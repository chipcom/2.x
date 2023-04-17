// mo_263.prg - общие режимы для задачи по приказу 263-ФФОМС
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 23.12.21
Function begin_task_263()
  Static n_zapusk := 0
  Local i, ar, fl := .t., group_ini := 'OBMEN_263'
  local sbase

  if n_zapusk == 0
    ++n_zapusk
    mywait()
    Public p_arr_stac_VO := {}, ; // список всех стационаров области
           dir_263_to, ;          // каталог, куда записываются созданные пакеты
           dir_263_from, ;        // каталог, откуда читаются полученные пакеты
           dir_263_copy, ;        // каталог, куда перезаписываются прочитанные пакеты
          work_otd_263          // 1-работать с отделениями в подзадаче
    ar := GetIniSect(tmp_ini, group_ini)
    dir_263_to   := alltrim(a2default(ar, 'dir_to', ''))
    dir_263_from := alltrim(a2default(ar, 'dir_from', ''))
    dir_263_copy := alltrim(a2default(ar, 'dir_copy', ''))
    work_otd_263 := int(val(a2default(ar, 'work_otd', '0')))
    ar := GetIniSect(tools_ini, group_ini)
    work_otd_263 := int(val(a2default(ar, 'work_otd', lstr(work_otd_263))))

    sbase := prefixFileRefName(WORK_YEAR) + 'uslc'
    R_Use(exe_dir + sbase, , 'USLC')

    index on codemo to (cur_dir + 'tmp_uslc') ;
        for datebeg == 0d20190101 .and. eq_any(left(shifr, 5), '1.11.', '55.1.') ;
        UNIQUE
    dbeval({|| aadd(p_arr_stac_VO, uslc->codemo) })
    use
  endif
  if G_SIsLock(sem_vagno_task[X_263])
    fl := f_err_sem_vagno_task(X_263)
  elseif copy_Tools_Ini()
    Tools_Ini_OMS(1, 0, 0)
  else
    fl := .f.
  endif
  return fl

// 13.09.16 инициализация файлов БД, относящихся к направлениям на госп-ию
Function _263_init()
  Local mo_nfile := { ; // ссылки на файлы обмена
   {'KOD',         'N', 6, 0}, ; // код файла
   {'DATE_F',      'D', 8, 0}, ; // дата файла
   {'NAME_F',      'C', 26, 0}, ; // имя файла без расширения (и ZIP-архива)
   {'DATE_R',      'D', 8, 0}, ; // отчётная дата
   {'NN',          'N', 4, 0}, ; // порядковый номер пакета за отчётную дату
   {'TIP_F',       'N', 1, 0}, ; // от 1 до 7 (пакеты от I01 до I07)
   {'IN_OUT',      'N', 1, 0}, ; // 1-в ТФОМС, 2-из ТФОМС
   {'DATE_OUT',    'D', 8, 0}, ; // дата отправки в ТФОМС
   {'KOL',         'N', 6, 0}, ; // количество пациентов в файле
   {'DWORK',       'D', 8, 0}, ; // дата обработки файла
   {'TWORK1',      'C', 5, 0}, ; // время начала обработки
   {'TWORK2',      'C', 5, 0}, ; // время окончания обработки
   {'TXT_F',       'C', 15, 0}, ; // имя текстового файла протокола без расширения
   {'D_ANS',       'D', 8, 0}, ; // дата протокола ответа из ТФОМС
   {'T_ANS',       'N', 1, 0} ;  // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
  }
  Local mo_nnapr := { ; // список направлений
   {'KOD',         'N', 6, 0}, ; // код направления - номер записи
   {'KOD_K',       'N', 7, 0}, ; // код по картотеке
   {'N_NAPR',      'N', 6, 0}, ; // уникальный номер направления (п-ка)
   {'NUM_D',       'C', 15, 0}, ; // номер направления
   {'DATE_D',      'D', 8, 0}, ; // дата направления
   {'MCOD_1',      'C', 6, 0}, ; // код поликлиники
   {'CODEM_1',     'C', 6, 0}, ; // код поликлиники
   {'DS_1',        'C', 6, 0}, ; // диагноз поликлиники
   {'USL_OK_1',    'N', 1, 0}, ; // условия оказания мед.помощи 1-стационар, 2-дневной стационар
   {'F_MEDC_1',    'N', 1, 0}, ; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
   {'ID_1',        'C', 36, 0}, ; // GUID+lstr(mo_nnapr->KOD) ID направления
   {'DATE_H_1',    'D', 8, 0}, ; // планируемая дата госпитализации
   {'DISP_1',      'N', 1, 0}, ; // Направление выдано по результатам диспансеризации/профосмотра взрослого населения
   {'OTD_1',       'N', 3, 0}, ; // отделение, где выписано направление
   {'PROFIL_1',    'N', 3, 0}, ; // профиль мед.помощи по справочнику V002
   {'PROFIL_K_1',  'N', 3, 0}, ; // профиль койки по справочнику T007
   {'VRACH_1',     'N', 4, 0}, ; // лечащий врач по mo_pers
   {'KOD_F_1out',  'N', 6, 0}, ; // код файла - по файлу mo_nfile
   {'KOD_F_1in',   'N', 6, 0}, ; // код файла - по файлу mo_nfile
   {'T_ANS_1',     'N', 1, 0}, ; // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
   {'S_MCOD',      'C', 6, 0}, ; // код стационара
   {'S_CODEM',     'C', 6, 0}, ; //_код стационара
   {'OTD_2',       'N', 3, 0}, ; // отделение, куда положат
   {'DATE_2',      'D', 8, 0}, ; // дата ввода даты госпитализации
   {'DATE_H_2',    'D', 8, 0}, ; // дата госпитализации, переданная из стационара
   {'KOD_F_2out',  'N', 6, 0}, ; // код файла - по файлу mo_nfile
   {'KOD_F_2in',   'N', 6, 0}, ; // код файла - по файлу mo_nfile
   {'T_ANS_2',     'N', 1, 0}, ; // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
   {'INF_PAC',     'N', 1, 0}, ; //_кто информирует пациента 1-СМО, 2-поликлиника
   {'TIP_ANNUL',   'N', 1, 0}, ; // кто аннулировал (1-СМО, 2-стац, 3-пол)
   {'REA_ANNUL',   'N', 2, 0}, ; // причина аннулирования (от 1 до 9)
   {'DATE_3',      'D', 8, 0}, ; // дата аннулирования
   {'T_ANS_3',     'N', 1, 0}, ; // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
   {'KOD_F_3out',  'N', 6, 0}, ; //_код файла - по файлу mo_nfile
   {'KOD_F_3in',   'N', 6, 0}, ; //_код файла - по файлу mo_nfile
   {'CODEM_FROM',  'C', 6, 0}, ; // из какого МО направлен (п-ка, другой стационар или наш же стационар)
   {'KOD_UP',      'N', 6, 0}, ; // код пред.направления (после перевода в др.отд-ие)
   {'KOD_PP',      'N', 7, 0}, ; // код по БД приёмного покоя
   {'TYPE_H_4',    'N', 1, 0}, ; // госп-ия: 1-по направлению, 2-перевод из другого МО, 3-перевод внутри нашего МО, 4-экстр./неотл. (I05)
   {'DATE_H_4',    'D', 8, 0}, ; // реальная дата госпитализации
   {'TIME_H_4',    'C', 5, 0}, ; // время госпитализации
   {'DNEJ_H_4',    'N', 3, 0}, ; // планируемое количество дней госпитализации (по умолчанию 7)
   {'ID_4',        'C', 36, 0}, ; // GUID+lstr(mo_nnapr->KOD) ID госпитализации для tip_f=4
   {'OTD_4',       'N', 3, 0}, ; // отделение, куда положили
   {'PROFIL_4',    'N', 3, 0}, ; // профиль мед.помощи по справочнику V002
   {'PROFIL_K_4',  'N', 3, 0}, ; // профиль койки по справочнику T007
   {'DS_4',        'C', 6, 0}, ; // диагноз приёмного отделения стационара
   {'USL_OK_4',    'N', 1, 0}, ; // условия оказания мед.помощи 1-стационар, 2-дневной стационар
   {'F_MEDC_4',    'N', 1, 0}, ; // форма оказания мед.помощи по V014 (1-экстренная, 2-неотложная, 3-плановая)
   {'NUM_HIST_4',  'C', 50, 0}, ; // номер истории болезни
   {'T_ANS_4',     'N', 1, 0}, ; // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
   {'KOD_F_4out',  'N', 6, 0}, ; // код файла - по файлу mo_nfile
   {'KOD_F_4in',   'N', 6, 0}, ; //_код файла - по файлу mo_nfile
   {'TYPE_6',      'N', 1, 0}, ; // выбытие: 1-выписан, 2-умер, 3-перевод внутри нашего МО
   {'KOD_NEXT',    'N', 6, 0}, ; // код следующей госпитализации (после перевода в др.отд-ие)
   {'ID_6',        'C', 36, 0}, ; // GUID+lstr(mo_nnapr->KOD) ID выписки для tip_f=6
   {'DATE_6',      'D', 8, 0}, ; // дата выбытия
   {'T_ANS_6',     'N', 1, 0}, ; // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
   {'KOD_F_6out',  'N', 6, 0}, ; //_код файла - по файлу mo_nfile
   {'KOD_F_6in',   'N', 6, 0}, ; //_код файла - по файлу mo_nfile
   {'DATE_R',      'D', 8, 0}, ; // дата рождения
   {'SEX',         'N', 1, 0}, ; // пол
   {'ENP',         'C', 16, 0} ;  // единый номер полиса ОМС
  }
  Local mo_nfina := { ; // ссылки на файлы обмена+направления
   {'KOD_F',       'N', 6, 0}, ; // код файла - по файлу mo_nfile
   {'KOD_N',       'N', 6, 0}, ; // код направления - по файлу mo_nnapr
   {'OSHIB',       'N', 3, 0}, ; // код ошибки
   {'IM_POL',      'C', 20, 0} ;  // имя поля, в котором произошла ошибка
  }
  Local mo_n7in := { ; //
   {'KOD_F',       'N', 6, 0}, ; // код файла - по файлу mo_nfile
   {'CODEM',       'C', 6, 0}, ; // код стационара
   {'ID_PL',       'C', 36, 0}, ; // GUID записи
   {'USL_OK',      'N', 1, 0}, ; // условия оказания мед.помощи 1-стационар, 2-дневной стационар
   {'PROFIL_K',    'N', 3, 0}, ; // профиль койки
   {'PROFIL',      'N', 3, 0}, ; // профиль мед.помощи
   {'KOL_KD',      'N', 3, 0}, ; // кол-во дней по-умолчанию по данному профилю койки
   {'QUANTITY',    'N', 3, 0}, ; // количество коек
   {'Q_P',         'N', 3, 0}, ; // состояло пациентов на начало пред.суток
   {'Q_AP',        'N', 3, 0}, ; // поступило пациентов за пред.сутки
   {'Q_DP',        'N', 3, 0}, ; // выбыло пациентов за пред.сутки
   {'Q_HP',        'N', 3, 0}, ; // запланировано госпитализаций на тек.день
   {'PLACE_FREE',  'N', 3, 0}, ; // количество свободных мест
   {'PF_M',        'N', 3, 0}, ; // --''-- для мужчин
   {'PF_W',        'N', 3, 0}, ; // --''-- для женщин
   {'PF_C',        'N', 3, 0}, ; // --''-- для детей
   {'PLACE1',      'N', 3, 0}, ; // количество свободных мест
   {'PF_M1',       'N', 3, 0}, ; // --''-- для мужчин
   {'PF_W1',       'N', 3, 0}, ; // --''-- для женщин
   {'PF_C1',       'N', 3, 0}, ; // --''-- для детей
   {'PLACE2',      'N', 3, 0}, ; // количество свободных мест
   {'PF_M2',       'N', 3, 0}, ; // --''-- для мужчин
   {'PF_W2',       'N', 3, 0}, ; // --''-- для женщин
   {'PF_C2',       'N', 3, 0}, ; // --''-- для детей
   {'PLACE3',      'N', 3, 0}, ; // количество свободных мест
   {'PF_M3',       'N', 3, 0}, ; // --''-- для мужчин
   {'PF_W3',       'N', 3, 0}, ; // --''-- для женщин
   {'PF_C3',       'N', 3, 0}, ; // --''-- для детей
   {'PLACE4',      'N', 3, 0}, ; // количество свободных мест
   {'PF_M4',       'N', 3, 0}, ; // --''-- для мужчин
   {'PF_W4',       'N', 3, 0}, ; // --''-- для женщин
   {'PF_C4',       'N', 3, 0}, ; // --''-- для детей
   {'PLACE5',      'N', 3, 0}, ; // количество свободных мест
   {'PF_M5',       'N', 3, 0}, ; // --''-- для мужчин
   {'PF_W5',       'N', 3, 0}, ; // --''-- для женщин
   {'PF_C5',       'N', 3, 0}, ; // --''-- для детей
   {'PLACE6',      'N', 3, 0}, ; // количество свободных мест
   {'PF_M6',       'N', 3, 0}, ; // --''-- для мужчин
   {'PF_W6',       'N', 3, 0}, ; // --''-- для женщин
   {'PF_C6',       'N', 3, 0}, ; // --''-- для детей
   {'PLACE7',      'N', 3, 0}, ; // количество свободных мест
   {'PF_M7',       'N', 3, 0}, ; // --''-- для мужчин
   {'PF_W7',       'N', 3, 0}, ; // --''-- для женщин
   {'PF_C7',       'N', 3, 0}, ; // --''-- для детей
   {'PLACE8',      'N', 3, 0}, ; // количество свободных мест
   {'PF_M8',       'N', 3, 0}, ; // --''-- для мужчин
   {'PF_W8',       'N', 3, 0}, ; // --''-- для женщин
   {'PF_C8',       'N', 3, 0}, ; // --''-- для детей
   {'PLACE9',      'N', 3, 0}, ; // количество свободных мест
   {'PF_M9',       'N', 3, 0}, ; // --''-- для мужчин
   {'PF_W9',       'N', 3, 0}, ; // --''-- для женщин
   {'PF_C9',       'N', 3, 0}, ; // --''-- для детей
   {'PLACE10',     'N', 3, 0}, ; // количество свободных мест
   {'PF_M10',      'N', 3, 0}, ; // --''-- для мужчин
   {'PF_W10',      'N', 3, 0}, ; // --''-- для женщин
   {'PF_C10',      'N', 3, 0}, ; // --''-- для детей
   {'V_H34001',    'N', 15, 0}, ; // количество госпитализаций СНГ
   {'V_H34002',    'N', 15, 0}, ; // количество госпитализаций СНГ
   {'V_H34006',    'N', 15, 0}, ; // количество госпитализаций СНГ
   {'V_H34007',    'N', 15, 0} ; // количество госпитализаций СНГ
  }
  Local mo_n7d := { ; // одна запись
   {'DATE_R_EDI',  'D', 8, 0}, ; // отчётная дата (за какое утро вводим)
   {'DATE_R_OUT',  'D', 8, 0}, ; // отчётная дата (за какое утро уже отправили)
   {'DATE_OUT',    'D', 8, 0}, ; // дата последней отправки
   {'DATE_E',      'D', 8, 0}, ; // дата редактирования
   {'TIME_E',      'C', 5, 0}, ; // время редактирования
   {'END_EDIT',    'N', 1, 0}, ; // 0-не закончено, 1-закончено редактирование
   {'KOD_OPER',    'N', 3, 0} ;  // код оператора
  }

  reconstruct(dir_server + 'mo_nfile', mo_nfile, , , .t.)
  reconstruct(dir_server + 'mo_nfina', mo_nfina, , , .t.)
  reconstruct(dir_server + 'mo_nnapr', mo_nnapr, , , .t.)
  reconstruct(dir_server + 'mo_n7in' , mo_n7in , , , .t.)
  reconstruct(dir_server + 'mo_n7out', mo_n7in , , , .t.)
  reconstruct(dir_server + 'mo_n7d'  , mo_n7d  , , , .t.)
  return NIL

// 11.08.14 редактирование картотеки
Function _263_kartoteka(k)
  Local mas_pmt := {'~Добавление', ;
                    '~Редактирование'}
  Local mas_msg := {'Добавление в картотеку информации о больном', ;
                    'Редактирование информации из карточки больного'}
  Local mas_fun := {'append_kart()','regi_kart()'}

  glob_task := X_REGIST
  if k == 2 // для стационара
    Private _task_263_ := .t.
  endif
  popup_prompt(T_ROW, T_COL + 5, 2, mas_pmt, mas_msg, mas_fun)
  glob_task := X_263
  return NIL

// 02.07.14 действия в ответ на выбор в меню 'Профиль койки'
Function f_valid_profil_k(get, old)

  if empty(m1profil_k)
    mprofil := space(67)
    m1profil := 0
    update_get('mprofil')
  elseif m1profil_k != old .and. old != NIL .and. get != NIL
    mprofil := space(67)
    m1profil := 0
    update_get('mprofil')
  endif
  return .t.

// 02.07.14 в GET-е вернуть профиль койки из Т007
Function f_get_profil_k(k, r, c)
  Static sprofil_k := 0
  Local ret, ret_arr

  if empty(k)
    k := sprofil_k
  endif
  popup_2array(arr_t007, -r, c, k, 1, @ret_arr, 'Выбор профиля койки', 'B/BG')
  if valtype(ret_arr) == 'A'
    ret := array(2)
    sprofil_k := ret_arr[2]
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret

// 02.07.14 в GET-е вернуть строку из getV002()
Function f_get_profil(k, r, c, lprofil_k)
  Local arr := {}, i, ret, ret_arr, tmp_select := select()

  if empty(lprofil_k)
    return NIL
  endif
  R_Use(exe_dir + '_mo_t007', cur_dir + '_mo_t007', 'T7')
  find (str(lprofil_k, 3))
  do while lprofil_k == t7->profil_k .and. !eof()
    aadd(arr, {inieditspr(A__MENUVERT, getV002(), t7->PROFIL), t7->profil})
    skip
  enddo
  t7->(dbCloseArea())
  select (tmp_select)
  if empty(arr)
    func_error(4, 'В справочнике T007 не найдено профилей мед.помощи для данного профиля койки')
    return NIL
  endif
  popup_2array(arr, -r, c, k, 1, @ret_arr, 'Выбор профиля мед.помощи', 'B/BG')
  if valtype(ret_arr) == 'A'
    ret := array(2)
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret

