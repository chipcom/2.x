#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 04.04.24
function full_diagnoz_human( diag, dopDiag )

  local sDop := alltrim( dopDiag )

  diag := alltrim( diag )

  if len( sDop ) == 1 .and. ( sDop >= '0' .and. sDop <= '9' )
    diag := diag + sDop
  endif
  return diag

// 01.02.22
function check_diag_pregant()
  local fl := .f.

  fl := iif( ;
      between_diag(HUMAN->KOD_DIAG2, 'O00', 'O99') .or. ;
      between_diag(HUMAN->KOD_DIAG3, 'O00', 'O99') .or. ;
      between_diag(HUMAN->KOD_DIAG4, 'O00', 'O99') .or. ;
      between_diag(HUMAN->SOPUT_B1, 'O00', 'O99') .or. ;
      between_diag(HUMAN->SOPUT_B2, 'O00', 'O99') .or. ;
      between_diag(HUMAN->SOPUT_B3, 'O00', 'O99') .or. ;
      between_diag(HUMAN->SOPUT_B4, 'O00', 'O99') .or. ;
      between_diag(HUMAN->KOD_DIAG2, 'Z34', 'Z35') .or. ;
      between_diag(HUMAN->KOD_DIAG3, 'Z34', 'Z35') .or. ;
      between_diag(HUMAN->KOD_DIAG4, 'Z34', 'Z35') .or. ;
      between_diag(HUMAN->SOPUT_B1, 'Z34', 'Z35') .or. ;
      between_diag(HUMAN->SOPUT_B2, 'Z34', 'Z35') .or. ;
      between_diag(HUMAN->SOPUT_B3, 'Z34', 'Z35') .or. ;
      between_diag(HUMAN->SOPUT_B4, 'Z34', 'Z35'), .t., .f.)
  return fl
  
// 23.11.22
function between_diag_array(sDiag, aDiag)
  local fl := .f., i

  if valtype(aDiag) != 'A'
    return fl
  endif
  for i := 1 to len(aDiag)
    fl := between_diag(sDiag, aDiag[i, 1], aDiag[i, 2])
    if fl
      return fl
    endif
  next
  return fl

// 22.11.22
function between_diag(sDiag, bDiag, eDiag)
  local fl := .f.
  local l, l1, l2
  local k, k1, k2, v, v1, v2

  sDiag := alltrim(sDiag)
  bDiag := alltrim(bDiag)
  eDiag := alltrim(eDiag)
  l := substr(sDiag, 1, 1)
  l1 := substr(bDiag, 1, 1)
  l2 := substr(eDiag, 1, 1)

  if empty(sDiag) .or. ! between(l, l1, l2)
    return fl
  endif

  k := rat('.', sDiag)
  sDiag := substr(sDiag, 2, k - iif(k > 0, 2, 0))
  k1 := rat('.', bDiag)
  bDiag := substr(bDiag, 2)
  k2 := rat('.', eDiag)
  eDiag := substr(eDiag, 2)

  v := int(val(sDiag))
  v1 := int(val(bDiag))
  v2 := int(val(eDiag))
  fl := between(v, v1, v2)
  return fl

