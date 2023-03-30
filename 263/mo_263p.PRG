***** mo_263p.prg - режимы поликлиники для задачи по приказу 263-ФФОМС
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 01.08.14 Проверка того, что ещё не сделано в поликлинике
Function _263_p_proverka()
ne_real()
return NIL

*

***** 19.02.17 Ввод направлений на госпитализацию по поликлинике
Function _263_p_napr()
Static str_sem := "_263_p_napr"
Local buf := save_maxrow(), blk, t_arr[BR_LEN], fl, n
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
Private arr_m
if (arr_m := year_month(T_ROW,T_COL+5)) == NIL
  G_SUnLock(str_sem)
  return NIL
endif
mywait()
R_Use(dir_server+"kartote_",,"_KART_")
R_Use(dir_server+"kartotek",,"_KART")
set relation to kod into _KART_
R_Use(dir_server+"mo_nfile",,"NF")
G_Use(dir_server+"mo_nnapr",,"NAPR")
set relation to kod_k into _KART, to KOD_F_1out into NF
if arr_m[5] == arr_m[6]
  index on str(n_napr,6) to (cur_dir+"tmp_napr") ;
        for n_napr > 0 .and. date_d == arr_m[5] ;
        descending
else
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") ;
        for n_napr > 0 .and. between(date_d,arr_m[5],arr_m[6])
  go top
  if eof()
    close databases
    G_SUnLock(str_sem)
    rest_box(buf)
    return func_error(4,"Не обнаружено направлений "+arr_m[4])
  endif
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_TITUL] := "Ввод / редактирование направлений на госпитализацию"
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_COLOR] := color0
t_arr[BR_OPEN] := {|| f2_263_p_napr(,,"open") }
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B,RB/BG,W+/RB,R/BG,W+/R",.t.}
blk := {|| iif(empty(napr->KOD_F_1out), {3,4}, ;
               iif(napr->t_ans_1==0, {5,6}, ;
                   iif(napr->t_ans_1==1, {1,2}, {7,8} ))) }
n := iif(work_otd_263 == 1, 22, 28)
t_arr[BR_COLUMN] := {{"№ напр", {|| str(napr->n_napr,6) }, blk },;
                     {"  Дата", {|| date_8(napr->date_d) }, blk },;
                     {" Ф.И.О.", {|| left(_kart->fio,n) }, blk },;
                     {" ", {|| iif(napr->usl_ok_1==2,"д","с") }, blk },;
                     {"Госп-ия", {|| date_8(napr->date_h_1) }, blk },;
                     {" Статус", {|| padr(f1_263_p_napr(),22) }, blk }}
if work_otd_263 == 1
  Ins_Array(t_arr[BR_COLUMN],5,{" Отд.", {|| _263_put_otd(napr->otd_1) }, blk })
endif
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход ^<Enter>^ просмотр/редактирование ^<Ins>^ добавление ^<Del>^ удаление") }
t_arr[BR_EDIT] := {|nk,ob| f2_263_p_napr(nk,ob,"edit") }
edit_browse(t_arr)
close databases
G_SUnLock(str_sem)
rest_box(buf)
return NIL

***** 11.09.14
Function _263_put_otd(lotd)
Local s := padc("-",5), tmp_select
if lotd > 0
  tmp_select := select()
  R_Use(dir_server+"mo_otd",,"_OTD")
  goto (lotd)
  if empty(s := _otd->short_name)
    s := "не вв"
  endif
  _otd->(dbCloseArea())
  select (tmp_select)
endif
return s

*

***** 21.02.17
Function f1_263_p_napr()
Local s := "ошибка"
if empty(napr->KOD_F_1out)
  s := "ещё не отправлен в ТФОМС"
elseif napr->t_ans_1 == 0
  s := "не получен ответ из ТФОМС"
elseif napr->t_ans_1 == 1
  s := "направлено в стационар"
  if napr->KOD_F_6in > 0 .or. ;
     (napr->KOD_F_6out > 0 .and. napr->t_ans_4 == 1 .and. napr->CODEM_1 == glob_mo[_MO_KOD_TFOMS])
    s := " выбытие "+date_8(napr->date_6)
  elseif napr->KOD_F_4in > 0 .or. ;
         (napr->KOD_F_4out > 0 .and. napr->t_ans_4 == 1 .and. napr->CODEM_1 == glob_mo[_MO_KOD_TFOMS])
    s := "госпитализир. "+date_8(napr->date_h_4)
  elseif napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0
    s := "аннулировано "+date_8(napr->date_3)
  //elseif napr->KOD_F_2in > 0
    //s := "будет гос-ван "+date_8(napr->date_h_2)
  endif
endif
return s

** 06.11.22
Function f2_263_p_napr(nKey,oBrow,regim)
Static mm_forma, s1stac_mo := "      ", s1vrach := 0
Local bg := {|o,k| get_MKB10(o,k) }
Local ret := -1, rec, i, k, s, tmp_color, buf, s_error := "",;
      tmp_V006 := {{"Стационар",1},{"Дневной стационар",2}}
if empty(s1stac_mo) .and. is_napr_stac // по умолчанию направляем в наш
  s1stac_mo := glob_mo[_MO_KOD_TFOMS]  // стационар (если он у нас есть)
