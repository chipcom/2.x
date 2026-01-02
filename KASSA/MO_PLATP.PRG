// mo_platp.prg - Информация ПЛАТНЫЕ
#include "set.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 02.05.18
Function po_statist( k )

  Static si1 := 1, si2 := 1, si3 := 1, si4
  Local uch_otd, mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  // ВРЕМЕННО
  // Private COUNT_UCH := 1
  Do Case
  Case k == 1
    uch_otd := saveuchotd()
    mas_pmt := { "~Объем работ", ;
      "По № ~квитанционной книжки", ;
      "По ~направившему врачу", ;
      "ДМС и ~взаимозачет", ;
      "~Множественный запрос", ;   // "~Сводная ведомость",;
      "~Журнал Регистрации", ;
      "Настраиваемый журнал ~Регистрации", ; // 21.05.08
      "По дате приема ~денег";
      }
    mas_msg := { "Статистика по объему работ персонала (по дате окончания лечения)", ;
      "Статистика по объему работ (по номеру квитанционной книжки)", ;
      "Статистика по направившим врачам", ;
      "Инф-ия о больных (о персонале), которые лечились (работали) по ДМС и взаимозач.", ;
      "Множественный запрос", ;   // "Сводная ведомость по объему работ персонала [по всем задачам]",;
      "Журнал регистрации договоров", ;
      "Настраиваемый журнал Регистрации", ; // 21.05.08
      "По дате приема денег";
      }
    mas_fun := { "Po_statist(11)", ;
      "Po_statist(12)", ;
      "Po_statist(13)", ;
      "Po_statist(14)", ;
      "Po_statist(15)", ;    // "Po_statist(16)",;
      "Po_statist(18)", ;
      "Po_statist(19)", ;
      "Po_statist(17)";
      }
    Private p_net_otd := .t.
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
    restuchotd( uch_otd )
  Case k == 11
    pob_statist()
  Case k == 12
    k_statist( 1 )
  Case k == 13
    mas_pmt := { "~Врачи + кол-во больных", ;
      "Врачи + ~услуги" }
    mas_msg := { "Статистика по направившим врачам с подсчетом количества больных", ;
      "Статистика по направившим врачам с расшифровкой по услугам" }
    mas_fun := { "Po_statist(31)", ;
      "Po_statist(32)" }
    popup_prompt( T_ROW, T_COL -5, si3, mas_pmt, mas_msg, mas_fun )
  Case k == 14
    mas_pmt := { "~Больные по ДМС и взаимозачету", ;
      "~Оплата по ДМС и взаимозачету", ;
      "Оборотная ве~домость", ;
      "~Врачи по ДМС и взаимозачету" }
    mas_msg := { "Информация о больных, которые лечились по ДМС и взаимозачету", ;
      "Информация о платежах от предприятий по ДМС и взаимозачету", ;
      "Получение оборотных ведомостей по ДМС и взаимозачету", ;
      "Информация о врачах, которые работали по ДМС и взаимозачету" }
    mas_fun := { "Po_statist(21)", ;
      "Po_statist(22)", ;
      "Po_statist(23)", ;
      "Po_statist(24)" }
    If is_oplata != 7
      AAdd( mas_pmt, "~Медсестры по ДМС и взаимозачету" )
      AAdd( mas_pmt, "~Санитарки по ДМС и взаимозачету" )
      AAdd( mas_msg, "Информация о медсестрах, которые работали по ДМС и взаимозачету" )
      AAdd( mas_msg, "Информация о санитарках, которые работали по ДМС и взаимозачету" )
      AAdd( mas_fun, "Po_statist(25)" )
      AAdd( mas_fun, "Po_statist(26)" )
    Endif
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 15
    pl_mnog_poisk()
  Case k == 16
    // sv_ved_plat()
    ne_real()
  Case k == 17
    mas_pmt := { "~Сводная по организации", ;
      "~По кассовым аппаратам", ;
      "По ~кассирам" }
    mas_msg := { "Статистика по услугам по дате приема денег", ;
      "Статистика по дате приема денег с группировкой по кассовым аппаратам", ;
      "Статистика по дате приема денег с группировкой по кассирам" }
    mas_fun := { "Po_statist(71)", ;
      "Po_statist(72)", ;
      "Po_statist(73)";
      }
    popup_prompt( T_ROW, T_COL -5, si3, mas_pmt, mas_msg, mas_fun )
  Case k == 18
    pl_pl_dogovor()
  Case k == 19
    pl_pl_2dogovor()
    //
  Case eq_any( k, 21, 24, 25, 26 )
    Default si4 To glob_close + 1
    mas_pmt := { "По дате ~окончания лечения", ;
      "По дате ~закрытия л/учета" }
    If ( j := popup_prompt( T_ROW, T_COL -5, si4, mas_pmt ) ) > 0
      si4 := j
      Private pi1 := si4 + 1
      If k == 21
        pl_vzaimozach()
      Else
        vr_vzaimozach( k -23 )
      Endif
    Endif
  Case k == 22
    pr_opl_vz()
  Case k == 23
    ob_ved_vz()
    //
  Case k == 31
    pl_napr_vrach()
  Case k == 32
    pl_napr2vrach()
  Case k == 71
    pl2_priemden( 1 )
  Case k == 72
    pl1_priemden( 2 )
  Case k == 73
    pl1_priemden( 3 )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Elseif Between( k, 31, 39 )
      si3 := j
    Endif
  Endif

  Return Nil

// Объем работ персонала
//
Function pob_statist()

  Static si
  Local mas_pmt := { "Объем работ (по дате ~лечения)", ;
    "Объем работ (по дате ~окончания лечения)", ;
    "Объем работ (по дате ~закрытия л/учета)" }
  Local mas_msg := { "Статистика по объему работ персонала (по дате лечения)", ;
    "Статистика по объему работ персонала (по дате окончания лечения)", ;
    "Статистика по объему работ персонала (по дате закрытия листа учета)" }
  Local mas_fun := { "Pob1_statist(0,1)", ;
    "Pob1_statist(0,2)", ;
    "Pob1_statist(0,3)" }
  Private pi1 := si, psz

  Default si To glob_close + 2
  popup_prompt( T_ROW, T_COL -5, si, mas_pmt, mas_msg, mas_fun )
  If pi1 != NIL ; si := pi1 ; Endif

  Return Nil

// объем работ персонала
Function pob1_statist( k, k1 )

  Static si0 := 1, si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1, si_slugba
  Local mas_pmt, mas_msg, mas_fun, j, fl

  Do Case
  Case k == 0
    pi1 := k1
    mas_pmt := { "~Стоимость лечения", ;
      "~Заработная плата" }
    mas_msg := { "Статистика по объему работ с подсчетом стоимости лечения", ;
      "Статистика по объему работ с подсчетом заработной платы" }
    mas_fun := { "Pob1_statist(1,1)", ;
      "Pob1_statist(1,2)" } //
    popup_prompt( T_ROW, T_COL -5, si0, mas_pmt, mas_msg, mas_fun, color0 + ",R/BG,GR+/N" )
  Case k == 1
    psz := si0 := k1
    mas_pmt := { "~Отделения", ;
      "~Службы", ;
      "~Персонал", ;
      "~Услуги" }
    mas_msg := { "Статистика по работе персонала и оказанным услугам в отделениях", ;
      "Количество услуг и сумма лечения по службам", ;
      "Статистика по работе персонала (независимо от отделения)", ;
      "Статистика по оказанию конкретных услуг (независимо от отделения)" }
    mas_fun := { "Pob1_statist(11)", ;
      "Pob1_statist(12)", ;
      "Pob1_statist(13)", ;
      "Pob1_statist(14)" }
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11  // отделения
    mas_pmt := { "~Список отделений", ;
      "Отделение + ~персонал", ;
      "Отделение + ~услуги", ;
      "~Отделение + персонал + услуги", ;
      "Отделение + услуга + ~больные", ;
      "Отделение + ~1 человек + больные", ;
      "Отделения + больные + услуги", ;
      "Больные по от~делениям" }
    mas_msg := { "Количество услуг и сумма лечения по отделениям", ;
      "Статистика по работе персонала в конкретном отделении", ;
      "Статистика по услугам, оказанным в конкретном отделении", ;
      "Статистика по работе персонала (плюс оказанные услуги) в конкретном отделении", ;
      "Статистика по оказанной услуге (плюс больные) в конкретном отделении", ;
      "Статистика по работе 1 человека (плюс больные) в конкретном отделении", ;
      "Статистика по работе персонала во многих отделениях", ;
      "Список больных с суммами лечения в каждом из отделений" }
    mas_fun := { "Pob1_statist(21)", ;
      "Pob1_statist(22)", ;
      "Pob1_statist(23)", ;
      "Pob1_statist(24)", ;
      "Pob1_statist(25)", ;
      "Pob1_statist(26)", ;
      "Pob1_statist(27)", ;
      "Pob1_statist(28)" }
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 12  // службы
    mas_pmt := { "Службы + ~отделения", ;
      "Службы + ~услуги", ;
      "Служб~а + услуги" }
    mas_msg := { "Количество услуг и сумма лечения по службам (с разбивкой по отделениям)", ;
      "Статистика по оказанным услугам (с объединением по службам)", ;
      "Статистика по оказанным услугам (по конкретной службе)" }
    mas_fun := { "Pob1_statist(31)", ;
      "Pob1_statist(32)", ;
      "Pob1_statist(33)" }
    popup_prompt( T_ROW, T_COL -5, si3, mas_pmt, mas_msg, mas_fun )
  Case k == 13  // персонал
    mas_pmt := { "1 человек + ~услуги", ;
      "~1 человек + услуги + больные", ;
      "~Весь персонал", ;
      "~Список персонала + услуги", ;
      "~Больные + персонал" }
    mas_msg := { "Статистика по работе конкретного работающего (плюс оказанные услуги)", ;
      "Статистика по работе конкретного работающего (плюс услуги плюс больные)", ;
      "Количество услуг и сумма лечения по всему списку работающих", ;
      "Статистика по работе некоторых работающих (плюс оказанные услуги)", ;
      "Список больных с разбивкой сумм лечения по каждому врачу (м/сестре, санитарке)" }
    mas_fun := { "Pob1_statist(41)", ;
      "Pob1_statist(42)", ;
      "Pob1_statist(43)", ;
      "Pob1_statist(44)", ;
      "Pob1_statist(45)" }
    If is_oplata != 7
      AAdd( mas_pmt, "~Медсестры" )
      AAdd( mas_pmt, "С~анитарки" )
      AAdd( mas_msg, "Список медсестер с заработанными суммами" )
      AAdd( mas_msg, "Список санитарок с заработанными суммами" )
      AAdd( mas_fun, "Pob1_statist(46)" )
      AAdd( mas_fun, "Pob1_statist(47)" )
    Endif
    popup_prompt( T_ROW, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
  Case k == 14  // услуги
    mas_pmt := { "~Список услуг", ;
      "Все ~услуги", ;
      "Список услуг+~больные" }
    mas_msg := { "Статистика по оказанию конкретных услуг (независимо от отделения)", ;
      "Статистика по оказанию всех услуг (независимо от отделения)", ;
      "Статистика по оказанию конкретных услуг [с больными] (независимо от отделения)" }
    mas_fun := { "Pob1_statist(51)", ;
      "Pob1_statist(52)", ;
      "Pob1_statist(53)" }
    popup_prompt( T_ROW, T_COL -5, si5, mas_pmt, mas_msg, mas_fun )
    // ** отделения
  Case k == 21    // список отделений
    pob2_statist( 1 )
  Case k == 22    // отделение + персонал
    pob2_statist( 2 )
  Case k == 23    // отделение + услуги
    pob2_statist( 3 )
  Case k == 24    // отделение + персонал + услуги
    pob2_statist( 4 )
  Case k == 25    // отделение + услуга + больные
    pob2_statist( 8 )
  Case k == 26    // отделение + персонал + больные
    pob2_statist( 9 )
  Case k == 27    // Список больных с суммами лечения в каждом из отделений
    st1_plat_fio()
  Case k == 28    // Список больных с суммами лечения в каждом из отделений
    st_plat_fio( 1 )
    // ** службы
  Case k == 31    // службы + отделения
    pob2_statist( 0 )
  Case k == 32    // службы + услуги
    pob2_statist( 10 )
  Case k == 33    // служба + услуги
    fl := .f.
    g_use( dir_server() + "slugba", dir_server() + "slugba", "SL" )
    If si_slugba == NIL
      Go Top
    Else
      find ( Str( si_slugba, 3 ) )
    Endif
    If alpha_browse( T_ROW, T_COL -5, MaxRow() -2, T_COL + 45, "f2spr_other", color0 )
      fl := .t. ; si_slugba := sl->shifr
      j := { sl->shifr, lstr( sl->shifr ) + ". " + AllTrim( sl->name ) }
    Endif
    sl->( dbCloseArea() )
    If fl
      pob2_statist( 11, j )
    Endif
    // ** персонал
  Case k == 41    // конкретный работающий + услуги
    pob2_statist( 5 )
  Case k == 42    // конкретный работающий + услуги + больные
    If ( j := popup_prompt( T_ROW, T_COL -5, si5, ;
        { "Все ~услуги", "~Список услуг" } ) ) > 0
      pob2_statist( 13,, ( j == 1 ) )
    Endif
  Case k == 43    // список персонала с объемом работ
    pob2_statist( 7 )
  Case k == 44    // список работающих + услуги
    pob2_statist( 5, { 1 } )
  Case k == 45    // Список больных с разбивкой сумм лечения по каждому врачу (м/сестре, санитарке)
    st_plat_fio( 2 )
  Case k == 46    // Список медсестер с заработанными суммами
    st_plat_ms( 1 )
  Case k == 47    // Список санитарок с заработанными суммами
    st_plat_ms( 2 )
    // ** услуги
  Case k == 51    // список услуг
    pob2_statist( 6 )
  Case k == 52    // все услуги
    pob2_statist( 12 )
  Case k == 53    // список услуг + больные
    pob2_statist( 14 )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Elseif Between( k, 31, 39 )
      si3 := j
    Elseif Between( k, 41, 49 )
      si4 := j
    Elseif Between( k, 51, 59 )
      si5 := j
    Endif
  Endif

  Return Nil

// 01.03.19
Function pob2_statist( k, serv_arr, is_all )

  Local i, j, arr[ 2 ], begin_date, end_date, bk := 1, ek := 99, al, ;
    fl_exit := .f., sh := 80, HH := 57, regim := 2, s, fl_1_list := .t., ;
    len_n, pkol, ptrud, pstoim, old_perso, old_usl, ;
    old_fio, arr_otd := {}, md, mkol, mstoim, arr_kd := {}, len_kd := 0, ;
    xx, yy, lrec, t_date1, t_date2, arr_title, msum, msum_opl, ;
    musluga, mperso, mkod_perso, arr_usl := {}, adbf1, adbf2, ;
    arr_svod_nom := {}, ssumv_ysl := 0, ssumv_sum := 0, ssumv_uet := 0, ;
    ssuma_ysl := 0, ssuma_sum := 0, ssuma_uet := 0

  Default is_all To .t.
  Private skol := { 0, 0 }, strud := { 0, 0 }, sstoim := { 0, 0 }, krvz, arr_dms
  If equalany( k, 2, 3, 4, 8, 9 )  // по отделению
    If ( st_a_otd := inputn_otd( T_ROW, T_COL -5, .f., .f. ) ) == NIL
      Return Nil
    Endif
    AEval( st_a_otd, {| x| AAdd( arr_otd, x ) } )
    If k == 8 .and. ( musluga := input_usluga() ) == NIL
      Return Nil
    Endif
    If k == 9 .and. !input_perso( T_ROW, T_COL -5, .f. )
      Return Nil
    Endif
  Else  // по учреждению(ям)
    If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) == NIL
      Return Nil
    Endif
    r_use( dir_server() + "mo_otd",, "OTD" )
    dbEval( {|| AAdd( arr_otd, { otd->( RecNo() ), otd->name, otd->kod_lpu } ) }, ;
      {|| f_is_uch( st_a_uch, otd->kod_lpu ) } )
    OTD->( dbCloseArea() )
    If Len( st_a_uch ) > 1
      g_use( dir_server() + "mo_uch",, "UCH" )
      For i := 1 To Len( arr_otd )
        Goto ( arr_otd[ i, 3 ] )
        arr_otd[ i, 2 ] := "[" + AllTrim( uch->name ) + "] " + AllTrim( arr_otd[ i, 2 ] )
      Next
      uch->( dbCloseArea() )
    Endif
    If ( ( k == 5 .and. serv_arr == NIL ) .or. k == 13 ) .and. !input_perso( T_ROW, T_COL -5, .f. )
      Return Nil
    Endif
  Endif
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  begin_date := arr[ 7 ]
  end_date := arr[ 8 ]
  If k == 5 .and. serv_arr != Nil .and. ( mperso := input_kperso() ) == NIL
    mywait()
    mperso := {}
    r_use( dir_server() + "mo_pers",, "PERSO" )
    Go Top
    Do While !Eof()
      If perso->kod > 0
        AAdd( mperso, { perso->kod, "" } )
      Endif
      Skip
    Enddo
    perso->( dbCloseArea() )
  Endif
  If ( krvz := fbp_tip_usl( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  If pi1 == 1  // по дате лечения
 /* G_Use(dir_server()+"mo_otd",,"OTD")
  dbeval({|| if(otd->usluga > 0 .and. ascan(arr_kd,otd->usluga) == 0, ;
                   aadd(arr_kd,otd->usluga), NIL),;
             if(otd->usluga_d > 0 .and. ascan(arr_kd,otd->usluga_d) == 0, ;
                   aadd(arr_kd,otd->usluga_d), NIL);
         },;
         {|| f_is_uch(st_a_uch,otd->kod_lpu)} )
  OTD->(dbCloseArea())
  len_kd := len(arr_kd)
  */
  Endif
  adbf1 := { ;
    { "U_KOD",    "N",      4,      0 }, ;  // код услуги
    { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
    { "U_NAME",     "C",     65,      0 }, ;  // наименование услуги
    { "FIO",        "C",     25,      0 }, ;  // ФИО больного
    { "KOD",        "N",      7,      0 }, ;  // код больного
    { "K_DATA",     "D",      8,      0 }, ;  // дата окончания лечения
    { "KOL",    "N",      5,      0 }, ;  // количество услуг
    { "STOIM",      "N",     20,      4 };   // стоимость услуг
    }
  adbf2 := { ;
    { "otd",        "N",      3,      0 }, ;  // отделение, где оказана услуга
    { "U_KOD",    "N",      4,      0 }, ;  // код услуги
    { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
    { "U_NAME",     "C",     65,      0 }, ;  // наименование услуги
    { "VR_AS",      "N",      1,      0 }, ;  // врач - 1 ; ассистент - 2
    { "TAB_NOM",    "N",      5,      0 }, ;  // таб.номер врача (ассистента)
    { "SVOD_NOM",   "N",      5,      0 }, ;  // сводный таб.номер
    { "KOD_VR",     "N",      4,      0 }, ;  // код врача
    { "FIO",        "C",     50,      0 }, ;  // Ф.И.О. врача
    { "TRUDOEM",    "N",     11,      4 }, ;  // трудоемкость услуг УЕТ
    { "KOL",    "N",      6,      0 }, ;  // количество услуг
    { "STOIM",    "N",     16,      4 };   // итоговая стоимость услуги
    }
  If k == 13 .and. !is_all
    dbCreate( cur_dir() + "tmp", adbf2 )
    Use ( cur_dir() + "tmp" )
    Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
    Close databases
    ob2_v_usl()
    Use ( cur_dir() + "tmp" )
    dbEval( {|| AAdd( arr_usl, tmp->u_kod ) } )
    Use
    If Len( arr_usl ) == 0
      Return Nil
    Endif
  Endif
  If equalany( k, 8, 9, 13, 14 )  // вывод списка больных
    dbCreate( cur_dir() + "tmp", adbf1 )
  Else
    dbCreate( cur_dir() + "tmp", adbf2 )
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  Use ( cur_dir() + "tmp" )
  Do Case
  Case k == 0  // Количество услуг и сумма лечения по службам (с разбивкой по отделениям)
    Index On Str( kod_vr, 4 ) + Str( otd, 3 ) to ( cur_dir() + "tmpk" )
    Index On Str( kod_vr, 4 ) + Upper( Left( u_name, 20 ) ) to ( cur_dir() + "tmpn" )
  Case k == 1  // Количество услуг и сумма лечения по отделениям
    Index On Str( otd, 3 ) to ( cur_dir() + "tmpk" )
    Index On fio to ( cur_dir() + "tmpn" )
  Case k == 2  // Статистика по работе персонала в конкретном отделении
    Index On Str( vr_as, 1 ) + Str( kod_vr, 4 ) to ( cur_dir() + "tmpk" )
    Index On Upper( Left( fio, 30 ) ) + Str( kod_vr, 4 ) + Str( vr_as, 1 ) to ( cur_dir() + "tmpn" )
  Case k == 3  // Статистика по услугам, оказанным в конкретном отделении
    Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
  Case k == 4  // Статистика по работе персонала (плюс оказанные услуги) в конкретном отделении
    Index On Str( vr_as, 1 ) + Str( kod_vr, 4 ) + Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
    Index On Upper( Left( fio, 30 ) ) + Str( kod_vr, 4 ) + Str( vr_as, 1 ) + fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
  Case k == 5  // Статистика по работе конкретного человека (плюс оказанные услуги)
    Index On Str( vr_as, 1 ) + Str( kod_vr, 4 ) + Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
    If serv_arr == NIL
      Index On Str( vr_as, 1 ) + fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
    Else
      Index On Upper( Left( fio, 30 ) ) + Str( kod_vr, 4 ) + Str( vr_as, 1 ) + fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
    Endif
  Case k == 6  // Статистика по конкретным услугам
    Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
    Close databases
    ob2_v_usl()
  Case k == 7  // Статистика по работе всего персонала
    Index On Str( vr_as, 1 ) + Str( kod_vr, 4 ) to ( cur_dir() + "tmpk" )
    Index On Upper( Left( fio, 30 ) ) + Str( kod_vr, 4 ) + Str( vr_as, 1 ) to ( cur_dir() + "tmpn" )
  Case equalany( k, 8, 9 )  // вывод списка больных
    Index On Str( kod, 7 ) to ( cur_dir() + "tmpk" )
    Index On DToS( k_data ) + Upper( Left( fio, 30 ) ) to ( cur_dir() + "tmpn" )
  Case k == 10 // Статистика по услугам по всем службам
    Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
    Index On Str( kod_vr, 4 ) + fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
  Case k == 11 // Статистика по услугам конкретной службы
    Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
  Case k == 12 // Статистика по всем услугам
    Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
  Case k == 13  // вывод услуг + списка больных
    Index On Str( u_kod, 4 ) + Str( kod, 7 ) to ( cur_dir() + "tmpk" )
    Index On fsort_usl( u_shifr ) + Str( u_kod, 4 ) + DToS( k_data ) + Upper( Left( fio, 30 ) ) to ( cur_dir() + "tmpn" )
  Case k == 14  // Статистика по конкретным услугам + список больных
    Index On Str( u_kod, 4 ) + Str( kod, 7 ) to ( cur_dir() + "tmpk" )
    Index On fsort_usl( u_shifr ) + Str( u_kod, 4 ) + DToS( k_data ) + Upper( Left( fio, 30 ) ) to ( cur_dir() + "tmpn" )
    Close databases
    ob2_v_usl()
  Endcase
  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmpk" ), ( cur_dir() + "tmpn" ) Alias TMP
  If mem_trudoem == 2
    useuch_usl()
  Endif
  // G_Use(dir_server()+"cena_usl",dir_server()+"cena_usl","CENA")
  g_use( dir_server() + "kartotek",, "KART" )
  g_use( dir_server() + "uslugi",, "USL" )
  Private is_1_usluga := ( Len( arr_usl ) == 1 )
  If psz == 2 .and. eq_any( is_oplata, 5, 6, 7 )
    open_opl_5()
    If is_oplata == 7
      cre_tmp7()
    Endif
  Endif
  r_use( dir_server() + "mo_pers",, "PERSO" )
  If equalany( k, 5, 9, 13 )  // Статистика по работе конкретного врача/ассистента
    If serv_arr == NIL
      mperso := { glob_human }
    Endif
    g_use( dir_server() + "hum_p",, "HUMAN" )
    g_use( dir_server() + "hum_p_u", { dir_server() + "hum_p_uv", ;
      dir_server() + "hum_p_ua", ;
      dir_server() + "hum_p_u" }, "HU" )
    If pi1 == 3  // по дате закрытия листа учета
      Select HU
      Set Index to ( dir_server() + "hum_p_u" )
      Select HUMAN
      Set Index to ( dir_server() + "hum_pc" )
      For xx := 0 To 2
        If AScan( krvz, xx ) > 0
          Select HUMAN
          dbSeek( Str( xx, 1 ) + "1" + DToS( arr[ 5 ] ), .t. )
          Do While human->tip_usl == xx .and. human->date_close <= arr[ 6 ] .and. !Eof()
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t. ; Exit
            Endif
            Select HU
            find ( Str( human->( RecNo() ), 7 ) )
            Do While hu->kod == human->( RecNo() )
              For yy := 1 To 2
                pole_va := { "hu->kod_vr", "hu->kod_as" }[ yy ]
                mkod_perso := &pole_va
                If AScan( mperso, {| x| x[ 1 ] == mkod_perso } ) > 0
                  If k == 5
                    pob3_statist( k, arr_otd, serv_arr, mkod_perso )
                  Elseif equalany( k, 9, 13 ) .and. ;
                      if( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                    pob5_statist( k, arr_otd, serv_arr, mkod_perso )
                  Endif
                Endif
              Next
              Select HU
              Skip
            Enddo
            Select HUMAN
            Skip
          Enddo
        Endif
        If fl_exit ; exit ; Endif
      Next
    Else
      For yy := 1 To Len( mperso )
        mkod_perso := mperso[ yy, 1 ]
        Select HU
        For xx := 1 To 2
          pole_va := { "hu->kod_vr", "hu->kod_as" }[ xx ]
          Select HU
          If xx == 1
            Set Order To 1
          Elseif xx == 2
            Set Order To 2
          Endif
          Do Case
          Case pi1 == 1  // по дате лечения
            If len_kd > 0  // если есть услуги "Койко-день" для работающих отделений
              // сначала проверим койко-дни за 60 дней до начальной даты
              dbSeek( Str( mkod_perso, 4 ) + dtoc4( arr[ 5 ] -60 ), .t. )
              Do while &pole_va == mkod_perso .and. hu->date_u < begin_date
                updatestatus()
                If Inkey() == K_ESC
                  fl_exit := .t. ; Exit
                Endif
                If AScan( arr_kd, hu->u_kod ) > 0 .and. hu->kol > 0 .and. ;
                    ( i := AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) ) > 0 .and. ;
                    ( md := c4tod( hu->date_u ) + hu->kol - 1 ) >= arr[ 5 ]
                  human->( dbGoto( hu->kod ) )
                  If k == 5
                    // если дата окончания койко-дней >= begin_date
                    md := Min( md, arr[ 6 ] )
                    mkol := md - arr[ 5 ] + 1
                    mstoim := round_5( hu->stoim / hu->kol * mkol, 2 )
                    pob4_statist( k, arr_otd, i, mkol, mstoim, serv_arr, mkod_perso )
                  Elseif equalany( k, 9, 13 ) .and. ;
                      if( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                    pob5_statist( k, , serv_arr, mkod_perso )
                  Endif
                Endif
                Select HU
                Skip
              Enddo
            Endif
            If !fl_exit
              Select HU
              dbSeek( Str( mkod_perso, 4 ) + begin_date, .t. )
              Do while &pole_va == mkod_perso .and. hu->date_u <= end_date
                updatestatus()
                If Inkey() == K_ESC
                  fl_exit := .t. ; Exit
                Endif
                human->( dbGoto( hu->kod ) )
                If len_kd > 0 .and. AScan( arr_kd, hu->u_kod ) > 0  // койко-день
                  If hu->kol > 0 .and. ( i := AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) ) > 0
                    If ( md := c4tod( hu->date_u ) ) + hu->kol - 1 > arr[ 6 ]
                      // если кол-во койко-дней выходит за конечную дату
                      mkol := arr[ 6 ] - md + 1
                      mstoim := round_5( hu->stoim / hu->kol * mkol, 2 )
                    Else  // если кол-во койко-дней умещается в диапазоне дат
                      mkol := hu->kol
                      mstoim := hu->stoim
                    Endif
                    If k == 5
                      pob4_statist( k, arr_otd, i, mkol, mstoim, serv_arr, mkod_perso )
                    Elseif equalany( k, 9, 13 ) .and. ;
                        if( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                      pob5_statist( k, , serv_arr, mkod_perso )
                    Endif
                  Endif
                Else
                  If k == 5
                    pob3_statist( k, arr_otd, serv_arr, mkod_perso )
                  Elseif equalany( k, 9, 13 ) .and. ;
                      if( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                    pob5_statist( k, arr_otd, serv_arr, mkod_perso )
                  Endif
                Endif
                Select HU
                Skip
              Enddo
            Endif
          Case pi1 == 2  // по дате окончания лечения
            Select HU                      // на всякий случай отнимем 5 мес.
            dbSeek( Str( mkod_perso, 4 ) + dtoc4( arr[ 5 ] -160 ), .t. )
            Do while &pole_va == mkod_perso .and. hu->date_u <= end_date
              updatestatus()
              If Inkey() == K_ESC
                fl_exit := .t. ; Exit
              Endif
              Select HUMAN
              Goto ( hu->kod )
              If Between( human->k_data, arr[ 5 ], arr[ 6 ] )
                If k == 5
                  pob3_statist( k, arr_otd, serv_arr, mkod_perso )
                Elseif equalany( k, 9, 13 ) .and. ;
                    if( is_all, .t., AScan( arr_usl, hu->u_kod ) > 0 )
                  pob5_statist( k, arr_otd, serv_arr, mkod_perso )
                Endif
              Endif
              Select HU
              Skip
            Enddo
          Endcase
        Next
        If fl_exit ; exit ; Endif
      Next
    Endif
  Elseif equalany( k, 6, 8, 14 )  // Статистика по конкретным(ой) услугам(е)
    If equalany( k, 6, 14 )
      Select TMP  // в базе данных уже занесены необходимые нам услуги
      // переносим их в массив arr_usl
      dbEval( {|| AAdd( arr_usl, { tmp->u_kod, tmp->( RecNo() ) } ) } )
      If k == 14
        Zap
      Endif
    Elseif k == 8
      arr_usl := { { musluga[ 1 ], 0 } }
    Endif
    is_1_usluga := ( Len( arr_usl ) == 1 )
    t_date1 := dtoc4( arr[ 5 ] -60 )
    t_date2 := dtoc4( arr[ 5 ] -1 )
    g_use( dir_server() + "hum_p",, "HUMAN" )
    g_use( dir_server() + "hum_p_u", { dir_server() + "hum_p_uk", ;
      dir_server() + "hum_p_u" }, "HU" )
    For xx := 1 To Len( arr_usl )
      If k == 6
        tmp->( dbGoto( arr_usl[ xx, 2 ] ) )
        lrec := tmp->( RecNo() )
      Endif
      Do Case
      Case pi1 == 1  // по дате лечения
        Select HU
        find ( Str( arr_usl[ xx, 1 ], 4 ) )
        Do While hu->u_kod == arr_usl[ xx, 1 ]
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          Select HUMAN
          Goto ( hu->kod )
          // сначала проверим койко-дни за 60 дней до начальной даты
          If len_kd > 0 .and. Between( hu->date_u, t_date1, t_date2 ) .and. ;
              AScan( arr_kd, hu->u_kod ) > 0 .and. hu->kol > 0 .and. ;
              ( i := AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) ) > 0 .and. ;
              ( md := c4tod( hu->date_u ) + hu->kol - 1 ) >= arr[ 5 ]
            If k == 6
              // если дата окончания койко-дней >= begin_date
              md := Min( md, arr[ 6 ] )
              mkol := md - arr[ 5 ] + 1
              mstoim := round_5( hu->stoim / hu->kol * mkol, 2 )
              pob4_statist( k, arr_otd, i, mkol, mstoim, serv_arr )
            Elseif equalany( k, 8, 14 )
              pob5_statist( k, , serv_arr )
            Endif
          Elseif Between( hu->date_u, begin_date, end_date )
            // если койко-день
            If len_kd > 0 .and. AScan( arr_kd, hu->u_kod ) > 0
              If hu->kol > 0 .and. ( i := AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) ) > 0
                If ( md := c4tod( hu->date_u ) ) + hu->kol - 1 > arr[ 6 ]
                  // если кол-во койко-дней выходит за конечную дату
                  mkol := arr[ 6 ] - md + 1
                  mstoim := round_5( hu->stoim / hu->kol * mkol, 2 )
                Else  // если кол-во койко-дней умещается в диапазоне дат
                  mkol := hu->kol
                  mstoim := hu->stoim
                Endif
                If k == 6
                  pob4_statist( k, arr_otd, i, mkol, mstoim, serv_arr )
                Elseif equalany( k, 8, 14 )
                  pob5_statist( k, , serv_arr )
                Endif
              Endif
            Else
              If k == 6
                pob3_statist( k, arr_otd, serv_arr )
              Elseif equalany( k, 8, 14 )
                pob5_statist( k, arr_otd, serv_arr )
              Endif
            Endif
          Endif
          Select HU
          Skip
        Enddo
      Case pi1 == 2  // по дате окончания лечения
        Select HU
        find ( Str( arr_usl[ xx, 1 ], 4 ) )
        Do While hu->u_kod == arr_usl[ xx, 1 ]
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          Select HUMAN
          Goto ( hu->kod )
          If Between( human->k_data, arr[ 5 ], arr[ 6 ] )
            If k == 6
              pob3_statist( k, arr_otd, serv_arr )
            Elseif equalany( k, 8, 14 )
              pob5_statist( k, arr_otd, serv_arr )
            Endif
          Endif
          Select HU
          Skip
        Enddo
      Case pi1 == 3  // по дате закрытия листа учета
        Select HU
        find ( Str( arr_usl[ xx, 1 ], 4 ) )
        Do While hu->u_kod == arr_usl[ xx, 1 ]
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          Select HUMAN
          Goto ( hu->kod )
          If !Empty( human->date_close ) .and. Between( human->date_close, arr[ 5 ], arr[ 6 ] )
            If k == 6
              pob3_statist( k, arr_otd, serv_arr )
            Elseif equalany( k, 8, 14 )
              pob5_statist( k, arr_otd, serv_arr )
            Endif
          Endif
          Select HU
          Skip
        Enddo
      Endcase
      If fl_exit ; exit ; Endif
    Next
  Else
    Do Case
    Case pi1 == 1  // по дате лечения
      g_use( dir_server() + "hum_p",, "HUMAN" )
      g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_ud", "HU" )
      Set Relation To kod into HUMAN
      If len_kd > 0  // если есть услуги "Койко-день" для работающих отделений
        // сначала проверим койко-дни за 60 дней до начальной даты
        dbSeek( dtoc4( arr[ 5 ] -60 ), .t. )
        Do While hu->date_u < begin_date .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          If AScan( arr_kd, hu->u_kod ) > 0 .and. hu->kol > 0 .and. ;
              ( i := AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) ) > 0 .and. ;
              ( md := c4tod( hu->date_u ) + hu->kol - 1 ) >= arr[ 5 ]
            // если дата окончания койко-дней >= begin_date
            md := Min( md, arr[ 6 ] )
            mkol := md - arr[ 5 ] + 1
            mstoim := round_5( hu->stoim / hu->kol * mkol, 2 )
            pob4_statist( k, arr_otd, i, mkol, mstoim, serv_arr )
          Endif
          Select HU
          Skip
        Enddo
      Endif
      If !fl_exit
        Select HU
        dbSeek( begin_date, .t. )
        Do While hu->date_u <= end_date .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          If len_kd > 0 .and. AScan( arr_kd, hu->u_kod ) > 0  // койко-день
            If hu->kol > 0 .and. ( i := AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) ) > 0
              If ( md := c4tod( hu->date_u ) ) + hu->kol - 1 > arr[ 6 ]
                // если кол-во койко-дней выходит за конечную дату
                mkol := arr[ 6 ] - md + 1
                mstoim := round_5( hu->stoim / hu->kol * mkol, 2 )
              Else  // если кол-во койко-дней умещается в диапазоне дат
                mkol := hu->kol
                mstoim := hu->stoim
              Endif
              pob4_statist( k, arr_otd, i, mkol, mstoim, serv_arr )
            Endif
          Else
            pob3_statist( k, arr_otd, serv_arr )
          Endif
          Select HU
          Skip
        Enddo
      Endif
    Case pi1 == 2  // по дате окончания лечения
      g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
      g_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUMAN" )
      dbSeek( DToS( arr[ 5 ] ), .t. )
      Do While human->k_data <= arr[ 6 ] .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select HU
        find ( Str( human->( RecNo() ), 7 ) )
        Do While hu->kod == human->( RecNo() )
          pob3_statist( k, arr_otd, serv_arr )
          Select HU
          Skip
        Enddo
        Select HUMAN
        Skip
      Enddo
    Case pi1 == 3  // по дате закрытия листа учета
      g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
      g_use( dir_server() + "hum_p", dir_server() + "hum_pc", "HUMAN" )
      For xx := 0 To 2
        If AScan( krvz, xx ) > 0
          Select HUMAN
          dbSeek( Str( xx, 1 ) + "1" + DToS( arr[ 5 ] ), .t. )
          Do While human->tip_usl == xx .and. human->date_close <= arr[ 6 ] .and. !Eof()
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t. ; Exit
            Endif
            Select HU
            find ( Str( human->( RecNo() ), 7 ) )
            Do While hu->kod == human->( RecNo() )
              pob3_statist( k, arr_otd, serv_arr )
              Select HU
              Skip
            Enddo
            Select HUMAN
            Skip
          Enddo
        Endif
        If fl_exit ; exit ; Endif
      Next
    Endcase
  Endif
  j := tmp->( LastRec() )
  Close databases
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    If equalany( k, 8, 9, 13, 14 )
      arr_title := { ;
        "─────────────────────────┬─────┬────────┬───────────────", ;
        "                         │Отде-│  Дата  │               ", ;
        "         Ф.И.О.          │ление│окон.леч│ Сумма лечения ", ;
        "─────────────────────────┴─────┴────────┴───────────────" }
      g_use( dir_server() + "mo_otd",, "OTD" )
      g_use( dir_server() + "hum_p",, "HUMAN" )
      Set Relation To otd into OTD
    Else
      len_n := 58
      If mem_trudoem == 2
        len_n := 49
      Endif
      arr_title := Array( 4 )
      arr_title[ 1 ] := Replicate( "─", len_n )
      arr_title[ 2 ] := Space( len_n )
      arr_title[ 3 ] := Space( len_n )
      arr_title[ 4 ] := Replicate( "─", len_n )
      arr_title[ 1 ] += "┬──────"
      arr_title[ 2 ] += "│Кол-во"
      arr_title[ 3 ] += "│ услуг"
      arr_title[ 4 ] += "┴──────"
      If mem_trudoem == 2
        arr_title[ 1 ] += "┬────────"
        arr_title[ 2 ] += "│        "
        arr_title[ 3 ] += "│ У.Е.Т. "
        arr_title[ 4 ] += "┴────────"
      Endif
      arr_title[ 1 ] += "┬──────────────"
      arr_title[ 2 ] += "│" + PadC( if( psz == 1, "Стоимость", "Заработная" ), 14 )
      arr_title[ 3 ] += "│" + PadC( if( psz == 1, "услуг", "плата" ), 14 )
      arr_title[ 4 ] += "┴──────────────"
    Endif
    sh := Len( arr_title[ 1 ] )
    Set( _SET_DELETED, .f. )
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmpk" ), ( cur_dir() + "tmpn" ) New Alias TMP
    If !equalany( k, 1, 8, 9 )
      If equalany( k, 0, 10 )
        r_use( dir_server() + "slugba", dir_server() + "slugba", "SL" )
      Endif
      If Between( k, 3, 6 ) .or. Between( k, 10, 14 )
        r_use( dir_server() + "uslugi",, "USL" )
      Endif
      r_use( dir_server() + "mo_pers",, "PERSO" )
      Select TMP
      Set Order To 0
      Go Top
      Do While !Eof()
        If equalany( k, 0, 10 )
          Select SL
          find ( Str( tmp->kod_vr, 3 ) )
          If Found() .and. !Deleted()
            tmp->fio := Str( sl->shifr, 3 ) + ". " + sl->name
          Else
            Select TMP
            Delete
          Endif
        Endif
        If Between( k, 3, 6 ) .or. Between( k, 10, 14 )
          Select USL
          Goto ( tmp->u_kod )
          If usl->kod <= 0 .or. Deleted() .or. Eof()
            Select TMP
            Delete
          Else
            tmp->u_shifr := usl->shifr
            If glob_mo[ _MO_KOD_TFOMS ] == '171004' // КБ-4
              tmp->u_name := usl->full_name
            Else
              tmp->u_name := usl->name
            Endif
          Endif
        Endif
        If equalany( k, 2, 4, 5, 7 )
          Select PERSO
          Goto ( tmp->kod_vr )
          If Deleted() .or. Eof()
            Select TMP
            Delete
          Else
            tmp->fio := perso->fio
            tmp->tab_nom := perso->tab_nom
            tmp->svod_nom := iif( Empty( perso->svod_nom ), perso->tab_nom, perso->svod_nom )  // ЮРА
            If k == 7
              If ( i := AScan( arr_svod_nom, ;
                  {| x| x[ 1 ] == iif( Empty( perso->svod_nom ), perso->tab_nom, perso->svod_nom );
                  .and. x[ 2 ] == tmp->vr_as } ) ) == 0 // ЮРА
                AAdd( arr_svod_nom, { perso->svod_nom, tmp->vr_as, {} } )
                i := Len( arr_svod_nom )
              Endif
              AAdd( arr_svod_nom[ i, 3 ], tmp->( RecNo() ) )
              tmp->u_shifr := lstr( iif( Empty( perso->svod_nom ), perso->tab_nom, perso->svod_nom ) )// ЮРА
            Endif
          Endif
        Endif
        Select TMP
        Skip
      Enddo
      If k == 7 .and. Len( arr_svod_nom ) > 0
        Select TMP
        For i := 1 To Len( arr_svod_nom )
          pkol := ptrud := pstoim := 0
          For j := 2 To Len( arr_svod_nom[ i, 3 ] )
            Goto ( arr_svod_nom[ i, 3, j ] )
            ptrud  += tmp->TRUDOEM
            pkol   += tmp->KOL
            pstoim += tmp->STOIM
            Delete
          Next
          Goto ( arr_svod_nom[ i, 3, 1 ] )
          tmp->TRUDOEM += ptrud
          tmp->KOL     += pkol
          tmp->STOIM   += pstoim
        Next
      Endif
      If equalany( k, 2, 4, 5, 7 )
        perso->( dbCloseArea() )
      Endif
    Endif
    Set( _SET_DELETED, .t. )
    fp := FCreate( cur_dir() + "ob_stat.txt" ) ; tek_stroke := 0 ; n_list := 1
    add_string( "ПЛАТНЫЕ УСЛУГИ" )
    If k == 0
      add_string( Center( "Статистика по службам (с разбивкой по отделениям)", sh ) )
      titlen_uch( st_a_uch, sh )
    Elseif k == 1
      add_string( Center( "Статистика по отделениям", sh ) )
      titlen_uch( st_a_uch, sh )
    Elseif k == 5
      add_string( Center( "Статистика по оказанным услугам", sh ) )
      If serv_arr == Nil  // по одному человеку
        add_string( Center( '"' + Upper( glob_human[ 2 ] ) + ;
          ' [' + lstr( glob_human[ 5 ] ) + ']"', sh ) )
      Endif
    Elseif equalany( k, 6, 14 )
      add_string( Center( "Статистика по услугам", sh ) )
      titlen_uch( st_a_uch, sh )
    Elseif k == 7
      add_string( Center( "Статистика по работе персонала", sh ) )
      titlen_uch( st_a_uch, sh )
    Elseif k == 10
      add_string( Center( "Статистика по услугам (с объединением по службам)", sh ) )
      titlen_uch( st_a_uch, sh )
    Elseif k == 11
      add_string( Center( "Статистика по службе", sh ) )
      add_string( Center( serv_arr[ 2 ], sh ) )
      titlen_uch( st_a_uch, sh )
    Elseif k == 12
      add_string( Center( "Статистика по всем оказанным услугам", sh ) )
      titlen_uch( st_a_uch, sh )
    Elseif k == 13
      add_string( Center( "Список больных, которым были оказаны услуги врачом (ассистентом):", sh ) )
      add_string( Center( '"' + Upper( glob_human[ 2 ] ) + ;
        ' [' + lstr( glob_human[ 5 ] ) + ']"', sh ) )
    Else
      add_string( Center( "Статистика по отделению", sh ) )
      titlen_otd( st_a_otd, sh )
      add_string( Center( "< " + AllTrim( glob_uch[ 2 ] ) + " >", sh ) )
      If equalany( k, 8, 9 )
        add_string( "" )
        If k == 8
          add_string( Center( "Список больных, которым была оказана услуга:", sh ) )
          add_string( Center( '"' + musluga[ 2 ] + '"', sh ) )
        Else
          add_string( Center( "Список больных, которым были оказаны услуги врачом (ассистентом):", sh ) )
          add_string( Center( '"' + Upper( glob_human[ 2 ] ) + ;
            ' [' + lstr( glob_human[ 5 ] ) + ']"', sh ) )
        Endif
      Endif
    Endif
    tit_tip_usl( krvz, arr_dms, sh )
    add_string( Center( arr[ 4 ], sh ) )
    add_string( "" )
    Do Case
    Case pi1 == 1
      s := "[ по дате лечения ]"
    Case pi1 == 2
      s := "[ по дате окончания лечения ]"
    Case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
    Endcase
    add_string( Center( s, sh ) )
    add_string( "" )
    Select TMP
    Set Order To 2
    Go Top
    If equalany( k, 8, 9, 13, 14 )
      mb := mkol := msum := old_usl := 0
      AEval( arr_title, {| x| add_string( x ) } )
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        If equalany( k, 13, 14 ) .and. tmp->u_kod != old_usl
          If old_usl > 0
            add_string( Replicate( "─", sh ) )
            add_string( PadR( "Кол-во больных - " + lstr( mb ), 28 ) + ;
              PadL( expand_value( msum, 2 ), 13 ) + " руб." )
            add_string( PadL( "Кол-во услуг - " + lstr( mkol ), 30 ) )
            mb := mkol := msum := 0
          Endif
          add_string( "" )
          add_string( "│ " + RTrim( tmp->u_shifr ) + ". " + RTrim( tmp->u_name ) )
          add_string( "└" + Replicate( "─", 24 ) )
        Endif
        old_usl := tmp->u_kod
        Select HUMAN
        Goto ( tmp->kod )
        s := tmp->fio + " " + otd->short_name + " " + date_8( tmp->k_data ) + ;
          PadL( expand_value( tmp->stoim, 2 ), 16 )
        add_string( s )
        mkol += tmp->kol ; msum += tmp->stoim ; ++mb
        Select TMP
        Skip
      Enddo
      add_string( Replicate( "─", sh ) )
      add_string( PadR( "Кол-во больных - " + lstr( mb ), 28 ) + ;
        PadL( expand_value( msum, 2 ), 13 ) + " руб." )
      add_string( PadL( "Кол-во услуг - " + lstr( mkol ), 30 ) )
    Else
      pkol := ptrud := pstoim := 0

      old_perso := tmp->kod_vr ; old_vr_as := tmp->vr_as
      // old_fio := ""
      old_fio := "[" + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + "] "
      old_fio += tmp->fio
      old_slugba := tmp->fio ; old_shifr := tmp->kod_vr
      If equalany( k, 2, 5, 7 )
        old_perso := -1  // для печати Ф.И.О. в начале
      Endif
      Select TMP
      Do While !Eof()
        If equalany( k, 0, 10 ) .and. old_shifr != tmp->kod_vr
          add_string( Space( 4 ) + Replicate( ".", sh -4 ) )
          add_string( PadR( Space( 4 ) + old_slugba, len_n ) + ;
            Str( pkol, 7, 0 ) + ;
            if( mem_trudoem == 2, put_val_0( ptrud, 9, 1 ), "" ) + ;
            put_kope( pstoim, 15 ) )
          add_string( Replicate( "─", sh ) )
          pkol := ptrud := pstoim := 0
        Endif
        If k == 4 .and. !( old_perso == tmp->kod_vr .and. old_vr_as == tmp->vr_as )
          add_string( Space( 4 ) + Replicate( ".", sh -4 ) )
          add_string( PadR( Space( 4 ) + old_fio, len_n -4 ) + ;
            if( psz == 1, if( old_vr_as == 1, "врач", "асс." ), Space( 4 ) ) + ;
            Str( pkol, 7, 0 ) + ;
            if( mem_trudoem == 2, put_val_0( ptrud, 9, 1 ), "" ) + ;
            put_kope( pstoim, 15 ) )
          add_string( Replicate( "─", sh ) )
          pkol := ptrud := pstoim := 0
        Endif
        If fl_1_list .or. verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
          fl_1_list := .f.
        Endif
        If k == 4
          pkol += tmp->kol
          ptrud += tmp->trudoem
          pstoim += tmp->stoim
          skol[ tmp->vr_as ] += tmp->kol
          strud[ tmp->vr_as ] += tmp->trudoem
          sstoim[ tmp->vr_as ] += tmp->stoim
          j := perenos( arr, tmp->u_shifr + " " + tmp->u_name, len_n )
          add_string( PadR( arr[ 1 ], len_n ) + ;
            Str( tmp->kol, 7, 0 ) + ;
            if( mem_trudoem == 2, put_val_0( tmp->trudoem, 9, 1 ), "" ) + ;
            put_kope( tmp->stoim, 15 ) )
          For i := 2 To j
            add_string( Space( 11 ) + arr[ i ] )
          Next
          old_perso := tmp->kod_vr
          old_vr_as := tmp->vr_as
          old_fio := "[" + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + "] "
          old_fio += tmp->fio
        Else
          Do Case
          Case k == 0
            s := PadR( tmp->u_name, len_n )
            skol[ 1 ] += tmp->kol
            strud[ 1 ] += tmp->trudoem
            sstoim[ 1 ] += tmp->stoim
            pkol += tmp->kol
            ptrud += tmp->trudoem
            pstoim += tmp->stoim
            old_slugba := tmp->fio ; old_shifr := tmp->kod_vr
          Case k == 1
            s := PadR( tmp->fio, len_n )
            skol[ 1 ] += tmp->kol
            strud[ 1 ] += tmp->trudoem
            sstoim[ 1 ] += tmp->stoim
          Case equalany( k, 2, 7 )
            s := ""
            If old_perso != tmp->kod_vr
              If !Empty( tmp->tab_nom )
                If AllTrim( tmp->u_shifr ) == lstr( tmp->tab_nom )
                  s := "[" + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + "]"
                  If Len( s ) < 8
                    s := PadR( s, 8 )
                  Endif
                Else
                  s := PadR( "[+" + AllTrim( tmp->u_shifr ) + "]", 8 )
                Endif
              Endif
              s += tmp->fio
            Endif
            s := PadR( s, len_n -5 ) + " " + ;
              if( psz == 1, if( tmp->vr_as == 1, "врач", "асс." ), Space( 4 ) )
            skol[ tmp->vr_as ] += tmp->kol
            strud[ tmp->vr_as ] += tmp->trudoem
            sstoim[ tmp->vr_as ] += tmp->stoim
            old_perso := tmp->kod_vr
          Case equalany( k, 3, 6, 10, 11, 12 )
            j := perenos( arr, tmp->u_shifr + " " + tmp->u_name, len_n )
            s := PadR( arr[ 1 ], len_n )
            skol[ 1 ] += tmp->kol
            strud[ 1 ] += tmp->trudoem
            sstoim[ 1 ] += tmp->stoim
            If k == 10
              pkol += tmp->kol
              ptrud += tmp->trudoem
              pstoim += tmp->stoim
              old_slugba := tmp->fio ; old_shifr := tmp->kod_vr
            Endif
          Case k == 5
            If serv_arr != Nil .and. old_perso != tmp->kod_vr
              If old_perso > 0
                add_string( Replicate( "─", sh ) )
                fl := .f.
                If !emptyall( skol[ 1 ], strud[ 1 ], sstoim[ 1 ] )
                  fl := .t.
                  s := PadL( "И Т О Г О :  ", len_n -4 )
                  If psz == 1 ; s += "врач"
                  else        ; s += Space( 4 )
                  Endif
                  add_string( s + ;
                    Str( skol[ 1 ], 7, 0 ) + ;
                    if( mem_trudoem == 2, put_val_0( strud[ 1 ], 9, 1 ), "" ) + ;
                    put_kope( sstoim[ 1 ], 15 ) )
                  ssumv_ysl += skol[ 1 ]
                  ssumv_sum += sstoim[ 1 ]
                  If mem_trudoem == 2
                    ssumv_uet += strud[ 1 ]
                  Endif
                Endif
                If !emptyall( skol[ 2 ], strud[ 2 ], sstoim[ 2 ] )
                  s := if( fl, "", "И Т О Г О :  " )
                  add_string( PadL( s, len_n -4 ) + "асс." + ;
                    Str( skol[ 2 ], 7, 0 ) + ;
                    if( mem_trudoem == 2, put_val_0( strud[ 2 ], 9, 1 ), "" ) + ;
                    put_kope( sstoim[ 2 ], 15 ) )
                  ssuma_ysl += skol[ 2 ]
                  ssuma_sum += sstoim[ 2 ]
                  If mem_trudoem == 2
                    ssuma_uet += strud[ 2 ]
                  Endif
                Endif
                AFill( skol, 0 ) ; AFill( strud, 0 ) ; AFill( sstoim, 0 )
              Endif
              add_string( "" )
              // if mem_tabnom == 1
              add_string( Space( 5 ) + put_tab_nom( tmp->tab_nom, tmp->svod_nom ) + ". " + Upper( RTrim( tmp->fio ) ) )
              // else
              // tabn->(dbseek(str(tmp->kod_vr,4)))
              // add_string(space(5)+put_tab_nom(tabn->tab_nom,tabn->svod_nom)+;
              // ". "+upper(rtrim(tmp->fio)))
              // endif
            Endif
            j := perenos( arr, tmp->u_shifr + " " + tmp->u_name, len_n -6 )
            s := PadR( arr[ 1 ], len_n -4 ) + ;
              if( psz == 1, if( tmp->vr_as == 1, "врач", "асс." ), Space( 4 ) )
            skol[ tmp->vr_as ] += tmp->kol
            strud[ tmp->vr_as ] += tmp->trudoem
            sstoim[ tmp->vr_as ] += tmp->stoim
            old_perso := tmp->kod_vr
          Endcase
          add_string( s + ;
            Str( tmp->kol, 7, 0 ) + ;
            if( mem_trudoem == 2, put_val_0( tmp->trudoem, 9, 1 ), "" ) + ;
            put_kope( tmp->stoim, 15 ) )
          If ( equalany( k, 3, 5, 6, 10, 11, 12 ) ) .and. j > 1
            For i := 2 To j
              add_string( Space( 11 ) + arr[ i ] )
            Next
          Endif
        Endif
        Select TMP
        Skip
      Enddo
      If equalany( k, 0, 10 )
        add_string( Space( 4 ) + Replicate( ".", sh -4 ) )
        add_string( PadR( Space( 4 ) + old_slugba, len_n ) + ;
          Str( pkol, 7, 0 ) + ;
          if( mem_trudoem == 2, put_val_0( ptrud, 9, 1 ), "" ) + ;
          put_kope( pstoim, 15 ) )
        add_string( "" )
      Endif
      If k == 4
        add_string( Space( 4 ) + Replicate( ".", sh -4 ) )
        add_string( PadR( Space( 4 ) + old_fio, len_n -4 ) + ;
          if( psz == 1, if( old_vr_as == 1, "врач", "асс." ), Space( 4 ) ) + ;
          Str( pkol, 7, 0 ) + ;
          if( mem_trudoem == 2, put_val_0( ptrud, 9, 1 ), "" ) + ;
          put_kope( pstoim, 15 ) )
        add_string( "" )
      Endif
      add_string( Replicate( "─", sh ) )
      fl := .f.
      If !emptyall( skol[ 1 ], strud[ 1 ], sstoim[ 1 ] )
        fl := .t.
        s := PadL( "И Т О Г О :  ", len_n -4 )
        If equalany( k, 2, 4, 5, 7 ) .and. psz == 1
          s += "врач"
        Else
          s += Space( 4 )
        Endif
        add_string( s + ;
          Str( skol[ 1 ], 7, 0 ) + ;
          if( mem_trudoem == 2, put_val_0( strud[ 1 ], 9, 1 ), "" ) + ;
          put_kope( sstoim[ 1 ], 15 ) )
      Endif
      If ( equalany( k, 2, 4, 5, 7 ) ) .and. !emptyall( skol[ 2 ], strud[ 2 ], sstoim[ 2 ] )
        s := if( fl, "", "И Т О Г О :  " )
        s := PadL( s, len_n -4 ) + "асс."
        add_string( s + ;
          Str( skol[ 2 ], 7, 0 ) + ;
          if( mem_trudoem == 2, put_val_0( strud[ 2 ], 9, 1 ), "" ) + ;
          put_kope( sstoim[ 2 ], 15 ) )
      Endif
      If k == 5
        If !emptyall( ssumv_ysl, ssumv_uet, ssumv_sum )
          add_string( Replicate( "─", sh ) )
          fl := .t.
          s := PadL( "В С Е Г О :  ", len_n -4 )
          If psz == 1 ; s += "врач"
          else        ; s += Space( 4 )
          Endif
          add_string( s + ;
            Str( ssumv_ysl, 7, 0 ) + ;
            if( mem_trudoem == 2, put_val_0( ssumv_uet, 9, 1 ), "" ) + ;
            put_kope( ssumv_sum, 15 ) )
        Endif
        If !emptyall( ssuma_ysl, ssuma_uet, ssuma_sum )
          s := if( fl, "", "В С Е Г О :  " )
          add_string( PadL( s, len_n -4 ) + "асс." + ;
            Str( ssuma_ysl, 7, 0 ) + ;
            if( mem_trudoem == 2, put_val_0( ssuma_uet, 9, 1 ), "" ) + ;
            put_kope( ssuma_sum, 15 ) )
        Endif
      Endif
    Endif
    If psz == 2 .and. is_oplata == 7 .and. is_1_usluga
      file_tmp7( arr_usl[ 1 ], sh, HH, 2 )
    Endif
    FClose( fp )
    Close databases
    viewtext( cur_dir() + "ob_stat.txt",,,, ( sh > 80 ),,, regim )
  Endif

  Return Nil

//
Static Function pob3_statist( k, arr_otd, serv_arr, mkod_perso )

  Local i, mtrud := { 0, 0, 0 }, koef_z := { 1, 1, 1 }, k1 := 2, s1 := "2"

  If AScan( krvz, human->tip_usl ) == 0
    Return Nil
  Endif
  If arr_dms != Nil .and. AScan( arr_dms, human->pr_smo ) == 0
    Return Nil
  Endif
  If hu->u_kod > 0 .and. ( hu->kol > 0 .or. hu->stoim > 0 ) .and. ;
      ( i := AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) ) > 0
    If mem_trudoem == 2
      kart->( dbGoto( human->kod_k ) )
      mtrud := _f_trud( hu->kol, kart->vzros_reb, hu->kod_vr, hu->kod_as )
    Endif
    If psz == 2 .and. eq_any( is_oplata, 5, 6, 7 )
      koef_z := ret_p3_z( hu->u_kod, hu->kod_vr, hu->kod_as )
      If is_oplata == 7 .and. is_1_usluga
        put_tmp7( hu->kol, hu->kod_vr, hu->kod_as, mtrud, koef_z, iif( human->tip_usl == PU_D_SMO, 3, 2 ) )
      Endif
      k1 := 1 ; s1 := "1"
    Endif
    Select TMP
    Do Case
    Case k == 0
      Select USL
      Goto ( hu->u_kod )
      If !usl->( Eof() ) .and. usl->slugba >= 0
        Select TMP
        find ( Str( usl->slugba, 4 ) + Str( hu->otd, 3 ) )
        If !Found()
          Append Blank
          tmp->otd := arr_otd[ i, 1 ]
          tmp->u_name := arr_otd[ i, 2 ]
          tmp->kod_vr := usl->slugba
        Endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 1 )
        tmp->trudoem += mtrud[ 1 ]
      Endif
    Case k == 1
      find ( Str( hu->otd, 3 ) )
      If !Found()
        Append Blank
        tmp->otd := arr_otd[ i, 1 ]
        tmp->fio := arr_otd[ i, 2 ]
      Endif
      tmp->kol += hu->kol
      tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 1 )
      tmp->trudoem += mtrud[ 1 ]
    Case equalany( k, 2, 7 )
      If hu->kod_vr > 0
        find ( "1" + Str( hu->kod_vr, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := 1
          tmp->kod_vr := hu->kod_vr
        Endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 2 )
        tmp->trudoem += mtrud[ 2 ]
      Endif
      If hu->kod_as > 0
        find ( s1 + Str( hu->kod_as, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := k1
          tmp->kod_vr := hu->kod_as
        Endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 3 )
        tmp->trudoem += mtrud[ 3 ]
      Endif
    Case equalany( k, 3, 6 )
      find ( Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += hu->kol
      tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 1 )
      tmp->trudoem += mtrud[ 1 ]
    Case k == 4
      If hu->kod_vr > 0
        find ( "1" + Str( hu->kod_vr, 4 ) + Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := 1
          tmp->kod_vr := hu->kod_vr
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 2 )
        tmp->trudoem += mtrud[ 2 ]
      Endif
      If hu->kod_as > 0
        find ( s1 + Str( hu->kod_as, 4 ) + Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := k1
          tmp->kod_vr := hu->kod_as
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 3 )
        tmp->trudoem += mtrud[ 3 ]
      Endif
    Case k == 5
      If hu->kod_vr == mkod_perso
        find ( "1" + Str( mkod_perso, 4 ) + Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := 1
          tmp->kod_vr := mkod_perso
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 2 )
        tmp->trudoem += mtrud[ 2 ]
      Endif
      If hu->kod_as == mkod_perso
        find ( s1 + Str( mkod_perso, 4 ) + Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->vr_as := k1
          tmp->kod_vr := mkod_perso
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 3 )
        tmp->trudoem += mtrud[ 3 ]
      Endif
    Case k == 10  // службы + услуги
      Select USL
      Goto ( hu->u_kod )
      If !Eof() .and. usl->slugba >= 0
        Select TMP
        find ( Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->kod_vr := usl->slugba
          tmp->u_kod := usl->kod
        Endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 1 )
        tmp->trudoem += mtrud[ 1 ]
      Endif
    Case k == 11  // служба + услуги
      Select USL
      Goto ( hu->u_kod )
      If !Eof() .and. usl->slugba == serv_arr[ 1 ]
        Select TMP
        find ( Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->u_kod := usl->kod
        Endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 1 )
        tmp->trudoem += mtrud[ 1 ]
      Endif
    Case k == 12  // все услуги
      Select USL
      Goto ( hu->u_kod )
      If !Eof()
        Select TMP
        find ( Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->u_kod := usl->kod
        Endif
        tmp->kol += hu->kol
        tmp->stoim += _f_koef_z( hu->stoim, hu->kol, koef_z, 1 )
        tmp->trudoem += mtrud[ 1 ]
      Endif
    Endcase
  Endif

  Return Nil

//
Static Function pob4_statist( k, arr_otd, i, mkol, mstoim, serv_arr, mkod_perso )

  Local mtrud := { 0, 0, 0 }, koef_z := { 1, 1, 1 }, k1 := 2, s1 := "2"

  If AScan( krvz, human->tip_usl ) == 0
    Return Nil
  Endif
  If arr_dms != Nil .and. AScan( arr_dms, human->pr_smo ) == 0
    Return Nil
  Endif
  If mem_trudoem == 2
    kart->( dbGoto( human->kod_k ) )
    mtrud := _f_trud( mkol, kart->vzros_reb, hu->kod_vr, hu->kod_as )
  Endif
  If psz == 2 .and. eq_any( is_oplata, 5, 6, 7 )
    koef_z := ret_p3_z( hu->u_kod, hu->kod_vr, hu->kod_as )
    If is_oplata == 7 .and. is_1_usluga
      put_tmp7( mkol, hu->kod_vr, hu->kod_as, mtrud, koef_z, iif( human->tip_usl == PU_D_SMO, 3, 2 ) )
    Endif
    k1 := 1 ; s1 := "1"
  Endif
  Select TMP
  Do Case
  Case k == 0
    Select USL
    Goto ( hu->u_kod )
    If !Eof() .and. usl->slugba >= 0
      Select TMP
      find ( Str( usl->slugba, 4 ) + Str( hu->otd, 3 ) )
      If !Found()
        Append Blank
        tmp->otd := arr_otd[ i, 1 ]
        tmp->u_name := arr_otd[ i, 2 ]
        tmp->kod_vr := usl->slugba
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 1 )
      tmp->trudoem += mtrud[ 1 ]
    Endif
  Case k == 1
    find ( Str( hu->otd, 3 ) )
    If !Found()
      Append Blank
      tmp->otd := arr_otd[ i, 1 ]
      tmp->fio := arr_otd[ i, 2 ]
    Endif
    tmp->kol += mkol
    tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 1 )
    tmp->trudoem += mtrud[ 1 ]
  Case equalany( k, 2, 7 )
    If hu->kod_vr > 0
      find ( "1" + Str( hu->kod_vr, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := 1
        tmp->kod_vr := hu->kod_vr
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 2 )
      tmp->trudoem += mtrud[ 2 ]
    Endif
    If hu->kod_as > 0
      find ( s1 + Str( hu->kod_as, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := k1
        tmp->kod_vr := hu->kod_as
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 3 )
      tmp->trudoem += mtrud[ 3 ]
    Endif
  Case equalany( k, 3, 6 )
    find ( Str( hu->u_kod, 4 ) )
    If !Found()
      Append Blank
      tmp->u_kod := hu->u_kod
    Endif
    tmp->kol += mkol
    tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 1 )
    tmp->trudoem += mtrud[ 1 ]
  Case k == 4
    If hu->kod_vr > 0
      find ( "1" + Str( hu->kod_vr, 4 ) + Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := 1
        tmp->kod_vr := hu->kod_vr
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 2 )
      tmp->trudoem += mtrud[ 2 ]
    Endif
    If hu->kod_as > 0
      find ( s1 + Str( hu->kod_as, 4 ) + Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := k1
        tmp->kod_vr := hu->kod_as
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 3 )
      tmp->trudoem += mtrud[ 3 ]
    Endif
  Case k == 5
    If hu->kod_vr == mkod_perso
      find ( "1" + Str( mkod_perso, 4 ) + Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := 1
        tmp->kod_vr := mkod_perso
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 2 )
      tmp->trudoem += mtrud[ 2 ]
    Endif
    If hu->kod_as == mkod_perso
      find ( s1 + Str( mkod_perso, 4 ) + Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->vr_as := k1
        tmp->kod_vr := mkod_perso
        tmp->u_kod := hu->u_kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 3 )
      tmp->trudoem += mtrud[ 3 ]
    Endif
  Case k == 10  // службы + услуги
    Select USL
    Goto ( hu->u_kod )
    If !Eof() .and. usl->slugba >= 0
      Select TMP
      find ( Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->kod_vr := usl->slugba
        tmp->u_kod := usl->kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 1 )
      tmp->trudoem += mtrud[ 1 ]
    Endif
  Case k == 11  // служба + услуги
    Select USL
    Goto ( hu->u_kod )
    If !Eof() .and. usl->slugba == serv_arr[ 1 ]
      Select TMP
      find ( Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->u_kod := usl->kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 1 )
      tmp->trudoem += mtrud[ 1 ]
    Endif
  Case k == 12  // все услуги
    Select USL
    Goto ( hu->u_kod )
    If !Eof()
      Select TMP
      find ( Str( hu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->u_kod := usl->kod
      Endif
      tmp->kol += mkol
      tmp->stoim += _f_koef_z( mstoim, mkol, koef_z, 1 )
      tmp->trudoem += mtrud[ 1 ]
    Endif
  Endcase

  Return Nil

//
Static Function pob5_statist( k, arr_otd, serv_arr )

  If arr_otd != Nil .and. AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) == 0
    Return Nil
  Endif
  If AScan( krvz, human->tip_usl ) == 0
    Return Nil
  Endif
  If arr_dms != Nil .and. AScan( arr_dms, human->pr_smo ) == 0
    Return Nil
  Endif
  Select TMP
  If equalany( k, 13, 14 )
    find ( Str( hu->u_kod, 4 ) + Str( human->( RecNo() ), 7 ) )
  Else
    find ( Str( human->( RecNo() ), 7 ) )
  Endif
  If !Found()
    Append Blank
    If equalany( k, 13, 14 )
      tmp->u_kod := hu->u_kod
    Endif
    tmp->kod := human->( RecNo() )
    kart->( dbGoto( human->kod_k ) )
    tmp->fio := fam_i_o( kart->fio )
    tmp->k_data := human->k_data
  Endif
  tmp->kol += hu->kol
  tmp->stoim += hu->stoim

  Return Nil

//
Function st_plat_fio( reg )

  // reg = 1 - Список больных с суммами лечения в каждом из отделений
  // reg = 2 - Список больных с разбивкой сумм лечения по каждому врачу (м/сестре, санитарке)
  Static svr_as := 1, mas_pmt := { "~Врачи", "~Ассистенты", "~Медсестры", "~Санитарки" }
  Local vr_as, adbf, i, j, arr[ 2 ], begin_date, end_date, ;
    fl_exit := .f., sh, HH := 57, reg_print, s, xx, n, nvr, ;
    arr_otd := {}, n_file := cur_dir() + "plat_fio.txt", buf := save_row( MaxRow() )
  Private krvz, arr_dms, d_file := "PLAT_FIO" + sdbf()
  If !del_dbf_file( d_file )
    Return Nil
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  begin_date := arr[ 7 ]
  end_date := arr[ 8 ]
  If ( krvz := fbp_tip_usl( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  If reg == 2
    If ( vr_as := popup_prompt( T_ROW, T_COL -5, svr_as, mas_pmt ) ) == 0
      Return Nil
    Endif
    svr_as := vr_as
  Endif
  mywait()
  r_use( dir_server() + "mo_uch",, "UCH" )
  r_use( dir_server() + "mo_otd",, "OTD" )
  Go Top
  Do While !Eof()
    If f_is_uch( st_a_uch, otd->kod_lpu )
      uch->( dbGoto( otd->kod_lpu ) )
      AAdd( arr_otd, { otd->( RecNo() ), otd->name, otd->kod_lpu, uch->name } )
    Endif
    Skip
  Enddo
  Close databases
  adbf := { { "kod",  "N", 7, 0 }, ;  // код л/у
    { "kod_k", "N", 7, 0 }, ;  // код по картотеке
    { "kod_p", "N", 4, 0 }, ;  // код персонала
    { "otd",  "N", 3, 0 }, ;  // код отделения
    { "summa", "N", 12, 2 } ;
    }   // общая сумма лечения по данному отделению
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod_k, 7 ) + Str( kod, 7 ) + Str( otd, 3 ) + Str( kod_p, 4 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  r_use( dir_server() + "hum_p",, "HUMAN" )
  If pi1 == 3  // по дате закрытия листа учета
    Set Index to ( dir_server() + "hum_pc" )
    For xx := 0 To 2
      If AScan( krvz, xx ) > 0
        Select HUMAN
        dbSeek( Str( xx, 1 ) + "1" + DToS( arr[ 5 ] ), .t. )
        Do While human->tip_usl == xx .and. human->date_close <= arr[ 6 ] .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          If iif( arr_dms == NIL, .t., AScan( arr_dms, human->pr_smo ) > 0 )
            Select HU
            find ( Str( human->( RecNo() ), 7 ) )
            Do While hu->kod == human->( RecNo() )
              If AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) > 0
                f1_plat_fio( reg, vr_as )
              Endif
              Select HU
              Skip
            Enddo
          Endif
          Select HUMAN
          Skip
        Enddo
      Endif
      If fl_exit ; exit ; Endif
    Next
  Else  // только по дате окончания лечения
    Set Index to ( dir_server() + "hum_pd" )
    dbSeek( DToS( arr[ 5 ] ), .t. )
    Do While human->k_data <= arr[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If AScan( krvz, human->tip_usl ) > 0 .and. ;
          iif( arr_dms == NIL, .t., AScan( arr_dms, human->pr_smo ) > 0 )
        Select HU
        find ( Str( human->( RecNo() ), 7 ) )
        Do While hu->kod == human->( RecNo() )
          If AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) > 0
            f1_plat_fio( reg, vr_as )
          Endif
          Select HU
          Skip
        Enddo
      Endif
      Select HUMAN
      Skip
    Enddo
  Endif
  j := tmp->( LastRec() )
  Close databases
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    n := 30
    arr_title := { Replicate( "─", n ), ;
      Space( n ), ;
      PadC( "Ф.И.О. больного", n ), ;
      Replicate( "─", n ) }
    adbf := { { "fio", "C", 50, 0 } }
    If reg == 1
      arr_title[ 1 ] += "┬──────────"
      arr_title[ 2 ] += "│ Окончание"
      arr_title[ 3 ] += "│  лечения "
      arr_title[ 4 ] += "┴──────────"
      AAdd( adbf, { "k_data", "C", 10, 0 } )
    Endif
    If pi1 == 3  // по дате закрытия листа учета
      arr_title[ 1 ] += "┬──────────"
      arr_title[ 2 ] += "│   Дата   "
      arr_title[ 3 ] += "│  оплаты  "
      arr_title[ 4 ] += "┴──────────"
      AAdd( adbf, { "date_close", "C", 10, 0 } )
    Endif
    If Len( st_a_uch ) > 1
      arr_title[ 1 ] += "┬──────────"
      arr_title[ 2 ] += "│          "
      arr_title[ 3 ] += "│Учреждение"
      arr_title[ 4 ] += "┴──────────"
      AAdd( adbf, { "uch", "C", 30, 0 } )
    Endif
    arr_title[ 1 ] += "┬─────"
    arr_title[ 2 ] += "│Отде-"
    arr_title[ 3 ] += "│ление"
    arr_title[ 4 ] += "┴─────"
    AAdd( adbf, { "otd", "C", 50, 0 } )
    nvr := 20
    If reg == 2
      arr_title[ 1 ] += "┬" + Replicate( "─", nvr )
      arr_title[ 2 ] += "│" + Space( nvr )
      arr_title[ 3 ] += "│" + PadC( { "Врачи", "Ассистенты", "Медсестры", "Санитарки" }[ vr_as ], nvr )
      arr_title[ 4 ] += "┴" + Replicate( "─", nvr )
      AAdd( adbf, { "tab_nom", "N", 5, 0 } )
      AAdd( adbf, { "personal", "C", 50, 0 } )
    Endif
    arr_title[ 1 ] += "┬───────────"
    arr_title[ 2 ] += "│ Стоимость "
    arr_title[ 3 ] += "│   услуг   "
    arr_title[ 4 ] += "┴───────────"
    AAdd( adbf, { "summa", "N", 12, 2 } )
    dbCreate( d_file, adbf )
    Use ( d_file ) New Alias DD
    reg_print :=  f_reg_print( arr_title, @sh )
    r_use( dir_server() + "mo_uch",, "UCH" )
    r_use( dir_server() + "mo_otd",, "OTD" )
    Set Relation To kod_lpu into UCH // , to recno() into OTD
    r_use( dir_server() + "kartotek",, "KART" )
    r_use( dir_server() + "hum_p",, "HUMAN" )
    Use ( cur_dir() + "tmp" ) new
    Set Relation To otd into OTD, To kod_k into KART, To kod into HUMAN
    If reg == 2
      If vr_as < 3
        r_use( dir_server() + "mo_pers",, "perso" )
        Select TMP
        Set Relation To kod_p into perso Additive
      Else
        r_use( dir_server() + "plat_ms",, "perso" )
        Select TMP
        Set Relation To kod_p into perso Additive
      Endif
    Endif
    If reg == 1
      Index On Left( Upper( kart->fio ), 20 ) + Str( kod_k, 7 ) + DToS( human->k_data ) + ;
        Upper( uch->name ) + Upper( otd->short_name ) to ( cur_dir() + "tmp" )
    Else
      Index On Left( Upper( kart->fio ), 20 ) + Str( kod_k, 7 ) + Upper( uch->name ) + ;
        Upper( otd->short_name ) + Upper( perso->fio ) to ( cur_dir() + "tmp" )
    Endif
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "ПЛАТНЫЕ УСЛУГИ" )
    add_string( Center( "Статистика по работе персонала", sh ) )
    titlen_uch( st_a_uch, sh )
    tit_tip_usl( krvz, arr_dms, sh )
    add_string( Center( arr[ 4 ], sh ) )
    add_string( "" )
    Do Case
    Case pi1 == 1
      s := "[ по дате лечения ]"
    Case pi1 == 2
      s := "[ по дате окончания лечения ]"
    Case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
    Endcase
    add_string( Center( s, sh ) )
    add_string( "" )
    old_kart := -999 ; old_lu := 0
    Select TMP
    Go Top
    AEval( arr_title, {| x| add_string( x ) } )
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      Select DD
      Append Blank
      dd->fio := kart->fio
      If old_kart == tmp->kod_k .and. old_lu == tmp->kod
        s := Space( n )
      Else
        s := PadR( kart->fio, n )
      Endif
      old_kart := tmp->kod_k
      old_lu := tmp->kod
      If reg == 1
        s += " " + full_date( human->k_data )
        dd->k_data := full_date( human->k_data )
      Endif
      If pi1 == 3  // по дате закрытия листа учета
        s += " "
        If human->date_close > human->k_data
          s += full_date( human->date_close )
        Else
          s += PadC( "аванс", 10 )
        Endif
        dd->date_close := full_date( human->date_close )
      Endif
      If Len( st_a_uch ) > 1
        s += " " + PadR( uch->name, 10 )
        dd->uch := uch->name
      Endif
      s += " " + PadR( otd->short_name, 5 )
      dd->otd := otd->name
      If reg == 2
        s1 := "["
        If vr_as < 3
          dd->tab_nom := perso->tab_nom
          s1 += lstr( perso->tab_nom )
        Else
          dd->tab_nom := perso->tab_nom
          s1 += lstr( perso->tab_nom )
        Endif
        s1 += "] " + fam_i_o( perso->fio )
        s += " " + PadR( s1, nvr )
        dd->personal := perso->fio
      Endif
      s += put_kop( tmp->summa, 12 )
      dd->summa := tmp->summa
      If dd->( LastRec() ) % 5000 == 0
        Commit
      Endif
      add_string( s )
      Select TMP
      Skip
    Enddo
    FClose( fp )
    Close databases
    viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
    rest_box( buf )
    n_message( { "Создан файл:  " + d_file },, cColorStMsg, cColorStMsg,,, cColorSt2Msg )
  Endif
  rest_box( buf )

  Return Nil

//
Function f1_plat_fio( reg, vr_as )

  Local i, k, arr := {}, koef_z := { 1, 1, 1 }, koef_ms := 1, koef_sn := 1

  If reg == 1
    Select TMP
    find ( Str( human->kod_k, 7 ) + Str( human->( RecNo() ), 7 ) + Str( hu->otd, 3 ) )
    If !Found()
      Append Blank
      tmp->kod   := human->( RecNo() )
      tmp->kod_k := human->kod_k
      tmp->otd   := hu->otd
    Endif
    tmp->summa += hu->stoim
  Else
    Do Case
    Case vr_as == 1  // врачи
      AAdd( arr, { hu->kod_vr, koef_z[ 2 ] } )
    Case vr_as == 2  // ассистенты
      AAdd( arr, { hu->kod_as, koef_z[ 3 ] } )
    Case vr_as == 3  // медсестры
      If hu->med1 > 0
        AAdd( arr, { hu->med1, koef_ms } )
      Endif
      If hu->med2 > 0
        AAdd( arr, { hu->med2, koef_ms } )
      Endif
      If hu->med3 > 0
        AAdd( arr, { hu->med3, koef_ms } )
      Endif
      If Len( arr ) == 0
        AAdd( arr, { 0, koef_ms } )
      Endif
    Case vr_as == 4  // санитарки
      If hu->san1 > 0
        AAdd( arr, { hu->san1, koef_sn } )
      Endif
      If hu->san2 > 0
        AAdd( arr, { hu->san2, koef_sn } )
      Endif
      If hu->san3 > 0
        AAdd( arr, { hu->san3, koef_sn } )
      Endif
      If Len( arr ) == 0
        AAdd( arr, { 0, koef_sn } )
      Endif
    Endcase
    k := Len( arr )
    For i := 1 To k
      Select TMP
      find ( Str( human->kod_k, 7 ) + Str( human->( RecNo() ), 7 ) + Str( hu->otd, 3 ) + Str( arr[ i, 1 ], 4 ) )
      If !Found()
        Append Blank
        tmp->kod   := human->( RecNo() )
        tmp->kod_k := human->kod_k
        tmp->otd   := hu->otd
        tmp->kod_p := arr[ i, 1 ]
      Endif
      tmp->summa += hu->stoim / k
    Next
  Endif

  Return Nil

//
Function st_plat_ms( reg )

  Local i, j, arr[ 2 ], begin_date, end_date, n_file := cur_dir() + "plat_ms.txt", ;
    fl_exit := .f., sh, HH := 57, reg_print := 1, s, arr_dms, ;
    ss, ss1, ss2, ss3, arr_title, adbf, krvz, xx

  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  begin_date := arr[ 7 ]
  end_date := arr[ 8 ]
  If ( krvz := fbp_tip_usl( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  If psz == 1
  /*Private usl_dop := rest_arr(dir_server()+"usl_pl_d"+smem()),;
          usl_mat := rest_arr(dir_server()+"usl_pl_m"+smem())*/
  Endif
  adbf := { ;
    { "KOD",        "N",      4,      0 }, ;  // код персонала
    { "KOL1",    "N",      6,      0 }, ;  // платные
    { "SUM1",    "N",     14,      2 }, ;  // платные
    { "KOL2",    "N",      6,      0 }, ;  // доплаты за услуги
    { "SUM2",    "N",     14,      2 }, ;  // доплаты за услуги
    { "KOL3",    "N",      6,      0 }, ;  // материалы
    { "SUM3",    "N",     14,      2 }, ;  // материалы
    { "SUMMA",      "N",     18,      2 };   // ст-ть услуг (зарплата)
    }
  dbCreate( cur_dir() + "tmp", adbf )
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  Use ( cur_dir() + "tmp" )
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp" )
  // по дате окончания лечения
  g_use( dir_server() + "uslugi", dir_server() + "uslugi", "USL" )
  g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  g_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUMAN" )
  If pi1 == 3  // по дате закрытия листа учета
    Set Index to ( dir_server() + "hum_pc" )
    For xx := 0 To 2
      If AScan( krvz, xx ) > 0
        Select HUMAN
        dbSeek( Str( xx, 1 ) + "1" + DToS( arr[ 5 ] ), .t. )
        Do While human->tip_usl == xx .and. human->date_close <= arr[ 6 ] .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          If iif( arr_dms == NIL, .t., AScan( arr_dms, human->pr_smo ) > 0 )
            Select HU
            find ( Str( human->( RecNo() ), 7 ) )
            Do While hu->kod == human->( RecNo() )
              f1_plat_ms( reg )
              Select HU
              Skip
            Enddo
          Endif
          Select HUMAN
          Skip
        Enddo
      Endif
    Next
  Else
    dbSeek( DToS( arr[ 5 ] ), .t. )
    Do While human->k_data <= arr[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If AScan( krvz, human->tip_usl ) > 0 .and. ;
          iif( arr_dms == NIL, .t., AScan( arr_dms, human->pr_smo ) > 0 )
        Select HU
        find ( Str( human->( RecNo() ), 7 ) )
        Do While hu->kod == human->( RecNo() )
          f1_plat_ms( reg )
          Select HU
          Skip
        Enddo
      Endif
      Select HUMAN
      Skip
    Enddo
  Endif
  j := tmp->( LastRec() )
  Close databases
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    If psz == 1
      reg_print := 2
      arr_title := { ;
        "──────────────────────────┬─────────────────┬─────────────────┬─────────────────", ;
        "                          │  Платные услуги │Доплаты за услуги│    Материалы    ", ;
        "                          ├──────┬──────────┼──────┬──────────┼──────┬──────────", ;
        "          Ф.И.О.          │Кол-во│ Стоимость│Кол-во│ Стоимость│Кол-во│ Стоимость", ;
        "                          │ услуг│   услуг  │ услуг│   услуг  │ услуг│   услуг  ", ;
        "──────────────────────────┴──────┴──────────┴──────┴──────────┴──────┴──────────" }
    Else
      arr_title := { ;
        "──────────────────────────────────────────────────┬──────────────", ;
        "                                                  │  Заработная", ;
        "                     Ф.И.О.                       │    плата", ;
        "──────────────────────────────────────────────────┴──────────────" }
    Endif
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "ПЛАТНЫЕ УСЛУГИ" )
    add_string( Center( "Статистика по работе персонала", sh ) )
    add_string( Center( Expand( { "МЕДСЕСТРЫ", "САНИТАРКИ" }[ reg ] ), sh ) )
    tit_tip_usl( krvz, arr_dms, sh )
    add_string( Center( arr[ 4 ], sh ) )
    add_string( "" )
    Do Case
    Case pi1 == 1
      s := "[ по дате лечения ]"
    Case pi1 == 2
      s := "[ по дате окончания лечения ]"
    Case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
    Endcase
    add_string( Center( s, sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    g_use( dir_server() + "plat_ms",, "PMS" )
    Store 0 To ss, ss1, ss2, ss3
    Use ( cur_dir() + "tmp" ) new
    Set Relation To kod into PMS
    Index On Upper( pms->fio ) to ( cur_dir() + "tmp" )
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If psz == 1
        add_string( PadR( Str( pms->tab_nom, 5 ) + " " + pms->fio, 26 ) + ;
          put_val( tmp->kol1, 7 ) + put_kope( tmp->sum1, 11 ) + ;
          put_val( tmp->kol2, 7 ) + put_kope( tmp->sum2, 11 ) + ;
          put_val( tmp->kol3, 7 ) + put_kope( tmp->sum3, 11 ) )
        ss1 += tmp->sum1
        ss2 += tmp->sum2
        ss3 += tmp->sum3
      Else
        add_string( PadR( Str( pms->tab_nom, 5 ) + "  " + pms->fio, 50 ) + put_kope( tmp->summa, 15 ) )
        ss += tmp->summa
      Endif
      Skip
    Enddo
    add_string( Replicate( "─", sh ) )
    If psz == 1
      add_string( put_kope( ss1, sh -36 ) + put_kope( ss2, 18 ) + put_kope( ss3, 18 ) )
    Else
      add_string( put_kope( ss, sh ) )
    Endif
    FClose( fp )
    Close databases
    viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

//
Function f1_plat_ms( reg )

  Local pole_kol, pole_sum, s1, koef := 0

  If psz == 1
    s1 := "1"
  /*if is_up_usl(usl_dop,hu->u_kod)
    s1 := "2"
  elseif is_up_usl(usl_mat,hu->u_kod)
    s1 := "3"
  endif*/
    pole_kol := "tmp->kol" + s1
    pole_sum := "tmp->sum" + s1
  Endif
  If reg == 1
    If hu->med1 > 0
      ++koef
    Endif
    If hu->med2 > 0
      ++koef
    Endif
    If hu->med3 > 0
      ++koef
    Endif
    If hu->med1 > 0
      Select TMP
      find ( Str( hu->med1, 4 ) )
      If !Found()
        Append Blank
        tmp->kod := hu->med1
      Endif
      If psz == 1
        &pole_kol := &pole_kol + hu->kol
        &pole_sum := &pole_sum + hu->stoim / koef
      Else
        tmp->summa += round_5( hu->stoim * mem_pl_ms / 100 / koef, 2 )
      Endif
    Endif
    If hu->med2 > 0
      Select TMP
      find ( Str( hu->med2, 4 ) )
      If !Found()
        Append Blank
        tmp->kod := hu->med2
      Endif
      If psz == 1
        &pole_kol := &pole_kol + hu->kol
        &pole_sum := &pole_sum + hu->stoim / koef
      Else
        tmp->summa += round_5( hu->stoim * mem_pl_ms / 100 / koef, 2 )
      Endif
    Endif
    If hu->med3 > 0
      Select TMP
      find ( Str( hu->med3, 4 ) )
      If !Found()
        Append Blank
        tmp->kod := hu->med3
      Endif
      If psz == 1
        &pole_kol := &pole_kol + hu->kol
        &pole_sum := &pole_sum + hu->stoim / koef
      Else
        tmp->summa += round_5( hu->stoim * mem_pl_ms / 100 / koef, 2 )
      Endif
    Endif
  Else
    If hu->san1 > 0
      ++koef
    Endif
    If hu->san2 > 0
      ++koef
    Endif
    If hu->san3 > 0
      ++koef
    Endif
    If hu->san1 > 0
      Select TMP
      find ( Str( hu->san1, 4 ) )
      If !Found()
        Append Blank
        tmp->kod := hu->san1
      Endif
      If psz == 1
        &pole_kol := &pole_kol + hu->kol
        &pole_sum := &pole_sum + hu->stoim / koef
      Else
        tmp->summa += round_5( hu->stoim * mem_pl_sn / 100 / koef, 2 )
      Endif
    Endif
    If hu->san2 > 0
      Select TMP
      find ( Str( hu->san2, 4 ) )
      If !Found()
        Append Blank
        tmp->kod := hu->san2
      Endif
      If psz == 1
        &pole_kol := &pole_kol + hu->kol
        &pole_sum := &pole_sum + hu->stoim / koef
      Else
        tmp->summa += round_5( hu->stoim * mem_pl_sn / 100 / koef, 2 )
      Endif
    Endif
    If hu->san3 > 0
      Select TMP
      find ( Str( hu->san3, 4 ) )
      If !Found()
        Append Blank
        tmp->kod := hu->san3
      Endif
      If psz == 1
        &pole_kol := &pole_kol + hu->kol
        &pole_sum := &pole_sum + hu->stoim / koef
      Else
        tmp->summa += round_5( hu->stoim * mem_pl_sn / 100 / koef, 2 )
      Endif
    Endif
  Endif

  Return Nil

// 22.03.17
Function pl_mnog_poisk()

  Static mm_g_selo :=  { { "город", 1 }, { "село", 2 } }
  Local mm_tmp := {}, k
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    mm_mest := { { "Волгоград или область", 1 }, { "иногородние", 2 } }, ;
    tmp_help := 0, hGauge, name_file := cur_dir() + "pl_mnog.txt", ;
    sh := 80, HH := 77, r1 := 2, a_diagnoz[ 3 ], a_uslugi[ 20 ], ;
    k_usl, fl_stom := .f., ;
    mm_da_net := { { "нет", 1 }, { "да ", 2 } }, lvid_doc := 0, ;
    menu_plat := { { "платные    ", PU_PLAT }, ;
    { "добр/страх.", PU_D_SMO }, ;
    { "взаимозачет", PU_PR_VZ } }, ;
    tmp_file := "tmp_mn_p" + sdbf()

  // help_code
  Private ssumma := 0
  Private = 0

  Private arr_doc := { "Дата рожд.", ;
    "Адрес", ;
    "Дата.леч.", ;
    "Диагноз", ;
    "Услуги", ;
    "Услуги+врачи" }
  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  Private pr_arr := {}, pr_arr_otd := {}, is_talon := ret_is_talon()
  //
  g_use( dir_server() + "mo_otd",, "OTD" )
  dbEval( {|| AAdd( pr_arr, { otd->( RecNo() ), otd->name, otd->kod_lpu, "" } ) }, ;
    {|| f_is_uch( st_a_uch, otd->kod_lpu ) .and. between_date( otd->dbeginp, otd->dendp, sys_date ) } )
  g_use( dir_server() + "mo_uch",, "UCH" )
  AEval( pr_arr, {| x, i| dbGoto( x[ 3 ] ), pr_arr[ i, 4 ] := uch->name } )
  //
  ASort( pr_arr,,, {| x, y| iif( x[ 3 ] == y[ 3 ], Upper( x[ 2 ] ) < Upper( y[ 2 ] ), ;
    Upper( x[ 4 ] ) < Upper( y[ 4 ] ) ) } )
  AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 2 ] + " " + x[ 4 ] ) } )
  Close databases
  //
  lvid_doc := SetBit( lvid_doc, 1 )
  lvid_doc := SetBit( lvid_doc, 3 )
  //
  Private pdate_lech, pdate_schet, mstr_crb := 0, mslugba
  //
  dbCreate( cur_dir() + "tmp", { ;
    { "U_KOD",    "N",      4,      0 }, ;  // код услуги
  { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
    { "U_NAME",     "C",     65,      0 } ;  // наименование услуги
  } )
  Use ( cur_dir() + "tmp" )
  Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
  Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
  tmp->( dbCloseArea() )
  AAdd( mm_tmp, { "date_lech", "N", 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, nil, ( pdate_lech := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    'Дата окончания лечения' } )
  AAdd( mm_tmp, { "date_schet", "N", 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, nil, ( pdate_schet := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    'Дата закрытия л/учета' } )
  AAdd( mm_tmp, { "uch_doc", "C", 10, 0, "@!", ;
    nil, ;
    Space( 10 ), nil, ;
    "Вид и номер учетного документа (шаблон)" } )
  Private arr_uchast := {}
  If is_uchastok > 0
    AAdd( mm_tmp, { "bukva", "C", 1, 0, "@!", ;
      nil, ;
      " ", nil, ;
      "Буква (перед участком)" } )
    AAdd( mm_tmp, { "uchast", "N", 1, 0,, ;
      {| x| menu_reader( x, ;
      { {| k, r, c| get_uchast( r + 1, c ) } }, A__FUNCTION ) }, ;
      0, {|| init_uchast( arr_uchast ) }, ;
      "Участок (участки)" } )
  Endif
  AAdd( mm_tmp, { "fio", "C", 20, 0, "@!", ;
    nil, ;
    Space( 20 ), nil, ;
    "ФИО (начальные буквы или шаблон)" } )
  AAdd( mm_tmp, { "inostran", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    "Документы иностранных граждан:" } )
  AAdd( mm_tmp, { "gorod_selo", "N", 2, 0, NIL, ;
    {| x| menu_reader( x, mm_g_selo, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    "Житель:" } )
  AAdd( mm_tmp, { "mi_git", "N", 2, 0, NIL, ;
    {| x| menu_reader( x, mm_mest, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    "Место жительства:" } )
  AAdd( mm_tmp, { "_okato", "C", 11, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| get_okato_ulica( k, r, c, { k, m_okato, } ) } }, A__FUNCTION ) }, ;
    Space( 11 ), {| x| Space( 11 ) }, ;
    'Адрес регистрации (ОКАТО)' } )
  // 12.11.16
  AAdd( mm_tmp, { "adres", "C", 20, 0, "@!", ;
    nil, ;
    Space( 20 ), nil, ;
    "Улица (подстрока или шаблон)" } )
  AAdd( mm_tmp, { "mr_dol", "C", 20, 0, "@!", ;
    nil, ;
    Space( 20 ), nil, ;
    "Место работы (подстрока или шаблон)" } )
  If is_talon
    AAdd( mm_tmp, { "kategor", "N", 2, 0, NIL, ;
      {| x| menu_reader( x, mo_cut_menu( stm_kategor ), A__MENUVERT ) }, ;
      0, {|| Space( 10 ) }, ;
      "Код категории льготы" } )
  Endif
  AAdd( mm_tmp, { "pol", "C", 1, 0, "!", ;
    nil, ;
    " ", nil, ;
    "Пол", {|| mpol $ " МЖ" } } )
  AAdd( mm_tmp, { "vzros_reb", "N", 2, 0, NIL, ;
    {| x| menu_reader( x, menu_vzros, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    "Возрастная принадлежность" } )
  AAdd( mm_tmp, { "god_r_min", "D", 8, 0,, ;
    nil, ;
    CToD( "" ), nil, ;
    "Дата рождения (минимальная)" } )
  AAdd( mm_tmp, { "god_r_max", "D", 8, 0,, ;
    nil, ;
    CToD( "" ), nil, ;
    "Дата рождения (максимальная)" } )
  AAdd( mm_tmp, { "rab_nerab", "N", 2, 0, NIL, ;
    {| x| menu_reader( x, menu_rab, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    "Работающий/неработающий" } )
/*aadd(mm_tmp, {"mi_git","N",2,0,NIL,;
              {|x|menu_reader(x,menu_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "МЕСТО ЖИТЕЛЬСТВА: г/о/и",;
              {|g,o|valid_mest_inog(g,o,2)} })
aadd(mm_tmp, {"rajon_git","N",2,0,NIL,;
              {|x|menu_reader(x,{dir_server()+"rajon",,;
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
              {|x|menu_reader(x,{dir_server()+"rajon",,;
                      {||FIELD->tip==m1mest_inog}},A__POPUPMENU)},;
              0,{|| space(10) },;
              "   район",,;
              {|| equalany(m1mest_inog,0,1) } })
              */
  AAdd( mm_tmp, { "kod_diag", "C", 5, 0, "@!", ;
    nil, ;
    Space( 5 ), nil, ;
    "Шифр заболевания", ;
    {|| val2_10diag() } } )
  If yes_h_otd == 1
    AAdd( mm_tmp, { "otd", "N", 3, 0, NIL, ;
      {| x| menu_reader( x, ;
      { {| k, r, c| get_otd( k, r + 1, c ) } }, A__FUNCTION ) }, ;
      0, {|| Space( 10 ) }, ;
      "Отделение, в котором выписан счет" } )
  Endif
  AAdd( mm_tmp, { "tip_usl", "N", 2, 0, NIL, ;
    {| x| menu_reader( x, menu_plat, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    "Категория оплаты" } )
  AAdd( mm_tmp, { "uslugi", "N", 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| ob2_v_usl( .t., r + 1 ) } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    "Оказанные услуги" } )
  AAdd( mm_tmp, { "otd_usl", "N", 3, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| get_otd( k, r + 1, c ) } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    "Отделение, в котором оказана услуга" } )
  AAdd( mm_tmp, { "slug_usl", "N", 3, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| get_slugba( k, r, c ) } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    "Служба, в которой оказана услуга" } )
  AAdd( mm_tmp, { "vr1", "N", 5, 0, NIL, ;
    nil, ;
    0, nil, ;
    "Врач, оказавший услугу(и)", ;
    {| g| st_v_vrach( g, "mvr" ) } } )
  AAdd( mm_tmp, { "vr", "C", 50, 0, NIL, ;
    nil, ;
    Space( 50 ), nil, ;
    "  ФИО врача",, ;
    {|| .f. } } )
  AAdd( mm_tmp, { "isvr", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    "Код врача проставлен?",, ;
    {|| mvr1 == 0 } } )
  AAdd( mm_tmp, { "as1", "N", 5, 0, NIL, ;
    nil, ;
    0, nil, ;
    "Ассистент, оказавший услугу(и)", ;
    {| g| st_v_vrach( g, "mas" ) } } )
  AAdd( mm_tmp, { "as", "C", 50, 0, NIL, ;
    nil, ;
    Space( 50 ), nil, ;
    "  ФИО асситента",, ;
    {|| .f. } } )
  AAdd( mm_tmp, { "isas", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    "Код ассистента проставлен?",, ;
    {|| mas1 == 0 } } )
  AAdd( mm_tmp, { "vras1", "N", 5, 0, NIL, ;
    nil, ;
    0, nil, ;
    "Человек, оказавший услугу(и)", ;
    {| g| st_v_vrach( g, "mvras" ) } } )
  AAdd( mm_tmp, { "vras", "C", 50, 0, NIL, ;
    nil, ;
    Space( 50 ), nil, ;
    "                            ",, ;
    {|| .f. } } )
  If is_oplata != 7
    AAdd( mm_tmp, { "med1", "N", 5, 0, NIL, ;
      nil, ;
      0, nil, ;
      "Медсестра", ;
      {| g| st_v_vrach( g, "mmed", 1 ) } } )
    AAdd( mm_tmp, { "med", "C", 50, 0, NIL, ;
      nil, ;
      Space( 50 ), nil, ;
      "  ФИО медсестры",, ;
      {|| .f. } } )
    AAdd( mm_tmp, { "san1", "N", 5, 0, NIL, ;
      nil, ;
      0, nil, ;
      "Санитарка", ;
      {| g| st_v_vrach( g, "msan", 2 ) } } )
    AAdd( mm_tmp, { "san", "C", 50, 0, NIL, ;
      nil, ;
      Space( 50 ), nil, ;
      "  ФИО санитарки",, ;
      {|| .f. } } )
  Endif
  AAdd( mm_tmp, { "summa_min", "N", 10, 2,, ;
    nil, ;
    0, nil, ;
    "Сумма лечения (минимальная)" } )
  AAdd( mm_tmp, { "summa_max", "N", 10, 2,, ;
    nil, ;
    0, nil, ;
    "Сумма лечения (максимальная)" } )
  AAdd( mm_tmp, { "vid_doc", "N", 5, 0, NIL, ;
    {| x| menu_reader( x, arr_doc, A__MENUBIT ) }, ;
    lvid_doc, {| x| inieditspr( A__MENUBIT, arr_doc, x ) }, ;
    "Вид документа", NIL } )
  Delete File ( tmp_file )
  init_base( tmp_file,, mm_tmp, 0 )
  //
  r_use( dir_server() + "plat_ms", dir_server() + "plat_ms", "MS" )
  r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
  k := f_edit_spr( A__APPEND, mm_tmp, "множественному запросу", ;
    "g_use(cur_dir()+'tmp_mn_p',,,.t.,.t.)", 0, 1,,,,, "pwrite_mn_p" )
  If k > 0
    mywait()
    Use ( tmp_file ) New Alias MN
    If is_talon .and. mn->kategor == 0
      is_talon := .f.
    Endif
    r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
    Select PERSO
    If mn->vr1 > 0
      find ( Str( mn->vr1, 5 ) )
      If Found()
        mn->vr1 := perso->kod
      Endif
    Endif
    If mn->as1 > 0
      find ( Str( mn->as1, 5 ) )
      If Found()
        mn->as1 := perso->kod
      Endif
    Endif
    If mn->vras1 > 0
      find ( Str( mn->vras1, 5 ) )
      If Found()
        mn->vras1 := perso->kod
      Endif
    Endif
    If is_oplata != 7
      r_use( dir_server() + "plat_ms", dir_server() + "plat_ms", "MS" )
      If mn->med1 > 0
        find ( "1" + Str( mn->med1, 5 ) )
        If Found()
          mn->med1 := ms->( RecNo() )
        Endif
      Endif
      If mn->san1 > 0
        find ( "2" + Str( mn->san1, 5 ) )
        If Found()
          mn->san1 := ms->( RecNo() )
        Endif
      Endif
      ms->( dbCloseArea() )
    Endif
    Private much_doc := "", mfio := "", madres := "", mmr_dol := ""
    If !Empty( mn->uch_doc )
      much_doc := AllTrim( mn->uch_doc )
      If !( Right( much_doc, 1 ) == "*" )
        much_doc += "*"
      Endif
    Endif
    If !Empty( mn->fio )
      mfio := AllTrim( mn->fio )
      If !( Right( mfio, 1 ) == "*" )
        mfio += "*"
      Endif
    Endif
    If !Empty( mn->adres )
      madres := AllTrim( mn->adres )
      If !( Left( madres, 1 ) == "*" )
        madres := "*" + madres
      Endif
      If !( Right( madres, 1 ) == "*" )
        madres += "*"
      Endif
    Endif
    If !Empty( mn->mr_dol )
      mmr_dol := AllTrim( mn->mr_dol )
      If !( Left( mmr_dol, 1 ) == "*" )
        mmr_dol := "*" + mmr_dol
      Endif
      If !( Right( mmr_dol, 1 ) == "*" )
        mmr_dol += "*"
      Endif
    Endif
    If mn->date_schet > 0
      p_regim := 2
    Else
      p_regim := 1
    Endif
    Private arr_usl := {}, fl_summa := .t.
    If mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. ;
        mn->vras1 > 0 .or. mn->slug_usl > 0 .or. mn->uslugi > 0
      fl_summa := .f.
    Endif
    If fl_summa .and. is_oplata != 7
      If mn->med1 > 0 .or. mn->san1 > 0
        fl_summa := .f.
      Endif
    Endif
    If mn->uslugi > 0
      Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmpn" ) new
      Go Top
      dbEval( {|| AAdd( arr_usl, { tmp->u_kod, tmp->u_shifr, tmp->u_name, 0, 0 } ) } )
      tmp->( dbCloseArea() )
    Endif
    flag_hu := ( mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. ;
      mn->vras1 > 0 .or. mn->slug_usl > 0 .or. mn->uslugi > 0 )
    If !flag_hu .and. is_oplata != 7
      flag_hu := ( mn->med1 > 0 .or. mn->san1 > 0 )
    Endif
    dbCreate( cur_dir() + "tmp", { { "kod", "N", 7, 0 }, ;
      { "stoim", "N", 10, 2 } } )
    Use ( cur_dir() + "tmp" ) new
    dbCreate( cur_dir() + "tmp_k", { { "kod_k", "N", 7, 0 } } )
    Use ( cur_dir() + "tmp_k" ) new
    Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_k" )
    fl_exit := .f.
    status_key( "^<Esc>^ - прервать поиск" )
    g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
    If mn->slug_usl > 0
      g_use( dir_server() + "uslugi",, "USL" )
      Select HU
      Set Relation To u_kod into USL
    Endif
    If is_talon
      ab_open()
    Endif
    Private c_view := 0, c_found := 0
    r_use( dir_server() + "kartote2",, "KART2" )
    r_use( dir_server() + "kartote_",, "KART_" )
    r_use( dir_server() + "kartotek",, "KART" )
    Set Relation To RecNo() into KART_, RecNo() into KART2
    If p_regim == 1
      r_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUMAN" )
      Set Relation To kod_k into KART
      dbSeek( DToS( pdate_lech[ 5 ] ), .t. )
      Do While human->k_data <= pdate_lech[ 6 ] .and. !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If f_is_uch( st_a_uch, human->lpu )
          s1_mnog_poisk( @c_view, @c_found )
        Endif
        Select HUMAN
        Skip
      Enddo
    Else  // по дате закрытия листа учета
      r_use( dir_server() + "hum_p", dir_server() + "hum_pc", "HUMAN" )
      Set Relation To kod_k into KART
      For xx := 0 To 2
        If iif( mn->tip_usl >= 0, xx == mn->tip_usl, .t. )
          Select HUMAN
          dbSeek( Str( xx, 1 ) + "1" + DToS( pdate_schet[ 5 ] ), .t. )
          Do While human->tip_usl == xx .and. human->date_close <= pdate_schet[ 6 ] .and. !Eof()
            If Inkey() == K_ESC
              fl_exit := .t. ; Exit
            Endif
            If f_is_uch( st_a_uch, human->lpu )
              s1_mnog_poisk( @c_view, @c_found )
            Endif
            Select HUMAN
            Skip
          Enddo
        Endif
        If fl_exit ; exit ; Endif
      Next
    Endif
    j := tmp->( LastRec() )
    Close databases
    If j == 0
      If !fl_exit
        func_error( 4, "Нет сведений!" )
      Endif
    Else
      mywait()
      Use ( tmp_file ) New Alias MN
      s1 := if( fl_summa, "  Сумма  ", "Стоимость" )
      s2 := if( fl_summa, " лечения ", "  услуг  " )
      arr_title := { ;
        "────────────────────────────────────────┬─────────", ;
        "             Ф.И.О. больного            │" + s1, ;
        "                                        │" + s2, ;
        "────────────────────────────────────────┴─────────" }
      If IsBit( mn->vid_doc, 1 )
        arr_title[ 1 ] += "┬────────"
        arr_title[ 2 ] += "│  Дата  "
        arr_title[ 3 ] += "│рождения"
        arr_title[ 4 ] += "┴────────"
      Endif
      If IsBit( mn->vid_doc, 2 )
        arr_title[ 1 ] += "┬────────────────────────"
        arr_title[ 2 ] += "│         Адрес          "
        arr_title[ 3 ] += "│                        "
        arr_title[ 4 ] += "┴────────────────────────"
      Endif
      If IsBit( mn->vid_doc, 3 )
        arr_title[ 1 ] += "┬────────"
        arr_title[ 2 ] += "│Окончан."
        arr_title[ 3 ] += "│лечения "
        arr_title[ 4 ] += "┴────────"
      Endif
      If IsBit( mn->vid_doc, 4 )
        arr_title[ 1 ] += "┬─────"
        arr_title[ 2 ] += "│Диаг-"
        arr_title[ 3 ] += "│ноз  "
        arr_title[ 4 ] += "┴─────"
      Endif
      If IsBit( mn->vid_doc, 5 )
        arr_title[ 1 ] += "┬───────────────────────"
        arr_title[ 2 ] += "│                       "
        arr_title[ 3 ] += "│     Список услуг      "
        arr_title[ 4 ] += "┴───────────────────────"
      Endif
      If IsBit( mn->vid_doc, 6 )
        arr_title[ 1 ] += "┬────────────────────────────"
        arr_title[ 2 ] += "│                            "
        arr_title[ 3 ] += "│       Услуги + врачи       "
        arr_title[ 4 ] += "┴────────────────────────────"
      Endif
      sh := Len( arr_title[ 1 ] )
      If sh <= 65
        sh := 65
        reg_print := 4
      Elseif sh <= 84
        reg_print := 5
      Elseif sh <= 120
        reg_print := 6
      Elseif sh <= 160
        reg_print := 5
      Else
        reg_print := 6
      Endif
      r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
      r_use( dir_server() + "uslugi",, "USL" )
      r_use( dir_server() + "mo_pers",, "PERSO" )
      r_use( dir_server() + "kartote2",, "KART2" )
      r_use( dir_server() + "kartote_",, "KART_" )
      r_use( dir_server() + "kartotek",, "KART" )
      Set Relation To RecNo() into KART_, To RecNo() into KART2
      r_use( dir_server() + "hum_p",, "HUMAN" )
      Set Relation To kod_k into KART
      Use ( cur_dir() + "tmp_k" ) new
      Use ( cur_dir() + "tmp" ) new
      Set Relation To kod into HUMAN
      Index On Upper( kart->fio ) + DToS( human->k_data ) to ( cur_dir() + "tmp" )
      //
      fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( "" )
      add_string( Center( Expand( "РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА" ), sh ) )
      titlen_uch( st_a_uch, sh )
      add_string( "" )
      add_string( " == ПАРАМЕТРЫ ПОИСКА ==" )
      If mn->date_lech > 0
        add_string( "Дата окончания лечения: " + pdate_lech[ 4 ] )
      Endif
      If mn->date_schet > 0
        add_string( "Дата закрытия л/учета: " + pdate_schet[ 4 ] )
      Endif
      If !Empty( much_doc )
        add_string( "Вид и номер учетного документа: " + much_doc )
      Endif
      If is_uchastok > 0
        If !Empty( mn->bukva )
          add_string( "Буква: " + mn->bukva )
        Endif
        If !Empty( mn->uchast )
          add_string( "Участок: " + init_uchast( arr_uchast ) )
        Endif
      Endif
      If !Empty( mfio )
        add_string( "ФИО: " + mfio )
      Endif
      If mn->inostran > 0
        add_string( "Документы иностранных граждан: " + ;
          inieditspr( A__MENUVERT, mm_da_net, mn->inostran ) )
      Endif
      If mn->gorod_selo > 0
        add_string( "Житель: " + ;
          inieditspr( A__MENUVERT, mm_g_selo, mn->gorod_selo ) )
      Endif
      If mn->mi_git > 0
        add_string( "Место жительства: " + ;
          inieditspr( A__MENUVERT, mm_mest, mn->mi_git ) )
      Endif
      If !Empty( mn->_okato )
        add_string( "Адрес регистрации (ОКАТО): " + ret_okato_ulica( '', mn->_okato ) )
      Endif
      If !Empty( madres )
        add_string( "Адрес: " + madres )
      Endif
      If !Empty( mmr_dol )
        add_string( "Место работы: " + mmr_dol )
      Endif
      If is_talon .and. mn->kategor > 0
        add_string( "Код категории льготы: " + ;
          inieditspr( A__MENUVERT, stm_kategor, mn->kategor ) )
      Endif
      If !Empty( mn->pol )
        add_string( "Пол: " + mn->pol )
      Endif
      If mn->vzros_reb >= 0
        add_string( "Возрастная принадлежность: " + ;
          inieditspr( A__MENUVERT, menu_vzros, mn->vzros_reb ) )
      Endif
      If !Empty( mn->god_r_min ) .or. !Empty( mn->god_r_max )
        If Empty( mn->god_r_min )
          add_string( "Лица, родившиеся до " + full_date( mn->god_r_max ) )
        Elseif Empty( mn->god_r_max )
          add_string( "Лица, родившиеся после " + full_date( mn->god_r_min ) )
        Else
          add_string( "Лица, родившиеся с " + ;
            full_date( mn->god_r_min ) + " по " + full_date( mn->god_r_max ) )
        Endif
      Endif
      If mn->rab_nerab >= 0
        add_string( Upper( inieditspr( A__MENUVERT, menu_rab, mn->rab_nerab ) ) )
      Endif
    /*
    if mn->mi_git >= 0
      add_string("Место жительства: "+;
                 inieditspr(A__MENUVERT, menu_mest, mn->mi_git))
    endif
    if mn->rajon_git > 0
      add_string("  Район: "+inieditspr(A__POPUPMENU, dir_server()+"rajon", mn->rajon_git))
    endif
    if mn->mest_inog >= 0
      add_string("Финансирование: "+;
                 inieditspr(A__MENUVERT, menu_mest, mn->mest_inog))
    endif
    if mn->rajon > 0
      add_string("  Район: "+inieditspr(A__POPUPMENU, dir_server()+"rajon", mn->rajon))
    endif    */
      If !Empty( mn->kod_diag )
        add_string( "Шифр заболевания: " + mn->kod_diag )
      Endif
      If yes_h_otd == 1 .and. mn->otd > 0
        add_string( "Отделение: " + ;
          inieditspr( A__POPUPMENU, dir_server() + "mo_otd", mn->otd ) )
      Endif
      If mn->tip_usl >= 0
        add_string( "Категория оплаты: " + ;
          inieditspr( A__MENUVERT, menu_plat, mn->tip_usl ) )
      Endif
      If mn->summa_min > 0 .or. mn->summa_max > 0
        If Empty( mn->summa_min )
          add_string( "Стоимость лечения менее " + lstr( mn->summa_max, 10, 2 ) )
        Elseif Empty( mn->summa_max )
          add_string( "Стоимость лечения более " + lstr( mn->summa_min, 10, 2 ) )
        Else
          add_string( "Стоимость лечения в диапазоне от " + ;
            lstr( mn->summa_min, 10, 2 ) + " до " + lstr( mn->summa_max, 10, 2 ) )
        Endif
      Endif
      If mn->otd_usl > 0
        add_string( "Отделение, в котором оказана услуга: " + ;
          inieditspr( A__POPUPMENU, dir_server() + "mo_otd", mn->otd_usl ) )
      Endif
      If mn->vr1 > 0
        add_string( "Врач, оказавший услугу(и): " + AllTrim( mn->vr ) )
      Endif
      If mn->isvr > 0
        add_string( "Код врача " + if( mn->isvr == 1, "не ", "" ) + "проставлен" )
      Endif
      If mn->as1 > 0
        add_string( "Ассистент, оказавший услугу(и): " + AllTrim( mn->as ) )
      Endif
      If mn->isas > 0
        add_string( "Код ассистента " + if( mn->isas == 1, "не ", "" ) + "проставлен" )
      Endif
      If mn->vras1 > 0
        add_string( "Человек, оказавший услугу(и): " + AllTrim( mn->vras ) )
      Endif
      If is_oplata != 7
        If mn->med1 > 0
          add_string( "Медсестра: " + mn->med )
        Endif
        If mn->san1 > 0
          add_string( "Санитарка: " + mn->san )
        Endif
      Endif
      If mn->uslugi > 0
        l := 0
        AEval( arr_usl, {| x| l := Max( l, Len( RTrim( x[ 3 ] ) ) ) } )
        add_string( PadR( "Оказанные услуги:", l + 13 ) + "|Кол-во| Ст-ть" )
        AEval( arr_usl, {| x| add_string( "  " + x[ 2 ] + " " + ;
          PadR( x[ 3 ], l ) + "|" + put_val( x[ 4 ], 5 ) + " |" + put_kop( x[ 5 ], 8 ) ) } )
      Endif
      If mn->slug_usl > 0
        add_string( "Служба, в которой оказаны услуги: " + mslugba[ 2 ] )
      Endif
      add_string( "" )
      add_string( " == РЕЗУЛЬТАТЫ ПОИСКА ==" )
      add_string( "Итого количество больных: " + lstr( tmp_k->( LastRec() ) ) + " чел." )
      add_string( "Итого листов учета: " + lstr( tmp->( LastRec() ) ) + ;
        " чел.  на сумму  " + lput_kop( ssumma, .t. ) + " руб." )
      add_string( "" )
      AEval( arr_title, {| x| add_string( x ) } )
      Keyboard ""
      Select TMP
      Go Top
      Do While !Eof()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        s1 := Left( kart->fio, 40 )
        s3 := ""
        //
        s1 += put_kope( tmp->stoim, 10 )
        If mem_kodkrt == 2
          s2 := " ["
          If is_uchastok > 0
            s2 += AllTrim( kart->bukva )
            s2 += lstr( kart->uchast, 2 ) + "/"
          Endif
          If is_uchastok == 1
            s2 += lstr( kart->kod_vu )
          Elseif is_uchastok == 3
            s2 += AllTrim( kart2->kod_AK )
          Else
            s2 += lstr( kart->kod )
          Endif
          s2 += "] "
        Else
          s2 := " "
        Endif
        If !Empty( mmr_dol )
          s2 += LTrim( kart->mr_dol )
        Endif
        s2 := PadR( s2, 50 )
        s3 := PadR( s3, 50 )
        //
        If IsBit( mn->vid_doc, 1 )
          s1 += " " + date_8( kart->date_r )
          s2 += Space( 9 )
          s3 += Space( 9 )
        Endif
        //
        If IsBit( mn->vid_doc, 2 )
          perenos( a_diagnoz, kart->adres, 24 )
          s1 += " " + PadR( AllTrim( a_diagnoz[ 1 ] ), 24 )
          s2 += " " + PadR( AllTrim( a_diagnoz[ 2 ] ), 24 )
          s3 += " " + PadR( AllTrim( a_diagnoz[ 3 ] ), 24 )
        Endif
        //
        If IsBit( mn->vid_doc, 3 )
          s1 += " " + date_8( human->k_data )
          s2 += Space( 9 )
          s3 += Space( 9 )
        Endif
        //
        If IsBit( mn->vid_doc, 4 )
          s1 += " " + PadC( AllTrim( human->kod_diag ), 5 )
          s2 += Space( 6 )
          s3 += Space( 6 )
        Endif
        //
        If IsBit( mn->vid_doc, 5 )
          tmp1 := "" ; aup := {}
          Select HU
          find ( Str( human->( RecNo() ), 7 ) )
          Do While hu->kod == human->( RecNo() ) .and. !Eof()
            If hu->kol > 0
              Select USL
              Goto ( hu->u_kod )
              lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
              AAdd( aup, { if( Empty( lshifr1 ), usl->shifr, lshifr1 ), ;
                hu->kol } )
            Endif
            Select HU
            Skip
          Enddo
          ASort( aup,,, {| x, y| fsort_usl( x[ 1 ] ) < fsort_usl( y[ 1 ] ) } )
          If mn->uslugi > 0
            bup := {}
            For i := 1 To Len( arr_usl )
              If ( l := AScan( aup, {| x| x[ 1 ] == arr_usl[ i, 2 ] } ) ) > 0
                AAdd( bup, AClone( aup[ l ] ) )
                ADel( aup, l ) ; ASize( aup, Len( aup ) -1 )
              Endif
            Next
            For i := Len( bup ) To 1 Step -1
              AAdd( aup, nil ) ; AIns( aup, 1 ) ; aup[ 1 ] := bup[ i ]
            Next
          Endif
          For i := 1 To Len( aup )
            tmp1 += AllTrim( aup[ i, 1 ] ) + "(" + lstr( aup[ i, 2 ] ) + "),"
          Next
          tmp1 := Left( tmp1, Len( tmp1 ) -1 )
          k_usl := perenos( a_uslugi, tmp1, 23, "," )
          s1 += " " + PadC( AllTrim( a_uslugi[ 1 ] ), 23 )
          s2 += " " + PadC( AllTrim( a_uslugi[ 2 ] ), 23 )
          s3 += " " + PadC( AllTrim( a_uslugi[ 3 ] ), 23 )
        Endif
        //
        If IsBit( mn->vid_doc, 6 )
          tmp1 := "" ; aup := {}
          Select HU
          find ( Str( human->( RecNo() ), 7 ) )
          Do While hu->kod == human->( RecNo() ) .and. !Eof()
            If hu->kol > 0
              Select USL
              Goto ( hu->u_kod )
              lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
              AAdd( aup, { if( Empty( lshifr1 ), usl->shifr, lshifr1 ), ;
                hu->kol, hu->kod_vr } )
            Endif
            Select HU
            Skip
          Enddo
          // перекодируем врача
          For i := 1 To Len( aup )
            Select PERSO
            Goto ( aup[ i, 3 ] )
            aup[ i, 3 ]  := perso->tab_nom
          Next
          //
          ASort( aup,,, {| x, y| fsort_usl( x[ 1 ] ) < fsort_usl( y[ 1 ] ) } )
          If mn->uslugi > 0
            bup := {}
            For i := 1 To Len( arr_usl )
              If ( l := AScan( aup, {| x| x[ 1 ] == arr_usl[ i, 2 ] } ) ) > 0
                AAdd( bup, AClone( aup[ l ] ) )
                ADel( aup, l ) ; ASize( aup, Len( aup ) -1 )
              Endif
            Next
            For i := Len( bup ) To 1 Step -1
              AAdd( aup, nil ) ; AIns( aup, 1 ) ; aup[ 1 ] := bup[ i ]
            Next
          Endif
          For i := 1 To Len( aup )
            tmp1 += AllTrim( aup[ i, 1 ] ) + "(" + lstr( aup[ i, 2 ] ) + ")[" + lstr( aup[ i, 3 ] ) + "],"
          Next
          tmp1 := Left( tmp1, Len( tmp1 ) -1 )
          k_usl := perenos( a_uslugi, tmp1, 28, "," )
          s1 += " " + PadC( AllTrim( a_uslugi[ 1 ] ), 28 )
          s2 += " " + PadC( AllTrim( a_uslugi[ 2 ] ), 28 )
          s3 += " " + PadC( AllTrim( a_uslugi[ 3 ] ), 28 )
        Endif
        //
        add_string( s1 )
        add_string( s2 )
        add_string( s3 )
        If ( IsBit( mn->vid_doc, 5 ) .or. IsBit( mn->vid_doc, 6 ) ) .and. k_usl > 3
          For i := 4 To k_usl
            s1 := Space( 50 )
            If IsBit( mn->vid_doc, 1 ) ; s1 += Space( 9 ) ; Endif
            If IsBit( mn->vid_doc, 2 ) ; s1 += Space( 25 ); Endif
            If IsBit( mn->vid_doc, 3 ) ; s1 += Space( 9 ) ; Endif
            If IsBit( mn->vid_doc, 4 ) ; s1 += Space( 6 ) ; Endif
            If IsBit( mn->vid_doc, 5 )
              add_string( s1 + " " + PadC( AllTrim( a_uslugi[ i ] ), 23 ) )
            Else
              add_string( s1 + " " + PadC( AllTrim( a_uslugi[ i ] ), 28 ) )
            Endif
          Next
        Endif
        Select TMP
        Skip
      Enddo
      add_string( Replicate( "─", sh ) )
      If fl_exit
        add_string( "*** " + Expand( "ОПЕРАЦИЯ ПРЕРВАНА" ) )
      Else
        add_string( "  Итого листов учета : " + lstr( tmp->( LastRec() ) ) + ;
          " чел.  на сумму  " + lput_kop( ssumma, .t. ) + " руб." )
      Endif
      FClose( fp )
      Close databases
      viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
    Endif
  Endif
  Close databases
  RestScreen( buf ) ; SetColor( tmp_color )

  Return Nil

//
Function pwrite_mn_p( k )

  Local fl := .t.

  If k == 1
    If emptyall( mdate_lech, mdate_schet )
      fl := func_error( 4, "Обязательно должно быть заполнено хотя бы одно из первых двух полей даты!" )
    Elseif mvr1 > 0 .and. m1isvr > 0
      fl := func_error( 4, "Недопустимое сочетание полей < Код врача >!" )
    Elseif mas1 > 0 .and. m1isas > 0
      fl := func_error( 4, "Недопустимое сочетание полей < Код ассистента >!" )
    Endif
  Endif

  Return fl

// 22.03.17
Static Function s1_mnog_poisk( cv, cf )

  Local i, fl := .t., flu := .f., mkol, mstoim := 0, luch_doc := "", arr

  ++cv
  If fl .and. mn->date_lech > 0 .and. p_regim != 1
    fl := Between( human->k_data, pdate_lech[ 5 ], pdate_lech[ 6 ] )
  Endif
  If fl .and. mn->date_schet > 0 .and. p_regim != 2
    fl := Between( human->k_data, pdate_schet[ 5 ], pdate_schet[ 6 ] )
  Endif
  If fl .and. !Empty( much_doc )
    If !emptyall( kart->bukva, kart->uchast, kart->kod_vu )
      If !Empty( kart->bukva )
        luch_doc += kart->bukva
      Endif
      luch_doc += lstr( kart->uchast, 2 )
      If kart->kod_vu > 0
        luch_doc += "/" + lstr( kart->kod_vu )
      Endif
    Endif
    fl := Like( much_doc, luch_doc )
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->uchast )
    fl := f_is_uchast( arr_uchast, kart->uchast )
  Endif
  If fl .and. !Empty( mfio )
    fl := Like( mfio, Upper( kart->fio ) )
  Endif
  If fl .and. mn->inostran > 0
    If mn->inostran == 1 // нет
      // 9,21,22,23,24
      fl := !equalany( kart_->vid_ud, 9, 21, 22, 23, 24 )
    Else
      fl := equalany( kart_->vid_ud, 9, 21, 22, 23, 24 )
    Endif
  Endif
  If fl .and. mn->mi_git > 0
    If mn->mi_git == 1
      fl := ( Left( kart_->okatog, 2 ) == '18' )
    Else
      fl := !( Left( kart_->okatog, 2 ) == '18' )
    Endif
  Endif
  If fl .and. mn->gorod_selo > 0
    If mn->gorod_selo == 1
      fl := !f_is_selo( kart_->gorod_selo, kart_->okatog )
    Else
      fl := f_is_selo( kart_->gorod_selo, kart_->okatog )
    Endif
  Endif
  If fl .and. !Empty( mn->_okato )
    s := mn->_okato
    For i := 1 To 3
      If Right( s, 3 ) == '000'
        s := Left( s, Len( s ) -3 )
      Else
        Exit
      Endif
    Next
    fl := ( Left( kart_->okatog, Len( s ) ) == s )
  Endif
  If fl .and. !Empty( madres )
    fl := Like( madres, Upper( kart->adres ) )
  Endif
  If fl .and. !Empty( mmr_dol )
    fl := Like( mmr_dol, Upper( kart->mr_dol ) )
  Endif
  If fl .and. is_talon .and. mn->kategor > 0
    fl := ( mn->kategor == kart_->kategor )
  Endif
  If fl .and. !Empty( mn->pol )
    fl := ( kart->pol == mn->pol )
  Endif
  If fl .and. mn->vzros_reb >= 0
    fl := ( kart->vzros_reb == mn->vzros_reb )
  Endif
  If fl .and. !Empty( mn->god_r_min )
    fl := ( mn->god_r_min <= kart->date_r )
  Endif
  If fl .and. !Empty( mn->god_r_max )
    fl := ( kart->date_r <= mn->god_r_max )
  Endif
  If fl .and. mn->rab_nerab >= 0
    fl := ( kart->rab_nerab == mn->rab_nerab )
  Endif
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
  If fl .and. !Empty( mn->kod_diag )
    fl := ( mn->kod_diag == human->KOD_DIAG )
  Endif
  If fl .and. yes_h_otd == 1 .and. mn->otd > 0
    fl := ( human->otd == mn->otd )
  Endif
  If fl .and. mn->tip_usl >= 0
    fl := ( human->tip_usl == mn->tip_usl )
  Endif
  If fl .and. mn->summa_min > 0
    fl := ( mn->summa_min <= human->cena )
  Endif
  If fl .and. mn->summa_max > 0
    fl := ( human->cena <= mn->summa_max )
  Endif
  If fl
    If flag_hu
      mkol := 0
      Select HU
      find ( Str( human->( RecNo() ), 7 ) )
      Do While hu->kod == human->( RecNo() )
        flu := .t.
        If flu .and. mn->otd_usl > 0
          flu := ( hu->otd == mn->otd_usl )
        Endif
        If flu .and. mn->vras1 > 0
          flu := ( hu->kod_vr == mn->vras1 .or. hu->kod_as == mn->vras1 )
        Endif
        If flu .and. mn->vr1 > 0
          flu := ( hu->kod_vr == mn->vr1 )
        Endif
        If flu .and. mn->isvr > 0
          If mn->isvr == 1  // нет
            flu := ( hu->kod_vr == 0 )
          Else
            flu := ( hu->kod_vr > 0 )
          Endif
        Endif
        If flu .and. mn->as1 > 0
          flu := ( hu->kod_as == mn->as1 )
        Endif
        If flu .and. mn->isas > 0
          If mn->isas == 1  // нет
            flu := ( hu->kod_as == 0 )
          Else
            flu := ( hu->kod_as > 0 )
          Endif
        Endif
        If is_oplata != 7
          If flu .and. mn->med1 > 0
            flu := equalany( mn->med1, hu->med1, hu->med2, hu->med3 )
          Endif
          If flu .and. mn->san1 > 0
            flu := equalany( mn->san1, hu->san1, hu->san2, hu->san3 )
          Endif
        Endif
        If flu .and. mn->slug_usl > 0
          flu := ( usl->slugba == mn->slug_usl )
        Endif
        If flu .and. mn->uslugi > 0
          i := AScan( arr_usl, {| x| x[ 1 ] == hu->u_kod } )
          If ( flu := ( i > 0 ) )
            arr_usl[ i, 4 ] += hu->kol
            arr_usl[ i, 5 ] += hu->stoim
          Endif
        Endif
        If flu
          mkol += hu->kol
          mstoim += hu->stoim
        Endif
        Skip
      Enddo
      If emptyall( mkol, mstoim )
        fl := .f.
      Endif
    Else
      mstoim := human->cena
    Endif
  Endif
  If fl
    Select TMP_K
    find ( Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_k->kod_k := human->kod_k
    Endif
    Select TMP
    Append Blank
    tmp->kod := human->( RecNo() )
    tmp->stoim := mstoim
    ssumma += mstoim
    If++cf % 2000 == 0
      Commit
    Endif
  Endif
  @ 24, 1 Say lstr( cv ) Color cColorSt2Msg
  @ Row(), Col() Say "/" Color "W/R"
  @ Row(), Col() Say lstr( cf ) Color cColorStMsg

  Return Nil

//
Function pl_napr_vrach()

  Local i, j, arr, begin_date, end_date, s, buf := save_row( MaxRow() ), ;
    fl_exit := .f., sh, HH := 60, reg_print, speriod, ;
    arr_title, name_file := cur_dir() + "napr_vr.txt", arr_m, adbf

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  speriod := arr_m[ 4 ]
  begin_date := arr_m[ 7 ]
  end_date := arr_m[ 8 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  adbf := { ;
    { "KOD_VR",     "N",      4,      0 }, ;  // код врача
  { "KOL",    "N",      6,      0 }, ;  // количество больных
    { "SUMMA",    "N",     14,      2 };   // общая стоимость
  }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" )
  Index On Str( kod_vr, 4 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUMAN" )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If human->kod_vr > 0 .and. f_is_uch( st_a_uch, human->lpu )
      Select TMP
      find ( Str( human->kod_vr, 4 ) )
      If !Found()
        Append Blank
        Replace kod_vr With human->kod_vr
      Endif
      tmp->kol++
      tmp->summa += human->cena
    Endif
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    reg_print := 1
    arr_title := { ;
      "──────────────────────────────────────────────┬─────┬───────────", ;
      "                                              │ Кол.│   Сумма   ", ;
      "                    Врач                      │больн│  лечения  ", ;
      "──────────────────────────────────────────────┴─────┴───────────" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( Center( "Врачи, направившие на платное лечение", sh ) )
    titlen_uch( st_a_uch, sh )
    add_string( Center( speriod, sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    r_use( dir_server() + "mo_uch",, "UCH" )
    r_use( dir_server() + "mo_otd",, "OTD" )
    Set Relation To kod_lpu into UCH
    r_use( dir_server() + "mo_pers",, "perso" )
    Set Relation To otd into OTD
    Use ( cur_dir() + "tmp" ) new
    Set Relation To kod_vr into perso
    Index On Upper( uch->name ) + Upper( otd->name ) + Str( perso->otd, 3 ) + Upper( perso->fio ) to ( cur_dir() + "tmp" )
    old_otd := kol_otd := sum_otd := j := 0
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If old_otd != perso->otd
        If old_otd != 0
          add_string( Space( sh -20 ) + Replicate( "-", 20 ) )
          add_string( PadL( "Итого: " + put_val( kol_otd, 6 ) + put_kope( sum_otd, 12 ), sh ) )
          kol_otd := sum_otd := 0
        Endif
        s := ""
        If count_uch > 1
          s := "[" + AllTrim( uch->name ) + "] " + Upper( AllTrim( otd->name ) )
        Endif
        add_string( Space( 10 ) + s )
      Endif
      s := Str( ++j, 3 ) + ". "
      s += "[" + lstr( perso->tab_nom ) + "] "
      s += AllTrim( perso->fio )
      add_string( PadR( s, 46 ) + put_val( tmp->kol, 6 ) + put_kope( tmp->summa, 12 ) )
      old_otd := perso->otd
      kol_otd += tmp->kol
      sum_otd += tmp->summa
      Select TMP
      Skip
    Enddo
    If old_otd != 0
      add_string( Space( sh -20 ) + Replicate( "-", 20 ) )
      add_string( PadL( "Итого: " + put_val( kol_otd, 6 ) + put_kope( sum_otd, 12 ), sh ) )
    Endif
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

// по направившим врачам + услуги
Function pl_napr2vrach()

  Local i, j, arr[ 2 ], begin_date, end_date, s, buf := save_row( MaxRow() ), ;
    fl_exit := .f., sh, HH := 60, reg_print, speriod, ;
    arr_title, name_file := cur_dir() + "napr_vr2.txt", arr_m, adbf, mperso

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  speriod := arr_m[ 4 ]
  begin_date := arr_m[ 7 ]
  end_date := arr_m[ 8 ]
  If ( mperso := input_kperso() ) == NIL
    mywait()
    mperso := {}
    r_use( dir_server() + "mo_pers",, "perso" )
    Go Top
    Do While !Eof()
      If perso->kod > 0
        AAdd( mperso, { perso->kod, "" } )
      Endif
      Skip
    Enddo
    perso->( dbCloseArea() )
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  adbf := { ;
    { "U_KOD",    "N",      4,      0 }, ;  // код услуги
  { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
    { "U_NAME",     "C",     65,      0 }, ;  // наименование услуги
  { "TAB_NOM",    "N",      5,      0 }, ;  // таб.номер врача
    { "KOD_VR",     "N",      4,      0 }, ;  // код врача
  { "FIO",        "C",     50,      0 }, ;  // Ф.И.О. врача
    { "KOL",    "N",      6,      0 }, ;  // количество услуг
  { "STOIM",    "N",     14,      2 };   // итоговая стоимость услуги
    }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod_vr, 4 ) + Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  r_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUMAN" )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If human->kod_vr > 0 .and. f_is_uch( st_a_uch, human->lpu )
      Select HU
      find ( Str( human->( RecNo() ), 7 ) )
      Do While hu->kod == human->( RecNo() )
        Select TMP
        find ( Str( human->kod_vr, 4 ) + Str( hu->u_kod, 4 ) )
        If !Found()
          Append Blank
          tmp->kod_vr := human->kod_vr
          tmp->u_kod := hu->u_kod
        Endif
        tmp->kol += hu->kol
        tmp->stoim += hu->stoim
        Select HU
        Skip
      Enddo
    Endif
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "mo_pers",, "PERSO" )
    Set( _SET_DELETED, .f. )
    Use ( cur_dir() + "tmp" ) new
    Go Top
    Do While !Eof()
      Select USL
      Goto ( tmp->u_kod )
      If usl->kod <= 0 .or. Deleted() .or. Eof()
        Select TMP
        Delete
      Else
        tmp->u_shifr := usl->shifr
        tmp->u_name := usl->name
      Endif
      Select PERSO
      Goto ( tmp->kod_vr )
      If Deleted() .or. Eof()
        Select TMP
        Delete
      Else
        tmp->fio := perso->fio
        tmp->tab_nom := perso->tab_nom
      Endif
      Select TMP
      Skip
    Enddo
    Set( _SET_DELETED, .t. )
    Select TMP
    Index On Upper( fio ) + Str( kod_vr, 4 ) + fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
    reg_print := 2
    arr_title := { ;
      "──────────────────────────────────────────────────────────┬──────┬──────────────", ;
      "                                                          │Кол-во│   Стоимость  ", ;
      "                                                          │ услуг│     услуг    ", ;
      "──────────────────────────────────────────────────────────┴──────┴──────────────" }
    sh := Len( arr_title[ 1 ] )
    len_n := 58
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( Center( "Врачи, направившие на платное лечение", sh ) )
    titlen_uch( st_a_uch, sh )
    add_string( Center( speriod, sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    old_perso := -1  // для печати Ф.И.О. в начале
    old_fio := "[" + lstr( tmp->tab_nom ) + "] " + tmp->fio
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If old_perso != tmp->kod_vr
        If old_perso > 0
          add_string( Replicate( "─", sh ) )
          If !emptyall( skol, sstoim )
            add_string( PadL( "И Т О Г О :  ", len_n ) + ;
              Str( skol, 7, 0 ) + ;
              put_kope( sstoim, 15 ) )
          Endif
        Endif
        skol := sstoim := 0
        add_string( "" )
        add_string( Space( 5 ) + lstr( tmp->tab_nom ) + ". " + Upper( RTrim( tmp->fio ) ) )
      Endif
      skol += tmp->kol
      sstoim += tmp->stoim
      j := perenos( arr, tmp->u_shifr + " " + tmp->u_name, len_n )
      old_perso := tmp->kod_vr
      add_string( PadR( arr[ 1 ], len_n ) + ;
        Str( tmp->kol, 7, 0 ) + ;
        put_kope( tmp->stoim, 15 ) )
      For i := 2 To j
        add_string( Space( 11 ) + arr[ i ] )
      Next
      Select TMP
      Skip
    Enddo
    add_string( Replicate( "─", sh ) )
    If !emptyall( skol, sstoim )
      add_string( PadL( "И Т О Г О :  ", len_n ) + ;
        Str( skol, 7, 0 ) + ;
        put_kope( sstoim, 15 ) )
    Endif
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

//
Function ob_ved_vz()

  Local i, j, k, fl, fl_exit := .f., buf := save_row( MaxRow() ), ;
    t_arr[ BR_LEN ], blk, fl1 := .f., fl2 := .f.
  Private arr_m, muslovie, ouslovie, p_sb, p_se, a_t[ 4 ]

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  p_sb := date_8( arr_m[ 5 ] )
  p_se := date_8( arr_m[ 6 ] )
  a_t[ 1 ] := "──────────────────────────────┬────────────┬────────────┬────────────┬────────────"
  a_t[ 2 ] := "                              │  Сальдо на │            │            │  Сальдо на "
  a_t[ 3 ] := "                              │  " + p_sb + "г.│    Дебет   │    Кредит  │  " + p_se + "г."
  a_t[ 4 ] := "──────────────────────────────┴────────────┴────────────┴────────────┴────────────"
  //
  dbCreate( cur_dir() + "tmp", { { "kod_k", "N", 7, 0 }, ; // код больного по картотеке
  { "pr_smo", "N", 6, 0 }, ; // код предприятия / СМО
  { "SALDO1", "N", 13, 2 }, ;
    { "DEBET", "N", 13, 2 }, ;
    { "KREDIT", "N", 13, 2 }, ;
    { "SALDO2", "N", 13, 2 } } ) //
  dbCreate( cur_dir() + "tmp1", { { "name", "C", 30, 0 }, ; // наименование предприятия
  { "tip_usl", "N", 1, 0 }, ; // 2-взаимозачет, 1-добр.СМО
  { "pr_smo", "N", 6, 0 }, ; // код предприятия / СМО
  { "SALDO1", "N", 13, 2 }, ;
    { "DEBET", "N", 13, 2 }, ;
    { "KREDIT", "N", 13, 2 }, ;
    { "SALDO2", "N", 13, 2 } } ) //
  r_use( dir_server() + "p_pr_vz",, "PRED" )
  r_use( dir_server() + "p_d_smo",, "SMO" )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( pr_smo, 6 ) + Str( kod_k, 7 ) to ( cur_dir() + "tmp" )
  Use ( cur_dir() + "tmp1" ) new
  Index On Str( tip_usl, 1 ) + Str( pr_smo, 6 ) to ( cur_dir() + "tmp1" )
  r_use( dir_server() + "hum_p",, "HP" )
  Index On kod_k to ( cur_dir() + "tmp_hp" ) ;
    For equalany( hp->tip_usl, 1, 2 ) .and. hp->k_data <= arr_m[ 6 ] progress
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  Go Top
  Do While !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    Select TMP1
    find ( Str( hp->tip_usl, 1 ) + Str( hp->pr_smo, 6 ) )
    If !Found()
      Append Blank
      tmp1->tip_usl := hp->tip_usl
      tmp1->pr_smo  := hp->pr_smo
      If hp->tip_usl == 1
        smo->( dbGoto( hp->pr_smo ) )
        tmp1->name := smo->name
      Else
        pred->( dbGoto( hp->pr_smo ) )
        tmp1->name := pred->name
      Endif
    Endif
    If hp->k_data < arr_m[ 5 ]
      tmp1->saldo1 += hp->cena
    Else
      tmp1->debet += hp->cena
    Endif
    If hp->tip_usl == 1  // добровольное страхование
      Select TMP
      find ( Str( hp->pr_smo, 6 ) + Str( hp->kod_k, 7 ) )
      If !Found()
        Append Blank
        tmp->kod_k  := hp->kod_k
        tmp->pr_smo := hp->pr_smo
      Endif
      If hp->k_data < arr_m[ 5 ]
        tmp->saldo1 += hp->cena
      Else
        tmp->debet += hp->cena
      Endif
    Endif
    Select HP
    Skip
  Enddo
  //
  r_use( dir_server() + "plat_vz",, "OPL" )
  Go Top
  Do While !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If opl->date_opl <= arr_m[ 6 ]
      Select TMP1
      find ( Str( opl->tip, 1 ) + Str( opl->pr_smo, 6 ) )
      If !Found()
        Append Blank
        tmp1->tip_usl := opl->tip
        tmp1->pr_smo  := opl->pr_smo
        If opl->tip == 1
          smo->( dbGoto( opl->pr_smo ) )
          tmp1->name := smo->name
        Else
          pred->( dbGoto( opl->pr_smo ) )
          tmp1->name := pred->name
        Endif
      Endif
      If opl->date_opl < arr_m[ 5 ]
        tmp1->saldo1 -= opl->summa_opl
      Else
        tmp1->kredit += opl->summa_opl
      Endif
      If opl->tip == 1  // добровольное страхование
        Select TMP
        find ( Str( opl->pr_smo, 6 ) + Str( opl->kod_k, 7 ) )
        If !Found()
          Append Blank
          tmp->kod_k  := opl->kod_k
          tmp->pr_smo := opl->pr_smo
          If tmp->( LastRec() ) % 5000 == 0
            Commit
          Endif
        Endif
        If opl->date_opl < arr_m[ 5 ]
          tmp->saldo1 -= opl->summa_opl
        Else
          tmp->kredit += opl->summa_opl
        Endif
      Endif
    Endif
    Select OPL
    Skip
  Enddo
  mywait()
  Select TMP1
  Delete For emptyall( SALDO1, DEBET, KREDIT )
  Pack
  If ( j := tmp1->( LastRec() ) ) > 0
    dbEval( {|| iif( tmp1->tip_usl == 1, ( fl1 := .t. ), ( fl2 := .t. ) ), ;
      tmp1->saldo2 := tmp1->saldo1 + tmp1->debet - tmp1->kredit, ;
      iif( Empty( name ) .and. tip_usl == 1, ( tmp1->name := " = без ДСМО = " ), nil ), ;
      iif( Empty( name ) .and. tip_usl == 2, ( tmp1->name := " = без предприятия = " ), nil ) } )
    //
    Select TMP
    Delete For emptyall( SALDO1, DEBET, KREDIT )
    Pack
    dbEval( {|| tmp->saldo2 := tmp->saldo1 + tmp->debet - tmp->kredit } )
  Endif
  Close databases
  rest_box( buf )
  If fl_exit
    // ничего
  Elseif j == 0
    func_error( 4, "Нет сведений по ДМС и взаимозачету " + arr_m[ 4 ] )
  Else
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_BOTTOM ] := MaxRow() -1
    t_arr[ BR_LEFT ] := 0
    t_arr[ BR_RIGHT ] := 79
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_TITUL ] := "Оборотная ведомость " + arr_m[ 4 ]
    If fl1
      t_arr[ BR_TITUL ] += " (добр/страх.)"
    Endif
    If fl2
      t_arr[ BR_TITUL ] += " (в/зачет)"
    Endif
    t_arr[ BR_TITUL_COLOR ] := "BG+/GR"
    t_arr[ BR_ARR_BROWSE ] := { "═", "░", "═", "N/BG,W+/N,B/BG,W+/B", .t., 0 }
    blk := {|| iif( tip_usl == 1, { 1, 2 }, { 3, 4 } ) }
    t_arr[ BR_COLUMN ] := { { Center( "Наименование", 30 ), {|| tmp1->name }, blk }, ;
      { " Сальдо на; " + p_sb, {|| put_kop( saldo1, 11 ) }, blk }, ;
      { "  Дебет", {|| put_kop( debet, 11 ) }, blk }, ;
      { "  Кредит", {|| put_kop( kredit, 11 ) }, blk }, ;
      { " Сальдо на; " + p_se, {|| put_kop( saldo2, 11 ) }, blk } }
    t_arr[ BR_EDIT ] := {| nk, ob| f1ob_ved_vz( nk, ob, "edit" ) }
    t_arr[ BR_STAT_MSG ] := {|| ;
      status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F9>^ - печать" ) }
    Use ( cur_dir() + "tmp1" ) new
    Index On Upper( name ) to ( cur_dir() + "tmp1" )
    Go Top
    edit_browse( t_arr )
    Close databases
    rest_box( buf )
  Endif

  Return Nil

//
Function f1ob_ved_vz( nKey, oBrow, regim )

  Local ret := -1, buf, fl := .f., rec, tmp_color, i, j, ;
    s, sh, HH := 58, reg_print := 2, arr_title, name_file := cur_dir() + "ob_ved.txt"

  Do Case
  Case regim == "edit"
    Do Case
    Case nKey == K_F9
      rec := tmp1->( RecNo() )
      buf := save_row( MaxRow() )
      sh := Len( a_t[ 1 ] )
      fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
      r_use( dir_server() + "organiz",, "ORG" )
      add_string( AllTrim( org->name ) )
      org->( dbCloseArea() )
      add_string( "" )
      s := "Оборотная ведомость по ДМС и взаимозачету"
      add_string( Center( s, sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( "" )
      AEval( a_t, {| x| add_string( x ) } )
      ss1 := sd := sk := ss2 := 0
      Select TMP1
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( a_t, {| x| add_string( x ) } )
        Endif
        add_string( tmp1->name + put_kope( tmp1->saldo1, 13 ) + ;
          put_kope( tmp1->debet, 13 ) + ;
          put_kope( tmp1->kredit, 13 ) + ;
          put_kope( tmp1->saldo2, 13 ) )
        ss1 += tmp1->saldo1
        sd  += tmp1->debet
        sk  += tmp1->kredit
        ss2 += tmp1->saldo2
        Skip
      Enddo
      add_string( Replicate( "─", sh ) )
      add_string( PadL( "И Т О Г О : ", 30 ) + put_kope( ss1, 13 ) + ;
        put_kope( sd, 13 ) + ;
        put_kope( sk, 13 ) + ;
        put_kope( ss2, 13 ) )
      FClose( fp )
      viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
      Select TMP1
      Goto ( rec )
    Case nKey == K_ENTER .and. tmp1->tip_usl == 1  // добр.страхование
      f2ob_ved_vz()
      Select TMP1
    Case nKey == K_ENTER .and. tmp1->tip_usl == 2  // взаимозачет
      glob_pr_vz := { tmp1->pr_smo, AllTrim( tmp1->name ) }
      muslovie := "hp->tip_usl==2 .and. hp->pr_smo==glob_pr_vz[1]"
      ouslovie := "opl->tip==2 .and. opl->pr_smo==glob_pr_vz[1]"
      f4ob_ved_vz( 2 )
      Select TMP1
    Endcase
  Endcase

  Return ret

//
Function f2ob_ved_vz()

  Local i, j, k, fl, buf := save_row( MaxRow() ), t_arr[ BR_LEN ]

  mywait()
  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -1
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := "Об.ведомость: " + AllTrim( tmp1->name ) + " " + arr_m[ 4 ]
  t_arr[ BR_TITUL_COLOR ] := "BG+/GR"
  t_arr[ BR_ARR_BROWSE ] := { "═", "░", "═", "N/BG,W+/N,B/BG,W+/B", .t., 0 }
  n := 30
  t_arr[ BR_COLUMN ] := { { Center( "Ф.И.О.", n ), {|| PadR( kart->fio, n ) } }, ;
    { " Сальдо на; " + p_sb, {|| put_kop( saldo1, 11 ) } }, ;
    { "  Дебет", {|| put_kop( debet, 11 ) } }, ;
    { "  Кредит", {|| put_kop( kredit, 11 ) } }, ;
    { " Сальдо на; " + p_se, {|| put_kop( saldo2, 11 ) } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f3ob_ved_vz( nk, ob, "edit" ) }
  t_arr[ BR_STAT_MSG ] := {|| ;
    status_key( "^<Esc>^ выход;  ^<Enter>^ оборотка по человеку;  ^<F8>^ полная оборотка;  ^<F9>^ печать" ) }
  r_use( dir_server() + "kartotek",, "KART" )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Set Relation To kod_k into KART
  Index On Upper( kart->fio ) to ( cur_dir() + "tmp" ) For tmp1->pr_smo == tmp->pr_smo
  Go Top
  edit_browse( t_arr )
  tmp->( dbCloseArea() )
  kart->( dbCloseArea() )
  rest_box( buf )

  Return Nil

//
Function f3ob_ved_vz( nKey, oBrow, regim )

  Local ret := -1, buf, fl := .f., rec, tmp_color, i, j, k, t_arr[ 2 ], ;
    s, sh, HH := 58, reg_print := 2, arr_title, name_file := cur_dir() + "ob_ved.txt"

  Do Case
  Case regim == "edit"
    Do Case
    Case nKey == K_F8
      rec := tmp->( RecNo() )
      Set Relation To
      kart->( dbCloseArea() )
      glob_d_smo := { tmp1->pr_smo, AllTrim( tmp1->name ) }
      muslovie := "hp->tip_usl==1 .and. hp->pr_smo==glob_d_smo[1]"
      ouslovie := "opl->tip==1 .and. opl->pr_smo==glob_d_smo[1]"
      f4ob_ved_vz( 1 )
      r_use( dir_server() + "kartotek",, "KART" )
      Select TMP
      Set Relation To kod_k into KART
      Goto ( rec )
    Case nKey == K_F9
      rec := tmp->( RecNo() )
      buf := save_row( MaxRow() )
      sh := Len( a_t[ 1 ] )
      fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
      r_use( dir_server() + "organiz",, "ORG" )
      add_string( AllTrim( org->name ) )
      org->( dbCloseArea() )
      add_string( "" )
      s := "Оборотная ведомость по: " + AllTrim( tmp1->name )
      add_string( Center( s, sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( "" )
      AEval( a_t, {| x| add_string( x ) } )
      ss1 := sd := sk := ss2 := 0
      Select TMP
      Go Top
      Do While !Eof()
        If verify_ff( HH, .t., sh )
          AEval( a_t, {| x| add_string( x ) } )
        Endif
        k := perenos( t_arr, kart->fio, 30 )
        add_string( PadR( t_arr[ 1 ], 30 ) + put_kope( tmp->saldo1, 13 ) + ;
          put_kope( tmp->debet, 13 ) + ;
          put_kope( tmp->kredit, 13 ) + ;
          put_kope( tmp->saldo2, 13 ) )
        For j := 2 To k
          add_string( PadL( AllTrim( t_arr[ j ] ), 30 ) )
        Next
        ss1 += tmp1->saldo1
        sd  += tmp1->debet
        sk  += tmp1->kredit
        ss2 += tmp1->saldo2
        Skip
      Enddo
      add_string( Replicate( "─", sh ) )
      add_string( PadL( "И Т О Г О : ", 30 ) + put_kope( ss1, 13 ) + ;
        put_kope( sd, 13 ) + ;
        put_kope( sk, 13 ) + ;
        put_kope( ss2, 13 ) )
      FClose( fp )
      viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
      Select TMP
      Goto ( rec )
    Case nKey == K_ENTER
      rec := tmp->( RecNo() )
      glob_fio := kart->fio
      Set Relation To
      kart->( dbCloseArea() )
      glob_d_smo := { tmp1->pr_smo, AllTrim( tmp1->name ) }
      muslovie := "hp->tip_usl==1 .and. hp->pr_smo==glob_d_smo[1]"
      muslovie += " .and. hp->kod_k==" + lstr( tmp->kod_k )
      ouslovie := "opl->tip==1 .and. opl->pr_smo==glob_d_smo[1]"
      ouslovie += " .and. opl->kod_k==" + lstr( tmp->kod_k )
      f4ob_ved_vz( 0 )
      r_use( dir_server() + "kartotek",, "KART" )
      Select TMP
      Set Relation To kod_k into KART
      Goto ( rec )
    Endcase
  Endcase

  Return ret

//
Function f4ob_ved_vz( par )

  Local s, sh, HH := 58, reg_print, arr_title, n_file := cur_dir() + "ob_ved.txt", ;
    buf := save_row( MaxRow() ), adbf, msaldo1, msaldo2, sum1, sum2

  mywait()
  adbf := { { "d_dokum", "D", 8, 0 }, ;
    { "prim",   "C", 30, 0 }, ;
    { "summa",  "N", 11, 2 } }
  dbCreate( cur_dir() + "tmp1_", adbf )
  dbCreate( cur_dir() + "tmp2_", adbf )
  Use ( cur_dir() + "tmp1_" ) new
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HP" )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On DToS( k_data ) to ( cur_dir() + "tmp_hp" ) for &muslovie While hp->k_data <= arr_m[ 6 ]
  Go Top
  Do While !Eof()
    kart->( dbGoto( hp->kod_k ) )
    Select TMP1_
    Append Blank
    tmp1_->d_dokum := hp->k_data
    tmp1_->prim := kart->fio
    tmp1_->summa := hp->cena
    Select HP
    Skip
  Enddo
  //
  Use ( cur_dir() + "tmp2_" ) new
  r_use( dir_server() + "plat_vz",, "OPL" )
  Index On DToS( date_opl ) to ( cur_dir() + "tmp_opl" ) for &ouslovie .and. Between( date_opl, arr_m[ 5 ], arr_m[ 6 ] )
  Go Top
  Do While !Eof()
    Select TMP2_
    Append Blank
    tmp2_->d_dokum := opl->date_opl
    If par == 1
      kart->( dbGoto( opl->kod_k ) )
      tmp2_->prim := fam_i_o( kart->fio )
    Else
      tmp2_->prim := opl->prim
    Endif
    tmp2_->summa := opl->summa_opl
    Select OPL
    Skip
  Enddo
  kart->( dbCloseArea() )
  opl->( dbCloseArea() )
  hp->( dbCloseArea() )
  //
  arr_title := { ;
    "──────────────────────────────────────────────────┬┬───────────────────────────────────", ;
    "                  Д  Е  Б  Е  Т                   ││        К  Р  Е  Д  И  Т           ", ;
    "────────┬──────────┬──────────────────────────────┼┼────────┬──────────┬───────────────", ;
    "  Дата  │   Сумма  │            Ф.И.О.            ││  Дата  │   Сумма  │  Примечание   ", ;
    "────────┴──────────┴──────────────────────────────┴┴────────┴──────────┴───────────────" }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( Center( "Оборотная ведомость", sh ) )
  Do Case
  Case par == 0
    add_string( Center( "по: " + glob_d_smo[ 2 ], sh ) )
    add_string( Center( "<<. " + AllTrim( glob_fio ) + " .>>", sh ) )
    msaldo1 := tmp->saldo1
    sum1    := tmp->debet
    sum2    := tmp->kredit
    msaldo2 := tmp->saldo2
  Case par == 1
    add_string( Center( "по: " + glob_d_smo[ 2 ], sh ) )
    msaldo1 := tmp1->saldo1
    sum1    := tmp1->debet
    sum2    := tmp1->kredit
    msaldo2 := tmp1->saldo2
  Case par == 2
    add_string( Center( "по: " + glob_pr_vz[ 2 ], sh ) )
    msaldo1 := tmp1->saldo1
    sum1    := tmp1->debet
    sum2    := tmp1->kredit
    msaldo2 := tmp1->saldo2
  Endcase
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( "" )
  s := "  Сальдо на " + date_8( arr_m[ 5 ] ) + "г.:  " + lput_kop( msaldo1, .t. )
  If msaldo1 >= 0
    add_string( s )
  Else
    add_string( PadL( s, sh -2 ) )
  Endif
  AEval( arr_title, {| x| add_string( x ) } )
  Select TMP1_
  Index On DToS( d_dokum ) + prim to ( cur_dir() + "tmp1_" )
  Go Top
  Select TMP2_
  Index On DToS( d_dokum ) + prim to ( cur_dir() + "tmp2_" )
  Go Top
  Do While !( tmp1_->( Eof() ) .and. tmp2_->( Eof() ) )
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    Select TMP1_
    If Eof()
      s := Space( 50 )
    Else
      s := date_8( tmp1_->d_dokum ) + ;
        put_kope( tmp1_->summa, 11 ) + " " + ;
        tmp1_->prim
      Skip
    Endif
    s += "  "
    Select TMP2_
    If !Eof()
      s += date_8( tmp2_->d_dokum ) + ;
        put_kope( tmp2_->summa, 11 ) + " " + ;
        AllTrim( tmp2_->prim )
      Skip
    Endif
    add_string( s )
  Enddo
  tmp1_->( dbCloseArea() )
  tmp2_->( dbCloseArea() )
  add_string( Replicate( "─", sh ) )
  add_string( put_kope( sum1, 19 ) + Space( 31 ) + "  " + put_kope( sum2, 19 ) )
  add_string( Replicate( "─", sh ) )
  s := "  Сальдо на " + date_8( arr_m[ 6 ] ) + "г.:  " + lput_kop( msaldo2, .t. )
  If msaldo2 >= 0
    add_string( s )
  Else
    add_string( PadL( s, sh -2 ) )
  Endif
  FClose( fp )
  rest_box( buf )
  viewtext( n_file,,,, ( sh > 80 ),,, 2 )

  Return Nil

//
Function rees1_vzaim( name_file )

  Local buf := save_row( MaxRow() ), sh, HH := 58, arr_title, s, j, sk, ss, old, ;
    reg_print := 2

  mywait()
  arr_title := { ;
    "──────────────────────────────────────────────┬────┬─────────────────┬─────────", ;
    "                   Ф.И.О.                     │Кол.│   Срок лечения  │Стоимость", ;
    "                                              │л/у │                 │ лечения ", ;
    "──────────────────────────────────────────────┴────┴─────────────────┴─────────" }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + "organiz",, "ORG" )
  add_string( AllTrim( org->name ) )
  org->( dbCloseArea() )
  add_string( "" )
  s := "Реестр платных услуг ("
  If tmp1->tip_usl == 1
    s += "добровольное страхование)"
  Else
    s += "взаимозачет)"
  Endif
  add_string( Center( s, sh ) )
  add_string( Center( "по: " + Upper( AllTrim( tmp1->name ) ), sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  j := sk := ss := 0
  Select TMP
  Go Top
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    s := PadR( Str( ++j, 4 ) + ". " + kart->fio, 46 ) + ;
      Str( tmp->kol, 3 ) + "   " + ;
      PadC( Left( DToC( tmp->n_data ), 5 ) + " - " + Left( DToC( tmp->k_data ), 5 ), 17 ) + ;
      put_kope( tmp->stoim, 10 )
    sk += tmp->kol
    ss += tmp->stoim
    add_string( s )
    Skip
  Enddo
  If verify_ff( HH -5, .t., sh )
    AEval( arr_title, {| x| add_string( x ) } )
  Endif
  add_string( Replicate( "─", sh ) )
  add_string( PadL( "Итого : " + lstr( sk ), sh -30 ) + put_kop( ss, 30 ) )
  add_string( "" )
  add_string( "" )
  add_string( Center( "Главный бухгалтер _________________", sh ) )
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 11.02.13
Function rees2_vzaim( name_file )

  Local buf := save_row( MaxRow() ), sh, HH := 52, arr_title, s, i, j, k, sk, ss, ;
    arr2title, reg_print := 6, afio[ 10 ], lfio := 19, kfio, lsk, lss, adbf, ;
    aadres[ 2 ], kadres, apolis[ 10 ], kpolis
  Private d_file := "P_REESTR" + sdbf()

  If !del_dbf_file( d_file )
    Return Nil
  Endif
  mywait()
  adbf := { { "nomer",  "C", 6, 0 }, ;
    { "fio",    "C", 50, 0 }, ;
    { "adres",  "C", 50, 0 }, ;
    { "polis",  "C", 17, 0 }, ;
    { "data",   "C", 10, 0 }, ;
    { "kod",    "C", 10, 0 }, ;
    { "name",   "C", 70, 0 }, ;
    { "otd",    "C", 5, 0 }, ;
    { "vrach",  "C", 20, 0 }, ;
    { "diagnoz", "C", 5, 0 }, ;
    { "cena",   "C", 10, 0 }, ;
    { "kol",    "C", 4, 0 }, ;
    { "summa",  "C", 10, 0 } }
  arr_title := { ;
    "───┬───────────────────┬─────────────────┬────────┬──────────┬─────────────────────────────────────────────────────────────────┬─────┬───────┬────┬──────────┬───────────", ;
    "NN │  Ф.И.О., адрес    │      Полис,     │  Дата  │ Код мани-│                   Название медицинской услуги                   │Отде-│  Цена │Кол.│ Сумма за │ Примечание", ;
    "пп │  застрахованного  │     диагноз     │оказания│ пуляции  │                                                                 │ление│ каждой│оказ│все кол-во│           ", ;
    "   │                   │                 │  мед.  │          │                                                                 │     │ услуги│ус- │оказ.услуг│           ", ;
    "   │                   │                 │ услуги │          │                                                                 │     │ (руб.)│луг │  (руб.)  │           ", ;
    "───┴───────────────────┴─────────────────┴────────┴──────────┴─────────────────────────────────────────────────────────────────┴─────┴───────┴────┴──────────┴───────────" }
  arr2title := { ;
    "───┬───────────────────┬─────────────────┬────────┬──────────┬─────────────────────────────────────────────────────────────────┬─────┬───────┬────┬──────────┬───────────", ;
    " 1 │         2         │        3        │    4   │     5    │                              6                                  │  7  │   8   │ 9  │    10    │     11    ", ;
    "───┴───────────────────┴─────────────────┴────────┴──────────┴─────────────────────────────────────────────────────────────────┴─────┴───────┴────┴──────────┴───────────" }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + "organiz",, "ORG" )
  add_string( AllTrim( org->name ) + if( Empty( org->inn ), "", ", ИНН " + org->inn ) )
  add_string( AllTrim( org->adres ) + if( Empty( org->telefon ), "", " тел." + org->telefon ) )
  add_string( "р/с № " + AllTrim( org->r_schet ) + " в " + RTrim( org->bank ) + ;
    ", БИК " + AllTrim( org->smfo ) + ", кор/c " + AllTrim( org->k_schet ) )
  add_string( "" )
  org->( dbCloseArea() )
  If tmp1->tip_usl == 1
    add_string( Center( "Реестр №_____ оказанных медицинских услуг", sh ) )
    add_string( Center( "по полисам ДМС " + AllTrim( tmp1->name ), sh ) )
  Else
    add_string( Center( "Реестр платных услуг (взаимозачет)", sh ) )
    add_string( Center( "по предприятию: " + Upper( AllTrim( tmp1->name ) ), sh ) )
  Endif
  add_string( Center( arr_m[ 4 ], sh ) )
  dbCreate( d_file, adbf )
  Use ( d_file ) New Alias DD
  r_use( dir_server() + "mo_otd",, "OTD" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "mo_pers",, "perso" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HPU" )
  r_use( dir_server() + "hum_p",, "HP" )
  AEval( arr_title, {| x| add_string( x ) } )
  j := sk := ss := 0
  Select TMP
  Go Top
  Do While !Eof()
    arr := {}
    Select TMP2
    find ( Str( tmp->( RecNo() ), 6 ) )
    Do While tmp2->rec_tmp == tmp->( RecNo() ) .and. !Eof()
      Select HP
      Goto ( tmp2->rec_hp )
      If ( i := AScan( arr, {| x| x[ 1 ] == tmp2->d_polis } ) ) == 0
        AAdd( arr, { tmp2->d_polis, {}, {}, {} } ) ; i := Len( arr )
      Endif
      add_diagnoz( arr[ i, 3 ] )
      Select HPU
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While hpu->kod == hp->( RecNo() )
        add_vrach( arr[ i, 4 ], hpu->kod_vr )
        otd->( dbGoto( hpu->otd ) )
        usl->( dbGoto( hpu->u_kod ) )
        AAdd( arr[ i, 2 ], { c4tod( hpu->date_u ), ;
          usl->shifr, ;
          usl->name, ;
          otd->short_name, ;
          hpu->kol, ;
          hpu->stoim;
          } )
        Select HPU
        Skip
      Enddo
      Select TMP2
      Skip
    Enddo
    kfio := perenos( afio, AllTrim( kart->fio ), lfio )
    kadres := perenos( aadres, AllTrim( kart->adres ), lfio )
    For i := 1 To kadres
      afio[ kfio + i ] := aadres[ i ]
    Next
    kfio += kadres
    For i := 1 To Len( arr )
      arr_diagnoz := arr[ i, 3 ]
      ASort( arr_diagnoz )
      If Len( AllTrim( arr[ i, 1 ] ) ) <= 17
        s := ""
        For k := 1 To Len( arr_diagnoz )
          s += AllTrim( arr_diagnoz[ k ] ) + " "
        Next
        kpolis := perenos( apolis, AllTrim( s ), 17 )
        ins_array( apolis, 1, AllTrim( arr[ i, 1 ] ) ) ; ++kpolis
      Else
        s := AllTrim( arr[ i, 1 ] ) + "/"
        For k := 1 To Len( arr_diagnoz )
          s += AllTrim( arr_diagnoz[ k ] ) + " "
        Next
        kpolis := perenos( apolis, AllTrim( s ), 17 )
      Endif
      arr_vrach := ret_arr_vrach( arr[ i, 4 ] )
      ASort( arr[ i, 2 ],,, {| x, y| iif( x[ 1 ] == y[ 1 ], fsort_usl( x[ 2 ] ) < fsort_usl( y[ 2 ] ), x[ 1 ] < y[ 1 ] ) } )
      lsk := lss := 0
      For k := 1 To Len( arr[ i, 2 ] )
        Select DD
        Append Blank
        If k == 1
          s := PadR( lstr( ++j ) + ". ", 4 )
          dd->nomer := lstr( j )
        Else
          s := Space( 4 )
        Endif
        If k <= kfio
          s += PadR( afio[ k ], lfio ) + " "
          If k == 1
            dd->fio := AllTrim( kart->fio )
            dd->adres := AllTrim( kart->adres )
          Endif
        Else
          s += Space( lfio + 1 )
        Endif
        If k <= kpolis
          s += PadC( AllTrim( apolis[ k ] ), 17 ) + " "
          If k == 1
            dd->polis := AllTrim( arr[ i, 1 ] )
          Endif
        Else
          s += Space( 17 + 1 )
        Endif
        dd->data  := full_date( arr[ i, 2, k, 1 ] )
        dd->kod   := arr[ i, 2, k, 2 ]
        dd->name  := arr[ i, 2, k, 3 ]
        dd->otd   := arr[ i, 2, k, 4 ]
        dd->cena  := Str( arr[ i, 2, k, 6 ] / arr[ i, 2, k, 5 ], 10, 2 )
        dd->kol   := Str( arr[ i, 2, k, 5 ], 4 )
        dd->summa := Str( arr[ i, 2, k, 6 ], 10, 2 )
        If k <= Len( arr_vrach )
          dd->vrach := arr_vrach[ k ]
        Endif
        If k <= Len( arr_diagnoz )
          dd->diagnoz := arr_diagnoz[ k ]
        Endif
        s += date_8( arr[ i, 2, k, 1 ] ) + " " + ;
          arr[ i, 2, k, 2 ] + " " + ;
          arr[ i, 2, k, 3 ] + " " + ;
          arr[ i, 2, k, 4 ] + ;
          Str( arr[ i, 2, k, 6 ] / arr[ i, 2, k, 5 ], 8, 2 ) + ;
          Str( arr[ i, 2, k, 5 ], 5 ) + ;
          Str( arr[ i, 2, k, 6 ], 11, 2 )
        If verify_ff( HH, .t., sh )
          AEval( arr2title, {| x| add_string( x ) } )
        Endif
        add_string( s )
        lsk += arr[ i, 2, k, 5 ]
        lss += arr[ i, 2, k, 6 ]
        sk += arr[ i, 2, k, 5 ]
        ss += arr[ i, 2, k, 6 ]
      Next
      For k := Len( arr[ i, 2 ] ) + 1 To Max( kfio, kpolis )
        s := Space( 4 )
        s += PadR( iif( k <= kfio, afio[ k ], "" ), lfio ) + " "
        s += PadR( iif( k <= kpolis, apolis[ k ], "" ), 17 )
        If verify_ff( HH, .t., sh )
          AEval( arr2title, {| x| add_string( x ) } )
        Endif
        add_string( s )
      Next
      add_string( PadL( Replicate( "-", 41 ), sh ) )
      add_string( PadL( lstr( lsk ) + Str( lss, 11, 2 ), sh -12 ) )
      add_string( "" )
    Next
    Select TMP
    Skip
  Enddo
  perso->( dbCloseArea() )
  dd->( dbCloseArea() )
  hp->( dbCloseArea() )
  hpu->( dbCloseArea() )
  usl->( dbCloseArea() )
  otd->( dbCloseArea() )
  If verify_ff( HH -5, .t., sh )
    AEval( arr2title, {| x| add_string( x ) } )
  Endif
  add_string( Replicate( "─", sh ) )
  add_string( PadL( "Итого : " + lstr( sk ) + Str( ss, 11, 2 ), sh -12 ) )
  add_string( "" )
  add_string( "" )
  add_string( Center( "Главный врач _________________                         Главный бухгалтер _________________", sh ) )
  FClose( fp )
  rest_box( buf )
  Private yes_albom := .t.
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  n_message( { "Создан файл: " + d_file + " (для загрузки в Excel)" },, cColorStMsg, cColorStMsg,,, cColorSt2Msg )

  Return Nil

//

//
Function pl_pl_1dogovor( k )

  Static si := 1
  Local mas_pmt := { "~С кодами врачей", ;
    "С фамилиями ~врачей" }
  Local mas_fun := { "pl_1dogovor(1)", ;
    "pl_1dogovor(2)" }

  Default k To 0
  Private kk := k
  If k == 0
    popup_prompt( T_ROW, T_COL + 5, si, mas_pmt,, mas_fun )
  Else
    si := k
    Do Case
    Case k == 1
      pl_pl_2dogovor( 1 )
    Case k == 2
      pl_pl_2dogovor( 2 )
    Endcase
  Endif

  Return Nil

//

// 25.12.25
Function pl_pl_dogovor()

  Local buf := save_row( MaxRow() ), sh, HH := 49, arr_title, s, i, j, k, sk, ss, ;
    arr2title, reg_print := 6, afio[ 10 ], lfio := 19, kfio, lsk, lss, adbf, ;
    aadres[ 2 ], kadres, apolis[ 10 ], kpolis, name_file := cur_dir() + "jurnal.txt", arr_dms, ;
    kol_vo := 0, usl_nds18 := 0, usl_nds18_1 := 0, ;
    usl_nds10 := 0, usl_nds10_1 := 0, ;
    usl_nds20 := 0, usl_nds20_1 := 0, ;
    usl_nds22 := 0, usl_nds22_1 := 0 

  arr_title := { ;
    "─────────────────────────────┬───────┬─────────────────────────────────────────────────────────────────┬───────┬────┬──────────┬──────────┬──────────", ;
    "        Ф.И.О., адрес        │ НОМЕР │                   Название медицинской услуги                   │  Цена │Кол.│ Сумма за │   Дата   │   Срок   ", ;
    "        застрахованного      │медицин│                                                                 │ каждой│оказ│все кол-во│  приема  │ оказания ", ;
    "                             │ карты │                                                                 │ услуги│ус- │оказ.услуг│   мед.   │   мед.   ", ;
    "                             │       │                                                                 │ (руб.)│луг │  (руб.)  │  услуги  │  услуги  ", ;
    "─────────────────────────────┴───────┴─────────────────────────────────────────────────────────────────┴───────┴────┴──────────┴──────────┴──────────" }
  Private krvz
  If ( krvz := fbp_tip_usl( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  mywait()
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + "organiz",, "ORG" )
  add_string( Center( "Ж У Р Н А Л", sh ) )
  add_string( Center( "учета заказов граждан на оказание им платных медицинских услуг(помощи)", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  tit_tip_usl( krvz, arr_dms, sh )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HPU" )
  r_use( dir_server() + "hum_p",, "HU" )
  AEval( arr_title, {| x| add_string( x ) } )
  j := sk := ss := 0
  Select HU
  Go Top
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If arr_m[ 5 ] <= hu->N_data .and. hu->n_data <= arr_m[ 6 ] .and. ;
        AScan( krvz, hu->tip_usl ) > 0 ;// 16.04.08
      .and. f_is_uch( st_a_uch, hu->lpu )// 16.05.09
      ss += hu->cena
      Select KART
      Goto hu->kod_k
      kfio := perenos( afio, AllTrim( kart->fio ) + " " + AllTrim( kart->adres ), 29 )
      fl_hu := .t. ; i := 0
      Select HPU
      t_kod := hu->( RecNo() )
      find ( Str( t_kod, 7 ) )
      Do While t_kod == hpu->kod .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        usl->( dbGoto( hpu->u_kod ) )
        If fl_hu
          fl_hu := .f.
          If glob_mo[ _MO_KOD_TFOMS ] == '171004' // КБ-4
            add_string( afio[ 1 ] + " " + ;
              PadR( lstr( hu->kod_k ), 7 ) + " " + ;
              PadR( usl->full_name, 65 ) + " " + put_kop( hpu->u_cena, 7 ) + " " + ;
              PadR( lstr( hpu->kol ), 4 ) + " " + put_kop( hpu->stoim, 10 ) + " " + ;
              full_date( c4tod( hu->Pdate ) ) + " " + full_date( c4tod( hpu->date_u ) ) )

          Else
            add_string( afio[ 1 ] + " " + ;
              PadR( lstr( hu->kod_k ), 7 ) + " " + ;
              PadR( usl->name, 65 ) + " " + put_kop( hpu->u_cena, 7 ) + " " + ;
              PadR( lstr( hpu->kol ), 4 ) + " " + put_kop( hpu->stoim, 10 ) + " " + ;
              full_date( c4tod( hu->Pdate ) ) + " " + full_date( c4tod( hpu->date_u ) ) )
          Endif
          i := 1
          ++kol_vo
        Else
          ++i
          If glob_mo[ _MO_KOD_TFOMS ] == '171004' // КБ-4
            add_string( iif( i <= kfio, afio[ i ], Space( 29 ) ) + " " + ;
              Space( 7 ) + " " + ;
              PadR( usl->full_name, 65 ) + " " + put_kop( hpu->u_cena, 7 ) + " " + ;
              PadR( lstr( hpu->kol ), 4 ) + " " + put_kop( hpu->stoim, 10 ) + " " + ;
              full_date( c4tod( hu->Pdate ) ) + " " + full_date( c4tod( hpu->date_u ) ) )
          Else
            add_string( iif( i <= kfio, afio[ i ], Space( 29 ) ) + " " + ;
              Space( 7 ) + " " + ;
              PadR( usl->name, 65 ) + " " + put_kop( hpu->u_cena, 7 ) + " " + ;
              PadR( lstr( hpu->kol ), 4 ) + " " + put_kop( hpu->stoim, 10 ) + " " + ;
              full_date( c4tod( hu->Pdate ) ) + " " + full_date( c4tod( hpu->date_u ) ) )
          Endif
        Endif
        Select HPU
        // Выборка НДС 18/10/20/22
        // возраст
        If fv_dog_date_r( hu->n_data, kart->date_r ) > 0 // дети
          If round_5( usl->pnds_d, 0 ) == 18
            usl_nds18 := usl_nds18 + hpu->kol
            usl_nds18_1 := usl_nds18_1 + hpu->stoim
          Elseif round_5( usl->pnds_d, 0 ) == 10
            usl_nds10 := usl_nds10 + hpu->kol
            usl_nds10_1 := usl_nds10_1 + hpu->stoim
          Elseif round_5( usl->pnds_d, 0 ) == 20
            usl_nds20 := usl_nds20 + hpu->kol
            usl_nds20_1 := usl_nds20_1 + hpu->stoim
          Elseif round_5( usl->pnds_d, 0 ) == 22
            usl_nds22 := usl_nds22 + hpu->kol
            usl_nds22_1 := usl_nds22_1 + hpu->stoim  
          Endif
        Else
          If round_5( usl->pnds, 0 ) == 18
            usl_nds18 := usl_nds18 + hpu->kol
            usl_nds18_1 := usl_nds18_1 + hpu->stoim
          Elseif round_5( usl->pnds, 0 ) == 10
            usl_nds10 := usl_nds10 + hpu->kol
            usl_nds10_1 := usl_nds10_1 + hpu->stoim
          Elseif round_5( usl->pnds, 0 ) == 20
            usl_nds20 := usl_nds20 + hpu->kol
            usl_nds20_1 := usl_nds20_1 + hpu->stoim
          Elseif round_5( usl->pnds, 0 ) == 22
            usl_nds22 := usl_nds22 + hpu->kol
            usl_nds22_1 := usl_nds22_1 + hpu->stoim  
          Endif
        Endif
        //
        Skip
      Enddo
      If i == 1
        add_string( iif( 1 < kfio, afio[ 2 ], Space( 29 ) ) )
      Endif
    Endif
    Select HU
    Skip
  Enddo
  Close databases
  add_string( Replicate( "─", sh ) )
  add_string( PadL( "Итого : " + Str( ss, 11, 2 ), sh -12 ) )
  add_string( PadL( "Итого договоров: " + Str( kol_vo, 11 ), sh -12 ) )
  If usl_nds18 > 0
    add_string( PadL( "Количество услуг с НДС 18% : " + Str( usl_nds18, 11 ), sh -12 ) )
  Endif
  If usl_nds18_1 > 0
    add_string( PadL( "Сумма услуг с НДС 18% : " + Str( usl_nds18_1, 11, 2 ), sh -12 ) )
  Endif
  If usl_nds10 > 0
    add_string( PadL( "Количество услуг с НДС 10% : " + Str( usl_nds10, 11 ), sh -12 ) )
  Endif
  If usl_nds10_1 > 0
    add_string( PadL( "Сумма услуг с НДС 10% : " + Str( usl_nds10_1, 11, 2 ), sh -12 ) )
  Endif
  If usl_nds20 > 0
    add_string( PadL( "Количество услуг с НДС 20% : " + Str( usl_nds20, 11 ), sh -12 ) )
  Endif
  If usl_nds20_1 > 0
    add_string( PadL( "Сумма услуг с НДС 20% : " + Str( usl_nds20_1, 11, 2 ), sh -12 ) )
  Endif
  If usl_nds22 > 0
    add_string( PadL( "Количество услуг с НДС 22% : " + Str( usl_nds22, 11 ), sh -12 ) )
  Endif
  If usl_nds22_1 > 0
    add_string( PadL( "Сумма услуг с НДС 22% : " + Str( usl_nds22_1, 11, 2 ), sh -12 ) )
  Endif
  add_string( "" )
  add_string( Center( "Главный врач _________________                         Главный бухгалтер _________________", sh ) )
  FClose( fp )
  rest_box( buf )
  Private yes_albom := .t.
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil


//


// 25.12.25
Function pl_pl_2dogovor()

  Local buf := save_row( MaxRow() ), sh, HH := 49, arr_title, s, i, k, sk, ss, ;
    arr2title, reg_print := 6, afio[ 10 ], lfio := 19, kfio, lsk, lss, adbf, ;
    aadres[ 2 ], kadres, apolis[ 10 ], kpolis, name_file := cur_dir() + "jurnal1.txt", ;
    usl_nds18 := 0, usl_nds18_1 := 0, ;
    usl_nds10 := 0, usl_nds10_1 := 0, ;
    usl_nds20 := 0, usl_nds20_1 := 0, ;
    usl_nds22 := 0, usl_nds22_1 := 0, ;  
    t_vr, t_as, t_nvr, t_nas, arr_dms, kol_vo := 0, ;
    nom_prihod

  arr_title := { ;
    "─────────────────────────────", ;
    "        Ф.И.О., адрес        ", ;
    "        застрахованного      ", ;
    "                             ", ;
    "                             ", ;
    "─────────────────────────────" }
  // номер карты
  arr_1 := { ;
    "┬──────────", ;
    "│   Дата   ", ;
    "│ рождения ", ;
    "│          ", ;
    "│          ", ;
    "┴──────────" }
  // номер карты
  arr_2 := { ;
    "┬───────", ;
    "│ НОМЕР ", ;
    "│медицин", ;
    "│ карты ", ;
    "│       ", ;
    "┴───────" }
  // номер договора
  arr_3 := { ;
    "┬─────────", ;
    "│  НОМЕР  ", ;
    "│         ", ;
    "│договора ", ;
    "│         ", ;
    "┴─────────" }
  // номер чека
  arr_4 := { ;
    "┬──────", ;
    "│НОМЕР ", ;
    "│      ", ;
    "│ чека ", ;
    "│      ", ;
    "┴──────" }
  // шифр услуги
  arr_5 := { ;
    "┬──────────", ;
    "│ Код мани-", ;
    "│ пуляции  ", ;
    "│          ", ;
    "│          ", ;
    "┴──────────" }
  // наименование услуги
  arr_6 := { ;
    "┬───────────────────────────────────────────────────", ;
    "│                                                   ", ;
    "│       Вид (наименование) медицинской услуги       ", ;
    "│                                                   ", ;
    "│                                                   ", ;
    "┴───────────────────────────────────────────────────" }

  // дата оплаты услуги
  // код врач
  arr_7 := { ;
    "┬─────", ;
    "│     ", ;
    "│     ", ;
    "│Врач ", ;
    "│     ", ;
    "┴─────" }
  // код м/c
  arr_8 := { ;
    "┬─────", ;
    "│     ", ;
    "│     ", ;
    "│ М/с ", ;
    "│     ", ;
    "┴─────" }
  // фио врача+м/с
  arr_9 := { ;
    "┬───────────────", ;
    "│               ", ;
    "│     Врач      ", ;
    "├───────────────", ;
    "│     М/с       ", ;
    "┴───────────────" }
  // фио врача+м/с
  arr_10 := { ;
    "┬───────────────", ;
    "│Ф.И.О специали-", ;
    "│ ста оказавшего", ;
    "│  мед. услугу  ", ;
    "│               ", ;
    "┴───────────────" }
  // цена услуги
  arr_11 := { ;
    "┬───────", ;
    "│  Цена ", ;
    "│ каждой", ;
    "│ услуги", ;
    "│ (руб.)", ;
    "┴───────" }
  // цена услуги
  arr_12 := { ;
    "┬───────", ;
    "│Стоимо-", ;
    "│  сть  ", ;
    "│ услуги", ;
    "│ (руб.)", ;
    "┴───────" }
  // количество услуг
  arr_13 := { ;
    "┬────", ;
    "│Кол.", ;
    "│оказ", ;
    "│ус- ", ;
    "│луг ", ;
    "┴────" }
  arr_14 := { ;
    "┬──────────", ;
    "│   Дата   ", ;
    "│  оплаты  ", ;
    "│   мед.   ", ;
    "│  услуги  ", ;
    "┴──────────" }
  // дата оказания услуги
  arr_15 := { ;
    "┬──────────", ;
    "│   Дата   ", ;
    "│ оказания ", ;
    "│ (приёма) ", ;
    "│мед.услуги", ;
    "┴──────────" }
  // сумма услуг
  arr_00 := { ;
    "┬──────────", ;
    "│ Сумма за ", ;
    "│все кол-во", ;
    "│оказ.услуг", ;
    "│  (руб.)  ", ;
    "┴──────────" }
  arr_01 := { ;
    "┬──────────", ;
    "│   Срок   ", ;
    "│ оказания ", ;
    "│   мед.   ", ;
    "│  услуги  ", ;
    "┴──────────" }

  Private krvz
  If ( krvz := fbp_tip_usl( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  Private glob_pozic
  If ( glob_pozic := inputnplpozic( T_ROW, T_COL + 5 ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  mywait()
  // создаем заголовок
  For i := 0 To 14
    If f_is_pozic( glob_pozic, i )
      For j := 1 To 6
        arr_title[ j ] += &( "arr_" + lstr( i + 1 ) + "[j]" )
      Next
    Endif
  Next
  For j := 1 To 6
    arr_title[ j ] += arr_00[ j ]
    arr_title[ j ] += arr_01[ j ]
  Next
  //
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  // R_Use(dir_server()+"kas_usld",,"PUSL",,,.T.)
  // index on str(u_kod,4) to tmp_ud
  r_use( dir_server() + "mo_pers",, "perso" )
  r_use( dir_server() + "organiz",, "ORG" )
  add_string( Center( "Ж У Р Н А Л", sh ) )
  add_string( Center( "учета заказов граждан на предоставление им платных медицинских услуг(помощи)", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  tit_tip_usl( krvz, arr_dms, sh )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HPU" )
  r_use( dir_server() + "hum_p",, "HU" )
  If glob_mo[ _MO_KOD_TFOMS ] == '171004' // КБ-4
    Index On DToS( N_data ) + Str( kv_cia, 6 ) to ( cur_dir() + "tmp_hum" ) For Between( N_data, arr_m[ 5 ], arr_m[ 6 ] )
  Else
    Index On pdate + Str( kv_cia, 6 ) to ( cur_dir() + "tmp_hum" ) For Between( pdate, arr_m[ 7 ], arr_m[ 8 ] )
  Endif
  Set Index to ( dir_server() + "hum_pkk" ), ( cur_dir() + "tmp_hum" )
  Set Order To 2
  //
  AEval( arr_title, {| x| add_string( x ) } )
  j := sk := ss := 0
  Select HU
  Go Top
  Do While !Eof()
    If AScan( krvz, hu->tip_usl ) > 0 .and. f_is_uch( st_a_uch, hu->lpu )
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      ss += hu->cena
      If f_is_pozic( glob_pozic, 1 )
        nom_prihod := 0
        t_recno := hu->( RecNo() )
        // index on str(kod_k,7)+dtos(k_data) to (dir_server()+"hum_pkk") descending progress
        kart_kod := hu->kod_k
        t_k_data := Year( hu->k_data )
        Set Order To 1
        Select HU
        Do While hu->kod_k == kart_kod .and. ;
            Year( hu->k_data ) == t_k_data .and. !Eof()
          ++nom_prihod
          Skip
        Enddo
        Set Order To 2
        Goto t_recno
      Endif
      //
      Select KART
      Goto hu->kod_k
      kfio := perenos( afio, AllTrim( kart->fio ) + " " + AllTrim( kart->adres ), 29 )
      fl_hu := .t.
      Select HPU
      t_kod := hu->( RecNo() )
      find ( Str( t_kod, 7 ) )
      Do While t_kod == hpu->kod .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        usl->( dbGoto( hpu->u_kod ) )
        Select perso
        Goto ( hpu->kod_vr )
        t_vr := perso->tab_nom
        t_nvr := fam_i_o( perso->fio )
        Goto ( hpu->kod_as )
        t_as := perso->tab_nom
        If fl_hu
          fl_hu := .f.
          // goto (hpu->kod_as)
          // t_nas := "  "//fam_i_o(perso->fio)
          //
          If glob_mo[ _MO_KOD_TFOMS ] == '171004' // КБ-4
            add_string( afio[ 1 ] + " " + ;
              iif( f_is_pozic( glob_pozic, 0 ), full_date( kart->date_r ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 1 ), PadR( lstr( hu->kod_k ), 7 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 2 ), PadR( lstr( hu->kod_k ) + "/" + lstr( nom_prihod ), 9 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 3 ), PadR( lstr( hu->kv_cia ), 6 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 4 ), usl->shifr + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 5 ), PadR( AllTrim( usl->full_name ), 51 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 6 ), iif( t_vr > 0, PadL( lstr( t_vr ), 5 ), Space( 5 ) ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 7 ), iif( t_as > 0, PadR( lstr( t_as ), 5 ), Space( 5 ) ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 8 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 9 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 10 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 11 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 12 ), PadR( lstr( hpu->kol ), 4 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 13 ), iif( hu->kv_cia > 0, full_date( c4tod( hu->pdate ) ), Space( 10 ) ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 14 ), full_date( c4tod( hpu->date_u ) ) + " ", "" ) + ;
              put_kop( hpu->stoim, 10 ) + " " + ;
              full_date( c4tod( hpu->date_u ) ) )
          Else
            add_string( afio[ 1 ] + " " + ;
              iif( f_is_pozic( glob_pozic, 0 ), full_date( kart->date_r ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 1 ), PadR( lstr( hu->kod_k ), 7 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 2 ), PadR( lstr( hu->kod_k ) + "/" + lstr( nom_prihod ), 9 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 3 ), PadR( lstr( hu->kv_cia ), 6 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 4 ), usl->shifr + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 5 ), PadR( AllTrim( usl->name ), 51 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 6 ), iif( t_vr > 0, PadL( lstr( t_vr ), 5 ), Space( 5 ) ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 7 ), iif( t_as > 0, PadR( lstr( t_as ), 5 ), Space( 5 ) ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 8 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 9 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 10 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 11 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 12 ), PadR( lstr( hpu->kol ), 4 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 13 ), full_date( c4tod( hu->pdate ) ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 14 ), full_date( c4tod( hpu->date_u ) ) + " ", "" ) + ;
              put_kop( hpu->stoim, 10 ) + " " + ;
              full_date( c4tod( hpu->date_u ) ) )
          Endif
          i := 1
          ++kol_vo
        Else
          ++i
          If glob_mo[ _MO_KOD_TFOMS ] == '171004' // КБ-4
            add_string( iif( i <= kfio, afio[ i ], Space( 29 ) ) + " " + ;
              iif( f_is_pozic( glob_pozic, 0 ), Space( 11 ), "" ) + ;
              iif( f_is_pozic( glob_pozic, 1 ), Space( 8 ), "" ) + ;
              iif( f_is_pozic( glob_pozic, 2 ), Space( 10 ), "" ) + ;
              iif( f_is_pozic( glob_pozic, 3 ), Space( 7 ), "" ) + ;
              iif( f_is_pozic( glob_pozic, 4 ), usl->shifr + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 5 ), PadR( AllTrim( usl->full_name ), 51 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 6 ), iif( t_vr > 0, PadL( lstr( t_vr ), 5 ), Space( 5 ) ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 7 ), iif( t_as > 0, PadL( lstr( t_as ), 5 ), Space( 5 ) ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 8 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 9 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 10 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 11 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 12 ), PadR( lstr( hpu->kol ), 4 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 13 ), Space( 10 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 14 ), full_date( c4tod( hpu->date_u ) ) + " ", "" ) + ;
              put_kop( hpu->stoim, 10 ) + " " + ;
              full_date( c4tod( hpu->date_u ) ) )
          Else
            add_string( iif( i <= kfio, afio[ i ], Space( 29 ) ) + " " + ;
              iif( f_is_pozic( glob_pozic, 0 ), Space( 11 ), "" ) + ;
              iif( f_is_pozic( glob_pozic, 1 ), Space( 8 ), "" ) + ;
              iif( f_is_pozic( glob_pozic, 2 ), Space( 10 ), "" ) + ;
              iif( f_is_pozic( glob_pozic, 3 ), Space( 7 ), "" ) + ;
              iif( f_is_pozic( glob_pozic, 4 ), usl->shifr + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 5 ), PadR( AllTrim( usl->name ), 51 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 6 ), iif( t_vr > 0, PadL( lstr( t_vr ), 5 ), Space( 5 ) ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 7 ), iif( t_as > 0, PadL( lstr( t_as ), 5 ), Space( 5 ) ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 8 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 9 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 10 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 11 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 12 ), PadR( lstr( hpu->kol ), 4 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 13 ), Space( 10 ) + " ", "" ) + ;
              iif( f_is_pozic( glob_pozic, 14 ), full_date( c4tod( hpu->date_u ) ) + " ", "" ) + ;
              put_kop( hpu->stoim, 10 ) + " " + ;
              full_date( c4tod( hpu->date_u ) ) )
          Endif
        Endif
        Select HPU
        // Выборка НДС 18/10/20/22
        // возраст
        If fv_dog_date_r( hu->n_data, kart->date_r ) > 0 // дети
          If round_5( usl->pnds_d, 0 ) == 18
            usl_nds18 := usl_nds18 + hpu->kol
            usl_nds18_1 := usl_nds18_1 + hpu->stoim
          Elseif round_5( usl->pnds_d, 0 ) == 10
            usl_nds10 := usl_nds10 + hpu->kol
            usl_nds10_1 := usl_nds10_1 + hpu->stoim
          Elseif round_5( usl->pnds_d, 0 ) == 20
            usl_nds20 := usl_nds20 + hpu->kol
            usl_nds20_1 := usl_nds20_1 + hpu->stoim
          Elseif round_5( usl->pnds_d, 0 ) == 22
            usl_nds22 := usl_nds22 + hpu->kol
            usl_nds22_1 := usl_nds22_1 + hpu->stoim  
          Endif
        Else
          If round_5( usl->pnds, 0 ) == 18
            usl_nds18 := usl_nds18 + hpu->kol
            usl_nds18_1 := usl_nds18_1 + hpu->stoim
          Elseif round_5( usl->pnds, 0 ) == 10
            usl_nds10 := usl_nds10 + hpu->kol
            usl_nds10_1 := usl_nds10_1 + hpu->stoim
          Elseif round_5( usl->pnds, 0 ) == 20
            usl_nds20 := usl_nds20 + hpu->kol
            usl_nds20_1 := usl_nds20_1 + hpu->stoim
          Elseif round_5( usl->pnds, 0 ) == 22
            usl_nds22 := usl_nds22 + hpu->kol
            usl_nds22_1 := usl_nds22_1 + hpu->stoim
          Endif
        Endif
        Skip
      Enddo
      If i == 1 .and. 1 < kfio
        add_string( afio[ 2 ] )
      Endif
    Endif
    // if mem_dop_st == 2
    // add_string("")
    // endif
    Select HU
    Skip
  Enddo
  Close databases
  add_string( Replicate( "─", sh ) )
  add_string( PadL( "Итого : " + lstr( ss, 15, 2 ), sh -11 ) )
  add_string( PadL( "Итого договоров : " + lstr( kol_vo ), sh -11 ) )
  If usl_nds18 > 0
    add_string( PadL( "Количество услуг с НДС 18% : " + Str( usl_nds18, 11 ), sh -11 ) )
  Endif
  If usl_nds18_1 > 0
    add_string( PadL( "Сумма услуг с НДС 18% : " + Str( usl_nds18_1, 11, 2 ), sh -11 ) )
  Endif
  If usl_nds10 > 0
    add_string( PadL( "Количество услуг с НДС 10% : " + Str( usl_nds10, 11 ), sh -11 ) )
  Endif
  If usl_nds10_1 > 0
    add_string( PadL( "Сумма услуг с НДС 10% : " + Str( usl_nds10_1, 11, 2 ), sh -11 ) )
  Endif
  If usl_nds20 > 0
    add_string( PadL( "Количество услуг с НДС 20% : " + Str( usl_nds20, 11 ), sh -12 ) )
  Endif
  If usl_nds20_1 > 0
    add_string( PadL( "Сумма услуг с НДС 20% : " + Str( usl_nds20_1, 11, 2 ), sh -12 ) )
  Endif
  If usl_nds22 > 0
    add_string( PadL( "Количество услуг с НДС 22% : " + Str( usl_nds22, 11 ), sh -12 ) )
  Endif
  If usl_nds22_1 > 0
    add_string( PadL( "Сумма услуг с НДС 22% : " + Str( usl_nds22_1, 11, 2 ), sh -12 ) )
  Endif
  add_string( "" )
  add_string( "" )
  add_string( Center( "Главный врач _________________                         Главный бухгалтер _________________", sh ) )
  FClose( fp )
  rest_box( buf )
  Private yes_albom := .t.
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

// 18.11.16 определение критерия "взрослый/ребёнок"
Function fv_dog_date_r( _data, ldate_r )

  Local k, cy

  cy := count_years( ldate_r, _data )
  If cy < 18 ; k := 1  // подросток+ребенок
  else       ; k := 0  // взрослый
  Endif

  Return k

//
Static Function add_diagnoz( ar )

  If !Empty( hp->KOD_DIAG ) .and. AScan( ar, hp->KOD_DIAG ) == 0
    AAdd( ar, hp->KOD_DIAG )
  Endif
  If !Empty( hp->SOPUT_B1 ) .and. AScan( ar, hp->SOPUT_B1 ) == 0
    AAdd( ar, hp->SOPUT_B1 )
  Endif
  If !Empty( hp->SOPUT_B2 ) .and. AScan( ar, hp->SOPUT_B2 ) == 0
    AAdd( ar, hp->SOPUT_B2 )
  Endif
  If !Empty( hp->SOPUT_B3 ) .and. AScan( ar, hp->SOPUT_B3 ) == 0
    AAdd( ar, hp->SOPUT_B3 )
  Endif
  If !Empty( hp->SOPUT_B4 ) .and. AScan( ar, hp->SOPUT_B4 ) == 0
    AAdd( ar, hp->SOPUT_B4 )
  Endif
  If !Empty( hp->SOPUT_B5 ) .and. AScan( ar, hp->SOPUT_B5 ) == 0
    AAdd( ar, hp->SOPUT_B5 )
  Endif

  Return Nil

//
Static Function add_vrach( ar, lkod_vr )

  If !Empty( lkod_vr ) .and. AScan( ar, lkod_vr ) == 0
    AAdd( ar, lkod_vr )
  Endif

  Return Nil

//
Static Function ret_arr_vrach( ar )

  Local i, arr := {}

  For i := 1 To Len( ar )
    perso->( dbGoto( ar[ i ] ) )
    AAdd( arr, fam_i_o( perso->fio ) )
  Next
  ASort( arr )

  Return arr

//
// 02.05.18
Function pl1_priemden( tip )

  // 1 - сводный
  // 2 - по кассовым аппаратам
  // 3 - по кассирам
  Local fl := .t., buf := save_row( MaxRow() ), sm := 0, HH := 52, ;
    n_file := cur_dir() + "platn.txt", arr_m, sum3 := 0, sh, sm_sn := 0, arr_dms, ;
    sm_1 := 0, sm_2 := 0, vrem_kas, sm1, sm2, t_name_ysl, mas_name := {}
  Local arr_title := { ;
    "──────────────────────────────────────────────────────────┬────────┬───────────", ;
    "                          Услуги                          │ Кол-во │   Сумма   ", ;
    "──────────────────────────────────────────────────────────┴────────┴───────────";
    }
  sh := Len( arr_title[ 1 ] )
  Private krvz
  If ( krvz := fbp_tip_usl( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  //
  mywait()
  dbCreate( cur_dir() + "tmp", { { "kod",        "N",  4,  0 }, ;
    { "name",       "C", 65,  0 }, ;
    { "full_name",  "C", 120,  0 }, ;
    { "kod_1",      "C", 10,  0 }, ;
    { "kol_vo",     "N", 10,  0 }, ;
    { "summa",      "N", 12,  2 }, ;
    { "operat",     "N",  3,  0 }, ;
    { "operatf",    "C", 40,  0 }, ;
    { "FR_zavod",   "C", 16,  0 };
    } )
  Use ( cur_dir() + "tmp" ) new
  If tip == 1
    Index On Str( kod, 4 ) to ( cur_dir() + "tmp_u" )
  Elseif tip == 2
    Index On Str( kod, 4 ) + fr_zavod to ( cur_dir() + "tmp_u" )
  Else
    Index On Str( kod, 4 ) + Str( operat, 3 ) to ( cur_dir() + "tmp_u" )
  Endif
  If yes_parol
    r_use( dir_server() + "base1",, "BASE1" )
  Endif
  r_use( dir_server() + "hum_p",, "HUM" )
  r_use( dir_server() + "hum_p_U", dir_server() + "hum_p_U", "HUM_U" )
  Select HUM
  Go Top
  sum3 := 0
  Do While !Eof()
    If arr_m[ 5 ] <= hum->N_data .and. hum->n_data <= arr_m[ 6 ] .and. ;
        AScan( krvz, hum->tip_usl ) > 0 // 16.04.08
      // sum3 += hum->cena    // 16.06.08
      sm_sn += hum->SUM_VOZ  // 16.06.08
      t := hum->( RecNo() )
      Select HUM_U
      find ( Str( t, 7 ) )
      Do While t == hum_u->kod .and. !Eof()
        Select TMP
        If tip == 1
          find ( Str( hum_u->u_kod, 4 ) )
        Elseif tip == 2
          find ( Str( hum_u->u_kod, 4 ) + hum->FR_zavod )
        Else
          find ( Str( hum_u->u_kod, 4 ) + Str( hum->KOD_OPER, 3 ) )
        Endif
        If !Found()
          Append Blank
          tmp->kod      := hum_u->u_kod
          tmp->operat   := hum->KOD_OPER
          tmp->FR_zavod := hum->FR_zavod
        Endif
        If yes_parol .and. hum->KOD_OPER > 0
          Select BASE1
          Goto ( hum->KOD_OPER )
          If !Eof() .and. !Empty( base1->p1 )
            tmp->operatf := AllTrim( Crypt( base1->p1, gpasskod ) )
          Endif
        Endif
        tmp->kol_vo := tmp->kol_vo + hum_u->kol
        tmp->summa  := tmp->summa  + hum_u->stoim
        Select HUM_U
        Skip
      Enddo
    Endif
    Select HUM
    Skip
  Enddo
  //
  r_use( dir_server() + "uslugi",, "USL" )
  Select TMP
  Go Top
  Do While !Eof()
    t := tmp->kod
    Select usl
    Goto t
    Select tmp
    tmp->name       := usl->name
    tmp->full_name  := usl->full_name
    tmp->kod_1      := usl->shifr
    Skip
  Enddo
  Select TMP
  Index On kod_1 to ( cur_dir() + "tmp_u" )
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( Center( "Оплата услуг", sh ) )
  add_string( Center( "по дате начала лечения", sh ) )
  If tip == 3
    add_string( Center( "с группировкой по кассирам", sh ) )
  Elseif tip == 2
    add_string( Center( "с группировкой по кассовым аппаратам", sh ) )
  Endif
  add_string( Center( arr_m[ 4 ], sh ) )
  tit_tip_usl( krvz, arr_dms, sh ) // 16.04.08
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  If tip == 1
    Index On kod_1 to ( cur_dir() + "tmp_u" )
  Elseif tip == 2
    Index On fr_zavod + kod_1 to ( cur_dir() + "tmp_u" )
  Else
    Index On operatf + kod_1 to ( cur_dir() + "tmp_u" )
  Endif
  Go Top
  sm1 := 0
  sm2 := 0
  If tip == 3
    vrem_kas := tmp->operatf
  Elseif tip == 2
    vrem_kas := tmp->FR_zavod
  Endif
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If tip == 3
      If vrem_kas != tmp->operatf
        add_string( Replicate( "─", sh ) )
        add_string( PadR( "Итого кассир: " + vrem_kas, 58 ) + ;
          Str( SM_1, 9 ) + ;
          put_kope( SM_2, 12 ) )
        add_string( "" )
        // add_string(replicate("─",sh))                 // 16.06.08
        // add_string(padR("из них возврат: ",59)+;
        // put_kope(sm_sn,12))
        vrem_kas := tmp->operatf
        sm_1 := 0
        sm_2 := 0
      Endif
    Elseif tip == 2
      If vrem_kas != tmp->FR_zavod
        add_string( Replicate( "─", sh ) )
        add_string( PadR( "Итого касса №: " + vrem_kas, 58 ) + ;
          Str( SM_1, 9 ) + ;
          put_kope( SM_2, 12 ) )
        add_string( "" )
        // add_string(replicate("─",sh))                 // 16.06.08
        // add_string(padR("из них возврат: ",59)+;
        // put_kope(sm_sn,12))
        vrem_kas := tmp->FR_zavod
        sm_1 := 0
        sm_2 := 0
      Endif
    Endif
    If !Empty( tmp->full_name )
      t_name_ysl := tmp->full_name
    Else
      t_name_ysl := tmp->name
    Endif
    For i := 1 To perenos( mas_name, t_name_ysl, 48 )
      If i == 1
        add_string( tmp->kod_1 + PadR( mas_name[ i ], 48 ) + ;
          Str( tmp->kol_vo, 9 ) + ;
          put_kope( tmp->summa, 12 ) )
      Else
        add_string( Space( 10 ) + mas_name[ i ] )
      Endif
    Next
    sm1 += tmp->kol_vo
    SM2 += tmp->summa
    sm_1 += tmp->kol_vo
    SM_2 += tmp->summa
    Skip
  Enddo
  If tip == 3
    add_string( Replicate( "─", sh ) )
    add_string( PadR( "Итого кассир: " + vrem_kas, 58 ) + ;
      Str( SM_1, 9 ) + ;
      put_kope( SM_2, 12 ) )
  Elseif tip == 2
    add_string( Replicate( "─", sh ) )
    add_string( PadR( "Итого касса №: " + vrem_kas, 58 ) + ;
      Str( SM_1, 9 ) + ;
      put_kope( SM_2, 12 ) )
  Endif
  add_string( Replicate( "─", sh ) )
  add_string( PadR( "Итого: ", 58 ) + ;
    Str( SM1, 9 ) + ;
    put_kope( SM2, 12 ) )
  add_string( Replicate( "─", sh ) )                 // 16.06.08
  add_string( PadR( "из них возврат: ", 67 ) + ;
    put_kope( sm_sn, 12 ) )
  Close databases
  FClose( fp )
  viewtext( n_file,,,, ( sh > 80 ),,, 1 )
  rest_box( buf )

  Return Nil


//

// 28.03.21
Function pl2_priemden( tip )

  // 2 - по кассовым аппаратам
  // 3 - по кассирам
  Local fl := .t., buf := save_row( MaxRow() ), sm := 0, HH := 51, ;
    n_file := cur_dir() + "platn.txt", arr_m, sum3 := 0, sh, sm_sn := 0, arr_dms, ;
    sm_1 := 0, sm_2 := 0, vrem_kas, sm1, sm2, t_name_ysl, mas_name := {}, ;
    t, t1

  Local arr_title := { ;
    "──────────────────────────────────────────────────────────┬────────────────────", ;
    "                                                          │        ИТОГО       ", ;
    "                          Услуги                          ├────────┬───────────", ;
    "                                                          │ Кол-во │   Сумма   ", ;
    "──────────────────────────────────────────────────────────┴────────┴───────────";
    }
  Local arr_1title := { ;
    "┬────────────────────", ;
    "│", ;
    "├────────┬───────────", ;
    "│ Кол-во │   Сумма   ", ;
    "┴────────┴───────────";
    }
  Private krvz, lpole, spole
  Private arr_kkm := {}
  If ( krvz := fbp_tip_usl( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  //
  mywait()
  dbCreate( cur_dir() + "tmp", { { "kod",        "N",  4,  0 }, ;
    { "name",       "C", 65,  0 }, ;
    { "full_name",  "C", 120,  0 }, ;
    { "kod_1",      "C", 10,  0 }, ;
    { "kol_vo",     "N", 10,  0 }, ;
    { "summa",      "N", 12,  2 }, ;
    { "operat",     "N",  3,  0 }, ;
    { "operatf",    "C", 40,  0 }, ;
    { "summa1",     "N", 12,  2 }, ;
    { "kol_vo1",    "N", 10,  0 }, ;
    { "summa2",     "N", 12,  2 }, ;
    { "kol_vo2",    "N", 10,  0 }, ;
    { "summa3",     "N", 12,  2 }, ;
    { "kol_vo3",    "N", 10,  0 }, ;
    { "summa4",     "N", 12,  2 }, ;
    { "kol_vo4",    "N", 10,  0 }, ;
    { "summa5",     "N", 12,  2 }, ;
    { "kol_vo5",    "N", 10,  0 }, ;
    { "summa6",     "N", 12,  2 }, ;
    { "kol_vo6",    "N", 10,  0 }, ;
    { "summa7",     "N", 12,  2 }, ;
    { "kol_vo7",    "N", 10,  0 }, ;
    { "summa8",     "N", 12,  2 }, ;
    { "kol_vo8",    "N", 10,  0 }, ;
    { "summa9",     "N", 12,  2 }, ;
    { "kol_vo9",    "N", 10,  0 }, ;
    { "summa10",    "N", 12,  2 }, ;
    { "kol_vo10",   "N", 10,  0 }, ;
    { "summa11",    "N", 12,  2 }, ;
    { "kol_vo11",   "N", 10,  0 }, ;
    { "summa12",    "N", 12,  2 }, ;
    { "kol_vo12",   "N", 10,  0 };
    } )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp_u" )
  r_use( dir_server() + "hum_p",, "HUM" )
  r_use( dir_server() + "hum_p_U", dir_server() + "hum_p_U", "HUM_U" )
  Select HUM
  Go Top
  sum3 := 0
  Do While !Eof()
    If arr_m[ 5 ] <= hum->N_data .and. hum->n_data <= arr_m[ 6 ] .and. ;
        AScan( krvz, hum->tip_usl ) > 0 // 16.04.08
      // sm_sn += hum->SUM_VOZ  // 16.06.08
      t := hum->( RecNo() )
      Select HUM_U
      find ( Str( t, 7 ) )
      Do While t == hum_u->kod .and. !Eof()
        Select TMP
        find ( Str( hum_u->u_kod, 4 ) + hum->FR_zavod )
        If !Found()
          Append Blank
          tmp->kod      := hum_u->u_kod
          tmp->operat   := hum->KOD_OPER
        Endif
        tmp->kol_vo := tmp->kol_vo + hum_u->kol
        tmp->summa  := tmp->summa  + hum_u->stoim
        If ( i := AScan( arr_kkm, {| x| AllTrim( x[ 1 ] ) == AllTrim( hum->FR_zavod ) } ) ) == 0
          AAdd( arr_kkm, { hum->FR_zavod, 0, 0 } )
          i := Len( arr_kkm )
        Endif
        t1 := lstr( i )
        Spole := "tmp->summa" + t1
        kpole := "tmp->kol_vo" + t1
        &spole := &spole + hum_u->stoim
        &kpole := &kpole + hum_u->kol
        Select HUM_U
        Skip
      Enddo
    Endif
    Select HUM
    Skip
  Enddo
  //
  r_use( dir_server() + "uslugi",, "USL" )
  Select TMP
  Go Top
  Do While !Eof()
    t := tmp->kod
    Select usl
    Goto t
    Select tmp
    tmp->name       := usl->name
    tmp->full_name  := usl->full_name
    tmp->kod_1      := usl->shifr
    Skip
  Enddo
  //
  Select TMP
  Index On kod_1 to ( cur_dir() + "tmp_u" )
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  For i := 1 To Len( arr_kkm )
    arr_title[ 1 ] := arr_title[ 1 ] + arr_1title[ 1 ]
    arr_title[ 2 ] := arr_title[ 2 ] + arr_1title[ 2 ] + PadC( AllTrim( arr_kkm[ i, 1 ] ), 20 )
    arr_title[ 3 ] := arr_title[ 3 ] + arr_1title[ 3 ]
    arr_title[ 4 ] := arr_title[ 4 ] + arr_1title[ 4 ]
    arr_title[ 5 ] := arr_title[ 5 ] + arr_1title[ 5 ]
  Next
  sh := Len( arr_title[ 1 ] )
  add_string( Center( "Оплата услуг", sh ) )
  add_string( Center( "по дате начала лечения", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  tit_tip_usl( krvz, arr_dms, sh ) // 16.04.08
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  Index On kod_1 to ( cur_dir() + "tmp_u" )
  Go Top
  sm1 := 0
  sm2 := 0
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    If !Empty( tmp->full_name )
      t_name_ysl := tmp->full_name
    Else
      t_name_ysl := tmp->name
    Endif
    For i := 1 To perenos( mas_name, t_name_ysl, 48 )
      If i == 1
        t_str := tmp->kod_1 + PadR( mas_name[ i ], 48 ) + ;
          Str( tmp->kol_vo, 9 ) + ;
          put_kope( tmp->summa, 12 )
        For j := 1 To Len( arr_kkm )
          t1 := lstr( j )
          Spole := "tmp->summa" + t1
          kpole := "tmp->kol_vo" + t1
          t_str += ( Str( &kpole, 9 ) + put_kope( &spole, 12 ) )
          arr_kkm[ j, 2 ] += &kpole
          arr_kkm[ j, 3 ] += &spole
        Next
        add_string( t_str )
      Else
        add_string( Space( 10 ) + mas_name[ i ] )
      Endif
    Next
    sm1 += tmp->kol_vo
    SM2 += tmp->summa
    Skip
  Enddo

  add_string( Replicate( "─", sh ) )
  t_str := PadR( "Итого: ", 58 ) + ;
    Str( SM1, 9 ) + ;
    put_kope( SM2, 12 )
  For j := 1 To Len( arr_kkm )
    t_str += ( Str( arr_kkm[ j, 2 ], 9 ) + put_kope( arr_kkm[ j, 3 ], 12 ) )
  Next
  add_string( t_str )
  add_string( Replicate( "─", sh ) )                 // 16.06.08
  // add_string(padR("из них возврат: ",67)+;
  // put_kope(sm_sn,12))
  Close databases
  FClose( fp )
  Private yes_albom := .t.
  viewtext( n_file,,,, ( sh > 80 ),,, 6 )
  rest_box( buf )

  Return Nil


// 02.12.12
Function inputnplpozic( r, c, fl_max )

  Static st_pozic := {}
  Local i, k, t_mas, ;
    buf := SaveScreen(), l_a_pozic
  Local mas_s := { "Дата рождения", ;
    "Номер карты", ;
    "Номер договора", ;
    "Номер чека", ;
    "Шифр мед.услуги", ;
    "Наименование мед.услуги", ;
    "Код Врача", ;
    "Код Медсестры", ;
    "ФИО врача+м/с", ;
    "ФИО специалиста", ;
    "Цена услуги", ;
    "Стоимость услуги", ;
    "Количество услуг", ;
    "Дата оплаты мед.услуги", ;
    "Дата оказания мед.услуги" }

  Local mas := { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }

  Default fl_max To .f.
  If ( k := r + 14 ) > MaxRow() -2
    k := MaxRow() -2
  Endif
  If c + 35 > 77
    c := 77 -35
  Endif
  t_mas := AClone( mas_s )
  If fl_max  // принудительное полное заполнение
    AEval( mas, {| x| AAdd( st_pozic, x ) } )
  Endif
  AEval( t_mas, {| x, i| ;
    t_mas[ i ] := if( AScan( st_pozic, mas[ i ] ) > 0, " * ", "   " ) + t_mas[ i ] } )
  status_key( "^<Esc>^ - отказ ^<Enter>^ - подтверждение ^<Ins>^ - смена признака выбора" )
  Do While .t.
    l_a_pozic := NIL
    If Popup( r, c, k, c + 35, t_mas, i, color0, .t., "fmenu_reader",, "Колонки информации", "B/BG" ) > 0
      l_a_pozic := {} ; st_pozic := {}
      For i := 1 To 15
        If "*" == SubStr( t_mas[ i ], 2, 1 )
          AAdd( l_a_pozic, { ( i -1 ), AllTrim( mas_s[ i ] ), } )
          AAdd( st_pozic, mas[ i ] )
        Endif
      Next
      If Empty( l_a_pozic )
        // func_error(4,"Необходимо отметить хотя бы один источник финансирования!")
        // loop
        Exit
      Else
        Exit
      Endif
    Else
      Exit
    Endif
  Enddo
  RestScreen( buf )

  Return l_a_pozic


//

// 13.02.16
Function k_statist( k )

  Static si := 1, si1 := 1, si2 := 1
  Local mas_pmt := { "~Реестр доплат", ;
    "П~ерсонал + услуги", ;
    "У~слуги + персонал" }
  Local mas_msg := { "Реестр доплат (за период времени)", ;
    "Статистика по работе персонала + оказанные услуги", ;
    "Статистика по оказанию конкретных услуг + персонал" }
  Local mas_fun := { "k_statist(11)", ;
    "k_statist(12)", ;
    "k_statist(13)" }
  Local i, buf

  If k < 10
    pi := 2
  Else
    si := k
  Endif
  Do Case
  Case k < 10
    If glob_pl_reg == 1 .or. ( Type( "mek_kassa" ) == "N" .and. mek_kassa == 2 ) //
      AAdd( mas_pmt, "~Больные + квитанции" )
      AAdd( mas_msg, "Больные + квитанции" )
      AAdd( mas_fun, "k_statist(14)" )
      //
      AAdd( mas_pmt, "Больные + ~услуги" )
      AAdd( mas_msg, "Больные + услуги" )
      AAdd( mas_fun, "k_statist(15)" )
      //
      AAdd( mas_pmt, "~Книжки + квитанции" )
      AAdd( mas_msg, "Список квитанционных книжек (с диапазонами квитанций) за период времени" )
      AAdd( mas_fun, "k_statist(16)" )
      //
      AAdd( mas_pmt, "Сдача ~выручки" )
      AAdd( mas_msg, "Оформление реестра платных услуг при сдаче выручки" )
      AAdd( mas_fun, "k_statist(17)" )
    Endif
    popup_prompt( T_ROW, T_COL -5, si, mas_pmt, mas_msg, mas_fun )
  Otherwise
    If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) != NIL
      Do Case
      Case k == 11
        f1r_s_plat( 1 )
      Case k == 12
        f2r_spl_plat( 1 )  // персонал + услуги по номеру квит.книжки
      Case k == 13
        f2r_spl_plat( 2 )  // услуги + персонал по номеру квит.книжки
      Case k == 14
        f3r_s_plat( 1 )  // больные + квитанции по номеру квит.книжки
      Case k == 15
        f4r_s_plat( 1 )  // больные + услуги по номеру квит.книжки
      Case k == 16
        f5r_s_plat()   // книжки + квитанции за период времени
      Case k == 17
        pl_vyruchka()
      Endcase
    Endif
  Endcase

  Return Nil

//

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
      arr_title, name_file := cur_dir() + "r_dohod.txt", arr_m
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
dbcreate(cur_dir()+"tmp", arr)
use (cur_dir()+"tmp")
index on str(tip,1)+str(kod,3) to (cur_dir()+"tmpk")
index on str(tip,1)+upper(name) to (cur_dir()+"tmpn")
use (cur_dir()+"tmp") index (cur_dir()+"tmpk"),(cur_dir()+"tmpn") alias TMP
//G_Use(dir_server()+"cena_usl",dir_server()+"cena_usl","CENA")
G_Use(dir_server()+"uslugi",,"USL")
G_Use(dir_server()+"hum_p_u",dir_server()+"hum_p_u","HU")
G_Use(dir_server()+"hum_p",dir_server()+"hum_pd","HUMAN")
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
  G_Use(dir_server()+"otdeleni",,"OTD")
  G_Use(dir_server()+"slugba",dir_server()+"slugba","SL")
  use (cur_dir()+"tmp") index (cur_dir()+"tmpk"),(cur_dir()+"tmpn") new alias TMP
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

//

//
Function f1r_s_plat()

  Local i, j, arr, begin_date, end_date, s, buf := save_row( MaxRow() ), ;
    fl_exit := .f., sh, HH := 57, reg_print, lyear, slyear, speriod, ;
    arr_title, name_file := cur_dir() + "r_dopl.txt", old_vr := 0, ;
    vstoim := 0, sstoim := 0, blk
  Private arr_m, kv[ 2 ]

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  speriod := arr_m[ 4 ]
  begin_date := arr_m[ 7 ]
  end_date := arr_m[ 8 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  dbCreate( cur_dir() + "tmp", { { "n_kvit", "N", 5, 0 }, ; // номер квитанционной книжки
  { "kv_cia", "N", 6, 0 }, ; // номер квитанции
  { "U_KOD", "N", 4, 0 }, ; // код услуги
  { "SHIFR", "C", 10, 0 }, ; // шифр услуги
  { "KOD_VR", "N", 4, 0 }, ; // код врача
  { "KOL", "N", 5, 0 }, ; // количество услуг
  { "STOIM", "N", 10, 2 } } ) // итоговая стоимость услуги
  Use ( cur_dir() + "tmp" )
  Index On Str( kod_vr, 4 ) + Str( n_kvit, 5 ) + Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
  Index On Str( kod_vr, 4 ) + Str( n_kvit, 5 ) + fsort_usl( shifr ) to ( cur_dir() + "tmpn" )
  dbCreate( cur_dir() + "tmpt", { { "n_kvit", "N", 5, 0 }, ; // номер квитанционной книжки
  { "STOIM", "N", 10, 2 } } ) // итоговая стоимость услуги
  Use ( cur_dir() + "tmpt" )
  Index On Str( n_kvit, 5 ) to ( cur_dir() + "tmpt" )
  dbCreate( cur_dir() + "tmpu", { { "U_KOD", "N", 4, 0 }, ; // код услуги
  { "SHIFR", "C", 10, 0 }, ; // шифр услуги
  { "KOL", "N", 5, 0 }, ; // количество услуг
  { "STOIM", "N", 10, 2 } } ) // итоговая стоимость услуги
  Use ( cur_dir() + "tmpu" )
  Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpuk" )
  Index On fsort_usl( shifr ) to ( cur_dir() + "tmpun" )
  Close databases
  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmpk" ), ( cur_dir() + "tmpn" ) New Alias TMP
  Use ( cur_dir() + "tmpt" ) index ( cur_dir() + "tmpt" ) New Alias TMPT
  Use ( cur_dir() + "tmpu" ) index ( cur_dir() + "tmpuk" ), ( cur_dir() + "tmpun" ) New Alias TMPU
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_p",, "HP" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_ud", "HPU" )
  Set Relation To kod into HP, To u_kod into USL
  dbSeek( arr_m[ 7 ], .t. )
  Do While hpu->date_u <= arr_m[ 8 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If f_is_uch( st_a_uch, hp->lpu )
      Select TMP
      find ( Str( hpu->kod_vr, 4 ) + Str( hp->n_kvit, 5 ) + Str( hpu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmp->kod_vr := hpu->kod_vr
        tmp->n_kvit := hp->n_kvit
        tmp->u_kod  := hpu->u_kod
        tmp->shifr  := usl->shifr
      Endif
      tmp->kol += hpu->kol
      tmp->stoim += hpu->stoim
      //
      Select TMPT
      find ( Str( hp->n_kvit, 5 ) )
      If !Found()
        Append Blank
        tmpt->n_kvit := hp->n_kvit
      Endif
      tmpt->stoim += hpu->stoim
      //
      Select TMPU
      find ( Str( hpu->u_kod, 4 ) )
      If !Found()
        Append Blank
        tmpu->u_kod  := hpu->u_kod
        tmpu->shifr  := usl->shifr
      Endif
      tmpu->kol += hpu->kol
      tmpu->stoim += hpu->stoim
    Endif
    Select HPU
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    reg_print := 1
    arr_title := { ;
      "───────────────────────────┬─────┬──────────┬─────┬─────────────", ;
      "                           │№ кв.│   Шифр   │ Кол.│  Стоимость  ", ;
      "  Врач                     │книжк│  услуги  │услуг│    услуг    ", ;
      "───────────────────────────┴─────┴──────────┴─────┴─────────────" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( Center( "Реестр доплат", sh ) )
    titlen_uch( st_a_uch, sh )
    add_string( Center( speriod, sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    g_use( dir_server() + "mo_pers",, "PERSO" )
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmpn" ) New Alias TMP
    Set Relation To kod_vr into PERSO
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If old_vr != tmp->kod_vr
        If old_vr != 0
          add_string( Space( sh -20 ) + Replicate( "-", 20 ) )
          add_string( Space( sh -20 ) + "Итого:" + PadL( expand_value( vstoim, 2 ), 14 ) )
          vstoim := 0
        Endif
        add_string( "[" + lstr( ret_tabn( tmp->kod_vr ) ) + "] " + AllTrim( perso->fio ) )
      Endif
      add_string( Space( 27 ) + Str( tmp->n_kvit, 5 ) + "  " + tmp->shifr + ;
        Str( tmp->kol, 6 ) + PadL( expand_value( tmp->stoim, 2 ), 14 ) )
      old_vr := tmp->kod_vr
      vstoim += tmp->stoim
      sstoim += tmp->stoim
      Select TMP
      Skip
    Enddo
    add_string( Space( sh -20 ) + Replicate( "-", 20 ) )
    add_string( Space( sh -20 ) + "Итого:" + PadL( expand_value( vstoim, 2 ), 14 ) )
    add_string( Replicate( "─", sh ) )
    add_string( Space( sh -20 ) + "ВСЕГО:" + PadL( expand_value( sstoim, 2 ), 14 ) )
    add_string( Replicate( "─", sh ) )
    //
    If verify_ff( HH -2, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( Space( 15 ) + "в том числе:" )
    Use ( cur_dir() + "tmpt" ) index ( cur_dir() + "tmpt" ) new
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( Space( 21 ) + "кв.кн." + Str( tmpt->n_kvit, 5 ) + ;
        Space( 18 ) + PadL( expand_value( tmpt->stoim, 2 ), 14 ) )
      Skip
    Enddo
    //
    If verify_ff( HH -2, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( Space( 15 ) + "в том числе:" )
    Use ( cur_dir() + "tmpu" ) index ( cur_dir() + "tmpun" ) new
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( Space( 34 ) + tmpu->shifr + ;
        Str( tmpu->kol, 6 ) + PadL( expand_value( tmpu->stoim, 2 ), 14 ) )
      Skip
    Enddo
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

//

//
Function f2r_spl_plat( reg )

  Static snomer := 1, sreg1 := 1
  Local i, j, k, arr[ 2 ], s, buf := save_row( MaxRow() ), buf1, reg1, ;
    fl_exit := .f., sh, HH := 57, reg_print, ;
    arr_title, name_file := cur_dir() + "n_kvit.txt", ;
    vstoim := 0, sstoim := 0, old := 0, up_usl, ;
    speriod, begin_date, end_date, cp := " "

  If ( mnomer := input_value( 18, 12, 20, 67, color1, ;
      "Введите необходимый номер квитанционной книжки", ;
      snomer, "99999" ) ) == NIL
    Return Nil
  Endif
  snomer := mnomer
  buf1 := box_shadow( 0, 0, 0, 30, color8, "Квитанционная книжка N " + lstr( mnomer ),, 0 )
  If ( reg1 := popup_prompt( T_ROW, T_COL -5, sreg1, ;
      { "В ~целом по квитанционной книжке", ;
      "За ~период времени" } ) ) == 0
    rest_box( buf1 )
    Return Nil
  Elseif reg1 == 2 .and. ( arr_m := year_month() ) == NIL
    rest_box( buf1 )
    Return Nil
  Endif
  sreg1 := reg1
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  dbCreate( cur_dir() + "tmp", { { "U_KOD", "N", 4, 0 }, ; // код услуги
  { "KOD_VR", "N", 4, 0 }, ; // код врача
  { "KOL", "N", 5, 0 }, ; // количество услуг
  { "STOIM", "N", 10, 2 } } ) // итоговая стоимость услуги
  Use ( cur_dir() + "tmp" )
  Index On Str( kod_vr, 4 ) + Str( u_kod, 4 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "uslugi", dir_server() + "uslugi", "USL" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HPU" )
  r_use( dir_server() + "hum_p", dir_server() + "hum_pv", "HP" )
  dbSeek( Str( mnomer, 5 ) )
  Do While hp->n_kvit == mnomer .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If f_is_uch( st_a_uch, hp->lpu )
      Select HPU
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While hpu->kod == hp->( RecNo() )
        If if( reg1 == 1, .t., Between( hpu->date_u, arr_m[ 7 ], arr_m[ 8 ] ) )
          Select TMP
          find ( Str( hpu->kod_vr, 4 ) + Str( hpu->u_kod, 4 ) )
          If !Found()
            Append Blank
            tmp->kod_vr := hpu->kod_vr
            tmp->u_kod  := hpu->u_kod
          Endif
          tmp->kol += hpu->kol
          tmp->stoim += hpu->stoim
        Endif
        Select HPU
        Skip
      Enddo
    Endif
    Select HP
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    // ничего
  Elseif j == 0
    func_error( 4, "Нет сведений по квитанционной книжке номер " + lstr( mnomer ) )
  Else
    mywait()
    reg_print := 2
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "mo_pers",, "PERSO" )
    Use ( cur_dir() + "tmp" ) New Alias TMP
    Set Relation To kod_vr into PERSO, To u_kod into USL
    If reg == 1
      Index On Str( kod_vr, 4 ) + fsort_usl( usl->shifr ) to ( cur_dir() + "tmp" )
    Elseif reg == 2
      Index On Str( u_kod, 4 ) + fsort_usl( usl->shifr ) + Str( kod_vr, 4 ) to ( cur_dir() + "tmp" )
    Endif
    arr_title := { ;
      "───────────────────────────────────────────────────────────┬─────┬─────────────", ;
      "                                                           │ Кол.│  Стоимость  ", ;
      "                                                           │услуг│    услуг    ", ;
      "───────────────────────────────────────────────────────────┴─────┴─────────────" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    titlen_uch( st_a_uch, sh )
    add_string( "" )
    add_string( Center( "Статистика по квитанционной книжке N " + lstr( mnomer ), sh ) )
    If reg1 == 2
      add_string( "" )
      add_string( Center( arr_m[ 4 ], sh ) )
    Endif
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If reg == 1
        If old != tmp->kod_vr
          If old != 0
            add_string( Space( sh -20 ) + Replicate( "-", 20 ) )
            add_string( Space( sh -20 ) + "Итого:" + PadL( expand_value( vstoim, 2 ), 14 ) )
            vstoim := 0
          Endif
          add_string( "" )
          add_string( "[" + lstr( ret_tabn( tmp->kod_vr ) ) + "] " + AllTrim( perso->fio ) )
          old := tmp->kod_vr
        Endif
        k := perenos( arr, AllTrim( usl->shifr ) + ". " + AllTrim( usl->name ), 55 )
      Else
        If old != tmp->u_kod
          If old != 0
            add_string( Space( sh -20 ) + Replicate( "-", 20 ) )
            add_string( Space( sh -20 ) + "Итого:" + PadL( expand_value( vstoim, 2 ), 14 ) )
            vstoim := 0
          Endif
          add_string( "" )
          add_string( AllTrim( usl->shifr ) + ". " + AllTrim( usl->name ) )
          old := tmp->u_kod
        Endif
        k := perenos( arr, "[" + lstr( ret_tabn( tmp->kod_vr ) ) + "] " + AllTrim( perso->fio ), 55 )
      Endif
      add_string( Space( 4 ) + PadR( AllTrim( arr[ 1 ] ), 55, cp ) + ;
        PadL( lstr( tmp->kol ), 6, cp ) + ;
        PadL( expand_value( tmp->stoim, 2 ), 14, cp ) )
      For i := 2 To k
        add_string( Space( 4 ) + PadL( AllTrim( arr[ i ] ), 55 ) )
      Next
      vstoim += tmp->stoim ; sstoim += tmp->stoim
      Select TMP
      Skip
    Enddo
    add_string( Space( sh -20 ) + Replicate( "-", 20 ) )
    add_string( Space( sh -20 ) + "Итого:" + PadL( expand_value( vstoim, 2 ), 14 ) )
    add_string( Replicate( "═", sh ) )
    add_string( Space( sh -20 ) + "ИТОГО:" + PadL( expand_value( sstoim, 2 ), 14 ) )
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  If buf1 != NIL
    rest_box( buf1 )
  Endif

  Return Nil

//

//
Function f3r_s_plat()

  Static snomer := 1, sreg1 := 1
  Local i, j, k, arr[ 2 ], s, buf := save_row( MaxRow() ), buf1, reg1, ;
    fl_exit := .f., sh, HH := 57, reg_print, ;
    arr_title, name_file := cur_dir() + "n_kvitan.txt", ;
    vstoim := 0, sstoim := 0, old := 0, ;
    speriod, begin_date, end_date, cp := " ", ss := 0

  If ( mnomer := input_value( 18, 12, 20, 67, color1, ;
      "Введите необходимый номер квитанционной книжки", ;
      snomer, "99999" ) ) == NIL
    Return Nil
  Endif
  snomer := mnomer
  buf1 := box_shadow( 0, 0, 0, 30, color8, "Квитанционная книжка N " + lstr( mnomer ),, 0 )
  If ( reg1 := popup_prompt( T_ROW, T_COL -5, sreg1, ;
      { "В ~целом по квитанционной книжке", ;
      "За ~период времени" } ) ) == 0
    rest_box( buf1 )
    Return Nil
  Elseif reg1 == 2 .and. ( arr_m := year_month() ) == NIL
    rest_box( buf1 )
    Return Nil
  Endif
  sreg1 := reg1
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  dbCreate( cur_dir() + "tmp", { { "kod_k", "N", 7, 0 }, ; // код больного по картотеке
  { "kv_cia", "N", 6, 0 }, ; // номер квитанции
  { "pdate", "C", 4, 0 }, ;
    { "KOL", "N", 5, 0 }, ; // количество услуг
  { "STOIM", "N", 10, 2 } } ) // итоговая стоимость услуги
  Use ( cur_dir() + "tmp" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HPU" )
  r_use( dir_server() + "hum_p", dir_server() + "hum_pv", "HP" )
  dbSeek( Str( mnomer, 5 ) )
  Do While hp->n_kvit == mnomer .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If f_is_uch( st_a_uch, hp->lpu ) .and. ;
        if( reg1 == 1, .t., Between( hp->pdate, arr_m[ 7 ], arr_m[ 8 ] ) )
      Select TMP
      Append Blank
      tmp->kod_k := hp->kod_k
      tmp->kv_cia := hp->kv_cia
      tmp->pdate := hp->pdate
      Select HPU
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While hpu->kod == hp->( RecNo() )
        tmp->kol += hpu->kol
        tmp->stoim += hpu->stoim
        Select HPU
        Skip
      Enddo
    Endif
    Select HP
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    // ничего
  Elseif j == 0
    func_error( 4, "Нет сведений по квитанционной книжке номер " + lstr( mnomer ) )
  Else
    mywait()
    reg_print := 2
    r_use( dir_server() + "kartotek",, "KART" )
    Use ( cur_dir() + "tmp" ) New Alias TMP
    Set Relation To kod_k into KART
    Index On Str( kv_cia, 6 ) + pdate to ( cur_dir() + "tmp" )
    arr_title := { ;
      "───────────────────────────────────────────┬────────┬──────┬─────┬─────────────", ;
      "                                           │  Дата  │№ кви-│ Кол.│  Стоимость  ", ;
      "         Ф.И.О. больного                   │ оплаты │танции│услуг│    услуг    ", ;
      "───────────────────────────────────────────┴────────┴──────┴─────┴─────────────" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    titlen_uch( st_a_uch, sh )
    add_string( "" )
    add_string( Center( "Статистика по квитанционной книжке N " + lstr( mnomer ), sh ) )
    If reg1 == 2
      add_string( "" )
      add_string( Center( arr_m[ 4 ], sh ) )
    Endif
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( Left( kart->fio, 43 ) + " " + date_8( c4tod( tmp->pdate ) ) + ;
        put_val( tmp->kv_cia, 7 ) + ;
        Str( tmp->kol, 6 ) + PadL( expand_value( tmp->stoim, 2 ), 14 ) )
      ss += tmp->stoim
      Select TMP
      Skip
    Enddo
    add_string( Replicate( "─", sh ) )
    add_string( PadR( lstr( tmp->( LastRec() ) ) + " чел.", 20 ) + PadL( "Итого : " + lput_kop( ss ), sh -20 ) )
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  If buf1 != NIL
    rest_box( buf1 )
  Endif

  Return Nil

//

//
Function f4r_s_plat()

  Local lyear, slyear, s_date, arr_kv := { { 1, 999999 } }, buf, ;
    mas12 := { { 1, " с ..." }, { 2, "по ..." } }, mpic := { { 6, 0 }, { 6, 0 } }, ;
    blk := {| b, ar, nDim, nElem, nKey| f1_s_vyruchka( b, ar, nDim, nElem, nKey ) }, ;
    i, j, k, arr[ 2 ], s, buf1, reg1, min_date, max_date, ;
    fl_exit := .f., sh, HH := 78, reg_print, ;
    arr_title, name_file := cur_dir() + "boln_usl.txt", ;
    vstoim := 0, sstoim := 0, old := 0, arr_otd, ;
    speriod, begin_date, end_date, cp := " ", ss := 0

  If ( lyear := input_value( 20, 15, 22, 64, color1, ;
      "За какой год желаете получить информацию", ;
      Year( sys_date ), "9999" ) ) == NIL
    Return Nil
  Endif
  slyear := Chr( Val( SubStr( StrZero( lyear, 4 ), 1, 2 ) ) ) + ;
    Chr( Val( SubStr( StrZero( lyear, 4 ), 3, 2 ) ) )
  arrn_browse( T_ROW, T_COL -5, MaxRow() -2, T_COL + 15, arr_kv, mas12, 1,, color0, ;
    "Квитанции", col_tit_popup,,, mpic, blk, { .t., .t., .t. } )
  If !f_esc_enter( "поиска" )
    Return Nil
  Endif
  buf := save_row( MaxRow() )
  mywait()
  ASort( arr_kv,,, {| x, y| x[ 1 ] < y[ 1 ] } )
  k := Len( arr_kv )
  For i := k To 1 Step -1
    If emptyany( arr_kv[ i, 1 ], arr_kv[ i, 2 ] )
      ADel( arr_kv, i ) ; --k
    Endif
  Next
  //
  dbCreate( cur_dir() + "tmp", { { "kod_k", "N", 7, 0 }, ; // код больного по картотеке
  { "rec_hp", "N", 7, 0 }, ; // номер записи по базе "hum_p"
  { "kv_cia", "N", 6, 0 }, ; // номер квитанции
  { "KOL", "N", 5, 0 }, ; // количество услуг
  { "STOIM", "N", 10, 2 } } ) // итоговая стоимость услуги
  Use ( cur_dir() + "tmp" )
  g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HPU" )
  g_use( dir_server() + "hum_p",, "HP" )
  If glob_mo[ _MO_KOD_TFOMS ] == '114504' // Поликлиника 4
    Index On n_kvit to ( cur_dir() + "tmp_hp" ) ;
      For f_is_uch( st_a_uch, hp->lpu ) .and. Left( hp->pdate, 2 ) == slyear ;
      .and. AScan( arr_kv, {| x| Between( hp->N_kvit, x[ 1 ], x[ 2 ] ) } ) > 0
  Else
    Index On n_kvit to ( cur_dir() + "tmp_hp" ) ;
      For f_is_uch( st_a_uch, hp->lpu ) .and. Left( hp->pdate, 2 ) == slyear ;
      .and. AScan( arr_kv, {| x| Between( hp->kv_cia, x[ 1 ], x[ 2 ] ) } ) > 0
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  Go Top
  min_date := max_date := hp->pdate
  Do While !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    Select TMP
    Append Blank
    tmp->kod_k := hp->kod_k
    tmp->kv_cia := hp->kv_cia
    tmp->rec_hp := hp->( RecNo() )
    If hp->pdate > max_date
      max_date := hp->pdate
    Elseif hp->pdate < min_date
      min_date := hp->pdate
    Endif
    Select HPU
    find ( Str( hp->( RecNo() ), 7 ) )
    Do While hpu->kod == hp->( RecNo() )
      tmp->kol += hpu->kol
      tmp->stoim += hpu->stoim
      Select HPU
      Skip
    Enddo
    Select HP
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    // ничего
  Elseif j == 0
    func_error( 4, "Нет сведений по выбранным квитанциям" )
  Else
    mywait()
    reg_print := 5
    g_use( dir_server() + "plat_ms", dir_server() + "plat_ms", "MS" )
    g_use( dir_server() + "uslugi",, "USL" )
    g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HPU" )
    Set Relation To u_kod into USL
    g_use( dir_server() + "mo_otd",, "OTD" )
    g_use( dir_server() + "hum_p",, "HP" )
    Set Relation To otd into OTD
    g_use( dir_server() + "kartotek",, "KART" )
    Use ( cur_dir() + "tmp" ) New Alias TMP
    Set Relation To kod_k into KART, To rec_hp into HP
    Index On Str( kv_cia, 6 ) to ( cur_dir() + "tmp" )
    arr_title := { ;
      "─────┬──────────┬────────────────────────────────────────────┬──────┬─────┬─────────", ;
      "Отде-│Номер амб.│ Ф.И.О. больного                            │№ кви-│ Кол.│Стоимость", ;
      "ление│  карты   │                                            │танции│услуг│  услуг  ", ;
      "─────┴─────────┬┴────┬─────────────────┬─────────────────┬───┴──────┤     │         ", ;
      "           Врач│ Асс.│ Медсестры       │ Санитарки       │  Услуги  │     │         ", ;
      "───────────────┴─────┴─────────────────┴─────────────────┴──────────┴─────┴─────────" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    titlen_uch( st_a_uch, sh )
    add_string( "" )
    add_string( Center( "Реестр платных услуг", sh ) )
    If min_date == max_date
      add_string( Center( "за " + date_month( c4tod( max_date ), .t. ), sh ) )
    Else
      add_string( Center( full_date( c4tod( min_date ) ) + " - " + full_date( c4tod( max_date ) ), sh ) )
    Endif
    add_string( "" )
    arr_otd := {}
    AEval( arr_title, {| x| add_string( x ) } )
    Go Top
    Do While !Eof()
      If verify_ff( HH -1, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If ( i := AScan( arr_otd, {| x| x[ 1 ] == hp->otd } ) ) == 0
        AAdd( arr_otd, { hp->otd, otd->name, 0, 0 } ) ; i := Len( arr_otd )
      Endif
      arr_otd[ i, 3 ] += tmp->stoim
      arr_otd[ i, 4 ] ++
      s := otd->short_name + " " + ;
        PadR( amb_kartan(), 11 ) + ;
        PadR( kart->fio, 44 ) + ;
        put_val( tmp->kv_cia, 7 ) + ;
        Str( tmp->kol, 4 ) + ;
        put_kope( tmp->stoim, 12 )
      add_string( s )
      add_string( Replicate( "-", sh ) )
      Select HPU
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While hpu->kod == hp->( RecNo() )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        mkod_vr := mkod_as := 0
        mkod_ms := mkod_san := ""
        // if mem_tabnom == 1
        // mkod_vr := hpu->kod_vr
        // mkod_as := hpu->kod_as
        // else
        mkod_vr := ret_tabn( hpu->kod_vr )
        mkod_as := ret_tabn( hpu->kod_as )
        // endif
        Select MS
        If hpu->med1 > 0
          Goto ( hpu->med1 )
          If !Eof() .and. ms->tip == 1
            mkod_ms += AllTrim( lstr( ms->tab_nom ) ) + " "
          Endif
        Endif
        If hpu->med2 > 0
          Goto ( hpu->med2 )
          If !Eof() .and. ms->tip == 1
            mkod_ms += AllTrim( lstr( ms->tab_nom ) ) + " "
          Endif
        Endif
        If hpu->med3 > 0
          Goto ( hpu->med3 )
          If !Eof() .and. ms->tip == 1
            mkod_ms += AllTrim( lstr( ms->tab_nom ) ) + " "
          Endif
        Endif
        If hpu->san1 > 0
          Goto ( hpu->san1 )
          If !Eof() .and. ms->tip == 2
            mkod_san += AllTrim( lstr( ms->tab_nom ) ) + " "
          Endif
        Endif
        If hpu->san2 > 0
          Goto ( hpu->san2 )
          If !Eof() .and. ms->tip == 2
            mkod_san += AllTrim( lstr( ms->tab_nom ) ) + " "
          Endif
        Endif
        If hpu->san3 > 0
          Goto ( hpu->san3 )
          If !Eof() .and. ms->tip == 2
            mkod_san += AllTrim( lstr( ms->tab_nom ) ) + " "
          Endif
        Endif
        s := put_val( mkod_vr, 15 ) + ;
          put_val( mkod_as, 6 ) + " " + ;
          PadR( mkod_ms, 17 ) + " " + ;
          PadR( mkod_san, 17 ) + " " + ;
          usl->shifr + ;
          Str( hpu->kol, 4 ) + ;
          put_kope( hpu->stoim, 12 )
        add_string( s )
        //
        Select HPU
        Skip
      Enddo
      add_string( Replicate( "=", sh ) )
      ss += tmp->stoim
      Select TMP
      Skip
    Enddo
    If verify_ff( HH - Len( arr_otd ) -1, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( PadR( lstr( tmp->( LastRec() ) ) + " чел.", 20 ) + PadL( "Итого : " + lput_kop( ss ), sh -20 ) )
    Close databases
    ASort( arr_otd, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
    For i := 1 To Len( arr_otd )
      s := iif( i == 1, "По отделениям: ", "" )
      add_string( PadL( s + AllTrim( arr_otd[ i, 2 ] ), 45 ) + ;
        put_kope( arr_otd[ i, 3 ], 12 ) + " руб. " + ;
        Str( arr_otd[ i, 4 ], 5 ) + " чел." )
    Next
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  If buf1 != NIL
    rest_box( buf1 )
  Endif

  Return Nil

//

//
Function f5r_s_plat()

  Local buf, i, k, mas12, arr_m, n_file := cur_dir() + "spis_kvi.txt", sh := 64, ssum := 0

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  buf := save_row( MaxRow() )
  mywait()
  dbCreate( cur_dir() + "tmp", { { "n_kvit", "N", 5, 0 }, ; // номер квитанционной книжки
  { "kv_cia", "N", 6, 0 }, ; // номер квитанции
  { "stoim", "N", 10, 2 } } ) // сумма квитанции
  Use ( cur_dir() + "tmp" )
  Index On Str( kv_cia, 6 ) to ( cur_dir() + "tmp" )
  g_use( dir_server() + "hum_p",, "HP" )
  Index On n_kvit to ( cur_dir() + "tmp_hp" ) ;
    For f_is_uch( st_a_uch, hp->lpu ) .and. Between( hp->pdate, arr_m[ 7 ], arr_m[ 8 ] )
  Go Top
  Do While !Eof()
    Select TMP
    find ( Str( hp->kv_cia, 6 ) )
    If !Found()
      Append Blank
      tmp->n_kvit := hp->n_kvit
      tmp->kv_cia := hp->kv_cia
      tmp->stoim := hp->cena
      ssum += hp->cena
    Endif
    Select HP
    Skip
  Enddo
  //
  Select TMP
  Index On Str( n_kvit, 5 ) + Str( kv_cia, 6 ) to ( cur_dir() + "tmp" )
  Go Top
  mas12 := {} ; AAdd( mas12, { tmp->n_kvit, tmp->kv_cia, tmp->kv_cia, 0 } ) ; i := 1
  Do While !Eof()
    If mas12[ i, 1 ] == tmp->n_kvit
      If tmp->kv_cia - mas12[ i, 3 ] > 1
        AAdd( mas12, { tmp->n_kvit, tmp->kv_cia, tmp->kv_cia, 0 } ) ; ++i
      Else
        mas12[ i, 3 ] := tmp->kv_cia
      Endif
    Else
      AAdd( mas12, { tmp->n_kvit, tmp->kv_cia, tmp->kv_cia, 0 } ) ; ++i
    Endif
    Skip
  Enddo
  Go Top
  Do While !Eof()
    If ( i := AScan( mas12, {| x| x[ 1 ] == tmp->n_kvit .and. ;
        Between( tmp->kv_cia, x[ 2 ], x[ 3 ] ) } ) ) > 0
      mas12[ i, 4 ] += tmp->stoim
    Endif
    Skip
  Enddo
  Close databases
  fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "РЕЕСТР ПЛАТНЫХ УСЛУГ", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( "" )
  old_kn := 0
  For i := 1 To Len( mas12 )
    If mas12[ i, 1 ] != old_kn
      add_string( "" )
      add_string( Center( "Квитанционная книжка N " + lstr( mas12[ i, 1 ] ), sh ) )
      old_kn := mas12[ i, 1 ]
    Endif
    If mas12[ i, 2 ] == mas12[ i, 3 ]
      add_string( PadR( "Квитанция N " + lstr( mas12[ i, 2 ] ), 32 ) + ;
        PadL( expand_value( mas12[ i, 4 ], 2 ), sh -32 ) )
    Else
      add_string( PadR( "Квитанции с N " + lstr( mas12[ i, 2 ] ) + " по N " + lstr( mas12[ i, 3 ] ), 32 ) + ;
        PadL( expand_value( mas12[ i, 4 ], 2 ), sh -32 ) )
    Endif
  Next
  add_string( "" )
  add_string( "Общая сумма:  " + expand_value( ssum, 2 ) )
  For j := 1 To perenos( mas12, "Сумма прописью:  " + srub_kop( ssum, .t. ), sh )
    add_string( mas12[ j ] )
  Next
  FClose( fp )
  rest_box( buf )
  viewtext( n_file )

  Return Nil

//

//
Function pl_vyruchka()

  Local lyear, slyear, s_date, arr_kv := { { 1, 999999 } }, buf, i, k, ;
    mas12 := { { 1, " с ..." }, { 2, "по ..." } }, mpic := { { 6, 0 }, { 6, 0 } }, ;
    blk := {| b, ar, nDim, nElem, nKey| f1_s_vyruchka( b, ar, nDim, nElem, nKey ) }, ;
    n_file := cur_dir() + "s_vyruch.txt", sh := 64, ssum := 0, hGauge

  If ( lyear := input_value( 20, 15, 22, 64, color1, ;
      "За какой год желаете получить информацию", ;
      Year( sys_date ), "9999" ) ) == NIL
    Return Nil
  Endif
  slyear := Chr( Val( SubStr( StrZero( lyear, 4 ), 1, 2 ) ) ) + ;
    Chr( Val( SubStr( StrZero( lyear, 4 ), 3, 2 ) ) )
  s_date := input_value( 18, 10, 20, 69, color1, ;
    Space( 9 ) + "Введите дату сдачи выручки", ;
    sys_date )
  If s_date == NIL
    Return Nil
  Endif
  arrn_browse( T_ROW, T_COL -5, MaxRow() -2, T_COL + 15, arr_kv, mas12, 1,, color0, ;
    "Квитанции", col_tit_popup,,, mpic, blk, { .t., .t., .t. } )
  If f_esc_enter( "поиска" )
    buf := save_row( MaxRow() )
    mywait()
    ASort( arr_kv,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    k := Len( arr_kv )
    For i := k To 1 Step -1
      If emptyany( arr_kv[ i, 1 ], arr_kv[ i, 2 ] )
        ADel( arr_kv, i ) ; --k
      Endif
    Next
    dbCreate( cur_dir() + "tmp", { { "n_kvit", "N", 5, 0 }, ; // номер квитанционной книжки
    { "kv_cia", "N", 6, 0 }, ; // номер квитанции
    { "stoim", "N", 10, 2 } } ) // сумма квитанции
    Use ( cur_dir() + "tmp" )
    Index On Str( kv_cia, 6 ) to ( cur_dir() + "tmp" )
    g_use( dir_server() + "hum_p",, "HP" )
    Index On n_kvit to ( cur_dir() + "tmp_hp" ) ;
      For f_is_uch( st_a_uch, hp->lpu ) .and. Left( hp->pdate, 2 ) == slyear ;
      .and. AScan( arr_kv, {| x| Between( hp->kv_cia, x[ 1 ], x[ 2 ] ) } ) > 0
    Go Top
    Do While !Eof()
      Select TMP
      find ( Str( hp->kv_cia, 6 ) )
      If !Found()
        Append Blank
        tmp->n_kvit := hp->n_kvit
        tmp->kv_cia := hp->kv_cia
        tmp->stoim := hp->cena
        ssum += hp->cena
      Endif
      Select HP
      Skip
    Enddo
    //
    Select TMP
    Index On Str( n_kvit, 5 ) + Str( kv_cia, 6 ) to ( cur_dir() + "tmp" )
    Go Top
    mas12 := {} ; AAdd( mas12, { tmp->n_kvit, tmp->kv_cia, tmp->kv_cia, 0 } ) ; i := 1
    Do While !Eof()
      If mas12[ i, 1 ] == tmp->n_kvit
        If tmp->kv_cia - mas12[ i, 3 ] > 1
          AAdd( mas12, { tmp->n_kvit, tmp->kv_cia, tmp->kv_cia, 0 } ) ; ++i
        Else
          mas12[ i, 3 ] := tmp->kv_cia
        Endif
      Else
        AAdd( mas12, { tmp->n_kvit, tmp->kv_cia, tmp->kv_cia, 0 } ) ; ++i
      Endif
      Skip
    Enddo
    Go Top
    Do While !Eof()
      If ( i := AScan( mas12, {| x| x[ 1 ] == tmp->n_kvit .and. ;
          Between( tmp->kv_cia, x[ 2 ], x[ 3 ] ) } ) ) > 0
        mas12[ i, 4 ] += tmp->stoim
      Endif
      Skip
    Enddo
    Close databases
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "РЕЕСТР ПЛАТНЫХ УСЛУГ", sh ) )
    add_string( "" )
    old_kn := 0
    For i := 1 To Len( mas12 )
      If mas12[ i, 1 ] != old_kn
        add_string( "" )
        add_string( Center( "Квитанционная книжка N " + lstr( mas12[ i, 1 ] ), sh ) )
        old_kn := mas12[ i, 1 ]
      Endif
      If mas12[ i, 2 ] == mas12[ i, 3 ]
        add_string( PadR( "Квитанция N " + lstr( mas12[ i, 2 ] ), 32 ) + ;
          PadL( expand_value( mas12[ i, 4 ], 2 ), sh -32 ) )
      Else
        add_string( PadR( "Квитанции с N " + lstr( mas12[ i, 2 ] ) + " по N " + lstr( mas12[ i, 3 ] ), 32 ) + ;
          PadL( expand_value( mas12[ i, 4 ], 2 ), sh -32 ) )
      Endif
    Next
    add_string( "" )
    add_string( "Общая сумма:  " + expand_value( ssum, 2 ) )
    For j := 1 To perenos( mpic, "Сумма прописью:  " + srub_kop( ssum, .t. ), sh )
      add_string( mpic[ j ] )
    Next
    add_string( "" )
    add_string( 'Дата: ' + date_month( s_date ) )
    add_string( "" )
    add_string( "Подпись ________________" )
    FClose( fp )
    rest_box( buf )
    viewtext( n_file )
  Endif

  Return Nil

//
Function f1_s_vyruchka( b, ar, nDim, nElem, nKey )

  Local nRow := Row(), nCol := Col(), i, j, flag := .f., buf, ;
    mpic := { "9999", }

  Do Case
  Case nKey == K_DOWN .or. nKey == K_INS
    b:panhome()
  Case nKey == K_LEFT
    b:Left()
  Case nKey == K_RIGHT
    b:Right()
  Otherwise
    If ( nKey == K_ENTER .or. Between( nKey, 48, 57 ) )
      If Between( nKey, 48, 57 )
        Keyboard Chr( nKey )
      Endif
      Private mkod := parr[ nElem, nDim ]
      @ nRow, nCol Get mkod Picture "999999"
      myread( { "up", "down" } )
      If LastKey() != K_ESC
        parr[ nElem, nDim ] := mkod
        If nDim == 1
          b:Right()
        Endif
        flag := .t.
      Endif
    Endif
  Endcase
  @ nRow, nCol Say ""

  Return flag

//

//
Function po_proverka( k )

  Static si1 := 1, si2 := 1, si3 := 1
  Local mas_pmt, mas_msg, mas_fun, j, mdate, arr_gr
  Local uch_otd

  Default k To 1
  Do Case
  Case k == 1
    uch_otd := saveuchotd()
    Private p_net_otd := .t.
    mas_pmt := { "Не введен код ~врача", ;
      "Не введен код ~асистента", ;
      "Не введен код ~медсестры", ;
      "Не введен код ~санитарки" }
    mas_msg := { "Проверка листов учета на отсутствие кода врача", ;
      "Проверка листов учета на отсутствие кода асистента", ;
      "Проверка листов учета на отсутствие кода медсестер", ;
      "Проверка листов учета на отсутствие кода санитарок" }
    mas_fun := { "Po_proverka(11)", ;
      "Po_proverka(16)", ;
      "Po_proverka(12)", ;
      "Po_proverka(13)" }
    If mem_otdusl == 2 .and. currentuser():isadmin()
      AAdd( mas_pmt, "~Отделение не равно месту работы" )
      AAdd( mas_msg, "Проверка отделения на равенство месту основной работы персонала" )
      AAdd( mas_fun, "Po_proverka(14)" )
    Endif
    AAdd( mas_pmt, "~Сверка со счетами ОМС" )
    AAdd( mas_msg, "" )
    AAdd( mas_fun, "Po_proverka(15)" )
    AAdd( mas_pmt, "~Направитель==врач" )
    AAdd( mas_msg, "Проверка на совпадение врача и направителя" )
    AAdd( mas_fun, "Po_proverka(17)" )
    AAdd( mas_pmt, "~Направитель==асистент" )
    AAdd( mas_msg, "Проверка на совпадение асистента и направителя" )
    AAdd( mas_fun, "Po_proverka(18)" )
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
    restuchotd( uch_otd )
  Case k == 11
    If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) != NIL
      po_pr_vr_as( 1 )
    Endif
  Case k == 12
    If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) != NIL
      po_pr_vr_as( 2 )
    Endif
  Case k == 13
    If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) != NIL
      po_pr_vr_as( 3 )
    Endif
  Case k == 14
    If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) != NIL
      po_pr_ot_pe()
    Endif
  Case k == 15
    po_pr_oms()
  Case k == 16
    If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) != NIL
      po_pr_vr_as( 4 )
    Endif
  Case k == 17
    If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) != NIL
      po_isp_nap( 1 )
    Endif
  Case k == 18
    If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) != NIL
      po_isp_nap( 2 )
    Endif
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Elseif Between( k, 31, 39 )
      si3 := j
    Endif
  Endif

  Return Nil

//

//
Function po_isp_nap( reg )

  Local i, j, k, arr, fl, fl_exit := .f., buf := save_row( MaxRow() ), ;
    s, sh, HH := 57, arr_title, name_file := cur_dir() + "proverka.txt", ;
    arr_usl := {}

  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  If ( k := f_alert( { 'Каким образом производить проверку на исполнитель==направитель.', ;
      "Выберите действие:" }, ;
      { " По ~всем услугам ", ;
      " ~Исключая некоторые услуги " }, ;
      1, "N+/BG", "R/BG",,, col1menu ) ) == 0
    Return Nil
  Elseif k == 2
    dbCreate( cur_dir() + "tmp", { ;
      { "U_KOD",    "N",      4,      0 }, ;  // код услуги
    { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
    { "U_NAME",     "C",     65,      0 } } )  // наименование услуги
    Use ( cur_dir() + "tmp" )
    Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
    Close databases
    ob2_v_usl()
    Use ( cur_dir() + "tmp" )
    dbEval( {|| AAdd( arr_usl, tmp->u_kod ) } )
    Use
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  dbCreate( cur_dir() + "tmp", { { "rec", "N", 7, 0 }, { "rec_vr", "N", 6, 0 }, { "sum_usl", "N", 8, 2 } } )
  Use ( cur_dir() + "tmp" ) new
  g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  g_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUMAN" )
  dbSeek( DToS( arr[ 5 ] ), .t. )
  Do While human->k_data <= arr[ 6 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If f_is_uch( st_a_uch, human->lpu )
      fl := .f.
      tt_sm := 0
      Select HU
      find ( Str( human->( RecNo() ), 7 ) )
      Do While hu->kod == human->( RecNo() ) .and. !Eof()
        If AScan( arr_usl, hu->u_kod ) == 0
          If reg == 1
            If hu->kod_vr == human->kod_vr .and. hu->kod_vr > 0
              tt_sm += hu->stoim
              fl := .t. // ; exit
            Endif
          Elseif reg == 2
            If hu->kod_as == human->kod_vr .and. hu->kod_vr > 0
              tt_sm += hu->stoim
              fl := .t. // ; exit
            Endif
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If fl
        Select TMP
        Append Blank
        tmp->rec := human->( RecNo() )
        tmp->rec_vr := human->kod_vr
        tmp->sum_usl := tt_sm
      Endif
      tt_sm := 0
    Endif
    Select HUMAN
    Skip
  Enddo
  If tmp->( LastRec() ) > 0
    mywait()
    arr_title := { ;
      "─────────────────────────────────────────────────┬──────────┬──────────┬──────────┬──────────────────", ;
      "              Ф.И.О. больного                    │Дата окон.│ Сумма Cл │ Сумма Усл│   Направитель    ", ;
      "─────────────────────────────────────────────────┴──────────┴──────────┴──────────┴──────────────────" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "Список больных, у которых в оказанных услугах", sh ) )
    add_string( Center( "код направителя соответствует " + { "врачу", "асистенту" }[ reg ], sh ) )
    add_string( "" )
    add_string( Center( arr[ 4 ], sh ) )
    titlen_uch( st_a_uch, sh )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    //
    g_use( dir_server() + "MO_pers",, "PERSO" )
    g_use( dir_server() + "kartotek",, "KART" )
    Select HUMAN
    Set Index To
    Set Relation To kod_k into KART
    Select TMP
    Set Relation To rec into HUMAN
    Index On Upper( kart->fio ) to ( cur_dir() + "tmp" )
    Go Top
    i := 0
    hGauge := gaugenew(,,, "Создание текстового файла", .t. )
    gaugedisplay( hGauge )
    mas_vr := {}
    Do While !Eof()
      gaugeupdate( hGauge, ++i / LastRec() )
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      PERSO->( dbGoto( tmp->rec_vr ) )
      s := Str( i, 4 ) + ". " + Left( kart->fio, 43 ) + " " + full_date( human->k_data )
      add_string( s + put_kope( human->cena, 11 ) + " " + put_kope( tmp->sum_usl, 11 ) + " " + PadR( PERSO->fio, 18 ) )
      If ( t := AScan( mas_vr, {| x| x[ 1 ] == tmp->rec_vr } ) ) == 0
        AAdd( mas_vr, { tmp->rec_vr, PERSO->fio, human->cena, tmp->sum_usl } )
      Else
        mas_vr[ t, 3 ] += human->cena
        mas_vr[ t, 4 ] += tmp->sum_usl
      Endif
      Select TMP
      Skip
    Enddo
    //
    add_string( "" )
    arr_title := { ;
      "────────────────────────────────────────┬──────────┬──────────", ;
      "       Ф.И.О. Врача/медсестры           │ Сумма Cл │ Сумма Усл", ;
      "────────────────────────────────────────┴──────────┴──────────" }
    AEval( arr_title, {| x| add_string( x ) } )
    For i := 1 To Len( mas_vr )
      add_string( PadR( mas_vr[ i, 2 ], 40 ) + " " + put_kop( mas_vr[ i, 3 ], 11 ) + " " + put_kop( mas_vr[ i, 4 ], 11 ) )
    Next
    Close databases
    closegauge( hGauge )
    FClose( fp )
    viewtext( name_file,,,, .t.,,, 3 )
  Else
    func_error( 4, "Не обнаружено услуг с направлением себе!" )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

//

//
Function po_pr_vr_as( reg )

  Local i, j, k, arr, fl, fl_exit := .f., buf := save_row( MaxRow() ), ;
    s, sh, HH := 57, arr_title, name_file := cur_dir() + "proverka.txt", ;
    arr_usl := {}

  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  If ( k := f_alert( { 'Каким образом производить проверку на отсутствие кодов персонала.', ;
      "Выберите действие:" }, ;
      { " По ~всем услугам ", ;
      " ~Исключая некоторые услуги " }, ;
      1, "N+/BG", "R/BG",,, col1menu ) ) == 0
    Return Nil
  Elseif k == 2
    dbCreate( cur_dir() + "tmp", { ;
      { "U_KOD",    "N",      4,      0 }, ;  // код услуги
    { "U_SHIFR",    "C",     10,      0 }, ;  // шифр услуги
    { "U_NAME",     "C",     65,      0 } } )  // наименование услуги
    Use ( cur_dir() + "tmp" )
    Index On Str( u_kod, 4 ) to ( cur_dir() + "tmpk" )
    Index On fsort_usl( u_shifr ) to ( cur_dir() + "tmpn" )
    Close databases
    ob2_v_usl()
    Use ( cur_dir() + "tmp" )
    dbEval( {|| AAdd( arr_usl, tmp->u_kod ) } )
    Use
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  dbCreate( cur_dir() + "tmp", { { "rec", "N", 7, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  g_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUMAN" )
  dbSeek( DToS( arr[ 5 ] ), .t. )
  Do While human->k_data <= arr[ 6 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If f_is_uch( st_a_uch, human->lpu )
      fl := .f.
      Select HU
      find ( Str( human->( RecNo() ), 7 ) )
      Do While hu->kod == human->( RecNo() )
        If AScan( arr_usl, hu->u_kod ) == 0
          If reg == 1
            If hu->kod_vr == 0
              fl := .t. ; Exit
            Endif
          Elseif reg == 4
            If hu->kod_as == 0
              fl := .t. ; Exit
            Endif
          Elseif reg == 2
            If emptyall( hu->med1, hu->med2, hu->med3 )
              fl := .t. ; Exit
            Endif
          Elseif reg == 3
            If emptyall( hu->san1, hu->san2, hu->san3 )
              fl := .t. ; Exit
            Endif
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If fl
        Select TMP
        Append Blank
        tmp->rec := human->( RecNo() )
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  If tmp->( LastRec() ) > 0
    mywait()
    arr_title := { ;
      "─────────────────────────────────────────────────┬──────────┬──────────", ;
      "              Ф.И.О. больного                    │Дата окон.│  Сумма   ", ;
      "─────────────────────────────────────────────────┴──────────┴──────────" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "" )
    add_string( Center( "Список больных, у которых в оказанных услугах", sh ) )
    add_string( Center( "отсутствует код " + { "врача", "медсестер", "санитарок", "асистента" }[ reg ], sh ) )
    add_string( "" )
    add_string( Center( arr[ 4 ], sh ) )
    titlen_uch( st_a_uch, sh )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    //
    g_use( dir_server() + "kartotek",, "KART" )
    Select HUMAN
    Set Index To
    Set Relation To kod_k into KART
    Select TMP
    Set Relation To rec into HUMAN
    Index On Upper( kart->fio ) to ( cur_dir() + "tmp" )
    Go Top
    i := 0
    hGauge := gaugenew(,,, "Создание текстового файла", .t. )
    gaugedisplay( hGauge )
    Do While !Eof()
      gaugeupdate( hGauge, ++i / LastRec() )
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      s := Str( i, 4 ) + ". " + Left( kart->fio, 43 ) + " " + full_date( human->k_data )
      add_string( s + put_kope( human->cena, 11 ) )
      Select TMP
      Skip
    Enddo
    Close databases
    closegauge( hGauge )
    FClose( fp )
    viewtext( name_file,,,, .f.,,, 2 )
  Else
    func_error( 4, "Не обнаружено услуг с незанесенным персоналом!" )
  Endif
  Close databases
  rest_box( buf )

  Return Nil


//

//
Function po_pr_oms( reg )

  Local i, j, k, arr, fl, fl_exit := .f., buf := save_row( MaxRow() ), s, sh := 81, ;
    HH := 57, name_file := cur_dir() + "proverka.txt", arr_usl := {}, numer := 1

  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Список больных по ОМС и ПЛАТНЫМ ", sh ) )
  add_string( Center( "по дате счета ОМС", sh ) )
  add_string( "" )
  add_string( Center( arr[ 4 ], sh ) )
  //
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "PHU" )
  g_use( dir_server() + "uslugi",, "USL" )
  g_use( dir_server() + "hum_p",, "PHUMAN" )
  Index On Str( kod_k, 7 ) + DToS( n_data ) to ( cur_dir() + "tmpp" )
  g_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
  Set Filter To !eq_any( mest_inog, 6, 7 )
  g_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
  g_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
  Select SCHET
  Go Top
  Do While !Eof()
    updatestatus()
    If schet->pdate <= arr[ 8 ] .and. schet->pdate >= arr[ 7 ]
      Select HUMAN
      find( Str( schet->kod, 6 ) )
      Do While schet->kod == human->schet .and. !Eof()
        If human->n_data <= arr[ 6 ] .and. human->n_data >= arr[ 5 ]
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          T_kod := human->kod_k
          Select PHUMAN
          dbSeek( ( Str( t_kod, 7 ) + DToS( human->n_data ) ), .t. )
          If human->kod_k == phuman->kod_k .and. ;
              human->n_data <= phuman->n_data .and. human->k_data >= phuman->n_data
            verify_ff( HH, .t., sh )
            add_string( lstr( numer ) + ". <" + lstr( human->kod_k ) + "> " + AllTrim( human->fio ) + ;
              ";  счет № " + schet->nomer_s )
            add_string( "ОМС: c " + full_date( human->n_data ) + " по " + full_date( human->k_data ) )
            Select HU
            find ( Str( human->( RecNo() ), 7 ) )
            Do While hu->kod == human->( RecNo() )
              Select USL
              Goto hu->u_kod
              verify_ff( HH, .t., sh )
              add_string( "  " + usl->shifr + " " + AllTrim( usl->name ) )
              Select HU
              Skip
            Enddo
            add_string( "ПЛАТНЫЕ: " + full_date( phuman->n_data ) )
            Select PHU
            find ( Str( phuman->( RecNo() ), 7 ) )
            Do While phu->kod == phuman->( RecNo() )
              Select USL
              Goto phu->u_kod
              verify_ff( HH, .t., sh )
              add_string( "  " + usl->shifr + " " + AllTrim( usl->name ) )
              Select PHU
              Skip
            Enddo
            add_string( "" )
            ++numer
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    Select SCHET
    Skip
  Enddo
  Close databases
  FClose( fp )
  viewtext( name_file,,,, .t.,,, 2 )
  rest_box( buf )

  Return Nil

//

// Проверка отделения на равенство месту основной работы персонала
Function po_pr_ot_pe()

  Local i := 0, j, k, arr, fl, fl_exit := .f., buf := save_row( MaxRow() ), ;
    s, sh, HH := 57, arr_title, name_file := cur_dir() + "prov_otd.txt", ;
    arr_usl := {}

  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  dbCreate( cur_dir() + "tmp", { { "rec", "N", 7, 0 }, ;
    { "otd", "N", 3, 0 }, ;
    { "otd_new", "N", 3, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  arr_title := { ;
    "─────────────────────────────────────────────────┬──────────┬──────────", ;
    "              Ф.И.О. больного                    │Дата окон.│  Сумма   ", ;
    "─────────────────────────────────────────────────┴──────────┴──────────" }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( "" )
  add_string( Center( "Список больных, у которых в оказанных услугах", sh ) )
  add_string( Center( "код отделения не соответствует месту основной работы персонала", sh ) )
  add_string( "" )
  add_string( Center( arr[ 4 ], sh ) )
  titlen_uch( st_a_uch, sh )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  g_use( dir_server() + "kartotek",, "KART" )
  g_use( dir_server() + "mo_pers",, "PERSO" )
  g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  g_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUMAN" )
  dbSeek( DToS( arr[ 5 ] ), .t. )
  Do While human->k_data <= arr[ 6 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If f_is_uch( st_a_uch, human->lpu )
      fl := .f.
      Select HU
      find ( Str( human->( RecNo() ), 7 ) )
      Do While hu->kod == human->( RecNo() )
        If ( old_kod := hu->kod_vr ) == 0
          old_kod := hu->kod_as
        Endif
        If old_kod > 0
          Select PERSO
          Goto ( old_kod )
          If perso->otd > 0 .and. hu->otd != perso->otd
            Select TMP
            Append Blank
            tmp->rec := hu->( RecNo() )
            tmp->otd := hu->otd
            tmp->otd_new := perso->otd
            If tmp->( LastRec() ) % 5000 == 0
              Commit
            Endif
            fl := .t.
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If fl
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        kart->( dbGoto( human->kod_k ) )
        s := Str( ++i, 4 ) + ". " + Left( kart->fio, 43 ) + " " + full_date( human->k_data )
        add_string( s + put_kope( human->cena, 11 ) )
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  rest_box( buf )
  If tmp->( LastRec() ) > 0
    Close databases
    FClose( fp )
    viewtext( name_file,,,, .f.,,, 2 )
    If ( k := f_alert( { 'Необходимо произвести изменение отделений по месту основной', ;
        "работы персонала?" }, ;
        { " ~Нет ", " ~Да " }, ;
        1, "N+/BG", "R/BG", 17,, col1menu ) ) == 2
      hGauge := gaugenew(,,, "Изменение кодов отделений", .t. )
      gaugedisplay( hGauge )
      g_use( dir_server() + "hum_p_u", { dir_server() + "hum_p_u", ;
        dir_server() + "hum_p_uk", ;
        dir_server() + "hum_p_ud", ;
        dir_server() + "hum_p_uv", ;
        dir_server() + "hum_p_ua" }, "HU" )
      Set Order To 0
      Use ( cur_dir() + "tmp" ) new
      Go Top
      Do While !Eof()
        gaugeupdate( hGauge, RecNo() / LastRec() )
        Select HU
        Goto ( tmp->rec )
        g_rlock( forever )
        hu->otd := tmp->otd_new
        Unlock
        Select TMP
        If tmp->( LastRec() ) % 5000 == 0
          Commit
        Endif
        Skip
      Enddo
      Close databases
      closegauge( hGauge )
      stat_msg( "Отделения изменены!" ) ; mybell( 2, OK )
    Endif
  Else
    func_error( 4, "Не обнаружено несоответствий!" )
  Endif
  Close databases

  Return Nil

//

// 11.02.13
Function pl_vzaimozach()

  Local i, j, k, fl, fl_exit := .f., buf := save_row( MaxRow() ), ;
    t_arr[ BR_LEN ], blk, fl1 := .f., fl2 := .f.
  Private arr_m

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  dbCreate( cur_dir() + "tmp", { { "kod_k", "N", 7, 0 }, ; // код больного по картотеке
  { "tip_usl", "N", 1, 0 }, ; // 2-взаимозачет, 1-добр.СМО
  { "pr_smo", "N", 6, 0 }, ; // код предприятия / СМО
  { "KOL", "N", 5, 0 }, ; // количество листов учета
  { "D_POLIS", "C", 25, 0 }, ; // полис
  { "N_DATA", "D", 8, 0 }, ; // дата начала лечения
  { "K_DATA", "D", 8, 0 }, ; // дата окончания лечения
  { "STOIM", "N", 10, 2 } } ) // итоговая стоимость услуг
  Use ( cur_dir() + "tmp" ) new
  Index On Str( tip_usl, 1 ) + Str( pr_smo, 6 ) + Str( kod_k, 7 ) to ( cur_dir() + "tmp" )
  dbCreate( cur_dir() + "tmp2", { { "rec_tmp", "N", 6, 0 }, ;
    { "rec_hp", "N", 7, 0 }, ;
    { "D_POLIS", "C", 25, 0 } } ) // полис
  Use ( cur_dir() + "tmp2" ) new
  If pi1 == 2  // по дате окончания лечения
    g_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HP" )
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While hp->k_data <= arr_m[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If equalany( hp->tip_usl, 1, 2 )
        f3_pl_vzaim()
      Endif
      Select HP
      Skip
    Enddo
  Else// pi1 == 3  // по дате закрытия листа учета
    g_use( dir_server() + "hum_p", dir_server() + "hum_pc", "HP" )
    For xx := 1 To 2
      Select HP
      dbSeek( Str( xx, 1 ) + "1" + DToS( arr_m[ 5 ] ), .t. )
      Do While hp->tip_usl == xx .and. hp->date_close <= arr_m[ 6 ] .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        f3_pl_vzaim()
        Select HP
        Skip
      Enddo
      If fl_exit ; exit ; Endif
    Next
  Endif
  j := tmp->( LastRec() )
  If !fl_exit .and. j > 0
    dbCreate( cur_dir() + "tmp1", { { "name", "C", 30, 0 }, ; // наименование предприятия
    { "tip_usl", "N", 1, 0 }, ; // 2-взаимозачет, 1-добр.СМО
    { "pr_smo", "N", 6, 0 }, ; // код предприятия / СМО
    { "KOL", "N", 6, 0 }, ; // количество больных
    { "STOIM", "N", 11, 2 } } ) // итоговая стоимость лечения
    g_use( dir_server() + "p_pr_vz",, "PRED" )
    g_use( dir_server() + "p_d_smo",, "SMO" )
    Use ( cur_dir() + "tmp1" ) new
    Index On Str( tip_usl, 1 ) + Str( pr_smo, 6 ) to ( cur_dir() + "tmp1" )
    Select TMP
    Go Top
    Do While !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      Select TMP1
      find ( Str( tmp->tip_usl, 1 ) + Str( tmp->pr_smo, 6 ) )
      If !Found()
        Append Blank
        tmp1->tip_usl := tmp->tip_usl
        tmp1->pr_smo  := tmp->pr_smo
        If tmp->tip_usl == 1
          smo->( dbGoto( tmp->pr_smo ) )
          tmp1->name := smo->name
          fl1 := .t.
        Else
          pred->( dbGoto( tmp->pr_smo ) )
          tmp1->name := pred->name
          fl2 := .t.
        Endif
      Endif
      tmp1->kol++
      tmp1->stoim += tmp->stoim
      Select TMP
      Skip
    Enddo
    j := tmp1->( LastRec() )
    mywait()
    Select TMP2
    Index On Str( rec_tmp, 6 ) to ( cur_dir() + "tmp2" )
  Endif
  Close databases
  rest_box( buf )
  If fl_exit
    // ничего
  Elseif j == 0
    func_error( 4, "Нет сведений по ДМС и взаимозачету " + arr_m[ 4 ] )
  Else
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_BOTTOM ] := MaxRow() -2
    t_arr[ BR_LEFT ] := 11
    t_arr[ BR_RIGHT ] := 68
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_TITUL ] := arr_m[ 4 ]
    If fl1
      t_arr[ BR_TITUL ] += " (ДМС)"
    Endif
    If fl2
      t_arr[ BR_TITUL ] += " (в/зачет)"
    Endif
    t_arr[ BR_TITUL_COLOR ] := "BG+/GR"
    t_arr[ BR_ARR_BROWSE ] := {,,, "N/BG,W+/N,B/BG,W+/B", .t., 0 }
    blk := {|| iif( tip_usl == 1, { 1, 2 }, { 3, 4 } ) }
    t_arr[ BR_COLUMN ] := { { Center( "Наименование", 30 ), {|| tmp1->name }, blk }, ;
      { "Кол-во;больных", {|| Str( kol, 7 ) }, blk }, ;
      { "   Сумма;  лечения", {|| put_kop( stoim, 11 ) }, blk } }
    t_arr[ BR_EDIT ] := {| nk, ob| f1_pl_vzaim( nk, ob, "edit" ) }
    t_arr[ BR_STAT_MSG ] := {|| ;
      status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор для печати; ^<F9>^ - сводная печать" ) } // 16.04.08
    Use ( cur_dir() + "tmp1" ) new
    Index On Upper( name ) to ( cur_dir() + "tmp1" )
    Go Top
    edit_browse( t_arr )
    Close databases
    rest_box( buf )
  Endif

  Return Nil

//

//
Function f1_pl_vzaim( nKey, oBrow, regim )

  Local ret := -1, buf, fl := .f., t_arr[ BR_LEN ]
  Local sm := 0, HH := 52, n_file := cur_dir() + "platn.txt", sum3 := 0, sh
  Local arr_title := { ;
    "───────────────────────────────────────────────────┬────────┬───────────", ;
    "                  Услуги                           │ Кол-во │   Сумма   ", ;
    "───────────────────────────────────────────────────┴────────┴───────────";
    }

  sh := Len( arr_title[ 1 ] )

  If regim == "edit" .and. nKey == K_ENTER
    Private rec_tmp1 := tmp1->( RecNo() )
    buf := SaveScreen()
    mywait()
    t_arr[ BR_TOP ] := 2
    t_arr[ BR_BOTTOM ] := MaxRow() -2
    t_arr[ BR_LEFT ] := 2
    t_arr[ BR_RIGHT ] := 77
    t_arr[ BR_COLOR ] := color0
    If tmp1->tip_usl == 1
      glob_d_smo := { tmp1->pr_smo, AllTrim( tmp1->name ) }
      t_arr[ BR_TITUL ] := glob_d_smo[ 2 ] + " (ДМС) " + arr_m[ 4 ]
    Else
      glob_pr_vz := { tmp1->pr_smo, AllTrim( tmp1->name ) }
      t_arr[ BR_TITUL ] := glob_pr_vz[ 2 ] + " (в/зачет) " + arr_m[ 4 ]
    Endif
    t_arr[ BR_TITUL_COLOR ] := "B/BG"
    t_arr[ BR_ARR_BROWSE ] := {,,, "N/BG,W+/N,B/BG,W+/B", .t., 0 }
    n := 33
    t_arr[ BR_COLUMN ] := { { Center( "Ф.И.О.", n ), {|| PadR( kart->fio, n ) } }, ;
      { "Раз", {|| Str( kol, 3 ) } }, ;
      { Center( "Срок лечения", 17 ), {|| date_8( n_data ) + "-" + date_8( k_data ) } }, ;
      { " Сумма", {|| put_kop( stoim, 10 ) } } }
    t_arr[ BR_EDIT ] := {| nk, ob| f2_pl_vzaim( nk, ob, "edit" ) }
    t_arr[ BR_STAT_MSG ] := {|| ;
      status_key( "^<Esc>^ - выход;  ^<Enter>^ - выбор для печати;  ^<F9>^ - печать реестра" ) }
    mywait()
    Use ( cur_dir() + "tmp2" ) index ( cur_dir() + "tmp2" ) new
    g_use( dir_server() + "kartotek",, "KART" )
    Use ( cur_dir() + "tmp" ) New Alias TMP
    Set Relation To kod_k into KART
    Index On Upper( kart->fio ) to ( cur_dir() + "tmp" ) ;
      For tmp1->tip_usl == tmp->tip_usl .and. tmp1->pr_smo == tmp->pr_smo
    edit_browse( t_arr )
    Close databases
    RestScreen( buf )
    Use ( cur_dir() + "tmp1" ) index ( cur_dir() + "tmp1" ) new
    Goto ( rec_tmp1 )
  Elseif regim == "edit" .and. nKey == K_F9
    rec_tmp1 := tmp1->( RecNo() )
    buf := SaveScreen()
    mywait()
    dbCreate( cur_dir() + "tmp9", { { "kod",     "N", 4,   0 }, ;
      { "name",    "C", 60,  0 }, ;
      { "kod_1",   "C", 10,  0 }, ;
      { "kol_vo",  "N", 10,  0 }, ;
      { "summa",   "N", 12,  2 } } )
    Use ( cur_dir() + "tmp2" ) index ( cur_dir() + "tmp2" ) new
    Use ( cur_dir() + "tmp9" ) new
    Index On kod to ( cur_dir() + "tmp_u" )
    g_use( dir_server() + "hum_p_U", dir_server() + "hum_p_U", "HUM_U",,, .t. )
    g_use( dir_server() + "hum_p",, "HP" )
    Use ( cur_dir() + "tmp" ) New Alias TMP
    Index On Str( tmp->kol, 6 ) to ( cur_dir() + "tmp" ) ;
      For tmp1->tip_usl == tmp->tip_usl .and. tmp1->pr_smo == tmp->pr_smo
    Go Top
    Do While !Eof()
      Select TMP2
      find ( Str( tmp->( RecNo() ), 6 ) )
      Do While tmp2->rec_tmp == tmp->( RecNo() ) .and. !Eof()
        Select HUM_U
        find ( Str( tmp2->rec_hp, 7 ) )
        Do While tmp2->rec_hp == hum_u->kod .and. !Eof()
          Select TMP9
          find ( hum_u->u_kod )
          If !Found()
            Append Blank
            tmp9->kod := hum_u->u_kod
          Endif
          tmp9->kol_vo += hum_u->kol
          tmp9->summa  += hum_u->stoim
          Select HUM_U
          Skip
        Enddo
        Select TMP2
        Skip
      Enddo
      Select TMP
      Skip
    Enddo
    g_use( dir_server() + "uslugi",, "USL" )
    Select TMP9
    Go Top
    Do While !Eof()
      t := tmp9->kod
      Select USL
      Goto t
      Select TMP9
      tmp9->name  := usl->name
      tmp9->kod_1 := usl->shifr
      Skip
    Enddo
    Select TMP9
    Index On kod_1 to ( cur_dir() + "tmp_u" )
    fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( Center( "Оплата услуг", sh ) )
    add_string( Center( "по дате начала лечения", sh ) )
    add_string( Center( tmp1->name, sh ) )
    If tmp1->tip_usl == 1
      add_string( Center( " (ДМС) ", sh ) )
    Else
      add_string( Center( " (в/зачет) ", sh ) )
    Endif
    add_string( Center( arr_m[ 4 ], sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    Go Top
    sm1 := 0
    sm2 := 0
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( tmp9->kod_1 + PadR( tmp9->name, 40 ) + ;
        Str( tmp9->kol_vo, 9 ) + ;
        put_kope( tmp9->summa, 12 ) )
      sm1 += tmp9->kol_vo
      SM2 += tmp9->summa
      Skip
    Enddo
    add_string( Replicate( "─", sh ) )
    add_string( PadR( "Итого: ", 50 ) + ;
      Str( SM1, 9 ) + ;
      put_kope( SM2, 12 ) )
    Close databases
    FClose( fp )
    viewtext( n_file,,,, ( sh > 80 ),,, 1 )
    RestScreen( buf )
    Use ( cur_dir() + "tmp1" ) index ( cur_dir() + "tmp1" ) new
    Goto ( rec_tmp1 )
  Endif

  Return ret

//

// 03.04.14
Function f2_pl_vzaim( nKey, oBrow, regim )

  Static sf_nomer, sf_date, sa_nomer, sa_date
  Local ret := -1, buf, fl := .f., rec, tmp_color, ah, ahu, i, j, k, fl_one, ;
    s, sh, HH := 76, reg_print, arr_title, name_file := cur_dir() + "vzaimoza.txt", ;
    d, sd, kol_usl, sk, ss, is_fio, is_sokr, old, mas_pmt

  Do Case
  Case regim == "edit"
    Do Case
    Case nKey == K_F9
      Default sf_nomer To Space( 10 ), sf_date To CToD( "" ), ;
        sa_nomer To Space( 10 ), sa_date To CToD( "" )
      mas_pmt := { ;
        "Печать счёта-~фактуры", ;
        "Печать ~акта выполненных работ", ;
        "~Реестр медуслуг в Excel (новый)", ;
        "Реестр - ~сокращённая форма (старый)", ;
        "Реестр - ~полная форма (старый)", ;
        "~Реестр медуслуг в Excel (Для Облздрава)";
        }
      Select TMP
      rec := RecNo()
      sk := ss := 0
      Go Top
      dbEval( {|| sk++, ss += tmp->stoim } )
      Go Top
      Do While ( i := popup_prompt( T_ROW, T_COL -5, i, mas_pmt,,, ;
          "BG+/RB,W+/R,W+/RB,GR+/R" ) ) > 0
        If eq_any( i, 1, 3 )
          If ( k := input_diapazon( MaxRow() -4, 9, MaxRow() -2, 68, color8, ;
              { "Введите номер", "и дату", "счёта-фактуры" }, ;
              { sf_nomer, sf_date } ) ) != NIL
            sf_nomer := k[ 1 ]
            sf_date := k[ 2 ]
            If i == 1
              pl_print_faktura( k, sk, ss )
            Else
              rees_new_vzaim( k )
            Endif
          Endif
        Elseif i == 2
          If ( k := input_diapazon( MaxRow() -4, 14, MaxRow() -2, 64, color8, ;
              { "Введите номер", "и дату", "акта" }, ;
              { sa_nomer, sa_date } ) ) != NIL
            sa_nomer := k[ 1 ]
            sa_date := k[ 2 ]
            pl_print_akt( k, sk, ss )
          Endif
        Elseif i == 4
          rees1_vzaim( name_file )
        Elseif i == 5
          rees2_vzaim( name_file )
        Elseif i == 6
          rees_new_vzaim_pol3( name_file )
        Endif
        Close databases
        Use ( cur_dir() + "tmp1" ) index ( cur_dir() + "tmp1" ) new
        Goto ( rec_tmp1 )
        Use ( cur_dir() + "tmp2" ) index ( cur_dir() + "tmp2" ) new
        g_use( dir_server() + "kartotek",, "KART" )
        Use ( cur_dir() + "tmp" ) New Alias TMP
        Set Relation To kod_k into KART
        Set Index to ( cur_dir() + "tmp" )
        Goto ( rec )
      Enddo
    Case nKey == K_ENTER
      buf := save_row( MaxRow() )
      ah := {} ; ahu := {}
      mywait()
      If is_zf_stomat == 1
        use_base( "humanst" )
      Endif
      g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HPU" )
      g_use( dir_server() + "hum_p",, "HP" )
      Select TMP2
      find ( Str( tmp->( RecNo() ), 6 ) )
      Do While tmp2->rec_tmp == tmp->( RecNo() ) .and. !Eof()
        Select HP
        Goto ( tmp2->rec_hp )
        arr := { hp->KOD_DIAG, ;
          hp->SOPUT_B1, ;
          hp->SOPUT_B2, ;
          hp->SOPUT_B3, ;
          hp->SOPUT_B4, ;
          hp->SOPUT_B5 }
        For i := 1 To Len( arr )
          If !Empty( arr[ i ] ) .and. AScan( ah, arr[ i ] ) == 0
            AAdd( ah, arr[ i ] )
          Endif
        Next
        Select HPU
        find ( Str( hp->( RecNo() ), 7 ) )
        Do While hpu->kod == hp->( RecNo() )
          s := ""
          If is_zf_stomat == 1
            Select HUMANST
            find ( Str( 2, 1 ) + Str( hpu->( RecNo() ), 8 ) )
            If Found()
              s += " ЗФ:"
              If !Empty( humanst->KOD_DIAG )
                s += AllTrim( humanst->KOD_DIAG ) + ","
              Endif
              s += AllTrim( humanst->ZF )
            Endif
          Endif
          AAdd( ahu, { c4tod( hpu->date_u ), ;
            hpu->u_kod, ;
            s, ;
            hpu->kol, ;
            hpu->stoim, ;
            hpu->kod_vr, ;
            { hpu->med1, hpu->med2, hpu->med3 }, ;
            { hpu->san1, hpu->san2, hpu->san3 };
            } )
          Select HPU
          Skip
        Enddo
        Select TMP2
        Skip
      Enddo
      hp->( dbCloseArea() )
      hpu->( dbCloseArea() )
      If is_zf_stomat == 1
        humanst->( dbCloseArea() )
      Endif
      //
      g_use( dir_server() + "plat_ms",, "PMS" )
      g_use( dir_server() + "mo_pers",, "perso" )
      g_use( dir_server() + "uslugi",, "USL" )
      For i := 1 To Len( ahu )
        // услуга
        Select USL
        Goto ( ahu[ i, 2 ] )
        ahu[ i, 2 ] := usl->shifr
        ahu[ i, 3 ] := AllTrim( usl->name ) + ahu[ i, 3 ]  // ЗФ
        // врач
        If ahu[ i, 6 ] == 0
          ahu[ i, 6 ] := "--"
        Else
          Select perso
          Goto ( ahu[ i, 6 ] )
          ahu[ i, 6 ] := fam_i_o( perso->fio )
        Endif
        // медсестра
        s := ""
        For j := 1 To Len( ahu[ i, 7 ] )
          If ahu[ i, 7, j ] > 0
            Select PMS
            Goto ( ahu[ i, 7, j ] )
            s += fam_i_o( pms->fio ) + ", "
          Endif
        Next
        ahu[ i, 7 ] := if( Empty( s ), "--", SubStr( s, 1, Len( s ) -2 ) )
        // санитарка
        s := ""
        For j := 1 To Len( ahu[ i, 8 ] )
          If ahu[ i, 8, j ] > 0
            Select PMS
            Goto ( ahu[ i, 8, j ] )
            s += fam_i_o( pms->fio ) + ", "
          Endif
        Next
        ahu[ i, 8 ] := if( Empty( s ), "--", SubStr( s, 1, Len( s ) -2 ) )
      Next
      pms->( dbCloseArea() )
      perso->( dbCloseArea() )
      usl->( dbCloseArea() )
      //
      ASort( ahu,,, {| x, y| if( x[ 1 ] == y[ 1 ], ;
        fsort_usl( x[ 2 ] ) < fsort_usl( y[ 2 ] ), x[ 1 ] < y[ 1 ] ) } )
      //
      arr_title := { ;
        "────────┬──────────────────────────────────────┬─────┬─────────┬────────────────────", ;
        "        │                                      │     │         │ФИО врача,          ", ;
        "  Дата  │      Шифр и наименование услуги      │ Кол.│Стоимость│    медсестры,      ", ;
        " лечения│                                      │услуг│         │    санитарки       ", ;
        "────────┴──────────────────────────────────────┴─────┴─────────┴────────────────────" }
      sh := Len( arr_title[ 1 ] )
      fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
      r_use( dir_server() + "organiz",, "ORG" )
      add_string( AllTrim( org->name ) )
      org->( dbCloseArea() )
      add_string( "" )
      add_string( AllTrim( kart->fio ) + iif( Empty( kart->mr_dol ), "", " [" + Upper( AllTrim( kart->mr_dol ) ) + "]" ) )
      add_string( "" )
      add_string( "Дата рождения: " + full_date( kart->date_r ) )
      add_string( "Проживает: " + AllTrim( kart->adres ) )
      add_string( tmp1->name )
      If !Empty( tmp->d_polis )
        add_string( "Полис: " + AllTrim( tmp->d_polis ) )
      Endif
      If ( fl_one := ( tmp->n_data == tmp->k_data ) )
        s := "Дата лечения: " + date_month( tmp->n_data )
      Else
        s := "Срок лечения: " + full_date( tmp->n_data ) + "-" + full_date( tmp->k_data )
      Endif
      add_string( "" )
      add_string( s )
      s := "Диагноз: "
      AEval( ah, {| x| s += AllTrim( x ) + ", " } )
      add_string( "" )
      add_string( SubStr( s, 1, Len( s ) -2 ) )
      AEval( arr_title, {| x| add_string( x ) } )
      ah := Array( 3 )
      d := iif( Len( ahu ) == 0, tmp->k_data, ahu[ 1, 1 ] )
      sd := kol_usl := 0
      For i := 1 To Len( ahu )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        If d == ahu[ i, 1 ]
          If i > 1
            add_string( Replicate( " - ", sh / 3 ) )
          Endif
        Else
          add_string( PadL( "Итого за " + date_8( d ) + ": " + lput_kop( sd ), sh -21, "-" ) )
          sd := 0
        Endif
        d := ahu[ i, 1 ]
        perenos( ah, AllTrim( ahu[ i, 2 ] ) + " " + ahu[ i, 3 ], 38 )
        add_string( date_8( ahu[ i, 1 ] ) + " " + PadR( ah[ 1 ], 38 ) + put_val( ahu[ i, 4 ], 4 ) + ;
          put_kope( ahu[ i, 5 ], 12 ) + " " + ahu[ i, 6 ] )
        add_string( Space( 9 ) + PadL( AllTrim( ah[ 2 ] ), 38 ) + Space( 16 ) + " " + ahu[ i, 7 ] )
        add_string( Space( 9 ) + PadL( AllTrim( ah[ 3 ] ), 38 ) + Space( 16 ) + " " + ahu[ i, 8 ] )
        kol_usl += ahu[ i, 4 ]
        sd += ahu[ i, 5 ]
      Next
      If !fl_one
        add_string( PadL( "Итого за " + date_8( d ) + ": " + lput_kop( sd ), sh -21, "-" ) )
      Endif
      add_string( Replicate( "─", sh ) )
      add_string( PadL( "Итого : " + put_val( kol_usl, 4 ) + put_kope( tmp->stoim, 12 ), sh -21 ) )
      add_string( "" )
      add_string( "" )
      add_string( "         Зав.отделением _________________                 Дата ______________" )
      FClose( fp )
      rest_box( buf )
      reg_print := 5
      viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
      Select TMP
    Endcase
  Endcase

  Return ret

//

// 11.02.13
Function f3_pl_vzaim()

  Select TMP
  find ( Str( hp->tip_usl, 1 ) + Str( hp->pr_smo, 6 ) + Str( hp->kod_k, 7 ) )
  If !Found()
    Append Blank
    tmp->tip_usl := hp->tip_usl
    tmp->pr_smo  := hp->pr_smo
    tmp->kod_k   := hp->kod_k
    tmp->n_data  := hp->n_data
    tmp->k_data  := hp->k_data
    If !Empty( hp->d_polis )
      tmp->d_polis := hp->d_polis
    Endif
  Endif
  If tmp->n_data > hp->n_data
    tmp->n_data := hp->n_data
  Endif
  If tmp->k_data < hp->k_data
    tmp->k_data := hp->k_data
  Endif
  tmp->kol++
  tmp->stoim += hp->cena
  //
  Select TMP2
  Append Blank
  tmp2->rec_tmp := tmp->( RecNo() )
  tmp2->rec_hp  := hp->( RecNo() )
  tmp2->d_polis := hp->d_polis
  If tmp2->( LastRec() ) % 5000 == 0
    Commit
  Endif

  Return Nil

//

//
Function vr_vzaimozach( regim )

  Local i, j, k, fl, fl_exit := .f., buf := save_row( MaxRow() ), ;
    sh, HH := 60, reg_print := 2, arr_title, n_file := cur_dir() + "vr_vzaim.txt"
  Private arr_m

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  dbCreate( cur_dir() + "tmp", { { "kod",        "N",      4,      0 }, ; // код персонала
  { "FIO",        "C",     50,      0 }, ;  // Ф.И.О. врача
    { "TRUDOEM",    "N",     11,      4 }, ;  // трудоемкость услуг УЕТ
  { "KOL",    "N",      6,      0 }, ;  // количество услуг
    { "STOIM_OB",   "N",     12,      2 }, ;  // итоговая стоимость услуг
  { "STOIM",    "N",     12,      2 }, ;  // итоговая стоимость услуг
    { "ZARPLATA",   "N",     12,      2 } } )  // на зарплату
  Use ( cur_dir() + "tmp" )
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp" )
  useuch_usl()
  g_use( dir_server() + "uslugi",, "USL" )
  If eq_any( is_oplata, 5, 6, 7 )
    open_opl_5()
  Endif
  g_use( dir_server() + "mo_pers",, "perso" )
  g_use( dir_server() + "plat_ms",, "PMS" )
  g_use( dir_server() + "kartotek",, "KART" )
  g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  If pi1 == 2
    g_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUMAN" )
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      Select HU
      find ( Str( human->( RecNo() ), 7 ) )
      Do While hu->kod == human->( RecNo() )
        f1_vr_vzaim( regim )
        Select HU
        Skip
      Enddo
      Select HUMAN
      Skip
    Enddo
  Else
    g_use( dir_server() + "hum_p", dir_server() + "hum_pc", "HUMAN" )
    For xx := 0 To 2
      Select HUMAN
      dbSeek( Str( xx, 1 ) + "1" + DToS( arr_m[ 5 ] ), .t. )
      Do While human->tip_usl == xx .and. human->date_close <= arr_m[ 6 ] .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        Select HU
        find ( Str( human->( RecNo() ), 7 ) )
        Do While hu->kod == human->( RecNo() )
          f1_vr_vzaim( regim )
          Select HU
          Skip
        Enddo
        Select HUMAN
        Skip
      Enddo
      If fl_exit ; exit ; Endif
    Next
  Endif
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    // ничего
  Elseif j == 0
    func_error( 4, "Нет сведений " + arr_m[ 4 ] )
  Else
    mywait()
    arr_title := { ;
      "───────────────────────────────────────┬──────┬─────────┬─────────┬──────┬──────────", ;
      "                                       │      │         │         │% вз/з│          ", ;
      "                 Ф.И.О.                │Кол-во│Стоимость│ Зарплата│от общ│Примечание", ;
      "                                       │ услуг│  услуг  │         │кол-ва│          ", ;
      "───────────────────────────────────────┴──────┴─────────┴─────────┴──────┴──────────" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "ПЛАТНЫЕ УСЛУГИ" )
    add_string( Center( "Работа персонала по ДМС и взаимозачету", sh ) )
    add_string( Center( arr_m[ 4 ], sh ) )
    add_string( Center( Expand( { "ВРАЧИ", "МЕДСЕСТРЫ", "САНИТАРКИ" }[ regim ] ), sh ) )
    Do Case
    Case pi1 == 2
      s := "[ по дате окончания лечения ]"
    Case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
    Endcase
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    skol := sstoim := sstoim_ob := szarplata := 0
    Use ( cur_dir() + "tmp" ) new
    Index On Upper( fio ) to ( cur_dir() + "tmp" ) For stoim > 0
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      s := PadR( tmp->fio, 40 ) + ;
        put_val( tmp->kol, 5 ) + ;
        put_kope( tmp->stoim, 11 ) + ;
        put_kope( tmp->zarplata, 10 ) + ;
        put_val_0( tmp->stoim / tmp->stoim_ob * 100, 7, 2 ) + ;
        " __________"
      add_string( s )
      skol += tmp->kol
      sstoim += tmp->stoim
      sstoim_ob += tmp->stoim_ob
      szarplata += tmp->zarplata
      Skip
    Enddo
    add_string( Replicate( "─", sh ) )
    s := PadC( "И Т О Г О :", 40 ) + ;
      put_val( skol, 5 ) + ;
      put_kope( sstoim, 11 ) + ;
      put_kope( szarplata, 10 ) + ;
      put_val_0( sstoim / sstoim_ob * 100, 7, 2 )
    add_string( s )
    FClose( fp )
    Close databases
    rest_box( buf )
    viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
  Endif

  Return Nil

//

//
Function f1_vr_vzaim( regim )

  Local i, mtrud := 0, koef := 1, koef_z := { 1, 1, 1 }

  If hu->u_kod > 0 .and. ( hu->kol > 0 .or. hu->stoim > 0 )
    kart->( dbGoto( human->kod_k ) )
    mtrud := round_5( hu->kol * opr_uet( kart->vzros_reb ), 4 )
    Do Case
    Case regim == 1 .and. hu->kod_vr > 0
      koef_z := ret_koef_z( hu->u_kod, hu->kod_vr, 0 )
      Select TMP
      find ( Str( hu->kod_vr, 4 ) )
      If !Found()
        Append Blank
        tmp->kod := hu->kod_vr
        perso->( dbGoto( tmp->kod ) )
        tmp->fio := perso->fio
      Endif
      tmp->stoim_ob += hu->stoim
      If human->tip_usl > 0  // взаимозачет
        tmp->trudoem += mtrud
        tmp->kol += hu->kol
        tmp->stoim += hu->stoim
        tmp->zarplata += hu->stoim * koef_z[ 1 ]
      Endif
    Case regim == 2
      koef := 0
      If hu->med1 > 0
        ++koef
      Endif
      If hu->med2 > 0
        ++koef
      Endif
      If hu->med3 > 0
        ++koef
      Endif
      For i := 1 To 3
        pole := "hu->med" + lstr( i )
        if &pole > 0
          Select TMP
          find ( Str( &pole, 4 ) )
          If !Found()
            Append Blank
            tmp->kod := &pole
            pms->( dbGoto( tmp->kod ) )
            tmp->fio := pms->fio
          Endif
          tmp->stoim_ob += hu->stoim / koef
          If human->tip_usl > 0  // взаимозачет
            tmp->trudoem += mtrud
            tmp->kol += hu->kol
            tmp->stoim += hu->stoim / koef
            tmp->zarplata += round_5( hu->stoim * mem_pl_ms / 100 / koef, 2 )
          Endif
        Endif
      Next
    Case regim == 3
      koef := 0
      If hu->san1 > 0
        ++koef
      Endif
      If hu->san2 > 0
        ++koef
      Endif
      If hu->san3 > 0
        ++koef
      Endif
      For i := 1 To 3
        pole := "hu->san" + lstr( i )
        if &pole > 0
          Select TMP
          find ( Str( &pole, 4 ) )
          If !Found()
            Append Blank
            tmp->kod := &pole
            pms->( dbGoto( tmp->kod ) )
            tmp->fio := pms->fio
          Endif
          tmp->stoim_ob += hu->stoim / koef
          If human->tip_usl > 0  // взаимозачет
            tmp->trudoem += mtrud
            tmp->kol += hu->kol
            tmp->stoim += hu->stoim / koef
            tmp->zarplata += round_5( hu->stoim * mem_pl_sn / 100 / koef, 2 )
          Endif
        Endif
      Next
    Endcase
  Endif

  Return Nil

//

//
Function pr_opl_vz()

  Local i, j, arr, begin_date, end_date, s, buf := save_row( MaxRow() ), ;
    fl_exit := .f., sh, HH := 58, reg_print, ssumma := 0, ;
    arr_title, name_file := cur_dir() + "vzoplata.txt", arr_m, adbf, ;
    menu_opl := { { "безналичн.", 0 }, ;
    { "наличными ", 1 }, ;
    { "в/зачет   ", 2 } }

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  mywait()
  reg_print := 2
  arr_title := { ;
    "──────────┬──────────┬──────────┬───────────────┬───────────────────────────────────", ;
    "   Дата   │   Тип    │  Сумма   │  Примечание   │  Предприятие (СМО)                ", ;
    "  оплаты  │  оплаты  │          │               │  (ФИО больного)                   ", ;
    "──────────┴──────────┴──────────┴───────────────┴───────────────────────────────────" }
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  add_string( Center( "Оплата по ДМС и взаимозачету", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  g_use( dir_server() + "kartotek",, "KART" )
  g_use( dir_server() + "p_pr_vz",, "VZ" )
  g_use( dir_server() + "p_d_smo",, "SMO" )
  g_use( dir_server() + "plat_vz",, "OPL" )
  Index On DToS( date_opl ) + Str( tip, 1 ) + Str( pr_smo, 6 ) + Str( kod_k, 7 ) to ( cur_dir() + "tmp" ) ;
    For Between( date_opl, arr_m[ 5 ], arr_m[ 6 ] ) progress
  Go Top
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    s := full_date( opl->date_opl ) + " " + ;
      inieditspr( A__MENUVERT, menu_opl, opl->tip_opl ) + " " + ;
      put_kope( opl->summa_opl, 10 ) + " " + ;
      opl->prim + " "
    ssumma += opl->summa_opl
    If opl->tip == 1
      smo->( dbGoto( opl->pr_smo ) )
      kart->( dbGoto( opl->kod_k ) )
      s += AllTrim( smo->name )
    Else
      vz->( dbGoto( opl->pr_smo ) )
      s += AllTrim( vz->name )
    Endif
    add_string( s )
    If opl->tip == 1
      add_string( Space( 49 ) + AllTrim( kart->fio ) )
    Endif
    Select OPL
    Skip
  Enddo
  If !Empty( ssumma )
    add_string( Replicate( "-", sh ) )
    add_string( put_kope( ssumma, 32 ) )
  Endif
  Close databases
  FClose( fp )
  rest_box( buf )
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )

  Return Nil

//

Function st_v_vrach( get, pole_vr, regim )

  // regim = 0  - по БД mo_pers
  // regim = 1  - медсестры по БД plat_ms
  // regim = 2  - санитарки по БД plat_ms
  // regim = 3  - по БД mo_pers через VGET
  Local lval, lpole, fl := .t.
  Default regim To 0
  If regim == 3
    lval := get:varget()
    lpole := ReadVar()
  Else
    lval := &( ReadVar() )
    lpole := ReadVar()
  Endif
  If lval == 0
    &pole_vr := Space( 30 )
  Elseif lval > 0
    Default regim To 0
    If equalany( regim, 0, 3 )
      Select PERSO
      find ( Str( lval, 5 ) )
      If Found()
        &pole_vr := PadR( fam_i_o( perso->fio ), 30 )
      Else
        fl := .f.
      Endif
    Else   // regim == 1 или 2
      Select MS
      find ( Str( regim, 1 ) + Str( lval, 5 ) )
      If Found()
        &pole_vr := PadR( ms->fio, 30 )
      Else
        fl := .f.
      Endif
    Endif
    If !fl
      // &lpole := get:original
      get:varput( get:original )
      Return func_error( 4, "Человека с таким кодом нет в базе данных персонала!" )
    Endif
  Else
    // &lpole := get:original
    get:varput( get:original )
    Return func_error( 4, "Нельзя вводить отрицательное число!" )
  Endif
  If regim < 3
    update_get( pole_vr )
  Endif

  Return .t.

//

//
Function valid_mest_inog( get, old, k, fl )

  Default k To 1, fl To .f.
  If k == 1
    If old != Nil .and. m1mest_inog != old
      If fl
        say_rajreg( get:row, k, m1mest_inog )
      Endif
      If m1mest_inog < 2
        miREG_RAB := ""
      Endif
      mrajon := Space( 34 ) ; m1rajon := 0
      update_get( "mrajon" )
    Endif
  Else
    If old != Nil .and. m1mi_git != old
      If fl
        say_rajreg( get:row, k, m1mi_git )
      Endif
      If m1mi_git < 2
        miREG_GIT := ""
      Endif
      mrajon_git := Space( 32 ) ; m1rajon_git := 0
      update_get( "mrajon_git" )
    Endif
  Endif

  Return .t.

//

//
Function get_slugba( k, r, c )

  Local ret, r1, r2

  If ( r1 := r + 1 ) > MaxRow() / 2
    r2 := r -1 ; r1 := 2
  Else
    r2 := MaxRow() -2
  Endif
  g_use( dir_server() + "slugba", dir_server() + "slugba", "SL" )
  If k > 0
    find ( Str( k, 3 ) )
  Endif
  If alpha_browse( r1, 27, r2, 77, "f2spr_other", color0 )
    ret := mslugba := { sl->shifr, lstr( sl->shifr ) + ". " + AllTrim( sl->name ) }
  Endif
  sl->( dbCloseArea() )

  Return ret

//

//
Function put_tab_nom( ltab_nom, lsvod_nom )

  Local s := lstr( ltab_nom )

  If !Empty( lsvod_nom ) .and. ltab_nom != lsvod_nom
    s := "(" + lstr( lsvod_nom ) + ")" + s
  Endif

  Return s

//

//
Function input_kperso()

  Local mas1 := {}, buf := SaveScreen(), i, arr := {}, ;
    mas3 := { { 5, 0 }, }, ;
    mas2 := { { 1, "Таб.N" }, ;
    { 2, "  Ф.И.О." } }, ;
    blk := {| b, ar, nDim, nElem, nKey| f1_i_kperso( b, ar, nDim, nElem, nKey ) }

  g_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
  If Len( mas1 ) == 0
    AAdd( mas1, { 0, Space( 50 ), 0 } )
  Endif
  change_attr()
  arrn_browse( 2, 9, MaxRow() -2, 70, mas1, mas2, 1,, color1, ;
    "Ввод списка персонала", "G+/B", ;
    .t.,, mas3, blk, { .t., .t., .t. } )
  For i := 1 To Len( mas1 )
    If mas1[ i, 1 ] > 0 .and. AScan( arr, {| x| x[ 1 ] == mas1[ i, 3 ] } ) == 0
      AAdd( arr, { mas1[ i, 3 ], "", mas1[ i, 1 ] } )
    Endif
  Next
  Close databases
  If Len( arr ) == 0
    arr := NIL
  Endif
  RestScreen( buf )

  Return arr

//

//
Function f1_i_kperso( b, ar, nDim, nElem, nKey )

  Local nRow := Row(), nCol := Col(), i, j, flag := .f., buf, ;
    mpic := { "99999", }

  Do Case
  Case nKey == K_DOWN .or. nKey == K_INS
    b:panhome()
  Otherwise
    If ( nKey == K_ENTER .or. Between( nKey, 48, 57 ) )
      If Between( nKey, 48, 57 )
        Keyboard Chr( nKey )
      Endif
      Private mkod := parr[ nElem, nDim ]
      @ nRow, nCol Get mkod Picture mpic[ nDim ]
      myread( { "up", "down" } )
      If LastKey() != K_ESC
        find ( Str( mkod, 5 ) )
        If !( fl := Found() )
          func_error( 4, "Человека с таким таб.номером нет в базе данных персонала!" )
        Else
          parr[ nElem, 1 ] := mkod
          parr[ nElem, 2 ] := perso->fio
          parr[ nElem, 3 ] := perso->kod
          flag := .t.
        Endif
      Endif
    Endif
  Endcase
  @ nRow, nCol Say ""

  Return flag

//

// 01.04.14
Function ob2_v_usl( is_get, r1, mtitul )

  Local t_arr[ BR_LEN ], buf := SaveScreen(), k, ret

  Default is_get To .f., r1 To T_ROW
  If r1 > 14 ; r1 := 14 ; Endif
  r_use( dir_server() + "uslugi", dir_server() + "uslugish", "USL" )
  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmpk" ), ( cur_dir() + "tmpn" ) New Alias TMP
  Set Order To 2
  t_arr[ BR_TOP ] := r1
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 1
  t_arr[ BR_RIGHT ] := 78
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitul
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_OPEN ] := {|| !Eof() }
  t_arr[ BR_ARR_BROWSE ] := { "═", "░", "═",, .t. }
  t_arr[ BR_COLUMN ] := { { "   Шифр", {|| tmp->u_shifr } }, ;
    { Center( "Наименование услуги", 65 ), {|| Left( tmp->u_name, 65 ) } } }
  t_arr[ BR_STAT_MSG ] := {|| ;
    status_key( "^<Esc>^ выход;  ^<Ins>^ добавление;  ^<Del>^ удаление услуги;  ^<F9>^ печать списка" ) }
  t_arr[ BR_EDIT ] := {| nk, ob| ob21v_usl( nk, ob, "edit", mtitul ) }
  edit_browse( t_arr )
  If is_get
    Go Top
    k := 0
    dbEval( {|| if( tmp->u_kod > 0, ++k, nil ) } )
    ret := { k, "Кол-во услуг - " + lstr( k ) }
  Endif
  tmp->( dbCloseArea() )
  usl->( dbCloseArea() )
  RestScreen( buf )
  If !is_get
    waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  Endif

  Return ret

//
Function ob21v_usl( nKey, oBrow, regim, mtitul )

  Local ret := -1, s
  Local buf, fl := .f., rec, rec1, k := 19, tmp_color, n_file, sh := 80, HH := 60

  Do Case
  Case regim == "edit"
    Do Case
    Case nKey == K_F9
      Default mtitul To "Список выбранных услуг"
      buf := save_row( MaxRow() )
      mywait()
      rec := RecNo()
      Private reg_print := 2
      n_file := cur_dir() + "ob2_v_us.txt"
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( "" )
      add_string( Center( mtitul, sh ) )
      add_string( "" )
      Go Top
      Do While !Eof()
        verify_ff( HH, .t., sh )
        s := tmp->u_shifr
        Select USL
        find ( tmp->u_shifr )
        If Found() .and. !Empty( usl->shifr1 ) .and. !( tmp->u_shifr == usl->shifr1 )
          s += "(" + AllTrim( usl->shifr1 ) + ")"
        Endif
        add_string( s + AllTrim( tmp->u_name ) )
        Select TMP
        Skip
      Enddo
      Goto ( rec )
      FClose( fp )
      rest_box( buf )
      viewtext( n_file,,,, ( .t. ),,, reg_print )
    Case nKey == K_INS
      Save Screen To buf
      Private mshifr := Space( 10 )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, 21, pc2 -1,, "Добавление услуги", cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 27 Say "Шифр услуги" Get mshifr Picture "@!" ;
        Valid valid_shifr()
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. !Empty( mshifr )
        If "*" == AllTrim( mshifr )
          func_error( 4, 'Воспользуйтесь режимом "Все услуги"!' )
        Elseif "*" $ mshifr .or. "?" $ mshifr
          mshifr := AllTrim( mshifr )
          mywait()
          Select USL
          Go Top
          Do While !Eof()
            If Like( mshifr, usl->shifr ) .or. Like( mshifr, usl->shifr1 )
              Select TMP
              Set Order To 1
              fl_found := fl := .t.
              addrec( 4 )
              ret := 0
              Replace tmp->u_shifr With usl->shifr, tmp->u_name With usl->name, ;
                tmp->u_kod With usl->kod
            Endif
            Select USL
            Skip
          Enddo
          Select TMP
          Set Order To 2
          If fl
            oBrow:gotop()
          Else
            func_error( 4, "Не найдено услуг по шаблону <" + mshifr + ">." )
          Endif
        Else
          Select USL
          find ( mshifr )
          fl := Found()
          Select TMP
          If fl
            Set Order To 1
            fl_found := .t.
            addrec( 4 )
            rec := RecNo()
            Replace tmp->u_shifr With mshifr, tmp->u_name With usl->name, ;
              tmp->u_kod With usl->kod
            Set Order To 2
            oBrow:gotop()
            Goto ( rec )
            ret := 0
          Else
            func_error( 4, "Услуги с данным шифром нет в справочнике!" )
          Endif
        Endif
      Endif
      If !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. !Empty( tmp->u_kod )
      rec1 := 0
      rec := RecNo()
      Skip
      If !Eof()
        rec1 := RecNo()
      Endif
      Goto ( rec )
      deleterec()
      If rec1 == 0
        oBrow:gobottom()
      Else
        Goto ( rec1 )
      Endif
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase

  Return ret

//

//
Function f_is_otd( arr_o, pole_o )
  Return ( AScan( arr_o, {| x| pole_o == x[ 1 ] } ) > 0 )

// 23.12.15
Function inputn_otd( r, c, fl_all_uch, fl_all_otd, a_inp_uch, /*@*/c_otd)

  Static st_otd := {}
  Local i, k, mas_o := {}, mas := {}, t_mas, c2, pole, ;
    buf := SaveScreen(), tmp_select := Select(), l_a_otd

  If a_inp_uch == Nil // запросить учреждение
    k := input_uch( r, c, iif( fl_all_uch,, sys_date ) )
  Else  // учреждение уже было ранее выбрано
    k := glob_uch
  Endif
  If k != NIL
    mywait()
    pole := "otd->dbegin" ; pole2 := "otd->dend"
    If glob_task == X_PLATN
      pole += "p" ; pole2 += "p"
    Elseif glob_task == X_ORTO
      pole += "o" ; pole2 += "o"
    Endif
    r_use( dir_server() + "mo_otd",, "OTD" )
    Go Top
    Do While !Eof()
      If otd->kod_lpu == glob_uch[ 1 ] .and. ;
          iif( fl_all_otd, .t., between_date( &pole, &pole2, sys_date ) )
        AAdd( mas_o, otd->name )
        AAdd( mas, otd->( RecNo() ) )
      Endif
      Skip
    Enddo
    otd->( dbCloseArea() )
    If tmp_select > 0 ; Select( tmp_select ) ; Endif
    count_otd := c_otd := Len( mas )
    If count_otd == 1
      glob_otd := { mas[ 1 ], mas_o[ 1 ] }
      RestScreen( buf )
      Return { glob_otd }
    Endif
    If r < 0 // т.е. GET находится внизу экрана
      k := Abs( r ) -2
      If ( r := k - count_otd - 1 ) < 2
        r := 2
      Endif
    Else
      If ( k := r + count_otd + 1 ) > MaxRow() -2
        k := MaxRow() -2
      Endif
    Endif
    c2 := c + 35 + 1
    If c2 > 77
      c2 := 77 ; c := 76 -35
    Endif
    t_mas := AClone( mas_o )
    If Len( st_otd ) == 0
      If glob_otd[ 1 ] > 0
        AAdd( st_otd, glob_otd[ 1 ] )
      Else
        AEval( mas, {| x| AAdd( st_otd, x ) } )
      Endif
    Endif
    AEval( t_mas, {| x, i| ;
      t_mas[ i ] := if( AScan( st_otd, mas[ i ] ) > 0, " * ", "   " ) + t_mas[ i ] } )
    status_key( "^<Esc>^ отказ;  ^<Enter>^ подтверждение;  ^<Ins>^ смена признака выбора отделения" )
    Do While .t.
      l_a_otd := NIL
      If Popup( r, c, k, c2, t_mas, i, color_uch, .t., "fmenu_reader",, ;
          AllTrim( glob_uch[ 2 ] ), col_tit_uch ) > 0
        l_a_otd := {} ; st_otd := {}
        For i := 1 To Len( t_mas )
          If "*" == SubStr( t_mas[ i ], 2, 1 )
            AAdd( l_a_otd, { mas[ i ], mas_o[ i ] } )
            AAdd( st_otd, mas[ i ] )
          Endif
        Next
        If Empty( l_a_otd )
          func_error( 4, "Необходимо отметить хотя бы одно отделение!" )
          Loop
        Else
          If ( k := Len( l_a_otd ) ) == 1
            glob_otd := l_a_otd[ 1 ]
          Endif
          Exit
        Endif
      Else
        Exit
      Endif
    Enddo
  Endif
  RestScreen( buf )

  Return l_a_otd

//

//
Function err_date_diap( _ld, _ls )

  Local fl := .t.

  If !Empty( _ld )
    If !Empty( mem_date_1 ) .and. _ld < mem_date_1
      fl := .f.
    Endif
    If !Empty( mem_date_2 ) .and. _ld > mem_date_2
      fl := .f.
    Endif
    If !fl
      func_error( 4, 'Значение поля "' + _ls + '" выходит за допустимый диапазон времени!' )
    Endif
  Endif

  Return fl

//

//
Function say_rajreg( r, k, lmi )

  @ r, iif( k == 1, 38, 40 ) Say iif( lmi == 2, "регион", "район " )

  Return Nil

//

//
Function ret_koef_z( mkod_usl, mkod_vr, mkod_as )

  Local mk := { 0, 0, 0 }

  Return mk

//

//
Function f_is_uch( arr_u, pole_u )
  Return AScan( arr_u, {| x| pole_u == x[ 1 ] } ) > 0

// 23.12.15
Function inputn_uch( r, c, date1, date2, /*@*/c_uch)

  Static st_uch := {}
  Local i, k, mas_u := {}, mas := {}, t_mas, c2, ;
    buf := SaveScreen(), tmp_select := Select(), l_a_uch

  r_use( dir_server() + "mo_uch",, "UCH" )
  Go Top
  Do While !Eof()
    If between_date( uch->DBEGIN, uch->DEND, date1, date2 )
      AAdd( mas_u, uch->name )
      AAdd( mas, uch->( RecNo() ) )
    Endif
    Skip
  Enddo
  uch->( dbCloseArea() )
  If tmp_select > 0 ; Select( tmp_select ) ; Endif
  count_uch := c_uch := Len( mas )
  If count_uch == 0
    func_error( 4, "Справочник учреждений пуст!" )
    Return Nil
  Elseif count_uch == 1
    is_all_uch := .f.
    glob_uch := { mas[ 1 ], mas_u[ 1 ] }
    RestScreen( buf )
    Return { glob_uch }
  Else
    If r < 0 // т.е. GET находится внизу экрана
      k := Abs( r ) -2
      If ( r := k - count_uch - 1 ) < 2
        r := 2
      Endif
    Else
      If ( k := r + count_uch + 1 ) > MaxRow() -2
        k := MaxRow() -2
      Endif
    Endif
    c2 := c + 35 + 1
    If c2 > 77
      c2 := 77 ; c := 76 -35
    Endif
    t_mas := AClone( mas_u )
    If Len( st_uch ) == 0
      AEval( mas, {| x| AAdd( st_uch, x ) } )
    Endif
    AEval( t_mas, {| x, i| ;
      t_mas[ i ] := if( AScan( st_uch, mas[ i ] ) > 0, " * ", "   " ) + t_mas[ i ] } )
    status_key( "^<Esc>^ отказ;  ^<Enter>^ подтверждение;  ^<Ins>^ смена признака выбора учреждения" )
    Do While .t.
      l_a_uch := NIL
      If Popup( r, c, k, c2, t_mas, i, color_uch, .t., "fmenu_reader",, ;
          "Учреждения", col_tit_uch ) > 0
        l_a_uch := {} ; st_uch := {}
        For i := 1 To Len( t_mas )
          If "*" == SubStr( t_mas[ i ], 2, 1 )
            AAdd( l_a_uch, { mas[ i ], mas_u[ i ] } )
            AAdd( st_uch, mas[ i ] )
          Endif
        Next
        If Empty( l_a_uch )
          func_error( 4, "Необходимо отметить хотя бы одно учреждение!" )
          Loop
        Else
          If ( k := Len( l_a_uch ) ) == 1
            glob_uch := l_a_uch[ 1 ]
          Endif
          is_all_uch := ( k == count_uch )
          Exit
        Endif
      Else
        Exit
      Endif
    Enddo
  Endif
  RestScreen( buf )

  Return l_a_uch

// 03.04.14 вывести дату в 24 строке
Function date_24( mdate )

  @ MaxRow(), 69 Say full_date( mdate ) Color "W/R"

  Return Nil

//

//
Function usl_p_kart( mkod_human, mkod_lpu )

  Local k

  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( glob_kartotek )
  Private smvzros_reb := kart->vzros_reb, ;
    smdate_r := kart->date_r, ;
    smpol := kart->pol
  kart->( dbCloseArea() )
  If is_zf_stomat == 1
    k := stuslpkart( mkod_human, mkod_lpu )
  Else
    k := souslpkart( mkod_human, mkod_lpu )
  Endif

  Return k

//
Function fp_ret_lpu( k, r, c )

  Local fl := .f., mas, r1, r2

  If r < 13
    r1 := r + 1
  Else
    r2 := r -1
  Endif
  If inpute_otd( r1, c, r2 )
    mas := { glob_uch[ 1 ], PadR( glob_uch[ 2 ], 30 ) }
    m1otd := glob_otd[ 1 ] ; motd := PadR( glob_otd[ 2 ], 30 )
  Endif

  Return mas

//

//
Function sv_ved_plat()

  Local arr, arr_m, buf, arr_title, sh, HH := 40, reg_print := 3, ;
    n_file := cur_dir() + "svod_ved.txt", arr_otd := {}, old_kateg, lfio

  pi := 3
  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  Private ym_kol_mes := 1
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  arr_m := AClone( arr )
  g_use( dir_server() + "mo_otd",, "OTD" )
  dbEval( {|| AAdd( arr_otd, { otd->( RecNo() ), otd->name, otd->kod_lpu } ) }, ;
    {|| f_is_uch( st_a_uch, otd->kod_lpu ) } )
  OTD->( dbCloseArea() )
  buf := save_row( MaxRow() )
  If sv1_ved_plat( arr, arr_otd ) .and. sv2_ved_plat( arr, arr_otd )
    mywait()
    arr_title := Array( 6 )
    arr_title[ 1 ] := "────────────────────────────────────────┬─────────────────────────┬──────────────────┬──────────────────┬──────────────────╥─────────╥────────────"
    arr_title[ 2 ] := "                                        │    Страховая медицина   │  Платные услуги  │ Доплаты за услуги│    Материалы     ║         ║            "
    arr_title[ 3 ] := "                                        ├──────┬──────┬───────────┼──────┬───────────┼──────┬───────────┼──────┬───────────╢         ║            "
    arr_title[ 4 ] := "                                        │Кол-во│  %%  │ Стоимость │Кол-во│ Стоимость │Кол-во│ Стоимость │Кол-во│ Стоимость ║         ║  И Т О Г О "
    arr_title[ 5 ] := "                 Ф.И.О.                 │ услуг│выпол.│   услуг   │ услуг│   услуг   │ услуг│   услуг   │ услуг│   услуг   ║         ║            "
    arr_title[ 6 ] := "────────────────────────────────────────┴──────┴──────┴───────────┴──────┴───────────┴──────┴───────────┴──────┴───────────╨─────────╨────────────"
    sh := Len( arr_title[ 1 ] )
    g_use( dir_server() + "uch_pers", dir_server() + "uch_pers", "UCHP" )
    g_use( dir_server() + "mo_uch",, "UCH" )
    g_use( dir_server() + "mo_otd",, "OTD" )
    Set Relation To kod_lpu into UCH
    g_use( dir_server() + "mo_pers",, "perso" )
    Set Relation To otd into OTD
    Use ( cur_dir() + "tmp" ) New Alias TMP
    Set Relation To kod_vr into perso
    Index On Str( perso->kateg, 1 ) + Upper( uch->name ) + Upper( otd->name ) + Str( perso->otd, 3 ) + Upper( perso->fio ) to ( cur_dir() + "tmp" )
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( Center( "Сводная ведомость [объем работ]", sh ) )
    titlen_uch( st_a_uch, sh )
    add_string( Center( arr[ 4 ], sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    ss := ss1 := ss2 := ss3 := ss4 := 0 ; old_kateg := -1 ; old_otd := -1
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If !( perso->kateg == old_kateg )
        add_string( Replicate( "-", sh ) )
        add_string( '=== Категория "' + inieditspr( A__MENUVERT, gmenu_kateg, perso->kateg ) + '" ===' )
      Endif
      If !( perso->kateg == old_kateg .and. perso->otd == old_otd )
        s := ""
        If count_uch > 1
          s := "[" + AllTrim( uch->name ) + "] " + Expand( AllTrim( otd->name ) )
        Endif
        add_string( Space( 10 ) + s )
      Endif
      lfio := ""
      If mem_tabnom == 2
        Select TABN
        find ( Str( tmp->kod_vr, 4 ) )
        lfio := PadR( "[" + lstr( tabn->tab_nom ) + "]", 8 )
      Endif
      lfio += perso->fio
      s := tmp->stoim + tmp->stoim1 + tmp->stoim2 + tmp->stoim3
      j := ret_trudoem( tmp->kod_vr, tmp->trudoem, ym_kol_mes, arr_m )
      k := "  " + put_val_0( j, 5, 1 )
      add_string( PadR( lfio, 40 ) + ;
        put_val( tmp->kol, 7 ) + k + put_kope( tmp->stoim, 12 ) + ;
        put_val( tmp->kol1, 7 ) + put_kope( tmp->stoim1, 12 ) + ;
        put_val( tmp->kol2, 7 ) + put_kope( tmp->stoim2, 12 ) + ;
        put_val( tmp->kol3, 7 ) + put_kope( tmp->stoim3, 12 ) + ;
        " _________" + put_kope( s, 12 ) )
      ss1 += tmp->stoim
      ss2 += tmp->stoim1
      ss3 += tmp->stoim2
      ss4 += tmp->stoim3
      ss += s
      old_kateg := perso->kateg
      old_otd := perso->otd
      Select TMP
      Skip
    Enddo
    Close databases
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( Replicate( "-", sh ) )
    add_string( PadC( "Итого:", 40 ) + ;
      put_kope( ss1, 26 ) + ;
      put_kope( ss2, 19 ) + ;
      put_kope( ss3, 19 ) + ;
      put_kope( ss4, 19 ) + ;
      put_kope( ss, 22 ) )
    FClose( fp )
    rest_box( buf )
    viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  rest_box( buf )

  Return Nil

//

//
Function sv1_ved_plat( arr, arr_otd )

  Local i, j, begin_date, end_date, bk := 1, ek := 99, al, ;
    fl_exit := .f., sh := 80, HH := 57, regim := 2, s, fl_1_list := .t., ;
    len_n, pkol, ptrud, pstoim, old_perso, old_usl, ;
    old_fio, md, mkol, mstoim, arr_kd := {}, len_kd := 0, ;
    xx, yy, pole_va, lrec, t_date1, t_date2, arr_title, msum, msum_opl, ;
    musluga, mperso, mkod_perso, arr_usl := {}, adbf1, adbf2
  Private skol := { 0, 0 }, strud := { 0, 0 }, sstoim := { 0, 0 }
  Private fl_plan := .f., fl7_plan := .f.

  begin_date := arr[ 7 ]
  end_date := arr[ 8 ]
  If mem_trudoem == 2 .and. ym_kol_mes > 0
    fl_plan := .t.
    fl7_plan := .t.
  Endif
  adbf2 := { ;
    { "KOD_VR",     "N",      4,      0 }, ;  // код врача
  { "FIO",        "C",     50,      0 }, ;  // Ф.И.О. врача (ассистента)
    { "TRUDOEM",    "N",     11,      4 }, ;  // трудоемкость услуг УЕТ
  { "KOL",    "N",      6,      0 }, ;  // количество услуг
    { "STOIM",    "N",     14,      2 }, ;  // итоговая стоимость услуги
  { "KOL1",    "N",      6,      0 }, ;  // платные
    { "STOIM1",    "N",     14,      2 }, ;  // платные
  { "KOL2",    "N",      6,      0 }, ;  // доплаты за услуги
    { "STOIM2",    "N",     14,      2 }, ;  // доплаты за услуги
  { "KOL3",    "N",      6,      0 }, ;  // материалы
    { "STOIM3",    "N",     14,      2 };   // материалы
  }
  dbCreate( cur_dir() + "tmp", adbf2 )
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  Use ( cur_dir() + "tmp" )
  Index On Str( kod_vr, 4 ) to ( cur_dir() + "tmpk" )
  If mem_trudoem == 2
    useuch_usl()
  Endif
  // G_Use(dir_server()+"cena_usl",dir_server()+"cena_usl","CENA")
  r_use( dir_server() + "uslugi",, "USL" )
  // pi1 == 2  // по дате выписки счета
  pole_kol := "hu->kol_1"
  pole_stoim := "hu->stoim_1"
  r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
  r_use( dir_server() + "human", dir_server() + "humans", "HUMAN" )
  r_use( dir_server() + "schet", dir_server() + "schetd", "SCHET" )
  Set Filter To !eq_any( mest_inog, 6, 7 )
  dbSeek( begin_date, .t. )
  Do While schet->pdate <= end_date .and. !Eof()
    Select HUMAN
    find ( Str( schet->kod, 6 ) )
    Do While human->schet == schet->kod
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      // if human->cena_1 > 0
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod
        ob3_statist( arr_otd )
        Select HU
        Skip
      Enddo
      // endif
      Select HUMAN
      Skip
    Enddo
    If fl_exit ; exit ; Endif
    Select SCHET
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases

  Return !fl_exit

//
Static Function ob3_statist( arr_otd )

  Local i, mtrud := 0, koef_z := { 1, 1, 1 }, k1 := 2, s1 := "2"

  If hu->u_kod > 0 .and. ( &pole_kol > 0 .or. &pole_stoim > 0 ) .and. ;
      ( i := AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) ) > 0
    If mem_trudoem == 2
      mtrud := round_5( &pole_kol * opr_uet( human->vzros_reb ), 4 )
    Endif
    If fl7_plan
      k1 := 1 ; s1 := "1"
    Endif
    Select TMP
    If hu->kod_vr > 0
      find ( Str( hu->kod_vr, 4 ) )
      If !Found()
        Append Blank
        tmp->kod_vr := hu->kod_vr
      Endif
      tmp->kol += &pole_kol
      tmp->stoim += &pole_stoim * koef_z[ 2 ]
      tmp->trudoem += mtrud
      If fl7_plan
        strud[ 1 ] += mtrud
        sstoim[ 1 ] += &pole_stoim * koef_z[ 2 ]
      Endif
    Elseif hu->kod_as > 0
      find ( Str( hu->kod_as, 4 ) )
      If !Found()
        Append Blank
        tmp->kod_vr := hu->kod_as
      Endif
      tmp->kol += &pole_kol
      tmp->stoim += &pole_stoim * koef_z[ 3 ]
      tmp->trudoem += mtrud
      If fl7_plan
        strud[ 2 ] += mtrud
        sstoim[ 2 ] += &pole_stoim * koef_z[ 2 ]
      Endif
    Endif
  Endif

  Return Nil

//

//
Function sv2_ved_plat( arr, arr_otd )

  Local i, j, begin_date, end_date, bk := 1, ek := 99, al, ;
    fl_exit := .f., sh := 80, HH := 57, regim := 2, s, fl_1_list := .t., ;
    len_n, pkol, ptrud, pstoim, old_perso, old_usl, ;
    old_fio, md, mkol, mstoim, arr_kd := {}, len_kd := 0, ;
    xx, yy, pole_va, lrec, t_date1, t_date2, arr_title, msum, msum_opl, ;
    musluga, mperso, mkod_perso, arr_usl := {}, adbf1, adbf2
  Private skol := { 0, 0 }, strud := { 0, 0 }, sstoim := { 0, 0 }
/*Private usl_dop := rest_arr(dir_server()+"usl_pl_d"+smem()),;
        usl_mat := rest_arr(dir_server()+"usl_pl_m"+smem())*/

  begin_date := arr[ 7 ]
  end_date := arr[ 8 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmpk" ) Alias TMP
  If mem_trudoem == 2
    useuch_usl()
  Endif
  // G_Use(dir_server()+"cena_usl",dir_server()+"cena_usl","CENA")
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "uslugi", dir_server() + "uslugi", "USL" )
  // pi1 == 2  // по дате окончания лечения
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  r_use( dir_server() + "hum_p", dir_server() + "hum_pd", "HUMAN" )
  dbSeek( DToS( arr[ 5 ] ), .t. )
  Do While human->k_data <= arr[ 6 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    Select HU
    find ( Str( human->( RecNo() ), 7 ) )
    Do While hu->kod == human->( RecNo() )
      ob32_statist( arr_otd )
      Select HU
      Skip
    Enddo
    Select HUMAN
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases

  Return !fl_exit

//
Static Function ob32_statist( arr_otd )

  Local i, mtrud := 0, koef_z := { 1, 1, 1 }, k1 := 2, s1 := "1"
  Private  pole_kol, pole_stoim

  If hu->u_kod > 0 .and. ( hu->kol > 0 .or. hu->stoim > 0 ) .and. ;
      ( i := AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) ) > 0
    pole_kol   := "tmp->kol" + s1
    pole_stoim := "tmp->stoim" + s1
    Select TMP
    If hu->kod_vr > 0
      find ( Str( hu->kod_vr, 4 ) )
      If !Found()
        Append Blank
        tmp->kod_vr := hu->kod_vr
      Endif
      &pole_kol   := &pole_kol   + hu->kol
      &pole_stoim := &pole_stoim + hu->stoim * koef_z[ 2 ]
    Endif
  Endif

  Return Nil

//

//
Function souslpkart( mkod_human, mkod_lpu )

  // mkod_human - код по БД human
  Local adbf, buf := SaveScreen(), j := 0, tmp_color := SetColor( color1 ), ;
    l_color, mtitle, tmp_help := 0 // help_code
  Private fl_found, mcena := 0, ;
    last_date := CToD( "01.01.1990" ), mvu[ 3, 2 ], pr1otd, ;
    pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}, ;
    pr_kod_vr := 0, pr_kod_as := 0, ;
    pr_med1 := 0, pr_med2 := 0, pr_med3 := 0, ;
    pr_san1 := 0, pr_san2 := 0, pr_san3 := 0, is_open_u1 := .f.
  afillall( mvu, 0 )
  mywait()
  //
  r_use( dir_server() + "mo_otd",, "OTD" )
  dbEval( {|| if( mem_otdusl == 2, ;
    AAdd( pr1arr_otd, { otd->( RecNo() ), otd->name, otd->kod_lpu, "" } ), nil );
    }, ;
    {|| iif( yes_many_uch, .t., otd->kod_lpu == glob_uch[ 1 ] ) };
    )
  If yes_many_uch
    dbEval( {|| AAdd( pr_arr, { otd->( RecNo() ), otd->name, otd->kod_lpu, "" } ) }, ;
      {|| between_date( otd->dbeginp, otd->dendp, sys_date ) } )
    r_use( dir_server() + "mo_uch",, "UCH" )
    AEval( pr_arr, {| x, i| dbGoto( x[ 3 ] ), pr_arr[ i, 4 ] := uch->name } )
    AEval( pr1arr_otd, {| x, i| dbGoto( x[ 3 ] ), pr1arr_otd[ i, 4 ] := uch->name } )
    uch->( dbCloseArea() )
    //
    ASort( pr_arr,,, {| x, y| iif( x[ 3 ] == y[ 3 ], Upper( x[ 2 ] ) < Upper( y[ 2 ] ), ;
      Upper( x[ 4 ] ) < Upper( y[ 4 ] ) ) } )
    AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 4 ] + " " + x[ 2 ] ) } )
  Else
    dbEval( {|| AAdd( pr_arr, { otd->( RecNo() ), otd->name, otd->kod_lpu, "" } ) }, ;
      {|| otd->kod_lpu == mkod_lpu .and. between_date( otd->dbeginp, otd->dendp, sys_date ) } )
    ASort( pr_arr,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
    AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 2 ] ) } )
  Endif
  //
  r_use( dir_server() + "uslugi",, "USL" )
  g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  adbf := dbStruct()
  AAdd( adbf, { "date_u1", "D", 8, 0 } )
  AAdd( adbf, { "shifr_u", "C", 10, 0 } )
  AAdd( adbf, { "name_u", "C", 65, 0 } )
  AAdd( adbf, { "is_nul", "L", 1, 0 } )
  AAdd( adbf, { "number", "N", 6, 0 } )
  AAdd( adbf, { "rec_hu", "N", 7, 0 } )
  dbCreate( cur_dir() + "tmp_usl", adbf )
  Use ( cur_dir() + "tmp_usl" ) New Alias tmp
  Private i_date_u1 := FieldPos( "date_u1" )
  If mem_ordusl == 1
    Index On DToS( date_u1 ) + fsort_usl( shifr_u ) to ( cur_dir() + "tmp_usl" )
  Else
    Index On fsort_usl( shifr_u ) + DToS( date_u1 ) to ( cur_dir() + "tmp_usl" )
  Endif
  Select HU
  Set Relation To u_kod into USL
  find ( Str( mkod_human, 7 ) )
  If ( fl_found := Found() )
    adbf := Array( FCount() )
    Do While hu->kod == mkod_human .and. !Eof()
      AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
      Select TMP
      Append Blank
      AEval( adbf, {| x, i| FieldPut( i, x ) } )
      pr_kod_vr := tmp->kod_vr
      pr_kod_as := tmp->kod_as
      pr_med1 := tmp->med1
      pr_med2 := tmp->med2
      pr_med3 := tmp->med3
      pr_san1 := tmp->san1
      pr_san2 := tmp->san2
      pr_san3 := tmp->san3
      tmp->date_u1 := c4tod( hu->date_u )
      tmp->shifr_u := usl->shifr
      tmp->name_u := usl->name
      tmp->is_nul := usl->is_nulp
      tmp->rec_hu := hu->( RecNo() )
      last_date := Max( tmp->date_u1, last_date )
      mcena += tmp->stoim
      Select HU
      Skip
    Enddo
  Endif
  tmp->( dbEval( {|| tmp->number := ++j } ) )
  Close databases
  //
  Private flag_1 := .t.
  If g_use( dir_server() + "hum_p",, "HUMAN" ) .and. ;
      g_use( dir_server() + "hum_p_u", { dir_server() + "hum_p_u", ;
      dir_server() + "hum_p_uk", ;
      dir_server() + "hum_p_ud", ;
      dir_server() + "hum_p_uv", ;
      dir_server() + "hum_p_ua" }, "HU" ) .and. ;
      r_use( dir_server() + "uslugi", dir_server() + "uslugish", "USL" ) .and. ;
      r_use( dir_server() + "mo_otd",, "OTD" ) .and. ;
      r_use( dir_server() + "plat_ms", dir_server() + "plat_ms", "MS" ) .and. ;
      r_use( dir_server() + "usl_otd", dir_server() + "usl_otd", "UO" ) .and. ;
      r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
    Select HUMAN
    Goto ( mkod_human )
    last_date := Max( human->n_data, last_date )
    Private is_kassa := ( human->is_kas != 1 )
    Use ( cur_dir() + "tmp_usl" ) index ( cur_dir() + "tmp_usl" ) New Alias TMP
    Set Relation To otd into OTD
    Go Top
    cls
    pr_1_str( "Платные услуги для больного < " + AllTrim( glob_k_fio ) + " >" )
    SetColor( "BG/B" )
    SetColor( "BG/B" )
    l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"
    @ MaxRow() -3, 0 Say "╒═══════════════════ Полное наименование услуги ═══════════════════╤══ Цена ═══╕"
    @ MaxRow() -2, 0 Say "│                                                                  │           │"
    @ MaxRow() -1, 0 Say "╘══════════════════════════════════════════════════════════════════╧═══════════╛"
    If fl_found
      Keyboard Chr( K_RIGHT )
    Else
      Keyboard Chr( K_INS )
    Endif
    SetColor( color1 )
    mtitle := f_srok_lech( human->n_data, human->k_data )
    If !is_kassa
      @ 1, 1 Say " ЧЕК " Color "G+*/B"
    Endif
    // help_code := HM_Edit_kart
    alpha_browse( 2, 0, MaxRow() -5, 79, "Fe_p_kusl", color1, mtitle, col_tit_popup, ;
      .f., .t.,, "F1e_p_kusl", "F2e_p_kusl",, ;
      { "═", "░", "═", l_color, .t., 180 } )
    If yes_parol .and. ( mvu[ 1, 1 ] > 0 .or. mvu[ 2, 1 ] > 0 .or. mvu[ 3, 1 ] > 0 ) ;
        .and. hb_FileExists( dir_server() + "mo_opern" + sdbf() )
      Close databases
      If g_use( dir_server() + "mo_opern", dir_server() + "mo_opern", "OP" )
        For i := 1 To 3
          If mvu[ i, 1 ] > 0
            write_work_oper( glob_task, OPER_USL, i, mvu[ i, 1 ], mvu[ i, 2 ], .f. )
          Endif
        Next
      Endif
    Endif
    Close databases
  Endif
  Close databases
  SetColor( tmp_color )
  RestScreen( buf )
  help_code := tmp_help

  Return mcena

//
Function fe_p_kusl( oBrow )

  Local oColumn, blk_color := {|| if( tmp->t_edit > 1, { 3, 4 }, { 1, 2 } ) }

  oColumn := TBColumnNew( " NN; пп", {|| Str( tmp->number, 3 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  If mem_ordusl == 1
    oColumn := TBColumnNew( "Дата;оказ.; усл.", {|| Left( DToC( tmp->date_u1 ), 5 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( "   Шифр;  услуги", {|| tmp->shifr_u } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  If mem_ordusl == 2
    oColumn := TBColumnNew( "Дата;оказ.; усл.", {|| Left( DToC( tmp->date_u1 ), 5 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( "Отде-;ление", {|| otd->short_name } )
  oColumn:defColor := { 6, 6 }
  oColumn:colorBlock := {|| { 6, 6 } }
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  Наименование;  услуги", {|| Left( tmp->name_u, 16 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Врач", {|| put_val( ret_tabn( tmp->kod_vr ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Асс.", {|| put_val( ret_tabn( tmp->kod_as ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Ко-;лич.;усл.", {|| tmp->kol } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Общая; стоимость; услуги", {|| put_kop( tmp->stoim, 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление; ^<F1>^ помощь" )

  Return Nil

//
Function f1e_p_kusl()

  Local nRow := Row(), nCol := Col()

  @ MaxRow() -2, 2 Say tmp->name_u Color cDataCSay
  @ MaxRow() -2, 68 Say if( Empty( tmp->u_cena ), Space( 11 ), ;
    PadC( AllTrim( dellastnul( tmp->u_cena, 10, 2 ) ), 11 ) ) Color cDataCSay
  If flag_1
    f3e_p_kusl()
    flag_1 := .f.
  Endif
  @ nRow, nCol Say ""

  Return Nil

//
Function f3e_p_kusl()

  @ MaxRow() -4, 60 Say PadL( "Итого: " + lstr( mcena, 11, 2 ), 19 ) Color "W+/N"

  Return Nil

//

//
Function f2e_p_kusl( nKey, oBrow )

  Static st_vzrosl, st_arr_dbf
  Local flag := -1, buf := SaveScreen(), fl := .f., rec, ;
    i1, k, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := SetColor(), ;
    rec_tmp := tmp->( RecNo() ), mrec_hu := tmp->rec_hu, date_tmp := tmp->date_u1, ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    tmp_help := 0, uch_otd := saveuchotd()  // help_code
  Private r1 := 10

  If eq_any( nKey, K_F4, K_F5, K_CTRL_F5, K_CTRL_F10, K_F11, K_INS, K_ENTER, K_DEL )
    If !ver_pub_date( human->k_data, .t. )
      Return flag
    Endif
    If nKey != K_ENTER .and. !is_kassa
      func_error( 4, "По данному листу учета уже пробит чек. Операция запрещена!" )
      Return flag
    Endif
  Endif
  Do Case
  Case nKey == K_F10 .and. tmp->kod > 0 .and. f_esc_enter( "запоминания услуг" )
    mywait()
    st_vzrosl := ( smvzros_reb == 0 )
    st_arr_dbf := {}
    Select TMP
    adbf1 := Array( FCount() )
    Go Top
    Do While !Eof()
      AEval( adbf1, {| x, i| adbf1[ i ] := FieldGet( i ) } )
      AAdd( st_arr_dbf, AClone( adbf1 ) )
      Select TMP
      Skip
    Enddo
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    stat_msg( "Услуги запомнены!" ) ; mybell( 1, OK )
    RestScreen( buf )
    flag := 0
  Case eq_any( nKey, K_CTRL_F10, K_F11 ) .and. st_arr_dbf != NIL
    If !fl_found
      ColorWin( 7, 0, 7, 79, "B/B", "W+/RB" )
    Endif
    If st_vzrosl != ( smvzros_reb == 0 )
      func_error( 4, 'Критерий "взрослый/ребенок" у данного больного отличается от предыдущего!' )
    Elseif f_esc_enter( "копирования услуг" )
      mywait()
      last_date := human->n_data
      min_date := st_arr_dbf[ 1, i_date_u1 ]
      For k := 1 To Len( st_arr_dbf )
        min_date := Min( st_arr_dbf[ k, i_date_u1 ], min_date )
      Next
      Select HU
      adbf := Array( FCount() )
      i1 := Len( adbf )
      For k := 1 To Len( st_arr_dbf )
        fl_found := .t.
        ++mvu[1,1 ]  // услуги добавлены оператором
        Select HU
        add1rec( 7 )
        AEval( st_arr_dbf[ k ], {| x, i| FieldPut( i, x ) }, 1, i1 )
        hu->kod := human->( RecNo() )
        new_date := human->n_data + ( st_arr_dbf[ k, i_date_u1 ] - min_date )
        If !Between( new_date, human->n_data, human->k_data )
          new_date := human->k_data
        Endif
        hu->date_u := dtoc4( new_date )
        Unlock
        Select TMP
        Append Blank
        AEval( st_arr_dbf[ k ], {| x, i| FieldPut( i, x ) } )
        tmp->kod := human->( RecNo() )
        tmp->date_u := dtoc4( new_date )
        tmp->date_u1 := new_date
        tmp->rec_hu := hu->( RecNo() )
        last_date := Max( tmp->date_u1, last_date )
        // если надо, переопределение цены
        If .f.
        Endif
      Next
      summa_usl( @mcena )
      Select HUMAN
      g_rlock( forever )
      Replace human->cena With mcena
      Unlock
      Commit
      stat_msg( "Услуги скопированы!" ) ; mybell( 1, OK )
      RestScreen( buf )
      f3e_p_kusl()
      Select TMP
      oBrow:gotop()
      flag := 0
    Elseif !fl_found
      flag := 1
    Endif
  Case eq_any( nKey, K_F4, K_F5, K_CTRL_F5 ) .and. tmp->kod > 0
    If ( arr_dni := uk_arr_dni( nKey ) ) != NIL
      mywait()
      arr_u := {}
      Select HU
      adbf := Array( FCount() )
      Select TMP
      adbf1 := Array( FCount() )
      If eq_any( nkey, K_F4, K_F5 )  // запомнить копируемую услугу
        Select HU
        Goto ( mrec_hu )
        AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
        Select TMP
        AEval( adbf1, {| x, i| adbf1[ i ] := FieldGet( i ) } )
        AAdd( arr_u, { AClone( adbf ), AClone( adbf1 ) } )
      Else
        Select TMP
        Go Top
        Do While !Eof()
          If date_tmp == tmp->date_u1  // запомнить все услуги за этот день
            mrec_hu := tmp->rec_hu
            Select HU
            Goto ( mrec_hu )
            AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
            Select TMP
            AEval( adbf1, {| x, i| adbf1[ i ] := FieldGet( i ) } )
            AAdd( arr_u, { AClone( adbf ), AClone( adbf1 ) } )
          Endif
          Select TMP
          Skip
        Enddo
      Endif
      For k := 1 To Len( arr_dni )
        For j := 1 To Len( arr_u )
          ++mvu[1,1 ]  // услуги добавлены оператором
          Select HU
          add1rec( 7 )
          AEval( arr_u[ j, 1 ], {| x, i| FieldPut( i, x ) } )
          hu->date_u := dtoc4( arr_dni[ k, 2 ] )
          mrec_hu := hu->( RecNo() )
          Unlock
          Select TMP
          Append Blank
          AEval( arr_u[ j, 2 ], {| x, i| FieldPut( i, x ) } )
          tmp->date_u1 := arr_dni[ k, 2 ]
          tmp->rec_hu := mrec_hu
          rec_tmp := tmp->( RecNo() )
          // если надо, переопределение цены
          If .f.
          Endif
        Next
      Next
      hu->( dbCommit() )
      summa_usl( @mcena )
      Select HUMAN
      g_rlock( forever )
      Replace human->cena With mcena
      Unlock
      human->( dbCommit() )
      RestScreen( buf )
      f3e_p_kusl()
      Select TMP
      oBrow:gotop()
      Goto ( rec_tmp )
      SetColor( tmp_color )
      flag := 0
    Endif
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. tmp->kod > 0 )
    // help_code := HM_Edit1_kart
    If nKey == K_INS .and. !fl_found
      ColorWin( 7, 0, 7, 79, "B/B", "W+/RB" )
    Endif
    Private motd, m1otd := if( nKey == K_INS, ;
      if( pr1otd == NIL, 0, pr1otd ), tmp->otd ), ;
      mu_kod := if( nKey == K_INS, 0, tmp->u_kod ), ;
      mdate_u1 := if( nKey == K_INS, last_date, tmp->date_u1 ), ;
      mis_nul := if( nKey == K_INS, .f., tmp->is_nul ), ;
      mu_cena := if( nKey == K_INS, 0, tmp->u_cena ), ;
      mkod_vr := if( nKey == K_INS, pr_kod_vr, tmp->kod_vr ), ;
      mtabn_vr := 0, mvrach := Space( 35 ), ;
      mkod_as := if( nKey == K_INS, pr_kod_as, tmp->kod_as ), ;
      mtabn_as := 0, massist := Space( 35 ), ;
      mkol := if( nKey == K_INS, 0, tmp->kol ), ;
      mstoim := if( nKey == K_INS, 0, tmp->stoim ), ;
      mt_edit := if( nKey == K_INS, 0, tmp->t_edit ), ;
      mshifr := if( nKey == K_INS, Space( 10 ), tmp->shifr_u ), ;
      mname_u := if( nKey == K_INS, Space( 65 ), tmp->name_u ), ;
      pmmed1 := if( nKey == K_INS, pr_med1, tmp->med1 ), mmed1 := 0, ;
      pmmed2 := if( nKey == K_INS, pr_med2, tmp->med2 ), mmed2 := 0, ;
      pmmed3 := if( nKey == K_INS, pr_med3, tmp->med3 ), mmed3 := 0, ;
      pmsan1 := if( nKey == K_INS, pr_san1, tmp->san1 ), msan1 := 0, ;
      pmsan2 := if( nKey == K_INS, pr_san2, tmp->san2 ), msan2 := 0, ;
      pmsan3 := if( nKey == K_INS, pr_san3, tmp->san3 ), msan3 := 0, ;
      pr_k_usl := {}, ;  // массив комплексных услуг
    gl_area := { 1, 0, 23, 79, 0 }
    motd := inieditspr( A__POPUPMENU, dir_server() + "mo_otd", m1otd )
    If mkod_vr > 0
      Select PERSO
      Goto ( mkod_vr )
      mvrach := PadR( perso->fio, 35 )
      mtabn_vr := perso->tab_nom
    Endif
    If mkod_as > 0
      Select PERSO
      Goto ( mkod_as )
      massist := PadR( perso->fio, 35 )
      mtabn_as := perso->tab_nom
    Endif
    Select MS
    If pmmed1 > 0
      Goto ( pmmed1 )
      If !Eof() .and. ms->tip == 1
        mmed1 := ms->tab_nom
      Endif
    Endif
    If pmmed2 > 0
      Goto ( pmmed2 )
      If !Eof() .and. ms->tip == 1
        mmed2 := ms->tab_nom
      Endif
    Endif
    If pmmed3 > 0
      Goto ( pmmed3 )
      If !Eof() .and. ms->tip == 1
        mmed3 := ms->tab_nom
      Endif
    Endif
    If pmsan1 > 0
      Goto ( pmsan1 )
      If !Eof() .and. ms->tip == 2
        msan1 := ms->tab_nom
      Endif
    Endif
    If pmsan2 > 0
      Goto ( pmsan2 )
      If !Eof() .and. ms->tip == 2
        msan2 := ms->tab_nom
      Endif
    Endif
    If pmsan3 > 0
      Goto ( pmsan3 )
      If !Eof() .and. ms->tip == 2
        msan3 := ms->tab_nom
      Endif
    Endif
    box_shadow( r1 -1, 0, 23, 79, color8, ;
      if( nKey == K_INS, "Добавление новой", ;
      "Редактирование" ) + " платной услуги", "RB+/B" )
    Do While .t.
      SetColor( cDataCGet )
      If mem_kodotd == 1
        @ r1 + 1, 2 Say "Отделение, в котором оказана услуга" Get motd ;
          reader {| x| menu_reader( x, ;
          { {| k, r, c| get_otd( k, r + 1, c, .t. ) } }, A__FUNCTION,,, .f. ) }
      Else
        @ r1 + 1, 2 Say "Отделение, в котором оказана услуга" Get m1otd Pict "99" ;
          when {| g| f5e_p_kusl( g, 1, 10 ) } ;
          valid {| g| f5e_p_kusl( g, 2, 10 ) }
        @ Row(), Col() + 2 Get motd Color color14 When .f.
      Endif
      @ r1 + 2, 2 Say "Дата оказания услуги" Get mdate_u1 ;
        valid {| g| f5e_p_kusl( g, 2, 1 ) }
      @ r1 + 3, 2 Say "Шифр услуги" Get mshifr Pict "@!" ;
        when {| g| f5e_p_kusl( g, 1, 2 ) } ;
        valid {| g| f5e_p_kusl( g, 2, 2 ) }
      @ Row(), 40 Say "Цена услуги" Get mu_cena Pict pict_cena() ;
        When .f. Color color14
      @ r1 + 4, 2 Say "Услуга" Get mname_u When .f. Color color14
      ix := 4
      For x := 1 To 3
        If mem_por_vr == x
          ++ix
          @ r1 + ix, 2 Say "Таб.N врача" Get mtabn_vr Pict "99999" ;
            valid {| g| f5e_p_kusl( g, 2, 3 ) }
          @ Row(), Col() + 3 Get mvrach When .f. Color color14
        Endif
        If mem_por_ass == x
          ++ix
          @ r1 + ix, 2 Say "Таб.N ассистента" Get mtabn_as Pict "99999" ;
            valid {| g| f5e_p_kusl( g, 2, 4 ) }
          @ Row(), Col() + 3 Get massist When .f. Color color14
        Endif
        If mem_por_kol == x
          ++ix
          @ r1 + ix, 2 Say "Количество услуг" Get mkol Pict "999" ;
            when {| g| is_kassa .and. f5e_p_kusl( g, 1, 5 ) } ;
            valid {| g| f5e_p_kusl( g, 2, 5 ) }
        Endif
      Next
      @ r1 + 9, 2 Say "Общая стоимость услуги" Get mstoim Pict pict_cena() ;
        when {| g| is_kassa .and. mem_edit_s == 2 .and. f5e_p_kusl( g, 1, 7 ) } ;
        valid {| g| f5e_p_kusl( g, 2, 7 ) }
      If mt_edit > 1
        @ r1 + 9, 37 Say "[ редактировалась стоимость услуги ]" Color color13
      Endif
      If is_oplata != 7
        @ r1 + 10, 2 Say "Коды медсестер" Get mmed1 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 11 ) }
        @ Row(), Col() Say "," Get mmed2 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 11 ) }
        @ Row(), Col() Say "," Get mmed3 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 11 ) }
        @ r1 + 11, 2 Say "Коды санитарок" Get msan1 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 12 ) }
        @ Row(), Col() Say "," Get msan2 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 12 ) }
        @ Row(), Col() Say "," Get msan3 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 12 ) }
      Endif
      status_key( "^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи" )

      Set Key K_F11 To clear_gets
      Set Key K_CTRL_F10 To clear_gets
      count_edit := myread(, @pos_read, ++k_read )
      SetKey( K_F2, NIL )
      SetKey( K_F3, NIL )
      SetKey( K_F11, NIL )
      SetKey( K_CTRL_F10, NIL )
      If eq_any( LastKey(), K_CTRL_F10, K_F11 )
        hb_keyPut( K_CTRL_F10 ) // keysend(KS_CTRL_F10)
      Elseif LastKey() != K_ESC
        If Empty( mdate_u1 )
          func_error( 4, "Не введена дата оказания услуги!" )
          Loop
        Elseif Len( pr_k_usl ) == 0 .and. Empty( mu_kod )
          func_error( 4, "Не введена услуга!" )
          Loop
        Elseif Len( pr_k_usl ) == 0 .and. !mis_nul .and. Empty( mstoim )
          func_error( 4, "Не введена цена услуги!" )
          Loop
        Elseif mem_vv_v_a == 1 .and. emptyall( mkod_vr, mkod_as )
          func_error( 4, "Не введены врач и ассистент!" )
          Loop
        Else
          err_date_diap( mdate_u1, "Дата оказания услуги" )
          mywait()
          If nKey == K_INS
            mvu[ 1, 2 ] += count_edit
          Else
            mvu[ 2, 2 ] += count_edit
          Endif
          If nKey == K_INS .and. Len( pr_k_usl ) > 0
            // комплексная услуга
            For i := 1 To Len( pr_k_usl )
              mshifr := pr_k_usl[ i, 1 ]
              mu_kod := pr_k_usl[ i, 3 ]
              mname_u := pr_k_usl[ i, 4 ]
              mu_cena := pr_k_usl[ i, 5 ]
              mt_edit := pr_k_usl[ i, 7 ]
              mis_nul := pr_k_usl[ i, 9 ]
              mstoim := round_5( mu_cena * mkol, 2 )
              Select HU
              add1rec( 7 )
              mrec_hu := hu->( RecNo() )
              fl_found := .t.
              Select TMP
              Append Blank
              rec_tmp := tmp->( RecNo() )
              ++mvu[1,1 ]  // услуга добавлена оператором
              //
              Select HU
              Replace hu->kod     With human->( RecNo() ), ;
                hu->kod_vr  With mkod_vr, ;
                hu->kod_as  With mkod_as, ;
                hu->u_koef  With 1, ;
                hu->stoim   With mstoim, ;
                hu->u_kod   With mu_kod, ;
                hu->u_cena  With mu_cena, ;
                hu->t_edit  With mt_edit, ;
                hu->kol     With mkol, ;
                hu->date_u  With dtoc4( mdate_u1 ), ;
                hu->otd     With m1otd, ;
                hu->med1    With pmmed1, ;
                hu->med2    With pmmed2, ;
                hu->med3    With pmmed3, ;
                hu->san1    With pmsan1, ;
                hu->san2    With pmsan2, ;
                hu->san3    With pmsan3
              Unlock
              pr1otd := m1otd
              adbf := Array( FCount() )
              AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
              Select TMP
              AEval( adbf, {| x, i| FieldPut( i, x ) } )
              tmp->date_u1 := mdate_u1
              tmp->shifr_u := mshifr
              tmp->name_u := mname_u
              tmp->is_nul := mis_nul
              tmp->rec_hu := mrec_hu
              last_date := tmp->date_u1  // - так стало
              pr_kod_vr := tmp->kod_vr
              pr_kod_as := tmp->kod_as
              pr_med1 := tmp->med1
              pr_med2 := tmp->med2
              pr_med3 := tmp->med3
              pr_san1 := tmp->san1
              pr_san2 := tmp->san2
              pr_san3 := tmp->san3
            Next
            summa_usl( @mcena )
            Select HUMAN
            g_rlock( forever )
            human->cena := mcena
          Else
            // одна услуга
            Select HU
            If nKey == K_INS
              add1rec( 7 )
              mrec_hu := hu->( RecNo() )
              fl_found := .t.
              Select TMP
              Append Blank
              rec_tmp := tmp->( RecNo() )
              ++mvu[1,1 ]  // услуга добавлена оператором
            Else
              Goto ( mrec_hu )
              g_rlock( forever )
              Select TMP
              Goto ( rec_tmp )
              ++mvu[2,1 ]  // услуга отредактирована оператором
            Endif
            Select HU
            Replace hu->kod     With human->( RecNo() ), ;
              hu->kod_vr  With mkod_vr, ;
              hu->kod_as  With mkod_as, ;
              hu->u_koef  With 1, ;
              hu->stoim   With mstoim, ;
              hu->u_kod   With mu_kod, ;
              hu->u_cena  With mu_cena, ;
              hu->t_edit  With mt_edit, ;
              hu->kol     With mkol, ;
              hu->date_u  With dtoc4( mdate_u1 ), ;
              hu->otd     With m1otd, ;
              hu->med1    With pmmed1, ;
              hu->med2    With pmmed2, ;
              hu->med3    With pmmed3, ;
              hu->san1    With pmsan1, ;
              hu->san2    With pmsan2, ;
              hu->san3    With pmsan3
            Unlock
            pr1otd := m1otd
            adbf := Array( FCount() )
            AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
            Select TMP
            AEval( adbf, {| x, i| FieldPut( i, x ) } )
            tmp->date_u1 := mdate_u1
            tmp->shifr_u := mshifr
            tmp->name_u := mname_u
            tmp->is_nul := mis_nul
            tmp->rec_hu := mrec_hu
            // last_date := max(tmp->date_u1,last_date) - так было
            last_date := tmp->date_u1  // - так стало
            pr_kod_vr := tmp->kod_vr
            pr_kod_as := tmp->kod_as
            pr_med1 := tmp->med1
            pr_med2 := tmp->med2
            pr_med3 := tmp->med3
            pr_san1 := tmp->san1
            pr_san2 := tmp->san2
            pr_san3 := tmp->san3
          Endif
          summa_usl( @mcena )
          Select HUMAN
          g_rlock( forever )
          human->cena := mcena
          Unlock
          Commit
        Endif
      Endif
      Exit
    Enddo
    flag := 0
    If nKey == K_INS .and. !fl_found .and. !eq_any( LastKey(), K_CTRL_F10, K_F11 )
      flag := 1
    Endif
    RestScreen( buf )
    f3e_p_kusl()
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
  Case nKey == K_DEL .and. tmp->kod > 0
    If f_esc_enter( 2 )
      mywait()
      ++mvu[3,1 ]  // услуга удалена оператором
      Select HU
      Goto ( tmp->rec_hu )
      deleterec( .t., .f. )  // очистка записи без пометки на удаление
      Select TMP
      deleterec( .t. )  // с пометкой на удаление
      summa_usl( @mcena )
      Select HUMAN
      g_rlock( forever )
      Replace human->cena With mcena
      Unlock
      Commit
      Select TMP
      oBrow:gotop()
      Go Top
      If Eof()
        fl_found := .f. ; Keyboard Chr( K_INS )
      Endif
      flag := 0
      RestScreen( buf )
      f3e_p_kusl()
    Endif
  Otherwise
    Keyboard ""
  Endcase
  help_code := tmp_help
  restuchotd( uch_otd )

  Return flag

//

// 08.10.17
Function stuslpkart( mkod_human, mkod_lpu )

  // mkod_human - код по БД human
  Local adbf, buf := SaveScreen(), j := 0, tmp_color := SetColor( color1 ), ;
    l_color, mtitle, tmp_help := 0 // help_code
  Private fl_found, mcena := 0, ;
    last_date := CToD( "01.01.1990" ), mvu[ 3, 2 ], pr1otd, ;
    pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}, ;
    pr_kod_vr := 0, pr_kod_as := 0, ;
    pr_med1 := 0, pr_med2 := 0, pr_med3 := 0, ;
    pr_san1 := 0, pr_san2 := 0, pr_san3 := 0, is_open_u1 := .f.
  afillall( mvu, 0 )
  mywait()
  //
  r_use( dir_server() + "mo_otd",, "OTD" )
  dbEval( {|| iif( mem_otdusl == 2, AAdd( pr1arr_otd, { otd->( RecNo() ), otd->name, otd->kod_lpu, "" } ), ) }, ;
    {|| iif( yes_many_uch, .t., otd->kod_lpu == glob_uch[ 1 ] ) };
    )
  If yes_many_uch
    dbEval( {|| AAdd( pr_arr, { otd->( RecNo() ), otd->name, otd->kod_lpu, "" } ) }, ;
      {|| between_date( otd->dbeginp, otd->dendp, sys_date ) } )
    r_use( dir_server() + "mo_uch",, "UCH" )
    AEval( pr_arr, {| x, i| dbGoto( x[ 3 ] ), pr_arr[ i, 4 ] := uch->name } )
    AEval( pr1arr_otd, {| x, i| dbGoto( x[ 3 ] ), pr1arr_otd[ i, 4 ] := uch->name } )
    uch->( dbCloseArea() )
    //
    ASort( pr_arr,,, {| x, y| iif( x[ 3 ] == y[ 3 ], Upper( x[ 2 ] ) < Upper( y[ 2 ] ), ;
      Upper( x[ 4 ] ) < Upper( y[ 4 ] ) ) } )
    AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 4 ] + " " + x[ 2 ] ) } )
  Else
    dbEval( {|| AAdd( pr_arr, { otd->( RecNo() ), otd->name, otd->kod_lpu, "" } ) }, ;
      {|| otd->kod_lpu == mkod_lpu .and. between_date( otd->dbeginp, otd->dendp, sys_date ) } )
    ASort( pr_arr,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
    AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 2 ] ) } )
  Endif
  //
  use_base( "humanst" )
  r_use( dir_server() + "uslugi",, "USL" )
  g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  adbf := dbStruct()
  AAdd( adbf, { "KOD_DIAG", "C", 5, 0 } )  // шифр 1-ой осн.болезни
  AAdd( adbf, { "ZF", "C", 30, 0 } )  // зубная формула
  AAdd( adbf, { "date_u1",  "D", 8, 0 } )
  AAdd( adbf, { "shifr_u",  "C", 10, 0 } )
  AAdd( adbf, { "name_u",   "C", 65, 0 } )
  AAdd( adbf, { "is_nul",   "L", 1, 0 } )
  AAdd( adbf, { "number",   "N", 6, 0 } )
  AAdd( adbf, { "rec_hu",   "N", 7, 0 } )
  dbCreate( cur_dir() + "tmp_usl", adbf )
  Use ( cur_dir() + "tmp_usl" ) New Alias tmp
  Private i_date_u1 := FieldPos( "date_u1" )
  If mem_ordusl == 1
    Index On DToS( date_u1 ) + fsort_usl( shifr_u ) to ( cur_dir() + "tmp_usl" )
  Else
    Index On fsort_usl( shifr_u ) + DToS( date_u1 ) to ( cur_dir() + "tmp_usl" )
  Endif
  Select HU
  Set Relation To u_kod into USL
  find ( Str( mkod_human, 7 ) )
  If ( fl_found := Found() )
    adbf := Array( FCount() )
    Do While hu->kod == mkod_human .and. !Eof()
      AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
      Select TMP
      Append Blank
      AEval( adbf, {| x, i| FieldPut( i, x ) } )
      pr_kod_vr := tmp->kod_vr
      pr_kod_as := tmp->kod_as
      pr_med1 := tmp->med1
      pr_med2 := tmp->med2
      pr_med3 := tmp->med3
      pr_san1 := tmp->san1
      pr_san2 := tmp->san2
      pr_san3 := tmp->san3
      tmp->date_u1 := c4tod( hu->date_u )
      tmp->shifr_u := usl->shifr
      tmp->name_u := usl->name
      tmp->is_nul := usl->is_nulp
      tmp->rec_hu := hu->( RecNo() )
      Select HUMANST
      find ( Str( 2, 1 ) + Str( hu->( RecNo() ), 8 ) )
      If Found()
        tmp->KOD_DIAG  := humanst->KOD_DIAG
        tmp->ZF        := humanst->ZF
      Endif
      last_date := Max( tmp->date_u1, last_date )
      mcena += tmp->stoim
      Select HU
      Skip
    Enddo
  Endif
  tmp->( dbEval( {|| tmp->number := ++j } ) )
  Close databases
  //
  Private flag_1 := .t.
  If g_use( dir_server() + "hum_p",, "HUMAN" ) .and. ;
      g_use( dir_server() + "hum_p_u", { dir_server() + "hum_p_u", ;
      dir_server() + "hum_p_uk", ;
      dir_server() + "hum_p_ud", ;
      dir_server() + "hum_p_uv", ;
      dir_server() + "hum_p_ua" }, "HU" ) .and. ;
      r_use( dir_server() + "uslugi", dir_server() + "uslugish", "USL" ) .and. ;
      r_use( dir_server() + "mo_otd",, "OTD" ) .and. ;
      r_use( dir_server() + "plat_ms", dir_server() + "plat_ms", "MS" ) .and. ;
      r_use( dir_server() + "usl_otd", dir_server() + "usl_otd", "UO" ) .and. ;
      r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
    use_base( "kart_st" )
    use_base( "humanst" )
    Select HUMAN
    Goto ( mkod_human )
    last_date := Max( human->n_data, last_date )
    Private is_kassa := ( human->is_kas != 1 )
    Use ( cur_dir() + "tmp_usl" ) index ( cur_dir() + "tmp_usl" ) New Alias TMP
    Set Relation To otd into OTD
    Go Top
    cls
    pr_1_str( "Платные услуги для больного < " + AllTrim( glob_k_fio ) + " >" )
    SetColor( "BG/B" )
    SetColor( "BG/B" )
    l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"
    @ MaxRow() -3, 0 Say "╒═══════════════════ Полное наименование услуги ═══════════════════╤══ Цена ═══╕"
    @ MaxRow() -2, 0 Say "│                                                                  │           │"
    @ MaxRow() -1, 0 Say "╘══════════════════════════════════════════════════════════════════╧═══════════╛"
    If fl_found
      Keyboard Chr( K_RIGHT )
    Else
      Keyboard Chr( K_INS )
    Endif
    SetColor( color1 )
    mtitle := f_srok_lech( human->n_data, human->k_data )
    If !is_kassa
      @ 1, 1 Say " ЧЕК " Color "G+*/B"
    Endif
    // help_code := HST_Edit_kart
    alpha_browse( 2, 0, MaxRow() -5, 79, "STe_p_kusl", color1, mtitle, col_tit_popup, ;
      .f., .t.,, "ST1e_p_kusl", "ST2e_p_kusl",, ;
      { "═", "░", "═", l_color, .t., 180 } )
    If yes_parol .and. ( mvu[ 1, 1 ] > 0 .or. mvu[ 2, 1 ] > 0 .or. mvu[ 3, 1 ] > 0 ) ;
        .and. hb_FileExists( dir_server() + "mo_opern" + sdbf() )
      Close databases
      If g_use( dir_server() + "mo_opern", dir_server() + "mo_opern", "OP" )
        For i := 1 To 3
          If mvu[ i, 1 ] > 0
            write_work_oper( glob_task, OPER_USL, i, mvu[ i, 1 ], mvu[ i, 2 ], .f. )
          Endif
        Next
      Endif
    Endif
    Close databases
  Endif
  Close databases
  SetColor( tmp_color )
  RestScreen( buf )
  help_code := tmp_help

  Return mcena

//
Function ste_p_kusl( oBrow )

  Local oColumn, blk_color := {|| if( tmp->t_edit > 1, { 3, 4 }, { 1, 2 } ) }

  oColumn := TBColumnNew( " NN; пп", {|| Str( tmp->number, 3 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  If mem_ordusl == 1
    oColumn := TBColumnNew( "Дата;оказ.; усл.", {|| Left( DToC( tmp->date_u1 ), 5 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( "   Шифр;  услуги", {|| tmp->shifr_u } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  If mem_ordusl == 2
    oColumn := TBColumnNew( "Дата;оказ.; усл.", {|| Left( DToC( tmp->date_u1 ), 5 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( "Отде-;ление", {|| otd->short_name } )
  oColumn:defColor := { 6, 6 }
  oColumn:colorBlock := {|| { 6, 6 } }
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "МКБ10", {|| tmp->kod_diag } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Зубная формула", {|| Left( tmp->zf, 17 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Врач", {|| put_val( ret_tabn( tmp->kod_vr ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Асс.", {|| put_val( ret_tabn( tmp->kod_as ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Ко-;лич.;усл.", {|| tmp->kol } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Общая; стоимость; услуги", {|| put_kop( tmp->stoim, 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление; ^<F1>^ помощь" )

  Return Nil

//
Function st1e_p_kusl()

  Local nRow := Row(), nCol := Col()

  @ MaxRow() -2, 2 Say tmp->name_u Color cDataCSay
  @ MaxRow() -2, 68 Say iif( Empty( tmp->u_cena ), Space( 11 ), ;
    PadC( AllTrim( dellastnul( tmp->u_cena, 10, 2 ) ), 11 ) ) Color cDataCSay
  If flag_1
    st3e_p_kusl()
    flag_1 := .f.
  Endif
  @ nRow, nCol Say ""

  Return Nil

//
Function st3e_p_kusl()

  @ MaxRow() -4, 60 Say PadL( "Итого: " + lstr( mcena, 11, 2 ), 19 ) Color "W+/N"

  Return Nil

// 08.10.17
Function st2e_p_kusl( nKey, oBrow )

  Static skod_human := 0, SKOD_DIAG, SZF, st_vzrosl, st_arr_dbf
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, flag := -1, buf := SaveScreen(), fl := .f., rec, ;
    i1, k, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := SetColor(), ;
    rec_tmp := tmp->( RecNo() ), date_tmp := tmp->date_u1, pos_read := 0, k_read := 0, ;
    count_edit := 0, tmp_help := 0, uch_otd := saveuchotd(), pic_diag := "@K@!"
  Private r1 := 10   // help_code

  If eq_any( nKey, K_INS, K_ENTER, K_DEL )
    If !ver_pub_date( human->k_data, .t. )
      Return flag
    Endif
    If nKey != K_ENTER .and. !is_kassa
      func_error( 4, "По данному листу учета уже пробит чек. Операция запрещена!" )
      Return flag
    Endif
  Endif
  Do Case
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. tmp->kod > 0 )
    If skod_human != human->( RecNo() )
      skod_human := human->( RecNo() )
      SKOD_DIAG := human->KOD_DIAG
      pr1otd := human->OTD
      SZF := Space( 30 )
    Endif
    If nKey == K_INS .and. !fl_found
      ColorWin( 7, 0, 7, 79, "B/B", "W+/RB" )
    Endif
    Private motd, m1otd := iif( nKey == K_INS, iif( pr1otd == NIL, 0, pr1otd ), tmp->otd ), ;
      mrec_hu := iif( nKey == K_INS, 0, tmp->rec_hu ), ;
      mu_kod := iif( nKey == K_INS, 0, tmp->u_kod ), ;
      mdate_u1 := iif( nKey == K_INS, last_date, tmp->date_u1 ), ;
      mis_nul := iif( nKey == K_INS, .f., tmp->is_nul ), ;
      mu_cena := iif( nKey == K_INS, 0, tmp->u_cena ), ;
      mKOD_DIAG  := iif( nKey == K_INS, SKOD_DIAG, tmp->KOD_DIAG ), ;
      mold_zf := mZF := iif( nKey == K_INS, SZF, tmp->ZF ), ;
      mkod_vr := iif( nKey == K_INS, pr_kod_vr, tmp->kod_vr ), ;
      mtabn_vr := 0, mvrach := Space( 35 ), ;
      mkod_as := iif( nKey == K_INS, pr_kod_as, tmp->kod_as ), ;
      mtabn_as := 0, massist := Space( 35 ), ;
      mkol := iif( nKey == K_INS, 0, tmp->kol ), ;
      mstoim := iif( nKey == K_INS, 0, tmp->stoim ), ;
      mt_edit := iif( nKey == K_INS, 0, tmp->t_edit ), ;
      mshifr := iif( nKey == K_INS, Space( 10 ), tmp->shifr_u ), ;
      mname_u := iif( nKey == K_INS, Space( 65 ), tmp->name_u ), ;
      pmmed1 := iif( nKey == K_INS, pr_med1, tmp->med1 ), mmed1 := 0, ;
      pmmed2 := iif( nKey == K_INS, pr_med2, tmp->med2 ), mmed2 := 0, ;
      pmmed3 := iif( nKey == K_INS, pr_med3, tmp->med3 ), mmed3 := 0, ;
      pmsan1 := iif( nKey == K_INS, pr_san1, tmp->san1 ), msan1 := 0, ;
      pmsan2 := iif( nKey == K_INS, pr_san2, tmp->san2 ), msan2 := 0, ;
      pmsan3 := iif( nKey == K_INS, pr_san3, tmp->san3 ), msan3 := 0, ;
      pr_k_usl := {}, ;  // массив комплексных услуг
    gl_area := { 1, 0, 23, 79, 0 }
    motd := inieditspr( A__POPUPMENU, dir_server() + "mo_otd", m1otd )
    If mkod_vr > 0
      Select PERSO
      Goto ( mkod_vr )
      mvrach := PadR( perso->fio, 35 )
      mtabn_vr := perso->tab_nom
    Endif
    If mkod_as > 0
      Select PERSO
      Goto ( mkod_as )
      massist := PadR( perso->fio, 35 )
      mtabn_as := perso->tab_nom
    Endif
    Select MS
    If pmmed1 > 0
      Goto ( pmmed1 )
      If !Eof() .and. ms->tip == 1
        mmed1 := ms->tab_nom
      Endif
    Endif
    If pmmed2 > 0
      Goto ( pmmed2 )
      If !Eof() .and. ms->tip == 1
        mmed2 := ms->tab_nom
      Endif
    Endif
    If pmmed3 > 0
      Goto ( pmmed3 )
      If !Eof() .and. ms->tip == 1
        mmed3 := ms->tab_nom
      Endif
    Endif
    If pmsan1 > 0
      Goto ( pmsan1 )
      If !Eof() .and. ms->tip == 2
        msan1 := ms->tab_nom
      Endif
    Endif
    If pmsan2 > 0
      Goto ( pmsan2 )
      If !Eof() .and. ms->tip == 2
        msan2 := ms->tab_nom
      Endif
    Endif
    If pmsan3 > 0
      Goto ( pmsan3 )
      If !Eof() .and. ms->tip == 2
        msan3 := ms->tab_nom
      Endif
    Endif
    box_shadow( r1 -1, 0, 23, 79, color8, iif( nKey == K_INS, "Добавление новой", ;
      "Редактирование" ) + " платной услуги", "RB+/B" )
    Do While .t.
      SetColor( cDataCGet )
      If mem_kodotd == 1
        @ r1 + 1, 2 Say "Отделение, в котором оказана услуга" Get motd ;
          reader {| x| menu_reader( x, { {| k, r, c| get_otd( k, r + 1, c, .t. ) } }, A__FUNCTION,,, .f. ) }
      Else
        @ r1 + 1, 2 Say "Отделение, в котором оказана услуга" Get m1otd Pict "99" ;
          when {| g| f5e_p_kusl( g, 1, 10 ) } ;
          valid {| g| f5e_p_kusl( g, 2, 10 ) }
        @ Row(), Col() + 2 Get motd Color color14 When .f.
      Endif
      @ r1 + 2, 2 Say "Дата оказания услуги" Get mdate_u1 ;
        valid {| g| f5e_p_kusl( g, 2, 1 ) }
      @ r1 + 3, 2 Say "Диагноз по МКБ-10" ;
        Get mkod_diag  Picture pic_diag When when_diag() reader {| o| mygetreader( o, bg ) } Valid val1_10diag( .t., .f., .f., last_date, smpol )
      @ r1 + 4, 2 Say "Зубная формула" Get mzf Pict pic_diag ;
        valid {| g| f5e_p_kusl( g, 2, 101 ) }
      @ r1 + 5, 2 Say "Шифр услуги" Get mshifr Pict "@!" ;
        when {| g| f5e_p_kusl( g, 1, 2 ) } ;
        valid {| g| f5e_p_kusl( g, 2, 2 ) }
      @ Row(), 40 Say "Цена услуги" Get mu_cena Pict pict_cena() ;
        When .f. Color color14
      @ r1 + 6, 2 Say "Услуга" Get mname_u When .f. Color color14
      ix := 6
      For x := 1 To 3
        If mem_por_vr == x
          ++ix
          @ r1 + ix, 2 Say "Таб.N врача" Get mtabn_vr Pict "99999" ;
            valid {| g| f5e_p_kusl( g, 2, 3 ) }
          @ Row(), Col() + 3 Get mvrach When .f. Color color14
        Endif
        If mem_por_ass == x
          ++ix
          @ r1 + ix, 2 Say "Таб.N ассистента" Get mtabn_as Pict "99999" ;
            valid {| g| f5e_p_kusl( g, 2, 4 ) }
          @ Row(), Col() + 3 Get massist When .f. Color color14
        Endif
        If mem_por_kol == x
          ++ix
          @ r1 + ix, 2 Say "Количество услуг" Get mkol Pict "999" ;
            when {| g| is_kassa .and. f5e_p_kusl( g, 1, 5 ) } ;
            valid {| g| f5e_p_kusl( g, 2, 5 ) }
        Endif
      Next
      ++ix
      @ r1 + ix, 2 Say "Общая стоимость услуги" Get mstoim Pict pict_cena() ;
        when {| g| is_kassa .and. mem_edit_s == 2 .and. f5e_p_kusl( g, 1, 7 ) } ;
        valid {| g| f5e_p_kusl( g, 2, 7 ) }
      If mt_edit > 1
        @ r1 + ix, 37 Say "[ редактировалась стоимость услуги ]" Color color13
      Endif
      If is_oplata != 7
        ++ix
        @ r1 + ix, 2 Say "Коды медсестер" Get mmed1 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 11 ) }
        @ Row(), Col() Say "," Get mmed2 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 11 ) }
        @ Row(), Col() Say "," Get mmed3 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 11 ) }
        @ r1 + 11, 2 Say "Коды санитарок" Get msan1 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 12 ) }
        @ Row(), Col() Say "," Get msan2 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 12 ) }
        @ Row(), Col() Say "," Get msan3 Pict "99999" ;
          valid {| g| f5e_p_kusl( g, 2, 12 ) }
      Endif
      status_key( "^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи" )
      count_edit := myread(, @pos_read, ++k_read )
      SetKey( K_F2, NIL )
      SetKey( K_F3, NIL )
      If LastKey() != K_ESC
        If Empty( mdate_u1 )
          func_error( 4, "Не введена дата оказания услуги!" )
          Loop
          // elseif empty(mu_kod)
          // func_error(4,"Не введена ЗДЕСЬ услуга!")
          // loop
          // elseif !mis_nul .and. empty(mstoim)
          // func_error(4,"Не введена цена услуги!")
          // loop
        Elseif mem_vv_v_a == 1 .and. emptyall( mkod_vr, mkod_as )
          func_error( 4, "Не введены врач и ассистент!" )
          Loop
        Else
          err_date_diap( mdate_u1, "Дата оказания услуги" )
          mywait()
          Select HU
          If nKey == K_INS .and. Len( pr_k_usl ) > 0
            // комплексная услуга
            For i := 1 To Len( pr_k_usl )
              mshifr := pr_k_usl[ i, 1 ]
              mu_kod := pr_k_usl[ i, 3 ]
              mname_u := pr_k_usl[ i, 4 ]
              mu_cena := pr_k_usl[ i, 5 ]
              mt_edit := pr_k_usl[ i, 7 ]
              mis_nul := pr_k_usl[ i, 9 ]
              mstoim := round_5( mu_cena * mkol, 2 )
              Select HU
              add1rec( 7 )
              mrec_hu := hu->( RecNo() )
              fl_found := .t.
              Select TMP
              Append Blank
              rec_tmp := tmp->( RecNo() )
              ++mvu[1,1 ]  // услуга добавлена оператором
              //
              Select HU
              Replace hu->kod     With human->( RecNo() ), ;
                hu->kod_vr  With mkod_vr, ;
                hu->kod_as  With mkod_as, ;
                hu->u_koef  With 1, ;
                hu->stoim   With mstoim, ;
                hu->u_kod   With mu_kod, ;
                hu->u_cena  With mu_cena, ;
                hu->t_edit  With mt_edit, ;
                hu->kol     With mkol, ;
                hu->date_u  With dtoc4( mdate_u1 ), ;
                hu->otd     With m1otd, ;
                hu->med1    With pmmed1, ;
                hu->med2    With pmmed2, ;
                hu->med3    With pmmed3, ;
                hu->san1    With pmsan1, ;
                hu->san2    With pmsan2, ;
                hu->san3    With pmsan3
              Unlock
              pr1otd := m1otd
              adbf := Array( FCount() )
              AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
              stappend( 2, mrec_hu, human->kod_k, hu->date_u, mu_kod, mkod_vr, mzf, mkod_diag )
              Select TMP
              AEval( adbf, {| x, i| FieldPut( i, x ) } )
              tmp->date_u1 := mdate_u1
              tmp->shifr_u := mshifr
              tmp->name_u := mname_u
              tmp->is_nul := mis_nul
              tmp->rec_hu := mrec_hu
              tmp->stoim     := mstoim  // - новый
              last_date := tmp->date_u1  // - так стало
              pr_kod_vr := tmp->kod_vr
              pr_kod_as := tmp->kod_as
              pr_med1 := tmp->med1
              pr_med2 := tmp->med2
              pr_med3 := tmp->med3
              pr_san1 := tmp->san1
              pr_san2 := tmp->san2
              pr_san3 := tmp->san3
            Next
            summa_usl( @mcena )
            Select HUMAN
            g_rlock( forever )
            human->cena := mcena

          /*  for i := 1 to len(pr_k_usl)
              mshifr := pr_k_usl[i,1]
              mu_kod := pr_k_usl[i,3] //
              mname_u := pr_k_usl[i,4] //
              mu_cena := pr_k_usl[i,5] //
              mis_nul := pr_k_usl[i,9]
              mstoim := mstoim_1 := round_5(mu_cena * mkol, 2)
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

              //
              pr1otd := m1otd
              adbf := array(fcount())
              aeval(adbf, {|x,i| adbf[i] := fieldget(i) } )
              STappend(2,mrec_hu,human->kod_k,hu->date_u,mu_kod,mkod_vr,mzf,mkod_diag)
              select TMP
              tmp->KOD_DIAG  := mKOD_DIAG
              tmp->ZF        := mZF
              tmp->date_u1   := mdate_u1
              tmp->shifr_u   := mshifr
              tmp->name_u    := mname_u
              tmp->is_nul    := mis_nul
              tmp->rec_hu    := mrec_hu
              tmp->stoim     := mstoim
              tmp->u_kod     := mu_kod
              tmp->u_cena    := mu_cena
              tmp->t_edit    := mt_edit
              tmp->kol       := mkol
              tmp->date_u    := dtoc4(mdate_u1)
              tmp->otd       := m1otd
              tmp->med1      := pmmed1
              tmp->med2      := pmmed2
              tmp->med3      := pmmed3
              tmp->san1      := pmsan1
              tmp->san2      := pmsan2
              tmp->san3      := pmsan3
              tmp->kod_vr    := mkod_vr
              tmp->kod_as    := mkod_as
              tmp->stoim     := mstoim
              summa_usl(@mcena)
              select HUMAN
              G_RLock(forever)
              human->cena := mcena
            next
            */
          Else
            // запись одной введённой услуги
            If nKey == K_INS
              add1rec( 7 )
              mrec_hu := hu->( RecNo() )
              fl_found := .t.
              Select TMP
              Append Blank
              rec_tmp := tmp->( RecNo() )
              ++mvu[1,1 ]  // услуга добавлена оператором
              mvu[ 1, 2 ] += count_edit
            Else
              Goto ( mrec_hu )
              g_rlock( forever )
              Select TMP
              Goto ( rec_tmp )
              ++mvu[2,1 ]  // услуга отредактирована оператором
              mvu[ 2, 2 ] += count_edit
            Endif
            Select HU
            Replace hu->kod     With human->( RecNo() ), ;
              hu->kod_vr  With mkod_vr, ;
              hu->kod_as  With mkod_as, ;
              hu->u_koef  With 1, ;
              hu->stoim   With mstoim, ;
              hu->u_kod   With mu_kod, ;
              hu->u_cena  With mu_cena, ;
              hu->t_edit  With mt_edit, ;
              hu->kol     With mkol, ;
              hu->date_u  With dtoc4( mdate_u1 ), ;
              hu->otd     With m1otd, ;
              hu->med1    With pmmed1, ;
              hu->med2    With pmmed2, ;
              hu->med3    With pmmed3, ;
              hu->san1    With pmsan1, ;
              hu->san2    With pmsan2, ;
              hu->san3    With pmsan3
            Unlock
            pr1otd := m1otd
            adbf := Array( FCount() )
            AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
            If !Empty( mzf )
              SKOD_DIAG  := mkod_diag
              SZF        := mzf
              usl->( dbGoto( mu_kod ) )
              If usl->zf == 0 // не вводится зубная формула
                mzf := Space( 30 )  // обнуляем
              Endif
            Endif
            If ( nKey == K_INS .and. !Empty( mzf ) ) .or. !( mold_zf == mzf ) // если изменили зубную формулу
              stappend( 2, mrec_hu, human->kod_k, hu->date_u, mu_kod, mkod_vr, mzf, mkod_diag )
            Endif
            Select TMP
            AEval( adbf, {| x, i| FieldPut( i, x ) } )
            tmp->KOD_DIAG  := mKOD_DIAG
            tmp->ZF        := mZF
            tmp->date_u1 := mdate_u1
            tmp->shifr_u := mshifr
            tmp->name_u := mname_u
            tmp->is_nul := mis_nul
            tmp->rec_hu := mrec_hu
            // last_date := max(tmp->date_u1,last_date) - так было
            last_date := tmp->date_u1  // - так стало
            pr_kod_vr := tmp->kod_vr
            pr_kod_as := tmp->kod_as
            pr_med1 := tmp->med1
            pr_med2 := tmp->med2
            pr_med3 := tmp->med3
            pr_san1 := tmp->san1
            pr_san2 := tmp->san2
            pr_san3 := tmp->san3
            summa_usl( @mcena )
            Select HUMAN
            g_rlock( forever )
            human->cena := mcena
            Unlock
            Commit
          Endif
        Endif
      Endif
      Exit
    Enddo
    flag := 0
    If nKey == K_INS .and. !fl_found
      flag := 1
    Endif
    RestScreen( buf )
    st3e_p_kusl()
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
  Case nKey == K_DEL .and. tmp->kod > 0 .and. f_esc_enter( 2 )
    mywait()
    ++mvu[3,1 ]  // услуга удалена оператором
    stdelhuman( 2, tmp->rec_hu )
    stdelkart( 2, tmp->rec_hu )
    Select HU
    Goto ( tmp->rec_hu )
    deleterec( .t., .f. )  // очистка записи без пометки на удаление
    Select TMP
    deleterec( .t. )  // с пометкой на удаление
    summa_usl( @mcena )
    Select HUMAN
    g_rlock( forever )
    Replace human->cena With mcena
    Unlock
    Commit
    Select TMP
    oBrow:gotop()
    Go Top
    If Eof()
      fl_found := .f. ; Keyboard Chr( K_INS )
    Endif
    flag := 0
    RestScreen( buf )
    st3e_p_kusl()
  Otherwise
    Keyboard ""
  Endcase
  help_code := tmp_help
  restuchotd( uch_otd )

  Return flag

//

//
Static Function summa_usl( s )

  Local j := 0

  s := 0
  Select TMP
  Go Top
  Do While !Eof()
    s += tmp->stoim
    tmp->number := ++j
    Skip
  Enddo
  s := Round( s, 2 )

  Return Nil

//

// 14.02.13
Function st1_plat_fio()

  Local reg := 1
  Local vr_as, adbf, i, j, arr[ 2 ], begin_date, end_date, ;
    fl_exit := .f., sh, HH := 57, reg_print, s, xx, n, nvr, ;
    arr_otd := {}, n_file := cur_dir() + "plat_fio.txt", buf := save_maxrow()
  Private krvz, arr_dms, d_file := "PLAT_FIO" + sdbf(), otdeleni := {}

  If !del_dbf_file( d_file )
    Return Nil
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5 ) ) == NIL
    Return Nil
  Endif
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  begin_date := arr[ 7 ]
  end_date := arr[ 8 ]
  If ( krvz := fbp_tip_usl( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  mywait()
  r_use( dir_server() + "mo_uch",, "UCH" )
  r_use( dir_server() + "mo_otd",, "OTD" )
  Go Top
  Do While !Eof()
    If f_is_uch( st_a_uch, otd->kod_lpu )
      uch->( dbGoto( otd->kod_lpu ) )
      AAdd( arr_otd, { otd->( RecNo() ), otd->name, otd->kod_lpu, uch->name } )
    Endif
    Skip
  Enddo
  Close databases
  adbf := { { "kod",  "N", 7, 0 }, ;  // код л/у
    { "kod_k", "N", 7, 0 }, ;  // код по картотеке
  { "kod_p", "N", 4, 0 }, ;  // код персонала
    { "otd",  "N", 3, 0 }, ;  // код отделения
  { "summa", "N", 12, 2 }, ;  // общая сумма лечения по данному отделению
    { "sm_vozvr", "N", 12, 2 }; // общая сумма лечения по данному отделению
  }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod_k, 7 ) + Str( kod, 7 ) + Str( otd, 3 ) + Str( kod_p, 4 ) to ( cur_dir() + "tmp" )
  g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
  g_use( dir_server() + "hum_p",, "HUMAN" )
  If pi1 == 3  // по дате закрытия листа учета
    Set Index to ( dir_server() + "hum_pc" )
    For xx := 0 To 2
      If AScan( krvz, xx ) > 0
        Select HUMAN
        dbSeek( Str( xx, 1 ) + "1" + DToS( arr[ 5 ] ), .t. )
        Do While human->tip_usl == xx .and. human->date_close <= arr[ 6 ] .and. !Eof()
          updatestatus()
          If Inkey() == K_ESC
            fl_exit := .t. ; Exit
          Endif
          If iif( arr_dms == NIL, .t., AScan( arr_dms, human->pr_smo ) > 0 )
            Select HU
            find ( Str( human->( RecNo() ), 7 ) )
            Do While hu->kod == human->( RecNo() )
              If AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) > 0
                f1_plat_fio( reg, vr_as )
              Endif
              Select HU
              Skip
            Enddo
          Endif
          Select HUMAN
          Skip
        Enddo
      Endif
      If fl_exit ; exit ; Endif
    Next
  Else  // только по дате окончания лечения
    Set Index to ( dir_server() + "hum_pd" )
    dbSeek( DToS( arr[ 5 ] ), .t. )
    Do While human->k_data <= arr[ 6 ] .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If AScan( krvz, human->tip_usl ) > 0 .and. ;
          iif( arr_dms == NIL, .t., AScan( arr_dms, human->pr_smo ) > 0 )
        Select HU
        find ( Str( human->( RecNo() ), 7 ) )
        Do While hu->kod == human->( RecNo() )
          If AScan( arr_otd, {| x| hu->otd == x[ 1 ] } ) > 0
            f1_plat_fio( reg, vr_as )
          Endif
          Select HU
          Skip
        Enddo
      Endif
      Select HUMAN
      Skip
    Enddo
  Endif
  j := tmp->( LastRec() )
  Close databases
  If fl_exit ; Return NIL ; Endif
  If j == 0
    func_error( 4, "Нет сведений!" )
  Else
    mywait()
    n := 40
    arr_title := { Replicate( "─", n ), ;
      PadC( "Ф.И.О. больного", n ), ;
      PadC( "наименование услуги", n ), ;
      Replicate( "─", n ) }
    adbf := { { "fio", "C", 50, 0 } }
    If reg == 1
      arr_title[ 1 ] += "┬──────────"
      arr_title[ 2 ] += "│ Окончание"
      arr_title[ 3 ] += "│  лечения "
      arr_title[ 4 ] += "┴──────────"
      AAdd( adbf, { "k_data", "C", 10, 0 } )
    Endif
    If pi1 == 3  // по дате закрытия листа учета
      arr_title[ 1 ] += "┬──────────"
      arr_title[ 2 ] += "│   Дата   "
      arr_title[ 3 ] += "│  оплаты  "
      arr_title[ 4 ] += "┴──────────"
      AAdd( adbf, { "date_close", "C", 10, 0 } )
    Endif
    If Len( st_a_uch ) > 1
      // arr_title[1] += "┬──────────"
      // arr_title[2] += "│          "
      // arr_title[3] += "│Учреждение"
      // arr_title[4] += "┴──────────"
      AAdd( adbf, { "uch", "C", 30, 0 } )
    Endif
    // arr_title[1] += "┬─────"
    // arr_title[2] += "│Отде-"
    // arr_title[3] += "│ление"
    // arr_title[4] += "┴─────"
    AAdd( adbf, { "otd", "C", 50, 0 } )
    nvr := 20
    If reg == 2
      arr_title[ 1 ] += "┬" + Replicate( "─", nvr )
      arr_title[ 2 ] += "│" + Space( nvr )
      arr_title[ 3 ] += "│" + PadC( { "Врачи", "Ассистенты", "Медсестры", "Санитарки" }[ vr_as ], nvr )
      arr_title[ 4 ] += "┴" + Replicate( "─", nvr )
      AAdd( adbf, { "tab_nom", "N", 5, 0 } )
      AAdd( adbf, { "personal", "C", 50, 0 } )
    Endif
    arr_title[ 1 ] += "┬───────────"
    arr_title[ 2 ] += "│ Стоимость "
    arr_title[ 3 ] += "│  договора "
    arr_title[ 4 ] += "┴───────────"
    arr_title[ 1 ] += "┬───────────"
    arr_title[ 2 ] += "│ Стоимость "
    arr_title[ 3 ] += "│   услуг   "
    arr_title[ 4 ] += "┴───────────"
    AAdd( adbf, { "summa", "N", 12, 2 } )
    dbCreate( d_file, adbf )
    Use ( d_file ) New Alias DD
    reg_print := f_reg_print( arr_title, @sh )
    r_use( dir_server() + "mo_uch",, "UCH" )
    r_use( dir_server() + "mo_otd",, "OTD" )
    Set Relation To kod_lpu into UCH
    g_use( dir_server() + "kartotek",, "KART" )
    g_use( dir_server() + "uslugi",, "USL" )
    g_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HU" )
    Set Relation To u_kod into USL
    g_use( dir_server() + "hum_p",, "HUMAN" )
    Use ( cur_dir() + "tmp" ) new
    Set Relation To otd into OTD, To kod_k into KART, To kod into HUMAN
    If reg == 2
      If vr_as < 3
        r_use( dir_server() + "mo_pers",, "PERSO" )
        Set Relation To kod_p into PERSO Additive
      Else
        g_use( dir_server() + "plat_ms",, "P2" )
        Select TMP
        Set Relation To kod_p into P2 Additive
      Endif
    Endif
    Index On Upper( uch->name ) + Left( Upper( otd->name ), 20 ) + Left( Upper( kart->fio ), 20 ) + Str( kod_k, 7 ) + DToS( human->k_data ) ;
      to ( cur_dir() + "tmp" )
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( "ПЛАТНЫЕ УСЛУГИ" )
    add_string( Center( "Статистика по работе персонала", sh ) )
    titlen_uch( st_a_uch, sh )
    tit_tip_usl( krvz, arr_dms, sh )
    add_string( Center( arr[ 4 ], sh ) )
    add_string( "" )
    Do Case
    Case pi1 == 1
      s := "[ по дате лечения ]"
    Case pi1 == 2
      s := "[ по дате окончания лечения ]"
    Case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
    Endcase
    add_string( Center( s, sh ) )
    add_string( "" )
    old_kart := -999 ; old_lu := 0
    Select TMP
    Go Top
    AEval( arr_title, {| x| add_string( x ) } )
    old_otdel := otd->name
    s_otdel   := 0
    s_vozvr   := 0
    s1vozvr   := 0
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If old_otdel != otd->name
        n1 := Len( arr_title[ 1 ] )
        add_string( Replicate( "─", n1 ) )
        add_string( PadR( AllTrim( old_otdel ), n + 1 ) + "    ИТОГО:" + put_kop( s_otdel, 12 ) )
        add_string( "" )
        AAdd( otdeleni, { old_otdel, s_otdel, s_vozvr, s1vozvr } )
        old_otdel := otd->name
        s_otdel := tmp->summa
        If human->date_voz == human->pdate
          s_vozvr := human->sum_voz
          s1vozvr := 0
        Else
          s_vozvr := 0
          s1vozvr := human->sum_voz
        Endif
      Else
        s_otdel += tmp->summa
        If human->date_voz == human->pdate
          s_vozvr += human->sum_voz
        Else
          s1vozvr += human->sum_voz
        Endif
      Endif
      If old_kart == tmp->kod_k .and. old_lu == tmp->kod
        s := Space( n )
      Else
        s := PadR( kart->fio, n )
      Endif
      old_kart := tmp->kod_k
      old_lu := tmp->kod
      If reg == 1
        s += " " + full_date( human->k_data )
      Endif
      If pi1 == 3  // по дате закрытия листа учета
        s += " "
        If human->date_close > human->k_data
          s += full_date( human->date_close )
        Else
          s += PadC( "аванс", 10 )
        Endif
      Endif
      If reg == 2
        s1 := "["
        If vr_as < 3
          If mem_tabnom == 2
            s1 += lstr( tabn->tab_nom )
          Else
            s1 += lstr( tmp->kod_p )
          Endif
        Else
          s1 += lstr( p2->tab_nom )
        Endif
        s1 += "] " + fam_i_o( p2->fio )
        s += " " + PadR( s1, nvr )
      Endif
      s += put_kop( tmp->summa, 12 )
      If human->sum_voz > 0
        s += "ВОЗВРАТ"
      Endif
      add_string( s )
      Select HU
      find( Str( human->( RecNo() ), 7 ) )
      Do While human->( RecNo() ) == hu->kod .and. !Eof()
        If hu->otd == tmp->otd
          If glob_mo[ _MO_KOD_TFOMS ] == '171004' // КБ-4
            add_string( "  " + PadR( usl->full_name, 60 ) + " " + put_kop( hu->stoim, 12 ) )
          Else
            add_string( "  " + PadR( usl->name, 60 ) + " " + put_kop( hu->stoim, 12 ) )
          Endif
        Endif
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        Skip
      Enddo
      Select TMP
      Skip
    Enddo
    n1 := Len( arr_title[ 1 ] )
    add_string( Replicate( "─", n1 ) )
    add_string( PadR( AllTrim( old_otdel ), n + 1 ) + "    ИТОГО:" + put_kop( s_otdel, 12 ) )
    AAdd( otdeleni, { old_otdel, s_otdel, s_vozvr, s1vozvr } )
    add_string( "" )
    verify_ff( 2, .t., sh )
    arr_title := { ;
      "───────────────────────────────────────────┬───────────┬───────────┬───────────", ;
      "                                           │ Оплачено в│  Возврат  │   Возврат ", ;
      "                 Отделения                 │   кассу   │через кассу│ через банк", ;
      "───────────────────────────────────────────┴───────────┴───────────┴───────────" }
    sh := Len( arr_title[ 1 ] )
    add_string( Center( "Итого по отделениям" ), sh )
    add_string( "" )
    Do Case
    Case pi1 == 1
      s := "[ по дате лечения ]"
    Case pi1 == 2
      s := "[ по дате окончания лечения ]"
    Case pi1 == 3
      s := "[ по дате закрытия листа учета ]"
    Endcase
    add_string( Center( s, sh ) )
    add_string( Center( arr[ 4 ], sh ) )
    sm  := 0
    sm1 := 0
    sm2 := 0
    AEval( arr_title, {| x| add_string( x ) } )
    For i := 1 To Len( otdeleni )
      add_string( PadR( AllTrim( otdeleni[ i, 1 ] ), 44 ) + put_kope( otdeleni[ i, 2 ], 12 ) + ;
        put_kope( otdeleni[ i, 3 ], 12 ) + put_kope( otdeleni[ i, 4 ], 12 ) )
      sm += otdeleni[ i, 2 ]
      sm1 += otdeleni[ i, 3 ]
      sm2 += otdeleni[ i, 4 ]
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
    Next
    add_string( Replicate( "─", sh ) )
    add_string( PadL( "ИТОГО: ", 44 ) + put_kope( sm, 12 ) + put_kope( sm1, 12 ) + put_kope( sm2, 12 ) )
    FClose( fp )
    Close databases
    viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
    rest_box( buf )
  Endif
  rest_box( buf )

  Return Nil

//

// 05.10.17 печать счёта-фактуры
Function pl_print_faktura( ret, sk, ss )

  Local adbf := {}, ip := 0, s

  //
  Private pole := "_t->name"
  delfrfiles()
  dbCreate( fr_titl, { { "title1", "C", 100, 0 }, ;
    { "title2", "C", 100, 0 }, ;
    { "name01", "C", 200, 0 }, ;
    { "name02", "C", 200, 0 }, ;
    { "name03", "C", 200, 0 }, ;
    { "name04", "C", 200, 0 }, ;
    { "name05", "C", 200, 0 }, ;
    { "name06", "C", 200, 0 }, ;
    { "name07", "C", 200, 0 }, ;
    { "name08", "C", 200, 0 }, ;
    { "name09", "C", 200, 0 }, ;
    { "name10", "C", 200, 0 }, ;
    { "name11", "C", 200, 0 }, ;
    { "name12", "C", 200, 0 }, ;
    { "name13", "C", 200, 0 }, ;
    { "name14", "C", 200, 0 }, ;
    { "name15", "C", 200, 0 }, ;
    { "pril", "C", 200, 0 }, ;
    { "pril2", "C", 100, 0 }, ;
    { "bottom", "C", 2000, 0 }, ;
    { "stoim", "C", 15, 0 }, ;
    { "nds", "C", 15, 0 }, ;
    { "itogo", "C", 15, 0 }, ;
    { "ind_pred", "C", 80, 0 }, ;
    { "svid_vo", "C", 80, 0 }, ;
    { "fio_ruk", "C", 50, 0 }, ;
    { "fio_bux", "C", 50, 0 } } )
  For j := 1 To 13
    AAdd( adbf, { "p_" + lstr( j ), "C", 60, 0 } )
  Next
  dbCreate( fr_data, adbf )
  Use ( fr_titl ) New Alias _t
  Append Blank
  Use ( fr_data ) New Alias _d
  r_use( dir_server() + "organiz",, "ORG" )
  pok_name := pok_adres := pok_inn := ""
  s := "Оказание медицинских услуг " + arr_m[ 4 ] + " - " + lstr( sk ) + " чел."
  If tmp1->tip_usl == 1
    r_use( dir_server() + "p_d_smo",, "PK" )
  Else
    r_use( dir_server() + "p_pr_vz",, "PK" )
  Endif
  Goto ( tmp1->pr_smo )
  pok_name := AllTrim( iif( Empty( pk->fname ), pk->name, pk->fname ) )
  pok_adres := AllTrim( pk->adres )
  pok_inn := AllTrim( pk->inn )
  //
  _t->pril := "Приложение № 1" + hb_eol() + ;
    "к постановлению Правительства" + hb_eol() + ;
    "Российской Федерации" + hb_eol() + ;
    "от 26 декабря 2011 г. № 1137"
  _t->pril2 := "(в ред.Постановления Правительства РФ от 19.08.2017 №981)"
  _t->title1 := "СЧЕТ-ФАКТУРА  № " + AllTrim( ret[ 1 ] ) + " от " + date_month( ret[ 2 ], .t. )
  _t->title2 := "ИСПРАВЛЕНИЕ   № -          от -"
  ip := 1
  &( pole + StrZero( ++ip, 2 ) ) := "Продавец :  " + org->name
  &( pole + StrZero( ++ip, 2 ) ) := "Адрес :  " + org->adres
  &( pole + StrZero( ++ip, 2 ) ) := "ИНН/КПП продавца :  " + org->inn
  &( pole + StrZero( ++ip, 2 ) ) := "Грузоотправитель и его адрес :  " + AllTrim( org->name ) + ", " + org->adres
  &( pole + StrZero( ++ip, 2 ) ) := "Грузополучатель и его адрес :  " + pok_name + ", " + pok_adres
  &( pole + StrZero( ++ip, 2 ) ) := "К платежно-расчетному документу № _________ от ____________________"
  &( pole + StrZero( ++ip, 2 ) ) := "Покупатель :  " + pok_name
  &( pole + StrZero( ++ip, 2 ) ) := "Адрес :  " + pok_adres
  &( pole + StrZero( ++ip, 2 ) ) := "ИНН/КПП покупателя :  " + pok_inn
  &( pole + StrZero( ++ip, 2 ) ) := "Валюта: наименование, код :  Российский рубль, 643"
  &( pole + StrZero( ++ip, 2 ) ) := "Идентификатор государственного контракта, договора (соглашения) (при наличии):"
  Select _d
  Append Blank
  _d->p_1 := s
  _d->p_2 := "-"
  _d->p_3 := "-"
  _d->p_4 := "1"
  _d->p_5 := lstr( ss, 11, 2 )
  _d->p_6 := lstr( ss, 13, 2 )
  _d->p_7 := "без акциза"
  _d->p_8 := _d->p_9 := "без НДС"
  _d->p_10 := lstr( ss, 13, 2 )
  _d->p_11 := "643"
  _d->p_12 := "Россия"
  // _d->p_13 := mtamog
  _t->stoim := lstr( ss, 15, 2 )
  _t->nds := ""
  _t->itogo := lstr( ss, 15, 2 )
  _t->fio_ruk := AllTrim( org->ruk )
  _t->fio_bux := AllTrim( org->bux )
  Close databases
  call_fr( "mo_faktu" + sfr3() )

  Return Nil

//

// 03.04.14 печать акта выполненных работ
Function pl_print_akt( ret, sk, ss )

  Local adbf := {}, s

  //
  delfrfiles()
  dbCreate( fr_titl, { { "nomer", "C", 10, 0 }, ;
    { "data", "C", 30, 0 }, ;
    { "prod_name", "C", 150, 0 }, ;
    { "prod_adres", "C", 100, 0 }, ;
    { "prod_inn", "C", 20, 0 }, ;
    { "pok_name", "C", 150, 0 }, ;
    { "pok_adres", "C", 100, 0 }, ;
    { "pok_inn", "C", 20, 0 }, ;
    { "stoim", "C", 15, 0 }, ;
    { "sstoim", "C", 200, 0 } } )
  For j := 1 To 7
    AAdd( adbf, { "p_" + lstr( j ), "C", 60, 0 } )
  Next
  dbCreate( fr_data, adbf )
  Use ( fr_titl ) New Alias _t
  Append Blank
  Use ( fr_data ) New Alias _d
  r_use( dir_server() + "organiz",, "ORG" )
  p_name := p_adres := p_inn := ""
  s := "Оказание медицинских услуг " + arr_m[ 4 ] + " - " + lstr( sk ) + " чел."
  If tmp1->tip_usl == 1
    r_use( dir_server() + "p_d_smo",, "PK" )
  Else
    r_use( dir_server() + "p_pr_vz",, "PK" )
  Endif
  Goto ( tmp1->pr_smo )
  p_name := AllTrim( iif( Empty( pk->fname ), pk->name, pk->fname ) )
  p_adres := AllTrim( pk->adres )
  p_inn := AllTrim( pk->inn )
  //
  _t->nomer := AllTrim( ret[ 1 ] )
  _t->data := date_month( ret[ 2 ], .t. )
  _t->prod_name := org->name
  _t->prod_adres := org->adres
  _t->prod_inn := org->inn
  _t->pok_name := p_name
  _t->pok_adres := p_adres
  _t->pok_inn := p_inn
  Select _d
  Append Blank
  _d->p_1 := s
  _d->p_2 := "1"
  _d->p_3 := _d->p_4 := lstr( ss, 11, 2 )
  _d->p_5 := _d->p_6 := "-"
  _d->p_7 := lstr( ss, 13, 2 )
  _t->stoim := lstr( ss, 15, 2 )
  _t->sstoim := srub_kop( ss, .t. )
  Close databases
  call_fr( "mo_akt" + sfr3() )

  Return Nil

//

// 04.04.14
Function rees_new_vzaim( nd_faktura )

  Local buf := save_row( MaxRow() ), s, i, j, k, ss, lss, adbf, km, vrem_shifr := ""

  delfrfiles()
  mywait()
  adbf := { { "n_fakt", "C", 10, 0 }, ;
    { "d_fakt", "C", 10, 0 }, ;
    { "n_dog", "C", 30, 0 }, ;
    { "d_dog", "C", 10, 0 }, ;
    { "d_beg", "C", 40, 0 }, ;
    { "d_end", "C", 40, 0 }, ;
    { "prod_name", "C", 150, 0 }, ;
    { "pok_name", "C", 150, 0 }, ;
    { "prod1name", "C", 150, 0 }, ;
    { "pok1name", "C", 150, 0 }, ;
    { "prod2name", "C", 150, 0 }, ;
    { "pok2name", "C", 150, 0 }, ;
    { "stoim", "N", 15, 2 } }
  dbCreate( fr_titl, adbf )
  adbf := { { "nomer",   "N", 4, 0 }, ;
    { "fio",     "C", 60, 0 }, ;
    { "polis",   "C", 25, 0 }, ;
    { "n_kart",  "C", 10, 0 }, ;
    { "data",    "C", 10, 0 }, ;
    { "kod",     "C", 15, 0 }, ;
    { "name",    "C", 70, 0 }, ;
    { "ZF", "C", 30, 0 }, ;
    { "vrach",   "C", 50, 0 }, ;
    { "diagnoz", "C", 6, 0 }, ;
    { "GP_NOMER", "C", 16, 0 }, ; // № гарантийного письма по ДМС
  { "GP_DATE", "C", 10, 0 }, ; // дата гарантийного письма по ДМС
  { "cena",    "N", 10, 2 }, ;
    { "kol",     "N", 4, 0 }, ;
    { "summa",   "N", 12, 2 } }
  dbCreate( fr_data, adbf )
  Use ( fr_titl ) New Alias _t
  Append Blank
  Use ( fr_data ) New Alias _d
  //
  _t->n_fakt := nd_faktura[ 1 ]
  _t->d_fakt := full_date( nd_faktura[ 2 ] )
  r_use( dir_server() + "organiz",, "ORG" )
  _t->prod_name := AllTrim( org->name )
  _t->prod1name := "ИНН/КПП " + AllTrim( org->inn ) + "    Адрес: " + AllTrim( org->adres )
  _t->prod2name := "Банк " + AllTrim( org->bank ) + "    БИК " + AllTrim( org->smfo ) + "    Р/С " + ;
    AllTrim( org->r_schet )
  If tmp1->tip_usl == 1
    r_use( dir_server() + "p_d_smo",, "PK" )
  Else
    r_use( dir_server() + "p_pr_vz",, "PK" )
  Endif
  Goto ( tmp1->pr_smo )
  _t->pok_name := AllTrim( iif( Empty( pk->fname ), pk->name, pk->fname ) )
  _t->n_dog := pk->n_dog
  _t->d_dog := full_date( pk->d_dog )
  _t->d_beg := date_month( arr_m[ 5 ] )
  _t->d_end := date_month( arr_m[ 6 ] )
  _t->pok1name := "ИНН/КПП " + AllTrim( pk->inn ) + "    Адрес: " + AllTrim( pk->adres )
  _t->pok2name := "Банк " + AllTrim( pk->bank ) + "    БИК " + AllTrim( pk->smfo ) + "    Р/С " + ;
    AllTrim( pk->r_schet )
  use_base( "humanst" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "mo_pers",, "perso" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HPU" )
  r_use( dir_server() + "hum_p",, "HP" )
  j := ss := 0
  Select TMP
  Go Top
  Do While !Eof()
    Select TMP2
    find ( Str( tmp->( RecNo() ), 6 ) )
    Do While tmp2->rec_tmp == tmp->( RecNo() ) .and. !Eof()
      Select HP
      Goto ( tmp2->rec_hp )
      //
      adiag := {}
      add_diagnoz( adiag ) ; ASort( adiag )
      //
      agp := {}
      If !emptyall( hp->GP_NOMER, hp->GP_DATE )
        AAdd( agp, { hp->GP_NOMER, hp->GP_DATE } )
      Endif
      If !emptyall( hp->GP2NOMER, hp->GP2DATE )
        AAdd( agp, { hp->GP2NOMER, hp->GP2DATE } )
      Endif
      //
      ausl := {}
      Select HPU
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While hpu->kod == hp->( RecNo() ) .and. !Eof()
        vrem_shifr := ""
        vrem_shifr1 := ""
        usl->( dbGoto( hpu->u_kod ) )
        perso->( dbGoto( hpu->kod_vr ) )
        Select HUMANST
        find ( Str( 2, 1 ) + Str( hpu->( RecNo() ), 8 ) )
        If mem_dms == 0 // внутренние шифры
          AAdd( ausl, { c4tod( hpu->date_u ), ;
            usl->shifr, ;
            usl->name, ;
            hpu->kol, ;
            hpu->stoim, ;
            iif( humanst->( Found() ), humanst->ZF, "" ), ;
            iif( hpu->kod_vr > 0, fam_i_o( perso->fio ), "" );
            } )
        Else
          vrem_shifr := BeforAtNum( " ", usl->full_name, 1 )
          vrem_shifr1 := SubStr( usl->full_name, Len( vrem_shifr ) )
          AAdd( ausl, { c4tod( hpu->date_u ), ;
            vrem_shifr, ;
            vrem_shifr1, ;
            hpu->kol, ;
            hpu->stoim, ;
            iif( humanst->( Found() ), humanst->ZF, "" ), ;
            iif( hpu->kod_vr > 0, fam_i_o( perso->fio ), "" );
            } )
        Endif
        Select HPU
        Skip
      Enddo
      If Max( Len( ausl ), Len( adiag ), Len( agp ) ) == 0
        AAdd( adiag, "" )
      Endif
      ASort( ausl,,, {| x, y| iif( x[ 1 ] == y[ 1 ], fsort_usl( x[ 2 ] ) < fsort_usl( y[ 2 ] ), x[ 1 ] < y[ 1 ] ) } )
      ++j ; lss := 0
      km := Max( Len( ausl ), Len( adiag ), Len( agp ) )
      For i := 1 To km
        Select _D
        Append Blank
        If i == 1
          _d->nomer := j
          _d->fio   := AllTrim( kart->fio ) + hb_eol()
          _d->polis := AllTrim( hp->d_polis ) + hb_eol()
          _d->n_kart := amb_kartan()
        Endif
        If i <= Len( ausl )
          _d->data  := full_date( ausl[ i, 1 ] )
          _d->kod   := ausl[ i, 2 ]
          _d->name  := AllTrim( ausl[ i, 3 ] ) + hb_eol()
          _d->cena  := iif( ausl[ i, 4 ] > 0, ausl[ i, 5 ] / ausl[ i, 4 ], ausl[ i, 5 ] )
          _d->kol   := ausl[ i, 4 ]
          _d->summa := ausl[ i, 5 ]
          _d->zf    := AllTrim( ausl[ i, 6 ] ) + hb_eol()
          _d->vrach := ausl[ i, 7 ]
          lss += ausl[ i, 5 ]
        Endif
        If i <= Len( adiag )
          _d->diagnoz := adiag[ i ]
        Endif
        If i <= Len( agp )
          _d->GP_NOMER := AllTrim( agp[ i, 1 ] ) + hb_eol()
          _d->GP_DATE  := full_date( agp[ i, 2 ] )
        Endif
      Next
      Select _D
      Append Blank
      _d->fio := "Итого по пациенту:"
      _d->summa := lss
      ss += lss
      Select TMP2
      Skip
    Enddo
    Select TMP
    Skip
  Enddo
  _t->stoim := ss
  Close databases
  rest_box( buf )
  message_fr_excel()
  call_fr( "mo_reesdms" + sfr3() )

  Return Nil

// 13.04.14
Function message_fr_excel()

  Local n := 0, arr := { ;
    "Для экспорта документа в Excel выполните следующие действия:", ;
    '- выберите четвёртую слева пиктограмму "Экспорт"', ;
    '- в выпадающем меню "Экспорт" выберите "Документ Excel (OLE)"', ;
    '- в разделе "Опции" окна настройки экспорта в Excel:', ;
    '-- отметьте поля "Неразрывный" и "Открыть Excel после экспорта"', ;
    '-- снимите отметку с поля "Разрывы страниц"' }

  AEval( arr, {| x| n := Max( n, Len( x ) ) } )
  AEval( arr, {| x, i| arr[ i ] := PadR( x, n, Chr( 255 ) ) } )
  n_message( arr, ;
    { "", "Нажмите любую клавишу для вывода документа в FastReport" }, ;
    color1, ;  // строка цвета для рамки
  cDataCSay, ;  // строка цвета для текста
    , ;  // верхний ряд рамки (99 - центировать)
  , ;  // левая колонка рамки (99 - центрировать)
    color8 )   // строка цвета для бегущей строки

  Return Nil


//

// 04.10.19
Function rees_new_vzaim_pol3( nd_faktura )

  Local buf := save_row( MaxRow() ), s, i, j, k, ss, lss, adbf, km

  delfrfiles()
  mywait()
  adbf := { { "n_fakt", "C", 10, 0 }, ;
    { "d_fakt", "C", 10, 0 }, ;
    { "n_dog", "C", 30, 0 }, ;
    { "d_dog", "C", 10, 0 }, ;
    { "d_beg", "C", 40, 0 }, ;
    { "d_end", "C", 40, 0 }, ;
    { "prod_name", "C", 150, 0 }, ;
    { "pok_name", "C", 150, 0 }, ;
    { "prod1name", "C", 150, 0 }, ;
    { "pok1name", "C", 150, 0 }, ;
    { "prod2name", "C", 150, 0 }, ;
    { "pok2name", "C", 150, 0 }, ;
    { "stoim", "N", 15, 2 } }
  dbCreate( fr_titl, adbf )
  adbf := { { "nomer",   "N", 4, 0 }, ;
    { "fio",     "C", 60, 0 }, ;
    { "pol",     "C", 1, 0 }, ;
    { "adres",   "C", 60, 0 }, ;
    { "date_r",  "C", 10, 0 }, ;
    { "data",    "C", 10, 0 }, ;
    { "kod",     "C", 10, 0 }, ;
    { "name",    "C", 70, 0 }, ;
    { "cena",    "N", 10, 2 }, ;
    { "kol",     "N", 4, 0 }, ;
    { "summa",   "N", 12, 2 } }
  dbCreate( fr_data, adbf )
  Use ( fr_titl ) New Alias _t
  Append Blank
  Use ( fr_data ) New Alias _d
  //
  // _t->n_fakt := nd_faktura[1]
  // _t->d_fakt := full_date(nd_faktura[2])
  r_use( dir_server() + "organiz",, "ORG" )
  _t->prod_name := AllTrim( org->name )
  _t->prod1name := "ИНН/КПП " + AllTrim( org->inn ) + "    Адрес: " + AllTrim( org->adres )
  _t->prod2name := "Банк " + AllTrim( org->bank ) + "    БИК " + AllTrim( org->smfo ) + "    Р/С " + ;
    AllTrim( org->r_schet )
  If tmp1->tip_usl == 1
    r_use( dir_server() + "p_d_smo",, "PK" )
  Else
    r_use( dir_server() + "p_pr_vz",, "PK" )
  Endif
  Goto ( tmp1->pr_smo )
  _t->pok_name := AllTrim( iif( Empty( pk->fname ), pk->name, pk->fname ) )
  _t->n_dog := pk->n_dog
  _t->d_dog := full_date( pk->d_dog )
  _t->d_beg := date_month( arr_m[ 5 ] )
  _t->d_end := date_month( arr_m[ 6 ] )
  _t->pok1name := "ИНН/КПП " + AllTrim( pk->inn ) + "    Адрес: " + AllTrim( pk->adres )
  _t->pok2name := "Банк " + AllTrim( pk->bank ) + "    БИК " + AllTrim( pk->smfo ) + "    Р/С " + ;
    AllTrim( pk->r_schet )
  use_base( "humanst" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "mo_pers",, "perso" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HPU" )
  r_use( dir_server() + "hum_p",, "HP" )
  j := ss := 0
  Select TMP
  Go Top
  Do While !Eof()
    Select TMP2
    find ( Str( tmp->( RecNo() ), 6 ) )
    Do While tmp2->rec_tmp == tmp->( RecNo() ) .and. !Eof()
      Select HP
      Goto ( tmp2->rec_hp )
      //
      adiag := {}
      add_diagnoz( adiag ) ; ASort( adiag )
      //
      agp := {}
      If !emptyall( hp->GP_NOMER, hp->GP_DATE )
        AAdd( agp, { hp->GP_NOMER, hp->GP_DATE } )
      Endif
      If !emptyall( hp->GP2NOMER, hp->GP2DATE )
        AAdd( agp, { hp->GP2NOMER, hp->GP2DATE } )
      Endif
      //
      ausl := {}
      Select HPU
      find ( Str( hp->( RecNo() ), 7 ) )
      Do While hpu->kod == hp->( RecNo() ) .and. !Eof()
        usl->( dbGoto( hpu->u_kod ) )
        perso->( dbGoto( hpu->kod_vr ) )
        Select HUMANST
        find ( Str( 2, 1 ) + Str( hpu->( RecNo() ), 8 ) )
        AAdd( ausl, { c4tod( hpu->date_u ), ;
          usl->shifr, ;
          usl->name, ;
          hpu->kol, ;
          hpu->stoim;
          } )
        Select HPU
        Skip
      Enddo
      If Max( Len( ausl ), Len( adiag ), Len( agp ) ) == 0
        AAdd( adiag, "" )
      Endif
      ASort( ausl,,, {| x, y| iif( x[ 1 ] == y[ 1 ], fsort_usl( x[ 2 ] ) < fsort_usl( y[ 2 ] ), x[ 1 ] < y[ 1 ] ) } )
      ++j ; lss := 0
      km := Max( Len( ausl ), Len( adiag ), Len( agp ) )
      For i := 1 To km
        Select _D
        Append Blank
        If i == 1
          _d->nomer  := j
          _d->fio    := AllTrim( kart->fio ) + hb_eol()
          _d->pol    := AllTrim( kart->pol )
          _d->adres  := AllTrim( kart->adres )
          _d->date_r := full_date( kart->date_r )
          // _d->n_kart := amb_kartaN()
        Endif
        If i <= Len( ausl )
          _d->data  := full_date( ausl[ i, 1 ] )
          _d->kod   := ausl[ i, 2 ]
          _d->name  := AllTrim( ausl[ i, 3 ] ) + hb_eol()
          _d->summa := ausl[ i, 5 ]
          lss += ausl[ i, 5 ]
        Endif
      Next
      // select _D
      // append blank
      // _d->fio := "Итого по пациенту:"
      // _d->summa := lss
      ss += lss
      Select TMP2
      Skip
    Enddo
    Select TMP
    Skip
  Enddo
  _t->stoim := ss
  Close databases
  rest_box( buf )
  message_fr_excel()
  call_fr( "mo_reesdmsP3" + sfr3() )

  Return Nil


//

// 23.06.19
Function pl_vozvrat()

  Local fl := .t., buf := save_row( MaxRow() ), sm := 0, HH := 52, ;
    n_file := cur_dir() + "platn.txt", arr_m, sh, sm_sn := 0, krvz, arr_dms, ;
    sm_usl := 0
  Local arr_title := { ;
    "───────────────────────────────────────────────────┬────────┬───────────", ;
    "                  Услуги                           │ Кол-во │   Сумма   ", ;
    "───────────────────────────────────────────────────┴────────┴───────────";
    }

  sh := Len( arr_title[ 1 ] )
  If ( krvz := fbp_tip_usl( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  //
  mywait()
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( Center( "ВОЗВРАТ оплаты услуг", sh ) )
  add_string( Center( "(по дате возврата)", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  tit_tip_usl( krvz, arr_dms, sh )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  //
  r_use( dir_server() + "mo_pers",, "P2" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_p_U", dir_server() + "hum_p_U", "HUM_U" )
  r_use( dir_server() + "hum_p",, "HUM" )
  Index On date_voz + FR_zavod  to ( cur_dir() + "tmp_uu" ) For sum_voz > 0
  // human->date_voz with dtoc4(date()), human->sum_voz with p_summa
  Go Top
  Do While !Eof()
    If Between( hum->date_voz, arr_m[ 7 ], arr_m[ 8 ] ) .and. ;
        AScan( krvz, hum->tip_usl ) > 0
      // .and. hum->SUM_VOZ > 0
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      Select KART
      Goto ( hum->kod_k )
      add_string( "--" + hum->FR_zavod )
      add_string( PadR( "--" + AllTrim( kart->fio ) + "  ВОЗВРАТ", 59 ) + put_kope( hum->SUM_VOZ, 12 ) )
      sm_sn += hum->SUM_VOZ
      t := hum->( RecNo() )
      Select HUM_U
      find ( Str( t, 7 ) )
      sum_sl := 0
      Do While t == hum_u->kod .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        Select USL
        Goto ( hum_u->u_kod )
        add_string( usl->shifr + PadR( iif( !Empty( usl->full_name ), usl->full_name, usl->name ), 40 ) + ;
          Str( hum_u->kol, 9 ) + ;
          put_kope( hum_u->stoim, 12 ) )
        Select P2
        Goto ( hum_u->kod_vr )
        add_string( PadR( p2->fio, 50 ) )
        sum_sl += hum_u->stoim
        sm_usl += hum_u->stoim
        Select HUM_U
        Skip
      Enddo
      add_string( PadR( "     Итого оплата", 59 ) + put_kope( sum_sl, 12 ) )
      add_string( "" )
    Endif
    Select HUM
    Skip
  Enddo
  add_string( Replicate( "─", sh ) )
  add_string( PadR( "ИТОГО возврат: ", 59 ) + put_kope( sm_sn, 12 ) )
  add_string( PadR( "ИТОГО сумма услуг: ", 59 ) + put_kope( sm_usl, 12 ) )
  Close databases
  FClose( fp )
  viewtext( n_file,,,, ( sh > 80 ),,, 1 )
  rest_box( buf )

  Return Nil

//


// 03.09.23
Function pl_priemshk()

  Local fl := .t., buf := save_row( MaxRow() ), sm2 := 0, HH := 52, ;
    n_file := cur_dir() + "platn.txt", arr_m, sh, krvz, arr_dms, ;
    mas_op1 := {}, mas_op2 := {}, mas_op3 := {}, i, arr[ 2 ], sm_bn := 0, ;
    t_hum_rec, kart_kod, t_k_data, nom_prihod := 0, sm_n := 0

  Local arr_title := { ;
    "───┬──────────────────────────────────────┬──────┬─────┬──────┬──────────┬────────────────────", ;
    " N │           Ф.И.О. пациента            │Время │ Чек │Код П │  Сумма   │        Врач        ", ;
    "───┴──────────────────────────────────────┴──────┴─────┴──────┴──────────┴────────────────────" }

  If glob_mo[ _MO_KOD_TFOMS ] == '171004' .or. glob_mo[ _MO_KOD_TFOMS ] == '114504' // КБ-4  и КП 4
    arr_title := { ;
      "───┬──────────────────────────────────────┬──────┬─────┬──────────┬──────────┬──────────────────", ;
      " N │           Ф.И.О. пациента            │Время │ Чек │  Договор │  Сумма   │       Врач       ", ;
      "───┴──────────────────────────────────────┴──────┴─────┴──────────┴──────────┴──────────────────" }
  Endif

  sh := Len( arr_title[ 1 ] )
  If ( krvz := fbp_tip_usl( T_ROW, T_COL -5, @arr_dms ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If !myfiledeleted( cur_dir() + "tmp" + sdbf() )
    Return Nil
  Endif
  //
  mywait()
  dbCreate( cur_dir() + "tmp", { { "kod",     "N",  4,  0 }, ;
    { "fio",     "C", 60,  0 }, ;
    { "chek",    "N", 10,  0 }, ;
    { "kod_hum", "N", 10,  0 }, ;
    { "dogovor", "C", 10,  0 }, ;
    { "operat",  "N", 10,  0 }, ;
    { "operatf", "C", 40,  0 }, ;
    { "operatd", "C", 40,  0 }, ;
    { "fr_data", "D",  8,  0 }, ;
    { "fr_time", "N",  5,  0 }, ;
    { "t_flag",  "N",  1,  0 }, ;
    { "summa",   "N", 12,  2 }, ;
    { "kod_vr",  "N",  4,  0 }, ;
    { "fio_vr",  "C", 60,  0 }, ;
    { "summa_bn", "N", 12,  2 }, ;
    { "summa_n", "N", 12,  2 } } )
  Use ( cur_dir() + "tmp" ) new
  If yes_parol
    r_use( dir_server() + "base1",, "BASE1" )
  Endif
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "mo_pers",, "PERS" )
  r_use( dir_server() + "hum_p_u", dir_server() + "hum_p_u", "HUM_U" )
  r_use( dir_server() + "hum_p", dir_server() + "hum_pkk", "HUM" )
  Index On fr_data to ( cur_dir() + "tmp_uu" ) For !Empty( fr_data )
  // index on str(kod_k,7)+dtos(k_data)+str(KV_CIA,6) to (dir_server()+"hum_pkk") descending progress
  // go top
  dbSeek( arr_m[ 7 ], .t. )
  Do While hum->fr_data <= arr_m[ 8 ] .and. !Eof()
    If ( hum->kod_oper == Asc( kod_polzovat ) .or. currentuser():isadmin() .or. currentuser():iskontroler() ) .and. ;
        AScan( krvz, hum->tip_usl ) > 0
      Select KART
      Goto ( hum->kod_k )
      Select TMP
      Append Blank
      tmp->fio      := kart->fio
      tmp->chek     := hum->kv_cia
      tmp->kod_hum  := hum->kod_k
      tmp->fr_data  := c4tod( hum->fr_data )
      tmp->fr_time  := hum->fr_time
      tmp->summa    := hum->cena
      tmp->summa_bn := hum->sbank
      tmp->summa_n  := hum->cena - hum->sbank
      tmp->operat   := hum->kod_oper
      tmp->dogovor  := lstr( hum->kod_k )
      If glob_mo[ _MO_KOD_TFOMS ] == '171004' // КБ-4
        nom_prihod := 0
        t_hum_rec := hum->( RecNo() )
        kart_kod := hum->kod_k
        t_k_data := Year( hum->k_data )
        Select HUM
        Do While hum->kod_k == kart_kod .and. Year( hum->k_data ) == t_k_data .and. !Eof()
          ++nom_prihod
          Skip
        Enddo
        Goto ( t_hum_rec )
        tmp->dogovor  := lstr( hum->kod_k ) + "/" + lstr( nom_prihod )
      Endif
      //
      If glob_mo[ _MO_KOD_TFOMS ] == '114504' // КП 4
        nom_prihod := 0
        t_hum_rec := hum->( RecNo() )
        kart_kod := hum->kod_k
        t_k_data := Year( hum->k_data )
        Select HUM
        Do While hum->kod_k == kart_kod .and. Year( hum->k_data ) == t_k_data .and. !Eof()
          ++nom_prihod
          Skip
        Enddo
        Goto ( t_hum_rec )
        tmp->dogovor  := lstr( kart->uchast ) + "/" + lstr( kart->kod_vu ) + "/" + lstr( nom_prihod )
      Endif
      //
      If c4tod( hum->fr_data ) != hum->n_data .or. ;
          c4tod( hum->fr_data ) != hum->k_data
        tmp->t_flag := 1
      Else
        tmp->t_flag := 0
      Endif
      If yes_parol .and. hum->KOD_OPER > 0
        Select BASE1
        Goto ( hum->KOD_OPER )
        If !Eof() .and. !Empty( base1->p1 )
          tmp->operatf := AllTrim( Crypt( base1->p1, gpasskod ) )
          tmp->operatd := AllTrim( Crypt( base1->p5, gpasskod ) )
        Endif
      Endif
      Select HUM_U
      find ( Str( hum->( RecNo() ), 7 ) )
      If Found()
        Select PERS
        Goto ( hum_u->kod_vr )
        tmp->fio_vr  := pers->fio
      Endif
    Endif
    Select HUM
    Skip
  Enddo
  Close databases
  Use ( cur_dir() + "tmp" ) new
  Index On operat to ( cur_dir() + "tmp_u" ) unique
  Go Top
  Do While !Eof()
    AAdd( mas_op1, tmp->operat )
    AAdd( mas_op2, tmp->operatf )
    AAdd( mas_op3, tmp->operatd )
    Skip
  Enddo
  Close databases
  rest_box( buf )
  // запрос по операторам
  If Len( mas_op1 ) == 0
    bkol_oper := 0
    func_error( 4, "Нет информации " + arr_m[ 4 ] )
  Elseif Len( mas_op1 ) == 1
    bkol_oper := 1
  Else
    bkol_oper := popup_prompt( T_ROW, T_COL + 5, 1, mas_op2 )
  Endif
  If bkol_oper > 0
    fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( Center( "Р Е Е С Т Р", sh ) )
    add_string( Center( "регистрации чеков на оплату оказанных медицинских платных услуг населению", sh ) )
    r_use( dir_server() + "organiz",, "ORG" )
    For i := 1 To perenos( arr, AllTrim( org->name ), sh )
      add_string( Center( AllTrim( arr[ i ] ), sh ) )
    Next
    add_string( Center( arr_m[ 4 ], sh ) )
    tit_tip_usl( krvz, arr_dms, sh )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    sm2 := ii := 0
    Use ( cur_dir() + "tmp" ) new
    Index On fr_time to ( cur_dir() + "tmp_u" ) For operat == mas_op1[ bkol_oper ]
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If glob_mo[ _MO_KOD_TFOMS ] == '171004' .or. glob_mo[ _MO_KOD_TFOMS ] == '114504' // КБ-4   КП 4
        add_string( Str( ++ii, 3 ) + " " + ;
          PadR( tmp->fio, 38 ) + ;
          iif( tmp->summa_bn > 0, "БН", "  " ) + ;
          PadR( SecToTime( tmp->fr_time ), 5 ) + " " + ;
          PadL( lstr( tmp->chek ), 5 ) + " " + ;
          PadR( tmp->dogovor, 10 ) + " " + ;
          iif( tmp->summa_bn > 0, put_kope( tmp->summa_bn, 10 ), put_kope( tmp->summa, 10 ) ) + " " + ;
          PadR( fam_i_o( tmp->fio_vr ), 18 ) + ;
          iif( tmp->t_flag == 1, "*", " " ) )
        If tmp->summa > tmp->summa_bn .and. tmp->summa_bn > 0
          add_string( Str( ++ii, 3 ) + " " + ;
            PadR( tmp->fio, 38 ) + "  " + ;
            PadR( SecToTime( tmp->fr_time ), 5 ) + " " + ;
            PadL( lstr( tmp->chek ), 5 ) + " " + ;
            PadR( tmp->dogovor, 10 ) + " " + ;
            put_kope( tmp->summa - tmp->summa_bn, 10 ) + " " + ;
            PadR( fam_i_o( tmp->fio_vr ), 18 ) + ;
            iif( tmp->t_flag == 1, "*", " " ) )
        Endif
      Else
        add_string( Str( ++ii, 3 ) + " " + ;
          PadR( tmp->fio, 38 ) + ;
          iif( tmp->summa_bn > 0, "БН", "  " ) + ;
          PadR( SecToTime( tmp->fr_time ), 5 ) + " " + ;
          PadL( lstr( tmp->chek ), 5 ) + " " + ;
          PadL( lstr( tmp->kod_hum ), 6 ) + " " + ;
          iif( tmp->summa_bn > 0, put_kope( tmp->summa_bn, 10 ), put_kope( tmp->summa, 10 ) ) + " " + ;
          PadR( fam_i_o( tmp->fio_vr ), 20 ) + ;
          iif( tmp->t_flag == 1, "*", " " ) )
        If tmp->summa > tmp->summa_bn .and. tmp->summa_bn > 0
          add_string( Str( ++ii, 3 ) + " " + ;
            PadR( tmp->fio, 38 ) + "  " + ;
            PadR( SecToTime( tmp->fr_time ), 5 ) + " " + ;
            PadL( lstr( tmp->chek ), 5 ) + " " + ;
            PadL( lstr( tmp->kod_hum ), 6 ) + " " + ;
            put_kope( tmp->summa - tmp->summa_bn, 10 ) + " " + ;
            PadR( fam_i_o( tmp->fio_vr ), 20 ) + ;
            iif( tmp->t_flag == 1, "*", " " ) )
        Endif
      Endif
      sm2   := sm2 + tmp->summa
      sm_bn := sm_bn + tmp->summa_bn
      sm_n  := sm_n + tmp->summa_n
      Skip
    Enddo
    add_string( Replicate( "─", sh ) )
    If glob_mo[ _MO_KOD_TFOMS ] == '171004' .or. glob_mo[ _MO_KOD_TFOMS ] == '114504' // КБ-4
      add_string( PadR( "Итого: ", 65 ) + put_kope( sm2, 12 ) )
    Else
      add_string( PadR( "Итого: ", 61 ) + put_kope( sm2, 12 ) )
    Endif
    add_string( Replicate( "─", sh ) )
    For i := 1 To perenos( arr, "Всего на сумму: " + srub_kop( sm2, .t. ), sh )
      add_string( arr[ i ] )
    Next
    If meK_bank == 1
      If glob_mo[ _MO_KOD_TFOMS ] == '103001'
        For i := 1 To perenos( arr, "из них в кассу: " + srub_kop( sm_n, .t. ), sh )
          add_string( arr[ i ] )
        Next
      Else
        For i := 1 To perenos( arr, "из них в кассу: " + srub_kop( sm2 - sm_bn, .t. ), sh )
          add_string( arr[ i ] )
        Next
      Endif
    Endif
    add_string( "" )
    add_string( "            Сдал " + PadR( AllTrim( mas_op3[ bkol_oper ] ) + ":", 21 ) + "                    /" + AllTrim( mas_op2[ bkol_oper ] ) + "/" )
    add_string( "" )
    add_string( "            Принял кассир:                                /" + AllTrim( mek_kassir ) + "/" )
    FClose( fp )
    Close databases
    viewtext( n_file,,,, ( sh > 80 ),,, 3 )
  Endif

  Return Nil

//
Function f2_inf_fr()

  Local j := 0, s, buf := save_row( MaxRow() ), n_file := cur_dir() + "_kassa1.txt", sh := 65, ;
    HH := 60
  Local arr_title := { ;
    "─" }

  mywait()
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0

  add_string( PadC( "Список больных без чеков", sh ) )
  add_string( PadC( "по состоянию на " + date_month( sys_date, .t. ), sh ) )
  add_string( "" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "hum_p",, "HUMAN" )
  Index On DToS( k_data ) to ( cur_dir() + "tmp" ) For is_kas == 2 progress
  Go Top
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    kart->( dbGoto( human->kod_k ) )
    add_string( Str( ++j, 4 ) + ". " + kart->fio + " " + DToC( human->k_data ) )
    Select HUMAN
    Skip
  Enddo
  FClose( fp )
  Close databases
  rest_box( buf )
  If j == 0
    func_error( 4, "Не обнаружено больных без чеков" )
  Else
    viewtext( n_file,,,, ( sh > 80 ),,, 2 )
  Endif

  Return Nil

// вызывается в "Платные услуги/Информация/Работа с кассой"
Function inf_fr( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "Информация по ~кассе", ;
      "Больные без ~ЧЕКОВ", ;
      "Реестр", ;
      "Возвраты" }
    mas_msg := { "Получение информации по состоянию кассового аппарата", ;
      "Поиск больных, у которых введены услуги, но не пробит ЧЕК", ;
      "Реестр кассира", ;
      "Информация по возвратам" }
    mas_fun := { "inf_fr(11)", ;
      "inf_fr(12)", ;
      "inf_fr(13)", ;
      "inf_fr(14)" }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    f1_inf_fr( 1 )
  Case k == 12
    f2_inf_fr()
  Case k == 13
    pl_priemshk()
  Case k == 14
    pl_vozvrat()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil
