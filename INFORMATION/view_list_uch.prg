// view_lists_uch.prg - просмотр листов учета по ОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 24.12.25
Function print_l_uch( mkod, par, regim, lnomer )
  
  // mkod - код больного по БД human

  Local sh := 80, HH := 77, buf := save_maxrow(), ;
      name_lpu, name_otd := '', mvzros_reb, mrab_nerab, ;
      mkomu, name_org, mlech_vr := '', msumma := 0, ;
      mud_lich := '', arr, n_file := cur_dir() + 'list_uch.txt', adiag_talon[16], ;
      madres, i := 1, j, k, tmp[2], tmp1, w1 := 37, s, s1, mnum_lu, lshifr1
  local tmpAlias
  local arrLekPreparat, arrImplantant, row
  local cREGNUM, cUNITCODE, cMETHOD
  local lTypeLUMedReab := .f., aMedReab
  local diagVspom := '', diagMemory := '', add_criteria
  local arrKSLP, akslp, len_akslp, arrKIRO, akiro
  local k_kslp, tmp_kslp := {}
  local k_kiro, tmp_kiro := {}
  local mas[2], lname
  local lExistFilesTFOMS

  DEFAULT par TO 1, regim TO 1, lnomer TO 0
  mywait()
  fp := fcreate(n_file)
  tek_stroke := 0
  n_list := 1
  //
  R_Use(dir_server() + 'organiz', , 'ORG')
  name_org := alltrim(org->name)
  dbCloseAll()
  if !myFileDeleted(cur_dir() + 'tmp1' + sdbf())
    return NIL
  endif
  dbcreate(cur_dir() + 'tmp1', {{'kod', 'N', 4, 0}, ;
                         {'name', 'C', 255, 0}, ;
                         {'shifr', 'C', 20, 0}, ;
                         {'shifr1', 'C', 20, 0}, ;
                         {'dom', 'N', 1, 0}, ;
                         {'zf', 'C', 30, 0}, ;
                         {'kod_diag', 'C', 5, 0}, ;
                         {'date_u1', 'D', 8, 0}, ;
                         {'date_u2', 'D', 8, 0}, ;
                         {'rec_hu', 'N', 8, 0}, ;
                         {'otd', 'C', 5, 0}, ;
                         {'plus', 'L', 1, 0}, ;
                         {'is_edit', 'N', 2, 0}, ;
                         {'kod_vr', 'N', 5, 0}, ;
                         {'kod_as', 'N', 5, 0}, ;
                         {'profil', 'N', 4, 0}, ;
                         {'kol', 'N', 4, 0}, ;
                         {'summa', 'N', 11, 2}})
  use (cur_dir() + 'tmp1')
  index on str(kod, 4) to (cur_dir() + 'tmp11')
  index on dtos(date_u1) +fsort_usl(shifr) to (cur_dir() + 'tmp12')
  use (cur_dir() + 'tmp1') index (cur_dir() + 'tmp11'), (cur_dir() + 'tmp12') alias tmp1
  Use_base('lusl')
  Use_base('luslf')
  R_Use(dir_server() + 'uslugi', , 'USL')
  R_Use(dir_server() + 'human_u_', , 'HU_')
  R_Use(dir_server() + 'human_u',dir_server() + 'human_u', 'HU')
  set relation to recno() into HU_
  R_Use(dir_server() + 'mo_su', , 'MOSU')
  R_Use(dir_server() + 'mo_hu',dir_server() + 'mo_hu', 'MOHU')
  R_Use(dir_server() + 'mo_otd', , 'OTD')
  R_Use(dir_server() + 'human_3',{dir_server() + 'human_3',dir_server() + 'human_32'}, 'HUMAN_3')
  R_Use(dir_server() + 'human_2', , 'HUMAN_2')
  goto (mkod)
  R_Use(dir_server() + 'human_', , 'HUMAN_')
  goto (mkod)
  R_Use(dir_server() + 'human', , 'HUMAN')
  goto (mkod)
  R_Use(dir_server() + 'mo_pers', , 'PERSO')
  goto (human_->vrach)
  mlech_vr := iif(empty(perso->tab_nom), '', lstr(perso->tab_nom) + ' ') + alltrim(perso->fio)
  otd->(dbGoto(human->otd))
  R_Use(dir_server() + 'kartote_', , 'KART_')
  goto (human->kod_k)
  R_Use(dir_server() + 'kartotek', , 'KART')
  goto (human->kod_k)
  //
  Private mvid_ud := kart_->vid_ud, ;
          mser    := kart_->ser_ud, ;
          mnom    := kart_->nom_ud, ;
          m1kategor := kart_->kategor, ;
          m1povod  := human_->POVOD, ;
          m1travma := human_->TRAVMA
  afill(adiag_talon,0)
  for i := 1 to 16
    adiag_talon[i] := int(val(substr(human_->DISPANS, i, 1)))
  next
  Private M1F14_EKST := int(val(substr(human_->FORMA14, 1, 1)))
  Private M1F14_SKOR := int(val(substr(human_->FORMA14, 2, 1)))
  Private M1F14_VSKR := int(val(substr(human_->FORMA14, 3, 1)))
  Private M1F14_RASH := int(val(substr(human_->FORMA14, 4, 1)))
  if mvid_ud > 0
    mud_lich := get_Name_Vid_Ud(mvid_ud, , ': ')
    if !empty(mser)
      mud_lich += charone(' ', mser) + ' '
    endif
    if !empty(mnom)
      mud_lich += mnom+ ' '
    endif
  endif
  mpolis := alltrim(rtrim(human_->SPOLIS) + ' ' +human_->NPOLIS) + ' (' +;
          alltrim(inieditspr(A__MENUVERT, mm_vid_polis, human_->VPOLIS)) + ')'
  madres := iif(emptyall(kart_->okatog,kart->adres), '', ret_okato_ulica(kart->adres,kart_->okatog))
  madresp := iif(emptyall(kart_->okatop,kart_->adresp), '', ret_okato_ulica(kart_->adresp,kart_->okatop))
  //
  if human->tip_h >= B_SCHET .and. human->schet > 0 // добавление номера счета
    R_Use(dir_server() + 'schet_', , 'SCHET_')
    goto (human->schet)
    R_Use(dir_server() + 'schet', , 'SCHET')
    goto (human->schet)
    add_string('Счет № ' + alltrim(schet_->nschet) + ' от ' +date_8(schet_->dschet) + 'г.' +;
             if(human_->SCHET_ZAP==0, '', '  [ № ' + lstr(human_->SCHET_ZAP) + ' ]'))
    if eq_any(human_->oplata, 2, 3, 9)
      s := iif(eq_any(human_->oplata, 2, 9), 'Не', 'Частично') + ' оплачен. '
      if human_->oplata == 3
        s += '(' + lstr(human_->sump) + ') '
      endif
      R_Use(dir_server() + 'mo_os', , 'MO_OS')
      Locate for kod == mkod
      if found()
        s += 'Акт № ' + alltrim(mo_os->AKT) + ' от ' +date_8(mo_os->DATE_OPL) + ' '
//        if !empty(s1 := ret_t005(mo_os->REFREASON))
        if ! empty( s1 := ret_f014( mo_os->REFREASON ) )
          s += 'Код дефекта ' + s1 + '. '
        endif
        if mo_os->IS_REPEAT == 1
          s += 'Лист учёта выставлен повторно.'
        endif
      else
        R_Use(dir_server() + 'mo_rak', , 'RAK')
        R_Use(dir_server() + 'mo_raks', , 'RAKS')
        set relation to akt into RAK
        R_Use(dir_server() + 'mo_raksh', , 'RAKSH') 
        set relation to kod_raks into RAKS
        arr := {}
        Index On Str( kod_h, 7 ) to ( cur_dir() + 'tmp_raksh' ) for kod_h == mkod
        //Locate for kod_h == mkod
        //do while found()
        //  aadd(arr, {rak->NAKT, rak->DAKT, raksh->REFREASON, raksh->NEXT_KOD})
        //  continue
        //enddo
        find(str(mkod,7))
        if found()
          do while raksh->kod_h == mkod .and. !eof()
            aadd(arr, {rak->NAKT, rak->DAKT, raksh->REFREASON, raksh->NEXT_KOD})
            skip 
          enddo
        endif 
        //
        asort(arr, , ,{|x,y| x[2] < y[2] })
        for i := 1 to len(arr)
          s += 'Акт № ' + alltrim(arr[i, 1]) + ' от ' +date_8(arr[i, 2]) + '. '
//        if !empty(s1 := ret_t005(arr[i, 3]))
          if ! empty( s1 := ret_f014( arr[i, 3] ) )
            s += 'Код дефекта ' + s1 + '. '
          endif
          if arr[i, 4] > 0
            s += 'Лист учёта выставлен повторно. '
          endif
          if i < len(arr)
            s += '; '
          endif
        next
      endif
      for i := 1 to perenos(tmp, s, sh)
        add_string(tmp[i])
      next
    endif
    add_string('')
  endif
  name_lpu := rtrim(inieditspr(A__MENUVERT, getUCH(), human->lpu))
  name_otd := '  [ ' + alltrim(otd->name) + ' ]'
  lTypeLUMedReab := (otd->tiplu == TIP_LU_MED_REAB)

  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, human->vzros_reb)
  mrab_nerab := inieditspr(A__MENUVERT, menu_rab, kart->rab_nerab)
  mkomu := f4_view_list_schet(human->komu, cut_code_smo(human_->smo), human->str_crb)
  mnum_lu := alltrim(human->uch_doc)
  if yes_num_lu == 1
    mnum_lu += ' [' + lstr(human->kod) + ']'
  endif
  //
  if ! (lExistFilesTFOMS := check_files_TFOMS(year(human->k_data)))  // проверим наличие справочников ТФОМС
    func_error(4, 'Отсутствуют справочники ТФОМС за ' + str(year(human->k_data), 4) +' год.' )
  endif

  for i := 1 to perenos(tmp, name_org, sh)
    add_string(center(alltrim(tmp[i]), sh))
  next
  add_string('')
  add_string(center(name_lpu + name_otd, sh))
  add_string('')
  add_string(center('Л_И_С_Т  У_Ч_Е_Т_А', sh))
  add_string(center('М_Е_Д_И_Ц_И_Н_С_К_И_Х  У_С_Л_У_Г  № ' + mnum_lu, sh))
  print_l_uch_disp(sh)
  if eq_any(human->ishod, 88, 89)
    select HUMAN_3
    if human->ishod == 88
      set order to 1
      is_2 := 1
    else
      set order to 2
      is_2 := 2
    endif
    find (str(human->kod, 7))
    if found() // если нашли двойной случай
      add_string('')
      add_string('Это двойной случай (с ' + date_8(human_3->N_DATA) + ' по ' + date_8(human_3->K_DATA) + ' на сумму ' + lstr(human_3->CENA_1,10,2) + 'р.)')
    endif
  endif
  add_string('')
  add_string('  Ф.И.О.: ' + human->fio + '          Пол: ' + human->pol)
  add_string('  Дата рождения: ' + full_date(human->date_r) + '  (' + mvzros_reb + ')')
