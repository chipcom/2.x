#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 07.09.22 амбулаторная медицинская реабилитация - добавление или редактирование случая (листа учета)
function oms_sluch_MED_REAB(Loc_kod, kod_kartotek, f_print)
  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  // f_print - наименование функции для печати

  Static skod_diag := '     ', st_n_data, st_k_data, ;
    st_vrach := 0, st_rslt := 0, st_ishod := 0

  local str_1
  local j // счетчик строк экрана
  Local bg := {|o, k| get_MKB10(o, k, .t.) }, ;
    buf, tmp_color := setcolor(), a_smert := {},;
    p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    fl_write_sluch := .f., when_uch_doc := .t.
  local tlist_rslt, list_rslt := {}, list_ishod, row
  local aReab, sArr := ''

  Default st_n_data TO sys_date, st_k_data TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0

///++++ 
  buf := savescreen()

  Private mm_rslt, mm_ishod, rslt_umolch := 0, ishod_umolch := 0, ;
    m1USL_OK := 3, mUSL_OK, ;    // только амбулаторно
    m1PROFIL := 158, mPROFIL     // медицинская реабилитация

  Private mkod := Loc_kod, ;
    mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
    mtip_h, ;
    m1lpu := glob_uch[1], mlpu, ;
    m1otd := glob_otd[1], motd, ;
    mfio := space(50), mpol, mdate_r, madres, mmr_dol, ;
    m1fio_kart := 1, mfio_kart, ;
    m1vzros_reb, mvzros_reb, mpolis, m1rab_nerab, ;
    much_doc    := space(10)         ,; // вид и номер учетного документа
    m1npr_mo := '', mnpr_mo := space(10), mnpr_date := ctod(''), ;
    mkod_diag   := skod_diag         , ; // шифр 1-ой осн.болезни
    mrslt, m1rslt := st_rslt         , ; // результат
    mishod, m1ishod := st_ishod      , ; // исход
    m1company := 0, mcompany, mm_company, ;
    mkomu, m1komu := 0, m1str_crb := 0, ; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
    m1reg_lech := 0, mreg_lech, ;
    mn_data     := st_n_data         , ; // дата начала лечения
    mk_data     := st_k_data         , ; // дата окончания лечения
    MCENA_1     := 0                 , ; // стоимость лечения
    MVRACH      := space(10)         , ; // фамилия и инициалы лечащего врача
    M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
    msmo := '', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := space(100), ;
    mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20), ;
    mvidreab, m1vidreab := 0, ;           // реабилитация по заболеваниям
    mshrm, m1shrm := 0                    // Шкала Реабилитационной Маршрутизации

  private ;                   // для совместимости
    MKOD_DIAG0  := space(6), ; // шифр первичного диагноза
    MKOD_DIAG2  := space(5), ; // шифр 2-ой осн.болезни
    MKOD_DIAG3  := space(5), ; // шифр 3-ой осн.болезни
    MKOD_DIAG4  := space(5), ; // шифр 4-ой осн.болезни
    MSOPUT_B1   := space(5), ; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := space(5), ; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := space(5), ; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := space(5), ; // шифр 4-ой сопутствующей болезни
    MDIAG_PLUS  := space(8), ; // дополнения к диагнозам
    MOSL1       := SPACE(6), ; // шифр 1-ого диагноза осложнения заболевания
    MOSL2       := SPACE(6), ; // шифр 2-ого диагноза осложнения заболевания
    MOSL3       := SPACE(6)    // шифр 3-ого диагноза осложнения заболевания

