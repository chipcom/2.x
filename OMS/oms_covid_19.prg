#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

****** 05.01.22 получить из HUMAN_2 вес пациента
function get_weight_covid(kod_hum)
  local weight := 0.0
  local tmpSelect := select()

  select HUMAN_2
  goto (Loc_kod)
  weight := val(HUMAN_2->PC4)
  select(tmpSelect)

  return weight

****** 05.01.22 записать в HUMAN_2 вес пациента
function save_weight_covid(kod_hum, weight)
  local tmpSelect := select()

  if valtype(weight) == 'N'
    select HUMAN_2
    goto (Loc_kod)
    G_RLock(forever)
    HUMAN_2->PC4 := str(weight, 3, 1)
    UnLock
    select(tmpSelect)
  endif
  return weight

******* 06.01.22 проверка на необходимость ввода лекарственных препаратов
function check_oms_sluch_lek_pr(mkod_human)
  // mkod_human - код по БД human

  local vidPom, m1USL_OK, m1PROFIL, last_date, mdiagnoz, d1, d2, ad_cr
  local retFl := .f.

  G_Use(dir_server + "human_2", , "HUMAN_2")
  G_Use(dir_server + "human_", , "HUMAN_")
  G_Use(dir_server + "human", {dir_server + "humank", ;
                              dir_server + "humankk", ;
                              dir_server + "humano"}, "HUMAN")
  set relation to recno() into HUMAN_, to recno() into HUMAN_2

  find (str(mkod_human, 7))
  d1 := human->n_data
  d2 := human->k_data
  last_date := human->n_data
  m1USL_OK := human_->USL_OK
  m1PROFIL := human_->PROFIL
  mdiagnoz := diag_to_array(, , , , .t.)
  if len(mdiagnoz) == 0
    mdiagnoz := {space(6)}
  endif
  human_kod_diag := mdiagnoz[1]
  vidPom := human_->VIDPOM
  ad_cr := lower(alltrim(human_2->PC3))

  retFl := (d2 >= d_01_01_2022) .and. ((alltrim(human_kod_diag) == 'U07.1') ;
    .or. (alltrim(human_kod_diag) == 'U07.2')) .and. (M1USL_OK == 1) ;
    .and. (M1PROFIL != 158) .and. (vidPom != 32) .and. (ad_cr != 'stt5')

  HUMAN_2->(dbCloseArea())    
  HUMAN_->(dbCloseArea())    
  HUMAN->(dbCloseArea())    

  return retFl

