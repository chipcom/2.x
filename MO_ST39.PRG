***** mo_st39.prg - стоматологическая форма 39 и прочие функции
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

Static f39h_nastr   := "f39hnast.ini"
Static f39h_sect    := "Форма 39Х - "
Static f39hdp_sect  := "Форма 39ХDP - "
Static f39hdz_sect  := "Форма 39ХDZ - "
Static f39t_nastr   := "f39tnast.ini"
Static f39t_sect    := "Форма 39T - "
Static f39tdp_sect  := "Форма 39TDP - "
Static f39tdz_sect  := "Форма 39TDZ - "
Static f39tdd_sect  := "Форма 39TDD - "

***** 16.11.16
Function f_stom_39_hirur()
f39_hir()
return NIL

***** 16.11.16
Function f_stom_39_terap()
f39_ter()
return NIL

***** 21.09.17 Запрос лиц, подлежащих диспасеризации, методом многовариантного поиска
Function mnog_poisk_DVN1()
Local mm_tmp := {}, mm_sort
Local buf := savescreen(), tmp_color := setcolor(cDataCGet),;
      tmp_help := help_code, hGauge, name_file := "_kartDVN"+stxt,;
      sh := 80, HH := 77, i, a_diagnoz[10], ta, name_dbf := cur_dir+"_kartDVN"+sdbf,;
      mm_da_net := {{"нет",1},{"да ",2}}, ;
      mm_mest := {{"Волгоград или область",1},{"иногородние",2}},;
      mm_disp := {{"неважно",0},{"не проходили",1},{"прошли",2}},;
      mm_death := {{"выводить всех",0},{"не выводить умерших",1},{"выводить только умерших",2}},;
      mm_prik := {{"неважно",0},;
                  {"прикреплён к нашей МО",1},;
                  {"прикреплён к другим МО",2},;
                  {"прикрепление неизвестно",3}},;
      tmp_file := cur_dir+"tmp_mn_p"+sdbf,;
      k_fio, k_adr, tt_fio[10], tt_adr[10], fl_exit := .f.
Local adbf := {;
   {"UCHAST" ,   "N",  2,0},; // номер участка
   {"KOD_VU" ,   "N",  6,0},; // код в участке
   {"FIO"    ,   "C", 50,0},; // Ф.И.О. больного
   {"PHONE"  ,   "C", 40,0},; // телефон больного
   {"POL"    ,   "C",  1,0},; // пол
   {"DATE_R"   , "C", 10,0},; // дата рождения больного
   {"LET"    ,   "N",  2,0},; // сколько лет в этом году
   {"ADRESR"  ,  "C", 50,0},; // адрес больного
   {"ADRESP"  ,  "C", 50,0},; // адрес больного
   {"RABOTA" ,   "C", 12,0},; // 0-работ,1-нераб
   {"POLIS",     "C", 17,0},; // полис
   {"KOD_SMO",   "C",  5,0},; //
   {"SMO",       "C", 80,0},; // реестровый номер СМО;;преобразовать из старых кодов в новые, иногродние = 34
   {"SNILS"  ,   "C", 14,0},;
   {"PENSIONER", "C", 11,0},; // является пенсионером?;0-нет, 1-да;
   {"MO_PR",     "C",  6,0},; // код МО приписки
   {"MONAME_PR", "C", 60,0},; // наименование МО приписки
   {"DATE_PR"  , "C", 10,0},; // дата приписки
   {"LAST_L_U" , "C", 10,0};  // дата последнего листа учёта
  }
if !myFileDeleted(name_dbf)
  return NIL
endif
Private mm_smo := {}, pyear, mstr_crb := 0, is_kategor2 := .f., is_talon := ret_is_talon()
if is_talon
  is_kategor2 := !empty(stm_kategor2)
endif
for i := 1 to len(glob_arr_smo)
  if glob_arr_smo[i,3] == 1
    aadd(mm_smo,{glob_arr_smo[i,1],padr(lstr(glob_arr_smo[i,2]),5)})
  endif