endif
if mm_forma == NIL
  mm_forma := aclone(getV014())
  Del_Array(mm_forma, 1) // убираем "экстренную" помощь
endif
do case
  case regim == "open"
    select NAPR
    go top
    ret := !eof()
  case regim == "edit"
    if nKey == K_INS .or. (napr->KOD > 0 .and. nKey == K_ENTER)
      rec := napr->(recno())
      Private mn_napr := iif(nKey == K_INS, 0, napr->n_napr),; // уникальный номер направления (п-ка)
              mfio    := iif(nKey == K_INS, "", _kart->fio),;
              mdate_r := iif(nKey == K_INS, ctod(""), _kart->date_r),;
              mpol    := iif(nKey == K_INS, "", _kart->pol),;
              mphone  := iif(nKey == K_INS, .t., emptyall(_kart_->PHONE_M,_kart_->PHONE_H,_kart_->PHONE_W))
      if nKey == K_INS
        if !fl_found
          colorwin(pr1+3,0,pr1+3,79,"N/N","W+/N")
          colorwin(pr1+3,0,pr1+3,79,"N/N","W+/B")
        endif
        k := polikl1_kart()
        close databases // если вдруг вышли по <Esc>
        //
        R_Use(dir_server+"kartote_",,"_KART_")
        R_Use(dir_server+"kartotek",,"_KART")
        set relation to kod into _KART_
        if k > 0
          goto (glob_kartotek)
          mfio    := _kart->fio
          mdate_r := _kart->date_r
          mpol    := _kart->pol
          mphone  := emptyall(_kart_->PHONE_M,_kart_->PHONE_H,_kart_->PHONE_W)
        endif
        R_Use(dir_server+"mo_nfile",,"NF")
        G_Use(dir_server+"mo_nnapr",,"NAPR")
        set relation to kod_k into _KART, to KOD_F_1out into NF
        set index to (cur_dir+"tmp_napr")
        if k <= 0
          func_error(4,"Для добавления направления сначала необходимо выбрать пациента!")
          return iif(fl_found,-1,1)
        endif
        index on str(N_NAPR,6) to (cur_dir+"tmp_napr1") for n_napr > 0
        for i := 1 to 999999
          find (str(i,6))
          if !found() // нашли свободный номер
            mn_napr := i
            exit
          endif
        next
        set index to (cur_dir+"tmp_napr")
        goto (rec)
        if empty(mn_napr)
          func_error(10,"Не удалось найти свободный номер направления. Обратитесь к разработчикам!")
          return iif(fl_found,-1,1)
        endif
      elseif napr->t_ans_1 == 2
        R_Use(dir_server+"mo_nfina",,"NFN")
        index on str(kod_n,6) to (cur_dir+"tmp_nfn") for kod_f == napr->KOD_F_1out
        find (str(napr->kod,6))
        if found()
          s_error := "ошибка " + lstr(nfn->OSHIB) + " - " + inieditspr(A__MENUVERT, getT008(), nfn->OSHIB)
          if !empty(nfn->IM_POL)
            s_error += " (в поле "+alltrim(nfn->IM_POL)+")"
          endif
        endif
        nfn->(dbCloseArea())
        select NAPR
      endif
      tmp_color := setcolor()
      buf := savescreen()
      mywait()
      Private ;
        mkod := iif(nKey == K_INS, 0, napr->KOD),;
        m1kod_k := iif(nKey == K_INS, glob_kartotek, napr->kod_k),; // код по картотеке
        md_napr := iif(nKey == K_INS, min(arr_m[6],sys_date), napr->DATE_D),; // дата направления
        motd := space(10), m1otd := if(nKey == K_INS, 0, napr->otd_1),;
        mkod_diag := iif(nKey == K_INS, space(6), napr->ds_1),; // диагноз поликлиники
        musl_ok, m1usl_ok := iif(nKey==K_INS.or.napr->usl_ok_1!=2, 1, napr->usl_ok_1),; // условия оказания мед.помощи
        mdisp, m1disp := iif(nKey == K_INS, 0, napr->disp_1),; // условия оказания мед.помощи
        mforma, m1forma := iif(nKey == K_INS, 3, napr->F_MEDC_1),; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
        mdate_hosp := iif(nKey == K_INS, nil, napr->DATE_H_1),; // планируемая дата госпитализации
        mprofil_k, m1profil_k := iif(nKey == K_INS, 0, napr->PROFIL_K_1),; // профиль койки по справочнику T007
        mprofil, m1profil := iif(nKey == K_INS, 0, napr->PROFIL_1),; // профиль мед.помощи по справочнику V002
        m1vrach := iif(nKey == K_INS, s1vrach, napr->VRACH_1),; // лечащий врач по mo_pers
        MVRACH := space(10),; // фамилия и инициалы лечащего врача
        MTAB_NOM := 0, m1prvs := 0,; // таб.№ лечащего врача
        mstac_mo := space(10), ;
        m1stac_mo := iif(nKey == K_INS, s1stac_mo, napr->S_CODEM),;  // код стационара
        gl_area := {1,0,23,79,0}
      if work_otd_263 == 1
        Private pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}
        make_arr_uch_otd(md_napr)
        if (i := ascan(pr_arr,{|x| x[1] == m1otd } )) > 0
          motd := pr_arr[i,2]
        elseif nKey == K_ENTER .and. m1otd > 0
          motd := "! некорректное отделение !"
        endif
      endif
      mdisp := inieditspr(A__MENUVERT, mm_danet, m1disp)
      mUSL_OK := inieditspr(A__MENUVERT, tmp_V006, m1USL_OK)
      mforma := inieditspr(A__MENUVERT, getV014(), m1forma)
      mprofil_k := inieditspr(A__MENUVERT, arr_t007, M1PROFIL_K)
      mprofil := inieditspr(A__MENUVERT, getV002(), M1PROFIL)
      DEFAULT mdate_hosp TO md_napr+30
      if !empty(m1stac_mo)
        mstac_mo := ret_mo(m1stac_mo)[_MO_SHORT_NAME]
      endif
      if m1vrach > 0
        R_Use(dir_server+"mo_pers",,"P2")
        goto (m1vrach)
        MTAB_NOM := p2->tab_nom
        m1prvs := ret_new_spec(p2->prvs,p2->prvs_new)
        mvrach := padr(fam_i_o(p2->fio)+" "+ret_tmp_prvs(0,m1prvs),36)
        p2->(dbCloseArea())
        select NAPR
      endif
      Private r1 := maxrow()-15
      if work_otd_263 == 1
        --r1
      endif
      do while .t.
        setcolor(cDataCGet)
        ClrLines(r1,maxrow()-1)
        @ r1-1,0 say padc(iif(nKey == K_INS,"Добавление","Редактирование")+" направления на госпитализацию",80) color "B/B*"
        i := r1
        ++i ; @ i,1 say "Пациент" get mfio when .f.
              @ row(),col()+2 say "Дата р." get mdate_r when .f.
        ++i ; @ i,1 say "направление: №" get mn_napr when .f. pict "999999"
              @ row(),col()+3 say "дата" get md_napr when .f.
        if mphone
              @ row(),col()+3 say " не введён на один телефон " color "GR+/R*"
        endif
        ++i ; @ i,1 say "Условия оказания, в которые направляется пациент" get musl_ok ;
                    reader {|x|menu_reader(x,tmp_V006,A__MENUVERT,,,.f.)}
        ++i ; @ i,1 say "Диагноз направившего учреждения" get mkod_diag picture "@K@!" ;
                    reader {|o|MyGetReader(o,bg)} ;
                    valid val1_10diag(.t.,.f.,.f.,md_napr,mpol)
        ++i ; @ i,1 say "Направление выдано по результатам диспансеризации/профосмотра взрослых" get mdisp ;
                    reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
        ++i ; @ i,1 say "Направил на госпитализацию врач" get MTAB_NOM pict "99999" ;
                    valid {|g| v_kart_vrach(g,.t.) }
        @ row(),col()+1 get mvrach when .f. color color14
        if work_otd_263 == 1
        ++i ; @ i,1 say "                           из отделения"
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
        ++i ; @ i,1 say "Форма оказания медицинской помощи" get mforma ;
                    reader {|x|menu_reader(x,mm_forma,A__MENUVERT,,,.f.)}
        ++i ; @ i,1 say "Планируемая дата госпитализации" get mdate_hosp
        ++i ; @ i,1 say "Направляется в стационар" get mstac_mo ;
                    reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)}
        ++i ; @ i,1 say "Профиль койки" get mprofil_k ;
                    reader {|x|menu_reader(x,{{|k,r,c|f_get_profil_k(k,r,c)}},A__FUNCTION,,,.f.)} ;
                    valid {|g,o| f_valid_profil_k(g,o) }
        ++i ; @ i,1 say "Профиль медицинской помощи" get mprofil ;
                    reader {|x|menu_reader(x,{{|k,r,c|f_get_profil(k,r,c,m1profil_k)}},A__FUNCTION,,,.f.)} ;
                    when m1profil_k > 0
        if !empty(s_error)
          ++i ; @ i,1 say s_error color color8
        endif
        if nKey == K_ENTER .and. !(empty(napr->KOD_F_1out) .or. napr->t_ans_1 == 2)
          s := ""
          if !empty(napr->KOD_F_1out) .and. !empty(nf->NAME_F)
            s := "(в файле "+alltrim(nf->NAME_F)+") "
          endif
          if napr->KOD_F_6in > 0 .or. ;
             (napr->KOD_F_6out > 0 .and. napr->t_ans_4 == 1 .and. napr->CODEM_1 == glob_mo[_MO_KOD_TFOMS])            
            s := "выбыл из стационара "+date_8(napr->date_6)
          elseif napr->KOD_F_4in > 0 .or. ;
                 (napr->KOD_F_4out > 0 .and. napr->t_ans_4 == 1 .and. napr->CODEM_1 == glob_mo[_MO_KOD_TFOMS])
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
          //elseif napr->KOD_F_2in > 0
            //s := "будет госпитализирован в стационаре "+date_8(napr->date_h_2)
          endif
          ++i ; @ i,1 say s color color8
          stat_msg("Ответ из ТФОМС "+iif(napr->t_ans_1==0,"ещё не","уже")+" получен. Редактирование направления запрещено!")
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
          if empty(md_napr)
            func_error(4,"Не введена дата направления.")
            loop
          endif
          if empty(mdate_hosp)
            func_error(4,"Не введена дата госпитализации.")
            loop
          endif
          if mdate_hosp < md_napr
            func_error(4,"Дата госпитализации меньше даты направления.")
            loop
          endif
          if mdate_hosp - md_napr > 30
            func_error(4,"Дата госпитализации более 30 дней от даты направления!")
            loop
          endif
          if empty(m1vrach)
            func_error(4,"Не введен врач.")
            loop
          endif
          if empty(m1stac_mo)
            func_error(4,"Не введен стационар.")
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
            func_error(4,"Не введен диагноз направившего учреждения.")
            loop
          endif
          select NAPR
          if nKey == K_INS
            index on str(kod,6) to (cur_dir+"tmp_napr1")
            set index to (cur_dir+"tmp_napr1"),(cur_dir+"tmp_napr")
            AddRec(6)
            napr->KOD := recno() // код направления - номер записи
            rec := mkod := napr->KOD
            napr->KOD_K := m1kod_k // код по картотеке
            napr->N_NAPR := mn_napr // уникальный номер направления (п-ка)
            fl_found := .t.
          else
            goto (mkod)
            G_RLock(forever)
          endif
          napr->NUM_D := glob_mo[_MO_KOD_TFOMS]+"_"+strzero(mn_napr,6) // номер направления
          napr->DATE_D := md_napr // дата направления
          napr->MCOD_1 := glob_mo[_MO_KOD_FFOMS] // код поликлиники
          napr->CODEM_1 := glob_mo[_MO_KOD_TFOMS] // код поликлиники
          napr->otd_1 := m1otd
          napr->USL_OK_1 := m1usl_ok
          napr->disp_1 := m1disp
          napr->DS_1 := mkod_diag // диагноз поликлиники
          napr->F_MEDC_1 := m1forma // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
          napr->ID_1 := mo_guid(1,mkod) // GUID30+lstr(mo_nnapr->KOD) ID направления
          napr->DATE_H_1 := mdate_hosp // планируемая дата госпитализации
          napr->PROFIL_K_1 := m1profil_k // профиль койки по справочнику T007
          napr->PROFIL_1 := m1profil // профиль мед.помощи по справочнику V002
          napr->VRACH_1 := m1vrach // лечащий врач по mo_pers
          napr->KOD_F_1out := 0 // код файла - по файлу mo_nfile
          napr->KOD_F_1in := 0 // код файла - по файлу mo_nfile
          napr->S_MCOD := ret_mo(m1stac_mo)[_MO_KOD_FFOMS] // код стационара
          napr->S_CODEM := m1stac_mo //_код стационара
          dbUnLock()
          Commit
          s1stac_mo := m1stac_mo
          s1vrach := m1vrach
          set index to (cur_dir+"tmp_napr")
          goto (rec)
          ret := 0
        endif
        exit
      enddo
      if !fl_found
        ret := 1
      endif
      setcolor(tmp_color)
      restscreen(buf)
    elseif nKey == K_CTRL_ENTER
      if napr->INF_PAC == 0
        //func_error(4,"Пациента о госпитализации должна информировать СМО")
      elseif napr->INF_PAC == 1
        func_error(4,"Пациента о госпитализации должна проинформировать СМО")
      elseif napr->INF_PAC == 3
        func_error(4,"Пациент уже проинформирован о госпитализации")
      else
        //
      endif
      ret := 0
    elseif nKey == K_DEL
      if empty(napr->KOD_F_1out) .or. napr->t_ans_1 == 2
        if f_Esc_Enter(2,.t.)
          select NAPR
          DeleteRec()
          go top
          ret := 1
        endif
      elseif !empty(napr->KOD_F_1out) .and. napr->t_ans_1 == 1
        func_error(4,'Аннулирование направления производится в режиме "Аннулирование"!')
      else
        func_error(4,"Ответ из ТФОМС ещё не получен. Удаление данного направления запрещено!")
      endif
    else
      keyboard ""
    endif
