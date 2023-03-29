#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 28.12.21
Function pripisnoe_naselenie(k)
  Static si1 := 1, si2 := 1, si3 := 1
  Local mas_pmt, mas_msg, mas_fun, j, r, nuch, nsmo

  DEFAULT k TO 1
  do case
    case k == 1
      mas_pmt := {"Просмотр ~файлов прикрепления",;
                  "~Подготовка и создание файлов прикрепления",;
                  "Печать ~заявления на прикрепление",;
                  "Создание файла ~сверки с ТФОМС",;
                  "~Редактирование участков списком",;
                  "~Импорт WQ2...DBF, простановка участков, отправка"}
      mas_msg := {"Просмотр файлов прикрепления (и ответов на них), запись файлов для ТФОМС",;
                  "Подготовка файлов прикрепления и создание их для отправки в ТФОМС",;
                  "Печать заявления на прикрепление по пациенту, ещё не прикреплённому к Вашей МО",;
                  "Создание файла сверки с ТФОМС по прикреплённому населению (письмо № 04-18-20)",;
                  "Редактирование номера участка для выбранного списка пациентов",;
                  "Импорт DBF-файла из ТФОМС, простановка участков, создание файла прикрепления"}
      mas_fun := {"pripisnoe_naselenie(11)",;
                  "pripisnoe_naselenie(12)",;
                  "pripisnoe_naselenie(13)",;
                  "pripisnoe_naselenie(14)",;
                  "pripisnoe_naselenie(15)",;
                  "pripisnoe_naselenie(16)"}
      if T_ROW > 8
        r := T_ROW-len(mas_pmt)-3
      else
        r := T_ROW
      endif
      popup_prompt(r,T_COL+5,si1,mas_pmt,mas_msg,mas_fun)
    case k == 11
      view_reestr_pripisnoe_naselenie()
    case k == 12
      preparation_for_pripisnoe_naselenie()
    case k == 13
      kartoteka_z_prikreplenie()
    case k == 14
      if hb_user_curUser:IsAdmin()
        str_sem := "Создание файла сверки с ТФОМС"
        if G_SLock(str_sem)
          pripisnoe_naselenie_create_SVERKA()
          G_SUnLock(str_sem)
        else
          func_error(4,err_slock)
        endif
      else
        func_error(4,err_admin)
      endif
    case k == 15
      edit_uchast_spisok()
    case k == 16 // Импорт WQ2...DBF
      mas_pmt := {"~Импорт WQ2...ZIP",;
                  "~Просмотр последнего импортированного файла",;
                  "Редактирование ~участков",;
                  "~Создание файлов прикрепления"}
      mas_msg := {"Импорт нового файла WQ2...ZIP (после всех операций с предыдущим прочитанным)",;
                  "Просмотр прикреплённым к нашему МО пациентов, присланных в последнем файле",;
                  "Редактирование участков пациентам, присланным в последнем файле",;
                  "Создание файла прикрепления из пациентов последнего файла WQ... для отправки"}
      mas_fun := {"pripisnoe_naselenie(31)",;
                  "pripisnoe_naselenie(32)",;
                  "pripisnoe_naselenie(33)",;
                  "pripisnoe_naselenie(34)"}
      popup_prompt(T_ROW-3-len(mas_pmt),T_COL+5,si3,mas_pmt,mas_msg,mas_fun)
    case k == 21
      spisok_pripisnoe_naselenie(1)
    case k == 22
      spisok_pripisnoe_naselenie(2)
    case k == 23
      spisok_pripisnoe_naselenie(3)
    case k == 31
      wq_import()
    case k == 32
      wq_view()
    case k == 33
      wq_edit_uchast()
    case k == 34
      wq_prikreplenie()
  endcase
  if k > 10
    j := int(val(right(lstr(k),1)))
    if between(k,11,19)
      si1 := j
    elseif between(k,21,29)
      si2 := j
    elseif between(k,31,39)
      si2 := j
    endif
  endif
  return NIL
  
