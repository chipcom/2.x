#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 09.12.23 ПерН - добавление или редактирование случая (листа учета)
Function oms_sluch_PerN(Loc_kod, kod_kartotek, f_print)
  // Loc_kod - код по БД human.dbf (если = 0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  // f_print - наименование функции для печати
  Static st_N_DATA, st_K_DATA, st_mo_pr := '      ', ;
         st_school := 0, st_tip_school := 0
  Local L_BEGIN_RSLT := 342
  Local bg := {|o, k| get_MKB10(o, k, .t.) }, arr_del := {}, mrec_hu := 0, ;
        buf := savescreen(), tmp_color := setcolor(), a_smert := {}, ;
        p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ;
        i, j, k, n, s, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
        pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod, ;
        tmp_help := chm_help_code, fl_write_sluch := .f., _y, _m, _d, t_arr[2]
  //
  Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0, f_print TO ''
  //
  if kod_kartotek == 0 // добавление в картотеку
    if (kod_kartotek := edit_kartotek(0, , , .t.)) == 0
      return NIL
    endif
  endif
  chm_help_code := 3002
  Private mfio := space(50), mpol, mdate_r, madres, mvozrast, mdvozrast, msvozrast := ' ', ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-ОМС, 1-компании, 3-комитеты/ЛПУ, 5-личный счет
    msmo := '34007', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := space(100), ;
    mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
  Private mkod := Loc_kod, mtip_h, is_talon := .f., ;
          mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0), ;
    M1LPU := glob_uch[1], MLPU, ;
    M1OTD := glob_otd[1], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MUCH_DOC    := space(10)         , ; // вид и номер учетного документа
    MKOD_DIAG   := space(5)          , ; // шифр 1-ой осн.болезни
    MKOD_DIAG2  := space(5)          , ; // шифр 2-ой осн.болезни
    MKOD_DIAG3  := space(5)          , ; // шифр 3-ой осн.болезни
    MKOD_DIAG4  := space(5)          , ; // шифр 4-ой осн.болезни
    MSOPUT_B1   := space(5)          , ; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := space(5)          , ; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := space(5)          , ; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := space(5)          , ; // шифр 4-ой сопутствующей болезни
    MDIAG_PLUS  := space(8)          , ; // дополнения к диагнозам
    adiag_talon[16]                  , ; // из статталона к диагнозам
    m1rslt  := L_BEGIN_RSLT          , ; // результат лечения
    m1ishod := 306      , ; // исход = осмотр
    MN_DATA := st_N_DATA         , ; // дата начала лечения
    MK_DATA := st_K_DATA         , ; // дата окончания лечения
    MVRACH := space(10)         , ; // фамилия и инициалы лечащего врача
    M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
    m1povod  := 4, ;   // Профилактический
    m1travma := 0, ;
    m1USL_OK := USL_OK_POLYCLINIC, ; // поликлиника
    m1VIDPOM :=  1, ; // первичная
    m1PROFIL := 68, ; // педиатрия
    m1IDSP   := 17   // законченный случай в п-ке
  //
  Private mperiod := 0, mshifr_zs := '', ;
          mMO_PR := space(10), m1MO_PR := st_mo_pr, ; // код МО прикрепления
          mschool := space(10), m1school := st_school, ; // код обр.учреждения
          mtip_school := space(10), m1tip_school := st_tip_school, ; // тип обр.учреждения
          mprotivo, m1protivo := 0, mgruppa := 0, m1GR_FIZ := 0
  Private mvar, m1var, m1lis := 0
  //
  for i := 1 to count_Pern_arr_iss // исследования
    mvar := 'MTAB_NOMiv' + lstr(i)
    Private &mvar := 0
    mvar := 'MTAB_NOMia' + lstr(i)
    Private &mvar := 0
    mvar := 'MDATEi' + lstr(i)
    Private &mvar := ctod('')
    mvar := 'MREZi' + lstr(i)
    Private &mvar := space(17)
    m1var := 'M1LIS' + lstr(i)
    Private &m1var := 0
    mvar := 'MLIS' + lstr(i)
    Private &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
  next
  // педиатр
  Private MTAB_NOMpv1 := 0, MTAB_NOMpa1 := 0, MDATEp1 := ctod(''), MKOD_DIAGp1 := space(6)
  //
  afill(adiag_talon, 0)
  R_Use(dir_server + 'human_', , 'HUMAN_')
  R_Use(dir_server + 'human', , 'HUMAN')
  set relation to recno() into HUMAN_
  if mkod_k > 0
    R_Use(dir_server + 'kartote2', , 'KART2')
    goto (mkod_k)
    R_Use(dir_server + 'kartote_', , 'KART_')
    goto (mkod_k)
    R_Use(dir_server + 'kartotek', , 'KART')
    goto (mkod_k)
    M1FIO       := 1
    mfio        := kart->fio
    mpol        := kart->pol
    mdate_r     := kart->date_r
    M1VZROS_REB := kart->VZROS_REB
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
    msmo        := kart_->SMO
    m1MO_PR     := kart2->MO_PR
    if kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    endif
    if eq_any(is_uchastok, 1, 3)
      MUCH_DOC := padr(amb_kartaN(), 10)
    elseif mem_kodkrt == 2
      MUCH_DOC := padr(lstr(mkod_k), 10)
    endif
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(1,, .t.) // открыть и закрыть
    endif
    // // проверка исхода = СМЕРТЬ
    // select HUMAN
    // set index to (dir_server + 'humankk')
    // find (str(mkod_k, 7))
    // do while human->kod_k == mkod_k .and. !eof()
    //   if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
    //                               human_->oplata != 9 .and. human_->NOVOR == 0
    //     a_smert := {'Данный больной умер!', ;
    //                 'Лечение с '+full_date(human->N_DATA)+;
    //                       ' по '+full_date(human->K_DATA)}
    //     exit
    //   endif
    //   skip
    // enddo
    // set index to
    a_smert := result_is_death(mkod_k, Loc_kod)
  endif
  if Loc_kod > 0
    select HUMAN
    goto (Loc_kod)
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    mfio        := human->fio
    mpol        := human->pol
    mdate_r     := human->date_r
    MTIP_H      := human->tip_h
    M1VZROS_REB := human->VZROS_REB
    MADRES      := human->ADRES         // адрес больного
    MMR_DOL     := human->MR_DOL        // место работы или причина безработности
    M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий
    mUCH_DOC    := human->uch_doc
    m1VRACH     := human_->vrach
    MKOD_DIAG0  := human_->KOD_DIAG0
    MKOD_DIAG   := human->KOD_DIAG
    MKOD_DIAG2  := human->KOD_DIAG2
    MKOD_DIAG3  := human->KOD_DIAG3
    MKOD_DIAG4  := human->KOD_DIAG4
    MSOPUT_B1   := human->SOPUT_B1
    MSOPUT_B2   := human->SOPUT_B2
    MSOPUT_B3   := human->SOPUT_B3
    MSOPUT_B4   := human->SOPUT_B4
    MDIAG_PLUS  := human->DIAG_PLUS
    MPOLIS      := human->POLIS         // серия и номер страхового полиса
    for i := 1 to 16
      adiag_talon[i] := int(val(substr(human_->DISPANS, i, 1)))
    next
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    if empty(val(msmo := human_->SMO))
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    else
      m1komu := m1str_crb := 0
    endif
    m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    mcena_1    := human->CENA_1
    //
    larr_i := array(count_Pern_arr_iss)
    afill(larr_i, 0)
    larr_p := {}
    mdate1 := mdate2 := ctod('')
    R_Use(dir_server + 'uslugi', , 'USL')
    use_base('human_u')
    find (str(Loc_kod, 7))
    do while hu->kod == Loc_kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1, usl->kod, mk_data))
        lshifr := usl->shifr
      endif
      lshifr := alltrim(lshifr)
      if left(lshifr, 5) == '72.4.'
        mshifr_zs := lshifr
      else
        fl := .t.
        for i := 1 to count_Pern_arr_iss
          if nPer_arr_issled[i, 1] == lshifr
            fl := .f.
            larr_i[i] := hu->(recno())
            exit
          endif
        next
        if fl .and. eq_any(hu_->PROFIL, 68, 57)
          aadd(larr_p, {hu->(recno()), c4tod(hu->date_u)})
        endif
      endif
      aadd(arr_usl, hu->(recno()))
      select HU
      skip
    enddo
    if len(larr_p) > 1 // если осмотров педиатра почему-то более 1
      asort(larr_p, , , {|x, y| x[2] < y[2]})  // отсортировать по дате
      asize(larr_p, 1) // отрезать лишние приёмы
    endif
    R_Use(dir_server + 'mo_pers', , 'P2')
    for j := 1 to 2
      if j == 1
        _arr := larr_i
        bukva := 'i'
      else
        _arr := larr_p
        bukva := 'p'
      endif
      for i := 1 to len(_arr)
        k := iif(j == 2, _arr[i, 1], _arr[i])
        if !empty(k)
          hu->(dbGoto(k))
          if hu->kod_vr > 0
            p2->(dbGoto(hu->kod_vr))
            mvar := 'MTAB_NOM' + bukva + 'v' + lstr(i)
            &mvar := p2->tab_nom
          endif
          if hu->kod_as > 0
            p2->(dbGoto(hu->kod_as))
            mvar := 'MTAB_NOM' + bukva+ 'a' + lstr(i)
            &mvar := p2->tab_nom
          endif
          mvar := 'MDATE' + bukva + lstr(i)
          &mvar := c4tod(hu->date_u)
          if j == 1
            m1var := 'm1lis' + lstr(i)
            if glob_yes_kdp2[TIP_LU_PERN] .and. ascan(glob_arr_usl_LIS, nper_arr_issled[i, 1]) > 0 ;
                                          .and. hu->is_edit == 1
              &m1var := 1
            endif
            mvar := 'mlis' + lstr(i)
            &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
          elseif !empty(hu_->kod_diag) .and. !(left(hu_->kod_diag, 1) == 'Z')
            mvar := 'MKOD_DIAG' + bukva + lstr(i)
            &mvar := hu_->kod_diag
          endif
        endif
      next
    next
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2, @rec_inogSMO, .t.) // открыть и закрыть
    endif
    read_arr_PerN(Loc_kod)
  endif
  if !(left(msmo, 2) == '34') // не Волгоградская область
    m1ismo := msmo
    msmo := '34'
  endif
  close databases
  is_talon := .t.
  fv_date_r( iif(Loc_kod>0, mn_data, ))
  MFIO_KART := _f_fio_kart()
  mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  mlpu      := inieditspr(A__POPUPMENU, dir_server + 'mo_uch', m1lpu)
  motd      := inieditspr(A__POPUPMENU, dir_server + 'mo_otd', m1otd)
  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mismo     := init_ismo(m1ismo)
  f_valid_komu( , -1)
  if m1komu == 0
    m1company := int(val(msmo))
  elseif eq_any(m1komu, 1, 3)
    m1company := m1str_crb
  endif
  mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
  if m1company == 34
    if !empty(mismo)
      mcompany := padr(mismo, 38)
    elseif !empty(mnameismo)
      mcompany := padr(mnameismo, 38)
    endif
  endif
  //
  if !empty(m1MO_PR)
    mMO_PR := ret_mo(m1MO_PR)[_MO_SHORT_NAME]
  endif
  mschool := inieditspr(A__POPUPMENU, dir_server + 'mo_schoo', m1school)
  mtip_school := inieditspr(A__MENUVERT, mm_tip_school, m1tip_school)
  mprotivo := inieditspr(A__MENUVERT, mm_danet, m1protivo)
  //
  if !empty(f_print)
    return &(f_print + '(' + lstr(Loc_kod) + ',' + lstr(kod_kartotek) + ',' + lstr(mvozrast) + ')')
  endif
  //
  str_1 := ' случая периодического осмотра несовершеннолетних'
  if Loc_kod == 0
    str_1 := 'Добавление' + str_1
    mtip_h := yes_vypisan
  else
    str_1 := 'Редактирование' + str_1
  endif
  setcolor(color8)
  Private gl_area := {1, 0, maxrow() - 1, maxcol(), 0}
  setcolor(cDataCGet)
  make_diagP(1)  // сделать 'шестизначные' диагнозы
  do while .t.
    close databases
    @ 0, 0 say padc(str_1, 80) color 'B/BG*'
    j := 1
    myclear(j)
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 say padl('Лист учета № ' + lstr(Loc_kod), 29) color color14
    endif
    @ ++j, 1 say 'Учреждение' get mlpu when .f. color cDataCSay
    @ row(), col() + 2 say 'Отделение' get motd when .f. color cDataCSay
    //
    @ ++j, 1 say 'ФИО' get mfio_kart ;
         reader {|x| menu_reader(x, {{|k, r, c| get_fio_kart(k, r, c)}}, A__FUNCTION, , , .f.)} ;
         valid {|g,o| update_get('mdate_r'), ;
                      update_get('mkomu'), update_get('mcompany')}
    @ row(), col() + 5 say 'Д.р.' get mdate_r when .f. color color14
    @ ++j, 1 say 'Принадлежность счёта' get mkomu ;
               reader {|x|menu_reader(x, mm_komu, A__MENUVERT, , , .f.)} ;
               valid {|g, o| f_valid_komu(g, o)} ;
               color colget_menu
    @ row(), col() + 1 say '==>' get mcompany ;
             reader {|x|menu_reader(x, mm_company, A__MENUVERT, , , .f.)} ;
             when m1komu < 5 ;
             valid {|g| func_valid_ismo(g, m1komu, 38) }
    @ ++j, 1 say 'Полис ОМС: серия' get mspolis when m1komu == 0
    @ row(), col() + 3 say 'номер'  get mnpolis when m1komu == 0
    @ row(), col() + 3 say 'вид'    get mvidpolis ;
              reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)} ;
              when m1komu == 0 ;
              valid func_valid_polis(m1vidpolis, mspolis, mnpolis)
    @ ++j, 1 to j, 78
    @ ++j, 1 say 'Сроки осмотра' get mn_data ;
              valid {|g| f_k_data(g, 1), ;
                    iif(mvozrast < 18, nil, func_error(4, 'Это взрослый пациент!')), ;
                        msvozrast := padr(count_ymd(mdate_r, mn_data), 40), ;
                        .t.;
                    }
    @ row(), col() + 1 say '-' get mk_data valid {|g|f_k_data(g, 2)}
    @ row(), col() + 3 get msvozrast when .f. color color14
    @ ++j, 1 say '№ амбулаторной карты' get much_doc picture '@!' ;
               when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
                     .or. mem_edit_ist==2
    ++j
    @ ++j, 1 say 'МО прикрепления' get mMO_PR ;
              reader {|x|menu_reader(x, {{|k, r, c|f_get_mo(k, r, c)}}, A__FUNCTION, , , .f.)}
    @ ++j, 1 say 'Общеобразовательное учреждение' get mschool ;
             reader {|x|menu_reader(x, {dir_server + 'mo_schoo', , , , , ,'Общеобразовательные учр-ия', 'B/BG'}, A__POPUPBASE1, , , .f.)}
    @ ++j, 1 say 'Тип общеобразовательного учреждения' get mtip_school ;
              reader {|x|menu_reader(x, mm_tip_school, A__MENUVERT, , , .f.)} ;
              valid {|| mperiod := iif(m1tip_school == 1, 1, 2), ;
                        iif(mperiod == 1, (MTAB_NOMiv3 := MTAB_NOMia3 := 0, MDATEi3 := ctod(''), MREZi3 := space(17)),), ;
                        iif(mperiod == 2.and.empty(MDATEi3), MDATEi3 := mn_data,), ;
                        .t.}
    @ ++j, 1 to j, 78
    @ ++j, 1 say 'Наименования исследований              Врач Ассис.  Дата     Результат' color 'RB+/B'
    if mem_por_ass == 0
      @ j, 45 say space(6)
    endif
    ++j
    if empty(MDATEi1)
      MDATEi1 := mn_data
    endif
    @ j, 1 say padr('Общий анализ мочи', 38)
    @ j, 39 get MTAB_NOMiv1 pict '99999' valid {|g| v_kart_vrach(g) }
    if mem_por_ass > 0
      @ j, 45 get MTAB_NOMia1 pict '99999' valid {|g| v_kart_vrach(g) }
    endif
    @ j, 51 get MDATEi1
    @ j, 62 get MREZi1
    //
    ++j
    if empty(MDATEi2)
      MDATEi2 := mn_data
    endif
    @ j, 1 say padr('Клинический анализ крови', 38)
    if glob_yes_kdp2[TIP_LU_PERN] .and. ascan(glob_arr_usl_LIS, nper_arr_issled[2, 1]) > 0
      @ j, 34 get mlis2 reader {|x|menu_reader(x, mm_kdp2, A__MENUVERT, , , .f.)}
    endif
    @ j, 39 get MTAB_NOMiv2 pict '99999' valid {|g| v_kart_vrach(g) }
    if mem_por_ass > 0
      @ j, 45 get MTAB_NOMia2 pict '99999' valid {|g| v_kart_vrach(g) }
    endif
    @ j, 51 get MDATEi2
    @ j, 62 get MREZi2
    //
    ++j
    if mperiod == 1
      MTAB_NOMiv3 := MTAB_NOMia3 := 0
      MDATEi3 := ctod('')
      MREZi3 := space(17)
    elseif empty(MDATEi3)
      MDATEi3 := mn_data
    endif
    @ j, 1 say padr('Анализ окиси углерода выдыхаем.воздуха', 38)
    @ j, 39 get MTAB_NOMiv3 pict '99999' valid {|g| v_kart_vrach(g) } ;
           when mperiod == 2
    if mem_por_ass > 0
      @ j, 45 get MTAB_NOMia3 pict '99999' valid {|g| v_kart_vrach(g) } ;
             when mperiod == 2
    endif
    @ j, 51 get MDATEi3 when mperiod == 2
    @ j, 62 get MREZi3 when mperiod == 2
    //
    @ ++j, 1 say 'Наименование осмотра                   Врач Ассис.  Дата     Диагноз' color 'RB+/B'
    if mem_por_ass == 0
      @ j, 45 say space(6)
    endif
    ++j
    if empty(MDATEp1)
      MDATEp1 := mn_data
    endif
    @ j, 1 say padr('педиатр (врач общей практики)', 38) color color8
    @ j, 39 get MTAB_NOMpv1 pict '99999' valid {|g| v_kart_vrach(g) }
    if mem_por_ass > 0
      @ j, 45 get MTAB_NOMpa1 pict '99999' valid {|g| v_kart_vrach(g) }
    endif
    @ j, 51 get MDATEp1
    @ j, 62 get MKOD_DIAGp1 picture pic_diag ;
          reader {|o|MyGetReader(o, bg)} valid val1_10diag(.t., .f., .f., mn_data, mpol)
    @ ++j, 1 to j, 78
    @ ++j, 1 say 'Обнаружены медицинские противопоказания к продолжению учёбы?' get mprotivo ;
               reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)}
    status_key('^<Esc>^ - выход без записи; ^<PgDn>^ - запись')
    if !empty(a_smert)
      n_message(a_smert, , 'GR+/R', 'W+/R', , , 'G+/R')
    endif
    count_edit += myread( , , ++k_read)
    k := f_alert({padc('Выберите действие', 60, '.')}, ;
                 {' Выход без записи ', ' Запись ', ' Возврат в редактирование '}, ;
                 iif(lastkey() == K_ESC, 1, 2), 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N, N/BG')
    if k == 3
      loop
    elseif k == 2
      if m1komu < 5 .and. empty(m1company)
        if m1komu == 0
          s := 'СМО'
        elseif m1komu == 1
          s := 'компании'
        else
          s := 'комитета/МО'
        endif
        func_error(4, 'Не заполнено наименование ' + s)
        loop
      endif
      if m1komu == 0 .and. empty(mnpolis)
        func_error(4, 'Не заполнен номер полиса')
        loop
      endif
      if empty(mn_data)
        func_error(4, 'Не введена дата начала лечения.')
        loop
      endif
      if mvozrast >= 18
        func_error(4, 'Периодический осмотр оказан взрослому пациенту!')
        loop
      endif
      if !between(mperiod, 1, 2)
        func_error(4, 'Не удалось определить возрастной период!')
        loop
      endif
      if empty(mk_data)
        func_error(4, 'Не введена дата окончания лечения.')
        loop
      elseif year(mk_data) == 2018
        func_error(4, 'Периодические осмотры с 2018 года более не проводятся')
        loop
      endif
      if empty(CHARREPL('0', much_doc, space(10)))
        func_error(4, 'Не заполнен номер амбулаторной карты')
        loop
      endif
      if empty(mmo_pr)
        func_error(4, 'Не введено МО, к которому прикреплён несовершеннолетний.')
        loop
      endif
      if empty(m1school)
        func_error(4, 'Не введено общеобразовательное учреждение.')
        loop
      endif
      if mvozrast < 1
        mdef_diagnoz := 'Z00.1 '
      elseif mvozrast < 14
        mdef_diagnoz := 'Z00.2 '
      else
        mdef_diagnoz := 'Z00.3 '
      endif
      arr_iss := array(count_Pern_arr_iss, 10)
      afillall(arr_iss, 0)
      R_Use(dir_exe + '_mo_mkb', cur_dir + '_mo_mkb', 'MKB_10')
      R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'P2')
      max_date1 := max_date2 := mn_data
      fl := .t.
      ar := nPer_arr_1_etap[mperiod]
      for i := 1 to count_Pern_arr_iss
        if ascan(ar[5], nPer_arr_issled[i, 1]) > 0
          mvart := 'MTAB_NOMiv' + lstr(i)
          mvara := 'MTAB_NOMia' + lstr(i)
          mvard := 'MDATEi' + lstr(i)
          mvarr := 'MREZi' + lstr(i)
          if empty(&mvard)
            fl := func_error(4, 'Не введена дата иссл-ия "' + nPer_arr_issled[i, 3] + '"')
          elseif empty(&mvart)
            fl := func_error(4, 'Не введен врач в иссл-ии "' + nPer_arr_issled[i, 3] + '"')
          else
            select P2
            find (str(&mvart, 5))
            if found()
              arr_iss[i, 1] := p2->kod
              arr_iss[i, 2] := -ret_new_spec(p2->prvs, p2->prvs_new)
            endif
            if !empty(&mvara)
              select P2
              find (str(&mvara, 5))
              if found()
                arr_iss[i, 3] := p2->kod
              endif
            endif
            arr_iss[i, 4] := nPer_arr_issled[i, 5] // профиль
            arr_iss[i, 5] := nPer_arr_issled[i, 1] // шифр услуги
            arr_iss[i, 6] := mdef_diagnoz
            arr_iss[i, 9] := &mvard
            m1var := 'm1lis' + lstr(i)
            if glob_yes_kdp2[TIP_LU_PERN] .and. &m1var == 1
              arr_iss[i, 10] := 1 // кровь проверяют в КДП2
            endif
            max_date1 := max(max_date1, arr_iss[i, 9])
          endif
        endif
        if !fl
          exit
        endif
      next
      if !fl
        loop
      endif
      if emptyany(MTAB_NOMpv1, MDATEp1)
        fl := func_error(4, 'Не введён педиатр (врач общей практики)')
      elseif MDATEp1 < max_date1
        fl := func_error(4, 'Педиатр (врач общей практики) должен проводить осмотр последним!')
      endif
      if !fl
        loop
      endif
      m1rslt := L_BEGIN_RSLT
      //
      err_date_diap(mn_data, 'Дата начала лечения')
      err_date_diap(mk_data, 'Дата окончания лечения')
      //
      if mem_op_out == 2 .and. yes_parol
        box_shadow(19, 10, 22, 69, cColorStMsg)
        str_center(20, 'Оператор "' + fio_polzovat + '".', cColorSt2Msg)
        str_center(21, 'Ввод данных за ' + date_month(sys_date), cColorStMsg)
      endif
      mywait('Ждите. Производится запись листа учёта...')
      m1lis := 0
      if glob_yes_kdp2[TIP_LU_PN]
        for i := 1 to count_Pern_arr_iss
          if valtype(arr_iss[i, 9]) == 'D' .and. arr_iss[i, 9] >= mn_data .and. len(arr_iss[i]) > 9 ;
                                          .and. valtype(arr_iss[i, 10]) == 'N' .and. arr_iss[i, 10] == 1
            m1lis := 1 // в рамках диспансеризации
          endif
        next
      endif
      arr_osm1 := {}
      // добавим педиатра
      aadd(arr_osm1, add_pediatr_PerN(MTAB_NOMpv1, MTAB_NOMpa1, MDATEp1, MKOD_DIAGp1))
      i := len(arr_osm1)
      m1vrach  := arr_osm1[i, 1]
      m1prvs   := arr_osm1[i, 2]
      m1assis  := arr_osm1[i, 3]
      m1PROFIL := arr_osm1[i, 4]
      MKOD_DIAG := padr(arr_osm1[i, 6], 6)
      // добавим код законченного случая
      aadd(arr_osm1, array(9))
      i := len(arr_osm1)
      arr_osm1[i, 1] := arr_osm1[i - 1, 1]
      arr_osm1[i, 2] := arr_osm1[i - 1, 2]
      arr_osm1[i, 3] := arr_osm1[i - 1, 3]
      arr_osm1[i, 4] := 48 // медицинским осмотрам (предварительным, периодическим)
      arr_osm1[i, 5] := ret_shifr_zs_PerN(mperiod)
      arr_osm1[i, 6] := arr_osm1[i - 1, 6]
      arr_osm1[i, 9] := mn_data
      select MKB_10
      find (MKOD_DIAG)
      if found() .and. !between_date(mkb_10->dbegin, mkb_10->dend, mk_data)
        MKOD_DIAG := mdef_diagnoz // если диагноз не входит в ОМС, то умолчание
      endif
      make_diagP(2)  // сделать 'пятизначные' диагнозы
      //
      Use_base('lusl')
      Use_base('luslc')
      Use_base('uslugi')
      R_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1', ;
                                  dir_server + 'uslugi1s'}, 'USL1')
      Private mu_cena
      mcena_1 := 0
      arr_usl_dop := {}
      glob_podr := ''
      glob_otd_dep := 0
      for i := 1 to len(arr_iss)
        if valtype(arr_iss[i, 5]) == 'C'
          arr_iss[i, 7] := foundOurUsluga(arr_iss[i, 5], mk_data, arr_iss[i, 4], M1VZROS_REB, @mu_cena)
          arr_iss[i, 8] := mu_cena
          mcena_1 += mu_cena
          aadd(arr_usl_dop, arr_iss[i])
        endif
      next
      for i := 1 to len(arr_osm1)
        if valtype(arr_osm1[i, 5]) == 'C'
          arr_osm1[i, 7] := foundOurUsluga(arr_osm1[i, 5], mk_data, arr_osm1[i, 4], M1VZROS_REB, @mu_cena)
          arr_osm1[i, 8] := mu_cena
          mcena_1 += mu_cena
          aadd(arr_usl_dop, arr_osm1[i])
        endif
      next
      //
      Use_base('human')
      if Loc_kod > 0
        find (str(Loc_kod, 7))
        mkod := Loc_kod
        G_RLock(forever)
      else
        Add1Rec(7)
        mkod := recno()
        replace human->kod with mkod
      endif
      select HUMAN_
      do while human_->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      //
      select HUMAN_2
      do while human_2->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      //
      st_N_DATA := MN_DATA
      st_K_DATA := MK_DATA
      st_mo_pr := m1mo_pr
      st_school := m1school
      st_tip_school := m1tip_school
      glob_perso := mkod
      if m1komu == 0
        msmo := lstr(m1company)
        m1str_crb := 0
      else
        msmo := ''
        m1str_crb := m1company
      endif
      //
      human->kod_k      := glob_kartotek
      human->TIP_H      := B_STANDART // 3-лечение завершено
      human->FIO        := MFIO          // Ф.И.О. больного
      human->POL        := MPOL          // пол
      human->DATE_R     := MDATE_R       // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
      human->ADRES      := MADRES        // адрес больного
      human->MR_DOL     := MMR_DOL       // место работы или причина безработности
      human->RAB_NERAB  := M1RAB_NERAB   // 0-работающий, 1-неработающий
      human->KOD_DIAG   := mkod_diag     // шифр 1-ой осн.болезни
      human->diag_plus  := mdiag_plus    //
      human->ZA_SMO     := 0
      human->KOMU       := M1KOMU        // от 0 до 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis(mspolis, mnpolis) // серия и номер страхового полиса
      human->LPU        := M1LPU         // код учреждения
      human->OTD        := M1OTD         // код отделения
      human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
      human->N_DATA     := MN_DATA       // дата начала лечения
      human->K_DATA     := MK_DATA       // дата окончания лечения
      human->CENA := human->CENA_1 := MCENA_1 // стоимость лечения
      human->ishod      := 305
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human_->RODIT_DR  := ctod('')
      human_->RODIT_POL := ''
      s := '' ; aeval(adiag_talon, {|x| s += str(x, 1) })
      human_->DISPANS   := s
      human_->STATUS_ST := ''
      //human_->POVOD     := m1povod
      //human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := ltrim(mspolis)
      human_->NPOLIS    := ltrim(mnpolis)
      human_->OKATO     := '' // это поле вернётся из ТФОМС в случае иногороднего
      human_->NOVOR     := 0
      human_->DATE_R2   := ctod('')
      human_->POL2      := ''
      human_->USL_OK    := m1USL_OK
      human_->VIDPOM    := m1VIDPOM
      human_->PROFIL    := m1PROFIL
      human_->IDSP      := 17
      human_->NPR_MO    := ''
      human_->FORMA14   := '0000'
      human_->KOD_DIAG0 := ''
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // уберём '2', если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      if Loc_kod == 0  // при добавлении
        human_->ID_PAC    := mo_guid(1, human_->(recno()))
        human_->ID_C      := mo_guid(2, human_->(recno()))
        human_->SUMP      := 0
        human_->SANK_MEK  := 0
        human_->SANK_MEE  := 0
        human_->SANK_EKMP := 0
        human_->REESTR    := 0
        human_->REES_ZAP  := 0
        human->schet      := 0
        human_->SCHET_ZAP := 0
        human->kod_p   := kod_polzovat    // код оператора
        human->date_e  := c4sys_date
      else // при редактированиии
        human_->kod_p2  := kod_polzovat    // код оператора
        human_->date_e2 := c4sys_date
      endif
      put_0_human_2()
      Private fl_nameismo := .f.
      if m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ОКАТО субъекта РФ территории страхования
        if empty(m1ismo)
          if !empty(mnameismo)
            fl_nameismo := .t.
          endif
        else
          human_->SMO := m1ismo  // заменяем '34' на код иногородней СМО
        endif
      endif
      if fl_nameismo .or. rec_inogSMO > 0
        G_Use(dir_server + 'mo_hismo', , 'SN')
        index on str(kod, 7) to (cur_dir + 'tmp_ismo')
        find (str(mkod, 7))
        if found()
          if fl_nameismo
            G_RLock(forever)
            sn->smo_name := mnameismo
          else
            DeleteRec(.t.)
          endif
        else
          if fl_nameismo
            AddRec(7)
            sn->kod := mkod
            sn->smo_name := mnameismo
          endif
        endif
      endif
      i1 := len(arr_usl)
      i2 := len(arr_usl_dop)
      Use_base('human_u')
      for i := 1 to i2
        select HU
        if i > i1
          Add1Rec(7)
          hu->kod := human->kod
        else
          goto (arr_usl[i])
          G_RLock(forever)
        endif
        mrec_hu := hu->(recno())
        hu->kod_vr  := arr_usl_dop[i, 1]
        hu->kod_as  := arr_usl_dop[i, 3]
        hu->u_koef  := 1
        hu->u_kod   := arr_usl_dop[i, 7]
        hu->u_cena  := arr_usl_dop[i, 8]
        hu->is_edit := iif(len(arr_usl_dop[i]) > 9 .and. valtype(arr_usl_dop[i, 10]) == 'N', arr_usl_dop[i, 10], 0)
        hu->date_u  := dtoc4(arr_usl_dop[i, 9])
        hu->otd     := m1otd
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_usl_dop[i, 8]
        select HU_
        do while hu_->(lastrec()) < mrec_hu
          APPEND BLANK
        enddo
        goto (mrec_hu)
        G_RLock(forever)
        if i > i1 .or. !valid_GUID(hu_->ID_U)
          hu_->ID_U := mo_guid(3, hu_->(recno()))
        endif
        hu_->PROFIL := arr_usl_dop[i, 4]
        hu_->PRVS   := arr_usl_dop[i, 2]
        hu_->kod_diag := arr_usl_dop[i, 6]
        hu_->zf := ''
        UNLOCK
      next
      if i2 < i1
        for i := i2+1 to i1
          select HU
          goto (arr_usl[i])
          DeleteRec(.t., .f.)  // очистка записи без пометки на удаление
        next
      endif
      save_arr_PerN(mkod)
      write_work_oper(glob_task, OPER_LIST, iif(Loc_kod == 0, 1, 2), 1, count_edit)
      fl_write_sluch := .t.
      close databases
      stat_msg('Запись завершена!', .f.)
    endif
    exit
  enddo
  close databases
  setcolor(tmp_color)
  restscreen(buf)
  chm_help_code := tmp_help
  if fl_write_sluch // если записали - запускаем проверку
    if type('fl_edit_DDS') == 'L'
      fl_edit_DDS := .t.
    endif
    if !empty(val(msmo))
      verify_OMS_sluch(glob_perso)
    endif
  endif
  return NIL