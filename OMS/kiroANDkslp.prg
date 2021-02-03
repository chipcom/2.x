#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "..\chip_mo.ch"

#define CODE_KSLP   1
#define NAME_KSLP   2
#define NAMEF_KSLP  3
#define COEF_KSLP   4

#include "tbox.ch"

***** 29.01.21 если надо, перезаписать значения КСЛП и КИРО в HUMAN_2
Function put_str_kslp_kiro(arr,fl)
  Local lpc1 := "", lpc2 := ""

  if len(arr) > 4 .and. !empty(arr[5])
    if year(human->k_data) != 2021  // added 29.01.2021
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
      if year(human->k_data) != 2021  // added 29.01.2021
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

***** 01.02.2021
// возвращает массив КИРО на указанную дату
function getKIROtable( dateSl )
  Local dbName, dbAlias := 'KIRO_'
  local tmp_select := select()
  local tmpKIRO := {}

  static aKIRO, loadKIRO := .f.

  if loadKIRO //если массив КИРО существует вернем его
    if (iy := ascan(aKIRO, {|x| x[1] == Year(dateSl) })) > 0 // год
      return aKIRO[ iy, 2 ]
    endif
  endif

  if year(dateSl) == 2021 // КИРО на 2021 год
    tmp_select := select()
    aKIRO := {}
    // tmpKIRO := {}
    dbName := '_mo1kiro'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(tmpKIRO, { (dbAlias)->CODE, (dbAlias)->NAME, (dbAlias)->NAME_F, (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    aadd(aKIRO, { Year(dateSl), tmpKIRO })
    loadKIRO := .t.
  else
    alertx('На указанную дату ' + DToC(dateSl) + ' КИРО отсутствуют!')
  endif
  return tmpKIRO

  // возвращает массив КСЛП на указанную дату
function getKSLPtable( dateSl )
  Local dbName, dbAlias := 'KSLP_'
  local tmp_select := select()
  local tmpKSLP := {}

  static aKSLP, loadKSLP := .f.

  if loadKSLP //если массив КСЛП существует вернем его
    if (iy := ascan(aKSLP, {|x| x[1] == Year(dateSl) })) > 0 // год
      return aKSLP[ iy, 2 ]
    endif
  endif

  if year(dateSl) == 2021 // КСЛП на 2021 год
    tmp_select := select()
    aKSLP := {}
    // tmpKSLP := {}
    dbName := '_mo1kslp'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(tmpKSLP, { (dbAlias)->CODE, (dbAlias)->NAME, (dbAlias)->NAME_F, (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    aadd(aKSLP, { Year(dateSl), tmpKSLP })
    loadKSLP := .t.
  else
    alertx('На указанную дату ' + DToC(dateSl) + ' КСЛП отсутствуют!')
  endif
  return tmpKSLP

// private mKSLP := '1,3,4,5', m1KSLP := "1,3,4,5"
// @ ++r,1 say "КСЛП" get mKSLP ;
//         reader {|x|menu_reader(x,{{|k,r,c|selectKSLP(k,r,c,sys_date,CToD('22/01/2014'))}},A__FUNCTION,,,.f.)}

// 31.01.2021
// функция выбора состава КСЛП, возвращает { маска,строка количества КСЛП }, или nil
function selectKSLP( k, r, c, dateBegin, dateEnd, DOB, shifrUsl )
  // k - значение m1KSLP (выбранные КСЛП)
  // r - строка экрана
  // c - колонка экрана
  // dateBegin - дата начала законченного случая
  // dateEnd - дата окончания законченного случая
  // DOB - дата рождения пациента

  Local mlen, t_mas := {}, ret, ;
    i, tmp_select := select()
  Local r1 := 0 // счетчик записей
  Local strArr := '', age

  Local m1var := '', s := "", countKSLP := 0
  local row, oBox
  local aKSLP := getKSLPtable( dateEnd )
  local aa := list2arr(k) // получим массив выбранных КСЛП
  local nLast, srok := dateEnd - dateBegin
  local sh := lower(substr(shifrUsl,1,2))
  local recN, permissibleKSLP := {}, isPermissible
  local sAsterisk := ' * ', sBlank := '   '

  default DOB to sys_date
  default dateBegin to sys_date
  default dateEnd to sys_date

  if sh != 'st' .and. sh != 'ds'
    return nil
  else
    recN := ('lusl')->(RecNo())
    ('lusl')->(dbGoTop())
    if ('lusl')->(dbSeek(shifrUsl))
      permissibleKSLP := list2arr(('lusl')->KSLPS)
    endif
  endif
  
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
      strArr += row[ NAME_KSLP ]
      aadd(t_mas, { strArr, .f., row[ CODE_KSLP ] })
    elseif row[ CODE_KSLP ] == 3 .and. isPermissible  // место законному представителю
      if (age < 4)
        strArr := sAsterisk
        strArr += row[ NAME_KSLP ]
      elseif (age < 18)
        strArr += row[ NAME_KSLP ]
      else
        strArr := sBlank
        strArr += row[ NAME_KSLP ]
      endif
      aadd(t_mas, { strArr, (age < 18), row[ CODE_KSLP ] })
    elseif row[ CODE_KSLP ] == 4 .and. isPermissible  // иммунизация РСВ
      if (age < 18)
        strArr += row[ NAME_KSLP ]
      else
        strArr := sBlank
        strArr += row[ NAME_KSLP ]
      endif
      aadd(t_mas, { strArr, (age < 18), row[ CODE_KSLP ] })
    elseif row[ CODE_KSLP ] == 9 // есть сопутствующие заболевания
      if isPermissible  // .and. strArr == sAsterisk
        strArr := sAsterisk
      else
        strArr := sBlank
      endif
      strArr += row[ NAME_KSLP ]
      aadd(t_mas, { strArr, .t., row[ CODE_KSLP ] })
    elseif row[ CODE_KSLP ] == 10 .and. isPermissible // лечение свыше 70 дней согласно инструкции
      strArr := iif(srok > 70, sAsterisk, sBlank)
      strArr += row[ NAME_KSLP ]
      aadd(t_mas, { strArr, .f., row[ CODE_KSLP ] })
  else
      strArr += row[ NAME_KSLP ]
      aadd(t_mas, { strArr, isPermissible, row[ CODE_KSLP ] })
    endif
  next

  strStatus := '^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - отметить / снять отметку'

  mlen := len(t_mas)

  // используем popupN из библиотеки FunLib
  if (ret := popupN(5,20,15,61,t_mas,i,color0,.t.,"fmenu_readerN",,;
      "Отметьте КСЛП",col_tit_popup,,strStatus)) > 0
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

  Return iif(ret==0, NIL, {m1var,s})

// возвращает сумму итогового КСЛП по маске КСЛП и дате случая
function calcKSLP(cKSLP, dateSl)
  // cKSLP - строка выбранных КСЛП
  // dateSl - дата законченного случая
  local summ := 0, i
  local fl := .f.
  local arrKSLP := getKSLPtable( dateSl )
  Local maxKSLP := 1.8  // по инструкции на 2021 год

  for i := 1 to len(cKSLP)
    if SubStr(cKSLP,i,1) == '1'
      if ! fl
        summ += arrKSLP[i, 4]
        fl := .t.
      else
        summ += (arrKSLP[i, 4] - 1)
      endif
    endif
  next
  if summ > maxKSLP
    summ := maxKSLP
  endif
  return summ

  ***** 01.02.21 
Function f_cena_kiro(/*@*/_cena, lkiro, dateSl )
  // _cena - изменяемая цена
  // lkiro - уровень КИРО
  // dateSl - дата случая
  Local _akiro := {0,1}
  local aKIRO, i

  if year(dateSl) == 2021
    aKIRO := getKIROtable( dateSl )
    if (i := ascan(aKIRO, {|x| x[1] == lkiro })) > 0
      if between_date(aKIRO[i, 5], aKIRO[i, 6], dateSl)
        _akiro := { lkiro, aKIRO[i, 4] }
      endif
    endif
  else
    do case
      case lkiro == 1 // менее 4-х дней, выполнено хирург.вмешательство
        _akiro := {lkiro,0.8}
      case lkiro == 2 // менее 4-х дней, хирург.лечение не проводилось
        _akiro := {lkiro,0.2}
      case lkiro == 3 // более 3-х дней, выполнено хирург.вмешательство, лечение прервано
        _akiro := {lkiro,0.9}
      case lkiro == 4 // более 3-х дней, хирург.лечение не проводилось, лечение прервано
        _akiro := {lkiro,0.9}
      case lkiro == 5 // менее 4-х дней, несоблюдение инструкции по приёму препарата
        _akiro := {lkiro,0.2}
      case lkiro == 6 // более 3-х дней, несоблюдение инструкции по приёму препарата, лечение прервано
        _akiro := {lkiro,0.9}
    endcase
  endif
  _cena := round_5(_cena*_akiro[2],0)  // округление до рублей с 2019 года
  return _akiro

***** 30.01.21 определить коэф-т сложности лечения пациента и пересчитать цену
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

      if year(_k_data) == 2021
        // запомним новое КСЛП
        tmSel := select('HUMAN_2')
        if (tmSel)->(dbRlock())
          HUMAN_2->PC1 := newKSLP
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
  
***** 26.01.21 вернуть итоговый КСЛП для 2021 года
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

***** 03.02.21 вернуть итоговый КСЛП для 2021 года
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

***** 30.01.21 проверка услувия для применения КСЛП=1 для 2021 года
function conditionKSLP_1_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f., y

  // КСЛП=1 пациенты старше 75 лет
  count_ymd( ctod(DOB), ctod(n_date), @y )
  if y > 75
    if (profil != 16 .and. ! (lshifr == "st38.001"))
      fl := .t.
    endif
  endif
  return fl

***** 30.01.21 проверка услувия для применения КСЛП=3 для 2021 года
function conditionKSLP_3_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f., y

  // КСЛП=3 спальное место законному представителю, НУЖЕН ЗАПРОС
  count_ymd( ctod(DOB), ctod(n_date), @y )
  aKSLP_ := list2arr(aKSLP)  // преобразуем строку выбранных КСЛП в массив
  if between(y, 0, 18) .and. ascan(aKSLP_, 3) > 0
    // пункт 3.1.1
    // Предоставление спального места и питания законному представителю, при возрасте 
    // ребенка старше 4 лет, осуществляется при наличии медицинских показаний и 
    // оформляется протоколом врачебной комиссии с обязательным указанием в первичной 
    // медицинской документации.
    fl := .t.
    endif
  return fl

***** 30.01.21 проверка услувия для применения КСЛП=4 для 2021 года
function conditionKSLP_4_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f., y

  // КСЛП=4 иммунизация РСВ, НУЖЕН ЗАПРОС
  count_ymd( ctod(DOB), ctod(n_date), @y )
  aKSLP_ := list2arr(aKSLP)  // преобразуем строку выбранных КСЛП в массив
  if between(y, 0, 18) .and. ascan(aKSLP_, 4) > 0
    // пункт 3.1.2
    // КСЛП применяется в случаях если сроки проведения первой иммунизации против 
    // респираторно-синцитиальной вирусной (РСВ) инфекции совпадают по времени с 
    // госпитализацией по поводу лечения нарушений, возникающих в перинатальном 
    // периоде, являющихся показанием к иммунизации.
    fl := .t.
  endif
  return fl

***** 30.01.21 проверка услувия для применения КСЛП=5 для 2021 года
function conditionKSLP_5_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f.

  aKSLP_ := list2arr(aKSLP)  // преобразуем строку выбранных КСЛП в массив
  // КСЛП=5 развертывание индивидуального поста, НУЖЕН ЗАПРОС
  if ascan(aKSLP_,5) > 0
    fl := .t.
  endif
  return fl

***** 30.01.21 проверка услувия для применения КСЛП=6 для 2021 года
function conditionKSLP_6_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f.

  aKSLP_ := list2arr(aKSLP)  // преобразуем строку выбранных КСЛП в массив
  // КСЛП=6 сочетанные хирургические операции
  if ascan(aKSLP_,6) > 0
    // пункт 3.1.3
    // Перечень сочетанных (симультанных) хирургических вмешательств, выполняемых во 
    // время одной госпитализации, представлен в таблице:        
    fl := .t.
  endif
  return fl

***** 30.01.21 проверка услувия для применения КСЛП=7 для 2021 года
function conditionKSLP_7_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f.

  // КСЛП=7 парные органы и введены парные органы
  if lpar_org > 1
    // пункт 3.1.4
    // К данным операциям целесообразно относить операции на парных органах/частях тела,
    // при выполнении которых необходимы, в том числе дорогостоящие расходные материалы.
    // Перечень хирургических вмешательств, при проведении которых одновременно на двух
    // парных органах может быть применен КСЛП, представлен в таблице:
    fl := .t.
  endif
  return fl

***** 30.01.21 проверка услувия для применения КСЛП=8 для 2021 года
function conditionKSLP_8_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f.

  aKSLP_ := list2arr(aKSLP)  // преобразуем строку выбранных КСЛП в массив
  // КСЛП = 8 антимикробная терапия, НУЖЕН ЗАПРОС
  if ascan(aKSLP_,8) > 0
      // пункт 3.1.5
    // В случаях лечения пациентов в стационарных условиях при заболеваниях и их 
    // осложнениях, вызванных микроорганизмами с антибиотикорезистентностью, а также 
    // в случаях лечения по поводу инвазивных микозов применяется КСЛП в соответствии 
    // со всеми перечисленными критериями:
    //  1) наличие инфекционного диагноза с кодом МКБ 10, вынесенного в клинический 
    //    диагноз (столбец Расшифровки групп ?Основной диагноз? или ?Диагноз осложнения?);
    //  2) наличие результатов микробиологического исследования с определением 
    //    чувствительности выделенных микроорганизмов к антибактериальным препаратам 
    //    и/или детекции основных классов карбапенемаз (сериновые, металлобеталактамазы),
    //    подтверждающих обоснованность назначения схемы антибактериальной терапии 
    //    (предполагается наличие результатов на момент завершения случая госпитализации, 
    //    в том числе прерванного);
    //  3) применение как минимум одного лекарственного препарата в парентеральной форме 
    //    из перечня МНН в составе схем антибактериальной и/или антимикотической терапии 
    //    в течение не менее чем 5 суток:        
    fl := .t.
  endif
  return fl


***** 30.01.21 проверка услувия для применения КСЛП=9 для 2021 года
function conditionKSLP_9_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
    // arr_diag - массив диагнозов, 1 элемент - основной диагноз,
  //   остальные сопутствующие и осложнения
  //
  // диагнозы влияющие на КСЛП 9
  // пункт 3.1.6
  //  К таким сопутствующим заболеваниям и осложнениям заболеваний относятся:
  //    ? Сахарный диабет типа 1 и 2 (E10.0-E10.9; E11.0-E11.9);
  //    ? Заболевания, включенные в Перечень редких (орфанных) заболеваний, 
  //      размещенный на официальном сайте Министерства здравоохранения РФ1;
  //    ? Рассеянный склероз (G35);
  //    ? Хронический лимфоцитарный лейкоз (C91.1);
  //    ? Состояния после трансплантации органов и (или) тканей 
  //      (Z94.0; Z94.1; Z94.4; Z94.8);
  //    ? Детский церебральный паралич (G80.0-G80.9);
  //    ? ВИЧ/СПИД, стадии 4Б и 4В, взрослые (B20 ? B24);
  //    ? Перинатальный контакт по ВИЧ-инфекции, дети (Z20.6).
  // При применении КСЛП9 в обязательном порядке в первичной медицинской 
  // документации отражаются мероприятия проводимые по вопросу лечения 
  // вышеуказанной тяжелой сопутствующей патологии (например: дополнительные 
  // лечебно-диагностические мероприятия, назначение лекарственных препаратов, 
  // увеличение срока госпитализации и т.д.), которые отражают дополнительные 
  // затраты медицинской организации на лечение данного пациента. 
  local diag, i := 0, tmp
  local inclDIAG := {;
    "E10.0", "E10.1", "E10.2", "E10.3", "E10.4", "E10.5", "E10.6", "E10.7", "E10.8", "E10.9", ;
    "E11.0", "E11.1", "E11.2", "E11.3", "E11.4", "E11.5", "E11.6", "E11.7", "E11.8", "E11.9", ;
    "G35", "C91.1", "Z94.0", "Z94.1", "Z94.4", "Z94.8", ;
    "G80.0", "G80.1", "G80.2", "G80.3", "G80.4", "G80.8", "G80.9", ;
    "B20", "B21", "B22", "B23", "B24", ;
    "Z20.6";
  }
  local fl := .f., aDiagnozis

  aDiagnozis := Slist2arr(arr_diag)  // преобразуем строку выбранных диагнозов в массив

  for each diag in aDiagnozis
    i++
    if i == 1
      loop
    endif
    if upper(substr(diag,1,1)) == 'B' // что-то с ВИЧ
      tmp := upper(substr(diag,1,3))
    else
      tmp := upper(diag)
    endif
    if ascan(inclDIAG, diag) > 0
      fl := .t.
      exit
    endif
  next
  return fl

***** 30.01.21 проверка услувия для применения КСЛП=10 для 2021 года
// function conditionKSLP_10_21( par )
function conditionKSLP_10_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  // duration - продолжительность лечения в днях
  // lshifr - код услуги КСГ
  //
  // пункт 3.1.7
  // Правила отнесения случаев к сверхдлительным не распространяются на КСГ, 
  // объединяющие случаи проведения лучевой терапии, в том числе в сочетании 
  // с лекарственной терапией (st19.075-st19.089, ds19.050-ds19.062), 
  // т.е. указанные случаи не могут считаться сверхдлительными и оплачиваться 
  // с применением КСЛП10.
  //
  // услуги КСГ исключений для КСЛП 10
  local exclKSG := {"st19.075", "st19.076", "st19.077", "st19.078", "st19.079", ;
    "st19.080", "st19.081", "st19.082", "st19.083", "st19.084", "st19.085", ;
    "st19.086", "st19.087", "st19.088", "st19.089",; 
    "ds19.050", "ds19.051", "ds19.052", "ds19.053", "ds19.054", "ds19.055", ;
    "ds19.056", "ds19.057", "ds19.058", "ds19.059", "ds19.060", "ds19.061", ;
    "ds19.062" }
  local fl := .f.

  // if ( par[8] > 70 ) .and. ( ascan(exclKSG, par[5]) == 0 )
  if ( duration > 70 ) .and. ( ascan(exclKSG, lshifr) == 0 )
    fl := .t.
  endif
  return fl