// 30.03.23 Проверка информации перед отправкой в ТФОМС
Function _263_to_proverka(yes_msg, /*@*/yes_I07)
  Local i, j, s, ikol := 0, lkod_k, ldate, buf := save_maxrow(), k1, k2, ;
      arr_i01 := {}, arr_i03 := {}, arr_i04 := {}, arr_i05 := {}, arr_i06 := {}, ;
      ldate_h_1, max_date, ta, arr_error := {}

  yes_I07 := .f.
  DEFAULT yes_msg TO .t.
  mywait('Проверка перед составлением...')
  R_Use(dir_exe + '_mo_mkb', cur_dir + '_mo_mkb', 'MKB_10')
  R_Use(dir_exe + '_mo_smo', cur_dir + '_mo_smo2', 'SMO')
  R_Use(dir_server + 'mo_pers', , 'P2')
  R_Use(dir_server + 'kartote_', , 'KART_')
  R_Use(dir_server + 'kartotek', , 'KART')
  set relation to recno() into KART_
  G_Use(dir_server + 'mo_nnapr', , 'NAPR')
  set relation to kod_k into KART
  index on str(kod_k, 7) to (cur_dir + 'tmp_naprkodk')
  // I01
  select NAPR
  index on kod to (cur_dir + 'tmp_napr') ;
      for n_napr > 0 .and. empty(KOD_F_1out)
  go top
  do while !eof()
    if (i := ascan(arr_i01, {|x| x[1] == napr->DATE_D })) == 0
      aadd(arr_i01, {napr->DATE_D, {}})
      i := len(arr_i01)
    endif
    aadd(arr_i01[i, 2], napr->kod)
    select NAPR
    skip
  enddo
  for i := 1 to len(arr_i01)
    DEFAULT max_date TO boy(sys_date)
    max_date := max(max_date, arr_i01[i, 1])
    for j := 1 to len(arr_i01[i, 2])
      ta := {}
      ++ikol
      select NAPR
      goto (arr_i01[i, 2, j])
      lkod_k := napr->kod_k
      lnomer := napr->N_NAPR
      ldate := napr->date_d
      ldate_h_1 := napr->date_h_1
      if !valid_GUID(napr->ID_1)
        G_RLock(forever)
        napr->ID_1 := mo_guid(1, napr->kod)
        UnLock
      endif
      if empty(napr->num_d)
        aadd(ta, 'не введён номер направления')
      endif
      if empty(napr->date_d)
        aadd(ta, 'не введена дата направления')
      elseif napr->date_d > sys_date
        aadd(ta, 'дата направления больше системной даты ' + full_date(napr->date_d))
      elseif napr->date_d < sys_date - 180
        aadd(ta, 'дата направления НЕКОРРЕКТНА ' + full_date(napr->date_d))
      elseif _263_verify_year(napr->date_d, ta)
      endif
      if emptyany(napr->S_MCOD, napr->S_CODEM)
        aadd(ta, 'не введён код стационара для госпитализации')
      endif
      if empty(napr->PROFIL_K_1)
        aadd(ta, 'не введён профиль койки')
      endif
      if empty(napr->PROFIL_1)
        aadd(ta, 'не введён профиль медицинской помощи')
      endif
      if empty(napr->DS_1)
        aadd(ta, 'не введён диагноз поликлиники')
      else
        select MKB_10
        find (padr(napr->DS_1, 6))
        if found()
          if !between_date(mkb_10->dbegin, mkb_10->dend, napr->date_d)
            aadd(ta, 'диагноз поликлиники не входит в ОМС')
          endif
          if !empty(mkb_10->pol) .and. !(mkb_10->pol == kart->pol)
            aadd(ta, 'несовместимость диагноза поликлиники по полу ' + alltrim(napr->DS_1))
          endif
        else
          aadd(ta, 'не найден диагноз поликлиники ' + alltrim(napr->DS_1) + ' в справочнике МКБ-10')
        endif
      endif
      if empty(napr->F_MEDC_1)
        aadd(ta, 'не введена форма оказания мед.помощи')
      endif
      if empty(napr->VRACH_1)
        aadd(ta, 'не введен врач, выписавший направление')
      else
        select P2
        goto (napr->VRACH_1)
        mvrach := fam_i_o(p2->fio) + ' [' + lstr(p2->tab_nom) + ']'
        if empty(p2->snils)
          aadd(ta, 'не введен СНИЛС у врача - ' + mvrach)
        else
          s := space(80)
          if !val_snils(p2->snils, 2, @s)
            aadd(ta,s+' у врача - ' + mvrach)
          endif
        endif
      endif
      if empty(napr->DATE_H_1)
        aadd(ta, 'не введена дата госпитализации')
      elseif napr->DATE_H_1 - napr->date_d > 30
        aadd(ta, 'дата госпитализации ' + full_date(napr->DATE_H_1) + ' более 30 дней от даты направления ' + full_date(napr->date_d))
      endif
      val_fio(retFamImOt(1, .f.), ta)
      if year(kart->date_r) < 1900
        aadd(ta, 'дата рождения: ' + full_date(kart->date_r) + ' ( < 1900г.)')
      endif
      if kart->date_r > napr->date_d
        aadd(ta, 'дата рождения: ' + full_date(kart->date_r) + ;
                ' > даты направления: ' + full_date(napr->date_d))
      endif
      if !empty(kart->snils)
        s := space(80)
        if !val_snils(kart->snils, 2, @s)
          aadd(ta, s + ' у пациента')
        endif
      endif
      Valid_SN_Polis(kart_->vpolis, kart_->SPOLIS, kart_->NPOLIS, ta, between(kart_->smo, '34001', '34007'))
      select SMO
      if alltrim(kart_->smo) == '34'
        if empty(kart_->KVARTAL_D)
          aadd(ta, 'не введён субъект РФ, в котором застрахован пациент')
        elseif empty(ret_inogSMO_name(1))
          aadd(ta, 'не введена иногородняя страховая компания')
        endif
      else
        select SMO
        find (kart_->smo)
        if !found()
          aadd(ta, 'не найдена СМО с кодом "' + kart_->smo + '"')
        endif
      endif
      if emptyall(kart_->PHONE_M, kart_->PHONE_H, kart_->PHONE_W)
        aadd(ta, 'не введён ни один телефон')
      else
        if !empty(kart_->PHONE_M)
          _263_valid_phone(1, kart_->PHONE_M, ta)
        endif
        if !empty(kart_->PHONE_H)
          _263_valid_phone(2, kart_->PHONE_H, ta)
        endif
        if !empty(kart_->PHONE_W)
          _263_valid_phone(3, kart_->PHONE_W, ta)
        endif
      endif
      select NAPR
      set index to (cur_dir + 'tmp_naprkodk')
      find (str(lkod_k, 7))
      do while napr->kod_k == lkod_k .and. !eof()
        if napr->kod == arr_i01[i, 2, j] .or. napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0
          // текущую запись или аннулирования пропустим
        elseif !empty(napr->date_h_4)
          fl := .f.
          if empty(napr->CODEM_FROM)
            if napr->TYPE_H_4 == 4 .and. napr->KOD_F_4out == -99 // не наша госпитализация
              s := ret_mo(napr->S_CODEM)[_MO_SHORT_NAME]
            else
              s := 'нашем стационаре'
              fl := .t.
            endif
          else
            s := ret_mo(napr->CODEM_FROM)[_MO_SHORT_NAME]
            fl := (napr->CODEM_FROM == glob_mo[_MO_KOD_TFOMS])
          endif
          if empty(napr->date_6)
            if fl
              aadd(ta, 'у пациента выписано направление №' + lstr(lnomer) + ' от ' + full_date(ldate) + ',')
              aadd(ta, ' но он уже госпитализирован в ' + s + ' ' + full_date(napr->date_h_4) + ' и ещё не выписан')
            endif
          elseif ldate_h_1 > napr->DATE_H_4 .and. ldate < napr->DATE_6
            if fl
              aadd(ta, 'у пациента выписано направление №' + lstr(lnomer) + ' от ' + full_date(ldate) + ',')
              aadd(ta, ' по текущему направлению планируемая дата госпитализации ' + full_date(ldate_h_1))
              aadd(ta, ' пересекается с госпитализацией в '+s+' ' + full_date(napr->date_h_4) + '-' + full_date(napr->date_6))
            endif
          endif
        else
          if abs(ldate - napr->date_d) < 20 .or. abs(ldate_h_1 - napr->date_h_1) < 20 //;
               //.or. (!empty(napr->date_h_2) .and. abs(ldate_h_1 - napr->date_h_2) < 20)
            aadd(ta, 'у пациента 2 направления: №' + lstr(lnomer) + ' от ' + full_date(ldate) + ;
                  ' и №' + lstr(napr->N_NAPR) + ' от ' + full_date(napr->date_d))
          endif
        endif
        skip
      enddo
      if !empty(ta)
        aadd(arr_error, {1, arr_i01[i, 2, j], aclone(ta)} )
      endif
    next
  next
  // I03
  select NAPR
  index on kod to (cur_dir + 'tmp_napr') ;
      for n_napr > 0 .and. KOD_F_1out > 0 .and. TIP_ANNUL == 3 .and. empty(KOD_F_3out)
  go top
  do while !eof()
    if (i := ascan(arr_i03, {|x| x[1] == napr->DATE_3 })) == 0
      aadd(arr_i03, {napr->DATE_3, {}})
      i := len(arr_i03)
    endif
    aadd(arr_i03[i, 2], napr->kod)
    select NAPR
    skip
  enddo
  index on kod to (cur_dir + 'tmp_napr') ;
      for (KOD_F_1in > 0 .or. (T_ANS_1 == 1 .and. CODEM_1 == glob_mo[_MO_KOD_TFOMS])) ;
          .and. TIP_ANNUL == 2 .and. empty(KOD_F_3out)
  go top
  do while !eof()
    if (i := ascan(arr_i03, {|x| x[1] == napr->DATE_3 })) == 0
      aadd(arr_i03, {napr->DATE_3, {}})
      i := len(arr_i03)
    endif
    aadd(arr_i03[i, 2], napr->kod)
    select NAPR
    skip
  enddo
  for i := 1 to len(arr_i03)
    DEFAULT max_date TO boy(sys_date)
    max_date := max(max_date, arr_i03[i, 1])
    for j := 1 to len(arr_i03[i, 2])
      ta := {}
      ++ikol
      select NAPR
      goto (arr_i03[i, 2, j])
      lkod_k := napr->kod_k
      if !valid_GUID(napr->ID_1, 2)
        aadd(ta, 'некорректное поле ID_D (GUID направления)')
      endif
      if napr->date_d > napr->date_3
        aadd(ta, 'дата аннулирования меньше даты направления ' + full_date(napr->date_3))
      elseif napr->date_3 > sys_date
        aadd(ta, 'дата аннулирования больше системной даты ' + full_date(napr->date_3))
      elseif napr->date_3 > napr->DATE_H_1
        aadd(ta, 'дата госпитализации меньше даты аннулирования ' + full_date(napr->date_3))
      //elseif !empty(napr->DATE_H_2) .and. napr->date_3 > napr->DATE_H_2
        //aadd(ta, 'дата госпитализации меньше даты аннулирования ' + full_date(napr->date_3))
      elseif _263_verify_year(napr->date_3, ta)
      endif
      if ascan(get_reason_annul(), {|x| x[2] == napr->REA_ANNUL} ) == 0
        aadd(ta, 'не указана причина аннулирования')
      endif
      if !empty(napr->date_h_4)
        if empty(napr->CODEM_FROM)
          s := 'нашем стационаре'
        else
          s := ret_mo(napr->CODEM_FROM)[_MO_SHORT_NAME]
        endif
        aadd(ta, 'пациент уже госпитализирован в ' + s + ' ' + full_date(napr->date_h_4))
      endif
      if !empty(ta)
        aadd(arr_error, {3, arr_i03[i, 2, j], aclone(ta)} )
      endif
    next
  next
  // I04
  select NAPR
  index on kod to (cur_dir + 'tmp_napr') for between(TYPE_H_4, 1, 3) .and. empty(KOD_F_4out)
  go top
  do while !eof()
    if (i := ascan(arr_i04, {|x| x[1] == napr->DATE_H_4 })) == 0
      aadd(arr_i04, {napr->DATE_H_4, {}})
      i := len(arr_i04)
    endif
    aadd(arr_i04[i, 2], napr->kod)
    select NAPR
    skip
  enddo
  for i := 1 to len(arr_i04)
    DEFAULT max_date TO boy(sys_date)
    max_date := max(max_date, arr_i04[i, 1])
    for j := 1 to len(arr_i04[i, 2])
      ta := {}
      ++ikol
      select NAPR
      goto (arr_i04[i, 2, j])
      lkod_k := napr->kod_k
      ldate := napr->DATE_H_4
      if !valid_GUID(napr->ID_4)
        G_RLock(forever)
        napr->ID_4 := mo_guid(1, napr->kod)
        UnLock
      endif
      if napr->TYPE_H_4 == 1 .and. !valid_GUID(napr->ID_1, 2)
        aadd(ta, 'некорректное поле ID_D (GUID направления)')
      endif
      if empty(napr->CODEM_FROM)
        aadd(ta, 'не введён код направившего учреждения')
      endif
      if empty(napr->DATE_H_4)
        aadd(ta, 'не введена дата госпитализации')
      elseif napr->date_h_4 > sys_date
        aadd(ta, 'дата госпитализации больше системной даты ' + full_date(napr->date_h_4))
      elseif napr->date_h_4 < sys_date - 180
        aadd(ta, 'дата госпитализации НЕКОРРЕКТНА ' + full_date(napr->date_h_4))
      elseif !between(int(val(left(napr->TIME_H_4, 2))), 0, 23) .or. !between(int(val(right(napr->TIME_H_4, 2))), 0, 59)
        aadd(ta, 'время госпитализации НЕКОРРЕКТНО ' + napr->TIME_H_4)
      elseif _263_verify_year(napr->date_h_4, ta)
      endif
      if empty(napr->TIME_H_4)
        aadd(ta, 'не введено время госпитализации')
      endif
      if empty(napr->DS_4)
        aadd(ta, 'не введён диагноз приёмного покоя')
      else
        select MKB_10
        find (padr(napr->DS_4, 6))
        if found()
          if !between_date(mkb_10->dbegin, mkb_10->dend, napr->DATE_H_4)
            aadd(ta, 'диагноз приёмного покоя не входит в ОМС')
          endif
          if !empty(mkb_10->pol) .and. !(mkb_10->pol == kart->pol)
            aadd(ta, 'несовместимость диагноза приёмного покоя по полу ' + alltrim(napr->DS_4))
          endif
        else
          aadd(ta, 'не найден диагноз приёмного покоя ' + alltrim(napr->DS_4) + ' в справочнике МКБ-10')
        endif
      endif
      if empty(napr->F_MEDC_4)
        aadd(ta, 'не введена форма оказания мед.помощи')
      endif
      if empty(napr->PROFIL_K_4)
        aadd(ta, 'не введён профиль койки')
      endif
      if empty(napr->PROFIL_4)
        aadd(ta, 'не введён профиль медицинской помощи')
      endif
      if empty(napr->NUM_HIST_4)
        aadd(ta, 'не введен номер истории болезни')
      endif
      val_fio(retFamImOt(1, .f.), ta)
      if year(kart->date_r) < 1900
        aadd(ta, 'дата рождения: ' + full_date(kart->date_r) + ' ( < 1900г.)')
      endif
      if kart->date_r > napr->DATE_H_4
        aadd(ta, 'дата рождения: ' + full_date(kart->date_r) + ' > даты госпитализации: ' + full_date(napr->DATE_H_4))
      endif
      if !empty(kart->snils)
        s := space(80)
        if !val_snils(kart->snils, 2, @s)
          aadd(ta, s)
        endif
      endif
      Valid_SN_Polis(kart_->vpolis, kart_->SPOLIS, kart_->NPOLIS, ta, between(kart_->smo, '34001', '34007'))
      select SMO
      if alltrim(kart_->smo) == '34'
        if empty(kart_->KVARTAL_D)
          aadd(ta, 'не введён субъект РФ, в котором застрахован пациент')
        elseif empty(ret_inogSMO_name(1))
          aadd(ta, 'не введена иногородняя страховая компания')
        endif
      else
        select SMO
        find (kart_->smo)
        if !found()
          aadd(ta, 'не найдена СМО с кодом "' + kart_->smo + '"')
        endif
      endif
      select NAPR
      set index to (cur_dir + 'tmp_naprkodk')
      find (str(lkod_k, 7))
      do while napr->kod_k == lkod_k .and. !eof()
        if napr->kod == arr_i04[i, 2, j]
          // текущую запись пропустим
        elseif !empty(napr->DATE_H_4)
          fl := .f.
          if empty(napr->CODEM_FROM)
            if napr->TYPE_H_4 == 4 .and. napr->KOD_F_4out == -99 // не наша госпитализация
              fl := (napr->S_CODEM == glob_mo[_MO_KOD_TFOMS])
            else
              fl := .t. // наша госпитализация
            endif
          else
            fl := (napr->CODEM_FROM == glob_mo[_MO_KOD_TFOMS])
          endif
          if !empty(napr->DATE_6) // если уже выписан
            if ldate > napr->DATE_H_4 .and. ldate < napr->DATE_6
              if fl
                aadd(ta, 'у данного пациента обнаружена госпитализация с ' + full_date(napr->DATE_H_4) + ' по ' + full_date(napr->DATE_6))
              endif
            endif
          else
            if fl
              aadd(ta, 'у данного пациента обнаружена незавершённая госпитализация от ' + full_date(napr->DATE_H_4))
            endif
          endif
        endif
        skip
      enddo
      if !empty(ta)
        aadd(arr_error, {4, arr_i04[i, 2, j], aclone(ta)} )
      endif
    next
  next
  // I05
  select NAPR
  index on kod to (cur_dir + 'tmp_napr') for TYPE_H_4 == 4 .and. empty(KOD_F_4out)
  go top
  do while !eof()
    if (i := ascan(arr_i05, {|x| x[1] == napr->DATE_H_4 })) == 0
      aadd(arr_i05, {napr->DATE_H_4, {}})
      i := len(arr_i05)
    endif
    aadd(arr_i05[i, 2], napr->kod)
    select NAPR
    skip
  enddo
  for i := 1 to len(arr_i05)
    DEFAULT max_date TO boy(sys_date)
    max_date := max(max_date, arr_i05[i, 1])
    for j := 1 to len(arr_i05[i, 2])
      ta := {}
      ++ikol
      select NAPR
      goto (arr_i05[i, 2, j])
      lkod_k := napr->kod_k
      ldate := napr->DATE_H_4
      if !valid_GUID(napr->ID_4)
        G_RLock(forever)
        napr->ID_4 := mo_guid(1, napr->kod)
        UnLock
      endif
      if empty(napr->DATE_H_4)
        aadd(ta, 'не введена дата госпитализации')
      elseif napr->date_h_4 > sys_date
        aadd(ta, 'дата госпитализации больше системной даты ' + full_date(napr->date_h_4))
      elseif napr->date_h_4 < sys_date - 180
        aadd(ta, 'дата госпитализации НЕКОРРЕКТНА ' + full_date(napr->date_h_4))
      elseif !between(int(val(left(napr->TIME_H_4, 2))), 0, 23) .or. !between(int(val(right(napr->TIME_H_4, 2))), 0, 59)
        aadd(ta, 'время госпитализации НЕКОРРЕКТНО ' + napr->TIME_H_4)
      elseif _263_verify_year(napr->date_h_4, ta)
      endif
      if empty(napr->TIME_H_4)
        aadd(ta, 'не введено время госпитализации')
      endif
      if empty(napr->DS_4)
        aadd(ta, 'не введён диагноз приёмного покоя')
      else
        select MKB_10
        find (padr(napr->DS_4, 6))
        if found()
          if !between_date(mkb_10->dbegin,mkb_10->dend, napr->DATE_H_4)
            aadd(ta, 'диагноз приёмного покоя не входит в ОМС')
          endif
          if !empty(mkb_10->pol) .and. !(mkb_10->pol == kart->pol)
            aadd(ta, 'несовместимость диагноза приёмного покоя по полу ' + alltrim(napr->DS_4))
          endif
        else
          aadd(ta, 'не найден диагноз приёмного покоя ' + alltrim(napr->DS_4) + ' в справочнике МКБ-10')
        endif
      endif
      if empty(napr->F_MEDC_4)
        aadd(ta, 'не введена форма оказания мед.помощи')
      endif
      if empty(napr->PROFIL_K_4)
        aadd(ta, 'не введён профиль койки')
      endif
      if empty(napr->PROFIL_4)
        aadd(ta, 'не введён профиль медицинской помощи')
      endif
      if empty(napr->NUM_HIST_4)
        aadd(ta, 'не введен номер истории болезни')
      endif
      val_fio(retFamImOt(1, .f.), ta)
      if year(kart->date_r) < 1900
        aadd(ta, 'дата рождения: ' + full_date(kart->date_r) + ' ( < 1900г.)')
      endif
      if kart->date_r > napr->DATE_H_4
        aadd(ta, 'дата рождения: ' + full_date(kart->date_r) + ;
                ' > даты госпитализации: ' + full_date(napr->DATE_H_4))
      endif
      if !empty(kart->snils)
        s := space(80)
        if !val_snils(kart->snils, 2, @s)
          aadd(ta, s)
        endif
      endif
      if !empty(kart_->NPOLIS)
        Valid_SN_Polis(kart_->vpolis, kart_->SPOLIS, kart_->NPOLIS, ta, between(kart_->smo, '34001', '34007'))
        select SMO
        if alltrim(kart_->smo) == '34'
          if empty(kart_->KVARTAL_D)
            aadd(ta, 'не введён субъект РФ, в котором застрахован пациент')
          elseif empty(ret_inogSMO_name(1))
            aadd(ta, 'не введена иногородняя страховая компания')
          endif
        else
          select SMO
          find (kart_->smo)
          if !found()
            aadd(ta, 'не найдена СМО с кодом "' + kart_->smo + '"')
          endif
        endif
      endif
      select NAPR
      set index to (cur_dir + 'tmp_naprkodk')
      find (str(lkod_k, 7))
      do while napr->kod_k == lkod_k .and. !eof()
        if napr->kod == arr_i05[i, 2, j]
          // текущую запись пропустим
        elseif !empty(napr->DATE_H_4)
          fl := .f.
          if empty(napr->CODEM_FROM)
            if napr->TYPE_H_4 == 4 .and. napr->KOD_F_4out == -99 // не наша госпитализация
              fl := (napr->S_CODEM == glob_mo[_MO_KOD_TFOMS])
            else
              fl := .t. // наша госпитализация
            endif
          else
            fl := (napr->CODEM_FROM == glob_mo[_MO_KOD_TFOMS])
          endif
          if !empty(napr->DATE_6) // если уже выписан
            if ldate > napr->DATE_H_4 .and. ldate < napr->DATE_6
              if fl
                aadd(ta, 'у данного пациента обнаружена госпитализация с ' + full_date(napr->DATE_H_4) + ' по ' + full_date(napr->DATE_6))
              endif
            endif
          else
            if fl
              aadd(ta, 'у данного пациента обнаружена незавершённая госпитализация от ' + full_date(napr->DATE_H_4))
            endif
          endif
        endif
        skip
      enddo
      if !empty(ta)
        aadd(arr_error, {5,arr_i05[i, 2, j], aclone(ta)} )
      endif
    next
  next
  // I06
  select NAPR
  index on kod to (cur_dir + 'tmp_napr') ;
      for KOD_F_4out > 0 .and. T_ANS_4 == 1 .and. !empty(DATE_6) .and. empty(KOD_F_6out)
  go top
  do while !eof()
    if (i := ascan(arr_i06, {|x| x[1] == napr->DATE_6 })) == 0
      aadd(arr_i06, {napr->DATE_6, {}})
      i := len(arr_i06)
    endif
    aadd(arr_i06[i, 2], napr->kod)
    select NAPR
    skip
  enddo
  for i := 1 to len(arr_i06)
    DEFAULT max_date TO boy(sys_date)
    max_date := max(max_date, arr_i06[i, 1])
    for j := 1 to len(arr_i06[i, 2])
      ta := {}
      ++ikol
      select NAPR
      goto (arr_i06[i, 2, j])
      if !valid_GUID(napr->ID_6)
        G_RLock(forever)
        napr->ID_6 := mo_guid(1, napr->kod)
        UnLock
      endif
      if empty(napr->DATE_H_4)
        aadd(ta, 'не введена дата госпитализации')
      endif
      if empty(napr->DATE_6)
        aadd(ta, 'не введена дата выбытия')
      elseif napr->date_6 < napr->date_h_4
        aadd(ta, 'дата выбытия меньше даты госпитализации ' + full_date(napr->date_6) + ' < ' + full_date(napr->date_h_4))
      elseif napr->date_6 > napr->date_h_4 + 180
        aadd(ta, 'дата выбытия НЕКОРРЕКТНА ' + full_date(napr->date_6))
      endif
      if empty(napr->F_MEDC_4)
        aadd(ta, 'не введена форма оказания мед.помощи')
      endif
      if empty(napr->PROFIL_K_4)
        aadd(ta, 'не введён профиль койки')
      endif
      if empty(napr->PROFIL_4)
        aadd(ta, 'не введён профиль медицинской помощи')
      endif
      if empty(napr->NUM_HIST_4)
        aadd(ta, 'не введен номер истории болезни')
      endif
      if napr->TYPE_H_4 == 1
        if !valid_GUID(napr->ID_1, 2)
          aadd(ta, 'некорректное поле ID_D (GUID направления)')
        endif
        if empty(napr->CODEM_FROM)
          aadd(ta, 'не введён код направившего учреждения')
        endif
      endif
      if empty(napr->NUM_HIST_4)
        aadd(ta, 'не введен номер истории болезни')
      endif
      if year(kart->date_r) < 1900
        aadd(ta, 'дата рождения: ' + full_date(kart->date_r) + ' ( < 1900г.)')
      endif
      if kart->date_r > napr->date_6
        aadd(ta, 'дата рождения: ' + full_date(kart->date_r) + ' > даты выбытия: ' + full_date(napr->DATE_6))
      endif
      if !empty(ta)
        aadd(arr_error, {6, arr_i06[i, 2, j], aclone(ta)} )
      endif
    next
  next
  // I07
  if is_napr_stac
    ta1 := {}
    R_Use(dir_server + 'mo_n7d', , 'D7')
    if lastrec() > 0 .and. !empty(d7->DATE_R_EDI)
      if !emptyany(d7->DATE_R_EDI, d7->DATE_R_OUT, d7->DATE_OUT) .and. ;
                            d7->DATE_R_EDI == d7->DATE_R_OUT .and. d7->DATE_OUT == sys_date
        // ничего не делаем, т.к. уже сегодня отправили
      elseif empty(d7->END_EDIT)
        if !empty(d7->DATE_R_OUT)
          aadd(ta1, 'не подтверждено окончание редактирования')
        endif
      else
        if !emptyany(d7->DATE_R_EDI, d7->DATE_R_OUT, d7->DATE_OUT) .and. ;
                              d7->DATE_R_EDI == d7->DATE_R_OUT .and. d7->DATE_OUT < sys_date
          aadd(ta1, 'после последней отправки в ТФОМС не было входа в редактирование')
        endif
        if d7->DATE_R_EDI > sys_date
          aadd(ta1, 'отчётная дата больше системной даты ' + full_date(d7->DATE_R_EDI))
        elseif d7->DATE_R_EDI < sys_date - 60
          aadd(ta1, 'отчётная дата НЕКОРРЕКТНА ' + full_date(d7->DATE_R_EDI))
        elseif _263_verify_year(d7->DATE_R_EDI, ta1)
        endif
        G_Use(dir_server + 'mo_n7out', , 'N7')
        index on padr(inieditspr(A__MENUVERT, arr_t007, n7->PROFIL_K), 60) + str(n7->PROFIL_K, 3) + ;
               padr(inieditspr(A__MENUVERT, getV002(), n7->PROFIL), 20) + str(n7->PROFIL, 3) to (cur_dir + 'tmp_n7')
        go top
        if !eof()
          do while !eof()
            yes_I07 := .t.
            ta := {}
            if n7->QUANTITY == 0
              aadd(ta, '-не введено количество коек')
            else
              k1 := n7->QUANTITY - (n7->Q_P + n7->Q_AP - n7->Q_DP + n7->Q_HP)
              k2 := n7->PF_M + n7->PF_W + n7->PF_C
              if n7->PLACE_FREE < 0
                aadd(ta, '-количество свободных коек меньше нуля')
              elseif k1 == k2
                if k1 != n7->PLACE_FREE
                  G_RLock(forever)
                  n7->PLACE_FREE := k1
                  UnLock
                  Commit
                endif
              else
                aadd(ta, '-количество свободных коек по разным формулам: ' + lstr(k1) + ' != ' + lstr(k2))
              endif
            endif
            if !empty(ta)
              Ins_Array(ta, 1, alltrim(inieditspr(A__MENUVERT, arr_t007, n7->PROFIL_K)) + ;
                           ' (' + alltrim(inieditspr(A__MENUVERT, getV002(), n7->PROFIL)) + ')')
              aadd(arr_error, {7, 0, aclone(ta)} )
            endif
            select N7
            skip
          enddo
        endif
      endif
    endif
    if !empty(ta1)
      aadd(arr_error, {7, 0, aclone(ta1)} )
    endif
  endif
  if len(arr_error) == 0
    if yes_msg
      stat_msg('Проверено пациентов - ' + lstr(ikol) + '. Ошибок не обнаружено!')
      mybell(4, OK)
    endif
  else
    name_file := cur_dir + '263error' + stxt
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    add_string(full_date(sys_date) + ' '+hour_min(seconds()))
    add_string('')
    add_string(center('Список обнаруженных ошибок', 80))
    select NAPR
    set index to
    for i := 1 to len(arr_error)
      do case
        case arr_error[i, 1] == 1
          s := 'Поликлиника/Направления'
        case arr_error[i, 1] == 3
          s := 'Поликлиника(Стационар)/Аннулирование'
        case arr_error[i, 1] == 4 .or. arr_error[i, 1] == 5
          s := 'Стационар/Госпитализация'
        case arr_error[i, 1] == 6
          s := 'Стационар/Выбытие'
        case arr_error[i, 1] == 7
          s := 'Стационар/Свободные койки'
      endcase
      verify_FF(76, .t., 80)
      add_string('')
      add_string('пакет I0' + lstr(arr_error[i, 1]) + '... режим "' + s + '"')
      if arr_error[i, 1] < 7
        goto (arr_error[i, 2])
        add_string(alltrim(kart->fio) + ' д.р.' + full_date(kart->date_r))
      endif
      for j := 1 to len(arr_error[i, 3])
        verify_FF(80, .t., 80)
        add_string('- ' + arr_error[i, 3, j])
      next
    next
    fclose(fp)
    close databases
    viewtext(name_file, , , , .t., , , 5)
  endif
  close databases
  rest_box(buf)
  return len(arr_error) == 0

// 13.12.21 проверить год, если вдруг 'сбита' системная дата в компьютере
Function _263_verify_year(mdate, arr)
  local end_year := WORK_YEAR + iif(month(sys_date) == 12, 1, 0)

  if !between(year(mdate), 2019, end_year)
    aadd(arr, 'в отчётной дате ' + full_date(mdate) + ' НЕКОРРЕКТНЫЙ год')
  endif
  return .f.


// 14.09.15 проверка на правильность номера телефона
Function _263_valid_phone(k, s, ta)
  Local s1

  if !empty(s)
    s := charrem('-', s)
    s := charrem(' ', s)
    s1 := CHARREPL('0123456789', s, SPACE(10))
    if !empty(s1) .or. !(left(s, 1) == '8')
      if k == 1
        aadd(ta, 'Правильный номер мобильного телефона: "8" + ещё 10 цифр')
      else
        aadd(ta, 'Правильный номер телефона: "8" + "код города" + "цифры" (всего 11 цифр)')
      endif
    endif
    if len(s) < 11
      aadd(ta, 'В номере телефона должно быть 11 знаков')
    endif
  endif
  return NIL

// 15.01.19 Составление информационных пакетов для отправкой в ТФОМС
Function _263_to_sostavlenie()
  Local i, j, k, mnn, nfile,  arr_f := {}, name_txt, file_error, buf := save_maxrow(), ;
      arr_i01 := {}, arr_i03 := {}, arr_i04 := {}, arr_i05 := {}, arr_i06 := {}, ;
      fl_error := .f., yes_i07 := .f.

  if empty(dir_263_to)
    return func_error(4, 'Не настроен каталог обмена в режиме "Настройка каталогов"')
  endif
  if !_263_to_proverka(.f., @yes_i07)
    return NIL
  endif
  if !mo_Lock_Task(X_263)
    return NIL
  endif
  mywait()
  //
  Private cFileProtokol := cur_dir + 'tmp' + stxt, cTimeBegin := hour_min(seconds())
  name_txt := dtos(sys_date) + '_' + charrem(':', padr(sectotime(seconds()), 8)) + stxt
  //
  R_Use(dir_server + 'mo_pers', , 'P2')
  R_Use(dir_server + 'kartote2', , 'KART2')
  R_Use(dir_server + 'kartote_', , 'KART_')
  R_Use(dir_server + 'kartotek', , 'KART')
  set relation to recno() into KART_, to recno() into KART2
  G_Use(dir_server + 'mo_nfina', , 'NFN')
  G_Use(dir_server + 'mo_nfile', , 'NF')
  index on str(tip_f, 1) + dtos(date_r) + str(in_out, 1) + str(nn, 4) to (cur_dir + 'tmp_nf')
  G_Use(dir_server + 'mo_nnapr', , 'NAPR')
  set relation to kod_k into KART
  
  // I01
select NAPR
index on kod to (cur_dir + 'tmp_napr') for n_napr > 0 .and. empty(KOD_F_1out)
go top
do while !eof()
  if (i := ascan(arr_i01, {|x| x[1] == napr->DATE_D })) == 0
    aadd(arr_i01, {napr->DATE_D, {}}) ; i := len(arr_i01)
  endif
  aadd(arr_i01[i, 2], napr->kod)
  select NAPR
  skip
enddo
for i := 1 to len(arr_i01)
  mnn := 0
  select NF
  find ('1'+dtos(arr_i01[i, 1]) + '1')
  do while nf->tip_f==1 .and. nf->date_r==arr_i01[i, 1] .and. nf->in_out==1 .and. !eof()
    mnn := nf->nn
    skip
  enddo
  ++mnn // номер пакета
  nfile := 'I01T34M'+glob_mo[_MO_KOD_TFOMS]+'_' + ;
           right(str(year(arr_i01[i, 1]), 4), 2) + ;
           strzero(month(arr_i01[i, 1]), 2) + ;
           strzero(day(arr_i01[i, 1]), 2) + ;
           lstr(mnn)
  select NF
  AddRec(1)
  nf->KOD := recno()            // код файла
  nf->DATE_F := sys_date        // дата файла
  nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
  nf->DATE_R := arr_i01[i, 1]    // отчётная дата
  nf->NN := mnn                 // порядковый номер пакета за отчётную дату
  nf->TIP_F := 1                // от 1 до 7 (пакеты от I01 до I07)
  nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
  nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
  nf->KOL := len(arr_i01[i, 2])  // количество пациентов в файле
  nf->DWORK := sys_date         // дата обработки файла
  nf->TWORK1 := hour_min(seconds()) // время начала обработки
  nf->TWORK2 := ''              // время окончания обработки
  nf->D_ANS := ctod('')         // дата протокола ответа из ТФОМС
  nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
  //
  oXmlDoc := HXMLDoc():New()
  oXmlDoc:Add( HXMLNode():New( 'ZL_LIST') )
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'ZGLV' ) )
    mo_add_xml_stroke(oXmlNode, 'VERSION', '2.0')
    mo_add_xml_stroke(oXmlNode, 'DATE_F', date2xml(nf->DATE_F))
    mo_add_xml_stroke(oXmlNode, 'NAME_F', nf->NAME_F)
    mo_add_xml_stroke(oXmlNode, 'DATE_R', date2xml(nf->DATE_R))
   oMo_d := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'MO_D' ) )
    mo_add_xml_stroke(oMo_d,'MO', glob_mo[_MO_KOD_FFOMS])
    mo_add_xml_stroke(oMo_d,'LPU', glob_mo[_MO_KOD_TFOMS])
  for j := 1 to len(arr_i01[i, 2])
    select NAPR
    goto (arr_i01[i, 2,j])
    G_RLock(forever)
    napr->KOD_F_1out := nf->KOD // код файла - по файлу mo_nfile
    napr->T_ANS_1 := 0
    napr->DATE_R := kart->date_r // дата рождения
    napr->SEX := iif(kart->pol=='М', 1, 2) // пол
    napr->ENP := iif(kart_->VPOLIS==3, kart_->NPOLIS,'') // единый номер полиса ОМС
    p2->(dbGoto(napr->VRACH_1))
    //
    select NFN
    append blank
    nfn->KOD_F := nf->KOD    // код файла - по файлу mo_nfile
    nfn->KOD_N := napr->kod  // код направления - по файлу mo_nnapr
    nfn->OSHIB := 0
    //
    arr_fio := retFamImOt(1, .f.) ; cSMOname := ''
    if alltrim(kart_->smo) == '34'
      cSMOname := ret_inogSMO_name(1)
    endif
    oDir := oMo_d:Add( HXMLNode():New( 'DIR' ) )
     mo_add_xml_stroke(oDir,'ID_D', napr->id_1)
     mo_add_xml_stroke(oDir,'NUM_D', napr->num_d)
     mo_add_xml_stroke(oDir,'DATE_D', date2xml(napr->date_d))
     mo_add_xml_stroke(oDir,'MO_H', napr->S_MCOD)
     mo_add_xml_stroke(oDir,'LPU_H', napr->S_CODEM)
     mo_add_xml_stroke(oDir,'USL_OK', lstr(iif(napr->usl_ok_1==2, 2, 1)))
     ar := _263_pr_prk(napr->PROFIL_K_1, napr->PROFIL_1,nf->DATE_R)
     mo_add_xml_stroke(oDir,'PROFIL', ar[1])
     mo_add_xml_stroke(oDir,'PROFIL_K', ar[2])
     mo_add_xml_stroke(oDir,'DS', napr->DS_1)
     mo_add_xml_stroke(oDir,'IDDOKT', p2->snils)
     mo_add_xml_stroke(oDir,'F_MEDC', lstr(napr->F_MEDC_1))
     mo_add_xml_stroke(oDir,'DATE_HOSP', date2xml(napr->DATE_H_1))
     mo_add_xml_stroke(oDir,'DISP', lstr(napr->disp_1))
     oPAC := oDir:Add( HXMLNode():New( 'PATIENT' ) )
      mo_add_xml_stroke(oPAC,'SURNAME',arr_fio[1])
      mo_add_xml_stroke(oPAC,'NAME',arr_fio[2])
      if !empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,'PATRONYMIC',arr_fio[3])
      endif
      mo_add_xml_stroke(oPAC,'BIRTHDAY',date2xml(kart->date_r))
      mo_add_xml_stroke(oPAC,'SEX',iif(kart->pol=='М','1','2'))
      if !empty(kart->snils)
        mo_add_xml_stroke(oPAC,'SS',transform(kart->SNILS,picture_pf))
      endif
      mo_add_xml_stroke(oPAC,'TYPE_P', lstr(kart_->VPOLIS))
      if !empty(kart_->SPOLIS)
        mo_add_xml_stroke(oPAC,'SER_P', kart_->SPOLIS)
      endif
      mo_add_xml_stroke(oPAC,'NUM_P', kart_->NPOLIS)
      if kart_->VPOLIS == 3
        mo_add_xml_stroke(oPAC,'ENP', kart_->NPOLIS)
      endif
      if empty(cSMOname)
        mo_add_xml_stroke(oPAC,'SMO' , kart_->smo)
      else
        mo_add_xml_stroke(oPAC,'NAME_SMO',cSMOname)
      endif
      mokato := '18000'
      if !empty(kart_->KVARTAL_D)
        mokato := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
      endif
      mo_add_xml_stroke(oPAC,'REG_OMS',mokato)
      oCon := oPAC:Add( HXMLNode():New( 'CONTACT' ) )
      if !empty(kart_->PHONE_M)
        mo_add_xml_stroke(oCon,'TEL_M',left(kart_->PHONE_M, 1) + '-'+substr(kart_->PHONE_M, 2, 3) + '-'+substr(kart_->PHONE_M, 5))
      endif
      if !empty(kart_->PHONE_H)
        mo_add_xml_stroke(oCon,'TEL_F',left(kart_->PHONE_H, 1) + '-'+substr(kart_->PHONE_H, 2, 4) + '-'+substr(kart_->PHONE_H, 6))
      elseif !empty(kart_->PHONE_W)
        mo_add_xml_stroke(oCon,'TEL_F',left(kart_->PHONE_W, 1) + '-'+substr(kart_->PHONE_W, 2, 4) + '-'+substr(kart_->PHONE_W, 6))
      endif
  next
  oXmlDoc:Save(nfile+sxml)
  name_zip := nfile+szip
  if chip_create_zipXML(name_zip, {nfile+sxml}, .t., 2)
    nf->TWORK2 := hour_min(seconds()) // время окончания обработки
    nf->TXT_F := name_txt
    aadd(arr_f, {nfile,len(arr_i01[i, 2])})
  else
    file_error := nfile
    fl_error := .t. ; exit
  endif
  dbUnLockAll()
  Commit
