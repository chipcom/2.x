#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

***** 01.11.19 СМП - добавление или редактирование случая (листа учета)
Function oms_sluch_SMP_1(Loc_kod,kod_kartotek,tip_lu)
  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  // tip_lu - TIP_LU_SMP или TIP_LU_NMP - скорая помощь (неотложная медицинская помощь)
  Static mm_brigada, st_brigada, mm_trombolit, st_trombolit, mm_spec, SKOD_DIAG := '     ',;
         st_N_DATA, st_vrach := 0, st_rslt := 0, st_ishod := 0
  Local top2, ar, ibrm := 0
  Local bg := {|o, k| get_MKB10(o, k, .t.) }, arr_del := {}, mrec_hu := 0,;
        buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
        arr_usluga := {}, p_uch_doc := '@!', pic_diag := '@K@!',;
        i, colget_menu := 'R/W', colgetImenu := 'R/BG',;
        pos_read := 0, k_read := 0, count_edit := 0,;
        tmp_help := chm_help_code, fl_write_sluch := .f.
  
  //
  Default st_N_DATA TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0
  Private row_diag_screen, rdiag := 1
  if mem_smp_input == 0
    if  kod_kartotek == 0 // добавление в картотеку
      if (kod_kartotek := edit_kartotek(0, ,,.t.)) == 0
        return NIL
      endif
    endif
    top2 := 6
    row_diag_screen := 6
  else
    top2 := 5
    row_diag_screen := 9
    Private ;
      MFIO        := space(50)         ,; // Ф.И.О. больного
      mfam := space(40), mim := space(40), mot := space(40),;
      mpol        := "М"            ,;
      mdate_r     := boy(addmonth(sys_date,-12*30)) ,;
      MVZROS_REB, M1VZROS_REB := 0,;
      MADRES      := space(50)         ,; // адрес больного
      m1MEST_INOG := 0, newMEST_INOG := 0,;
      MVID_UD                          ,; // вид удостоверения
      M1VID_UD    := 14                ,; // 1-18
      mser_ud := space(10), mnom_ud := space(20), mmesto_r := space(100), ;
      MKEMVYD, M1KEMVYD := 0, MKOGDAVYD := ctod(""),; // кем и когда выдан паспорт
      mspolis := space(10), mnpolis := space(20), msmo := '34007',;
      mnamesmo, m1namesmo,;
      m1company := 0, mcompany, mm_company, ;
      m1KOMU := 0, MKOMU, M1STR_CRB := 0, ;
      mvidpolis, m1vidpolis := 1,;
      msnils := space(11),;
      mokatog := padr(alltrim(okato_umolch),11, "0"),;
      m1adres_reg := 1, madres_reg,;
      rec_inogSMO := 0, ;
      mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100)
    if kod_kartotek > 0
      R_Use(dir_server + "kartote_", , "KART_")
      R_Use(dir_server + "kartotek", , "KART")
      select KART
      goto (kod_kartotek)
      select KART_
      goto (kod_kartotek)
      mFIO        := kart->FIO
      mpol        := kart->pol
      mDATE_R     := kart->DATE_R
      m1VZROS_REB := kart->VZROS_REB
      mADRES      := kart->ADRES
      msnils      := kart->snils
      if kart->MI_GIT == 9
        m1KOMU    := kart->KOMU
        M1STR_CRB := kart->STR_CRB
      endif
      if kart->MEST_INOG == 9 // т.е. отдельно занесены Ф.И.О.
        m1MEST_INOG := kart->MEST_INOG
      endif
      m1vidpolis  := kart_->VPOLIS // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый
      mspolis     := kart_->SPOLIS // серия полиса
      mnpolis     := kart_->NPOLIS // номер полиса
      msmo        := kart_->SMO    // реестровый номер СМО
      m1vid_ud    := kart_->vid_ud   // вид удостоверения личности
      mser_ud     := kart_->ser_ud   // серия удостоверения личности
      mnom_ud     := kart_->nom_ud   // номер удостоверения личности
      m1kemvyd    := kart_->kemvyd   // кем выдан документ
      mkogdavyd   := kart_->kogdavyd // когда выдан документ
      mmesto_r    := kart_->mesto_r      // место рождения
      mokatog     := kart_->okatog       // код места жительства по ОКАТО
      m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
      //
      arr := retFamImOt(1,.f.)
      mfam := padr(arr[1],40)
      mim  := padr(arr[2],40)
      mot  := padr(arr[3],40)
      if alltrim(msmo) == '34'
        mnameismo := ret_inogSMO_name(1,@rec_inogSMO,.t.)
      elseif left(msmo,2) == '34'
        // Волгоградская область
      elseif !empty(msmo)
        m1ismo := msmo ; msmo := '34'
      endif
    endif
    close databases
  endif
  if tip_lu == TIP_LU_SMP .and. empty(mm_brigada)
    mm_brigada := {} ; mm_trombolit := {}
    Use_base("luslc")
    set order to 2
    find (glob_mo[_MO_KOD_TFOMS]+ "71.")
    do while luslc->CODEMO == glob_mo[_MO_KOD_TFOMS] .and. left(luslc->shifr,3) == "71."
      // поиск цены по дате окончания лечения
      if between_date(luslc->datebeg,luslc->dateend,sys_date)
        if eq_any(left(luslc->shifr,5), "71.1.", "71.2.")
          i := right(alltrim(luslc->shifr),1)
          if ascan(mm_brigada,{|x| x[2] == i }) == 0
            aadd(mm_brigada,{"-",i})
          endif
        elseif left(luslc->shifr,5) == "71.3."
          i := AfterAtNum(".",alltrim(luslc->shifr))
          if ascan(mm_trombolit,{|x| x[2] == i }) == 0
            aadd(mm_trombolit,{"-",i})
          endif
        endif
      endif
      skip
    enddo
    luslc->(dbCloseArea())
    if len(mm_brigada) == 0
      return func_error(4, "Ввод скорой помощи не разрешён в Вашей МО по состоянию на "+full_date(sys_date))
    endif
    asort(mm_brigada, ,,{|x,y| x[2] < y[2] } )
    for i := 1 to len(mm_brigada)
      do case
        case mm_brigada[i,2] == '1'
          mm_brigada[i,1] := "1-фельдшерская"
          st_brigada := '1'
        case mm_brigada[i,2] == '2'
          mm_brigada[i,1] := "2-врачебная"
          st_brigada := '2'
        case mm_brigada[i,2] == '3'
          mm_brigada[i,1] := "3-интенсивной терапии"
        case mm_brigada[i,2] == '4'
          mm_brigada[i,1] := "4-анестезиологии и реаниматологии"
        case mm_brigada[i,2] == '5'
          mm_brigada[i,1] := "5-кардиологическая"
        case mm_brigada[i,2] == '6'
          mm_brigada[i,1] := "6-педиатрическая"
      endcase
    next
    if len(mm_trombolit) > 0
      asort(mm_trombolit, ,,{|x,y| val(x[2]) < val(y[2]) } )
      st_trombolit := mm_trombolit[1,2]
      for i := 1 to len(mm_trombolit)
        do case
          case mm_trombolit[i,2] == '1'
            mm_trombolit[i,1] := "фельдшерская - применение актилизе"
          case mm_trombolit[i,2] == '2'
            mm_trombolit[i,1] := "фельдшерская - применение фортолезина"
          case mm_trombolit[i,2] == '3'
            mm_trombolit[i,1] := "фельдшерская - применение пуролазы"
          case mm_trombolit[i,2] == '4'
            mm_trombolit[i,1] := "фельдшерская - применение метализе"
          case mm_trombolit[i,2] == '5'
            mm_trombolit[i,1] := "врачебная - применение актилизе"
          case mm_trombolit[i,2] == '6'
            mm_trombolit[i,1] := "врачебная - применение фортолезина"
          case mm_trombolit[i,2] == '7'
            mm_trombolit[i,1] := "врачебная - применение пуролазы"
          case mm_trombolit[i,2] == '8'
            mm_trombolit[i,1] := "врачебная - применение метализе"
          case mm_trombolit[i,2] == '9'
            mm_trombolit[i,1] := "спец.врачебная - применение актилизе"
          case mm_trombolit[i,2] == '10'
            mm_trombolit[i,1] := "спец.врачебная - применение фортолезина"
          case mm_trombolit[i,2] == '11'
            mm_trombolit[i,1] := "спец.врачебная - применение пуролазы"
          case mm_trombolit[i,2] == '12'
            mm_trombolit[i,1] := "спец.врачебная - применение метализе"
        endcase
      next
    endif
  endif
  if tip_lu == TIP_LU_NMP .and. empty(mm_spec)
    mm_spec := {{"фельдшер",1},{"врач",2}}
  endif
  chm_help_code := 3002
  //
  ar := GetIniVar(tmp_ini,{{"RAB_MESTO", "kart_polis", "1"}} )
  Private mm_rslt := {}, mm_ishod := {}, rslt_umolch := 401, ishod_umolch := 401, p_find_polis := int(val(ar[1]))
  if tip_lu == TIP_LU_NMP
    rslt_umolch := 301 ; ishod_umolch := 301
  endif
  //
  if mem_smp_input == 0
    Private mfio := space(50), mpol, mdate_r, madres, ;
            M1VZROS_REB, MVZROS_REB, m1company := 0, mcompany, mm_company,;
            mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
            msmo := "34007", rec_inogSMO := 0,;
            mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
            mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
  endif
  Private mkod := Loc_kod, mtip_h, is_talon := .f.,;
          mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
    M1LPU := glob_uch[1], MLPU,;
    M1OTD := glob_otd[1], MOTD,;
    M1FIO_KART := 1, MFIO_KART,;
    MUCH_DOC    := 0                 ,; // вид и номер учетного документа
    MKOD_DIAG   := SKOD_DIAG         ,; // шифр 1-ой осн.болезни
    MKOD_DIAG2  := space(5)          ,; // шифр 2-ой осн.болезни
    MKOD_DIAG3  := space(5)          ,; // шифр 3-ой осн.болезни
    MKOD_DIAG4  := space(5)          ,; // шифр 4-ой осн.болезни
    MSOPUT_B1   := space(5)          ,; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := space(5)          ,; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := space(5)          ,; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := space(5)          ,; // шифр 4-ой сопутствующей болезни
    MDIAG_PLUS  := space(8)          ,; // дополнения к диагнозам
    mrslt, m1rslt := st_rslt         ,; // результат
    mishod, m1ishod := st_ishod      ,; // исход
    MN_DATA := MK_DATA := st_N_DATA         ,; // дата начала лечения
    MVRACH      := space(10)         ,; // фамилия и инициалы лечащего врача
    M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
    MF14_EKST, M1F14_EKST := 0       ,; //
    m1novor := 0, mnovor, mcount_reb := 0,;
    mDATE_R2 := ctod(""), mpol2 := " ",;
    mbrigada, m1brigada := st_brigada,;
    mtrombolit, m1trombolit := st_trombolit,;
    m1brig := 0, mbrig, mm_brig,;
    m1spec := 1, mspec,;
    mprer_b := space(28), m1prer_b := 0,; // прерывание беременности
    mm1prer_b := {{"по медицинским показаниям   ",1},;
                  {"НЕ по медицинским показаниям",2}},;
    mm2prer_b := {{"постановка на учёт по берем.",1},;
                  {"продолжение наблюдения      ",0}},;
    mm3prer_b := {{"отсутствие болевого синдрома",0},;
                  {"острая боль                 ",1},;
                  {"постоянная некупирующ. боль ",2},;
                  {"другая постоянная боль      ",3},;
                  {"боль неуточнённая           ",4}},;
    mtip, m1tip := 0,;
    musluga, m1usluga := 0,;
    mm_usluga := {{"А05.10.004.001 Расшифровка ЭКГ",1},;
                  {"В01.015.007 Консультация кардиолога",2}},;
    m1USL_OK := iif(tip_lu == TIP_LU_SMP, 4, 3),;
    m1VIDPOM := iif(tip_lu == TIP_LU_SMP, 21, 11),;
    m1PROFIL := iif(tip_lu == TIP_LU_SMP, 84, 160),;
    m1IDSP   := iif(tip_lu == TIP_LU_SMP, 24, 41)
  Private mm_prer_b := mm2prer_b
  //
  // aeval(glob_V009,{|x| iif(x[5] == m1USL_OK, aadd(mm_rslt,x), nil) })
  // aeval(glob_V012,{|x| iif(x[5] == m1USL_OK, aadd(mm_ishod,x), nil) })
  aeval(getV009(),{|x| iif(x[5] == m1USL_OK, aadd(mm_rslt,x), nil) })
  aeval(getV012(),{|x| iif(x[5] == m1USL_OK, aadd(mm_ishod,x), nil) })
  if ascan(mm_rslt, {|x| x[2] == rslt_umolch}) > 0
    m1rslt := rslt_umolch
  endif
  if ascan(mm_ishod, {|x| x[2] == ishod_umolch}) > 0
    m1ishod := ishod_umolch
  endif
  //
  R_Use(dir_server + "human_2", , "HUMAN_2")
  R_Use(dir_server + "human_", , "HUMAN_")
  R_Use(dir_server + "human", , "HUMAN")
  set relation to recno() into HUMAN_, recno() into HUMAN_2
  if mkod_k > 0
    if mem_smp_input == 0
      R_Use(dir_server + "kartote_", , "KART_")
      goto (mkod_k)
      R_Use(dir_server + "kartotek", , "KART")
      goto (mkod_k)
      M1FIO       := 1
      mfio        := kart->fio
      mpol        := kart->pol
      mdate_r     := kart->date_r
      M1VZROS_REB := kart->VZROS_REB
      mADRES      := kart->ADRES
      m1VIDPOLIS  := kart_->VPOLIS
      mSPOLIS     := kart_->SPOLIS
      mNPOLIS     := kart_->NPOLIS
      mmesto_r    := kart_->mesto_r      // место рождения
      m1kemvyd    := kart_->kemvyd   // кем выдан документ
      mkogdavyd   := kart_->kogdavyd // когда выдан документ
      m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
      msmo        := kart_->SMO
      if kart->MI_GIT == 9
        m1komu    := kart->KOMU
        m1str_crb := kart->STR_CRB
      endif
      if alltrim(msmo) == '34'
        mnameismo := ret_inogSMO_name(1, ,.t.) // открыть и закрыть
      endif
    endif
    // проверка исхода = СМЕРТЬ
    select HUMAN
    set index to (dir_server + "humankk")
    find (str(mkod_k,7))
    do while human->kod_k == mkod_k .and. !eof()
      if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
                                   human_->oplata != 9 .and. human_->NOVOR == 0
        a_smert := {"Данный больной умер!",;
                    "Лечение с "+full_date(human->N_DATA)+;
                          " по "+full_date(human->K_DATA)}
        exit
      endif
      skip
    enddo
    set index to
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
    mUCH_DOC    := int(val(human->uch_doc))
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
    mstatus_st  := human_->STATUS_ST
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    if empty(val(msmo := human_->SMO))
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    else
      m1komu := m1str_crb := 0
    endif
    if human_->NOVOR > 0
      m1novor := 1
      mcount_reb := human_->NOVOR
      mDATE_R2 := human_->DATE_R2
      mpol2 := human_->POL2
    endif
    m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
    M1F14_EKST := int(val(substr(human_->FORMA14, 1, 1)))
    mn_data := mk_data := human->N_DATA
    m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW
    if (ibrm := f_oms_beremenn(mkod_diag)) > 0
      m1prer_b := human_2->PN2
    endif
    //
    R_Use(dir_server + "uslugi", , "USL")
    use_base("human_u")
    find (str(Loc_kod,7))
    do while hu->kod == Loc_kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
        lshifr := usl->shifr
      endif
      if tip_lu == TIP_LU_SMP .and. left(lshifr,3) == "71." .and. mrec_hu == 0
        if left(lshifr,5) == "71.3."
          m1trombolit := right(rtrim(lshifr),1)
          m1tip := 1
        else
          m1brigada := right(rtrim(lshifr),1)
          m1tip := 0
        endif
        mrec_hu := hu->(recno())
      elseif tip_lu == TIP_LU_NMP .and. eq_any(alltrim(lshifr), "2.80.27", "2.80.28") .and. mrec_hu == 0
        m1spec := iif(alltrim(lshifr) == "2.80.27", 1, 2)
        mrec_hu := hu->(recno())
      else
        aadd(arr_del,hu->(recno()))
      endif
      select HU
      skip
    enddo
    for i := 1 to len(arr_del)
      select HU
      goto (arr_del[i])
      DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
    next
    if mem_smp_tel == 1
      R_Use(dir_server + "mo_su", , "MOSU")
      G_Use(dir_server + "mo_hu", dir_server + "mo_hu", "MOHU")
      find (str(Loc_kod,7))
      do while mohu->kod == Loc_kod .and. !eof()
        mosu->(dbGoto(mohu->u_kod))
        if alltrim(mosu->shifr1) == "A05.10.004.001"
          m1usluga := setbit(m1usluga,1)
          aadd(arr_usluga, {1,mohu->(recno())})
        elseif alltrim(mosu->shifr1) == "B01.015.007"
          m1usluga := setbit(m1usluga,2)
          aadd(arr_usluga, {2,mohu->(recno())})
        else
          aadd(arr_usluga, {0,mohu->(recno())})
        endif
        select MOHU
        skip
      enddo
    endif
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // открыть и закрыть
    endif
  endif
  if !(left(msmo,2) == '34') // не Волгоградская область
    m1ismo := msmo ; msmo := '34'
  endif
  if m1vrach > 0
    R_Use(dir_server + "mo_pers", , "P2")
    goto (m1vrach)
    MTAB_NOM := p2->tab_nom
    m1prvs := -ret_new_spec(p2->prvs,p2->prvs_new)
    mvrach := padr(fam_i_o(p2->fio)+ " "+ret_tmp_prvs(m1prvs),36)
  endif
  close databases
  fv_date_r( iif(Loc_kod>0,mn_data,) )
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  MNOVOR    := inieditspr(A__MENUVERT, mm_danet, M1NOVOR)
  MF14_EKST := inieditspr(A__MENUVERT, mm_ekst_smp, M1F14_EKST)
  // mrslt     := inieditspr(A__MENUVERT, glob_V009, m1rslt)
  // mishod    := inieditspr(A__MENUVERT, glob_V012, m1ishod)
  mrslt     := inieditspr(A__MENUVERT, getV009(), m1rslt)
  mishod    := inieditspr(A__MENUVERT, getV012(), m1ishod)
  mlpu      := inieditspr(A__POPUPMENU, dir_server + "mo_uch", m1lpu)
  motd      := inieditspr(A__POPUPMENU, dir_server + "mo_otd", m1otd)
  MKEMVYD   := inieditspr(A__POPUPMENU, dir_server + "s_kemvyd", M1KEMVYD)
  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mtip      := inieditspr(A__MENUVERT, mm_danet, m1tip)
  musluga   := inieditspr(A__MENUBIT,  mm_usluga,m1usluga)
  mismo     := init_ismo(m1ismo)
  if ibrm > 0
    mm_prer_b := iif(ibrm == 1, mm1prer_b, iif(ibrm == 2, mm2prer_b, mm3prer_b))
    if ibrm == 1 .and. m1prer_b == 0
      mprer_b := space(28)
    else
      mprer_b := inieditspr(A__MENUVERT, mm_prer_b, m1prer_b)
    endif
  endif
  if mem_smp_input == 1
    mvid_ud := inieditspr(A__MENUVERT, menu_vidud, m1vid_ud)
    madres_reg := ini_adres(1)
  endif
  f_valid_komu(,-1)
  if m1komu == 0
    m1company := int(val(msmo))
  elseif eq_any(m1komu,1,3)
    m1company := m1str_crb
  endif
  mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
  if m1company == 34
    if !empty(mismo)
      mcompany := padr(mismo,38)
    elseif !empty(mnameismo)
      mcompany := padr(mnameismo,38)
    endif
  endif
  if tip_lu == TIP_LU_SMP
    f_valid_brig(,-1,mm_brigada,mm_trombolit,st_brigada,st_trombolit)
    if m1tip == 0
      m1brig := m1brigada
    else
      m1brig := m1trombolit
    endif
    mbrig := inieditspr(A__MENUVERT, mm_brig, m1brig)
    str_1 := " случая оказания СМП"
  else
    --top2
    mspec := inieditspr(A__MENUVERT, mm_spec, m1spec)
    str_1 := " случая оказания неотложной медицинской помощи"
  endif
  if Loc_kod == 0
    str_1 := "Добавление"+str_1
    mtip_h := yes_vypisan
  else
    str_1 := "Редактирование"+str_1
  endif
  setcolor(color8)
  myclear(top2)
  @ top2-1,0 say padc(str_1,80) color "B/BG*"
  Private gl_area := {1,0,maxrow()-1,maxcol(),0}
  Private gl_arr := {;  // для битовых полей
    {"usluga", "N",10,0, ,, ,{|x|inieditspr(A__MENUBIT,mm_usluga,x)} };
   }
  @ maxrow(),0 say padc("<Esc> - выход;  <PgDn> - запись;  <F1> - помощь",maxcol()+1) color color0
  mark_keys({"<F1>", "<Esc>", "<PgDn>"}, "R/BG")
  setcolor(cDataCGet)
  make_diagP(1)  // сделать "шестизначные" диагнозы
  diag_screen(0)
  do while .t.
    j := top2
    if yes_num_lu == 1 .and. Loc_kod > 0
      @ j,50 say padl("Лист учета № "+lstr(Loc_kod),29) color color14
    endif
    //
    ++j; @ j,1 say "Учреждение" get mlpu when .f. color cDataCSay
         @ row(),col()+2 say "Отделение" get motd when .f. color cDataCSay
    //
  if tip_lu == TIP_LU_SMP
    ++j; @ j,1 say "Карта вызова: №" get much_doc picture "999999"
         @ row(),col() say ", дата выезда" get mn_data ;
               valid {|g| mk_data := mn_data, f_k_data(g,1)}
  else
    ++j; @ j,1 say "Карта №" get much_doc picture "999999"
         @ row(),col() say ", дата приёма" get mn_data ;
               valid {|g| mk_data := mn_data, f_k_data(g,1)}
  endif
    //
  if mem_smp_input == 0
    ++j; @ j,1 say "ФИО" get mfio_kart ;
         reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION, ,,.f.)} ;
         valid {|g,o| update_get("mkomu"),update_get("mcompany") }
  else
    ++j; @ j,1 say "Полис ОМС: серия" get mspolis when m1komu == 0
         @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0 ;
                         valid {|| findKartoteka(2,@mkod_k) }
         @ row(),col()+3 say "вид"    get mvidpolis ;
                      reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT, ,,.f.)} ;
                      when m1komu == 0 ;
                      valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
    //
    ++j ; @ j,1 say "Фамилия" get mfam pict "@S33" ;
                  valid {|g| lastkey()==K_UP .or. valFamImOt(1,mfam) }
      @ row(),col()+1 say "Имя" get mim pict "@S32" ;
                  valid {|g| valFamImOt(2,mim) }
    ++j ; @ j,1 say "Отчество" get mot ;
                  valid {|g| valFamImOt(3,mot) }
    if mem_pol == 1
      @ row(),70 say "Пол" get mpol ;
              reader {|x|menu_reader(x,menupol,A__MENUVERT, ,,.f.)}
    else
      @ row(),70 say "Пол" get mpol pict "@!" valid {|g| mpol $ "МЖ" }
    endif
    ++j ; @ j,1 say "Дата рождения" get mdate_r ;
           valid {|| fv_date_r(mn_data), findKartoteka(1,@mkod_k) }
    @ row(),30 say "==>" get mvzros_reb when .f. color cDataCSay
    @ row(),50 say "СНИЛС" get msnils pict picture_pf ;
           valid {|| val_snils(msnils,1), findKartoteka(3,@mkod_k) }
    ++j ; @ j,1 say "Уд-ие личности:" get mvid_ud ;
           reader {|x|menu_reader(x,menu_vidud,A__MENUVERT, ,,.f.)}
           @ j,42 say "Серия" get mser_ud pict "@!" valid val_ud_ser(1,m1vid_ud,mser_ud)
           @ j,col()+1 say "№" get mnom_ud pict "@!S18" valid val_ud_nom(1,m1vid_ud,mnom_ud)
    if tip_lu == TIP_LU_NMP
      ++j ; @ j,2 say "Место рождения" get mmesto_r pict "@S62"
      ++j ; @ j,2 say "Выдано" get mkogdavyd
            @ j,col() say ", " get mkemvyd ;
            reader {|x|menu_reader(x,{{|k,r,c|get_s_kemvyd(k,r,c)}},A__FUNCTION, ,,.f.)}
    endif
    ++j ; @ j,1 say "Адрес регистрации" get madres_reg ;
          reader {|x| menu_reader(x,{{|k,r,c| get_adres(1,k,r,c)}},A__FUNCTION, ,,.f.)}
  endif
    ++j; @ j,1 say "Принадлежность счёта" get mkomu ;
               reader {|x|menu_reader(x,mm_komu,A__MENUVERT, ,,.f.)} ;
               valid {|g,o| f_valid_komu(g,o) } ;
               color colget_menu
         @ row(),col()+1 say "==>" get mcompany ;
             reader {|x|menu_reader(x,mm_company,A__MENUVERT, ,,.f.)} ;
             when diag_screen(2) .and. m1komu < 5 ;
             valid {|g| func_valid_ismo(g,m1komu,38) }
    //
  if mem_smp_input == 0
    ++j; @ j,1 say "Полис ОМС: серия" get mspolis when m1komu == 0
         @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0
         @ row(),col()+3 say "вид"    get mvidpolis ;
                      reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT, ,,.f.)} ;
                      when m1komu == 0 ;
                      valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
  endif
    //
    ++j; @ j,1 say "Новорожденный?" get mnovor ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT, ,,.f.)} ;
               valid {|g,o| f_valid_novor(g,o) } ;
               color colget_menu
         @ row(),col()+3 say "№/пп ребёнка" get mcount_reb pict "99" range 1,99 ;
               when (m1novor == 1)
         @ row(),col()+3 say "Д.р. ребёнка" get mdate_r2 when (m1novor == 1)
    if mem_pol == 1
         @ row(),col()+3 say "Пол ребёнка" get mpol2 ;
             reader {|x|menu_reader(x,menupol,A__MENUVERT, ,,.f.)} ;
             when diag_screen(2) .and. (m1novor == 1)
    else
         @ row(),col()+3 say "Пол ребёнка" get mpol2 pict "@!" ;
             valid {|g| mpol2 $ "МЖ" } ;
             when diag_screen(2) .and. (m1novor == 1)
    endif
    //
    ++j; @ j,1 say "Диагноз(ы)" get mkod_diag picture pic_diag ;
               reader {|o|MyGetReader(o,bg)} ;
               when when_diag() ;
               valid {|| val1_10diag(.t.,.t.,.t.,mk_data,iif(m1novor==0,mpol,mpol2)), f_valid_beremenn(mkod_diag) }
         @ row(),col() say ", " get mkod_diag2 picture pic_diag ;
               reader {|o|MyGetReader(o,bg)} ;
               when when_diag() ;
               valid val1_10diag(.t.,.t.,.t.,mn_data,iif(m1novor==0,mpol,mpol2))
  if tip_lu == TIP_LU_SMP
         @ row(),col()+3 say "Форма оказания СМП" get MF14_EKST ;
              reader {|x|menu_reader(x,mm_ekst_smp,A__MENUVERT, ,,.f.)}
  endif
    ++j ; rdiag := j
    if (ibrm := f_oms_beremenn(mkod_diag)) == 1
         @ j,26 say "прерывание беременности"
    elseif ibrm == 2
         @ j,26 say "дисп.набл.за беременной"
    elseif ibrm == 3
         @ j,26 say "     боли при онкологии"
    endif
         @ j,51 get mprer_b ;
                reader {|x| menu_reader(x,mm_prer_b,A__MENUVERT, ,,.f.)} ;
                when {|| diag_screen(2),;
                         ibrm := f_oms_beremenn(mkod_diag),;
                         mm_prer_b := iif(ibrm == 1, mm1prer_b, iif(ibrm == 2, mm2prer_b, mm3prer_b)),;
                         (ibrm > 0) }
    //
    ++j; @ j,1 say "Результат обращения" get mrslt ;
             reader {|x|menu_reader(x,mm_rslt,A__MENUVERT, ,,.f.)} ;
             valid {|g,o| f_valid_rslt(g,o) }
    //
    ++j; @ j,1 say "Исход заболевания" get mishod ;
             reader {|x|menu_reader(x,mm_ishod,A__MENUVERT, ,,.f.)}
    //
  if tip_lu == TIP_LU_SMP
   if empty(mm_trombolit)
    ++j; @ j,1 say "Бригада СМП" get mbrig ;
              reader {|x|menu_reader(x,mm_brig,A__MENUVERT, ,,.f.)}
   else
    ++j; @ j,1 say "Тромболитическая терапия:" get mtip ;
              reader {|x|menu_reader(x,mm_danet,A__MENUVERT, ,,.f.)} ;
              valid {|g,o| f_valid_brig(g,o,mm_brigada,mm_trombolit,st_brigada,st_trombolit) }
         @ j,32 say "Бригада СМП" get mbrig ;
              reader {|x|menu_reader(x,mm_brig,A__MENUVERT, ,,.f.)}
   endif
   if mem_smp_tel == 1
    ++j; @ j,1 say "Услуга(и) телемедицины" get musluga ;
               reader {|x| menu_reader(x,mm_usluga,A__MENUBIT, ,,.f.)}
   endif
  else
    ++j; @ j,1 say "Врач (фельдшер)" get mspec ;
              reader {|x|menu_reader(x,mm_spec,A__MENUVERT, ,,.f.)}
  endif
    //
    ++j; @ j,1 say "Таб.№ врача (фельдшера)" get MTAB_NOM pict "99999" ;
               valid {|g| v_kart_vrach(g,.t.) } when diag_screen(2)
         @ row(),col()+1 get mvrach when .f. color color14
    if !empty(a_smert)
      n_message(a_smert, , "GR+/R", "W+/R", ,, "G+/R")
    endif
    if pos_read > 0 .and. lower(GetList[pos_read]:name) == "mvrach"
      --pos_read
    endif
    count_edit := myread(,@pos_read,++k_read)
    diag_screen(2)
    k := f_alert({padc('Выберите действие', 60, '.')}, ;
                 {' Выход без записи ', ' Запись ', ' Возврат в редактирование '}, ;
                 iif(lastkey() == K_ESC, 1, 2), 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N,N/BG' )
    if k == 3
      loop
    elseif k == 2
      if empty(much_doc)
        func_error(4,'Не заполнен номер карты'+iif(tip_lu==TIP_LU_SMP,' вызова',''))
        loop
      endif
      if empty(mn_data)
        func_error(4,'Не введена дата '+iif(tip_lu==TIP_LU_SMP,'выезда.','приёма.'))
        loop
      elseif tip_lu == TIP_LU_SMP .and. year(mn_data) < 2016 .and. m1tip == 1
        func_error(4, "Тромболитическая терапия разрешена только с 2016 года.")
        loop
      endif
      if m1komu < 5 .and. empty(m1company)
        if m1komu == 0     ; s := "СМО"
        elseif m1komu == 1 ; s := "компании"
        else               ; s := "комитета/МО"
        endif
        func_error(4,'Не заполнено наименование '+s)
        loop
      endif
      if m1komu == 0 .and. empty(mnpolis)
        func_error(4,'Не заполнен номер полиса')
        loop
      endif
      if mem_smp_input == 1
        if empty(mfio)
          func_error(4, "Не введены Ф.И.О. Нет записи!")
          loop
        endif
        if empty(mdate_r)
          func_error(4,'Не заполнена дата рождения')
          loop
        endif
        if tip_lu == TIP_LU_NMP .and. eq_any(m1vid_ud,3,14) .and. ;
                                            !empty(mser_ud) .and. empty(del_spec_symbol(mmesto_r))
          func_error(4,iif(m1vid_ud==3,'Для свид-ва о рождении','Для паспорта РФ')+;
                       ' обязательно заполнение поля "Место рождения"')
          loop
        endif
      endif
      if empty(mkod_diag)
        func_error(4, "Не введен шифр основного заболевания.")
        loop
      endif
      err_date_diap(mn_data, "Дата выезда")
      if mem_op_out == 2 .and. yes_parol
        box_shadow(19,10,22,69,cColorStMsg)
        str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
        str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
      endif
      mywait()
      make_diagP(2)  // сделать "пятизначные" диагнозы
      if m1komu == 0
        msmo := lstr(m1company)
        m1str_crb := 0
      else
        msmo := ""
        m1str_crb := m1company
      endif
      Private old_vzros_reb := M1VZROS_REB
      fv_date_r(MN_DATA) // переопределение M1VZROS_REB
      if tip_lu == TIP_LU_SMP // определяем шифр услуги СМП
        lshifr := "71."
        if m1tip == 0
          if (is_komm_SMP() .and. mk_data < 0d20190501) .or. (is_komm_SMP() .and. mk_data >= 0d20220101)// если это коммерческая скорая
            lshifr += "2."
          elseif m1komu == 0
            if len(alltrim(msmo)) == 5 .and. left(msmo,2) == '34'
              lshifr += "1."
            else
              lshifr += "2."
            endif
          else
            lshifr += "1."
          endif
          lshifr += m1brig
          st_brigada := m1brig
        else // тромболитическая терапия
          lshifr += "3."+m1brig
          st_trombolit := m1brig
          M1F14_EKST := 1 // экстренная
        endif
      else // определяем шифр услуги НМП
        lshifr := iif(m1spec == 1, "2.80.27", "2.80.28")
      endif
      lshifr := padr(lshifr,10)
      //
      Use_base("lusl")
      Use_base("luslc")
      Use_base("uslugi")
      R_Use(dir_server + "uslugi1",{dir_server + "uslugi1",;
                                  dir_server + "uslugi1s"}, "USL1")
      Private mu_kod, mu_cena
      glob_podr := "" ; glob_otd_dep := 0
      mu_kod := foundOurUsluga(lshifr,mk_data,m1PROFIL,M1VZROS_REB,@mu_cena)
      if mem_smp_input == 1
        mfio := rtrim(mfam)+ " "+rtrim(mim)+ " "+mot
        if TwoWordFamImOt(mfam) .or. TwoWordFamImOt(mim) .or. TwoWordFamImOt(mot)
          newMEST_INOG := 9
        endif
        Use_base("kartotek")
        if mkod_k == 0  // добавление в картотеку
          Add1Rec(7)
          glob_kartotek := mkod_k := kart->kod := recno()
        else
          find (str(mkod_k,7))
          if found()
            G_RLock(forever)
          else
            Add1Rec(7)
            glob_kartotek := mkod_k := kart->kod := recno()
          endif
        endif
        glob_k_fio := alltrim(mfio)
        //
        kart->FIO       := mfio
        kart->pol       := mpol
        kart->DATE_R    := mdate_r
        kart->VZROS_REB := old_vzros_reb
        kart->ADRES     := mADRES
        kart->POLIS     := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
        kart->snils     := msnils
        kart->KOMU      := m1KOMU
        kart->STR_CRB   := m1str_crb
        kart->MI_GIT    := 9
        kart->MEST_INOG := newMEST_INOG
        //
        select KART2
        do while kart2->(lastrec()) < mkod_k
          APPEND BLANK
        enddo
        //
        select KART_
        do while kart_->(lastrec()) < mkod_k
          APPEND BLANK
        enddo
        goto (mkod_k)
        G_RLock(forever)
        kart_->VPOLIS := m1vidpolis
        kart_->SPOLIS := mSPOLIS
        kart_->NPOLIS := mNPOLIS
        kart_->SMO    := msmo
        kart_->vid_ud := m1vid_ud
        kart_->ser_ud := mser_ud
        kart_->nom_ud := mnom_ud
        if tip_lu == TIP_LU_NMP
          kart_->mesto_r  := mmesto_r
          kart_->kemvyd   := m1kemvyd
          kart_->kogdavyd := mkogdavyd
        endif
        kart_->okatog := mokatog
        Private fl_nameismo := .f.
        if m1komu == 0 .and. m1company == 34
          kart_->KVARTAL_D := m1okato // ОКАТО субъекта РФ территории страхования
          if empty(m1ismo)
            if !empty(mnameismo)
              fl_nameismo := .t.
            endif
          else
            kart_->SMO := m1ismo  // заменяем "34" на код иногородней СМО
          endif
        endif
        if m1MEST_INOG == 9 .or. newMEST_INOG == 9
          G_Use(dir_server + "mo_kfio", , "KFIO")
          index on str(kod,7) to (cur_dir + "tmp_kfio")
          find (str(mkod_k,7))
          if found()
            if newMEST_INOG == 9
              G_RLock(forever)
              kfio->FAM := mFAM
              kfio->IM  := mIM
              kfio->OT  := mOT
            else
              DeleteRec(.t.)
            endif
          else
            if newMEST_INOG == 9
              AddRec(7)
              kfio->kod := mkod_k
              kfio->FAM := mFAM
              kfio->IM  := mIM
              kfio->OT  := mOT
            endif
          endif
        endif
        if fl_nameismo .or. rec_inogSMO > 0
          G_Use(dir_server + "mo_kismo", , "SN")
          index on str(kod,7) to (cur_dir + "tmp_ismo")
          find (str(mkod_k,7))
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
              sn->kod := mkod_k
              sn->smo_name := mnameismo
            endif
          endif
          sn->(dbCloseArea())
        endif
      endif
      Use_base("human")
      if Loc_kod > 0
        find (str(Loc_kod,7))
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
      if isbit(mem_oms_pole,1)  //  "сроки лечения",;  1
        st_N_DATA := MN_DATA
      endif
      if isbit(mem_oms_pole,2)  //  "леч.врач",;       2
        st_VRACH := m1vrach
      endif
      if isbit(mem_oms_pole,3)  //  "осн.диагноз",;    3
        SKOD_DIAG := substr(MKOD_DIAG,1,5)
      endif
      if isbit(mem_oms_pole,5)  //  "результат",;      5
        st_RSLT := m1rslt
      endif
      if isbit(mem_oms_pole,6)  //  "исход",;          6
        st_ISHOD := m1ishod
      endif
      st_brigada := m1brigada
      glob_perso := mkod
      //
      human->kod_k      := mkod_k
      human->TIP_H      := B_STANDART
      human->FIO        := MFIO          // Ф.И.О. больного
      human->POL        := MPOL          // пол
      human->DATE_R     := MDATE_R       // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
      human->ADRES      := MADRES        // адрес больного
      human->KOD_DIAG   := MKOD_DIAG     // шифр 1-ой осн.болезни
      human->KOD_DIAG2  := MKOD_DIAG2    // шифр 2-ой осн.болезни
      human->KOD_DIAG3  := MKOD_DIAG3    // шифр 3-ой осн.болезни
      human->KOD_DIAG4  := MKOD_DIAG4    // шифр 4-ой осн.болезни
      human->SOPUT_B1   := MSOPUT_B1     // шифр 1-ой сопутствующей болезни
      human->SOPUT_B2   := MSOPUT_B2     // шифр 2-ой сопутствующей болезни
      human->SOPUT_B3   := MSOPUT_B3     // шифр 3-ой сопутствующей болезни
      human->SOPUT_B4   := MSOPUT_B4     // шифр 4-ой сопутствующей болезни
      human->diag_plus  := mdiag_plus    //
      human->KOMU       := M1KOMU        // от 0 до 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis(mspolis,mnpolis) // серия и номер страхового полиса
      human->LPU        := M1LPU         // код учреждения
      human->OTD        := M1OTD         // код отделения
      human->UCH_DOC    := lstr(MUCH_DOC) // вид и номер учетного документа
      human->N_DATA := human->K_DATA := MN_DATA // дата начала-окончания лечения
      human->CENA := human->CENA_1 := mu_cena // стоимость лечения
      human_->DISPANS   := replicate("0",16)
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := ltrim(mspolis)
      human_->NPOLIS    := ltrim(mnpolis)
      human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
      human_->NOVOR     := iif(m1novor==0, 0       , mcount_reb)
      human_->DATE_R2   := iif(m1novor==0, ctod(""), mDATE_R2  )
      human_->POL2      := iif(m1novor==0, ""      , mpol2     )
      human_->USL_OK    := m1USL_OK //  4
      human_->VIDPOM    := m1VIDPOM //  2
      human_->PROFIL    := m1PROFIL // 84
      human_->IDSP      := m1IDSP   // 24
      human_->FORMA14   := str(M1F14_EKST,1)+ "000"
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      if Loc_kod == 0  // при добавлении
        human_->ID_PAC    := mo_guid(1,human_->(recno()))
        human_->ID_C      := mo_guid(2,human_->(recno()))
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
      if f_oms_beremenn(mkod_diag) > 0
        human_2->PN2 := m1prer_b
      endif
      Private fl_nameismo := .f.
      if m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ОКАТО субъекта РФ территории страхования
        if empty(m1ismo)
          if !empty(mnameismo)
            fl_nameismo := .t.
          endif
        else
          human_->SMO := m1ismo  // заменяем "34" на код иногородней СМО
        endif
      endif
      if fl_nameismo .or. rec_inogSMO > 0
        G_Use(dir_server + "mo_hismo", , "SN")
        index on str(kod,7) to (cur_dir + "tmp_ismo")
        find (str(mkod,7))
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
      use_base("human_u")
      select HU
      if mrec_hu == 0
        Add1Rec(7)
        mrec_hu := hu->(recno())
      else
        goto (mrec_hu)
        G_RLock(forever)
      endif
      replace hu->kod     with human->kod,;
              hu->kod_vr  with m1vrach,;
              hu->kod_as  with 0,;
              hu->u_koef  with 1,;
              hu->u_kod   with mu_kod,;
              hu->u_cena  with mu_cena,;
              hu->is_edit with 0,;
              hu->date_u  with dtoc4(MK_DATA),;
              hu->otd     with m1otd,;
              hu->kol     with 1,;
              hu->stoim   with mu_cena,;
              hu->kol_1   with 1,;
              hu->stoim_1 with mu_cena,;
              hu->KOL_RCP with 0
      select HU_
      do while hu_->(lastrec()) < mrec_hu
        APPEND BLANK
      enddo
      goto (mrec_hu)
      G_RLock(forever)
      if Loc_kod == 0 .or. !valid_GUID(hu_->ID_U)
        hu_->ID_U := mo_guid(3,hu_->(recno()))
      endif
      hu_->PROFIL   := m1PROFIL
      hu_->PRVS     := m1PRVS
      hu_->kod_diag := mkod_diag
      hu_->zf       := ""
      //
      if mem_smp_tel == 1 .and. (len(arr_usluga) > 0 .or. m1usluga > 0)
        for i := 1 to 2
          j := ascan(arr_usluga,{|x| x[1] == i })
          if isbit(m1usluga,i)
            if j == 0
              aadd(arr_usluga, {i,0})
            endif
          else
            if j > 0
              arr_usluga[j,1] := 0
            endif
          endif
        next
        use_base("luslf")
        Use_base("mo_su")
        Use_base("mo_hu")
        for i := 1 to len(arr_usluga)
          if arr_usluga[i,1] > 0
            kod_uslf := 0
            lshifr := iif(arr_usluga[i,1] == 1, "A05.10.004.001", "B01.015.007")
            select MOSU
            set order to 3 // по шифру ФФОМС
            find (padr(lshifr,20))
            if found()
              kod_uslf := mosu->kod
            else
              select LUSLF
              find (padr(lshifr,20))
              if found()
                select MOSU
                set order to 1
                FIND (STR(-1,6))
                if found()
                  G_RLock(forever)
                else
                  AddRec(6)
                endif
                kod_uslf := mosu->kod := recno()
                mosu->name := luslf->name
                mosu->shifr1 := lshifr
                mosu->PROFIL := 0
              endif
            endif
            if !empty(kod_uslf)
              select MOHU
              if arr_usluga[i,2] > 0
                goto (arr_usluga[i,2])
                G_RLock(forever)
              else
                Add1Rec(7)
              endif
              mohu->kod     := human->kod
              mohu->kod_vr  := 0
              mohu->u_kod   := kod_uslf
              mohu->u_cena  := 0
              mohu->date_u  := dtoc4(MK_DATA)
              mohu->date_u2 := dtoc4(MK_DATA)
              mohu->otd     := m1otd
              mohu->kol_1   := 1
              mohu->stoim_1 := 0
              mohu->ID_U    := mo_guid(4,mohu->(recno()))
              mohu->PROFIL  := m1PROFIL
              mohu->PRVS    := m1PRVS
              mohu->kod_diag:= mkod_diag
            endif
          else
            select MOHU
            if arr_usluga[i,2] > 0
              goto (arr_usluga[i,2])
              DeleteRec(.t.)
            endif
          endif
        next i
      endif
      //
      write_work_oper(glob_task,OPER_LIST,iif(Loc_kod==0,1,2),1,count_edit)
      fl_write_sluch := .t.
      close databases
      stat_msg("Запись завершена!",.f.)
    endif
    exit
  enddo
  close databases
  diag_screen(2)
  setcolor(tmp_color)
  restscreen(buf)
  chm_help_code := tmp_help
  if fl_write_sluch // если записали - запускаем проверку
    if type("fl_edit_smp") == "L"
      fl_edit_smp := .t.
    endif
    if !empty(val(msmo))
      verify_OMS_sluch(glob_perso)
    endif
  endif
  return NIL
  
***** 26.01.16 действия в ответ на выбор в меню "Тромболитическая терапия:"
Function f_valid_brig_1(get,old,menu1,menu2,st1,st2)
if m1tip != old .and. old != NIL
  mm_brig := {}
  if m1tip == 0 //
    mm_brig := aclone(menu1)
    m1brig := st1
  else
    mm_brig := aclone(menu2)
    m1brig := st2
  endif
  mbrig := padr(inieditspr(A__MENUVERT, mm_brig, m1brig),40)
  update_get("mbrig")
endif
return .t.

