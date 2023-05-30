// распечатка различных справочников - mo_spri.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 16.09.18 просмотр/печать общих справочников
Function o_sprav(k)
  Static sk := 1, sk1 := 1, sk2 := 1
  Local str_sem, mas_pmt, mas_msg, mas_fun, j

  DEFAULT k TO 0
  do case
    case k == 0
      mas_pmt := {'~Услуги', ;
                  '~Диагнозы', ;
                  '~Персонал', ;
                  '~Онкология', ;
                  '~Другие справочники'}
      mas_msg := {'Услуги', ;
                  'Диагнозы', ;
                  'Персонал', ;
                  'Просмотр справочников, относящихся к Приказу ФФОМС №59 по онкологии', ;
                  'Другие справочники'}
      mas_fun := {'o_sprav(1)', ;
                  'o_sprav(2)', ;
                  'o_sprav(3)', ;
                  'o_sprav(4)', ;
                  'o_sprav(5)'}
      if mem_kodotd == 2
        aadd(mas_pmt, 'Коды ~отделений')
        aadd(mas_msg, 'Коды отделений')
        aadd(mas_fun, 'o_sprav(6)')
      endif
      uch_otd := saveuchotd()
      popup_prompt(T_ROW, T_COL - 5, sk, mas_pmt, mas_msg, mas_fun)
      restuchotd(uch_otd)
    case k == 1
      fspr_uslugi()
    case k == 2
      spr_info_diagn()
    case k == 3
      spr_personal()
    case k == 4
      mas_pmt := {'Услуги диагностики при дообследовании на ~ЗНО', ;
                  'Услуги по типам лечения ~ОНКОзаболеваний', ;
                  'Обязательные типы услуг для методов ВМП', ;
                  'Справочники N~0...'}
      mas_msg := {'Вывод списка услуг диагностики при дообследовании в направлениях на ЗНО', ;
                  'Вывод списка услуг по типам лечения ОНКОзаболеваний', ;
                  'Вывод обязательных типов услуг для каждого метода ВМП в онкологических случаях', ;
                  'Распечатка справочников, участвующих в заполнении контрольного листа'}
      mas_fun := {'o_sprav(11)', ;
                  'o_sprav(12)', ;
                  'o_sprav(13)', ;
                  'o_sprav(14)'}
      popup_prompt(T_ROW - 3 - len(mas_pmt), T_COL - 5, sk1, mas_pmt, mas_msg, mas_fun)
    case k == 5
      spr_other()
    case k == 6
      spr_kod_otd()
    case k == 11 // Вывод списка услуг диагностики при дообследовании в направлениях на ЗНО
      usl_napr_FFOMS()
    case k == 12 // Вывод списка услуг по типам лечения ОНКОзаболеваний
      usl_ksg_FFOMS()
    case k == 13 // Обязательные типы услуг для методов ВМП
      pr_sprav_onk_vmp()
    case k == 14
      mas_pmt := {'Классификатор стадий (N00~2)', ;
                  'Классификатор Tumor (N00~3)', ;
                  'Классификатор Nodus (N00~4)', ;
                  'Классификатор Metastasis (N00~5)', ;
                  'Справочник соответствия стадий TNM (N00~6)'}
      mas_msg := {'Распечатка классификатора стадий (N002)', ;
                  'Распечатка классификатора Tumor (N003)', ;
                  'Распечатка классификатора Nodus (N004)', ;
                  'Распечатка классификатора Metastasis (N005)', ;
                  'Распечатка справочника соответствия стадий TNM (N006)'}
      mas_fun := {'o_sprav(21)', ;
                  'o_sprav(22)', ;
                  'o_sprav(23)', ;
                  'o_sprav(24)', ;
                  'o_sprav(25)'}
      popup_prompt(T_ROW, T_COL - 5, sk2, mas_pmt, mas_msg, mas_fun)
    case k == 21 //
      pr_sprav_N002(2)
    case k == 22 //
      pr_sprav_N002(3)
    case k == 23 //
      pr_sprav_N002(4)
    case k == 24 //
      pr_sprav_N002(5)
    case k == 25 // Справочник соответствия стадий TNM
      pr_sprav_N006()
  endcase
  if k > 0
    if k > 20
      sk2 := k
    elseif k > 10
      sk1 := k
    else
      sk := k
    endif
  endif
  return NIL

// 02.02.22
Function fspr_uslugi(k)
  Static _su := 110
  Static sk := 1, sk1 := 1, sk2 := 1
  Local str_sem, mas_pmt, mas_msg, mas_fun, j, s

  DEFAULT k TO 0
  do case
    case k == 0
      mas_pmt := {'Поиск по ~шифру', ;
                  'Услуги по стандарту ~ТФОМС', ;
                  'Услуги Минздрава РФ (~ФФОМС)', ;
                  'Список услуг по ~ОМС', ;
                  'Список ~платных услуг', ;
                  'Список услуг по ~ДМС', ;
                  'Услуги с ~нулевой ценой', ;
                  'Печать ~комплексных услуг'}
      mas_msg := {'Просмотр конкретной услуги с поиском по шифру', ;
                  'Распечатка списка услуг с ценами ТФОМС по ОМС', ;
                  'Распечатка номенклатуры медицинских услуг Минздрава РФ (ФФОМС)', ;
                  'Распечатка списка услуг с ценами по ОМС', ;
                  'Распечатка списка услуг с ценами на платные услуги', ;
                  'Распечатка списка услуг с ценами по ДМС', ;
                  'Распечатка услуг, для которых разрешается ввод нулевой цены', ;
                  'Распечатка комплексных услуг'}
      mas_fun := {'fspr_uslugi(1)', ;
                  'fspr_uslugi(2)', ;
                  'fspr_uslugi(3)', ;
                  'fspr_uslugi(4)', ;
                  'fspr_uslugi(5)', ;
                  'fspr_uslugi(6)', ;
                  'fspr_uslugi(7)', ;
                  'fspr_uslugi(8)'}
      popup_prompt(T_ROW, T_COL - 5, sk, mas_pmt, mas_msg, mas_fun)
    case k == 1
        v_1usluga()
    case k == 2
      mas_pmt := {'~Даты смены цен на услуги', ;
                  '~Цены на конкретную дату', ;
                  'Услуги ТФОМС -> ~наши услуги'}
      mas_msg := {'Вывод списка изменений ТФОМС на цены услуг по конкретным датам', ;
                  'Вывод списка услуг ТФОМС с ценами на указанную Вами дату', ;
                  'Привязка Ваших услуг к услугам ТФОМС'}
      mas_fun := {'fspr_uslugi(11)', ;
                  'fspr_uslugi(12)', ;
                  'fspr_uslugi(13)'}
      Private su := _su
      popup_prompt(T_ROW - len(mas_pmt) - 3, T_COL - 5, sk1, mas_pmt, mas_msg, mas_fun)
      _su := su
    case k == 3
      mas_pmt := {'Номенклатура медуслуг ~ФФОМС', ;
                  '~Стоматологические услуги', ;
                  'Услуги ~телемедицины', ;
                  'Операции на ~парных органах', ;
                  'Классификатор ~видов ВМП', ;
                  'Классификатор ~методов ВМП', ;
                  'Услуги ФФОМС -> ~наши услуги', ;
                  'Список ~имплантатов'}
      mas_msg := {'Вывод списка услуг Минздрава РФ (ФФОМС) по подразделам', ;
                  'Вывод списка стоматологических услуг Минздрава РФ (ФФОМС) по группам', ;
                  'Распечатка списка услуг с использованием телемедицинских технологий', ;
                  'Распечатка списка операций на парных органах (частях тела)', ;
                  'Распечатка классификатора видов ВМП', ;
                  'Распечатка классификатора методов ВМП (с группировкой по видам ВМП)', ;
                  'Привязка Ваших услуг к услугам ФФОМС', ;
                  'Распечатка списка имплантатов'}
      mas_fun := {'fspr_uslugi(21)', ;
                  'fspr_uslugi(22)', ;
                  'fspr_uslugi(23)', ;
                  'fspr_uslugi(24)', ;
                  'fspr_uslugi(25)', ;
                  'fspr_uslugi(26)', ;
                  'fspr_uslugi(27)', ;
                  'fspr_uslugi(30)'}
      k := len(mas_pmt)
      use_base('luslc')
      set order to 2
      find (glob_mo[_MO_KOD_TFOMS] + 'ds')
      if found()
        aadd(mas_pmt, 'Услуги + КСГ (~дневной стационар)')
        aadd(mas_msg, 'Вывод списка разрешённых услуг ФФОМС вместе с КСГ дневного стационара')
        aadd(mas_fun, 'fspr_uslugi(28)')
      endif
      k := len(mas_pmt)
      find (glob_mo[_MO_KOD_TFOMS] + 'st')
      if found()
        aadd(mas_pmt, 'Услуги + ~КСГ (стационар)')
        aadd(mas_msg, 'Вывод списка разрешённых услуг ФФОМС вместе с КСГ стационара')
        aadd(mas_fun, 'fspr_uslugi(29)')
      endif
      close databases
      popup_prompt(T_ROW - len(mas_pmt) - 3, T_COL - 5, sk2, mas_pmt, mas_msg, mas_fun)
    case k == 4
      f4_uslugi(1)
    case k == 5
      f4_uslugi(2)
    case k == 6
      f4_uslugi(3)
    case k == 7
      v_nulusluga()
    case k == 8
      v_k_uslugi()
    case k == 11
      usl1TFOMS()
    case k == 12
      usl2TFOMS()
    case k == 13
      usl3TFOMS()
    case k == 21
      usl1FFOMS()
    case k == 22
      usl_stom_FFOMS()
    case k == 23
      usl_telemedicina()
    case k == 24
      usl_par_organ()
    case k == 25
      usl11FFOMS()
    case k == 26
      usl12FFOMS()
    case k == 27
      usl2FFOMS()
    case k == 28
      usl6FFOMS(2)
    case k == 29
      usl6FFOMS(1)
    case k == 30 
      v_implantant()
  endcase
  if k > 0
    if k > 20
      sk2 := k - 20
    elseif k > 10
      sk1 := k - 10
    else
      sk := k
    endif
  endif
  return NIL

// 26.05.23
Function f4_uslugi(reg)
  Local i, s := 'Список услуг ', mas[2], buf := save_maxrow(), ;
      n_file := cur_dir + 'uslugi' + stxt, sh := 80, HH := 60, l, k, j, lshifr, lshifr1, lname
  local tmpAlias

  if (j := f_alert({'Необходим вывод списка отделений,', ;
                  'в которых разрешается ввод услуги?', ;
                  ''}, ;
                 {' ~Нет ', ' ~Да '}, ;
                 1, 'N+/BG', 'R/BG', 17, , col1menu )) == 0
    return NIL
  endif
  mywait()
  do case
    case reg == 1
      s += 'с ценами по ОМС'
    case reg == 2
      s := 'Список платных услуг'
    case reg == 3
      s += 'с ценами по ДМС'
  endcase
  fp := fcreate(n_file)
  n_list := 1
  tek_stroke := 0
  add_string('')
  add_string(CENTER(s, sh))
  add_string('')
  if mem_trudoem == 2
    Private arr_title := {space(sh - 15) + 'УЕТ ' + iif(is_oplata == 7, 'вр.', 'взр') + '│УЕТ ' + iif(is_oplata == 7, 'асс', 'дет'), ;
                        space(sh - 15) + '───────┴───────'}
    aeval(arr_title, {|x| add_string(x) } )
    useUch_Usl()
    l := sh - 16
  else
    l := sh
  endif
  Use_base('lusl')
  Use_base('luslc')
  R_Use(dir_server + 'mo_uch', , 'LPU')
  R_Use(dir_server + 'mo_otd', , 'OTD')
  R_Use(dir_server + 'usl_otd', dir_server + 'usl_otd', 'UO')
  R_Use(dir_server + 'uslugi',, 'USL')
  index on iif(kod > 0, '1', '0') + fsort_usl(shifr) to (cur_dir + 'tmp_usl')
  go top
  do while !eof()
    lshifr := ''
    if !empty(usl->shifr)
      s := usl->shifr
      lname := alltrim(usl->name)
      lshifr += alltrim(usl->shifr)
      lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod)
      if reg == 1 .and. !empty(lshifr1) .and. !(usl->shifr == lshifr1)
        s := lshifr1
        lshifr += '(' + alltrim(lshifr1) + ')'
      endif
      lshifr += '.'
      //if usl->zf == 1
        //lshifr += " [ЗФ] "
      //endif
      s := f42_uslugi(reg, s)
      if !empty(s)
        if mem_trudoem == 2
          if verify_FF(HH, .t., sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
        else
          verify_FF(HH, .t., sh)
        endif
        if empty(lshifr1) .or. lshifr1 == usl->shifr
          select LUSL
          find (usl->shifr)
          if found()
            lname := alltrim(lusl->name)
          endif
          // else
          //   select LUSL19
          //   find (usl->shifr)
          //   if found()
          //     lname := alltrim(lusl19->name)
          //   else
          //     select LUSL18
          //     find (usl->shifr)
          //     if found()
          //       lname := alltrim(lusl18->name)
          //     endif
          //   endif
          // endif
        endif
        k := perenos(mas, lshifr + lname + ' [' + s + ']', l, ' , ;')
        s := padr(mas[1], l)
        if mem_trudoem == 2
          select UU
          find (str(usl->kod, 4))
          if is_oplata == 7
            s += put_val_0(uu->vkoef_v, 8, 4) + put_val_0(uu->akoef_v, 8, 4)
          else
           s += put_val_0(uu->koef_v, 8, 4)+ put_val_0(uu->koef_r, 8, 4)
          endif
        endif
        add_string(s)
        for i := 2 to k
          add_string(padl(alltrim(mas[i]), l))
        next
        if j == 2
          select UO
          find (str(usl->kod, 4))
          if found()
            k := 1
            do while !(substr(uo->otdel,k, 1) == chr(0))
              otd->(dbGoto(asc(substr(uo->otdel, k, 1))))
              lpu->(dbGoto(otd->kod_lpu))
              add_string(space(18) + '= ' + alltrim(otd->name) + ' [' + alltrim(lpu->name) + ']')
              ++k
            enddo
          endif
        endif
      endif
    endif
    select USL
    skip
  enddo
  close databases
  fclose(fp)
  viewtext(n_file, , , , , , , 2)
  RETURN NIL

//
Function f42_uslugi(reg,_shifr)
Local s := "", v1, v2, fl1del, fl2del
if reg == 1
  select LUSL
  find (_shifr)
  if found()
    v1 := fcena_oms(lusl->shifr, .t.,sys1_date,@fl1del)
    v2 := fcena_oms(lusl->shifr, .f.,sys1_date,@fl2del)
    if fl1del .and. fl2del
      s += "удалена ТФОМС"
    else
      s += "Ц="+dellastnul(v1)+";ЦД="+dellastnul(v2)
    endif
  elseif !emptyall(usl->cena,usl->cena_d)
    s += "Ц="+dellastnul(usl->cena)+";ЦД="+dellastnul(usl->cena_d)
  endif
endif
// для платных услуг
if eq_any(reg, 2, 3, 23)
  if eq_any(reg, 2, 23) .and. !emptyall(usl->pcena,usl->pcena_d)
    s += "ПлЦ="+dellastnul(usl->pcena)
    if !empty(usl->pnds)
      s += "(НДС="+dellastnul(usl->pnds)+")"
    endif
    s += ";ПлЦД="+dellastnul(usl->pcena_d)
    if !empty(usl->pnds_d)
      s += "(НДС="+dellastnul(usl->pnds_d)+")"
    endif
  endif
  if eq_any(reg, 3, 23) .and. !empty(usl->dms_cena)
    if !empty(s)
      s += ";"
    endif
    s += "ДМС="+dellastnul(usl->dms_cena)
  endif
endif
return s


// 26.05.23
Function v_1usluga()
  Local arr_usl, atf := {0, '', ''}, i := 1, k, mas[2], sh := 80, HH := 60, j := 0, j1, ;
      sb, fl, lshifr, s, n_file := cur_dir + 'usluga_1' + stxt
  local prefix := prefixFileRefName(WORK_YEAR)

  if (arr_usl := input_usluga(atf)) != NIL
    mywait()
    fp := fcreate(n_file)
    n_list := 1
    tek_stroke := 0

    R_Use(dir_exe + prefix + 'dep', cur_dir + prefix + 'dep', 'DEP')
    Use_base('lusl')
    Use_base('luslc')
    R_Use(dir_server + 'uslugi', dir_server + 'uslugi', 'USL')
    add_string('')
    add_string(center('ПРОСМОТР УСЛУГИ', sh))
    add_string('')
    add_string(center('(по нашему справочнику)', sh))
    add_string('')
    if arr_usl[1] == 0
      add_string('НЕ НАЙДЕНА!')
    else
      select USL
      find (str(arr_usl[1], 4))
      lshifr := ''
      if !empty(usl->shifr)
        s := usl->shifr
        lshifr += alltrim(usl->shifr)
        lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod)
        if !empty(lshifr1) .and. !(usl->shifr == lshifr1)
          lshifr += '('+ alltrim(lshifr1) + ')'
          s := lshifr1
        endif
        lshifr += '.'
      endif
      k := perenos(mas, lshifr + ' ' + alltrim(usl->name) + ' [' + f42_uslugi(1, s) + ']', sh, ' , ;')
      add_string(mas[1])
      if k > 1
        add_string(padl(alltrim(mas[2]), sh))
      endif
      if !emptyall(usl->pcena, usl->pcena_d, usl->dms_cena)
        add_string('')
        add_string(SPACE(2) + '* Цена платной услуги' + ' [' + f42_uslugi(23) + ']')
      endif
      if mem_trudoem == 2
        useUch_Usl()
        select UU
        find (str(arr_usl[1], 4))
        add_string('')
        if is_oplata == 7
          if !emptyall(uu->koef_v, uu->vkoef_v, uu->akoef_v)
            s := '  УЕТ для взрослых ' + str_0(uu->koef_v, 7, 4) + ;
               ' [врач ' + alltrim(str_0(uu->vkoef_v, 7, 4)) + ', асс. ' + alltrim(str_0(uu->akoef_v, 7, 4)) + ']'
            add_string(s)
          endif
          if !emptyall(uu->koef_r, uu->vkoef_r, uu->akoef_r)
            s := '  УЕТ для детей    ' + str_0(uu->koef_r, 7, 4) + ;
               ' [врач ' + alltrim(str_0(uu->vkoef_r, 7, 4)) + ', асс. ' + alltrim(str_0(uu->akoef_r, 7, 4)) + ']'
            add_string(s)
          endif
        else
          if !empty(uu->koef_v)
            add_string('  УЕТ для взрослых ' + str_0(uu->koef_v, 7, 4))
          endif
          if !empty(uu->koef_r)
            add_string('  УЕТ для детей    ' + str_0(uu->koef_r, 7, 4))
          endif
        endif
      endif
    endif
    add_string('')
    add_string(replicate('-', sh))
    add_string('')
    add_string(center('(по справочнику ТФОМС)', sh))
    add_string('')
    if atf[1] == 0
      add_string('НЕ НАЙДЕНА!')
    else
      k := perenos(mas, atf[2], sh)
      add_string(mas[1])
      for i := 2 to k
        add_string(padl(alltrim(mas[i]), sh))
      next
      // select LUSLC19
      // set order to 1
      // find (atf[3])
      // do while luslc19->shifr == atf[3] .and. !eof()
      //   s := space(2) + 'c ' + date_8(luslc19->datebeg) + ' по ' + date_8(luslc19->dateend) + ': ЦЕНА ' + ;
      //      iif(luslc19->VZROS_REB == 0, 'взрослая=', 'детская =') + dellastnul(luslc19->cena)
      //   if is_otd_dep .and. luslc19->depart > 0
      //     select DEP
      //     find (str(luslc19->depart, 3))
      //     if found()
      //       s += '  (' + alltrim(dep->name_short) + ')'
      //     endif
      //   endif
      //   verify_FF(HH)
      //   add_string(s)
      //   select LUSLC19
      //   skip
      // enddo
      select LUSLC
      set order to 1
      find (atf[3])
      do while luslc->shifr == atf[3] .and. !eof()
        s := space(2) + 'c ' + date_8(luslc->datebeg) + ' по ' + date_8(luslc->dateend) + ': ЦЕНА ' + ;
           iif(luslc->VZROS_REB == 0, 'взрослая=', 'детская =') + dellastnul(luslc->cena)
        if is_otd_dep .and. luslc->depart > 0
          select DEP
          find (str(luslc->depart, 3))
          if found()
            s += '  (' + alltrim(dep->name_short) + ')'
          endif
        endif
        verify_FF(HH)
        add_string(s)
        select LUSLC
        skip
      enddo
    endif
    close databases
    fclose(fp)
    viewtext(n_file, , , , , , , 2)
  endif
  return NIL