***** 11.03.13
Function view_reestr_pripisnoe_naselenie()
  Local buf := savescreen()
  Private goal_dir := dir_server+dir_XML_MO+cslash
  G_Use(dir_server+"mo_krtf",,"KRTF")
  G_Use(dir_server+"mo_krtr",,"KRTR")
  index on dtos(dfile) to (cur_dir+"tmp_krtr") DESCENDING
  go top
  if eof()
    func_error(4,"Нет составленных файлов прикрепления")
  else
    Alpha_Browse(T_ROW,0,23,79,"f1_view_r_pr_nas",color0,,,,,,,;
                 "f2_view_r_pr_nas",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
  endif
  close databases
  restscreen(buf)
  return NIL
  
***** 14.07.15
Function f1_view_r_pr_nas(oBrow)
  Local oColumn, ;
        blk := {|_s| _s := goal_dir+alltrim(krtr->FNAME), ;
                     iif(hb_fileExists(_s+scsv) .or. hb_fileExists(_s+szip), ;
                       iif(empty(krtr->date_out), {3,4}, {1,2}),;
                       {5,6}) }
  oColumn := TBColumnNew("Дата файла",{|| full_date(krtr->dfile) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Кол-во;пац-ов", {|| str(krtr->kol,6) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" Наименование файла",{|| padr(krtr->FNAME,20) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Примечание",{|| f11_view_r_pr_nas() })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" Ответ;получен", {|| padc(iif(krtr->ANSWER==1,"да",""),7) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Прикре;плено", {|| put_val(krtr->kol_p,6) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" WQ", {|| krtr->wq })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  status_key("^<Esc>^ - выход;  ^<F5>^ - запись для ТФОМС;  ^<F3>^ - информация о файле прикрепления")
  return NIL
  
***** 03.11.14
Function f11_view_r_pr_nas()
  Local s := ""
  if !(hb_fileExists(goal_dir+alltrim(krtr->FNAME)+scsv) .or. ;
           hb_fileExists(goal_dir+alltrim(krtr->FNAME)+szip))
    krtf->(dbGoto(krtr->kod_f))
    if empty(krtf->TWORK2)
      s := "не завершён"
    else
      s := "нет файла"
    endif
  elseif empty(krtr->date_out)
    s := "не записан"
  else
    s := "зап. "+lstr(krtr->NUMB_OUT)+" раз"
  endif
  return padr(s,11)
  
***** 24.03.15
Function f2_view_r_pr_nas(nKey,oBrow)
  Local pss := space(10), tmp_pss := my_parol()
  Local ret := -1, rec := krtr->(recno()), tmp_color := setcolor(), r, r1, r2,;
        s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
  krtf->(dbGoto(krtr->kod_f))
  do case
    case nKey==K_CTRL_F10 .and. eq_any(krtf->TIP_OUT,_CSV_FILE_REESTR,_CSV_FILE_SVERKAZ) .and. krtr->ANSWER==0
      pss := get_parol(,,,,,"N/W","W/N*")
      if lastkey() == K_ENTER .and. ascan(tmp_pss, crypt(pss,gpasskod)) > 0 ;
                                    .and. f_Esc_Enter("аннулирования файла",.t.)
        krtf->(dbGoto(krtr->kod_f))
        zip_file := alltrim(krtr->FNAME)+iif(krtf->TIP_OUT==_CSV_FILE_REESTR,scsv,szip)
        str_sem := "f2_view_r_pr_nas_K_CTRL_F12"
        if G_SLock(str_sem)
          mywait()
          i := 0
          Use (dir_server+"mo_krtp") new alias KRTP
          index on str(reestr,6) to (cur_dir+"tmp_k")
          do while .t.
            @ maxrow(),0 say str(i/krtr->KOL*100,6,2)+"%" color cColorWait
            find (str(krtr->KOD,6))
            if !found() ; exit ; endif
            DeleteRec(.t.)
            if ++i % 5000 == 0
              Commit
            endif
          enddo
          Commit
          pack
          krtp->(dbCloseArea())
          select KRTF
          DeleteRec()
          select KRTR
          DeleteRec()
          delete file (goal_dir+zip_file)
          G_SUnLock(str_sem)
          stat_msg("Файл успешно аннулирован!") ; mybell(2,OK)
          return 1
        endif
      endif
    case nKey == K_CTRL_F12
      if empty(krtf->TWORK2) // не дописан
        zip_file := alltrim(krtr->FNAME)+iif(krtf->TIP_OUT==_CSV_FILE_REESTR,scsv,szip)
        if krtr->ANSWER > 0
          func_error(4,"Ответ для данного файла уже был прочитан - аннулирование запрещено!")
        elseif hb_fileExists(goal_dir+zip_file)
          func_error(4,"Данный файл уже создан в целевом каталоге - аннулирование запрещено!")
        elseif f_Esc_Enter("аннулирования файла",.t.)
          str_sem := "f2_view_r_pr_nas_K_CTRL_F12"
          if G_SLock(str_sem)
            mywait()
            i := 0
            Use (dir_server+"mo_krtp") new alias KRTP
            index on str(reestr,6) to (cur_dir+"tmp_k")
            do while .t.
              @ maxrow(),0 say str(i/krtr->KOL*100,6,2)+"%" color cColorWait
              find (str(krtr->KOD,6))
              if !found() ; exit ; endif
              DeleteRec(.t.)
              if ++i % 5000 == 0
                Commit
              endif
            enddo
            Commit
            pack
            krtp->(dbCloseArea())
            select KRTF
            DeleteRec()
            select KRTR
            DeleteRec()
            delete file (goal_dir+zip_file)
            G_SUnLock(str_sem)
            stat_msg("Файл успешно аннулирован!") ; mybell(2,OK)
            return 1
          endif
        endif
      else
        func_error(4,"Данный файл аннулировать запрещено!")
      endif
    case nKey == K_F5
      if f_Esc_Enter("записи файла за "+date_8(krtr->dfile))
        Private p_var_manager := "copy_schet"
        s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" для выбора каталога
        if !empty(s)
          if upper(s) == upper(goal_dir)
            func_error(4,"Вы выбрали каталог, в котором уже записан данный файл! Это недопустимо.")
          else
            zip_file := alltrim(krtr->FNAME)+iif(left(krtr->FNAME,2)=="MO",scsv,szip)
            if hb_fileExists(goal_dir+zip_file)
              mywait('Копирование "'+zip_file+'" в каталог "'+s+'"')
              //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
              copy file (goal_dir+zip_file) to (s+zip_file)
              //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
              if hb_fileExists(s+zip_file)
                krtr->(G_RLock(forever))
                krtr->DATE_OUT := sys_date
                if krtr->NUMB_OUT < 99
                  krtr->NUMB_OUT ++
                endif
                //
                krtf->(dbGoto(krtr->kod_f))
                krtf->(G_RLock(forever))
                krtf->DREAD := sys_date
                krtf->TREAD := hour_min(seconds())
              else
                func_error(4,"Ошибка записи файла "+s+zip_file)
              endif
            else
              func_error(4,"Не обнаружен файл "+goal_dir+zip_file )
            endif
            UnLock
            Commit
            stat_msg("Запись завершена!") ; mybell(2,OK)
          endif
        endif
      endif
      select KRTR
      ret := 0
    case nKey == K_F3
      f3_view_r_pr_nas(oBrow)
      ret := 0
  endcase
  setcolor(tmp_color)
  restscreen(buf)
  return ret
  
***** 24.10.18
Function f3_view_r_pr_nas(oBrow)
  Static si := 1, snfile := "", sarr_mo, sarr_err, sjmo, sjerr
  Local i, j, r := row(), r1, r2, buf := save_maxrow(), fl := .f., ii,;
        mm_func := {-1}, mm_menu

  Private fl_csv := .f., mm_err := {}
  if krtf->TIP_OUT == _CSV_FILE_SVERKAZ
    mm_err := {{'Не имеет текущего страхования',708},; // !!!
               {'Прикрепление к МО отсутствует',709},; //
               {'ТФОМС не вернул никакой информации',-99}} // !!!
  endif
  if left(krtr->FNAME,2) == "MO"
    fl_csv := .t.
    mm_menu := {"~Список пациентов в файле прикрепления"}
    if krtr->ANSWER == 1
      aadd(mm_func, -2) ; aadd(mm_menu, "Список ~прикреплённых пациентов")
      aadd(mm_func, -3) ; aadd(mm_menu, "Список ~не прикреплённых пациентов")
    endif
  else
    mm_menu := {"~Список пациентов в файле сверки"}
    if !(snfile == alltrim(krtr->FNAME))
      fl := .t.
      snfile := alltrim(krtr->FNAME)
      sarr_mo := {} ; sjmo := 1
      sarr_err := {} ; sjerr := 1
    endif
  endif
  mywait()
  select KRTF
  index on FNAME to (cur_dir+"tmp_krtf") for reestr==krtr->kod .and. empty(TIP_OUT)
  go top
  do while !eof()
    aadd(mm_func, krtf->kod)
    aadd(mm_menu, "Протокол ~чтения "+rtrim(krtf->FNAME)+iif(empty(krtf->TWORK2),"-ЧТЕНИЕ НЕ ЗАВЕРШЕНО",""))
    skip
  enddo
  select KRTF
  set index to
  if !fl_csv .and. krtr->ANSWER == 1
    aadd(mm_func, -2) ; aadd(mm_menu, "Список пациентов, прикреплённых к ~нашей МО")
    aadd(mm_func, -4) ; aadd(mm_menu, "Список пациентов, прикреплённых к ~другим МО")
    aadd(mm_func, -3) ; aadd(mm_menu, "Список вернувшихся из ТФОМС с кодом ~ошибки")
    if fl
      ii := 0
      R_Use(dir_server+"mo_krte",,"KRTE")
      index on str(rees_zap,6) to (cur_dir+"tmp_krte") for reestr == krtr->kod
      R_Use(dir_server+"mo_kartp",dir_server+"mo_kartp","KARTP")
      R_Use(dir_server+"mo_krtp",,"KRTP")
      index on str(rees_zap,6) to (cur_dir+"tmp_krtp") for reestr == krtr->kod
      go top
      do while !eof()
        @ maxrow(),0 say str(++ii/krtr->kol*100,6,2)+"%" color cColorWait
        if empty(md_prik := krtp->D_PRIK1)
          if empty(md_prik := krtp->D_PRIK)
            md_prik := krtr->DFILE // для совместимости со старой версией
          endif
        endif
        select KRTE
        find (str(krtp->REES_ZAP,6))
        do while krtp->REES_ZAP == krte->REES_ZAP .and. !eof()
          if ascan(sarr_err,krte->REFREASON) == 0
            aadd(sarr_err,krte->REFREASON)
          endif
          skip
        enddo
        if krtp->OPLATA == 3
          select KARTP
          find (str(krtp->KOD_K,7)+dtos(md_prik))
          if found() .and. ascan(sarr_mo,kartp->MO_PR) == 0
            aadd(sarr_mo,kartp->MO_PR)
          endif
        endif
        select KRTP
        skip
      enddo
      krte->(dbCloseArea())
      kartp->(dbCloseArea())
      krtp->(dbCloseArea())
      asort(sarr_err)
      for j := 1 to len(sarr_err)
        if ascan(mm_err,{|x| x[2] == sarr_err[j]}) > 0
          sarr_err[j] := str(sarr_err[j],3)+" "+inieditspr(A__MENUVERT,mm_err,sarr_err[j])
        else
          sarr_err[j] := str(sarr_err[j],3)+" "+inieditspr(A__MENUVERT,mm_err_csv_prik,sarr_err[j])
        endif
      next
      asort(sarr_mo)
      for j := 1 to len(sarr_mo)
        sarr_mo[j] += " "+ret_mo(sarr_mo[j])[_MO_SHORT_NAME]
      next
    endif
  endif
  if r <= 12
    r1 := r+1 ; r2 := r1+len(mm_menu)+1
  else
    r2 := r-1 ; r1 := r2-len(mm_menu)-1
  endif
  rest_box(buf)
  if len(mm_menu) == 1
    i := 1
  else
    i := popup_prompt(r1,10,si,mm_menu,,,color5)
  endif
  if i > 0
    si := i
    if mm_func[i] < 0
      if !fl_csv .and. mm_func[i] == -4
        if !empty(sarr_mo)
          if r <= 12
            r1 := r+1 ; r2 := r1+len(sarr_mo)+1
            if r2 > maxrow()-2
              r2 := maxrow()-2
            endif
          else
            r2 := r-1 ; r1 := r2-len(sarr_mo)-1
            if r1 < 2
              r1 := 2
            endif
          endif
          do while (j := popup_SCR(r1,10,r2,77,sarr_mo,sjmo,color5,.t.,,,;
                           'Выберите, к какому МО прикреплён пациент',"B/W")) > 0
            sjmo := j
            f31_view_r_pr_nas(abs(mm_func[i]),mm_menu[i],sarr_mo[j])
          enddo
        endif
      elseif !fl_csv .and. mm_func[i] == -3
        if !empty(sarr_err)
          if r <= 12
            r1 := r+1 ; r2 := r1+len(sarr_err)+1
            if r2 > maxrow()-2
              r2 := maxrow()-2
            endif
          else
            r2 := r-1 ; r1 := r2-len(sarr_err)-1
            if r1 < 2
              r1 := 2
            endif
          endif
          do while (j := popup_SCR(r1,10,r2,77,sarr_err,sjerr,color5,.t.,,,;
                           'Выберите код ошибки возврата из ТФОМС',"B/W")) > 0
            sjerr := j
            f31_view_r_pr_nas(abs(mm_func[i]),mm_menu[i],sarr_err[j])
          enddo
        endif
      else
        f31_view_r_pr_nas(abs(mm_func[i]),mm_menu[i])
      endif
    else
      krtf->(dbGoto(mm_func[i]))
      viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+alltrim(krtf->FNAME)+stxt,60,80),,,,.t.,,,2)
    endif
  endif
  select KRTR
  return NIL
  
***** 04.11.14
Function f31_view_r_pr_nas(reg,s,s1)
  Local fl := .t., buf := save_maxrow(), n_file := "prikspis"+stxt, lmo, lerr, ;
        i, j, k, ii, ar[2]
  mywait()
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center(charrem("~",s),80))
  if fl_csv
    add_string(center("( файл прикрепления от "+full_date(krtr->dfile)+" )",80))
  else
    DEFAULT s1 TO ""
    s1 := alltrim(s1)
    add_string(center("( файл сверки от "+full_date(krtr->dfile)+" )",80))
    if reg == 4
      lmo := left(s1,6)
      add_string(center(charone('"','Список прикреплённых к "'+s1+'"'),80))
    elseif reg == 3
      lerr := int(val(s1))
      for i := 1 to perenos(ar,'Список вернувшихся из ТФОМС с ошибкой "'+s1+'"',80)
        add_string(center(alltrim(ar[i]),80))
      next
    endif
  endif
  add_string("")
  R_Use(dir_server+"mo_krte",,"KRTE")
  if reg == 3 .or. !fl_csv
    index on str(rees_zap,6) to (cur_dir+"tmp_krte") for reestr == krtr->kod
  endif
  // список прикреплений по пациенту во времени
  R_Use(dir_server+"mo_kartp",dir_server+"mo_kartp","KARTP")
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART2
  R_Use(dir_server+"mo_krtp",,"KRTP")
  set relation to kod_k into KART
  index on str(rees_zap,6) to (cur_dir+"tmp_krtp") for reestr == krtr->kod
  ii := k := 0
  go top
  do while !eof()
    @ maxrow(),0 say str(++ii/krtr->kol*100,6,2)+"%" color cColorWait
    if empty(md_prik := krtp->D_PRIK1)
      if empty(md_prik := krtp->D_PRIK)
        md_prik := krtr->DFILE // для совместимости со старой версией
      endif
    endif
    fl := .f.
    do case
      case reg == 1
        fl := .t.
      case reg == 2
        fl := (krtp->OPLATA == 1)
      case reg == 3 .and. fl_csv
        fl := (krtp->OPLATA == 2)
      case reg == 3 .and. !fl_csv
        select KRTE
        find (str(krtp->REES_ZAP,6))
        do while krtp->REES_ZAP == krte->REES_ZAP .and. !eof()
          if lerr == krte->REFREASON
            fl := .t. ; exit
          endif
          skip
        enddo
      case reg == 4
        if krtp->OPLATA == 3
          select KARTP
          find (str(krtp->KOD_K,7)+dtos(md_prik))
          fl := found() .and. lmo == kartp->MO_PR
        endif
    endcase
    if fl
      ++k
      s := lstr(krtp->REES_ZAP)+". "+alltrim(kart->fio)+;
           " (д.р."+full_date(kart->date_r)+") "
      if reg == 1
        if fl_csv
          s += "заказ на прикрепление с "+date_8(md_prik)
        endif
      elseif krtp->OPLATA == 2 .and. !empty(kart2->MO_PR)
        if kart2->MO_PR == glob_mo[_MO_KOD_TFOMS]
          s += 'ранее прикреплён к Вашей МО'
        else
          s += 'ранее прикреплён к '+ret_mo(kart2->MO_PR)[_MO_SHORT_NAME]
        endif
      elseif eq_any(krtp->OPLATA,1,3) //    reg == 2
        s += "ПРИКРЕПЛ"+iif(kart->pol=="М","ЁН","ЕНА")+" с "+date_8(md_prik)
      endif
      verify_FF(60,.t.,80)
      add_string(s)
      if reg == 3 .and. fl_csv
        select KRTE
        find (str(krtp->REES_ZAP,6))
        do while krtp->REES_ZAP == krte->REES_ZAP .and. !eof()
          s := space(len(lstr(krtp->REES_ZAP))+2)+lstr(krte->REFREASON)+" "+;
               inieditspr(A__MENUVERT,mm_err_csv_prik,krte->REFREASON)
          verify_FF(60,.t.,80)
          add_string(s)
          skip
        enddo
      endif
    endif
    select KRTP
    skip
  enddo
  if reg == 3 .and. !fl_csv
    add_string("=== Итого пациентов - "+lstr(k)+" чел.")
  endif
  krte->(dbCloseArea())
  kartp->(dbCloseArea())
  kart2->(dbCloseArea())
  kart->(dbCloseArea())
  krtp->(dbCloseArea())
  fclose(fp)
  rest_box(buf)
  viewtext(n_file,,,,.t.,,,2)
  return NIL
  
