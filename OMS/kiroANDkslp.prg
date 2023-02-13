#include 'function.ch'

#define CODE_KSLP   1
#define NAME_KSLP   2
#define NAMEF_KSLP  3
#define COEF_KSLP   4

#include 'tbox.ch'

// 27.02.21
//
function buildStringKSLP(row)
  // row - одномерный массив описывающий КСЛП
  local ret

  ret := str(row[ CODE_KSLP ], 2) + '.' + row[ NAME_KSLP ]
  return ret

// 01.02.23
// функция выбора состава КСЛП, возвращает { маска,строка количества КСЛП }, или nil
function selectKSLP( lkslp, savedKSLP, dateBegin, dateEnd, DOB, mdiagnoz )
  // lkslp - значение КСЛП (выбранные КСЛП)
  // savedKSLP - сохраненное в HUMAN_2 КСЛП или пусто
  // dateBegin - дата начала законченного случая
  // dateEnd - дата окончания законченного случая
  // DOB - дата рождения пациента
  // mdiagnoz - список выбранных диагнозов

  Local mlen, t_mas := {}, ret, ;
    i, tmp_select := select()
  Local r1 := 0 // счетчик записей
  Local strArr := '', age

  Local m1var := '', s := '', countKSLP := 0
  local row, oBox
  local nLast, srok := dateEnd - dateBegin
  local recN, permissibleKSLP := {}, isPermissible
  local sAsterisk := ' * ', sBlank := '   '
  local fl := .f.

  local aKSLP := getKSLPtable( dateEnd )  // список допустимых КСЛП для услуги
  local aa := list2arr(savedKSLP) // получим массив выбранных КСЛП

  default DOB to sys_date
  default dateBegin to sys_date
  default dateEnd to sys_date

  permissibleKSLP := list2arr(lkslp)
  
  age := count_years(DOB, dateEnd)
  
  for each row in aKSLP
    r1++

    isPermissible := ascan(permissibleKSLP, row[ CODE_KSLP ]) > 0

    if (ascan(aa, {|x| x == row[ CODE_KSLP ] }) > 0) .and. isPermissible
      strArr := sAsterisk
    else
      strArr := sBlank
    endif
    if (row[ CODE_KSLP ] == 3 .and. year(dateEnd) == 2023) ;    // старше 75 лет
        .or. (row[ CODE_KSLP ] == 3 .and. year(dateEnd) == 2022) ;
        .or. (row[ CODE_KSLP ] == 1 .and. year(dateEnd) == 2021)
      if (age >= 75) .and. (year(dateEnd) == 2021) .and. isPermissible
        strArr := sAsterisk
        strArr += buildStringKSLP(row)
      elseif (age >= 75) .and. (year(dateEnd) == 2022) .and. isPermissible
        strArr += buildStringKSLP(row)
      else
        strArr := sBlank
        strArr += buildStringKSLP(row)
      endif
      aadd(t_mas, { strArr, (age >= 75), row[ CODE_KSLP ] })
    elseif ((row[ CODE_KSLP ] == 1 .and. year(dateEnd) == 2023) .or. ;
        (row[ CODE_KSLP ] == 2 .and. year(dateEnd) == 2023) .or. ;
        (row[ CODE_KSLP ] == 1 .and. year(dateEnd) == 2022) .or. ;
        (row[ CODE_KSLP ] == 2 .and. year(dateEnd) == 2022) .or. ;
        (row[ CODE_KSLP ] == 3 .and. year(dateEnd) == 2021)) ;
        .and. isPermissible  // место законному представителю
      if (age < 4)
        strArr := sAsterisk
        strArr += buildStringKSLP(row)
      elseif (age < 18)
        strArr += buildStringKSLP(row)
      else
        strArr := sBlank
        strArr += buildStringKSLP(row)
      endif
      aadd(t_mas, { strArr, (age < 18), row[ CODE_KSLP ] })
    elseif (row[ CODE_KSLP ] == 4 .and. year(dateEnd) == 2021) .and. isPermissible  // иммунизация РСВ
      if (age < 18)
        strArr += buildStringKSLP(row)
      else
        strArr := sBlank
        strArr += buildStringKSLP(row)
      endif
      aadd(t_mas, { strArr, (age < 18), row[ CODE_KSLP ] })
    elseif (row[ CODE_KSLP ] == 9 .and. year(dateEnd) == 2021) // есть сопутствующие заболевания
      fl := conditionKSLP_9_21(, DToC(DOB), DToC(dateBegin),,,, arr2SlistN(mdiagnoz),)
      if !fl
        strArr := sBlank
      else
        // strArr := sAsterisk
      endif
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, fl, row[ CODE_KSLP ] })
    elseif (row[ CODE_KSLP ] == 10 .and. year(dateEnd) == 2021) .and. isPermissible // лечение свыше 70 дней согласно инструкции
      strArr := iif(srok > 70, sAsterisk, sBlank)
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, .f., row[ CODE_KSLP ] })
    elseif (row[ CODE_KSLP ] == 19 .and. year(dateEnd) == 2023) .and. isPermissible  // проведение 1 этапа медицинской реабилитации пациентов
      strArr := sBlank
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, isPermissible, row[ CODE_KSLP ] })
    elseif (row[ CODE_KSLP ] == 20 .and. year(dateEnd) == 2023) .and. isPermissible   // проведение сопроводительной лекарственной терапии 
                                                                                      //при злокачественных новообразованиях у взрослых в 
                                                                                      // стационарных условиях в соответствии с клиническими рекомендациями
      strArr := sBlank
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, isPermissible, row[ CODE_KSLP ] })
    else
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, isPermissible, row[ CODE_KSLP ] })
    endif
  next

  strStatus := '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - отметить / снять отметку'

  mlen := len(t_mas)

  // используем popupN из библиотеки FunLib
    // if (ret := popupN(5,10,15,71,t_mas,i,color0,.t.,'fmenu_readerN',,;
  if (ret := popupN(5, 10, 5 + mlen + 1, 71, t_mas, i, color0, .t., 'fmenu_readerN', , ;
      'Отметьте КСЛП', col_tit_popup,, strStatus)) > 0
    for i := 1 to mlen
      if '*' == substr(t_mas[i, 1],2,1)
        m1var += alltrim(str(t_mas[i, 3])) + ','
        countKSLP += 1
      endif
    next
    if (nLast := RAt(',', m1var)) > 0
      m1var := substr(m1var, 1, nLast - 1)  // удалим последнюю не нужную ','
    endif
    s := m1var
  endif 

  Select(tmp_select)
  Return s