//  add_string('  СНИЛС: ' + transform(kart->SNILS, picture_pf))
  add_string( '  СНИЛС: ' + transform_SNILS( kart->SNILS ) )

  if !empty(mud_lich)
    k := perenos(tmp, mud_lich, sh - 2)
    add_string('  ' + tmp[1])
    for i := 2 to k
      add_string(padl(alltrim(tmp[i]), sh))
    next
  endif
  k := perenos(tmp, 'Место рождения: ' + kart_->mesto_r, sh - 2)
  add_string('  ' + tmp[1])
  for i := 2 to k
    add_string(padl(alltrim(tmp[i]), sh))
  next
  k := perenos(tmp, 'Адрес регистрации: ' + madres, sh - 2)
  add_string('  ' + tmp[1])
  for i := 2 to k
    add_string(padl(alltrim(tmp[i]), sh))
  next
  if !empty(madresp)
    k := perenos(tmp, 'Адрес пребывания: ' + madresp, sh - 2)
    add_string('  ' + tmp[1])
    for i := 2 to k
      add_string(padl(alltrim(tmp[i]), sh))
    next
  endif
  if !empty(human->mr_dol)
    add_string('  Место работы/учебы: ' + human->mr_dol)
  endif
  add_string( '  Статус пациента: ' + mrab_nerab )
  add_string( '  Социальная категория пациента: ' + inieditspr( A__MENUVERT, mm_SOC(), val( kart->PC3 ) ) )

  if human_->NOVOR > 0
    add_string('')
    add_string('  Новорожденный: ' + lstr(human_->NOVOR) + '-й ребёнок, д.р. ' + ;
             date_8(human_->DATE_R2) + ', пол ' + human_->POL2)
    add_string('')
  endif
  if !empty(human_->NPR_MO) .and. !(human_->NPR_MO == glob_mo[_MO_KOD_TFOMS])
    k := perenos(tmp, 'Направившая МО: ' +ret_mo(human_->NPR_MO)[_MO_FULL_NAME], sh - 2)
    add_string('  ' + tmp[1])
    for i := 2 to k
      add_string(padl(alltrim(tmp[i]), sh))
    next
    if !empty(human_2->NPR_DATE)
      add_string('  Дата направления: ' + full_date(human_2->NPR_DATE))
    endif
  endif
  add_string('  Принадлежность счета: ' + mkomu)
  add_string('  Серия и номер страхового полиса: ' + mpolis)
  if M1F14_EKST == 1
    s := '  Госпитализирован по экстренным показаниям'
    if M1F14_SKOR == 1
      s += ' (доставлен скорой мед.помощью)'
    endif
    add_string(s)
  endif
  s := ''
  if eq_any(human->ishod, 201, 202, 203, 401, 402, 501, 502 )  // дисп-ия (профосмотр) взрослого населения
    Private pole_diag, pole_1pervich
    for i := 1 to 5
      pole_diag := 'mdiag' + lstr(i)
      pole_1pervich := 'm1pervich' + lstr(i)
      Private &pole_diag := space(6)
      Private &pole_1pervich := 0
    next
    if eq_any(human->ishod, 501, 502 )  // дисп-ия  репродуктивного здоровья взрослого населения
      read_arr_drz( human->kod )
    else
      read_arr_DVN(human->kod)
    endif
    arr := {}
    for i := 1 to 5
      pole_diag := 'mdiag' + lstr(i)
      pole_1pervich := 'm1pervich' + lstr(i)
      if !empty(&pole_diag) .and. &pole_1pervich == 2  // предварительный диагноз
        aadd(arr, &pole_diag)
      endif
    next
    for j := 1 to len(arr)
      s += ' ' + alltrim(arr[j])
    next
    if !empty(s)
      s := '  Предварительный диагноз: ' + s
    endif
  elseif !empty(human_->KOD_DIAG0)
    s := '  Первичный диагноз: ' + human_->KOD_DIAG0
  endif
  if !empty(s)
    add_string(s)
  endif
  arr := diag_to_array( , .t., .t., .t., .t., adiag_talon)
  if len(arr) > 0
    if eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ) .and. diagnosis_for_replacement(arr[1], human_->USL_OK)
      diagVspom := alltrim(arr[1])
      diagMemory := alltrim(arr[2])
    endif
    add_string('  Основной диагноз: ' + iif(empty(diagVspom), arr[1], arr[2] + ' (!!!вспомогательный диагноз ' + diagVspom + '!!!)'))
    if year(human->k_data) > 2017 .and. !empty(human_2->pc3)
      k := 0
      add_string('  Дополнительный критерий : ')
      if lExistFilesTFOMS
        add_criteria := getArrayCriteria(human->K_DATA, human_2->pc3)
        if ! empty(add_criteria)
          if year(human->k_data) >= 2021
            k := perenos(tmp, alltrim(human_2->pc3) + ' - ' + alltrim(add_criteria[6]), sh - 3)
            for i := 1 to k
              add_string(space(3) + tmp[i])
            next
          else
            add_string(space(3) + alltrim(human_2->pc3))
          endif
        endif
      else
        add_string(space(3) + alltrim(human_2->pc3))
      endif
    endif
    if len(arr) > 1
      tmp1 := '  Сопутствующие диагнозы:'
      for j := iif(empty(diagVspom), 2, 3) to len(arr)
        tmp1 += ' ' + arr[j]
      next
      add_string(tmp1)
    endif
  endif
  tmp1 := ''
  arr := {human_2->OSL1, human_2->OSL2, human_2->OSL3}
  for j := 1 to len(arr)
    tmp1 += ' ' + arr[j]
  next
  if !empty(tmp1)
    add_string('  Диагнозы осложнения:' + tmp1)
  endif
  if lTypeLUMedReab
    aMedReab := list2arr(human_2->PC5)  // [1], list2arr(human_2->PC5)[2]
    add_string('')
    add_string('  Вид реаблитации: ' + inieditspr(A__MENUVERT, type_reabilitacia(), aMedReab[1]))
    add_string('  Шкала Реабилитационной Маршрутизации: ' + inieditspr(A__MENUVERT, type_shrm_reabilitacia(), aMedReab[2]))
  endif

  add_string('  Медицинская помощь: условия оказания: ' + inieditspr(A__MENUVERT, getV006(), human_->USL_OK))
  if human_->PROFIL > 0
    k := perenos(tmp, 'профиль: ' + inieditspr(A__MENUVERT, getV002(), human_->PROFIL), sh - 4)
    add_string(space(4) + tmp[1])
    for i := 2 to k
      add_string(padl(alltrim(tmp[i]), sh))
    next
  endif
  if human_2->PROFIL_K > 0 .and. eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
    k := perenos(tmp, 'профиль койки: ' +inieditspr(A__MENUVERT, getV020(), human_2->PROFIL_K), sh - 4)
    add_string(space(4) + tmp[1])
    for i := 2 to k
      add_string(padl(alltrim(tmp[i]), sh))
    next
  endif
  k := perenos(tmp, inieditspr(A__MENUVERT, getV010(), human_->IDSP), sh - 19)
  add_string('    способ оплаты: ' + tmp[1])
  for i := 2 to k
    add_string(space(19) + tmp[i])
  next
  k := perenos(tmp, 'Результат обращения: ' + inieditspr(A__MENUVERT, getV009(), human_->RSLT_NEW), sh - 2)
  add_string('  ' + tmp[1])
  for i := 2 to k
    add_string(padl(alltrim(tmp[i]), sh))
  next
  if human->OBRASHEN == '1'
    add_string('  Признак подозрения на злокачественное новообразование: да')
  endif
  add_string('  Исход заболевания: ' + inieditspr(A__MENUVERT, getV012(), human_->ISHOD_NEW))
  if is_death(human_->RSLT_NEW) .and. M1F14_VSKR == 1 // смерть
    s := '  Проведено патологоанатомическое вскрытие'
    if M1F14_RASH == 1
      s += ' (установлено расхождение диагнозов)'
    endif
    add_string(s)
  endif
  if human_2->VMP == 1 .and. !empty(human_2->VIDVMP)
    if !empty(human_2->TAL_NUM)
      add_string('  Номер талона на ВМП: ' + human_2->TAL_NUM)
    endif
    if lExistFilesTFOMS
      k := perenos(tmp, ret_V018(human_2->VIDVMP, human->k_data), sh - 11)
      add_string('  Вид ВМП: ' + tmp[1])
      for i := 2 to k
        add_string(space(11) + tmp[i])
      next
      if !empty(human_2->METVMP)
        k := perenos(tmp, ret_V019(human_2->METVMP, human_2->VIDVMP, human->k_data), sh - 14)
        add_string('   метод ВМП: ' + tmp[1])
        for i := 2 to k
          add_string(space(14) + tmp[i])
        next
      endif
    endif
  endif

  if HUMAN_2->PN6 == 1
    add_string('')
    add_string('  Пациент направлен на МСЭ в бюро медико-социальной экспертизы')
  endif
  
  if !empty(mlech_vr)
    add_string('  Лечащий врач : ' + mlech_vr)
  endif

  add_string('')
  add_string(center('Срок лечения с ' + full_date(human->n_data) + ' по ' + full_date(human->k_data), sh))
  add_string('')
  if human->bolnich > 0
    add_string('  Временная нетрудоспособность (больничный) с ' + ;
             full_date(c4tod(human->date_b_1)) + ' по ' + full_date(c4tod(human->date_b_2)))
    if human->bolnich == 2
      add_string('  (По уходу: дата рождения родителя ' + ;
               full_date(human_->RODIT_DR) + ', пол ' +human_->RODIT_POL+ ')')
    endif
    add_string('')
  endif
  add_string(center('О_К_А_З_А_Н_Ы   У_С_Л_У_Г_И', sh))
  Select HU
  find (str(mkod, 7))
  do while hu->kod == mkod .and. !eof()
    if !emptyall(hu->kol_1, hu->stoim_1)
      Select OTD
      goto (hu->otd)
      Select USL
      goto (hu->u_kod)
      lname := usl->name

      tmpAlias := create_name_alias('LUSL',  year(human->k_data))
      if lExistFilesTFOMS
        select (tmpAlias)
        find (padr(usl->shifr, 10))
        if found()
          lname := (tmpAlias)->name  // наименование услуги из справочника ТФОМС
        endif
      endif
      lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
      select TMP1
      append blank
      tmp1->kod := usl->kod
      tmp1->name := lname
      tmp1->shifr := usl->shifr //iif(empty(lshifr1), usl->shifr, lshifr1)
      tmp1->shifr1 := lshifr1
      tmp1->date_u1 := c4tod(hu->date_u)
      tmp1->date_u2 := c4tod(hu_->date_u2)
      tmp1->rec_hu := hu->(recno())
      tmp1->kod_diag := hu_->KOD_DIAG
      tmp1->dom := iif(between(hu->kol_rcp, -2, -1), -hu->kol_rcp, 0)
      tmp1->otd := otd->short_name
      if lExistFilesTFOMS
        if human->k_data < 0d20120301
          tmp1->plus := !f_paraklinika(usl->shifr, lshifr1, c4tod(hu->date_u))
        else
          tmp1->plus := !f_paraklinika(usl->shifr, lshifr1, human->k_data)
        endif
      endif
      tmp1->profil := hu_->profil
      tmp1->is_edit := hu->is_edit
      tmp1->kod_vr := hu->kod_vr
      tmp1->kod_as := hu->kod_as
      tmp1->kol += hu->kol_1
      tmp1->summa += hu->stoim_1
    endif
    select HU
    Skip
  enddo
  Select MOHU
  find (str(mkod, 7))
  do while mohu->kod == mkod .and. !eof()
    if !empty(mohu->kol_1)
      Select OTD
      goto (mohu->otd)
      Select MOSU
      goto (mohu->u_kod)
      lname := mosu->name
      if lExistFilesTFOMS
        tmpAlias := create_name_alias('LUSLF',  year(human->k_data))
        select (tmpAlias)
        find (padr(mosu->shifr1, 20))
        if found()
          lname := (tmpAlias)->name  // наименование услуги из справочника ТФОМС
        endif
      endif

      select TMP1
      append blank
      tmp1->kod := mosu->kod
      tmp1->name := lname
      tmp1->shifr := iif(empty(mosu->shifr), mosu->shifr1, mosu->shifr)
      tmp1->shifr1 := mosu->shifr1
      tmp1->date_u1 := c4tod(mohu->date_u)
      tmp1->date_u2 := c4tod(mohu->date_u2)
      tmp1->rec_hu := mohu->(recno())
      tmp1->kod_diag := mohu->KOD_DIAG
      if STisZF(human_->USL_OK, human_->PROFIL)
        tmp1->zf := mohu->ZF
      endif
      tmp1->otd := otd->short_name
      tmp1->plus := .f.
      tmp1->kod_vr := mohu->kod_vr
      tmp1->kod_as := mohu->kod_as
      tmp1->kol += mohu->kol_1
      tmp1->summa += mohu->stoim_1
    endif
    select MOHU
    Skip
  enddo
  mpsumma := 0
  w1 := 34
  header_uslugi(w1)
  select TMP1
  set order TO 2
  go top
  do while !eof()
    s := alltrim(tmp1->shifr)
    if !(alltrim(tmp1->shifr) == alltrim(tmp1->shifr1)) .and. !empty(tmp1->shifr1)
      s += '(' + alltrim(tmp1->shifr1) + ')'
    endif
    s += iif(tmp1->dom==1, '/на дому/', iif(tmp1->dom==2, '/домАКТИВ/', ' '))
    s += alltrim(tmp1->name)
    if eq_any(alltrim(tmp1->shifr), '2.3.1', '2.3.3', '2.6.1', '2.60.1')
      s += ' (' + alltrim(inieditspr(A__MENUVERT, getV002(), tmp1->PROFIL)) + ')'
    elseif !empty(tmp1->zf)
      s += ' ЗФ:' + alltrim(tmp1->ZF)
    endif
    k := perenos(tmp, s, w1)
    if verify_FF(HH)
      header_uslugi(w1)
    endif
    if eq_any(left(tmp1->shifr, 5), '1.11.', '55.1.')
      s := left(date_8(tmp1->date_u1), 2) + '-' + left(date_8(tmp1->date_u2), 5) + ' '
    else
      s := date_8(tmp1->date_u1) + ' '
    endif
    if tmp1->is_edit == 1
      s += 'КДП№2 '
    elseif tmp1->is_edit == 2
      s += ' РДЛ  '
    elseif tmp1->is_edit == 4
      s += 'ПАбюро'
    elseif tmp1->is_edit == 5
      s += 'ПАпроч'
    elseif tmp1->is_edit == -1
      s += 'ЦКДЛ  '
    elseif alltrim(tmp1->shifr) == '4.20.2' .or. tmp1->is_edit == 3
      s += 'ВОКОД '
    else
      s += tmp1->otd+ ' '
    endif
    if empty(diagVspom)
      s += tmp1->kod_diag + ' '
    else
      s += diagMemory + ' '
    endif
    s += padr(tmp[1], w1)
    s += put_val(ret_tabn(tmp1->kod_vr), 6) + put_val(ret_tabn(tmp1->kod_as), 6)
    if tmp1->plus
      s += padl(' + ' + lstr(tmp1->kol), 4)
      mpsumma += tmp1->summa
    else
      if tmp1->summa >= 100000
        s += ' ' + padr(lstr(tmp1->kol), 3)
      else
        s += put_val(tmp1->kol, 4)
      endif
      msumma += tmp1->summa
    endif
    s += put_kopE(tmp1->summa, 9)
    //
    // if eq_any(human->ishod, 401, 402 ) .and. tmp1->kod_vr == 0 
    if is_sluch_dispanser_COVID( human->ishod ) .and. tmp1->kod_vr == 0 
    // УГЛУБЛЕННАЯ дисп-ия взрослого населения
    else
      add_string(s)
      for i := 2 to k
        add_string(space(21) + padl(rtrim(tmp[i]), w1))
      next
    endif
    //
    if tmp1->summa > 0 .and. is_ksg(tmp1->shifr)
        if year(human->k_data) > 2017
          s1 := ''
          if !empty(human_2->pc1)
            akslp := List2Arr(human_2->pc1)
            if len(akslp) > 0
              s1 += '(с учётом КСЛП='
              if year(human->k_data) >= 2021
                for i := 1 to len(akslp)  // возможно несколько КСЛП для КСГ
                  if lExistFilesTFOMS
                    arrKSLP := getInfoKSLP(human->k_data, akslp[i])
                    s1 += alltrim(str(arrKSLP[1])) + '. ' + arrKSLP[3] + ', коэф.=' + str(arrKSLP[4], 4, 2) + ') '
                  else
                    //
                  endif
                next
              else
                len_akslp := len(akslp) / 2
                for i := 1 to len_akslp
                  if lExistFilesTFOMS
                    arrKSLP := getInfoKSLP(human->k_data, akslp[i * 2 - 1])
                    s1 += alltrim(str(arrKSLP[1])) + '. ' + arrKSLP[3] + ', коэф.=' + str(arrKSLP[4], 4, 2) + ') '
                  else
                    //
                  endif
                next
              endif
              k_kslp := perenos(tmp_kslp, s1, w1)
            endif
          endif
          if !empty(human_2->pc2)
            s1 := ''
            akiro := List2Arr(human_2->pc2)
            if len(akiro) > 1
              s1 += '(с учётом КИРО='
              if lExistFilesTFOMS
                arrKIRO := getInfoKIRO(human->k_data, akiro[1])
                s1 += alltrim(str(arrKIRO[1])) + '. ' + arrKIRO[3] + ', коэф.=' + str(arrKIRO[4], 4, 2) + ') '
              else
                //
              endif
              k_kiro := perenos(tmp_kiro, s1, w1)
            endif
          endif
          if !empty(tmp_kslp)
            for i := 1 to k_kslp
              if i == 1
                add_string(space(21) + tmp_kslp[i])
              else
                add_string(space(21) + padl(rtrim(tmp_kslp[i]), w1))
              endif
            next
          endif
          if !empty(tmp_kiro)
            for i := 1 to k_kiro
              if i == 1
                add_string(space(21) + tmp_kiro[i])
              else
                add_string(space(21) + padl(rtrim(tmp_kiro[i]), w1))
              endif
            next
          endif
        endif
    endif
    select TMP1
    skip
  enddo
  zap
  set order to 1
  add_string(replicate('-', sh))
  s := 'Общая сумма лечения: ' + put_kop(human->cena_1, 12)
  if mpsumma > 0
    s := alltrim(s) + ' (+ ' + lput_kop(mpsumma, .t.) + ')'
  endif
  add_string(padl(s, sh))

  if f_is_oncology( 1 ) == 2 .and. eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )
    print_luch_onk( human->k_data, human->KOD_DIAG, sh )
  else
    arrLekPreparat := collect_lek_pr( mkod ) // выберем лекарственные препараты
    if len( arrLekPreparat ) != 0  // не пустой список лекарственных препаратов
      add_string('')
      add_string(center('Л_Е_К_А_Р_С_Т_В_Е_Н_Н_Ы_Е   П_Р_Е_П_А_Р_А_Т_Ы', sh))
      header_lek_preparat( w1 )
      for each row in arrLekPreparat
        if verify_FF( HH )
          header_lek_preparat( w1 )
        endif
        s := ''
        cREGNUM := padr(get_Lek_pr_By_ID(row[3]), 30)
        cUNITCODE := padr(inieditspr(A__MENUVERT, get_ed_izm(), row[4]),iif(mem_n_V034==0, 15, 30))
        cMETHOD := padr(inieditspr(A__MENUVERT, getMethodINJ(), row[6]), 30)
        s := date_8(row[1]) + ' '
        if empty(cREGNUM)
          s += padr(ret_schema_V032(row[8]), 33)
        else
          s += padr(cREGNUM, 33) + ' '
          s := s + str(row[5], 6, 2) + ' ' ;
              + padr(cUNITCODE, 7) + ' ' ;
              + padr(cMETHOD, 15) + ' ' ;
              + str(row[7], 6)
        endif
        add_string(s)
      next
    endif
  endif

  arrImplantant := collect_implantant(mkod) // выберем имплантант
  if ! empty(arrImplantant)
    add_string('')
    add_string(center('У_С_Т_А_Н_О_В_Л_Е_Н_Н_Ы_Е   И_М_П_Л_А_Н_Т_А_Н_Т_Ы', sh))
    header_implantant(w1)
    for each row in arrImplantant
      s := ''
      s := date_8(row[3]) + ' '
      k := perenos(mas, inieditspr(A__MENUVERT, get_implantant(), row[4]), 40, ' ,;')
      s := s + padr(mas[1], 40) + ' ' + padr(row[5], 35)
      add_string(s)
      if k > 1
        add_string(space(9) + padl(alltrim(mas[2]), 40))
      endif
    next
  endif

  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(n_file, , , , .f., , , 5)
  return NIL

