// mo_omsit.prg - информация по ОМС (правила, статистические формы)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static lcount_uch  := 1
Static lcount_otd  := 0
Static sect_nastr  := 'НАСТРОЙКА'
Static nastr_print := 'PRINT'
Static nastr_vvod  := 'VVOD'
Static nastr_diagn := 'DIAGN'
Static nastr_f12   := 'F12'
Static nastr_f57   := 'F57'

//
Function prover_rule()
Local i, k, hGauge, buf := save_maxrow(), arr_m, ;
      n_file := cur_dir() + 'ver_rule.txt', sh := 80, HH := 78, reg_print := 5, ;
      fl_exit := .f., taa[2], ab := {}, s, arr1, blk, jkart, jhuman, jerr, t1, t2, i1
if (arr_m := year_month()) == NIL
  return NIL
endif
mywait()
t1 := seconds()
// чтение правил в память
Private mbukva5 := "", marr5 := {}, len5
if !read_rule(D_RULE_N_PRINT)
  close databases
  rest_box(buf)
  return func_error(4,'Зайдите в режим "Настройка правил статистики"')
endif
len5 := len(mbukva5)
for i := 1 to len5
  aadd(marr5, {substr(mbukva5,i, 1), 0} )
next
Private fl_plus := !empty(yes_d_plus)
R_Use(dir_server + "human_",,"HUMAN_")
R_Use(dir_server + "human",dir_server + "humand","HUMAN")
set relation to recno() into HUMAN_
dbseek(dtos(arr_m[5]),.t.)
index on str(kod_k, 7)+dtos(k_data) to (cur_dir() + "tmp_h") ;
      while k_data <= arr_m[6] ;
      for kod > 0
//
status_key("^<Esc>^ - прервать поиск")
hGauge := GaugeNew(,,,"Поиск "+arr_m[4],.t.)
GaugeDisplay( hGauge )
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("Проверка на соответствие правилам статистики",sh))
add_string(center(arr_m[4],sh))
add_string("")
R_Use(dir_server + "kartotek",dir_server + "kartoten","KART")
go top
jkart := jhuman := jerr := 0
blk := {|| human_->USL_OK != 1 }  // режим лечения не "стационарно"
do while !eof()
  GaugeUpdate( hGauge, ++jkart/lastrec() )
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if f1_prover_rule(blk,ab)
    ++jhuman
    arr1 := verify_rule(ab,kart->pol)
    if len(arr1) > 0
      ++jerr
      verify_FF(HH-3,.t.,sh)
      add_string("")
      s := lstr(jerr)+". "
      add_string(s+alltrim(kart->fio)+" (пол: "+kart->pol+")")
      for i := 1 to len(arr1)
        verify_FF(HH,.t.,sh)
        k := len(s)
        for i1 := 1 to perenos(taa,arr1[i],sh-k)
          if i1 == 1
            add_string(space(k)+taa[i1])
          else
            add_string(padl(alltrim(taa[i1]),sh))
          endif
        next
      next
    endif
  endif
  @ maxrow(), 1 say lstr(jkart) color "W+/R"
  @ row(),col() say "/" color "W/R"
  @ row(),col() say lstr(jhuman) color "GR+/R"
  @ row(),col() say "/" color "W/R"
  @ row(),col() say lstr(jerr) color "G+/R"
  select KART
  if recno() % 5000 == 0
    Commit
  endif
  skip
enddo
close databases
CloseGauge(hGauge)
fclose(fp)
rest_box(buf)
t2 := seconds() - t1
//n_message({"","Время проверки - "+sectotime(t2)},, ;
//          color1,cDataCSay,,,color8)
if jerr == 0
  func_error(4,"Ошибок не обнаружено!")
else
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
return NIL


// 05.01.17
Function f1_prover_rule(blk_usl,ab,n_forma)
Static a_d_talon[16]
Local i, j, k, n, arr_d, lshifr, lta, lbukva, s, arr1, rec, lnum_kol, tip_travma := {}
DEFAULT n_forma TO 12
Private arr_all := {}
if len(ab) > 0
  asize(ab, 0)
endif
if tmp1rule->(lastrec()) > 0
  select TMP1RULE
  zap
endif
if tmp2rule->(lastrec()) > 0
  select TMP2RULE
  zap
endif
select HUMAN
find (str(kart->kod, 7))
do while kart->kod == human->kod_k .and. !eof()
  lnum_kol := 0
  if eval(blk_usl)
    rec := human->(recno())
    lta := {} ; lbukva := alltrim(human_->STATUS_ST)
    if eq_any(human->ishod, 101, 102, 201, 202, 203, 204, 205, 301, 302)
      if eq_any(human->ishod, 101, 102)
        arr := ret_f12_PN(human->kod, 1)
        lnum_kol := 9 // профосмотр
      elseif eq_any(human->ishod, 201, 202, 203, 204, 205)
        arr := ret_f12_DVN(human->kod, 2)
        lnum_kol := iif(human->ishod == 203, 9, 10) // профосмотр или диспансеризация
      elseif eq_any(human->ishod, 301, 302)
        arr := ret_f12_PN(human->kod, 2)
        lnum_kol := 9 // профосмотр
      endif
      if empty(arr)
        aadd(arr, {human->KOD_DIAG, 0, 0})
      endif
      for i := 1 to len(arr)
        if !empty(lshifr := alltrim(arr[i, 1]))
          if n_forma == 57 .and. eq_any(left(lshifr, 1),"V","W","X","Y")
            aadd(arr_all,padr(lshifr, 5))
          endif
          if (k := ascan(lta,{|x| x[1] == lshifr })) == 0
            aadd(lta, {lshifr, 0, 0, 0})
            k := len(lta)
          endif
          if lta[k, 2] == 0 .and. arr[i, 2] > 0
            lta[k, 2] := arr[i, 2]
          endif
          lta[k, 3] := arr[i, 3]
        endif
      next
    else
      arr_d := {human->KOD_DIAG , ;
                human->KOD_DIAG2, ;
                human->KOD_DIAG3, ;
                human->KOD_DIAG4, ;
                human->SOPUT_B1 , ;
                human->SOPUT_B2 , ;
                human->SOPUT_B3 , ;
                human->SOPUT_B4}
      for j := 1 to 8
        if !empty(lshifr := alltrim(arr_d[j]))
          if n_forma == 57 .and. eq_any(left(lshifr, 1),"V","W","X","Y")
            aadd(arr_all,padr(lshifr, 5))
          endif
          if (k := ascan(lta,{|x| x[1] == lshifr })) == 0
            aadd(lta, {lshifr, 0, 0, 0})
            k := len(lta)
          endif
          if lta[k, 2] == 0 .and. !empty(s := substr(human->diag_plus,j, 1))
            if s $ "+-"
              lta[k, 2] := if(s=="+", 1, 2)
            elseif fl_plus .and. s $ yes_d_plus .and. !(s $ lbukva)
              lbukva += s
            endif
          endif
          if emptyany(lta[k, 2],lta[k, 3],lta[k, 4])
            for i := 1 to 16
              a_d_talon[i] := int(val(substr(human_->DISPANS,i, 1)))
            next
            s := a_d_talon[j*2-1]   // характер заболевания
            if eq_any(s, 1, 2)
              lta[k, 2] := s
            endif
            s := a_d_talon[j*2]   // диспансеризация
            if between(s, 1, 3)
              lta[k, 3] := s
              if empty(lta[k, 2])  // если не определен характер заболевания,
                lta[k, 2] := s     // то определяем его принудительно
              endif
            endif
          endif
        endif
      next
      if n_forma == 57
        arr := {human_2->OSL1,human_2->OSL2,human_2->OSL3}
        for i := 1 to len(arr)
          if !empty(lshifr := alltrim(arr[i]))
            if eq_any(left(lshifr, 1),"V","W","X","Y")
              aadd(arr_all,padr(lshifr, 5))
            endif
          endif
        next
      endif
    endif
    if n_forma == 57 .and. empty(tip_travma := ret_f_57_wide()) //  если NIL, то по-старому из меню типа травмы
      tip_travma := {4}
      do case
        case human_->TRAVMA == 4 // {"Дорожно-транспортная пр-венная", 4}, ;
          aadd(tip_travma, 5)
        case human_->TRAVMA == 8 // {"Дор.трансп., не связанная с пр-вом", 8}, ;
          aadd(tip_travma, 5)
          aadd(tip_travma, 6)
        otherwise
          aadd(tip_travma, 7)
      endcase
    endif
    for i := 1 to len(lta)
      lshifr := lta[i, 1]
      // сначала для 5-тизначного шифра
      select TMP1RULE
      find ("1"+padr(lshifr, 5))
      if !found()
        append blank
        tmp1rule->kod   := recno()
        tmp1rule->tip   := 1
        tmp1rule->shifr := lshifr
        tmp1rule->dnum  := diag_to_num(lshifr, 1)
      endif
      select TMP2RULE
      append blank
      tmp2rule->kod    := tmp1rule->kod
      tmp2rule->n_data := human->n_data
      tmp2rule->k_data := human->k_data
      tmp2rule->harak  := lta[i, 2]
      if lta[i, 3] > 0
        tmp1rule->dispan := lta[i, 3]
        tmp2rule->dispan := lta[i, 3]
      endif
      tmp2rule->travma := arr2list(tip_travma)
      tmp2rule->bukva  := lbukva
      if lta[i, 2] == 1
        ++ tmp1rule->kol1
        if lnum_kol > 0
          tmp1rule->num_kol := lnum_kol
          tmp2rule->num_kol := lnum_kol
        endif
      elseif lta[i, 2] == 2
        ++ tmp1rule->kol2
      endif
    /*if !empty(right(lshifr, 1))  // а теперь для трехзначной подрубрики
        lshifr := padr(left(lshifr, 3), 5)
        select TMP1RULE
        find ("2"+lshifr)
        if !found()
          append blank
          tmp1rule->kod   := recno()
          tmp1rule->tip   := 2
          tmp1rule->shifr := lshifr
          tmp1rule->dnum  := diag_to_num(lshifr, 1)
        endif
        select TMP2RULE
        append blank
        tmp2rule->kod    := tmp1rule->kod
        tmp2rule->n_data := human->n_data
        tmp2rule->k_data := human->k_data
        tmp2rule->harak  := lta[i, 2]
        if lta[i, 3] > 0
          tmp1rule->dispan := lta[i, 3]
          tmp2rule->dispan := lta[i, 3]
        endif
        tmp2rule->travma := arr2list(tip_travma)
        tmp2rule->bukva  := lbukva
        if lta[i, 2] == 1
          ++ tmp1rule->kol1
        elseif lta[i, 2] == 2
          ++ tmp1rule->kol2
        endif
      endif*/
    next
    if !empty(lbukva)
      aadd(ab, {human->n_data, ;   // D_RULE_N_DATA
                human->k_data, ;   // D_RULE_K_DATA
                lbukva})          // D_RULE_BUKVA
    endif
  endif
  select HUMAN
  skip
enddo
if rec != NIL
  goto (rec)
endif
return (tmp1rule->(lastrec()) > 0)

//
Function st_rule_1()
Local arr, i, s, adbf, t_arr[BR_LEN], mtitle := rule_section[1]
adbf := {{"diag1","C", 5, 0}, ;
         {"diag2","C", 5, 0}, ;
         {"dni4", "N", 3, 0}, ;
         {"dni3", "N", 3, 0}}
dbcreate(cur_dir() + "tmp",adbf)
use (cur_dir() + "tmp") new alias TMP
index on diag1+diag2 to (cur_dir() + "tmp")
arr := GetIniSect( file_stat, rule_section[1] )
if empty(arr)
  if !dostup_stat
    use
    return func_error(4,"Данное правило не заполнено!")
  endif
else
  select TMP
  for i := 1 to len(arr)
    append blank
    tmp->diag1 := token(arr[i, 1],"-", 1)
    tmp->diag2 := token(arr[i, 1],"-", 2)
    tmp->dni4  := int(val(token(arr[i, 2],",", 1)))
    tmp->dni3  := int(val(token(arr[i, 2],",", 2)))
  next
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := T_COL-10
t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 35
t_arr[BR_OPEN] := {|| f1_rule_1(,,"open") }
t_arr[BR_SEMAPHORE] := mtitle
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitle
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_ARR_BROWSE] := {,,,,.t., 0}
t_arr[BR_COLUMN] := {{ " Коды;  с", {|| tmp->diag1 } }, ;
                     { "диагнозов; по", {|| tmp->diag2 } }, ;
                     { "Дни; 4", {|| tmp->dni4 } }, ;
                     { "Дни; 3", {|| tmp->dni3 } }}
t_arr[BR_EDIT] := {|nk,ob| f1_rule_1(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key(s_msg) }
go top
//help_code := H_stat_rule_1
edit_browse(t_arr)
//help_code := -1
if dostup_stat .and. f_Esc_Enter(1)
  arr := {}
  go top
  do while !eof()
    if !empty(tmp->diag1)
      s := alltrim(tmp->diag1)
      if !empty(tmp->diag2)
        s += "-"+alltrim(tmp->diag2)
      endif
      aadd(arr, {s,lstr(tmp->dni4)+","+lstr(tmp->dni3)} )
    endif
    skip
  enddo
  SetIniSect(file_stat, rule_section[1], arr)
  stat_msg("Запись завершена!") ; mybell(2,OK)
endif
close databases
return NIL

//
Function f1_rule_1(nKey,oBrow,regim)
Local ret := -1
Local buf, fl := .f., rec, rec1, k := 16, tmp_color
Local bg := {|o,k| get_MKB10(o,k,.t.) }
do case
  case regim == "open"
    ret := (lastrec() > 0)
  case regim == "edit"
    do case
      case nKey == K_F10
        f10_diagnoz()
      case nKey == K_F9
        rec := tmp->(recno())
        print_rule(1)
        select TMP
        goto (rec)
      case dostup_stat .and. (nKey == K_INS .or. (nKey == K_ENTER .and. !empty(tmp->diag1)))
        rec := tmp->(recno())
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+4,pc1,pr1+4,pc2,"N/N","W+/N")
        endif
        Private mdiag1, mdiag2, mdni4, mdni3, gl_area := {1, 0, 23, 79, 0}
        mdiag1 := if(nKey == K_INS, space(5), tmp->diag1)
        mdiag2 := if(nKey == K_INS, space(5), tmp->diag2)
        mdni4 := if(nKey == K_INS, 90, tmp->dni4)
        mdni3 := if(nKey == K_INS, 90, tmp->dni3)
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1, 21,pc2-1,, ;
                       if(nKey == K_INS,"Добавление","Редактирование"), ;
                       cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+3 say "Диагнозы: с" get mdiag1 pict "@!" ;
                    reader {|o|MyGetReader(o,bg)} valid val2_10diag()
        @ row(),col() say ", по" get mdiag2 pict "@!" ;
                    reader {|o|MyGetReader(o,bg)} valid val2_10diag()
        @ k+2,pc1+3 say "Частота заболевания в днях:"
        @ k+3,pc1+3 say "- по четырехзначной рубрике" get mdni4 pict "999"
        @ k+4,pc1+3 say "   - по трехзначной рубрике" get mdni3 pict "999"
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !emptyany(mdiag1,mdni4) .and. f_Esc_Enter(1)
          if nKey == K_INS
            fl_found := .t.
            append blank
            rec := tmp->(recno())
          endif
          tmp->diag1 := mdiag1
          tmp->diag2 := mdiag2
          tmp->dni4  := mdni4
          tmp->dni3  := mdni3
          UNLOCK
          COMMIT
          oBrow:goTop()
          goto (rec)
          ret := 0
        elseif nKey == K_INS .and. !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case dostup_stat .and. nKey == K_DEL .and. !empty(tmp->diag1) .and. f_Esc_Enter(2)
        DeleteRec()
        oBrow:goTop()
        ret := 0
        if eof()
          ret := 1
        endif
    endcase
endcase
return ret

//
Function st_rule_2()
Local arr, i, s, adbf, t_arr[BR_LEN], mtitle := rule_section[2]
adbf := {{"diag1","C", 5, 0}, ;
         {"diag2","C", 5, 0}}
dbcreate(cur_dir() + "tmp",adbf)
use (cur_dir() + "tmp") new alias TMP
index on diag1+diag2 to (cur_dir() + "tmp")
arr := GetIniSect( file_stat, rule_section[2] )
if empty(arr)
  if !dostup_stat
    use
    return func_error(4,"Данное правило не заполнено!")
  endif
else
  select TMP
  for i := 1 to len(arr)
    append blank
    tmp->diag1 := token(arr[i, 1],"-", 1)
    tmp->diag2 := token(arr[i, 1],"-", 2)
  next
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := T_COL-10
t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 35
t_arr[BR_OPEN] := {|| f1_rule_2(,,"open") }
t_arr[BR_SEMAPHORE] := mtitle
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitle
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_ARR_BROWSE] := {,,,,.t., 0}
t_arr[BR_COLUMN] := {{ " Коды;  с", {|| tmp->diag1 } }, ;
                     { "диагнозов; по", {|| tmp->diag2 } }}
