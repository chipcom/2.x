***** mo_vounc.prg - ВОУНЦ
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

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

*

*****
Function vounc_Reconstruct_BD()
Local vouncmnn := {;
   {"NAME",       "C",60,0},;
   {"NAME_LAT",   "C",60,0},;
   {"TIP_MNN",    "N", 1,0};  // тип МНН
  }
Local vounctrn := {;
   {"NAME",       "C",60,0},;
   {"NAME_LAT",   "C",60,0},;
   {"doza",       "N", 6,1},; // дозировка
   {"C_LF",       "N", 1,0},; // 0-мг,1-мг/мл
   {"N_LF",       "N", 4,0},; // количество в упаковке
   {"MNN",        "N", 5,0};
  }
Local vouncnaz := {;
   {"KOD_K",   "N",   7, 0},; // код по картотеке
   {"DATE_NAZ","D",   8, 0},; // Дата назначения
   {"KOD_DIAG","C",   5, 0},; // Код заболевания (по МКБ-10)
   {"TOVAR",   "N",   5, 0},; // код ТРН
   {"KOL_NAZ", "N",   6, 1},; // количество назначенного препарата в сутки
   {"KOL_UP",  "N",   2, 0},; // количество упаковок
   {"DATE_E" , "C",   4, 0},; // дата добавления
   {"KOD_P"  , "C",   1, 0};  // код пользователя, добавившего
  }
Local vouncrec := {;
   {"KOD_K",   "N",   7, 0},; // код по картотеке
   {"KOD_DIAG","C",   5, 0},; // Код заболевания (по МКБ-10)
   {"NUMBER_R","N",   6, 0},; // номер рецепта
   {"DATE_R",  "D",   8, 0},; // Дата выписки рецепта
   {"TOVAR",   "N",   5, 0},; // код ТРН
   {"VRACH",   "N",   4, 0},; // код врача по "mo_pers"
   {"KOL_NAZ", "N",   6, 1},; // количество назначенного препарата в сутки
   {"KOL_UP",  "N",   2, 0},; // количество упаковок
   {"ANNUL",   "N",   1, 0},; // 1-аннулирован, 0-обычный
   {"D_ANNUL", "D",   8, 0},; // Дата аннулирования рецепта
   {"DATE_E" , "C",   4, 0},; // дата добавления
   {"KOD_P"  , "C",   1, 0},; // код пользователя, добавившего
   {"DATE_E2", "C",   4, 0},; // дата редактирования
   {"KOD_P2" , "C",   1, 0};  // код пользователя, исправившего
  }
reconstruct(dir_server+"vouncmnn",vouncmnn,,,.t.)
reconstruct(dir_server+"vounctrn",vounctrn,,,.t.)
reconstruct(dir_server+"vouncnaz",vouncnaz,,,.t.)
reconstruct(dir_server+"vouncrec",vouncrec,,,.t.)
return NIL

*****
Function vounc_init_array_files_DB()
Static arr_f := {"vouncmnn","vounctrn","vouncnaz","vouncrec"}
return arr_f

*

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

*===============================================================================

***** 16.01.19
Function create1reestr19(_recno,_nyear,_nmonth)
Local buf := savescreen(), s, i, j, pole
Private mpz[100], oldpz[100], atip[100]
for j := 0 to 99
  pole := "tmp->PZ"+lstr(j)
  mpz[j+1] := oldpz[j+1] := &pole
  atip[j+1] := "-"
  if (i := ascan(glob_array_PZ_19, {|x| x[1] == j })) > 0
    atip[j+1] := glob_array_PZ_19[i,4]
  endif
next
Private pkol := tmp->kol, psumma := tmp->summa, pnyear := _nyear
Private old_kol := pkol, old_summa := psumma, p_blk := {|mkol,msum| f_blk_create1reestr19(_nyear) }
close databases
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_
use (cur_dir+"tmpb") new alias TMP
set relation to kod_human into HUMAN
index on upper(human->fio)+dtos(human->k_data) to (cur_dir+"tmpb") for kod_tmp == _recno
go top
eval(p_blk)
if Alpha_Browse(3,0,maxrow()-4,79,"f1create1reestr19",color0,;
                "Составление реестра случаев за "+mm_month[_nmonth]+str(_nyear,5)+" года","BG+/GR",;
                .t.,.t.,,,"f2create1reestr19",,;
                {'═','░','═',"N/BG,W+/N,B/BG,W+/B",,300} )
  if pkol > 0 .and. (j := f_alert({"",;
                  "Каким образом сортировать реестр, отправляемый в ТФОМС",;
                  ""},;
                 {" по ~ФИО пациента "," по ~убыванию стоимости "},;
                 1,"W/RB","G+/RB",maxrow()-6,,"BG+/RB,W+/R,W+/RB,GR+/R" )) > 0
    f_message({"Системная дата: "+date_month(sys_date,.t.),;
               "Обращаем Ваше внимание, что",;
               "реестр будет создан с этой датой.",;
               "",;
               "Изменить её будет НЕВОЗМОЖНО!",;
               "",;
               "Сортировка реестра: "+{"по ФИО пациента","по убыванию стоимости лечения"}[j]},,;
               "GR+/R","W+/R")
    if f_Esc_Enter("составления реестра")
      restscreen(buf)
      create2reestr19(_recno,_nyear,_nmonth,j)
    endif
  endif
endif
close databases
restscreen(buf)
return NIL

***** 21.05.17
Function f_blk_create1reestr19(_nyear)
Local i, s, ta[2], sh := maxcol()+1
s := "Случаев - "+expand_value(pkol)+" на сумму "+expand_value(psumma,2)+" руб."
@ 0,0 say padc(s,sh) color color1
s := ""
for i := 1 to len(mpz)
  if !empty(mpz[i])
    s += alltrim(str_0(mpz[i],9,2))+" "+atip[i]+", "
  endif
next
if !empty(s)
  s := "(п/з: "+substr(s,1,len(s)-2)+")"
endif
perenos(ta,s,sh)
for i := 1 to 2
  @ i,0 say padc(alltrim(ta[i]),sh) color color1
next
return NIL

***** 16.01.19
Static Function f_p_z19(_pzkol,_pz,k)
Local s, s2, i
s2 := alltrim(str_0(_pzkol,9,2))
s := atip[_PZ+1]
if (i := ascan(glob_array_PZ_19, {|x| x[1] == _PZ })) > 0 .and. !empty(glob_array_PZ_19[i,5])
  s2 += glob_array_PZ_19[i,5]
endif
return iif(k == 1, s, s2)

***** 29.03.16
Function f1create1reestr19(oBrow)
Local oColumn, tmp_color, blk_color := {|| if(tmp->plus, {1,2}, {3,4}) }, n := 30
oColumn := TBColumnNew(" ", {|| if(tmp->plus,""," ") })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Ф.И.О. больного",n), {|| padr(human->fio,n) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("План-заказ", {|| padc(f_p_z19(human_->pzkol,tmp->pz,1),10) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол-во", {|| padc(f_p_z19(human_->pzkol,tmp->pz,2),6) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Нача-; ло", {|| left(dtoc(human->n_data),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Окончан.;лечения", {|| date_8(human->k_data) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Стоимость; лечения", {|| put_kopE(human->cena_1,10) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
tmp_color := setcolor("N/BG")
@ maxrow()-3,0 say padr(" <Esc> - выход     <Enter> - подтверждение составления реестра",80)
@ maxrow()-2,0 say padr(" <Ins> - отметить одного пациента или снять отметку с одного пациента",80)
@ maxrow()-1,0 say padr(" <+> - отметить всех пациентов (или по одному виду ПЛАНА-ЗАКАЗА) ",80)
@ maxrow()-0,0 say padr(" <-> - снять со всех отметки (никто не попадает в реестр)",80)
mark_keys({"<Esc>","<Enter>","<Ins>","<+>","<->","<F9>"},"R/BG")
setcolor(tmp_color)
return NIL

***** 16.01.19
Function f2create1reestr19(nKey,oBrow)
Local buf, rec, k := -1, s, i, j, mas_pmt := {}, arr, r1, r2
do case
  case nkey == K_INS
    replace tmp->plus with !tmp->plus
    j := tmp->pz + 1
    i := ascan(glob_array_PZ_19, {|x| x[1] == tmp->PZ })
    if tmp->plus
      psumma += human->cena_1 ; pkol++
      if i > 0 .and. !empty(glob_array_PZ_19[i,5])
        mpz[j] ++
      else
        mpz[j] += human_->PZKOL
      endif
    else
      psumma -= human->cena_1 ; pkol--
      if i > 0 .and. !empty(glob_array_PZ_19[i,5])
        mpz[j] --
      else
        mpz[j] -= human_->PZKOL
      endif
    endif
    eval(p_blk)
    k := 0
    keyboard chr(K_TAB)
  case nkey == 43  // +
    arr := {}
    aadd(mas_pmt, "Отметить всех пациентов") ; aadd(arr,-1)
    if !empty(oldpz[1])
      aadd(mas_pmt, "Отметить неопределённых пациентов") ; aadd(arr,0)
    endif
    for j := 2 to len(oldpz)
      if !empty(oldpz[j]) .and. (i := ascan(glob_array_PZ_19, {|x| x[1] == j-1 })) > 0
        aadd(mas_pmt, 'Отметить "'+glob_array_PZ_19[i,3]+'"') ; aadd(arr,j-1)
      endif
    next
    r1 := 12
    r2 := r1 + len(mas_pmt) + 1
    if r2 > maxrow()-2
      r2 := maxrow()-2
      r1 := r2 - len(mas_pmt) - 1
      if r1 < 2
        r1 := 2
      endif 
    endif 
    if (j := popup_SCR(r1,12,r2,67,mas_pmt,1,color5,.t.)) > 0
      j := arr[j]
      rec := recno()
      buf := save_maxrow()
      mywait()
      if j == -1
        tmp->(dbeval({|| tmp->plus := .t. }))
        psumma := old_summa ; pkol := old_kol
        aeval(mpz, {|x,i| mpz[i] := oldpz[i] })
      else
        psumma := pkol := 0
        afill(mpz,0)
        mpz[j+1] := oldpz[j+1]
        go top
        do while !eof()
          if tmp->pz == j
            tmp->plus := .t.
            psumma += human->cena_1
            pkol++
          else
            tmp->plus := .f.
          endif
          skip
        enddo
      endif
      goto (rec)
      rest_box(buf)
      eval(p_blk)
      k := 0
    endif
  case nkey == 45  //  -
    rec := recno()
    buf := save_maxrow()
    mywait()
    tmp->(dbeval({|| tmp->plus := .f. }))
    goto (rec)
    rest_box(buf)
    psumma := pkol := 0
    afill(mpz,0)
    eval(p_blk)
    k := 0
endcase
return k

***** 16.01.19 создание XML-файлов реестра
Function create2reestr19(_recno,_nyear,_nmonth,reg_sort)
Local mnn, mnschet := 1, fl, mkod_reestr, name_zip, arr_zip := {}, ;
      lst, lshifr1, code_reestr, mb, me, nsh, adiag_talon[16]
//       
stat_msg("Составление реестра случаев")
close databases
nsh := f_mb_me_nsh(_nyear,@mb,@me)
R_Use(dir_exe+"_mo_mkb",,"MKB_10")
index on shifr+str(ks,1) to (cur_dir+"_mo_mkb")
G_Use(dir_server+"mo_rees",,"REES")
index on str(nn,nsh) to (cur_dir+"tmp_rees") for nyear == _nyear .and. nmonth == _nmonth
fl := .f.
for mnn := mb to me
  find (str(mnn,nsh))
  if !found() // нашли свободный номер
    fl := .t. ; exit
  endif
next
if !fl
  close databases
  return func_error(10,"Не удалось найти свободный номер пакета в ТФОМС. Проверьте настройки!")
endif
index on str(nschet,6) to (cur_dir+"tmp_rees") for nyear == _nyear
if !eof()
  go bottom
  mnschet := rees->nschet+1
endif
if !between(mnschet,mem_beg_rees,mem_end_rees)
  fl := .f.
  for mnschet := mem_beg_rees to mem_end_rees
    find (str(mnschet,6))
    if !found() // нашли свободный номер
      fl := .t. ; exit
    endif
  next
  if !fl
    close databases
    return func_error(10,"Не удалось найти свободный номер реестра. Проверьте настройки!")
  endif
endif
set index to
AddRecN()
rees->KOD    := recno()
rees->NSCHET := mnschet
rees->DSCHET := sys_date
rees->NYEAR  := _NYEAR
rees->NMONTH := _NMONTH
rees->NN     := mnn
s := "RM"+CODE_LPU+"T34"+"_"+right(strzero(_NYEAR,4),2)+strzero(_NMONTH,2)+strzero(mnn,nsh)
rees->NAME_XML := {"H","F"}[p_tip_reestr]+s
mkod_reestr := rees->KOD
rees->CODE  := ret_unique_code(mkod_reestr)
code_reestr := rees->CODE
//
G_Use(dir_server+"mo_xml",,"MO_XML")
AddRecN()
mo_xml->KOD    := recno()
mo_xml->FNAME  := rees->NAME_XML
mo_xml->FNAME2 := "L"+s
mo_xml->DFILE  := rees->DSCHET
mo_xml->TFILE  := hour_min(seconds())
mo_xml->TIP_OUT := _XML_FILE_REESTR // тип высылаемого файла;1-реестр
mo_xml->REESTR := mkod_reestr
//
rees->KOD_XML := mo_xml->KOD
UnLock
Commit
//
//R_Use(exe_dir+"_mo_v024",cur_dir+"_mo_v024","V024")
use_base("lusl")
use_base("luslc")
use_base("luslf")
laluslf := "luslf"
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"mo_pers",,"P2")
R_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"mo_rhum",,"RHUM")
index on str(REESTR,6) to (cur_dir+"tmp_rhum")
G_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"mo_su",,"MOSU")
G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
if p_tip_reestr == 1
  R_Use(dir_server+"kart_inv",,"INV")
  index on str(kod,7) to (cur_dir+"tmp_inv")
