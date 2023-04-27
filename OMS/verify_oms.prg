#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define max_rec_reestr 9999

// 27.04.23
Function verify_OMS(arr_m, fl_view)
  Local ii := 0, iprov := 0, inprov := 0, ko := 2, fl, name_file := cur_dir + 'err_sl' + stxt, ;
        name_file2, name_file3, kr_unlock, i, ;
        mas_pmt := {'Список обнаруженных ошибок в результате проверки'}, mas_file := {}

  aadd(mas_file, name_file)
  DEFAULT arr_m TO year_month(T_ROW, T_COL + 5, , 3), fl_view TO .t.
  if arr_m == NIL
    return NIL
  endif
  if fl_view .and. (ko := popup_prompt(T_ROW, T_COL + 5, 1, ;
                                       {'Проверять ~всех пациентов', ;
                                        'Не проверять вернувшихся из ТФОМС с ~ошибкой'})) == 0
    return NIL
  endif
  kr_unlock := iif(fl_view, 50, 1000)
  WaitStatus('Начало проверки...')
  fp := fcreate(name_file)
  n_list := 1
  tek_stroke := 0
  add_string('')
  add_string(center('Список обнаруженных ошибок', 80))
  add_string(center('по дате окончания лечения ' + arr_m[4], 80))
  add_string('')
  if ! fl_view
    Use (cur_dir + 'tmp') new
    use (cur_dir + 'tmpb') index (cur_dir + 'tmpb') new
  endif
  dbcreate(cur_dir + 'tmp_no', {{'kod', 'N', 7, 0}, ;
                                {'tip', 'N', 1, 0}, ;
                                {'komu', 'N', 1, 0}, ;
                                {'str_crb', 'N', 2, 0}})
  use (cur_dir + 'tmp_no') new
  f_create_diag_srok()
  R_Use(dir_server + 'mo_pers', , 'PERS')
  R_Use(dir_server + 'mo_uch', , 'UCH')
  R_Use(dir_server + 'mo_otd', , 'OTD')
  use_base('lusl')
  use_base('luslc')
  use_base('luslf')
  R_Use(dir_server + 'uslugi', , 'USL')
  G_Use(dir_server + 'human_u_', , 'HU_')
  G_Use(dir_server + 'human_u', {dir_server + 'human_u', ;
                                dir_server + 'human_uk', ;
                                dir_server + 'human_ud', ;
                                dir_server + 'human_uv', ;
                                dir_server + 'human_ua'}, 'HU')
  set relation to recno() into HU_, to u_kod into USL
  R_Use(dir_server + 'mo_su', , 'MOSU')
  G_Use(dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU')
  set relation to u_kod into MOSU
  G_Use(dir_server + 'kartote_', , 'KART_')
  R_Use(dir_server + 'kartotek', , 'KART')
  set relation to recno() into KART_
  G_Use(dir_server + 'mo_onkna', dir_server + 'mo_onkna', 'ONKNA') // онконаправления
  G_Use(dir_server + 'mo_onksl', dir_server + 'mo_onksl', 'ONKSL') // Сведения о случае лечения онкологического заболевания
  G_Use(dir_server + 'mo_onkdi', dir_server + 'mo_onkdi', 'ONKDI') // Диагностический блок
  G_Use(dir_server + 'mo_onkpr', dir_server + 'mo_onkpr', 'ONKPR') // Сведения об имеющихся противопоказаниях
  G_Use(dir_server + 'mo_onkus', dir_server + 'mo_onkus', 'ONKUS')
  G_Use(dir_server + 'mo_onkco', dir_server + 'mo_onkco', 'ONKCO')
  G_Use(dir_server + 'mo_onkle', dir_server + 'mo_onkle', 'ONKLE')
  G_Use(dir_server + 'human_2', , 'HUMAN_2')
  G_Use(dir_server + 'human_', , 'HUMAN_')
  G_Use(dir_server + 'human', dir_server + 'humand', 'HUMAN')
  dbseek(dtos(arr_m[5]), .t.)
  if ascan(kod_LIS, glob_mo[_MO_KOD_TFOMS]) > 0 .and. fl_view
    Private old_npr_mo := '000000'
    index on f_napr_mo_lis() + upper(fio) + str(kod_k, 7) to (cur_dir + 'tmp_hfio') ;
          while human->k_data <= arr_m[6] .and. !eof() ;
          for tip_h == B_STANDART .and. empty(schet) .and. !empty(k_data)
  else
    index on upper(fio) + str(kod_k, 7) to (cur_dir + 'tmp_hfio') ;
          while human->k_data <= arr_m[6] .and. !eof() ;
          for tip_h == B_STANDART .and. empty(schet) .and. !empty(k_data)
  endif
  set index to (dir_server + 'humans'), (dir_server + 'humankk'), (dir_server + 'humand'), (cur_dir + 'tmp_hfio')
  set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
  set order to 4
  go top
  do while !eof()
    if emptyall(iprov, inprov)
      UpdateStatus()
    endif
    if empty(human_->reestr)
      ++ii
      if (fl := (human->cena_1 == 0)) // если цена нулевая
        otd->(dbGoto(human->OTD))
        if is_smp(human_->USL_OK, human_->PROFIL)  // скорая помощь
          fl = .f.
        elseif eq_any(human->ishod, 201, 202, 204) // диспансеризация взрослого населения
          fl = .f.
        elseif otd->tiplu == TIP_LU_ONKO_DISP
          fl := .f.
        endif
      endif
      if empty(int(val(human_->smo))) // нет СМО
        fl := .t.
      endif
      if fl // прочие счета
        select TMP_NO
        append blank
        tmp_no->kod  := human->kod
        tmp_no->tip  := iif(human->cena_1 == 0, 1, 2)
        tmp_no->komu := human->komu
        tmp_no->str_crb := human->str_crb
      elseif ko == 2 .and. human_->oplata == 2 .and. human_->ST_VERIFY < 5
        // не проверять вернувшихся из ТФОМС с ошибкой
      else
        if arr_m[1] > 2018
          fl := verify_1_sluch(fl_view)
        else
          fl := verify_1_sluch_18(fl_view)
        endif
        if fl
          ++iprov
          if !fl_view .and. human->ishod != 88 .and. ! exist_reserve_KSG(human->kod, 'HUMAN') // это не 1-ый л/у в двойном случае
            select TMPB
            find (str(human->kod, 7))
            if !found()
              append blank
              tmpb->kod_human := human->kod
              tmpb->n_data := human->n_data
              tmpb->k_data := human->k_data
              tmpb->cena_1 := human->cena_1
              tmpb->PZKOL := human_->pzkol
              tmpb->ishod := human->ishod
              tmpb->plus := .t.
              tmpb->kod_tmp := 1
              tmpb->plus := .t.
              if arr_m[1] > 2016
                if between(human->ishod, 301, 305) .or. between(human->ishod, 201, 205) .or. between(human->ishod, 101, 102) .or. between(human->ishod, 401, 402)
                  tmpb->tip := 2
                  kol_2r++
                else
                  tmpb->tip := 1
                  kol_1r++
                endif
              endif
            endif
            if iprov >= max_rec_reestr // если число проверенных без ошибок достигло максимума,
              exit                     // остальных не проверяем, начинаем составление реестра
            endif
          endif
        else
          ++inprov
        endif
      endif
      @ maxrow(), 50 say padl( 'всего: ' + lstr(iprov + inprov) + ', ошибок: ' + lstr(inprov), 30) color cColorSt2Msg
    endif
    if ii % kr_unlock == 0
      dbUnlockAll()
      dbCommitAll()
    endif
    select HUMAN
    set order to 4  //
    skip
  enddo
  dbUnlockAll()
  dbCommitAll()
  if inprov == 0
    if iprov > 0
      add_string( 'Проверено случаев - ' + lstr(iprov) + '. Ошибок не обнаружено.')
    else
      add_string('Нечего проверять!')
    endif
  endif
  fclose(fp)
  if !fl_view
    select HUMAN
    set index to  // отвязываем условный индекс
    G_Use(dir_server + 'human_3', {dir_server + 'human_3', dir_server + 'human_32'}, 'HUMAN_3')
    // проверяем случаи, где 2-ой случай закончился в текущем отчётном месяце, а 1-ый - неважно
    select HUMAN_3
    set order to 2 // встать на индекс по 2-му случаю
    select TMPB
    index on str(kod_human, 7) to (cur_dir + 'tmpb') for ishod == 89  // 2-ой лист учёта в двойном случае
    go top
    do while !eof()
      select HUMAN_3
      find (str(tmpb->kod_human, 7))
      if found()
        select HUMAN
        goto (tmpb->kod_human)  // 2-ой лист учёта в двойном случае
        ln_data := human->n_data
        lk_data := human->k_data
        ldiag := human->kod_diag
        lcena := human->cena_1
        pz := human_->PZKOL
        select HUMAN
        goto (human_3->kod)
        if human_->ST_VERIFY >= 5 // если 1-ый л/у также прошёл проверку
          if !exist_reserve_KSG(HUMAN->kod, 'HUMAN')
            ln_data := human->n_data
          endif
          lcena += human->cena_1
          pz += human_->PZKOL
          select HUMAN_3
          G_RLock(forever)
          human_3->N_DATA    := ln_data
          human_3->K_DATA    := lk_data
          human_3->CENA_1    := lcena
          select HUMAN
          goto (human_3->kod2)  // снова встать на 2-ой случай, чтобы взять исход, результат, ...
          human_3->RSLT_NEW  := human_->RSLT_NEW
          human_3->ISHOD_NEW := human_->ISHOD_NEW
          human_3->VNR1      := human_2->VNR1
          human_3->VNR2      := human_2->VNR2
          human_3->VNR3      := human_2->VNR3
          human_3->PZKOL     := pz
          human_3->ST_VERIFY := 5
          tmpb->n_data := ln_data
          tmpb->k_data := lk_data
          tmpb->cena_1 := lcena
          tmpb->PZKOL := pz
        else
          tmpb->tip := 0 //p_tip_reestr
          kol_1r--
        endif
      else
        tmpb->tip := 0 //p_tip_reestr
        kol_1r--
      endif
      select TMPB
      skip
    enddo
  endif
  if fl_view .and. d_srok->(lastrec()) > 0
    name_file2 := cur_dir + 'err_sl2' + stxt
    delete file (name_file2)
    aadd(mas_pmt, 'Случаи повторных обращений по поводу одного заболевания')
    aadd(mas_file, name_file2)
    mywait()
    delFRfiles()
    adbf := {{'name', 'C', 130, 0}, ;
             {'name1', 'C', 150, 0}, ;
             {'period', 'C', 150, 0}}
    dbcreate(fr_titl, adbf)
    use (fr_titl) new alias FRT
    append blank
    frt->name := glob_mo[_MO_SHORT_NAME]
    frt->name1 := 'Список случаев повторных обращений по поводу одного и того же заболевания'
    frt->period := arr_m[4]
    adbf := {{'fio', 'C', 100, 0}, ;
             {'diag', 'C', 5, 0}, ;
             {'diag1', 'C', 5, 0}, ;
             {'srok', 'C', 30, 0}, ;
             {'srok1', 'C', 30, 0}, ;
             {'tip', 'C', 12, 0}, ;
             {'tip1', 'C', 12, 0}, ;
             {'otd', 'C', 200, 0}, ;
             {'otd1', 'C', 200, 0}, ;
             {'vrach', 'C', 100, 0}, ;
             {'vrach1', 'C', 100, 0}}
    dbcreate(fr_data, adbf)
    use (fr_data) new alias FRD
    am := {'78', '80', '88', '89'}
    select HUMAN
    set index to
    select D_SROK
    go top
    do while !eof()
      select HUMAN
      goto (d_srok->kod)
      select FRD
      append blank
      frd->fio := alltrim(human->fio) + ' д.р.' + full_date(human->date_r) + ' (повтор через ' + lstr(d_srok->dni) + ' дн.)'
      frd->diag := human->kod_diag
      frd->srok := full_date(human->n_data) + ' - ' + full_date(human->k_data)
      if d_srok->tip > 0
        frd->tip := '( 2.' + am[d_srok->tip] + '.' + d_srok->tips + ' )'
      elseif human_->usl_ok == USL_OK_HOSPITAL  //  1
        frd->tip := '( стац. )'
      elseif human_->usl_ok == USL_OK_DAY_HOSPITAL  //  2
        frd->tip := '( дн.ст. )'
      elseif human_->usl_ok == USL_OK_AMBULANCE //  4
        frd->tip := '( скорая )'
      endif
      uch->(dbGoto(human->LPU))
      otd->(dbGoto(human->OTD))
      frd->otd := alltrim(uch->name) + '/ ' + alltrim(otd->name) + '/ профиль по "' + ;
                  inieditspr(A__MENUVERT, getV002(), human_->profil) + '"'
      pers->(dbGoto(human_->VRACH))
      frd->vrach := '[ ' + lstr(pers->tab_nom) + ' ] ' + pers->fio
      //
      select HUMAN
      goto (d_srok->kod1)
      frd->diag1 := human->kod_diag
      frd->srok1 := full_date(human->n_data) + ' - ' + full_date(human->k_data)
      if d_srok->tip1 > 0
        frd->tip1 := '( 2.' + am[d_srok->tip1] + '.' + d_srok->tip1s + ' )'
      elseif human_->usl_ok == USL_OK_HOSPITAL  //  1
        frd->tip1 := '( стац. )'
      elseif human_->usl_ok == USL_OK_DAY_HOSPITAL  // 2
        frd->tip1 := '( дн.ст. )'
      elseif human_->usl_ok == USL_OK_AMBULANCE //  4
        frd->tip1 := '( скорая )'
      endif
      uch->(dbGoto(human->LPU))
      otd->(dbGoto(human->OTD))
      frd->otd1 := alltrim(uch->name) + '/ ' + alltrim(otd->name) + '/ профиль по "' + ;
                      inieditspr(A__MENUVERT, getV002(), human_->profil) + '"'
      pers->(dbGoto(human_->VRACH))
      frd->vrach1 := '[ ' + lstr(pers->tab_nom) + ' ] ' + pers->fio
      select D_SROK
      skip
    enddo
  endif
  if fl_view .and. tmp_no->(lastrec()) > 0
    name_file3 := cur_dir + 'err_sl3' + stxt
    aadd(mas_pmt, 'Список листов учёта, которые не проверялись')
    aadd(mas_file, name_file3)
    fp := fcreate(name_file3)
    n_list := 1
    tek_stroke := 0
    select HUMAN
    set index to
    add_string('')
    add_string(center('Список листов учёта, которые не проверялись', 80))
    R_Use(dir_server + 'str_komp', , 'STR')
    R_Use(dir_server + 'komitet', , 'KOM')
    select TMP_NO
    set relation to kod into HUMAN
    index on str(tip, 1) + str(komu, 1) + str(str_crb, 2) + upper(human->fio) to (cur_dir + 'tmp_no')
    old_tip := old_komu := old_str_crb := -1
    go top
    do while !eof()
      verify_FF(77, .t., 80)
      add_string('')
      if old_tip != tmp_no->tip
        old_tip := tmp_no->tip
        if tmp_no->tip == 1
          add_string(padc('Нулевая цена', 80, '-'))
        endif
      endif
      if old_komu != tmp_no->komu
        old_komu := tmp_no->komu
        if tmp_no->tip == 2 .and. tmp_no->komu == 0
          add_string(padc('Пустая СМО', 80, '-'))
        endif
      endif
      if !(old_komu == tmp_no->komu .and. old_str_crb == tmp_no->str_crb)
        old_komu := tmp_no->komu
        old_str_crb := tmp_no->str_crb
        do case
          case tmp_no->komu == 1
            str->(dbGoto(tmp_no->str_crb))
            add_string(padc('Прочая компания: ' + alltrim(str->name), 80, '-'))
          case tmp_no->komu == 3
            kom->(dbGoto(tmp_no->str_crb))
            add_string(padc('Комитет/МО: ' + alltrim(kom->name), 80, '-'))
          case tmp_no->komu == 5
            add_string(padc('Личный счёт', 80, '-'))
        endcase
      endif
      uch->(dbGoto(human->LPU))
      otd->(dbGoto(human->OTD))
      add_string(alltrim(human->fio) + ' ' + date_8(human->n_data) + '-' + date_8(human->k_data))
      add_string(' ' + alltrim(uch->name) + '/' + alltrim(otd->name))
      select TMP_NO
      skip
    enddo
    fclose(fp)
  endif
  close databases
  if fl_view
    ClrLine(maxrow(), color0)
    if len(mas_pmt) == 1
      viewtext(name_file, , , , .t., , , 5)
    else
      i := 1
      keyboard chr(K_ENTER)
      do while i > 0
        if (i := popup_prompt(T_ROW, T_COL + 5, i, mas_pmt, mas_pmt)) == 0
          if !f_Esc_Enter('выхода из просмотра')
            i := 1
          endif
        elseif hb_fileExists(mas_file[i])
          viewtext(mas_file[i], , , , .t., , , 5)
        else
          call_fr('mo_d_srok')
        endif
      enddo
    endif
  endif
  return nil  