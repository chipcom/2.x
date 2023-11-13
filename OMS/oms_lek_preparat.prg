#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 15.01.23
// Function init_lek_pr(_usl_tip, _crit)
Function init_lek_pr()
  Local s, n

  use (cur_dir + 'tmp_onkle') new alias TMPLE
  index on REGNUM to (cur_dir + 'tmp_onkle') UNIQUE
  n := 0
  dbeval({|| ++n })
  s := 'препаратов - ' + lstr(n)
  index on dtos(DATE_INJ) to (cur_dir + 'tmp_onkle') UNIQUE
  n := 0
  dbeval({|| ++n })
  s += ', дней приёма - ' + lstr(n)
  tmple->(dbCloseArea())
  return s


// 29.03.22 проверка на необходимость ввода лекарственных препаратов
function check_oms_sluch_lek_pr(mkod_human)
  // mkod_human - код по БД human

  local vidPom, m1USL_OK, m1PROFIL, last_date, mdiagnoz, d1, d2, ad_cr
  local retFl := .f., mvozrast, p_cel

  G_Use(dir_server + 'human_2', , 'HUMAN_2')
  G_Use(dir_server + 'human_', , 'HUMAN_')
  G_Use(dir_server + 'human', {dir_server + 'humank', ;
                              dir_server + 'humankk', ;
                              dir_server + 'humano'}, 'HUMAN')
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
  human_kod_diag := alltrim(mdiagnoz[1])
  vidPom := human_->VIDPOM
  ad_cr := lower(alltrim(human_2->PC3))
  mvozrast := count_years(human->DATE_R, d2)

  p_cel := get_IDPC_from_V025_by_number(human_->povod)

  if eq_any(human_kod_diag, 'U07.1', 'U07.2') .and. mvozrast >= 18 .and. !check_diag_pregant()
    if (M1USL_OK == 1) .and. (d2 >= 0d20220101)
      retFl := (M1PROFIL != 158) .and. (vidPom != 32) .and. (ad_cr != 'stt5')
    elseif (M1USL_OK == 3) .and. (d2 >= d_01_04_2022)
      retFl := (M1PROFIL != 158) .and. (vidPom != 32) .and. (p_cel == '3.0')
    endif
  endif

  HUMAN_2->(dbCloseArea())    
  HUMAN_->(dbCloseArea())    
  HUMAN->(dbCloseArea())    

  return retFl