endif
R_Use(dir_server+"kartote2",,"KART2")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_, to recno() into KART2 
R_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","ONKNA") // онконаправления
R_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","ONKCO")
R_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","ONKSL") // Сведения о случае лечения онкологического заболевания
R_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","ONKDI") // Диагностический блок
R_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","ONKPR") // Сведения об имеющихся противопоказаниях
G_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","ONKUS")
G_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","ONKLE")
G_Use(dir_server+"human_2",,"HUMAN_2")
G_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
use (cur_dir+"tmpb") new
set relation to kod_human into HUMAN
if reg_sort == 1
  index on upper(human->fio) to (cur_dir+"tmpb") for kod_tmp==_recno .and. plus
else
  index on str(pz,2)+str(10000000-human->cena_1,11,2) to (cur_dir+"tmpb") for kod_tmp==_recno .and. plus
endif
pkol := psumma := iusl := 0
go top
do while !eof()
  pkol++ ; psumma += human->cena_1
  @ maxrow(),1 say lstr(pkol) color cColorSt2Msg
  select RHUM
  AddRec(6)
  rhum->REESTR := mkod_reestr
  rhum->KOD_HUM := human->kod
  rhum->REES_ZAP := pkol
  human_->(G_RLock(forever))
  if human_->REES_NUM < 99
    human_->REES_NUM := human_->REES_NUM+1
  endif
  human_->REESTR := mkod_reestr
  human_->REES_ZAP := pkol
  UnLock
  if pkol % 2000 == 0
    Commit
  endif
  select TMPB
  skip
enddo
select TMPB
set relation to
select REES
G_RLock(forever)
rees->KOL := pkol
rees->SUMMA := psumma
dbUnlockAll()
dbCommitAll()
//
Private arr_usl_otkaz
//
oXmlDoc := HXMLDoc():New()
oXmlDoc:Add( HXMLNode():New( "ZL_LIST") )
 oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
  s := '3.11'
  mo_add_xml_stroke(oXmlNode,"VERSION" ,s)
  mo_add_xml_stroke(oXmlNode,"DATA"    ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"FILENAME",mo_xml->FNAME)
  mo_add_xml_stroke(oXmlNode,"SD_Z"    ,lstr(pkol)) 
 oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "SCHET" ) )
  mo_add_xml_stroke(oXmlNode,"CODE"   ,lstr(code_reestr))
  mo_add_xml_stroke(oXmlNode,"CODE_MO",CODE_MO)
  mo_add_xml_stroke(oXmlNode,"YEAR"   ,lstr(_NYEAR))
  mo_add_xml_stroke(oXmlNode,"MONTH"  ,lstr(_NMONTH))
  mo_add_xml_stroke(oXmlNode,"NSCHET" ,lstr(rees->NSCHET))
  mo_add_xml_stroke(oXmlNode,"DSCHET" ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"SUMMAV" ,str(psumma,15,2))
  //mo_add_xml_stroke(oXmlNode,"COMENTS","")