// 08.02.23
Function v_k_uslugi()
  Local sh := 80, HH := 57, n_file := cur_dir + 'k_uslugi' + stxt

  mywait()
  fp := fcreate(n_file)
  n_list := 1
  tek_stroke := 0
  add_string('')
  add_string(center('КОМПЛЕКСНЫЕ УСЛУГИ', sh))
  add_string('')
  R_Use(dir_server + 'uslugi', dir_server + 'uslugish', 'USL')
  R_Use(dir_server + 'uslugi1k', dir_server + 'uslugi1k', 'U1K')
  set relation to shifr1 into USL
  R_Use(dir_server + 'uslugi_k', dir_server + 'uslugi_k', 'UK')
  go top
  do while !eof()
    verify_FF(HH - 3, .t., sh)
    add_string('')
    add_string(uk->shifr + ' ' + rtrim(uk->name))
    select U1K
    find (uk->shifr)
    do while u1k->shifr == uk->shifr .and. !eof()
      verify_FF(HH, .t., sh)
      add_string('   ' + u1k->shifr1 + ' ' + rtrim(usl->name))
      skip
    enddo
    select UK
    skip
  enddo
  close databases
  fclose(fp)
  viewtext(n_file, , , , , , , 2)
  return NIL

//  31.01.23
Function v_implantant()
  
  Local vrem_local := '', k, l, s, i, ss, sh := 80, HH := 57, n_file := cur_dir + 'implant' + stxt
  local mas[2]
  Local arrImplantant := get_implantant()

  mywait()
  fp := fcreate(n_file)
  n_list := 1
  tek_stroke := 0
  add_string('')
  add_string(center('Имплантируемые материалы', sh))
  add_string('')
  l := sh
  asort(arrImplantant, , ,{|x, y| (padr(x[7], 75) + x[1]) < (padr(y[7], 75) + y[1])}) 
  // vrem_local := arrImplantant[1, 7]
  // if len(alltrim(vrem_local)) < 2
  //   add_string(center('Без группы', sh))
  // else  
  //   add_string(center(vrem_local, sh))
  // endif
  for i := 1 to len(arrImplantant)
    // if vrem_local != arrImplantant[i, 7]
    //   if verify_FF(HH, .t., sh)
    //   endif
    //   vrem_local := arrImplantant[i, 7]
    //   add_string('')
    //   add_string(center(vrem_local, sh))
    //   add_string('')
    // endif
    if verify_FF(HH, .t., sh)
    endif
    k := perenos(mas, alltrim(arrImplantant[i, 1]), l, ' , ;')
    s := padr(mas[1], l)
    add_string(s)
    if k > 1
      add_string(padl(alltrim(mas[2]), l))
    endif
  next
  fclose(fp)
  viewtext(n_file, , , , , , , 2)
  return NIL
  


// 08.02.23
Function v_nulusluga()
  Local mas[2], k, l, s, sh := 80, HH := 57, n_file := cur_dir + 'n_uslugi' + stxt

  mywait()
  fp := fcreate(n_file)
  n_list := 1
  tek_stroke := 0
  add_string('')
  add_string(center('УСЛУГИ, для которых разрешается ввод нулевой цены', sh))
  if mem_trudoem == 2
    Private arr_title := {space(sh - 15) + 'УЕТ ' + iif(is_oplata == 7, 'вр.', 'взр') + '│УЕТ ' + iif(is_oplata == 7, 'асс', 'дет'), ;
                        space(sh - 15) + '───────┴───────'}
    aeval(arr_title, {|x| add_string(x) })
    useUch_Usl()
    l := sh - 16
  else
    l := sh
  endif
  R_Use(dir_server + 'uslugi', , 'USL')
  for i := 1 to 2
    add_string('')
    add_string(center(iif(i == 1, '[ ОМС ]', '[ Платные услуги ]'), sh))
    add_string('')
    index on iif(kod > 0, '1', '0') + fsort_usl(shifr) to (cur_dir + 'tmp_usl') ;
        for !empty(shifr) .and. iif(i == 1, is_nul, is_nulp)
    go top
    do while !eof()
      if mem_trudoem == 2
        if verify_FF(HH, .t., sh)
          aeval(arr_title, {|x| add_string(x)})
        endif
      else
        verify_FF(HH, .t., sh)
      endif
      s := rtrim(usl->shifr) + ' '
      //if usl->zf == 1
        //s += '[ЗФ] '
      //endif
      k := perenos(mas, s + alltrim(usl->name), l, ' , ;')
      s := padr(mas[1], l)
      if mem_trudoem == 2
        select UU
        find (str(usl->kod, 4))
        if is_oplata == 7
          s += put_val_0(uu->vkoef_v, 8, 4) + put_val_0(uu->akoef_v, 8, 4)
        else
          s += put_val_0(uu->koef_v, 8, 4) + put_val_0(uu->koef_r, 8, 4)
        endif
      endif
      add_string(s)
      if k > 1
        add_string(padl(alltrim(mas[2]), l))
      endif
      select USL
      skip
    enddo
  next
  close databases
  fclose(fp)
  viewtext(n_file, , , , , , , 2)
  return NIL

// 30.05.23 даты смены цен
Function usl1TFOMS()
  Local k, buf := save_maxrow(), name_file := cur_dir + 'uslugi' + stxt, sh := 80, HH := 60, ;
      i, s, fl, v1, v2, mdate, pole, nu, t_arr[BR_LEN], ret, ret_arr, scode, dy
  local sbase, tmpAlias

  mywait()
  dbcreate(cur_dir + 'tmp', {{'ibeg', 'N', 1, 0}, {'iend', 'N', 1, 0}, {'data', 'D', 8, 0}})
  use (cur_dir + 'tmp') new
  index on dtos(data) to (cur_dir + 'tmp')
  use_base('luslc')

  for i := 2018 to WORK_YEAR
    tmpAlias := create_name_alias('LUSLC', i)
    if ! (tmpAlias)->(used())
      loop
    endif
    select (tmpAlias)
    index on datebeg to (cur_dir + 'tmp_' + tmpAlias) for !empty(datebeg) .and. codemo == glob_mo[_MO_KOD_TFOMS] unique
    go top
    do while !eof()
      select TMP
      append blank
      tmp->ibeg := 1
      tmp->data := (tmpAliAs)->datebeg
      select (tmpAliAs)
      skip
    enddo
    select (tmpAlias)
    index on dateend to (cur_dir + 'tmp_' + tmpAlias) for !empty(dateend) .and. codemo == glob_mo[_MO_KOD_TFOMS] unique
    go top
    do while !eof()
      select TMP
      find (dtos((tmpAlias)->dateend))
      if !found()
        append blank
        tmp->data := (tmpAlias)->dateend
      endif
      tmp->iend := 1
      select (tmpAlias)
      skip
    enddo
  next
  close databases

  rest_box(buf)
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT] := T_COL - 5
  t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 26
  t_arr[BR_COLOR] := color0
  t_arr[BR_COLUMN] := {{ 'Даты смены;   цен', {|| iif(tmp->ibeg == 1, full_date(tmp->data), space(10))}}, ;
                     {'Окончание; действия;  услуг', {|| iif(tmp->iend == 1, full_date(tmp->data), space(10))}}}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - выход;  ^<Enter>^ - выбор')}
  t_arr[BR_ENTER] := {|| ret := {tmp->data, tmp->ibeg, tmp->iend}}
  use (cur_dir + 'tmp') index (cur_dir + 'tmp') new
  keyboard chr(K_END)
  edit_browse(t_arr)
  close databases

  if ret != NIL
    mdate := ret[1]
    dy := year(mdate)
    scode := glob_mo[_MO_KOD_TFOMS]
    mywait()
    dbcreate(cur_dir + 'tmp1', {{'shifr',   'C', 10, 0}, ;
                                {'flv',     'L', 1, 0}, ;
                                {'fld',     'L', 1, 0}, ;
                                {'depart',  'N', 3, 0}, ;
                                {'cenav',   'N', 10, 2}, ;
                                {'cenad',   'N', 10, 2}})

    sbase := prefixFileRefName(dy) + 'dep'
    R_Use(dir_exe + sbase, cur_dir + sbase, 'DEP')

    use (cur_dir + 'tmp1') new
    index on shifr + str(depart, 3) to (cur_dir + 'tmp1')
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    add_string(glob_mo[_MO_SHORT_NAME] + iif(valtype(ret_arr) == 'A', ' (' + ret_arr[2] + ' - ' + ret_arr[1] + ')', ''))
    if ret[2] == 1
      add_string('')
      add_string(center('Список цен на услуги', sh))
      add_string(center('[ цены установлены '+ date_8(mdate) + 'г. ]', sh))
      add_string('')
      use_base('luslc')
      tmpAlias := create_name_alias('LUSLC', dy)
      select (tmpAlias)
      //   set order to 2 // работаем с собственными ценами
      //   find (scode)
      //   do while (tmpAlias)->CODEMO == scode .and. !eof()
      go top
      do while !eof()
        if (tmpAlias)->datebeg == mdate
          select TMP1
          find ((tmpAlias)->shifr + str((tmpAlias)->depart, 3))
          if !found()
            append blank
            tmp1->shifr := (tmpAlias)->shifr
            tmp1->depart := (tmpAlias)->depart
          endif
          if (tmpAlias)->VZROS_REB == 0
            tmp1->flv := .t.
            tmp1->cenav := (tmpAlias)->CENA
          else
            tmp1->fld := .t.
            tmp1->cenad := (tmpAlias)->CENA
          endif
        endif
        select (tmpAlias)
        skip
      enddo

      use_base('lusl')
      lal := 'lusl'
      select TMP1

      lal := create_name_alias(lal, dy)
      set relation to shifr into (lal)

      index on fsort_usl(shifr) to (cur_dir + 'tmp1')
      go top
      old := space(10)
      do while !eof()
        n := iif(empty(tmp1->depart), 50, 70)
        k := perenos(t_arr, if(len(alltrim(tmp1->shifr)) == 10, ' ', '') + &lal.->name, n)
        if empty(tmp1->depart)
          s := tmp1->shifr+padr(t_arr[1], n)
          if emptyall(tmp1->cenav, tmp1->cenad)
            s += iif(tmp1->flv, put_kop(tmp1->cenav, 10), space(10))
            s += iif(tmp1->fld, put_kop(tmp1->cenad, 10), space(10))
          else
            s += put_kopE(tmp1->cenav, 10) + put_kopE(tmp1->cenad, 10)
          endif
          verify_FF(HH-k, .t., sh)
          add_string(s)
          for i := 2 to k
            add_string(space(10) + t_arr[i])
          next
        endif
        if !empty(tmp1->depart)
          if !(old == tmp1->shifr)
            verify_FF(HH - k - 1, .t., sh)
            for i := 1 to k
              add_string(iif(i == 1, tmp1->shifr, space(10)) + t_arr[i])
            next
          endif
          select DEP
          find (str(tmp1->depart, 3))
          if found()
            s := padl(alltrim(dep->name_short), 60)
            s += put_kopE(tmp1->cenav, 10) + put_kopE(tmp1->cenad, 10)
            verify_FF(HH, .t., sh)
            add_string(s)
          endif
        endif
        old := tmp1->shifr
        select TMP1
        skip
      enddo
    endif
    if ret[3] == 1
      add_string('')
      add_string(center('Список услуг, закончивших действие', sh))
      add_string(center(date_month(mdate, .t.), sh))
      add_string('')
      use_base('luslc')
      tmpAlias := create_name_alias('LUSLC', dy)
      select (tmpAlias)
      //   set order to 2 // работаем с собственными ценами
      //   find (scode)
      //   do while (tmpAlias)->CODEMO == scode .and. !eof()
      go top
      do while !eof()
        if !empty((tmpAlias)->dateend) .and. (tmpAlias)->dateend == mdate
          select TMP1
          find ((tmpAlias)->shifr + str((tmpAlias)->depart, 3))
          if !found()
            append blank
            tmp1->shifr := (tmpAlias)->shifr
            tmp1->depart := (tmpAlias)->depart
          endif
          if luslc->VZROS_REB == 0
            tmp1->flv := .t.
            tmp1->cenav := (tmpAlias)->CENA
          else
            tmp1->fld := .t.
            tmp1->cenad := (tmpAlias)->CENA
          endif
        endif
        select (tmpAlias)
        skip
      enddo

      use_base('lusl')
      lal := 'lusl'
      select TMP1
      lal := create_name_alias(lal, dy)
      set relation to shifr into (lal)

      index on fsort_usl(shifr) to (cur_dir + 'tmp1')
      go top
      old := space(10)
      do while !eof()
        n := iif(empty(tmp1->depart), 50, 70)
        k := perenos(t_arr, &lal.->name, n)
        if empty(tmp1->depart)
          s := tmp1->shifr + padr(t_arr[1], n)
          if emptyall(tmp1->cenav, tmp1->cenad)
            s += iif(tmp1->flv, put_kop(tmp1->cenav, 10), space(10))
            s += iif(tmp1->fld, put_kop(tmp1->cenad, 10), space(10))
          else
            s += put_kopE(tmp1->cenav, 10) + put_kopE(tmp1->cenad, 10)
          endif
          verify_FF(HH - k, .t., sh)
          add_string(s)
          for i := 2 to k
            add_string(space(10) + t_arr[i])
          next
        endif
        if !empty(tmp1->depart)
          if !(old == tmp1->shifr)
            verify_FF(HH - k - 1, .t., sh)
            for i := 1 to k
              add_string(iif(i == 1, tmp1->shifr, space(10)) + t_arr[i])
            next
          endif
          select DEP
          find (str(tmp1->depart, 3))
          if found()
            s := padl(alltrim(dep->name_short), 60)
            s += put_kopE(tmp1->cenav, 10) + put_kopE(tmp1->cenad, 10)
            verify_FF(HH, .t., sh)
            add_string(s)
          endif
        endif
        old := tmp1->shifr
        select TMP1
        skip
      enddo
    endif
    close databases
    rest_box(buf)
    fclose(fp)
    viewtext(name_file, , , , .t., , , 2)
  endif
  return NIL