t_arr[BR_EDIT] := {|nk,ob| f1_rule_2(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key(s_msg) }
go top
//help_code := H_stat_rule_2
edit_browse(t_arr)
//help_code := -1
if dostup_stat .and. f_Esc_Enter(1)
  arr := {} ; i := 0
  go top
  do while !eof()
    if !empty(tmp->diag1)
      s := alltrim(tmp->diag1)
      if !empty(tmp->diag2)
        s += "-"+alltrim(tmp->diag2)
      endif
      aadd(arr, {s,lstr(++i)} )
    endif
    skip
  enddo
  SetIniSect(file_stat, rule_section[2], arr)
  stat_msg("Запись завершена!") ; mybell(2,OK)
endif
close databases
return NIL

//
Function f1_rule_2(nKey,oBrow,regim)
Local ret := -1
Local buf, fl := .f., rec, rec1, k := 16, tmp_color
Local bg := {|o,k| get_MKB10(o,k,.t.) }
do case
  case regim == "open"
    ret := (lastrec() > 0)
  case regim == "edit"
    do case
      case nKey == K_F10
        f10_diagnoz()
      case nKey == K_F9
        rec := tmp->(recno())
        print_rule(2)
        select TMP
        goto (rec)
      case dostup_stat .and. (nKey == K_INS .or. (nKey == K_ENTER .and. !empty(tmp->diag1)))
        rec := tmp->(recno())
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+4,pc1,pr1+4,pc2,"N/N","W+/N")
        endif
        Private mdiag1, mdiag2, gl_area := {1, 0, 23, 79, 0}
        mdiag1 := if(nKey == K_INS, space(5), tmp->diag1)
        mdiag2 := if(nKey == K_INS, space(5), tmp->diag2)
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1, 21,pc2-1,, ;
                       if(nKey == K_INS,"Добавление","Редактирование"), ;
                       cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+3 say "Диагнозы: с" get mdiag1 pict "@!" ;
                    reader {|o|MyGetReader(o,bg)} valid val2_10diag()
        @ k+2,pc1+3 say "         по" get mdiag2 pict "@!" ;
                    reader {|o|MyGetReader(o,bg)} valid val2_10diag()
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !empty(mdiag1) .and. f_Esc_Enter(1)
          if nKey == K_INS
            fl_found := .t.
            append blank
            rec := tmp->(recno())
          endif
          tmp->diag1 := mdiag1
          tmp->diag2 := mdiag2
          UNLOCK
          COMMIT
          oBrow:goTop()
          goto (rec)
          ret := 0
        elseif nKey == K_INS .and. !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case dostup_stat .and. nKey == K_DEL .and. !empty(tmp->diag1) .and. f_Esc_Enter(2)
        DeleteRec()
        oBrow:goTop()
        ret := 0
        if eof()
          ret := 1
        endif
    endcase
endcase
return ret

//
Function st_rule_3()
Local arr, i, s, adbf, t_arr[BR_LEN], mtitle := rule_section[3]
adbf := {{"diag1","C", 5, 0}, ;
         {"diag2","C", 5, 0}, ;
         {"pol",  "C", 1, 0}}
dbcreate(cur_dir() + "tmp",adbf)
use (cur_dir() + "tmp") new alias TMP
index on diag1+diag2 to (cur_dir() + "tmp")
arr := GetIniSect( file_stat, rule_section[3] )
if empty(arr)
  if !dostup_stat
    use
    return func_error(4,"Данное правило не заполнено!")
  endif
else
  select TMP
  for i := 1 to len(arr)
    append blank
    tmp->diag1 := token(arr[i, 1],"-", 1)
    tmp->diag2 := token(arr[i, 1],"-", 2)
    tmp->pol   := arr[i, 2]
  next
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := T_COL-10
t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 35
t_arr[BR_OPEN] := {|| f1_rule_3(,,"open") }
t_arr[BR_SEMAPHORE] := mtitle
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitle
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_ARR_BROWSE] := {,,,,.t., 0}
t_arr[BR_COLUMN] := {{ " Коды;  с", {|| tmp->diag1 } }, ;
                     { "диагнозов; по", {|| tmp->diag2 } }, ;
                     { "Пол", {|| tmp->pol } }}
t_arr[BR_EDIT] := {|nk,ob| f1_rule_3(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key(s_msg) }
go top
//help_code := H_stat_rule_3
edit_browse(t_arr)
//help_code := -1
if dostup_stat .and. f_Esc_Enter(1)
  arr := {}
  go top
  do while !eof()
    if !empty(tmp->diag1)
      s := alltrim(tmp->diag1)
      if !empty(tmp->diag2)
        s += "-"+alltrim(tmp->diag2)
      endif
      aadd(arr, {s,tmp->pol} )
    endif
    skip
  enddo
  SetIniSect(file_stat, rule_section[3], arr)
  stat_msg("Запись завершена!") ; mybell(2,OK)
endif
close databases
return NIL

//
Function f1_rule_3(nKey,oBrow,regim)
Local ret := -1
Local buf, fl := .f., rec, rec1, k := 16, tmp_color
Local bg := {|o,k| get_MKB10(o,k,.t.) }
do case
  case regim == "open"
    ret := (lastrec() > 0)
  case regim == "edit"
    do case
      case nKey == K_F10
        f10_diagnoz()
      case nKey == K_F9
        rec := tmp->(recno())
        print_rule(3)
        select TMP
        goto (rec)
      case dostup_stat .and. (nKey == K_INS .or. (nKey == K_ENTER .and. !empty(tmp->diag1)))
        rec := tmp->(recno())
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+4,pc1,pr1+4,pc2,"N/N","W+/N")
        endif
        Private mdiag1, mdiag2, mpol, gl_area := {1, 0, 23, 79, 0}
        mdiag1 := if(nKey == K_INS, space(5), tmp->diag1)
        mdiag2 := if(nKey == K_INS, space(5), tmp->diag2)
        mpol := if(nKey == K_INS, "Ж", tmp->pol)
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1, 21,pc2-1,, ;
                       if(nKey == K_INS,"Добавление","Редактирование"), ;
                       cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+3 say "Диагнозы: с" get mdiag1 pict "@!" ;
                    reader {|o|MyGetReader(o,bg)} valid val2_10diag()
        @ k+2,pc1+3 say "         по" get mdiag2 pict "@!" ;
                    reader {|o|MyGetReader(o,bg)} valid val2_10diag()
        if mem_pol == 1
          @ k+3,pc1+3 say "Пол" get mpol reader {|x|menu_reader(x,menupol,A__MENUVERT,,,.f.)}
        else
          @ k+3,pc1+3 say "Пол" get mpol pict "@!" valid {|g| mpol $ "МЖ" }
        endif
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !emptyany(mdiag1,mpol) .and. f_Esc_Enter(1)
          if nKey == K_INS
            fl_found := .t.
            append blank
            rec := tmp->(recno())
          endif
          tmp->diag1 := mdiag1
          tmp->diag2 := mdiag2
          tmp->pol   := mpol
          UNLOCK
          COMMIT
          oBrow:goTop()
          goto (rec)
          ret := 0
        elseif nKey == K_INS .and. !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case dostup_stat .and. nKey == K_DEL .and. !empty(tmp->diag1) .and. f_Esc_Enter(2)
        DeleteRec()
        oBrow:goTop()
        ret := 0
        if eof()
          ret := 1
        endif
    endcase
endcase
return ret

//
Function st_rule_4()
Local arr, i, s, adbf, t_arr[BR_LEN], mtitle := rule_section[4]
adbf := {{"diag1","C", 5, 0}, ;
         {"diag2","C", 5, 0}}
dbcreate(cur_dir() + "tmp",adbf)
use (cur_dir() + "tmp") new alias TMP
index on diag1+diag2 to (cur_dir() + "tmp")
arr := GetIniSect( file_stat, rule_section[4] )
if empty(arr)
  if !dostup_stat
    use
    return func_error(4,"Данное правило не заполнено!")
  endif
else
  select TMP
  for i := 1 to len(arr)
    append blank
    tmp->diag1 := token(arr[i, 1],"-", 1)
    tmp->diag2 := token(arr[i, 1],"-", 2)
  next
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := T_COL-10
t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 35
t_arr[BR_OPEN] := {|| f1_rule_4(,,"open") }
t_arr[BR_SEMAPHORE] := mtitle
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitle
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_ARR_BROWSE] := {,,,,.t., 0}
t_arr[BR_COLUMN] := {{ " Коды;  с", {|| tmp->diag1 } }, ;
                     { "диагнозов; по", {|| tmp->diag2 } }}
t_arr[BR_EDIT] := {|nk,ob| f1_rule_4(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key(s_msg) }
go top
//help_code := H_stat_rule_4
edit_browse(t_arr)
//help_code := -1
if dostup_stat .and. f_Esc_Enter(1)
  arr := {} ; i := 0
  go top
  do while !eof()
    if !empty(tmp->diag1)
      s := alltrim(tmp->diag1)
      if !empty(tmp->diag2)
        s += "-"+alltrim(tmp->diag2)
      endif
      aadd(arr, {s,lstr(++i)} )
    endif
    skip
  enddo
  SetIniSect(file_stat, rule_section[4], arr)
  stat_msg("Запись завершена!") ; mybell(2,OK)
endif
close databases
return NIL

//
Function f1_rule_4(nKey,oBrow,regim)
Local ret := -1
Local buf, fl := .f., rec, rec1, k := 16, tmp_color
Local bg := {|o,k| get_MKB10(o,k,.t.) }
do case
  case regim == "open"
    ret := (lastrec() > 0)
  case regim == "edit"
    do case
      case nKey == K_F10
        f10_diagnoz()
      case nKey == K_F9
        rec := tmp->(recno())
        print_rule(4)
        select TMP
        goto (rec)
      case dostup_stat .and. (nKey == K_INS .or. (nKey == K_ENTER .and. !empty(tmp->diag1)))
        rec := tmp->(recno())
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+4,pc1,pr1+4,pc2,"N/N","W+/N")
        endif
        Private mdiag1, mdiag2, gl_area := {1, 0, 23, 79, 0}
        mdiag1 := if(nKey == K_INS, space(5), tmp->diag1)
        mdiag2 := if(nKey == K_INS, space(5), tmp->diag2)
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1, 21,pc2-1,, ;
                       if(nKey == K_INS,"Добавление","Редактирование"), ;
                       cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+3 say "Диагнозы: с" get mdiag1 pict "@!" ;
                    reader {|o|MyGetReader(o,bg)} valid val2_10diag()
        @ k+2,pc1+3 say "         по" get mdiag2 pict "@!" ;
                    reader {|o|MyGetReader(o,bg)} valid val2_10diag()
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !empty(mdiag1) .and. f_Esc_Enter(1)
          if nKey == K_INS
            fl_found := .t.
            append blank
            rec := tmp->(recno())
          endif
          tmp->diag1 := mdiag1
          tmp->diag2 := mdiag2
          UNLOCK
          COMMIT
          oBrow:goTop()
          goto (rec)
          ret := 0
        elseif nKey == K_INS .and. !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case dostup_stat .and. nKey == K_DEL .and. !empty(tmp->diag1) .and. f_Esc_Enter(2)
        DeleteRec()
        oBrow:goTop()
        ret := 0
        if eof()
          ret := 1
        endif
    endcase
endcase
return ret

//
Function st_rule_5()
Local i, s, arr, mbukva := ""
arr := GetIniSect( file_stat, rule_section[5] )
if empty(arr)
  if !dostup_stat
    use
    return func_error(4,"Данное правило не заполнено!")
  endif
else
  mbukva := arr[1, 2]
endif
mbukva := padr(mbukva, 5)
//help_code := H_stat_rule_5
if (mbukva := input_value(20, 10, 22, 69,color1, ;
                          "  Буквы, которые встречаются не более раза в году", ;
                          mbukva,"@!")) != NIL
  arr := {}
  if !empty(mbukva)
    arr := {{"bukva",mbukva}}
  endif
  SetIniSect(file_stat, rule_section[5], arr)
  stat_msg("Запись завершена!") ; mybell(2,OK)
endif
//help_code := -1
return NIL

//
Function st_rule_6()
Local arr, i, s, adbf, t_arr[BR_LEN], mtitle := rule_section[6]
adbf := {{"bukva1","C", 1, 0}, ;
         {"bukva2","C", 1, 0}, ;
         {"bukva", "C", 1, 0}}
dbcreate(cur_dir() + "tmp",adbf)
use (cur_dir() + "tmp") new alias TMP
index on bukva1+bukva2 to (cur_dir() + "tmp")
arr := GetIniSect( file_stat, rule_section[6] )
if empty(arr)
  if !dostup_stat
    use
    return func_error(4,"Данное правило не заполнено!")
  endif
else
  select TMP
  for i := 1 to len(arr)
    append blank
    tmp->bukva1 := token(arr[i, 1],"-", 1)
    tmp->bukva2 := token(arr[i, 1],"-", 2)
    tmp->bukva  := arr[i, 2]
  next
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := T_COL-10
t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 35
t_arr[BR_OPEN] := {|| f1_rule_6(,,"open") }
t_arr[BR_SEMAPHORE] := mtitle
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := mtitle
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_ARR_BROWSE] := {,,,,.t., 0}
t_arr[BR_COLUMN] := {{ "Первая;буква", {|| tmp->bukva1 } }, ;
                     { "Вторая;буква", {|| tmp->bukva2 } }, ;
                     { "Какую букву;оставить", {|| tmp->bukva } }}
t_arr[BR_EDIT] := {|nk,ob| f1_rule_6(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key(s_msg) }
go top
//help_code := H_stat_rule_6
edit_browse(t_arr)
//help_code := -1
if dostup_stat .and. f_Esc_Enter(1)
  arr := {}
  go top
  do while !eof()
    if !emptyall(tmp->bukva1,tmp->bukva2,tmp->bukva)
      s := tmp->bukva1+"-"+tmp->bukva2
      aadd(arr, {s,tmp->bukva} )
    endif
    skip
  enddo
  SetIniSect(file_stat, rule_section[6], arr)
  stat_msg("Запись завершена!") ; mybell(2,OK)
endif
close databases
return NIL

//
Function f1_rule_6(nKey,oBrow,regim)
Local ret := -1
Local buf, fl := .f., rec, rec1, k := 16, tmp_color
do case
  case regim == "open"
    ret := (lastrec() > 0)
  case regim == "edit"
    do case
      case nKey == K_F9
        rec := tmp->(recno())
        print_rule(6)
        select TMP
        goto (rec)
      case dostup_stat .and. (nKey == K_INS .or. (nKey == K_ENTER .and. !empty(tmp->bukva1)))
        rec := tmp->(recno())
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+4,pc1,pr1+4,pc2,"N/N","W+/N")
        endif
        Private mbukva1, mbukva2, mbukva, gl_area := {1, 0, 23, 79, 0}
        mbukva1 := if(nKey == K_INS, " ", tmp->bukva1)
        mbukva2 := if(nKey == K_INS, " ", tmp->bukva2)
        mbukva  := if(nKey == K_INS, " ", tmp->bukva)
        tmp_color := setcolor(cDataCScr)
        box_shadow(k,pc1+1, 21,pc2-1,, ;
                       if(nKey == K_INS,"Добавление","Редактирование"), ;
                       cDataPgDn)
        setcolor(cDataCGet)
        @ k+1,pc1+3 say "Первая буква" get mbukva1 pict "@!"
        @ k+2,pc1+3 say "Вторая буква" get mbukva2 pict "@!"
        @ k+4,pc1+3 say "Какая буква остается" get mbukva pict "@!"
        status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
        myread()
        if lastkey() != K_ESC .and. !emptyall(mbukva1,mbukva2,mbukva) .and. f_Esc_Enter(1)
          if nKey == K_INS
            fl_found := .t.
            append blank
            rec := tmp->(recno())
          endif
          tmp->bukva1 := mbukva1
          tmp->bukva2 := mbukva2
          tmp->bukva  := mbukva
          UNLOCK
          COMMIT
          oBrow:goTop()
          goto (rec)
          ret := 0
        elseif nKey == K_INS .and. !fl_found
          ret := 1
        endif
        setcolor(tmp_color)
        restore screen from buf
      case dostup_stat .and. nKey == K_DEL .and. !empty(tmp->bukva1) .and. f_Esc_Enter(2)
        DeleteRec()
        oBrow:goTop()
        ret := 0
        if eof()
          ret := 1
        endif
    endcase
endcase
return ret