///----    

  ///++++  
  R_Use(dir_server + 'human_2', , 'HUMAN_2')
  R_Use(dir_server + 'human_', , 'HUMAN_')
  R_Use(dir_server + 'human', , 'HUMAN')
  set relation to recno() into HUMAN_, to recno() into HUMAN_2
  if mkod_k > 0
    R_Use(dir_server + 'kartote2', , 'KART2')
    goto (mkod_k)
    R_Use(dir_server + 'kartote_', , 'KART_')
    goto (mkod_k)
    R_Use(dir_server + 'kartotek', , 'KART')
    goto (mkod_k)
    M1FIO       := 1
    mfio        := kart->fio
    mpol        := kart->pol
    mdate_r     := kart->date_r
    M1VZROS_REB := kart->VZROS_REB
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
    msmo        := kart_->SMO
    if kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    endif
    if eq_any(is_uchastok, 1, 3)
      much_doc := padr(amb_kartaN(), 10)
    elseif mem_kodkrt == 2
      much_doc := padr(lstr(mkod_k), 10)
    endif
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(1, , .t.) // открыть и закрыть
    endif

    // проверка исхода = СМЕРТЬ
    select HUMAN
    set index to (dir_server + 'humankk')
    find (str(mkod_k, 7))
    do while human->kod_k == mkod_k .and. !eof()
      if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
                                 human_->oplata != 9 .and. human_->NOVOR == 0
        a_smert := {'Данный больной умер!', ;
          'Лечение с ' + full_date(human->N_DATA) + ' по ' + full_date(human->K_DATA)}
        exit
      endif
      skip
    enddo
    set index to
  endif

  if Loc_kod > 0
    select HUMAN
    goto (Loc_kod)
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    mfio        := human->fio
    mpol        := human->pol
    mdate_r     := human->date_r
    MTIP_H      := human->tip_h
    M1VZROS_REB := human->VZROS_REB
    MADRES      := human->ADRES         // адрес больного
    MMR_DOL     := human->MR_DOL        // место работы или причина безработности
    M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий
    much_doc    := human->uch_doc
    m1reg_lech  := human->reg_lech
    m1VRACH     := human_->vrach
    MKOD_DIAG   := human->KOD_DIAG
    MPOLIS      := human->POLIS         // серия и номер страхового полиса

    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    if empty(val(msmo := human_->SMO))
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    else
      m1komu := m1str_crb := 0
    endif

    m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
    m1USL_OK   := human_->USL_OK
    m1PROFIL   := human_->PROFIL
    m1NPR_MO   := human_->NPR_MO
    mNPR_DATE  := human_2->NPR_DATE
    
    aReab      := list2arr(human_2->PC5)
    m1vidreab  := aReab[1]
    m1shrm     := aReab[2]
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW

    mcena_1 := human->CENA_1

    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2, @rec_inogSMO, .t.) // открыть и закрыть
    endif
  endif

  if !(left(msmo, 2) == '34') // не Волгоградская область
    m1ismo := msmo
    msmo := '34'
  endif

  if Loc_kod == 0
    R_Use(dir_server + 'mo_otd', , 'OTD')
    goto (m1otd)
  endif
  R_Use(dir_server + 'mo_uch', , 'UCH')
  goto (m1lpu)
  mlpu := rtrim(uch->name)

  if m1vrach > 0
    R_Use(dir_server + 'mo_pers', , 'P2')
    goto (m1vrach)
    MTAB_NOM := p2->tab_nom
    m1prvs := -ret_new_spec(p2->prvs, p2->prvs_new)
    mvrach := padr(fam_i_o(p2->fio) + ' ' + ret_tmp_prvs(m1prvs), 36)
  endif

  close databases

  tlist_rslt := getRSLT_usl_date(m1USL_OK, mk_data)
  for each row in tlist_rslt
    if between(row[2], 301, 315)
      aadd(list_rslt, row)
    endif
  next
  list_ishod := getISHOD_usl_date(m1USL_OK, mk_data)

  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  mUSL_OK   := inieditspr(A__MENUVERT, getV006(), m1USL_OK)

  mPROFIL   := inieditspr(A__MENUVERT, getV002(), m1PROFIL)
  if !empty(m1NPR_MO)
    mNPR_MO := ret_mo(m1NPR_MO)[_MO_SHORT_NAME]
  endif

  mvidreab  := inieditspr(A__MENUVERT, type_reabilitacia(), m1vidreab)
  mshrm     := inieditspr(A__MENUVERT, type_shrm_reabilitacia(), m1shrm)

  mrslt     := inieditspr(A__MENUVERT, list_rslt, m1rslt)
  mishod    := inieditspr(A__MENUVERT, list_ishod, m1ishod)

  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  motd      := inieditspr(A__POPUPMENU, dir_server + 'mo_otd', m1otd)
  mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mismo     := init_ismo(m1ismo)
  f_valid_komu(, -1)
  if m1komu == 0
    m1company := int(val(msmo))
  elseif eq_any(m1komu, 1, 3)
    m1company := m1str_crb
  endif
  mcompany  := inieditspr(A__MENUVERT, mm_company, m1company)
  if m1company == 34
    if !empty(mismo)
      mcompany := padr(mismo, 38)
    elseif !empty(mnameismo)
      mcompany := padr(mnameismo, 38)
    endif
  endif