endcase
return ret

*
***** 21.02.17
Function for_263_p_annul()
Local fl := (n_napr > 0)
if arr_m[5] == arr_m[6]
  fl := (date_d == arr_m[5])
else
  fl := between(date_d,arr_m[5],arr_m[6])
endif
if fl  
  fl := (KOD_F_1out > 0 .and. t_ans_1 == 1)  // отправлено в ТФОМС
endif
if fl  
  fl := (!empty(napr->date_3) .or. empty(KOD_F_4in))  // и не госпитализирован
endif  
return fl

***** 21.02.17 Аннулирование выписанных направлений на госпитализацию по поликлинике
Function _263_p_annul()
Static str_sem := "_263_p_annul"
Local buf := save_maxrow(), blk, t_arr[BR_LEN], fl, n
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
Private arr_m
if (arr_m := year_month(T_ROW,T_COL+5)) == NIL
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
if arr_m[5] == arr_m[6]
  index on str(n_napr,6) to (cur_dir+"tmp_napr") for for_263_p_annul() descending
else
  index on upper(_kart->fio)+str(_kart->kod,7) to (cur_dir+"tmp_napr") for for_263_p_annul()
endif
go top
if eof()
  close databases
  G_SUnLock(str_sem)
  rest_box(buf)
  return func_error(4,"Нет доступных для аннулирования направлений "+arr_m[4])
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_TITUL] := "Аннулирование направлений на госпитализацию в поликлинике"
t_arr[BR_TITUL_COLOR] := "B/BG"
t_arr[BR_COLOR] := color0
t_arr[BR_OPEN] := {|| f2_263_p_annul(,,"open") }
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B,RB/BG,W+/RB,R/BG,W+/R",.t.}
blk := {|| iif(!empty(napr->KOD_F_3in), {1,2}, ;
               iif(empty(napr->KOD_F_3out), {3,4}, ;
                   iif(napr->t_ans_3==0, {5,6}, ;
                       iif(napr->t_ans_3==1, {1,2}, {7,8} )))) }
