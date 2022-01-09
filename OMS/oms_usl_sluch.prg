#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"


***** 02.01.22 ввод услуг в случай (лист учёта)
Function oms_usl_sluch(mkod_human,mkod_kartotek,fl_edit)
  // mkod_human - код по БД human
  // mkod_kartotek - код по БД kartotek
  Local adbf, buf := savescreen(), i, j := 0, tmp_color := setcolor(color1), rec_ksg := 0,;
        lshifr := "", l_color, tmp_help, mtitle, d1, d2, cd1, cd2, fl_oms, fl, kol_rec, old_is_zf_stomat
  DEFAULT fl_edit TO .t.
  //
  Private fl_edit_usl := fl_edit
  Private fl_found, last_date, mvu[3,2], pr1otd, pr_amb_reab := .f.,;
          pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}, is_1_vvod,;
          kod_lech_vr := 0, is_open_u1 := .f., arr_uva := {}, arr_usl1year, u_other := {}
  private flExistImplant := .f., arrImplant

  afillall(mvu,0)
  //
  Private tmp_V002 := create_classif_FFOMS(0,"V002") // PROFIL
  //
  mywait()
  R_Use(dir_server+"usl_uva",,"OU")
  dbeval({|| aadd(arr_uva, {alltrim(ou->shifr),ou->kod_vr,ou->kod_as} ) } )
  ou->(dbCloseArea())
  use_base("lusl")
  use_base("luslc")
  use_base("luslf")
  Use_base("mo_su")
  set order to 0
  G_Use(dir_server+"uslugi",{dir_server+"uslugish",;
                             dir_server+"uslugi"},"USL")
  set order to 0
  Use_base("mo_hu")
  Use_base("human_u")
  G_Use(dir_server+"human_2",,"HUMAN_2")
  G_Use(dir_server+"human_",,"HUMAN_")
  G_Use(dir_server+"human",{dir_server+"humank",;
                            dir_server+"humankk",;
                            dir_server+"humano"},"HUMAN")
  set relation to recno() into HUMAN_, to recno() into HUMAN_2
  find (str(mkod_human,7))
  arr_usl1year := f_arr_usl1()
  glob_kartotek := human->kod_k
  d1 := human->n_data ; d2 := human->k_data
  cd1 := dtoc4(d1) ; cd2 := dtoc4(d2)
  last_date := human->n_data
  Private m1USL_OK := human_->USL_OK
  Private m1PROFIL := human_->PROFIL
  Private mdiagnoz := diag_to_array(,,,,.t.)
  if len(mdiagnoz) == 0
    mdiagnoz := {space(6)}
  endif
  Private human_kod_diag := mdiagnoz[1]
  //
  make_arr_uch_otd(human->n_data,human->LPU)
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  f_put_glob_podr(human_->USL_OK,d2) // заполнить код подразделения
  // просмотр других случаев данного больного
  select HUMAN
  set order to 2
  find (str(glob_kartotek,7))
  do while human->kod_k == glob_kartotek .and. !eof()
    fl := (mkod_human != human->kod)
    if fl .and. human->schet > 0 .and. eq_any(human_->oplata,2,9)
      fl := .f. // лист учёта снят по акту и выставлен повторно
    endif
    // если диапазон лечения частично перекрывается
    if fl .and. human->n_data <= d2 .and. d1 <= human->k_data
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        if between(hu->date_u,cd1,cd2) // услуга в том же диапазоне лечения
          aadd(u_other, {hu->u_kod,hu->date_u,hu->kol_1,hu_->profil,0})
        endif
        skip
      enddo
      select MOHU
      find (str(human->kod,7))
      do while mohu->kod == human->kod .and. !eof()
        if between(mohu->date_u,cd1,cd2) // услуга в том же диапазоне лечения
          aadd(u_other, {mohu->u_kod,mohu->date_u,mohu->kol_1,mohu->profil,1})
        endif
        skip
      enddo
    endif
    select HUMAN
    skip
  enddo
  //
  // проверим наличие имплантов
  Use_base("human_im")
  find (str(mkod_human, 7))
  if IMPL->(found())
    flExistImplant := .t.
    arrImplant := {IMPL->KOD_HUM, IMPL->DATE_UST, IMPL->RZN, ''}  //, IMPL->SER_NUM}
  else
    arrImplant := {mkod_human, stod('  /  /    '), 0, ''}
  endif
  IMPL->(dbCloseArea())

  //
  adbf := {;
    {"KOD"      ,   "N",     7,     0},; // код больного
    {"DATE_U"   ,   "C",     4,     0},; // дата оказания услуги
    {"date_u2"  ,   "C",     4,     0},; // дата окончания оказания услуги
    {"date_u1"  ,   "D",     8,     0},;
    {"date_next",   "D",     8,     0},; // дата след.визита для дисп.наблюдения
    {"shifr_u"  ,   "C",    20,     0},;
    {"shifr1"   ,   "C",    20,     0},;
    {"name_u"   ,   "C",    65,     0},;
    {"U_KOD"    ,   "N",     6,     0},; // код услуги
    {"U_CENA"   ,   "N",    10,     2},; // цена услуги
    {"dom"      ,   "N",     2,     0},; // -1 - на дому
    {"KOD_VR"   ,   "N",     4,     0},; // код врача
    {"KOD_AS"   ,   "N",     4,     0},; // код ассистента
    {"OTD"      ,   "N",     3,     0},; // код отделения
    {"KOL_1"    ,   "N",     3,     0},; // оплачиваемое количество услуг
    {"STOIM_1"  ,   "N",    10,     2},; // оплачиваемая стоимость услуги
    {"ZF"       ,   "C",    30,     0},; // зубная формула или парные органы
    {"PAR_ORG"  ,   "C",    40,     0},; // разрешённые парные органы
    {"ID_U"     ,   "C",    36,     0},; // код записи об оказанной услуге;GUID оказанной услуги;создается при добавлении записи
    {"PROFIL"   ,   "N",     3,     0},; // профиль;по справочнику V002
    {"PRVS"     ,   "N",     9,     0},; // Специальность врача;по справочнику V004;
    {"kod_diag" ,   "C",     6,     0},; // диагноз;перенести из основного диагноза
    {"n_base"   ,   "N",     1,     0},; // номер справочника услуг 0-старый,1-новый
    {"is_nul"   ,   "L",     1,     0},;
    {"is_oms"   ,   "L",     1,     0},;
    {"is_zf"    ,   "N",     1,     0},;
    {"is_edit"  ,   "N",     2,     0},;
    {"number"   ,   "N",     3,     0},;
    {"rec_hu"   ,   "N",     8,     0}}
  dbcreate(cur_dir+"tmp_usl_",adbf)
  use (cur_dir+"tmp_usl_") new alias TMP
  select HUMAN
  set order to 1
  find (str(mkod_human,7))
  select HU
  set relation to u_kod into USL additive
  find (str(mkod_human,7))
  if found()
    do while hu->kod == mkod_human .and. !eof()
      select TMP
      append blank
      tmp->KOD     := hu->kod
      tmp->DATE_U  := hu->date_u
      tmp->date_u2 := hu_->date_u2
      tmp->date_u1 := c4tod(hu->date_u)
      tmp->shifr_u := usl->shifr
      tmp->shifr1  := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
      if empty(lshifr := tmp->shifr1)
        lshifr := tmp->shifr_u
      endif
      if human_->usl_ok == 3
        if is_usluga_disp_nabl(lshifr)
          tmp->DATE_NEXT := c4tod(human->DATE_OPL)
        elseif left(lshifr,5) == "2.89."
          pr_amb_reab := .t.
        endif
      endif
      tmp->name_u  := usl->name
      tmp->U_KOD   := hu->u_kod
      tmp->U_CENA  := hu->u_cena
      tmp->KOD_VR  := hu->kod_vr
      tmp->dom     := hu->KOL_RCP
      tmp->KOD_AS  := hu->kod_as
      tmp->OTD     := hu->otd
      tmp->KOL_1   := hu->kol_1
      tmp->STOIM_1 := hu->stoim_1
      tmp->ZF      := hu_->ZF
      tmp->ID_U    := hu_->ID_U
      tmp->PROFIL  := hu_->PROFIL
      tmp->PRVS    := hu_->PRVS
      tmp->kod_diag:= hu_->kod_diag
      tmp->n_base  := 0
      tmp->is_edit := hu->is_edit
      tmp->is_nul  := usl->is_nul
      tmp->rec_hu  := hu->(recno())
      last_date := max(tmp->date_u1,last_date)
      if human_->usl_ok < 3 .and. is_ksg(lshifr) // для КСГ цену не переопределяем - сделаем попозже
        rec_ksg := tmp->(recno())
      else
        fl_oms := .f.
        // переопределение цены
        if (v := f1cena_oms(tmp->shifr_u,;
                            tmp->shifr1,;
                            (human->vzros_reb==0),;
                            human->k_data,;
                            tmp->is_nul,;
                            @fl_oms)) != NIL
          tmp->is_oms := fl_oms
          if !(round(tmp->u_cena,2) == round(v,2))
            tmp->u_cena := v
            tmp->stoim_1 := round_5(tmp->u_cena * tmp->kol_1, 2)
            select HU
            G_RLock(forever)
            hu->u_cena := tmp->u_cena
            hu->stoim  := hu->stoim_1 := tmp->stoim_1
            UNLOCK
          endif
        endif
      endif
      select HU
      skip
    enddo
    commit
  endif
  select MOHU
  set relation to u_kod into MOSU
  find (str(mkod_human,7))
  if found()
    do while mohu->kod == mkod_human .and. !eof()
      select TMP
      append blank
      tmp->KOD     := mohu->kod
      tmp->DATE_U  := mohu->date_u
      tmp->date_u2 := mohu->date_u2
      tmp->date_u1 := c4tod(mohu->date_u)
      tmp->shifr_u := iif(empty(mosu->shifr),mosu->shifr1,mosu->shifr)
      tmp->shifr1  := mosu->shifr1
      tmp->name_u  := mosu->name
      tmp->U_KOD   := mohu->u_kod
      tmp->U_CENA  := mohu->u_cena
      tmp->KOD_VR  := mohu->kod_vr
      tmp->KOD_AS  := mohu->kod_as
      tmp->OTD     := mohu->otd
      tmp->KOL_1   := mohu->kol_1
      tmp->STOIM_1 := mohu->stoim_1
      tmp->ZF      := mohu->ZF
      tmp->ID_U    := mohu->ID_U
      tmp->PROFIL  := mohu->PROFIL
      tmp->PRVS    := mohu->PRVS
      tmp->kod_diag:= mohu->kod_diag
      tmp->n_base  := 1
      tmp->is_nul  := .t.
      tmp->is_oms  := .t.
      tmp->is_zf   := ret_is_zf(tmp->shifr1)
      tmp->rec_hu  := mohu->(recno())
      tmp->par_org := ret_par_org(tmp->shifr1,d2)
      if is_telemedicina(tmp->shifr1)
        tmp->is_edit := -1 // не заполняется код врача
      endif
      last_date := max(tmp->date_u1,last_date)
      select MOHU
      skip
    enddo
    commit
  endif
  select TMP
  fl_found := (tmp->(lastrec()) > 0)
  is_1_vvod := (tmp->(lastrec()) == 0 .and. mem_ordu_1 == 1)
  if !is_1_vvod
    if mem_ordusl == 1
      index on dtos(date_u1)+fsort_usl(shifr_u) to (cur_dir+"tmp_usl_")
    else
      index on fsort_usl(shifr_u)+dtos(date_u1) to (cur_dir+"tmp_usl_")
    endif
  endif
  summa_usl(.f.)
  //
  old_is_zf_stomat := is_zf_stomat
  select HU
  set relation to  // "отвязываем" human_u_
  select USL
  set order to 1
  is_zf_stomat := 0
  if STisZF(m1USL_OK,m1PROFIL)
    is_zf_stomat := 1
  endif
  if is_zf_stomat == 1
    Use_base("kartdelz")
  endif
  R_Use(dir_server+"usl_otd",dir_server+"usl_otd","UO")
  R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
  select TMP
  set relation to otd into OTD
  go top
  i := tmp->(lastrec())
  if i == 0
    if mem_coplec == 2
      kod_lech_vr := human_->vrach
    endif
  elseif rec_ksg > 0
    aksg := f_usl_definition_KSG(human->kod)
    if mem_coplec == 2 .and. i == 1
      kod_lech_vr := human_->vrach
    endif
  endif
  cls
  pr_1_str("Услуги для < "+fio_plus_novor()+" >")
  if yes_num_lu == 1
    @ 1,50 say padl("Лист учета № "+lstr(human->kod),29) color color14
  endif
  l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"
  s := "Полное наименование услуги"
  if is_zf_stomat == 1
    s := "Формула зуба / "+s
  endif
  @ maxrow()-3,0 say "╒"+padc(s,66,"═")+                                                "╤══ Цена ═══╕"
  @ maxrow()-2,0 say "│                                                                  │           │"
  @ maxrow()-1,0 say "╘══════════════════════════════════════════════════════════════════╧═══════════╛"
  if fl_found
    keyboard chr(K_RIGHT)
  else
    keyboard chr(K_INS)
  endif
  setcolor(color1)
  tmp_help := chm_help_code
  chm_help_code := 3003
  mtitle := f_srok_lech(human->n_data,human->k_data,human_->usl_ok)
  Alpha_Browse(2,0,maxrow()-5,79,"f_oms_usl_sluch",color1,mtitle,col_tit_popup,;
               .f.,.t.,,"f1oms_usl_sluch","f2oms_usl_sluch",,;
               {"═","░","═",l_color,.t.,180} )
  select TMP
  pack
  kol_rec := lastrec()
  Private mcena_1 := human->cena_1, msmo := human_->smo
  if yes_parol .and. (mvu[1,1] > 0 .or. mvu[2,1] > 0 .or. mvu[3,1] > 0) ;
               .and. hb_FileExists(dir_server+"mo_opern"+sdbf)
    close databases
    if G_Use(dir_server+"mo_opern",dir_server+"mo_opern","OP")
      for i := 1 to 3
        if mvu[i,1] > 0
          write_work_oper(glob_task,OPER_USL,i,mvu[i,1],mvu[i,2],.f.)
        endif
      next
    endif
  endif
  close databases
  setcolor(tmp_color)
  if kol_rec == 0
    n_message({"Не введено ни одной услуги"},,"GR+/R","W+/R",,,"G+/R")
  endif
  restscreen(buf)
  chm_help_code := tmp_help
  // запускаем проверку
  if (mcena_1 > 0 .or. is_smp(m1USL_OK,m1PROFIL)) .and. !empty(val(msmo))
    verify_OMS_sluch(mkod_human)
  endif
  is_zf_stomat := old_is_zf_stomat
  return NIL
  