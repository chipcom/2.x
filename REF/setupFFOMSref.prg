// setupFFOMSref.prg - настройка используемых справочников ФФОМС
#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 24.01.22 Настройка справочников ФФОМС
Function nastr_sprav_FFOMS(k)
  Static arr_spr, arr_spr_name, sk := 1
  static arr_ref, arr_name
  Local str_sem, mas_pmt := {}, mas_msg := {}, mas_fun := {}, j

  DEFAULT k TO 0
  do case
    case k == 0
      if ! hb_user_curUser:IsAdmin()
        return func_error(4, err_admin)
      endif
      arr_ref := {'V002', 'V020', 'V006', 'V034', 'MethodINJ', 'Implantant'}
      arr_name := {'ПРОФИЛЕЙ оказанной медицинской помощи', 'ПРОФИЛЕЙ КОЙКИ', ;
          'УСЛОВИЙ оказания медицинской помощи', 'ЕДИНИЦ ИЗМЕРЕНИЯ', ;
          'ПУТЕЙ ВВЕДЕНИЯ', 'ИМПЛАНТАНТОВ'}
      arr_spr_name := { ;
        'Классификатор ПРОФИЛЕЙ оказанной медицинской помощи', ;
        'Классификатор ПРОФИЛЕЙ КОЙКИ', ;
        'Классификатор УСЛОВИЙ оказания медицинской помощи', ;
        'Классификатор ЕДИНИЦ ИЗМЕРЕНИЯ', ;
        'Классификатор ПУТЕЙ ВВЕДЕНИЯ лекарственных препаратов', ;
        'Классификатор ИМПЛАНТАНТОВ для использования'}
        
      arr_spr := arr_name   // подставим имена пунктов меню
      for j := 1 to len(arr_spr)
        aadd(mas_pmt, 'Настройка ' + arr_spr[j])
        aadd(mas_msg, arr_spr_name[j])
        aadd(mas_fun, 'nastr_sprav_FFOMS(' + lstr(j) + ')')
      next
      popup_prompt(T_ROW, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun)
    case k > 0
      str_sem := 'Настройка ' + arr_spr[k]
      arr_spr := arr_ref  // подставим имена справочников
      if G_SLock(str_sem)
        fnastr_sprav_FFOMS(0, arr_spr[k], arr_spr_name[k])
        G_SUnLock(str_sem)
      else
        func_error(4, err_slock)
      endif
      arr_spr := arr_name   // подставим имена пунктов меню
  endcase
  if k > 0
    sk := k
  endif
  return nil
  
//
Function fnastr_sprav_FFOMS(k, _n, _m)
  Static sk := 1, _name, _msg
  Local str_sem, mas_pmt, mas_msg, mas_fun, j

  DEFAULT k TO 0
  do case
    case k == 0
      _name := _n ; _msg := _m
      mas_pmt := {'~По организации', ;
                  'По ~учреждению', ;
                  'По ~отделению'}
      mas_msg := {'Настройка содержания классификатора ' + _name + ' в целом по организации', ;
                  'Уточнение настройки классификатора ' +_name + ' по учреждению', ;
                  'Уточнение настройки классификатора ' + _name + ' по отделению'}
      mas_fun := {'fnastr_sprav_FFOMS(1)', ;
                  'fnastr_sprav_FFOMS(2)', ;
                  'fnastr_sprav_FFOMS(3)'}
      popup_prompt(T_ROW, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun)
    case k == 1
      f1nastr_sprav_FFOMS(0, _name, _msg)
    case k == 2
      if input_uch(T_ROW - 1, T_COL + 5, sys_date) != nil
        f1nastr_sprav_FFOMS(1, _name, _msg)
      endif
    case k == 3
      if input_uch(T_ROW - 1, T_COL + 5, sys_date) != NIL .and. ;
                   input_otd(T_ROW - 1, T_COL + 5, sys_date) != NIL
        f1nastr_sprav_FFOMS(2, _name, _msg)
      endif
  endcase
  if k > 0
    sk := k
  endif
  return NIL
  
