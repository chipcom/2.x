***** mo_263s.prg - режимы стационара для задачи по приказу 263-ФФОМС
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 01.08.14 Проверка того, что ещё не сделано в стационаре
Function _263_s_proverka()
ne_real()
return NIL

***** 08.03.17 добавление / редактирование госпитализаций в стационаре
Function for_263_s_gospit()
Local fl := (KOD_F_4out >= 0 .and. TYPE_H_4 > 0)
if fl
  fl := between(date_h_4,arr_m[5],arr_m[6])
endif
if fl .and. not_out
  fl := empty(KOD_F_4out)
endif
return fl

***** 08.03.17 добавление / редактирование госпитализаций в стационаре
Function _263_s_gospit()
Static str_sem := "_263_s_gospit", si := 2
Local buf := save_maxrow(), blk, t_arr[BR_LEN], fl, i, n
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
if (i := popup_prompt(T_ROW,T_COL+5,si,;
            {"Добавить ~госпитализацию",;
             "Поиск по ~дате госпитализации"})) == 0
  G_SUnLock(str_sem)
  return NIL
endif
Private arr_m, not_out := .f.
if (si := i) == 1
  if !_263_edit_s_gospit(K_INS)
    G_SUnLock(str_sem)
    return NIL
  endif
elseif si == 2 
  if (arr_m := year_month(T_ROW,T_COL+5)) == NIL
    G_SUnLock(str_sem)
    return NIL
  endif
  if (i := popup_prompt(T_ROW,T_COL+5,1,{"Все ~госпитализации","Ещё ~не отправленные в ТФОМС"})) == 2
    not_out := .t.
  endif
endif
mywait()
R_Use(dir_server+"kartotek",,"_KART")
R_Use(dir_server+"mo_nfile",,"NF")
G_Use(dir_server+"mo_nnapr",,"NAPR")
set relation to kod_k into _KART, to KOD_F_4out into NF
index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
      for for_263_s_gospit()
go top
if eof()
  close databases
  G_SUnLock(str_sem)
  rest_box(buf)
  return func_error(4,"Не обнаружено госпитализаций "+arr_m[4])
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_TITUL] := "Госпитализации "+arr_m[4]
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B,RB/BG,W+/RB,R/BG,W+/R,N+/BG",.t.}
blk := {|| iif(empty(napr->KOD_F_4out), {3,4}, ;
               iif(napr->t_ans_4==1.or.napr->KOD_F_4out<0, {1,2}, ;
                   iif(napr->t_ans_4==0, {5,6}, {7,8} ))) }
n := iif(work_otd_263 == 1, 20, 26)
t_arr[BR_COLUMN] := {{" Ф.И.О.", {|| padr(iif(empty(_kart->fio),"код "+lstr(napr->kod_k),_kart->fio),n) }, blk },;
                     {" Откуда поступил", {|| padr(f0_263_s_gospit(),17) }, blk },;
                     {" ", {|| iif(napr->usl_ok_4==2,"д","с") }, blk },;
                     {"  Дата;госп-ии", {|| date_8(napr->date_h_4) }, blk },;
                     {" Статус", {|| padr(f1_263_s_gospit(),22) }, blk }}
if work_otd_263 == 1
  Ins_Array(t_arr[BR_COLUMN],4,{" Отд.", {|| _263_put_otd(napr->otd_4) }, blk })
endif
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход ^<Enter>^ просмотр/ред-ие инф-ии по госпитализации ^<Del>^ удаление") }
t_arr[BR_EDIT] := {|nk,ob| f2_263_s_gospit(nk,ob,"edit") }
edit_browse(t_arr)
close databases
G_SUnLock(str_sem)
rest_box(buf)
return NIL

*

***** 21.02.17
Function f0_263_s_gospit()
Local s := ""
do case
  case napr->TYPE_H_4 == 1 // госп-ия: 1-по направлению
    s := "напр"
    if napr->CODEM_FROM == glob_mo[_MO_KOD_TFOMS]
      s += "-ие из нашей п-ки"
    elseif empty(napr->CODEM_FROM)
      s += napr->NUM_D
    else
      s += ret_mo(napr->CODEM_FROM)[_MO_SHORT_NAME]
    endif
  case napr->TYPE_H_4 == 2 // госп-ия: 2-перевод из другого МО
    if !empty(napr->CODEM_FROM)
      s := "из "+ret_mo(napr->CODEM_FROM)[_MO_SHORT_NAME]
    endif
  case napr->TYPE_H_4 == 3 // госп-ия: 3-перевод внутри нашего МО
    s := "внутри нашего МО"
  case napr->TYPE_H_4 == 4 // госп-ия: 4-экстр./неотл. (I05)
    s := inieditspr(A__MENUVERT,glob_V014,napr->F_MEDC_4)+" госпитализация"
endcase
return s

***** 19.02.17
Function f1_263_s_gospit()
Local s := "ошибка"
if empty(napr->KOD_F_4out)
  s := "ещё не отправлено в ТФОМС"
elseif napr->t_ans_4 == 0
  if napr->KOD_F_4out < 0
    s := "госп-ия в др.стационар"
  else
    s := "не получен ответ из ТФОМС"
  endif
elseif napr->t_ans_4 == 1
  s := "получен ответ из ТФОМС"
  if napr->KOD_F_6out > 0
    s := " выбытие "+date_8(napr->date_6)
  elseif napr->KOD_F_4out > 0
    s := "отправлено в ТФОМС"
  endif
endif
return s

*

***** 19.02.17
Function f2_263_s_gospit(nKey,oBrow,regim)
Local ret := -1, fl, rec
do case
  case regim == "edit"
    if nKey == K_ENTER
      if _263_edit_s_gospit(K_ENTER)
        ret := 0
      else
        ret := 1
      endif
    elseif nKey == K_DEL // удаление
      if empty(napr->KOD_F_4out) .or. napr->t_ans_4 == 2
        fl := .t.
        select NAPR
        do case
          case napr->TYPE_H_4 == 1 // госп-ия: 1-по направлению
            if napr->KOD_PP > 0
              // fl := .f. проверим БД приёмного покоя
            endif
            if fl .and. f_Esc_Enter(2,.t.)
              G_RLock(forever)
              napr->CODEM_FROM := ""          // из какого МО направлен (п-ка, другой стационар или наш же стационар)
              napr->KOD_UP     := 0           // код пред.направления (после перевода в др.отд-ие)
              napr->KOD_PP     := 0           // код по БД приёмного покоя
              napr->TYPE_H_4   := 0           // госп-ия: 1-по направлению, 2-перевод из другого МО, 3-перевод внутри нашего МО, 5-экстр./неотл. (I05)
              napr->DATE_H_4   := ctod("")    // реальная дата госпитализации
              napr->TIME_H_4   := ""          // время госпитализации
              napr->DNEJ_H_4   := 0       
              napr->usl_ok_4   := 0       
              napr->ID_4       := ""          // GUID+lstr(mo_nnapr->KOD) ID госпитализации для tip_f=4 или 5
              napr->PROFIL_4   := 0           // профиль мед.помощи по справочнику V002
              napr->PROFIL_K_4 := 0           // профиль койки по справочнику T007
              napr->DS_4       := ""          // диагноз приёмного отделения стационара
              napr->F_MEDC_4   := 0           // форма оказания мед.помощи по V014 (1-экстренная, 2-неотложная, 3-плановая)
              napr->NUM_HIST_4 := ""          // номер истории болезни
              napr->T_ANS_4    := 0           // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
              napr->KOD_F_4out := 0           // код файла - по файлу mo_nfile
              napr->KOD_F_4in  := 0           //_код файла - по файлу mo_nfile
              go top
              ret := 1
            endif
          case napr->TYPE_H_4 == 2 // госп-ия: 2-перевод из другого МО
            if f_Esc_Enter(2,.t.)
              DeleteRec()
              go top
              ret := 1
            endif
          case napr->TYPE_H_4 == 3 // госп-ия: 3-перевод внутри нашего МО
            rec := 0
            if napr->KOD_UP > 0
              rec := napr->KOD_UP
              // fl := .f. указать, что уже выписан и отправлен в ТФОМС
            endif
            if fl .and. f_Esc_Enter(2,.t.)
              DeleteRec()
              if rec > 0
                set index to
                goto (rec)
                G_RLock(forever)
                napr->TYPE_6 := 0         // выбытие: 1-выписан, 2-умер, 3-перевод внутри нашего МО
                napr->KOD_NEXT := 0       // код следующей госпитализации (после перевода в др.отд-ие)
                napr->ID_6 := ""          // GUID+lstr(mo_nnapr->KOD) ID выписки для tip_f=6
                napr->DATE_6 := ctod("")  // дата выбытия
                napr->T_ANS_6 := 0        // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
                napr->KOD_F_6out := 0     //_код файла - по файлу mo_nfile
                napr->KOD_F_6in := 0      //_код файла - по файлу mo_nfile
              endif
              go top
              ret := 1
            endif
          case napr->TYPE_H_4 == 4 // госп-ия: 4-экстр./неотл. (I05)
            if f_Esc_Enter(2,.t.)
              DeleteRec()
              go top
              ret := 1
            endif
        endcase
      else
        if napr->KOD_F_4out < 0
          s := "Это наш пациент госпитализирован в другой стационар"
        else
          s := "Ответ из ТФОМС "+iif(napr->t_ans_4==0,"ещё не","уже")+" получен"
        endif
        func_error(4,s+". Удаление запрещено!")
      endif
    else
      keyboard ""
    endif
endcase
return ret

*

***** 19.02.17 работа с направлениями на госпитализацию в стационаре
Function _263_edit_s_gospit(nKey)
Static sk := 1
Local bg := {|o,k| get_MKB10(o,k) }
Local flag := .t., i, k, mm_forma, s_error := "", tmp_color := setcolor(), buf := savescreen(),;
      tmp_V006 := {{"Стационар",1},{"Дневной стационар",2}}
Private mkod := iif(nKey == K_INS, 0, napr->KOD),;
        m1kod_k := iif(nKey == K_INS, 0, napr->kod_k),; // код по картотеке
        mfio    := iif(nKey == K_INS, "", _kart->fio),;
        mdate_r := iif(nKey == K_INS, ctod(""), _kart->date_r),;
        mpol    := iif(nKey == K_INS, "", _kart->pol),;
        mnum_d  := iif(nKey == K_INS, "", napr->NUM_D),;
        md_napr := iif(nKey == K_INS, ctod(""), napr->DATE_D),; // дата направления
        motd := space(10), m1otd := if(nKey == K_INS, 0, napr->otd_4),;
        mCODEM_FROM, m1CODEM_FROM := iif(nKey == K_INS, "", napr->CODEM_FROM),;
        mkod_diag := iif(nKey == K_INS, "", napr->ds_4),; // диагноз
        musl_ok, m1usl_ok := iif(nKey==K_INS.or.napr->usl_ok_4!=2, 1, napr->usl_ok_4),; // условия оказания мед.помощи
        mforma, m1forma := iif(nKey == K_INS, 2, napr->F_MEDC_4),; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
        mdate_h := iif(nKey == K_INS, sys_date, napr->DATE_H_4),; // дата госпитализации
        mtime_h := iif(nKey == K_INS, "11:00", napr->TIME_H_4),; // время госпитализации
        mprofil_k, m1profil_k := iif(nKey == K_INS, 0, napr->PROFIL_K_4),; // профиль койки по справочнику T007
        mprofil, m1profil := iif(nKey == K_INS, 0, napr->PROFIL_4),; // профиль мед.помощи по справочнику V002
        mnum_hist := iif(nKey == K_INS, space(10), left(napr->NUM_HIST_4,10)),;
        mTYPE_H_4 := iif(nKey == K_INS, 0, napr->TYPE_H_4),;
        mDNEJ_H_4 := iif(nKey == K_INS, 0, napr->DNEJ_H_4),;
        mTIP_ANNUL := iif(nKey == K_INS, 0, napr->TIP_ANNUL),;
        mdate_3 := iif(nKey == K_INS, ctod(""), napr->date_3)
