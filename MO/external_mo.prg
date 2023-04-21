#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch' 

// 13.10.20 в GET-е вернуть {_MO_SHORT_NAME, _MO_KOD_TFOMS} и по пробелу - очистка поля
Function f_get_mo(k, r, c, lusl, lpar)
  Static skodN := ''
  Local arr_mo3 := {}, ret, r1, r2, i, lcolor, tmp_select := select()
    
  DEFAULT lpar TO 1
  Private muslovie, loc_arr_MO, ppar := lpar

  if lusl != NIL
    muslovie := lusl
  endif
  if muslovie == NIL
    if glob_task == X_PPOKOJ
      arr_mo3 := Slist2arr(pp_KEM_NAPR)
    elseif glob_task == X_OMS
      arr_mo3 := Slist2arr(mem_KEM_NAPR)
    elseif glob_task == X_263
      arr_mo3 := p_arr_stac_VO
    endif
  endif

  if (r1 := r + 1) > int(maxrow() / 2)
    r2 := r - 1
    r1 := 2
  else
    r2 := maxrow() - 2
  endif
  Private p_mo, lmo3 := 1, pkodN := skodN, _fl_space, _fl_add_mo
  if valtype(k) == 'C' .and. !empty(k)
    pkodN := k
    if ascan(arr_mo3, k) == 0
      lmo3 := 0
    endif
  endif
  if empty(arr_mo3) .or. ppar == 2
    lmo3 := 0
  endif
  dbcreate(cur_dir + 'tmp_mo',{ ;
    {'kodN','C', 6, 0}, ;
    {'kodF','C', 6, 0}, ;
    {'mo3', 'N', 1, 0}, ;
    {'name','C', 72, 0} ;
  })
  use (cur_dir + 'tmp_mo') new alias RG
  do while .t.
    zap
    if lmo3 == 0
      lcolor := color5
      if ppar == 2
        append blank
        rg->kodN := rg->kodF := '999999'
        rg->name := '=== сторонняя МО (не в ОМС или не в Волгоградской области) ==='
      endif
      for i := 1 to len(glob_arr_mo)
        loc_arr_MO := glob_arr_mo[i]
        if iif(muslovie == NIL, .t., &muslovie) .and. year(sys_date) <= year(glob_arr_mo[i, _MO_DEND])
          append blank
          rg->kodN := glob_arr_mo[i, _MO_KOD_TFOMS]
          rg->kodF := glob_arr_mo[i, _MO_KOD_FFOMS]
          rg->name := glob_arr_mo[i, _MO_SHORT_NAME]
          if ascan(arr_mo3, rg->kodN) > 0
            rg->mo3 := 1
          endif
        endif
      next
    else
      lcolor := 'N/W*, GR+/R'
      for j := 1 to len(arr_mo3)
        if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == arr_mo3[j] })) > 0 .and. year(sys_date) <= year(glob_arr_mo[i, _MO_DEND])
          append blank
          rg->kodN := glob_arr_mo[i, _MO_KOD_TFOMS]
          rg->kodF := glob_arr_mo[i, _MO_KOD_FFOMS]
          rg->name := glob_arr_mo[i, _MO_SHORT_NAME]
          rg->mo3 := 1
        endif
      next
    endif
    index on upper(name) to (cur_dir + 'tmp_mo')
    go top
    if empty(pkodN)
      pkodN := glob_mo[_MO_KOD_TFOMS]
    endif
    if !empty(pkodN)
      Locate for kodN == pkodN
      if !found()
        go top
      endif
    endif

    p_mo := 0
    _fl_space := .f.
    _fl_add_mo := .f.
    if Alpha_Browse(r1, 2, r2, 77, 'f2get_mo', lcolor, , , , , , , 'f3get_mo')
      if _fl_space
        skodN := rg->kodN
        ret := { '', space(10) }
        exit
      elseif _fl_add_mo
        skodN := rg->kodN
        ret := { rg->kodN, alltrim(rg->name) }
        exit
      elseif p_mo == 0
        skodN := rg->kodN
        ret := { rg->kodN, alltrim(rg->name) }
        exit
      endif
    elseif p_mo == 0
      exit
    endif
  enddo
  rg->(dbCloseArea())
  select (tmp_select)
  return ret
  
