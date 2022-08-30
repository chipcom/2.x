#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** согласно письму ТФОМС 09-30-276 от 29.08.22 года

** 30.08.22 добавление или редактирование случая (листа учета)
function oms_sluch_ONKO_DISP(Loc_kod, kod_kartotek)
  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  static SKOD_DIAG := '     ', st_N_DATA, st_K_DATA, ;
    st_vrach := 0, st_profil := 0, st_profil_k := 0, st_rslt := 0, st_ishod := 0

  local bg := {|o, k| get_MKB10(o, k, .t.) }, ;
    buf, tmp_color := setcolor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    fl_write_sluch := .f., when_uch_doc := .t.
  local mm_da_net := {{'нет', 0}, {'да ', 1}}
  local caption_window

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
    msmo := '',  rec_inogSMO := 0, ;
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
    m1USL_OK := 0, mUSL_OK, ;
    m1PROFIL := st_profil, mPROFIL, ;
    m1PROFIL_K := st_profil_k, mPROFIL_K

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
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    mfio        := human->fio
    mpol        := human->pol
    mdate_r     := human->date_r
    M1VZROS_REB := human->VZROS_REB
    MADRES      := human->ADRES         // адрес больного
    MMR_DOL     := human->MR_DOL        // место работы или причина безработности
    M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий
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
    m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW
    mcena_1 := human->CENA_1
    //
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // открыть и закрыть
    endif
  endif
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
    m1USL_OK := 1
  endif // на всякий случай
  mUSL_OK   := inieditspr(A__MENUVERT, glob_V006, m1USL_OK)
  mPROFIL   := inieditspr(A__MENUVERT, glob_V002, m1PROFIL)
  mPROFIL_K := inieditspr(A__MENUVERT, getV020(),  m1PROFIL_K)
  mrslt     := inieditspr(A__MENUVERT, glob_V009, m1rslt)
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
      mcompany := padr(mismo,38)
    elseif !empty(mnameismo)
      mcompany := padr(mnameismo,38)
    endif
  endif
  caption_window := ' случая (листа учёта)'
  if Loc_kod == 0
    caption_window := 'Добавление' + caption_window
  else
    caption_window := 'Редактирование' + caption_window
  endif

  pr_1_str(caption_window)
  setcolor(color8)
  myclear(1)

  Private gl_area := {1, 0,maxrow()-1,maxcol(), 0}

  setcolor(cDataCGet)
  make_diagP(1)  // сделать 'шестизначные' диагнозы
  f_valid_usl_ok(, -1)

  Private rdiag := 1, rpp := 1

  do while .t.
    SetMode(26, 80)
    pr_1_str(caption_window)
    j := 1
    myclear(j)
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 say padl('Лист учета № ' + lstr(Loc_kod), 29) color color14
    endif
    diag_screen(0)
    pos_read := 0
    // put_dop_diag(0)
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
    //
    ++j
    @ ++j, 1 say 'Дата постановки на диспансерный учет' get mn_data valid {|g|f_k_data(g, 1)}
    // @ row(), col() + 1 say '-'   get mk_data valid {|g|f_k_data(g, 2)}
    @ row(), col() + 3 get mvzros_reb when .f. color cDataCSay
    //
    //
    @ ++j, 1 say '№ амб.карты (истории)' get much_doc picture '@!' when when_uch_doc
    @ row(), col() + 1 say 'Врач' get MTAB_NOM pict '99999' ;
        valid {|g| v_kart_vrach(g, .t.), f_valid_onko_vrach(MTAB_NOM, mdate_r, MN_DATA) } when diag_screen(2)
    @ row(), col() + 1 get mvrach when .f. color color14
    //
    //
    ++j
    @ j, 1 say 'Основной диагноз' get mkod_diag picture pic_diag ;
      reader {|o| MyGetReader(o, bg)} ;
      when when_diag() ;
      valid {|| val1_10diag(.t., .t., .t., mn_data, mpol),  f_valid_onko_diag(mkod_diag, mdate_r, MN_DATA) }
    //

    status_key('^<Esc>^ выход без записи ^<PgDn>^ ЗАПИСЬ')

    count_edit += myread(, @pos_read)

    k := 2
    if lastkey() != K_ESC
      k := f_alert({padc('Выберите действие', 60, '.')}, ;
                   {' Выход без записи ',  ' Запись ',  ' Возврат в редактирование '}, ;
                   iif(lastkey() == K_ESC, 1, 2),  'W+/N',  'N+/N', maxrow() - 2, , 'W+/N,N/BG' )
    endif
    if k == 3
      loop
    elseif k == 2 // запись информации
      MK_DATA := MN_DATA  // даты совпадают
    endif
    exit

  enddo
  close databases
  diag_screen(2)
  setcolor(tmp_color)

  restscreen(buf)

  return nil

** 30.08.22
function f_valid_onko_diag(diag, dob, date_post)
  // diag - онкологический диагноз
  // dob - дата рождения
  // date_post - дата постановки на учет

  return .t.

** 30.08.22
function f_valid_onko_vrach(tab_nom, dob, date_post)
  // tab_nom - табельный номер врача
  // dob - дата рождения
  // date_post - дата постановки на учет

return .t.
