// delete_dubl_pacient.prg - режим удаления дубликатов из картотеи
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

//
Function dubl_zap_1(r, c)
  Local mas_pmt := {'~Поиск дублирующихся записей', ;
                    '~Удаление дублирующихся записей'}
  Local mas_msg := {'Поиск дублирующихся записей в картотеке', ;
                    'Удаление дублирующихся записей из картотеки'}
  Local mas_fun := {'f1dubl_zap()', ;
                    'f2dubl_zap()'}

  DEFAULT r TO T_ROW, c TO T_COL + 5
  popup_prompt(r, c, 1, mas_pmt, mas_msg, mas_fun)
  return NIL

// 09.07.18
Function f1dubl_zap_1()
  Static si := 1
  Local hGauge, sh, HH := 77, name_file := cur_dir() + 'dubl_zap.txt', j1, ;
      fl := .t., k := 0, rec1, curr := 0, ;
      mfio, mdate_r, mpolis, arr_title, reg_print := 4, ;
      arr := {' По ~ФИО+дата рожд. ', ' По ~полису ', ' По ~СНИЛС ', ' По ~ЕНП '}

  if (i := f_alert({'Выберите, каким образом будет осуществляться поиск дубликатов записей:', ;
                  ''}, ;
                  arr, ;
                  si, 'N+/BG', 'R/BG', 15, , col1menu )) == 0
    return NIL
  endif
  si := i
  if !myFileDeleted(cur_dir() + 'tmp' + sdbf())
    return NIL
  endif
  if !myFileDeleted(cur_dir() + 'tmpitg' + sdbf())
    return NIL
  endif
  dbcreate(cur_dir() + 'tmpitg', { ;
    {'ID','N', 8, 0}, ;
    {'fio','C', 50, 0}, ;
    {'DATE_R','D', 8, 0}, ;
    {'kod_kart','N', 8, 0}, ;
    {'kod_tf','N', 10, 0}, ;
    {'kod_mis','C', 20, 0}, ;
    {'adres','C', 50, 0}, ;
    {'fio','C', 50, 0}, ;
    {'pol','C', 1, 0}, ;
    {'polis','C', 17, 0}, ;
    {'uchast','N', 2, 0}, ;
    {'KOD_VU','N', 5, 0}, ; // код в участке
    {'snils','C', 17, 0}, ;
    {'DATE_PR','D', 8, 0}, ;
    {'MO_PR','C', 6, 0} ;
  })
  use (cur_dir() + 'tmpitg') new
  R_Use(dir_server() + 'kartote2', , 'KART2')
  //
  status_key('^<Esc>^ - прервать поиск')
  hGauge := GaugeNew(, , , 'Поиск дублирующихся записей', .t.)
  GaugeDisplay( hGauge )
  if i == 1
    arr_title := {'────┬─────────────────────────────────────────────┬────────┬──────', ;
                  ' NN │                   Ф.И.О.                    │ Дата р.│Кол-во', ;
                  '────┴─────────────────────────────────────────────┴────────┴──────'}
    sh := len(arr_title[1])
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    add_string('')
    add_string(center('Список дублирующихся записей в картотеке', sh))
    add_string(center('(сравнение по полю "Ф.И.О." + "Дата рождения")', sh))
    add_string('')
    aeval(arr_title, {|x| add_string(x) })
    dbcreate(cur_dir() + 'tmp', {{'fio','C', 50, 0}, {'DATE_R','D', 8, 0}})
    use (cur_dir() + 'tmp') new
    index on upper(fio) + dtos(date_r) to (cur_dir() + 'tmp')
    R_Use(dir_server() + 'kartotek', dir_server() + 'kartoten', 'KART')
    set relation to recno() into KART2
    index on upper(fio)+dtos(date_r) to (cur_dir() + 'tmp_kart') for kod > 0
    go top
    do while !eof()
      GaugeUpdate( hGauge, ++curr / lastrec() )
      if inkey() == K_ESC
        add_string(replicate('*', sh))
        add_string(expand('ПОИСК ПРЕРВАН'))
        stat_msg('Поиск прерван!')
        mybell(1, OK)
        exit
      endif
      mfio := upper(kart->fio)
      mdate_r := kart->date_r
      rec1 := recno()
      j1 := 0
      find (mfio+dtos(mdate_r))
      do while upper(kart->fio) == mfio .and. kart->date_r == mdate_r .and. !eof()
        if kart->(recno()) != rec1
          j1++
        endif
        skip
      enddo
      goto (rec1)
      if j1 > 0
        select TMP
        find (mfio + dtos(mdate_r))
        if !found()
          append blank
          tmp->fio := mfio
          tmp->date_r := mdate_r
          if verify_FF(HH, .t., sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          ++k
          add_string(put_val(k, 4) + '. ' + padr(mfio, 44) + ' ' + date_8(mdate_r) + str(j1 + 1, 5))
          select TMPITG
          append blank
          TMPITG->id       := k
          TMPITG->fio      := kart->fio
          TMPITG->DATE_R   := kart->date_r
          TMPITG->kod_kart := kart->kod
          TMPITG->adres    := kart->adres
          TMPITG->pol      := kart->pol
          TMPITG->polis    := kart->polis
          TMPITG->uchast   := kart->uchast
          TMPITG->kod_vu   := kart->kod_vu
          TMPITG->snils    := transform(kart->snils, picture_pf)
          TMPITG->DATE_PR  := kart2->date_pr
          TMPITG->MO_PR    := kart2->mo_pr
          TMPITG->kod_tf   := kart2->kod_tf
          TMPITG->kod_mis  := kart2->kod_mis
          if lastrec() % 1000 == 0
            commit
          endif
        endif
      endif
      @ maxrow(), 1 say lstr(curr) color 'W+/R'
      @ row(), col() say '/' color 'W/R'
      @ row(), col() say lstr(k) color 'G+/R'
      select KART
      skip
    enddo
  elseif i == 2
    mpolis := space(17)
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    arr_title := { ;
      '────┬─────────────────┬─────────┬──────────────────────────────────────────────────┬────────', ;
      ' NN │      Полис      │№ амб.к. │                      Ф.И.О.                      │ Дата р.', ;
      '────┴─────────────────┴─────────┴──────────────────────────────────────────────────┴────────'}
    sh := len(arr_title[1])
    reg_print := 5
    add_string('')
    add_string(center('Список дублирующихся записей в картотеке', sh))
    add_string(center('(сравнение по полю "Полис")', sh))
    add_string('')
    aeval(arr_title, {|x| add_string(x) } )
    dbcreate(cur_dir() + 'tmp', {{'POLIS','C', 17, 0}})
    use (cur_dir() + 'tmp') new
    index on polis to (cur_dir() + 'tmp')
    R_Use(dir_server() + 'kartotek', dir_server() + 'kartotep', 'KART')
    set relation to recno() into KART2
    find ('1')
    do while !eof()
      GaugeUpdate( hGauge, ++curr / lastrec() )
      if inkey() == K_ESC
        add_string(replicate('*', sh))
        add_string(expand('ПОИСК ПРЕРВАН'))
        stat_msg('Поиск прерван!')
        mybell(1, OK)
        exit
      endif
      if kart->kod > 0 .and. !empty(CHARREPL('*-0', kart->polis, space(3)))
        mpolis := kart->polis
        mfio := kart->fio
        rec1 := recno()
        j1 := 0
        find ('1' + mpolis)
        do while kod > 0 .and. kart->polis == mpolis .and. !eof()
          if recno() != rec1
            j1++
          endif
          skip
        enddo
        goto (rec1)
        if j1 > 0
          select TMP
          find (mpolis)
          if !found()
            append blank
            tmp->polis := mpolis
            ++k
            j1 := 0
            select KART
            find ('1' + mpolis)
            do while kod > 0 .and. kart->polis == mpolis .and. !eof()
              if verify_FF(HH, .t., sh)
                aeval(arr_title, {|x| add_string(x) } )
              endif
              ++j1
              s := iif(j1 == 1, padr(lstr(k) + '.', 5), space(5))
              add_string(s + mpolis + ' ' + padr(amb_kartaN(.t.), 10) + ;
                       padr(kart->fio, 50) + ' ' + date_8(kart->date_r))
              select TMPITG
              append blank
              TMPITG->id       := k
              TMPITG->fio      := kart->fio
              TMPITG->DATE_R   := kart->date_r
              TMPITG->kod_kart := kart->kod
              TMPITG->adres    := kart->adres
              TMPITG->pol      := kart->pol
              TMPITG->polis    := kart->polis
              TMPITG->uchast   := kart->uchast
              TMPITG->kod_vu   := kart->kod_vu
              TMPITG->snils    := transform(kart->snils, picture_pf)
              TMPITG->DATE_PR  := kart2->date_pr
              TMPITG->MO_PR    := kart2->mo_pr
              TMPITG->kod_tf   := kart2->kod_tf
              TMPITG->kod_mis  := kart2->kod_mis
              if lastrec() % 1000 == 0
                commit
              endif
              select KART
              skip
            enddo
            goto (rec1)
          endif
          select KART
        endif
      endif
      @ maxrow(), 1 say lstr(curr) color 'W+/R'
      @ row(), col() say '/' color 'W/R'
      @ row(), col() say lstr(k) color 'G+/R'
      skip
    enddo
  elseif i == 3
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    arr_title := { ;
      '────┬──────────────┬─────────┬──────────────────────────────────────────────────┬────────', ;
      ' NN │    СНИЛС     │№ амб.к. │                      Ф.И.О.                      │ Дата р.', ;
      '────┴──────────────┴─────────┴──────────────────────────────────────────────────┴────────'}
    sh := len(arr_title[1])
    reg_print := 5
    add_string('')
    add_string(center('Список дублирующихся записей в картотеке', sh))
    add_string(center('(сравнение по полю "СНИЛС")', sh))
    add_string('')
    aeval(arr_title, {|x| add_string(x) } )
    dbcreate(cur_dir() + 'tmp', {{'SNILS', 'C', 11, 0}})
    use (cur_dir() + 'tmp') new
    index on snils to (cur_dir() + 'tmp')
    R_Use(dir_server() + 'kartotek', dir_server() + 'kartotes', 'KART')
    set relation to recno() into KART2
    find ('1')
    do while !eof()
      GaugeUpdate( hGauge, ++curr / lastrec() )
      if inkey() == K_ESC
        add_string(replicate('*', sh))
        add_string(expand('ПОИСК ПРЕРВАН'))
        stat_msg('Поиск прерван!')
        mybell(1,OK)
        exit
      endif
      if kart->kod > 0 .and. !empty(CHARREPL('0', kart->snils, ' '))
        msnils := kart->snils
        mfio := kart->fio
        rec1 := recno()
        j1 := 0
        find ('1' + msnils)
        do while kod > 0 .and. kart->snils == msnils .and. !eof()
          if recno() != rec1
            j1++
          endif
          skip
        enddo
        goto (rec1)
        if j1 > 0
          select TMP
          find (msnils)
          if !found()
            append blank
            tmp->snils := msnils
            ++k
            j1 := 0
            select KART
            find ('1' + msnils)
            do while kod > 0 .and. kart->snils == msnils .and. !eof()
              if verify_FF(HH, .t., sh)
                aeval(arr_title, {|x| add_string(x)})
              endif
              ++j1
              s := iif(j1 == 1, padr(lstr(k) + '.', 5), space(5))
              add_string(s + transform(msnils, picture_pf) + ' ' + padr(amb_kartaN(.t.), 10) + ;
                       padr(kart->fio, 50) + ' ' + date_8(kart->date_r))
              select TMPITG
              append blank
              TMPITG->id       := k
              TMPITG->fio      := kart->fio
              TMPITG->DATE_R   := kart->date_r
              TMPITG->kod_kart := kart->kod
              TMPITG->adres    := kart->adres
              TMPITG->pol      := kart->pol
              TMPITG->polis    := kart->polis
              TMPITG->uchast   := kart->uchast
              TMPITG->kod_vu   := kart->kod_vu
              TMPITG->snils    := transform(kart->snils, picture_pf)
              TMPITG->DATE_PR  := kart2->date_pr
              TMPITG->MO_PR    := kart2->mo_pr
              TMPITG->kod_tf   := kart2->kod_tf
              TMPITG->kod_mis  := kart2->kod_mis
              if lastrec() % 1000 == 0
                commit
              endif
              select KART
              skip
            enddo
            goto (rec1)
          endif
          select KART
        endif
      endif
      @ maxrow(), 1 say lstr(curr) color 'W+/R'
      @ row(), col() say '/' color 'W/R'
      @ row(), col() say lstr(k) color 'G+/R'
      skip
    enddo
  elseif i == 4
    arr_title := { ;
        '────┬────────────────┬─────────┬──────────────────────────────────────────────────┬────────', ;
        ' NN │       ЕНП      │ № амб.к.│                     Ф.И.О.                       │ Дата р.', ;
        '────┴────────────────┴─────────┴──────────────────────────────────────────────────┴────────'}
    sh := len(arr_title[1])
    reg_print := 5
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    add_string('')
    add_string(center('Список дублирующихся записей в картотеке', sh))
    add_string(center('(сравнение по полю ЕНП "Единый Номер Полиса")', sh))
    add_string('')
    aeval(arr_title, {|x| add_string(x) } )
    dbcreate(cur_dir() + 'tmp', {{'kod_mis', 'C', 20, 0}})
    use (cur_dir() + 'tmp') new
    index on kod_mis to (cur_dir() + 'tmp')
    R_Use(dir_server() + 'kartote_', , 'KART_')
    R_Use(dir_server() + 'kartotek', , 'KART')
    select KART2
    set relation to recno() into KART, to recno() into KART_
    index on kod_mis to (cur_dir() + 'tmp_kodmis') for !empty(kod_mis) .and. !empty(kart->kod)
    go top
    do while !eof()
      GaugeUpdate( hGauge, ++curr / lastrec() )
      if inkey() == K_ESC
        add_string(replicate('*', sh))
        add_string(expand('ПОИСК ПРЕРВАН'))
        stat_msg('Поиск прерван!')
        mybell(1,OK)
        exit
      endif
      mkod_mis := kart2->kod_mis
      mfio := kart->fio
      rec1 := recno()
      j1 := 0
      find (mkod_mis)
      do while kart2->kod_mis == mkod_mis .and. !eof()
        if recno() != rec1
          j1++
        endif
        skip
      enddo
      goto (rec1)
      if j1 > 0
        select TMP
        find (mkod_mis)
        if !found()
          append blank
          tmp->kod_mis := mkod_mis
          ++k
          j1 := 0
          select KART2
          find (mkod_mis)
          do while kart2->kod_mis == mkod_mis .and. !eof()
            if verify_FF(HH, .t., sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            ++j1
            s := iif(j1 == 1, padr(lstr(k) + '.', 5), space(5))
            add_string(s + left(mkod_mis, 16) + ' ' + padr(amb_kartaN(.t.), 10) + ;
                     padr(alltrim(kart->fio) + ' (' + alltrim(inieditspr(A__MENUVERT, mm_vid_polis, kart_->VPOLIS)) + ;
                          ' полис)', 50) + ' ' + date_8(kart->date_r))
            select TMPITG
            append blank
            TMPITG->id       := k
            TMPITG->fio      := kart->fio
            TMPITG->DATE_R   := kart->date_r
            TMPITG->kod_kart := kart->kod
            TMPITG->adres    := kart->adres
            TMPITG->pol      := kart->pol
            TMPITG->polis    := kart->polis
            TMPITG->uchast   := kart->uchast
            TMPITG->kod_vu   := kart->kod_vu
            TMPITG->snils    := transform(kart->snils, picture_pf)
            TMPITG->DATE_PR  := kart2->date_pr
            TMPITG->MO_PR    := kart2->mo_pr
            TMPITG->kod_tf   := kart2->kod_tf
            TMPITG->kod_mis  := kart2->kod_mis
            if lastrec() % 1000 == 0
              commit
            endif
            select KART2
            skip
          enddo
        endif
      endif
      select KART2
      goto (rec1)
      @ maxrow(), 1 say lstr(curr) color 'W+/R'
      @ row(), col() say '/' color 'W/R'
      @ row(), col() say lstr(k) color 'G+/R'
      skip
    enddo
  endif
  close databases
  fclose(fp)
  CloseGauge(hGauge)
  if k == 0
    func_error(4, 'Не найдено дублирующихся записей!')
  else
  viewtext(name_file, , , , .t., , , reg_print)
  endif
  return NIL

// 20.07.23
Function f2dubl_zap_1()
  Local buf := savescreen()

  Private dubl1_kart := 0, dubl2_kart := 0, top_frm
  setcolor(color0)
  box_shadow(15, 2, 22, 77)
  str_center(17, 'В общем списке сначала отмечается человек, которому будет перенесена вся')
  str_center(18, 'информация из удаляемой карточки - он выделяется синим цветом.')
  mark_keys({'он выделяется'}, col_tit_popup)
  mark_keys({'синим цветом'}, 'W+/B')
  str_center(19, 'Затем отмечается карточка удаляемого человека;')
  str_center(20, 'удаляемая запись выделяется красным цветом.')
  mark_keys({'удаляемая запись выделяется'}, 'R/BG')
  mark_keys({'красным цветом'}, 'W+/R')
  RunStr('Нажмите любую клавишу', 21, 3, 76, 'W+/BG')
  box_shadow(0, 2, 0, 77, color1, , , 0)
  str_center(0, 'Удаление дублирующихся записей в картотеке', color8)
  if view_kart(3) .and. dubl1_kart > 0 .and. dubl2_kart > 0
    mywait()
    Use_base('kartotek')
    // вывод на экран информации
    top_frm := 0
    goto (dubl1_kart)
    kartotek_to_screen(1, 8)
    @ 0, 0 to 9, 79 color 'G+/B'
    str_center(0,' Человек, которому переносится информация ', 'G+/RB')
    top_frm := 10
    goto (dubl2_kart)
    kartotek_to_screen(11, 18)
    @ 10, 0 to 19, 79 double color color8
    str_center(10, ' Человек, который удаляется ', 'GR+/R')
    FillScrArea(20, 0, 24, 79, '░' ,color1)
    if !G_SLock('Редактирование картотеки ' + lstr(dubl2_kart))
      func_error(4, 'В данный момент с карточкой удаляемого человека работает другой пользователь.')
    else
      if f_Esc_Enter(2, .t.)
        mywait()
        // список пациентов в реестрах будущих диспансеризаций
        /*G_Use(dir_server() + 'mo_r01k', ,'R01K')
        index on str(kod_k, 7) to (cur_dir() + 'tmp_r01k')
        do while .t.
          find (str(dubl2_kart, 7))
          if !found()
            exit
          endif
          G_RLock(forever)
          r01k->kod_k := dubl1_kart
        enddo
        close databases*/
        // направления на госпитализацию
        G_Use(dir_server() + 'mo_nnapr', , 'NAPR')
        delete_dubl_rec_in_file('NAPR', kod_k, dubl1_kart, dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir() + 'tmp_napr')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   napr->kod_k := dubl1_kart
        // enddo
        // close databases // на всякий случай
        //
        if hb_fileExists(dir_server() + 'mo_dnab' + sntx())
          Use_base('mo_dnab') // алиас 'DN'
          delete_dubl_rec_in_file('DN', kod_k, dubl1_kart, dubl2_kart, .f.)
          // do while .t.
          //   find (str(dubl2_kart, 7))
          //   if !found()
          //     exit
          //   endif
          //   G_RLock(forever)
          //   dn->kod_k := dubl1_kart
          // enddo
          // close databases // на всякий случай
        endif
        //
        G_Use(dir_server() + 'human', dir_server() + 'humankk', 'HUMAN')
        delete_dubl_rec_in_file('HUMAN', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   human->kod_k := dubl1_kart
        // enddo
        // close databases // на всякий случай (вдруг работает задача ОМС)
        //
        G_Use(dir_server() + 'mo_kinos', dir_server() + 'mo_kinos', 'KIS')
        delete_dubl_rec('KIS', dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   DeleteRec(.t.)
        // enddo
        //
        G_Use(dir_server() + 'mo_kismo', , 'SN')
        delete_dubl_rec('SN', dubl2_kart, .t.)
        // index on str(kod, 7) to (cur_dir() + 'tmp_ismo')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   DeleteRec(.t.)
        // enddo
        // платные услуги
        G_Use(dir_server() + 'hum_p', dir_server() + 'hum_pkk', 'HUM_P')
        delete_dubl_rec_in_file('HUM_P', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   hum_p->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // ортопедия
        G_Use(dir_server() + 'hum_ort', dir_server() + 'hum_ortk', 'HUM_O')
        delete_dubl_rec_in_file('HUM_O', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   hum_o->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // приемный покой
        G_Use(dir_server() + 'mo_pp', dir_server() + 'mo_pp_r', 'PP')
        delete_dubl_rec_in_file('HU', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   pp->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // касса платные
        G_Use(dir_server() + 'kas_pl', dir_server() + 'kas_pl1', 'KASP')
        delete_dubl_rec_in_file('KASP', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   kasp->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // касса ортопедия
        G_Use(dir_server() + 'kas_ort', dir_server() + 'kas_ort1', 'KASO')
        delete_dubl_rec_in_file('KASO', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   kaso->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // подобие регистра застрахованных
        G_Use(dir_server() + 'kart_etk')
        delete_dubl_rec('KPRIM1', dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir() + 'tmp_kart_etk')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   DeleteRec(.t.)
        // enddo
        // примечания к картотеке
        G_Use(dir_server() + 'k_prim1', dir_server() + 'k_prim1', 'K_PRIM1')
        delete_dubl_rec('KPRIM1', dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   DeleteRec(.t.)
        // enddo
        // оплата по ДМС и взаимозачету
        G_Use(dir_server() + 'plat_vz', , 'PVZ')
        index on str(kod_k, 7) to (cur_dir() + 'tmp_pvz')
        set index to (cur_dir() + 'tmp_pvz'), (dir_server() + 'plat_vz')
        delete_dubl_rec_in_file('PVZ', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   pvz->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // регистрация печати л/у
        G_Use(dir_server() + 'mo_regi', {dir_server() + 'mo_regi1', ;
                                  dir_server() + 'mo_regi2', ;
                                  dir_server() + 'mo_regi3'}, 'RU')
        set order to 3
        delete_dubl_rec_in_file('RU', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   ru->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // МСЭК
        G_Use(dir_server() + 'msek', dir_server() + 'msek', 'MSEK')
        delete_dubl_rec_in_file('MSEK', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   msek->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // cписок карточек пациентов в отосланных ходатайствах
        G_Use(dir_server() + 'mo_hod_k', , 'HK')
        delete_dubl_rec_in_file('HK', kod_k, dubl1_kart, dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir() + 'tmp_hk')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   hk->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // список прикреплений по пациенту во времени
        G_Use(dir_server() + 'mo_kartp', dir_server() + 'mo_kartp', 'KARTP')
        delete_dubl_rec_in_file('KARTP', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   kartp->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // список карточек в реестрах на прикрепление
        G_Use(dir_server() + 'mo_krtp', , 'KRTP')
        delete_dubl_rec_in_file('KRTP', kod_k, dubl1_kart, dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir() + 'tmp_krtp')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   krtp->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // список ошибок в реестрах на прикрепление
        G_Use(dir_server() + 'mo_krte', , 'KRTE')
        delete_dubl_rec_in_file('KRTE', kod_k, dubl1_kart, dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir() + 'tmp_krte')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   krte->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // список карточек в файлах на открепление
        G_Use(dir_server() + 'mo_krto', , 'KRTO')
        delete_dubl_rec_in_file('KRTO', kod_k, dubl1_kart, dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir() + 'tmp_krto')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   krto->kod_k := dubl1_kart
        //   UnLock
        // enddo
        //
        Use_base('kartotek')
        set order to 0
        select KART
        goto (dubl2_kart)
        // т.к. relation
        select KART2
        goto (dubl2_kart)
        if !eof()
          DeleteRec(.t., .f.)  // очистка записи без пометки на удаление
        endif
        select KART_
        goto (dubl2_kart)
        if !eof()
          DeleteRec(.t., .f.)  // очистка записи без пометки на удаление
        endif
        select KART
        goto (dubl2_kart)
        DeleteRec(.t., .f.)  // очистка записи без пометки на удаление
        close databases
        stat_msg('Дублирующаяся запись удалена из картотеки!')
        mybell(2, OK)
      endif
      G_SUnLock('Редактирование картотеки ' + lstr(dubl2_kart))
    endif
    close databases
    glob_kartotek := dubl1_kart
  endif
  restscreen(buf)
  return NIL

// 20.07.23
function delete_dubl_rec_in_file(cAlias, kod_k, dubl1_kart, dubl2_kart, lIndex)
  local name_index := cur_dir() + 'tmp_' + cAlias

  default lIndex to .f.
  if lIndex
    (cAlias)->(dbCreateIndex(name_index, 'str(kod_k, 7)', , nil))
  endif
  do while .t.
    (cAlias)->(dbSeek(str(dubl2_kart, 7)))
    if ! (cAlias)->(found())
      exit
    endif
    G_RLock(forever)
    (cAlias)->kod_k := dubl1_kart
    (cAlias)->(dbUnlock())
  enddo
  (cAlias)->(dbCloseArea())
  return nil

// 20.07.23
function delete_dubl_rec(cAlias, dubl2_kart, lIndex)
  local name_index := cur_dir() + 'tmp_' + cAlias

  default lIndex to .f.
  if lIndex
    (cAlias)->(dbCreateIndex(name_index, 'str(kod_k, 7)', , nil))
  endif

  do while .t.
    (cAlias)->(dbSeek(str(dubl2_kart, 7)))
    if ! (cAlias)->(found())
      exit
    endif
    DeleteRec(.t.)
  enddo
  return nil

// 02.09.15 поиск и удаление дубликатов в картотеке по ключу "код ТФ(PID)+ФИО+дата рождения"
Function dubl_zap_kod_tf()

  Local j := 0, old_tf := 0, ii := 0, k, ar[ 10 ], name_file := cur_dir() + 'kod_tf.txt', ;
    adbf, rec, i, j1, j2, ak := {}, buf := SaveScreen()

  f_message( { "Ждите! Пpоизводится поиск и удаление дубликатов в картотеке.", ;
    "", ;
    "Ни в коем случае не прерывайте процесс", ;
    "во избежание нежелательных последствий!" },, "G+/R", "GR+/R", 13 )
  stat_msg( 'Поиск дубликатов по ключу "код ТФ(PID)+ФИО+дата рождения"' )
  adbf := { { "kod", "N", 7, 0 }, { "kodh", "N", 7, 0 } }
  dbCreate( cur_dir() + "t_dubl", adbf )
  AAdd( adbf, { "kod1", "N", 7, 0 } )
  dbCreate( cur_dir() + "t1dubl", adbf )
  Use ( cur_dir() + "t_dubl" ) New Alias t
  Use ( cur_dir() + "t1dubl" ) New Alias t1
  Use ( dir_server() + "human" ) New Alias HUMAN
  Index On Str( kod_k, 7 ) + Str( Descend( k_data ), 10 ) to ( cur_dir() + "tmp_human" ) For !Empty( k_data )
  Use ( dir_server() + "kartote_" ) New Alias KART_
  Use ( dir_server() + "kartotek" ) New Alias KART
  Use ( dir_server() + "kartote2" ) New Alias KART2
  Set Relation To RecNo() into KART_, To RecNo() into KART
  Index On Str( kart2->kod_tf, 10 ) to ( cur_dir() + "tmp_kart2" ) ;
    For kart2->kod_tf > 0 .and. !kart->( Eof() ) .and. kart->kod > 0
  Go Top
  Do While !Eof()
    If ii < 10 .or. ii % 10 == 0
      @ MaxRow(), 1 Say lstr( ii ) Color cColorStMsg
    Endif
    If kart2->kod_tf > old_tf
      old_tf := kart2->kod_tf ; k := 0
      Select KART2
      Do While old_tf == kart2->kod_tf .and. !Eof()
        ++k
        Skip
      Enddo
      rec := RecNo()
      If k > 1
        arr1 := {}
        Select KART2
        find ( Str( old_tf, 10 ) )
        Do While old_tf == kart2->kod_tf .and. !Eof()
          If ( i := AScan( arr1, {| x| x[ 2 ] == Upper( kart->fio ) .and. x[ 3 ] == kart->date_r } ) ) == 0
            AAdd( arr1, { 0, Upper( kart->fio ), kart->date_r, {} } ) ; i := Len( arr1 )
          Endif
          arr1[ i, 1 ] ++
          AAdd( arr1[ i, 4 ], kart2->( RecNo() ) )
          Skip
        Enddo
        If Len( arr1 ) > 1
          ASort( arr1,,, {| x, y| x[ 1 ] > y[ 1 ] } )
        Endif
        If ( k := arr1[ 1, 1 ] ) > 1
          ++ii ; j += k
          If ( i := AScan( ak, {| x| x[ 1 ] == k } ) ) == 0
            AAdd( ak, { k, 0 } ) ; i := Len( ak )
          Endif
          ak[ i, 2 ] ++
          arr := {}
          For i := 1 To Len( arr1[ 1, 4 ] )
            Select KART2
            Goto ( arr1[ 1, 4, i ] )
            Select HUMAN
            find ( Str( kart->kod, 7 ) )
            AAdd( arr, { arr1[ 1, 4, i ], ;
              iif( Found(), Int( Val( DToS( human->k_data ) ) ), 0 ), ;
              kart_->VPOLIS, ;
              kart_->vid_ud, ;
              kart_->ser_ud, ;
              iif( Left( kart2->PC2, 1 ) == "1", 1, 0 ), ;
              iif( Found(), human->kod, 0 ) } )
          Next
          ASort( arr,,, {| x, y| iif( x[ 2 ] == y[ 2 ], ;
            iif( x[ 3 ] == y[ 3 ], ;
            iif( x[ 4 ] == y[ 4 ], x[ 5 ] > y[ 5 ], x[ 4 ] > y[ 4 ] ), ;
            x[ 3 ] > y[ 3 ] ), ;
            x[ 2 ] > y[ 2 ] ) } )
          For k := 1 To Len( arr )
            Select KART2
            Goto ( arr[ k, 1 ] )
            If k == 1
              Select T
              Append Blank
              t->kod  := arr[ k, 1 ]
              t->kodh := arr[ k, 7 ]
            Else // k > 1
              Select T1
              Append Blank
              t1->kod  := t->kod
              t1->kod1 := arr[ k, 1 ]
              t1->kodh := arr[ k, 7 ]
            Endif
          Next
          If ii % 2000 == 0
            Commit
          Endif
        Endif
      Endif
      Select KART2
      Goto ( rec )
      Skip -1
    Endif
    Select KART2
    Skip
  Enddo
  j1 := t->( LastRec() )
  j2 := t1->( LastRec() )
  Close databases
  If j1 > 0
    Private mfio, mdate_r, mbukva, muchast, mkod_vu, mkod_AK, ;
      MADRES, MMR_DOL, M1VID_UD, mser_ud, mnom_ud, M1KEMVYD, MKOGDAVYD, ;
      m1vidpolis, mpolis, mspolis, mnpolis, msmo, mmesto_r, msnils, ;
      m1kategor, m1kategor2, mokatog, mokatop, madresp, ;
      mPHONE_H, mPHONE_M, mPHONE_W, m1okato
    stat_msg( 'Удаление дубликатов по ключу "код ТФ(PID)+ФИО+дата рождения"' )
    fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( "Будет удалено записей в картотеке - " + lstr( j - ii ) )
    ASort( ak,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    add_string( print_array( ak ) )
    add_string( Replicate( "-", 102 ) )
    f_open_files_dubl_zap( .t. ) // монопольное открытие всех файлов
    e_use( dir_server() + "human", dir_server() + "humankk", "HUMAN" ) // монопольно
    use_base( "kartotek",, .t. ) // монопольно
    Set Order To 0
    Use ( cur_dir() + "t1dubl" ) New Alias t1
    Index On Str( kod, 7 ) to ( cur_dir() + "t1dubl" )
    Use ( cur_dir() + "t_dubl" ) New Alias t
    Go Top
    Do While !Eof()
      If RecNo() < 10 .or. RecNo() % 10 == 0
        @ MaxRow(), 0 Say Str( RecNo() / j1 * 100, 6, 2 ) + "%" Color cColorStMsg
      Endif
      ar[ 1 ] := "код |"
      ar[ 2 ] := "уч-к|"
      ar[ 3 ] := "пол.|"
      ar[ 4 ] := "пасп|"
      ar[ 5 ] := "адр.|"
      ar[ 6 ] := "прож|"
      Select KART
      Goto ( t->kod )
      ar[ 1 ] += lstr( t->kod )
      If t->kodh > 0
        human->( dbGoto( t->kodh ) )
        ar[ 1 ] += "(п/л/у " + full_date( human->k_data ) + ")"
      Endif
      ar[ 1 ] += iif( Left( kart2->PC2, 1 ) == "1", " УМЕР", "" ) + "|"
      ar[ 2 ] += " участок " + lstr( kart->uchast ) + "|"
      ar[ 3 ] += lstr( kart_->VPOLIS, 1 ) + " " + AllTrim( kart_->NPOLIS ) + "|"
      ar[ 4 ] += lstr( kart_->vid_ud ) + " " + AllTrim( kart_->ser_ud ) + " " + AllTrim( kart_->nom_ud ) + "|"
      ar[ 5 ] += RTrim( kart_->okatog ) + " " + AllTrim( kart->adres ) + "|"
      ar[ 6 ] += RTrim( kart_->okatop ) + " " + AllTrim( kart_->adresp ) + "|"
      mfio := kart->fio ; mdate_r := kart->date_r
      mokatog     := kart_->okatog       // код места жительства по ОКАТО
      mADRES      := kart->ADRES
      mokatop     := kart_->okatop       // код места пребывания по ОКАТО
      madresp     := kart_->adresp       // адрес места пребывания
      mMR_DOL     := kart->MR_DOL
      msnils      := kart->snils
      mbukva      := kart->bukva
      muchast     := kart->uchast
      mkod_vu     := kart->kod_vu
      mkod_AK     := kart2->kod_AK
      m1vidpolis  := kart_->VPOLIS // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый
      mpolis      := kart->POLIS   // полис
      mspolis     := kart_->SPOLIS // серия полиса
      mnpolis     := kart_->NPOLIS // номер полиса
      msmo        := kart_->SMO    // реестровый номер СМО
      m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
      m1vid_ud    := kart_->vid_ud   // вид удостоверения личности
      mser_ud     := kart_->ser_ud   // серия удостоверения личности
      mnom_ud     := kart_->nom_ud   // номер удостоверения личности
      m1kemvyd    := kart_->kemvyd   // кем выдан документ
      mkogdavyd   := kart_->kogdavyd // когда выдан документ
      m1kategor   := kart_->kategor  // категория пациента
      m1kategor2  := kart_->kategor2 // категория пациента (собственная для МО)
      mmesto_r    := kart_->mesto_r    // место рождения;;
      mPHONE_H    := kart_->PHONE_H    // телефон домашний;;
      mPHONE_M    := kart_->PHONE_M    // телефон мобильный;;
      mPHONE_W    := kart_->PHONE_W    // телефон рабочий;;
      iuch := iadres := imrab := isnils := ipolis := iud := imr := ith := itm := itw := 1
      k := 1
      Select T1
      find ( Str( t->kod, 7 ) )
      Do While t1->kod == t->kod .and. !Eof()
        ++k
        Select KART
        Goto ( t1->kod1 )
        If Empty( muchast ) .and. !Empty( kart->uchast )
          mbukva  := kart->bukva
          muchast := kart->uchast
          mkod_vu := kart->kod_vu
          iuch := k
        Endif
        If Empty( mkod_AK )
          mkod_AK := kart2->kod_AK
        Endif
        If emptyany( mokatog, mADRES ) .and. !emptyall( kart_->okatog, kart->ADRES )
          iadres := k
          mokatog := kart_->okatog       // код места жительства по ОКАТО
          mADRES  := kart->ADRES
          If emptyany( mokatop, mADRESp ) .and. !emptyall( kart_->okatop, kart_->adresp )
            mokatop := kart_->okatop       // код места пребывания по ОКАТО
            madresp := kart_->adresp       // адрес места пребывания
          Endif
        Endif
        If Empty( mMR_DOL ) .and. !Empty( kart->MR_DOL )
          imrab := k
          mMR_DOL := kart->MR_DOL
        Endif
        If Empty( msnils ) .and. !Empty( kart->snils )
          isnils := k
          msnils := kart->snils
        Endif
        If m1vidpolis < kart_->VPOLIS
          ipolis := k
          mpolis     := kart->POLIS   // полис
          m1vidpolis := kart_->VPOLIS // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый
          mspolis    := kart_->SPOLIS // серия полиса
          mnpolis    := kart_->NPOLIS // номер полиса
          msmo       := kart_->SMO    // реестровый номер СМО
          m1okato    := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
        Endif
        If m1vid_ud < kart_->vid_ud .or. ;
            ( m1vid_ud == kart_->vid_ud .and. !Empty( kart_->ser_ud ) ;
            .and. val_ud_ser( 2, kart_->vid_ud, kart_->ser_ud ) ;
            .and. mser_ud < kart_->ser_ud )
          iud := k
          m1vid_ud  := kart_->vid_ud   // вид удостоверения личности
          mser_ud   := kart_->ser_ud   // серия удостоверения личности
          mnom_ud   := kart_->nom_ud   // номер удостоверения личности
          m1kemvyd  := kart_->kemvyd   // кем выдан документ
          mkogdavyd := kart_->kogdavyd // когда выдан документ
        Endif
        If eq_any( m1kategor, 0, 13 ) .and. !Empty( kart_->kategor )
          m1kategor := kart_->kategor  // категория пациента
        Endif
        If Empty( m1kategor2 )
          m1kategor2 := kart_->kategor2 // категория пациента (собственная для МО)
        Endif
        If Empty( mmesto_r ) .and. !Empty( kart_->mesto_r )
          imr := k
          mmesto_r := kart_->mesto_r    // место рождения;;
        Endif
        If Empty( mPHONE_H ) .and. !Empty( kart_->PHONE_H )
          ith := k
          mPHONE_H := kart_->PHONE_H    // телефон домашний;;
        Endif
        If Empty( mPHONE_M ) .and. !Empty( kart_->PHONE_M )
          itm := k
          mPHONE_M := kart_->PHONE_M    // телефон мобильный;;
        Endif
        If Empty( mPHONE_W ) .and. !Empty( kart_->PHONE_W )
          itw := k
          mPHONE_W := kart_->PHONE_W    // телефон рабочий;;
        Endif
        ar[ 1 ] += lstr( t1->kod1 )
        If t1->kodh > 0
          human->( dbGoto( t1->kodh ) )
          ar[ 1 ] += "(п/л/у " + full_date( human->k_data ) + ")"
        Endif
        If !( Upper( mfio ) == Upper( kart->fio ) .and. mdate_r == kart->date_r )
          ar[ 1 ] += " err " + fam_i_o( kart->fio ) + " " + full_date( kart->date_r )
        Endif
        ar[ 1 ] += iif( Left( kart2->PC2, 1 ) == "1", " УМЕР", "" ) + "|"
        ar[ 2 ] += " участок " + lstr( kart->uchast ) + "|"
        ar[ 3 ] += lstr( kart_->VPOLIS, 1 ) + " " + AllTrim( kart_->NPOLIS ) + "|"
        ar[ 4 ] += lstr( kart_->vid_ud ) + " " + AllTrim( kart_->ser_ud ) + " " + AllTrim( kart_->nom_ud ) + "|"
        ar[ 5 ] += RTrim( kart_->okatog ) + " " + AllTrim( kart->adres ) + "|"
        ar[ 6 ] += RTrim( kart_->okatop ) + " " + AllTrim( kart_->adresp ) + "|"
        f_delete_dubl_zap( t1->kod, t1->kod1, .f. ) // не блокировать записи
        Select T1
        Skip
      Enddo
      Select KART
      Goto ( t->kod )
      add_string( PadR( lstr( kart2->kod_tf ) + "/" + lstr( t->( RecNo() ) ) + " (" + lstr( k ) + ")", 102, "-" ) )
      add_string( AllTrim( kart->fio ) + " " + full_date( kart->date_r ) )
      For k := 1 To 6
        add_string( ar[ k ] )
      Next
      add_string( "уч-ок" + iif( iuch == 1, ":", "(" + lstr( iuch ) + "):" ) + AllTrim( mbukva ) + lstr( muchast ) + "/" + lstr( mkod_vu ) + " " + mkod_AK )
      add_string( "полис" + iif( ipolis == 1, ":", "(" + lstr( ipolis ) + "):" ) + lstr( m1vidpolis ) + " " + AllTrim( mspolis ) + " " + AllTrim( mnpolis ) )
      add_string( "удост" + iif( iud == 1, ":", "(" + lstr( iud ) + "):" ) + lstr( m1vid_ud ) + " " + AllTrim( mser_ud ) + " " + AllTrim( mnom_ud ) )
      add_string( "рожд." + iif( imr == 1, ":", "(" + lstr( imr ) + "):" ) + RTrim( mmesto_r ) )
      add_string( "адрес" + iif( iadres == 1, ":", "(" + lstr( iadres ) + "):" ) + mokatog + " " + RTrim( mADRES ) + "/" + mokatop + " " + RTrim( mADRESp ) )
      If !Empty( mmr_dol )
        add_string( "работ" + iif( imrab == 1, ":", "(" + lstr( imrab ) + "):" ) + RTrim( mmr_dol ) )
      Endif
      add_string( "СНИЛС" + iif( isnils == 1, ":", "(" + lstr( isnils ) + "):" ) + Transform( mSNILS, picture_pf ) )
      s := ""
      If !Empty( mPHONE_H )
        s += "тел.Д" + iif( ith == 1, ":", "(" + lstr( ith ) + "):" ) + mPHONE_H
      Endif
      If !Empty( mPHONE_M )
        s += "тел.М" + iif( itm == 1, ":", "(" + lstr( itm ) + "):" ) + mPHONE_m
      Endif
      If !Empty( mPHONE_W )
        s += "тел.Р" + iif( itw == 1, ":", "(" + lstr( itw ) + "):" ) + mPHONE_w
      Endif
      If !Empty( s )
        add_string( s )
      Endif
      //
      Select KART
      Goto ( t->kod )
      Select KART_
      Do While kart_->( LastRec() ) < t->kod
        Append Blank
      Enddo
      Goto ( t->kod )
      Select KART2
      Do While kart2->( LastRec() ) < t->kod
        Append Blank
      Enddo
      Goto ( t->kod )
      //
      If !( kart_->okatog == mokatog )
        kart_->okatog := mokatog
      Endif
      If !( kart->ADRES == mADRES )
        kart->ADRES := mADRES
      Endif
      If !( kart_->okatop == mokatop )
        kart_->okatop := mokatop
      Endif
      If !( kart_->adresp == madresp )
        kart_->adresp := madresp
      Endif
      If !( kart->MR_DOL == mMR_DOL )
        kart->MR_DOL := mMR_DOL
      Endif
      If !( kart->snils == msnils )
        kart->snils := msnils
      Endif
      If !( kart->bukva == mbukva )
        kart->bukva := mbukva
      Endif
      If kart->uchast != muchast
        kart->uchast := muchast
      Endif
      If kart->kod_vu != mkod_vu
        kart->kod_vu := mkod_vu
      Endif
      If !( kart2->kod_AK == mkod_AK )
        kart2->kod_AK := mkod_AK
      Endif
      If kart_->VPOLIS != m1vidpolis
        kart_->VPOLIS := m1vidpolis
      Endif
      If !( kart->POLIS == mpolis )
        kart->POLIS := mpolis
      Endif
      If !( kart_->SPOLIS == mspolis )
        kart_->SPOLIS := mspolis
      Endif
      If !( kart_->NPOLIS == mnpolis )
        kart_->NPOLIS := mnpolis
      Endif
      If !( kart_->SMO == msmo )
        kart_->SMO := msmo
      Endif
      If !( kart_->KVARTAL_D == m1okato )
        kart_->KVARTAL_D := m1okato
      Endif
      If kart_->vid_ud != m1vid_ud
        kart_->vid_ud := m1vid_ud
      Endif
      If !( kart_->ser_ud == mser_ud )
        kart_->ser_ud := mser_ud
      Endif
      If !( kart_->nom_ud == mnom_ud )
        kart_->nom_ud := mnom_ud
      Endif
      If kart_->kemvyd != m1kemvyd
        kart_->kemvyd := m1kemvyd
      Endif
      If kart_->kogdavyd != mkogdavyd
        kart_->kogdavyd := mkogdavyd
      Endif
      If kart_->kategor != m1kategor
        kart_->kategor := m1kategor
      Endif
      If kart_->kategor2 != m1kategor2
        kart_->kategor2 := m1kategor2
      Endif
      If !( kart_->mesto_r == mmesto_r )
        kart_->mesto_r := mmesto_r
      Endif
      If !( kart_->PHONE_H == mPHONE_H )
        kart_->PHONE_H := mPHONE_H
      Endif
      If !( kart_->PHONE_M == mPHONE_M )
        kart_->PHONE_M := mPHONE_M
      Endif
      If !( kart_->PHONE_W == mPHONE_W )
        kart_->PHONE_W := mPHONE_W
      Endif
      Select T
      If RecNo() % 400 == 0
        @ MaxRow(), 7 Say "rec" Color "W/R"
        Commit
        @ MaxRow(), 7 Say "   " Color cColorStMsg
      Endif
      Skip
    Enddo
    Close databases
    Delete File ( "t1dubl" + sntx() )
    FClose( fp )
  Endif
  Delete File ( "t_dubl" + sdbf() )
  Delete File ( "t1dubl" + sdbf() )
  RestScreen( buf )
  Return { j1, j2 }

// 11.01.19 открыть все файлы для удаления дубликатов записей в картотеке
Function f_open_files_dubl_zap( lExcluUse )

  g_use( dir_server() + "mo_d01k",, "D01K",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_d01k" )
  // список пациентов в реестрах будущих диспансеризаций
  g_use( dir_server() + "mo_dr01k",, "R01K",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_r01k" )
  // направления на госпитализацию
  g_use( dir_server() + "mo_nnapr",, "NAPR",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_napr" )
  //
  g_use( dir_server() + "mo_kinos", dir_server() + "mo_kinos", "KIS",, lExcluUse )
  //
  g_use( dir_server() + "mo_kismo",, "SN",, lExcluUse )
  Index On Str( kod, 7 ) to ( cur_dir() + "tmp_ismo" )
  // платные услуги
  g_use( dir_server() + "hum_p", dir_server() + "hum_pkk", "HUM_P",, lExcluUse )
  // ортопедия
  g_use( dir_server() + "hum_ort", dir_server() + "hum_ortk", "HUM_O",, lExcluUse )
  // приемный покой
  g_use( dir_server() + "mo_pp", dir_server() + "mo_pp_r", "PP",, lExcluUse )
  // касса платные
  g_use( dir_server() + "kas_pl", dir_server() + "kas_pl1", "KASP",, lExcluUse )
  // касса ортопедия
  g_use( dir_server() + "kas_ort", dir_server() + "kas_ort1", "KASO",, lExcluUse )
  // подобие регистра застрахованных
  g_use( dir_server() + "kart_etk",, "kart_etk",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_kart_etk" )
  // примечания к картотеке
  g_use( dir_server() + "k_prim1", dir_server() + "k_prim1", "K_PRIM1",, lExcluUse )
  // оплата по ДМС и взаимозачету
  g_use( dir_server() + "plat_vz",, "PVZ",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_pvz" )
  Set Index to ( cur_dir() + "tmp_pvz" ), ( dir_server() + "plat_vz" )
  // регистрация печати л/у
  g_use( dir_server() + "mo_regi", { dir_server() + "mo_regi1", ;
    dir_server() + "mo_regi2", ;
    dir_server() + "mo_regi3" }, "RU",, lExcluUse )
  Set Order To 3
  // МСЭК
  g_use( dir_server() + "msek", dir_server() + "msek", "MSEK",, lExcluUse )
  // cписок карточек пациентов в отосланных ходатайствах
  g_use( dir_server() + "mo_hod_k",, "HK",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_hk" )
  // список прикреплений по пациенту во времени
  g_use( dir_server() + "mo_kartp", dir_server() + "mo_kartp", "KARTP",, lExcluUse )
  // список карточек в реестрах на прикрепление
  g_use( dir_server() + "mo_krtp",, "KRTP",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_krtp" )
  // список ошибок в реестрах на прикрепление
  g_use( dir_server() + "mo_krte",, "KRTE",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_krte" )
  // список карточек в файлах на открепление
  g_use( dir_server() + "mo_krto",, "KRTO",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp_krto" )
  Return Nil

// 11.01.19 удалить дубликаты записей в картотеке
Function f_delete_dubl_zap( dubl1_kart, dubl2_kart, is_lock )

  // dubl1_kart - Человек, которому переносится информация
  // dubl2_kart - Человек, который удаляется
  // is_lock    - логическая величина - блокировать ли запись
  Default is_lock To .t.
  // список пациентов в реестрах будущих диспансеризаций
  Select D01K
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    d01k->kod_k := dubl1_kart
  Enddo
  Select R01K
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    r01k->kod_k := dubl1_kart
  Enddo
  // направления на госпитализацию
  Select NAPR
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    napr->kod_k := dubl1_kart
  Enddo
  Select HUMAN
  // должен уже стоять на индексе (dir_server()+"humankk")
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    human->kod_k := dubl1_kart
  Enddo
  Select KIS
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    deleterec( .t.,, is_lock )
  Enddo
  Select SN
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    deleterec( .t.,, is_lock )
  Enddo
  Select HUM_P
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    hum_p->kod_k := dubl1_kart
  Enddo
  Select HUM_O
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    hum_o->kod_k := dubl1_kart
  Enddo
  Select PP
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    pp->kod_k := dubl1_kart
  Enddo
  Select KASP
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    kasp->kod_k := dubl1_kart
  Enddo
  Select KASO
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    kaso->kod_k := dubl1_kart
  Enddo
  Select kart_etk
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    deleterec( .t.,, is_lock )
  Enddo
  Select K_PRIM1
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    deleterec( .t.,, is_lock )
  Enddo
  Select PVZ
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    pvz->kod_k := dubl1_kart
  Enddo
  Select RU
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    ru->kod_k := dubl1_kart
  Enddo
  Select MSEK
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    msek->kod_k := dubl1_kart
  Enddo
  Select HK
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    hk->kod_k := dubl1_kart
  Enddo
  Select KARTP
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    kartp->kod_k := dubl1_kart
  Enddo
  Select KRTP
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    krtp->kod_k := dubl1_kart
  Enddo
  Select KRTE
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    krte->kod_k := dubl1_kart
  Enddo
  Select KRTO
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    krto->kod_k := dubl1_kart
  Enddo
  // картотека
  Select KART
  Set Order To 0
  Goto ( dubl2_kart )
  // т.к. relation
  Select KART2
  Goto ( dubl2_kart )
  If !Eof()
    deleterec( .t., .f., is_lock )  // очистка записи без пометки на удаление
  Endif
  Select KART_
  Goto ( dubl2_kart )
  If !Eof()
    deleterec( .t., .f., is_lock )  // очистка записи без пометки на удаление
  Endif
  Select KART
  Goto ( dubl2_kart )
  deleterec( .t., .f., is_lock )  // очистка записи без пометки на удаление
  If is_lock
    dbUnlockAll()
  Endif
  Return Nil