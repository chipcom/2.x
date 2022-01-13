#include "function.ch"

#define CODE_KSLP   1
#define NAME_KSLP   2
#define NAMEF_KSLP  3
#define COEF_KSLP   4

#include "tbox.ch"

// 27.02.21
//
function buildStringKSLP(row)
  // row - одномерный массив описывающий КСЛП
  local ret

  ret := str(row[ CODE_KSLP ], 2) + '.' + row[ NAME_KSLP ]
  return ret

// 27.02.21
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

  Local m1var := '', s := "", countKSLP := 0
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

    if row[ CODE_KSLP ] == 1  // старше 75 лет
      if (age >= 75) .and. isPermissible
        strArr := sAsterisk
      else
        strArr := sBlank
      endif
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, .f., row[ CODE_KSLP ] })
    elseif row[ CODE_KSLP ] == 3 .and. isPermissible  // место законному представителю
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
    elseif row[ CODE_KSLP ] == 4 .and. isPermissible  // иммунизация РСВ
      if (age < 18)
        strArr += buildStringKSLP(row)
      else
        strArr := sBlank
        strArr += buildStringKSLP(row)
      endif
      aadd(t_mas, { strArr, (age < 18), row[ CODE_KSLP ] })
    elseif row[ CODE_KSLP ] == 9 // есть сопутствующие заболевания
      fl := conditionKSLP_9_21(, DToC(DOB), DToC(dateBegin),,,, arr2SlistN(mdiagnoz),)
      if !fl
        strArr := sBlank
      else
        // strArr := sAsterisk
      endif
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, fl, row[ CODE_KSLP ] })
    elseif row[ CODE_KSLP ] == 10 .and. isPermissible // лечение свыше 70 дней согласно инструкции
      strArr := iif(srok > 70, sAsterisk, sBlank)
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, .f., row[ CODE_KSLP ] })
    else
      strArr += buildStringKSLP(row)
      aadd(t_mas, { strArr, isPermissible, row[ CODE_KSLP ] })
    endif
  next

  strStatus := '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - отметить / снять отметку'

  mlen := len(t_mas)

  // используем popupN из библиотеки FunLib
    // if (ret := popupN(5,10,15,71,t_mas,i,color0,.t.,"fmenu_readerN",,;
  if (ret := popupN(5, 10, 5 + mlen + 1, 71, t_mas, i, color0, .t., 'fmenu_readerN',,;
      'Отметьте КСЛП', col_tit_popup,, strStatus)) > 0
    for i := 1 to mlen
      if "*" == substr(t_mas[i, 1],2,1)
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

***** 13.01.22 если надо, перезаписать значения КСЛП и КИРО в HUMAN_2
Function put_str_kslp_kiro(arr,fl)
  Local lpc1 := "", lpc2 := ""

  if len(arr) > 4 .and. !empty(arr[5])
    if year(human->k_data) < 2021  // added 29.01.21
      lpc1 := lstr(arr[5,1])+","+lstr(arr[5,2],5,2)
      if len(arr[5]) >= 4
        lpc1 += ","+lstr(arr[5,3])+","+lstr(arr[5,4],5,2)
      endif
    endif
  endif
  if len(arr) > 5 .and. !empty(arr[6])
    lpc2 := lstr(arr[6,1])+","+lstr(arr[6,2],5,2)
  endif
  if !(padr(lpc1,20) == human_2->pc1 .and. padr(lpc2,10) == human_2->pc2)
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

***** 04.02.21
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

***** 30.11.21 
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