///---
  str_1 := ' случая (листа учёта)'
  if Loc_kod == 0
    str_1 := 'Добавление'+str_1
    mtip_h := yes_vypisan
  else
    str_1 := 'Редактирование'+str_1
  endif
  pr_1_str(str_1)
  setcolor(color8)
  myclear(1)

  setcolor(cDataCGet)
  make_diagP(1)  // сделать 'шестизначные' диагнозы

  do while .t.
    pr_1_str(str_1)
    j := 1
    myclear(j)
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 say padl('Лист учета № ' + lstr(Loc_kod), 29) color color14
    endif

    diag_screen(0)
    pos_read := 0

    @ ++j, 1 say 'Учреждение' get mlpu when .f. color cDataCSay
    @ row(),col()+2 say 'Отделение' get motd when .f. color cDataCSay
    //
    @ ++j, 1 say 'ФИО' get mfio_kart ;
        reader {|x| menu_reader(x, {{|k, r, c| get_fio_kart(k, r, c)}}, A__FUNCTION, , , .f.)} ;
        valid {|g, o| update_get('mkomu'),update_get('mcompany'), ;
          update_get('mspolis'),update_get('mnpolis'), ;
          update_get('mvidpolis') }
    //
    @ ++j, 1 say 'Принадлежность счёта' get mkomu ;
      reader {|x|menu_reader(x, mm_komu, A__MENUVERT, , , .f.)} ;
      valid {|g, o| f_valid_komu(g, o) } ;
      color colget_menu
    @ row(), col() + 1 say '==>' get mcompany ;
      reader {|x|menu_reader(x, mm_company, A__MENUVERT, , , .f.)} ;
      when diag_screen(2) .and. m1komu < 5 ;
      valid {|g| func_valid_ismo(g, m1komu, 38) }
    //
    @ ++j, 1 say 'Полис ОМС: серия' get mspolis when m1komu == 0
    @ row(), col() + 3 say 'номер'  get mnpolis when m1komu == 0
    @ row(), col() + 3 say 'вид'    get mvidpolis ;
      reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)} ;
      when m1komu == 0 ;
      valid func_valid_polis(m1vidpolis, mspolis, mnpolis)

    ++j
    @ ++j, 1 say 'Направление: дата' get mnpr_date
    @ j, col() + 1 say 'из МО' get mnpr_mo ;
        reader {|x|menu_reader(x, {{|k, r, c| f_get_mo(k, r, c)}}, A__FUNCTION, , , .f.)} ;
        color colget_menu

    @ ++j, 1 say 'Сроки лечения' get mn_data valid {|g| f_k_data(g, 1)}
    @ row() ,col() + 1 say '-'   get mk_data valid {|g| f_k_data(g, 2)}
    @ row(), col() + 3 get mvzros_reb when .f. color cDataCSay

    ++j
    @ ++j,1 say '№ амб.карты (истории)' get much_doc picture '@!' ;
        when when_uch_doc

    @ row(), col() + 1 say 'Врач' get MTAB_NOM pict '99999' ;
        valid {|g| v_kart_vrach(g, .t.) } when diag_screen(2)
    @ row(), col() + 1 get mvrach when .f. color color14

    @ ++j, 1 say 'Основной диагноз' get mkod_diag picture pic_diag ;
        reader {|o| MyGetReader(o, bg)} ;
        when when_diag() ;
        valid {|| val1_10diag(.t., .t., .t., mk_data, mpol, .t.) }

    @ ++j, 1 say 'Профиль мед.помощи' get mprofil ;
        when .f. color cDataCSay ;
        valid {|| val1_10diag(.t., .t., .t., mk_data, mpol, .t.) }

    @ ++j, 1 say 'Вид реаблитации' get mvidreab ;
        reader {|x|menu_reader(x, type_reabilitacia(), A__MENUVERT, , , .f.)}

    @ ++j, 1 say 'Шкала Реабилитационной Маршрутизации' get mshrm ;
        reader {|x|menu_reader(x, type_shrm_reabilitacia(), A__MENUVERT, , , .f.)} ;
        when diag_screen(2) // очистим сообщение о диагнозе

    @ ++j, 1 say 'Результат обращения' get mrslt ;
        reader {|x|menu_reader(x, list_rslt, A__MENUVERT, , , .f.)} ;
        valid {|g, o| f_valid_rslt(g, o) }

    @ ++j, 1 say 'Исход заболевания' get mishod ;
        reader {|x|menu_reader(x, list_ishod, A__MENUVERT, , , .f.)}

    @ maxrow() - 1, 55 say 'Сумма лечения' color color1
    @ row(), col() + 1 say lput_kop(mcena_1) color color8

    if !empty(a_smert)
      n_message(a_smert, , 'GR+/R', 'W+/R', , , 'G+/R')
    endif

    @ maxrow(), 0 say padc('<Esc> - выход;  <PgDn> - запись;  <F1> - помощь', maxcol() + 1) color color0
    mark_keys({'<F1>', '<Esc>', '<PgDn>'}, 'R/BG')

    count_edit += myread(, @pos_read)

    k := f_alert({padc('Выберите действие', 60, '.')}, ;
      {' Выход без записи ', ' Запись ', ' Возврат в редактирование '}, ;
      iif(lastkey() == K_ESC, 1, 2), 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N,N/BG')

    if k == 3
      loop
    elseif k == 2
      // проверки и запись
      if m1vidreab == 0
        func_error(4, 'Не выбран вид реабилитации.')
        loop
      endif
      if m1shrm == 0
        func_error(4, 'Не выбрана шкала реабилитации.')
        loop
      endif
      if empty(mn_data)
        func_error(4, 'Не введена дата начала лечения.')
        loop
      endif
      if empty(mk_data)
        func_error(4, 'Не введена дата окончания лечения.')
        loop
      endif
      if empty(mkod_diag)
        func_error(4, 'Не введен шифр основного заболевания.')
        loop
      endif
      if empty(CHARREPL('0', much_doc, space(10)))
        func_error(4, 'Не заполнен номер амбулаторной карты (истории болезни)')
        loop
      endif
      if m1komu < 5 .and. empty(m1company)
        if m1komu == 0     ; s := 'СМО'
        elseif m1komu == 1 ; s := 'компании'
        else               ; s := 'комитета/МО'
        endif
        func_error(4, 'Не заполнено наименование '+s)
        loop
      endif
      if m1komu == 0 .and. empty(mnpolis)
        func_error(4, 'Не заполнен номер полиса')
        loop
      endif
      err_date_diap(mn_data, 'Дата начала лечения')
      err_date_diap(mk_data, 'Дата окончания лечения')
      restscreen(buf)
      if mem_op_out == 2 .and. yes_parol
        box_shadow(19, 10, 22, 69, cColorStMsg)
        str_center(20, 'Оператор "' + fio_polzovat + '".', cColorSt2Msg)
        str_center(21, 'Ввод данных за ' + date_month(sys_date), cColorStMsg)
      endif
      mywait('Ждите. Производится запись листа учёта ...')

      make_diagP(2)  // сделать "пятизначные" диагнозы
      Use_base('human')
      if Loc_kod > 0
        find (str(Loc_kod,7))
        mkod := Loc_kod
        G_RLock(forever)
      else
        Add1Rec(7)
        mkod := recno()
        replace human->kod with mkod
      endif
      select HUMAN_
      do while human_->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      //
      select HUMAN_2
      do while human_2->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)

      if isbit(mem_oms_pole,1)  //  "сроки лечения",;  1
        st_N_DATA := MN_DATA
        st_K_DATA := MK_DATA
      endif
      if isbit(mem_oms_pole,2)  //  "леч.врач",;       2
        st_VRACH := m1vrach
      endif
      if isbit(mem_oms_pole,3)  //  "осн.диагноз",;    3
        SKOD_DIAG := substr(MKOD_DIAG,1,5)
      endif
      if isbit(mem_oms_pole,5)  //  "результат",;      5
        st_RSLT := m1rslt
      endif
      if isbit(mem_oms_pole,6)  //  "исход",;          6
        st_ISHOD := m1ishod
      endif

      glob_perso := mkod
      if m1komu == 0
        msmo := lstr(m1company)
        m1str_crb := 0
      else
        msmo := ""
        m1str_crb := m1company
      endif
      //
      human->kod_k      := glob_kartotek
      human->TIP_H      := mtip_h
      human->FIO        := MFIO          // Ф.И.О. больного
      human->POL        := MPOL          // пол
      human->DATE_R     := MDATE_R       // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
      human->ADRES      := MADRES        // адрес больного
      human->MR_DOL     := MMR_DOL       // место работы или причина безработности
      human->RAB_NERAB  := M1RAB_NERAB   // 0-работающий, 1-неработающий
      human->KOD_DIAG   := MKOD_DIAG     // шифр 1-ой осн.болезни
      human->KOMU       := M1KOMU        // от 0 до 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
      human->LPU        := M1LPU         // код учреждения
      human->OTD        := M1OTD         // код отделения
      human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
      human->N_DATA     := MN_DATA       // дата начала лечения
      human->K_DATA     := MK_DATA       // дата окончания лечения
      human->CENA       := MCENA_1       // стоимость лечения
      human->CENA_1     := MCENA_1       // стоимость лечения

      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := ltrim(mspolis)
      human_->NPOLIS    := ltrim(mnpolis)
      human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
      human_->USL_OK    := m1USL_OK
      human_->PROFIL    := m1PROFIL
      human_->NPR_MO    := m1NPR_MO
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      if Loc_kod == 0  // при добавлении
        human_->ID_PAC    := mo_guid(1, human_->(recno()))
        human_->ID_C      := mo_guid(2, human_->(recno()))
        human_->SUMP      := 0
        human_->SANK_MEK  := 0
        human_->SANK_MEE  := 0
        human_->SANK_EKMP := 0
        human_->REESTR    := 0
        human_->REES_ZAP  := 0
        human->schet      := 0
        human_->SCHET_ZAP := 0
        human->kod_p   := kod_polzovat    // код оператора
        human->date_e  := c4sys_date
      else // при редактированиии
        human_->kod_p2  := kod_polzovat    // код оператора
        human_->date_e2 := c4sys_date
      endif
      human_2->NPR_DATE := mNPR_DATE
      human_2->PC5    := arr2list({m1vidreab, m1shrm}, .t.)

      Private fl_nameismo := .f.
      if m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ОКАТО субъекта РФ территории страхования
        if empty(m1ismo)
          if !empty(mnameismo)
            fl_nameismo := .t.
          endif
        else
          human_->SMO := m1ismo  // заменяем "34" на код иногородней СМО
        endif
      endif
      if fl_nameismo .or. rec_inogSMO > 0
        G_Use(dir_server + 'mo_hismo', , 'SN')
        index on str(kod, 7) to (cur_dir + 'tmp_ismo')
        find (str(mkod, 7))
        if found()
          if fl_nameismo
            G_RLock(forever)
            sn->smo_name := mnameismo
          else
            DeleteRec(.t.)
          endif
        else
          if fl_nameismo
            AddRec(7)
            sn->kod := mkod
            sn->smo_name := mnameismo
          endif
        endif
      endif
      write_work_oper(glob_task, OPER_LIST, iif(Loc_kod==0, 1, 2), 1, count_edit)
      fl_write_sluch := .t.
      close databases
      stat_msg('Запись завершена!', .f.)
    endif
    exit
  enddo
  close databases
  diag_screen(2)
  setcolor(tmp_color)
  restscreen(buf)

  if fl_write_sluch // если записали
    defenition_usluga_med_reab(mkod, m1vidreab, m1shrm)
    if type('fl_edit_oper') == 'L' // если находимся в режиме добавления случая
      fl_edit_oper := .t.  // проверку запустим при выходе из набивания услуг
    else // иначе запускаем проверку
      if (mcena_1 > 0) .and. !empty(val(msmo))
        verify_OMS_sluch(glob_perso)
      endif
    endif
  endif

  // if !empty(f_print)
  //   return &(f_print + '(' + lstr(Loc_kod) + ',' + lstr(kod_kartotek) + ')')
  // endif
  return nil

