** ࠧ���� �㭪樨 ��饣� ���짮����� - mo_func.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
 
** 21.08.17
Function run_my_hrb(name_hrb, name_func)
  Local x, handle, n_file := dir_exe + name_hrb + '.hrb'

  if hb_FileExists(n_file)
    handle := hb_hrbLoad(n_file)
    x := &(name_func)   // �㭪�� �� name_hrb.hrb
    hb_hrbUnload(handle)
  else
    func_error(4, '�� �����㦥� 䠩� ' + n_file)
  endif
  return Nil

** ������� ���� ࠡ��� �����஢
Function write_work_oper(_pt, _tp, _ae, _kk, _kp, _open)
  // {"PD",      'C',   4,   0}, ; // ��� ����� c4tod(pd)
  // {"PO",      'C',   1,   0}, ; // ��� ������ asc(po)
  // {"PT",      'C',   1,   0}, ; // ��� �����
  // {"TP",      'C',   1,   0}, ; // ⨯ (1-����窠, 2-�/�, 3-��㣨)
  // {"AE",      'C',   1,   0}, ; // 1-����������, 2-।���஢����, 3-㤠�����
  // {"KK",      'C',   3,   0}, ; // ���-�� (����祪, �/� ��� ���)
  // {"KP",      'C',   3,   0};  // ������⢮ ������� �����
  Static llen := 6

  DEFAULT _kk TO 1, _kp TO 0, _open TO .t.
  if yes_parol .and. hb_FileExists(dir_server + 'mo_opern' + sdbf) .and. ;
    iif(_open, G_Use(dir_server + 'mo_opern', dir_server + 'mo_opern', 'OP'), .t.)
    _pt := chr(_pt)
    _tp := chr(_tp)
    _ae := chr(_ae)
    find (c4sys_date + kod_polzovat + _pt + _tp + _ae)
    if found()
      G_RLock(forever)
      op->kk := ft_sqzn(_kk + ft_unsqzn(op->kk, llen), llen)
      op->kp := ft_sqzn(_kp + ft_unsqzn(op->kp, llen), llen)
    else
      G_RLock(.t.,forever)
      op->PD := c4sys_date
      op->PO := kod_polzovat
      op->pt := _pt
      op->tp := _tp
      op->ae := _ae
      op->kk := ft_sqzn(_kk, llen)
      op->kp := ft_sqzn(_kp, llen)
    endif
    if _open
      op->(dbCloseArea())
    endif
  endif
  return NIL

** �஢����, ����� ������ �� ᫮�� �⤥�쭮 � 䠬����, ����� � ����⢥
Function TwoWordFamImOt(s)
  Static arr_char := {' ', '-', '.', "'", '"'}
  Local i, fl := .f.

  s := alltrim(s)
  for i := 1 to len(arr_char)
    if arr_char[i] $ s
      fl := .t.
      exit
    endif
  next
  return fl

** �஢���� �⤥�쭮 䠬����, ��� � ����⢮ � GET'��
Function valFamImOt(ltip, s, par, /*@*/msg)
  Static arr_pole := {'�������', '���', '����⢮'}
  Static arr_char := {' ', '-', '.', "'", '"'}
  Local fl := .t., i, c, s1 := '', nword := 0, get, r := row()

  DEFAULT par TO 1
  s := alltrim(s)
  for i := 1 to len(arr_char)
    s := charone(arr_char[i], s)
  next
  if len(s) > 0
    s := upper(left(s, 1)) + substr(s, 2)
  endif
  for i := 1 to len(s)
    c := substr(s, i, 1)
    if isralpha(c)
      //
    elseif ascan(arr_char, c) > 0
      ++nword
    else
      s1 += c
    endif
  next
  msg := ''
  if !empty(s1)
    msg := '� ���� "' + arr_pole[ltip] + '" �����㦥�� �������⨬� ᨬ���� "' + s1 + '"'
  elseif empty(s) .and. ltip < 3
    msg := '���⮥ ���祭�� ���� "' + arr_pole[ltip] + '" �������⨬�'
  endif
  if par == 1  // ��� GET-��⥬�
    Private tmp := readvar()
    &tmp := padr(s, 40)
    if empty(msg) .and. nword > 0
      if (get := get_pointer(tmp)) != NIL
        r := get:Row
      endif
      fl := .f.
      MyBell()
      if f_alert({padc('� ���� "' + arr_pole[ltip] + '" ����ᥭ� ' + lstr(nword + 1) + ' ᫮��', 60, '.')}, ;
               {' ������ � ।���஢���� ', ' �ࠢ��쭮� ���� '}, ;
               1, 'W+/N', 'N+/N', r + 1, , 'W+/N,N/BG') == 2
        fl := .t.
      endif
    endif
  endif
  if !empty(msg)
    if par == 1  // ��� GET-��⥬�
      fl := func_error(4, msg)
    else  // ��� �஢�ન �����
      fl := .f.
    endif
  endif
  return fl

** 02.09.15 ������ �⤥�쭮 䠬����, ��� � ����⢮ � ���ᨢ�
Function retFamImOt(ltip, fl_no, is_open_kfio)
  Static cDelimiter := ' .'
  Local i, k := 0, s := '', s1, mfio, tmp_select, ret_arr := {'', '', ''}
  
  DEFAULT fl_no TO .t., is_open_kfio TO .f.
  if ltip == 1 // �맢��� �� ����⥪�
    mfio := kart->fio
  else  // �맢��� �� ���� ����
    mfio := human->fio
    if human->kod_k != kart->kod // �᫨ �� �易�� �� relation
      kart->(dbGoto(human->kod_k))
    endif
  endif
  if kart->MEST_INOG == 9 // �.�. �⤥�쭮 ����ᥭ� �.�.�.
    tmp_select := select()
    if is_open_kfio
      select KFIO
    else
      R_Use(dir_server + 'mo_kfio', , 'KFIO')
      index on str(kod, 7) to (cur_dir + 'tmp_kfio')
    endif
    find (str(kart->kod, 7))
    if found()
      ret_arr[1] := alltrim(kfio->FAM)
      ret_arr[2] := alltrim(kfio->IM)
      ret_arr[3] := alltrim(kfio->OT)
    endif
    if !is_open_kfio
      kfio->(dbCloseArea())
    endif
    select (tmp_select)
  endif
  if empty(ret_arr[1]) // �� ��直� ��砩 - ���� �� ��諨 � "mo_kfio"
    mfio := alltrim(mfio)
    for i := 1 to numtoken(mfio, cDelimiter)
      s1 := alltrim(token(mfio, cDelimiter,i))
      if !empty(s1)
        ++k
        if k < 3
          ret_arr[k] := s1
        else
          s += s1 + ' '
        endif
      endif
    next
    ret_arr[3] := alltrim(s)
  endif
  if fl_no .and. empty(ret_arr[3])
    ret_arr[3] := '���'
  endif
  return ret_arr

** 26.10.14 �஢�ઠ �� �ࠢ��쭮��� ����񭭮�� ���
Function val_fio(afio, aerr)
  Local i, k := 0, msg

  DEFAULT aerr TO {}
  for i := 1 to 3
    valFamImOt(i, afio[i], 2, @msg)
    if !empty(msg)
      ++k
      aadd(aerr, msg)
    endif
  next
  return (k == 0)

** 26.08.14 ������ �����த��� ���
Function ret_inogSMO_name(ltip, /*@*/rec, fl_close)
  Local s := space(100), fl := .f., tmp_select := select()

  DEFAULT fl_close TO .f.
  if select('SN') == 0
    R_Use(dir_server + iif(ltip == 1, 'mo_kismo', 'mo_hismo'), , 'SN')
    index on str(kod, 7) to (cur_dir + 'tmp_ismo')
    fl := .t.
  endif
  select SN
  find (str(iif(ltip == 1, kart->kod, human->kod), 7))
  if found()
    s := sn->SMO_NAME
    rec := sn->(recno())
  endif
  if fl .and. fl_close
    sn->(dbCloseArea())
  endif
  select (tmp_select)
  return s

