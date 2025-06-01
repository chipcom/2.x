// prikreplenie.prg - ०��� � �ਪ९������ ��ᥫ����
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 13.07.15 ������ ��᫥���� ������஢���� 䠩�
Function wq_ret_last_name()
  Local s := '', arr_f := {}

  scandirfiles(dir_server, ;
               'mo_wq*' + sdbf, ;
              {|x| aadd(arr_f, Name_Without_Ext(StripPath(x)))})
  if !empty(arr_f)
    asort(arr_f, , ,{|x, y| iif(substr(x, 6, 6) == substr(y, 6, 6), ;
                              val(substr(x, 12)) < val(substr(y, 12)), ;
                              substr(x, 6, 6) < substr(y, 6, 6)) } )
    s := atail(arr_f)
  endif
  return s

// 14.07.15 �஢���� �� �� ��᫥���� (�� ���) �������㥬� 䠩�
Function wq_if_last_file(lname, /*@*/flast)
  Local fl := .t., s := wq_ret_last_name()

  if !empty(s)
    flast := substr(s, 6)
    lname := substr(lname, 10)
    if left(lname, 6) == left(flast, 6)
      if val(substr(lname, 7)) < val(substr(flast, 7))
        fl := .f.
      endif
    elseif left(lname, 6) < left(flast, 6)
      fl := .f.
    endif
  endif
  if !fl
    func_error(4, '��� �� ���⠭ ����� ������� 䠩�. ����� ����樨!')
  endif
  return fl

