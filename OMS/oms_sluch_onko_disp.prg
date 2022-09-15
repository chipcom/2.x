#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** согласно письму ТФОМС 09-30-276 от 29.08.22 года

** 15.09.22 добавление или редактирование случая (листа учета)
function oms_sluch_ONKO_DISP(Loc_kod, kod_kartotek)
  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  static SKOD_DIAG := '     ', st_N_DATA, st_K_DATA, ;
    st_vrach := 0, st_profil := 0, st_profil_k := 0, ;
    st_rslt := 314, ; // динамическое наблюдение
    st_ishod := 304 // без перемен

  local bg := {|o, k| get_MKB10(o, k, .t.) }, ;
    buf, tmp_color := setcolor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    fl_write_sluch := .f., when_uch_doc := .t., ;
    arr_del := {}, mrec_hu := 0
  local mm_da_net := {{'нет', 0}, {'да ', 1}}
  local caption_window
  local top2, s
  local mtip_h
  local vozrast
  local lshifr := padr('2.5.2', 10)

  Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0
  if kod_kartotek == 0 // добавление в картотеку
    if (kod_kartotek := edit_kartotek(0, , ,.t.)) == 0
      return NIL
    endif
  endif
  buf := savescreen()
  if is_uchastok == 1 .and. is_task(X_REGIST) // У23/12356 и есть 'Регистратура'
    when_uch_doc := (mem_edit_ist == 2)
  endif
  //
  // ДЛЯ ПАЦИЕНТА ИЗ КАРТОТЕКИ
  Private mkod := Loc_kod,  ;
    mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
    mfio := space(50),  mpol, mdate_r, madres, mmr_dol, ;
    M1FIO_KART := 1, MFIO_KART, ;
    M1VZROS_REB, MVZROS_REB, mpolis, M1RAB_NERAB, ;
    MUCH_DOC    := space(10)         , ; // вид и номер учетного документа
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-ОМС, 1-компании, 3-комитеты/ЛПУ, 5-личный счет
    msmo := '34007',  rec_inogSMO := 0, ;
    mokato, m1okato := '',  mismo, m1ismo := '',  mnameismo := space(100), ;
    mvidpolis, m1vidpolis := 1, mspolis := space(10),  mnpolis := space(20)

  //
  Private tmp_V006 := create_classif_FFOMS(2, 'V006') // USL_OK
  Private tmp_V002 := create_classif_FFOMS(2, 'V002') // PROFIL
  Private tmp_V020 := create_classif_FFOMS(2, 'V020') // PROFIL_K
  Private tmp_V009 := cut_glob_array(glob_V009,sys_date) // rslt
  Private tmp_V012 := cut_glob_array(glob_V012,sys_date) // ishod

  Private mm_rslt, mm_ishod, rslt_umolch := 0, ishod_umolch := 0
  //
  Private ;
    M1LPU := glob_uch[1], MLPU, ;
    M1OTD := glob_otd[1], MOTD, ;
    MKOD_DIAG   := SKOD_DIAG         , ; // шифр 1-ой осн.болезни
    MKOD_DIAG0  := space(6)          , ; // шифр первичного диагноза
    MKOD_DIAG2  := space(5)          , ; // шифр 2-ой осн.болезни
    MKOD_DIAG3  := space(5)          , ; // шифр 3-ой осн.болезни
    MKOD_DIAG4  := space(5)          , ; // шифр 4-ой осн.болезни
    MSOPUT_B1   := space(5)          , ; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := space(5)          , ; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := space(5)          , ; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := space(5)          , ; // шифр 4-ой сопутствующей болезни
    MDIAG_PLUS  := space(8)          , ; // дополнения к диагнозам
    MOSL1 := SPACE(6)     , ; // шифр 1-ого диагноза осложнения заболевания
    MOSL2 := SPACE(6)     , ; // шифр 2-ого диагноза осложнения заболевания
    MOSL3 := SPACE(6)     , ; // шифр 3-ого диагноза осложнения заболевания
    mrslt, m1rslt := st_rslt         , ; // результат
    mishod, m1ishod := st_ishod      , ; // исход
    MN_DATA     := st_N_DATA         , ; // дата начала лечения
    MK_DATA     := st_K_DATA         , ; // дата окончания лечения
    MCENA_1     := 0                 , ; // стоимость лечения
    MVRACH      := space(10)         , ; // фамилия и инициалы лечащего врача
    M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
    m1USL_OK := 3, mUSL_OK, ;             // амбулаторно
    m1PROFIL := st_profil, mPROFIL, ;
    m1PROFIL_K := st_profil_k, mPROFIL_K, ;
    m1IDSP   := 29                        // за посещение

  Private mm_profil := {{'педиатрия', 68}, ;
    {'гематология', 12}, ;
    {'детская онкология', 18}, ;
    {'онкология', 60}, ;
    {'общей врачебной практики', 57}}

  //
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
      MUCH_DOC := padr(amb_kartaN(), 10)
    elseif mem_kodkrt == 2
      MUCH_DOC := padr(lstr(mkod_k), 10)
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
    MTIP_H      := human->tip_h
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    // будем брать из картотеки
    // mfio        := human->fio
    // mpol        := human->pol
    // mdate_r     := human->date_r
    // M1VZROS_REB := human->VZROS_REB
    // MADRES      := human->ADRES         // адрес больного
    // MMR_DOL     := human->MR_DOL        // место работы или причина безработности
    // M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий
    //
    mUCH_DOC    := human->uch_doc
    m1VRACH     := human_->vrach
    MKOD_DIAG   := human->KOD_DIAG
    // MKOD_DIAG0  := human_->KOD_DIAG0
    // MKOD_DIAG2  := human->KOD_DIAG2
    // MKOD_DIAG3  := human->KOD_DIAG3
    // MKOD_DIAG4  := human->KOD_DIAG4
    // MSOPUT_B1   := human->SOPUT_B1
    // MSOPUT_B2   := human->SOPUT_B2
    // MSOPUT_B3   := human->SOPUT_B3
    // MSOPUT_B4   := human->SOPUT_B4
    // MDIAG_PLUS  := human->DIAG_PLUS
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
    m1PROFIL_K := human_2->PROFIL_K
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    // m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW
    mcena_1    := human->CENA_1
    //
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // открыть и закрыть
    endif

    // выберем услуги
    R_Use(dir_server + 'uslugi', , 'USL')
    use_base('human_u')
    find (str(Loc_kod, 7))
    do while hu->kod == Loc_kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, mk_data))
        lshifr := usl->shifr
      endif
      if mrec_hu == 0
        mrec_hu := hu->(recno())
      else
        aadd(arr_del, hu->(recno()))
      endif
      select HU
      skip
    enddo
    for i := 1 to len(arr_del)
      select HU
      goto (arr_del[i])
      DeleteRec(.t., .f.)  // очистка записи без пометки на удаление
    next
  endif

  // готовим список профилей по возрасту  
  vozrast := count_years(mdate_r, mk_data)
  if vozrast < 18
    hb_ADel(mm_profil, 5, .t.)
    hb_ADel(mm_profil, 4, .t.)
  else
    hb_ADel(mm_profil, 3, .t.)
    hb_ADel(mm_profil, 2, .t.)
    hb_ADel(mm_profil, 1, .t.)
  endif

  mPROFIL := inieditspr(A__MENUVERT, mm_profil, m1PROFIL)

  if !(left(msmo, 2) == '34') // не Волгоградская область
    m1ismo := msmo
    msmo := '34'
  endif

  if Loc_kod == 0
    R_Use(dir_server + 'mo_otd', , 'OTD')
    goto (m1otd)
    m1USL_OK := otd->IDUMP
    if empty(m1PROFIL)
      m1PROFIL := otd->PROFIL
    endif
    if empty(m1PROFIL_K)
      m1PROFIL_K := otd->PROFIL_K
    endif
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
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  if empty(m1USL_OK)
    m1USL_OK := 3
  endif // на всякий случай
  // mUSL_OK   := inieditspr(A__MENUVERT, glob_V006, m1USL_OK)
  // mPROFIL   := inieditspr(A__MENUVERT, glob_V002, m1PROFIL)
  // mPROFIL_K := inieditspr(A__MENUVERT, getV020(),  m1PROFIL_K)
  // mrslt     := inieditspr(A__MENUVERT, glob_V009, m1rslt)
  mishod    := inieditspr(A__MENUVERT, glob_V012, m1ishod)
  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  motd      := inieditspr(A__POPUPMENU, dir_server + 'mo_otd',  m1otd)
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
  caption_window := ' случая постановки на диспансерный учет онкологического пациента'
  if Loc_kod == 0
    caption_window := 'Добавление' + caption_window
    mtip_h := yes_vypisan
  else
    caption_window := 'Редактирование' + caption_window
  endif

  setcolor(color8)
  top2 := 11
  myclear(top2)
  @ top2 - 1,0 say padc(caption_window, 80) color "B/BG*"
  Private gl_area := {1, 0, maxrow() - 1, maxcol(), 0}
  // Private gl_arr := {;  // для битовых полей
  //   {"usluga", "N",10,0, ,, ,{|x|inieditspr(A__MENUBIT,mm_usluga,x)} };
  //  }
  @ maxrow(), 0 say padc('<Esc> - выход;  <PgDn> - запись', maxcol() + 1) color color0
  mark_keys({'<F1>', '<Esc>', '<PgDn>'}, 'R/BG')
  setcolor(cDataCGet)
  make_diagP(1)  // сделать "шестизначные" диагнозы
  diag_screen(0)

  // f_valid_usl_ok(, -1)

  Private rdiag := 1, rpp := 1

  do while .t.
    j := top2
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 say padl('Лист учета № ' + lstr(Loc_kod), 29) color color14
    endif
    pos_read := 0
    //
    @ ++j, 1 say 'Учреждение' get mlpu when .f. color cDataCSay
    @ row(), col() + 2 say 'Отделение' get motd when .f. color cDataCSay
    //
    //
    ++j
    @ ++j, 1 say 'ФИО' get mfio_kart ;
        reader {|x| menu_reader(x, {{|k, r, c| get_fio_kart(k, r, c)}}, A__FUNCTION, , ,.f.)} ;
        valid {|g, o| update_get('mkomu'), update_get('mcompany'), ;
          update_get('mspolis'), update_get('mnpolis'), ;
          update_get('mvidpolis') }
    //
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
    @ row(), col()+3 say 'номер' get mnpolis when m1komu == 0
    @ row(), col()+3 say 'вид'   get mvidpolis ;
        reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)} ;
        when m1komu == 0 ;
        valid func_valid_polis(m1vidpolis, mspolis, mnpolis)
    //
    ++j
    //
    //
    @ ++j, 1 say '№ амб.карты (истории)' get much_doc picture '@!' when when_uch_doc
    //
    @ ++j, 1 say 'Профиль' get mPROFIL ;
      reader {|x|menu_reader(x,mm_profil, A__MENUVERT, , ,.f.)} //; color colget_menu
    //
    @ ++j, 1 say 'Дата постановки на диспансерный учет' get mn_data valid {|g|f_k_data(g, 1)}
    // @ row(), col() + 1 say '-'   get mk_data valid {|g|f_k_data(g, 2)}
    // @ row(), col() + 3 get mvzros_reb when .f. color cDataCSay
    //
    //
    ++j
    @ j, 1 say 'Основной диагноз' get mkod_diag picture pic_diag ;
      reader {|o| MyGetReader(o, bg)} ;
      when when_diag() ;
      valid {|| val1_10diag(.t., .f., .f., mn_data, mpol),  f_valid_onko_diag(mkod_diag, mdate_r, MN_DATA) }
    @ row(), col() + 1 say 'Врач' get MTAB_NOM pict '99999' ;
      valid {|g| v_kart_vrach(g, .t.), f_valid_onko_vrach(MTAB_NOM, mdate_r, MN_DATA) } when diag_screen(2)
    @ row(), col() + 1 get mvrach when .f. color color14
    //

    count_edit += myread(, @pos_read)

    k := f_alert({padc('Выберите действие', 60, '.')}, ;
                   {' Выход без записи ',  ' Запись ',  ' Возврат в редактирование '}, ;
                   iif(lastkey() == K_ESC, 1, 2),  'W+/N',  'N+/N', maxrow() - 2, , 'W+/N,N/BG' )
    if k == 3
      loop
    elseif k == 2 // запись информации
      MK_DATA := MN_DATA  // даты совпадают
      if empty(mn_data)
        func_error(4, 'Не введена дата постановки на учет')
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
        func_error(4,'Не заполнен номер полиса')
        loop
      endif
      if empty(mfio)
        func_error(4, 'Не введены Ф.И.О. Нет записи!')
        loop
      endif
      if empty(mdate_r)
        func_error(4, 'Не заполнена дата рождения')
        loop
      endif
      // if eq_any(m1vid_ud,3,14) .and. !empty(mser_ud) .and. empty(del_spec_symbol(mmesto_r))
      //   func_error(4,iif(m1vid_ud == 3, 'Для свид-ва о рождении', 'Для паспорта РФ') + ;
      //                ' обязательно заполнение поля "Место рождения"')
      //   loop
      // endif
      if empty(mkod_diag)
        func_error(4, 'Не введен шифр основного заболевания.')
        loop
      endif

      mywait('Ждите. Производится запись листа учёта ...')
      // далее проверки и запись

      make_diagP(2)  // сделать 'пятизначные' диагнозы
      //
      Use_base('lusl')
      Use_base('luslc')
      Use_base('uslugi')
      R_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1', ;
                                dir_server + 'uslugi1s'}, 'USL1')
      Private mu_kod, mu_cena
      mu_kod := foundOurUsluga(lshifr, mk_data, m1PROFIL, M1VZROS_REB, @mu_cena)

      Use_base('human')
      if Loc_kod > 0
        find (str(Loc_kod, 7))
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
      //
      glob_perso := mkod
      if m1komu == 0
        msmo := lstr(m1company)
        m1str_crb := 0
      else
        msmo := ''
        m1str_crb := m1company
      endif
      //
      human->kod_k      := glob_kartotek
      human->TIP_H      := B_STANDART
      human->FIO        := MFIO          // Ф.И.О. больного
      human->POL        := MPOL          // пол
      human->DATE_R     := MDATE_R       // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
      human->ADRES      := MADRES        // адрес больного
      human->MR_DOL     := MMR_DOL       // место работы или причина безработности
      human->RAB_NERAB  := M1RAB_NERAB   // 0-работающий, 1-неработающий
      human->KOD_DIAG   := MKOD_DIAG     // шифр 1-ой осн.болезни
      // human->KOD_DIAG2  := MKOD_DIAG2    // шифр 2-ой осн.болезни
      // human->KOD_DIAG3  := MKOD_DIAG3    // шифр 3-ой осн.болезни
      // human->KOD_DIAG4  := MKOD_DIAG4    // шифр 4-ой осн.болезни
      // human->SOPUT_B1   := MSOPUT_B1     // шифр 1-ой сопутствующей болезни
      // human->SOPUT_B2   := MSOPUT_B2     // шифр 2-ой сопутствующей болезни
      // human->SOPUT_B3   := MSOPUT_B3     // шифр 3-ой сопутствующей болезни
      // human->SOPUT_B4   := MSOPUT_B4     // шифр 4-ой сопутствующей болезни
      // human->diag_plus  := mdiag_plus    //
      human->KOMU       := M1KOMU        // от 0 до 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis(mspolis, mnpolis) // серия и номер страхового полиса
      human->LPU        := M1LPU         // код учреждения
      human->OTD        := M1OTD         // код отделения
      human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
      human->N_DATA     := MN_DATA       // дата начала лечения
      human->K_DATA     := MK_DATA       // дата окончания лечения
      human->CENA       := MCENA_1       // стоимость лечения
      human->CENA_1     := MCENA_1       // стоимость лечения
      // human->OBRASHEN := iif(m1DS_ONK == 1, '1',  ' ')
      // s := '' ; aeval(adiag_talon, {|x| s += str(x, 1) })
      human_->DISPANS   := '2000000000000000'  // поставлен на диспансерный учет
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := ltrim(mspolis)
      human_->NPOLIS    := ltrim(mnpolis)
      human_->OKATO     := '' // это поле вернётся из ТФОМС в случае иногороднего
      human_->USL_OK    := m1USL_OK
      human_->PROFIL    := m1PROFIL
      human_->IDSP      := m1IDSP   // 29
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // уберём '2',  если отредактировали запись из реестра СП и ТК
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
      human_2->PROFIL_K := m1PROFIL_K
      human_2->p_per  := iif(eq_any(m1USL_OK, 1, 2),  m1p_per, 0)


      use_base('human_u')
      select HU
      if mrec_hu == 0
        Add1Rec(7)
        mrec_hu := hu->(recno())
      else
        goto (mrec_hu)
        G_RLock(forever)
      endif
      replace hu->kod     with human->kod, ;
              hu->kod_vr  with m1vrach, ;
              hu->kod_as  with 0, ;
              hu->u_koef  with 1, ;
              hu->u_kod   with mu_kod, ;
              hu->u_cena  with mu_cena, ;
              hu->is_edit with 0, ;
              hu->date_u  with dtoc4(MK_DATA), ;
              hu->otd     with m1otd, ;
              hu->kol     with 1, ;
              hu->stoim   with mu_cena, ;
              hu->kol_1   with 1, ;
              hu->stoim_1 with mu_cena, ;
              hu->KOL_RCP with 0
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

      write_work_oper(glob_task, OPER_LIST, iif(Loc_kod == 0, 1, 2), 1, count_edit)
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
  if fl_write_sluch // если записали - запускаем проверку
    if !empty(val(msmo))
      verify_OMS_sluch(glob_perso)
    endif
  endif

  return nil

