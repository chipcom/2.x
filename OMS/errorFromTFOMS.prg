#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"
#include 'tbox.ch'

** 06.09.22 Редактирование случая с выбором по конкретной ошибке из ТФОМС
Function f3oms_edit()
  Static si := 1
  Local buf, str_sem, i, k, arr, old_yes_h_otd := yes_h_otd, iRefr, ret_arr, srec, buf24, buf_scr, s, mas_pmt
  local lek_pr := .f.


  if !myFileDeleted(cur_dir+"tmp_h"+sdbf)
    return NIL
  endif

  Private arr_m

  if (arr_m := year_month(T_ROW,T_COL+5,,3)) != NIL
    buf24 := save_maxrow()
    mywait()
    arr := {}
    dbcreate(cur_dir+"tmp_h",{{"kod","N",7,0},;
                              {"SREFREASON","C",12,0},;
                              {"REFREASON","N",3,0}})
    use (cur_dir+"tmp_h") new
    R_Use(dir_server+"mo_refr",,"REFR")
    index on str(kodz,8) to (cur_dir+"tmp_refr") for tipz == 1
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",dir_server+"humand","HUMAN")
    set relation to recno() into HUMAN_, to str(human->kod,8) into REFR

    // заполним временный файл БД видами полученных ошибок
    dbseek(dtos(arr_m[5]),.t.)
    do while human->k_data <= arr_m[6] .and. !eof()
      if human_->reestr == 0 .and. human_->REES_NUM > 0 .and. human->schet == 0
        s := 0 ; s1 := ""
        select REFR
        find (str(human->kod,8))
        do while human->kod == refr->kodz .and. !eof()
          s := refr->REFREASON // берём последнее значение
          s1 := refr->SREFREASON
          skip
        enddo
        if s > 0
          select TMP_H
          append blank
          replace kod with human->kod, REFREASON with s
          if (i := ascan(arr,{|x| x[2]==tmp_h->REFREASON})) == 0
            if empty(s := ret_t005(tmp_h->REFREASON))
              s := lstr(tmp_h->REFREASON)+" неизвестная причина отказа"
            endif
            aadd(arr, {s,tmp_h->REFREASON})
          endif
        elseif !empty(s1)
          select TMP_H
          append blank
          // replace kod with human->kod, REFREASON with -99, SREFREASON with s1
          replace kod with human->kod, REFREASON with 10, SREFREASON with s1  // чтобы обмануть выбор пациентов 20/02/21
          if (i := ascan(arr,{|x| x[2]==tmp_h->REFREASON})) == 0
            if len(aTokens := hb_ATokens( s1, '.' )) == 3 // ошибка по справочнику Q015
              s := alltrim(s1) + ' ' + getCategoryCheckErrorByID_Q017(aTokens[1])[1]
            else
              s := s1 + ' новая причина отказа'
            endif
            aadd(arr, {s,tmp_h->REFREASON})
          endif
        endif
      endif
      select HUMAN
      skip
    enddo
    if glob_mo[_MO_KOD_TFOMS] == '805965' //РДЛ
      adbf := {{"REFREASON","N",15,0},; 
           {"shifr_usl","C",10,0},;  // шифр услуги 
           {"name_usl","C",250,0},; // наименование услуги 
           {"NUMORDER","N",10,0},;   // Номер заявки(ORDER Number)
           {"fio","C",70,0},;
           {"date_r","C",10,0},;
           {"kol_usl","N",10,0},;    // кол-во услуг
           {"cena_1","N",11,2},;
           {"otd","C",42,0},;
           {"otd_kod","N",3,0},; 
           {"smo_kod","C",5,0}}
      dbcreate(cur_dir + fr_data + '2', adbf)
      use (cur_dir + fr_data + '2') new alias FRD2
      // база готова
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"human_2",,"HU2")
      R_Use(dir_server+"uslugi",,"USL")
      R_Use(dir_server+"human_u_",,"HU_")
      R_Use(dir_server+"human_u",dir_server+"human_u","HU")
      set relation to recno() into HU_, to u_kod into USL
      use_base("lusl")
      select tmp_h 
      go top
      do while !eof() 
        select hu
        find (str(tmp_h->kod,7))
        do while tmp_h->kod == hu->kod .and. !eof()
          select hu2
          goto tmp_h->kod
          select  frd2
          append blank
          frd2->REFREASON := tmp_h->refreason 
          frd2->shifr_usl := usl->shifr    // шифр услуги 
          frd2->name_usl  :=  usl->name // наименование услуги 
          select human
          goto tmp_h->kod
          select human_
          goto tmp_h->kod
          frd2->smo_kod   := human_->smo
          //
          musl := transform_shifr(frd2->shifr_usl)
          select lusl
          find(musl)
          frd2->name_usl := lusl->name
          //
          frd2->NUMORDER := hu2->pn3   // Номер заявки(ORDER Number)

          frd2->fio     := alltrim (human->fio )+" "+full_date(human->date_r)
          frd2->kol_usl := hu->kol_1     // кол-во услуг
          frd2->cena_1  := hu->stoim_1
          select otd
          goto human->otd
          frd2->otd    := alltrim(otd->NAME)
          frd2->otd_kod := human->otd
          select hu
          skip
        enddo
        select tmp_h 
        skip
      enddo 
    endif
    close databases
    rest_box(buf24)
    Private kod_REFREASON_menu
    if empty(arr)
      func_error(4,"Нет пациентов с ошибками из ТФОМС "+arr_m[4])
    elseif (iRefr := popup_2array(arr,T_ROW,T_COL+5,,,@ret_arr,"Выбор вида ошибки","B/BG",color0, 'errorOMSkey', ;
        '^<Esc>^ - отказ;  ^<Enter>^ - выбор; ^F2^ - дополнительное описание' )) > 0
      // в случае выбора ошибки 57 (ошибки в персональных данных) или 599 (неверный пол или дата рождения)
      if eq_any(iRefr,57,599) .and. (i := popup_prompt(T_ROW,T_COL+5,1,;
                       {"Редактирование листов учёта",;
                        "Создание файла ХОДАТАЙСТВА для отсылки в ТФОМС",;
                        "Оформление (печать) ХОДАТАЙСТВА (по старому)"},,,color5)) > 1
        return TFOMS_hodatajstvo(arr_m,iRefr,i-1)
      endif
      Private mr1 := T_ROW, regim_vyb := 2, p_del_error := ret_arr
      kod_REFREASON_menu := iRefr
      do while .t.
        R_Use(dir_server+"mo_otd",,"OTD")
        G_Use(dir_server+"human_",,"HUMAN_")
        R_Use(dir_server+"human",,"HUMAN")
        set relation to recno() into HUMAN_, to otd into OTD
        use (cur_dir+"tmp_h") new
        set relation to kod into HUMAN
        index on upper(human->fio) to (cur_dir+"tmp_h") for REFREASON==iRefr
        if srec == NIL
          go top
        else
          goto (srec)
        endif
        mkod := 0
        yes_h_otd := 2
        buf_scr := savescreen()
        box_shadow(maxrow()-3,2,maxrow()-1,77,color0)
        if Alpha_Browse(T_ROW,2,maxrow()-4,77,"f1ret_oms_human",color0,ret_arr[1],'B/BG',,;
                                       .t.,,"f21ret_oms_human","f2ret_oms_human",,;
                                       {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
          if (glob_perso := tmp_h->kod) == 0
            func_error(4,"Не найдено нужных записей!")
          elseif eq_any(human->ishod,88,89)
            func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
          else
            srec := tmp_h->(recno())
            mkod := glob_perso
            glob_kartotek := human->kod_k
            glob_k_fio := fio_plus_novor()
            glob_otd[1] := human->otd
            glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
            if len(glob_otd) == 2
              aadd(glob_otd,human_->usl_ok)
            else
              glob_otd[3] := human_->usl_ok
            endif
            k := ret_tip_lu()
            if len(glob_otd) == 3
              aadd(glob_otd,k)
            else
              glob_otd[4] := k
            endif
            glob_uch[1] := human->LPU
            glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
            fl_schet := (human->schet > 0)
          endif
        else
          restscreen(buf_scr)
          exit
        endif
        restscreen(buf_scr)
        close databases
        if mkod > 0
          lek_pr := check_oms_sluch_lek_pr(glob_perso)
          yes_h_otd := old_yes_h_otd
          if buf != NIL ; rest_box(buf) ; endif
          buf := box_shadow(0,41,3,77,color13)
          @ 1,42 say padc(glob_otd[2],35) color color14
          @ 2,42 say padc(glob_k_fio,35) color color8
          if lek_pr
            mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг", "Использованные ~лекарства"}
          else
            mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
          endif
          if glob_otd[3] == 4 .or. (glob_otd[4] > 0 .and. glob_otd[4] != TIP_LU_MED_REAB)
            si := 1
            asize(mas_pmt,1)
            keyboard chr(K_ENTER)
          endif
          do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
            si := i
            str_sem := "Редактирование человека "+lstr(glob_perso)
            if G_SLock(str_sem)
              if i == 1
                oms_sluch(glob_perso,glob_kartotek)
              elseif i == 2
                oms_usl_sluch(glob_perso,glob_kartotek)
              elseif i == 3
                oms_sluch_lek_pr(glob_perso,glob_kartotek)
              endif
              G_SUnLock(str_sem)
            else
              func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
              exit
            endif
          enddo
        endif
      enddo
    endif
    if buf != NIL ; rest_box(buf) ; endif
    yes_h_otd := old_yes_h_otd
    close databases
  endif
  return NIL
  
***** 25.05.21 получить ошибку ФФОМС в виде массива из файлов Q015 или Q016
function errorArrayFFOMS( error_code )
  local arr_error := {}

  if substr(error_code, 4, 1) == 'F' .and. substr(error_code, 6, 2) == '00'
    arr_error := getRuleCheckErrorByID_Q015(error_code)
  elseif substr(error_code, 4, 1) == 'K' .and. substr(error_code, 6, 2) == '00'
    arr_error := getRuleCheckErrorByID_Q016(error_code)
  endif
  return arr_error

***** 22.05.21 отображение полного описания ошибки
Function errorOMSkey(nkey, ind)
  Local ret := -1, oBox
	local color_say := 'N/W', color_get := 'W/N*'
  local arr := split(parr[ind])
  local error_code, opis := {}, arr_error, cond := .f.
  local begin_row := 2

  error_code := arr[1]

  if len(error_code) < 4
    perenos( opis, retArr_t005(val(error_code))[3], 56 )
  elseif (len(error_code) == 12) .and. (hb_TokenCount( error_code, '.') == 3)
    // if substr(error_code, 4, 1) == 'F' .and. substr(error_code, 6, 2) == '00'
    //   arr_error := getRuleCheckErrorByID_Q015(error_code)
    // elseif substr(error_code, 4, 1) == 'K' .and. substr(error_code, 6, 2) == '00'
    //   arr_error := getRuleCheckErrorByID_Q016(error_code)
    // endif
    arr_error := errorArrayFFOMS( error_code )
    perenos( opis, arr_error[6], 56 )
    if ! empty(arr_error[4])
      hb_AIns( opis, 1, 'Для: ' + arr_error[4], .t.)
      cond := .t.
    endif
    if ! empty(arr_error[5])
        hb_AIns( opis, iif(cond, 2, 1), 'Должно быть: ' + arr_error[5], .t.)
    endif
  else
    // дополнительной информации по ошибке нет
    return ret
  endif
  if nKey == K_F2
    oBox := NIL // уничтожим окно
    oBox := TBox():New( begin_row, 10, 3 + len(opis), 70 )
    oBox:Color := color_say + ',' + color_get
    oBox:Frame := BORDER_DOUBLE
    oBox:MessageLine := '^<любая клавиша>^ - выход'
    oBox:Save := .t.

    oBox:Caption := 'Описание ошибки - ' + error_code
    oBox:View()
    for i := 1 to len(opis)
      @ begin_row + i, 12 say opis[i]
    next
    inkey(0)

  //   ret := 0
  elseif nKey == K_F3
  //   ret := 0
  elseif nKey == K_SPACE
  //   ret := 1
  endif
  return ret
  