// 15.10.24 ������ 䠩�� �� ����� � ���⪠�� �ਪ९���� ��� ���
Function wq_import()
  Local adbf, cName, i, s, buf, arr, arr_f, fbase

  Private p_var_manager := 'Read_WQ_TFOMS', full_zip
  if !empty(full_zip := manager(T_ROW, T_COL + 5,maxrow() - 2, , .t., 1, , , ,'WQ2*' + szip()))
    name_zip := StripPath(full_zip)  // ��� 䠩�� ��� ���
    cName := Name_Without_Ext(name_zip)
    fbase := 'mo_wq' + substr(cName, 10)
    if hb_fileExists(dir_server + fbase + sdbf)
      return func_error(4, '����� 䠩� 㦥 �� ������஢��!')
    endif
    R_Use(dir_server + 'mo_krtr', , 'KRTR')
    index on wq to (cur_dir() + 'tmp_krtr') for !empty(wq)
    find (padr(substr(cName, 10), 11))
    fl := found()
    Use
    if fl
      return func_error(4, '����� 䠩� 㦥 �� ������஢��')
    endif
    fl := .f.
    if (arr_f := Extract_Zip_XML(KeepPath(full_zip), name_zip)) != NIL
      if (n := ascan(arr_f, {|x| upper(Name_Without_Ext(x)) == upper(cName)})) > 0
        fl := .t.
      else
        fl := func_error(4, '� ��娢� ' + name_zip + ' ��� 䠩�� ' + cName + sdbf)
      endif
    endif
    /*if (fl := Extract_RAR(KeepPath(full_zip),name_zip)) .and. ;
                                       !hb_fileExists(_tmp_dir1()+cName+sdbf)
      fl := func_error(4, '�������� �訡�� �� ࠧ��娢�஢���� '+_tmp_dir1()+cName+szip())
    endif*/
    last_file := ' '
    if fl .and. wq_if_last_file(cName, @last_file)
      s := cName
      name_dbf := cName + sdbf
      if upper(left(s, 3)) == 'WQ2'
        s := substr(s, 4)
        cMO := substr(s, 1, 6)
        if cMO == glob_MO[_MO_KOD_TFOMS]
          last_file := padr(last_file, 11)
          k := 0
          R_Use(dir_server + 'mo_krtr', , 'KRTR')
          index on wq to (cur_dir() + 'tmp_krtr') for !empty(wq)
          go top
          do while !eof()
            if last_file == krtr->wq
              ++k
            endif
            if krtr->ANSWER == 0
              fl := func_error(4, '�� 䠩� �ਪ९����� ' + rtrim(krtr->fname) + scsv() + ' �� ����祭 �⢥� �� �����!')
            endif
            skip
          enddo
          Use
          if fl .and. !empty(last_file) .and. empty(k)
            fl := func_error(4, '�� �।��饬� 䠩�� mo_wq' + rtrim(last_file) + sdbf + ' �� �� ��⠢��� 䠩� �ਪ९�����')
          endif
          if fl
            R_Use(_tmp_dir1() + cName, , 'T1')
            k := lastrec()
            Use
          else
            k := 0
          endif
          if k > 0
            arr := {glob_MO[_MO_SHORT_NAME]}
            aadd(arr, '��⠥��� 䠩� ' + name_dbf + ' � �ਪ९��� ��ᥫ�����,')
            aadd(arr, '�� ���஬� � ����� ��� �� �ਪ९���� ��� (���⪨) - ' + lstr(k) + ' 祫.')
            buf := save_maxrow()
            if f_alert(arr, {' �⪠� ', ' ������ 䠩�� �ਪ९����� '}, 1, ;
                     'N+/G*', 'N/G*', 16, , 'N/G*') == 2
              adbf := { ;
                  {'kod_k',      'N',      7,      0}, ;
                  {'uchast',     'N',      2,      0}, ;
                  {'fio',        'C',     50,      0}, ;
                  {'ID',         'N',      8,      0}, ;
                  {'FAM',        'C',     40,      0}, ;
                  {'IM',         'C',     40,      0}, ;
                  {'OT',         'C',     40,      0}, ;
                  {'W',          'N',      1,      0}, ;
                  {'DR',         'D',      8,      0}, ;
                  {'SA',         'C',      1,      0}, ;
                  {'RN',         'C',     11,      0}, ;
                  {'INDX',       'C',      6,      0}, ;
                  {'adres',      'C',     90,      0}, ;
                  {'CITY',       'C',     80,      0}, ;
                  {'NP',         'C',     80,      0}, ;
                  {'UL',         'C',     80,      0}, ;
                  {'DOM',        'C',     12,      0}, ;
                  {'KOR',        'C',     12,      0}, ;
                  {'KV',         'C',     12,      0}, ;
                  {'SMO',        'C',      5,      0}, ;
                  {'POLTP',      'N',      1,      0}, ;
                  {'SPOL',       'C',     20,      0}, ;
                  {'NPOL',       'C',     20,      0}, ;
                  {'LPUAUTO',    'N',      1,      0}, ;
                  {'LPU',        'C',      6,      0}, ;
                  {'LPUDT',      'D',      8,      0};
              }
              /* �⥫��� ��
                {'UCHAST',     'N',     10,      0}, ; // ���⮪
                {'SNILS_VR',   'C',     11,      0}, ; // ����� ��.���
                {'KATEG_VR',   'N',      1,      0}, ; // ��⥣��� ���
                {'SNILS',      'C',     11,      0}, ; // ����� ��樥��
                {'vid_ud',     'N',      2,      0}, ; // ��� 㤮�⮢�७�� ��筮��;�� ����஢�� �����;'PKRT_VID �� ''APP_BASE'''
                {'ser_ud',     'C',     10,      0}, ; // ��� 㤮�⮢�७�� ��筮��;;'PKRT_SER �� ''APP_BASE'''
                {'nom_ud',     'C',     20,      0}, ; // ����� 㤮�⮢�७�� ��筮��;;'PKRT_NOM �� ''APP_BASE'''
                {'kemvyd',     'N',      6,      0}, ; // ��� �뤠� ���㬥��;'�ࠢ�筨� ''s_kemvyd''';'PKRT_KEM �� ''APP_BASE'''
                {'kogdavyd',   'D',      8,      0}, ; // ����� �뤠� ���㬥��;;'PKRT_KOGDA �� ''APP_BASE'''
                {'MESTO_R',    'C',    100,      0}, ; // ���� ஦�����
              */
              dbcreate(dir_server + fbase, adbf)
              Use (dir_server + fbase) new alias WQ
              i1 := i2 := 0
              G_Use(dir_server + 'mo_kfio', , 'KFIO')
              index on str(kod, 7) to (cur_dir() + 'tmp_kfio')
              use_base('kartotek')
              R_Use(_tmp_dir1() + cName, , 'T1')
              go top
              do while !eof()
                @ maxrow(), 0 say padr(str(recno() / lastrec() * 100, 6, 2) + '%', maxcol() + 1) color 'W/R'
                MFIO := alltrim(t1->FAM) + ' ' + alltrim(t1->IM) + ' ' + alltrim(t1->OT)
                lkod_k := luchast := 0
                mfio := padr(charone(' ', mfio), 50)
                if !emptyany(mfio, t1->dr)
                  select KART
                  set order to 2
                  s := upper(padr(mfio, 50))
                  find ('1' + s + dtos(t1->dr))
                  if (fl := found())
                    ++i1
                    lkod_k := kart->kod
                    luchast := kart->uchast
                  endif
                  select WQ
                  append blank
                  wq->kod_k   := lkod_k
                  wq->uchast  := luchast
                  wq->fio     := mfio
                  wq->ID      := t1->ID
                  wq->FAM     := t1->FAM
                  wq->IM      := t1->IM
                  wq->OT      := t1->OT
                  wq->W       := t1->W
                  wq->DR      := t1->DR
                  wq->SA      := t1->SA
                  wq->RN      := t1->RN
                  wq->INDX    := t1->INDX
                  wq->CITY    := t1->CITY
                  wq->NP      := t1->NP
                  wq->UL      := t1->UL
                  wq->DOM     := t1->DOM
                  wq->KOR     := t1->KOR
                  wq->KV      := t1->KV
                  wq->SMO     := t1->SMO
                  wq->POLTP   := t1->POLTP
                  wq->SPOL    := t1->SPOL
                  wq->NPOL    := t1->NPOL
                  wq->LPUAUTO := t1->LPUAUTO
                  wq->LPU     := t1->LPU
                  wq->LPUDT   := t1->LPUDT
                  la := ''
                  if !empty(wq->INDX)
                    la += wq->INDX + ' '
                  endif
                  if !emptyall(wq->CITY, wq->NP)
                    if wq->CITY == wq->NP
                      la += alltrim(wq->CITY) + ' '
                    else
                      if !empty(wq->CITY)
                        la += alltrim(wq->CITY) + ' '
                      endif
                      if !empty(wq->NP)
                        la += alltrim(wq->NP) + ' '
                      endif
                    endif
                  endif
                  if !empty(wq->UL)
                    la += alltrim(wq->UL) + ' '
                  endif
                  if !empty(wq->DOM)
                    la += '�.' + alltrim(wq->DOM)
                    if !empty(wq->KOR)
                      if !(left(wq->KOR, 1) == '/')
                        la += '/'
                      endif
                      la += alltrim(wq->KOR)
                    endif
                  endif
                  if !empty(wq->KV)
                    la += ',��.' + alltrim(wq->KV) + ' '
                  endif
                  wq->adres := la
                  if fl
                    lpoltp := iif(between(wq->POLTP, 1, 3), wq->POLTP, 1)
                    if !(kart_->VPOLIS == lpoltp .and. alltrim(kart_->NPOLIS) == alltrim(wq->NPOL))
                      select KART
                      G_RLock(forever)
                      kart->POLIS   := make_polis(wq->SPOL, wq->NPOL)
                      select KART_
                      do while kart_->(lastrec()) < lkod_k
                        APPEND BLANK
                      enddo
                      goto (lkod_k)
                      G_RLock(forever)
                      kart_->VPOLIS := lpoltp
                      kart_->SPOLIS := ltrim(wq->SPOL)
                      kart_->NPOLIS := ltrim(wq->NPOL)
                      kart_->SMO    := wq->SMO
                    endif
                    select KART2
                    do while kart2->(lastrec()) < lkod_k
                      G_RLock(.t., forever) // ��᪮��筠� ����⪠ �������� ������
                      kart2->kod_tf := 0
                      kart2->MO_PR := ''
                      kart2->SNILS_VR := '' // ��.��� ��� �� �ਢ易�
                      kart2->PC2 := ''      // �� 㬥�
                      kart2->PC4 := ''
                    enddo
                    goto (lkod_k)
                    G_RLock(forever)
                    kart2->kod_tf := wq->id
                    kart2->MO_PR := wq->lpu
                    kart2->TIP_PR := wq->LPUAUTO
                    kart2->DATE_PR := wq->lpudt
                    kart2->PC2 := ''      // �� 㬥�
                    if !empty(kart2->DATE_PR)
                      kart2->PC4 := date_8(kart2->DATE_PR)
                    endif
                  else
                    ++i2
                    select KART
                    set order to 1
                    Add1Rec(7)
                    lkod_k := kart->kod := recno()
                    wq->kod_k := lkod_k
                    kart->FIO := wq->fio
                    mdate_r := kart->DATE_R := wq->dr
                    m1VZROS_REB := M1NOVOR := 0
                    fv_date_r()
                    kart->pol := iif(wq->w == 1, '�', '�')
                    kart->VZROS_REB := m1VZROS_REB
                    if TwoWordFamImOt(wq->fam) .or. TwoWordFamImOt(wq->im) ;
                                             .or. TwoWordFamImOt(wq->ot)
                      kart->MEST_INOG := 9
                    else
                      kart->MEST_INOG := 0
                    endif
                    madres := ''
                    if !empty(wq->UL)
                      madres += alltrim(wq->UL) + ' '
                    endif
                    if !empty(wq->DOM)
                      madres += '�.' + alltrim(wq->DOM)
                      if !empty(wq->KOR)
                        if !(left(wq->KOR, 1) == '/')
                          madres += '/'
                        endif
                        madres += alltrim(wq->KOR)
                      endif
                    endif
                    if !empty(wq->KV)
                      madres += ',��.' + alltrim(wq->KV) + ' '
                    endif
                    kart->ADRES := madres
                    select KART_
                    do while kart_->(lastrec()) < lkod_k
                      APPEND BLANK
                    enddo
                    goto (lkod_k)
                    G_RLock(forever)
                    kart->POLIS   := make_polis(wq->SPOL, wq->NPOL)
                    kart_->VPOLIS := iif(between(wq->POLTP, 1, 3), wq->POLTP, 1)
                    kart_->SPOLIS := ltrim(wq->SPOL)
                    kart_->NPOLIS := ltrim(wq->NPOL)
                    kart_->SMO := wq->SMO
                    kart_->okatog := wq->rn
                    if wq->sa == '�' // �� ����� �஦������
                      kart_->okatop := wq->rn
                      kart_->adresp := madres
                    endif
                    select KART2
                    do while kart2->(lastrec()) < lkod_k
                      G_RLock(.t., forever) // ��᪮��筠� ����⪠ �������� ������
                      kart2->kod_tf := 0
                      kart2->MO_PR := ''
                      kart2->SNILS_VR := '' // ��.��� ��� �� �ਢ易�
                      kart2->PC2 := ''      // �� 㬥�
                      kart2->PC4 := ''
                    enddo
                    goto (lkod_k)
                    G_RLock(forever)
                    kart2->kod_tf := wq->id
                    kart2->MO_PR := wq->lpu
                    kart2->TIP_PR := wq->LPUAUTO
                    kart2->DATE_PR := wq->lpudt
                    kart2->PC2 := ''      // �� 㬥�
                    if !empty(kart2->DATE_PR)
                      kart2->PC4 := date_8(kart2->DATE_PR)
                    endif
                    //
                    select KFIO
                    find (str(lkod_k, 7))
                    if found()
                      if kart->MEST_INOG == 9
                        G_RLock(forever)
                        kfio->FAM := ltrim(charone(' ', wq->fam))
                        kfio->IM  := ltrim(charone(' ', wq->im))
                        kfio->OT  := ltrim(charone(' ', wq->ot))
                      else
                        DeleteRec(.t.)
                      endif
                    else
                      if kart->MEST_INOG == 9
                        AddRec(7)
                        kfio->kod := lkod_k
                        kfio->FAM := ltrim(charone(' ', wq->fam))
                        kfio->IM  := ltrim(charone(' ', wq->im))
                        kfio->OT  := ltrim(charone(' ', wq->ot))
                      endif
                    endif
                  endif
                  dbUnlockAll()
                endif
                select T1
                if recno() % 1000 == 0
                  dbCommitAll()
                endif
                skip
              enddo
              close databases
              rest_box(buf)
              n_message({'�⥭�� 䠩�� ' + cName + ' �����襭�!', ;
                       '������� � ����⥪� - ' + lstr(i1) + ' 祫.', ;
                       '������஢��� - ' + lstr(i2) + ' 祫.'}, , 'W/G', 'N/G', , , 'GR/G')
              keyboard chr(K_TAB) + chr(K_ENTER)
            endif
            close databases
            rest_box(buf)
          endif
        else
          func_error(4, '��� ��� �� ' + glob_MO[_MO_KOD_TFOMS] + ;
                     ' �� ᮮ⢥����� ���� �����⥫�: ' + cMO)
        endif
      else
        func_error(4, '����⪠ ������ ��������� 䠩� (䠩� ������ ��稭����� � WQ2...)')
      endif
    endif
  endif
  return NIL

