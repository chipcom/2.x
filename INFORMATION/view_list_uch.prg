** view_lists_uch.prg - просмотр листов учета по ОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 29.10.22
Function print_l_uch(mkod, par, regim, lnomer)
  // mkod - код больного по БД human
  Local sh := 80, HH := 77, buf := save_maxrow(), ;
      name_lpu, name_otd := '', mvzros_reb, mreg_lech, mmest_inog, mrab_nerab, ;
      mkomu, name_org, mlech_vr := '', mishod, mprodol, msumma := 0, mmi_git, ;
      mud_lich := '', arr, n_file := cur_dir + 'list_uch' + stxt, adiag_talon[16], ;
      madres, i := 1, j, k, tmp[2], tmp1, w1 := 37, s, s1, mnum_lu, lshifr1
  local tmpAlias
  local arrLekPreparat, arrImplantant, aNameImp, aSerNum, nNameImp, nSerNum, row
  local cREGNUM, cUNITCODE, cMETHOD
  local lTypeLUMedReab := .f., aMedReab
  local diagVspom := '', diagMemory := '', add_criteria
  local arrKSLP, akslp, len_akslp, arrKIRO, akiro
  local k_kslp, tmp_kslp := {}
  local k_kiro, tmp_kiro := {}

  DEFAULT par TO 1, regim TO 1, lnomer TO 0
  mywait()
  fp := fcreate(n_file)
  tek_stroke := 0
  n_list := 1
  //
  R_Use(dir_server + 'organiz', , 'ORG')
  name_org := alltrim(org->name)
  dbCloseAll()
  if !myFileDeleted(cur_dir + 'tmp1' + sdbf)
    return NIL
  endif
  dbcreate(cur_dir + 'tmp1', {{'kod', 'N', 4, 0}, ;
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
  use (cur_dir + 'tmp1')
  index on str(kod, 4) to (cur_dir + 'tmp11')
  index on dtos(date_u1) +fsort_usl(shifr) to (cur_dir + 'tmp12')
  use (cur_dir + 'tmp1') index (cur_dir + 'tmp11'), (cur_dir + 'tmp12') alias tmp1
  Use_base('lusl')
  Use_base('luslf')
  R_Use(dir_server + 'uslugi', , 'USL')
  R_Use(dir_server + 'human_u_', , 'HU_')
  R_Use(dir_server + 'human_u',dir_server + 'human_u', 'HU')
  set relation to recno() into HU_
  R_Use(dir_server + 'mo_su', , 'MOSU')
  R_Use(dir_server + 'mo_hu',dir_server + 'mo_hu', 'MOHU')
  R_Use(dir_server + 'mo_otd', , 'OTD')
  R_Use(dir_server + 'human_3',{dir_server + 'human_3',dir_server + 'human_32'}, 'HUMAN_3')
  R_Use(dir_server + 'human_2', , 'HUMAN_2')
  goto (mkod)
  R_Use(dir_server + 'human_', , 'HUMAN_')
  goto (mkod)
  R_Use(dir_server + 'human', , 'HUMAN')
  goto (mkod)
  R_Use(dir_server + 'mo_pers', , 'PERSO')
  goto (human_->vrach)
  mlech_vr := iif(empty(perso->tab_nom), '', lstr(perso->tab_nom) + ' ') + alltrim(perso->fio)
  otd->(dbGoto(human->otd))
  R_Use(dir_server + 'kartote_', , 'KART_')
  goto (human->kod_k)
  R_Use(dir_server + 'kartotek', , 'KART')
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
    mud_lich := ''
    if (j := ascan(menu_vidud, {|x| x[2] == mvid_ud})) > 0
      mud_lich := menu_vidud[j, 4] + ': '
    endif
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
    R_Use(dir_server + 'schet_', , 'SCHET_')
    goto (human->schet)
    R_Use(dir_server + 'schet', , 'SCHET')
    goto (human->schet)
    add_string('Счет № ' + alltrim(schet_->nschet) + ' от ' +date_8(schet_->dschet) + 'г.' +;
             if(human_->SCHET_ZAP==0, '', '  [ № ' + lstr(human_->SCHET_ZAP) + ' ]'))
    if eq_any(human_->oplata, 2, 3, 9)
      s := iif(eq_any(human_->oplata, 2, 9), 'Не', 'Частично') + ' оплачен. '
      if human_->oplata == 3
        s += '(' + lstr(human_->sump) + ') '
      endif
      R_Use(dir_server + 'mo_os', , 'MO_OS')
      Locate for kod == mkod
      if found()
        s += 'Акт № ' + alltrim(mo_os->AKT) + ' от ' +date_8(mo_os->DATE_OPL) + ' '
        if !empty(s1 := ret_t005(mo_os->REFREASON))
          s += 'Код дефекта ' +s1+ '. '
        endif
        if mo_os->IS_REPEAT == 1
          s += 'Лист учёта выставлен повторно.'
        endif
      else
        R_Use(dir_server + 'mo_rak', , 'RAK')
        R_Use(dir_server + 'mo_raks', , 'RAKS')
        set relation to akt into RAK
        R_Use(dir_server + 'mo_raksh', , 'RAKSH')
        set relation to kod_raks into RAKS
        arr := {}
        Locate for kod_h == mkod
        do while found()
          aadd(arr, {rak->NAKT, rak->DAKT, raksh->REFREASON, raksh->NEXT_KOD})
          continue
        enddo
        asort(arr, , ,{|x,y| x[2] < y[2] })
        for i := 1 to len(arr)
          s += 'Акт № ' + alltrim(arr[i, 1]) + ' от ' +date_8(arr[i, 2]) + '. '
          if !empty(s1 := ret_t005(arr[i, 3]))
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
  name_lpu := rtrim(inieditspr(A__POPUPMENU, dir_server + 'mo_uch', human->lpu))
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
  add_string('  Статус пациента: ' + mrab_nerab)
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
  add_string('                     Серия и номер страхового полиса: ' + mpolis)
  if M1F14_EKST == 1
    s := '  Госпитализирован по экстренным показаниям'
    if M1F14_SKOR == 1
      s += ' (доставлен скорой мед.помощью)'
    endif
    add_string(s)
  endif
  s := ''
  if eq_any(human->ishod, 201, 202, 203, 401, 402 )  // дисп-ия (профосмотр) взрослого населения
    Private pole_diag, pole_1pervich
    for i := 1 to 5
      pole_diag := 'mdiag' + lstr(i)
      pole_1pervich := 'm1pervich' + lstr(i)
      Private &pole_diag := space(6)
      Private &pole_1pervich := 0
    next
    read_arr_DVN(human->kod)
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
    if eq_any(alltrim(arr[1]), 'Z92.2', 'Z92.4')
      diagVspom := alltrim(arr[1])
      diagMemory := alltrim(arr[2])
    endif
    add_string('  Основной диагноз: ' + iif(empty(diagVspom), arr[1], arr[2] + ' (!!!вспомогательный диагноз ' + diagVspom + '!!!)'))
    if year(human->k_data) > 2017 .and. !empty(human_2->pc3)
      k := 0
      add_string('  Дополнительный критерий : ')
      add_criteria := getArrayCriteria(human->K_DATA, human_2->pc3)
      if ! empty(add_criteria)
          k := perenos(tmp, alltrim(human_2->pc3) + ' - ' + alltrim(add_criteria[6]), sh - 3)
          for i := 1 to k
            add_string(space(3) + tmp[i])
          next
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
    k := perenos(tmp, 'профиль: ' + inieditspr(A__MENUVERT, glob_V002, human_->PROFIL), sh - 4)
    add_string(space(4) + tmp[1])
    for i := 2 to k
      add_string(padl(alltrim(tmp[i]), sh))
    next
  endif
  if human_2->PROFIL_K > 0 .and. human_->USL_OK < 3
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
  print_luch_onk(sh)
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
      select LUSL
      find (padr(usl->shifr, 10))
      if found()
        lname := lusl->name  // наименование услуги из справочника ТФОМС
      else
        select LUSL19
        find (padr(usl->shifr, 10))
        if found()
          lname := lusl19->name  // наименование услуги из справочника ТФОМС
        else
          select LUSL18
          find (padr(usl->shifr, 10))
          if found()
            lname := lusl18->name  // наименование услуги из справочника ТФОМС
          endif
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
      if human->k_data < 0d20120301
        tmp1->plus := !f_paraklinika(usl->shifr, lshifr1, c4tod(hu->date_u))
      else
        tmp1->plus := !f_paraklinika(usl->shifr, lshifr1, human->k_data)
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
      tmpAlias := create_name_alias('LUSLF',  year(human->k_data))
      select (tmpAlias)
      find (padr(mosu->shifr1, 20))
      if found()
        lname := (tmpAlias)->name  // наименование услуги из справочника ТФОМС
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
      s += ' (' + alltrim(inieditspr(A__MENUVERT, glob_V002, tmp1->PROFIL)) + ')'
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
    if eq_any(human->ishod, 401, 402 ) .and. tmp1->kod_vr == 0 
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
                arrKSLP := getInfoKSLP(human->k_data, akslp[i])
                s1 += alltrim(str(arrKSLP[1])) + '. ' + arrKSLP[3] + ', коэф.=' + str(arrKSLP[4], 4, 2) + ') '
              next
            else
              len_akslp := len(akslp) / 2
              for i := 1 to len_akslp
                arrKSLP := getInfoKSLP(human->k_data, akslp[i * 2 - 1])
                s1 += alltrim(str(arrKSLP[1])) + '. ' + arrKSLP[3] + ', коэф.=' + str(arrKSLP[4], 4, 2) + ') '
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
            arrKIRO := getInfoKIRO(human->k_data, akiro[1])
            s1 += alltrim(str(arrKIRO[1])) + '. ' + arrKIRO[3] + ', коэф.=' + str(arrKIRO[4], 4, 2) + ') '
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
    // elseif human_->USL_OK == 1 // стационар
      //   altd()
      //   s := iif(empty(tmp1->shifr1), tmp1->shifr, tmp1->shifr1)
      //   if human_->USL_OK < 3 .and. !empty(human_2->pc1)
      //     akslp := List2Arr(human_2->pc1)
      //     if len(akslp) > 1 .and. valtype(akslp) == 'N'
      //       arrKSLP := getKSLPtable(human->k_data)
      //       // s1 += '(с учётом КСЛП=' + str(akslp[2], 4, 2) + ')'
      //       s1 += '(с учётом КСЛП='
      //       if year(human->k_data) >= 2021
      //         for i := 1 to len(akslp)
      //           arrKSLP := getInfoKSLP(human->k_data, akslp[i])
      //           s1 += arrKSLP[3] + ', коэф.=' + str(arrKSLP[4], 4, 2) + ') '
      //         next
      //       else
      //         len_akslp := len(akslp) / 2
      //         for i := 1 to len_akslp
      //           arrKSLP := getInfoKSLP(human->k_data, akslp[i * 2 - 1])
      //           s1 += arrKSLP[3] + ', коэф.=' + str(arrKSLP[4], 4, 2) + ') '
      //         next
      //         k_kslp := perenos(tmp_kslp, s1, w1)
      //       endif
      //     endif
      //   endif
      endif
    endif
    if eq_any(human->ishod, 401, 402 ) .and. tmp1->kod_vr == 0 
      // УГЛУБЛЕННАЯ дисп-ия взрослого населения
    else
      // for i := 2 to k
      //   add_string(space(21) + padl(rtrim(tmp[i]), w1))
      // next
      // if !empty(tmp_kslp)
      //   // add_string(space(21) + s1)
      //   add_string(space(21) + tmp_kslp[1])
      //   for i := 2 to k_kslp
      //     add_string(space(21) + padl(rtrim(tmp_kslp[i]), w1))
      //   next
      // endif
      // if !empty(tmp_kiro)
      //   add_string(space(21) + tmp_kiro[1])
      //   for i := 2 to k_kiro
      //     add_string(space(21) + padl(rtrim(tmp_kiro[i]), w1))
      //   next
      // endif
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

  arrLekPreparat := collect_lek_pr(mkod) // выберем лекарственные препараты
  if len(arrLekPreparat) != 0  // не пустой список лекарственных препаратов
    add_string('')
    add_string(center('Л_Е_К_А_Р_С_Т_В_Е_Н_Н_Ы_Е   П_Р_Е_П_А_Р_А_Т_Ы', sh))
    header_lek_preparat(w1)
    for each row in arrLekPreparat
      if verify_FF(HH)
        header_lek_preparat(w1)
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

  arrImplantant := collect_implantant(mkod) // выберем имплантант
  if ! empty(arrImplantant)
    add_string('')
    add_string(center('У_С_Т_А_Н_О_В_Л_Е_Н_Н_Ы_Е   И_М_П_Л_А_Н_Т_А_Н_Т_Ы', sh))
    header_implantant(w1)
    for each row in arrImplantant
      s := ''
      s := date_8(row[3]) + ' '
      s := s + ;
          padr(inieditspr(A__MENUVERT, get_implantant(), row[4]), 40) + ' ' + ;
          padr(row[5], 35)
      add_string(s)
    next
  endif

  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(n_file, , , , .f., , , 5)
  return NIL

**
Function header_implantant(w1)
  add_string('────────┬────────────────────────────────────────┬──────────────────────────────')
  add_string('  Дата  │Наименование имплантанта                │Серийный номер')
  add_string('────────┴────────────────────────────────────────┴──────────────────────────────')
  return NIL

**
Function header_lek_preparat(w1)
  add_string('────────┬─────────────────────────────────┬──────┬───────┬───────────────┬──────')
  add_string('  Дата  │Наименование препарата или группы│Доз-ка│Единица│Способ введения│Кол-во')
  add_string('────────┴─────────────────────────────────┴──────┴───────┴───────────────┴──────')
  return NIL
  
**
Function header_uslugi(w1)
  add_string('────────┬─────┬─────┬' +replicate('─', w1)              + '┬─────┬─────┬───┬────────')
  add_string('  Дата  │ Отд.│МКБ10│' +padc('Наименование услуги', w1) + '│ Врач│ Асс.│Кол│ Сумма  ')
  add_string('────────┴─────┴─────┴' +replicate('─', w1)              + '┴─────┴─────┴───┴────────')
  return NIL


** 02.11.22 печать доп.заголовка, если это лист учёта диспансеризации/профилактики
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

** 02.11.22 добовка по онкологии к листу учёта
Function print_luch_onk(sh)
  Static mm_DS1_T := {{'первичное лечение', 0}, ;  // N019
                      {'лечение при рецидиве', 1}, ;
                      {'лечение при прогрессировании', 2}, ;
                      {'динамическое наблюдение', 3}, ;
                      {'диспансерное наблюдение (здоров/ремиссия)', 4}, ;
                      {'диагностика (без специфического лечения)', 5}, ;
                      {'симптоматическое лечение', 6}}
  Static mm_usl_tip := {{'Хирургическое лечение', 1}, ;
                      {'Лекарственная противоопухолевая терапия', 2}, ;
                      {'Лучевая терапия', 3}, ;
                      {'Химиолучевая терапия', 4}, ;
                      {'Неспецифическое лечение (катетер, прочее)', 5}, ;
                      {'Диагностика', 6}}

  if f_is_oncology(1) == 2 .and. human_->USL_OK < 3
    add_string('  Онкология:')
    R_Use(dir_server + 'mo_onksl', dir_server + 'mo_onksl', 'ONKSL') // Сведения о случае лечения онкологического заболевания
    find (str(human->kod, 7))
    add_string('   Повод обращения: ' + inieditspr(A__MENUVERT, mm_DS1_T, onksl->DS1_T))
    R_Use(dir_server + 'mo_onkus', dir_server + 'mo_onkus', 'ONKUS')
    find (str(human->kod, 7))
    do while onkus->kod == human->kod .and. !eof()
      if between(onkus->USL_TIP, 1, 6)
        add_string('   Проведённое лечение: ' + inieditspr(A__MENUVERT, mm_usl_tip, onkus->USL_TIP))
        if eq_any(onkus->USL_TIP, 2, 4) .and. !empty(onksl->crit)
          add_string('    Схема: ' + alltrim(onksl->crit) + ' ' + inieditspr(A__POPUPEDIT, exe_dir + '_mo9shema', onksl->crit))
        endif
        if eq_any(onkus->USL_TIP, 3, 4)
          add_string('    Количество фракций: ' + lstr(onksl->k_fr))
        endif
      endif
      select ONKUS
      skip
    enddo
    add_string('')
  endif
  return NIL

** 29.10.22 просмотр/печать листов учёта
Function o_list_uch()
  Local j := 0, buf := savescreen(), mtitul, func_step := '', r2 := maxrow() - 2

  if polikl1_kart() > 0
    mywait()
    if yes_parol
      func_step := 'f3o_list_uch'
    endif
    Private blk_open := {|| iif(yes_parol, R_Use(dir_server + 'base1', , 'BASE1'), nil), ;
          R_Use(dir_server + 'mo_otd', ,'OTD'), ;
          R_Use(dir_server + 'mo_rees', , 'REES'), ;
          R_Use(dir_server + 'schet_', , 'SCHET_'), ;
          R_Use(dir_server + 'schet', , 'SCHET'), ;
          dbSetRelation( 'SCHET_', {|| recno()}, 'recno()'), ;
          R_Use(dir_server + 'human_2', , 'HUMAN_2'), ;
          R_Use(dir_server + 'human_', , 'HUMAN_'), ;
          R_Use(dir_server + 'human', , 'HUMAN'), ;
          dbSetRelation('HUMAN_2', {|| recno()}, 'recno()' ), ;
          dbSetRelation('HUMAN_', {|| recno()}, 'recno()' ), ;
          dbSetRelation('OTD', {|| otd}, 'otd' ), ;
          dbSetRelation('SCHET', {|| schet}, 'schet' )}
    eval(blk_open)
    set index to (dir_server + 'humankk')
    find (str(glob_kartotek, 7))
    if found()
      mtitul := alltrim(fio)
      index on dtos(k_data) + dtos(n_data) to (cur_dir + 'tmp_olu') while kod_k == glob_kartotek descending
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

** 02.11.11
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

**
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

** 12.05.2019
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

** 31.10.22
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
    set index to (cur_dir + 'tmp_olu')
    goto (rec)
  endif
  return k

** 05.11.22 печать нескольких листов учёта
Function print_al_uch(arr_h, arr_m)
  Local sh := 80, HH := 77, buf := save_maxrow(), ;
        name_lpu, mvzros_reb, mreg_lech, mmest_inog, mrab_nerab, ;
        mkomu, name_org, mlech_vr := '', mishod, mprodol, msumma := 0, mmi_git, ;
        mud_lich := '', arr, n_file := cur_dir + 'list_uch' + stxt, adiag_talon[16], ;
        i := 1, j, k, tmp[2], tmp1, w1 := 65, s, mnum_lu, fl_parakl, lshifr1
  local diagVspom := '', diagMemory := '', add_criteria
  
  mywait()
  fp := fcreate(n_file)
  tek_stroke := 0
  n_list := 1
  //
  R_Use(dir_server + 'organiz')
  name_org := center(alltrim(name), sh)
  dbCloseAll()
  if !myFileDeleted(cur_dir + 'tmp1' + sdbf)
    return NIL
  endif
  dbcreate(cur_dir + 'tmp1', {{'kod', 'N', 4, 0}, ;
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
  use (cur_dir + 'tmp1')
  index on str(kod, 4) to (cur_dir + 'tmp11')
  index on dtos(date_u1) + fsort_usl(shifr) to (cur_dir + 'tmp12')
  dbCloseAll()
  //
  R_Use(dir_server + 'human_', , 'HUMAN_')
  R_Use(dir_server + 'human', , 'HUMAN')
  set relation to recno() into HUMAN_
  goto (atail(arr_h)[2])
  mpolis := alltrim(rtrim(human_->SPOLIS) + ' ' +human_->NPOLIS) + ' (' + ;
            alltrim(inieditspr(A__MENUVERT, mm_vid_polis, human_->VPOLIS)) + ')'
  R_Use(dir_server + 'kartote_', , 'KART_')
  R_Use(dir_server + 'kartotek', , 'KART')
  set relation to recno() into KART_
  goto (human->kod_k)
  madres := iif(emptyall(kart_->okatog, kart->adres), '', ;
                ret_okato_ulica(kart->adres, kart_->okatog))
  Private mvid_ud := kart_->vid_ud, ;
          mser    := kart_->ser_ud, ;
          mnom    := kart_->nom_ud
  if mvid_ud > 0
    mud_lich := ''
    if (j := ascan(menu_vidud, {|x| x[2] == mvid_ud})) > 0
      mud_lich := menu_vidud[j, 4] + ': '
    endif
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
  add_string('  Полис: ' + mpolis)
  //
  R_Use(dir_server + 'mo_uch', , 'UCH')
  R_Use(dir_server + 'mo_otd', , 'OTD')
  R_Use(dir_server + 'uslugi', , 'USL')
  R_Use(dir_server + 'mo_pers', , 'PERSO')
  R_Use(dir_server + 'schet_', , 'SCHET_')
  R_Use(dir_server + 'schet', , 'SCHET')
  set relation to recno() into SCHET_
  R_Use(dir_server + 'human_u_', , 'HU_')
  R_Use(dir_server + 'human_u', dir_server + 'human_u', 'HU')
  set relation to recno() into HU_
  R_Use(dir_server + 'mo_su', , 'MOSU')
  R_Use(dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU')
  use (cur_dir + 'tmp1') index (cur_dir + 'tmp11'), (cur_dir + 'tmp12') new alias tmp1
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
    uch->(dbGoto(human->lpu))
    otd->(dbGoto(human->otd))
    add_string('  Условия: ' + ;
      inieditspr(A__MENUVERT, getV006(), human_->USL_OK) + ', ' + ;
      alltrim(otd->name) + ' [' + alltrim(uch->name) + ']')
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
      if eq_any(alltrim(arr[1]), 'Z92.2', 'Z92.4')
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
  
    // if len(arr) > 0
    //   add_string('  Шифр основного заболевания: ' + arr[1])
    //   if len(arr) > 1
    //     tmp1 := '  Шифры сопутствующих заболеваний:'
    //     for j := 2 to len(arr)
    //       tmp1 += ' ' + arr[j]
    //     next
    //     add_string(tmp1)
    //   endif
    // endif
    verify_FF(HH - 6, .t., sh)
    if human_->PROFIL > 0
      add_string('  Профиль: ' + inieditspr(A__MENUVERT, glob_V002, human_->PROFIL))
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
        if human->k_data < 0d20120301
          tmp1->plus := !f_paraklinika(usl->shifr, lshifr1, c4tod(hu->date_u))
        else
          tmp1->plus := !f_paraklinika(usl->shifr, lshifr1, human->k_data)
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
        s += ' (' + alltrim(inieditspr(A__MENUVERT, glob_V002, tmp1->PROFIL)) + ')'
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
  next ii
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(n_file, , , ,.f., , ,5)
  return NIL