** 13.01.22 если надо, перезаписать значения КСЛП и КИРО в HUMAN_2
Function put_str_kslp_kiro(arr,fl)
  Local lpc1 := '', lpc2 := ''

  if len(arr) > 4 .and. !empty(arr[5])
    if year(human->k_data) < 2021  // added 29.01.21
      lpc1 := lstr(arr[5, 1]) + ',' + lstr(arr[5, 2], 5, 2)
      if len(arr[5]) >= 4
        lpc1 += ',' + lstr(arr[5, 3]) + ',' + lstr(arr[5, 4], 5, 2)
      endif
    endif
  endif
  if len(arr) > 5 .and. !empty(arr[6])
    lpc2 := lstr(arr[6, 1]) + ',' + lstr(arr[6, 2], 5, 2)
  endif
  if !(padr(lpc1, 20) == human_2->pc1 .and. padr(lpc2, 10) == human_2->pc2)
    DEFAULT fl TO .t. // блокировать и разблокировать запись в HUMAN_2
    select HUMAN_2
    if fl
      G_RLock(forever)
    endif

    // запомним новое КСЛП
    tmSel := select('HUMAN_2')
    if (tmSel)->(dbRlock())
      if year(human->k_data) < 2021  // added 29.01.21
        human_2->pc1 := lpc1
      endif
      human_2->pc2 := lpc2
      (tmSel)->(dbRUnlock())
    endif
    select(tmSel)
    if fl
      UnLock
    endif
  endif
  return NIL

** 04.02.21
// возвращает сумму итогового КСЛП по маске КСЛП и дате случая
function calcKSLP(cKSLP, dateSl)
  // cKSLP - строка выбранных КСЛП
  // dateSl - дата законченного случая
  local summ := 1, i
  local fl := .f.
  local arrKSLP := getKSLPtable( dateSl )
  Local maxKSLP := 1.8  // по инструкции на 21 год
  local aSelected := Slist2arr(cKSLP)

  for i := 1 to len(aSelected)
    summ += (arrKSLP[val(aSelected[i]), 4] - 1)
  next
  if summ > maxKSLP
    summ := maxKSLP
  endif
  return summ