** 22.05.15 ��� �� ��࠭ (�����)
Function smo_to_screen(ltip)
  Local s := '', s1 := '', lsmo, nsmo, lokato

  lsmo := iif(ltip == 1, kart_->smo, human_->smo)
  nsmo := int(val(lsmo))
  s := inieditspr(A__MENUVERT, glob_arr_smo, nsmo)
  if empty(s) .or. nsmo == 34
    if nsmo == 34
      s1 := ret_inogSMO_name(ltip, , .t.)
    else
      s1 := init_ismo(lsmo)
    endif
    if !empty(s1)
      s := alltrim(s1)
    endif
    lokato := iif(ltip == 1, kart_->KVARTAL_D, human_->okato)
    if !empty(lokato)
      s += '/' + inieditspr(A__MENUVERT, glob_array_srf, lokato)
    endif
  endif
  return s

** 15.10.14 �஢�ઠ ���४⭮�� GUID
Function valid_GUID(s, par)
  // par = 1 - GUID �� ���� �ணࠬ��
  // par = 2 - GUID �� �㦮� �ணࠬ��
  Local fl := .t.
  
  DEFAULT par TO 1
  if par == 1
    if len(charrem(' ', s)) < 36
      fl := .f.
    else
      fl := empty(CHARREPL('0123456789ABCDEF-', upper(s), SPACE(17)))
    endif
  else // par = 2 - GUID �� �㦮� �ணࠬ��
    fl := !empty(s) // ���� �஢�ਬ �� ������
  endif
  return fl

** ��⠢��� GUID
Function mo_guid(par1, par2)
  // par1 - �� 1 �� 3
  //        .XXXXX...... ��� par1 = 1
  //        ....XXXXX... ��� par1 = 2
  //        .......XXXXX ��� par1 = 3
  //        .....XXXXXX. ��� par1 = 4
  // par2 - ����� �����
  Local s, s1, s2, k, l

  s := f1CreateGUID(8) + '-' + ;
       f1CreateGUID(4) + '-' + ;
       f1CreateGUID(4) + '-' + ;
       f1CreateGUID(4) + '-'
  s1 := f1CreateGUID(12)
  s2 := ntoc(par2, 16) // ����� ����� -> � 16-�筮� �᫮ (��ப�)
  l := len(s2) // ����� 16-�筮� ��ப�
  k := {6, 9, 12, 11}[par1] - l + 1 // ����� ����樨, � ���ன �㤥� �������
  return s + stuff(s1, k, l, s2)

**
Static Function f1CreateGUID(tmpLength)
  Static strValid := '0123456789ABCDEF'
  Local tmpCounter, tmpGUID := ''

  For tmpCounter := 1 To tmpLength
    tmpGUID += substr(strValid, random() % 16 + 1, 1)
  Next
  return tmpGUID

** 21.01.17 ��।����� ��������� ����஢ ����⮢
Function f_mb_me_nsh(_nyear, /*@*/mb, /*@*/me)

  if mem_bnn13rees <= 0 .or. mem_enn13rees <= 0
    if mem_bnn_rees == 1
      mem_bnn13rees := mem_bnn_rees
    else
      mem_bnn13rees := int(val(lstr(mem_bnn_rees) + '0'))
    endif
    mem_enn13rees := int(val(lstr(mem_enn_rees) + '9'))
  endif
  mb := mem_bnn13rees
  me := mem_enn13rees
  /*if _nyear < 2013 .and. mem_bnn_rees == 1
    mb := 100
  endif*/
  return iif(_nyear < 2017, 3, 5) // ��稭�� � 2017 ���� - 5 ᨬ�����





** �஢����, ������� 䠩� nfile, � ��������� 㤠���� ���
Function myFileDeleted(nfile)
  Static sn := 100 // ������ 100 ����⮪
  Local i := 0, fl := .f.

  do while i < sn
    if hb_FileExists(nfile)
      delete file (nfile)
    else
      fl := .t.
      exit
    endif
    ++i
  enddo
  if !fl
    func_error(4, '��㤠筠� ����⪠ 㤠����� 䠩�� ' + nfile + '. ����⠩��� ᭮��')
  endif
  return fl

** 15.12.13 ���४⥭ �� ��ਮ� ��� ���ଠ樨 "�� ����⭮�� ��ਮ��"
Function is_otch_period(arr_m)
  Local fl := .t.

  if !(arr_m[5] == bom(arr_m[5]) .and. arr_m[6] == eom(arr_m[6]))
    fl := func_error(4, '��� ����⭮�� ��ਮ�� ����室��� �롨��� ���� ������ ��ਮ�!')
  endif
  return fl

** �������� �� ���.��ਮ� (_YEAR,_MONTH) � �������� � _begin_date �� _end_date
Function between_otch_period(_date, _YEAR, _MONTH, _begin_date, _end_date)
  Local mdate

  if emptyany(_YEAR, _MONTH)
    mdate := _date // ��-��஬�, �.�. �� ��� ����
  else
    mdate := stod(strzero(_YEAR, 4) + strzero(_MONTH, 2) + '15')
  endif
  return between(mdate, _begin_date, _end_date)

** 21.10.13 �஢���� ��४��⨥ ���������� p1-p2 � d1-d2 ��� ��樮���
Function overlap_diapazon(p1, p2, d1, d2)
  Local fl := .f.

  if p1 == d1 .and. p2 == d2 // ��᮫�⭮ ��������� ��������� ��祭��
    fl := .t.
  elseif p1 == p2 // ��ࢮ� ��祭�� � ���� ����
    if d1 < d2    // � ��஥ ��祭�� ����� ������ ���
      fl := (d1 < p1 .and. p2 < d2) // ��ࢮ� ��祭�� ����� ��ண�
    endif
  elseif d1 == d2 // ��஥ ��祭�� � ���� ����
    if p1 < p2    // � ��ࢮ� ��祭�� ����� ������ ���
      fl := (p1 < d1 .and. d2 < p2) // ��஥ ��祭�� ����� ��ࢮ��
    endif
  elseif p1 == d1 .or. p2 == d2 // ��砫� ��� ����砭�� ��祭�� � ���� ����
    fl := .t.
  else
    if !(fl := ((p1 < d1 .and. d1 < p2) .or. (p1 < d2 .and. d2 < p2)))
      fl := ((d1 < p1 .and. p1 < d2) .or. (d1 < p2 .and. p2 < d2))
    endif
  endif
  return fl

** ᤥ���� �� ������쭮�� ���ᨢ� 㪮�祭�� (����� �� ��� ����⢨�)
Function cut_glob_array(_glob_array, _date)
  Local i, tmp_array := {}

  for i := 1 to len(_glob_array)
    if between_date(_glob_array[i, 3], _glob_array[i, 4], _date)
      aadd(tmp_array, _glob_array[i])
    endif
  next
  return tmp_array

** ᮧ���� (name_base).DBF �� ������쭮�� ���ᨢ� (㪮�祭���) (����� �� ��� ����⢨�)
FUNCTION init_tmp_glob_array(name_base, _glob_array, _date, is_all)
  Local i, len1, len2, f2type, fl_is, tmp_select

  DEFAULT name_base TO 'tmp_ga', is_all TO .f.
  if !myFileDeleted(cur_dir + name_base + sdbf)
    return .f.
  endif
  tmp_select := select()
  len1 := len2 := 0
  f2type := valtype(_glob_array[1, 2])
  for i := 1 to len(_glob_array)
    if iif(is_all, .t., between_date(_glob_array[i, 3], _glob_array[i, 4], _date))
      len1 := max(len1, len(alltrim(_glob_array[i, 1])))
      if f2type == 'N'
        len2 := max(len2, len(lstr(_glob_array[i, 2])))
      else
        len2 := max(len2, len(alltrim(_glob_array[i, 2])))
      endif
    endif
  next
  dbcreate(name_base, {{'name', 'C', len1, 0}, ;
                      {'kod', f2type, len2, 0}, ;
                      {'is', 'L', 1, 0}})
  use (name_base) new alias tmp_ga
  for i := 1 to len(_glob_array)
    fl_is := between_date(_glob_array[i, 3], _glob_array[i, 4], _date)
    if iif(is_all, .t., fl_is)
      append blank
      replace name with _glob_array[i, 1], ;
              kod with _glob_array[i, 2], ;
              is with fl_is
    endif
  next
  index on upper(name) to (name_base)
  tmp_ga->(dbCloseArea())
  select (tmp_select)
  return .t.