n := iif(work_otd_263 == 1, 24, 30)
t_arr[BR_COLUMN] := {{"№ напр", {|| str(napr->n_napr,6) }, blk },;
                     {"  Дата", {|| date_8(napr->date_d) }, blk },;
                     {" Ф.И.О.", {|| left(_kart->fio,n) }, blk },;
                     {"Госп-ия", {|| date_8(napr->date_h_1) }, blk },;
                     {" Статус", {|| padr(f1_263_p_annul(),22) }, blk }}
if work_otd_263 == 1
  Ins_Array(t_arr[BR_COLUMN],4,{" Отд.", {|| _263_put_otd(napr->otd_1) }, blk })
endif
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход ^<Enter>^ просмотр/аннулирование ^<Del>^ удаление аннулирования") }
t_arr[BR_EDIT] := {|nk,ob| f2_263_p_annul(nk,ob,"edit") }
edit_browse(t_arr)
close databases
G_SUnLock(str_sem)
rest_box(buf)
return NIL

*

***** 19.02.17
Function f1_263_p_annul()
Local s := "ошибка"
if empty(napr->date_3)
  s := " направлено в стационар"
elseif napr->TIP_ANNUL == 3
  if empty(napr->KOD_F_3out)
    s := "аннул/не отправлен в ТФ"
  elseif napr->t_ans_3 == 0
    s := "аннул/не получен ответ"
  elseif napr->t_ans_3 == 1
    s := "аннулировано "+date_8(napr->date_3)
  endif