//
select RHUM
set relation to kod_hum into HUMAN
index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR==mkod_reestr
go top
do while !eof()
  @ maxrow(),0 say str(rhum->REES_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
  fl_DISABILITY := is_zak_sl := is_zak_sl_vr := .f.
  lshifr_zak_sl := lvidpoms := ""
  a_usl := {} ; a_fusl := {} ; lvidpom := 1 ; lfor_pom := 3
  atmpusl := {} ; akslp := {} ; akiro := {} ; tarif_zak_sl := human->cena_1
  kol_kd := 0
  is_KSG := .f.
  v_reabil_slux := 0
  m1veteran := 0
  m1mobilbr := 0  // мобильная бригада
  m1mesto_prov := 0
  m1p_otk := 0    // признак отказа 
  m1dopo_na := 0
  m1napr_v_mo := 0 // {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
  arr_mo_spec := {} 
  m1napr_stac := 0 // {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
  m1profil_stac := 0
  m1napr_reab := 0
  m1profil_kojki := 0
  fl_disp_nabl := .f.
  ldate_next := ctod("")
  //   
  is_oncology := f_is_oncology(1)
  if p_tip_reestr == 2
    is_oncology := 0
  endif
  arr_onkna := {}
  select ONKNA
  find (str(human->kod,7))
  do while onkna->kod == human->kod .and. !eof()
    mosu->(dbGoto(onkna->U_KOD))
    aadd(arr_onkna, {onkna->NAPR_DATE,onkna->NAPR_V,onkna->MET_ISSL,mosu->shifr1})
    skip
  enddo
  select ONKCO
  find (str(human->kod,7))
  //
  mvsod := 0
  select ONKSL
  find (str(human->kod,7))
  //
  arr_onkdi := {}
  select ONKDI
  find (str(human->kod,7))
  do while onkdi->kod == human->kod .and. !eof()
    aadd(arr_onkdi, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
    skip
  enddo
  //
  arr_onkpr := {}
  select ONKPR
  find (str(human->kod,7))
  do while onkpr->kod == human->kod .and. !eof()
    aadd(arr_onkpr, {onkpr->PROT,onkpr->D_PROT})
    skip
  enddo
  //
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,,@lst,,@s)
      lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
      if human_->USL_OK == 3 .and. is_usluga_disp_nabl(lshifr)
        ldate_next := c4tod(human->DATE_OPL)
        fl_disp_nabl := .t.
      endif
      aadd(atmpusl,lshifr)
      if eq_any(left(lshifr,5),"1.11.","55.1.")
        kol_kd += hu->kol_1
        is_KSG := .t.
      endif
      if !empty(s) .and. "," $ s
        lvidpoms := s
      endif
      if (hu->stoim_1 > 0 .or. left(lshifr,3) == "71.") .and. (i := ret_vid_pom(1,lshifr,human->k_data)) > 0
        lvidpom := i
      endif
      if f_is_neotl_pom(lshifr)
        lfor_pom := 2 // неотложная
      endif
      if lst == 1
        lshifr_zak_sl := lshifr
        if f_is_zak_sl_vr(lshifr) // зак.случай в п-ке
          is_zak_sl_vr := .t.
        else
          is_zak_sl_vr := .t. // КСГ
          if human_->USL_OK < 3 .and. p_tip_reestr == 1
            if !empty(human_2->pc1)
              akslp := List2Arr(human_2->pc1)
            endif  
            if !empty(human_2->pc2)
              akiro := List2Arr(human_2->pc2)
            endif  
          endif
          if !empty(akslp) .or. !empty(akiro)
            otd->(dbGoto(human->OTD))
            f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
            tarif_zak_sl := fcena_oms(lshifr,(human->vzros_reb==0),human->k_data)
          endif
          /*if eq_any(human_->USL_OK,1,2) .and. human_->PROFIL == 158 .and. is_reabil_slux
            if _NYEAR == 2018
              t_arr := {"1331.0","1332.0","1333.0","1335.0","2127.0","2128.0","2130.0"}
              for i := 1 to len(t_arr)
                if t_arr[i] == lshifr .and. !between(human_2->PN1,1,3) 
                  v_reabil_slux := human_2->PN1 
                endif
              next
            endif
          endif*/ 
        endif
      else
        aadd(a_usl,hu->(recno()))
      endif
    endif
    select HU
    skip
  enddo
  if is_oncology == 2 .and. human_->USL_OK == 3 .and. fl_disp_nabl // Диспансерное наблюдение
    is_oncology := 1 // для дисп.наблюдения не вводится онкология
  endif
  if !empty(lvidpoms) 
    if !eq_ascan(atmpusl,"55.1.2","55.1.3") .or. glob_mo[_MO_KOD_TFOMS] == '801935' // ЭКО-Москва
      lvidpoms := ret_vidpom_licensia(human_->USL_OK,lvidpoms) // только для дн.стационара при стационаре
    endif
    if !empty(lvidpoms) .and. !("," $ lvidpoms)
      lvidpom := int(val(lvidpoms))
      lvidpoms := ""
    endif
  endif
  if !empty(lvidpoms)
    if eq_ascan(atmpusl,"55.1.1","55.1.4")
      if "31" $ lvidpoms
        lvidpom := 31
      endif
    elseif eq_ascan(atmpusl,"55.1.2","55.1.3")
      if eq_any(human_->PROFIL,57,68,97) //терапия,педиатр,врач общ.практики
        if "12" $ lvidpoms
          lvidpom := 12
        endif
      else
        if "13" $ lvidpoms
          lvidpom := 13
        endif
      endif
    endif
  endif
  select MOHU
  find (str(human->kod,7))
  do while mohu->kod == human->kod .and. !eof()
    mvsod += mohu->PZKOL
    aadd(a_fusl,mohu->(recno()))
    skip
  enddo
  a_otkaz := {}
  arr_nazn := {}
  if eq_any(human->ishod,101,102) // дисп-ия детей-сирот
    read_arr_DDS(human->kod)
  elseif eq_any(human->ishod,301,302) // профосмотры несовершеннолетних
    arr_usl_otkaz := {}
    read_arr_PN(human->kod)
    if valtype(arr_usl_otkaz) == "A"
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == "A" .and. len(ar) > 9 .and. valtype(ar[5]) == "C" .and. ;
                                                      valtype(ar[10]) == "C" .and. ar[10] $ "io"
          lshifr := alltrim(ar[5])
          ldate := human->N_DATA // дата
          if valtype(ar[9]) == "D"
            ldate := ar[9]
          endif
          if ar[10] == "i" // исследования
            if (i := ascan(np_arr_issled, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0
              aadd(a_otkaz,{lshifr,;
                            ar[6],; // диагноз
                            ldate,; // дата
                            correct_profil(ar[4]),; // профиль
                            ar[2],; // специальность
                            0,;     // цена
                            1})     // 1-отказ,2-невозможность
            endif                
          elseif (i := ascan(np_arr_osmotr, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0 // осмотры
            if (i := ascan(np_arr_osmotr_KDP2, {|x| x[1] == lshifr })) > 0
              lshifr := np_arr_osmotr_KDP2[i,3]  // замена врачебного приёма на 2.3.*
            endif
            aadd(a_otkaz,{lshifr,;
                          ar[6],; // диагноз
                          ldate,; // дата
                          correct_profil(ar[4]),; // профиль
                          ar[2],; // специальность
                          0,;     // цена
                          1})     // 1-отказ,2-невозможность
          endif
        endif
      next j
    endif
  elseif between(human->ishod,201,205) // дисп-ия I этап или профилактика
    arr_usl_otkaz := {}
    read_arr_DVN(human->kod)
    if valtype(arr_usl_otkaz) == "A" .and. eq_any(human->ishod,201,203) // не II этап
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == "A" .and. len(ar) >= 10 .and. valtype(ar[5]) == "C"
          lshifr := alltrim(ar[5])
          if (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]==lshifr})) > 0
            if valtype(ar[10]) == "N" .and. between(ar[10],1,2)
              aadd(a_otkaz,{lshifr,;
                            ar[6],; // диагноз
                            human->N_DATA,; // дата
                            correct_profil(ar[4]),; // профиль
                            ar[2],; // специальность
                            ar[8],; // цена
                            ar[10]}) // 1-отказ,2-невозможность
            endif
          endif
        endif
      next j
    endif
  endif
  if m1dopo_na > 0
    aadd(arr_nazn,{3,{}}) ; j := len(arr_nazn)
    for i := 1 to 3
      if isbit(m1dopo_na,i)
        aadd(arr_nazn[j,2],i)
      endif
    next
  endif
  if between(m1napr_v_mo,1,2) .and. !empty(arr_mo_spec) // {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
    aadd(arr_nazn,{m1napr_v_mo,{}}) ; j := len(arr_nazn)
    for i := 1 to min(3,len(arr_mo_spec))
      aadd(arr_nazn[j,2],arr_mo_spec[i])
    next
  endif 
  if between(m1napr_stac,1,2) .and. m1profil_stac > 0 // {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
    aadd(arr_nazn,{iif(m1napr_stac==1,5,4),m1profil_stac})
  endif 
  if m1napr_reab == 1 .and. m1profil_kojki > 0   
    aadd(arr_nazn,{6,m1profil_kojki})
  endif 
  cSMOname := ""
  if alltrim(human_->smo) == '34'
    cSMOname := ret_inogSMO_name(2)
  endif
  mdiagnoz := diag_for_xml(,.t.,,,.t.)
  if p_tip_reestr == 1
    if glob_mo[_MO_IS_UCH] .and. ;                    // наше МО имеет прикреплённое население
       human_->USL_OK == 3 .and. ;                    // поликлиника
       kart2->MO_PR == glob_MO[_MO_KOD_TFOMS] .and. ; // прикреплён к нашему МО
       between(kart_->INVALID,1,4)                    // инвалид
      select INV
      find (str(human->kod_k,7))
      if found() .and. !emptyany(inv->DATE_INV,inv->PRICH_INV)
        // дата начала лечения отстоит от даты первичного установления инвалидности не более чем на год
        fl_DISABILITY := (inv->DATE_INV < human->n_data .and. human->n_data <= addmonth(inv->DATE_INV,12))
      endif 
    endif
  else
    afill(adiag_talon,0) 
    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
    next
  endif
  mdiagnoz3 := {}
  if !empty(human_2->OSL1)
    aadd(mdiagnoz3,human_2->OSL1)
  endif
  if !empty(human_2->OSL2)
    aadd(mdiagnoz3,human_2->OSL2)
  endif
  if !empty(human_2->OSL3)
    aadd(mdiagnoz3,human_2->OSL3)
  endif
  oZAP := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZAP" ) )
   mo_add_xml_stroke(oZAP,"N_ZAP" ,lstr(rhum->REES_ZAP))
   mo_add_xml_stroke(oZAP,"PR_NOV",iif(human_->SCHET_NUM > 0, '1', '0')) // если попал в счёт 2-й раз и т.д.
   // Сведения о пациенте
   oPAC := oZAP:Add( HXMLNode():New( "PACIENT" ) )
    mo_add_xml_stroke(oPAC,"ID_PAC",human_->ID_PAC)
    mo_add_xml_stroke(oPAC,"VPOLIS",lstr(human_->VPOLIS))
    if !empty(human_->SPOLIS)
      mo_add_xml_stroke(oPAC,"SPOLIS",human_->SPOLIS)
    endif
    mo_add_xml_stroke(oPAC,"NPOLIS",human_->NPOLIS)      
    if len(alltrim(kart2->kod_mis)) == 16
      mo_add_xml_stroke(oPAC,"ENP",kart2->kod_mis) // Единый номер полиса единого образца
    endif
    //mo_add_xml_stroke(oPAC,"ST_OKATO" ,...) // Регион страхования
    if empty(cSMOname)
      mo_add_xml_stroke(oPAC,"SMO" ,human_->smo)
    endif
    mo_add_xml_stroke(oPAC,"SMO_OK",iif(empty(human_->OKATO),"18000",human_->OKATO))
    if !empty(cSMOname)
      mo_add_xml_stroke(oPAC,"SMO_NAM",cSMOname)
    endif
    if human_->NOVOR == 0
      mo_add_xml_stroke(oPAC,"NOVOR",'0')
    else
      mnovor := iif(human_->pol2=="М",'1','2')+;
                strzero(day(human_->DATE_R2),2)+;
                strzero(month(human_->DATE_R2),2)+;
                right(lstr(year(human_->DATE_R2)),2)+;
                strzero(human_->NOVOR,2)
      mo_add_xml_stroke(oPAC,"NOVOR",mnovor)
    endif
    //mo_add_xml_stroke(oPAC,"MO_PR",???)
    if human_->USL_OK == 1 .and. human_2->VNR > 0
      // стационар + л/у на недоношенного ребёнка
      mo_add_xml_stroke(oPAC,"VNOV_D",lstr(human_2->VNR))
    endif
    if fl_DISABILITY // Сведения о первичном признании застрахованного лица инвалидом
      oDISAB := oPAC:Add( HXMLNode():New( "DISABILITY" ) )
       // группа инвалидности при первичном признании застрахованного лица инвалидом
       mo_add_xml_stroke(oDISAB,"INV",lstr(kart_->invalid))
       // Дата первичного установления инвалидности
       mo_add_xml_stroke(oDISAB,"DATA_INV",date2xml(inv->DATE_INV))
       // Код причины установления  инвалидности
       mo_add_xml_stroke(oDISAB,"REASON_INV",lstr(inv->PRICH_INV))
      if !empty(inv->DIAG_INV) // Код основного заболевания по МКБ-10
       mo_add_xml_stroke(oDISAB,"DS_INV",inv->DIAG_INV)
      endif
    endif
   // Сведения о законченном случае оказания медицинской помощи
   oSLUCH := oZAP:Add( HXMLNode():New( "Z_SL" ) )
    mo_add_xml_stroke(oSLUCH,"IDCASE"  ,lstr(rhum->REES_ZAP))
    mo_add_xml_stroke(oSLUCH,"ID_C"    ,human_->ID_C)
    if p_tip_reestr == 2
      s := space(3)
      ret_tip_lu(@s)
      if !empty(s)
        mo_add_xml_stroke(oSLUCH,"DISP",s) // Тип диспансеризации
      endif
    endif
    mo_add_xml_stroke(oSLUCH,"USL_OK"  ,lstr(human_->USL_OK))
    mo_add_xml_stroke(oSLUCH,"VIDPOM"  ,lstr(lvidpom))
    if p_tip_reestr == 1
      mo_add_xml_stroke(oSLUCH,"ISHOD"   ,lstr(human_->ISHOD_NEW))
      //mo_add_xml_stroke(oSLUCH,"VB_P"  ,lstr(lvbp)) // Признак внутрибольничного перевода при оплате законченного случая как суммы стоимостей пребывания пациента в разных профильных отделениях, каждое из которых оплачивается по КСГ
      mo_add_xml_stroke(oSLUCH,"IDSP"    ,lstr(human_->IDSP))
      mo_add_xml_stroke(oSLUCH,"SUMV"    ,lstr(human->cena_1,10,2))
      do case
        case human_->USL_OK == 1 // стационар
          i := iif(left(human_->FORMA14,1)=='1', 1, 3)
        case human_->USL_OK == 4 // скорая помощь
          i := iif(left(human_->FORMA14,1)=='1', 1, 2)
        otherwise
          i := lfor_pom
      endcase
      mo_add_xml_stroke(oSLUCH,"FOR_POM",lstr(i)) // 1 - экстренная, 2 - неотложная, 3 - плановая
      if !empty(human_->NPR_MO) .and. !empty(mNPR_MO := ret_mo(human_->NPR_MO)[_MO_KOD_FFOMS])
        mo_add_xml_stroke(oSLUCH,"NPR_MO",mNPR_MO)
        s := iif(empty(human_2->NPR_DATE),human->N_DATA, human_2->NPR_DATE)
        mo_add_xml_stroke(oSLUCH,"NPR_DATE",date2xml(s))
      endif
      mo_add_xml_stroke(oSLUCH,"LPU",CODE_LPU)
    else
      mo_add_xml_stroke(oSLUCH,"FOR_POM",'3') // 3 - плановая
      mo_add_xml_stroke(oSLUCH,"LPU",CODE_LPU)
      mo_add_xml_stroke(oSLUCH,"VBR",iif(m1mobilbr==0,'0','1'))
      if eq_any(human->ishod,301,302,203)
        s := "2.1" // Медицинский осмотр
      else
        s := "2.2" // Диспансеризация
      endif
      mo_add_xml_stroke(oSL,"P_CEL",s)
      mo_add_xml_stroke(oSLUCH,"P_OTK",iif(m1p_otk==0,'0','1')) // Признак отказа
    endif
    mo_add_xml_stroke(oSLUCH,"DATE_Z_1",date2xml(human->N_DATA))
    mo_add_xml_stroke(oSLUCH,"DATE_Z_2",date2xml(human->K_DATA))
    if p_tip_reestr == 1 .and. kol_kd > 0
      mo_add_xml_stroke(oSLUCH,"KD_Z",lstr(kol_kd)) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
    endif
    if human_->USL_OK == 1 // стационар
      // вес недоношенных детей для л/у матери
      if human_2->VNR1 > 0
        mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(human_2->VNR1))
      endif
      if human_2->VNR2 > 0
        mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(human_2->VNR2))
      endif
      if human_2->VNR3 > 0
        mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(human_2->VNR3))
      endif
    endif
    mo_add_xml_stroke(oSLUCH,"RSLT",lstr(human_->RSLT_NEW))
    if p_tip_reestr == 1
      //mo_add_xml_stroke(oSLUCH,"MSE",'1')
    else
      mo_add_xml_stroke(oSLUCH,"ISHOD",lstr(human_->ISHOD_NEW))
      mo_add_xml_stroke(oSLUCH,"IDSP" ,lstr(human_->IDSP))
      mo_add_xml_stroke(oSLUCH,"SUMV" ,lstr(human->cena_1,10,2))
    endif
   for isl := 1 to 1//kol_sl
    oSL := oSLUCH:Add( HXMLNode():New( "SL" ) )
     mo_add_xml_stroke(oSL,"SL_ID",human_->ID_C)
     if (is_vmp := human_->USL_OK == 1 .and. human_2->VMP == 1 ;// ВМП
                                       .and. !emptyany(human_2->VIDVMP,human_2->METVMP))
      mo_add_xml_stroke(oSL,"VID_HMP",human_2->VIDVMP)
      mo_add_xml_stroke(oSL,"METOD_HMP",lstr(human_2->METVMP))
     endif
     otd->(dbGoto(human->OTD))
     if human_->USL_OK == 1 .and. is_otd_dep
      f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
      if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
        i := 1
      endif  
      mo_add_xml_stroke(oSL,"LPU_1",lstr(mm_otd_dep[i,3]))
      mo_add_xml_stroke(oSL,"PODR" ,lstr(glob_otd_dep))
     endif
     mo_add_xml_stroke(oSL,"PROFIL",lstr(human_->PROFIL))
     if p_tip_reestr == 1
      if human_->USL_OK < 3
        mo_add_xml_stroke(oSL,"PROFIL_K",lstr(human_2->PROFIL_K))
      endif
      mo_add_xml_stroke(oSL,"DET",iif(human->VZROS_REB==0,'0','1'))
      if human_->USL_OK == 3
        s := "2.6" 
        if (i := ascan(glob_V025, {|x| x[2] == human_->povod})) > 0
          s := glob_V025[i,3]
        endif
        mo_add_xml_stroke(oSL,"P_CEL",s)
      endif
     endif
     if is_vmp
      mo_add_xml_stroke(oSL,"TAL_D" ,date2xml(human_2->TAL_D)) // Дата выдачи талона на ВМП
      mo_add_xml_stroke(oSL,"TAL_P" ,date2xml(human_2->TAL_P)) // Дата планируемой госпитализации в соответствии с талоном на ВМП
      mo_add_xml_stroke(oSL,"TAL_NUM",human_2->TAL_NUM) // номер талона на ВМП
     endif 
     mo_add_xml_stroke(oSL,"NHISTORY",iif(empty(human->UCH_DOC),lstr(human->kod),human->UCH_DOC))
     if !is_vmp .and. eq_any(human_->USL_OK,1,2)
      mo_add_xml_stroke(oSL,"P_PER",lstr(human_2->P_PER)) // Признак поступления/перевода
     endif
     mo_add_xml_stroke(oSL,"DATE_1",date2xml(human->N_DATA))
     mo_add_xml_stroke(oSL,"DATE_2",date2xml(human->K_DATA))
     if p_tip_reestr == 1
      if kol_kd > 0
       mo_add_xml_stroke(oSL,"KD",lstr(kol_kd)) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
      endif
      if !empty(human_->kod_diag0)
       mo_add_xml_stroke(oSL,"DS0",human_->kod_diag0)
      endif
     endif
     mo_add_xml_stroke(oSL,"DS1",rtrim(mdiagnoz[1]))
     if p_tip_reestr == 2 
       s := 3 // не подлежит диспансерному наблюдению
       if adiag_talon[1] == 1 // впервые
         mo_add_xml_stroke(oSL,"DS1_PR",'1') // Признак первичного установления  диагноза 
         if adiag_talon[2] == 2
           s := 2 // взят на диспансерное наблюдение
         endif
       elseif adiag_talon[1] == 2 // ранее
         if adiag_talon[2] == 1
           s := 1 // состоит на диспансерном наблюдении
         elseif adiag_talon[2] == 2
           s := 2 // взят на диспансерное наблюдение
         endif
       endif
       mo_add_xml_stroke(oSL,"PR_D_N",lstr(s))
       if s == 2 // взят на диспансерное наблюдение
         aadd(ar_dn, {'1',rtrim(mdiagnoz[1]),"",date2xml(bom(ldate_next))})
       endif
     endif
     if p_tip_reestr == 1
      for i := 2 to len(mdiagnoz)
        if !empty(mdiagnoz[i])
          mo_add_xml_stroke(oSL,"DS2" ,rtrim(mdiagnoz[i]))
        endif
      next
      for i := 1 to len(mdiagnoz3) // ЕЩЁ ДИАГНОЗы ОСЛОЖНЕНИЯ ЗАБОЛЕВАНИЯ
        if !empty(mdiagnoz3[i])
          mo_add_xml_stroke(oSL,"DS3",rtrim(mdiagnoz3[i]))
        endif
      next
      if need_reestr_c_zab(human_->USL_OK,mdiagnoz[1])
        mo_add_xml_stroke(oSL,"C_ZAB",'1') // Характер основного заболевания
      endif
      if human_->USL_OK < 4
        i := 0
        if human->OBRASHEN == '1' .and. is_oncology < 2
          i := 1
        endif
        mo_add_xml_stroke(oSL,"DS_ONK",lstr(i))
      endif
      if human_->USL_OK == 3 .and. human_->povod == 4 // Обязательно, если P_CEL=1.3
        s := 2 // взят
        if adiag_talon[1] == 2 // ранее
          if adiag_talon[2] == 1
            s := 1 // состоит
          elseif adiag_talon[2] == 2
            s := 2 // взят
          elseif adiag_talon[2] == 3 // снят
            s := 4 // снят по причине выздоровления
          elseif adiag_talon[2] == 4
            s := 6 // снят по другим причинам
          endif
        endif
        mo_add_xml_stroke(oSL,"DN",lstr(s))
      endif
    else // диспансеризация
      for i := 2 to len(mdiagnoz)
        if !empty(mdiagnoz[i])
         oDiag := oSL:Add( HXMLNode():New( "DS2_N" ) )
          mo_add_xml_stroke(oDiag,"DS2",rtrim(mdiagnoz[i]))
          s := 3 // не подлежит диспансерному наблюдению
          if adiag_talon[i*2-1] == 1 // впервые
            mo_add_xml_stroke(oDiag,"DS2_PR",'1')
            if adiag_talon[i*2] == 2
              s := 2 // взят на диспансерное наблюдение
            endif
          elseif adiag_talon[i*2-1] == 2 // ранее
            if adiag_talon[i*2] == 1
              s := 1 // состоит на диспансерном наблюдении
            elseif adiag_talon[i*2] == 2
              s := 2 // взят на диспансерное наблюдение
            endif
          endif
          mo_add_xml_stroke(oDiag,"PR_D",lstr(s))
          if s == 2 // взят на диспансерное наблюдение
            aadd(ar_dn, {'1',rtrim(mdiagnoz[i]),"",date2xml(bom(ldate_next))})
          endif
        endif
      next
      i := iif(human->OBRASHEN == '1', 1, 0)
      mo_add_xml_stroke(oSL,"DS_ONK",lstr(i))
      if len(arr_nazn) > 0 
        oPRESCRIPTION := oSL:Add( HXMLNode():New( "PRESCRIPTION" ) )
        for j := 1 to len(arr_nazn)
         oPRESCRIPTIONS := oPRESCRIPTION:Add( HXMLNode():New( "PRESCRIPTIONS" ) )
          mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_N",lstr(j))
          mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_R",lstr(arr_nazn[j,1]))
          if eq_any(arr_nazn[j,1],1,2)
            for i := 1 to len(arr_nazn[j,2])
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SP",lstr(arr_nazn[j,2,i]))
            next
          elseif arr_nazn[j,1] == 3
            for i := 1 to len(arr_nazn[j,2])
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_V",lstr(arr_nazn[j,2,i]))
            next
            if human->OBRASHEN == '1'
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_USL",arr_nazn[j,3]) // Мед.услуга (код), указанная в направлении
            endif
          elseif eq_any(arr_nazn[j,1],4,5)
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PMP",lstr(arr_nazn[j,2]))
          elseif arr_nazn[j,1] == 6
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PK",lstr(arr_nazn[j,2]))
          endif
          if eq_any(arr_nazn[j,1],2,3) .and. human->OBRASHEN == '1'
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAPR_DATE",date2xml(arr_nazn[j,4])) // Дата направления
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAPR_MO",arr_nazn[j,5]) // Код МО, куда оформлено направление 
          endif
        next j
      endif
    endif
    if is_KSG
     oKSG := oSL:Add( HXMLNode():New( "KSG_KPG" ) )
      mo_add_xml_stroke(oKSG,"N_KSG",lshifr_zak_sl)
      if !empty(human_2->pc3) .and. !left(human_2->pc3,1) == '6' // кроме "старости"
        mo_add_xml_stroke(oKSG,"DKK1",human_2->pc3)
        //mo_add_xml_stroke(oKSG,"DKK2",human_2->pc3)
      endif
      mo_add_xml_stroke(oKSG,"SL_K",iif(empty(akslp),'0','1'))
      if !empty(akslp)
        mo_add_xml_stroke(oKSG,"IT_SL",lstr(akslp[2],7,5))
        oSLk := oKSG:Add( HXMLNode():New( "SL_KOEF" ) )
         mo_add_xml_stroke(oSLk,"ID_SL",lstr(akslp[1]))
         mo_add_xml_stroke(oSLk,"VAL_C",lstr(akslp[2],7,5))
      endif
      if !empty(akiro)
        oSLk := oKSG:Add( HXMLNode():New( "S_KIRO" ) )
         mo_add_xml_stroke(oSLk,"CODE_KIRO",lstr(akiro[1]))
         mo_add_xml_stroke(oSLk,"VAL_K",lstr(akiro[2],4,2))
      endif
    elseif is_zak_sl .or. is_zak_sl_vr
      mo_add_xml_stroke(oSL,"CODE_MES1",lshifr_zak_sl)
    endif
    if human_->USL_OK < 4 .and. is_oncology > 0
      for j := 1 to len(arr_onkna)
       oNAPR := oSL:Add( HXMLNode():New( "NAPR" ) )
        mo_add_xml_stroke(oNAPR,"NAPR_DATE",date2xml(arr_onkna[j,1]))
        if !empty(arr_onkna[j,5])
          mo_add_xml_stroke(oNAPR,"NAPR_MO",arr_onkna[j,5])
        endif
        mo_add_xml_stroke(oNAPR,"NAPR_V",lstr(arr_onkna[j,2]))
        if arr_onkna[j,2] == 3
          mo_add_xml_stroke(oNAPR,"MET_ISSL",lstr(arr_onkna[j,3]))
          mo_add_xml_stroke(oNAPR,"NAPR_USL",arr_onkna[j,4])
        endif
      next j
      oCONS := oSL:Add( HXMLNode():New( "CONS" ) ) // консилиумов м.б.несколько
       mo_add_xml_stroke(oCONS,"PR_CONS",lstr(onkco->PR_CONS)) // N019
       if !empty(onkco->DT_CONS)
         mo_add_xml_stroke(oCONS,"DT_CONS",date2xml(onkco->DT_CONS))
       endif
      if is_oncology == 2
       oONK_SL := oSL:Add( HXMLNode():New( "ONK_SL" ) )
        mo_add_xml_stroke(oONK_SL,"DS1_T",lstr(onksl->DS1_T))
        if between(onksl->DS1_T,0,4)
          mo_add_xml_stroke(oONK_SL,"STAD",lstr(onksl->STAD))
          if onksl->DS1_T == 0 .and. human->vzros_reb == 0
            mo_add_xml_stroke(oONK_SL,"ONK_T",lstr(onksl->ONK_T))
            mo_add_xml_stroke(oONK_SL,"ONK_N",lstr(onksl->ONK_N))
            mo_add_xml_stroke(oONK_SL,"ONK_M",lstr(onksl->ONK_M))
          endif
          if between(onksl->DS1_T,1,2) .and. onksl->MTSTZ == 1
            mo_add_xml_stroke(oONK_SL,"MTSTZ",lstr(onksl->MTSTZ))
          endif
        endif
        if ascan(arr_onk_usl,3) > 0 .or. ascan(arr_onk_usl,4) > 0 
          mo_add_xml_stroke(oONK_SL,"SOD",lstr(onksl->sod,6,2))
          mo_add_xml_stroke(oONK_SL,"K_FR",lstr(onksl->k_fr))
        endif
        if ascan(arr_onk_usl,2) > 0 .or. ascan(arr_onk_usl,4) > 0 
          mo_add_xml_stroke(oONK_SL,"WEI",lstr(onksl->WEI,5,1))
          mo_add_xml_stroke(oONK_SL,"HEI",lstr(onksl->HEI))
          mo_add_xml_stroke(oONK_SL,"BSA",lstr(onksl->BSA,5,2))
        endif
        for j := 1 to len(arr_onkdi)
         oDIAG := oONK_SL:Add( HXMLNode():New( "B_DIAG" ) )
          mo_add_xml_stroke(oDIAG,"DIAG_DATE",date2xml(arr_onkdi[j,1]))
          mo_add_xml_stroke(oDIAG,"DIAG_TIP", lstr(arr_onkdi[j,2]))
          mo_add_xml_stroke(oDIAG,"DIAG_CODE",lstr(arr_onkdi[j,3]))
          if arr_onkdi[j,4] > 0
            mo_add_xml_stroke(oDIAG,"DIAG_RSLT",lstr(arr_onkdi[j,4]))
            mo_add_xml_stroke(oDIAG,"REC_RSLT",'1')
          endif
        next j
        for j := 1 to len(arr_onkpr)
         oPROT := oONK_SL:Add( HXMLNode():New( "B_PROT" ) )
          mo_add_xml_stroke(oPROT,"PROT",lstr(arr_onkpr[j,1]))
          mo_add_xml_stroke(oPROT,"D_PROT",date2xml(arr_onkpr[j,2]))
        next j
        select ONKUS
        find (str(human->kod,7))
        do while onkus->kod == human->kod .and. !eof()
         if between(onkus->USL_TIP,1,6)
          oONK := oONK_SL:Add( HXMLNode():New( "ONK_USL" ) )
           mo_add_xml_stroke(oONK,"USL_TIP",lstr(onkus->USL_TIP))
           if onkus->HIR_TIP == 1
            mo_add_xml_stroke(oONK,"HIR_TIP",lstr(onkus->HIR_TIP))
           endif	
           if onkus->HIR_TIP == 2
            mo_add_xml_stroke(oONK,"LEK_TIP_L",lstr(onkus->LEK_TIP_L))	
            mo_add_xml_stroke(oONK,"LEK_TIP_V",lstr(onkus->LEK_TIP_V))
           endif	
           if eq_any(onkus->USL_TIP,3,4)
            mo_add_xml_stroke(oONK,"LUCH_TIP",lstr(onkus->LUCH_TIP))
           endif
           if eq_any(onkus->USL_TIP,2,4)
            /*цикл по БД лекарств
             oLEK := oONK:Add( HXMLNode():New( "LEK_PR" ) )
              mo_add_xml_stroke(oLEK,"REGNUM",...)
              // цикл по датам приёма данного лекарства
               mo_add_xml_stroke(oLEK,"DATE_INJ",...)*/
            if onkus->PPTR > 0   
             mo_add_xml_stroke(oONK,"PPTR",'1')
            endif
           endif 
         endif
         select ONKUS
         skip 	
        enddo
      endif
    endif
    sCOMENTSL := ""
    if p_tip_reestr == 1
      mo_add_xml_stroke(oSL,"PRVS",put_prvs_to_reestr(human_->PRVS,_NYEAR))
      if glob_mo[_MO_KOD_TFOMS] == kod_LIS .and. eq_any(human_->profil,6,34)
        mo_add_xml_stroke(oSL,"IDDOKT","0")
      else
        p2->(dbGoto(human_->vrach))
        mo_add_xml_stroke(oSL,"IDDOKT",p2->snils)
      endif
      if is_zak_sl .or. is_zak_sl_vr
        mo_add_xml_stroke(oSL,"ED_COL",'1')
        mo_add_xml_stroke(oSL,"TARIF" ,lstr(tarif_zak_sl,10,2))
      endif
      mo_add_xml_stroke(oSL,"SUM_M",lstr(human->cena_1,10,2))
      if !empty(ldate_next)
        mo_add_xml_stroke(oSL,"NEXT_VISIT",date2xml(bom(ldate_next)))
      endif
      //
      j := 0
      if (ibrm := f_oms_beremenn(mdiagnoz[1])) == 1 .and. eq_any(human_->profil,136,137) // акушерству и гинекологии
        j := iif(human_2->pn2 == 1, 4, 3)
      elseif ibrm == 2 .and. human_->USL_OK == 3 // поликлиника
        j := iif(human_2->pn2 == 1, 5, 6)
        if j == 5 .and. !eq_any(human_->profil,136,137)
          j := 6  // т.е. только акушер-гинеколог может поставить на учёт по беременности
        endif
      endif 
      if j > 0
        sCOMENTSL += lstr(j)
      endif
      sCOMENTSL += ":;" // пока так (потом добавим дисп.наблюдение)
    else
      if is_zak_sl .or. is_zak_sl_vr
        mo_add_xml_stroke(oSL,"ED_COL",'1')
      endif
      mo_add_xml_stroke(oSL,"PRVS",put_prvs_to_reestr(human_->PRVS,_NYEAR))
      if is_zak_sl .or. is_zak_sl_vr
        mo_add_xml_stroke(oSL,"TARIF" ,lstr(tarif_zak_sl,10,2))
      endif
      mo_add_xml_stroke(oSL,"SUM_M",lstr(human->cena_1,10,2))
      //
      if between(human->ishod,201,205) // ДВН
        j := iif(human->RAB_NERAB==0,20,iif(human->RAB_NERAB==1,10,14))
        if human->ishod != 203 .and. m1veteran == 1
          j := iif(human->RAB_NERAB==0, 21, 11)
        endif
        sCOMENTSL := lstr(j)+":;"  // пока так (потом добавим постановку на дисп.учёт)
      //elseif between(human->ishod,301,302)  
        //j := iif(between(m1mesto_prov,0,1), m1mesto_prov, 0)
        //fl := .t.
      endif
    endif
    if !empty(sCOMENTSL)
      mo_add_xml_stroke(oSL,"COMENTSL",sCOMENTSL)
    endif 
    if !is_zak_sl
      for j := 1 to len(a_usl)
        select HU
        goto (a_usl[j])
        hu_->(G_RLock(forever))
        hu_->REES_ZAP := ++iusl
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
        oUSL := oSL:Add( HXMLNode():New( "USL" ) )
        mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(hu_->REES_ZAP))
        mo_add_xml_stroke(oUSL,"ID_U"    ,hu_->ID_U)
        if hu->is_edit == 1 // гематологические исследования
          mo_add_xml_stroke(oUSL,"LPU"   ,'125901') // т.е. иссл-ие проводится в КДП №2
        elseif lshifr == "4.20.2" // жидкостная цитология
          mo_add_xml_stroke(oUSL,"LPU"   ,'103001') // т.е. иссл-ие проводится в онкологии
        else
          mo_add_xml_stroke(oUSL,"LPU"   ,CODE_LPU)
        endif
        if p_tip_reestr == 1 
          if human_->USL_OK == 1 .and. is_otd_dep
            otd->(dbGoto(hu->OTD))
            f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
            if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
              i := 1
            endif  
            mo_add_xml_stroke(oUSL,"LPU_1",lstr(mm_otd_dep[i,3]))
            mo_add_xml_stroke(oUSL,"PODR" ,lstr(glob_otd_dep))
          elseif hu->KOL_RCP < 0 .and. DomUslugaTFOMS(lshifr)
            mo_add_xml_stroke(oUSL,"PODR",'0')
          endif
        endif
        mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(hu_->PROFIL))
        if p_tip_reestr == 1
          mo_add_xml_stroke(oUSL,"DET"   ,iif(human->VZROS_REB==0,'0','1'))
        endif
        mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(c4tod(hu->DATE_U)))
        mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(c4tod(hu_->DATE_U2)))
        if p_tip_reestr == 1
          mo_add_xml_stroke(oUSL,"DS"    ,hu_->kod_diag)
        else
          mo_add_xml_stroke(oUSL,"P_OTK" ,'0')
        endif
        mo_add_xml_stroke(oUSL,"CODE_USL",lshifr)
        mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(hu->KOL_1,6,2))
        mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(hu->U_CENA,10,2))
        mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(hu->STOIM_1,10,2))
        mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(hu_->PRVS,_NYEAR))
        if c4tod(hu->DATE_U) < human->n_data ; // если сделано ранее
                       .or. eq_any(hu->is_edit,-1,1) .or. lshifr == "4.20.2" // не заполняется код врача
          mo_add_xml_stroke(oUSL,"CODE_MD",'0')
        else
          p2->(dbGoto(hu->kod_vr))
          mo_add_xml_stroke(oUSL,"CODE_MD" ,p2->snils)
        endif
      next
    endif
    if p_tip_reestr == 2 .and. len(a_otkaz) > 0 // отказы (диспансеризация или профосмоты несовешеннолетних)
      for j := 1 to len(a_otkaz)
        oUSL := oSL:Add( HXMLNode():New( "USL" ) )
        mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(++iusl))
        mo_add_xml_stroke(oUSL,"ID_U"    ,mo_guid(3,iusl))
        mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
        mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(a_otkaz[j,4]))
        mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(a_otkaz[j,3]))
        mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(a_otkaz[j,3]))
        mo_add_xml_stroke(oUSL,"P_OTK"   ,lstr(a_otkaz[j,7]))
        mo_add_xml_stroke(oUSL,"CODE_USL",a_otkaz[j,1])
        mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(1,6,2))
        mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(a_otkaz[j,6],10,2))
        mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(a_otkaz[j,6],10,2))
        mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(a_otkaz[j,5],_NYEAR))
        mo_add_xml_stroke(oUSL,"CODE_MD" ,'0') // отказ => 0
      next
    endif
    if p_tip_reestr == 1 .and. len(a_fusl) > 0 // добавляем операции
      for j := 1 to len(a_fusl)
        select MOHU
        goto (a_fusl[j])
        mohu->(G_RLock(forever))
        mohu->REES_ZAP := ++iusl
        lshifr := alltrim(mosu->shifr1)
        oUSL := oSL:Add( HXMLNode():New( "USL" ) )
        mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(mohu->REES_ZAP))
        mo_add_xml_stroke(oUSL,"ID_U"    ,mohu->ID_U)
        mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
        if human_->USL_OK == 1 .and. is_otd_dep
          otd->(dbGoto(hu->OTD))
          f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
          if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
            i := 1
          endif  
          mo_add_xml_stroke(oUSL,"LPU_1",lstr(mm_otd_dep[i,3]))
          mo_add_xml_stroke(oUSL,"PODR" ,lstr(glob_otd_dep))
        endif
        mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(mohu->PROFIL))
        mo_add_xml_stroke(oUSL,"VID_VME",lshifr)
        mo_add_xml_stroke(oUSL,"DET"     ,iif(human->VZROS_REB==0,'0','1'))
        mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(c4tod(mohu->DATE_U)))
        mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(c4tod(mohu->DATE_U2)))
        mo_add_xml_stroke(oUSL,"DS"      ,mohu->kod_diag)
        mo_add_xml_stroke(oUSL,"CODE_USL",lshifr)
        mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(mohu->KOL_1,6,2))
        mo_add_xml_stroke(oUSL,"TARIF"   ,'0')//lstr(mohu->U_CENA,10,2))
        mo_add_xml_stroke(oUSL,"SUMV_USL",'0')//lstr(mohu->STOIM_1,10,2))
        mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(mohu->PRVS,_NYEAR))
        if is_telemedicina(lshifr) // не заполняется код врача
          mo_add_xml_stroke(oUSL,"CODE_MD",'0')
        else        
          p2->(dbGoto(mohu->kod_vr))
          mo_add_xml_stroke(oUSL,"CODE_MD" ,p2->snils)
        endif
        if STisZF(human_->USL_OK,human_->PROFIL)
          dbSelectArea(laluslf)
          find (padr(lshifr,20)) 
          if &laluslf.->zf == 1  // обязателен ввод зубной формулы
            mo_add_xml_stroke(oUSL,"COMENTU",arr2list(STretArrZF(mohu->zf))) // формула зуба
          endif
        endif
      next j
    endif
   next isl  
  select RHUM
  if rhum->REES_ZAP % 2000 == 0
    dbUnlockAll()
    dbCommitAll()
  endif
  skip