next
ta := f2_mnog_poisk_DVN2(,,,1)
keyboard chr(K_TAB)
aadd(mm_tmp, {"net_dann","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "Не обращался в нашу МО после этой даты"})
aadd(mm_tmp, {"god","N",4,0,"9999",;
              nil,;
              0,nil,;
              "Год проведения диспансеризации"})
aadd(mm_tmp, {"v_period","C",100,0,NIL,;
              {|x|menu_reader(x,{{ |k,r,c| f2_mnog_poisk_DVN2(k,r,c) }},A__FUNCTION)},;
              ta[1],{|x| ta[2] },;
              'Возрастные периоды диспансеризации'})
aadd(mm_tmp, {"o_disp","N",1,0,NIL,;
              {|x|menu_reader(x,mm_disp,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_disp,x)},;
              "Отношение к диспансеризации"})
aadd(mm_tmp, {"o_prik","N",1,0,NIL,;
              {|x|menu_reader(x,mm_prik,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_prik,x)},;
              "Отношение к прикреплению"})
aadd(mm_tmp, {"o_death","N",1,0,NIL,;
              {|x|menu_reader(x,mm_death,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_death,x)},;
              "Сведения о смерти по сведениям ТФОМС"})
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
  mm_sort := {;
   {"№ участка + Лет дисп-ии + ФИО",1},;
   {"№ участка + Лет дисп-ии + Адрес",2},;
   {"№ участка + Адрес + Лет дисп-ии",4};
  }
  if is_uchastok == 1
    aadd(mm_sort, {'№ участка + № в участке',3})
  elseif is_uchastok == 2
    aadd(mm_sort, {'№ участка + Код по картотеке',3})
  elseif is_uchastok == 3
    aadd(mm_sort, {'№ участка + номер АК МИС',3})
  endif
else
  mm_sort := {;
   {"Лет дисп-ии + ФИО",1},;
   {"Лет дисп-ии + Адрес",2},;
   {"Код по картотеке",3};
  }
  Del_Array(adbf,1) // убираем участок
  Del_Array(adbf,1) // убираем участок
endif
aadd(mm_tmp, {"fio","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "ФИО (начальные буквы или шаблон)"})
aadd(mm_tmp, {"mi_git","N",2,0,NIL,;
              {|x|menu_reader(x,mm_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Место жительства:"})
aadd(mm_tmp, {"_okato","C",11,0,NIL,;
              {|x|menu_reader(x,;
                {{ |k,r,c| get_okato_ulica(k,r,c,{k,m_okato,}) }},A__FUNCTION)},;
              space(11),{|x| space(11)},;
              'Адрес регистрации (ОКАТО)'})
aadd(mm_tmp, {"adres","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "Улица (подстрока или шаблон)"})
if is_talon
  aadd(mm_tmp, {"kategor","N",2,0,NIL,;
                {|x|menu_reader(x,mo_cut_menu(stm_kategor),A__MENUVERT)},;
                0,{|| space(10) },;
                "Код категории льготы"})
  if is_kategor2
    aadd(mm_tmp, {"kategor2","N",4,0,NIL,;
                  {|x|menu_reader(x,stm_kategor2,A__MENUVERT)},;
                  0,{|| space(10) },;
                  "Категория МО"})
  endif
endif
aadd(mm_tmp, {"pol","C",1,0,"!",;
              nil,;
              " ",nil,;
              "Пол", {|| mpol $ " МЖ" } })
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
aadd(mm_tmp, {"smo","C",5,0,NIL,;
              {|x|menu_reader(x,mm_smo,A__MENUVERT)},;
              space(5),{|| space(10) },;
              "Страховая компания"})
aadd(mm_tmp, {"i_sort","N",1,0,NIL,;
              {|x|menu_reader(x,mm_sort,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_sort,x)},;
              "Сортировка выходного документа"})
delete file (tmp_file)
init_base(tmp_file,,mm_tmp,0)
//
k := f_edit_spr(A__APPEND,mm_tmp,"множественному запросу",;
                "e_use(cur_dir+'tmp_mn_p')",0,1,,,,,"write_mn_p_DVN1")
if k > 0
  mywait()
  use (tmp_file) new alias MN
  if is_talon .and. mn->kategor == 0
    is_talon := (is_kategor2 .and. mn->kategor2 > 0)
  endif
  Private mfio := "", madres := "", arr_vozr := List2Arr(mn->v_period)
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
  Private c_view := 0, c_found := 0
  Status_Key("^<Esc>^ - прервать поиск")
  hGauge := GaugeNew(,,,"Поиск в картотеке",.t.)
  GaugeDisplay( hGauge )
  //
  dbcreate(cur_dir+"tmp",{{"kod","N",7,0}},,.t.,"TMP")
  if !empty(mn->net_dann) // ВСТАВКА
    R_Use(dir_server+"hum_p",dir_server+"hum_pkk","HUM_P")
    R_Use(dir_server+"hum_ort",dir_server+"hum_ortk","HUM_ORT")
    R_Use(dir_server+"kas_pl",dir_server+"kas_pl1","KS_PL")
    R_Use(dir_server+"kas_ORT",dir_server+"kas_ort1","KS_ORT")
    R_Use(dir_server+"mo_regi",dir_server+"mo_regi3","RU")
    R_Use(dir_server+"mo_pp",dir_server+"mo_pp_r","PP")
    R_Use(dir_server+"mo_nnapr",,"NAPR")
    index on str(kod_k,7)+dtos(date_d) to tmp_NA
  endif // ВСТАВКА- КОНЕЦ
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_, recno() into KART2
  go top
  do while !eof()
    GaugeUpdate( hGauge, recno()/lastrec() )
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    f1_mnog_poisk_DVN1(@c_view,@c_found)
    select KART
    skip
  enddo
  CloseGauge(hGauge)
  j := tmp->(lastrec())
  close databases
  if j == 0
    if !fl_exit
      func_error(4,"Нет сведений!")
    endif
  else
    stat_msg("Составление текстового и DBF-файлов")
    use (tmp_file) new alias MN
    arr_title := {;
     "─────┬",;
     " №№  │",;
     " пп  │",;
     "─────┴"}
    if is_uchastok > 0 .or. mn->i_sort == 3 // Код по картотеке
      arr_title[1] += "─────────┬"
      arr_title[2] += " Участок │"
      arr_title[3] += "   код   │"
      arr_title[4] += "─────────┴"
    endif
    arr_title[1] += "───────────────────────────────────────────┬──┬──────────┬───────────────────────────────────┬─────┬──────────"
    arr_title[2] += "             Ф.И.О. пациента               │Ле│   дата   │              Адрес                │при- │последний "
    arr_title[3] += "                (телефон)                  │т │ рождения │                                   │креп.│л/у по ОМС"
    arr_title[4] += "───────────────────────────────────────────┴──┴──────────┴───────────────────────────────────┴─────┴──────────"
    reg_print := f_reg_print(arr_title,@sh,2)
    dbcreate(name_dbf,adbf,,.t.,"DVN")
    R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
    R_Use(dir_server+"kartote2",,"KART2")
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"kartotek",,"KART")
    set relation to recno() into KART_, to recno() into KART2
    use (cur_dir+"tmp") new
    set relation to kod into KART
    if is_uchastok > 0
      if mn->i_sort == 1 // № участка + Год рождения + ФИО
        index on str(kart->uchast,2)+str(abs(mn->god-year(kart->date_r)),4)+upper(kart->fio) to (cur_dir+"tmp")
      elseif mn->i_sort == 2 // № участка + Год рождения + Адрес
        index on str(kart->uchast,2)+str(abs(mn->god-year(kart->date_r)),4)+upper(kart->adres) to (cur_dir+"tmp")
      elseif mn->i_sort == 4 // № участка + Адрес + Год рождения
        index on str(kart->uchast,2)+upper(kart->adres)+str(abs(mn->god-year(kart->date_r)),4) to (cur_dir+"tmp")
      elseif mn->i_sort == 3 // № участка + Код
        if is_uchastok == 1 // № участка + № в участке
          index on str(kart->uchast,2)+str(kart->kod_vu,5)+upper(kart->fio) to (cur_dir+"tmp")
        elseif is_uchastok == 2 // № участка + Код по картотеке
          index on str(kart->uchast,2)+str(kart->kod,7) to (cur_dir+"tmp")
        elseif is_uchastok == 3 // № участка + номер АК МИС
          index on str(kart->uchast,2)+kart2->kod_AK+upper(kart->fio) to (cur_dir+"tmp")
        endif
      endif
    else
      if mn->i_sort == 1 // Год рождения + ФИО
        index on str(abs(mn->god-year(kart->date_r)),4)+upper(kart->fio) to (cur_dir+"tmp")
      elseif mn->i_sort == 2 // Год рождения + Адрес
        index on str(abs(mn->god-year(kart->date_r)),4)+upper(kart->adres) to (cur_dir+"tmp")
      elseif mn->i_sort == 3 // Код по картотеке
        index on str(kod,7) to (cur_dir+"tmp")
      endif
    endif
    fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center(expand("РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА"),sh))
    add_string("")
    add_string(" == ПАРАМЕТРЫ ПОИСКА ==")
    if !empty(mn->net_dann)
      add_string("Лица, не обращавшиеся в нашу МО после "+full_date(mn->net_dann))
    endif
    if !empty(mn->god)
      add_string("Год проведения диспансеризации: "+lstr(mn->god))
      if !empty(mn->v_period)
        add_string("Возрастные периоды диспансеризации: "+alltrim(mn->v_period))
      endif
    endif
    if mn->o_death == 1
      add_string("За исключением умерших (по сведению ТФОМС)")
    elseif mn->o_death == 2
      add_string("Список умерших (по сведению ТФОМС)")
    endif
    if !empty(mn->o_disp)
      add_string("Отношение к диспансеризации: "+inieditspr(A__MENUVERT, mm_disp, mn->o_disp))
    endif
    if !empty(mn->o_prik)
      add_string("Отношение к прикреплению: "+inieditspr(A__MENUVERT, mm_prik, mn->o_prik))
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
    if mn->mi_git > 0
      add_string("Место жительства: "+inieditspr(A__MENUVERT, mm_mest, mn->mi_git))
    endif
    if !empty(mn->_okato)
      add_string("Адрес регистрации (ОКАТО): "+ret_okato_ulica('',mn->_okato))
    endif
    if !empty(madres)
      add_string("Улица: "+madres)
    endif
    if is_talon .and. mn->kategor > 0
      add_string("Код категории льготы: "+inieditspr(A__MENUVERT, stm_kategor, mn->kategor))
    endif
    if is_talon .and. is_kategor2 .and. mn->kategor2 > 0
      add_string("Категория МО: "+inieditspr(A__MENUVERT, stm_kategor2, mn->kategor2))
    endif
    if !empty(mn->pol)
      add_string("Пол: "+mn->pol)
    endif
    if !empty(mn->god_r_min) .or. !empty(mn->god_r_max)
      if empty(mn->god_r_min)
        add_string("Лица, родившиеся до "+full_date(mn->god_r_max))
      elseif empty(mn->god_r_max)
        add_string("Лица, родившиеся после "+full_date(mn->god_r_min))
      else
        add_string("Лица, родившиеся с "+full_date(mn->god_r_min)+" по "+full_date(mn->god_r_max))
      endif
    endif
    if mn->rab_nerab >= 0
      add_string(upper(inieditspr(A__MENUVERT, menu_rab, mn->rab_nerab)))
    endif
    if !empty(mn->smo)
      add_string("СМО: "+inieditspr(A__MENUVERT, mm_smo, mn->smo))
    endif
    add_string("")
    add_string("Найдено пациентов: "+lstr(tmp->(lastrec()))+" чел.")
    aeval(arr_title, {|x| add_string(x) } )
    ii := 0
    select TMP
    go top
    do while !eof()
      ++ii
      @ maxrow(),1 say str(ii/tmp->(lastrec())*100,6,2)+"%" color cColorSt2Msg
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      mdate := ctod("")
      select HUMAN
      find (str(tmp->kod,7))
      do while human->kod_k == tmp->kod .and. !eof()
        if empty(mdate)
          mdate := human->k_data
        else
          mdate := max(mdate,human->k_data)
        endif
        skip
      enddo
      select DVN
      append blank
      s1 := padr(lstr(ii),6)
      if is_uchastok > 0 .or. mn->i_sort == 3
        if is_uchastok > 0
          s := ""
          if !empty(kart->uchast)
            dvn->UCHAST := kart->uchast
            s += lstr(kart->uchast)
          endif
          if is_uchastok == 1 .and. !empty(kart->kod_vu) // № участка + № в участке
            s += "/"+lstr(kart->kod_vu)
            dvn->KOD_VU := kart->kod_vu
          elseif is_uchastok == 2 // № участка + Код по картотеке
            s += "/"+lstr(kart->kod)
            dvn->KOD_VU := kart->kod
          elseif is_uchastok == 3 .and. !empty(kart2->kod_AK) // № участка + номер АК МИС
            s += "/"+ltrim(kart2->kod_AK)
            dvn->KOD_VU := val(kart2->kod_AK)
          endif
        else
          s := padl(lstr(tmp->kod),9)
        endif
        s1 += padr(s,10)
      endif
      s := ""
      if !empty(kart_->PHONE_H)
        s += "д."+alltrim(kart_->PHONE_H)+" "
      endif
      if !empty(kart_->PHONE_M)
        s += "м."+alltrim(kart_->PHONE_M)+" "
      endif
      if !empty(kart_->PHONE_W)
        s += "р."+alltrim(kart_->PHONE_W)
      endif
      dvn->FIO := kart->fio
      dvn->PHONE := s
      s := alltrim(kart->fio)+" "+s
      k_fio := perenos(tt_fio,s,43)
      s1 += padr(tt_fio[1],44)
      if (k := iif(mn->god > 0, mn->god, year(sys_date)) - year(kart->date_r)) > 99
        k := 99
      endif
      s1 += str(k,2)+" "
      dvn->LET := k
      s1 += full_date(kart->date_r)+" "
      dvn->POL := kart->pol
      dvn->DATE_R := full_date(kart->date_r)
      k_adr := perenos(tt_adr,kart->adres,35)
      s1 += padr(tt_adr[1],36)
      dvn->ADRESR := kart->adres
      dvn->ADRESP := kart_->adresp
      dvn->RABOTA := inieditspr(A__MENUVERT, menu_rab, kart->RAB_NERAB)
      dvn->POLIS := ltrim(kart_->NPOLIS)
      dvn->KOD_SMO := kart_->smo
      dvn->SMO := smo_to_screen(1)
      dvn->SNILS := iif(empty(kart->SNILS),"",transform(kart->SNILS,picture_pf))
      dvn->PENSIONER := iif(kart_->PENSIONER==1,"пенсионер","")
      if !empty(dvn->mo_pr := kart2->mo_pr)
        dvn->MONAME_PR := ret_mo(kart2->mo_pr)[_MO_SHORT_NAME]
        if !empty(kart2->pc4)
          dvn->DATE_PR := left(kart2->pc4,6)+"20"+substr(kart2->pc4,7)
        else
          dvn->DATE_PR := full_date(kart2->DATE_PR)
        endif
      endif
      if empty(kart2->MO_PR)
        s := ""
      elseif kart2->MO_PR == glob_mo[_MO_KOD_TFOMS]
        s := "наш"
      else
        s := "чужой"
      endif
      s1 += padr(s,6)
      s1 += full_date(mdate)
      dvn->last_l_u := full_date(mdate)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s1)
      for i := 2 to max(k_fio,k_adr)
        s1 := space(6)
        if is_uchastok > 0 .or. mn->i_sort == 3
          s1 += space(10)
        endif
        s1 += padr(tt_fio[i],44)
        s1 += space(14)
        s1 += tt_adr[i]
        add_string(s1)
      next
      add_string(replicate("-",sh))
      select TMP
      skip
    enddo
    if fl_exit
      add_string("*** "+expand("ОПЕРАЦИЯ ПРЕРВАНА"))
    else
      add_string("Итого количество пациентов: "+lstr(tmp->(lastrec()))+" чел.")
    endif
    fclose(fp)
    close databases
    restscreen(buf)
    viewtext(name_file,,,,.t.,,,reg_print)
    n_message({"Создан файл для загрузки в Excel: "+name_dbf},,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
  endif
endif
close databases
restscreen(buf) ; setcolor(tmp_color)
return NIL

***** 21.09.17
Function write_mn_p_DVN1(k)
Local fl := .t.
if k == 1
  if empty(mnet_dann)
    if empty(mgod)
      fl := func_error(4,'Обязательно должно быть заполнено поле "Год проведения диспансеризации"')
    elseif empty(mv_period)
      fl := func_error(4,'Обязательно должен быть введён хотя бы один возрастной период диспансеризации')
    endif
  endif
endif
return fl

***** 21.09.17
Static Function f1_mnog_poisk_DVN1(cv,cf)
Local i, j, k, n, s, arr, fl := .t., fl_disp := .f., god_r, arr1
++cv
if !empty(mn->net_dann)
  fl := f11_mnog_poisk_DVN1(mn->net_dann)
endif
if fl .and. mn->god > 0
  fl := (ascan(arr_vozr,mn->god-year(kart->date_r)) > 0)
endif
if fl .and. mn->o_disp > 0 .and. mn->god > 0
  select HUMAN
  find (str(kart->kod,7))
  do while human->kod_k == kart->kod .and. !eof()
    if year(human->k_data) == mn->god .and. eq_any(human->ishod,201,202)
      fl_disp := .t. ; exit
    endif
    skip
  enddo
  if mn->o_disp == 1 // не проходили
    fl := !fl_disp
  else // прошли
    fl := fl_disp
  endif
endif
if fl .and. !empty(mn->o_prik)
  if mn->o_prik == 1 // к нашей МО
    fl := (kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
  elseif mn->o_prik == 2 // к другим МО
    fl := !(kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
  else // прикрепление неизвестно
    fl := empty(kart2->MO_PR)
  endif
endif
if fl .and. mn->o_death > 0
  if mn->o_death == 1 // За исключением умерших (по сведению ТФОМС)
    fl := !(left(kart2->PC2,1) == "1")
  elseif mn->o_death == 2 // Список умерших (по сведению ТФОМС)
    fl := (left(kart2->PC2,1) == "1")
  endif
endif
if fl .and. is_uchastok > 0 .and. !empty(mn->bukva)
  fl := (mn->bukva == kart->bukva)
endif
if fl .and. is_uchastok > 0 .and. !empty(mn->uchast)
  fl := f_is_uchast(arr_uchast,kart->uchast)
endif
if fl .and. !empty(mfio)
  fl := like(mfio,upper(kart->fio))
endif
if fl .and. !empty(madres)
  fl := like(madres,upper(kart->adres))
endif
if fl .and. is_talon .and. mn->kategor > 0
  fl := (mn->kategor == kart_->kategor)
endif
if fl .and. is_kategor2 .and. mn->kategor2 > 0
  fl := (mn->kategor2 == kart_->kategor2)
endif
if fl .and. !empty(mn->pol)
  fl := (kart->pol == mn->pol)
endif
if fl .and. !empty(mn->god_r_min)
  fl := (mn->god_r_min <= kart->date_r)
endif
if fl .and. !empty(mn->god_r_max)
  fl := (human->date_r <= mn->god_r_max)
endif
if fl .and. mn->rab_nerab >= 0
  fl := (kart->rab_nerab == mn->rab_nerab)
endif
if fl .and. mn->mi_git > 0
  if mn->mi_git == 1
    fl := (left(kart_->okatog,2)=='18')
  else
    fl := !(left(kart_->okatog,2)=='18')
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
if fl .and. !empty(mn->smo)
  fl := (kart_->smo == mn->smo)
endif
//
if fl
  select TMP
  append blank
  tmp->kod := kart->kod
  if ++cf % 5000 == 0
    tmp->(dbCommit())
  endif
endif
@ maxrow(),1 say lstr(cv) color cColorSt2Msg
@ row(),col() say "/" color "W/R"
@ row(),col() say lstr(cf) color cColorStMsg
return NIL

***** 19.09.17
Static Function f11_mnog_poisk_DVN1(date_otbor_old)
Local fl_f11 := .T.
// ОМС
select HUMAN
find (str(kart->kod,7))
do while human->kod_k == kart->kod .and. !eof()
  if fl_f11 .and. human->k_data >= date_otbor_old
    // был после ХХ убираем из списка
    fl_f11 := .F.
  endif
  skip
enddo
// дополнительно проверяем регистратуру
if fl_f11
  select RU
  find (str(kart->kod,7)+dtoc4(date_otbor_old))
  do while ru->kod_k == kart->kod .and. !eof()
    // индекс обратный
    if fl_f11 .and. ru->pdate >= dtoc4(date_otbor_old)
      // был после ХХ убираем из списка
      fl_f11 := .F.
    endif
    skip -1
  enddo
endif
// платные
if fl_f11
  select HUM_P
  find (str(kart->kod,7)+dtos(date_otbor_old))
  do while hum_p->kod_k == kart->kod .and. !eof()
    // индекс обратный
    if fl_f11 .and. hum_p->k_data >= date_otbor_old
      fl_f11 := .F.
    endif
    skip -1
  enddo
endif
// ортопедия
if fl_f11
  select HUM_ORT
  find (str(kart->kod,7)+dtos(date_otbor_old))
  do while hum_ort->kod_k == kart->kod .and. !eof()
    // индекс обратный
    if fl_f11 .and. hum_opt->data >= date_otbor_old
      fl_f11 := .F.
    endif
    skip -1
  enddo
endif
// ЛПУ-касса
IF fl_f11
  select KS_PL
  find (str(kart->kod,7)+dtos(date_otbor_old))
  do while ks_pl->kod_k == kart->kod .and. !eof()
    // сортировка по увеличению даты
    // индекс обратный
    if fl_f11 .and. ks_pl->k_data >= date_otbor_old
      fl_f11 := .F.
    endif
    skip -1
  enddo
  //
  select KS_ORT
  find (str(kart->kod,7)+dtos(date_otbor_old))
  do while ks_ort->kod_k == kart->kod .and. !eof()
    // индекс обратный
    if fl_f11 .and. ks_ort->k_data >= date_otbor_old
      fl_f11 := .F.
    endif
    skip -1
  enddo
ENDIF
// ПРИемный покой
if fl_f11
  select PP
  find (str(kart->kod,7)+dtos(date_otbor_old))
  do while pp->kod_k == kart->kod .and. !eof()
    if fl_f11 .and. pp->k_data >= date_otbor_old
      fl_f11 := .F.
    endif
    skip -1
  enddo
endif
// госпитализация
if fl_f11
  select NAPR
  find (str(kart->kod,7)+dtos(date_otbor_old))
  do while napr->kod_k == kart->kod .and. !eof()
    if fl_f11 .and. napr->date_d >= date_otbor_old
      fl_f11 := .F.
    endif
    skip
  enddo
endif
return fl_f11

*

***** 22.12.14 Многовариантный запрос по диспансеризации/профилактике взрослого населения
Function mnog_poisk_DVN2()
Static mm_perevyst := {;
  {"без учёта случаев с отказом (перевыставленных)",0},;
  {"случаи с отказом, которые БЫЛИ перевыставлены",2},;
  {"случаи с отказом, которые НЕ были перевыставлены",3},;
  {"все случаи",1};
 }
Static mm_vid_obsl := {;
  {"ДИСПАНСЕРИЗАЦИЯ проведена",0},;
  {"ДИСПАНСЕРИЗАЦИЯ НЕ проведена",1},;
  {"ПРОФИЛАКТИКА проведена",2};
 }
Static mm_prikrepl := {;
  {"к нашей МО  ",1},;
  {"к другому МО",2},;
  {"неизвестно  ",3};
 }
Static mm_gruppa := {{"Присвоена I группа здоровья"  ,1},;
                     {"Присвоена II группа здоровья" ,2},;
                     {"Присвоена III группа здоровья",3}}
Static mm_regschet := {{"Не зарегистрированные счета",1},{"Зарегистрированные счета",2}}
Static mm_schet := {{"Не попавшие в счета",1},{"Попавшие в счета",2}}
Static mm_reestr := {{"Не попавшие в реестры",1},{"Попавшие в реестры",2}}
Static mm_da_net := {{"нет",1},{"да ",2}}
Local mm_tmp := {}, k
Local buf := savescreen(), tmp_color := setcolor(cDataCGet),;
      tmp_help := help_code, hGauge, name_file := "mn_z2dvn"+stxt,;
      sh := 80, HH := 77, i, a_diagnoz[10], lvid_doc := 0,;
      tmp_file := "tmp_mn_p"+sdbf,;
      k_diagnoz, k_usl, tt_diagnoz[10], tt_usl[10]
Private ssumma := 0, suet := 0, mm_company := {}, ;
        is_kategor2 := .f., is_talon := ret_is_talon()
if is_talon
  is_kategor2 := !empty(stm_kategor2)
endif
//
close databases
//
Private pdate_lech, pdate_vvod, mstr_crb := 0, mstr_crbM := {}, ;
        mm_rslt := {;
  {"316 Направлен на II этап диспансеризации",316},;
  {"352 Направлен на II этап, предварительно присвоена I группа здоровья",352},;
  {"353 Направлен на II этап, предварительно присвоена II группа здоровья",353},;
  {"354 Направлен на II этап, предварительно присвоена III группа здоровья",354};
 }
//
aadd(mm_tmp, {"date_lech","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(pdate_lech:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              'Дата окончания лечения (отч.период)',;
              {|| iif(empty(mdate_lech),func_error(4,"Не заполнена дата окончания лечения"),.t.)} })
aadd(mm_tmp, {"date_vvod","N",4,0,NIL,;
              {|x|menu_reader(x,;
                 {{|k,r,c| k:=year_month(r+1,c),;
                      if(k==nil,nil,(pdate_vvod:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION)},;
              0,{|| space(10) },;
              '  дата ввода информации'})
aadd(mm_tmp, {"reestr","N",1,0,NIL,;
              {|x|menu_reader(x,mm_reestr,A__MENUVERT)},;
              0,{|| space(10) },;
              "В реестре?"})
aadd(mm_tmp, {"schet","N",1,0,NIL,;
              {|x|menu_reader(x,mm_schet,A__MENUVERT)},;
              0,{|| space(10) },;
              "В счёте?"})
aadd(mm_tmp, {"regschet","N",1,0,NIL,;
              {|x|menu_reader(x,mm_regschet,A__MENUVERT)},;
              0,{|| space(10) },;
              "Счёт зарегистрирован в ТФОМС?",,;
              {|| m1schet == 2 }})
aadd(mm_tmp, {"perevyst","N",1,0,NIL,;
              {|x|menu_reader(x,mm_perevyst,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_perevyst,x)},;
              "Какие случаи учитывать?"})
aadd(mm_tmp, {"vid_obsl","N",1,0,NIL,;
              {|x|menu_reader(x,mm_vid_obsl,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_vid_obsl,x)},;
              "Вид обследования",;
              {|g,o| f_valid_mnog_poisk_DVN2(g,o) } })
aadd(mm_tmp, {"v_period","C",100,0,NIL,;
              {|x|menu_reader(x,{{ |k,r,c| f2_mnog_poisk_DVN2(k,r,c) }},A__FUNCTION)},;
              space(100),{|x| space(10)},;
              ' Возрастные периоды диспансеризации',,;
              {|| m1vid_obsl < 2 } })
aadd(mm_tmp, {"disp1","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
              " Проведён I этап диспансеризации?",;
              {|| iif(m1disp1==2,nil,(mrslt:=space(60),m1rslt:=0,update_get("mrslt"))), .t.},;
              {|| m1vid_obsl < 2 } })
aadd(mm_tmp, {"rslt","N",3,0,NIL,;
              {|x|menu_reader(x,mm_rslt,A__MENUVERT)},;
              -1,{|| space(10) },;
              " └─> на II этап?(результат)",,;
              {|| m1disp1 == 2 } })
aadd(mm_tmp, {"disp2","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_da_net,x)},;
              " Проведён II этап диспансеризации?",,;
              {|| m1vid_obsl < 2 } })
aadd(mm_tmp, {"prikrepl","N",1,0,NIL,;
              {|x|menu_reader(x,mm_prikrepl,A__MENUVERT)},;
              0,{|| space(10) },;
              "Прикрепление",;
              {|| iif(m1prikrepl==2,nil,(mmo_prik:=space(70),m1mo_prik:=space(6),update_get("mmo_prik"))), .t.} })
aadd(mm_tmp, {"mo_prik","C",6,0,NIL,;
              {|x|menu_reader(x,{{ |k,r,c| f_get_mo(k,r,c,"loc_arr_MO[10].and.loc_arr_MO[2]!=glob_mo[2]") }},A__FUNCTION)},;
              space(6),{|x| space(10)},;
              '└─> к какому МО',,;
              {|| m1prikrepl == 2 } })
aadd(mm_tmp, {"gruppa","N",1,0,NIL,;
              {|x|menu_reader(x,mm_gruppa,A__MENUVERT)},;
              0,{|x|inieditspr(A__MENUVERT,mm_gruppa,x)},;
              "Группа здоровья?"})
aadd(mm_tmp, {"uch_doc","C",10,0,"@!",;
              nil,;
              space(10),nil,;
              "№ амб.карты/истории болезни (шаблон)"})
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
aadd(mm_tmp, {"_okato","C",11,0,NIL,;
              {|x|menu_reader(x,;
                {{ |k,r,c| get_okato_ulica(k,r,c,{k,m_okato,}) }},A__FUNCTION)},;
              space(11),{|x| space(11)},;
              'Адрес регистрации (ОКАТО)'})
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
  if is_kategor2
    aadd(mm_tmp, {"kategor2","N",4,0,NIL,;
                  {|x|menu_reader(x,stm_kategor2,A__MENUVERT)},;
                  0,{|| space(10) },;
                  "Категория МО"})
  endif
endif
aadd(mm_tmp, {"pol","C",1,0,"!",;
              nil,;
              " ",nil,;
              "Пол", {|| mpol $ " МЖ" } })
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
aadd(mm_tmp, {"vrach1","N",5,0,NIL,;
              nil,;
              0,nil,;
              "Лечащий врач",;
              {|g| st_v_vrach(g,"mvrach") } })
aadd(mm_tmp, {"vrach","C",50,0,NIL,;
              nil,;
              space(50),nil,;
              "            ",,;
              {|| .f. } })
aadd(mm_tmp, {"ist_fin","N",2,0,NIL,;
              {|x|menu_reader(x,mm_ist_fin,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Источник финансирования"})
aadd(mm_tmp, {"komu","N",2,0,NIL,;
              {|x|menu_reader(x,mm_komu,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Принадлежность счёта",;
              {|g,o| f_valid_komu(g,o) }})
aadd(mm_tmp, {"company","N",5,0,NIL,;
              {|x|menu_reader(x,mm_company,A__MENUVERT)},;
              0,{|| space(10) },;
              "  ==>",,{||eq_any(m1komu,0,1,3)}})
aadd(mm_tmp, {"is_dbf","N",1,0,NIL,;
              {|x|menu_reader(x,mm_da_net,A__MENUVERT)},;
              1,{|| space(10) },;
              "Создавать DBF-файл (параллельно с текстовым)?"})
delete file (tmp_file)
init_base(tmp_file,,mm_tmp,0)
//
R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
k := f_edit_spr(A__APPEND,mm_tmp,"множественному запросу",;
                "g_use(cur_dir+'tmp_mn_p',,,.t.,.t.)",0,1,,,,,"write_mn_p_DVN2")
if k > 0
  mywait()
  use (tmp_file) new alias MN
  if mn->ist_fin >= 0
    Private _arr_if := {mn->ist_fin}, _what_if := _init_if(), _arr_komit := {}
  endif
  if is_talon .and. mn->kategor == 0
    is_talon := (is_kategor2 .and. mn->kategor2 > 0)
  endif
  // заменить таб.номер на код
  if mn->vrach1 > 0
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
    find (str(mn->vrach1,5))
    if found()
      mn->vrach1 := perso->kod
    endif
    perso->(dbCloseArea())
  endif
  Private much_doc := "", mfio := "", madres := "", mmr_dol := "", ;
          arr_vozr := List2Arr(mn->v_period)
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
  dbcreate(cur_dir+"tmp",{{"kod",      "N", 7,0},;
                          {"kod_k",    "N", 7,0},;
                          {"etap",     "N", 1,0},;
                          {"vozr",     "N", 2,0},;
                          {"stoim",    "N",10,2}})
  use (cur_dir+"tmp") new
  dbcreate(cur_dir+"tmp_k",{{"kod_k","N",7,0},;
                            {"kol",  "N",6,0}})
  use (cur_dir+"tmp_k") new
  index on str(kod_k,7) to (cur_dir+"tmp_k")
  fl_exit := .f.
  Status_Key("^<Esc>^ - прервать поиск")
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"human_u_",,"HU_")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  set relation to recno() into HU_, to u_kod into USL additive
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",,"SCHET")
  set relation to recno() into SCHET_
  //
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_, to recno() into KART2
  //
  Private c_view := 0, c_found := 0
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")  // по дате окончания лечения
  set relation to recno() into HUMAN_
  dbseek(dtos(pdate_lech[5]),.t.)
  do while human->k_data <= pdate_lech[6] .and. !eof()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    date_24(human->k_data)
    f1_mnog_poisk_DVN2(@c_view,@c_found)
    select HUMAN
    skip
  enddo
  j := tmp->(lastrec())
  close databases
  if j == 0
    if !fl_exit
      func_error(4,"Нет сведений!")
    endif
  else
    mywait()
    use (tmp_file) new alias MN
    arr_title := {;
     "────────────────────────────────────────┬─────────",;
     "             Ф.И.О. больного            │  Сумма  ",;
     "                                        │ лечения ",;
     "────────────────────────────────────────┴─────────"}
      arr_title[1] += "┬────────"
      arr_title[2] += "│  Дата  "
      arr_title[3] += "│рождения"
      arr_title[4] += "┴────────"
      arr_title[1] += "┬────────────────────────"
      arr_title[2] += "│         Адрес          "
      arr_title[3] += "│                        "
      arr_title[4] += "┴────────────────────────"
      arr_title[1] += "┬────────"
      arr_title[2] += "│ Сроки  "
      arr_title[3] += "│лечения "
      arr_title[4] += "┴────────"
      arr_title[1] += "┬─────"
      arr_title[2] += "│ Леч."
      arr_title[3] += "│ врач"
      arr_title[4] += "┴─────"
    if yes_parol
      arr_title[1] += "┬──────────"
      arr_title[2] += "│Дата ввода"
      arr_title[3] += "│и оператор"
      arr_title[4] += "┴──────────"
    endif
    reg_print := f_reg_print(arr_title,@sh,2)
    if sh < 65 ; sh := 65 ; endif
    R_Use(dir_server+"human_u_",,"HU_")
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    set relation to recno() into HU_
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"schet",,"SCHET")
    set relation to recno() into SCHET_
    if yes_parol
      R_Use(dir_server+"base1",,"BASE1")
    endif
    R_Use(dir_server+"mo_pers",,"PERSO")
    R_Use(dir_server+"kartote2",,"KART2")
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"kartotek",,"KART")
    set relation to recno() into KART_, to recno() into KART2
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humank","HUMAN")
    set relation to recno() into HUMAN_
    fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center(expand("РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА"),sh))
    add_string("")
    add_string(" == ПАРАМЕТРЫ ПОИСКА ==")
    add_string("Дата окончания лечения: "+pdate_lech[4])
    if mn->perevyst != 1
      add_string(upper(inieditspr(A__MENUVERT, mm_perevyst, mn->perevyst)))
    endif
    if mn->reestr > 0
      add_string(inieditspr(A__MENUVERT, mm_reestr, mn->reestr))
    endif
    if mn->schet > 0
      add_string(inieditspr(A__MENUVERT, mm_schet, mn->schet))
      if mn->schet == 2 .and. mn->regschet > 0
        add_string(inieditspr(A__MENUVERT, mm_regschet, mn->regschet))
      endif
    endif
    add_string(inieditspr(A__MENUVERT, mm_vid_obsl, mn->vid_obsl))
    if mn->vid_obsl < 2
      if mn->disp1 > 0
        add_string(" Проведён I этап диспансеризации: "+inieditspr(A__MENUVERT, mm_da_net, mn->disp1))
      endif
      if mn->disp1 == 2 .and. mn->rslt > 0
        add_string(" └─> результат обращения: "+inieditspr(A__MENUVERT, mm_rslt, mn->rslt))
      endif
      if mn->disp2 > 0
        add_string(" Проведён II этап диспансеризации: "+inieditspr(A__MENUVERT, mm_da_net, mn->disp2))
      endif
    endif
    if mn->prikrepl > 0
      add_string("Прикрепление: "+inieditspr(A__MENUVERT, mm_prikrepl, mn->prikrepl))
      if mn->prikrepl == 2 .and. !empty(mn->mo_prik)
        add_string("└─> к какому МО прикреплён: "+ret_mo(mn->mo_prik)[_MO_SHORT_NAME])
      endif
    endif
    if mn->gruppa > 0
      add_string(inieditspr(A__MENUVERT, mm_gruppa, mn->gruppa))
    endif
    if !empty(much_doc)
      add_string("№ амб.карты/истории болезни: "+much_doc)
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
    if !empty(mn->_okato)
      add_string("Адрес регистрации (ОКАТО): "+ret_okato_ulica('',mn->_okato))
    endif
    if !empty(madres)
      add_string("Улица: "+madres)
    endif
    if !empty(mmr_dol)
      add_string("Место работы: "+mmr_dol)
    endif
    if is_talon .and. mn->kategor > 0
      add_string("Код категории льготы: "+;
                 inieditspr(A__MENUVERT, stm_kategor, mn->kategor))
    endif
    if is_talon .and. is_kategor2 .and. mn->kategor2 > 0
      add_string("Категория МО: "+;
                 inieditspr(A__MENUVERT, stm_kategor2, mn->kategor2))
    endif
    if !empty(mn->pol)
      add_string("Пол: "+mn->pol)
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
    if mn->vrach1 > 0
      add_string("Лечащий врач: "+alltrim(mn->vrach))
    endif
    if mn->ist_fin >= 0
      add_string("Источник финансирования "+;
                 inieditspr(A__MENUVERT, mm_ist_fin, mn->ist_fin))
    endif
    if mn->komu >= 0
      add_string("Принадлежность счёта: "+;
                 inieditspr(A__MENUVERT, mm_komu, mn->komu))

      if mn->company > 0
        add_string("  ==> "+;
                   inieditspr(A__MENUVERT, mm_company, mn->company))
      endif
    endif
    if mn->date_vvod > 0
      add_string("Дата ввода: "+pdate_vvod[4])
    endif
    add_string("")
    add_string(" == РЕЗУЛЬТАТЫ ПОИСКА ==")
    use (cur_dir+"tmp_k") new
    use (cur_dir+"tmp") new
    set relation to str(kod,7) into HUMAN
    index on upper(human->fio)+dtos(human->k_data) to (cur_dir+"tmp")
    add_string("Итого количество больных: "+lstr(tmp_k->(lastrec()))+" чел.")
    s := "Итого листов учета: "+lstr(tmp->(lastrec()))+" на сумму "+lput_kop(ssumma,.t.)+" руб."
    add_string(s)
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    ssumma := skol_lu := 0
    keyboard ""
    Status_Key("^<Esc>^ - прервать составление текстового файла")
    select TMP
    go top
    do while !eof()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      s1 := left(human->fio,40)
      kart->(dbGoto(human->kod_k))
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
        s2 := space(7)
      endif
      if mn->komu < 0
        s2 += f4_view_list_schet(human->komu,cut_code_smo(human_->smo),human->str_crb)
      endif
      s2 := padr(s2,50)
      s3 := iif(mem_kodkrt == 2, space(1), space(7))
      if !empty(mmr_dol)
        s3 += ltrim(kart->mr_dol)
      endif
      s3 := padr(s3,50)
      //
      s1 += str(tmp->stoim,10,2)
      ssumma += tmp->stoim
      ++skol_lu
      //
      s1 += " "+date_8(human->date_r)
      s2 += iif(empty(tmp->vozr), space(9), " возр.:"+str(tmp->vozr,2))
      s3 += iif(empty(tmp->etap), space(9), "  "+padr({"I","II"}[tmp->etap]+" этап",7))
      //
      perenos(a_diagnoz,ret_okato_ulica(kart->adres,kart_->okatog,0,2),24)
      s1 += " "+padr(alltrim(a_diagnoz[1]),24)
      s2 += " "+padr(alltrim(a_diagnoz[2]),24)
      s3 += " "+padr(alltrim(a_diagnoz[3]),24)
      //
      s1 += " "+date_8(human->n_data)
      s2 += " "+date_8(human->k_data)
      s3 += space(9)
      //
      if human_->vrach > 0
        select PERSO
        goto (human_->vrach)
        s1 += put_val(perso->tab_nom,6)
      else
        s1 += space(6)
      endif
      s2 += space(6)
      s3 += space(6)
      //
      if yes_parol
        s1 += " "+date_8(c4tod(human->date_e))+"г."
        if asc(human->kod_p) > 0
          select BASE1
          goto (asc(human->kod_p))
          if !eof() .and. !empty(base1->p1)
            s2 += " "+left(crypt(base1->p1,gpasskod),10)
          endif
        endif
      endif
      add_string(s1)
      add_string(s2)
      add_string(s3)
      select TMP
      skip
    enddo
    add_string(replicate("─",sh))
    if fl_exit
      add_string("*** "+expand("ОПЕРАЦИЯ ПРЕРВАНА"))
    else
      add_string("  Итого листов учета: "+lstr(tmp->(lastrec()))+;
                 " на сумму  "+lput_kop(ssumma,.t.)+" руб.")
    endif
    fclose(fp)
    close databases
    viewtext(name_file,,,,.t.,,,reg_print)
  endif
endif
close databases
restscreen(buf) ; setcolor(tmp_color)
return NIL

*

***** 18.12.14 valid на переменную "vid_obsl"
Function f_valid_mnog_poisk_DVN2(get,old)
if m1vid_obsl != old .and. old != NIL // при смене значения
  if m1vid_obsl == 2                  // на профилактику
    m1v_period := mv_period := space(100)
    m1disp1 := m1disp2 := m1rslt := 0
    mdisp1 := mdisp2 := space(3)
    mrslt := space(60)
    update_get("mv_period")
    update_get("mdisp1")
    update_get("mrslt")
    update_get("mdisp2")
  endif
endif
return .t.

***** 21.09.17 запрос в GET-е возрастных периодов диспансеризации
Function f2_mnog_poisk_DVN2(k,r,c,par)
Static sast, sarr
Local buf := save_maxrow(), a, i, j, s, s1
DEFAULT par TO 2
if sast == NIL
  sast := {} ; sarr := {}
  for j := 1 to len(arr_vozrast_DVN)
    aadd(sast,.t.)
    s := lstr(arr_vozrast_DVN[j])
    i := int(val(right(s,1)))
    if i == 1
      s += " год"
    elseif between(i,2,4)
      s += " года"
    else
      s += " лет"
    endif
    aadd(sarr,{s,arr_vozrast_DVN[j]})
  next
endif
s := s1 := ""
if par == 1
  sast := {}
  for i := 1 to len(sarr)
    aadd(sast,.t.)
    s += lstr(sarr[i,2])+iif(i < len(sarr),",","")
  next
  s1 := "все"
elseif (a := bit_popup(r,c,sarr,sast)) != NIL
  afill(sast,.f.)
  for i := 1 to len(a)
    if (j := ascan(sarr,{|x| x[2]==a[i,2] })) > 0
      sast[j] := .t.
      s += lstr(a[i,2])+iif(i<len(a),",","")
    endif
  next
  if len(a) == len(sast)
    s1 := "все"
  endif
endif
if empty(s)
  s := space(10)
endif
if empty(s1)
  s1 := s
endif
return {s,s1}

***** 16.12.14
Function write_mn_p_DVN2(k)
Local fl := .t.
if k == 1
  if empty(mdate_lech)
    fl := func_error(4,"Обязательно должно быть заполнено первое поле даты!")
  endif
endif
return fl

*

***** 22.12.14
Function f1_mnog_poisk_DVN2(cv,cf)
Static P_BEGIN_RSLT := 342, D_BEGIN_RSLT := 316, D_BEGIN_RSLT2 := 351
Local i, j, k, n, s, arr, fl := .t., flu := .f., mkol, mstoim := 0, fl1, fl2,;
      god_r, arr1
++cv
kart->(dbGoto(human->kod_k))
Private metap := 0, m1gruppa := 0, mdvozrast := 0,;
        arr_usl_dop := {}, arr_usl_otkaz := {}, m1veteran := 0,;
        m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, ;
        m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
        m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, m1prof_ko := 0, ;
        pole_diag, pole_1stadia, pole_1pervich, mWEIGHT := 0, mHEIGHT := 0
for i := 1 to 5
  pole_diag := "mdiag"+lstr(i)
  pole_1stadia := "m1stadia"+lstr(i)
  pole_1pervich := "m1pervich"+lstr(i)
  Private &pole_diag := space(6)
  Private &pole_1stadia := 0
  Private &pole_1pervich := 0
next
if mn->vid_obsl == 0      // ДИСПАНСЕРИЗАЦИЯ проведена
  if (fl := eq_any(human->ishod,201,202))
    metap := human->ishod-200
    if human_->RSLT_NEW > D_BEGIN_RSLT2
      m1GRUPPA := human_->RSLT_NEW - D_BEGIN_RSLT2
    else
      m1GRUPPA := human_->RSLT_NEW - D_BEGIN_RSLT
    endif
  endif
elseif mn->vid_obsl == 1  // ДИСПАНСЕРИЗАЦИЯ НЕ проведена
  fl := !eq_any(human->ishod,201,202,203,204,205)
elseif mn->vid_obsl == 2  // ПРОФИЛАКТИКА проведена
  if (fl := (human->ishod == 203))
    m1GRUPPA := human_->RSLT_NEW-P_BEGIN_RSLT
  endif
endif
if !between(m1gruppa,1,3)
  m1GRUPPA := 0
endif
if fl .and. mn->perevyst != 1
  if mn->perevyst == 0
    fl := (human_->oplata != 9)
  elseif mn->perevyst == 2
    fl := (human_->oplata == 9)
  elseif mn->perevyst == 3
    fl := (human_->oplata == 2)
  endif
endif
if fl .and. mn->date_vvod > 0
  fl := between(human->date_e,pdate_vvod[7],pdate_vvod[8])
endif
if fl
  if mn->reestr == 1
    fl := (human_->reestr == 0)
  elseif mn->reestr == 2
    fl := (human_->reestr > 0)
  endif
endif
if fl
  if mn->schet == 1
    fl := (human->schet <= 0)
  elseif mn->schet == 2
    if (fl := (human->schet > 0)) .and. mn->regschet > 0
      if schet->kod != human->schet
        schet->(dbGoto(human->schet))
      endif
      if mn->regschet == 1
        fl := (schet_->NREGISTR != 0) // не зарегистрированные
      elseif mn->regschet == 2
        fl := (schet_->NREGISTR == 0) // зарегистрированные
      endif
    endif
  endif
endif
if fl .and. eq_any(mn->vid_obsl,0,2)
  read_arr_DVN(human->kod)
  ret_tip_mas(mWEIGHT,mHEIGHT,@m1tip_mas)
endif
if fl .and. mn->vid_obsl == 0
  mdvozrast := year(human->n_data) - year(human->date_r)
  if m1veteran == 1
    mdvozrast := ret_vozr_DVN_veteran(mdvozrast)
  endif
  if !empty(arr_vozr)
    fl := (ascan(arr_vozr,mdvozrast) > 0)
  endif
  if fl .and. mn->disp1 > 0
    if mn->disp1 == 2 // да
      fl := (metap == 1)
    else
      fl := (metap != 1)
    endif
    if fl .and. mn->rslt > 0
      fl := (human_->RSLT_NEW == mn->rslt)
    endif
  endif
  if fl .and. mn->disp2 > 0
    if mn->disp2 == 2 // да
      fl := (metap == 2)
    else
      fl := (metap != 2)
    endif
  endif
endif
if fl .and. mn->prikrepl > 0
  if mn->prikrepl == 1 // к нашей МО
    fl := (kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
  elseif mn->prikrepl == 2 // к другому МО
    fl := !(kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
    if fl .and. !empty(mn->mo_prik)
      fl := (kart2->MO_PR == mn->mo_prik)
    endif
  elseif mn->prikrepl == 3 // неизвестно
    fl := empty(kart2->MO_PR)
  endif
endif
if fl .and. !empty(much_doc)
  fl := like(much_doc,human->uch_doc)
endif
if fl .and. is_uchastok > 0 .and. !empty(mn->bukva)
  kart->(dbGoto(human->kod_k))
  fl := (mn->bukva == kart->bukva)
endif
if fl .and. is_uchastok > 0 .and. !empty(mn->uchast)
  kart->(dbGoto(human->kod_k))
  fl := f_is_uchast(arr_uchast,kart->uchast)
endif
if fl .and. !empty(mfio)
  fl := like(mfio,upper(human->fio))
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
if fl .and. is_kategor2 .and. mn->kategor2 > 0
  fl := (mn->kategor2 == kart_->kategor2)
endif
if fl .and. !empty(mn->pol)
  fl := (human->pol == mn->pol)
endif
if fl .and. !empty(mn->god_r_min)
  fl := (mn->god_r_min <= human->date_r)
endif
if fl .and. !empty(mn->god_r_max)
  fl := (human->date_r <= mn->god_r_max)
endif
if fl .and. mn->rab_nerab >= 0
  fl := (kart->rab_nerab == mn->rab_nerab)
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
if fl .and. mn->vrach1 > 0
  fl := (human_->vrach == mn->vrach1)
endif
if fl .and. mn->ist_fin >= 0
  fl := _f_ist_fin()
endif
if fl .and. mn->komu >= 0
  if mn->company == 0
    fl := (mn->komu==human->komu)
  elseif mn->komu == 0
    if human->schet > 0
      if schet->kod != human->schet
        schet->(dbGoto(human->schet))
      endif
      fl := (int(val(schet_->smo))==mn->company)
    else
      fl := (int(val(cut_code_smo(human_->smo)))==mn->company)
    endif
  else
    fl := (mn->komu==human->komu .and. mn->company==human->str_crb)
  endif
endif
if fl
  select TMP_K
  find (str(human->kod_k,7))
  if !found()
    append blank
    tmp_k->kod_k := human->kod_k
  endif
  tmp_k->kol ++
  select TMP
  append blank
  tmp->kod := human->kod
  tmp->kod_k := human->kod_k
  tmp->etap := metap
  tmp->vozr := mdvozrast
  tmp->stoim := human->cena_1
  ssumma += tmp->stoim
  if ++cf % 5000 == 0
    tmp->(dbCommit())
    tmp_k->(dbCommit())
  endif
endif
@ 24,1 say lstr(cv) color cColorSt2Msg
@ row(),col() say "/" color "W/R"
@ row(),col() say lstr(cf) color cColorStMsg
return NIL

*

***** 16.11.16
Function f39_hir(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"Форма 39 по ~организации",;
                "Форма 39 по ~врачу",;
                "~Настройка формы 39",;
                "~Печать настройки"}
    mas_msg := {"Распечатка формы 39 в целом по организации",;
                "Распечатка формы 39 по врачу",;
                "Настройка для составления формы 39",;
                "Распечатка настройки формы 39-ХИРУРГИЯ"}
    mas_fun := {"f39_hir(1)",;
                "f39_hir(2)",;
                "f39_hir(3)",;
                "f39_hir(4)"}
    popup_prompt(T_ROW-len(mas_pmt)-3,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 1
    forma_39hall(3)
  case k == 2
    forma_39hall(1)
  case k == 3
    forma_39h_na(1)
  case k == 4
    forma_39h_na(2)
endcase
if between(k,1,9)
  si1 := k
endif
return NIL


*

*****
Function get_nastr_stom_f39h()
Local nf := dir_server+f39h_nastr, fl, i
if (fl := file(nf))
  for j := 1 to 35
    t := "au"+lstr(j)
    &t := GetIniSect(nf,f39h_sect+lstr(j))
  next
  fl := .f.
  for j := 1 to 35
    t := "au"+lstr(j)
    for i := 1 to len(&t)
      fl := .t.
      &t[i,2] := int(val(&t[i,2]))
    next
  next
  //
  for j := 1 to 35
    tt := "aud"+lstr(j)
    &tt := GetIniSect(nf,f39hdp_sect+lstr(j))
  next
  fl := .f.
  for j := 1 to 35
    tt := "aud"+lstr(j)
    for i := 1 to len(&tt)
      fl := .t.
      &tt[i,2] := int(val(&tt[i,2]))
    next
  next
  //
  for j := 1 to 35
    ttt := "auz"+lstr(j)
    &ttt := GetIniSect(nf,f39hdz_sect+lstr(j))
  next
  fl := .f.
  for j := 1 to 35
    ttt := "auz"+lstr(j)
    for i := 1 to len(&ttt)
      fl := .t.
      &ttt[i,2] := int(val(&ttt[i,2]))
    next
  next
  //
endif
//
if !fl
  func_error(4,"Не произведена настройка формы 39-ХИРУРГИЯ")
endif
return fl


*

*****
Function forma_39hall(tip_f39)
Static sds := 0
Local i, j, k, arr, begin_date, end_date, s, buf := save_row(24),;
      fl_exit := .f., tm, t, tt, t1, t2, s_lu := 0, s_human := 0,;
      kh := 0, jh := 0, arr_m, arr_pl, arr_dms, ttt
Local  mas_pmt := {"По дате ~окончания лечения",;
                   "По ~дате оказания услуги"}
//Public menu_vid_opl := {{"ОМС",1},;  //  (битовое)
//                        {"Бюджет",2},;
//                        {"Пл.услуги",3},;
//                        {"ДМС",4},;
//                        {"Другое",5}}
Private Pi1 := 0, Pi1_DATE, Pi1_OMS := 1

for j := 1 to 35
  t := "au"+lstr(j)
  tt := "aud"+lstr(j)
  ttt := "auz"+lstr(j)
  Private &t
  Private &tt
  Private &ttt
next
Private mas_diag := {}
//
if !get_nastr_stom_f39h()
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
if (krvz := fbp_tip_f39(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
if (j := popup_prompt(T_ROW,T_COL-5,sds,mas_pmt,,,"B/BG,W+/B,N/BG,BG+/B")) > 0
  sds := j
endif
Pi1 := j
if tip_f39 == 1 .and. !input_perso(T_ROW,T_COL-5,.f.)
  return NIL
endif
Private speriod := arr_m[4]
begin_date := arr_m[7]
end_date := dtos(arr_m[6])
//
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
delFRfiles()
dbcreate(cur_dir+"tmp_hum",{{"kod_h","N",6,0},;
                            {"date_u","C",4,0}})
cre_tmp_39h({{"p_kod","C",4,0},;
             {"data","D",8,0},;
             {"tip","N",1,0},;   // 1-весь персонал, 2-перс.в отделении, 3-отделение
             {"otd","N",2,0},;
             {"tab_nom","N",5,0},;
             {"name","C",25,0},;
             {"summa","N",10,2},;
             {"sr_it","N",1,0},;
             {"sanirov","N",10,0},;
             {"yet","N",10,2};
            })
use (fr_data) new alias TMP
index on str(tip,1)+p_kod to (cur_dir+"tmp")
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
//
if ascan(krvz,1) > 0  // ОМС
  Pi1_OMS := 1
  if Pi1 == 1 //по дате окончания лечения
    R_Use(dir_server+"kartote_",,"KARTOTE_")
    if ascan(krvz,3) > 0 //платные присутствуют
      //Pi1_OMS := 0
      R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","PHU")
      R_Use(dir_server+"hum_p",dir_server+"hum_pkk","PHUMAN")
    endif
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    dbseek(arr_m[5],.t.)
    // цикл по ОМС
    do while human->k_data <= arr_m[6] .and. !eof()
      // проходим по диагнозам
      mas_diag := {}
      if len(alltrim(human->kod_diag)) > 3
        aadd(mas_diag,human->kod_diag)
      endif
      if len(alltrim(human->kod_diag2)) > 3
        aadd(mas_diag,human->kod_diag2)
      endif
      if len(alltrim(human->kod_diag3)) > 3
        aadd(mas_diag,human->kod_diag3)
      endif
      if len(alltrim(human->kod_diag4)) > 3
        aadd(mas_diag,human->kod_diag4)
      endif
      preobr_mkb()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select TMP
      find ("1"+dtoc4(human->k_data))  // поиск по дате
      if !found()
        append blank
        tmp->p_kod := dtoc4(human->k_data)
        tmp->data  := human->k_data
        tmp->tip   := 1
      endif
      //tmp->summa += human->cena
      if (arr := yes_f_39h(0,0,tip_f39)) != NIL
        ++jh
        for i := 1 to len(arr)
          write_f39h(arr[i])
        next
      endif
      @ 24,1 say lstr(++kh) color cColorSt2Msg
      if jh > 0
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh) color cColorStMsg
      endif
      select HUMAN
      skip
    enddo
    KARTOTE_->(dbclosearea())
    HU->(dbclosearea())
    HUMAN->(dbclosearea())
    HUMAN_->(dbclosearea())
    if ascan(krvz,3) > 0 //платные присутствуют
      PHU->(dbclosearea())
      PHUMAN->(dbclosearea())
    endif
  else  //дата оказания услуг
    R_Use(dir_server+"kartote_",,"KARTOTE_")
    if ascan(krvz,3) > 0 //платные присутствуют
      //Pi1_OMS := 0
      R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","PHU")
      R_Use(dir_server+"hum_p",dir_server+"hum_pkk","PHUMAN")
    endif
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    R_Use(dir_server+"human_u",dir_server+"human_ud","HU")
    use (cur_dir+"tmp_hum") new alias TMP_HUM
    select HU
    dbseek(arr_m[7],.t.)
    do while hu->date_u <= arr_m[8] .and. !eof()
      select TMP_HUM
      append blank
      tmp_hum->kod_h  := hu->kod
      tmp_hum->date_u := hu->date_u
      select HU
      skip
    enddo
    select TMP_HUM
    index on str(kod_h,6)+date_u to (cur_dir+"tmp_om") unique progress
    HU->(dbclosearea())
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    select TMP_HUM
    // создаём временный индекс - выбираем все нужные нам случ
    // цикл по ОМС
    go top
    do while !eof()
    // проходим по диагнозам
      select HUMAN
      goto (TMP_HUM->kod_h)
      Pi1_DATE := tmp_hum->date_u
      mas_diag := {}
      if len(alltrim(human->kod_diag)) > 3
        aadd(mas_diag,human->kod_diag)
      endif
      if len(alltrim(human->kod_diag2)) > 3
        aadd(mas_diag,human->kod_diag2)
      endif
      if len(alltrim(human->kod_diag3)) > 3
        aadd(mas_diag,human->kod_diag3)
      endif
      if len(alltrim(human->kod_diag4)) > 3
        aadd(mas_diag,human->kod_diag4)
      endif
      preobr_mkb()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select TMP
      find ("1"+tmp_hum->date_u)  // поиск по дате
      if !found()
        append blank
        tmp->p_kod := tmp_hum->date_u
        tmp->data  := c4tod(tmp_hum->date_u)
        tmp->tip   := 1
      endif
      //tmp->summa += human->cena
      if (arr := yes_f_39h(0,0,tip_f39)) != NIL
        ++jh
        for i := 1 to len(arr)
          write_f39h(arr[i])
        next
      endif
      @ 24,1 say lstr(++kh) color cColorSt2Msg
      if jh > 0
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh) color cColorStMsg
      endif
      select TMP_HUM
      skip
    enddo
    KARTOTE_->(dbclosearea())
    HU->(dbclosearea())
    HUMAN->(dbclosearea())
    HUMAN_->(dbclosearea())
    TMP_HUM->(dbclosearea())
    if ascan(krvz,3) > 0 //платные присутствуют
      PHU->(dbclosearea())
      PHUMAN->(dbclosearea())
    endif
  endif
endif
// для СОНИРОВАНО
if ascan(krvz,1) > 0  // ОМС
  R_Use(dir_server+"kartote_",,"KARTOTE_")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  dbseek(arr_m[5],.t.)
  // цикл по ОМС
  do while human->k_data <= arr_m[6] .and. !eof()
    // проходим о диагнозам
    select HUMAN_
    goto (human->(recno()))
    if iif(tip_f39 == 1,glob_human[1] == human_->vrach,.T.)
      if human_->ISHOD_NEW == 301
        select TMP
        find("1"+ dtoc4(human->k_data))
        if found()
          G_RLock(forever)
          tmp->p32 += 1
          UNLOCK
        endif
      endif
    endif
    select HUMAN
    skip
  enddo
  KARTOTE_->(dbclosearea())
  HUMAN->(dbclosearea())
  HUMAN_->(dbclosearea())
endif

//цикл только по платным
if ascan(krvz,3) > 0 //.and. ascan(krvz,1) == 0
  Pi1_OMS := 0
  R_Use(dir_server+"kartote_",,"KARTOTE_")
  R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
  R_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
  dbseek(dtos(arr_m[5]),.t.)
  // цикл по ОМС
  do while human->k_data <= arr_m[6] .and. !eof()
    mas_diag := {}
    if len(alltrim(human->kod_diag)) > 3
      aadd(mas_diag,human->kod_diag)
    endif
    if len(alltrim(human->soput_b1)) > 3
      aadd(mas_diag,human->soput_b1)
    endif
    if len(alltrim(human->soput_b2)) > 3
      aadd(mas_diag,human->soput_b2)
    endif
    if len(alltrim(human->soput_b3)) > 3
      aadd(mas_diag,human->soput_b3)
    endif
    if len(alltrim(human->soput_b4)) > 3
      aadd(mas_diag,human->soput_b4)
    endif
    if len(alltrim(human->soput_b5)) > 3
      aadd(mas_diag,human->soput_b5)
    endif
    preobr_mkb()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    select TMP
    find ("1"+dtoc4(human->k_data))  //
    if !found()
      append blank
      tmp->p_kod := dtoc4(human->k_data)
      tmp->data  := human->k_data
      tmp->tip   := 1
    endif
  //tmp->summa += human->cena
    if (arr := yes_f_39h(0,0,tip_f39)) != NIL
      ++jh
      for i := 1 to len(arr)
        write_f39h(arr[i])
      next
    endif
    @ 24,1 say lstr(++kh) color cColorSt2Msg
    if jh > 0
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jh) color cColorStMsg
    endif
    select HUMAN
    skip
  enddo
endif
//*******************
close databases

rest_box(buf)
mybell()
//
use (fr_data) new
index on p_kod to (fr_data)
//
dbcreate(fr_titl, {{"god","N",4,0},;
                   {"tit1name","C",130,0},;
                   {"tit2name","C",130,0},;
                   {"tit3name","C",130,0},;
                   {"tit4name","C",130,0}})
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
use (fr_titl) new
append blank
replace tit1name with alltrim(org->name)
replace tit2name with alltrim(arr_m[4])
if tip_f39 == 1 //по врачу
  replace tit3name with alltrim(glob_human[2])
endif
t := ""
if ascan(krvz,1) > 0
  t:= "ОМС"
endif
if ascan(krvz,3) > 0
  t += " + Платные услуги"
endif
replace tit4name with t
close databases
call_fr("mo_sth39.fr3")
return NIL

*

Function preobr_mkb()
// mas_diag
Local i
for i := 1 to len(mas_diag)
  select DIAG
  find (mas_diag[i]+" ")
  if found()
    mas_diag[i] := diag->(recno())
  endif
next
return NIL

*


***** проверить больного по БД human и вернуть результат в виде массива
Static Function yes_f_39h(par1,vozrast,vrach)
Local i, j, k, s, arr, ret, t_human := .T.
Private t_mas := array(45), lp := array(40)
Private mdate_r, m1vzros_reb := 0, t_vrach := vrach
arr := {}
// проходим по услугам
select HU
t_human := .T.
find (str(human->(recno()),6))
do while hu->kod == human->(recno()) .and. !eof()
  if iif(vrach== 1,glob_human[1] == hu->kod_vr,.T.)
    if iif(Pi1==1,.T.,hu->date_u==Pi1_DATE)
      k := hu->kol
      afill(lp,0)
      ___f_39h(k)
      lp[3] := lp[1]
      lp[1] := 0
      lp[6] := lp[2]
      lp[2] := 0
      lp[7] := lp[3]+lp[6]
      if vozrast == 1
        mdate_r := human->date_r
        fv_date_r(,.f.)
      else

      endif
      if m1vzros_reb == 0 //взрослые
        lp[1] := lp[3]
        lp[4] := lp[6]
      else
        lp[2] := lp[3]
        lp[5] := lp[6]
      endif

      //УЕТ
      lp[36] := opr_uet(m1vzros_reb)*k
      //
      if lp[37]
        //РЕЗУЛЬТАТ
     /*   if lp[36] > 0
          if Pi1_OMS == 1 .and. t_human
            select HUMAN_
            goto (human->(recno()))
            t_human := .F.
            if human_->RSLT_NEW == 301
              lp[32] := 1
            endif
          endif
        endif
        */
        aadd(arr,aclone(lp))
      endif
    endif
  endif
  select HU
  skip
enddo
if len(arr) > 0
  // проверяем второй список
  ret := arr
endif
return ret


*

*****
Function ___f_39h(k)
Local _1,_2, t_rec, t_flag, t_kart, t_date
  lp[37] := .F.
  for j := 1 to 35
    t := "au"+lstr(j)
    t1 := &t
    _1 := (ascan(&t,{|x| x[2] == hu->u_kod}) > 0)
    if _1
      lp[37] := .T.
      if j > 2
        lp[j+6]  := k
      else
        lp[j]  := k
      endif
    endif
    // проверяем второй список
    // делаем цикл по всему случаю

    tt := "aud"+lstr(j)
    t2 := &tt
    if len(&tt) > 0
      //если ответ отрицательный - нулируем предыдущий результат
      t_flag := .T.
      t_rec := hu->(recno())
      find (str(human->(recno()),6))
      do while hu->kod == human->(recno()) .and. !eof()
        if iif(t_vrach== 1,glob_human[1] == hu->kod_vr,.T.)
          _2 := (ascan(&tt,{|x| x[2] == hu->u_kod}) > 0)
          if _2
            t_flag := .F.
          endif
        endif
        skip
      enddo
      // проверка по ПЛАТНЫМ внутри ОМС
      if ascan(krvz,3) > 0 .and. ascan(krvz,1) > 0 .and. Pi1_OMS == 1
        //@ 10,20 say  human->kod_k
        //inkey(0)
        select HUMAN
        t_kart := human->kod_k
        // по дате окончания лечения
        if Pi1 == 1 //по дате окончания лечения
          t_date := human->k_data
        else // по дате услуги
          t_date := c4tod(Pi1_DATE)
        endif
        select PHUMAN
        find (str(t_kart,6)+dtos(t_date))
        // перебираем случаи
        do while phuman->kod_k == t_kart .and.;
                 phuman->k_data == t_date .and. !eof()
          select PHU
          // перебираем услуги
          //t_rec := hu->(recno())
          find (str(phuman->(recno()),6))
          do while phu->kod == phuman->(recno()) .and. !eof()
            if iif(t_vrach== 1,glob_human[1] == phu->kod_vr,.T.)
              _2 := (ascan(&tt,{|x| x[2] == phu->u_kod}) > 0)
              if _2
                t_flag := .F.
              endif
            endif
            skip
          enddo
          select PHUMAN
          skip
        enddo
      endif
      // конец проверки ОМС
      if t_flag
        if j > 2
          lp[j+6]  := 0
        else
          lp[j]  := 0
        endif
      endif
      hu->(dbgoto(t_rec))
    endif
    // проверяем третий список - ДИАГНОЗЫ
    ttt := "auz"+lstr(j)
    t3 := &ttt
    if len(&ttt) > 0
      //если ответ отрицательный - нулируем предыдущий результат
      // у нас есть масси диагнозов
      for ll := 1 to len(mas_diag)
        _3 := (ascan(&ttt,{|x| x[2] == mas_diag[ll]}) > 0)
        if _3
         exit
        else
          if j > 2
            lp[j+6]  := 0
          else
            lp[j]  := 0
          endif
        endif
      next
    endif
  next
return NIL

*

***** записать одну строку из массива в TMP-файл
Function write_f39h(ar)
Local i, pole
for i := 1 to 35
  pole := "tmp->p"+lstr(i)
  &pole := &pole + ar[i]
next
tmp->yet := tmp->yet+ar[36]
return NIL


*

*****
Function forma_39h_na(tip)
Static arr := {'Посещение первичное',;                  // 1
               'Посещение повторное',;                  // 2
               'Блокада',;                              // 3
               'Экстракция зубов с обезболиванием',;    // 4
               'Экстракция зубов без обезболивания',;   // 5
               'Экстракция корней зубов',;              // 6
               'Экстракция молочных зубов ',;           // 7
               'Экстракция постоянных зубов ',;         // 8
               'Экстракция зубов периостит',;           // 9
               'Экстракция зубов остеомиелит',;         // 10
               'Экстракция зубов резекций верх.корня',; // 11
               'Реплантарий',;                          // 12
               'Кюретаж лунки',;                        // 13
               'Альвелолотомия',;                       // 14
               'Удаление секвестров',;                  // 15
               'Удаление аномальных зубов',;            // 16
               'Удаление ретенционных кист',;           // 17
               'Удаление мигрирующих гранул',;          // 18
               'Удаление кист радикулярных',;           // 19
               'Удаление кист фолликулярных',;          // 20
               'Удаление доброкачественных опухолей',;  // 21
               'Вскрытие абсцесса',;                    // 22
               'Френгуло-пластика',;                    // 23
               'Операций с общим обезболиванием',;      // 24
               'Шинирование переломов',;                // 25
               'Санировано',;                           // 26
               'Консультаций, советов',;                // 27
               'Прочие заболевания'}                    // 28
Static si1
Local l, sh := 0, f39_scr := savescreen(), i, j
Local HH := 58, name_file := "orto_ns"+stxt,;
arr_title := {;
"──────────┬──────────────────────────────────────────────────────────────────",;
"   Шифр   │                                                                  ",;
"  услуги  │                  Наименование услуги                             ",;
"──────────┴──────────────────────────────────────────────────────────────────"}
if tip == 1
  aeval(arr, {|x| sh := max(sh,len(x)) })
  do while (l := popup(T_ROW,T_COL-5,22,T_COL+sh-2,arr,l)) > 0
    DEFAULT si1 TO 1
    mas_pmt := {"Основная услуга",;
                "Сопутствующая услуга",;
                "Обязательный диагноз"}
    if (j := popup_prompt(T_ROW,T_COL-5,si1,mas_pmt)) > 0
      si1 := j
      restscreen(f39_scr)
      if j == 1
        f1_forma_39h_na(l,arr[l],1)
      elseif j == 2
        f1_forma_39h_na(l,arr[l],2)
      else
        f1_forma_39h_na_diag(l,arr[l])
      endif
    endif
    restscreen(f39_scr)
  enddo
  restscreen(f39_scr)
else
  sh := len(arr_title[1])
  WaitStatus("<Esc> - прервать формирование") ; mark_keys({"<Esc>"})
  reg_print := 2
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("Настройка Форма 39-СТОМАТОЛОГИЯ-ХИРУРГИЯ",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  add_string("")
  for i := 1 to len(arr)
    add_string("")
    add_string("==>> "+arr[i])
    f1_forma_39h_prn_na(i,arr[i],1)
    if !eof()
      add_string("")
      add_string("=> ОСНОВНАЯ УСЛУГА")
    endif
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(tmp->u_shifr+"  "+tmp->u_name)
      skip
    enddo
    close databases
    //
    f1_forma_39h_prn_na(i,arr[i],2)
    if !eof()
      add_string("=> ОБЯЗАТЕЛЬНАЯ ДОПОЛНИТЕЛЬНАЯ УСЛУГА")
    endif
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(tmp->u_shifr+"  "+tmp->u_name)
      skip
    enddo
    close databases
    //
    f1_forma_39h_prn_diag_na(i,arr[i],2)
    if !eof()
      add_string("=> ОБЯЗАТЕЛЬНЫЙ ДИАГНОЗ")
    endif
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(tmp->d_shifr+"  "+tmp->d_name)
      skip
    enddo
    close databases
    //
  next
  fclose(fp)
  restscreen(f39_scr)
  viewtext(name_file)
  restscreen(f39_scr)
endif
return NIL


*

*****
Function f1_forma_39h_na(par,title, tip)
Local nfile := dir_server+f39h_nastr, name_sect
Local adbf, arr_usl, i
//
if tip == 1
  name_sect := f39h_sect+lstr(par)
else
  name_sect := f39hdp_sect+lstr(par)
endif
arr_usl := GetIniSect(nFile, name_sect)
adbf := {;
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0};   // наименование услуги
    }
dbcreate(cur_dir+"tmp", adbf)
R_Use(dir_server+"uslugi",,"USL")
use (cur_dir+"tmp") new
for i := 1 to len(arr_usl)
  select USL
  goto (val(arr_usl[i,2]))
  if !eof() .and. usl->kod > 0
    select TMP
    append blank
    tmp->u_kod := usl->kod
    tmp->u_shifr := usl->shifr
    tmp->u_name := usl->name
  endif
next
select TMP
index on str(u_kod,4) to (cur_dir+"tmpk")
index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
close databases
if tip == 1
  ob2_v_usl(,2,"Настройка формы 39-хирургия: колонка "+title)
else
  ob2_v_usl(,2,"Настройка формы 39-хирургия: колонка ДОПОЛНЕНИЕ "+title)
endif
if f_Esc_Enter(1)
  arr_usl := {}
  use (cur_dir+"tmp") index (cur_dir+"tmpn") new alias TMP
  go top
  do while !eof()
    aadd(arr_usl, {tmp->u_shifr,lstr(tmp->u_kod)})
    skip
  enddo
  close databases
  SetIniSect(nFile, name_sect, arr_usl)
endif
return NIL

*

*****
Function f1_forma_39h_prn_na(par,title, tip)
Local nfile := dir_server+f39h_nastr, name_sect
Local adbf, arr_usl, i
//
if tip == 1
  name_sect := f39h_sect+lstr(par)
else
  name_sect := f39hdp_sect+lstr(par)
endif
arr_usl := GetIniSect(nFile, name_sect)
adbf := {;
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0};   // наименование услуги
    }
dbcreate(cur_dir+"tmp", adbf)
R_Use(dir_server+"uslugi",,"USL")
use (cur_dir+"tmp") new
for i := 1 to len(arr_usl)
  select USL
  goto (val(arr_usl[i,2]))
  if !eof() .and. usl->kod > 0
    select TMP
    append blank
    tmp->u_kod := usl->kod
    tmp->u_shifr := usl->shifr
    tmp->u_name := usl->name
  endif
next
select TMP
index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
return NIL

*

*****
Function f1_forma_39h_prn_diag_na(par,title)
Local nfile := dir_server+f39h_nastr, name_sect
Local adbf, arr_diag, i
//
name_sect := f39hdz_sect+lstr(par)
arr_diag := GetIniSect(nFile, name_sect)
adbf := {;
     {"d_KOD"  ,    "N",      4,      0},;  // код услуги
     {"d_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"d_NAME",     "C",     65,      0};   // наименование услуги
    }
dbcreate(cur_dir+"tmp", adbf)
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
use (cur_dir+"tmp") new
for i := 1 to len(arr_diag)
  select DIAG
  goto (val(arr_diag[i,2]))
  if !eof() .and. diag->(recno()) > 0
    select TMP
    append blank
    tmp->d_kod   := diag->(recno())
    tmp->d_shifr := diag->shifr
    tmp->d_name  := diag->name
  endif
next
select TMP
index on d_shifr to (cur_dir+"tmpn")
return NIL



*

*****
Static Function cre_tmp_39h(adbf)
Local i
for i := 1 to 36
  aadd(adbf,{ "p"+lstr(i),"N",7,0})
next
dbcreate(fr_data,adbf)
return NIL



*

***** вернуть тип услуги (bit-овый вариант)
Function fbp_tip_f39(r,c,ret_arr)
Static sast := {.t.,.f.,.t.,.F.,.F.}
Local i, j, a, out_arr
DEFAULT r TO T_ROW, c TO T_COL+5
if (a := bit_popup(r,c,menu_vid_opl,sast)) != NIL
  out_arr := {} ; afill(sast,.f.)
  for i := 1 to len(a)
    aadd(out_arr,a[i,2])
    if (j := ascan(menu_vid_opl,{|x| x[2]==a[i,2] })) > 0
      sast[j] := .t.
    endif
  next
endif
return out_arr

*

*****
Function f1_forma_39h_na_diag(par,title, tip)
Local nfile := dir_server+f39h_nastr, name_sect
Local adbf, arr_diag, i
//
name_sect := f39hdz_sect+lstr(par)
arr_diag := GetIniSect(nFile, name_sect)
adbf := {;
     {"D_KOD"  ,    "N",      4,      0},;  // код услуги
     {"D_SHIFR",    "C",      6,      0},;  // шифр услуги
     {"D_NAME",     "C",     65,      0};   // наименование услуги
    }
dbcreate(cur_dir+"tmp", adbf)
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
use (cur_dir+"tmp") new
for i := 1 to len(arr_diag)
  select DIAG
  goto (val(arr_diag[i,2]))
  if !eof() .and. diag->(recno()) > 0
    select TMP
    append blank
    tmp->d_kod   := diag->(recno())
    tmp->d_shifr := diag->shifr
    tmp->d_name  := diag->name
  endif
next
select TMP
index on str(d_kod,4) to (cur_dir+"tmpk")
index on d_shifr to (cur_dir+"tmpn")
close databases
ob2_v_diag(,2,"Настройка формы 39-хирургия: колонка ДИАГНОЗ "+title)
if f_Esc_Enter(1)
  arr_diag := {}
  use (cur_dir+"tmp") index (cur_dir+"tmpn") new alias TMP
  go top
  do while !eof()
    aadd(arr_diag, {tmp->d_shifr,lstr(tmp->d_kod)})
    skip
  enddo
  close databases
  SetIniSect(nFile, name_sect, arr_diag)
endif
return NIL

*

*****
Function ob2_v_diag(is_get,r1,mtitul)
Local t_arr[BR_LEN], buf := savescreen(), k, ret
DEFAULT is_get TO .f., r1 TO T_ROW
if r1 > 14 ; r1 := 14 ; endif
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
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
t_arr[BR_COLUMN] := {{ "   Шифр", {|| tmp->d_shifr } },;
                     { center("Наименование диагноза",65), {|| tmp->d_name } } }
t_arr[BR_STAT_MSG] := {|| ;
  status_key("^<Esc>^ выход;  ^<Ins>^ добавление;  ^<Del>^ удаление диагноза;") }
t_arr[BR_EDIT] := {|nk,ob| ob21v_diag(nk,ob,"edit",mtitul) }
edit_browse(t_arr)
if is_get
  go top
  k := 0
  dbeval({|| if(tmp->d_kod > 0, ++k, nil)})
  ret := {k,"Кол-во услуг - "+lstr(k)}
endif
tmp->(dbCloseArea())
diag->(dbCloseArea())
restscreen(buf)
if !is_get
  WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
endif
return ret

*****
Function ob21v_diag(nKey,oBrow,regim,mtitul)
Local ret := -1, s
Local buf, fl := .f., rec, rec1, k := 19, tmp_color, n_file, sh := 80, HH := 60
do case
  case regim == "edit"
    do case
      case nKey == K_INS
        save screen to buf
        Private mshifr := space(6)
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1,21,pc2-1,,"Добавление диагноза",cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+27 say "Шифр диагн" get mshifr picture "@!"
                     //valid valid_shifr()
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !empty(mshifr)
          select DIAG
          find (mshifr)
          fl := found()
          select TMP
          if fl
            set order to 1
            fl_found := .t.
            AddRec(4)
            rec := recno()
            replace tmp->d_shifr with mshifr, tmp->d_name with diag->name,;
                    tmp->d_kod with diag->(recno())
            set order to 2
            oBrow:goTop()
            goto (rec)
            ret := 0
          else
            func_error(4,"Диагноза с данным шифром нет в справочнике!")
          endif
        endif
        if !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. !empty(tmp->d_kod)
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

***** 16.11.16
Function f39_ter(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"Форма 39 по ~организации",;
                "Форма 39 по ~врачу",;
                "~Настройка формы 39",;
                "~Печать настройки"}
    mas_msg := {"Распечатка формы 39 в целом по организации",;
                "Распечатка формы 39 по врачу",;
                "Настройка для составления формы 39",;
                "Распечатка настройки формы 39-ТЕРАПИЯ"}
    mas_fun := {"f39_ter(1)",;
                "f39_ter(2)",;
                "f39_ter(3)",;
                "f39_ter(4)"}
    popup_prompt(T_ROW-len(mas_pmt)-3,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 1
    forma_39tall(3)
  case k == 2
    forma_39tall(1)
  case k == 3
    forma_39t_na(1)
  case k == 4
    forma_39t_na(2)
endcase
if between(k,1,9)
  si1 := k
endif
return NIL


*

*****
Function get_nastr_stom_f39t()
Local nf := dir_server+f39t_nastr, fl, i
if (fl := file(nf))
  for j := 1 to 56
    t := "au"+lstr(j)
    &t := GetIniSect(nf,f39t_sect+lstr(j))
  next
  fl := .f.
  for j := 1 to 56
    t := "au"+lstr(j)
    for i := 1 to len(&t)
      fl := .t.
      &t[i,2] := int(val(&t[i,2]))
    next
  next
  //
  for j := 1 to 56
    tt := "aud"+lstr(j)
    &tt := GetIniSect(nf,f39tdp_sect+lstr(j))
  next
  fl := .f.
  for j := 1 to 56
    tt := "aud"+lstr(j)
    for i := 1 to len(&tt)
      fl := .t.
      &tt[i,2] := int(val(&tt[i,2]))
    next
  next
  //
  for j := 1 to 56
    ttt := "auz"+lstr(j)
    &ttt := GetIniSect(nf,f39tdz_sect+lstr(j))
  next
  fl := .f.
  for j := 1 to 56
    ttt := "auz"+lstr(j)
    for i := 1 to len(&ttt)
      fl := .t.
      &ttt[i,2] := int(val(&ttt[i,2]))
    next
  next
  //
endif
//
if !fl
  func_error(4,"Не произведена настройка формы 39-ТЕРАПИЯ")
endif
return fl


*

***** записать одну строку из массива в TMP-файл
Function write_f39t(ar)
Local i, pole
for i := 1 to 56
  pole := "tmp->p"+lstr(i)
  &pole := &pole + ar[i]
next
//tmp->p4 := tmp->p5 +tmp->p6
return NIL


*

*****
Function forma_39t_na(tip)
Static arr := {'02 - Посещений Всего',;
               '03 - Посещений дети до 15',;
               '04 - Посещений сельских жителей',;
               '05 - Посещений с лечебной целью Всего',;
               '06 - Лечение парадонтоза',;
               '07 - Лечение слизистой',;
               '08 - Первичные Всего',;
               '09 - Первичные Дети до 15',;
               '10 - Первичные больным пародонтозм',;
               '11 - Санированных всего',;
               '12 - Санированных детей до 15',;
               '13 - Лечение кариеса начато и закончено в одно посещение',;
               '14 - Лечение кариеса начато и не закончено',;
               '15 - Лечение кариеса продолжено и не закончено',;
               '16 - Лечение кариеса продолжено и закончено',;
               '17 - Лечение пульпита начато и закончено в одно посещение',;
               '18 - Лечение пульпита начато и не закончено',;
               '19 - Лечение пульпита продолжено и не закончено',;
               '20 - Лечение пульпита продолжено и закончено',;
               '21 - Лечение периодонтита начато и закончено в одно посещение',;
               '22 - Лечение периодонтита начато и не закончено',;
               '23 - Лечение периодонтита продолжено и не закончено',;
               '24 - Лечение периодонтита продолжено и закончено',;
               '25 - Число лиц, которым удал.отложения на зубах',;
               '26 - Удалённых зубов всего',;
               '27 - Удалённых зубов молочных',;
               '28 - Удалённых зубов постоянных',;
               '29 - Прочие амбулаторные операции',;
               '30 - колонка',;
               '31 - ПРОФ колонка',;
               '32 - ПРОФ колонка',;
               '33 - ПРОФ колонка',;
               '34 - ПРОФ колонка',;
               '35 - ПРОФ колонка',;
               '36 - ПРОФ Диспансерных больных',;
               '37 - ПРОФ Беременных',;
               '38 - ПРОФ НУЖДАЛИСЬ В СОНАЦИИ - всего',;
               '39 - ПРОФ НУЖДАЛИСЬ Дошкольников',;
               '40 - ПРОФ НУЖДАЛИСЬ Учащихся до 15 лет',;
               '41 - ПРОФ НУЖДАЛИСЬ Учащихся с 15 до 18 лет',;
               '42 - ПРОФ НУЖДАЛИСЬ Допризывников',;
               '43 - ПРОФ НУЖДАЛИСЬ Рабочих',;
               '44 - ПРОФ НУЖДАЛИСЬ Диспансерных больных',;
               '45 - ПРОФ НУЖДАЛИСЬ Беременных',;
               '46 - ПРОФ САНИРОВАНО',;
               '47 - ПРОФ САНИРОВАНО Дошкольников',;
               '48 - ПРОФ САНИРОВАНО Учащихся до 15 лет',;
               '49 - ПРОФ САНИРОВАНО Учащихся с 15 до 18 лет',;
               '50 - ПРОФ САНИРОВАНО Допризывников',;
               '51 - ПРОФ САНИРОВАНО Рабочих',;
               '52 - ПРОФ САНИРОВАНО Диспансерных больных',;
               '53 - ПРОФ САНИРОВАНО Беременных колонка',;
               '54 - ПРОФ Запломбировано каналов',;
               '55 - ПРОФ Закончен курс лечения парадонтоза',;
               '56 - ПРОФ Всего наложено пломб';
               }
Static si1
Local l, sh := 0, f39_scr := savescreen(), i, j
Local HH := 58, name_file := "orto_ns"+stxt,;
arr_title := {;
"──────────┬──────────────────────────────────────────────────────────────────",;
"   Шифр   │                                                                  ",;
"  услуги  │                  Наименование услуги                             ",;
"──────────┴──────────────────────────────────────────────────────────────────"}
if tip == 1
  aeval(arr, {|x| sh := max(sh,len(x)) })
  do while (l := popup(T_ROW,T_COL-5,22,T_COL+sh-2,arr,l)) > 0
    DEFAULT si1 TO 1
    mas_pmt := {"Основная услуга",;
                "Сопутствующая услуга",;
                "Обязательный диагноз",;
                "Исключительная услуга"}
    if (j := popup_prompt(T_ROW,T_COL-5,si1,mas_pmt)) > 0
      si1 := j
      restscreen(f39_scr)
      if j == 1
        f1_forma_39t_na(l,arr[l],1)
      elseif j == 2
        f1_forma_39t_na(l,arr[l],2)
      elseif j == 3
        f1_forma_39t_na_diag(l,arr[l])
      else
        f1_forma_39t_na(l,arr[l],3)
      endif
    endif
    restscreen(f39_scr)
  enddo
  restscreen(f39_scr)
else
  sh := len(arr_title[1])
  WaitStatus("<Esc> - прервать формирование") ; mark_keys({"<Esc>"})
  reg_print := 2
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("Настройка Форма 39-СТОМАТОЛОГИЯ-ТЕРАПИЯ",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  add_string("")
  for i := 1 to len(arr)
    add_string("")
    add_string("==>> "+arr[i])
    f1_forma_39t_prn_na(i,arr[i],1)
    if !eof()
      add_string("")
      add_string("=> ОСНОВНАЯ УСЛУГА")
    endif
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(tmp->u_shifr+"  "+tmp->u_name)
      skip
    enddo
    close databases
    //
    f1_forma_39t_prn_na(i,arr[i],2)
    if !eof()
      add_string("=> ОБЯЗАТЕЛЬНАЯ ДОПОЛНИТЕЛЬНАЯ УСЛУГА")
    endif
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(tmp->u_shifr+"  "+tmp->u_name)
      skip
    enddo
    close databases
    //
    f1_forma_39t_prn_na(i,arr[i],3)
    if !eof()
      add_string("=> УСЛУГА ОТМЕНЫ")
    endif
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(tmp->u_shifr+"  "+tmp->u_name)
      skip
    enddo
    close databases
    //

    f1_forma_39t_prn_diag_na(i,arr[i],2)
    if !eof()
      add_string("=> ОБЯЗАТЕЛЬНЫЙ ДИАГНОЗ")
    endif
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(tmp->d_shifr+"  "+tmp->d_name)
      skip
    enddo
    close databases
    //
  next
  fclose(fp)
  restscreen(f39_scr)
  viewtext(name_file)
  restscreen(f39_scr)
endif
return NIL


*

*****
Function f1_forma_39t_na(par,title, tip)
Local nfile := dir_server+f39t_nastr, name_sect
Local adbf, arr_usl, i
//
if tip == 1
  name_sect := f39t_sect+lstr(par)
elseif tip == 2
  name_sect := f39tdp_sect+lstr(par)
else
  name_sect := f39tdd_sect+lstr(par)
endif
arr_usl := GetIniSect(nFile, name_sect)
adbf := {;
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0};   // наименование услуги
    }
dbcreate(cur_dir+"tmp", adbf)
R_Use(dir_server+"uslugi",,"USL")
use (cur_dir+"tmp") new
for i := 1 to len(arr_usl)
  select USL
  goto (val(arr_usl[i,2]))
  if !eof() .and. usl->kod > 0
    select TMP
    append blank
    tmp->u_kod := usl->kod
    tmp->u_shifr := usl->shifr
    tmp->u_name := usl->name
  endif
next
select TMP
index on str(u_kod,4) to (cur_dir+"tmpk")
index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
close databases
if tip == 1
  ob2_v_usl(,2,"Настройка формы 39-терапия: колонка "+title)
elseif tip == 2
  ob2_v_usl(,2,"Настройка формы 39-терапия: колонка ДОПОЛНЕНИЕ "+title)
else
  ob2_v_usl(,2,"Настройка формы 39-терапия: колонка ОТМЕНА "+title)
endif
if f_Esc_Enter(1)
  arr_usl := {}
  use (cur_dir+"tmp") index (cur_dir+"tmpn") new alias TMP
  go top
  do while !eof()
    aadd(arr_usl, {tmp->u_shifr,lstr(tmp->u_kod)})
    skip
  enddo
  close databases
  SetIniSect(nFile, name_sect, arr_usl)
endif
return NIL

*

*****
Function f1_forma_39t_prn_na(par,title, tip)
Local nfile := dir_server+f39t_nastr, name_sect
Local adbf, arr_usl, i
//
if tip == 1
  name_sect := f39t_sect+lstr(par)
elseif tip == 2
  name_sect := f39tdp_sect+lstr(par)
else
  name_sect := f39tdd_sect+lstr(par)
endif
arr_usl := GetIniSect(nFile, name_sect)
adbf := {;
     {"U_KOD"  ,    "N",      4,      0},;  // код услуги
     {"U_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"U_NAME",     "C",     65,      0};   // наименование услуги
    }
dbcreate(cur_dir+"tmp", adbf)
R_Use(dir_server+"uslugi",,"USL")
use (cur_dir+"tmp") new
for i := 1 to len(arr_usl)
  select USL
  goto (val(arr_usl[i,2]))
  if !eof() .and. usl->kod > 0
    select TMP
    append blank
    tmp->u_kod := usl->kod
    tmp->u_shifr := usl->shifr
    tmp->u_name := usl->name
  endif
next
select TMP
index on fsort_usl(u_shifr) to (cur_dir+"tmpn")
return NIL

*

*****
Function f1_forma_39t_prn_diag_na(par,title)
Local nfile := dir_server+f39t_nastr, name_sect
Local adbf, arr_diag, i
//
name_sect := f39tdz_sect+lstr(par)
arr_diag := GetIniSect(nFile, name_sect)
adbf := {;
     {"d_KOD"  ,    "N",      4,      0},;  // код услуги
     {"d_SHIFR",    "C",     10,      0},;  // шифр услуги
     {"d_NAME",     "C",     65,      0};   // наименование услуги
    }
dbcreate(cur_dir+"tmp", adbf)
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
use (cur_dir+"tmp") new
for i := 1 to len(arr_diag)
  select DIAG
  goto (val(arr_diag[i,2]))
  if !eof() .and. diag->(recno()) > 0
    select TMP
    append blank
    tmp->d_kod   := diag->(recno())
    tmp->d_shifr := diag->shifr
    tmp->d_name  := diag->name
  endif
next
select TMP
index on d_shifr to (cur_dir+"tmpn")
return NIL



*

*****
Static Function cre_tmp_39t(adbf)
Local i
for i := 2 to 55
  aadd(adbf,{ "p"+lstr(i),"N",7,0})
next
aadd(adbf,{ "p56","N",9,2})
dbcreate(fr_data,adbf)
return NIL

*

*****
Function f1_forma_39t_na_diag(par,title, tip)
Local nfile := dir_server+f39t_nastr, name_sect
Local adbf, arr_diag, i
//
name_sect := f39tdz_sect+lstr(par)
arr_diag := GetIniSect(nFile, name_sect)
adbf := {;
     {"D_KOD"  ,    "N",      4,      0},;  // код услуги
     {"D_SHIFR",    "C",      6,      0},;  // шифр услуги
     {"D_NAME",     "C",     65,      0};   // наименование услуги
    }
dbcreate(cur_dir+"tmp", adbf)
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
use (cur_dir+"tmp") new
for i := 1 to len(arr_diag)
  select DIAG
  goto (val(arr_diag[i,2]))
  if !eof() .and. diag->(recno()) > 0
    select TMP
    append blank
    tmp->d_kod   := diag->(recno())
    tmp->d_shifr := diag->shifr
    tmp->d_name  := diag->name
  endif
next
select TMP
index on str(d_kod,4) to (cur_dir+"tmpk")
index on d_shifr to (cur_dir+"tmpn")
close databases
ob2_v_diag(,2,"Настройка формы 39-терапия: колонка ДИАГНОЗ "+title)
if f_Esc_Enter(1)
  arr_diag := {}
  use (cur_dir+"tmp") index (cur_dir+"tmpn") new alias TMP
  go top
  do while !eof()
    aadd(arr_diag, {tmp->d_shifr,lstr(tmp->d_kod)})
    skip
  enddo
  close databases
  SetIniSect(nFile, name_sect, arr_diag)
endif
return NIL


*

*****
Function forma_39tall(tip_f39)
Static sds := 0
Local i, j, k, arr, begin_date, end_date, s, buf := save_row(24),;
      fl_exit := .f., tm, t, tt, t1, t2, s_lu := 0, s_human := 0,;
      kh := 0, jh := 0, arr_m, arr_pl, arr_dms, ttt
Local  mas_pmt := {"По дате ~окончания лечения",;
                   "По ~дате оказания услуги"}
//Public menu_vid_opl := {{"ОМС",1},;  //  (битовое)
//                        {"Бюджет",2},;
//                        {"Пл.услуги",3},;
//                        {"ДМС",4},;
//                        {"Другое",5}}
Private Pi1 := 0, Pi1_DATE, Pi1_OMS := 1

for j := 1 to 56
  t := "au"+lstr(j)
  tt := "aud"+lstr(j)
  ttt := "auz"+lstr(j)
  Private &t
  Private &tt
  Private &ttt
next
Private mas_diag := {}
//
if !get_nastr_stom_f39t()
  return NIL
endif
if (arr_m := year_month()) == NIL
  return NIL
endif
if (krvz := fbp_tip_f39(T_ROW,T_COL-5,@arr_dms)) == NIL
  return NIL
endif
if (j := popup_prompt(T_ROW,T_COL-5,sds,mas_pmt,,,"B/BG,W+/B,N/BG,BG+/B")) > 0
  sds := j
endif
Pi1 := j
if tip_f39 == 1 .and. !input_perso(T_ROW,T_COL-5,.f.)
  return NIL
endif
Private speriod := arr_m[4]
begin_date := arr_m[7]
end_date := dtos(arr_m[6])
//
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
delFRfiles()
dbcreate(cur_dir+"tmp_hum",{{"kod_h","N",6,0},;
                            {"date_u","C",4,0}})
cre_tmp_39t({{"p_kod","C",4,0},;
             {"data","D",8,0},;
             {"tip","N",1,0},;   // 1-весь персонал, 2-перс.в отделении, 3-отделение
             {"otd","N",2,0},;
             {"tab_nom","N",5,0},;
             {"name","C",25,0},;
             {"summa","N",10,2},;
             {"sr_it","N",1,0},;
             {"sanirov","N",10,0},;
             {"yet","N",10,2},;
             {"p1","N",10,2};
            })
use (fr_data) new alias TMP
index on str(tip,1)+p_kod to (cur_dir+"tmp")
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
//
if ascan(krvz,1) > 0  // ОМС
  Pi1_OMS := 1
  if Pi1 == 1 //по дате окончания лечения
    R_Use(dir_server+"kartote_",,"KARTOTE_")
    if ascan(krvz,3) > 0 //платные присутствуют
      //Pi1_OMS := 0
      R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","PHU")
      R_Use(dir_server+"hum_p",dir_server+"hum_pkk","PHUMAN")
    endif
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    R_Use(dir_server+"human_u_",,"HU_")
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    dbseek(arr_m[5],.t.)
    // цикл по ОМС
    do while human->k_data <= arr_m[6] .and. !eof()
      // проходим по диагнозам
      mas_diag := {}
/*      if len(alltrim(human->kod_diag)) > 3
        aadd(mas_diag,human->kod_diag)
      endif
      if len(alltrim(human->kod_diag2)) > 3
        aadd(mas_diag,human->kod_diag2)
      endif
      if len(alltrim(human->kod_diag3)) > 3
        aadd(mas_diag,human->kod_diag3)
      endif
      if len(alltrim(human->kod_diag4)) > 3
        aadd(mas_diag,human->kod_diag4)
      endif
      preobr_mkb()
 */
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select TMP
      find ("1"+dtoc4(human->k_data))  // поиск по дате
      if !found()
        append blank
        tmp->p_kod := dtoc4(human->k_data)
        tmp->data  := human->k_data
        tmp->tip   := 1
      endif
      //tmp->summa += human->cena
      if (arr := yes_f_39t(0,0,tip_f39)) != NIL
        ++jh
        for i := 1 to len(arr)
          write_f39t(arr[i])
        next
      endif
      @ 24,1 say lstr(++kh) color cColorSt2Msg
      if jh > 0
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh) color cColorStMsg
      endif
      select HUMAN
      skip
    enddo
    KARTOTE_->(dbclosearea())
    HU->(dbclosearea())
    HU_->(dbclosearea())
    HUMAN->(dbclosearea())
    HUMAN_->(dbclosearea())
    if ascan(krvz,3) > 0 //платные присутствуют
      PHU->(dbclosearea())
      PHUMAN->(dbclosearea())
    endif
  else  //дата оказания услуг
    R_Use(dir_server+"kartote_",,"KARTOTE_")
    if ascan(krvz,3) > 0 //платные присутствуют
      //Pi1_OMS := 0
      R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","PHU")
      R_Use(dir_server+"hum_p",dir_server+"hum_pkk","PHUMAN")
    endif
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    R_Use(dir_server+"human_u_",,"HU_")
    R_Use(dir_server+"human_u",dir_server+"human_ud","HU")
    use (cur_dir+"tmp_hum") new alias TMP_HUM
    select HU
    dbseek(arr_m[7],.t.)
    do while hu->date_u <= arr_m[8] .and. !eof()
      select TMP_HUM
      append blank
      tmp_hum->kod_h  := hu->kod
      tmp_hum->date_u := hu->date_u
      select HU
      skip
    enddo
    select TMP_HUM
    index on str(kod_h,6)+date_u to (cur_dir+"tmp_om") unique progress
    HU->(dbclosearea())
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    select TMP_HUM
    // создаём временный индекс - выбираем все нужные нам случ
    // цикл по ОМС
    go top
    do while !eof()
    // проходим по диагнозам
      select HUMAN
      goto (TMP_HUM->kod_h)
      Pi1_DATE := tmp_hum->date_u
      mas_diag := {}
 /*     if len(alltrim(human->kod_diag)) > 3
        aadd(mas_diag,human->kod_diag)
      endif
      if len(alltrim(human->kod_diag2)) > 3
        aadd(mas_diag,human->kod_diag2)
      endif
      if len(alltrim(human->kod_diag3)) > 3
        aadd(mas_diag,human->kod_diag3)
      endif
      if len(alltrim(human->kod_diag4)) > 3
        aadd(mas_diag,human->kod_diag4)
      endif
      preobr_mkb()
 */
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      select TMP
      find ("1"+tmp_hum->date_u)  // поиск по дате
      if !found()
        append blank
        tmp->p_kod := tmp_hum->date_u
        tmp->data  := c4tod(tmp_hum->date_u)
        tmp->tip   := 1
      endif
      //tmp->summa += human->cena
      if (arr := yes_f_39t(0,0,tip_f39)) != NIL
        ++jh
        for i := 1 to len(arr)
          write_f39t(arr[i])
        next
      endif
      @ 24,1 say lstr(++kh) color cColorSt2Msg
      if jh > 0
        @ row(),col() say "/" color "W/R"
        @ row(),col() say lstr(jh) color cColorStMsg
      endif
      select TMP_HUM
      skip
    enddo
    KARTOTE_->(dbclosearea())
    HU->(dbclosearea())
    HU_->(dbclosearea())
    HUMAN->(dbclosearea())
    HUMAN_->(dbclosearea())
    TMP_HUM->(dbclosearea())
    if ascan(krvz,3) > 0 //платные присутствуют
      PHU->(dbclosearea())
      PHUMAN->(dbclosearea())
    endif
  endif
endif
// для СОНИРОВАНО
if ascan(krvz,1) > 0  // ОМС
  R_Use(dir_server+"kartote_",,"KARTOTE_")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  dbseek(arr_m[5],.t.)
  // цикл по ОМС
  do while human->k_data <= arr_m[6] .and. !eof()
    // проходим о диагнозам
    select HUMAN_
    goto (human->(recno()))
    if iif(tip_f39 == 1,glob_human[1] == human_->vrach,.T.)
      if human_->ISHOD_NEW == 301
        select TMP
        find("1"+ dtoc4(human->k_data))
        if found()
          G_RLock(forever)
          tmp->p10 += 1
          UNLOCK
        endif
      endif
    endif
    select HUMAN
    skip
  enddo
  KARTOTE_->(dbclosearea())
  HUMAN->(dbclosearea())
  HUMAN_->(dbclosearea())
endif

//цикл только по платным
if ascan(krvz,3) > 0 //.and. ascan(krvz,1) == 0
  Pi1_OMS := 0
  R_Use(dir_server+"kartote_",,"KARTOTE_")
  R_Use(dir_server+"hum_p_u",dir_server+"hum_p_u","HU")
  R_Use(dir_server+"hum_p",dir_server+"hum_pd","HUMAN")
  dbseek(dtos(arr_m[5]),.t.)
  // цикл по ОМС
  do while human->k_data <= arr_m[6] .and. !eof()
/*    mas_diag := {}
    if len(alltrim(human->kod_diag)) > 3
      aadd(mas_diag,human->kod_diag)
    endif
    if len(alltrim(human->soput_b1)) > 3
      aadd(mas_diag,human->soput_b1)
    endif
    if len(alltrim(human->soput_b2)) > 3
      aadd(mas_diag,human->soput_b2)
    endif
    if len(alltrim(human->soput_b3)) > 3
      aadd(mas_diag,human->soput_b3)
    endif
    if len(alltrim(human->soput_b4)) > 3
      aadd(mas_diag,human->soput_b4)
    endif
    if len(alltrim(human->soput_b5)) > 3
      aadd(mas_diag,human->soput_b5)
    endif
    preobr_mkb()
    */
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    select TMP
    find ("1"+dtoc4(human->k_data))  //
    if !found()
      append blank
      tmp->p_kod := dtoc4(human->k_data)
      tmp->data  := human->k_data
      tmp->tip   := 1
    endif
  //tmp->summa += human->cena
    if (arr := yes_f_39t(0,0,tip_f39)) != NIL
      ++jh
      for i := 1 to len(arr)
        write_f39t(arr[i])
      next
    endif
    @ 24,1 say lstr(++kh) color cColorSt2Msg
    if jh > 0
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jh) color cColorStMsg
    endif
    select HUMAN
    skip
  enddo
endif
//*******************

close databases

rest_box(buf)
mybell()
//
use (fr_data) new
index on p_kod to (fr_data)
//
dbcreate(fr_titl, {{"god","N",4,0},;
                   {"tit1name","C",130,0},;
                   {"tit2name","C",130,0},;
                   {"tit3name","C",130,0},;
                   {"tit4name","C",130,0}})
R_Use(dir_server+"organiz",,"ORG")
add_string(alltrim(org->name))
use (fr_titl) new
append blank
replace tit1name with alltrim(org->name)
replace tit2name with alltrim(arr_m[4])
if tip_f39 == 1 //по врачу
  replace tit3name with alltrim(glob_human[2])
endif
t := ""
if ascan(krvz,1) > 0
  t:= "ОМС"
endif
if ascan(krvz,3) > 0
  t += " + Платные услуги"
endif
replace tit4name with t
close databases
call_fr("mo_stt39.fr3")
return NIL


*


***** проверить больного по БД human и вернуть результат в виде массива
Static Function yes_f_39t(par1,vozrast,vrach)
Local i, j, k, s, arr, ret, t_human := .T., t_select
Private t_mas := array(65), lp := array(60)
Private mdate_r, m1vzros_reb := 0, t_vrach := vrach
arr := {}
// проходим по услугам
select HU
t_human := .T.
find (str(human->(recno()),6))
do while hu->kod == human->(recno()) .and. !eof()
  if iif(vrach== 1,glob_human[1] == hu->kod_vr,.T.)
    if iif(Pi1==1,.T.,hu->date_u==Pi1_DATE)
      select HU_
      goto (hu->(recno()))
      select DIAG
      find (alltrim(hu_->kod_diag)+" ")
      if found()
        mas_diag := {}
        TMP_DIAG := diag->(recno())
        aadd(mas_diag,TMP_DIAG)
      endif
      select HU
  //
      k := hu->kol
      afill(lp,0)
      ___f_39t(k)
      if vozrast == 1
        mdate_r := human->date_r
        fv_date_r(,.f.)
      else

      endif
      t_select := select()
      select KARTOTE_
      goto human->kod_k
      select KARTOTE_
      if substr(kartote_->okatog,1,3)=="184"
        lp[3] := 0
      endif
      if m1vzros_reb == 0 //взрослые
//        lp[1] := lp[3]
//        lp[4] := lp[6]
      else
//        lp[2] := lp[3]
//        lp[5] := lp[6]
      endif

      //УЕТ
      lp[56] := opr_uet(m1vzros_reb)*k
      //
     // if lp[37]
        //РЕЗУЛЬТАТ
        aadd(arr,aclone(lp))
     // endif
    endif
  endif
  select HU
  skip
enddo
if len(arr) > 0
  // проверяем второй список
  ret := arr
endif
return ret


*

*****
Function ___f_39t(k)
Local _1,_2, t_rec, t_flag, t_kart, t_date, tt1 := 0, tt2:= 0, tt3 := 0, tt4 := 0,;
      tt5 := 0, tt6 := 0
   t_rec := hu->(recno())

  for j := 1 to 56 //56
    t := "au"+lstr(j)
    t1 := &t
    _1 := (ascan(&t,{|x| x[2] == hu->u_kod}) > 0)
    tt1 := _1
    if _1
      if j < 56
        if len(alltrim(hu_->zf)) == 2
          lp[j]  := 1
        elseif len(alltrim(hu_->zf)) > 2
          lp[j]  := 2
        else
          lp[j]  := k
        endif
      endif

    endif
    // проверяем второй список
    // делаем цикл по всему случаю
    tt := "aud"+lstr(j)
    t2 := &tt
    t_flag := .F.
    if len(&tt) > 0
      //если ответ отрицательный - нулируем предыдущий результат
      t_flag := .T.
      t_rec := hu->(recno())
      find (str(human->(recno()),6))
      do while hu->kod == human->(recno()) .and. !eof()
        if iif(t_vrach== 1,glob_human[1] == hu->kod_vr,.T.)
          _2 := (ascan(&tt,{|x| x[2] == hu->u_kod}) > 0)
          tt4 := _2
          if _2
            t_flag := .F.
          endif
        endif
        skip
      enddo
      // проверка по ПЛАТНЫМ внутри ОМС
    /*  if ascan(krvz,3) > 0 .and. ascan(krvz,1) > 0
        //@ 10,20 say  human->kod_k
        //inkey(0)
        select HUMAN
        t_kart := human->kod_k
        // по дате окончания лечения
        if Pi1 == 1 //по дате окончания лечения
          t_date := human->k_data
        else // по дате услуги
          t_date := c4tod(Pi1_DATE)
        endif
        select PHUMAN
        find (str(t_kart,6)+dtos(t_date))
        // перебираем случаи
        do while phuman->kod_k == t_kart .and.;
                 phuman->k_data == t_date .and. !eof()
          select PHU
          // перебираем услуги
          //t_rec := hu->(recno())
          find (str(phuman->(recno()),6))
          do while phu->kod == phuman->(recno()) .and. !eof()
            if iif(t_vrach== 1,glob_human[1] == phu->kod_vr,.T.)
              _2 := (ascan(&tt,{|x| x[2] == phu->u_kod}) > 0)
              if _2
                t_flag := .F.
              endif
            endif
            skip
          enddo
          select PHUMAN
          skip
        enddo
      endif
      */
      // конец проверки ОМС
      tt2 := t_flag

      if t_flag
        if j < 56
          lp[j]  := 0
        endif
      endif
      hu->(dbgoto(t_rec))
    endif
    // проверяем третий список - ДИАГНОЗЫ
    ttt := "auz"+lstr(j)
    t3 := &ttt
    if len(&ttt) > 0
      //если ответ отрицательный - нулируем предыдущий результат
      // у нас есть масси диагнозов
      for ll := 1 to len(mas_diag)
        _3 := (ascan(&ttt,{|x| x[2] == mas_diag[ll]}) > 0)
        tt3 := _3

        if _3
         exit
        else
          if j < 56
            lp[j]  := 0
          endif
        endif
      next
    endif
    // проверяем на дублирование зубной формулы
    if j > 11 .and. j < 24

    endif
  next
return NIL