elseif napr->TIP_ANNUL == 1
  s := "аннулировано в СМО"
elseif napr->TIP_ANNUL == 2
  s := "аннулировано в стационаре"
endif
return s

// 30.03.23
Function f2_263_p_annul(nKey, oBrow, regim)
  Local ret := -1, rec, i, k, s, tmp_color, buf, s_error := '', ;
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
        mn_napr := napr->n_napr,; // уникальный номер направления (п-ка)
        mfio    := _kart->fio,;
        mdate_r := _kart->date_r,;
        mpol    := _kart->pol,;
        mkod    := napr->KOD,;
        m1kod_k := napr->kod_k,; // код по картотеке
        md_napr := napr->DATE_D,; // дата направления
        motd := space(10), m1otd := napr->otd_1,;
        mkod_diag := napr->ds_1,; // диагноз поликлиники
        mforma, m1forma := napr->F_MEDC_1,; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
        mdate_hosp := napr->DATE_H_1,; // планируемая дата госпитализации
        musl_ok, m1usl_ok := iif(napr->usl_ok_1==2, 2, 1),; // условия оказания мед.помощи
        mprofil_k, m1profil_k := napr->PROFIL_K_1,; // профиль койки по справочнику T007
        mprofil, m1profil := napr->PROFIL_1,; // профиль мед.помощи по справочнику V002
        m1vrach := napr->VRACH_1,; // лечащий врач по mo_pers
        MVRACH := space(10),; // фамилия и инициалы лечащего врача
        MTAB_NOM := 0, m1prvs := 0,; // таб.№ лечащего врача
        mstac_mo := space(10), ;
        m1stac_mo := napr->S_CODEM,;  // код стационара
        mdate_3 := napr->date_3, ;
        mrea_annul := space(10), m1rea_annul := napr->rea_annul,;
        gl_area := {1,0,23,79,0}
      if work_otd_263 == 1
        Private pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}
        make_arr_uch_otd(md_napr)
        if (i := ascan(pr_arr,{|x| x[1]==m1otd } )) > 0
          motd := pr_arr[i,2]
        elseif m1otd > 0
          motd := '! некорректное отделение !'
        endif
      endif
      mUSL_OK := inieditspr(A__MENUVERT, tmp_V006, m1USL_OK)
      mforma := inieditspr(A__MENUVERT, getV014(), m1forma)
      mprofil_k := inieditspr(A__MENUVERT, arr_t007, M1PROFIL_K)
      mprofil := inieditspr(A__MENUVERT, getV002(), M1PROFIL)
      mstac_mo := ret_mo(m1stac_mo)[_MO_SHORT_NAME]
      // mrea_annul := inieditspr(A__MENUVERT, mm_reason_annul, m1rea_annul)
      mrea_annul := inieditspr(A__MENUVERT, get_reason_annul(), m1rea_annul)
      if m1vrach > 0
        R_Use(dir_server + 'mo_pers', , 'P2')
        goto (m1vrach)
        MTAB_NOM := p2->tab_nom
        m1prvs := ret_new_spec(p2->prvs,p2->prvs_new)
        mvrach := padr(fam_i_o(p2->fio)+" "+ret_tmp_prvs(0,m1prvs),36)
        p2->(dbCloseArea())
        select NAPR
      endif
      Private r1 := maxrow()-17
      if work_otd_263 == 1
        --r1
      endif
      do while .t.
        setcolor(cDataCGet)
        ClrLines(r1, maxrow() - 1)
        @ r1 - 1, 0 say padc('Аннулирование направления на госпитализацию', 80) color 'B/B*'
        i := r1
        @ ++i, 1 say 'Пациент' get mfio when .f.
        @ row(), col() + 2 say 'Дата р.' get mdate_r when .f.
        @ ++i, 1 say 'направление: №' get mn_napr when .f. pict '999999'
        @ row(), col() + 3 say 'дата' get md_napr when .f.
        @ ++i, 1 say 'Условия оказания, в которые направляется пациент' get musl_ok when .f.
        @ ++i, 1 say 'Диагноз направившего учреждения' get mkod_diag when .f. picture '@K@!'
        @ ++i, 1 say 'Направил на госпитализацию врач' get MTAB_NOM when .f. pict '99999'
        @ row(), col() + 1 get mvrach when .f. color color14
        if work_otd_263 == 1
          @ ++i, 1 say '                   из отделения' get motd when .f.
        endif
        @ ++i, 1 say 'Форма оказания медицинской помощи' get mforma when .f.
        @ ++i, 1 say 'Планируемая дата госпитализации' get mdate_hosp when .f.
        @ ++i, 1 say 'Направляется в стационар' get mstac_mo when .f.
        @ ++i, 1 say 'Профиль койки' get mprofil_k when .f.
        @ ++i, 1 say 'Профиль медицинской помощи' get mprofil when .f.
        // ++i ; @ i,1 say "Причина аннулирования" get mrea_annul ;
        //             reader {|x|menu_reader(x,mm_reason_annul,A__MENUVERT,,,.f.)}
        @ ++i, 1 say 'Причина аннулирования' get mrea_annul ;
                    reader {|x|menu_reader(x, get_reason_annul(), A__MENUVERT, , , .f.)}
        @ ++i, 1 say 'Дата аннулирования' get mdate_3
        if napr->KOD_F_3in > 0 .or. napr->KOD_F_3out > 0 .or. eq_any(napr->TIP_ANNUL,1,2)
          s_msg := ""
          s := "Направление аннулировано в "
          if napr->TIP_ANNUL == 1
            s += "СМО"
            s_msg := s
          elseif napr->TIP_ANNUL == 2
            s += "стационаре"
            s_msg := s
          else
            s += "нашей поликлинике"
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
          if mdate_hosp < mdate_3
            func_error(4,"Дата госпитализации меньше даты аннулирования.")
            loop
          endif
          select NAPR
          goto (rec)
          G_RLock(forever)
          napr->DATE_3 := mdate_3 // дата аннулирования
          napr->TIP_ANNUL := 3  // ануллировано в поликлинике
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
    elseif nKey == K_DEL .and. napr->TIP_ANNUL == 3
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
        func_error(4,'Аннулирование направления уже отправлено в ТФОМС!')
        if napr->t_ans_3 == 1
          func_error(4,'Аннулирование направления уже отправлено в ТФОМС!')
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