enddo
dbUnlockAll()
dbCommitAll()
stat_msg("Запись XML-файла реестра случаев")
oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
name_zip := alltrim(mo_xml->FNAME)+szip
aadd(arr_zip, alltrim(mo_xml->FNAME)+sxml)
//
stat_msg("Составление реестра пациентов")
oXmlDoc := HXMLDoc():New()
oXmlDoc:Add( HXMLNode():New( "PERS_LIST") )
 oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
  mo_add_xml_stroke(oXmlNode,"VERSION" ,'3.11')
  mo_add_xml_stroke(oXmlNode,"DATA"     ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"FILENAME" ,mo_xml->FNAME2)
  mo_add_xml_stroke(oXmlNode,"FILENAME1",mo_xml->FNAME)
select RHUM
go top
do while !eof()
  @ maxrow(),0 say str(rhum->REES_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
  arr_fio := retFamImOt(2,.f.)
  oPAC := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERS" ) )
  mo_add_xml_stroke(oPAC,"ID_PAC" ,human_->ID_PAC)
  if human_->NOVOR == 0
    mo_add_xml_stroke(oPAC,"FAM"  ,arr_fio[1])
    if !empty(arr_fio[2])
      mo_add_xml_stroke(oPAC,"IM"   ,arr_fio[2])
    endif
    if !empty(arr_fio[3])
      mo_add_xml_stroke(oPAC,"OT" ,arr_fio[3])
    endif
    mo_add_xml_stroke(oPAC,"W"    ,iif(human->pol=="М",'1','2'))
    mo_add_xml_stroke(oPAC,"DR"   ,date2xml(human->date_r))
    if empty(arr_fio[3])
      mo_add_xml_stroke(oPAC,"DOST",'1') // отсутствует отчество
    endif
    if empty(arr_fio[2])
      mo_add_xml_stroke(oPAC,"DOST",'3') // отсутствует имя
    endif
    if p_tip_reestr == 2 // Указывается только для диспансеризации при предоставлении сведений
      if     len(alltrim(kart_->PHONE_H)) == 11
        mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_H,2))
      elseif len(alltrim(kart_->PHONE_M)) == 11
        mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_M,2))
      elseif len(alltrim(kart_->PHONE_W)) == 11
        mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_W,2))
      endif
    endif 
  else
    mo_add_xml_stroke(oPAC,"W"    ,iif(human_->pol2=="М",'1','2'))
    mo_add_xml_stroke(oPAC,"DR"   ,date2xml(human_->date_r2))
    mo_add_xml_stroke(oPAC,"FAM_P",arr_fio[1])
    if !empty(arr_fio[2])
      mo_add_xml_stroke(oPAC,"IM_P" ,arr_fio[2])
    endif
    if !empty(arr_fio[3])
      mo_add_xml_stroke(oPAC,"OT_P",arr_fio[3])
    endif
    mo_add_xml_stroke(oPAC,"W_P"  ,iif(human->pol=="М",'1','2'))
    mo_add_xml_stroke(oPAC,"DR_P" ,date2xml(human->date_r))
    if empty(arr_fio[3])
      mo_add_xml_stroke(oPAC,"DOST_P",'1') // отсутствует отчество
    endif
    if !empty(arr_fio[2])
      mo_add_xml_stroke(oPAC,"DOST_P",'3') // отсутствует имя
    endif
  endif
  if !empty(smr := del_spec_symbol(kart_->mesto_r))
    mo_add_xml_stroke(oPAC,"MR",smr)
  endif
  if human_->vpolis == 3 .and. emptyany(kart_->nom_ud,kart_->nom_ud)
    // для нового полиса паспорт необязателен
  else
    mo_add_xml_stroke(oPAC,"DOCTYPE",lstr(kart_->vid_ud))
    if !empty(kart_->ser_ud)
      mo_add_xml_stroke(oPAC,"DOCSER",kart_->ser_ud)
    endif
    mo_add_xml_stroke(oPAC,"DOCNUM",kart_->nom_ud)
  endif
  if !empty(kart->snils)
    mo_add_xml_stroke(oPAC,"SNILS",transform(kart->SNILS,picture_pf))
  endif
  if human_->vpolis == 3 .and. empty(kart_->okatog)
    // для нового полиса место регистрации необязательно
  else
    mo_add_xml_stroke(oPAC,"OKATOG" ,kart_->okatog)
  endif
  if len(alltrim(kart_->okatop)) == 11
    mo_add_xml_stroke(oPAC,"OKATOP",kart_->okatop)
  endif
  select RHUM
  skip
