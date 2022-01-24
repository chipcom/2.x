***** setupFFOMSref.prg - ����ன�� �ᯮ��㥬�� �ࠢ�筨��� �����
#include "set.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 24.01.22 ����ன�� �ࠢ�筨��� �����
Function nastr_sprav_FFOMS(k)
  Static arr_spr, arr_spr_name, sk := 1
  static arr_ref, arr_name
  Local str_sem, mas_pmt := {}, mas_msg := {}, mas_fun := {}, j

  DEFAULT k TO 0
  do case
    case k == 0
      if ! hb_user_curUser:IsAdmin()
        return func_error(4,err_admin)
      endif
      arr_ref := {"V002","V020","V006","V034","MethodINJ"}
      arr_name := {"�������� ��������� ����樭᪮� �����", "�������� �����", "������� �������� ����樭᪮� �����", "������ ���������", "����� ��������"}
      arr_spr_name := {;
        "�����䨪��� �������� ��������� ����樭᪮� �����",;
        "�����䨪��� �������� �����",;
        "�����䨪��� ������� �������� ����樭᪮� �����",;
        "�����䨪��� ������ ���������",;
        "�����䨪��� ����� �������� ������⢥���� �९��⮢"}
        
      arr_spr := arr_name   // ����⠢�� ����� �㭪⮢ ����
      for j := 1 to len(arr_spr)
        aadd(mas_pmt, "����ன�� "+arr_spr[j])
        aadd(mas_msg, arr_spr_name[j])
        aadd(mas_fun, "nastr_sprav_FFOMS("+lstr(j)+")")
      next
      popup_prompt(T_ROW, T_COL+5, sk, mas_pmt, mas_msg, mas_fun)
    case k > 0
      str_sem := "����ன�� "+arr_spr[k]
      arr_spr := arr_ref  // ����⠢�� ����� �ࠢ�筨���
      if G_SLock(str_sem)
        fnastr_sprav_FFOMS(0,arr_spr[k],arr_spr_name[k])
        G_SUnLock(str_sem)
      else
        func_error(4,err_slock)
      endif
      arr_spr := arr_name   // ����⠢�� ����� �㭪⮢ ����
  endcase
  if k > 0
    sk := k
  endif
  return NIL
  
*****
Function fnastr_sprav_FFOMS(k,_n,_m)
  Static sk := 1, _name, _msg
  Local str_sem, mas_pmt, mas_msg, mas_fun, j
  DEFAULT k TO 0
  // ���-�� �� ������ PUBLIC
  Private glob_V034 := getV034()
  Private glob_methodinj := getMethodINJ()
  //
  do case
    case k == 0
      _name := _n ; _msg := _m
      mas_pmt := {"~�� �࣠����樨",;
                  "�� ~��०�����",;
                  "�� ~�⤥�����"}
      mas_msg := {"����ன�� ᮤ�ঠ��� �����䨪��� "+_name+" � 楫�� �� �࣠����樨",;
                  "��筥��� ����ன�� �����䨪��� "+_name+" �� ��०�����",;
                  "��筥��� ����ன�� �����䨪��� "+_name+" �� �⤥�����"}
      mas_fun := {"fnastr_sprav_FFOMS(1)",;
                  "fnastr_sprav_FFOMS(2)",;
                  "fnastr_sprav_FFOMS(3)"}
      popup_prompt(T_ROW, T_COL+5, sk, mas_pmt, mas_msg, mas_fun)
    case k == 1
      f1nastr_sprav_FFOMS(0,_name,_msg)
    case k == 2
      if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL
        f1nastr_sprav_FFOMS(1,_name,_msg)
      endif
    case k == 3
      if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
                   input_otd(T_ROW-1,T_COL+5,sys_date) != NIL
        f1nastr_sprav_FFOMS(2,_name,_msg)
      endif
  endcase
  if k > 0
    sk := k
  endif
  return NIL
  
