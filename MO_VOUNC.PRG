***** реестры/счета 2019 года (и ВОУНЦ)
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// Static sadiag1 := {}

*****
Function vounc_begin_task()
Static n_zapusk := 0
Local fl := .t.
if n_zapusk == 0
  ++n_zapusk
  Public sem_vagno_VOUNC := "Важный режим в задаче VOUNC",;
         mm_tip_mnn := {{"ингибитор кальцинейрина",0},;
                        {"микофенолат            ",1}},;
         mm_lf_lat := {{"mg",0},{"mg/ml",1}},;
         mm_lf := {{"мг   ",0},{"мг/мл",1}}
  vounc_sprav_nastr(1)
endif
if G_SIsLock(sem_vagno_VOUNC)
  fl := func_error('В задаче выполняется важная операция. Доступ временно запрещён!')
elseif copy_Tools_Ini()
  Tools_Ini_OMS(1,0,0)
  Vounc_Tools_Ini(1,0,0)
else
  fl := .f.
endif
return fl

*****
Function vounc_f1main()
aadd(cmain_menu,1)
aadd(main_menu," ~Ввод данных ")
aadd(main_message,"Ввод данных")
aadd(first_menu, {"~Назначения",;
                  "~Рецепты",0,;
                  "~Картотека"})
aadd(first_message,  {;
     "Редактирование назначений лекарственных препаратов",;
     "Ввод/редактирование рецептов",;
     "Ввод/редактирование картотеки (регистратура)"})
aadd(func_menu, {"vounc_input_nazn()",;
                 "vounc_input_recept()",;
                 "oms_kartoteka()"})
//
aadd(cmain_menu,34)
aadd(main_menu," ~Информация ")
aadd(main_message,"Просмотр / печать")
aadd(first_menu, {"~Назначения",;
                  "~Рецепты",;
                  "~Справочники"})
aadd(first_message,  { ;   // информация
      "Просмотр / печать назначений",;
      "Просмотр / печать отчетов по выписке рецептов",;
      "Просмотр/печать справочников";
     })
aadd(func_menu, {;    // информация
      "vounc_info_nazn()",;
      "vounc_info_recept()",;
      "vounc_info_sprav()";
     })
//
aadd(cmain_menu,51)
aadd(main_menu," ~Справочники ")
aadd(main_message,"Редактирование справочников")
aadd(first_menu,{"~Торговые наименования",;
                 "~МНН",0,;
                 "~Настройка программы"})
aadd(first_message,{;
     "Редактирование торговых наименований препаратов",;
     "Редактирование международных непатентованных наименований препаратов",;
     "Настройка программы (некоторых значений по умолчанию)"})
aadd(func_menu,{"vounc_sprav_trn()",;
                "vounc_sprav_mnn()",;
                "vounc_sprav_nastr(2)"})
return NIL

*

*****
Function vounc_input_nazn()
Static si := 2
Local arr, ret, buf, str_sem := "vounc_input_nazn"
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
Private ltip_mnn
if polikl1_kart() > 0
  arr := aclone(mm_tip_mnn)
  aadd(arr, {"все назначения",2})
  popup_2array(arr,T_ROW,T_COL+5,si,1,@ret,,,color5)
  if valtype(ret) == "A"
    ltip_mnn := si := ret[2]
  endif
  if ltip_mnn != NIL
    buf := savescreen()
    Private blk_open := {|| R_Use(dir_server+"vouncmnn",,"MNN"),;
                            R_Use(dir_server+"vounctrn",,"TRN"),;
                            dbSetRelation( "MNN", {|| mnn}, "mnn" ),;
                            G_Use(dir_server+"vouncnaz",,"NAZN"),;
                            dbSetRelation( "TRN", {|| tovar}, "tovar" ) }
    eval(blk_open)
    index on str(kod_k,7)+str(descend(DATE_NAZ),10) to (cur_dir+"tmp_nazn")
    if ltip_mnn < 2
      set filter to mnn->tip_mnn==ltip_mnn
    endif
    Private fl_found, str_find, muslovie
    str_find := str(glob_kartotek,7)
    muslovie := "nazn->kod_k == glob_kartotek"
    find (str_find)
    fl_found := found()
    arr_blk := {{| | FindFirst(str_find)},;
                {| | FindLast(str_find)},;
                {|n| SkipPointer(n, muslovie)},;
                str_find,muslovie;
               }
    if !fl_found ; keyboard chr(K_INS) ; endif
    Alpha_Browse(T_ROW,0,23,79,"f1_vounc_input_nazn",color0,glob_k_fio,"BG+/GR",;
                 .f.,.t.,arr_blk,,"f2_vounc_input_nazn",,;
                 {"═","░","═","N/BG,W+/N,B/BG,BG+/B",.t.,180} )
    close databases
    restscreen(buf)
  endif
endif
G_SUnLock(str_sem)
return NIL