//
Function header_implantant(w1)

  add_string('────────┬────────────────────────────────────────┬──────────────────────────────')
  add_string('  Дата  │Наименование имплантанта                │Серийный номер')
  add_string('────────┴────────────────────────────────────────┴──────────────────────────────')
  return NIL

//
Function header_lek_preparat( w1 )

  add_string('────────┬─────────────────────────────────┬──────┬───────┬───────────────┬──────')
  add_string('  Дата  │Наименование препарата или группы│Доз-ка│Единица│Способ введения│Кол-во')
  add_string('────────┴─────────────────────────────────┴──────┴───────┴───────────────┴──────')
  return NIL
  
// 27.01.25
Function header_lek_preparat_onko( w1 )

  add_string('────────┬─────────────────────────────────┬───────┬───────┬─────────────┬─────────────')
  add_string('  Дата  │Наименование препарата или группы│Единица│Введено│Израсходовано│Стоимость ед.')
  add_string('────────┴─────────────────────────────────┴───────┴───────┴─────────────┴─────────────')
  return NIL
  
//
Function header_uslugi(w1)

  add_string('────────┬─────┬─────┬' +replicate('─', w1)              + '┬─────┬─────┬───┬────────')
  add_string('  Дата  │ Отд.│МКБ10│' +padc('Наименование услуги', w1) + '│ Врач│ Асс.│Кол│ Сумма  ')
  add_string('────────┴─────┴─────┴' +replicate('─', w1)              + '┴─────┴─────┴───┴────────')
  return NIL