***** 29.06.14 Информирование наших пациентов о дате предстоящей госпитализации
Function _263_p_inform()
ne_real()
return NIL

*

***** 19.02.17 Просмотр количества свободных коек по профилям в стационарах
Function _263_p_svob_kojki()
Static si := 1, sprofil_k := 0, sprofil := 0
Local buf := save_maxrow(), blk, t_arr[BR_LEN], fl, i, j, arr := {}, ret_arr
if (i := popup_prompt(T_ROW,T_COL+5,si,;
            {"Список ~стационаров",;
             "Профиль ~койки",;
             "Профиль ~мед.помощи"})) == 0
  return NIL
endif
if (si := i) == 1
  R_Use(dir_server+"mo_n7in",,"N7")
  index on codem+upper(padr(inieditspr(A__MENUVERT,arr_T007,PROFIL_K),60))+;
           str(profil_k,3)+str(usl_ok,1) to (cur_dir+"tmp_n7")
  R_Use(dir_server+"mo_nfile",,"NF")
  index on upper(padr(ret_mo(substr(nf->name_f,12,6))[_MO_SHORT_NAME],30)) to (cur_dir+"tmp_nf") ;
        for TIP_F == 7 .and. IN_OUT == 2 .and. ;
            ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS]==substr(nf->name_f,12,6)} ) > 0
  go top
  if eof()
    func_error(4,"Ещё не было чтения пакетов I07")
  else
    t_arr[BR_TOP] := 2
    t_arr[BR_BOTTOM] := maxrow()-5
    t_arr[BR_LEFT] := 0
    t_arr[BR_RIGHT] := 79
    t_arr[BR_COLOR] := color0
    t_arr[BR_TITUL] := "Стационары + количество коек"
    t_arr[BR_TITUL_COLOR] := "B/BG"
    t_arr[BR_ARR_BROWSE] := {"═","░","═",,.t.}
    t_arr[BR_COLUMN] := {{" Наименование учреждения",{|| padr(ret_mo(substr(nf->name_f,12,6))[_MO_SHORT_NAME],48) }, blk },;
                         {"Отч.дата", {|| date_8(nf->date_r) }, blk },;
                         {" Количество коек", {|| f1_263_p_svob_kojki(3) }, blk }}
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход ^<Enter>^ просмотр информации по выбранному стационару") }
    t_arr[BR_STEP_FUNC] := {|| f1_263_p_svob_kojki(1) }
    t_arr[BR_EDIT] := {|nk,ob| f2_263_p_svob_kojki(nk,ob,"edit",1) }
    f1_263_p_svob_kojki(0)
    edit_browse(t_arr)
    f1_263_p_svob_kojki(2)
  endif