// 13.10.20
Function f2get_mo(oBrow)
  Local n := 72
  oBrow:addColumn(TBColumnNew(center('Наименование МО', n), {|| padr(rg->name, n) }) )
  if ppar == 2
    status_key('^<Esc>^ - выход;  ^<Enter>^ - выбор МО')
  // elseif lmo3 == 0
  //   status_key('^<Esc>^ - выход; ^<Enter>^ - выбор; ^<Пробел>^ - очистка'+iif(glob_task==X_263.or.muslovie!=NIL,'','; ^<F3>^ - краткий список'))
  else
    status_key('^<Esc>^ - выход; ^<Enter>^ - выбор; ^<Пробел>^ - очистка' + iif(glob_task == X_263.or.muslovie != NIL, '', '; ^<F3>^ - все МО'))
  endif
  return NIL
  
// 13.10.20
Function f3get_mo(nkey, oBrow)
  Local ret := -1, cCode, rec
  local aRet

  if nKey == K_F2 .and. lmo3 == 0
    if (cCode := input_value(18, 2, 20, 77, color1, ;
                             'Введите код МО или обособленного подразделения, присвоенный ТФОМС', ;
                             space(6),'999999')) != NIL .and. !empty(cCode)
      rec := rg->(recno())
      go top
      oBrow:gotop()
      Locate for rg->kodN == cCode .or. rg->kodF == cCode
      if !found()
        go top
        oBrow:gotop()
        goto (rec)
      endif
      ret := 0
    endif
  elseif nKey == K_F3 .and. glob_task != X_263 .and. muslovie == NIL .and. ppar == 1

    aRet := viewF003()
    if ! empty(aRet[1])
      _fl_add_mo := .t.
      RG->(dbAppend())  // blank
      rg->kodN := aRet[1]
      rg->name := aRet[2]
      rg->mo3 := 0
      glob_arr_mo := getMo_mo_New('_mo_mo', .t.)
    endif

    ret := 1
    // p_mo := 1
    // pkodN := rg->kodN
    // lmo3 := iif(lmo3 == 0, 1, 0)
    // if lmo3 == 1 .and. rg->mo3 != lmo3
    //   pkodN := ''
    // endif
  elseif nKey == K_SPACE
    _fl_space := .t.
    ret := 1
  endif
  return ret
  
// вернуть массив по МО с кодом ТФОМС cCode
Function ret_mo(cCode)
  // cCode - код МО по ТФОМС
  Local i, arr := aclone(glob_arr_mo[1]) // возьмём первое по порядку МО
  
  for i := 1 to len(arr)
    if valtype(arr[i]) == 'C'
      arr[i] := space(6) // и очистим строковые элементы
    endif
  next
  if !empty(cCode)
    if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode })) > 0
      arr := glob_arr_mo[i]
    elseif (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_FFOMS] == cCode })) > 0
      arr := glob_arr_mo[i]
    endif
  endif
  return arr