// 02.11.22 печать доп.заголовка, если это лист учёта диспансеризации/профилактики
Function print_l_uch_disp(sh)

  Local s := ''

  if eq_any(human->ishod, 101, 102)
    s := 'диспансеризация детей-сирот ' + ;
       iif(!empty(human->ZA_SMO), 'в стационаре', 'под опекой') + ;
       iif(human->ishod == 101, ' I этап', ' I и II этап')
  elseif eq_any(human->ishod, 201, 202, 203)
    s := iif(human->ishod == 203, 'профилактика', 'диспансеризация') + ;
       ' опр.групп взрослого населения'
    if eq_any(human->ishod, 201, 202)
      s += iif(human->ishod == 201, ' I', ' II') + ' этап'
    endif
  elseif eq_any(human->ishod, 204, 205)
    s := 'диспансеризация опр.групп взрослого населения (1 раз в 2 года) ' + iif(human->ishod==204, 'I', 'II') + ' этап'
  elseif eq_any(human->ishod, 301, 302)
    s := 'профилактика несовершеннолетних' + ;
       iif(human->ishod == 301, ' I этап', ' I и II этап')
  elseif eq_any(human->ishod, 303, 304)
    s := 'предварительный осмотр несовершеннолетних' +;
       iif(human->ishod == 303, ' I этап', ' I и II этап')
  elseif human->ishod == 305
    s := 'периодический осмотр несовершеннолетних'
  endif
  if !empty(s)
    add_string('')
    add_string(center(' [' + s + ']', sh))
  endif
  return NIL

// 02.09.25 добавка по онкологии к листу учёта
Function print_luch_onk( dk,  diag, sh )

  local mm_DS1_T //:= getN018()  // N018
  local mm_usl_tip //:= getN013()
  local fname //:= prefixFileRefName( dk ) + 'shema'

  local mm_N014 //:= getn014()
  local mm_N015 //:= getn015()
  local mm_N016 //:= getn016()
  local mm_N017 //:= getn017()

  local mm_str1 := { '',  'Тип лечения',  'Цикл терапии',  'Тип терапии',  'Тип терапии',  '' }
  local mm_shema_err := { { 'соблюдён', 0 }, { 'не соблюдён', 1 } }
  local tstr
  local _arr_sh //:= ret_arr_shema( 1, dk )
  local _arr_mt //:= ret_arr_shema( 2, dk )
  local _arr_fr //:= ret_arr_shema( 3, dk )
  local mm_shema_usl
  local m1PR_CONS := 0, mDT_CONS
  local arrLekPreparat, row, w1
  Local HH := 77
  local m1usl_tip1, mm_usl_tip1, m1usl_tip2, mm_usl_tip2
  local m1crit
  local cREGNUM, cUNITCODE

  local mm_N002
  local mm_N003
  local mm_N004
  local mm_N005
  local stage

  if f_is_oncology(1) == 2 .and. eq_any( human_->USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL )

    mm_DS1_T := getN018()  // N018
    mm_usl_tip := getN013()
    fname := prefixFileRefName( dk ) + 'shema'

    mm_N014 := getn014()
    mm_N015 := getn015()
    mm_N016 := getn016()
    mm_N017 := getn017()
    _arr_sh := ret_arr_shema( 1, dk )
    _arr_mt := ret_arr_shema( 2, dk )
    _arr_fr := ret_arr_shema( 3, dk )

    dbCreate( cur_dir() + 'tmp_onkle',  { ; // Сведения о применённых лекарственных препаратах
      { 'KOD',      'N',   7,  0 }, ; // код больного
      { 'REGNUM',   'C',   6,  0 }, ; // IDD лек.препарата N020
      { 'ID_ZAP',   'N',   6,  0 }, ; // IDD лек.препарата N021
      { 'CODE_SH',  'C',  20,  0 }, ; // код схемы лек.терапии V024
      { 'DATE_INJ', 'D',   8,  0 };  // дата введения лек.препарата
    } )
    Use ( cur_dir() + 'tmp_onkle' ) New Alias TMPLE
    r_use( dir_server() + 'mo_onkle', dir_server() + 'mo_onkle',  'LE' ) // Сведения о применённых лекарственных препаратах
    find ( Str( human->kod, 7 ) )
    Do While le->kod == human->kod .and. !Eof()
      Select TMPLE
      Append Blank
      tmple->REGNUM   := le->REGNUM
      tmple->CODE_SH  := le->CODE_SH
      tmple->DATE_INJ := le->DATE_INJ
      Select LE
      Skip
    Enddo
    r_use( dir_server() + 'mo_onkco', dir_server() + 'mo_onkco',  'CO' )
    find ( Str( human->kod, 7 ) )
    If Found()
      m1PR_CONS := co->pr_cons
      mDT_CONS := co->dt_cons
    Endif
    tmple->( dbCloseArea() )
    le->( dbCloseArea() )
    co->( dbCloseArea() )

    add_string('  Онкология:')
    R_Use(dir_server() + 'mo_onksl', dir_server() + 'mo_onksl', 'ONKSL') // Сведения о случае лечения онкологического заболевания
    find (str(human->kod, 7))

    mm_N002 := f_define_tnm( 2, diag, dk )
    stage := inieditspr( A__MENUVERT, mm_N002, onksl->STAD )
    mm_N003 := f_define_tnm( 3, diag, dk, stage )
    mm_N004 := f_define_tnm( 4, diag, dk, stage )
    mm_N005 := f_define_tnm( 5, diag, dk, stage )

    add_string('   Повод обращения: ' + inieditspr(A__MENUVERT, mm_DS1_T, onksl->DS1_T))
    add_string('   Стадия заболевания: ' + alltrim( inieditspr( A__MENUVERT, mm_N002, onksl->STAD ) ) ;
      + ', Tumor: ' + alltrim( inieditspr( A__MENUVERT, mm_N003, onksl->ONK_T ) ) ;
      + ', Nodus: ' + alltrim( inieditspr( A__MENUVERT, mm_N004, onksl->ONK_N ) ) ;
      + ', Metastasis: ' + alltrim( inieditspr( A__MENUVERT, mm_N005, onksl->ONK_M ) ) )
    add_string( '   Наличие отдаленных метастазов (при рецидиве или прогрессировании): ' + alltrim( inieditspr( A__MENUVERT, mm_danet, onksl->MTSTZ ) ) )
    add_string( '' )
    tstr := space( 3 ) + 'Консилиум: ' + inieditspr( A__MENUVERT, getn019(), m1PR_CONS )
    if m1PR_CONS != 0
      tstr += ' дата ' + DToC( mDT_CONS )
    endif
    add_string( tstr )
    add_string( '' )

    add_string( space( 3 ) + 'Гистология / иммуногистохимия: ' + ;
      inieditspr( A__MENUVERT, mmb_diag(), onksl->b_diag ) )
    
    add_string( '' )
    R_Use(dir_server() + 'mo_onkus', dir_server() + 'mo_onkus', 'ONKUS')
    find (str(human->kod, 7))
    do while onkus->kod == human->kod .and. !eof()
      if between(onkus->USL_TIP, 1, 6)
        add_string('   Проведённое лечение: ' + inieditspr(A__MENUVERT, mm_usl_tip, onkus->USL_TIP))
        if eq_any(onkus->USL_TIP, 2, 4) .and. !empty(onksl->crit)
          add_string('    Схема: ' + alltrim(onksl->crit) + ' ' + inieditspr(A__POPUPEDIT, dir_exe() + fname, onksl->crit))
        endif
        if eq_any(onkus->USL_TIP, 3, 4)
          add_string('    Количество фракций: ' + lstr(onksl->k_fr))
        endif
      endif
      If ONKUS->USL_TIP == 1
        m1usl_tip1 := ONKUS->HIR_TIP
        mm_usl_tip1 := mm_N014
      Elseif ONKUS->USL_TIP == 2
        m1usl_tip1 := ONKUS->LEK_TIP_V
        mm_usl_tip1 := mm_N016
        m1usl_tip2 := ONKUS->LEK_TIP_L
        mm_usl_tip2 := mm_N015
      Elseif eq_any( ONKUS->USL_TIP, 3, 4 )
        m1usl_tip1 := ONKUS->LUCH_TIP
        mm_usl_tip1 := mm_N017
      Endif

      m1crit := onksl->crit

      If Between( ONKUS->USL_TIP, 1, 4 )
        add_string( space( 3 ) + PadR( mm_str1[ ONKUS->USL_TIP + 1 ], 12 ) + ': ' + ;
          inieditspr( A__MENUVERT, mm_usl_tip1, m1usl_tip1 ) )
        If ONKUS->USL_TIP == 2
          add_string( space( 3 ) + 'Линия терапии: ' + ;
            inieditspr( A__MENUVERT, mm_usl_tip2, m1usl_tip2 ) )
          add_string( space( 3 ) + ret_str_onc( 6, 1 ) + ': ' + ;
            inieditspr( A__MENUVERT, mm_shema_err, onksl->is_err ) )
        Endif
        If eq_any( ONKUS->USL_TIP, 2, 4 )
          tstr := ret_str_onc( 3, 1 ) + ' ' + alltrim( str_0( onksl->WEI, 5, 1 ) ) + ','
          tstr += ' ' + ret_str_onc( 4, 1 ) + ' ' + lstr( onksl->HEI ) + ','
          tstr += ' ' + ret_str_onc( 5, 1 ) + ' ' +  AllTrim( str_0( onksl->BSA, 4, 2 ) )
          add_string( space( 3 ) + tstr )
          If Left( m1crit, 2 ) == 'mt' .and. ONKUS->USL_TIP == 2
            m1crit := Space( 10 )
          Elseif eq_any( Left( m1crit, 2 ),  'не',  'sh' ) .and. ONKUS->USL_TIP == 4
            m1crit := Space( 10 )
          Endif
          If !Empty( human_2->PC3 ) .and. Left( Lower( human_2->PC3 ), 5 ) == 'gemop' // после разговора с Л.Н.Антоновой 13.01.23
            mm_shema_usl := f_valid2ad_cr( dk )  //mm_ad_cr
            m1crit := AllTrim( human_2->PC3 )
          Else
            mm_shema_usl := iif( ONKUS->USL_TIP == 2, _arr_sh, _arr_mt )
          Endif
          add_string( space( 3 ) + ret_str_onc( 7, 1 ) + ': ' + inieditspr( A__MENUVERT, mm_shema_usl, m1crit ) )
          add_string( space( 3 ) + ret_str_onc( 8, 1 ) + ': ' + init_lek_pr() )
          add_string( space( 3 ) + ret_str_onc( 9, 1 ) + ': ' + ;
            inieditspr( A__MENUVERT, mm_danet, ONKUS->pptr ) )
        Endif
      Endif
      select ONKUS
      skip
    enddo
    add_string('')
    ONKUS->( dbCloseArea() )
    ONKSL->( dbCloseArea() )

    w1 := 34
    arrLekPreparat := collect_lek_pr_onko( human->kod ) // выберем лекарственные препараты
    if len( arrLekPreparat ) != 0  // не пустой список лекарственных препаратов
      add_string( '' )
      add_string( center( 'Л_Е_К_А_Р_С_Т_В_Е_Н_Н_Ы_Е   П_Р_Е_П_А_Р_А_Т_Ы', sh ) )
      header_lek_preparat_onko( w1 )
      for each row in arrLekPreparat
        if verify_FF( HH )
          header_lek_preparat_onko( w1 )
        endif
        tstr := ''
        cREGNUM := padr( get_Lek_pr_By_ID( row[ 3 ] ), 30)
        cUNITCODE := padr( inieditspr( A__MENUVERT, get_ed_izm(), row[ 2 ] ),iif( mem_n_V034 == 0, 15, 30 ) )
        tstr := date_8( row[ 1 ] ) + ' '
        if empty( cREGNUM )
          tstr += padr( ret_schema_V032( row[ 8 ] ), 33 )
        else
          tstr += padr( cREGNUM, 33 ) + ' '
          tstr += + padr( cUNITCODE, 7 ) + ' ' ;
              + str( row[ 4 ], 8, 3 ) + ' ' ;
              + str( row[ 5 ], 8, 3 ) + ' ' ;
              + str( row[ 6 ], 15, 6 )
        endif
        add_string( tstr )
      next
    endif
  endif
  return NIL

