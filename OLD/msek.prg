*

*****
Function func_msek(k)
  Static si1 := 1, si2 := 1, si3 := 1
  Local mas_pmt, mas_msg, mas_fun, j
  DEFAULT k TO 0
  do case
    case k == 0
      mas_pmt := {"Ввод ~данных",;
                  "Получение ~информации"}
      mas_msg := {"Ввод данных по МСЭК",;
                  "Получение информации по МСЭК"}
      mas_fun := {"func_msek(1)",;
                  "func_msek(2)"}
      popup_prompt(T_ROW,T_COL+5,si1,mas_pmt,mas_msg,mas_fun)
    case k == 1
      msek_kart()
    case k == 2
      msek_print()
  endcase
  if k > 0
    si1 := k
  endif
  return NIL
  
*
*****
Function msek_kart()
  Local buf, str_sem
  if polikl1_kart() > 0
    str_sem := "МСЭК Редактирование человека "+lstr(glob_kartotek)
    if !G_SLock(str_sem)
      return func_error(4,err_slock)
    endif
    buf := savescreen()
    Private smenu_cel := {{"уст-ие группы инвалидности",1},;
                          {"уст-ие % утраты трудоспособности",2},;
                          {"для консультации",3},;
                          {"для продления б/листа",4},;
                          {"для предоставления автотранспорта",5},;
                          {"для ИПР",6},;
                          {"прочие",7}}
    Private fl_found, str_find, muslovie
    str_find := str(glob_kartotek,7)
    muslovie := "human->kod_k == glob_kartotek"
    G_Use(dir_server+"msek",dir_server+"msek","HUMAN")
    find (str_find)
    fl_found := found()
    arr_blk := {{| | FindFirst(str_find)},;
                {| | FindLast(str_find)},;
                {|n| SkipPointer(n, muslovie)},;
                str_find,muslovie;
               }
    if !fl_found ; keyboard chr(K_INS) ; endif
    mtitle := "М С Э К : "+glob_k_fio
    Alpha_Browse(T_ROW,2,maxrow()-2,77,"f2_k_msek",color0,mtitle,"BG+/GR",;
                 .f.,.t.,arr_blk,,"f3_k_msek",,;
                 {,,,"N/BG,W+/N,B/BG,BG+/B,R/BG",.t.,180} )
    close databases
    restscreen(buf)
    G_SUnLock(str_sem)
  endif
  close databases
  return NIL
  