//
Function print_rule(n)
Local sh := 80, HH := 58, reg_print := 2, ;
      s, n_file := cur_dir() + 'rule' + iif(prs == 1, 'KOM', 'LPU') + lstr(n) + stxt(), ;
      buf := save_maxrow()
//
mywait()
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(center({"Комитет по здравоохранению","ЛПУ"}[prs],sh))
add_string(center(expand("СТАТИСТИКА: ПРАВИЛО НОМЕР "+lstr(n)),sh))
add_string(center(rule_section[n],sh))
add_string("")
select TMP
go top
do while !eof()
  verify_FF(HH,.t.,sh)
  s := ""
  do case
    case n == 1
      if !empty(tmp->diag1)
        s := alltrim(tmp->diag1)
        if !empty(tmp->diag2)
          s += " - "+alltrim(tmp->diag2)
        endif
        s := padr(s, 15)
        if tmp->dni4 > 0
          s += "[ "+lstr(tmp->dni4)
          if tmp->dni3 > 0 .and. tmp->dni3 != tmp->dni4
            s += " ("+lstr(tmp->dni3)+")"
          endif
          s += " дней ]"
        endif
      endif
    case n == 2
      if !empty(tmp->diag1)
        s := alltrim(tmp->diag1)
        if !empty(tmp->diag2)
          s += " - "+alltrim(tmp->diag2)
        endif
      endif
    case n == 3
      if !empty(tmp->diag1)
        s := alltrim(tmp->diag1)
        if !empty(tmp->diag2)
          s += " - "+alltrim(tmp->diag2)
        endif
        s := padr(s, 15)+"пол: "+tmp->pol
      endif
    case n == 4
      if !empty(tmp->diag1)
        s := alltrim(tmp->diag1)
        if !empty(tmp->diag2)
          s += " - "+alltrim(tmp->diag2)
        endif
      endif
    case n == 5
      if !empty(tmp->bukva)
        s := tmp->bukva
      endif
    case n == 6
      if !emptyall(tmp->bukva1,tmp->bukva2,tmp->bukva)
        s := tmp->bukva1+"-"+tmp->bukva2+" ===> "+tmp->bukva
      endif
  endcase
  if !empty(s)
    add_string(s)
  endif
  select TMP
  skip
enddo
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,(sh>80),,,reg_print)
return NIL

//
Function get_nas_rule()
Local ar := GetIniSect( f_stat_lpu, sect_nastr ), ar2, i, j
if len(ar) == 0
  m1print := {11, 13}
endif
for i := 1 to len(ar)
  ar2 := {}
  for j := 1 to numtoken(ar[i, 2],",")
    aadd(ar2, int(val(token(ar[i, 2],",",j))) )
  next
  do case
    case ar[i, 1] == nastr_print
      m1print := ar2
    case ar[i, 1] == nastr_vvod
      m1vvod := ar2
    case ar[i, 1] == nastr_diagn
      m1diagn := ar2
    case ar[i, 1] == nastr_f12
      m1f12 := ar2
    case ar[i, 1] == nastr_f57
      m1f57 := ar2
  endcase
next
return NIL

//
Function a_nastr_rule()
Local arr := {{"КОМ-1", 11}, ;
              {"КОМ-2", 12}, ;
              {"КОМ-3", 13}, ;
              {"ЛПУ-1", 21}, ;
              {"ЛПУ-2", 22}, ;
              {"ЛПУ-3", 23}, ;
              {"ЛПУ-4", 24}}
if yes_bukva
  aadd(arr, {"ЛПУ-5", 25})
  aadd(arr, {"ЛПУ-6", 26})
endif
return arr

//
Function i_nastr_rule(ar)
Local sk := "КОМ: ", sl := "ЛПУ: ", flk := .f., fll := .f., i, s := ""
for i := 1 to len(ar)
  if ar[i] <= 20
    flk := .t.
    sk += right(lstr(ar[i]), 1)+","
  else
    fll := .t.
    sl += right(lstr(ar[i]), 1)+","
  endif
next
if flk
  s := left(sk, len(sk)-1)
  if fll
    s += "  "
  endif
endif
if fll
  s += left(sl, len(sl)-1)
endif
return iif(empty(s), "-= нет =-", s)

//
Function inp_nas_rule(k,r,c)
Local nr, i, s, r1, r2, ret, t_mas := {}, buf, buf1
nr := len(arr_name_rule)
for i := 1 to nr
  if ascan(k,arr_name_rule[i, 2]) > 0
    s := " * "
  else
    s := space(3)
  endif
  s += arr_name_rule[i, 1]
  aadd(t_mas, s)
next
r2 := r-1
r1 := r2 - nr - 1
buf := save_box(r1,c,r2+1,c+14)
buf1 := save_maxrow()
status_key("^<Esc>^ отказ; ^<Enter>^ выбор; ^<Ins,+,->^ смена признака включения данного правила")
if popup(r1,c,r2,c+12,t_mas,,color0,.t.,"fmenu_reader") > 0
  k := {}
  FOR i := 1 TO nr
    IF "*" == substr(t_mas[i], 2, 1)
      aadd(k,arr_name_rule[i, 2])
    ENDIF
  NEXT
  ret := {k,i_nastr_rule(k)}
endif
rest_box(buf)
rest_box(buf1)
return ret

//
Function nastr_rule()
Local buf := savescreen()
Local r1 := 12, c1 := 2, r2 := 22, c2 := 77, tmp_color, s, arr
Private arr_name_rule := a_nastr_rule()
box_shadow(r1,c1,r2,c2,color1,"Настройка работы с правилами статистики",color8)
Private mprint, m1print := {}, ;
        mvvod, m1vvod := {}, ;
        mdiagn, m1diagn := {}, ;
        mf12, m1f12 := {}, ;
        mf57, m1f57 := {}
get_nas_rule()
mprint := i_nastr_rule(m1print)
mvvod  := i_nastr_rule(m1vvod)
mdiagn := i_nastr_rule(m1diagn)
mf12   := i_nastr_rule(m1f12)
mf57   := i_nastr_rule(m1f57)
str_center(r1+2,"В каких режимах с какими правилами работаем:","G+/B")
tmp_color := setcolor(cDataCGet)
@ r1+4,c1+2 say "В режиме проверки                          " get mprint reader ;
     {|x| menu_reader(x,{{|k,r,c| inp_nas_rule(k,r,c)}},A__FUNCTION,,,.f.)}
@ r1+5,c1+2 say "При вводе листа учета    (пока не работает)" get mvvod  reader ;
     {|x| menu_reader(x,{{|k,r,c| inp_nas_rule(k,r,c)}},A__FUNCTION,,,.f.)}
@ r1+6,c1+2 say "В статистике по диагнозам(пока не работает)" get mdiagn reader ;
     {|x| menu_reader(x,{{|k,r,c| inp_nas_rule(k,r,c)}},A__FUNCTION,,,.f.)}
@ r1+7,c1+2 say "В статистической форме 12                  " get mf12   reader ;
     {|x| menu_reader(x,{{|k,r,c| inp_nas_rule(k,r,c)}},A__FUNCTION,,,.f.)}
@ r1+8,c1+2 say "В статистической форме 57                  " get mf57   reader ;
     {|x| menu_reader(x,{{|k,r,c| inp_nas_rule(k,r,c)}},A__FUNCTION,,,.f.)}
status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода;  ^<F1>^ - помощь")
//help_code := H_nastr_rule
myread()
//help_code := -1
if f_Esc_Enter(1)
  arr := {}
  s := ""
  aeval(m1print, {|x| s += lstr(x)+"," })
  aadd(arr, {nastr_print,left(s,len(s)-1)} )
  s := ""
  aeval(m1vvod, {|x| s += lstr(x)+"," })
  aadd(arr, {nastr_vvod,left(s,len(s)-1)} )
  s := ""
  aeval(m1diagn, {|x| s += lstr(x)+"," })
  aadd(arr, {nastr_diagn,left(s,len(s)-1)} )
  s := ""
  aeval(m1f12, {|x| s += lstr(x)+"," })
  aadd(arr, {nastr_f12,left(s,len(s)-1)} )
  s := ""
  aeval(m1f57, {|x| s += lstr(x)+"," })
  aadd(arr, {nastr_f57,left(s,len(s)-1)} )
  SetIniSect(f_stat_lpu, sect_nastr, arr)
endif
setcolor(tmp_color)
restscreen(buf)
return NIL

// 05.01.17
Function read_rule(regim)
Local sregim := ""
Local i, j, j1, s, arr, adbf, file_stat, val_stroke := " ", ret := .f.
Local ar_nastr := GetIniSect( f_stat_lpu, sect_nastr )
do case
  case regim == D_RULE_N_PRINT
    sregim := nastr_print
  case regim == D_RULE_N_VVOD
    sregim := nastr_vvod
  case regim == D_RULE_N_DIAGN
    sregim := nastr_diagn
  case regim == D_RULE_N_F12
    sregim := nastr_f12
  case regim == D_RULE_N_F57
    sregim := nastr_f57
endcase
for i := 1 to len(ar_nastr)
  if ar_nastr[i, 1] == sregim
    val_stroke := ar_nastr[i, 2]
    exit
  endif
next
adbf := {{"kod",   "N", 6, 0}, ;
         {"tip",   "N", 1, 0}, ;
         {"shifr", "C", 5, 0}, ;
         {"dnum",  "N", 6, 0}, ;
         {"dispan","N", 1, 0}, ;
         {"num_kol","N", 2, 0}, ;
         {"kol1",  "N", 6, 0}, ;
         {"kol2",  "N", 6, 0}}
dbcreate(cur_dir() + "tmp1rule",adbf)
use (cur_dir() + "tmp1rule") new
index on str(tip, 1)+shifr to (cur_dir() + "tmp1rule")
adbf := {{"kod",   "N", 6, 0}, ;
         {"n_data","D", 8, 0}, ;
         {"k_data","D", 8, 0}, ;
         {"harak", "N", 1, 0}, ;
         {"dispan","N", 1, 0}, ;
         {"travma","C", 20, 0}, ;
         {"num_kol","N", 2, 0}, ;
         {"bukva", "C", 15, 0}}
dbcreate(cur_dir() + "tmp2rule",adbf)
use (cur_dir() + "tmp2rule") new
index on str(kod, 6)+dtos(k_data) to (cur_dir() + "tmp2rule")
adbf := {{"rule",  "N", 1, 0}, ;
         {"tip",   "N", 1, 0}, ;
         {"diag1", "C", 5, 0}, ;
         {"diag2", "C", 5, 0}, ;
         {"dnum1", "N", 6, 0}, ;
         {"dnum2", "N", 6, 0}, ;
         {"bukva1","C", 1, 0}, ;
         {"bukva2","C", 1, 0}, ;
         {"bukva", "C", 5, 0}, ;
         {"pol",   "C", 1, 0}, ;
         {"num_kol","N", 2, 0}, ;
         {"dni4",  "N", 3, 0}, ;
         {"dni3",  "N", 3, 0}}
dbcreate(cur_dir() + "tmp_rule",adbf)
use (cur_dir() + "tmp_rule") new
for j1 := 1 to 2   // 1 - комитет, 2 - ЛПУ
  file_stat := {f_stat_com,f_stat_lpu}[j1]
  for j := 1 to 6    // номер правила
    s := lstr(j1)+lstr(j)
    if s $ val_stroke
      arr := GetIniSect( file_stat, rule_section[j] )
      if !empty(arr)
        for i := 1 to len(arr)
          ret := .t.
          append blank
          tmp_rule->rule := j  // номер правила
          tmp_rule->tip := j1  // 1 - комитет, 2 - ЛПУ
          if j < 5
            tmp_rule->diag1 := token(arr[i, 1],"-", 1)
            tmp_rule->diag2 := token(arr[i, 1],"-", 2)
            if empty(tmp_rule->diag2)
              tmp_rule->diag2 := tmp_rule->diag1
            endif
            if j == 1
              tmp_rule->dni4 := int(val(token(arr[i, 2],",", 1)))
              tmp_rule->dni3 := int(val(token(arr[i, 2],",", 2)))
            elseif j == 3
              tmp_rule->pol := upper(arr[i, 2])
            endif
            tmp_rule->dnum1 := diag_to_num(tmp_rule->diag1, 1)
            tmp_rule->dnum2 := diag_to_num(tmp_rule->diag2, 2)
          elseif j == 5
            mbukva5 := alltrim(arr[i, 2])
          elseif j == 6
            tmp_rule->bukva1 := token(arr[i, 1],"-", 1)
            tmp_rule->bukva2 := token(arr[i, 1],"-", 2)
            tmp_rule->bukva  := arr[i, 2]
          endif
        next
      endif
    endif
  next
next
index on str(rule, 1)+str(dnum2, 6) to (cur_dir() + "tmp_rule")
return ret

// для проверялки
Function verify_rule(arr_bukva,lpol)
Local i, j, k, ta := {}, lb := len(arr_bukva), s, ta3 := {}
// правило 1
select TMP_RULE
find ("1")
if found()  // т.е. работаем с правилами номер 1
  select TMP1RULE
  find ("1")
  do while tmp1rule->tip == 1 .and. !eof()
    select TMP_RULE
    dbseek("1"+str(tmp1rule->dnum, 6),.t.)
    if tmp_rule->rule == 1 .and. between(tmp1rule->dnum,tmp_rule->dnum1,tmp_rule->dnum2)
      // острое заболевание
      if tmp1rule->kol2 > 0  // указан характер ПОВТОРНОЕ
        aadd(ta, f1_ver_rule(tmp1rule->shifr,tmp_rule->tip, 1, 2))
      elseif tmp1rule->kol1 == 0  // не указан характер ПЕРВИЧНОЕ
        aadd(ta, f1_ver_rule(tmp1rule->shifr,tmp_rule->tip, 1, 1))
      elseif tmp1rule->kol1 > 1 ; // характер ПЕРВИЧНОЕ указан более 1 раза
                      .and. f2_ver_rule(tmp1rule->kod,tmp_rule->dni4)
        aadd(ta, f1_ver_rule(tmp1rule->shifr,tmp_rule->tip, 1, 4))
      else
      endif
    else // хроническое заболевание для пятизначного диагноза
      if tmp1rule->kol1+tmp1rule->kol2 > 1
        aadd(ta, f1_ver_rule(tmp1rule->shifr,tmp_rule->tip, 1, 3))
      endif
    endif
    select TMP1RULE
    skip
  enddo
  //
  select TMP1RULE
  find ("2")
  do while tmp1rule->tip == 2 .and. !eof()
    select TMP_RULE
    dbseek("1"+str(tmp1rule->dnum, 6),.t.)
    if tmp_rule->rule == 1 .and. between(tmp1rule->dnum,tmp_rule->dnum1,tmp_rule->dnum2)
      // острое заболевание
      if tmp1rule->kol1 > 1 ; // характер ПЕРВИЧНОЕ указан более 1 раза
                      .and. tmp_rule->dni3 > 0 .and. f2_ver_rule(tmp1rule->kod,tmp_rule->dni3)
        aadd(ta, f1_ver_rule(tmp1rule->shifr,tmp_rule->tip, 1, 4))
      else
        //
      endif
    else // хроническое заболевание для трехзначного диагноза
      if tmp1rule->kol1+tmp1rule->kol2 > 1
        aadd(ta, f1_ver_rule(tmp1rule->shifr,tmp_rule->tip, 1, 3))
      endif
    endif
    select TMP1RULE
    skip
  enddo
endif
// правило 2
* пока нет такого правила
// правило 3
select TMP1RULE
find ("1")
do while tmp1rule->tip == 1 .and. !eof()
  select TMP_RULE
  dbseek("3"+str(tmp1rule->dnum, 6),.t.)
  if tmp_rule->rule == 3 .and. !(tmp_rule->pol == lpol) ;
                         .and. between(tmp1rule->dnum,tmp_rule->dnum1,tmp_rule->dnum2)
    aadd(ta, f1_ver_rule(tmp1rule->shifr,tmp_rule->tip, 3))
  endif
  select TMP1RULE
  skip
enddo
// правило 4
select TMP1RULE
find ("1")
do while tmp1rule->tip == 1 .and. !eof()
  select TMP_RULE
  dbseek("4"+str(tmp1rule->dnum, 6),.t.)
  if tmp_rule->rule == 4 .and. between(tmp1rule->dnum,tmp_rule->dnum1,tmp_rule->dnum2)
    aadd(ta, f1_ver_rule(tmp1rule->shifr,tmp_rule->tip, 4))
  endif
  select TMP1RULE
  skip