// 08.04.22 ввода лекарственных препаратов
function oms_sluch_lek_pr(mkod_human, mkod_kartotek, fl_edit)
  // mkod_human - код по БД human
  // mkod_kartotek - код по БД kartotek
  local aDbf, buf := savescreen(), l_color, fl_found
  local mtitle, tmp_color := setcolor(color1)
  local nBegin, strWeight

  private mSeverity, m1Severity := 0

  default fl_edit to .f.

  G_Use(dir_server + 'human_u',{dir_server + 'human_u', ;
    dir_server + 'human_uk', ;
    dir_server + 'human_ud', ;
    dir_server + 'human_uv', ;
    dir_server + 'human_ua'}, 'HU')
  G_Use(dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU')

  G_Use(dir_server + 'human_2', , 'HUMAN_2')
  G_Use(dir_server + 'human_', , 'HUMAN_')
  G_Use(dir_server + 'human', {dir_server + 'humank', ;
                              dir_server + 'humankk', ;
                              dir_server + 'humano'}, 'HUMAN')
  set relation to recno() into HUMAN_, to recno() into HUMAN_2

  find (str(mkod_human, 7)) // встанем на лист учета

  G_Use(dir_server + 'human_lek_pr', dir_server + 'human_lek_pr', 'LEK_PR')

  adbf := {;
    {'KOD_HUM' ,   'N',    7,     0},; // код листа учёта по файлу 'human'
    {'DATE_INJ',   'D',    8,     0},; // Дата введения лекарственного препарата
    {'SEVERITY',   'N',    5,     0},; // код тяжести течения заболевания по справочнику _mo_severity.dbf
    {'SCHEME'  ,   'C',   10,     0},; // схема лечения пациента V030
    {'SCHEDRUG',   'C',   10,     0},; // сочетание схемы лечения и группы препаратов V032
    {'REGNUM'  ,   'C',    6,     0},; // лекарственного препарата
    {'ED_IZM'  ,   'N',    3,     0},; // Единица измерения дозы лекарственного препарата
    {'DOZE'    ,   'N',    8,     2},; // Доза введения лекарственного препарата
    {'METHOD'  ,   'N',    3,     0},; // Путь введения лекарственного препарата
    {'COL_INJ' ,   'N',    5,     0},; // Количество введений в течениедня, указанного в DATA_INJ
    {'COD_MARK',   'C',  100,     0},; // Код маркировки лекарственного препарата
    {'NUMBER'  ,   'N',    3,     0},; // счетчик строк
    {'REC_N'   ,   'N',    8,     0};  // номер записи в файле human_lek_pr.dbf
  }
  // dbcreate(cur_dir + 'tmp_lek_pr', adbf)
  // use (cur_dir + 'tmp_lek_pr') new alias TMP
  dbCreate( 'mem:lek_pr', adbf, , .T., 'TMP' )

  select LEK_PR
  find (str(mkod_human, 7))
  if found()
    do while LEK_PR->KOD_HUM == mkod_human .and. !eof()
      select TMP
      append blank
      tmp->NUMBER   := tmp->(recno())
      tmp->KOD_HUM  := LEK_PR->KOD_HUM
      tmp->DATE_INJ := LEK_PR->DATE_INJ
      tmp->SEVERITY := LEK_PR->SEVERITY
      tmp->SCHEME   := LEK_PR->CODE_SH
      tmp->SCHEDRUG := LEK_PR->SCHEDRUG
      tmp->REGNUM   := LEK_PR->REGNUM
      tmp->ED_IZM   := LEK_PR->ED_IZM
      tmp->DOZE     := LEK_PR->DOSE_INJ
      tmp->METHOD   := LEK_PR->METHOD_I
      tmp->COL_INJ  := LEK_PR->COL_INJ
      // tmp->COD_MARK := LEK_PR->COD_MARK
      tmp->REC_N    :=  LEK_PR->(recno())
      LEK_PR->(dbSkip())
    enddo
  endif
  fl_found := (tmp->(lastrec()) > 0)
  index on dtos(DATE_INJ) TAG LEK_PR

  cls
  pr_1_str('Лекарственные препараты < ' + fio_plus_novor() + ' >')
  @ 1,50 say padl('Лист учета № ' + lstr(mkod_human), 29) color color14
  l_color := 'W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B'

  setcolor(color1)

  nBegin := 3

  if fl_found
    tmp->(dbGoTop())
    keyboard chr(K_RIGHT)
  else
    keyboard chr(K_INS)
  endif

  mtitle := f_srok_lech(human->n_data,human->k_data,human_->usl_ok)  
  Alpha_Browse(nBegin, 0, maxrow() - 2, 79, 'f_oms_sluch_lek_pr', color1, mtitle, col_tit_popup,;
               .f., .t., , 'f1oms_sluch_lek_pr', 'f2oms_sluch_lek_pr', , ;
               {'═', '░', '═', l_color, .t., 180} )

  LEK_PR->(dbCloseArea())
  TMP->(dbCloseArea())
  dbDrop( 'mem:lek_pr' )  /* освободим память */
  hb_vfErase('mem:lek_pr.ntx')  /* освободим память от индексного файла */

  HUMAN_2->(dbCloseArea())
  HUMAN_->(dbCloseArea())
  HUMAN->(dbCloseArea())
  HU->(dbCloseArea())    
  MOHU->(dbCloseArea())    

  setcolor(tmp_color)
  restscreen(buf)
  verify_OMS_sluch(mkod_human)
  return nil

// 08.01.22
Function f_oms_sluch_lek_pr(oBrow)
  Local oColumn, blk_color

  oColumn := TBColumnNew(' Дата;инекц', ;
      {|| left(dtoc(tmp->DATE_INJ), 5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew('Тяже-; сть ', ;
      {|| iif(tmp->SEVERITY == 0, space(5), padr(ret_severity_name(tmp->SEVERITY), 5)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew('  Тип препарата   ', ;
      {|| iif(empty(tmp->SCHEDRUG), space(18), padr(ret_schema_V032(tmp->SCHEDRUG), 18)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew('     Препарат    ', ;
      {|| iif(empty(tmp->REGNUM), space(17), padr(get_Lek_pr_By_ID(tmp->REGNUM), 17)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew(' Доза',{|| str(tmp->DOZE, 6, 2) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  // oColumn := TBColumnNew(' Единица; измер-я', ;
  //     {|| iif(tmp->ED_IZM == 0, space(8), padr(ret_ed_izm_V034(tmp->ED_IZM), 8)) })
  oColumn := TBColumnNew(' Единица; измер-я', ;
    {|| iif(tmp->ED_IZM == 0, space(8), padr(ret_ed_izm(tmp->ED_IZM), 8)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  
  oColumn := TBColumnNew('  Способ; введения ', ;
      {|| iif(tmp->METHOD == 0, space(10), padr(ret_meth_method_inj(tmp->METHOD), 10)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)

  oColumn := TBColumnNew('Кол',{|| str(tmp->COL_INJ, 3, 0) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  
  status_key('^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление')
  return NIL
  
////* 06.01.22
Function f1oms_sluch_lek_pr()
  LOCAL nRow := ROW(), nCol := COL()
  return NIL

// 08.04.22
function add_lek_pr(dateInjection, nKey)

  if ValType(dateInjection) == 'C'
    dateInjection := ctod(dateInjection)
  endif

  select LEK_PR
  if nKey == K_INS  // при добавлении лекарственного препарата
    AddRec(7)
    select tmp
    append blank
    tmp->NUMBER       := tmp->(recno())
  elseif nKey == K_ENTER    // при редатировании лекарственного препарата
    goto (tmp->REC_N)
    G_RLock(forever)
    select TMP
    goto (number)
  endif

  tmp->REC_N        := LEK_PR->(recno())
  tmp->KOD_HUM      := HUMAN->KOD
  tmp->DATE_INJ     := dateInjection
  tmp->SEVERITY     := m1SEVERITY
  tmp->SCHEME       := m1SCHEME
  tmp->SCHEDRUG     := m1SCHEDRUG
  tmp->REGNUM       := m1REGNUM
  if ! empty(m1REGNUM)
    tmp->ED_IZM       := m1UNITCODE
    tmp->DOZE         := mDOZE
    tmp->METHOD       := m1METHOD
    tmp->COL_INJ      := mKOLVO
  endif
  // tmp->COD_MARK     := LEK_PR->COD_MARK
  select LEK_PR
  LEK_PR->KOD_HUM     := HUMAN->KOD
  LEK_PR->DATE_INJ    := dateInjection
  LEK_PR->SEVERITY    := m1SEVERITY
  LEK_PR->CODE_SH     := m1SCHEME
  LEK_PR->SCHEDRUG    := m1SCHEDRUG
  LEK_PR->REGNUM      := m1REGNUM
  if ! empty(m1REGNUM)
    LEK_PR->ED_IZM      := m1UNITCODE
    LEK_PR->DOSE_INJ    := mDOZE
    LEK_PR->METHOD_I    := m1METHOD
    LEK_PR->COL_INJ     := mKOLVO
  endif
  UnLock
  // LEK_PR->COD_MARK
  select tmp
  return nil

// 18.10.22
function f2oms_sluch_lek_pr(nKey,oBrow)

  LOCAL flag := -1, buf := savescreen(), k_read := 0, count_edit := 0
  local r1, ix, number
  local last_date := human->n_data
  local flMany := .f., tDate
  local arr_dni, row, i

  do case
    case nKey == K_F9
    case nKey == K_F10
    case nKey == K_INS .or. (nKey == K_ENTER .and. tmp->KOD_HUM > 0)
      private mMNN := .f.
      private arr_lek_pr := {}
      private m1date_u1
      private mdate_u1 := iif(nKey == K_INS, last_date, tmp->DATE_INJ)  // для совместимости с f5editkusl
      private m1SEVERITY := iif(nKey == K_INS, 0, tmp->SEVERITY), mSEVERITY
      private m1SCHEME := iif(nKey == K_INS, '', tmp->SCHEME), mSCHEME
      private m1SCHEDRUG := iif(nKey == K_INS, '', tmp->SCHEDRUG), mSCHEDRUG
      private m1UNITCODE := iif(nKey == K_INS, 0, tmp->ED_IZM), mUNITCODE
      private m1METHOD := iif(nKey == K_INS, 0, tmp->METHOD), mMETHOD
      private m1REGNUM := iif(nKey == K_INS, '', tmp->REGNUM), mREGNUM
      private mDOZE :=  iif(nKey == K_INS, 0.0, tmp->DOZE)
      private mKOLVO :=  iif(nKey == K_INS, 0, tmp->COL_INJ)
      // ЧТО-БЫ не делать PUBLIC
      // Private glob_V034 := get_ed_izm()
      // Private glob_methodinj := getMethodINJ()
      Private tmp_V034 := create_classif_FFOMS(2, 'V034') // UNITCODE
      Private tmp_MethodINJ := create_classif_FFOMS(2, 'MethodINJ') // METHOD
   
      private mdate_end_per := mdate_u1      // human->k_data
      private arrDateUslug

      number :=  iif(nKey == K_INS, 0, tmp->NUMBER)

      if human_->USL_OK == 3
        arrDateUslug := collect_date_uslugi()
        if !empty(mdate_u1)
          if (i := ascan(arrDateUslug, {|x| x[1] == dtoc(mdate_u1) })) > 0
            m1date_u1 := arrDateUslug[i, 2]
            mdate_u1 :=  arrDateUslug[i, 1]
          endif
        endif
      endif

      mUNITCODE := space(iif(mem_n_V034 == 0, 15, 30))
      mMETHOD   := space(30)
      mSCHEDRUG := space(42) 
      mREGNUM   := space(30) 
      if nKey == K_ENTER
        mSEVERITY := inieditspr(A__MENUVERT, get_severity(), m1SEVERITY)
        mSCHEME := ret_schema_V030(m1SCHEME)
        mSCHEDRUG := padr(ret_schema_V032(m1SCHEDRUG),42)
        mREGNUM := padr(get_Lek_pr_By_ID(m1REGNUM),30)
        mUNITCODE := padr(inieditspr(A__MENUVERT, get_ed_izm(), m1UNITCODE),iif(mem_n_V034==0,15,30))
        mMETHOD := padr(inieditspr(A__MENUVERT, getMethodINJ(), m1METHOD),30)
      endif

      r1 := 13
      box_shadow(r1, 0, maxrow() - 1, 79, color8, ;
                 iif(nKey == K_INS, 'Добавление нового препарата', ;
                                   'Редактирование препарата'), iif(yes_color, 'RB+/B', 'W/N'))
      do while .t.
        setcolor(cDataCGet)
        ix := 1
        
        if (nKey == K_ENTER .or. nKey == K_INS) .and. human_->USL_OK == 3
          @ r1+ix, 2 say 'Дата назначения препарата' get mdate_u1 ;
              reader {|x|menu_reader(x, arrDateUslug, A__MENUVERT, , , .f.)} ;
              valid {| g | f5editpreparat(g, nKey, 2, 1)}
        elseif nKey == K_ENTER .and. human_->USL_OK == 1
          @ r1+ix, 2 say 'Дата введения препарата' get mdate_u1 ;
              valid {| g | f5editpreparat(g, nKey, 2, 1)}
        elseif nKey == K_INS .and. human_->USL_OK == 1
          @ r1+ix,2 say 'Начало введения препарата' get mdate_u1 ;
              valid {| g | f5editpreparat(g, nKey, 2, 1)}
          @ r1+ix, col() say ', окончание введения препарата' get mdate_end_per ;
              valid {| g | f5editpreparat(g, nKey, 2, 4)}
        endif

        ++ix
        @ r1 + ix,2 say 'Степень тяжести состояния' get mSEVERITY ;
              reader {|x|menu_reader(x, get_severity(), A__MENUVERT,,,.f.)} ;
              valid {| g | f5editpreparat(g, nKey, 2, 6)} 
      
        ++ix
        @ r1 + ix,2 say 'Схема лечения' get mSCHEME ;
            reader {|x|menu_reader(x, get_schemas_lech(m1Severity, mdate_u1), A__MENUVERT,,,.f.)} ;
            valid {| g | f5editpreparat(g, nKey, 2, 3)}

        ++ix
        @ r1 + ix,2 say 'Сочетание схемы лечения препаратам' get mSCHEDRUG ;
            reader {|x|menu_reader(x, get_group_by_schema_lech(m1SCHEME, mdate_u1), A__MENUVERT,,,.f.)} ;
            valid {| g | f5editpreparat(g, nKey, 2, 2)}
            
        ++ix
        @ r1 + ix,2 say 'Препарат' get mREGNUM ;
            reader {|x|menu_reader(x, arr_lek_pr, A__MENUVERT,,,.f.)} ;
            valid {| g | f5editpreparat(g, nKey, 2, 5)} ;
            when mMNN

        ++ix
        @ r1 + ix,2 say 'Доза' get mDOZE picture '99999.99' ;
            valid {|| mDOZE != 0 } ;
            when mMNN
        
        ++ix
        @ r1 + ix,2 say 'Единица измерения' get mUNITCODE ;
            reader {|x|menu_reader(x, tmp_V034, A__MENUVERT,,,.f.)} ;
            valid {|| mUNITCODE := padr(mUNITCODE, iif(mem_n_V034==0,15,30)), m1UNITCODE != 0 } ;
            when mMNN
        
        ++ix
        @ r1 + ix,2 say 'Способ введения' get mMETHOD ;
            reader {|x|menu_reader(x,tmp_MethodINJ , A__MENUVERT,,,.f.)} ;
            valid {|| mMETHOD := padr(mMETHOD, 30), m1METHOD != 0 } ;
            when mMNN
            
        ++ix
        @ r1 + ix,2 say 'Количество введений' get mKOLVO picture '99' ;
            valid {|| mKOLVO != 0 } ;
            when mMNN
                
        status_key('^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи')
        count_edit := myread( , ,++k_read)
        if lastkey() != K_ESC
          // обработка и выход
          if nKey == K_INS    // добавление
            flMany := (mdate_end_per > mdate_u1)
            if flMany
                // добавим пакетом лекарственные препараты
              if (arr_dni := select_arr_days(mdate_u1, mdate_end_per)) != NIL
                for each row in arr_dni
                  add_lek_pr(row[2], nKey)
                  last_date := max(tmp->DATE_INJ, last_date)
                next
              endif
            else
              add_lek_pr(mdate_u1, nKey)
              last_date := max(tmp->DATE_INJ, last_date)
            endif
          elseif nKey == K_ENTER  // редактирование
            add_lek_pr(mdate_u1, nKey)
            last_date := max(tmp->DATE_INJ, last_date)
          endif
          select TMP
          oBrow:goTop()
          flag := 0
          exit
        elseif lastkey() == K_ESC
          exit
        endif
      enddo
                            
    case nKey == K_DEL .and. tmp->KOD_HUM > 0 .and. f_Esc_Enter(2)
      if tmp->rec_n != 0
        select LEK_PR
        goto (tmp->rec_n)
        DeleteRec(.t.)  // очистка записи с пометкой на удаление
        select TMP
      endif
      DeleteRec(.t.)  // с пометкой на удаление
      oBrow:goTop()
      go top
      if eof()
        keyboard chr(K_INS)
      endif
      flag := 0
    otherwise
      keyboard ''
  endcase
  
  restscreen(buf)
  return flag

// 29.03.22 функция для when и valid при вводе услуг в лист учёта
Function f5editpreparat(get, nKey, when_valid, k)
  Local fl := .t., arr, row
  local arrN020 := {}, tmpSelect
  
  if when_valid == 1    // when
    if k == 1     // Дата оказания услуги
    elseif k == 2 // Сочетание схемы лечения препаратам
    elseif k == 3 // схема лечения
    elseif k == 4 // дата окончания периода
    endif
  else  // valid
    if k == 1     // Дата оказания услуги
      if ValType(mdate_u1) == 'C'
        mdate_u1 := CToD(mdate_u1)
      endif
      if !emptyany(human->n_data, mdate_u1) .and. mdate_u1 < human->n_data
        fl := func_error(4, 'Введенная дата меньше даты начала лечения!')
      elseif !emptyany(human->k_data, mdate_u1) .and. mdate_u1 > human->k_data
        fl := func_error(4, 'Введенная дата больше даты окончания лечения!')
      endif
      if nKey == K_ENTER
      elseif nKey == K_INS
        if mdate_u1 > mdate_end_per
          mdate_end_per := mdate_u1
          update_get('mdate_end_per')  
      endif
      endif
    elseif k == 2 // Сочетание схемы лечения препаратам
      if empty(get:buffer)
        return .f.
      endif
      if alltrim(get:buffer) != mSCHEDRUG
        // очистим все
        m1UNITCODE := 0
        mUNITCODE  := space(iif(mem_n_V034==0,15,30))
        //
        mMETHOD    := space(30)
        m1METHOD   := 0
        //
        m1REGNUM   := ''
        mREGNUM    := space(30)
        //
        mDOZE      := 0.0
        mKOLVO     := 0.0
        update_get('mUNITCODE')  
        update_get('mMETHOD')     
        update_get('mREGNUM')  
        update_get('mDOZE')  
        update_get('mKOLVO')
      endif
      mSCHEDRUG := alltrim(mSCHEDRUG)
      if (arr := get_group_prep_by_kod(substr(m1SCHEDRUG, len(m1SCHEDRUG)), mdate_u1)) != nil
        mMNN := iif(arr[3] == 1, .t., .f.)
        if mMNN
          arrN020 := get_drugcode_by_schema_lech(m1SCHEDRUG, mdate_u1)
          if len(arrN020) != 0
            tmpSelect := select()
            R_Use(dir_exe + '_mo_N020', cur_dir + '_mo_N020', 'N20')
            arr_lek_pr := {}
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
          func_error(1,'У Данной схемы НЕТ МЕДИКАМЕНТОВ!')
        endif
      endif
    elseif k == 3 // схема лечения
      if empty(get:buffer)
        return .f.
      endif
      if alltrim(get:buffer) != mSCHEME
        // очистим все
        m1UNITCODE := 0
        mUNITCODE  := space(iif(mem_n_V034==0,15,30))
        //
        mMETHOD    := space(30)
        m1METHOD   := 0
        //
        m1SCHEDRUG := ''
        mSCHEDRUG  := space(42) 
        //
        m1REGNUM   := ''
        mREGNUM    := space(30)
        //
        mDOZE      := 0.0
        mKOLVO     := 0.0
        update_get('mUNITCODE')  
        update_get('mMETHOD')  
        update_get('mSCHEDRUG')  
        update_get('mREGNUM')  
        update_get('mDOZE')  
        update_get('mKOLVO')  
      endif
    elseif k == 4     // Дата окончания периода
      if !emptyany(human->n_data, mdate_end_per) .and. mdate_end_per < human->n_data
        fl := func_error(4, 'Введенная дата меньше даты начала лечения!')
      elseif !emptyany(human->k_data, mdate_end_per) .and. mdate_end_per > human->k_data
        fl := func_error(4, 'Введенная дата больше даты окончания лечения!')       
      endif
    elseif k == 5 //препарат 
      if empty(get:buffer)
        return .f.
      endif
      if alltrim(get:buffer) != mREGNUM
        // очистим все
        m1UNITCODE := 0
        mUNITCODE  := space(iif(mem_n_V034==0,15,30))
        mMETHOD    := space(30)
        m1METHOD   := 0
        mDOZE      := 0.0
        mKOLVO     := 0.0
        update_get('mUNITCODE')  
        update_get('mMETHOD')  
        update_get('mDOZE')  
        update_get('mKOLVO')  
      endif
    elseif k == 6 // Степень тяжести состояния
      if empty(get:buffer)
        return .f.
      endif
      if alltrim(get:buffer) != mSEVERITY 
        // очистим все
        mSCHEME   := space(10) 
        m1SCHEME  := ''
        //
        m1UNITCODE := 0
        mUNITCODE  := space(iif(mem_n_V034==0,15,30))
        //
        mMETHOD    := space(30)
        m1METHOD   := 0
        //
        m1SCHEDRUG := ''
        mSCHEDRUG  := space(42) 
        //
        m1REGNUM   := ''
        mREGNUM    := space(30)
        //
        mDOZE      := 0.0
        mKOLVO     := 0.0
        update_get('mUNITCODE')  
        update_get('mMETHOD')  
        update_get('mSCHEDRUG')  
        update_get('mREGNUM')  
        update_get('mDOZE')  
        update_get('mKOLVO')  
        update_get('mSCHEME') 
      endif 
    endif
  endif
  return fl

//////* 06.03.22
function collect_lek_pr(mkod_human)
  local retArr := {}
  local existAlias := .f.
  local oldSelect := select()
  local lekAlias
  local cAlias := 'LEK_PR'
  
  lekAlias := select(cAlias)
  if lekAlias == 0
    R_Use(dir_server + 'human_lek_pr', dir_server + 'human_lek_pr', cAlias)
  endif
  dbSelectArea(cAlias)
  (cAlias)->(dbSeek(str(mkod_human, 7)))
  if (cAlias)->(found())
    do while (cAlias)->KOD_HUM == mkod_human .and. !eof()
      AAdd( retArr, {(cAlias)->DATE_INJ, (cAlias)->CODE_SH, (cAlias)->REGNUM, (cAlias)->ED_IZM, ;
                  (cAlias)->DOSE_INJ, (cAlias)->METHOD_I, (cAlias)->COL_INJ, (cAlias)->SCHEDRUG})
      (cAlias)->(dbSkip())
    enddo
  endif

  select(oldSelect)
  if lekAlias == 0
    (cAlias)->(dbCloseArea())
  endif

  return retArr

////* 10.01.22 функция для when и valid при вводе различных полей
Function check_edit_field(get, when_valid, k)
  Local fl := .t.
  local arrN020 := {}, tmpSelect
  
  if when_valid == 1    // when
    if k == 1     // Вес пациента в кг
    elseif k == 2 // 
    elseif k == 3 // 
    endif
  else  // valid
    if k == 1     // Вес пациента в кг
      if val(get:buffer) > 500
        get:varPut( get:original )
        fl := func_error(4, 'Введенный вес не может быть выше 500 кг!')
      elseif val(get:buffer) < 0
        get:varPut( get:original )
        fl := func_error(4, 'Введенный вес не может быть отрицательным!')
      endif
    elseif k == 2 // 
    elseif k == 3 // 
    endif
  endif
  return fl

// 27.09.23
Function get_lek_pr(k, r, c, _crit)
  Local i, j, nrec, t_arr := array(BR_LEN), ret := {space(10), space(10)}

  local aN021 := getN021(mk_data), it, row

  Private arr_lek_pr := {}, yes_crit
  dbcreate(cur_dir + 'tmp', {{'id_lekp', 'C', 6, 0}, ;
                        {'mnn', 'C', 70, 0}, ;
                        {'kol', 'N', 3, 0}})
  use (cur_dir + 'tmp') new
  index on id_lekp to (cur_dir + 'tmp')
  R_Use(dir_exe + '_mo_N020', {cur_dir + '_mo_N020', cur_dir + '_mo_N020n'}, 'N20')
  set filter to between_date(datebeg, dateend, mk_data)

  // R_Use(dir_exe + '_mo_N021', cur_dir + '_mo_N021', 'N21')
  // set filter to between_date(datebeg, dateend, mk_data)

  if (it := ascan(aN021, {|x| x[2] + x[3] == _crit})) == 0
    yes_crit := .t.
  endif

  // find (_crit)
  // yes_crit := found()

  use (cur_dir + 'tmp_onkle') new alias TMPLE
  index on REGNUM + dtos(DATE_INJ) to (cur_dir + 'tmp_onkle') UNIQUE

  if yes_crit // по данному критерию есть препараты в схеме
    // select N21
    // // find (padr(_crit, 10))
    // find(_crit)
    // do while alltrim(n21->code_sh) == alltrim(_crit) .and. !eof()
    //   select TMP
    //   append blank
    //   tmp->id_lekp := n21->id_lekp
    //   aadd(arr_lek_pr, {tmp->id_lekp, tmp->(recno()), {}})
    //   i := len(arr_lek_pr)
    //   select N20
    //   find (n21->id_lekp)
    //   if found()
    //     tmp->mnn := n20->mnn
    //   else
    //     tmp->mnn := 'Препарат ' + n21->id_lekp + ' не найден в справочнике N020'
    //   endif
    //   select TMPLE
    //   find (tmp->id_lekp)
    //   do while tmp->id_lekp == tmple->REGNUM .and. !eof()
    //     aadd(arr_lek_pr[i, 3], tmple->DATE_INJ)
    //     skip
    //   enddo
    //   tmp->kol := len(arr_lek_pr[i, 3])
    //   select N21
    //   skip
    // enddo
    for each row in aN021
      if alltrim(row[2]) == alltrim(_crit)
        select TMP
        append blank
        tmp->id_lekp := row[3]
        aadd(arr_lek_pr, {tmp->id_lekp, tmp->(recno()), {}})
        i := len(arr_lek_pr)
        select N20
        find (row[3])
        if found()
          tmp->mnn := n20->mnn
        else
          tmp->mnn := 'Препарат ' + row[3] + ' не найден в справочнике N020'
        endif
        select TMPLE
        find (tmp->id_lekp)
        do while tmp->id_lekp == tmple->REGNUM .and. !eof()
          aadd(arr_lek_pr[i, 3], tmple->DATE_INJ)
          skip
        enddo
        tmp->kol := len(arr_lek_pr[i, 3])
      endif
    next
  else // по данному критерию нет препаратов в схеме
    select TMPLE
    go top
    do while !eof()
      select N20
      find (tmple->REGNUM)
      if found() // найден препарат в справочнике
        select TMP
        find (tmple->REGNUM)
        if !found()
          append blank
          tmp->id_lekp := tmple->REGNUM
          tmp->mnn := n20->mnn
        endif
        tmp->kol ++
        if (i := ascan(arr_lek_pr, {|x| x[2] == tmp->(recno())})) == 0
          aadd(arr_lek_pr, {tmp->id_lekp, tmp->(recno()),{}})
          i := len(arr_lek_pr)
        endif
        aadd(arr_lek_pr[i, 3], tmple->DATE_INJ)
      endif
      select TMPLE
      skip
    enddo
  endif
  select TMPLE
  set index to
  nrec := tmp->(lastrec())
  if yes_crit
    t_arr[BR_TOP] := r - nrec - 4
  else//
    t_arr[BR_TOP] := r - 4 - 4
  endif
  if t_arr[BR_TOP] < 2
    t_arr[BR_TOP] := 2
  endif
  t_arr[BR_BOTTOM] := r - 1
  t_arr[BR_LEFT]  := 1
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color5
  t_arr[BR_TITUL] := 'Редактирование дат введения препаратов для схемы ' + alltrim(_crit)
  t_arr[BR_TITUL_COLOR] := 'BG+/GR'
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', , .t.}
  t_arr[BR_COLUMN] := {{' Наименование препарата', {|| tmp->mnn }}, ;
                      {' Дни', {|| tmp->kol}}}
  t_arr[BR_EDIT] := {|nk, ob| f1_get_lek_pr(nk,ob, 'edit', r)}
  s := '^<Esc>^ - выход;  ^<Enter>^ - редактирование дат'
  if !yes_crit
    s += '; ^<Ins>^ - добавить препарат;  ^<Del>^ - удалить препарат'
  endif
  t_arr[BR_STAT_MSG] := {|| status_key(s)}
  select TMP
  index on upper(mnn) to (cur_dir + 'tmp')
  go top
  if eof() .and. !yes_crit
    keyboard chr(K_INS)
  endif
  edit_browse(t_arr)
  //
  nrec := tmp->(lastrec())
  select TMPLE
  zap
  for i := 1 to nrec
    if len(arr_lek_pr) >= i
      for j := 1 to len(arr_lek_pr[i, 3])
        select TMPLE
        append blank
        tmple->REGNUM   := arr_lek_pr[i, 1]
        tmple->CODE_SH  := _crit
        tmple->DATE_INJ := arr_lek_pr[i, 3, j]
      next
    endif
  next
  index on dtos(DATE_INJ) to (cur_dir + 'tmp_onkle') UNIQUE
  ndn := 0
  dbeval({|| ++ndn })
  ret[1] := ret[2] := padr('препаратов - ' + lstr(nrec) + ', дней приёма - ' + lstr(ndn), 53)
  //
  tmp->(dbCloseArea())
  tmple->(dbCloseArea())
  n20->(dbCloseArea())
  // n21->(dbCloseArea())
  return ret

// 31.01.19 выбор нескольких дат
Function f1_get_lek_pr(nKey, oBrow, regim, get_row)
  Local mlen, t_mas := {}, buf := savescreen(), i, j, d, tmp_color := setcolor(), ;
        k, n, r1, r2, top_bottom, r := row(), ret := -1
  
  if regim == 'edit'
    if nKey == K_ENTER .and. tmp->(lastrec()) > 0
      if (i := ascan(arr_lek_pr, {|x| x[2] == tmp->(recno())})) == 0
        func_error(4, 'Непонятная ошибка!')
      else
        for d := mn_data to mk_data
          aadd(t_mas, iif(ascan(arr_lek_pr[i, 3], d) > 0, ' * ', '   ') + full_date(d))
        next
        mlen := len(t_mas)
        status_key('^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins,+,->^ - смена выбора даты')
        top_bottom := (r < maxrow() / 2)
        if top_bottom     // сверху вниз
          r1 := r + 1
          if (r2 := r1 + mlen + 1) > maxrow() - 2
            r2 := maxrow() - 2
          endif
        else
          r2 := r - 1
          if (r1 := r2 - mlen - 1) < 2
            r1 := 2
          endif
        endif
        if popup(r1, 60, r2, 77, t_mas, i, color0, .t., 'fmenu_reader', , 'Даты введения', 'B/BG') > 0
          arr_lek_pr[i, 3] := {}
          for j := 1 to mlen
            if '*' == substr(t_mas[j], 2, 1)
              aadd(arr_lek_pr[i, 3], ctod(substr(t_mas[j], 4)))
            endif
          next
          tmp->kol := len(arr_lek_pr[i, 3])
        endif
      endif
    elseif nKey == K_INS .and. !yes_crit
      if (k := f2_get_lek_pr(get_row)) != NIL
        select TMP
        go top
        Locate for id_lekp == k[1]
        if found()
          func_error(2, 'Данный препарат уже добавлен!')
        else
          AddRecN()
          tmp->id_lekp := k[1]
          tmp->mnn := k[2]
          aadd(arr_lek_pr, {tmp->id_lekp, tmp->(recno()), {}} )
        endif
        ret := 0
      endif
      select TMP
    elseif nKey == K_DEL .and. !yes_crit .and. f_Esc_Enter(2)
      if (i := ascan(arr_lek_pr, {|x| x[2] == tmp->(recno()) })) > 0
        Del_Array(arr_lek_pr, i)
      endif
      deleterec()
      go top
      oBrow:gotop()
      ret := 1
    endif
  endif
  restscreen(buf)
  setcolor(tmp_color)
  return ret
  
// 31.01.19
Function f2_get_lek_pr(r)
  Static srec := 0
  Local ret, t_arr[BR_LEN]

  t_arr[BR_TOP] := 3
  t_arr[BR_BOTTOM] := r - 1
  t_arr[BR_LEFT] := 4
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := 'Добавление лекарственного препарата'
  t_arr[BR_TITUL_COLOR] := 'BG+/GR'
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', 'N/BG,W+/N', .f., 72}
  t_arr[BR_COLUMN] := {{center('Наименование', 72), {|| left(n20->mnn, 70)}}}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке')}
  t_arr[BR_EDIT] := {|nk, ob| f3_get_lek_pr(nk, ob)}
  t_arr[BR_ENTER] := {|| srec := n20->(recno()), ret := {n20->id_lekp, n20->mnn}}
  //
  select N20
  set order to 2
  if srec > 0
    goto (srec)
  else
    go top
  endif
  edit_browse(t_arr)
  return ret
  
// 31.01.19
Function f3_get_lek_pr(nk, ob)
  Local ret := -1, rec
  if nk == K_F2
    if (ret := f4_get_lek_pr(@rec, ob)) == 0
      ob:goTop()
      goto (rec)
    endif
  endif
  return ret
  
// 31.01.19
Function f4_get_lek_pr(ret_rec, obrow)
  Static stmp1 := ''
  Local rec1 := recno(), buf := savescreen(), tmp_color, ret := -1, j, r1 := pr2 - 6, r2 := pr2 - 1

  box_shadow(r1, pc1 + 1, r2, pc2 - 1, cDataPgDn, 'Поиск по ключу', cDataCSay)
  tmp_color := setcolor(cDataCGet)
  @ r1 + 2, pc1 + 2 say center('Введите ключевое слово', pc2 - pc1 - 3)
  do while .t.
    setcolor(cDataCGet)
    tmp := padr(stmp1, pc2 - pc1 - 3)
    status_key('^<Esc>^ - отказ от ввода')
    @ r1 + 3, pc1 + 2 get tmp picture '@K@!'
    myread()
    setcolor(color0)
    if lastkey() == K_ESC .or. empty(tmp)
      goto (rec1)
    else
      mywait()
      stmp1 := tmp := alltrim(tmp)
      Private tmp_mas := {}, tmp_kod := {}, i := 0, t_len, k1 := pr1 + 3, k2 := pr2 - 1
      oBrow:goTop()
      do while !eof()
        if tmp $ upper(n20->mnn)
          ++i
          aadd(tmp_mas, n20->mnn)
          aadd(tmp_kod, recno())
        endif
        skip
      enddo
      if (t_len := len(tmp_kod)) == 0
        func_error(3, 'Неудачный поиск!')
        loop
      else
        box_shadow(pr1, pc1, pr2, pc2)
        SETCOLOR('B/BG')
        @ pr1 + 1, pc1 + 2 say 'Ключ: ' + tmp
        SETCOLOR(color0)
        if t_len < pr2 - pr1 - 5
          k2 := k1 + t_len + 2
        endif
        @ k1, pc1 + 1 say padc('Найденное количество - ' + lstr(i), pc2 - pc1 - 1)
        status_key('^<Esc>^ - отказ от выбора')
        if (i := popup(k1 + 1, pc1 + 1, k2, pc2 - 1, tmp_mas, 1, 0)) > 0
          ret_rec := tmp_kod[i]
          ret := 0
        endif
      endif
    endif
    exit
  enddo
  goto (rec1)
  restscreen(buf)
  setcolor(tmp_color)
  return ret
  
  