// 14.09.20 проверить направляющую МО по дате направления и дате окончания действия
Function verify_dend_mo(cCode, ldate, is_record)
  Static a_mo := { ;
    {255315,{255416}}, ;
    {115309,{425301}}, ;
    {105301,{185301}}, ;
    {155307,{595301}}, ;
    {451001,{105903, 456001}}, ;
    {121125,{101902}}, ;
    {103001,{103002, 103003}}, ;
    {251008,{255601}}, ;
    {251002,{255802}}, ;
    {126501,{256501, 456501, 396501}}, ;
    {251003,{254504}}, ;
    {165531,{165525}}, ;
    {145516,{145526}}, ;
    {115506,{115510}}, ;
    {186002,{126406}}, ;
    {125901,{158201}}, ;
    {134505,{134510}}, ;
    {131001,{136003}}, ;
    {395301,{395302, 395303}}, ;
    {175303,{175304}}, ;
    {155307,{155306}}, ;
    {111008,{171002}}, ;
    {155601,{155502}}, ;
    {175603,{175627}}, ;
    {185515,{125505}}, ;
    {171004,{171006}}, ;
    {184603,{184512}}, ;
    {114504,{114506}}, ;
    {174601,{175709}}, ;
    {124528,{121018}}, ;
    {154602,{154620, 154608}}, ;
    {101003,{184711, 181003}}, ;
    {711001,{711005}} ;
   }
  Local i, j, fl, s := ''
  
  DEFAULT is_record TO .f.
  cCode := ret_mo(cCode)[_MO_KOD_TFOMS]
  if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode })) > 0
    if ldate > glob_arr_mo[i, _MO_DEND]
      fl := .f.
      if is_record
        for j := 1 to len(a_mo)
          if ascan(a_mo[j, 2], int(val(cCode))) > 0
            fl := .t.
            exit
          endif
        next
      endif
      if fl
        human_->NPR_MO := lstr(a_mo[j, 1]) // перезаписываем код направляющего МО в листе учёта ОМС
      else
        s := '<' + glob_arr_mo[i, _MO_SHORT_NAME] + '> закончила свою деятельность ' + date_8(glob_arr_mo[i, _MO_DEND]) + 'г.'
      endif
    endif
  else
    s := 'в справочнике медицинских организаций не найдена МО с кодом ' + cCode
  endif
  return s
  
// инициализация выборки нескольких МО
Function ini_ed_mo(lval)
  Local s := ''
  if empty(lval)
    s := 'Все МО,'
  else
    aeval(glob_arr_mo, {|x| s += iif(x[_MO_KOD_TFOMS] $ lval, alltrim(x[_MO_SHORT_NAME]) + ',', '') })
  endif
  s := substr(s, 1, len(s) - 1)
  return s
  
  // выбор нескольких МО
  Function inp_bit_mo(k, r, c)
  Static arr
  Local mlen, t_mas := {}, buf := savescreen(), ret, i, tmp_color := setcolor(), ;
        m1var := '', s := '', r1, r2, top_bottom := (r < maxrow() / 2)
  mywait()
  if arr == NIL
    arr := {}
    aeval(glob_arr_mo,{|x| aadd(arr, x[_MO_SHORT_NAME])})
  endif
  aeval(glob_arr_mo, {|x| aadd(t_mas, iif(x[_MO_KOD_TFOMS] $ k, ' * ', '   ') + x[_MO_SHORT_NAME]) })
  mlen := len(t_mas)
  i := 1
  status_key('^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins,+,->^ - смена выбора МО')
  if top_bottom     // сверху вниз
    r1 := r + 1
    if (r2 := r1 + mlen + 1) > maxrow() - 2
      r2 := maxrow() - 2
    endif
  else
    r2 := r - 1
    if (r1 := r2 - mlen - 1) < 2
      r1 := 2
    endif
  endif
  if (ret := popup(r1, 2, r2, 77, t_mas, i, color0, .t., 'fmenu_reader', , ;
                   'Выбор наиболее часто встречающихся направляющих МО', 'B/BG')) > 0
    for i := 1 to mlen
      if '*' == substr(t_mas[i], 2, 1)
        m1var += glob_arr_mo[i, _MO_KOD_TFOMS] + ','
      endif
    next
    m1var := left(m1var, len(m1var) - 1)
    s := ini_ed_mo(m1var)
  endif
  restscreen(buf)
  setcolor(tmp_color)
  return iif(ret == 0, NIL, {m1var, s})
    