enddo
stat_msg("Запись XML-файла реестра пациентов")
oXmlDoc:Save(alltrim(mo_xml->FNAME2)+sxml)
aadd(arr_zip, alltrim(mo_xml->FNAME2)+sxml)
//
close databases
if chip_create_zipXML(name_zip,arr_zip,.t.)
  keyboard chr(K_TAB)+chr(K_ENTER)
endif
return NIL

***** 28.08.18 создать счета по результатам прочитанного реестра СП
Function create_schet19_from_XML(arr_XML_info,aerr,fl_msg,arr_s,name_sp_tk)
Local arr_schet := {}, c, len_stand, _arr_stand, lshifr, i, j, k, lbukva,;
      doplataF, doplataR, mnn, fl, name_zip, arr_zip := {}, lshifr1,;
      CODE_LPU := glob_mo[_MO_KOD_TFOMS], code_schet, mb, me, nsh,;
      CODE_MO  := glob_mo[_MO_KOD_FFOMS], s1
DEFAULT fl_msg TO .t., arr_s TO {}
Private pole
//
use (cur_dir+"tmp1file") new alias TMP1
mdate_schet := tmp1->_DSCHET
nsh := f_mb_me_nsh(tmp1->_year,@mb,@me)
// составляем массив будущих счетов
// открыть распакованный реестр
use (cur_dir+"tmp_r_t1") new index (cur_dir+"tmpt1") alias T1
use (cur_dir+"tmp_r_t2") new index (cur_dir+"tmpt2") alias T2
use (cur_dir+"tmp_r_t3") new index (cur_dir+"tmpt3") alias T3
use (cur_dir+"tmp_r_t4") new index (cur_dir+"tmpt4") alias T4
use (cur_dir+"tmp_r_t5") new index (cur_dir+"tmpt5") alias T5
use (cur_dir+"tmp_r_t6") new index (cur_dir+"tmpt6") alias T6
use (cur_dir+"tmp_r_t7") new index (cur_dir+"tmpt7") alias T7
use (cur_dir+"tmp_r_t8") new index (cur_dir+"tmpt8") alias T8
R_Use(dir_server+"mo_pers",,"PERS")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
G_Use(dir_server+"human_u_",,"HU_")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"mo_su",,"MOSU")
G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
G_Use(dir_server+"mo_xml",,"MO_XML")
use_base("human")
set order to 0
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
use (cur_dir+"tmp2file") new alias TMP2
set relation to kod_human into HUMAN
index on upper(human->fio) to (cur_dir+"tmp2") for _OPLATA == 1
go top
do while !eof()
  c := " "
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    lbukva := " "
    if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,@lbukva)
      lshifr1 := iif(empty(lshifr1), usl->shifr, lshifr1)
      if hu->STOIM_1 > 0 .or. left(lshifr1,3) == "71."  // скорая помощь
        if !empty(lbukva)
          c := lbukva
          exit
        endif
      endif
    endif
    select HU
    skip
  enddo
  if type("pr_array_schet") == "A" .and. empty(c)
    c := "A"   // искусственно для экспорта из чужих БД случаев с отсутствующими услугами
  endif
  if empty(c)
    s := alltrim(human->fio)+" - не найдена буква счёта"
    aadd(aerr,s)
    close databases
    return func_error(4,s)
  else
    tmp2->SCHET_CHAR := c
  endif
  if (i := ascan(arr_schet, {|x| x[1]==tmp2->_SMO .and. x[2]==tmp2->SCHET_CHAR})) == 0
    aadd(arr_schet, {tmp2->_SMO,tmp2->SCHET_CHAR,0,0,0,0,0,0,0,0})
    i := len(arr_schet)
  endif
  arr_schet[i,3] ++
  arr_schet[i,4] += human->cena_1
  arr_schet[i,8] := 0 // сюда запишем код счёта
  arr_schet[i,9] := 0 // сюда запишем номер пакета
  arr_schet[i,10] := 0 // сюда запишем индекс массива pr_array_schet
  tmp2->SCHET_ZAP := arr_schet[i,3]
  tmp2->SCHET := i
  //
  select TMP2
  skip