*****
Function f1_vounc_input_nazn(oBrow)
Local oColumn, blk := {|| iif(mnn->tip_mnn==1, {3,4}, {1,2}) }
//
oColumn := TBColumnNew("   Дата;назначения", {|| full_date(nazn->date_naz) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("МКБ10", {|| nazn->kod_diag })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Назнач;кол-во", {|| put_val_0(nazn->KOL_NAZ,6,1) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Кол;уп.", {|| put_val(nazn->KOL_UP,3) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Препарат", {|| padr(trn->name,30) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Дози-;ровка", {|| put_val_0(trn->doza,6,1) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Ед.;изм.", {|| iif(empty(trn->name),space(4),inieditspr(A__MENUVERT,mm_lf,trn->c_lf)) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Кол.;в уп", {|| put_val(trn->n_lf,4) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
status_key("^<Esc>^-выход; ^<Enter>^-редактирование; ^<Ins>^-добавление; ^<Del>^-удаление")
return NIL

*

*****
Function f2_vounc_input_nazn(nKey,oBrow)
LOCAL flag := -1, buf := save_maxrow(), buf1, fl := .f., rec,;
      tmp_color := setcolor(), r1, c1, bg := {|o,k| get_MKB10(o,k,.t.) }
do case
  case (nKey == K_ENTER .and. nazn->kod_k > 0) .or. nKey == K_INS
    rec := nazn->(recno())
    Private mdate_naz := sys_date, mkod_diag := vounc_mem_diag,;
            m1tovar := 0, mkol_naz := 0, mtovar, mkol_up := 1, ;
            gl_area := {1,0,23,79,0}
    if nKey == K_INS
      if fl_found
        do while .t.
          if iif(ltip_mnn==2, .t., mnn->tip_mnn == ltip_mnn)
            mkod_diag := nazn->kod_diag
            m1tovar   := nazn->tovar
            mkol_naz  := nazn->kol_naz
            mkol_up   := nazn->kol_up
            exit
          endif
          skip
          if !&muslovie .or. eof()
            exit
          endif
        enddo
        goto (rec)
      else
        colorwin(T_ROW+4,0,T_ROW+4,79,"N/N","W+/N")
        colorwin(T_ROW+4,0,T_ROW+4,79,"N/N","BG+/B")
      endif
    else // nKey == K_ENTER
      mdate_naz := nazn->date_naz
      mkod_diag := nazn->kod_diag
      m1tovar   := nazn->tovar
      mkol_naz  := nazn->kol_naz
      mkol_up   := nazn->kol_up
    endif
    close databases
    mtovar := vounc_ret_name_trn(m1tovar,1,.t.)
    r1 := 14 ; c1 := 2
    buf1 := box_shadow(r1,c1,21,77,color8,;
             iif(nKey == K_INS,"Добавление","Редактирование")+" назначения",cDataPgDn)
    setcolor(cDataCGet)
    @ r1+2,c1+2 say "Дата назначения" get mdate_naz
    @ r1+3,c1+2 say "Код заболевания (по МКБ-10)" get mkod_diag pict "@K@!" ;
                reader {|o|MyGetReader(o,bg)} valid val2_10diag()
    @ r1+4,c1+2 say "Назначаемый препарат" get mtovar ;
                reader {|x|menu_reader(x,{{|k,r,c| vounc_get_tovar(k,r,c,ltip_mnn)}},A__FUNCTION,,,.f.)}
    @ r1+5,c1+2 say "Количество назначенного препарата в сутки" get mkol_naz pict "9999.9"
    @ r1+6,c1+2 say "Количество упаковок в рецепте" get mkol_up pict "99"
    status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода")
    myread()
    eval(blk_open)
    set index to (cur_dir+"tmp_nazn")
    goto (rec)
    if lastkey() != K_ESC .and. !emptyany(mdate_naz,mkod_diag,m1tovar,mkol_naz) .and. f_Esc_Enter(1)
      fl_found := .t.
      if nKey == K_INS
        AddRec(7)
        nazn->KOD_K := glob_kartotek
        rec := recno()
      else
        G_RLock(forever)
      endif
      nazn->DATE_NAZ := mdate_naz
      nazn->KOD_DIAG := mkod_diag
      nazn->TOVAR    := m1tovar
      nazn->KOL_NAZ  := mkol_naz
      nazn->KOL_UP   := mkol_up
      nazn->DATE_E   := c4sys_date
      nazn->KOD_P    := kod_polzovat    // код оператора
      UnLock
      Commit
    endif
    rest_box(buf1)
    if ltip_mnn < 2
      set filter to mnn->tip_mnn==ltip_mnn
    endif
    goto (rec)
    flag := 0
  case nKey == K_DEL .and. nazn->KOD_K > 0 .and. f_Esc_Enter(2,.t.)
    DeleteRec()
    find (str_find)
    flag := iif(found(), 0, 1)
  otherwise
    keyboard ""
endcase
return flag

*

*****
Function vounc_input_recept()
Local buf, str_sem := "vounc_input_recept"
if !G_SLock(str_sem)
  return func_error(4,err_slock)
endif
if polikl1_kart() > 0
  buf := savescreen()
  Private blk_open := {|| R_Use(dir_server+"vouncmnn",,"MNN"),;
                          R_Use(dir_server+"vounctrn",,"TRN"),;
                          dbSetRelation( "MNN", {|| mnn}, "mnn" ),;
                          G_Use(dir_server+"vouncrec",,"RCP"),;
                          dbSetRelation( "TRN", {|| tovar}, "tovar" ) }
  eval(blk_open)
  index on str(kod_k,7)+str(descend(DATE_R),10)+str(999999-NUMBER_R,6) to (cur_dir+"tmp_rcp")
  Private fl_found, str_find, muslovie
  str_find := str(glob_kartotek,7)
  muslovie := "rcp->kod_k == glob_kartotek"
  find (str_find)
  fl_found := found()
  arr_blk := {{| | FindFirst(str_find)},;
              {| | FindLast(str_find)},;
              {|n| SkipPointer(n, muslovie)},;
              str_find,muslovie;
             }
  if !fl_found ; keyboard chr(K_INS) ; endif
  Alpha_Browse(T_ROW,0,23,79,"f1_vounc_input_recept",color0,glob_k_fio,"BG+/GR",;
               .f.,.t.,arr_blk,,"f2_vounc_input_recept",,;
               {"═","░","═","N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
  close databases
  restscreen(buf)
endif
G_SUnLock(str_sem)
return NIL

*****
Function f1_vounc_input_recept(oBrow)
Local oColumn, blk := {|| iif(rcp->annul==1, {5,6}, iif(mnn->tip_mnn==1, {3,4}, {1,2})) }
//
oColumn := TBColumnNew("   Дата;  рецепта", {|| full_date(rcp->date_r) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Номер;рецепт", {|| put_val(rcp->NUMBER_R,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Назнач;кол-во", {|| put_val_0(rcp->KOL_NAZ,6,1) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Кол;уп.", {|| put_val(rcp->KOL_UP,3) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("МКБ10", {|| rcp->kod_diag })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew(" Препарат", {|| padr(trn->name,21) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Дози-;ровка", {|| put_val_0(trn->doza,6,1) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Ед.;изм.", {|| iif(empty(trn->name),space(4),inieditspr(A__MENUVERT,mm_lf,trn->c_lf)) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("Кол.;в уп", {|| put_val(trn->n_lf,4) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
oColumn := TBColumnNew("   ", {|| iif(rcp->annul==1,"анн","   ")  })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
//
status_key("^<Esc>^ выход ^<Del>^ аннулирование ^<Enter>^ редакт-ие ^<Ins>^ добавление ^<F9>^ печать")
return NIL

*

*****
Function f2_vounc_input_recept(nKey,oBrow)
Static st_vrach := 0, si := 1
Local arr, i, k, fl_recept := .f.
LOCAL flag := -1, buf := save_maxrow(), buf1, fl := .f., rec,;
      tmp_color := setcolor(), r1, c1, bg := {|o,k| get_MKB10(o,k,.t.) }
do case
  case nKey == K_F9
    if rcp->annul == 1
      func_error(4,"Данный рецепт аннулирован "+full_date(rcp->d_annul)+"г.")
    else
      fl_recept := .t.
    endif
  case nKey == K_INS
    rec := rcp->(recno())
    close databases
    Private mkod_diag, m1tovar, mkol_naz, mkol_up, mtovar,;
            mdate_r := sys_date, mnumber_r := 0, MTAB_NOM := 0,;
            m1vrach := st_vrach, mvrach := space(10), gl_area := {1,0,23,79,0}
    if fl_found
      //
    else
      colorwin(T_ROW+4,0,T_ROW+4,79,"N/N","W+/N")
      colorwin(T_ROW+4,0,T_ROW+4,79,"N/N","BG+/B")
    endif
    //
    R_Use(dir_server+"vouncmnn",,"MNN")
    R_Use(dir_server+"vounctrn",,"TRN")
    dbSetRelation( "MNN", {|| mnn}, "mnn" )
    G_Use(dir_server+"vouncnaz",,"NAZN")
    dbSetRelation( "TRN", {|| tovar}, "tovar" )
    index on str(descend(DATE_NAZ),10) to (cur_dir+"tmp_nazn") for kod_k==glob_kartotek
    k := {0,0} ; arr := {}
    go top
    do while !eof()
      i := mnn->tip_mnn+1
      if between(i,1,2) .and. k[i] < iif(i==1,5,3)
        k[i] ++
        s := alltrim(str_0(nazn->KOL_NAZ,6,1))+" "+;
             alltrim(inieditspr(A__MENUVERT,mm_lf,trn->c_lf))+;
             iif(nazn->KOL_UP==1," ","("+lstr(nazn->KOL_UP)+"уп.) ")+;
             date_8(nazn->DATE_NAZ)+" - "+vounc_ret1_name_trn(1)
        aadd(arr, {s,nazn->(recno())})
      endif
      if k[1]==5 .and. k[2]==3
        exit
      endif
      select NAZN
      skip
    enddo
    if len(arr) == 0
      func_error(4,"Не было назначений данному человеку!")
    elseif (i := popup_2array(arr,T_ROW,T_COL+5,si,1,,;
             "По какому назначению выписывается рецепт","B/W",color5)) > 0
      si := i
      goto (i)
      mkod_diag := nazn->kod_diag
      m1tovar   := nazn->tovar
      mkol_naz  := nazn->kol_naz
      mkol_up   := nazn->kol_up
      if m1vrach > 0
        R_Use(dir_server+"mo_pers",,"P2")
        goto (m1vrach)
        mvrach := fam_i_o(p2->fio)
        MTAB_NOM := p2->tab_nom
      endif
    endif
    close databases
    fl := .t.
    if m1tovar != NIL
      mtovar := vounc_ret_name_trn(m1tovar,1,.t.)
      if vounc_mem_regim == 2  // автоматическая нумерация
        if !Vounc_Tools_Ini(1,0,0) // перечитать последний рецепт
          fl := func_error(4,"Не удалось прочитать номер последнего рецепта. Попытайтесь снова.")
        endif
        mnumber_r := vounc_mem_last_rc+1
      endif
      if fl
        r1 := 11 ; c1 := 2
        buf1 := box_shadow(r1,c1,21,77,color8,;
                           "Добавление нового рецепта",cDataPgDn)
        do while .t.
          setcolor(cDataCGet)
          @ r1+2,c1+2 say "Дата рецепта" get mdate_r
          if vounc_mem_regim == 2  // автоматическая нумерация
            @ r1+3,c1+2 say "Номер рецепта" get mnumber_r pict "999999" when .f. color cDataPgDn
          else
            @ r1+3,c1+2 say "Номер рецепта" get mnumber_r pict "999999"
          endif
          @ r1+4,c1+2 say "Врач, выписавший рецепт" get mtab_nom picture "99999" ;
                      valid {|g| v_kart_vrach(g) }
          @ row(),col()+1 get mvrach when .f. color cDataPgDn
          @ r1+5,c1+2 say "Количество упаковок в рецепте" get mkol_up pict "99"
          @ r1+6,c1+2 say "Код заболевания (по МКБ-10)" get mkod_diag pict "@K@!" ;
                      reader {|o|MyGetReader(o,bg)} valid val2_10diag()
          @ r1+7,c1+2 say "Препарат" get mtovar ;
                      reader {|x|menu_reader(x,{{|k,r,c| vounc_get_tovar(k,r,c)}},A__FUNCTION,,,.f.)}
          @ r1+8,c1+2 say "Количество назначенного препарата в сутки" get mkol_naz pict "9999.9"
          status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода")
          myread()
          if lastkey() != K_ESC .and. !emptyany(mdate_r,mkod_diag,m1tovar,mkol_naz) .and. f_Esc_Enter(1)
            mywait()
            fl := .t.
            if fl .and. empty(mnumber_r)
              fl := func_error(4,"Не введен номер рецепта")
            endif
            if fl .and. !between(mnumber_r,vounc_mem_nom1,vounc_mem_nom2)
              fl := func_error(4,"Номер рецепта не попадает в диапазон с "+;
                                 lstr(vounc_mem_nom1)+" по "+lstr(vounc_mem_nom2))
            endif
            if fl .and. empty(m1vrach)
              fl := func_error(4,"Не введен врач, выписавший рецепт")
            endif
            if fl
              R_Use(dir_server+"vouncrec",,"RCP")
              index on str(number_r,6) to (cur_dir+"tmp_rcp1") for year(date_r)==year(mdate_r)
              find (str(mnumber_r,6))
              if found()
                fl := func_error(4,"В этом году уже был введен рецепт № "+lstr(mnumber_r))
                if vounc_mem_regim == 2  // автоматическая нумерация
                  ++mnumber_r
                endif
              endif
              if fl
                set index to
                Locate for rcp->kod_k==glob_kartotek .and. ;
                           m1tovar==rcp->tovar .and. ;
                           left(dtos(mdate_r),6)==left(dtos(rcp->date_r),6)
                if found()
                  buf2 := savescreen()
                  f_message({"В этом месяце на данный препарат уже был выписан",;
                             "рецепт № "+lstr(rcp->number_r)},,"GR+/R","W+/R",16)
                  mybell(2)
                  fl := (f_alert({padc("Выберите действие",60,".")},;
                                 {" Нет записи "," Записать рецепт "},;
                                 1,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG")) == 2
                  restscreen(buf2)
                endif
              endif
              Use
            endif
            if fl
              fl_found := fl_recept := .t.
              G_Use(dir_server+"vouncrec",,"RCP")
              AddRecN()
              rec := recno()
              rcp->KOD_K    := glob_kartotek
              rcp->DATE_R   := mdate_r
              rcp->NUMBER_R := MNUMBER_R
              rcp->KOD_DIAG := mkod_diag
              rcp->TOVAR    := m1tovar
              rcp->VRACH    := m1vrach
              rcp->KOL_NAZ  := mkol_naz
              rcp->KOL_UP   := mkol_up
              rcp->DATE_E   := c4sys_date
              rcp->KOD_P    := kod_polzovat    // код оператора
              UnLock
              Commit
              st_vrach := m1vrach
              if nKey == K_INS .and. vounc_mem_regim == 2  // автоматическая нумерация
                vounc_mem_last_rc := mnumber_r
                if !Vounc_Tools_Ini(2,0,0)
                  func_error(4,"Не удалось записать номер последнего рецепта. Проверьте и исправьте.")
                endif
              endif
              index on str(kod_k,7)+str(descend(DATE_R),10)+str(999999-NUMBER_R,6) to (cur_dir+"tmp_rcp")
              Use
            else
              loop
            endif
          endif
          exit
        enddo
        rest_box(buf1)
      endif
    endif
    eval(blk_open)
    set index to (cur_dir+"tmp_rcp")
    goto (rec)
    flag := iif(fl_found,0,1)
  case nKey == K_ENTER .and. rcp->kod_k > 0
    if rcp->annul == 1
      func_error(4,"Данный рецепт аннулирован "+full_date(rcp->d_annul)+"г.")
      return flag
    endif
    rec := rcp->(recno())
    Private mkod_diag := rcp->KOD_DIAG,;
            mtovar, m1tovar := rcp->TOVAR,;
            mkol_naz := rcp->KOL_NAZ,;
            mkol_up := rcp->KOL_UP,;
            mdate_r := rcp->DATE_R,;
            mnumber_r := rcp->NUMBER_R,;
            MTAB_NOM := 0, m1vrach := rcp->VRACH, mvrach := space(10), ;
            gl_area := {1,0,23,79,0}
    mtovar := vounc_ret1_name_trn(1,.t.)
    if m1vrach > 0
      R_Use(dir_server+"mo_pers",,"P2")
      goto (m1vrach)
      mvrach := fam_i_o(p2->fio)
      MTAB_NOM := p2->tab_nom
    endif
    close databases
    r1 := 11 ; c1 := 2
    buf1 := box_shadow(r1,c1,21,77,color8,;
                       "Редактирование рецепта",cDataPgDn)
    setcolor(cDataCGet)
    @ r1+2,c1+2 say "Дата рецепта" get mdate_r when .f.
    @ r1+3,c1+2 say "Номер рецепта" get mnumber_r pict "999999" when .f.
    @ r1+4,c1+2 say "Врач, выписавший рецепт" get mtab_nom picture "99999" ;
                valid {|g| v_kart_vrach(g) }
    @ row(),col()+1 get mvrach when .f. color cDataPgDn
    @ r1+5,c1+2 say "Количество упаковок в рецепте" get mkol_up pict "99"
    @ r1+6,c1+2 say "Код заболевания (по МКБ-10)" get mkod_diag pict "@K@!" ;
                reader {|o|MyGetReader(o,bg)} valid val2_10diag()
    @ r1+7,c1+2 say "Препарат" get mtovar ;
                reader {|x|menu_reader(x,{{|k,r,c| vounc_get_tovar(k,r,c)}},A__FUNCTION,,,.f.)}
    @ r1+8,c1+2 say "Количество назначенного препарата в сутки" get mkol_naz pict "9999.9"
    status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода")
    myread()
    eval(blk_open)
    set index to (cur_dir+"tmp_rcp")
    goto (rec)
    if lastkey() != K_ESC .and. !emptyany(mdate_r,mnumber_r,m1vrach,mkod_diag,m1tovar,mkol_naz) .and. f_Esc_Enter(1)
      goto (rec)
      fl_recept := .t.
      G_RLock(forever)
      rcp->KOD_DIAG := mkod_diag
      rcp->TOVAR    := m1tovar
      rcp->VRACH    := m1vrach
      rcp->KOL_NAZ  := mkol_naz
      rcp->KOL_UP   := mkol_up
      rcp->DATE_E2  := c4sys_date
      rcp->KOD_P2   := kod_polzovat    // код оператора
      UnLock
      Commit
    endif
    rest_box(buf1)
    flag := 0
  case nKey == K_DEL .and. rcp->kod_k > 0
    Private mdate
    if rcp->annul == 1
      arr := {"Данный рецепт уже аннулирован "+full_date(rcp->d_annul)+"г.",;
              space(11)+"Возможна отмена аннулирования - введите дату"}
    else
      arr := {"Рецепт № "+strzero(rcp->number_r,6)+" выписан "+full_date(rcp->DATE_R)+"г.",;
              space(19)+"Введите дату аннулирования"}
    endif
    if (mdate := input_value(18,2,21,77,color1,arr,sys_date)) != NIL ;
        .and. f_Esc_Enter(iif(rcp->annul==1,"отмены ","")+"аннулирования",.t.)
      G_RLock(forever)
      rcp->annul   := iif(rcp->annul==1, 0, 1)
      rcp->d_annul := mdate
      rcp->DATE_E2 := c4sys_date
      rcp->KOD_P2  := kod_polzovat    // код оператора
      UnLock
      Commit
    endif
    flag := 0
  otherwise
    keyboard ""
endcase
if fl_recept
  ClrLine(24,color0)
  keyboard ""
  if f_alert({"Распечатать рецепт номер "+lstr(rcp->number_r)+" ?"},;
              {" ~Да "," ~Нет "},;
              1,"N+/BG","R/BG",18,,col1menu ) == 1
    vounc_print_recept()
  endif
endif
rest_box(buf)
return flag

*

*****
Function vounc_print_recept()
Local arr, adbf := {;
   {"SHTAMP",     "C",      5,      0},;
   {"OGRN",       "C",     30,      0},;
   {"KOD_LGOT",   "C",      3,      0},;
   {"MKB",        "C",      5,      0},;
   {"RC_SER",     "C",     10,      0},;
   {"RC_NOM",     "C",      6,      0},;
   {"RC_DATE",    "C",     10,      0},;
   {"FIO",        "C",     50,      0},;
   {"DATE_R",     "C",     10,      0},;
   {"SNILS",      "C",     20,      0},;
   {"POLIS",      "C",     25,      0},;
   {"ADRES",      "C",     80,      0},;
   {"FIO_VRACH",  "C",     50,      0},;
   {"KOD_VRACH",  "C",      5,      0},;
   {"MTRN",       "C",     80,      0},;
   {"KOL",        "C",     10,      0},;
   {"SIGNA",      "C",     30,      0};
  }
Local d
if (d := input_value(18,10,20,69,color1,;
                     {space(10)+"Введите дату выписки рецепта",;
                      substr(full_date(rcp->date_r),3)},;
                     day(sys_date),"99")) == NIL
  return NIL
endif
delFRfiles()
dbcreate(fr_data,adbf)
use (fr_data) new alias FRD
append blank
R_Use(dir_server+"mo_pers",,"P2")
goto (rcp->vrach)
R_Use(dir_server+"kartotek",,"KART")
goto (rcp->kod_k)
R_Use(dir_server+"kartote_",,"KART_")
goto (rcp->kod_k)
R_Use(dir_server+"organiz",,"ORG")
frd->OGRN := org->ogrn
frd->KOD_LGOT := kart_->KOD_LGOT
frd->MKB := rcp->kod_diag
frd->RC_SER := vounc_mem_ser
frd->RC_NOM := strzero(rcp->number_r,6)
frd->RC_DATE := iif(d<=0,"  ",strzero(d,2))+substr(full_date(rcp->date_r),3)
frd->FIO := kart->fio
frd->DATE_R := full_date(kart->DATE_R)
frd->SNILS := iif(empty(kart->snils), "", transform(kart->SNILS,picture_pf))
frd->POLIS := make_polis(kart_->spolis,kart_->npolis)
frd->ADRES := lstr(kart->kod_vu)
frd->FIO_VRACH := p2->fio
frd->KOD_VRACH := strzero(p2->kod_dlo,5)
frd->MTRN := vounc_ret1_name_trn(2,.f.)
frd->KOL := ltrim(str(rcp->kol_up*trn->n_lf))
frd->SIGNA := alltrim(str_0(rcp->kol_naz,6,1))+" мг в сутки"
org->(dbCloseArea())
p2->(dbCloseArea())
kart->(dbCloseArea())
kart_->(dbCloseArea())
//
arr := {}
if empty(frd->OGRN)
  aadd(arr,'Пустое поле "ОГРН ЛПУ"')
endif
if empty(frd->KOD_LGOT)
  aadd(arr,'Пустое поле "Код льготы"')
endif
if empty(frd->MKB)
  aadd(arr,'Пустое поле "Диагноз"')
endif
if empty(frd->RC_SER)
  aadd(arr,'Пустое поле "Серия рецепта"')
endif
if empty(frd->RC_NOM)
  aadd(arr,'Пустое поле "Номер рецепта"')
endif
if empty(frd->RC_DATE)
  aadd(arr,'Пустое поле "Дата рецепта"')
endif
if empty(frd->FIO)
  aadd(arr,'Пустое поле "ФИО"')
endif
if empty(frd->DATE_R)
  aadd(arr,'Пустое поле "Дата рождения"')
endif
if empty(frd->SNILS)
  aadd(arr,'Пустое поле "СНИЛС"')
endif
if empty(frd->POLIS)
  aadd(arr,'Пустое поле "Полис ОМС"')
endif
if frd->ADRES=='0'
  aadd(arr,'Пустое поле "Номер амбулаторной карты (номер в участке)"')
endif
if empty(frd->FIO_VRACH)
  aadd(arr,'Пустое поле "ФИО врача"')
endif
if frd->KOD_VRACH=='00000'
  aadd(arr,'Пустое поле "Код врача для рецептов по ДЛО"')
endif
if empty(frd->MTRN)
  aadd(arr,'Пустое поле "Наименование препарата"')
endif
if frd->KOL=='0'
  aadd(arr,'Пустое поле "Кол-во упаковок"')
endif
if empty(rcp->kol_naz)
  aadd(arr,'Пустое поле "Кол-во назначенного препарата"')
endif
if !empty(arr)
  n_message(arr,,"GR+/B","W+/B",,,"G+/B")
endif
//
frd->(dbCloseArea())
call_fr("mo_rcp")
select RCP
return NIL

*

*****
Function vounc_info_nazn()
ne_real()
return NIL

*

*****
Function vounc_info_recept(k)
Static sk := 1
Local str_sem, mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"~Количество рецептов",;
                "Препараты по ~месяцам",;
                "Больные + ~препараты"}
    mas_msg := {"Подсчёт количества выписанных рецептов",;
                "Итоговое значение выписанных препаратов по месяцам за год",;
                "Больные + препараты, выписанные за период времени"}
    mas_fun := {"vounc_info_recept(1)",;
                "vounc_info_recept(2)",;
                "vounc_info_recept(3)"}
    popup_prompt(T_ROW, T_COL-5, sk, mas_pmt, mas_msg, mas_fun)
  case k == 1
    f1vounc_info_recept()
  case k == 2
    f2vounc_info_recept()
  case k == 3
    f3vounc_info_recept()
endcase
if k > 0
  sk := k
endif
return NIL

*

***** 28.02.13
Function f1vounc_info_recept()
Static sn := 5, ;
       mm_menu := {{"Понедельник",2},;
                   {"Вторник"    ,3},;
                   {"Среда"      ,4},;
                   {"Четверг"    ,5},;
                   {"Пятница"    ,6},;
                   {"Суббота"    ,7},;
                   {"Воскресенье",1}}
Local sh, HH := 58, buf := save_maxrow(), n_file := "kol_rcp"+stxt,;
      arr_m, adbf, d, in, in2, last_d, skol := 0, am := {}
if (arr_m := year_month()) == NIL
  return NIL
endif
/*
if (in := input_value(18,10,20,69,color1,;
           space(10)+"Выберите начальный день недели",sn,mm_menu)) == NIL
  return NIL
endif
sn := in
if in > 2
  in2 := in - 1
elseif in == 2
  in2 := 1
elseif in == 1
  in2 := 7
endif
mywait()
adbf := {{"date1","D", 8,0},;
         {"date2","D", 8,0},;
         {"name", "C",50,0},;
         {"kol"  ,"N", 6,0}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp")
do while dow(arr_m[5]) != in
  -- arr_m[5]
enddo
do while dow(arr_m[6]) != in2
  ++ arr_m[6]
enddo
for d := arr_m[5] to arr_m[6] step 7
  append blank
  tmp->date1 := d
  tmp->date2 := d+6
  tmp->name := beforatnum(" ",date_month(tmp->date1),2)+" - "+;
               beforatnum(" ",date_month(tmp->date2),2)+;
               str(year(tmp->date2),5)+" года"
next
index on dtos(date1) to (cur_dir+"tmp")
R_Use(dir_server+'vouncrec',,"RCP")
go top
do while !eof()
  if between(rcp->date_r,arr_m[5],arr_m[6]) .and. rcp->annul == 0
    d := rcp->date_r
    do while dow(d) != in
      -- d
    enddo
    select TMP
    find (dtos(d))
    if found()
      tmp->kol ++
      skol ++
    endif
  endif
  select RCP
  skip
enddo
rest_box(buf)
if skol == 0
  func_error(4,"Не было выписано рецептов "+arr_m[4])
else
  sh := 60
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string("")
  add_string(center("Количество рецептов",sh))
  add_string(center("с "+date_8(arr_m[5])+"г. по "+date_8(arr_m[6])+"г.",sh))
  add_string("")
  select TMP
  go top
  do while !eof()
    verify_FF(HH,.t.,sh)
    add_string(tmp->name+str(tmp->kol,10))
    skip
  enddo
  close databases
  add_string(replicate("─",sh))
  add_string(padl("Итого рецептов",50)+str(skol,10))
  fclose(fp)
  viewtext(n_file)
endif
*/
sh := 80
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("Количество рецептов",sh))
add_string(center("с "+date_8(arr_m[5])+"г. по "+date_8(arr_m[6])+"г.",sh))
last_d := arr_m[5]
add_string("")
R_Use(dir_server+'kartotek',,"KART")
R_Use(dir_server+'vouncrec',,"RCP")
set relation to kod_k into KART
index on dtos(DATE_R)+str(NUMBER_R,6) to (cur_dir+"tmp_rcp") ;
      for between(date_r,arr_m[5],arr_m[6]) .and. annul == 0
go top
do while !eof()
  verify_FF(HH,.t.,sh)
  add_string(str(++skol,4)+". "+left(dtoc(rcp->date_r),5)+str(rcp->number_r,7)+;
             " "+rtrim(kart->fio))
  m := month(rcp->date_r)
  if (i := ascan(am, {|x| x[1] == m })) == 0
    aadd(am, {m,0,{}}) ; i := len(am)
  endif
  am[i,2] ++
  if (j := ascan(am[i,3], {|x| x[1] == rcp->date_r})) == 0
    aadd(am[i,3], {rcp->date_r,0}) ; j := len(am[i,3])
  endif
  am[i,3,j,2] ++
  last_d := rcp->date_r
  select RCP
  skip
enddo
add_string(replicate("─",sh))
for i := 1 to len(am)
  for j := 1 to len(am[i,3])
    verify_FF(HH,.t.,sh)
    add_string(full_date(am[i,3,j,1])+" -"+str(am[i,3,j,2],4)+" рецептов")
  next
  add_string(replicate("─",sh))
  add_string(padr(mm_month[am[i,1]],10)+" -"+str(am[i,2],4)+" рецептов")
  add_string(replicate("─",sh))
next
rest_box(buf)
close databases
add_string("с "+date_8(arr_m[5])+"г. по "+date_8(last_d)+;
           "г. итого рецептов: "+lstr(skol))
fclose(fp)
keyboard chr(K_END)
viewtext(n_file,,,,.t.,,,2,,,.f.)
return NIL

*

*****
Function f2vounc_info_recept()
Local sh, HH := 57, buf := save_maxrow(), n_file := "trn_year"+stxt,;
      arr_m, adbf
if (arr_m := year_month(,,,4)) == NIL
  return NIL
endif
mywait()
adbf := {{"TOVAR","N",5,0},;
         {"kol"  ,"N",6,0}}
for i := 1 to 12
  aadd(adbf,{"kol"+lstr(i),"N",6,0})
next
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp")
index on str(tovar,5) to (cur_dir+"tmp")
R_Use(dir_server+'vouncrec',,"RCP")
go top
do while !eof()
  if between(rcp->date_r,arr_m[5],arr_m[6]) .and. rcp->annul == 0
    pole := "tmp->kol"+lstr(month(rcp->date_r))
    select TMP
    find (str(rcp->tovar,5))
    if !found()
      append blank
      tmp->tovar := rcp->tovar
    endif
    tmp->kol += rcp->KOL_UP
    &pole := &pole + rcp->KOL_UP
  endif
  select RCP
  skip
enddo
rest_box(buf)
if tmp->(lastrec()) == 0
  func_error(4,"Не было выписано рецептов "+arr_m[4])
else
  arr_title := {"─"," ","─"}
  for i := 1 to 12
    arr_title[1] += "───┬"
    arr_title[2] += left(mm_month[i],3)+"│"
    arr_title[3] += "───┴"
  next
  arr_title[1] += "─────┬─────────────────────────────────"
  arr_title[2] += "Всего│  Наименование препаратов        "
  arr_title[3] += "─────┴─────────────────────────────────"
  sh := len(arr_title[1])
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string("")
  add_string(center("Препараты в рецептах "+arr_m[4],sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+'vouncmnn',,"MNN")
  R_Use(dir_server+'vounctrn',,"TRN")
  set relation to mnn into MNN
  select TMP
  set relation to tovar into TRN
  index on str(mnn->TIP_MNN,1)+upper(trn->name)+str(trn->c_lf,1)+str(trn->doza,6,1)+str(trn->n_lf,4) to (cur_dir+"tmp")
  go top
  do while !eof()
    s := ""
    for i := 1 to 12
      pole := "tmp->kol"+lstr(i)
      s += put_val(&pole,4)
    next
    s += put_val(tmp->kol,6)+" "+alltrim(trn->name)+" "+;
         alltrim(str_0(trn->doza,6,1))+;
         " "+alltrim(inieditspr(A__MENUVERT,mm_lf,trn->c_lf))+;
         " N"+lstr(trn->n_lf)
    add_string(s)
    skip
  enddo
  fclose(fp)
  close databases
  viewtext(n_file,,,,(sh>80),,,2)
endif
close databases
return NIL

*

*****
Function f3vounc_info_recept()
Local sh, HH := 54, buf := save_maxrow(), n_file := "pac_trn"+stxt,;
      arr_m, adbf
if (arr_m := year_month()) == NIL
  return NIL
endif
mywait()
adbf := {{"kod_k","N",7,0},;
         {"TOVAR","N",5,0},;
         {"kol"  ,"N",6,0}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp")
index on str(kod_k,7)+str(tovar,5) to (cur_dir+"tmp")
R_Use(dir_server+'vouncrec',,"RCP")
go top
do while !eof()
  if between(rcp->date_r,arr_m[5],arr_m[6]) .and. rcp->annul == 0
    select TMP
    find (str(rcp->kod_k,7)+str(rcp->tovar,5))
    if !found()
      append blank
      tmp->kod_k := rcp->kod_k
      tmp->tovar := rcp->tovar
    endif
    tmp->kol += rcp->KOL_UP
  endif
  select RCP
  skip
enddo
rest_box(buf)
if tmp->(lastrec()) == 0
  func_error(4,"Не было выписано рецептов "+arr_m[4])
else
  R_Use(dir_server+'vouncmnn',,"MNN")
  R_Use(dir_server+'vounctrn',,"TRN")
  set relation to mnn into MNN
  select TMP
  set relation to tovar into TRN
  index on tovar to (cur_dir+"tmp") unique
  arr := {}
  go top
  do while !eof()
    aadd(arr, {mnn->TIP_MNN,trn->name,trn->c_lf,trn->doza,trn->n_lf,tovar})
    skip
  enddo
  asort(arr,,,{|x,y| iif(x[1] == y[1],;
                         iif(x[2] == y[2],;
                             iif(x[3] == y[3],;
                                 iif(x[4] == y[4], x[5] < y[5], x[4] < y[4]),;
                                 x[3] < y[3]),;
                             x[2] < y[2]),;
                         x[1] < y[1]) })
  arr_title := array(9) ; n := 50
  for i := 1 to 9
    if eq_any(i,1,9)
      arr_title[i] := replicate("─",n)
    elseif i == 5
      arr_title[i] := padc("Ф.И.О. пациента",n)
    else
      arr_title[i] := space(n)
    endif
  next
  for i := 1 to len(arr)
    arr_title[1] += "┬────"
    arr_title[2] += "│"+substr(arr[i,2],1,4)
    arr_title[3] += "│"+substr(arr[i,2],5,4)
    arr_title[4] += "│"+substr(arr[i,2],9,4)
    arr_title[5] += "│"+substr(arr[i,2],13,4)
    arr_title[6] += "│"+padc(alltrim(str_0(arr[i,4],6,1)),4)
    arr_title[7] += "│"+padc(alltrim(inieditspr(A__MENUVERT,mm_lf,arr[i,3])),4)
    arr_title[8] += "│"+padc("N"+lstr(arr[i,5]),4)
    arr_title[9] += "┴────"
  next
  sh := len(arr_title[1])
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string("")
  add_string(center("Больные + препараты в рецептах "+arr_m[4],sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+'kartotek',,"KART")
  select TMP
  set relation to kod_k into KART
  index on upper(kart->fio)+str(kod_k,7) to (cur_dir+"tmp")
  old_kart := -1
  s := "" ; ii := 0
  go top
  do while !eof()
    if old_kart != tmp->kod_k
      if !empty(s)
        if verify_FF(HH,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(s)
        add_string(replicate("─",sh))
      endif
      old_kart := tmp->kod_k
      s := padr(lstr(++ii)+"("+lstr(kart->kod_vu)+") "+kart->fio,n)+;
           space(5*len(arr))
    endif
    if (i := ascan(arr,{|x| x[6] == tmp->tovar})) > 0
      s := stuff(s,n+5*(i-1),5,put_val(tmp->kol,5))
    endif
    skip
  enddo
  close databases
  if !empty(s)
    add_string(s)
    add_string(replicate("─",sh))
  endif
  fclose(fp)
  Private yes_albom := .t.
  viewtext(n_file,,,,(sh>80),,,5)
endif
close databases
return NIL

*

*****
Function vounc_info_sprav()
Local sh := 64, HH := 57, buf := save_maxrow(), n_file := "mnn_trn"+stxt,;
      old_tip_mnn := -1
mywait()
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center(expand("Список лекарственных препаратов"),sh))
R_Use(dir_server+'vounctrn',,"TRN")
index on str(mnn,5)+upper(name)+str(c_lf,1)+str(doza,6,1)+str(n_lf,4) to (cur_dir+"tmp_trn")
R_Use(dir_server+'vouncmnn',,"MNN")
index on str(TIP_MNN,1)+upper(name) to (cur_dir+"tmp_mnn")
go top
do while !eof()
  if old_tip_mnn != mnn->tip_mnn
    old_tip_mnn := mnn->tip_mnn
    add_string("")
    add_string(inieditspr(A__MENUVERT,mm_tip_mnn,mnn->tip_mnn))
  endif
  add_string(space(5)+alltrim(mnn->name)+" ("+alltrim(mnn->name_lat)+")")
  select TRN
  find (str(mnn->(recno()),5))
  do while mnn->(recno()) == trn->mnn .and. !eof()
    add_string(space(10)+alltrim(trn->name)+" "+alltrim(str_0(trn->doza,6,1))+;
               " "+alltrim(inieditspr(A__MENUVERT,mm_lf,trn->c_lf))+;
               " N"+lstr(trn->n_lf)+;
               " ("+alltrim(trn->name_lat)+")")
    skip
  enddo
  select MNN
  skip
enddo
close databases
fclose(fp)
rest_box(buf)
viewtext(n_file)
return NIL

*

*****
Function vounc_sprav_trn()
Local arr[US_LEN], blk
arr[US_TOP      ] := T_ROW
arr[US_BOTTOM   ] := 23
arr[US_LEFT     ] := 0
arr[US_RIGHT    ] := 79
arr[US_BASE     ] := dir_server+'vounctrn'
arr[US_ARR_BROWSE]:= {"═","░","═","N/BG,W+/N,B/BG,W+/B",.t.}
arr[US_COLUMN   ] := {{" Наименование",{|| left(name,20)},blk},;
                      {"дозир.",{|| str_0(doza,6,1)},blk},;
                      {"ед.из",{|| inieditspr(A__MENUVERT,mm_lf,c_lf) },blk},;
                      {"в уп",{|| str(n_lf,4)},blk},;
                      {" По латыни",{|| left(name_lat,18)},blk},;
                      {" МНН",{|| left(inieditspr(A__POPUPMENU,dir_server+'vouncmnn',mnn),21) },blk}}
arr[US_BLK_DEL  ] := {|_k| vounc_del_trn(_k) }
arr[US_ROD_PADEG] := arr[US_IM_PADEG ] := arr[US_SEMAPHORE] := "ТРН"
arr[US_EDIT_SPR ] := {{"name",    "C",60,0,,,space(60),,"Наименование"},;
                      {"name_lat","C",60,0,,,space(60),,"По латыни   "},;
                      {"doza","N",6,1,,,0,,"Дозировка"},;
                      {"c_lf","N",1,0,NIL,;
                       {|x|menu_reader(x,mm_lf,A__MENUVERT,,,.f.)},;
                       0,{|x|inieditspr(A__MENUVERT,mm_lf,x)},;
                       "Единицы измерения"},;
                      {"n_lf","N",4,0,,,0,,"Количество в упаковке"},;
                      {"mnn","N",5,0,,;
                       {|x|menu_reader(x,{dir_server+'vouncmnn'},A__POPUPMENU,,,.f.)},;
                       1,{|x|inieditspr(A__POPUPMENU,dir_server+'vouncmnn',x)},;
                       "МНН"};
                     }
edit_u_spr(1,arr)
return NIL

*****
Function vounc_del_trn(k)
Local _fl, buf := save_maxrow()
mywait()
R_Use(dir_server+"vouncnaz",,"__B")
index on str(tovar,5) to (cur_dir+"tmp_nazn")
find (str(k,5))
_fl := found()
dbCloseArea()
if !_fl
  R_Use(dir_server+"vouncrec",,"__B")
  index on str(tovar,5) to (cur_dir+"tmp_recp")
  find (str(k,5))
  _fl := found()
  dbCloseArea()
endif
rest_box(buf)
return !_fl

*

*****
Function vounc_sprav_mnn()
Local arr[US_LEN], blk
arr[US_TOP      ] := T_ROW
arr[US_BOTTOM   ] := 23
arr[US_LEFT     ] := 0
arr[US_RIGHT    ] := 79
arr[US_BASE     ] := dir_server+'vouncmnn'
arr[US_ARR_BROWSE]:= {"═","░","═","N/BG,W+/N,B/BG,W+/B",.t.}
arr[US_COLUMN   ] := {{" МНН",{|| left(name,27)}},;
                      {" По латыни",{|| left(name_lat,26) }},;
                      {" Тип",{|| padr(inieditspr(A__MENUVERT,mm_tip_mnn,tip_mnn),23) }}}
arr[US_BLK_DEL  ] := {|_k| vounc_del_mnn(_k) }
arr[US_ROD_PADEG] := arr[US_IM_PADEG ] := arr[US_SEMAPHORE] := "МНН"
arr[US_EDIT_SPR ] := {{"name",    "C",60,0,,,space(60),,"Наименование"},;
                      {"name_lat","C",60,0,,,space(60),,"По латыни   "},;
                      {"tip_mnn","N",1,0,NIL,;
                       {|x|menu_reader(x,mm_tip_mnn,A__MENUVERT,,,.f.)},;
                       0,{|x|inieditspr(A__MENUVERT,mm_tip_mnn,x)},;
                       "Тип"};
                     }
edit_u_spr(1,arr)
return NIL

*****
Function vounc_del_mnn(k)
Local _fl
R_Use(dir_server+"vounctrn",,"__B")
dbLocateProgress( {|| __b->mnn == k} )
_fl := !found()
dbCloseArea()
return _fl

*

*****
Function vounc_sprav_nastr(reg)
Static mm_regim := {{"вручную      ",1},{"автоматически",2}}
Local mm_tmp := {}, str_sem
do case
  case reg == 1 // определить
    Public vounc_mem_regim   := 1,;
           vounc_mem_last_rc := 0,;
           vounc_mem_nom1    := 1,;
           vounc_mem_nom2    := 999999,;
           vounc_mem_diag    := 'Z94.0',;
           vounc_mem_ser     := space(10)
  case reg == 2 .and. Vounc_Tools_Ini(1,0,0) // редактирование
    if tip_polzovat != 0
      return func_error(4,err_admin)
    endif
    str_sem := "Редактирование настроек VOUNC"
    if G_SLock(str_sem)
      close databases
      delete file tmp.dbf
      aadd(mm_tmp, {"regim","N",1,0,NIL,;
                    {|x|menu_reader(x,mm_regim,A__MENUVERT)},;
                    1,{|x|inieditspr(A__MENUVERT,mm_regim,x)},;
                    "Каким образом проставляется номер рецепта при добавлении"})
      aadd(mm_tmp, {"last_rc","N",6,0,NIL,;
                    NIL,;
                    0,NIL,;
                    "Номер последнего (автоматически) добавленного рецепта",,;
                    {|| vounc_val_nom() }})
      aadd(mm_tmp, {"nom1","N",6,0,NIL,;
                    NIL,;
                    0,NIL,;
                    "Введите начальный номер рецепта",;
                    {|| vounc_val_nom() }})
      aadd(mm_tmp, {"nom2","N",6,0,NIL,;
                    NIL,;
                    0,NIL,;
                    "Введите конечный номер рецепта",;
                    {|| vounc_val_nom() }})
      aadd(mm_tmp, {"ser","C",10,0,"@!",;
                    NIL,;
                    "",NIL,;
                    "Серия для печати рецептов"})
      aadd(mm_tmp, {"diag","C",5,0,"@!",;
                    NIL,;
                    "",NIL,;
                    "Диагноз по умолчанию"})
      init_base(cur_dir+"tmp",,mm_tmp,0)
      use (cur_dir+"tmp") new
      append blank
      tmp->regim   := vounc_mem_regim
      tmp->last_rc := vounc_mem_last_rc
      tmp->ser     := vounc_mem_ser
      tmp->diag    := vounc_mem_diag
      tmp->nom1    := vounc_mem_nom1
      tmp->nom2    := vounc_mem_nom2
      close databases
      if f_edit_spr(A__EDIT,mm_tmp,"настройке программы",;
                    "g_use(cur_dir+'tmp',,,.t.,.t.)",0,1,"spr_nastr") > 0
        use (cur_dir+"tmp") new
        vounc_mem_regim   := tmp->regim
        vounc_mem_last_rc := tmp->last_rc
        vounc_mem_ser     := tmp->ser
        vounc_mem_diag    := tmp->diag
        vounc_mem_nom1    := tmp->nom1
        vounc_mem_nom2    := tmp->nom2
        Vounc_Tools_Ini(2,0,0)
      endif
      close databases
      G_SUnLock(str_sem)
    else
      func_error(4,err_slock)
    endif
endcase
return NIL

*****
Static Function vounc_val_nom()
if mnom1 <= 0 .or. mnom2 <= 0
  func_error(4,'Начальный (конечный) номер должен быть положительным числом')
elseif mnom1 > mnom2
  func_error(4,'Начальный номер рецепта должен быть меньше конечного')
elseif !between(mlast_rc,mnom1-1,mnom2)
  func_error(4,'Номер последнего (автоматически) добавленного рецепта не попадает в диапазон')
endif
return .t.

*****
Function Vounc_Tools_Ini(reg,k1,k2)
Static arr := {{"vounc_mem_regim",  "N"},;
               {"vounc_mem_last_rc","N"},;
               {"vounc_mem_diag",   "C"},;
               {"vounc_mem_nom1",   "N"},;
               {"vounc_mem_nom2",   "N"},;
               {"vounc_mem_ser",    "C"}}
Local name_section := "ВОУНЦ"
Local i, j, ta := {}, v, fl
if (fl := Semaphor_Tools_Ini(1))
  name_section += "-"+lstr(k1)+"-"+lstr(k2)
  if reg == 1 // чтение
    ta := GetIniSect(tools_ini, name_section) // вернуть двумерный массив содержимого секции {{"наим.","знач."},...}
    for j := 1 to len(ta)
      if (i := ascan(arr, {|x| upper(x[1]) == ta[j,1] })) > 0
        &(arr[i,1]) := iif(arr[i,2]=="C", ta[j,2], val(ta[j,2]))
        if arr[i,2]=="N" .and. len(arr[i]) == 2
          &(arr[i,1]) := int(val(ta[j,2]))
        endif
      endif
    next
  else // запись
    for i := 1 to len(arr)
      v := &(arr[i,1])
      aadd(ta, {arr[i,1], iif(arr[i,2]=="C", v, lstr(v))})
    next
    SetIniSect(tools_ini, name_section, ta) // запись секции в ini.файл
  endif
  Semaphor_Tools_Ini(2)
endif
return fl

*****
Static Function vounc_ret_name_trn(ltovar,k,fl_upak)
Local ret := space(10)
if ltovar > 0
  R_Use(dir_server+"vounctrn",,"TRN")
  goto (ltovar)
  ret := vounc_ret1_name_trn(k,fl_upak)
  use
endif
return ret

*****
Static Function vounc_ret1_name_trn(k,fl_upak)
Local ret
DEFAULT fl_upak TO .t.
if k == 1  // по русски
  ret := alltrim(trn->name)+" "+alltrim(str_0(trn->doza,6,1))+" "+;
         alltrim(inieditspr(A__MENUVERT,mm_lf,trn->c_lf))
  if fl_upak
    ret += " N"+lstr(trn->n_lf)
  endif
else  // по латыни
  ret := alltrim(trn->name_lat)+" "+alltrim(str_0(trn->doza,6,1))+" "+;
         alltrim(inieditspr(A__MENUVERT,mm_lf_lat,trn->c_lf))
  if fl_upak
    ret += " N"+lstr(trn->n_lf)
  endif
endif
return ret

*

*****
Function vounc_get_tovar(k,r,c,_tip_mnn)
Local arr_name := {}, arr_kod := {}
Local buf := savescreen(), ret, i, r1, r2, c1, c2, l := 0
DEFAULT _tip_mnn TO 2
R_Use(dir_server+"vouncmnn",,"MNN")
R_Use(dir_server+"vounctrn",,"TRN")
index on upper(name) to (cur_dir+"tmp_trn")
dbSetRelation( "MNN", {|| mnn}, "mnn" )
go top
do while !eof()
  if iif(_tip_mnn == 2, .t., _tip_mnn == mnn->tip_mnn)
    aadd(arr_name, vounc_ret1_name_trn(1)) ; aadd(arr_kod,recno())
    l := max(l,len(atail(arr_name)))
  endif
  skip
enddo
close databases
if len(arr_kod) == 0
  s := "Пустой справочник препаратов"
  if eq_any(_tip_mnn,0,1)
    s += ' "'+upper(alltrim(mm_tip_mnn[_tip_mnn+1,1]))+'"'
  endif
  func_error(4,s)
else
  if k != NIL
    i := ascan(arr_kod,k)
  endif
  r2 := r-1 ; r1 := r2-len(arr_kod)-1
  if r1 < 2 ; r1 := 2 ; endif
  c1 := c ; c2 := c1 + l + 3
  if c2 > 77
    c2 := 77 ; c1 := c2 - l - 3
    if c1 < 0 ; c1 := 0 ; endif
  endif
  status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор препарата")
  if (k := popup(r1,c1,r2,c2,arr_name,i,color0,.t.)) > 0
    ret := {arr_kod[k],arr_name[k]}
  endif
endif
restscreen(buf)
return ret