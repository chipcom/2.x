#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
// #include 'hblibxlsxwriter.ch'
#include 'hbxlsxwriter.ch'

Static lcount_uch  := 1

// 13.10.23 многовариантный поиск
Function s_mnog_poisk()
  Static mm_rak := { ;
    {'все случаи', 0}, ;
    {'за исключением полностью неоплачиваемых', 1}, ;
    {'полностью неоплачиваемые и перевыставленные', 2}, ;
    {'полностью неоплачиваемые и неперевыставленные', 3}, ;
    {'полностью неоплачиваемые', 4}, ;
    {'частично неоплачиваемые', 5}, ;
    {'полностью или частично неоплачиваемые', 6} ;
  }
  Static mm_d_p_m := { ;  // 'Диспансеризация/Профилактика/Медосмотр?'
    {'диспансеризация детей-сирот при стационаре I этап', 1}, ;
    {'диспансеризация детей-сирот при стационаре II этап', 2}, ;
    {'диспансеризация детей-сирот под опекой I этап', 3}, ;
    {'диспансеризация детей-сирот под опекой II этап', 4}, ;
    {'диспансеризация взрослого населения I этап (1 раз в 3 года)', 5}, ;
    {'диспансеризация взрослого населения II этап (1 раз в 3 года)', 6}, ;
    {'профилактика взрослого населения', 7}, ;
    {'диспансеризация взрослого населения I этап (1 раз в 2 года)', 8}, ;
    {'диспансеризация взрослого населения II этап (1 раз в 2 года)', 9}, ;
    {'профосмотр несовершеннолетних I этап', 10}, ;
    {'профосмотр несовершеннолетних II этап', 11}, ;
    {'предварительный осмотр несовершеннолетних I этап', 12}, ;
    {'предварительный осмотр несовершеннолетних II этап', 13}, ;
    {'периодический осмотр несовершеннолетних', 14}, ;
    {'углубленная диспансеризация I этап (COVID-19)', 15}, ;
    {'углубленная диспансеризация II этап (COVID-19)', 16} ;
  }
  Static mm_perevyst := { ;
    {'все случаи', 1}, ;
    {'без учёта случаев с отказом (перевыставленных)', 0}, ;
    {'только случаи с отказом (которые были перевыставлены)', 2} ;
  }
  Static mm_g_selo :=  {{'город', 1}, {'село', 2}}
  Static mm_regschet := {{'Не зарегистрированные счета', 1}, {'Зарегистрированные счета', 2}}
  Static mm_schet := {{'Не попавшие в счета', 1}, {'Попавшие в счета', 2}}
  Static mm_reestr := {{'Не попавшие в реестры', 1}, {'Попавшие в реестры', 2}}
  Static mm_zav_lech := {{'Незаконченный случай', 1}, {'законченный случай', 2}}
  Static mm_dvojn := {{'все случаи', 1}, {'только двойные случаи', 2}, {'все, кроме двойных случаев', 3}}
  Local mm_tmp := {}, k, adiag_talon[16]
  Local buf := savescreen(), tmp_color := setcolor(cDataCGet), ;
        tmp_help := help_code, hGauge, name_file := cur_dir + 'report' + stxt, ;
        sh := 80, HH := 77, i, a_diagnoz[10], ;
        mm_da_net := {{'нет', 1}, {'да ', 2}}, lvid_doc := 0, ;
        menu_bolnich := {{'нет', 1}, {'да', 2}, {'родители', 3}}, ;
        mm_mest := {{'Волгоград или область', 1}, {'иногородние', 2}}, ;
        mm_dom := {{'-----', 0}, {'в поликлинике', 1}, {'на дому', 2}}, ;
        mm_invalid := {{'неважно', 0}, {'любая группа', 9}, {'1 группа', 1}, {'2 группа', 2}, {'3 группа', 3}, {'дети-инвалиды', 4}}, ;
        mm_prik := {{'неважно', 0}, ;
                    {'прикреплён к нашей МО', 1}, ;
                    {'не прикреплён к нашей МО', 2}}, ;
        tmp_file := cur_dir + 'tmp_mn_p' + sdbf, ;
        k_diagnoz, k_usl, tt_diagnoz[10], tt_usl[10]
  local nameArr
  local name_fileXLS := 'Report_' + suffixFileTimestamp()
  local name_fileXLS_full := name_fileXLS + '.xlsx'
  local lExcel := .t., used_column := 0
  local workbook
  local header, header_wrap
  local worksheet, wsCommon
  local formatDate
  local fmtCellNumber, fmtCellString, fmtCellStringCenter, fmtCellNumberRub
  local row, column, rowWS, columnWS
  local s1, s2, s3
  local wsCommon_format, wsCommon_format_header, wsCommon_format_wrap, wsCommon_Number, wsCommon_Number_Rub

  if mem_dom_aktiv == 1
    aadd(mm_dom, {'на дому-АКТИВ', 3})
    aadd(mm_dom, {'на дому + на дому-АКТИВ', 4})
  endif
  Private ssumma := 0, srak_s := 0, suet := 0, p_regim := 1, mm_company := {}, is_kategor2 := .f., ;
          mm_rslt := {}, mm_ishod := {}, rslt_umolch := -1, ishod_umolch := -1
  Private tmp_V006 := create_classif_FFOMS(0, 'V006') // USL_OK
  Private tmp_V002 := create_classif_FFOMS(0, 'V002') // PROFIL
  Private tmp_V009 := getV009(sys_date) // rslt
  Private tmp_V012 := getV012(sys_date) // ishod
  Private arr_doc := {'Дата рожд.', ;
                      'Адрес', ;
                      'Номер карты', ; 
                      'Сроки леч.', ;
                      'Диагноз', ;
                      'Счет', ;
                      'РАК', ;
                      'Леч.врач', ;
                      'Услуги', ;
                      'Доп.критерий'}
  if yes_parol
    aadd(arr_doc, 'Дата ввода')
  endif
  aadd(arr_doc, 'Номера Тел.')
  if (st_a_uch := inputN_uch(T_ROW, T_COL - 5, , , @lcount_uch)) == NIL
    return NIL
  endif
  if yes_bukva
    Private md_plus := array(len(yes_d_plus))
    k_plus := len(md_plus)
    afill(md_plus, ' ')
    aeval(md_plus, {|x, i| md_plus[i] := substr(yes_d_plus, i, 1)})
    sd_plus := array(k_plus)
    afill(sd_plus, 0)
  endif
  Private pr_arr := {}, pr_arr_otd := {}, is_talon := ret_is_talon(), arr_tal_diag[2, 3], mm_pz := {}
  afillall(arr_tal_diag, 0)

  nameArr := 'glob_array_PZ_' + '19'    //last_digits_year(ly)
  // for i := 1 to len(glob_array_PZ_19)
  //   aadd(mm_pz, {glob_array_PZ_19[i, 3],glob_array_PZ_19[i, 1]})
  for i := 1 to len(&nameArr)
    aadd(mm_pz, {&nameArr.[i, 3], &nameArr.[i, 1]})
  next
  if is_talon
    is_kategor2 := !empty(stm_kategor2)
  endif
  //
  R_Use(dir_server + 'mo_otd', , 'OTD')
  dbeval({|| aadd(pr_arr, {otd->(recno()), otd->name, otd->kod_lpu, ''}) }, ;
       {|| f_is_uch(st_a_uch, otd->kod_lpu) .and. between_date(otd->dbegin, otd->dend, sys_date)})
  R_Use(dir_server + 'mo_uch', , 'UCH')
  aeval(pr_arr, {|x, i| dbGoto(x[3]), pr_arr[i, 4] := uch->name})
  //
  asort(pr_arr, , , {|x, y| iif(x[3] == y[3], upper(x[2]) < upper(y[2]), upper(x[4]) < upper(y[4]))})
  aeval(pr_arr, {|x| aadd(pr_arr_otd, x[2] + ' ' + x[4])})
  close databases
  //
  lvid_doc := setbit(lvid_doc, 3)
  lvid_doc := setbit(lvid_doc, 5)
  //
  Private pdate_lech, pdate_schet, pdate_usl, pdate_vvod, mstr_crb := 0, mstr_crbM := {}, mslugba
  //
  dbcreate(cur_dir + 'tmp', { ;
      {'U_KOD'  ,    'N',      4,      0}, ;  // код услуги
      {'U_SHIFR',    'C',     10,      0}, ;  // шифр услуги
      {'U_NAME',     'C',     65,      0} ;   // наименование услуги
    })
  use (cur_dir + 'tmp')
  index on str(u_kod, 4) to (cur_dir + 'tmpk')
  index on fsort_usl(u_shifr) to (cur_dir + 'tmpn')
  tmp->(dbCloseArea())
  //
  dbcreate(cur_dir + 'tmpF', { ;
      {'U_KOD'  ,    'N',      6,      0}, ;  // код услуги
      {'U_SHIFR',    'C',     20,      0}, ;  // шифр услуги
      {'U_NAME',     'C',    255,      0} ;   // наименование услуги
    })
  use (cur_dir + 'tmpF')
  index on str(u_kod, 6) to (cur_dir + 'tmpFk')
  index on fsort_usl(u_shifr) to (cur_dir + 'tmpFn')
  tmpF->(dbCloseArea())
  //
  aadd(mm_tmp, {'date_lech', 'N', 4, 0, NIL, ;
              {|x| menu_reader(x, ;
                 {{|k, r, c| k := year_month(r + 1, c), ;
                      if(k == nil, NIL, (pdate_lech := aclone(k), k := {k[1], k[4]})), ;
                      k }}, A__FUNCTION)}, ;
              0, {|| space(10) }, ;
              'Дата окончания лечения'})
  aadd(mm_tmp, {'date_schet', 'N', 4, 0, NIL, ;
              {|x| menu_reader(x, ;
                 {{|k, r, c| k := year_month(r + 1, c), ;
                      if(k == nil, NIL, (pdate_schet := aclone(k), k := {k[1], k[4]})), ;
                      k }}, A__FUNCTION)}, ;
              0, {|| space(10) }, ;
              'Дата выписки счета'})
  aadd(mm_tmp, {'date_usl', 'N', 4, 0, NIL, ;
              {|x| menu_reader(x, ;
                 {{|k, r, c| k := year_month(r + 1, c), ;
                      if(k == nil, NIL, (pdate_usl := aclone(k), k := {k[1], k[4]})), ;
                      k }}, A__FUNCTION)}, ;
              0, {|| space(10) }, ;
              'Дата оказания услуг'})
  aadd(mm_tmp, {'date_vvod', 'N', 4, 0, NIL, ;
              {|x| menu_reader(x, ;
                 {{|k, r, c| k := year_month(r + 1, c), ;
                      if(k == nil, NIL, (pdate_vvod := aclone(k), k := {k[1], k[4]})), ;
                      k }}, A__FUNCTION)}, ;
              0, {|| space(10) }, ;
              '  дата ввода информации'})
  if yes_vypisan == B_END
    aadd(mm_tmp, {'zav_lech', 'N', 1, 0, NIL, ;
                {|x| menu_reader(x, mm_zav_lech, A__MENUVERT)}, ;
                0, {|| space(10) }, ;
                'Факт завершения лечения?'})
  endif
  aadd(mm_tmp, {'reestr', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_reestr, A__MENUVERT)}, ;
              0, {|| space(10) }, ;
              'В реестре?'})
  aadd(mm_tmp, {'schet', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_schet, A__MENUVERT)}, ;
              0, {|| space(10) }, ;
              'В счёте?'})
  aadd(mm_tmp, {'regschet', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_regschet, A__MENUVERT)}, ;
              0, {|| space(10) }, ;
              'Счёт зарегистрирован в ТФОМС?', , ;
              {|| m1schet == 2 }})
  aadd(mm_tmp, {'perevyst', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_perevyst, A__MENUVERT)}, ;
              0, {|x| inieditspr(A__MENUVERT, mm_perevyst, x)}, ;
              'Какие случаи учитывать?'})
  aadd(mm_tmp, {'rak', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_rak, A__MENUVERT)}, ;
              0, {|x| inieditspr(A__MENUVERT,mm_rak, x)}, ;
              'Оплата в актах контроля (РАК)'})
  aadd(mm_tmp, {'d_p_m', 'N', 10, 0, NIL, ;
              {|x| menu_reader(x, mm_d_p_m, A__MENUBIT)}, ;
              0, {|x| inieditspr(A__MENUBIT,mm_d_p_m, x)}, ;
              'Диспансеризация/Профилактика/Медосмотр?'})
  aadd(mm_tmp, {'pz', 'N', 2, 0, NIL, ;
              {|x| menu_reader(x, mm_pz, A__MENUVERT_SPACE)}, ;
              0, {|| space(10) }, ;
              'Вид план-заказа'})
  aadd(mm_tmp, {'dvojn', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_dvojn, A__MENUVERT)}, ;
              1, {|x| inieditspr(A__MENUVERT, mm_dvojn, x)}, ;
              'Учитывать двойные случаи?'})
  aadd(mm_tmp, {'zno', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_da_net, A__MENUVERT)}, ;
              0, {|| space(10) }, ;
              'Признак подозрения на ЗНО?'})
  aadd(mm_tmp, {'kol_lu', 'N', 2, 0, , ;
              nil, ;
              0, NIL, ;
              'Количество листов учета по одному больному более'})
  aadd(mm_tmp, {'kol_pos', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_da_net, A__MENUVERT)}, ;
              0, {|| space(10) }, ;
              'Подсчитывать количество амбулаторных и стоматологических посещений?'})
  aadd(mm_tmp, {'uch_doc', 'C', 10, 0, '@!', ;
              nil, ;
              space(10), NIL, ;
              '№ амб.карты/истории болезни (шаблон)'})
  Private arr_uchast := {}
  if is_uchastok > 0
    aadd(mm_tmp, {'bukva', 'C', 1, 0, '@!', ;
                nil, ;
                ' ', NIL, ;
                'Буква (перед участком)'})
    aadd(mm_tmp, {'uchast', 'N', 1, 0, , ;
                {|x| menu_reader(x, {{ |k, r, c| get_uchast(r + 1, c) }}, A__FUNCTION)}, ;
                0, {|| init_uchast(arr_uchast) }, ;
                'Участок (участки)'})
  endif
  if glob_mo[_MO_IS_UCH]
    aadd(mm_tmp, {'o_prik', 'N', 1, 0, NIL, ;
                {|x| menu_reader(x, mm_prik, A__MENUVERT)}, ;
                0, {|x| inieditspr(A__MENUVERT, mm_prik, x)}, ;
                'Отношение к прикреплению на начало лечения'})
  endif
  aadd(mm_tmp, {'fio', 'C', 20, 0, '@!', ;
              nil, ;
              space(20), NIL, ;
              'ФИО (начальные буквы или шаблон)'})
  aadd(mm_tmp, {'inostran', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_da_net, A__MENUVERT)}, ;
              0, {|| space(10) }, ;
              'Документы иностранных граждан:'})
  aadd(mm_tmp, {'gorod_selo', 'N', 2, 0, NIL, ;
              {|x| menu_reader(x,mm_g_selo, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              'Житель:'})
  aadd(mm_tmp, {'mi_git', 'N', 2, 0, NIL, ;
              {|x| menu_reader(x, mm_mest, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              'Место жительства:'})
  aadd(mm_tmp, {'_okato', 'C', 11, 0, NIL, ;
              {|x| menu_reader(x, {{ |k, r, c| get_okato_ulica(k, r, c, {k, m_okato,}) }}, A__FUNCTION)}, ;
              space(11), {|x| space(11)}, ;
              'Адрес регистрации (ОКАТО)'})
  aadd(mm_tmp, {'adres', 'C', 20, 0, '@!', ;
              nil, ;
              space(20), NIL, ;
              'Улица (подстрока или шаблон)'})
  aadd(mm_tmp, {'mr_dol', 'C', 20, 0, '@!', ;
              nil, ;
              space(20), NIL, ;
              'Место работы (подстрока или шаблон)'})
  aadd(mm_tmp, {'invalid', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_invalid, A__MENUVERT)}, ;
              0, {|x| inieditspr(A__MENUVERT, mm_invalid, x)}, ;
              'Наличие инвалидности'})
  aadd(mm_tmp, {'kategor', 'N', 4, 0, NIL, ;
              {|x| menu_reader(x, mo_cut_menu(stm_kategor), A__MENUVERT)}, ;
              0, {|| space(10) }, ;
              'Код категории льготы'})
  if is_talon
    if is_kategor2
      aadd(mm_tmp, {'kategor2', 'N', 4, 0, NIL, ;
                  {|x| menu_reader(x, stm_kategor2, A__MENUVERT)}, ;
                  0, {|| space(10) }, ;
                  'Категория МО'})
    endif
  endif
  aadd(mm_tmp, {'pol', 'C', 1, 0,'!', ;
              nil, ;
              ' ', NIL, ;
              'Пол', {|| mpol $ ' МЖ' } })
  aadd(mm_tmp, {'vzros_reb', 'N', 2, 0, NIL, ;
              {|x| menu_reader(x, menu_vzros, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              'Возрастная принадлежность'})
  aadd(mm_tmp, {'god_r_min', 'D', 8, 0, , ;
              nil, ;
              ctod(''), NIL, ;
              'Дата рождения (минимальная)'})
  aadd(mm_tmp, {'god_r_max', 'D', 8, 0, , ;
              nil, ;
              ctod(''), NIL, ;
              'Дата рождения (максимальная)'})
  aadd(mm_tmp, {'rab_nerab', 'N', 2, 0, NIL, ;
              {|x| menu_reader(x, menu_rab, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              'Работающий/неработающий'})
  aadd(mm_tmp, {'USL_OK', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, tmp_V006, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              'Медицинская помощь: условия оказания', ;
              {|g,o| f_valid_usl_ok(g, o, .f.) }})
  /*aadd(mm_tmp, {'VIDPOM', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, tmp_V008, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              '  вид'})*/
  aadd(mm_tmp, {'PROFIL', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, tmp_V002, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              '  профиль (в случае)'})
  aadd(mm_tmp, {'PROFIL_U', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, tmp_V002, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              '  профиль (в услуге)'})
  /*aadd(mm_tmp, {'IDSP', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, tmp_V010, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              '  способ оплаты'})*/
  aadd(mm_tmp, {'rslt', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, mm_rslt, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              'Результат обращения', , ;
              {|| m1usl_ok > 0 }})
  aadd(mm_tmp, {'ishod', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, mm_ishod, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              'Исход заболевания', , ;
              {|| m1usl_ok > 0 }})
  /*if is_talon
    aadd(mm_tmp, {'povod', 'N', 2, 0, NIL, ;
                {|x| menu_reader(x, stm_povod, A__MENUVERT)}, ;
                0, {|| space(10) }, ;
                'Повод обращения'})
    aadd(mm_tmp, {'travma', 'N', 2, 0, NIL, ;
                {|x| menu_reader(x, stm_travma, A__MENUVERT)}, ;
                -1, {|| space(10) }, ;
                'Вид травмы'})
  endif*/
  aadd(mm_tmp, {'bolnich1', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, menu_bolnich, A__MENUVERT)}, ;
              0, {|| space(10) }, ;
              'Больничный?'})
  aadd(mm_tmp, {'bolnich', 'N', 3, 0, , ;
              nil, ;
              0, NIL, ;
              'Кол-во дней на больничном более'})
  aadd(mm_tmp, {'vrach1', 'N', 5, 0, NIL, ;
              nil, ;
              0, NIL, ;
              'Лечащий врач', ;
              {|g| st_v_vrach(g, 'mvrach') } })
  aadd(mm_tmp, {'vrach', 'C', 50, 0, NIL, ;
              nil, ;
              space(50), NIL, ;
              '            ', , ;
              {|| .f. } })
  if yes_bukva
    aadd(mm_tmp, {'status_st', 'C', 5, 0, '@!', ;
                nil, ;
                space(5), NIL, ;
                'Статус стоматологического больного'})
  endif
  aadd(mm_tmp, {'diag', 'C', 5, 0, '@!', ;
              nil, ;
              space(5), NIL, ;
              'Шифр диагноза (осн.+сопут.): [ с ]', ;
              {|| val2_10diag() }})
  aadd(mm_tmp, {'diag1', 'C', 5, 0, '@!', ;
              nil, ;
              space(5), NIL, ;
              '                            [ по ]', ;
              {|| val2_10diag() }})
  aadd(mm_tmp, {'kod_diag', 'C', 5, 0, '@!', ;
              nil, ;
              space(5), NIL, ;
              'Шифр ОСНОВНОГО диагноза: [ с ]', ;
              {|| val2_10diag() }})
  aadd(mm_tmp, {'kod_diag1', 'C', 5, 0, '@!', ;
              nil, ;
              space(5), NIL, ;
              '                        [ по ]', ;
              {|| val2_10diag() }})
  aadd(mm_tmp, {'soput_d', 'C', 5, 0, '@!', ;
              nil, ;
              space(5), NIL, ;
              'Шифр СОПУТСТВУЮЩЕГО диагноза: [ с ]', ;
              {|| val2_10diag() }})
  aadd(mm_tmp, {'soput_d1', 'C', 5, 0, '@!', ;
              nil, ;
              space(5), NIL, ;
              '                             [ по ]', ;
              {|| val2_10diag() }})
  aadd(mm_tmp, {'osl_d', 'C', 5, 0, '@!', ;
              nil, ;
              space(5), NIL, ;
              'Шифр диагноза ОСЛОЖНЕНИЯ: [ с ]', ;
              {|| val2_10diag() }})
  aadd(mm_tmp, {'osl_d1', 'C', 5, 0, '@!', ;
              nil, ;
              space(5), NIL, ;
              '                         [ по ]', ;
              {|| val2_10diag() }})
  aadd(mm_tmp, {'pred_d', 'C', 5, 0, '@!', ;
              nil, ;
              space(5), NIL, ;
              'Шифр ПРЕДВАРИТЕЛЬНОГО диагноза: [ с ]', ;
              {|| val2_10diag() }})
  aadd(mm_tmp, {'pred_d1', 'C', 5, 0, '@!', ;
              nil, ;
              space(5), NIL, ;
              '                               [ по ]', ;
              {|| val2_10diag() }})
  if is_talon
    aadd(mm_tmp, {'talon_diag', 'N', 1, 0, NIL, ;
                 {|x| menu_reader(x, {{|k, r, c|f_mn_tal_diag(k, r, c)}}, A__FUNCTION)}, ;
                0, {|| space(10) }, ;
                'Присутствует талон амбулаторного пациента?', , ;
                {|| !emptyall(mdiag, mkod_diag, msoput_d) } })
  endif
  aadd(mm_tmp, {'otd', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, { { |k, r, c| get_otd(k, r + 1, c) }}, A__FUNCTION)}, ;
              0, {|| space(10) }, ;
              'Отделение, в котором выписан счет' })
  aadd(mm_tmp, {'ist_fin', 'N', 2, 0, NIL, ;
              {|x| menu_reader(x, mm_ist_fin, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              'Источник финансирования'})
  aadd(mm_tmp, {'komu', 'N', 2, 0, NIL, ;
              {|x| menu_reader(x, mm_komu, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              'Принадлежность счёта', ;
              {|g, o| f_valid_komu(g, o) }})
  aadd(mm_tmp, {'company', 'N', 5, 0, NIL, ;
              {|x| menu_reader(x, mm_company, A__MENUVERT)}, ;
              0, {|| space(10) }, ;
              '  ==>', , {||eq_any(m1komu, 0, 1, 3)}})
  aadd(mm_tmp, {'uslugi', 'N', 4, 0, NIL, ;
              {|x| menu_reader(x, { { |k, r, c| ob2_v_usl(.t., r + 1,'Услуги (ТФОМС)') }}, A__FUNCTION)}, ;
              0, {|| space(10) }, ;
              'Оказанные услуги (ТФОМС)' })
  aadd(mm_tmp, {'uslugiF', 'N', 4, 0, NIL, ;
              {|x| menu_reader(x, { { |k, r, c| obF2_v_usl(.t., r + 1,'Услуги (ФФОМС)', 'tmpF') }}, A__FUNCTION)}, ;
              0, {|| space(10) }, ;
              'Оказанные услуги (ФФОМС)' })
  aadd(mm_tmp, {'dom', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_dom, A__MENUVERT)}, ;
              0, {|x| inieditspr(A__MENUVERT, mm_dom, x)}, ;
              'Где оказана услуга', , ;
              {|| m1usl_ok == 3 }})
  aadd(mm_tmp, {'otd_usl', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, { { |k, r, c| get_otd(k,r + 1, c) }}, A__FUNCTION)}, ;
              0, {|| space(10) }, ;
              'Отделение, в котором оказана услуга' })
  aadd(mm_tmp, {'vr1', 'N', 5, 0, NIL, ;
              nil, ;
              0, NIL, ;
              'Врач, оказавший услугу(и)', ;
              {|g| st_v_vrach(g, 'mvr') } })
  aadd(mm_tmp, {'vr', 'C', 50, 0, NIL, ;
              nil, ;
              space(50), NIL, ;
              '                         ', , ;
              {|| .f. } })
  aadd(mm_tmp, {'isvr', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_da_net, A__MENUVERT)}, ;
              0, {|| space(10) }, ;
              'Код врача проставлен?', , ;
              {|| mvr1 == 0 } })
  aadd(mm_tmp, {'as1', 'N', 5, 0, NIL, ;
              nil, ;
              0, NIL, ;
              'Ассистент, оказавший услугу(и)', ;
              {|g| st_v_vrach(g, 'mas') } })
  aadd(mm_tmp, {'as', 'C', 50, 0, NIL, ;
              nil, ;
              space(50), NIL, ;
              '                              ', , ;
              {|| .f. } })
  aadd(mm_tmp, {'isas', 'N', 1, 0, NIL, ;
              {|x| menu_reader(x, mm_da_net, A__MENUVERT)}, ;
              0, {|| space(10) }, ;
              'Код ассистента проставлен?', , ;
              {|| mas1 == 0 } })
  aadd(mm_tmp, {'vras1', 'N', 5, 0, NIL, ;
              nil, ;
              0, NIL, ;
              'Человек, оказавший услугу(и)', ;
              {|g| st_v_vrach(g, 'mvras') } })
  aadd(mm_tmp, {'vras', 'C', 50, 0, NIL, ;
              nil, ;
              space(50), NIL, ;
              '                            ', , ;
              {|| .f. } })
  aadd(mm_tmp, {'slug_usl', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, ;
                { { |k, r, c| get_slugba(k, r, c) }}, A__FUNCTION)}, ;
              0, {|| space(10) }, ;
              'Служба, в которой оказана услуга' })
  aadd(mm_tmp, {'srok_min', 'N', 3, 0, , ;
              nil, ;
              0, NIL, ;
              'Срок лечения (минимальный)'})
  aadd(mm_tmp, {'srok_max', 'N', 3, 0, , ;
              nil, ;
              0, NIL, ;
              'Срок лечения (максимальный)'})
  aadd(mm_tmp, {'summa_min', 'N', 10, 2, , ;
              nil, ;
              0, NIL, ;
              'Сумма лечения (минимальная)'})
  aadd(mm_tmp, {'summa_max', 'N', 10, 2, , ;
              nil, ;
              0, NIL, ;
              'Сумма лечения (максимальная)'})
  aadd(mm_tmp, {'vid_doc', 'N', 5, 0, NIL, ;
              {|x| menu_reader(x, arr_doc, A__MENUBIT)}, ;
              lvid_doc, {|x| inieditspr(A__MENUBIT, arr_doc, x)}, ;
              'Вид документа', NIL})
  delete file (tmp_file)
  init_base(tmp_file, , mm_tmp, 0)
  //
  R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO')
  k := f_edit_spr(A__APPEND, mm_tmp, 'множественному запросу', ;
                'e_use(cur_dir + "tmp_mn_p")', 0, 1, , , , , 'write_mn_p')
  if k > 0
    mywait()
    use (tmp_file) new alias MN
    if mn->ist_fin >= 0
      Private _arr_if := {mn->ist_fin}, _what_if := _init_if(), _arr_komit := {}
    endif
    if is_talon .and. mn->kategor == 0 .and. mn->talon_diag == 0
      is_talon := (is_kategor2 .and. mn->kategor2 > 0)
    endif
    if yes_vypisan == B_END .and. mn->zav_lech > 0
      Private p_zak_sl := (mn->zav_lech == 2)  // ? законченный случай
      mn->zav_lech := yes_vypisan + mn->zav_lech - 1
    endif
    // заменить таб.номер на код
    R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO')
    if mn->vrach1 > 0
      find (str(mn->vrach1, 5))
      if found()
        mn->vrach1 := perso->kod
      endif
    endif
    if mn->vr1 > 0
      find (str(mn->vr1, 5))
      if found()
        mn->vr1 := perso->kod
      endif
    endif
    if mn->as1 > 0
      find (str(mn->as1, 5))
      if found()
        mn->as1 := perso->kod
      endif
    endif
    if mn->vras1 > 0
      find (str(mn->vras1, 5))
      if found()
        mn->vras1 := perso->kod
      endif
    endif
    perso->(dbCloseArea())
    if mn->date_schet > 0
      p_regim := 2
    elseif mn->date_lech > 0
      p_regim := 1
    elseif mn->date_usl > 0
      p_regim := 3
    endif
    Private much_doc := '', mfio := '', madres := '', mmr_dol := ''
    if !empty(mn->uch_doc)
      much_doc := alltrim(mn->uch_doc)
      if !(right(much_doc, 1) == '*')
        much_doc += '*'
      endif
    endif
    if !empty(mn->fio)
      mfio := alltrim(mn->fio)
      if !(right(mfio, 1) == '*')
        mfio += '*'
      endif
    endif
    if !empty(mn->adres)
      madres := alltrim(mn->adres)
      if !(left(madres, 1) == '*')
        madres := '*'+madres
      endif
      if !(right(madres, 1) == '*')
        madres += '*'
      endif
    endif
    if !empty(mn->mr_dol)
      mmr_dol := alltrim(mn->mr_dol)
      if !(left(mmr_dol, 1) == '*')
        mmr_dol := '*' + mmr_dol
      endif
      if !(right(mmr_dol, 1) == '*')
        mmr_dol += '*'
      endif
    endif
    Private arr_usl := {}, arr_uslF := {}, fl_summa := .t., NUMdiag, NUMdiag1
    // заранее диапазоны диагнозов переведём в числовые значения
    if !emptyall(mn->diag, mn->diag1)
      NUMdiag := diag2num(mn->diag)
      NUMdiag1 := diag2num(mn->diag1)
    endif
    Private NUMkod_diag, NUMkod_diag1
    if !emptyall(mn->kod_diag, mn->kod_diag1)
      NUMkod_diag := diag2num(mn->kod_diag)
      NUMkod_diag1 := diag2num(mn->kod_diag1)
    endif
    Private NUMsoput_d, NUMsoput_d1
    if !emptyall(mn->soput_d, mn->soput_d1)
      NUMsoput_d := diag2num(mn->soput_d)
      NUMsoput_d1 := diag2num(mn->soput_d1)
    endif
    Private NUMpred_d, NUMpred_d1
    if !emptyall(mn->pred_d, mn->pred_d1)
      NUMpred_d := diag2num(mn->pred_d)
      NUMpred_d1 := diag2num(mn->pred_d1)
    endif
    Private NUMosl_d, NUMosl_d1
    if !emptyall(mn->osl_d, mn->osl_d1)
      NUMosl_d := diag2num(mn->osl_d)
      NUMosl_d1 := diag2num(mn->osl_d1)
    endif
    if mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. ;
         mn->vras1 > 0 .or. mn->slug_usl > 0 .or. mn->uslugi > 0 .or. mn->uslugiF > 0 .or. mn->dom > 0
      fl_summa := .f.
    endif
    if mn->uslugi > 0
      fl_rak_usl := .f.
      use (cur_dir + 'tmp') index (cur_dir + 'tmpn') new
      go top
      dbeval({|| aadd(arr_usl, {tmp->u_kod, tmp->u_shifr, tmp->u_name, 0, 0, 0}), ;
               iif(left(tmp->u_shifr, 3) == '71.', fl_rak_usl := .t., ) ;
           })
      tmp->(dbCloseArea())
      if !isbit(mn->vid_doc, 6)
        fl_rak_usl := .f.
      endif
    endif
    if mn->uslugiF > 0
      use (cur_dir + 'tmpF') index (cur_dir + 'tmpFn') new
      go top
      dbeval({|| aadd(arr_uslF, {tmpf->u_kod, tmpf->u_shifr, tmpf->u_name, 0, 0, 0})})
      tmpf->(dbCloseArea())
    endif
    flag_hu := (mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. mn->vras1 > 0 .or. ;
              mn->slug_usl > 0 .or. mn->uslugi > 0 .or. mn->dom > 0 .or. ;
              mn->kol_pos == 2 .or. mn->date_usl > 0 .or. mn->profil_u > 0)
    flag_huF := (mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. mn->vras1 > 0 .or. ;
               mn->uslugiF > 0 .or. mn->dom > 0 .or. ;
               mn->kol_pos == 2 .or. mn->date_usl > 0 .or. mn->profil_u > 0)
    dbcreate(cur_dir + 'tmp', {{'kod',      'N', 7, 0}, ;
                          {'kod_k',    'N', 7, 0}, ;
                          {'stoim',    'N', 10, 2}, ;
                          {'rak_p',    'N', 3, 0}, ;
                          {'rak_s',    'N', 10, 2}})
    use (cur_dir + 'tmp') new
    dbcreate(cur_dir + 'tmp_k', {{'kod_k', 'N', 7, 0}, ;
                            {'kol',  'N', 6, 0}})
    use (cur_dir + 'tmp_k') new
    index on str(kod_k, 7) to (cur_dir + 'tmp_k')
    if mn->kol_pos == 2
      Private kol_pos_amb := 0, pol_pos_stom1 := 0, pol_pos_stom2 := 0, pol_pos_stom3 := 0
      dbcreate(cur_dir + 'tmp_kp', {{'kod_k', 'N', 7, 0}, ;
                               {'data', 'C', 4, 0}})
      use (cur_dir + 'tmp_kp') new
      index on str(kod_k, 7)+data to (cur_dir + 'tmp_kp')
    endif
    f1_diag_statist_bukva()
    fl_exit := .f.
    if p_regim == 3  // по дате оказания усуги
      dbcreate(cur_dir + 'tmp_hum', {{'kod', 'N', 7, 0}})
      use (cur_dir + 'tmp_hum') new
      R_Use(dir_server + 'human_u', dir_server + 'human_ud', 'HU')
      find (pdate_usl[7])
      index on kod to (cur_dir + 'tmp_hu') while date_u <= pdate_usl[8] UNIQUE
      go top
      do while !eof()
        select TMP_HUM
        append blank
        replace kod with hu->kod
        select HU
        skip
      enddo
      hu->(dbCloseArea())
      tmp_hum->(dbCloseArea())
    endif
    if mem_trudoem == 2
      useUch_Usl()
    endif
    Status_Key('^<Esc>^ - прервать поиск')
    if isbit(mn->vid_doc, 6) .or. mn->rak > 0
      R_Use(dir_server + 'mo_raksh', , 'RAKSH')
      index on str(kod_h, 7) to (cur_dir + 'tmp_raksh')
    endif
    use_base('lusl')
    use_base('luslc')
    use_base('luslf')
    R_Use(dir_server + 'mo_su', , 'MOSU')
    R_Use(dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU')
    R_Use(dir_server + 'uslugi', , 'USL')
    R_Use(dir_server + 'human_u_', , 'HU_')
    R_Use(dir_server + 'human_u', dir_server + 'human_u', 'HU')
    set relation to recno() into HU_, to u_kod into USL
    //
    R_Use(dir_server + 'schet_', , 'SCHET_')
    R_Use(dir_server + 'schet', , 'SCHET')
    set relation to recno() into SCHET_
    //
    R_Use(dir_server + 'kartote2', , 'KART2')
    R_Use(dir_server + 'kartote_', , 'KART_')
    R_Use(dir_server + 'kartotek', , 'KART')
    set relation to recno() into KART_, recno() into KART2
    //
    R_Use(dir_server + 'human_3', {dir_server + 'human_3', dir_server + 'human_32'}, 'HUMAN_3')
    R_Use(dir_server + 'human_', , 'HUMAN_')
    R_Use(dir_server + 'human_2', , 'HUMAN_2')
    R_Use(dir_server + 'human', , 'HUMAN')
    set relation to recno() into HUMAN_, to recno() into HUMAN_2
    //
    Private c_view := 0, c_found := 0
    do case
      case p_regim == 1  // по дате окончания лечения
        select HUMAN
        set index to (dir_server + 'humand')
        dbseek(dtos(pdate_lech[5]), .t.)
        do while human->k_data <= pdate_lech[6] .and. !eof()
          if inkey() == K_ESC
            fl_exit := .t.
            exit
          endif
          if f_is_uch(st_a_uch, human->lpu)
            date_24(human->k_data)
            s1_mnog_poisk(@c_view, @c_found)
          endif
          select HUMAN
          skip
        enddo
      case p_regim == 2  // по дате выписки счета
        select HUMAN
        set index to (dir_server + 'humans')
        select SCHET
        set index to (dir_server + 'schetd')
        set filter to empty(schet_->IS_DOPLATA)
        dbseek(pdate_schet[7], .t.)
        do while schet->pdate <= pdate_schet[8] .and. !eof()
          date_24(c4tod(schet->pdate))
          select HUMAN
          find (str(schet->kod, 6))
          do while human->schet == schet->kod
            if inkey() == K_ESC
              fl_exit := .t.
              exit
            endif
            if f_is_uch(st_a_uch, human->lpu)
              s1_mnog_poisk(@c_view, @c_found)
            endif
            select HUMAN
            skip
          enddo
          if fl_exit
            exit
          endif
          select SCHET
          skip
        enddo
      case p_regim == 3  // по дате оказания усуги
        use (cur_dir + 'tmp_hum') new
        set relation to kod into HUMAN
        go top
        do while !eof()
          if inkey() == K_ESC
            fl_exit := .t.
            exit
          endif
          if f_is_uch(st_a_uch, human->lpu)
            date_24(human->k_data)
            s1_mnog_poisk(@c_view, @c_found)
          endif
          select TMP_HUM
          skip
        enddo
    endcase
    j := tmp->(lastrec())
    close databases
    if j == 0
      if ! fl_exit
        func_error(4, 'Нет сведений!')
      endif
    else
      mywait()
      if lExcel
        workbook  := WORKBOOK_NEW(name_fileXLS_full)
        wsCommon := WORKBOOK_ADD_WORKSHEET(workbook, hb_StrToUtf8('Описание'))
        WORKSHEET_SET_COLUMN(wsCommon, 7, 7, 15, nil)
        wsCommon_format := WORKBOOK_ADD_FORMAT(workbook)
        format_set_align(wsCommon_format, LXW_ALIGN_CENTER)
        format_set_align(wsCommon_format, LXW_ALIGN_VERTICAL_CENTER)
        FORMAT_SET_BOLD(wsCommon_format)

        wsCommon_format_wrap := WORKBOOK_ADD_FORMAT(workbook)
        format_set_align(wsCommon_format_wrap, LXW_ALIGN_LEFT)
        format_set_align(wsCommon_format_wrap, LXW_ALIGN_VERTICAL_CENTER)
        format_set_text_wrap(wsCommon_format_wrap)

        wsCommon_format_header := WORKBOOK_ADD_FORMAT(workbook)
        format_set_align(wsCommon_format_header, LXW_ALIGN_CENTER)
        format_set_align(wsCommon_format_header, LXW_ALIGN_VERTICAL_CENTER)
        FORMAT_SET_BOLD(wsCommon_format_header)
        FORMAT_SET_FONT_SIZE(wsCommon_format_header, 20)

        wsCommon_Number := WORKBOOK_ADD_FORMAT(workbook)
        FORMAT_SET_ALIGN(wsCommon_Number, LXW_ALIGN_CENTER)
        FORMAT_SET_ALIGN(wsCommon_Number, LXW_ALIGN_VERTICAL_CENTER)

        wsCommon_Number_Rub := WORKBOOK_ADD_FORMAT(workbook)
        FORMAT_SET_ALIGN(wsCommon_Number_Rub, LXW_ALIGN_RIGHT)
        FORMAT_SET_ALIGN(wsCommon_Number_Rub, LXW_ALIGN_VERTICAL_CENTER)
        FORMAT_SET_NUM_FORMAT(wsCommon_Number_Rub, '#,##0.00')
        
        worksheet := WORKBOOK_ADD_WORKSHEET(workbook, hb_StrToUtf8('Список пациентов'))
        formatDate := WORKBOOK_ADD_FORMAT(workbook)
        FORMAT_SET_NUM_FORMAT(formatDate, 'dd/mm/yyyy')
        FORMAT_SET_ALIGN(formatDate, LXW_ALIGN_CENTER)
        FORMAT_SET_ALIGN(formatDate, LXW_ALIGN_VERTICAL_CENTER)
        FORMAT_SET_BORDER(formatDate, LXW_BORDER_THIN)
      
        header = WORKBOOK_ADD_FORMAT(workbook)
        FORMAT_SET_ALIGN(header, LXW_ALIGN_CENTER)
        FORMAT_SET_ALIGN(header, LXW_ALIGN_VERTICAL_CENTER)
        FORMAT_SET_FG_COLOR(header, 0xD7E4BC)
        FORMAT_SET_BOLD(header)
        FORMAT_SET_BORDER(header, LXW_BORDER_THIN)
      
        header_wrap = WORKBOOK_ADD_FORMAT(workbook)
        FORMAT_SET_ALIGN(header_wrap, LXW_ALIGN_CENTER)
        FORMAT_SET_ALIGN(header_wrap, LXW_ALIGN_VERTICAL_CENTER)
        FORMAT_SET_FG_COLOR(header_wrap, 0xD7E4BC)
        FORMAT_SET_BOLD(header_wrap)
        FORMAT_SET_BORDER(header_wrap, LXW_BORDER_THIN)
        FORMAT_SET_TEXT_WRAP(header_wrap)
      
        fmtCellNumber := WORKBOOK_ADD_FORMAT(workbook)
        FORMAT_SET_ALIGN(fmtCellNumber, LXW_ALIGN_CENTER)
        FORMAT_SET_ALIGN(fmtCellNumber, LXW_ALIGN_VERTICAL_CENTER)
        FORMAT_SET_BORDER(fmtCellNumber, LXW_BORDER_THIN)

        fmtCellNumberRub := WORKBOOK_ADD_FORMAT(workbook)
        FORMAT_SET_ALIGN(fmtCellNumberRub, LXW_ALIGN_RIGHT)
        FORMAT_SET_ALIGN(fmtCellNumberRub, LXW_ALIGN_VERTICAL_CENTER)
        FORMAT_SET_BORDER(fmtCellNumberRub, LXW_BORDER_THIN)
        FORMAT_SET_NUM_FORMAT(fmtCellNumberRub, '#,##0.00')
        
        fmtCellString := WORKBOOK_ADD_FORMAT(workbook)
        FORMAT_SET_ALIGN(fmtCellString, LXW_ALIGN_LEFT)
        FORMAT_SET_ALIGN(fmtCellString, LXW_ALIGN_VERTICAL_CENTER)
        FORMAT_SET_TEXT_WRAP(fmtCellString)
        FORMAT_SET_BORDER(fmtCellString, LXW_BORDER_THIN)
      
        fmtCellStringCenter := WORKBOOK_ADD_FORMAT(workbook)
        FORMAT_SET_ALIGN(fmtCellStringCenter, LXW_ALIGN_CENTER)
        FORMAT_SET_ALIGN(fmtCellStringCenter, LXW_ALIGN_VERTICAL_CENTER)
        FORMAT_SET_TEXT_WRAP(fmtCellStringCenter)
        FORMAT_SET_BORDER(fmtCellStringCenter, LXW_BORDER_THIN)

        /* Заморозим верхнюю строку на закладке. */
        // WORKSHEET_FREEZE_PANES(worksheet, row, 0)
      endif
      row := 0
      column := 0
      rowWS := 1
      columnWS := 0
      use (tmp_file) new alias MN
      s1 := if(fl_summa, '  Сумма  ', 'Стоимость')
      s2 := if(fl_summa, ' лечения ', '  услуг  ')
      arr_title := { ;
        '────────────────────────────────────────┬─────────', ;
        '             Ф.И.О. больного            │'+ s1     , ;
        '                                        │'+ s2     , ;
        '────────────────────────────────────────┴─────────'}
      if lExcel
        // WORKSHEET_SET_COLUMN(worksheet, row, column, 100, nil)
        WORKSHEET_SET_COLUMN(worksheet, column, column, 35, nil)
        WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('Ф.И.О. больного'), header)
        WORKSHEET_SET_COLUMN(worksheet, column, column, 22, nil)
        WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('СМО'), header)
        WORKSHEET_SET_COLUMN(worksheet, column, column, 15, nil)
        WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('СНИЛС'), header)
        WORKSHEET_SET_COLUMN(worksheet, column, column, 11, nil)
        WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(iif(fl_summa, 'Сумма лечения', 'Стоимость услуг')), header_wrap)
      endif
      if isbit(mn->vid_doc, 1)
        arr_title[1] += '┬────────'
        arr_title[2] += '│  Дата  '
        arr_title[3] += '│рождения'
        arr_title[4] += '┴────────'
        if lExcel
          WORKSHEET_SET_COLUMN(worksheet, column, column, 10.0, nil)
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('Дата рождения'), header_wrap)
        endif
      endif
      if isbit(mn->vid_doc, 2)
        arr_title[1] += '┬────────────────────────'
        arr_title[2] += '│         Адрес          '
        arr_title[3] += '│                        '
        arr_title[4] += '┴────────────────────────'
        if lExcel
          WORKSHEET_SET_COLUMN(worksheet, column, column, 22.0, nil)
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('Адрес'), header)
        endif
      endif
      if isbit(mn->vid_doc, 12)
        arr_title[1] += '┬──────────'
        arr_title[2] += '│   Номера '
        arr_title[3] += '│ телефонов'
        arr_title[4] += '┴──────────'
        if lExcel
          WORKSHEET_SET_COLUMN(worksheet, column, column, 11.0, nil)
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('Номера телефонов'), header_wrap)
        endif
      endif
      if isbit(mn->vid_doc, 3)
        arr_title[1] += '┬──────────'
        arr_title[2] += '│  N карты '
        arr_title[3] += '│          '
        arr_title[4] += '┴──────────'
        if lExcel
          WORKSHEET_SET_COLUMN(worksheet, column, column, 10.0, nil)
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('N карты'), header)
        endif
      endif
      if isbit(mn->vid_doc, 4)
        arr_title[1] += '┬────────'
        arr_title[2] += '│ Сроки  '
        arr_title[3] += '│лечения '
        arr_title[4] += '┴────────'
        if lExcel
          WORKSHEET_SET_COLUMN(worksheet, column, column, 10.0, nil)
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('Сроки лечения'), header_wrap)
        endif
      endif
      if isbit(mn->vid_doc, 5)
        arr_title[1] += '┬─────────────'
        arr_title[2] += '│   Диагноз   '
        arr_title[3] += '│             '
        arr_title[4] += '┴─────────────'
        if lExcel
          WORKSHEET_SET_COLUMN(worksheet, column, column, 11, nil)
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('Диагноз'), header)
        endif
      endif
      if isbit(mn->vid_doc, 6)
        arr_title[1] += '┬───────────────'
        arr_title[2] += '│ Номер и дата  '
        arr_title[3] += '│    счета      '
        arr_title[4] += '┴───────────────'
        if lExcel
          WORKSHEET_SET_COLUMN(worksheet, column, column, 19.0, nil)
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('Номер и дата счета'), header_wrap)
        endif
      endif
      if isbit(mn->vid_doc, 7)
        arr_title[1] += '┬─────────'
        arr_title[2] += '│   РАК   '
        arr_title[3] += '│         '
        arr_title[4] += '┴─────────'
        R_Use(dir_server + 'mo_raksh', cur_dir + 'tmp_raksh', 'RAKSH')
        if lExcel
          WORKSHEET_SET_COLUMN(worksheet, column, column, 13.0, nil)
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('РАК'), header_wrap)
        endif
      endif
      if isbit(mn->vid_doc, 8)
        arr_title[1] += '┬─────'
        arr_title[2] += '│ Леч.'
        arr_title[3] += '│ врач'
        arr_title[4] += '┴─────'
        if lExcel
          WORKSHEET_SET_COLUMN(worksheet, column, column, 10.0, nil)
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('Леч. врач'), header_wrap)
        endif
      endif
      if isbit(mn->vid_doc, 9)
        arr_title[1] += '┬───────────────────────'
        arr_title[2] += '│                       '
        arr_title[3] += '│     Список услуг      '
        arr_title[4] += '┴───────────────────────'
        if lExcel
          WORKSHEET_SET_COLUMN(worksheet, column, column, 10.0, nil)
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('Список услуг'), header_wrap)
        endif
      endif
      if isbit(mn->vid_doc, 10)
        arr_title[1] += '┬────────'
        arr_title[2] += '│Дополнит'
        arr_title[3] += '│критерий'
        arr_title[4] += '┴────────'
        if lExcel
          WORKSHEET_SET_COLUMN(worksheet, column, column, 10.0, nil)
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('Дополнит. критерий'), header_wrap)
        endif
      endif
      if yes_parol
        if isbit(mn->vid_doc, 11)
          arr_title[1] += '┬──────────'
          arr_title[2] += '│Дата ввода'
          arr_title[3] += '│и оператор'
          arr_title[4] += '┴──────────'
          if lExcel
            WORKSHEET_SET_COLUMN(worksheet, column, column, 10.0, nil)
            WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('Дата ввода и оператор'), header_wrap)
          endif
        endif
      endif
      reg_print := f_reg_print(arr_title, @sh, 2)
      if sh < 65
        sh := 65
      endif
      R_Use(dir_server + 'human_u_', , 'HU_')
      R_Use(dir_server + 'human_u', dir_server + 'human_u', 'HU')
      set relation to recno() into HU_
      R_Use(dir_server + 'uslugi', , 'USL')
      R_Use(dir_server + 'mo_su', , 'MOSU')
      R_Use(dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU')
      R_Use(dir_server + 'schet_', , 'SCHET_')
      R_Use(dir_server + 'schet', , 'SCHET')
      set relation to recno() into SCHET_
      if yes_parol
        R_Use(dir_server + 'base1', , 'BASE1')
      endif
      dbcreate(cur_dir + '_MNPOISK', {{'dd0', 'C', 100, 0}, ; // ФИО.
                                   {'dd00', 'C', 20, 0}, ;
                                   {'dd01', 'C', 150, 0}, ;
                                   {'dd02', 'C', 30, 0}, ;
                                   {'dd1', 'C', 10, 0}, ; // Дата рожд.
                                   {'dd2', 'C', 50, 0}, ; // Адрес
                                   {'dd12', 'C', 35, 0}, ; // Телефон
                                   {'dd3', 'C', 10, 0}, ; // Номер карты
                                   {'dd4', 'C', 35, 0}, ; // Сроки леч.
                                   {'dd5', 'C', 40, 0}, ; // Диагноз
                                   {'dd6', 'C', 30, 0}, ; // Счет
                                   {'dd60', 'C', 30, 0}, ;
                                   {'dd61', 'C',  6, 0}, ;  // CМО  
                                   {'dd62', 'C',  6, 0}, ;  // N в счете
                                   {'dd7', 'C', 30, 0}, ; // РАК 
                                   {'dd8', 'C', 40, 0}, ; // Лечащий врач
                                   {'dd9', 'C', 80, 0}, ; // услуги
                                   {'dd10', 'C', 50, 0}, ; // Доп.критерий
                                   {'dd11', 'C', 10, 0}}) // Дата ввода
      use _MNPOISK new alias VIGRUZKA
      R_Use(dir_server + 'mo_pers', , 'PERSO')
      R_Use(dir_server + 'kartote2', , 'KART2')
      R_Use(dir_server + 'kartote_', , 'KART_')
      R_Use(dir_server + 'kartotek', , 'KART')
      set relation to recno() into KART_, to recno() into KART2
      R_Use(dir_server + 'mo_onksl', dir_server + 'mo_onksl', 'ONKSL') // Сведения о случае лечения онкологического заболевания
      R_Use(dir_server + 'human_3', {dir_server + 'human_3', dir_server + 'human_32'}, 'HUMAN_3')
      R_Use(dir_server + 'human_2', , 'HUMAN_2')
      R_Use(dir_server + 'human_', , 'HUMAN_')
      R_Use(dir_server + 'human', dir_server + 'humank', 'HUMAN')
      set relation to recno() into HUMAN_, to recno() into HUMAN_2
      fp := fcreate(name_file)
      n_list := 1
      tek_stroke := 0
      add_string('')
      add_string(center(expand('РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА'), sh))
      titleN_uch(st_a_uch, sh, lcount_uch)
      add_string('')
      add_string(' == ПАРАМЕТРЫ ПОИСКА ==')

      if lExcel
        WORKSHEET_MERGE_RANGE(wsCommon, rowWS, columnWS, rowWS, 12, '', wsCommon_format_header)
        WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8(expand('РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА')), wsCommon_format_header)
        titleN_uchEXCEL(wsCommon, rowWS++, columnWS, st_a_uch, sh, lcount_uch)
        rowWS++
        WORKSHEET_MERGE_RANGE(wsCommon, rowWS, columnWS, rowWS, 12, '', wsCommon_format)
        WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('== ПАРАМЕТРЫ ПОИСКА =='), wsCommon_format)
      endif

      if mn->date_lech > 0
        add_string('Дата окончания лечения: ' + pdate_lech[4])
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Дата окончания лечения: ' + pdate_lech[4]), nil)
        endif
      endif
      if mn->date_schet > 0
        add_string('Дата выписки счета: ' + pdate_schet[4])
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Дата выписки счета: ' + pdate_schet[4]), nil)
        endif
      endif
      if mn->date_usl > 0
        add_string('Дата оказания услуг: ' + pdate_usl[4])
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Дата оказания услуг: ' + pdate_usl[4]), nil)
        endif
      endif
      if mn->perevyst != 1
        add_string(upper(inieditspr(A__MENUVERT, mm_perevyst, mn->perevyst)))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8(upper(inieditspr(A__MENUVERT, mm_perevyst, mn->perevyst))), nil)
        endif
      endif
      if mn->rak > 0
        add_string(upper(inieditspr(A__MENUVERT, mm_rak, mn->rak)))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8(upper(inieditspr(A__MENUVERT, mm_rak, mn->rak))), nil)
        endif
      endif
      if yes_vypisan == B_END .and. mn->zav_lech > 0
        add_string('Лечение завершено?: ' + iif(mn->zav_lech == B_STANDART, 'да', 'нет'))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Лечение завершено?: ' + iif(mn->zav_lech == B_STANDART, 'да', 'нет')), nil)
        endif
      endif
      if mn->reestr > 0
        add_string(inieditspr(A__MENUVERT, mm_reestr, mn->reestr))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8(inieditspr(A__MENUVERT, mm_reestr, mn->reestr)), nil)
        endif
      endif
      if mn->schet > 0
        add_string(inieditspr(A__MENUVERT, mm_schet, mn->schet))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8(inieditspr(A__MENUVERT, mm_schet, mn->schet)), nil)
        endif
        if mn->schet == 2 .and. mn->regschet > 0
          add_string(inieditspr(A__MENUVERT, mm_regschet, mn->regschet))
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8(inieditspr(A__MENUVERT, mm_regschet, mn->regschet)), nil)
          endif
        endif
      endif
      if mn->d_p_m > 0
        s := 'Диспансеризация/Профилактика/Медосмотр?: ' + ;
            inieditspr(A__MENUBIT, mm_d_p_m, mn->d_p_m)
        k := perenos(a_diagnoz, s, sh)
        add_string(a_diagnoz[1])
        for i := 2 to k
          add_string(padl(alltrim(a_diagnoz[i]), sh))
        next
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8(s), nil)
        endif
      endif
      if mn->pz > 0
        add_string('Вид план-заказа: ' + inieditspr(A__MENUVERT, mm_pz, mn->pz))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Вид план-заказа: ' + inieditspr(A__MENUVERT, mm_pz, mn->pz)), nil)
        endif
      endif
      if mn->dvojn > 1
        add_string('Двойные случаи: ' + inieditspr(A__MENUVERT, mm_dvojn, mn->dvojn))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Двойные случаи: ' + inieditspr(A__MENUVERT, mm_dvojn, mn->dvojn)), nil)
        endif
      endif
      if mn->zno == 2
        add_string('Признак подорения на злокачественное новообразование: да')
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Признак подорения на злокачественное новообразование: да'), nil)
        endif
      endif
      if mn->kol_lu > 0
        add_string('Количество листов учета по одному больному более ' + lstr(mn->kol_lu))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Количество листов учета по одному больному более ' + lstr(mn->kol_lu)), nil)
        endif
      endif
      if !empty(much_doc)
        add_string('№ амб.карты/истории болезни: ' + much_doc)
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('№ амб.карты/истории болезни: ' + much_doc), nil)
        endif
      endif
      if is_uchastok > 0
        if !empty(mn->bukva)
          add_string('Буква: ' + mn->bukva)
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Буква: ' + mn->bukva), nil)
          endif
        endif
        if !empty(mn->uchast)
          add_string('Участок: ' + init_uchast(arr_uchast))
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Участок: ' + init_uchast(arr_uchast)), nil)
          endif
        endif
      endif
      if glob_mo[_MO_IS_UCH] .and. !empty(mn->o_prik)
        add_string('Отношение к прикреплению: ' + inieditspr(A__MENUVERT, mm_prik, mn->o_prik))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Отношение к прикреплению: ' + inieditspr(A__MENUVERT, mm_prik, mn->o_prik)), nil)
        endif
      endif
      if !empty(mfio)
        add_string('ФИО: ' + mfio)
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('ФИО: ' + mfio), nil)
        endif
      endif
      if mn->inostran > 0
        add_string('Документы иностранных граждан: ' + inieditspr(A__MENUVERT, mm_da_net, mn->inostran))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Документы иностранных граждан: ' + inieditspr(A__MENUVERT, mm_da_net, mn->inostran)), nil)
        endif
      endif
      if mn->gorod_selo > 0
        add_string('Житель: ' + inieditspr(A__MENUVERT, mm_g_selo, mn->gorod_selo))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Житель: ' + inieditspr(A__MENUVERT, mm_g_selo, mn->gorod_selo)), nil)
        endif
      endif
      if mn->mi_git > 0
        add_string('Место жительства: ' + inieditspr(A__MENUVERT, mm_mest, mn->mi_git))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Место жительства: ' + inieditspr(A__MENUVERT, mm_mest, mn->mi_git)), nil)
        endif
      endif
      if !empty(mn->_okato)
        add_string('Адрес регистрации (ОКАТО): ' + ret_okato_ulica('', mn->_okato))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Адрес регистрации (ОКАТО): ' + ret_okato_ulica('', mn->_okato)), nil)
        endif
      endif
      if !empty(madres)
        add_string('Улица: ' + madres)
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Улица: ' + madres), nil)
        endif
      endif
      if !empty(mmr_dol)
        add_string('Место работы: ' + mmr_dol)
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Место работы: ' + mmr_dol), nil)
        endif
      endif
      if mn->invalid > 0
        add_string('Наличие инвалидности: ' + inieditspr(A__MENUVERT, mm_invalid, mn->invalid))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Наличие инвалидности: ' + inieditspr(A__MENUVERT, mm_invalid, mn->invalid)), nil)
        endif
      endif
      if mn->kategor > 0
        add_string('Код категории льготы: ' + inieditspr(A__MENUVERT, stm_kategor, mn->kategor))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Код категории льготы: ' + inieditspr(A__MENUVERT, stm_kategor, mn->kategor)), nil)
        endif
      endif
      if is_talon .and. is_kategor2 .and. mn->kategor2 > 0
        add_string('Категория МО: ' + inieditspr(A__MENUVERT, stm_kategor2, mn->kategor2))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Категория МО: ' + inieditspr(A__MENUVERT, stm_kategor2, mn->kategor2)), nil)
        endif
      endif
      if !empty(mn->pol)
        add_string('Пол: ' + iif(upper(mn->pol) == 'М', 'мужской', 'женский'))
        if lExcel
          // WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Пол: ' + mn->pol), nil)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, columnWS, hb_StrToUtf8('Пол:'), nil)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, 1, hb_StrToUtf8(iif(upper(mn->pol) == 'М', 'мужской', 'женский')), nil)
        endif
      endif
      if mn->vzros_reb >= 0
        add_string('Возрастная принадлежность: ' + inieditspr(A__MENUVERT, menu_vzros, mn->vzros_reb))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Возрастная принадлежность: ' + inieditspr(A__MENUVERT, menu_vzros, mn->vzros_reb)), nil)
        endif
      endif
      if !empty(mn->god_r_min) .or. !empty(mn->god_r_max)
        if empty(mn->god_r_min)
          add_string('Лица, родившиеся до ' + full_date(mn->god_r_max))
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Лица, родившиеся до ' + full_date(mn->god_r_max)), nil)
          endif
        elseif empty(mn->god_r_max)
          add_string('Лица, родившиеся после ' + full_date(mn->god_r_min))
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Лица, родившиеся после ' + full_date(mn->god_r_min)), nil)
          endif
        else
          add_string('Лица, родившиеся с ' + full_date(mn->god_r_min) + ' по ' + full_date(mn->god_r_max))
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Лица, родившиеся с ' + full_date(mn->god_r_min) + ' по ' + full_date(mn->god_r_max)), nil)
          endif
        endif
      endif
      if mn->rab_nerab >= 0
        add_string(upper(inieditspr(A__MENUVERT, menu_rab, mn->rab_nerab)))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8(upper(inieditspr(A__MENUVERT, menu_rab, mn->rab_nerab))), nil)
        endif
      endif
      if mn->USL_OK > 0
        add_string('Условия оказания: ' + inieditspr(A__MENUVERT, tmp_V006, mn->USL_OK))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Условия оказания: ' + inieditspr(A__MENUVERT, tmp_V006, mn->USL_OK)), nil)
        endif
      endif
      /*if mn->VIDPOM > 0
        add_string('Вид помощи: ' + inieditspr(A__MENUVERT, tmp_V008, mn->VIDPOM))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Вид помощи: ' + inieditspr(A__MENUVERT, tmp_V008, mn->VIDPOM)), nil)
        endif
      endif*/
      if mn->PROFIL > 0
        add_string('Профиль (в случае): ' + inieditspr(A__MENUVERT, tmp_V002, mn->PROFIL))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Профиль (в случае): ' + inieditspr(A__MENUVERT, tmp_V002, mn->PROFIL)), nil)
        endif
      endif
      if mn->PROFIL_U > 0
        add_string('Профиль (в услуге): ' + inieditspr(A__MENUVERT, tmp_V002, mn->PROFIL_U))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Профиль (в услуге): ' + inieditspr(A__MENUVERT, tmp_V002, mn->PROFIL_U)), nil)
        endif
      endif
      /*if mn->IDSP > 0
        add_string('Способ оплаты: ' + inieditspr(A__MENUVERT, tmp_V010, mn->IDSP))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Способ оплаты: ' + inieditspr(A__MENUVERT, tmp_V010, mn->IDSP)), nil)
        endif
      endif*/
      if mn->rslt > 0
        add_string('Результат обращения: ' + inieditspr(A__MENUVERT, mm_rslt, mn->rslt))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Результат обращения: ' + inieditspr(A__MENUVERT, mm_rslt, mn->rslt)), nil)
        endif
      endif
      if mn->ishod > 0
        add_string('Исход заболевания: ' + inieditspr(A__MENUVERT, mm_ishod, mn->ishod))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Исход заболевания: ' + inieditspr(A__MENUVERT, mm_ishod, mn->ishod)), nil)
        endif
      endif
      /*if is_talon .and. mn->povod > 0
        add_string('Повод обращения: '+;
                 inieditspr(A__MENUVERT, stm_povod, mn->povod))
      endif
      if is_talon .and. mn->travma > 0
        add_string('Вид травмы: '+;
                 inieditspr(A__MENUVERT, stm_travma, mn->travma))
      endif*/
      if mn->bolnich1 > 0
        add_string('Больничный: ' + inieditspr(A__MENUVERT, menu_bolnich, mn->bolnich1))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Больничный: ' + inieditspr(A__MENUVERT, menu_bolnich, mn->bolnich1)), nil)
        endif
      endif
      if mn->bolnich > 0
        add_string('Кол-во дней на больничном более ' + lstr(mn->bolnich))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Кол-во дней на больничном более ' + lstr(mn->bolnich)), nil)
        endif
      endif
      if mn->vrach1 > 0
        add_string('Лечащий врач: ' + alltrim(mn->vrach))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Лечащий врач: ' + alltrim(mn->vrach)), nil)
        endif
      endif
      if yes_bukva .and. ! empty(mn->status_st)
        add_string('Статус стоматологического больного: ' + alltrim(mn->status_st))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Статус стоматологического больного: ' + alltrim(mn->status_st)), nil)
        endif
      endif
      if !emptyany(mn->diag, mn->diag1)
        add_string('Шифр диагноза (осн.+сопут.): с ' + alltrim(mn->diag) + ' по ' + alltrim(mn->diag1))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Шифр диагноза (осн.+сопут.): с ' + alltrim(mn->diag) + ' по ' + alltrim(mn->diag1)), nil)
        endif
      elseif !empty(mn->diag)
        add_string('Шифр диагноза (осн.+сопут.): ' + mn->diag)
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Шифр диагноза (осн.+сопут.): ' + mn->diag), nil)
        endif
      endif
      if !emptyany(mn->kod_diag, mn->kod_diag1)
        add_string('Шифр основного диагноза: с ' + alltrim(mn->kod_diag) + ' по ' + alltrim(mn->kod_diag1))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Шифр основного диагноза: с ' + alltrim(mn->kod_diag) + ' по ' + alltrim(mn->kod_diag1)), nil)
        endif
      elseif !empty(mn->kod_diag)
        add_string('Шифр основного диагноза: ' + mn->kod_diag)
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Шифр основного диагноза: ' + mn->kod_diag), nil)
        endif
      endif
      if !emptyany(mn->soput_d, mn->soput_d1)
        add_string('Шифр сопутствующего диагноза: с ' + alltrim(mn->soput_d) + ' по ' + alltrim(mn->soput_d1))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Шифр сопутствующего диагноза: с ' + alltrim(mn->soput_d) + ' по ' + alltrim(mn->soput_d1)), nil)
        endif
      elseif !empty(mn->soput_d)
        add_string('Шифр сопутствующего диагноза: ' + mn->soput_d)
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Шифр сопутствующего диагноза: ' + mn->soput_d), nil)
        endif
      endif
      if !emptyany(mn->osl_d, mn->osl_d1)
        add_string('Шифр диагноза осложнения: с ' + alltrim(mn->osl_d) + ' по ' + alltrim(mn->osl_d1))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Шифр диагноза осложнения: с ' + alltrim(mn->osl_d) + ' по ' + alltrim(mn->osl_d1)), nil)
        endif
      elseif !empty(mn->osl_d)
        add_string('Шифр диагноза осложнения: ' + mn->osl_d)
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Шифр диагноза осложнения: ' + mn->osl_d), nil)
        endif
      endif
      if !emptyany(mn->pred_d, mn->pred_d1)
        add_string('Шифр предварительного диагноза: с ' + alltrim(mn->pred_d) + ' по ' + alltrim(mn->pred_d1))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Шифр предварительного диагноза: с ' + alltrim(mn->pred_d) + ' по ' + alltrim(mn->pred_d1)), nil)
        endif
      elseif !empty(mn->pred_d)
        add_string('Шифр предварительного диагноза: ' + mn->pred_d)
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Шифр предварительного диагноза: ' + mn->pred_d), nil)
        endif
      endif
      f_put_tal_diag()  // вывод информации о характере, диспансеризации...
      if lExcel
        f_put_tal_diagEXCEL(wsCommon, rowWS++, columnWS)
      endif
      if yes_h_otd == 1 .and. mn->otd > 0
        add_string('Отделение, в котором выписан счет: ' + inieditspr(A__POPUPMENU, dir_server + 'mo_otd', mn->otd))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Отделение, в котором выписан счет: ' + inieditspr(A__POPUPMENU, dir_server + 'mo_otd', mn->otd)), nil)
        endif
      endif
      if mn->ist_fin >= 0
        add_string('Источник финансирования ' + inieditspr(A__MENUVERT, mm_ist_fin, mn->ist_fin))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Источник финансирования ' + inieditspr(A__MENUVERT, mm_ist_fin, mn->ist_fin)), nil)
        endif
      endif
      if mn->komu >= 0
        add_string('Принадлежность счёта: ' + inieditspr(A__MENUVERT, mm_komu, mn->komu))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Принадлежность счёта: ' + inieditspr(A__MENUVERT, mm_komu, mn->komu)), nil)
        endif

        if mn->company > 0
          add_string('  ==> ' + inieditspr(A__MENUVERT, mm_company, mn->company))
        endif
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('  ==> ' + inieditspr(A__MENUVERT, mm_company, mn->company)), nil)
        endif
      endif
      if mn->srok_min > 0 .or. mn->srok_max > 0
        if empty(mn->srok_min)
          add_string('Срок лечения (максимальный) ' + lstr(mn->srok_max) + ' дн.')
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Срок лечения (максимальный) ' + lstr(mn->srok_max) + ' дн.'), nil)
          endif
        elseif empty(mn->srok_max)
          add_string('Срок лечения (минимальный) ' + lstr(mn->srok_min) + ' дн.')
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Срок лечения (минимальный) ' + lstr(mn->srok_min) + ' дн.'), nil)
          endif
        else
          add_string('Срок лечения от ' + lstr(mn->srok_min) + ' до ' + lstr(mn->srok_max) + ' дн.')
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Срок лечения от ' + lstr(mn->srok_min) + ' до ' + lstr(mn->srok_max) + ' дн.'), nil)
          endif
        endif
      endif
      if mn->summa_min > 0 .or. mn->summa_max > 0
        if empty(mn->summa_min)
          add_string('Стоимость лечения менее ' + lstr(mn->summa_max, 10, 2))
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Стоимость лечения менее ' + lstr(mn->summa_max, 10, 2)), nil)
          endif
        elseif empty(mn->summa_max)
          add_string('Стоимость лечения более ' + lstr(mn->summa_min, 10, 2))
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Стоимость лечения более ' + lstr(mn->summa_min, 10, 2)), nil)
          endif
        else
          add_string('Стоимость лечения в диапазоне от ' + lstr(mn->summa_min, 10, 2) + ' до ' + lstr(mn->summa_max, 10, 2))
          if lExcel
            WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Стоимость лечения в диапазоне от ' + lstr(mn->summa_min, 10, 2) + ' до ' + lstr(mn->summa_max, 10, 2)), nil)
          endif
        endif
      endif
      if mn->dom > 0
        add_string('Где оказана услуга: ' + inieditspr(A__MENUVERT, mm_dom, mn->dom))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Где оказана услуга: ' + inieditspr(A__MENUVERT, mm_dom, mn->dom)), nil)
        endif
      endif
      if mn->otd_usl > 0
        add_string('Отделение, в котором оказана услуга: ' + inieditspr(A__POPUPMENU, dir_server + 'mo_otd', mn->otd_usl))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Отделение, в котором оказана услуга: ' + inieditspr(A__POPUPMENU, dir_server + 'mo_otd', mn->otd_usl)), nil)
        endif
      endif
      if mn->vr1 > 0
        add_string('Врач, оказавший услугу(и): ' + alltrim(mn->vr))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Врач, оказавший услугу(и): ' + alltrim(mn->vr)), nil)
        endif
      endif
      if mn->isvr > 0
        add_string('Код врача ' + if(mn->isvr == 1, 'не ', '') + 'проставлен')
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Код врача ' + if(mn->isvr == 1, 'не ', '') + 'проставлен'), nil)
        endif
      endif
      if mn->as1 > 0
        add_string('Ассистент, оказавший услугу(и): ' + alltrim(mn->as))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Ассистент, оказавший услугу(и): ' + alltrim(mn->as)), nil)
        endif
      endif
      if mn->isas > 0
        add_string('Код ассистента ' + if(mn->isas == 1, 'не ', '') + 'проставлен')
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Код ассистента ' + if(mn->isas == 1, 'не ', '') + 'проставлен'), nil)
        endif
      endif
      if mn->vras1 > 0
        add_string('Человек, оказавший услугу(и): ' + alltrim(mn->vras))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Человек, оказавший услугу(и): ' + alltrim(mn->vras)), nil)
        endif
      endif
      if mn->date_vvod > 0
        add_string('Дата ввода: ' + pdate_vvod[4])
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Дата ввода: ' + pdate_vvod[4]), nil)
        endif
      endif
      if mn->slug_usl > 0
        add_string('Служба, в которой оказаны услуги: ' + mslugba[2])
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Служба, в которой оказаны услуги: ' + mslugba[2]), nil)
        endif
      endif
      if mn->uslugi > 0
        l := s := k := 0
        aeval(arr_usl, {|x| l := max(l, len(rtrim(x[3]))) } )
        if fl_rak_usl
          l -= 11
        endif
        verify_FF(HH - 1, .t., sh)
        add_string(padr('Оказанные услуги (ТФОМС):', l + 13) + '|Кол-во|  Ст-ть   '+iif(fl_rak_usl,'| Снято РАК', ''))
        if lExcel
          WORKSHEET_MERGE_RANGE(wsCommon, rowWS, 0, rowWS, 5, hb_StrToUtf8('Оказанные услуги (ТФОМС)'), wsCommon_format)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, 6, hb_StrToUtf8('Кол-во'), wsCommon_format)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, 7, hb_StrToUtf8('Стоимость'), wsCommon_format)
          if fl_rak_usl
            WORKSHEET_WRITE_STRING(wsCommon, rowWS, 8, hb_StrToUtf8('Снято РАК'), wsCommon_format)
          endif
          rowWS++
        endif
        for i := 1 to len(arr_usl)
          verify_FF(HH, .t., sh)
          add_string('  ' + arr_usl[i, 2] + ' ' + ;
                   padr(arr_usl[i, 3], l) + '|' + put_val(arr_usl[i, 4], 5) + ' |' + put_kopE(arr_usl[i, 5], 10) + ;
                   iif(fl_rak_usl .and. left(arr_usl[i, 2], 3) == '71.', '|' + put_kopE(arr_usl[i, 6], 10), ''))
          k += arr_usl[i, 4]
          s += arr_usl[i, 5]
          if lExcel
            WORKSHEET_MERGE_RANGE(wsCommon, rowWS, 0, rowWS, 5, hb_StrToUtf8('  ' + arr_usl[i, 2] + ' ' + padr(arr_usl[i, 3], l)), wsCommon_format_wrap)
            WORKSHEET_WRITE_NUMBER(wsCommon, rowWS, 6, arr_usl[i, 4], wsCommon_Number)
            WORKSHEET_WRITE_NUMBER(wsCommon, rowWS, 7, arr_usl[i, 5], wsCommon_Number_Rub)
            if fl_rak_usl .and. left(arr_usl[i, 2], 3) == '71.'
              WORKSHEET_WRITE_NUMBER(wsCommon, rowWS, 8, arr_usl[i, 6], wsCommon_Number_Rub)
            endif
            rowWS++
          endif
        next
        add_string('  ИТОГО:     Оказано услуг ' + lstr(k) + ' на сумму ' + lstr(s, 12, 2) + 'р.')
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, 1, hb_StrToUtf8('ИТОГО:'), nil)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS, 6, k, wsCommon_Number)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS++, 7, s, wsCommon_Number_Rub)
      endif
      endif
      if mn->uslugiF > 0
        l := s := k := 0
        aeval(arr_uslF, {|x| l := max(l, len(rtrim(x[3]))) } )
        verify_FF(HH - 1, .t., sh)
        add_string(padr('Оказанные услуги (ФФОМС):', l + 23) + '|Кол-во')
        if lExcel
          rowWS++
          WORKSHEET_MERGE_RANGE(wsCommon, rowWS, 0, rowWS, 5, hb_StrToUtf8('Оказанные услуги (ФФОМС)'), wsCommon_format)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, 6, hb_StrToUtf8('Кол-во'), wsCommon_Number)
        endif
        for i := 1 to len(arr_uslF)
          verify_FF(HH, .t., sh)
          add_string('  ' + arr_uslF[i, 2] + ' ' + ;
                   padr(arr_uslF[i, 3], l) + '|' + put_val(arr_uslF[i, 4], 5))
          k += arr_uslF[i, 4]
          if lExcel
            WORKSHEET_MERGE_RANGE(wsCommon, rowWS, 0, rowWS, 5, hb_StrToUtf8(arr_uslF[i, 2] + ' ' + padr(arr_uslF[i, 3], l)), wsCommon_format_wrap)
            WORKSHEET_WRITE_NUMBER(wsCommon, rowWS++, 6, arr_uslF[i, 4], wsCommon_Number)
          endif
        next
        add_string('  ИТОГО:     Оказано услуг ' + lstr(k))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, 1, hb_StrToUtf8('ИТОГО:'), nil)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS++, 6, k, nil)
        endif
      endif
      use (cur_dir + 'tmp_bbuk') index (cur_dir + 'tmp_bbuk') new
      use (cur_dir + 'tmp_buk') index (cur_dir + 'tmp_buk') new
      if lastrec() > 0
        verify_FF(HH - 3, .t., sh)
        add_string('Стоматологический статус|Больн.|Случаев')
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('Стоматологический статус|Больн.|Случаев'), nil)
        endif
        w1 := 17
        f3_diag_statist_bukva(HH, sh)
      endif
      add_string('')
      add_string(' == РЕЗУЛЬТАТЫ ПОИСКА ==')
      if lExcel
        rowWS++
        WORKSHEET_MERGE_RANGE(wsCommon, rowWS, columnWS, rowWS, 12, '', wsCommon_format)
        WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('== РЕЗУЛЬТАТЫ ПОИСКА =='), wsCommon_format)
        WORKSHEET_MERGE_RANGE(wsCommon, rowWS, columnWS, rowWS, 12, '', wsCommon_format)
        WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('(см. на листе "Список пациентов")'), nil)
        rowWS++
      endif

      if mn->kol_lu > 0
        use (cur_dir + 'tmp_k') index (cur_dir + 'tmp_k') new
        COUNT TO skol FOR tmp_k->kol > mn->kol_lu
        use (cur_dir + 'tmp') new
        set relation to str(kod, 7) into HUMAN, to str(kod_k, 7) into TMP_K
        index on upper(human->fio) + dtos(human->k_data) to (cur_dir + 'tmp') ;
            for tmp_k->kol > mn->kol_lu
      else
        use (cur_dir + 'tmp_k') new
        use (cur_dir + 'tmp') new
        set relation to str(kod, 7) into HUMAN
        index on upper(human->fio) + dtos(human->k_data) to (cur_dir + 'tmp')
        add_string('Итого количество больных: ' + lstr(tmp_k->(lastrec())) + ' чел.')
        s := 'Итого листов учета: ' + lstr(tmp->(lastrec())) + ' на сумму ' + lput_kop(ssumma, .t.) + ' руб.'
        if suet > 0
          s += ' (' + alltrim(str_0(suet, 15, 4)) + ' УЕТ)'
        endif
        add_string(s)
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, columnWS, hb_StrToUtf8('Итого количество больных (чел.):'), nil)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS++, 7, tmp_k->(lastrec()), nil)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, columnWS, hb_StrToUtf8('Итого листов учета:'), nil)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS++, 7, tmp_k->(lastrec()), nil)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, 1, hb_StrToUtf8('на сумму (руб.):'), nil)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS, 7, ssumma, wsCommon_Number_Rub)
          if suet > 0
            WORKSHEET_WRITE_STRING(wsCommon, rowWS, 8, hb_StrToUtf8('(' + alltrim(str_0(suet, 15, 4)) + ' УЕТ)'), nil)
          endif
          rowWS++
        endif
      endif
      if !empty(srak_s)
        add_string('Сумма, снятая актами контроля ' + lput_kop(srak_s, .t.) + ' руб.')
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, columnWS, hb_StrToUtf8('Сумма, снятая актами контроля (руб.)'), nil)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS++, 7, srak_s, nil)
        endif
      endif
      if mn->kol_pos == 2
        verify_FF(HH - 5, .t., sh)
        add_string('Количество амбулаторных посещений: ' + lstr(kol_pos_amb))
        add_string('Количество стоматологических посещений всего: ' + lstr(pol_pos_stom1 + pol_pos_stom2 + pol_pos_stom3))
        add_string(padl(  'в том числе с лечебной целью: ', 47) + lstr(pol_pos_stom1))
        add_string(padl(      'с профилактической целью: ', 47) + lstr(pol_pos_stom2))
        add_string(padl('при оказании неотложной помощи: ', 47) + lstr(pol_pos_stom3))
        //use (cur_dir + 'tmp_kp') new
        //add_string('Количество посещений (сколько дней пациенты заходили в МО): ' + lstr(tmp_kp->(lastrec())))
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, 1, hb_StrToUtf8('Количество амбулаторных посещений:'), nil)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS++, 7, kol_pos_amb, nil)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, 1, hb_StrToUtf8('Количество стоматологических посещений всего:'), nil)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS++, 7, pol_pos_stom1 + pol_pos_stom2 + pol_pos_stom3, nil)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, 1, hb_StrToUtf8('в том числе'), nil)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, 3, hb_StrToUtf8('с лечебной целью:'), nil)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS++, 7, pol_pos_stom1, nil)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, 3, hb_StrToUtf8('с профилактической целью:'), nil)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS++, 7, pol_pos_stom2, nil)
          WORKSHEET_WRITE_STRING(wsCommon, rowWS, 3, hb_StrToUtf8('при оказании неотложной помощи:'), nil)
          WORKSHEET_WRITE_NUMBER(wsCommon, rowWS++, 7, pol_pos_stom3, nil)
        endif
      endif
      add_string('')
      aeval(arr_title, {|x| add_string(x) } )
      ssumma := skol_lu := 0
      keyboard ''
      select TMP
      go top
      do while !eof()
        if inkey() == K_ESC
          fl_exit := .t.
          exit
        endif
        row++
        used_column := column + 1
        column := 0
        if verify_FF(HH, .t., sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        select VIGRUZKA
        append blank
        //
        select ONKSL
        find (str(human->kod, 7))
        is_oncology := f_is_oncology(1)
        k_diagnoz := k_usl := 0
        afill(tt_diagnoz, '')
        afill(tt_usl, '')
        //
        is_2 := .f.
        rec_1 := 0
        mn_data := human->n_data
        if human->ishod == 89
          select HUMAN_3
          set order to 2 // встать на индекс по 2-му случаю
          find (str(human->kod, 7))
          if found()
            mn_data := human_3->N_DATA
            is_2 := .t.
            rec_1 := human_3->KOD
          endif
        endif
        //
        s1 := left(human->fio, 40)
        if lExcel
          WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(human->fio), fmtCellString)
        endif
        kart->(dbGoto(human->kod_k))
        if mem_kodkrt == 2
          s2 := ' ['
          if is_uchastok > 0
            s2 += alltrim(kart->bukva)
            s2 += lstr(kart->uchast, 2) + '/'
          endif
          if is_uchastok == 1
            s2 += lstr(kart->kod_vu)
          elseif is_uchastok == 3
            s2 += alltrim(kart2->kod_AK)
          else
            s2 += lstr(kart->kod)
          endif
          s2 += '] '
        else
          s2 := space(7)
        endif
        if mn->komu < 0
          s2 += f4_view_list_schet(human->komu, cut_code_smo(human_->smo), human->str_crb)
          if lExcel
            WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(f4_view_list_schet(human->komu, cut_code_smo(human_->smo), human->str_crb)), fmtCellString)
          endif
        else
          column++
        endif
        if yes_bukva .and. !empty(human_->status_st)
          tmp1 := ' ' + alltrim(human_->status_st)
          s2 := padr(s2, 50 - len(tmp1)) + tmp1
        else
          s2 := padr(s2, 50)
        endif
        s3 := iif(mem_kodkrt == 2, space(1), space(7))
        if !empty(kart->SNILS)
          s3 += transform(kart->SNILS, picture_pf) + ' '
          if lExcel
            WORKSHEET_WRITE_STRING(worksheet, row, column++, transform(kart->SNILS, picture_pf), fmtCellString)
          endif
        else
          column++
        endif
        if mn->invalid == 9
          if kart_->INVALID == 1
            s3 += 'инв.1группы '
          elseif kart_->INVALID == 2
            s3 += 'инв.2группы '
          elseif kart_->INVALID == 3
            s3 += 'инв.3группы '
          else
            s3 += 'дети-инвалиды '
          endif
        endif
        if mn->bolnich1 > 1 .or. mn->bolnich > 0
          s3 += 'больничн. ' + left(date_8(c4tod(human->date_b_1)), 5) + '-' + date_8(c4tod(human->date_b_2))
        elseif !empty(mmr_dol)
          s3 += alltrim(kart->mr_dol)
        endif
        s3 := padr(s3, 50)
        //
        VIGRUZKA->dd0  := s1
        VIGRUZKA->dd00  := str(tmp->stoim, 10, 2)
        s1 += str(tmp->stoim, 10, 2)
        if lExcel
          WORKSHEET_WRITE_NUMBER(worksheet, row, column++, tmp->stoim, fmtCellNumberRub)
        endif
        ssumma += tmp->stoim
        ++skol_lu
        //
        VIGRUZKA->dd01 := s2
        VIGRUZKA->dd02 := s3
        //
        if isbit(mn->vid_doc, 1)
          s1 += ' ' + date_8(human->date_r)
          s2 += space(9)
          s3 += space(9)
          VIGRUZKA->dd1 := full_date(human->date_r)
          if lExcel
            WORKSHEET_WRITE_STRING(worksheet, row, column++, date_8(human->date_r), fmtCellStringCenter)
          endif
        endif
        //
        if isbit(mn->vid_doc, 2) // адрес
          perenos(a_diagnoz, ret_okato_ulica(kart->adres, kart_->okatog, 0, 2), 24)
          s1 += ' ' + padr(alltrim(a_diagnoz[1]), 24)
          s2 += ' ' + padr(alltrim(a_diagnoz[2]), 24)
          s3 += ' ' + padr(alltrim(a_diagnoz[3]), 24)
          VIGRUZKA->dd2 := ret_okato_ulica(kart->adres, kart_->okatog, 0, 2)
          if lExcel
            WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(ret_okato_ulica(kart->adres, kart_->okatog, 0, 2)), fmtCellString)
          endif
        endif
        //
        if isbit(mn->vid_doc, 12) // телефоны
          KART->(dbselectarea(human->kod_k ))
          s1 += ' ' + padr(alltrim(kart_->Phone_h), 10)
          s2 += ' ' + padr(alltrim(kart_->Phone_m), 10)
          s3 += ' ' + padr(alltrim(kart_->Phone_w), 10) 
          VIGRUZKA->dd12 := alltrim(kart_->Phone_h) + ' ' + alltrim(kart_->Phone_m) + ' ' + alltrim(kart_->Phone_w)
          if lExcel
            WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(alltrim(kart_->Phone_h) + ' ' + alltrim(kart_->Phone_m) + ' ' + alltrim(kart_->Phone_w)), fmtCellString)
          endif
        endif
         //
         if isbit(mn->vid_doc, 3) // номер карты
          s1 += space(11)
          s2 += ' ' + human->uch_doc
          s3 += space(11)
          VIGRUZKA->dd3 := human->uch_doc
          if lExcel
            WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(human->uch_doc), fmtCellString)
          endif
        endif
        //
        if isbit(mn->vid_doc, 4)
          if mn_data == human->k_data
            s1 += ' ' + date_8(human->k_data)
            s2 += space(9)
            VIGRUZKA->dd4 := date_8(human->k_data)
          else
            s1 += ' с' + left(date_8(mn_data), 5) + 'по'
            s2 += ' ' + date_8(human->k_data)
            VIGRUZKA->dd4 := ' с' + left(date_8(mn_data), 5) + 'по'+' ' + date_8(human->k_data)
          endif
          s3 += space(9)
          if lExcel
            WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(iif(mn_data == human->k_data, date_8(human->k_data), 'с ' + left(date_8(mn_data), 5) + ' по ' + date_8(human->k_data))), fmtCellString)
          endif
        endif
        //
        if isbit(mn->vid_doc, 5)
          afill(adiag_talon, 0)
          for i := 1 to 16
            adiag_talon[i] := int(val(substr(human_->DISPANS, i, 1)))
          next
          arr := diag_to_array(, .t., .t., .t., .t., adiag_talon)
          tmp1 := ''
          for i := 1 to len(arr)
            tmp1 += arr[i] + ' '
          next
          for i := 1 to 8
            if !empty(s := substr(human->diag_plus, i, 1))
              if yes_bukva .and. (j := ascan(md_plus, s)) > 0
                sd_plus[j] ++
              endif
            endif
          next
          k_diagnoz := perenos(a_diagnoz, tmp1, 13)
          s1 += ' ' + padc(alltrim(a_diagnoz[1]), 13)
          s2 += ' ' + padc(alltrim(a_diagnoz[2]), 13)
          s3 += ' ' + padc(alltrim(a_diagnoz[3]), 13)
          if k_diagnoz > 3
            tt_diagnoz := aclone(a_diagnoz)
          endif
          if lExcel
              WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(tmp1), fmtCellString)
          endif
          VIGRUZKA->dd5 := tmp1
        endif
        //
        if isbit(mn->vid_doc, 6)
          if human->tip_h >= B_SCHET .and. human->schet > 0
            select SCHET
            goto (human->schet)
            s1 += ' ' + padc(alltrim(schet_->nschet), 15)
            s2 += ' ' + padc(date_8(schet_->dschet) + 'г.', 15)
            VIGRUZKA->dd6 := alltrim(schet_->nschet) 
            VIGRUZKA->dd60 := full_date(schet_->dschet)
          else
            s1 += ' ' + padc('-', 15)
            s2 += space(16)
          endif
          s3 += space(16)
          VIGRUZKA->dd62 := lstr(HUMAN_->schet_zap)
          VIGRUZKA->dd61 := schet_->smo
          if lExcel
              WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(iif(human->tip_h >= B_SCHET .and. human->schet > 0, alltrim(schet_->nschet) + ' ' + date_8(schet_->dschet) + 'г.', padc('-', 8))), fmtCellString)
          endif
        endif
        //
        if isbit(mn->vid_doc, 7)
          if tmp->rak_p == 0
            s1 += ' ' + padc('оплачи-', 9)
            s2 += ' ' + padc('вается', 9)
            s3 += space(10)
            VIGRUZKA->dd7 := 'оплачивается'
          else
            s1 += ' ' + padr('снят ' + lstr(tmp->rak_p) + '%', 9)
            if human_->oplata == 9
              s2 += ' ' + padc('перевыс-', 9)
              s3 += ' ' + padc('тавлен', 9)
              VIGRUZKA->dd7 :='снят ' + lstr(tmp->rak_p) + '% '+'перевыставлен'
            else
              s2 += ' ' + padc(lstr(tmp->rak_s, 9, 2), 9)
              s3 += space(10)
              VIGRUZKA->dd7 := 'снят ' + lstr(tmp->rak_p) + '% '+ lstr(tmp->rak_s, 9, 2)
            endif
          endif
          if lExcel
            if tmp->rak_p == 0
              WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('оплачивается'), fmtCellString)
            else
              if human_->oplata == 9
                WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('снят ' + lstr(tmp->rak_p) + '% ' + 'перевыставлен'), fmtCellString)
              else
                WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8('снят ' + lstr(tmp->rak_p) + '% '+ lstr(tmp->rak_s, 9, 2)), fmtCellString)
              endif
            endif
          endif
         endif
        //
        if isbit(mn->vid_doc, 8)
          if human_->vrach > 0
            select PERSO
            goto (human_->vrach)
            s1 += put_val(perso->tab_nom, 6)
            VIGRUZKA->dd8 := put_val(perso->tab_nom, 6)
          else
            s1 += space(6)
          endif
          s2 += space(6)
          s3 += space(6)
          if lExcel
              WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(put_val(perso->tab_nom, 6)), fmtCellString)
          endif
        endif
        //
        if isbit(mn->vid_doc, 9)
          tmp1 := ''
          aup := {}
          ar := {human->kod}
          if is_2
            Ins_Array(ar, 1, rec_1)
          endif
          for j := 1 to len(ar)
            Select HU
            find (str(ar[j], 7))
            do while hu->kod == ar[j] .and. !eof()
              if hu->kol_1 > 0
                Select USL
                goto (hu->u_kod)
                //if empty(l1 := opr_shifr_TFOMS(usl->shifr1,usl->kod, human->k_data))
                l1 := usl->shifr
                //endif
                l3 := ''//iif(hu->is_edit > 1, '[-' + lstr(hu->is_edit) + '%]', '')
                if (i := ascan(aup, {|x| x[1] == l1 .and. x[3] == l3} )) == 0
                  aadd(aup, {l1, 0, l3})
                  i := len(aup)
                endif
                aup[i, 2] += hu->kol_1
              endif
              select HU
              Skip
            enddo
          next j
          asort(aup, , , {|x, y| fsort_usl(x[1]) < fsort_usl(y[1]) } )
          for j := 1 to len(ar)
            Select MOHU
            find (str(ar[j], 7))
            do while mohu->kod == ar[j] .and. !eof()
              if !empty(mohu->kol_1)
                Select MOSU
                goto (mohu->u_kod)
                l1 := iif(empty(mosu->shifr), mosu->shifr1, mosu->shifr)
                l3 := ''
                if (i := ascan(aup, {|x| x[1] == l1 .and. x[3] == l3} )) == 0
                  aadd(aup, {l1, 0, l3})
                  i := len(aup)
                endif
                aup[i, 2] += mohu->kol_1
              endif
              Select MOHU
              Skip
            enddo
          next j
          if mn->uslugi > 0
            bup := {}
            for i := 1 to len(arr_usl)
              if (l := ascan(aup, {|x| x[1] == arr_usl[i, 2]})) > 0
                aadd(bup, aclone(aup[l]) )
                adel(aup, l)
                asize(aup, len(aup) - 1)
              endif
            next
            for i := len(bup) to 1 step -1
              aadd(aup, nil)
              ains(aup, 1)
              aup[1] := bup[i]
            next
          endif
          if mn->uslugiF > 0
            bup := {}
            for i := 1 to len(arr_uslF)
              if (l := ascan(aup, {|x| x[1] == arr_uslF[i, 2]})) > 0
                aadd(bup, aclone(aup[l]) )
                adel(aup, l)
                asize(aup, len(aup) - 1)
              endif
            next
            for i := len(bup) to 1 step -1
              aadd(aup, nil)
              ains(aup, 1)
              aup[1] := bup[i]
            next
          endif
          for i := 1 to len(aup)
            tmp1 += alltrim(aup[i, 1]) + iif(aup[i, 2] > 1, '(' + lstr(aup[i, 2]) + ')', '') + aup[i, 3] + ','
          next
          tmp1 := left(tmp1, len(tmp1) - 1)
          k_usl := perenos(a_diagnoz, tmp1, 23, ',')
          s1 += ' ' + padc(alltrim(a_diagnoz[1]), 23)
          s2 += ' ' + padc(alltrim(a_diagnoz[2]), 23)
          s3 += ' ' + padc(alltrim(a_diagnoz[3]), 23)
          if k_usl > 3
            tt_usl := aclone(a_diagnoz)
          endif
          VIGRUZKA->dd9 := tmp1
          if lExcel
              WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(tmp1), fmtCellString)
          endif
        endif
        //
        if isbit(mn->vid_doc, 10)
          afill(a_diagnoz, '')
          i := 0
          if !empty(human_2->pc3) .and. !left(human_2->pc3, 1) == '6' // кроме 'старости'
            a_diagnoz[++i] := human_2->pc3
          elseif is_oncology  == 2
            if !empty(onksl->crit)
              a_diagnoz[++i] := onksl->crit
            endif
            if !empty(onksl->crit2)
              a_diagnoz[++i] := onksl->crit2  // второй критерий
            endif
          endif
          s1 += ' ' + padc(a_diagnoz[1], 8)
          s2 += ' ' + padc(a_diagnoz[2], 8)
          s3 += ' ' + padc(a_diagnoz[3], 8)
          VIGRUZKA->dd10 := a_diagnoz[1] + ' ' + a_diagnoz[2] + ' ' + a_diagnoz[3]
          if lExcel
              WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(a_diagnoz[1] + ' ' + a_diagnoz[2] + ' ' + a_diagnoz[3]), fmtCellString)
          endif
        endif
        if yes_parol
          if isbit(mn->vid_doc, 11)
            s1 += ' ' + date_8(c4tod(human->date_e)) + 'г.'
            if asc(human->kod_p) > 0
              select BASE1
              goto (asc(human->kod_p))
              if !eof() .and. !empty(base1->p1)
                s2 += ' ' + left(crypt(base1->p1, gpasskod), 10)
                VIGRUZKA->dd11 := date_8(c4tod(human->date_e)) + 'г. '+crypt(base1->p1, gpasskod)
              endif
            elseif human_2->PN3 > 0
              s2 += ' ИМПОРТ'
              VIGRUZKA->dd11 := date_8(c4tod(human->date_e)) + 'г. ' + ' ИМПОРТ'
            endif
            if lExcel
              if asc(human->kod_p) > 0
                WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(date_8(c4tod(human->date_e)) + 'г. '+crypt(base1->p1, gpasskod)), fmtCellString)
              elseif human_2->PN3 > 0
                WORKSHEET_WRITE_STRING(worksheet, row, column++, hb_StrToUtf8(date_8(c4tod(human->date_e)) + 'г. ' + ' ИМПОРТ'), fmtCellString)
              endif
            endif
          endif
        endif
        add_string(s1)
        add_string(s2)
        add_string(s3)
        if k_diagnoz > 3 .or. k_usl > 3
          for i := 4 to min(10,max(k_diagnoz, k_usl))
            s3 := space(50)
            if isbit(mn->vid_doc, 1)
              s3 += space(9)
            endif
            if isbit(mn->vid_doc, 2)
              s3 += ' ' + space(24)
            endif
            if isbit(mn->vid_doc, 3)
              s3 += space(9)
            endif
            if isbit(mn->vid_doc, 4)
              s3 += ' ' + padc(alltrim(tt_diagnoz[i]), 13)
            endif
            if isbit(mn->vid_doc, 5)
              s3 += space(16)
            endif
            if isbit(mn->vid_doc, 6)
              s3 += space(10)
            endif
            if isbit(mn->vid_doc, 7)
              s3 += space(6)
            endif
            if isbit(mn->vid_doc, 8)
              s3 += ' ' + padc(alltrim(tt_usl[i]), 23)
            endif
            add_string(s3)
          next
        endif
        if is_2
          add_string(space(5) + '! Это двойной случай !')
          VIGRUZKA->(dbappend())
          VIGRUZKA->dd2 := space(5) + '! Это двойной случай !'
        endif
        select TMP
        skip
      enddo
      add_string(replicate('─', sh))
      if fl_exit
        add_string('*** '+expand('ОПЕРАЦИЯ ПРЕРВАНА'))
      else
        if mn->kol_lu > 0
          add_string('Итого количество больных: ' + lstr(skol) + ' чел.')
          add_string('Итого листов учета: ' + lstr(skol_lu) + ;
                     ' на сумму  ' + lput_kop(ssumma, .t.) + ' руб.')
        else
          add_string('  Итого листов учета: ' + lstr(tmp->(lastrec())) + ;
                   ' на сумму  ' + lput_kop(ssumma, .t.) + ' руб.')
          if yes_bukva
            for i := 1 to k_plus
              if !empty(sd_plus[i])
                add_string(padl('"' + md_plus[i] + '"  : ', 29) + lstr(sd_plus[i]))
              endif
            next
          endif
        endif
      endif
      fclose(fp)
      close databases
      viewtext(name_file, , , , .t., , , reg_print)
      if lExcel
        WORKBOOK_CLOSE(workbook)
        SaveTo(cur_dir + name_fileXLS_full)
      endif
    endif
  endif
  close databases
  restscreen(buf)
  setcolor(tmp_color)
  return NIL