elseif i == 2
  R_Use(dir_server+"mo_n7in",,"N7")
  index on str(profil_k,3) to (cur_dir+"tmp_n7") UNIQUE
  go top
  if eof()
    func_error(4,"Ещё не было чтения пакетов I07")
  else
    dbeval({|| aadd(arr, {"",n7->profil_k}) })
    for i := 1 to len(arr)
      if (j := ascan(arr_t007, {|x| x[2] == arr[i,2] })) == 0
        arr[i,1] := "Профиль койки "+lstr(arr[i,2])
      else
        arr[i,1] := arr_t007[j,1]
      endif
    next
    popup_2array(arr,T_ROW,T_COL+5,sprofil_k,1,@ret_arr,"Выбор профиля койки","B/BG")
    if valtype(ret_arr) == "A"
      sprofil_k := ret_arr[2]
      R_Use(dir_server+"mo_nfile",,"NF")
      select N7
      set relation to kod_f into NF
      index on upper(padr(ret_mo(codem)[_MO_SHORT_NAME],30))+codem+str(usl_ok,1) to (cur_dir+"tmp_n7") ;
               for profil_k == ret_arr[2] .and. ;
                   ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS]==codem} ) > 0
      go top
      t_arr[BR_TOP] := 2
      t_arr[BR_BOTTOM] := maxrow()-5
      t_arr[BR_LEFT] := 0
      t_arr[BR_RIGHT] := 79
      t_arr[BR_COLOR] := color0
      t_arr[BR_TITUL] := ret_arr[1]
      t_arr[BR_TITUL_COLOR] := "B/BG"
      t_arr[BR_ARR_BROWSE] := {"═","░","═",,.t.}
      t_arr[BR_COLUMN] := {{" Наименование учреждения",{|| padr(ret_mo(substr(nf->name_f,12,6))[_MO_SHORT_NAME],29) }, blk },;
                           {"Отч.дата", {|| date_8(nf->date_r) }, blk },;
                           {"ус", {|| iif(n7->usl_ok==2,"дн","ст") }, blk },;
                           {"Профиль мед.помощи", {|| padr(inieditspr(A__MENUVERT,getV002(),n7->PROFIL),18) }, blk },;
                           {" Количество коек", {|| padr(lstr(n7->QUANTITY)+", свободно "+lstr(n7->PLACE_FREE),17) }, blk }}
      t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход ^<Enter>^ просмотр информации по выбранному стационару и профилю") }
      t_arr[BR_STEP_FUNC] := {|| f1_263_p_svob_kojki(1) }
      t_arr[BR_EDIT] := {|nk,ob| f2_263_p_svob_kojki(nk,ob,"edit",2) }
      f1_263_p_svob_kojki(0)
      edit_browse(t_arr)
      f1_263_p_svob_kojki(2)
    endif
  endif
elseif i == 3
  R_Use(dir_server+"mo_n7in",,"N7")
  index on str(profil,3)+str(usl_ok,1) to (cur_dir+"tmp_n7") UNIQUE
  go top
  if eof()
    func_error(4,"Ещё не было чтения пакетов I07")
  else
    dbeval({|| aadd(arr, {"",n7->profil}) })
    for i := 1 to len(arr)
      if (j := ascan(getV002(), {|x| x[2] == arr[i,2] })) == 0
        arr[i,1] := "Профиль мед.помощи "+lstr(arr[i,2])
      else
        arr[i,1] := getV002()[j,1]
      endif
    next
    popup_2array(arr,T_ROW,T_COL+5,sprofil,1,@ret_arr,"Выбор профиля мед.помощи","B/BG")
    if valtype(ret_arr) == "A"
      sprofil := ret_arr[2]
      R_Use(dir_server+"mo_nfile",,"NF")
      select N7
      set relation to kod_f into NF
      index on upper(padr(ret_mo(codem)[_MO_SHORT_NAME],30))+codem+str(usl_ok,1) to (cur_dir+"tmp_n7") ;
               for profil == ret_arr[2] .and. ;
                   ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS]==codem} ) > 0
      go top
      t_arr[BR_TOP] := 2
      t_arr[BR_BOTTOM] := maxrow()-5
      t_arr[BR_LEFT] := 0
      t_arr[BR_RIGHT] := 79
      t_arr[BR_COLOR] := color0
      t_arr[BR_TITUL] := ret_arr[1]
      t_arr[BR_TITUL_COLOR] := "B/BG"
      t_arr[BR_ARR_BROWSE] := {"═","░","═",,.t.}
      t_arr[BR_COLUMN] := {{" Наименование учреждения",{|| padr(ret_mo(substr(nf->name_f,12,6))[_MO_SHORT_NAME],29) }, blk },;
                           {"Отч.дата", {|| date_8(nf->date_r) }, blk },;
                           {"ус", {|| iif(n7->usl_ok==2,"дн","ст") }, blk },;
                           {" Профиль койки", {|| padr(inieditspr(A__MENUVERT,arr_T007,n7->PROFIL_K),18) }, blk },;
                           {" Количество коек", {|| padr(lstr(n7->QUANTITY)+", свободно "+lstr(n7->PLACE_FREE),17) }, blk }}
      t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход ^<Enter>^ просмотр информации по выбранному стационару и профилю") }
      t_arr[BR_STEP_FUNC] := {|| f1_263_p_svob_kojki(1) }
      t_arr[BR_EDIT] := {|nk,ob| f2_263_p_svob_kojki(nk,ob,"edit",3) }
      f1_263_p_svob_kojki(0)
      edit_browse(t_arr)
      f1_263_p_svob_kojki(2)
    endif
  endif