// 19.05.22 проверка ввода диагноза в случае ОМС
Function val1_10diag(fl_search, fl_plus, fl_screen, ldate, lpol, lUp)
  // fl_search - искать введённый диагноз в справочнике
  // fl_plus   - допускается ли ввод первично(+)/повторно(-) в конце диагноза
  // fl_screen - выводить ли на экран наименование диагноза
  // ldate     - дата, по которой проверяется диагноз по ОМС
  // lpol      - пол для проверки допустимости ввода диагноза по полу
  Local fl := .t., mshifr, tmp_select := select(), c_plus := ' ', i, arr,;
        lis_talon := .f., jt, m1, s, mshifr6, fl_4
  local isGeneralDiagnoze
        
  DEFAULT fl_search TO .t., fl_plus TO .f., fl_screen TO .f., ldate TO sys_date
  default lUp TO .f.

  if type('is_talon') == 'L' .and. is_talon
    lis_talon := .t.
  endif
  Private mvar := upper(readvar())

  isGeneralDiagnoze := (mvar == 'MKOD_DIAG')  // установим является ли проверяемое поле основным диагнозом
  
  mshifr := alltrim(&mvar)
  if lis_talon
    arr := {'MKOD_DIAG' ,;
            'MKOD_DIAG2',;
            'MKOD_DIAG3',;
            'MKOD_DIAG4',;
            'MSOPUT_B1' ,;
            'MSOPUT_B2' ,;
            'MSOPUT_B3' ,;
            'MSOPUT_B4'}
    if (jt := ascan(arr, mvar)) == 0
      lis_talon := .f.
    endif
  endif
  if fl_plus
    if (c_plus := right(mshifr, 1)) $ yes_d_plus  // '+-'
      mshifr := alltrim(left(mshifr, len(mshifr) - 1))
    else
      c_plus := ' '
    endif
  endif
  mshifr6 := padr(mshifr, 6)
  mshifr := padr(mshifr, 5)
  if empty(mshifr)
    diag_screen( 2)
  elseif fl_search
    R_Use(dir_exe() + '_mo_mkb', cur_dir + '_mo_mkb', 'DIAG')
    mshifr := mshifr6
    find (mshifr)
    if found()
      fl_4 := .f.
      if !empty(ldate) .and. !between_date(diag->dbegin, diag->dend, ldate, , isGeneralDiagnoze)
        fl_4 := .t.  // Диагноз не входит в ОМС
      endif
      if fl_4 .and. mem_diag4 == 2 .and. !('.' $ mshifr) // если шифр трехзначный
        m1 := alltrim(mshifr) + '.'
        // теперь проверим на наличие любого четырехзначного шифра
        find (m1)
        if found()
          s := ''
          for i := 0 to 9
            find (m1+str(i, 1))
            if found()
              s += alltrim(diag->shifr) + ','
            endif
          next
          s := substr(s, 1, len(s) - 1)
          &mvar := padr(m1, 5) + c_plus
          fl := func_error(4, 'Доступные шифры: ' + s)
        endif
      endif
      if fl .and. fl_screen .and. mem_diagno == 2
        arr := {'', '', '', ''}
        i := 1
        find (mshifr)
        arr[1] := mshifr + ' ' + diag->name
        skip
        do while i < 4 .and. diag->shifr == mshifr .and. !eof()
          arr[++i] := space(6) + diag->name
          skip
        enddo
        s := ''
        find (mshifr)
        if !empty(ldate) .and. !between_date(diag->dbegin, diag->dend, ldate, , isGeneralDiagnoze)
          s := 'Диагноз не входит в ОМС'
        endif
        if !empty(lpol) .and. !empty(diag->pol) .and. !(diag->pol == lpol)
          if empty(s)
            s := 'Н'
          else
            s += ', н'
          endif
          s += 'есовместимость диагноза по полу'
        endif
        if !empty(s)
          arr[4] := padc(alltrim(s) + '!', 71)
          mybell()
        endif
        diag_screen(1, arr, lUp)
      endif
    else
      if '.' $ mshifr  // если шифр четырехзначный
        m1 := beforatnum('.', mshifr)
        // сначала проверим на наличие трехзначного шифра
        find (m1)
        if found()
          // теперь проверим на наличие любого четырехзначного шифра
          find (m1 + '.')
          if found()
            s := ''
            for i := 0 to 9
              find (m1 + '.' + str(i, 1))
              if found()
                s += alltrim(diag->shifr) + ','
              endif
            next
            s := substr(s, 1, len(s) - 1)
            &mvar := padr(m1 + '.', 5) + c_plus
            fl := func_error(4, 'Доступные шифры: ' + s)
          else
            &mvar := padr(m1, 5) + c_plus
            fl := func_error(4, 'Данный диагноз присутствует только в виде ТРЕХзначного шифра!')
          endif
        endif
      endif
      if fl
        &mvar := space(if(fl_plus, 6, 5))
        fl := func_error(4, 'Диагноз с таким шифром не найден!')
      endif
    endif
    diag->(dbCloseArea())
    if tmp_select > 0
      select (tmp_select)
    endif
  endif
  if fl
    if right(mshifr6, 1) != ' '
      &mvar := mshifr6
    else
      &mvar := padr(mshifr, 5) + c_plus
    endif
  endif
  if lis_talon .and. type('adiag_talon') == 'A'
    if empty(&mvar)  // если пустой диагноз -> обнуляем добавки к нему
      for i := jt * 2 - 1 to jt * 2
        adiag_talon[i] := 0
      next
    endif
    put_dop_diag()
  endif
  return fl
  
// упрощённая проверка ввода диагноза
Function val2_10diag()
  Local fl := .t., mshifr, tmp_select := select()
  
  Private mvar := upper(readvar())
  mshifr := alltrim(&mvar)
  mshifr := padr(alltrim(&mvar), 5)
  if !empty(mshifr)
    R_Use(dir_exe() + '_mo_mkb', cur_dir + '_mo_mkb', 'DIAG')
    find (mshifr)
    fl := found()
    diag->(dbCloseArea())
    if tmp_select > 0
      select (tmp_select)
    endif
    if !fl
      func_error(4, 'Диагноз не соответствует МКБ-10')
    endif
  endif
  return fl
  