** 04.05.13 � GET'� ����� ���祭�� �� TMP_GA.DBF (������쭮�� ���ᨢ�) � ���᪮� �� �����ப�
Function fget_tmp_ga(k, r, c, name_base, browTitle, is_F2, sTitle)
  Local ret, fl, cRec, kolRec, nRec, len1, len2, f2type, tmp_select, blk, t_arr[BR_LEN]

  DEFAULT name_base TO 'tmp_ga', browTitle TO '������������', is_F2 TO .t.
  tmp_select := select()
  use (name_base) index (name_base) new alias tmp_ga
  kolRec := lastrec()
  len1 := fieldlen(1)
  len2 := fieldlen(2)
  if r <= maxrow()/2
    t_arr[BR_TOP] := r + 1
    if (t_arr[BR_BOTTOM] := t_arr[BR_TOP] + kolRec + 3) > maxrow() - 2
      t_arr[BR_BOTTOM] := maxrow() - 2
    endif
  else
    t_arr[BR_BOTTOM] := r - 1
    if (t_arr[BR_TOP] := t_arr[BR_BOTTOM] - kolRec - 3) < 1
      t_arr[BR_TOP] := 1
    endif
  endif
  t_arr[BR_LEFT] := c
  if (t_arr[BR_RIGHT] := c + len1 + 3) > 77
    t_arr[BR_RIGHT] := 77
    t_arr[BR_LEFT] := t_arr[BR_RIGHT] - len1 - 3
    if t_arr[BR_LEFT] < 2
      t_arr[BR_LEFT] := 2
    endif
  endif
  len1 := t_arr[BR_RIGHT] - t_arr[BR_LEFT] - 3
  blk := {|| iif(tmp_ga->is, {1, 2}, {3, 4}) }
  t_arr[BR_COLOR] := color0
  if sTitle != NIL
    t_arr[BR_TITUL] := sTitle
    t_arr[BR_TITUL_COLOR] := 'B/BG'
  endif
  t_arr[BR_ARR_BROWSE] := {, , , 'N/BG,W+/N,B/BG,W+/B', .f.}
  t_arr[BR_COLUMN] := {{center(browTitle, len1), {|| left(tmp_ga->name, len1)}, blk}}
  if is_F2
    t_arr[BR_EDIT] := {|nk, ob| f1get_tmp_ga(nk, ob, 'edit')}
  endif
  if fieldnum('IDUMP') > 0 //ᯥ樠�쭮 ��� �⤥�����
    t_arr[BR_ENTER] := {|| ret := {tmp_ga->kod, alltrim(tmp_ga->name), tmp_ga->idump, tmp_ga->tiplu}}
  else
    t_arr[BR_ENTER] := {|| ret := {tmp_ga->kod, alltrim(tmp_ga->name)}}
  endif
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - ��室;  ^<Enter>^ - �롮�' + iif(is_F2, ';  ^<F2>^ - ���� �� �����ப�', ''))}
  f2type := fieldtype(2)
  fl := .f.
  nRec := 0
  if k != NIL
    go top
    do while !eof()
      if f2type == 'N'
        fl := (tmp_ga->kod == k)
      else
        fl := (alltrim(tmp_ga->kod) == alltrim(k))
      endif
      if fl
        cRec := recno()
        exit
      endif
      ++nRec
      skip
    enddo
  endif
  if !fl
    nRec := 0
  endif
  go top
  if nRec > 0
    if kolRec - nRec < t_arr[BR_BOTTOM] - t_arr[BR_TOP] - 3 // ��᫥���� ��࠭��?
      keyboard chr(K_END) + replicate(chr(K_UP), kolRec - nRec - 1)
    else
      goto (cRec)
    endif
  endif
  edit_browse(t_arr)
  tmp_ga->(dbCloseArea())
  select (tmp_select)
  return ret

** 23.01.17
Function f1get_tmp_ga(nKey, oBrow, regim, arr)
  Static tmp := ''
  Local ret := -1, buf, buf1, tmp1, rec1 := recno()

  if regim == 'edit' .and. nkey == K_INS .and. valtype(arr) == 'A' .and. fieldnum('ISN') > 0
    //ᯥ樠�쭮 ��� ������⢥����� �롮� �� �ࠢ�筨�� ����� ᯥ樠�쭮�⥩ V015
    tmp_ga->isn := iif(tmp_ga->isn==1, 0, 1)
    keyboard chr(K_TAB)
    return 0
  endif
  if !(regim == 'edit' .and. nKey == K_F2)
    return ret
  endif
  buf := savescreen()
  do while .t.
    buf1 := save_box(pr2 - 3, pc1 + 1, pr2 - 1, pc2 - 1)
    box_shadow(pr2 - 3, pc1 + 1, pr2 - 1, pc2 - 1, color1, '������ �����ப� ���᪠', color8)
    tmp1 := padr(tmp, 15)
    status_key('^<Esc>^ - �⪠� �� �����')
    @ pr2 - 2, pc1 + (pc2 - pc1 - 15) / 2 get tmp1 picture '@K@!' color color8
    myread()
    if lastkey() == K_ESC .or. empty(tmp1)
      exit
    endif
    mywait()
    tmp := alltrim(tmp1)
    Private tmp_mas := {}, tmp_kod := {}, t_len, k1, k2
    i := 0
    go top
    do while !eof()
      if tmp $ upper(tmp_ga->name)
        aadd(tmp_mas, tmp_ga->name)
        aadd(tmp_kod, tmp_ga->(recno()))
      endif
      skip
    enddo
    rest_box(buf1)
    if (t_len := len(tmp_kod)) = 0
      stat_msg('�� ������� �� ����� �����, 㤮���⢮���饩 ������ �����ப�!')
      mybell(2)
      loop
    elseif t_len == 1  // ������� ���� ��ப�
      goto (tmp_kod[1])
      ret := 0
      exit
    else
      status_key('^<Esc>^ - �⪠� �� �롮�')
      if (i := popup(pr1 + 3, pc1 + 1, pr2 - 1, pc2 - 1, tmp_mas, 1, color1, .f., , , ;
                    '���-�� ����ᥩ � "' + tmp + '" - ' + lstr(t_len), color8)) > 0
        goto (tmp_kod[i])
        ret := 0
      endif
      exit
    endif
  enddo
  restscreen(buf)
  if ret == -1
    goto rec1
  endif
  return ret

**
Function is_up_usl(arr_usl, mkod)
  Local i := 0, tmp_select := select()

  select USL
  do while .t.
    find (str(mkod, 4))
    if !found()
      exit
    endif
    if usl->kod_up == 0 .or. i > 20
      exit
    endif
    mkod := usl->kod_up
    ++i
  enddo
  if tmp_select > 0
    select(tmp_select)
  endif
  return ( ascan(arr_usl, usl->kod) > 0 )

** 03.01.19
Function input_usluga(arr_tfoms)
  Local ar, musl, arr_usl, buf, fl_tfoms := (valtype(arr_tfoms) == 'A')

  ar := GetIniSect(tmp_ini, 'uslugi')
  musl := padr(a2default(ar, 'shifr'), 10)
  if (musl := input_value(18, 6, 20, 73, color1, ;
          space(17) + '������ ��� ��㣨', musl, '@K')) != NIL .and. !empty(musl)
    buf := save_maxrow()
    mywait()
    musl := transform_shifr(musl)
    SetIniSect(tmp_ini, 'uslugi', {{'shifr', musl}})
    R_Use(dir_server + 'uslugi', dir_server + 'uslugish', 'USL')
    find (musl)
    if found()
      susl := musl
      arr_usl := {usl->kod, alltrim(usl->shifr) + '. ' + alltrim(usl->name), usl->shifr}
    else
      func_error(4, '��㣠 � ��஬ ' + alltrim(musl) + ' �� ������� � ��襬 �ࠢ�筨��!')
      if fl_tfoms
        arr_usl := {0, '', ''}
      endif
    endif
    usl->(dbCloseArea())
    if fl_tfoms
      use_base("lusl")
      find (musl)
      if found()
        arr_tfoms[1] := lusl->(recno())
        arr_tfoms[2] := alltrim(lusl->shifr) + '. ' + alltrim(lusl->name)
        arr_tfoms[3] := lusl->shifr
      endif
      close_use_base('lusl')
    endif
    rest_box(buf)
  endif
  return arr_usl