enddo
if type("pr_array_schet") == "A"
  for ii := 1 to len(arr_schet)
    fl := .f.
    mn_schet := alltrim(arr_schet[ii,1])+"-"+alltrim(tmp1->_NSCHET)+arr_schet[ii,2]
    if (i := ascan(pr_array_schet, {|x| alltrim(x[3])==mn_schet .and. x[6]==tmp1->_year})) > 0
      arr_schet[ii,9] := pr_array_schet[i,2] // сюда запишем номер пакета
      arr_schet[ii,10] := i
    endif
    if arr_schet[ii,10] == 0
      my_debug(,lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" не найден счёт "+mn_schet)
    else
      i := arr_schet[ii,10]
      s := lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" "+padr(mn_schet,15)
      s += "max: "+lstr(pr_array_schet[i,8])
      if pr_array_schet[i,8] == arr_schet[ii,3]
        s += " = "
        s1 := "+"
      else
        s += " != "
        s1 := "-"
        fl := .t.
      endif
      s += lstr(arr_schet[ii,3])+", кол: "+lstr(pr_array_schet[i,7])
      if pr_array_schet[i,7] == arr_schet[ii,3]
        s += " = "
        s1 += "+"
      else
        s += " != "
        s1 += "-"
        fl := .t.
      endif
      s += lstr(arr_schet[ii,3])+", сум: "+lstr(pr_array_schet[i,5],13,2)
      if round(pr_array_schet[i,5],2) == round(arr_schet[ii,4],2)
        s += " = "
        s1 += "+"
      else
        s += " != "
        s1 += "-"
        fl := .t.
      endif
      s += lstr(arr_schet[ii,4],13,2)
      my_debug(,s1+s)
    endif
    if arr_schet[ii,10] > 0 // счёт найден в "pr_array_schet"
      i := arr_schet[ii,10]
      arr_schet[ii,3] := arr_schet[ii,4] := 0
      select TMP2
      index on upper(_ID_C) to (cur_dir+"tmp2") for schet == ii
      dbeval({|| tmp2->SCHET_ZAP := 0 }) // обнуляем номер позиции в счёте
      use (cur_dir+"tmp_s_id") new alias TS
      index on NIDCASE to (cur_dir+"tmp_ts") for kod == pr_array_schet[i,11]
      go top
      do while !eof()
        select TMP2
        find (upper(ts->ID_C))
        if found()
          tmp2->SCHET_ZAP := ts->NIDCASE
          human->(dbGoto(tmp2->kod_human))
          arr_schet[ii,3] ++
          arr_schet[ii,4] += human->cena_1
        else
          my_debug(,"в счёте не найден пациент с GUID "+ts->ID_C)
          my_debug(,"└─>"+print_array(pr_array_schet[i]))
        endif
        select TS
        skip
      enddo
      ts->(dbCloseArea())
      if fl .or. !(pr_array_schet[i,8] == arr_schet[ii,3] .and. ;
                   pr_array_schet[i,7] == arr_schet[ii,3] .and. ;
                   round(pr_array_schet[i,5],2) == round(arr_schet[ii,4],2))
        if fl
          my_debug(,"после исправления:")
        else
          my_debug(,"что-то случилось:")
        endif
        s := lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" "+padr(mn_schet,15)
        s += "max: "+lstr(pr_array_schet[i,8])
        if pr_array_schet[i,8] == arr_schet[ii,3]
          s += " = "
          s1 := "+"
        else
          s += " != "
          s1 := "-"
        endif
        s += lstr(arr_schet[ii,3])+", кол: "+lstr(pr_array_schet[i,7])
        if pr_array_schet[i,7] == arr_schet[ii,3]
          s += " = "
          s1 += "+"
        else
          s += " != "
          s1 += "-"
        endif
        s += lstr(arr_schet[ii,3])+", сум: "+lstr(pr_array_schet[i,5],13,2)
        if round(pr_array_schet[i,5],2) == round(arr_schet[ii,4],2)
          s += " = "
          s1 += "+"
        else
          s += " != "
          s1 += "-"
        endif
        s += lstr(arr_schet[ii,4],13,2)
        my_debug(,s1+s)
      endif
    endif
  next
endif
R_Use(dir_server+"schet_",,"SCH")
index on smo+str(nn,nsh) to (cur_dir+"tmp_sch") for nyear == tmp1->_YEAR .and. nmonth == tmp1->_MONTH
fl := .f.
for i := 1 to len(arr_schet)
  fl := .f. ; sKodSMO := arr_schet[i,1]
  if arr_schet[i,9] > 0
    find (sKodSMO+str(arr_schet[i,9],nsh))
    if found() // номер уже занят
      arr_schet[i,9] := 0
    endif
  endif
  fl := (arr_schet[i,9] > 0)
  if !fl
    for mnn := mb to me
      if ascan(arr_schet, {|x| x[1] == sKodSMO .and. x[9] == mnn}) == 0
        find (sKodSMO+str(mnn,nsh))
        if !found() // нашли свободный номер
          fl := .t. ; arr_schet[i,9] := mnn ; exit
        endif
      endif
    next
  endif
  if !fl ; exit ; endif
next
if !fl
  close databases
  s := "Не удалось найти свободный номер пакета в ТФОМС. Проверьте настройки!"
  aadd(aerr,s)
  return func_error(4,s)