*****
Function f2_k_msek(oBrow)
  Local oColumn, blk
  //
  oColumn := TBColumnNew(" Цель", ;
          {|| padr(inieditspr(A__MENUVERT, smenu_cel, human->cel), 23) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  //
  oColumn := TBColumnNew("Труд-ть", {|| padc(if(human->trud==1,"нет",""),7) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  //
  oColumn := TBColumnNew("Дата МСЭК",{|| full_date(human->date_kom) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  //
  oColumn := TBColumnNew("Диагноз", {|| human->kod_diag })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  //
  oColumn := TBColumnNew(" До  ", {|| f_msek_do_posle(human->cel,human->grup_do) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  //
  oColumn := TBColumnNew("После", {|| f_msek_do_posle(human->cel,human->grup_posle) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование;  ^<Ins>^ - добавление;  ^<Del>^ - удаление")
  return NIL
  
*****
Function f3_k_msek(nKey,oBrow)
  LOCAL j := 0, flag := -1, buf := save_maxrow(), buf1, fl := .f., rec, mkod,;
        tmp_color := setcolor(), r1 := 15, c1 := 2
  do case
    case nKey == K_INS .or. (nKey == K_ENTER .and. human->kod_k > 0)
      if nKey == K_INS .and. !fl_found
        colorwin(7,0,7,79,"N/N","W+/N")
        colorwin(7,0,7,79,"N/N","BG+/B")
      endif
      rec := recno()
      f4_k_msek(nKey)
      flag := 0
      if !fl_found
        flag := 1
      endif
    case nKey == K_DEL .and. human->kod_k > 0
      if f_Esc_Enter(2,.t.)
        mywait()
        DeleteRec(.t.)
        Commit
        flag := 0
        oBrow:goTop()
        find (str_find)
        if !found()
          fl_found := .f.
          flag := 1
        endif
        stat_msg("Строка по МСЭК удалена!") ; mybell(1,OK)
        rest_box(buf)
      endif
    otherwise
      keyboard ""
  endcase
  return flag
  
*****
Function f4_k_msek(nKey)
  Local buf := savescreen(buf), r1 := 12, mm_danet := {{"да ",0},{"НЕТ",1}}
  Local bg := {|o,k| get_MKB10(o,k) }, tmp_color := setcolor(cDataCGet)
  box_shadow(r1,2,22,77,color1,;
         iif(nKey==K_INS,"Добавление","Редактирование")+" строки МСЭК",color8)
  Private MDATE_KOM   := if(nkey==K_INS, sys_date, human->DATE_KOM  ),;
          MKOD_DIAG   := if(nkey==K_INS, space(5), human->KOD_DIAG  ),;
          MTRUD,M1TRUD:= if(nkey==K_INS, 0,        human->TRUD      ),;
          MCEL, M1CEL := if(nkey==K_INS, 0,        human->CEL       ),;
          MGRUP_DO    := if(nkey==K_INS, 0,        human->GRUP_DO   ),;
          MGRUP_POSLE := if(nkey==K_INS, 0,        human->GRUP_POSLE),;
          gl_area := {1,0,23,79,0}
  mtrud := inieditspr(A__MENUVERT, mm_danet, m1trud)
  mcel := inieditspr(A__MENUVERT, smenu_cel, m1cel)
  status_key("^<Esc>^ - выход;  ^<PgDn>^ - запись")
  do while .t.
    @ r1+2,4 say "Дата МСЭК" get mdate_kom
    @ r1+3,4 say "Диагноз" get mkod_diag  picture "@!" reader {|o|MyGetReader(o,bg)} valid val1_10diag()
    @ r1+4,4 say "Цель МСЭК" get mcel reader {|x|menu_reader(x,smenu_cel,A__MENUVERT,,,.f.)}
    @ r1+5,4 say "Трудоспособность" get mtrud reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    @ r1+6,4 say "Группа (процент) до комиссии" get mgrup_do pict "99"
    @ r1+7,4 say "Группа (процент) после комиссии" get mgrup_posle pict "99"
    myread()
    if f_Esc_Enter(1)
      if emptyany(mdate_kom,mkod_diag,mcel)
        func_error(4,"Введены не все данные!")
        loop
      endif
      if m1cel == 1
        if emptyall(mgrup_do,mgrup_posle)
          func_error(4,"Не введена группа инвалидности!")
          loop
        endif
        if !between(mgrup_do,0,3) .or. !between(mgrup_posle,0,3)
          func_error(4,"Не верно введена группа инвалидности!")
          loop
        endif
      endif
      if m1cel == 2
        if emptyall(mgrup_do,mgrup_posle)
          func_error(4,"Не введен процент нетрудоспособности!")
          loop
        endif
      endif
      if m1cel > 2
        mgrup_do := mgrup_posle := 0
      endif
      mywait()
      if nKey == K_INS
        AddRec(7)
        human->kod_k := glob_kartotek
        fl_found := .t.
      else
        G_RLock(forever)
      endif
      replace ;
         human->DATE_KOM   with MDATE_KOM  ,;
         human->KOD_DIAG   with MKOD_DIAG  ,;
         human->TRUD       with M1TRUD     ,;
         human->CEL        with M1CEL      ,;
         human->GRUP_DO    with MGRUP_DO   ,;
         human->GRUP_POSLE with MGRUP_POSLE
      Unlock
      Commit
    endif
    exit
  enddo
  restscreen(buf)
  setcolor(tmp_color)
  return NIL
  
  *
  
*****
Function msek_print()
  Local i, j, arr, begin_date, end_date, s, buf := save_maxrow(),;
        fl_exit := .f., sh := 64, HH := 58, reg_print := 1, speriod,;
        arr_title, name_file := "msek"+stxt, arr_m
  if (arr_m := year_month(T_ROW,T_COL+5)) == NIL
    return NIL
  endif
  speriod := arr_m[4]
  begin_date := arr_m[7]
  end_date := arr_m[8]
  WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
  Store 0 to ss,sinv,sinv1,sinv1r,sinv2,sinv2r,sinv3,sinv3r,;
             s4,s2,s5,s5iov,s3,s6,spereos,spereos1,spereos2,spereos3,s7
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"msek",,"HUMAN")
  set relation to kod_k into KART_
  index on dtos(date_kom) to (cur_dir+"tmp_msek")
  dbseek(dtos(arr_m[5]),.t.)
  do while human->date_kom <= arr_m[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    ++ss
    do case
      case human->cel == 1
        if human->grup_do == 0
          ++sinv
          if human->grup_posle == 1
            ++sinv1
            if human->trud == 0
              ++sinv1r
            endif
          elseif human->grup_posle == 2
            ++sinv2
            if human->trud == 0
              ++sinv2r
            endif
          elseif human->grup_posle == 3
            ++sinv3
            if human->trud == 0
              ++sinv3r
            endif
          endif
        else
          ++spereos  // Для переосвидетельствования всего
          if human->grup_posle > human->grup_do
            ++spereos1                      // усилена группа
          elseif human->grup_posle < human->grup_do
            if human->grup_posle == 0
              ++spereos3  // реабилитация полная
            else
              ++spereos2  // реабилитация частичная
            endif
          endif
        endif
      case human->cel == 2
        ++s2
      case human->cel == 3
        ++s3
      case human->cel == 4
        ++s4
      case human->cel == 5
        ++s5
        if kart_->kategor == 1  // инвалиды войны
          ++s5iov
        endif
      case human->cel == 6
        ++s6
      case human->cel == 7
        ++s7
    endcase
    select HUMAN
    skip
  enddo
  close databases
  rest_box(buf)
  if fl_exit ; return NIL ; endif
  //
  mywait()
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  R_Use(dir_server+"organiz",,"ORG")
  add_string(center(alltrim(org->name),sh))
  add_string(center("Анализ работы по МСЭК",sh))
  add_string(center(speriod,sh))
  add_string("")
  add_string("")
  add_string("Направлено на МСЭК всего                  "+put_val(ss,15))
  add_string("Установлена инвалидность всего            "+put_val(sinv,15))
  add_string("в т.ч. 1 группа/в т.ч. работающих         "+put_val(sinv1,13)+"/"+lstr(sinv1r))
  add_string("       2 группа/в т.ч. работающих         "+put_val(sinv2,13)+"/"+lstr(sinv2r))
  add_string("       3 группа/в т.ч. работающих         "+put_val(sinv3,13)+"/"+lstr(sinv3r))
  add_string("Для продления лечения по б/листу          "+put_val(s4,15))
  add_string("Для установления % утраты трудоспособности"+put_val(s2,15))
  add_string("Для предоставления автотранспорта         "+put_val(s5,15))
  add_string("                  в том числе ИОВ         "+put_val(s5iov,15))
  add_string("Для консультации                          "+put_val(s3,15))
  add_string("Для ИПР                                   "+put_val(s6,15))
  add_string("Для переосвидетельствования всего         "+put_val(spereos,15))
  add_string(" из них: усилена группа                   "+put_val(spereos1,15))
  add_string("         реабилитация частичная           "+put_val(spereos2,15))
  add_string("         реабилитация полная              "+put_val(spereos3,15))
  add_string("Прочие                                    "+put_val(s7,15))
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
  return NIL
  
*
  
  