**
Function ret_1st_otd(lkod_uch)
  Local k, tmp_select := select()

  R_Use(dir_server + 'mo_otd', , 'OTD')
  Locate for otd->kod_lpu == lkod_uch
  if found()
    k := {otd->(recno()), alltrim(otd->name)}
  else
    func_error(3, '��� �⤥����� ��� ������� ��०�����!')
  endif
  otd->(dbCloseArea())
  if tmp_select > 0
    select(tmp_select)
  endif
  return k

** ������ ��業� �믮������ �����
Function ret_trudoem(lkod_vr, ltrudoem, kol_mes, arr_m, /*@*/plan)
  Local i := 0, trd := 0, ltrud, tmp_select := select()

  plan := 0
  do while i < kol_mes
    ltrud := 0
    // ᭠砫� ���� �����⭮�� �����
    select UCHP
    find (str(lkod_vr, 4) + str(arr_m[1], 4) + str(arr_m[2] + i, 2))
    if found()
      ltrud := uchp->m_trud
    endif
    if empty(ltrud)  // �᫨ �� ��諨
      // � ���� �।������筮�� �����
      select UCHP
      find (str(lkod_vr, 4) + str(0, 4) + str(0, 2))
      if found()
        ltrud := uchp->m_trud
      endif
    endif
    plan += ltrud
    ++i
  enddo
  if plan > 0
    trd := ltrudoem / plan * 100
  endif
  select (tmp_select)
  return trd

** 13.02.14
FUNCTION input_uch(r, c, date1, date2)
  Local ret, k, fl_is, tmp_select := select()

  if !myFileDeleted(cur_dir + 'tmp_ga' + sdbf)
    return ret
  endif
  if empty(glob_uch[1])
    ar := GetIniVar(tmp_ini, {{'uch_otd', 'uch', '0'}, ;
                              {'uch_otd', 'OTD', '0'}})
    glob_uch[1] := int(val(ar[1]))
    glob_otd[1] := int(val(ar[2]))
  endif
  dbcreate(cur_dir + 'tmp_ga', {{'name', 'C', 30, 0}, ;
                                {'kod', 'N', 3, 0}, ;
                                {'is', 'L', 1, 0}})
  use (cur_dir + 'tmp_ga') new
  R_Use(dir_server + 'mo_uch', ,'UCH')
  go top
  do while !eof()
    fl_is := between_date(uch->DBEGIN, uch->DEND, date1, date2)
    if iif(date1 == NIL, .t., fl_is)
      select TMP_GA
      append blank
      replace name with uch->name, ;
              kod with uch->kod, ;
              is with fl_is
    endif
    select UCH
    skip
  enddo
  uch->(dbCloseArea())
  select TMP_GA
  if (k := tmp_ga->(lastrec())) == 1
    ret := {tmp_ga->kod, alltrim(tmp_ga->name)}
  else
    index on upper(name) to (cur_dir + 'tmp_ga')
  endif
  tmp_ga->(dbCloseArea())
  select (tmp_select)
  if k == 0
    func_error(4, '���⮩ �ࠢ�筨� ��०�����')
  elseif k > 1
    ret := fget_tmp_ga(glob_uch[1], r, c, , '�롮� ��०�����', .f.)
  endif
  if ret != NIL
    glob_uch := ret
    st_a_uch := {glob_uch}
    SetIniVar(tmp_ini, {{'uch_otd', 'UCH', glob_uch[1]}})
  endif
  return ret

**
Function inputE_otd(r1, c1, r2)
  return input_otd(r1, c1, sys_date)

** 13.02.14
FUNCTION input_otd(r, c, date1, date2, nTask)
  Local ret, k, fl_is, tmp_select := select()

  DEFAULT nTask TO X_OMS
  if !myFileDeleted(cur_dir + 'tmp_ga' + sdbf)
    return ret
  endif
  dbcreate(cur_dir + 'tmp_ga', {{'name', 'C', 30, 0}, ;
                                {'kod', 'N', 3, 0}, ;
                                {'idump', 'N', 2, 0}, ;
                                {'tiplu', 'N', 2, 0}, ;
                                {'is', 'L', 1, 0}})
  use (cur_dir + 'tmp_ga') new
  R_Use(dir_server + 'mo_otd', , 'OTD')
  go top
  do while !eof()
    if otd->KOD_LPU == glob_uch[1]
      if nTask == X_ORTO
        fl_is := between_date(otd->DBEGINO, otd->DENDO, date1, date2)
      elseif nTask == X_PLATN
        fl_is := between_date(otd->DBEGINP, otd->DENDP, date1, date2)
      else
        fl_is := between_date(otd->DBEGIN, otd->DEND, date1, date2)
      endif
      if iif(date1 == NIL, .t., fl_is)
        select TMP_GA
        append blank
        replace name with otd->name, ;
                kod with otd->kod, ;
                idump with otd->idump, ;
                tiplu with otd->tiplu, ;
                is with fl_is
      endif
    endif
    select OTD
    skip
  enddo
  otd->(dbCloseArea())
  select TMP_GA
  if (k := tmp_ga->(lastrec())) == 1
    ret := {tmp_ga->kod, alltrim(tmp_ga->name), tmp_ga->idump, tmp_ga->tiplu}
  else
    index on upper(name) to (cur_dir + 'tmp_ga')
  endif
  tmp_ga->(dbCloseArea())
  select (tmp_select)
  if k == 0
    func_error(4, '�� ������� �⤥����� ��� ������� ��०�����')
  elseif k > 1
    ret := fget_tmp_ga(glob_otd[1], r, c, , '�롮� �⤥�����', .f., alltrim(glob_uch[2]))
  endif
  if ret != NIL
    glob_otd := ret
    SetIniVar(tmp_ini, {{'uch_otd', 'OTD', glob_otd[1]}})
  endif
  return ret

** 29.10.18
Function input_perso(r, c, is_null, is_rab)
  Static si := 1
  Local fl := .f., fl1 := .f., mas_pmt, s_input, s_glob, s_pict, tmp_help := 0, ;
        arr_dolj := {}, arr_kod := {}, lr, r1, r2, i, buf := save_row(maxrow())

  DEFAULT is_null TO .t., is_rab TO .f.
  mas_pmt := {'���� ���㤭��� �� ~⠡.������', '���� ���㤭��� �� ~䠬����'}
  s_input := space(10) + '������ ⠡���� ����� ���㤭���'
  s_glob := glob_human[5]
  s_pict := '99999'
  if (i := popup_prompt(r, c, si, mas_pmt)) == 0
    return .f.
  elseif i == 1
    si := 1
    if (i := input_value(18, 6, 20, 73, color1, s_input, s_glob, s_pict)) == NIL
      return .f.
    elseif i == 0
      if is_null
        glob_human := {0, '', 0, 0, 0, '', 0, 0}
        return .t.
      else
        return .f.
      endif
    elseif i < 0
      return func_error(4, '������ ���� - ����⥫�� ���!')
    endif
    R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO')
    find (str(i, 5))
    if found()
      glob_human := {perso->kod, ;
                     alltrim(perso->fio), ;
                     perso->uch, ;
                     perso->otd, ;
                     i, ;
                     alltrim(perso->name_dolj), ;
                     perso->prvs, ;
                     perso->prvs_new }
      fl1 := .t.
    else
      func_error(4, '����㤭��� � ⠡���� ����஬ ' + lstr(i) + ' ��� � ���� ������ ���ᮭ���!')
    endif
    close databases
    return fl1
  endif
  si := 2
  Private mr := r
  mywait()
  //help_code := H_Input_fio
  if R_Use(dir_server + 'mo_pers', , 'PERSO')
    index on upper(fio) to (cur_dir + 'tmp_pers') for kod > 0
    if glob_human[1] > 0
      goto (glob_human[1])
      fl := !eof() .and. !deleted()
    endif
    if !fl
      go top
    endif
    if Alpha_Browse(r, 9, maxrow() - 2, 70, 'f1inp_perso', color0, , , , , , , , , {'�', '�', '�', 'N/BG,W+/N,B/BG,BG+/B'})
      lr := row()
      if perso->kod == 0
        func_error(4, '���� ������ ���ᮭ��� �����!')
      else
        glob_human := {perso->kod, ;
                       alltrim(perso->fio), ;
                       perso->uch, ;
                       perso->otd, ;
                       perso->tab_nom, ;
                       alltrim(perso->name_dolj), ;
                       perso->prvs, ;
                       perso->prvs_new }
        fl1 := .t.
      endif
    endif
  endif
  close databases
  //help_code := tmp_help
  rest_box(buf)
  return fl1