******* 07.01.22 ввода лекарственных препаратов
function oms_sluch_lek_pr(mkod_human,mkod_kartotek,fl_edit)
  // mkod_human - код по БД human
  // mkod_kartotek - код по БД kartotek
  local aDbf, buf := savescreen(), l_color, fl_found
  local mtitle, tmp_color := setcolor(color1)
  local nBegin

  private mWeight := 0.0
  private mSeverity, m1Severity := 0

  default fl_edit to .f.

  G_Use(dir_server + "human_2", , "HUMAN_2")
  G_Use(dir_server + "human_", , "HUMAN_")
  G_Use(dir_server + "human", {dir_server + "humank", ;
                              dir_server + "humankk", ;
                              dir_server + "humano"}, "HUMAN")
  set relation to recno() into HUMAN_, to recno() into HUMAN_2

  find (str(mkod_human, 7)) // встанем на лист учета

  G_Use(dir_server + 'human_lek_pr', dir_server + 'human_lek_pr', 'LEK_PR')

  mWeight := val(HUMAN_2->PC4)  // получим вес пациента
  m1Severity := val(HUMAN_2->PC5) // получим степень тяжести
  mSeverity  := inieditspr(A__MENUVERT, get_severity(), m1Severity)
  
  // Local mo_lek_pr := {; // Сведения о введенных лекарственных препаратах
  //   {"KOD_HUM",   "N",   7, 0},; // код листа учёта по файлу "human"
  //   {"DATE_INJ",  "D",   8, 0},;  // Дата введения лекарственного препарата
  //   {"CODE_SH",   "C",  10, 0},;   // Код схемы лечения пациента/код группы препарата
  //   {"REGNUM",    "C",   6, 0},;  // Идентификатор лекарственного препарата
  //   {"ED_IZM",    "C",   3, 0},;  // Единица измерения дозы лекарственного препарата
  //   {"DOSE_INJ",  "N",   5, 2},;  // Доза введения лекарственного препарата
  //   {"METHOD_I",  "C",   3, 0},;  // Путь введения лекарственного препарата
  //   {"COL_INJ",   "N",   5, 0},;  // Количество введений в течениедня, указанного в DATA_INJ
  //   {"COD_MARK",  "C", 100, 0},;  // Код маркировки лекарственного препарата
  // }

  adbf := {;
    {"KOD_HUM" ,   "N",    7,     0},; // код листа учёта по файлу "human"
    {"DATE_INJ",   "D",    8,     0},; // Дата введения лекарственного препарата
    {"SCHEME"  ,   "C",   10,     0},; // схема лечения пациента V030
    {"SCHEMECO",   "C",    3,     0},; // сочетание схемы лечения и группы препаратов V032
    {"REGNUM"  ,   "C",    6,     0},; // лекарственного препарата
    {"ED_IZM"  ,   "C",    3,     0},; // Единица измерения дозы лекарственного препарата
    {"SHORTTIT",   "C",    5,     0},; // краткое наименование единицы измерения
    {"DOZE"    ,   "N",    5,      2},; // Доза введения лекарственного препарата
    {"METHOD"  ,   "C",    3,     0},; // Путь введения лекарственного препарата
    {"COL_INJ" ,   "N",    5,      0},; // Количество введений в течениедня, указанного в DATA_INJ
    {"COD_MARK",   "C",  100,      0},;  // Код маркировки лекарственного препарата
    {"NUMBER"  ,   "N",    3,      0},;
    {"REC_N"   ,   "N",    8,      0};
  }
  dbcreate(cur_dir + 'tmp_lek_pr', adbf)
  use (cur_dir + 'tmp_lek_pr') new alias TMP

  number := 0
  select LEK_PR
  find (str(mkod_human, 7))
  if found()
    do while LEK_PR->kod == mkod_human .and. !eof()
      number++
      select TMP
      append blank
      tmp->NUMBER   := number
      tmp->KOD_HUM  := LEK_PR->KOD_HUM
      tmp->DATE_INJ := LEK_PR->DATE_INJ
      tmp->SCHEME   := LEK_PR->CODE_SH
      tmp->SCHEMECO := LEK_PR->SCHEMECO
      tmp->REGNUM   := LEK_PR->REGNUM
      tmp->ED_IZM   := LEK_PR->ED_IZM
      tmp->SHORTTIT := left(inieditspr(A__MENUVERT, getV034(), val(LEK_PR->ED_IZM)), 5)
      tmp->DOZE     := LEK_PR->DOZE
      tmp->METHOD   := LEK_PR->METHOD_I
      tmp->COL_INJ  := LEK_PR->COL_INJ
      tmp->COD_MARK := LEK_PR->COD_MARK
      tmp->REC_N    :=  LEK_PR->(recno())
      LEK_PR->(dbSkip())
    enddo
  endif
  fl_found := (tmp->(lastrec()) > 0)

  // mishod    := inieditspr(A__MENUVERT, glob_V012, m1ishod)
  cls
  pr_1_str("Лекарственные препараты < " + fio_plus_novor() + " >")
  @ 1,50 say padl("Лист учета № " + lstr(mkod_human), 29) color color14
  l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"

  setcolor(color1)

  nBegin := 5
  if mWeight == 0.0
    @ 2, 2 say "Вес пациента" get mWeight picture '999.9' //;
      // valid {|| mprofil := padr(mprofil,69), .t. }
      @ 3,2 say "Степень тяжести состояния" get mSeverity ;
      reader {|x|menu_reader(x, get_severity(), A__MENUVERT,,,.f.)}
    myread()
  else
    @ 2, 2 say "Вес пациента:"
    @ 2, col() + 1 say mWeight picture '999.9'
    @ 3,2 say "Степень тяжести состояния:"
    @ 3, col() + 1 say mSeverity
  endif

  if fl_found
    keyboard chr(K_RIGHT)
  else
    keyboard chr(K_INS)
  endif

  mtitle := f_srok_lech(human->n_data,human->k_data,human_->usl_ok)  
  Alpha_Browse(nBegin, 0, maxrow() - 5, 79, 'f_oms_sluch_lek_pr', color1, mtitle, col_tit_popup,;
               .f., .t., , "f1oms_sluch_lek_pr", "f2oms_sluch_lek_pr", , ;
               {"═", "░", "═", l_color, .t., 180} )

  LEK_PR->(dbCloseArea())
  TMP->(dbCloseArea())

  HUMAN_2->(dbCloseArea())
  HUMAN_->(dbCloseArea())
  HUMAN->(dbCloseArea())

  setcolor(tmp_color)
  restscreen(buf)
  return nil