if nKey == K_INS
  if (k := popup_prompt(T_ROW,T_COL+5,sk,;
            {"на основании ~направления из поликлиники",;
             "переводом из другого ~стационара",;
             "переводом из другого ~отделения нашего МО",;
             "по неотложным или ~экстренным показаниям"})) == 0
    return .f.
  endif
  sk := mTYPE_H_4 := k
  do case
    case sk == 1 // на основании направления
      if (mkod := _263_input_napr()) > 0
        R_Use(dir_server+"mo_nnapr",,"NAPR")
        goto (mkod)
        m1kod_k := napr->kod_k
        mnum_d := napr->NUM_D
        md_napr := napr->DATE_D // дата направления
        m1otd := napr->otd_1
        m1CODEM_FROM := napr->CODEM_1 // код поликлиники
        mkod_diag := napr->ds_1
        m1usl_ok := napr->usl_ok_1 // переносим условия из направления поликлиники и не меняем
        m1forma :=  napr->F_MEDC_1
        mdate_h :=  napr->DATE_H_1
        m1profil_k :=  napr->PROFIL_K_1
        m1profil :=  napr->PROFIL_1
        mTIP_ANNUL := napr->TIP_ANNUL
        mdate_3 := napr->date_3
      else
        flag := .f.
      endif
    case sk == 2 // переводом из другого стационара
      k := f_get_mo(,T_ROW,T_COL+5)
      if k == NIL .or. empty(k[1])
        flag := .f.
      elseif k[1] == glob_mo[_MO_KOD_TFOMS]
        flag := func_error(4,"Нельзя выбирать наше МО - необходимо выбрать другой стационар!")
      else
        m1CODEM_FROM := k[1]
        if (k := polikl1_kart()) > 0
          m1kod_k := k
        else
          flag := .f.
        endif
      endif
    case sk == 3 // переводом из другого отделения нашего МО
      flag := func_error(4,'Воспользуйтесь режимом "Стационар/Выписка (выбытие)"')
    case sk == 4 // по неотложным или экстренным показаниям
      if (k := polikl1_kart()) > 0
        m1kod_k := k
      else
        flag := .f.
      endif
  endcase
  close databases // если вдруг вышли из картотеки по <Esc>
  //
  if m1kod_k > 0
    R_Use(dir_server+"kartotek",,"_KART")
    goto (m1kod_k)
    mfio    := _kart->fio
    mdate_r := _kart->date_r
    mpol    := _kart->pol
  endif
  close databases
endif
if flag
  if empty(m1CODEM_FROM)
    mCODEM_FROM := space(10)
  else
    if m1CODEM_FROM == glob_mo[_MO_KOD_TFOMS]
      mCODEM_FROM := "Поликлиники нашего МО"
    else
      mCODEM_FROM := ret_mo(m1CODEM_FROM)[_MO_SHORT_NAME]
    endif
  endif
  mm_forma := aclone(glob_V014)
  if mTYPE_H_4 > 1
    Del_Array(mm_forma,3) // убираем "плановую" помощь
  endif
  mUSL_OK := inieditspr(A__MENUVERT, tmp_V006, m1USL_OK)
  mforma := inieditspr(A__MENUVERT,glob_V014,m1forma)
  mprofil_k := inieditspr(A__MENUVERT, arr_t007, M1PROFIL_K)
  mprofil := inieditspr(A__MENUVERT, glob_V002, M1PROFIL)
  if work_otd_263 == 1
    Private pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}
    make_arr_uch_otd(mdate_h)
    if (i := ascan(pr_arr,{|x| x[1] == m1otd } )) > 0
      motd := pr_arr[i,2]
    elseif nKey == K_ENTER .and. m1otd > 0
      motd := "! некорректное отделение !"
    endif
  endif
  if nKey == K_INS
    flag := .f.
  elseif napr->t_ans_4 == 2
    R_Use(dir_server+"mo_nfina",,"NFN")
    index on str(kod_n,6) to (cur_dir+"tmp_nfn") for kod_f == napr->KOD_F_4out
    find (str(napr->kod,6))
    if found()
      s_error := "ошибка "+lstr(nfn->OSHIB)+" - "+inieditspr(A__MENUVERT,glob_T008,nfn->OSHIB)
      if !empty(nfn->IM_POL)
        s_error += " (в поле "+alltrim(nfn->IM_POL)+")"
      endif
    endif
    nfn->(dbCloseArea())
    select NAPR
  endif
  Private r1 := maxrow()-15
  if work_otd_263 == 1
    --r1
  endif
  do while .t.
    setcolor(cDataCGet)
    ClrLines(r1,maxrow()-1)
    @ r1-1,0 say padc(iif(nKey == K_INS,"Добавление","Редактирование")+" госпитализации",80) color "B/B*"
    i := r1
    ++i ; @ i,1 say "Пациент" get mfio when .f.
          @ row(),col()+2 say "Дата р." get mdate_r when .f.
    do case
      case mTYPE_H_4 == 1
        ++i ; @ i,1 say "Направлен из" color color8 get mCODEM_FROM when .f.
        ++i ; @ i,1 say " направление: №" color color8 get mnum_d when .f.
              @ row(),col()+1 say "от" color color8 get md_napr when .f.
      case mTYPE_H_4 == 2
        ++i ; @ i,1 say "Переведён из" color color8 get mCODEM_FROM when .f.
      case mTYPE_H_4 == 3
        ++i ; @ i,1 say "Переведён внутри МО из стационарного отделения в стационарное отделение" color color8
      case mTYPE_H_4 == 4
        ++i ; @ i,1 say "Госпитализация по неотложным или экстренным показаниям" color color8
    endcase
    ++i ; @ i,1 say "Условия оказания, в которые направляется пациент" get musl_ok ;
                reader {|x|menu_reader(x,tmp_V006,A__MENUVERT,,,.f.)} when between(mTYPE_H_4,2,3)
    ++i ; @ i,1 say "Дата фактической госпитализации" get mdate_h
          @ row(),col() say ", время" get mtime_h pict "99:99"
    if work_otd_263 == 1
    ++i ; @ i,1 say "   госпитализирован в отделение"
      if mem_kodotd == 1
        @ row(),col()+1 get motd ;
                        reader {|x|menu_reader(x,{{|k,r,c| get_otd(k,r+1,c,.f.) }},A__FUNCTION,,,.f.)}
      else
        @ row(),col()+1 get m1otd pict "99" ;
                        when {|g| f5editkusl(g,1,10) } ;
                        valid {|g| f5editkusl(g,2,10) }
        @ row(),col()+2 get motd color color14 when .f.
      endif
    endif
    ++i ; @ i,1 say "Диагноз приёмного отделения" get mkod_diag picture "@K@!" ;
                reader {|o|MyGetReader(o,bg)} ;
                valid val1_10diag(.t.,.f.,.f.,mdate_h,mpol)
    ++i ; @ i,1 say "Форма оказания медицинской помощи" get mforma ;
                reader {|x|menu_reader(x,mm_forma,A__MENUVERT,,,.f.)} ;
                when mTYPE_H_4 > 1
    ++i ; @ i,1 say "Профиль койки" get mprofil_k ;
                reader {|x|menu_reader(x,{{|k,r,c|f_get_profil_k(k,r,c)}},A__FUNCTION,,,.f.)} ;
                valid {|g,o| f_valid_profil_k(g,o) } ;
                when mTYPE_H_4 > 1
    ++i ; @ i,1 say "Профиль медицинской помощи" get mprofil ;
                reader {|x|menu_reader(x,{{|k,r,c|f_get_profil(k,r,c,m1profil_k)}},A__FUNCTION,,,.f.)} ;
                when m1profil_k > 0 .and. mTYPE_H_4 > 1
    ++i ; @ i,1 say "Планирумый срок лечения" get mdnej_h_4 pict "999" when f1_263_edit_s_gospit()
          @ row(),col()+1 say "койко-дней"
    ++i ; @ i,1 say "Номер истории болезни" get mnum_hist pict "@!"
    if between(mTIP_ANNUL,1,3)
      s := "Предупреждение! Данное направление аннулировано в "
      if mTIP_ANNUL == 1
        s += "СМО"
      elseif mTIP_ANNUL == 2
        s += "стационаре"
      else
        s += "поликлинике"
      endif
      ++i ; @ i,1 say s+" "+date_8(mdate_3) color color8
    endif
    if !empty(s_error)
      ++i ; @ i,1 say s_error color color8
    endif
    if nKey == K_ENTER .and. !(empty(napr->KOD_F_4out) .or. napr->t_ans_4 == 2)
      s := ""
      if !empty(napr->KOD_F_4out) .and. !empty(nf->NAME_F)
        s := "(в файле "+alltrim(nf->NAME_F)+") "
      endif
      if napr->KOD_F_6in > 0 .or. (napr->KOD_F_6out > 0 .and. napr->t_ans_6 == 1;
                                                        .and. napr->CODEM_1 == glob_mo[_MO_KOD_TFOMS])
        s := "выбыл из стационара "+date_8(napr->date_6)
      endif
      ++i ; @ i,1 say s color color8
      if napr->KOD_F_4out < 0
        ++i ; @ i,1 say "стационар: "+ret_mo(napr->S_CODEM)[_MO_SHORT_NAME] color color14
        s := "Это наш пациент госпитализирован в другой стационар"
      else
        s := "Ответ из ТФОМС "+iif(napr->t_ans_4==0,"ещё не","уже")+" получен"
      endif
      stat_msg(s+". Редактирование запрещено!")
      mybell(0,ERR)
      clear_gets()
      exit
    endif
    status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода")
    myread()
    k := f_alert({padc("Выберите действие",60,".")},;
                 {" Выход без записи "," Запись "," Возврат в редактирование "},;
                 iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
    if k == 3
      loop
    elseif k == 2
      if empty(CHARREPL("0",mnum_hist,space(10)))
        func_error(4,'Не заполнен номер истории болезни')
        loop
      endif
      if empty(mdate_h)
        func_error(4,"Не введена дата госпитализации.")
        loop
      endif
      if empty(m1profil_k)
        func_error(4,"Не введен профиль койки.")
        loop
      endif
      if empty(m1profil)
        func_error(4,"Не введен профиль медицинской помощи.")
        loop
      endif
      if empty(mkod_diag)
        func_error(4,"Не введен диагноз приёмного отделения.")
        loop
      endif
      if nKey == K_INS
        G_Use(dir_server+"mo_nnapr",,"NAPR")
        if mTYPE_H_4 == 1
          goto (mkod)
          G_RLock(forever)
        else
          G_RLock(.t.,forever) // бесконечная попытка добавить запись
          napr->KOD := recno() // код направления - номер записи
          rec := mkod := napr->KOD
          napr->KOD_K := m1kod_k // код по картотеке
          fl_found := .t.
        endif
        napr->CODEM_FROM := m1CODEM_FROM
        napr->TYPE_H_4 := mTYPE_H_4
        napr->ID_4 := mo_guid(1,mkod)
        napr->KOD_UP := 0
        napr->KOD_PP := 0
      else
        select NAPR
        G_RLock(forever)
      endif
      napr->otd_4 := m1otd
      napr->DS_4 := mkod_diag // диагноз приёмного отделения
      napr->usl_ok_4 := m1usl_ok
      napr->F_MEDC_4 := m1forma // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
      napr->DATE_H_4 := mdate_h // дата госпитализации
      napr->TIME_H_4 := mtime_h // время госпитализации
      napr->DNEJ_H_4 := mDNEJ_H_4 // сроки госпитализации
      napr->PROFIL_K_4 := m1profil_k // профиль койки по справочнику T007
      napr->PROFIL_4 := m1profil // профиль мед.помощи по справочнику V002
      napr->NUM_HIST_4 := mnum_hist
      napr->KOD_F_4out := 0 // код файла - по файлу mo_nfile
      napr->KOD_F_4in := 0 // код файла - по файлу mo_nfile
      if nKey == K_INS
        close databases
        arr_m := {year(mdate_h), 1, 1, "за "+date_month(mdate_h,.t.), ;
                  mdate_h, mdate_h, dtoc4(mdate_h), dtoc4(mdate_h)}
        flag := .t.
      else
        dbUnLock()
        Commit
        flag := between(mdate_h,arr_m[5],arr_m[6])
      endif
    endif
    exit
  enddo
endif
setcolor(tmp_color)
restscreen(buf)
return flag

***** 14.09.16 подставить срок лечения по умолчанию для конкретного профиля
Function f1_263_edit_s_gospit()
Local tmp_select := select()
if m1profil_k > 0 .and. m1profil > 0 .and. mDNEJ_H_4 <= 0 
  R_Use(dir_server+"mo_n7out",,"N7")
  index on str(profil_k,3)+str(profil,3) to tmpn7 memory
  find (str(m1profil_k,3)+str(m1profil,3))
  if found() .and. n7->kol_kd > 0
    mDNEJ_H_4 := n7->kol_kd 
  endif  
  n7->(dbCloseArea())
  select (tmp_select)
endif  
return .t.

*

***** 08.03.17
Function for_263_input_napr()
Local fl := !empty(NUM_D)
if fl
  if KOD_F_1in > 0 
    //
  elseif T_ANS_1 == 1 .and. CODEM_1 == glob_mo[_MO_KOD_TFOMS]
    //
  else 
    fl := .f.
  endif
endif  
if fl    
  fl := (S_CODEM == glob_mo[_MO_KOD_TFOMS] .and. TYPE_H_4 == 0)
endif
if fl
  fl := (ascan(arr_year,year(date_h_1)) > 0)
endif
if fl .and. is_annul
  fl := (TIP_ANNUL == 0)
endif
return fl  

****** 08.03.17 выбор фильтра направлений для госпитализации
Function f1_263_input_napr()
Static s_arr := {}, si := 2
Local fl, i, y, arr_p := {}, sast, a
for y := year(sys_date) to 2014 step -1
  aadd(arr_p, {"дата госпитализации "+lstr(y)+" год",y})
next  
sast := array(len(arr_p))
afill(sast,.f.) ; fl := .t.
for i := 1 to len(arr_p)
  if ascan(s_arr,arr_p[i,2]) > 0
    sast[i] := .t. ; fl := .f.
  endif
next
if fl
  sast[1] := .t.
endif
if (a := bit_popup(T_ROW,T_COL+5,arr_p,sast,color0)) == NIL
  return .f.
else
  s_arr := {}
  for i := 1 to len(a)
    aadd(s_arr,a[i,2])
  next
  if empty(s_arr)
    for i := 1 to len(arr_p)
      aadd(s_arr,arr_p[i,2])
    next
  endif
  arr_year := aclone(s_arr)
  fl := .f.
  if (i := popup_prompt(T_ROW,T_COL+5,si,{"все направления на госпитализацию",;
                                          "без учёта аннулированных"})) > 0
    fl := .t.
    si := i
    is_annul := (i == 2) 
  endif 
endif
return fl      

****** 08.03.17 выбор направления для госпитализации
Function _263_input_napr()
Local lkod := 0, buf := save_maxrow(), i, y, blk, t_arr[BR_LEN]
Private arr_year, is_annul
if !f1_263_input_napr()
  return lkod
endif
mywait()
R_Use(dir_server+"kartotek",,"_KART")
G_Use(dir_server+"mo_nnapr",,"NAPR")
set relation to kod_k into _KART
index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
      for for_263_input_napr()
go top
if eof()
  close databases
  rest_box(buf)
  func_error(4,"Не обнаружено направлений с ещё не оформленными госпитализациями")
  return lkod
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_TITUL] := "Выбор направления для госпитализации"
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,RB/BG,W+/RB,R/BG,W+/R,R/BG*,W+/R*",.f.}
blk := {|| iif(between(napr->TIP_ANNUL,1,3), {7,8}, {1,2}) }
/*blk := {|| iif(between(napr->TIP_ANNUL,1,3), {7,8},;
               iif(napr->t_ans_2 == 0, ;
                   iif(empty(napr->date_h_2),{5,6},{3,4}), {1,2})) }*/