next
// I03
for k := 2 to 3
  if !fl_error
    arr_i03 := {}
    select NAPR
    if k == 2
      index on kod to (cur_dir + 'tmp_napr') ;
            for (KOD_F_1in > 0 .or. (T_ANS_1 == 1 .and. CODEM_1 == glob_mo[_MO_KOD_TFOMS])) ;
                                                  .and. TIP_ANNUL == 2 .and. empty(KOD_F_3out)
    else
      index on kod to (cur_dir + 'tmp_napr') ;
            for n_napr > 0 .and. KOD_F_1out > 0 .and. TIP_ANNUL == 3 .and. empty(KOD_F_3out)
    endif
    go top
    do while !eof()
      if (i := ascan(arr_i03, {|x| x[1] == napr->DATE_3 })) == 0
        aadd(arr_i03, {napr->DATE_3, {}}) ; i := len(arr_i03)
      endif
      aadd(arr_i03[i, 2], napr->kod)
      select NAPR
      skip
    enddo
    for i := 1 to len(arr_i03)
      mnn := 0
      select NF
      find ('3'+dtos(arr_i03[i, 1]) + '1')
      do while nf->tip_f==3 .and. nf->date_r==arr_i03[i, 1] .and. nf->in_out==1 .and. !eof()
        mnn := nf->nn
        skip
      enddo
      ++mnn // номер пакета
      nfile := 'I03T34M'+glob_mo[_MO_KOD_TFOMS]+'_' + ;
               right(str(year(arr_i03[i, 1]), 4), 2) + ;
               strzero(month(arr_i03[i, 1]), 2) + ;
               strzero(day(arr_i03[i, 1]), 2) + ;
               lstr(mnn)
      select NF
      AddRec(1)
      nf->KOD := recno()            // код файла
      nf->DATE_F := sys_date        // дата файла
      nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
      nf->DATE_R := arr_i03[i, 1]    // отчётная дата
      nf->NN := mnn                 // порядковый номер пакета за отчётную дату
      nf->TIP_F := 3                // от 1 до 7 (пакеты от I01 до I07)
      nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
      nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
      nf->KOL := len(arr_i03[i, 2])  // количество пациентов в файле
      nf->DWORK := sys_date         // дата обработки файла
      nf->TWORK1 := hour_min(seconds()) // время начала обработки
      nf->TWORK2 := ''              // время окончания обработки
      nf->D_ANS := ctod('')         // дата протокола ответа из ТФОМС
      nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
      //
      oXmlDoc := HXMLDoc():New()
      oXmlDoc:Add( HXMLNode():New( 'ZL_LIST') )
       oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'ZGLV' ) )
        mo_add_xml_stroke(oXmlNode, 'VERSION', '2.0')
        mo_add_xml_stroke(oXmlNode, 'DATE_F', date2xml(nf->DATE_F))
        mo_add_xml_stroke(oXmlNode, 'NAME_F', nf->NAME_F)
        mo_add_xml_stroke(oXmlNode, 'DATE_R', date2xml(nf->DATE_R))
       oMo_d := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'SOURCE' ) )
        mo_add_xml_stroke(oMo_d,'TYPE_S', lstr(k))
        mo_add_xml_stroke(oMo_d,'CODE', glob_mo[_MO_KOD_FFOMS])
      for j := 1 to len(arr_i03[i, 2])
        select NAPR
        goto (arr_i03[i, 2,j])
        G_RLock(forever)
        napr->KOD_F_3out := nf->KOD // код файла - по файлу mo_nfile
        napr->T_ANS_3 := 0
        //
        select NFN
        append blank
        nfn->KOD_F := nf->KOD    // код файла - по файлу mo_nfile
        nfn->KOD_N := napr->kod  // код направления - по файлу mo_nnapr
        nfn->OSHIB := 0
        //
        oDate_hosp := oMo_d:Add( HXMLNode():New( 'REF_HOSP' ) )
         mo_add_xml_stroke(oDate_hosp,'ID_D', napr->id_1)
         mo_add_xml_stroke(oDate_hosp,'MO_D', napr->MCOD_1 )
         mo_add_xml_stroke(oDate_hosp,'LPU_D', napr->CODEM_1)
         mo_add_xml_stroke(oDate_hosp,'DATE_REF', date2xml(napr->DATE_3))
         mo_add_xml_stroke(oDate_hosp,'REASON_REF', lstr(napr->REA_ANNUL))
      next
      oXmlDoc:Save(nfile+sxml)
      name_zip := nfile+szip
      if chip_create_zipXML(name_zip, {nfile+sxml}, .t., 2)
        nf->TWORK2 := hour_min(seconds()) // время окончания обработки
        nf->TXT_F := name_txt
        aadd(arr_f, {nfile,len(arr_i03[i, 2])})
      else
        file_error := nfile
        fl_error := .t. ; exit
      endif
      dbUnLockAll()
      Commit
    next
  endif
next
// I04
if !fl_error
  select NAPR
  index on kod to (cur_dir + 'tmp_napr') for between(TYPE_H_4, 1, 3) .and. empty(KOD_F_4out)
  go top
  do while !eof()
    if (i := ascan(arr_i04, {|x| x[1] == napr->DATE_H_4 })) == 0
      aadd(arr_i04, {napr->DATE_H_4, {}}) ; i := len(arr_i04)
    endif
    aadd(arr_i04[i, 2], napr->kod)
    select NAPR
    skip
  enddo
  for i := 1 to len(arr_i04)
    mnn := 0
    select NF
    find ('4'+dtos(arr_i04[i, 1]) + '1')
    do while nf->tip_f==4 .and. nf->date_r==arr_i04[i, 1] .and. nf->in_out==1 .and. !eof()
      mnn := nf->nn
      skip
    enddo
    ++mnn // номер пакета
    nfile := 'I04T34M'+glob_mo[_MO_KOD_TFOMS]+'_' + ;
             right(str(year(arr_i04[i, 1]), 4), 2) + ;
             strzero(month(arr_i04[i, 1]), 2) + ;
             strzero(day(arr_i04[i, 1]), 2) + ;
             lstr(mnn)
    select NF
    AddRec(1)
    nf->KOD := recno()            // код файла
    nf->DATE_F := sys_date        // дата файла
    nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
    nf->DATE_R := arr_i04[i, 1]    // отчётная дата
    nf->NN := mnn                 // порядковый номер пакета за отчётную дату
    nf->TIP_F := 4                // от 1 до 7 (пакеты от I01 до I07)
    nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
    nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
    nf->KOL := len(arr_i04[i, 2])  // количество пациентов в файле
    nf->DWORK := sys_date         // дата обработки файла
    nf->TWORK1 := hour_min(seconds()) // время начала обработки
    nf->TWORK2 := ''              // время окончания обработки
    nf->D_ANS := ctod('')         // дата протокола ответа из ТФОМС
    nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
    //
    oXmlDoc := HXMLDoc():New()
    oXmlDoc:Add( HXMLNode():New( 'ZL_LIST') )
     oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'ZGLV' ) )
      mo_add_xml_stroke(oXmlNode, 'VERSION', '2.0')
      mo_add_xml_stroke(oXmlNode, 'DATE_F', date2xml(nf->DATE_F))
      mo_add_xml_stroke(oXmlNode, 'NAME_F', nf->NAME_F)
      mo_add_xml_stroke(oXmlNode, 'DATE_R', date2xml(nf->DATE_R))
     oMo_d := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'MO_HOSP' ) )
      mo_add_xml_stroke(oMo_d,'MO', glob_mo[_MO_KOD_FFOMS])
      mo_add_xml_stroke(oMo_d,'LPU', glob_mo[_MO_KOD_TFOMS])
    for j := 1 to len(arr_i04[i, 2])
      select NAPR
      goto (arr_i04[i, 2,j])
      G_RLock(forever)
      napr->KOD_F_4out := nf->KOD // код файла - по файлу mo_nfile
      napr->T_ANS_4 := 0
      napr->DATE_R := kart->date_r // дата рождения
      napr->SEX := iif(kart->pol=='М', 1, 2) // пол
      napr->ENP := iif(kart_->VPOLIS==3, kart_->NPOLIS,'') // единый номер полиса ОМС
      //
      select NFN
      append blank
      nfn->KOD_F := nf->KOD    // код файла - по файлу mo_nfile
      nfn->KOD_N := napr->kod  // код направления - по файлу mo_nnapr
      nfn->OSHIB := 0
      //
      arr_fio := retFamImOt(1, .f.) ; cSMOname := ''
      if alltrim(kart_->smo) == '34'
        cSMOname := ret_inogSMO_name(1)
      endif
      oDir := oMo_d:Add( HXMLNode():New( 'HOSP' ) )
       mo_add_xml_stroke(oDir,'ID_H', napr->id_4)
       mo_add_xml_stroke(oDir,'USL_OK', lstr(iif(napr->usl_ok_4==2, 2, 1)))
       mo_add_xml_stroke(oDir,'TYPE_H', lstr(napr->TYPE_H_4))
       if napr->TYPE_H_4 == 1
         mo_add_xml_stroke(oDir,'ID_D', napr->id_1)
       endif
       mo_add_xml_stroke(oDir,'MO_D', ret_mo(napr->CODEM_FROM)[_MO_KOD_FFOMS])
       mo_add_xml_stroke(oDir,'LPU_D', napr->CODEM_FROM)
       mo_add_xml_stroke(oDir,'DATE_H', date2xml(napr->DATE_H_4))
       mo_add_xml_stroke(oDir,'TIME_H', charrepl(':', napr->TIME_H_4, '-'))
       mo_add_xml_stroke(oDir,'DS', napr->DS_4)
       mo_add_xml_stroke(oDir,'F_MEDC', lstr(napr->F_MEDC_4))
       ar := _263_pr_prk(napr->PROFIL_K_4, napr->PROFIL_4,nf->DATE_R)
       mo_add_xml_stroke(oDir,'PROFIL', ar[1])
       mo_add_xml_stroke(oDir,'PROFIL_K', ar[2])
       mo_add_xml_stroke(oDir,'NUM_HIST', napr->NUM_HIST_4)
       oPAC := oDir:Add( HXMLNode():New( 'PATIENT' ) )
        mo_add_xml_stroke(oPAC,'SURNAME',arr_fio[1])
        mo_add_xml_stroke(oPAC,'NAME',arr_fio[2])
        if !empty(arr_fio[3])
          mo_add_xml_stroke(oPAC,'PATRONYMIC',arr_fio[3])
        endif
        mo_add_xml_stroke(oPAC,'BIRTHDAY',date2xml(kart->date_r))
        mo_add_xml_stroke(oPAC,'SEX',iif(kart->pol=='М','1','2'))
        if !empty(kart->snils)
          mo_add_xml_stroke(oPAC,'SS',transform(kart->SNILS,picture_pf))
        endif
        mo_add_xml_stroke(oPAC,'TYPE_P', lstr(kart_->VPOLIS))
        if !empty(kart_->SPOLIS)
          mo_add_xml_stroke(oPAC,'SER_P', kart_->SPOLIS)
        endif
        mo_add_xml_stroke(oPAC,'NUM_P', kart_->NPOLIS)
        if kart_->VPOLIS == 3
          mo_add_xml_stroke(oPAC,'ENP', kart_->NPOLIS)
        endif
        if empty(cSMOname)
          mo_add_xml_stroke(oPAC,'SMO' , kart_->smo)
        else
          mo_add_xml_stroke(oPAC,'NAME_SMO',cSMOname)
        endif
        mokato := '18000'
        if !empty(kart_->KVARTAL_D)
          mokato := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
        endif
        mo_add_xml_stroke(oPAC,'REG_OMS',mokato)
    next
    oXmlDoc:Save(nfile+sxml)
    name_zip := nfile+szip
    if chip_create_zipXML(name_zip, {nfile+sxml}, .t., 2)
      nf->TWORK2 := hour_min(seconds()) // время окончания обработки
      nf->TXT_F := name_txt
      aadd(arr_f, {nfile,len(arr_i04[i, 2])})
    else
      file_error := nfile
      fl_error := .t. ; exit
    endif
    dbUnLockAll()
    Commit
  next
endif
// I05
if !fl_error
  select NAPR
  index on kod to (cur_dir + 'tmp_napr') for TYPE_H_4 == 4 .and. empty(KOD_F_4out)
  go top
  do while !eof()
    if (i := ascan(arr_i05, {|x| x[1] == napr->DATE_H_4 })) == 0
      aadd(arr_i05, {napr->DATE_H_4, {}}) ; i := len(arr_i05)
    endif
    aadd(arr_i05[i, 2], napr->kod)
    select NAPR
    skip
  enddo
  for i := 1 to len(arr_i05)
    mnn := 0
    select NF
    find ('5'+dtos(arr_i05[i, 1]) + '1')
    do while nf->tip_f==5 .and. nf->date_r==arr_i05[i, 1] .and. nf->in_out==1 .and. !eof()
      mnn := nf->nn
      skip
    enddo
    ++mnn // номер пакета
    nfile := 'I05T34M'+glob_mo[_MO_KOD_TFOMS]+'_' + ;
             right(str(year(arr_i05[i, 1]), 4), 2) + ;
             strzero(month(arr_i05[i, 1]), 2) + ;
             strzero(day(arr_i05[i, 1]), 2) + ;
             lstr(mnn)
    select NF
    AddRec(1)
    nf->KOD := recno()            // код файла
    nf->DATE_F := sys_date        // дата файла
    nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
    nf->DATE_R := arr_i05[i, 1]    // отчётная дата
    nf->NN := mnn                 // порядковый номер пакета за отчётную дату
    nf->TIP_F := 5                // от 1 до 7 (пакеты от I01 до I07)
    nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
    nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
    nf->KOL := len(arr_i05[i, 2])  // количество пациентов в файле
    nf->DWORK := sys_date         // дата обработки файла
    nf->TWORK1 := hour_min(seconds()) // время начала обработки
    nf->TWORK2 := ''              // время окончания обработки
    nf->D_ANS := ctod('')         // дата протокола ответа из ТФОМС
    nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
    //
    oXmlDoc := HXMLDoc():New()
    oXmlDoc:Add( HXMLNode():New( 'ZL_LIST') )
     oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'ZGLV' ) )
      mo_add_xml_stroke(oXmlNode, 'VERSION', '2.0')
      mo_add_xml_stroke(oXmlNode, 'DATE_F', date2xml(nf->DATE_F))
      mo_add_xml_stroke(oXmlNode, 'NAME_F', nf->NAME_F)
      mo_add_xml_stroke(oXmlNode, 'DATE_R', date2xml(nf->DATE_R))
     oMo_d := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'MO_EXTR' ) )
      mo_add_xml_stroke(oMo_d,'MO', glob_mo[_MO_KOD_FFOMS])
      mo_add_xml_stroke(oMo_d,'LPU', glob_mo[_MO_KOD_TFOMS])
    for j := 1 to len(arr_i05[i, 2])
      select NAPR
      goto (arr_i05[i, 2,j])
      G_RLock(forever)
      napr->KOD_F_4out := nf->KOD // код файла - по файлу mo_nfile
      napr->T_ANS_4 := 0
      napr->DATE_R := kart->date_r // дата рождения
      napr->SEX := iif(kart->pol=='М', 1, 2) // пол
      napr->ENP := iif(kart_->VPOLIS==3, kart_->NPOLIS,'') // единый номер полиса ОМС
      //
      select NFN
      append blank
      nfn->KOD_F := nf->KOD    // код файла - по файлу mo_nfile
      nfn->KOD_N := napr->kod  // код направления - по файлу mo_nnapr
      nfn->OSHIB := 0
      //
      arr_fio := retFamImOt(1, .f.) ; cSMOname := ''
      if alltrim(kart_->smo) == '34'
        cSMOname := ret_inogSMO_name(1)
      endif
      oDir := oMo_d:Add( HXMLNode():New( 'HOSP' ) )
       mo_add_xml_stroke(oDir,'ID_H', napr->id_4)
       mo_add_xml_stroke(oDir,'DATE_H', date2xml(napr->DATE_H_4))
       mo_add_xml_stroke(oDir,'TIME_H', charrepl(':', napr->TIME_H_4, '-'))
       mo_add_xml_stroke(oDir,'DS', napr->DS_4)
       mo_add_xml_stroke(oDir,'F_MEDC', lstr(napr->F_MEDC_4))
       ar := _263_pr_prk(napr->PROFIL_K_4, napr->PROFIL_4,nf->DATE_R)
       mo_add_xml_stroke(oDir,'PROFIL', ar[1])
       mo_add_xml_stroke(oDir,'PROFIL_K', ar[2])
       mo_add_xml_stroke(oDir,'NUM_HIST', napr->NUM_HIST_4)
       oPAC := oDir:Add( HXMLNode():New( 'PATIENT' ) )
        mo_add_xml_stroke(oPAC,'SURNAME',arr_fio[1])
        mo_add_xml_stroke(oPAC,'NAME',arr_fio[2])
        if !empty(arr_fio[3])
          mo_add_xml_stroke(oPAC,'PATRONYMIC',arr_fio[3])
        endif
        mo_add_xml_stroke(oPAC,'BIRTHDAY',date2xml(kart->date_r))
        mo_add_xml_stroke(oPAC,'SEX',iif(kart->pol=='М','1','2'))
        if !empty(kart->snils)
          mo_add_xml_stroke(oPAC,'SS',transform(kart->SNILS,picture_pf))
        endif
        if !empty(kart_->NPOLIS)
          mo_add_xml_stroke(oPAC,'TYPE_P', lstr(kart_->VPOLIS))
          if !empty(kart_->SPOLIS)
            mo_add_xml_stroke(oPAC,'SER_P', kart_->SPOLIS)
          endif
          mo_add_xml_stroke(oPAC,'NUM_P', kart_->NPOLIS)
          if empty(cSMOname)
            mo_add_xml_stroke(oPAC,'SMO' , kart_->smo)
            if kart_->VPOLIS == 3
              mo_add_xml_stroke(oPAC,'ENP', kart_->NPOLIS)
            endif
          else
            if kart_->VPOLIS == 3
              mo_add_xml_stroke(oPAC,'ENP', kart_->NPOLIS)
            endif
            mo_add_xml_stroke(oPAC,'NAME_SMO',cSMOname)
          endif
          mokato := '18000'
          if !empty(kart_->KVARTAL_D)
            mokato := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
          endif
          mo_add_xml_stroke(oPAC,'REG_OMS',mokato)
        endif
    next
    oXmlDoc:Save(nfile+sxml)
    name_zip := nfile+szip
    if chip_create_zipXML(name_zip, {nfile+sxml}, .t., 2)
      nf->TWORK2 := hour_min(seconds()) // время окончания обработки
      nf->TXT_F := name_txt
      aadd(arr_f, {nfile,len(arr_i05[i, 2])})
    else
      file_error := nfile
      fl_error := .t. ; exit
    endif
    dbUnLockAll()
    Commit
  next
endif
// I06
if !fl_error
  select NAPR
  index on kod to (cur_dir + 'tmp_napr') ;
        for KOD_F_4out > 0 .and. T_ANS_4 == 1 .and. !empty(DATE_6) .and. empty(KOD_F_6out)
  go top
  do while !eof()
    if (i := ascan(arr_i06, {|x| x[1] == napr->DATE_6 })) == 0
      aadd(arr_i06, {napr->DATE_6, {}}) ; i := len(arr_i06)
    endif
    aadd(arr_i06[i, 2], napr->kod)
    select NAPR
    skip
  enddo
  for i := 1 to len(arr_i06)
    mnn := 0
    select NF
    find ('6'+dtos(arr_i06[i, 1]) + '1')
    do while nf->tip_f==6 .and. nf->date_r==arr_i06[i, 1] .and. nf->in_out==1 .and. !eof()
      mnn := nf->nn
      skip
    enddo
    ++mnn // номер пакета
    nfile := 'I06T34M'+glob_mo[_MO_KOD_TFOMS]+'_' + ;
             right(str(year(arr_i06[i, 1]), 4), 2) + ;
             strzero(month(arr_i06[i, 1]), 2) + ;
             strzero(day(arr_i06[i, 1]), 2) + ;
             lstr(mnn)
    select NF
    AddRec(1)
    nf->KOD := recno()            // код файла
    nf->DATE_F := sys_date        // дата файла
    nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
    nf->DATE_R := arr_i06[i, 1]    // отчётная дата
    nf->NN := mnn                 // порядковый номер пакета за отчётную дату
    nf->TIP_F := 6                // от 1 до 7 (пакеты от I01 до I07)
    nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
    nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
    nf->KOL := len(arr_i06[i, 2])  // количество пациентов в файле
    nf->DWORK := sys_date         // дата обработки файла
    nf->TWORK1 := hour_min(seconds()) // время начала обработки
    nf->TWORK2 := ''              // время окончания обработки
    nf->D_ANS := ctod('')         // дата протокола ответа из ТФОМС
    nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
    //
    oXmlDoc := HXMLDoc():New()
    oXmlDoc:Add( HXMLNode():New( 'ZL_LIST') )
     oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'ZGLV' ) )
      mo_add_xml_stroke(oXmlNode, 'VERSION', '2.0')
      mo_add_xml_stroke(oXmlNode, 'DATE_F', date2xml(nf->DATE_F))
      mo_add_xml_stroke(oXmlNode, 'NAME_F', nf->NAME_F)
      mo_add_xml_stroke(oXmlNode, 'DATE_R', date2xml(nf->DATE_R))
     oMo_d := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'MO_DC' ) )
      mo_add_xml_stroke(oMo_d,'MO', glob_mo[_MO_KOD_FFOMS])
      mo_add_xml_stroke(oMo_d,'LPU', glob_mo[_MO_KOD_TFOMS])
    for j := 1 to len(arr_i06[i, 2])
      select NAPR
      goto (arr_i06[i, 2,j])
      G_RLock(forever)
      napr->KOD_F_6out := nf->KOD // код файла - по файлу mo_nfile
      napr->T_ANS_6 := 0
      //
      select NFN
      append blank
      nfn->KOD_F := nf->KOD    // код файла - по файлу mo_nfile
      nfn->KOD_N := napr->kod  // код направления - по файлу mo_nnapr
      nfn->OSHIB := 0
      //
      oDir := oMo_d:Add( HXMLNode():New( 'DISCH' ) )
       mo_add_xml_stroke(oDir,'ID_DISCH', napr->id_6)
       mo_add_xml_stroke(oDir,'DATE_H', date2xml(napr->DATE_H_4))
       mo_add_xml_stroke(oDir,'DATE_D', date2xml(napr->DATE_6))
       mo_add_xml_stroke(oDir,'F_MEDC', lstr(napr->F_MEDC_4))
       ar := _263_pr_prk(napr->PROFIL_K_4, napr->PROFIL_4,nf->DATE_R)
       mo_add_xml_stroke(oDir,'PROFIL', ar[1])
       mo_add_xml_stroke(oDir,'PROFIL_K', ar[2])
       mo_add_xml_stroke(oDir,'USL_OK', lstr(iif(napr->usl_ok_4==2, 2, 1)))
       if napr->TYPE_H_4 == 1
         mo_add_xml_stroke(oDir,'ID_D', napr->id_1)
         mo_add_xml_stroke(oDir,'MO_D', ret_mo(napr->CODEM_FROM)[_MO_KOD_FFOMS])
         mo_add_xml_stroke(oDir,'LPU_D', napr->CODEM_FROM)
       endif
       mo_add_xml_stroke(oDir,'NUM_HIST', napr->NUM_HIST_4)
       oPAC := oDir:Add( HXMLNode():New( 'PATIENT' ) )
        mo_add_xml_stroke(oPAC,'BIRTHDAY',date2xml(iif(empty(napr->DATE_R),kart->date_r, napr->DATE_R)))
        mo_add_xml_stroke(oPAC,'SEX',iif(empty(napr->SEX),iif(kart->pol=='М','1','2'), lstr(napr->SEX)))
        if !empty(napr->ENP)
          mo_add_xml_stroke(oPAC,'ENP', napr->ENP)
        elseif kart_->VPOLIS == 3
          mo_add_xml_stroke(oPAC,'ENP', kart_->NPOLIS)
        endif
    next
    oXmlDoc:Save(nfile+sxml)
    name_zip := nfile+szip
    if chip_create_zipXML(name_zip, {nfile+sxml}, .t., 2)
      nf->TWORK2 := hour_min(seconds()) // время окончания обработки
      nf->TXT_F := name_txt
      aadd(arr_f, {nfile,len(arr_i06[i, 2])})
    else
      file_error := nfile
      fl_error := .t. ; exit
    endif
    dbUnLockAll()
    Commit
  next
endif
// I07
if !fl_error .and. yes_i07
  kart_->(dbCloseArea())
  kart->(dbCloseArea())
  napr->(dbCloseArea())
  G_Use(dir_server + 'mo_n7d', ,'D7')
  nfile := 'I07T34M'+glob_mo[_MO_KOD_TFOMS]
  select NF
  index on upper(name_f) to (cur_dir + 'tmp_nf') for in_out == 1
  find (upper(nfile)) // наверное уже отправляли I07 в ТФОМС
  if found()
    G_RLock(forever) // бесконечная попытка блокировать запись
    // удалим предыдущий XML-файл
    delete file (dir_server + dir_NAPR_MO + cslash+ alltrim(nf->NAME_F) + szip)
  else
    G_RLock(.t., forever) // бесконечная попытка добавить запись
    nf->KOD := recno()            // код файла
  endif
  nfile += '_'+right(str(year(d7->DATE_R_EDI), 4), 2) + ;
           strzero(month(d7->DATE_R_EDI), 2) + ;
           strzero(day(d7->DATE_R_EDI), 2) + '1'
  nf->DATE_F := sys_date        // дата файла
  nf->NAME_F := nfile           // имя файла без расширения (и ZIP-архива)
  nf->DATE_R := d7->DATE_R_EDI  // отчётная дата
  nf->NN := 1                   // порядковый номер пакета за отчётную дату
  nf->TIP_F := 7                // от 1 до 7 (пакеты от I01 до I07)
  nf->IN_OUT := 1               // 1-в ТФОМС, 2-из ТФОМС
  nf->DATE_OUT := sys_date      // дата отправки в ТФОМС
  nf->KOL := 0                  // количество пациентов в файле
  nf->DWORK := sys_date         // дата обработки файла
  nf->TWORK1 := hour_min(seconds()) // время начала обработки
  nf->TWORK2 := ''              // время окончания обработки
  nf->D_ANS := ctod('')         // дата протокола ответа из ТФОМС
  nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
    //
  oXmlDoc := HXMLDoc():New()
  oXmlDoc:Add( HXMLNode():New( 'ZL_LIST') )
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'ZGLV' ) )
    mo_add_xml_stroke(oXmlNode, 'VERSION', '2.0')
    mo_add_xml_stroke(oXmlNode, 'DATE_F', date2xml(nf->DATE_F))
    mo_add_xml_stroke(oXmlNode, 'NAME_F', nf->NAME_F)
    mo_add_xml_stroke(oXmlNode, 'DATE_R', date2xml(nf->DATE_R))
   oMo_d := oXmlDoc:aItems[1]:Add( HXMLNode():New( 'MO_PLACE' ) )
    mo_add_xml_stroke(oMo_d,'MO', glob_mo[_MO_KOD_FFOMS])
    mo_add_xml_stroke(oMo_d,'LPU', glob_mo[_MO_KOD_TFOMS])
  //
  G_Use(dir_server + 'mo_n7out', ,'N7')
  index on padr(inieditspr(A__MENUVERT, arr_t007, n7->PROFIL_K), 60) + str(n7->PROFIL_K, 3) + ;
           padr(inieditspr(A__MENUVERT, getV002(), n7->PROFIL), 20) + str(n7->PROFIL, 3) to (cur_dir + 'tmp_n7')
  _263_put_10_days(nf->DATE_R)
  select N7
  go top
  do while !eof()
    oDir := oMo_d:Add( HXMLNode():New( 'PLACES' ) )
     mo_add_xml_stroke(oDir,'ID_PL', mo_guid(1,n7->(recno())))
     mo_add_xml_stroke(oDir,'USL_OK', lstr(iif(n7->usl_ok==2, 2, 1)))
     ar := _263_pr_prk(n7->PROFIL_K,n7->PROFIL,nf->DATE_R)
     mo_add_xml_stroke(oDir,'PROFIL', ar[1])
     mo_add_xml_stroke(oDir,'PROFIL_K', ar[2])
     mo_add_xml_stroke(oDir,'QUANTITY', lstr(n7->QUANTITY))
     mo_add_xml_stroke(oDir,'Q_P', lstr(n7->Q_P))
     mo_add_xml_stroke(oDir,'Q_AP', lstr(n7->Q_AP))
     mo_add_xml_stroke(oDir,'Q_DP', lstr(n7->Q_DP))
     mo_add_xml_stroke(oDir,'Q_HP', lstr(n7->Q_HP))
     oFP := oDir:Add( HXMLNode():New( 'FREE_PLACES' ) )
     ifp := 0
     for d := nf->DATE_R to nf->DATE_R+100
       if d == nf->DATE_R .or. is_work_day(d)
        oZAP := oFP:Add( HXMLNode():New( 'ZAP' ) )
         mo_add_xml_stroke(oZAP,'DATE_PL', date2xml(d))
         pole := iif(ifp==0, 'n7->PLACE_FREE', 'n7->PLACE' + lstr(ifp))
         mo_add_xml_stroke(oZAP,'PLACE_FREE', lstr(&pole))
         pole := 'n7->PF_M' + iif(ifp==0, '', lstr(ifp))
         mo_add_xml_stroke(oZAP,'PF_M', lstr(&pole))
         pole := 'n7->PF_W' + iif(ifp==0, '', lstr(ifp))
         mo_add_xml_stroke(oZAP,'PF_W', lstr(&pole))
         pole := 'n7->PF_C' + iif(ifp==0, '', lstr(ifp))
         mo_add_xml_stroke(oZAP,'PF_C', lstr(&pole))
         if ++ifp > 10
           exit
         endif
       endif
     next
     oSMO := oDir:Add( HXMLNode():New( 'SMO_V' ) )
      mo_add_xml_stroke(oSMO,'SMO','34001')
      mo_add_xml_stroke(oSMO,'V_H','0')
     oSMO := oDir:Add( HXMLNode():New( 'SMO_V' ) )
      mo_add_xml_stroke(oSMO,'SMO','34002')
      mo_add_xml_stroke(oSMO,'V_H','0')
     oSMO := oDir:Add( HXMLNode():New( 'SMO_V' ) )
      mo_add_xml_stroke(oSMO,'SMO','34006')
      mo_add_xml_stroke(oSMO,'V_H','0')
     oSMO := oDir:Add( HXMLNode():New( 'SMO_V' ) )
      mo_add_xml_stroke(oSMO,'SMO','34007')
      mo_add_xml_stroke(oSMO,'V_H','0')
    select N7
    skip
  enddo
  oXmlDoc:Save(nfile+sxml)
  name_zip := nfile+szip
  if chip_create_zipXML(name_zip, {nfile+sxml}, .t., 2)
    nf->TWORK2 := hour_min(seconds()) // время окончания обработки
    nf->TXT_F := name_txt
    select D7
    G_RLock(forever)
    d7->DATE_R_OUT := d7->DATE_R_EDI
    d7->DATE_OUT := sys_date
    aadd(arr_f, {nfile, 0})
    dbUnLockAll()
    Commit
  else
    file_error := nfile
    fl_error := .t.
  endif
