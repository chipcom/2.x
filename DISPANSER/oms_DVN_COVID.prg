#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 25.07.21 ДВН - добавление или редактирование случая (листа учета)
Function oms_sluch_DVN_COVID(Loc_kod,kod_kartotek,f_print)
  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  // f_print - наименование функции для печати
  Static sadiag1 := {}
  Static st_N_DATA, st_K_DATA, s1dispans := 1
  
  Local bg := {|o,k| get_MKB10(o,k,.t.) }, arr_del := {}, mrec_hu := 0, mrec_mohu := 0,;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
      p_uch_doc := "@!", pic_diag := "@K@!", arr_usl := {}, ah,;
      i, j, k, s, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0, ar, larr, lu_kod,;
      fl, tmp_help := chm_help_code, fl_write_sluch := .f., mu_cena, lrslt_1_etap := 0

  local iUslDop := iUslOtkaz := iUslOtklon := 0   // счетчики

  //
  Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
  Default Loc_kod TO 0, kod_kartotek TO 0
  //
  Private oms_sluch_DVN := .t., ps1dispans := s1dispans, is_prazdnik

  if kod_kartotek == 0 // добавление в картотеку
    if (kod_kartotek := edit_kartotek(0,,,.t.)) == 0
      return NIL
    endif
  elseif Loc_kod > 0
    R_Use(dir_server+"human",,"HUMAN")
    goto (Loc_kod)
    fl := (human->k_data < 0d20210701)
    Use
    if fl
      return func_error(4,"Углубленная диспансеризация после COVID началась 01 июля 2021 году")
    endif
  endif

  if empty(sadiag1)
    Private file_form, diag1 := {}, len_diag := 0
    if (file_form := search_file("DISP_NAB"+sfrm)) == NIL
      func_error(4,"Не обнаружен файл DISP_NAB"+sfrm)
    endif
    f2_vvod_disp_nabl("A00")
    sadiag1 := diag1
  endif

  chm_help_code := 3002

  Private mfio := space(50), mpol, mdate_r, madres, mvozrast, ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0,;
    m1company := 0, mcompany, mm_company,;
    mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
    msmo := "34007", rec_inogSMO := 0,;
    mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
    mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
    // mdvozrast,
  Private mkod := Loc_kod, is_talon := .f., mshifr_zs := "",;
    mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
    M1LPU := glob_uch[1], MLPU,;
    M1OTD := glob_otd[1], MOTD,;
    M1FIO_KART := 1, MFIO_KART,;
    MRAB_NERAB, M1RAB_NERAB := 0,; // 0-работающий, 1 -неработающий
    MUCH_DOC    := space(10)         ,; // вид и номер учетного документа
    MKOD_DIAG   := space(5)          ,; // шифр 1-ой осн.болезни
    MKOD_DIAG2  := space(5)          ,; // шифр 2-ой осн.болезни
    MKOD_DIAG3  := space(5)          ,; // шифр 3-ой осн.болезни
    MKOD_DIAG4  := space(5)          ,; // шифр 4-ой осн.болезни
    MSOPUT_B1   := space(5)          ,; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := space(5)          ,; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := space(5)          ,; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := space(5)          ,; // шифр 4-ой сопутствующей болезни
    MDIAG_PLUS  := space(8)          ,; // дополнения к диагнозам
    adiag_talon[16]                  ,; // из статталона к диагнозам
    m1rslt  := 317      ,; // результат (присвоена I группа здоровья)
    m1ishod := 306      ,; // исход = осмотр
    MN_DATA := st_N_DATA         ,; // дата начала лечения
    MK_DATA := st_K_DATA         ,; // дата окончания лечения
    MVRACH := space(10)         ,; // фамилия и инициалы лечащего врача
    M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
    m1povod  := 4,;   // Профилактический
    m1travma := 0, ;
    m1USL_OK :=  3,; // поликлиника
    m1VIDPOM :=  1,; // первичная
    m1PROFIL := 97,; // 97-терапия,57-общая врач.практика (семейн.мед-а),42-лечебное дело
    m1IDSP   := 11,; // доп.диспансеризация
    mmobilbr, m1mobilbr := 0,;  // мобильная бригада
    mcena_1 := 0
  //
  Private arr_usl_dop := {}, arr_usl_otkaz := {}, arr_otklon := {}, m1p_otk := 0
  Private metap := 1,;  // 1-первый этап, 2-второй этап (по умолчанию 1 этап)
    mnapr_onk := space(10), m1napr_onk := 0,;
    mOKSI := 0,;  // данные оксиметра %
    mDateCOVID := sys_date,;  // дата окончания лечения COVID
    mgruppa, m1gruppa := 9,;      // группа здоровья
    mdyspnea, m1dyspnea := 0 //
    // m1ndisp := 1, mndisp,;
  Private mdispans, m1dispans := 0, mnazn_l , m1nazn_l  := 0,;
    mdopo_na, m1dopo_na := 0, mssh_na , m1ssh_na  := 0,;
    mspec_na, m1spec_na := 0, msank_na, m1sank_na := 0
  Private mvar, m1var // переменный для организации ввода ин-ции в табличной части
  Private mm_ndisp := {{"Углубленная диспансеризация I  этап",1},;
                       {"Углубленная диспансеризация II этап",2}}
  private mm_strong := {{'Легкое течение болезни',1},;
                        {'Среднее течение болезни',2},;
                        {'Тяжелое течение болезни',3},;
                        {'Крайне тяжелое течение',4}}
  private mstrong, m1strong := 1

  Private mm_gruppa, mm_ndisp1
  // Private is_disp_19 := .t.

  mm_ndisp1 := aclone(mm_ndisp)

  Private mm_gruppaP := {{"Присвоена I группа здоровья"   ,1,343},;
      {"Присвоена II группа здоровья"  ,2,344},;
      {"Присвоена III группа здоровья" ,3,345},;
      {"Присвоена IIIа группа здоровья",3,373},;
      {"Присвоена IIIб группа здоровья",4,374};
    }
  Private mm_gruppaD1 := {;
      {"Проведена диспансеризация - присвоена I группа здоровья"   ,1,317},;
      {"Проведена диспансеризация - присвоена II группа здоровья"  ,2,318},;
      {"Проведена диспансеризация - присвоена IIIа группа здоровья",3,355},;
      {"Проведена диспансеризация - присвоена IIIб группа здоровья",4,356},;
      {"Направлен на 2 этап, предварительно присвоена I группа здоровья"   ,11,352},;
      {"Направлен на 2 этап, предварительно присвоена II группа здоровья"  ,12,353},;
      {"Направлен на 2 этап, предварительно присвоена IIIа группа здоровья",13,357},;
      {"Направлен на 2 этап, предварительно присвоена IIIб группа здоровья",14,358};
    }
  Private mm_gruppaD2 := aclone(mm_gruppaD1)
  asize(mm_gruppaD2,4)
  Private mm_otkaz := {{"_выполнено",0},;
                       {"отклонение",3},;
                       {"ОТКАЗ пац.",1},;
                       {"НЕВОЗМОЖНО",2}}
  Private mm_otkaz1 := aclone(mm_otkaz)
  asize(mm_otkaz1,3)
  Private mm_otkaz0 := aclone(mm_otkaz)
  asize(mm_otkaz0,2)

  Private mm_pervich := {{"впервые     ",1},;
                          {"ранее выявл.",0},;
                          {"пред.диагноз",2}}
  Private mm_dispans := {{"не установлено             ",0},;
                      {"участковым терапевтом      ",3},;
                      {"врачом отд.мед.профилактики",1},;
                      {"врачом центра здоровья     ",2}}
  Private mm_dopo_na := {{"лаб.диагностика",1},{"инстр.диагностика",2},{"лучевая диагностика",3},{"КТ, МРТ, ангиография",4}}
  Private gl_arr := {;  // для битовых полей
    {"dopo_na","N",10,0,,,,{|x|inieditspr(A__MENUBIT,mm_dopo_na,x)} };
  }
  Private mnapr_v_mo, m1napr_v_mo := 0, ;
    mm_napr_v_mo := {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
    arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
  Private mnapr_stac, m1napr_stac := 0, ;
    mm_napr_stac := {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
    mprofil_stac, m1profil_stac := 0
  Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0

  private mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

////// РАЗОБРАТЬСЯ С НАПРАВЛЕНИЯМИ
  Private mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0

  Private pole_diag, pole_pervich, pole_1pervich, pole_d_diag, ;
    pole_stadia, pole_dispans, pole_1dispans, pole_d_dispans, pole_dn_dispans

  for i := 1 to 5
    sk := lstr(i)
    pole_diag := "mdiag"+sk
    pole_d_diag := "mddiag"+sk
    pole_pervich := "mpervich"+sk
    pole_1pervich := "m1pervich"+sk
    pole_stadia := "m1stadia"+sk
    pole_dispans := "mdispans"+sk
    pole_1dispans := "m1dispans"+sk
    pole_d_dispans := "mddispans"+sk
    pole_dn_dispans := "mdndispans"+sk
    Private &pole_diag := space(6)
    Private &pole_d_diag := ctod("")
    Private &pole_pervich := space(7)
    Private &pole_1pervich := 0
    Private &pole_stadia := 1
    Private &pole_dispans := space(10)
    Private &pole_1dispans := 0
    Private &pole_d_dispans := ctod("")
    Private &pole_dn_dispans := ctod("")
  next

  for i := 1 to len(ret_arrays_disp_COVID())  // создадим поля ввода для всех возможных услуг диспансеризации
    mvar := "MTAB_NOMv"+lstr(i)
    Private &mvar := 0
    mvar := "MTAB_NOMa"+lstr(i)
    Private &mvar := 0
    mvar := "MDATE"+lstr(i)
    Private &mvar := ctod("")
    mvar := "MKOD_DIAG"+lstr(i)
    Private &mvar := space(6)
    mvar := "MOTKAZ"+lstr(i)
    Private &mvar := mm_otkaz[1,1]
    mvar := "M1OTKAZ"+lstr(i)
    Private &mvar := mm_otkaz[1,2]
  next
  //
  afill(adiag_talon,0)

  R_Use(dir_server+"human_2",,"HUMAN_2")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_, to recno() into HUMAN_2

  if mkod_k > 0
    R_Use(dir_server+"kartote2",,"KART2")
    goto (mkod_k)
    R_Use(dir_server+"kartote_",,"KART_")
    goto (mkod_k)
    R_Use(dir_server+"kartotek",,"KART")
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
    m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
    msmo        := kart_->SMO
    m1MO_PR     := kart2->MO_PR
    if kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    endif
    if eq_any(is_uchastok,1,3)
      MUCH_DOC := padr(amb_kartaN(),10)
    elseif mem_kodkrt == 2
      MUCH_DOC := padr(lstr(mkod_k),10)
    endif
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(1,,.t.) // открыть и закрыть
    endif
    // проверка исхода = СМЕРТЬ
    ah := {}
    select HUMAN
    set index to (dir_server+"humankk")
    find (str(mkod_k,7))
    do while human->kod_k == mkod_k .and. !eof()
      if human_->oplata != 9 .and. human_->NOVOR == 0 .and. recno() != Loc_kod
        if is_death(human_->RSLT_NEW) .and. empty(a_smert)
          a_smert := {"Данный больной умер!",;
                      "Лечение с "+full_date(human->N_DATA)+" по "+full_date(human->K_DATA)}
        endif
        if between(human->ishod,401,402)
          aadd(ah,{human->(recno()),human->K_DATA})
        endif
      endif
      select HUMAN
      skip
    enddo
    set index to
    if len(ah) > 0
      asort(ah,,,{|x,y| x[2] < y[2] })
      select HUMAN
      goto (atail(ah)[1])
      M1RAB_NERAB := human->RAB_NERAB // 0-работающий, 1-неработающий, 2-обучающ.ОЧНО
      letap := human->ishod - 400
      if eq_any(letap,1,2)
        lrslt_1_etap := human_->RSLT_NEW
      endif
      read_arr_DVN_COVID(human->kod,.f.)  // читаем сохраненные данные по углубленной диспансеризации

    endif
  endif
  
  if Loc_kod > 0  // читаем информацию из HUMAN, HUMAN_U и MO_HU и заполним табличную часть
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
    M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий, 2-обучающ.ОЧНО
    mUCH_DOC    := human->uch_doc
    m1VRACH     := human_->vrach
    MPOLIS      := human->POLIS         // серия и номер страхового полиса
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
    m1rslt     := human_->RSLT_NEW
    //
    is_prazdnik := f_is_prazdnik_DVN_COVID(mn_data)

    metap := human->ishod-400   // получим сохраненный этап диспансеризации

    // mdvozrast := year(mn_data) - year(mdate_r)
    if between(metap,1,2)
      mm_gruppa := {mm_gruppaD1,mm_gruppaD2}[metap]
      if (i := ascan(mm_gruppa, {|x| x[3] == m1rslt })) > 0
        m1GRUPPA := mm_gruppa[i,2]
      endif
    endif
    //
    // выбираем иформацию об услугах
    larr := array(2, len(uslugiEtap_DVN_COVID(metap)))
    arr_usl := {} // array(len(uslugiEtap_DVN_COVID(metap)))
    afillall(larr,0)
    // afillall(arr_usl,0)
    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"mo_su",,"MOSU")
    use_base("mo_hu")
    use_base("human_u")

    // сначала выберем информацию из human_u по услугам ТФОМС
    find (str(Loc_kod,7))
    do while hu->kod == Loc_kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
        lshifr := usl->shifr
      endif
      lshifr := alltrim(lshifr)
      for i := 1 to len(uslugiEtap_DVN_COVID(metap))
        if empty(larr[1,i])
          if valtype(uslugiEtap_DVN_COVID(metap)[i,2]) == "C" .and. uslugiEtap_DVN_COVID(metap)[i,12] == 0  // услуга ТФОМС
            if uslugiEtap_DVN_COVID(metap)[i,2] == lshifr
              fl := .f.
              larr[1,i] := hu->(recno())
              larr[2,i] := lshifr
              // arr_usl[i] := hu->(recno())
              aadd(arr_usl, hu->(recno()))

              if valtype(uslugiEtap_DVN_COVID(metap)[i,13]) == "C" .and. !empty(uslugiEtap_DVN_COVID(metap)[i,13])
                select MOHU
                set relation to u_kod into MOSU 
                find (str(Loc_kod,7))
                do while MOHU->kod == Loc_kod .and. !eof()
                  MOSU->(dbGoto(MOHU->u_kod))
                  lshifr := alltrim(iif(empty(MOSU->shifr),MOSU->shifr1,MOSU->shifr))
                  if lshifr == uslugiEtap_DVN_COVID(metap)[i,13]
                    aadd(arr_usl, MOHU->(recno()))
                  endif

                  // for i := 1 to len(uslugiEtap_DVN_COVID(metap))
                  //   if empty(larr[1,i])
                  //     if valtype(uslugiEtap_DVN_COVID(metap)[i,2]) == "C" .and. uslugiEtap_DVN_COVID(metap)[i,12] == 1  // услуга ФФОМС
                  //       if uslugiEtap_DVN_COVID(metap)[i,2] == lshifr
                  //         fl := .f.
                  //         larr[1,i] := MOHU->(recno())
                  //         larr[2,i] := lshifr
                  //         arr_usl[i] := MOHU->(recno())
                  //       endif
                  //     endif
                  //   endif
                  // next
                  select MOHU
                  skip
                enddo
                SELECT HU
              endif
            endif
          endif
        endif
      next
      select HU
      skip
    enddo

    // затем выберем информацию из mo_hu по услугам ФФОМС
    select MOHU
    set relation to u_kod into MOSU 
    find (str(Loc_kod,7))
    do while MOHU->kod == Loc_kod .and. !eof()
      MOSU->(dbGoto(MOHU->u_kod))
      lshifr := alltrim(iif(empty(MOSU->shifr),MOSU->shifr1,MOSU->shifr))
      for i := 1 to len(uslugiEtap_DVN_COVID(metap))
        if empty(larr[1,i])
          if valtype(uslugiEtap_DVN_COVID(metap)[i,2]) == "C" .and. uslugiEtap_DVN_COVID(metap)[i,12] == 1  // услуга ФФОМС
            if uslugiEtap_DVN_COVID(metap)[i,2] == lshifr
              fl := .f.
              larr[1,i] := MOHU->(recno())
              larr[2,i] := lshifr
              // arr_usl[i] := MOHU->(recno())
              aadd(arr_usl, MOHU->(recno()))
            endif
          endif
        endif
      next
      select MOHU
      skip
    enddo
    //
    read_arr_DVN_COVID(Loc_kod)

    if metap == 1 .and. between(m1GRUPPA,11,14) .and. m1p_otk == 1
      m1GRUPPA += 10
    endif
    R_Use(dir_server+"mo_pers",,"P2")
    for i := 1 to len(larr[1])
      if ( valtype(larr[2,i]) == "C" ) .and. ( ! eq_any(SubStr(larr[2,i],1,1), 'A', 'B') )  // это услуга ТФОМС, а не ФФОМС (первый символ не A,B)
        if larr[2,i] == '70.8.1'  // пропустим эту услугу
          loop
        endif
        hu->(dbGoto(larr[1,i]))
        if hu->kod_vr > 0
          p2->(dbGoto(hu->kod_vr))
          mvar := "MTAB_NOMv"+lstr(i)
          &mvar := p2->tab_nom
        endif
        if hu->kod_as > 0
          p2->(dbGoto(hu->kod_as))
          mvar := "MTAB_NOMa"+lstr(i)
          &mvar := p2->tab_nom
        endif
        mvar := "MDATE"+lstr(i)
        &mvar := c4tod(hu->date_u)
        if !empty(hu_->kod_diag) .and. !(left(hu_->kod_diag,1)=="U")
          mvar := "MKOD_DIAG"+lstr(i)
          &mvar := hu_->kod_diag
        endif
        m1var := "M1OTKAZ"+lstr(i)
        &m1var := 0 // выполнено
        if valtype(uslugiEtap_DVN_COVID(metap)[i,2]) == "C"
          if ascan(arr_otklon,uslugiEtap_DVN_COVID(metap)[i,2]) > 0
            &m1var := 3 // выполнено, обнаружены отклонения
          endif
        endif
        mvar := "MOTKAZ"+lstr(i)
        &mvar := inieditspr(A__MENUVERT, mm_otkaz, &m1var)
      elseif ( valtype(larr[2,i]) == "C" ) .and. ( eq_any(SubStr(larr[2,i],1,1), 'A', 'B') )  // это услуга ФФОМС (первый символ A,B)
        MOHU->(dbGoto(larr[1,i]))
        if MOHU->kod_vr > 0
          p2->(dbGoto(MOHU->kod_vr))
          mvar := "MTAB_NOMv"+lstr(i)
          &mvar := p2->tab_nom
        endif
        if MOHU->kod_as > 0
          p2->(dbGoto(MOHU->kod_as))
          mvar := "MTAB_NOMa"+lstr(i)
          &mvar := p2->tab_nom
        endif
        mvar := "MDATE"+lstr(i)
        &mvar := c4tod(MOHU->date_u)
        if !empty(MOHU->kod_diag) .and. !(left(MOHU->kod_diag,1)=="U")
          mvar := "MKOD_DIAG"+lstr(i)
          &mvar := hu_->kod_diag
        endif
        m1var := "M1OTKAZ"+lstr(i)
        &m1var := 0 // выполнено
        if valtype(uslugiEtap_DVN_COVID(metap)[i,2]) == "C"
          if ascan(arr_otklon,uslugiEtap_DVN_COVID(metap)[i,2]) > 0
            &m1var := 3 // выполнено, обнаружены отклонения
          endif
        endif
        mvar := "MOTKAZ"+lstr(i)
        &mvar := inieditspr(A__MENUVERT, mm_otkaz, &m1var)
      endif
    next
    if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2,@rec_inogSMO,.t.) // открыть и закрыть
    endif
    if valtype(arr_usl_otkaz) == "A"
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == "A" .and. len(ar) >= 5 .and. valtype(ar[5]) == "C"
          lshifr := alltrim(ar[5])
          
          for i := 1 to len(uslugiEtap_DVN_COVID(metap))
            if valtype(uslugiEtap_DVN_COVID(metap)[i,2]) == "C" .and. ;
                (uslugiEtap_DVN_COVID(metap)[i,2] == lshifr)
              if valtype(ar[1]) == "N" .and. ar[1] > 0
                p2->(dbGoto(ar[1]))
                mvar := "MTAB_NOMv"+lstr(i)
                &mvar := p2->tab_nom
              endif
              if valtype(ar[3]) == "N" .and. ar[3] > 0
                p2->(dbGoto(ar[3]))
                mvar := "MTAB_NOMa"+lstr(i)
                &mvar := p2->tab_nom
              endif
              mvar := "MDATE"+lstr(i)
              &mvar := mn_data
              if len(ar) >= 9 .and. valtype(ar[9]) == "D"
                &mvar := ar[9]
              endif
              m1var := "M1OTKAZ"+lstr(i)
              &m1var := 1
              if len(ar) >= 10 .and. valtype(ar[10]) == "N" .and. between(ar[10],1,2)
                &m1var := ar[10]
              endif
              mvar := "MOTKAZ"+lstr(i)
              &mvar := inieditspr(A__MENUVERT, mm_otkaz, &m1var)
            endif
          next i
        endif
      next j
    endif
    for i := 1 to 5
      f_valid_diag_oms_sluch_DVN_COVID(,i)
    next i
  endif

  if empty(mOKSI)
    mOKSI := 95   // оксиметрия в %
  endif
  //

  if !(left(msmo,2) == '34') // не Волгоградская область
    m1ismo := msmo ; msmo := '34'
  endif
  is_talon := .t.
  close databases

  fv_date_r( iif(Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  mndisp    := inieditspr(A__MENUVERT, mm_ndisp, metap)
  mrab_nerab:= inieditspr(A__MENUVERT, menu_rab, m1rab_nerab)
  mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
  mlpu      := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
  motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
  mvidpolis := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  mokato    := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu     := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mismo     := init_ismo(m1ismo)
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
  mmobilbr := inieditspr(A__MENUVERT, mm_danet, m1mobilbr)
  mstrong := inieditspr(A__MENUVERT, mm_strong, m1strong)
  mdyspnea := inieditspr(A__MENUVERT, mm_danet, m1dyspnea)
  mdispans  := inieditspr(A__MENUVERT, mm_dispans, m1dispans)
  mnazn_l   := inieditspr(A__MENUVERT, mm_danet, m1nazn_l)
  mdopo_na  := inieditspr(A__MENUBIT, mm_dopo_na, m1dopo_na)
  mnapr_v_mo := inieditspr(A__MENUVERT, mm_napr_v_mo, m1napr_v_mo)
  if empty(arr_mo_spec)
    ma_mo_spec := "---"
  else
    ma_mo_spec := ""
    for i := 1 to len(arr_mo_spec)
      ma_mo_spec += lstr(arr_mo_spec[i])+","
    next
    ma_mo_spec := left(ma_mo_spec,len(ma_mo_spec)-1)
  endif
  mnapr_stac := inieditspr(A__MENUVERT, mm_napr_stac, m1napr_stac)
  mprofil_stac := inieditspr(A__MENUVERT, glob_V002, m1profil_stac)
  mnapr_reab := inieditspr(A__MENUVERT, mm_danet, m1napr_reab)
  mprofil_kojki := inieditspr(A__MENUVERT, glob_V020, m1profil_kojki)
  mssh_na   := inieditspr(A__MENUVERT, mm_danet, m1ssh_na)
  mspec_na  := inieditspr(A__MENUVERT, mm_danet, m1spec_na)
  msank_na  := inieditspr(A__MENUVERT, mm_danet, m1sank_na)
// alertx(valtype(mprofil_stac),'mprofil')
// alertx(len(mprofil_stac),'mprofil')
  
  if ! ret_ndisp_COVID(Loc_kod,kod_kartotek) 
    return NIL
  endif
  //
  if !empty(f_print)
    return &(f_print+"("+lstr(Loc_kod)+","+lstr(kod_kartotek)+")")
  endif

  //
  str_1 := " случая углубленной диспансеризации взрослого населения (COVID)"
  if Loc_kod == 0
    str_1 := "Добавление"+str_1
  else
    str_1 := "Редактирование"+str_1
  endif

  setcolor(color8)
  Private gl_area
  setcolor(cDataCGet)
  make_diagP(1)  // сделать "шестизначные" диагнозы

  Private num_screen := 1
  do while .t.
    close databases
    DispBegin()
    hS := 25 ; wS := 80
    SetMode(hS,wS)
    @ 0, 0 say padc(str_1,wS) color "B/BG*"
    gl_area := {1,0,maxrow()-1,maxcol(),0}

    j := 1
    myclear(j)

    @ j, 0 say "Экран "+lstr(num_screen) color color8
    if num_screen > 1
      s := alltrim(mfio)+" ("+lstr(mvozrast)+" "+s_let(mvozrast)+")"
      @ j, wS - len(s) say s color color14
    endif
    if num_screen == 1 //
      @ ++j, 1 say "ФИО" get mfio_kart ;
          reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
          valid {|g,o| update_get("mdate_r"),;
                      update_get("mkomu"),update_get("mcompany") }
      @ row(), col()+5 say "Д.р." get mdate_r when .f. color color14

      // ++j
      // @ ++j,1 say " Работающий?" get mrab_nerab ;
      //     reader {|x|menu_reader(x,menu_rab,A__MENUVERT,,,.f.)}
      @ ++j, 1 say " Принадлежность счёта" get mkomu ;
          reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
          valid {|g,o| f_valid_komu(g,o) } ;
          color colget_menu
      @ row(), col()+1 say "==>" get mcompany ;
          reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
          when m1komu < 5 ;
          valid {|g| func_valid_ismo(g,m1komu,38) }
      @ ++j, 1 say " Полис ОМС: серия" get mspolis when m1komu == 0
      @ row(), col()+3 say "номер"  get mnpolis when m1komu == 0
      @ row(), col()+3 say "вид"    get mvidpolis ;
          reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
          when m1komu == 0 ;
          valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
      //
      @ ++j, 1 say "Сроки" get mn_data ;
          valid {|g| f_k_data(g,1), f_valid_Begdata_DVN_COVID(g),;
              iif(mvozrast < 18, func_error(4,"Это не взрослый пациент!"), nil),;
                ret_ndisp_COVID(Loc_kod,kod_kartotek);
          }
      // @ ++j, 1 say "Сроки" get mn_data ;
      //     valid {|g| f_k_data(g,1),;
      //         iif(mvozrast < 18, func_error(4,"Это не взрослый пациент!"), nil),;
      //           ret_ndisp_COVID(Loc_kod,kod_kartotek);
      //     }
      @ row(), col()+1 say "-" get mk_data ;
          valid {|g| f_k_data(g,2), f_valid_Enddata_DVN_COVID(g),;
                ret_ndisp_COVID(Loc_kod,kod_kartotek) ;
          }
      // @ row(), col()+1 say "-" get mk_data ;
      //     valid {|g| f_k_data(g,2),;
      //           ret_ndisp_COVID(Loc_kod,kod_kartotek) ;
      //     }

      // ++j
      @ j, col() + 5 say "№ амбулаторной карты" get much_doc picture "@!" ;
          when !(is_uchastok == 1 .and. is_task(X_REGIST)) .or. mem_edit_ist==2
      // @ j,col()+5 say "Мобильная бригада?" get mmobilbr ;
      //       reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
      // ++j
    
      ret_ndisp_COVID(Loc_kod,kod_kartotek)

      @ ++j, 8 get mndisp when .f. color color14
      // ++j

      @ ++j, 1 say "Дата окончания лечения COVID" get mDateCOVID ;
          valid {|| iif(((mn_data - mDateCOVID) < 60), func_error(4,"Прошло меньше 60 дней после заболевания!"), .t.)} ;
          when (metap == 1)   // редактируем только на первом этапе
      if metap == 1 // вводим только на первом этапе
        @ row(), col() + 5 say "Пульсооксиметрия" get mOKSI pict "999" ;
            valid {|| iif(between(mOKSI,70,100),,func_error(4,"Неразумные показания пульсооксиметрии")), .t.}
        @ row(), col()+1 say "%"
        @ ++j, 1 say "Степень тяжести болезни"
        @ j, col()+1 get mstrong ;
              reader {|x|menu_reader(x,mm_strong,A__MENUVERT,,,.f.)}
        @ j, col() + 5 say "Одышка/отеки" get mdyspnea ;
              reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
 
      endif

      @ ++j, 1 say "────────────────────────────────────────────┬─────┬─────┬──────────┬──────────" color color8
      @ ++j, 1 say "Наименования исследований                   │врач │ассис│дата услуг│выполнение " color color8
      @ ++j, 1 say "────────────────────────────────────────────┴─────┴─────┴──────────┴──────────" color color8
      if mem_por_ass == 0
        @ j-1,52 say space(5)
      endif
      fl_vrach := .t.

      for i := 1 to len(uslugiEtap_DVN_COVID(metap))
        fl_diag := .f.
        i_otkaz := 0
        if f_is_usl_oms_sluch_DVN_COVID(i, metap, .f., @fl_diag, @i_otkaz)
          if fl_diag .and. fl_vrach
            @ ++j, 1 say "────────────────────────────────────────────┬─────┬─────┬───────────" color color8
            @ ++j, 1 say "Наименования осмотров                       │врач │ассис│дата услуги" color color8
            @ ++j, 1 say "────────────────────────────────────────────┴─────┴─────┴───────────" color color8
            if mem_por_ass == 0
              @ j-1, 52 say space(5)
            endif
            fl_vrach := .f.
          endif
          mvarv := "MTAB_NOMv"+lstr(i)
          mvara := "MTAB_NOMa"+lstr(i)
          mvard := "MDATE"+lstr(i)
          if empty(&mvard)
            &mvard := mn_data
          endif
          mvarz := "MKOD_DIAG"+lstr(i)
          mvaro := "MOTKAZ"+lstr(i)
          @ ++j, 1 say uslugiEtap_DVN_COVID(metap)[i,1]
          if (metap == 1) .and. (i == 6) .and. (mOKSI >= 95 .and. m1dyspnea == 1)
            flEdit := 0 //.f.
          elseif (metap == 1) .and. (i == 7) .and. (m1strong >= 2)
            flEdit := 0 //.f.
          else
            flEdit := 1 //.t.
          endif
          @ j, 46 get &mvarv pict "99999" valid {|g| v_kart_vrach(g) } when flEdit > 0
          if mem_por_ass > 0
            @ j, 52 get &mvara pict "99999" valid {|g| v_kart_vrach(g) } when flEdit > 0
          endif
          @ j, 58 get &mvard when flEdit == 1
          if fl_diag
            // @ j, 69 get &mvarz picture pic_diag ;
            //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
          elseif i_otkaz == 0
            @ j, 69 get &mvaro ;
                 reader {|x|menu_reader(x,mm_otkaz0,A__MENUVERT,,,.f.)} when flEdit == 1
          elseif i_otkaz == 1
            @ j, 69 get &mvaro ;
                 reader {|x|menu_reader(x,mm_otkaz1,A__MENUVERT,,,.f.)} when flEdit == 1
          elseif eq_any(i_otkaz,2,3)
            @ j, 69 get &mvaro ;
                 reader {|x|menu_reader(x,mm_otkaz,A__MENUVERT,,,.f.)} when flEdit == 1
          endif
        endif
      next
      @ ++j, 1 say replicate("─",68) color color8
      status_key("^<Esc>^ выход без записи ^<PgDn>^ на 2-ю страницу")
    elseif num_screen == 2 //

      mm_gruppa := {mm_gruppaD1,mm_gruppaD2}[metap]
      mgruppa := inieditspr(A__MENUVERT, mm_gruppa, m1gruppa)
      if (i := ascan(mm_gruppa, {|x| x[3] == m1rslt })) > 0
        m1GRUPPA := mm_gruppa[i,2]
      endif

      ret_ndisp_COVID(Loc_kod,kod_kartotek)
      @ ++j, 8 get mndisp when .f. color color14
      @ ++j, 1  say "───────┬────────────┬──────────┬──────┬───────────────────────────────────────"
      @ ++j, 1  say "       │  выявлено  │   дата   │стадия│установлено диспансерное Дата следующего"
      @ ++j, 1  say "диагноз│заболевание │выявления │забол.│наблюдение     (когда)     визита"
      @ ++j, 1  say "───────┴────────────┴──────────┴──────┴───────────────────────────────────────"
      //                2      9            22           35       44        54
      @ ++j, 2  get mdiag1 picture pic_diag ;
          reader {|o| MyGetReader(o,bg)} ;
          valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                  f_valid_diag_oms_sluch_DVN_COVID(g,1),;
                  .f.) }
      @ j, 9  get mpervich1 ;
          reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
          when !empty(mdiag1)
      @ j, 22 get mddiag1 when !empty(mdiag1)
      @ j, 35 get m1stadia1 pict "9" range 1,4 ;
          when !empty(mdiag1)
      @ j, 44 get mdispans1 ;
          reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
          when !empty(mdiag1)
      @ j, 54 get mddispans1 when m1dispans1==1
      @ j, 67 get mdndispans1 when m1dispans1==1
      //
      @ ++j, 2  get mdiag2 picture pic_diag ;
          reader {|o| MyGetReader(o,bg)} ;
          valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                  f_valid_diag_oms_sluch_DVN_COVID(g,2),;
                  .f.) }
      @ j, 9  get mpervich2 ;
          reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
          when !empty(mdiag2)
      @ j, 22 get mddiag2 when !empty(mdiag2)
      @ j, 35 get m1stadia2 pict "9" range 1,4 ;
          when !empty(mdiag2)
      @ j, 44 get mdispans2 ;
          reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
          when !empty(mdiag2)
      @ j, 54 get mddispans2 when m1dispans2==1
      @ j, 67 get mdndispans2 when m1dispans2==1
      //
      @ ++j, 2  get mdiag3 picture pic_diag ;
          reader {|o| MyGetReader(o,bg)} ;
          valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                  f_valid_diag_oms_sluch_DVN_COVID(g,3),;
                  .f.) }
      @ j, 9  get mpervich3 ;
          reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
          when !empty(mdiag3)
      @ j, 22 get mddiag3 when !empty(mdiag3)
      @ j, 35 get m1stadia3 pict "9" range 1,4 ;
          when !empty(mdiag3)
      @ j, 44 get mdispans3 ;
          reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
          when !empty(mdiag3)
      @ j, 54 get mddispans3 when m1dispans3==1
      @ j, 67 get mdndispans3 when m1dispans3==1
      //
      @ ++j, 2  get mdiag4 picture pic_diag ;
          reader {|o| MyGetReader(o,bg)} ;
          valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                  f_valid_diag_oms_sluch_DVN_COVID(g,4),;
                  .f.) }
      @ j, 9  get mpervich4 ;
          reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
          when !empty(mdiag4)
      @ j, 22 get mddiag4 when !empty(mdiag4)
      @ j, 35 get m1stadia4 pict "9" range 1,4 ;
          when !empty(mdiag4)
      @ j, 44 get mdispans4 ;
          reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
          when !empty(mdiag4)
      @ j, 54 get mddispans4 when m1dispans4==1
      @ j, 67 get mdndispans4 when m1dispans4==1
      //
      @ ++j, 2  get mdiag5 picture pic_diag ;
          reader {|o| MyGetReader(o,bg)} ;
          valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                  f_valid_diag_oms_sluch_DVN_COVID(g,5),;
                  .f.) }
      @ j, 9  get mpervich5 ;
          reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
          when !empty(mdiag5)
      @ j, 22 get mddiag5 when !empty(mdiag5)
      @ j, 35 get m1stadia5 pict "9" range 1,4 ;
          when !empty(mdiag5)
      @ j, 44 get mdispans5 ;
          reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
          when !empty(mdiag5)
      @ j, 54 get mddispans5 when m1dispans5==1
      @ j, 67 get mdndispans5 when m1dispans5==1
      //
      @ ++j, 1 say replicate("─",78) color color1
      // подвал второго листа
      @ ++j,1 say "Диспансерное наблюдение установлено" get mdispans ;
                 reader {|x|menu_reader(x,mm_dispans,A__MENUVERT,,,.f.)} ;
                 when !emptyall(mdispans1,mdispans2,mdispans3,mdispans4,mdispans5)
      // @ ++j,1 say "Признак подозрения на злокачественное новообразование" get mDS_ONK ;
      //            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
      // @ ++j,1 say "Направления при подозрении на ЗНО" get mnapr_onk ;
      //            reader {|x|menu_reader(x,{{|k,r,c| fget_napr_PN(k,r,c)}},A__FUNCTION,,,.f.)} ;
      //            when m1ds_onk == 1
      @ ++j,1 say "Назначено лечение (для ф.131)" get mnazn_l ;
                 reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}

      if mk_data >= 0d20210801  // по новому ПУМП
        @ j, 74 say "Врач"
        @ ++j, 1 say replicate("─",78) color color1

        mdopo_na := iif(len(mdopo_na)>0,substr(mdopo_na,1,20),'')
        @ ++j,1 say "Направлен на дополнительное обследование" get mdopo_na ;
          reader {|x|menu_reader(x,mm_dopo_na,A__MENUBIT,,,.f.)}
        @ j,73 get mtab_v_dopo_na pict "99999" valid {|g| v_kart_vrach(g) } when m1dopo_na > 0

        @ ++j,1 say "Направлен" get mnapr_v_mo ;
            reader {|x|menu_reader(x,mm_napr_v_mo,A__MENUVERT,,,.f.)} ;
            valid {|| iif(m1napr_v_mo==0, (arr_mo_spec:={},ma_mo_spec:=padr("---",42)), ), update_get("ma_mo_spec")}
        ma_mo_spec := iif(len(ma_mo_spec)>0,substr(ma_mo_spec,1,20),'')
        @ j,col()+1 say "к специалистам" get ma_mo_spec ;
            reader {|x|menu_reader(x,{{|k,r,c| fget_spec_DVN(k,r,c,arr_mo_spec)}},A__FUNCTION,,,.f.)} ;
            when m1napr_v_mo > 0
        @ j,73 get mtab_v_mo pict "99999" valid {|g| v_kart_vrach(g) } when m1napr_v_mo > 0
        @ ++j,1 say "Направлен на лечение" get mnapr_stac ;
            reader {|x|menu_reader(x,mm_napr_stac,A__MENUVERT,,,.f.)} ;
            valid {|| iif(m1napr_stac==0, (m1profil_stac:=0,mprofil_stac:=space(32)), ), update_get("mprofil_stac")}
        mprofil_stac := iif(len(mprofil_stac)>0,substr(mprofil_stac,1,27),'')
        @ j,col()+1 say "по профилю" get mprofil_stac PICTURE '@S27';
            reader {|x|menu_reader(x,glob_V002,A__MENUVERT,,,.f.)} ;
            when m1napr_stac > 0
        @ j,73 get mtab_v_stac pict "99999" valid {|g| v_kart_vrach(g) } when m1napr_stac > 0
        @ ++j,1 say "Направлен на реабилитацию" get mnapr_reab ;
            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
            valid {|| iif(m1napr_reab==0, (m1profil_kojki:=0,mprofil_kojki:=space(30)), ), update_get("mprofil_kojki")}
        mprofil_kojki := iif(len(mprofil_kojki)>0,substr(mprofil_kojki,1,25),'')
        @ j,col()+1 say ", профиль койки" get mprofil_kojki ;
            reader {|x|menu_reader(x,glob_V020,A__MENUVERT,,,.f.)} ;
            when m1napr_reab > 0
        @ j,73 get mtab_v_reab pict "99999" valid {|g| v_kart_vrach(g) } when m1napr_reab > 0
        @ ++j,1 say "Направлен на санаторно-курортное лечение" get msank_na ;
            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}      //;
            //  valid {|| iif(m1sank_na==0, mtab_v_sanat := 0, ), update_get("mtab_v_sank")}
        @ j,73 get mtab_v_sanat pict "99999" valid {|g| v_kart_vrach(g) } when (m1sank_na > 0)
      else
        @ ++j,1 say "Направлен на дополнительное обследование" get mdopo_na ;
            reader {|x|menu_reader(x,mm_dopo_na,A__MENUBIT,,,.f.)}
        @ ++j,1 say "Направлен" get mnapr_v_mo ;
            reader {|x|menu_reader(x,mm_napr_v_mo,A__MENUVERT,,,.f.)} ;
            valid {|| iif(m1napr_v_mo==0, (arr_mo_spec:={},ma_mo_spec:=padr("---",42)), ), update_get("ma_mo_spec")}
        @ j,col()+1 say "к специалистам" get ma_mo_spec ;
            reader {|x|menu_reader(x,{{|k,r,c| fget_spec_DVN(k,r,c,arr_mo_spec)}},A__FUNCTION,,,.f.)} ;
            when m1napr_v_mo > 0
        @ ++j,1 say "Направлен на лечение" get mnapr_stac ;
            reader {|x|menu_reader(x,mm_napr_stac,A__MENUVERT,,,.f.)} ;
            valid {|| iif(m1napr_stac==0, (m1profil_stac:=0,mprofil_stac:=space(32)), ), update_get("mprofil_stac")}
        @ j,col()+1 say "по профилю" get mprofil_stac ;
            reader {|x|menu_reader(x,glob_V002,A__MENUVERT,,,.f.)} ;
            when m1napr_stac > 0
        @ ++j,1 say "Направлен на реабилитацию" get mnapr_reab ;
            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
            valid {|| iif(m1napr_reab==0, (m1profil_kojki:=0,mprofil_kojki:=space(30)), ), update_get("mprofil_kojki")}
        @ j,col()+1 say ", профиль койки" get mprofil_kojki ;
            reader {|x|menu_reader(x,glob_V020,A__MENUVERT,,,.f.)} ;
            when m1napr_reab > 0
        @ ++j,1 say "Направлен на санаторно-курортное лечение" get msank_na ;
            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}      //;
            //  valid {|| iif(m1sank_na==0, mtab_v_sanat := 0, ), update_get("mtab_v_sank")}
      endif

      ++j

      @ ++j, 1 say "ГРУППА состояния ЗДОРОВЬЯ"
      @ j, col()+1 get mGRUPPA ;
          reader {|x|menu_reader(x,mm_gruppa,A__MENUVERT,,,.f.)}
      status_key("^<Esc>^ выход без записи ^<PgUp>^ на 1-ю страницу ^<PgDn>^ ЗАПИСЬ")
    endif
    DispEnd()
    count_edit += myread()