// 15.01.18
Function ret_otd_dep()
Local ret_arr
if !(valtype(glob_otd_dep) == "N")
  glob_otd_dep := 0
endif
popup_2array(mm_otd_dep,T_ROW,T_COL-5,glob_otd_dep, 1,@ret_arr,"Выбор отделения стационара","B/BG")
if valtype(ret_arr) == "A"
  glob_otd_dep := ret_arr[2]
endif
return ret_arr

// 07.08.17
Function f_spr_usl_adres_podr()
Static arr := {}
Local i, j, ret_arr
if (i := ascan(glob_adres_podr, {|x| x[1] == glob_mo[_MO_KOD_TFOMS] })) > 0
  if empty(arr)
    for j := 1 to len(glob_adres_podr[i, 2])
      aadd(arr,{glob_adres_podr[i, 2,j, 3],glob_adres_podr[i, 2,j, 1]})
    next
  endif
  popup_2array(arr,T_ROW,T_COL-5,glob_podr, 1,@ret_arr,"Адрес удалённого подразделения","B/BG")
  if valtype(ret_arr) == "A"
    glob_podr := ret_arr[2]
  endif
endif
if empty(ret_arr)
  glob_podr := glob_mo[_MO_KOD_TFOMS] // по умолчанию
endif
return ret_arr

// 08.12.21
Function usl2TFOMS()
  Static sdate
  Local k, buf := save_maxrow(), name_file := cur_dir + 'uslugi' + stxt, nu, ret_arr, ;
      sh := 80, HH := 60, t_arr, i, s, fl, v1, v2, mdate, fl1uslc, fl2uslc, ;
      ta[2], lyear, fl1del, fl2del, len_ksg := 10
  local arrKSLP, rowKSLP, tmpKSLP, arrKIRO, rowKIRO, tmpKIRO
  local sbase

  DEFAULT sdate TO sys1_date
  mdate := input_value(20, 5, 22, 73,color1, ;
                     "Дата, по состоянию на которую выводятся цены на услуги", ;
                     sdate)
  if mdate == NIL
    return NIL
  endif
  if (lyear := year(mdate)) < 2018
    return func_error(4, 'Вы запрашиваете слишком старую информацию')
  endif
  if lyear > WORK_YEAR
    return func_error(4, 'Информация на будуюшую дату отсутствует')
  endif
  sdate := mdate
  if (k := popup_2array(usl9TFOMS(mdate),T_ROW,T_COL-5,su, 1,@t_arr,"Выберите группу услуг","B/BG",color0)) > 0
    glob_podr := ""
    if is_otd_dep .and. t_arr[2] == 501
      if (ret_arr := ret_otd_dep()) == NIL
        return NIL
      endif
    else
      glob_otd_dep := 0
    endif
    mywait()
    su := k
    fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
    nu := get_uroven(mdate)
    /*if between(nu, 1, 3)
      s := "Уровень цен на мед.услуги: "+lstr(nu)
    else
      s := "Индивидуальные тарифы на мед.услуги"
    endif*/
    add_string(glob_mo[_MO_SHORT_NAME]+iif(valtype(ret_arr)=="A", " ("+ret_arr[1]+")",""))
    add_string('')
    add_string(center("Список услуг по группе", sh))
    add_string(center('"'+ alltrim(t_arr[1])+'"', sh))
    add_string(center("[ цены по состоянию на "+ date_8(mdate)+"г. ]", sh))
    add_string("")
    if t_arr[2] > 500
      arrKSLP := getKSLPtable( mdate )
      add_string('КСЛП:')
      for each rowKSLP in arrKSLP
        k := perenos(ta, alltrim(rowKSLP[3]), 58)
        for i := 1 to k
          if i == 1
            tmpKSLP := str(rowKSLP[1], 7) + ' - ' + ta[i] + ' (коеф=' + str(rowKSLP[4], 4, 2) + ')'
          else
            tmpKSLP := space(10) + ta[i]
          endif
          add_string(tmpKSLP)
        next
      next
      arrKIRO := getKIROtable( mdate )
      add_string('КИРО:')
      for each rowKIRO in arrKIRO
        if between_date(rowKIRO[5], rowKIRO[6], mdate)
          k := perenos(ta, alltrim(rowKIRO[3]), 58)
          for i := 1 to k
            if i == 1
              tmpKIRO := str(rowKIRO[1], 7) + ' - ' + ta[i] + ' (коеф=' + str(rowKIRO[4], 4, 2) + ')'
            else
              tmpKIRO := space(10) + ta[i]
            endif
            add_string(tmpKIRO)
          next
        endif
      next

      sbase := prefixFileRefName(lyear) + 'k006'
      R_Use(exe_dir + sbase, , 'K006')
    
      index on SHIFR+str(ns, 6) to (cur_dir + "tmp_k006") unique
      index on SHIFR+str(ns, 6)+ds+sy to (cur_dir + "tmp_k006_")
      set index to (cur_dir + "tmp_k006"),(cur_dir + "tmp_k006_")
    endif
    use_base('luslc')
    use_base('lusl')
    lal := 'lusl'
    lal := create_name_alias(lal, lyear)

    dbSelectArea(lal)
    if t_arr[2] > 500
      index on fsort_usl(shifr) to (cur_dir + "tmplu") for is_ksg(shifr,t_arr[2]-500) .and. datebeg >= boy(mdate)
    else
      index on fsort_usl(shifr) to (cur_dir + "tmp") for usl2arr(shifr)[1]==k .and. !is_ksg(shifr)
    endif
    go top
    do while !eof()

      v1 := fcena_oms(&lal.->shifr, .t.,mdate,@fl1del,@fl1uslc)
      v2 := fcena_oms(&lal.->shifr, .f.,mdate,@fl2del,@fl2uslc)
      if !(fl1del .and. fl2del)
        s := alltrim(&lal.->name)
        if len(alltrim(&lal.->shifr)) == 10
          s := " "+s
        endif
        k := perenos(ta,s, 50)
        verify_FF(HH-k-1, .t., sh)
        if t_arr[2] > 100
          add_string(replicate("─", sh))
        endif
        add_string(&lal.->shifr+ta[1]+;
                 iif(fl1del,"      -   ", put_kop(v1, 10))+;
                 iif(fl2del,"      -   ", put_kop(v2, 10)))
        s := space(10)+padr(ta[2], 50)
        if !empty(s)
          add_string(s)
        endif
        for i := 3 to k
          add_string(space(10)+ta[i])
        next
        if t_arr[2] > 500
          select K006
          set order to 1
          find (padr(&lal.->shifr,len_ksg))
          s1 := f_ret_kz_ksg(k006->kz,&lal.->kslps,&lal.->kiros)
          add_string(space(10)+s1)
          do while padr(&lal.->shifr,len_ksg) == k006->shifr .and. !eof()
            if between_date(k006->DATEBEG,k006->DATEEND,mdate)
              lrec := k006->(recno())
              lns := k006->ns
              i := 0
              s := s1 := ""
              set order to 2
              find (padr(&lal.->shifr,len_ksg)+str(lns, 6))
              do while padr(&lal.->shifr,len_ksg) == k006->shifr .and. lns == k006->ns .and. !eof()
                if !empty(k006->DS)
                  s1 += alltrim(k006->DS)+" "
                endif
                if ++i == 1
                  if !empty(k006->DS1)
                    s += "СОПУТ.Диагноз "+ alltrim(k006->DS1)+"; "
                  endif
                  if !empty(k006->DS2)
                    s += "Диагноз ОСЛОЖНЕНИЯ "+ alltrim(k006->DS2)+"; "
                  endif
                  if !empty(k006->SY)
                    s += "УСЛУГА "+ alltrim(k006->sy)+"; "
                  endif
                  if !empty(k006->AGE)
                    s += "ВОЗРАСТ "+ret_vozrast_k006(k006->AGE)+"; "
                  endif
                  if !empty(k006->SEX)
                    s += "ПОЛ "+iif(k006->SEX=='1',"мужской","женский")+"; "
                  endif
                  if !empty(k006->LOS)
                    s += ret_duration_k006(k006->LOS,iif(left(&lal.->shifr, 1)=='1',"койко","пациенто")+"-")+"; "
                  endif
                  if k006->(fieldpos("RSLT")) > 0 .and. !empty(k006->RSLT)
                    s += "РЕЗУЛЬТАТ "+ alltrim(k006->RSLT)+"; "
                  endif
                  if k006->(fieldpos("AD_CR")) > 0 .and. !empty(k006->AD_CR)
                    s += "ДОП.КРИТЕРИЙ "+ alltrim(k006->AD_CR)+"; "
                  endif
                  if k006->(fieldpos("AD_CR1")) > 0 .and. !empty(k006->AD_CR1)
                    s += "ИНОЙ КРИТЕРИЙ "+ alltrim(k006->AD_CR1)+"; "
                  endif
                endif
                skip
              enddo
              if !empty(s1)
                s1 := "ОСН.Диагноз "+left(s1,len(s1)-1)+"; "
              endif
              s := s1+s
              s := left(s,len(s)-2)
              k := perenos(ta,s, 70)
              for i := 1 to k
                verify_FF(HH, .t., sh)
                add_string(iif(i==1, space(8)+"- ", space(10))+ta[i])
              next
              select K006
              goto (lrec)
              set order to 1
            endif
            skip
          enddo
        endif
      endif
      dbSelectArea(lal)
      skip
    enddo
    close databases
    rest_box(buf)
    fclose(fp)
    viewtext(name_file,,,, .t.,,, 2)
  endif
  return NIL

// 08.12.21
Function ret_vozrast_k006(s)
  Local ret := ""

  do case
    case s == '1'
      ret := "0-28 дней"
    case s == '2'
      ret := "29-90 дней"
    case s == '3'
      ret := "от 91 дня до 1 года"
    case s == '4'
      ret := "до 2 лет включительно"
    case s == '5'
      ret := "ребёнок"
    case s == '6'
      ret := "взрослый"
  endcase
  return ret

// 08.12.21
Function ret_duration_k006(s,s1)
  Static sd := "день", sdr := "дня", sdm := "дней"
  Local arr := {"1-3 " + s1 + sdr, ;                   //  1
              "4 " + s1 + sdr + " и более", ;          //  2
              "1-6 " + s1 + sdm, ;                     //  3
              "7 " + s1 + sdm + " и более", ;          //  4
              "21 " + s1 + sd + " и более", ;          //  5
              "1-20 " + s1 + sdm, ;                    //  6
              "1 " + s1 + sd, ;                        //  7
              "4-7 " + s1 + sdm, ;                     //  8
              "8-10 " + s1 + sdm, ;                    //  9
              "11 " + s1 + sdm + " и более"}          // 10
  Local i := int(val(s))

  return "дл-ть " + iif(between(i, 1, 10), arr[i], "")

// 08.02.23
Function f_ret_kz_ksg(lkz, lkslp, lkiro)
  Local s := 'коэф-т затратоёмкости ' + lstr(lkz, 5, 2)

  if !empty(lkslp)
    s += '; КСЛП: ' + alltrim(lkslp)
  endif
  if !empty(lkiro)
    s += '; КИРО: ' + alltrim(lkiro)
  endif
  return s

// 08.02.23
Function usl3TFOMS()
Local i, k, buf := save_maxrow(), name_file := cur_dir + 'uslugi' + stxt, ;
      sh := 85, HH := 80, mas1[5], mas2[5], arr[5], k1, k2, t_arr, mdate, lyear
//
if (mdate := input_value(20, 5, 22, 74,color1, ;
                         "Введите дату, на которую необходимо получить информацию", ;
                         sys_date)) == NIL
  return NIL
endif
if (lyear := year(mdate)) < 2018
  return func_error(4, 'Вы запрашиваете слишком старую информацию')
