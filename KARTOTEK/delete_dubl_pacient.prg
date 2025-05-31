// delete_dubl_pacient.prg - ०�� 㤠����� �㡫���⮢ �� ����⥨
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

//
Function dubl_zap_1(r, c)
  Local mas_pmt := {'~���� �㡫�������� ����ᥩ', ;
                    '~�������� �㡫�������� ����ᥩ'}
  Local mas_msg := {'���� �㡫�������� ����ᥩ � ����⥪�', ;
                    '�������� �㡫�������� ����ᥩ �� ����⥪�'}
  Local mas_fun := {'f1dubl_zap()', ;
                    'f2dubl_zap()'}

  DEFAULT r TO T_ROW, c TO T_COL + 5
  popup_prompt(r, c, 1, mas_pmt, mas_msg, mas_fun)
  return NIL

// 09.07.18
Function f1dubl_zap_1()
  Static si := 1
  Local hGauge, sh, HH := 77, name_file := cur_dir() + 'dubl_zap.txt', j1, ;
      fl := .t., k := 0, rec1, curr := 0, ;
      mfio, mdate_r, mpolis, arr_title, reg_print := 4, ;
      arr := {' �� ~���+��� ஦�. ', ' �� ~������ ', ' �� ~����� ', ' �� ~��� '}

  if (i := f_alert({'�롥��, ����� ��ࠧ�� �㤥� �����⢫����� ���� �㡫���⮢ ����ᥩ:', ;
                  ''}, ;
                  arr, ;
                  si, 'N+/BG', 'R/BG', 15, , col1menu )) == 0
    return NIL
  endif
  si := i
  if !myFileDeleted(cur_dir + 'tmp' + sdbf)
    return NIL
  endif
  if !myFileDeleted(cur_dir + 'tmpitg' + sdbf)
    return NIL
  endif
  dbcreate(cur_dir + 'tmpitg', { ;
    {'ID','N', 8, 0}, ;
    {'fio','C', 50, 0}, ;
    {'DATE_R','D', 8, 0}, ;
    {'kod_kart','N', 8, 0}, ;
    {'kod_tf','N', 10, 0}, ;
    {'kod_mis','C', 20, 0}, ;
    {'adres','C', 50, 0}, ;
    {'fio','C', 50, 0}, ;
    {'pol','C', 1, 0}, ;
    {'polis','C', 17, 0}, ;
    {'uchast','N', 2, 0}, ;
    {'KOD_VU','N', 5, 0}, ; // ��� � ���⪥
    {'snils','C', 17, 0}, ;
    {'DATE_PR','D', 8, 0}, ;
    {'MO_PR','C', 6, 0} ;
  })
  use (cur_dir + 'tmpitg') new
  R_Use(dir_server + 'kartote2', , 'KART2')
  //
  status_key('^<Esc>^ - ��ࢠ�� ����')
  hGauge := GaugeNew(, , , '���� �㡫�������� ����ᥩ', .t.)
  GaugeDisplay( hGauge )
  if i == 1
    arr_title := {'������������������������������������������������������������������', ;
                  ' NN �                   �.�.�.                    � ��� �.����-��', ;
                  '������������������������������������������������������������������'}
    sh := len(arr_title[1])
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    add_string('')
    add_string(center('���᮪ �㡫�������� ����ᥩ � ����⥪�', sh))
    add_string(center('(�ࠢ����� �� ���� "�.�.�." + "��� ஦�����")', sh))
    add_string('')
    aeval(arr_title, {|x| add_string(x) })
    dbcreate(cur_dir + 'tmp', {{'fio','C', 50, 0}, {'DATE_R','D', 8, 0}})
    use (cur_dir + 'tmp') new
    index on upper(fio) + dtos(date_r) to (cur_dir + 'tmp')
    R_Use(dir_server + 'kartotek', dir_server + 'kartoten', 'KART')
    set relation to recno() into KART2
    index on upper(fio)+dtos(date_r) to (cur_dir + 'tmp_kart') for kod > 0
    go top
    do while !eof()
      GaugeUpdate( hGauge, ++curr / lastrec() )
      if inkey() == K_ESC
        add_string(replicate('*', sh))
        add_string(expand('����� �������'))
        stat_msg('���� ��ࢠ�!')
        mybell(1, OK)
        exit
      endif
      mfio := upper(kart->fio)
      mdate_r := kart->date_r
      rec1 := recno()
      j1 := 0
      find (mfio+dtos(mdate_r))
      do while upper(kart->fio) == mfio .and. kart->date_r == mdate_r .and. !eof()
        if kart->(recno()) != rec1
          j1++
        endif
        skip
      enddo
      goto (rec1)
      if j1 > 0
        select TMP
        find (mfio + dtos(mdate_r))
        if !found()
          append blank
          tmp->fio := mfio
          tmp->date_r := mdate_r
          if verify_FF(HH, .t., sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          ++k
          add_string(put_val(k, 4) + '. ' + padr(mfio, 44) + ' ' + date_8(mdate_r) + str(j1 + 1, 5))
          select TMPITG
          append blank
          TMPITG->id       := k
          TMPITG->fio      := kart->fio
          TMPITG->DATE_R   := kart->date_r
          TMPITG->kod_kart := kart->kod
          TMPITG->adres    := kart->adres
          TMPITG->pol      := kart->pol
          TMPITG->polis    := kart->polis
          TMPITG->uchast   := kart->uchast
          TMPITG->kod_vu   := kart->kod_vu
          TMPITG->snils    := transform(kart->snils, picture_pf)
          TMPITG->DATE_PR  := kart2->date_pr
          TMPITG->MO_PR    := kart2->mo_pr
          TMPITG->kod_tf   := kart2->kod_tf
          TMPITG->kod_mis  := kart2->kod_mis
          if lastrec() % 1000 == 0
            commit
          endif
        endif
      endif
      @ maxrow(), 1 say lstr(curr) color 'W+/R'
      @ row(), col() say '/' color 'W/R'
      @ row(), col() say lstr(k) color 'G+/R'
      select KART
      skip
    enddo
  elseif i == 2
    mpolis := space(17)
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    arr_title := { ;
      '��������������������������������������������������������������������������������������������', ;
      ' NN �      �����      �� ���.�. �                      �.�.�.                      � ��� �.', ;
      '��������������������������������������������������������������������������������������������'}
    sh := len(arr_title[1])
    reg_print := 5
    add_string('')
    add_string(center('���᮪ �㡫�������� ����ᥩ � ����⥪�', sh))
    add_string(center('(�ࠢ����� �� ���� "�����")', sh))
    add_string('')
    aeval(arr_title, {|x| add_string(x) } )
    dbcreate(cur_dir + 'tmp', {{'POLIS','C', 17, 0}})
    use (cur_dir + 'tmp') new
    index on polis to (cur_dir + 'tmp')
    R_Use(dir_server + 'kartotek', dir_server + 'kartotep', 'KART')
    set relation to recno() into KART2
    find ('1')
    do while !eof()
      GaugeUpdate( hGauge, ++curr / lastrec() )
      if inkey() == K_ESC
        add_string(replicate('*', sh))
        add_string(expand('����� �������'))
        stat_msg('���� ��ࢠ�!')
        mybell(1, OK)
        exit
      endif
      if kart->kod > 0 .and. !empty(CHARREPL('*-0', kart->polis, space(3)))
        mpolis := kart->polis
        mfio := kart->fio
        rec1 := recno()
        j1 := 0
        find ('1' + mpolis)
        do while kod > 0 .and. kart->polis == mpolis .and. !eof()
          if recno() != rec1
            j1++
          endif
          skip
        enddo
        goto (rec1)
        if j1 > 0
          select TMP
          find (mpolis)
          if !found()
            append blank
            tmp->polis := mpolis
            ++k
            j1 := 0
            select KART
            find ('1' + mpolis)
            do while kod > 0 .and. kart->polis == mpolis .and. !eof()
              if verify_FF(HH, .t., sh)
                aeval(arr_title, {|x| add_string(x) } )
              endif
              ++j1
              s := iif(j1 == 1, padr(lstr(k) + '.', 5), space(5))
              add_string(s + mpolis + ' ' + padr(amb_kartaN(.t.), 10) + ;
                       padr(kart->fio, 50) + ' ' + date_8(kart->date_r))
              select TMPITG
              append blank
              TMPITG->id       := k
              TMPITG->fio      := kart->fio
              TMPITG->DATE_R   := kart->date_r
              TMPITG->kod_kart := kart->kod
              TMPITG->adres    := kart->adres
              TMPITG->pol      := kart->pol
              TMPITG->polis    := kart->polis
              TMPITG->uchast   := kart->uchast
              TMPITG->kod_vu   := kart->kod_vu
              TMPITG->snils    := transform(kart->snils, picture_pf)
              TMPITG->DATE_PR  := kart2->date_pr
              TMPITG->MO_PR    := kart2->mo_pr
              TMPITG->kod_tf   := kart2->kod_tf
              TMPITG->kod_mis  := kart2->kod_mis
              if lastrec() % 1000 == 0
                commit
              endif
              select KART
              skip
            enddo
            goto (rec1)
          endif
          select KART
        endif
      endif
      @ maxrow(), 1 say lstr(curr) color 'W+/R'
      @ row(), col() say '/' color 'W/R'
      @ row(), col() say lstr(k) color 'G+/R'
      skip
    enddo
  elseif i == 3
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    arr_title := { ;
      '�����������������������������������������������������������������������������������������', ;
      ' NN �    �����     �� ���.�. �                      �.�.�.                      � ��� �.', ;
      '�����������������������������������������������������������������������������������������'}
    sh := len(arr_title[1])
    reg_print := 5
    add_string('')
    add_string(center('���᮪ �㡫�������� ����ᥩ � ����⥪�', sh))
    add_string(center('(�ࠢ����� �� ���� "�����")', sh))
    add_string('')
    aeval(arr_title, {|x| add_string(x) } )
    dbcreate(cur_dir + 'tmp', {{'SNILS', 'C', 11, 0}})
    use (cur_dir + 'tmp') new
    index on snils to (cur_dir + 'tmp')
    R_Use(dir_server + 'kartotek', dir_server + 'kartotes', 'KART')
    set relation to recno() into KART2
    find ('1')
    do while !eof()
      GaugeUpdate( hGauge, ++curr / lastrec() )
      if inkey() == K_ESC
        add_string(replicate('*', sh))
        add_string(expand('����� �������'))
        stat_msg('���� ��ࢠ�!')
        mybell(1,OK)
        exit
      endif
      if kart->kod > 0 .and. !empty(CHARREPL('0', kart->snils, ' '))
        msnils := kart->snils
        mfio := kart->fio
        rec1 := recno()
        j1 := 0
        find ('1' + msnils)
        do while kod > 0 .and. kart->snils == msnils .and. !eof()
          if recno() != rec1
            j1++
          endif
          skip
        enddo
        goto (rec1)
        if j1 > 0
          select TMP
          find (msnils)
          if !found()
            append blank
            tmp->snils := msnils
            ++k
            j1 := 0
            select KART
            find ('1' + msnils)
            do while kod > 0 .and. kart->snils == msnils .and. !eof()
              if verify_FF(HH, .t., sh)
                aeval(arr_title, {|x| add_string(x)})
              endif
              ++j1
              s := iif(j1 == 1, padr(lstr(k) + '.', 5), space(5))
              add_string(s + transform(msnils, picture_pf) + ' ' + padr(amb_kartaN(.t.), 10) + ;
                       padr(kart->fio, 50) + ' ' + date_8(kart->date_r))
              select TMPITG
              append blank
              TMPITG->id       := k
              TMPITG->fio      := kart->fio
              TMPITG->DATE_R   := kart->date_r
              TMPITG->kod_kart := kart->kod
              TMPITG->adres    := kart->adres
              TMPITG->pol      := kart->pol
              TMPITG->polis    := kart->polis
              TMPITG->uchast   := kart->uchast
              TMPITG->kod_vu   := kart->kod_vu
              TMPITG->snils    := transform(kart->snils, picture_pf)
              TMPITG->DATE_PR  := kart2->date_pr
              TMPITG->MO_PR    := kart2->mo_pr
              TMPITG->kod_tf   := kart2->kod_tf
              TMPITG->kod_mis  := kart2->kod_mis
              if lastrec() % 1000 == 0
                commit
              endif
              select KART
              skip
            enddo
            goto (rec1)
          endif
          select KART
        endif
      endif
      @ maxrow(), 1 say lstr(curr) color 'W+/R'
      @ row(), col() say '/' color 'W/R'
      @ row(), col() say lstr(k) color 'G+/R'
      skip
    enddo
  elseif i == 4
    arr_title := { ;
        '�������������������������������������������������������������������������������������������', ;
        ' NN �       ���      � � ���.�.�                     �.�.�.                       � ��� �.', ;
        '�������������������������������������������������������������������������������������������'}
    sh := len(arr_title[1])
    reg_print := 5
    fp := fcreate(name_file)
    n_list := 1
    tek_stroke := 0
    add_string('')
    add_string(center('���᮪ �㡫�������� ����ᥩ � ����⥪�', sh))
    add_string(center('(�ࠢ����� �� ���� ��� "����� ����� �����")', sh))
    add_string('')
    aeval(arr_title, {|x| add_string(x) } )
    dbcreate(cur_dir + 'tmp', {{'kod_mis', 'C', 20, 0}})
    use (cur_dir + 'tmp') new
    index on kod_mis to (cur_dir + 'tmp')
    R_Use(dir_server + 'kartote_', , 'KART_')
    R_Use(dir_server + 'kartotek', , 'KART')
    select KART2
    set relation to recno() into KART, to recno() into KART_
    index on kod_mis to (cur_dir + 'tmp_kodmis') for !empty(kod_mis) .and. !empty(kart->kod)
    go top
    do while !eof()
      GaugeUpdate( hGauge, ++curr / lastrec() )
      if inkey() == K_ESC
        add_string(replicate('*', sh))
        add_string(expand('����� �������'))
        stat_msg('���� ��ࢠ�!')
        mybell(1,OK)
        exit
      endif
      mkod_mis := kart2->kod_mis
      mfio := kart->fio
      rec1 := recno()
      j1 := 0
      find (mkod_mis)
      do while kart2->kod_mis == mkod_mis .and. !eof()
        if recno() != rec1
          j1++
        endif
        skip
      enddo
      goto (rec1)
      if j1 > 0
        select TMP
        find (mkod_mis)
        if !found()
          append blank
          tmp->kod_mis := mkod_mis
          ++k
          j1 := 0
          select KART2
          find (mkod_mis)
          do while kart2->kod_mis == mkod_mis .and. !eof()
            if verify_FF(HH, .t., sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            ++j1
            s := iif(j1 == 1, padr(lstr(k) + '.', 5), space(5))
            add_string(s + left(mkod_mis, 16) + ' ' + padr(amb_kartaN(.t.), 10) + ;
                     padr(alltrim(kart->fio) + ' (' + alltrim(inieditspr(A__MENUVERT, mm_vid_polis, kart_->VPOLIS)) + ;
                          ' �����)', 50) + ' ' + date_8(kart->date_r))
            select TMPITG
            append blank
            TMPITG->id       := k
            TMPITG->fio      := kart->fio
            TMPITG->DATE_R   := kart->date_r
            TMPITG->kod_kart := kart->kod
            TMPITG->adres    := kart->adres
            TMPITG->pol      := kart->pol
            TMPITG->polis    := kart->polis
            TMPITG->uchast   := kart->uchast
            TMPITG->kod_vu   := kart->kod_vu
            TMPITG->snils    := transform(kart->snils, picture_pf)
            TMPITG->DATE_PR  := kart2->date_pr
            TMPITG->MO_PR    := kart2->mo_pr
            TMPITG->kod_tf   := kart2->kod_tf
            TMPITG->kod_mis  := kart2->kod_mis
            if lastrec() % 1000 == 0
              commit
            endif
            select KART2
            skip
          enddo
        endif
      endif
      select KART2
      goto (rec1)
      @ maxrow(), 1 say lstr(curr) color 'W+/R'
      @ row(), col() say '/' color 'W/R'
      @ row(), col() say lstr(k) color 'G+/R'
      skip
    enddo
  endif
  close databases
  fclose(fp)
  CloseGauge(hGauge)
  if k == 0
    func_error(4, '�� ������� �㡫�������� ����ᥩ!')
  else
  viewtext(name_file, , , , .t., , , reg_print)
  endif
  return NIL

// 20.07.23
Function f2dubl_zap_1()
  Local buf := savescreen()

  Private dubl1_kart := 0, dubl2_kart := 0, top_frm
  setcolor(color0)
  box_shadow(15, 2, 22, 77)
  str_center(17, '� ��饬 ᯨ᪥ ᭠砫� �⬥砥��� 祫����, ���஬� �㤥� ��७�ᥭ� ���')
  str_center(18, '���ଠ�� �� 㤠�塞�� ����窨 - �� �뤥����� ᨭ�� 梥⮬.')
  mark_keys({'�� �뤥�����'}, col_tit_popup)
  mark_keys({'ᨭ�� 梥⮬'}, 'W+/B')
  str_center(19, '��⥬ �⬥砥��� ����窠 㤠�塞��� 祫�����;')
  str_center(20, '㤠�塞�� ������ �뤥����� ���� 梥⮬.')
  mark_keys({'㤠�塞�� ������ �뤥�����'}, 'R/BG')
  mark_keys({'���� 梥⮬'}, 'W+/R')
  RunStr('������ ���� �������', 21, 3, 76, 'W+/BG')
  box_shadow(0, 2, 0, 77, color1, , , 0)
  str_center(0, '�������� �㡫�������� ����ᥩ � ����⥪�', color8)
  if view_kart(3) .and. dubl1_kart > 0 .and. dubl2_kart > 0
    mywait()
    Use_base('kartotek')
    // �뢮� �� �࠭ ���ଠ樨
    top_frm := 0
    goto (dubl1_kart)
    kartotek_to_screen(1, 8)
    @ 0, 0 to 9, 79 color 'G+/B'
    str_center(0,' �������, ���஬� ��७����� ���ଠ�� ', 'G+/RB')
    top_frm := 10
    goto (dubl2_kart)
    kartotek_to_screen(11, 18)
    @ 10, 0 to 19, 79 double color color8
    str_center(10, ' �������, ����� 㤠����� ', 'GR+/R')
    FillScrArea(20, 0, 24, 79, '�' ,color1)
    if !G_SLock('������஢���� ����⥪� ' + lstr(dubl2_kart))
      func_error(4, '� ����� ������ � ����窮� 㤠�塞��� 祫����� ࠡ�⠥� ��㣮� ���짮��⥫�.')
    else
      if f_Esc_Enter(2, .t.)
        mywait()
        // ᯨ᮪ ��樥�⮢ � ॥���� ����� ��ᯠ��ਧ�権
        /*G_Use(dir_server + 'mo_r01k', ,'R01K')
        index on str(kod_k, 7) to (cur_dir + 'tmp_r01k')
        do while .t.
          find (str(dubl2_kart, 7))
          if !found()
            exit
          endif
          G_RLock(forever)
          r01k->kod_k := dubl1_kart
        enddo
        close databases*/
        // ���ࠢ����� �� ��ᯨ⠫�����
        G_Use(dir_server + 'mo_nnapr', , 'NAPR')
        delete_dubl_rec_in_file('NAPR', kod_k, dubl1_kart, dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir + 'tmp_napr')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   napr->kod_k := dubl1_kart
        // enddo
        // close databases // �� ��直� ��砩
        //
        if hb_fileExists(dir_server + 'mo_dnab' + sntx())
          Use_base('mo_dnab') // ����� 'DN'
          delete_dubl_rec_in_file('DN', kod_k, dubl1_kart, dubl2_kart, .f.)
          // do while .t.
          //   find (str(dubl2_kart, 7))
          //   if !found()
          //     exit
          //   endif
          //   G_RLock(forever)
          //   dn->kod_k := dubl1_kart
          // enddo
          // close databases // �� ��直� ��砩
        endif
        //
        G_Use(dir_server + 'human', dir_server + 'humankk', 'HUMAN')
        delete_dubl_rec_in_file('HUMAN', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   human->kod_k := dubl1_kart
        // enddo
        // close databases // �� ��直� ��砩 (���� ࠡ�⠥� ����� ���)
        //
        G_Use(dir_server + 'mo_kinos', dir_server + 'mo_kinos', 'KIS')
        delete_dubl_rec('KIS', dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   DeleteRec(.t.)
        // enddo
        //
        G_Use(dir_server + 'mo_kismo', , 'SN')
        delete_dubl_rec('SN', dubl2_kart, .t.)
        // index on str(kod, 7) to (cur_dir + 'tmp_ismo')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   DeleteRec(.t.)
        // enddo
        // ����� ��㣨
        G_Use(dir_server + 'hum_p', dir_server + 'hum_pkk', 'HUM_P')
        delete_dubl_rec_in_file('HUM_P', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   hum_p->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // ��⮯����
        G_Use(dir_server + 'hum_ort', dir_server + 'hum_ortk', 'HUM_O')
        delete_dubl_rec_in_file('HUM_O', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   hum_o->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // �ਥ��� �����
        G_Use(dir_server + 'mo_pp', dir_server + 'mo_pp_r', 'PP')
        delete_dubl_rec_in_file('HU', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   pp->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // ���� �����
        G_Use(dir_server + 'kas_pl', dir_server + 'kas_pl1', 'KASP')
        delete_dubl_rec_in_file('KASP', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   kasp->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // ���� ��⮯����
        G_Use(dir_server + 'kas_ort', dir_server + 'kas_ort1', 'KASO')
        delete_dubl_rec_in_file('KASO', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   kaso->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // ������� ॣ���� �����客�����
        G_Use(dir_server + 'kart_etk')
        delete_dubl_rec('KPRIM1', dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir + 'tmp_kart_etk')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   DeleteRec(.t.)
        // enddo
        // �ਬ�砭�� � ����⥪�
        G_Use(dir_server + 'k_prim1', dir_server + 'k_prim1', 'K_PRIM1')
        delete_dubl_rec('KPRIM1', dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   DeleteRec(.t.)
        // enddo
        // ����� �� ��� � �����������
        G_Use(dir_server + 'plat_vz', , 'PVZ')
        index on str(kod_k, 7) to (cur_dir + 'tmp_pvz')
        set index to (cur_dir + 'tmp_pvz'), (dir_server + 'plat_vz')
        delete_dubl_rec_in_file('PVZ', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   pvz->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // ॣ������ ���� �/�
        G_Use(dir_server + 'mo_regi', {dir_server + 'mo_regi1', ;
                                  dir_server + 'mo_regi2', ;
                                  dir_server + 'mo_regi3'}, 'RU')
        set order to 3
        delete_dubl_rec_in_file('RU', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   ru->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // ����
        G_Use(dir_server + 'msek', dir_server + 'msek', 'MSEK')
        delete_dubl_rec_in_file('MSEK', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   msek->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // c��᮪ ����祪 ��樥�⮢ � ��᫠���� 室�⠩�⢠�
        G_Use(dir_server + 'mo_hod_k', , 'HK')
        delete_dubl_rec_in_file('HK', kod_k, dubl1_kart, dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir + 'tmp_hk')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   hk->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // ᯨ᮪ �ਪ९����� �� ��樥��� �� �६���
        G_Use(dir_server + 'mo_kartp', dir_server + 'mo_kartp', 'KARTP')
        delete_dubl_rec_in_file('KARTP', kod_k, dubl1_kart, dubl2_kart, .f.)
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   kartp->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // ᯨ᮪ ����祪 � ॥���� �� �ਪ९�����
        G_Use(dir_server + 'mo_krtp', , 'KRTP')
        delete_dubl_rec_in_file('KRTP', kod_k, dubl1_kart, dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir + 'tmp_krtp')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   krtp->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // ᯨ᮪ �訡�� � ॥���� �� �ਪ९�����
        G_Use(dir_server + 'mo_krte', , 'KRTE')
        delete_dubl_rec_in_file('KRTE', kod_k, dubl1_kart, dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir + 'tmp_krte')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   krte->kod_k := dubl1_kart
        //   UnLock
        // enddo
        // ᯨ᮪ ����祪 � 䠩��� �� ��९�����
        G_Use(dir_server + 'mo_krto', , 'KRTO')
        delete_dubl_rec_in_file('KRTO', kod_k, dubl1_kart, dubl2_kart, .t.)
        // index on str(kod_k, 7) to (cur_dir + 'tmp_krto')
        // do while .t.
        //   find (str(dubl2_kart, 7))
        //   if !found()
        //     exit
        //   endif
        //   G_RLock(forever)
        //   krto->kod_k := dubl1_kart
        //   UnLock
        // enddo
        //
        Use_base('kartotek')
        set order to 0
        select KART
        goto (dubl2_kart)
        // �.�. relation
        select KART2
        goto (dubl2_kart)
        if !eof()
          DeleteRec(.t., .f.)  // ���⪠ ����� ��� ����⪨ �� 㤠�����
        endif
        select KART_
        goto (dubl2_kart)
        if !eof()
          DeleteRec(.t., .f.)  // ���⪠ ����� ��� ����⪨ �� 㤠�����
        endif
        select KART
        goto (dubl2_kart)
        DeleteRec(.t., .f.)  // ���⪠ ����� ��� ����⪨ �� 㤠�����
        close databases
        stat_msg('�㡫�������� ������ 㤠���� �� ����⥪�!')
        mybell(2, OK)
      endif
      G_SUnLock('������஢���� ����⥪� ' + lstr(dubl2_kart))
    endif
    close databases
    glob_kartotek := dubl1_kart
  endif
  restscreen(buf)
  return NIL

// 20.07.23
function delete_dubl_rec_in_file(cAlias, kod_k, dubl1_kart, dubl2_kart, lIndex)
  local name_index := cur_dir + 'tmp_' + cAlias

  default lIndex to .f.
  if lIndex
    (cAlias)->(dbCreateIndex(name_index, 'str(kod_k, 7)', , nil))
  endif
  do while .t.
    (cAlias)->(dbSeek(str(dubl2_kart, 7)))
    if ! (cAlias)->(found())
      exit
    endif
    G_RLock(forever)
    (cAlias)->kod_k := dubl1_kart
    (cAlias)->(dbUnlock())
  enddo
  (cAlias)->(dbCloseArea())
  return nil

// 20.07.23
function delete_dubl_rec(cAlias, dubl2_kart, lIndex)
  local name_index := cur_dir + 'tmp_' + cAlias

  default lIndex to .f.
  if lIndex
    (cAlias)->(dbCreateIndex(name_index, 'str(kod_k, 7)', , nil))
  endif

  do while .t.
    (cAlias)->(dbSeek(str(dubl2_kart, 7)))
    if ! (cAlias)->(found())
      exit
    endif
    DeleteRec(.t.)
  enddo
  return nil
