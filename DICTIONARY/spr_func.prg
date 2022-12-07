** различные функции используемые в справочниках - spr_func.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
 
** 07.12.22 в GET'е выбрать значение из TMP_V015.DBF (глобального массива) с поиском по подстроке
Function fget_tmp_V015(k, r, c, a_spec)
  Local ret, fl, kolRec, nRec, tmp_select := select(), s, blk, t_arr[BR_LEN]

  use (cur_dir + 'tmp_v015') index (cur_dir + 'tmpsV015'), (cur_dir + 'tmpkV015') new alias tmp_ga
  kolRec := lastrec()
  if r <= maxrow() / 2
    t_arr[BR_TOP] := r + 1
    if (t_arr[BR_BOTTOM] := t_arr[BR_TOP] + kolRec+3) > maxrow() - 2
      t_arr[BR_BOTTOM] := maxrow() - 2
    endif
  else
    t_arr[BR_BOTTOM] := r - 1
      if (t_arr[BR_TOP] := t_arr[BR_BOTTOM] - kolRec - 3) < 1
      t_arr[BR_TOP] := 1
    endif
  endif
  if valtype(a_spec) == 'A'
    blk := {|| iif(tmp_ga->isn == 1, {1,2}, {3,4})}
    if !empty(a_spec)
      go top
      do while !eof()
        if ascan(a_spec, int(val(tmp_ga->kod))) > 0
          tmp_ga->isn := 1
        endif
        skip
      enddo
    endif
  else
    blk := {|| iif(tmp_ga->vs == 'врач', {1, 2}, {3, 4})}
  endif
  t_arr[BR_LEFT] := 2
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', .f.}
  t_arr[BR_COLUMN] := { ;
    {'Код', {|| tmp_ga->kod }, blk}, ;
    {center('Медицинская специальность', 40), {|| padr(f1get_tmp_V015(), 40) }, blk}, ;
    {' ', {|| tmp_ga->vs }, blk}, ;
    {center('подчинение', 21), {|| left(tmp_ga->name_up, 21) }, blk} ;
  }
  t_arr[BR_EDIT] := {|nk, ob| f1get_tmp_ga(nk, ob, 'edit', a_spec)}
  if valtype(a_spec) == 'A'
    Ins_Array(t_arr[BR_COLUMN], 1, {' ', {|| iif(tmp_ga->isn==1, '', ' ') }, blk})
    t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - выход;  ^<Ins>^ - отметить специальность;  ^<F2>^ - поиск по подстроке')}
  else
    t_arr[BR_ENTER] := {|| iif(tmp_ga->uroven==0, (func_error(4, 'Запрещается выбирать данную специальность'), ret := nil), ;
                                                (ret := {tmp_ga->kod, alltrim(tmp_ga->name)}))}
    t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке')}
  endif
  fl := .f.
  nRec := 0
  if !(valtype(a_spec) == 'A') .and. k != NIL
    set order to 2
    find (k)
    if (fl := found())
      nRec := recno()
    endif
    set order to 1
  endif
  if !fl
    nRec := 0
  endif
  go top
  if nRec > 0
    if kolRec - nRec < t_arr[BR_BOTTOM] - t_arr[BR_TOP] - 3 // последняя страница?
    keyboard chr(K_END) + replicate(chr(K_UP), kolRec - nRec - 1)
    else
      goto (nRec)
    endif
  endif
  edit_browse(t_arr)
  if valtype(a_spec) == 'A'
    s := ''
    asize(a_spec, 0)
    go top
    do while !eof()
      if tmp_ga->isn == 1
        s += alltrim(tmp_ga->kod) + ','
        aadd(a_spec, int(val(tmp_ga->kod)))
        tmp_ga->isn := 0
      endif
      skip
    enddo
    if empty(s)
      s := '---'
    else
      s := left(s, len(s) - 1)
    endif
    ret := {1, s}
  endif
  tmp_ga->(dbCloseArea())
  select (tmp_select)
  return ret

** 07.08.16
Function f1get_tmp_V015()
  Local s := afteratnum('.', tmp_ga->name, 1)

  s := space(2 * tmp_ga->uroven) + s
  return s