endif
close databases
return NIL

***** 06.08.14
Function f1_263_p_svob_kojki(k)
Static buf
Local ta[2], k1, k2
if k == 0
  buf := box_shadow(maxrow()-4,0,maxrow()-1,79,color1,"Полное наименование стационара","B+/B")
elseif k == 1
  perenos(ta,ret_mo(substr(nf->name_f,12,6))[_MO_FULL_NAME],78)
  @ maxrow()-3,1 say padc(alltrim(ta[1]),78) color color14
  @ maxrow()-2,1 say padc(alltrim(ta[2]),78) color color14
elseif k == 2
  rest_box(buf)
elseif k == 3
  k1 := k2 := 0
  select N7
  find (substr(nf->name_f,12,6))
  do while n7->codem == substr(nf->name_f,12,6) .and. !eof()
    k1 += n7->QUANTITY
    k2 += n7->PLACE_FREE
    skip
  enddo
  select NF
  return padr(lstr(k1)+", свободно "+lstr(k2),20)
endif
return NIL

***** 19.02.17
Function f2_263_p_svob_kojki(nKey,oBrow,regim,par)
Local lkod, buf, r1, rec, i, ret := -1, lcodem, n1, n2, ad[10,4], d,;
      n_file := "sv_kojki"+stxt, sh := 80, HH := 80, t_arr[4], s1, s2, s3, s4
if regim == "edit"
  do case
    case nKey == K_ENTER
      arr_title := {;
"──┬──────────────────────┬───────────────────────┬────┬─────────────┬───────────",;
"ус│                      │                       │кол.│за пред.сутки│ свободных ",;
"ло│ профиль койки        │ профиль мед.помощи    │коек│и на тек.день│   коек    ",;
"──┴──────────────────────┴───────────────────────┴────┴─────────────┴───────────"}
      d := nf->date_r ; afillall(ad,0) ; i := 0
      do while .t.
        if is_work_day(++d)
          ad[++i,1] := d
          if i == 10
            exit
          endif
        endif
      enddo
      for i := 1 to 10
        arr_title[1] += "┬───"
        arr_title[2] += "│"+left(dtoc(ad[i,1]),3)
        arr_title[3] += "│"+substr(dtoc(ad[i,1]),4,3)
        arr_title[4] += "┴───"
      next
      sh := len(arr_title[1])
      lcodem := substr(nf->name_f,12,6)
      fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
      add_string("")
      add_string(center("Количество стационарных коек на утро "+date_8(nf->date_r)+"г.",sh))
      for i := 1 to perenos(t_arr,ret_mo(lcodem)[_MO_FULL_NAME],sh)
        add_string(center(alltrim(t_arr[i]),sh))
      next
      aeval(arr_title, {|x| add_string(x) } )
      n1 := 23 ; n2 := 23
      if par == 1
        select N7
        find (lcodem)
        do while n7->codem == lcodem .and. !eof()
          s1 := iif(n7->usl_ok==2, "дн", "ст")+" "
          s2 := s3 := s4 := space(3)
          perenos(t_arr,inieditspr(A__MENUVERT,arr_T007,n7->PROFIL_K),n1-1)
          s1 += padr(t_arr[1],n1)
          s2 += padr(t_arr[2],n1)
          s3 += padr(t_arr[3],n1)
          s4 += padr(t_arr[4],n1)
          perenos(t_arr,inieditspr(A__MENUVERT,getV002(),n7->PROFIL),n2-1)
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
          select N7
          skip
        enddo
        select NF
      else
        s1 := iif(n7->usl_ok==2, "дн", "ст")+" "
        s2 := s3 := s4 := space(3)
        perenos(t_arr,inieditspr(A__MENUVERT,arr_T007,n7->PROFIL_K),n1-1)
        s1 += padr(t_arr[1],n1)
        s2 += padr(t_arr[2],n1)
        s3 += padr(t_arr[3],n1)
        s4 += padr(t_arr[4],n1)
        perenos(t_arr,inieditspr(A__MENUVERT,getV002(),n7->PROFIL),n2-1)
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
        add_string(s1)
        add_string(s2)
        add_string(s3)
        add_string(s4)
        add_string(replicate("─",sh))
      endif
      fclose(fp)
      viewtext(n_file,,,,(sh>80),,,6)
  endcase
endif
return ret