endif
sch->(dbCloseArea())
use_base("schet")
set relation to
// определим дату счёта, чтобы она не была раньше даты чтения реестра в ТФОМС
mdate_schet := max(mdate_schet,sys_date)
strfile(space(10)+"Список составленных счетов:"+hb_eol(),cFileProtokol,.t.)
select TMP2
index on str(schet,6)+str(schet_zap,6) to (cur_dir+"tmp2") for schet_zap > 0
for ii := 1 to len(arr_schet)
  mnn := arr_schet[ii,9]
  sKodSMO := alltrim(arr_schet[ii,1])
  s := "M"+CODE_LPU+iif(sKodSMO=='34',"T","S")+sKodSMO+"_"+;
       right(strzero(tmp1->_YEAR,4),2)+strzero(tmp1->_MONTH,2)+;
       strzero(mnn,nsh)
  mn_schet := sKodSMO+"-"+alltrim(tmp1->_NSCHET)+arr_schet[ii,2]
  stat_msg("Составление реестра случаев по счёту № "+mn_schet)
  //
  c := upper(left(name_sp_tk,1)) // {"H","F"}[p_tip_reestr]+s
  p_tip_reestr := iif(c == "H", 1, 2)
  select SCHET
  AddRec(6)
  arr_schet[ii,8] := mkod := recno()
  schet->KOD := mkod
  schet->NOMER_S := mn_schet
  aadd(arr_s,mn_schet)
  schet->PDATE := dtoc4(mdate_schet)
  schet->KOL   := arr_schet[ii,3]
  schet->SUMMA := arr_schet[ii,4]
  schet->KOL_OST   := arr_schet[ii,3]
  schet->SUMMA_OST := arr_schet[ii,4]
  //
  select SCHET_
  do while schet_->(lastrec()) < mkod
    APPEND BLANK
  enddo
  goto (mkod)
  G_RLock(forever)
  schet_->IFIN       := 1 // источник финансирования;1-ТФОМС(СМО)
  schet_->IS_MODERN  := 0 // является модернизацией, 0-нет
  schet_->IS_DOPLATA := 0 // является доплатой;0-нет
  schet_->BUKVA      := arr_schet[ii,2]
  schet_->NSCHET     := mn_schet
  schet_->DSCHET     := mdate_schet
  schet_->SMO        := sKodSMO
  schet_->NYEAR      := tmp1->_YEAR
  schet_->NMONTH     := tmp1->_MONTH
  schet_->NN         := mnn
  schet_->NAME_XML   := c+s // {"H","F"}[p_tip_reestr]+s
  schet_->XML_REESTR := mXML_REESTR
  schet_->NREGISTR   := 1 // ещё не зарегистрирован
  schet_->CODE := ret_unique_code(mkod,12)
  code_schet := schet_->code
  //
  select MO_XML
  AddRecN()
  mo_xml->KOD    := recno()
  mo_xml->FNAME  := c+s
  mo_xml->FNAME2 := "L"+s
  mo_xml->DFILE  := schet_->DSCHET
  mo_xml->TFILE  := hour_min(seconds())
  mo_xml->TIP_OUT := _XML_FILE_SCHET  // тип высылаемого файла;2-счет
  mo_xml->SCHET   := mkod  // код счета (отсылаемого или обработанного СМО)
  //
  schet_->KOD_XML := mo_xml->KOD
  UnLock
  //
  strfile(lstr(ii)+". "+mn_schet+" от "+date_8(mdate_schet)+" ("+;
          lstr(arr_schet[ii,3])+" чел.) "+;
          inieditspr(A__MENUVERT,glob_arr_smo,int(val(sKodSMO)))+;
          hb_eol(),cFileProtokol,.t.)
  //
  oXmlDoc := HXMLDoc():New()
  oXmlDoc:Add( HXMLNode():New( "ZL_LIST") )
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
    if tmp1->_YEAR > 2018 .or. (tmp1->_YEAR == 2018 .and. tmp1->_MONTH >= 9) // с сентября 2018 года
      s := '3.1'
    else
      s := '2.12'
      if c == "H"
        if tmp1->_YEAR > 2017
          s := '2.13'
          if tmp1->_YEAR == 2018 .and. tmp1->_MONTH >= 5 // с мая 2018 года
            s := '2.14'
          endif
        endif
      endif
    endif
    mo_add_xml_stroke(oXmlNode,"VERSION" ,s)
    mo_add_xml_stroke(oXmlNode,"DATA"    ,date2xml(schet_->DSCHET))
    mo_add_xml_stroke(oXmlNode,"FILENAME",mo_xml->FNAME)
    mo_add_xml_stroke(oXmlNode,"SD_Z"    ,lstr(arr_schet[ii,3])) // новое поле
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "SCHET" ) )
    mo_add_xml_stroke(oXmlNode,"CODE"   ,lstr(code_schet))
    mo_add_xml_stroke(oXmlNode,"CODE_MO",CODE_MO)
    mo_add_xml_stroke(oXmlNode,"YEAR"   ,lstr(tmp1->_YEAR ))
    mo_add_xml_stroke(oXmlNode,"MONTH"  ,lstr(tmp1->_MONTH))
    mo_add_xml_stroke(oXmlNode,"NSCHET" ,mn_schet)
    mo_add_xml_stroke(oXmlNode,"DSCHET" ,date2xml(schet_->DSCHET))
    mo_add_xml_stroke(oXmlNode,"PLAT"   ,schet_->SMO)
    mo_add_xml_stroke(oXmlNode,"SUMMAV" ,str(schet->SUMMA,15,2))
  // запись номера счета по больным
  iidserv := 0
  select TMP2
  find (str(ii,6))
  do while tmp2->schet==ii .and. !eof()
    @ maxrow(),0 say str(tmp2->schet_zap/arr_schet[ii,3]*100,6,2)+"%" color cColorSt2Msg
    human->(G_RLock(forever))
    human->schet := mkod ; human->tip_h := B_SCHET
    human_->(G_RLock(forever))
    human_->schet_zap := tmp2->schet_zap
    if human_->SCHET_NUM < 99
      human_->SCHET_NUM := human_->SCHET_NUM+1
    endif
    UnLock
    //
    select T1
    find (str(tmp2->_N_ZAP,6))
    if found() // нашли в отосланном реестре
      a_usl := {}
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        if is_usluga_TFOMS(usl->shifr,opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data),human->k_data)
          aadd(a_usl,{hu->(recno()),hu_->REES_ZAP})
        endif
        select HU
        skip
      enddo
      a_fusl := {}
      select MOHU
      find (str(human->kod,7))
      do while mohu->kod == human->kod .and. !eof()
        aadd(a_fusl,{mohu->(recno()),mohu->REES_ZAP})
        skip
      enddo
      oZAP := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZAP" ) )
       mo_add_xml_stroke(oZAP,"N_ZAP" ,lstr(human_->schet_zap))
       mo_add_xml_stroke(oZAP,"PR_NOV",t1->PR_NOV) // по версии 2.12
       oPAC := oZAP:Add( HXMLNode():New( "PACIENT" ) )
        mo_add_xml_stroke(oPAC,"ID_PAC",t1->ID_PAC)
        mo_add_xml_stroke(oPAC,"VPOLIS",t1->VPOLIS)
        if !empty(t1->SPOLIS)
          mo_add_xml_stroke(oPAC,"SPOLIS",t1->SPOLIS)
        endif
        mo_add_xml_stroke(oPAC,"NPOLIS",t1->NPOLIS)
        if !empty(t1->ENP)
          mo_add_xml_stroke(oPAC,"ENP",t1->ENP)
        endif
        mo_add_xml_stroke(oPAC,"SMO"   ,t1->smo)
        mo_add_xml_stroke(oPAC,"SMO_OK",t1->SMO_OK)
        mo_add_xml_stroke(oPAC,"NOVOR",t1->NOVOR)
        mo_add_xml_stroke(oPAC,"MO_PR",t1->MO_PR)
        if !empty(t1->VNOV_D)
          mo_add_xml_stroke(oPAC,"VNOV_D",t1->VNOV_D)
        endif
        if !empty(t1->INV) // Сведения о первичном признании застрахованного лица инвалидом
         oDISAB := oPAC:Add( HXMLNode():New( "DISABILITY" ) )
          mo_add_xml_stroke(oDISAB,"INV",t1->INV)
          mo_add_xml_stroke(oDISAB,"DATA_INV",t1->DATA_INV)
          mo_add_xml_stroke(oDISAB,"REASON_INV",t1->REASON_INV)
         if !empty(t1->DS_INV) 
          mo_add_xml_stroke(oDISAB,"DS_INV",t1->DS_INV)
         endif
        endif
       oSLUCH := oZAP:Add( HXMLNode():New( "SLUCH" ) )
        mo_add_xml_stroke(oSLUCH,"IDCASE",lstr(human_->schet_zap))
        mo_add_xml_stroke(oSLUCH,"ID_C"  ,t1->ID_C)
        if !empty(t1->DISP)
          mo_add_xml_stroke(oSLUCH,"DISP",t1->DISP) // Тип диспансеризации
        endif
        mo_add_xml_stroke(oSLUCH,"USL_OK",t1->USL_OK)
        mo_add_xml_stroke(oSLUCH,"VIDPOM",t1->VIDPOM)
        if !empty(t1->FOR_POM)
          mo_add_xml_stroke(oSLUCH,"FOR_POM",t1->FOR_POM)
        endif
        if !empty(t1->VID_HMP)               
          mo_add_xml_stroke(oSLUCH,"VID_HMP",t1->VID_HMP)
        endif
        if !empty(t1->METOD_HMP)
          mo_add_xml_stroke(oSLUCH,"METOD_HMP",t1->METOD_HMP)
        endif
        if !empty(t1->F_SP)
          mo_add_xml_stroke(oSLUCH,"F_SP",t1->F_SP)
        endif
        if !empty(t1->NPR_MO)
          mo_add_xml_stroke(oSLUCH,"NPR_MO",t1->NPR_MO)
        endif
        if !empty(t1->NPR_DATE)
          mo_add_xml_stroke(oSLUCH,"NPR_DATE",t1->NPR_DATE)
        endif
        if !empty(t1->EXTR)
          mo_add_xml_stroke(oSLUCH,"EXTR",t1->EXTR)
        endif
        mo_add_xml_stroke(oSLUCH,"LPU",t1->LPU)
        if !empty(t1->LPU_1)
          mo_add_xml_stroke(oSLUCH,"LPU_1",t1->LPU_1)
        endif
        if !empty(t1->PODR)
          mo_add_xml_stroke(oSLUCH,"PODR",t1->PODR)
        endif
        mo_add_xml_stroke(oSLUCH,"PROFIL",t1->PROFIL)
        if !empty(t1->PROFIL_K)
          mo_add_xml_stroke(oSLUCH,"PROFIL_K",t1->PROFIL_K)
        endif
        if !empty(t1->DET)
          mo_add_xml_stroke(oSLUCH,"DET",t1->DET)
        endif
        if !empty(t1->P_CEL)
          mo_add_xml_stroke(oSLUCH,"P_CEL",t1->P_CEL)
        endif
        if !empty(t1->VBR)
          mo_add_xml_stroke(oSLUCH,"VBR"     ,t1->VBR)
        endif
        if !empty(t1->TAL_D)
          mo_add_xml_stroke(oSLUCH,"TAL_D"   ,t1->TAL_D)
          mo_add_xml_stroke(oSLUCH,"TAL_P"   ,t1->TAL_P)
          if !empty(t1->TAL_NUM)
            mo_add_xml_stroke(oSLUCH,"TAL_NUM",t1->TAL_NUM)
          endif
        endif
        mo_add_xml_stroke(oSLUCH,"NHISTORY",t1->NHISTORY)
        if !empty(t1->P_PER)
          mo_add_xml_stroke(oSLUCH,"P_PER"   ,t1->P_PER)
        endif
        if !empty(t1->P_OTK)
          mo_add_xml_stroke(oSLUCH,"P_OTK"   ,t1->P_OTK)
        endif
        mo_add_xml_stroke(oSLUCH,"DATE_1"  ,t1->DATE_1)
        mo_add_xml_stroke(oSLUCH,"DATE_2"  ,t1->DATE_2)
        if !empty(t1->DS0)
          mo_add_xml_stroke(oSLUCH,"DS0"   ,t1->DS0)
        endif
        mo_add_xml_stroke(oSLUCH,"DS1"     ,t1->DS1)
        if !empty(t1->DS1_PR)
          mo_add_xml_stroke(oSLUCH,"DS1_PR",t1->DS1_PR)
        endif
        if p_tip_reestr == 2 .and. !empty(t1->DS_ONK)
          mo_add_xml_stroke(oSLUCH,"DS_ONK",t1->DS_ONK)
        endif
        if !empty(t1->PR_D_N)
          mo_add_xml_stroke(oSLUCH,"PR_D_N",t1->PR_D_N)
        endif
        for j := 1 to 7
          pole := "t1->DS2"+iif(j==1, "", "_"+lstr(j))
          if !empty(&pole)
            mo_add_xml_stroke(oSLUCH,"DS2",&pole)
          endif
        next
        for j := 1 to 3
          pole := "t1->DS3"+iif(j==1, "", "_"+lstr(j))
          if !empty(&pole)
            mo_add_xml_stroke(oSLUCH,"DS3",&pole)
          endif
        next
        if p_tip_reestr == 1 .and. !empty(t1->DS_ONK)
          mo_add_xml_stroke(oSLUCH,"DS_ONK",t1->DS_ONK)
        endif
        if !empty(t1->C_ZAB)
          mo_add_xml_stroke(oSLUCH,"C_ZAB",t1->C_ZAB)
        endif
        if !empty(t1->DN)
          mo_add_xml_stroke(oSLUCH,"DN",t1->DN)
        endif
        if !empty(t1->MSE)
          mo_add_xml_stroke(oSLUCH,"MSE",t1->MSE)
        endif
        for j := 1 to 3
          pole := "t1->VNOV_M"+iif(j==1, "", "_"+lstr(j))
          if !empty(&pole)
            mo_add_xml_stroke(oSLUCH,"VNOV_M",&pole)
          endif
        next
        for j1 := 1 to 4
          pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))
          if !empty(&pole)
           oD := oSLUCH:Add( HXMLNode():New( "DS2_N" ) )
            mo_add_xml_stroke(oD,"DS2",&pole)
            pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_PR"
            if !empty(&pole)
              mo_add_xml_stroke(oD,"DS2_PR",&pole)
            endif
            pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_D"
            if !empty(&pole)
              mo_add_xml_stroke(oD,"PR_D",&pole)
            endif
          endif
        next
        if !empty(t1->CODE_MES1)
          mo_add_xml_stroke(oSLUCH,"CODE_MES1",t1->CODE_MES1)
        endif
        select T6
        find (t1->IDCASE)
        do while t1->IDCASE == t6->IDCASE .and. !eof()
         oNAPR := oSLUCH:Add( HXMLNode():New( "NAPR" ) )
          mo_add_xml_stroke(oNAPR,"NAPR_DATE",t6->NAPR_DATE)
          mo_add_xml_stroke(oNAPR,"NAPR_V",t6->NAPR_V)
          if int(val(t6->NAPR_V)) == 3
            mo_add_xml_stroke(oNAPR,"MET_ISSL",t6->MET_ISSL)
            mo_add_xml_stroke(oNAPR,"NAPR_USL",t6->U_KOD)
          endif
          skip
        enddo
        if !empty(t1->DS1_T)
         oONK_SL := oSLUCH:Add( HXMLNode():New( "ONK_SL" ) )
          mo_add_xml_stroke(oONK_SL,"DS1_T",t1->DS1_T)
          if !empty(t1->PR_CONS)
           mo_add_xml_stroke(oONK_SL,"PR_CONS",t1->PR_CONS)
           mo_add_xml_stroke(oONK_SL,"DT_CONS",t1->DT_CONS)
          endif
          mo_add_xml_stroke(oONK_SL,"STAD",t1->STAD)
          mo_add_xml_stroke(oONK_SL,"ONK_T",t1->ONK_T)
          mo_add_xml_stroke(oONK_SL,"ONK_N",t1->ONK_N)
          mo_add_xml_stroke(oONK_SL,"ONK_M",t1->ONK_M)
          if !empty(t1->MTSTZ)
           mo_add_xml_stroke(oONK_SL,"MTSTZ",t1->MTSTZ)
          endif
          select T7
          find (t1->IDCASE)
          do while t1->IDCASE == t7->IDCASE .and. !eof()
           oDIAG := oONK_SL:Add( HXMLNode():New( "B_DIAG" ) )
            if !empty(t7->DIAG_DATE)
             mo_add_xml_stroke(oDIAG,"DIAG_DATE",t7->DIAG_DATE)
            else
             mo_add_xml_stroke(oDIAG,"DIAG_TIP", t7->DIAG_TIP)
             mo_add_xml_stroke(oDIAG,"DIAG_CODE",t7->DIAG_CODE)
             mo_add_xml_stroke(oDIAG,"DIAG_RSLT",t7->DIAG_RSLT)
            endif
           skip
          enddo
          select T8
          find (t1->IDCASE)
          do while t1->IDCASE == t8->IDCASE .and. !eof()
           oPROT := oONK_SL:Add( HXMLNode():New( "B_PROT" ) )
            mo_add_xml_stroke(oPROT,"PROT",t8->PROT)
            mo_add_xml_stroke(oPROT,"D_PROT",t8->D_PROT)
           skip
          enddo
          if !empty(t1->SOD)
           mo_add_xml_stroke(oONK_SL,"SOD",t1->SOD)
          endif
        endif
        mo_add_xml_stroke(oSLUCH,"RSLT",t1->RSLT)
        select T5
        find (t1->IDCASE)
        if found()
          oPRESCRIPTION := oSLUCH:Add( HXMLNode():New( "PRESCRIPTION" ) )
          do while t1->IDCASE == t5->IDCASE .and. !eof()
            oPRESCRIPTIONS := oPRESCRIPTION:Add( HXMLNode():New( "PRESCRIPTIONS" ) ) 
            if !empty(t5->NAZ_N)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_N",t5->NAZ_N)
            endif
            if !empty(t5->NAZ_R)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_R",t5->NAZ_R)
            endif 
            if !empty(t5->NAZR)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZR",t5->nazr)
            endif
            for i := 1 to 3
              pole := "t5->NAZ_SP"+lstr(i)
              if !empty(&pole)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SP",&pole)
              endif
            next
            for i := 1 to 3
              pole := "t5->NAZ_V"+lstr(i)
              if !empty(&pole)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_V",&pole)
              endif
            next
            if !empty(t5->NAZ_PMP)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PMP",t5->NAZ_PMP)
            endif
            if !empty(t5->NAZ_PK)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PK",t5->NAZ_PK)
            endif
            select T5
            skip
          enddo
        endif
        mo_add_xml_stroke(oSLUCH,"ISHOD"   ,t1->ISHOD)
        mo_add_xml_stroke(oSLUCH,"PRVS"    ,t1->PRVS)
        if !empty(t1->IDDOKT)
          mo_add_xml_stroke(oSLUCH,"IDDOKT",t1->IDDOKT)
        endif
        if !empty(t1->OS_SLUCH)
          mo_add_xml_stroke(oSLUCH,"OS_SLUCH",t1->OS_SLUCH)
        endif
        mo_add_xml_stroke(oSLUCH,"IDSP"    ,t1->IDSP)
        if !empty(t1->ED_COL)
          mo_add_xml_stroke(oSLUCH,"ED_COL",t1->ED_COL)
          mo_add_xml_stroke(oSLUCH,"TARIF" ,t1->TARIF)
        endif
        mo_add_xml_stroke(oSLUCH,"SUMV"    ,t1->SUMV)
        if !empty(t1->AD_CR)
          mo_add_xml_stroke(oSLUCH,"AD_CRITERION",t1->AD_CR)
          if !empty(t1->DKK2)
            mo_add_xml_stroke(oSLUCH,"DKK2",t1->DKK2)
          endif
        endif
        if !empty(t1->IT_SL)
          mo_add_xml_stroke(oSLUCH,"IT_SL" ,t1->IT_SL)
        endif
        if !empty(t1->CODE_KIRO)
          oSL := oSLUCH:Add( HXMLNode():New( "S_KIRO" ) )
           mo_add_xml_stroke(oSL,"CODE_KIRO",t1->CODE_KIRO)
           mo_add_xml_stroke(oSL,"VAL_K",t1->VAL_K)
        endif
        if !empty(t1->NEXT_VISIT)
          mo_add_xml_stroke(oSLUCH,"NEXT_VISIT",t1->NEXT_VISIT)
        endif 
        select T2
        find (t1->IDCASE)
        do while t1->IDCASE == t2->IDCASE .and. !eof()
          ++iidserv
          if (j := ascan(a_fusl, {|x| x[2] == int(val(t2->IDSERV))} )) > 0
            select MOHU
            goto (a_fusl[j,1])
            mohu->(G_RLock(forever))
            mohu->SCHET_ZAP := iidserv
            UnLock
          else
            if (j := ascan(a_usl, {|x| x[2] == int(val(t2->IDSERV))} )) == 0
              j := 1 // ????? такого не может быть
            endif
            if j <= len(a_usl)
              select HU
              goto (a_usl[j,1])
              hu_->(G_RLock(forever))
              hu_->SCHET_ZAP := iidserv
              UnLock
            endif
          endif
          oUSL := oSLUCH:Add( HXMLNode():New( "USL" ) )
          mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(iidserv))
          mo_add_xml_stroke(oUSL,"ID_U"    ,t2->ID_U)
          mo_add_xml_stroke(oUSL,"LPU"     ,t2->LPU)
          if !empty(t2->LPU_1)
            mo_add_xml_stroke(oUSL,"LPU_1" ,t2->LPU_1)
          endif
          if !empty(t2->PODR)
            mo_add_xml_stroke(oUSL,"PODR"  ,t2->PODR)
          endif
          mo_add_xml_stroke(oUSL,"PROFIL"  ,t2->PROFIL)
          if !empty(t2->VID_VME)
            mo_add_xml_stroke(oUSL,"VID_VME",t2->VID_VME)
          endif
          if !empty(t2->DET)
            mo_add_xml_stroke(oUSL,"DET"   ,t2->DET)
          endif
          mo_add_xml_stroke(oUSL,"DATE_IN" ,t2->DATE_IN)
          mo_add_xml_stroke(oUSL,"DATE_OUT",t2->DATE_OUT)
          if !empty(t2->DS)
            mo_add_xml_stroke(oUSL,"DS"    ,t2->DS)
          endif
          if !empty(t2->P_OTK)
            mo_add_xml_stroke(oUSL,"P_OTK" ,t2->P_OTK)
          endif
          mo_add_xml_stroke(oUSL,"CODE_USL",t2->CODE_USL)
          mo_add_xml_stroke(oUSL,"KOL_USL" ,t2->KOL_USL)
          mo_add_xml_stroke(oUSL,"TARIF"   ,t2->TARIF)
          mo_add_xml_stroke(oUSL,"SUMV_USL",t2->SUMV_USL)
          mo_add_xml_stroke(oUSL,"PRVS"    ,t2->PRVS)
          mo_add_xml_stroke(oUSL,"CODE_MD",t2->CODE_MD)
          if !empty(t2->USL_TIP)
           oONK := oUSL:Add( HXMLNode():New( "ONK_USL" ) )
            mo_add_xml_stroke(oONK,"USL_TIP",t2->USL_TIP)
            if !empty(t2->HIR_TIP)
             mo_add_xml_stroke(oONK,"HIR_TIP",t2->HIR_TIP)
            endif	
            if !empty(t2->LEK_TIP_L)	
             mo_add_xml_stroke(oONK,"LEK_TIP_L",t2->LEK_TIP_L)	
             mo_add_xml_stroke(oONK,"LEK_TIP_V",t2->LEK_TIP_V)
            endif	
            if !empty(t2->LUCH_TIP)	
             mo_add_xml_stroke(oONK,"LUCH_TIP",t2->LUCH_TIP)
            endif	
          endif
          if !empty(t2->COMENTU)
            mo_add_xml_stroke(oUSL,"COMENTU",t2->COMENTU)
          endif
          select T2
          skip
        enddo
        select T4
        find (t1->IDCASE)
        if found()
          oSL := oSLUCH:Add( HXMLNode():New( "SL_KOEFF" ) )
          do while t1->IDCASE == t4->IDCASE .and. !eof()
            oCOEFF := oSL:Add( HXMLNode():New( "COEFF" ) ) 
            mo_add_xml_stroke(oCOEFF,"CODE_SL",t4->CODE_SL)
            mo_add_xml_stroke(oCOEFF,"VAL_C"  ,t4->VAL_C)
            select T4
            skip
          enddo
        endif
        if !empty(t1->COMENTSL)
          mo_add_xml_stroke(oSLUCH,"COMENTSL",t1->COMENTSL)
        endif
    else // не нашли в отосланном реестре - почему?
      func_error(4,'В реестре не найден пациент "'+alltrim(human->fio)+'"')
    endif
    //
    select TMP2
    skip
  enddo
  Commit
  @ maxrow(),0 say " запись" color cColorSt2Msg
  oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
  name_zip := alltrim(mo_xml->FNAME)+szip
  arr_zip := {alltrim(mo_xml->FNAME)+sxml}
  //
  stat_msg("Составление реестра пациентов по счёту № "+mn_schet)
  oXmlDoc := HXMLDoc():New()
  oXmlDoc:Add( HXMLNode():New( "PERS_LIST") )
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
    mo_add_xml_stroke(oXmlNode,"VERSION" ,'2.12')
    mo_add_xml_stroke(oXmlNode,"DATA"     ,date2xml(schet_->DSCHET))
    mo_add_xml_stroke(oXmlNode,"FILENAME" ,mo_xml->FNAME2)
    mo_add_xml_stroke(oXmlNode,"FILENAME1",mo_xml->FNAME)
  select TMP2
  find (str(ii,6))
  do while tmp2->schet==ii .and. !eof()
    @ maxrow(),0 say str(tmp2->schet_zap/arr_schet[ii,3]*100,6,2)+"%" color cColorSt2Msg
    select T3
    find (upper(tmp2->_ID_PAC))
    if found() // нашли в отосланном реестре
      oPAC := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERS" ) )
      mo_add_xml_stroke(oPAC,"ID_PAC",t3->ID_PAC)
      mo_add_xml_stroke(oPAC,"FAM"   ,t3->FAM)
      mo_add_xml_stroke(oPAC,"IM"    ,t3->IM)
      if !empty(t3->OT)
        mo_add_xml_stroke(oPAC,"OT"  ,t3->OT)
      endif
      mo_add_xml_stroke(oPAC,"W"     ,t3->W)
      mo_add_xml_stroke(oPAC,"DR"    ,t3->DR)
      if !empty(t3->dost)
        mo_add_xml_stroke(oPAC,"DOST",t3->dost) // отсутствует отчество
      endif
      if !empty(t3->tel)
        mo_add_xml_stroke(oPAC,"TEL",t3->tel)
      endif
      if !empty(t3->FAM_P)
        mo_add_xml_stroke(oPAC,"FAM_P",t3->FAM_P)
        mo_add_xml_stroke(oPAC,"IM_P" ,t3->IM_P)
        if !empty(t3->OT_P)
          mo_add_xml_stroke(oPAC,"OT_P" ,t3->OT_P)
        endif
        mo_add_xml_stroke(oPAC,"W_P"  ,t3->W_P)
        mo_add_xml_stroke(oPAC,"DR_P" ,t3->DR_P)
        if !empty(t3->dost_p)
          mo_add_xml_stroke(oPAC,"DOST_P",t3->dost_p) // отсутствует отчество
        endif
      endif
      if !empty(t3->MR)
        mo_add_xml_stroke(oPAC,"MR",t3->MR)
      endif
      if !empty(t3->DOCNUM)
        mo_add_xml_stroke(oPAC,"DOCTYPE",t3->DOCTYPE)
        if !empty(t3->DOCSER)
          mo_add_xml_stroke(oPAC,"DOCSER",t3->DOCSER)
        endif
        mo_add_xml_stroke(oPAC,"DOCNUM" ,t3->DOCNUM)
      endif
      if !empty(t3->SNILS)
        mo_add_xml_stroke(oPAC,"SNILS",t3->SNILS)
      endif
      if !empty(t3->OKATOG)
        mo_add_xml_stroke(oPAC,"OKATOG",t3->OKATOG)
      endif
      if !empty(t3->OKATOP)
        mo_add_xml_stroke(oPAC,"OKATOP",t3->OKATOP)
      endif
    else // не нашли в отосланном реестре
      func_error(4,'В реестре не найден пациент "'+alltrim(tmp2->_ID_PAC)+'"')
    endif
    select TMP2
    skip
  enddo
  @ maxrow(),0 say " запись" color cColorSt2Msg
  oXmlDoc:Save(alltrim(mo_xml->FNAME2)+sxml)
  aadd(arr_zip, alltrim(mo_xml->FNAME2)+sxml)
  if chip_create_zipXML(name_zip,arr_zip,.t.)
    // может быть, сделать ещё что-нибудь после записи счёта?
  endif
next
// запишем время окончания обработки
select MO_XML
goto (mXML_REESTR)
G_RLock(forever)
mo_xml->TWORK2 := hour_min(seconds())
close databases
if fl_msg
  stat_msg("Запись счетов завершена!") ; mybell(2,OK)
endif
return .t.