enddo
// правило 5
if len5 > 0 .and. lb > 0
  fl := .f.
  // обнулим второй элемент
  for i := 1 to len5
    marr5[i, 2] := 0
  next
  for i := 1 to lb
    for j := 1 to len(arr_bukva[i,D_RULE_BUKVA])
      if (k := at(substr(arr_bukva[i,D_RULE_BUKVA],j, 1),mbukva5)) > 0
        ++ marr5[k, 2]
        if marr5[k, 2] > 1
          fl := .t.
        endif
      endif
    next
  next
  if fl
    for k := 1 to len5
      if marr5[k, 2] > 1
        s := 'Повторение буквы "'+marr5[k, 1]+'"'
        for i := 1 to lb
          for j := 1 to len(arr_bukva[i,D_RULE_BUKVA])
            if substr(arr_bukva[i,D_RULE_BUKVA],j, 1) == marr5[k, 1]
              s += ", "+left(dtoc(arr_bukva[i,D_RULE_N_DATA]), 5)+"-";
                       +left(dtoc(arr_bukva[i,D_RULE_K_DATA]), 5)
            endif
          next
        next
        aadd(ta, f1_ver_rule(s, 2, 5))
      endif
    next
  endif
endif
// правило 6
select TMP_RULE
find ("6")
do while tmp_rule->rule == 6 .and. !eof()
  if ascan(arr_bukva, {|x| tmp_rule->bukva1 $ x[D_RULE_BUKVA]}) > 0 .and. ;
     ascan(arr_bukva, {|x| tmp_rule->bukva2 $ x[D_RULE_BUKVA]}) > 0
    s := 'Сочетание букв "'+tmp_rule->bukva1+'" и "'+tmp_rule->bukva2+'"'
    for i := 1 to lb
      for j := 1 to len(arr_bukva[i,D_RULE_BUKVA])
        if substr(arr_bukva[i,D_RULE_BUKVA],j, 1) == tmp_rule->bukva1
          s += ', "'+tmp_rule->bukva1+'": '+;
               left(dtoc(arr_bukva[i,D_RULE_N_DATA]), 5)+"-";
              +left(dtoc(arr_bukva[i,D_RULE_K_DATA]), 5)
        endif
        if substr(arr_bukva[i,D_RULE_BUKVA],j, 1) == tmp_rule->bukva2
          s += ', "'+tmp_rule->bukva2+'": '+;
               left(dtoc(arr_bukva[i,D_RULE_N_DATA]), 5)+"-";
              +left(dtoc(arr_bukva[i,D_RULE_K_DATA]), 5)
        endif
      next
    next
    s += ', должно быть "'+alltrim(tmp_rule->bukva)+'"'
    aadd(ta, f1_ver_rule(s, 2, 6))
  endif
  skip
enddo
return ta

//
Function f1_ver_rule(_a,_n,_p,_p2)
Local i, s := " [правило "+iif(_n==1,"КОМ","ЛПУ")+"-"+lstr(_p)+"]", ;
      fl_date := .f., blk := {|| .t. }
do case
  case _p == 1
    do case
      case _p2 == 1
        s := _a+s+" Для острого заболевания не указан характер ПЕРВИЧНОЕ"
        fl_date := .t.
      case _p2 == 2
        s := _a+s+" Для острого заболевания указан характер ПОВТОРНОЕ"
        blk := {|x| x == 2 }
        fl_date := .t.
      case _p2 == 3
        s := _a+s+" Для хронического заболевания несколько раз указан характер"
        blk := {|x| x > 0 }
        fl_date := .t.
      case _p2 == 4
        s := _a+s+" Слишком часто указан характер ПЕРВИЧНОЕ"
        blk := {|x| x == 1 }
        fl_date := .t.
    endcase
  case _p == 2
    //
  case equalany(_p, 3, 4)
    s := _a+s
    fl_date := .t.
  case _p == 5
    s := _a+s
  case _p == 6
    s := _a+s
endcase
if fl_date
  select TMP2RULE
  find (str(tmp1rule->kod, 6))
  do while tmp2rule->kod == tmp1rule->kod .and. !eof()
    if eval(blk,tmp2rule->harak)
      s += ", "+left(dtoc(tmp2rule->n_data), 5)+"-";
               +left(dtoc(tmp2rule->k_data), 5)
    endif
    select TMP2RULE
    skip
  enddo
endif
return s

// Слишком часто указан характер ПЕРВИЧНОЕ - проверялка
Function f2_ver_rule(_a,_dni)
Static sdate
Local i, mdate1, mdate2, ret := .f.
DEFAULT sdate TO stod("19000101")
mdate1 := sdate
select TMP2RULE
find (str(tmp1rule->kod, 6))
do while tmp2rule->kod == tmp1rule->kod .and. !eof()
  if tmp2rule->harak == 1
    mdate2 := tmp2rule->n_data
    if mdate2 - mdate1 < _dni
      ret := .t. ; exit
    endif
    mdate1 := tmp2rule->k_data
  endif
  select TMP2RULE
  skip
enddo
return ret

// Слишком часто указан характер ПЕРВИЧНОЕ - исправлялка
Function f3_ver_rule(_a,_dni)
Static sdate
Local i, k := 0, mdate1, mdate2
DEFAULT sdate TO stod("19000101")
mdate1 := sdate
select TMP2RULE
find (str(tmp1rule->kod, 6))
do while tmp2rule->kod == tmp1rule->kod .and. !eof()
  if tmp2rule->harak == 1
    ++k
    mdate2 := tmp2rule->n_data
    if mdate2 - mdate1 < _dni
      --k
    endif
    mdate1 := tmp2rule->k_data
  endif
  select TMP2RULE
  skip
enddo
return k

//
Static Function ret_f_rule(lshifr)
Local ret := {}, i, j, d, r
d := diag_to_num(lshifr, 1)
for i := 1 to len_diag
  r := diag1[i, 2]
  for j := 1 to len(r)
    if between(d,r[j, 1],r[j, 2])
      aadd(ret, {diag1[i, 1],diag1[i, 2]})
      exit
    endif
  next
next
if len(ret) == 0 ; ret := NIL ; endif
return ret

// 14.10.24
Function diag0statist()
Static sz := 1
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., sh, HH := 77, reg_print, speriod, fl, ;
      arr_title, name_file := 's_diagn0.txt', fl_itogo := .f., ;
      jh := 0, arr_m, name_gr, j_1 := 0, j_2 := 0, a_otd := {}
Local mas_pmt := {"по ~всем диагнозам (заболеваниям)", ;
                  "по ~основному заболеванию"}
Private is_talon := .t., adiag_talon[16], md_bukva := {}, ;
        i_lu := 0, i_human := 0, id_plus, fl_z := .f., ;
        s_lu := 0, s_human := 0, sd_plus, ;
        s_dispan := "Диспансер", fl_plus := .f., md_plus := {}, k_plus
if (j := popup_prompt(T_ROW,T_COL-5,sz,mas_pmt)) == 0
  return NIL
endif
sz := j
if (arr_m := year_month()) == NIL
  return NIL
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  return NIL
endif
if len(st_a_uch) == 1
  glob_uch := st_a_uch[1]
  if (st_a_otd := inputN_otd(T_ROW,T_COL-5,.f.,.f.,glob_uch,@lcount_otd)) == NIL
    return NIL
  endif
  aeval(st_a_otd, {|x| aadd(a_otd,x[1]) })
else
  R_Use(dir_server + "mo_otd",,"OTD")
  go top
  do while !eof()
    if f_is_uch(st_a_uch,otd->kod_lpu)
      aadd(a_otd, otd->(recno()))
    endif
    skip
  enddo
  otd->(dbCloseArea())
endif
if is_talon
  aadd(md_plus,"+")
  aadd(md_plus,"-")
  aadd(md_plus,s_dispan)
endif
k_plus := len(md_plus)
if (fl_plus := (k_plus > 0))
  sd_plus := array(k_plus)
  afill(sd_plus, 0)
  id_plus := array(k_plus)
  afill(id_plus, 0)
endif
speriod := arr_m[4]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
arr := {;
   {"SHIFR",      "C",      5,      0}, ;  // диагноз
   {"SHIFR2",     "C",      5,      0}, ;  // диагноз
   {"TIP",        "N",      1,      0}, ;  // 0 - 3
   {"KOL",        "N",      6,      0};   // кол-во диагнозов
  }
if fl_plus
  for i := 1 to k_plus
    aadd(arr, {"KOL"+lstr(i),"N", 6, 0} )
  next
endif
dbcreate(cur_dir() + "tmp", arr)
use (cur_dir() + "tmp") new
index on shifr+str(tip, 1) to (cur_dir() + "tmp")
dbcreate(cur_dir() + "tmp_k", {{"kod","N", 7, 0}, ;
                           {"kol","N", 6, 0}})
use (cur_dir() + "tmp_k") new
index on str(kod, 7) to (cur_dir() + "tmp_k")
dbcreate(cur_dir() + "tmp_i", {{"kod","N", 7, 0}, ;
                           {"kol","N", 6, 0}})
use (cur_dir() + "tmp_i") new
index on str(kod, 7) to (cur_dir() + "tmp_i")
arr := {{"kod","N", 7, 0}, ;
        {"shifr","C", 5, 0}, ;
        {"tip","N", 1, 0}, ;
        {"kol","N", 6, 0}}