** 13.02.23
function defenition_KIRO(lkiro, ldnej, lrslt, lis_err, lksg)
  // lkiro - список возможных КИРО для КСГ
  // ldnej - длительность случая в койко-днях
  // lrslt - результат обращения (справочник V009)
  // lis_err - ошибка (какая-то)
  // lksg - шифр КСГ
  local vkiro := 0
  local cKSG := alltrim(LTrim(lksg))

  if eq_any(cKSG, 'st37.002', 'st37.003', 'st37.006', 'st37.007', 'st37.024', 'st37.025', 'st37.026')
    // КСГ по услугам мед. реабилитации в стационаре согласно Служебная записка Мызгина от 13.02.23
    if (cKSG == 'st37.002' .and. ldnej < 14) .or. ;
        (cKSG == 'st37.003' .and. ldnej < 20) .or. ;
        (cKSG == 'st37.006' .and. ldnej < 12) .or. ;
        (cKSG == 'st37.007' .and. ldnej < 18) .or. ;
        ((cKSG == 'st37.024' .or. cKSG == 'st37.025' .or. cKSG == 'st37.026') .and. ldnej < 30)
      vkiro := 4
    endif
  else  // все другое
    if ldnej < 4  // длительность случая 3 койко-дня и менее
      if ascan(lkiro, 1) > 0
        vkiro := 1
      elseif ascan(lkiro, 2) > 0
        vkiro := 2
      elseif lis_err == 1 .and. ascan(lkiro, 5) > 0 // добавляем ещё несоблюдение схемы химиотерапии (КИРО=5)
        vkiro := 5
      endif
    else          // длительность случая 4 койко-дня и более
      if ascan({102, 105, 107, 110, 202, 205, 207}, lrslt) > 0
        if ascan(lkiro, 3) > 0
          vkiro := 3
        elseif ascan(lkiro, 4) > 0
          vkiro := 4
        elseif lis_err == 1 .and. ascan(lkiro, 6) > 0 // добавляем ещё несоблюдение схемы химиотерапии (КИРО=6)
          vkiro := 6
        endif
      endif
    endif
  endif
  return vkiro

** 30.11.21
Function f_cena_kiro(/*@*/_cena, lkiro, dateSl )
  // _cena - изменяемая цена
  // lkiro - уровень КИРО
  // dateSl - дата случая
  Local _akiro := {0, 1}
  local aKIRO, rowKIRO

  aKIRO := getKIROtable( dateSl )
  for each rowKIRO in aKIRO
    if rowKIRO[1] == lkiro
      if between_date(rowKIRO[5], rowKIRO[6], dateSl)
        _akiro := { lkiro, rowKIRO[4] }
      endif
    endif
  next

  _cena := round_5(_cena * _akiro[2], 0)  // округление до рублей с 2019 года
  return _akiro