///////////////////////////////////////////////////////////////////////////////////////////

    if num_screen == 2
      if lastkey() == K_PGUP
        k := 3
        --num_screen
      else
        k := f_alert({padc("Выберите действие",60,".")},;
                   {" Выход без записи "," Запись "," Возврат в редактирование "},;
                   iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
      endif
    else
      if lastkey() == K_PGUP
        k := 3
        if num_screen > 1
          --num_screen
        endif
      elseif lastkey() == K_ESC
        if (k := f_alert({padc("Выберите действие",60,".")},;
                      {" Выход без записи "," Возврат в редактирование "},;
                       1,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )) == 2
          k := 3
        endif
      else
        k := 3
        ++num_screen
        if mvozrast < 18
          num_screen := 1
          func_error(4,"Это не взрослый пациент!")
        elseif metap == 0
          num_screen := 1
          func_error(4,"Проверьте сроки диспансеризации!")
        endif
      endif
    endif

    SetMode(25,80)
    if k == 3
      loop
    elseif k == 2
      num_screen := 1
      if m1komu < 5 .and. empty(m1company)
        if m1komu == 0
          s := "СМО"
        elseif m1komu == 1
          s := "компании"
        else
          s := "комитета/МО"
        endif
        func_error(4,'Не заполнено наименование '+s)
        loop
      endif
      if m1komu == 0 .and. empty(mnpolis)
        func_error(4,'Не заполнен номер полиса')
        loop
      endif
      if empty(mn_data)
        func_error(4,"Не введена дата начала углубленной диспансеризации после COVID.")
        loop
      endif
      if mvozrast < 18
        func_error(4,"Диспансеризация оказана НЕ взрослому пациенту!")
        loop
      endif
      if empty(mk_data)
        func_error(4,"Не введена дата окончания углубленной диспансеризации после COVID.")
        loop
      endif
      if empty(CHARREPL("0",much_doc,space(10)))
        func_error(4,'Не заполнен номер амбулаторной карты')
        loop
      endif
      //
//////////////////////////////////////////////////////////////
      mdef_diagnoz := 'U09.9 '
      R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
      R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2")
      num_screen := 2
      fl := .t.
      k := 0
      kol_d_usl := 0
      arr_osm1 := array(len(uslugiEtap_DVN_COVID(metap)), 13)
      afillall(arr_osm1,0)

      // ВСЕ ЗАПИСЫВАЕМ
      tmpvr := 0
      for i := 1 to len(uslugiEtap_DVN_COVID(metap))
        fl_diag := .f.
        i_otkaz := 0
        // if f_is_usl_oms_sluch_DVN_COVID(i, metap, .t., @fl_diag, @i_otkaz)
        f_is_usl_oms_sluch_DVN_COVID(i, metap, .t., @fl_diag, @i_otkaz)
          mvart := "MTAB_NOMv"+lstr(i)
          mvara := "MTAB_NOMa"+lstr(i)
          mvard := "MDATE"+lstr(i)
          mvarz := "MKOD_DIAG"+lstr(i)
          mvaro := "M1OTKAZ"+lstr(i)
          ar := uslugiEtap_DVN_COVID(metap)[i]
          // для заполнения услуги 70.8.1
          if valtype(ar[2]) == "C" .and. ar[2] == "B01.026.001"
            tmpvr := &mvart
          endif
          if valtype(ar[2]) == "C" .and. ar[2] == "70.8.1" .and. metap == 1
            &mvard := mn_data
            &mvart := tmpvr
          endif
          //
          ++kol_d_usl
          arr_osm1[i,12] := uslugiEtap_DVN_COVID(metap)[i, 12]   // признак услуги 0 - ТФОМС / 1 - ФФОМС
          if arr_osm1[i,12] == 0
            arr_osm1[i,13] := uslugiEtap_DVN_COVID(metap)[i, 13]
          endif
          if i_otkaz == 2 .and. &mvaro == 2 // если исследование невозможно
            select P2
            find (str(&mvart,5))
            if found()
              arr_osm1[i,1] := p2->kod
            endif
            if valtype(ar[11]) == "A" // специальность
              arr_osm1[i,2] := ar[11,1]
            endif
            if valtype(ar[10]) == "N" // профиль
              arr_osm1[i,4] := ar[10]
            endif
            arr_osm1[i,5] := ar[2] // шифр услуги
            // arr_osm1[i,9] := iif(empty(&mvard), mn_data, &mvard)
            arr_osm1[i,9] := iif(empty(&mvard), mk_data, &mvard)
            arr_osm1[i,10] := &mvaro
            --kol_d_usl
          elseif empty(&mvard)
            fl := func_error(4,'Не введена дата услуги "'+ltrim(ar[1])+'"')
          elseif empty(&mvart) .and. metap == 1 .and. !eq_any(ar[2], '70.8.2', '70.8.3')      // на втором этапе услуги могут быть не все
            fl := func_error(4,'Не введен врач в услуге "'+ltrim(ar[1])+'"')
          else  // табельный номер врача и его специальность
            select P2
            find (str(&mvart,5))
            if found()
              arr_osm1[i,1] := p2->kod
              arr_osm1[i,2] := -ret_new_spec(p2->prvs,p2->prvs_new)
            endif
            if !empty(&mvara) // табельный номер ассистента
              select P2
              find (str(&mvara,5))
              if found()
                arr_osm1[i,3] := p2->kod
              endif
            endif
            if valtype(ar[10]) == "N" // профиль
              arr_osm1[i,4] := ret_profil_dispans_COVID(ar[10],arr_osm1[i,2])
            else
              if len(ar[10]) == len(ar[11]) ; // кол-во профилей = кол-ву спец-тей
                    .and. arr_osm1[i,2] < 0 ; // и нашли специальность по V015
                    .and. (j := ascan(ar[11],ret_old_prvs(arr_osm1[i,2]))) > 0
                // берём профиль, соответствующий специальности
              else
                j := 1 // если нет, берём первый профиль из списка
              endif
              arr_osm1[i,4] := ar[10,j] // профиль
            endif
            if valtype(ar[2]) == "C"  // шифр услуги
              arr_osm1[i,5] := ar[2] // шифр услуги
            else
              if len(ar[2]) >= metap
                j := metap
              else
                j := 1
              endif
              arr_osm1[i,5] := ar[2,j] // шифр услуги
            endif

            if !fl_diag .or. empty(&mvarz) .or. left(&mvarz,1) == 'U'
              arr_osm1[i,6] := mdef_diagnoz
            else
              arr_osm1[i,6] := &mvarz
              select MKB_10
              find (padr(arr_osm1[i,6],6))
              if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
                fl := func_error(4,"Несовместимость диагноза по полу "+arr_osm1[i,6])
              endif
            endif
            arr_osm1[i,10] := &mvaro
            arr_osm1[i,9] := &mvard

          endif
        // endif
        if !fl
          exit
        endif
      next
      if metap == 1
        iB01_026_001 := indexUslugaEtap_DVN_COVID(metap, 'B01.026.001')
        i70_80_1 := indexUslugaEtap_DVN_COVID(metap, '70.8.1')
        arr_osm1[i70_80_1, 1] := arr_osm1[iB01_026_001, 1]
        arr_osm1[i70_80_1, 2] := arr_osm1[iB01_026_001, 2]
        arr_osm1[i70_80_1, 3] := arr_osm1[iB01_026_001, 3]
        arr_osm1[i70_80_1, 6] := arr_osm1[iB01_026_001, 6]
        arr_osm1[i70_80_1, 9] := arr_osm1[iB01_026_001, 9]
        arr_osm1[i70_80_1, 11] := arr_osm1[iB01_026_001, 11]
      endif
      if !fl
        loop
      endif

      num_screen := 2
      arr_diag := {}
      for i := 1 to 5
        sk := lstr(i)
        pole_diag := "mdiag"+sk
        pole_d_diag := "mddiag"+sk
        pole_1pervich := "m1pervich"+sk
        pole_1dispans := "m1dispans"+sk
        pole_d_dispans := "mddispans"+sk
        pole_dn_dispans := "mdndispans"+sk
        if !empty(&pole_diag)
          if left(&pole_diag,1) == "U"
            fl := func_error(4,'Диагноз '+rtrim(&pole_diag)+'(первый символ "U") не вводится. Это не заболевание!')
          elseif &pole_1pervich == 0
            if empty(&pole_d_diag)
              fl := func_error(4,"Не введена дата выявления диагноза "+&pole_diag)
            elseif &pole_1dispans == 1 .and. empty(&pole_d_dispans)
              fl := func_error(4,"Не введена дата установления диспансерного наблюдения для диагноза "+&pole_diag)
            endif
          endif
          if fl .and. between(&pole_1pervich,0,1) // предварительные диагнозы не берём
            aadd(arr_diag, {&pole_diag,&pole_1pervich,&pole_1dispans,&pole_dn_dispans})
          endif
        endif
        if !fl
          exit
        endif
      next
      if len(arr_diag) > 0
        aadd(arr_diag, {mdef_diagnoz,0,0,ctod("")})
      endif
      if !fl
        loop
      endif

      afill(adiag_talon,0)
      if empty(arr_diag) // диагнозы не вводили
        // aadd(arr_diag, {mdef_diagnoz,0,0,ctod("")}) // диагноз по умолчанию
        MKOD_DIAG := mdef_diagnoz
      else
        for i := 1 to len(arr_diag)
          if arr_diag[i,2] == 0 // "ранее выявлено"
            arr_diag[i,2] := 2  // заменяем, как в листе учёта ОМС
          endif
          if arr_diag[i,3] > 0 // "дисп.наблюдение установлено" и "ранее выявлено"
            if arr_diag[i,2] == 2 // "ранее выявлено"
              arr_diag[i,3] := 1 // то "Состоит"
            else
              arr_diag[i,3] := 2 // то "Взят"
            endif
          endif
        next
        for i := 1 to len(arr_diag)
          // if ascan(sadiag1,alltrim(arr_diag[i,1])) > 0 .and. ;
          //                         arr_diag[i,3] == 1 .and. !empty(arr_diag[i,4]) .and. arr_diag[i,4] > mk_data
          // endif
          adiag_talon[i*2-1] := arr_diag[i,2]
          adiag_talon[i*2  ] := arr_diag[i,3]
          if i == 1
            MKOD_DIAG := arr_diag[i,1]
          elseif i == 2
            MKOD_DIAG2 := arr_diag[i,1]
          elseif i == 3
            MKOD_DIAG3 := arr_diag[i,1]
          elseif i == 4
            MKOD_DIAG4 := arr_diag[i,1]
          elseif i == 5
            MSOPUT_B1 := arr_diag[i,1]
          endif
          select MKB_10
          find (padr(arr_diag[i,1],6))
          if found()
            if !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
              fl := func_error(4,"несовместимость диагноза по полу "+alltrim(arr_diag[i,1]))
            endif
          else
            fl := func_error(4,"не найден диагноз "+alltrim(arr_diag[i,1])+" в справочнике МКБ-10")
          endif
          if !fl
            exit
          endif
        next
        if !fl
          loop
        endif
      endif

      aadd(arr_diag, {mdef_diagnoz,0,0,ctod("")}) // всегда добавляем в лист учета

      mm_gruppa := {mm_gruppaD1,mm_gruppaD2}[metap]

      m1p_otk := 0
      if (i := ascan(mm_gruppa,{|x| x[2] == m1GRUPPA })) > 0
        if (m1rslt := mm_gruppa[i,3]) == 352
          m1rslt := 353 // по письму ТФОМС от 06.07.2018 №09-30-96
        endif
        if eq_any(m1GRUPPA,11,21)
          m1GRUPPA++  // по письму ТФОМС от 06.07.2018 №09-30-96
        endif
        if m1GRUPPA > 20
          m1p_otk := 1 // отказ от прихода на 2-й этап
        endif
      else
        func_error(4,"Не введена ГРУППА состояния ЗДОРОВЬЯ")
        loop
      endif
      //
      m1ssh_na := m1psih_na := m1spec_na := 0
      if m1napr_v_mo > 0
        if eq_ascan(arr_mo_spec,45,141) // Направлен к врачу-сердечно-сосудистому хирургу
          m1ssh_na := 1
        endif
        if eq_ascan(arr_mo_spec,23,97) // Направлен к врачу-психиатру (врачу-психиатру-наркологу)
          m1psih_na := 1
        endif
      endif
      if m1napr_stac > 0 .and. m1profil_stac > 0
        m1spec_na := 1 // Направлен для получения специализированной медицинской помощи (в т.ч. ВМП)
      endif
      //
      err_date_diap(mn_data,"Дата начала углубленной диспансеризации после COVID")
      err_date_diap(mk_data,"Дата окончания углубленной диспансеризации после COVID")
      //
      if mem_op_out == 2 .and. yes_parol
        box_shadow(19,10,22,69,cColorStMsg)
        str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
        str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
      endif
      mywait()
      is_prazdnik := f_is_prazdnik_DVN_COVID(mn_data)
      
      make_diagP(2)  // сделать "пятизначные" диагнозы
      if m1dispans > 0
        s1dispans := m1dispans
      endif
      //
      Use_base("lusl")
      Use_base("luslc")
      Use_base("uslugi")
      R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                                dir_server+"uslugi1s"},"USL1")
      mcena_1 := mu_cena := 0
      arr_usl_dop := {}
      arr_usl_otkaz := {}
      arr_otklon := {}
      glob_podr := ""
      glob_otd_dep := 0
      iUslDop := 0
      iUslOtkaz := 0
      iUslOtklon := 0
      for i := 1 to len(arr_osm1)
        if valtype(arr_osm1[i,5]) == "C"
          if arr_osm1[i,12] == 0
            arr_osm1[i,7] := foundOurUsluga(arr_osm1[i,5],mk_data,arr_osm1[i,4],M1VZROS_REB,@mu_cena)
            arr_osm1[i,8] := iif(eq_any(arr_osm1[i,10],0,3), mu_cena, 0)
          else
            arr_osm1[i,7] := foundFFOMSUsluga(arr_osm1[i,5])
            arr_osm1[i,8] := 0  // для федеральных услуг цену дадим 0
            // mu_cena := 0
          endif

          if arr_osm1[i,1] == 0    // если в услуге не назначен врач
            loop
          endif

          if eq_any(arr_osm1[i,10],0,3) // выполнено
            aadd(arr_usl_dop,aclone(arr_osm1[i]))
            // iUslDop++
            if arr_osm1[i,12] == 0 .and. !empty(arr_osm1[i,13])  // для услуги ТФОМС добавим услугу ФФОМС
              aadd(arr_usl_dop,aclone(arr_osm1[i]))
              iUslDop := len(arr_usl_dop) //++
              arr_usl_dop[iUslDop,5] := arr_osm1[i,13]
              arr_usl_dop[iUslDop,7] := foundFFOMSUsluga(arr_usl_dop[iUslDop,5])
              arr_usl_dop[iUslDop,8] := 0  // для федеральных услуг цену дадим 0
              arr_usl_dop[iUslDop,12] := 1  // установим флаг услуги ФФОМС
              arr_usl_dop[iUslDop,13] := ''  // очистим федеральную услугу
            endif
            if arr_osm1[i,10] == 3 // обнаружены отклонения
              aadd(arr_otklon,aclone(arr_osm1[i,5]))
              iUslOtklon++
            endif
          else // отказ и невозможность
            aadd(arr_usl_otkaz,aclone(arr_osm1[i]))
            // iUslOtkaz++
            if arr_osm1[i,12] == 0 .and. !empty(arr_osm1[i,13])  // для услуги ТФОМС добавим услугу ФФОМС
              aadd(arr_usl_otkaz,aclone(arr_osm1[i]))
              iUslOtkaz := len(arr_usl_otkaz) //++
              arr_usl_otkaz[iUslOtkaz,5] := arr_osm1[i,13]
              arr_usl_otkaz[iUslOtkaz,7] := foundFFOMSUsluga(arr_usl_otkaz[iUslOtkaz,5])
              arr_usl_otkaz[iUslOtkaz,8] := 0  // для федеральных услуг цену дадим 0
              arr_usl_otkaz[iUslOtkaz,12] := 1  // установим флаг услуги ФФОМС
              arr_usl_otkaz[iUslOtkaz,13] := ''  // очистим федеральную услугу
            endif
          endif
        endif
      next
      // получим общую стоимость случая для принимаемых услуг
      for i := 1 to len(arr_usl_dop)
        mcena_1 += arr_usl_dop[i,8]
      next
      //
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
      st_N_DATA := MN_DATA
      glob_perso := mkod
      if m1komu == 0
        msmo := lstr(m1company)
        m1str_crb := 0
      else
        msmo := ""
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
      human->RAB_NERAB  := M1RAB_NERAB   // 0-работающий, 1-неработающий, 2-студент
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
      human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
      human->N_DATA     := MN_DATA       // дата начала лечения
      human->K_DATA     := MK_DATA       // дата окончания лечения
      human->CENA := human->CENA_1 := MCENA_1 // стоимость лечения
      human->ishod      := 400 + metap
      // human->OBRASHEN   := iif(m1DS_ONK == 1, '1', " ")
      human->bolnich    := 0
      human->date_b_1   := ""
      human->date_b_2   := ""
      human_->RODIT_DR  := ctod("")
      human_->RODIT_POL := ""
      s := ""
      aeval(adiag_talon, {|x| s += str(x,1) })
      human_->DISPANS   := s
      human_->STATUS_ST := ""
      human_->POVOD     := iif(metap == 3, 5, 6)
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := ltrim(mspolis)
      human_->NPOLIS    := ltrim(mnpolis)
      human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
      human_->NOVOR     := 0
      human_->DATE_R2   := ctod("")
      human_->POL2      := ""
      human_->USL_OK    := m1USL_OK
      human_->VIDPOM    := m1VIDPOM
      human_->PROFIL    := 151    // m1PROFIL
      human_->IDSP      := 30     // iif(metap == 3, 17, 11)
      human_->NPR_MO    := ''
      human_->FORMA14   := '0000'
      human_->KOD_DIAG0 := ''
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
        G_Use(dir_server+"mo_hismo",,"SN")
        index on str(kod,7) to (cur_dir+"tmp_ismo")
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
      i1 := len(arr_usl)
      // i2 := len(arr_usl_dop)

      // R_Use(dir_server+"uslugi",,"USL")
      R_Use(dir_server+"mo_su",,"MOSU")
      Use_base("mo_hu")
      Use_base("human_u")
      for i := 1 to len(arr_usl_dop)  // i2
        flExist := .f.
        if arr_usl_dop[i,12] == 0   // это услуга ТФОМС
          select HU
            // сначала выберем информацию из human_u по услугам ТФОМС
            find (str(Loc_kod,7))
            do while hu->kod == Loc_kod .and. !eof()
              usl->(dbGoto(hu->u_kod))
              if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
                lshifr := usl->shifr
              endif
              lshifr := alltrim(lshifr)
              if lshifr == alltrim(arr_usl_dop[i,5])
                G_RLock(forever)
                flExist := .t.
                exit
              endif
              skip
            enddo
            if ! flExist
              Add1Rec(7)
              hu->kod := human->kod
            endif
          // endif
          mrec_hu := hu->(recno())
          hu->kod_vr  := arr_usl_dop[i,1]
          hu->kod_as  := arr_usl_dop[i,3]
          hu->u_koef  := 1
          hu->u_kod   := arr_usl_dop[i,7]
          hu->u_cena  := arr_usl_dop[i,8]
          hu->is_edit := iif(len(arr_usl_dop[i]) > 10 .and. valtype(arr_usl_dop[i,11]) == "N", arr_usl_dop[i,11], 0)
          hu->date_u  := dtoc4(arr_usl_dop[i,9])
          hu->otd     := m1otd
          hu->kol := hu->kol_1 := 1
          hu->stoim := hu->stoim_1 := arr_usl_dop[i,8]
          hu->KOL_RCP := 0
          select HU_
          do while hu_->(lastrec()) < mrec_hu
            APPEND BLANK
          enddo
          goto (mrec_hu)
          G_RLock(forever)
          if i > i1 .or. !valid_GUID(hu_->ID_U)
            hu_->ID_U := mo_guid(3,hu_->(recno()))
          endif
          hu_->PROFIL := arr_usl_dop[i,4]
          hu_->PRVS   := arr_usl_dop[i,2]
          hu_->kod_diag := iif(empty(arr_usl_dop[i,6]), MKOD_DIAG, arr_usl_dop[i,6])
          hu_->zf := ""
          UNLOCK
        else  // 1 - это услуга ФФОМС
          select MOHU
            // затем выберем информацию из mo_hu по услугам ФФОМС
            set relation to u_kod into MOSU 
            find (str(Loc_kod,7))
            do while MOHU->kod == Loc_kod .and. !eof()
              MOSU->(dbGoto(MOHU->u_kod))
              select MOHU
              lshifr := alltrim(iif(empty(MOSU->shifr),MOSU->shifr1,MOSU->shifr))
              if alltrim(lshifr) == alltrim(arr_usl_dop[i,5])
                G_RLock(forever)
                flExist := .t.
                exit
              endif
              skip
            enddo
            if ! flExist
              Add1Rec(7)
              MOHU->kod := human->kod
            endif
          // endif
          mrec_mohu := MOHU->(recno())
          MOHU->kod_vr  := arr_usl_dop[i,1]
          MOHU->kod_as  := arr_usl_dop[i,3]
          MOHU->u_kod   := arr_usl_dop[i,7]
          MOHU->u_cena  := arr_usl_dop[i,8]
          MOHU->date_u  := dtoc4(arr_usl_dop[i,9])
          MOHU->otd     := m1otd
          MOHU->kol_1 := 1
          MOHU->stoim_1 := arr_usl_dop[i,8]
          if i > i1 .or. !valid_GUID(MOHU->ID_U)
            MOHU->ID_U := mo_guid(3,MOHU->(recno()))
          endif
          MOHU->PROFIL := arr_usl_dop[i,4]
          MOHU->PRVS   := arr_usl_dop[i,2]
          MOHU->kod_diag := iif(empty(arr_usl_dop[i,6]), MKOD_DIAG, arr_usl_dop[i,6])
          UNLOCK
        endif
      next
      // ????????

      if ! (len(arr_usl) == 0)
        if ! empty(arr_usl_otkaz)
          for iOtkaz := 1 to len(arr_usl_otkaz)
            if arr_usl_otkaz[iOtkaz,12] == 0
              select HU
              // сначала выберем информацию из human_u по услугам ТФОМС
              find (str(Loc_kod,7))
              do while hu->kod == Loc_kod .and. !eof()
                usl->(dbGoto(hu->u_kod))
                if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
                  lshifr := usl->shifr
                endif
                lshifr := alltrim(lshifr)
                if lshifr == alltrim(arr_usl_otkaz[iOtkaz,5])
                  DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
                  exit
                endif
                skip
              enddo

            else
              select MOHU
              // затем выберем информацию из mo_hu по услугам ФФОМС
              set relation to u_kod into MOSU 
              find (str(Loc_kod,7))
              do while MOHU->kod == Loc_kod .and. !eof()
                MOSU->(dbGoto(MOHU->u_kod))
                lshifr := alltrim(iif(empty(MOSU->shifr),MOSU->shifr1,MOSU->shifr))
                select MOHU
                if alltrim(lshifr) == alltrim(arr_usl_otkaz[iOtkaz,5])
                  DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
                  exit
                endif
                skip
              enddo
            endif
          next
        endif
        for i := 1 to len(arr_osm1)
          if arr_osm1[i, 1] == 0  // не заполнен врач
            if arr_osm1[i,12] == 0
              select HU
              // goto (arr_usl[indexUslugaEtap_DVN_COVID(metap, arr_osm1[i,5])])
              // if !eof() .and. !bof()
              //   DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
              // endif

              // сначала выберем информацию из human_u по услугам ТФОМС
              find (str(Loc_kod,7))
              do while hu->kod == Loc_kod .and. !eof()
                usl->(dbGoto(hu->u_kod))
                if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
                  lshifr := usl->shifr
                endif
                lshifr := alltrim(lshifr)
                flFFOMS := valtype(arr_osm1[i,13]) == 'C' .and. !empty(arr_osm1[i,13])    // есть соответствующая услуга ФФОМС
                if lshifr == alltrim(arr_osm1[i,5])
                  DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
                  if flFFOMS
                    select MOHU
                    // затем выберем информацию из mo_hu по услугам ФФОМС
                    set relation to u_kod into MOSU 
                    find (str(Loc_kod,7))
                    do while MOHU->kod == Loc_kod .and. !eof()
                      MOSU->(dbGoto(MOHU->u_kod))
                      lshifr := alltrim(iif(empty(MOSU->shifr),MOSU->shifr1,MOSU->shifr))
                      if alltrim(lshifr) == alltrim(arr_osm1[i,13])
                        DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
                        exit
                      endif
                      skip
                    enddo
                    select HU
                  endif
                  exit
                endif
                skip
              enddo

            else
              select MOHU
              // goto (arr_usl[indexUslugaEtap_DVN_COVID(metap, arr_osm1[i,5])])
              // if !eof() .and. !bof()
              //   DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
              // endif
              // затем выберем информацию из mo_hu по услугам ФФОМС
              set relation to u_kod into MOSU 
              find (str(Loc_kod,7))
              do while MOHU->kod == Loc_kod .and. !eof()
                MOSU->(dbGoto(MOHU->u_kod))
                lshifr := alltrim(iif(empty(MOSU->shifr),MOSU->shifr1,MOSU->shifr))
                select MOHU
                if alltrim(lshifr) == alltrim(arr_osm1[i,5])
                  DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
                  exit
                endif
                skip
              enddo

            endif
          endif
        next
      endif

      // if i2 < i1
      //   for i := i2+1 to i1
      //     select HU
      //     goto (arr_usl[i])
      //     DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
      //   next
      // endif
      save_arr_DVN_COVID(mkod)

      write_work_oper(glob_task,OPER_LIST,iif(Loc_kod==0,1,2),1,count_edit)
      fl_write_sluch := .t.
      close databases
      stat_msg("Запись завершена!",.f.)
    endif
    exit
  enddo

  close databases
  setcolor(tmp_color)
  restscreen(buf)
  chm_help_code := tmp_help
  if fl_write_sluch // если записали - запускаем проверку
    if type("fl_edit_DVN_COVID") == "L"
      fl_edit_DVN_COVID := .t.
    endif
    if !empty(val(msmo))
      verify_OMS_sluch(glob_perso)
    endif
  endif
  return NIL