endif
if fl_error
  dbUnLockAll()
  Commit
endif
if len(arr_f) > 0 .or. fl_error
  strfile(space(10) + 'Протокол создания информационных пакетов для ТФОМС' + ;
          hb_eol(), cFileProtokol)
  strfile(space(10) +full_date(sys_date) + 'г. '+cTimeBegin+ ;
          hb_eol(), cFileProtokol, .t.)
  if len(arr_f) > 0
    asort(arr_f, , , {|x,y| x[1] < y[1] })
    for i := 1 to len(arr_f)
      chip_copy_zipXML(dir_server + dir_NAPR_MO + cslash+arr_f[i, 1]+szip, left(dir_263_to,len(dir_263_to)-1))
      strfile(hb_eol() + ;
              'Создан файл пакета '+arr_f[i, 1]+iif(arr_f[i, 2]==0,'',' - ' + lstr(arr_f[i, 2]) + ' чел.') + ;
              hb_eol(), cFileProtokol, .t.)
    next
  endif
  if fl_error
    strfile(hb_eol() + ;
            'Произошла ошибка при создании файла пакета '+file_error + hb_eol() + ;
            'Обратитесь к разработчикам!' + ;
            hb_eol(), cFileProtokol, .t.)
  endif
  if len(arr_f) > 0
    strfile(hb_eol() + ;
            'Все файлы информационных пакетов записаны в каталог обмена' + hb_eol() + ;
            dir_263_to+' для отправки в ТФОМС' + ;
            hb_eol(), cFileProtokol, .t.)
    copy file (cFileProtokol) to (name_txt)
    // запишем файл протокола записи
    chip_copy_zipXML(name_txt,dir_server + dir_NAPR_MO, .t.)
  endif
  viewtext(Devide_Into_Pages(cFileProtokol, 60, 80), , , , .t., , , 2)
else
  func_error(4, 'Не обнаружено подготовленной информации для создания информационных пакетов')
endif
close databases
rest_box(buf)
mo_UnLock_Task(X_263)
return NIL