// 21.04.23
Function f1nastr_sprav_FFOMS(reg, _name, _msg)
  Local buf, t_arr[BR_LEN], blk, len1, sKey, i, s, arr, arr1, arr2, fl := .t.
  
  Private name_arr := 'get' + _name + '()', ob_kol, p_blk
  if upper(_name) == 'V034'
    name_arr := 'get_ed_izm()'
  elseif upper(_name) == 'IMPLANTANT'
    name_arr := 'get_implantant()'
  endif
  
  // if !init_tmp_glob_array(, &name_arr, sys_date, _name == 'V002')
  if !init_tmp_glob_array(, &name_arr, sys_date, .f.)
    return NIL
  endif
  use (cur_dir + 'tmp_ga') new
  ob_kol := lastrec()
  sKey := lstr(reg)
  s := 'Настройка по '
  do case
    case reg == 0
      s += 'организации'
    case reg == 1
      sKey += '-' + lstr(glob_uch[1])
      s += 'учреждению "' + glob_uch[2] + '"'
    case reg == 2
      sKey += "-" + lstr(glob_otd[1])
      s += 'отделению "' + glob_otd[2] + '"'
  endcase
  //
  if (fl := Semaphor_Tools_Ini(1))
    arr := GetIniVar(tools_ini, {{_name, '0', ''}})
    arr := list2arr(arr[1])
    if len(arr) > 0
      ob_kol := len(arr)
      tmp_ga->(dbeval({|| tmp_ga->is := (ascan(arr, kod) > 0) }))
    endif
    if reg > 0
      if empty(arr)
        fl := func_error(4, 'Сначала необходимо сохранить настройку классификатора по ОРГАНИЗАЦИИ')
      else
        delete for !tmp_ga->is
        pack
        //
        arr1 := GetIniVar(tools_ini, {{_name, '1-' + lstr(glob_uch[1]), ''}})
        arr1 := list2arr(arr1[1])
        if len(arr1) > 0
          ob_kol := len(arr1)
          tmp_ga->(dbeval({|| tmp_ga->is := (ascan(arr1, kod) > 0) }))
        endif
      endif
      if fl .and. reg == 2
        if empty(arr1)
          fl := func_error(4, 'Сначала необходимо сохранить настройку классификатора по УЧРЕЖДЕНИЮ')
        else
          delete for !tmp_ga->is
          pack
          //
          arr2 := GetIniVar(tools_ini, {{_name, sKey, ''}})
          arr2 := list2arr(arr2[1])
          if len(arr2) > 0
            ob_kol := len(arr2)
            tmp_ga->(dbeval({|| tmp_ga->is := (ascan(arr2, kod) > 0) }))
          endif
        endif
      endif
    endif
    Semaphor_Tools_Ini(2)
  endif
  if !fl
    close databases
    return NIL
  endif
  index on upper(name) to (cur_dir + 'tmp_ga')
  buf := savescreen()
  box_shadow(0, 50, 2, 77, color1)
  p_blk := {|| SetPos(1, 51), DispOut(padc('Выбрано строк: ' + lstr(ob_kol), 26), color8) }
  blk := {|| iif(tmp_ga->is, {1, 2}, {3, 4}) }
  eval(p_blk)
  //
  t_arr[BR_TOP] := 4
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT] := 2
  t_arr[BR_RIGHT] := 77
  len1 := t_arr[BR_RIGHT] - t_arr[BR_LEFT] - 3 - 4
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := _name + ' ' + _msg
  t_arr[BR_TITUL_COLOR] := 'B/BG'
  t_arr[BR_FL_NOCLEAR] := .t.
  t_arr[BR_ARR_BROWSE] := { , , , 'N/BG,W+/N,B/BG,W+/B', .t.}
  t_arr[BR_COLUMN] := {{ ' ', {|| iif(tmp_ga->is, '', ' ') }, blk }, ;
                       { center(s, len1), {|| padr(tmp_ga->name, len1) }, blk }}
  t_arr[BR_EDIT] := {|nk, ob| f2nastr_sprav_FFOMS(nk, ob, 'edit') }
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - выход;  ^<+,-,Ins>^ - отметить;  ^<F2>^ - поиск по подстроке') }
  go top
  edit_browse(t_arr)
  eval(p_blk)
  if f_Esc_Enter('записи настройки')
    arr := {}
    tmp_ga->(dbeval({|| iif(tmp_ga->is, aadd(arr, tmp_ga->kod), nil) }))
    if Semaphor_Tools_Ini(1)
      SetIniVar(tools_ini, {{_name, sKey, arr2list(arr)}})
      Semaphor_Tools_Ini(2)
    endif
  endif
  close databases
  restscreen(buf)
  return NIL
  
