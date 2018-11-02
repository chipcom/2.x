***** mo_omsna.prg - диспансерное наблюдение
#include "inkey.ch"
#include "..\_mylib_hbt\fastreph.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1

***** 28.10.18 Диспансерное наблюдение
Function disp_nabludenie(k)
Static si1 := 1, si2 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    Private file_form, mdate_r, M1VZROS_REB, diag1 := {}, len_diag := 0
    if (file_form := search_file("DISP_NAB"+sfrm)) == NIL
      return func_error(4,"Не обнаружен файл DISP_NAB"+sfrm)
    endif
    mas_pmt := {"Первичный ~ввод",;
                "~Информация",;
                "~Обмен с ТФОМС"}
    mas_msg := {"Первичный ввод сведений о состоящих на диспансерном учёте в Вашей МО",;
                "Информация по первичному вводу сведений о состоящих на диспансерном учёте",;
                "Обмен с ТФОМС информацией по диспансерному наблюдению"}
    mas_fun := {"disp_nabludenie(11)",;
                "disp_nabludenie(12)",;
                "disp_nabludenie(13)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    vvod_disp_nabl()
  case k == 12
    mas_pmt := {"~Пациенты с диагнозами для диспансерного учёта"}
    mas_msg := {"Список пациентов с диагнозами, обязательными для диспансерного учёта (за 2 года)"}
    mas_fun := {"disp_nabludenie(21)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 13
    obmen_disp_nabl()
  case k == 21
    inf_disp_nabl()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  endif
endif
return NIL

***** 29.10.18 Первичный ввод сведений о состоящих на диспансерном учёте в Вашей МО
Function vvod_disp_nabl()
Local buf := savescreen(), k, s, t_arr := array(BR_LEN)
Private str_find, muslovie
G_Use(dir_server+"mo_dnab",,"DN")
index on str(KOD_K,7)+KOD_DIAG to (cur_dir+"tmp_dnab")
use
if input_perso(T_ROW,T_COL-5)
  k := -ret_new_spec(glob_human[7],glob_human[8])
  box_shadow(0,0,2,49,color13,,,0)
  @ 0,0 say padc("["+lstr(glob_human[5])+"] "+glob_human[2],50) color color8
  @ 1,0 say padc(ret_tmp_prvs(k),50) color color14
  do while .t. 
    @ 2,0 say padc("... Выбор пациента ...",50) color color1
    k := polikl1_kart()
    close databases
    //
    R_Use(dir_server+"kartotek",,"_KART")
    if k == 0
      exit
    else
      goto (glob_kartotek)
      s := alltrim(padr(_kart->fio,37))+" ("+full_date(_kart->date_r)+")"
      @ 2,0 say padc(s,50) color color1
      mdate_r := _kart->date_r ; M1VZROS_REB := _kart->VZROS_REB
      fv_date_r(sys_date) // переопределение M1VZROS_REB
      if M1VZROS_REB > 0
        func_error(4,"Данный режим только для взрослых, а выбранный пациент пока РЕБЁНОК!")
      else
        str_find := str(glob_kartotek,7) ; muslovie := "dn->kod_k == glob_kartotek"
        t_arr[BR_TOP] := T_ROW
        t_arr[BR_BOTTOM] := maxrow()-2
        t_arr[BR_LEFT] := 2
        t_arr[BR_RIGHT] := maxcol()-2
        t_arr[BR_COLOR] := color0
        t_arr[BR_ARR_BROWSE] := {,,,,.t.}
        t_arr[BR_OPEN] := {|nk,ob| f1_vvod_disp_nabl(nk,ob,"open") }
        t_arr[BR_ARR_BLOCK] := {{| | FindFirst(str_find)},;
                                {| | FindLast(str_find)},;
                                {|n| SkipPointer(n, muslovie)},;
                                str_find,muslovie;
                               }
        t_arr[BR_COLUMN] := {{"Диагноз;заболевания",{|| dn->kod_diag }}}
        aadd(t_arr[BR_COLUMN],{"   Дата;постановки; на учёт",{|| full_date(dn->n_data) }})
        aadd(t_arr[BR_COLUMN],{"   Дата;следующего;посещения",{|| full_date(dn->next_data) }})
        aadd(t_arr[BR_COLUMN],{"Место проведения;диспансерного;наблюдения",{|| iif(empty(dn->kod_diag),space(7),iif(dn->mesto==0," в МО  ","на дому")) }})
        t_arr[BR_EDIT] := {|nk,ob| f1_vvod_disp_nabl(nk,ob,"edit") }
        G_Use(dir_server+"mo_dnab",cur_dir+"tmp_dnab","DN")
        edit_browse(t_arr)
      endif
    endif
    close databases
  enddo
endif
close databases
restscreen(buf)
return NIL

***** 29.10.18
Function f1_vvod_disp_nabl(nKey,oBrow,regim)
Local ret := -1
Local buf, fl := .f., rec := 0, rec1, r1, r2, tmp_color
Local bg := {|o,k| get_MKB10(o,k,.t.) }
Local mm_dom := {{"в МО   ",0},;
                 {"на дому",1}}
do case
  case regim == "open"
    find (str_find)
    ret := found()
  case regim == "edit"
    do case
      case nKey == K_INS .or. (nKey == K_ENTER .and. dn->kod_k > 0)
        if nKey == K_ENTER .and. dn->vrach != glob_human[1]
          func_error(4,"Данная строка введена другим врачом!")
          return ret
        endif
        if nKey == K_ENTER
          rec := recno()
        endif
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+5,pc1,pr1+5,pc2,"N/N","W+/N")
        endif
        Private gl_area := {1,0,maxrow()-1,79,0}, ;
                mKOD_DIAG := iif(nKey == K_INS, space(5), dn->kod_diag),;
                mN_DATA := iif(nKey == K_INS, sys_date-1, dn->n_data),;
                mNEXT_DATA := iif(nKey == K_INS, 0d20181202, dn->next_data),;
                mMESTO, m1mesto := iif(nKey == K_INS, 0, dn->mesto)
        mmesto := inieditspr(A__MENUVERT, mm_dom, m1mesto)
        r1 := pr2-6 ; r2 := pr2-1
        tmp_color := setcolor(cDataCScr)
        box_shadow(r1,pc1+1,r2,pc2-1,,iif(nKey == K_INS,"Добавление","Редактирование"),cDataPgDn)
        setcolor(cDataCGet)
        do while .t.               
          @ r1+1,pc1+3 say "Диагноз, по поводу которого пациент подлежит дисп.наблюдению" get mkod_diag ;
                       pict "@K@!" reader {|o|MyGetReader(o,bg)} ;
                       valid val1_10diag(.t.,.f.,.f.,0d20181201,_kart->pol)
          @ r1+2,pc1+3 say "Дата начала диспансерного наблюдения" get mn_data
          @ r1+3,pc1+3 say "Дата следующей явки с целью диспансерного наблюдения" get mnext_data
          @ r1+4,pc1+3 say "Место проведения диспансерного наблюдения" get mmesto ;
                       reader {|x|menu_reader(x,mm_dom,A__MENUVERT,,,.f.)} 
          status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода")
          myread()
          if lastkey() != K_ESC .and. f_Esc_Enter(1)
            mKOD_DIAG := padr(mKOD_DIAG,5)
            fl := .t.
            if empty(mKOD_DIAG)
              fl := func_error(4,"Не введён диагноз")
            elseif !f2_vvod_disp_nabl(mKOD_DIAG)
              fl := func_error(4,"Диагноз не входит в список допустимых из Приказа КЗ и ТФОМС")
            else
              select DN
              find (str(glob_kartotek,7))
              do while dn->kod_k == glob_kartotek .and. !eof()
                if rec != recno() .and. mKOD_DIAG == dn->kod_diag
                  fl := func_error(4,"Данный диагноз уже введён для данного пациента")
                  exit
                endif
                skip
              enddo
            endif
            if empty(mN_DATA)
              fl := func_error(4,"Не введена дата начала диспансерного наблюдения")
            elseif mN_DATA >= 0d20181201
              fl := func_error(4,"Дата начала диспансерного наблюдения слишком большая")
            endif
            if empty(mNEXT_DATA)
              fl := func_error(4,"Не введена дата следующей явки")
            elseif mN_DATA >= mNEXT_DATA
              fl := func_error(4,"Дата следующей явки меньше даты начала диспансерного наблюдения")
            elseif mNEXT_DATA <= 0d20181201
              fl := func_error(4,"Дата следующей явки должна быть не ранее 1 декабря")
            endif
            if !fl
              loop
            endif
            select DN
            if nKey == K_INS
              fl_found := .t.
              AddRec(7)
              dn->kod_k := glob_kartotek
              rec := recno()
            else
              goto (rec)
              G_RLock(forever)
            endif
            dn->vrach := glob_human[1]
            dn->prvs  := iif(empty(glob_human[8]), glob_human[7], -glob_human[8])
            dn->kod_diag := mKOD_DIAG
            dn->n_data := mN_DATA
            dn->next_data := mNEXT_DATA
            dn->mesto := m1mesto
            UnLock
            COMMIT
            oBrow:goTop()
            goto (rec)
            ret := 0
          elseif nKey == K_INS .and. !fl_found
            ret := 1
          endif
          exit
        enddo
        select DN
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. dn->kod_k == glob_kartotek .and. f_Esc_Enter(2)
        DeleteRec()
        oBrow:goTop()
        ret := 0
        if eof() .or. !&muslovie
          ret := 1
        endif
    endcase
endcase
return ret

***** 29.10.18 Информация по первичному вводу сведений о состоящих на диспансерном учёте
Function f2_vvod_disp_nabl(ldiag)
Local fl := .f., lfp, i, s, d1, d2
if len_diag == 0
  lfp := fopen(file_form)
  do while !feof(lfp)
    UpdateStatus()
    s := fReadLn(lfp)
for i := 1 to len(s) // проверка на русские буквы в диагнозах
  if ISRALPHA(substr(s,i,1))
    strfile(s+eos,"ttt.ttt",.t.)
    exit
  endif
next
    if "-" $ s
      d1 := token(s,"-",1)
      d2 := token(s,"-",2)
    else
      d1 := d2 := s
    endif
    aadd(diag1, {1,{{diag_to_num(d1,1),diag_to_num(d2,2)}}} )
  enddo
  fclose(lfp)
  len_diag := len(diag1)
endif  
return !(ret_f_14(ldiag) == NIL)

***** 01.11.18 Информация по первичному вводу сведений о состоящих на диспансерном учёте
Function inf_disp_nabl()
Static su := 0
Local ku, i, adiagnoz, ar, sh := 80, HH := 60, buf := save_maxrow(), name_file := "disp_nabl"+stxt,;
      s, c1, cv := 0, cf := 0, fl_exit := .f.
if (ku := input_value(20,20,22,59,color1,space(6)+"Введите номер участка",su,"99")) == NIL
  return NIL
endif
su := ku
stat_msg("Поиск информации...")
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("Список пациентов с диагнозами, обязательными для диспансерного учёта (за 2 года)",sh))
add_string(center("участок № "+lstr(ku),sh))
add_string("")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
R_Use_base("kartotek")
set order to 4
find (strzero(ku,2))
index on upper(fio) to (cur_dir+"tmp_kart") ;
      for kart->kod > 0 .and. kart2->MO_PR == glob_mo[_MO_KOD_TFOMS] .and. !(left(kart2->PC2,1) == "1") ;
      while ku == uchast