// запрос на ввод диагноза
Function input_10diag()
  Static sshifr := '     '
  Local buf := box_shadow(18, 20, 20, 59, color8), bg := {|o, k| get_MKB10(o, k)}
  
  Private mshifr := sshifr, ashifr := {}, fl_F3 := .f.
  @ 19, 26 say 'Введите шифр заболевания' color color1 ;
              get mshifr PICTURE '@K@!' ;
              reader {|o| MyGetReader(o, bg)} ;
              valid val1_10diag(.f.) color color1
  status_key('^<Esc>^ - отказ от ввода;  ^<Enter>^ - подтверждение ввода;  ^<F3>^ - выбор из списка')
  set key K_F3 TO f1input_10diag()
  myread({'confirm'})
  set key K_F3 TO
  if fl_F3
    sshifr := mshifr
  elseif lastkey() != K_ESC .and. !empty(mshifr)
    R_Use(dir_exe() + '_mo_mkb', cur_dir + '_mo_mkb', 'DIAG')
    find (mshifr)
    if found()
      sshifr := mshifr
      ashifr := f2input_10diag()
    else
      mshifr := ''
      func_error(4, 'Диагноз с таким шифром не найден!')
    endif
    Use
  endif
  rest_box(buf)
  return {mshifr, ashifr}
  
//
Function f1input_10diag()
  Local buf := savescreen(), agets, fl := .f.
  
  Private pregim := 1, uregim := 1
  set key K_F3 TO
  SAVE GETS TO agets
  R_Use(dir_exe() + '_mo_mkb', cur_dir + '_mo_mkb', 'DIAG')
  if !empty(mshifr)
    find (alltrim(mshifr))
    fl := found()
  endif
  if !fl
    go top
  endif
  if Alpha_Browse(2, 1, maxrow() - 2, 77, 'f1_10diag', color0, , , .t., , , , 'f2_10diag', , , {, , , 'N/BG,W+/N,B/BG,BG+/B'})
    fl_F3 := .t.
    mshifr := FIELD->shifr
    ashifr := f2input_10diag()
    keyboard chr(K_ENTER)
  endif
  close databases
  restscreen(buf)
  RESTORE GETS FROM agets
  set key K_F3 TO f1input_10diag()
  return NIL
  
//
Static Function f2input_10diag()
  Local arr_t := {}
  
  do while FIELD->ks > 0
    skip -1
  enddo
  aadd(arr_t, alltrim(FIELD->name))
  skip
  do while FIELD->ks > 0
    aadd(arr_t, alltrim(FIELD->name))
    skip
  enddo
  return arr_t
  
// меняет русские буквы на латинские при вводе диагноза
Function get_mkb10(oGet, nKey, fl_F7)
  Local cKey, arr, i, mvar, mvar_old

  if nKey == K_F7 .and. fl_F7 .and. !(yes_d_plus == '+-')
    arr := {'MKOD_DIAG' ,;
            'MKOD_DIAG2',;
            'MKOD_DIAG3',;
            'MKOD_DIAG4',;
            'MSOPUT_B1' ,;
            'MSOPUT_B2' ,;
            'MSOPUT_B3' ,;
            'MSOPUT_B4' ,;
            'MKOD_DIAG0'}
    mvar := readvar()
    if (i := ascan(arr, {|x| x == mvar})) > 1
      mvar_old := arr[i - 1]
      if !empty(&mvar_old)
        keyboard chr(K_HOME) + left(&mvar_old, 5)
      endif
    endif
  elseif between(nKey, 32, 255)
    cKey := CHR(nKey)
    ////////////// найти ЛАТ букву, стоящую на клавиатуре там же, где и РУС
    if oGet:pos < 4  // курсор в начале
      cKey := kb_rus_lat(ckey)  // если русская буква
    endif
    if cKey == ','
      cKey := '.' // замениь запятую на точку (цифровая клавиатура под Windows)
    endif
    if oGet:pos > 3 .and. (cKey == 'Ю' .or. cKey == 'ю')
      cKey := '.' // замениь букву 'Ю' на точку (цифровая клавиатура под Windows)
    endif
    //////////////
    IF (SET(_SET_INSERT))
      oGet:insert(cKey)
    ELSE
      oGet:overstrike(cKey)
    ENDIF
    IF (oGet:typeOut)
      IF (SET(_SET_BELL))
        ?? CHR(7)
      ENDIF
      IF (! SET(_SET_CONFIRM))
        oGet:exitState := GE_ENTER
      ENDIF
    ENDIF
  ENDIF
  return NIL
  