// 03.08.14 Просмотр протоколов записи информационных пакетов в ТФОМС
Function _263_to_protokol()
  Local i, d, s, blk, t_arr[BR_LEN], buf := save_maxrow()

  mywait()
  dbcreate(cur_dir + 'tmp', { ;
                            {'named','D', 8, 0}, ;
                            {'namet','C', 9, 0}, ;
                            {'txt_f','C', 15, 0}})
  use (cur_dir + 'tmp') new
  blk := {|x| s := Name_Without_Ext(StripPath(x)), ;
            dbAppend(), ;
            tmp->named := stod(left(s, 8)), ;
            tmp->namet := left(right(s, 6), 2) + ':' + left(right(s, 4), 2) + ':' + right(s, 2), ;
            tmp->txt_f := s }
  scandirfiles(dir_server + dir_NAPR_MO + cslash, '*' + stxt, blk )
  if lastrec() == 0
    close databases
    rest_box(buf)
    return func_error(4, 'Пока ещё не создавали информационные пакеты для отправки в ТФОМС')
  endif
  index on descend(txt_f) to (cur_dir + 'tmp')
  go top
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT] := T_COL - 5
  t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 23
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', , .t.}
  blk := nil
  t_arr[BR_COLUMN] := {{'   Дата', {|| full_date(tmp->named) }, blk }, ;
                     {' Время', {|| tmp->namet }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - выход;  ^<Enter>^ - просмотр файла протокола записи') }
  t_arr[BR_EDIT] := {|nk, ob| f2_263_to_protokol(nk, ob, 'edit') }
  edit_browse(t_arr)
  close databases
  rest_box(buf)
  return nil

// 03.08.14
Function f2_263_to_protokol(nKey, oBrow, regim)
  Local ret := -1

  do case
    case regim == 'edit'
      if nKey == K_ENTER
        viewtext(Devide_Into_Pages(dir_server + dir_NAPR_MO + cslash + tmp->txt_f + stxt, 60, 80), , , , .t., , , 2)
      else
        keyboard ''
      endif
  endcase
  return ret

// 19.02.17 Список информационных пакетов с выписанными направлениями
Function _263_to_I01()
  Static str_sem := '263_to_I01'
  Local buf := save_maxrow(), blk, t_arr[BR_LEN]

  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  Private goal_dir := dir_server + dir_NAPR_MO + cslash
  G_Use(dir_server + 'mo_nfile', , 'NF')
  index on dtos(date_r) + upper(name_f) to (cur_dir + 'tmp_nf') ;
      for in_out == 1 .and. tip_f == 1 DESCENDING
  go top
  if eof()
    close databases
    G_SUnLock(str_sem)
    return func_error(4, 'Пока не было записи пакетов I01 в ТФОМС')
  endif
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow() - 1
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_TITUL] := 'Информационные пакеты I01, отправленные в ТФОМС'
  t_arr[BR_TITUL_COLOR] := 'B/BG'
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R', .t.}
  blk := {|| iif(empty(nf->TWORK2) .or. nf->t_ans == 2, {7, 8}, iif(nf->t_ans == 0, {5, 6}, {1, 2})) }
  t_arr[BR_COLUMN] := {{' Имя файла', {|| left(nf->name_f, 22) }, blk }, ;
                     {' Отч.дата', {|| full_date(nf->date_r) }, blk }, ;
                     {' Кол.', {|| str(nf->kol, 5) }, blk }, ;
                     {'Дата и время записи', {|| padr(f1_263_to_I01(3), 38) }, blk }}
  //t_arr[BR_STEP_FUNC] := {|| f1_263_to_I01(1) }
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ выход  ^<Enter>^ просмотр  ^<F5>^ повторная запись') }
  t_arr[BR_EDIT] := {|nk, ob| f2_263_to_I01(nk, ob, 'edit') }
  //f1_263_to_I01(0)
  edit_browse(t_arr)
  //f1_263_to_I01(2)
  close databases
  G_SUnLock(str_sem)
  rest_box(buf)
  return nil

// 19.02.17
Function f1_263_to_I01(k)
  Static buf
  Local s, ta[2], k1, k2

  if k == 0
    buf := box_shadow(maxrow() - 4, 0,maxrow() - 1, 79, color1, 'Полное наименование стационара', 'B+/B')
  elseif k == 1
    perenos(ta, ret_mo(substr(nf->name_f, 12, 6))[_MO_FULL_NAME], 78)
    @ maxrow() - 3, 1 say padc(alltrim(ta[1]), 78) color color14
    @ maxrow() - 2, 1 say padc(alltrim(ta[2]), 78) color color14
  elseif k == 2
    rest_box(buf)
  elseif k == 3
    s := date_8(nf->dwork) + ' ' + nf->twork1
    if empty(nf->TWORK2)
      s += ' ЗАПИСЬ НЕ ЗАВЕРШЕНА'
    elseif nf->T_ANS == 0
      s += ' ответ не получен'
    elseif nf->T_ANS == 2
      s += ' ошибка (из ТФОМС)'
    endif
    if !hb_fileExists(goal_dir + alltrim(nf->name_f) + szip)
      s += ' нет файла'
    endif
    return s
  endif
  return nil

// 13.05.22
Function f2_263_to_I01(nKey, oBrow, regim)
  Local lkod, buf, r1, rec, i, ret := -1, arr, lcodem, n1, n2, ;
      n_file := cur_dir + 'i01' + stxt, sh := 80, HH := 60, t_arr[4], s, s1, s2, s3, s4

  if regim == 'edit'
    do case
      case nKey == K_F5
        copy_I0_file_once_more()
      case nKey == K_CTRL_F12
        if empty(nf->TWORK2)
          buf := savescreen()
          arr := {}
          aadd(arr, 'Файл ' + alltrim(nf->name_f) + ', отчётная дата ' + full_date(nf->date_r) + 'г.')
          aadd(arr, 'количество пациентов ' + lstr(nf->kol) + ' чел.')
          aadd(arr, '')
          aadd(arr, 'Аннулируется НЕЗАПИСАННЫЙ информационный пакет I01')
          aadd(arr, '')
          aadd(arr, 'После подтверждения аннулирования все последствия записи данного')
          aadd(arr, 'файла, а также сам файл, будут удалены (а направления останутся)')
          f_message(arr, , cColorSt2Msg, cColorSt1Msg)
          s := 'Подтвердите аннулирование информационного пакета I01'
          stat_msg(s)
          mybell(2)
          if f_Esc_Enter('аннулирования', .t.)
            mywait()
            G_Use(dir_server + 'mo_nnapr', , 'NAPR')
            index on kod to (cur_dir + 'tmp_napr') for KOD_F_1out == nf->kod
            arr := {}
            dbeval({|| aadd(arr, napr->(recno())) })
            set index to
            for i := 1 to len(arr)
              goto (arr[i])
              G_RLock(forever)
              napr->KOD_F_1out := 0 // код файла - по файлу mo_nfile
            next
            napr->(dbCloseArea())
            select NF
            DeleteRec()
            stat_msg('Аннулирование завершено! Можете записать файл снова')
            mybell(2)
            go top
            ret := 1
          endif
          restscreen(buf)
        else
          func_error(4, 'Данный файл был успешно записан. Аннулирование запрещено!')
        endif
      case nKey == K_ENTER
        buf := save_maxrow()
        mywait()
        fp := fcreate(n_file)
        tek_stroke := 0
        n_list := 1
        add_string('')
        add_string('Файл ' + alltrim(nf->name_f) + ', отчётная дата ' + full_date(nf->date_r) + 'г.')
        if empty(nf->TWORK2)
          add_string('ЗАПИСЬ НЕ ЗАВЕРШЕНА')
        elseif nf->T_ANS == 0
          add_string('ответ из ТФОМС не получен')
        elseif nf->T_ANS == 2
          add_string('ответ из ТФОМС получен - ОШИБКА')
        endif
        add_string('количество пациентов ' + lstr(nf->kol) + ' чел.')
        add_string('')
        add_string('Это информационный пакет со сведениями о выписанных в поликлинике направлениях')
        R_Use(dir_server + 'kartote_', , '_KART_')
        R_Use(dir_server + 'kartotek', , '_KART')
        set relation to kod into _KART_
        R_Use(dir_server + 'mo_nfina', , 'NFN')
        index on str(kod_n, 6) to (cur_dir + 'tmp_nfn') for kod_f == nf->kod
        R_Use(dir_server + 'mo_nnapr', , 'NAPR')
        set relation to kod_k into _KART
        index on upper(_kart->fio) + str(_kart->kod, 7) to (cur_dir + 'tmp_napr') for KOD_F_1out == nf->kod
        i := 0
        go top
        do while !eof()
          verify_FF(HH - 5, .t., sh)
          add_string('')
          add_string(lstr(++i) + '. Направление № ' + alltrim(napr->NUM_D) + ' от ' + date_8(napr->DATE_D))
          if napr->S_CODEM == glob_mo[_MO_KOD_TFOMS]
            add_string(space(3) + 'в стационар нашего МО')
          else
            add_string(space(3) + 'в стационар МО ' + ret_mo(napr->S_CODEM)[_MO_SHORT_NAME])
          endif
          add_string(space(3) + alltrim(_kart->fio) + ', д.р.' + full_date(_kart->date_r))
          add_string(space(3) + 'планируемая дата госпитализации ' + date_8(napr->DATE_H_1) + ' по диагнозу ' + alltrim(napr->DS_1))
          add_string(space(3) + inieditspr(A__MENUVERT, arr_t007, napr->PROFIL_K_1) + ;
                                     ' (' + inieditspr(A__MENUVERT, getV002(), napr->PROFIL_1) + ')')
          select NFN
          find (str(napr->kod, 6))
          if found() .and. nfn->OSHIB > 0
            s := space(3) + 'ОШИБКА ' + lstr(nfn->OSHIB) + ' - ' + inieditspr(A__MENUVERT, getT008(), nfn->OSHIB)
            if !empty(nfn->IM_POL)
              s += ' (в поле ' + alltrim(nfn->IM_POL) + ')'
            endif
            add_string(s)
          endif
          if napr->t_ans_1 == 2
            add_string(space(3) + 'ответ из ТФОМС получен - ОШИБКА ещё не отредактирована')
          endif
          select NAPR
          skip
        enddo
        fclose(fp)
        _kart->(dbCloseArea())
        _kart_->(dbCloseArea())
        nfn->(dbCloseArea())
        napr->(dbCloseArea())
        rest_box(buf)
        viewtext(n_file, , , , .t., , , 2)
        select NF
    endcase
  endif
  return ret

// 06.07.22 Список информационных пакетов с аннулированными направлениями
Function _263_to_I03()
  Static str_sem := '263_to_I03'
  Local buf := save_maxrow(), blk, t_arr[BR_LEN]

  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  Private goal_dir := dir_server + dir_NAPR_MO + cslash
  G_Use(dir_server + 'mo_nfile', , 'NF')
  index on dtos(date_r) + upper(name_f) to (cur_dir + 'tmp_nf') ;
      for in_out == 1 .and. tip_f == 3 DESCENDING
  go top
  if eof()
    close databases
    G_SUnLock(str_sem)
    return func_error(4, 'Пока не было записи пакетов I03 в ТФОМС')
  endif
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow() - 1
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_TITUL] := 'Информационные пакеты I03, отправленные в ТФОМС'
  t_arr[BR_TITUL_COLOR] := 'B/BG'
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R', .t.}
  blk := {|| iif(empty(nf->TWORK2) .or. nf->t_ans == 2, {7, 8}, iif(nf->t_ans == 0, {5, 6}, {1, 2})) }
  t_arr[BR_COLUMN] := {{' Имя файла', {|| left(nf->name_f, 22) }, blk }, ;
                     {' Отч.дата', {|| full_date(nf->date_r) }, blk }, ;
                     {' Кол.', {|| str(nf->kol, 5) }, blk }, ;
                     {'Дата и время записи', {|| padr(f1_263_to_I01(3), 38) }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ выход  ^<Enter>^ просмотр  ^<F5>^ повторная запись') }
  t_arr[BR_EDIT] := {|nk, ob| f2_263_to_I03(nk, ob, 'edit') }
  edit_browse(t_arr)
  close databases
  G_SUnLock(str_sem)
  rest_box(buf)
  return NIL

// 30.03.23
Function f2_263_to_I03(nKey, oBrow, regim)
  Local lkod, buf, r1, rec, i, ret := -1, arr, lcodem, n1, n2, ;
      n_file := cur_dir + 'I03' + stxt, sh := 80, HH := 60, t_arr[4], s1, s2, s3, s4

  if regim == 'edit'
    do case
      case nKey == K_F5
        copy_I0_file_once_more()
      case nKey == K_CTRL_F12
        if empty(nf->TWORK2)
          buf := savescreen()
          arr := {}
          aadd(arr, 'Файл ' + alltrim(nf->name_f) + ', отчётная дата ' + full_date(nf->date_r) + 'г.')
          aadd(arr, 'количество пациентов ' + lstr(nf->kol) + ' чел.')
          aadd(arr, '')
          aadd(arr, 'Аннулируется НЕЗАПИСАННЫЙ информационный пакет I03')
          aadd(arr, '')
          aadd(arr, 'После подтверждения аннулирования все последствия записи данного')
          aadd(arr, 'файла, а также сам файл, будут удалены (а направления останутся)')
          f_message(arr, , cColorSt2Msg, cColorSt1Msg)
          s := 'Подтвердите аннулирование информационного пакета I03'
          stat_msg(s)
          mybell(2)
          if f_Esc_Enter('аннулирования', .t.)
            mywait()
            G_Use(dir_server + 'mo_nnapr', , 'NAPR')
            index on kod to (cur_dir + 'tmp_napr') for KOD_F_3out == nf->kod
            arr := {}
            dbeval({|| aadd(arr, napr->(recno())) })
            set index to
            for i := 1 to len(arr)
              goto (arr[i])
              G_RLock(forever)
              napr->KOD_F_3out := 0 // код файла - по файлу mo_nfile
            next
            napr->(dbCloseArea())
            select NF
            DeleteRec()
            stat_msg('Аннулирование завершено! Можете записать файл снова')
            mybell(2)
            go top
            ret := 1
          endif
          restscreen(buf)
        else
          func_error(4, 'Данный файл был успешно записан. Аннулирование операции запрещено!')
        endif
      case nKey == K_ENTER
        buf := save_maxrow()
        mywait()
        fp := fcreate(n_file)
        tek_stroke := 0
        n_list := 1
        add_string('')
        add_string('Файл ' + alltrim(nf->name_f) + ', отчётная дата ' + full_date(nf->date_r) + 'г.')
        if empty(nf->TWORK2)
          add_string('ЗАПИСЬ НЕ ЗАВЕРШЕНА')
        elseif nf->T_ANS == 0
          add_string('ответ из ТФОМС не получен')
        elseif nf->T_ANS == 2
          add_string('ответ из ТФОМС получен - ОШИБКА')
        endif
        add_string('количество пациентов ' + lstr(nf->kol) + ' чел.')
        add_string('')
        add_string('Это информационный пакет с аннулированными направлениями')
        R_Use(dir_server + 'kartote_', , '_KART_')
        R_Use(dir_server + 'kartotek', , '_KART')
        set relation to kod into _KART_
        R_Use(dir_server + 'mo_nfina', , 'NFN')
        index on str(kod_n, 6) to (cur_dir + 'tmp_nfn') for kod_f == nf->kod
        R_Use(dir_server + 'mo_nnapr', , 'NAPR')
        set relation to kod_k into _KART
        index on upper(_kart->fio) + str(_kart->kod, 7) to (cur_dir + 'tmp_napr') for KOD_F_3out == nf->kod
        i := 0
        go top
        do while !eof()
          verify_FF(HH - 5, .t., sh)
          add_string('')
          add_string(lstr(++i) + '. Направление № ' + alltrim(napr->NUM_D) + ' от ' + date_8(napr->DATE_D))
          if napr->TIP_ANNUL == 3
            if napr->S_CODEM == glob_mo[_MO_KOD_TFOMS]
              add_string(space(3) + 'в стационар нашего МО')
            else
              add_string(space(3) + 'в стационар МО ' + ret_mo(napr->S_CODEM)[_MO_SHORT_NAME])
            endif
            add_string(space(3) + 'направление аннулировано в нашей ПОЛИКЛИНИКЕ')
          else
            if napr->CODEM_1 == glob_mo[_MO_KOD_TFOMS]
              add_string(space(3) + 'из поликлиники нашего МО')
            else
              add_string(space(3) + 'из поликлиники МО ' + ret_mo(napr->CODEM_1)[_MO_SHORT_NAME])
            endif
            add_string(space(3) + 'направление аннулировано в нашем СТАЦИОНАРЕ')
          endif
          add_string(space(3) + alltrim(_kart->fio) + ', д.р.' + full_date(_kart->date_r))
          add_string(space(3) + 'форма оказания медицинской помощи - ' + inieditspr(A__MENUVERT, getV014(), napr->F_MEDC_1))
          add_string(space(3) + inieditspr(A__MENUVERT, arr_t007, napr->PROFIL_K_1) + ;
                                     ' (' + inieditspr(A__MENUVERT, getV002(), napr->PROFIL_1) + ')')
          add_string(space(3) + 'причина аннулирования: ' + inieditspr(A__MENUVERT, get_reason_annul(), napr->rea_annul))
          add_string(space(3) + 'дата аннулирования ' + full_date(napr->date_3))
          select NFN
          find (str(napr->kod, 6))
          if found() .and. nfn->OSHIB > 0
            s := space(3) + 'ОШИБКА ' + lstr(nfn->OSHIB) + ' - ' + inieditspr(A__MENUVERT, getT008(), nfn->OSHIB)
            if !empty(nfn->IM_POL)
              s += ' (в поле ' + alltrim(nfn->IM_POL) + ')'
            endif
            add_string(s)
          endif
          if napr->t_ans_3 == 2
            add_string(space(3) + 'ответ из ТФОМС получен - ОШИБКА ещё не отредактирована')
          endif
          select NAPR
          skip
        enddo
        fclose(fp)
        _kart->(dbCloseArea())
        _kart_->(dbCloseArea())
        nfn->(dbCloseArea())
        napr->(dbCloseArea())
        rest_box(buf)
        viewtext(n_file, , , , .t., , , 2)
        select NF
    endcase
  endif
  return ret

// 19.02.17 Список информационных пакетов с госпитализациями по направлениям
Function _263_to_I04(k)
  Static str_sem := '263_to_I04'
  Local buf := save_maxrow(), blk, t_arr[BR_LEN]

  Private ppaket := k
  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  Private goal_dir := dir_server + dir_NAPR_MO + cslash
  G_Use(dir_server + 'mo_nfile', , 'NF')
  index on dtos(date_r) + upper(name_f) to (cur_dir + 'tmp_nf') ;
      for in_out == 1 .and. tip_f == ppaket DESCENDING
  go top
  if eof()
    close databases
    G_SUnLock(str_sem)
    return func_error(4, 'Пока не было записи пакетов I0' + lstr(ppaket) + ' в ТФОМС')
  endif
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow() - 1
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_TITUL] := 'Информационные пакеты I0' + lstr(ppaket) + ', отправленные в ТФОМС'
  t_arr[BR_TITUL_COLOR] := 'B/BG'
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R', .t.}
  blk := {|| iif(empty(nf->TWORK2) .or. nf->t_ans == 2, {7, 8}, iif(nf->t_ans == 0, {5, 6}, {1, 2})) }
  t_arr[BR_COLUMN] := {{' Имя файла', {|| left(nf->name_f, 22) }, blk }, ;
                       {' Отч.дата', {|| full_date(nf->date_r) }, blk }, ;
                       {' Кол.', {|| str(nf->kol, 5) }, blk }, ;
                       {'Дата и время записи', {|| padr(f1_263_to_I01(3), 38) }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ выход  ^<Enter>^ просмотр  ^<F5>^ повторная запись') }
  t_arr[BR_EDIT] := {|nk, ob| f2_263_to_I04(nk, ob, 'edit') }
  edit_browse(t_arr)
  close databases
  G_SUnLock(str_sem)
  rest_box(buf)
  return NIL

// 06.11.22
Function f2_263_to_I04(nKey, oBrow, regim)
  Local lkod, buf, r1, rec, i, ret := -1, arr, lcodem, n1, n2, s1, s2, s3, s4, ;
      n_file := cur_dir + 'i0' + lstr(ppaket) + stxt, sh := 80, HH := 60, t_arr[4]

  if regim == 'edit'
    do case
      case nKey == K_F5
        copy_I0_file_once_more()
      case nKey == K_CTRL_F12
        if empty(nf->TWORK2)
          buf := savescreen()
          arr := {}
          aadd(arr, 'Файл ' + alltrim(nf->name_f) + ', отчётная дата ' + full_date(nf->date_r) + 'г.')
          aadd(arr, 'количество пациентов ' + lstr(nf->kol) + ' чел.')
          aadd(arr, '')
          aadd(arr, 'Аннулируется НЕЗАПИСАННЫЙ информационный пакет I0' + lstr(ppaket))
          aadd(arr, '')
          aadd(arr, 'После подтверждения аннулирования все последствия записи данного')
          aadd(arr, 'файла, а также сам файл, будут удалены (а госпитализации останутся)')
          f_message(arr, , cColorSt2Msg, cColorSt1Msg)
          s := 'Подтвердите аннулирование информационного пакета I0' + lstr(ppaket)
          stat_msg(s)
          mybell(2)
          if f_Esc_Enter('аннулирования', .t.)
            mywait()
            G_Use(dir_server + 'mo_nnapr', , 'NAPR')
            index on kod to (cur_dir + 'tmp_napr') for KOD_F_4out == nf->kod
            arr := {}
            dbeval({|| aadd(arr, napr->(recno())) })
            set index to
            for i := 1 to len(arr)
              goto (arr[i])
              G_RLock(forever)
              napr->KOD_F_4out := 0 // код файла - по файлу mo_nfile
            next
            napr->(dbCloseArea())
            select NF
            DeleteRec()
            stat_msg('Аннулирование завершено! Можете записать файл снова')
            mybell(2)
            go top
            ret := 1
          endif
          restscreen(buf)
        else
          func_error(4, 'Данный файл был успешно записан. Аннулирование запрещено!')
        endif
      case nKey == K_ENTER
        buf := save_maxrow()
        mywait()
        fp := fcreate(n_file)
        tek_stroke := 0
        n_list := 1
        add_string('')
        add_string('Файл ' + alltrim(nf->name_f) + ', отчётная дата ' + full_date(nf->date_r) + 'г.')
        if empty(nf->TWORK2)
          add_string('ЗАПИСЬ НЕ ЗАВЕРШЕНА')
        elseif nf->T_ANS == 0
          add_string('ответ из ТФОМС не получен')
        elseif nf->T_ANS == 2
          add_string('ответ из ТФОМС получен - ОШИБКА')
        endif
        add_string('количество пациентов ' + lstr(nf->kol) + ' чел.')
        add_string('')
        if ppaket == 4
          add_string('Это информационный пакет с госпитализациями по направлениям')
        else
          add_string('Это информационный пакет с госпитализациями без направлений (экстренно/неотложно)')
        endif
        R_Use(dir_server + 'kartote_', , '_KART_')
        R_Use(dir_server + 'kartotek', , '_KART')
        set relation to kod into _KART_
        R_Use(dir_server + 'mo_nfina', , 'NFN')
        index on str(kod_n, 6) to (cur_dir + 'tmp_nfn') for kod_f == nf->kod
        R_Use(dir_server + 'mo_nnapr', , 'NAPR')
        set relation to kod_k into _KART
        index on upper(_kart->fio) + str(_kart->kod, 7) to (cur_dir + 'tmp_napr') for KOD_F_4out == nf->kod
        i := 0
        go top
        do while !eof()
          verify_FF(HH - 5, .t., sh)
          add_string('')
          add_string(lstr(++i) + '. ' + alltrim(_kart->fio) + ', д.р.' + full_date(_kart->date_r))
          do case
            case napr->TYPE_H_4 == 1
              s := 'Направлен из '
              if napr->CODEM_1 == glob_mo[_MO_KOD_TFOMS]
                s += 'поликлиники нашего МО'
              else
                s += ret_mo(napr->CODEM_1)[_MO_SHORT_NAME]
              endif
              add_string(space(3) + s)
              add_string(space(3) + 'направление: № ' + alltrim(napr->NUM_D) + ' от ' + full_date(napr->DATE_D))
            case napr->TYPE_H_4 == 2
              add_string(space(3) + 'Переведён из ' + ret_mo(napr->CODEM_FROM)[_MO_SHORT_NAME])
            case napr->TYPE_H_4 == 3
              add_string(space(3) + 'Переведён внутри МО из стационарного отделения в стационарное отделение')
          endcase
          add_string(space(3) + 'Дата фактической госпитализации ' + full_date(napr->DATE_H_4) + ;
                            ', время ' + napr->TIME_H_4)
          add_string(space(3) + 'Диагноз приёмного отделения ' + alltrim(napr->DS_4))
          add_string(space(3) + inieditspr(A__MENUVERT, arr_t007, napr->PROFIL_K_4) + ;
                                     ' (' + inieditspr(A__MENUVERT, getV002(), napr->PROFIL_4) + ')')
          add_string(space(3) + 'Форма оказания медицинской помощи - ' + inieditspr(A__MENUVERT, getV014(), napr->F_MEDC_4))
          add_string(space(3) + 'Номер истории болезни - ' + alltrim(napr->NUM_HIST_4))
          select NFN
          find (str(napr->kod, 6))
          if found() .and. nfn->OSHIB > 0
            s := space(3) + 'ОШИБКА ' + lstr(nfn->OSHIB) + ' - ' + inieditspr(A__MENUVERT, getT008(), nfn->OSHIB)
            if !empty(nfn->IM_POL)
              s += ' (в поле ' + alltrim(nfn->IM_POL) + ')'
            endif
            add_string(s)
          endif
          if napr->t_ans_4 == 2
            add_string(space(3) + 'ответ из ТФОМС получен - ОШИБКА ещё не отредактирована')
          endif
          select NAPR
          skip
        enddo
        fclose(fp)
        _kart->(dbCloseArea())
        _kart_->(dbCloseArea())
        nfn->(dbCloseArea())
        napr->(dbCloseArea())
        rest_box(buf)
        viewtext(n_file, , , , .t., , , 2)
        select NF
    endcase
  endif
  return ret

// 19.02.17 Список информационных пакетов со сведениями о выбывших пациентах
Function _263_to_I06()
  Static str_sem := '263_to_I06'
  Local buf := save_maxrow(), blk, t_arr[BR_LEN]

  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  Private goal_dir := dir_server + dir_NAPR_MO + cslash, ;
        mm_tip_vyb := {{'выписан', 1}, {'умер', 2}, {'перевод в другое отделение', 3}}

  G_Use(dir_server + 'mo_nfile', , 'NF')
  index on dtos(date_r) + upper(name_f) to (cur_dir + 'tmp_nf') ;
      for in_out == 1 .and. tip_f == 6 DESCENDING
  go top
  if eof()
    close databases
    G_SUnLock(str_sem)
    return func_error(4, 'Пока не было записи пакетов I06 в ТФОМС')
  endif
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow() - 1
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_TITUL] := 'Информационные пакеты I06, отправленные в ТФОМС'
  t_arr[BR_TITUL_COLOR] := 'B/BG'
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, RB/BG, W+/RB, R/BG, W+/R', .t.}
  blk := {|| iif(empty(nf->TWORK2) .or. nf->t_ans == 2, {7, 8}, iif(nf->t_ans == 0, {5, 6}, {1, 2})) }
  t_arr[BR_COLUMN] := {{' Имя файла', {|| left(nf->name_f, 22) }, blk }, ;
                       {' Отч.дата', {|| full_date(nf->date_r) }, blk }, ;
                       {' Кол.', {|| str(nf->kol, 5) }, blk }, ;
                       {'Дата и время записи', {|| padr(f1_263_to_I01(3), 38) }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ выход  ^<Enter>^ просмотр  ^<F5>^ повторная запись') }
  t_arr[BR_EDIT] := {|nk, ob| f2_263_to_I06(nk, ob, 'edit') }
  edit_browse(t_arr)
  close databases
  G_SUnLock(str_sem)
  rest_box(buf)
  return NIL

// 06.11.22
Function f2_263_to_I06(nKey, oBrow, regim)
  Local lkod, buf, r1, rec, i, ret := -1, arr, lcodem, n1, n2, s1, s2, s3, s4, ;
      n_file := cur_dir + 'i06' + stxt, sh := 80, HH := 60, t_arr[4]

  if regim == 'edit'
    do case
      case nKey == K_F5
        copy_I0_file_once_more()
      case nKey == K_CTRL_F12
        if empty(nf->TWORK2)
          buf := savescreen()
          arr := {}
          aadd(arr, 'Файл ' + alltrim(nf->name_f) + ', отчётная дата ' + full_date(nf->date_r) + 'г.')
          aadd(arr, 'количество пациентов ' + lstr(nf->kol) + ' чел.')
          aadd(arr, '')
          aadd(arr, 'Аннулируется НЕЗАПИСАННЫЙ информационный пакет I06')
          aadd(arr, '')
          aadd(arr, 'После подтверждения аннулирования все последствия записи данного')
          aadd(arr, 'файла, а также сам файл, будут удалены (а выбытия останутся)')
          f_message(arr, ,cColorSt2Msg, cColorSt1Msg)
          s := 'Подтвердите аннулирование информационного пакета I06'
          stat_msg(s)
          mybell(2)
          if f_Esc_Enter('аннулирования', .t.)
            mywait()
            G_Use(dir_server + 'mo_nnapr', , 'NAPR')
            index on kod to (cur_dir + 'tmp_napr') for KOD_F_6out == nf->kod
            arr := {}
            dbeval({|| aadd(arr, napr->(recno())) })
            set index to
            for i := 1 to len(arr)
              goto (arr[i])
              G_RLock(forever)
              napr->KOD_F_6out := 0 // код файла - по файлу mo_nfile
            next
            napr->(dbCloseArea())
            select NF
            DeleteRec()
            stat_msg('Аннулирование завершено! Можете записать файл снова')
            mybell(2)
            go top
            ret := 1
          endif
          restscreen(buf)
        else
          func_error(4, 'Данный файл был успешно записан. Аннулирование запрещено!')
        endif
      case nKey == K_ENTER
        buf := save_maxrow()
        mywait()
        fp := fcreate(n_file)
        tek_stroke := 0
        n_list := 1
        add_string('')
        add_string('Файл ' + alltrim(nf->name_f) + ', отчётная дата ' + full_date(nf->date_r) + 'г.')
        if empty(nf->TWORK2)
          add_string('ЗАПИСЬ НЕ ЗАВЕРШЕНА')
        elseif nf->T_ANS == 0
          add_string('ответ из ТФОМС не получен')
        elseif nf->T_ANS == 2
          add_string('ответ из ТФОМС получен - ОШИБКА')
        endif
        add_string('количество пациентов ' + lstr(nf->kol) + ' чел.')
        add_string('')
        add_string('Это информационный пакет с выписанными пациентами')
        R_Use(dir_server + 'kartote_', , '_KART_')
        R_Use(dir_server + 'kartotek', , '_KART')
        set relation to kod into _KART_
        R_Use(dir_server + 'mo_nfina', , 'NFN')
        index on str(kod_n, 6) to (cur_dir + 'tmp_nfn') for kod_f == nf->kod
        R_Use(dir_server + 'mo_nnapr', , 'NAPR')
        set relation to kod_k into _KART
        index on upper(_kart->fio) + str(_kart->kod, 7) to (cur_dir + 'tmp_napr') for KOD_F_6out == nf->kod
        i := 0
        go top
        do while !eof()
          verify_FF(HH - 5, .t., sh)
          add_string('')
          add_string(lstr(++i) + '. ' + alltrim(_kart->fio) + ', д.р.' + full_date(_kart->date_r))
          do case
            case napr->TYPE_H_4 == 1
              s := 'Направлен из '
              if napr->CODEM_1 == glob_mo[_MO_KOD_TFOMS]
                s += 'поликлиники нашего МО'
              else
                s += ret_mo(napr->CODEM_1)[_MO_SHORT_NAME]
              endif
              add_string(space(3) + s)
              add_string(space(3) + 'направление: № ' + alltrim(napr->NUM_D) + ' от ' + full_date(napr->DATE_D))
            case napr->TYPE_H_4 == 2
              add_string(space(3) + 'Переведён из ' + ret_mo(napr->CODEM_FROM)[_MO_SHORT_NAME])
            case napr->TYPE_H_4 == 3
              add_string(space(3) + 'Переведён внутри МО из стационарного отделения в стационарное отделение')
          endcase
          add_string(space(3) + 'Дата фактической госпитализации ' + full_date(napr->DATE_H_4) + ;
                            ', время ' + napr->TIME_H_4)
          add_string(space(3) + 'Диагноз приёмного отделения ' + alltrim(napr->DS_4))
          add_string(space(3) + inieditspr(A__MENUVERT, arr_t007, napr->PROFIL_K_4) + ;
                                     ' (' + inieditspr(A__MENUVERT, getV002(), napr->PROFIL_4) + ')')
          add_string(space(3) + 'Форма оказания медицинской помощи - ' + inieditspr(A__MENUVERT, getV014(), napr->F_MEDC_4))
          add_string(space(3) + 'Номер истории болезни - ' + alltrim(napr->NUM_HIST_4))
          add_string(space(3) + 'Тип выбытия - ' + inieditspr(A__MENUVERT,mm_tip_vyb, napr->type_6))
          add_string(space(3) + 'Дата выбытия - ' + full_date(napr->date_6))
          select NFN
          find (str(napr->kod, 6))
          if found() .and. nfn->OSHIB > 0
            s := space(3) + 'ОШИБКА ' + lstr(nfn->OSHIB) + ' - ' + inieditspr(A__MENUVERT, getT008(), nfn->OSHIB)
            if !empty(nfn->IM_POL)
              s += ' (в поле ' + alltrim(nfn->IM_POL) + ')'
            endif
            add_string(s)
          endif
          if napr->t_ans_6 == 2
            add_string(space(3) + 'ответ из ТФОМС получен - ОШИБКА ещё не отредактирована')
          endif
          select NAPR
          skip
        enddo
        fclose(fp)
        _kart->(dbCloseArea())
        _kart_->(dbCloseArea())
        nfn->(dbCloseArea())
        napr->(dbCloseArea())
        rest_box(buf)
        viewtext(n_file, , , , .t., , , 2)
        select NF
    endcase
  endif
  return ret

// 24.09.14 записать файл любого пакета в каталог обмена
Function copy_I0_file_once_more()
  Local buf, t_arr, zip_file := alltrim(nf->name_f) + szip

  if empty(dir_263_to)
    func_error(4, 'Не настроен каталог обмена в режиме "Настройка каталогов"')
  elseif hb_fileExists(goal_dir + zip_file)
    buf := savescreen()
    t_arr := {'Файл ' + zip_file + ' ещё раз', ;
            'записывается в каталог ' + dir_263_to, ;
            'для отправки в ТФОМС'}
    f_message(t_arr, ,color1,color8)
    if f_Esc_Enter('записи файла', .t.)
      copy file (goal_dir + zip_file) to (dir_263_to + zip_file)
      if hb_fileExists(dir_263_to + zip_file)
        stat_msg('Файл ' + zip_file + ' записан в каталог ' + dir_263_to)
        mybell(4, OK)
      else
        func_error(4, 'Произошла ошибка записи файла ' + zip_file)
      endif
    endif
    restscreen(buf)
  else
    func_error(4, 'Не обнаружен файл ' + goal_dir + zip_file)
  endif
  return NIL


// 29.12.21 Настройка каталогов обмена - куда записывать созданные для ТФОМС файлы
Function _263_to_nastr() 
  Static group_ini := 'OBMEN_263'
  Local ar, sr, mm_tmp := {}

  if ! hb_user_curUser:IsAdmin()
    return func_error(4, err_admin)
  endif

  delete file tmp.dbf
  //
  aadd(mm_tmp, {'work_otd', 'N', 1, 0,NIL, ;
              {|x|menu_reader(x, mm_danet, A__MENUVERT)}, ;
              0, {|x|inieditspr(A__MENUVERT, mm_danet, x)}, ;
              'Работаем с отделениями в данной подзадаче?', , ;
              {|| hb_user_curUser:IsAdmin() }})
  aadd(mm_tmp, {'e_1', 'C', 1, 0, NIL, , '', , ;
              ' ', , ;
              {|| .f. }})
  aadd(mm_tmp, {'e_2', 'C', 1, 0, NIL, , '', , ;
              'Каталоги для обмена информационными пакетами:', , ;
              {|| .f. }})
  aadd(mm_tmp, {'path1','C', 100, 0, NIL, ;
              {|x| menu_reader(x, {{|k, r, c| mng_dir(k, r, c, 'path1_263') }}, A__FUNCTION)}, ;
              ' ', {|x| x }, ;
              '==> для записи пакетов в ТФОМС', , ;
              {|| hb_user_curUser:IsAdmin() }})
  aadd(mm_tmp, {'path2', 'C', 100, 0, NIL, ;
              {|x| menu_reader(x, {{|k, r, c| mng_dir(k, r, c, 'path2_263') }}, A__FUNCTION)}, ;
              ' ', {|x| x }, ;
              '==> для чтения пакетов из ТФОМС', , ;
              {|| hb_user_curUser:IsAdmin() }})
  aadd(mm_tmp, {'path3', 'C', 100, 0, NIL, ;
              {|x| menu_reader(x, {{|k, r, c| mng_dir(k, r, c, 'path3_263') }}, A__FUNCTION)}, ;
              ' ', {|x| x }, ;
              '==> для перезаписи прочитанных пакетов', , ;
              {|| hb_user_curUser:IsAdmin() }})
  init_base(cur_dir + 'tmp', , mm_tmp, 0)
  use (cur_dir + 'tmp') new
  append blank
  ar := GetIniSect(tmp_ini, group_ini)
  tmp->path1 := a2default(ar, 'dir_to', '')
  tmp->path2 := a2default(ar, 'dir_from', '')
  tmp->path3 := a2default(ar, 'dir_copy', '')
  ar := GetIniSect(tools_ini, group_ini)
  tmp->work_otd := int(val(a2default(ar, 'work_otd', lstr(work_otd_263))))
  close databases
  if f_edit_spr(A__EDIT, mm_tmp, 'настройке каталогов обмена', 'g_use(cur_dir + "tmp", , , .t., .t.)', 0, 1) > 0
    use (cur_dir + 'tmp') new
    if upper(tmp->path1) == upper(tmp->path2) .or. ;
      upper(tmp->path2) == upper(tmp->path3) .or. ;
      upper(tmp->path1) == upper(tmp->path3)
      func_error(4, 'Два раза выбран один и тот же каталог - это недопустимо!')
    else
      mm_tmp := { ;
               {group_ini, 'dir_to',  tmp->path1}, ;
               {group_ini, 'dir_from',tmp->path2}, ;
               {group_ini, 'dir_copy',tmp->path3} ;
              }
      SetIniVar(tmp_ini, mm_tmp)
      work_otd_263 := tmp->work_otd
      dir_263_to   := alltrim(tmp->path1)
      dir_263_from := alltrim(tmp->path2)
      dir_263_copy := alltrim(tmp->path3)
      SetIniVar(tools_ini, {{group_ini, 'work_otd', tmp->work_otd}})
    endif
  endif
  close databases
  return NIL

// 30.03.23 Получение из ТФОМС файлов обмена (информационных пакетов)
Function _263_from_read()
  Static nerrf := 999
  Local i, j, k, n, s, af := {}, arr_f := {}, aerr := {}, blk := {|x| aadd(af,x) }, ii, ;
      name_zip, cName, is_err, buf := save_maxrow(), name_txt, fl, is_read := .f., nerr

  if empty(dir_263_from)
    return func_error(4, 'Не настроен каталог обмена в режиме "Настройка каталогов"')
  endif
  if !myFileDeleted(cur_dir + 'tmp1file' + sdbf)
    return NIL
  endif
  if !myFileDeleted(cur_dir + 'tmp2file' + sdbf)
    return NIL
  endif
  scandirfiles(dir_263_from, '*' + szip, blk )
  if empty(af)
    return func_error(4, 'Не обнаружено необходимых файлов обмена в каталоге ' + dir_263_from)
  endif
  if !mo_Lock_Task(X_263)
    return NIL
  endif
  mywait()
  for i := 1 to len(af)
    s := StripPath(af[i])  // имя файла без пути
    if left(s, 3) == 'RI0'
      aadd(arr_f, af[i])
    endif
  next
  for i := 1 to len(af)
    s := StripPath(af[i])  // имя файла без пути
    if left(s, 2) == 'I0'
      aadd(arr_f, af[i])
    endif
  next
  Private cFileProtokol := cur_dir + 'tmp' + stxt, cTimeBegin := hour_min(seconds())
  strfile(space(10) + 'Протокол чтения информационных пакетов из ТФОМС' + hb_eol(), cFileProtokol)
  strfile(space(10) + full_date(sys_date) + 'г. ' + cTimeBegin + hb_eol(), cFileProtokol, .t.)
  name_txt := dtos(sys_date) + '_' + charrem(':', padr(sectotime(seconds()), 8)) + stxt
  //
  G_Use(dir_server + 'mo_kfio', , 'KFIO')
  index on str(kod, 7) to (cur_dir + 'tmp_kfio')
  G_Use(dir_server + 'mo_kismo', , 'KSN')
  index on str(kod, 7) to (cur_dir + 'tmpkismo')
  Use_base('kartotek')
  G_Use(dir_server + 'mo_n7in', , 'N7')
  index on str(kod_f, 6) to (cur_dir + 'tmp7in')
  G_Use(dir_server + 'mo_nfina', , 'NFN')
  G_Use(dir_server + 'mo_nnapr', , 'NAPR')
  index on upper(id_1) to (cur_dir + 'tmp_napr')
  G_Use(dir_server + 'mo_nfile', , 'NF')
  for ii := 1 to len(arr_f)
    name_zip := StripPath(arr_f[ii])  // имя файла без пути
    cName := Name_Without_Ext(name_zip)
    if (af := Extract_Zip_XML(KeepPath(arr_f[ii]), name_zip)) == NIL
      aadd(aerr, 'Возникла ошибка при разархивировании ' + name_zip)
    else
      if len(af) > 1
        aadd(aerr, 'В архиве ' + name_zip + ' более одного файла')
      elseif (n := ascan(af, {|x| upper(Name_Without_Ext(x)) == upper(cName)})) > 0
        // нормально
      else
        aadd(aerr, 'В архиве ' + name_zip + ' нет файла ' + cName + sxml)
      endif
    endif
    if empty(aerr)
      strfile(hb_eol() + 'Чтение файла ' + cName + hb_eol(), cFileProtokol, .t.)
      stat_msg('Обрабатывается файл ' + cName)
      if left(cName, 1) == 'R' // протокол ответа на наш пакет
        type_paket := int(val(substr(cName, 4, 1)))
        select NF
        index on upper(name_f) to (cur_dir + 'tmp_nf') for in_out == 1
        find (padr(substr(upper(cName), 2), 26)) // поиск нашего первичного пакета
        if found()
          strfile(space(5) + 'обрабатывается ПРОТОКОЛ обработки информационного пакета' + hb_eol() + ;
                space(5) + alltrim(nf->NAME_F) + ' от ' + date_8(nf->DATE_F) + 'г. (отчётная дата ' + date_8(nf->DATE_R) + 'г.)' + ;
                hb_eol(), cFileProtokol, .t.)
          if emptyany(nf->d_ans,nf->t_ans) // если ответа ещё не было
            is_read := .t.
            select NF
            G_RLock(forever)
            nf->DWORK := sys_date         // дата обработки файла
            nf->TWORK1 := hour_min(seconds()) // время начала обработки
            // читаем протокол
            is_err := _263_protokol_tmpfile(af[1], aerr)
            //
            if tmp1->OSHIB == 0 // файл уже был загружен в ТФОМС
              // ???????????????nf->T_ANS := 2  // тип ответа (2-ошибка)
              aadd(aerr, 'Файл ' + alltrim(nf->NAME_F) + sxml + ' уже был загружен в ТФОМС (а у нас нет информации об этом)?')
            elseif is_err // ошибки
              if tmp1->kol2 == 0
                select TMP2
                go top
                strfile(space(5) + 'обнаружена ошибка в файле:' + hb_eol() + ;
                      space(5) + '- ' + lstr(tmp2->OSHIB) + ' - ' + inieditspr(A__MENUVERT, getT008(), tmp2->OSHIB) + ;
                      hb_eol(), cFileProtokol, .t.)
              else
                strfile(space(5) + 'обнаружены ошибки:' + hb_eol(), cFileProtokol, .t.)
              endif
              do case
                case nf->TIP_F == 1
                  select NFN
                  index on str(kod_n, 6) to (cur_dir + 'tmp_nfn') for KOD_F == nf->KOD
                  select NAPR
                  index on str(kod, 6) to (cur_dir + 'tmp_naprkod') for KOD_F_1out == nf->KOD
                  go top
                  do while !eof()
                    nerr := iif(tmp1->kol2 == 0, 2, 1)
                    if tmp1->kol2 > 0
                      select TMP2
                      find (upper(napr->ID_1))
                      if found()
                        select KART
                        goto (napr->KOD_K)
                        strfile(space(5) + '- ' + alltrim(kart->fio) + ' д.р.' + full_date(kart->DATE_R) + hb_eol() + ;
                              space(7) + lstr(tmp2->OSHIB) + ' - ' + inieditspr(A__MENUVERT, getT008(), tmp2->OSHIB) + hb_eol() + ;
                              space(7) + 'ошибка в поле ' + tmp2->IM_POL + hb_eol() + ;
                              hb_eol(), cFileProtokol, .t.)
                        nerr := 2
                        select NFN
                        find (str(napr->kod, 6))
                        if found()
                          G_RLock(forever)
                          nfn->OSHIB := tmp2->OSHIB
                          nfn->IM_POL := tmp2->IM_POL
                          dbUnLock()
                        endif
                      else
                        select KART
                        goto (napr->KOD_K)
                        strfile(space(5) + '- ' + alltrim(kart->fio) + ' д.р.' + full_date(kart->DATE_R) + hb_eol() + ;
                                space(7) + lstr(nerrf) + ' - ' + inieditspr(A__MENUVERT, getT008(), nerrf)  + hb_eol() + ;
                                hb_eol(), cFileProtokol, .t.)
                        nerr := 2
                        select NFN
                        find (str(napr->kod, 6))
                        if found()
                          G_RLock(forever)
                          nfn->OSHIB := nerrf
                          dbUnLock()
                        endif
                      endif
                    endif
                    select NAPR
                    G_RLock(forever)
                    napr->T_ANS_1 := nerr
                    dbUnLock()
                    skip
                  enddo
                case nf->TIP_F == 3
                  select NFN
                  index on str(kod_n, 6) to (cur_dir + 'tmp_nfn') for KOD_F == nf->KOD
                  select NAPR
                  index on str(kod, 6) to (cur_dir + 'tmp_naprkod') for KOD_F_3out == nf->KOD
                  go top
                  do while !eof()
                    nerr := iif(tmp1->kol2 == 0, 2, 1)
                    if tmp1->kol2 > 0
                      select TMP2
                      find (upper(napr->ID_1))
                      if found()
                        select KART
                        goto (napr->KOD_K)
                        strfile(space(5) + '- ' + alltrim(kart->fio) + ' д.р.' + full_date(kart->DATE_R) + hb_eol() + ;
                                space(7) + lstr(tmp2->OSHIB) + ' - ' + inieditspr(A__MENUVERT, getT008(), tmp2->OSHIB) + hb_eol() + ;
                                space(7) + 'ошибка в поле ' + tmp2->IM_POL + hb_eol() + ;
                                hb_eol(), cFileProtokol, .t.)
                        nerr := 2
                        select NFN
                        find (str(napr->kod, 6))
                        if found()
                          G_RLock(forever)
                          nfn->OSHIB := tmp2->OSHIB
                          nfn->IM_POL := tmp2->IM_POL
                          dbUnLock()
                        endif
                      else
                        select KART
                        goto (napr->KOD_K)
                        strfile(space(5) + '- ' + alltrim(kart->fio) + ' д.р.' + full_date(kart->DATE_R) + hb_eol() + ;
                                space(7) + lstr (nerrf) + ' - ' + inieditspr(A__MENUVERT, getT008(), nerrf) + hb_eol() + ;
                                hb_eol(), cFileProtokol, .t.)
                        nerr := 2
                        select NFN
                        find (str(napr->kod, 6))
                        if found()
                          G_RLock(forever)
                          nfn->OSHIB := nerrf
                          dbUnLock()
                        endif
                      endif
                    endif
                    select NAPR
                    G_RLock(forever)
                    napr->T_ANS_3 := nerr
                    dbUnLock()
                    skip
                  enddo
                case nf->TIP_F == 4 .or. nf->TIP_F == 5
                  select NFN
                  index on str(kod_n, 6) to (cur_dir + 'tmp_nfn') for KOD_F == nf->KOD
                  select NAPR
                  index on str(kod, 6) to (cur_dir + 'tmp_naprkod') for KOD_F_4out == nf->KOD
                  go top
                  do while !eof()
                    nerr := iif(tmp1->kol2 == 0, 2, 1)
                    if tmp1->kol2 > 0
                      select TMP2
                      find (upper(napr->ID_4))
                      if found()
                        select KART
                        goto (napr->KOD_K)
                        strfile(space(5) + '- ' + alltrim(kart->fio) + ' д.р.' + full_date(kart->DATE_R) + hb_eol() + ;
                                space(7) + lstr(tmp2->OSHIB) + ' - ' + inieditspr(A__MENUVERT, getT008(), tmp2->OSHIB) + hb_eol() + ;
                                space(7) + 'ошибка в поле ' + tmp2->IM_POL + hb_eol() + ;
                                hb_eol(), cFileProtokol, .t.)
                        nerr := 2
                        select NFN
                        find (str(napr->kod, 6))
                        if found()
                          G_RLock(forever)
                          nfn->OSHIB := tmp2->OSHIB
                          nfn->IM_POL := tmp2->IM_POL
                          dbUnLock()
                        endif
                      else
                        select KART
                        goto (napr->KOD_K)
                        strfile(space(5) + '- ' + alltrim(kart->fio) + ' д.р.' + full_date (kart->DATE_R) + hb_eol() + ;
                                space(7) + lstr(nerrf) + ' - ' + inieditspr(A__MENUVERT, getT008(), nerrf) + hb_eol() + ;
                                hb_eol(), cFileProtokol, .t.)
                        nerr := 2
                        select NFN
                        find (str(napr->kod, 6))
                        if found()
                          G_RLock(forever)
                          nfn->OSHIB := nerrf
                          dbUnLock()
                        endif
                      endif
                    endif
                    select NAPR
                    G_RLock(forever)
                    napr->T_ANS_4 := nerr
                    dbUnLock()
                    skip
                  enddo
                case nf->TIP_F == 6
                  select NFN
                  index on str(kod_n, 6) to (cur_dir + 'tmp_nfn') for KOD_F == nf->KOD
                  select NAPR
                  index on str(kod, 6) to (cur_dir + 'tmp_naprkod') for KOD_F_6out == nf->KOD
                  go top
                  do while !eof()
                    nerr := iif(tmp1->kol2 == 0, 2, 1)
                    if tmp1->kol2 > 0
                      select TMP2
                      find (upper(napr->ID_6))
                      if found()
                        select KART
                        goto (napr->KOD_K)
                        strfile(space(5) + '- ' + alltrim(kart->fio) + ' д.р.' + full_date(kart->DATE_R) + hb_eol() + ;
                                space(7) + lstr(tmp2->OSHIB) + ' - ' + inieditspr(A__MENUVERT, getT008(), tmp2->OSHIB) + hb_eol() + ;
                                space(7) + 'ошибка в поле ' + tmp2->IM_POL + hb_eol() + ;
                                hb_eol(), cFileProtokol, .t.)
                        nerr := 2
                        select NFN
                        find (str(napr->kod, 6))
                        if found()
                          G_RLock(forever)
                          nfn->OSHIB := tmp2->OSHIB
                          nfn->IM_POL := tmp2->IM_POL
                          dbUnLock()
                        endif
                      else
                        select KART
                        goto (napr->KOD_K)
                        strfile(space(5) + '- ' + alltrim(kart->fio) + ' д.р.' + full_date(kart->DATE_R) + hb_eol() + ;
                                space(7) + lstr(nerrf) + ' - ' + inieditspr(A__MENUVERT, getT008(), nerrf) + hb_eol() + ;
                                hb_eol(), cFileProtokol, .t.)
                        nerr := 2
                        select NFN
                        find (str(napr->kod, 6))
                        if found()
                          G_RLock(forever)
                          nfn->OSHIB := nerrf
                          dbUnLock()
                        endif
                      endif
                    endif
                    select NAPR
                    G_RLock(forever)
                    napr->T_ANS_6 := nerr
                    dbUnLock()
                    skip
                  enddo
                case nf->TIP_F == 7
              endcase
              nf->T_ANS := 2  // тип ответа (2-ошибка)
            else // нет ошибок
              strfile(space(5) + 'ошибок не обнаружено' + ;
                      hb_eol(), cFileProtokol, .t.)
              do case
                case nf->TIP_F == 1
                  select NAPR
                  index on str(kod, 6) to (cur_dir + 'tmp_naprkod') for KOD_F_1out == nf->KOD
                  go top
                  do while !eof()
                    G_RLock(forever)
                    napr->T_ANS_1 := 1
                    dbUnLock()
                    skip
                  enddo
                case nf->TIP_F == 3
                  select NAPR
                  index on str(kod, 6) to (cur_dir + 'tmp_naprkod') for KOD_F_3out == nf->KOD
                  go top
                  do while !eof()
                    G_RLock(forever)
                    napr->T_ANS_3 := 1
                    dbUnLock()
                    skip
                  enddo
                case nf->TIP_F == 4 .or. nf->TIP_F == 5
                  select NAPR
                  index on str(kod, 6) to (cur_dir + 'tmp_naprkod') for KOD_F_4out == nf->KOD
                  go top
                  do while !eof()
                    G_RLock(forever)
                    napr->T_ANS_4 := 1
                    dbUnLock()
                    skip
                  enddo
                case nf->TIP_F == 6
                  select NAPR
                  index on str(kod, 6) to (cur_dir + 'tmp_naprkod') for KOD_F_6out == nf->KOD
                  go top
                  do while !eof()
                    G_RLock(forever)
                    napr->T_ANS_6 := 1
                    dbUnLock()
                    skip
                  enddo
                case nf->TIP_F == 7
                  //
              endcase
              nf->T_ANS := 1  // тип ответа (1-всё хорошо)
            endif
            nf->TWORK2 := hour_min(seconds()) // время окончания обработки
            nf->TXT_F := name_txt
            nf->D_ANS := tmp1->DATE_F // дата протокола ответа из ТФОМС
            dbUnLockAll()
            Commit
            tmp2->(dbCloseArea())
            tmp1->(dbCloseArea())
          else
            strfile(space(5) + 'данный файл уже был прочитан (дата протокола ответа из ТФОМС ' + date_8(nf->d_ans) + 'г.)' + hb_eol() + ;
                    space(5) +iif(nf->t_ans==1, 'ошибок не обнаружено', 'обнаружены ошибки') + ;
                    hb_eol(), cFileProtokol, .t.)
          endif
        elseif type_paket != 7
          strfile(space(5) + 'мы не отправляли в ТФОМС пакет '+substr(cName, 2) + ;
                  hb_eol(), cFileProtokol, .t.)
          if '_' $ cName
            s := right(beforatnum('_', cName), 6)
            if s == glob_mo[_MO_KOD_TFOMS]
              // наше МО
            elseif (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == s})) > 0
              strfile(space(5) + 'это пакет МО "' + glob_arr_mo[i, _MO_SHORT_NAME] + '"' + ;
                      hb_eol(), cFileProtokol, .t.)
            endif
          endif
        endif
      else // полученный файл информационного пакета
        type_paket := int(val(substr(cName, 3, 1)))
        select NF
        index on upper(name_f) to (cur_dir + 'tmp_nf') for in_out == 2
        find (padr(upper(cName), 26)) // поиск, м.б. уже читали?
        if found()
          strfile(space(5) + 'данный файл уже был прочитан ' + date_8(nf->DWORK) + 'г. в ' + nf->TWORK2+ ;
                  iif(nf->kol == 0, '', hb_eol() + space(5) + 'количество пациентов - ' + lstr(nf->kol)) + ;
                  hb_eol(), cFileProtokol, .t.)
        else
          s := substr(cName, 5, 6)
          if s == glob_mo[_MO_KOD_TFOMS] // наше МО
            s := beforatnum('_', substr(cName, 11))
            if (c := left(s, 1)) == 'M'
              sFrom := substr(s, 2)
              if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == sFrom})) > 0
                s := 'от МО "' + glob_arr_mo[i, _MO_SHORT_NAME] + '"'
              else
                aadd(aerr, 'Файл ' + cName + sxml + ' неизвестно от кого (неизвестный код МО ' + sFrom + ')')
              endif
            elseif c == 'S'
              s := substr(s, 2)
              if s == '34007'
                s := 'от СМО ООО "Капитал МС"'
              elseif s == '34002'
                s := 'от СМО "Согаз"'
              elseif s == '34001'
                s := 'от СМО "Капитал"'
              elseif s == '34006'
                s := 'от СМО "Максимус"'
              else
                aadd(aerr, 'Файл ' + cName + sxml + ' от неизвестной СМО (код ' + s + ')')
              endif
            else
              aadd(aerr, 'Файл ' + cName+sxml+' неизвестно от кого')
            endif
            if empty(aerr)
              ar := {'о выписанных в поликлинике направлениях', ;
                     'об установленных стационаром датах плановой госпитализации по направлениям', ;
                     'об аннулировании направлений', ;
                     'о госпитализациях пациентов по направлениям или в результате перевода', ;
                     'о госпитализациях по экстренным или неотложным показаниям (без направлений)', ;
                     'о выбывших из стационара пациентах', ;
                    'о наличии в стационарах свободных мест'}
              strfile(space(5) + 'это информационный пакет со сведениями' + hb_eol() + ;
                      space(5) + ar[type_paket] + hb_eol() + ;
                      space(5) + charone('"', s) + ;
                      hb_eol(), cFileProtokol, .t.)
              do case
                case type_paket == 1
                  if _263_I01_tmpfile(af[1], aerr)
                    is_read := .t.
                    select NAPR
                    index on num_d to (cur_dir + 'tmp_naprnum')
                    // добавим запись о принимаемом файле
                    select NF
                    G_RLock(.t., forever) // бесконечная попытка добавить запись
                    nf->KOD := recno()            // код файла
                    nf->DATE_F := tmp1->DATE_F    // дата файла
                    nf->NAME_F := tmp1->NAME_F    // имя файла без расширения (и ZIP-архива)
                    nf->DATE_R := tmp1->DATE_R    // отчётная дата
                    nf->NN := 0                   // порядковый номер пакета за отчётную дату
                    nf->TIP_F := 1                // от 1 до 7 (пакеты от I01 до I07)
                    nf->IN_OUT := 2               // 1-в ТФОМС, 2-из ТФОМС
                    nf->DATE_OUT := ctod('')      // дата отправки в ТФОМС
                    nf->KOL := tmp1->kol          // количество пациентов в файле
                    nf->DWORK := sys_date         // дата обработки файла
                    nf->TWORK1 := hour_min(seconds()) // время начала обработки
                    nf->TWORK2 := ''              // время окончания обработки
                    nf->TXT_F := name_txt
                    nf->D_ANS := ctod('')         // дата протокола ответа из ТФОМС
                    nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
                    //
                    select TMP2
                    go top
                    do while !eof()
                      mfio := alltrim(alltrim(tmp2->SURNAME) + ' ' + alltrim(tmp2->NAME) + ' ' + alltrim(tmp2->PATRONYMIC))
                      strfile(space(5) + '- обрабатывается направление № ' + alltrim(tmp2->NUM_D) + ;
                                     ' от ' + date_8(tmp2->DATE_D) + hb_eol() + ;
                            space(7) + mfio + ' д.р.' + full_date(tmp2->BIRTHDAY) + hb_eol() + ;
                            space(7) + 'Условия оказания, в которые направляется пациент: ' + ;
                                     iif(tmp2->usl_ok == 2, 'дневной ', '') + 'стационар' + hb_eol() + ;
                            space(7) + 'Направление выдано по результатам диспансеризации/профосмотра взрослых: ' + ;
                                     iif(tmp2->disp == 1, 'нет', 'да') + hb_eol() + ;
                            space(7) + 'планируемая дата госпитализации ' + date_8(tmp2->DATE_HOSP) + ;
                                     ' по диагнозу ' + alltrim(tmp2->DS) + hb_eol() + ;
                            space(7) + inieditspr(A__MENUVERT, arr_t007, tmp2->PROFIL_K) + ;
                                     ' (' + inieditspr(A__MENUVERT, getV002(), tmp2->PROFIL) + ')' + ;
                            hb_eol(), cFileProtokol, .t.)
                      m1kod_k := 0
                      select NAPR
                      find (tmp2->NUM_D)
                      if found()
                        G_RLock(forever)
                        if napr->KOD_K > 0
                          m1kod_k := napr->KOD_K
                        endif
                      else
                        if sFrom == glob_mo[_MO_KOD_TFOMS] // направление из нашей п-ки
                          strfile(space(7) + 'это наше направление - почему-то не найдено в отправленных - добавляем' + ;
                                  hb_eol(), cFileProtokol, .t.)
                        endif
                        G_RLock(.t., forever) // бесконечная попытка добавить запись
                        napr->KOD := recno() // код направления - номер записи
                        napr->NUM_D := tmp2->NUM_D
                        napr->DATE_D := tmp2->DATE_D
                      endif
                      // добавим запись в картотеке (или перезапишем)
                      m1kod_k := _263_add_kart(m1kod_k, mfio, cFileProtokol)
                      //
                      napr->KOD_K := m1kod_k // код по картотеке
                      napr->MCOD_1 := tmp2->MO // код поликлиники
                      napr->CODEM_1 := tmp2->LPU // код поликлиники
                      napr->DS_1 := tmp2->DS // диагноз поликлиники
                      napr->usl_ok_1 := tmp2->usl_ok
                      napr->disp_1 := tmp2->disp
                      napr->F_MEDC_1 := tmp2->F_MEDC // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
                      napr->ID_1 := tmp2->ID_D // GUID30+lstr(mo_nnapr->KOD) ID направления
                      napr->DATE_H_1 := tmp2->DATE_HOSP // планируемая дата госпитализации
                      napr->PROFIL_K_1 := tmp2->PROFIL_K // профиль койки по справочнику T007
                      napr->PROFIL_1 := tmp2->PROFIL // профиль мед.помощи по справочнику V002
                      //napr->VRACH_1 := ??IDDOKT // лечащий врач по mo_pers
                      napr->S_MCOD := tmp2->MO_H // код стационара
                      napr->S_CODEM := tmp2->LPU_H //_код стационара
                      napr->KOD_F_1in := nf->KOD // код файла - по файлу mo_nfile
                      if empty(napr->KOD_F_1out)
                        napr->KOD_F_1out := -99 // не наш
                      endif
                      //
                      select TMP2
                      skip
                    enddo
                    nf->TWORK2 := hour_min(seconds()) // время окончания обработки
                    chip_copy_zipXML(arr_f[ii], dir_server + dir_NAPR_TF)
                  endif
                case type_paket == 3
                  if _263_I03_tmpfile(af[1], aerr)
                    is_read := .t.
                    select NAPR
                    set index to (cur_dir + 'tmp_napr')
                    // добавим запись о принимаемом файле
                    select NF
                    G_RLock(.t., forever) // бесконечная попытка добавить запись
                    nf->KOD := recno()            // код файла
                    nf->DATE_F := tmp1->DATE_F    // дата файла
                    nf->NAME_F := tmp1->NAME_F    // имя файла без расширения (и ZIP-архива)
                    nf->DATE_R := tmp1->DATE_R    // отчётная дата
                    nf->NN := 0                   // порядковый номер пакета за отчётную дату
                    nf->TIP_F := 3                // от 1 до 7 (пакеты от I01 до I07)
                    nf->IN_OUT := 2               // 1-в ТФОМС, 2-из ТФОМС
                    nf->DATE_OUT := ctod('')      // дата отправки в ТФОМС
                    nf->KOL := tmp1->kol          // количество пациентов в файле
                    nf->DWORK := sys_date         // дата обработки файла
                    nf->TWORK1 := hour_min(seconds()) // время начала обработки
                    nf->TWORK2 := ''              // время окончания обработки
                    nf->TXT_F := name_txt
                    nf->D_ANS := ctod('')         // дата протокола ответа из ТФОМС
                    nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
                    //
                    select TMP2
                    go top
                    do while !eof()
                      select NAPR
                      find (upper(tmp2->ID_D))
                      if found()
                        G_RLock(forever)
                        kart->(dbGoto(napr->KOD_K))
                        mfio := alltrim(kart->fio)
                        //
                        s := space(5) + '- обрабатывается направление № ' + alltrim(napr->NUM_D) + ' от ' + date_8(napr->DATE_D) + hb_eol() + ;
                             space(7) + mfio + ' д.р.' + full_date(kart->date_r) + hb_eol() + ;
                            space(7) + 'планируемая дата госпитализации (п-ка) - ' + full_date(napr->DATE_H_1) + hb_eol()
                        /*if !empty(napr->DATE_H_2)
                          s+=space(7) + 'планируемая дата госпитализации (стац) - ' + full_date(napr->DATE_H_2) + hb_eol() + ;
                             space(7) + '(дата госпитализации введена в стационаре - ' + full_date(napr->DATE_2) + ')' + hb_eol()
                        endif*/
                        s += space(7) + 'причина аннулирования: ' + inieditspr(A__MENUVERT, get_reason_annul(), tmp2->REASON_REF) + hb_eol() + ;
                             space(7) + 'дата аннулирования ' + full_date(tmp2->DATE_REF) + hb_eol()
                        if empty(napr->DATE_3)
                          napr->DATE_3 := tmp2->DATE_REF // дата аннулирования
                          napr->TIP_ANNUL := tmp2->TYPE_S  // где ануллировано
                          napr->rea_annul := tmp2->REASON_REF // причина аннулирования
                        elseif !(napr->DATE_3    == tmp2->DATE_REF .and. ;
                               napr->TIP_ANNUL == tmp2->TYPE_S   .and. ;
                               napr->rea_annul == tmp2->REASON_REF)
                          s += space(8) + 'у нас УЖЕ ЗАНЕСЕНО аннулирование в '
                          if napr->TIP_ANNUL == 1
                            s += 'СМО'
                          elseif napr->TIP_ANNUL == 2
                            s += 'стационаре'
                          else
                            s += 'поликлинике'
                          endif
                          s += hb_eol()
                          s += space(8) + 'причина аннулирования: ' + inieditspr(A__MENUVERT, get_reason_annul(), napr->rea_annul) + hb_eol() + ;
                               space(8) + 'дата аннулирования ' + full_date(napr->date_3) + hb_eol()
                        endif
                        if empty(napr->KOD_F_3in)
                          napr->KOD_F_3in := nf->KOD // код файла - по файлу mo_nfile
                        endif
                        if empty(napr->KOD_F_3out)
                          napr->KOD_F_3out := -99 // не наш
                        endif
                        strfile(s + hb_eol(), cFileProtokol, .t.)
                      else
                        strfile(space(5) + '- не найдено направление с ID_D=' + alltrim(tmp2->ID_D) + ;
                                hb_eol(), cFileProtokol, .t.)
                      endif
                      //
                      select TMP2
                      skip
                    enddo
                    nf->TWORK2 := hour_min(seconds()) // время окончания обработки
                    chip_copy_zipXML(arr_f[ii], dir_server + dir_NAPR_TF)
                  endif
                case type_paket == 4 .or. type_paket == 5
                  if _263_I04_tmpfile(af[1], aerr)
                    is_read := .t.
                    select NAPR
                    index on upper(id_4) to (cur_dir + 'tmp_naprid4')
                    if !(sFrom == glob_mo[_MO_KOD_TFOMS]) .and. is_napr_pol
                      index on upper(id_1) to (cur_dir + 'tmp_naprid1')
                      set index to (cur_dir + 'tmp_naprid4'), (cur_dir + 'tmp_naprid1')
                    endif
                    // добавим запись о принимаемом файле
                    select NF
                    G_RLock(.t., forever) // бесконечная попытка добавить запись
                    nf->KOD := recno()            // код файла
                    nf->DATE_F := tmp1->DATE_F    // дата файла
                    nf->NAME_F := tmp1->NAME_F    // имя файла без расширения (и ZIP-архива)
                    nf->DATE_R := tmp1->DATE_R    // отчётная дата
                    nf->NN := 0                   // порядковый номер пакета за отчётную дату
                    nf->TIP_F := type_paket       // от 1 до 7 (пакеты от I01 до I07)
                    nf->IN_OUT := 2               // 1-в ТФОМС, 2-из ТФОМС
                    nf->DATE_OUT := ctod('')      // дата отправки в ТФОМС
                    nf->KOL := tmp1->kol          // количество пациентов в файле
                    nf->DWORK := sys_date         // дата обработки файла
                    nf->TWORK1 := hour_min(seconds()) // время начала обработки
                    nf->TWORK2 := ''              // время окончания обработки
                    nf->TXT_F := name_txt
                    nf->D_ANS := ctod('')         // дата протокола ответа из ТФОМС
                    nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
                    //
                    select TMP2
                    go top
                    do while !eof()
                      mfio := alltrim(alltrim(tmp2->SURNAME) + ' ' + alltrim(tmp2->NAME) + ' ' + alltrim(tmp2->PATRONYMIC))
                      s := '- обрабатывается госпитализация '
                      s1 := iif(empty(tmp2->LPU_D) .or. tmp2->TYPE_H == 3, '', 'из ' + ret_mo(tmp2->LPU_D)[_MO_SHORT_NAME])
                      do case
                        case tmp2->TYPE_H == 1
                          s += 'по направлению'
                        case tmp2->TYPE_H == 2
                          s += 'переводом из другого стационара'
                        case tmp2->TYPE_H == 3
                          s += 'переводом внутри нашего МО'
                        case tmp2->TYPE_H == 4
                          s += 'по неотложным или экстренным показаниям'
                      endcase
                      strfile(space(5) + s + hb_eol() + ;
                              iif(empty(s1), '', space(7) + s1 + hb_eol()) + ;
                              space(7) +mfio+' д.р.' + full_date(tmp2->BIRTHDAY) + hb_eol() + ;
                              space(7) + 'условия оказания медицинской помощи: ' + ;
                                     iif(tmp2->usl_ok == 2, 'дневной ', '') + 'стационар' + hb_eol(), cFileProtokol, .t.)
                      if sFrom == glob_mo[_MO_KOD_TFOMS] // если пациент лёг в наш стационар
                        select NAPR
                        find (upper(tmp2->ID_H)) // ищем GUID госпитализации
                        if found()
                          if tmp2->TYPE_H == 1 .and. !empty(napr->NUM_D)
                            strfile(space(7) + 'направление № ' + alltrim(napr->NUM_D) + ' от ' + date_8(napr->DATE_D) + ;
                                    hb_eol(), cFileProtokol, .t.)
                          endif
                          G_RLock(forever)
                          napr->KOD_F_4in := nf->KOD // код файла - по файлу mo_nfile
                          UnLock
                        else
                          strfile(space(7) + 'это наша госпитализация - почему-то не найдена в отправленных ?' + ;
                                  hb_eol(), cFileProtokol, .t.)
                        endif
                      else // из другого стационара к нам в п-ку пришло уведомление
                        if tmp2->TYPE_H == 1 .and. !empty(tmp2->ID_D)
                          select NAPR
                          set order to 2
                          find (upper(tmp2->ID_D))
                          if found()
                            if tmp2->TYPE_H == 1 .and. !empty(napr->NUM_D)
                              strfile(space(7) + 'направление № ' + alltrim(napr->NUM_D) + ' от ' + date_8(napr->DATE_D) + ;
                                      hb_eol(), cFileProtokol, .t.)
                            endif
                            G_RLock(forever)
                            napr->CODEM_FROM := iif(empty(tmp2->LPU_D), glob_mo[_MO_KOD_TFOMS], tmp2->LPU_D)
                            napr->TYPE_H_4 := tmp2->TYPE_H
                            napr->ID_4 := tmp2->ID_H
                            napr->KOD_UP := 0
                            napr->KOD_PP := 0
                            napr->DS_4 := tmp2->ds // диагноз приёмного отделения
                            napr->F_MEDC_4 := tmp2->F_MEDC // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
                            napr->DATE_H_4 := tmp2->DATE_H // дата госпитализации
                            napr->TIME_H_4 := tmp2->TIME_H // время госпитализации
                            napr->PROFIL_K_4 := tmp2->PROFIL_K // профиль койки по справочнику T007
                            napr->PROFIL_4 := tmp2->PROFIL // профиль мед.помощи по справочнику V002
                            napr->NUM_HIST_4 := tmp2->NUM_HIST
                            napr->KOD_F_4in := nf->KOD // код файла - по файлу mo_nfile
                            if empty(napr->KOD_F_4out)
                              napr->KOD_F_4out := -99 // не наша госпитализация
                            endif
                            UnLock
                          else
                            strfile(space(7) + 'это наше направление - почему-то не найдено в отправленных ?' + ;
                                    hb_eol(), cFileProtokol, .t.)
                          endif
                          set order to 1
                        elseif empty(tmp2->BIRTHDAY) // нет даты рождения
                          strfile(space(7) + 'нет даты рождения, поэтому не добавляем к себе в базу данных' + ;
                                  hb_eol(), cFileProtokol, .t.)
                        else
                          if (m1kod_k := _263_add_kart(0, mfio, cFileProtokol, .f.)) > 0
                            // добавим запись в картотеке (или перезапишем)
                            select NAPR
                            G_RLock(.t., forever) // бесконечная попытка добавить запись
                            napr->KOD := recno() // код направления - номер записи
                            //
                            napr->KOD_K := m1kod_k // код по картотеке
                            napr->CODEM_FROM := tmp2->LPU_D
                            napr->TYPE_H_4 := tmp2->TYPE_H
                            napr->ID_4 := tmp2->ID_H
                            napr->KOD_UP := 0
                            napr->KOD_PP := 0
                            napr->usl_ok_4 := tmp2->usl_ok
                            napr->DS_4 := tmp2->ds // диагноз приёмного отделения
                            napr->F_MEDC_4 := tmp2->F_MEDC // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
                            napr->DATE_H_4 := tmp2->DATE_H // дата госпитализации
                            napr->TIME_H_4 := tmp2->TIME_H // время госпитализации
                            napr->PROFIL_K_4 := tmp2->PROFIL_K // профиль койки по справочнику T007
                            napr->PROFIL_4 := tmp2->PROFIL // профиль мед.помощи по справочнику V002
                            napr->NUM_HIST_4 := tmp2->NUM_HIST
                            napr->S_MCOD := tmp2->MO // код стационара
                            napr->S_CODEM := tmp2->LPU //_код стационара
                            napr->KOD_F_4in := nf->KOD // код файла - по файлу mo_nfile
                            if empty(napr->KOD_F_4out)
                              napr->KOD_F_4out := -99 // не наша госпитализация
                            endif
                            //
                            napr->DATE_R := tmp2->BIRTHDAY
                            napr->SEX    := tmp2->SEX
                            napr->ENP    := tmp2->ENP
                            UnLock
                          else
                            strfile(space(7) + 'по ФИО и дате рождения пациент не найден в нашей картотеке - не добавляем' + ;
                                    hb_eol(), cFileProtokol, .t.)
                          endif
                        endif
                      endif
                      //
                      select TMP2
                      skip
                    enddo
                    nf->TWORK2 := hour_min(seconds()) // время окончания обработки
                    chip_copy_zipXML(arr_f[ii], dir_server + dir_NAPR_TF)
                  endif
                case type_paket == 6
                  if _263_I06_tmpfile(af[1], aerr)
                    is_read := .t.
                    select NAPR
                    index on upper(id_6) to (cur_dir + 'tmp_naprid6')
                    if !(sFrom == glob_mo[_MO_KOD_TFOMS]) .and. is_napr_pol
                      index on upper(id_1) to (cur_dir + 'tmp_naprid1')
                      index on dtos(DATE_H_4) to (cur_dir + 'tmp_naprd4')
                      set index to (cur_dir + 'tmp_naprid6'),(cur_dir + 'tmp_naprid1'),(cur_dir + 'tmp_naprd4')
                    endif
                    // добавим запись о принимаемом файле
                    select NF
                    G_RLock(.t., forever) // бесконечная попытка добавить запись
                    nf->KOD := recno()            // код файла
                    nf->DATE_F := tmp1->DATE_F    // дата файла
                    nf->NAME_F := tmp1->NAME_F    // имя файла без расширения (и ZIP-архива)
                    nf->DATE_R := tmp1->DATE_R    // отчётная дата
                    nf->NN := 0                   // порядковый номер пакета за отчётную дату
                    nf->TIP_F := 6                // от 1 до 7 (пакеты от I01 до I07)
                    nf->IN_OUT := 2               // 1-в ТФОМС, 2-из ТФОМС
                    nf->DATE_OUT := ctod('')      // дата отправки в ТФОМС
                    nf->KOL := tmp1->kol          // количество пациентов в файле
                    nf->DWORK := sys_date         // дата обработки файла
                    nf->TWORK1 := hour_min(seconds()) // время начала обработки
                    nf->TWORK2 := ''              // время окончания обработки
                    nf->TXT_F := name_txt
                    nf->D_ANS := ctod('')         // дата протокола ответа из ТФОМС
                    nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
                    //
                    select TMP2
                    go top
                    do while !eof()
                      strfile(space(5) + '- обрабатывается выбытие из стационара' + hb_eol() + ;
                              space(7) + 'госпитализация - ' + date_8(tmp2->DATE_H) + ', выбытие ' + date_8(tmp2->DATE_D) + hb_eol() + ;
                              space(7) +iif(tmp2->SEX == 1, 'мужчина', 'женщина') + ' д.р.' + full_date(tmp2->BIRTHDAY) + ;
                                      iif(empty(tmp2->ENP), '', ' полис '+tmp2->ENP) + hb_eol() + ;
                              space(7) + 'условия оказания медицинской помощи: ' + ;
                                      iif(tmp2->usl_ok == 2, 'дневной ', '') + 'стационар' + hb_eol(), cFileProtokol, .t.)
                      if sFrom == glob_mo[_MO_KOD_TFOMS] // если пациент лежал в нашем стационар
                        select NAPR
                        set order to 1
                        find (upper(tmp2->ID_DISCH)) // ищем GUID выбытия
                        if found()
                          if napr->kod_k > 0
                            kart->(dbGoto(napr->kod_k))
                            strfile(space(7) + kart->fio + ;
                                    hb_eol(), cFileProtokol, .t.)
                          endif
                          if !empty(napr->NUM_D)
                            strfile(space(7) + 'направление № ' + alltrim(napr->NUM_D) + ' от ' + date_8(napr->DATE_D) + ;
                                    hb_eol(), cFileProtokol, .t.)
                          endif
                          G_RLock(forever)
                          napr->KOD_F_6in := nf->KOD // код файла - по файлу mo_nfile
                          if empty(napr->KOD_F_6out)
                            napr->KOD_F_6out := -99 // не наш
                          endif
                          UnLock
                        else
                          strfile(space(7) + 'это наша госпитализация/выбытие - почему-то не найдена в отправленных ?' + ;
                                  hb_eol(), cFileProtokol, .t.)
                        endif
                      else // из другого стационара к нам в п-ку пришло уведомление
                        if !empty(tmp2->ID_D)
                          select NAPR
                          set order to 2
                          find (upper(tmp2->ID_D))
                          if found()
                            if napr->kod_k > 0
                              kart->(dbGoto(napr->kod_k))
                              strfile(space(7) + kart->fio + ;
                                    hb_eol(), cFileProtokol, .t.)
                            endif
                            if !empty(napr->NUM_D)
                              strfile(space(7) + 'направление № ' + alltrim(napr->NUM_D) + ' от ' + date_8(napr->DATE_D) + ;
                                      hb_eol(), cFileProtokol, .t.)
                            endif
                            G_RLock(forever)
                            napr->DATE_6 := tmp2->DATE_D // дата выписки
                            napr->KOD_F_6in := nf->KOD // код файла - по файлу mo_nfile
                            if empty(napr->KOD_F_6out)
                              napr->KOD_F_6out := -99 // не наш
                            endif
                            UnLock
                          else
                            strfile(space(7) + 'это наше направление - почему-то не найдено в отправленных ?' + ;
                                    hb_eol(), cFileProtokol, .t.)
                          endif
                        else
                          fl := .f.
                          select NAPR
                          set order to 3
                          find (dtos(tmp2->DATE_H))
                          do while tmp2->DATE_H == napr->DATE_H_4 .and. !eof()
                            if napr->kod_k > 0
                              kart->(dbGoto(napr->kod_k))
                              if tmp2->BIRTHDAY == iif(empty(napr->DATE_R), kart->DATE_R, napr->DATE_R)
                                if upper(tmp2->NUM_HIST) == upper(napr->NUM_HIST_4)
                                  fl := .t.
                                  strfile(space(7) + kart->fio + ;
                                          hb_eol(), cFileProtokol, .t.)
                                  select NAPR
                                  G_RLock(forever)
                                  napr->DATE_6 := tmp2->DATE_D // дата выписки
                                  napr->KOD_F_6in := nf->KOD   // код файла - по файлу mo_nfile
                                  if empty(napr->KOD_F_6out)
                                    napr->KOD_F_6out := -99 // не наш
                                  endif
                                  UnLock
                                  exit
                                endif
                              endif
                            endif
                            select NAPR
                            skip
                          enddo
                          if !fl
                            strfile(space(7) + 'данная госпитализация не найдена в нашей базе данных ?' + ;
                                    hb_eol(), cFileProtokol, .t.)
                          endif
                        endif
                      endif
                      //
                      select TMP2
                      skip
                    enddo
                    nf->TWORK2 := hour_min(seconds()) // время окончания обработки
                    chip_copy_zipXML(arr_f[ii], dir_server + dir_NAPR_TF)
                  endif
                case type_paket == 7
                  fl := .t.
                  luch := beforatnum('_', cName)
                  ldate := stod('20' + left(afteratnum('_', cName), 6))
                  lrec_nf := 0
                  select NF
                  //index on upper(name_f) to tmp_nf for in_out == 2
                  find (upper(luch)) // м.б. уже читали I07 от данного МО?
                  if found()
                    lrec_nf := nf->kod
                    if nf->DATE_R > ldate
                      fl := .f.
                      strfile(space(5) + 'у нас уже прочитан более поздний файл от ' + date_8(nf->DATE_R) + ;
                              hb_eol(), cFileProtokol, .t.)
                    endif
                  endif
                  if fl .and. _263_I07_tmpfile(af[1], aerr)
                    // добавим запись о принимаемом файле
                    is_read := .t.
                    select NF
                    if lrec_nf == 0
                      G_RLock(.t., forever) // бесконечная попытка добавить запись
                      nf->KOD := recno()            // код файла
                      lrec_nf := nf->KOD
                    else
                      goto (lrec_nf)
                      G_RLock(forever) // бесконечная попытка блокировать запись
                    endif
                    nf->DATE_F := tmp1->DATE_F    // дата файла
                    nf->NAME_F := tmp1->NAME_F    // имя файла без расширения (и ZIP-архива)
                    nf->DATE_R := tmp1->DATE_R    // отчётная дата
                    nf->NN := 0                   // порядковый номер пакета за отчётную дату
                    nf->TIP_F := 7                // от 1 до 7 (пакеты от I01 до I07)
                    nf->IN_OUT := 2               // 1-в ТФОМС, 2-из ТФОМС
                    nf->DATE_OUT := ctod('')      // дата отправки в ТФОМС
                    nf->KOL := tmp1->kol          // количество
                    nf->DWORK := sys_date         // дата обработки файла
                    nf->TWORK1 := hour_min(seconds()) // время начала обработки
                    nf->TWORK2 := ''              // время окончания обработки
                    nf->TXT_F := name_txt
                    nf->D_ANS := ctod('')         // дата протокола ответа из ТФОМС
                    nf->T_ANS := 0                // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
                    //
                    if lrec_nf > 0
                      select N7
                      do while !eof()
                        find (str(lrec_nf, 6))
                        if !found()
                          exit
                        endif
                        DeleteRec(.t.)
                      enddo
                    endif
                    select TMP2
                    go top
                    do while !eof()
                      select N7
                      AddRec(6)
                      n7->KOD_F      := nf->KOD          // код файла - по файлу mo_nfile
                      n7->CODEM      := tmp2->LPU        // код стационара
                      n7->ID_PL      := tmp2->ID_PL      // GUID записи
                      n7->USL_OK     := tmp2->USL_OK     //
                      n7->PROFIL_K   := tmp2->PROFIL_K   // профиль койки
                      n7->PROFIL     := tmp2->PROFIL     // профиль мед.помощи
                      n7->QUANTITY   := tmp2->QUANTITY   // количество коек
                      n7->Q_P        := tmp2->Q_P        // состояло пациентов на начало пред.суток
                      n7->Q_AP       := tmp2->Q_AP       // поступило пациентов за пред.сутки
                      n7->Q_DP       := tmp2->Q_DP       // выбыло пациентов за пред.сутки
                      n7->Q_HP       := tmp2->Q_HP       // запланировано госпитализаций на тек.день
                      n7->PLACE_FREE := tmp2->PLACE_FREE // количество свободных мест
                      n7->PF_M       := tmp2->PF_M       // --''-- для мужчин
                      n7->PF_W       := tmp2->PF_W       // --''-- для женщин
                      n7->PF_C       := tmp2->PF_C       // --''-- для детей
                      n7->PLACE1     := tmp2->PLACE1     // количество свободных мест
                      n7->PF_M1      := tmp2->PF_M1      // --''-- для мужчин
                      n7->PF_W1      := tmp2->PF_W1      // --''-- для женщин
                      n7->PF_C1      := tmp2->PF_C1      // --''-- для детей
                      n7->PLACE2     := tmp2->PLACE2     // количество свободных мест
                      n7->PF_M2      := tmp2->PF_M2      // --''-- для мужчин
                      n7->PF_W2      := tmp2->PF_W2      // --''-- для женщин
                      n7->PF_C2      := tmp2->PF_C2      // --''-- для детей
                      n7->PLACE3     := tmp2->PLACE3     // количество свободных мест
                      n7->PF_M3      := tmp2->PF_M3      // --''-- для мужчин
                      n7->PF_W3      := tmp2->PF_W3      // --''-- для женщин
                      n7->PF_C3      := tmp2->PF_C3      // --''-- для детей
                      n7->PLACE4     := tmp2->PLACE4     // количество свободных мест
                      n7->PF_M4      := tmp2->PF_M4      // --''-- для мужчин
                      n7->PF_W4      := tmp2->PF_W4      // --''-- для женщин
                      n7->PF_C4      := tmp2->PF_C4      // --''-- для детей
                      n7->PLACE5     := tmp2->PLACE5     // количество свободных мест
                      n7->PF_M5      := tmp2->PF_M5      // --''-- для мужчин
                      n7->PF_W5      := tmp2->PF_W5      // --''-- для женщин
                      n7->PF_C5      := tmp2->PF_C5      // --''-- для детей
                      n7->PLACE6     := tmp2->PLACE6     // количество свободных мест
                      n7->PF_M6      := tmp2->PF_M6      // --''-- для мужчин
                      n7->PF_W6      := tmp2->PF_W6      // --''-- для женщин
                      n7->PF_C6      := tmp2->PF_C6      // --''-- для детей
                      n7->PLACE7     := tmp2->PLACE7     // количество свободных мест
                      n7->PF_M7      := tmp2->PF_M7      // --''-- для мужчин
                      n7->PF_W7      := tmp2->PF_W7      // --''-- для женщин
                      n7->PF_C7      := tmp2->PF_C7      // --''-- для детей
                      n7->PLACE8     := tmp2->PLACE8     // количество свободных мест
                      n7->PF_M8      := tmp2->PF_M8      // --''-- для мужчин
                      n7->PF_W8      := tmp2->PF_W8      // --''-- для женщин
                      n7->PF_C8      := tmp2->PF_C8      // --''-- для детей
                      n7->PLACE9     := tmp2->PLACE9     // количество свободных мест
                      n7->PF_M9      := tmp2->PF_M9      // --''-- для мужчин
                      n7->PF_W9      := tmp2->PF_W9      // --''-- для женщин
                      n7->PF_C9      := tmp2->PF_C9      // --''-- для детей
                      n7->PLACE10    := tmp2->PLACE10    // количество свободных мест
                      n7->PF_M10     := tmp2->PF_M10     // --''-- для мужчин
                      n7->PF_W10     := tmp2->PF_W10     // --''-- для женщин
                      n7->PF_C10     := tmp2->PF_C10     // --''-- для детей
                      n7->V_H34001   := tmp2->V_H34001   // количество госпитализаций реабилитаций СНГ
                      n7->V_H34002   := tmp2->V_H34002   // количество госпитализаций реабилитаций СНГ
                      n7->V_H34006   := tmp2->V_H34006   // количество госпитализаций реабилитаций СНГ
                      n7->V_H34007   := tmp2->V_H34007   // количество госпитализаций реабилитаций СНГ
                      select TMP2
                      skip
                    enddo
                    nf->TWORK2 := hour_min(seconds()) // время окончания обработки
                    //chip_copy_zipXML(arr_f[ii], dir_server + dir_NAPR_TF)
                  endif
              endcase
              dbUnLockAll()
              Commit
              if select('TMP2') != 0
                tmp2->(dbCloseArea())
              endif
              if select('TMP1') != 0
                tmp1->(dbCloseArea())
              endif
            endif
          elseif (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == s})) > 0
            strfile(space(5) + 'это пакет не для нас, а для МО "' + glob_arr_mo[i, _MO_SHORT_NAME] + '"' + ;
                    hb_eol(), cFileProtokol, .t.)
          endif
        endif
      endif
    endif
    if !empty(aerr)
      exit
    endif
  next ii
  close databases
  rest_box(buf)
  if empty(aerr)
    if is_read
      copy file (cFileProtokol) to (name_txt)
      // запишем файл протокола обработки
      chip_copy_zipXML(name_txt, dir_server + dir_NAPR_TF, .t.)
    endif
    if !empty(dir_263_copy)
      strfile(hb_eol() + 'Перезапись прочитанных файлов в каталог ' + dir_263_copy + hb_eol() + ;
                       'и удаление прочитанных файлов из каталога ' + dir_263_from + ;
                        hb_eol(), cFileProtokol, .t.)
      for ii := 1 to len(arr_f)
        name_zip := StripPath(arr_f[ii])  // имя файла без пути
        copy file (arr_f[ii]) to (dir_263_copy + name_zip)
        delete file (arr_f[ii])
        strfile('- ' + name_zip + ' переписан' + ;
                hb_eol(), cFileProtokol, .t.)
      next ii
    endif
  else
    aeval(aerr, {|x| strfile(x + hb_eol(), cFileProtokol, .t.) })
  endif
  viewtext(Devide_Into_Pages(cFileProtokol, 60, 80), , , , .t., , , 2)
  delete file (cFileProtokol)
  mo_UnLock_Task(X_263)
  return NIL