** 29.10.18
Function f1inp_perso(oBrow)
  Local oColumn

  oColumn := TBColumnNew(center('�.�.�.', 30), {|| left(perso->fio, 30)})
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew('���.�', {|| perso->tab_nom})
  oColumn:defColor := {3, 3}
  oColumn:colorBlock := {|| {3, 3} }
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(center('���樠�쭮���', 21), {|| padr(ret_tmp_prvs(perso->prvs, perso->prvs_new), 21)})
  oBrow:addColumn(oColumn)
  return NIL

** ������ ��०����� � �⤥����� � GET'�
FUNCTION ret_uch_otd(k, r, c, date1, date2, nTask)
  Local ret, n := 1

  if k != NIL .and. k > 0
    glob_uch[1] := k
  endif
  if input_uch(r, c, date1, date2) != NIL
    if type('m1otd') == 'N' .and. m1otd > 0
      glob_otd[1] := m1otd
    endif
    if input_otd(r, c, date1, date2, nTask) != NIL
      if valtype(motd) == 'C'
        n := len(motd)
      endif
      m1otd := glob_otd[1]
      motd := alltrim(glob_otd[2])
      if len(motd) < n
        motd := padr(motd, n)
      endif
      ret := glob_uch
    endif
  endif
  return ret

** 㤠����� ������ �� �㡭�� ��㫥 � HUMANST (��� ������ ���)
Function STdelHuman(ltip, lrec)

  select HUMANST
  do while .t.
    find (str(ltip, 1) + str(lrec, 8))
    if !found()
      exit
    endif
    DeleteRec(.t.)
  enddo
  return NIL

** 㤠����� ������ �� �㡭�� ��㫥 � ����⥪�
Function STdelKart(ltip, lrec)

  select KART_ST
  set order to 2
  do while .t.
    find (str(ltip, 1) + str(lrec, 8))
    if !found()
      exit
    endif
    DeleteRec(.t.)
  enddo
  return NIL

** ���������� ������ �� �㡭�� ��㫥
Function STappend(ltip, lrec, lkod_k, ldate_u, lu_kod, lkod_vr, _zf, _diag)
  Local i, arr_zf := STretArrZF(_zf)

  STdelKart(ltip, lrec)
  if ltip == 2 // ����� ��㣨
    STdelHuman(ltip, lrec)
  endif
  if len(arr_zf) > 0
    if ltip == 2 // ����� ��㣨
      select HUMANST
      AddRec(1)
      humanst->TIP_BD    := ltip
      humanst->REC_BD    := lrec
      humanst->KOD_DIAG  := _diag
      humanst->ZF        := _zf
      humanst->(dbUnLock())
    endif
    select KART_ST
    set order to 2
    for i := 1 to len(arr_zf)
      AddRec(1)
      kart_st->KOD       := lkod_k
      kart_st->ZF        := arr_zf[i]
      kart_st->KOD_DIAG  := _diag
      kart_st->TIP_BD    := ltip
      kart_st->REC_BD    := lrec
      kart_st->DATE_U    := ldate_u
      kart_st->U_KOD     := lu_kod
      kart_st->KOD_VR    := lkod_vr
      kart_st->(dbUnLock())
    next
  endif
  return NIL

** 17.12.18 ���������� 㤠�񭭮�� �㡠
Function STappendDelZ(lkod_k, _zf, ldate_u, lu_kod)
  Static arr_STdelzub
  Local i, arr_zf := STretArrZF(_zf)

  DEFAULT arr_STdelzub TO ret_arr_STdelzub()
  if len(arr_zf) > 0 .and. ascan(arr_STdelzub, lu_kod) > 0 .and. select('KARTDELZ') > 0
    select KARTDELZ
    for i := 1 to len(arr_zf)
      find (str(lkod_k, 7) + str(arr_zf[i], 2))
      if found()
        if !(kartdelz->DATE_U == ldate_u)
          G_RLock(forever)
          kartdelz->DATE_U := ldate_u
          kartdelz->(dbUnLock())
        endif
      else
        AddRec(7)
        kartdelz->KOD    := lkod_k
        kartdelz->ZF     := arr_zf[i]
        kartdelz->DATE_U := ldate_u
        kartdelz->(dbUnLock())
      endif
    next
  endif
  return NIL

** 17.12.18 㤠����� 㤠�񭭮�� �㡠
Function STDelDelZ(lkod_k, _zf, lu_kod)
  Static arr_STdelzub
  Local i, arr_zf := STretArrZF(_zf)

  DEFAULT arr_STdelzub TO ret_arr_STdelzub()
  if len(arr_zf) > 0 .and. ascan(arr_STdelzub, lu_kod) > 0 .and. select('KARTDELZ') > 0
    select KARTDELZ
    for i := 1 to len(arr_zf)
      find (str(lkod_k, 7) + str(arr_zf[i], 2))
      if found()
        DeleteRec(.t.)
      endif
    next
  endif
  return NIL

** 11.12.18 ������ ���ᨢ � ������ ��� 㤠����� �㡠
Function ret_arr_STdelzub()
  Static arr := { ;
    {'A16.07.030.001', '�������� �६������ �㡠'}, ;
    {'A16.07.030.002', '�������� ����ﭭ��� �㡠'}, ;
    {'A16.07.030.003', '�������� �㡠 ᫮���� � ࠧꥤ������� ��୥�'}, ;
    {'A16.07.039'    , '������ 㤠����� �⨭�஢������, ���⮯�஢������ ��� ᢥ�媮�����⭮�� �㡠'} ;
  }
  Static akod := {}
  Local i, s, lkod := 0
  /*if len(akod) == 0
    use_base("mo_su","MOSU1")
    akod := {}
    for i := 1 to len(arr)
      s := arr[i,1]
      select MOSU1
      set order to 3
      find (padr(s,20))
      do while mosu1->shifr1 == padr(s,20) .and. !eof()
        if !("*" $ mosu1->shifr)
          lkod := mosu1->kod ; exit
        endif
        skip
      enddo
      if lkod == 0
        set order to 1
        FIND (STR(-1,6))
        if found()
          G_RLock(forever)
        else
          AddRec(6)
        endif
        lkod := mosu1->kod := recno()
        mosu1->name := arr[i,2]
        mosu1->shifr1 := s
      endif
      aadd(akod,lkod)
    next
    mosu1->(dbCloseArea())
  endif*/
  return akod