// в поле 'диагноз' включить курсор
Function when_diag()
  SETCURSOR()
  return .t.

// 25.03.23
function fill_array_diagnoze(al)
  local aDiagnoze, tmpSelect

  DEFAULT al      TO 'human'  // alias БД листов учета
  if empty(al)
    ad := {MKOD_DIAG , ;
           MKOD_DIAG2, ;
           MKOD_DIAG3, ;
           MKOD_DIAG4, ;
          MSOPUT_B1, ;
          MSOPUT_B2, ;
          MSOPUT_B3, ;
          MSOPUT_B4, ;
          MOSL1, ;
          MOSL2, ;
          MOSL3}
  else
    ad := {&al.->KOD_DIAG , ;
           &al.->KOD_DIAG2, ;
           &al.->KOD_DIAG3, ;
           &al.->KOD_DIAG4, ;
          &al.->SOPUT_B1, ;
          &al.->SOPUT_B2, ;
          &al.->SOPUT_B3, ;
          &al.->SOPUT_B4}
    aadd(ad, human_2->OSL1)
    aadd(ad, human_2->OSL2)
    aadd(ad, human_2->OSL3)
  endif

  return ad

// 31.10.22 вернуть диагнозы в массиве
Function diag_to_array(al, fl_trim, fl_dop, fl_del, fl_6, adiag_talon)
  Local ad, _arr := {}, j, k, s, lshifr, dp, dp1, _ta, tmp_select := select()

  DEFAULT al      TO 'human', ; // alias БД листов учета
          fl_trim TO .f., ;     // удалять завершающие пробелы
          fl_dop  TO .f., ;     // дописывать букву
          fl_del  TO .t., ;     // удалять повторяющиеся диагнозы
          fl_6    TO .f.        // разрешать поиск шестизначных диагнозов
  if empty(al)
    ad := {MKOD_DIAG , ;
           MKOD_DIAG2, ;
           MKOD_DIAG3, ;
           MKOD_DIAG4, ;
          MSOPUT_B1, ;
          MSOPUT_B2, ;
          MSOPUT_B3, ;
          MSOPUT_B4}
  else
    ad := {&al.->KOD_DIAG , ;
           &al.->KOD_DIAG2, ;
           &al.->KOD_DIAG3, ;
           &al.->KOD_DIAG4, ;
          &al.->SOPUT_B1, ;
          &al.->SOPUT_B2, ;
          &al.->SOPUT_B3, ;
          &al.->SOPUT_B4}
  endif
  if fl_6
    if select('MKB_10') == 0
      R_Use(dir_exe() + '_mo_mkb', cur_dir + '_mo_mkb', 'MKB_10')
    endif
    select MKB_10
  endif
  for j := 1 to 8
    if iif(fl_del, !empty(ad[j]), .t.)
      lshifr := ad[j]
      dp := dp1 := ''
      if fl_trim
        lshifr := alltrim(lshifr)
      endif
      if adiag_talon != NIL
        s := adiag_talon[j * 2 - 1]
        if eq_any(s, 1, 2)
          dp := iif(s == 1, '+', '-')
        endif
        s := adiag_talon[j * 2]
        if s > 0
          dp += 'д' + lstr(s)
        endif
      endif
      if !empty(al)
        k := substr(&al.->diag_plus, j, 1)
        if fl_6 .and. !empty(k)
          find (ad[j] + k)
          if found() // если нашли шестизначный шифр
            lshifr := ad[j] + k
          endif
        endif
        if fl_dop .and. !empty(k) .and. k $ yes_d_plus
          dp1 := k
        endif
      endif
      aadd(_arr, {lshifr, dp + dp1})
    endif
  next
  _ta := {}
  if fl_del // удалим из списка повторяющиеся диагнозы
    for j := 1 to len(_arr)
      if ascan(_ta, {|x| x == _arr[j, 1] } ) == 0
        aadd(_ta, _arr[j, 1] )
      endif
    next
    for j := 1 to len(_ta)
      s := ''
      for k := 1 to len(_arr)
        if _arr[k, 1] == _ta[j]
          s += _arr[k, 2]
        endif
      next
      _ta[j] += s
    next
  else
    for j := 1 to len(_arr)
      aadd(_ta, _arr[j, 1] + _arr[j, 2])
    next
  endif
  if tmp_select > 0
    select (tmp_select)
  endif
  return _ta