** 01.02.23 определить коэф-т сложности лечения пациента и пересчитать цену
Function f_cena_kslp(/*@*/_cena, _lshifr, _date_r, _n_data, _k_data, lkslp, arr_usl, lPROFIL_K, arr_diag, lpar_org, lad_cr)
  Static s_1_may := 0d20160430, s_18 := 0d20171231, s_19 := 0d20181231
  static s_20 := 0d20201231
  Static s_kslp17 := { ;
    {1, 1.1, 0,  3}, ;   // до 4 лет
    {2, 1.1, 75, 999} ;    // 75 лет и старше
   }
  Static s_kslp16 := { ;
    {1, 1.1 , 0,  3}, ;   // до 4 лет
    {2, 1.05, 75, 999} ;    // 75 лет и старше
   }
  Local i, j, vksg, y := 0, fl, ausl := {}, s_kslp, _akslp := {}, sop_diag
  local countDays := _k_data - _n_data // кол-во дней лечения

  local savedKSLP, newKSLP := '', nLast
  local nameFunc := '', argc, row

  DEFAULT lad_cr TO space(10)

  _lshifr := alltrim(_lshifr) // перенес

  if _k_data > s_20
    if empty(lkslp)
      return _akslp
    endif
    // п.3 инструкции
    // Возраст пациента определяется на момент поступления на стационарное лечение.
    // Все случаи применения КСЛП (за исключением КСЛП1) подвергаются экспертному контролю.
    count_ymd( _date_r, _n_data, @y )
    lkslp := list2arr(lkslp)  // преобразуем строку допустимых КСЛП в массив

    savedKSLP := iif(empty(HUMAN_2->PC1), '"' + '"', '"' + alltrim(HUMAN_2->PC1) + '"')  // получим сохраненные КСЛП

    // argc := '(' + savedKSLP + ',' + ;
    // "'" + dtoc(_date_r) + "'," + "'" + dtoc(_n_data) + "'," + ;
    // lstr(lPROFIL_K) + ',' + "'" + _lshifr + "'," + lstr(lpar_org) + ',' + ;
    // "'" + arr2SlistN(arr_diag) + "'," + lstr(countDays) + ')'
    argc := '(' + savedKSLP + ',' + ;
    '"' + dtoc(_date_r) + '",' + '"' + dtoc(_k_data) + '",' + ;
    lstr(lPROFIL_K) + ',' + '"' + _lshifr + '",' + lstr(lpar_org) + ',' + ;
    '"' + arr2SlistN(arr_diag) + '",' + lstr(countDays) + ')'

    for each row in getKSLPtable( _k_data )
      // nameFunc := 'conditionKSLP_' + alltrim(str(row[1],2)) + '_' + last_digits_year(_n_data)
      nameFunc := 'conditionKSLP_' + alltrim(str(row[1],2)) + '_' + last_digits_year(_k_data)
      nameFunc := namefunc + argc

      if ascan( lkslp, row[1]) > 0 .and. &nameFunc
        newKSLP += alltrim(str(row[1], 2)) + ','
        aadd(_akslp, row[1])
        aadd(_akslp, row[4])
      endif
    next
    if (nLast := RAt(',', newKSLP)) > 0
      newKSLP := substr(newKSLP, 1, nLast - 1)  // удалим последнюю не нужную ','
    endif
    // установим цену с учетом КСЛП
    if !empty(_akslp)

      if year(_k_data) == 2021
        _cena := round_5(_cena * ret_koef_kslp_21(_akslp, year(_k_data)), 0)  // с 2019 года цена округляется до рублей
      elseif year(_k_data) == 2022
        // на 2022 базовая ставка стационарного случая 24322,6 руб
        // на 2022 базовая ставка для случая дневного стационара 13915,7 руб
        _cena := round_5(_cena + 24322.6 * ret_koef_kslp_21(_akslp, year(_k_data)), 0)
      elseif year(_k_data) == 2023  // сообщил Мызгин 01.02.23
        // на 2023 базовая ставка стационарного случая 25986,7 руб
        // на 2023 базовая ставка для случая дневного стационара 15029,1 руб 
        _cena := round_5(_cena + 25986.7 * ret_koef_kslp_21(_akslp, year(_k_data)), 0)
      endif
      
      if year(_k_data) >= 2021
        // запомним новое КСЛП
        tmSel := select('HUMAN_2')
        if (tmSel)->(dbRlock())
          if year(human->k_data) < 2021  // added 29.01.21
            human_2->pc1 := newKSLP
          endif
          (tmSel)->(dbRUnlock())
        endif
        select(tmSel)
      endif
    endif

  elseif _k_data > s_19  // с 2019 года
    if !empty(lkslp)
      if _lshifr == 'ds02.005' // ЭКО, lkslp = 12,13,14
        s_kslp := { ;
          {12, 0.60}, ;
          {13, 1.10}, ;
          {14, 0.19} ;
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == 'A'
            aadd(ausl, alltrim(arr_usl[i, 1]))  // массив многомерный
          else
            aadd(ausl, alltrim(arr_usl[i]))    // массив одномерный
          endif
        next i
        j := 0 // КСЛП - 1 схема
        if ascan(ausl, 'A11.20.031') > 0  // крио
          j := 13  // 6 схема
          if ascan(ausl, 'A11.20.028') > 0 // третий этап
            j := 0   // 2 схема
          endif
        elseif ascan(ausl, 'A11.20.025.001') > 0  // первый этап
          j := 12  // 3 схема
          if ascan(ausl, 'A11.20.036') > 0  // завершающий второй этап
            j := 12  // 4 схема
          elseif ascan(ausl, 'A11.20.028') > 0  // завершающий третий этап
            j := 12  // 5 схема
          endif
        elseif ascan(ausl, 'A11.20.030.001') > 0  // только четвертый этап
          j := 14  // 7 схема
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp, s_kslp[i, 1])
          aadd(_akslp, s_kslp[i, 2])
          _cena := round_5(_cena * s_kslp[i, 2], 0)  // с 2019 года цена округляется до рублей
        endif
        if !empty(_akslp) .and. _k_data > 0d20191231 // с 2020 года
          _akslp[1] += 3 // т.е. с 2020 года КСЛП для ЭКО 15,16,17
        endif
      else // остальные КСГ
        s_kslp := { ;
          { 1, 1.10, 0,  0}, ;  // до 1 года
          { 2, 1.10, 1,  3}, ;  // от 1 до 3 лет включительно
          { 4, 1.02, 75, 999}, ;  // 75 и старше
          { 5, 1.10, 60, 999} ;   // 60 и старше и астения
        }
        count_ymd(_date_r, _n_data, @y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0 // стоит данный КСЛП в выбранной КСГ
            if between(y, s_kslp[i, 3], s_kslp[i, 4])
              fl := .t.
              if lkslp[j] == 4
                fl := (lprofil_k != 16 ; // пациент лежит не на геронтологической койке
                        .and. !(_lshifr == 'st38.001'))
              elseif lkslp[j] == 5
                sop_diag := aclone(arr_diag)
                del_array(sop_diag, 1)
                fl := (lprofil_k == 16 .and. ; // пациент лежит на геронтологической койке
                        !(_lshifr == 'st38.001') .and. ;//!(alltrim(arr_diag[1]) == 'R54') .and. ; // с основным диагнозом не <R54-старость>
                        ascan(sop_diag, {|x| alltrim(x) == 'R54'}) > 0 ) // в соп.диагнозах есть <R54-старость>
              endif
              if fl
                aadd(_akslp, s_kslp[i, 1])
                aadd(_akslp, s_kslp[i, 2])
                exit
              endif
            endif
          endif
        next
        if ascan(lkslp, 11) > 0 .and. lpar_org > 1 // разрешена КСЛП=11 и введены парные органы
          aadd(_akslp, 11)
          aadd(_akslp, 1.2)
        endif
        if ascan(lkslp, 18) > 0 .and. 'cr6' $ lad_cr // разрешена КСЛП=18 и для сложного COVID-19
          aadd(_akslp, 18)
          aadd(_akslp, 1.2)
        endif
        if !empty(_akslp)
          _cena := round_5(_cena * ret_koef_kslp(_akslp), 0)  // с 2019 года цена округляется до рублей
        endif
      endif
    endif
  elseif _k_data > s_18  // с 2018 года
    if !empty(lkslp)
      if _lshifr == '2005.0' // ЭКО, lkslp = 12,13,14
        s_kslp := { ;
          {12, 0.60}, ;
          {13, 1.10}, ;
          {14, 0.19} ;
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == 'A'
            aadd(ausl, alltrim(arr_usl[i, 1]))  // массив многомерный
          else
            aadd(ausl, alltrim(arr_usl[i]))    // массив одномерный
          endif
        next i
        j := 0 // КСЛП - 1 схема
        if ascan(ausl, 'A11.20.031') > 0  // крио
          j := 13  // 6 схема
          if ascan(ausl, 'A11.20.028') > 0 // третий этап
            j := 0   // 2 схема
          endif
        elseif ascan(ausl, 'A11.20.025.001') > 0  // первый этап
          j := 12  // 3 схема
          if ascan(ausl, 'A11.20.036') > 0  // завершающий второй этап
            j := 12  // 4 схема
          elseif ascan(ausl, 'A11.20.028') > 0  // завершающий третий этап
            j := 12  // 5 схема
          endif
        elseif ascan(ausl, 'A11.20.030.001') > 0  // только четвертый этап
          j := 14  // 7 схема
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp, s_kslp[i, 1])
          aadd(_akslp, s_kslp[i, 2])
          _cena := round_5(_cena * s_kslp[i, 2], 1)
        endif
      else // остальные КСГ
        s_kslp := { ;
          { 1, 1.10, 0,  0}, ;  // до 1 года
          { 2, 1.10, 1,  3}, ;  // от 1 до 3 лет включительно
          { 4, 1.05, 75, 999}, ;  // 75 и старше
          { 5, 1.10, 60, 999} ;   // 60 и старше и астения
        }
        count_ymd(_date_r, _n_data, @y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0
            if between(i, 1, 5) .and. between(y, s_kslp[i, 3], s_kslp[i, 4])
              aadd(_akslp, s_kslp[i, 1])
              aadd(_akslp, s_kslp[i, 2])
              _cena := round_5(_cena * s_kslp[i, 2], 1)
              exit
            endif
          endif
        next
      endif
    endif
  elseif _k_data > s_1_may ;                 // с 1 мая 2016 года
              .and. left(_lshifr,1) == '1' ; // круглосуточный стационар
              .and. !('.' $ _lshifr)         // это шифр КСГ
    count_ymd(_date_r, _n_data, @y)
    vksg := int(val(right(_lshifr, 3))) // последние три цифры - код КСГ
    if (fl := vksg < 900) // не диализ
      if year(_k_data) > 2016
        s_kslp := s_kslp17
        if y < 1 .and. between(vksg, 105, 111) // до 1 года и малая масса при рождении
          fl := .f.
        endif
      else
        s_kslp := s_kslp16
      endif
      if fl
        for i := 1 to len(s_kslp)
          if between(y, s_kslp[i, 3], s_kslp[i, 4])
            aadd(_akslp, s_kslp[i, 1])
            aadd(_akslp, s_kslp[i, 2])
            _cena := round_5(_cena * s_kslp[i, 2], 1)
            exit
          endif
        next
      endif
    endif
  endif
  return _akslp
  
** 23.01.19 вернуть итоговый КСЛП
Function ret_koef_kslp(akslp)
  Local k := 1
  if valtype(akslp) == 'A' .and. len(akslp) >= 2
    k := akslp[2]
    if len(akslp) >= 4
      k += akslp[4] - 1
    endif
  endif
  return k
  
  
//** 08.02.22 вернуть итоговый КСЛП для 21 года
** 01.02.23 вернуть итоговый КСЛП для 21 года
Function ret_koef_kslp_21(akslp, nYear)
  Local k := 1  // КСЛП равен 1

  if valtype(akslp) == 'A' .and. len(akslp) >= 2
    if nYear == 2021
      for i := 1 TO len(akslp) STEP 2
        if i == 1
          k := akslp[2]
        else
          k += (akslp[i + 1] - 1)
        endif
      next
      if k > 1.8
        k := 1.8  // согласно п.3 инструкции
      endif
    // elseif nYear == 2022
    elseif nYear >= 2022
      k := 0
      for i := 1 TO len(akslp) STEP 2
        if i == 1 // возможно только одно КСЛП
          k += akslp[2]
        // else
        //   k += akslp[i + 1]
        endif
      next
    endif
  endif
  return k

** 01.02.23 вернуть итоговый КСЛП для конкретного года
Function ret_koef_kslp_21_XML(akslp, tKSLP, nYear)
  Local k := 1  // КСЛП равен 1
  local iAKSLP

  if valtype(akslp) == 'A'
    if nYear == 2021
      for iAKSLP := 1 to len(akslp)
        if (cKSLP := ascan(tKSLP, {|x| x[1] == akslp[ iAKSLP ] })) > 0
          k += (tKSLP[ cKSLP, 4 ] - 1)
        endif
      next
      if k > 1.8
        k := 1.8  // согласно п.3 инструкции
      endif
    elseif nYear >= 2022
      k := 0
      for iAKSLP := 1 to len(akslp)
        if (cKSLP := ascan(tKSLP, {|x| x[1] == akslp[ iAKSLP ] })) > 0
          k += tKSLP[ cKSLP, 4 ]
        endif
      next
    endif
  endif
  return k