*****
Function f1nastr_sprav_FFOMS(reg,_name,_msg)
  Local buf, t_arr[BR_LEN], blk, len1, sKey, i, s, arr, arr1, arr2, fl := .t.
  Private name_arr := "glob_"+_name, ob_kol, p_blk
  
  if !init_tmp_glob_array(,&name_arr,sys_date,_name=="V002")
    return NIL
  endif
  use (cur_dir+"tmp_ga") new
  ob_kol := lastrec()
  sKey := lstr(reg)
  s := "����ன�� �� "
  do case
    case reg == 0
      s += '�࣠����樨'
    case reg == 1
      sKey += "-"+lstr(glob_uch[1])
      s += '��०����� "'+glob_uch[2]+'"'
    case reg == 2
      sKey += "-"+lstr(glob_otd[1])
      s += '�⤥����� "'+glob_otd[2]+'"'
  endcase
  //
  if (fl := Semaphor_Tools_Ini(1))
    arr := GetIniVar(tools_ini,{{_name,'0',""}})
    arr := list2arr(arr[1])
    if len(arr) > 0
      ob_kol := len(arr)
      tmp_ga->(dbeval({|| tmp_ga->is := (ascan(arr,kod) > 0) }))
    endif
    if reg > 0
      if empty(arr)
        fl := func_error(4,"���砫� ����室��� ��࠭��� ����ன�� �����䨪��� �� �����������")
      else
        delete for !tmp_ga->is
        pack
        //
        arr1 := GetIniVar(tools_ini,{{_name,"1-"+lstr(glob_uch[1]),""}})
        arr1 := list2arr(arr1[1])
        if len(arr1) > 0
          ob_kol := len(arr1)
          tmp_ga->(dbeval({|| tmp_ga->is := (ascan(arr1,kod) > 0) }))
        endif
      endif
      if fl .and. reg == 2
        if empty(arr1)
          fl := func_error(4,"���砫� ����室��� ��࠭��� ����ன�� �����䨪��� �� ����������")
        else
          delete for !tmp_ga->is
          pack
          //
          arr2 := GetIniVar(tools_ini,{{_name,sKey,""}})
          arr2 := list2arr(arr2[1])
          if len(arr2) > 0
            ob_kol := len(arr2)
            tmp_ga->(dbeval({|| tmp_ga->is := (ascan(arr2,kod) > 0) }))
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
  index on upper(name) to (cur_dir+"tmp_ga")
  buf := savescreen()
  box_shadow(0,50,2,77,color1)
  p_blk := {|| SetPos(1,51), DispOut(padc("��࠭� ��ப: "+lstr(ob_kol),26),color8) }
  blk := {|| iif(tmp_ga->is, {1,2}, {3,4}) }
  eval(p_blk)
  //
  t_arr[BR_TOP] := 4
  t_arr[BR_BOTTOM] := maxrow()-2
  t_arr[BR_LEFT] := 2
  t_arr[BR_RIGHT] := 77
  len1 := t_arr[BR_RIGHT]-t_arr[BR_LEFT]-3-4
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := _name+" "+_msg
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_FL_NOCLEAR] := .t.
  t_arr[BR_ARR_BROWSE] := {,,,"N/BG,W+/N,B/BG,W+/B",.t.}
  t_arr[BR_COLUMN] := {{ ' ', {|| iif(tmp_ga->is, '', ' ') },blk },;
                       { center(s,len1), {|| padr(tmp_ga->name,len1) },blk }}
  t_arr[BR_EDIT] := {|nk,ob| f2nastr_sprav_FFOMS(nk,ob,"edit") }
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - ��室;  ^<+,-,Ins>^ - �⬥���;  ^<F2>^ - ���� �� �����ப�") }
  go top
  edit_browse(t_arr)
  eval(p_blk)
  if f_Esc_Enter("����� ����ன��")
    arr := {}
    tmp_ga->(dbeval({|| iif(tmp_ga->is, aadd(arr,tmp_ga->kod),nil) }))
    if Semaphor_Tools_Ini(1)
      SetIniVar(tools_ini,{{_name,sKey,arr2list(arr)}})
      Semaphor_Tools_Ini(2)
    endif
  endif
  close databases
  restscreen(buf)
  return NIL
  
*****
Function f2nastr_sprav_FFOMS(nKey,oBrow,regim)
  Local k := -1, rec, fl
  if regim == "edit"
    do case
      case nKey == K_F2
        k := f1get_tmp_ga(nKey,oBrow,regim)
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
      case nkey == 43 .or. nkey == 45  // + ��� -
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
  