** 08.09.22
function f_valid_onko_diag(diag, dob, date_post)
  // diag - онкологический диагноз
  // dob - дата рождения
  // date_post - дата постановки на учет

  // для взрослых один из рубрик C00-D09
  // для детей один из рубрик C00-D89
  local vozrast, fl := .f., diagBeg := 'C00', diagAdult := 'D09', diagChild := 'D89'

  vozrast := count_years(dob, date_post)
  if ! (fl := between_diag(diag, 'C00', iif(vozrast < 18, diagChild, diagAdult)))
    func_error(4, 'Недопустимый диагноз, допустимый диапазон с ' + diagBeg + ' по ' + iif(vozrast < 18, diagChild, diagAdult) + '!')
  endif

  return fl

** 09.09.22
function f_valid_onko_vrach(tabnom, dob, date_post)
  // tab_nom - табельный номер врача
  // dob - дата рождения
  // date_post - дата постановки на учет
  local vozrast, fl := .f.
  local med_spec_child_V021 := {9, 19, 49, 102}
  local med_spec_adult_V021 := {39, 41}

  vozrast := count_years(dob, date_post)
  if ascan(iif(vozrast < 18, med_spec_child_V021, med_spec_adult_V021), get_spec_vrach_V021_by_tabnom(tabnom)) > 0
    fl := .t.
  endif
  if ! fl
    func_error(4, 'Недопустимая специальность врача!')
  endif
  return fl