// 22.07.14 Просмотр протоколов чтения информационных пакетов из ТФОМС
Function _263_from_protokol()
  Local i, d, s, blk, t_arr[BR_LEN], buf := save_maxrow()

  mywait()
  dbcreate(cur_dir + 'tmp', {{'named','D', 8, 0}, ;
                            {'namet','C', 9, 0}, ;
                            {'txt_f','C', 15, 0}})
  use (cur_dir + 'tmp') new
  blk := {|x| s := Name_Without_Ext(StripPath(x)), ;
            dbAppend(), ;
            tmp->named := stod(left(s, 8)), ;
            tmp->namet := left(right(s, 6), 2) + ':'+left(right(s, 4), 2) + ':' + right(s, 2), ;
            tmp->txt_f := s }
  scandirfiles(dir_server + dir_NAPR_TF + cslash, '*' + stxt, blk )
  if lastrec() == 0
    close databases
    rest_box(buf)
    return func_error(4, 'Пока ещё не читали информационные пакеты из ТФОМС')
  endif
  index on descend(txt_f) to (cur_dir + 'tmp')
  go top
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT] := T_COL - 5
  t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 23
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', , .t.}
  blk := nil
  t_arr[BR_COLUMN] := {{'   Дата', {|| full_date(tmp->named) }, blk }, ;
                       {' Время', {|| tmp->namet }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - выход;  ^<Enter>^ - просмотр файла протокола чтения') }
  t_arr[BR_EDIT] := {|nk, ob| f2_263_from_protokol(nk, ob, 'edit') }
  edit_browse(t_arr)
  close databases
  rest_box(buf)
  return NIL

// 22.07.14
Function f2_263_from_protokol(nKey, oBrow, regim)
  Local ret := -1

  do case
    case regim == 'edit'
      if nKey == K_ENTER
        viewtext(Devide_Into_Pages(dir_server + dir_NAPR_TF + cslash+tmp->txt_f + stxt, 60, 80), , , , .t., , , 2)
      else
        keyboard ''
      endif
  endcase
  return ret

// 26.08.14 Список информационных пакетов с полученными направлениями от поликлиник
Function _263_from_I01()
  Static str_sem := '263_from_I01'
  Local buf := save_maxrow(), blk, t_arr[BR_LEN]

  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  G_Use(dir_server + 'mo_nfile', , 'NF')
  index on dtos(date_r) +upper(name_f) to (cur_dir + 'tmp_nf') ;
      for in_out == 2 .and. tip_f == 1 DESCENDING
  go top
  if eof()
    close databases
    G_SUnLock(str_sem)
    return func_error(4, 'Пока не было чтения информационных пакетов I01 из ТФОМС')
  endif
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow() - 5
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_TITUL] := 'Информационные пакеты I01, полученные из ТФОМС'
  t_arr[BR_TITUL_COLOR] := 'B/BG'
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', 'N/BG, W+/N, B/BG, W+/B, R/BG, W+/R', .t.}
  blk := {|| iif(empty(nf->TWORK2), {5, 6}, ;
          iif(substr(nf->name_f, 12, 6) == glob_mo[_MO_KOD_TFOMS], {3, 4}, {1, 2})) }
  t_arr[BR_COLUMN] := {{' Имя файла', {|| nf->name_f }, blk }, ;
                       {' Отч.дата', {|| full_date(nf->date_r) }, blk }, ;
                       {' Кол.', {|| str(nf->kol, 5) }, blk }, ;
                       {'Дата и время чтения', {|| padr(f1_263_from_I01(3), 34) }, blk }}
  t_arr[BR_STEP_FUNC] := {|| f1_263_from_I01(1) }
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ выход  ^<Enter>^ просмотр') }
  t_arr[BR_EDIT] := {|nk, ob| f2_263_from_I01(nk, ob, 'edit') }
  f1_263_from_I01(0)
  edit_browse(t_arr)
  f1_263_from_I01(2)
  close databases
  G_SUnLock(str_sem)
  rest_box(buf)
  return NIL

// 26.08.14
Function f1_263_from_I01(k)
  Static buf
  Local ta[2], k1, k2

  if k == 0
    buf := box_shadow(maxrow() - 4, 0,maxrow() - 1, 79, color1, 'Полное наименование направившей поликлиники', 'B+/B')
  elseif k == 1
    perenos(ta, ret_mo(substr(nf->name_f, 12, 6))[_MO_FULL_NAME], 78)
    @ maxrow() - 3, 1 say padc(alltrim(ta[1]), 78) color color14
    @ maxrow() - 2, 1 say padc(alltrim(ta[2]), 78) color color14
  elseif k == 2
    rest_box(buf)
  elseif k == 3
    return date_8(nf->dwork) + ' ' + nf->twork1 + iif(empty(nf->TWORK2), ' ЧТЕНИЕ НЕ ЗАВЕРШЕНО', '')
  endif
  return NIL

// 26.08.14
Function f2_263_from_I01(nKey, oBrow, regim)
  Local lkod, buf, r1, rec, i, ret := -1, arr, lcodem, n1, n2, ;
        n_file := cur_dir + 'i01' + stxt, sh := 80, HH := 60, t_arr[4], s1, s2, s3, s4

  if regim == 'edit'
    do case
      case nKey == K_CTRL_F12
        if empty(nf->TWORK2)
          buf := savescreen()
          arr := {}
          aadd(arr, 'Файл ' + alltrim(nf->name_f) + ', отчётная дата ' + full_date(nf->date_r) + 'г.')
          aadd(arr, 'количество пациентов ' + lstr(nf->kol) + ' чел.')
          aadd(arr, '')
          aadd(arr, 'Аннулируется НЕДОЧИТАННЫЙ информационный пакет I01')
          aadd(arr, '')
          aadd(arr, 'После подтверждения аннулирования все последствия чтения данного')
          aadd(arr, 'файла, а также сам файл, будут удалены.')
          f_message(arr, , cColorSt2Msg, cColorSt1Msg)
          s := 'Подтвердите аннулирование информационного пакета I01'
          stat_msg(s) ; mybell(1)
          if f_Esc_Enter('аннулирования', .t.)
            mywait()
            G_Use(dir_server + 'mo_nnapr', , 'NAPR')
            index on kod to (cur_dir + 'tmp_napr') for KOD_F_1in == nf->kod
            arr := {}
            dbeval({|| aadd(arr, napr->(recno())) })
            set index to
            for i := 1 to len(arr)
              if napr->CODEM_1 == napr->S_CODEM // код поликлиники == код стационара
                G_RLock(forever)
                napr->KOD_F_1in := 0 // код файла - по файлу mo_nfile
              else
                DeleteRec(.t.)
              endif
            next
            napr->(dbCloseArea())
            select NF
            DeleteRec()
            stat_msg('Аннулирование завершено! Можете прочитать файл снова')
            mybell(2)
            go top
            ret := 1
          endif
          restscreen(buf)
        else
          func_error(4, 'Данный файл был успешно прочитан. Аннулирование запрещено!')
        endif
      case nKey == K_ENTER
        buf := save_maxrow()
        mywait()
        fp := fcreate(n_file)
        tek_stroke := 0
        n_list := 1
        add_string('')
        add_string('Файл ' + alltrim(nf->name_f) + ', отчётная дата ' + full_date(nf->date_r) + 'г.')
        add_string('количество пациентов ' + lstr(nf->kol) + ' чел.')
        add_string('')
        add_string('Это информационный пакет со сведениями о выписанных в поликлинике направлениях')
        add_string('от МО ' + charone('"', ret_mo(substr(nf->name_f, 12, 6))[_MO_SHORT_NAME]))
        R_Use(dir_server + 'kartote_', , '_KART_')
        R_Use(dir_server + 'kartotek', , '_KART')
        set relation to kod into _KART_
        R_Use(dir_server + 'mo_nnapr', , 'NAPR')
        set relation to kod_k into _KART
        index on upper(_kart->fio) + str(_kart->kod, 7) to (cur_dir + 'tmp_napr') ;
                 for KOD_F_1in == nf->kod
        i := 0
        go top
        do while !eof()
          verify_FF(HH - 5, .t., sh)
          add_string('')
          add_string(lstr(++i) + '. Направление № ' + alltrim(napr->NUM_D) + ' от ' + date_8(napr->DATE_D))
          add_string(space(3) + alltrim(_kart->fio) + ', д.р.' + full_date(_kart->date_r))
          add_string(space(3) + 'Условия оказания, в которые направляется пациент: ' + iif(napr->usl_ok_1==2,'дневной ','') + 'стационар')
          add_string(space(3) + 'Направление выдано по результатам диспансеризации/профосмотра взрослых: ' + iif(napr->disp_1==1,'нет','да'))
          add_string(space(3) + 'планируемая дата госпитализации ' + date_8(napr->DATE_H_1) + ' по диагнозу ' + alltrim(napr->DS_1))
          add_string(space(3) + inieditspr(A__MENUVERT, arr_t007, napr->PROFIL_K_1) + ;
                                     ' (' + inieditspr(A__MENUVERT, getV002(), napr->PROFIL_1) + ')')
          select NAPR
          skip
        enddo
        fclose(fp)
        _kart->(dbCloseArea())
        _kart_->(dbCloseArea())
        napr->(dbCloseArea())
        rest_box(buf)
        viewtext(n_file, , , , .t., , , 2)
        select NF
    endcase
  endif
  return ret

// Список информационных пакетов с аннулированными направлениями
Function _263_from_I03()
  
  ne_real()
  return NIL

// Список информационных пакетов с госпитализациями по направлениям
Function _263_from_I04()
  
  ne_real()
  return NIL

// Список информационных пакетов с госпитализациями без направлений (экстр.и неотл.)
Function _263_from_I05()

  ne_real()
  return NIL

// Список информационных пакетов со сведениями о выбывших пациентах
Function _263_from_I06()

  ne_real()
  return NIL

// Список информационных пакетов со сведениями о наличии свободных мест
Function _263_from_I07()

  ne_real()
  return NIL

// 20.01.16 добавим или перезапишем запись в картотеке
Function _263_add_kart(lkod_k, lfio, cFileProtokol, yes_append)
  Local s, fl_nameismo := .f., mfio := padr(upper(lfio), 50)

  DEFAULT yes_append TO .t.
  select KART
  if empty(lkod_k)
    set order to 2
    find ('1' + mfio + dtos(tmp2->BIRTHDAY))
    if found()
      lkod_k := kart->kod
    endif
  else
    goto (lkod_k)
    if !(mfio == upper(kart->fio) .and. tmp2->BIRTHDAY == kart->DATE_R)
      strfile(space(7) + 'в нашей картотеке данный пациент записан как:' + ;
            space(9) + alltrim(kart->fio) + ' д.р.' + full_date(kart->DATE_R) + ;
            hb_eol(), cFileProtokol, .t.)
      lkod_k := 0
    endif
  endif
  select KART
  set order to 1
  if empty(lkod_k)
    if yes_append
      strfile(space(7) + 'добавляем этого пациента в нашу картотеку как нового' + ;
              hb_eol(), cFileProtokol, .t.)
      Add1Rec(7)
      lkod_k := kart->kod := recno()
      kart->FIO    := lfio
      kart->DATE_R := tmp2->BIRTHDAY
    else
      return lkod_k
    endif
  else
    strfile(space(7) + 'данный пациент найден в нашей картотеке' + ;
          hb_eol(), cFileProtokol, .t.)
    goto (lkod_k)
    G_RLock(forever)
  endif
  Private mdate_r := kart->DATE_R, m1VZROS_REB := 0, M1NOVOR := 0
  fv_date_r()
  kart->pol       := iif(tmp2->SEX==1, 'М','Ж')
  kart->VZROS_REB := m1VZROS_REB
  kart->POLIS     := make_polis(tmp2->SER_P, tmp2->NUM_P)
  kart->snils     := charrem('- ', tmp2->SS)
  if TwoWordFamImOt(tmp2->SURNAME) .or. TwoWordFamImOt(tmp2->NAME) ;
                                 .or. TwoWordFamImOt(tmp2->PATRONYMIC)
    kart->MEST_INOG := 9
  else
    kart->MEST_INOG := 0
  endif
  select KART_
  do while kart_->(lastrec()) < lkod_k
    APPEND BLANK
  enddo
  goto (lkod_k)
  G_RLock(forever)
  kart_->VPOLIS    := tmp2->TYPE_P
  kart_->SPOLIS    := tmp2->SER_P
  kart_->NPOLIS    := tmp2->NUM_P
  kart_->SMO       := tmp2->SMO
  kart_->KVARTAL_D := tmp2->REG_OMS // ОКАТО субъекта РФ территории страхования
  if !empty(tmp2->TEL_M)
    kart_->PHONE_M := charrem('-', tmp2->TEL_M)
  endif
  if !empty(tmp2->TEL_F)
    kart_->PHONE_H := charrem('-', tmp2->TEL_F)
  endif
  //
  select KART2
  do while kart2->(lastrec()) < lkod_k
    APPEND BLANK
  enddo
  if !empty(tmp2->ENP)
    goto (lkod_k)
    G_RLock(forever)
    kart2->kod_mis := tmp2->ENP
  endif
  //
  select KFIO
  find (str(lkod_k, 7))
  if found()
    if kart->MEST_INOG == 9
      G_RLock(forever)
      kfio->FAM := tmp2->SURNAME
      kfio->IM  := tmp2->NAME
      kfio->OT  := tmp2->PATRONYMIC
    else
      DeleteRec(.t.)
    endif
  else
    if kart->MEST_INOG == 9
      AddRec(7)
      kfio->kod := lkod_k
      kfio->FAM := tmp2->SURNAME
      kfio->IM  := tmp2->NAME
      kfio->OT  := tmp2->PATRONYMIC
    endif
  endif
  if empty(tmp2->SMO) .and. !empty(tmp2->NAME_SMO)
    fl_nameismo := .t.
  endif
  select KSN
  find (str(lkod_k, 7))
  if found()
    if fl_nameismo
      G_RLock(forever)
      ksn->smo_name := tmp2->NAME_SMO
    else
      DeleteRec(.t.)
    endif
  else
    if fl_nameismo
      AddRec(7)
      ksn->kod := lkod_k
      ksn->smo_name := tmp2->NAME_SMO
    endif
  endif
  return lkod_k

// 14.07.14 зачитать протокол обработки информационного пакета (любого)
Function _263_protokol_tmpfile(nfile, aerr)
  Local adbf, j, oXmlDoc, oXmlNode, is_err_FLK := .f.

  adbf := { ;
          {'NAME_F', 'C', 26, 0}, ;
          {'DATE_F', 'D',  8, 0}, ;
          {'OSHIB',  'N',  3, 0}, ;  // код ошибки T008 для всего файла
          {'KOL2',   'N',  6, 0} ;   // кол-во ошибок
  }
  dbcreate(cur_dir + 'tmp1file', adbf, , .t., 'TMP1')
  append blank
  tmp1->OSHIB := -1
  //
  adbf := { ; // элементы PR
          {'OSHIB',      'N',  3, 0}, ;  // код ошибки  T008
          {'IM_POL',     'C', 20, 0}, ;  // имя поля, в котором ошибка
          {'BAS_EL',     'C', 20, 0}, ;  // имя базового элемента
          {'ID_BAS',     'C', 36, 0}, ;  // GUID базового элемента
          {'KOD_NAPR',   'N',  6, 0} ;   // код по БД направлений
  }
  dbcreate(cur_dir + 'tmp2file', adbf, , .t., 'TMP2')  // элементы PR
  if upper(right(nfile, 4)) == sxml
    // читаем файл в память
    oXmlDoc := HXMLDoc():Read(_tmp_dir1 + nfile)
    is_err_FLK := (oXmlDoc == NIL)
  endif
  if !is_err_FLK
    FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
      oXmlNode := oXmlDoc:aItems[1]:aItems[j]
      do case
        case 'NAME_F' == oXmlNode:title
          tmp1->NAME_F := mo_read_xml_tag(oXmlNode, aerr, .t.)
        case 'DATE_F' == oXmlNode:title
          tmp1->DATE_F := xml2date(mo_read_xml_tag(oXmlNode, aerr, .t.))
        case 'PR' == oXmlNode:title
          select TMP2
          append blank
          tmp2->OSHIB := val(mo_read_xml_stroke(oXmlNode, 'OSHIB', aerr))
          if tmp2->OSHIB == 0
            tmp1->OSHIB := 0
          else
            is_err_FLK := .t.
          endif
          tmp2->IM_POL := mo_read_xml_stroke(oXmlNode, 'IM_POL', aerr, .f.)
          tmp2->BAS_EL := mo_read_xml_stroke(oXmlNode, 'BAS_EL', aerr, .f.)
          tmp2->ID_BAS := mo_read_xml_stroke(oXmlNode, 'ID_BAS', aerr, .f.)
          if !empty(tmp2->BAS_EL) .and. !empty(tmp2->ID_BAS)
            tmp1->KOL2 ++
          endif
      endcase
    NEXT j
  endif
  select TMP2
  index on upper(ID_BAS) to (cur_dir + 'tmp2file')
  commit
  return is_err_FLK

// 15.01.19 зачитать информационный пакет I01
Function _263_I01_tmpfile(nfile, aerr)
  Local _table1 := { ;
                    {'VERSION',   'C',  5, 0}, ; // версия взаимодействия
                    {'DATE_F',    'D',  8, 0}, ; // дата формирования файла
                    {'NAME_F',    'C', 26, 0}, ; // имя файла
                    {'DATE_R',    'D',  8, 0}, ; // отчетная дата
                    {'KOL',       'N',  6, 0} ;  // кол-во направлений в файле
                  }
  Local _table2 := { ;
                    {'MO',        'C',  6, 0}, ; // mcod п-ки
                    {'LPU',       'C',  6, 0}, ; // codem п-ки
                    {'ID_D',      'C', 36, 0}, ; //
                    {'NUM_D',     'C', 15, 0}, ; // номер направления
                    {'DATE_D',    'D',  8, 0}, ; // дата направления
                    {'MO_H',      'C',  6, 0}, ; // mcod стационара
                    {'LPU_H',     'C',  6, 0}, ; // codem стационара
                    {'USL_OK',    'N',  1, 0}, ; //
                    {'DISP',      'N',  1, 0}, ; //
                    {'PROFIL',    'N',  3, 0}, ; // профиль медпомощи
                    {'PROFIL_K',  'N',  3, 0}, ; // профиль койки
                    {'DS',        'C',  6, 0}, ; // диагноз
                    {'IDDOKT',    'C', 16, 0}, ; // код медработника
                    {'F_MEDC',    'N',  1, 0}, ; // форма оказания медпомощи
                    {'DATE_HOSP', 'D',  8, 0}, ; // планируемая дата госпитализации
                    {'COMMENT_D', 'C', 250, 0}, ; //
                    {'SURNAME',   'C', 40, 0}, ; //
                    {'NAME',      'C', 40, 0}, ; //
                    {'PATRONYMIC','C', 40, 0}, ; //
                    {'BIRTHDAY',  'D',  8, 0}, ; //
                    {'SEX',       'N',  1, 0}, ; //
                    {'SS',        'C', 14, 0}, ; //
                    {'TYPE_P',    'N',  1, 0}, ; //
                    {'SER_P',     'C', 10, 0}, ; //
                    {'NUM_P',     'C', 20, 0}, ; //
                    {'ENP',       'C', 16, 0}, ; //
                    {'SMO',       'C',  5, 0}, ; //
                    {'NAME_SMO',  'C', 100, 0}, ; //
                    {'REG_OMS',   'C',  5, 0}, ; //
                    {'COMMENT_P', 'C', 250, 0}, ; //
                    {'TEL_M',     'C', 13, 0}, ; //
                    {'TEL_F',     'C', 13, 0} ;  //
                  }
  Local arr_f, ii, oXmlDoc, j, j1, _ar, buf := save_maxrow(), fl := .f., ;
        sMO, sLPU, oNode1, oNode2, oNode3

  //
  dbcreate(cur_dir + 'tmp1file', _table1, , .t., 'TMP1')
  append blank
  dbcreate(cur_dir + 'tmp2file', _table2, , .t., 'TMP2')
  if upper(right(nfile, 4)) == sxml
    fl := .t.
    // читаем файл в память
    oXmlDoc := HXMLDoc():Read(_tmp_dir1 + nfile)
    if oXmlDoc == NIL
      fl := func_error(4, 'Ошибка в чтении файла ' + nfile)
    endif
  endif
  if fl
    FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
      if Empty( oXmlDoc:aItems )
        fl := func_error(4, 'Ошибка в чтении файла ' + nfile)
        exit
      endif
      oXmlNode := oXmlDoc:aItems[1]:aItems[j]
      if 'ZGLV' == oXmlNode:title
        tmp1->VERSION :=          mo_read_xml_stroke(oXmlNode, 'VERSION', aerr)
        tmp1->DATE_F  := xml2date(mo_read_xml_stroke(oXmlNode, 'DATE_F', aerr))
        tmp1->NAME_F  :=          mo_read_xml_stroke(oXmlNode, 'NAME_F', aerr)
        tmp1->DATE_R  := xml2date(mo_read_xml_stroke(oXmlNode, 'DATE_R', aerr))
        tmp1->KOL     := 0
      elseif 'MO_D' == oXmlNode:title
        sMO  := mo_read_xml_stroke(oXmlNode, 'MO', aerr, .f.)
        sLPU := mo_read_xml_stroke(oXmlNode, 'LPU', aerr)
        if !empty(sLPU) .and. empty(sMO)
          sMO  := ret_mo(sLPU)[_MO_KOD_FFOMS]
        endif
        for j1 := 1 to len(oXmlNode:aitems) // последовательный просмотр
          oNode2 := oXmlNode:aItems[j1]     // т.к. направлений м.б. несколько
          if valtype(oNode2) != 'C' .AND. oNode2:title == 'DIR'
            tmp1->KOL ++
            select TMP2
            append blank
            tmp2->MO       := sMO
            tmp2->LPU      := sLPU
            tmp2->ID_D     :=          mo_read_xml_stroke(oNode2, 'ID_D', aerr)
            tmp2->NUM_D    :=          mo_read_xml_stroke(oNode2, 'NUM_D', aerr)
            tmp2->DATE_D   := xml2date(mo_read_xml_stroke(oNode2, 'DATE_D', aerr))
            tmp2->MO_H     :=          mo_read_xml_stroke(oNode2, 'MO_H', aerr)
            tmp2->LPU_H    :=          mo_read_xml_stroke(oNode2, 'LPU_H', aerr)
            tmp2->DISP     :=      val(mo_read_xml_stroke(oNode2, 'DISP', aerr, .f.))
            tmp2->USL_OK   :=      val(mo_read_xml_stroke(oNode2, 'USL_OK', aerr, .f.))
            if empty(tmp2->USL_OK) // для файлов старой версии
              tmp2->USL_OK := 1
            endif
            tmp2->PROFIL   :=      val(mo_read_xml_stroke(oNode2, 'PROFIL', aerr))
            tmp2->PROFIL_K := f_profil_k_v020_t007(mo_read_xml_stroke(oNode2, 'PROFIL_K', aerr), tmp2->PROFIL, tmp1->DATE_R)
            tmp2->DS       :=          mo_read_xml_stroke(oNode2, 'DS', aerr)
            tmp2->IDDOKT   :=          mo_read_xml_stroke(oNode2, 'IDDOKT', aerr, .f.)
            tmp2->F_MEDC   :=      val(mo_read_xml_stroke(oNode2, 'F_MEDC', aerr))
            tmp2->DATE_HOSP:= xml2date(mo_read_xml_stroke(oNode2, 'DATE_HOSP', aerr))
            tmp2->COMMENT_D:=          mo_read_xml_stroke(oNode2, 'COMMENT_D', aerr, .f.)
            if (oNode1 := oNode2:Find('PATIENT')) != NIL
              tmp2->SURNAME   :=          mo_read_xml_stroke(oNode1, 'SURNAME', aerr)
              tmp2->NAME      :=          mo_read_xml_stroke(oNode1, 'NAME', aerr)
              tmp2->PATRONYMIC:=          mo_read_xml_stroke(oNode1, 'PATRONYMIC', aerr, .f.)
              tmp2->BIRTHDAY  := xml2date(mo_read_xml_stroke(oNode1, 'BIRTHDAY', aerr))
              tmp2->SEX       :=      val(mo_read_xml_stroke(oNode1, 'SEX', aerr))
              tmp2->SS        :=          mo_read_xml_stroke(oNode1, 'SS', aerr, .f.)
              tmp2->TYPE_P    :=      val(mo_read_xml_stroke(oNode1, 'TYPE_P', aerr))
              tmp2->SER_P     :=          mo_read_xml_stroke(oNode1, 'SER_P', aerr, .f.)
              tmp2->NUM_P     :=          mo_read_xml_stroke(oNode1, 'NUM_P', aerr)
              tmp2->ENP       :=          mo_read_xml_stroke(oNode1, 'ENP', aerr, .f.)
              tmp2->SMO       :=          mo_read_xml_stroke(oNode1, 'SMO', aerr, .f.)
              tmp2->NAME_SMO  :=          mo_read_xml_stroke(oNode1, 'NAME_SMO', aerr, .f.)
              tmp2->REG_OMS   :=          mo_read_xml_stroke(oNode1, 'REG_OMS', aerr)
              tmp2->COMMENT_P :=          mo_read_xml_stroke(oNode1, 'COMMENT_P', aerr, .f.)
              if (oNode3 := oNode1:Find('CONTACT')) != NIL
                tmp2->TEL_M := mo_read_xml_stroke(oNode3, 'TEL_M', aerr, .f.)
                tmp2->TEL_F := mo_read_xml_stroke(oNode3, 'TEL_F', aerr, .f.)
              endif
            endif
          endif
        next j1
      endif
    next j
  endif
  rest_box(buf)
  return fl .and. empty(aerr)

// 19.02.17 зачитать информационный пакет I03
Function _263_I03_tmpfile(nfile, aerr)
  Local _table1 := { ;
                    {'VERSION',   'C',  5, 0}, ; // версия взаимодействия
                    {'DATE_F',    'D',  8, 0}, ; // дата формирования файла
                    {'NAME_F',    'C', 26, 0}, ; // имя файла
                    {'DATE_R',    'D',  8, 0}, ; // отчетная дата
                    {'KOL',       'N',  6, 0} ;  // кол-во направлений в файле
                  }
  Local _table2 := { ;
                    {'TYPE_S',    'N',  1, 0}, ; // тип отправителя: 1-СМО, 2-стационар, 3-поликлиника
                    {'CODE',      'C',  6, 0}, ; // регистрационный код отправителя
                    {'ID_D',      'C', 36, 0}, ; // код записи направления
                    {'MO_D',      'C',  6, 0}, ; // mcod п-ки
                    {'LPU_D',     'C',  6, 0}, ; // codem п-ки
                    {'DATE_REF',  'D',  8, 0}, ; // дата аннулирования
                    {'REASON_REF','N',  6, 0} ;  // (от 1 до 9) причина аннулирования
                  }
  Local arr_f, ii, oXmlDoc, j, j1, _ar, buf := save_maxrow(), fl := .f., ;
      sMO, sLPU, oNode1, oNode2, oNode3

  //
  dbcreate(cur_dir + 'tmp1file', _table1, , .t., 'TMP1')
  append blank
  dbcreate(cur_dir + 'tmp2file', _table2, , .t., 'TMP2')
  if upper(right(nfile, 4)) == sxml
    fl := .t.
    // читаем файл в память
    oXmlDoc := HXMLDoc():Read(_tmp_dir1 + nfile)
    if oXmlDoc == NIL
      fl := func_error(4, 'Ошибка в чтении файла ' + nfile)
    endif
  endif
  if fl
    FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
      if Empty( oXmlDoc:aItems )
        fl := func_error(4, 'Ошибка в чтении файла ' + nfile)
        exit
      endif
      oXmlNode := oXmlDoc:aItems[1]:aItems[j]
      if 'ZGLV' == oXmlNode:title
        tmp1->VERSION :=          mo_read_xml_stroke(oXmlNode, 'VERSION', aerr)
        tmp1->DATE_F  := xml2date(mo_read_xml_stroke(oXmlNode, 'DATE_F', aerr))
        tmp1->NAME_F  :=          mo_read_xml_stroke(oXmlNode, 'NAME_F', aerr)
        tmp1->DATE_R  := xml2date(mo_read_xml_stroke(oXmlNode, 'DATE_R', aerr))
        tmp1->KOL     := 0
      elseif 'SOURCE' == oXmlNode:title
        sTYPE_S := int(val(mo_read_xml_stroke(oXmlNode, 'TYPE_S', aerr)))
        sCODE   :=         mo_read_xml_stroke(oXmlNode, 'CODE', aerr)
        for j1 := 1 to len(oXmlNode:aitems) // последовательный просмотр
          oNode2 := oXmlNode:aItems[j1]     // т.к. направлений м.б. несколько
          if valtype(oNode2) != 'C' .AND. oNode2:title == 'REF_HOSP'
            tmp1->KOL ++
            select TMP2
            append blank
            tmp2->TYPE_S     := sTYPE_S
            tmp2->CODE       := sCODE
            tmp2->ID_D       :=          mo_read_xml_stroke(oNode2, 'ID_D', aerr)
            tmp2->MO_D       :=          mo_read_xml_stroke(oNode2, 'MO_D', aerr)
            tmp2->LPU_D      :=          mo_read_xml_stroke(oNode2, 'LPU_D', aerr)
            tmp2->DATE_REF   := xml2date(mo_read_xml_stroke(oNode2, 'DATE_REF', aerr))
            tmp2->REASON_REF :=      val(mo_read_xml_stroke(oNode2, 'REASON_REF', aerr))
          endif
        next j1
      endif
    next j
  endif
  rest_box(buf)
  return fl .and. empty(aerr)

// 15.01.19 зачитать информационный пакет I04 или I05
Function _263_I04_tmpfile(nfile, aerr)
  Local _table1 := { ;
                    {'VERSION',   'C',  5, 0}, ; // версия взаимодействия
                    {'DATE_F',    'D',  8, 0}, ; // дата формирования файла
                    {'NAME_F',    'C', 26, 0}, ; // имя файла
                    {'DATE_R',    'D',  8, 0}, ; // отчетная дата
                    {'KOL',       'N',  6, 0} ;  // кол-во направлений в файле
                  }
  Local _table2 := { ;
                    {'MO',        'C',  6, 0}, ; // mcod п-ки
                    {'LPU',       'C',  6, 0}, ; // codem п-ки
                    {'ID_H',      'C', 36, 0}, ; //
                    {'TYPE_H',    'N',  1, 0}, ; //
                    {'ID_D',      'C', 36, 0}, ; //
                    {'MO_D',      'C',  6, 0}, ; // mcod
                    {'LPU_D',     'C',  6, 0}, ; // codem
                    {'DATE_H',    'D',  8, 0}, ; // дата госпитализации
                    {'TIME_H',    'C',  5, 0}, ; // время госпитализации
                    {'USL_OK',    'N',  1, 0}, ; //
                    {'PROFIL',    'N',  3, 0}, ; // профиль медпомощи
                    {'PROFIL_K',  'N',  3, 0}, ; // профиль койки
                    {'DS',        'C',  6, 0}, ; // диагноз
                    {'F_MEDC',    'N',  1, 0}, ; // форма оказания медпомощи
                    {'NUM_HIST',  'C', 50, 0}, ; //
                    {'COMMENT',   'C', 250, 0}, ; //
                    {'SURNAME',   'C', 40, 0}, ; //
                    {'NAME',      'C', 40, 0}, ; //
                    {'PATRONYMIC','C', 40, 0}, ; //
                    {'BIRTHDAY',  'D',  8, 0}, ; //
                    {'SEX',       'N',  1, 0}, ; //
                    {'SS',        'C', 14, 0}, ; //
                    {'TYPE_P',    'N',  1, 0}, ; //
                    {'SER_P',     'C', 10, 0}, ; //
                    {'NUM_P',     'C', 20, 0}, ; //
                    {'ENP',       'C', 16, 0}, ; //
                    {'SMO',       'C',  5, 0}, ; //
                    {'NAME_SMO',  'C', 100, 0}, ; //
                    {'REG_OMS',   'C',  5, 0}, ; //
                    {'COMMENT_P', 'C', 250, 0}, ; //
                    {'TEL_M',     'C', 13, 0}, ; //
                    {'TEL_F',     'C', 13, 0} ;  //
                  }
  Local arr_f, ii, oXmlDoc, j, j1, _ar, buf := save_maxrow(), fl := .f., sMO, ;
      sLPU, oNode1, oNode2, oNode3
  
  //
  dbcreate(cur_dir + 'tmp1file', _table1, , .t., 'TMP1')
  append blank
  dbcreate(cur_dir + 'tmp2file', _table2, , .t., 'TMP2')
  if upper(right(nfile, 4)) == sxml
    fl := .t.
    // читаем файл в память
    oXmlDoc := HXMLDoc():Read(_tmp_dir1 + nfile)
    if oXmlDoc == NIL
      fl := func_error(4, 'Ошибка в чтении файла ' + nfile)
    endif
  endif
  if fl
    FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
      if Empty( oXmlDoc:aItems )
        fl := func_error(4, 'Ошибка в чтении файла ' + nfile)
        exit
      endif
      oXmlNode := oXmlDoc:aItems[1]:aItems[j]
      if 'ZGLV' == oXmlNode:title
        tmp1->VERSION :=          mo_read_xml_stroke(oXmlNode, 'VERSION', aerr)
        tmp1->DATE_F  := xml2date(mo_read_xml_stroke(oXmlNode, 'DATE_F', aerr))
        tmp1->NAME_F  :=          mo_read_xml_stroke(oXmlNode, 'NAME_F', aerr)
        tmp1->DATE_R  := xml2date(mo_read_xml_stroke(oXmlNode, 'DATE_R', aerr))
        tmp1->KOL     := 0
      elseif eq_any(oXmlNode:title,'MO_HOSP','MO_EXTR')
        sMO  := mo_read_xml_stroke(oXmlNode, 'MO', aerr, .f.)
        sLPU := mo_read_xml_stroke(oXmlNode, 'LPU', aerr)
        if !empty(sLPU) .and. empty(sMO)
          sMO  := ret_mo(sLPU)[_MO_KOD_FFOMS]
        endif
        for j1 := 1 to len(oXmlNode:aitems) // последовательный просмотр
          oNode2 := oXmlNode:aItems[j1]     // т.к. направлений м.б. несколько
          if valtype(oNode2) != 'C' .AND. oNode2:title == 'HOSP'
            tmp1->KOL ++
            select TMP2
            append blank
            tmp2->MO       := sMO
            tmp2->LPU      := sLPU
            tmp2->ID_H     :=          mo_read_xml_stroke(oNode2, 'ID_H', aerr)
            tmp2->TYPE_H   :=      val(mo_read_xml_stroke(oNode2, 'TYPE_H', aerr, .f.))
            tmp2->USL_OK   :=      val(mo_read_xml_stroke(oNode2, 'USL_OK', aerr, .f.))
            if empty(tmp2->USL_OK) // для файлов старой версии / или пакет I05
              tmp2->USL_OK := 1
            endif
            if empty(tmp2->TYPE_H)
              tmp2->TYPE_H := 4 // т.е. это информационный пакет I05
            endif
            tmp2->ID_D     :=          mo_read_xml_stroke(oNode2, 'ID_D', aerr, .f.)
            tmp2->MO_D     :=          mo_read_xml_stroke(oNode2, 'MO_D', aerr, .f.)
            tmp2->LPU_D    :=          mo_read_xml_stroke(oNode2, 'LPU_D', aerr, .f.)
            tmp2->DATE_H   := xml2date(mo_read_xml_stroke(oNode2, 'DATE_H', aerr))
            tmp2->TIME_H   :=          mo_read_xml_stroke(oNode2, 'TIME_H', aerr)
            if '-' $ tmp2->TIME_H
              tmp2->TIME_H := charrepl('-', tmp2->TIME_H,':') // время в моём формате
            endif
            tmp2->DS       :=          mo_read_xml_stroke(oNode2, 'DS', aerr)
            tmp2->F_MEDC   :=      val(mo_read_xml_stroke(oNode2, 'F_MEDC', aerr))
            tmp2->PROFIL   :=      val(mo_read_xml_stroke(oNode2, 'PROFIL', aerr))
            tmp2->PROFIL_K := f_profil_k_v020_t007(mo_read_xml_stroke(oNode2, 'PROFIL_K', aerr), tmp2->PROFIL, tmp1->DATE_R)
            tmp2->NUM_HIST :=          mo_read_xml_stroke(oNode2, 'NUM_HIST', aerr)
            tmp2->COMMENT  :=          mo_read_xml_stroke(oNode2, 'COMMENT', aerr, .f.)
            if (oNode1 := oNode2:Find('PATIENT')) != NIL
              tmp2->SURNAME   :=          mo_read_xml_stroke(oNode1, 'SURNAME', aerr)
              tmp2->NAME      :=          mo_read_xml_stroke(oNode1, 'NAME', aerr)
              tmp2->PATRONYMIC:=          mo_read_xml_stroke(oNode1, 'PATRONYMIC', aerr, .f.)
              tmp2->BIRTHDAY  := xml2date(mo_read_xml_stroke(oNode1, 'BIRTHDAY', aerr, .f.))
              tmp2->SEX       :=      val(mo_read_xml_stroke(oNode1, 'SEX', aerr))
              tmp2->SS        :=          mo_read_xml_stroke(oNode1, 'SS', aerr, .f.)
              tmp2->TYPE_P    :=      val(mo_read_xml_stroke(oNode1, 'TYPE_P', aerr, .f.))
              tmp2->SER_P     :=          mo_read_xml_stroke(oNode1, 'SER_P', aerr, .f.)
              tmp2->NUM_P     :=          mo_read_xml_stroke(oNode1, 'NUM_P', aerr, .f.)
              tmp2->ENP       :=          mo_read_xml_stroke(oNode1, 'ENP', aerr, .f.)
              tmp2->SMO       :=          mo_read_xml_stroke(oNode1, 'SMO', aerr, .f.)
              tmp2->NAME_SMO  :=          mo_read_xml_stroke(oNode1, 'NAME_SMO', aerr, .f.)
              tmp2->REG_OMS   :=          mo_read_xml_stroke(oNode1, 'REG_OMS', aerr, .f.)
              tmp2->COMMENT_P :=          mo_read_xml_stroke(oNode1, 'COMMENT_P', aerr, .f.)
            endif
          endif
        next j1
      endif
    next j
  endif
  rest_box(buf)
  return fl .and. empty(aerr)

// 15.01.19 зачитать информационный пакет I06
Function _263_I06_tmpfile(nfile, aerr)
  Local _table1 := { ;
                    {'VERSION',   'C',  5, 0}, ; // версия взаимодействия
                    {'DATE_F',    'D',  8, 0}, ; // дата формирования файла
                    {'NAME_F',    'C', 26, 0}, ; // имя файла
                    {'DATE_R',    'D',  8, 0}, ; // отчетная дата
                    {'KOL',       'N',  6, 0} ;  // кол-во направлений в файле
                  }
  Local _table2 := { ;
                    {'MO',        'C',  6, 0}, ; // mcod п-ки
                    {'LPU',       'C',  6, 0}, ; // codem п-ки
                    {'ID_DISCH',  'C', 36, 0}, ; //
                    {'ID_D',      'C', 36, 0}, ; //
                    {'MO_D',      'C',  6, 0}, ; // mcod
                    {'LPU_D',     'C',  6, 0}, ; // codem
                    {'DATE_H',    'D',  8, 0}, ; // дата госпитализации
                    {'DATE_D',    'D',  8, 0}, ; // дата госпитализации
                    {'USL_OK',    'N',  1, 0}, ; //
                    {'PROFIL',    'N',  3, 0}, ; // профиль медпомощи
                    {'PROFIL_K',  'N',  3, 0}, ; // профиль койки
                    {'F_MEDC',    'N',  1, 0}, ; // форма оказания медпомощи
                    {'NUM_HIST',  'C', 50, 0}, ; //
                    {'COMMENT',   'C', 250, 0}, ; //
                    {'BIRTHDAY',  'D',  8, 0}, ; //
                    {'SEX',       'N',  1, 0}, ; //
                    {'ENP',       'C', 16, 0} ;  //
                  }
  Local arr_f, ii, oXmlDoc, j, j1, _ar, buf := save_maxrow(), fl := .f., sMO, sLPU, ;
        oNode1, oNode2, oNode3

  //
  dbcreate(cur_dir + 'tmp1file', _table1, , .t., 'TMP1')
  append blank
  dbcreate(cur_dir + 'tmp2file', _table2, , .t., 'TMP2')
  if upper(right(nfile, 4)) == sxml
    fl := .t.
    // читаем файл в память
    oXmlDoc := HXMLDoc():Read(_tmp_dir1 + nfile)
    if oXmlDoc == NIL
      fl := func_error(4, 'Ошибка в чтении файла ' + nfile)
    endif
  endif
  if fl
    FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
      if Empty( oXmlDoc:aItems )
        fl := func_error(4, 'Ошибка в чтении файла ' + nfile)
        exit
      endif
      oXmlNode := oXmlDoc:aItems[1]:aItems[j]
      if 'ZGLV' == oXmlNode:title
        tmp1->VERSION :=          mo_read_xml_stroke(oXmlNode, 'VERSION', aerr)
        tmp1->DATE_F  := xml2date(mo_read_xml_stroke(oXmlNode, 'DATE_F', aerr))
        tmp1->NAME_F  :=          mo_read_xml_stroke(oXmlNode, 'NAME_F', aerr)
        tmp1->DATE_R  := xml2date(mo_read_xml_stroke(oXmlNode, 'DATE_R', aerr))
        tmp1->KOL     := 0
      elseif oXmlNode:title == 'MO_DC'
        sMO  := mo_read_xml_stroke(oXmlNode, 'MO', aerr, .f.)
        sLPU := mo_read_xml_stroke(oXmlNode, 'LPU', aerr)
        if !empty(sLPU) .and. empty(sMO)
          sMO  := ret_mo(sLPU)[_MO_KOD_FFOMS]
        endif
        for j1 := 1 to len(oXmlNode:aitems) // последовательный просмотр
          oNode2 := oXmlNode:aItems[j1]     // т.к. направлений м.б. несколько
          if valtype(oNode2) != 'C' .AND. oNode2:title == 'DISCH'
            tmp1->KOL ++
            select TMP2
            append blank
            tmp2->MO       := sMO
            tmp2->LPU      := sLPU
            tmp2->ID_DISCH :=          mo_read_xml_stroke(oNode2, 'ID_DISCH', aerr)
            tmp2->DATE_H   := xml2date(mo_read_xml_stroke(oNode2, 'DATE_H', aerr))
            tmp2->DATE_D   := xml2date(mo_read_xml_stroke(oNode2, 'DATE_D', aerr))
            tmp2->F_MEDC   :=      val(mo_read_xml_stroke(oNode2, 'F_MEDC', aerr))
            tmp2->USL_OK   :=      val(mo_read_xml_stroke(oNode2, 'USL_OK', aerr, .f.))
            if empty(tmp2->USL_OK) // для файлов старой версии
              tmp2->USL_OK := 1
            endif
            tmp2->PROFIL   :=      val(mo_read_xml_stroke(oNode2, 'PROFIL', aerr))
            tmp2->PROFIL_K := f_profil_k_v020_t007(mo_read_xml_stroke(oNode2, 'PROFIL_K', aerr), tmp2->PROFIL, tmp1->DATE_R)
            tmp2->ID_D     :=          mo_read_xml_stroke(oNode2, 'ID_D', aerr, .f.)
            tmp2->MO_D     :=          mo_read_xml_stroke(oNode2, 'MO_D', aerr, .f.)
            tmp2->LPU_D    :=          mo_read_xml_stroke(oNode2, 'LPU_D', aerr, .f.)
            tmp2->NUM_HIST :=          mo_read_xml_stroke(oNode2, 'NUM_HIST', aerr)
            tmp2->COMMENT  :=          mo_read_xml_stroke(oNode2, 'COMMENT', aerr, .f.)
            if (oNode1 := oNode2:Find('PATIENT')) != NIL
              tmp2->BIRTHDAY  := xml2date(mo_read_xml_stroke(oNode1, 'BIRTHDAY', aerr))
              tmp2->SEX       :=      val(mo_read_xml_stroke(oNode1, 'SEX', aerr))
              tmp2->ENP       :=          mo_read_xml_stroke(oNode1, 'ENP', aerr, .f.)
            endif
          endif
        next j1
      endif
    next j
  endif
  rest_box(buf)
  return fl .and. empty(aerr)

// 15.01.19 зачитать информационный пакет I07
Function _263_I07_tmpfile(nfile, aerr)
  Local _table1 := { ;
                    {'VERSION',   'C',  5, 0}, ; // версия взаимодействия
                    {'DATE_F',    'D',  8, 0}, ; // дата формирования файла
                    {'NAME_F',    'C', 26, 0}, ; // имя файла
                    {'DATE_R',    'D',  8, 0}, ; // отчетная дата
                    {'KOL',       'N',  6, 0} ;  // кол-во учреждений в файле
                  }
  Local _table2 := { ;
                    {'MO',        'C',  6, 0}, ; // mcod п-ки
                    {'LPU',       'C',  6, 0}, ; // codem п-ки
                    {'ID_PL',     'C', 36, 0}, ; // GUID записи
                    {'USL_OK',    'N',  1, 0}, ; //
                    {'PROFIL_K',  'N',  3, 0}, ; // профиль койки
                    {'PROFIL',    'N',  3, 0}, ; // профиль мед.помощи
                    {'QUANTITY',  'N',  3, 0}, ; // количество коек
                    {'Q_P',       'N',  3, 0}, ; // состояло пациентов на начало пред.суток
                    {'Q_AP',      'N',  3, 0}, ; // поступило пациентов за пред.сутки
                    {'Q_DP',      'N',  3, 0}, ; // выбыло пациентов за пред.сутки
                    {'Q_HP',      'N',  3, 0}, ; // запланировано госпитализаций на тек.день
                    {'PLACE_FREE','N',  3, 0}, ; // количество свободных мест
                    {'PF_M',      'N',  3, 0}, ; // --''-- для мужчин
                    {'PF_W',      'N',  3, 0}, ; // --''-- для женщин
                    {'PF_C',      'N',  3, 0}, ; // --''-- для детей
                    {'PLACE1',      'N', 3, 0}, ; // количество свободных мест
                    {'PF_M1',       'N', 3, 0}, ; // --''-- для мужчин
                    {'PF_W1',       'N', 3, 0}, ; // --''-- для женщин
                    {'PF_C1',       'N', 3, 0}, ; // --''-- для детей
                    {'PLACE2',      'N', 3, 0}, ; // количество свободных мест
                    {'PF_M2',       'N', 3, 0}, ; // --''-- для мужчин
                    {'PF_W2',       'N', 3, 0}, ; // --''-- для женщин
                    {'PF_C2',       'N', 3, 0}, ; // --''-- для детей
                    {'PLACE3',      'N', 3, 0}, ; // количество свободных мест
                    {'PF_M3',       'N', 3, 0}, ; // --''-- для мужчин
                    {'PF_W3',       'N', 3, 0}, ; // --''-- для женщин
                    {'PF_C3',       'N', 3, 0}, ; // --''-- для детей
                    {'PLACE4',      'N', 3, 0}, ; // количество свободных мест
                    {'PF_M4',       'N', 3, 0}, ; // --''-- для мужчин
                    {'PF_W4',       'N', 3, 0}, ; // --''-- для женщин
                    {'PF_C4',       'N', 3, 0}, ; // --''-- для детей
                    {'PLACE5',      'N', 3, 0}, ; // количество свободных мест
                    {'PF_M5',       'N', 3, 0}, ; // --''-- для мужчин
                    {'PF_W5',       'N', 3, 0}, ; // --''-- для женщин
                    {'PF_C5',       'N', 3, 0}, ; // --''-- для детей
                    {'PLACE6',      'N', 3, 0}, ; // количество свободных мест
                    {'PF_M6',       'N', 3, 0}, ; // --''-- для мужчин
                    {'PF_W6',       'N', 3, 0}, ; // --''-- для женщин
                    {'PF_C6',       'N', 3, 0}, ; // --''-- для детей
                    {'PLACE7',      'N', 3, 0}, ; // количество свободных мест
                    {'PF_M7',       'N', 3, 0}, ; // --''-- для мужчин
                    {'PF_W7',       'N', 3, 0}, ; // --''-- для женщин
                    {'PF_C7',       'N', 3, 0}, ; // --''-- для детей
                    {'PLACE8',      'N', 3, 0}, ; // количество свободных мест
                    {'PF_M8',       'N', 3, 0}, ; // --''-- для мужчин
                    {'PF_W8',       'N', 3, 0}, ; // --''-- для женщин
                    {'PF_C8',       'N', 3, 0}, ; // --''-- для детей
                    {'PLACE9',      'N', 3, 0}, ; // количество свободных мест
                    {'PF_M9',       'N', 3, 0}, ; // --''-- для мужчин
                    {'PF_W9',       'N', 3, 0}, ; // --''-- для женщин
                    {'PF_C9',       'N', 3, 0}, ; // --''-- для детей
                    {'PLACE10',     'N', 3, 0}, ; // количество свободных мест
                    {'PF_M10',      'N', 3, 0}, ; // --''-- для мужчин
                    {'PF_W10',      'N', 3, 0}, ; // --''-- для женщин
                    {'PF_C10',      'N', 3, 0}, ; // --''-- для детей
                    {'COMMENT',   'C', 250, 0}, ; //
                    {'V_H34001',  'N', 15, 0}, ; // количество госпитализаций реабилитаций СНГ
                    {'V_H34002',  'N', 15, 0}, ; // количество госпитализаций реабилитаций СНГ
                    {'V_H34006',  'N', 15, 0}, ; // количество госпитализаций реабилитаций СНГ
                    {'V_H34007',  'N', 15, 0} ; // количество госпитализаций реабилитаций СНГ
                    }
  Local arr_f, ii, oXmlDoc, j, j1, j2, ifp, d, _ar, buf := save_maxrow(), fl := .f., ;
      sMO, sLPU, oNode1, oNode2, oNode3, oNode4, ssmo, arr

  //
  dbcreate(cur_dir + 'tmp1file', _table1, , .t., 'TMP1')
  append blank
  dbcreate(cur_dir + 'tmp2file', _table2, , .t., 'TMP2')
  if upper(right(nfile, 4)) == sxml
    fl := .t.
    // читаем файл в память
    oXmlDoc := HXMLDoc():Read(_tmp_dir1 + nfile)
    if oXmlDoc == NIL
      fl := func_error(4, 'Ошибка в чтении файла ' + nfile)
    endif
  endif
  if fl
    FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
      if Empty( oXmlDoc:aItems )
        fl := func_error(4, 'Ошибка в чтении файла ' + nfile)
        exit
      endif
      oXmlNode := oXmlDoc:aItems[1]:aItems[j]
      if 'ZGLV' == oXmlNode:title
        tmp1->VERSION := mo_read_xml_stroke(oXmlNode, 'VERSION', aerr)
        tmp1->DATE_F := xml2date(mo_read_xml_stroke(oXmlNode, 'DATE_F', aerr))
        tmp1->NAME_F :=          mo_read_xml_stroke(oXmlNode, 'NAME_F', aerr)
        tmp1->DATE_R := xml2date(mo_read_xml_stroke(oXmlNode, 'DATE_R', aerr))
        tmp1->KOL    := 0
      elseif oXmlNode:title == 'MO_PLACE'
        sMO  := mo_read_xml_stroke(oXmlNode, 'MO', aerr, .f.)
        sLPU := mo_read_xml_stroke(oXmlNode, 'LPU', aerr)
        if !empty(sLPU) .and. empty(sMO)
          sMO  := ret_mo(sLPU)[_MO_KOD_FFOMS]
        endif
        for j1 := 1 to len(oXmlNode:aitems) // последовательный просмотр
          oNode2 := oXmlNode:aItems[j1]     // т.к. профилей больше одного
          if valtype(oNode2) != 'C' .AND. oNode2:title == 'PLACES'
            select TMP2
            append blank
            tmp2->MO       := sMO
            tmp2->LPU      := sLPU
            tmp2->ID_PL    :=     mo_read_xml_stroke(oNode2, 'ID_PL', aerr)
            tmp2->USL_OK   := val(mo_read_xml_stroke(oNode2, 'USL_OK', aerr, .f.))
            if empty(tmp2->USL_OK) // для файлов старой версии
              tmp2->USL_OK := 1
            endif
            tmp2->PROFIL   := val(mo_read_xml_stroke(oNode2, 'PROFIL', aerr))
            tmp2->PROFIL_K := f_profil_k_v020_t007(mo_read_xml_stroke(oNode2, 'PROFIL_K', aerr), tmp2->PROFIL, tmp1->DATE_R)
            tmp2->QUANTITY := val(mo_read_xml_stroke(oNode2, 'QUANTITY', aerr))
            tmp2->Q_P      := val(mo_read_xml_stroke(oNode2, 'Q_P', aerr))
            tmp2->Q_AP     := val(mo_read_xml_stroke(oNode2, 'Q_AP', aerr))
            tmp2->Q_DP     := val(mo_read_xml_stroke(oNode2, 'Q_DP', aerr))
            tmp2->Q_HP     := val(mo_read_xml_stroke(oNode2, 'Q_HP', aerr))
            if (oNode3 := oNode2:Find('FREE_PLACES')) != NIL
              arr := {}
              for j2 := 1 TO Len( oNode3:aItems )
                oNode4 := oNode3:aItems[j2]
                if 'ZAP' == oNode4:title
                  d := xml2date(mo_read_xml_stroke(oNode4, 'DATE_PL', aerr))
                  v1 := val(mo_read_xml_stroke(oNode4, 'PLACE_FREE', aerr))
                  v2 := val(mo_read_xml_stroke(oNode4, 'PF_M', aerr))
                  v3 := val(mo_read_xml_stroke(oNode4, 'PF_W', aerr))
                  v4 := val(mo_read_xml_stroke(oNode4, 'PF_C', aerr))
                  aadd(arr, {v1, v2, v3, v4, d})
                endif
              next j2
              asort(arr, , , {|x, y| x[5] < y[5]}) // если у других не отсортированы даты
              for j2 := 1 to min(11, len(arr))
                ifp := j2 - 1
                pole := iif(ifp == 0, 'tmp2->PLACE_FREE', 'tmp2->PLACE' + lstr(ifp))
                &pole := arr[j2, 1]
                pole := 'tmp2->PF_M' + iif(ifp == 0, '', lstr(ifp))
                &pole := arr[j2, 2]
                pole := 'tmp2->PF_W' + iif(ifp == 0, '', lstr(ifp))
                &pole := arr[j2, 3]
                pole := 'tmp2->PF_C' + iif(ifp == 0, '', lstr(ifp))
                &pole := arr[j2, 4]
              next j2
            endif
            tmp2->COMMENT := mo_read_xml_stroke(oNode2, 'COMMENT', aerr, .f.)
            for j2 := 1 to len(oNode2:aitems) // последовательный просмотр
              oNode3 := oNode2:aItems[j2]     // т.к. СМО м.б. несколько
              if valtype(oNode3) != 'C' .AND. oNode3:title == 'SMO_V'
                ssmo := alltrim(mo_read_xml_stroke(oNode3, 'SMO', aerr))
                if eq_any(ssmo, '34001', '34002', '34006', '34007')
                  &('tmp2->V_H'+ssmo) := val(mo_read_xml_stroke(oNode3, 'V_H', aerr))
                endif
              endif
            next j2
          endif
        next j1
      endif
    next j
  endif
  rest_box(buf)
  return fl .and. empty(aerr)

// 11.02.19 вернуть профиль и профиль койки в виде строк в массиве
Function _263_pr_prk(lprk, lpr, ldate_r)
  Local ar[2]

  ar[2] := f_profil_k_t007_v020(lprk, @lpr, ldate_r)
  ar[1] := lstr(lpr)
  return ar

// 11.02.19 профиль койки из t007 в v020 и в строку
Function f_profil_k_t007_v020(lprk, /*@*/lpr, ldate_r)
  Local i, lprk20 := lprk

  if ldate_r > 0d20190115 // с 16 января
    if select('T7') > 0
      t7->(dbCloseArea())
    endif
    R_Use(exe_dir + '_mo_t007', cur_dir + '_mo_t007', 'T7')
    find (str(lprk, 3) + str(lpr, 3))
    if found()
      lprk20 := t7->pk_V020
    else
      find (str(lprk, 3))
      if found()
        lprk20 := t7->pk_V020
      endif
    endif
    t7->(dbCloseArea())
    if lprk20 == 50
      lpr := 162
    elseif lprk20 == 51
      lpr := 163
    endif
  endif
  return lstr(lprk20)

// 21.01.19 профиль койки из строки в число, затем из v020 в t007
Function f_profil_k_v020_t007(sprk20, lpr, ldate_r)
  Local i, lprk, lprk20 := int(val(sprk20))

  lprk := lprk20
  if ldate_r > 0d20190115 // с 16 января
    if select('T7') > 0
      t7->(dbCloseArea())
    endif
    R_Use(exe_dir + '_mo_t007', cur_dir + '_mo_t0072', 'T7')
    find (str(lprk20, 3) + str(lpr, 3))
    if found()
      lprk := t7->profil_k
    else
      find (str(lprk20, 3))
      if found()
        lprk := t7->profil_k
      endif
    endif
    t7->(dbCloseArea())
  endif
  return lprk