** 17.12.18 �஢�ઠ, �� 㤠�� �� ��
Function STverDelZub(lkod_k, arr_zf, ldate_u, ltip, lrec, /*@*/amsg)
  Static arr_STdelzub
  Local i

  DEFAULT arr_STdelzub TO ret_arr_STdelzub()
  if len(arr_STdelzub) > 0 .and. select('KARTDELZ') > 0
    select KARTDELZ
    for i := 1 to len(arr_zf)
      find (str(lkod_k, 7) + str(arr_zf[i], 2))
      if found() .and. kartdelz->DATE_U < ldate_u
        aadd(amsg, lstr(arr_zf[i]) + ': ����� �� 㤠��� ' + full_date(c4tod(kartdelz->DATE_U)))
      endif
    next
  endif
  /*if len(arr_STdelzub) > 0
    select KART_ST
    set order to 1
    for i := 1 to len(arr_zf)
      find (str(lkod_k,7)+str(arr_zf[i],2))
      do while kart_st->KOD == lkod_k .and. kart_st->ZF == arr_zf[i]
        if !(kart_st->TIP_BD == ltip .and. kart_st->REC_BD == lrec)
          if kart_st->DATE_U < ldate_u .and. ascan(arr_STdelzub,kart_st->U_KOD) > 0
            aadd(amsg, lstr(arr_zf[i])+': ����� �� 㤠��� '+full_date(c4tod(kart_st->DATE_U)))
          endif
        endif
        skip
      enddo
    next
  endif*/
  return NIL

** 16.01.19 �஢�ઠ �ࠢ��쭮�� ����� �㡭�� ����
Function STVerifyKolZf(arr_zf, mkol, /*@*/amsg, lshifr)

  if valtype(arr_zf) == 'A' .and. valtype(mkol) == 'N'
    DEFAULT lshifr TO ''
    if len(arr_zf) == 0 //
      aadd(amsg, '�� ������� �㡭�� ��㫠 ' + lshifr)
    elseif len(arr_zf) != mkol
      aadd(amsg, '������⢮ �㡮� �� ᮮ⢥����� �������� ������� �㡭�� ��� ' + lshifr)
    endif
  endif
  return !empty(amsg)

** 31.01.19 �஢�ઠ �ࠢ��쭮�� ����� �㡭�� ����
Function STverifyZF(_zf, _date_r, _sys_date, /*@*/amsg, lshifr)
  Static fz := {{11, 18}, {21, 28}, {31, 38}, {41, 48},{51, 55}, {61, 65}, {71, 75}, {81, 85}}
  //               ������ ���쭮�� � 14 ���   |       ������ �� 5 ���
  Local i, j, k, v, arr_zf := STretArrZF(_zf, @amsg, lshifr)
  if len(arr_zf) > 0
    DEFAULT lshifr TO ''
    v := count_years(_date_r, _sys_date)
    for i := 1 to len(arr_zf)
      k := 0
      for j := 1 to len(fz)
        if between(arr_zf[i], fz[j, 1], fz[j, 2])
          k := j
          exit
        endif
      next
      if k == 0
        aadd(amsg, lstr(arr_zf[i]) + ' - ����ୠ� �㡭�� ��㫠 ' + lshifr)
      //elseif v <= 5 .and. between(k,1,4)
        //aadd(amsg, lstr(arr_zf[i])+' - � ॡ���� �㡭�� ��㫠 ���᫮�� '+lshifr)
      //elseif v > 14 .and. between(k,5,8)
        //aadd(amsg, lstr(arr_zf[i])+' - � ���᫮�� �㡭�� ��㫠 ॡ���� '+lshifr)
      endif
    next
  endif
  return arr_zf

** 16.01.19 ᨭ⠪��᪨� ������ �㡭�� ����, ������ ���ᨢ� �㡮�
Function STretArrZF(_zf, /*@*/amsg, lshifr)
  //Static ssymb := "12345678,-�����", nsymb := 15  ⠪ �뫮 � ��������� ������
  Static ssymb := '12345678,-', nsymb := 10
  Local i, j, s, tmps, v1, v2, arr_zf := {}

  DEFAULT amsg TO {}, lshifr TO ''
  s := charrem(' ', _zf) // 㤠���� �� �஡���
  // �஢��塞 �� �����⨬� ᨬ����
  tmps := charrem(' ', CHARREPL(ssymb, s, SPACE(nsymb)))
  if !empty(tmps)
    aadd(amsg, '"' + tmps + '" - �㡭�� ��㫠: �����४�� ᨬ���� ' + lshifr)
  endif
  for i := 1 to numtoken(s, ',')
    tmps := token(s, ',', i)
    if '-' $ tmps // ��ࠡ�⪠ ���������
      v1 := token(tmps, '-', 1)
      v2 := token(tmps, '-', 2)
    else // �����筮� ���祭��
      v1 := v2 := tmps
    endif
    v1 := int(val(v1))
    v2 := int(val(v2))
    if v2 < v1
      aadd(amsg, '"' + tmps + '" - �㡭�� ��㫠: �����४�� �������� ' + lshifr)
      v2 := v1
    endif
    for j := v1 to v2
      aadd(arr_zf, j) // ���ᨢ �㡮�
    next
  next
  return arr_zf

** 16.01.19 ���� �� ��砩 �⮬�⮫����᪨� ��� ����� �㡭�� ����
Function STisZF(_USL_OK, _PROFIL)
  return (_USL_OK == 3 .and. eq_any(_PROFIL, 85, 86, 87, 88, 89, 90, 140, 171))

** ���� �ࠧ� ��� ���� ࠡ��� �� ᯨ᪠
Function v_vvod_mr()
Local k, nrow := row(), ncol := col(), fl := .f., tmp_keys, tmp_gets
tmp_keys := my_savekey()
if (get := get_pointer("MMR_DOL")) != NIL .and. get:hasFocus
  save gets to tmp_gets
  setcursor(0)
  if !empty(k := input_s_mr())
    fl := .t.
  else
    @ nrow,ncol say ""
  endif
  restore gets from tmp_gets
  if fl
    keyboard (alltrim(k))
  endif
  setcursor()
endif
my_restkey(tmp_keys)
return NIL

** �롮� �ࠧ� ��� ���� ࠡ���
Function input_s_mr()
Local t_arr[BR_LEN], tmp_select := select(), buf := savescreen(), ret := ""
t_arr[BR_TOP] := 2
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 26
t_arr[BR_RIGHT] := 79
t_arr[BR_OPEN] := {|| f1_s_mr(,,"open") }
t_arr[BR_CLOSE] := {|| sa->(dbCloseArea()) }
t_arr[BR_COLOR] := color0
//t_arr[BR_ARR_BROWSE] := {,,,,,reg,"*+"}
t_arr[BR_COLUMN] := {{ center("���᮪ �ࠧ ��� ���� ࠡ���",50),{|| sa->name} }}
s_msg := "^<Esc>^ - ��室;  ^<Enter>^ - �롮�;  ^<Ins>^ - ����������"
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - ��室;  ^<Enter>^ - �롮�;  ^<Ins>^ - ����������;  ^<F2>^ - ����") }
t_arr[BR_EDIT] := {|nk,ob| f1_s_mr(nk,ob,"edit") }
t_arr[BR_ENTER] := {|| ret := alltrim(sa->name) }
edit_browse(t_arr)
if tmp_select > 0
  select(tmp_select)
endif
restscreen(buf)
return ret

**
Function f1_s_mr(nKey,oBrow,regim)
Static tmp := ' '
Local ret := -1, j := 0, flag := -1, buf := save_maxrow(), buf1, ;
      fl := .f., rec, mkod, tmp_color := setcolor()