endif
if lyear > WORK_YEAR
  return func_error(4, 'Информация на будуюшую дату отсутствует')
endif

if (k := popup_2array(usl9TFOMS(mdate),T_ROW,T_COL-5,su, 1,@t_arr,"Выберите группу услуг","B/BG",color0)) > 0
  su := k
  mywait()
  arr_title := { ;
"──────────────────────────────────────────┬──────────────────────────────────────────", ;
" Справочник ТФОМС                         │ Наш справочник услуг                     ", ;
"──────────────────────────────────────────┴──────────────────────────────────────────"}
  fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
  add_string(center("Список услуг по группе", sh))
  add_string(center('"'+ alltrim(t_arr[1])+'"', sh))
  add_string(center('по состоянию на '+date_month(mdate, .t.), sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  dbcreate(cur_dir + "tmp",{{"shifr","C", 10, 0}})
  use (cur_dir + "tmp") new
  R_Use(dir_server + 'uslugi',, 'USL')
  go top
  do while !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,mdate)
    select TMP
    do while tmp->(lastrec()) < usl->(recno())
      append blank
    enddo
    goto (usl->(recno()))
    tmp->shifr := iif(empty(lshifr1), usl->shifr, lshifr1)
    select USL
    skip
  enddo
  select TMP
  set relation to recno() into USL
  index on shifr+fsort_usl(usl->shifr) to (cur_dir + "tmp")
  use_base('lusl')
  lal := 'lusl'
  lal := create_name_alias(lal, lyear)

  dbSelectArea(lal)
  if t_arr[2] > 500
    index on fsort_usl(shifr) to (cur_dir + "tmplu") for is_ksg(shifr,t_arr[2]-500) .and. datebeg >= boy(mdate)
  else
    index on fsort_usl(shifr) to (cur_dir + "tmplu") for usl2arr(shifr)[1]==k .and. !is_ksg(shifr)
  endif
  go top
  do while !eof()
    k1 := perenos(mas1,alltrim(&lal.->shifr)+" "+&lal.->name, 42)
    for i := 2 to k1
      mas1[i] := padl(alltrim(mas1[i]), 42)
    next
    mas2 := {} ; k2 := 0
    select TMP
    find (&lal.->shifr)
    do while &lal.->shifr == tmp->shifr .and. !eof()
      k := perenos(arr,alltrim(usl->shifr)+" "+usl->name, 42)
      for i := 1 to k
        if i == 1
          aadd(mas2,arr[1])
        else
          aadd(mas2,padl(alltrim(arr[i]), 42))
        endif
      next
      k2 += k
      select TMP
      skip
    enddo
    for i := 1 to max(k1,k2)
      if verify_FF(HH, .t., sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      s := ""
      if i <= k1
        s := mas1[i]
      endif
      if i <= k2
        s := padr(s, 43)+mas2[i]
      endif
      add_string(s)
    next
    add_string(replicate("─", sh))
    dbSelectArea(lal)
    skip
  enddo
  close databases
  rest_box(buf)
  fclose(fp)
  viewtext(name_file,,,, .t.,,, 5)
endif
return NIL

// 08.11.21
Function usl9TFOMS(mdate)
Static sdate, sarr1
Local arr := {{" 1. Койко-дни по профилям", 1}, ;
              {" 2. Врачебные приёмы по профилям", 2}, ;
              {" 3. Процедуры и манипуляции", 3}, ;
              {" 4. Лабораторные исследования", 4}, ;
              {" 7. Рентгенологические исследования", 7}, ;
              {" 8. Ультразвуковые исследования", 8}, ;
              {"10. Эндоскопические исследования", 10}, ;
              {"13. Электрокардиографические исследования", 13}, ;
              {"14. Реоэнцефалография", 14}, ;
              {"16. Прочие исследования", 16}, ;
              {"19. Физиотерапевтическое лечение", 19}, ;
              {"20. Лечебная физкультура", 20}, ;
              {"21. Массаж", 21}, ;
              {"22. Рефлексотерапия", 22}, ;
              {"55. Дневные стационары", 55}, ;
              {"56. Прочие услуги", 56}, ;
              {"60. Тарифы на отдельные медицинские услуги", 60}, ;
              {"70. Диспансеризация", 70}, ;
              {"71. Скорая медицинская помощь", 71}, ;
              {"72. Профилактические медицинские осмотры", 72}}
Local i, ls, sShifr, arr1 := {}, lyear, fl_delete := .t., fl_yes := .f., lal := 'luslc'
if empty(sdate) .or. sdate != mdate
  lal := create_name_alias(lal, mdate)

  Ins_Array(arr, 1,{"КСГ в ДНЕВНОМ стационаре", 502})
  Ins_Array(arr, 1,{"КСГ в СТАЦИОНАРЕ", 501})

  use_base('luslc')
  for i := 1 to len(arr)
    if arr[i, 2] > 500
      sShifr := iif(arr[i, 2] == 501, "st", "ds")
    else
      sShifr := lstr(arr[i, 2])+"."
    endif
    ls := len(sShifr)
    dbselectArea(lal)

    set order to 1
    find (sShifr)
    do while sShifr == left(&lal.->shifr,ls) .and. !eof()
      if iif(arr[i, 2] > 500, is_ksg(&lal.->shifr), .t.)
        fl_yes := .t.
        // поиск цены по дате окончания лечения
        if between_date(&lal.->datebeg,&lal.->dateend,mdate)
          fl_delete := .f. ; exit

        endif
      endif
      skip
    enddo
    if fl_yes .and. !fl_delete
      aadd(arr1,arr[i])
    endif
  next
  close databases
else
  arr1 := aclone(sarr1)
endif
sdate := mdate
sarr1 := aclone(arr1)
return arr1

// 08.02.23
Function usl3FFOMS()
  // A,B - класс медуслуги
  // XX - раздел медуслуги
  Local arr := { ;
    "A01 функциональное обследование без использования приспособлений и/или приборов и выполняемое непосредственно медицинскими работниками (физикальные исследования, включая сбор жалоб, анамнеза, перкуссию, пальпацию и аускультацию)", ;
    "A02 функциональное обследование с использованием простых приспособлений, приборов, не требующее специальных навыков и помощи ассистента", ;
    "A03 визуальное обследование, требующее специальных приборов, навыков и помощи ассистента", ;
    "A04 регистрация звуковых сигналов, издаваемых или отражающихся органами или тканями с их последующей расшифровкой и описанием", ;
    "A05 регистрация электромагнитных сигналов, испускаемых или потенцированных в органах и тканях с их последующей расшифровкой и описанием", ;
    "A06 рентгенологические исследования с их последующим описанием и рентгенотерапия", ;
    "A07 исследования с помощью радионуклидов и методы радиационной терапии", ;
    "A08 морфологические исследования тканей", ;
    "A09 исследования биологических жидкостей, с помощью которых исследуются концентрации веществ в жидких средах организма и активность ферментативных систем", ;
    "A10 диагностические исследования, выполняемые в процессе лечения", ;
    "A11 специальные методы получения исследуемых образцов, доступа и введения", ;
    "A12 исследования функции органов или тканей с использованием специальных процедур, приспособлений и методик, не обозначенных в других рубриках, направленных на прямое исследование функции органов или тканей, - медикаментозные и физические пробы, исследование оседания эритроцитов, иммунные реакции, в том числе определение группы крови и резус-фактора, исследование системы гемостаза (за исключением уровня факторов свертывающей системы) и др.", ;
    "A13 исследования и воздействия на сознание и психическую сферу", ;
    "A14 уход за больными или отдельными анатомо-физиологическими элементами организма (ротовая полость, верхние дыхательные пути и т.д.)", ;
    "A15 десмургия, иммобилизация, бандажи, ортопедические пособия", ;
    "A16 оперативное лечение", ;
    "A17 электромагнитное лечебное воздействие на органы и ткани", ;
    "A18 экстракорпоральное воздействие на кровь и трансфузиологические пособия", ;
    "A19 лечебная физкультура, применяемая при заболеваниях определенных органов и систем", ;
    "A20 лечение климатическими воздействиями (вода, воздух и др.)", ;
    "A21 лечение с помощью простых физических воздействий на пациента (массаж, иглорефлексотерапия, мануальная терапия)", ;
    "A22 лечение с помощью лучевого (звукового, светового, ультрафиолетового, лазерного) воздействия", ;
    "A23 диагностика и лечение, не обозначенные в других рубриках", ;
    "A24 диагностика и лечение, основанные на тепловых эффектах", ;
    "A25 назначения", ;
    "A26 микробиологические исследования основных возбудителей инфекционных заболеваний", ;
    "B01 врачебная лечебно-диагностическая услуга", ;
    "B02 сестринский уход", ;
    "B03 сложная диагностическая услуга (методы исследования: лабораторный, функциональный, инструментальный, рентгенорадиологический и др.), формирующие диагностические комплексы", ;
    "B04 медицинские услуги по профилактике, такие как диспансерное наблюдение, вакцинация, медицинские физкультурно-оздоровительные мероприятия", ;
    "B05 медицинские услуги по медико-социальной реабилитации";
  }
  Local i

  for i := 1 to len(arr)
    arr[i] := {arr[i], left(arr[i], 3)}
  next
  return arr


// 18.02.23
Function usl4FFOMS()
  // A - класс медуслуги
  // XX - раздел медуслуги
  // XX - подраздел медуслуги (затем "001"-группа и м.б. ".001"-подгруппа)
  Local arr := { ;
    "01 Кожа, подкожно-жировая клетчатка, придатки кожи", ;
    "02 Мышечная система",                               ;
    "03 Костная система",                                ;
    "04 Суставы",                                        ;
    "05 Система органов кроветворения и кровь",          ;
    "06 Иммунная система",                               ;
    "07 Полость рта и зубы",                             ;
    "08 Верхние дыхательные пути",                       ;
    "09 Нижние дыхательные пути и легочная ткань",       ;
    "10 Сердце и перикард",                              ;
    "11 Средостение",                                    ;
    "12 Крупные кровеносные сосуды",                     ;
    "13 Система микроциркуляции",                        ;
    "14 Печень и желчевыводящие пути",                   ;
    "15 Поджелудочная железа",                           ;
    "16 Пищевод, желудок, двенадцатиперстная кишка",     ;
    "17 Тонкая кишка",                                   ;
    "18 Толстая кишка",                                  ;
    "19 Сигмовидная и прямая кишка",                     ;
    "20 Женские половые органы",                         ;
    "21 Мужские половые органы",                         ;
    "22 Железы внутренней секреции",                     ;
    "23 Центральная нервная система и головной мозг",    ;
    "24 Периферическая нервная система",                 ;
    "25 Орган слуха",                                    ;
    "26 Орган зрения",                                   ;
    "27 Орган обоняния",                                 ;
    "28 Почки и мочевыделительная система",              ;
    "29 Психическая сфера",                              ;
    "30 Прочие"                                          ;
  }
  Local i

  for i := 1 to len(arr)
    arr[i] := {arr[i], left(arr[i], 2)}
  next
  return arr


// 08.02.23
Function usl5FFOMS()
  // B - класс медуслуги
  // XX - раздел медуслуги
  // XXX - подраздел медуслуги (затем "001"-группа и м.б. ".001"-подгруппа)
  Local arr := { ;
    "001 акушерство и гинекология", ;
    "002 аллергология и иммунология", ;
    "003 анестезиология и реаниматология", ;
    "004 гастроэнтерология", ;
    "005 гематология", ;
    "006 генетика", ;
    "007 гериатрия", ;
    "008 дерматовенерология и косметология", ;
    "009 детская онкология", ;
    "010 детская хирургия", ;
    "011 детская эндокринология", ;
    "012 диабетология", ;
    "013 диетология", ;
    "014 инфекционные болезни", ;
    "015 кардиология, детская кардиология", ;
    "016 клиническая лабораторная диагностика", ;
    "017 клиническая фармакология", ;
    "018 колопроктология", ;
    "019 лабораторная генетика", ;
    "020 лечебная физкультура и спортивная медицина", ;
    "021 социальная гигиена, санитария и эпидемиология", ;
    "022 мануальная терапия", ;
    "023 неврология", ;
    "024 нейрохирургия", ;
    "025 нефрология", ;
    "026 общая врачебная практика (семейная медицина)", ;
    "027 онкология", ;
    "028 оториноларингология", ;
    "029 офтальмология", ;
    "030 патологическая анатомия", ;
    "031 педиатрия", ;
    "032 неонатология", ;
    "033 профпатология", ;
    "034 психотерапия", ;
    "035 психиатрия и судебно-психиатрическая экспертиза", ;
    "036 психиатрия-наркология", ;
    "037 пульмонология", ;
    "038 радиология и радиотерапия", ;
    "039 рентгенология", ;
    "040 ревматология", ;
    "041 рефлексотерапия", ;
    "042 сексология", ;
    "043 сердечно-сосудистая хирургия, рентгенэндоваскулярная диагностика и лечение", ;
    "044 скорая медицинская помощь", ;
    "045 судебно-медицинская экспертиза", ;
    "046 сурдология-оториноларингология", ;
    "047 терапия", ;
    "048 токсикология", ;
    "049 торакальная хирургия", ;
    "050 травматология и ортопедия", ;
    "051 трансфузиология", ;
    "052 ультразвуковая диагностика", ;
    "053 урология, детская урология-андрология", ;
    "054 физиотерапия", ;
    "055 фтизиатрия", ;
    "056 функциональная диагностика", ;
    "057 хирургия, хиругия (трансплантация органов и тканей) и комбустиология", ;
    "058 эндокринология", ;
    "059 эндоскопия", ;
    "060 бактериология", ;
    "061 вирусология", ;
    "062 эпидемиология", ;
    "063 ортодонтия", ;
    "064 стоматология и стоматология детская", ;
    "065 стоматология терапевтическая", ;
    "066 стоматология ортопедическая", ;
    "067 стоматология хирургическая", ;
    "068 челюстно-лицевая хирургия", ;
    "069 прочие";
  }
  Local i

  for i := 1 to len(arr)
    arr[i] := {arr[i], left(arr[i], 3)}
  next
  return arr

// 08.02.23
Function usl_stom_FFOMS()
Static arr_gr := {"Общепрофильные","Ортодонтия","Терапевтическая стоматология","Физиотерапия","Хирургическая стоматология"}
Local i, j, k, s, buf := save_maxrow(), name_file := cur_dir + "uslugiS" + stxt, sh := 80, HH := 60, t_arr[2], fl
mywait()
R_Use_base("luslf")
index on str(grp, 1)+shifr to (cur_dir + "tmp_uslf")
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
// add_string("2020 год")
add_string(str(WORK_YEAR, 4, 0) + ' год')
add_string(center("Номенклатура стоматологических услуг Минздрава РФ (ФФОМС)", sh))
add_string("")
for j := 1 to len(arr_gr)
  fl := .t.
  find (str(j, 1))
  do while luslf->grp == j .and. !eof()
    s := alltrim(luslf->shifr)+" "+rtrim(luslf->name)
    if luslf->zf == 1
     s += " [ЗФ]"
    endif
    k := perenos(t_arr,s, sh-12)
    if fl
      verify_FF(HH-k-3, .t., sh)
      add_string(replicate("=", sh))
      add_string(center(arr_gr[j], sh))
      add_string(replicate("=", sh))
      fl := .f.
    endif
    verify_FF(HH-k, .t., sh)
    add_string(padr(t_arr[1], sh-12)+ put_val_0(luslf->uetv, 6, 2)+ put_val_0(luslf->uetd, 6, 2))
    for i := 2 to k
      add_string(padl(alltrim(t_arr[i]), sh-12))
    next
    skip
  enddo
next
close databases
rest_box(buf)
fclose(fp)
viewtext(name_file,,,, .t.,,, 2)
return NIL

// 24.05.23 Распечатка списка услуг с использованием телемедицинских технологий
Function usl_telemedicina()
  Local i, j, k, buf := save_maxrow(), name_file := cur_dir + 'uslugiT' + stxt, sh := 80, HH := 60, t_arr[2], fl

  mywait()
  R_Use_base('luslf')
  index on shifr to (cur_dir + 'tmp_uslf') for telemed == 1
  fp := fcreate(name_file)
  n_list := 1
  tek_stroke := 0
  add_string(str(WORK_YEAR, 4, 0) + ' год')
  add_string(center('Услуги с использованием телемедицинских технологий Минздрава РФ (ФФОМС)', sh))
  add_string('')
  go top
  do while !eof()
    // k := perenos(t_arr, alltrim(luslf->shifr) + ' ' + luslf->name, sh)
    k := perenos(t_arr, padr(luslf->shifr, 15) + ' ' + luslf->name, sh)
    verify_FF(HH - k, .t., sh)
    add_string(t_arr[1])
    for i := 2 to k
      add_string(padl(alltrim(t_arr[i]), sh))
    next
    skip
  enddo
  close databases
  rest_box(buf)
  fclose(fp)
  viewtext(name_file, , , , .t., , , 2)
  return nil

// 28.03.23 Распечатка списка операций на парных органах
Function usl_par_organ()
  Local i, j, k, buf := save_maxrow(), name_file := cur_dir + 'uslugiT' + stxt, sh := 80, HH := 60, t_arr[2], fl

  mywait()
  R_Use_base('luslf')
  index on shifr to (cur_dir + 'tmp_uslf') for !empty(par_org)
  fp := fcreate(name_file)
  n_list := 1
  tek_stroke := 0
  add_string(str(WORK_YEAR, 4, 0) + ' год')
  add_string('')
  add_string('=== Описание обозначения органа (части тела)')
  for i := 1 to len(getParOrgan())
    add_string(' ' + getParOrgan()[i, 1])
  next
  add_string('===')
  add_string(center('Операции на парных органах (частях тела) Минздрава РФ (ФФОМС)', sh))
  add_string('')
  go top
  do while !eof()
    k := perenos(t_arr, alltrim(luslf->shifr) + ' (' + alltrim(luslf->par_org) + ') ' + luslf->name, sh)
    verify_FF(HH - k, .t., sh)
    add_string(t_arr[1])
    for i := 2 to k
      add_string(padl(alltrim(t_arr[i]), sh))
    next
    skip
  enddo
  close databases
  rest_box(buf)
  fclose(fp)
  viewtext(name_file, , , , .t., , , 2)
  return NIL

// 08.02.23 Вывод списка услуг диагностики при дообследовании в направлениях на ЗНО
Function usl_napr_FFOMS()
  Static arr_gr := { ;
    {'1 - лабораторная диагностика', 1}, ;
    {'2 - инструментальная диагностика', 2}, ;
    {'3 - методы лучевой диагностики, за исключением дорогостоящих', 3}, ;
    {'4 - дорогостоящие методы лучевой диагностики (КТ, МРТ, ангиография)', 4}}
  Local i, j, k, buf := save_maxrow(), name_file := cur_dir + 'uslugiON' + stxt, sh := 80, HH := 60, t_arr[2], fl, ar

  if (t_arr := bit_popup(T_ROW, T_COL - 5, arr_gr, , color0, 1, 'Метод диагностического исследования', 'B/BG')) == NIL
    return NIL
  endif
  ar := aclone(t_arr)
  mywait()
  R_Use_base('luslf')
  index on str(onko_napr, 1) + shifr to (cur_dir + 'tmp_uslf')
  fp := fcreate(name_file)
  n_list := 1
  tek_stroke := 0
  add_string(str(WORK_YEAR, 4, 0) + ' год')
  add_string(center('Номенклатура услуг диагностики при дообследовании на ЗНО МЗРФ (ФФОМС)', sh))
  add_string(center('(услуги в направлениях при подозрении на ЗНО)', sh))
  for j := 1 to len(ar)
    fl := .t.
    find (str(ar[j, 2], 1))
    do while luslf->onko_napr == ar[j, 2] .and. !eof()
      k := perenos(t_arr, alltrim(luslf->shifr) + ' ' + luslf->name, sh)
      if fl
        verify_FF(HH - k - 3, .t., sh)
        add_string(replicate('=', sh))
        add_string(center(ar[j, 1], sh))
        add_string(replicate('=', sh))
        fl := .f.
      endif
      verify_FF(HH - k, .t., sh)
      add_string(padr(t_arr[1], sh))
      for i := 2 to k
        add_string(padl(alltrim(t_arr[i]), sh))
      next
      skip
    enddo
  next
  close databases
  rest_box(buf)
  fclose(fp)
  viewtext(name_file, , , , .t., , , 2)
  return NIL

// 08.02.23 Вывод списка услуг по типам лечения ОНКОзаболеваний
Function usl_ksg_FFOMS()
  Static arr_gr := { ;
    {'1 - Хирургическое лечение', 1}, ;
    {'2 - Лекарственная противоопухолевая терапия', 2}, ;
    {'3 - Лучевая терапия', 3}, ;
    {'4 - Химиолучевая терапия', 4}, ;
    {'5 - Неспецифическое лечение (осложнения противоопухолевой терапии, установка/замена порт системы (катетера))', 5}, ;
    {'6 - Диагностика', 6}}
  Local i, j, k, buf := save_maxrow(), name_file := cur_dir + 'uslugiOK' + stxt, sh := 80, HH := 60, t_arr[2], fl, ar

  if (t_arr := bit_popup(T_ROW, T_COL - 5, arr_gr, , color0, 1, 'Тип лечения онкологических заболеваний', 'B/BG')) == NIL
    return NIL
  endif
  ar := aclone(t_arr)
  mywait()
  R_Use_base('luslf')
  index on str(onko_ksg, 1) + shifr to (cur_dir + 'tmp_uslf')
  fp := fcreate(name_file)
  n_list := 1
  tek_stroke := 0
  add_string(str(WORK_YEAR, 4, 0) + ' год')
  add_string(center('Номенклатура услуг по типам лечения ОНКОзаболеваний МЗРФ (ФФОМС)', sh))
  for j := 1 to len(ar)
    fl := .t.
    find (str(ar[j, 2], 1))
    do while luslf->onko_ksg == ar[j, 2] .and. !eof()
      k := perenos(t_arr, alltrim(luslf->shifr) + ' ' + luslf->name, sh)
      if fl
        verify_FF(HH - k - 3, .t., sh)
        add_string(replicate('=', sh))
        k := perenos(t_arr, ar[j, 1], sh)
        add_string(center(alltrim(t_arr[1]), sh))
        if k > 1
          add_string(center(alltrim(t_arr[2]), sh))
        endif
        add_string(replicate('=', sh))
        fl := .f.
        k := perenos(t_arr, alltrim(luslf->shifr) + ' ' + luslf->name, sh)
      endif
      verify_FF(HH - k, .t., sh)
      add_string(padr(t_arr[1], sh))
      for i := 2 to k
        add_string(padl(alltrim(t_arr[i]), sh))
      next
      skip
    enddo
  next
  close databases
  rest_box(buf)
  fclose(fp)
  viewtext(name_file, , , , .t., , , 2)
  return NIL

// 08.02.23
Function usl1FFOMS()
  Static su := 'A01', suA := '01', suB := '001'
  Local k, buf := save_maxrow(), name_file := cur_dir + 'uslugiF' + stxt, arr[2], ;
      sh := 80, HH := 60, t_arr[2], t_aA[2], t_aB[2], i, n, s, fl := .f.

  if !empty(popup_2array(usl3FFOMS(), T_ROW, T_COL - 5, su, 1, @t_arr, ;
          'Выберите раздел номенклатуры медицинских услуг', 'B/W', color5))
    su := t_arr[2]
    s := su + '.'
    n := 4
    if left(su, 1) == 'A'
      if (i := popup_prompt(T_ROW, T_COL - 5, 2, ;
          {'В целом по разделу', 'По одной анатомо-функциональной области'})) == 0
        return NIL
      elseif i == 1
        fl := .t.
      elseif ! empty(popup_2array(usl4FFOMS(), T_ROW, T_COL - 5, suA, 1, @t_aA, ;
                'Выберите анатомо-функциональную область', 'B/BG', color0))
        suA := t_aA[2]
        fl := .t.
        s += suA + '.'
        n := 7
      endif
    else
      if (i := popup_prompt(T_ROW, T_COL - 5, 1, ;
            {'В целом по разделу', 'По одной медицинской специальности'})) == 0
        return NIL
      elseif i == 1
        fl := .t.
      elseif ! empty(popup_2array(usl5FFOMS(), T_ROW, T_COL - 5, suB, 1, @t_aB, ;
               'Выберите медицинскую специальность', 'B/BG', color0))
        suB := t_aB[2]
        fl := .t.
        s += suB + '.'
        n := 8
      endif
    endif
  endif
  if fl
    mywait()
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    add_string('')
    add_string(center('Раздел номенклатуры медицинских услуг ФФОМС:', sh))
    for i := 1 to perenos(arr, '"' + t_arr[1] + '"', sh)
      add_string(center(alltrim(arr[i]), sh))
    next
    if n > 4
      if left(su, 1) == 'A'
        add_string(center('Анатомо-функциональная область:', sh))
        for i := 1 to perenos(arr, '"' + t_aA[1] + '"', sh)
          add_string(center(alltrim(arr[i]), sh))
        next
      else
        add_string(center('Медицинская специальность', sh))
        for i := 1 to perenos(arr, t_aB[1], sh)
          add_string(center(alltrim(arr[i]), sh))
        next
      endif
    endif
    add_string('')
    use_base('luslf')
    find (s)
    do while s == left(luslf->shifr, n) .and. !eof()
      k := perenos(t_arr, luslf->name, 65)
      verify_FF(HH - k + 1, .t., sh)
      add_string(luslf->shifr + t_arr[1])
      for i := 2 to k
        add_string(space(20) + t_arr[i])
      next
      skip
    enddo
    close databases
    rest_box(buf)
    fclose(fp)
    viewtext(name_file, , , , .t., , , 2)
  endif
  return NIL

// 27.05.23
Function usl2FFOMS()
  Local i, k, buf := save_maxrow(), name_file := cur_dir + 'uslugiF' + stxt, sh := 85, HH := 80, mas1[5]
  //
  mywait()
  arr_title := { ;
    '───────────────────┬─────────┬───────────────────────────────────────────────────────', ;
    ' Шифр ФФОМС        │ Шифр МО │ Наименование услуги                                   ', ;
    '───────────────────┴─────────┴───────────────────────────────────────────────────────'}
  fp := fcreate(name_file)
  n_list := 1
  tek_stroke := 0
  add_string(center('Список услуг ФФОМС в нашем справочнике', sh))
  add_string('')
  aeval(arr_title, {|x| add_string(x) } )
  use_base('luslf')
  R_Use(dir_server + 'mo_su', dir_server + 'mo_sush1', 'MOSU')
  go top
  do while !eof()
    k := 1
    afill(mas1, '')
    if mosu->tip == 5 .and. LUSLF18->(used())
      select LUSLF18
      find (mosu->shifr1)
      if found()
        k := perenos(mas1, '...удалена...' + luslf18->name, 55)
      endif
    else
      select LUSLF
      find (mosu->shifr1)
      if found()
        k := perenos(mas1, luslf->name, 55)
      elseif  LUSLF18->(used())
        select LUSLF18
        find (mosu->shifr1)
        if found()
          k := perenos(mas1, '...удалена...' + luslf18->name, 55)
        endif
      endif
    endif
    if verify_FF(HH - k + 1, .t., sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(mosu->shifr1 + mosu->shifr + mas1[1])
    for i := 2 to k
      add_string(space(30) + mas1[i])
    next
    select MOSU
    skip
  enddo
  close databases
  rest_box(buf)
  fclose(fp)
  viewtext(name_file, , , , .t., , , 5)
  return NIL

// 08.02.23
Function usl6FFOMS(lksg)
  Local k, buf := save_maxrow(), name_file := cur_dir + 'usl_ksg' + stxt, nu, sh := 80, HH := 78, ;
      t_arr, i, s, fl, v1, v2, mdate, fl1uslc, fl2uslc, ta[2], fl1del, fl2del, ret_arr
  local sbase

  glob_otd_dep := 0
  if is_otd_dep .and. lksg == 1 .and. (ret_arr := ret_otd_dep()) == NIL
    return NIL
  endif
  mywait()
  dbcreate(cur_dir + 'tmp', { ;
    {'SHIFR',      'C',     10,      0}, ;
    {'NAME',       'C',    255,      0}, ;
    {'CENA_V',     'C',     10,      0}, ;
    {'CENA_D',     'C',     10,      0}})
  use (cur_dir + 'tmp') new
  dbcreate(cur_dir + "tmp1",{ ;
    {'SHIFR',      'C',     10,      0}, ;
    {'SHIFR1',     'C',     20,      0}})
  use (cur_dir + 'tmp1') new
  index on shifr1+shifr to (cur_dir + 'tmp1')
  mdate := sys_date

  sbase := prefixFileRefName(WORK_YEAR) + 'k006'
  R_Use(exe_dir + sbase, , 'K006')
  index on SHIFR + SY to (cur_dir + 'tmp_t009')
  use_base('luslc')
  use_base('lusl')
  index on fsort_usl(shifr) to (cur_dir + 'tmp_lusl') for is_ksg(shifr, lksg) .and. datebeg >= boy(mdate)
  go top
  do while !eof()
    v1 := fcena_oms(lusl->shifr, .t., mdate, @fl1del, @fl1uslc)
    v2 := fcena_oms(lusl->shifr, .f., mdate, @fl2del, @fl2uslc)
    if !(fl1del .and. fl2del)
      select TMP
      append blank
      tmp->SHIFR  := lusl->shifr
      tmp->NAME   := alltrim(lusl->name)
      tmp->CENA_V := iif(fl1del, '      -   ', str(v1, 10, 2))
      tmp->CENA_D := iif(fl2del, '      -   ', str(v2, 10, 2))
      select K006
      find (padr(lusl->shifr, 10))
      do while (padr(lusl->shifr, 10)) == k006->shifr .and. !eof()
        if !empty(k006->sy)
          select TMP1
          find (padr(k006->sy, 20) + padr(lusl->shifr, 10))
          if !found()
            append blank
            tmp1->SHIFR  := lusl->shifr
            tmp1->SHIFR1 := k006->sy
          endif
        endif
        select K006
        skip
      enddo
    endif
    select LUSL
    skip
  enddo
  delFRfiles()
  dbcreate(fr_titl, { ;
    {'mo',    'C', 90, 0}, ;
    {'str1',  'C', 90, 0}, ;
    {'str2',  'C', 90, 0};
  })
  use (fr_titl) new alias FRT
  append blank
  frt->mo := glob_mo[_MO_SHORT_NAME] + iif(valtype(ret_arr) == 'A', ' (' + ret_arr[1] + ')', '')
  fp := fcreate(name_file)
  n_list := 1
  tek_stroke := 0
  add_string(glob_mo[_MO_SHORT_NAME] + iif(valtype(ret_arr) == 'A', ' (' + ret_arr[1] + ')', ''))
  add_string('')
  s := 'Услуги ФФОМС + КСГ в ' + iif(lksg == 1, 'стационаре', 'дневном стационаре')
  frt->str1 := s
  add_string(center(s, sh))
  s := '[ цены по состоянию на ' + date_8(mdate) + 'г. ]'
  frt->str2 := s
  add_string(center(s, sh))
  add_string('')
  dbcreate(fr_data, {{'SHIFR1',  'C', 20, 0}, ;
                      {'NAME',    'C', 255, 0}})
  use (fr_data) new alias _d
  //
  dbcreate(fr_data + '1', {{'SHIFR1', 'C', 20, 0}, ;
                            {'SHIFR', 'C', 10, 0}, ;
                            {'NAME',  'C', 255, 0}, ;
                            {'CENA_V','C', 10, 0}, ;
                            {'CENA_D','C', 10, 0}})
  use (fr_data + '1') new alias _d1
  use_base('luslf')
  old_shifr := space(20)
  select TMP
  index on shifr to (cur_dir + 'tmp')
  select TMP1
  go top
  do while !eof()
    if !(old_shifr == tmp1->shifr1)
      add_string(replicate('─', sh))
      select LUSLF
      find (tmp1->shifr1)
      k := perenos(ta, luslf->name, sh - 15)
      for i := 1 to k
        verify_FF(HH, .t., sh)
        add_string(iif(i == 1, tmp1->shifr1, space(20)) + ta[i])
      next
      add_string(replicate('-', sh))
      select _D
      append blank
      _d->shifr1 := tmp1->shifr1
      _d->name := luslf->name
    endif
    old_shifr := tmp1->shifr1
    select TMP
    find (tmp1->shifr)
    k := perenos(ta, alltrim(tmp->name), 45)
    for i := 1 to k
      verify_FF(HH, .t., sh)
      add_string(iif(i == 1, padl(alltrim(tmp->shifr), 19) + ' ', space(20)) + ta[i] + ;
                  iif(i == 1, tmp->cena_v + tmp->cena_d, ''))
    next
    select _D1
    append blank
    _d1->shifr1 := tmp1->shifr1
    _d1->shifr := tmp->shifr
    _d1->name := tmp->name
    _d1->cena_v := tmp->cena_v
    _d1->cena_d := tmp->cena_d
    select TMP1
    skip
  enddo
  select _d1
  index on shifr1 + shifr to (fr_data + '1')
  close databases
  rest_box(buf)
  fclose(fp)
  name_fr := 'mo_v1ksg' + sfr3
  if _upr_epson() .or. ! file(dir_exe + name_fr)
    viewtext(name_file, , , , .t., , , 5)
  else
    call_fr(name_fr, , , {|| FrPrn:SetMasterDetail('_data', '_data1', {|| _data->shifr1 })})
  endif
  return NIL

// 25.01.23
Function usl11FFOMS()
  Local buf := save_maxrow(), name_file := cur_dir + 'vidVMP' + stxt, sh := 80, HH := 60, t_arr[2], i, j, k
  local arrV018 := getV018(boy())

  mywait()

  fp := fcreate(name_file)
  n_list := 1
  tek_stroke := 0
  add_string('')
  add_string(center('Классификатор видов ВМП', sh))
  add_string('')
  for j := 1 to len(arrV018)
    k := perenos(t_arr, arrV018[j, 2], 67)
    verify_FF(HH - k + 1, .t., sh)
    add_string(padr(arrV018[j, 1], 13) + t_arr[1])
    for i := 2 to k
      add_string(space(13) + t_arr[i])
    next
  next
  rest_box(buf)
  fclose(fp)
  viewtext(name_file, , , , .t., , , 2)
  return NIL

// 25.01.23
Function usl12FFOMS()
  Static sast, sarr
  Local buf := save_maxrow(), name_file := cur_dir + 'metodVMP' + stxt, sh := 80, HH := 60, t_arr[2], a, i, j, k, n, s
  local arrV018 := getV018(boy())
  local arrV019 := getV019(boy())

  if sast == NIL
    sast := {}
    sarr := {}
    for j := 1 to len(arrV018)
      aadd(sast, .t.)
      aadd(sarr, {padr(arrV018[j, 1], 13) + left(arrV018[j, 2], 67), arrV018[j, 1]})
    next
  endif
  if (a := bit_popup(T_ROW, T_COL - 5, sarr, sast)) != NIL
    afill(sast, .f.)
    for i := 1 to len(a)
      if (j := ascan(sarr, {|x| x[2]==a[i, 2] })) > 0
        sast[j] := .t.
      endif
    next
    mywait()
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    add_string('')
    add_string(center('Классификатор методов ВМП', sh))
    add_string('')
    for n := 1 to len(a)
      if (j := ascan(arrV018, {|x| x[1] == a[n, 2] })) > 0
        k := perenos(t_arr, arrV018[j, 2], 67)
        verify_FF(HH - k + 3, .t., sh)
        add_string(replicate('-', sh))
        add_string(padr(arrV018[j, 1], 13) + t_arr[1])
        for i := 2 to k
          add_string(space(13) + t_arr[i])
        next
        add_string(replicate('-', sh))
        for l := 1 to len(arrV019)
          if arrV019[l, 4] == arrV018[j, 1]
            s := arrV019[l, 2] + ' (диагноз' + iif(len(arrV019[l, 3]) > 1, 'ы', '') + ;
               ' ' + print_array(arrV019[l, 3]) + ')'
            k := perenos(t_arr, s, 66)
            verify_FF(HH - k + 1, .t., sh)
            add_string(str(arrV019[l, 1], 13) + ' ' + t_arr[1])
            for i := 2 to k
              add_string(space(14) + t_arr[i])
            next
          endif
        next
      endif
    next
    rest_box(buf)
    fclose(fp)
    viewtext(name_file, , , , .t., , , 2)
  endif
  return NIL

//
Function spr_other()
Local mas_pmt, mas_msg, mas_fun, j, r, c := T_COL-5
mas_pmt := {"~Прочие организации", ;
            "~Комитеты (МО)", ;
            "~Службы", ;
            "~Услуги без службы";
           }
mas_msg := {"Прочие организации", ;
            "Комитеты по здравоохранению (МО)", ;
            "Список служб с возможностью распечатки услуг по конкретной службе", ;
            "Распечатка услуг, у которых не проставлена служба";
           }
mas_fun := {"f1spr_other(1)", ;
            "f1spr_other(2)", ;
            "f1spr_other(3)", ;
            "f1spr_other(4)"}
if (r := T_ROW-len(mas_pmt)-3) < 0
  r := 2 ; c := T_COL+10
endif
popup_prompt(r,c, 1,mas_pmt,mas_msg,mas_fun)
return NIL

//
Function f1spr_other(k)
Local buf := save_maxrow(), mas1 := {}, mas2
do case
  case k == 1
    popup_edit(dir_server + "str_komp",T_ROW,T_COL-5,T_ROW+8,,PE_VIEW,,,,{||!between(tfoms, 44, 47)})
  case k == 2
    popup_edit(dir_server + "komitet",T_ROW,T_COL-5,T_ROW+8,,PE_VIEW)
  case k == 3
    if R_Use(dir_server + "slugba", dir_server + "slugba","SL")
      go top
      do while Alpha_Browse(T_ROW,T_COL-5,maxrow()-2,T_COL+45,"f2spr_other",color0)
        f3spr_other(1)
      enddo
    endif
  case k == 4
    f3spr_other(2)
endcase
close databases
rest_box(buf)
return NIL

//
Function f2spr_other(oBrow)
oBrow:addColumn(TBColumnNew("Шифр", {|| sl->shifr }) )
oBrow:addColumn(TBColumnNew(center("Наименование службы", 40), {|| sl->name }) )
status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор службы")
return NIL

// 08.02.23
Function f3spr_other(reg)
  Local buf := save_maxrow(), n_file := cur_dir + 'uslugi' + stxt, ;
    sh := 80, HH := 60, l, k, mas[2]

mywait()
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
if mem_trudoem == 2
  Private arr_title := {space(sh-15)+"УЕТ "+iif(is_oplata==7,"вр.","взр")+"│УЕТ "+iif(is_oplata==7,"асс","дет"), ;
                        space(sh-15)+"───────┴───────"}
  useUch_Usl()
  l := sh-16
else
  l := sh
endif
Use_base('lusl')
Use_base('luslc')
R_Use(dir_server + 'uslugi', dir_server + "uslugisl", 'USL')
if reg == 1
  add_string(CENTER("Список услуг по службе:", 80))
  add_string(CENTER(lstr(sl->shifr)+". "+ alltrim(sl->name), 80))
  find (str(sl->shifr, 3))
  index on fsort_usl(shifr) to (cur_dir + "tmp") for kod > 0 while slugba == sl->shifr
else
  add_string(CENTER("Список услуг с непроставленной службой", 80))
  index on fsort_usl(shifr) to (cur_dir + "tmp") for f5spr_other()
endif
add_string("")
if mem_trudoem == 2
  aeval(arr_title, {|x| add_string(x) } )
endif
go top
do while !eof()
  lshifr := ""
  if !empty(usl->shifr)
    s := usl->shifr
    lshifr += alltrim(usl->shifr)
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod)
    if !empty(lshifr1) .and. !(usl->shifr==lshifr1)
      s := lshifr1
      lshifr += "("+ alltrim(lshifr1)+")"
    endif
    lshifr += "."
    s := f42_uslugi(1,s)
    s1 := f42_uslugi(23)
    if !emptyall(s,s1) .or. usl->is_nul
      if mem_trudoem == 2
        if verify_FF(HH, .t., sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
      else
        verify_FF(HH, .t., sh)
      endif
      if empty(s)
        s := s1
      elseif !empty(s1)
        s += ";"+s1
      endif
      k := perenos(mas,lshifr+ alltrim(usl->name)+" ["+s+"]",l," , ;")
      s := padr(mas[1],l)
      if mem_trudoem == 2
        select UU
        find (str(usl->kod, 4))
        if is_oplata == 7
          s += put_val_0(uu->vkoef_v, 8, 4)+ put_val_0(uu->akoef_v, 8, 4)
        else
          s += put_val_0(uu->koef_v, 8, 4)+ put_val_0(uu->koef_r, 8, 4)
        endif
      endif
      add_string(s)
      if k > 1
        add_string(padl(alltrim(mas[2]),l))
      endif
    endif
  endif
  select USL
  skip
enddo

close_use_base('lusl')
close_use_base('luslc')

usl->(dbCloseArea())
if mem_trudoem == 2
  uu->(dbCloseArea())
  uu1->(dbCloseArea())
endif
if reg == 1
  select SL
endif
fclose(fp)
viewtext(n_file,,,,,,, 2)
rest_box(buf)
return NIL

//
Function f5spr_other()
Local fl := !empty(shifr)
if fl
  fl := is_nul .or. !emptyall(cena,cena_d)
endif
if fl
  fl := (slugba <= 0)
endif
return fl

//* 07.03.21
// список персонала
Function spr_personal()
Local k, sh := 80, HH := 57, fl := .t., s
mywait()
fp := fcreate("spisok"+stxt) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("Списочный состав персонала с табельными номерами", sh))
add_string("")
add_string(center(alltrim(glob_uch[2])+" ("+ alltrim(glob_otd[2])+")", sh))
add_string(padl(date_8(sys_date)+"г.", sh))
if R_Use(dir_server + "mo_pers",,"PERSO")
  index on upper(fio) to (cur_dir + "tmp_pers") for kod > 0
  do while !eof()
    if fl .or. tek_stroke > HH
      if !fl
        add_string(chr(12))
        tek_stroke := 0
        n_list++
        next_list(sh)
      endif
      add_string("─────┬──────────────────────────────────────────────────┬──────────────────────")
      add_string("Таб.№│                       Ф.И.О.                     │ Специальность        ")
      add_string("─────┴──────────────────────────────────────────────────┴──────────────────────")
    endif
    fl := .f.
    s := put_val(perso->tab_nom, 5)+;
         iif(empty(perso->svod_nom), space(5), padl("("+lstr(perso->svod_nom)+")", 5))+;
         " "+padr(alltrim(perso->fio), 45)
    if !emptyall(perso->prvs,perso->prvs_new)
      s += " "+ret_tmp_prvs(perso->prvs,perso->prvs_new)
    endif
    add_string(s)
    select PERSO
    skip
  enddo
endif
close databases
fclose(fp)
viewtext("spisok"+stxt,,,,,,, 2)
return NIL


// список отделений с кодами
Function spr_kod_otd()
Local sh := 64, HH := 57, buf := save_maxrow(), n_file := cur_dir + "kod_otd" + stxt
mywait()
Private t_arr := {}, count_uch := 0
R_Use(dir_server + 'mo_uch',,"UCH")
dbeval({|| count_uch++, aadd(t_arr,{kod,alltrim(name)}) } )
if count_uch == 0
  func_error(4,"База учреждений пуста!")
else
  R_Use(dir_server + 'mo_otd',, 'OTD')
  index on str(kod_lpu, 3)+upper(name) to (cur_dir + "tmp_otd") for !empty(name)
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string("")
  add_string(center(expand("КОДЫ ОТДЕЛЕНИЙ"), sh))
  add_string("")
  select UCH
  index on upper(name) to (cur_dir + "tmp_uch") for !empty(name)
  go top
  do while !eof()
    add_string("")
    add_string(upper(uch->name))
    select OTD
    find (str(uch->kod, 3))
    do while otd->kod_lpu == uch->kod .and. !eof()
      add_string(str(otd->kod, 14)+"   "+otd->name)
      select OTD
      skip
    enddo
    select UCH
    skip
  enddo
endif
close databases
fclose(fp)
rest_box(buf)
viewtext(n_file)
return NIL


// просмотр/печать справочника диагнозов
Function spr_info_diagn(k)
Static sk := 1
Local str_sem, mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"~Болезни МКБ-10", ;
                "~Группы (классы)", ;
                "~Подгруппы", ;
                "Пе~чать по группам", ;
                "Печ~ать по подгруппам"}
    mas_msg := {"Просмотр справочника МКБ-10 (поиск по шифру или наименованию)", ;
                "Просмотр справочника групп диагнозов (классов)", ;
                "Просмотр справочника подгрупп диагнозов", ;
                "Печать справочника МКБ-10 по группам", ;
                "Печать справочника МКБ-10 по подгруппам"}
    mas_fun := {"spr_info_diagn(1)", ;
                "spr_info_diagn(2)", ;
                "spr_info_diagn(3)", ;
                "spr_info_diagn(4)", ;
                "spr_info_diagn(5)"}
    popup_prompt(T_ROW, T_COL-5, sk, mas_pmt, mas_msg, mas_fun)
  case k > 0
    f_10diag(k)
endcase
if k > 0
  sk := k
endif
return NIL


// 05.04.20
Function f_10diag(k)
Local buf := savescreen(), i := 1, c1 := 1, c2 := 77, msh_b, msh_e, arr_t, s, s1
Private pregim := k, uregim := 1
change_attr()
do case
  case k == 1
    mywait()
    R_Use(dir_exe+"_mo_mkb", cur_dir + "_mo_mkb","DIAG")
    go top
    Alpha_Browse(2,c1,maxrow()-2,c2,"f1_10diag",color0,,, .t.,,,,"f2_10diag",,{,,,"N/BG,W+/N,B/BG,BG+/B,GR/BG,BG+/GR", .t.} )
  case k == 2
    R_Use(dir_exe+"_mo_mkbk")
    index on sh_b+str(ks, 1) to (cur_dir + "tmp")
    go top
    Alpha_Browse(2, 0,maxrow()-2, 79,"f1_10diag",color0,,, .t.,,,,,,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B"})
  case k == 3
    R_Use(dir_exe+"_mo_mkbg")
    index on sh_b+str(ks, 1) to (cur_dir + "tmp")
    go top
    Alpha_Browse(2,c1,maxrow()-2,c2,"f1_10diag",color0,,, .t.,,,,,,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B"})
  case k == 4 .or. k == 5
    R_Use(dir_exe+"_mo_mkb"+iif(pregim==4,"k","g"))
    index on sh_b+str(ks, 1) to (cur_dir + "tmp_d")
    Use
    do while .t.
      R_Use(dir_exe+"_mo_mkb"+iif(pregim==4,"k","g"))
      set index to "tmp_d"
      goto (i)
      if pregim == 4
        c1 := 0 ; c2 := 79
      endif
      if Alpha_Browse(2,c1,maxrow()-2,c2,"f1_10diag",color0,,, .t.,,,,,,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B"})
        mywait()
        arr_t := {}
        do while ks > 0
          skip -1
        enddo
        i := recno()
        if pregim == 4
          aadd(arr_t, "Класс "+ alltrim(klass))
        endif
        msh_b := sh_b ; msh_e := sh_e
        do while sh_e == msh_e
          aadd(arr_t, alltrim(name))
          skip
        enddo
        Use
        if msh_b == msh_e
          aadd(arr_t, "( "+ alltrim(msh_b)+" )")
        else
          aadd(arr_t, "( "+ alltrim(msh_b)+" - "+ alltrim(msh_e)+" )")
        endif
        Private sh := 76, HH := 77
        fp := fcreate("diagtmp.txt") ; n_list := 1 ; tek_stroke := 0
        add_string("")
        R_Use(dir_exe+"_mo_mkb", cur_dir + "_mo_mkb","DIAG")
        for k := 1 to len(arr_t)
          add_string(center(arr_t[k], sh))
        next
        add_string("")
        add_string(center('[ знаком "-" перед шифром отмечены диагнозы, не входящие в ОМС ]', sh))
        add_string("")
        dbseek(padr(msh_b, 5), .t.)
        do while left(shifr, 3) <= msh_e .and. !eof()
          if ks == 0
            verify_FF(HH, .t., sh)
          endif
          if !("." $ shifr) .and. ks == 0
            add_string("")
          endif
          s1 := iif(ks==0 .and. !empty(diag->pol),iif(diag->pol=="М","<муж.>","<жен.>"), space(6))
          s := iif("." $ shifr, s1, "")
          s += iif(ks==0 .and. !between_date(diag->dbegin,diag->dend) , "-", " ")
          s += padr(if(ks == 0, shifr, ""), 6)
          s += " "+rtrim(name)
          add_string(s)
          skip
        enddo
        close databases
        fclose(fp)
        viewtext("diagtmp.txt",,,,,,, 5)
      else
        exit
      endif
    enddo
endcase
close databases
restscreen(buf)
return NIL

// 13.04.21
Function f1_10diag(oBrow)
Local oColumn, blk, n := 65
if pregim == 1
  blk := {|| iif(!between_date(diag->dbegin,diag->dend,,, .t.), {3, 4}, iif(!empty(diag->pol), {5, 6}, {1, 2})) }
  oColumn := TBColumnNew("Шифр",{|| padr(if(ks==0,shifr+diag->pol,""), 7) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(center("Наименование диагнозов заболеваний",n),{||name})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  if uregim > 0
    status_key("^<Esc>^ - выход;  ^<F2>^ - поиск по шифру;  ^<F3>^ - поиск по подстроке"+;
                              iif(uregim==1,"",";  ^<Enter>^ - выбор"))
  endif
else
  if equalany(pregim, 2, 4)
    oColumn := TBColumnNew("Класс",{||if(ks==0,klass,"    ")})
    oColumn:colorBlock := blk
    oBrow:addColumn(oColumn)
    n := 64
  endif
  oColumn := TBColumnNew("",{||if(ks==0,sh_b,"    ")})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("",{||if(ks==0,sh_e,"    ")})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(center("Наименование "+;
       iif(pregim==2.or.pregim==4,"","под")+"группы заболеваний",n),{||left(name,n)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  if uregim > 0
    if equalany(pregim, 4, 5)
      status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор "+iif(pregim==4,"","под")+"группы для печати")
    else
      status_key("^^ - просмотр;  ^<Esc>^ - выход"+iif(uregim==1,"",";  ^<Enter>^ - выбор"))
    endif
  endif
endif
return NIL

//
Function f2_10diag(nKey,oBrow)
Static sshifr := "     ", sname := ""
Local buf, buf24, fl := .f., s, rec, k := -1, bg := {|o,k| get_MKB10(o,k) }
do case
  case nKey == K_F2
    buf := save_box(18, 0, 24, 79)
    Private mshifr := sshifr
    box_shadow(18, 20, 20, 59,color8)
    @ 19, 32 say "Введите шифр" color color1 ;
                get mshifr PICTURE "@K@!" ;
                reader {|o| MyGetReader(o,bg) } ;
                valid val1_10diag(.f.) color color1
    status_key("^<Esc>^ - отказ от ввода;  ^<Enter>^ - подтверждение ввода")
    myread({"confirm"})
    if lastkey() != K_ESC .and. !empty(mshifr)
      rec := recno()
      find (rtrim(mshifr))
      if found()
        sshifr := mshifr
        k := 0
      else
        goto rec
        func_error(4,"Диагноз с таким шифром не найден!")
      endif
    endif
    rest_box(buf)
    if k == 0
      oBrow:goTop()
      find (rtrim(mshifr))
    endif
  case nKey == K_F3
    Private mname := padr(alltrim(sname), 30)
    if (mname := input_value(18, 4, 20, 75,color8, ;
                  "Введите подстроку диагноза для поиска", ;
                  mname,"@K@!")) != NIL .and. !empty(mname)
      mname := alltrim(mname)
      rec := recno()
      //
      Private i := j := 0, lshifr := "", lname := "", ;
              tmp_mas := {}, tmp_kod := {}, t_len
      hGauge := GaugeNew(,,{color8,color1,"G+/B"},"Поиск подстроки <."+mname+".>", .t.)
      GaugeDisplay( hGauge )
      buf24 := save_maxrow()
      s := "^<Esc>^ - прервать поиск"
      status_key(s) ; s += ".   Найдено диагнозов -"
      go top
      do while !eof()
        GaugeUpdate( hGauge, ++j/lastrec() )
        if inkey() == K_ESC
          exit
        endif
        if FIELD->ks == 0
          if !empty(lname) // проверить предыдущую запись
            if mname $ upper(lname)
              if ++i > 4000 ; exit ; endif
              aadd(tmp_mas, lshifr+" "+lname)
              aadd(tmp_kod, lshifr)
              status_key(s+"^ "+lstr(i)+".^")
            endif
          endif
          lshifr := FIElD->shifr ; lname := ""
        endif
        lname += alltrim(FIELD->name)+" "
        skip
      enddo
      if !empty(lname) .and. mname $ upper(lname)
        aadd(tmp_mas, lshifr+" "+lname)
        aadd(tmp_kod, lshifr)
      endif
      CloseGauge(hGauge)
      goto rec
      rest_box(buf24)
      //
      if (t_len := len(tmp_kod)) = 0
        func_error(3,"Неудачный поиск!")
      else
        sname := mname
        Private r1 := 2, c1 := 1, r2 := maxrow()-2, c2 := 77
        Private k1 := r1+3, k2 := r2-1
        buf := box_shadow(r1,c1,r2,c2,color0)
        buf24 := save_maxrow()
        @ r1+1,c1+1 say "Подстрока: "+mname color "B/BG"
        SETCOLOR(color0)
        if t_len < k2-k1-1
          k2 := k1 + t_len + 2
        endif
        @ k1,c1+1 say padc("Кол-во найденных строк - "+lstr(t_len),c2-c1-1)
        i := ascan(tmp_kod, sshifr)
        status_key("^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор;  ^<F9>^ - печать")
        if (i := popup(k1+1,c1+1,k2,c2-1,tmp_mas,i,color0, .t.,"f3_10diag")) > 0
          sshifr := tmp_kod[i]
          k := 0
        endif
        rest_box(buf)
        rest_box(buf24)
      endif
      //
    endif
    if k == 0
      oBrow:goTop()
      find (sshifr)
    endif
endcase
return k

//
Function f3_10diag(nKey,nInd)
Local rec, i
if nKey == K_F9
  rec := recno()
  Private sh := 76, HH := 77
  fp := fcreate("diagtmp.txt") ; n_list := 1 ; tek_stroke := 0
  add_string("")
  add_string(center("Результат поиска по подстроке: "+mname, sh))
  add_string("")
  for i := 1 to len(parr)
    find (left(parr[i], 6))
    do while shifr == left(parr[i], 6) .and. !eof()
      if ks == 0
        verify_FF(HH, .t., sh)
      endif
      s := padr(if(ks == 0, shifr, ""), 7)
      s += " "+rtrim(name)
      add_string(s)
      skip
    enddo
  next
  fclose(fp)
  viewtext("diagtmp.txt",,,,,,, 5)
  goto (rec)
endif
return -1


//
Function f10_diagnoz()
Static srec
Local buf := savescreen(), c1 := 1, c2 := 77, tmp_select := select()
Private pregim := 1, uregim := 1
change_attr()
mywait()
R_Use(dir_exe+"_mo_mkb", cur_dir + "_mo_mkb","DIAG")
go top
if srec != NIL
  goto (srec)
endif
Alpha_Browse(2,c1,maxrow()-2,c2,"f1_10diag",color0,,, .t.,,,,"f2_10diag",,{,,,"N/BG,W+/N,B/BG,BG+/B", .t.} )
srec := diag->(recno())
diag->(dbCloseArea())
restscreen(buf)
if tmp_select > 0
  select (tmp_select)
endif
return NIL


//
Function diag_to_num(lshifr,j)
Local s, c5, c6, i, l, lnum := 0
lshifr := alltrim(lshifr)
if (l := len(lshifr)) > 0
  c5 := c6 := {"0","9"}[j]  // на конце 0 - для начала интервала, 9 - для конца
  if l > 3
    if l >= 5
      c5 := substr(lshifr, 5, 1)
    endif
    if l == 6
      c6 := right(lshifr, 1)
    endif
    // на всякий случай
    lshifr := padr(lshifr, 3,"0") ; l := 3
  endif
  lshifr += c5+c6 ; l := len(lshifr)
  // первый символ буква, остальные - цифры
  s := lstr(asc(left(lshifr, 1)))
  for i := 2 to l
    s += substr(lshifr,i, 1)
  next
  lnum := int(val(s))
endif
return lnum

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
Public public_date := ctod("") // датa, по которую (включительно) запрещено редактировать данные
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
Public mem_date_1  := ctod("")
Public mem_date_2  := ctod("")
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
Public mem_edit_s  := 2
// для задачи "Ортопедия"
Public mem_ort_na  := space(10) // ортопедия
Public mem_ort_sl  := space(10) // ортопедия
Public mem_ort_ysl := 1     // нет // ортопедия
Public mem_ortotd  := 0            // ортопедия
Public mem_ortot1  := 1            // ортопедия
Public mem_ort_ms  := 2     // да  // ортопедия
Public mem_ort_bp  := "ZAKAZ_BP.SMY"// ортопедия
Public mem_ort_pl  := "ZAKAZ_PL.SMY"// ортопедия
Public mem_ort_dat := 1             // ортопедия
Public mem_ort_f8  := "LIST_U_8.SHB" // ортопедия
Public mem_ortfflu := 1              // ортопедия
Public mem_ort_dog := space(3)   // расширение догов. ортопедии
Public mem_ort_f39 := 0  // работать с формой 39

Public MUSIC_ON_OFF := (mem_sound == 2)

if (j := search_file("lpu"+sini, 2)) != NIL
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
  i := GetIniVar( j, {{"kassa","delta_chek",}} )
  if i[1] != NIL
    delta_chek := int(val(i[1]))
  endif
endif
//
if (j := search_file("lpu_stom"+sini)) != NIL
  k := GetIniSect( j, "Категория" )
  if !empty(k)
    stm_kategor2 := {}
    for i := 1 to len(k)
      aadd(stm_kategor2, { k[i, 1], int(val(k[i, 2])) } )
    next
  endif
  k := GetIniSect( j, "Повод" )
  if !empty(k)
    stm_povod := {}
    for i := 1 to len(k)
      aadd(stm_povod, { k[i, 1], int(val(k[i, 2])) } )
    next
  endif
  k := GetIniSect( j, "Травма" )
  if !empty(k)
    stm_travma := {}
    for i := 1 to len(k)
      aadd(stm_travma, { k[i, 1], int(val(k[i, 2])) } )
    next
  endif
endif
//
Public dlo_version := 4
Public is_r_mu := .f.
Public gpath_reg := "" // путь к файлам R_MU.DBF
return NIL

// 11.05.20 удалить счет(а) по одному реестру СП и ТК и по этим людям создать заново счета (м.б.другое кол-во счетов)
Function ReCreate_some_Schet_From_FILE_SP(arr)
Local arr_XML_info[8], cFile, arr_f, k, n, oXmlDoc, aerr := {}, t_arr[2], ;
      i, s, rec_schet, rec_schet_xml, go_to_schet := .f., arr_schet := {}
  
Private name_schet, _date_schet, mXML_REESTR
for i := 1 to len(arr)
  select SCHET
  goto (arr[i])
  if emptyany(schet_->name_xml,schet_->kod_xml) .or. schet_->IS_MODERN == 1
    return func_error(4,"Некорректно заполнены поля счёта "+rtrim(schet_->nschet)+". Операция запрещена.")
  endif
  if i == 1
    mXML_REESTR := schet_->XML_REESTR // ссылка на реестр СП и ТК
  elseif mXML_REESTR != schet_->XML_REESTR
    return func_error(4,"Счёт "+rtrim(schet_->nschet)+" из другого реестра СП и ТК. Операция запрещена.")
  endif
  aadd(arr_schet, { ;
    arr[i], ;                  // 1 - schet->(recno())
    schet_->kod_xml, ;         // 2 - ссылка на файл "mo_xml"
    schet_->name_xml, ;        // 3 - имя XML-файла без расширения (и ZIP-архива)
    alltrim(schet_->nschet), ; // 4 - номер счета
    schet_->dschet ;          // 5 - дата формирования счета
   })
next
//
mo_xml->(dbGoto(mXML_REESTR))
if empty(mo_xml->REESTR)
  return func_error(4,"Отсутствует ссылка на первичный реестр! Операция запрещена.")
endif
Private cReadFile := alltrim(mo_xml->FNAME) // имя файла реестра СП и ТК
Private cFileProtokol := cReadFile+stxt     // имя файла протокола чтения реестра СП и ТК
Private mkod_reestr := mo_xml->REESTR       // код первичного реестра
Private cTimeBegin := hour_min(seconds())
Private name_zip := cReadFile+szip          // имя архива файла реестра СП и ТК
cFile := cReadFile+sxml                     // имя XML-файла реестра СП и ТК
//
rees->(dbGoto(mkod_reestr))
Private name_reestr := alltrim(rees->name_xml)+szip // имя архива файла первичного реестра
// распаковываем первичный реестр
if (arr_f := Extract_Zip_XML(dir_server+dir_XML_MO+cslash,name_reestr)) == NIL
  return func_error(4,"Ошибка в распаковке архива реестра "+name_reestr)
endif
// распаковываем реестр СП и ТК
if (arr_f := Extract_Zip_XML(dir_server+dir_XML_TF+cslash,name_zip)) == NIL
  return func_error(4,"Ошибка в распаковке архива реестра СП и ТК "+name_zip)
endif
if (n := ascan(arr_f,{|x| upper(Name_Without_Ext(x)) == upper(cReadFile)})) == 0
  return func_error(4,"В архиве "+name_zip+" нет файла "+cReadFile+sxml)
endif
close databases

if mo_Lock_Task(X_OMS) // запрет только ОМС G_SLock1Task(sem_task,sem_vagno) // запрет доступа всем
  k := len(arr_schet)
  s := iif(k == 1, "счёта ", lstr(k)+" счетов ")
  if iif(arr_schet[1, 5] > stod("20220224") .and. arr_schet[1, 5] < stod("20220228") , .t.,involved_password(3,arr_schet[1, 4],"пересоздания "+s+arr_schet[1, 4])) ;
     .and. f_Esc_Enter("пересоздания "+s) // .and. m_copy_DB_from_end(.t.) // резервное копирование
    Private fl_open := .t.
    index_base("schet") // для составления счетов
    index_base("human") // для разноски счетов
    index_base("human_3") // двойные случаи
    use (dir_server + "human_u") new READONLY
    index on str(kod, 7)+date_u to (dir_server + "human_u") progress
    use
    Use (dir_server + "mo_hu") new READONLY
    index on str(kod, 7)+date_u to (dir_server + "mo_hu") progress
    Use
    index_base("mo_refr")  // для записи причин отказов
    //
    mywait()
    strfile(hb_eol()+;
            space(10)+"Повторная обработка файла: "+cFile+;
            hb_eol(),cFileProtokol)
    strfile(space(10)+full_date(sys_date)+"г. "+cTimeBegin+;
            hb_eol(),cFileProtokol, .t.)
    mywait("Производится анализ файла "+cFile)
    // читаем файл в память
    oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
    if oXmlDoc == NIL .or. empty( oXmlDoc:aItems )
      aadd(aerr,"Ошибка в чтении файла "+cFile)
    else
      reestr_sp_tk_tmpfile(oXmlDoc,aerr,cReadFile)
    endif
    if empty(aerr)
      R_Use(dir_server + "mo_rees",,"REES")
      goto (mkod_reestr)
      if !extract_reestr(rees->(recno()),rees->name_xml)
        aadd(aerr,center("Не найден ZIP-архив с РЕЕСТРом № "+lstr(mnschet)+" от "+ date_8(tmp1->_DSCHET), 80))
        aadd(aerr,"")
        aadd(aerr,center(dir_server+dir_XML_MO+cslash+ alltrim(rees->name_xml)+szip, 80))
        aadd(aerr,"")
        aadd(aerr,center("Без данного архива дальнейшая работа НЕВОЗМОЖНА!", 80))
      endif
    endif
    close databases
    if empty(aerr)
      dbcreate(cur_dir + "tmpsh",{{"kod_h","N", 7, 0}})
      use (cur_dir + "tmpsh") new
      R_Use(dir_server + "human", dir_server + "humans","HUMAN")
      for i := 1 to len(arr_schet)
        find (str(arr_schet[i, 1], 6))
        do while human->schet == arr_schet[i, 1] .and. !eof()
          select tmpsh
          append blank
          replace kod_h with human->kod
          select HUMAN
          skip
        enddo
      next
      select tmpsh
      index on str(kod_h, 7) to (cur_dir + "tmpsh")
      R_Use(dir_server + "mo_rhum",,"RHUM")
      index on str(REES_ZAP, 6) to (cur_dir + "tmp_rhum") for reestr == mkod_reestr
      // открыть распакованный реестр
      use (cur_dir + "tmp_r_t1") new alias T1
      index on str(val(n_zap), 6) to (cur_dir + "tmpt1")
      use (cur_dir + "tmp_r_t2") new alias T2
      index on IDCASE+str(sluch, 6) to (cur_dir + "tmpt2")
      use (cur_dir + "tmp_r_t3") new alias T3
      index on upper(ID_PAC) to (cur_dir + "tmpt3")
      use (cur_dir + "tmp_r_t4") new alias T4
      index on IDCASE+str(sluch, 6) to (cur_dir + "tmpt4")
      use (cur_dir + "tmp_r_t5") new alias T5
      index on IDCASE+str(sluch, 6) to (cur_dir + "tmpt5")
      use (cur_dir + "tmp_r_t6") new alias T6
      index on IDCASE+str(sluch, 6) to (cur_dir + "tmpt6")
      use (cur_dir + "tmp_r_t7") new alias T7
      index on IDCASE+str(sluch, 6) to (cur_dir + "tmpt7")
      use (cur_dir + "tmp_r_t8") new alias T8
      index on IDCASE+str(sluch, 6) to (cur_dir + "tmpt8")
      use (cur_dir + "tmp_r_t9") new alias T
      index on IDCASE+str(sluch, 6) to (cur_dir + "tmpt9")
      use (cur_dir + "tmp_r_t10") new alias T10
      index on IDCASE+str(sluch, 6)+regnum+code_sh+date_inj to (cur_dir + "tmpt10")
      use (cur_dir + "tmp_r_t11") new alias T11
      index on IDCASE+str(sluch, 6) to (cur_dir + "tmpt11")
      use (cur_dir + "tmp_r_t12") new alias T12
      index on IDCASE+str(sluch, 6) to (cur_dir + "tmpt12")
      use (cur_dir + "tmp_r_t1_1") new alias T1_1
      index on IDCASE to (cur_dir + "tmpt1_1")
      use (cur_dir + "tmp2file") new alias TMP2
      is_new_err := .f.  // ушли ли какие-либо случаи в ошибки (т.е. новые ошибки)
      go top
      do while !eof()
        if tmp2->_OPLATA == 1
          select T1
          find (str(tmp2->_N_ZAP, 6))
          if found()
            t1->VPOLIS := lstr(tmp2->_VPOLIS)
            t1->SPOLIS := tmp2->_SPOLIS
            t1->NPOLIS := tmp2->_NPOLIS
            t1->ENP    := tmp2->_ENP
            t1->SMO    := tmp2->_SMO
            t1->SMO_OK := tmp2->_SMO_OK
            t1->MO_PR  := tmp2->_MO_PR
          endif
        endif
        select RHUM
        find (str(tmp2->_N_ZAP, 6))
        if found() .and. rhum->KOD_HUM > 0
          select tmpsh
          find (str(rhum->KOD_HUM, 7))
          if found()
            tmp2->kod_human := rhum->KOD_HUM
            if tmp2->_OPLATA > 1
              is_new_err := .t. // т.е. в новом реестре СП и ТК человек ушёл в ошибки (а раньше попадал в счёт)
            endif
          endif
        else
          aadd(aerr,"")
          aadd(aerr," - не найден пациент с номером записи "+lstr(tmp2->_N_ZAP))
        endif
        select TMP2
        skip
      enddo
      select TMP2
      delete for kod_human == 0 // удалим тех, кто не входит в выбранные счета
      pack
    endif
    close databases
    if empty(aerr) .and. is_new_err
      R_Use(dir_server + 'mo_otd',, 'OTD')
      G_Use(dir_server + "human_",,"HUMAN_")
      G_Use(dir_server + "human",{dir_server + "humann", dir_server + "humans"},"HUMAN")
      set order to 0 // индексы открыты для реконструкции при перезаписи ФИО
      set relation to recno() into HUMAN_, to otd into OTD
      G_Use(dir_server + "human_3",{dir_server + "human_3", dir_server + "human_32"},"HUMAN_3")
      G_Use(dir_server + "mo_rhum",,"RHUM")
      index on str(REES_ZAP, 6) to (cur_dir + "tmp_rhum") for reestr == mkod_reestr
      G_Use(dir_server + "mo_refr", dir_server + "mo_refr","REFR")
      use (cur_dir + "tmp3file") new alias TMP3
      index on str(_n_zap, 8) to (cur_dir + "tmp3")
      use (cur_dir + "tmp2file") new alias TMP2
      go top
      do while !eof()
        if tmp2->_OPLATA > 1 // удаляем из счёта, удаляем из реестра, оформляем ошибку
          select RHUM
          find (str(tmp2->_N_ZAP, 6))
          G_RLock(forever)
          rhum->OPLATA := tmp2->_OPLATA
          is_2 := 0
          select HUMAN
          goto (rhum->KOD_HUM)
          if eq_any(human->ishod, 88, 89)
            select HUMAN_3
            if human->ishod == 88
              set order to 1
              is_2 := 1
            else
              set order to 2
              is_2 := 2
            endif
            find (str(rhum->KOD_HUM, 7))
            if found() // если нашли двойной случай
              select HUMAN
              if human->ishod == 88  // если реестр составлен по 1-му листу
                goto (human_3->kod2)  // встать на 2-ой
              else
                goto (human_3->kod)   // иначе - на 1-ый
              endif
              human->(G_RLock(forever))
              human->schet := 0 ; human->tip_h := B_STANDART
              //
              human_->(G_RLock(forever))
              human_->OPLATA := tmp2->_OPLATA
              human_->REESTR := 0 // направляется на дальнейшее редактирование
              human_->ST_VERIFY := 0 // снова ещё не проверен
              if human_->REES_NUM > 0
                human_->REES_NUM := human_->REES_NUM-1
              endif
              human_->REES_ZAP := 0
              if human_->schet_zap > 0
                if human_->SCHET_NUM > 0
                  human_->SCHET_NUM := human_->SCHET_NUM-1
                endif
                human_->schet_zap := 0
              endif
              //
              human_3->(G_RLock(forever))
              human_3->OPLATA := tmp2->_OPLATA
              human_3->schet := 0
              human_3->REESTR := 0
              if human_3->REES_NUM > 0
                human_3->REES_NUM := human_3->REES_NUM-1
              endif
              human_3->REES_ZAP := 0
              if human_3->SCHET_NUM > 0
                human_3->SCHET_NUM := human_3->SCHET_NUM - 1
              endif
              human_3->schet_zap := 0
            endif
          endif
          select HUMAN
          goto (rhum->KOD_HUM)
          G_RLock(forever)
          human->schet := 0 ; human->tip_h := B_STANDART
          human_->(G_RLock(forever))
          human_->OPLATA := tmp2->_OPLATA
          human_->REESTR := 0 // а направляется на дальнейшее редактирование
          human_->ST_VERIFY := 0 // снова ещё не проверен
          if human_->REES_NUM > 0
            human_->REES_NUM := human_->REES_NUM-1
          endif
          human_->REES_ZAP := 0
          if human_->SCHET_NUM > 0
            human_->SCHET_NUM := human_->SCHET_NUM-1
          endif
          human_->schet_zap := 0
          //
          lal := "human"
          if is_2 > 0
            lal += "_3"
          endif
          strfile("!!! "+ alltrim(human->fio)+", "+full_date(human->date_r)+;
                       iif(empty(otd->SHORT_NAME), "", " ["+ alltrim(otd->SHORT_NAME)+"]")+;
                       " "+ alltrim(human->KOD_DIAG)+;
                       " "+ date_8(&lal.->n_data)+"-"+ date_8(&lal.->k_data)+;
                       hb_eol(),cFileProtokol, .t.)
          select REFR
          do while .t.
            find (str(1, 1)+str(mkod_reestr, 6)+str(1, 1)+str(rhum->KOD_HUM, 8))
            if !found() ; exit ; endif
            DeleteRec(.t.)
          enddo
          select TMP3
          find (str(tmp2->_N_ZAP, 8))
          do while tmp2->_N_ZAP == tmp3->_N_ZAP .and. !eof()
            select REFR
            AddRec(1)
            refr->TIPD := 1
            refr->KODD := mkod_reestr
            refr->TIPZ := 1
            refr->KODZ := rhum->KOD_HUM
            refr->IDENTITY := tmp2->_IDENTITY
            refr->REFREASON := tmp3->_REFREASON
            refr->SREFREASON := tmp3->SREFREASON
            if empty(refr->SREFREASON)
              if empty(s := ret_t005(refr->REFREASON))
                s := lstr(refr->REFREASON)+" неизвестная причина отказа"
              endif
            else
              s := "код ошибки = "+tmp3->SREFREASON+" "
              s += '"' + getCategoryCheckErrorByID_Q017(left(tmp3->SREFREASON, 4))[2] + '" '
              s += alltrim(inieditspr(A__POPUPMENU, dir_exe+"_mo_Q015", tmp3->SREFREASON))
            endif
            k := perenos(t_arr,s, 75)
            for i := 1 to k
              strfile(space(5)+t_arr[i]+hb_eol(),cFileProtokol, .t.)
            next
            select TMP3
            skip
          enddo
          if is_2 > 0
            strfile(space(5)+'- разбейте двойной случай в режиме "ОМС/Двойные случаи/Разделить"'+;
                    hb_eol(),cFileProtokol, .t.)
            strfile(space(5)+'- отредактируйте каждый из случаев в режиме "ОМС/Редактирование"'+;
                    hb_eol(),cFileProtokol, .t.)
            strfile(space(5)+'- снова соберите случай в режиме "ОМС/Двойные случаи/Создать"'+;
                    hb_eol(),cFileProtokol, .t.)
          endif
        endif
        select TMP2
        skip
      enddo
      close databases
      strfile(hb_eol(),cFileProtokol, .t.)
    endif
    if empty(aerr)
      arr_f := {}
      // создадим новые счета
      go_to_schet := create_schet_from_XML(arr_XML_info,aerr,,arr_f,cReadFile)
      close databases
      if empty(aerr) // если нет ошибок
        use_base("schet")
        set relation to
        G_Use(dir_server + "mo_xml",,"MO_XML")
        // удалим старые счета
        for i := 1 to len(arr_schet)
          strfile(hb_eol()+;
                  "удалён старый счёт № "+arr_schet[i, 4]+" от "+full_date(arr_schet[i, 5])+;
                  hb_eol(),cFileProtokol, .t.)
          select SCHET_
          goto (arr_schet[i, 1])
          DeleteRec(.t., .f.)  // без пометки на удаление
          //
          select SCHET
          goto (arr_schet[i, 1])
          DeleteRec(.t.)
          //
          select MO_XML
          goto (arr_schet[i, 2])
          DeleteRec(.t.)
        next
        close databases
      endif
    endif
    if empty(aerr)
      // дозапишем предыдущий файл протокола обработки новым протоколом
      f_append_file(dir_server+dir_XML_TF+cslash+cFileProtokol,cFileProtokol)
      viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+cFileProtokol, 60, 80),,,, .t.,,, 2)
    else
      aeval(aerr,{|x| strfile(x+hb_eol(),cFileProtokol, .t.) })
      viewtext(Devide_Into_Pages(cFileProtokol, 60, 80),,,, .t.,,, 2)
    endif
    delete file (cFileProtokol)
  endif
  close databases
  // разрешение доступа всем
  //G_SUnLock(sem_vagno)
  mo_UnLock_Task(X_OMS)
  keyboard ""
  if go_to_schet // если выписаны счета
    keyboard chr(K_ENTER)
  endif
else
  func_error(4,"В данный момент работают другие задачи. Операция запрещена!")
endif
return NIL

// 08.02.23 дополнить файл ofile строками из файла nfile
Function f_append_file(ofile, nfile)
  Local s

  ft_use(nfile)
  ft_gotop()
  do while !ft_eof()
    s := ft_ReadLn()
    strfile(s + hb_eol(), ofile, .t.)
    ft_skip()
  enddo
  ft_use()
  return NIL