dbcreate(cur_dir() + "tmp_b",arr)
use (cur_dir() + "tmp_b") new
index on shifr+str(tip, 1)+str(kod, 7) to (cur_dir() + "tmp_b")
f1_diag_statist_bukva()
name_pgr := dir_exe() + "_mo_mkbg"
name_gr := dir_exe() + "_mo_mkbk"
R_Use(name_pgr,,"PGR")
index on sh_e to (cur_dir() + "tmp_pgr")
R_Use(name_gr,,"GR")
index on sh_e to (cur_dir() + "tmp_gr")
if pi1 == 1  // по дате окончания лечения
  begin_date := arr_m[5]
  end_date := arr_m[6]
  R_Use(dir_server + "human_",,"HUMAN_")
  R_Use(dir_server + "human",dir_server + "humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(begin_date),.t.)
  do while human->k_data <= end_date .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if func_pi_schet() .and. ascan(a_otd,human->otd) > 0
      @ 24, 1 say lstr(++jh) color cColorSt2Msg
      f1diag0statist(sz)
    endif
    select HUMAN
    skip
  enddo
else
  begin_date := arr_m[7]
  end_date := arr_m[8]
  R_Use(dir_server + "human_",,"HUMAN_")
  R_Use(dir_server + "human",dir_server + "humans","HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server + "schet_",,"SCHET_")
  R_Use(dir_server + "schet",dir_server + "schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  dbseek(begin_date,.t.)
  do while schet->pdate <= end_date .and. !eof()
    select HUMAN
    find (str(schet->kod, 6))
    do while human->schet == schet->kod
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if ascan(a_otd,human->otd) > 0
        @ 24, 1 say lstr(++jh) color cColorSt2Msg
        f1diag0statist(sz)
      endif
      select HUMAN
      skip
    enddo
    select SCHET
    skip
  enddo
endif
j := tmp->(lastrec())
i_human := tmp_i->(lastrec())
s_human := tmp_k->(lastrec())
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  reg_print := 5 ; w1 := 47
  arr_title := {;
    "─────────────────────────────────────────────────────┬──────┬──────", ;
    "                                                     │ Боль-│ Слу- ", ;
    "                    Д и а г н о з                    │ ных  │ чаев ", ;
    "─────────────────────────────────────────────────────┴──────┴──────"}
  if fl_plus
    for i := 1 to k_plus
      if md_plus[i] == s_dispan
        s1 := substr(s_dispan, 1, 5)
        s2 := substr(s_dispan, 6)
      else
        s1 := ""
        s2 := '"'+md_plus[i]+'"'
      endif
      arr_title[1] += '╥─────'
      arr_title[2] += '║'+padc(s1, 5)
      arr_title[3] += '║'+padc(s2, 5)
      arr_title[4] += '╨─────'
    next
  endif
  if (sh := len(arr_title[1])) > 85
    reg_print := 6
  endif
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("Статистика по диагнозам",sh))
  titleN_uch(st_a_uch,sh,lcount_uch)
  if len(st_a_uch) == 1
    titleN_otd(st_a_otd,sh,lcount_otd)
  endif
  add_string("")
  add_string(center(speriod,sh))
  add_string("")
  if pi1 == 1
    add_string(center(str_pi_schet(),sh))
  else
    add_string(center("[ по дате выписки счета ]",sh))
  endif
  if sz == 2
    add_string(center("{ по основному заболеванияю }",sh))
  endif
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  //
  R_Use(name_pgr,,"PGR")
  index on sh_b to (cur_dir() + "tmp_pgr")
  R_Use(name_gr,,"GR")
  index on sh_b to (cur_dir() + "tmp_gr")
  R_Use(dir_exe() + "_mo_mkb",cur_dir() + "_mo_mkb","MKB10")
  use (cur_dir() + "tmp_b") index (cur_dir() + "tmp_b") new
  use (cur_dir() + "tmp") index (cur_dir() + "tmp") new
  go top
  do while !eof()
    s := ""
    if tmp->tip == 0
      select GR
      find (left(tmp->shifr, 3))
      if (fl := found())
        do while gr->sh_b == left(tmp->shifr, 3) .and. !eof()
          s += alltrim(gr->name)+" "
          skip
        enddo
      endif
      k := perenos(arr,s,w1-2)
      s := left(tmp->shifr, 3)+"-"+left(tmp->shifr2, 3)+" "+padr(arr[1],w1-2)
      sk := 8
    elseif tmp->tip == 1
      select PGR
      find (left(tmp->shifr, 3))
      if (fl := found())
        do while pgr->sh_b == left(tmp->shifr, 3) .and. !eof()
          s += alltrim(pgr->name)+" "
          skip
        enddo
      endif
      k := perenos(arr,s,w1-4)
      s := "  "+left(tmp->shifr, 3)+"-"+left(tmp->shifr2, 3)+" "+padr(arr[1],w1-4)
      sk := 10
    else
      select MKB10
      find (tmp->shifr)
      s := alltrim(mkb10->name)+" "
      skip
      do while left(mkb10->shifr, 5) == tmp->shifr .and. mkb10->ks > 0 ;
                                                  .and. !eof()
        s += alltrim(mkb10->name)+" "
        skip
      enddo
      if tmp->tip == 2
        k := perenos(arr,s,w1-2)
        s := space(4)+left(tmp->shifr, 3)+" "+padr(arr[1],w1-2)
        sk := 8
      else
        k := perenos(arr,s,w1-6)
        s := space(6)+tmp->shifr+" "+padr(arr[1],w1-6)
        sk := 12
      endif
    endif
    if left(ltrim(s), 1) == "Z" .and. !fl_itogo
      add_string(replicate("─",sh))
      si := padl("Итого: ",w1+6)+str(i_human, 7)+str(i_lu, 7)
      if fl_plus
        for i := 1 to k_plus
          si += str(id_plus[i], 6)
        next
      endif
      add_string(si)
      add_string(replicate("─",sh))
      fl_itogo := .t.
    endif
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    j := 0
    select TMP_B
    find (tmp->shifr+str(tmp->tip, 1))
    dbeval({|| ++j },,{|| tmp_b->shifr==tmp->shifr .and. tmp_b->tip==tmp->tip })
    s += str(j, 7)
    s += str(tmp->kol, 7)
    for i := 1 to k_plus
      pole := "tmp->kol"+lstr(i)
      s += put_val(&pole, 6)
    next
    add_string(s)
    for i := 2 to k
      add_string(space(sk)+arr[i])
    next
    select TMP
    skip
  enddo
  if fl_z
    add_string(replicate("─",sh))
    si := padl("Всего: ",w1+6)+str(s_human, 7)+str(s_lu, 7)
    if fl_plus
      for i := 1 to k_plus
        si += str(sd_plus[i], 6)
      next
    endif
    add_string(si)
  endif
  f3_diag_statist_bukva(HH,sh,arr_title)
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

//
Function f1diag0statist(sz)
Local arr_d1 := {}, arr_d2 := {}, arr_d3 := {}, arr_d4 := {}
Local arr, i, j, mshifr, ar, pshifr, s, pole, fl_i, all_i := .f.
f2_diag_statist_bukva()
afill(adiag_talon, 0)
for i := 1 to 16
  adiag_talon[i] := int(val(substr(human_->DISPANS,i, 1)))
next
arr := diag_to_array(,,,.f.)
if sz == 2
  asize(arr, 1)
endif
for i := 1 to len(arr)
  if !empty(arr[i])
    if left(arr[i], 1) == "Z"
      fl_z := .t.  // private - переменная
    else
      all_i := .t.  // не только "Z" у данного больного
    endif
  endif
next
for i := 1 to len(arr)
  mshifr := padr(arr[i], 5)
  if empty(mshifr)
    loop
  endif
  fl_i := !(left(arr[i], 1) == "Z")
  ar := {}
  if "." $ mshifr  // 4-х/значный шифр
    select TMP
    find (mshifr+"3")
    if !found()
      append blank
      tmp->shifr := mshifr
      tmp->tip := 3
    endif
    if ascan(arr_d1, mshifr) == 0
      aadd(arr_d1, mshifr)
      tmp->kol ++
    endif
    aadd( ar, tmp->(recno()) )
  endif
  //
  pshifr := padr(left(mshifr, 3), 5)
  select TMP
  find (pshifr+"2")
  if !found()
    append blank
    tmp->shifr := pshifr
    tmp->tip := 2
  endif
  if ascan(arr_d2, pshifr) == 0
    aadd(arr_d2, pshifr)
    tmp->kol ++
  endif
  aadd( ar, tmp->(recno()) )
  //
  pshifr := left(pshifr, 3)
  select PGR
  dbseek(pshifr,.t.)
  select TMP
  find (pgr->sh_b+"  1")
  if !found()
    append blank
    tmp->shifr := pgr->sh_b
    tmp->shifr2 := pgr->sh_e
    tmp->tip := 1
  endif
  pshifr := padr(pgr->sh_b, 5)
  if ascan(arr_d3, pshifr) == 0
    aadd(arr_d3, pshifr)
    tmp->kol ++
  endif
  aadd( ar, tmp->(recno()) )
  //
  select GR
  dbseek(pshifr,.t.)
  select TMP
  find (gr->sh_b+"  0")
  if !found()
    append blank
    tmp->shifr := gr->sh_b
    tmp->shifr2 := gr->sh_e
    tmp->tip := 0
  endif
  pshifr := padr(gr->sh_b, 5)
  if ascan(arr_d4, pshifr) == 0
    aadd(arr_d4, pshifr)
    tmp->kol ++
  endif
  aadd( ar, tmp->(recno()) )
  //
  s := substr(human->diag_plus,i, 1)
  if fl_plus .and. !empty(s) .and. (j := ascan(md_plus, s)) > 0
    sd_plus[j] ++
    if fl_i
      id_plus[j] ++
    endif
    pole := "tmp->kol"+lstr(j)
    for j := 1 to len(ar)
      tmp->(dbGoto(ar[j]))
      &pole := &pole+1
    next
  endif
  if !eq_any(s,"+","-")
    s := adiag_talon[i*2-1]
    if eq_any(s, 1, 2)
      s := iif(s == 1, "+", "-")
      if (j := ascan(md_plus, s)) > 0
        sd_plus[j] ++
        if fl_i
          id_plus[j] ++
        endif
        pole := "tmp->kol"+lstr(j)
        for j := 1 to len(ar)
          tmp->(dbGoto(ar[j]))
          &pole := &pole+1
        next
      endif
    endif
  endif
  if eq_any(adiag_talon[i*2], 1, 2) .and. (j := ascan(md_plus, s_dispan)) > 0
    sd_plus[j] ++
    if fl_i
      id_plus[j] ++
    endif
    pole := "tmp->kol"+lstr(j)
    for j := 1 to len(ar)
      tmp->(dbGoto(ar[j]))
      &pole := &pole+1
    next
  endif
next
if len(arr_d1) > 0 .or. len(arr_d2) > 0
  ++s_lu
  select TMP_K
  find (str(human->kod_k, 7))
  if !found()
    append blank
    tmp_k->kod := human->kod_k
  endif
  tmp_k->kol ++
  if all_i
    ++i_lu
    select TMP_I
    find (str(human->kod_k, 7))
    if !found()
      append blank
      tmp_i->kod := human->kod_k
    endif
    tmp_i->kol ++
  endif
endif
for j := 1 to len(arr_d1)
  select TMP_B
  find (arr_d1[j]+"3"+str(human->kod_k, 7))
  if !found()
    append blank
    tmp_b->shifr := arr_d1[j]
    tmp_b->tip := 3
    tmp_b->kod := human->kod_k
    if tmp_b->(lastrec()) % 5000 == 0
      Commit
    endif
  endif
  tmp_b->kol ++
next
for j := 1 to len(arr_d2)
  select TMP_B
  find (arr_d2[j]+"2"+str(human->kod_k, 7))
  if !found()
    append blank
    tmp_b->shifr := arr_d2[j]
    tmp_b->tip := 2
    tmp_b->kod := human->kod_k
    if tmp_b->(lastrec()) % 5000 == 0
      Commit
    endif
  endif
  tmp_b->kol ++
next
for j := 1 to len(arr_d3)
  select TMP_B
  find (arr_d3[j]+"1"+str(human->kod_k, 7))
  if !found()
    append blank
    tmp_b->shifr := arr_d3[j]
    tmp_b->tip := 1
    tmp_b->kod := human->kod_k
    if tmp_b->(lastrec()) % 5000 == 0
      Commit
    endif
  endif
  tmp_b->kol ++
next
for j := 1 to len(arr_d4)
  select TMP_B
  find (arr_d4[j]+"0"+str(human->kod_k, 7))
  if !found()
    append blank
    tmp_b->shifr := arr_d4[j]
    tmp_b->tip := 0
    tmp_b->kod := human->kod_k
    if tmp_b->(lastrec()) % 5000 == 0
      Commit
    endif
  endif
  tmp_b->kol ++
next
return NIL

// 14.10.24
Function diag_statist(reg)
Static sz := 1
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., sh, HH := 77, reg_print, speriod, fl, ;
      arr_title, name_file := 's_diagn.txt', fl_itogo := .f., ;
      jh := 0, arr_m, name_gr, j_1 := 0, j_2 := 0, a_otd := {}
Local mas_pmt := {"по ~всем диагнозам (заболеваниям)", ;
                  "по ~основному заболеванию"}
Private is_talon := .t., adiag_talon[16], md_bukva := {}, ;
        i_lu := 0, i_human := 0, id_plus, fl_z := .f., ;
        s_lu := 0, s_human := 0, sd_plus, ;
        s_dispan := "Диспансер", fl_plus := .f., md_plus := {}, k_plus
if (j := popup_prompt(T_ROW,T_COL-5,sz,mas_pmt)) == 0
  return NIL
endif
sz := j
if (arr_m := year_month()) == NIL
  return NIL
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  return NIL
endif
if len(st_a_uch) == 1
  glob_uch := st_a_uch[1]
  if (st_a_otd := inputN_otd(T_ROW,T_COL-5,.f.,.f.,glob_uch,@lcount_otd)) == NIL
    return NIL
  endif
  aeval(st_a_otd, {|x| aadd(a_otd,x[1]) })
else
  R_Use(dir_server + "mo_otd",,"OTD")
  go top
  do while !eof()
    if f_is_uch(st_a_uch,otd->kod_lpu)
      aadd(a_otd, otd->(recno()))
    endif
    skip
  enddo
  otd->(dbCloseArea())
endif
if is_talon
  aadd(md_plus,"+")
  aadd(md_plus,"-")
  aadd(md_plus,s_dispan)
endif
k_plus := len(md_plus)
if (fl_plus := (k_plus > 0))
  sd_plus := array(k_plus)
  afill(sd_plus, 0)
  id_plus := array(k_plus)
  afill(id_plus, 0)
endif
speriod := arr_m[4]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
arr := {;
   {"SHIFR",      "C",      5,      0}, ;  // диагноз
   {"SHIFR2",     "C",      5,      0}, ;  // диагноз
   {"KOL",        "N",      6,      0};   // кол-во диагнозов
  }
for i := 1 to k_plus
  aadd(arr, {"KOL"+lstr(i),"N", 6, 0} )
next
dbcreate(cur_dir() + "tmp", arr)
use (cur_dir() + "tmp") new
index on shifr to (cur_dir() + "tmp")
dbcreate(cur_dir() + "tmp_k", {{"kod","N", 7, 0}, ;
                           {"kol","N", 6, 0}})
use (cur_dir() + "tmp_k") new
index on str(kod, 7) to (cur_dir() + "tmp_k")
dbcreate(cur_dir() + "tmp_i", {{"kod","N", 7, 0}, ;
                           {"kol","N", 6, 0}})
use (cur_dir() + "tmp_i") new
index on str(kod, 7) to (cur_dir() + "tmp_i")
dbcreate(cur_dir() + "tmp_b", {{"kod","N", 7, 0}, ;
                           {"shifr","C", 5, 0}, ;
                           {"kol","N", 6, 0}})
use (cur_dir() + "tmp_b") new
index on shifr+str(kod, 7) to (cur_dir() + "tmp_b")
f1_diag_statist_bukva()
if reg > 2
  if reg == 3
    name_gr := dir_exe() + "_mo_mkbg"
  else
    name_gr := dir_exe() + "_mo_mkbk"
  endif
  R_Use(name_gr,,"GR")
  index on sh_e to (cur_dir() + "tmp_gr")
endif
if pi1 == 1  // по дате окончания лечения
  begin_date := arr_m[5]
  end_date := arr_m[6]
  R_Use(dir_server + "human_",,"HUMAN_")
  R_Use(dir_server + "human",dir_server + "humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(begin_date),.t.)
  do while human->k_data <= end_date .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if func_pi_schet() .and. ascan(a_otd,human->otd) > 0
      @ 24, 1 say lstr(++jh) color cColorSt2Msg
      f1diag_statist(reg,sz)
    endif
    select HUMAN
    skip
  enddo
else
  begin_date := arr_m[7]
  end_date := arr_m[8]
  R_Use(dir_server + "human_",,"HUMAN_")
  R_Use(dir_server + "human",dir_server + "humans","HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server + "schet_",,"SCHET_")
  R_Use(dir_server + "schet",dir_server + "schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  dbseek(begin_date,.t.)
  do while schet->pdate <= end_date .and. !eof()
    select HUMAN
    find (str(schet->kod, 6))
    do while human->schet == schet->kod
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if ascan(a_otd,human->otd) > 0
        @ 24, 1 say lstr(++jh) color cColorSt2Msg
        f1diag_statist(reg,sz)
      endif
      select HUMAN
      skip
    enddo
    select SCHET
    skip
  enddo
endif
j := tmp->(lastrec())
i_human := tmp_i->(lastrec())
s_human := tmp_k->(lastrec())
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  reg_print := 5 ; w1 := 47
  arr_title := {;
    "─────────────────────────────────────────────────────┬──────┬──────", ;
    "                                                     │ Боль-│ Слу- ", ;
    "                    Д и а г н о з                    │ ных  │ чаев ", ;
    "─────────────────────────────────────────────────────┴──────┴──────"}
  if fl_plus
    for i := 1 to k_plus
      if md_plus[i] == s_dispan
        s1 := substr(s_dispan, 1, 5)
        s2 := substr(s_dispan, 6)
      else
        s1 := ""
        s2 := '"'+md_plus[i]+'"'
      endif
      arr_title[1] += '╥─────'
      arr_title[2] += '║'+padc(s1, 5)
      arr_title[3] += '║'+padc(s2, 5)
      arr_title[4] += '╨─────'
    next
  endif
  if (sh := len(arr_title[1])) > 85
    reg_print := 6
  endif
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("Статистика по диагнозам",sh))
  titleN_uch(st_a_uch,sh,lcount_uch)
  if len(st_a_uch) == 1
    titleN_otd(st_a_otd,sh,lcount_otd)
  endif
  add_string("")
  add_string(center(speriod,sh))
  add_string("")
  if pi1 == 1
    add_string(center(str_pi_schet(),sh))
  else
    add_string(center("[ по дате выписки счета ]",sh))
  endif
  if sz == 2
    add_string(center("{ по основному заболеванияю }",sh))
  endif
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  //
  if reg < 3
    R_Use(dir_exe() + "_mo_mkb",cur_dir() + "_mo_mkb","MKB10")
    use (cur_dir() + "tmp_b") index (cur_dir() + "tmp_b") new
    use (cur_dir() + "tmp") index (cur_dir() + "tmp") new
    go top
    do while !eof()
      s := ""
      select MKB10
      find (tmp->shifr)
      s := alltrim(mkb10->name)+" "
      skip
      do while left(mkb10->shifr, 5) == tmp->shifr .and. mkb10->ks > 0 ;
                                                  .and. !eof()
        s += alltrim(mkb10->name)+" "
        skip
      enddo
      k := perenos(arr,s,w1)
      s := tmp->shifr+" "+padr(arr[1],w1)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      j := 0
      select TMP_B
      find (tmp->shifr)
      dbeval({|| ++j },,{|| tmp_b->shifr==tmp->shifr })
      s += str(j, 7)
      s += str(tmp->kol, 7)
      if fl_plus
        for i := 1 to k_plus
          pole := "tmp->kol"+lstr(i)
          s += put_val(&pole, 6)
          sd_plus[i] += &pole
          if !(left(ltrim(s), 1) == "Z")
            id_plus[i] += &pole
          endif
        next
      endif
      if left(ltrim(s), 1) == "Z" .and. !fl_itogo
        add_string(replicate("─",sh))
        si := padl("Итого: ",w1+6)+str(i_human, 7)+str(i_lu, 7)
        if fl_plus
          for i := 1 to k_plus
            si += str(id_plus[i], 6)
          next
        endif
        add_string(si)
        add_string(replicate("─",sh))
        fl_itogo := .t.
      endif
      add_string(s)
      for i := 2 to k
        add_string(space(6)+arr[i])
      next
      select TMP
      skip
    enddo
  else
    R_Use(name_gr,,"GR")
    index on sh_b to (cur_dir() + "tmp_gr")
    use (cur_dir() + "tmp_b") index (cur_dir() + "tmp_b") new
    use (cur_dir() + "tmp") index (cur_dir() + "tmp") new
    go top
    do while !eof()
      s := "" ; fl := .f.
      select GR
      find (left(tmp->shifr, 3))
      if (fl := found())
        do while gr->sh_b == left(tmp->shifr, 3) .and. !eof()
          s += alltrim(gr->name)+" "
          skip
        enddo
      endif
      k := perenos(arr,s,w1-2)
      s := left(tmp->shifr, 3)+"-"+left(tmp->shifr2, 3)+" "+padr(arr[1],w1-2)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      j := 0
      select TMP_B
      find (tmp->shifr)
      dbeval({|| ++j },,{|| tmp_b->shifr==tmp->shifr })
      s += str(j, 7)
      s += str(tmp->kol, 7)
      if fl_plus
        for i := 1 to k_plus
          pole := "tmp->kol"+lstr(i)
          s += put_val(&pole, 6)
          sd_plus[i] += &pole
          if !(left(ltrim(s), 1) == "Z")
            id_plus[i] += &pole
          endif
        next
      endif
      if left(ltrim(s), 1) == "Z" .and. !fl_itogo
        add_string(replicate("─",sh))
        si := padl("Итого: ",w1+6)+str(i_human, 7)+str(i_lu, 7)
        if fl_plus
          for i := 1 to k_plus
            si += str(id_plus[i], 6)
          next
        endif
        add_string(si)
        add_string(replicate("─",sh))
        fl_itogo := .t.
      endif
      add_string(s)
      for i := 2 to k
        add_string(space(8)+arr[i])
      next
      select TMP
      skip
    enddo
  endif
  if fl_z
    add_string(replicate("─",sh))
    s := padl("Всего: ",w1+6)+str(s_human, 7)+str(s_lu, 7)
    if fl_plus
      for i := 1 to k_plus
        s += str(sd_plus[i], 6)
      next
    endif
    add_string(s)
  endif
  f3_diag_statist_bukva(HH,sh,arr_title)
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

//
Function f1diag_statist(reg,sz)
Local arr_d := {}, arr, i, j, mshifr, s, pole, fl_i, all_i := .f.
f2_diag_statist_bukva()
afill(adiag_talon, 0)
for i := 1 to 16
  adiag_talon[i] := int(val(substr(human_->DISPANS,i, 1)))
next
arr := diag_to_array(,,,.f.)
if sz == 2
  asize(arr, 1)
endif
for i := 1 to len(arr)
  if !empty(arr[i])
    if left(arr[i], 1) == "Z"
      fl_z := .t.  // private - переменная
    else
      all_i := .t.  // не только "Z" у данного больного
    endif
  endif
next
for i := 1 to len(arr)
  if reg == 1  // 4-х/значный шифр
    mshifr := padr(arr[i], 5)
  else
    mshifr := left(arr[i], 3)
  endif
  if empty(mshifr)
    loop
  endif
  fl_i := !(left(arr[i], 1) == "Z")
  if reg < 3
    mshifr := padr(mshifr, 5)
    select TMP
    find (mshifr)
    if !found()
      append blank
      tmp->shifr := mshifr
    endif
  else
    select GR
    dbseek(mshifr,.t.)
    select TMP
    find (gr->sh_b)
    if !found()
      append blank
      tmp->shifr := gr->sh_b
      tmp->shifr2 := gr->sh_e
    endif
    mshifr := padr(gr->sh_b, 5)
  endif
  if ascan(arr_d, mshifr) == 0
    aadd(arr_d, mshifr)
    tmp->kol ++
  endif
  s := substr(human->diag_plus,i, 1)
  if fl_plus .and. !empty(s) .and. (j := ascan(md_plus, s)) > 0
    pole := "tmp->kol"+lstr(j)
    &pole := &pole+1
  endif
  if !eq_any(s,"+","-")
    s := adiag_talon[i*2-1]
    if eq_any(s, 1, 2)
      s := iif(s == 1, "+", "-")
      if (j := ascan(md_plus, s)) > 0
        pole := "tmp->kol"+lstr(j)
        &pole := &pole+1
      endif
    endif
  endif
  if eq_any(adiag_talon[i*2], 1, 2) .and. (j := ascan(md_plus, s_dispan)) > 0
    pole := "tmp->kol"+lstr(j)
    &pole := &pole+1
  endif
next
if len(arr_d) > 0
  ++s_lu
  select TMP_K
  find (str(human->kod_k, 7))
  if !found()
    append blank
    tmp_k->kod := human->kod_k
  endif
  tmp_k->kol ++
  if all_i
    ++i_lu
    select TMP_I
    find (str(human->kod_k, 7))
    if !found()
      append blank
      tmp_i->kod := human->kod_k
    endif
    tmp_i->kol ++
  endif
  for j := 1 to len(arr_d)
    select TMP_B
    find (arr_d[j]+str(human->kod_k, 7))
    if !found()
      append blank
      tmp_b->shifr := arr_d[j]
      tmp_b->kod := human->kod_k
      if tmp_b->(lastrec()) % 5000 == 0
        Commit
      endif
    endif
    tmp_b->kol ++
  next
endif
return NIL

// 14.10.24
Function diagLVstatist()
Static sz := 1
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., sh, HH := 76, reg_print, speriod, fl, ;
      arr_title, name_file := 's_diag_v.txt', ;
      jh := 0, arr_m, name_gr, j_1 := 0, j_2 := 0, a_otd := {}
Local mas_pmt := {"С ~разбивкой по врачам", ;
                  "~Объединенный документ"}
Private is_talon := .t., adiag_talon[16], s_lu := 0, s_human := 0, ;
        s_dispan := "Диспансер", fl_plus := .f., md_plus := {}, ;
        sd_plus, k_plus, mperso, regim := 1, md_bukva := {}
if (arr_m := year_month()) == NIL
  return NIL
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  return NIL
endif
if len(st_a_uch) == 1
  glob_uch := st_a_uch[1]
  if (st_a_otd := inputN_otd(T_ROW,T_COL-5,.f.,.f.,glob_uch,@lcount_otd)) == NIL
    return NIL
  endif
  aeval(st_a_otd, {|x| aadd(a_otd,x[1]) })
else
  R_Use(dir_server + "mo_otd",,"OTD")
  go top
  do while !eof()
    if f_is_uch(st_a_uch,otd->kod_lpu)
      aadd(a_otd, otd->(recno()))
    endif
    skip
  enddo
  otd->(dbCloseArea())
endif
if (mperso := input_kperso()) != NIL
  if (j := popup_prompt(T_ROW,T_COL-5,sz,mas_pmt)) == 0
    return NIL
  endif
  regim := sz := j
endif
if is_talon
  aadd(md_plus,"+")
  aadd(md_plus,"-")
  aadd(md_plus,s_dispan)
endif
k_plus := len(md_plus)
if (fl_plus := (k_plus > 0))
  sd_plus := array(k_plus)
  afill(sd_plus, 0)
endif
speriod := arr_m[4]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
arr := {;
   {"vrach",      "N",      4,      0}, ;
   {"SHIFR",      "C",      5,      0}, ;  // диагноз
   {"KOL",        "N",      6,      0};   // кол-во диагнозов
  }
for i := 1 to k_plus
  aadd(arr, {"KOL"+lstr(i),"N", 6, 0} )
next
dbcreate(cur_dir() + "tmp", arr)
use (cur_dir() + "tmp") new
index on str(vrach, 4)+shifr to (cur_dir() + "tmp")
dbcreate(cur_dir() + "tmp_k", {{"vrach","N", 4, 0}, ;
                           {"kod","N", 7, 0}, ;
                           {"kol","N", 6, 0}})
use (cur_dir() + "tmp_k") new
index on str(vrach, 4)+str(kod, 7) to (cur_dir() + "tmp_k")
dbcreate(cur_dir() + "tmp_b", {{"vrach","N", 4, 0}, ;
                           {"kod","N", 7, 0}, ;
                           {"shifr","C", 5, 0}, ;
                           {"kol","N", 6, 0}})
use (cur_dir() + "tmp_b") new
index on str(vrach, 4)+shifr+str(kod, 7) to (cur_dir() + "tmp_b")
f1_diag_statist_bukva()
if pi1 == 1  // по дате окончания лечения
  begin_date := arr_m[5]
  end_date := arr_m[6]
  R_Use(dir_server + "human_",,"HUMAN_")
  R_Use(dir_server + "human",dir_server + "humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(begin_date),.t.)
  do while human->k_data <= end_date .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if func_pi_schet() .and. ascan(a_otd,human->otd) > 0
      @ 24, 1 say lstr(++jh) color cColorSt2Msg
      f1diagLVstatist()
    endif
    select HUMAN
    skip
  enddo
else
  begin_date := arr_m[7]
  end_date := arr_m[8]
  R_Use(dir_server + "human_",,"HUMAN_")
  R_Use(dir_server + "human",dir_server + "humans","HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server + "schet_",,"SCHET_")
  R_Use(dir_server + "schet",dir_server + "schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  dbseek(begin_date,.t.)
  do while schet->pdate <= end_date .and. !eof()
    select HUMAN
    find (str(schet->kod, 6))
    do while human->schet == schet->kod
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if ascan(a_otd,human->otd) > 0
        @ 24, 1 say lstr(++jh) color cColorSt2Msg
        f1diagLVstatist()
      endif
      select HUMAN
      skip
    enddo
    select SCHET
    skip
  enddo
endif
j := tmp->(lastrec())
s_human := tmp_k->(lastrec())
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  reg_print := 5 ; w1 := 47
  arr_title := {;
    "─────────────────────────────────────────────────────┬──────┬──────", ;
    "                                                     │ Боль-│ Слу- ", ;
    "                    Д и а г н о з                    │ ных  │ чаев ", ;
    "─────────────────────────────────────────────────────┴──────┴──────"}
  if fl_plus
    for i := 1 to k_plus
      if md_plus[i] == s_dispan
        s1 := substr(s_dispan, 1, 5)
        s2 := substr(s_dispan, 6)
      else
        s1 := ""
        s2 := '"'+md_plus[i]+'"'
      endif
      arr_title[1] += '╥─────'
      arr_title[2] += '║'+padc(s1, 5)
      arr_title[3] += '║'+padc(s2, 5)
      arr_title[4] += '╨─────'
    next
  endif
  if (sh := len(arr_title[1])) > 85
    reg_print := 6
  endif
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("Статистика по диагнозам",sh))
  titleN_uch(st_a_uch,sh,lcount_uch)
  if len(st_a_uch) == 1
    titleN_otd(st_a_otd,sh,lcount_otd)
  endif
  add_string("")
  add_string(center(speriod,sh))
  add_string("")
  if pi1 == 1
    add_string(center(str_pi_schet(),sh))
  else
    add_string(center("[ по дате выписки счета ]",sh))
  endif
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  //
  R_Use(dir_exe() + "_mo_mkb",cur_dir() + "_mo_mkb","MKB10")
  use (cur_dir() + "tmp_k") index (cur_dir() + "tmp_k") new
  use (cur_dir() + "tmp_b") index (cur_dir() + "tmp_b") new
  use (cur_dir() + "tmp") index (cur_dir() + "tmp") new
  if regim == 1
    R_Use(dir_server + "mo_pers",,"PERSO")
    select TMP
    set relation to vrach into PERSO
    index on upper(perso->fio)+str(vrach, 4)+shifr to (cur_dir() + "tmp1")
    old_vrach := 0
    afill(sd_plus, 0)
  endif
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if regim == 1 .and. old_vrach != tmp->vrach
      if old_vrach > 0
        f2diagLVstatist(old_vrach,sd_plus,sh)
        f3_diag_statist_bukva(HH,sh,arr_title,old_vrach)
      endif
      add_string("")
      add_string(space(10)+lstr(perso->tab_nom)+". "+upper(alltrim(perso->fio)))
      old_vrach := tmp->vrach
      afill(sd_plus, 0)
    endif
    s := ""
    select MKB10
    find (tmp->shifr)
    s := alltrim(mkb10->name)+" "
    skip
    do while left(mkb10->shifr, 5) == tmp->shifr .and. mkb10->ks > 0 ;
                                                .and. !eof()
      s += alltrim(mkb10->name)+" "
      skip
    enddo
    k := perenos(arr,s,w1)
    //
    s := tmp->shifr+" "+padr(arr[1],w1)
    j := 0
    select TMP_B
    if regim == 1
      find (str(tmp->vrach, 4)+tmp->shifr)
      dbeval({|| ++j },, ;
             {|| tmp_b->vrach==tmp->vrach .and. tmp_b->shifr==tmp->shifr })
    else
      find (str(0, 4)+tmp->shifr)
      dbeval({|| ++j },,{|| tmp_b->shifr==tmp->shifr })
    endif
    s += str(j, 7)
    s += str(tmp->kol, 7)
    if fl_plus
      for i := 1 to k_plus
        pole := "tmp->kol"+lstr(i)
        s += put_val(&pole, 6)
        sd_plus[i] += &pole
      next
    endif
    add_string(s)
    for i := 2 to k
      add_string(space(6)+arr[i])
    next
    select TMP
    skip
  enddo
  if regim == 1
    if old_vrach > 0
      f2diagLVstatist(old_vrach,sd_plus,sh)
      f3_diag_statist_bukva(HH,sh,arr_title,old_vrach)
    endif
  else
    add_string(replicate("─",sh))
    s := padl("Итого: ",w1+6)+str(s_human, 7)+str(s_lu, 7)
    if fl_plus
      for i := 1 to k_plus
        s += str(sd_plus[i], 6)
      next
    endif
    add_string(s)
    f3_diag_statist_bukva(HH,sh,arr_title)
  endif
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

//
Function f1diagLVstatist()
Local arr_d := {}, arr, i, j, mvrach := 0, mshifr, s, pole, fl
if (fl := (human_->vrach > 0))
  if regim == 1    // с разбивкой по врачам
    mvrach := human_->vrach
  endif
  if mperso != NIL  // не все врачи
    fl := (ascan(mperso, {|x| x[1] == human_->vrach }) > 0)
  endif
endif
if !fl ; return NIL ; endif
f2_diag_statist_bukva(mvrach)
//
afill(adiag_talon, 0)
for i := 1 to 16
  adiag_talon[i] := int(val(substr(human_->DISPANS,i, 1)))
next
arr := diag_to_array(,,,.f.)
for i := 1 to len(arr)
  mshifr := padr(arr[i], 5)
  if empty(mshifr)
    loop
  endif
  select TMP
  find (str(mvrach, 4)+mshifr)
  if !found()
    append blank
    tmp->vrach := mvrach
    tmp->shifr := mshifr
  endif
  if ascan(arr_d, mshifr) == 0
    aadd(arr_d, mshifr)
    tmp->kol ++
  endif
  s := substr(human->diag_plus,i, 1)
  if fl_plus .and. !empty(s) .and. (j := ascan(md_plus, s)) > 0
    pole := "tmp->kol"+lstr(j)
    &pole := &pole+1
  endif
  if !eq_any(s,"+","-")
    s := adiag_talon[i*2-1]
    if eq_any(s, 1, 2)
      s := iif(s == 1, "+", "-")
      if (j := ascan(md_plus, s)) > 0
        pole := "tmp->kol"+lstr(j)
        &pole := &pole+1
      endif
    endif
  endif
  if eq_any(adiag_talon[i*2], 1, 2) .and. (j := ascan(md_plus, s_dispan)) > 0
    pole := "tmp->kol"+lstr(j)
    &pole := &pole+1
  endif
next
if len(arr_d) > 0
  s_lu ++
  select TMP_K
  find (str(mvrach, 4)+str(human->kod_k, 7))
  if !found()
    append blank
    tmp_k->vrach := mvrach
    tmp_k->kod := human->kod_k
  endif
  tmp_k->kol ++
  for j := 1 to len(arr_d)
    select TMP_B
    find (str(mvrach, 4)+arr_d[j]+str(human->kod_k, 7))
    if !found()
      append blank
      tmp_b->vrach := mvrach
      tmp_b->shifr := arr_d[j]
      tmp_b->kod := human->kod_k
      if tmp_b->(lastrec()) % 5000 == 0
        Commit
      endif
    endif
    tmp_b->kol ++
  next
endif
return NIL

//
Function f2diagLVstatist(kod_vr,sd_plus,sh)
Local ls_lu := 0, ls_human := 0, i, s
select TMP_K
find (str(kod_vr, 4))
dbeval( {|| ++ls_human, ls_lu += tmp_k->kol },,{|| kod_vr == tmp_k->vrach } )
add_string(replicate("─",sh))
s := padl("Итого: ",w1+6)+str(ls_human, 7)+str(ls_lu, 7)
if fl_plus
  for i := 1 to k_plus
    s += str(sd_plus[i], 6)
  next
endif
add_string(s)
return NIL

// 14.10.24
Function diagLUstatist()
Static sz := 1
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., sh, HH := 76, reg_print, speriod, fl, ;
      arr_title, name_file := 's_diag_u.txt', ;
      jh := 0, arr_m, name_gr, j_1 := 0, j_2 := 0, a_otd := {}
Private is_talon := .t., adiag_talon[16], s_lu := 0, s_human := 0, ;
        s_dispan := "Диспансер", fl_plus := .f., md_plus := {}, ;
        sd_plus, k_plus, mperso, regim := 1, md_bukva := {}
if (arr_m := year_month()) == NIL
  return NIL
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  return NIL
endif
if len(st_a_uch) == 1
  glob_uch := st_a_uch[1]
  if (st_a_otd := inputN_otd(T_ROW,T_COL-5,.f.,.f.,glob_uch,@lcount_otd)) == NIL
    return NIL
  endif
  aeval(st_a_otd, {|x| aadd(a_otd,x[1]) })
else
  R_Use(dir_server + "mo_otd",,"OTD")
  go top
  do while !eof()
    if f_is_uch(st_a_uch,otd->kod_lpu)
      aadd(a_otd, otd->(recno()))
    endif
    skip
  enddo
  otd->(dbCloseArea())
endif
Private arr_uchast
if (arr_uchast := ret_uchast(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if is_talon
  aadd(md_plus,"+")
  aadd(md_plus,"-")
  aadd(md_plus,s_dispan)
endif
k_plus := len(md_plus)
if (fl_plus := (k_plus > 0))
  sd_plus := array(k_plus)
  afill(sd_plus, 0)
endif
speriod := arr_m[4]
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
arr := {;
   {"uchast",     "N",      2,      0}, ;
   {"SHIFR",      "C",      5,      0}, ;  // диагноз
   {"KOL",        "N",      6,      0};   // кол-во диагнозов
  }
for i := 1 to k_plus
  aadd(arr, {"KOL"+lstr(i),"N", 6, 0} )
next
dbcreate(cur_dir() + "tmp", arr)
use (cur_dir() + "tmp") new
index on str(uchast, 2)+shifr to (cur_dir() + "tmp")
dbcreate(cur_dir() + "tmp_k", {{"uchast","N", 2, 0}, ;
                           {"kod","N", 7, 0}, ;
                           {"kol","N", 6, 0}})
use (cur_dir() + "tmp_k") new
index on str(uchast, 2)+str(kod, 7) to (cur_dir() + "tmp_k")
dbcreate(cur_dir() + "tmp_b", {{"uchast","N", 2, 0}, ;
                           {"kod","N", 7, 0}, ;
                           {"shifr","C", 5, 0}, ;
                           {"kol","N", 6, 0}})
use (cur_dir() + "tmp_b") new
index on str(uchast, 2)+shifr+str(kod, 7) to (cur_dir() + "tmp_b")
f1_diag_statist_bukva()
R_Use(dir_server + "kartotek",,"KART")
if pi1 == 1  // по дате окончания лечения
  begin_date := arr_m[5]
  end_date := arr_m[6]
  R_Use(dir_server + "human_",,"HUMAN_")
  R_Use(dir_server + "human",dir_server + "humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(begin_date),.t.)
  do while human->k_data <= end_date .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if func_pi_schet() .and. ascan(a_otd,human->otd) > 0
      @ 24, 1 say lstr(++jh) color cColorSt2Msg
      f1diagLUstatist()
    endif
    select HUMAN
    skip
  enddo
else
  begin_date := arr_m[7]
  end_date := arr_m[8]
  R_Use(dir_server + "human_",,"HUMAN_")
  R_Use(dir_server + "human",dir_server + "humans","HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server + "schet_",,"SCHET_")
  R_Use(dir_server + "schet",dir_server + "schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  dbseek(begin_date,.t.)
  do while schet->pdate <= end_date .and. !eof()
    select HUMAN
    find (str(schet->kod, 6))
    do while human->schet == schet->kod .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if ascan(a_otd,human->otd) > 0
        @ 24, 1 say lstr(++jh) color cColorSt2Msg
        f1diagLUstatist()
      endif
      select HUMAN
      skip
    enddo
    select SCHET
    skip
  enddo
endif
j := tmp->(lastrec())
s_human := tmp_k->(lastrec())
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
if j == 0
  func_error(4,"Нет сведений!")
else
  mywait()
  reg_print := 5 ; w1 := 47
  arr_title := {;
    "─────────────────────────────────────────────────────┬──────┬──────", ;
    "                                                     │ Боль-│ Слу- ", ;
    "                    Д и а г н о з                    │ ных  │ чаев ", ;
    "─────────────────────────────────────────────────────┴──────┴──────"}
  if fl_plus
    for i := 1 to k_plus
      if md_plus[i] == s_dispan
        s1 := substr(s_dispan, 1, 5)
        s2 := substr(s_dispan, 6)
      else
        s1 := ""
        s2 := '"'+md_plus[i]+'"'
      endif
      arr_title[1] += '╥─────'
      arr_title[2] += '║'+padc(s1, 5)
      arr_title[3] += '║'+padc(s2, 5)
      arr_title[4] += '╨─────'
    next
  endif
  if (sh := len(arr_title[1])) > 85
    reg_print := 6
  endif
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("Статистика по диагнозам",sh))
  titleN_uch(st_a_uch,sh,lcount_uch)
  if len(st_a_uch) == 1
    titleN_otd(st_a_otd,sh,lcount_otd)
  endif
  add_string("")
  add_string(center(speriod,sh))
  add_string("")
  if pi1 == 1
    add_string(center(str_pi_schet(),sh))
  else
    add_string(center("[ по дате выписки счета ]",sh))
  endif
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  //
  R_Use(dir_exe() + "_mo_mkb",cur_dir() + "_mo_mkb","MKB10")
  old_uchast := -1
  use (cur_dir() + "tmp_k") index (cur_dir() + "tmp_k") new
  use (cur_dir() + "tmp_b") index (cur_dir() + "tmp_b") new
  use (cur_dir() + "tmp") index (cur_dir() + "tmp") new
  go top
  do while !eof()
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if regim == 1 .and. old_uchast != tmp->uchast
      if old_uchast >= 0
        f2diagLUstatist(old_uchast,sd_plus,sh)
        f3_diag_statist_bukva(HH,sh,arr_title,old_uchast)
      endif
      add_string("")
      add_string(space(10)+"УЧАСТОК № "+lstr(tmp->uchast))
      old_uchast := tmp->uchast
      afill(sd_plus, 0)
    endif
    s := ""
    select MKB10
    find (tmp->shifr)
    s := alltrim(mkb10->name)+" "
    skip
    do while left(mkb10->shifr, 5) == tmp->shifr .and. mkb10->ks > 0 ;
                                                .and. !eof()
      s += alltrim(mkb10->name)+" "
      skip
    enddo
    k := perenos(arr,s,w1)
    //
    s := tmp->shifr+" "+padr(arr[1],w1)
    j := 0
    select TMP_B
    find (str(tmp->uchast, 2)+tmp->shifr)
    dbeval({|| ++j },, ;
           {|| tmp_b->uchast==tmp->uchast .and. tmp_b->shifr==tmp->shifr })
    s += str(j, 7)
    s += str(tmp->kol, 7)
    if fl_plus
      for i := 1 to k_plus
        pole := "tmp->kol"+lstr(i)
        s += put_val(&pole, 6)
        sd_plus[i] += &pole
      next
    endif
    add_string(s)
    for i := 2 to k
      add_string(space(6)+arr[i])
    next
    select TMP
    skip
  enddo
  if old_uchast > 0
    f2diagLUstatist(old_uchast,sd_plus,sh)
    f3_diag_statist_bukva(HH,sh,arr_title,old_uchast)
  endif
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(name_file,,,,(sh>80),,,reg_print)
endif
return NIL

//
Function f1diagLUstatist()
Local arr_d := {}, arr, i, j, muchast := 0, mshifr, s, pole, fl
if human->kod_k > 0
  select KART
  goto (human->kod_k)
  if kart->uchast > 0
    muchast := kart->uchast
  endif
endif
if !f_is_uchast(arr_uchast,muchast)
  return NIL
endif
f2_diag_statist_bukva(muchast)
afill(adiag_talon, 0)
for i := 1 to 16
  adiag_talon[i] := int(val(substr(human_->DISPANS,i, 1)))
next
arr := diag_to_array(,,,.f.)
for i := 1 to len(arr)
  mshifr := padr(arr[i], 5)
  if empty(mshifr)
    loop
  endif
  select TMP
  find (str(muchast, 2)+mshifr)
  if !found()
    append blank
    tmp->uchast := muchast
    tmp->shifr := mshifr
  endif
  if ascan(arr_d, mshifr) == 0
    aadd(arr_d, mshifr)
    tmp->kol ++
  endif
  s := substr(human->diag_plus,i, 1)
  if fl_plus .and. !empty(s) .and. (j := ascan(md_plus, s)) > 0
    pole := "tmp->kol"+lstr(j)
    &pole := &pole+1
  endif
  if !eq_any(s,"+","-")
    s := adiag_talon[i*2-1]
    if eq_any(s, 1, 2)
      s := iif(s == 1, "+", "-")
      if (j := ascan(md_plus, s)) > 0
        pole := "tmp->kol"+lstr(j)
        &pole := &pole+1
      endif
    endif
  endif
  if eq_any(adiag_talon[i*2], 1, 2) .and. (j := ascan(md_plus, s_dispan)) > 0
    pole := "tmp->kol"+lstr(j)
    &pole := &pole+1
  endif
next
if len(arr_d) > 0
  s_lu ++
  select TMP_K
  find (str(muchast, 2)+str(human->kod_k, 7))
  if !found()
    append blank
    tmp_k->uchast := muchast
    tmp_k->kod := human->kod_k
  endif
  tmp_k->kol ++
  for j := 1 to len(arr_d)
    select TMP_B
    find (str(muchast, 2)+arr_d[j]+str(human->kod_k, 7))
    if !found()
      append blank
      tmp_b->uchast := muchast
      tmp_b->shifr := arr_d[j]
      tmp_b->kod := human->kod_k
      if tmp_b->(lastrec()) % 5000 == 0
        Commit
      endif
    endif
    tmp_b->kol ++
  next
endif
return NIL

//
Function f2diagLUstatist(kod_uch,sd_plus,sh)
Local ls_lu := 0, ls_human := 0, i, s
select TMP_K
find (str(kod_uch, 2))
dbeval( {|| ++ls_human, ls_lu += tmp_k->kol },,{|| kod_uch == tmp_k->uchast } )
add_string(replicate("─",sh))
s := padl("Итого: ",w1+6)+str(ls_human, 7)+str(ls_lu, 7)
if fl_plus
  for i := 1 to k_plus
    s += str(sd_plus[i], 6)
  next
endif
add_string(s)
return NIL

//
Function f1_diag_statist_bukva()
dbcreate(cur_dir() + "tmp_buk",{{"bukva","C", 1, 0}, ;
                            {"vu","N", 4, 0}, ;
                            {"KOL","N", 6, 0}})
use (cur_dir() + "tmp_buk") new
index on str(vu, 4)+bukva to (cur_dir() + "tmp_buk")
dbcreate(cur_dir() + "tmp_bbuk",{{"bukva","C", 1, 0}, ;
                             {"vu","N", 4, 0}, ;
                             {"kod","N", 7, 0}, ;
                             {"KOL","N", 6, 0}})
use (cur_dir() + "tmp_bbuk") new
index on str(vu, 4)+bukva+str(kod, 7) to (cur_dir() + "tmp_bbuk")
return NIL

//
Function f2_diag_statist_bukva(lvu)
Local i, c, s := upper(charrem(" ",alltrim(human_->STATUS_ST)))
DEFAULT lvu TO 0
for i := 1 to len(s)
  c := substr(s,i, 1)
  select TMP_BUK
  find (str(lvu, 4)+c)
  if !found()
    append blank
    tmp_buk->vu := lvu
    tmp_buk->bukva := c
  endif
  tmp_buk->kol ++
  //
  select TMP_BBUK
  find (str(lvu, 4)+c+str(human->kod_k, 7))
  if !found()
    append blank
    tmp_bbuk->vu := lvu
    tmp_bbuk->bukva := c
    tmp_bbuk->kod := human->kod_k
  endif
  tmp_bbuk->kol ++
next
return NIL

//
Function f3_diag_statist_bukva(HH,sh,arr_title,lvu)
Local j
DEFAULT lvu TO 0
if select("TMP_BUK") == 0
  use (cur_dir() + "tmp_bbuk") index (cur_dir() + "tmp_bbuk") new
  use (cur_dir() + "tmp_buk") index (cur_dir() + "tmp_buk") new
endif
select TMP_BUK
find (str(lvu, 4))
do while tmp_buk->vu == lvu .and. !eof()
  j := 0
  select TMP_BBUK
  find (str(lvu, 4)+tmp_buk->bukva)
  dbeval({|| ++j },,{|| tmp_bbuk->vu == lvu .and. tmp_bbuk->bukva==tmp_buk->bukva })
  if verify_FF(HH,.t.,sh) .and. valtype(arr_title)=="A"
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(padl(tmp_buk->bukva,w1+6)+str(j, 7)+str(tmp_buk->kol, 7))
  select TMP_BUK
  skip
enddo
return NIL

//
Function f_stat_boln()
Local i, j, k, arr, begin_date, end_date, s, buf := save_maxrow(), ;
      fl_exit := .f., jh := 0, is_talon := .t., t_arr[BR_LEN], a_otd := {}
Private adiag_talon[16], speriod, arr_m
if (arr_m := year_month()) == NIL
  return NIL
endif
speriod := arr_m[4]
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  return NIL
endif
if len(st_a_uch) == 1
  glob_uch := st_a_uch[1]
  if (st_a_otd := inputN_otd(T_ROW,T_COL-5,.f.,.f.,glob_uch,@lcount_otd)) == NIL
    return NIL
  endif
  aeval(st_a_otd, {|x| aadd(a_otd,x[1]) })
else
  R_Use(dir_server + "mo_otd",,"OTD")
  go top
  do while !eof()
    if f_is_uch(st_a_uch,otd->kod_lpu)
      aadd(a_otd, otd->(recno()))
    endif
    skip
  enddo
  otd->(dbCloseArea())
endif
//
WaitStatus("<Esc> - прервать поиск") ; mark_keys({"<Esc>"})
//
adbf := {{"kod_k","N", 7, 0}, ;
         {"STATUS_ST","C", 20, 0}, ;
         {"kol_1","N", 3, 0}, ;
         {"kol_2","N", 3, 0}}
dbcreate(cur_dir() + "tmp",adbf)
use (cur_dir() + "tmp") new
index on str(kod_k, 7) to (cur_dir() + "tmp")
//
adbf := {{"kod_k","N", 7, 0}, ;
         {"kod_h","N", 7, 0}}
dbcreate(cur_dir() + "tmp_h",adbf)
use (cur_dir() + "tmp_h") new
//
kh := 0
if pi1 == 1 // по дате окончания лечения
  begin_date := arr_m[5]
  end_date := arr_m[6]
  R_Use(dir_server + "human_",,"HUMAN_")
  R_Use(dir_server + "human",dir_server + "humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(begin_date),.t.)
  do while human->k_data <= end_date .and. !eof()
    @ 24, 1 say lstr(++kh) color cColorSt2Msg
    if jh > 0
      @ row(),col() say "/" color "W/R"
      @ row(),col() say lstr(jh) color cColorStMsg
    endif
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    if func_pi_schet() .and. ascan(a_otd,human->otd) > 0
      jh := f1_stat_boln(jh)
    endif
    select HUMAN
    skip
  enddo
else
  begin_date := arr_m[7]
  end_date := arr_m[8]
  R_Use(dir_server + "human_",,"HUMAN_")
  R_Use(dir_server + "human",dir_server + "humans","HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server + "schet_",,"SCHET_")
  R_Use(dir_server + "schet",dir_server + "schetd","SCHET")
  set relation to recno() into SCHET_
  set filter to empty(schet_->IS_DOPLATA)
  dbseek(begin_date,.t.)
  do while schet->pdate <= end_date .and. !eof()
    select HUMAN
    find (str(schet->kod, 6))
    do while human->schet == schet->kod .and. !eof()
      UpdateStatus()
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      if ascan(a_otd,human->otd) > 0
        @ 24, 1 say lstr(++kh) color cColorSt2Msg
        if jh > 0
          @ row(),col() say "/" color "W/R"
          @ row(),col() say lstr(jh) color cColorStMsg
        endif
        jh := f1_stat_boln(jh)
      endif
      select HUMAN
      skip
    enddo
    select SCHET
    skip
  enddo
endif
close databases
rest_box(buf)
if fl_exit ; return NIL ; endif
if jh == 0
  return func_error(4,"Не вводилась информация о характере заболевания за указанный период!")
endif
mywait()
use (cur_dir() + "tmp_h") new
index on str(kod_k, 7) to (cur_dir() + "tmp_h")
use
//
t_arr[BR_TOP] := 2
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 8
t_arr[BR_RIGHT] := 72
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Список больных с заполненным характером заболевания"
t_arr[BR_TITUL_COLOR] := "BG+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.t., 0}
n := 50
blk := {|| iif(kol_1 > 1 .or. kol_2 > 1, {3, 4}, {1, 2}) }
t_arr[BR_COLUMN] := {{ center("Ф.И.О.",n+1), {|| " "+padr(kart->fio,n) }, blk }, ;
                     { "  +  ", {|| put_val(kol_1, 3)+"  " }, blk }, ;
                     { "  -  ", {|| put_val(kol_2, 3)+"  " }, blk }}
if yes_bukva // если в настройке - работа со статусом стом.больного
  asize(t_arr[BR_COLUMN], 1)
  aadd(t_arr[BR_COLUMN],{ "Стом.статус", {|| left(status_st, 11) }, blk })
  t_arr[BR_TITUL] := "Список больных с заполненным стоматологическим статусом"
endif
t_arr[BR_EDIT] := {|nk,ob| f2_stat_boln(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| ;
      status_key("^<Esc>^ выход;  ^<Enter>^ листы учета по больному;  ^<F9>^ печать списка") }
R_Use(dir_server + "kartotek",,"KART")
use (cur_dir() + "tmp") new
set relation to kod_k into KART
index on upper(kart->fio) to (cur_dir() + "tmp")
go top
edit_browse(t_arr)
close databases
rest_box(buf)
return NIL

//
Function f1_stat_boln(jh)
Local is_talon := .t., arr, i, j, k, s, k1 := 0, k2 := 0
afill(adiag_talon, 0)
for i := 1 to 16
  adiag_talon[i] := int(val(substr(human_->DISPANS,i, 1)))
next
arr := {human->KOD_DIAG , ;
        human->KOD_DIAG2, ;
        human->KOD_DIAG3, ;
        human->KOD_DIAG4, ;
        human->SOPUT_B1 , ;
        human->SOPUT_B2 , ;
        human->SOPUT_B3 , ;
        human->SOPUT_B4}
for i := 1 to len(arr)
  if !empty(arr[i])
    s := substr(human->diag_plus,i, 1)
    if eq_any(s,"+","-")  // старая форма
      if s == "+"
        ++k1
      else
        ++k2
      endif
    elseif is_talon
      s := adiag_talon[i*2-1]
      if s == 1
        ++k1
      elseif s == 2
        ++k2
      endif
    endif
  endif
next
if k1 > 0 .or. k2 > 0 .or. !empty(human_->STATUS_ST)
  ++jh
  select TMP
  find (str(human->kod_k, 7))
  if !found()
    append blank
    tmp->kod_k := human->kod_k
  endif
  if !empty(human_->STATUS_ST)
    tmp->STATUS_ST := charrem(" ",charlist(charmix(tmp->STATUS_ST,human_->STATUS_ST)))
  endif
  tmp->kol_1 += k1
  tmp->kol_2 += k2
  //
  select TMP_H
  append blank
  tmp_h->kod_k := human->kod_k
  tmp_h->kod_h := human->kod
  if recno() % 5000 == 0
    tmp->(dbCommit())
    tmp_h->(dbCommit())
  endif
endif
return jh

//
Function f2_stat_boln(nKey,oBrow,regim)
Local ret := -1, fl := .f., rec, arr := {}
do case
  case regim == "edit"
    do case
      case nKey == K_F9
        rec := tmp->(recno())
        f3_stat_boln()
        select TMP
        goto (rec)
      case nKey == K_ENTER
        rec := tmp->(recno())
        use (cur_dir() + "tmp_h") index (cur_dir() + "tmp_h") new
        find (str(tmp->kod_k, 7))
        do while tmp->kod_k == tmp_h->kod_k .and. !eof()
          aadd(arr,{0,tmp_h->kod_h})
          select TMP_H
          skip
        enddo
        close databases
        print_al_uch(arr,arr_m)
        //
        R_Use(dir_server + "kartotek",,"KART")
        use (cur_dir() + "tmp") new
        set relation to kod_k into KART
        set index to (cur_dir() + "tmp")
        goto (rec)
    endcase
endcase
return ret

//
Function f3_stat_boln()
Local i, s, sh, HH := 80, reg_print, arr_title, name_file := "stat_b.txt", ;
      buf := save_maxrow()
mywait()
reg_print := 4
arr_title := {;
  "────┬─────────────────────────────────────────────┬─────┬─────", ;
  " NN │              Ф.И.О. больного                │  +  │  -  ", ;
  "────┴─────────────────────────────────────────────┴─────┴─────";
  }
sh := len(arr_title[1])
fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
add_string(center("Список больных, по которым",sh))
add_string(center("был проставлен характер заболевания",sh))
titleN_uch(st_a_uch,sh,lcount_uch)
if len(st_a_uch) == 1
  titleN_otd(st_a_otd,sh,lcount_otd)
endif
add_string(center(speriod,sh))
if pi1 == 1
  add_string(center(str_pi_schet(),sh))
else
  add_string(center("[ по дате выписки счета ]",sh))
endif
add_string("")
aeval(arr_title, {|x| add_string(x) })
i := 0
go top
do while !eof()
  if verify_FF(HH,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  s := padr(lstr(++i)+". "+kart->fio, 50)+put_val(tmp->kol_1, 4)+"  "+;
                                         put_val(tmp->kol_2, 4)
  add_string(s)
  select TMP
  skip
enddo
fclose(fp)
rest_box(buf)
viewtext(name_file,,,,.t.,,,reg_print)
return NIL


// 14.10.24 Подсчёт стационарных случаев по профилям (по диагнозам, КСГ и операциям)
Function i_stac_sl_profil()
  Local buf := savescreen(), sh := 80, HH := 80, n_file := cur_dir() + 'stac_pro.txt'

  Private arr_m := {2024, 1, 6, 'за январь - июнь 2024 года', 0d20240101, 0d20240630}, ;
          mm_uslov := {{'по всем случаям                      ', 2}, ;
                       {'по счетам отч.периода (без учёта РАК)', 0}, ;
                       {'с учётом РАК (как в форме 14-МЕД/ОМС)', 1}}
  Private mdate := arr_m[4], m1date := arr_m[1], muslov := mm_uslov[3, 1], m1uslov := mm_uslov[3, 2]
  r1 := 17
  box_shadow(r1, 2, 22, 77, color1, ' Отчёт по профилям в стационаре (дневном стационаре) ', color8)
  tmp_solor := setcolor(cDataCGet)

  @ r1 + 2, 4 say 'Период времени' get mdate ;
            reader {|x|menu_reader(x, ;
                   {{|k, r, c| k := year_month(r + 1, c, , {3, 4}), ;
                             iif(k == nil, nil, (arr_m := aclone(k), k:={k[1], k[4]})), ;
                             k }}, A__FUNCTION, , , .f.)}
  @ r1 + 3, 4 say 'Условия отбора' get muslov ;
            reader {|x|menu_reader(x, mm_uslov, A__MENUVERT, , , .f.)}
  status_key('^<Esc>^ - выход;  ^<PgDn>^ - создание отчёта')
  myread()
  restscreen(buf)
  if lastkey() == K_ESC
    return nil
  elseif !between(arr_m[1], 2018, 2024)
    return func_error(4, 'Данный отчёт работает только с 2018-24 годами')
  else
    begin_date := dtoc4(arr_m[5])
    end_date := dtoc4(arr_m[6])
    WaitStatus('<Esc> - прервать поиск')
    mark_keys({'<Esc>'})
    //
    kds := kdr := 10
    if arr_m[1] == 2019 .and. arr_m[3] == 12
      kds := 17 // дата регистрации по 17.01.20
      kdr := 21 // по какую дату РАК сумма к оплате 21.01.20
    elseif arr_m[1] == 2018 .and. arr_m[3] == 12
      kds := 21
      kdr := 22
    elseif arr_m[1] == 2020 .and. arr_m[3] == 12
      kds := 21    
      kdr := 22
    elseif arr_m[1] == 2022 .and. arr_m[3] == 12
      kds := 21    // !!! ВНИМАНИЕ -проверить
      kdr := 22  
    elseif arr_m[1] == 2023 .and. arr_m[3] == 12
      kds := 21    // !!! ВНИМАНИЕ -проверить
      kdr := 22   
    elseif arr_m[1] == 2024 .and. arr_m[3] == 12
      kds := 21    // !!! ВНИМАНИЕ -проверить
      kdr := 22    
    endif
  //////////////////////////////
  mdate_rak := arr_m[6] + kdr
  //////////////////////////////
  dbcreate(cur_dir() + 'tmp', {{'shifr', 'C', 20, 0}, ;
                          {'usl_ok', 'N', 1, 0}, ;
                          {'tip', 'N', 1, 0}, ;
                          {'profil', 'N', 3, 0}, ;
                          {'kv', 'N', 6, 0}, ;
                          {'kd', 'N', 6, 0}})
  use (cur_dir() + 'tmp') new
  index on str(usl_ok, 1) + str(tip, 1) + shifr + str(profil, 3) to (cur_dir() + 'tmp')
  if m1uslov == 1
    R_Use(dir_server + "mo_xml",,"MO_XML")
    R_Use(dir_server + "mo_rak",,"RAK")
    set relation to kod_xml into MO_XML
    R_Use(dir_server + "mo_raks",,"RAKS")
    set relation to akt into RAK
    R_Use(dir_server + "mo_raksh",,"RAKSH")
    set relation to kod_raks into RAKS
    index on str(kod_h, 7) to (cur_dir() + "tmp_raksh") for mo_xml->DFILE <= mdate_rak
  endif
  R_Use(dir_server + "str_komp",,"SK")
  R_Use(dir_server + "komitet",,"KM")
  R_Use(dir_server + "mo_su",,"MOSU")
  R_Use(dir_server + "mo_hu",dir_server + "mo_hu","MOHU")
  set relation to u_kod into MOSU
  R_Use(dir_server + "uslugi",,"USL")
  R_Use(dir_server + "human_u",dir_server + "human_u","HU")
  set relation to u_kod into USL
  R_Use(dir_server + "schet_",,"SCHET_")
  R_Use(dir_server + "schet",,"SCHET")
  set relation to recno() into SCHET_
  R_Use(dir_server + "human_",,"HUMAN_")
  R_Use(dir_server + "human",dir_server + "humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(arr_m[5]),.t.)
  do while human->k_data <= arr_m[6] .and. !eof()
    UpdateStatus()
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    fl := (human_->USL_OK < 3 .and. ; // стационар
           human_->oplata != 9 .and. ; // не перевыставлен
           human->komu < 5)            // не личный счёт
    if fl .and. human->komu == 1 .and. human->str_crb > 0
      sk->(dbGoto(human->str_crb))
      fl := !eq_any(sk->ist_fin,I_FIN_PLAT,I_FIN_DMS)
    elseif fl .and. human->komu == 3 .and. human->str_crb > 0
      km->(dbGoto(human->str_crb))
      fl := !eq_any(km->ist_fin,I_FIN_PLAT,I_FIN_DMS)
    endif
    if fl .and. m1uslov < 2 .and. (fl := human->schet > 0)
      select SCHET
      goto (human->schet)
      if (fl := schet_->IS_DOPLATA == 0 .and. !empty(val(schet_->smo)) .and. schet_->NREGISTR == 0) // только зарегистрированные
        // дата регистрации
        mdate := date_reg_schet()
        // дата отчетного периода
        mdate1 := stod(strzero(schet_->nyear, 4)+strzero(schet_->nmonth, 2)+"15")
        //
        fl := between(mdate,arr_m[5],arr_m[6]+kds) .and. between(mdate1,arr_m[5],arr_m[6]) // !!отч.период
        if fl .and. m1uslov == 1 // как в 14-МЕД
          koef := 1 ; k := j := 0
          select RAKSH
          find (str(human->kod, 7))
          do while human->kod == raksh->kod_h .and. !eof()
            if !empty(raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP)
              ++j
            endif
            k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
            skip
          enddo
          if !empty(round(k, 2))
            if empty(human->cena_1) // скорая помощь
              koef := 0
            elseif round_5(human->cena_1, 2) <= round_5(k, 2) // полное снятие
              koef := 0
            else // частичное снятие
              koef := (human->cena_1-k)/human->cena_1
            endif
          endif
          fl := (koef > 0)
        endif
      endif
    endif
    if fl // не платный больной
      kodKSG := ""
      select HU
      find (str(human->kod, 7))
      do while hu->kod == human->kod .and. !eof()
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if is_ksg(lshifr)
            kodKSG := lshifr ; exit
          endif
        endif
        select HU
        skip
      enddo
      au := {}
      select MOHU
      find (str(human->kod, 7))
      do while mohu->kod == human->kod .and. !eof()
        aadd(au,{mosu->shifr1,mohu->kod_diag,mohu->profil})
        skip
      enddo
      mprofil := human_->profil
      if empty(au)
        s := human->kod_diag
        mtip := 1
      else
        s := au[1, 1] // взять шифр первой операции
        mtip := 2
        if len(au) > 1 // если более одной операции
          asort(au,,,{|x,y| x[1] < y[1] } )
          for i := len(au) to 1 step -1
            if mprofil != au[i, 3] .or. !(padr(human->kod_diag, 5)==padr(au[i, 2], 5))
              del_array(au,i) // удалить не тот профиль и не тот диагноз
            endif
          next
          if len(au) > 0
            s := au[1, 1] // взять шифр первой операции из оставшихся
          endif
        endif
      endif
      select TMP
      find (str(human_->USL_OK, 1)+str(mtip, 1)+padr(s, 20)+str(mprofil, 3))
      if !found()
        append blank
        tmp->USL_OK := human_->USL_OK
        tmp->shifr := s
        tmp->tip := mtip
        tmp->profil := mprofil
      endif
      if human->VZROS_REB == 0
        tmp->kv ++
      else
        tmp->kd ++
      endif
      if !empty(kodKSG)
        select TMP
        find (str(human_->USL_OK, 1)+str(3, 1)+padr(kodKSG, 20)+str(mprofil, 3))
        if !found()
          append blank
          tmp->USL_OK := human_->USL_OK
          tmp->shifr := kodKSG
          tmp->tip := 3
          tmp->profil := mprofil
        endif
        if human->VZROS_REB == 0
          tmp->kv ++
        else
          tmp->kd ++
        endif
      endif
    endif
    select HUMAN
    skip
  enddo
  close databases
  Use_base("lusl")
  Use_base("luslf")
  R_Use(dir_exe() + "_mo_mkb",cur_dir() + "_mo_mkb","DIAG")
  use (cur_dir() + "tmp") index (cur_dir() + "tmp") new
  arr_title := {;
"───────────────────────────────────────────────────────────╥──────╥──────┬──────", ;
"                                                           ║Случаи║в т.ч.│в т.ч.", ;
" Профиль койки                                             ║всего ║взросл│дети  ", ;
"───────────────────────────────────────────────────────────╨──────╨──────┴──────"}
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string(glob_mo[_MO_SHORT_NAME])
  add_string("")
  add_string(center('случаи '+arr_m[4],sh))
  if m1uslov == 0
    add_string(center('(по зарегистрированным счетам)',sh))
  elseif m1uslov == 1
    add_string(center('(по зарегистрированным счетам с учётом РАК)',sh))
  else
    add_string(center('(без учёта платных услуг и ДМС)',sh))
  endif
  for iusl_ok := 1 to 2
    add_string("")
    add_string(center('Данные об объёмах при оказании медицинской помощи',sh))
    add_string(center('в '+{'круглосуточном','дневном'}[iusl_ok]+' стационаре в разрезе профилей',sh))
    aeval(arr_title, {|x| add_string(x) } )
    au := {}
    select TMP
    find (str(iusl_ok, 1))
    do while tmp->usl_ok == iusl_ok .and. !eof()
      if tmp->profil > 0 .and. tmp->tip < 3
        if (i := ascan(au, {|x| x[1] == tmp->profil})) == 0
          aadd(au,{tmp->profil,"", 0, 0}) ; i := len(au)
          if (j := ascan(getV002(), {|x| x[2] == tmp->profil})) > 0
            au[i, 2] := getV002()[j, 1]
          else
            au[i, 2] := "профиль "+lstr(tmp->profil)
          endif
        endif
        au[i, 3] += tmp->kv
        au[i, 4] += tmp->kd
      endif
      skip
    enddo
    asort(au,,,{|x,y| upper(x[2]) < upper(y[2]) } )
    sv := sd := 0
    for i := 1 to len(au)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(padr(au[i, 2], 59)+put_val(au[i, 3]+au[i, 4], 7)+put_val(au[i, 3], 7)+put_val(au[i, 4], 7))
      sv += au[i, 3]
      sd += au[i, 4]
    next
    add_string(replicate("─",sh))
    add_string(padr("Всего:", 59)+put_val(sv+sd, 7)+put_val(sv, 7)+put_val(sd, 7))
    arr_title[2] := padr("Наименование КСГ", 59)+substr(arr_title[2], 60)
    lal := "lusl"
    lal := create_name_alias(lal, arr_m[1])

    verify_FF(HH-6,.t.,sh)
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    old := space(20)
    select TMP
    find (str(iusl_ok, 1)+"3")
    do while tmp->usl_ok == iusl_ok .and. tmp->tip == 3 .and. !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if !(old == padr(tmp->shifr, 20))
        dbselectarea(lal)
        find (padr(tmp->shifr, 10))
        add_string(alltrim(tmp->shifr)+" "+alltrim(&lal.->name))
      endif
      old := padr(tmp->shifr, 20)
      if (j := ascan(getV002(), {|x| x[2] == tmp->profil})) > 0
        s := getV002()[j, 1]
      else
        s := "профиль "+lstr(tmp->profil)
      endif
      add_string(padr("- "+s, 59)+put_val(tmp->kv+tmp->kd, 7)+put_val(tmp->kv, 7)+put_val(tmp->kd, 7))
      select TMP
      skip
    enddo
    arr_title[2] := padr(" Основной диагноз (терапевтическая группа КСГ)", 59)+substr(arr_title[2], 60)
    verify_FF(HH-6,.t.,sh)
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    old := space(5)
    select TMP
    find (str(iusl_ok, 1)+"1")
    do while tmp->usl_ok == iusl_ok .and. tmp->tip == 1 .and. !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if !(old == padr(tmp->shifr, 5))
        select DIAG
        find (padr(tmp->shifr, 5))
        add_string(rtrim(left(tmp->shifr, 5))+" "+alltrim(diag->name))
      endif
      old := padr(tmp->shifr, 5)
      if (j := ascan(getV002(), {|x| x[2] == tmp->profil})) > 0
        s := getV002()[j, 1]
      else
        s := "профиль "+lstr(tmp->profil)
      endif
      add_string(padr("- "+s, 59)+put_val(tmp->kv+tmp->kd, 7)+put_val(tmp->kv, 7)+put_val(tmp->kd, 7))
      select TMP
      skip
    enddo
    arr_title[2] := padr(" Операция (хирургическая группа КСГ)", 59)+substr(arr_title[2], 60)

    lal := "luslf"
    lal := create_name_alias(lal, arr_m[1])

    verify_FF(HH-6,.t.,sh)
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    old := space(20)
    select TMP
    find (str(iusl_ok, 1)+"2")
    do while tmp->usl_ok == iusl_ok .and. tmp->tip == 2 .and. !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if !(old == padr(tmp->shifr, 20))
        dbselectarea(lal)
        find (padr(tmp->shifr, 20))
        add_string(alltrim(tmp->shifr)+" "+alltrim(&lal.->name))
      endif
      old := padr(tmp->shifr, 20)
      if (j := ascan(getV002(), {|x| x[2] == tmp->profil})) > 0
        s := getV002()[j, 1]
      else
        s := "профиль "+lstr(tmp->profil)
      endif
      add_string(padr("- "+s, 59)+put_val(tmp->kv+tmp->kd, 7)+put_val(tmp->kv, 7)+put_val(tmp->kd, 7))
      select TMP
      skip
    enddo
  next iusl_ok
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,, 5)
endif
return NIL