do case
  case regim == "open"
    G_Use(dir_server + "s_mr",,"SA")
    index on upper(name) to (cur_dir + "tmp_mr")
    go top
    ret := !eof()
  case regim == "edit"
    if nKey == K_F2
      Private tmp1 := padr(tmp,30)
      if (tmp1 := input_value(pr2-2,pc1+1,pr2,pc2-1,color1, ;
                              "�����ப� ���᪠", ;
                              tmp1,"@K@!")) != NIL .and. !empty(tmp1)
        tmp := alltrim(tmp1)
        Private tmp_mas := {}, tmp_kod := {}
        rec := recno()
        go top
        locate for tmp $ upper(name)
        do while !eof()
          if ++j > 4000 ; exit ; endif
          aadd(tmp_mas,sa->name) ; aadd(tmp_kod,sa->(recno()))
          continue
        enddo
        goto (rec)
        if len(tmp_kod) == 0
          stat_msg("��㤠�� ����!") ; mybell(2)
        else
          status_key("^<Esc>^ - �⪠� �� �롮�")
          if (j := popup(pr1+1,pc1+1,pr2-1,pc2-1,tmp_mas,,color5,,,, ;
                         '������� ���᪠ �� �����ப� "'+tmp+'"',"B/W")) > 0
            oBrow:gotop()
            goto (tmp_kod[j])
          endif
          ret := 0
        endif
      endif
    elseif nKey == K_INS
      rec := recno()
      Private mname := if(nKey == K_INS, space(50), sa->name), ;
              gl_area := {1,0,23,79,0}
      buf1 := box_shadow(pr2-2,pc1+1,pr2,pc2-1,color8, ;
                    iif(nKey==K_INS,"����������","������஢����"),cDataPgDn)
      setcolor(cDataCGet)
      @ pr2-1,pc1+2 get mname
      status_key("^<Esc>^ - ��室 ��� �����;  ^<Enter>^ - ���⢥ত���� �����")
      myread()
      if lastkey() != K_ESC .and. !empty(mname)
        if nKey == K_INS
          AddRecN()
          rec := recno()
        else
          G_RLock(forever)
        endif
        replace name with mname
        COMMIT
        UNLOCK
        oBrow:goTop()
        goto (rec)
        ret := 0
      endif
      setcolor(tmp_color)
      rest_box(buf) ; rest_box(buf1)
    else
      keyboard ""
    endif
endcase
return ret

** 07.02.13 ���� �ࠧ� ��� ���� �� ᯨ᪠
Function v_vvod_adres()
  Local k, nrow := row(), ncol := col(), fl := .f., tmp_keys, tmp_gets

  tmp_keys := my_savekey()
  if (get := get_pointer('MULICADOM')) != NIL .and. get:hasFocus
    save gets to tmp_gets
    setcursor(0)
    if !empty(k := input_s_adres())
      fl := .t.
    else
      @ nrow,ncol say ''
    endif
    restore gets from tmp_gets
    if fl
      keyboard (alltrim(k) + ' ')
    endif
    setcursor()
  endif
  my_restkey(tmp_keys)
  return NIL

** �롮� �ࠧ� ��� ����
Function input_s_adres()
  Local t_arr[BR_LEN], tmp_select := select(), buf := savescreen(), ret := ''

  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT] := 36
  t_arr[BR_RIGHT] := 79
  t_arr[BR_OPEN] := {|| f1_s_adres( , , 'open')}
  t_arr[BR_CLOSE] := {|| sa->(dbCloseArea())}
  t_arr[BR_COLOR] := color0
  //t_arr[BR_ARR_BROWSE] := {,,,,,reg,"*+"}
  t_arr[BR_COLUMN] := {{center('���᮪ �ࠧ ��� ����', 40), {|| sa->name}}}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - ��室;  ^<Enter>^ - �롮�;  ^<Ins>^ - ����������')}
  t_arr[BR_EDIT] := {|nk, ob| f1_s_adres(nk, ob, 'edit')}
  t_arr[BR_ENTER] := {|| ret := alltrim(sa->name)}
  edit_browse(t_arr)
  if tmp_select > 0
    select(tmp_select)
  endif
  restscreen(buf)
  return ret

** �ଠ ����ன�� ����砥���/�᪫�砥��� ���
Function forma_nastr(s_titul, arr_strok, nfile, arr, fl)
  Local i, j, r := 2, tmp_color := setcolor(cDataCGet)
  Local buf := savescreen(), blk := {|| f9_f_nastr(s_titul, arr_strok)}

  if nfile != NIL
    arr := rest_arr(nfile)
  endif
  if arr == NIL .or. empty(arr)
    arr := {{}, {}}
  endif
  Private mda[15], mnet[15]
  afill(mda, space(10))
  aeval(arr[1], {|x, i| mda[i] := padr(x, 10)})
  afill(mnet, space(10))
  aeval(arr[2], {|x, i| mnet[i] := padr(x, 10)})
  box_shadow(r, 0, 23, 79, color1, s_titul, color8)
  str_center(r + 2, '����� ०�� �।�����祭 ��� ����ன��')
  j := r + 2
  aeval(arr_strok, {|x| str_center(++j, x, 'G+/B')})
  ++j
  @ ++j, 4 say '     ����砥�� ��㣨 (蠡���)          �᪫�砥�� ��㣨 (蠡���)'
  for i := 1 to 15
    @ j + i, 15 say str(i, 2) get mda[i]
  next
  for i := 1 to 15
    @ j + i, 52 say str(i, 2) get mnet[i]
  next
  status_key('^<Esc>^ - ��室;  ^<PgDn>^ - ��������� ����ன��;  ^<F9>^ - ����� ᯨ᪠ ���')
  SETKEY(K_F9, blk)
  myread()
  SETKEY(K_F9, NIL)
  fl := .f.
  if lastkey() != K_ESC .and. f_Esc_Enter(1)
    fl := .t.
    arr := {{}, {}}
    for i := 1 to 15
      if !empty(mda[i])
        aadd(arr[1], mda[i])
      endif
      if !empty(mnet[i])
        aadd(arr[2], mnet[i])
      endif
    next
    if nfile != NIL
      save_arr(arr, nfile)
    endif
  endif
  setcolor(tmp_color)
  restscreen(buf)
  return arr

**
Function f9_f_nastr(l_titul, a_strok)
  Local sh := 80, HH := 77, buf := save_maxrow(), n_file := cur_dir + 'frm_nast' + stxt
  Local i, k, nrow := row(), ncol := col(), tmp_keys, tmp_gets, ta := {}

  mywait()
  tmp_keys := my_savekey()
  save gets to tmp_gets
  //
  fp := fcreate(n_file)
  tek_stroke := 0
  n_list := 1
  add_string('')
  add_string(center(l_titul, sh))
  add_string('')
  add_string(center('����� ᯨ᮪ ��� �।�⠢��� ᮤ�ঠ���', sh))
  aeval(a_strok, {|x| add_string(center(x, sh))})
  add_string('')
  add_string('      ����砥�� ��㣨 (蠡���)          �᪫�砥�� ��㣨 (蠡���)')
  k := 0
  for i := 1 to 15
    aadd(ta, space(20) + mda[i] + space(20) + mnet[i])
    if !emptyall(mda[i], mnet[i])
      k := i
    endif
  next
  for i := 1 to k
    add_string(ta[i])
  next
  R_Use(dir_server + 'uslugi', , 'USL')
  index on fsort_usl(shifr) to (cur_dir + 'tmpu')
  go top
  do while !eof()
    if _f_usl_danet(mda, mnet)
      verify_FF(HH, .t., sh)
      add_string(usl->shifr + ' ' + rtrim(usl->name))
    endif
    skip
  enddo
  usl->(dbCloseArea())
  fclose(fp)
  rest_box(buf)
  viewtext(n_file, , , , .f., , , 5)
  //
  restore gets from tmp_gets
  my_restkey(tmp_keys)
  setcursor()
  return NIL

**
Function ret_f_nastr(a_usl, lshifr)
  Local i, shb, fl := .f.

  for i := 1 to len(a_usl[1])
    if !empty(shb := a_usl[1, i])
      if '*' $ shb .or. '?' $ shb
        fl := like(alltrim(shb), lshifr)
      else
        fl := (shb == lshifr)
      endif
      if fl
        exit
      endif
    endif
  next
  if fl
    for i := 1 to len(a_usl[2])
      if !empty(shb := a_usl[2, i])
        if '*' $ shb .or. '?' $ shb
          fl := !like(alltrim(shb), lshifr)
        else
          fl := !(shb == lshifr)
        endif
        if !fl
          exit
        endif
      endif
    next
  endif
  return fl

**
Function _f_usl_danet(a_da, a_net)
  Local fl, i, shb

  fl := usl->is_nul .or. !emptyall(usl->cena, usl->cena_d)
  if !fl .and. is_task(X_PLATN) // ��� ������ ���
    fl := usl->is_nulp .or. !emptyall(usl->pcena, usl->pcena_d, usl->dms_cena)
  endif
  if fl
    fl := .f.
    for i := 1 to len(a_da)
      if !empty(shb := a_da[i])
        if '*' $ shb .or. '?' $ shb
          fl := like(alltrim(shb), usl->shifr)
        else
          fl := (shb == usl->shifr)
        endif
        if fl
          exit
        endif
      endif
    next
    if fl
      for i := 1 to len(a_net)
        if !empty(shb := a_net[i])
          if '*' $ shb .or. '?' $ shb
            fl := !like(alltrim(shb), usl->shifr)
          else
            fl := !(shb == usl->shifr)
          endif
          if !fl
            exit
          endif
        endif
      next
    endif
  endif
  return fl