// 29.03.23
Function preparation_for_pripisnoe_naselenie()
  Local i, j, k, aerr, buf := savescreen(), blk, t_arr[BR_LEN], cur_year,;
        str_sem := "preparation_for_pripisnoe_naselenie"
  mywait()
  G_Use(dir_server+"mo_krtp",,"KRTP")
  index on kod_k to (cur_dir+"tmp_k") for reestr == 0
  dbcreate(cur_dir+"tmp_krtp",{;
    {"rec",   "N",8,0},; // номер записи в файле "mo_krtp"
    {"uchast","N",2,0},; // участок
    {"D_PRIK","D",8,0},; // дата прикрепления
    {"S_PRIK","N",1,0},; // способ прикрепления: 1-по месту регистрации, 2-по личному заявлению, 3-
    {"KOD_K", "N",7,0};  // код пациента по файлу "kartotek"
   })
  use (cur_dir+"tmp_krtp") new
  use_base("kartotek")
  set order to 0
  select KRTP
  go top
  do while !eof()
    if empty(krtp->d_prik)
      G_RLock(forever)
      krtp->d_prik := sys_date
      UnLock
    endif
    kart->(dbGoto(krtp->kod_k))
    select TMP_KRTP
    append blank
    tmp_krtp->rec := krtp->(recno())
    tmp_krtp->kod_k := krtp->kod_k
    tmp_krtp->uchast := kart->uchast
    tmp_krtp->s_prik := krtp->s_prik
    tmp_krtp->d_prik := krtp->d_prik
    select KRTP
    skip
  enddo
  commit
  select KRTP
  index on str(reestr,6) to (cur_dir+"tmp_k")
  select TMP_KRTP
  set relation to kod_k into KART
  index on str(kod_k,7) to (cur_dir+"tmp_krtp")
  index on upper(kart->fio)+dtos(kart->date_r)+str(kod_k,7) to (cur_dir+"tmp2krtp")
  set index to (cur_dir+"tmp2krtp"),(cur_dir+"tmp_krtp")
  go top
  restscreen(buf)
  if lastrec() == 0 .and. ;
     f_alert({"В данный момент не отмечено ни одного пациента",;
              "для прикрепления",""},;
             {" Отказ "," Начать подготовку файла прикрепления "},;
             1,"N+/G*","N/G*",maxrow()-8,,"N/G*") != 2
    close databases
    return NIL
  endif
  if !G_SLock(str_sem)
    close databases
    return func_error(4,"В данный момент с этим режимом работает другой пользователь.")
  endif
  Private tr := T_ROW
  box_shadow(tr-4,47,tr-2,77,"B/W*")
  t_arr[BR_TOP] := tr
  t_arr[BR_BOTTOM] := maxrow()-1
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_COLOR] := color5
  t_arr[BR_TITUL] := "Подготовка файла прикрепления"
  t_arr[BR_TITUL_COLOR] := "B/W"
  t_arr[BR_ARR_BROWSE] := {"═","░","═","N/W,W+/N,B/W,W+/B,RB/W,W+/RB",.t.,72}
  blk := {|| iif(kart->uchast > 0, iif(tmp_krtp->s_prik==2,{1,2},{3,4}), {5,6}) }
  Private arr_prik := {{"по месту регистрации",1},;
                       {"лич/з-е без изм. м/ж",2},;
                       {"лич/з-е с измен. м/ж",3}}
  Private arr_prik1 := {{"по личному заявлению (без изменения места жительства)",2},;
                        {"по личному заявлению (в связи с изменением места жительства)",3}}
  t_arr[BR_COLUMN] := {{ center("Ф.И.О.",32),{|| left(kart->fio,32) }, blk },;
                       {"   Дата; рождения", {|| full_date(kart->date_r) }, blk },;
                       {"Уч", {|| str(kart->uchast) }, blk },;
                       {"   Дата; заявления", {|| full_date(tmp_krtp->d_prik) }, blk },;
                       {"Способ прикрепления", {|| padr(inieditspr(A__MENUVERT,arr_prik,tmp_krtp->s_prik),20) }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход ^<Enter>^ ред-ние даты и способа/просмотр ^<Ins>^ добавить ^<Del>^ удалить") }
  t_arr[BR_STEP_FUNC] := {|| f3_p_f_prikreplenie() }
  t_arr[BR_EDIT] := {|nk,ob| f1_p_f_prikreplenie(nk,ob,"edit") }
  if lastrec() == 0
    keyboard chr(K_INS)
  endif
  edit_browse(t_arr)
  restscreen(buf)
  if tmp_krtp->(lastrec()) > 0
    mywait()
    cur_year := year(sys_date)
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    go bottom
    if !empty(human->k_data)
      cur_year := year(human->k_data)
    endif
    Use
    cFileProtokol := "prot"+stxt
    strfile(space(10)+"Список ошибок"+hb_eol()+hb_eol(),cFileProtokol)
    ii := i := 0
    R_Use(dir_server+"mo_otd",,"OTD")
    R_Use(dir_server+"mo_pers",,"P2")
    R_Use(dir_server+"mo_uchvr",,"UV")
    index on str(uch,2) to (cur_dir+"tmp_uv")
    select TMP_KRTP
    go top
    do while !eof()
      ++ii
      aerr := {}
      if empty(kart->date_r)
        aadd(aerr,'не заполнено поле "Дата рождения"')
      elseif kart->date_r >= sys_date
        aadd(aerr,'дата рождения больше сегодняшней даты')
      elseif year(kart->date_r) < 1900
        aadd(aerr, "дата рождения: "+full_date(kart->date_r)+" ( < 1900г.)")
      endif
      if kart2->MO_PR == glob_mo[_MO_KOD_TFOMS]
        aadd(aerr,'данный пациент уже прикреплён к Вашей МО с '+;
                  iif(empty(kart2->pc4),full_date(kart2->DATE_PR),alltrim(kart2->pc4))+"г.")
      endif
      if empty(tmp_krtp->uchast)
        aadd(aerr,'не заполнено поле "Номер участка"')
      else
        select UV
        find (str(tmp_krtp->uchast,2))
        if found() .and. !emptyall(uv->vrach,uv->vrachv,uv->vrachd)
          if count_years(kart->date_r,sys_date) < 18 // дети
            if emptyall(uv->vrach,uv->vrachd)
              aadd(aerr,"на участке "+lstr(kart->uchast)+" не привязан участковый врач к детям")
            else
              if !empty(uv->vrach)
                p2->(dbGoto(uv->vrach))
              else
                p2->(dbGoto(uv->vrachd))
              endif
              f1_p_f_pripisnoe_naselenie(aerr)
            endif
          else
            if emptyall(uv->vrach,uv->vrachv)
              aadd(aerr,"на участке "+lstr(kart->uchast)+" не привязан участковый врач к взрослым")
            else
              if !empty(uv->vrach)
                p2->(dbGoto(uv->vrach))
              else
                p2->(dbGoto(uv->vrachv))
              endif
              f1_p_f_pripisnoe_naselenie(aerr)
            endif
          endif
        else
          aadd(aerr,"к участку "+lstr(kart->uchast)+" не привязан участковый врач")
        endif
      endif
      Valid_SN_Polis(kart_->vpolis, kart_->SPOLIS, kart_->NPOLIS, aerr, between(kart_->smo, '34001', '34007'))
      // if ascan(menu_vidud,{|x| x[2] == kart_->vid_ud }) == 0
      if ascan(getVidUd(), {|x| x[2] == kart_->vid_ud }) == 0
        aadd(aerr, 'не заполнено поле "ВИД удостоверения личности"')
      else
        if empty(kart_->nom_ud)
          aadd(aerr,'должно быть заполнено поле "НОМЕР удостоверения личности"')
        elseif !ver_number(kart_->nom_ud)
          aadd(aerr,'поле "НОМЕР удостоверения личности" должно быть цифровым')
        endif
        if !empty(kart_->nom_ud)
          s := space(80)
          if !val_ud_nom(2,kart_->vid_ud,kart_->nom_ud,@s)
            aadd(aerr,s)
          endif
        endif
        if eq_any(kart_->vid_ud,1,3,14) .and. empty(kart_->ser_ud)
          aadd(aerr,'не заполнено поле "СЕРИЯ удостоверения личности"')
        endif
        if eq_any(kart_->vid_ud,3,14) .and. empty(del_spec_symbol(kart_->mesto_r))
          aadd(aerr,iif(kart_->vid_ud==3,'для свид-ва о рождении','для паспорта РФ')+;
                                         ' обязательно заполнение поля "Место рождения"')
        endif
        if !empty(kart_->ser_ud)
          s := space(80)
          if !val_ud_ser(2,kart_->vid_ud,kart_->ser_ud,@s)
            aadd(aerr,s)
          endif
        endif
      endif
      if !empty(kart_->kogdavyd) .and. kart_->kogdavyd < kart->date_r
        aadd(aerr,'дата выдачи документа, удостоверяющего личность, меньше даты рождения')
      endif
      val_fio(retFamImOt(1,.f.),aerr)
      if !empty(kart->snils)
        s := space(80)
        if !val_snils(kart->snils,2,@s)
          aadd(aerr,s)
        endif
      endif
      select KRTP
      goto (tmp_krtp->rec)
      if !eq_any(krtp->S_PRIK,1,2,3)
        aadd(aerr,'неверный способ прикрепления')
      endif
      if empty(krtp->D_PRIK)
        aadd(aerr,'не заполнено поле "Дата заявления"')
      elseif krtp->D_PRIK > sys_date
        aadd(aerr,'дата заявления больше сегодняшней даты')
      elseif year(krtp->D_PRIK) < cur_year
        aadd(aerr, "дата заявления: "+full_date(krtp->D_PRIK)+" - прошлый год")
      endif
      if !empty(aerr)
        strfile(lstr(++i)+". "+alltrim(kart->fio)+" "+full_date(kart->date_r)+hb_eol(),cFileProtokol,.t.)
        aeval(aerr,{|x| strfile(" - "+x+hb_eol(),cFileProtokol,.t.) })
      endif
      select TMP_KRTP
      skip
    enddo
    j := tmp_krtp->(lastrec())
    close databases
    restscreen(buf)
    k := 1
    if i > 0
      viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
    else
      k := f_alert({"В данный момент отмечено "+lstr(ii)+" пациентов для прикрепления",;
                    ""},;
                   {" Отказ "," Создать файл прикрепления "},;
                   1,"N+/GR*","N/GR*",maxrow()-7,,"N/GR*")
    endif
    j := 0
    if k == 2
      k := f_alert({padc("Выберите, каким образом создавать файл прикрепления",70,"."),;
                    ""},;
                   {" Только по заявлению "," Включать пациентов с изменением № участка "},;
                   1,"N+/G*","N/G*",maxrow()-7,,"N/G*")
      if k == 1
        k := 2
      elseif k == 2
        if (k := find_change_snils(@j)) == 3
          k := f_alert({padc("Выберите, каким образом создавать файл прикрепления",70,"."),;
                        ""},;
                       {" Только по заявлению "," Включить "+lstr(j)+" пациентов с изменением уч-ка "},;
                       1,"N+/G*","N/G*",maxrow()-7,,"N/G*")
          if k == 1
            k := 2 ; j := 0
          elseif k == 2
            k := 3
          endif
        endif
      endif
    endif
    if k > 1
      s := "MO2"
      G_Use(dir_server+"mo_krtr",,"KRTR")
      Locate for DFILE == sys_date .and. left(FNAME,3) == s
      if found()
        func_error(4,"Файл прикрепления с датой "+full_date(sys_date)+"г. уже был создан")
      elseif f_Esc_Enter("создания файла прикрепления",.t.)
        mywait()
        s += glob_mo[_MO_KOD_TFOMS]+dtos(sys_date)
        n_file := s+scsv
        R_Use(exe_dir+"_mo_podr",cur_dir+"_mo_podr","PODR")
        find (glob_mo[_MO_KOD_TFOMS])
        loidmo := alltrim(podr->oidmo)
        select KRTR
        index on str(kod,6) to (cur_dir+"tmp_krtr")
        AddRec(6)
        krtr->KOD := recno()
        krtr->FNAME := s
        krtr->DFILE := sys_date
        krtr->DATE_OUT := ctod("")
        krtr->NUMB_OUT := 0
        krtr->KOL := ii+j
        krtr->KOL_P := 0
        krtr->ANSWER := 0  // 0-не было ответа, 1-был прочитан ответ
        G_Use(dir_server+"mo_krtf",,"KRTF")
        index on str(kod,6) to (cur_dir+"tmp_krtf")
        AddRec(6)
        krtf->KOD   := recno()
        krtf->FNAME := krtr->FNAME
        krtf->DFILE := krtr->DFILE
        krtf->TFILE := hour_min(seconds())
        krtf->TIP_IN := 0
        krtf->TIP_OUT := _CSV_FILE_REESTR
        krtf->REESTR := krtr->KOD
        krtf->DWORK := sys_date
        krtf->TWORK1 := hour_min(seconds()) // время начала обработки
        krtf->TWORK2 := ""                  // время окончания обработки
        //
        krtr->KOD_F := krtf->KOD
        UnLock
        Commit
        //
        blk := {|_s| iif(empty(_s), '', '"'+_s+'"') }
        delete file (n_file)
        fp := fcreate(n_file)
        //
        R_Use(dir_server+"mo_otd",,"OTD")
        R_Use(dir_server+"mo_pers",,"P2")
        R_Use(dir_server+"mo_uchvr",,"UV")
        index on str(uch,2) to (cur_dir+"tmp_uv")
        G_Use(dir_server+"mo_krtp",,"KRTP")
        use_base("kartotek")
        set order to 0
        use (cur_dir+"tmp_krtp") new
        set relation to kod_k into KART
        index on upper(kart->fio)+dtos(kart->date_r)+str(kod_k,7) to (cur_dir+"tmp2krtp")
        i := 0
        go top
        do while !eof()
          ++i
          @ maxrow(),0 say str(i/(ii+j)*100,6,2)+"%" color cColorWait
          if !empty(tmp_krtp->uchast)
            select UV
            find (str(tmp_krtp->uchast,2))
            if found()
              if count_years(kart->date_r,sys_date) < 18 // дети
                if !empty(uv->vrach)
                  p2->(dbGoto(uv->vrach))
                else
                  p2->(dbGoto(uv->vrachd))
                endif
              else
                if !empty(uv->vrach)
                  p2->(dbGoto(uv->vrach))
                else
                  p2->(dbGoto(uv->vrachv))
                endif
              endif
            endif
            select OTD
            goto (p2->otd)
          endif
          select KRTP
          goto (tmp_krtp->rec)
          G_RLock(forever)
          krtp->REESTR   := krtr->KOD
          krtp->REES_ZAP := i
          krtp->OPLATA   := 0
          krtp->UCHAST   := tmp_krtp->uchast     // номер участка
          krtp->SNILS_VR := p2->snils      // СНИЛС участкового врача
          krtp->KOD_PODR := alltrim(otd->kod_podr) // код подразделения по паспорту ЛПУ
          krtp->D_PRIK1  := ctod("")       // дата прикрепления
          UnLock
          //
          s1 := iif(i==1, "", hb_eol())
          // 1 - Номер записи в файле с 10.06.19г.
          s1 += eval(blk,lstr(i))+";"
          // 1 - Действие
          s := "Р"
          s1 += eval(blk,s)+";"
          // 2 - Код типа ДПФС
          s := iif(kart_->vpolis==3, "П", iif(kart_->vpolis==2, "В", "С"))
          s1 += eval(blk,s)+";"
          // 3 - Серия и номер ДПФС
          s := iif(kart_->vpolis==3, "", ;
                   iif(kart_->vpolis==2, alltrim(kart_->NPOLIS),;
                       alltrim(kart_->SPOLIS)+" № "+alltrim(kart_->NPOLIS)))
          s1 += eval(blk,f_s_csv(s))+";"
          // 4 - Единый номер полиса ОМС
          s := iif(kart_->vpolis==3, alltrim(kart_->NPOLIS), "")
          s1 += eval(blk,s)+";"
          arr_fio := retFamImOt(1,.f.)
          // 5 - Фамилия застрахованного лица
          s1 += eval(blk,f_s_csv(arr_fio[1]))+";"
          // 6 - Имя застрахованного лица
          s1 += eval(blk,f_s_csv(arr_fio[2]))+";"
          // 7 - Отчество застрахованного лица
          s1 += eval(blk,f_s_csv(arr_fio[3]))+";"
          // 8 - Дата рождения застрахованного лица
          s1 += eval(blk,dtos(kart->date_r))+";"
          // 9 - Место рождения застрахованного лица
          s := iif(eq_any(kart_->vid_ud,3,14), alltrim(del_spec_symbol(kart_->mesto_r)), "")
          s1 += eval(blk,f_s_csv(s))+";"
          // 10 - Тип документа, удостоверяющего личность
          s1 += eval(blk,lstr(kart_->vid_ud))+";"
          // 11 - Номер или серия и номер документа, удостоверяющего личность.
          s := alltrim(kart_->ser_ud)+" № "+alltrim(kart_->nom_ud)
          s1 += eval(blk,f_s_csv(s))+";"
          // 12 - Дата выдачи документа, удостоверяющего личность
          s := iif(empty(kart_->kogdavyd), "", dtos(kart_->kogdavyd))
          s1 += eval(blk,s)+";"
          // 13 - Наименование органа, выдавшего документ
          s := alltrim(inieditspr(A__POPUPMENU,dir_server+"s_kemvyd",kart_->kemvyd))
          s1 += eval(blk,f_s_csv(s))+";"
          // 14 - СНИЛС застрахованного лица
          s1 += eval(blk,alltrim(kart->snils))+";"
          // 15 - Идентификатор МО
          s1 += eval(blk,glob_mo[_MO_KOD_TFOMS])+";"
          // 16 - Способ прикрепления
          s1 += eval(blk,lstr(krtp->S_PRIK))+";"
          // 17 - Тип прикрепления (Зарезервированное поле)
          s := ""
          s1 += eval(blk,s)+";"
          // 18 - Дата заявления
          s1 += eval(blk,dtos(krtp->D_PRIK))+";"
          // 19 - Дата открепления
          s1 += eval(blk,"")+";"
          // 20 ОИД МО
          s1 += eval(blk,f_s_csv(loidmo))+";"
          // 21 код подразделения
          s := alltrim(otd->kod_podr)
          s1 += eval(blk,f_s_csv(s))+";"
          // 22 номер участка
          s := lstr(tmp_krtp->uchast)
          s1 += eval(blk,s)+";"
          // 23 СНИЛС врача
          s := p2->snils
          s1 += eval(blk,s)+";"
          // 24 категория врача
          s := iif(p2->kateg==1,"1","2")
          s1 += eval(blk,s)
          //
          fwrite(fp,hb_OemToAnsi(s1))
          //
          select TMP_KRTP
          skip
        enddo
        if k == 3 // после смены участка
          select KRTP
          index on str(reestr,6) to (cur_dir+"tmp_krtp")
          use (cur_dir+"tmpu") new
          set relation to kod into KART
          go top
          do while !eof()
            ++i
            @ maxrow(),0 say str(i/(ii+j)*100,6,2)+"%" color cColorWait
            p2->(dbGoto(tmpu->kodp))
            otd->(dbGoto(p2->otd))
            select KRTP
            AddRec(6)
            krtp->REESTR   := krtr->KOD      // код реестра;по файлу "mo_krtr"
            krtp->KOD_K    := tmpu->kod      // код пациента по файлу "kartotek"
            krtp->D_PRIK   := sys_date       // дата прикрепления (заявления)
            krtp->S_PRIK   := 2              // способ прикрепления: 1-по месту регистрации, 2-по личному заявлению (без изменения м/ж), 3-по личному заявлению (в связи с изменением м/ж)
            krtp->UCHAST   := kart->uchast   // номер участка
            krtp->SNILS_VR := p2->snils      // СНИЛС участкового врача
            krtp->KOD_PODR := alltrim(otd->kod_podr) // код подразделения по паспорту ЛПУ
            krtp->REES_ZAP := i              // номер строки в реестре
            krtp->OPLATA   := 0              // тип оплаты;сначала 0, 1-прикреплён, 2-ошибки
            krtp->D_PRIK1  := ctod("")       // дата прикрепления
            UnLock
            //
            s1 := iif(i==1, "", hb_eol())
            // 1 - Номер записи в файле с 10.06.19г.
            s1 += eval(blk,lstr(i))+";"
            // 1 - Действие
            s := "И" // !!!!!!!!!!!!!! с версии 2.2.12
            s1 += eval(blk,s)+";"
            // 2 - Код типа ДПФС
            s := iif(kart_->vpolis==3, "П", iif(kart_->vpolis==2, "В", "С"))
            s1 += eval(blk,s)+";"
            // 3 - Серия и номер ДПФС
            s := iif(kart_->vpolis==3, "", ;
                     iif(kart_->vpolis==2, alltrim(kart_->NPOLIS),;
                         alltrim(kart_->SPOLIS)+" № "+alltrim(kart_->NPOLIS)))
            s1 += eval(blk,f_s_csv(s))+";"
            // 4 - Единый номер полиса ОМС
            s := iif(kart_->vpolis==3, alltrim(kart_->NPOLIS), "")
            s1 += eval(blk,s)+";"
            arr_fio := retFamImOt(1,.f.)
            // 5 - Фамилия застрахованного лица
            s1 += eval(blk,f_s_csv(arr_fio[1]))+";"
            // 6 - Имя застрахованного лица
            s1 += eval(blk,f_s_csv(arr_fio[2]))+";"
            // 7 - Отчество застрахованного лица
            s1 += eval(blk,f_s_csv(arr_fio[3]))+";"
            // 8 - Дата рождения застрахованного лица
            s1 += eval(blk,dtos(kart->date_r))+";"
            // 9 - Место рождения застрахованного лица
            s := iif(eq_any(kart_->vid_ud,3,14), alltrim(del_spec_symbol(kart_->mesto_r)), "")
            s1 += eval(blk,f_s_csv(s))+";"
            // fl := ascan(menu_vidud,{|x| x[2] == kart_->vid_ud }) == 0
            fl := ascan(getVidUd(), {|x| x[2] == kart_->vid_ud }) == 0
            if !fl
              if empty(kart_->nom_ud)
                fl := .t. //должно быть заполнено поле "НОМЕР удостоверения личности"
              elseif !ver_number(kart_->nom_ud)
                fl := .t. //поле "НОМЕР удостоверения личности" должно быть цифровым
              elseif !val_ud_nom(2,kart_->vid_ud,kart_->nom_ud)
                fl := .t.
              endif
            endif
            if !fl .and. eq_any(kart_->vid_ud,1,3,14) .and. empty(kart_->ser_ud)
              fl := .t. //не заполнено поле "СЕРИЯ удостоверения личности"
            endif
            if !fl .and. !empty(kart_->ser_ud) .and. !val_ud_ser(2,kart_->vid_ud,kart_->ser_ud)
              fl := .t.
            endif
            if fl
              // 10 - Тип документа, удостоверяющего личность
              s1 += eval(blk,"")+";"
              // 11 - Номер или серия и номер документа, удостоверяющего личность.
              s1 += eval(blk,"")+";"
            else
              // 10 - Тип документа, удостоверяющего личность
              s1 += eval(blk,lstr(kart_->vid_ud))+";"
              // 11 - Номер или серия и номер документа, удостоверяющего личность.
              s := alltrim(kart_->ser_ud)+" № "+alltrim(kart_->nom_ud)
              s1 += eval(blk,f_s_csv(s))+";"
            endif
            // 12 - Дата выдачи документа, удостоверяющего личность
            lkogdavyd := kart_->kogdavyd
            if !empty(kart_->kogdavyd) .and. !between(kart_->kogdavyd,kart->date_r,sys_date)
              if kart_->vid_ud == 3 // свид_во о рождении
                lkogdavyd := kart->date_r
              else
                lkogdavyd := ctod("")
              endif
            endif
            s := iif(empty(lkogdavyd), "", dtos(lkogdavyd))
            s1 += eval(blk,s)+";"
            // 13 - Наименование органа, выдавшего документ
            s := alltrim(inieditspr(A__POPUPMENU,dir_server+"s_kemvyd",kart_->kemvyd))
            s1 += eval(blk,f_s_csv(s))+";"
            // 14 - СНИЛС застрахованного лица
            if !empty(lsnils := kart->snils) .and. !val_snils(kart->snils,2)
              lsnils := ""
            endif
            s1 += eval(blk,alltrim(lsnils))+";"
            // 15 - Идентификатор МО
            s1 += eval(blk,glob_mo[_MO_KOD_TFOMS])+";"
            // 16 - Способ прикрепления
            s1 += eval(blk,lstr(krtp->S_PRIK))+";"
            // 17 - Тип прикрепления (Зарезервированное поле)
            s := ""
            s1 += eval(blk,s)+";"
            // 18 - Дата заявления
            s1 += eval(blk,dtos(krtp->D_PRIK))+";"
            // 19 - Дата открепления
            s1 += eval(blk,"")+";"
            // 20 ОИД МО
            s1 += eval(blk,f_s_csv(loidmo))+";"
            // 21 код подразделения
            s := alltrim(otd->kod_podr)
            s1 += eval(blk,f_s_csv(s))+";"
            // 22 номер участка
            s := lstr(kart->uchast)
            s1 += eval(blk,s)+";"
            // 23 СНИЛС врача
            s := p2->snils
            s1 += eval(blk,s)+";"
            // 24 категория врача
            s := iif(p2->kateg==1,"1","2")
            s1 += eval(blk,s)
            //
            fwrite(fp,hb_OemToAnsi(s1))
            //
            select TMPU
            skip
          enddo
        endif
        fclose(fp)
        if hb_FileExists(n_file)
          chip_copy_zipXML(n_file,dir_server+dir_XML_MO,.t.)
          keyboard chr(K_HOME)+chr(K_ENTER)
          select KRTF
          G_RLock(forever)
          krtf->KOL := ii+j
          krtf->TWORK2 := hour_min(seconds()) // время окончания обработки
        else
          func_error(4,"Ошибка создания файла "+n_file)
        endif
      endif
    endif
  endif
  close databases
  G_SUnLock(str_sem)
  return NIL
  
***** 11.10.15
Function f1_p_f_pripisnoe_naselenie(aerr)
  Local s := space(80), lfio := '"'+alltrim(p2->fio)+'"'

  if p2->kateg != 1
    aadd(aerr,"у специалиста "+lfio+" в справочнике персонала категория должна быть ВРАЧ")
  elseif empty(p2->snils)
    aadd(aerr,"не введен СНИЛС у врача "+lfio+" в справочнике персонала")
  elseif !val_snils(p2->snils,2,@s)
    aadd(aerr,s+" у врача "+lfio+" в справочнике персонала")
  endif
  if empty(p2->otd)
    aadd(aerr,"не проставлено отделение у врача "+lfio+" в справочнике персонала")
  else
    select OTD
    goto (p2->otd)
    if empty(otd->kod_podr)
      aadd(aerr,'в отд."'+alltrim(otd->name)+'" не проставлен код подразделения')
    endif
  endif
  return NIL

***** 05.03.13
Function kartoteka_z_prikreplenie()
  Static srec := 0
  Local blk, t_arr[BR_LEN]
  Private str_find := "1", muslovie := "kart->kod > 0", z_rec := 0
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := maxrow()-1
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := maxcol()
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := "Картотека - прикрепление"
  t_arr[BR_TITUL_COLOR] := "BG+/GR"
  t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B,R/BG,W+/R",.t.,72}
  t_arr[BR_ARR_BLOCK] := {{| | FindFirst(str_find)},;
                          {| | FindLast(str_find)},;
                          {|_n| SkipPointer(_n,muslovie)},;
                          str_find,muslovie;
                         }
  blk := {|| iif(kart2->mo_pr==glob_MO[_MO_KOD_TFOMS], {1,2},;
                 iif(empty(kart2->mo_pr), {3,4}, {5,6})) }
  t_arr[BR_COLUMN] := {{ center("Ф.И.О.",35),{|| left(kart->fio,32) }, blk },;
                       {"Дата рожд.", {|| full_date(kart->date_r) }, blk },;
                       {" Прикрепление", {|| padr(inieditspr(A__MENUVERT,glob_arr_mo,kart2->mo_pr),34) }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход; ^^ или нач.буква - поиск; ^<F9>^ - печать заявления на прикрепление") }
  t_arr[BR_EDIT] := {|nk,ob| f1_k_z_prikreplenie(nk,ob,"edit") }
  use_base("kartotek")
  set order to 2
  if srec > 0
    goto (srec)
  else
    find (str_find)
  endif
  edit_browse(t_arr)
  if z_rec > 0
    srec := z_rec
  endif
  close databases
  return NIL
  
// 29.03.23
Function f1_k_z_prikreplenie(nKey, oBrow, regim)
  Local j, s, ret := -1
  if regim == "edit" .and. nKey == K_F9
    if kart2->mo_pr == glob_MO[_MO_KOD_TFOMS]
      func_error(1,"Данный пациент уже прикреплён к Вашему МО")
    endif
    z_rec := kart->(recno())
    delFRfiles()
    dbcreate(fr_titl, {;
         {"name_org","C",130,0},;
         {"adres_org","C",110,0},;
         {"fio","C",60,0},;
         {"fam_io","C",30,0},;
         {"pol","C",10,0},;
         {"date_r","C",120,0},;
         {"pasport","C",250,0},;
         {"adres_p","C",250,0},;
         {"adres_g","C",250,0},;
         {"smo","C",100,0},;
         {"ruk_fio","C",60,0},;
         {"ruk","C",20,0}})
    R_Use(dir_server+"organiz",,"ORG")
    use (fr_titl) new alias FRT
    append blank
    frt->name_org := glob_MO[_MO_SHORT_NAME]+" ("+glob_MO[_MO_KOD_TFOMS]+")"
    frt->adres_org := alltrim(org->adres)
    frt->fio := kart->fio
    frt->fam_io := fam_i_o(kart->fio)
    frt->pol := iif(kart->pol=="М", "мужской", "женский")
    frt->date_r := full_date(kart->date_r)+"г. "+alltrim(kart_->mesto_r)
    s := ""
    if kart_->vid_ud > 0
      // if (j := ascan(menu_vidud, {|x| x[2] == kart_->vid_ud})) > 0
      //   s := menu_vidud[j,4]+": "
      if (j := ascan(getVidUd(), {|x| x[2] == kart_->vid_ud})) > 0
        s := getVidUd()[j, 4] + ': '
      endif
      if !empty(kart_->ser_ud)
        s += charone(" ",alltrim(kart_->ser_ud))+" "
      endif
      if !empty(kart_->nom_ud)
        s += alltrim(kart_->nom_ud)+" "
      endif
      if !empty(kart_->kogdavyd)
        s += "выдан "+full_date(kart_->kogdavyd)+"г. "
      endif
      if !empty(kart_->kemvyd)
        s += inieditspr(A__POPUPMENU, dir_server+"s_kemvyd", kart_->kemvyd)
      endif
    endif
    frt->pasport := s
    frt->adres_g := ret_okato_ulica(kart->adres,kart_->okatog)
    if emptyall(kart_->okatop,kart_->adresp)
      frt->adres_p := frt->adres_g
    else
      frt->adres_p := ret_okato_ulica(kart_->adresp,kart_->okatop)
    endif
    s := alltrim(inieditspr(A__MENUVERT,glob_arr_smo,int(val(kart_->smo))))+", полис "
    s += alltrim(rtrim(kart_->SPOLIS)+" "+kart_->NPOLIS)+" ("+;
          alltrim(inieditspr(A__MENUVERT, mm_vid_polis, kart_->VPOLIS))+")"
    frt->smo := s
    frt->ruk_fio := alltrim(iif(empty(org->ruk_fio), org->ruk, org->ruk_fio))
    frt->ruk := alltrim(org->ruk)
    close databases
    call_fr("mo_zprik")
    //
    use_base("kartotek")
    set order to 2
    goto (z_rec)
    ret := 0
  endif
  return ret
  
***** 11.09.17 создать файл(ы) сверки
Function pripisnoe_naselenie_create_SVERKA()
  Local ii := 0, s, buf := savescreen(), fl, af := {}, arr_fio, ta, fl_polis, fl_pasport
  if !f_Esc_Enter("создания файла сверки",.t.)
    return NIL
  endif
  ClrLine(maxrow(),color0)
  dbcreate(cur_dir+"tmp",{{"kod","N",7,0}})
  use (cur_dir+"tmp") new
  hGauge := GaugeNew(,,,"Составление списка для включения в файл сверки",.t.)
  GaugeDisplay( hGauge )
  curr := 0
  R_Use(dir_server+"mo_kfio",,"KFIO")
  index on str(kod,7) to (cur_dir+"tmp_kfio")
  R_Use_base("kartotek")
  set order to 2
  find ("1")
  do while kart->kod > 0 .and. !eof()
    GaugeUpdate( hGauge, ++curr/lastrec() )
    fl := .t.
    if empty(kart->date_r)
      fl := .f. // не заполнено поле "Дата рождения"
    elseif kart->date_r >= sys_date
      fl := .f. // дата рождения больше сегодняшней даты
    elseif year(kart->date_r) < 1900
      fl := .f. // дата рождения < 1900г.
    endif
    if fl
      fl := between(kart_->vpolis,1,3) .and. !empty(kart_->NPOLIS)
    endif
    if fl
      arr_fio := retFamImOt(1,.f.,.t.)
      if val_fio(arr_fio) .and. !(len(arr_fio[2]) < 2 .and. len(arr_fio[3]) < 2)
        //
      else
        fl := .f.
      endif
    endif
    if !fl .and. kart2->mo_pr == glob_MO[_MO_KOD_TFOMS]
      fl := .t.
    endif
    if fl
      select TMP
      append blank
      tmp->kod := kart->kod
      if tmp->(recno()) % 100 == 0
        @ maxrow(),1 say lstr(tmp->(recno())) color color0
        if tmp->(recno()) % 2000 == 0
          Commit
        endif
      endif
    endif
    select KART
    skip
  enddo
  ii := tmp->(lastrec())
  close databases
  CloseGauge(hGauge)
  i := -1
  arr := {}
  do while ii > 0
    k := min(ii,99999) ; i++
    aadd(arr,{k,sys_date-i,0})
    ii -= k
  enddo
  fl := .f.
  s := "SZ2"
  R_Use(dir_server+"mo_krtr",,"KRTR")
  index on dtos(DFILE) to (cur_dir+"tmp_krtr") for left(FNAME,3) == s
  ar := {}
  for i := 1 to len(arr)
    n_file := s+glob_mo[_MO_KOD_TFOMS]+dtos(arr[i,2])+scsv
    s1 := ""
    find (dtos(arr[i,2]))
    if found()
      s1 := " - уже был создан"
      fl := .t.
    endif
    aadd(ar,n_file+" ("+lstr(arr[i,1])+" чел.)"+s1)
  next
  close databases
  ClrLine(maxrow(),color0)
  ar2 := {" Выход "} ; s1 := "файл"+iif(len(arr)==1,"а","ов")
  if fl
    Ins_Array(ar,1,"Запрет создания "+s1+" сверки:")
  else
    Ins_Array(ar,1,"Подтвердите создание "+s1+" сверки:")
    aadd(ar2," Создание "+s1+" сверки ")
  endif
  if len(ar) < 8
    aadd(ar,"")
    if len(ar) < 8
      Ins_Array(ar,2,"")
    endif
  endif
  if f_alert(ar,ar2,1,"GR+/R","W+/R",,,"GR+/R,N/BG") == 2
    mywait()
    blk := {|_s| iif(empty(_s), '', '"'+_s+'"') }
    G_Use(dir_server+"mo_krtr",,"KRTR")
    index on str(kod,6) to (cur_dir+"tmp_krtr")
    G_Use(dir_server+"mo_krtf",,"KRTF")
    index on str(kod,6) to (cur_dir+"tmp_krtf")
    G_Use(dir_server+"mo_krtp",,"KRTP")
    index on str(reestr,6) to (cur_dir+"tmp_k")
    R_Use(dir_server+"mo_kfio",cur_dir+"tmp_kfio","KFIO")
    R_Use_base("kartotek")
    set order to 0
    use (cur_dir+"tmp") new
    set relation to kod into KART
    curr := 0
    restscreen(buf)
    for i := 1 to len(arr)
      n_file := "SZ2"+glob_mo[_MO_KOD_TFOMS]+dtos(arr[i,2])
      select KRTR
      AddRec(6)
      krtr->KOD := recno()
      krtr->FNAME := n_file
      krtr->DFILE := arr[i,2]
      krtr->DATE_OUT := ctod("")
      krtr->NUMB_OUT := 0
      krtr->KOL := arr[i,1]
      krtr->KOL_P := 0
      krtr->ANSWER := 0  // 0-не было ответа, 1-был прочитан ответ
      //
      select KRTF
      AddRec(6)
      krtf->KOD   := recno()
      krtf->FNAME := krtr->FNAME
      krtf->DFILE := krtr->DFILE
      krtf->TFILE := hour_min(seconds())
      krtf->TIP_IN := 0
      krtf->TIP_OUT := _CSV_FILE_SVERKAZ
      krtf->REESTR := krtr->KOD
      krtf->DWORK := sys_date
      krtf->TWORK1 := hour_min(seconds()) // время начала обработки
      krtf->TWORK2 := ""                  // время окончания обработки
      //
      krtr->KOD_F := krtf->KOD
      dbUnLockAll()
      Commit
      //
      n_file += scsv
      delete file (n_file)
      fp := fcreate(n_file)
      //
      hGauge := GaugeNew(,,,"Создание файла сверки "+n_file,.t.)
      GaugeDisplay( hGauge )
      for ii := 1 to arr[i,1]
        GaugeUpdate( hGauge, ii/arr[i,1] )
        ++curr
        select TMP
        goto (curr)
        arr_fio := retFamImOt(1,.f.,.t.)
        fl_polis := fl_pasport := .t.
        if empty(kart_->SPOLIS)
          ta := {}
          Valid_SN_Polis(kart_->vpolis,"",kart_->NPOLIS,ta,.t.)
          fl_polis := empty(ta) // функция проверки не вернула ошибок
        else
          fl_polis := .f. // есть серия полиса => иногородний
        endif
        if !eq_any(kart_->vid_ud,1,3,14)
          fl_pasport := .f. // не то в поле "ВИД удостоверения личности"
        else
          if empty(kart_->nom_ud)
            fl_pasport := .f. // должно быть заполнено поле "НОМЕР удостоверения личности"
          elseif !val_ud_nom(2,kart_->vid_ud,kart_->nom_ud)
            fl_pasport := .f.
          endif
          if fl_pasport .and. !empty(kart_->ser_ud) .and. !val_ud_ser(2,kart_->vid_ud,kart_->ser_ud)
            fl_pasport := .f.
          endif
        endif
        select KRTP
        AddRec(6)
        krtp->REESTR   := krtr->KOD // код реестра;по файлу "mo_krtr"
        krtp->KOD_K    := kart->kod // код пациента по файлу "kartotek"
        krtp->D_PRIK   := sys_date  // дата прикрепления (заявления)
        krtp->S_PRIK   := 0         // способ прикрепления: 1-по месту регистрации, 2-по личному заявлению (без изменения м/ж), 3-по личному заявлению (в связи с изменением м/ж)
        krtp->REES_ZAP := ii        // номер строки в реестре
        krtp->OPLATA   := 0         // тип оплаты;сначала 0, 1-прикреплён, 2-ошибки
        krtp->D_PRIK1  := ctod("")  // дата прикрепления
        //
        s1 := iif(ii==1, "", hb_eol()) + eval(blk,lstr(ii))+";" // в начале - номер по порядку
        // 1 - Код типа ДПФС
        s := iif(kart_->vpolis==3, "П", iif(kart_->vpolis==2, "В", "С"))
        s1 += eval(blk,s)+";"
        if kart_->vpolis < 3
          s := alltrim(kart_->SPOLIS)+alltrim(kart_->NPOLIS)
          if empty(s)
            s :=  iif(kart_->vpolis == 2, "123456789", "34")
          endif
          if kart_->vpolis == 2
            s := padr(s,9,"0")
          else
            s := padr(s,16,"0")
          endif
        else
          s := ""
        endif
        s1 += eval(blk,s)+";"
        // 3 - Единый номер полиса ОМС
        s := iif(kart_->vpolis == 3, alltrim(kart_->NPOLIS), "")
        s1 += eval(blk,s)+";"
        /*if fl_polis
          // 2 - Серия и номер ДПФС (только номер - наша область)
          s := iif(kart_->vpolis < 3, alltrim(kart_->NPOLIS), "")
          s1 += eval(blk,s)+";"
          // 3 - Единый номер полиса ОМС
          s := iif(kart_->vpolis == 3, alltrim(kart_->NPOLIS), "")
          s1 += eval(blk,s)+";"
        else
          s1 += ";;"
        endif*/
        // 4 - Фамилия застрахованного лица
        s1 += eval(blk,arr_fio[1])+";"
        // 5 - Имя застрахованного лица
        s1 += eval(blk,arr_fio[2])+";"
        // 6 - Отчество застрахованного лица
        s1 += eval(blk,arr_fio[3])+";"
        // 7 - Дата рождения застрахованного лица
        s1 += eval(blk,dtos(kart->date_r))+";"
        if fl_pasport
          // 8 - Тип документа, удостоверяющего личность
          s := lstr(kart_->vid_ud)
          s1 += eval(blk,s)+";"
          // 9 - Номер или серия и номер документа, удостоверяющего личность.
          s := alltrim(kart_->ser_ud)+" № "+alltrim(kart_->nom_ud)
          s1 += eval(blk,s)+";"
        else
          s1 += ";;"
        endif
        // 10 - СНИЛС застрахованного лица
        s := ""
        if !empty(kart->snils) .and. val_snils(kart->snils,2)
          s := kart->snils
        endif
        s1 += eval(blk,s)  // нет ";", т.к. последнее поле
        //
        fwrite(fp,hb_OemToAnsi(s1))
        if ii % 3000 == 0
          dbUnLockAll()
          Commit
        endif
      next ii
      fclose(fp)
      name_zip := alltrim(krtr->FNAME)+szip
      select KRTR
      G_RLock(forever)
      krtr->KOL := arr[i,1]
      select KRTF
      G_RLock(forever)
      krtf->KOL := arr[i,1]
      krtf->TWORK2 := hour_min(seconds()) // время окончания обработки
      dbUnLockAll()
      Commit
      if hb_FileExists(n_file)
        if chip_create_zipXML(name_zip,{n_file},.t.)
          stat_msg("Файл сверки "+n_file+" создан!") ; mybell(1,OK)
        endif
      else
        func_error(4,"Ошибка создания файла "+n_file)
      endif
    next i
    close databases
    keyboard chr(K_HOME)+chr(K_ENTER)
  endif
  restscreen(buf)
  return NIL
  
***** 05.07.15 быстрое редактирование участков списком
Function edit_uchast_spisok()
  Local flag := .T. //фильтр
  Local arr_pr := {{"к нашему МО",0},;
                   {"все пациенты",1}}
  Local arr_sr := {{"по ФИО",0},;
                   {"по адресу",1},;
                   {"по месту работы",2}}
  Local arr_voz := {{"все пациенты",0},;
                    {"взрослые",1},;
                    {"дети",2}}
  Local t_okato, t_rec, len_fio, buf := savescreen()
  // Номер участка
  Local fl_uchast := 0
  // Взрослый/Ребёнок
  Local fl_vzros_reb := 0 //по умолчанию взрослый
  // Окато - населённый пункт прописка
  Local fl_okato := okato_umolch
  // Прикрепление
  Local fl_pr := 0 //
  // фильтр АДРЕС
  Local fl_adres := space(20) //
  // фильтр ДОЛЖНОСТЬ
  Local fl_dol := space(20) //
  // фильтр ФИО
  Local fl_fio := space(20) //
  //Сортировать
  Local fl_sort := 0
  // ДИАЛОГ -заготовка
  Private mfl_vzros_reb, m1fl_vzros_reb := fl_vzros_reb,;
          muchast := "все пациенты", m1uchast := 0,;
          mokatog := space(10), m1okatog := space(11),;
          mokatop := space(10), m1okatop := space(11),;
          mfl_pr, m1fl_pr := fl_pr,;
          mfl_adres := fl_adres, mfl_dol := fl_dol,;
          mfl_fio := fl_fio ,;
          mfl_sort, m1fl_sort := fl_sort
  mfl_vzros_reb := inieditspr(A__MENUVERT,arr_voz,m1fl_vzros_reb)
  mfl_pr   := inieditspr(A__MENUVERT,arr_pr,m1fl_pr)
  mfl_sort := inieditspr(A__MENUVERT,arr_sr,m1fl_sort)
  //
  Private arr_uchast := {}
  setcolor(cDataCGet)
  ix := 12
  ClrLines(ix,23)
  @ ix,0 to ix,79
  str_center(ix," Запрос для составления списка ")
  ++ix
  @ ++ix,3 say "Участок (участки)" get muchast ;
                reader {|x|menu_reader(x,;
                           {{ |k,r,c| get_uchast(r+1,c) }},A__FUNCTION,,,.f.)}
  @ ++ix,3 say "Прикрепление" get mfl_pr ;
                    reader {|x|menu_reader(x,arr_pr,A__MENUVERT,,,.f.)}
  @ ++ix,3 say "Возраст" get mfl_vzros_reb  ;
                    reader {|x|menu_reader(x,arr_voz,A__MENUVERT,,,.f.)}
  @ ++ix,3 say "Адрес регистрации (ОКАТО)" get mokatog ;
    reader {|x| menu_reader(x,{{|k,r,c| get_okato_ulica(k,r,c,{k,mokatog,})}},A__FUNCTION,,,.f.)}
  @ ++ix,3 say "Адрес пребывания (ОКАТО)" get mokatop ;
    reader {|x| menu_reader(x,{{|k,r,c| get_okato_ulica(k,r,c,{k,mokatop,})}},A__FUNCTION,,,.f.)}
  @ ++ix,3 say "Улица (подстрока или шаблон)" get mfl_adres pict "@!"
  @ ++ix,3 say "Место работы (подстрока или шаблон)" get mfl_dol pict "@!"
  @ ++ix,3 say "Фамилия (начальные буквы)" get mfl_fio pict "@!"
  @ ++ix,3 say "Как сортировать список пациентов" get mfl_sort  ;
                    reader {|x|menu_reader(x,arr_sr,A__MENUVERT,,,.f.)}
  status_key("^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода и создание списка пациентов")
  myread()
  if lastkey() == K_ESC .or. !f_Esc_Enter(1)
    restscreen(buf)
    return NIL
  endif
  mywait()
  dbcreate(cur_dir+"tmp_krtp",{{"KOD_K","N",7,0}})
  use (cur_dir+"tmp_krtp") new
  // Фильтр по ФИО
  if !empty(mfl_fio)
    mfl_fio := upper(alltrim(mfl_fio))
    len_fio := len(mfl_fio)
  endif
  index on str(kod_k,7) to (cur_dir+"tmp_wq")
  Use_base("kartotek")
  go top
  do while !eof()
    flag := (kart->kod > 0 .and. !(left(kart2->PC2,1)=='1'))
    //участки
    if flag .and. !empty(muchast)
      flag := f_is_uchast(arr_uchast,kart->uchast)
    endif
    // Взрослый/Ребёнок
    if flag .and. m1fl_vzros_reb > 0
      if m1fl_vzros_reb == 1 // взрослые
        if !(count_years(kart->date_r,sys_date) >= 18)
          flag := .F.
        endif
      else // дети
        if !(count_years(kart->date_r,date()) < 18)
          flag := .F.
        endif
      endif
    endif
    // Окато
    if flag .and. !empty(m1okatog)
      s := m1okatog
      for i := 1 to 3
        if right(s,3)=='000'
          s := left(s,len(s)-3)
        else
          exit
        endif
      next
      flag := (left(kart_->okatog,len(s))==s)
    endif
    if flag .and. !empty(m1okatop)
      s := m1okatop
      for i := 1 to 3
        if right(s,3)=='000'
          s := left(s,len(s)-3)
        else
          exit
        endif
      next
      flag := (left(kart_->okatop,len(s))==s)
    endif
    if flag .and. m1fl_pr == 0 // прикреплён к НАМ
      flag := (kart2->mo_pr == glob_MO[_MO_KOD_TFOMS])
    endif
    // Фильтр по адресу
    if flag .and. !empty(mfl_adres)
      if "*" $  mfl_adres .or. "?" $ mfl_adres
        flag := like(alltrim(mfl_adres),upper(kart->adres))
      else
        flag := (alltrim(mfl_adres) $ upper(kart->adres))
      endif
    endif
    // Фильтр по работе
    if flag .and. !empty(mfl_dol)
      if "*" $  mfl_dol .or. "?" $ mfl_dol
        flag := like(alltrim(mfl_dol),upper(kart->mr_dol))
      else
        flag := (alltrim(mfl_dol) $ upper(kart->mr_dol))
      endif
    endif
    // Фильтр по ФИО
    if flag .and. !empty(mfl_fio)
      flag := (mfl_fio == upper(left(kart->fio,len_fio)))
    endif
    // Добавляем запись
    if flag
      select TMP_KRTP
      append blank
      tmp_krtp->KOD_K := kart->(recno())
    endif
    select KART
    skip
  enddo
  Private ku := tmp_krtp->(lastrec())
  close databases
  if ku == 0
    restscreen(buf)
    return func_error(4,"По данному условию отбора ничего не найдено!")
  endif
  //
  Private TIP_uchast  := 1 // 1-адрес 2-работа
  G_Use(dir_server+"kartotek",{dir_server+"kartotek",;
                               dir_server+"kartoten",;
                               dir_server+"kartotep",;
                               dir_server+"kartoteu"},"KART")
  set order to 0
  use (cur_dir+"tmp_krtp") new
  set relation to kod_k into KART
  // устанавливаем реляцию
  if m1fl_sort ==  0 //по фио
    index on upper(kart->fio) to (cur_dir+"tmp_ru")
  elseif m1fl_sort ==  1 // по адресу
    index on upper(kart->adres) to (cur_dir+"tmp_ru")
  else
    index on upper(kart->mr_dol) to (cur_dir+"tmp_ru")
    TIP_uchast := 2 // 1-адрес 2-работа
  endif
  Alpha_Browse(2,0,23,79,"f1_vvod_uchast_spisok",color0,"Редактирование участка ("+lstr(ku)+" чел.)","BG+/GR",;
               .t.,.t.,,,"f2_vvod_uchast_spisok",,;
               {"═","░","═","N/BG,W+/N,B/BG,W+/B,R/BG,BG/R",.t.,180,"*+"} )
  close databases
  restscreen(buf)
  return NIL
  
***** 29.05.15
Function f1_vvod_uchast_spisok(oBrow)
  Local oColumn, blk
  oColumn := TBColumnNew(center("ФИО",30),{|| padr(kart->fio,30) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Дата рожд.",{|| full_date(kart->date_r) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Уч",{|| str(kart->uchast,2) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  if TIP_uchast  == 1
    oColumn := TBColumnNew(center("Адрес",31),{|| padr(kart->adres,31) })
  else
    oColumn := TBColumnNew(center("Место работы",31),{|| padr(kart->mr_dol,31) })
  endif
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование участка;  ^<F9>^ - печать списка")
  return NIL
  
  
***** 28.12.21
Function f2_vvod_uchast_spisok(nKey,oBrow)
  Local j := 0, flag := -1, buf := save_maxrow(), buf1, fl := .f.,;
        nr := row(), c1, rec, mkod, buf0, tmp_color := setcolor(), t_vr,;
        vp := int(val(lstr(day(sys_date))+strzero(month(sys_date),2)))
  Private  much, old_uch
  do case
    case nKey == K_F10
      if ku > 10000
        func_error(4,"Слишком много пациентов в списке")
      elseif ! hb_user_curUser:IsAdmin()
        func_error(4,err_admin)
      elseif (much := input_value(18,5,20,74,color1,;
          "Введите номер участка для простановки всем пациентам из списка",0,"99")) != NIL ;
        .and. much > 0 ;// .and. involved_password(1,vp,"смены номера участка всем пациентам из списка") ;
            .and. f_alert({padc("Выберите действие",60,".")},;
                          {" Отказ "," Сменить номер участка всем пациентам "},;
                          1,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" ) == 2
        mywait()
        rec := tmp_krtp->(recno())
        go top
        do while !eof()
          kart->(G_RLock(forever))
          kart->uchast := much
          kart->(dbunlock())
          skip
        enddo
        rest_box(buf)
        select TMP_KRTP
        goto (rec)
        flag := 0
        stat_msg('Участок заменён всем пациентам!') ; mybell(1,OK)
      endif
    case nKey == K_F9
      mywait()
      rec := tmp_krtp->(recno())
      f3_vvod_uchast_spisok(TIP_uchast)
      rest_box(buf)
      select TMP_KRTP
      goto (rec)
      flag := 0
    case nKey == K_ENTER
      old_uch := much := kart->uchast
      c1 := 44
      @ nr,c1 get much pict "99" color "GR+/R"
      myread()
      if lastkey() != K_ESC .and. old_uch != much
        kart->(G_RLock(forever))
        kart->uchast := much
        kart->(dbunlock())
        keyboard chr(K_TAB)
      endif
      flag := 0
    otherwise
      keyboard ""
  endcase
  return flag
  
***** 28.05.15
Function f3_vvod_uchast_spisok(tip)
  //tip - 1 адрес
  //      2 место работы
  Local sh, HH := 78, name_file := "reg_prip"+stxt,i := 0, arr_title, s
  s := {"Адрес","Место работы"}[tip]
  arr_title := {;
  "─────┬────┬────────────────────────────────────────┬──────────┬─────────────────────────────────────────────────",;
  "№ п/п│Уч-к│               Ф.И.О                    │Дата рожд.│"+center(s,50),;
  "─────┴────┴────────────────────────────────────────┴──────────┴─────────────────────────────────────────────────"}
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  sh := len(arr_title[1])
  add_string("")
  add_string(center("Список пациентов (для ввода участка)",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  select TMP_KRTP
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(str(++i,5)+str(kart->uchast,4)+"  "+padr(kart->fio,40)+" "+;
                 full_date(kart->date_r)+" "+;
                 alltrim(iif(tip==1,kart->adres,kart->mr_dol)))
    select TMP_KRTP
    skip
  enddo
  fclose(fp)
  viewtext(name_file,,,,.t.,,,6)
  return NIL
  
***** 09.09.15 Просмотр/печать прикреплённого населения
Function spisok_pripisnoe_naselenie(par)
  Static sj, smo := "      "
  Local i, j, k, s, arr := {}, n_file := "pr_nas"+lstr(par)+stxt, ;
        ret_arr, sh := 81, HH := 80, buf := save_maxrow()
  if empty(arr_mo)
    mywait()
    R_Use(dir_server+"kartotek",,"KART")
    R_Use(dir_server+"kartote2",,"KART2")
    set relation to recno() into KART
    index on mo_pr to (cur_dir+"tmp_kart2") for !kart->(eof()) .and. kart->kod > 0
    go top
    do while !eof()
      if (i := ascan(arr_mo, {|x| x[2] == kart2->mo_pr })) == 0
        aadd(arr_mo, {"",kart2->mo_pr,0,0}) ; i := len(arr_mo)
      endif
      arr_mo[i,3] ++
      if left(kart2->PC2,1) == "1"
        arr_mo[i,4] ++
      endif
      skip
    enddo
    close databases
    for i := 1 to len(arr_mo)
      if (j := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == arr_mo[i,2]})) > 0
        arr_mo[i,1] := str(arr_mo[i,3],6)+" чел. "+arr_mo[i,2]+" "+glob_arr_mo[j,_MO_SHORT_NAME]
        if arr_mo[i,2] == glob_MO[_MO_KOD_TFOMS]
          aadd(arr,i)
        endif
      else
        aadd(arr_no,arr_mo[i,2])
        aadd(arr,i)
      endif
    next
    asort(arr)
    for i := len(arr) to 1 step -1
      del_array(arr_mo,arr[i])
    next
    asort(arr_mo,,,{|x,y| x[2] < y[2] })
    rest_box(buf)
  endif
  if (j := f_alert({"",;
                    "Выберите порядок сортировки выходного документа",;
                    ""},;
                   {" По ~ФИО "," По ~участку "},;
                   sj,"W/RB","G+/RB",18,,"BG+/RB,W+/R,W+/RB,GR+/R" )) == 0
    return NIL
  endif
  sj := j
  mywait()
  fl := .t.
  R_Use(dir_server+"kartotek",,"KART")
  R_Use(dir_server+"kartote2",,"KART2")
  set relation to recno() into KART
  set index to (cur_dir+"tmp_kart2")
  do case
    case par == 1
      find (glob_MO[_MO_KOD_TFOMS])
      index on iif(sj==1,"",str(kart->uchast,2))+upper(kart->fio)+dtos(kart->date_r) to (cur_dir+"tmp_kart") ;
            while kart2->mo_pr == glob_MO[_MO_KOD_TFOMS]
    case par == 2
      popup_2array(arr_mo,2,2,smo,1,@ret_arr,"Выбор МО прикрепления","B/BG")
      if valtype(ret_arr) == "A"
        smo := ret_arr[2]
        find (ret_arr[2])
        index on iif(sj==1,"",str(kart->uchast,2))+upper(kart->fio)+dtos(kart->date_r) to (cur_dir+"tmp_kart") ;
              while kart2->mo_pr == ret_arr[2]
      else
        fl := .f.
      endif
    case par == 3
      index on iif(sj==1,"",str(kart->uchast,2))+upper(kart->fio)+dtos(kart->date_r) to (cur_dir+"tmp_kart") ;
            for !kart->(eof()) .and. kart->kod > 0 .and. ascan(arr_no,kart2->mo_pr) > 0
  endcase
  if fl
    arr_title := {;
  "──┬──────────────────────────────────────────────────┬──────────┬──────────────────────────────────────────────────┬──────────",;
  "Уч│                    Ф.И.О                         │Дата рожд.│                      Адрес                       │Прикреплен",;
  "──┴──────────────────────────────────────────────────┴──────────┴──────────────────────────────────────────────────┴──────────"}
    sh := len(arr_title[1])
    fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
    add_string("")
    do case
      case par == 1
        add_string(center("Состав картотеки (прикреплённые к нашей МО)",sh))
      case par == 2
        add_string(center("Состав картотеки (прикреплённые к "+substr(ret_arr[1],13)+")",sh))
      case par == 3
        add_string(center("Состав картотеки (не прикреплённые ни к одной МО)",sh))
    endcase
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    k := k1 := 0
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(put_val(kart->uchast,2)+" "+;
                 iif(left(kart2->PC2,1)=="1", padr(kart->fio,45)+" УМЕР", padr(kart->fio,50))+" "+;
                 full_date(kart->date_r)+" "+padr(kart->adres,50)+" "+;
                 iif(par==3, "", iif(empty(kart2->pc4),full_date(kart2->DATE_PR),alltrim(kart2->pc4))))
      ++k
      if left(kart2->PC2,1)=="1"
        ++k1
      endif
      skip
    enddo
    add_string(replicate("-",sh))
    add_string("Итого: "+lstr(k)+" чел. (в т.ч. умерло - "+lstr(k1)+")")
    fclose(fp)
    viewtext(n_file,,,,.t.,,,6)
  endif
  close databases
  rest_box(buf)
  return NIL
  
***** 25.03.18 Подсчёт количества прикреплённого населения по участкам
Function kol_uch_pripisnoe_naselenie()
  Local sh, HH := 60, name_file := "uch_prik"+stxt, arr_title, i, j, k, arr1 := {}, arr2 := {},;
        fl, arr, buf := save_maxrow()
  mywait()
  R_Use(dir_exe+"_okatos",cur_dir+"_okats","SELO")
  R_Use(dir_exe+"_okatoo",cur_dir+"_okato","OBLAST")
  R_Use_base("kartotek")
  set order to
  go top
  do while !eof()
    @ maxrow(),0 say str(recno()/lastrec()*100,6,2)+"%" color cColorWait
    if kart->kod > 0 .and. !(left(kart2->PC2,1)=='1') .and. kart2->mo_pr == glob_MO[_MO_KOD_TFOMS] // прикреплён к НАМ
      v := iif(count_years(kart->date_r,sys_date) < 18, 2, 1)
      j := iif(kart->pol == "М", 2, 3)
      k := 4 // город
      fl := .f.
      if kart_->gorod_selo == 2
        fl := .t.  // нашли
        k := 5   // село
      endif
      if !fl .and. !empty(okato_rajon(kart_->okatog,@arr))
        if arr[5] == 1 // город
          fl := .t.  // нашли
          k := 4   // город
        endif
      endif
      if !fl
        select SELO
        find (padr(kart_->okatog,11,'0'))
        if found()
          fl := .t.  // нашли
          k := iif(selo->selo == 0, 5, 4)
        endif
        if !fl
          select OBLAST
          find (padr(kart_->okatog,5,'0'))
          if found()
            fl := .t.  // нашли
            k := iif(oblast->selo == 0, 5, 4)
          endif
        endif
      endif
      if v == 1
        if (i := ascan(arr1, {|x| x[1] == kart->uchast })) == 0
          aadd(arr1, {kart->uchast,0,0,0,0}) ; i := len(arr1)
        endif
        arr1[i,j] ++
        arr1[i,k] ++
      else
        if (i := ascan(arr2, {|x| x[1] == kart->uchast })) == 0
          aadd(arr2, {kart->uchast,0,0,0,0}) ; i := len(arr2)
        endif
        arr2[i,j] ++
        arr2[i,k] ++
      endif
    endif
    select KART
    skip
  enddo
  close databases
  rest_box(buf)
  if len(arr1) == 0 .and. len(arr2) == 0
    func_error(4,"Не обнаружено пациентов, прикреплённых к нашей МО")
  else
    arr := array(5)
    asort(arr1,,,{|x,y| x[1] < y[1] })
    asort(arr2,,,{|x,y| x[1] < y[1] })
    arr_title := {;
      "─────────┬───────────┬───────────┬───────────┬───────────┬───────────",;
      "№ участка│  мужчины  │  женщины  │   город   │   село    │   Всего   ",;
      "─────────┴───────────┴───────────┴───────────┴───────────┴───────────"}
    fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
    sh := len(arr_title[1])
    add_string(glob_mo[_MO_SHORT_NAME])
    add_string("")
    add_string(center("Количество прикреплённых пациентов",sh))
    add_string(center("[ по состоянию на "+date_8(sys_date)+"г. ]",sh))
    aeval(arr_title, {|x| add_string(x) } )
    if len(arr1) > 0
      if verify_FF(HH-2,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      afill(arr,0)
      add_string("")
      add_string(padc("взрослые",sh,"_"))
      for i := 1 to len(arr1)
        if verify_FF(HH,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(str(arr1[i,1],7)+put_val(arr1[i,2],12)+put_val(arr1[i,3],12)+;
                                    put_val(arr1[i,4],12)+put_val(arr1[i,5],12)+put_val(arr1[i,2]+arr1[i,3],12))
        for j := 2 to 5
          arr[j] += arr1[i,j]
        next
      next
      add_string(replicate("─",sh))
      add_string(" Итого:"+put_val(arr[2],12)+put_val(arr[3],12)+;
                           put_val(arr[4],12)+put_val(arr[5],12)+put_val(arr[2]+arr[3],12))
    endif
    if len(arr2) > 0
      if verify_FF(HH-2,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      afill(arr,0)
      add_string("")
      add_string(padc("дети",sh,"_"))
      for i := 1 to len(arr2)
        if verify_FF(HH,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(str(arr2[i,1],7)+put_val(arr2[i,2],12)+put_val(arr2[i,3],12)+;
                                    put_val(arr2[i,4],12)+put_val(arr2[i,5],12)+put_val(arr2[i,2]+arr2[i,3],12))
        for j := 2 to 5
          arr[j] += arr2[i,j]
        next
      next
      add_string(replicate("─",sh))
      add_string(" Итого:"+put_val(arr[2],12)+put_val(arr[3],12)+;
                           put_val(arr[4],12)+put_val(arr[5],12)+put_val(arr[2]+arr[3],12))
    endif
    fclose(fp)
    viewtext(name_file,,,,.t.,,,1)
  endif
  return NIL
  