// 27.05.23
Static Function s1_mnog_poisk(cv, cf)
  Static a_stom_vp := {{}, {}, {}}
  Local i, j, k, n, s, arr, fl := .t., flu := .f., mkol, mstoim := 0, fl1, fl2, vid_vp := 1, ;
        au := {}, au_lu := {}, au_flu := {}, msumma, mn_data, rec_1 := 0, is_2 := .f., ;
        mrak_p := 0, mrak_s := 0, d, lshifr, muet := 0, god_r, arr1, adiag_talon[16]  // из статталона к диагнозам

  if empty(a_stom_vp[1])
    f_vid_p_stom({}, {},a_stom_vp[1], {1})
    f_vid_p_stom({}, {},a_stom_vp[2], {2})
    f_vid_p_stom({}, {},a_stom_vp[3], {3})
  endif
  ++cv
  mn_data := human->n_data
  msumma := human->cena_1
  kart->(dbGoto(human->kod_k))
  if fl
    if mn->dvojn == 1
      fl := (human->ishod != 88)
    elseif mn->dvojn == 2
      fl := (human->ishod == 89)
    elseif mn->dvojn == 3
      fl := !eq_any(human->ishod, 88, 89)
    endif
    if fl
      if human->ishod == 89
        select HUMAN_3
        set order to 2 // встать на индекс по 2-му случаю
        find (str(human->kod, 7))
        if found()
          mn_data := human_3->N_DATA
          msumma := human_3->CENA_1
          rec_1 := human_3->KOD
          is_2 := .t.
        endif
      endif
    endif
  endif
  if fl .and. mn->date_lech > 0 .and. p_regim != 1
    fl := between(human->k_data, pdate_lech[5], pdate_lech[6])
  endif
  if fl .and. mn->date_schet > 0 .and. p_regim != 2
    fl := !empty(human->DATE_CLOSE) .and. between(human->DATE_CLOSE, pdate_lech[5], pdate_lech[6])
    if (fl := (human->schet > 0))
      if schet->kod != human->schet
        schet->(dbGoto(human->schet))
      endif
      fl := between(schet->pdate, pdate_schet[7], pdate_schet[8])
    endif
  endif
  if fl .and. mn->perevyst != 1
    if mn->perevyst == 0
      fl := (human_->oplata != 9)
    elseif mn->perevyst == 2
      fl := (human_->oplata == 9)
    endif
  endif
  if fl .and. mn->rak > 0
    k := 0 // по умолчанию оплачен, если даже нет РАКа
    select RAKSH
    find (str(human->kod, 7))
    do while human->kod == raksh->kod_h .and. !eof()
      k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
      skip
    enddo
    if !empty(round(k, 2))
      mrak_s := k
      if empty(human->cena_1) // скорая помощь с нулевой ценой
        if (y := year(human->k_data)) == 2018
          n := 2224.60
        elseif y == 2017
          n := 1819.50
        else  // 16 год
          n := 1747.70
        endif
        mrak_p := k := round(mrak_s / n * 100, 0)
      else
        mrak_p := k := round(mrak_s / human->cena_1 * 100, 0)
      endif
    endif
    do case
      case mn->rak == 1 // {'за исключением полностью неоплачиваемых', 1}, ;
        fl := (k < 100)
      case mn->rak == 2 // {'полностью неоплачиваемые и перевыставленные', 2}, ;
        fl := (k == 100 .and. human_->oplata == 9)
      case mn->rak == 3 // {'полностью неоплачиваемые и неперевыставленные', 3}, ;
        fl := (k == 100 .and. human_->oplata != 9)
      case mn->rak == 4 // {'полностью неоплачиваемые', 4}, ;
        fl := (k == 100)
      case mn->rak == 5 // {'частично неоплачиваемые', 5}, ;
        fl := (k > 0 .and. k < 100)
      case mn->rak == 6 // {'полностью или частично неоплачиваемые', 6};
        fl := (k > 0)
    endcase
  endif
  if fl .and. mn->date_vvod > 0
    fl := between(human->date_e, pdate_vvod[7], pdate_vvod[8])
  endif
  if fl .and. yes_vypisan == B_END .and. mn->zav_lech > 0
    if p_zak_sl  // если законченный случай
      fl := (human->tip_h >= mn->zav_lech)  // проверить все вплоть до счетов
    else
      fl := (human->tip_h <= mn->zav_lech)
    endif
  endif
  if fl
    if mn->reestr == 1
      fl := (human_->reestr == 0)
    elseif mn->reestr == 2
      fl := (human_->reestr > 0)
    endif
  endif
  if fl
    if mn->schet == 1
      fl := (human->schet <= 0)
    elseif mn->schet == 2
      if (fl := (human->schet > 0)) .and. mn->regschet > 0
        if schet->kod != human->schet
          schet->(dbGoto(human->schet))
        endif
        if mn->regschet == 1
          fl := (schet_->NREGISTR != 0) // не зарегистрированные
        elseif mn->regschet == 2
          fl := (schet_->NREGISTR == 0) // зарегистрированные
        endif
      endif
    endif
  endif
  if fl .and. mn->d_p_m > 0
    fl := .f.
    if !fl .and. isbit(mn->d_p_m, 1) // диспансеризация детей-сирот при стационаре I этап', 1}
      fl := (human->ishod == 101 .and. !empty(human->za_smo))
    endif
    if !fl .and. isbit(mn->d_p_m, 2) // диспансеризация детей-сирот при стационаре II этап', 2}, ;
      fl := (human->ishod == 102 .and. !empty(human->za_smo))
    endif
    if !fl .and. isbit(mn->d_p_m, 3) // диспансеризация детей-сирот под опекой I этап', 3}, ;
      fl := (human->ishod == 101 .and. empty(human->za_smo))
    endif
    if !fl .and. isbit(mn->d_p_m, 4) // диспансеризация детей-сирот под опекой II этап', 4}, ;
      fl := (human->ishod == 102 .and. empty(human->za_smo))
    endif
    if !fl .and. isbit(mn->d_p_m, 5) // диспансеризация взрослого населения I этап', 5}, ;
      fl := (human->ishod == 201)
    endif
    if !fl .and. isbit(mn->d_p_m, 6) // диспансеризация взрослого населения II этап', 6}, ;
      fl := (human->ishod == 202)
    endif
    if !fl .and. isbit(mn->d_p_m, 7) // профилактика взрослого населения', 7}, ;
      fl := (human->ishod == 203)
    endif
    if !fl .and. isbit(mn->d_p_m, 8) // диспансеризация взрослого населения I этап 1 раз в два года
      fl := (human->ishod == 204)
    endif
    if !fl .and. isbit(mn->d_p_m, 9) // диспансеризация взрослого населения II этап 1 раз в два года
      fl := (human->ishod == 205)
    endif
    if !fl .and. isbit(mn->d_p_m, 10) // профосмотр несовершеннолетних I этап', 8}, ;
      fl := (human->ishod == 301)
    endif
    if !fl .and. isbit(mn->d_p_m, 11) // профосмотр несовершеннолетних II этап', 9}, ;
      fl := (human->ishod == 302)
    endif
    if !fl .and. isbit(mn->d_p_m, 12) // предварительный осмотр несовершеннолетних I этап', 10}, ;
      fl := (human->ishod == 303)
    endif
    if !fl .and. isbit(mn->d_p_m, 13) // предварительный осмотр несовершеннолетних II этап', 11}, ;
      fl := (human->ishod == 304)
    endif
    if !fl .and. isbit(mn->d_p_m, 14) // периодический осмотр несовершеннолетних', 12};
      fl := (human->ishod == 305)
    endif
    if !fl .and. isbit(mn->d_p_m, 15) // углубленная диспансеризация I -й этап};
      fl := (human->ishod == 401)
    endif
    if !fl .and. isbit(mn->d_p_m, 16) // углубленная диспансеризация II -й этап};
      fl := (human->ishod == 402)
    endif
  endif
  if fl .and. mn->pz > 0
    fl := (human_->PZTIP == mn->pz)
  endif
  if fl .and. mn->zno == 2
    fl := (human->OBRASHEN == '1')
  endif
  if fl .and. !empty(much_doc)
    fl := like(much_doc, human->uch_doc)
  endif
  if fl .and. is_uchastok > 0 .and. !empty(mn->bukva)
    kart->(dbGoto(human->kod_k))
    fl := (mn->bukva == kart->bukva)
  endif
  if fl .and. is_uchastok > 0 .and. !empty(mn->uchast)
    kart->(dbGoto(human->kod_k))
    fl := f_is_uchast(arr_uchast,kart->uchast)
  endif
  if fl .and. glob_mo[_MO_IS_UCH] .and. !empty(mn->o_prik)
    kart->(dbGoto(human->kod_k))
    if mn->o_prik == 1 // прикреплен к нашей МО
      fl := (kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
    elseif mn->o_prik == 2 // не прикреплен к нашей МО
      fl := !(kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
    endif
  endif
  if fl .and. !empty(mfio)
    fl := like(mfio, upper(human->fio))
  endif
  if fl .and. mn->inostran > 0
    if mn->inostran == 1 //нет
      //9, 21, 22, 23, 24
      fl := !equalany(kart_->vid_ud, 9, 21, 22, 23, 24)
    else
      fl := equalany(kart_->vid_ud, 9, 21, 22, 23, 24)
    endif
  endif
  if fl .and. mn->gorod_selo > 0
    if mn->gorod_selo == 1
      fl := !f_is_selo(kart_->gorod_selo, kart_->okatog)
    else
      fl := f_is_selo(kart_->gorod_selo, kart_->okatog)
    endif
  endif
  if fl .and. !empty(madres)
    fl := like(madres, upper(kart->adres))
  endif
  if fl .and. !empty(mmr_dol)
    fl := like(mmr_dol, upper(kart->mr_dol))
  endif
  if fl .and. mn->invalid > 0
    if mn->invalid == 9
      fl := (kart_->INVALID > 0)
    else
      fl := (kart_->INVALID == mn->invalid)
    endif
  endif
  if fl .and. mn->kategor > 0
    fl := (mn->kategor == kart_->kategor)
  endif
  if fl .and. is_kategor2 .and. mn->kategor2 > 0
    fl := (mn->kategor2 == kart_->kategor2)
  endif
  /*if fl .and. is_talon .and. (mn->povod > 0 .or. mn->travma > 0)
    fl1 := fl2 := .t.
    if mn->povod > 0
      fl1 := .f.
    endif
    if mn->travma > 0
      fl2 := .f.
    endif
    if mn->povod > 0 .and. mn->povod == human_->povod
      fl1:= .t.
    endif
    if mn->travma > 0 .and. mn->travma == human_->travma
      fl2 := .t.
    endif
    fl := (fl1 .and. fl2)
  endif*/
  if fl .and. !empty(mn->pol)
    fl := (human->pol == mn->pol)
  endif
  if fl .and. mn->vzros_reb >= 0
    fl := (human->vzros_reb == mn->vzros_reb)
  endif
  if fl .and. !empty(mn->god_r_min)
    fl := (mn->god_r_min <= human->date_r)
  endif
  if fl .and. !empty(mn->god_r_max)
    fl := (human->date_r <= mn->god_r_max)
  endif
  if fl .and. mn->rab_nerab >= 0
    fl := (kart->rab_nerab == mn->rab_nerab)
  endif
  if fl .and. mn->mi_git > 0
    if mn->mi_git == 1
      fl := (left(kart_->okatog, 2) == '18')
    else
      fl := !(left(kart_->okatog, 2) == '18')
    endif
  endif
  if fl .and. !empty(mn->_okato)
    s := mn->_okato
    for i := 1 to 3
      if right(s, 3) == '000'
        s := left(s, len(s) - 3)
      else
        exit
      endif
    next
    fl := (left(kart_->okatog, len(s)) == s)
  endif
  if fl .and. mn->USL_OK > 0
    fl := (human_->USL_OK == mn->USL_OK)
  endif
  /*if fl .and. mn->VIDPOM > 0
    fl := (human_->VIDPOM == mn->VIDPOM)
  endif*/
  if fl .and. mn->PROFIL > 0
    fl := (human_->PROFIL == mn->PROFIL)
  endif
  /*if fl .and. mn->IDSP > 0
    fl := (human_->IDSP == mn->IDSP)
  endif*/
  if fl .and. mn->rslt > 0
    fl := (human_->RSLT_NEW == mn->rslt)
  endif
  if fl .and. mn->ishod > 0
    fl := (human_->ISHOD_NEW == mn->ishod)
  endif
  if fl .and. mn->bolnich1 > 0
    fl := (human->bolnich + 1 == mn->bolnich1)
  endif
  if fl .and. mn->bolnich > 0 .and. mn->bolnich1 != 1  // не 'нет'
    fl := .f.
    if human->bolnich > 0 .and. (c4tod(human->date_b_2) - c4tod(human->date_b_1) + 1) >= mn->bolnich
      fl := .t.
    endif
  endif
  if fl .and. mn->vrach1 > 0
    fl := (human_->vrach == mn->vrach1)
  endif
  if fl .and. yes_bukva .and. !empty(mn->status_st)
    if (fl := !empty(human_->status_st))
      fl := .f.
      s := alltrim(mn->status_st)
      for i := 1 to len(s)
        fl := (substr(s, i, 1) $ human_->status_st)
        if fl
          exit
        endif
      next
    endif
  endif
  if fl .and. !empty(mn->osl_d)
    arr := {human_2->OSL1, human_2->OSL2, human_2->OSL3}
    fl := .f.
    for j := 1 to len(arr)
      if !empty(arr[j])
        arr[j] := padr(arr[j], 5)
        if empty(mn->osl_d1)
          fl := (arr[j] == mn->osl_d)
        else
          fl := between(diag2num(arr[j]), NUMosl_d, NUMosl_d1)
        endif
        if fl
          exit
        endif  // т.е. один диагноз удовлетворяет условию
      endif
    next
  endif
  if fl .and. !empty(mn->pred_d)
    if between(human->ishod, 201, 203)  // дисп-ия (профосмотр) взрослого населения
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
    else
      arr := {human_->KOD_DIAG0}
    endif
    fl := .f.
    for j := 1 to len(arr)
      if !empty(arr[j])
        arr[j] := padr(arr[j], 5)
        if empty(mn->pred_d1)
          fl := (arr[j] == mn->pred_d)
        else
          fl := between(diag2num(arr[j]), NUMpred_d, NUMpred_d1)
        endif
        if fl
          exit
        endif  // т.е. один диагноз удовлетворяет условию
      endif
    next
  endif
  if fl .and. !emptyall(mn->diag, mn->kod_diag, mn->soput_d)
    arr := {{human->KOD_DIAG , 1, 0, 0}, ;
            {human->KOD_DIAG2, 2, 0, 0}, ;
            {human->KOD_DIAG3, 3, 0, 0}, ;
            {human->KOD_DIAG4, 4, 0, 0}, ;
            {human->SOPUT_B1 , 5, 0, 0}, ;
            {human->SOPUT_B2 , 6, 0, 0}, ;
            {human->SOPUT_B3 , 7, 0, 0}, ;
            {human->SOPUT_B4 , 8, 0, 0}}
    if is_talon .and. mn->talon_diag > 0
      afill(adiag_talon, 0)
      for i := 1 to 16
        adiag_talon[i] := int(val(substr(human_->DISPANS, i, 1)))
      next
      for j := 1 to len(arr)
        for i := 1 to 2
          if adiag_talon[j * 2 - (2 - i)] > 0
            arr[j, 2 + i] := 1
          endif
        next
      next
    endif
    if fl .and. !emptyall(mn->diag, mn->diag1) // проверим все заболевания
      fl := .f.
      for j := 1 to len(arr)
        if empty(mn->diag1)
          fl := (arr[j, 1] == mn->diag)
        else
          fl := between(diag2num(arr[j, 1]), NUMdiag, NUMdiag1)
        endif
        if fl
          if is_talon .and. mn->talon_diag > 0
            fl := .f.
            if arr[j, 3] > 0 .or. arr[j, 4] > 0 .or. arr_tal_diag[1, 3] == 2 .or. arr_tal_diag[2, 3] == 2
              for i := 1 to 2
                if arr[j, 2 + i] > 0 .or. arr_tal_diag[i, 3] == 2
                  k := adiag_talon[j * 2 - (2 - i)]
                  if arr_tal_diag[i, 3] == 2
                    if empty(k)
                      fl := .t.
                    endif
                  elseif arr_tal_diag[i, 1] > 0 .and. between(k, arr_tal_diag[i, 1], arr_tal_diag[i, 2])
                    fl := .t.
                  endif
                  if fl
                    exit
                  endif
                endif
              next
            endif
          endif
          if fl
            exit
          endif  // т.е. один диагноз удовлетворяет условию
        endif
      next
    endif
    if fl .and. !emptyall(mn->kod_diag, mn->kod_diag1) // проверим основное заболевание
      fl := .f.
      j := 1 // первое = основное заболевание
      if empty(mn->kod_diag1)
        fl := (arr[j, 1] == mn->kod_diag)
      else
        fl := between(diag2num(arr[j, 1]), NUMkod_diag, NUMkod_diag1)
      endif
      if fl
        if is_talon .and. mn->talon_diag > 0
          fl := .f.
          if arr[j, 3] > 0 .or. arr[j, 4] > 0 .or. arr_tal_diag[1, 3] == 2 .or. arr_tal_diag[2, 3] == 2
            for i := 1 to 2
              if arr[j, 2 + i] > 0 .or. arr_tal_diag[i, 3] == 2
                k := adiag_talon[j * 2 - (2 - i)]
                if arr_tal_diag[i, 3] == 2
                  if empty(k)
                    fl := .t.
                  endif
                elseif arr_tal_diag[i, 1] > 0 .and. between(k, arr_tal_diag[i, 1], arr_tal_diag[i, 2])
                  fl := .t.
                endif
                if fl
                  exit
                endif
              endif
            next
          endif
        endif
      endif
    endif
    if fl .and. !emptyall(mn->soput_d, mn->soput_d1) // проверим сопутствующие заболевания
      fl := .f.
      for j := 2 to len(arr)  // начиная со второго
        if empty(mn->soput_d1)
          fl := (arr[j, 1] == mn->soput_d)
        else
          fl := between(diag2num(arr[j, 1]), NUMsoput_d, NUMsoput_d1)
        endif
        if fl
          if is_talon .and. mn->talon_diag > 0
            fl := .f.
            if arr[j, 3] > 0 .or. arr[j, 4] > 0 .or. arr_tal_diag[1, 3] == 2 .or. arr_tal_diag[2, 3] == 2
              for i := 1 to 2
                if arr[j, 2 + i] > 0 .or. arr_tal_diag[i, 3] == 2
                  k := adiag_talon[j * 2 - (2 - i)]
                  if arr_tal_diag[i, 3] == 2
                    if empty(k)
                      fl := .t.
                    endif
                  elseif arr_tal_diag[i, 1] > 0 .and. between(k, arr_tal_diag[i, 1], arr_tal_diag[i, 2])
                    fl := .t.
                  endif
                  if fl
                    exit
                  endif
                endif
              next
            endif
          endif
          if fl
            exit
          endif  // т.е. один диагноз удовлетворяет условию
        endif
      next
    endif
  endif
  if fl .and. yes_h_otd == 1 .and. mn->otd > 0
    fl := (human->otd == mn->otd)
  endif
  if fl .and. mn->ist_fin >= 0
    fl := _f_ist_fin()
  endif
  if fl .and. mn->komu >= 0
    if mn->company == 0
      if mn->komu == 0
        fl := !empty(human_->smo)
      else
        fl := (mn->komu == human->komu)
      endif
    elseif mn->komu == 0
      if human->schet > 0
        if schet->kod != human->schet
          schet->(dbGoto(human->schet))
        endif
        fl := (int(val(schet_->smo)) == mn->company)
      else
        fl := (int(val(cut_code_smo(human_->smo))) == mn->company)
      endif
    else
      fl := (mn->komu == human->komu .and. mn->company == human->str_crb)
    endif
  endif
  k := human->k_data - mn_data + 1
  if fl .and. mn->srok_min > 0
    fl := (mn->srok_min <= k)
  endif
  if fl .and. mn->srok_max > 0
    fl := (k <= mn->srok_max)
  endif
  if fl .and. mn->summa_min > 0
    fl := (mn->summa_min <= msumma)
  endif
  if fl .and. mn->summa_max > 0
    fl := (msumma <= mn->summa_max)
  endif
  fl1 := fl2 := .t.
  if fl
    if flag_hu .or. flag_huF
      ar := {human->kod}
      if is_2
        Ins_Array(ar, 1, rec_1)
      endif
    endif
    if flag_hu
      for i := 1 to len(ar)
        select HU
        find (str(ar[i], 7))
        do while hu->kod == ar[i] .and. !eof()
          lshifr1 := opr_shifr_TFOMS(usl->shifr1, usl->kod, human->k_data)
          if f_paraklinika(usl->shifr, lshifr1, human->k_data)
            lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
            aadd(au_lu, {lshifr, ;              // 1
                        c4tod(hu->date_u), ;               // 2
                        hu_->profil, ;         // 3
                        hu_->PRVS, ;           // 4
                        alltrim(usl->shifr), ; // 5
                        hu->kol_1, ;           // 6
                        c4tod(hu_->date_u2), ;     // 7
                        hu_->kod_diag, ;       // 8
                        hu->(recno()), ;       // 9 - номер записи
                        hu->is_edit})         // 10
            if flag_hu
              aadd(au, {1, hu->(recno()), len(au_lu)})
            endif
          endif
          select HU
          skip
        enddo
      next i
    endif
    if flag_huF
      for i := 1 to len(ar)
        select MOHU
        find (str(ar[i], 7))
        do while mohu->kod == ar[i] .and. !eof()
          Select MOSU
          goto (mohu->u_kod)
          aadd(au_flu, {mosu->shifr1, ;         // 1
                       c4tod(mohu->date_u), ;  // 2
                       mohu->profil, ;         // 3
                       mohu->PRVS, ;           // 4
                       mosu->shifr, ;          // 5
                       mohu->kol_1, ;          // 6
                       c4tod(mohu->date_u2), ; // 7
                       mohu->kod_diag, ;       // 8
                       mohu->(recno())})      // 9 - номер записи
          aadd(au, {2, mohu->(recno()), len(au_flu)})
          select MOHU
          skip
        enddo
      next i
      if mn->kol_pos == 2
        k := 0
        f_vid_p_stom(au_lu, {}, , , human->k_data, @vid_vp, @k, , au_flu)
        if vid_vp == 1 // с лечебной целью
          pol_pos_stom1 += k  // по поводу заболевания
        elseif vid_vp == 2 // // с профилактической целью
          pol_pos_stom2 += k  // профилактика
        elseif vid_vp == 3 // // при оказании неотложной помощи
          pol_pos_stom3 += k  // в неотложной форме
        endif
      endif
    endif
    if flag_hu .or. flag_huF
      if mn->kol_pos == 2 .and. eq_any(human_->USL_OK, 1, 4) // стационар и СМП
        select TMP_KP
        for d := human->n_data to human->k_data
          s := dtoc4(d)
          find (str(human->kod_k, 7) + s)
          if !found()
            append blank
            tmp_kp->kod_k := human->kod_k
            tmp_kp->data  := s
          endif
        next
      endif
      mkol := 0
      for iau := 1 to len(au)
        lal := {'hu', 'mohu'}[au[iau, 1]]
        lal_ := {'hu_', 'mohu'}[au[iau, 1]]
        dbSelectArea(lal)
        dbGoto(au[iau, 2])
        flu := .t.
        if flu .and. mn->date_usl > 0
          flu := between(&lal.->date_u, pdate_usl[7], pdate_usl[8])
        endif
        if flu .and. mn->dom > 0
          if au[iau, 1] == 1 // только для HU
            do case
              case mn->dom == 1 // в поликлинике
                flu := (hu->KOL_RCP >= 0)
              case mn->dom == 2 // на дому
                flu := (hu->KOL_RCP == -1)
              case mn->dom == 3 // на дому-АКТИВ
                flu := (hu->KOL_RCP == -2)
              case mn->dom == 4 // на дому + на дому-АКТИВ
                flu := (hu->KOL_RCP < 0)
            endcase
          elseif mn->dom > 1 // фед.услуги только в поликлинике
            flu := .f.
          endif
        endif
        if flu .and. mn->otd_usl > 0
          flu := (&lal.->otd == mn->otd_usl)
        endif
        if flu .and. mn->PROFIL_U > 0
          flu := (&lal_.->PROFIL == mn->PROFIL_U)
        endif
        if flu .and. mn->vras1 > 0
          flu := (&lal.->kod_vr == mn->vras1 .or. &lal.->kod_as == mn->vras1)
        endif
        if flu .and. mn->vr1 > 0
          flu := (&lal.->kod_vr == mn->vr1)
        endif
        if flu .and. mn->isvr > 0
          if mn->isvr == 1  // нет
            flu := (&lal.->kod_vr == 0)
          else
            flu := (&lal.->kod_vr > 0)
          endif
        endif
        if flu .and. mn->as1 > 0
          flu := (&lal.->kod_as == mn->as1)
        endif
        if flu .and. mn->isas > 0
          if mn->isas == 1  // нет
            flu := (&lal.->kod_as == 0)
          else
            flu := (&lal.->kod_as > 0)
          endif
        endif
        if flu .and. mn->slug_usl > 0 .and. au[iau, 1] == 1 // только для HU
          flu := (usl->slugba == mn->slug_usl)
        endif
        if flu
          if au[iau, 1] == 1 .and. mn->uslugi > 0
            i := ascan(arr_usl, {|x| x[1] == hu->u_kod})
            if (flu := (i > 0))
              fl1 := .f.
              arr_usl[i, 4] += hu->kol_1
              arr_usl[i, 5] += hu->stoim_1
              arr_usl[i, 6] += mrak_s
            endif
          elseif au[iau, 1] == 2 .and. mn->uslugiF > 0
            i := ascan(arr_uslF, {|x| x[1] == mohu->u_kod})
            if (flu := (i > 0))
              fl2 := .f.
              arr_uslF[i, 4] += mohu->kol_1
            endif
          endif
        endif
        if flu
          mkol += &lal.->kol_1
          mstoim += &lal.->stoim_1
          if mem_trudoem == 2 // подсчитывать трудоёмкость
            if au[iau, 1] == 1
              muet += round_5(hu->kol_1 * opr_uet(human->vzros_reb), 4)
            elseif human_->usl_ok == 3 // только для стоматологии
              if year(human->k_data) > 2018
                select LUSLF
                find (mosu->shifr1)
                muet += round_5(mohu->kol_1 * iif(human->vzros_reb == 0, luslf->uetv, luslf->uetd), 4)
              elseif LUSLF18->(used())
                select LUSLF18
                find (mosu->shifr1)
                muet += round_5(mohu->kol_1 * iif(human->vzros_reb == 0, luslf18->uetv, luslf18->uetd), 4)
              endif
            endif
          endif
          if mn->kol_pos == 2 .and. eq_any(human_->USL_OK, 2, 3) .and. au[iau, 1] == 1
            i := au[iau, 3]
            lshifr := au_lu[i, 1]
            if human_->USL_OK == 2 // дневной стационар
              if left(lshifr, 5) == '55.1.' // кол-во пациенто-дней
                for i := 1 to hu->kol_1
                  if i == 1
                    s := hu->date_u
                  else
                    s := dtoc4(c4tod(hu->date_u) + i - 1)
                  endif
                  select TMP_KP
                  find (str(human->kod_k, 7) + s)
                  if !found()
                    append blank
                    tmp_kp->kod_k := human->kod_k
                    tmp_kp->data  := s
                  endif
                next
              endif
            elseif !f_is_zak_sl_vr(lshifr)  // поликлиника
              if left(lshifr, 2) == '2.' // врачебные приёмы амбулаторные
                if between_shifr(lshifr, '2.79.52', '2.79.64')
                  vid_vp := 2 // с профилактической целью
                elseif between_shifr(lshifr, '2.88.40', '2.88.51')
                  vid_vp := 2 // с профилактической целью
                elseif between_shifr(lshifr, '2.80.29', '2.80.38')
                  vid_vp := 3 // при оказании неотложной помощи
                else
                  kol_pos_amb += hu->kol_1
                endif
              else // проверяем старую стоматологию
                for i := 1 to 3
                  if ascan(a_stom_vp[i], lshifr) > 0
                    do case
                      case i == 1 // с лечебной целью
                        pol_pos_stom1 += hu->kol_1  // по поводу заболевания
                      case i == 2 // // с профилактической целью
                        pol_pos_stom2 += hu->kol_1  // профилактика
                      case i == 3 // // при оказании неотложной помощи
                        pol_pos_stom3 += hu->kol_1  // в неотложной форме
                    endcase
                    exit
                  endif
                next
              endif
            endif
          endif
          if flu .and. mn->kol_pos == 2
            select TMP_KP
            find (str(human->kod_k, 7) + &lal.->date_u)
            if !found()
              append blank
              tmp_kp->kod_k := human->kod_k
              tmp_kp->data  := &lal.->date_u
            endif
          endif
        endif
      next
      if emptyall(mkol, mstoim)
        fl := .f.
      elseif mn->uslugi > 0 .and. fl1 // не попало ни одной услуги из списка отбора
        fl := .f.
      elseif mn->uslugiF > 0 .and. fl2 // не попало ни одной услуги из списка отбора
        fl := .f.
      endif
    else
      mstoim := msumma
    endif
  endif
  if fl
    select TMP_K
    find (str(human->kod_k, 7))
    if !found()
      append blank
      tmp_k->kod_k := human->kod_k
    endif
    tmp_k->kol ++
    select TMP
    append blank
    tmp->kod := human->kod
    tmp->kod_k := human->kod_k
    tmp->stoim := mstoim
    tmp->rak_p := mrak_p
    tmp->rak_s := mrak_s
    ssumma += mstoim
    srak_s += mrak_s
    if muet > 0
      suet += muet
    endif
    f2_diag_statist_bukva()
    if ++cf % 5000 == 0
      tmp->(dbCommit())
      tmp_k->(dbCommit())
    endif
  endif
  @ maxrow(), 1 say lstr(cv) color cColorSt2Msg
  @ row(), col() say '/' color 'W/R'
  @ row(), col() say lstr(cf) color cColorStMsg
  return NIL

// 12.10.23
Function titleN_uchEXCEL(worksheet, row, column, arr_u, lsh, c_uch)
  local s := ''

  if !(type('count_uch') == 'N')
    count_uch := iif(c_uch == NIL, 1, c_uch)
  endif
  if count_uch > 1
    if count_uch == len(arr_u)
      WORKSHEET_WRITE_STRING(worksheet, row, column, hb_StrToUtf8(center('[ по всем учреждениям ]')), nil)
    else
      aeval(arr_u, {|x| s += '"' + alltrim(x[2]) + '", ' } )
      s := substr(s, 1, len(s) - 2)
      WORKSHEET_WRITE_STRING(worksheet, row, column, hb_StrToUtf8(center(s)), nil)
    endif
  endif
  return NIL

//
Function f_put_tal_diag()
  Static mm_s := {'Характер заболевания', ;
                  'Диспансерный учет'}
  Local i, s

  for i := 1 to 2
    if arr_tal_diag[i, 3] == 2
      add_string(mm_s[i] + ': не введён')
    elseif arr_tal_diag[i, 1] > 0
      s := mm_s[i] + ': ' + lstr(arr_tal_diag[i, 1])
      if arr_tal_diag[i, 1] != arr_tal_diag[i, 2]
        s += ' - ' + lstr(arr_tal_diag[i, 2])
      endif
      add_string(s)
    endif
  next
  return NIL
  
// 12.10.23
Function f_put_tal_diagEXCEL(worksheet, row, column)
  Static mm_s := {'Характер заболевания', ;
                    'Диспансерный учет'}
  Local i, s
  
  for i := 1 to 2
    if arr_tal_diag[i, 3] == 2
      WORKSHEET_WRITE_STRING(worksheet, row, column, hb_StrToUtf8(mm_s[i] + ': не введён'), nil)
    elseif arr_tal_diag[i, 1] > 0
      s := mm_s[i] + ': ' + lstr(arr_tal_diag[i, 1])
      if arr_tal_diag[i, 1] != arr_tal_diag[i, 2]
        s += ' - ' + lstr(arr_tal_diag[i, 2])
      endif
      WORKSHEET_WRITE_STRING(worksheet, row, column, hb_StrToUtf8(s), nil)
    endif
  next
  return NIL
    
// 12.10.23
Function f3_diag_statist_bukvaEXCEL(HH,sh,arr_title,lvu)
  Local j

  DEFAULT lvu TO 0
  if select('TMP_BUK') == 0
    use (cur_dir + 'tmp_bbuk') index (cur_dir + 'tmp_bbuk') new
    use (cur_dir + 'tmp_buk') index (cur_dir + 'tmp_buk') new
  endif
  select TMP_BUK
  find (str(lvu, 4))
  do while tmp_buk->vu == lvu .and. !eof()
    j := 0
    select TMP_BBUK
    find (str(lvu, 4) + tmp_buk->bukva)
    dbeval({|| ++j }, , {|| tmp_bbuk->vu == lvu .and. tmp_bbuk->bukva == tmp_buk->bukva })
    if verify_FF(HH, .t., sh) .and. valtype(arr_title) == 'A'
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(padl(tmp_buk->bukva, w1 + 6) + str(j, 7) + str(tmp_buk->kol, 7))
    select TMP_BUK
    skip
  enddo
  return NIL
  
  