t_arr[BR_COLUMN] := {{" Ф.И.О.", {|| left(_kart->fio,36) }, blk },;
                     {"№ направления", {|| padr(napr->NUM_D,13) }, blk },;
                     {"  Дата;направ-я", {|| date_8(napr->DATE_D) }, blk },;
                     {"  Дата;гос.п-ки", {|| iif(between(napr->TIP_ANNUL,1,3), "аннулир.", date_8(napr->date_h_1)) }, blk },;
                     {"условия;оказания ", {|| iif(napr->usl_ok_1==2,"днев.стац","стационар") }, blk }}
                     //{"  Дата;госп-ии", {|| date_8(napr->date_h_2) }, blk }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор направления для госпитализации") }
t_arr[BR_ENTER] := {|| iif(between(napr->TIP_ANNUL,1,3), func_error(4,"Данное направление аннулировано в "+;
                           {"СМО","стационаре","поликлинике"}[napr->TIP_ANNUL]+" "+date_8(napr->date_3)), nil),;
                       lkod := napr->kod }
/*t_arr[BR_ENTER] := {|| iif(napr->t_ans_2==0, ;
                           iif(empty(napr->date_h_2),;
                               func_error(4,"Вы ещё не подтвердили дату госпитализации по этому направлению"),;
                               func_error(4,"Вы ещё не получили подтверждения из ТФОМС по дате госпитализации")),;
                           (iif(between(napr->TIP_ANNUL,1,3), func_error(4,"Данное направление аннулировано в "+{"СМО","стационаре","поликлинике"}[napr->TIP_ANNUL]+" "+date_8(napr->date_3)), nil),;
                            lkod := napr->kod)) }*/
edit_browse(t_arr)
close databases
rest_box(buf)
return lkod

*

***** 16.03.17 выписка (выбытие) пациента из стационара
Function _263_s_vybytie()
Static str_sem := "_263_s_vybytie", si := 3
Local buf := save_maxrow(), blk, t_arr[BR_LEN], fl, i
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
if (i := popup_prompt(T_ROW,T_COL+5,si,;
            {"~Не введена дата выбытия (ещё лечатся)",;
             "Поиск по дате ~госпитализации",;
             "Поиск по дате ~выбытия"})) == 0
  G_SUnLock(str_sem)
  return NIL
endif
Private arr_m
if (si := i) > 1 .and. (arr_m := year_month(T_ROW,T_COL+5)) == NIL
  G_SUnLock(str_sem)
  return NIL
endif
mywait()
R_Use(dir_server+"kartotek",,"_KART")
R_Use(dir_server+"mo_nfile",,"NF")
G_Use(dir_server+"mo_nnapr",,"NAPR")
set relation to kod_k into _KART, to KOD_F_6out into NF
if si == 1
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
        for KOD_F_4out > 0 .and. T_ANS_4 == 1 .and. empty(DATE_6)
elseif si == 2
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
        for KOD_F_4out > 0 .and. T_ANS_4 == 1 .and. between(date_h_4,arr_m[5],arr_m[6])
else
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
        for KOD_F_4out > 0 .and. T_ANS_4 == 1 .and. between(date_6,arr_m[5],arr_m[6])
endif
go top
if eof()
  close databases
  G_SUnLock(str_sem)
  rest_box(buf)
  return func_error(4,"Не обнаружено госпитализаций по запрашиваемому условию")
endif
dbcreate(cur_dir+"tmp",{{"kod","N",6,0}})
use (cur_dir+"tmp") new
napr->(dbeval({|| dbselectarea("TMP"), dbappend(), tmp->kod := napr->kod }))
select NAPR
set index to
select TMP
set relation to kod into NAPR
index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp")
go top
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_TITUL] := "Госпитализации - даты выбытия"
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B,RB/BG,W+/RB,R/BG,W+/R,N+/BG",.t.}
blk := {|| iif(empty(napr->KOD_F_6out), {3,4}, ;
               iif(napr->t_ans_6==0, {5,6}, ;
                   iif(napr->t_ans_6==1, {1,2}, {7,8} ))) }