** 28.01.20 �뢥�� ��ப� � �⫠���� ���ᨢ � ���
Function f_put_debug_KSG(k, arr, ars)
  // k = 1 - �࠯����᪠�
  // k = 2 - ���ࣨ�᪠�
  Local s := ' ', i, s1, arr1 := {}
  if k == 1
    s += '�࠯.'
  elseif k == 2
    s += '����.'
  endif
  s += '���'
  if len(arr) == 0
    s += ' �� ��।�����'
  else
    s += ': '
    for i := 1 to len(arr)
      s1 := ''
      if k == 0 .and. !empty(arr[i, 5])
        s1 += '��.����.,'
      endif
      if eq_any(k, 0, 1) .and. !empty(arr[i, 6])
        if alltrim(arr[i, 10]) == 'mgi'
          //
        else
          s1 += '��.,'
        endif
      endif
      if !empty(arr[i, 7])
        s1 += '����.,'
      endif
      if !empty(arr[i, 8])
        s1 += '���,'
      endif
      if !empty(arr[i, 9])
        s1 += '��-��,'
      endif
      if !empty(arr[i, 10])
        s1 += '���.���਩,'
      endif
      if len(arr[i]) >= 15 .and. !empty(arr[i, 15])
        s1 += '���� ���਩,'
      endif
      if !empty(arr[i, 11])
        s1 += 'ᮯ.����.,'
      endif
      if !empty(arr[i, 12])
        s1 += '����.��.,'
      endif
      if !empty(s1)
        s1 := ' (' + left(s1, len(s1) - 1) + ')'
      endif
      s1 := alltrim(arr[i, 1]) + s1 + ' [��=' + lstr(arr[i, 3]) + ']'
      if ascan(arr1, s1) == 0
        aadd(arr1, s1)
      endif
    next
    for i := 1 to len(arr1)
      s += arr1[i] + ' '
    next
  endif
  aadd(ars, s)
  return len(arr1)

** 20.01.14 ������ 業� ���
Function ret_cena_KSG(lshifr, lvr, ldate, ta)
  Local fl_del := .f., fl_uslc := .f., v := 0

  DEFAULT ta TO {}
  v := fcena_oms(lshifr, ;
                (lvr == 0), ;
                ldate, ;
                @fl_del, ;
                @fl_uslc)
  if fl_uslc  // �᫨ ��諨 � �ࠢ�筨�� �����
    if fl_del
      aadd(ta, ' 業� �� ���� ' + rtrim(lshifr) + ' ��������� � �ࠢ�筨�� �����')
    endif
  else
    aadd(ta, ' ��� ��襩 �� � �ࠢ�筨�� ����� �� ������� ��㣠: ' + lshifr)
  endif
  return v

** 28.01.14 �뢥�� � 業�� ��࠭� ��⮪�� ��।������ ���
Function f_put_arr_ksg(cLine)
  Local buf := savescreen(), i, nLLen := 0, mc := maxcol() - 1, ;
        nLCol, nRCol, nTRow, nBRow, nNumRows := len(cLine)

  AEVAL(cLine, {|x, i| nLLen := Max(nLLen, Len(x))})
  if nLLen > mc
    nLLen := mc
  endif
  // ���᫥��� ���न��� 㣫��
  nLCol := Int((mc - nLLen) / 2)
  nRCol := nLCol + nLLen + 1
  nTRow := Int((maxrow() - nNumRows) / 2)
  nBRow := nTRow + nNumRows + 1
  PUT_SHADOW(nTRow, nLCol, nBRow, nRCol)
  @ nTRow, nLCol Clear to nBRow, nRCol
  DispBox(nTRow, nLCol, nBRow, nRCol, 2, 'GR/GR*')
  AEVAL(cLine, {|cSayStr, i| ;
                 nSayRow := nTRow + i, ;
                nSayCol := nLCol + 1, ;
                setpos(nSayRow, nSayCol), dispout(padr(cSayStr, nLLen), 'N/GR*') ;
                })
  inkey(0)
  restscreen(buf)
  return NIL

// ** 26.01.18 ��� ��।������ ���
// Function test_definition_KSG()
// Local arr, buf := save_maxrow(), lshifr, lrec, lu_kod, lcena, lyear, mrec_hu, not_ksg := .t.
// stat_msg("��।������ ���")
// R_Use(dir_server + "mo_uch",,'UCH')
// R_Use(dir_server + 'mo_otd',,'OTD')
// Use_base("lusl")
// Use_base("luslc")
// Use_base('uslugi')
// R_Use(dir_server + "schet_",,"SCHET_")
// R_Use(dir_server + "uslugi1",{dir_server + "uslugi1", ;
//                             dir_server + "uslugi1s"},"USL1")
// use_base("human_u") // �᫨ �����������, 㤠���� ���� ��� � �������� ����
// R_Use(dir_server + "mo_su",,"MOSU")
// R_Use(dir_server + "mo_hu",dir_server + "mo_hu","MOHU")
// set relation to u_kod into MOSU
// R_Use(dir_server + "human_2",,"HUMAN_2")
// R_Use(dir_server + "human_",,"HUMAN_")
// G_Use(dir_server + "human",,"HUMAN") // ��१������ �㬬�
// set relation to recno() into HUMAN_, to recno() into HUMAN_2
// n_file := "test_ksg"+stxt
// fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
// go top
// do while !eof()
//   @ maxrow(),0 say str(recno()/lastrec()*100,7,2)+"%" color cColorStMsg
//   if inkey() == K_ESC
//     exit
//   endif
//   if human->K_DATA > stod("20190930") .and. eq_any(human_->USL_OK,1,2)
//     arr := definition_KSG()
//     if len(arr) == 7 // ������
//       add_string("== ������ == ")
//     else
//       aeval(arr[1],{|x| add_string(x) })
//       if !empty(arr[2])
//         add_string("������:")
//         aeval(arr[2],{|x| add_string(x) })
//       endif
//       select HU
//       find (str(human->kod,7))
//       do while hu->kod == human->kod .and. !eof()
//         usl->(dbGoto(hu->u_kod))
//         if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
//           lshifr := usl->shifr
//         endif
//         if alltrim(lshifr) == arr[3] // 㦥 �⮨� �� �� ���
//           if !(round(hu->u_cena,2) == round(arr[4],2)) // �� � 業�
//             add_string("� �/� ��� ���="+arr[3]+" �⮨� 業� "+lstr(hu->u_cena,10,2)+", � ������ ���� "+lstr(arr[4],10,2))
//             if human->schet > 0
//               schet_->(dbGoto(human->schet))
//               add_string("..���� � "+alltrim(schet_->nschet)+" �� "+date_8(schet_->dschet)+"�.")
//             endif
//           endif
//           exit
//         endif
//         select LUSL
//         find (lshifr) // ����� lshifr 10 ������
//         if found() .and. (eq_any(left(lshifr,5),"1.12.") .or. is_ksg(lusl->shifr)) // �⮨� ��㣮� ���
//           add_string("� �/� �⮨� ���="+alltrim(lshifr)+"("+lstr(hu->u_cena,10,2)+;
//                      "), � ������ ���� "+arr[3]+"("+lstr(arr[4],10,2)+")")
//           if human->schet > 0
//             schet_->(dbGoto(human->schet))
//             add_string("..���� � "+alltrim(schet_->nschet)+" �� "+date_8(schet_->dschet)+"�.")
//           endif
//           exit
//         endif
//         select HU
//         skip
//       enddo
//     endif
//     add_string(replicate("*",80))
//   endif
//   select HUMAN
//   skip
// enddo
// close databases
// rest_box(buf)
// fclose(fp)
// return NIL