***** 06.01.22
Function f_oms_sluch_lek_pr(oBrow)
  Local oColumn, blk_color

  oColumn := TBColumnNew(" NN; пп",{|| tmp->number })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("Дата; инек.",{|| left(dtoc(tmp->DATE_INJ), 5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("Схема",{|| tmp->SCHEME })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("Препарат",{|| tmp->REGNUM })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("Единица",{|| tmp->SHORTTIT })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("Доза",{|| str(tmp->DOZE, 5, 2) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("Способ;введения",{|| tmp->METHOD })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew("Способ;введения",{|| str(tmp->COL_INJ, 5, 0) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  
  // if mem_ordusl == 2
  //   oColumn := TBColumnNew("Дата; усл.",{|| left(dtoc(tmp->date_u1),5) })
  //   oColumn:colorBlock := blk_color
  //   oBrow:addColumn(oColumn)
  // endif
  // oColumn := TBColumnNew("Отде-;ление",{|| otd->short_name })
  // oColumn:defColor := {6,6}
  // oColumn:colorBlock := {|| {6,6} }
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew("МКБ10",{|| tmp->kod_diag })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew("Профиль услуги",{|| padr(inieditspr(A__MENUVERT,glob_V002,tmp->PROFIL),15) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew("Врач",{|| put_val(ret_tabn(tmp->kod_vr),5) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew("Асс.",{|| put_val(ret_tabn(tmp->kod_as),5) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew("Кол;усл",{|| str(tmp->kol_1,3) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew(" Общая; ст-ть",{|| put_kop(tmp->stoim_1,8) })
  // oColumn:colorBlock := blk_color
  // oBrow:addColumn(oColumn)
  status_key("^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление")
  return NIL
  
***** 06.01.22
Function f1oms_sluch_lek_pr()
  LOCAL nRow := ROW(), nCol := COL()
  // local s := tmp->name_u, lcolor := cDataCSay

  // if is_zf_stomat == 1 .and. !empty(tmp->zf)
  //   s := alltrim(tmp->zf)+" / "+s
  //   lcolor := color8
  // endif
  // @ maxrow()-2,2 say padr(s,65) color lcolor
  // if empty(tmp->u_cena)
  //   s := iif(tmp->n_base==0, "", "ФФОМС")
  // else
  //   s := alltrim(dellastnul(tmp->u_cena,10,2))
  // endif
  // @ maxrow()-2,68 say padc(s,11) color cDataCSay
  // f3oms_usl_sluch()
  // @ nRow, nCol SAY ""
  return NIL

****** 07.01.22
function f2oms_sluch_lek_pr(nKey,oBrow)

  LOCAL flag := -1, buf := savescreen(), k_read := 0, count_edit := 0
  local r1 := 10, ix
  local last_date := human->n_data

  do case
    case nKey == K_F9
    case nKey == K_F10
    case nKey == K_INS .or. (nKey == K_ENTER .and. tmp->KOD_HUM > 0)
      private mMNN := .f.
      private arr_lek_pr := {}
      private mdate_u1 := iif(nKey == K_INS, last_date, tmp->date_u1)  // для совместимости с f5editkusl
      private m1SCHEME := iif(nKey == K_INS, '', tmp->SCHEME), mSCHEME
      private m1SCHEMECOD := iif(nKey == K_INS, '', tmp->SCHEMECO), mSCHEMECOD
      private m1UNITCODE := iif(nKey == K_INS, '', tmp->ED_IZM), mUNITCODE
      private m1METHOD := iif(nKey == K_INS, '', tmp->METHOD), mMETHOD
      private m1REGNUM := iif(nKey == K_INS, '', tmp->METHOD), mREGNUM
      private mDOZE :=  iif(nKey == K_INS, 0.0, tmp->DOZE)
      private mKOLVO :=  iif(nKey == K_INS, 0, tmp->COL_INJ)

      --r1
      box_shadow(r1-1,0,maxrow()-1,79,color8,;
                 iif(nKey == K_INS,"Добавление нового препарата",;
                                   "Редактирование препарата"),iif(yes_color,"RB+/B","W/N"))
      do while .t.
        setcolor(cDataCGet)
        ix := 1
        @ r1+ix,2 say "Дата введения препарата" get mdate_u1 ;
              valid {| g | f5editpreparat(g, 2, 1)}

        ++ix
        @ r1 + ix,2 say "Схема лечения" get mSCHEME ;
            reader {|x|menu_reader(x, get_schemas_lech(m1Severity, mdate_u1), A__MENUVERT,,,.f.)} ;
            valid {| g | f5editpreparat(g, 2, 3)}

        ++ix
        @ r1 + ix,2 say "Сочетание схемы лечения препаратам" get mSCHEMECOD ;
            reader {|x|menu_reader(x, get_group_by_schema_lech(m1SCHEME, mdate_u1), A__MENUVERT,,,.f.)} ;
            valid {| g | f5editpreparat(g, 2, 2)}
            
        ++ix
        @ r1 + ix,2 say "Препарат" get mREGNUM ;
            reader {|x|menu_reader(x, arr_lek_pr, A__MENUVERT,,,.f.)} ;
            when mMNN
                
        ++ix
        @ r1 + ix,2 say "Доза" get mDOZE picture '999.99'
        
        ++ix
        @ r1 + ix,2 say "Единица измерения" get mUNITCODE ;
            reader {|x|menu_reader(x, getV034(), A__MENUVERT,,,.f.)} ;
            valid {|| mUNITCODE := padr(mUNITCODE, 69), .t. }
        
        ++ix
        @ r1 + ix,2 say "Способ введения" get mMETHOD ;
            reader {|x|menu_reader(x, getV035(), A__MENUVERT,,,.f.)} ;
            valid {|| mMETHOD := padr(mMETHOD, 69), .t. }
            
        ++ix
        @ r1 + ix,2 say "Количество введений" get mKOLVO picture '99'
                
        status_key("^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи")
        count_edit := myread( , ,++k_read)
        if lastkey() != K_ESC
          // обработка и выход
          select tmp
          append blank
          tmp->NUMBER       := tmp->(recno())
          tmp->KOD_HUM      := HUMAN->KOD
          tmp->DATE_INJ     := mdate_u1
          tmp->SCHEME       := m1SCHEME
          tmp->SCHEMECO     := m1SCHEMECOD
          tmp->REGNUM       := m1REGNUM
          tmp->ED_IZM       := str(m1UNITCODE, 3)
          tmp->SHORTTIT     := left(mUNITCODE, 5)
          tmp->DOZE         := mDOZE
          tmp->METHOD       := str(m1METHOD, 3)
          tmp->COL_INJ      := mKOLVO
          // tmp->COD_MARK     := LEK_PR->COD_MARK
          // tmp->REC_N        :=  LEK_PR->(recno())
          last_date := max(tmp->DATE_INJ, last_date)
          flag := 0
          exit
        elseif lastkey() == K_ESC
          exit
        endif
      enddo
                            
    case nKey == K_DEL .and. tmp->KOD_HUM > 0 .and. f_Esc_Enter(2)
      flag := 0
    otherwise
      keyboard ''
  endcase
  
  restscreen(buf)
  return flag

***** 07.01.22 функция для when и valid при вводе услуг в лист учёта
Function f5editpreparat(get, when_valid, k)
  Local fl := .t., arr, row
  local arrN020 := {}, tmpSelect
  
  if when_valid == 1    // when
    if k == 1     // Дата оказания услуги
    elseif k == 2 // Сочетание схемы лечения препаратам
    elseif k == 3 // схема лечения
    endif
  else  // valid
    if k == 1     // Дата оказания услуги
      if !emptyany(human->n_data, mdate_u1) .and. mdate_u1 < human->n_data
        fl := func_error(4, "Введенная дата меньше даты начала лечения!")
      elseif !emptyany(human->k_data, mdate_u1) .and. mdate_u1 > human->k_data
        fl := func_error(4, "Введенная дата больше даты окончания лечения!")
      endif
    elseif k == 2 // Сочетание схемы лечения препаратам
      mSCHEMECOD := alltrim(mSCHEMECOD)
      if (arr := get_group_prep_by_kod(substr(m1SCHEMECOD, len(m1SCHEMECOD)), mdate_u1)) != nil
        mMNN := iif(arr[3] == 1, .t., .f.)
        if mMNN
          arrN020 := get_drugcode_by_schema_lech(m1SCHEMECOD, mdate_u1)
          if len(arrN020) != 0
            tmpSelect := select()
            R_Use(exe_dir + '_mo_N020', cur_dir + '_mo_N020', 'N20')
            for each row in arrN020
              find (row[2])
              if found()
                AAdd(arr_lek_pr, {N20->MNN, N20->ID_LEKP, N20->DATEBEG, N20->DATEEND })
              endif
            next
            N20->(dbCloseArea())
            select(tmpSelect)
            arrN020 := {}
          endif
        else
          arr_lek_pr := {}
          arrN020 := {}
        endif
      endif
    elseif k == 3 // схема лечения
      mSCHEMECOD := alltrim(mSCHEME)
    endif
  endif
  return fl