// 13.07.15
Function wq_view()
  Local sh, HH := 78, name_file := cur_dir() + 'imp_prip.txt', i := 0, arr_title, lu, la, ;
        buf := save_maxrow(), fname := wq_ret_last_name()

  if empty(fname)
    return func_error(4, '�� �뫮 �⥭�� 䠩�� � ����� �ଠ�!')
  endif
  mywait()
  arr_title := { ;
  '�����������������������������������������������������������������������������������������������������������������', ;
  ' �� ���               �.�.�                    ���� ஦�.�                     ����', ;
  '�����������������������������������������������������������������������������������������������������������������'}
  fp := fcreate(name_file)
  tek_stroke := 0
  n_list := 1
  sh := len(arr_title[1])
  add_string('')
  add_string(center('���᮪ ��樥�⮢ �� 䠩�� ' + fname, sh))
  add_string('')
  aeval(arr_title, {|x| add_string(x)})
  R_Use(dir_server+fname, , 'WQ')
  index on upper(fio) + dtos(dr) to (cur_dir() + 'tmp_wq')
  go top
  do while !eof()
    if verify_FF(HH, .t., sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(padr(lstr(++i) + '.', 5) + put_val(wq->uchast, 2) + ' ' + padr(wq->fio, 40) + ' ' + ;
               full_date(wq->dr) + ' ' + rtrim(wq->adres))
    skip
  enddo
  fclose(fp)
  close databases
  rest_box(buf)
  viewtext(name_file, , , , .t., , , 6)
  return NIL

// 14.07.15 ����஥ ।���஢���� ���⪮� ᯨ᪮�
Function wq_edit_uchast()
  Local fl, buf := savescreen()

  Private fname := wq_ret_last_name()
  if empty(fname)
    return func_error(4, '�� �뫮 �⥭�� 䠩�� � ����� �ଠ�!')
  endif
  R_Use(dir_server + 'mo_krtr', , 'KRTR')
  index on wq to (cur_dir() + 'tmp_krtr') for !empty(wq)
  find (padr(substr(fname, 10), 11))
  fl := found()
  Use
  if fl
    return func_error(4, '���� �ਪ९����� MO2...CSV �� 䠩�� ' + fname + sdbf + ' 㦥 ��ࠢ��� � �����!')
  endif
  mywait()
  Use_base('kartotek')
  set order to 0
  G_Use(dir_server+fname, , 'WQ')
  index on upper(fio)+dtos(dr) to (cur_dir() + 'tmp_wq')
  go top
  Private ku := wq->(lastrec())
  if ku == 0
    close databases
    restscreen(buf)
    return func_error(4, '��� ����ᥩ!')
  endif
  go top
  Alpha_Browse(2, 0, 23, 79, 'f1_wq_edit_uchast', color0, '������஢���� ���⪮� � 䠩�� ' + fname + ' (' + lstr(ku) + ' 祫.)', 'BG+/GR', ;
             .t., .t., , , 'f2_wq_edit_uchast', , ;
             {'�', '�', '�', 'N/BG, W+/N, B/BG, W+/B, R/BG, BG/R', .t., 180, '*+'})
  close databases
  restscreen(buf)
  return NIL

// 16.01.17
Function f1_wq_edit_uchast(oBrow)
  Local oColumn, blk := {|| iif(wq->uchast <= 0, {3, 4}, {1, 2}) }

  oColumn := TBColumnNew(center('���', 30), {|| padr(wq->fio, 30) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew('��� ஦�.', {|| full_date(wq->dr) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew('��', {|| str(wq->uchast, 2) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(center('����', 31), {|| padr(wq->adres, 31) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  status_key('^<Esc>^ - ��室;  ^<Enter>^ - ।���஢���� ���⪠;  ^<F9>^ - ����� ᯨ᪠')
  return NIL

// 14.07.15
Function f2_wq_edit_uchast(nKey, oBrow)
  Local j := 0, flag := -1, buf := save_maxrow(), fl := .f., nr := row(), c1, rec, arr_title, ;
      mkod, buf0, tmp_color := setcolor(), sh, HH := 78, name_file := cur_dir() + 'wq.txt', i := 0

  Private  much, old_uch
  do case
    case nKey == K_F9
      mywait()
      rec := wq->(recno())
      arr_title := { ;
  '�����������������������������������������������������������������������������������������������������������������', ;
  ' �� ���               �.�.�                    ���� ஦�.�                     ����', ;
  '�����������������������������������������������������������������������������������������������������������������'}
      fp := fcreate(name_file)
      tek_stroke := 0
      n_list := 1
      sh := len(arr_title[1])
      add_string('')
      add_string(center('���᮪ ��樥�⮢ �� 䠩�� ' + fname, sh))
      add_string('')
      aeval(arr_title, {|x| add_string(x) } )
      go top
      do while !eof()
        if verify_FF(HH, .t., sh)
          aeval(arr_title, {|x| add_string(x)})
        endif
        add_string(padr(lstr(++j) + '.', 5) + put_val(wq->uchast, 2) + ' ' + padr(wq->fio, 40) + ' ' + ;
                 full_date(wq->dr) + ' ' + rtrim(wq->adres))
        skip
      enddo
      fclose(fp)
      rest_box(buf)
      viewtext(name_file, , , , .t., , , 6)
      goto (rec)
      flag := 0
    case nKey == K_ENTER
      old_uch := much := wq->uchast
      c1 := 44
      @ nr, c1 get much pict '99' color 'GR+/R'
      myread()
      if lastkey() != K_ESC .and. old_uch != much
        select KART
        goto (wq->kod_k)
        G_RLock(forever)
        kart->uchast := much
        dbunlock()
        select WQ
        G_RLock(forever)
        wq->uchast := much
        dbunlock()
        Commit
        keyboard chr(K_TAB)
      endif
      flag := 0
    otherwise
      keyboard ''
  endcase
  return flag

// 29.03.23 �����⮢�� � ᮧ����� 䠩��� �ਪ९����� ��� WQ...
Function wq_prikreplenie()
  Local i, j := 0, arr_uch := {}, fl_err := .f., buf := save_maxrow(), ;
      fl := .f., filename := wq_ret_last_name()

  if empty(filename)
    return func_error(4, '�� �뫮 �⥭�� 䠩�� � ����� �ଠ�!')
  endif
  Private nkod_reestr := 0
  mywait()
  R_Use(dir_server + 'mo_krtr', , 'KRTR')
  index on wq to (cur_dir() + 'tmp_krtr') for !empty(wq)
  go top
  if eof() // �.�. ���� ࠧ
    nkod_reestr := 1
  else
    find (padr(substr(filename, 10), 11))
    if (fl := found())
      func_error(4, '���� �ਪ९����� ' + rtrim(krtr->fname) + scsv() + ' �� 䠩�� ' + filename + sdbf + ' 㦥 ��ࠢ��� � �����!')
    else
      go bottom
      if krtr->ANSWER == 1
        nkod_reestr := krtr->KOD
      endif
    endif
  endif
  if !fl .and. empty(nkod_reestr)
    fl := !func_error(4, '�� ��᫥���� 䠩� �ਪ९����� �� �� ���⠭ �⢥�. ����� ����樨!')
  endif
  if !fl
    index on dtos(dfile) to (cur_dir() + 'tmp_krtr') for left(fname, 3) == 'MO2'
    find (dtos(sys_date))
    if found()
      fl := !func_error(4, '���� �ਪ९����� � ��⮩ ' + full_date(sys_date) + '�. 㦥 �� ᮧ���')
    endif
  endif
  Use
  rest_box(buf)
  if fl
    return NIL
  endif
  if !f_Esc_Enter('�ਪ९�����')
    return NIL
  endif
  mywait()
  close databases
  if hb_FileExists(dir_server + filename + sdbf)
    mywait()
    //
    R_Use(dir_server + filename, , 'WQ')
    index on upper(fio) + dtos(dr) to (cur_dir() + 'tmp_wq')
    go top
    do while !eof()
      if empty(wq->uchast)
        aadd(arr_uch, alltrim(wq->fio) + ' �.�.' + full_date(wq->dr) + ' ��� ���⪠')
      endif
      skip
    enddo
    close databases
    //
    rest_box(buf)
    if !empty(arr_uch)
      fl_err := .t.
    endif
  else
    fl_err := !func_error(4, '�� ������ ������஢���� 䠩� ' + filename + sdbf)
  endif
  if fl_err
    if !empty(arr_uch)
      mywait()
      cFileProtokol := cur_dir() + 'prot.txt'
      strfile(space(5) + '���᮪ ��樥�⮢ �� 䠩�� ' + filename + sdbf + ' ��� ���⪠' + hb_eol() + hb_eol(), cFileProtokol)
      for i := 1 to len(arr_uch)
        strfile(lstr(i) + '. ' + arr_uch[i] + hb_eol(), cFileProtokol, .t.)
      next
      rest_box(buf)
      viewtext(Devide_Into_Pages(cFileProtokol, 60, 80), , , , .t., , , 2)
    endif
    return NIL
  endif
  mywait()
  dbcreate(cur_dir() + 'tmp', { ;
    {'kod_k',   'N', 7, 0}, ;
    {'kod_wq',  'N', 6, 0}, ;
    {'uchast',  'N', 2, 0}, ;
    {'vr',      'N', 1, 0}})
  use (cur_dir() + 'tmp') new
  j := 0
  R_Use(dir_server + filename, , 'WQ')
  go top
  do while !eof()
    @ maxrow(), 0 say str(++j / wq->(lastrec()) * 100, 6, 2) + '%' color cColorWait
    if (i := ascan(arr_uch, {|x| x[1] == wq->uchast })) == 0
     aadd(arr_uch, {wq->uchast, 0, 0 })
     i := len(arr_uch)
    endif
    select TMP
    append blank
    tmp->kod_k := wq->kod_k
    tmp->kod_wq := wq->(recno())
    tmp->uchast := wq->uchast
    if count_years(wq->dr, sys_date) < 18 // ���
      arr_uch[i, 2] ++
      tmp->vr := 1
    else
      arr_uch[i, 3] ++
      tmp->vr := 0
    endif
    select WQ
    skip
  enddo
  close databases
  rest_box(buf)
  if empty(arr_uch)
    return func_error(4, '�� ������� �ਪ९���� ��樥�⮢ � ���⪠��, �� ��ࠢ������ � �����')
  endif
  asort(arr_uch, , , {|x, y| x[1] < y[1] })
  cFileProtokol := cur_dir() + 'prot.txt'
  strfile(space(5) + '���᮪ ���⪮�' + hb_eol() + hb_eol(), cFileProtokol)
  R_Use(dir_server + 'mo_otd', , 'OTD')
  R_Use(dir_server + 'mo_pers', , 'P2')
  R_Use(dir_server + 'mo_uchvr', , 'UV')
  index on str(uch, 2) to (cur_dir() + 'tmp_uv')
  j := 0
  for i := 1 to len(arr_uch)
    s := str(arr_uch[i, 1], 2) + ':'
    if !empty(arr_uch[i, 2])
      s += '  ��� - ' + lstr(arr_uch[i, 2]) + '祫.'
    endif
    if !empty(arr_uch[i, 3])
      s += '  ����� - ' + lstr(arr_uch[i, 3]) + '祫.'
    endif
    strfile(s + hb_eol(), cFileProtokol, .t.)
    select UV
    find (str(arr_uch[i, 1], 2))
    if found() .and. !emptyall(uv->vrach, uv->vrachv, uv->vrachd)
      select P2
      if empty(uv->vrach)
        if empty(uv->vrachv)
          if !empty(arr_uch[i, 3])
            strfile(space(5) + '�������������� - �� �ਢ易� ���⪮�� ��� � ����� - �� ��ࠢ�塞' + hb_eol(), cFileProtokol, .t.)
          endif
        else
          p2->(dbGoto(uv->vrachv))
          strfile(space(5) + alltrim(p2->fio) + ' (�����)' + hb_eol(), cFileProtokol, .t.)
          f1_wq_prikreplenie(cFileProtokol, @fl_err)
          j += arr_uch[i, 3]
        endif
        if empty(uv->vrachd)
          if !empty(arr_uch[i, 2])
            strfile(space(5) + '�������������� - �� �ਢ易� ���⪮�� ��� � ���� - �� ��ࠢ�塞' + hb_eol(), cFileProtokol, .t.)
          endif
        else
          p2->(dbGoto(uv->vrachd))
          strfile(space(5) + alltrim(p2->fio) + ' (���)' + hb_eol(), cFileProtokol, .t.)
          f1_wq_prikreplenie(cFileProtokol, @fl_err)
          j += arr_uch[i, 2]
        endif
      else
        p2->(dbGoto(uv->vrach))
        strfile(space(5) + alltrim(p2->fio) + iif(emptyany(arr_uch[i, 2], arr_uch[i, 3]), '', ' (�� ��樥���)') + hb_eol(), cFileProtokol, .t.)
        f1_wq_prikreplenie(cFileProtokol, @fl_err)
        j += arr_uch[i, 2] + arr_uch[i, 3]
      endif
    else
      fl_err := .t.
      strfile(space(5) + '!������! �� �ਢ易� ���⪮�� ���' + hb_eol(), cFileProtokol, .t.)
    endif
  next
  close databases
  viewtext(Devide_Into_Pages(cFileProtokol, 60, 80), , , , .t., , , 2)
  if !fl_err .and. j == 0
    return func_error(4, '�� ������� �ਪ९���� ��樥�⮢ � ���⪠��, �� ��ࠢ������ � �����')
  endif
  if !fl_err .and. ;
      f_alert({'� ����� ������ �����⮢���� ' + lstr(j) + ' (������஢�����) ��樥�⮢', ;
             '��� ����祭�� � 䠩� �ਪ९�����', ''}, ;
              {' �⪠� ', ' ������� 䠩� �ਪ९����� '}, ;
              1, 'N+/GR*', 'N/GR*', maxrow() - 8, , 'N/GR*') == 2
    mdate := sys_date
    Private str_sem := 'pripisnoe_naselenie_create_compare'
    if !G_SLock(str_sem)
      return func_error(4, '� ����� ������ � �⨬ ०���� ࠡ�⠥� ��㣮� ���짮��⥫�.')
    endif
    mywait()
    s := 'MO2' + glob_mo[_MO_KOD_TFOMS] + dtos(mdate)
    n_file := s + scsv()
    G_Use(dir_server + 'mo_krtr', , 'KRTR')
    index on str(kod, 6) to (cur_dir() + 'tmp_krtr')
    AddRec(6)
    krtr->KOD := recno()
    krtr->FNAME := s
    krtr->DFILE := mdate
    krtr->DATE_OUT := ctod('')
    krtr->NUMB_OUT := 0
    krtr->WQ := substr(filename, 6) // YYMMDDN - ����砭�� ����� 䠩��
    krtr->KOL := 0
    krtr->KOL_P := 0
    krtr->ANSWER := 0  // 0-�� �뫮 �⢥�, 1-�� ���⠭ �⢥�
    G_Use(dir_server + 'mo_krtf', , 'KRTF')
    index on str(kod, 6) to (cur_dir() + 'tmp_krtf')
    AddRec(6)
    krtf->KOD   := recno()
    krtf->FNAME := krtr->FNAME
    krtf->DFILE := krtr->DFILE
    krtf->TFILE := hour_min(seconds())
    krtf->TIP_IN := 0
    krtf->TIP_OUT := _CSV_FILE_REESTR
    krtf->REESTR := krtr->KOD
    krtf->DWORK := sys_date
    krtf->TWORK1 := hour_min(seconds()) // �६� ��砫� ��ࠡ�⪨
    krtf->TWORK2 := ''                  // �६� ����砭�� ��ࠡ�⪨
    //
    krtr->KOD_F := krtf->KOD
    dbUnLockAll()
    Commit
    //
    blk := {|_s| iif(empty(_s), '', '"' + _s + '"')}
    delete file (n_file)
    fp := fcreate(n_file)
    //
    G_Use(dir_server + 'mo_krtp', , 'KRTP')
    index on str(reestr, 6) to (cur_dir() + 'tmp_krtp')
    mywait('�������� 䠩�� �ਪ९�����')
    j := ii := 0
    R_Use(dir_exe() + '_mo_podr', cur_dir() + '_mo_podr', 'PODR')
    find (glob_mo[_MO_KOD_TFOMS])
    loidmo := alltrim(podr->oidmo)
    R_Use(dir_server + 'mo_otd', , 'OTD')
    R_Use(dir_server + 'mo_pers', , 'P2')
    R_Use(dir_server + 'mo_uchvr', cur_dir() + 'tmp_uv', 'UV')
    R_Use(dir_server + filename, , 'WQ')
    use_base('kartotek')
    set order to 0
    use (cur_dir() + 'tmp') new
    set relation to kod_wq into WQ
    index on upper(wq->fio) to (cur_dir() + 'tmp__')
    go top
    do while !eof()
      @ maxrow(), 0 say str(++j / tmp->(lastrec()) * 100, 6, 2) + '%' color cColorWait
      if (i := ascan(arr_uch, {|x| x[1] == wq->uchast })) == 0
        fl := .f.
      else
        select UV
        find (str(arr_uch[i, 1], 2))
        if found() .and. !emptyall(uv->vrach, uv->vrachv, uv->vrachd)
          select P2
          if empty(uv->vrach)
            fl := .f.
            if empty(uv->vrachv)
              //
            elseif tmp->vr == 0 // �����
              fl := .t.
              p2->(dbGoto(uv->vrachv))
              otd->(dbGoto(p2->otd))
            endif
            if empty(uv->vrachd)
              //
            elseif tmp->vr == 1 // ���
              fl := .t.
              p2->(dbGoto(uv->vrachd))
              otd->(dbGoto(p2->otd))
            endif
          else // ��
            fl := .t.
            p2->(dbGoto(uv->vrach))
            otd->(dbGoto(p2->otd))
          endif
        else
          fl := .f.
        endif
      endif
      if fl
        select KART
        goto (wq->kod_k)
        ++ii
        select KRTP
        AddRec(6)
        krtp->REESTR   := krtr->KOD      // ��� ॥���;�� 䠩�� 'mo_krtr'
        krtp->KOD_K    := wq->kod_k      // ��� ��樥�� �� 䠩�� 'kartotek'
        krtp->D_PRIK   := wq->LPUDT      // ��� �ਪ९����� (������)
        krtp->S_PRIK   := 1              // ᯮᮡ �ਪ९�����: 1-�� ����� ॣ����樨, 2-�� ��筮�� ������ (��� ��������� �/�), 3-�� ��筮�� ������ (� �裡 � ���������� �/�)
        krtp->UCHAST   := wq->uchast     // ����� ���⪠
        krtp->SNILS_VR := p2->snils      // ����� ���⪮���� ���
        krtp->KOD_PODR := alltrim(otd->kod_podr) // ��� ���ࠧ������� �� ��ᯮ��� ���
        krtp->REES_ZAP := ii             // ����� ��ப� � ॥���
        krtp->OPLATA   := 0              // ⨯ ������;᭠砫� 0, 1-�ਪ९��, 2-�訡��
        krtp->D_PRIK1  := ctod('')       // ��� �ਪ९�����
        //
        s1 := iif(ii==1, '', hb_eol())
        // 1 - ����� ����� � 䠩�� � 10.06.19�.
        s1 += eval(blk, lstr(ii)) + ';'
        // 1 - ����⢨�
        s := '�'
        s1 += eval(blk, s) + ';'
        // 2 - ��� ⨯� ����
        s := iif(wq->POLTP==3, '�', iif(wq->POLTP==2, '�', '�'))
        s1 += eval(blk, s) + ';'
        // 3 - ���� � ����� ����
        s := iif(wq->POLTP == 3, '', ;
               iif(wq->POLTP == 2, alltrim(wq->NPOL), ;
                   alltrim(wq->SPOL) + ' � ' + alltrim(wq->NPOL)))
        s1 += eval(blk, f_s_csv(s)) + ';'
        // 4 - ����� ����� ����� ���
        s := iif(wq->POLTP == 3, alltrim(wq->NPOL), '')
        s1 += eval(blk, s) + ';'
        // 5 - ������� �����客������ ���
        s1 += eval(blk, f_s_csv(alltrim(wq->FAM))) + ';'
        // 6 - ��� �����客������ ���
        s1 += eval(blk, f_s_csv(alltrim(wq->IM))) + ';'
        // 7 - ����⢮ �����客������ ���
        s1 += eval(blk, f_s_csv(alltrim(wq->OT))) + ';'
        fl := .f.
        if empty(ldate_r := wq->DR)
          fl := .t. //�� ��������� ���� '��� ஦�����'
        elseif wq->DR >= sys_date
          fl := .t. //��� ஦����� ����� ᥣ����譥� ����
        elseif year(wq->DR) < 1900
          fl := .t. //��� ஦�����: ' + full_date(kart->date_r)+' ( < 1900�.)
        endif
        if fl
          ldate_r := addmonth(sys_date, -18 * 12)
        endif
        // 8 - ��� ஦����� �����客������ ���
        s1 += eval(blk, dtos(ldate_r)) + ';'
        // 9 - ���� ஦����� �����客������ ���
        lmesto_r := ''
        if eq_any(kart_->vid_ud, 3, 14)
          if empty(kart_->mesto_r)
            lmesto_r := '���.������ࠤ'
          else
            lmesto_r := alltrim(del_spec_symbol(kart_->mesto_r))
          endif
        endif
        lmesto_r := charone(' ', CHARREPL('/;', lmesto_r, SPACE(2)))
        s1 += eval(blk, f_s_csv(lmesto_r)) + ';'
        //
        fl := ascan(getVidUd(), {|x| x[2] == kart_->vid_ud }) == 0
        if !fl
          if empty(kart_->nom_ud)
            fl := .t. //������ ���� ��������� ���� '����� 㤮�⮢�७�� ��筮��'
          elseif !ver_number(kart_->nom_ud)
            fl := .t. //���� '����� 㤮�⮢�७�� ��筮��' ������ ���� ��஢�
          elseif !val_ud_nom(2, kart_->vid_ud, kart_->nom_ud)
            fl := .t.
          endif
        endif
        if !fl .and. eq_any(kart_->vid_ud, 1, 3, 14) .and. empty(kart_->ser_ud)
          fl := .t. //�� ��������� ���� '����� 㤮�⮢�७�� ��筮��'
        endif
        if !fl .and. !empty(kart_->ser_ud) .and. !val_ud_ser(2, kart_->vid_ud, kart_->ser_ud)
          fl := .t.
        endif
        if fl
          // 10 - ��� ���㬥��, 㤮�⮢����饣� ��筮���
          s1 += eval(blk, '') + ';'
          // 11 - ����� ��� ��� � ����� ���㬥��, 㤮�⮢����饣� ��筮���.
          s1 += eval(blk, '') + ';'
        else
          // 10 - ��� ���㬥��, 㤮�⮢����饣� ��筮���
          s1 += eval(blk, lstr(kart_->vid_ud)) + ';'
          // 11 - ����� ��� ��� � ����� ���㬥��, 㤮�⮢����饣� ��筮���.
          s := alltrim(kart_->ser_ud) + ' � ' + alltrim(kart_->nom_ud)
          s1 += eval(blk, f_s_csv(s)) + ';'
        endif
        // 12 - ��� �뤠� ���㬥��, 㤮�⮢����饣� ��筮���
        lkogdavyd := kart_->kogdavyd
        if !empty(kart_->kogdavyd) .and. !between(kart_->kogdavyd, kart->date_r, sys_date)
          if kart_->vid_ud == 3 // ᢨ�_�� � ஦�����
            lkogdavyd := kart->date_r
          else
            lkogdavyd := ctod('')
          endif
        endif
        s := iif(empty(lkogdavyd), '', dtos(lkogdavyd))
        s1 += eval(blk, s) + ';'
        // 13 - ������������ �࣠��, �뤠�襣� ���㬥��
        s := alltrim(inieditspr(A__POPUPMENU, dir_server + 's_kemvyd', kart_->kemvyd))
        s1 += eval(blk, f_s_csv(s)) + ';'
        // 14 - ����� �����客������ ���
        if !empty(lsnils := kart->snils) .and. !val_snils(kart->snils, 2)
          lsnils := ''
        endif
        s1 += eval(blk, alltrim(lsnils)) + ';'
        // 15 - �����䨪��� ��
        s1 += eval(blk, glob_mo[_MO_KOD_TFOMS]) + ';'
        // 16 - ���ᮡ �ਪ९�����
        s1 += eval(blk, lstr(krtp->S_PRIK)) + ';'
        // 17 - ��� �ਪ९����� (��१�ࢨ஢����� ����)
        s1 += eval(blk, '') + ';'
        // 18 - ��� �ਪ९�����
        ld_prik := krtp->D_PRIK
        if !between(krtp->D_PRIK, wq->DR, sys_date)
          ld_prik := sys_date - 1
        endif
        s1 += eval(blk, dtos(ld_prik)) + ';'
        // 19 - ��� ��९�����
        s1 += eval(blk, '') + ';'
        // 20 ��� ��
        s1 += eval(blk, f_s_csv(loidmo)) + ';'
        // 21 ��� ���ࠧ�������
        s := alltrim(otd->kod_podr)
        s1 += eval(blk, f_s_csv(s)) + ';'
        // 22 ����� ���⪠
        s := lstr(wq->uchast)
        s1 += eval(blk, s) + ';'
        // 23 ����� ���
        s := p2->snils
        s1 += eval(blk, s) + ';'
        // 24 ��⥣��� ���
        s := iif(p2->kateg == 1, '1', '2')
        s1 += eval(blk, s)
        //
        fwrite(fp, hb_OemToAnsi(s1))
      endif
      if ii % 3000 == 0
        dbUnLockAll()
        Commit
      endif
      select TMP
      skip
    enddo
    fclose(fp)
    select KRTR
    G_RLock(forever)
    krtr->KOL := ii
    select KRTF
    G_RLock(forever)
    krtf->KOL := ii
    krtf->TWORK2 := hour_min(seconds()) // �६� ����砭�� ��ࠡ�⪨
    close databases
    G_SUnLock(str_sem)
    rest_box(buf)
    if ii > 0 .and. hb_FileExists(n_file)
      chip_copy_zipXML(n_file, dir_server + dir_XML_MO(), .t.)
      stat_msg('���� �ਪ९����� ᮧ���!')
      mybell(3, OK)
      keyboard chr(K_ESC) + chr(K_HOME) + chr(K_ENTER)
    else
      func_error(4, '�訡�� ᮧ����� 䠩�� ' + n_file)
    endif
  endif
  return NIL

// 03.08.23
function text_error_to_file(cFileProtokol)
  strfile('!������!' + hb_eol(), cFileProtokol, .t.)
  return nil

// 03.08.23
Function f1_wq_prikreplenie(cFileProtokol, /*@*/is_err)
  Local s

  if p2->kateg != 1
    is_err := .t.
    text_error_to_file(cFileProtokol)
    strfile(space(5) + '!������! � ᯥ樠���� � �ࠢ�筨�� ���ᮭ��� ��⥣��� ������ ���� ����' + hb_eol(), cFileProtokol, .t.)
  elseif empty(p2->snils)
    is_err := .t.
    text_error_to_file(cFileProtokol)
    strfile(space(5) + '!������! �� ������ ����� � ��� � �ࠢ�筨�� ���ᮭ���' + hb_eol(), cFileProtokol, .t.)
  else
    s := space(80)
    if !val_snils(p2->snils, 2, @s)
      is_err := .t.
      text_error_to_file(cFileProtokol)
      strfile(space(5) + '!������! '+s+' � ��� � �ࠢ�筨�� ���ᮭ���' + hb_eol(), cFileProtokol, .t.)
    endif
  endif
  if empty(p2->otd)
    is_err := .t.
    text_error_to_file(cFileProtokol)
    strfile(space(5) + '!������! �� ���⠢���� �⤥����� � ��� � �ࠢ�筨�� ���ᮭ���' + hb_eol(), cFileProtokol, .t.)
  else
    select OTD
    goto (p2->otd)
    if empty(otd->kod_podr)
      is_err := .t.
      text_error_to_file(cFileProtokol)
      strfile(space(5) + '!������! � ��."' + alltrim(otd->name) + '" �� ���⠢��� ��� ���ࠧ�������' + hb_eol(), cFileProtokol, .t.)
    endif
  endif
  return NIL

// 09.06.16 �������� ';' � ���� �� ' ' ��� ��ࠢ�� � 䠩�� CSV
Function f_s_csv(s)
  Static c := ';'

  if c $ s
    s := charrepl(c, s, ' ')
  endif
  return charone(' ', s)