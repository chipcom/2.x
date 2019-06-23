***** mo_platp.prg - Информация ПЛАТНЫЕ
#include "set.ch"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 02.05.18
Function Po_statist(k)
Static si1 := 1, si2 := 1, si3 := 1, si4
Local uch_otd, mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
//ВРЕМЕННО
//Private COUNT_UCH := 1
do case
  case k == 1
    uch_otd := saveuchotd()
    mas_pmt := {"~Объем работ",;
                "По № ~квитанционной книжки",;
                "По ~направившему врачу",;
                "ДМС и ~взаимозачет",;
                "~Множественный запрос",;   //             "~Сводная ведомость",;
                "~Журнал Регистрации",;
                "Настраиваемый журнал ~Регистрации",; //21.05.08
                "По дате приема ~денег";
               }
    mas_msg := {"Статистика по объему работ персонала (по дате окончания лечения)",;
                "Статистика по объему работ (по номеру квитанционной книжки)",;
                "Статистика по направившим врачам",;
                "Инф-ия о больных (о персонале), которые лечились (работали) по ДМС и взаимозач.",;
                "Множественный запрос",;   //              "Сводная ведомость по объему работ персонала [по всем задачам]",;
                "Журнал регистрации договоров",;
                "Настраиваемый журнал Регистрации",; //21.05.08
                "По дате приема денег";
               }
    mas_fun := {"Po_statist(11)",;
                "Po_statist(12)",;
                "Po_statist(13)",;
                "Po_statist(14)",;
                "Po_statist(15)",;    //             "Po_statist(16)",;
                "Po_statist(18)",;
                "Po_statist(19)",;
                "Po_statist(17)";
               }
    Private p_net_otd := .t.
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
    restuchotd(uch_otd)
  case k == 11
    Pob_statist()
  case k == 12
    k_statist(1)
  case k == 13
    mas_pmt := {"~Врачи + кол-во больных",;
                "Врачи + ~услуги"}
    mas_msg := {"Статистика по направившим врачам с подсчетом количества больных",;
                "Статистика по направившим врачам с расшифровкой по услугам"}
    mas_fun := {"Po_statist(31)",;
                "Po_statist(32)"}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)
  case k == 14
    mas_pmt := {"~Больные по ДМС и взаимозачету",;
                "~Оплата по ДМС и взаимозачету",;
                "Оборотная ве~домость",;
                "~Врачи по ДМС и взаимозачету"}
    mas_msg := {"Информация о больных, которые лечились по ДМС и взаимозачету",;
                "Информация о платежах от предприятий по ДМС и взаимозачету",;
                "Получение оборотных ведомостей по ДМС и взаимозачету",;
                "Информация о врачах, которые работали по ДМС и взаимозачету"}
    mas_fun := {"Po_statist(21)",;
                "Po_statist(22)",;
                "Po_statist(23)",;
                "Po_statist(24)"}
    if is_oplata != 7
       aadd(mas_pmt,"~Медсестры по ДМС и взаимозачету")
       aadd(mas_pmt,"~Санитарки по ДМС и взаимозачету")
       aadd(mas_msg,"Информация о медсестрах, которые работали по ДМС и взаимозачету")
       aadd(mas_msg,"Информация о санитарках, которые работали по ДМС и взаимозачету")
       aadd(mas_fun,"Po_statist(25)")
       aadd(mas_fun,"Po_statist(26)")
    endif
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 15
    pl_mnog_poisk()
  case k == 16
   // sv_ved_plat()
   ne_real()
  case k == 17
    mas_pmt := {"~Сводная по организации",;
                "~По кассовым аппаратам",;
                "По ~кассирам"}
    mas_msg := {"Статистика по услугам по дате приема денег",;
                "Статистика по дате приема денег с группировкой по кассовым аппаратам",;
                "Статистика по дате приема денег с группировкой по кассирам"}
    mas_fun := {"Po_statist(71)",;
                "Po_statist(72)",;
                "Po_statist(73)";
                }
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)
  case k == 18
    pl_pl_dogovor()
  case k == 19
    pl_pl_2dogovor()
****************************
  case eq_any(k,21,24,25,26)
    DEFAULT si4 TO glob_close+1
    mas_pmt := {"По дате ~окончания лечения",;
                "По дате ~закрытия л/учета"}
    if (j := popup_prompt(T_ROW,T_COL-5,si4,mas_pmt)) > 0
      si4 := j
      Private pi1 := si4+1
      if k == 21
        pl_vzaimozach()
      else
        vr_vzaimozach(k-23)
      endif
    endif
  case k == 22
    pr_opl_vz()
  case k == 23
    ob_ved_vz()
****************************
  case k == 31
    pl_napr_vrach()
  case k == 32
    pl_napr2vrach()
  case k == 71
    pl2_priemden(1)
  case k == 72
    pl1_priemden(2)
  case k == 73
    pl1_priemden(3)
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  elseif between(k,31,39)
    si3 := j
  endif
endif
return NIL

************************* Объем работ персонала *******************************

*****
Function Pob_statist()
Static si
Local mas_pmt := {"Объем работ (по дате ~лечения)",;
                  "Объем работ (по дате ~окончания лечения)",;
                  "Объем работ (по дате ~закрытия л/учета)"}
Local mas_msg := {"Статистика по объему работ персонала (по дате лечения)",;
                  "Статистика по объему работ персонала (по дате окончания лечения)",;
                  "Статистика по объему работ персонала (по дате закрытия листа учета)"}
Local mas_fun := {"Pob1_statist(0,1)",;
                  "Pob1_statist(0,2)",;
                  "Pob1_statist(0,3)"}
Private pi1 := si, psz
DEFAULT si TO glob_close+2
popup_prompt(T_ROW,T_COL-5,si,mas_pmt,mas_msg,mas_fun)
if pi1 != NIL ; si := pi1 ; endif
return NIL

***** объем работ персонала
Function Pob1_statist(k,k1)
Static si0 := 1, si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1, si_slugba
Local mas_pmt, mas_msg, mas_fun, j, fl
do case
  case k == 0
    pi1 := k1
    mas_pmt := {"~Стоимость лечения",;
                "~Заработная плата"}
    mas_msg := {"Статистика по объему работ с подсчетом стоимости лечения",;
                "Статистика по объему работ с подсчетом заработной платы"}
    mas_fun := {"Pob1_statist(1,1)",;
                "Pob1_statist(1,2)"} //
    popup_prompt(T_ROW,T_COL-5,si0,mas_pmt,mas_msg,mas_fun,color0+",R/BG,GR+/N")
  case k == 1
    psz := si0 := k1
    mas_pmt := {"~Отделения",;
                "~Службы",;
                "~Персонал",;
                "~Услуги"}
    mas_msg := {"Статистика по работе персонала и оказанным услугам в отделениях",;
                "Количество услуг и сумма лечения по службам",;
                "Статистика по работе персонала (независимо от отделения)",;
                "Статистика по оказанию конкретных услуг (независимо от отделения)"}
    mas_fun := {"Pob1_statist(11)",;
                "Pob1_statist(12)",;
                "Pob1_statist(13)",;
                "Pob1_statist(14)"}
    popup_prompt(T_ROW-len(mas_pmt)-3,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11  // отделения
    mas_pmt := {"~Список отделений",;
                "Отделение + ~персонал",;
                "Отделение + ~услуги",;
                "~Отделение + персонал + услуги",;
                "Отделение + услуга + ~больные",;
                "Отделение + ~1 человек + больные",;
                "Отделения + больные + услуги",;
                "Больные по от~делениям"}
    mas_msg := {"Количество услуг и сумма лечения по отделениям",;
                "Статистика по работе персонала в конкретном отделении",;
                "Статистика по услугам, оказанным в конкретном отделении",;
                "Статистика по работе персонала (плюс оказанные услуги) в конкретном отделении",;
                "Статистика по оказанной услуге (плюс больные) в конкретном отделении",;
                "Статистика по работе 1 человека (плюс больные) в конкретном отделении",;
                "Статистика по работе персонала во многих отделениях",;
                "Список больных с суммами лечения в каждом из отделений"}
    mas_fun := {"Pob1_statist(21)",;
                "Pob1_statist(22)",;
                "Pob1_statist(23)",;
                "Pob1_statist(24)",;
                "Pob1_statist(25)",;
                "Pob1_statist(26)",;
                "Pob1_statist(27)",;
                "Pob1_statist(28)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 12  // службы
    mas_pmt := {"Службы + ~отделения",;
                "Службы + ~услуги",;
                "Служб~а + услуги"}
    mas_msg := {"Количество услуг и сумма лечения по службам (с разбивкой по отделениям)",;
                "Статистика по оказанным услугам (с объединением по службам)",;
                "Статистика по оказанным услугам (по конкретной службе)"}
    mas_fun := {"Pob1_statist(31)",;
                "Pob1_statist(32)",;
                "Pob1_statist(33)"}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)
  case k == 13  // персонал
    mas_pmt := {"1 человек + ~услуги",;
                "~1 человек + услуги + больные",;
                "~Весь персонал",;
                "~Список персонала + услуги",;
                "~Больные + персонал"}
    mas_msg := {"Статистика по работе конкретного работающего (плюс оказанные услуги)",;
                "Статистика по работе конкретного работающего (плюс услуги плюс больные)",;
                "Количество услуг и сумма лечения по всему списку работающих",;
                "Статистика по работе некоторых работающих (плюс оказанные услуги)",;
                "Список больных с разбивкой сумм лечения по каждому врачу (м/сестре, санитарке)"}
    mas_fun := {"Pob1_statist(41)",;
                "Pob1_statist(42)",;
                "Pob1_statist(43)",;
                "Pob1_statist(44)",;
                "Pob1_statist(45)"}
    if is_oplata != 7
      aadd(mas_pmt,"~Медсестры")
      aadd(mas_pmt,"С~анитарки")
      aadd(mas_msg,"Список медсестер с заработанными суммами")
      aadd(mas_msg,"Список санитарок с заработанными суммами")
      aadd(mas_fun,"Pob1_statist(46)")
      aadd(mas_fun,"Pob1_statist(47)")
    endif
    popup_prompt(T_ROW,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
  case k == 14  // услуги
    mas_pmt := {"~Список услуг",;
                "Все ~услуги",;
                "Список услуг+~больные"}
    mas_msg := {"Статистика по оказанию конкретных услуг (независимо от отделения)",;
                "Статистика по оказанию всех услуг (независимо от отделения)",;
                "Статистика по оказанию конкретных услуг [с больными] (независимо от отделения)"}
    mas_fun := {"Pob1_statist(51)",;
                "Pob1_statist(52)",;
                "Pob1_statist(53)"}
    popup_prompt(T_ROW,T_COL-5,si5,mas_pmt,mas_msg,mas_fun)
*** отделения
  case k == 21    // список отделений
    Pob2_statist(1)
  case k == 22    // отделение + персонал
    Pob2_statist(2)
  case k == 23    // отделение + услуги
    Pob2_statist(3)
  case k == 24    // отделение + персонал + услуги
    Pob2_statist(4)
  case k == 25    // отделение + услуга + больные
    Pob2_statist(8)
  case k == 26    // отделение + персонал + больные
    Pob2_statist(9)
  case k == 27    // Список больных с суммами лечения в каждом из отделений
    st1_plat_fio()
  case k == 28    // Список больных с суммами лечения в каждом из отделений
    st_plat_fio(1)
*** службы
  case k == 31    // службы + отделения
    Pob2_statist(0)
  case k == 32    // службы + услуги
    Pob2_statist(10)
  case k == 33    // служба + услуги
    fl := .f.
    G_Use(dir_server+"slugba",dir_server+"slugba","SL")
    if si_slugba == NIL
      go top
    else
      find (str(si_slugba,3))
    endif
    if Alpha_Browse(T_ROW,T_COL-5,maxrow()-2,T_COL+45,"f2spr_other",color0)
      fl := .t. ; si_slugba := sl->shifr
      j := { sl->shifr, lstr(sl->shifr)+". "+alltrim(sl->name) }
    endif
    sl->(dbCloseArea())
    if fl
      Pob2_statist(11,j)
    endif
*** персонал
  case k == 41    // конкретный работающий + услуги
    Pob2_statist(5)
  case k == 42    // конкретный работающий + услуги + больные
    if (j := popup_prompt(T_ROW,T_COL-5,si5,;
                       {"Все ~услуги","~Список услуг"})) > 0
      Pob2_statist(13,,(j==1))
    endif
  case k == 43    // список персонала с объемом работ
    Pob2_statist(7)
  case k == 44    // список работающих + услуги
    Pob2_statist(5,{1})
  case k == 45    // Список больных с разбивкой сумм лечения по каждому врачу (м/сестре, санитарке)
    st_plat_fio(2)
  case k == 46    // Список медсестер с заработанными суммами
    st_plat_ms(1)
  case k == 47    // Список санитарок с заработанными суммами
    st_plat_ms(2)
*** услуги
  case k == 51    // список услуг
    Pob2_statist(6)
  case k == 52    // все услуги
    Pob2_statist(12)
  case k == 53    // список услуг + больные
    Pob2_statist(14)
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  elseif between(k,31,39)
    si3 := j
  elseif between(k,41,49)
    si4 := j
  elseif between(k,51,59)
    si5 := j
  endif
endif
return NIL

*

***** 01.03.19
Function Pob2_statist(k,serv_arr,is_all)
Local i, j, arr[2], begin_date, end_date, bk := 1, ek := 99, al,;
      fl_exit := .f., sh := 80, HH := 57, regim := 2, s, fl_1_list := .t.,;
      len_n, pkol, ptrud, pstoim, old_perso, old_usl,;
      old_fio, arr_otd := {}, md, mkol, mstoim, arr_kd := {}, len_kd := 0,;
      xx, yy, lrec, t_date1, t_date2, arr_title, msum, msum_opl,;
      musluga, mperso, mkod_perso, arr_usl := {}, adbf1, adbf2,;
      arr_svod_nom := {}, ssumv_ysl := 0, ssumv_sum := 0, ssumv_uet := 0,;
      ssuma_ysl := 0, ssuma_sum := 0, ssuma_uet := 0
DEFAULT is_all TO .t.
Private skol := {0,0}, strud := {0,0}, sstoim := {0,0}, krvz, arr_dms
if equalany(k,2,3,4,8,9)  // по отделению
  if (st_a_otd := inputN_otd(T_ROW,T_COL-5,.f.,.f.)) == NIL
    return NIL
  endif
  aeval(st_a_otd, {|x| aadd(arr_otd,x) })
  if k == 8 .and. (musluga := input_usluga()) == NIL
    return NIL
  endif
  if k == 9 .and. !input_perso(T_ROW,T_COL-5,.f.)
    return NIL
  endif
else  // по учреждению(ям)
  if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) == NIL
    return NIL
  endif
  R_Use(dir_server+"mo_otd",,"OTD")
  dbeval({|| aadd(arr_otd,{otd->(recno()),otd->name,otd->kod_lpu}) },;
         {|| f_is_uch(st_a_uch,otd->kod_lpu)} )
  OTD->(dbCloseArea())
  if len(st_a_uch) > 1
    G_Use(dir_server+"mo_uch",,"UCH")
    for i := 1 to len(arr_otd)
      goto (arr_otd[i,3])
      arr_otd[i,2] := "["+alltrim(uch->name)+"] "+alltrim(arr_otd[i,2])
    next
    uch->(dbCloseArea())
  endif
  if ((k==5.and.serv_arr==NIL) .or. k==13) .and. !input_perso(T_ROW,T_COL-5,.f.)
    return NIL
  endif
endif
if (arr := year_month()) == NIL
  return NIL
endif
begin_date := arr[7]
end_date := arr[8]
if k == 5 .and. serv_arr != NIL .and. (mperso := input_kperso()) == NIL
  mywait()
  mperso := {}
  R_Use(dir_server+"mo_pers",,"PERSO")
  go top
  do while !eof()
    if perso->kod > 0
      aadd(mperso, {perso->kod,""} )
    endif
    skip
  enddo
  perso->(dbCloseArea())
endif
if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
if pi1 == 1  // по дате лечения
 /* G_Use(dir_server+"mo_otd",,"OTD")
  dbeval({|| if(otd->usluga > 0 .and. ascan(arr_kd,otd->usluga) == 0, ;
                   aadd(arr_kd,otd->usluga), NIL),;
             if(otd->usluga_d > 0 .and. ascan(arr_kd,otd->usluga_d) == 0, ;
                   aadd(arr_kd,otd->usluga_d), NIL);
         },;
         {|| f_is_uch(st_a_uch,otd->kod_lpu)} )
  OTD->(dbCloseArea())
  len_kd := len(arr_kd)
  */
endif
adbf1 := {;
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0},;  // наименование услуги
     {"FIO",        "C",     25,      0},;  // ФИО больного
     {"KOD",        "N",      7,      0},;  // код больного
     {"K_DATA",     "D",      8,      0},;  // дата окончания лечения
     {"KOL"    ,    "N",      5,      0},;  // количество услуг
     {"STOIM",      "N",     20,      4};   // стоимость услуг
    }
adbf2 := {;
     {"otd",        "N",      3,      0},;  // отделение, где оказана услуга
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0},;  // наименование услуги
     {"VR_AS",      "N",      1,      0},;  // врач - 1 ; ассистент - 2
     {"TAB_NOM",    "N",      5,      0},;  // таб.номер врача (ассистента)
     {"SVOD_NOM",   "N",      5,      0},;  // сводный таб.номер
     {"KOD_VR",     "N",      4,      0},;  // код врача
     {"FIO",        "C",     50,      0},;  // Ф.И.О. врача
     {"TRUDOEM",    "N",     11,      4},;  // трудоемкость услуг УЕТ
     {"KOL"    ,    "N",      6,      0},;  // количество услуг
     {"STOIM"  ,    "N",     16,      4};   // итоговая стоимость услуги
    }
if k == 13 .and. !is_all
  dbcreate(cur_dir+"tmp", adbf2)
  use (cur_dir+"tmp")
  index on str(u_kod,4) to (cur_dir+"tmpk")
  index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
  close databases
  ob2_v_usl()
  use (cur_dir+"tmp")
  dbeval({|| aadd(arr_usl,tmp->u_kod) } )
  use
  if len(arr_usl) == 0
    return NIL
  endif
endif
if equalany(k,8,9,13,14)  // вывод списка больных
  dbcreate(cur_dir+"tmp", adbf1)
else
  dbcreate(cur_dir+"tmp", adbf2)
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
use (cur_dir+"tmp")
do case
  case k == 0  // Количество услуг и сумма лечения по службам (с разбивкой по отделениям)
    index on str(kod_vr,4)+str(otd,3) to (cur_dir+"tmpk")
    index on str(kod_vr,4)+upper(left(u_name,20)) to (cur_dir+"tmpn")
  case k == 1  // Количество услуг и сумма лечения по отделениям
    index on str(otd,3) to (cur_dir+"tmpk")
    index on fio to (cur_dir+"tmpn")
  case k == 2  // Статистика по работе персонала в конкретном отделении
    index on str(vr_as,1)+str(kod_vr,4) to (cur_dir+"tmpk")
    index on upper(left(fio,30))+str(kod_vr,4)+str(vr_as,1) to (cur_dir+"tmpn")
  case k == 3  // Статистика по услугам, оказанным в конкретном отделении
    index on str(u_kod,4) to (cur_dir+"tmpk")
    index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
  case k == 4  // Статистика по работе персонала (плюс оказанные услуги) в конкретном отделении
    index on str(vr_as,1)+str(kod_vr,4)+str(u_kod,4) to (cur_dir+"tmpk")
    index on upper(left(fio,30))+str(kod_vr,4)+str(vr_as,1)+fsort_usl(u_shifr) to (cur_dir+"tmpn")
  case k == 5  // Статистика по работе конкретного человека (плюс оказанные услуги)
    index on str(vr_as,1)+str(kod_vr,4)+str(u_kod,4) to (cur_dir+"tmpk")
    if serv_arr == NIL
      index on str(vr_as,1)+fsort_usl(u_shifr) to (cur_dir+"tmpn")
    else
      index on upper(left(fio,30))+str(kod_vr,4)+str(vr_as,1)+fsort_usl(u_shifr) to (cur_dir+"tmpn")
    endif
  case k == 6  // Статистика по конкретным услугам
    index on str(u_kod,4) to (cur_dir+"tmpk")
    index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
    close databases
    ob2_v_usl()
  case k == 7  // Статистика по работе всего персонала
    index on str(vr_as,1)+str(kod_vr,4) to (cur_dir+"tmpk")
    index on upper(left(fio,30))+str(kod_vr,4)+str(vr_as,1) to (cur_dir+"tmpn")
  case equalany(k,8,9)  // вывод списка больных
    index on str(kod,7) to (cur_dir+"tmpk")
    index on dtos(k_data)+upper(left(fio,30)) to (cur_dir+"tmpn")
  case k == 10 // Статистика по услугам по всем службам
    index on str(u_kod,4) to (cur_dir+"tmpk")
    index on str(kod_vr,4)+fsort_usl(u_shifr) to (cur_dir+"tmpn")
  case k == 11 // Статистика по услугам конкретной службы
    index on str(u_kod,4) to (cur_dir+"tmpk")
    index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
  case k == 12 // Статистика по всем услугам
    index on str(u_kod,4) to (cur_dir+"tmpk")
    index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
  case k == 13  // вывод услуг + списка больных
    index on str(u_kod,4)+str(kod,7) to (cur_dir+"tmpk")
    index on fsort_usl(u_shifr)+str(u_kod,4)+dtos(k_data)+upper(left(fio,30)) to (cur_dir+"tmpn")
  case k == 14  // Статистика по конкретным услугам + список больных
    index on str(u_kod,4)+str(kod,7) to (cur_dir+"tmpk")
    index on fsort_usl(u_shifr)+str(u_kod,4)+dtos(k_data)+upper(left(fio,30)) to (cur_dir+"tmpn")
    close databases
    ob2_v_usl()
endcase
use (cur_dir+"tmp") index (cur_dir+"tmpk"),(cur_dir+"tmpn") alias TMP
if mem_trudoem == 2
  useUch_Usl()
endif
//G_Use(dir_server+"cena_usl",dir_server+"cena_usl","CENA")
G_Use(dir_server+"kartotek",,"KART")
G_Use(dir_server+"uslugi",,"USL")
Private is_1_usluga := (len(arr_usl) == 1)
if psz == 2 .and. eq_any(is_oplata,5,6,7)
  open_opl_5()
  if is_oplata == 7
    cre_tmp7()
  endif
endif
R_Use(dir_server+"mo_pers",,"PERSO")
if equalany(k,5,9,13)  // Статистика по работе конкретного врача/ассистента
  if serv_arr == NIL
    mperso := {glob_human}
  endif
  G_Use(dir_server+"hum_p",,"HUMAN")
  G_Use(dir_server+"hum_p_u",{dir_server+"hum_p_uv",;
                              dir_server+"hum_p_ua",;
                              dir_server+"hum_p_u"},"HU")
  if pi1 == 3  // по дате закрытия листа учета
    select HU
    set index to (dir_server+"hum_p_u")
    select HUMAN
    set index to (dir_server+"hum_pc")
    for xx := 0 to 2
      if ascan(krvz,xx) > 0
        select HUMAN
        dbseek(str(xx,1)+"1"+dtos(arr[5]),.t.)
        do while human->tip_usl==xx .and. human->date_close <= arr[6] .and. !eof()
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          select HU
          find (str(human->(recno()),7))
          do while hu->kod == human->(recno())
            for yy := 1 to 2
              pole_va := {"hu->kod_vr","hu->kod_as"}[yy]
              mkod_perso := &pole_va
              if ascan(mperso, {|x| x[1]==mkod_perso}) > 0
                if k == 5
                  Pob3_statist(k, arr_otd, serv_arr, mkod_perso)
                elseif equalany(k,9,13) .and. ;
                      if(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                  Pob5_statist(k, arr_otd, serv_arr, mkod_perso)
                endif
              endif
            next
            select HU
            skip
          enddo
          select HUMAN
          skip
        enddo
      endif
      if fl_exit ; exit ; endif
    next
  else
    for yy := 1 to len(mperso)
      mkod_perso := mperso[yy,1]
      select HU
      for xx := 1 to 2
        pole_va := {"hu->kod_vr","hu->kod_as"}[xx]
        select HU
        if xx == 1
          set order to 1
        elseif xx == 2
          set order to 2
        endif
        do case
          case pi1 == 1  // по дате лечения
            if len_kd > 0  // если есть услуги "Койко-день" для работающих отделений
              // сначала проверим койко-дни за 60 дней до начальной даты
              dbseek(str(mkod_perso,4)+dtoc4(arr[5]-60),.t.)
              do while &pole_va == mkod_perso .and. hu->date_u < begin_date
                UpdateStatus()
                if inkey() == K_ESC
                  fl_exit := .t. ; exit
                endif
                if ascan(arr_kd,hu->u_kod) > 0 .and. hu->kol > 0 .and. ;
                        (i := ascan(arr_otd, {|x| hu->otd==x[1]})) > 0 .and. ;
                                (md := c4tod(hu->date_u) + hu->kol - 1) >= arr[5]
                  human->(dbGoto(hu->kod))
                  if k == 5
                    // если дата окончания койко-дней >= begin_date
                    md := min(md,arr[6])
                    mkol := md - arr[5] + 1
                    mstoim := round_5(hu->stoim/hu->kol*mkol, 2)
                    Pob4_statist(k, arr_otd, i, mkol, mstoim, serv_arr, mkod_perso)
                  elseif equalany(k,9,13) .and. ;
                        if(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                    Pob5_statist(k, , serv_arr, mkod_perso)
                  endif
                endif
                select HU
                skip
              enddo
            endif
            if !fl_exit
              select HU
              dbseek(str(mkod_perso,4)+begin_date,.t.)
              do while &pole_va == mkod_perso .and. hu->date_u <= end_date
                UpdateStatus()
                if inkey() == K_ESC
                  fl_exit := .t. ; exit
                endif
                human->(dbGoto(hu->kod))
                if len_kd > 0 .and. ascan(arr_kd,hu->u_kod) > 0  // койко-день
                  if hu->kol > 0 .and. (i := ascan(arr_otd, {|x| hu->otd==x[1]})) > 0
                    if (md := c4tod(hu->date_u)) + hu->kol - 1 > arr[6]
                      // если кол-во койко-дней выходит за конечную дату
                      mkol := arr[6] - md + 1
                      mstoim := round_5(hu->stoim/hu->kol*mkol, 2)
                    else  // если кол-во койко-дней умещается в диапазоне дат
                      mkol := hu->kol
                      mstoim := hu->stoim
                    endif
                    if k == 5
                      Pob4_statist(k, arr_otd, i, mkol, mstoim, serv_arr, mkod_perso)
                    elseif equalany(k,9,13) .and. ;
                        if(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                      Pob5_statist(k, , serv_arr, mkod_perso)
                    endif
                  endif
                else
                  if k == 5
                    Pob3_statist(k, arr_otd, serv_arr, mkod_perso)
                  elseif equalany(k,9,13) .and. ;
                        if(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                    Pob5_statist(k, arr_otd, serv_arr, mkod_perso)
                  endif
                endif
                select HU
                skip
              enddo
            endif
          case pi1 == 2  // по дате окончания лечения
            select HU                      // на всякий случай отнимем 5 мес.
            dbseek(str(mkod_perso,4)+dtoc4(arr[5]-160),.t.)
            do while &pole_va == mkod_perso .and. hu->date_u <= end_date
              UpdateStatus()
              if inkey() == K_ESC
                fl_exit := .t. ; exit
              endif
              select HUMAN
              goto (hu->kod)
              if between(human->k_data,arr[5],arr[6])
                if k == 5
                  Pob3_statist(k, arr_otd, serv_arr, mkod_perso)
                elseif equalany(k,9,13) .and. ;
                      if(is_all, .t., ascan(arr_usl,hu->u_kod) > 0)
                  Pob5_statist(k, arr_otd, serv_arr, mkod_perso)
                endif
              endif
              select HU
              skip
            enddo
        endcase
      next
      if fl_exit ; exit ; endif
    next
  endif
elseif equalany(k,6,8,14)  // Статистика по конкретным(ой) услугам(е)
  if equalany(k,6,14)
    select TMP  // в базе данных уже занесены необходимые нам услуги
                // переносим их в массив arr_usl
    dbeval({|| aadd(arr_usl,{tmp->u_kod,tmp->(recno())}) } )
    if k == 14
      zap
    endif
  elseif k == 8
    arr_usl := {{musluga[1],0}}
  endif
  is_1_usluga := (len(arr_usl) == 1)
  t_date1 := dtoc4(arr[5]-60)
  t_date2 := dtoc4(arr[5]-1)
  G_Use(dir_server+"hum_p",,"HUMAN")
  G_Use(dir_server+"hum_p_u",{dir_server+"hum_p_uk",;
                              dir_server+"hum_p_u"},"HU")
  for xx := 1 to len(arr_usl)
    if k == 6
      tmp->(dbGoto(arr_usl[xx,2]))
      lrec := tmp->(recno())
    endif
    do case
      case pi1 == 1  // по дате лечения
        select HU
        find (str(arr_usl[xx,1],4))
        do while hu->u_kod == arr_usl[xx,1]
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          select HUMAN
          goto (hu->kod)
          // сначала проверим койко-дни за 60 дней до начальной даты
          if len_kd > 0 .and. between(hu->date_u,t_date1,t_date2) .and. ;
               ascan(arr_kd,hu->u_kod) > 0 .and. hu->kol > 0 .and. ;
                  (i := ascan(arr_otd, {|x| hu->otd==x[1]})) > 0 .and. ;
                          (md := c4tod(hu->date_u) + hu->kol - 1) >= arr[5]
            if k == 6
              // если дата окончания койко-дней >= begin_date
              md := min(md,arr[6])
              mkol := md - arr[5] + 1
              mstoim := round_5(hu->stoim/hu->kol*mkol, 2)
              Pob4_statist(k, arr_otd, i, mkol, mstoim, serv_arr)
            elseif equalany(k,8,14)
              Pob5_statist(k, , serv_arr)
            endif
          elseif between(hu->date_u,begin_date,end_date)
            // если койко-день
            if len_kd > 0 .and. ascan(arr_kd,hu->u_kod) > 0
              if hu->kol > 0 .and. (i := ascan(arr_otd, {|x| hu->otd==x[1]})) > 0
                if (md := c4tod(hu->date_u)) + hu->kol - 1 > arr[6]
                  // если кол-во койко-дней выходит за конечную дату
                  mkol := arr[6] - md + 1
                  mstoim := round_5(hu->stoim/hu->kol*mkol, 2)
                else  // если кол-во койко-дней умещается в диапазоне дат
                  mkol := hu->kol
                  mstoim := hu->stoim
                endif
                if k == 6
                  Pob4_statist(k, arr_otd, i, mkol, mstoim, serv_arr)
                elseif equalany(k,8,14)
                  Pob5_statist(k, , serv_arr)
                endif
              endif
            else
              if k == 6
                Pob3_statist(k, arr_otd, serv_arr)
              elseif equalany(k,8,14)
                Pob5_statist(k, arr_otd, serv_arr)
              endif
            endif
          endif
          select HU
          skip
        enddo
      case pi1 == 2  // по дате окончания лечения
        select HU
        find (str(arr_usl[xx,1],4))
        do while hu->u_kod == arr_usl[xx,1]
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          select HUMAN
          goto (hu->kod)
          if between(human->k_data,arr[5],arr[6])
            if k == 6
              Pob3_statist(k, arr_otd, serv_arr)
            elseif equalany(k,8,14)
              Pob5_statist(k, arr_otd, serv_arr)
            endif
          endif
          select HU
          skip
        enddo
      case pi1 == 3  // по дате закрытия листа учета
        select HU
        find (str(arr_usl[xx,1],4))
        do while hu->u_kod == arr_usl[xx,1]
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          select HUMAN
          goto (hu->kod)
          if !empty(human->date_close) .and. between(human->date_close,arr[5],arr[6])
            if k == 6
              Pob3_statist(k, arr_otd, serv_arr)
            elseif equalany(k,8,14)
              Pob5_statist(k, arr_otd, serv_arr)
            endif
          endif
          select HU
          skip
        enddo
    endcase
    if fl_exit ; exit ; endif
  next
else
  do case
    case pi1 == 1  // по дате лечения
      G_Use(dir_server+"hum_p",,"HUMAN")
      G_Use(dir_server+"hum_p_u",dir_server+"hum_p_ud","HU")
      set relation to kod into HUMAN
      if len_kd > 0  // если есть услуги "Койко-день" для работающих отделений
        // сначала проверим койко-дни за 60 дней до начальной даты
        dbseek(dtoc4(arr[5]-60),.t.)
        do while hu->date_u < begin_date .and. !eof()
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          if ascan(arr_kd,hu->u_kod) > 0 .and. hu->kol > 0 .and. ;
                  (i := ascan(arr_otd, {|x| hu->otd==x[1]})) > 0 .and. ;
                          (md := c4tod(hu->date_u) + hu->kol - 1) >= arr[5]
            // если дата окончания койко-дней >= begin_date
            md := min(md,arr[6])
            mkol := md - arr[5] + 1
            mstoim := round_5(hu->stoim/hu->kol*mkol, 2)
            Pob4_statist(k, arr_otd, i, mkol, mstoim, serv_arr)
          endif
          select HU
          skip
        enddo
      endif
      if !fl_exit
        select HU
        dbseek(begin_date,.t.)
        do while hu->date_u <= end_date .and. !eof()
          UpdateStatus()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          if len_kd > 0 .and. ascan(arr_kd,hu->u_kod) > 0  // койко-день
            if hu->kol > 0 .and. (i := ascan(arr_otd, {|x| hu->otd==x[1]})) > 0
              if (md := c4tod(hu->date_u)) + hu->kol - 1 > arr[6]
                // если кол-во койко-дней выходит за конечную дату
                mkol := arr[6] - md + 1
                mstoim := round_5(hu->stoim/hu->kol*mkol, 2)
              else  // если кол-во койко-дней умещается в диапазоне дат
                mkol := hu->kol
                mstoim := hu->stoim
              endif
              Pob4_statist(k, arr_otd, i, mkol, mstoim, serv_arr)
            endif
          else
            Pob3_statist(k, arr_otd, serv_arr)
          endif
          select HU
          skip
        enddo
      endif
    case pi1 == 2  // по дате окончания лечения
      G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
      G_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
      dbseek(dtos(arr[5]),.t.)
      do while human->k_data <= arr[6] .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        select HU
        find (str(human->(recno()),7))
        do while hu->kod == human->(recno())
          Pob3_statist(k, arr_otd, serv_arr)
          select HU
          skip
        enddo
        select HUMAN
        skip
      enddo
    case pi1 == 3  // по дате закрытия листа учета
      G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
      G_Use(dir_server+"hum_p",dir_server+"hum_pc","HUMAN")
      for xx := 0 to 2
        if ascan(krvz,xx) > 0
          select HUMAN
          dbseek(str(xx,1)+"1"+dtos(arr[5]),.t.)
          do while human->tip_usl==xx .and. human->date_close <= arr[6] .and. !eof()
            UpdateStatus()
            if inkey() == K_ESC
              fl_exit := .t. ; exit
            endif
            select HU
            find (str(human->(recno()),7))
            do while hu->kod == human->(recno())
              Pob3_statist(k, arr_otd, serv_arr)
              select HU
              skip
            enddo
            select HUMAN
            skip
          enddo
        endif
        if fl_exit ; exit ; endif
      next
  endcase
endif
j := tmp->(lastrec())
close databases
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  if equalany(k,8,9,13,14)
    arr_title := {;
"─────────────────────────┬─────┬────────┬───────────────",;
"                         │Отде-│  Дата  │               ",;
"         Ф.И.О.          │ление│окон.леч│ Сумма лечения ",;
"─────────────────────────┴─────┴────────┴───────────────"}
    G_Use(dir_server+"mo_otd",,"OTD")
    G_Use(dir_server+"hum_p",,"HUMAN")
    set relation to otd into OTD
 else
    len_n := 58
    if mem_trudoem == 2
      len_n := 49
    endif
    arr_title := array(4)
    arr_title[1] := replicate("─",len_n)
    arr_title[2] := space(len_n)
    arr_title[3] := space(len_n)
    arr_title[4] := replicate("─",len_n)
    arr_title[1] += "┬──────"
    arr_title[2] += "│Кол-во"
    arr_title[3] += "│ услуг"
    arr_title[4] += "┴──────"
    if mem_trudoem == 2
      arr_title[1] += "┬────────"
      arr_title[2] += "│        "
      arr_title[3] += "│ У.Е.Т. "
      arr_title[4] += "┴────────"
    endif
    arr_title[1] += "┬──────────────"
    arr_title[2] += "│"+padc(if(psz==1,"Стоимость","Заработная"),14)
    arr_title[3] += "│"+padc(if(psz==1,"услуг","плата"),14)
    arr_title[4] += "┴──────────────"
  endif
  sh := len(arr_title[1])
  SET(_SET_DELETED, .F.)
  use (cur_dir+"tmp") index (cur_dir+"tmpk"),(cur_dir+"tmpn") NEW alias TMP
  if !equalany(k,1,8,9)
    if equalany(k,0,10)
      R_Use(dir_server+"slugba",dir_server+"slugba","SL")
    endif
    if between(k,3,6) .or. between(k,10,14)
      R_Use(dir_server+"uslugi",,"USL")
    endif
    R_Use(dir_server+"mo_pers",,"PERSO")
    select TMP
    set order to 0
    go top
    do while !eof()
      if equalany(k,0,10)
        select SL
        find (str(tmp->kod_vr,3))
        if found() .and. !deleted()
          tmp->fio := str(sl->shifr,3)+". "+sl->name
        else
          select TMP
          DELETE
        endif
      endif
      if between(k,3,6) .or. between(k,10,14)
        select USL
        goto (tmp->u_kod)
        if usl->kod <= 0 .or. deleted() .or. eof()
          select TMP
          DELETE
        else
          tmp->u_shifr := usl->shifr
          if glob_mo[_MO_KOD_TFOMS] == '171004' // КБ-4
            tmp->u_name := usl->full_name
          else
            tmp->u_name := usl->name
          endif
        endif
      endif
      if equalany(k,2,4,5,7)
        select PERSO
        goto (tmp->kod_vr)
        if deleted() .or. eof()
          select TMP
          DELETE
        else
          tmp->fio := perso->fio
          tmp->tab_nom := perso->tab_nom
          tmp->svod_nom := iif(empty(perso->svod_nom),perso->tab_nom,perso->svod_nom)  //ЮРА
          if k == 7
            if (i := ascan(arr_svod_nom, ;
                 {|x| x[1] == iif(empty(perso->svod_nom),perso->tab_nom,perso->svod_nom);
                              .and. x[2] == tmp->vr_as})) == 0 //ЮРА
              aadd(arr_svod_nom, {perso->svod_nom,tmp->vr_as,{}} )
              i := len(arr_svod_nom)
            endif
            aadd(arr_svod_nom[i,3], tmp->(recno()) )
            tmp->u_shifr := lstr(iif(empty(perso->svod_nom),perso->tab_nom,perso->svod_nom))//ЮРА
          endif
        endif
      endif
      select TMP
      skip
    enddo
    if k == 7 .and. len(arr_svod_nom) > 0
      select TMP
      for i := 1 to len(arr_svod_nom)
        pkol := ptrud := pstoim := 0
        for j := 2 to len(arr_svod_nom[i,3])
          goto (arr_svod_nom[i,3,j])
          ptrud  += tmp->TRUDOEM
          pkol   += tmp->KOL
          pstoim += tmp->STOIM
          DELETE
        next
        goto (arr_svod_nom[i,3,1])
        tmp->TRUDOEM += ptrud
        tmp->KOL     += pkol
        tmp->STOIM   += pstoim
      next
    endif
    if equalany(k,2,4,5,7)
      perso->(dbCloseArea())
    endif
  endif
  SET(_SET_DELETED, .T.)
  fp := fcreate("ob_stat"+stxt) ; tek_stroke := 0 ; n_list := 1
  add_string("ПЛАТНЫЕ УСЛУГИ")
  if k == 0
    add_string(center("Статистика по службам (с разбивкой по отделениям)",sh))
    titleN_uch(st_a_uch,sh)
  elseif k == 1
    add_string(center("Статистика по отделениям",sh))
    titleN_uch(st_a_uch,sh)
  elseif k == 5
    add_string(center("Статистика по оказанным услугам",sh))
    if serv_arr == NIL  // по одному человеку
      add_string(center('"'+upper(glob_human[2])+;
                        ' ['+lstr(glob_human[5])+']"',sh))
    endif
  elseif equalany(k,6,14)
    add_string(center("Статистика по услугам",sh))
    titleN_uch(st_a_uch,sh)
  elseif k == 7
    add_string(center("Статистика по работе персонала",sh))
    titleN_uch(st_a_uch,sh)
  elseif k == 10
    add_string(center("Статистика по услугам (с объединением по службам)",sh))
    titleN_uch(st_a_uch,sh)
  elseif k == 11
    add_string(center("Статистика по службе",sh))
    add_string(center(serv_arr[2],sh))
    titleN_uch(st_a_uch,sh)
  elseif k == 12
    add_string(center("Статистика по всем оказанным услугам",sh))
    titleN_uch(st_a_uch,sh)
  elseif k == 13
    add_string(center("Список больных, которым были оказаны услуги врачом (ассистентом):",sh))
    add_string(center('"'+upper(glob_human[2])+;
                      ' ['+lstr(glob_human[5])+']"',sh))
  else
    add_string(center("Статистика по отделению",sh))
    titleN_otd(st_a_otd,sh)
    add_string(center("< "+alltrim(glob_uch[2])+" >",sh))
    if equalany(k,8,9)
      add_string("")
      if k == 8
        add_string(center("Список больных, которым была оказана услуга:",sh))
        add_string(center('"'+musluga[2]+'"',sh))
      else
        add_string(center("Список больных, которым были оказаны услуги врачом (ассистентом):",sh))
        add_string(center('"'+upper(glob_human[2])+;
                          ' ['+lstr(glob_human[5])+']"',sh))
      endif
    endif
  endif
  tit_tip_usl(krvz,arr_dms,sh)
  add_string(center(arr[4],sh))
  add_string("")
  do case
    case pi1 == 1
      s := "[ по дате лечения ]"
    case pi1 == 2
      s := "[ по дате окончания лечения ]"
    case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
  endcase
  add_string(center(s,sh))
  add_string("")
  select TMP
  set order to 2
  go top
  if equalany(k,8,9,13,14)
    mb := mkol := msum := old_usl := 0
    aeval(arr_title, {|x| add_string(x) } )
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if equalany(k,13,14) .and. tmp->u_kod != old_usl
        if old_usl > 0
          add_string(replicate("─",sh))
          add_string(padr("Кол-во больных - "+lstr(mb),28)+;
                     padl(expand_value(msum,2),13)+" руб.")
          add_string(padl("Кол-во услуг - "+lstr(mkol),30))
          mb := mkol := msum := 0
        endif
        add_string("")
        add_string("│ "+rtrim(tmp->u_shifr)+". "+rtrim(tmp->u_name))
        add_string("└"+replicate("─",24))
      endif
      old_usl := tmp->u_kod
      select HUMAN
      goto (tmp->kod)
      s := tmp->fio+" "+otd->short_name+" "+date_8(tmp->k_data)+;
           padl(expand_value(tmp->stoim,2),16)
      add_string(s)
      mkol += tmp->kol ; msum += tmp->stoim ; ++mb
      select TMP
      skip
    enddo
    add_string(replicate("─",sh))
    add_string(padr("Кол-во больных - "+lstr(mb),28)+;
               padl(expand_value(msum,2),13)+" руб.")
    add_string(padl("Кол-во услуг - "+lstr(mkol),30))
  else
    pkol := ptrud := pstoim := 0

    old_perso := tmp->kod_vr ; old_vr_as := tmp->vr_as
    //old_fio := ""
    old_fio := "["+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+"] "
    old_fio += tmp->fio
    old_slugba := tmp->fio ; old_shifr := tmp->kod_vr
    if equalany(k,2,5,7)
      old_perso := -1  // для печати Ф.И.О. в начале
    endif
    select TMP
    do while !eof()
      if equalany(k,0,10) .and. old_shifr != tmp->kod_vr
        add_string(space(4)+replicate(".",sh-4))
        add_string(padr(space(4)+old_slugba,len_n)+;
                   str(pkol,7,0)+;
                   if(mem_trudoem==2,put_val_0(ptrud,9,1),"")+;
                   put_kopE(pstoim,15))
        add_string(replicate("─",sh))
        pkol := ptrud := pstoim := 0
      endif
      if k == 4 .and. !(old_perso == tmp->kod_vr .and. old_vr_as == tmp->vr_as)
        add_string(space(4)+replicate(".",sh-4))
        add_string(padr(space(4)+old_fio,len_n-4)+;
                   if(psz==1,if(old_vr_as==1,"врач","асс."),space(4))+;
                   str(pkol,7,0)+;
                   if(mem_trudoem==2,put_val_0(ptrud,9,1),"")+;
                   put_kopE(pstoim,15))
        add_string(replicate("─",sh))
        pkol := ptrud := pstoim := 0
      endif
      if fl_1_list .or. verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
        fl_1_list := .f.
      endif
      if k == 4
        pkol += tmp->kol
        ptrud += tmp->trudoem
        pstoim += tmp->stoim
        skol[tmp->vr_as] += tmp->kol
        strud[tmp->vr_as] += tmp->trudoem
        sstoim[tmp->vr_as] += tmp->stoim
        j := perenos(arr,tmp->u_shifr+" "+tmp->u_name,len_n)
        add_string(padr(arr[1],len_n)+;
                   str(tmp->kol,7,0)+;
                   if(mem_trudoem==2,put_val_0(tmp->trudoem,9,1),"")+;
                   put_kopE(tmp->stoim,15))
        for i := 2 to j
          add_string(space(11)+arr[i])
        next
        old_perso := tmp->kod_vr
        old_vr_as := tmp->vr_as
        old_fio := "["+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+"] "
        old_fio += tmp->fio
      else
        do case
          case k == 0
            s := padr(tmp->u_name,len_n)
            skol[1] += tmp->kol
            strud[1] += tmp->trudoem
            sstoim[1] += tmp->stoim
            pkol += tmp->kol
            ptrud += tmp->trudoem
            pstoim += tmp->stoim
            old_slugba := tmp->fio ; old_shifr := tmp->kod_vr
          case k == 1
            s := padr(tmp->fio,len_n)
            skol[1] += tmp->kol
            strud[1] += tmp->trudoem
            sstoim[1] += tmp->stoim
          case equalany(k,2,7)
            s := ""
            if old_perso != tmp->kod_vr
              if !empty(tmp->tab_nom)
                if alltrim(tmp->u_shifr) == lstr(tmp->tab_nom)
                  s := "["+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+"]"
                  if len(s) < 8
                    s := padr(s,8)
                  endif
                else
                  s := padr("[+"+alltrim(tmp->u_shifr)+"]",8)
                endif
              endif
              s += tmp->fio
            endif
            s := padr(s,len_n-5)+" "+;
                 if(psz==1,if(tmp->vr_as==1,"врач","асс."),space(4))
            skol[tmp->vr_as] += tmp->kol
            strud[tmp->vr_as] += tmp->trudoem
            sstoim[tmp->vr_as] += tmp->stoim
            old_perso := tmp->kod_vr
          case equalany(k,3,6,10,11,12)
            j := perenos(arr,tmp->u_shifr+" "+tmp->u_name,len_n)
            s := padr(arr[1],len_n)
            skol[1] += tmp->kol
            strud[1] += tmp->trudoem
            sstoim[1] += tmp->stoim
            if k == 10
              pkol += tmp->kol
              ptrud += tmp->trudoem
              pstoim += tmp->stoim
              old_slugba := tmp->fio ; old_shifr := tmp->kod_vr
            endif
          case k == 5
            if serv_arr != NIL .and. old_perso != tmp->kod_vr
              if old_perso > 0
                add_string(replicate("─",sh))
                fl := .f.
                if !emptyall(skol[1],strud[1],sstoim[1])
                  fl := .t.
                  s := padl("И Т О Г О :  ",len_n-4)
                  if psz == 1 ; s += "врач"
                  else        ; s += space(4)
                  endif
                  add_string(s+;
                             str(skol[1],7,0)+;
                             if(mem_trudoem==2,put_val_0(strud[1],9,1),"")+;
                             put_kopE(sstoim[1],15))
                  ssumv_ysl += skol[1]
                  ssumv_sum += sstoim[1]
                  if mem_trudoem==2
                    ssumv_uet += strud[1]
                  endif
                endif
                if !emptyall(skol[2],strud[2],sstoim[2])
                  s := if(fl, "", "И Т О Г О :  ")
                  add_string(padl(s,len_n-4)+"асс."+;
                             str(skol[2],7,0)+;
                             if(mem_trudoem==2,put_val_0(strud[2],9,1),"")+;
                             put_kopE(sstoim[2],15))
                  ssuma_ysl += skol[2]
                  ssuma_sum += sstoim[2]
                  if mem_trudoem==2
                    ssuma_uet += strud[2]
                  endif
                endif
                afill(skol,0) ; afill(strud,0) ; afill(sstoim,0)
              endif
              add_string("")
             // if mem_tabnom == 1
             add_string(space(5)+put_tab_nom(tmp->tab_nom,tmp->svod_nom)+". "+upper(rtrim(tmp->fio)))
             // else
             //   tabn->(dbseek(str(tmp->kod_vr,4)))
             //   add_string(space(5)+put_tab_nom(tabn->tab_nom,tabn->svod_nom)+;
             //              ". "+upper(rtrim(tmp->fio)))
             // endif
            endif
            j := perenos(arr,tmp->u_shifr+" "+tmp->u_name,len_n-6)
            s := padr(arr[1],len_n-4)+;
                 if(psz==1,if(tmp->vr_as==1,"врач","асс."),space(4))
            skol[tmp->vr_as] += tmp->kol
            strud[tmp->vr_as] += tmp->trudoem
            sstoim[tmp->vr_as] += tmp->stoim
            old_perso := tmp->kod_vr
        endcase
        add_string(s+;
                   str(tmp->kol,7,0)+;
                   if(mem_trudoem==2,put_val_0(tmp->trudoem,9,1),"")+;
                   put_kopE(tmp->stoim,15))
        if (equalany(k,3,5,6,10,11,12)) .and. j > 1
          for i := 2 to j
            add_string(space(11)+arr[i])
          next
        endif
      endif
      select TMP
      skip
    enddo
    if equalany(k,0,10)
      add_string(space(4)+replicate(".",sh-4))
      add_string(padr(space(4)+old_slugba,len_n)+;
                 str(pkol,7,0)+;
                 if(mem_trudoem==2,put_val_0(ptrud,9,1),"")+;
                 put_kopE(pstoim,15))
      add_string("")
    endif
    if k == 4
      add_string(space(4)+replicate(".",sh-4))
      add_string(padr(space(4)+old_fio,len_n-4)+;
                 if(psz==1,if(old_vr_as==1,"врач","асс."),space(4))+;
                 str(pkol,7,0)+;
                 if(mem_trudoem==2,put_val_0(ptrud,9,1),"")+;
                 put_kopE(pstoim,15))
      add_string("")
    endif
    add_string(replicate("─",sh))
    fl := .f.
    if !emptyall(skol[1],strud[1],sstoim[1])
      fl := .t.
      s := padl("И Т О Г О :  ",len_n-4)
      if equalany(k,2,4,5,7) .and. psz == 1
        s += "врач"
      else
        s += space(4)
      endif
      add_string(s+;
                 str(skol[1],7,0)+;
                 if(mem_trudoem==2,put_val_0(strud[1],9,1),"")+;
                 put_kopE(sstoim[1],15))
    endif
    if (equalany(k,2,4,5,7)) .and. !emptyall(skol[2],strud[2],sstoim[2])
      s := if(fl, "", "И Т О Г О :  ")
      s := padl(s,len_n-4)+"асс."
      add_string(s+;
                 str(skol[2],7,0)+;
                 if(mem_trudoem==2,put_val_0(strud[2],9,1),"")+;
                 put_kopE(sstoim[2],15))
    endif
    if k == 5
      if !emptyall(ssumv_ysl,ssumv_uet,ssumv_sum)
        add_string(replicate("─",sh))
        fl := .t.
        s := padl("В С Е Г О :  ",len_n-4)
        if psz == 1 ; s += "врач"
        else        ; s += space(4)
        endif
        add_string(s+;
                   str(ssumv_ysl,7,0)+;
                   if(mem_trudoem==2,put_val_0(ssumv_uet,9,1),"")+;
                   put_kopE(ssumv_sum,15))
      endif
      if !emptyall(ssuma_ysl,ssuma_uet,ssuma_sum)
        s := if(fl, "", "В С Е Г О :  ")
        add_string(padl(s,len_n-4)+"асс."+;
                   str(ssuma_ysl,7,0)+;
                   if(mem_trudoem==2,put_val_0(ssuma_uet,9,1),"")+;
                   put_kopE(ssuma_sum,15))
      endif
    endif
  endif
  if psz == 2 .and. is_oplata == 7 .and. is_1_usluga
    file_tmp7(arr_usl[1],sh,HH,2)
  endif
  fclose(fp)
  close databases
  viewtext("ob_stat"+stxt,,,,(sh>80),,,regim)
endif
return NIL

*

*****
Static Function Pob3_statist(k, arr_otd, serv_arr, mkod_perso)
Local i, mtrud := {0,0,0}, koef_z := {1,1,1}, k1 := 2, s1 := "2"
if ascan(krvz,human->tip_usl) == 0
  return NIL
endif
if arr_dms != NIL .and. ascan(arr_dms,human->pr_smo) == 0
  return NIL
endif
if hu->u_kod > 0 .and. (hu->kol > 0 .or. hu->stoim > 0) .and. ;
                          (i := ascan(arr_otd, {|x| hu->otd==x[1]})) > 0
  if mem_trudoem == 2
    kart->(dbGoto(human->kod_k))
    mtrud := _f_trud(hu->kol,kart->vzros_reb,hu->kod_vr,hu->kod_as)
  endif
  if psz == 2 .and. eq_any(is_oplata,5,6,7)
    koef_z := ret_p3_z(hu->u_kod,hu->kod_vr,hu->kod_as)
    if is_oplata == 7 .and. is_1_usluga
      put_tmp7(hu->kol,hu->kod_vr,hu->kod_as,mtrud,koef_z,iif(human->tip_usl==PU_D_SMO,3,2))
    endif
    k1 := 1 ; s1 := "1"
  endif
  select TMP
  do case
    case k == 0
      select USL
      goto (hu->u_kod)
      if !usl->(eof()) .and. usl->slugba >= 0
        select TMP
        find (str(usl->slugba,4)+str(hu->otd,3))
        if !found()
          append blank
          tmp->otd := arr_otd[i,1]
          tmp->u_name := arr_otd[i,2]
          tmp->kod_vr := usl->slugba
        endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,1)
        tmp->trudoem += mtrud[1]
      endif
    case k == 1
      find (str(hu->otd,3))
      if !found()
        append blank
        tmp->otd := arr_otd[i,1]
        tmp->fio := arr_otd[i,2]
      endif
      tmp->kol += hu->kol
      tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,1)
      tmp->trudoem += mtrud[1]
    case equalany(k,2,7)
      if hu->kod_vr > 0
        find ("1"+str(hu->kod_vr,4))
        if !found()
          append blank
          tmp->vr_as := 1
          tmp->kod_vr := hu->kod_vr
        endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,2)
        tmp->trudoem += mtrud[2]
      endif
      if hu->kod_as > 0
        find (s1+str(hu->kod_as,4))
        if !found()
          append blank
          tmp->vr_as := k1
          tmp->kod_vr := hu->kod_as
        endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,3)
        tmp->trudoem += mtrud[3]
      endif
    case equalany(k,3,6)
      find (str(hu->u_kod,4))
      if !found()
        append blank
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += hu->kol
      tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,1)
      tmp->trudoem += mtrud[1]
    case k == 4
      if hu->kod_vr > 0
        find ("1"+str(hu->kod_vr,4)+str(hu->u_kod,4))
        if !found()
          append blank
          tmp->vr_as := 1
          tmp->kod_vr := hu->kod_vr
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,2)
        tmp->trudoem += mtrud[2]
      endif
      if hu->kod_as > 0
        find (s1+str(hu->kod_as,4)+str(hu->u_kod,4))
        if !found()
          append blank
          tmp->vr_as := k1
          tmp->kod_vr := hu->kod_as
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,3)
        tmp->trudoem += mtrud[3]
      endif
    case k == 5
      if hu->kod_vr == mkod_perso
        find ("1"+str(mkod_perso,4)+str(hu->u_kod,4))
        if !found()
          append blank
          tmp->vr_as := 1
          tmp->kod_vr := mkod_perso
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,2)
        tmp->trudoem += mtrud[2]
      endif
      if hu->kod_as == mkod_perso
        find (s1+str(mkod_perso,4)+str(hu->u_kod,4))
        if !found()
          append blank
          tmp->vr_as := k1
          tmp->kod_vr := mkod_perso
          tmp->u_kod := hu->u_kod
        endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,3)
        tmp->trudoem += mtrud[3]
      endif
    case k == 10  // службы + услуги
      select USL
      goto (hu->u_kod)
      if !eof() .and. usl->slugba >= 0
        select TMP
        find (str(hu->u_kod,4))
        if !found()
          append blank
          tmp->kod_vr := usl->slugba
          tmp->u_kod := usl->kod
        endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,1)
        tmp->trudoem += mtrud[1]
      endif
    case k == 11  // служба + услуги
      select USL
      goto (hu->u_kod)
      if !eof() .and. usl->slugba == serv_arr[1]
        select TMP
        find (str(hu->u_kod,4))
        if !found()
          append blank
          tmp->u_kod := usl->kod
        endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,1)
        tmp->trudoem += mtrud[1]
      endif
    case k == 12  // все услуги
      select USL
      goto (hu->u_kod)
      if !eof()
        select TMP
        find (str(hu->u_kod,4))
        if !found()
          append blank
          tmp->u_kod := usl->kod
        endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z(hu->stoim,hu->kol,koef_z,1)
        tmp->trudoem += mtrud[1]
      endif
  endcase
endif
return NIL

*

*****
Static Function Pob4_statist(k, arr_otd, i, mkol, mstoim, serv_arr, mkod_perso)
Local mtrud := {0,0,0}, koef_z := {1,1,1}, k1 := 2, s1 := "2"
if ascan(krvz,human->tip_usl) == 0
  return NIL
endif
if arr_dms != NIL .and. ascan(arr_dms,human->pr_smo) == 0
  return NIL
endif
if mem_trudoem == 2
  kart->(dbGoto(human->kod_k))
  mtrud := _f_trud(mkol,kart->vzros_reb,hu->kod_vr,hu->kod_as)
endif
if psz == 2 .and. eq_any(is_oplata,5,6,7)
  koef_z := ret_p3_z(hu->u_kod,hu->kod_vr,hu->kod_as)
  if is_oplata == 7 .and. is_1_usluga
    put_tmp7(mkol,hu->kod_vr,hu->kod_as,mtrud,koef_z,iif(human->tip_usl==PU_D_SMO,3,2))
  endif
  k1 := 1 ; s1 := "1"
endif
select TMP
do case
  case k == 0
    select USL
    goto (hu->u_kod)
    if !eof() .and. usl->slugba >= 0
      select TMP
      find (str(usl->slugba,4)+str(hu->otd,3))
      if !found()
        append blank
        tmp->otd := arr_otd[i,1]
        tmp->u_name := arr_otd[i,2]
        tmp->kod_vr := usl->slugba
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,1)
      tmp->trudoem += mtrud[1]
    endif
  case k == 1
    find (str(hu->otd,3))
    if !found()
      append blank
      tmp->otd := arr_otd[i,1]
      tmp->fio := arr_otd[i,2]
    endif
    tmp->kol += mkol
    tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,1)
    tmp->trudoem += mtrud[1]
  case equalany(k,2,7)
    if hu->kod_vr > 0
      find ("1"+str(hu->kod_vr,4))
      if !found()
        append blank
        tmp->vr_as := 1
        tmp->kod_vr := hu->kod_vr
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,2)
      tmp->trudoem += mtrud[2]
    endif
    if hu->kod_as > 0
      find (s1+str(hu->kod_as,4))
      if !found()
        append blank
        tmp->vr_as := k1
        tmp->kod_vr := hu->kod_as
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,3)
      tmp->trudoem += mtrud[3]
    endif
  case equalany(k,3,6)
    find (str(hu->u_kod,4))
    if !found()
      append blank
      tmp->u_kod := hu->u_kod
    endif
    tmp->kol += mkol
    tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,1)
    tmp->trudoem += mtrud[1]
  case k == 4
    if hu->kod_vr > 0
      find ("1"+str(hu->kod_vr,4)+str(hu->u_kod,4))
      if !found()
        append blank
        tmp->vr_as := 1
        tmp->kod_vr := hu->kod_vr
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,2)
      tmp->trudoem += mtrud[2]
    endif
    if hu->kod_as > 0
      find (s1+str(hu->kod_as,4)+str(hu->u_kod,4))
      if !found()
        append blank
        tmp->vr_as := k1
        tmp->kod_vr := hu->kod_as
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,3)
      tmp->trudoem += mtrud[3]
    endif
  case k == 5
    if hu->kod_vr == mkod_perso
      find ("1"+str(mkod_perso,4)+str(hu->u_kod,4))
      if !found()
        append blank
        tmp->vr_as := 1
        tmp->kod_vr := mkod_perso
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,2)
      tmp->trudoem += mtrud[2]
    endif
    if hu->kod_as == mkod_perso
      find (s1+str(mkod_perso,4)+str(hu->u_kod,4))
      if !found()
        append blank
        tmp->vr_as := k1
        tmp->kod_vr := mkod_perso
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,3)
      tmp->trudoem += mtrud[3]
    endif
  case k == 10  // службы + услуги
    select USL
    goto (hu->u_kod)
    if !eof() .and. usl->slugba >= 0
      select TMP
      find (str(hu->u_kod,4))
      if !found()
        append blank
        tmp->kod_vr := usl->slugba
        tmp->u_kod := usl->kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,1)
      tmp->trudoem += mtrud[1]
    endif
  case k == 11  // служба + услуги
    select USL
    goto (hu->u_kod)
    if !eof() .and. usl->slugba == serv_arr[1]
      select TMP
      find (str(hu->u_kod,4))
      if !found()
        append blank
        tmp->u_kod := usl->kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,1)
      tmp->trudoem += mtrud[1]
    endif
  case k == 12  // все услуги
    select USL
    goto (hu->u_kod)
    if !eof()
      select TMP
      find (str(hu->u_kod,4))
      if !found()
        append blank
        tmp->u_kod := usl->kod
      endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z(mstoim,mkol,koef_z,1)
      tmp->trudoem += mtrud[1]
    endif
endcase
return NIL

*

*****
Static Function Pob5_statist(k, arr_otd, serv_arr)
if arr_otd != NIL .and. ascan(arr_otd, {|x| hu->otd==x[1]}) == 0
  return NIL
endif
if ascan(krvz,human->tip_usl) == 0
  return NIL
endif
if arr_dms != NIL .and. ascan(arr_dms,human->pr_smo) == 0
  return NIL
endif
select TMP
if equalany(k,13,14)
  find (str(hu->u_kod,4)+str(human->(recno()),7))
else
  find (str(human->(recno()),7))
endif
if !found()
  append blank
  if equalany(k,13,14)
    tmp->u_kod := hu->u_kod
  endif
  tmp->kod := human->(recno())
  kart->(dbGoto(human->kod_k))
  tmp->fio := fam_i_o(kart->fio)
  tmp->k_data := human->k_data
endif
tmp->kol += hu->kol
tmp->stoim += hu->stoim
return NIL

*

*****
Function st_plat_fio(reg)
// reg = 1 - Список больных с суммами лечения в каждом из отделений
// reg = 2 - Список больных с разбивкой сумм лечения по каждому врачу (м/сестре, санитарке)
Static svr_as := 1, mas_pmt := {"~Врачи","~Ассистенты","~Медсестры","~Санитарки"}
Local vr_as, adbf, i, j, arr[2], begin_date, end_date, ;
      fl_exit := .f., sh, HH := 57, reg_print, s, xx, n, nvr,;
      arr_otd := {}, n_file := "plat_fio"+stxt, buf := save_row(maxrow())
Private krvz, arr_dms, d_file := "PLAT_FIO"+sdbf
if !del_dbf_file(d_file)
  return NIL
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if (arr := year_month()) == NIL
  return NIL
endif
begin_date := arr[7]
end_date := arr[8]
if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
if reg == 2
  if (vr_as := popup_prompt(T_ROW,T_COL-5,svr_as,mas_pmt)) == 0
    return NIL
  endif
  svr_as := vr_as
endif
mywait()
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
go top
do while !eof()
  if f_is_uch(st_a_uch,otd->kod_lpu)
    uch->(dbGoto(otd->kod_lpu))
    aadd(arr_otd,{otd->(recno()),otd->name,otd->kod_lpu,uch->name})
  endif
  skip
enddo
close databases
adbf := {{"kod",  "N", 7,0},;  // код л/у
         {"kod_k","N", 7,0},;  // код по картотеке
         {"kod_p","N", 4,0},;  // код персонала
         {"otd",  "N", 3,0},;  // код отделения
         {"summa","N",12,2}}   // общая сумма лечения по данному отделению
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
index on str(kod_k,7)+str(kod,7)+str(otd,3)+str(kod_p,4) to (cur_dir+"tmp")
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
R_Use(dir_server+"hum_p",,"HUMAN")
if pi1 == 3  // по дате закрытия листа учета
  set index to (dir_server+"hum_pc")
  for xx := 0 to 2
    if ascan(krvz,xx) > 0
      select HUMAN
      dbseek(str(xx,1)+"1"+dtos(arr[5]),.t.)
      do while human->tip_usl==xx .and. human->date_close <= arr[6] .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if iif(arr_dms==NIL, .t., ascan(arr_dms,human->pr_smo) > 0)
          select HU
          find (str(human->(recno()),7))
          do while hu->kod == human->(recno())
            if ascan(arr_otd, {|x| hu->otd==x[1]}) > 0
              f1_plat_fio(reg,vr_as)
            endif
            select HU
            skip
          enddo
        endif
        select HUMAN
        skip
      enddo
    endif
    if fl_exit ; exit ; endif
  next
else  // только по дате окончания лечения
  set index to (dir_server+"hum_pd")
  dbseek(dtos(arr[5]),.t.)
  do while human->k_data <= arr[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if ascan(krvz,human->tip_usl) > 0 .and. ;
              iif(arr_dms==NIL, .t., ascan(arr_dms,human->pr_smo) > 0)
      select HU
      find (str(human->(recno()),7))
      do while hu->kod == human->(recno())
        if ascan(arr_otd, {|x| hu->otd==x[1]}) > 0
          f1_plat_fio(reg,vr_as)
        endif
        select HU
        skip
      enddo
    endif
    select HUMAN
    skip
  enddo
endif
j := tmp->(lastrec())
close databases
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  n := 30
  arr_title := {replicate("─",n),;
                space(n),;
                padc("Ф.И.О. больного",n),;
                replicate("─",n)}
  adbf := {{"fio","C",50,0}}
  if reg == 1
    arr_title[1] += "┬──────────"
    arr_title[2] += "│ Окончание"
    arr_title[3] += "│  лечения "
    arr_title[4] += "┴──────────"
    aadd(adbf,{"k_data","C",10,0})
  endif
  if pi1 == 3  // по дате закрытия листа учета
    arr_title[1] += "┬──────────"
    arr_title[2] += "│   Дата   "
    arr_title[3] += "│  оплаты  "
    arr_title[4] += "┴──────────"
    aadd(adbf,{"date_close","C",10,0})
  endif
  if len(st_a_uch) > 1
    arr_title[1] += "┬──────────"
    arr_title[2] += "│          "
    arr_title[3] += "│Учреждение"
    arr_title[4] += "┴──────────"
    aadd(adbf,{"uch","C",30,0})
  endif
  arr_title[1] += "┬─────"
  arr_title[2] += "│Отде-"
  arr_title[3] += "│ление"
  arr_title[4] += "┴─────"
  aadd(adbf,{"otd","C",50,0})
  nvr := 20
  if reg == 2
    arr_title[1] += "┬"+replicate("─",nvr)
    arr_title[2] += "│"+space(nvr)
    arr_title[3] += "│"+padc({"Врачи","Ассистенты","Медсестры","Санитарки"}[vr_as],nvr)
    arr_title[4] += "┴"+replicate("─",nvr)
    aadd(adbf,{"tab_nom","N",5,0})
    aadd(adbf,{"personal","C",50,0})
  endif
  arr_title[1] += "┬───────────"
  arr_title[2] += "│ Стоимость "
  arr_title[3] += "│   услуг   "
  arr_title[4] += "┴───────────"
  aadd(adbf,{"summa","N",12,2})
  dbcreate(d_file,adbf)
  use (d_file) new alias DD
  reg_print :=  f_reg_print(arr_title,@sh)
  R_Use(dir_server+"mo_uch",,"UCH")
  R_Use(dir_server+"mo_otd",,"OTD")
  set relation to kod_lpu into UCH //, to recno() into OTD
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"hum_p",,"HUMAN")
  use (cur_dir+"tmp") new
  set relation to otd into OTD, to kod_k into KART, to kod into HUMAN
  if reg == 2
    if vr_as < 3
      R_Use(dir_server+"mo_pers",,"perso")
      select TMP
      set relation to kod_p into perso additive
    else
      R_Use(dir_server+"plat_ms",,"perso")
      select TMP
      set relation to kod_p into perso additive
    endif
  endif
  if reg == 1
    index on left(upper(kart->fio),20)+str(kod_k,7)+dtos(human->k_data)+;
             upper(uch->name)+upper(otd->short_name) to (cur_dir+"tmp")
  else
    index on left(upper(kart->fio),20)+str(kod_k,7)+upper(uch->name)+;
             upper(otd->short_name)+upper(perso->fio) to (cur_dir+"tmp")
  endif
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string("ПЛАТНЫЕ УСЛУГИ")
  add_string(center("Статистика по работе персонала",sh))
  titleN_uch(st_a_uch,sh)
  tit_tip_usl(krvz,arr_dms,sh)
  add_string(center(arr[4],sh))
  add_string("")
  do case
    case pi1 == 1
      s := "[ по дате лечения ]"
    case pi1 == 2
      s := "[ по дате окончания лечения ]"
    case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
  endcase
  add_string(center(s,sh))
  add_string("")
  old_kart := -999 ; old_lu := 0
  select TMP
  go top
  aeval(arr_title, {|x| add_string(x) } )
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    select DD
    append blank
    dd->fio := kart->fio
    if old_kart==tmp->kod_k .and. old_lu==tmp->kod
      s := space(n)
    else
      s := padr(kart->fio,n)
    endif
    old_kart:=tmp->kod_k
    old_lu:=tmp->kod
    if reg == 1
      s += " "+full_date(human->k_data)
      dd->k_data := full_date(human->k_data)
    endif
    if pi1 == 3  // по дате закрытия листа учета
      s += " "
      if human->date_close > human->k_data
        s += full_date(human->date_close)
      else
        s += padc("аванс",10)
      endif
      dd->date_close := full_date(human->date_close)
    endif
    if len(st_a_uch) > 1
      s += " "+padr(uch->name,10)
      dd->uch := uch->name
    endif
    s += " "+padr(otd->short_name,5)
    dd->otd := otd->name
    if reg == 2
      s1 := "["
      if vr_as < 3
        dd->tab_nom := perso->tab_nom
        s1 += lstr(perso->tab_nom)
      else
        dd->tab_nom := perso->tab_nom
        s1 += lstr(perso->tab_nom)
      endif
      s1 += "] "+fam_i_o(perso->fio)
      s += " "+padr(s1,nvr)
      dd->personal := perso->fio
    endif
    s += put_kop(tmp->summa,12)
    dd->summa := tmp->summa
    if dd->(lastrec()) % 5000 == 0
      commit
    endif
    add_string(s)
    select TMP
    skip
  enddo
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,reg_print)
  rest_box(buf)
  n_message({"Создан файл:  "+d_file},,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
endif
rest_box(buf)
return NIL

*****
Function f1_plat_fio(reg,vr_as)
Local i, k, arr := {}, koef_z := {1,1,1}, koef_ms := 1, koef_sn := 1
if reg == 1
  select TMP
  find (str(human->kod_k,7)+str(human->(recno()),7)+str(hu->otd,3))
  if !found()
    append blank
    tmp->kod   := human->(recno())
    tmp->kod_k := human->kod_k
    tmp->otd   := hu->otd
  endif
  tmp->summa += hu->stoim
else
  do case
    case vr_as == 1  // врачи
      aadd(arr,{hu->kod_vr,koef_z[2]})
    case vr_as == 2  // ассистенты
      aadd(arr,{hu->kod_as,koef_z[3]})
    case vr_as == 3  // медсестры
      if hu->med1 > 0
        aadd(arr,{hu->med1,koef_ms})
      endif
      if hu->med2 > 0
        aadd(arr,{hu->med2,koef_ms})
      endif
      if hu->med3 > 0
        aadd(arr,{hu->med3,koef_ms})
      endif
      if len(arr) == 0
        aadd(arr,{0,koef_ms})
      endif
    case vr_as == 4  // санитарки
      if hu->san1 > 0
        aadd(arr,{hu->san1,koef_sn})
      endif
      if hu->san2 > 0
        aadd(arr,{hu->san2,koef_sn})
      endif
      if hu->san3 > 0
        aadd(arr,{hu->san3,koef_sn})
      endif
      if len(arr) == 0
        aadd(arr,{0,koef_sn})
      endif
  endcase
  k := len(arr)
  for i := 1 to k
    select TMP
    find (str(human->kod_k,7)+str(human->(recno()),7)+str(hu->otd,3)+str(arr[i,1],4))
    if !found()
      append blank
      tmp->kod   := human->(recno())
      tmp->kod_k := human->kod_k
      tmp->otd   := hu->otd
      tmp->kod_p := arr[i,1]
    endif
    tmp->summa += hu->stoim/k
  next
endif
return NIL

*

*****
Function st_plat_ms(reg)
Local i, j, arr[2], begin_date, end_date, n_file := "plat_ms"+stxt,;
      fl_exit := .f., sh, HH := 57, reg_print := 1, s, arr_dms,;
      ss, ss1, ss2, ss3, arr_title, adbf, krvz, xx
if (arr := year_month()) == NIL
  return NIL
endif
begin_date := arr[7]
end_date := arr[8]
if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
if psz == 1
  /*Private usl_dop := rest_arr(dir_server+"usl_pl_d"+smem),;
          usl_mat := rest_arr(dir_server+"usl_pl_m"+smem)*/
endif
adbf := {;
     {"KOD",        "N",      4,      0},;  // код персонала
     {"KOL1"   ,    "N",      6,      0},;  // платные
     {"SUM1"   ,    "N",     14,      2},;  // платные
     {"KOL2"   ,    "N",      6,      0},;  // доплаты за услуги
     {"SUM2"   ,    "N",     14,      2},;  // доплаты за услуги
     {"KOL3"   ,    "N",      6,      0},;  // материалы
     {"SUM3"   ,    "N",     14,      2},;  // материалы
     {"SUMMA",      "N",     18,      2};   // ст-ть услуг (зарплата)
    }
dbcreate(cur_dir+"tmp", adbf)
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
use (cur_dir+"tmp")
index on str(kod,4) to (cur_dir+"tmp")
// по дате окончания лечения
G_Use(dir_server+"uslugi",dir_server+"uslugi","USL")
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
G_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
if pi1 == 3  // по дате закрытия листа учета
  set index to (dir_server+"hum_pc")
  for xx := 0 to 2
    if ascan(krvz,xx) > 0
      select HUMAN
      dbseek(str(xx,1)+"1"+dtos(arr[5]),.t.)
      do while human->tip_usl==xx .and. human->date_close <= arr[6] .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if iif(arr_dms == NIL, .t., ascan(arr_dms,human->pr_smo) > 0)
          select HU
          find (str(human->(recno()),7))
          do while hu->kod == human->(recno())
            f1_plat_ms(reg)
            select HU
            skip
          enddo
        endif
        select HUMAN
        skip
      enddo
    endif
  next
else
  dbseek(dtos(arr[5]),.t.)
  do while human->k_data <= arr[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if ascan(krvz,human->tip_usl) > 0 .and. ;
                 iif(arr_dms == NIL, .t., ascan(arr_dms,human->pr_smo) > 0)
      select HU
      find (str(human->(recno()),7))
      do while hu->kod == human->(recno())
        f1_plat_ms(reg)
        select HU
        skip
      enddo
    endif
    select HUMAN
    skip
  enddo
endif
j := tmp->(lastrec())
close databases
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  if psz == 1
    reg_print := 2
    arr_title := {;
    "──────────────────────────┬─────────────────┬─────────────────┬─────────────────",;
    "                          │  Платные услуги │Доплаты за услуги│    Материалы    ",;
    "                          ├──────┬──────────┼──────┬──────────┼──────┬──────────",;
    "          Ф.И.О.          │Кол-во│ Стоимость│Кол-во│ Стоимость│Кол-во│ Стоимость",;
    "                          │ услуг│   услуг  │ услуг│   услуг  │ услуг│   услуг  ",;
    "──────────────────────────┴──────┴──────────┴──────┴──────────┴──────┴──────────"}
  else
    arr_title := {;
    "──────────────────────────────────────────────────┬──────────────",;
    "                                                  │  Заработная",;
    "                     Ф.И.О.                       │    плата",;
    "──────────────────────────────────────────────────┴──────────────"}
  endif
  sh := len(arr_title[1])
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string("ПЛАТНЫЕ УСЛУГИ")
  add_string(center("Статистика по работе персонала",sh))
  add_string(center(expand({"МЕДСЕСТРЫ","САНИТАРКИ"}[reg]),sh))
  tit_tip_usl(krvz,arr_dms,sh)
  add_string(center(arr[4],sh))
  add_string("")
  do case
    case pi1 == 1
      s := "[ по дате лечения ]"
    case pi1 == 2
      s := "[ по дате окончания лечения ]"
    case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
  endcase
  add_string(center(s,sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  G_Use(dir_server+"plat_ms",,"PMS")
  Store 0 to ss, ss1, ss2, ss3
  use (cur_dir+"tmp") new
  set relation to kod into PMS
  index on upper(pms->fio) to (cur_dir+"tmp")
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if psz == 1
      add_string(padr(str(pms->tab_nom,5)+" "+pms->fio,26)+;
                 put_val(tmp->kol1,7)+put_kopE(tmp->sum1,11)+;
                 put_val(tmp->kol2,7)+put_kopE(tmp->sum2,11)+;
                 put_val(tmp->kol3,7)+put_kopE(tmp->sum3,11))
      ss1 += tmp->sum1
      ss2 += tmp->sum2
      ss3 += tmp->sum3
    else
      add_string(padr(str(pms->tab_nom,5)+"  "+pms->fio,50)+put_kopE(tmp->summa,15))
      ss += tmp->summa
    endif
    skip
  enddo
  add_string(replicate("─",sh))
  if psz == 1
    add_string(put_kopE(ss1,sh-36)+put_kopE(ss2,18)+put_kopE(ss3,18))
  else
    add_string(put_kopE(ss,sh))
  endif
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
return NIL

*****
Function f1_plat_ms(reg)
Local pole_kol, pole_sum, s1, koef := 0
if psz == 1
  s1 := "1"
  /*if is_up_usl(usl_dop,hu->u_kod)
    s1 := "2"
  elseif is_up_usl(usl_mat,hu->u_kod)
    s1 := "3"
  endif*/
  pole_kol := "tmp->kol"+s1
  pole_sum := "tmp->sum"+s1
endif
if reg == 1
  if hu->med1 > 0
    ++koef
  endif
  if hu->med2 > 0
    ++koef
  endif
  if hu->med3 > 0
    ++koef
  endif
  if hu->med1 > 0
    select TMP
    find (str(hu->med1,4))
    if !found()
      append blank
      tmp->kod := hu->med1
    endif
    if psz == 1
      &pole_kol := &pole_kol + hu->kol
      &pole_sum := &pole_sum + hu->stoim / koef
    else
      tmp->summa += round_5(hu->stoim * mem_pl_ms / 100 / koef, 2)
    endif
  endif
  if hu->med2 > 0
    select TMP
    find (str(hu->med2,4))
    if !found()
      append blank
      tmp->kod := hu->med2
    endif
    if psz == 1
      &pole_kol := &pole_kol + hu->kol
      &pole_sum := &pole_sum + hu->stoim / koef
    else
      tmp->summa += round_5(hu->stoim * mem_pl_ms / 100 / koef, 2)
    endif
  endif
  if hu->med3 > 0
    select TMP
    find (str(hu->med3,4))
    if !found()
      append blank
      tmp->kod := hu->med3
    endif
    if psz == 1
      &pole_kol := &pole_kol + hu->kol
      &pole_sum := &pole_sum + hu->stoim / koef
    else
      tmp->summa += round_5(hu->stoim * mem_pl_ms / 100 / koef, 2)
    endif
  endif
else
  if hu->san1 > 0
    ++koef
  endif
  if hu->san2 > 0
    ++koef
  endif
  if hu->san3 > 0
    ++koef
  endif
  if hu->san1 > 0
    select TMP
    find (str(hu->san1,4))
    if !found()
      append blank
      tmp->kod := hu->san1
    endif
    if psz == 1
      &pole_kol := &pole_kol + hu->kol
      &pole_sum := &pole_sum + hu->stoim / koef
    else
      tmp->summa += round_5(hu->stoim * mem_pl_sn / 100 / koef, 2)
    endif
  endif
  if hu->san2 > 0
    select TMP
    find (str(hu->san2,4))
    if !found()
      append blank
      tmp->kod := hu->san2
    endif
    if psz == 1
      &pole_kol := &pole_kol + hu->kol
      &pole_sum := &pole_sum + hu->stoim / koef
    else
      tmp->summa += round_5(hu->stoim * mem_pl_sn / 100 / koef, 2)
    endif
  endif
  if hu->san3 > 0
    select TMP
    find (str(hu->san3,4))
    if !found()
      append blank
      tmp->kod := hu->san3
    endif
    if psz == 1
      &pole_kol := &pole_kol + hu->kol
      &pole_sum := &pole_sum + hu->stoim / koef
    else
      tmp->summa += round_5(hu->stoim * mem_pl_sn / 100 / koef, 2)
    endif
  endif
endif
return NIL

*

***** 22.03.17
Function pl_mnog_poisk()
Static mm_g_selo :=  {{"город",1},{"село",2}}
Local mm_tmp := {}, k
Local buf := savescreen(), tmp_color := setcolor(cDataCGet),;
      mm_mest := {{"Волгоград или область",1},{"иногородние",2}},;
      tmp_help := 0, hGauge, name_file := "pl_mnog"+stxt,;
      sh := 80, HH := 77, r1 := 2, a_diagnoz[3], a_uslugi[20],;
      k_usl, fl_stom := .f.,;
      mm_da_net := {{"нет",1},{"да ",2}}, lvid_doc := 0,;
      menu_plat := {{"платные    ",PU_PLAT },;
                    {"добр/страх.",PU_D_SMO},;
                    {"взаимозачет",PU_PR_VZ}},;
      tmp_file := "tmp_mn_p"+sdbf
      // help_code
Private ssumma := 0
Private = 0

Private arr_doc := {"Дата рожд.",;
                    "Адрес",;
                    "Дата.леч.",;
                    "Диагноз",;
                    "Услуги",;
                    "Услуги+врачи"}
if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) == NIL
  return NIL
endif
Private pr_arr := {}, pr_arr_otd := {}, is_talon := ret_is_talon()
//
G_Use(dir_server+"mo_otd",,"OTD")
dbeval({|| aadd(pr_arr,{otd->(recno()),otd->name,otd->kod_lpu,""}) },;
       {|| f_is_uch(st_a_uch,otd->kod_lpu) .and. between_date(otd->dbeginp,otd->dendp,sys_date)} )
G_Use(dir_server+"mo_uch",,"UCH")
aeval(pr_arr, {|x,i| dbGoto(x[3]), pr_arr[i,4] := uch->name } )
//
asort(pr_arr,,,{|x,y| iif(x[3] == y[3], upper(x[2]) < upper(y[2]), ;
                                        upper(x[4]) < upper(y[4])) } )
aeval(pr_arr, {|x| aadd(pr_arr_otd,x[2]+" "+x[4]) } )
close databases
//
lvid_doc := setbit(lvid_doc,1)
lvid_doc := setbit(lvid_doc,3)
//
Private pdate_lech, pdate_schet, mstr_crb := 0, mslugba
//
dbcreate(cur_dir+"tmp", {;
   {"U_KOD"  ,    "N",      4,      0},;  // код услуги
   {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
   {"U_NAME",     "C",     65,      0} ;  // наименование услуги
  })
use (cur_dir+"tmp")
index on str(u_kod,4) to (cur_dir+"tmpk")
index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
tmp->(dbCloseArea())
aadd(mm_tmp, {"date_lech","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(pdate_lech:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              'Дата окончания лечения'})
aadd(mm_tmp, {"date_schet","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(pdate_schet:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              'Дата закрытия л/учета'})
aadd(mm_tmp, {"uch_doc","C",10,0,"@!",;
              nil,;
              space(10),nil,;
              "Вид и номер учетного документа (шаблон)"})
Private arr_uchast := {}
if is_uchastok > 0
  aadd(mm_tmp, {"bukva","C",1,0,"@!",;
                nil,;
                " ",nil,;
                "Буква (перед участком)"})
  aadd(mm_tmp, {"uchast","N",1,0,,;
                {|x|menu_reader(x,;
                      {{ |k,r,c| get_uchast(r+1,c) }},A__FUNCTION)},;
                0,{|| init_uchast(arr_uchast) },;
                "Участок (участки)"})
endif
aadd(mm_tmp, {"fio","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "ФИО (начальные буквы или шаблон)"})
aadd(mm_tmp, {"inostran","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|| space(10) },;
              "Документы иностранных граждан:"})
aadd(mm_tmp, {"gorod_selo","N",2,0,NIL,;
              {|x|menu_reader(x,mm_g_selo,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Житель:"})
aadd(mm_tmp, {"mi_git","N",2,0,NIL,;
              {|x|menu_reader(x,mm_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Место жительства:"})
aadd(mm_tmp, {"_okato","C",11,0,NIL,;
              {|x|menu_reader(x,;
                {{ |k,r,c| get_okato_ulica(k,r,c,{k,m_okato,}) }},A__FUNCTION)},;
              space(11),{|x| space(11)},;
              'Адрес регистрации (ОКАТО)'})
// 12.11.16
aadd(mm_tmp, {"adres","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "Улица (подстрока или шаблон)"})
aadd(mm_tmp, {"mr_dol","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "Место работы (подстрока или шаблон)"})
if is_talon
  aadd(mm_tmp, {"kategor","N",2,0,NIL,;
                {|x|menu_reader(x,mo_cut_menu(stm_kategor),A__MENUVERT)},;
                0,{|| space(10) },;
                "Код категории льготы"})
endif
aadd(mm_tmp, {"pol","C",1,0,"!",;
              nil,;
              " ",nil,;
              "Пол", {|| mpol $ " МЖ" } })
aadd(mm_tmp, {"vzros_reb","N",2,0,NIL,;
              {|x|menu_reader(x,menu_vzros,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Возрастная принадлежность"})
aadd(mm_tmp, {"god_r_min","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "Дата рождения (минимальная)"})
aadd(mm_tmp, {"god_r_max","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "Дата рождения (максимальная)"})
aadd(mm_tmp, {"rab_nerab","N",2,0,NIL,;
              {|x|menu_reader(x,menu_rab,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Работающий/неработающий"})
/*aadd(mm_tmp, {"mi_git","N",2,0,NIL,;
              {|x|menu_reader(x,menu_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "МЕСТО ЖИТЕЛЬСТВА: г/о/и",;
              {|g,o|valid_mest_inog(g,o,2)} })
aadd(mm_tmp, {"rajon_git","N",2,0,NIL,;
              {|x|menu_reader(x,{dir_server+"rajon",,;
                      {||FIELD->tip==m1mi_git}},A__POPUPMENU)},;
              0,{|| space(10) },;
              "   район",,;
              {|| equalany(m1mi_git,0,1) } })
aadd(mm_tmp, {"mest_inog","N",2,0,NIL,;
              {|x|menu_reader(x,menu_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Финансирование: г/о/и",;
              {|g,o|valid_mest_inog(g,o)} })
aadd(mm_tmp, {"rajon","N",2,0,NIL,;
              {|x|menu_reader(x,{dir_server+"rajon",,;
                      {||FIELD->tip==m1mest_inog}},A__POPUPMENU)},;
              0,{|| space(10) },;
              "   район",,;
              {|| equalany(m1mest_inog,0,1) } })
              */
aadd(mm_tmp, {"kod_diag","C",5,0,"@!",;
              nil,;
              space(5),nil,;
              "Шифр заболевания",;
              {|| val2_10diag() }})
if yes_h_otd == 1
  aadd(mm_tmp, {"otd","N",3,0,NIL,;
                {|x|menu_reader(x, ;
                  { { |k,r,c| get_otd(k,r+1,c) }},A__FUNCTION)},;
                0,{|| space(10) },;
                "Отделение, в котором выписан счет" })
endif
aadd(mm_tmp, {"tip_usl","N",2,0,NIL,;
              {|x|menu_reader(x,menu_plat,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Категория оплаты"})
aadd(mm_tmp, {"uslugi","N",4,0,NIL,;
              {|x|menu_reader(x, ;
               { { |k,r,c| ob2_v_usl(.t.,r+1) }},A__FUNCTION)},;
              0,{|| space(10) },;
              "Оказанные услуги" })
aadd(mm_tmp, {"otd_usl","N",3,0,NIL,;
              {|x|menu_reader(x, ;
                { { |k,r,c| get_otd(k,r+1,c) }},A__FUNCTION)},;
              0,{|| space(10) },;
              "Отделение, в котором оказана услуга" })
aadd(mm_tmp, {"slug_usl","N",3,0,NIL,;
              {|x|menu_reader(x, ;
                { { |k,r,c| get_slugba(k,r,c) }},A__FUNCTION)},;
              0,{|| space(10) },;
              "Служба, в которой оказана услуга" })
aadd(mm_tmp, {"vr1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Врач, оказавший услугу(и)",;
              {|g| st_v_vrach(g,"mvr") } })
aadd(mm_tmp, {"vr","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "  ФИО врача",,;
              {|| .f. } })
aadd(mm_tmp, {"isvr","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|| space(10) },;
              "Код врача проставлен?",,;
              {|| mvr1==0 } })
aadd(mm_tmp, {"as1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Ассистент, оказавший услугу(и)",;
              {|g| st_v_vrach(g,"mas") } })
aadd(mm_tmp, {"as","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "  ФИО асситента",,;
              {|| .f. } })
aadd(mm_tmp, {"isas","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|| space(10) },;
              "Код ассистента проставлен?",,;
              {|| mas1==0 } })
aadd(mm_tmp, {"vras1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Человек, оказавший услугу(и)",;
              {|g| st_v_vrach(g,"mvras") } })
aadd(mm_tmp, {"vras","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "                            ",,;
              {|| .f. } })
if is_oplata != 7
  aadd(mm_tmp, {"med1","N",5,0,NIL,;
                nil,;
                0,nil,;
                "Медсестра",;
                {|g| st_v_vrach(g,"mmed",1) } })
  aadd(mm_tmp, {"med","C",50,0,NIL,;
                nil,;
                space(50),nil,;
                "  ФИО медсестры",,;
                {|| .f. } })
  aadd(mm_tmp, {"san1","N",5,0,NIL,;
                nil,;
                0,nil,;
                "Санитарка",;
                {|g| st_v_vrach(g,"msan",2) } })
  aadd(mm_tmp, {"san","C",50,0,NIL,;
                nil,;
                space(50),nil,;
                "  ФИО санитарки",,;
                {|| .f. } })
endif
aadd(mm_tmp, {"summa_min","N",10,2,,;
              nil,;
              0,nil,;
              "Сумма лечения (минимальная)"})
aadd(mm_tmp, {"summa_max","N",10,2,,;
              nil,;
              0,nil,;
              "Сумма лечения (максимальная)"})
aadd(mm_tmp, {"vid_doc","N",5,0,NIL,;
              {|x|menu_reader(x,arr_doc,A__MENUBIT)},;
              lvid_doc,{|x|inieditspr(A__MENUBIT,arr_doc,x)},;
              "Вид документа",NIL})
delete file (tmp_file)
init_base(tmp_file,,mm_tmp,0)
//
R_Use(dir_server+"plat_ms",dir_server+"plat_ms","MS")
R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
k := f_edit_spr(A__APPEND,mm_tmp,"множественному запросу",;
                "g_use(cur_dir+'tmp_mn_p',,,.t.,.t.)",0,1,,,,,"pwrite_mn_p")
if k > 0
  mywait()
  use (tmp_file) new alias MN
  if is_talon .and. mn->kategor == 0
    is_talon := .f.
  endif
  R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
  select PERSO
  if mn->vr1 > 0
    find (str(mn->vr1,5))
    if found()
      mn->vr1 := perso->kod
    endif
  endif
  if mn->as1 > 0
    find (str(mn->as1,5))
    if found()
      mn->as1 := perso->kod
    endif
  endif
  if mn->vras1 > 0
    find (str(mn->vras1,5))
    if found()
      mn->vras1 := perso->kod
    endif
  endif
  if is_oplata != 7
    R_Use(dir_server+"plat_ms",dir_server+"plat_ms","MS")
    if mn->med1 > 0
      find ("1"+str(mn->med1,5))
      if found()
        mn->med1 := ms->(recno())
      endif
    endif
    if mn->san1 > 0
      find ("2"+str(mn->san1,5))
      if found()
        mn->san1 := ms->(recno())
      endif
    endif
    ms->(dbCloseArea())
  endif
  Private much_doc := "", mfio := "", madres := "", mmr_dol := ""
  if !empty(mn->uch_doc)
    much_doc := alltrim(mn->uch_doc)
    if !(right(much_doc,1) == "*")
      much_doc += "*"
    endif
  endif
  if !empty(mn->fio)
    mfio := alltrim(mn->fio)
    if !(right(mfio,1) == "*")
      mfio += "*"
    endif
  endif
  if !empty(mn->adres)
    madres := alltrim(mn->adres)
    if !(left(madres,1) == "*")
      madres := "*"+madres
    endif
    if !(right(madres,1) == "*")
      madres += "*"
    endif
  endif
  if !empty(mn->mr_dol)
    mmr_dol := alltrim(mn->mr_dol)
    if !(left(mmr_dol,1) == "*")
      mmr_dol := "*"+mmr_dol
    endif
    if !(right(mmr_dol,1) == "*")
      mmr_dol += "*"
    endif
  endif
  if mn->date_schet > 0
    p_regim := 2
  else
    p_regim := 1
  endif
  Private arr_usl := {}, fl_summa := .t.
  if mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. ;
     mn->vras1 > 0 .or. mn->slug_usl > 0 .or. mn->uslugi > 0
    fl_summa := .f.
  endif
  if fl_summa .and. is_oplata != 7
    if mn->med1 > 0 .or. mn->san1 > 0
      fl_summa := .f.
    endif
  endif
  if mn->uslugi > 0
    use (cur_dir+"tmp") index (cur_dir+"tmpn") new
    go top
    dbeval({|| aadd(arr_usl, {tmp->u_kod,tmp->u_shifr,tmp->u_name,0,0}) })
    tmp->(dbCloseArea())
  endif
  flag_hu := (mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. ;
              mn->vras1 > 0 .or. mn->slug_usl > 0 .or. mn->uslugi > 0)
  if !flag_hu .and. is_oplata != 7
    flag_hu := (mn->med1 > 0 .or. mn->san1 > 0)
  endif
  dbcreate(cur_dir+"tmp",{{"kod","N",7,0},;
                          {"stoim","N",10,2}})
  use (cur_dir+"tmp") new
  dbcreate(cur_dir+"tmp_k",{{"kod_k","N",7,0}})
  use (cur_dir+"tmp_k") new
  index on str(kod_k,7) to (cur_dir+"tmp_k")
  fl_exit := .f.
  Status_Key("^<Esc>^ - прервать поиск")
  G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
  if mn->slug_usl > 0
    G_Use(dir_server+"uslugi",,"USL")
    select HU
    set relation to u_kod into USL
  endif
  if is_talon
    AB_open()
  endif
  Private c_view := 0, c_found := 0
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_, recno() into KART2
  if p_regim == 1
    R_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
    set relation to kod_k into KART
    dbseek(dtos(pdate_lech[5]),.t.)
    do while human->k_data <= pdate_lech[6] .and. !eof()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if f_is_uch(st_a_uch,human->lpu)
        s1_mnog_poisk(@c_view,@c_found)
      endif
      select HUMAN
      skip
    enddo
  else  // по дате закрытия листа учета
    R_Use(dir_server+"hum_p",dir_server+"hum_pc","HUMAN")
    set relation to kod_k into KART
    for xx := 0 to 2
      if iif(mn->tip_usl >= 0, xx==mn->tip_usl, .t.)
        select HUMAN
        dbseek(str(xx,1)+"1"+dtos(pdate_schet[5]),.t.)
        do while human->tip_usl==xx .and. human->date_close <= pdate_schet[6] .and. !eof()
          if inkey() == K_ESC
            fl_exit := .t. ; exit
          endif
          if f_is_uch(st_a_uch,human->lpu)
            s1_mnog_poisk(@c_view,@c_found)
          endif
          select HUMAN
          skip
        enddo
      endif
      if fl_exit ; exit ; endif
    next
  endif
  j := tmp->(lastrec())
  close databases
  if j == 0
    if !fl_exit
      func_error(4,"Нет сведений!")
    endif
  else
    mywait()
    use (tmp_file) new alias MN
    s1 := if(fl_summa, "  Сумма  ", "Стоимость")
    s2 := if(fl_summa, " лечения ", "  услуг  ")
    arr_title := {;
     "────────────────────────────────────────┬─────────",;
     "             Ф.И.О. больного            │"+ s1     ,;
     "                                        │"+ s2     ,;
     "────────────────────────────────────────┴─────────"}
    if isbit(mn->vid_doc,1)
      arr_title[1] += "┬────────"
      arr_title[2] += "│  Дата  "
      arr_title[3] += "│рождения"
      arr_title[4] += "┴────────"
    endif
    if isbit(mn->vid_doc,2)
      arr_title[1] += "┬────────────────────────"
      arr_title[2] += "│         Адрес          "
      arr_title[3] += "│                        "
      arr_title[4] += "┴────────────────────────"
    endif
    if isbit(mn->vid_doc,3)
      arr_title[1] += "┬────────"
      arr_title[2] += "│Окончан."
      arr_title[3] += "│лечения "
      arr_title[4] += "┴────────"
    endif
    if isbit(mn->vid_doc,4)
      arr_title[1] += "┬─────"
      arr_title[2] += "│Диаг-"
      arr_title[3] += "│ноз  "
      arr_title[4] += "┴─────"
    endif
    if isbit(mn->vid_doc,5)
      arr_title[1] += "┬───────────────────────"
      arr_title[2] += "│                       "
      arr_title[3] += "│     Список услуг      "
      arr_title[4] += "┴───────────────────────"
    endif
    if isbit(mn->vid_doc,6)
      arr_title[1] += "┬────────────────────────────"
      arr_title[2] += "│                            "
      arr_title[3] += "│       Услуги + врачи       "
      arr_title[4] += "┴────────────────────────────"
    endif
    sh := len(arr_title[1])
    if sh <= 65
      sh := 65
      reg_print := 4
    elseif sh <= 84
      reg_print := 5
    elseif sh <= 120
      reg_print := 6
    elseif sh <= 160
      reg_print := 5
    else
      reg_print := 6
    endif
    R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"mo_pers",,"PERSO")
    R_Use(dir_server+"kartote2",,"KART2")
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"kartotek",,"KART")
    set relation to recno() into KART_, to recno() into KART2
    R_Use(dir_server+"hum_p",,"HUMAN")
    set relation to kod_k into KART
    use (cur_dir+"tmp_k") new
    use (cur_dir+"tmp") new
    set relation to kod into HUMAN
    index on upper(kart->fio)+dtos(human->k_data) to (cur_dir+"tmp")
    //
    fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center(expand("РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА"),sh))
    titleN_uch(st_a_uch,sh)
    add_string("")
    add_string(" == ПАРАМЕТРЫ ПОИСКА ==")
    if mn->date_lech > 0
      add_string("Дата окончания лечения: "+pdate_lech[4])
    endif
    if mn->date_schet > 0
      add_string("Дата закрытия л/учета: "+pdate_schet[4])
    endif
    if !empty(much_doc)
      add_string("Вид и номер учетного документа: "+much_doc)
    endif
    if is_uchastok > 0
      if !empty(mn->bukva)
        add_string("Буква: "+mn->bukva)
      endif
      if !empty(mn->uchast)
        add_string("Участок: "+init_uchast(arr_uchast))
      endif
    endif
    if !empty(mfio)
      add_string("ФИО: "+mfio)
    endif
    if mn->inostran > 0
      add_string("Документы иностранных граждан: "+;
                 inieditspr(A__MENUVERT, mm_da_net, mn->inostran))
    endif
    if mn->gorod_selo > 0
      add_string("Житель: "+;
                 inieditspr(A__MENUVERT, mm_g_selo, mn->gorod_selo))
    endif
    if mn->mi_git > 0
      add_string("Место жительства: "+;
                 inieditspr(A__MENUVERT, mm_mest, mn->mi_git))
    endif
    if !empty(mn->_okato)
      add_string("Адрес регистрации (ОКАТО): "+ret_okato_ulica('',mn->_okato))
    endif
    if !empty(madres)
      add_string("Адрес: "+madres)
    endif
    if !empty(mmr_dol)
      add_string("Место работы: "+mmr_dol)
    endif
    if is_talon .and. mn->kategor > 0
      add_string("Код категории льготы: "+;
                 inieditspr(A__MENUVERT, stm_kategor, mn->kategor))
    endif
    if !empty(mn->pol)
      add_string("Пол: "+mn->pol)
    endif
    if mn->vzros_reb >= 0
      add_string("Возрастная принадлежность: "+;
                 inieditspr(A__MENUVERT, menu_vzros, mn->vzros_reb))
    endif
    if !empty(mn->god_r_min) .or. !empty(mn->god_r_max)
      if empty(mn->god_r_min)
        add_string("Лица, родившиеся до "+full_date(mn->god_r_max))
      elseif empty(mn->god_r_max)
        add_string("Лица, родившиеся после "+full_date(mn->god_r_min))
      else
        add_string("Лица, родившиеся с "+;
                   full_date(mn->god_r_min)+" по "+full_date(mn->god_r_max))
      endif
    endif
    if mn->rab_nerab >= 0
      add_string(upper(inieditspr(A__MENUVERT, menu_rab, mn->rab_nerab)))
    endif
    /*
    if mn->mi_git >= 0
      add_string("Место жительства: "+;
                 inieditspr(A__MENUVERT, menu_mest, mn->mi_git))
    endif
    if mn->rajon_git > 0
      add_string("  Район: "+inieditspr(A__POPUPMENU, dir_server+"rajon", mn->rajon_git))
    endif
    if mn->mest_inog >= 0
      add_string("Финансирование: "+;
                 inieditspr(A__MENUVERT, menu_mest, mn->mest_inog))
    endif
    if mn->rajon > 0
      add_string("  Район: "+inieditspr(A__POPUPMENU, dir_server+"rajon", mn->rajon))
    endif    */
    if !empty(mn->kod_diag)
      add_string("Шифр заболевания: "+mn->kod_diag)
    endif
    if yes_h_otd == 1 .and. mn->otd > 0
      add_string("Отделение: "+;
                 inieditspr(A__POPUPMENU, dir_server+"mo_otd", mn->otd))
    endif
    if mn->tip_usl >= 0
      add_string("Категория оплаты: "+;
                 inieditspr(A__MENUVERT, menu_plat, mn->tip_usl))
    endif
    if mn->summa_min > 0 .or. mn->summa_max > 0
      if empty(mn->summa_min)
        add_string("Стоимость лечения менее "+lstr(mn->summa_max,10,2))
      elseif empty(mn->summa_max)
        add_string("Стоимость лечения более "+lstr(mn->summa_min,10,2))
      else
        add_string("Стоимость лечения в диапазоне от "+;
                   lstr(mn->summa_min,10,2)+" до "+lstr(mn->summa_max,10,2))
      endif
    endif
    if mn->otd_usl > 0
      add_string("Отделение, в котором оказана услуга: "+;
                 inieditspr(A__POPUPMENU, dir_server+"mo_otd", mn->otd_usl))
    endif
    if mn->vr1 > 0
      add_string("Врач, оказавший услугу(и): "+alltrim(mn->vr))
    endif
    if mn->isvr > 0
      add_string("Код врача "+if(mn->isvr==1,"не ","")+"проставлен")
    endif
    if mn->as1 > 0
      add_string("Ассистент, оказавший услугу(и): "+alltrim(mn->as))
    endif
    if mn->isas > 0
      add_string("Код ассистента "+if(mn->isas==1,"не ","")+"проставлен")
    endif
    if mn->vras1 > 0
      add_string("Человек, оказавший услугу(и): "+alltrim(mn->vras))
    endif
    if is_oplata != 7
      if mn->med1 > 0
        add_string("Медсестра: "+mn->med)
      endif
      if mn->san1 > 0
        add_string("Санитарка: "+mn->san)
      endif
    endif
    if mn->uslugi > 0
      l := 0
      aeval(arr_usl, {|x| l := max(l,len(rtrim(x[3]))) } )
      add_string(padr("Оказанные услуги:",l+13)+"|Кол-во| Ст-ть")
      aeval(arr_usl, {|x| add_string("  "+x[2]+" "+;
                   padr(x[3],l)+"|"+put_val(x[4],5)+" |"+put_kop(x[5],8)) } )
    endif
    if mn->slug_usl > 0
      add_string("Служба, в которой оказаны услуги: "+mslugba[2])
    endif
    add_string("")
    add_string(" == РЕЗУЛЬТАТЫ ПОИСКА ==")
    add_string("Итого количество больных: "+lstr(tmp_k->(lastrec()))+" чел.")
    add_string("Итого листов учета: "+lstr(tmp->(lastrec()))+;
               " чел.  на сумму  "+lput_kop(ssumma,.t.)+" руб.")
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    keyboard ""
    select TMP
    go top
    do while !eof()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      s1 := left(kart->fio,40)
      s3 := ""
      //
      s1 += put_kopE(tmp->stoim,10)
      if mem_kodkrt == 2
        s2 := " ["
        if is_uchastok > 0
          s2 += alltrim(kart->bukva)
          s2 += lstr(kart->uchast,2)+"/"
        endif
        if is_uchastok == 1
          s2 += lstr(kart->kod_vu)
        elseif is_uchastok == 3
          s2 += alltrim(kart2->kod_AK)
        else
          s2 += lstr(kart->kod)
        endif
        s2 += "] "
      else
        s2 := " "
      endif
      if !empty(mmr_dol)
        s2 += ltrim(kart->mr_dol)
      endif
      s2 := padr(s2,50)
      s3 := padr(s3,50)
      //
      if isbit(mn->vid_doc,1)
        s1 += " "+date_8(kart->date_r)
        s2 += space(9)
        s3 += space(9)
      endif
      //
      if isbit(mn->vid_doc,2)
        perenos(a_diagnoz,kart->adres,24)
        s1 += " "+padr(alltrim(a_diagnoz[1]),24)
        s2 += " "+padr(alltrim(a_diagnoz[2]),24)
        s3 += " "+padr(alltrim(a_diagnoz[3]),24)
      endif
      //
      if isbit(mn->vid_doc,3)
        s1 += " "+date_8(human->k_data)
        s2 += space(9)
        s3 += space(9)
      endif
      //
      if isbit(mn->vid_doc,4)
        s1 += " "+padc(alltrim(human->kod_diag),5)
        s2 += space(6)
        s3 += space(6)
      endif
      //
      if isbit(mn->vid_doc,5)
        tmp1 := "" ; aup := {}
        Select HU
        find (str(human->(recno()),7))
        do while hu->kod == human->(recno()) .and. !eof()
          if hu->kol > 0
            Select USL
            goto (hu->u_kod)
            lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
            aadd(aup, {if(empty(lshifr1), usl->shifr, lshifr1),;
                       hu->kol} )
          endif
          select HU
          Skip
        enddo
        asort(aup,,,{|x,y| fsort_usl(x[1]) < fsort_usl(y[1]) } )
        if mn->uslugi > 0
          bup := {}
          for i := 1 to len(arr_usl)
            if (l := ascan(aup,{|x| x[1] == arr_usl[i,2]})) > 0
              aadd(bup, aclone(aup[l]) )
              adel(aup,l) ; asize(aup,len(aup)-1)
            endif
          next
          for i := len(bup) to 1 step -1
            aadd(aup, nil) ; ains(aup,1) ; aup[1] := bup[i]
          next
        endif
        for i := 1 to len(aup)
          tmp1 += alltrim(aup[i,1])+"("+lstr(aup[i,2])+"),"
        next
        tmp1 := left(tmp1,len(tmp1)-1)
        k_usl := perenos(a_uslugi,tmp1,23,",")
        s1 += " "+padc(alltrim(a_uslugi[1]),23)
        s2 += " "+padc(alltrim(a_uslugi[2]),23)
        s3 += " "+padc(alltrim(a_uslugi[3]),23)
      endif
      //
      if isbit(mn->vid_doc,6)
        tmp1 := "" ; aup := {}
        Select HU
        find (str(human->(recno()),7))
        do while hu->kod == human->(recno()) .and. !eof()
          if hu->kol > 0
            Select USL
            goto (hu->u_kod)
            lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
            aadd(aup, {if(empty(lshifr1), usl->shifr, lshifr1),;
                       hu->kol, hu->kod_vr} )
          endif
          select HU
          Skip
        enddo
        // перекодируем врача
        for i := 1 to len(aup)
          select PERSO
          goto (aup[i,3])
          aup[i,3]  := perso->tab_nom
        next
        //
        asort(aup,,,{|x,y| fsort_usl(x[1]) < fsort_usl(y[1]) } )
        if mn->uslugi > 0
          bup := {}
          for i := 1 to len(arr_usl)
            if (l := ascan(aup,{|x| x[1] == arr_usl[i,2]})) > 0
              aadd(bup, aclone(aup[l]) )
              adel(aup,l) ; asize(aup,len(aup)-1)
            endif
          next
          for i := len(bup) to 1 step -1
            aadd(aup, nil) ; ains(aup,1) ; aup[1] := bup[i]
          next
        endif
        for i := 1 to len(aup)
          tmp1 += alltrim(aup[i,1])+"("+lstr(aup[i,2])+")["+lstr(aup[i,3])+"],"
        next
        tmp1 := left(tmp1,len(tmp1)-1)
        k_usl := perenos(a_uslugi,tmp1,28,",")
        s1 += " "+padc(alltrim(a_uslugi[1]),28)
        s2 += " "+padc(alltrim(a_uslugi[2]),28)
        s3 += " "+padc(alltrim(a_uslugi[3]),28)
      endif
      //
      add_string(s1)
      add_string(s2)
      add_string(s3)
      if (isbit(mn->vid_doc,5).or.isbit(mn->vid_doc,6)) .and. k_usl > 3
        for i := 4 to k_usl
          s1 := space(50)
          if isbit(mn->vid_doc,1) ; s1 += space(9) ; endif
          if isbit(mn->vid_doc,2) ; s1 += space(25); endif
          if isbit(mn->vid_doc,3) ; s1 += space(9) ; endif
          if isbit(mn->vid_doc,4) ; s1 += space(6) ; endif
          if isbit(mn->vid_doc,5)
            add_string(s1+" "+padc(alltrim(a_uslugi[i]),23))
          else
            add_string(s1+" "+padc(alltrim(a_uslugi[i]),28))
          endif
        next
      endif
      select TMP
      skip
    enddo
    add_string(replicate("─",sh))
    if fl_exit
      add_string("*** "+expand("ОПЕРАЦИЯ ПРЕРВАНА"))
    else
      add_string("  Итого листов учета : "+lstr(tmp->(lastrec()))+;
                 " чел.  на сумму  "+lput_kop(ssumma,.t.)+" руб.")
    endif
    fclose(fp)
    close databases
    viewtext(name_file,,,,(sh>80),,,reg_print)
  endif
endif
close databases
restscreen(buf) ; setcolor(tmp_color)
return NIL

*****
Function pwrite_mn_p(k)
Local fl := .t.
if k == 1
  if emptyall(mdate_lech,mdate_schet)
    fl := func_error(4,"Обязательно должно быть заполнено хотя бы одно из первых двух полей даты!")
  elseif mvr1 > 0 .and. m1isvr > 0
    fl := func_error(4,"Недопустимое сочетание полей < Код врача >!")
  elseif mas1 > 0 .and. m1isas > 0
    fl := func_error(4,"Недопустимое сочетание полей < Код ассистента >!")
  endif
endif
return fl

*

***** 22.03.17
Static Function s1_mnog_poisk(cv,cf)
Local i, fl := .t., flu := .f., mkol, mstoim := 0, luch_doc := "", arr
++cv
if fl .and. mn->date_lech > 0 .and. p_regim != 1
  fl := between(human->k_data,pdate_lech[5],pdate_lech[6])
endif
if fl .and. mn->date_schet > 0 .and. p_regim != 2
  fl := between(human->k_data,pdate_schet[5],pdate_schet[6])
endif
if fl .and. !empty(much_doc)
  if !emptyall(kart->bukva,kart->uchast,kart->kod_vu)
    if !empty(kart->bukva)
      luch_doc += kart->bukva
    endif
    luch_doc += lstr(kart->uchast,2)
    if kart->kod_vu > 0
      luch_doc += "/"+lstr(kart->kod_vu)
    endif
  endif
  fl := like(much_doc,luch_doc)
endif
if fl .and. is_uchastok > 0 .and. !empty(mn->uchast)
  fl := f_is_uchast(arr_uchast,kart->uchast)
endif
if fl .and. !empty(mfio)
  fl := like(mfio,upper(kart->fio))
endif
if fl .and. mn->inostran > 0
  if mn->inostran == 1 //нет
    //9,21,22,23,24
    fl := !equalany(kart_->vid_ud,9,21,22,23,24)
  else
    fl := equalany(kart_->vid_ud,9,21,22,23,24)
  endif
endif
if fl .and. mn->mi_git > 0
  if mn->mi_git == 1
    fl := (left(kart_->okatog,2)=='18')
  else
    fl := !(left(kart_->okatog,2)=='18')
  endif
endif
if fl .and. mn->gorod_selo > 0
  if mn->gorod_selo == 1
    fl := !f_is_selo(kart_->gorod_selo,kart_->okatog)
  else
    fl := f_is_selo(kart_->gorod_selo,kart_->okatog)
  endif
endif
if fl .and. !empty(mn->_okato)
  s := mn->_okato
  for i := 1 to 3
    if right(s,3)=='000'
      s := left(s,len(s)-3)
    else
      exit
    endif
  next
  fl := (left(kart_->okatog,len(s))==s)
endif
if fl .and. !empty(madres)
  fl := like(madres,upper(kart->adres))
endif
if fl .and. !empty(mmr_dol)
  fl := like(mmr_dol,upper(kart->mr_dol))
endif
if fl .and. is_talon .and. mn->kategor > 0
  fl := (mn->kategor == kart_->kategor)
endif
if fl .and. !empty(mn->pol)
  fl := (kart->pol == mn->pol)
endif
if fl .and. mn->vzros_reb >= 0
  fl := (kart->vzros_reb == mn->vzros_reb)
endif
if fl .and. !empty(mn->god_r_min)
  fl := (mn->god_r_min <= kart->date_r)
endif
if fl .and. !empty(mn->god_r_max)
  fl := (kart->date_r <= mn->god_r_max)
endif
if fl .and. mn->rab_nerab >= 0
  fl := (kart->rab_nerab == mn->rab_nerab)
endif
/*
if fl .and. mn->mi_git >= 0
  fl := (kart->mi_git == mn->mi_git)
endif
if fl .and. mn->rajon_git > 0
  fl := (kart->rajon_git == mn->rajon_git)
endif
if fl .and. mn->mest_inog >= 0
  fl := (kart->mest_inog == mn->mest_inog)
endif
if fl .and. mn->rajon > 0
  fl := (kart->rajon == mn->rajon)
endif*/
if fl .and. !empty(mn->kod_diag)
  fl := (mn->kod_diag == human->KOD_DIAG)
endif
if fl .and. yes_h_otd == 1 .and. mn->otd > 0
  fl := (human->otd == mn->otd)
endif
if fl .and. mn->tip_usl >= 0
  fl := (human->tip_usl == mn->tip_usl)
endif
if fl .and. mn->summa_min > 0
  fl := (mn->summa_min <= human->cena)
endif
if fl .and. mn->summa_max > 0
  fl := (human->cena <= mn->summa_max)
endif
if fl
  if flag_hu
    mkol := 0
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno())
      flu := .t.
      if flu .and. mn->otd_usl > 0
        flu := (hu->otd == mn->otd_usl)
      endif
      if flu .and. mn->vras1 > 0
        flu := (hu->kod_vr == mn->vras1 .or. hu->kod_as == mn->vras1)
      endif
      if flu .and. mn->vr1 > 0
        flu := (hu->kod_vr == mn->vr1)
      endif
      if flu .and. mn->isvr > 0
        if mn->isvr == 1  // нет
          flu := (hu->kod_vr == 0)
        else
          flu := (hu->kod_vr > 0)
        endif
      endif
      if flu .and. mn->as1 > 0
        flu := (hu->kod_as == mn->as1)
      endif
      if flu .and. mn->isas > 0
        if mn->isas == 1  // нет
          flu := (hu->kod_as == 0)
        else
          flu := (hu->kod_as > 0)
        endif
      endif
      if is_oplata != 7
        if flu .and. mn->med1 > 0
          flu := equalany(mn->med1,hu->med1,hu->med2,hu->med3)
        endif
        if flu .and. mn->san1 > 0
          flu := equalany(mn->san1,hu->san1,hu->san2,hu->san3)
        endif
      endif
      if flu .and. mn->slug_usl > 0
        flu := (usl->slugba == mn->slug_usl)
      endif
      if flu .and. mn->uslugi > 0
        i := ascan(arr_usl,{|x| x[1] == hu->u_kod})
        if (flu := (i > 0))
          arr_usl[i,4] += hu->kol
          arr_usl[i,5] += hu->stoim
        endif
      endif
      if flu
        mkol += hu->kol
        mstoim += hu->stoim
      endif
      skip
    enddo
    if emptyall(mkol,mstoim)
      fl := .f.
    endif
  else
    mstoim := human->cena
  endif
endif
if fl
  select TMP_K
  find (str(human->kod_k,7))
  if !found()
    append blank
    tmp_k->kod_k := human->kod_k
  endif
  select TMP
  append blank
  tmp->kod := human->(recno())
  tmp->stoim := mstoim
  ssumma += mstoim
  if ++cf % 2000 == 0
    Commit
  endif
endif
@ 24,1 say lstr(cv) color cColorSt2Msg
@ row(),col() say "/" color "W/R"
@ row(),col() say lstr(cf) color cColorStMsg
return NIL

*

*****
Function pl_napr_vrach()
Local i, j, arr, begin_date, end_date, s, buf := save_row(maxrow()),;
      fl_exit := .f., sh, HH := 60, reg_print, speriod,;
      arr_title, name_file := "napr_vr"+stxt, arr_m, adbf
if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
speriod := arr_m[4]
begin_date := arr_m[7]
end_date := arr_m[8]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
adbf := {;
     {"KOD_VR",     "N",      4,      0},;  // код врача
     {"KOL"    ,    "N",      6,      0},;  // количество больных
     {"SUMMA"  ,    "N",     14,      2};   // общая стоимость
    }
dbcreate(cur_dir+"tmp", adbf)
use (cur_dir+"tmp")
index on str(kod_vr,4) to (cur_dir+"tmp")
R_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
dbseek(dtos(arr_m[5]),.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if human->kod_vr > 0 .and. f_is_uch(st_a_uch,human->lpu)
    select TMP
    find (str(human->kod_vr,4))
    if !found()
      append blank
      replace kod_vr with human->kod_vr
    endif
    tmp->kol ++
    tmp->summa += human->cena
  endif
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  reg_print := 1
  arr_title := {;
"──────────────────────────────────────────────┬─────┬───────────",;
"                                              │ Кол.│   Сумма   ",;
"                    Врач                      │больн│  лечения  ",;
"──────────────────────────────────────────────┴─────┴───────────"}
  sh := len(arr_title[1])
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string(center("Врачи, направившие на платное лечение",sh))
  titleN_uch(st_a_uch,sh)
  add_string(center(speriod,sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"mo_uch",,"UCH")
  R_Use(dir_server+"mo_otd",,"OTD")
  set relation to kod_lpu into UCH
  R_Use(dir_server+"mo_pers",,"perso")
  set relation to otd into OTD
  use (cur_dir+"tmp") new
  set relation to kod_vr into perso
  index on upper(uch->name)+upper(otd->name)+str(perso->otd,3)+upper(perso->fio) to (cur_dir+"tmp")
  old_otd := kol_otd := sum_otd := j := 0
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if old_otd != perso->otd
      if old_otd != 0
        add_string(space(sh-20)+replicate("-",20))
        add_string(padl("Итого: "+put_val(kol_otd,6)+put_kopE(sum_otd,12),sh))
        kol_otd := sum_otd := 0
      endif
      s := ""
      if count_uch > 1
        s := "["+alltrim(uch->name)+"] "+upper(alltrim(otd->name))
      endif
      add_string(space(10)+s)
    endif
    s := str(++j,3)+". "
    s += "["+lstr(perso->tab_nom)+"] "
    s += alltrim(perso->fio)
    add_string(padr(s,46)+put_val(tmp->kol,6)+put_kopE(tmp->summa,12))
    old_otd := perso->otd
    kol_otd += tmp->kol
    sum_otd += tmp->summa
    select TMP
    skip
  enddo
  if old_otd != 0
    add_string(space(sh-20)+replicate("-",20))
    add_string(padl("Итого: "+put_val(kol_otd,6)+put_kopE(sum_otd,12),sh))
  endif
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

*

***** по направившим врачам + услуги
Function pl_napr2vrach()
Local i, j, arr[2], begin_date, end_date, s, buf := save_row(maxrow()),;
      fl_exit := .f., sh, HH := 60, reg_print, speriod,;
      arr_title, name_file := "napr_vr2"+stxt, arr_m, adbf, mperso
if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
speriod := arr_m[4]
begin_date := arr_m[7]
end_date := arr_m[8]
if (mperso := input_kperso()) == NIL
  mywait()
  mperso := {}
  R_Use(dir_server+"mo_pers",,"perso")
  go top
  do while !eof()
    if perso->kod > 0
      aadd(mperso, {perso->kod,""} )
    endif
    skip
  enddo
  perso->(dbCloseArea())
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
adbf := {;
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0},;  // наименование услуги
     {"TAB_NOM",    "N",      5,      0},;  // таб.номер врача
     {"KOD_VR",     "N",      4,      0},;  // код врача
     {"FIO",        "C",     50,      0},;  // Ф.И.О. врача
     {"KOL"    ,    "N",      6,      0},;  // количество услуг
     {"STOIM"  ,    "N",     14,      2};   // итоговая стоимость услуги
    }
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
index on str(kod_vr,4)+str(u_kod,4) to (cur_dir+"tmpk")
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
R_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
dbseek(dtos(arr_m[5]),.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if human->kod_vr > 0 .and. f_is_uch(st_a_uch,human->lpu)
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno())
      select TMP
      find (str(human->kod_vr,4)+str(hu->u_kod,4))
      if !found()
        append blank
        tmp->kod_vr := human->kod_vr
        tmp->u_kod := hu->u_kod
      endif
      tmp->kol += hu->kol
      tmp->stoim += hu->stoim
      select HU
      skip
    enddo
  endif
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"mo_pers",,"PERSO")
  SET(_SET_DELETED, .F.)
  use (cur_dir+"tmp") new
  go top
  do while !eof()
    select USL
    goto (tmp->u_kod)
    if usl->kod <= 0 .or. deleted() .or. eof()
      select TMP
      DELETE
    else
      tmp->u_shifr := usl->shifr
      tmp->u_name := usl->name
    endif
    select PERSO
    goto (tmp->kod_vr)
    if deleted() .or. eof()
      select TMP
      DELETE
    else
      tmp->fio := perso->fio
      tmp->tab_nom := perso->tab_nom
    endif
    select TMP
    skip
  enddo
  SET(_SET_DELETED, .T.)
  select TMP
  index on upper(fio)+str(kod_vr,4)+fsort_usl(u_shifr) to (cur_dir+"tmpn")
  reg_print := 2
  arr_title := {;
"──────────────────────────────────────────────────────────┬──────┬──────────────",;
"                                                          │Кол-во│   Стоимость  ",;
"                                                          │ услуг│     услуг    ",;
"──────────────────────────────────────────────────────────┴──────┴──────────────"}
  sh := len(arr_title[1])
  len_n := 58
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string(center("Врачи, направившие на платное лечение",sh))
  titleN_uch(st_a_uch,sh)
  add_string(center(speriod,sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  old_perso := -1  // для печати Ф.И.О. в начале
  old_fio := "["+lstr(tmp->tab_nom)+"] "+tmp->fio
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if old_perso != tmp->kod_vr
      if old_perso > 0
        add_string(replicate("─",sh))
        if !emptyall(skol,sstoim)
          add_string(padl("И Т О Г О :  ",len_n)+;
                     str(skol,7,0)+;
                     put_kopE(sstoim,15))
        endif
      endif
      skol := sstoim := 0
      add_string("")
      add_string(space(5)+lstr(tmp->tab_nom)+". "+upper(rtrim(tmp->fio)))
    endif
    skol += tmp->kol
    sstoim += tmp->stoim
    j := perenos(arr,tmp->u_shifr+" "+tmp->u_name,len_n)
    old_perso := tmp->kod_vr
    add_string(padr(arr[1],len_n)+;
               str(tmp->kol,7,0)+;
               put_kopE(tmp->stoim,15))
    for i := 2 to j
      add_string(space(11)+arr[i])
    next
    select TMP
    skip
  enddo
  add_string(replicate("─",sh))
  if !emptyall(skol,sstoim)
    add_string(padl("И Т О Г О :  ",len_n)+;
               str(skol,7,0)+;
               put_kopE(sstoim,15))
  endif
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

*

*****
Function ob_ved_vz()
Local i, j, k, fl, fl_exit := .f., buf := save_row(maxrow()),;
      t_arr[BR_LEN], blk, fl1 := .f., fl2 := .f.
Private arr_m, muslovie, ouslovie, p_sb, p_se, a_t[4]
if (arr_m := year_month()) == NIL
  return NIL
endif
p_sb := date_8(arr_m[5])
p_se := date_8(arr_m[6])
a_t[1] := "──────────────────────────────┬────────────┬────────────┬────────────┬────────────"
a_t[2] := "                              │  Сальдо на │            │            │  Сальдо на "
a_t[3] := "                              │  "+p_sb+"г.│    Дебет   │    Кредит  │  "+p_se+"г."
a_t[4] := "──────────────────────────────┴────────────┴────────────┴────────────┴────────────"
//
dbcreate(cur_dir+"tmp", {{"kod_k"  ,"N", 7,0},; // код больного по картотеке
                         {"pr_smo" ,"N", 6,0},; // код предприятия / СМО
                         {"SALDO1" ,"N",13,2},;
                         {"DEBET"  ,"N",13,2},;
                         {"KREDIT" ,"N",13,2},;
                         {"SALDO2" ,"N",13,2}}) //
dbcreate(cur_dir+"tmp1", {{"name"   ,"C",30,0},; // наименование предприятия
                          {"tip_usl","N", 1,0},; // 2-взаимозачет, 1-добр.СМО
                          {"pr_smo" ,"N", 6,0},; // код предприятия / СМО
                          {"SALDO1" ,"N",13,2},;
                          {"DEBET"  ,"N",13,2},;
                          {"KREDIT" ,"N",13,2},;
                          {"SALDO2" ,"N",13,2}}) //
R_Use(dir_server+"p_pr_vz",,"PRED")
R_Use(dir_server+"p_d_smo",,"SMO")
use (cur_dir+"tmp") new
index on str(pr_smo,6)+str(kod_k,7) to (cur_dir+"tmp")
use (cur_dir+"tmp1") new
index on str(tip_usl,1)+str(pr_smo,6) to (cur_dir+"tmp1")
R_Use(dir_server+"hum_p",,"HP")
index on kod_k to (cur_dir+"tmp_hp") ;
      for equalany(hp->tip_usl,1,2) .and. hp->k_data <= arr_m[6] progress
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
go top
do while !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  select TMP1
  find (str(hp->tip_usl,1)+str(hp->pr_smo,6))
  if !found()
    append blank
    tmp1->tip_usl := hp->tip_usl
    tmp1->pr_smo  := hp->pr_smo
    if hp->tip_usl == 1
      smo->(dbGoto(hp->pr_smo))
      tmp1->name := smo->name
    else
      pred->(dbGoto(hp->pr_smo))
      tmp1->name := pred->name
    endif
  endif
  if hp->k_data < arr_m[5]
    tmp1->saldo1 += hp->cena
  else
    tmp1->debet += hp->cena
  endif
  if hp->tip_usl == 1  // добровольное страхование
    select TMP
    find (str(hp->pr_smo,6)+str(hp->kod_k,7))
    if !found()
      append blank
      tmp->kod_k  := hp->kod_k
      tmp->pr_smo := hp->pr_smo
    endif
    if hp->k_data < arr_m[5]
      tmp->saldo1 += hp->cena
    else
      tmp->debet += hp->cena
    endif
  endif
  select HP
  skip
enddo
//
R_Use(dir_server+"plat_vz",,"OPL")
go top
do while !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if opl->date_opl <= arr_m[6]
    select TMP1
    find (str(opl->tip,1)+str(opl->pr_smo,6))
    if !found()
      append blank
      tmp1->tip_usl := opl->tip
      tmp1->pr_smo  := opl->pr_smo
      if opl->tip == 1
        smo->(dbGoto(opl->pr_smo))
        tmp1->name := smo->name
      else
        pred->(dbGoto(opl->pr_smo))
        tmp1->name := pred->name
      endif
    endif
    if opl->date_opl < arr_m[5]
      tmp1->saldo1 -= opl->summa_opl
    else
      tmp1->kredit += opl->summa_opl
    endif
    if opl->tip == 1  // добровольное страхование
      select TMP
      find (str(opl->pr_smo,6)+str(opl->kod_k,7))
      if !found()
        append blank
        tmp->kod_k  := opl->kod_k
        tmp->pr_smo := opl->pr_smo
        if tmp->(lastrec()) % 5000 == 0
          Commit
        endif
      endif
      if opl->date_opl < arr_m[5]
        tmp->saldo1 -= opl->summa_opl
      else
        tmp->kredit += opl->summa_opl
      endif
    endif
  endif
  select OPL
  skip
enddo
mywait()
select TMP1
delete for emptyall(SALDO1,DEBET,KREDIT)
pack
if (j := tmp1->(lastrec())) > 0
  dbeval({|| iif(tmp1->tip_usl == 1, (fl1 := .t.), (fl2 := .t.)),;
             tmp1->saldo2 := tmp1->saldo1 + tmp1->debet - tmp1->kredit,;
             iif(empty(name) .and. tip_usl==1, (tmp1->name := " = без ДСМО = "), nil),;
             iif(empty(name) .and. tip_usl==2, (tmp1->name := " = без предприятия = "), nil) })
  //
  select TMP
  delete for emptyall(SALDO1,DEBET,KREDIT)
  pack
  dbeval({|| tmp->saldo2 := tmp->saldo1 + tmp->debet - tmp->kredit })
endif
close databases
rest_box(buf)
if fl_exit
  // ничего
elseif j == 0
  func_error(4,"Нет сведений по ДМС и взаимозачету "+arr_m[4])
else
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow()-1
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := "Оборотная ведомость "+arr_m[4]
  if fl1
    t_arr[BR_TITUL] += " (добр/страх.)"
  endif
  if fl2
    t_arr[BR_TITUL] += " (в/зачет)"
  endif
  t_arr[BR_TITUL_COLOR] := "BG+/GR"
  t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.t.,0}
  blk := {|| iif(tip_usl==1, {1,2}, {3,4}) }
  t_arr[BR_COLUMN] := {{ center("Наименование",30), {|| tmp1->name }, blk },;
                       { " Сальдо на; "+p_sb, {|| put_kop(saldo1,11) }, blk },;
                       { "  Дебет", {|| put_kop(debet,11) }, blk },;
                       { "  Кредит", {|| put_kop(kredit,11) }, blk },;
                       { " Сальдо на; "+p_se, {|| put_kop(saldo2,11) }, blk }}
  t_arr[BR_EDIT] := {|nk,ob| f1ob_ved_vz(nk,ob,"edit") }
  t_arr[BR_STAT_MSG] := {|| ;
    status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F9>^ - печать") }
  use (cur_dir+"tmp1") new
  index on upper(name) to (cur_dir+"tmp1")
  go top
  edit_browse(t_arr)
  close databases
  rest_box(buf)
endif
return NIL

*

*****
Function f1ob_ved_vz(nKey,oBrow,regim)
Local ret := -1, buf, fl := .f., rec, tmp_color, i, j, ;
      s, sh, HH := 58, reg_print := 2, arr_title, name_file := "ob_ved"+stxt
do case
  case regim == "edit"
    do case
      case nKey == K_F9
        rec := tmp1->(recno())
        buf := save_row(maxrow())
        sh := len(a_t[1])
        fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
        R_Use(dir_server+"organiz",,"ORG")
        add_string(alltrim(org->name))
        org->(dbCloseArea())
        add_string("")
        s := "Оборотная ведомость по ДМС и взаимозачету"
        add_string(center(s,sh))
        add_string(center(arr_m[4],sh))
        add_string("")
        aeval(a_t, {|x| add_string(x) } )
        ss1 := sd := sk := ss2 := 0
        select TMP1
        go top
        do while !eof()
          if verify_FF(HH,.t.,sh)
            aeval(a_t, {|x| add_string(x) } )
          endif
          add_string(tmp1->name+put_kopE(tmp1->saldo1,13)+;
                                put_kopE(tmp1->debet,13)+;
                                put_kopE(tmp1->kredit,13)+;
                                put_kopE(tmp1->saldo2,13))
          ss1 += tmp1->saldo1
          sd  += tmp1->debet
          sk  += tmp1->kredit
          ss2 += tmp1->saldo2
          skip
        enddo
        add_string(replicate("─",sh))
        add_string(padl("И Т О Г О : ",30)+put_kopE(ss1,13)+;
                                           put_kopE(sd,13)+;
                                           put_kopE(sk,13)+;
                                           put_kopE(ss2,13))
        fclose(fp)
        viewtext(name_file,,,,(sh>80),,,reg_print)
        select TMP1
        goto (rec)
      case nKey == K_ENTER .and. tmp1->tip_usl == 1  // добр.страхование
        f2ob_ved_vz()
        select TMP1
      case nKey == K_ENTER .and. tmp1->tip_usl == 2  // взаимозачет
        glob_pr_vz := {tmp1->pr_smo,alltrim(tmp1->name)}
        muslovie := "hp->tip_usl==2 .and. hp->pr_smo==glob_pr_vz[1]"
        ouslovie := "opl->tip==2 .and. opl->pr_smo==glob_pr_vz[1]"
        f4ob_ved_vz(2)
        select TMP1
    endcase
endcase
return ret

*

*****
Function f2ob_ved_vz()
Local i, j, k, fl, buf := save_row(maxrow()), t_arr[BR_LEN]
mywait()
t_arr[BR_TOP] := 2
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Об.ведомость: "+alltrim(tmp1->name)+" "+arr_m[4]
t_arr[BR_TITUL_COLOR] := "BG+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.t.,0}
n := 30
t_arr[BR_COLUMN] := {{ center("Ф.И.О.",n), {|| padr(kart->fio,n) } },;
                     { " Сальдо на; "+p_sb, {|| put_kop(saldo1,11) } },;
                     { "  Дебет", {|| put_kop(debet,11) } },;
                     { "  Кредит", {|| put_kop(kredit,11) } },;
                     { " Сальдо на; "+p_se, {|| put_kop(saldo2,11) } }}
t_arr[BR_EDIT] := {|nk,ob| f3ob_ved_vz(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| ;
  status_key("^<Esc>^ выход;  ^<Enter>^ оборотка по человеку;  ^<F8>^ полная оборотка;  ^<F9>^ печать") }
R_Use(dir_server+"kartotek",,"KART")
use (cur_dir+"tmp") new alias TMP
set relation to kod_k into KART
index on upper(kart->fio) to (cur_dir+"tmp") for tmp1->pr_smo == tmp->pr_smo
go top
edit_browse(t_arr)
tmp->(dbCloseArea())
kart->(dbCloseArea())
rest_box(buf)
return NIL

*

*****
Function f3ob_ved_vz(nKey,oBrow,regim)
Local ret := -1, buf, fl := .f., rec, tmp_color, i, j, k, t_arr[2],;
      s, sh, HH := 58, reg_print := 2, arr_title, name_file := "ob_ved"+stxt
do case
  case regim == "edit"
    do case
      case nKey == K_F8
        rec := tmp->(recno())
        set relation to
        kart->(dbCloseArea())
        glob_d_smo := {tmp1->pr_smo,alltrim(tmp1->name)}
        muslovie := "hp->tip_usl==1 .and. hp->pr_smo==glob_d_smo[1]"
        ouslovie := "opl->tip==1 .and. opl->pr_smo==glob_d_smo[1]"
        f4ob_ved_vz(1)
        R_Use(dir_server+"kartotek",,"KART")
        select TMP
        set relation to kod_k into KART
        goto (rec)
      case nKey == K_F9
        rec := tmp->(recno())
        buf := save_row(maxrow())
        sh := len(a_t[1])
        fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
        R_Use(dir_server+"organiz",,"ORG")
        add_string(alltrim(org->name))
        org->(dbCloseArea())
        add_string("")
        s := "Оборотная ведомость по: "+alltrim(tmp1->name)
        add_string(center(s,sh))
        add_string(center(arr_m[4],sh))
        add_string("")
        aeval(a_t, {|x| add_string(x) } )
        ss1 := sd := sk := ss2 := 0
        select TMP
        go top
        do while !eof()
          if verify_FF(HH,.t.,sh)
            aeval(a_t, {|x| add_string(x) } )
          endif
          k := perenos(t_arr,kart->fio,30)
          add_string(padr(t_arr[1],30)+put_kopE(tmp->saldo1,13)+;
                                       put_kopE(tmp->debet,13)+;
                                       put_kopE(tmp->kredit,13)+;
                                       put_kopE(tmp->saldo2,13))
          for j := 2 to k
            add_string(padl(alltrim(t_arr[j]),30))
          next
          ss1 += tmp1->saldo1
          sd  += tmp1->debet
          sk  += tmp1->kredit
          ss2 += tmp1->saldo2
          skip
        enddo
        add_string(replicate("─",sh))
        add_string(padl("И Т О Г О : ",30)+put_kopE(ss1,13)+;
                                           put_kopE(sd,13)+;
                                           put_kopE(sk,13)+;
                                           put_kopE(ss2,13))
        fclose(fp)
        viewtext(name_file,,,,(sh>80),,,reg_print)
        select TMP
        goto (rec)
      case nKey == K_ENTER
        rec := tmp->(recno())
        glob_fio := kart->fio
        set relation to
        kart->(dbCloseArea())
        glob_d_smo := {tmp1->pr_smo,alltrim(tmp1->name)}
        muslovie := "hp->tip_usl==1 .and. hp->pr_smo==glob_d_smo[1]"
        muslovie += " .and. hp->kod_k=="+lstr(tmp->kod_k)
        ouslovie := "opl->tip==1 .and. opl->pr_smo==glob_d_smo[1]"
        ouslovie += " .and. opl->kod_k=="+lstr(tmp->kod_k)
        f4ob_ved_vz(0)
        R_Use(dir_server+"kartotek",,"KART")
        select TMP
        set relation to kod_k into KART
        goto (rec)
    endcase
endcase
return ret

*

*****
Function f4ob_ved_vz(par)
Local s, sh, HH := 58, reg_print, arr_title, n_file := "ob_ved"+stxt,;
      buf := save_row(maxrow()), adbf, msaldo1, msaldo2, sum1, sum2
mywait()
adbf := {{"d_dokum","D", 8,0},;
         {"prim",   "C",30,0},;
         {"summa",  "N",11,2}}
dbcreate(cur_dir+"tmp1_",adbf)
dbcreate(cur_dir+"tmp2_",adbf)
use (cur_dir+"tmp1_") new
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"hum_p",dir_server+"hum_pd","HP")
dbseek(dtos(arr_m[5]),.t.)
index on dtos(k_data) to (cur_dir+"tmp_hp") for &muslovie while hp->k_data <= arr_m[6]
go top
do while !eof()
  kart->(dbGoto(hp->kod_k))
  select TMP1_
  append blank
  tmp1_->d_dokum := hp->k_data
  tmp1_->prim := kart->fio
  tmp1_->summa := hp->cena
  select HP
  skip
enddo
//
use (cur_dir+"tmp2_") new
R_Use(dir_server+"plat_vz",,"OPL")
index on dtos(date_opl) to (cur_dir+"tmp_opl") for &ouslovie .and. between(date_opl,arr_m[5],arr_m[6])
go top
do while !eof()
  select TMP2_
  append blank
  tmp2_->d_dokum := opl->date_opl
  if par == 1
    kart->(dbGoto(opl->kod_k))
    tmp2_->prim := fam_i_o(kart->fio)
  else
    tmp2_->prim := opl->prim
  endif
  tmp2_->summa := opl->summa_opl
  select OPL
  skip
enddo
kart->(dbCloseArea())
opl->(dbCloseArea())
hp->(dbCloseArea())
//
arr_title := {;
  "──────────────────────────────────────────────────┬┬───────────────────────────────────",;
  "                  Д  Е  Б  Е  Т                   ││        К  Р  Е  Д  И  Т           ",;
  "────────┬──────────┬──────────────────────────────┼┼────────┬──────────┬───────────────",;
  "  Дата  │   Сумма  │            Ф.И.О.            ││  Дата  │   Сумма  │  Примечание   ",;
  "────────┴──────────┴──────────────────────────────┴┴────────┴──────────┴───────────────"}
sh := len(arr_title[1])
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(center("Оборотная ведомость",sh))
do case
  case par == 0
    add_string(center("по: "+glob_d_smo[2],sh))
    add_string(center("<<. "+alltrim(glob_fio)+" .>>",sh))
    msaldo1 := tmp->saldo1
    sum1    := tmp->debet
    sum2    := tmp->kredit
    msaldo2 := tmp->saldo2
  case par == 1
    add_string(center("по: "+glob_d_smo[2],sh))
    msaldo1 := tmp1->saldo1
    sum1    := tmp1->debet
    sum2    := tmp1->kredit
    msaldo2 := tmp1->saldo2
  case par == 2
    add_string(center("по: "+glob_pr_vz[2],sh))
    msaldo1 := tmp1->saldo1
    sum1    := tmp1->debet
    sum2    := tmp1->kredit
    msaldo2 := tmp1->saldo2
endcase
add_string(center(arr_m[4],sh))
add_string("")
s := "  Сальдо на "+date_8(arr_m[5])+"г.:  "+lput_kop(msaldo1,.t.)
if msaldo1 >= 0
  add_string(s)
else
  add_string(padl(s,sh-2))
endif
aeval(arr_title, {|x| add_string(x) } )
select TMP1_
index on dtos(d_dokum)+prim to (cur_dir+"tmp1_")
go top
select TMP2_
index on dtos(d_dokum)+prim to (cur_dir+"tmp2_")
go top
do while !( tmp1_->(eof()) .and. tmp2_->(eof()) )
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  select TMP1_
  if eof()
    s := space(50)
  else
    s := date_8(tmp1_->d_dokum) + ;
         put_kopE(tmp1_->summa,11)+" "+;
         tmp1_->prim
    skip
  endif
  s += "  "
  select TMP2_
  if !eof()
    s += date_8(tmp2_->d_dokum) + ;
         put_kopE(tmp2_->summa,11)+" "+;
         alltrim(tmp2_->prim)
    skip
  endif
  add_string(s)
enddo
tmp1_->(dbCloseArea())
tmp2_->(dbCloseArea())
add_string(replicate("─",sh))
add_string(put_kopE(sum1,19)+space(31)+"  "+put_kopE(sum2,19))
add_string(replicate("─",sh))
s := "  Сальдо на "+date_8(arr_m[6])+"г.:  "+lput_kop(msaldo2,.t.)
if msaldo2 >= 0
  add_string(s)
else
  add_string(padl(s,sh-2))
endif
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,(sh > 80),,,2)
return NIL

*

*****
Function rees1_vzaim(name_file)
Local buf := save_row(maxrow()), sh, HH := 58, arr_title, s, j, sk, ss, old,;
      reg_print := 2
mywait()
arr_title := {;
"──────────────────────────────────────────────┬────┬─────────────────┬─────────",;
"                   Ф.И.О.                     │Кол.│   Срок лечения  │Стоимость",;
"                                              │л/у │                 │ лечения ",;
"──────────────────────────────────────────────┴────┴─────────────────┴─────────"}
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
org->(dbCloseArea())
add_string("")
s := "Реестр платных услуг ("
if tmp1->tip_usl == 1
  s += "добровольное страхование)"
else
  s += "взаимозачет)"
endif
add_string(center(s,sh))
add_string(center("по: "+upper(alltrim(tmp1->name)),sh))
add_string(center(arr_m[4],sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
j := sk := ss := 0
select TMP
go top
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  s := padr(str(++j,4)+". "+kart->fio,46)+;
       str(tmp->kol,3)+"   "+;
       padc(left(dtoc(tmp->n_data),5)+" - "+left(dtoc(tmp->k_data),5),17)+;
       put_kopE(tmp->stoim,10)
  sk += tmp->kol
  ss += tmp->stoim
  add_string(s)
  skip
enddo
if verify_FF(HH-5,.t.,sh)
  aeval(arr_title, {|x| add_string(x) } )
endif
add_string(replicate("─",sh))
add_string(padl("Итого : "+lstr(sk),sh-30)+put_kop(ss,30))
add_string("")
add_string("")
add_string(center("Главный бухгалтер _________________",sh))
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

***** 11.02.13
Function rees2_vzaim(name_file)
Local buf := save_row(maxrow()), sh, HH := 52, arr_title, s, i, j, k, sk, ss,;
      arr2title, reg_print := 6, afio[10], lfio := 19, kfio, lsk, lss, adbf,;
      aadres[2], kadres, apolis[10], kpolis
Private d_file := "P_REESTR"+sdbf
if !del_dbf_file(d_file)
  return NIL
endif
mywait()
adbf := {{"nomer",  "C", 6,0},;
         {"fio",    "C",50,0},;
         {"adres",  "C",50,0},;
         {"polis",  "C",17,0},;
         {"data",   "C",10,0},;
         {"kod",    "C",10,0},;
         {"name",   "C",70,0},;
         {"otd",    "C", 5,0},;
         {"vrach",  "C",20,0},;
         {"diagnoz","C", 5,0},;
         {"cena",   "C",10,0},;
         {"kol",    "C", 4,0},;
         {"summa",  "C",10,0}}
arr_title := {;
"───┬───────────────────┬─────────────────┬────────┬──────────┬─────────────────────────────────────────────────────────────────┬─────┬───────┬────┬──────────┬───────────",;
"NN │  Ф.И.О., адрес    │      Полис,     │  Дата  │ Код мани-│                   Название медицинской услуги                   │Отде-│  Цена │Кол.│ Сумма за │ Примечание",;
"пп │  застрахованного  │     диагноз     │оказания│ пуляции  │                                                                 │ление│ каждой│оказ│все кол-во│           ",;
"   │                   │                 │  мед.  │          │                                                                 │     │ услуги│ус- │оказ.услуг│           ",;
"   │                   │                 │ услуги │          │                                                                 │     │ (руб.)│луг │  (руб.)  │           ",;
"───┴───────────────────┴─────────────────┴────────┴──────────┴─────────────────────────────────────────────────────────────────┴─────┴───────┴────┴──────────┴───────────"}
arr2title := {;
"───┬───────────────────┬─────────────────┬────────┬──────────┬─────────────────────────────────────────────────────────────────┬─────┬───────┬────┬──────────┬───────────",;
" 1 │         2         │        3        │    4   │     5    │                              6                                  │  7  │   8   │ 9  │    10    │     11    ",;
"───┴───────────────────┴─────────────────┴────────┴──────────┴─────────────────────────────────────────────────────────────────┴─────┴───────┴────┴──────────┴───────────"}
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name)+if(empty(org->inn), "", ", ИНН "+org->inn))
add_string(alltrim(org->adres)+if(empty(org->telefon), "", " тел."+org->telefon))
add_string("р/с № "+alltrim(org->r_schet)+" в "+rtrim(org->bank)+;
           ", БИК "+alltrim(org->smfo)+", кор/c "+alltrim(org->k_schet))
add_string("")
org->(dbCloseArea())
if tmp1->tip_usl == 1
  add_string(center("Реестр №_____ оказанных медицинских услуг",sh))
  add_string(center("по полисам ДМС "+alltrim(tmp1->name),sh))
else
  add_string(center("Реестр платных услуг (взаимозачет)",sh))
  add_string(center("по предприятию: "+upper(alltrim(tmp1->name)),sh))
endif
add_string(center(arr_m[4],sh))
dbcreate(d_file,adbf)
use (d_file) new alias DD
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"mo_pers",,"perso")
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HPU")
R_Use(dir_server+"hum_p",,"HP")
aeval(arr_title, {|x| add_string(x) } )
j := sk := ss := 0
select TMP
go top
do while !eof()
  arr := {}
  select TMP2
  find (str(tmp->(recno()),6))
  do while tmp2->rec_tmp == tmp->(recno()) .and. !eof()
    select HP
    goto (tmp2->rec_hp)
    if (i := ascan(arr, {|x| x[1] == tmp2->d_polis })) == 0
      aadd(arr, {tmp2->d_polis,{},{},{}}) ; i := len(arr)
    endif
    add_diagnoz(arr[i,3])
    select HPU
    find (str(hp->(recno()),7))
    do while hpu->kod == hp->(recno())
      add_vrach(arr[i,4],hpu->kod_vr)
      otd->(dbGoto(hpu->otd))
      usl->(dbGoto(hpu->u_kod))
      aadd(arr[i,2], {c4tod(hpu->date_u),;
                      usl->shifr,;
                      usl->name,;
                      otd->short_name,;
                      hpu->kol,;
                      hpu->stoim;
                     })
      select HPU
      skip
    enddo
    select TMP2
    skip
  enddo
  kfio := perenos(afio,alltrim(kart->fio),lfio)
  kadres := perenos(aadres,alltrim(kart->adres),lfio)
  for i := 1 to kadres
    afio[kfio+i] := aadres[i]
  next
  kfio += kadres
  for i := 1 to len(arr)
    arr_diagnoz := arr[i,3]
    asort(arr_diagnoz)
    if len(alltrim(arr[i,1])) <= 17
      s := ""
      for k := 1 to len(arr_diagnoz)
        s += alltrim(arr_diagnoz[k])+" "
      next
      kpolis := perenos(apolis,alltrim(s),17)
      Ins_Array(apolis,1,alltrim(arr[i,1])) ; ++kpolis
    else
      s := alltrim(arr[i,1])+"/"
      for k := 1 to len(arr_diagnoz)
        s += alltrim(arr_diagnoz[k])+" "
      next
      kpolis := perenos(apolis,alltrim(s),17)
    endif
    arr_vrach := ret_arr_vrach(arr[i,4])
    asort(arr[i,2],,,{|x,y| iif(x[1]==y[1], fsort_usl(x[2]) < fsort_usl(y[2]), x[1] < y[1]) } )
    lsk := lss := 0
    for k := 1 to len(arr[i,2])
      select DD
      append blank
      if k == 1
        s := padr(lstr(++j)+". ",4)
        dd->nomer := lstr(j)
      else
        s := space(4)
      endif
      if k <= kfio
        s += padr(afio[k],lfio)+" "
        if k == 1
          dd->fio := alltrim(kart->fio)
          dd->adres := alltrim(kart->adres)
        endif
      else
        s += space(lfio+1)
      endif
      if k <= kpolis
        s += padc(alltrim(apolis[k]),17)+" "
        if k == 1
          dd->polis := alltrim(arr[i,1])
        endif
      else
        s += space(17+1)
      endif
      dd->data  := full_date(arr[i,2,k,1])
      dd->kod   := arr[i,2,k,2]
      dd->name  := arr[i,2,k,3]
      dd->otd   := arr[i,2,k,4]
      dd->cena  := str(arr[i,2,k,6]/arr[i,2,k,5],10,2)
      dd->kol   := str(arr[i,2,k,5],4)
      dd->summa := str(arr[i,2,k,6],10,2)
      if k <= len(arr_vrach)
        dd->vrach := arr_vrach[k]
      endif
      if k <= len(arr_diagnoz)
        dd->diagnoz := arr_diagnoz[k]
      endif
      s += date_8(arr[i,2,k,1])+" "+;
           arr[i,2,k,2]+" "+;
           arr[i,2,k,3]+" "+;
           arr[i,2,k,4]+;
           str(arr[i,2,k,6]/arr[i,2,k,5],8,2)+;
           str(arr[i,2,k,5],5)+;
           str(arr[i,2,k,6],11,2)
      if verify_FF(HH,.t.,sh)
        aeval(arr2title, {|x| add_string(x) } )
      endif
      add_string(s)
      lsk += arr[i,2,k,5]
      lss += arr[i,2,k,6]
      sk += arr[i,2,k,5]
      ss += arr[i,2,k,6]
    next
    for k := len(arr[i,2])+1 to max(kfio,kpolis)
      s := space(4)
      s += padr(iif(k <= kfio, afio[k], ""), lfio)+" "
      s += padr(iif(k <= kpolis, apolis[k], ""), 17)
      if verify_FF(HH,.t.,sh)
        aeval(arr2title, {|x| add_string(x) } )
      endif
      add_string(s)
    next
    add_string(padl(replicate("-",41),sh))
    add_string(padl(lstr(lsk)+str(lss,11,2),sh-12))
    add_string("")
  next
  select TMP
  skip
enddo
perso->(dbCloseArea())
dd->(dbCloseArea())
hp->(dbCloseArea())
hpu->(dbCloseArea())
usl->(dbCloseArea())
otd->(dbCloseArea())
if verify_FF(HH-5,.t.,sh)
  aeval(arr2title, {|x| add_string(x) } )
endif
add_string(replicate("─",sh))
add_string(padl("Итого : "+lstr(sk)+str(ss,11,2),sh-12))
add_string("")
add_string("")
add_string(center("Главный врач _________________                         Главный бухгалтер _________________",sh))
fclose(fp)
rest_box(buf)
Private yes_albom := .t.
viewtext(name_file,,,,(sh>80),,,reg_print)
n_message({"Создан файл: "+d_file+" (для загрузки в Excel)"},,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
return NIL

*

*****
Function pl_pl_1dogovor(k)
static si := 1
Local mas_pmt := {"~С кодами врачей",;
                  "С фамилиями ~врачей"}
Local mas_fun := {"pl_1dogovor(1)",;
                  "pl_1dogovor(2)"}
DEFAULT k TO 0
private kk := k
if k == 0
  popup_prompt(T_ROW,T_COL+5,si,mas_pmt,,mas_fun)
else
  si := k
  do case
  case k == 1
    pl_pl_2dogovor(1)
  case k == 2
    pl_pl_2dogovor(2)
  endcase
endif
return NIL

*

***** 01.03.19
Function pl_pl_dogovor()
Local buf := save_row(maxrow()), sh, HH := 49, arr_title, s, i, j, k, sk, ss,;
      arr2title, reg_print := 6, afio[10], lfio := 19, kfio, lsk, lss, adbf,;
      aadres[2], kadres, apolis[10], kpolis, name_file := "jurnal.txt", arr_dms,;
      kol_vo := 0, usl_nds18 := 0, usl_nds18_1 := 0,;
      usl_nds10 := 0, usl_nds10_1 := 0,;
      usl_nds20 := 0, usl_nds20_1 := 0
arr_title := {;
"─────────────────────────────┬───────┬─────────────────────────────────────────────────────────────────┬───────┬────┬──────────┬──────────┬──────────",;
"        Ф.И.О., адрес        │ НОМЕР │                   Название медицинской услуги                   │  Цена │Кол.│ Сумма за │   Дата   │   Срок   ",;
"        застрахованного      │медицин│                                                                 │ каждой│оказ│все кол-во│  приема  │ оказания ",;
"                             │ карты │                                                                 │ услуги│ус- │оказ.услуг│   мед.   │   мед.   ",;
"                             │       │                                                                 │ (руб.)│луг │  (руб.)  │  услуги  │  услуги  ",;
"─────────────────────────────┴───────┴─────────────────────────────────────────────────────────────────┴───────┴────┴──────────┴──────────┴──────────"}
Private krvz
if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) == NIL
  return NIL
endif
mywait()
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
R_Use(dir_server+"organiz",,"ORG")
add_string(center("Ж У Р Н А Л",sh))
add_string(center("учета заказов граждан на оказание им платных медицинских услуг(помощи)",sh))
add_string(center(arr_m[4],sh))
tit_tip_usl(krvz,arr_dms,sh)
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HPU")
R_Use(dir_server+"hum_p",,"HU")
aeval(arr_title, {|x| add_string(x) } )
j := sk := ss := 0
select HU
go top
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if arr_m[5] <= hu->N_data .and. hu->n_data <= arr_m[6] .and.;
     ascan(krvz,hu->tip_usl) > 0 ;//16.04.08
     .and. f_is_uch(st_a_uch,hu->lpu)//16.05.09
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
        if glob_mo[_MO_KOD_TFOMS] == '171004' // КБ-4
          add_string(afio[1]+" "+;
                     padr(lstr(hu->kod_k),7)+" "+;
                     padr(usl->full_name,65)+" "+put_kop(hpu->u_cena,7)+" "+;
                     padr(lstr(hpu->kol),4)+" "+put_kop(hpu->stoim,10)+" "+;
                     full_date(c4tod(hu->Pdate))+" "+full_date(c4tod(hpu->date_u)))

        else
          add_string(afio[1]+" "+;
                     padr(lstr(hu->kod_k),7)+" "+;
                     padr(usl->name,65)+" "+put_kop(hpu->u_cena,7)+" "+;
                     padr(lstr(hpu->kol),4)+" "+put_kop(hpu->stoim,10)+" "+;
                     full_date(c4tod(hu->Pdate))+" "+full_date(c4tod(hpu->date_u)))
        endif
        i := 1
        ++kol_vo
      else
        ++i
        if glob_mo[_MO_KOD_TFOMS] == '171004' // КБ-4
          add_string(iif(i<=kfio,afio[i],space(29))+" "+;
                     space(7)+" "+;
                     padr(usl->full_name,65)+" "+put_kop(hpu->u_cena,7)+" "+;
                     padr(lstr(hpu->kol),4)+" "+put_kop(hpu->stoim,10)+" "+;
                     full_date(c4tod(hu->Pdate))+" "+full_date(c4tod(hpu->date_u)))
        else
          add_string(iif(i<=kfio,afio[i],space(29))+" "+;
                     space(7)+" "+;
                     padr(usl->name,65)+" "+put_kop(hpu->u_cena,7)+" "+;
                     padr(lstr(hpu->kol),4)+" "+put_kop(hpu->stoim,10)+" "+;
                     full_date(c4tod(hu->Pdate))+" "+full_date(c4tod(hpu->date_u)))
        endif
      endif
      select HPU
      // Выборка НДС 18/10/20
      // возраст
      if fv_dog_date_r(hu->n_data,kart->date_r) > 0 // дети
        if round_5(usl->pnds_d,0) == 18
          usl_nds18 := usl_nds18+hpu->kol
          usl_nds18_1 := usl_nds18_1+hpu->stoim
        elseif round_5(usl->pnds_d,0) == 10
          usl_nds10 := usl_nds10+hpu->kol
          usl_nds10_1 := usl_nds10_1+hpu->stoim
        elseif round_5(usl->pnds_d,0) == 20
          usl_nds20 := usl_nds20+hpu->kol
          usl_nds20_1 := usl_nds20_1+hpu->stoim
        endif
      else
        if round_5(usl->pnds,0) == 18
          usl_nds18 := usl_nds18+hpu->kol
          usl_nds18_1 := usl_nds18_1+hpu->stoim
        elseif round_5(usl->pnds,0) == 10
          usl_nds10 := usl_nds10+hpu->kol
          usl_nds10_1 := usl_nds10_1+hpu->stoim
        elseif round_5(usl->pnds,0) == 20
          usl_nds20 := usl_nds20+hpu->kol
          usl_nds20_1 := usl_nds20_1+hpu->stoim
        endif
      endif
      //
      skip
    enddo
    if i == 1
      add_string(iif(1<kfio,afio[2],space(29)))
    endif
  endif
  select HU
  skip
enddo
close databases
add_string(replicate("─",sh))
add_string(padl("Итого : "+str(ss,11,2),sh-12))
add_string(padl("Итого договоров: "+str(kol_vo,11),sh-12))
if usl_nds18 > 0
  add_string(padl("Количество услуг с НДС 18% : "+str(usl_nds18,11),sh-12))
endif
if usl_nds18_1 > 0
  add_string(padl("Сумма услуг с НДС 18% : "+str(usl_nds18_1,11,2),sh-12))
endif
if usl_nds10 > 0
  add_string(padl("Количество услуг с НДС 10% : "+str(usl_nds10,11),sh-12))
endif
if usl_nds10_1 > 0
  add_string(padl("Сумма услуг с НДС 10% : "+str(usl_nds10_1,11,2),sh-12))
endif
if usl_nds20 > 0
  add_string(padl("Количество услуг с НДС 20% : "+str(usl_nds20,11),sh-12))
endif
if usl_nds20_1 > 0
  add_string(padl("Сумма услуг с НДС 20% : "+str(usl_nds20_1,11,2),sh-12))
endif
add_string("")
add_string(center("Главный врач _________________                         Главный бухгалтер _________________",sh))
fclose(fp)
rest_box(buf)
Private yes_albom := .t.
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL


*


***** 01.03.19
Function pl_pl_2dogovor()
Local buf := save_row(maxrow()), sh, HH := 49, arr_title, s, i, k, sk, ss,;
      arr2title, reg_print := 6, afio[10], lfio := 19, kfio, lsk, lss, adbf,;
      aadres[2], kadres, apolis[10], kpolis, name_file := "jurnal1.txt",;
      usl_nds18 := 0, usl_nds18_1 := 0,;
      usl_nds10 := 0, usl_nds10_1 := 0,;
      usl_nds20 := 0, usl_nds20_1 := 0,;
      t_vr, t_as, t_nvr, t_nas, arr_dms, kol_vo := 0,;
      nom_prihod
arr_title := {;
"─────────────────────────────",;
"        Ф.И.О., адрес        ",;
"        застрахованного      ",;
"                             ",;
"                             ",;
"─────────────────────────────"}
// номер карты
arr_1 := {;
"┬──────────",;
"│   Дата   ",;
"│ рождения ",;
"│          ",;
"│          ",;
"┴──────────"}
// номер карты
arr_2 := {;
 "┬───────",;
 "│ НОМЕР ",;
 "│медицин",;
 "│ карты ",;
 "│       ",;
 "┴───────"}
// номер договора
arr_3 := {;
 "┬─────────",;
 "│  НОМЕР  ",;
 "│         ",;
 "│договора ",;
 "│         ",;
 "┴─────────"}
//номер чека
arr_4 := {;
 "┬──────",;
 "│НОМЕР ",;
 "│      ",;
 "│ чека ",;
 "│      ",;
 "┴──────"}
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
 "┬───────────────────────────────────────────────────",;
 "│                                                   ",;
 "│       Вид (наименование) медицинской услуги       ",;
 "│                                                   ",;
 "│                                                   ",;
 "┴───────────────────────────────────────────────────"}

// дата оплаты услуги
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
arr_9 := {;
 "┬───────────────",;
 "│               ",;
 "│     Врач      ",;
 "├───────────────",;
 "│     М/с       ",;
 "┴───────────────"}
// фио врача+м/с
arr_10 := {;
 "┬───────────────",;
 "│Ф.И.О специали-",;
 "│ ста оказавшего",;
 "│  мед. услугу  ",;
 "│               ",;
 "┴───────────────"}
// цена услуги
arr_11 := {;
 "┬───────",;
 "│  Цена ",;
 "│ каждой",;
 "│ услуги",;
 "│ (руб.)",;
 "┴───────"}
// цена услуги
arr_12 := {;
 "┬───────",;
 "│Стоимо-",;
 "│  сть  ",;
 "│ услуги",;
 "│ (руб.)",;
 "┴───────"}
// количество услуг
arr_13 := {;
 "┬────",;
 "│Кол.",;
 "│оказ",;
 "│ус- ",;
 "│луг ",;
 "┴────"}
arr_14 := {;
 "┬──────────",;
 "│   Дата   ",;
 "│  оплаты  ",;
 "│   мед.   ",;
 "│  услуги  ",;
 "┴──────────"}
// дата оказания услуги
arr_15 := {;
 "┬──────────",;
 "│   Дата   ",;
 "│ оказания ",;
 "│ (приёма) ",;
 "│мед.услуги",;
 "┴──────────"}
// сумма услуг
arr_00 := {;
 "┬──────────",;
 "│ Сумма за ",;
 "│все кол-во",;
 "│оказ.услуг",;
 "│  (руб.)  ",;
 "┴──────────"}
arr_01 := {;
 "┬──────────",;
 "│   Срок   ",;
 "│ оказания ",;
 "│   мед.   ",;
 "│  услуги  ",;
 "┴──────────"}

Private krvz
if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
Private glob_pozic
if (glob_pozic := inputNplpozic(T_ROW,T_COL+5)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) == NIL
  return NIL
endif
mywait()
// создаем заголовок
for i := 0 to 14
  if f_is_pozic(glob_pozic,i)
    for j := 1 to 6
      arr_title[j] += &("arr_"+lstr(i+1)+"[j]")
    next
  endif
next
for j := 1 to 6
  arr_title[j] += arr_00[j]
  arr_title[j] += arr_01[j]
next
//
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
//R_Use(dir_server+"kas_usld",,"PUSL",,,.T.)
//index on str(u_kod,4) to tmp_ud
R_Use(dir_server+"mo_pers",,"perso")
R_Use(dir_server+"organiz",,"ORG")
add_string(center("Ж У Р Н А Л",sh))
add_string(center("учета заказов граждан на предоставление им платных медицинских услуг(помощи)",sh))
add_string(center(arr_m[4],sh))
tit_tip_usl(krvz,arr_dms,sh)
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HPU")
R_Use(dir_server+"hum_p",,"HU")
index on pdate+str(kv_cia,6) to (cur_dir+"tmp_hum") for between(pdate,arr_m[7],arr_m[8])
set index to (dir_server+"hum_pkk"),(cur_dir+"tmp_hum")
set order to 2
//
aeval(arr_title, {|x| add_string(x) } )
j := sk := ss := 0
select HU
go top
do while !eof()
  if ascan(krvz,hu->tip_usl) > 0 .and. f_is_uch(st_a_uch,hu->lpu)
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    ss += hu->cena
    if f_is_pozic(glob_pozic,1)
      nom_prihod := 0
      t_recno := hu->(recno())
      //index on str(kod_k,7)+dtos(k_data) to (dir_server+"hum_pkk") descending progress
      kart_kod := hu->kod_k
      t_k_data := year(hu->k_data)
      set order to 1
      select HU
      do while hu->kod_k == kart_kod .and.;
               year(hu->k_data) == t_k_data .and. !eof()
        ++nom_prihod
        skip
      enddo
      set order to 2
      goto t_recno
    endif
    //
    select KART
    goto hu->kod_k
    kfio := perenos(afio,alltrim(kart->fio)+" "+alltrim(kart->adres),29)
    fl_hu := .T.
    select HPU
    t_kod := hu->(recno())
    find (str(t_kod,7))
    do while t_kod==hpu->kod .and. !eof()
      usl->(dbGoto(hpu->u_kod))
      select perso
      goto (hpu->kod_vr)
      t_vr := perso->tab_nom
      t_nvr := fam_i_o(perso->fio)
      goto (hpu->kod_as)
      t_as := perso->tab_nom
      if fl_hu
        fl_hu := .F.
        //goto (hpu->kod_as)
        //t_nas := "  "//fam_i_o(perso->fio)
        //
        if glob_mo[_MO_KOD_TFOMS] == '171004' // КБ-4
          add_string(afio[1]+" "+;
                     iif(f_is_pozic(glob_pozic,0),full_date(kart->date_r)+" ","")+;
                     iif(f_is_pozic(glob_pozic,1),padr(lstr(hu->kod_k),7)+" ","")+;
                     iif(f_is_pozic(glob_pozic,2),padr(lstr(hu->kod_k)+"/"+lstr(nom_prihod),9)+" ","")+;
                     iif(f_is_pozic(glob_pozic,3),padr(lstr(hu->kv_cia),6)+" ","")+;
                     iif(f_is_pozic(glob_pozic,4),usl->shifr+" ","")+;
                     iif(f_is_pozic(glob_pozic,5),padr(alltrim(usl->full_name),51)+" ","")+;
                     iif(f_is_pozic(glob_pozic,6),iif(t_vr>0,padl(lstr(t_vr),5),space(5))+" ","")+;
                     iif(f_is_pozic(glob_pozic,7),iif(t_as>0,padr(lstr(t_as),5),space(5))+" ","")+;
                     iif(f_is_pozic(glob_pozic,8),padr(t_nvr,15)+" ","")+;
                     iif(f_is_pozic(glob_pozic,9),padr(t_nvr,15)+" ","")+;
                     iif(f_is_pozic(glob_pozic,10),put_kop(hpu->u_cena,7)+" ","")+;
                     iif(f_is_pozic(glob_pozic,11),put_kop(hpu->u_cena,7)+" ","")+;
                     iif(f_is_pozic(glob_pozic,12),padr(lstr(hpu->kol),4)+" ","")+;
                     iif(f_is_pozic(glob_pozic,13),iif(hu->kv_cia > 0,full_date(c4tod(hu->pdate)),space(10))+" ","")+;
                     iif(f_is_pozic(glob_pozic,14),full_date(c4tod(hpu->date_u))+" ","")+;
                     put_kop(hpu->stoim,10)+" "+;
                     full_date(c4tod(hpu->date_u)))
        else
          add_string(afio[1]+" "+;
                     iif(f_is_pozic(glob_pozic,0),full_date(kart->date_r)+" ","")+;
                     iif(f_is_pozic(glob_pozic,1),padr(lstr(hu->kod_k),7)+" ","")+;
                     iif(f_is_pozic(glob_pozic,2),padr(lstr(hu->kod_k)+"/"+lstr(nom_prihod),9)+" ","")+;
                     iif(f_is_pozic(glob_pozic,3),padr(lstr(hu->kv_cia),6)+" ","")+;
                     iif(f_is_pozic(glob_pozic,4),usl->shifr+" ","")+;
                     iif(f_is_pozic(glob_pozic,5),padr(alltrim(usl->name),51)+" ","")+;
                     iif(f_is_pozic(glob_pozic,6),iif(t_vr>0,padl(lstr(t_vr),5),space(5))+" ","")+;
                     iif(f_is_pozic(glob_pozic,7),iif(t_as>0,padr(lstr(t_as),5),space(5))+" ","")+;
                     iif(f_is_pozic(glob_pozic,8),padr(t_nvr,15)+" ","")+;
                     iif(f_is_pozic(glob_pozic,9),padr(t_nvr,15)+" ","")+;
                     iif(f_is_pozic(glob_pozic,10),put_kop(hpu->u_cena,7)+" ","")+;
                     iif(f_is_pozic(glob_pozic,11),put_kop(hpu->u_cena,7)+" ","")+;
                     iif(f_is_pozic(glob_pozic,12),padr(lstr(hpu->kol),4)+" ","")+;
                     iif(f_is_pozic(glob_pozic,13),full_date(c4tod(hu->pdate))+" ","")+;
                     iif(f_is_pozic(glob_pozic,14),full_date(c4tod(hpu->date_u))+" ","")+;
                     put_kop(hpu->stoim,10)+" "+;
                     full_date(c4tod(hpu->date_u)))
        endif
        i := 1
        ++kol_vo
      else
        ++i
        if glob_mo[_MO_KOD_TFOMS] == '171004' // КБ-4
          add_string(iif(i<=kfio,afio[i],space(29))+" "+;
                     iif(f_is_pozic(glob_pozic,0),space(11),"")+;
                     iif(f_is_pozic(glob_pozic,1),space(8),"")+;
                     iif(f_is_pozic(glob_pozic,2),space(10),"")+;
                     iif(f_is_pozic(glob_pozic,3),space(7),"")+;
                     iif(f_is_pozic(glob_pozic,4),usl->shifr+" ","")+;
                     iif(f_is_pozic(glob_pozic,5),padr(alltrim(usl->full_name),51)+" ","")+;
                     iif(f_is_pozic(glob_pozic,6),iif(t_vr>0,padl(lstr(t_vr),5),space(5))+" ","")+;
                     iif(f_is_pozic(glob_pozic,7),iif(t_as>0,padl(lstr(t_as),5),space(5))+" ","")+;
                     iif(f_is_pozic(glob_pozic,8),padr(t_nvr,15)+" ","")+;
                     iif(f_is_pozic(glob_pozic,9),padr(t_nvr,15)+" ","")+;
                     iif(f_is_pozic(glob_pozic,10),put_kop(hpu->u_cena,7)+" ","")+;
                     iif(f_is_pozic(glob_pozic,11),put_kop(hpu->u_cena,7)+" ","")+;
                     iif(f_is_pozic(glob_pozic,12),padr(lstr(hpu->kol),4)+" ","")+;
                     iif(f_is_pozic(glob_pozic,13),space(10)+" ","")+;
                     iif(f_is_pozic(glob_pozic,14),full_date(c4tod(hpu->date_u))+" ","")+;
                     put_kop(hpu->stoim,10)+" "+;
                     full_date(c4tod(hpu->date_u)))
        else
          add_string(iif(i<=kfio,afio[i],space(29))+" "+;
                     iif(f_is_pozic(glob_pozic,0),space(11),"")+;
                     iif(f_is_pozic(glob_pozic,1),space(8),"")+;
                     iif(f_is_pozic(glob_pozic,2),space(10),"")+;
                     iif(f_is_pozic(glob_pozic,3),space(7),"")+;
                     iif(f_is_pozic(glob_pozic,4),usl->shifr+" ","")+;
                     iif(f_is_pozic(glob_pozic,5),padr(alltrim(usl->name),51)+" ","")+;
                     iif(f_is_pozic(glob_pozic,6),iif(t_vr>0,padl(lstr(t_vr),5),space(5))+" ","")+;
                     iif(f_is_pozic(glob_pozic,7),iif(t_as>0,padl(lstr(t_as),5),space(5))+" ","")+;
                     iif(f_is_pozic(glob_pozic,8),padr(t_nvr,15)+" ","")+;
                     iif(f_is_pozic(glob_pozic,9),padr(t_nvr,15)+" ","")+;
                     iif(f_is_pozic(glob_pozic,10),put_kop(hpu->u_cena,7)+" ","")+;
                     iif(f_is_pozic(glob_pozic,11),put_kop(hpu->u_cena,7)+" ","")+;
                     iif(f_is_pozic(glob_pozic,12),padr(lstr(hpu->kol),4)+" ","")+;
                     iif(f_is_pozic(glob_pozic,13),space(10)+" ","")+;
                     iif(f_is_pozic(glob_pozic,14),full_date(c4tod(hpu->date_u))+" ","")+;
                     put_kop(hpu->stoim,10)+" "+;
                     full_date(c4tod(hpu->date_u)))
        endif
      endif
      select HPU
      // Выборка НДС 18/10/20
      // возраст
      if fv_dog_date_r(hu->n_data,kart->date_r) > 0 // дети
        if round_5(usl->pnds_d,0) == 18
          usl_nds18 := usl_nds18+hpu->kol
          usl_nds18_1 := usl_nds18_1+hpu->stoim
        elseif round_5(usl->pnds_d,0) == 10
          usl_nds10 := usl_nds10+hpu->kol
          usl_nds10_1 := usl_nds10_1+hpu->stoim
        elseif round_5(usl->pnds_d,0) == 20
          usl_nds20 := usl_nds20+hpu->kol
          usl_nds20_1 := usl_nds20_1+hpu->stoim
        endif
      else
        if round_5(usl->pnds,0) == 18
          usl_nds18 := usl_nds18+hpu->kol
          usl_nds18_1 := usl_nds18_1+hpu->stoim
        elseif round_5(usl->pnds,0) == 10
          usl_nds10 := usl_nds10+hpu->kol
          usl_nds10_1 := usl_nds10_1+hpu->stoim
        elseif round_5(usl->pnds,0) == 20
          usl_nds20 := usl_nds20+hpu->kol
          usl_nds20_1 := usl_nds20_1+hpu->stoim
        endif
      endif
      skip
    enddo
    if i == 1 .and. 1<kfio
      add_string(afio[2])
    endif
  endif
//  if mem_dop_st == 2
//    add_string("")
//  endif
  select HU
  skip
enddo
close databases
add_string(replicate("─",sh))
add_string(padl("Итого : "+lstr(ss,15,2),sh-11))
add_string(padl("Итого договоров : "+lstr(kol_vo),sh-11))
if usl_nds18 > 0
  add_string(padl("Количество услуг с НДС 18% : "+str(usl_nds18,11),sh-11))
endif
if usl_nds18_1 > 0
  add_string(padl("Сумма услуг с НДС 18% : "+str(usl_nds18_1,11,2),sh-11))
endif
if usl_nds10 > 0
  add_string(padl("Количество услуг с НДС 10% : "+str(usl_nds10,11),sh-11))
endif
if usl_nds10_1 > 0
  add_string(padl("Сумма услуг с НДС 10% : "+str(usl_nds10_1,11,2),sh-11))
endif
if usl_nds20 > 0
  add_string(padl("Количество услуг с НДС 20% : "+str(usl_nds20,11),sh-12))
endif
if usl_nds20_1 > 0
  add_string(padl("Сумма услуг с НДС 20% : "+str(usl_nds20_1,11,2),sh-12))
endif
add_string("")
add_string("")
add_string(center("Главный врач _________________                         Главный бухгалтер _________________",sh))
fclose(fp)
rest_box(buf)
Private yes_albom := .t.
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL


*

***** 18.11.16 определение критерия "взрослый/ребёнок"
Function fv_dog_date_r(_data,ldate_r)
Local k, cy
cy := count_years(ldate_r,_data)
if cy < 18 ; k := 1  // подросток+ребенок
else       ; k := 0  // взрослый
endif
return k

*

*****
Static Function add_diagnoz(ar)
if !empty(hp->KOD_DIAG) .and. ascan(ar,hp->KOD_DIAG) == 0
  aadd(ar,hp->KOD_DIAG)
endif
if !empty(hp->SOPUT_B1) .and. ascan(ar,hp->SOPUT_B1) == 0
  aadd(ar,hp->SOPUT_B1)
endif
if !empty(hp->SOPUT_B2) .and. ascan(ar,hp->SOPUT_B2) == 0
  aadd(ar,hp->SOPUT_B2)
endif
if !empty(hp->SOPUT_B3) .and. ascan(ar,hp->SOPUT_B3) == 0
  aadd(ar,hp->SOPUT_B3)
endif
if !empty(hp->SOPUT_B4) .and. ascan(ar,hp->SOPUT_B4) == 0
  aadd(ar,hp->SOPUT_B4)
endif
if !empty(hp->SOPUT_B5) .and. ascan(ar,hp->SOPUT_B5) == 0
  aadd(ar,hp->SOPUT_B5)
endif
return NIL

*****
Static Function add_vrach(ar,lkod_vr)
if !empty(lkod_vr) .and. ascan(ar,lkod_vr) == 0
  aadd(ar,lkod_vr)
endif
return NIL

*****
Static Function ret_arr_vrach(ar)
Local i, arr := {}
for i := 1 to len(ar)
  perso->(dbGoto(ar[i]))
  aadd(arr,fam_i_o(perso->fio))
next
asort(arr)
return arr

*
***** 02.05.18
Function pl1_priemden(tip)
//  1 - сводный
//  2 - по кассовым аппаратам
//  3 - по кассирам
Local fl := .t., buf := save_row(maxrow()), sm := 0, HH := 52,;
      n_file := "platn.txt", arr_m, sum3 := 0, sh, sm_sn := 0, arr_dms,;
      sm_1 := 0, sm_2 := 0, vrem_kas, sm1, sm2, t_name_ysl, mas_name := {}
Local arr_title := {;
  "──────────────────────────────────────────────────────────┬────────┬───────────",;
  "                          Услуги                          │ Кол-во │   Сумма   ",;
  "──────────────────────────────────────────────────────────┴────────┴───────────";
  }
sh := len(arr_title[1])
Private krvz
if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
//
mywait()
dbcreate(cur_dir+"tmp", {{"kod",        "N",  4,  0},;
                         {"name",       "C", 65,  0},;
                         {"full_name",  "C",120,  0},;
                         {"kod_1",      "C", 10,  0},;
                         {"kol_vo",     "N", 10,  0},;
                         {"summa",      "N", 12,  2},;
                         {"operat",     "N",  3,  0},;
                         {"operatf",    "C", 40,  0},;
                         {"FR_zavod",   "C", 16,  0};
                         })
use (cur_dir+"tmp") new
if tip == 1
  index on str(kod,4) to (cur_dir+"tmp_u")
elseif tip == 2
  index on str(kod,4)+fr_zavod to (cur_dir+"tmp_u")
else
  index on str(kod,4)+str(operat,3) to (cur_dir+"tmp_u")
endif
if yes_parol
  R_Use(dir_server+"base1",,"BASE1")
endif
R_Use(dir_server+"hum_p",,"HUM")
R_Use(dir_server+"hum_p_U",dir_server+"hum_p_U","HUM_U")
select HUM
go top
sum3 := 0
do while !eof()
  if arr_m[5] <= hum->N_data .and. hum->n_data <= arr_m[6] .AND.;
     ascan(krvz,hum->tip_usl) > 0 //16.04.08
  //  sum3 += hum->cena    // 16.06.08
    sm_sn += hum->SUM_VOZ  // 16.06.08
    t := hum->(RECNO())
    select HUM_U
    find (str(t,7))
    do while t == hum_u->kod .and. !eof()
      select TMP
      if tip == 1
        find (str(hum_u->u_kod,4))
      elseif tip == 2
        find (str(hum_u->u_kod,4)+hum->FR_zavod)
      else
        find (str(hum_u->u_kod,4)+str(hum->KOD_OPER,3))
      endif
      if !found()
        append blank
        tmp->kod      := hum_u->u_kod
        tmp->operat   := hum->KOD_OPER
        tmp->FR_zavod := hum->FR_zavod
      endif
      if yes_parol .and. hum->KOD_OPER > 0
        select BASE1
        goto (hum->KOD_OPER)
        if !eof() .and. !empty(base1->p1)
          tmp->operatf := alltrim(crypt(base1->p1,gpasskod))
        endif
      endif
      tmp->kol_vo := tmp->kol_vo + hum_u->kol
      tmp->summa  := tmp->summa  + hum_u->stoim
      select HUM_U
      skip
    enddo
  endif
  select HUM
  skip
enddo
//
R_Use(dir_server+"uslugi",,"USL")
select TMP
go top
do while !eof()
  t := tmp->kod
  select usl
  goto t
  select tmp
  tmp->name       := usl->name
  tmp->full_name  := usl->full_name
  tmp->kod_1      := usl->shifr
  skip
enddo
select TMP
index on kod_1 to (cur_dir+"tmp_u")
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(center("Оплата услуг",sh))
add_string(center("по дате начала лечения",sh))
if tip == 3
  add_string(center("с группировкой по кассирам",sh))
elseif tip == 2
  add_string(center("с группировкой по кассовым аппаратам",sh))
endif
add_string(center(arr_m[4],sh))
tit_tip_usl(krvz,arr_dms,sh) //16.04.08
add_string("")
aeval(arr_title, {|x| add_string(x) })
if tip == 1
  index on kod_1 to (cur_dir+"tmp_u")
elseif tip == 2
  index on fr_zavod+kod_1 to (cur_dir+"tmp_u")
else
  index on operatf+kod_1 to (cur_dir+"tmp_u")
endif
go top
sm1 := 0
sm2 := 0
if tip == 3
  vrem_kas := tmp->operatf
elseif tip == 2
  vrem_kas := tmp->FR_zavod
endif
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if tip == 3
    if vrem_kas != tmp->operatf
      add_string(replicate("─",sh))
      add_string(padR("Итого кассир: "+vrem_kas,58)+;
                   STR(SM_1,9)+;
                   put_kope(SM_2,12))
      add_string("")
      //add_string(replicate("─",sh))                 // 16.06.08
      //add_string(padR("из них возврат: ",59)+;
      //             put_kope(sm_sn,12))
      vrem_kas := tmp->operatf
      sm_1 := 0
      sm_2 := 0
    endif
  elseif tip == 2
    if vrem_kas != tmp->FR_zavod
      add_string(replicate("─",sh))
      add_string(padR("Итого касса №: "+vrem_kas,58)+;
                   STR(SM_1,9)+;
                   put_kope(SM_2,12))
      add_string("")
      //add_string(replicate("─",sh))                 // 16.06.08
      //add_string(padR("из них возврат: ",59)+;
      //             put_kope(sm_sn,12))
      vrem_kas := tmp->FR_zavod
      sm_1 := 0
      sm_2 := 0
    endif
  endif
  if !empty(tmp->full_name)
    t_name_ysl := tmp->full_name
  else
    t_name_ysl := tmp->name
  endif
  for i := 1 to perenos(mas_name,t_name_ysl,48)
    if i == 1
      add_string(tmp->kod_1+padr(mas_name[i],48)+;
                 STR(tmp->kol_vo,9)+;
                 put_kope(tmp->summa,12))
    else
      add_string(space(10)+mas_name[i])
    endif
  next
  sm1 += tmp->kol_vo
  SM2 += tmp->summa
  sm_1 += tmp->kol_vo
  SM_2 += tmp->summa
  skip
enddo
if tip == 3
  add_string(replicate("─",sh))
  add_string(padR("Итого кассир: "+vrem_kas,58)+;
               STR(SM_1,9)+;
               put_kope(SM_2,12))
elseif tip == 2
  add_string(replicate("─",sh))
  add_string(padR("Итого касса №: "+vrem_kas,58)+;
               STR(SM_1,9)+;
               put_kope(SM_2,12))
endif
add_string(replicate("─",sh))
add_string(padR("Итого: ",58)+;
             STR(SM1,9)+;
             put_kope(SM2,12))
add_string(replicate("─",sh))                 // 16.06.08
add_string(padR("из них возврат: ",67)+;
             put_kope(sm_sn,12))
close databases
fclose(fp)
viewtext(n_file,,,,(sh>80),,,1)
rest_box(buf)
return NIL


*

***** 02.04.19
Function pl2_priemden(tip)
//  2 - по кассовым аппаратам
//  3 - по кассирам
Local fl := .t., buf := save_row(maxrow()), sm := 0, HH := 51,;
      n_file := "platn.txt", arr_m, sum3 := 0, sh, sm_sn := 0, arr_dms,;
      sm_1 := 0, sm_2 := 0, vrem_kas, sm1, sm2, t_name_ysl, mas_name := {},;
      t, t1

Local arr_title := {;
  "──────────────────────────────────────────────────────────┬────────────────────",;
  "                                                          │        ИТОГО       ",;
  "                          Услуги                          ├────────┬───────────",;
  "                                                          │ Кол-во │   Сумма   ",;
  "──────────────────────────────────────────────────────────┴────────┴───────────";
  }
Local arr_1title := {;
  "┬────────────────────",;
  "│",;
  "├────────┬───────────",;
  "│ Кол-во │   Сумма   ",;
  "┴────────┴───────────";
  }
Private krvz, lpole, spole
Private arr_kkm := {}
if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
//
mywait()
dbcreate(cur_dir+"tmp", {{"kod",        "N",  4,  0},;
                         {"name",       "C", 65,  0},;
                         {"full_name",  "C",120,  0},;
                         {"kod_1",      "C", 10,  0},;
                         {"kol_vo",     "N", 10,  0},;
                         {"summa",      "N", 12,  2},;
                         {"operat",     "N",  3,  0},;
                         {"operatf",    "C", 40,  0},;
                         {"summa1",     "N", 12,  2},;
                         {"kol_vo1",    "N", 10,  0},;
                         {"summa2",     "N", 12,  2},;
                         {"kol_vo2",    "N", 10,  0},;
                         {"summa3",     "N", 12,  2},;
                         {"kol_vo3",    "N", 10,  0},;
                         {"summa4",     "N", 12,  2},;
                         {"kol_vo4",    "N", 10,  0},;
                         {"summa5",     "N", 12,  2},;
                         {"kol_vo5",    "N", 10,  0},;
                         {"summa6",     "N", 12,  2},;
                         {"kol_vo6",    "N", 10,  0},;
                         {"summa7",     "N", 12,  2},;
                         {"kol_vo7",    "N", 10,  0},;
                         {"summa8",     "N", 12,  2},;
                         {"kol_vo8",    "N", 10,  0};
                         })
use (cur_dir+"tmp") new
index on str(kod,4) to (cur_dir+"tmp_u")
R_Use(dir_server+"hum_p",,"HUM")
R_Use(dir_server+"hum_p_U",dir_server+"hum_p_U","HUM_U")
select HUM
go top
sum3 := 0
do while !eof()
  if arr_m[5] <= hum->N_data .and. hum->n_data <= arr_m[6] .AND.;
     ascan(krvz,hum->tip_usl) > 0 //16.04.08
    //sm_sn += hum->SUM_VOZ  // 16.06.08
    t := hum->(RECNO())
    select HUM_U
    find (str(t,7))
    do while t == hum_u->kod .and. !eof()
      select TMP
      find (str(hum_u->u_kod,4)+hum->FR_zavod)
      if !found()
        append blank
        tmp->kod      := hum_u->u_kod
        tmp->operat   := hum->KOD_OPER
      endif
      tmp->kol_vo := tmp->kol_vo + hum_u->kol
      tmp->summa  := tmp->summa  + hum_u->stoim
      if (i := ascan(arr_kkm, {|x| alltrim(x[1]) == alltrim(hum->FR_zavod)})) == 0
        aadd(arr_kkm, {hum->FR_zavod,0,0})
        i := len(arr_kkm)
      endif
      t1 := lstr(i)
      Spole := "tmp->summa"+t1
      kpole := "tmp->kol_vo"+t1
      &spole := &spole + hum_u->stoim
      &kpole := &kpole + hum_u->kol
      select HUM_U
      skip
    enddo
  endif
  select HUM
  skip
enddo
//
R_Use(dir_server+"uslugi",,"USL")
select TMP
go top
do while !eof()
  t := tmp->kod
  select usl
  goto t
  select tmp
  tmp->name       := usl->name
  tmp->full_name  := usl->full_name
  tmp->kod_1      := usl->shifr
  skip
enddo
//
select TMP
index on kod_1 to (cur_dir+"tmp_u")
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
for i := 1 to len(arr_kkm)
  arr_title[1] := arr_title[1] + arr_1title[1]
  arr_title[2] := arr_title[2] + arr_1title[2]+ padc(alltrim(arr_kkm[i,1]),20)
  arr_title[3] := arr_title[3] + arr_1title[3]
  arr_title[4] := arr_title[4] + arr_1title[4]
  arr_title[5] := arr_title[5] + arr_1title[5]
next
sh := len(arr_title[1])
add_string(center("Оплата услуг",sh))
add_string(center("по дате начала лечения",sh))
add_string(center(arr_m[4],sh))
tit_tip_usl(krvz,arr_dms,sh) //16.04.08
add_string("")
aeval(arr_title, {|x| add_string(x) })
index on kod_1 to (cur_dir+"tmp_u")
go top
sm1 := 0
sm2 := 0
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  if !empty(tmp->full_name)
    t_name_ysl := tmp->full_name
  else
    t_name_ysl := tmp->name
  endif
  for i := 1 to perenos(mas_name,t_name_ysl,48)
    if i == 1
      t_str := tmp->kod_1+padr(mas_name[i],48)+;
                 STR(tmp->kol_vo,9)+;
                 put_kope(tmp->summa,12)
      for j := 1 to len(arr_kkm)
        t1 := lstr(j)
        Spole := "tmp->summa"+t1
        kpole := "tmp->kol_vo"+t1
        t_str += (STR(&kpole,9) + put_kope(&spole,12))
        arr_kkm[j,2] += &kpole
        arr_kkm[j,3] += &spole
      next
      add_string(t_str)
    else
      add_string(space(10)+mas_name[i])
    endif
  next
  sm1 += tmp->kol_vo
  SM2 += tmp->summa
  skip
enddo

add_string(replicate("─",sh))
t_str := padR("Итого: ",58)+;
             STR(SM1,9)+;
             put_kope(SM2,12)
for j := 1 to len(arr_kkm)
  t_str += (STR(arr_kkm[j,2],9) + put_kope(arr_kkm[j,3],12))
next
add_string(t_str)
add_string(replicate("─",sh))                 // 16.06.08
//add_string(padR("из них возврат: ",67)+;
//             put_kope(sm_sn,12))
close databases
fclose(fp)
Private yes_albom := .t.
viewtext(n_file,,,,(sh>80),,,6)
rest_box(buf)
return NIL


***** 02.12.12
Function inputNplpozic(r,c,fl_max)
Static st_pozic := {}
Local i, k, t_mas, ;
      buf := savescreen(), l_a_pozic
Local mas_s := {"Дата рождения",;
                "Номер карты",;
                "Номер договора",;
                "Номер чека",;
                "Шифр мед.услуги",;
                "Наименование мед.услуги",;
                "Код Врача",;
                "Код Медсестры",;
                "ФИО врача+м/с",;
                "ФИО специалиста",;
                "Цена услуги",;
                "Стоимость услуги",;
                "Количество услуг",;
                "Дата оплаты мед.услуги",;
                "Дата оказания мед.услуги"}

Local mas := {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
DEFAULT fl_max TO .f.
if (k := r + 14) > maxrow()-2
  k := maxrow()-2
endif
if c+35 > 77
  c := 77-35
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
    for i := 1 TO 15
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

***** 13.02.16
Function k_statist(k)
Static si := 1, si1 := 1, si2 := 1
Local mas_pmt := {"~Реестр доплат",;
                  "П~ерсонал + услуги",;
                  "У~слуги + персонал"}
Local mas_msg := {"Реестр доплат (за период времени)",;
                  "Статистика по работе персонала + оказанные услуги",;
                  "Статистика по оказанию конкретных услуг + персонал"}
Local mas_fun := {"k_statist(11)",;
                  "k_statist(12)",;
                  "k_statist(13)"}
Local i, buf
if k < 10
  pi := 2
else
  si := k
endif
do case
  case k < 10
    if glob_pl_reg == 1 .or. (type("mek_kassa")=="N" .and. mek_kassa == 2) //
      aadd(mas_pmt, "~Больные + квитанции")
      aadd(mas_msg, "Больные + квитанции")
      aadd(mas_fun, "k_statist(14)")
      //
      aadd(mas_pmt, "Больные + ~услуги")
      aadd(mas_msg, "Больные + услуги")
      aadd(mas_fun, "k_statist(15)")
      //
      aadd(mas_pmt, "~Книжки + квитанции")
      aadd(mas_msg, "Список квитанционных книжек (с диапазонами квитанций) за период времени")
      aadd(mas_fun, "k_statist(16)")
      //
      aadd(mas_pmt, "Сдача ~выручки")
      aadd(mas_msg, "Оформление реестра платных услуг при сдаче выручки")
      aadd(mas_fun, "k_statist(17)")
    endif
    popup_prompt(T_ROW,T_COL-5,si,mas_pmt,mas_msg,mas_fun)
  otherwise
    if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) != NIL
      do case
        case k == 11
          f1r_s_plat(1)
        case k == 12
          f2r_spl_plat(1)  // персонал + услуги по номеру квит.книжки
        case k == 13
          f2r_spl_plat(2)  // услуги + персонал по номеру квит.книжки
        case k == 14
          f3r_s_plat(1)  // больные + квитанции по номеру квит.книжки
        case k == 15
          f4r_s_plat(1)  // больные + услуги по номеру квит.книжки
        case k == 16
          f5r_s_plat()   // книжки + квитанции за период времени
        case k == 17
          Pl_vyruchka()
      endcase
    endif
endcase
return NIL

*

/*****
Function Pd_statist(k)
Static si := 1, si1 := 1, si2 := 1
Local mas_pmt := {"По ~отделениям и службам"}
Local mas_msg := {"Распределение доходов с разбивкой по отделениям и службам"}
Local mas_fun := {"Pd_statist(11)"}
Local i, buf
if k < 10
  pi := 4
else
  si := k
endif
do case
  case k < 10
    popup_prompt(T_ROW,T_COL-5,si,mas_pmt,mas_msg,mas_fun)
  otherwise
    if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) != NIL
      do case
        case k == 11
          Pd2_statist(1)
      endcase
    endif
endcase
return NIL

*****
Function Pd2_statist(k)
Local i, j, arr, begin_date, end_date, s, buf := save_row(maxrow()),;
      fl_exit := .f., sh, HH := 40, reg_print, speriod,;
      arr_title, name_file := "r_dohod"+stxt, arr_m
if (arr_m := year_month()) == NIL
  return NIL
endif
speriod := arr_m[4]
begin_date := arr_m[7]
end_date := arr_m[8]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
arr := {;
   {"TIP",        "N",      1,      0},;  // 1-отделение,2-служба
   {"KOD",        "N",      3,      0},;  // код отделения/службы
   {"NAME",       "C",     40,      0},;  // наименование
   {"STOIM",      "N",     18,      2};   // сумма
  }
Private p_arr := {}, len_m := 4
aeval(gmenu_scu, {|x| aadd(arr, {"s"+lstr(x[2]),"N",18,2} ),;
                      aadd(p_arr, {1,x[2],0} ) } )
aeval(gmenu1_scu, {|x| aadd(arr, {"z"+lstr(x[2]),"N",18,2} ),;
                       aadd(p_arr, {2,x[2],0} ) } )
dbcreate(cur_dir+"tmp", arr)
use (cur_dir+"tmp")
index on str(tip,1)+str(kod,3) to (cur_dir+"tmpk")
index on str(tip,1)+upper(name) to (cur_dir+"tmpn")
use (cur_dir+"tmp") index (cur_dir+"tmpk"),(cur_dir+"tmpn") alias TMP
//G_Use(dir_server+"cena_usl",dir_server+"cena_usl","CENA")
G_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
G_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
dbseek(dtos(arr_m[5]),.t.)
do while human->k_data <= arr_m[6] .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if f_is_uch(st_a_uch,human->lpu)
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno())
      d3_statist(k)
      select HU
      skip
    enddo
  endif
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений (или не настроен СТАНДАРТНЫЙ вид оплаты по конечному результату)!")
else
  G_Use(dir_server+"otdeleni",,"OTD")
  G_Use(dir_server+"slugba",dir_server+"slugba","SL")
  use (cur_dir+"tmp") index (cur_dir+"tmpk"),(cur_dir+"tmpn") new alias TMP
  go top
  do while !eof()
    if tmp->tip == 1
      select OTD
      goto (tmp->kod)
      tmp->name := otd->name
    else
      select SL
      find (str(tmp->kod,3))
      tmp->name := sl->name
    endif
    select TMP
    skip
  enddo
  mywait()
  reg_print := 3
  arr_title := {"","","",""}
  for i := 1 to len(gmenu_scu)
    perenos(arr,gmenu_scu[i,1],10)
    arr_title[1] += "──────────"            +if(i==len(gmenu_scu),"╥","┬")
    arr_title[2] += padc(alltrim(arr[1]),10)+if(i==len(gmenu_scu),"║","│")
    arr_title[3] += padc(alltrim(arr[2]),10)+if(i==len(gmenu_scu),"║","│")
    arr_title[4] += "──────────"            +if(i==len(gmenu_scu),"╨","┴")
  next
  for i := 1 to len(gmenu1_scu)
    perenos(arr,gmenu1_scu[i,1],10)
    arr_title[1] += "──────────"            +if(i==len(gmenu1_scu),"╥","┬")
    arr_title[2] += padc(alltrim(arr[1]),10)+if(i==len(gmenu1_scu),"║","│")
    arr_title[3] += padc(alltrim(arr[2]),10)+if(i==len(gmenu1_scu),"║","│")
    arr_title[4] += "──────────"            +if(i==len(gmenu1_scu),"╨","┴")
  next
  arr_title[1] += "──────────┬──────────────────────────────"
  arr_title[2] += "          │"
  arr_title[3] += "  ИТОГО   │  Наименование"
  arr_title[4] += "──────────┴──────────────────────────────"
  sh := len(arr_title[1])
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("ПЛАТНЫЕ УСЛУГИ")
  add_string(center("Распределение доходов по отделениям и службам",sh))
  titleN_uch(st_a_uch,sh)
  add_string("")
  add_string(center(speriod,sh))
  add_string(center("[ по дате окончания лечения ]",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  select TMP
  set order to 2
  arr := array(len(p_arr)+1)
  for j := 1 to 2
    afill(arr,0)
    find (str(j,1))
    do while tmp->tip == j
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      s := ""
      for i := 1 to len(p_arr)
        arr[i] += fieldget(i+len_m)
        s += put_kopE(fieldget(i+len_m),10)+" "
      next
      s += put_kopE(tmp->stoim,10)
      arr[len(p_arr)+1] += tmp->stoim
      add_string(s+"  "+rtrim(tmp->name))
      select TMP
      skip
    enddo
    add_string(replicate("─",sh))
    s := ""
    aeval(arr, {|x| s += put_kopE(x,10)+" " } )
    add_string(s)
    add_string("")
  next
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

*****
Static Function d3_statist(k)
Local mkod_usl := hu->u_kod, fl, i, kzrp, mkoef
do case
  case k == 1
    fl := .f.
    do while .t.
      select USL
      goto (mkod_usl)
      if eof() ; exit ; endif  // неудачное перемещение по БД услуг
      kzrp := 0
      select CENA
      find (str(mkod_usl,4)+"11")  // ищем зарплату
      if (fl := found())
        for i := 1 to len(p_arr)
          find (str(mkod_usl,4)+str(p_arr[i,1],1)+str(p_arr[i,2],1))
          if found()
            if p_arr[i,1] == 1  // структура цены услуги
              mkoef := 1//cena->koef/100
              if p_arr[i,2] == 1  // зарплата
                kzrp := mkoef
              endif
            else                 // структура зарплаты
              mkoef := 1//kzrp * cena->koef/100
            endif
            p_arr[i,3] := hu->stoim*mkoef
          else
            p_arr[i,3] := 0
          endif
        next
      endif
      if fl ; exit ; endif
      if usl->kod_up == 0 ; exit ; endif  // дошли до "корня" дерева
      mkod_usl := usl->kod_up
    enddo
    if fl
      select TMP
      find ("1"+str(hu->otd,3))
      if !found()
        append blank
        tmp->tip := 1
        tmp->kod := hu->otd
      endif
      tmp->stoim += hu->stoim
      aeval(p_arr, {|x,i| fieldput(i+len_m,fieldget(i+len_m)+x[3]) } )
      select USL
      goto (hu->u_kod)
      if usl->slugba >= 0
        select TMP
        find ("2"+str(usl->slugba,3))
        if !found()
          append blank
          tmp->tip := 2
          tmp->kod := usl->slugba
        endif
        tmp->stoim += hu->stoim
        aeval(p_arr, {|x,i| fieldput(i+len_m,fieldget(i+len_m)+x[3]) } )
      endif
    endif
endcase
return NIL*/

*

*****
Function f1r_s_plat()
Local i, j, arr, begin_date, end_date, s, buf := save_row(maxrow()),;
      fl_exit := .f., sh, HH := 57, reg_print, lyear, slyear, speriod,;
      arr_title, name_file := "r_dopl"+stxt, old_vr := 0,;
      vstoim := 0, sstoim := 0, blk
Private arr_m, kv[2]
if (arr_m := year_month()) == NIL
  return NIL
endif
speriod := arr_m[4]
begin_date := arr_m[7]
end_date := arr_m[8]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
dbcreate(cur_dir+"tmp", {{"n_kvit","N", 5,0},; // номер квитанционной книжки
                 {"kv_cia","N", 6,0},; // номер квитанции
                 {"U_KOD" ,"N", 4,0},; // код услуги
                 {"SHIFR" ,"C",10,0},; // шифр услуги
                 {"KOD_VR","N", 4,0},; // код врача
                 {"KOL"   ,"N", 5,0},; // количество услуг
                 {"STOIM" ,"N",10,2}}) // итоговая стоимость услуги
use (cur_dir+"tmp")
index on str(kod_vr,4)+str(n_kvit,5)+str(u_kod,4) to (cur_dir+"tmpk")
index on str(kod_vr,4)+str(n_kvit,5)+fsort_usl(shifr) to (cur_dir+"tmpn")
dbcreate(cur_dir+"tmpt", {{"n_kvit","N", 5,0},; // номер квитанционной книжки
                          {"STOIM" ,"N",10,2}}) // итоговая стоимость услуги
use (cur_dir+"tmpt")
index on str(n_kvit,5) to (cur_dir+"tmpt")
dbcreate(cur_dir+"tmpu", {{"U_KOD" ,"N", 4,0},; // код услуги
                          {"SHIFR" ,"C",10,0},; // шифр услуги
                          {"KOL"   ,"N", 5,0},; // количество услуг
                          {"STOIM" ,"N",10,2}}) // итоговая стоимость услуги
use (cur_dir+"tmpu")
index on str(u_kod,4) to (cur_dir+"tmpuk")
index on fsort_usl(shifr) to (cur_dir+"tmpun")
close databases
use (cur_dir+"tmp") index (cur_dir+"tmpk"),(cur_dir+"tmpn") new alias TMP
use (cur_dir+"tmpt") index (cur_dir+"tmpt") new alias TMPT
use (cur_dir+"tmpu") index (cur_dir+"tmpuk"),(cur_dir+"tmpun") new alias TMPU
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"hum_p",,"HP")
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_ud","HPU")
set relation to kod into HP, to u_kod into USL
dbseek(arr_m[7],.t.)
do while hpu->date_u <= arr_m[8] .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if f_is_uch(st_a_uch,hp->lpu)
    select TMP
    find (str(hpu->kod_vr,4)+str(hp->n_kvit,5)+str(hpu->u_kod,4))
    if !found()
      append blank
      tmp->kod_vr := hpu->kod_vr
      tmp->n_kvit := hp->n_kvit
      tmp->u_kod  := hpu->u_kod
      tmp->shifr  := usl->shifr
    endif
    tmp->kol += hpu->kol
    tmp->stoim += hpu->stoim
    //
    select TMPT
    find (str(hp->n_kvit,5))
    if !found()
      append blank
      tmpt->n_kvit := hp->n_kvit
    endif
    tmpt->stoim += hpu->stoim
    //
    select TMPU
    find (str(hpu->u_kod,4))
    if !found()
      append blank
      tmpu->u_kod  := hpu->u_kod
      tmpu->shifr  := usl->shifr
    endif
    tmpu->kol += hpu->kol
    tmpu->stoim += hpu->stoim
  endif
  select HPU
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  reg_print := 1
  arr_title := {;
"───────────────────────────┬─────┬──────────┬─────┬─────────────",;
"                           │№ кв.│   Шифр   │ Кол.│  Стоимость  ",;
"  Врач                     │книжк│  услуги  │услуг│    услуг    ",;
"───────────────────────────┴─────┴──────────┴─────┴─────────────"}
  sh := len(arr_title[1])
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string(center("Реестр доплат",sh))
  titleN_uch(st_a_uch,sh)
  add_string(center(speriod,sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  G_Use(dir_server+"mo_pers",,"PERSO")
  use (cur_dir+"tmp") index (cur_dir+"tmpn") new alias TMP
  set relation to kod_vr into PERSO
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if old_vr != tmp->kod_vr
      if old_vr != 0
        add_string(space(sh-20)+replicate("-",20))
        add_string(space(sh-20)+"Итого:"+padl(expand_value(vstoim,2),14))
        vstoim := 0
      endif
      add_string("["+lstr(ret_tabn(tmp->kod_vr))+"] "+alltrim(perso->fio))
    endif
    add_string(space(27)+str(tmp->n_kvit,5)+"  "+tmp->shifr+;
               str(tmp->kol,6)+padl(expand_value(tmp->stoim,2),14))
    old_vr := tmp->kod_vr
    vstoim += tmp->stoim
    sstoim += tmp->stoim
    select TMP
    skip
  enddo
  add_string(space(sh-20)+replicate("-",20))
  add_string(space(sh-20)+"Итого:"+padl(expand_value(vstoim,2),14))
  add_string(replicate("─",sh))
  add_string(space(sh-20)+"ВСЕГО:"+padl(expand_value(sstoim,2),14))
  add_string(replicate("─",sh))
  //
  if verify_FF(HH-2,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(space(15)+"в том числе:")
  use (cur_dir+"tmpt") index (cur_dir+"tmpt") new
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(space(21)+"кв.кн."+str(tmpt->n_kvit,5)+;
               space(18)+padl(expand_value(tmpt->stoim,2),14))
    skip
  enddo
  //
  if verify_FF(HH-2,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(space(15)+"в том числе:")
  use (cur_dir+"tmpu") index (cur_dir+"tmpun") new
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(space(34)+tmpu->shifr+;
               str(tmpu->kol,6)+padl(expand_value(tmpu->stoim,2),14))
    skip
  enddo
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

*

*****
Function f2r_spl_plat(reg)
Static snomer := 1, sreg1 := 1
Local i, j, k, arr[2], s, buf := save_row(maxrow()), buf1, reg1,;
      fl_exit := .f., sh, HH := 57, reg_print,;
      arr_title, name_file := "n_kvit"+stxt,;
      vstoim := 0, sstoim := 0, old := 0, up_usl, ;
      speriod, begin_date, end_date, cp := " "
if (mnomer := input_value(18,12,20,67,color1,;
          "Введите необходимый номер квитанционной книжки",;
          snomer,"99999")) == NIL
  return NIL
endif
snomer := mnomer
buf1 := box_shadow(0,0,0,30,color8,"Квитанционная книжка N "+lstr(mnomer),,0)
if (reg1 := popup_prompt(T_ROW,T_COL-5,sreg1,;
                         {"В ~целом по квитанционной книжке",;
                          "За ~период времени"})) == 0
  rest_box(buf1)
  return NIL
elseif reg1 == 2 .and. (arr_m := year_month()) == NIL
  rest_box(buf1)
  return NIL
endif
sreg1 := reg1
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
dbcreate(cur_dir+"tmp", {{"U_KOD" ,"N", 4,0},; // код услуги
                         {"KOD_VR","N", 4,0},; // код врача
                         {"KOL"   ,"N", 5,0},; // количество услуг
                         {"STOIM" ,"N",10,2}}) // итоговая стоимость услуги
use (cur_dir+"tmp")
index on str(kod_vr,4)+str(u_kod,4) to (cur_dir+"tmp")
R_Use(dir_server+"uslugi",dir_server+"uslugi","USL")
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HPU")
R_Use(dir_server+"hum_p",dir_server+"hum_pv","HP")
dbseek(str(mnomer,5))
do while hp->n_kvit == mnomer .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if f_is_uch(st_a_uch,hp->lpu)
    select HPU
    find (str(hp->(recno()),7))
    do while hpu->kod == hp->(recno())
      if if(reg1 == 1, .t., between(hpu->date_u, arr_m[7], arr_m[8]) )
        select TMP
        find (str(hpu->kod_vr,4)+str(hpu->u_kod,4))
        if !found()
          append blank
          tmp->kod_vr := hpu->kod_vr
          tmp->u_kod  := hpu->u_kod
        endif
        tmp->kol += hpu->kol
        tmp->stoim += hpu->stoim
      endif
      select HPU
      skip
    enddo
  endif
  select HP
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  // ничего
elseif j == 0
  func_error(4,"Нет сведений по квитанционной книжке номер "+lstr(mnomer))
else
  mywait()
  reg_print := 2
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"mo_pers",,"PERSO")
  use (cur_dir+"tmp") new alias TMP
  set relation to kod_vr into PERSO, to u_kod into USL
  if reg == 1
    index on str(kod_vr,4)+fsort_usl(usl->shifr) to (cur_dir+"tmp")
  elseif reg == 2
    index on str(u_kod,4)+fsort_usl(usl->shifr)+str(kod_vr,4) to (cur_dir+"tmp")
  endif
  arr_title := {;
"───────────────────────────────────────────────────────────┬─────┬─────────────",;
"                                                           │ Кол.│  Стоимость  ",;
"                                                           │услуг│    услуг    ",;
"───────────────────────────────────────────────────────────┴─────┴─────────────"}
  sh := len(arr_title[1])
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  titleN_uch(st_a_uch,sh)
  add_string("")
  add_string(center("Статистика по квитанционной книжке N "+lstr(mnomer),sh))
  if reg1 == 2
    add_string("")
    add_string(center(arr_m[4],sh))
  endif
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if reg == 1
      if old != tmp->kod_vr
        if old != 0
          add_string(space(sh-20)+replicate("-",20))
          add_string(space(sh-20)+"Итого:"+padl(expand_value(vstoim,2),14))
          vstoim := 0
        endif
        add_string("")
        add_string("["+lstr(ret_tabn(tmp->kod_vr))+"] "+alltrim(perso->fio))
        old := tmp->kod_vr
      endif
      k := perenos(arr,alltrim(usl->shifr)+". "+alltrim(usl->name),55)
    else
      if old != tmp->u_kod
        if old != 0
          add_string(space(sh-20)+replicate("-",20))
          add_string(space(sh-20)+"Итого:"+padl(expand_value(vstoim,2),14))
          vstoim := 0
        endif
        add_string("")
        add_string(alltrim(usl->shifr)+". "+alltrim(usl->name))
        old := tmp->u_kod
      endif
      k := perenos(arr,"["+lstr(ret_tabn(tmp->kod_vr))+"] "+alltrim(perso->fio),55)
    endif
    add_string(space(4)+padr(alltrim(arr[1]),55,cp)+;
               padl(lstr(tmp->kol),6,cp)+;
               padl(expand_value(tmp->stoim,2),14,cp))
    for i := 2 to k
      add_string(space(4)+padl(alltrim(arr[i]),55))
    next
    vstoim += tmp->stoim ; sstoim += tmp->stoim
    select TMP
    skip
  enddo
  add_string(space(sh-20)+replicate("-",20))
  add_string(space(sh-20)+"Итого:"+padl(expand_value(vstoim,2),14))
  add_string(replicate("═",sh))
  add_string(space(sh-20)+"ИТОГО:"+padl(expand_value(sstoim,2),14))
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
Function f3r_s_plat()
Static snomer := 1, sreg1 := 1
Local i, j, k, arr[2], s, buf := save_row(maxrow()), buf1, reg1,;
      fl_exit := .f., sh, HH := 57, reg_print,;
      arr_title, name_file := "n_kvitan"+stxt,;
      vstoim := 0, sstoim := 0, old := 0,;
      speriod, begin_date, end_date, cp := " ", ss := 0
if (mnomer := input_value(18,12,20,67,color1,;
          "Введите необходимый номер квитанционной книжки",;
          snomer,"99999")) == NIL
  return NIL
endif
snomer := mnomer
buf1 := box_shadow(0,0,0,30,color8,"Квитанционная книжка N "+lstr(mnomer),,0)
if (reg1 := popup_prompt(T_ROW,T_COL-5,sreg1,;
                         {"В ~целом по квитанционной книжке",;
                          "За ~период времени"})) == 0
  rest_box(buf1)
  return NIL
elseif reg1 == 2 .and. (arr_m := year_month()) == NIL
  rest_box(buf1)
  return NIL
endif
sreg1 := reg1
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
dbcreate(cur_dir+"tmp", {{"kod_k", "N", 7,0},; // код больного по картотеке
                         {"kv_cia","N", 6,0},; // номер квитанции
                         {"pdate", "C", 4,0},;
                         {"KOL"   ,"N", 5,0},; // количество услуг
                         {"STOIM" ,"N",10,2}}) // итоговая стоимость услуги
use (cur_dir+"tmp")
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HPU")
R_Use(dir_server+"hum_p",dir_server+"hum_pv","HP")
dbseek(str(mnomer,5))
do while hp->n_kvit == mnomer .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if f_is_uch(st_a_uch,hp->lpu) .and. ;
         if(reg1 == 1, .t., between(hp->pdate, arr_m[7], arr_m[8]) )
    select TMP
    append blank
    tmp->kod_k := hp->kod_k
    tmp->kv_cia := hp->kv_cia
    tmp->pdate := hp->pdate
    select HPU
    find (str(hp->(recno()),7))
    do while hpu->kod == hp->(recno())
      tmp->kol += hpu->kol
      tmp->stoim += hpu->stoim
      select HPU
      skip
    enddo
  endif
  select HP
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  // ничего
elseif j == 0
  func_error(4,"Нет сведений по квитанционной книжке номер "+lstr(mnomer))
else
  mywait()
  reg_print := 2
  R_Use(dir_server+"kartotek",,"KART")
  use (cur_dir+"tmp") new alias TMP
  set relation to kod_k into KART
  index on str(kv_cia,6)+pdate to (cur_dir+"tmp")
  arr_title := {;
"───────────────────────────────────────────┬────────┬──────┬─────┬─────────────",;
"                                           │  Дата  │№ кви-│ Кол.│  Стоимость  ",;
"         Ф.И.О. больного                   │ оплаты │танции│услуг│    услуг    ",;
"───────────────────────────────────────────┴────────┴──────┴─────┴─────────────"}
  sh := len(arr_title[1])
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  titleN_uch(st_a_uch,sh)
  add_string("")
  add_string(center("Статистика по квитанционной книжке N "+lstr(mnomer),sh))
  if reg1 == 2
    add_string("")
    add_string(center(arr_m[4],sh))
  endif
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(left(kart->fio,43)+" "+date_8(c4tod(tmp->pdate))+;
               put_val(tmp->kv_cia,7)+;
               str(tmp->kol,6)+padl(expand_value(tmp->stoim,2),14))
    ss += tmp->stoim
    select TMP
    skip
  enddo
  add_string(replicate("─",sh))
  add_string(padr(lstr(tmp->(lastrec()))+" чел.",20)+padl("Итого : "+lput_kop(ss),sh-20))
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
Function f4r_s_plat()
Local lyear, slyear, s_date, arr_kv := {{1,999999}}, buf, ;
      mas12 := {{1," с ..."},{2,"по ..."}}, mpic := {{6,0},{6,0}},;
      blk := {|b,ar,nDim,nElem,nKey| f1_s_vyruchka(b,ar,nDim,nElem,nKey)},;
      i, j, k, arr[2], s, buf1, reg1, min_date, max_date, ;
      fl_exit := .f., sh, HH := 78, reg_print,;
      arr_title, name_file := "boln_usl"+stxt,;
      vstoim := 0, sstoim := 0, old := 0, arr_otd,;
      speriod, begin_date, end_date, cp := " ", ss := 0
if (lyear := input_value(20,15,22,64,color1,;
        "За какой год желаете получить информацию",;
        year(sys_date),"9999")) == NIL
  return NIL
endif
slyear := chr(val(substr(strzero(lyear,4),1,2)))+;
          chr(val(substr(strzero(lyear,4),3,2)))
Arrn_Browse(T_ROW,T_COL-5,maxrow()-2,T_COL+15,arr_kv,mas12,1,,color0,;
            "Квитанции",col_tit_popup,,,mpic,blk,{.t.,.t.,.t.})
if !f_Esc_Enter("поиска")
  return NIL
endif
buf := save_row(maxrow())
mywait()
asort(arr_kv,,,{|x,y| x[1] < y[1] } )
k := len(arr_kv)
for i := k to 1 step -1
  if emptyany(arr_kv[i,1],arr_kv[i,2])
    adel(arr_kv,i) ; --k
  endif
next
//
dbcreate(cur_dir+"tmp", {{"kod_k", "N", 7,0},; // код больного по картотеке
                         {"rec_hp","N", 7,0},; // номер записи по базе "hum_p"
                         {"kv_cia","N", 6,0},; // номер квитанции
                         {"KOL"   ,"N", 5,0},; // количество услуг
                         {"STOIM" ,"N",10,2}}) // итоговая стоимость услуги
use (cur_dir+"tmp")
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HPU")
G_Use(dir_server+"hum_p",,"HP")
index on n_kvit to (cur_dir+"tmp_hp") ;
      for f_is_uch(st_a_uch,hp->lpu) .and. left(hp->pdate,2) == slyear ;
          .and. ascan(arr_kv, {|x| between(hp->kv_cia,x[1],x[2]) } ) > 0
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
go top
min_date := max_date := hp->pdate
do while !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  select TMP
  append blank
  tmp->kod_k := hp->kod_k
  tmp->kv_cia := hp->kv_cia
  tmp->rec_hp := hp->(recno())
  if hp->pdate > max_date
    max_date := hp->pdate
  elseif hp->pdate < min_date
    min_date := hp->pdate
  endif
  select HPU
  find (str(hp->(recno()),7))
  do while hpu->kod == hp->(recno())
    tmp->kol += hpu->kol
    tmp->stoim += hpu->stoim
    select HPU
    skip
  enddo
  select HP
  skip
enddo
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  // ничего
elseif j == 0
  func_error(4,"Нет сведений по выбранным квитанциям")
else
  mywait()
  reg_print := 5
  G_Use(dir_server+"plat_ms",dir_server+"plat_ms","MS")
  G_Use(dir_server+"uslugi",,"USL")
  G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HPU")
  set relation to u_kod into USL
  G_Use(dir_server+"mo_otd",,"OTD")
  G_Use(dir_server+"hum_p",,"HP")
  set relation to otd into OTD
  G_Use(dir_server+"kartotek",,"KART")
  use (cur_dir+"tmp") new alias TMP
  set relation to kod_k into KART, to rec_hp into HP
  index on str(kv_cia,6) to (cur_dir+"tmp")
  arr_title := {;
"─────┬──────────┬────────────────────────────────────────────┬──────┬─────┬─────────",;
"Отде-│Номер амб.│ Ф.И.О. больного                            │№ кви-│ Кол.│Стоимость",;
"ление│  карты   │                                            │танции│услуг│  услуг  ",;
"─────┴─────────┬┴────┬─────────────────┬─────────────────┬───┴──────┤     │         ",;
"           Врач│ Асс.│ Медсестры       │ Санитарки       │  Услуги  │     │         ",;
"───────────────┴─────┴─────────────────┴─────────────────┴──────────┴─────┴─────────"}
  sh := len(arr_title[1])
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  titleN_uch(st_a_uch,sh)
  add_string("")
  add_string(center("Реестр платных услуг",sh))
  if min_date == max_date
    add_string(center("за "+date_month(c4tod(max_date),.t.),sh))
  else
    add_string(center(full_date(c4tod(min_date))+" - "+full_date(c4tod(max_date)),sh))
  endif
  add_string("")
  arr_otd := {}
  aeval(arr_title, {|x| add_string(x) } )
  go top
  do while !eof()
    if verify_FF(HH-1,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if (i := ascan(arr_otd, {|x| x[1] == hp->otd } )) == 0
      aadd(arr_otd, {hp->otd,otd->name,0,0} ) ; i := len(arr_otd)
    endif
    arr_otd[i,3] += tmp->stoim
    arr_otd[i,4] ++
    s := otd->short_name+" "+;
         padr(amb_kartaN(),11)+;
         padr(kart->fio,44)+;
         put_val(tmp->kv_cia,7)+;
         str(tmp->kol,4)+;
         put_kopE(tmp->stoim,12)
    add_string(s)
    add_string(replicate("-",sh))
    select HPU
    find (str(hp->(recno()),7))
    do while hpu->kod == hp->(recno())
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      mkod_vr := mkod_as := 0
      mkod_ms := mkod_san := ""
     // if mem_tabnom == 1
     //   mkod_vr := hpu->kod_vr
     //   mkod_as := hpu->kod_as
     // else
        mkod_vr := ret_tabn(hpu->kod_vr)
        mkod_as := ret_tabn(hpu->kod_as)
    //  endif
      select MS
      if hpu->med1 > 0
        goto (hpu->med1)
        if !eof() .and. ms->tip == 1
          mkod_ms += alltrim(lstr(ms->tab_nom))+" "
        endif
      endif
      if hpu->med2 > 0
        goto (hpu->med2)
        if !eof() .and. ms->tip == 1
          mkod_ms += alltrim(lstr(ms->tab_nom))+" "
        endif
      endif
      if hpu->med3 > 0
        goto (hpu->med3)
        if !eof() .and. ms->tip == 1
          mkod_ms += alltrim(lstr(ms->tab_nom))+" "
        endif
      endif
      if hpu->san1 > 0
        goto (hpu->san1)
        if !eof() .and. ms->tip == 2
          mkod_san += alltrim(lstr(ms->tab_nom))+" "
        endif
      endif
      if hpu->san2 > 0
        goto (hpu->san2)
        if !eof() .and. ms->tip == 2
          mkod_san += alltrim(lstr(ms->tab_nom))+" "
        endif
      endif
      if hpu->san3 > 0
        goto (hpu->san3)
        if !eof() .and. ms->tip == 2
          mkod_san += alltrim(lstr(ms->tab_nom))+" "
        endif
      endif
      s := put_val(mkod_vr,15)+;
           put_val(mkod_as,6)+" "+;
           padr(mkod_ms,17)+" "+;
           padr(mkod_san,17)+" "+;
           usl->shifr+;
           str(hpu->kol,4)+;
           put_kopE(hpu->stoim,12)
      add_string(s)
      //
      select HPU
      skip
    enddo
    add_string(replicate("=",sh))
    ss += tmp->stoim
    select TMP
    skip
  enddo
  if verify_FF(HH-len(arr_otd)-1,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(padr(lstr(tmp->(lastrec()))+" чел.",20)+padl("Итого : "+lput_kop(ss),sh-20))
  close databases
  asort(arr_otd, {|x,y| upper(x[2]) < upper(y[2]) } )
  for i := 1 to len(arr_otd)
    s := iif(i==1, "По отделениям: ", "")
    add_string(padl(s+alltrim(arr_otd[i,2]),45)+;
               put_kopE(arr_otd[i,3],12)+" руб. "+;
               str(arr_otd[i,4],5)+" чел.")
  next
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
Function f5r_s_plat()
Local buf, i, k, mas12, arr_m, n_file := "spis_kvi"+stxt, sh := 64, ssum := 0
if (arr_m := year_month()) == NIL
  return NIL
endif
buf := save_row(maxrow())
mywait()
dbcreate(cur_dir+"tmp", {{"n_kvit","N", 5,0},; // номер квитанционной книжки
                         {"kv_cia","N", 6,0},; // номер квитанции
                         {"stoim", "N",10,2}}) // сумма квитанции
use (cur_dir+"tmp")
index on str(kv_cia,6) to (cur_dir+"tmp")
G_Use(dir_server+"hum_p",,"HP")
index on n_kvit to (cur_dir+"tmp_hp") ;
      for f_is_uch(st_a_uch,hp->lpu) .and. between(hp->pdate,arr_m[7],arr_m[8])
go top
do while !eof()
  select TMP
  find (str(hp->kv_cia,6))
  if !found()
    append blank
    tmp->n_kvit := hp->n_kvit
    tmp->kv_cia := hp->kv_cia
    tmp->stoim := hp->cena
    ssum += hp->cena
  endif
  select HP
  skip
enddo
//
select TMP
index on str(n_kvit,5)+str(kv_cia,6) to (cur_dir+"tmp")
go top
mas12 := {} ; aadd(mas12, {tmp->n_kvit,tmp->kv_cia,tmp->kv_cia,0}) ; i := 1
do while !eof()
  if mas12[i,1] == tmp->n_kvit
    if tmp->kv_cia - mas12[i,3] > 1
      aadd(mas12, {tmp->n_kvit,tmp->kv_cia,tmp->kv_cia,0}) ; ++i
    else
      mas12[i,3] := tmp->kv_cia
    endif
  else
    aadd(mas12, {tmp->n_kvit,tmp->kv_cia,tmp->kv_cia,0}) ; ++i
  endif
  skip
enddo
go top
do while !eof()
  if (i := ascan(mas12, {|x| x[1] == tmp->n_kvit .and. ;
                             between(tmp->kv_cia,x[2],x[3]) } )) > 0
    mas12[i,4] += tmp->stoim
  endif
  skip
enddo
close databases
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("РЕЕСТР ПЛАТНЫХ УСЛУГ",sh))
add_string(center(arr_m[4],sh))
add_string("")
old_kn := 0
for i := 1 to len(mas12)
  if mas12[i,1] != old_kn
    add_string("")
    add_string(center("Квитанционная книжка N "+lstr(mas12[i,1]),sh))
    old_kn := mas12[i,1]
  endif
  if mas12[i,2] == mas12[i,3]
    add_string(padr("Квитанция N "+lstr(mas12[i,2]),32)+;
               padl(expand_value(mas12[i,4],2),sh-32))
  else
    add_string(padr("Квитанции с N "+lstr(mas12[i,2])+" по N "+lstr(mas12[i,3]),32)+;
               padl(expand_value(mas12[i,4],2),sh-32))
  endif
next
add_string("")
add_string("Общая сумма:  "+expand_value(ssum,2))
for j := 1 to perenos(mas12,"Сумма прописью:  "+srub_kop(ssum,.t.),sh)
  add_string(mas12[j])
next
fclose(fp)
rest_box(buf)
viewtext(n_file)
return NIL

*

*****
Function Pl_vyruchka()
Local lyear, slyear, s_date, arr_kv := {{1,999999}}, buf, i, k,;
      mas12 := {{1," с ..."},{2,"по ..."}}, mpic := {{6,0},{6,0}},;
      blk := {|b,ar,nDim,nElem,nKey| f1_s_vyruchka(b,ar,nDim,nElem,nKey)},;
      n_file := "s_vyruch"+stxt, sh := 64, ssum := 0, hGauge
if (lyear := input_value(20,15,22,64,color1,;
        "За какой год желаете получить информацию",;
        year(sys_date),"9999")) == NIL
  return NIL
endif
slyear := chr(val(substr(strzero(lyear,4),1,2)))+;
          chr(val(substr(strzero(lyear,4),3,2)))
s_date := input_value(18,10,20,69,color1,;
                          space(9)+"Введите дату сдачи выручки",;
                          sys_date)
if s_date == NIL
  return NIL
endif
Arrn_Browse(T_ROW,T_COL-5,maxrow()-2,T_COL+15,arr_kv,mas12,1,,color0,;
            "Квитанции",col_tit_popup,,,mpic,blk,{.t.,.t.,.t.})
if f_Esc_Enter("поиска")
  buf := save_row(maxrow())
  mywait()
  asort(arr_kv,,,{|x,y| x[1] < y[1] } )
  k := len(arr_kv)
  for i := k to 1 step -1
    if emptyany(arr_kv[i,1],arr_kv[i,2])
      adel(arr_kv,i) ; --k
    endif
  next
  dbcreate(cur_dir+"tmp", {{"n_kvit","N", 5,0},; // номер квитанционной книжки
                           {"kv_cia","N", 6,0},; // номер квитанции
                           {"stoim", "N",10,2}}) // сумма квитанции
  use (cur_dir+"tmp")
  index on str(kv_cia,6) to (cur_dir+"tmp")
  G_Use(dir_server+"hum_p",,"HP")
  index on n_kvit to (cur_dir+"tmp_hp") ;
        for f_is_uch(st_a_uch,hp->lpu) .and. left(hp->pdate,2) == slyear ;
                .and. ascan(arr_kv, {|x| between(hp->kv_cia,x[1],x[2]) } ) > 0
  go top
  do while !eof()
    select TMP
    find (str(hp->kv_cia,6))
    if !found()
      append blank
      tmp->n_kvit := hp->n_kvit
      tmp->kv_cia := hp->kv_cia
      tmp->stoim := hp->cena
      ssum += hp->cena
    endif
    select HP
    skip
  enddo
  //
  select TMP
  index on str(n_kvit,5)+str(kv_cia,6) to (cur_dir+"tmp")
  go top
  mas12 := {} ; aadd(mas12, {tmp->n_kvit,tmp->kv_cia,tmp->kv_cia,0}) ; i := 1
  do while !eof()
    if mas12[i,1] == tmp->n_kvit
      if tmp->kv_cia - mas12[i,3] > 1
        aadd(mas12, {tmp->n_kvit,tmp->kv_cia,tmp->kv_cia,0}) ; ++i
      else
        mas12[i,3] := tmp->kv_cia
      endif
    else
      aadd(mas12, {tmp->n_kvit,tmp->kv_cia,tmp->kv_cia,0}) ; ++i
    endif
    skip
  enddo
  go top
  do while !eof()
    if (i := ascan(mas12, {|x| x[1] == tmp->n_kvit .and. ;
                               between(tmp->kv_cia,x[2],x[3]) } )) > 0
      mas12[i,4] += tmp->stoim
    endif
    skip
  enddo
  close databases
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("РЕЕСТР ПЛАТНЫХ УСЛУГ",sh))
  add_string("")
  old_kn := 0
  for i := 1 to len(mas12)
    if mas12[i,1] != old_kn
      add_string("")
      add_string(center("Квитанционная книжка N "+lstr(mas12[i,1]),sh))
      old_kn := mas12[i,1]
    endif
    if mas12[i,2] == mas12[i,3]
      add_string(padr("Квитанция N "+lstr(mas12[i,2]),32)+;
                 padl(expand_value(mas12[i,4],2),sh-32))
    else
      add_string(padr("Квитанции с N "+lstr(mas12[i,2])+" по N "+lstr(mas12[i,3]),32)+;
                 padl(expand_value(mas12[i,4],2),sh-32))
    endif
  next
  add_string("")
  add_string("Общая сумма:  "+expand_value(ssum,2))
  for j := 1 to perenos(mpic,"Сумма прописью:  "+srub_kop(ssum,.t.),sh)
    add_string(mpic[j])
  next
  add_string("")
  add_string('Дата: '+date_month(s_date))
  add_string("")
  add_string("Подпись ________________")
  fclose(fp)
  rest_box(buf)
  viewtext(n_file)
endif
return NIL

*****
Function f1_s_vyruchka(b,ar,nDim,nElem,nKey)
LOCAL nRow := ROW(), nCol := COL(), i, j, flag := .f., buf,;
      mpic := {"9999",}
DO CASE
  CASE nKey == K_DOWN .or. nKey == K_INS
    b:panHome()
  CASE nKey == K_LEFT
    b:left()
  CASE nKey == K_RIGHT
    b:right()
  OTHERWISE
    if (nKey == K_ENTER .or. between(nKey,48,57))
      if between(nKey,48,57)
        keyboard chr(nKey)
      endif
      Private mkod := parr[nElem,nDim]
      @ nRow, nCol GET mkod picture "999999"
      myread({"up","down"})
      if lastkey() != K_ESC
        parr[nElem,nDim] := mkod
        if nDim == 1
          b:right()
        endif
        flag := .t.
      endif
    endif
ENDCASE
@ nRow, nCol SAY ""
return flag

*

*****
Function Po_proverka(k)
Static si1 := 1, si2 := 1, si3 := 1
Local mas_pmt, mas_msg, mas_fun, j, mdate, arr_gr
Local uch_otd
DEFAULT k TO 1
do case
  case k == 1
    uch_otd := saveuchotd()
    Private p_net_otd := .t.
    mas_pmt := {"Не введен код ~врача",;
                "Не введен код ~асистента",;
                "Не введен код ~медсестры",;
                "Не введен код ~санитарки"}
    mas_msg := {"Проверка листов учета на отсутствие кода врача",;
                "Проверка листов учета на отсутствие кода асистента",;
                "Проверка листов учета на отсутствие кода медсестер",;
                "Проверка листов учета на отсутствие кода санитарок"}
    mas_fun := {"Po_proverka(11)",;
                "Po_proverka(16)",;
                "Po_proverka(12)",;
                "Po_proverka(13)"}
    if mem_otdusl == 2 .and. tip_polzovat == 0
      aadd(mas_pmt,"~Отделение не равно месту работы")
      aadd(mas_msg,"Проверка отделения на равенство месту основной работы персонала")
      aadd(mas_fun,"Po_proverka(14)")
    endif
    aadd(mas_pmt,"~Сверка со счетами ОМС")
    aadd(mas_msg,"")
    aadd(mas_fun,"Po_proverka(15)")
    aadd(mas_pmt,"~Направитель==врач")
    aadd(mas_msg,"Проверка на совпадение врача и направителя")
    aadd(mas_fun,"Po_proverka(17)")
    aadd(mas_pmt,"~Направитель==асистент")
    aadd(mas_msg,"Проверка на совпадение асистента и направителя")
    aadd(mas_fun,"Po_proverka(18)")
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
    restuchotd(uch_otd)
  case k == 11
    if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) != NIL
      Po_pr_vr_as(1)
    endif
  case k == 12
    if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) != NIL
      Po_pr_vr_as(2)
    endif
  case k == 13
    if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) != NIL
      Po_pr_vr_as(3)
    endif
  case k == 14
    if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) != NIL
      Po_pr_ot_pe()
    endif
  case k == 15
    Po_pr_OMS()
  case k == 16
    if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) != NIL
      Po_pr_vr_as(4)
    endif
  case k == 17
    if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) != NIL
      Po_isp_nap(1)
    endif
  case k == 18
    if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) != NIL
      Po_isp_nap(2)
    endif
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  elseif between(k,31,39)
    si3 := j
  endif
endif
return NIL

*

*****
Function Po_isp_nap(reg)
Local i, j, k, arr, fl, fl_exit := .f., buf := save_row(maxrow()),;
      s, sh, HH := 57, arr_title, name_file := "proverka"+stxt,;
      arr_usl := {}
if (arr := year_month()) == NIL
  return NIL
endif
if (k := f_alert({'Каким образом производить проверку на исполнитель==направитель.',;
                  "Выберите действие:"},;
                 {" По ~всем услугам ",;
                  " ~Исключая некоторые услуги "},;
                 1,"N+/BG","R/BG",,,col1menu )) == 0
  return NIL
elseif k == 2
  dbcreate(cur_dir+"tmp", {;
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0}})  // наименование услуги
  use (cur_dir+"tmp")
  index on str(u_kod,4) to (cur_dir+"tmpk")
  index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
  close databases
  ob2_v_usl()
  use (cur_dir+"tmp")
  dbeval({|| aadd(arr_usl,tmp->u_kod) } )
  use
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
dbcreate(cur_dir+"tmp", {{"rec","N",7,0},{"rec_vr","N",6,0},{"sum_usl","N",8,2}})
use (cur_dir+"tmp") new
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
G_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
dbseek(dtos(arr[5]),.t.)
do while human->k_data <= arr[6] .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if f_is_uch(st_a_uch,human->lpu)
    fl := .f.
    tt_sm := 0
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno()) .and. !eof()
      if ascan(arr_usl, hu->u_kod) == 0
        if reg == 1
          if hu->kod_vr == human->kod_vr .and. hu->kod_vr > 0
            tt_sm += hu->stoim
            fl := .t. //; exit
          endif
        elseif reg == 2
          if hu->kod_as == human->kod_vr .and. hu->kod_vr > 0
            tt_sm += hu->stoim
            fl := .t. //; exit
          endif
        endif
      endif
      select HU
      skip
    enddo
    if fl
      select TMP
      append blank
      tmp->rec := human->(recno())
      tmp->rec_vr := human->kod_vr
      tmp->sum_usl := tt_sm
    endif
    tt_sm := 0
  endif
  select HUMAN
  skip
enddo
if tmp->(lastrec()) > 0
  mywait()
  arr_title := {;
"─────────────────────────────────────────────────┬──────────┬──────────┬──────────┬──────────────────",;
"              Ф.И.О. больного                    │Дата окон.│ Сумма Cл │ Сумма Усл│   Направитель    ",;
"─────────────────────────────────────────────────┴──────────┴──────────┴──────────┴──────────────────"}
  sh := len(arr_title[1])
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("Список больных, у которых в оказанных услугах",sh))
  add_string(center("код направителя соответствует "+{"врачу","асистенту"}[reg],sh))
  add_string("")
  add_string(center(arr[4],sh))
  titleN_uch(st_a_uch,sh)
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  //
  G_Use(dir_server+"MO_pers",,"PERSO")
  G_Use(dir_server+"kartotek",,"KART")
  select HUMAN
  set index to
  set relation to kod_k into KART
  select TMP
  set relation to rec into HUMAN
  index on upper(kart->fio) to (cur_dir+"tmp")
  go top
  i := 0
  hGauge := GaugeNew(,,,"Создание текстового файла",.t.)
  GaugeDisplay( hGauge )
  mas_vr :={}
  do while !eof()
    GaugeUpdate( hGauge, ++i/lastrec() )
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    PERSO->(dbGoto(tmp->rec_vr))
    s := str(i,4)+". "+left(kart->fio,43)+" "+full_date(human->k_data)
    add_string(s+put_kopE(human->cena,11)+" "+put_kopE(tmp->sum_usl,11)+" "+padr(PERSO->fio,18))
    if (t := ascan(mas_vr,{|x| x[1]==tmp->rec_vr})) == 0
      aadd(mas_vr,{tmp->rec_vr,PERSO->fio,human->cena,tmp->sum_usl})
    else
      mas_vr[t,3] += human->cena
      mas_vr[t,4] += tmp->sum_usl
    endif
    select TMP
    skip
  enddo
  //
  add_string("")
  arr_title := {;
"────────────────────────────────────────┬──────────┬──────────",;
"       Ф.И.О. Врача/медсестры           │ Сумма Cл │ Сумма Усл",;
"────────────────────────────────────────┴──────────┴──────────"}
  aeval(arr_title, {|x| add_string(x) } )
  for i := 1 to len(mas_vr)
    add_string(padr(mas_vr[i,2],40)+" "+put_kop(mas_vr[i,3],11)+" "+put_kop(mas_vr[i,4],11))
  next
  close databases
  CloseGauge(hGauge)
  fclose(fp)
  viewtext(name_file,,,,.t.,,,3)
else
  func_error(4,"Не обнаружено услуг с направлением себе!")
endif
close databases
rest_box(buf)
return NIL

*

*****
Function Po_pr_vr_as(reg)
Local i, j, k, arr, fl, fl_exit := .f., buf := save_row(maxrow()),;
      s, sh, HH := 57, arr_title, name_file := "proverka"+stxt,;
      arr_usl := {}
if (arr := year_month()) == NIL
  return NIL
endif
if (k := f_alert({'Каким образом производить проверку на отсутствие кодов персонала.',;
                  "Выберите действие:"},;
                 {" По ~всем услугам ",;
                  " ~Исключая некоторые услуги "},;
                 1,"N+/BG","R/BG",,,col1menu )) == 0
  return NIL
elseif k == 2
  dbcreate(cur_dir+"tmp", {;
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0}})  // наименование услуги
  use (cur_dir+"tmp")
  index on str(u_kod,4) to (cur_dir+"tmpk")
  index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
  close databases
  ob2_v_usl()
  use (cur_dir+"tmp")
  dbeval({|| aadd(arr_usl,tmp->u_kod) } )
  use
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
dbcreate(cur_dir+"tmp", {{"rec","N",7,0}})
use (cur_dir+"tmp") new
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
G_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
dbseek(dtos(arr[5]),.t.)
do while human->k_data <= arr[6] .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if f_is_uch(st_a_uch,human->lpu)
    fl := .f.
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno())
      if ascan(arr_usl, hu->u_kod) == 0
        if reg == 1
          if hu->kod_vr == 0
            fl := .t. ; exit
          endif
        elseif reg == 4
          if hu->kod_as == 0
            fl := .t. ; exit
          endif
        elseif reg == 2
          if emptyall(hu->med1,hu->med2,hu->med3)
            fl := .t. ; exit
          endif
        elseif reg == 3
          if emptyall(hu->san1,hu->san2,hu->san3)
            fl := .t. ; exit
          endif
        endif
      endif
      select HU
      skip
    enddo
    if fl
      select TMP
      append blank
      tmp->rec := human->(recno())
    endif
  endif
  select HUMAN
  skip
enddo
if tmp->(lastrec()) > 0
  mywait()
  arr_title := {;
"─────────────────────────────────────────────────┬──────────┬──────────",;
"              Ф.И.О. больного                    │Дата окон.│  Сумма   ",;
"─────────────────────────────────────────────────┴──────────┴──────────"}
  sh := len(arr_title[1])
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("Список больных, у которых в оказанных услугах",sh))
  add_string(center("отсутствует код "+{"врача","медсестер","санитарок","асистента"}[reg],sh))
  add_string("")
  add_string(center(arr[4],sh))
  titleN_uch(st_a_uch,sh)
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  //
  G_Use(dir_server+"kartotek",,"KART")
  select HUMAN
  set index to
  set relation to kod_k into KART
  select TMP
  set relation to rec into HUMAN
  index on upper(kart->fio) to (cur_dir+"tmp")
  go top
  i := 0
  hGauge := GaugeNew(,,,"Создание текстового файла",.t.)
  GaugeDisplay( hGauge )
  do while !eof()
    GaugeUpdate( hGauge, ++i/lastrec() )
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    s := str(i,4)+". "+left(kart->fio,43)+" "+full_date(human->k_data)
    add_string(s+put_kopE(human->cena,11))
    select TMP
    skip
  enddo
  close databases
  CloseGauge(hGauge)
  fclose(fp)
  viewtext(name_file,,,,.f.,,,2)
else
  func_error(4,"Не обнаружено услуг с незанесенным персоналом!")
endif
close databases
rest_box(buf)
return NIL


*

*****
Function Po_pr_oms(reg)
Local i, j, k, arr, fl, fl_exit := .f., buf := save_row(maxrow()), s, sh := 81, ;
      HH := 57, name_file := "proverka"+stxt, arr_usl := {}, numer := 1
if (arr := year_month()) == NIL
  return NIL
endif
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Список больных по ОМС и ПЛАТНЫМ ",sh))
add_string(center("по дате счета ОМС",sh))
add_string("")
add_string(center(arr[4],sh))
//
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","PHU")
G_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"hum_p",,"PHUMAN")
index on str(kod_k,7)+dtos(n_data) to (cur_dir+"tmpp")
G_Use(dir_server+"schet",dir_server+"schetd","SCHET")
set filter to !eq_any(mest_inog,6,7)
G_Use(dir_server+"human",dir_server+"humans","HUMAN")
G_Use(dir_server+"human_u",dir_server+"human_u","HU")
select SCHET
go top
do while !eof()
  UpdateStatus()
  if schet->pdate <= arr[8] .and. schet->pdate >= arr[7]
    select HUMAN
    find(str(schet->kod,6))
    do while schet->kod == human->schet .and. !eof()
      if human->n_data <= arr[6] .and. human->n_data >= arr[5]
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        T_kod := human->kod_k
        select PHUMAN
        dbseek((str(t_kod,7)+dtos(human->n_data)),.T.)
        if human->kod_k == phuman->kod_k .and.;
             human->n_data <= phuman->n_data .and. human->k_data >= phuman->n_data
          verify_FF(HH,.t.,sh)
          add_string(lstr(numer)+". <"+lstr(human->kod_k)+"> "+alltrim(human->fio)+;
                     ";  счет № "+schet->nomer_s)
          add_string("ОМС: c "+full_date(human->n_data)+" по "+full_date(human->k_data))
          select HU
          find (str(human->(recno()),7))
          do while hu->kod == human->(recno())
            select USL
            goto hu->u_kod
            verify_FF(HH,.t.,sh)
            add_string("  "+usl->shifr+" "+alltrim(usl->name))
            select HU
            skip
          enddo
          add_string("ПЛАТНЫЕ: "+full_date(phuman->n_data))
          select PHU
          find (str(phuman->(recno()),7))
          do while phu->kod == phuman->(recno())
            select USL
            goto phu->u_kod
            verify_FF(HH,.t.,sh)
            add_string("  "+usl->shifr+" "+alltrim(usl->name))
            select PHU
            skip
          enddo
          add_string("")
          ++numer
        endif
      endif
      select HUMAN
      skip
    enddo
  endif
  select SCHET
  skip
enddo
close databases
fclose(fp)
viewtext(name_file,,,,.t.,,,2)
rest_box(buf)
return NIL

*

***** Проверка отделения на равенство месту основной работы персонала
Function Po_pr_ot_pe()
Local i := 0, j, k, arr, fl, fl_exit := .f., buf := save_row(maxrow()),;
      s, sh, HH := 57, arr_title, name_file := "prov_otd"+stxt,;
      arr_usl := {}
if (arr := year_month()) == NIL
  return NIL
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
dbcreate(cur_dir+"tmp", {{"rec","N",7,0},;
                         {"otd","N",3,0},;
                         {"otd_new","N",3,0}})
use (cur_dir+"tmp") new
arr_title := {;
"─────────────────────────────────────────────────┬──────────┬──────────",;
"              Ф.И.О. больного                    │Дата окон.│  Сумма   ",;
"─────────────────────────────────────────────────┴──────────┴──────────"}
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("Список больных, у которых в оказанных услугах",sh))
add_string(center("код отделения не соответствует месту основной работы персонала",sh))
add_string("")
add_string(center(arr[4],sh))
titleN_uch(st_a_uch,sh)
add_string("")
aeval(arr_title, {|x| add_string(x) } )
//
G_Use(dir_server+"kartotek",,"KART")
G_Use(dir_server+"mo_pers",,"PERSO")
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
G_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
dbseek(dtos(arr[5]),.t.)
do while human->k_data <= arr[6] .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if f_is_uch(st_a_uch,human->lpu)
    fl := .f.
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno())
      if (old_kod := hu->kod_vr) == 0
        old_kod := hu->kod_as
      endif
      if old_kod > 0
        select PERSO
        goto (old_kod)
        if perso->otd > 0 .and. hu->otd != perso->otd
          select TMP
          append blank
          tmp->rec := hu->(recno())
          tmp->otd := hu->otd
          tmp->otd_new := perso->otd
          if tmp->(lastrec()) % 5000 == 0
            commit
          endif
          fl := .t.
        endif
      endif
      select HU
      skip
    enddo
    if fl
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      kart->(dbGoto(human->kod_k))
      s := str(++i,4)+". "+left(kart->fio,43)+" "+full_date(human->k_data)
      add_string(s+put_kopE(human->cena,11))
    endif
  endif
  select HUMAN
  skip
enddo
rest_box(buf)
if tmp->(lastrec()) > 0
  close databases
  fclose(fp)
  viewtext(name_file,,,,.f.,,,2)
  if (k := f_alert({'Необходимо произвести изменение отделений по месту основной',;
                    "работы персонала?"},;
                   {" ~Нет "," ~Да "},;
                   1,"N+/BG","R/BG",17,,col1menu )) == 2
    hGauge := GaugeNew(,,,"Изменение кодов отделений",.t.)
    GaugeDisplay( hGauge )
    G_Use(dir_server+"hum_p_u",{dir_server+"hum_p_u",;
                                dir_server+"hum_p_uk",;
                                dir_server+"hum_p_ud",;
                                dir_server+"hum_p_uv",;
                                dir_server+"hum_p_ua"},"HU")
    set order to 0
    use (cur_dir+"tmp") new
    go top
    do while !eof()
      GaugeUpdate( hGauge, recno()/lastrec() )
      select HU
      goto (tmp->rec)
      G_RLock(forever)
      hu->otd := tmp->otd_new
      UnLock
      select TMP
      if tmp->(lastrec()) % 5000 == 0
        commit
      endif
      skip
    enddo
    close databases
    CloseGauge(hGauge)
    stat_msg("Отделения изменены!") ; mybell(2,OK)
  endif
else
  func_error(4,"Не обнаружено несоответствий!")
endif
close databases
return NIL

*

***** 11.02.13
Function pl_vzaimozach()
Local i, j, k, fl, fl_exit := .f., buf := save_row(maxrow()),;
      t_arr[BR_LEN], blk, fl1 := .f., fl2 := .f.
Private arr_m
if (arr_m := year_month()) == NIL
  return NIL
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
dbcreate(cur_dir+"tmp", {{"kod_k"  ,"N", 7,0},; // код больного по картотеке
                         {"tip_usl","N", 1,0},; // 2-взаимозачет, 1-добр.СМО
                         {"pr_smo" ,"N", 6,0},; // код предприятия / СМО
                         {"KOL"    ,"N", 5,0},; // количество листов учета
                         {"D_POLIS","C",25,0},; // полис
                         {"N_DATA" ,"D", 8,0},; // дата начала лечения
                         {"K_DATA" ,"D", 8,0},; // дата окончания лечения
                         {"STOIM"  ,"N",10,2}}) // итоговая стоимость услуг
use (cur_dir+"tmp") new
index on str(tip_usl,1)+str(pr_smo,6)+str(kod_k,7) to (cur_dir+"tmp")
dbcreate(cur_dir+"tmp2", {{"rec_tmp","N", 6,0},;
                          {"rec_hp" ,"N", 7,0},;
                          {"D_POLIS","C",25,0}}) // полис
use (cur_dir+"tmp2") new
if pi1 == 2  // по дате окончания лечения
  G_Use(dir_server+"hum_p",dir_server+"hum_pd","HP")
  dbseek(dtos(arr_m[5]),.t.)
  do while hp->k_data <= arr_m[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if equalany(hp->tip_usl,1,2)
      f3_pl_vzaim()
    endif
    select HP
    skip
  enddo
else// pi1 == 3  // по дате закрытия листа учета
  G_Use(dir_server+"hum_p",dir_server+"hum_pc","HP")
  for xx := 1 to 2
    select HP
    dbseek(str(xx,1)+"1"+dtos(arr_m[5]),.t.)
    do while hp->tip_usl==xx .and. hp->date_close <= arr_m[6] .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      f3_pl_vzaim()
      select HP
      skip
    enddo
    if fl_exit ; exit ; endif
  next
endif
j := tmp->(lastrec())
if !fl_exit .and. j > 0
  dbcreate(cur_dir+"tmp1", {{"name"   ,"C",30,0},; // наименование предприятия
                            {"tip_usl","N", 1,0},; // 2-взаимозачет, 1-добр.СМО
                            {"pr_smo" ,"N", 6,0},; // код предприятия / СМО
                            {"KOL"    ,"N", 6,0},; // количество больных
                            {"STOIM"  ,"N",11,2}}) // итоговая стоимость лечения
  G_Use(dir_server+"p_pr_vz",,"PRED")
  G_Use(dir_server+"p_d_smo",,"SMO")
  use (cur_dir+"tmp1") new
  index on str(tip_usl,1)+str(pr_smo,6) to (cur_dir+"tmp1")
  select TMP
  go top
  do while !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    select TMP1
    find (str(tmp->tip_usl,1)+str(tmp->pr_smo,6))
    if !found()
      append blank
      tmp1->tip_usl := tmp->tip_usl
      tmp1->pr_smo  := tmp->pr_smo
      if tmp->tip_usl == 1
        smo->(dbGoto(tmp->pr_smo))
        tmp1->name := smo->name
        fl1 := .t.
      else
        pred->(dbGoto(tmp->pr_smo))
        tmp1->name := pred->name
        fl2 := .t.
      endif
    endif
    tmp1->kol ++
    tmp1->stoim += tmp->stoim
    select TMP
    skip
  enddo
  j := tmp1->(lastrec())
  mywait()
  select TMP2
  index on str(rec_tmp,6) to (cur_dir+"tmp2")
endif
close databases
rest_box(buf)
if fl_exit
  // ничего
elseif j == 0
  func_error(4,"Нет сведений по ДМС и взаимозачету "+arr_m[4])
else
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow()-2
  t_arr[BR_LEFT] := 11
  t_arr[BR_RIGHT] := 68
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := arr_m[4]
  if fl1
    t_arr[BR_TITUL] += " (ДМС)"
  endif
  if fl2
    t_arr[BR_TITUL] += " (в/зачет)"
  endif
  t_arr[BR_TITUL_COLOR] := "BG+/GR"
  t_arr[BR_ARR_BROWSE] := {,,,"N/BG,W+/N,B/BG,W+/B",.t.,0}
  blk := {|| iif(tip_usl==1, {1,2}, {3,4}) }
  t_arr[BR_COLUMN] := {{ center("Наименование",30), {|| tmp1->name }, blk },;
                       { "Кол-во;больных", {|| str(kol,7) }, blk },;
                       { "   Сумма;  лечения", {|| put_kop(stoim,11) }, blk }}
  t_arr[BR_EDIT] := {|nk,ob| f1_pl_vzaim(nk,ob,"edit") }
  t_arr[BR_STAT_MSG] := {|| ;
  status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор для печати; ^<F9>^ - сводная печать") } //16.04.08
  use (cur_dir+"tmp1") new
  index on upper(name) to (cur_dir+"tmp1")
  go top
  edit_browse(t_arr)
  close databases
  rest_box(buf)
endif
return NIL

*

*****
Function f1_pl_vzaim(nKey,oBrow,regim)
Local ret := -1, buf, fl := .f., t_arr[BR_LEN]
Local sm := 0, HH := 52, n_file := "platn.txt", sum3 := 0, sh
Local arr_title := {;
  "───────────────────────────────────────────────────┬────────┬───────────",;
  "                  Услуги                           │ Кол-во │   Сумма   ",;
  "───────────────────────────────────────────────────┴────────┴───────────";
  }
sh := len(arr_title[1])

if regim == "edit" .and. nKey == K_ENTER
  Private rec_tmp1 := tmp1->(recno())
  buf := savescreen()
  mywait()
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := maxrow()-2
  t_arr[BR_LEFT] := 2
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color0
  if tmp1->tip_usl == 1
    glob_d_smo := {tmp1->pr_smo,alltrim(tmp1->name)}
    t_arr[BR_TITUL] := glob_d_smo[2]+" (ДМС) "+arr_m[4]
  else
    glob_pr_vz := {tmp1->pr_smo,alltrim(tmp1->name)}
    t_arr[BR_TITUL] := glob_pr_vz[2]+" (в/зачет) "+arr_m[4]
  endif
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_ARR_BROWSE] := {,,,"N/BG,W+/N,B/BG,W+/B",.t.,0}
  n := 33
  t_arr[BR_COLUMN] := {{ center("Ф.И.О.",n), {|| padr(kart->fio,n) } },;
                       { "Раз", {|| str(kol,3) } },;
                       { center("Срок лечения",17), {|| date_8(n_data)+"-"+date_8(k_data) } },;
                       { " Сумма", {|| put_kop(stoim,10) } }}
  t_arr[BR_EDIT] := {|nk,ob| f2_pl_vzaim(nk,ob,"edit") }
  t_arr[BR_STAT_MSG] := {|| ;
    status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор для печати;  ^<F9>^ - печать реестра") }
  mywait()
  use (cur_dir+"tmp2") index (cur_dir+"tmp2") new
  G_Use(dir_server+"kartotek",,"KART")
  use (cur_dir+"tmp") new alias TMP
  set relation to kod_k into KART
  index on upper(kart->fio) to (cur_dir+"tmp") ;
        for tmp1->tip_usl == tmp->tip_usl .and. tmp1->pr_smo == tmp->pr_smo
  edit_browse(t_arr)
  close databases
  restscreen(buf)
  use (cur_dir+"tmp1") index (cur_dir+"tmp1") new
  goto (rec_tmp1)
elseif regim == "edit" .and. nKey == K_F9
  rec_tmp1 := tmp1->(recno())
  buf := savescreen()
  mywait()
  dbcreate(cur_dir+"tmp9", {{"kod",     "N", 4,   0},;
                            {"name",    "C", 60,  0},;
                            {"kod_1",   "C", 10,  0},;
                            {"kol_vo",  "N", 10,  0},;
                            {"summa",   "N", 12,  2}})
  use (cur_dir+"tmp2") index (cur_dir+"tmp2") new
  use (cur_dir+"tmp9") new
  index on kod to (cur_dir+"tmp_u")
  G_Use(dir_server+"hum_p_U",dir_server+"hum_p_U","HUM_U",,,.T.)
  G_Use(dir_server+"hum_p",,"HP")
  use (cur_dir+"tmp") new alias TMP
  index on str(tmp->kol,6) to (cur_dir+"tmp") ;
        for tmp1->tip_usl == tmp->tip_usl .and. tmp1->pr_smo == tmp->pr_smo
  go top
  do while !eof()
    select TMP2
    find (str(tmp->(recno()),6))
    do while tmp2->rec_tmp == tmp->(recno()) .and. !eof()
      select HUM_U
      find (str(tmp2->rec_hp,7))
      do while tmp2->rec_hp == hum_u->kod .and. !eof()
        select TMP9
        find (hum_u->u_kod)
        if !found()
          append blank
          tmp9->kod := hum_u->u_kod
        endif
        tmp9->kol_vo += hum_u->kol
        tmp9->summa  += hum_u->stoim
        select HUM_U
        skip
      enddo
      select TMP2
      skip
    enddo
    select TMP
    skip
  enddo
  G_Use(dir_server+"uslugi",,"USL")
  select TMP9
  go top
  do while !eof()
    t := tmp9->kod
    select USL
    goto t
    select TMP9
    tmp9->name  := usl->name
    tmp9->kod_1 := usl->shifr
    skip
  enddo
  select TMP9
  index on kod_1 to (cur_dir+"tmp_u")
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string(center("Оплата услуг",sh))
  add_string(center("по дате начала лечения",sh))
  add_string(center(tmp1->name,sh))
  if tmp1->tip_usl == 1
    add_string(center(" (ДМС) ",sh))
  else
    add_string(center(" (в/зачет) ",sh))
  endif
  add_string(center(arr_m[4],sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) })
  go top
  sm1 := 0
  sm2 := 0
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(tmp9->kod_1+padr(tmp9->name,40)+;
               STR(tmp9->kol_vo,9)+;
               put_kope(tmp9->summa,12))
    sm1 += tmp9->kol_vo
    SM2 += tmp9->summa
    skip
  enddo
  add_string(replicate("─",sh))
  add_string(padR("Итого: ",50)+;
               STR(SM1,9)+;
               put_kope(SM2,12))
  close databases
  fclose(fp)
  viewtext(n_file,,,,(sh>80),,,1)
  restscreen(buf)
  use (cur_dir+"tmp1") index (cur_dir+"tmp1") new
  goto (rec_tmp1)
endif
return ret

*

***** 03.04.14
Function f2_pl_vzaim(nKey,oBrow,regim)
Static sf_nomer, sf_date, sa_nomer, sa_date
Local ret := -1, buf, fl := .f., rec, tmp_color, ah, ahu, i, j, k, fl_one,;
      s, sh, HH := 76, reg_print, arr_title, name_file := "vzaimoza"+stxt,;
      d, sd, kol_usl, sk, ss, is_fio, is_sokr, old, mas_pmt
do case
  case regim == "edit"
    do case
      case nKey == K_F9
        DEFAULT sf_nomer TO space(10), sf_date TO ctod(""), ;
                sa_nomer TO space(10), sa_date TO ctod("")
        mas_pmt := {;
          "Печать счёта-~фактуры",;
          "Печать ~акта выполненных работ",;
          "~Реестр медуслуг в Excel (новый)",;
          "Реестр - ~сокращённая форма (старый)",;
          "Реестр - ~полная форма (старый)"}
        select TMP
        rec := recno()
        sk := ss := 0
        go top
        dbeval({|| sk++, ss += tmp->stoim })
        go top
        do while (i := popup_prompt(T_ROW,T_COL-5,i,mas_pmt,,,;
                                    "BG+/RB,W+/R,W+/RB,GR+/R")) > 0
          if eq_any(i,1,3)
            if (k := input_diapazon(maxrow()-4,9,maxrow()-2,68,color8,;
                          {"Введите номер","и дату","счёта-фактуры"},;
                          {sf_nomer,sf_date})) != NIL
              sf_nomer := k[1]
              sf_date := k[2]
              if i == 1
                pl_print_faktura(k,sk,ss)
              else
                rees_new_vzaim(k)
              endif
            endif
          elseif i == 2
            if (k := input_diapazon(maxrow()-4,14,maxrow()-2,64,color8,;
                          {"Введите номер","и дату","акта"},;
                          {sa_nomer,sa_date})) != NIL
              sa_nomer := k[1]
              sa_date := k[2]
              pl_print_akt(k,sk,ss)
            endif
          elseif i == 4
            rees1_vzaim(name_file)
          elseif i == 5
            rees2_vzaim(name_file)
          endif
          close databases
          use (cur_dir+"tmp1") index (cur_dir+"tmp1") new
          goto (rec_tmp1)
          use (cur_dir+"tmp2") index (cur_dir+"tmp2") new
          G_Use(dir_server+"kartotek",,"KART")
          use (cur_dir+"tmp") new alias TMP
          set relation to kod_k into KART
          set index to (cur_dir+"tmp")
          goto (rec)
        enddo
      case nKey == K_ENTER
        buf := save_row(maxrow())
        ah := {} ; ahu := {}
        mywait()
        if is_zf_stomat == 1
          Use_base("humanst")
        endif
        G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HPU")
        G_Use(dir_server+"hum_p",,"HP")
        select TMP2
        find (str(tmp->(recno()),6))
        do while tmp2->rec_tmp == tmp->(recno()) .and. !eof()
          select HP
          goto (tmp2->rec_hp)
          arr := {hp->KOD_DIAG ,;
                  hp->SOPUT_B1 ,;
                  hp->SOPUT_B2 ,;
                  hp->SOPUT_B3 ,;
                  hp->SOPUT_B4 ,;
                  hp->SOPUT_B5}
          for i := 1 to len(arr)
            if !empty(arr[i]) .and. ascan(ah,arr[i]) == 0
              aadd(ah,arr[i])
            endif
          next
          select HPU
          find (str(hp->(recno()),7))
          do while hpu->kod == hp->(recno())
            s := ""
            if is_zf_stomat == 1
              select HUMANST
              find (str(2,1)+str(hpu->(recno()),8))
              if found()
                s += " ЗФ:"
                if !empty(humanst->KOD_DIAG)
                  s += alltrim(humanst->KOD_DIAG)+","
                endif
                s += alltrim(humanst->ZF)
              endif
            endif
            aadd(ahu, {c4tod(hpu->date_u),;
                       hpu->u_kod,;
                       s,;
                       hpu->kol,;
                       hpu->stoim,;
                       hpu->kod_vr,;
                       {hpu->med1,hpu->med2,hpu->med3},;
                       {hpu->san1,hpu->san2,hpu->san3};
                      })
            select HPU
            skip
          enddo
          select TMP2
          skip
        enddo
        hp->(dbCloseArea())
        hpu->(dbCloseArea())
        if is_zf_stomat == 1
          humanst->(dbCloseArea())
        endif
        //
        G_Use(dir_server+"plat_ms",,"PMS")
        G_Use(dir_server+"mo_pers",,"perso")
        G_Use(dir_server+"uslugi",,"USL")
        for i := 1 to len(ahu)
          // услуга
          select USL
          goto (ahu[i,2])
          ahu[i,2] := usl->shifr
          ahu[i,3] := alltrim(usl->name)+ahu[i,3]  // ЗФ
          // врач
          if ahu[i,6] == 0
            ahu[i,6] := "--"
          else
            select perso
            goto (ahu[i,6])
            ahu[i,6] := fam_i_o(perso->fio)
          endif
          // медсестра
          s := ""
          for j := 1 to len(ahu[i,7])
            if ahu[i,7,j] > 0
              select PMS
              goto (ahu[i,7,j])
              s += fam_i_o(pms->fio)+", "
            endif
          next
          ahu[i,7] := if(empty(s), "--", substr(s,1,len(s)-2))
          // санитарка
          s := ""
          for j := 1 to len(ahu[i,8])
            if ahu[i,8,j] > 0
              select PMS
              goto (ahu[i,8,j])
              s += fam_i_o(pms->fio)+", "
            endif
          next
          ahu[i,8] := if(empty(s), "--", substr(s,1,len(s)-2))
        next
        pms->(dbCloseArea())
        perso->(dbCloseArea())
        usl->(dbCloseArea())
        //
        asort(ahu,,,{|x,y| if(x[1] == y[1], ;
                       fsort_usl(x[2]) < fsort_usl(y[2]), x[1] < y[1]) } )
        //
        arr_title := {;
"────────┬──────────────────────────────────────┬─────┬─────────┬────────────────────",;
"        │                                      │     │         │ФИО врача,          ",;
"  Дата  │      Шифр и наименование услуги      │ Кол.│Стоимость│    медсестры,      ",;
" лечения│                                      │услуг│         │    санитарки       ",;
"────────┴──────────────────────────────────────┴─────┴─────────┴────────────────────"}
        sh := len(arr_title[1])
        fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
        R_Use(dir_server+"organiz",,"ORG")
        add_string(alltrim(org->name))
        org->(dbCloseArea())
        add_string("")
        add_string(alltrim(kart->fio)+iif(empty(kart->mr_dol),""," ["+upper(alltrim(kart->mr_dol))+"]"))
        add_string("")
        add_string("Дата рождения: "+full_date(kart->date_r))
        add_string("Проживает: "+alltrim(kart->adres))
        add_string(tmp1->name)
        if !empty(tmp->d_polis)
          add_string("Полис: "+alltrim(tmp->d_polis))
        endif
        if (fl_one := (tmp->n_data == tmp->k_data))
          s := "Дата лечения: "+date_month(tmp->n_data)
        else
          s := "Срок лечения: "+full_date(tmp->n_data)+"-"+full_date(tmp->k_data)
        endif
        add_string("")
        add_string(s)
        s := "Диагноз: "
        aeval(ah, {|x| s += alltrim(x)+", " } )
        add_string("")
        add_string(substr(s,1,len(s)-2))
        aeval(arr_title, {|x| add_string(x) } )
        ah := array(3)
        d := iif(len(ahu)==0, tmp->k_data, ahu[1,1])
        sd := kol_usl := 0
        for i := 1 to len(ahu)
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          if d == ahu[i,1]
            if i > 1
              add_string(replicate(" - ",sh/3))
            endif
          else
            add_string(padl("Итого за "+date_8(d)+": "+lput_kop(sd),sh-21,"-"))
            sd := 0
          endif
          d := ahu[i,1]
          perenos(ah,alltrim(ahu[i,2])+" "+ahu[i,3],38)
          add_string(date_8(ahu[i,1])+" "+padr(ah[1],38)+put_val(ahu[i,4],4)+;
                     put_kopE(ahu[i,5],12)+" "+ahu[i,6])
          add_string(space(9)+padl(alltrim(ah[2]),38)+space(16)+" "+ahu[i,7])
          add_string(space(9)+padl(alltrim(ah[3]),38)+space(16)+" "+ahu[i,8])
          kol_usl += ahu[i,4]
          sd += ahu[i,5]
        next
        if !fl_one
          add_string(padl("Итого за "+date_8(d)+": "+lput_kop(sd),sh-21,"-"))
        endif
        add_string(replicate("─",sh))
        add_string(padl("Итого : "+put_val(kol_usl,4)+put_kopE(tmp->stoim,12),sh-21))
        add_string("")
        add_string("")
        add_string("         Зав.отделением _________________                 Дата ______________")
        fclose(fp)
        rest_box(buf)
        reg_print := 5
        viewtext(name_file,,,,(sh>80),,,reg_print)
        select TMP
    endcase
endcase
return ret

*

***** 11.02.13
Function f3_pl_vzaim()
select TMP
find (str(hp->tip_usl,1)+str(hp->pr_smo,6)+str(hp->kod_k,7))
if !found()
  append blank
  tmp->tip_usl := hp->tip_usl
  tmp->pr_smo  := hp->pr_smo
  tmp->kod_k   := hp->kod_k
  tmp->n_data  := hp->n_data
  tmp->k_data  := hp->k_data
  if !empty(hp->d_polis)
    tmp->d_polis := hp->d_polis
  endif
endif
if tmp->n_data > hp->n_data
  tmp->n_data := hp->n_data
endif
if tmp->k_data < hp->k_data
  tmp->k_data := hp->k_data
endif
tmp->kol ++
tmp->stoim += hp->cena
//
select TMP2
append blank
tmp2->rec_tmp := tmp->(recno())
tmp2->rec_hp  := hp->(recno())
tmp2->d_polis := hp->d_polis
if tmp2->(lastrec()) % 5000 == 0
  Commit
endif
return NIL

*

*****
Function vr_vzaimozach(regim)
Local i, j, k, fl, fl_exit := .f., buf := save_row(maxrow()),;
      sh, HH := 60, reg_print := 2, arr_title, n_file := "vr_vzaim"+stxt
Private arr_m
if (arr_m := year_month()) == NIL
  return NIL
endif
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
dbcreate(cur_dir+"tmp", {{"kod",        "N",      4,      0},; // код персонала
                 {"FIO",        "C",     50,      0},;  // Ф.И.О. врача
                 {"TRUDOEM",    "N",     11,      4},;  // трудоемкость услуг УЕТ
                 {"KOL"    ,    "N",      6,      0},;  // количество услуг
                 {"STOIM_OB",   "N",     12,      2},;  // итоговая стоимость услуг
                 {"STOIM"  ,    "N",     12,      2},;  // итоговая стоимость услуг
                 {"ZARPLATA",   "N",     12,      2}})  // на зарплату
use (cur_dir+"tmp")
index on str(kod,4) to (cur_dir+"tmp")
useUch_Usl()
G_Use(dir_server+"uslugi",,"USL")
if eq_any(is_oplata,5,6,7)
  open_opl_5()
endif
G_Use(dir_server+"mo_pers",,"perso")
G_Use(dir_server+"plat_ms",,"PMS")
G_Use(dir_server+"kartotek",,"KART")
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
if pi1 == 2
  G_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
  dbseek(dtos(arr_m[5]),.t.)
  do while human->k_data <= arr_m[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    select HU
    find (str(human->(recno()),7))
    do while hu->kod == human->(recno())
      f1_vr_vzaim(regim)
      select HU
      skip
    enddo
    select HUMAN
    skip
  enddo
else
  G_Use(dir_server+"hum_p",dir_server+"hum_pc","HUMAN")
  for xx := 0 to 2
    select HUMAN
    dbseek(str(xx,1)+"1"+dtos(arr_m[5]),.t.)
    do while human->tip_usl==xx .and. human->date_close <= arr_m[6] .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select HU
      find (str(human->(recno()),7))
      do while hu->kod == human->(recno())
        f1_vr_vzaim(regim)
        select HU
        skip
      enddo
      select HUMAN
      skip
    enddo
    if fl_exit ; exit ; endif
  next
endif
j := tmp->(lastrec())
close databases
rest_box(buf)
if fl_exit
  // ничего
elseif j == 0
  func_error(4,"Нет сведений "+arr_m[4])
else
  mywait()
  arr_title := {;
"───────────────────────────────────────┬──────┬─────────┬─────────┬──────┬──────────",;
"                                       │      │         │         │% вз/з│          ",;
"                 Ф.И.О.                │Кол-во│Стоимость│ Зарплата│от общ│Примечание",;
"                                       │ услуг│  услуг  │         │кол-ва│          ",;
"───────────────────────────────────────┴──────┴─────────┴─────────┴──────┴──────────"}
  sh := len(arr_title[1])
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string("ПЛАТНЫЕ УСЛУГИ")
  add_string(center("Работа персонала по ДМС и взаимозачету",sh))
  add_string(center(arr_m[4],sh))
  add_string(center(expand({"ВРАЧИ","МЕДСЕСТРЫ","САНИТАРКИ"}[regim]),sh))
  do case
    case pi1 == 2
      s := "[ по дате окончания лечения ]"
    case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
  endcase
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  skol := sstoim := sstoim_ob := szarplata := 0
  use (cur_dir+"tmp") new
  index on upper(fio) to (cur_dir+"tmp") for stoim > 0
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    s := padr(tmp->fio,40)+;
         put_val(tmp->kol,5)+;
         put_kopE(tmp->stoim,11)+;
         put_kopE(tmp->zarplata,10)+;
         put_val_0(tmp->stoim/tmp->stoim_ob*100,7,2)+;
         " __________"
    add_string(s)
    skol += tmp->kol
    sstoim += tmp->stoim
    sstoim_ob += tmp->stoim_ob
    szarplata += tmp->zarplata
    skip
  enddo
  add_string(replicate("─",sh))
  s := padc("И Т О Г О :",40)+;
       put_val(skol,5)+;
       put_kopE(sstoim,11)+;
       put_kopE(szarplata,10)+;
       put_val_0(sstoim/sstoim_ob*100,7,2)
  add_string(s)
  fclose(fp)
  close databases
  rest_box(buf)
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
return NIL

*

*****
Function f1_vr_vzaim(regim)
Local i, mtrud := 0, koef := 1, koef_z := {1,1,1}
if hu->u_kod > 0 .and. (hu->kol > 0 .or. hu->stoim > 0)
  kart->(dbGoto(human->kod_k))
  mtrud := round_5(hu->kol * opr_uet(kart->vzros_reb), 4)
  do case
    case regim == 1 .and. hu->kod_vr > 0
      koef_z := ret_koef_z(hu->u_kod,hu->kod_vr,0)
      select TMP
      find (str(hu->kod_vr,4))
      if !found()
        append blank
        tmp->kod := hu->kod_vr
        perso->(dbGoto(tmp->kod))
        tmp->fio := perso->fio
      endif
      tmp->stoim_ob += hu->stoim
      if human->tip_usl > 0  // взаимозачет
        tmp->trudoem += mtrud
        tmp->kol += hu->kol
        tmp->stoim += hu->stoim
        tmp->zarplata += hu->stoim * koef_z[1]
      endif
    case regim == 2
      koef := 0
      if hu->med1 > 0
        ++koef
      endif
      if hu->med2 > 0
        ++koef
      endif
      if hu->med3 > 0
        ++koef
      endif
      for i := 1 to 3
        pole := "hu->med"+lstr(i)
        if &pole > 0
          select TMP
          find (str(&pole,4))
          if !found()
            append blank
            tmp->kod := &pole
            pms->(dbGoto(tmp->kod))
            tmp->fio := pms->fio
          endif
          tmp->stoim_ob += hu->stoim / koef
          if human->tip_usl > 0  // взаимозачет
            tmp->trudoem += mtrud
            tmp->kol += hu->kol
            tmp->stoim += hu->stoim / koef
            tmp->zarplata += round_5(hu->stoim * mem_pl_ms / 100 / koef, 2)
          endif
        endif
      next
    case regim == 3
      koef := 0
      if hu->san1 > 0
        ++koef
      endif
      if hu->san2 > 0
        ++koef
      endif
      if hu->san3 > 0
        ++koef
      endif
      for i := 1 to 3
        pole := "hu->san"+lstr(i)
        if &pole > 0
          select TMP
          find (str(&pole,4))
          if !found()
            append blank
            tmp->kod := &pole
            pms->(dbGoto(tmp->kod))
            tmp->fio := pms->fio
          endif
          tmp->stoim_ob += hu->stoim / koef
          if human->tip_usl > 0  // взаимозачет
            tmp->trudoem += mtrud
            tmp->kol += hu->kol
            tmp->stoim += hu->stoim / koef
            tmp->zarplata += round_5(hu->stoim * mem_pl_sn / 100 / koef, 2)
          endif
        endif
      next
  endcase
endif
return NIL

*

*****
Function pr_opl_vz()
Local i, j, arr, begin_date, end_date, s, buf := save_row(maxrow()),;
      fl_exit := .f., sh, HH := 58, reg_print, ssumma := 0,;
      arr_title, name_file := "vzoplata"+stxt, arr_m, adbf,;
      menu_opl := {{"безналичн.",0},;
                   {"наличными ",1},;
                   {"в/зачет   ",2}}
if (arr_m := year_month()) == NIL
  return NIL
endif
mywait()
reg_print := 2
arr_title := {;
"──────────┬──────────┬──────────┬───────────────┬───────────────────────────────────",;
"   Дата   │   Тип    │  Сумма   │  Примечание   │  Предприятие (СМО)                ",;
"  оплаты  │  оплаты  │          │               │  (ФИО больного)                   ",;
"──────────┴──────────┴──────────┴───────────────┴───────────────────────────────────"}
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string(center("Оплата по ДМС и взаимозачету",sh))
add_string(center(arr_m[4],sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
//
G_Use(dir_server+"kartotek",,"KART")
G_Use(dir_server+"p_pr_vz",,"VZ")
G_Use(dir_server+"p_d_smo",,"SMO")
G_Use(dir_server+"plat_vz",,"OPL")
index on dtos(date_opl)+str(tip,1)+str(pr_smo,6)+str(kod_k,7) to (cur_dir+"tmp") ;
      for between(date_opl,arr_m[5],arr_m[6]) progress
go top
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  s := full_date(opl->date_opl)+" "+;
       inieditspr(A__MENUVERT, menu_opl, opl->tip_opl)+" "+;
       put_kopE(opl->summa_opl,10)+" "+;
       opl->prim+" "
  ssumma += opl->summa_opl
  if opl->tip == 1
    smo->(dbGoto(opl->pr_smo))
    kart->(dbGoto(opl->kod_k))
    s += alltrim(smo->name)
  else
    vz->(dbGoto(opl->pr_smo))
    s += alltrim(vz->name)
  endif
  add_string(s)
  if opl->tip == 1
    add_string(space(49)+alltrim(kart->fio))
  endif
  select OPL
  skip
enddo
if !empty(ssumma)
  add_string(replicate("-",sh))
  add_string(put_kopE(ssumma,32))
endif
close databases
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,(sh>80),,,reg_print)
return NIL

*

Function st_v_vrach(get,pole_vr,regim)
// regim = 0  - по БД mo_pers
// regim = 1  - медсестры по БД plat_ms
// regim = 2  - санитарки по БД plat_ms
// regim = 3  - по БД mo_pers через VGET
Local lval, lpole, fl := .t.
DEFAULT regim TO 0
if regim == 3
  lval := get:varget()
  lpole := readvar()
else
  lval := &(readvar())
  lpole := readvar()
endif
if lval == 0
  &pole_vr := space(30)
elseif lval > 0
  DEFAULT regim TO 0
  if equalany(regim,0,3)
    select PERSO
    find (str(lval,5))
    if found()
      &pole_vr := padr(fam_i_o(perso->fio),30)
    else
      fl := .f.
    endif
  else   // regim == 1 или 2
    select MS
    find (str(regim,1)+str(lval,5))
    if found()
      &pole_vr := padr(ms->fio,30)
    else
      fl := .f.
    endif
  endif
  if !fl
    //&lpole := get:original
    get:varput( get:original )
    return func_error(4,"Человека с таким кодом нет в базе данных персонала!")
  endif
else
  //&lpole := get:original
  get:varput( get:original )
  return func_error(4,"Нельзя вводить отрицательное число!")
endif
if regim < 3
  update_get(pole_vr)
endif
return .t.

*

*****
Function valid_mest_inog(get,old,k,fl)
DEFAULT k TO 1, fl TO .f.
if k == 1
  if old != NIL .and. m1mest_inog != old
    if fl
      say_rajreg(get:row,k,m1mest_inog)
    endif
    if m1mest_inog < 2
      miREG_RAB := ""
    endif
    mrajon := space(34) ; m1rajon := 0
    update_get("mrajon")
  endif
else
  if old != NIL .and. m1mi_git != old
    if fl
      say_rajreg(get:row,k,m1mi_git)
    endif
    if m1mi_git < 2
      miREG_GIT := ""
    endif
    mrajon_git := space(32) ; m1rajon_git := 0
    update_get("mrajon_git")
  endif
endif
return .t.

*

*****
Function get_slugba(k,r,c)
Local ret, r1, r2
if (r1 := r+1) > maxrow()/2
  r2 := r-1 ; r1 := 2
else
  r2 := maxrow()-2
endif
G_Use(dir_server+"slugba",dir_server+"slugba","SL")
if k > 0
  find (str(k,3))
endif
if Alpha_Browse(r1,27,r2,77,"f2spr_other",color0)
  ret := mslugba := { sl->shifr, lstr(sl->shifr)+". "+alltrim(sl->name) }
endif
sl->(dbCloseArea())
return ret

*

*****
Function put_tab_nom(ltab_nom,lsvod_nom)
Local s := lstr(ltab_nom)
if !empty(lsvod_nom) .and. ltab_nom != lsvod_nom
  s := "("+lstr(lsvod_nom)+")"+s
endif
return s

*

*****
Function input_kperso()
Local mas1 := {}, buf := savescreen(), i, arr := {},;
      mas3 := {{5,0},},;
      mas2 := {{1,"Таб.N"},;
               {2,"  Ф.И.О."}},;
      blk := {|b,ar,nDim,nElem,nKey| f1_i_kperso(b,ar,nDim,nElem,nKey)}
G_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
if len(mas1) == 0
  aadd(mas1, {0,space(50),0} )
endif
change_attr()
Arrn_Browse(2,9,maxrow()-2,70,mas1,mas2,1,,color1,;
            "Ввод списка персонала","G+/B",;
            .t.,,mas3,blk,{.t.,.t.,.t.})
for i := 1 to len(mas1)
  if mas1[i,1] > 0 .and. ascan(arr, {|x| x[1] == mas1[i,3] } ) == 0
    aadd(arr, {mas1[i,3],"",mas1[i,1]} )
  endif
next
close databases
if len(arr) == 0
  arr := NIL
endif
restscreen(buf)
return arr

*

*****
Function f1_i_kperso(b,ar,nDim,nElem,nKey)
LOCAL nRow := ROW(), nCol := COL(), i, j, flag := .f., buf,;
      mpic := {"99999",}
DO CASE
  CASE nKey == K_DOWN .or. nKey == K_INS
    b:panHome()
  OTHERWISE
    if (nKey == K_ENTER .or. between(nKey,48,57))
      if between(nKey,48,57)
        keyboard chr(nKey)
      endif
      Private mkod := parr[nElem,nDim]
      @ nRow, nCol GET mkod picture mpic[nDim]
      myread({"up","down"})
      if lastkey() != K_ESC
        find (str(mkod,5))
        if !(fl := found())
          func_error(4,"Человека с таким таб.номером нет в базе данных персонала!")
        else
          parr[nElem,1] := mkod
          parr[nElem,2] := perso->fio
          parr[nElem,3] := perso->kod
          flag := .t.
        endif
      endif
    endif
ENDCASE
@ nRow, nCol SAY ""
return flag

*

***** 01.04.14
Function ob2_v_usl(is_get,r1,mtitul)
Local t_arr[BR_LEN], buf := savescreen(), k, ret
DEFAULT is_get TO .f., r1 TO T_ROW
if r1 > 14 ; r1 := 14 ; endif
R_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
use (cur_dir+"tmp") index (cur_dir+"tmpk"),(cur_dir+"tmpn") new alias TMP
set order to 2
t_arr[BR_TOP] := r1
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 1
t_arr[BR_RIGHT] := 78
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitul
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_OPEN] := {|| !eof() }
t_arr[BR_ARR_BROWSE] := {"═","░","═",,.t.}
t_arr[BR_COLUMN] := {{ "   Шифр", {|| tmp->u_shifr } },;
                     { center("Наименование услуги",65), {|| left(tmp->u_name,65) } } }
t_arr[BR_STAT_MSG] := {|| ;
  status_key("^<Esc>^ выход;  ^<Ins>^ добавление;  ^<Del>^ удаление услуги;  ^<F9>^ печать списка") }
t_arr[BR_EDIT] := {|nk,ob| ob21v_usl(nk,ob,"edit",mtitul) }
edit_browse(t_arr)
if is_get
  go top
  k := 0
  dbeval({|| if(tmp->u_kod > 0, ++k, nil)})
  ret := {k,"Кол-во услуг - "+lstr(k)}
endif
tmp->(dbCloseArea())
usl->(dbCloseArea())
restscreen(buf)
if !is_get
  WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
endif
return ret

*****
Function ob21v_usl(nKey,oBrow,regim,mtitul)
Local ret := -1, s
Local buf, fl := .f., rec, rec1, k := 19, tmp_color, n_file, sh := 80, HH := 60
do case
  case regim == "edit"
    do case
      case nKey == K_F9
        DEFAULT mtitul TO "Список выбранных услуг"
        buf := save_row(maxrow())
        mywait()
        rec := recno()
        Private reg_print := 2
        n_file := "ob2_v_us"+stxt
        fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
        add_string("")
        add_string(center(mtitul,sh))
        add_string("")
        go top
        do while !eof()
          verify_FF(HH, .t., sh)
          s := tmp->u_shifr
          select USL
          find (tmp->u_shifr)
          if found() .and. !empty(usl->shifr1) .and. !(tmp->u_shifr==usl->shifr1)
            s += "("+alltrim(usl->shifr1)+")"
          endif
          add_string(s+alltrim(tmp->u_name))
          select TMP
          skip
        enddo
        goto (rec)
        fclose(fp)
        rest_box(buf)
        viewtext(n_file,,,,(.t.),,,reg_print)
      case nKey == K_INS
        save screen to buf
        Private mshifr := space(10)
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1,21,pc2-1,,"Добавление услуги",cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+27 say "Шифр услуги" get mshifr picture "@!" ;
                     valid valid_shifr()
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !empty(mshifr)
          if "*" == alltrim(mshifr)
            func_error(4,'Воспользуйтесь режимом "Все услуги"!')
          elseif "*" $ mshifr .or. "?" $ mshifr
            mshifr := alltrim(mshifr)
            mywait()
            select USL
            go top
            do while !eof()
              if like(mshifr,usl->shifr) .or. like(mshifr,usl->shifr1)
                select TMP
                set order to 1
                fl_found := fl := .t.
                AddRec(4)
                ret := 0
                replace tmp->u_shifr with usl->shifr, tmp->u_name with usl->name,;
                        tmp->u_kod with usl->kod
              endif
              select USL
              skip
            enddo
            select TMP
            set order to 2
            if fl
              oBrow:goTop()
            else
              func_error(4,"Не найдено услуг по шаблону <"+mshifr+">.")
            endif
          else
            select USL
            find (mshifr)
            fl := found()
            select TMP
            if fl
              set order to 1
              fl_found := .t.
              AddRec(4)
              rec := recno()
              replace tmp->u_shifr with mshifr, tmp->u_name with usl->name,;
                      tmp->u_kod with usl->kod
              set order to 2
              oBrow:goTop()
              goto (rec)
              ret := 0
            else
              func_error(4,"Услуги с данным шифром нет в справочнике!")
            endif
          endif
        endif
        if !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. !empty(tmp->u_kod)
        rec1 := 0
        rec := recno()
        skip
        if !eof()
          rec1 := recno()
        endif
        goto (rec)
        DeleteRec()
        if rec1 == 0
          oBrow:goBottom()
        else
          goto (rec1)
        endif
        ret := 0
        if eof()
          ret := 1
        endif
    endcase
endcase
return ret

*

*****
Function f_is_otd(arr_o,pole_o)
return ( ascan(arr_o,{|x| pole_o == x[1] }) > 0 )

***** 23.12.15
Function inputN_otd(r,c,fl_all_uch,fl_all_otd,a_inp_uch,/*@*/c_otd)
Static st_otd := {}
Local i, k, mas_o := {}, mas := {}, t_mas, c2, pole,;
      buf := savescreen(), tmp_select := select(), l_a_otd
if a_inp_uch == NIL // запросить учреждение
  k := input_uch(r,c,iif(fl_all_uch,,sys_date))
else  // учреждение уже было ранее выбрано
  k := glob_uch
endif
if k != NIL
  mywait()
  pole := "otd->dbegin" ; pole2 := "otd->dend"
  if glob_task == X_PLATN
    pole += "p" ; pole2 += "p"
  elseif glob_task == X_ORTO
    pole += "o" ; pole2 += "o"
  endif
  R_Use(dir_server+"mo_otd",,"OTD")
  go top
  do while !eof()
    if otd->kod_lpu == glob_uch[1] .and. ;
          iif(fl_all_otd, .t., between_date(&pole,&pole2,sys_date))
      aadd( mas_o, otd->name )
      aadd( mas, otd->(recno()) )
    endif
    skip
  enddo
  otd->(dbCloseArea())
  if tmp_select > 0 ; select(tmp_select) ; endif
  count_otd := c_otd := len(mas)
  if count_otd == 1
    glob_otd := {mas[1],mas_o[1]}
    restscreen(buf)
    return {glob_otd}
  endif
  if r < 0 // т.е. GET находится внизу экрана
    k := abs(r)-2
    if (r := k - count_otd - 1) < 2
      r := 2
    endif
  else
    if (k := r + count_otd + 1) > maxrow()-2
      k := maxrow()-2
    endif
  endif
  c2 := c + 35 + 1
  if c2 > 77
    c2 := 77 ; c := 76 - 35
  endif
  t_mas := aclone(mas_o)
  if len(st_otd) == 0
    if glob_otd[1] > 0
      aadd(st_otd,glob_otd[1])
    else
      aeval(mas, {|x| aadd(st_otd,x) } )
    endif
  endif
  aeval(t_mas, {|x,i| ;
        t_mas[i] := if(ascan(st_otd,mas[i]) > 0, " * ", "   ")+t_mas[i]})
  status_key("^<Esc>^ отказ;  ^<Enter>^ подтверждение;  ^<Ins>^ смена признака выбора отделения")
  do while .t.
    l_a_otd := NIL
    if popup(r,c,k,c2,t_mas,i,color_uch,.t.,"fmenu_reader",,;
             alltrim(glob_uch[2]),col_tit_uch) > 0
      l_a_otd := {} ; st_otd := {}
      for i := 1 TO len(t_mas)
        if "*" == substr(t_mas[i],2,1)
          aadd(l_a_otd, { mas[i],mas_o[i] } )
          aadd(st_otd, mas[i])
        endif
      next
      if empty(l_a_otd)
        func_error(4,"Необходимо отметить хотя бы одно отделение!")
        loop
      else
        if (k := len(l_a_otd)) == 1
          glob_otd := l_a_otd[1]
        endif
        exit
      endif
    else
      exit
    endif
  enddo
endif
restscreen(buf)
return l_a_otd

*

*****
Function titleN_otd(arr_o,lsh,c_otd)
Local i, t_arr[2], s := ""
if !(type("count_otd")=="N")
  count_otd := iif(c_otd==NIL,1,c_otd)
endif
if count_otd > 1 .and. valtype(arr_o) == "A"
  if count_otd == len(arr_o)
    add_string(center("[ по всем отделениям ]",lsh))
  else
    aeval(arr_o, {|x| s += '"'+alltrim(x[2])+'", ' } )
    s := substr(s,1,len(s)-2)
    for i := 1 to perenos(t_arr,s,lsh)
      add_string(center(alltrim(t_arr[i]),lsh))
    next
  endif
endif
return NIL

*

*****
Function err_date_diap(_ld,_ls)
Local fl := .t.
if !empty(_ld)
  if !empty(mem_date_1) .and. _ld < mem_date_1
    fl := .f.
  endif
  if !empty(mem_date_2) .and. _ld > mem_date_2
    fl := .f.
  endif
  if !fl
    func_error(4,'Значение поля "'+_ls+'" выходит за допустимый диапазон времени!')
  endif
endif
return fl

*

*****
Function say_rajreg(r,k,lmi)
@ r,iif(k==1,38,40) say iif(lmi==2,"регион","район ")
return NIL

*

*****
Function ret_koef_z(mkod_usl,mkod_vr,mkod_as)
Local mk := {0,0,0}
return mk

*

*****
Function f_is_uch(arr_u,pole_u)
return ascan(arr_u,{|x| pole_u == x[1] }) > 0

***** 23.12.15
Function inputN_uch(r,c,date1,date2,/*@*/c_uch)
Static st_uch := {}
Local i, k, mas_u := {}, mas := {}, t_mas, c2,;
      buf := savescreen(), tmp_select := select(), l_a_uch
R_Use(dir_server+"mo_uch",,"UCH")
go top
do while !eof()
  if between_date(uch->DBEGIN,uch->DEND,date1,date2)
    aadd(mas_u, uch->name)
    aadd(mas, uch->(recno()))
  endif
  skip
enddo
uch->(dbCloseArea())
if tmp_select > 0 ; select(tmp_select) ; endif
count_uch := c_uch := len(mas)
if count_uch == 0
  func_error(4,"Справочник учреждений пуст!")
  return NIL
elseif count_uch == 1
  is_all_uch := .f.
  glob_uch := {mas[1],mas_u[1]}
  restscreen(buf)
  return {glob_uch}
else
  if r < 0 // т.е. GET находится внизу экрана
    k := abs(r)-2
    if (r := k - count_uch - 1) < 2
      r := 2
    endif
  else
    if (k := r + count_uch + 1) > maxrow()-2
      k := maxrow()-2
    endif
  endif
  c2 := c + 35 + 1
  if c2 > 77
    c2 := 77 ; c := 76 - 35
  endif
  t_mas := aclone(mas_u)
  if len(st_uch) == 0
    aeval(mas, {|x| aadd(st_uch,x) } )
  endif
  aeval(t_mas, {|x,i| ;
        t_mas[i] := if(ascan(st_uch,mas[i]) > 0, " * ", "   ")+t_mas[i]})
  status_key("^<Esc>^ отказ;  ^<Enter>^ подтверждение;  ^<Ins>^ смена признака выбора учреждения")
  do while .t.
    l_a_uch := NIL
    if popup(r,c,k,c2,t_mas,i,color_uch,.t.,"fmenu_reader",,;
             "Учреждения",col_tit_uch) > 0
      l_a_uch := {} ; st_uch := {}
      for i := 1 TO len(t_mas)
        if "*" == substr(t_mas[i],2,1)
          aadd(l_a_uch, { mas[i],mas_u[i] } )
          aadd(st_uch, mas[i])
        endif
      next
      if empty(l_a_uch)
        func_error(4,"Необходимо отметить хотя бы одно учреждение!")
        loop
      else
        if (k := len(l_a_uch)) == 1
          glob_uch := l_a_uch[1]
        endif
        is_all_uch := (k == count_uch)
        exit
      endif
    else
      exit
    endif
  enddo
endif
restscreen(buf)
return l_a_uch

*****
Function titleN_uch(arr_u,lsh,c_uch)
Local i, t_arr[2], s := ""
if !(type("count_uch")=="N")
  count_uch := iif(c_uch==NIL,1,c_uch)
endif
if count_uch > 1
  if count_uch == len(arr_u)
    add_string(center("[ по всем учреждениям ]",lsh))
  else
    aeval(arr_u, {|x| s += '"'+alltrim(x[2])+'", ' } )
    s := substr(s,1,len(s)-2)
    for i := 1 to perenos(t_arr,s,lsh)
      add_string(center(alltrim(t_arr[i]),lsh))
    next
  endif
endif
return NIL

*

***** 03.04.14 вывести дату в 24 строке
Function date_24(mdate)
@ maxrow(),69 say full_date(mdate) color "W/R"
return NIL

*

*****
Function usl_p_kart(mkod_human,mkod_lpu)
Local k
R_Use(dir_server+"kartotek",,"KART")
goto (glob_kartotek)
Private smvzros_reb := kart->vzros_reb, ;
        smdate_r := kart->date_r, ;
        smpol := kart->pol
kart->(dbCloseArea())
if is_zf_stomat == 1
  k := STuslPkart(mkod_human,mkod_lpu)
else
  k := SOuslPkart(mkod_human,mkod_lpu)
endif
return k

*****
Function fp_ret_lpu(k,r,c)
Local fl := .f., mas, r1, r2
if r < 13
  r1 := r+1
else
  r2 := r-1
endif
if inputE_otd(r1,c,r2)
  mas := {glob_uch[1],padr(glob_uch[2],30)}
  m1otd := glob_otd[1] ; motd := padr(glob_otd[2],30)
endif
return mas

*

*****
Function sv_ved_plat()
Local arr, arr_m, buf, arr_title, sh, HH := 40, reg_print := 3, ;
      n_file := "svod_ved"+stxt, arr_otd := {}, old_kateg, lfio
pi := 3
if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) == NIL
  return NIL
endif
Private ym_kol_mes := 1
if (arr := year_month()) == NIL
  return NIL
endif
arr_m := aclone(arr)
G_Use(dir_server+"mo_otd",,"OTD")
dbeval({|| aadd(arr_otd,{otd->(recno()),otd->name,otd->kod_lpu}) },;
       {|| f_is_uch(st_a_uch,otd->kod_lpu)} )
OTD->(dbCloseArea())
buf := save_row(maxrow())
if sv1_ved_plat(arr,arr_otd) .and. sv2_ved_plat(arr,arr_otd)
  mywait()
  arr_title := array(6)
  arr_title[1] := "────────────────────────────────────────┬─────────────────────────┬──────────────────┬──────────────────┬──────────────────╥─────────╥────────────"
  arr_title[2] := "                                        │    Страховая медицина   │  Платные услуги  │ Доплаты за услуги│    Материалы     ║         ║            "
  arr_title[3] := "                                        ├──────┬──────┬───────────┼──────┬───────────┼──────┬───────────┼──────┬───────────╢         ║            "
  arr_title[4] := "                                        │Кол-во│  %%  │ Стоимость │Кол-во│ Стоимость │Кол-во│ Стоимость │Кол-во│ Стоимость ║         ║  И Т О Г О "
  arr_title[5] := "                 Ф.И.О.                 │ услуг│выпол.│   услуг   │ услуг│   услуг   │ услуг│   услуг   │ услуг│   услуг   ║         ║            "
  arr_title[6] := "────────────────────────────────────────┴──────┴──────┴───────────┴──────┴───────────┴──────┴───────────┴──────┴───────────╨─────────╨────────────"
  sh := len(arr_title[1])
  G_Use(dir_server+"uch_pers",dir_server+"uch_pers","UCHP")
  G_Use(dir_server+"mo_uch",,"UCH")
  G_Use(dir_server+"mo_otd",,"OTD")
  set relation to kod_lpu into UCH
  G_Use(dir_server+"mo_pers",,"perso")
  set relation to otd into OTD
  use (cur_dir+"tmp") new alias TMP
  set relation to kod_vr into perso
  index on str(perso->kateg,1)+upper(uch->name)+upper(otd->name)+str(perso->otd,3)+upper(perso->fio) to (cur_dir+"tmp")
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string(center("Сводная ведомость [объем работ]",sh))
  titleN_uch(st_a_uch,sh)
  add_string(center(arr[4],sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  ss := ss1 := ss2 := ss3 := ss4 := 0 ; old_kateg := -1 ; old_otd := -1
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if !(perso->kateg == old_kateg)
      add_string(replicate("-",sh))
      add_string('=== Категория "'+inieditspr(A__MENUVERT,gmenu_kateg,perso->kateg)+'" ===')
    endif
    if !(perso->kateg == old_kateg .and. perso->otd == old_otd)
      s := ""
      if count_uch > 1
        s := "["+alltrim(uch->name)+"] "+expand(alltrim(otd->name))
      endif
      add_string(space(10)+s)
    endif
    lfio := ""
    if mem_tabnom == 2
      select TABN
      find (str(tmp->kod_vr,4))
      lfio := padr("["+lstr(tabn->tab_nom)+"]",8)
    endif
    lfio += perso->fio
    s := tmp->stoim+tmp->stoim1+tmp->stoim2+tmp->stoim3
    j := ret_trudoem(tmp->kod_vr,tmp->trudoem,ym_kol_mes,arr_m)
    k := "  "+put_val_0(j,5,1)
    add_string(padr(lfio,40)+;
               put_val(tmp->kol,7)+k+put_kopE(tmp->stoim,12)+;
               put_val(tmp->kol1,7)+put_kopE(tmp->stoim1,12)+;
               put_val(tmp->kol2,7)+put_kopE(tmp->stoim2,12)+;
               put_val(tmp->kol3,7)+put_kopE(tmp->stoim3,12)+;
               " _________"+put_kopE(s,12))
    ss1 += tmp->stoim
    ss2 += tmp->stoim1
    ss3 += tmp->stoim2
    ss4 += tmp->stoim3
    ss += s
    old_kateg := perso->kateg
    old_otd := perso->otd
    select TMP
    skip
  enddo
  close databases
  if verify_FF(HH,.t.,sh)
     aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(replicate("-",sh))
  add_string(padc("Итого:",40)+;
             put_kopE(ss1,26)+;
             put_kopE(ss2,19)+;
             put_kopE(ss3,19)+;
             put_kopE(ss4,19)+;
             put_kopE(ss,22))
  fclose(fp)
  rest_box(buf)
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
rest_box(buf)
return NIL

*

*****
Function sv1_ved_plat(arr,arr_otd)
Local i, j, begin_date, end_date, bk := 1, ek := 99, al,;
      fl_exit := .f., sh := 80, HH := 57, regim := 2, s, fl_1_list := .t.,;
      len_n, pkol, ptrud, pstoim, old_perso, old_usl,;
      old_fio, md, mkol, mstoim, arr_kd := {}, len_kd := 0,;
      xx, yy, pole_va, lrec, t_date1, t_date2, arr_title, msum, msum_opl,;
      musluga, mperso, mkod_perso, arr_usl := {}, adbf1, adbf2
Private skol := {0,0}, strud := {0,0}, sstoim := {0,0}
Private fl_plan := .f., fl7_plan := .f.
begin_date := arr[7]
end_date := arr[8]
if mem_trudoem == 2 .and. ym_kol_mes > 0
  fl_plan := .t.
  fl7_plan := .t.
endif
adbf2 := {;
     {"KOD_VR",     "N",      4,      0},;  // код врача
     {"FIO",        "C",     50,      0},;  // Ф.И.О. врача (ассистента)
     {"TRUDOEM",    "N",     11,      4},;  // трудоемкость услуг УЕТ
     {"KOL"    ,    "N",      6,      0},;  // количество услуг
     {"STOIM"  ,    "N",     14,      2},;  // итоговая стоимость услуги
     {"KOL1"   ,    "N",      6,      0},;  // платные
     {"STOIM1" ,    "N",     14,      2},;  // платные
     {"KOL2"   ,    "N",      6,      0},;  // доплаты за услуги
     {"STOIM2" ,    "N",     14,      2},;  // доплаты за услуги
     {"KOL3"   ,    "N",      6,      0},;  // материалы
     {"STOIM3" ,    "N",     14,      2};   // материалы
    }
dbcreate(cur_dir+"tmp",adbf2)
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
use (cur_dir+"tmp")
index on str(kod_vr,4) to (cur_dir+"tmpk")
if mem_trudoem == 2
  useUch_Usl()
endif
//G_Use(dir_server+"cena_usl",dir_server+"cena_usl","CENA")
R_Use(dir_server+"uslugi",,"USL")
// pi1 == 2  // по дате выписки счета
pole_kol := "hu->kol_1"
pole_stoim := "hu->stoim_1"
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
set filter to !eq_any(mest_inog,6,7)
dbseek(begin_date,.t.)
do while schet->pdate <= end_date .and. !eof()
  select HUMAN
  find (str(schet->kod,6))
  do while human->schet == schet->kod
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    //if human->cena_1 > 0
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod
        ob3_statist(arr_otd)
        select HU
        skip
      enddo
    //endif
    select HUMAN
    skip
  enddo
  if fl_exit ; exit ; endif
  select SCHET
  skip
enddo
j := tmp->(lastrec())
close databases
return !fl_exit

*****
Static Function ob3_statist(arr_otd)
Local i, mtrud := 0, koef_z := {1,1,1}, k1 := 2, s1 := "2"
if hu->u_kod > 0 .and. (&pole_kol > 0 .or. &pole_stoim > 0) .and. ;
                          (i := ascan(arr_otd, {|x| hu->otd==x[1]})) > 0
  if mem_trudoem == 2
    mtrud := round_5(&pole_kol * opr_uet(human->vzros_reb), 4)
  endif
  if fl7_plan
    k1 := 1 ; s1 := "1"
  endif
  select TMP
  if hu->kod_vr > 0
    find (str(hu->kod_vr,4))
    if !found()
      append blank
      tmp->kod_vr := hu->kod_vr
    endif
    tmp->kol += &pole_kol
    tmp->stoim += &pole_stoim * koef_z[2]
    tmp->trudoem += mtrud
    if fl7_plan
      strud[1] += mtrud
      sstoim[1] += &pole_stoim * koef_z[2]
    endif
  elseif hu->kod_as > 0
    find (str(hu->kod_as,4))
    if !found()
      append blank
      tmp->kod_vr := hu->kod_as
    endif
    tmp->kol += &pole_kol
    tmp->stoim += &pole_stoim * koef_z[3]
    tmp->trudoem += mtrud
    if fl7_plan
      strud[2] += mtrud
      sstoim[2] += &pole_stoim * koef_z[2]
    endif
  endif
endif
return NIL

*

*****
Function sv2_ved_plat(arr,arr_otd)
Local i, j, begin_date, end_date, bk := 1, ek := 99, al,;
      fl_exit := .f., sh := 80, HH := 57, regim := 2, s, fl_1_list := .t.,;
      len_n, pkol, ptrud, pstoim, old_perso, old_usl,;
      old_fio, md, mkol, mstoim, arr_kd := {}, len_kd := 0,;
      xx, yy, pole_va, lrec, t_date1, t_date2, arr_title, msum, msum_opl,;
      musluga, mperso, mkod_perso, arr_usl := {}, adbf1, adbf2
Private skol := {0,0}, strud := {0,0}, sstoim := {0,0}
/*Private usl_dop := rest_arr(dir_server+"usl_pl_d"+smem),;
        usl_mat := rest_arr(dir_server+"usl_pl_m"+smem)*/
begin_date := arr[7]
end_date := arr[8]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
use (cur_dir+"tmp") index (cur_dir+"tmpk") alias TMP
if mem_trudoem == 2
  useUch_Usl()
endif
//G_Use(dir_server+"cena_usl",dir_server+"cena_usl","CENA")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"uslugi",dir_server+"uslugi","USL")
// pi1 == 2  // по дате окончания лечения
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
R_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
dbseek(dtos(arr[5]),.t.)
do while human->k_data <= arr[6] .and. !eof()
  UpdateStatus()
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  select HU
  find (str(human->(recno()),7))
  do while hu->kod == human->(recno())
    ob32_statist(arr_otd)
    select HU
    skip
  enddo
  select HUMAN
  skip
enddo
j := tmp->(lastrec())
close databases
return !fl_exit

*****
Static Function ob32_statist(arr_otd)
Local i, mtrud := 0, koef_z := {1,1,1}, k1 := 2, s1 := "1"
Private  pole_kol, pole_stoim
if hu->u_kod > 0 .and. (hu->kol > 0 .or. hu->stoim > 0) .and. ;
                          (i := ascan(arr_otd, {|x| hu->otd==x[1]})) > 0
  pole_kol   := "tmp->kol"+s1
  pole_stoim := "tmp->stoim"+s1
  select TMP
  if hu->kod_vr > 0
    find (str(hu->kod_vr,4))
    if !found()
      append blank
      tmp->kod_vr := hu->kod_vr
    endif
    &pole_kol   := &pole_kol   + hu->kol
    &pole_stoim := &pole_stoim + hu->stoim * koef_z[2]
  endif
endif
return NIL

*

*****
Function SOuslPkart(mkod_human,mkod_lpu)
// mkod_human - код по БД human
Local adbf, buf := savescreen(), j := 0, tmp_color := setcolor(color1), ;
      l_color, mtitle, tmp_help := 0 //help_code
Private fl_found, mcena := 0, ;
        last_date := ctod("01.01.1990"), mvu[3,2], pr1otd, ;
        pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}, ;
        pr_kod_vr := 0, pr_kod_as := 0, ;
        pr_med1 := 0, pr_med2 := 0, pr_med3 := 0, ;
        pr_san1 := 0, pr_san2 := 0, pr_san3 := 0, is_open_u1 := .f.
afillall(mvu,0)
mywait()
//
R_Use(dir_server+"mo_otd",,"OTD")
dbeval({|| if(mem_otdusl == 2, ;
              aadd(pr1arr_otd,{otd->(recno()),otd->name,otd->kod_lpu,""}), nil);
       },;
       {|| iif(yes_many_uch, .t., otd->kod_lpu == glob_uch[1]) };
      )
if yes_many_uch
  dbeval({|| aadd(pr_arr,{otd->(recno()),otd->name,otd->kod_lpu,""}) },;
         {|| between_date(otd->dbeginp,otd->dendp,sys_date)} )
  R_Use(dir_server+"mo_uch",,"UCH")
  aeval(pr_arr, {|x,i| dbGoto(x[3]), pr_arr[i,4] := uch->name } )
  aeval(pr1arr_otd, {|x,i| dbGoto(x[3]), pr1arr_otd[i,4] := uch->name } )
  uch->(dbCloseArea())
  //
  asort(pr_arr,,,{|x,y| iif(x[3] == y[3], upper(x[2]) < upper(y[2]), ;
                                          upper(x[4]) < upper(y[4])) } )
  aeval(pr_arr, {|x| aadd(pr_arr_otd,x[4]+" "+x[2]) } )
else
  dbeval({|| aadd(pr_arr,{otd->(recno()),otd->name,otd->kod_lpu,""}) },;
         {|| otd->kod_lpu == mkod_lpu .and. between_date(otd->dbeginp,otd->dendp,sys_date)} )
  asort(pr_arr,,,{|x,y| upper(x[2]) < upper(y[2]) } )
  aeval(pr_arr, {|x| aadd(pr_arr_otd,x[2]) } )
endif
//
R_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
adbf := dbstruct()
aadd(adbf, {"date_u1","D", 8,0} )
aadd(adbf, {"shifr_u","C",10,0} )
aadd(adbf, {"name_u", "C",65,0} )
aadd(adbf, {"is_nul", "L", 1,0} )
aadd(adbf, {"number", "N", 6,0} )
aadd(adbf, {"rec_hu", "N", 7,0} )
dbcreate(cur_dir+"tmp_usl",adbf)
use (cur_dir+"tmp_usl") new alias tmp
Private i_date_u1 := fieldpos("date_u1")
if mem_ordusl == 1
  index on dtos(date_u1)+fsort_usl(shifr_u) to (cur_dir+"tmp_usl")
else
  index on fsort_usl(shifr_u)+dtos(date_u1) to (cur_dir+"tmp_usl")
endif
select HU
set relation to u_kod into USL
find (str(mkod_human,7))
if (fl_found := found())
  adbf := array(fcount())
  do while hu->kod == mkod_human .and. !eof()
    aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
    select TMP
    append blank
    aeval(adbf, {|x,i| fieldput(i,x) } )
    pr_kod_vr := tmp->kod_vr
    pr_kod_as := tmp->kod_as
    pr_med1 := tmp->med1
    pr_med2 := tmp->med2
    pr_med3 := tmp->med3
    pr_san1 := tmp->san1
    pr_san2 := tmp->san2
    pr_san3 := tmp->san3
    tmp->date_u1 := c4tod(hu->date_u)
    tmp->shifr_u := usl->shifr
    tmp->name_u := usl->name
    tmp->is_nul := usl->is_nulp
    tmp->rec_hu := hu->(recno())
    last_date := max(tmp->date_u1,last_date)
    mcena += tmp->stoim
    select HU
    skip
  enddo
endif
tmp->(dbeval({|| tmp->number := ++j } ) )
close databases
//
Private flag_1 := .t.
if G_Use(dir_server+"hum_p",,"HUMAN") .and. ;
   G_Use(dir_server+"hum_p_u",{dir_server+"hum_p_u",;
                               dir_server+"hum_p_uk",;
                               dir_server+"hum_p_ud",;
                               dir_server+"hum_p_uv",;
                               dir_server+"hum_p_ua"},"HU") .and. ;
   R_Use(dir_server+"uslugi",dir_server+"uslugish","USL") .and. ;
   R_Use(dir_server+"mo_otd",,"OTD") .and. ;
   R_Use(dir_server+"plat_ms",dir_server+"plat_ms","MS") .and. ;
   R_Use(dir_server+"usl_otd",dir_server+"usl_otd","UO") .and. ;
   R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
  select HUMAN
  goto (mkod_human)
  last_date := max(human->n_data,last_date)
  Private is_kassa := (human->is_kas != 1)
  Use (cur_dir+"tmp_usl") index (cur_dir+"tmp_usl") new alias TMP
  set relation to otd into OTD
  go top
  cls
  pr_1_str("Платные услуги для больного < "+alltrim(glob_k_fio)+" >")
  setcolor("BG/B")
  setcolor("BG/B")
  l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"
  @ maxrow()-3,0 say "╒═══════════════════ Полное наименование услуги ═══════════════════╤══ Цена ═══╕"
  @ maxrow()-2,0 say "│                                                                  │           │"
  @ maxrow()-1,0 say "╘══════════════════════════════════════════════════════════════════╧═══════════╛"
  if fl_found
    keyboard chr(K_RIGHT)
  else
    keyboard chr(K_INS)
  endif
  setcolor(color1)
  mtitle := f_srok_lech(human->n_data,human->k_data)
  if !is_kassa
    @ 1,1 say " ЧЕК " color "G+*/B"
  endif
  //help_code := HM_Edit_kart
  Alpha_Browse(2,0,maxrow()-5,79,"Fe_p_kusl",color1,mtitle,col_tit_popup,;
               .f.,.t.,,"F1e_p_kusl","F2e_p_kusl",,;
               {"═","░","═",l_color,.t.,180} )
  if yes_parol .and. (mvu[1,1] > 0 .or. mvu[2,1] > 0 .or. mvu[3,1] > 0) ;
               .and. hb_FileExists(dir_server+"mo_opern"+sdbf)
    close databases
    if G_Use(dir_server+"mo_opern",dir_server+"mo_opern","OP")
      for i := 1 to 3
        if mvu[i,1] > 0
          write_work_oper(glob_task,OPER_USL,i,mvu[i,1],mvu[i,2],.f.)
        endif
      next
    endif
  endif
  close databases
endif
close databases
setcolor(tmp_color)
restscreen(buf)
help_code := tmp_help
return mcena

*****
Function fe_p_kusl(oBrow)
Local oColumn, blk_color := {|| if(tmp->t_edit > 1, {3,4}, {1,2}) }
oColumn := TBColumnNew(" NN; пп",{|| str(tmp->number,3) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
if mem_ordusl == 1
  oColumn := TBColumnNew("Дата;оказ.; усл.",{|| left(dtoc(tmp->date_u1),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("   Шифр;  услуги",{|| tmp->shifr_u })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
if mem_ordusl == 2
  oColumn := TBColumnNew("Дата;оказ.; усл.",{|| left(dtoc(tmp->date_u1),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("Отде-;ление",{|| otd->short_name })
oColumn:defColor := {6,6}
oColumn:colorBlock := {|| {6,6} }
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Наименование;  услуги",{|| left(tmp->name_u,16) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Врач",{|| put_val(ret_tabn(tmp->kod_vr),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Асс.",{|| put_val(ret_tabn(tmp->kod_as),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Ко-;лич.;усл.",{|| tmp->kol })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Общая; стоимость; услуги",{|| put_kop(tmp->stoim,10) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление; ^<F1>^ помощь")
return NIL

*****
Function f1e_p_kusl()
LOCAL nRow := ROW(), nCol := COL()
@ maxrow()-2,2 say tmp->name_u color cDataCSay
@ maxrow()-2,68 say if(empty(tmp->u_cena),space(11),;
        padc(alltrim(dellastnul(tmp->u_cena,10,2)),11)) color cDataCSay
if flag_1
  f3e_p_kusl()
  flag_1 := .f.
endif
@ nRow, nCol SAY ""
return NIL

*****
Function f3e_p_kusl()
@ maxrow()-4,60 say padl("Итого: "+lstr(mcena,11,2),19) color "W+/N"
return NIL

*

*****
Function f2e_p_kusl(nKey,oBrow)
Static st_vzrosl, st_arr_dbf
LOCAL flag := -1, buf := savescreen(), fl := .f., rec, ;
      i1, k, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := setcolor(), ;
      rec_tmp := tmp->(recno()), mrec_hu := tmp->rec_hu, date_tmp := tmp->date_u1,;
      pos_read := 0, k_read := 0, count_edit := 0,;
      tmp_help := 0, uch_otd := saveuchotd()  //help_code
Private r1 := 10
if eq_any(nKey,K_F4,K_F5,K_CTRL_F5,K_CTRL_F10,K_F11,K_INS,K_ENTER,K_DEL)
  if !ver_pub_date(human->k_data,.t.)
    return flag
  endif
  if nKey != K_ENTER .and. !is_kassa
    func_error(4,"По данному листу учета уже пробит чек. Операция запрещена!")
    return flag
  endif
endif
do case
  case nKey == K_F10 .and. tmp->kod > 0 .and. f_Esc_Enter("запоминания услуг")
    mywait()
    st_vzrosl := (smvzros_reb==0)
    st_arr_dbf := {}
    select TMP
    adbf1 := array(fcount())
    go top
    do while !eof()
      aeval(adbf1, {|x,i| adbf1[i] := fieldget(i) } )
      aadd(st_arr_dbf, aclone(adbf1) )
      select TMP
      skip
    enddo
    select TMP
    oBrow:goTop()
    goto (rec_tmp)
    stat_msg("Услуги запомнены!") ; mybell(1,OK)
    restscreen(buf)
    flag := 0
  case eq_any(nKey,K_CTRL_F10,K_F11) .and. st_arr_dbf != NIL
    if !fl_found
      colorwin(7,0,7,79,"B/B","W+/RB")
    endif
    if st_vzrosl != (smvzros_reb==0)
      func_error(4,'Критерий "взрослый/ребенок" у данного больного отличается от предыдущего!')
    elseif f_Esc_Enter("копирования услуг")
      mywait()
      last_date := human->n_data
      min_date := st_arr_dbf[1,i_date_u1]
      for k := 1 to len(st_arr_dbf)
        min_date := min(st_arr_dbf[k,i_date_u1],min_date)
      next
      select HU
      adbf := array(fcount())
      i1 := len(adbf)
      for k := 1 to len(st_arr_dbf)
        fl_found := .t.
        ++mvu[1,1]  // услуги добавлены оператором
        select HU
        Add1Rec(7)
        aeval(st_arr_dbf[k], {|x,i| fieldput(i,x) }, 1, i1 )
        hu->kod := human->(recno())
        new_date := human->n_data + (st_arr_dbf[k,i_date_u1] - min_date)
        if !between(new_date,human->n_data,human->k_data)
          new_date := human->k_data
        endif
        hu->date_u := dtoc4(new_date)
        UNLOCK
        select TMP
        append blank
        aeval(st_arr_dbf[k], {|x,i| fieldput(i,x) } )
        tmp->kod := human->(recno())
        tmp->date_u := dtoc4(new_date)
        tmp->date_u1 := new_date
        tmp->rec_hu := hu->(recno())
        last_date := max(tmp->date_u1,last_date)
        // если надо, переопределение цены
        if .f.
        endif
      next
      summa_usl(@mcena)
      select HUMAN
      G_RLock(forever)
      replace human->cena with mcena
      UNLOCK
      COMMIT
      stat_msg("Услуги скопированы!") ; mybell(1,OK)
      restscreen(buf)
      f3e_p_kusl()
      select TMP
      oBrow:goTop()
      flag := 0
    elseif !fl_found
      flag := 1
    endif
  case eq_any(nKey,K_F4,K_F5,K_CTRL_F5) .and. tmp->kod > 0
    if (arr_dni := uk_arr_dni(nKey)) != NIL
      mywait()
      arr_u := {}
      select HU
      adbf := array(fcount())
      select TMP
      adbf1 := array(fcount())
      if eq_any(nkey,K_F4,K_F5)  // запомнить копируемую услугу
        select HU
        goto (mrec_hu)
        aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
        select TMP
        aeval(adbf1, {|x,i| adbf1[i] := fieldget(i) } )
        aadd(arr_u, {aclone(adbf),aclone(adbf1)})
      else
        select TMP
        go top
        do while !eof()
          if date_tmp == tmp->date_u1  // запомнить все услуги за этот день
            mrec_hu := tmp->rec_hu
            select HU
            goto (mrec_hu)
            aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
            select TMP
            aeval(adbf1, {|x,i| adbf1[i] := fieldget(i) } )
            aadd(arr_u, {aclone(adbf),aclone(adbf1)})
          endif
          select TMP
          skip
        enddo
      endif
      for k := 1 to len(arr_dni)
        for j := 1 to len(arr_u)
          ++mvu[1,1]  // услуги добавлены оператором
          select HU
          Add1Rec(7)
          aeval(arr_u[j,1], {|x,i| fieldput(i,x) } )
          hu->date_u := dtoc4(arr_dni[k,2])
          mrec_hu := hu->(recno())
          UNLOCK
          select TMP
          append blank
          aeval(arr_u[j,2], {|x,i| fieldput(i,x) } )
          tmp->date_u1 := arr_dni[k,2]
          tmp->rec_hu := mrec_hu
          rec_tmp := tmp->(recno())
          // если надо, переопределение цены
          if .f.
          endif
        next
      next
      hu->(dbcommit())
      summa_usl(@mcena)
      select HUMAN
      G_RLock(forever)
      replace human->cena with mcena
      UNLOCK
      human->(dbcommit())
      restscreen(buf)
      f3e_p_kusl()
      select TMP
      oBrow:goTop()
      goto (rec_tmp)
      setcolor(tmp_color)
      flag := 0
    endif
  case nKey == K_INS .or. (nKey == K_ENTER .and. tmp->kod > 0)
   // help_code := HM_Edit1_kart
    if nKey == K_INS .and. !fl_found
      colorwin(7,0,7,79,"B/B","W+/RB")
    endif
    Private motd, m1otd := if(nKey == K_INS, ;
                      if(pr1otd == NIL, 0, pr1otd), tmp->otd),;
            mu_kod := if(nKey == K_INS, 0, tmp->u_kod),;
            mdate_u1 := if(nKey == K_INS, last_date, tmp->date_u1),;
            mis_nul := if(nKey == K_INS, .f., tmp->is_nul),;
            mu_cena := if(nKey == K_INS, 0, tmp->u_cena),;
            mkod_vr := if(nKey == K_INS, pr_kod_vr, tmp->kod_vr),;
            mtabn_vr := 0, mvrach := space(35),;
            mkod_as := if(nKey == K_INS, pr_kod_as, tmp->kod_as),;
            mtabn_as := 0, massist := space(35),;
            mkol := if(nKey == K_INS, 0, tmp->kol),;
            mstoim := if(nKey == K_INS, 0, tmp->stoim),;
            mt_edit := if(nKey == K_INS, 0, tmp->t_edit),;
            mshifr := if(nKey == K_INS, space(10), tmp->shifr_u),;
            mname_u := if(nKey == K_INS, space(65), tmp->name_u),;
            pmmed1 := if(nKey == K_INS, pr_med1, tmp->med1), mmed1 := 0,;
            pmmed2 := if(nKey == K_INS, pr_med2, tmp->med2), mmed2 := 0,;
            pmmed3 := if(nKey == K_INS, pr_med3, tmp->med3), mmed3 := 0,;
            pmsan1 := if(nKey == K_INS, pr_san1, tmp->san1), msan1 := 0,;
            pmsan2 := if(nKey == K_INS, pr_san2, tmp->san2), msan2 := 0,;
            pmsan3 := if(nKey == K_INS, pr_san3, tmp->san3), msan3 := 0,;
            pr_k_usl := {},;  // массив комплексных услуг
            gl_area := {1,0,23,79,0}
    motd := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
    if mkod_vr > 0
      select PERSO
      goto (mkod_vr)
      mvrach := padr(perso->fio,35)
      mtabn_vr := perso->tab_nom
    endif
    if mkod_as > 0
      select PERSO
      goto (mkod_as)
      massist := padr(perso->fio,35)
      mtabn_as := perso->tab_nom
    endif
    select MS
    if pmmed1 > 0
      goto (pmmed1)
      if !eof() .and. ms->tip == 1
        mmed1 := ms->tab_nom
      endif
    endif
    if pmmed2 > 0
      goto (pmmed2)
      if !eof() .and. ms->tip == 1
        mmed2 := ms->tab_nom
      endif
    endif
    if pmmed3 > 0
      goto (pmmed3)
      if !eof() .and. ms->tip == 1
        mmed3 := ms->tab_nom
      endif
    endif
    if pmsan1 > 0
      goto (pmsan1)
      if !eof() .and. ms->tip == 2
        msan1 := ms->tab_nom
      endif
    endif
    if pmsan2 > 0
      goto (pmsan2)
      if !eof() .and. ms->tip == 2
        msan2 := ms->tab_nom
      endif
    endif
    if pmsan3 > 0
      goto (pmsan3)
      if !eof() .and. ms->tip == 2
        msan3 := ms->tab_nom
      endif
    endif
    box_shadow(r1-1,0,23,79,color8,;
             if(nKey == K_INS,"Добавление новой",;
                              "Редактирование")+" платной услуги","RB+/B")
    do while .t.
      setcolor(cDataCGet)
      if mem_kodotd == 1
        @ r1+1,2 say "Отделение, в котором оказана услуга" get motd ;
                 reader {|x|menu_reader(x, ;
                      { { |k,r,c| get_otd(k,r+1,c,.t.) }},A__FUNCTION,,,.f.)}
      else
        @ r1+1,2 say "Отделение, в котором оказана услуга" get m1otd pict "99" ;
                 when {|g| f5e_p_kusl(g,1,10) } ;
                 valid {|g| f5e_p_kusl(g,2,10) }
        @ row(),col()+2 get motd color color14 when .f.
      endif
      @ r1+2,2 say "Дата оказания услуги" get mdate_u1 ;
               valid {|g| f5e_p_kusl(g,2,1) }
      @ r1+3,2 say "Шифр услуги" get mshifr pict "@!" ;
               when {|g| f5e_p_kusl(g,1,2) } ;
               valid {|g| f5e_p_kusl(g,2,2) }
      @ row(),40 say "Цена услуги" get mu_cena pict pict_cena ;
                when .f. color color14
      @ r1+4,2 say "Услуга" get mname_u when .f. color color14
      ix := 4
      for x := 1 to 3
        if mem_por_vr == x
          ++ix
          @ r1+ix,2 say "Таб.N врача" get mtabn_vr pict "99999" ;
                    valid {|g| f5e_p_kusl(g,2,3) }
          @ row(),col()+3 get mvrach when .f. color color14
        endif
        if mem_por_ass == x
          ++ix
          @ r1+ix,2 say "Таб.N ассистента" get mtabn_as pict "99999" ;
                    valid {|g| f5e_p_kusl(g,2,4) }
          @ row(),col()+3 get massist when .f. color color14
        endif
        if mem_por_kol == x
          ++ix
          @ r1+ix,2 say "Количество услуг" get mkol pict "999" ;
                    when {|g| is_kassa .and. f5e_p_kusl(g,1,5) } ;
                    valid {|g| f5e_p_kusl(g,2,5) }
        endif
      next
      @ r1+9,2 say "Общая стоимость услуги" get mstoim pict pict_cena ;
               when {|g| is_kassa .and. mem_edit_s==2 .and. f5e_p_kusl(g,1,7) } ;
               valid {|g| f5e_p_kusl(g,2,7) }
      if mt_edit > 1
        @ r1+9,37 say "[ редактировалась стоимость услуги ]" color color13
      endif
      if is_oplata != 7
        @ r1+10,2 say "Коды медсестер" get mmed1 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,11) }
        @ row(),col() say "," get mmed2 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,11) }
        @ row(),col() say "," get mmed3 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,11) }
        @ r1+11,2 say "Коды санитарок" get msan1 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,12) }
        @ row(),col() say "," get msan2 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,12) }
        @ row(),col() say "," get msan3 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,12) }
      endif
      status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи")
      set key K_F11 to clear_gets
      set key K_CTRL_F10 to clear_gets
      count_edit := myread(,@pos_read,++k_read)
      SetKey( K_F2, NIL )
      SetKey( K_F3, NIL )
      SetKey( K_F11, NIL )
      SetKey( K_CTRL_F10, NIL )
      if eq_any(lastkey(),K_CTRL_F10,K_F11)
        hb_KeyPut(K_CTRL_F10) //keysend(KS_CTRL_F10)
      elseif lastkey() != K_ESC
        if empty(mdate_u1)
          func_error(4,"Не введена дата оказания услуги!")
          loop
        elseif len(pr_k_usl) == 0 .and. empty(mu_kod)
          func_error(4,"Не введена услуга!")
          loop
        elseif len(pr_k_usl) == 0 .and. !mis_nul .and. empty(mstoim)
          func_error(4,"Не введена цена услуги!")
          loop
        elseif mem_vv_v_a == 1 .and. emptyall(mkod_vr,mkod_as)
          func_error(4,"Не введены врач и ассистент!")
          loop
        else
          err_date_diap(mdate_u1,"Дата оказания услуги")
          mywait()
          if nKey == K_INS
            mvu[1,2] += count_edit
          else
            mvu[2,2] += count_edit
          endif
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
              /*if mt_edit > 0
                k := (100-mt_edit) / 100
                mstoim := round_5(mstoim * k, 2)
              endif*/
              //
              select HU
              Add1Rec(7)
              mrec_hu := hu->(recno())
              fl_found := .t.
              select TMP
              append blank
              rec_tmp := tmp->(recno())
              ++mvu[1,1]  // услуга добавлена оператором
              //
              select HU
              replace hu->kod     with human->(recno()),;
                      hu->kod_vr  with mkod_vr,;
                      hu->kod_as  with mkod_as,;
                      hu->u_koef  with 1,;
                      hu->stoim   with mstoim,;
                      hu->u_kod   with mu_kod,;
                      hu->u_cena  with mu_cena,;
                      hu->t_edit  with mt_edit,;
                      hu->kol     with mkol,;
                      hu->date_u  with dtoc4(mdate_u1),;
                      hu->otd     with m1otd,;
                      hu->med1    with pmmed1,;
                      hu->med2    with pmmed2,;
                      hu->med3    with pmmed3,;
                      hu->san1    with pmsan1,;
                      hu->san2    with pmsan2,;
                      hu->san3    with pmsan3
              UNLOCK
              pr1otd := m1otd
              adbf := array(fcount())
              aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
              select TMP
              aeval(adbf, {|x,i| fieldput(i,x) } )
              tmp->date_u1 := mdate_u1
              tmp->shifr_u := mshifr
              tmp->name_u := mname_u
              tmp->is_nul := mis_nul
              tmp->rec_hu := mrec_hu
            //last_date := max(tmp->date_u1,last_date) - так было
              last_date := tmp->date_u1  // - так стало
              pr_kod_vr := tmp->kod_vr
              pr_kod_as := tmp->kod_as
              pr_med1 := tmp->med1
              pr_med2 := tmp->med2
              pr_med3 := tmp->med3
              pr_san1 := tmp->san1
              pr_san2 := tmp->san2
              pr_san3 := tmp->san3
            next
          else
            // одна услуга
            select HU
            if nKey == K_INS
              Add1Rec(7)
              mrec_hu := hu->(recno())
              fl_found := .t.
              select TMP
              append blank
              rec_tmp := tmp->(recno())
              ++mvu[1,1]  // услуга добавлена оператором
            else
              goto (mrec_hu)
              G_RLock(forever)
              select TMP
              goto (rec_tmp)
              ++mvu[2,1]  // услуга отредактирована оператором
            endif
            select HU
            replace hu->kod     with human->(recno()),;
                    hu->kod_vr  with mkod_vr,;
                    hu->kod_as  with mkod_as,;
                    hu->u_koef  with 1,;
                    hu->stoim   with mstoim,;
                    hu->u_kod   with mu_kod,;
                    hu->u_cena  with mu_cena,;
                    hu->t_edit  with mt_edit,;
                    hu->kol     with mkol,;
                    hu->date_u  with dtoc4(mdate_u1),;
                    hu->otd     with m1otd,;
                    hu->med1    with pmmed1,;
                    hu->med2    with pmmed2,;
                    hu->med3    with pmmed3,;
                    hu->san1    with pmsan1,;
                    hu->san2    with pmsan2,;
                    hu->san3    with pmsan3
            UNLOCK
            pr1otd := m1otd
            adbf := array(fcount())
            aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
            select TMP
            aeval(adbf, {|x,i| fieldput(i,x) } )
            tmp->date_u1 := mdate_u1
            tmp->shifr_u := mshifr
            tmp->name_u := mname_u
            tmp->is_nul := mis_nul
            tmp->rec_hu := mrec_hu
          //last_date := max(tmp->date_u1,last_date) - так было
            last_date := tmp->date_u1  // - так стало
            pr_kod_vr := tmp->kod_vr
            pr_kod_as := tmp->kod_as
            pr_med1 := tmp->med1
            pr_med2 := tmp->med2
            pr_med3 := tmp->med3
            pr_san1 := tmp->san1
            pr_san2 := tmp->san2
            pr_san3 := tmp->san3
          endif
          summa_usl(@mcena)
          select HUMAN
          G_RLock(forever)
          human->cena := mcena
          UNLOCK
          COMMIT
        endif
      endif
      exit
    enddo
    flag := 0
    if nKey == K_INS .and. !fl_found .and. !eq_any(lastkey(),K_CTRL_F10,K_F11)
      flag := 1
    endif
    restscreen(buf)
    f3e_p_kusl()
    select TMP
    oBrow:goTop()
    goto (rec_tmp)
    setcolor(tmp_color)
  case nKey == K_DEL .and. tmp->kod > 0
    if f_Esc_Enter(2)
      mywait()
      ++mvu[3,1]  // услуга удалена оператором
      select HU
      goto (tmp->rec_hu)
      DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
      select TMP
      DeleteRec(.t.)  // с пометкой на удаление
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
      f3e_p_kusl()
    endif
  otherwise
    keyboard ""
endcase
help_code := tmp_help
restuchotd(uch_otd)
return flag

*

***** 08.10.17
Function STuslPkart(mkod_human,mkod_lpu)
// mkod_human - код по БД human
Local adbf, buf := savescreen(), j := 0, tmp_color := setcolor(color1), ;
      l_color, mtitle, tmp_help := 0 //help_code
Private fl_found, mcena := 0, ;
        last_date := ctod("01.01.1990"), mvu[3,2], pr1otd, ;
        pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}, ;
        pr_kod_vr := 0, pr_kod_as := 0, ;
        pr_med1 := 0, pr_med2 := 0, pr_med3 := 0, ;
        pr_san1 := 0, pr_san2 := 0, pr_san3 := 0, is_open_u1 := .f.
afillall(mvu,0)
mywait()
//
R_Use(dir_server+"mo_otd",,"OTD")
dbeval({|| iif(mem_otdusl == 2, aadd(pr1arr_otd,{otd->(recno()),otd->name,otd->kod_lpu,""}), ) },;
       {|| iif(yes_many_uch, .t., otd->kod_lpu == glob_uch[1]) };
      )
if yes_many_uch
  dbeval({|| aadd(pr_arr,{otd->(recno()),otd->name,otd->kod_lpu,""}) },;
         {|| between_date(otd->dbeginp,otd->dendp,sys_date)} )
  R_Use(dir_server+"mo_uch",,"UCH")
  aeval(pr_arr, {|x,i| dbGoto(x[3]), pr_arr[i,4] := uch->name } )
  aeval(pr1arr_otd, {|x,i| dbGoto(x[3]), pr1arr_otd[i,4] := uch->name } )
  uch->(dbCloseArea())
  //
  asort(pr_arr,,,{|x,y| iif(x[3] == y[3], upper(x[2]) < upper(y[2]), ;
                                          upper(x[4]) < upper(y[4])) } )
  aeval(pr_arr, {|x| aadd(pr_arr_otd,x[4]+" "+x[2]) } )
else
  dbeval({|| aadd(pr_arr,{otd->(recno()),otd->name,otd->kod_lpu,""}) },;
         {|| otd->kod_lpu == mkod_lpu .and. between_date(otd->dbeginp,otd->dendp,sys_date)} )
  asort(pr_arr,,,{|x,y| upper(x[2]) < upper(y[2]) } )
  aeval(pr_arr, {|x| aadd(pr_arr_otd,x[2]) } )
endif
//
Use_base("humanst")
R_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
adbf := dbstruct()
aadd(adbf, {"KOD_DIAG" ,"C", 5,0})  // шифр 1-ой осн.болезни
aadd(adbf, {"ZF"       ,"C",30,0})  // зубная формула
aadd(adbf, {"date_u1",  "D", 8,0})
aadd(adbf, {"shifr_u",  "C",10,0})
aadd(adbf, {"name_u",   "C",65,0})
aadd(adbf, {"is_nul",   "L", 1,0})
aadd(adbf, {"number",   "N", 6,0})
aadd(adbf, {"rec_hu",   "N", 7,0})
dbcreate(cur_dir+"tmp_usl",adbf)
use (cur_dir+"tmp_usl") new alias tmp
Private i_date_u1 := fieldpos("date_u1")
if mem_ordusl == 1
  index on dtos(date_u1)+fsort_usl(shifr_u) to (cur_dir+"tmp_usl")
else
  index on fsort_usl(shifr_u)+dtos(date_u1) to (cur_dir+"tmp_usl")
endif
select HU
set relation to u_kod into USL
find (str(mkod_human,7))
if (fl_found := found())
  adbf := array(fcount())
  do while hu->kod == mkod_human .and. !eof()
    aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
    select TMP
    append blank
    aeval(adbf, {|x,i| fieldput(i,x) } )
    pr_kod_vr := tmp->kod_vr
    pr_kod_as := tmp->kod_as
    pr_med1 := tmp->med1
    pr_med2 := tmp->med2
    pr_med3 := tmp->med3
    pr_san1 := tmp->san1
    pr_san2 := tmp->san2
    pr_san3 := tmp->san3
    tmp->date_u1 := c4tod(hu->date_u)
    tmp->shifr_u := usl->shifr
    tmp->name_u := usl->name
    tmp->is_nul := usl->is_nulp
    tmp->rec_hu := hu->(recno())
    select HUMANST
    find (str(2,1)+str(hu->(recno()),8))
    if found()
      tmp->KOD_DIAG  := humanst->KOD_DIAG
      tmp->ZF        := humanst->ZF
    endif
    last_date := max(tmp->date_u1,last_date)
    mcena += tmp->stoim
    select HU
    skip
  enddo
endif
tmp->(dbeval({|| tmp->number := ++j } ) )
close databases
//
Private flag_1 := .t.
if G_Use(dir_server+"hum_p",,"HUMAN") .and. ;
   G_Use(dir_server+"hum_p_u",{dir_server+"hum_p_u",;
                               dir_server+"hum_p_uk",;
                               dir_server+"hum_p_ud",;
                               dir_server+"hum_p_uv",;
                               dir_server+"hum_p_ua"},"HU") .and. ;
   R_Use(dir_server+"uslugi",dir_server+"uslugish","USL") .and. ;
   R_Use(dir_server+"mo_otd",,"OTD") .and. ;
   R_Use(dir_server+"plat_ms",dir_server+"plat_ms","MS") .and. ;
   R_Use(dir_server+"usl_otd",dir_server+"usl_otd","UO") .and. ;
   R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
  Use_base("kart_st")
  Use_base("humanst")
  select HUMAN
  goto (mkod_human)
  last_date := max(human->n_data,last_date)
  Private is_kassa := (human->is_kas != 1)
  Use (cur_dir+"tmp_usl") index (cur_dir+"tmp_usl") new alias TMP
  set relation to otd into OTD
  go top
  cls
  pr_1_str("Платные услуги для больного < "+alltrim(glob_k_fio)+" >")
  setcolor("BG/B")
  setcolor("BG/B")
  l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"
  @ maxrow()-3,0 say "╒═══════════════════ Полное наименование услуги ═══════════════════╤══ Цена ═══╕"
  @ maxrow()-2,0 say "│                                                                  │           │"
  @ maxrow()-1,0 say "╘══════════════════════════════════════════════════════════════════╧═══════════╛"
  if fl_found
    keyboard chr(K_RIGHT)
  else
    keyboard chr(K_INS)
  endif
  setcolor(color1)
  mtitle := f_srok_lech(human->n_data,human->k_data)
  if !is_kassa
    @ 1,1 say " ЧЕК " color "G+*/B"
  endif
  //help_code := HST_Edit_kart
  Alpha_Browse(2,0,maxrow()-5,79,"STe_p_kusl",color1,mtitle,col_tit_popup,;
               .f.,.t.,,"ST1e_p_kusl","ST2e_p_kusl",,;
               {"═","░","═",l_color,.t.,180} )
  if yes_parol .and. (mvu[1,1] > 0 .or. mvu[2,1] > 0 .or. mvu[3,1] > 0) ;
               .and. hb_FileExists(dir_server+"mo_opern"+sdbf)
    close databases
    if G_Use(dir_server+"mo_opern",dir_server+"mo_opern","OP")
      for i := 1 to 3
        if mvu[i,1] > 0
          write_work_oper(glob_task,OPER_USL,i,mvu[i,1],mvu[i,2],.f.)
        endif
      next
    endif
  endif
  close databases
endif
close databases
setcolor(tmp_color)
restscreen(buf)
help_code := tmp_help
return mcena

*****
Function STe_p_kusl(oBrow)
Local oColumn, blk_color := {|| if(tmp->t_edit > 1, {3,4}, {1,2}) }
oColumn := TBColumnNew(" NN; пп",{|| str(tmp->number,3) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
if mem_ordusl == 1
  oColumn := TBColumnNew("Дата;оказ.; усл.",{|| left(dtoc(tmp->date_u1),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("   Шифр;  услуги",{|| tmp->shifr_u })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
if mem_ordusl == 2
  oColumn := TBColumnNew("Дата;оказ.; усл.",{|| left(dtoc(tmp->date_u1),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("Отде-;ление",{|| otd->short_name })
oColumn:defColor := {6,6}
oColumn:colorBlock := {|| {6,6} }
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("МКБ10",{|| tmp->kod_diag })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Зубная формула",{|| left(tmp->zf,17) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Врач",{|| put_val(ret_tabn(tmp->kod_vr),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Асс.",{|| put_val(ret_tabn(tmp->kod_as),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Ко-;лич.;усл.",{|| tmp->kol })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Общая; стоимость; услуги",{|| put_kop(tmp->stoim,10) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление; ^<F1>^ помощь")
return NIL

*****
Function ST1e_p_kusl()
LOCAL nRow := ROW(), nCol := COL()
@ maxrow()-2,2 say tmp->name_u color cDataCSay
@ maxrow()-2,68 say iif(empty(tmp->u_cena),space(11),;
                         padc(alltrim(dellastnul(tmp->u_cena,10,2)),11)) color cDataCSay
if flag_1
  ST3e_p_kusl()
  flag_1 := .f.
endif
@ nRow, nCol SAY ""
return NIL

*****
Function ST3e_p_kusl()
@ maxrow()-4,60 say padl("Итого: "+lstr(mcena,11,2),19) color "W+/N"
return NIL

***** 08.10.17
Function ST2e_p_kusl(nKey,oBrow)
Static skod_human := 0, SKOD_DIAG, SZF, st_vzrosl, st_arr_dbf
Local bg := {|o,k| get_MKB10(o,k,.t.) }, flag := -1, buf := savescreen(), fl := .f., rec, ;
      i1, k, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := setcolor(), ;
      rec_tmp := tmp->(recno()), date_tmp := tmp->date_u1, pos_read := 0, k_read := 0, ;
      count_edit := 0, tmp_help := 0, uch_otd := saveuchotd(), pic_diag := "@K@!"
Private r1 := 10   //help_code
if eq_any(nKey,K_INS,K_ENTER,K_DEL)
  if !ver_pub_date(human->k_data,.t.)
    return flag
  endif
  if nKey != K_ENTER .and. !is_kassa
    func_error(4,"По данному листу учета уже пробит чек. Операция запрещена!")
    return flag
  endif
endif
do case
  case nKey == K_INS .or. (nKey == K_ENTER .and. tmp->kod > 0)
    if skod_human != human->(recno())
      skod_human := human->(recno())
      SKOD_DIAG := human->KOD_DIAG
      pr1otd := human->OTD
      SZF := space(30)
    endif
    if nKey == K_INS .and. !fl_found
      colorwin(7,0,7,79,"B/B","W+/RB")
    endif
    Private motd, m1otd := iif(nKey == K_INS, iif(pr1otd == NIL, 0, pr1otd), tmp->otd),;
            mrec_hu := iif(nKey == K_INS, 0, tmp->rec_hu),;
            mu_kod := iif(nKey == K_INS, 0, tmp->u_kod),;
            mdate_u1 := iif(nKey == K_INS, last_date, tmp->date_u1),;
            mis_nul := iif(nKey == K_INS, .f., tmp->is_nul),;
            mu_cena := iif(nKey == K_INS, 0, tmp->u_cena),;
            mKOD_DIAG  := iif(nKey == K_INS, SKOD_DIAG , tmp->KOD_DIAG),;
            mold_zf := mZF := iif(nKey == K_INS, SZF, tmp->ZF),;
            mkod_vr := iif(nKey == K_INS, pr_kod_vr, tmp->kod_vr),;
            mtabn_vr := 0, mvrach := space(35),;
            mkod_as := iif(nKey == K_INS, pr_kod_as, tmp->kod_as),;
            mtabn_as := 0, massist := space(35),;
            mkol := iif(nKey == K_INS, 0, tmp->kol),;
            mstoim := iif(nKey == K_INS, 0, tmp->stoim),;
            mt_edit := iif(nKey == K_INS, 0, tmp->t_edit),;
            mshifr := iif(nKey == K_INS, space(10), tmp->shifr_u),;
            mname_u := iif(nKey == K_INS, space(65), tmp->name_u),;
            pmmed1 := iif(nKey == K_INS, pr_med1, tmp->med1), mmed1 := 0,;
            pmmed2 := iif(nKey == K_INS, pr_med2, tmp->med2), mmed2 := 0,;
            pmmed3 := iif(nKey == K_INS, pr_med3, tmp->med3), mmed3 := 0,;
            pmsan1 := iif(nKey == K_INS, pr_san1, tmp->san1), msan1 := 0,;
            pmsan2 := iif(nKey == K_INS, pr_san2, tmp->san2), msan2 := 0,;
            pmsan3 := iif(nKey == K_INS, pr_san3, tmp->san3), msan3 := 0,;
            pr_k_usl := {},;  // массив комплексных услуг
            gl_area := {1,0,23,79,0}
    motd := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
    if mkod_vr > 0
      select PERSO
      goto (mkod_vr)
      mvrach := padr(perso->fio,35)
      mtabn_vr := perso->tab_nom
    endif
    if mkod_as > 0
      select PERSO
      goto (mkod_as)
      massist := padr(perso->fio,35)
      mtabn_as := perso->tab_nom
    endif
    select MS
    if pmmed1 > 0
      goto (pmmed1)
      if !eof() .and. ms->tip == 1
        mmed1 := ms->tab_nom
      endif
    endif
    if pmmed2 > 0
      goto (pmmed2)
      if !eof() .and. ms->tip == 1
        mmed2 := ms->tab_nom
      endif
    endif
    if pmmed3 > 0
      goto (pmmed3)
      if !eof() .and. ms->tip == 1
        mmed3 := ms->tab_nom
      endif
    endif
    if pmsan1 > 0
      goto (pmsan1)
      if !eof() .and. ms->tip == 2
        msan1 := ms->tab_nom
      endif
    endif
    if pmsan2 > 0
      goto (pmsan2)
      if !eof() .and. ms->tip == 2
        msan2 := ms->tab_nom
      endif
    endif
    if pmsan3 > 0
      goto (pmsan3)
      if !eof() .and. ms->tip == 2
        msan3 := ms->tab_nom
      endif
    endif
    box_shadow(r1-1,0,23,79,color8,iif(nKey == K_INS,"Добавление новой",;
                                                     "Редактирование")+" платной услуги","RB+/B")
    do while .t.
      setcolor(cDataCGet)
      if mem_kodotd == 1
        @ r1+1,2 say "Отделение, в котором оказана услуга" get motd ;
                 reader {|x|menu_reader(x,{{|k,r,c| get_otd(k,r+1,c,.t.) }},A__FUNCTION,,,.f.)}
      else
        @ r1+1,2 say "Отделение, в котором оказана услуга" get m1otd pict "99" ;
                 when {|g| f5e_p_kusl(g,1,10) } ;
                 valid {|g| f5e_p_kusl(g,2,10) }
        @ row(),col()+2 get motd color color14 when .f.
      endif
      @ r1+2,2 say "Дата оказания услуги" get mdate_u1 ;
               valid {|g| f5e_p_kusl(g,2,1) }
      @ r1+3,2 say "Диагноз по МКБ-10" ;
               get mkod_diag  picture pic_diag when when_diag() reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,last_date,smpol)
      @ r1+4,2 say "Зубная формула" get mzf pict pic_diag ;
               valid {|g| f5e_p_kusl(g,2,101) }
      @ r1+5,2 say "Шифр услуги" get mshifr pict "@!" ;
               when {|g| f5e_p_kusl(g,1,2) } ;
               valid {|g| f5e_p_kusl(g,2,2) }
      @ row(),40 say "Цена услуги" get mu_cena pict pict_cena ;
                when .f. color color14
      @ r1+6,2 say "Услуга" get mname_u when .f. color color14
      ix := 6
      for x := 1 to 3
        if mem_por_vr == x
          ++ix
          @ r1+ix,2 say "Таб.N врача" get mtabn_vr pict "99999" ;
                    valid {|g| f5e_p_kusl(g,2,3) }
          @ row(),col()+3 get mvrach when .f. color color14
        endif
        if mem_por_ass == x
          ++ix
          @ r1+ix,2 say "Таб.N ассистента" get mtabn_as pict "99999" ;
                    valid {|g| f5e_p_kusl(g,2,4) }
          @ row(),col()+3 get massist when .f. color color14
        endif
        if mem_por_kol == x
          ++ix
          @ r1+ix,2 say "Количество услуг" get mkol pict "999" ;
                    when {|g| is_kassa .and. f5e_p_kusl(g,1,5) } ;
                    valid {|g| f5e_p_kusl(g,2,5) }
        endif
      next
      ++ix
      @ r1+ix,2 say "Общая стоимость услуги" get mstoim pict pict_cena ;
                when {|g| is_kassa .and. mem_edit_s==2 .and. f5e_p_kusl(g,1,7) } ;
                valid {|g| f5e_p_kusl(g,2,7) }
      if mt_edit > 1
        @ r1+ix,37 say "[ редактировалась стоимость услуги ]" color color13
      endif
      if is_oplata != 7
        ++ix
        @ r1+ix,2 say "Коды медсестер" get mmed1 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,11) }
        @ row(),col() say "," get mmed2 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,11) }
        @ row(),col() say "," get mmed3 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,11) }
        @ r1+11,2 say "Коды санитарок" get msan1 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,12) }
        @ row(),col() say "," get msan2 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,12) }
        @ row(),col() say "," get msan3 pict "99999" ;
                  valid {|g| f5e_p_kusl(g,2,12) }
      endif
      status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи")
      count_edit := myread(,@pos_read,++k_read)
      SetKey( K_F2, NIL )
      SetKey( K_F3, NIL )
      if lastkey() != K_ESC
        if empty(mdate_u1)
          func_error(4,"Не введена дата оказания услуги!")
          loop
        elseif empty(mu_kod)
          func_error(4,"Не введена услуга!")
          loop
        elseif !mis_nul .and. empty(mstoim)
          func_error(4,"Не введена цена услуги!")
          loop
        elseif mem_vv_v_a == 1 .and. emptyall(mkod_vr,mkod_as)
          func_error(4,"Не введены врач и ассистент!")
          loop
        else
          err_date_diap(mdate_u1,"Дата оказания услуги")
          mywait()
          select HU
          if nKey == K_INS
            Add1Rec(7)
            mrec_hu := hu->(recno())
            fl_found := .t.
            select TMP
            append blank
            rec_tmp := tmp->(recno())
            ++mvu[1,1]  // услуга добавлена оператором
            mvu[1,2] += count_edit
          else
            goto (mrec_hu)
            G_RLock(forever)
            select TMP
            goto (rec_tmp)
            ++mvu[2,1]  // услуга отредактирована оператором
            mvu[2,2] += count_edit
          endif
          select HU
          replace hu->kod     with human->(recno()),;
                  hu->kod_vr  with mkod_vr,;
                  hu->kod_as  with mkod_as,;
                  hu->u_koef  with 1,;
                  hu->stoim   with mstoim,;
                  hu->u_kod   with mu_kod,;
                  hu->u_cena  with mu_cena,;
                  hu->t_edit  with mt_edit,;
                  hu->kol     with mkol,;
                  hu->date_u  with dtoc4(mdate_u1),;
                  hu->otd     with m1otd,;
                  hu->med1    with pmmed1,;
                  hu->med2    with pmmed2,;
                  hu->med3    with pmmed3,;
                  hu->san1    with pmsan1,;
                  hu->san2    with pmsan2,;
                  hu->san3    with pmsan3
          UNLOCK
          pr1otd := m1otd
          adbf := array(fcount())
          aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
          if !empty(mzf)
            SKOD_DIAG  := mkod_diag
            SZF        := mzf
            usl->(dbGoto(mu_kod))
            if usl->zf == 0 // не вводится зубная формула
              mzf := space(30)  // обнуляем
            endif
          endif
          if (nKey == K_INS .and. !empty(mzf)) .or. !(mold_zf == mzf) // если изменили зубную формулу
            STappend(2,mrec_hu,human->kod_k,hu->date_u,mu_kod,mkod_vr,mzf,mkod_diag)
          endif
          select TMP
          aeval(adbf, {|x,i| fieldput(i,x) } )
          tmp->KOD_DIAG  := mKOD_DIAG
          tmp->ZF        := mZF
          tmp->date_u1 := mdate_u1
          tmp->shifr_u := mshifr
          tmp->name_u := mname_u
          tmp->is_nul := mis_nul
          tmp->rec_hu := mrec_hu
          //last_date := max(tmp->date_u1,last_date) - так было
          last_date := tmp->date_u1  // - так стало
          pr_kod_vr := tmp->kod_vr
          pr_kod_as := tmp->kod_as
          pr_med1 := tmp->med1
          pr_med2 := tmp->med2
          pr_med3 := tmp->med3
          pr_san1 := tmp->san1
          pr_san2 := tmp->san2
          pr_san3 := tmp->san3
          summa_usl(@mcena)
          select HUMAN
          G_RLock(forever)
          human->cena := mcena
          UNLOCK
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
    ST3e_p_kusl()
    select TMP
    oBrow:goTop()
    goto (rec_tmp)
    setcolor(tmp_color)
  case nKey == K_DEL .and. tmp->kod > 0 .and. f_Esc_Enter(2)
    mywait()
    ++mvu[3,1]  // услуга удалена оператором
    STdelHuman(2,tmp->rec_hu)
    STdelKart(2,tmp->rec_hu)
    select HU
    goto (tmp->rec_hu)
    DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
    select TMP
    DeleteRec(.t.)  // с пометкой на удаление
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
    ST3e_p_kusl()
  otherwise
    keyboard ""
endcase
help_code := tmp_help
restuchotd(uch_otd)
return flag

*

*****
Static Function summa_usl(s)
Local j := 0
s := 0
select TMP
go top
do while !eof()
  s += tmp->stoim
  tmp->number := ++j
  skip
enddo
s := round(s,2)
return NIL

*

*****  14.02.13
Function st1_plat_fio()
Local reg := 1
Local vr_as, adbf, i, j, arr[2], begin_date, end_date, ;
      fl_exit := .f., sh, HH := 57, reg_print, s, xx, n, nvr,;
      arr_otd := {}, n_file := "plat_fio"+stxt, buf := save_maxrow()
Private krvz, arr_dms, d_file := "PLAT_FIO"+sdbf, otdeleni := {}
if !del_dbf_file(d_file)
  return NIL
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if (arr := year_month()) == NIL
  return NIL
endif
begin_date := arr[7]
end_date := arr[8]
if (krvz := fbp_tip_usl(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
mywait()
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
go top
do while !eof()
  if f_is_uch(st_a_uch,otd->kod_lpu)
    uch->(dbGoto(otd->kod_lpu))
    aadd(arr_otd,{otd->(recno()),otd->name,otd->kod_lpu,uch->name})
  endif
  skip
enddo
close databases
adbf := {{"kod",  "N", 7,0},;  // код л/у
         {"kod_k","N", 7,0},;  // код по картотеке
         {"kod_p","N", 4,0},;  // код персонала
         {"otd",  "N", 3,0},;  // код отделения
         {"summa","N",12,2},;  // общая сумма лечения по данному отделению
         {"sm_vozvr","N",12,2}; // общая сумма лечения по данному отделению
        }
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
index on str(kod_k,7)+str(kod,7)+str(otd,3)+str(kod_p,4) to (cur_dir+"tmp")
G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
G_Use(dir_server+"hum_p",,"HUMAN")
if pi1 == 3  // по дате закрытия листа учета
  set index to (dir_server+"hum_pc")
  for xx := 0 to 2
    if ascan(krvz,xx) > 0
      select HUMAN
      dbseek(str(xx,1)+"1"+dtos(arr[5]),.t.)
      do while human->tip_usl==xx .and. human->date_close <= arr[6] .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t. ; exit
        endif
        if iif(arr_dms == NIL, .t., ascan(arr_dms,human->pr_smo) > 0)
          select HU
          find (str(human->(recno()),7))
          do while hu->kod == human->(recno())
            if ascan(arr_otd, {|x| hu->otd==x[1]}) > 0
              f1_plat_fio(reg,vr_as)
            endif
            select HU
            skip
          enddo
        endif
        select HUMAN
        skip
      enddo
    endif
    if fl_exit ; exit ; endif
  next
else  // только по дате окончания лечения
  set index to (dir_server+"hum_pd")
  dbseek(dtos(arr[5]),.t.)
  do while human->k_data <= arr[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if ascan(krvz,human->tip_usl) > 0 .and. ;
              iif(arr_dms == NIL, .t., ascan(arr_dms,human->pr_smo) > 0)
      select HU
      find (str(human->(recno()),7))
      do while hu->kod == human->(recno())
        if ascan(arr_otd, {|x| hu->otd==x[1]}) > 0
          f1_plat_fio(reg,vr_as)
        endif
        select HU
        skip
      enddo
    endif
    select HUMAN
    skip
  enddo
endif
j := tmp->(lastrec())
close databases
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  n := 40
  arr_title := {replicate("─",n),;
                padc("Ф.И.О. больного",n),;
                padc("наименование услуги",n),;
                replicate("─",n)}
  adbf := {{"fio","C",50,0}}
  if reg == 1
    arr_title[1] += "┬──────────"
    arr_title[2] += "│ Окончание"
    arr_title[3] += "│  лечения "
    arr_title[4] += "┴──────────"
    aadd(adbf,{"k_data","C",10,0})
  endif
  if pi1 == 3  // по дате закрытия листа учета
    arr_title[1] += "┬──────────"
    arr_title[2] += "│   Дата   "
    arr_title[3] += "│  оплаты  "
    arr_title[4] += "┴──────────"
    aadd(adbf,{"date_close","C",10,0})
  endif
  if len(st_a_uch) > 1
   // arr_title[1] += "┬──────────"
   // arr_title[2] += "│          "
   // arr_title[3] += "│Учреждение"
   // arr_title[4] += "┴──────────"
    aadd(adbf,{"uch","C",30,0})
  endif
 // arr_title[1] += "┬─────"
 // arr_title[2] += "│Отде-"
 // arr_title[3] += "│ление"
 // arr_title[4] += "┴─────"
  aadd(adbf,{"otd","C",50,0})
  nvr := 20
  if reg == 2
    arr_title[1] += "┬"+replicate("─",nvr)
    arr_title[2] += "│"+space(nvr)
    arr_title[3] += "│"+padc({"Врачи","Ассистенты","Медсестры","Санитарки"}[vr_as],nvr)
    arr_title[4] += "┴"+replicate("─",nvr)
    aadd(adbf,{"tab_nom","N",5,0})
    aadd(adbf,{"personal","C",50,0})
  endif
  arr_title[1] += "┬───────────"
  arr_title[2] += "│ Стоимость "
  arr_title[3] += "│  договора "
  arr_title[4] += "┴───────────"
  arr_title[1] += "┬───────────"
  arr_title[2] += "│ Стоимость "
  arr_title[3] += "│   услуг   "
  arr_title[4] += "┴───────────"
  aadd(adbf,{"summa","N",12,2})
  dbcreate(d_file,adbf)
  use (d_file) new alias DD
  reg_print := f_reg_print(arr_title,@sh)
  R_Use(dir_server+"mo_uch",,"UCH")
  R_Use(dir_server+"mo_otd",,"OTD")
  set relation to kod_lpu into UCH
  G_Use(dir_server+"kartotek",,"KART")
  G_Use(dir_server+"uslugi",,"USL")
  G_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
  set relation to u_kod into USL
  G_Use(dir_server+"hum_p",,"HUMAN")
  use (cur_dir+"tmp") new
  set relation to otd into OTD, to kod_k into KART, to kod into HUMAN
  if reg == 2
    if vr_as < 3
      R_Use(dir_server+"mo_pers",,"PERSO")
      set relation to kod_p into PERSO additive
    else
      G_Use(dir_server+"plat_ms",,"P2")
      select TMP
      set relation to kod_p into P2 additive
    endif
  endif
  index on upper(uch->name)+left(upper(otd->name),20)+left(upper(kart->fio),20)+str(kod_k,7)+dtos(human->k_data) ;
        to (cur_dir+"tmp")
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string("ПЛАТНЫЕ УСЛУГИ")
  add_string(center("Статистика по работе персонала",sh))
  titleN_uch(st_a_uch,sh)
  tit_tip_usl(krvz,arr_dms,sh)
  add_string(center(arr[4],sh))
  add_string("")
  do case
    case pi1 == 1
      s := "[ по дате лечения ]"
    case pi1 == 2
      s := "[ по дате окончания лечения ]"
    case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
  endcase
  add_string(center(s,sh))
  add_string("")
  old_kart := -999 ; old_lu := 0
  select TMP
  go top
  aeval(arr_title, {|x| add_string(x) } )
  old_otdel := otd->name
  s_otdel   := 0
  s_vozvr   := 0
  s1vozvr   := 0
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    If old_otdel != otd->name
      n1 := len(arr_title[1])
      add_string(replicate("─",n1))
      add_string(padr(alltrim(old_otdel),n+1)+"    ИТОГО:"+ put_kop(s_otdel,12))
      add_string("")
      aadd(otdeleni, {old_otdel,s_otdel,s_vozvr,s1vozvr} )
      old_otdel := otd->name
      s_otdel := tmp->summa
      if human->date_voz == human->pdate
        s_vozvr := human->sum_voz
        s1vozvr := 0
      else
        s_vozvr := 0
        s1vozvr := human->sum_voz
      endif
    else
      s_otdel += tmp->summa
      if human->date_voz == human->pdate
        s_vozvr += human->sum_voz
      else
        s1vozvr += human->sum_voz
      endif
    endif
    if old_kart==tmp->kod_k .and. old_lu==tmp->kod
      s := space(n)
    else
      s := padr(kart->fio,n)
    endif
    old_kart:=tmp->kod_k
    old_lu:=tmp->kod
    if reg == 1
      s += " "+full_date(human->k_data)
    endif
    if pi1 == 3  // по дате закрытия листа учета
      s += " "
      if human->date_close > human->k_data
        s += full_date(human->date_close)
      else
        s += padc("аванс",10)
      endif
    endif
    if reg == 2
      s1 := "["
      if vr_as < 3
        if mem_tabnom == 2
          s1 += lstr(tabn->tab_nom)
        else
          s1 += lstr(tmp->kod_p)
        endif
      else
        s1 += lstr(p2->tab_nom)
      endif
      s1 += "] "+fam_i_o(p2->fio)
      s += " "+padr(s1,nvr)
    endif
    s += put_kop(tmp->summa,12)
    if human->sum_voz > 0
      s += "ВОЗВРАТ"
    endif
    add_string(s)
    select HU
    find(str(human->(recno()),7))
    do while human->(recno()) == hu->kod .and. !eof()
      if hu->otd == tmp->otd
        if glob_mo[_MO_KOD_TFOMS] == '171004' // КБ-4
          add_string("  "+padr(usl->full_name,60)+" "+put_kop(hu->stoim,12))
        else
          add_string("  "+padr(usl->name,60)+" "+put_kop(hu->stoim,12))
        endif
      endif
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      skip
    enddo
    select TMP
    skip
  enddo
  n1 := len(arr_title[1])
  add_string(replicate("─",n1))
  add_string(padr(alltrim(old_otdel),n+1)+"    ИТОГО:"+ put_kop(s_otdel,12))
  aadd(otdeleni, {old_otdel,s_otdel,s_vozvr,s1vozvr} )
  add_string("")
  verify_FF(2,.t.,sh)
  arr_title := {;
  "───────────────────────────────────────────┬───────────┬───────────┬───────────",;
  "                                           │ Оплачено в│  Возврат  │   Возврат ",;
  "                 Отделения                 │   кассу   │через кассу│ через банк",;
  "───────────────────────────────────────────┴───────────┴───────────┴───────────"}
  sh := len(arr_title[1])
  add_string(center("Итого по отделениям"),sh)
  add_string("")
  do case
    case pi1 == 1
      s := "[ по дате лечения ]"
    case pi1 == 2
      s := "[ по дате окончания лечения ]"
    case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
  endcase
  add_string(center(s,sh))
  add_string(center(arr[4],sh))
  sm  := 0
  sm1 := 0
  sm2 := 0
  aeval(arr_title, {|x| add_string(x) } )
  for i := 1 to len(otdeleni)
    add_string(padr(alltrim(otdeleni[i,1]),44)+ put_kope(otdeleni[i,2],12)+;
               put_kope(otdeleni[i,3],12)+put_kope(otdeleni[i,4],12))
    sm += otdeleni[i,2]
    sm1 += otdeleni[i,3]
    sm2 += otdeleni[i,4]
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
  next
  add_string(replicate("─",sh))
  add_string(padl("ИТОГО: ",44)+put_kope(sm,12)+put_kope(sm1,12)+put_kope(sm2,12))
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,reg_print)
  rest_box(buf)
endif
rest_box(buf)
return NIL

*

***** 05.10.17 печать счёта-фактуры
Function pl_print_faktura(ret,sk,ss)
Local adbf := {}, ip := 0, s
//
Private pole := "_t->name"
delFRfiles()
dbcreate(fr_titl,{{"title1","C",100,0},;
                  {"title2","C",100,0},;
                  {"name01","C",200,0},;
                  {"name02","C",200,0},;
                  {"name03","C",200,0},;
                  {"name04","C",200,0},;
                  {"name05","C",200,0},;
                  {"name06","C",200,0},;
                  {"name07","C",200,0},;
                  {"name08","C",200,0},;
                  {"name09","C",200,0},;
                  {"name10","C",200,0},;
                  {"name11","C",200,0},;
                  {"name12","C",200,0},;
                  {"name13","C",200,0},;
                  {"name14","C",200,0},;
                  {"name15","C",200,0},;
                  {"pril","C",200,0},;
                  {"pril2","C",100,0},;
                  {"bottom","C",2000,0},;
                  {"stoim","C",15,0},;
                  {"nds","C",15,0},;
                  {"itogo","C",15,0},;
                  {"ind_pred","C",80,0},;
                  {"svid_vo","C",80,0},;
                  {"fio_ruk","C",50,0},;
                  {"fio_bux","C",50,0}})
for j := 1 to 13
  aadd(adbf, {"p_"+lstr(j),"C",60,0})
next
dbcreate(fr_data,adbf)
use (fr_titl) new alias _t
append blank
use (fr_data) new alias _d
R_Use(dir_server+"organiz",,"ORG")
pok_name := pok_adres := pok_inn := ""
s := "Оказание медицинских услуг "+arr_m[4]+" - "+lstr(sk)+" чел."
if tmp1->tip_usl == 1
  R_Use(dir_server+"p_d_smo",,"PK")
else
  R_Use(dir_server+"p_pr_vz",,"PK")
endif
goto (tmp1->pr_smo)
pok_name := alltrim(iif(empty(pk->fname), pk->name, pk->fname))
pok_adres := alltrim(pk->adres)
pok_inn := alltrim(pk->inn)
//
_t->pril := "Приложение № 1"+eos+;
            "к постановлению Правительства"+eos+;
            "Российской Федерации"+eos+;
            "от 26 декабря 2011 г. № 1137"
_t->pril2 := "(в ред.Постановления Правительства РФ от 19.08.2017 №981)"
_t->title1 := "СЧЕТ-ФАКТУРА  № "+alltrim(ret[1])+" от "+date_month(ret[2],.t.)
_t->title2 := "ИСПРАВЛЕНИЕ   № -          от -"
ip := 1
&(pole+strzero(++ip,2)) := "Продавец :  "+org->name
&(pole+strzero(++ip,2)) := "Адрес :  "+org->adres
&(pole+strzero(++ip,2)) := "ИНН/КПП продавца :  "+org->inn
&(pole+strzero(++ip,2)) := "Грузоотправитель и его адрес :  "+alltrim(org->name)+", "+org->adres
&(pole+strzero(++ip,2)) := "Грузополучатель и его адрес :  "+pok_name+", "+pok_adres
&(pole+strzero(++ip,2)) := "К платежно-расчетному документу № _________ от ____________________"
&(pole+strzero(++ip,2)) := "Покупатель :  "+pok_name
&(pole+strzero(++ip,2)) := "Адрес :  "+pok_adres
&(pole+strzero(++ip,2)) := "ИНН/КПП покупателя :  "+pok_inn
&(pole+strzero(++ip,2)) := "Валюта: наименование, код :  Российский рубль, 643"
&(pole+strzero(++ip,2)) := "Идентификатор государственного контракта, договора (соглашения) (при наличии):"
select _d
append blank
_d->p_1 := s
_d->p_2 := "-"
_d->p_3 := "-"
_d->p_4 := "1"
_d->p_5 := lstr(ss,11,2)
_d->p_6 := lstr(ss,13,2)
_d->p_7 := "без акциза"
_d->p_8 := _d->p_9 := "без НДС"
_d->p_10 := lstr(ss,13,2)
_d->p_11 := "643"
_d->p_12 := "Россия"
//_d->p_13 := mtamog
_t->stoim := lstr(ss,15,2)
_t->nds := ""
_t->itogo := lstr(ss,15,2)
_t->fio_ruk := alltrim(org->ruk)
_t->fio_bux := alltrim(org->bux)
close databases
call_fr("mo_faktu"+sfr3)
return NIL

*

***** 03.04.14 печать акта выполненных работ
Function pl_print_akt(ret,sk,ss)
Local adbf := {}, s
//
delFRfiles()
dbcreate(fr_titl,{{"nomer","C",10,0},;
                  {"data","C",30,0},;
                  {"prod_name","C",150,0},;
                  {"prod_adres","C",100,0},;
                  {"prod_inn","C",20,0},;
                  {"pok_name","C",150,0},;
                  {"pok_adres","C",100,0},;
                  {"pok_inn","C",20,0},;
                  {"stoim","C",15,0},;
                  {"sstoim","C",200,0}})
for j := 1 to 7
  aadd(adbf, {"p_"+lstr(j),"C",60,0})
next
dbcreate(fr_data,adbf)
use (fr_titl) new alias _t
append blank
use (fr_data) new alias _d
R_Use(dir_server+"organiz",,"ORG")
p_name := p_adres := p_inn := ""
s := "Оказание медицинских услуг "+arr_m[4]+" - "+lstr(sk)+" чел."
if tmp1->tip_usl == 1
  R_Use(dir_server+"p_d_smo",,"PK")
else
  R_Use(dir_server+"p_pr_vz",,"PK")
endif
goto (tmp1->pr_smo)
p_name := alltrim(iif(empty(pk->fname), pk->name, pk->fname))
p_adres := alltrim(pk->adres)
p_inn := alltrim(pk->inn)
//
_t->nomer := alltrim(ret[1])
_t->data := date_month(ret[2],.t.)
_t->prod_name := org->name
_t->prod_adres := org->adres
_t->prod_inn := org->inn
_t->pok_name := p_name
_t->pok_adres := p_adres
_t->pok_inn := p_inn
select _d
append blank
_d->p_1 := s
_d->p_2 := "1"
_d->p_3 := _d->p_4 := lstr(ss,11,2)
_d->p_5 := _d->p_6 := "-"
_d->p_7 := lstr(ss,13,2)
_t->stoim := lstr(ss,15,2)
_t->sstoim := srub_kop(ss,.t.)
close databases
call_fr("mo_akt"+sfr3)
return NIL

*

***** 04.04.14
Function rees_new_vzaim(nd_faktura)
Local buf := save_row(maxrow()), s, i, j, k, ss, lss, adbf, km
delFRfiles()
mywait()
adbf := {{"n_fakt","C",10,0},;
         {"d_fakt","C",10,0},;
         {"n_dog","C",30,0},;
         {"d_dog","C",10,0},;
         {"d_beg","C",40,0},;
         {"d_end","C",40,0},;
         {"prod_name","C",150,0},;
         {"pok_name","C",150,0},;
         {"prod1name","C",150,0},;
         {"pok1name","C",150,0},;
         {"prod2name","C",150,0},;
         {"pok2name","C",150,0},;
         {"stoim","N",15,2}}
dbcreate(fr_titl,adbf)
adbf := {{"nomer",   "N", 4,0},;
         {"fio",     "C",60,0},;
         {"polis",   "C",25,0},;
         {"n_kart",  "C",10,0},;
         {"data",    "C",10,0},;
         {"kod",     "C",10,0},;
         {"name",    "C",70,0},;
         {"ZF"      ,"C",30,0},;
         {"vrach",   "C",50,0},;
         {"diagnoz", "C", 6,0},;
         {"GP_NOMER","C",16,0},; // № гарантийного письма по ДМС
         {"GP_DATE" ,"C",10,0},; // дата гарантийного письма по ДМС
         {"cena",    "N",10,2},;
         {"kol",     "N", 4,0},;
         {"summa",   "N",12,2}}
dbcreate(fr_data,adbf)
use (fr_titl) new alias _t
append blank
use (fr_data) new alias _d
//
_t->n_fakt := nd_faktura[1]
_t->d_fakt := full_date(nd_faktura[2])
R_Use(dir_server+"organiz",,"ORG")
_t->prod_name := alltrim(org->name)
_t->prod1name := "ИНН/КПП "+alltrim(org->inn)+"    Адрес: "+alltrim(org->adres)
_t->prod2name := "Банк "+alltrim(org->bank)+"    БИК "+alltrim(org->smfo)+"    Р/С "+;
                 alltrim(org->r_schet)
if tmp1->tip_usl == 1
  R_Use(dir_server+"p_d_smo",,"PK")
else
  R_Use(dir_server+"p_pr_vz",,"PK")
endif
goto (tmp1->pr_smo)
_t->pok_name := alltrim(iif(empty(pk->fname), pk->name, pk->fname))
_t->n_dog := pk->n_dog
_t->d_dog := full_date(pk->d_dog)
_t->d_beg := date_month(arr_m[5])
_t->d_end := date_month(arr_m[6])
_t->pok1name := "ИНН/КПП "+alltrim(pk->inn)+"    Адрес: "+alltrim(pk->adres)
_t->pok2name := "Банк "+alltrim(pk->bank)+"    БИК "+alltrim(pk->smfo)+"    Р/С "+;
                 alltrim(pk->r_schet)
Use_base("humanst")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"mo_pers",,"perso")
R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HPU")
R_Use(dir_server+"hum_p",,"HP")
j := ss := 0
select TMP
go top
do while !eof()
  select TMP2
  find (str(tmp->(recno()),6))
  do while tmp2->rec_tmp == tmp->(recno()) .and. !eof()
    select HP
    goto (tmp2->rec_hp)
    //
    adiag := {}
    add_diagnoz(adiag) ; asort(adiag)
    //
    agp := {}
    if !emptyall(hp->GP_NOMER,hp->GP_DATE)
      aadd(agp,{hp->GP_NOMER,hp->GP_DATE})
    endif
    if !emptyall(hp->GP2NOMER,hp->GP2DATE)
      aadd(agp,{hp->GP2NOMER,hp->GP2DATE})
    endif
    //
    ausl := {}
    select HPU
    find (str(hp->(recno()),7))
    do while hpu->kod == hp->(recno()) .and. !eof()
      usl->(dbGoto(hpu->u_kod))
      perso->(dbGoto(hpu->kod_vr))
      select HUMANST
      find (str(2,1)+str(hpu->(recno()),8))
      aadd(ausl, {c4tod(hpu->date_u),;
                  usl->shifr,;
                  usl->name,;
                  hpu->kol,;
                  hpu->stoim,;
                  iif(humanst->(found()), humanst->ZF, ""),;
                  iif(hpu->kod_vr > 0, fam_i_o(perso->fio), "");
                 })
      select HPU
      skip
    enddo
    if max(len(ausl),len(adiag),len(agp)) == 0
      aadd(adiag,"")
    endif
    asort(ausl,,,{|x,y| iif(x[1]==y[1], fsort_usl(x[2]) < fsort_usl(y[2]), x[1] < y[1]) } )
    ++j ; lss := 0
    km := max(len(ausl),len(adiag),len(agp))
    for i := 1 to km
      select _D
      append blank
      if i == 1
        _d->nomer := j
        _d->fio   := alltrim(kart->fio)+eos
        _d->polis := alltrim(hp->d_polis)+eos
        _d->n_kart := amb_kartaN()
      endif
      if i <= len(ausl)
        _d->data  := full_date(ausl[i,1])
        _d->kod   := ausl[i,2]
        _d->name  := alltrim(ausl[i,3])+eos
        _d->cena  := iif(ausl[i,4] > 0, ausl[i,5]/ausl[i,4], ausl[i,5])
        _d->kol   := ausl[i,4]
        _d->summa := ausl[i,5]
        _d->zf    := alltrim(ausl[i,6])+eos
        _d->vrach := ausl[i,7]
        lss += ausl[i,5]
      endif
      if i <= len(adiag)
        _d->diagnoz := adiag[i]
      endif
      if i <= len(agp)
        _d->GP_NOMER := alltrim(agp[i,1])+eos
        _d->GP_DATE  := full_date(agp[i,2])
      endif
    next
    select _D
    append blank
    _d->fio := "Итого по пациенту:"
    _d->summa := lss
    ss += lss
    select TMP2
    skip
  enddo
  select TMP
  skip
enddo
_t->stoim := ss
close databases
rest_box(buf)
message_fr_excel()
call_fr("mo_reesdms"+sfr3)
return NIL

***** 13.04.14
Function message_fr_excel()
Local n := 0, arr := {;
  "Для экспорта документа в Excel выполните следующие действия:",;
  '- выберите четвёртую слева пиктограмму "Экспорт"',;
  '- в выпадающем меню "Экспорт" выберите "Документ Excel (OLE)"',;
  '- в разделе "Опции" окна настройки экспорта в Excel:',;
  '-- отметьте поля "Неразрывный" и "Открыть Excel после экспорта"',;
  '-- снимите отметку с поля "Разрывы страниц"'}
aeval(arr, {|x| n := max(n,len(x)) })
aeval(arr, {|x,i| arr[i] := padr(x,n,chr(255)) })
n_message(arr,;
          {"","Нажмите любую клавишу для вывода документа в FastReport"},;
          color1,;  // строка цвета для рамки
          cDataCSay,;  // строка цвета для текста
          ,;  // верхний ряд рамки (99 - центировать)
          ,;  // левая колонка рамки (99 - центрировать)
          color8)   // строка цвета для бегущей строки
return NIL


*

***** 23.06.19
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
add_string(center("(по дате возврата)",sh))
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
index on date_voz+FR_zavod  to (cur_dir+"tmp_uu") for sum_voz > 0
// human->date_voz with dtoc4(date()), human->sum_voz with p_summa
go top
do while !eof()
  if between(hum->date_voz,arr_m[7],arr_m[8]) .and.;
                        ascan(krvz,hum->tip_usl) > 0
                     //.and. hum->SUM_VOZ > 0
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    select KART
    goto (hum->kod_k)
    add_string("--"+hum->FR_zavod)
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
      add_string(usl->shifr+padr(iif(!empty(usl->full_name),usl->full_name,usl->name),40)+;
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


***** 27.03.19
Function pl_priemshk()
Local fl := .t., buf := save_row(maxrow()), sm2 := 0, HH := 52,;
      n_file := "platn.txt", arr_m, sh, krvz, arr_dms,;
      mas_op1 := {}, mas_op2 := {}, mas_op3 := {}, i, arr[2], sm_bn := 0,;
      t_hum_rec, kart_kod, t_k_data, nom_prihod := 0

Local arr_title := {;
  "───┬──────────────────────────────────────┬──────┬─────┬──────┬──────────┬────────────────────",;
  " N │           Ф.И.О. пациента            │Время │ Чек │Код П │  Сумма   │        Врач        ",;
  "───┴──────────────────────────────────────┴──────┴─────┴──────┴──────────┴────────────────────"}

if glob_mo[_MO_KOD_TFOMS] == '171004' // КБ-4
  arr_title := {;
  "───┬──────────────────────────────────────┬──────┬─────┬────────┬──────────┬──────────────────",;
  " N │           Ф.И.О. пациента            │Время │ Чек │ Договор│  Сумма   │       Врач       ",;
  "───┴──────────────────────────────────────┴──────┴─────┴────────┴──────────┴──────────────────"}
endif

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
                         {"dogovor", "C", 10,  0},;
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
R_Use(dir_server+"hum_p",dir_server+"hum_pkk","HUM")
index on fr_data  to (cur_dir+"tmp_uu") for !empty(fr_data)
// index on str(kod_k,7)+dtos(k_data)+str(KV_CIA,6) to (dir_server+"hum_pkk") descending progress
//go top
find(arr_m[7])
do while hum->fr_data <= arr_m[8] .and. !eof()
  if (hum->kod_oper == asc(kod_polzovat) .or. tip_polzovat == 0) .and.;
      ascan(krvz,hum->tip_usl) > 0
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
    tmp->dogovor  := lstr(hum->kod_k)
    if glob_mo[_MO_KOD_TFOMS] == '171004' // КБ-4
      nom_prihod := 0
      t_hum_rec := hum->(recno())
      kart_kod := hum->kod_k
      t_k_data := year(hum->k_data)
      select HUM
      do while hum->kod_k == kart_kod .and. year(hum->k_data) == t_k_data .and. !eof()
        ++nom_prihod
        skip
      enddo
      goto (t_hum_rec)
      tmp->dogovor  := lstr(hum->kod_k)+"/"+lstr(nom_prihod)
    endif
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
    if glob_mo[_MO_KOD_TFOMS] == '171004' // КБ-4
      add_string(str(++ii,3)+" "+;
                 padr(tmp->fio,38)+;
                 iif(tmp->summa_bn > 0,"БН","  ")+;
                 padr(sectotime(tmp->fr_time),5)+" "+;
                 padl(lstr(tmp->chek),5)+" "+;
                 padr(tmp->dogovor,8)+" "+;
                 iif(tmp->summa_bn > 0,put_kope(tmp->summa_bn,10),put_kope(tmp->summa,10))+" "+;
                 padr(fam_i_o(tmp->fio_vr),18)+;
                 iif(tmp->t_flag==1,"*"," "))
      if tmp->summa > tmp->summa_bn .and. tmp->summa_bn > 0
        add_string(str(++ii,3)+" "+;
                   padr(tmp->fio,38)+"  "+;
                   padr(sectotime(tmp->fr_time),5)+" "+;
                   padl(lstr(tmp->chek),5)+" "+;
                   padr(tmp->dogovor,8)+" "+;
                   put_kope(tmp->summa-tmp->summa_bn,10)+" "+;
                   padr(fam_i_o(tmp->fio_vr),18)+;
                   iif(tmp->t_flag==1,"*"," "))
      endif
    else
      add_string(str(++ii,3)+" "+;
                 padr(tmp->fio,38)+;
                 iif(tmp->summa_bn > 0,"БН","  ")+;
                 padr(sectotime(tmp->fr_time),5)+" "+;
                 padl(lstr(tmp->chek),5)+" "+;
                 padl(lstr(tmp->kod_hum),6)+" "+;
                 iif(tmp->summa_bn > 0,put_kope(tmp->summa_bn,10),put_kope(tmp->summa,10))+" "+;
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
    endif
    sm2 += tmp->summa
    sm_bn += tmp->summa_bn
    skip
  enddo
  add_string(replicate("─",sh))
  if glob_mo[_MO_KOD_TFOMS] == '171004' // КБ-4
    add_string(padR("Итого: ",63)+put_kope(sm2,12))
  else
    add_string(padR("Итого: ",61)+put_kope(sm2,12))
  endif
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