Private mm_tip_vyb := {{"выписан",1},{"умер",2},{"перевод в другое отделение",3}}
t_arr[BR_COLUMN] := {{" Ф.И.О.", {|| left(_kart->fio,29) }, blk },;
                     {"  дата;госп-ии", {|| date_8(napr->date_h_4) }, blk },;
                     {"  дата;выбытия", {|| date_8(napr->date_6) }, blk },;
                     {"  тип;выбытия", {|| padr(inieditspr(A__MENUVERT,mm_tip_vyb,napr->type_6),7) }, blk },;
                     {" Статус", {|| padr(f1_263_s_vybytie(),22) }, blk }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход ^<Enter>^ ред-ие даты выписки ^<Del>^ очистка даты выписки ^<F9>^ печать") }
t_arr[BR_EDIT] := {|nk,ob| f2_263_s_vybytie(nk,ob,"edit") }
edit_browse(t_arr)
close databases
G_SUnLock(str_sem)
rest_box(buf)
return NIL

*

***** 19.02.17
Function f1_263_s_vybytie()
Local s := "ошибка"
if empty(napr->KOD_F_6out)
  s := iif(empty(napr->date_6), "не введена дата выбытия", "ещё не отправлено в ТФОМС")
elseif napr->t_ans_6 == 0
  s := "не получен ответ из ТФОМС"
elseif napr->t_ans_6 == 1
  s := "получен ответ из ТФОМС"
endif
return s

*

***** 16.03.17
Function f2_263_s_vybytie(nKey,oBrow,regim)
Local ret := -1, rec, i, k, r1, tmp_color, buf, fl, s_error := "",;
      n_file := "spisokne"+stxt, sh := 84, HH := 80, t_arr[3], s1
do case
  case regim == "edit"
    if nKey == K_F9
      rec := tmp->(recno())
      arr_title := {;
"─────────────────────────────────────────┬──────┬────────┬──┬───────────────────────",;
"                                         │ диаг-│  дата  │ус│                       ",;
"            ФИО                          │ ноз  │госп-ии │ло│     профиль койки     ",;
"─────────────────────────────────────────┴──────┴────────┴──┴───────────────────────"}
      fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
      add_string(padl("дата печати "+date_8(sys_date)+" "+hour_min(seconds()),sh))
      add_string("")
      add_string(center("Список пациентов, ещё не выбывших из стационара",sh))
      aeval(arr_title, {|x| add_string(x) } )
      k := 0
      go top
      do while !eof()
        if empty(napr->KOD_F_6out) .and. empty(napr->date_6)
          s1 := padr(lstr(++k)+". "+alltrim(_kart->fio),41)+" "
          s1 += napr->ds_4+" "+date_8(napr->DATE_H_4)+" "
          s1 += iif(napr->usl_ok_4==2,"дн","ст")+" "
          s1 += inieditspr(A__MENUVERT, arr_t007, napr->PROFIL_K_4)
          if verify_FF(HH-2,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(s1)
          add_string(replicate("─",sh))
        endif
        select TMP
        skip
      enddo
      select TMP
      goto (rec)
      fclose(fp)
      viewtext(n_file,,,,(sh>80),,,5)
    elseif nKey == K_ENTER
      Private mfio    := _kart->fio,;
              mdate_r := _kart->date_r,;
              mpol    := _kart->pol,;
              mkod    := napr->KOD,;
              m1kod_k := napr->kod_k,; // код по картотеке
              mforma, m1forma := napr->F_MEDC_4,; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
              mdate_h := napr->DATE_H_4,; // дата госпитализации
              mprofil_k, m1profil_k := napr->PROFIL_K_4,; // профиль койки по справочнику T007
              mprofil, m1profil := napr->PROFIL_4,; // профиль мед.помощи по справочнику V002
              mCODEM_FROM, m1CODEM_FROM := napr->CODEM_FROM,;
              mnum_d  := napr->NUM_D,;
              md_napr := napr->DATE_D,; // дата направления
              mTYPE_H_4 := napr->TYPE_H_4,;
              mnum_hist := napr->NUM_HIST_4,;
              mdate_6 := napr->date_6,;
              mtip, m1tip := napr->type_6,;
              gl_area := {1,0,23,79,0}
      mtip := inieditspr(A__MENUVERT,mm_tip_vyb,m1tip)
      mforma := inieditspr(A__MENUVERT,glob_V014,m1forma)
      mprofil_k := inieditspr(A__MENUVERT, arr_t007, M1PROFIL_K)
      mprofil := inieditspr(A__MENUVERT, glob_V002, M1PROFIL)
      if empty(m1CODEM_FROM)
        mCODEM_FROM := space(10)
      else
        if m1CODEM_FROM == glob_mo[_MO_KOD_TFOMS]
          mCODEM_FROM := "Поликлиники нашего МО"
        else
          mCODEM_FROM := ret_mo(m1CODEM_FROM)[_MO_SHORT_NAME]
        endif
      endif
      if napr->t_ans_6 == 2
        R_Use(dir_server+"mo_nfina",,"NFN")
        index on str(kod_n,6) to (cur_dir+"tmp_nfn") for kod_f == napr->KOD_F_6out
        find (str(napr->kod,6))
        if found()
          s_error := "ошибка "+lstr(nfn->OSHIB)+" - "+inieditspr(A__MENUVERT,glob_T008,nfn->OSHIB)
          if !empty(nfn->IM_POL)
            s_error += " (в поле "+alltrim(nfn->IM_POL)+")"
          endif
        endif
        nfn->(dbCloseArea())
        select TMP
      endif
      buf := savescreen()
      r1 := maxrow()-15
      do while .t.
        setcolor(cDataCGet)
        ClrLines(r1,maxrow()-1)
        @ r1,0 say padc("Ввод/редактирование даты выбытия",80) color "B/B*"
        i := 0
        ++i ; @ r1+i,1 say "Пациент" get mfio when .f.
              @ row(),col()+2 say "Дата р." get mdate_r when .f.
        do case
          case mTYPE_H_4 == 1
            ++i ; @ r1+i,1 say "Направлен из" color color8 get mCODEM_FROM when .f.
            ++i ; @ r1+i,1 say " направление: №" color color8 get mnum_d when .f.
                  @ row(),col()+1 say "от" color color8 get md_napr when .f.
          case mTYPE_H_4 == 2
            ++i ; @ r1+i,1 say "Переведён из" color color8 get mCODEM_FROM when .f.
          case mTYPE_H_4 == 3
            ++i ; @ r1+i,1 say "Переведён внутри МО из стационарного отделения в стационарное отделение" color color8
          case mTYPE_H_4 == 4
            ++i ; @ r1+i,1 say "Госпитализация по неотложным или экстренным показаниям" color color8
        endcase
        ++i ; @ r1+i,1 say "Форма оказания медицинской помощи" get mforma when .f.
        ++i ; @ r1+i,1 say "Профиль койки" get mprofil_k when .f.
        ++i ; @ r1+i,1 say "Профиль медицинской помощи" get mprofil when .f.
        ++i ; @ r1+i,1 say "Дата госпитализации (в нашем стационаре)" get mdate_h when .f.
        ++i ; @ r1+i,1 say "Номер истории болезни" get mnum_hist when .f.
        ++i ; @ r1+i,1 say "Тип выбытия" get mtip ;
                       reader {|x|menu_reader(x,mm_tip_vyb,A__MENUVERT,,,.f.)}
        ++i ; @ r1+i,1 say "Дата выбытия" get mdate_6
        if !empty(s_error)
          ++i ; @ r1+i,1 say s_error color color8
        endif
        fl := .t.
        if empty(napr->KOD_F_6out)
          fl := .f.
        elseif !empty(nf->NAME_F)
          ++i ; @ r1+i,1 say "(в файле "+alltrim(nf->NAME_F)+")" color color8
        endif
        if napr->t_ans_6 == 2
          fl := .f.
        endif
        if !fl .and. m1tip == 3 .and. napr->KOD_NEXT > 0
          fl := .t.
        endif
        if fl
          stat_msg("Ответ из ТФОМС "+iif(napr->t_ans_6==0,"ещё не","уже")+" получен. Редактирование запрещено!")
          mybell(0,ERR)
          clear_gets()
          setcolor(tmp_color)
          restscreen(buf)
          return ret
        endif
        status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода")
        myread()
        k := f_alert({padc("Выберите действие",60,".")},;
                   {" Выход без записи "," Запись "," Возврат в редактирование "},;
                   if(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
        if k == 3
          loop
        elseif k == 2
          if m1tip == 0
            func_error(4,"Не введён тип выбытия.")
            loop
          endif
          if m1tip == 3
            func_error(4,"Режим перевода пока не реализован.")
            loop
          endif
          if empty(mdate_6)
            func_error(4,"Не введена дата выбытия.")
            loop
          endif
          if mdate_6 < mdate_h
            func_error(4,"Дата выбытия меньше даты госпитализации.")
            loop
          endif
          select NAPR
          G_RLock(forever)
          napr->TYPE_6 := m1tip         // выбытие: 1-выписан, 2-умер, 3-перевод внутри нашего МО
          napr->KOD_NEXT := 0           // код следующей госпитализации (после перевода в др.отд-ие)
          napr->ID_6 := mo_guid(1,mkod) // GUID+lstr(mo_nnapr->KOD) ID выписки для tip_f=6
          napr->DATE_6 := mdate_6       // дата выбытия
          napr->KOD_F_6out := 0         // код файла - по файлу mo_nfile
          napr->KOD_F_6in := 0          // код файла - по файлу mo_nfile
          dbUnLock()
          Commit
          select TMP
          ret := 0
        endif
        exit
      enddo
      setcolor(tmp_color)
      restscreen(buf)
    elseif nKey == K_DEL .and. !empty(napr->DATE_6)
      if empty(napr->KOD_F_6out)
        if napr->TYPE_6 == 3 // выбытие: 3-перевод внутри нашего МО
          func_error(4,"Режим удаления перевода пока не реализован.")
        elseif f_Esc_Enter("очистки даты выписки",.t.)
          select NAPR
          G_RLock(forever)
          napr->TYPE_6 := 0             // выбытие: 1-выписан, 2-умер, 3-перевод внутри нашего МО
          napr->KOD_NEXT := 0           // код следующей госпитализации (после перевода в др.отд-ие)
          napr->ID_6 := ""              // GUID+lstr(mo_nnapr->KOD) ID выписки для tip_f=6
          napr->DATE_6 := ctod("")      // дата выбытия
          napr->KOD_F_6out := 0 // код файла - по файлу mo_nfile
          napr->KOD_F_6in := 0 // код файла - по файлу mo_nfile
          dbUnLock()
          Commit
          select TMP
          ret := 1
        endif
      elseif napr->t_ans_6 == 1
        func_error(4,"Ответ из ТФОМС уже получен. Очистка даты выписки запрещена!")
      endif
    else
      keyboard ""
    endif
endcase
return ret

*

***** 08.03.17
Function for_263_s_napr()
Local fl := .t.
if KOD_F_1in > 0
  //
elseif T_ANS_1 == 1 .and. CODEM_1 == glob_mo[_MO_KOD_TFOMS]
  //
else 
  fl := .f.
endif
if fl    
  fl := (S_CODEM == glob_mo[_MO_KOD_TFOMS] .and. TYPE_H_4 == 0)
endif
if fl
  fl := (napr->KOD_F_4out == 0 .and. between(date_d,arr_m[5],arr_m[6]))
endif  
return fl

***** 08.03.17 работа с направлениями на госпитализацию в стационаре
Function _263_s_napr()
Static str_sem := "_263_s_napr", si := 1
Local buf := save_maxrow(), blk, t_arr[BR_LEN], fl, i, n
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
/*if (i := popup_prompt(T_ROW,T_COL+5,si,;
            {"~Не подтверждена дата госпитализации пол-ки",;
             "По дате ~госпитализации, введённой в стационаре",;
             "По дате ~ввода даты госпитализации в стационаре",;
             "Вернувшиеся с ~ошибкой из ТФОМС"})) == 0
  G_SUnLock(str_sem)
  return NIL
endif*/
Private arr_m
//si := i
if /*eq_any(i,2,3) .and.*/ (arr_m := year_month(T_ROW,T_COL+5)) == NIL
  G_SUnLock(str_sem)
  return NIL
endif
mywait()
R_Use(dir_server+"kartotek",,"_KART")
R_Use(dir_server+"mo_nfile",,"NF")
G_Use(dir_server+"mo_nnapr",,"NAPR")
set relation to kod_k into _KART//, to KOD_F_2out into NF
index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
      for for_263_s_napr()
/*if si == 1
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
        for KOD_F_1in > 0 .and. empty(DATE_H_2)
elseif si == 2
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
        for KOD_F_1in > 0 .and. between(date_h_2,arr_m[5],arr_m[6])
elseif si == 3
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
        for KOD_F_1in > 0 .and. between(date_2,arr_m[5],arr_m[6])
else
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
        for KOD_F_1in > 0 .and. t_ans_2 == 2
endif*/
go top
if eof()
  close databases
  G_SUnLock(str_sem)
  rest_box(buf)
  return func_error(4,"Не обнаружено направлений "+arr_m[4])
endif
dbcreate(cur_dir+"tmp",{{"kod","N",6,0}})
use (cur_dir+"tmp") new
napr->(dbeval({|| dbselectarea("TMP"), dbappend(), tmp->kod := napr->kod }))
select NAPR
set index to
select TMP
set relation to kod into NAPR
index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp")
go top
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_TITUL] := "Список направлений "+arr_m[4]
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B,RB/BG,W+/RB,R/BG,W+/R,R/BG*,W+/R*",.t.}
blk := {|| iif(between(napr->TIP_ANNUL,1,3), {9,10}, iif(napr->type_h_4 > 0, {1,2}, {3,4})) }
/*blk := {|| iif(between(napr->TIP_ANNUL,1,3), {9,10},;
               iif(empty(napr->KOD_F_2out), {3,4}, ;
                   iif(napr->t_ans_2==0, {5,6}, ;
                       iif(napr->t_ans_2==1, {1,2}, {7,8} )))) }*/
n := iif(work_otd_263 == 1, 23, 29)
t_arr[BR_COLUMN] := {{"№ направления", {|| left(napr->NUM_D,13) }, blk },;
                     {"  Дата", {|| date_8(napr->date_d) }, blk },;
                     {" Ф.И.О.", {|| left(_kart->fio,n) }, blk },;
                     {"ус;ок", {|| iif(napr->usl_ok_1==2,"дн","ст") }, blk },;
                     {" Статус", {|| padr(f1_263_s_napr(),22) }, blk }}
if work_otd_263 == 1
  Ins_Array(t_arr[BR_COLUMN],5,{" Отд.", {|| _263_put_otd(iif(empty(napr->otd_4),napr->otd_1,napr->otd_4)) }, blk })
endif
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход   ^<Enter>^ просмотр   ^<F9>^ печать") }
t_arr[BR_EDIT] := {|nk,ob| f2_263_s_napr(nk,ob,"edit") }
edit_browse(t_arr)
close databases
G_SUnLock(str_sem)
rest_box(buf)
return NIL

*

***** 19.02.17
Function f1_263_s_napr()
Local s := " направлено в стационар"
if napr->KOD_F_6out > 0
  s := " выбытие "+date_8(napr->date_6)
elseif napr->type_h_4 > 0
  s := "госпитализир. "+date_8(napr->date_h_4)
elseif napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0
  s := "аннулировано "+date_8(napr->date_3)
endif
return s

*

***** 08.03.17
Function f2_263_s_napr(nKey,oBrow,regim)
Static s_arr
Local ret := -1, rec, i, k, tmp_color, buf, s_error := "", arr_p := {}, sast := {}, a, fl,;
      tmp_V006 := {{"Стационар",1},{"Дневной стационар",2}},;
      n_file := "spisok"+stxt, sh := 84, HH := 60, t_arr[3], s1, s2, s3
do case
  case regim == "edit"
    if nKey == K_F9 .and. (k := f_alert({padc('Выберите вариант печати списка направлений',60,'.')},;
                                        {' Без аннулированных ',' Все направления '},;
                                        1,"W+/N","N+/N",maxrow()-3,,"W+/N,N/BG")) > 0
      select TMP
      rec := recno()
      go top
      do while !eof()
        if iif(k==2, .t., !(napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0)) .and. ; 
                                    ascan(arr_p, {|x| x[2] == napr->PROFIL_K_1 }) == 0
          aadd(arr_p, {inieditspr(A__MENUVERT, arr_t007, napr->PROFIL_K_1),;
                       napr->PROFIL_K_1} )
        endif
        skip
      enddo
      goto (rec)
      if len(arr_p) == 1
        s_arr := {arr_p[1,2]}
      else
        DEFAULT s_arr TO {}
        asort(arr_p,,,{|x,y| x[1] < y[1] })
        sast := array(len(arr_p))
        afill(sast,.f.) ; fl := .t.
        for i := 1 to len(arr_p)
          if ascan(s_arr,arr_p[i,2]) > 0
            sast[i] := .t. ; fl := .f.
          endif
        next
        if fl
          afill(sast,.t.)
        endif
        if (a := bit_popup(T_ROW,T_COL+5,arr_p,sast,color5)) == NIL
          return ret
        else
          s_arr := {}
          for i := 1 to len(a)
            aadd(s_arr,a[i,2])
          next
        endif
      endif
      arr_title := {;
"────────────────────────────┬──────────────────────┬───────────────────────┬────────",;
"                            │                      │    диагноз, форма     │  дата  ",;
"ФИО и дата рождения пациента│     направление      │профиль койки(мед.пом.)│госп-ии ",;
"────────────────────────────┴──────────────────────┴───────────────────────┴────────"}
      fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
      add_string("")
      add_string(center("Направления на госпитализацию "+arr_m[4],sh))
      aeval(arr_title, {|x| add_string(x) } )
      go top
      do while !eof()
        if iif(k==2, .t., !(napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0)) .and. ascan(s_arr,napr->PROFIL_K_1) > 0
          s := alltrim(_kart->fio)+" д.р."+full_date(_kart->date_r)
          perenos(t_arr,s,28)
          s1 := padr(t_arr[1],29)
          s2 := padr(t_arr[2],29)
          s3 := padr(t_arr[3],29)
          s := padr(napr->NUM_D,14)+date_8(napr->DATE_D)+" "+ret_mo(napr->CODEM_1)[_MO_SHORT_NAME]
          perenos(t_arr,s,22)
          s1 += padr(t_arr[1],23)
          s2 += padr(t_arr[2],23)
          s3 += padr(t_arr[3],23)
          s := rtrim(napr->ds_1)+" "+;
               inieditspr(A__MENUVERT,glob_V014,napr->F_MEDC_1)+" "+;
               inieditspr(A__MENUVERT, arr_t007, napr->PROFIL_K_1)+" ("+;
               inieditspr(A__MENUVERT, glob_V002, napr->PROFIL_1)+")"
          perenos(t_arr,s,23)
          s1 += padr(t_arr[1],24)+date_8(napr->DATE_H_1)
          s2 += padr(t_arr[2],24)+iif(napr->usl_ok_1==2,"дневной","стационар")
          s3 += padr(t_arr[3],24)+iif(napr->usl_ok_1==2,"стационар","")
          if verify_FF(HH-4,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(s1)
          add_string(s2)
          add_string(s3)
          add_string(replicate("─",sh))
        endif
        select TMP
        skip
      enddo
      select TMP
      goto (rec)
      fclose(fp)
      viewtext(n_file,,,,(sh>80),,,2)
    elseif nKey == K_ENTER
      Private mn_napr := napr->NUM_D, md_napr := napr->DATE_D,;
              mpol_mo := space(10), m1pol_mo := napr->CODEM_1,;
              mfio    := _kart->fio,;
              mdate_r := _kart->date_r,;
              mpol    := _kart->pol,;
              mkod    := napr->KOD,;
              m1kod_k := napr->kod_k,; // код по картотеке
              mkod_diag := napr->ds_1,; // диагноз поликлиники
              mforma, m1forma := napr->F_MEDC_1,; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
              mdate_hosp := napr->DATE_H_1,; // планируемая дата госпитализации
              mprofil_k, m1profil_k := napr->PROFIL_K_1,; // профиль койки по справочнику T007
              mprofil, m1profil := napr->PROFIL_1,; // профиль мед.помощи по справочнику V002
              musl_ok, m1usl_ok := napr->usl_ok_1,; // условия оказания мед.помощи
              mdate_2 := iif(empty(napr->date_2), sys_date, napr->date_2),;
              mdate_h_2 := iif(empty(napr->date_h_2), napr->date_h_1, napr->date_h_2),;
              motd := space(10), m1otd := napr->otd_2,;
              gl_area := {1,0,23,79,0}
      if work_otd_263 == 1
        Private pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}
        make_arr_uch_otd(mdate_h_2)
        if (i := ascan(pr_arr,{|x| x[1]==m1otd } )) > 0
          motd := pr_arr[i,2]
        elseif nKey == K_ENTER .and. m1otd > 0
          motd := "! некорректное отделение !"
        endif
      endif
      mforma := inieditspr(A__MENUVERT,glob_V014,m1forma)
      mprofil_k := inieditspr(A__MENUVERT, arr_t007, M1PROFIL_K)
      mprofil := inieditspr(A__MENUVERT, glob_V002, M1PROFIL)
      mUSL_OK := inieditspr(A__MENUVERT, tmp_V006, m1USL_OK)
      if !empty(m1pol_mo)
        if m1pol_mo == glob_mo[_MO_KOD_TFOMS]
          mpol_mo := "Поликлиника нашего МО"
        else
          mpol_mo := ret_mo(m1pol_mo)[_MO_SHORT_NAME]
        endif
      endif
      if napr->t_ans_2 == 2
        R_Use(dir_server+"mo_nfina",,"NFN")
        index on str(kod_n,6) to (cur_dir+"tmp_nfn") for kod_f == napr->KOD_F_2out
        find (str(napr->kod,6))
        if found()
          s_error := "ошибка "+lstr(nfn->OSHIB)+" - "+inieditspr(A__MENUVERT,glob_T008,nfn->OSHIB)
          if !empty(nfn->IM_POL)
            s_error += " (в поле "+alltrim(nfn->IM_POL)+")"
          endif
        endif
        nfn->(dbCloseArea())
        select TMP
      endif
      buf := savescreen()
      Private r1 := maxrow()-15
      if work_otd_263 == 1
        --r1
      endif
      setcolor(cDataCGet)
      ClrLines(r1,maxrow()-1)
      @ r1-1,0 say padc("Просмотр направления на госпитализацию",80) color "B/B*"
      i := r1
      ++i ; @ i,1 say "Пациент" get mfio when .f.
            @ row(),col()+2 say "Дата р." get mdate_r when .f.
      ++i ; @ i,1 say "направление: №" get mn_napr when .f.
            @ row(),col()+3 say "дата" get md_napr when .f.
      ++i ; @ i,1 say "Диагноз направившего учреждения" get mkod_diag when .f.
      ++i ; @ i,1 say "Направившее учреждение" get mpol_mo when .f.
      ++i ; @ i,1 say "Форма оказания медицинской помощи" get mforma when .f.
      ++i ; @ i,1 say "Условия оказания, в которые направляется пациент" get musl_ok 
      tmp_V006 := {{"Стационар",1},{"Дневной стационар",2}}
      ++i ; @ i,1 say "Профиль койки" get mprofil_k when .f.
      ++i ; @ i,1 say "Профиль медицинской помощи" get mprofil when .f.
      ++i ; @ i,1 say "Планируемая дата госпитализации" get mdate_hosp when .f.
      if work_otd_263 == 1
      ++i ; @ i,1 say "  будет госпитализирован в отделение"
        if mem_kodotd == 1
          @ row(),col()+1 get motd ;
                          reader {|x|menu_reader(x,{{|k,r,c| get_otd(k,r+1,c,.f.) }},A__FUNCTION,,,.f.)}
        else
          @ row(),col()+1 get m1otd pict "99" ;
                          when {|g| f5editkusl(g,1,10) } ;
                          valid {|g| f5editkusl(g,2,10) }
          @ row(),col()+2 get motd color color14 when .f.
        endif
      endif
      if !empty(s_error)
        ++i ; @ i,1 say s_error color color8
      endif
      if !(empty(napr->KOD_F_2out) .or. napr->t_ans_2 == 2)
        s := ""
        if napr->KOD_F_6out > 0
          s := "выбыл из стационара "+date_8(napr->date_6)
        elseif napr->KOD_F_4out > 0
          s := "госпитализирован в стационар "+date_8(napr->date_h_4)
        elseif napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0
          s := "направление аннулировано "+date_8(napr->date_3)+" в "
          if napr->TIP_ANNUL == 1
            s += "СМО"
          elseif napr->TIP_ANNUL == 2
            s += "стационаре"
          else
            s += "поликлинике"
          endif
        endif
        ++i ; @ i,1 say s color color8
        stat_msg("Ответ из ТФОМС "+iif(napr->t_ans_2==0,"ещё не","уже")+" получен. Редактирование запрещено!")
      else
        status_key("^<Esc>^ - выход")
      endif
      clear_gets()
      inkey(0)
      setcolor(tmp_color)
      restscreen(buf)
    else
      keyboard ""
    endif
endcase
return ret

***** 08.03.17
Function for_263_s_annul()
Local fl := (S_CODEM == glob_mo[_MO_KOD_TFOMS])
if KOD_F_1in > 0
  //
elseif T_ANS_1 == 1 .and. CODEM_1 == glob_mo[_MO_KOD_TFOMS]
  //
else 
  fl := .f.
endif
if fl
  fl := (!empty(napr->date_3) .or. empty(KOD_F_4out)) // и не госпитализирован
endif  
if fl
  fl := between(date_h_1,arr_m[5],arr_m[6])
endif
return fl      

***** 21.02.17 Аннулирование направлений, поступивших из поликлиник через ТФОМС
Function _263_s_annul()
Static str_sem := "_263_s_annul", si := 1
Local buf := save_maxrow(), blk, t_arr[BR_LEN], fl, i, n
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
/*if (i := popup_prompt(T_ROW,T_COL+5,si,;
            {"~Не подтверждена дата госпитализации пол-ки",;
             "По дате ~госпитализации, введённой в стационаре",;
             "По дате ~ввода даты госпитализации в стационаре"})) == 0
  G_SUnLock(str_sem)
  return NIL
endif*/
Private arr_m
if /*(si := i) > 1 .and.*/ (arr_m := year_month(T_ROW,T_COL+5)) == NIL
  G_SUnLock(str_sem)
  return NIL
endif
mywait()
R_Use(dir_server+"kartote_",,"_KART_")
R_Use(dir_server+"kartotek",,"_KART")
set relation to kod into _KART_
R_Use(dir_server+"mo_nfile",,"NF")
G_Use(dir_server+"mo_nnapr",,"NAPR")
set relation to kod_k into _KART, to KOD_F_3out into NF
index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
      for for_263_s_annul()
/*if si == 1
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
        for KOD_F_1in > 0 .and. empty(DATE_H_2) .and. ;
            (!empty(napr->date_3) .or. empty(KOD_F_4out)) // и не госпитализирован
elseif si == 2
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
        for KOD_F_1in > 0 .and. between(date_h_2,arr_m[5],arr_m[6]) .and. ;
            (!empty(napr->date_3) .or. empty(KOD_F_4out)) // и не госпитализирован
else
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
        for KOD_F_1in > 0 .and. between(date_2,arr_m[5],arr_m[6]) .and. ;
            (!empty(napr->date_3) .or. empty(KOD_F_4out)) // и не госпитализирован
endif*/
go top
if eof()
  close databases
  G_SUnLock(str_sem)
  rest_box(buf)
  return func_error(4,"Не обнаружено направлений по запрашиваемому условию")
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_TITUL] := "Аннулирование направлений на госпитализацию в стационаре"
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_COLOR] := color0
t_arr[BR_OPEN] := {|| f2_263_s_annul(,,"open") }
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B,RB/BG,W+/RB,R/BG,W+/R",.t.}
blk := {|| iif(!empty(napr->KOD_F_3in), {1,2}, ;
               iif(empty(napr->KOD_F_3out), {3,4}, ;
                   iif(napr->t_ans_3==0, {5,6}, ;
                       iif(napr->t_ans_3==1, {1,2}, {7,8} )))) }
n := iif(work_otd_263 == 1, 23, 29)
t_arr[BR_COLUMN] := {{"№ направления", {|| left(napr->NUM_D,13) }, blk },;
                     {"  Дата", {|| date_8(napr->date_d) }, blk },;
                     {" Ф.И.О.", {|| left(_kart->fio,n) }, blk },;
                     {"ус;ок", {|| iif(napr->usl_ok_1==2,"дн","ст") }, blk },;
                     {" Статус", {|| padr(f1_263_s_annul(),22) }, blk }}
if work_otd_263 == 1
  Ins_Array(t_arr[BR_COLUMN],5,{" Отд.", {|| _263_put_otd(napr->otd_1) }, blk })
endif
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход ^<Enter>^ просмотр/аннулирование ^<Del>^ удаление аннулирования") }
t_arr[BR_EDIT] := {|nk,ob| f2_263_s_annul(nk,ob,"edit") }
edit_browse(t_arr)
close databases
G_SUnLock(str_sem)
rest_box(buf)
return NIL

***** 08.03.17
Function f1_263_s_annul()
Local s := "ошибка"
if empty(napr->date_3)
  if napr->TYPE_H_4 == 0
    s := "ещё не госпитализирован"
  elseif empty(napr->KOD_F_4out)
    s := "ещё не отправлено в ТФОМС"
  else
    s := "отправлено в ТФОМС"
  endif
elseif napr->TIP_ANNUL == 2
  if empty(napr->KOD_F_3out)
    s := "аннул/не отправлен в ТФ"
  elseif napr->t_ans_3 == 0
    s := "аннул/не получен ответ"
  elseif napr->t_ans_3 == 1
    s := "аннулировано "+date_8(napr->date_3)
  endif
elseif napr->TIP_ANNUL == 1
  s := "аннулировано в СМО"
elseif napr->TIP_ANNUL == 3
  s := "аннулировано в поликлинике"
endif
return s

*

***** 19.02.17
Function f2_263_s_annul(nKey,oBrow,regim)
Local ret := -1, rec, i, k, s, tmp_color, buf, s_error := "",;
      tmp_V006 := {{"Стационар",1},{"Дневной стационар",2}}
do case
  case regim == "open"
    select NAPR
    go top
    ret := !eof()
  case regim == "edit"
    if napr->KOD > 0 .and. nKey == K_ENTER
      rec := napr->(recno())
      tmp_color := setcolor()
      buf := savescreen()
      mywait()
      Private ;
        mn_napr := napr->NUM_D,; // уникальный номер направления (п-ка)
        md_napr := napr->DATE_D,; // дата направления
        mpol_mo := space(10), m1pol_mo := napr->CODEM_1,;
        mfio    := _kart->fio,;
        mdate_r := _kart->date_r,;
        mpol    := _kart->pol,;
        mkod    := napr->KOD,;
        m1kod_k := napr->kod_k,; // код по картотеке
        mkod_diag := napr->ds_1,; // диагноз поликлиники
        musl_ok, m1usl_ok := iif(napr->usl_ok_1==2, 2, 1),; // условия оказания мед.помощи
        mforma, m1forma := napr->F_MEDC_1,; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
        mdate_hosp := napr->DATE_H_1,; // планируемая дата госпитализации
        mprofil_k, m1profil_k := napr->PROFIL_K_1,; // профиль койки по справочнику T007
        mprofil, m1profil := napr->PROFIL_1,; // профиль мед.помощи по справочнику V002
        motd := space(10), m1otd := napr->otd_1,;
        mdate_3 := napr->date_3, ;
        mrea_annul := space(10), m1rea_annul := napr->rea_annul,;
        gl_area := {1,0,23,79,0}
      if work_otd_263 == 1
        Private pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}
        make_arr_uch_otd(md_napr)
        if (i := ascan(pr_arr,{|x| x[1]==m1otd } )) > 0
          motd := pr_arr[i,2]
        elseif m1otd > 0
          motd := "! некорректное отделение !"
        endif
      endif
      mUSL_OK := inieditspr(A__MENUVERT, tmp_V006, m1USL_OK)
      mforma := inieditspr(A__MENUVERT,glob_V014,m1forma)
      mprofil_k := inieditspr(A__MENUVERT, arr_t007, M1PROFIL_K)
      mprofil := inieditspr(A__MENUVERT, glob_V002, M1PROFIL)
      mrea_annul := inieditspr(A__MENUVERT, mm_reason_annul, m1rea_annul)
      if !empty(m1pol_mo)
        if m1pol_mo == glob_mo[_MO_KOD_TFOMS]
          mpol_mo := "Поликлиника нашего МО"
        else
          mpol_mo := ret_mo(m1pol_mo)[_MO_SHORT_NAME]
        endif
      endif
      Private r1 := maxrow()-15
      //if work_otd_263 == 1
        //--r1
      //endif
      do while .t.
        setcolor(cDataCGet)
        ClrLines(r1,maxrow()-1)
        @ r1-1,0 say padc("Аннулирование направления на госпитализацию",80) color "B/B*"
        i := r1
        ++i ; @ i,1 say "Пациент" get mfio when .f.
              @ row(),col()+2 say "Дата р." get mdate_r when .f.
        ++i ; @ i,1 say "направление: №" get mn_napr when .f.
              @ row(),col()+3 say "дата" get md_napr when .f.
        ++i ; @ i,1 say "Направившее учреждение" get mpol_mo when .f.
        ++i ; @ i,1 say "Диагноз направившего учреждения" get mkod_diag when .f. picture "@K@!"
        ++i ; @ i,1 say "Условия оказания, в которые направляется пациент" get musl_ok when .f.
        ++i ; @ i,1 say "Форма оказания медицинской помощи" get mforma when .f.
        ++i ; @ i,1 say "Профиль койки" get mprofil_k when .f.
        ++i ; @ i,1 say "Профиль медицинской помощи" get mprofil when .f.
        ++i ; @ i,1 say "Планируемая дата госпитализации направившего учреждения" get mdate_hosp when .f.
        /*if !empty(napr->KOD_F_2out)
          ++i ; @ i,1 say "Планируемая дата госпитализации (нашего стационара)" get mdate_h_2 when .f.
          ++i ; @ i,1 say "Дата ввода даты госпитализации (в стационаре)" get mdate_2 when .f.
          if work_otd_263 == 1
          ++i ; @ i,1 say "       будет госпитализирован в отделение" get motd when .f.
          endif
        endif*/
        ++i ; @ i,1 say "Причина аннулирования" get mrea_annul ;
                    reader {|x|menu_reader(x,mm_reason_annul,A__MENUVERT,,,.f.)}
        ++i ; @ i,1 say "Дата аннулирования" get mdate_3
        if napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0 .or. eq_any(napr->TIP_ANNUL,1,3)
          s_msg := ""
          s := "Направление аннулировано в "
          if napr->TIP_ANNUL == 1
            s += "СМО"
            s_msg := s
          elseif napr->TIP_ANNUL == 2
            s += "нашем стационаре"
          else
            s += "поликлинике"
            s_msg := s
          endif
          if !empty(napr->KOD_F_3out) .and. !empty(nf->NAME_F)
            s += " (в файле "+alltrim(nf->NAME_F)+")"
          endif
          ++i ; @ i,1 say s color color8
          if empty(s_msg)
            s_msg := "Ответ из ТФОМС "+iif(napr->t_ans_3==0,"ещё не","уже")+" получен"
          endif
          stat_msg(s_msg+". Редактирование запрещено!")
          mybell(0,ERR)
          clear_gets()
          setcolor(tmp_color)
          restscreen(buf)
          return ret
        endif
        status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода")
        myread()
        k := f_alert({padc("Выберите действие",60,".")},;
                     {" Выход без записи "," Запись "," Возврат в редактирование "},;
                     iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
        if k == 3
          loop
        elseif k == 2
          if empty(mdate_3)
            func_error(4,"Не введена дата аннулирования.")
            loop
          endif
          if empty(m1rea_annul)
            func_error(4,"Не введена причина аннулирования.")
            loop
          endif
          if mdate_3 < md_napr
            func_error(4,"Дата аннулирования меньше даты направления.")
            loop
          endif
          /*if !empty(mdate_h_2)
            if mdate_h_2 < mdate_3
              func_error(4,"Дата госпитализации стационара меньше даты аннулирования.")
              loop
            endif
          elseif mdate_hosp < mdate_3
            func_error(4,"Дата госпитализации поликлиники меньше даты аннулирования.")
            loop
          endif*/
          select NAPR
          goto (rec)
          G_RLock(forever)
          napr->DATE_3 := mdate_3 // дата аннулирования
          napr->TIP_ANNUL := 2  // ануллировано в стационаре
          napr->rea_annul := m1rea_annul // причина аннулирования
          napr->KOD_F_3out := 0 // код файла - по файлу mo_nfile
          napr->KOD_F_3in := 0 // код файла - по файлу mo_nfile
          dbUnLock()
          Commit
          ret := 0
        endif
        exit
      enddo
      setcolor(tmp_color)
      restscreen(buf)
    elseif nKey == K_DEL .and. napr->TIP_ANNUL == 2
      if empty(napr->KOD_F_3out) .or. napr->t_ans_3 == 2
        if f_Esc_Enter(2,.t.)
          select NAPR
          G_RLock(forever)
          napr->DATE_3 := ctod("") // дата аннулирования
          napr->TIP_ANNUL := 0  // ануллировано в поликлинике
          napr->rea_annul := 0 // причина аннулирования
          napr->KOD_F_3out := 0 // код файла - по файлу mo_nfile
          napr->KOD_F_3in := 0 // код файла - по файлу mo_nfile
          dbUnLock()
          Commit
          ret := 0
        endif
      elseif !empty(napr->KOD_F_3out)
        if napr->t_ans_3 == 1
          func_error(4,'Аннулирование данного направления уже отправлено в ТФОМС!')
        else
          func_error(4,"Ответ из ТФОМС ещё не получен. Удаление данного аннулирования запрещено!")
        endif
      endif
    else
      keyboard ""
    endif
endcase
return ret

*

***** 19.02.17 Ввод / редактирование количества свободных коек по профилям в стационаре
Function _263_s_svob_kojki()
Static str_sem := "_263_s_svob_kojki"
Local buf, blk, t_arr[BR_LEN], fl := .t., k := 0
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
G_Use(dir_server+"mo_n7d",,"D7")
if lastrec() == 0
  append blank
  UnLock
endif
buf := savescreen()
Private mdate_r := iif(empty(d7->DATE_R_EDI), sys_date, d7->DATE_R_EDI)
box_shadow(T_ROW,2,T_ROW+7,77,color1)
tmp_color := setcolor(cDataCGet)
if empty(d7->DATE_R_OUT)
  @ T_ROW+2,4 say "Данные ещё ни разу не отправлялись в ТФОМС"
else
  @ T_ROW+2,4 say "Последний раз данные в ТФОМС отправлены за отчётную дату "+date_8(d7->DATE_R_OUT)+"г."
endif
@ T_ROW+3,4 say "Последний раз данные редактировались "+date_8(d7->DATE_E)+"г. в "+d7->TIME_E+;
                " - "+iif(d7->END_EDIT==1,"", "не ")+"завершено"
if d7->KOD_OPER > 0
  R_Use(dir_server+"base1",,"base1")
  goto (d7->KOD_OPER)
  @ T_ROW+4,4 say "Данные редактировал пользователь: "+crypt(base1->p1,gpasskod)
  base1->(dbCloseArea())
endif
@ T_ROW+5,4 say "Отчётная дата для направления сведений (по состоянию на 09:00)" get mdate_r
status_key("^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода отчётной даты и ред-ие свободных коек")
myread()
setcolor(tmp_color)
if lastrec() == K_ESC
  fl := .f.
elseif empty(mdate_r)
  fl := func_error(4,"Не введена отчётная дата")
elseif mdate_r > sys_date+1
  fl := func_error(4,"Отчётная дата больше системной")
elseif !empty(d7->DATE_R_OUT) .and. mdate_r <= d7->DATE_R_OUT
  fl := func_error(4,"Некорректная отчётная дата. В ТФОМС уже был направлен пакет I07 за "+date_8(d7->DATE_R_OUT)+"г.")
endif
restscreen(buf)
if !fl
  close databases
  G_SUnLock(str_sem)
  return NIL
endif
if mdate_r != d7->DATE_R_EDI
  select D7
  G_RLock(forever)
  d7->DATE_R_EDI := mdate_r
  UnLock
  Commit
endif
G_Use(dir_server+"mo_n7out",,"N7")
index on padr(inieditspr(A__MENUVERT, arr_t007, n7->PROFIL_K),60)+str(PROFIL_K,3)+str(usl_ok,1)+;
         padr(inieditspr(A__MENUVERT, glob_V002, n7->PROFIL),20)+str(PROFIL,3) to (cur_dir+"tmp_n7")
go top
//
box_shadow(0,0,4,79,color1,"Редактирование количества свободных коек по профилям в стационаре",color14)
if empty(d7->DATE_R_OUT)
  @ 1,2 say "Данные ещё ни разу не отправлялись в ТФОМС" color color1
else
  @ 1,2 say "Последний раз данные в ТФОМС отправлены за отчётную дату "+date_8(d7->DATE_R_OUT)+"г." color color1
endif
@ 2,2 say "Последний раз данные редактировались "+date_8(d7->DATE_E)+"г. в "+d7->TIME_E+;
          " - "+iif(d7->END_EDIT==1,"", "не ")+"завершено" color color1
@ 3,2 say "Отчётная дата для направления сведений (по состоянию на 09:00) "+date_8(d7->DATE_R_EDI) color color1
t_arr[BR_TOP] := 5
t_arr[BR_BOTTOM] := maxrow()-5
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_COLOR] := color0
t_arr[BR_OPEN] := {|| f2_263_s_svob_kojki(,,"open") }
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B,R/BG,W+/R",.t.}
blk := {|| f0_263_s_svob_kojki() }
t_arr[BR_COLUMN] := {{" ", {|| iif(n7->usl_ok==2,"д","с") }, blk },;
                     {" Профиль койки", {|| padr(inieditspr(A__MENUVERT,arr_T007,n7->PROFIL_K),16) }, blk },;
                     {"Профиль м/пом.", {|| padr(inieditspr(A__MENUVERT,glob_V002,n7->PROFIL),14) }, blk },;
                     {"сро;леч;к/д", {|| put_val(n7->kol_kd,3) }, {|| {5,5}} },; // 
                     {"Кол.;коек", {|| put_val(n7->QUANTITY,4) }, blk },; // количество коек
                     {"сост;на;пред", {|| put_val(n7->Q_P,4) }, blk },; // состояло пациентов на начало пред.суток
                     {"пост;за;пред", {|| put_val(n7->Q_AP,4) }, blk },; // поступило пациентов за пред.сутки
                     {"выбы;за;пред", {|| put_val(n7->Q_DP,4) }, blk },; // выбыло пациентов за пред.сутки
                     {"зап;гос;тек", {|| put_val(n7->Q_HP,3) }, blk },; // запланировано госпитализаций на тек.день
                     {"Кол.;своб;мест", {|| put_val(n7->PLACE_FREE,4) }, blk },; // количество свободных мест
                     {"кол;для;муж", {|| put_val(n7->PF_M,3) }, blk },; // --""-- для мужчин
                     {"кол;для;жен", {|| put_val(n7->PF_W,3) }, blk },; // --""-- для женщин
                     {"кол;для;дет", {|| put_val(n7->PF_C,3) }, blk }}  // --""-- для детей
