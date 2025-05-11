#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 09.12.18 инициализировать все mem (public) - переменные
Function init_all_mem_public()

  // настраиваемые из всех задач
  Public mem_smp_input := 0
  Public mem_smp_tel := 0
  Public mem_dom_aktiv := 0
  Public mem_beg_rees := 1
  Public mem_end_rees := 999999
  Public mem_bnn_rees := 1
  Public mem_enn_rees := 99
  Public mem_bnn13rees := -1
  Public mem_enn13rees := -1
  Public okato_umolch := "18401395000"
  Public public_date := CToD( "" ) // датa, по которую (включительно) запрещено редактировать данные
  Public mem_kart_error := 0  // 1 - разрешать администратору устанавливать статус амбулаторной карты
  Public mem_kodkrt  := 1     // 2 - если есть регистратура???
  Public mem_trudoem := 1
  Public mem_tr_plan := 2     // да
  Public mem_sound   := 2     // да
  Public mem_pol     := 1
  Public mem_diag4   := 2     // да
  Public mem_diagno  := 2     // да
  Public mem_kodotd  := 1
  Public mem_otdusl  := 1
  Public mem_ordusl  := 1
  Public mem_ordu_1  := 2     // да
  Public mem_kat_va  := 2     // да
  Public mem_vv_v_a  := 2
  Public mem_por_vr  := 1
  Public mem_por_ass := 2
  Public mem_por_kol := 3
  Public mem_date_1  := CToD( "" )
  Public mem_date_2  := CToD( "" )
  Public yes_many_uch := .f.  // выбор отделения только из "своего" учреждения
  Public mem_ff_lu := 1
  // Приёмный покой
  Public pp_NOVOR     := 1  // вводить новорожденного
  Public pp_KEM_NAPR  := "" // список наиболее часто встречающихся направляющих ЛПУ
  Public pp_POB_D_LEK := 1  // вводить побочное действие лекарств
  Public pp_KOD_VR    := 1  // вводить кода врача приёмного отделения
  Public pp_TRAVMA    := 1  // вводить вид травмы
  Public pp_NE_ZAK    := 1  // запрет ввода, если еще не закончил лечение по предыдущему случаю
  // ОМС
  Public mem_KEM_NAPR := "" // список наиболее часто встречающихся направляющих ЛПУ
  Public mem_edit_ist := 2
  Public mem_e_istbol := 1
  Public mem_op_out  := 1    // нет
  Public mem_st_kat  := 1
  Public mem_st_pov  := 1
  Public mem_st_trav := 1
  Public mem_zav_l   := 3     // запоминать предыдущий
  Public mem_pom_va   := 1    // нет
  Public mem_coplec   := 1    // нет
  Public mem_dni_vr  := 365  // для совместимости - не храним
  Public is_uchastok := 0
  Public is_oplata := 5       // способ оплаты
  Public yes_h_otd := 1
  Public yes_vypisan := B_STANDART // или B_END  при работе с "Завершением лечения"
  Public yes_num_lu := 0      // =1 - номер л/у равен номеру записи
  Public yes_d_plus := "+-"   // по умолчанию после диагноза
  Public yes_bukva := .f.     // если разрешается ввод букв
  Public is_zf_stomat := 0    // зубная формула = нет
  Public mem_ls_parakl := 0   // Включать ПАРАКЛИНИКУ в сумму ЛИЧНОГО СЧЁТА
  Public is_0_schet := 0
  Public pp_OMS := .t.    // записываем из приёмного покоя л/у в задачу ОМС
  Public pp_date_OMS      // с какой даты
  Public mem_n_V034 := 0  // вид справочника V034
  Public mem_methodinj := 0  // вид справочника ПУТИ ВВЕДЕНИЯ
  // для задачи "Платные услуги" и "ЛПУ-Касса"
  Public delta_chek := 0  // перечитать из "lpu.ini"-файла
  // для задачи "Платные услуги"
  Public mem_anonim := 0  // работать с анонимами
  Public glob_pl_reg := 0 // нет квит.книжки, 1 - есть
  Public glob_close := 0  // закрытие л/учета: платные и в/зачет вручную, ДМС по оплате
  Public glob_kassa := 0  // нет кассового аппарата, 1 - кассовый аппарат: Штрих-ФР-Ф
  Public mem_naprvr  := 2  // для платных услуг
  Public mem_plsoput := 1  // для платных услуг
  Public mem_dogovor := "_DOGOVOR.SHB"  // для платных услуг
  Public mem_pl_ms   := 0  // для платных услуг
  Public mem_pl_sn   := 0  // для платных услуг
  Public mem_dms     := 0  // для платных услуг
  Public mem_edit_s  := 2
  // для задачи "Ортопедия"
  Public mem_ort_na  := Space( 10 ) // ортопедия
  Public mem_ort_sl  := Space( 10 ) // ортопедия
  Public mem_ort_ysl := 1     // нет // ортопедия
  Public mem_ortotd  := 0            // ортопедия
  Public mem_ortot1  := 1            // ортопедия
  Public mem_ort_ms  := 2     // да  // ортопедия
  Public mem_ort_bp  := "ZAKAZ_BP.SMY"// ортопедия
  Public mem_ort_pl  := "ZAKAZ_PL.SMY"// ортопедия
  Public mem_ort_dat := 1             // ортопедия
  Public mem_ort_f8  := "LIST_U_8.SHB" // ортопедия
  Public mem_ortfflu := 1              // ортопедия
  Public mem_ort_dog := Space( 3 )   // расширение догов. ортопедии
  Public mem_ort_f39 := 0  // работать с формой 39

  Public MUSIC_ON_OFF := ( mem_sound == 2 )

  If ( j := search_file( "lpu" + sini, 2 ) ) != NIL
  /*i := GetIniVar( j, {{"kartoteka","uchastok",}} )
  if i[1] != NIL .and. eq_any(i[1],"1","2")
    is_uchastok := int(val(i[1]))
  endif
  i := GetIniVar( j, {{"diagnoz","bukva",}} )
  if i[1] != NIL
    yes_d_plus := i[1]
    for i := 1 to len(yes_d_plus)
      if asc(substr(yes_d_plus,i, 1)) > 64
        yes_bukva := .t. ; exit
      endif
    next
  endif
  i := GetIniVar( j, {{'uslugi',"oplata",}} )
  if i[1] != NIL
    is_oplata := int(val(i[1]))
    if !between(is_oplata, 5, 7)
      is_oplata := 5
    endif
  endif
  // Разрешается выписывать счета с нулевой суммой (по параклинике):
  i := GetIniVar( j, {{'uslugi',"schet_nul",}} )
  if i[1] != NIL
    is_0_schet := int(val(i[1]))
    if !between(is_0_schet, 0, 1)
      is_0_schet := 0
    endif
  endif
  i := GetIniVar( j, {{"lechenie","human_otd",}, ;
                      {"lechenie","standart",}, ;
                      {"lechenie","many_uch",}} )
  if i[1] != NIL .and. i[1] == "2"
    yes_h_otd := 2        // работаем без выбора отделений
  endif
  if i[2] != NIL .and. i[2] == "2"
    yes_vypisan := B_END  // установлена задача "Завершение лечения"
  endif
  if i[3] != NIL .and. i[3] == "2"
    yes_many_uch := .t.  // выбор отделения из всех доступных учреждений
  endif
  //
  i := GetIniVar( j, {{"list_uch","nomer",}} )
  if i[1] != NIL
    if upper(i[1]) == "RECNO"
      yes_num_lu := 1  // номер л/у равен номеру записи
    endif
  endif
  // для задачи "Платные услуги"
  i := GetIniVar( j, {{"lpu_plat","regi_plat",}, ;
                      {"lpu_plat","close",}, ;
                      {"lpu_plat","kassa",}} )
  if i[1] != NIL .and. i[1] == "1"
    glob_pl_reg := 1  // вводим квитанционную книжку в задаче "Платные услуги"
  endif
  if i[2] != NIL .and. i[1] == "1"
    glob_close := 1  // закрытие листа учета - вручную
  endif
  if i[3] != NIL .and. eq_any(i[3],"elves","fr")
    glob_kassa := 1   // кассовый аппарат: Штрих-ФР-Ф
    glob_pl_reg := 0  // убираем квитанционную книжку
  endif*/
    // для задачи "Платные услуги" и "ЛПУ-Касса"
    i := getinivar( j, { { "kassa", "delta_chek", } } )
    If i[ 1 ] != NIL
      delta_chek := Int( Val( i[ 1 ] ) )
    Endif
  Endif
  //
  If ( j := search_file( "lpu_stom" + sini ) ) != NIL
    k := getinisect( j, "Категория" )
    If !Empty( k )
      stm_kategor2 := {}
      For i := 1 To Len( k )
        AAdd( stm_kategor2, { k[ i, 1 ], Int( Val( k[ i, 2 ] ) ) } )
      Next
    Endif
    k := getinisect( j, "Повод" )
    If !Empty( k )
      stm_povod := {}
      For i := 1 To Len( k )
        AAdd( stm_povod, { k[ i, 1 ], Int( Val( k[ i, 2 ] ) ) } )
      Next
    Endif
    k := getinisect( j, "Травма" )
    If !Empty( k )
      stm_travma := {}
      For i := 1 To Len( k )
        AAdd( stm_travma, { k[ i, 1 ], Int( Val( k[ i, 2 ] ) ) } )
      Next
    Endif
  Endif
  //
  Public dlo_version := 4
  Public is_r_mu := .f.
  Public gpath_reg := "" // путь к файлам R_MU.DBF
  Return Nil