go top      
do while !eof()
  @ maxrow(),1 say lstr(++cv) color cColorSt2Msg
  @ row(),col() say "/" color "W/R"
  c1 := col()
  @ row(),c1 say lstr(cf) color cColorStMsg
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if kart->kod > 0 .and. kart2->MO_PR == glob_mo[_MO_KOD_TFOMS] .and. !(left(kart2->PC2,1) == "1")
    mdate_r := kart->date_r ; M1VZROS_REB := kart->VZROS_REB
    fv_date_r(sys_date) // переопределение M1VZROS_REB
    if M1VZROS_REB == 0
      ar := {} 
      select HUMAN
      find (str(kart->kod,7))
      do while human->kod_k == kart->kod .and. !eof()
        if human->k_data > 0d20161231 // т.е. последние два года и не скорая помощь
          human_->(dbGoto(human->(recno())))
          if human_->USL_OK < 4
            adiagnoz := diag_to_array()
            for i := 1 to len(adiagnoz)
              if !empty(adiagnoz[i]) .and. f2_vvod_disp_nabl(adiagnoz[i])
                s := padr(adiagnoz[i],5)
                if ascan(ar,s) == 0
                  aadd(ar,s)
                endif
              endif
            next i
          endif
        endif 
        select HUMAN
        skip
      enddo
      if len(ar) > 0
        s2 := "" 
        if mem_kodkrt == 2
          s2 := "["
          if is_uchastok > 0
            s2 += alltrim(kart->bukva)
            s2 += lstr(kart->uchast,2)+"/"
          endif
          if is_uchastok == 1
            s2 += lstr(kart->kod_vu)
          elseif is_uchastok == 3
            s2 += alltrim(kart2->kod_AK)
          else
            s2 += lstr(kart->kod)
          endif
          s2 += "] "
        endif
        verify_FF(HH,.t.,sh)
        add_string(left(s2+alltrim(kart->fio)+" д.р."+full_date(kart->date_r),99))
        add_string(left("  "+arr2Slist(ar),99))
        if empty(kart_->okatop)
          add_string(left("  "+ret_okato_ulica(kart->adres,kart_->okatog,0,2),99))
        else
          add_string(left("  "+ret_okato_ulica(kart_->adresp,kart_->okatop,0,2),99))
        endif
        @ row(),c1 say lstr(++cf) color cColorStMsg
      endif
    endif
  endif
  select KART
  skip
enddo
if fl_exit
  add_string("*** "+expand("ОПЕРАЦИЯ ПРЕРВАНА"))
elseif empty(cf)
  add_string("Не обнаружено запрашиваемых пациентов по данному участку.")
endif
close databases
fclose(fp)
viewtext(name_file,,,,.t.,,,2)
rest_box(buf)  
return NIL

***** 28.10.18 Обмен с ТФОМС информацией по диспансерному наблюдению
Function obmen_disp_nabl()
return func_error(4,"Функция будет реализована к декабрю 2018 года!")