t_arr[BR_STEP_FUNC] := {|| f1_263_s_svob_kojki(1) }
t_arr[BR_EDIT] := {|nk,ob| f2_263_s_svob_kojki(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход ^<Enter>^ редактирование ^<Ins>^ добавление ^<Del>^ удаление ^<F9>^ печать") }
t_arr[BR_FL_NOCLEAR] := .t.
f1_263_s_svob_kojki(0)
edit_browse(t_arr)
f1_263_s_svob_kojki(2)
if n7->(lastrec()) > 0
  keyboard ""
  if (k := input_value(maxrow()-5,2,maxrow()-3,77,color1,;
             space(4)+"Редактирование завершено и данные готовы к отправке в ТФОМС?",;
             d7->END_EDIT,mm_danet)) == NIL
    k := 0
  endif
endif
select D7
G_RLock(forever)
d7->DATE_E := sys_date            // дата редактирования
d7->TIME_E := hour_min(seconds()) // время редактирования
d7->END_EDIT := k                 // 0-не закончено, 1-закончено редактирование
d7->KOD_OPER := asc(kod_polzovat) // код оператора
close databases
G_SUnLock(str_sem)
restscreen(buf)
return NIL

***** 24.08.14
Function f0_263_s_svob_kojki()
Local k1, k2
if n7->QUANTITY == 0
  return {3,4}
else
  k1 := n7->QUANTITY - (n7->Q_P + n7->Q_AP - n7->Q_DP + n7->Q_HP)
  k2 := n7->PF_M + n7->PF_W + n7->PF_C
  if n7->PLACE_FREE < 0
    return {5,6}
  elseif k1 == k2
    if k1 != n7->PLACE_FREE
      G_RLock(forever)
      n7->PLACE_FREE := k1
      UnLock
      Commit
    endif
  else
    return {5,6}
  endif
endif
return {1,2}

***** 21.08.14
Function f1_263_s_svob_kojki(k)
Static buf
Local ta[2], k1, k2
if k == 0
  buf := box_shadow(maxrow()-4,0,maxrow()-1,79,color1,"Профиль койки и профиль медицинской помощи","B+/B")
elseif k == 1
  @ maxrow()-3,1 say padc(alltrim(inieditspr(A__MENUVERT, arr_t007, n7->PROFIL_K)),78) color color14
  @ maxrow()-2,1 say padc(alltrim(inieditspr(A__MENUVERT, glob_V002, n7->PROFIL)),78) color color14
elseif k == 2
  rest_box(buf)
endif
return NIL

***** 19.02.17
Function f2_263_s_svob_kojki(nKey,oBrow,regim)
Local lkod, buf, r1, rec, i, ret := -1, lcodem, n1, n2, tmp_color, arr_p := {},;
      n_file := "sv_kojki"+stxt, sh := 80, HH := 80, t_arr[4], s1, s2, s3, s4,;
      tmp_V006 := {{"Стационар",1},{"Дневной стационар",2}}
if regim == "open"
  select N7
  go top
  ret := !eof()
elseif regim == "edit"
  do case
    case nKey == K_INS .or. nKey == K_ENTER
      if nKey == K_INS
        rec := n7->(recno())
        dbeval({|| aadd(arr_p,{n7->PROFIL_K,n7->PROFIL,iif(n7->usl_ok==2,2,1)}) })
        goto (rec)
      endif
      Private ;
        musl_ok, m1usl_ok := iif(nKey==K_INS.or.n7->usl_ok!=2, 1, n7->usl_ok),; // условия оказания мед.помощи
        mprofil_k, m1profil_k := iif(nKey == K_INS, 0, n7->PROFIL_K),; // профиль койки по справочнику T007
        mprofil, m1profil := iif(nKey == K_INS, 0, n7->PROFIL),; // профиль мед.помощи по справочнику V002
        mkol_kd     := iif(nKey == K_INS, 0, n7->kol_kd    ),;
        mQUANTITY   := iif(nKey == K_INS, 0, n7->QUANTITY  ),;
        mQ_P        := iif(nKey == K_INS, 0, n7->Q_P       ),;
        mQ_AP       := iif(nKey == K_INS, 0, n7->Q_AP      ),;
        mQ_DP       := iif(nKey == K_INS, 0, n7->Q_DP      ),;
        mQ_HP       := iif(nKey == K_INS, 0, n7->Q_HP      ),;
        mPLACE_FREE := iif(nKey == K_INS, 0, n7->PLACE_FREE),;
        mPF_M       := iif(nKey == K_INS, 0, n7->PF_M      ),;
        mPF_W       := iif(nKey == K_INS, 0, n7->PF_W      ),;
        mPF_C       := iif(nKey == K_INS, 0, n7->PF_C      ),;
        gl_area := {1,0,23,79,0}, mPLACE_FREE2
      mUSL_OK := inieditspr(A__MENUVERT, tmp_V006, m1USL_OK)
      mprofil_k := inieditspr(A__MENUVERT, arr_t007, M1PROFIL_K)
      mprofil := inieditspr(A__MENUVERT, glob_V002, M1PROFIL)
      mPLACE_FREE2 := mPF_M + mPF_W + mPF_C
      tmp_color := setcolor()
      buf := savescreen()
      r1 := 5//maxrow()-18
      if nKey == K_ENTER
        keyboard chr(K_TAB)+iif(empty(mkol_kd),"",chr(K_TAB))
      endif
      do while .t.
        setcolor(cDataCGet)
        ClrLines(r1,maxrow()-1)
        @ r1,0 say padc("Свободные койки ("+iif(nKey == K_INS,"добавление","редактирование")+")",80) color "B/B*"
        @ r1+1,1  say "Условия оказания медицинской помощи" get musl_ok ;
                  reader {|x|menu_reader(x,tmp_V006,A__MENUVERT,,,.f.)} ;
                  when nKey == K_INS
        @ r1+2,1  say "Профиль койки" get mprofil_k ;
                  reader {|x|menu_reader(x,{{|k,r,c|f_get_profil_k(k,r,c)}},A__FUNCTION,,,.f.)} ;
                  valid {|g,o| f_valid_profil_k(g,o) } ;
                  when nKey == K_INS
        @ r1+3,1  say "Профиль медицинской помощи" get mprofil ;
                  reader {|x|menu_reader(x,{{|k,r,c|f_get_profil(k,r,c,m1profil_k)}},A__FUNCTION,,,.f.)} ;
                  when m1profil_k > 0 .and. nKey == K_INS
        @ r1+4,1  say "Общее количество коек по данному профилю         " get mQUANTITY pict "999" valid {|| count_place_free() }
        @ r1+5,1  say "Планируемый средний срок лечения в койко-днях    " color color8 get mkol_kd color color8 pict "999"
        @ r1+6,1  say "Состояло пациентов на начало предшествующих суток" get mQ_P pict "999" valid {|| count_place_free() }
        @ r1+7,1  say "Поступило пациентов за предшествующие сутки      " get mQ_AP pict "999" valid {|| count_place_free() }
        @ r1+8,1  say "Выбыло пациентов в течение предшествующих суток  " get mQ_DP pict "999" valid {|| count_place_free() }
        @ r1+9,1  say "Запланировано госпитализаций на отчётную дату    " get mQ_HP pict "999" valid {|| count_place_free() }
        @ r1+10,1  say "Общее количество свободных мест на текущие сутки " get mPLACE_FREE color color8 pict "999" when .f.
        @ r1+10,col()+1 get mPLACE_FREE2 color color14 pict "999" when .f.
        @ r1+11,1 say "Количество свободных мест на текущие сутки для мужчин" get mPF_M pict "999" valid {|| count_place_free() }
        @ r1+12,1 say "количество свободных мест на текущие сутки для женщин" get mPF_W pict "999" valid {|| count_place_free() }
        @ r1+13,1 say "количество свободных мест на текущие сутки для детей " get mPF_C pict "999" valid {|| count_place_free() }
        status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода")
        myread()
        k := f_alert({padc("Выберите действие",60,".")},;
                   {" Выход без записи "," Запись "," Возврат в редактирование "},;
                   if(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
        if k == 3
          loop
        elseif k == 2
          if empty(m1profil_k)
            func_error(4,"Не введен профиль койки.")
            loop
          endif
          if empty(m1profil)
            func_error(4,"Не введен профиль медицинской помощи.")
            loop
          endif
          select N7
          if nKey == K_INS
            if ascan(arr_p,{|x| x[1]==m1PROFIL_K .and. x[2]==m1PROFIL .and. x[3]==m1usl_ok }) > 0
              func_error(4,"В таблице уже есть строка с данным профилем койки и медицинской помощи.")
              loop
            endif
            AddRecN()
            n7->usl_ok := m1usl_ok
            n7->PROFIL_K := m1profil_k // профиль койки по справочнику T007
            n7->PROFIL := m1profil // профиль мед.помощи по справочнику V002
            fl_found := .t.
          else
            G_RLock(forever)
          endif
          n7->QUANTITY   := mQUANTITY
          n7->kol_kd     := mkol_kd
          n7->Q_P        := mQ_P
          n7->Q_AP       := mQ_AP
          n7->Q_DP       := mQ_DP
          n7->Q_HP       := mQ_HP
          n7->PLACE_FREE := mPLACE_FREE
          n7->PF_M       := mPF_M
          n7->PF_W       := mPF_W
          n7->PF_C       := mPF_C
          dbUnLock()
          Commit
          ret := 0
        endif
        exit
      enddo
      if !fl_found
        ret := 1
      endif
      setcolor(tmp_color)
      restscreen(buf)
    case nKey == K_DEL .and. f_Esc_Enter(2,.t.)
      DeleteRec()
      go top
      ret := iif(eof(), 1, 0)
    case nKey == K_F9
      rec := n7->(recno())
      ad := _263_put_10_days(d7->DATE_R_EDI)
      arr_title := {;
"──┬──────────────────────┬───────────────────────┬────┬─────────────┬───────────",;
"ус│                      │                       │кол.│за пред.сутки│ свободных ",;
"ло│ профиль койки        │ профиль мед.помощи    │коек│и на тек.день│   коек    ",;
"──┴──────────────────────┴───────────────────────┴────┴─────────────┴───────────"}
      for i := 1 to 10
        arr_title[1] += "┬───"
        arr_title[2] += "│"+left(dtoc(ad[i,1]),3)
        arr_title[3] += "│"+substr(dtoc(ad[i,1]),4,3)
        arr_title[4] += "┴───"
      next
      sh := len(arr_title[1])
      fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
      add_string("")
      add_string(center("Количество стационарных коек на утро "+date_8(d7->DATE_R_EDI)+"г.",sh))
      for i := 1 to perenos(t_arr,glob_mo[_MO_FULL_NAME],sh)
        add_string(center(alltrim(t_arr[i]),sh))
      next
      aeval(arr_title, {|x| add_string(x) } )
      n1 := 23 ; n2 := 23
      select N7
      go top
      do while !eof()
        s1 := iif(n7->usl_ok==2, "дн", "ст")+" "
        s2 := s3 := s4 := space(3)
        perenos(t_arr,inieditspr(A__MENUVERT,arr_T007,n7->PROFIL_K),n1-1)
        s1 += padr(t_arr[1],n1)
        s2 += padr(t_arr[2],n1)
        s3 += padr(t_arr[3],n1)
        s4 += padr(t_arr[4],n1)
        perenos(t_arr,inieditspr(A__MENUVERT,glob_V002,n7->PROFIL),n2-1)
        s1 += padr(t_arr[1],n2)
        s2 += padr(t_arr[2],n2)
        s3 += padr(t_arr[3],n2)
        s4 += padr(t_arr[4],n2)
        s1 += str(n7->QUANTITY,4)+"  состояло -"+str(n7->Q_P ,3)
        s2 += space(4)           +"  поступило-"+str(n7->Q_AP,3)
        s3 += space(4)           +"  выбыло   -"+str(n7->Q_DP,3)
        s4 += space(4)           +"  поступит -"+str(n7->Q_HP,3)
        s1 += " всего  -"+str(n7->PLACE_FREE,3)
        s2 += " мужских-"+str(n7->PF_M,3)
        s3 += " женских-"+str(n7->PF_W,3)
        s4 += " детских-"+str(n7->PF_C,3)
        for i := 1 to 10
          pole1 := "n7->PLACE"+lstr(i)
          pole2 := "n7->PF_M"+lstr(i)
          pole3 := "n7->PF_W"+lstr(i)
          pole4 := "n7->PF_C"+lstr(i)
          s1 += put_val(&pole1,4)
          s2 += put_val(&pole2,4)
          s3 += put_val(&pole3,4)
          s4 += put_val(&pole4,4)
        next
        if verify_FF(HH-5,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(s1)
        add_string(s2)
        add_string(s3)
        add_string(s4)
        add_string(replicate("─",sh))
        skip
      enddo
      goto (rec)
      fclose(fp)
      viewtext(n_file,,,,(sh>80),,,6)
  endcase
endif
return ret

***** 24.08.14
Static Function count_place_free()
mplace_free := mQUANTITY - (mQ_P + mQ_AP - mQ_DP + mQ_HP)
mPLACE_FREE2 := mPF_M + mPF_W + mPF_C
update_get("mplace_free")
return update_get("mplace_free2")

***** 19.02.17
Function _263_put_10_days(mdate)
Local i := 0, j, d := mdate, d2, arr[10,4]
afillall(arr,0)
do while .t.
  if is_work_day(++d)
    arr[++i,1] := d
    if i == 10
      exit
    endif
  endif
enddo
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"mo_nnapr",,"NAPR")
set relation to kod_k into KART
index on str(profil_k_4,3)+str(profil_4,3)+str(usl_ok_4,1) to (cur_dir+"tmp_napr") ;
      for empty(TIP_ANNUL) .and. KOD_F_4out >= 0 .and. TYPE_H_4 > 0 .and. !empty(date_h_4) .and. empty(date_6)
select N7
go top
do while !eof()
  select NAPR
  find (str(n7->profil_k,3)+str(n7->profil,3)+str(n7->usl_ok,1))
  do while napr->profil_k_4 == n7->profil_k .and. napr->profil_4 == n7->profil ;
                                            .and. napr->usl_ok_4 == n7->usl_ok .and. !eof()
    if empty(d2 := napr->DNEJ_H_4)
      if empty(d2 := n7->kol_kd)
        d2 := 7 // по умолчанию срок лечения 7 койко-дней 
      endif
    endif
    d2 := mdate+d2
    if count_years(kart->date_r,napr->date_h_4) < 18
      j := 4
    else
      j := iif(kart->pol == "М", 2, 3)
    endif
    for d := mdate+1 to d2-1
      if (i := ascan(arr,{|x| x[1] == d})) > 0
        arr[i,j] --
      endif
    next
    if (i := ascan(arr,{|x| x[1] == d2})) > 0
      arr[i,j] ++
    endif
    skip
  enddo
  select N7
  G_RLock(forever)
  for i := 1 to 10
    pole1 := "n7->PLACE"+lstr(i)
    pole2 := "n7->PF_M"+lstr(i)
    pole3 := "n7->PF_W"+lstr(i)
    pole4 := "n7->PF_C"+lstr(i)
    v2 := iif(n7->PF_M + arr[i,2] < 0, 0, n7->PF_M + arr[i,2]) 
    v3 := iif(n7->PF_W + arr[i,3] < 0, 0, n7->PF_W + arr[i,3]) 
    v4 := iif(n7->PF_C + arr[i,4] < 0, 0, n7->PF_C + arr[i,4])
    if v2 > n7->PF_M
      v2 := n7->PF_M
    endif 
    if v3 > n7->PF_W
      v3 := n7->PF_W
    endif 
    if v4 > n7->PF_C
      v4 := n7->PF_C
    endif
    &pole2 := v2 
    &pole3 := v3 
    &pole4 := v4
    &pole1 := v2 + v3 + v4  
  next i
  UnLock          
  skip
enddo
Commit  
kart->(dbCloseArea())
napr->(dbCloseArea())
return arr