// 29.10.22 просмотр/печать листов учёта
Function o_list_uch()

  Local j := 0, buf := savescreen(), mtitul, func_step := '', r2 := maxrow() - 2

  if polikl1_kart() > 0
    mywait()
    if yes_parol
      func_step := 'f3o_list_uch'
    endif
    Private blk_open := {|| iif(yes_parol, R_Use(dir_server() + 'base1', , 'BASE1'), nil), ;
          R_Use(dir_server() + 'mo_otd', ,'OTD'), ;
          R_Use(dir_server() + 'mo_rees', , 'REES'), ;
          R_Use(dir_server() + 'schet_', , 'SCHET_'), ;
          R_Use(dir_server() + 'schet', , 'SCHET'), ;
          dbSetRelation( 'SCHET_', {|| recno()}, 'recno()'), ;
          R_Use(dir_server() + 'human_2', , 'HUMAN_2'), ;
          R_Use(dir_server() + 'human_', , 'HUMAN_'), ;
          R_Use(dir_server() + 'human', , 'HUMAN'), ;
          dbSetRelation('HUMAN_2', {|| recno()}, 'recno()' ), ;
          dbSetRelation('HUMAN_', {|| recno()}, 'recno()' ), ;
          dbSetRelation('OTD', {|| otd}, 'otd' ), ;
          dbSetRelation('SCHET', {|| schet}, 'schet' )}
    eval(blk_open)
    set index to (dir_server() + 'humankk')
    find (str(glob_kartotek, 7))
    if found()
      mtitul := alltrim(fio)
      index on dtos(k_data) + dtos(n_data) to (cur_dir() + 'tmp_olu') while kod_k == glob_kartotek descending
      dbeval( {|| ++j } )
      go top
      if yes_parol
        r2 := maxrow() - 6
        box_shadow(maxrow() - 4, 2, maxrow() - 2, 77, color5)
      endif
      if j > 0
        Alpha_Browse(T_ROW, 2, r2, 77, 'f1o_list_uch', color5, ;
                    mtitul, 'B/W', , .t., , func_step, 'f4o_list_uch', , ;
                    {'═', '░', '═', 'N/W,W+/N,' + ;
                                 'B/W,W+/B,' + ;
                                 'R/W,W+/R,' + ;
                                 'RB/W,W+/RB,' + ;
                                 'GR/W,W+/GR,' + ;
                                 'BG+/W,W+/BG', .t.})
      endif
    else
      func_error(4, 'В базе данных нет листов учета на выбранного человека!')
    endif
    close databases
  endif
  restscreen(buf)
  return NIL

