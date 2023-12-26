// информация по форма 14-МЕД ОМС (по счетам)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 26.12.23 форма 14-МЕД (ОМС)
Function forma14_med_oms()
  Static group_ini := 'f14_med_oms'
  Local begin_date, end_date, buf := savescreen(), arr_m, i, j, k, k1, k2, ;
        t_arr[10], t_arr1[10], name_file := cur_dir + 'f14med' + stxt, tfoms_pz[5, 11], ;
        sh, HH := 80, reg_print := 5, is_trudosp, is_rebenok, is_inogoro, is_onkologia, ;
        is_reabili, is_ekstra, lshifr1, koef, vid_vp, r1 := 9, fl_exit := .f., ;
        is_vmp, d2_year, ar, arr_excel := {}, fl_error := .f., is_z_sl, ;
        cFileProtokol := cur_dir + 'tmp' + stxt, arr_prof := {}, arr_usl, au, ii, is_school,;
        filetmp14 := cur_dir + 'tmp14' + stxt, sum_k := 0, sum_ki := 0, sum_kd := 0, sum_kt := 0, kol_d := 0 , sum_d := 0
  Local arr_skor[81, 2], arr_eko[2, 2], arr_profil := {}, arr_dn_stac := {}, arrDdn_stac[4], fl_pol1[15], ;
        arr_pol[32], arr_pol1[15, 5], arr_pril5[32, 3], ifff := 0, kol_stom_pos := 0, ;
        arr_pol3000[29, 6], vr_rec := 0, arr_full_usl, ;
        fl_pol3000_PROF, fl_pol3000_DVN2 := .T.
  
  local sbase
  local lal, lalf
  local nameArr //, funcGetPZ
  
  old5 := old2 := 0
  afillall(arr_skor, 0)
  afillall(arr_eko, 0)
  afill(arrDdn_stac, 0)
  afill(arr_pol, 0)
  afillall(arr_pril5, 0)
  afillall(arr_pol1, 0)
  afillall(arr_pol3000, 0)
  arr_pol1[ 1, 1] := 'Посещений - всего (02+11+13)'
  arr_pol1[ 2, 1] := 'Посещения с профилактическими и иными целями (03+06+09)'
  arr_pol1[ 3, 1] := 'посещения с профилактическими целями, всего'
  arr_pol1[ 4, 1] := 'из строки 03 - посещения, связанные с диспансеризацией'
  arr_pol1[ 5, 1] := 'из строки 03 - посещения по специальности "стоматология"'
  arr_pol1[ 6, 1] := 'разовые посещения в связи с заболеваниями, всего'
  arr_pol1[ 7, 1] := 'из строки 06 - посещения на дому'
  arr_pol1[ 8, 1] := 'из строки 06 - посещения по специальности "стоматология"'
  arr_pol1[ 9, 1] := 'посещения с иными целями, всего'
  arr_pol1[10, 1] := 'из строки 09 паллиативная медицинская помощь'
  arr_pol1[11, 1] := 'Посещения при оказании помощи в неотложной форме, всего'
  arr_pol1[12, 1] := 'из строки 11 - посещения на дому'
  arr_pol1[13, 1] := 'Посещения, включенные в обращение в связи с заболеваниями'
  arr_pol1[14, 1] := 'из строки 13 - посещения по специальности "стоматология"'
  arr_pol1[15, 1] := 'Из строки 01 - посещения к среднему медперсоналу'
  //
  arr_pol3000[ 1, 1] := 'Посещений - всего (02+21+25)' //1-1
  arr_pol3000[ 1, 6] := 1
  arr_pol3000[ 2, 1] := 'Посещения с профилактическими и иными целями (03+06)' //
  arr_pol3000[ 2, 6] := 2
  arr_pol3000[ 3, 1] := 'посещения с профилактическими целями, всего (04+05)'
  arr_pol3000[ 3, 6] := 3
  arr_pol3000[ 4, 1] := 'из строки 03 - посещения, связанные с профосмотрами'
  arr_pol3000[ 4, 6] := 4
  arr_pol3000[ 5, 1] := 'из строки 03 - посещения, связанные с диспансеризацией'
  arr_pol3000[ 5, 6] := 5
  arr_pol3000[ 6, 1] := 'посещения с иными целями, всего (07+08+12+14+15+16+19+20)'
  arr_pol3000[ 6, 6] := 6
  arr_pol3000[ 7, 1] := 'из строки 06 посещения с целью диспансерного наблюдения'
  arr_pol3000[ 7, 6] := 7
  arr_pol3000[ 8, 1] := 'из строки 06 посещения с целью диспансеризации'
  arr_pol3000[ 8, 6] := 8
  arr_pol3000[ 9, 1] := 'из строки 06 разовые посещения в связи с заболеваниями'
  arr_pol3000[ 9, 6] := 12
  arr_pol3000[ 10, 1] := 'из строки 12 - посещения на дому'
  arr_pol3000[ 10, 6] := 13
  arr_pol3000[ 11, 1] := 'из строки 06 - посещения центров доровья'
  arr_pol3000[ 11, 6] := 14
  arr_pol3000[ 12, 1] := 'из строки 06 - посещения работников, со средним м/о'
  arr_pol3000[ 12, 6] := 15
  arr_pol3000[ 13, 1] := 'из строки 06 - посещения амбулаторных ОНКО центров'
  arr_pol3000[ 13, 6] := 16
  arr_pol3000[ 14, 1] := 'из строки 12 - посещения по специальности "онкология"'
  arr_pol3000[ 14, 6] := 17
  arr_pol3000[ 15, 1] := 'из строки 13 - посещения по специальности "стоматология"'
  arr_pol3000[ 15, 6] := 18
  arr_pol3000[ 16, 1] := 'посещения с другими целями, всего'
  arr_pol3000[ 16, 6] := 20
  arr_pol3000[ 17, 1] := 'Посещения при оказании помощи в неотложной форме, всего'
  arr_pol3000[ 17, 6] := 21
  arr_pol3000[ 18, 1] := 'из строки 21 - посещения на дому'
  arr_pol3000[ 18, 6] := 22
  arr_pol3000[ 19, 1] := 'из строки 21 - посещения по специальности "стоматология"'
  arr_pol3000[ 19, 6] := 24
  arr_pol3000[ 20, 1] := 'Посещения, включенные в обращение в связи с заболеваниями'
  arr_pol3000[ 20, 6] := 25
  arr_pol3000[ 21, 1] := 'из строки 25 - посещения по специальности "онкология"'
  arr_pol3000[ 21, 6] := 26
  arr_pol3000[ 22, 1] := 'из строки 25 - посещения по специальности "стоматология"'
  arr_pol3000[ 22, 6] := 27
  arr_pol3000[ 23, 1] := ' КТ'
  arr_pol3000[ 23, 6] := 28
  arr_pol3000[ 24, 1] := ' МРТ'
  arr_pol3000[ 24, 6] := 29
  arr_pol3000[ 25, 1] := ' УЗИ ССС'
  arr_pol3000[ 25, 6] := 30
  arr_pol3000[ 26, 1] := ' Эндоскопические диагностические исследования'
  arr_pol3000[ 26, 6] := 31
  arr_pol3000[ 27, 1] := ' Молекулярно-генетические исследования'
  arr_pol3000[ 27, 6] := 32
  arr_pol3000[ 28, 1] := ' Гистологические исследования'
  arr_pol3000[ 28, 6] := 33
  arr_pol3000[ 29, 1] := ' Тестирование на COVID-19'
  arr_pol3000[ 29, 6] := 34
  
  
  //
  arr_pril5[ 1, 1] := 'Объёмы всего ,руб.'
  arr_pril5[ 2, 1] := 'СМП - вызовов, ед.'
  arr_pril5[ 3, 1] := 'СМП - лиц, чел.'
  arr_pril5[ 4, 1] := 'СМП - руб.'
  arr_pril5[ 8, 1] := 'Всего посещений'
  arr_pril5[ 9, 1] := 'Всего расходов на амб.помощь'
  arr_pril5[10, 1] := 'Число обращений по поводу заболевания'
  arr_pril5[32, 1] := 'Число обращений по поводу Диспансерного наблюдения' 
  arr_pril5[11, 1] := 'Число посещений с проф.(иной) целью'
  arr_pril5[12, 1] := 'руб.'
  arr_pril5[13, 1] := 'Число посещений по неотл.мед.помощи'
  arr_pril5[14, 1] := 'руб.'
  arr_pril5[15, 1] := 'Стационар - койко-дней'
  arr_pril5[16, 1] := 'Стационар - случаев госпитализации'
  arr_pril5[17, 1] := 'Стационар - руб.'
  arr_pril5[18, 1] := 'Стац(ВМП) - койко-дней'
  arr_pril5[19, 1] := 'Стац(ВМП) - случаев госпитализации'
  arr_pril5[20, 1] := 'Стац(ВМП) - руб.'
  arr_pril5[21, 1] := 'Стац(реабил) - койко-дней'
  arr_pril5[22, 1] := 'Стац(реабил) - случаев госпитализации'
  arr_pril5[23, 1] := 'Стац(реабил) - руб.'
  arr_pril5[24, 1] := 'Дн.стац. - пациенто-дней'
  arr_pril5[25, 1] := 'Дн.стац. - пациентов, чел.'
  arr_pril5[26, 1] := 'Дн.стац. - руб.'
  arr_pril5[27, 1] := 'Дн.стац.ЭКО - пациенто-дней'
  arr_pril5[28, 1] := 'Дн.стац.ЭКО - пациентов, чел.'
  arr_pril5[29, 1] := 'Дн.стац.ЭКО - руб.'
  arr_pril5[30, 1] := 'Стац - стентирование, единиц' 
  arr_pril5[31, 1] := 'Стац - стентирование иногородние, единиц' 

  
  ////////////////////////////////////////////////////////////////////
  arr_m := {2023, 1, 12, 'за январь - сентябрь 2023 года', 0d20230101, 0d20230930}
  ////////////////////////////////////////////////////////////////////
  lal := create_name_alias('lusl', arr_m[1])
  lalf := create_name_alias('luslf', arr_m[1])
  Private mk1, mk2, mk3, mk4, md1, md11, md12, md2, md21, md22, md3, md4
  ar := GetIniSect(tmp_ini, group_ini)
  mk1 := int(val(a2default(ar, 'mk1', '0')))
  mk2 := int(val(a2default(ar, 'mk2', '0')))
  mk3 := int(val(a2default(ar, 'mk3', '0')))
  mk4 := int(val(a2default(ar, 'mk4', '0')))
  md1 := int(val(a2default(ar, 'md1', '0')))
  md11 := int(val(a2default(ar, 'md11', '0')))
  md12 := int(val(a2default(ar, 'md12', '0')))
  md2 := int(val(a2default(ar, 'md2', '0')))
  md21 := int(val(a2default(ar, 'md21', '0')))
  md22 := int(val(a2default(ar, 'md22', '0')))
  md3 := int(val(a2default(ar, 'md3', '0')))
  md4 := int(val(a2default(ar, 'md4', '0')))
  box_shadow(r1, 2, 22, 77, color1,'Форма 14-МЕД ' + arr_m[4], color8)
  tmp_solor := setcolor(cDataCGet)
  @ r1 + 1, 4 say center('Стационар (раздел II)', 72) color color14
  @ r1 + 2, 4 say 'Число коек на конец отчетного периода (коек)      ' get mk1 pict '9999'
  @ r1 + 3, 4 say '  из них: для детей (0-17 лет включительно) (коек)' get mk2 pict '9999'
  @ r1 + 4, 4 say 'Число коек в среднем за отчетный период (коек)    ' get mk3 pict '9999'
  @ r1 + 5, 4 say '  из них: для детей (0-17 лет включительно) (коек)' get mk4 pict '9999'
  @ r1 + 6, 4 say center('Дневной стационар (раздел IV)', 72) color color14
  @ r1 + 7, 4 say 'Число дневных стационаров                   ' get md1 pict '9999'
  @ r1 + 8, 4 say '    из них при оказании специализированной помощи' get md11 pict '9999' valid md11 <= md1
  @ row(), col() say ', в т.ч.ВМП' get md12 pict '9999' valid md12 <= md11
  @ r1 + 9, 4 say '  Из них оказывающие помощь детям (0-17 лет)' get md2 pict '9999'
  @ r1 + 10, 4 say '    из них при оказании специализированной помощи' get md21 pict '9999' valid md21 <= md2
  @ row(),col() say ', в т.ч.ВМП' get md22 pict '9999' valid md22 <= md21
  @ r1 + 11, 4 say 'Число мест на конец отчетного периода       ' get md3 pict '9999'
  @ r1 + 12, 4 say 'Число мест, в среднем за отчетный период    ' get md4 pict '9999'
  status_key('^<Esc>^ - выход;  ^<PgDn>^ - создание отчёта')
  myread()
  restscreen(buf)
  if lastkey() == K_ESC
    return nil
  endif
  SetIniSect(tmp_ini, group_ini, {{'mk1', mk1}, ;
                                  {'mk2', mk2}, ;
                                  {'mk3', mk3}, ;
                                  {'mk4', mk4}, ;
                                  {'md1', md1}, ;
                                  {'md11', md11}, ;
                                  {'md12', md12}, ;
                                  {'md2', md2}, ;
                                  {'md21', md21}, ;
                                  {'md22', md22}, ;
                                  {'md3', md3}, ;
                                  {'md4', md4}})
  WaitStatus(arr_m[4])
  @ maxrow(), 0 say ' ждите...' color 'W/R'
  begin_date := dtoc4(arr_m[5])
  end_date := dtoc4(arr_m[6])
  dbcreate(cur_dir + 'tmp', {{'nstr', 'N', 2, 0}, ;
                          {'sum4', 'N', 15, 2}, ;
                          {'sum5', 'N', 15, 2}, ;
                          {'sum6', 'N', 15, 2}, ;
                          {'sum7', 'N', 15, 2}, ;
                          {'sum8', 'N', 15, 2}, ;
                          {'sum9', 'N', 15, 2}})
  use (cur_dir + 'tmp') new alias TMP
  index on str(nstr, 2) to (cur_dir + 'tmp')
  append blank ; tmp->nstr :=  1 ; tmp->sum4 := tmp->sum5 := mk1
  append blank ; tmp->nstr :=  2 ; tmp->sum4 := tmp->sum5 := mk2
  append blank ; tmp->nstr :=  3 ; tmp->sum4 := tmp->sum5 := mk3
  append blank ; tmp->nstr :=  4 ; tmp->sum4 := tmp->sum5 := mk4
  append blank ; tmp->nstr := 46 ; tmp->sum4 := tmp->sum5 := md1 ; tmp->sum7 := md11 ; tmp->sum8 := md12
  append blank ; tmp->nstr := 47 ; tmp->sum4 := tmp->sum5 := md2 ; tmp->sum7 := md21 ; tmp->sum8 := md22
  append blank ; tmp->nstr := 48 ; tmp->sum4 := tmp->sum5 := md3
  append blank ; tmp->nstr := 49 ; tmp->sum4 := tmp->sum5 := md4
  dbcreate(cur_dir + 'tmpf14', {;
     {'KOD_XML',  'N', 6, 0}, ; // ссылка на файл 'mo_xml'
     {'SCHET',    'N', 6, 0}, ; //
     {'KOD_RAK',  'N', 6, 0}, ; // № записи в файле RAK
     {'KOD_RAKS', 'N', 6, 0}, ; // № записи в файле RAKS
     {'KOD_RAKSH','N', 8, 0}, ; // № записи в файле RAKSH
     {'kol_akt',  'N', 2, 0}, ; //
     {'usl_ok',   'N', 1, 0}, ; //
     {'KOD_H',    'N', 7, 0};  // код листа учета по БД 'human'
    })
  use (cur_dir + 'tmpf14') new alias TMPF14
  Use_base('lusl')
  Use_base('luslf')
  
  // sbase := prefixFileRefName(WORK_YEAR) + 'unit'
  sbase := prefixFileRefName(arr_m[1]) + 'unit'
  R_Use(dir_exe + sbase, cur_dir + sbase, 'MOUNIT')
  
  R_Use(dir_server + 'mo_su',,'MOSU')
  R_Use(dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU')
  set relation to u_kod into MOSU
  R_Use(dir_server + 'uslugi', , 'USL')
  R_Use(dir_server + 'human_u_', , 'HU_')
  R_Use(dir_server + 'human_u', dir_server + 'human_u', 'HU')
  set relation to recno() into HU_, to u_kod into USL
  R_Use(dir_server + 'kartote_', , 'KART_')
  R_Use(dir_server + 'kartotek', , 'KART')
  set relation to recno() into KART_
  R_Use(dir_server + 'human_2', , 'HUMAN_2')
  R_Use(dir_server + 'human_', , 'HUMAN_')
  R_Use(dir_server + 'human', dir_server + 'humans', 'HUMAN')
  set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
  //
  ////////////////////////////////////////////////////////////////////
  mdate_rak := arr_m[6] + 12 // по какую дату РАК сумма к оплате 12.09.23
  ////////////////////////////////////////////////////////////////////
  R_Use(dir_server + 'mo_xml', , 'MO_XML')
  R_Use(dir_server + 'mo_rak', , 'RAK')
  set relation to kod_xml into MO_XML
  R_Use(dir_server + 'mo_raks', , 'RAKS')
  set relation to akt into RAK
  R_Use(dir_server + 'mo_raksh', , 'RAKSH')
  set relation to kod_raks into RAKS
  index on str(kod_h, 7) to (cur_dir + 'tmp_raksh') for mo_xml->DFILE <= mdate_rak
  //
  R_Use(dir_server + 'schet_', , 'SCHET_')
  R_Use(dir_server + 'schet', , 'SCHET')
  set relation to recno() into SCHET_
  ob_kol := 0
  go top
  do while !eof()
    fl := .f.
    if schet_->IS_DOPLATA == 0 .and. !empty(val(schet_->smo)) .and. schet_->NREGISTR == 0 // только зарегистрированные
      @ maxrow(), 0 say padr(alltrim(schet_->NSCHET) + ' от ' + date_8(schet_->DSCHET), 27) color 'W/R'
      // дата регистрации
      mdate := date_reg_schet()
      // дата отчетного периода
      mdate1 := stod(strzero(schet_->nyear, 4) + strzero(schet_->nmonth, 2) + '25') // !!! 
      //
      // 2023 год
        k := 6 // дата регистрации по 6.10.23
      //
      fl := between(mdate, arr_m[5], arr_m[6] + k) .and. between(mdate1, arr_m[5], arr_m[6]) // !!отч.период 2022 год
    endif
    if fl
      select HUMAN
      find (str(schet->kod, 6))
      do while human->schet == schet->kod .and. !eof()
        UpdateStatus()
        if inkey() == K_ESC
          fl_exit := .t.
          exit
        endif
        // по умолчанию оплачен, если даже нет РАКа
        koef := 1 ; k := j := 0
        select RAKSH
        find (str(human->kod, 7))
        do while human->kod == raksh->kod_h .and. !eof()
          if !empty(raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP)
            ++j
          endif
          k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          skip
        enddo
        if !empty(round(k, 2))
          if empty(human->cena_1) // скорая помощь
            koef := 0
          elseif round_5(human->cena_1, 2) <= round_5(k, 2) // полное снятие
            koef := 0
          else // частичное снятие
            koef := (human->cena_1-k)/human->cena_1
          endif
          select RAKSH
          find (str(human->kod, 7))
          //my_debug(,str(human->kod, 7))
          do while human->kod == raksh->kod_h .and. !eof()
            if !empty(raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP)
              select TMPF14
              append blank
              tmpf14->KOD_XML   := rak->kod_xml
              tmpf14->SCHET     := schet->kod
              tmpf14->KOD_RAK   := raks->AKT
              tmpf14->KOD_RAKS  := raksh->KOD_RAKS
              tmpf14->KOD_RAKSH := raksh->(recno())
              tmpf14->KOD_H     := human->kod
              tmpf14->kol_akt   := j
              tmpf14->usl_ok    := iif(schet_->BUKVA == 'T', 5, human_->USL_OK)
              //my_debug(,' Сумма '+ str(raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP))
            endif
            select RAKSH
            skip
          enddo
        endif
        if koef > 0
          afill(fl_pol1, 0)
          is_vmp := (human_2->VMP == 1)
          is_trudosp := f_starshe_trudosp(human->POL, human->DATE_R, human->n_data, 4) // настроен на 2023-2024 год
          is_reabili := (human_->PROFIL == 158)
          is_rebenok := (human->VZROS_REB > 0)
          is_inogoro := (int(val(schet_->smo)) == 34)
          igs := iif(f_is_selo(kart_->gorod_selo,kart_->okatog), 3, 2)
          if !(fl_stom := (schet_->BUKVA == 'T')) // стоматология в отдельной таблице
            arr_pril5[1, igs] += round(human->cena_1 * koef, 2)
          endif
          if schet_->BUKVA == 'K' // отдельные медицинские услуги учитываем только суммой
            arr_pol1[6, 4] += round(human->cena_1 * koef, 2)
            if is_inogoro
              arr_pol1[6, 5] += round(human->cena_1 * koef, 2)
            endif
            // теперь делим по услугам
            svp := space(5)
            vr_rec := hu->(recno())
            select HU
            find (str(human->kod, 7))
            do while hu->kod == human->kod .and. !eof()
              lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
              if is_usluga_TFOMS(usl->shifr, lshifr1, human->k_data, , , , , @svp)
                 lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
              endif
              if padr(alltrim(lshifr), 5) == '60.4.'
                 // KT
                arr_pol3000[ 23, 4] += round(hu->stoim_1 * koef, 2)
                arr_pol3000[ 23, 2] += 1
                arr_pol1[6, 2] += 1
                if is_inogoro
                  arr_pol3000[ 23, 5] += round(hu->stoim_1 * koef, 2)
                  arr_pol3000[ 23, 3] += 1
                  arr_pol1[6, 3] += 1
                endif
              elseif padr(alltrim(lshifr), 5) == '60.5.'
                // МРТ
                arr_pol3000[ 24, 4] += round(hu->stoim_1 * koef, 2)
                arr_pol3000[ 24, 2] += 1
                arr_pol1[6, 2] += 1
                if is_inogoro
                  arr_pol3000[ 24, 5] += round(hu->stoim_1 * koef, 2)
                  arr_pol3000[ 24, 3] += 1
                  arr_pol1[6, 3] += 1
                endif
              elseif padr(alltrim(lshifr), 5) == '60.6.'
                // УЗИ ССС
                arr_pol3000[ 25, 4] += round(hu->stoim_1 * koef, 2)
                arr_pol3000[ 25, 2] += 1
                arr_pol1[6, 2] += 1
                if is_inogoro
                  arr_pol3000[ 25, 5] += round(hu->stoim_1 * koef, 2)
                  arr_pol3000[ 25, 3] += 1
                  arr_pol1[6, 3] += 1
                endif
              elseif padr(alltrim(lshifr), 5) == '60.7.'
                // ' Эндоскопические диагностические исследования'
                arr_pol3000[ 26, 4] += round(human->cena_1 * koef, 2)
                arr_pol3000[ 26, 2] += 1
                arr_pol1[6, 2] += 1
                if is_inogoro
                  arr_pol3000[ 26, 5] += round(human->cena_1 * koef, 2)
                  arr_pol3000[ 26, 3] += 1
                  arr_pol1[6, 3] += 1
                endif
              elseif padr(alltrim(lshifr), 5) == '60.9.'
                // ' Молекулярно-генетические исследования'
                arr_pol3000[ 27, 4] += round(human->cena_1 * koef, 2)
                arr_pol3000[ 27, 2] += 1
                arr_pol1[6, 2] += 1
                if is_inogoro
                  arr_pol3000[ 27, 5] += round(human->cena_1 * koef, 2)
                  arr_pol3000[ 27, 3] += 1
                  arr_pol1[6, 3] += 1
                endif
              elseif padr(alltrim(lshifr), 5) == '60.8.'
                // ' Гистологические исследования'
                arr_pol3000[ 28, 4] += round(human->cena_1 * koef, 2)
                arr_pol3000[ 28, 2] += 1
                arr_pol1[6, 2] += 1
                if is_inogoro
                  arr_pol3000[ 28, 5] += round(human->cena_1 * koef, 2)
                  arr_pol3000[ 28, 3] += 1
                  arr_pol1[6, 3] += 1
                endif
              elseif padr(alltrim(lshifr), 8) == '4.17.785' .or.;
                     padr(alltrim(lshifr), 8) == '4.17.786'
                //' Тестирование на COVID-19'
                arr_pol3000[ 29, 4] += round(human->cena_1 * koef, 2)
                arr_pol3000[ 29, 2] += 1
                arr_pol1[6, 2] += 1
                if is_inogoro
                  arr_pol3000[ 29, 5] += round(human->cena_1 * koef, 2)
                  arr_pol3000[ 29, 3] += 1
                  arr_pol1[6, 3] += 1
                endif
              endif
              skip
            enddo
            select HU
            goto (vr_rec)
            select HUMAN
          endif
          //
          if schet_->BUKVA != 'K' // отдельные медицинские услуги учитываем только суммой
            arr_pol1[6, 4] += round(human->cena_1 * koef, 2)
            if is_inogoro
              arr_pol1[6, 5] += round(human->cena_1 * koef, 2)
            endif
            // теперь делим по услугам
            svp := space(5)
            vr_rec := hu->(recno())
            select HU
            find (str(human->kod, 7))
            do while hu->kod == human->kod .and. !eof()
              lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
              if is_usluga_TFOMS(usl->shifr, lshifr1, human->k_data, , , , , @svp)
                 lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
              endif
              if eq_any(padr(alltrim(lshifr), 8), ;
                            '2.79.34 ','2.79.37 ','2.79.38 ', ;
                            '2.79.49 ','2.79.50 ','2.79.63 ', ;
                            '2.79.64 ','2.88.35 ','2.88.36 ', ;
                            '2.79.37 ','2.88.50 ','2.88.54 ', ;
                            '2.88.116','2.88.117','2.88.118')
                //'из строки 06 - посещения работников, со средним м/о'
                arr_pol3000[ 12, 4] += round(human->cena_1 * koef, 2)
                arr_pol3000[ 12, 2] += 1
                if is_inogoro
                  arr_pol3000[ 12, 5] += round(human->cena_1 * koef, 2)
                  arr_pol3000[ 12, 3] += 1
                endif
              elseif padr(alltrim(lshifr), 8) == '2.88.107'
                //'из строки 06 - посещения амбулаторных ОНКО центров'
                arr_pol3000[ 13, 4] += round(human->cena_1 * koef, 2)
                arr_pol3000[ 13, 2] += 1
                if is_inogoro
                  arr_pol3000[ 13, 5] += round(human->cena_1 * koef, 2)
                  arr_pol3000[ 13, 3] += 1
                endif
              elseif eq_any(padr(alltrim(lshifr), 8), ;
                            '2.88.24 ','2.88.25 ','2.88.104', ;
                            '2.81.24 ','2.81.25 ','2.81.26 ', ;
                            '2.81.27 ','2.81.28 ','2.81.29 ', ;
                            '2.81.30 ','2.81.31 ','2.81.32 ', ;
                            '2.81.33 ','2.81.45 ','2.88.104')
                //'из строки 12 - посещения по специальности 'онкология''
                arr_pol3000[ 14, 4] += round(human->cena_1 * koef, 2)
                arr_pol3000[ 14, 2] += 1
                if is_inogoro
                  arr_pol3000[ 14, 5] += round(human->cena_1 * koef, 2)
                  arr_pol3000[ 14, 3] += 1
                endif
              elseif eq_any(left(lshifr, 5),'2.79.','2.76.')
                // 'посещения с другими целями, всего'
                 if eq_any(padr(alltrim(lshifr), 7), ;
                            '2.79.34','2.79.37','2.79.38', ;
                            '2.79.49','2.79.50','2.79.59', ;
                            '2.79.60','2.79.61','2.79.62', ;
                            '2.79.63','2.79.64')
                 else
                   arr_pol3000[ 16, 4] += round(human->cena_1 * koef, 2)
                   arr_pol3000[ 16, 2] += 1
                   if is_inogoro
                     arr_pol3000[ 16, 5] += round(human->cena_1 * koef, 2)
                     arr_pol3000[ 16, 3] += 1
                   endif
                 endif
              elseif eq_any(padr(alltrim(lshifr), 8), ;
                            '2.88.52 ','2.88.53 ','2.88.55 ', ;
                            '2.88.56 ','2.88.57 ','2.88.58 ', ;
                            '2.88.59 ','2.88.60 ','2.88.61 ', ;
                            '2.88.62 ','2.88.63 ','2.88.64 ', ;
                            '2.88.65 ','2.88.66 ','2.88.67 ', ;
                            '2.88.68 ','2.88.69 ','2.88.70 ', ;
                            '2.88.71 ','2.88.72 ','2.88.73 ', ;
                            '2.88.74 ','2.88.75 ','2.88.76 ', ;
                            '2.88.77 ','2.88.106','2.88.110')
                 //'из строки 06 посещения с целью диспансерного наблюдения'
                  arr_pol3000[ 7, 4] += round(human->cena_1 * koef, 2)
                  arr_pol3000[ 7, 2] += 1
                  if is_inogoro
                    arr_pol3000[ 7, 5] += round(human->cena_1 * koef, 2)
                    arr_pol3000[ 7, 3] += 1
                  endif
              endif
              skip
            enddo
            select HU
            goto (vr_rec)
            select HUMAN
          endif
          //
          is_dializ := .f.
          is_z_sl := .f.
          is_ekstra := .f.
          is_centr_z := .f.
          is_s_obsh := .f.
          is_disp_nabluden := .f.
          is_kt := .f.
          is_school := .f.
          is_prvs_206 := (ret_new_prvs(human_->prvs) == 206) // лечебное дело
          kol_2_3 := kol_2_6 := kol_2_60 := kol_sr := kol_2_sr := 0
          isp := 1
          is_sred_stom := .f.
          ds_spec := ds1_spec := kol_stom := kol_dializ := 0
          vid_vp := 0 // по умолчанию профилактика
          d2_year := year(human->k_data)
          if human_->USL_OK == 1 // стационар
            //
          elseif human_->USL_OK == 2 // дневной стационар
            is_ekstra := (human_->PROFIL == 137)
          elseif human_->USL_OK == 3 // поликлиника
            vid_vp := -1
          elseif human_->USL_OK == 4 // скорая помощь
            i := int(val(substr(human_->FORMA14, 1, 1)))
            isp := iif(i == 0, 1, 2)
          endif
          afillall(tfoms_pz, 0)
          ap := {}
          arr_usl := {} ; au := {}
          arr_full_usl := {}
          lvidpom := 1
          lvidpoms := ''
          svp := space(5)
          select HU
          find (str(human->kod, 7))
          do while hu->kod == human->kod .and. !eof()
            lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
            if is_usluga_TFOMS(usl->shifr, lshifr1, human->k_data, , , , , @svp)
              lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
              aadd(arr_full_usl,lshifr)
              ta := f14tf_nastr(@lshifr, , d2_year)
              lshifr := alltrim(lshifr)
              if left(lshifr, 7) == '60.10.3'
                //my_debug(,round(hu->stoim_1 * koef, 2))   
              endif  
              aadd(au, {lshifr, hu->kol_1, round(hu->stoim_1 * koef, 2), 0, 0, hu->kol_1})
              i16 := 0
              dbSelectArea(lal)
              find (padr(lshifr, 10))
              if found() .and. !empty(&lal.->unit_code)
                select MOUNIT    // !!! ВНИМАНИЕ
                find (str(&lal.->unit_code, 3))
                if found() .and. mounit->pz > 0
                  if (i16 := mounit->ii) > 0
                    // j1 := glob_array_PZ_21[i16, 1] 
                    // nameArr := 'glob_array_PZ_' + last_digits_year(human->k_data)
                    // j1 := &nameArr.[i16, 1]
                    // funcGetPZ := 'get_array_PZ_' + last_digits_year(human->k_data) + '()'
                    nameArr := get_array_PZ( human->k_data )
                    j1 := nameArr[i16, 1]

                    if eq_any(j1, 68)  // 75 убрал - это бывшая стом //09.07.23
                      vid_vp := 0 // Посещение профилактическое
                    elseif eq_any(j1, 69) // 76 убрал - это бывшая стом//09.07.23
                      vid_vp := 1 // в неотложной форме
                    elseif eq_any(j1, 70, 91, 92)  // 77 убрал - это бывшая стом //09.07.23
                      vid_vp := 2 // обращения с лечебной целью
                    elseif j1 == 71
                      is_centr_z := .t.
                      vid_vp := 0 // Посещение профилактическое Центра здоровья
                    elseif eq_any(j1, 73, 74, 87, 88, 89, 90, 59, 78)  // т.е. 261, 262, 318, 319, 320, 321, 511, 513   //09.07.23
                      vid_vp := 0 // комплексное посещение при диспансеризации
                      is_z_sl := .t.
                      fl_pol3000_DVN2 := .F.
                      // вставить деление на ПРОФОСМОТР
                      fl_pol3000_DVN2 := .T.
                      if j1 == 74 // ДВН - 2 этап
                         fl_pol3000_DVN2 := .F.
                      endif
                      //
                    elseif j1 == 64 .or. between(j1, 79, 86) .or. between(j1, 93, 98) // исследования
                      is_kt := .t.
                      ds1_spec := 1
                      vid_vp := 2 // с лечебной целью
                    elseif eq_any(j1, 63, 65, 67)
                      is_dializ := .t.
                    // elseif   57 - реабилитация
                    elseif j1 == 58 // 583 - школа сах диабета - посещение профилактическое
                      vid_vp := 0 // Посещение профилактическое
                      is_school := .t.
                    endif
                  endif
                endif
                select HU
              endif
              if human_->USL_OK == 1 // стационар
                if left(lshifr, 5) == '1.11.'
                  kol_dializ += hu->kol_1 // койко-день
                endif
              elseif human_->USL_OK == 2  // дневной стационар
                if left(lshifr, 5) == '60.3.'
                  is_dializ := .t.
                  kol_dializ += hu->kol_1
                endif
                aadd(arr_usl,lshifr)
                //aadd(arr_full_usl,lshifr)
                if !empty(svp) .and. ',' $ svp
                  lvidpoms := svp
                endif
                if (i := ret_vid_pom(1, lshifr, human->k_data)) > 0
                  lvidpom := i
                endif
              elseif eq_any(left(lshifr, 5), '2.78.', '2.89.') // обращения с лечебной целью
                if  left(lshifr, 8) =='2.78.107' // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                 // диспансерное наблюдение  
                 is_disp_nabluden := .t.
                endif 
                  vid_vp := 2 // обращения с лечебной целью
                  if lshifr == '2.78.2'
                    is_s_obsh := .t. // врачи общей практики
                  elseif eq_any(lshifr, '2.78.36', '2.78.39', '2.78.40')
                    kol_sr += hu->kol_1
                  endif
                  if left(lshifr, 5) == '2.89.'
                    ds_spec := 1 // первичная специализированная
                    is_reabili := .t.
                  elseif !eq_any(human_->PROFIL, 97, 57, 68, 3, 42, 85, 87)
                    ds_spec := 1
                  endif
                
                // признак онкологии
                //if eq_any(lshifr, '2.78.19', '2.78.45', '2.78.87', '2.78.90', '2.78.91')
                //
                //endif
              endif
              if f_is_zak_sl_vr(lshifr)
                is_z_sl := .t.
              endif
              //
              if eq_any(left(lshifr, 4), '2.6.', '2.60')
                kol_stom += hu->kol_1
              endif
              // онкология
              //if eq_any(left(lshifr, 4), '2.6.', '2.60')
              //  kol_stom += hu->kol_1
              //endif
  
              if eq_any(lshifr, '2.3.3', '2.3.4', '2.60.3', '2.60.4') // фельдшерские приёмы
                fl_pol1[15] := -1
              endif
              if eq_any(lshifr, '2.78.60', '2.79.63', '2.79.64', '2.80.38', '2.88.50') // зубной врач (средний мед.персонал)
                fl_pol1[15] := -1
                is_sred_stom := .t.
              endif
              if left(lshifr, 5) == '2.80.' .and. hu->KOL_RCP < 0 // посещения в неотложной форме на дому
                fl_pol1[12] += hu->kol_1
              endif
              if left(lshifr, 5) == '2.88.' .and. hu->KOL_RCP < 0 // разовое посещение на дому
                fl_pol1[7] += hu->kol_1
              endif
              //
              for j := 1 to len(ta)
                k := ta[j, 1]
                mkol1 := 0
                if between(k, 1, 10)
                  if ta[j, 2] == 1 // законченный случай стационара
                    mkol := human->k_data - human->n_data  // койко-день
                  elseif ta[j, 2] == 0
                    mkol := hu->kol_1
                  else
                    mkol := 0
                    mkol1 := hu->kol_1
                  endif
                  muet := 0
                  msum := round(hu->stoim_1 * koef, 2)
                  ii := 0
                  is_obsh := .f.
                  if k == 2 // стационар
                    ii := 1
                  elseif k == 1 // поликлиника
                    ii := 2
                    aadd(arr_usl,left(lshifr, 5))
                    if left(lshifr, 2) == '2.'
                      if left(lshifr, 4) == '2.3.'
                        kol_2_3 += hu->kol_1
                        if eq_any(lshifr,'2.3.3','2.3.4')
                          kol_2_sr += hu->kol_1
                        endif
                      elseif left(lshifr, 4) == '2.6.'
                        kol_2_6 += hu->kol_1
                      elseif left(lshifr, 5) == '2.60.'
                        kol_2_60 += hu->kol_1
                        if eq_any(lshifr,'2.60.3','2.60.4')
                          kol_2_sr += hu->kol_1
                        endif
                      elseif left(lshifr, 5) == '2.76.' // центр здоровья
                        vid_vp := 0 // Посещение профилактическое
                        //!!!
                        arr_pol3000[ 11, 4] := round(human->cena_1 * koef, 2)
                        arr_pol3000[ 11, 2] := 1
                        if is_inogoro
                          arr_pol3000[ 11, 5] := round(human->cena_1 * koef, 2)
                          arr_pol3000[ 11, 3] := 1
                        endif
                      elseif left(lshifr, 5) == '2.92.' // школа сахарного диабета
                        vid_vp := 0 // Посещение профилактическое
                        //!!!
                        arr_pol3000[ 11, 4] := round(human->cena_1 * koef, 2)
                        arr_pol3000[ 11, 2] := 1
                        if is_inogoro
                          arr_pol3000[ 11, 5] := round(human->cena_1 * koef, 2)
                          arr_pol3000[ 11, 3] := 1
                        endif 
                      elseif left(lshifr, 5) == '2.79.' // посещение с профилактической целью
                        vid_vp := 0 // Посещение профилактическое
                        if !eq_any(human_->PROFIL, 97, 57, 68, 3, 42, 85, 87)
                          ds1_spec := 1 // первичная специализированная
                        endif
                        if eq_any(lshifr,'2.79.2','2.79.45')
                          is_obsh := .t.
                        endif
                        if eq_any(lshifr,'2.79.34','2.79.37','2.79.38','2.79.49','2.79.50')
                          kol_sr += hu->kol_1
                        endif
                      elseif left(lshifr, 5) == '2.80.' // в неотложной форме
                        vid_vp := 1 // в неотложной форме
                        if !eq_any(human_->PROFIL, 97, 57, 68, 3, 42, 85, 87, 160)
                          ds1_spec := 1
                        endif
                        if lshifr == '2.80.2'
                          is_obsh := .t.
                        endif
                        if eq_any(lshifr,'2.80.19','2.80.22','2.80.23','2.80.27')
                          kol_sr += hu->kol_1
                        endif
                      elseif left(lshifr, 5) == '2.81.' // консультации специалистов
                        vid_vp := 0 // Посещение профилактическое
                        if !eq_any(human_->PROFIL, 68, 97)
                          ds1_spec := 1
                        endif
                      elseif left(lshifr, 5) == '2.82.' // Посещение в приёмном покое (в неотложной форме)
                        vid_vp := 1 // в неотложной форме
                        if !eq_any(human_->PROFIL, 57, 68, 97)
                          ds1_spec := 1
                        endif
                      elseif left(lshifr, 5) == '2.83.' // диспансеризация детей-сирот
                        if lshifr == '2.83.15'
                          is_obsh := .t.
                        endif
                      elseif left(lshifr, 5) == '2.88.' // разовое посещение
                        vid_vp := 0 // Посещение профилактическое
                        if !eq_any(human_->PROFIL, 97, 57, 68, 3, 42, 85, 87)
                          ds1_spec := 1
                        endif
                        if eq_any(lshifr,'2.88.3','2.88.53','2.88.79')
                          is_obsh := .t.
                        endif
                        if eq_any(lshifr,'2.88.35','2.88.36','2.88.37')
                          kol_sr += hu->kol_1
                        endif
                      endif
                    elseif left(lshifr, 5) == '60.3.'
                      is_dializ := .t.
                    endif
                    if i16 > 0
                      aadd(ap, {lshifr, iif(empty(mkol),mkol1,mkol),is_obsh})
                    endif
                  elseif k == 7 // отд.мед.услуги
                    ii := 2 // в поликлинику
                    mkol := 0  // участвует не количеством, а только суммой
                    is_kt := .t.
                    ds1_spec := 1
                  elseif k == 8 // СМП
                    ii := 5
                  elseif eq_any(k, 3, 4, 5) // дневной стационар
                    ii := 4
                    if left(lshifr, 5) == '55.1.'
                      //
                    else
                      mkol := 0
                    endif
                  endif
                  if is_dializ
                    if human_->USL_OK == 1 // стационар
                      ii := 1
                    elseif human_->USL_OK == 2 // дневной стационар
                      ii := 4
                    elseif human_->USL_OK == 3 // поликлиника
                      ii := 2
                      mkol := 1
                      ds_spec := ds1_spec := 1
                      vid_vp := 2 // по поводу заболевания
                    endif
                  endif
                  if fl_stom // стоматология
                    //
                  elseif ii > 0
                    tfoms_pz[ii, 1] := 1
                    tfoms_pz[ii, 2] += mkol
                    tfoms_pz[ii, 3] += msum
                    if is_vmp
                      tfoms_pz[ii, 9] := 1
                      tfoms_pz[ii, 10] += mkol
                      tfoms_pz[ii, 11] += msum
                    endif
                    if ii == 2 // поликлиника
                      if is_obsh
                        tfoms_pz[ii, 7] += mkol
                        tfoms_pz[ii, 8] += msum
                        if ds1_spec == 1
                          tfoms_pz[ii, 9] += mkol
                          tfoms_pz[ii, 10] += msum
                        endif
                      else
                        if ds1_spec == 1
                          tfoms_pz[ii, 5] += mkol
                          tfoms_pz[ii, 6] += msum
                        endif
                      endif
                    endif
                  endif
                endif
              next j
            endif
            select HU
            skip
          enddo
          if kol_dializ > 0
            tfoms_pz[ii, 2] := kol_dializ // заменяем на кол-во диализных процедур
          endif
          ta := {}
          if fl_stom // стоматология
            tfoms_pz[1, 1] := 0
            tfoms_pz[2, 1] := 0
            tfoms_pz[3, 1] := 1
            tfoms_pz[4, 1] := 0
            tfoms_pz[5, 1] := 0
          endif
          do case
            // стационар
            case tfoms_pz[1, 1] > 0
              tfoms_pz[1, 2] := kol_dializ
              if (i := ascan(arr_profil, {|x| x[1] == human_->PROFIL })) == 0
                aadd(arr_profil, {human_->PROFIL, 0, 0, 0, 0}) ; i := len(arr_profil)
              endif
              if human->ishod == 88 // это 1-й л/у в двойном случае
                tfoms_pz[1, 1] := 0
              else
                arr_profil[i, 2] ++
              endif
              arr_profil[i, 3] += round(human->cena_1 * koef, 2)
              if is_inogoro
                arr_profil[i, 4] ++ ; arr_profil[i, 5] += round(human->cena_1 * koef, 2)
              endif
              arr_pril5[15,igs] += tfoms_pz[1, 2] // 'Стационар - койко-дней'
              arr_pril5[16,igs] += tfoms_pz[1, 1] // 'Стационар - случаев госпитализации'
              arr_pril5[17,igs] += tfoms_pz[1, 3] // 'Стационар - руб.'
              if is_vmp
                arr_pril5[18,igs] += tfoms_pz[1, 2] // Стац(ВМП) - койко-дней'
                arr_pril5[19,igs] += tfoms_pz[1, 1] // Стац(ВМП) - случаев госпитализации'
                arr_pril5[20,igs] += tfoms_pz[1, 3] // Стац(ВМП) - руб.'
              endif
              aadd(ta, { 5, tfoms_pz[1, 1], tfoms_pz[1, 1], tfoms_pz[1, 9], tfoms_pz[1, 3], tfoms_pz[1, 3], tfoms_pz[1, 11]})
              aadd(ta, {10, tfoms_pz[1, 2], tfoms_pz[1, 2], tfoms_pz[1, 10]})
              if is_rebenok
                aadd(ta, { 6, tfoms_pz[1, 1], tfoms_pz[1, 1], tfoms_pz[1, 9], tfoms_pz[1, 3], tfoms_pz[1, 3], tfoms_pz[1, 11]})
                aadd(ta, {11, tfoms_pz[1, 2], tfoms_pz[1, 2], tfoms_pz[1, 10]})
              endif
              if is_trudosp
                aadd(ta, { 7, tfoms_pz[1, 1], tfoms_pz[1, 1], tfoms_pz[1, 9], tfoms_pz[1, 3], tfoms_pz[1, 3], tfoms_pz[1, 11]})
                aadd(ta, {12, tfoms_pz[1, 2], tfoms_pz[1, 2], tfoms_pz[1, 10]})
              endif
              if is_reabili
                arr_pril5[21,igs] += tfoms_pz[1, 2] // 'Стац(реабил) - койко-дней'
                arr_pril5[22,igs] += tfoms_pz[1, 1] // 'Стац(реабил) - случаев госпитализации'
                arr_pril5[23,igs] += tfoms_pz[1, 3] // 'Стац(реабил) - руб.'
                aadd(ta, { 8, tfoms_pz[1, 1], tfoms_pz[1, 1], tfoms_pz[1, 9], tfoms_pz[1, 3], tfoms_pz[1, 3], tfoms_pz[1, 11]})
                aadd(ta, {13, tfoms_pz[1, 2], tfoms_pz[1, 2], tfoms_pz[1, 10]})
              endif
              if is_inogoro
                aadd(ta, { 9, tfoms_pz[1, 1], tfoms_pz[1, 1], tfoms_pz[1, 9], tfoms_pz[1, 3], tfoms_pz[1, 3], tfoms_pz[1, 11]})
                aadd(ta, {14, tfoms_pz[1, 2], tfoms_pz[1, 2], tfoms_pz[1, 10]})
              endif
            // поликлиника
            case tfoms_pz[2, 1] > 0
              arr_pril5[9,igs] += round(human->cena_1 * koef, 2) // 'Всего расходов на амб.помощь'
              if is_kt // для КТ обнуляем количество
                tfoms_pz[ii, 1] := tfoms_pz[ii, 2] := tfoms_pz[ii, 5] := tfoms_pz[ii, 7] := tfoms_pz[ii, 9] := 0
              elseif is_dializ // перит.диализ
                vid_vp := 2 // по поводу заболевания
                ds_spec := 1
              endif
              if kol_2_60 > 0 .and. ascan(arr_usl,'2.78.') > 0
                arr_pril5[8,igs] += kol_2_60 // 'Всего посещений'
                ////////////////////////////////////////////////
              endif
              if kol_2_60 > 0 .and. ascan(arr_usl,'2.78.') > 0
                arr_pril5[8,igs] += kol_2_60 // 'Всего посещений'
                ////////////////////////////////////////////////
              endif
              // онкология в т.3000
              if kol_2_60 > 0 //.and. ;
                if eq_ascan(arr_full_usl,'2.78.19','2.78.45','2.78.87','2.78.90','2.78.91')
                  arr_pol3000[ 21, 4] += round(human->cena_1 * koef, 2)
                  arr_pol3000[ 21, 2] += 1
                  if is_inogoro
                    arr_pol3000[ 21, 5] += round(human->cena_1 * koef, 2)
                    arr_pol3000[ 21, 3] += 1
                  endif
                endif
              endif
              if schet_->BUKVA == 'O'  // диспансеризация 2-й этап
                if ascan(arr_usl,'2.84.') > 0 .or. ascan(arr_full_usl,'56.1.723') > 0
                  arr_pol3000[ 8, 4] += round(human->cena_1 * koef, 2)
                  arr_pol3000[ 8, 2] += 1
                  if is_inogoro
                    arr_pol3000[ 8, 5] += round(human->cena_1 * koef, 2)
                    arr_pol3000[ 8, 3] += 1
                  endif
                endif
              endif
              //
              if kol_2_6 > 0 .and. ascan(arr_usl,'2.89.') > 0
                arr_pril5[8,igs] += kol_2_6 // 'Всего посещений'
              endif
              fl := eq_any(schet_->BUKVA,'A','K')
              if schet_->BUKVA == 'K'
                vid_vp := 2 // по поводу заболевания
                ds1_spec := 1
                sum_k += tfoms_pz[2, 3]
                if is_rebenok
                  sum_kd += tfoms_pz[2, 3]
                endif
                if is_trudosp
                  sum_kt += tfoms_pz[2, 3]
                endif
                if is_inogoro
                  sum_ki += tfoms_pz[2, 3]
                endif
              endif
              if vid_vp == 1 // в неотложной форме
                fl_pol1[11] += tfoms_pz[2, 2]
                arr_pril5[ 8,igs] += tfoms_pz[2, 2] // 'Всего посещений'
                arr_pril5[13,igs] += tfoms_pz[2, 2] // 'Число посещений по неотл.мед.помощи'
                arr_pril5[14,igs] += tfoms_pz[2, 3] // 'руб.'
                aadd(ta, {22, tfoms_pz[2, 2], tfoms_pz[2, 2], tfoms_pz[2, 5], tfoms_pz[2, 3], tfoms_pz[2, 3], tfoms_pz[2, 6]})
                aadd(ta, {23, tfoms_pz[2, 7], tfoms_pz[2, 7], tfoms_pz[2, 9], tfoms_pz[2, 8], tfoms_pz[2, 8], tfoms_pz[2, 10]})
                if fl
                   arr_pol[22] += tfoms_pz[2, 3]
                  arr_pol[23] += tfoms_pz[2, 8]
                endif
                if is_rebenok
                  aadd(ta, {24, tfoms_pz[2, 2], tfoms_pz[2, 2], tfoms_pz[2, 5], tfoms_pz[2, 3], tfoms_pz[2, 3], tfoms_pz[2, 6]})
                  if fl
                    arr_pol[24] += tfoms_pz[2, 3]
                  endif
                endif
                if is_trudosp
                  aadd(ta, {25, tfoms_pz[2, 2], tfoms_pz[2, 2], tfoms_pz[2, 5], tfoms_pz[2, 3], tfoms_pz[2, 3], tfoms_pz[2, 6]})
                  if fl
                    arr_pol[25] += tfoms_pz[2, 3]
                  endif
                endif
                if is_inogoro
                  aadd(ta, {26, tfoms_pz[2, 2], tfoms_pz[2, 2], tfoms_pz[2, 5], tfoms_pz[2, 3], tfoms_pz[2, 3], tfoms_pz[2, 6]})
                  if fl
                    arr_pol[26] += tfoms_pz[2, 3]
                  endif
                endif
              elseif vid_vp == 2 // по поводу заболевания
                fl_pol1[13] := -1
                if is_disp_nabluden
                  arr_pril5[32,igs] += tfoms_pz[2, 1] // 'Число обращений по поводу заболевания'
                else  
                  arr_pril5[10,igs] += tfoms_pz[2, 1] // 'Число обращений по поводу заболевания'
                  aadd(ta, {27, tfoms_pz[2, 1], tfoms_pz[2, 1], iif(ds_spec == 1, tfoms_pz[2, 1], 0), tfoms_pz[2, 3], tfoms_pz[2, 3], iif(ds_spec == 1.or.ds1_spec==1, tfoms_pz[2, 3], 0)})
                  if fl
                    arr_pol[27] += tfoms_pz[2, 3]
                  endif
                  if is_s_obsh
                    aadd(ta, {28, tfoms_pz[2, 1], tfoms_pz[2, 1], iif(ds_spec == 1, tfoms_pz[2, 1], 0), tfoms_pz[2, 3], tfoms_pz[2, 3], iif(ds_spec == 1.or.ds1_spec==1, tfoms_pz[2, 3], 0)})
                    if fl
                      arr_pol[28] += tfoms_pz[2, 3]
                    endif
                  endif
                  if is_rebenok
                    aadd(ta, {29, tfoms_pz[2, 1], tfoms_pz[2, 1], iif(ds_spec == 1, tfoms_pz[2, 1], 0), tfoms_pz[2, 3], tfoms_pz[2, 3], iif(ds_spec == 1.or.ds1_spec==1, tfoms_pz[2, 3], 0)})
                    if fl
                      arr_pol[29] += tfoms_pz[2, 3]
                    endif
                  endif
                  if is_trudosp
                    aadd(ta, {30, tfoms_pz[2, 1], tfoms_pz[2, 1], iif(ds_spec == 1, tfoms_pz[2, 1], 0), tfoms_pz[2, 3], tfoms_pz[2, 3], iif(ds_spec == 1.or.ds1_spec==1, tfoms_pz[2, 3], 0)})
                    if fl
                      arr_pol[30] += tfoms_pz[2, 3]
                    endif
                 endif
                  if is_reabili
                    aadd(ta, {31, tfoms_pz[2, 1], tfoms_pz[2, 1], iif(ds_spec == 1, tfoms_pz[2, 1], 0), tfoms_pz[2, 3], tfoms_pz[2, 3], iif(ds_spec == 1.or.ds1_spec==1, tfoms_pz[2, 3], 0)})
                    if fl
                      arr_pol[31] += tfoms_pz[2, 3]
                    endif
                  endif
                  if is_inogoro
                    aadd(ta, {32, tfoms_pz[2, 1], tfoms_pz[2, 1], iif(ds_spec == 1, tfoms_pz[2, 1], 0), tfoms_pz[2, 3], tfoms_pz[2, 3], iif(ds_spec == 1.or.ds1_spec==1, tfoms_pz[2, 3], 0)})
                    if fl
                     arr_pol[32] += tfoms_pz[2, 3]
                     endif
                  endif
                endif  
              elseif vid_vp == 0 // профилактика
                tfoms_pz[2, 2] := tfoms_pz[2, 7] := tfoms_pz[2, 9] := tfoms_pz[2, 5] := 0 // обнулим количество приемов
                if eq_any(schet_->BUKVA,'O','F','R','D','U','W','Y') // диспансеризация и профосмотры + углубленная 23.01.23 
                  lshifr := 'дисп-ия' ; lkol := 1
                  if (j := ascan(arr_prof, {|x| x[1] == lshifr })) == 0
                    aadd(arr_prof, {lshifr, 0}) ; j := len(arr_prof)
                  endif
                  arr_prof[j, 2] += lkol
                  //
                  tfoms_pz[2, 2] += lkol
                  if is_prvs_206 // лечебное дело в диспансеризации
                    fl_pol1[15] += lkol
                  endif
                  // терапевт, педиатр, врач общей практики, фельдшер при диспансеризации
                  fl_pol1[3] += lkol
                  fl_pol1[4] += lkol
                  fl_pol3000_PROF := .F.
                  if eq_any(schet_->BUKVA,'F','R') // диспансеризация и профосмотры
                    fl_pol3000_PROF := .T.
         // my_debug(,str(human->kod) + '  fl_pol3000_PROF := .T.')
                  else
                    fl_pol3000_PROF := .F.
         // my_debug(,str(human->kod) + '  fl_pol3000_PROF := .F.')
                  endif
                else
                  for i := 1 to len(ap)
                    lshifr := ap[i, 1] ; lkol := ap[i, 2]
                    if (j := ascan(arr_prof, {|x| x[1] == lshifr })) == 0
                      aadd(arr_prof, {lshifr, 0}) ; j := len(arr_prof)
                    endif
                    arr_prof[j, 2] += lkol
                    //
                    tfoms_pz[2, 2] += lkol
                    if ap[i, 3] // is_obsh
                      tfoms_pz[2, 7] += lkol
                      if ds1_spec == 1
                        tfoms_pz[2, 9] += lkol
                      endif
                    else
                      if ds1_spec == 1
                        tfoms_pz[2, 5] += lkol
                      endif
                    endif
                    if eq_any(left(lshifr, 5),'2.79.','2.76.') // профилактика и центры здоровья
                      if between_shifr(lshifr,'2.79.44','2.79.50')  // патронаж
                        fl_pol1[9] += lkol
                        if eq_any(human_->profil, 49, 53, 54) // паллиативная медицинская помощь
                          fl_pol1[10] += lkol
                        endif
                      else
                        fl_pol1[3] += lkol
                      endif
                    endif
                    if eq_any(lshifr,'2.79.34','2.79.37','2.79.38','2.79.49','2.79.50', ; // фельдшерские приёмы
                                     '2.79.63','2.79.64','2.88.50', ;                    
                                     '2.80.19','2.80.22','2.80.23','2.80.27', ;
                                     '2.88.35','2.88.36','2.88.37','2.90.2')
                      fl_pol1[15] += lkol
                    endif
                    if eq_any(left(lshifr, 5),'2.88.','2.81.') // разовое посещение или консультации
                      fl_pol1[6] += lkol
                    endif
                  next
                endif
                if is_z_sl .and. tfoms_pz[2, 2] > 0
                  tfoms_pz[2, 3] := round(human->cena_1 * koef, 2)
                  if ds1_spec == 1
                    tfoms_pz[2, 6] := round(human->cena_1 * koef, 2)
                  endif
                  if is_obsh
                    tfoms_pz[2, 8] := round(human->cena_1 * koef, 2)
                    if ds1_spec == 1
                      tfoms_pz[2, 10] := round(human->cena_1 * koef, 2)
                    endif
                  endif
                endif
                if eq_any(schet_->BUKVA,'G','J','D','O','R','F','V','I','U')
                  kol_d += tfoms_pz[2, 2]
                  sum_d += tfoms_pz[2, 3]
                endif
                arr_pril5[ 8,igs] += tfoms_pz[2, 2] // 'Всего посещений'
                arr_pril5[11,igs] += tfoms_pz[2, 2] // 'Число посещений с проф.(иной) целью'
                arr_pril5[12,igs] += tfoms_pz[2, 3] // 'руб.'
                aadd(ta, {15, tfoms_pz[2, 2], tfoms_pz[2, 2], tfoms_pz[2, 5], tfoms_pz[2, 3], tfoms_pz[2, 3], tfoms_pz[2, 6]})
                aadd(ta, {16, tfoms_pz[2, 7], tfoms_pz[2, 7], tfoms_pz[2, 9], tfoms_pz[2, 8], tfoms_pz[2, 8], tfoms_pz[2, 10]})
                if fl
                  arr_pol[15] += tfoms_pz[2, 3]
                  arr_pol[16] += tfoms_pz[2, 8]
                endif
                if is_centr_z
                  aadd(ta, {17, tfoms_pz[2, 2], tfoms_pz[2, 2], tfoms_pz[2, 5], tfoms_pz[2, 3], tfoms_pz[2, 3], tfoms_pz[2, 6]})
                  if fl
                    arr_pol[17] += tfoms_pz[2, 3]
                  endif
                endif
                if is_rebenok
                  aadd(ta, {18, tfoms_pz[2, 2], tfoms_pz[2, 2], tfoms_pz[2, 5], tfoms_pz[2, 3], tfoms_pz[2, 3], tfoms_pz[2, 6]})
                  if fl
                    arr_pol[18] += tfoms_pz[2, 3]
                  endif
                  if is_centr_z
                    aadd(ta, {19, tfoms_pz[2, 2], tfoms_pz[2, 2], tfoms_pz[2, 5], tfoms_pz[2, 3], tfoms_pz[2, 3], tfoms_pz[2, 6]})
                    if fl
                      arr_pol[19] += tfoms_pz[2, 3]
                    endif
                  endif
                endif
                if is_trudosp
                  aadd(ta, {20, tfoms_pz[2, 2], tfoms_pz[2, 2], tfoms_pz[2, 5], tfoms_pz[2, 3], tfoms_pz[2, 3], tfoms_pz[2, 6]})
                  if fl
                    arr_pol[20] += tfoms_pz[2, 3]
                  endif
                endif
                if is_inogoro
                  aadd(ta, {21, tfoms_pz[2, 2], tfoms_pz[2, 2], tfoms_pz[2, 5], tfoms_pz[2, 3], tfoms_pz[2, 3], tfoms_pz[2, 6]})
                  if fl
                    arr_pol[21] += tfoms_pz[2, 3]
                  endif
                endif
              endif
            // стоматология
            case tfoms_pz[3, 1] > 0
              au_flu := {} ; muet := 0
              select MOHU
              find (str(human->kod, 7))
              do while mohu->kod == human->kod .and. !eof()
                aadd(au_flu, {mosu->shifr1, ;         // 1
                             c4tod(mohu->date_u), ;  // 2
                             mohu->profil, ;         // 3
                             mohu->PRVS, ;           // 4
                             mosu->shifr, ;          // 5
                             mohu->kol_1, ;          // 6
                             c4tod(mohu->date_u2), ; // 7
                             mohu->kod_diag})       // 8
                dbSelectArea(lalf)
                find (mosu->shifr1)
                muet += round_5(mohu->kol_1 * iif(human->vzros_reb==0, &lalf.->uetv, &lalf.->uetd), 2)
                select MOHU
                skip
              enddo
              tfoms_pz[3, 4] := muet
              ret_tip := 0
              // 1 с лечебной целью
              // 2 с профилактической целью
              // 2  -- ' -- ' -- ' -- ' -- разовое по поводу заболевания
              // 3 при оказании неотложной помощи
              ret_kol := 0
              is_2_88 := .f.
              f_vid_p_stom(au, {},,, human->k_data,@ret_tip,@ret_kol,@is_2_88,au_flu)
              do case
                case ret_tip == 1
                  vid_vp := 2 // по поводу заболевания
                  fl_pol1[13] := -1
                  fl_pol1[14] := -1
                case ret_tip == 2
                  vid_vp := 0 // профилактика
                  if is_2_88 // разовое по поводу заболевания
                    fl_pol1[6] := -1
                    fl_pol1[8] := -1
                  else
                    fl_pol1[3] := -1
                    fl_pol1[5] := -1
                  endif
                case ret_tip == 3
                  vid_vp := 1 // в неотложной форме
                  fl_pol1[11] := -1
              endcase
              tfoms_pz[3, 1] := 1
              tfoms_pz[3, 2] := ret_kol
              tfoms_pz[3, 3] := round(human->cena_1 * koef, 2)
              //из строки 06 разовые посещения в связи с заболеваниями
              //из строки 12 - посещения по специальности 'стоматология'
              // СТАВИМ НОООЛЬ
              // 'Посещения при оказании помощи в неотложной форме, всего'
              // 'из строки 21 - посещения по специальности 'стоматология''
              // 
              // 'Посещения, включенные в обращение в связи с заболеваниями'
              // 'из строки 25 - посещения по специальности 'стоматология''
              if ret_tip == 1
                arr_pol3000[ 22, 4] += round(human->cena_1 * koef, 2)
                arr_pol3000[ 22, 2] += ret_kol
                if is_inogoro
                  arr_pol3000[ 22, 5] += round(human->cena_1 * koef, 2)
                  arr_pol3000[ 22, 3] += ret_kol
                endif
              endif
              func_f14_stom(tfoms_pz[3, 3],ret_tip,ret_kol,is_2_88,is_rebenok,is_trudosp,is_inogoro,is_sred_stom)
              kol_stom := ret_kol
              kol_stom_pos += ret_kol
              // в таблицу Excel добавляются только УЕТ-ы
              aadd(ta, {45, tfoms_pz[3, 4], tfoms_pz[3, 4], tfoms_pz[3, 3], tfoms_pz[3, 3]})
            // дневной стационар
            case tfoms_pz[4, 1] > 0
              if !empty(lvidpoms)
                if !eq_ascan(arr_usl,'55.1.2','55.1.3') .or. glob_mo[_MO_KOD_TFOMS] == '801935' // ЭКО-Москва
                  lvidpoms := ret_vidpom_licensia(human_->USL_OK,lvidpoms, human_->profil) // только для дн.стационара при стационаре
                endif
                if !empty(lvidpoms) .and. !(',' $ lvidpoms)
                  lvidpom := int(val(lvidpoms))
                  lvidpoms := ''
                endif
              endif
              if !empty(lvidpoms)
                if eq_ascan(arr_usl,'55.1.1','55.1.4')
                  if '31' $ lvidpoms
                    lvidpom := 31
                  endif
                elseif eq_ascan(arr_usl,'55.1.2','55.1.3','2.76.6','2.76.7','2.81.67')
                  if eq_any(human_->PROFIL, 57, 68, 97) //терапия,педиатр,врач общ.практики
                    if '12' $ lvidpoms
                      lvidpom := 12
                    endif
                  else
                    if '13' $ lvidpoms
                      lvidpom := 13
                    endif
                  endif
                endif
              endif
              //
              if (i := ascan(arr_dn_stac, {|x| x[1] == human_->PROFIL })) == 0
                aadd(arr_dn_stac, {human_->PROFIL, 0, 0, 0, 0}) ; i := len(arr_dn_stac)
              endif
              is_onkologia := .F.
              if equalany(human_->PROFIL, 18, 60, 76)
                is_onkologia := .T.
              endif 
              if is_dializ
                lvidpom := 31 // !!!!!!!
              endif
              arr_dn_stac[i, 2] += tfoms_pz[4, 1]
              arr_dn_stac[i, 3] += tfoms_pz[4, 3]
              if lvidpom == 13
                ds_spec := 1
              elseif lvidpom == 31
                ds_spec := 2
              else
                ds_spec := 0
              endif
              if is_rebenok
                arr_dn_stac[i, 5] += tfoms_pz[4, 2]
              else
                arr_dn_stac[i, 4] += tfoms_pz[4, 2]
              endif
              if ascan(arr_usl,'55.1.3') > 0 // на дому
                arrDdn_stac[1] += tfoms_pz[4, 1]
                arrDdn_stac[2] += tfoms_pz[4, 3]
                if is_rebenok
                  arrDdn_stac[4] += tfoms_pz[4, 2]
                else
                  arrDdn_stac[3] += tfoms_pz[4, 2]
                endif
              endif
              arr_pril5[24,igs] += tfoms_pz[4, 2] // 'Дн.стац. - пациенто-дней'
              arr_pril5[25,igs] += tfoms_pz[4, 1] // 'Дн.стац. - пациентов, чел.'
              arr_pril5[26,igs] += tfoms_pz[4, 3] // 'Дн.стац. - руб.'
              aadd(ta, {50, tfoms_pz[4, 1], tfoms_pz[4, 1], iif(ds_spec == 1, tfoms_pz[4, 1], 0), iif(ds_spec==2, tfoms_pz[4, 1], 0), tfoms_pz[4, 9]})
              aadd(ta, {56-1, tfoms_pz[4, 2], tfoms_pz[4, 2], iif(ds_spec == 1, tfoms_pz[4, 2], 0), iif(ds_spec==2, tfoms_pz[4, 2], 0), tfoms_pz[4, 10]})
              if is_rebenok //52 и 57
                aadd(ta, {51, tfoms_pz[4, 1], tfoms_pz[4, 1], iif(ds_spec == 1, tfoms_pz[4, 1], 0), iif(ds_spec==2, tfoms_pz[4, 1], 0), tfoms_pz[4, 9]})
                aadd(ta, {57-1, tfoms_pz[4, 2], tfoms_pz[4, 2], iif(ds_spec == 1, tfoms_pz[4, 2], 0), iif(ds_spec==2, tfoms_pz[4, 2], 0), tfoms_pz[4, 10]})
              endif
              if is_trudosp // 54 и 59
                aadd(ta, {52, tfoms_pz[4, 1], tfoms_pz[4, 1], iif(ds_spec == 1, tfoms_pz[4, 1], 0), iif(ds_spec==2, tfoms_pz[4, 1], 0), tfoms_pz[4, 9]})
                aadd(ta, {58-1, tfoms_pz[4, 2], tfoms_pz[4, 2], iif(ds_spec == 1, tfoms_pz[4, 2], 0), iif(ds_spec==2, tfoms_pz[4, 2], 0), tfoms_pz[4, 10]})
              endif
              if is_reabili  // 55 и 60
                aadd(ta, {53, tfoms_pz[4, 1], tfoms_pz[4, 1], iif(ds_spec == 1, tfoms_pz[4, 1], 0), iif(ds_spec==2, tfoms_pz[4, 1], 0), tfoms_pz[4, 9]})
                aadd(ta, {59-1, tfoms_pz[4, 2], tfoms_pz[4, 2], iif(ds_spec == 1, tfoms_pz[4, 2], 0), iif(ds_spec==2, tfoms_pz[4, 2], 0), tfoms_pz[4, 10]})
              endif
              if is_inogoro  // 56 и 61
                aadd(ta, {55-1, tfoms_pz[4, 1], tfoms_pz[4, 1], iif(ds_spec == 1, tfoms_pz[4, 1], 0), iif(ds_spec==2, tfoms_pz[4, 1], 0), tfoms_pz[4, 9]})
                aadd(ta, {61-2, tfoms_pz[4, 2], tfoms_pz[4, 2], iif(ds_spec == 1, tfoms_pz[4, 2], 0), iif(ds_spec==2, tfoms_pz[4, 2], 0), tfoms_pz[4, 10]})
              endif
              if is_ekstra
                arr_pril5[27,igs] += tfoms_pz[4, 2] // 'Дн.стац.ЭКО - пациенто-дней'
                arr_pril5[28,igs] += tfoms_pz[4, 1] // 'Дн.стац.ЭКО - пациентов, чел.'
                arr_pril5[29,igs] += tfoms_pz[4, 3] // 'Дн.стац.ЭКО - руб.'
                arr_eko[1, 1] += tfoms_pz[4, 2]
                arr_eko[1, 2] += tfoms_pz[4, 10]
                aadd(ta, {68-3, tfoms_pz[4, 1], tfoms_pz[4, 1], 0, iif(ds_spec==2, tfoms_pz[4, 1], 0), tfoms_pz[4, 9]})
                aadd(ta, {70-3, tfoms_pz[4, 3], tfoms_pz[4, 3], 0, iif(ds_spec==2, tfoms_pz[4, 3], 0), tfoms_pz[4, 11]})
                if is_inogoro
                  arr_eko[2, 1] += tfoms_pz[4, 2]
                  arr_eko[2, 2] += tfoms_pz[4, 10]
                  aadd(ta, {69-3, tfoms_pz[4, 1], tfoms_pz[4, 1], 0, iif(ds_spec==2, tfoms_pz[4, 1], 0), tfoms_pz[4, 9]})
                  aadd(ta, {71-3, tfoms_pz[4, 3], tfoms_pz[4, 3], 0, iif(ds_spec==2, tfoms_pz[4, 3], 0), tfoms_pz[4, 11]})
                endif
              endif
              aadd(ta, {62-2, tfoms_pz[4, 3], tfoms_pz[4, 3], iif(ds_spec == 1, tfoms_pz[4, 3], 0), iif(ds_spec==2, tfoms_pz[4, 3], 0), tfoms_pz[4, 11]})
              if is_rebenok
                aadd(ta, {63-2, tfoms_pz[4, 3], tfoms_pz[4, 3], iif(ds_spec == 1, tfoms_pz[4, 3], 0), iif(ds_spec==2, tfoms_pz[4, 3], 0), tfoms_pz[4, 11]})
              endif
              if is_trudosp
                aadd(ta, {64-2, tfoms_pz[4, 3], tfoms_pz[4, 3], iif(ds_spec == 1, tfoms_pz[4, 3], 0), iif(ds_spec==2, tfoms_pz[4, 3], 0), tfoms_pz[4, 11]})
              endif
              if is_reabili
                aadd(ta, {65-2, tfoms_pz[4, 3], tfoms_pz[4, 3], iif(ds_spec == 1, tfoms_pz[4, 3], 0), iif(ds_spec==2, tfoms_pz[4, 3], 0), tfoms_pz[4, 11]})
              endif
              if is_inogoro
                aadd(ta, {67-3, tfoms_pz[4, 3], tfoms_pz[4, 3], iif(ds_spec == 1, tfoms_pz[4, 3], 0), iif(ds_spec==2, tfoms_pz[4, 3], 0), tfoms_pz[4, 11]})
              endif
              /*if is_onkologia // онкология
                 //  добавка 13.07.22    // стр 54, 60, 66
                 aadd(ta, {54, tfoms_pz[4, 1], tfoms_pz[4, 1], iif(ds_spec == 1, tfoms_pz[4, 1], 0), iif(ds_spec==2, tfoms_pz[4, 1], 0), tfoms_pz[4, 9]})
                 aadd(ta, {60, tfoms_pz[4, 2], tfoms_pz[4, 2], iif(ds_spec == 1, tfoms_pz[4, 2], 0), iif(ds_spec==2, tfoms_pz[4, 2], 0), tfoms_pz[4, 10]})   
                 aadd(ta, {66, tfoms_pz[4, 3], tfoms_pz[4, 3], iif(ds_spec == 1, tfoms_pz[4, 3], 0), iif(ds_spec==2, tfoms_pz[4, 3], 0), tfoms_pz[4, 11]})
              endif  
              */ 
            // скорая помощь
            case tfoms_pz[5, 1] > 0
              arr_pril5[2,igs] += tfoms_pz[5, 1] // 'СМП - вызовов, ед.'
              arr_pril5[3,igs] += tfoms_pz[5, 1] // 'СМП - лиц, чел.'
              arr_pril5[4,igs] += tfoms_pz[5, 3] // 'СМП - руб.'
              aadd(ta, {69, tfoms_pz[5, 1], tfoms_pz[5, 1]})
              arr_skor[69,isp] += tfoms_pz[5, 1]
              aadd(ta, {73, tfoms_pz[5, 1], tfoms_pz[5, 1]})
              arr_skor[73,isp] += tfoms_pz[5, 1]
              aadd(ta, {77, tfoms_pz[5, 3], tfoms_pz[5, 3]})
              arr_skor[77,isp] += tfoms_pz[5, 3]
              if is_rebenok
                aadd(ta, {70, tfoms_pz[5, 1], tfoms_pz[5, 1]})
                arr_skor[70,isp] += tfoms_pz[5, 1]
                aadd(ta, {74, tfoms_pz[5, 1], tfoms_pz[5, 1]})
                arr_skor[74,isp] += tfoms_pz[5, 1]
                aadd(ta, {78, tfoms_pz[5, 3], tfoms_pz[5, 3]})
                arr_skor[78,isp] += tfoms_pz[5, 3]
              endif
              if is_trudosp
                aadd(ta, {71, tfoms_pz[5, 1], tfoms_pz[5, 1]})
                arr_skor[71,isp] += tfoms_pz[5, 1]
                aadd(ta, {75, tfoms_pz[5, 1], tfoms_pz[5, 1]})
                arr_skor[75,isp] += tfoms_pz[5, 1]
                aadd(ta, {79, tfoms_pz[5, 3], tfoms_pz[5, 3]})
                arr_skor[79,isp] += tfoms_pz[5, 3]
              endif
              if is_inogoro
                aadd(ta, {72, tfoms_pz[5, 1], tfoms_pz[5, 1]})
                arr_skor[72,isp] += tfoms_pz[5, 1]
                aadd(ta, {76, tfoms_pz[5, 1], tfoms_pz[5, 1]})
                arr_skor[76,isp] += tfoms_pz[5, 1]
                aadd(ta, {80, tfoms_pz[5, 3], tfoms_pz[5, 3]})
                arr_skor[80,isp] += tfoms_pz[5, 3]
              endif
          endcase
          for j := 1 to len(ta)
            select TMP
            find (str(ta[j, 1], 2))
            if !found()
              append blank
              tmp->nstr := ta[j, 1]
            endif
            // !!!!
            tmp->sum4 += ta[j, 2]
            tmp->sum5 += ta[j, 3]
            //my_debug(,str(j))
            //my_debug(,str(ta[j, 1]))
  
            //my_debug(,str(tmp->sum4) + ' '+ str(tmp->sum5))
            //my_debug(,str(tmp->sum6) + ' '+ str(tmp->sum7))
  
            // !!!!
            if len(ta[j]) > 3
              tmp->sum6 += ta[j, 4]
            endif
            if len(ta[j]) > 4
              tmp->sum7 += ta[j, 5]
            endif
            if len(ta[j]) > 5
              tmp->sum8 += ta[j, 6]
            endif
            if len(ta[j]) > 6
              tmp->sum9 += ta[j, 7]
            endif
          next
          for i := 1 to len(arr_pol1)
  
            if fl_pol1[i] > 0
              arr_pol1[i, 2] += fl_pol1[i]
              arr_pol1[i, 4] += round(human->cena_1 * koef, 2)
              if is_inogoro
                arr_pol1[i, 3] += fl_pol1[i]
                arr_pol1[i, 5] += round(human->cena_1 * koef, 2)
              endif
              if i == 4
                if fl_pol3000_PROF   //профосмотры
                  arr_pol3000[ 4, 2] += fl_pol1[i]
                  arr_pol3000[ 4, 4] += round(human->cena_1 * koef, 2)
                else
                  if fl_pol3000_DVN2
                    arr_pol3000[ 5, 2] += fl_pol1[i]
                    arr_pol3000[ 5, 4] += round(human->cena_1 * koef, 2)
                  endif
                endif
              endif
            elseif fl_pol1[i] < 0
              if i == 13 .and. schet_->BUKVA == 'K'
               //
              else
                arr_pol1[i, 2] += kol_stom
                arr_pol1[i, 4] += round(human->cena_1 * koef, 2)
                if is_inogoro
                  arr_pol1[i, 3] += kol_stom
                  arr_pol1[i, 5] += round(human->cena_1 * koef, 2)
                endif
                if i == 4
                  if fl_pol3000_PROF   //профосмотры
                    arr_pol3000[ 4, 2] += fl_pol1[i]
                    arr_pol3000[ 4, 4] += round(human->cena_1 * koef, 2)
                  else
                    if fl_pol3000_DVN2
                      arr_pol3000[ 5, 2] += fl_pol1[i]
                      arr_pol3000[ 5, 4] += round(human->cena_1 * koef, 2)
                    endif
                  endif
                endif
              endif
            endif
          next
        endif
        select HUMAN
        skip
      enddo
    endif
    if fl_exit ; exit ; endif
    select SCHET
    skip
  enddo
  delete file (filetmp14)
  if !fl_exit .and. tmpf14->(lastrec()) > 0
    HH := 80
    arr_title := {;
    '──────────────────────┬──────────────────────┬──────────┬───────────────────────────', ;
    '  № в счёте, ФИО,     │ отч.период, № счёта, │Суммы слу-│                           ', ;
    '  ст-ть случая        │ дата счёта           │чая,снятия│ РАК, № и дата акта        ', ;
    '──────────────────────┴──────────────────────┴──────────┴───────────────────────────'}
    sh := len(arr_title[1])
    //
    fp := fcreate(filetmp14) ; n_list := 1 ; tek_stroke := 0
    add_string('')
    add_string(center('Список случаев, не вошедших в форму 14',sh))
    select RAKSH
    set index to
    select HUMAN
    set index to
    select TMPF14
    set relation to KOD_RAKSH into RAKSH, to schet into SCHET, to kod_h into HUMAN
    index on str(usl_ok, 1) + str(schet_->nyear, 4) + str(schet_->nmonth, 2) + ;
             str(human_->SCHET_ZAP, 6) to (cur_dir + 'tmpf14')
    for j := 1 to 5
      find (str(j, 1))
      if found()
        add_string('')
        if j == 5
          add_string(center('[ стоматология ]', sh))
        else
          add_string(center('[' + inieditspr(A__MENUVERT, getV006(), j) + ']', sh))
        endif
        aeval(arr_title, {|x| add_string(x) } )
        do while tmpf14->usl_ok == j .and. !eof()
          s1 := lstr(human_->SCHET_ZAP) + '. ' + alltrim(human->fio)
          if tmpf14->kol_akt > 1
            s1 += ' (' + lstr(tmpf14->kol_akt) + ' актов)'
          endif
          s2 := right(str(schet_->nyear, 4), 2) + '/' + strzero(schet_->nmonth, 2) + ' '+;
                alltrim(schet_->nschet) + ' от ' + date_8(schet_->dschet)
          s3 := alltrim(rak->nakt) + ' от ' + date_8(rak->dakt)
          arr1 := array(5)
          arr2 := array(5)
          arr3 := array(5)
          k1 := perenos(arr1, s1, 22)
          k2 := perenos(arr2, s2, 22)
          k3 := perenos(arr3, s3, 27)
          Ins_Array(arr3, 1, alltrim(mo_xml->fname))
          ++k3
          k := max(k1, k2, k3, 3)
          if verify_FF(HH - k, .t., sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          v := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          if round(human->cena_1, 2) == round(v, 2)
            s := '='
          elseif empty(human->cena_1)
            s := '>'
          else
            s := '<'
          endif
          add_string(padr(arr1[1], 23) + padr(arr2[1], 22) + str(human->cena_1, 11, 2) + ' '+arr3[1])
          add_string(padr(arr1[2], 23) + padr(arr2[2], 22) + str(v, 11, 2) + ' ' + arr3[2])
          add_string(padr(arr1[3], 23) + padr(arr2[3], 22) + padl(s, 11) + ' ' + arr3[3])
          for i := 4 to k
            add_string(padr(arr1[i], 23) + padr(arr2[i], 23) + space(11) + ' ' + arr3[i])
          next
          add_string(replicate('─', sh))
          select TMPF14
          skip
        enddo
      endif
    next
    fclose(fp)
  endif
  close databases
  if fl_exit
    restscreen(buf)
    return func_error(4, 'Процесс прерван!')
  endif
  //
  arr_razdel := { ;
   {'2. стационар', 1, 14}, ;
   {'3. амбулаторная медицинская помощь', 15, 32}, ;
   {'4. стоматологическая помощь', 33, 45}, ;
   {'5. дневные стационары', 46, 68}, ;
   {'6. скорая медицинская помощь', 69, 81};
  }
  //
  R_Use(dir_server + 'organiz', , 'ORG')
  ar := {}
  aadd(ar, {12, 77, mm_month[arr_m[3]] })
  aadd(ar, {12, 94, right(lstr(arr_m[1]), 2) })
  aadd(ar, {35, 48, glob_mo[_MO_FULL_NAME] })
  aadd(ar, {37, 19, glob_mo[_MO_ADRES] })
  aadd(ar, {42, 19, org->okpo })
  aadd(arr_excel, {'Лист 1', aclone(ar)})
  //
  use (cur_dir + 'tmp') index (cur_dir + 'tmp') new
  for i := 1 to len(arr_razdel)
    ar := {}
    i_stroke := iif(eq_any(i, 1, 4), 7, 6)
    for j := arr_razdel[i, 2] to arr_razdel[i, 3]
      ++i_stroke
      find (str(j, 2))
      if found()
        do case
          case i == 1
            dm := 9
          case i == 2
            dm := 9
          case i == 3
            dm := 7
          case i == 4
            dm := 8
          case i == 5
            dm := 5
        endcase
        i_column := iif(i==5, 4, 3)
        for k := 4 to dm
          ++i_column
          d := 0
          do case
            case i == 1
              d := iif(k < 7, 0, 2)
            case i == 2
              d := iif(k < 7, 0, 2)
            case i == 3
              d := iif(k < 6, 0, 2)
            case i == 4
              d := iif(between(j, 60, 64) .or. j > 66, 2, 0)
            case i == 5
              d := iif(j < 77, 0, 2)
          endcase
          pole := 'tmp->sum' + lstr(k)
          if !empty(&pole)
            aadd(ar, {i_stroke, i_column, lstr(&pole, 15, d)})
          endif
        next
      endif
    next
    for k := 1 to len(ar)
      if '.' $ ar[k, 3]
        ar[k, 3] := charrepl('.', ar[k, 3], ',')
      endif
    next
    aadd(arr_excel, {'Раздел ' + left(arr_razdel[i, 1], 1), aclone(ar)})
  next
  close databases
  restscreen(buf)
  delete file (cFileProtokol)
  /*k := 0
  for i := 1 to len(arr_prof)
    fl_error := .t.
    strfile(padr(arr_prof[i, 1], 10) + str(arr_prof[i, 2], 10) + ;
            hb_eol(), cFileProtokol, .t.)
    k += arr_prof[i, 2]
  next
  strfile(padr('Профприёмы', 10) + str(k, 10) + hb_eol(), cFileProtokol, .t.)*/
  //
  strfile(hb_eol() + ;
          padc('Дополнительные данные для заполнения формы 62', 80) + ;
          hb_eol(), cFileProtokol, .t.)
  if kol_stom_pos > 0
    fl_error := .t.
    use (cur_dir + 'TMP_STOM') new
    strfile(hb_eol() + ;
            'Отчёт о количестве и стоимости обращений и посещений при оказании стоматологической помощи'+;
            hb_eol() + ;
  '___________________________________________________________________________________________________________________________' + hb_eol() + ;
  '___________________________|______всего____________|_________дети__________|____старше трудоспос.__|____иногородние________' + hb_eol() + ;
  '                           |случа|посе-|  сумма    |случа|посе-|  сумма    |случа|посе-|  сумма    |случа|посе-|  сумма    ' + hb_eol() + ;
  '___________________________|ев___|щений|___________|ев___|щений|___________|ев___|щений|___________|ев___|щений|___________' + hb_eol(), cFileProtokol, .t.)
    for i := 1 to 10
      goto (i)
      if i == 9 .and. empty(tmp_stom->k2)
        loop
      endif
      strfile(tmp_stom->name+ str(tmp_stom->k2, 6) + str(tmp_stom->k3, 6) + str(tmp_stom->k4, 12, 2) + ;
                             str(tmp_stom->k5, 6) + str(tmp_stom->k6, 6) + str(tmp_stom->k7, 12, 2) + ;
                             str(tmp_stom->k8, 6) + str(tmp_stom->k9, 6) + str(tmp_stom->k10, 12, 2) + ;
                             str(tmp_stom->k11, 6) + str(tmp_stom->k12, 6) + str(tmp_stom->k13, 12, 2) + hb_eol(), cFileProtokol, .t.)
    next
    // 21 'Посещения при оказании помощи в неотложной форме, всего'
    // 24 'из строки 21 - посещения по специальности 'стоматология''
    goto 7
    arr_pol3000[ 19, 2] := tmp_stom->k3 // кол-во
    arr_pol3000[ 19, 3] := tmp_stom->k4 // ко-во иногородних
    arr_pol3000[ 19, 4] := tmp_stom->k12 // сумма
    arr_pol3000[ 19, 5] := tmp_stom->k13 // сумма иногородих
    use
  endif
  fl := .f.
  for i := 1 to len(arr_pril5)
    if !empty(arr_pril5[i, 2] + arr_pril5[i, 3])
      fl := .t. ; exit
    endif
  next
  if fl
    fl_error := .t.
    strfile(hb_eol() + ;
            padl('Приложение 5 к форме 62', 80) + hb_eol() + ;
  '─────────────────────────────────────────┬────────────┬────────────┬────────────' + hb_eol() + ;
  '                                         │   всего    │городские ж.│сельские жит' + hb_eol() + ;
  '─────────────────────────────────────────┴────────────┴────────────┴────────────' + hb_eol(), cFileProtokol, .t.)
    for i := 1 to (len(arr_pril5)-1)
      if !empty(arr_pril5[i, 2] +arr_pril5[i, 3])
        strfile(padr(arr_pril5[i, 1], 39) + str(i, 2) + ;
                padl(alltrim(put_val_0(arr_pril5[i, 2] + arr_pril5[i, 3], 13, 2)), 13) + ;
                padl(alltrim(put_val_0(arr_pril5[i, 2], 13, 2)), 13) + ;
                padl(alltrim(put_val_0(arr_pril5[i, 3], 13, 2)), 13) + ;
                hb_eol(), cFileProtokol, .t.)
        if i == 10
          strfile(padr(arr_pril5[32, 1], 39) + str(10, 2) + ;
            padl(alltrim(put_val_0(arr_pril5[32, 2] + arr_pril5[32, 3], 13, 2)), 13) + ;
            padl(alltrim(put_val_0(arr_pril5[32, 2], 13, 2)), 13) + ;
            padl(alltrim(put_val_0(arr_pril5[32, 3], 13, 2)), 13) + ;
            hb_eol(), cFileProtokol, .t.)
        endif  
      endif
    next
  endif
  if !empty(arr_dn_stac)
    fl_error := .t.
    asort(arr_dn_stac,,, {|x, y| x[1] < y[1] })
    aadd(arr_dn_stac, {'', 0, 0, 0, 0}) ; j := len(arr_dn_stac)
    strfile(hb_eol() + ;
            padc('Дневной стационар по профилям', 80) + hb_eol() + ;
  '──────────────────────────────┬─────────────────────┬──────┬──────────────────────' + hb_eol() + ;
  '                              │        Всего        │ сред.│  число пациенто-дней ' + hb_eol() + ;
  '            Профиль           ├───────┬─────────────│ длит.├───────┬──────┬───────' + hb_eol() + ;
  '                              │случаев│    сумма    │1случ.│ всего │взрос.│ дети  ' + hb_eol() + ;
  '──────────────────────────────┴───────┴─────────────┴──────┴───────┴──────┴───────' + hb_eol(), cFileProtokol, .t.)
    for i := 1 to len(arr_dn_stac) - 1
      s := padr(lstr(arr_dn_stac[i, 1]) + ' ' + inieditspr(A__MENUVERT, getV002(), arr_dn_stac[i, 1]), 30) + ;
              put_val(arr_dn_stac[i, 2], 8) + put_kope(arr_dn_stac[i, 3], 14)
      k := 0
      if arr_dn_stac[i, 2] > 0
        k := (arr_dn_stac[i, 4] + arr_dn_stac[i, 5]) / arr_dn_stac[i, 2]
      endif
      s += str(k, 6, 1) + put_val(arr_dn_stac[i, 4] + arr_dn_stac[i, 5], 9) + ;
           put_val(arr_dn_stac[i, 4], 7) + put_val(arr_dn_stac[i, 5], 7)
      strfile(s+hb_eol(), cFileProtokol, .t.)
      arr_dn_stac[j, 2] += arr_dn_stac[i, 2]
      arr_dn_stac[j, 3] += arr_dn_stac[i, 3]
      arr_dn_stac[j, 4] += arr_dn_stac[i, 4]
      arr_dn_stac[j, 5] += arr_dn_stac[i, 5]
    next
    strfile(replicate('─', 83) + hb_eol(), cFileProtokol, .t.)
    s := padr('Итого:', 30) + ;
              put_val(arr_dn_stac[j, 2], 8) + put_kope(arr_dn_stac[j, 3], 14)
    k := 0
    if arr_dn_stac[j, 2] > 0
      k := (arr_dn_stac[j, 4] + arr_dn_stac[j, 5]) / arr_dn_stac[j, 2]
    endif
    s += str(k, 6, 1) + put_val(arr_dn_stac[j, 4] + arr_dn_stac[j, 5], 9) + ;
         put_val(arr_dn_stac[j, 4], 7) + put_val(arr_dn_stac[j, 5], 7)
    strfile(s + hb_eol(), cFileProtokol, .t.)
    strfile(replicate('─', 83) + hb_eol(), cFileProtokol, .t.)
    s := padr('в т.ч.в дн.стационарах на дому', 30) + ;
              put_val(arrDdn_stac[1], 8) + put_kope(arrDdn_stac[2], 14)
    k := 0
    if arrDdn_stac[1] > 0
      k := (arrDdn_stac[3] + arrDdn_stac[4]) / arrDdn_stac[1]
    endif
    s += str(k, 6, 1) + put_val(arrDdn_stac[3] + arrDdn_stac[4], 9) + ;
         put_val(arrDdn_stac[3], 7) + put_val(arrDdn_stac[4], 7)
    strfile(s + hb_eol(), cFileProtokol, .t.)
  endif
  if !empty(arr_profil)
    fl_error := .t.
    asort(arr_profil,,, {|x, y| x[1] < y[1] })
    strfile(hb_eol() + ;
            padc('Стационар по профилям', 80) + hb_eol() + ;
  '──────────────────────────────┬────────────────────────┬────────────────────────' + hb_eol() + ;
  '                              │        Всего           │   в т.ч. иногородние   ' + hb_eol() + ;
  '            Профиль           ├─────────┬──────────────┼─────────┬──────────────' + hb_eol() + ;
  '                              │пациентов│     сумма    │пациентов│     сумма    ' + hb_eol() + ;
  '──────────────────────────────┴─────────┴──────────────┴─────────┴──────────────' + hb_eol(), cFileProtokol, .t.)
    for i := 1 to len(arr_profil)
      strfile(padr(lstr(arr_profil[i, 1]) + ' ' + inieditspr(A__MENUVERT, getV002(), arr_profil[i, 1]), 30) + ;
              put_val(arr_profil[i, 2], 10) + put_kope(arr_profil[i, 3], 15) + ;
              put_val(arr_profil[i, 4], 10) + put_kope(arr_profil[i, 5], 15) + ;
              hb_eol(), cFileProtokol, .t.)
    next
  endif
  fl := .f.
  for i := 15 to 32
    if arr_pol[i] > 0
      fl := .t. ; exit
    endif
  next
  if fl
    fl_error := .t.
    strfile(hb_eol() + ;
            padc('Амбулаторно-поликлиническая помощь', 80) + hb_eol() + ;
  '──────────────────────────────────────────────────┬─────────────────────────────' + hb_eol() + ;
  '                                                  │стоимость по счетам "A" и "K"' + hb_eol() + ;
  '──────────────────────────────────────────────────┴─────────────────────────────' + hb_eol() + ;
  'Посещения с профилактической целью, всего          15' + put_kope(arr_pol[15], 20) + hb_eol() + ;
  '  из них: врачей общей практики (семейных врачей)  16' + put_kope(arr_pol[16], 20) + hb_eol() + ;
  '          центров здоровья                         17' + put_kope(arr_pol[17], 20) + hb_eol() + ;
  '  из строки 15: детьми (0-17 лет включительно)     18' + put_kope(arr_pol[18], 20) + hb_eol() + ;
  '    из них центров здоровья детьми (0-17 лет)      19' + put_kope(arr_pol[19], 20) + hb_eol() + ;
  '           лицами старше трудоспособного возраста  20' + put_kope(arr_pol[20], 20) + hb_eol() + ;
  ' лицами, застрахованными за пределами субъекта РФ  21' + put_kope(arr_pol[21], 20) + hb_eol() + ;
  'Посещения при оказании мед.помощи в неотл.форме    22' + put_kope(arr_pol[22], 20) + hb_eol() + ;
  '  из них: врачей общей практики (семейных врачей)  23' + put_kope(arr_pol[23], 20) + hb_eol() + ;
  '  из строки 22: детьми (0-17 лет включительно)     24' + put_kope(arr_pol[24], 20) + hb_eol() + ;
  '           лицами старше трудоспособного возраста  25' + put_kope(arr_pol[25], 20) + hb_eol() + ;
  ' лицами, застрахованными за пределами субъекта РФ  26' + put_kope(arr_pol[26], 20) + hb_eol() + ;
  'Обращения по поводу заболевания, всего             27' + put_kope(arr_pol[27], 20) + hb_eol() + ;
  ' из них к врачам общей практики (семейным врачам)  28' + put_kope(arr_pol[28], 20) + hb_eol() + ;
  '  из строки 27: детей (0-17 лет включительно)      29' + put_kope(arr_pol[29], 20) + hb_eol() + ;
  '     лиц старше трудоспособного возраста           30' + put_kope(arr_pol[30], 20) + hb_eol() + ;
  '     лиц, при прохождении реабилитации             31' + put_kope(arr_pol[31], 20) + hb_eol() + ;
  '     лиц, застрахованных за пределами субъекта РФ  32' + put_kope(arr_pol[32], 20) + hb_eol(), cFileProtokol, .t.)
  endif
  
  fl := .f.
  for i := 1 to 15
    if arr_pol1[i, 2] > 0
      fl := .t. ; exit
    endif
  next
  if fl
    fl_error := .t.
    strfile(hb_eol() + ;
            padc('3000 Фактические объёмы посещений и их финансирование (Старый вариант)', 80) + hb_eol() + ;
  '────────────────────────────────────┬───────────────┬───────────────────────────' + hb_eol() + ;
  '                                    │   посещений   │          сумма            ' + hb_eol() + ;
  ' Наименование показателя            ├───────┬───────┼─────────────┬─────────────' + hb_eol() + ;
  '                                    │ всего │иногор.│    всего    │в т.ч. иногор' + hb_eol() + ;
  '────────────────────────────────────┴───────┴───────┴─────────────┴─────────────' + hb_eol(), cFileProtokol, .t.)
    add_val_2_array(arr_pol1, 2, 3, 2, 5)
    add_val_2_array(arr_pol1, 2, 6, 2, 5)
    add_val_2_array(arr_pol1, 2, 9, 2, 5)
    //
    add_val_2_array(arr_pol1, 1, 2, 2, 5)
    add_val_2_array(arr_pol1, 1, 11, 2, 5)
    add_val_2_array(arr_pol1, 1, 13, 2, 5)
    for i := 1 to len(arr_pol1)
      k := perenos(t_arr, arr_pol1[i, 1], 33)
      strfile(padr(rtrim(t_arr[1]), 34, '.') + strzero(i, 2) + ;
              put_val(arr_pol1[i, 2], 8) + put_val(arr_pol1[i, 3], 8) + ;
              put_kope(arr_pol1[i, 4], 14) + put_kope(arr_pol1[i, 5], 14) + hb_eol(), cFileProtokol, .t.)
      for j := 2 to k
        strfile(padl(alltrim(t_arr[j]), 34) + hb_eol(), cFileProtokol, .t.)
      next
    next
  endif
  if !empty(sum_k)
    fl_error := .t.
    strfile(hb_eol() + 'Сумма по счетам, имеющим параметр К = ' + lstr(sum_k, 12, 2) + ;
                     ' (в т.ч.дети ' + lstr(sum_kd, 12, 2) + ', трудоспос.' + lstr(sum_kt, 12, 2) + ;
                     ', иногородние ' + lstr(sum_ki, 12, 2) + ')' + hb_eol(), cFileProtokol, .t.)
  endif
  if !empty(sum_d)
    fl_error := .t.
    strfile(hb_eol() + 'По счетам, имеющим параметр G,J,D,O,R,F,V,I,U = ' + lstr(kol_d) + ' приёмов на сумму ' + lstr(sum_d, 12, 2) + hb_eol(), cFileProtokol, .t.)
  endif
  if arr_eko[1, 1] > 0
    fl_error := .t.
    strfile(hb_eol() + ;
      'Проведено выбывшими пациентами пациенто-дней при ЭКО  ' + lstr(arr_eko[1, 1]) + ' (в т.ч.ВМП ' + lstr(arr_eko[1, 2]) + ')' + hb_eol() + ;
      '  из них лиц, застрахованных за пределами субъекта РФ ' + lstr(arr_eko[2, 1]) + ' (в т.ч.ВМП ' + lstr(arr_eko[2, 2]) + ')' + hb_eol(), cFileProtokol, .t.)
  endif
  
  
  fl := .f.
  for i := 1 to 29
    if arr_pol3000[i, 2] > 0
      fl := .t. ; exit
    endif
  next
  if fl
    fl_error := .t.
    strfile(hb_eol() + ;
            padc('3000 Фактические объёмы посещений и их финансирование', 80) + hb_eol() + ;
  '────────────────────────────────────┬───────────────┬───────────────────────────' + hb_eol() + ;
  '                                    │   посещений   │          сумма            ' + hb_eol() + ;
  ' Наименование показателя            ├───────┬───────┼─────────────┬─────────────' + hb_eol() + ;
  '                                    │ всего │иногор.│    всего    │в т.ч. иногор' + hb_eol() + ;
  '────────────────────────────────────┴───────┴───────┴─────────────┴─────────────' + hb_eol(), cFileProtokol, .t.)
    //
    //'02 Посещения с профилактическими и иными целями (03+06)'
  //  add_val_2_array(arr_pol3000, 2, 3, 2, 5)
  //  add_val_2_array(arr_pol3000, 2, 6, 2, 5)
    // 01 Посещений - всего (02+21+25)
  //  add_val_2_array(arr_pol3000, 1, 2, 2, 5)
  //  add_val_2_array(arr_pol3000, 1, 17, 2, 5)
  //  add_val_2_array(arr_pol3000, 1, 20, 2, 5)
    //
  // Переприсвоение
    for xx := 2 to 5
      arr_pol3000[ 1, xx] := arr_pol1[1, xx]
    next
    //
    for xx := 2 to 5
      arr_pol3000[ 2, xx] := arr_pol1[2, xx]
    next
  // 12 'из строки 06 разовые посещения в связи с заболеваниями'
    for xx := 2 to 5
      arr_pol3000[ 9, xx] := arr_pol1[6, xx]
    next
  // 13 'из строки 12 - посещения на дому'
    for xx := 2 to 5
      arr_pol3000[ 10, xx] := arr_pol1[7, xx]
    next
  // 'Посещения при оказании помощи в неотложной форме, всего'
    for xx := 2 to 5
      arr_pol3000[ 17, xx] := arr_pol1[11, xx]
    next
  //'из строки 21 - посещения на дому'
    for xx := 2 to 5
      arr_pol3000[ 18, xx] := arr_pol1[12, xx]
    next
  //'Посещения, включенные в обращение в связи с заболеваниями'
    for xx := 2 to 5
      arr_pol3000[ 20, xx] := arr_pol1[13, xx]
    next
    //'06 посещения с иными целями, всего (07+08+12+14+15+16+19+20)'
    //add_val_2_array(arr_pol3000, 6, 7, 2, 5)   // 7
    //add_val_2_array(arr_pol3000, 6, 8, 2, 5)   // 8
    //add_val_2_array(arr_pol3000, 6, 9, 2, 5)   // 12
    //add_val_2_array(arr_pol3000, 6, 11, 2, 5)  // 14
    //add_val_2_array(arr_pol3000, 6, 12, 2, 5)  // 15
    //add_val_2_array(arr_pol3000, 6, 13, 2, 5)  // 16
    ////add_val_2_array(arr_pol3000, 6,, 2, 5)  // 19 нет в системе ОМС
    //add_val_2_array(arr_pol3000, 6, 16, 2, 5)  // 20
  
    //'03 посещения с профилактическими целями, всего (04+05)'
    add_val_2_array(arr_pol3000, 3, 4, 2, 5)
    add_val_2_array(arr_pol3000, 3, 5, 2, 5)
    //
    for xx := 2 to 5
      arr_pol3000[ 6, xx] := arr_pol3000[2, xx] - arr_pol3000[ 3, xx]
    next
    //
    for i := 1 to len(arr_pol3000)
      k := perenos(t_arr,arr_pol3000[i, 1], 33)
      strfile(padr(rtrim(t_arr[1]), 34,'.') + strzero(arr_pol3000[i, 6], 2) + ; //strzero(arr_pol3000[i, 1], 2) + ;
              put_val(arr_pol3000[i, 2], 8) + put_val(arr_pol3000[i, 3], 8) + ;
              put_kope(arr_pol3000[i, 4], 14) + put_kope(arr_pol3000[i, 5], 14) + hb_eol(), cFileProtokol, .t.)
      for j := 2 to k
        strfile(padl(alltrim(t_arr[j]), 34) + hb_eol(), cFileProtokol, .t.)
      next
    next
  endif
  if !empty(sum_k)
    fl_error := .t.
    strfile(hb_eol() + 'Сумма по счетам, имеющим параметр К = ' + lstr(sum_k, 12, 2) + ;
                     ' (в т.ч.дети ' + lstr(sum_kd, 12, 2) + ', трудоспос.' + lstr(sum_kt, 12, 2) + ;
                     ', иногородние ' + lstr(sum_ki, 12, 2) + ')' + hb_eol(), cFileProtokol, .t.)
  endif
  if !empty(sum_d)
    fl_error := .t.
    strfile(hb_eol() + 'По счетам, имеющим параметр G,J,D,O,R,F,V,I,U = ' + lstr(kol_d) + ' приёмов на сумму ' + lstr(sum_d, 12, 2) + hb_eol(), cFileProtokol, .t.)
  endif
  if arr_eko[1, 1] > 0
    fl_error := .t.
    strfile(hb_eol() + ;
      'Проведено выбывшими пациентами пациенто-дней при ЭКО  ' + lstr(arr_eko[1, 1]) + ' (в т.ч.ВМП ' + lstr(arr_eko[1, 2]) + ')' + hb_eol() + ;
      '  из них лиц, застрахованных за пределами субъекта РФ ' + lstr(arr_eko[2, 1]) + ' (в т.ч.ВМП ' + lstr(arr_eko[2, 2]) + ')' + hb_eol(), cFileProtokol, .t.)
  endif
  if arr_skor[69, 1] > 0 .or. arr_skor[69, 2] > 0
    fl_error := .t.
    strfile(hb_eol()+padc('Скорая помощь', 80) + hb_eol() + ;
  '──────────────────────────────────────────────────────┬────────────┬────────────' + hb_eol() + ;
  '                                                      │в неотлож.ф.│в экстрен.ф.' + hb_eol() + ;
  '──────────────────────────────────────────────────────┴────────────┴────────────' + hb_eol() + ;
  'Число выполненных вызовов скорой медицинской помощи, 69' + put_kope(arr_skor[69, 1], 13) + put_kope(arr_skor[69, 2], 13) + hb_eol() + ;
  '  из них: к детям (0-17 лет включительно)          , 70' + put_kope(arr_skor[70, 1], 13) + put_kope(arr_skor[70, 2], 13) + hb_eol() + ;
  '          к лицам старше трудоспособного возраста  , 71' + put_kope(arr_skor[71, 1], 13) + put_kope(arr_skor[71, 2], 13) + hb_eol() + ;
  '   к лицам, застрахованным за пределами субъекта РФ, 72' + put_kope(arr_skor[72, 1], 13) + put_kope(arr_skor[72, 2], 13) + hb_eol() + ;
  'Число лиц, обслуженных бригадами скорой мед.помощи , 73' + put_kope(arr_skor[73, 1], 13) + put_kope(arr_skor[73, 2], 13) + hb_eol() + ;
  '  из них: детей (0-17 лет включительно)            , 74' + put_kope(arr_skor[74, 1], 13) + put_kope(arr_skor[74, 2], 13) + hb_eol() + ;
  '          лиц старше трудоспособного возраста      , 75' + put_kope(arr_skor[75, 1], 13) + put_kope(arr_skor[75, 2], 13) + hb_eol() + ;
  '       лиц, застрахованных за пределами субъекта РФ, 76' + put_kope(arr_skor[76, 1], 13) + put_kope(arr_skor[76, 2], 13) + hb_eol() + ;
  'Стоимость оказанной скорой медицинской помощи,всего, 77' + put_kope(arr_skor[77, 1], 13) + put_kope(arr_skor[77, 2], 13) + hb_eol() + ;
  '  из них: детям (0-17 лет включительно)            , 78' + put_kope(arr_skor[78, 1], 13) + put_kope(arr_skor[78, 2], 13) + hb_eol() + ;
  '          лицам старше трудоспособного возраста    , 79' + put_kope(arr_skor[79, 1], 13) + put_kope(arr_skor[79, 2], 13) + hb_eol() + ;
  '     лицам, застрахованным за пределами субъекта РФ, 80' + put_kope(arr_skor[80, 1], 13) + put_kope(arr_skor[80, 2], 13) + hb_eol() + ;
  'Стоимость иных видов медицинской помощи и услуг    , 81' + put_kope(arr_skor[81, 1], 13) + put_kope(arr_skor[81, 2], 13) + hb_eol(), cFileProtokol, .t.)
  endif
  if file(filetmp14)
    viewtext(filetmp14,,,,.t.,,, 5)
  endif
  if fl_error
    viewtext(Devide_Into_Pages(cFileProtokol, 60, 80),,,,.t.,,, 3)
  endif
  fill_in_Excel_Book(dir_exe + 'mo_14med' + sxls, ;
                     cur_dir + '__14med' + sxls, ;
                     arr_excel, ;
                     'присланный из ТФОМС')
  return NIL