//
Function f2nastr_sprav_FFOMS(nKey, oBrow, regim)
  Local k := -1, rec, fl

  if regim == 'edit'
    do case
      case nKey == K_F2
        k := f1get_tmp_ga(nKey, oBrow, regim)
      case nkey == K_INS
        replace tmp_ga->is with !tmp_ga->is
        if tmp_ga->is
          ob_kol++
        else
          ob_kol--
        endif
        eval(p_blk)
        k := 0
        keyboard chr(K_TAB)
      case nkey == 43 .or. nkey == 45  // + или -
        fl := (nkey == 43)
        rec := recno()
        tmp_ga->(dbeval({|| tmp_ga->is := fl}))
        goto (rec)
        if fl
          ob_kol := tmp_ga->(lastrec())
        else
          ob_kol := 0
        endif
        eval(p_blk)
        k := 0
    endcase
  endif
  return k
  
// 18.10.22 сформировать справочник по настройке организации/учреждения/отделения
Function create_classif_FFOMS(reg, _name)
  // reg - возврат кслассификатора для 0-организации/1-учреждения/2-отделения
  Local i, k, arr, arr1, arr2, fl := .t., ret := {}, ret1
  
  Private name_arr := 'get' + _name + '()'
  //
  if upper(_name) == 'V034'
    name_arr := 'get_ed_izm()'
  elseif upper(_name) == 'IMPLANTANT'
    name_arr := 'get_implantant()'
  endif

  arr := GetIniVar(local_tools_ini,{{_name, '0', ''}})
  arr := list2arr(arr[1])
  if len(arr) > 0
    ret := aclone(arr)
    if reg > 0
      arr1 := GetIniVar(local_tools_ini, {{_name, '1-' + lstr(glob_uch[1]), ''}})
      arr1 := list2arr(arr1[1])
      if (k := len(arr1)) > 0
        for i := k to 1 step -1
          if ascan(ret, arr1[i]) == 0
            Del_Array(arr1, i)
          endif
        next
        ret := aclone(arr1)
      endif
      if reg == 2
        arr2 := GetIniVar(local_tools_ini, {{_name, '2-' + lstr(glob_otd[1]), ''}})
        arr2 := list2arr(arr2[1])
        if (k := len(arr2)) > 0
          for i := k to 1 step -1
            if ascan(ret, arr2[i]) == 0
              Del_Array(arr2, i)
            endif
          next
          ret := aclone(arr2)
        endif
      endif
    endif
  endif
  if len(ret) > 0
    ret1 := {}
    for i := 1 to len(ret)
      if (k := ascan(&name_arr, {|x| x[2] == ret[i] })) > 0
        aadd(ret1, &name_arr.[k])
      endif
    next
  elseif upper(_name) == 'V002'
    ret1 := aclone(getV002())
  else
    ret1 := cut_glob_array(&name_arr, sys_date)
  endif
  asort(ret1, , , {|x, y| upper(x[1]) < upper(y[1]) })
  return ret1