***** 13.01.22 определить коэф-т сложности лечения пациента и пересчитать цену
Function f_cena_kslp(/*@*/_cena,_lshifr,_date_r,_n_data,_k_data,lkslp,arr_usl,lPROFIL_K,arr_diag,lpar_org,lad_cr)
  Static s_1_may := 0d20160430, s_18 := 0d20171231, s_19 := 0d20181231
  static s_20 := 0d20201231
  Static s_kslp17 := {;
    {1,1.1, 0,  3},;   // до 4 лет
    {2,1.1,75,999};    // 75 лет и старше
   }
  Static s_kslp16 := {;
    {1,1.1 , 0,  3},;   // до 4 лет
    {2,1.05,75,999};    // 75 лет и старше
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

    savedKSLP := iif(empty(HUMAN_2->PC1), "'"+"'", "'" + alltrim(HUMAN_2->PC1) + "'")  // получим сохраненные КСЛП

    argc := '(' + savedKSLP + ',' + ;
    "'" + dtoc(_date_r) + "'," + "'" + dtoc(_n_data) + "'," + ;
    lstr(lPROFIL_K) + ',' + "'" + _lshifr + "'," + lstr(lpar_org) + ',' + ;
    "'" + arr2SlistN(arr_diag) + "'," + lstr(countDays) + ')'

    for each row in getKSLPtable( _k_data )
      nameFunc := 'conditionKSLP_' + alltrim(str(row[1],2)) + '_21'
      nameFunc := namefunc + argc

      if ascan( lkslp, row[1]) > 0 .and. &nameFunc
        newKSLP += alltrim(str(row[1],2)) + ','
        aadd(_akslp, row[1])
        aadd(_akslp,row[4])
      endif
    next
    if (nLast := RAt(',', newKSLP)) > 0
      newKSLP := substr(newKSLP, 1, nLast - 1)  // удалим последнюю не нужную ','
    endif

    // установим цену с учетом КСЛП
    if !empty(_akslp)
      _cena := round_5(_cena*ret_koef_kslp_21(_akslp),0)  // с 2019 года цена округляется до рублей
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
      if _lshifr == "ds02.005" // ЭКО, lkslp = 12,13,14
        s_kslp := {;
          {12,0.60},;
          {13,1.10},;
          {14,0.19};
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == "A"
            aadd(ausl,alltrim(arr_usl[i,1]))  // массив многомерный
          else
            aadd(ausl,alltrim(arr_usl[i]))    // массив одномерный
          endif
        next i
        j := 0 // КСЛП - 1 схема
        if ascan(ausl,"A11.20.031") > 0  // крио
          j := 13  // 6 схема
          if ascan(ausl,"A11.20.028") > 0 // третий этап
            j := 0   // 2 схема
          endif
        elseif ascan(ausl,"A11.20.025.001") > 0  // первый этап
          j := 12  // 3 схема
          if ascan(ausl,"A11.20.036") > 0  // завершающий второй этап
            j := 12  // 4 схема
          elseif ascan(ausl,"A11.20.028") > 0  // завершающий третий этап
            j := 12  // 5 схема
          endif
        elseif ascan(ausl,"A11.20.030.001") > 0  // только четвертый этап
          j := 14  // 7 схема
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp,s_kslp[i,1])
          aadd(_akslp,s_kslp[i,2])
          _cena := round_5(_cena*s_kslp[i,2],0)  // с 2019 года цена округляется до рублей
        endif
        if !empty(_akslp) .and. _k_data > 0d20191231 // с 2020 года
          _akslp[1] += 3 // т.е. с 2020 года КСЛП для ЭКО 15,16,17
        endif
      else // остальные КСГ
        s_kslp := {;
          { 1,1.10, 0,  0},;  // до 1 года
          { 2,1.10, 1,  3},;  // от 1 до 3 лет включительно
          { 4,1.02,75,999},;  // 75 и старше
          { 5,1.10,60,999};   // 60 и старше и астения
        }
        count_ymd(_date_r,_n_data,@y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0 // стоит данный КСЛП в выбранной КСГ
            if between(y,s_kslp[i,3],s_kslp[i,4])
              fl := .t.
              if lkslp[j] == 4
                fl := (lprofil_k != 16 ; // пациент лежит не на геронтологической койке
                        .and. !(_lshifr == "st38.001"))
              elseif lkslp[j] == 5
                sop_diag := aclone(arr_diag)
                del_array(sop_diag,1)
                fl := (lprofil_k == 16 .and. ; // пациент лежит на геронтологической койке
                        !(_lshifr == "st38.001") .and. ;//!(alltrim(arr_diag[1]) == "R54") .and. ; // с основным диагнозом не <R54-старость>
                        ascan(sop_diag, {|x| alltrim(x) == "R54"}) > 0 ) // в соп.диагнозах есть <R54-старость>
              endif
              if fl
                aadd(_akslp,s_kslp[i,1])
                aadd(_akslp,s_kslp[i,2])
                exit
              endif
            endif
          endif
        next
        if ascan(lkslp,11) > 0 .and. lpar_org > 1 // разрешена КСЛП=11 и введены парные органы
          aadd(_akslp,11)
          aadd(_akslp,1.2)
        endif
        if ascan(lkslp,18) > 0 .and. "cr6" $ lad_cr // разрешена КСЛП=18 и для сложного COVID-19
          aadd(_akslp,18)
          aadd(_akslp,1.2)
        endif
        if !empty(_akslp)
          _cena := round_5(_cena*ret_koef_kslp(_akslp),0)  // с 2019 года цена округляется до рублей
        endif
      endif
    endif
  elseif _k_data > s_18  // с 2018 года
    if !empty(lkslp)
      if _lshifr == "2005.0" // ЭКО, lkslp = 12,13,14
        s_kslp := {;
          {12,0.60},;
          {13,1.10},;
          {14,0.19};
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == "A"
            aadd(ausl,alltrim(arr_usl[i,1]))  // массив многомерный
          else
            aadd(ausl,alltrim(arr_usl[i]))    // массив одномерный
          endif
        next i
        j := 0 // КСЛП - 1 схема
        if ascan(ausl,"A11.20.031") > 0  // крио
          j := 13  // 6 схема
          if ascan(ausl,"A11.20.028") > 0 // третий этап
            j := 0   // 2 схема
          endif
        elseif ascan(ausl,"A11.20.025.001") > 0  // первый этап
          j := 12  // 3 схема
          if ascan(ausl,"A11.20.036") > 0  // завершающий второй этап
            j := 12  // 4 схема
          elseif ascan(ausl,"A11.20.028") > 0  // завершающий третий этап
            j := 12  // 5 схема
          endif
        elseif ascan(ausl,"A11.20.030.001") > 0  // только четвертый этап
          j := 14  // 7 схема
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp,s_kslp[i,1])
          aadd(_akslp,s_kslp[i,2])
          _cena := round_5(_cena*s_kslp[i,2],1)
        endif
      else // остальные КСГ
        s_kslp := {;
          { 1,1.10, 0,  0},;  // до 1 года
          { 2,1.10, 1,  3},;  // от 1 до 3 лет включительно
          { 4,1.05,75,999},;  // 75 и старше
          { 5,1.10,60,999};   // 60 и старше и астения
        }
        count_ymd(_date_r,_n_data,@y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0
            if between(i,1,5) .and. between(y,s_kslp[i,3],s_kslp[i,4])
              aadd(_akslp,s_kslp[i,1])
              aadd(_akslp,s_kslp[i,2])
              _cena := round_5(_cena*s_kslp[i,2],1)
              exit
            endif
          endif
        next
      endif
    endif
  elseif _k_data > s_1_may ;                 // с 1 мая 2016 года
              .and. left(_lshifr,1) == '1' ; // круглосуточный стационар
              .and. !("." $ _lshifr)         // это шифр КСГ
    count_ymd(_date_r,_n_data,@y)
    vksg := int(val(right(_lshifr,3))) // последние три цифры - код КСГ
    if (fl := vksg < 900) // не диализ
      if year(_k_data) > 2016
        s_kslp := s_kslp17
        if y < 1 .and. between(vksg,105,111) // до 1 года и малая масса при рождении
          fl := .f.
        endif
      else
        s_kslp := s_kslp16
      endif
      if fl
        for i := 1 to len(s_kslp)
          if between(y,s_kslp[i,3],s_kslp[i,4])
            aadd(_akslp,s_kslp[i,1])
            aadd(_akslp,s_kslp[i,2])
            _cena := round_5(_cena*s_kslp[i,2],1)
            exit
          endif
        next
      endif
    endif
  endif
  return _akslp
  
***** 23.01.19 вернуть итоговый КСЛП
Function ret_koef_kslp(akslp)
  Local k := 1
  if valtype(akslp) == "A" .and. len(akslp) >= 2
    k := akslp[2]
    if len(akslp) >= 4
      k += akslp[4] - 1
    endif
  endif
  return k
  
  
  ***** 26.01.21 вернуть итоговый КСЛП для 21 года
Function ret_koef_kslp_21(akslp)
  Local k := 1  // КСЛП равен 1

  if valtype(akslp) == "A" .and. len(akslp) >= 2
    for i := 1 TO len(akslp) STEP 2
      if i == 1
        k := akslp[2]
      else
        k += (akslp[i + 1] - 1)
      endif
    next
  endif
  if k > 1.8
    k := 1.8  // согласно п.3 инструкции
  endif
  return k

***** 03.02.21 вернуть итоговый КСЛП для 21 года
Function ret_koef_kslp_21_XML(akslp, tKSLP)
  Local k := 1  // КСЛП равен 1
  local iAKSLP

  if valtype(akslp) == "A"
    for iAKSLP := 1 to len(akslp)
      if (cKSLP := ascan(tKSLP, {|x| x[1] == akslp[ iAKSLP ] })) > 0
        // mo_add_xml_stroke( oSLk, "ID_SL", lstr(akslp[ iAKSLP ] ) )
        // mo_add_xml_stroke( oSLk, "VAL_C", lstr( tKSLP[ cKSLP, 4 ], 7, 5 ) )
        k += (tKSLP[ cKSLP, 4 ] - 1)
      endif
    next
  endif
  if k > 1.8
    k := 1.8  // согласно п.3 инструкции
  endif
  return k