#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 03.02.15
Function f_d_dializ()
  if !(left(dtos(mn_data), 6) == left(dtos(mk_data), 6))
    func_error(4, 'Даты начала и окончания процедур не в одном отчётном месяце.')
  endif
  return .t.
  
// 16.02.24 гемодиализ (1) и перитонеальный диализ (2)
Function oms_sluch_dializ(par, Loc_kod, kod_kartotek)
  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  Static SKOD_DIAG := 'N18.5', st_N_DATA, st_K_DATA, st_vrach := 0
  // Local top2 := {2, 11}[par]
  // Local top2 := {1, 11}[par]
  Local top2 := {1, 7}[par]
  Local bg := {|o, k| get_MKB10(o, k, .t.)}, ;
        buf := savescreen(), tmp_color := setcolor(), a_smert := {}, ;
        p_uch_doc := '@!', pic_diag := '@K@!', ;
        i, d, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
        pos_read := 0, k_read := 0, count_edit := 0, arr_usl, fl, ss, ;
        tmp_help := chm_help_code, fl_write_sluch := .f.
  Static kod_ksg := 'ds18.002', arr_lek := { ;
        {'A25.28.001.001', 'препараты железа'}, ;
        {'A25.28.001.002', 'антианемические препараты (стимуляторы эритропоэза)'}, ;
        {'A25.28.001.003', 'антипаратиреоидные препараты'}, ;
        {'A25.28.001.004', 'препараты витамина D и его аналогов'}, ;
        {'A25.28.001.005', 'препараты аминокислот, включая комбинации с полипептидами'}, ;
        {'A25.28.001.006', 'препараты для лечения гиперкальциемии, гиперкалиемии и гиперфосфатемии'}}
  //
  Default st_N_DATA TO bom(sys_date), st_K_DATA TO eom(sys_date)
  Private ;
    mkol_proc := 0, mkol_proc1 := 0, mkol_proc2 := 0, mkol_proc3 := 0, ; // кол-во процедур диализа разного вида
    mkol_proc4 := 0, mkol_proc5 := 0, mkol_proc6 := 0, ;
    MFIO        := space(50)         , ; // Ф.И.О. больного
    mfam := space(40), mim := space(40), mot := space(40), ;
    mpol        := 'М'            , ;
    mdate_r     := boy(addmonth(sys_date, -12 * 30)) , ;
    MVZROS_REB, M1VZROS_REB := 0, ;
    MADRES      := space(50)         , ; // адрес больного
    m1MEST_INOG := 0, newMEST_INOG := 0, ;
    MVID_UD                          , ; // вид удостоверения
    M1VID_UD    := 14                , ; // 1-18
    mser_ud := space(10), mnom_ud := space(20), ;
    mspolis := space(10), mnpolis := space(20), msmo := '34007', ;
    mnamesmo, m1namesmo, ;
    m1company := 0, mcompany, mm_company, ;
    m1KOMU := 0, MKOMU, M1STR_CRB := 0, ;
    mvidpolis, m1vidpolis := 1, ;
    msnils := space(11), ;
    mokatog := padr(alltrim(okato_umolch), 11, '0'), ;
    m1adres_reg := 1, madres_reg, ;
    rec_inogSMO := 0, ;
    mkol[6], musl_lek[6], ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := space(100)
  afill(mkol, 0)
  afill(musl_lek, 0)
  //
  Private mkod := Loc_kod, mtip_h, is_talon := .f., ;
    mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
    M1LPU := glob_uch[1], MLPU, ;
    M1OTD := glob_otd[1], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MUCH_DOC    := space(10)         , ; // вид и номер учетного документа
    MKOD_DIAG   := SKOD_DIAG         , ; // шифр 1-ой осн.болезни
    MKOD_DIAG2  := space(5)          , ; // шифр 2-ой осн.болезни
    MKOD_DIAG3  := space(5)          , ; // шифр 3-ой осн.болезни
    MKOD_DIAG4  := space(5)          , ; // шифр 4-ой осн.болезни
    MSOPUT_B1   := space(5)          , ; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := space(5)          , ; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := space(5)          , ; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := space(5)          , ; // шифр 4-ой сопутствующей болезни
    MDIAG_PLUS  := space(8)          , ; // дополнения к диагнозам
    mrslt, m1rslt := 0         , ; // результат
    mishod, m1ishod := 0      , ; // исход
    MN_DATA     := st_N_DATA         , ; // дата начала лечения
    MK_DATA     := st_K_DATA         , ; // дата окончания лечения
    MVRACH      := space(10)         , ; // фамилия и инициалы лечащего врача
    M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
    m1novor := 0, mnovor, mcount_reb := 0, ldnej := 0, ;
    mDATE_R2 := ctod(''), mpol2 := ' ', ;
    m1USL_OK, m1PROFIL := 56, m1PROFIL_K := 41 // НЕФРОЛОГИЯ
  //
  Private mm_rslt := {}, mm_ishod := {}
  if par == 1 // гемодиализ (1)
    m1USL_OK := USL_OK_DAY_HOSPITAL
    aeval(getV009(), {|x| iif(x[5] == m1usl_ok, aadd(mm_rslt, x), nil)})
    m1rslt := 201
    m1ishod := 203
  else // перитонеальный диализ (2)
    m1USL_OK := USL_OK_POLYCLINIC
    aeval(getV009(), {|x| iif(x[5] == m1usl_ok .and. x[2] < 316, aadd(mm_rslt, x), nil)})
    m1rslt := 314
    m1ishod := 304
  endif
  aeval(getV012(), {|x| iif(x[5] == m1usl_ok, aadd(mm_ishod, x), nil)})
  //
  R_Use(dir_server + 'kartote_', , 'KART_')
  goto (kod_kartotek)
  R_Use(dir_server + 'kartotek', , 'KART')
  goto (kod_kartotek)
  mFIO        := kart->FIO
  mpol        := kart->pol
  mDATE_R     := kart->DATE_R
  m1VZROS_REB := kart->VZROS_REB
  mADRES      := kart->ADRES
  msnils      := kart->snils
  if kart->MI_GIT == 9
    m1KOMU    := kart->KOMU
    M1STR_CRB := kart->STR_CRB
  endif
  if kart->MEST_INOG == 9 // т.е. отдельно занесены Ф.И.О.
    m1MEST_INOG := kart->MEST_INOG
  endif
  m1vidpolis  := kart_->VPOLIS // вид полиса (от 1 до 3);1-старый, 2-врем., 3-новый
  mspolis     := kart_->SPOLIS // серия полиса
  mnpolis     := kart_->NPOLIS // номер полиса
  msmo        := kart_->SMO    // реестровый номер СМО
  m1vid_ud    := kart_->vid_ud   // вид удостоверения личности
  mser_ud     := kart_->ser_ud   // серия удостоверения личности
  mnom_ud     := kart_->nom_ud   // номер удостоверения личности
  mokatog     := kart_->okatog       // код места жительства по ОКАТО
  m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
  //
  arr := retFamImOt(1, .f.)
  mfam := padr(arr[1], 40)
  mim  := padr(arr[2], 40)
  mot  := padr(arr[3], 40)
  if alltrim(msmo) == '34'
    mnameismo := ret_inogSMO_name(1, @rec_inogSMO)
  elseif left(msmo, 2) == '34'
    // Волгоградская область
  elseif !empty(msmo)
    m1ismo := msmo ; msmo := '34'
  endif
  if eq_any(is_uchastok, 1, 3)
    MUCH_DOC := padr(amb_kartaN(), 10)
  elseif mem_kodkrt == 2
    MUCH_DOC := padr(lstr(mkod_k), 10)
  endif
  close databases
  chm_help_code := 3002
  //
  R_Use(dir_server + 'human_', , 'HUMAN_')
  R_Use(dir_server + 'human', dir_server + 'humankk', 'HUMAN')
  set relation to recno() into HUMAN_
  // проверка исхода = СМЕРТЬ
  find (str(mkod_k, 7))
  do while human->kod_k == mkod_k .and. !eof()
    if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
                                 human_->oplata != 9 .and. human_->NOVOR == 0
      a_smert := {'Данный больной умер!', ;
                  'Лечение с ' + full_date(human->N_DATA) +;
                        ' по ' + full_date(human->K_DATA)}
      exit
    endif
    skip
  enddo
  if !(left(msmo, 2) == '34') // не Волгоградская область
    m1ismo := msmo
    msmo := '34'
  endif
  if m1vrach > 0
    R_Use(dir_server + 'mo_pers', , 'P2')
    goto (m1vrach)
    MTAB_NOM := p2->tab_nom
    m1prvs := -ret_new_spec(p2->prvs, p2->prvs_new)
    mvrach := padr(fam_i_o(p2->fio) + ' ' + ret_tmp_prvs(m1prvs), 36)
  endif
  close databases
  fv_date_r(iif(Loc_kod>0, mn_data, ))
  MFIO_KART := _f_fio_kart()
  mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  mrslt     := inieditspr(A__MENUVERT, mm_rslt, m1rslt)
  mishod    := inieditspr(A__MENUVERT, mm_ishod, m1ishod)
  mlpu      := inieditspr(A__POPUPMENU, dir_server + 'mo_uch', m1lpu)
  motd      := inieditspr(A__POPUPMENU, dir_server + 'mo_otd', m1otd)
  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mismo     := init_ismo(m1ismo)
  f_valid_komu( , -1)
  if m1komu == 0
    m1company := int(val(msmo))
  elseif eq_any(m1komu, 1, 3)
    m1company := m1str_crb
  endif
  mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
  if m1company == 34
    if !empty(mismo)
      mcompany := padr(mismo, 38)
    elseif !empty(mnameismo)
      mcompany := padr(mnameismo, 38)
    endif
  endif
  str_1 := iif(par == 1, 'гемодиализа', 'перитонеального диализа') + ' за месяц'
  if Loc_kod == 0
    str_1 := 'Добавление ' + str_1
    mtip_h := yes_vypisan
  else
    str_1 := 'Редактирование ' + str_1
  endif
  setcolor(color8)
  myclear(top2)

  // SetMode(26, 80)

  @ top2 - 1, 0 say padc(str_1, 80) color 'B/BG*'
  Private gl_area := {1, 0, maxrow() - 1, maxcol(), 0}
  status_key('^<Esc>^ - выход  ^<PgDn>^ - запись листов учёта')
  setcolor(cDataCGet)
  make_diagP(1)  // сделать 'шестизначные' диагнозы
  Private row_diag_screen := 9
  diag_screen(0)
  do while .t.
    j := top2
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 say padl('Лист учета № ' + lstr(Loc_kod), 29) color color14
    endif
    //
    @ ++j, 1 say 'Учреждение' get mlpu when .f. color cDataCSay
    @ row(), col() + 2 say 'Отделение' get motd when .f. color cDataCSay
    //
    @ ++j, 1 say 'ФИО' get mfio_kart ;
        reader {|x| menu_reader(x, {{|k, r, c| get_fio_kart(k, r, c)}}, A__FUNCTION, , , .f.)} ;
        valid {|g, o| update_get('mkomu'), update_get('mcompany')}
    //
    @ ++j, 1 say 'Принадлежность счёта' get mkomu ;
        reader {|x|menu_reader(x, mm_komu, A__MENUVERT, , , .f.)} ;
        valid {|g, o| f_valid_komu(g, o)} ;
        color colget_menu
    @ row(), col() + 1 say '==>' get mcompany ;
        reader {|x|menu_reader(x, mm_company, A__MENUVERT, , , .f.)} ;
        when diag_screen(2) .and. m1komu < 5 ;
        valid {|g| func_valid_ismo(g, m1komu, 38)}
    //
    @ ++j, 1 say 'Полис ОМС: серия' get mspolis when m1komu == 0
    @ row(), col() + 3 say 'номер'  get mnpolis when m1komu == 0
    @ row(), col() + 3 say 'вид'    get mvidpolis ;
        reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)} ;
        when diag_screen(2) .and. m1komu == 0 ;
        valid func_valid_polis(m1vidpolis, mspolis, mnpolis)
    //
    @ ++j, 1 say 'Основной диагноз' get mkod_diag picture pic_diag when .f. //reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t., mn_data,iif(m1novor==0, mpol, mpol2))
    @ row(), col() say ', соп.диагноз' get mkod_diag2 picture pic_diag reader {|o|MyGetReader(o, bg)} when when_diag() valid val1_10diag(.t., .t., .t., mn_data,iif(m1novor == 0, mpol, mpol2))
    //
    @ ++j, 1 say '№ амб.карты' get much_doc picture '@!' ;
        when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
          .or. mem_edit_ist == 2
          //   !(    У23/12356     и есть 'Регистратура')
    @ row(), col() + 1 say 'Врач' get MTAB_NOM pict '99999' ;
        valid {|g| v_kart_vrach(g, .t.)} when diag_screen(2)
    @ row(), col() + 1 get mvrach when .f. color color14
    //
    @ ++j, 1 say 'Диализ проводился с' get mn_data valid {|g| f_d_dializ()}
    @ row(), col() + 1 say 'по' get mk_data valid {|g| f_d_dializ()}
    //
    if par == 1
      @ ++j, 1 say 'Количество процедур лекарственной терапии:'
      for i := 1 to 6
        @ ++j, 2 say arr_lek[i, 1] get mkol[i] pict '99'
        @ j, col() + 1 say arr_lek[i, 2]
      next
      @ ++j, 1 say 'Количество НИЗКОпоточных процедур' get mkol_proc pict '99'
      @ ++j, 1 say 'Количество ВЫСОКОпоточных процедур' get mkol_proc1 pict '99'
      if m1USL_OK == USL_OK_DAY_HOSPITAL
        @ ++j, 1 say 'Гемодиафильтрация (A18.05.011)' get mkol_proc2 pict '99'
      endif
      // @ ++j, 1 say 'Количество диализов при нарушении ультрафильтрации (А18.30.001.003)' get mkol_proc3 pict '99'
      if m1USL_OK == USL_OK_HOSPITAL
        @ ++j, 1 say 'Количество дней обмена перитонеального диализа (A18.30.001)' get mkol_proc4 pict '99'
        @ ++j, 1 say 'Количество диализов с автоматизированными технологиями (А18.30.001.002)' get mkol_proc5 pict '99'
        @ ++j, 1 say 'Количество диализов при нарушении ультрафильтрации (А18.30.001.003)' get mkol_proc6 pict '99'
      endif
    elseif par == 2
      @ ++j, 1 say 'Количество дней обмена перитонеального диализа (A18.30.001)' get mkol_proc4 pict '99'
      @ ++j, 1 say 'Количество диализов с автоматизированными технологиями (А18.30.001.002)' get mkol_proc5 pict '99'
      @ ++j, 1 say 'Количество диализов при нарушении ультрафильтрации (А18.30.001.003)' get mkol_proc6 pict '99'
    endif
    @ ++j, 1 say 'Результат обращения' get mrslt ;
        reader {|x|menu_reader(x, mm_rslt, A__MENUVERT, , , .f.)} ;
        valid {|g, o| f_valid_rslt(g, o)}
    //
    @ ++j, 1 say 'Исход заболевания' get mishod ;
        reader {|x|menu_reader(x, mm_ishod, A__MENUVERT, , , .f.)}
    if !empty(a_smert)
      n_message(a_smert, , 'GR+/R', 'W+/R', , , 'G+/R')
    endif
    if pos_read > 0 .and. lower(GetList[pos_read]:name) == 'mishod'
      --pos_read
    endif
    count_edit := myread(, @pos_read, ++k_read)
    diag_screen(2)
    k := f_alert({padc('Выберите действие', 60, '.')}, ;
                 {' Выход без записи ', ' Запись ', ' Возврат в редактирование '}, ;
                 iif(lastkey() == K_ESC, 1, 2), 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N,N/BG' )
    if k == 3
      loop
    elseif k == 2
      if empty(mn_data)
        func_error(4, 'Не введена дата начала процедур.')
        loop
      endif
      if empty(mk_data)
        func_error(4, 'Не введена дата окончания процедур.')
        loop
      elseif year(mk_data) < 2018
        func_error(4, 'Данный режим работает только с 2018 года.')
        loop
      endif
      if mk_data < mn_data
        func_error(4, 'Дата окончания меньше даты начала процедур.')
        loop
      endif
      if !(left(dtos(mn_data), 6) == left(dtos(mk_data), 6))
        func_error(4, 'Даты начала и окончания процедур не в одном отчётном месяце.')
        loop
      endif
      ldnej := mk_data - mn_data + 1
      vlek := vdial := 0
      if par == 1
        if empty(vdial := mkol_proc + mkol_proc1 + mkol_proc2 + mkol_proc3 + mkol_proc4 + mkol_proc5 + mkol_proc6)
          func_error(4, 'Количество процедур гемодиализа равно нулю')
          loop
        elseif mkol_proc + mkol_proc1 + mkol_proc2 + mkol_proc3 + mkol_proc4 + mkol_proc5 + mkol_proc6 > ldnej
          func_error(4, 'Количество процедур гемодиализа больше длительности лечения')
          loop
        endif
        vlek := 0
        for i := 1 to 6
          vlek += mkol[i]
        next
        if vlek > 0
          if year(mk_data) == 2018
            func_error(4, 'Работа с лекарственными препаратами разрешена только с 2019 года.')
            loop
          elseif !(alltrim(mkod_diag) == 'N18.5')
            func_error(4, 'Для КСГ лекарственной терапии основной диагноз должен быть N18.5')
            loop
          endif
        endif
      endif
      if empty(CHARREPL('0', much_doc, space(10)))
        func_error(4, 'Не заполнен номер амбулаторной карты')
        loop
      endif
      if m1vrach == 0
        func_error(4, 'Не заполнен табельный номер лечащего врача')
        loop
      endif
      if m1komu < 5 .and. empty(m1company)
        if m1komu == 0
          s := 'СМО'
        elseif m1komu == 1
          s := 'компании'
        else
          s := 'комитета/МО'
        endif
        func_error(4, 'Не заполнено наименование ' + s)
        loop
      endif
      if m1komu == 0 .and. empty(mnpolis)
        func_error(4, 'Не заполнен номер полиса')
        loop
      endif
      if empty(mkod_diag)
        func_error(4, 'Не введен шифр основного заболевания.')
        loop
      endif
      err_date_diap(mn_data, 'Дата начала процедур')
      err_date_diap(mk_data, 'Дата окончания процедур')
      arr_usl := {}
      if par == 1
        if vlek > 0
          aadd(arr_usl, {'55.1.1', 0, 0, iif(vlek > vdial, vlek, vdial)})
        endif
        if mkol_proc > 0
          if mk_data >= 0d20240101
            aadd(arr_usl, {'60.3.19', 0, 0, mkol_proc})
          else
            aadd(arr_usl, {'60.3.9', 0, 0, mkol_proc})
          endif
        endif
        if mkol_proc1 > 0
          if mk_data >= 0d20240101
            aadd(arr_usl, {'60.3.20', 0, 0, mkol_proc1})
          else
            aadd(arr_usl, {'60.3.10', 0, 0, mkol_proc})
          endif
        endif
        if mkol_proc2 > 0
          if mk_data >= 0d20240101
            aadd(arr_usl, {'60.3.21', 0, 0, mkol_proc2})
          else
            aadd(arr_usl, {'60.3.11', 0, 0, mkol_proc2})
          endif
        endif
        if mkol_proc3 > 0
          aadd(arr_usl, {'60.3.13', 0, 0, mkol_proc3})
        endif
        if mkol_proc4 > 0
          aadd(arr_usl, {'60.3.14', 0, 0, mkol_proc4})
        endif
        if mkol_proc5 > 0
          aadd(arr_usl, {'60.3.15', 0, 0, mkol_proc5})
        endif
        if mkol_proc6 > 0
          aadd(arr_usl, {'60.3.16', 0, 0, mkol_proc6})
        endif
      else
        // aadd(arr_usl, {'60.3.1', 0, 0, ldnej})
        if mkol_proc4 > 0
          aadd(arr_usl, {'60.3.1', 0, 0, mkol_proc4})
        endif
        if mkol_proc5 > 0
          aadd(arr_usl, {'60.3.12', 0, 0, mkol_proc5})
        endif
        if mkol_proc6 > 0
          aadd(arr_usl, {'60.3.13', 0, 0, mkol_proc6})
        endif
      endif
      fv_date_r(mn_data) // переопределение M1VZROS_REB
      Use_base('lusl')
      Use_base('luslc')
      Use_base('uslugi')
      R_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1', ;
                                  dir_server + 'uslugi1s'}, 'USL1')
      glob_podr := ''
      glob_otd_dep := 0
      fl := .t.
      for i := 1 to len(arr_usl)
        arr_usl[i, 2] := foundOurUsluga(arr_usl[i, 1], mk_data, m1PROFIL, m1VZROS_REB, @arr_usl[i, 3])
        if empty(arr_usl[i, 2])
          fl := func_error(4, 'Цена на услугу ' + arr_usl[i, 1] + ' отсутствует в справочнике ТФОМС')
        endif
      next
      close databases
      if !fl
        loop
      endif
      k := f_alert({padc('Сейчас будет записан лист учёта. Выберите действие', 60, '.')}, ;
                   {' Выход без записи ', ' Запись ', ' Возврат в редактирование '}, ;
                   iif(lastkey() == K_ESC, 1, 2), 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N,N/BG' )
      if k == 3
        loop
      elseif k == 1
        exit
      endif
      if mem_op_out == 2 .and. yes_parol
        box_shadow(19, 10, 22, 69, cColorStMsg)
        str_center(20, 'Оператор "' + fio_polzovat + '".', cColorSt2Msg)
        str_center(21, 'Ввод данных за ' + date_month(sys_date), cColorStMsg)
      endif
      mywait()
      make_diagP(2)  // сделать 'пятизначные' диагнозы
      if m1komu == 0
        msmo := lstr(m1company)
        m1str_crb := 0
      else
        msmo := ''
        m1str_crb := m1company
      endif
      st_N_DATA := MN_DATA
      st_K_DATA := MK_DATA
      st_VRACH := m1vrach
      SKOD_DIAG := substr(MKOD_DIAG, 1, 5)
      Private mu_kod, mu_cena, fl_nameismo
      Use_base('lusl')
      Use_base('luslc')
      use_base('luslf')
      Use_base('mo_su')
      Use_base('uslugi')
      R_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1', ;
                                  dir_server + 'uslugi1s'}, 'USL1')
      G_Use(dir_server + 'mo_hismo', , 'SN')
      index on str(kod, 7) to (cur_dir + 'tmp_ismo')
      Use_base('mo_hu')
      use_base('human_u')
      Use_base('human')
      Add1Rec(7)
      mkod := recno()
      replace human->kod with mkod
      select HUMAN_
      do while human_->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      select HUMAN_2
      do while human_2->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      glob_perso := mkod
      //
      human->kod_k      := mkod_k
      human->TIP_H      := B_STANDART
      human->FIO        := MFIO          // Ф.И.О. больного
      human->POL        := MPOL          // пол
      human->DATE_R     := MDATE_R       // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
      human->ADRES      := MADRES        // адрес больного
      human->KOD_DIAG   := MKOD_DIAG     // шифр 1-ой осн.болезни
      human->KOD_DIAG2  := MKOD_DIAG2    // шифр 2-ой осн.болезни
      human->KOD_DIAG3  := MKOD_DIAG3    // шифр 3-ой осн.болезни
      human->KOD_DIAG4  := MKOD_DIAG4    // шифр 4-ой осн.болезни
      human->SOPUT_B1   := MSOPUT_B1     // шифр 1-ой сопутствующей болезни
      human->SOPUT_B2   := MSOPUT_B2     // шифр 2-ой сопутствующей болезни
      human->SOPUT_B3   := MSOPUT_B3     // шифр 3-ой сопутствующей болезни
      human->SOPUT_B4   := MSOPUT_B4     // шифр 4-ой сопутствующей болезни
      human->diag_plus  := mdiag_plus    //
      human->KOMU       := M1KOMU        // от 0 до 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis(mspolis, mnpolis) // серия и номер страхового полиса
      human->LPU        := M1LPU         // код учреждения
      human->OTD        := M1OTD         // код отделения
      human->UCH_DOC    := MUCH_DOC // вид и номер учетного документа
      human->N_DATA     := MN_DATA // дата начала лечения
      human->K_DATA     := MK_DATA // дата окончания лечения
      human->CENA := human->CENA_1 := 0 // стоимость лечения
      human_->DISPANS   := replicate('0', 16)
      human_->POVOD     := 1
      //human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := ltrim(mspolis)
      human_->NPOLIS    := ltrim(mnpolis)
      human_->OKATO     := '' // это поле вернётся из ТФОМС в случае иногороднего
      human_->NOVOR     := iif(m1novor==0, 0       , mcount_reb)
      human_->DATE_R2   := iif(m1novor==0, ctod(''), mDATE_R2  )
      human_->POL2      := iif(m1novor==0, ''      , mpol2     )
      human_->USL_OK    := m1USL_OK //
      human_->PROFIL    := m1PROFIL // 56
      human_->FORMA14   := '0000'
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // уберём '2', если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      human_->ID_PAC    := mo_guid(1,human_->(recno()))
      human_->ID_C      := mo_guid(2,human_->(recno()))
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
      put_0_human_2()
      human_2->PROFIL_K := m1PROFIL_K // 41
      fl_nameismo := .f.
      if m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ОКАТО субъекта РФ территории страхования
        if empty(m1ismo)
          if !empty(mnameismo)
            fl_nameismo := .t.
          endif
        else
          human_->SMO := m1ismo  // заменяем '34' на код иногородней СМО
        endif
      endif
      if fl_nameismo .or. rec_inogSMO > 0
        select SN
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
      ss := 0
      // записываем услуги
      for i := 1 to len(arr_usl)
        select HU
        Add1Rec(7)
        mrec_hu := hu->(recno())
        replace hu->kod     with mkod, ;
                hu->kod_vr  with m1vrach, ;
                hu->kod_as  with 0, ;
                hu->u_koef  with 1, ;
                hu->u_kod   with arr_usl[i, 2], ;
                hu->u_cena  with arr_usl[i, 3], ;
                hu->is_edit with 0, ;
                hu->date_u  with dtoc4(MN_DATA), ;
                hu->otd     with m1otd, ;
                hu->kol     with arr_usl[i, 4], ;
                hu->stoim   with arr_usl[i, 3] * arr_usl[i, 4], ;
                hu->kol_1   with arr_usl[i, 4], ;
                hu->stoim_1 with arr_usl[i, 3] * arr_usl[i, 4], ;
                hu->KOL_RCP with 0
        ss += arr_usl[i, 3] * arr_usl[i, 4]
        select HU_
        do while hu_->(lastrec()) < mrec_hu
          APPEND BLANK
        enddo
        goto (mrec_hu)
        G_RLock(forever)
        if Loc_kod == 0 .or. !valid_GUID(hu_->ID_U)
          hu_->ID_U := mo_guid(3, hu_->(recno()))
        endif
        hu_->PROFIL   := m1PROFIL
        hu_->PRVS     := m1PRVS
        hu_->kod_diag := mkod_diag
        hu_->zf       := ''
      next i
      if par == 1 .and. vlek > 0
        for i := 1 to len(arr_lek)
          if mkol[i] > 0
            mu_kod := append_shifr_mo_su(arr_lek[i, 1])
            select MOHU
            Add1Rec(7)
            mohu->kod     := mkod
            mohu->kod_vr  := m1vrach
            mohu->kod_as  := 0
            mohu->u_kod   := mu_kod
            mohu->u_cena  := 0
            mohu->date_u  := dtoc4(MN_DATA)
            mohu->otd     := m1otd
            mohu->kol_1   := mkol[i]
            mohu->stoim_1 := 0
            mohu->ID_U    := mo_guid(4, mohu->(recno()))
            mohu->PROFIL  := m1PROFIL
            mohu->PRVS    := m1PRVS
            mohu->kod_diag := mkod_diag
          endif
        next
      endif
      human->CENA := human->CENA_1 := ss // стоимость лечения
      write_work_oper(glob_task, OPER_LIST, iif(Loc_kod==0, 1, 2), 1, count_edit)
      fl_write_sluch := .t.
      close databases
      stat_msg('Запись завершена!', .f.)
      if par == 1 .and. vlek > 0
        f_1pac_definition_KSG(mkod)
      endif
    endif
    exit
  enddo
  close databases
  diag_screen(2)
  setcolor(tmp_color)
  restscreen(buf)
  chm_help_code := tmp_help
  // SetMode(25, 80)
  if fl_write_sluch // если записали - запускаем проверку
    verify_OMS_sluch(mkod)
  endif
  return nil
  