// 02.11.11
Function f1o_list_uch(oBrow)

  Local oColumn, blk := {|_i| _i := iif(between(human->tip_h, 1, 6), human->tip_h, 2), ;
                            {{1, 2}, {3, 4}, {5, 6}, {7, 8}, {9, 10}, {11, 12}}[_i] }
  //
  oColumn := TBColumnNew(' Начало; лечения', {|| date_8(human->n_data)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  //
  oColumn := TBColumnNew('Окончание; лечения', {|| date_8(human->k_data)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  //
  oColumn := TBColumnNew(' Отд.', {|| otd->short_name})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  //
  oColumn := TBColumnNew('  Стоимость;   лечения', ;
                         {|| padl(expand_value(human->cena_1, 2), 13)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew('  Примечание', {|| padr(f2o_list_uch(human->tip_h), 33)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  status_key('^<Esc>^ выход ^<Enter>^ печать л/у ^<F9>^ печать свода л/у ^<F10>^ печать справки ОМС')
  return NIL

//
Function f2o_list_uch(k)

  Static arr := {'лечится', ;
                 'не закончено лечение', ;
                 'закончено лечение', ;
                 '', ;
                 '', ;
                 ''}

  Local s
  k := iif(between(k, 1, 6), k, 4)
  s := arr[k]
  if k == B_STANDART .and. human_->reestr > 0
    rees->(dbGoto(human_->reestr))
    s := 'реестр № ' + lstr(rees->nschet) + ' от ' + date_8(rees->dschet)
  endif
  if k >= B_SCHET  // добавление номера счета
    s := 'счёт № ' + alltrim(schet_->nschet) + ' от ' + date_8(schet_->dschet)
  endif
  return s

// 12.05.2019
Function f3o_list_uch()

  Local s := 'Добавление ' + date_8(c4tod(human->date_e)) + 'г. '

  if asc(human->kod_p) > 0
    select BASE1
    goto (asc(human->kod_p))
    if !eof() .and. !empty(base1->p1)
      s += alltrim(crypt(base1->p1, gpasskod)) + ' '
    endif
  elseif human_2->PN3 > 0
    s += 'ИМПОРТ '
  endif
  if !empty(human_->DATE_E2)
    s := alltrim(s) + ', '
    s += 'исправление ' + date_8(c4tod(human_->DATE_E2)) + 'г. '
    if asc(human_->kod_p2) > 0
      select BASE1
      goto (asc(human_->kod_p2))
      if !eof() .and. !empty(base1->p1)
        s += alltrim(crypt(base1->p1, gpasskod))
      endif
    endif
  endif
  @ maxrow() - 3, 3 say padc(s, 74) color 'B/W'
  select HUMAN
  return NIL

// 31.10.22
Function f4o_list_uch(nKey, oBrow)

  Local buf, rec, k := -1, fl := .f., arr_m, arr_rec := {}

  rec := human->(recno())
  if eq_any(nkey, K_ENTER, K_F10)
    fl := .t.
    glob_perso := human->kod
  elseif nkey == K_F9
    buf := savescreen()
    change_attr()
    if (arr_m := year_month()) != NIL
      go top
      dbeval({|| aadd(arr_rec, {human->k_data, human->(recno())})}, ;
            {|| between(human->k_data, arr_m[5], arr_m[6])})
      if len(arr_rec) > 0
        fl := .t.
        asort(arr_rec, , , {|x, y| x[1] < y[1]})
      else
        goto (rec)
        func_error(4, 'Не найдено листов учета по данному больному в требуемом диапазоне времени!')
      endif
    endif
    restscreen(buf)
  endif
  if fl
    close databases
    if nkey == K_ENTER
      print_l_uch(glob_perso)
    elseif nkey == K_F9
      print_al_uch(arr_rec, arr_m)
    elseif nkey == K_F10
      print_spravka_OMS(glob_perso)
    endif
    eval(blk_open)
    set index to (cur_dir() + 'tmp_olu')
    goto (rec)
  endif
  return k

// 12.09.25 печать нескольких листов учёта
Function print_al_uch(arr_h, arr_m)

  Local sh := 80, HH := 77, buf := save_maxrow(), ;
        mvzros_reb, mrab_nerab, ;
        mkomu, name_org, mlech_vr := '', msumma := 0, ;
        mud_lich := '', arr, n_file := cur_dir() + 'list_uch.txt', adiag_talon[16], ;
        i := 1, ii, j, k, tmp[2], tmp1, w1 := 65, s, mnum_lu, lshifr1
  local diagVspom := '', diagMemory := '' 
  
  mywait()
  fp := fcreate(n_file)
  tek_stroke := 0
  n_list := 1
  //
  R_Use(dir_server() + 'organiz')
  name_org := center(alltrim(name), sh)
  dbCloseAll()
  if !myFileDeleted(cur_dir() + 'tmp1' + sdbf())
    return NIL
  endif
  dbcreate(cur_dir() + 'tmp1', {{'kod', 'N', 4, 0}, ;
                   {'name', 'C', 65, 0}, ;
                   {'shifr', 'C', 10, 0}, ;
                   {'dom', 'N', 1, 0}, ;
                   {'zf', 'C', 30, 0}, ;
                   {'kod_diag', 'C', 5, 0}, ;
                   {'date_u1', 'D', 8, 0}, ;
                   {'rec_hu', 'N', 8, 0}, ;
                   {'otd', 'C', 5, 0}, ;
                   {'plus', 'L', 1, 0}, ;
                   {'is_edit', 'N', 2, 0}, ;
                   {'kod_vr', 'N', 5, 0}, ;
                   {'kod_as', 'N', 5, 0}, ;
                   {'profil', 'N', 4, 0}, ;
                   {'kol', 'N', 4, 0}, ;
                   {'summa', 'N', 11, 2}})
  use (cur_dir() + 'tmp1')
  index on str(kod, 4) to (cur_dir() + 'tmp11')
  index on dtos(date_u1) + fsort_usl(shifr) to (cur_dir() + 'tmp12')
  dbCloseAll()
  //
  R_Use(dir_server() + 'human_', , 'HUMAN_')
  R_Use(dir_server() + 'human', , 'HUMAN')
  set relation to recno() into HUMAN_
  goto (atail(arr_h)[2])
  mpolis := alltrim(rtrim(human_->SPOLIS) + ' ' +human_->NPOLIS) + ' (' + ;
            alltrim(inieditspr(A__MENUVERT, mm_vid_polis, human_->VPOLIS)) + ')'
  R_Use(dir_server() + 'kartote_', , 'KART_')
  R_Use(dir_server() + 'kartotek', , 'KART')
  set relation to recno() into KART_
  goto (human->kod_k)
  madres := iif(emptyall(kart_->okatog, kart->adres), '', ;
                ret_okato_ulica(kart->adres, kart_->okatog))
  Private mvid_ud := kart_->vid_ud, ;
          mser    := kart_->ser_ud, ;
          mnom    := kart_->nom_ud
  if mvid_ud > 0
    mud_lich := get_Name_Vid_Ud(mvid_ud, , ': ')
    if !empty(mser)
      mud_lich += charone(' ',mser) + ' '
    endif
    if !empty(mnom)
      mud_lich += mnom + ' '
    endif
  endif
  //
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, human->vzros_reb)
  mrab_nerab := inieditspr(A__MENUVERT, menu_rab, human->rab_nerab)
  mkomu := f4_view_list_schet(human->komu, cut_code_smo(human_->smo), human->str_crb)
  mnum_lu := alltrim(human->uch_doc)
  if yes_num_lu == 1
    mnum_lu += ' [' + lstr(human->kod) + ']'
  endif
  add_string(name_org)
  add_string('')
  add_string(center('Л_И_С_Ты  У_Ч_Е_Т_А', sh))
  add_string(center('М_Е_Д_И_Ц_И_Н_С_К_И_Х  У_С_Л_У_Г  № ' + mnum_lu, sh))
  add_string(center(arr_m[4], sh))
  add_string('')
  add_string('  Ф.И.О.: ' + human->fio+ '          Пол: ' + human->pol)
  add_string('  Дата рождения: ' + full_date(human->date_r) + '  [ ' +mvzros_reb+ ' ]')
//  add_string('  СНИЛС: ' + transform(kart->SNILS, picture_pf))
  add_string( '  СНИЛС: ' + transform_SNILS( kart->SNILS ) )

  if !empty(mud_lich)
    k := perenos(tmp, mud_lich, sh-2)
    add_string('  ' + tmp[1])
    for i := 2 to k
      add_string(padl(alltrim(tmp[i]), sh))
    next
  endif
  add_string('  Адрес: ' + madres)
  if !empty(kart->mr_dol)
    add_string('  Место работы/учебы: ' + human->mr_dol)
  endif
  add_string('  Статус пациента: ' + mrab_nerab)
  add_string('  Принадлежность счета: ' + mkomu)
  // add_string('  Полис: ' + mpolis)
  add_string('  Серия и номер страхового полиса: ' + mpolis)
  //
  // R_Use(dir_server() + 'mo_uch', , 'UCH')
  R_Use(dir_server() + 'mo_otd', , 'OTD')
  R_Use(dir_server() + 'uslugi', , 'USL')
  R_Use(dir_server() + 'mo_pers', , 'PERSO')
  R_Use(dir_server() + 'schet_', , 'SCHET_')
  R_Use(dir_server() + 'schet', , 'SCHET')
  set relation to recno() into SCHET_
  R_Use(dir_server() + 'human_u_', , 'HU_')
  R_Use(dir_server() + 'human_u', dir_server() + 'human_u', 'HU')
  set relation to recno() into HU_
  R_Use(dir_server() + 'mo_su', , 'MOSU')
  R_Use(dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU')
  use (cur_dir() + 'tmp1') index (cur_dir() + 'tmp11'), (cur_dir() + 'tmp12') new alias tmp1
  for ii := 1 to len(arr_h)
    select TMP1
    set order to 1
    zap
    select HUMAN
    goto (arr_h[ii, 2])
    if human->schet > 0
      schet->(dbGoto(human->schet))
    endif
    mlech_vr := ''
    if human_->vrach > 0
      select PERSO
      goto (human_->vrach)
      mlech_vr := alltrim(perso->fio)
    endif
    //
    afill(adiag_talon, 0)
    for j := 1 to 16
      adiag_talon[j] := int(val(substr(human_->DISPANS, j, 1)))
    next
    //
    verify_FF(HH - 5, .t., sh)
    print_l_uch_disp(sh)
    add_string('')
    add_string(padc(' Срок лечения с ' + full_date(human->n_data) + ' по ' + full_date(human->k_data) + ' ', sh, '─'))
    // uch->(dbGoto(human->lpu))
    otd->(dbGoto(human->otd))
    add_string('  Условия: ' + ;
      inieditspr(A__MENUVERT, getV006(), human_->USL_OK) + ', ' + ;
      alltrim(otd->name) + ' [' + alltrim(getUCH_Name(human->lpu)) + ']')
      // alltrim(otd->name) + ' [' + alltrim(uch->name) + ']')
    s := '  '
    if !empty(human_->KOD_DIAG0)
      s := padr('  Первичный диагноз: ' + human_->KOD_DIAG0, 40)
    endif
    if !empty(human_->STATUS_ST)
      s += 'Статус стом.больного: ' + alltrim(human_->STATUS_ST)
    endif
    if !empty(s)
      add_string(s)
    endif
    diagVspom := ''
    arr := diag_to_array( , .t., .t., .t., .t., adiag_talon)
    if len(arr) > 0
      if diagnosis_for_replacement(arr[1], human_->USL_OK)
        diagVspom := alltrim(arr[1])
        diagMemory := alltrim(arr[2])
      endif
      add_string('  Основной диагноз: ' + iif(empty(diagVspom), arr[1], arr[2] + ' (!!!вспомогательный диагноз ' + diagVspom + '!!!)'))
      if len(arr) > 1
        tmp1 := '  Сопутствующие диагнозы:'
        for j := iif(empty(diagVspom), 2, 3) to len(arr)
        // for j := 2 to len(arr)
          tmp1 += ' ' + arr[j]
        next
        add_string(tmp1)
      endif
    endif
    tmp1 := ''
  
    verify_FF(HH - 6, .t., sh)
    if human_->PROFIL > 0
      add_string('  Профиль: ' + inieditspr(A__MENUVERT, getV002(), human_->PROFIL))
    endif
    add_string('  Способ оплаты: ' + inieditspr(A__MENUVERT, getV010(), human_->IDSP))
    add_string('  Результат обращения: ' + inieditspr(A__MENUVERT, getV009(), human_->RSLT_NEW))
    add_string('  Исход заболевания: ' + inieditspr(A__MENUVERT, getV012(), human_->ISHOD_NEW))
    if !empty(mlech_vr)
      add_string('  Лечащий врач : ' + mlech_vr)
    endif
    if human->bolnich > 0
      add_string('  Временная нетрудоспособность (больничный) с ' +;
                 full_date(c4tod(human->date_b_1)) + ' по ' + full_date(c4tod(human->date_b_2)))
      add_string('')
    endif
    Select HU
    find (str(arr_h[ii, 2], 7))
    do while hu->kod == arr_h[ii, 2] .and. !eof()
      if !emptyall(hu->kol_1, hu->stoim_1)
        Select OTD
        goto (hu->otd)
        Select USL
        goto (hu->u_kod)
        lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
        select TMP1
        append blank
        tmp1->kod := usl->kod
        tmp1->name := usl->name
        tmp1->shifr := usl->shifr //iif(empty(lshifr1), usl->shifr, lshifr1)
        tmp1->date_u1 := c4tod(hu->date_u)
        tmp1->dom := iif(between(hu->kol_rcp, -2, -1), -hu->kol_rcp, 0)
        tmp1->rec_hu := hu->(recno())
        tmp1->kod_diag := hu_->KOD_DIAG
        tmp1->otd := otd->short_name
        if check_files_TFOMS(year(human->k_data))
          if human->k_data < 0d20120301
            tmp1->plus := !f_paraklinika(usl->shifr, lshifr1, c4tod(hu->date_u))
          else
            tmp1->plus := !f_paraklinika(usl->shifr, lshifr1, human->k_data)
          endif
        endif
        tmp1->is_edit := hu->is_edit
        tmp1->kod_vr := hu->kod_vr
        tmp1->kod_as := hu->kod_as
        tmp1->profil := hu_->profil
        tmp1->kol += hu->kol_1
        tmp1->summa += hu->stoim_1
      endif
      select HU
      Skip
    enddo
    Select MOHU
    find (str(arr_h[ii, 2], 7))
    do while mohu->kod == arr_h[ii, 2] .and. !eof()
      if !empty(mohu->kol_1)
        Select OTD
        goto (mohu->otd)
        Select MOSU
        goto (mohu->u_kod)
        select TMP1
        append blank
        tmp1->kod := mosu->kod
        tmp1->name := mosu->name
        tmp1->shifr := iif(empty(mosu->shifr), mosu->shifr1, mosu->shifr)
        tmp1->date_u1 := c4tod(mohu->date_u)
        tmp1->rec_hu := mohu->(recno())
        tmp1->kod_diag := mohu->KOD_DIAG
        if STisZF(human_->USL_OK, human_->PROFIL)
          tmp1->zf := mohu->ZF
        endif
        tmp1->otd := otd->short_name
        tmp1->plus := .f.
        tmp1->kod_vr := mohu->kod_vr
        tmp1->kod_as := mohu->kod_as
        tmp1->kol += mohu->kol_1
        tmp1->summa += mohu->stoim_1
      endif
      select MOHU
      Skip
    enddo
    mpsumma := 0
    verify_FF(HH - 4, .t., sh)
    w1 := 34
    header_uslugi(w1)
    select TMP1
    set order TO 2
    go top
    do while !eof()
      s := alltrim(tmp1->shifr) + iif(tmp1->dom==1, '/на дому/', iif(tmp1->dom==2, '/домАКТИВ/', ' ')) + alltrim(tmp1->name)
      if eq_any(alltrim(tmp1->shifr), '2.3.1', '2.3.3', '2.6.1', '2.60.1')
        s += ' (' + alltrim(inieditspr(A__MENUVERT, getV002(), tmp1->PROFIL)) + ')'
      elseif !empty(tmp1->zf)
        s += ' ЗФ:' + alltrim(tmp1->ZF)
      endif
      k := perenos(tmp, s, w1)
      if verify_FF(HH)
        header_uslugi(w1)
      endif
      s := date_8(tmp1->date_u1) + ' '
      if tmp1->is_edit == 1
        s += 'КДП№2 '
      elseif tmp1->is_edit == 2
        s += ' РДЛ  '
      elseif tmp1->is_edit == 4
        s += 'ПАбюро'
      elseif tmp1->is_edit == 5
        s += 'ПАпроч'
      elseif tmp1->is_edit == -1
        s += 'ЦКДЛ  '
      elseif alltrim(tmp1->shifr) == '4.20.2' .or. tmp1->is_edit == 3
        s += 'ВОКОД '
      else
        s += tmp1->otd+ ' '
      endif
      s += tmp1->kod_diag+ ' '
      s += padr(tmp[1], w1)
      s += put_val(ret_tabn(tmp1->kod_vr), 6) + ;
           put_val(ret_tabn(tmp1->kod_as), 6)
      if tmp1->plus
        s += padl(' + ' + lstr(tmp1->kol), 4)
        mpsumma += tmp1->summa
      else
        s += put_val(tmp1->kol, 4)
        msumma += tmp1->summa
      endif
      s += put_kopE(tmp1->summa, 9)
      add_string(s)
      for i := 2 to k
        add_string(space(21) + padl(rtrim(tmp[i]), w1))
      next
      select TMP1
      skip
    enddo
    add_string(padl(replicate('-', 33), sh))
    s := 'Общая сумма лечения: ' + put_kop(human->cena_1, 12)
    if mpsumma > 0
      s := alltrim(s) + ' (+ ' + lput_kop(mpsumma, .t.) + ')'
    endi
    add_string(padl(s, sh))
  next
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(n_file, , , ,.f., , ,5)
  return NIL

// 27.11.14
Function create_FR_file_for_spravkaOMS()

  dbCloseAll()
  delFRfiles()
  dbcreate(fr_titl, {{'name', 'C', 255, 0}, ;
                    {'adres', 'C', 255, 0}, ;
                    {'data', 'D', 8, 0}, ;
                    {'data1', 'D', 8, 0}, ;
                    {'data2', 'D', 8, 0}, ;
                    {'fio', 'C', 60, 0}})
  use (fr_titl) new alias FRT
  append blank
  frt->name := glob_mo[_MO_FULL_NAME]
  frt->adres := glob_mo[_MO_ADRES]
  dbcreate(fr_data, {{'name', 'C', 255, 0}, ;
                    {'name1', 'C', 55, 0}, ;
                    {'shifr', 'C', 10, 0}, ;
                    {'kol', 'N', 4, 0}, ;
                    {'cena', 'N', 11, 2}, ;
                    {'summa', 'N', 11, 2}})
  use (fr_data) new alias FRD
  index on shifr to (cur_dir() + 'tmp1')
  return NIL

// 15.12.23 печать справки ОМС по готовому листу учёта
Function print_spravka_OMS(mkod)
  // mkod - код больного по БД human
  Local r1, c1, r2, c2, mdate, buf := save_maxrow(), msumma := 0, lshifr
  local tmpAlias
  local lExistFilesTFOMS

  get_row_col_max(18, 4, @r1, @c1, @r2, @c2)
  if (mdate := input_value(r1, c1, r2, c2, color1, ;
        'Введите дату выдачи справки о стоимости мед.помощи по ОМС', ;
        sys_date)) == NIL
    return NIL
  endif
  mywait()
  create_FR_file_for_spravkaOMS()
  Use_base('lusl')
  Use_base('luslf')
  R_Use(dir_server() + 'uslugi1', {dir_server() + 'uslugi1', ;
                              dir_server() + 'uslugi1s'}, 'USL1')
  R_Use(dir_server() + 'uslugi', , 'USL')
  R_Use(dir_server() + 'human_u', dir_server() + 'human_u', 'HU')
  R_Use(dir_server() + 'human_', , 'HUMAN_')
  goto (mkod)
  R_Use(dir_server() + 'human', , 'HUMAN')
  goto (mkod)
  if mdate < human->k_data
    rest_box(buf)
    close databases
    return func_error(4, 'Дата выдачи справки меньше даты окончания лечения!')
  endif
  tmpAlias := create_name_alias('LUSL',  year(human->k_data))
  if ! (lExistFilesTFOMS := check_files_TFOMS(year(human->k_data)))  // проверим наличие справочников ТФОМС
    func_error(4, 'Отсутствуют справочники ТФОМС за ' + str(year(human->k_data), 4) +' год.' )
  endif

  frt->data := mdate
  frt->data1 := human->n_data
  frt->data2 := human->k_data
  frt->fio := human->fio
  Select HU
  find (str(mkod, 7))
  do while hu->kod == mkod .and. !eof()
    if !emptyany(hu->kol_1, hu->stoim_1)
      usl->(dbGoto(hu->u_kod))
      lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
      if lExistFilesTFOMS
        if is_usluga_TFOMS(usl->shifr,lshifr, human->k_data)
          lshifr := iif(empty(lshifr), usl->shifr, lshifr)
          select LUSL
          find (padr(lshifr, 10))
          Select FRD
          find (padr(lshifr, 10))
          if !found()
            append blank
            frd->shifr := lshifr
            frd->name := lusl->name  // наименование услуги из справочника ТФОМС
            frd->cena := hu->stoim_1 / hu->kol_1
          endif
          frd->kol += hu->kol_1
          frd->summa += hu->stoim_1
          msumma += hu->stoim_1
        endif
      else
        lshifr := iif(empty(lshifr), usl->shifr, lshifr)
        Select FRD
        find (padr(lshifr, 10))
        if !found()
          append blank
          frd->shifr := lshifr
          frd->name := 'Отсутствуют справочники ТФОМС за ' + str(year(human->k_data), 4) +' год.'
          frd->cena := hu->stoim_1 / hu->kol_1
        endif
        frd->kol += hu->kol_1
        frd->summa += hu->stoim_1
        msumma += hu->stoim_1
    endif
    endif
    select HU
    Skip
  enddo
  Select FRD
  go top
  do while !eof()
    if frd->kol > 1
      frd->name1 := ' (в количестве ' + lstr(frd->kol) + ')'
    endif
    Skip
  enddo
  index on str(summa, 11, 2) to (fr_data) descending
  G_Use(dir_server() + 'mo_sprav', , 'SPR_OMS')
  Locate for kod_h == mkod
  if found()
    G_RLock(forever)
  else
    append blank
    spr_oms->KOD_H  := mkod
    spr_oms->KOD_K  := 0
  endif
  spr_oms->FIO    := human->FIO
  spr_oms->DATE_R := human->DATE_R
  spr_oms->DATA   := mdate
  spr_oms->N_DATA := human->n_data
  spr_oms->K_DATA := human->k_data
  if human_->USL_OK == USL_OK_HOSPITAL
    spr_oms->TIP := 2  // стационар
  elseif human_->USL_OK == USL_OK_DAY_HOSPITAL
    spr_oms->TIP := 3  // дневной стационар
  else
    spr_oms->TIP := 1  // амбулаторно
  endif
  spr_oms->STOIM  := human->CENA_1
  close databases
  rest_box(buf)
  call_fr('mo_spravkaOMS')
  return NIL

// 27.11.14 Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС')
Function f_spravka_OMS()

  Local i, j, k, k1, buf := savescreen(), rec_spr_oms := 0

  k1 := polikl1_kart()
  close databases // если вдруг вышли по <Esc>
  //
  Private mfio := space(50), mdate_r := ctod(''), ;
        mdate := sys_date, mn_data := sys_date, mk_data := sys_date, ;
        mstoim := 0, m1usl := 1, musl := ' ', parr_usl := {}, ;
        p_box_buf, gl_area := {1, 0, 23, 79, 0}

  if k1 > 0
    R_Use(dir_server() + 'kartotek', , 'KART')
    goto (glob_kartotek)
    mfio    := kart->fio
    mdate_r := kart->date_r
    close databases
  endif
  Private r1 := maxrow() - 18
  do while .t.
    setcolor(cDataCGet)
    ClrLines(r1, maxrow() - 1)
    @ r1 - 1, 0 say padc('Справка ОМС', 80) color 'B/B*'
    if p_box_buf != NIL
      rest_box(p_box_buf)
    endif
    i := r1 + 1
    if k1 == 0
      @ i, 1 say 'Пациент' get mfio pict '@!'
      @ row(), col() + 2 say 'Дата р.' get mdate_r
    else
      @ i, 1 say 'Пациент' color 'G+/B' get mfio when .f.
      @ row(), col() + 2 say 'Дата р.' color 'G+/B' get mdate_r when .f.
    endif
    @ ++i, 1 say 'Сроки лечения: с' get mn_data
    @ row(), col() + 1 say 'по' get mk_data
    @ row(), col() + 7 say 'Дата выдачи справки' get mdate ;
                        valid {|| __keyboard(CHR(K_ENTER)), .t. }
    @ ++i, 1 say 'Оказанные услуги:' color color8 get musl ;
              reader {|x|menu_reader(x, {{|k, r, c| fu_spravka_OMS(r, c)}}, A__FUNCTION,,, .f.)}
    status_key('^<Esc>^ - выход для печати')
    myread()
    do while (k := f_alert({padc('Выберите действие', 60, '.')}, ;
              {' Выход ', ' Печать справки ', ' Возврат в редактирование '}, ;
              2, 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N, N/BG' )) == 0
    enddo
    if k == 1
      exit
    elseif k == 2
      if empty(mfio)
        func_error(4, 'Не введены Ф.И.О.')
        loop
      endif
      if empty(mdate)
        func_error(4, 'Не введена дата выдачи справки.')
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
      if mdate < mk_data
        func_error(4, 'Дата выдачи справки меньше даты окончания лечения.')
        loop
      endif
      if mk_data < mn_data
        func_error(4, 'Дата окончания лечения меньше даты начала лечения.')
        loop
      endif
      mstoim := 0 ; mtip := 2 // стационар
      for i := 1 to len(parr_usl)
        mstoim += parr_usl[i, 2] * parr_usl[i, 3]
        if left(parr_usl[i, 5], 3) == '55.'
          mtip := 3  // дневной стационар
          exit
        elseif left(parr_usl[i, 5], 2) == '2.' .or. eq_any(left(parr_usl[i, 5], 3), '57.', '60.', '70.', '72.')
          mtip := 1  // амбулаторно
          exit
        endif
      next
      if empty(mstoim)
        func_error(4, 'Не введены услуги.')
        loop
      endif
      create_FR_file_for_spravkaOMS()
      Use_base('lusl')
      frt->data := mdate
      frt->data1 := mn_data
      frt->data2 := mk_data
      frt->fio := mfio
      for i := 1 to len(parr_usl)
        if !emptyany(parr_usl[i, 2], parr_usl[i, 3])
          select LUSL
          find (padr(parr_usl[i, 5], 10))
          Select FRD
          find (padr(parr_usl[i, 5], 10))
          if !found()
            append blank
            frd->shifr := parr_usl[i, 5]
            frd->name := lusl->name  // наименование услуги из справочника ТФОМС
            frd->cena := parr_usl[i, 3]
          endif
          frd->kol += parr_usl[i, 2]
          frd->summa += parr_usl[i, 2] * parr_usl[i, 3]
        endif
      next
      Select FRD
      go top
      do while !eof()
        if frd->kol > 1
          frd->name1 := ' (в количестве ' + lstr(frd->kol) + ')'
        endif
        Skip
      enddo
      index on str(summa, 11, 2) to (fr_data) descending
      G_Use(dir_server() + 'mo_sprav', , 'SPR_OMS')
      if rec_spr_oms == 0
        append blank
        spr_oms->KOD_H  := 0
        spr_oms->KOD_K  := iif(k1 > 0, glob_kartotek, 0)
        rec_spr_oms := recno()
      else
        goto (rec_spr_oms)
        G_RLock(forever)
      endif
      spr_oms->FIO    := mFIO
      spr_oms->DATE_R := mDATE_R
      spr_oms->DATA   := mdate
      spr_oms->N_DATA := mn_data
      spr_oms->K_DATA := mk_data
      spr_oms->TIP    := mtip
      spr_oms->STOIM  := mstoim
      close databases
      call_fr('mo_spravkaOMS')
    endif
  enddo
  restscreen(buf)
  return NIL

// 27.11.14
Function fu_spravka_OMS(r, c)

  Local arr_title := {{1,' Шифр усл.'}, ;
                      {2,'Кол'}, ;
                      {3,'   Цена   '}, ;
                      {4,' Наименование услуги'}}
  local mpic := {, {3, 0}, {10, 2}}, tmp_color := setcolor('W+/B, W+/RB'), i
  local blk := {|b, ar, nDim, nElem, nKey| fu2spravka_OMS(b, ar, nDim, nElem, nKey)}

  if emptyany(mdate_r, mn_data, mk_data)
    func_error(4, 'Проверьте правильность ввода даты рождения и сроков лечения')
  else
    @ r, c say space(10) color 'B/B'
    Private mvzros_reb := iif(count_years(mdate_r, mn_data) < 18, 1, 0)
    if len(parr_usl) == 0
      aadd(parr_usl, {space(10), 1, 0, space(40), ''})
    endif
    Use_base('lusl')
    Use_base('luslc')
    R_Use(dir_server() + 'uslugi', dir_server() + 'uslugish', 'USL')
    Arrn_Browse(r + 1, 2, maxrow() - 2, 77, parr_usl, arr_title, 1, , , , , .t., , mpic,blk, {.t., .t., .t.})
    p_box_buf := save_box(r + 1, 0, maxrow() - 1, 79)
    close databases
  endif
  setcolor(tmp_color)
  return {1, ' '}

// 27.11.14
Function fu2spravka_OMS(b, ar, nDim, nElem, nKey)

  LOCAL nRow := ROW(), nCol := COL(), i, j, flag := .f., fl, lshifr, lshifr1

  DO CASE
    CASE nKey == K_DOWN .or. nKey == K_INS
      b:panHome()
    CASE nKey == K_LEFT
      b:left()
    CASE nKey == K_RIGHT
      if nDim == 1
        b:right()
      endif
    OTHERWISE
      if (nKey == K_ENTER .or. between(nKey, 48, 57)) .and. nDim < 3
        if nDim == 1 .and. empty(parr[nElem, nDim])
          if between(nKey, 48, 57)
            keyboard chr(nKey)
          endif
          Private mshifr := space(10)
          @ nRow, nCol GET mshifr picture '@!' valid valid_shifr()
          myread()
          if lastkey() != K_ESC
            lshifr := mname := ''
            select USL
            find (mshifr)
            if found()
              mname := usl->name
              lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, mk_data)
              if is_usluga_TFOMS(usl->shifr, lshifr1, mk_data)
                lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
              else
                func_error(4, 'Это не услуга ТФОМС: ' + lshifr1)
              endif
            else
              select LUSL
              find (mshifr)
              if found()
                lshifr := lusl->shifr
                mname := lusl->name
              else
                func_error(4, 'Это не услуга ТФОМС: '+mshifr)
              endif
            endif
            if !empty(lshifr)
              fl_del := fl_uslc := .f.
              glob_podr := ''
              glob_otd_dep := 0
              v := fcena_oms(lshifr, ;
                           (mvzros_reb == 0), ;
                           mk_data, ;
                           @fl_del, ;
                           @fl_uslc)
              if fl_uslc  // если нашли в справочнике ТФОМС
                if fl_del
                  func_error(4, 'Цена на услугу ' + rtrim(lshifr) + ' отсутствует в справочнике ТФОМС')
                else
                  fl := .t.
                  parr[nElem, 1] := mshifr
                  if empty(parr[nElem, 2])
                    parr[nElem, 2] := 1
                  endif
                  parr[nElem, 3] := v
                  parr[nElem, 4] := left(mname, 40)
                  parr[nElem, 5] := lshifr
                  b:right()
                  b:refreshAll() ; flag := .t.
                endif
              else
                func_error(4, 'Не найдена услуга в справочнике ТФОМС: '+lshifr)
              endif
            endif
          endif
        elseif nDim == 2
          if between(nKey, 48, 57)
            keyboard chr(nKey)
          endif
          Private mkol := parr[nElem, nDim]
          @ nRow, nCol GET mkol picture '999'
          myread()
          if lastkey() != K_ESC .and. mkol >= 0
            parr[nElem, 2] := mkol
            flag := .t.
          endif
        endif
      else
        keyboard ''
      endif
  ENDCASE
  @ nRow, nCol SAY ''
  return flag

// 27.11.14 Отчёт о количестве выданных справок ОМС
Function f_otchet_spravka_OMS()

  Local arr_m, buf := save_maxrow(), as := {0, 0, 0}, sh := 80, HH := 80, ;
      i, n_file := cur_dir() + 'o_sprOMS.txt'

  if (arr_m := year_month()) != NIL
    mywait()
    R_Use(dir_server() + 'mo_sprav', , 'SPR_OMS')
    index on data to (cur_dir() + 'tmp') for between(data, arr_m[5], arr_m[6])
    go top
    do while !eof()
      i := 1
      if between(spr_oms->TIP, 1, 3)
        i := spr_oms->TIP
      endif
      as[i] ++
      skip
    enddo
    Use
    fp := fcreate(n_file)
    n_list := 1
    tek_stroke := 0
    add_string(glob_mo[_MO_SHORT_NAME])
    add_string(padl('Приложение 3', sh))
    add_string(padl('к Приказу МЗВО и ТФОМС', sh))
    add_string(padl('№2841/758 от 29.10.2014г.', sh))
    add_string('')
    add_string(center('Отчёт', sh))
    add_string(center('О количестве справок о стоимости оказанной медицинской помощи в', sh))
    add_string(center('сфере ОМС, выданных застрахованным лицам в медицинских организациях', sh))
    add_string(center(arr_m[4], sh))
    add_string('')
    add_string('────────────────────────────────────────────────────────────────────────────────')
    add_string('      Количество проинформированных пациентов с выдачей справок о стоимости     ')
    add_string('                      медицинской помощи в сфере ОМС                            ')
    add_string('──────────────────────────┬──────────────────────────┬──────────────────────────')
    add_string(' в амбулаторно-поликлини- │  в условиях стационара   │     в условиях дневного  ')
    add_string('     ческих условиях      │                          │         стационара       ')
    add_string('──────────────────────────┴──────────────────────────┴──────────────────────────')
    add_string('')
    add_string(padc(lstr(as[1]), 26) + ' ' + padc(lstr(as[2]), 26) + ' ' + padc(lstr(as[3]), 26))
    add_string('')
    add_string('────────────────────────────────────────────────────────────────────────────────')
    fclose(fp)
    rest_box(buf)
    viewtext(n_file, , , , .f., , , 2)
  endif
  return NIL
