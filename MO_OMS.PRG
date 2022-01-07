***** mo_oms.prg - режимы ввода данных для задачи ОМС
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

*****
Function begin_task_oms()
Static n_zapusk := 0
Local i, fl := .t.
if n_zapusk == 0
  ++n_zapusk
  Public arr_opl_7, len_arr_7, mem_oms_pole := 0
endif
if G_SIsLock(sem_vagno_task[X_OMS])
  fl := f_err_sem_vagno_task(X_OMS)
elseif copy_Tools_Ini()
  Tools_Ini_OMS(1,0,0)
  i := GetIniVar(tmp_ini, {{"RAB_MESTO","oms_pole","0"}} )
  if i[1] != NIL
    mem_oms_pole := int(val(i[1]))
  endif
else
  fl := .f.
endif
return fl

***** 01.11.19 СМП - добавление или редактирование случая (листа учета)
Function oms_sluch_SMP(Loc_kod,kod_kartotek,tip_lu)
// Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
// tip_lu - TIP_LU_SMP или TIP_LU_NMP - скорая помощь (неотложная медицинская помощь)
Static mm_brigada, st_brigada, mm_trombolit, st_trombolit, mm_spec, SKOD_DIAG := '     ',;
       st_N_DATA, st_vrach := 0, st_rslt := 0, st_ishod := 0
Local top2, ar, ibrm := 0
Local bg := {|o,k| get_MKB10(o,k,.t.) }, arr_del := {}, mrec_hu := 0,;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
      arr_usluga := {}, p_uch_doc := "@!", pic_diag := "@K@!",;
      i, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0,;
      tmp_help := chm_help_code, fl_write_sluch := .f.
//
Default st_N_DATA TO sys_date
Default Loc_kod TO 0, kod_kartotek TO 0
Private row_diag_screen, rdiag := 1
if mem_smp_input == 0
  if  kod_kartotek == 0 // добавление в картотеку
    if (kod_kartotek := edit_kartotek(0,,,.t.)) == 0
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
    mokatog := padr(alltrim(okato_umolch),11,"0"),;
    m1adres_reg := 1, madres_reg,;
    rec_inogSMO := 0, ;
    mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100)
  if kod_kartotek > 0
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"kartotek",,"KART")
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
  find (glob_mo[_MO_KOD_TFOMS]+"71.")
  do while luslc->CODEMO == glob_mo[_MO_KOD_TFOMS] .and. left(luslc->shifr,3) == "71."
    // поиск цены по дате окончания лечения
    if between_date(luslc->datebeg,luslc->dateend,sys_date)
      if eq_any(left(luslc->shifr,5),"71.1.","71.2.")
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
    return func_error(4,"Ввод скорой помощи не разрешён в Вашей МО по состоянию на "+full_date(sys_date))
  endif
  asort(mm_brigada,,,{|x,y| x[2] < y[2] } )
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
    asort(mm_trombolit,,,{|x,y| val(x[2]) < val(y[2]) } )
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
ar := GetIniVar(tmp_ini,{{"RAB_MESTO","kart_polis","1"}} )
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
aeval(glob_V009,{|x| iif(x[5] == m1USL_OK, aadd(mm_rslt,x), nil) })
aeval(glob_V012,{|x| iif(x[5] == m1USL_OK, aadd(mm_ishod,x), nil) })
if ascan(mm_rslt, {|x| x[2] == rslt_umolch}) > 0
  m1rslt := rslt_umolch
endif
if ascan(mm_ishod, {|x| x[2] == ishod_umolch}) > 0
  m1ishod := ishod_umolch
endif
//
R_Use(dir_server+"human_2",,"HUMAN_2")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, recno() into HUMAN_2
if mkod_k > 0
  if mem_smp_input == 0
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
      mnameismo := ret_inogSMO_name(1,,.t.) // открыть и закрыть
    endif
  endif
  // проверка исхода = СМЕРТЬ
  select HUMAN
  set index to (dir_server+"humankk")
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
  R_Use(dir_server+"uslugi",,"USL")
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
    elseif tip_lu == TIP_LU_NMP .and. eq_any(alltrim(lshifr),"2.80.27","2.80.28") .and. mrec_hu == 0
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
    R_Use(dir_server+"mo_su",,"MOSU")
    G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
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
  R_Use(dir_server+"mo_pers",,"P2")
  goto (m1vrach)
  MTAB_NOM := p2->tab_nom
  m1prvs := -ret_new_spec(p2->prvs,p2->prvs_new)
  mvrach := padr(fam_i_o(p2->fio)+" "+ret_tmp_prvs(m1prvs),36)
endif
close databases
fv_date_r( iif(Loc_kod>0,mn_data,) )
MFIO_KART := _f_fio_kart()
mvzros_reb := inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
MNOVOR    := inieditspr(A__MENUVERT, mm_danet, M1NOVOR)
MF14_EKST := inieditspr(A__MENUVERT, mm_ekst_smp, M1F14_EKST)
mrslt     := inieditspr(A__MENUVERT, glob_V009, m1rslt)
mishod    := inieditspr(A__MENUVERT, glob_V012, m1ishod)
mlpu      := inieditspr(A__POPUPMENU, dir_server+"mo_uch", m1lpu)
motd      := inieditspr(A__POPUPMENU, dir_server+"mo_otd", m1otd)
MKEMVYD   := inieditspr(A__POPUPMENU, dir_server+"s_kemvyd", M1KEMVYD)
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
  {"usluga","N",10,0,,,,{|x|inieditspr(A__MENUBIT,mm_usluga,x)} };
 }
@ maxrow(),0 say padc("<Esc> - выход;  <PgDn> - запись;  <F1> - помощь",maxcol()+1) color color0
mark_keys({"<F1>","<Esc>","<PgDn>"},"R/BG")
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
       reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
       valid {|g,o| update_get("mkomu"),update_get("mcompany") }
else
  ++j; @ j,1 say "Полис ОМС: серия" get mspolis when m1komu == 0
       @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0 ;
                       valid {|| findKartoteka(2,@mkod_k) }
       @ row(),col()+3 say "вид"    get mvidpolis ;
                    reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
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
            reader {|x|menu_reader(x,menupol,A__MENUVERT,,,.f.)}
  else
    @ row(),70 say "Пол" get mpol pict "@!" valid {|g| mpol $ "МЖ" }
  endif
  ++j ; @ j,1 say "Дата рождения" get mdate_r ;
         valid {|| fv_date_r(mn_data), findKartoteka(1,@mkod_k) }
  @ row(),30 say "==>" get mvzros_reb when .f. color cDataCSay
  @ row(),50 say "СНИЛС" get msnils pict picture_pf ;
         valid {|| val_snils(msnils,1), findKartoteka(3,@mkod_k) }
  ++j ; @ j,1 say "Уд-ие личности:" get mvid_ud ;
         reader {|x|menu_reader(x,menu_vidud,A__MENUVERT,,,.f.)}
         @ j,42 say "Серия" get mser_ud pict "@!" valid val_ud_ser(1,m1vid_ud,mser_ud)
         @ j,col()+1 say "№" get mnom_ud pict "@!S18" valid val_ud_nom(1,m1vid_ud,mnom_ud)
  if tip_lu == TIP_LU_NMP
    ++j ; @ j,2 say "Место рождения" get mmesto_r pict "@S62"
    ++j ; @ j,2 say "Выдано" get mkogdavyd
          @ j,col() say "," get mkemvyd ;
          reader {|x|menu_reader(x,{{|k,r,c|get_s_kemvyd(k,r,c)}},A__FUNCTION,,,.f.)}
  endif
  ++j ; @ j,1 say "Адрес регистрации" get madres_reg ;
        reader {|x| menu_reader(x,{{|k,r,c| get_adres(1,k,r,c)}},A__FUNCTION,,,.f.)}
endif
  ++j; @ j,1 say "Принадлежность счёта" get mkomu ;
             reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
             valid {|g,o| f_valid_komu(g,o) } ;
             color colget_menu
       @ row(),col()+1 say "==>" get mcompany ;
           reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
           when diag_screen(2) .and. m1komu < 5 ;
           valid {|g| func_valid_ismo(g,m1komu,38) }
  //
if mem_smp_input == 0
  ++j; @ j,1 say "Полис ОМС: серия" get mspolis when m1komu == 0
       @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0
       @ row(),col()+3 say "вид"    get mvidpolis ;
                    reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
                    when m1komu == 0 ;
                    valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
endif
  //
  ++j; @ j,1 say "Новорожденный?" get mnovor ;
             reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
             valid {|g,o| f_valid_novor(g,o) } ;
             color colget_menu
       @ row(),col()+3 say "№/пп ребёнка" get mcount_reb pict "99" range 1,99 ;
             when (m1novor == 1)
       @ row(),col()+3 say "Д.р. ребёнка" get mdate_r2 when (m1novor == 1)
  if mem_pol == 1
       @ row(),col()+3 say "Пол ребёнка" get mpol2 ;
           reader {|x|menu_reader(x,menupol,A__MENUVERT,,,.f.)} ;
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
       @ row(),col() say "," get mkod_diag2 picture pic_diag ;
             reader {|o|MyGetReader(o,bg)} ;
             when when_diag() ;
             valid val1_10diag(.t.,.t.,.t.,mn_data,iif(m1novor==0,mpol,mpol2))
if tip_lu == TIP_LU_SMP
       @ row(),col()+3 say "Форма оказания СМП" get MF14_EKST ;
            reader {|x|menu_reader(x,mm_ekst_smp,A__MENUVERT,,,.f.)}
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
              reader {|x| menu_reader(x,mm_prer_b,A__MENUVERT,,,.f.)} ;
              when {|| diag_screen(2),;
                       ibrm := f_oms_beremenn(mkod_diag),;
                       mm_prer_b := iif(ibrm == 1, mm1prer_b, iif(ibrm == 2, mm2prer_b, mm3prer_b)),;
                       (ibrm > 0) }
  //
  ++j; @ j,1 say "Результат обращения" get mrslt ;
           reader {|x|menu_reader(x,mm_rslt,A__MENUVERT,,,.f.)} ;
           valid {|g,o| f_valid_rslt(g,o) }
  //
  ++j; @ j,1 say "Исход заболевания" get mishod ;
           reader {|x|menu_reader(x,mm_ishod,A__MENUVERT,,,.f.)}
  //
if tip_lu == TIP_LU_SMP
 if empty(mm_trombolit)
  ++j; @ j,1 say "Бригада СМП" get mbrig ;
            reader {|x|menu_reader(x,mm_brig,A__MENUVERT,,,.f.)}
 else
  ++j; @ j,1 say "Тромболитическая терапия:" get mtip ;
            reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
            valid {|g,o| f_valid_brig(g,o,mm_brigada,mm_trombolit,st_brigada,st_trombolit) }
       @ j,32 say "Бригада СМП" get mbrig ;
            reader {|x|menu_reader(x,mm_brig,A__MENUVERT,,,.f.)}
 endif
 if mem_smp_tel == 1
  ++j; @ j,1 say "Услуга(и) телемедицины" get musluga ;
             reader {|x| menu_reader(x,mm_usluga,A__MENUBIT,,,.f.)}
 endif
else
  ++j; @ j,1 say "Врач (фельдшер)" get mspec ;
            reader {|x|menu_reader(x,mm_spec,A__MENUVERT,,,.f.)}
endif
  //
  ++j; @ j,1 say "Таб.№ врача (фельдшера)" get MTAB_NOM pict "99999" ;
             valid {|g| v_kart_vrach(g,.t.) } when diag_screen(2)
       @ row(),col()+1 get mvrach when .f. color color14
  if !empty(a_smert)
    n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
  endif
  if pos_read > 0 .and. lower(GetList[pos_read]:name) == "mvrach"
    --pos_read
  endif
  count_edit := myread(,@pos_read,++k_read)
  diag_screen(2)
  k := f_alert({padc("Выберите действие",60,".")},;
               {" Выход без записи "," Запись "," Возврат в редактирование "},;
               iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
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
      func_error(4,"Тромболитическая терапия разрешена только с 2016 года.")
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
        func_error(4,"Не введены Ф.И.О. Нет записи!")
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
      func_error(4,"Не введен шифр основного заболевания.")
      loop
    endif
    err_date_diap(mn_data,"Дата выезда")
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
        if is_komm_SMP() .and. mk_data < 0d20190501 // если это коммерческая скорая
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
    R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                                dir_server+"uslugi1s"},"USL1")
    Private mu_kod, mu_cena
    glob_podr := "" ; glob_otd_dep := 0
    mu_kod := foundOurUsluga(lshifr,mk_data,m1PROFIL,M1VZROS_REB,@mu_cena)
    if mem_smp_input == 1
      mfio := rtrim(mfam)+" "+rtrim(mim)+" "+mot
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
        G_Use(dir_server+"mo_kfio",,"KFIO")
        index on str(kod,7) to (cur_dir+"tmp_kfio")
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
        G_Use(dir_server+"mo_kismo",,"SN")
        index on str(kod,7) to (cur_dir+"tmp_ismo")
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
    human_->FORMA14   := str(M1F14_EKST,1)+"000"
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
Function f_valid_brig(get,old,menu1,menu2,st1,st2)
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

* разные функции для oms_sluch()

***** 10.02.17
Function get_fio_kart(k,r,c)
Local s := "", ret, buf, tmp_keys
Private fl_write_kartoteka := .f.
buf := savescreen()
tmp_keys := my_savekey()
edit_kartotek(mkod_k,r+1,,.t.,mkod)
my_restkey(tmp_keys)
if fl_write_kartoteka
  R_Use(dir_server+"kartote2",,"KART2")
  goto (mkod_k)
  R_Use(dir_server+"kartote_",,"KART_")
  goto (mkod_k)
  R_Use(dir_server+"kartotek",,"KART")
  goto (mkod_k)
  M1FIO := 1 ; mfio := kart->fio ; mpol := kart->pol ; mdate_r := kart->date_r
  mfio_kart := _f_fio_kart()
  if type("mn_data") == "D"
    if type("m1novor") == "N" .and. type("mdate_r2") == "D" .and. m1novor > 0
      mvozrast := count_years(mdate_r2,mn_data)
    else
      mvozrast := count_years(mdate_r,mn_data)
    endif
  endif
  if type("m1novor") == "N" .and. m1novor > 0
    M1VZROS_REB := 1 // ребенок
  else
    M1VZROS_REB := kart->VZROS_REB
  endif
  mADRES      := kart->ADRES
  mMR_DOL     := kart->MR_DOL
  m1RAB_NERAB := kart->RAB_NERAB
  m1komu      := kart->komu
  mPOLIS      := kart->POLIS
  m1VIDPOLIS  := kart_->VPOLIS
  mSPOLIS     := kart_->SPOLIS
  mNPOLIS     := kart_->NPOLIS
  msmo        := kart_->SMO
  m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
  mokato      := inieditspr(A__MENUVERT, glob_array_srf, m1okato)
  mkomu       := inieditspr(A__MENUVERT, mm_komu, m1komu)
  mvidpolis   := inieditspr(A__MENUVERT, mm_vid_polis, m1vidpolis)
  if !empty(mn_data)
    fv_date_r(mn_data,.f.)
  endif
  f_valid_komu(,-1)
  m1company   := int(val(msmo))
  mcompany    := inieditspr(A__MENUVERT, mm_company, m1company)
  if m1company == 34
    mnameismo := ret_inogSMO_name(1,,.t.) // открыть и закрыть
  elseif !(left(msmo,2) == '34')
    m1ismo := msmo ; msmo := '34' ; m1company := 34
    mismo := init_ismo(m1ismo)
  endif
  if m1company == 34
    if !empty(mismo)
      mcompany := mismo
    elseif !empty(mnameismo)
      mcompany := mnameismo
    endif
  endif
  if !empty(mcompany)
    old_name_smo := padr(mcompany,38)
  endif
  if m1komu > 0
    m1company := 0 ; mcompany := ""
    if eq_any(m1komu,1,3)
      m1company := m1str_crb := kart->STR_CRB
      mcompany := inieditspr(A__MENUVERT, mm_company, m1company)
    endif
  endif
  mcompany := padr(mcompany,38)
  if eq_any(is_uchastok,1,3)
    s := amb_kartaN()
  elseif mem_kodkrt == 2
    s := lstr(mkod_k)
  endif
  if !empty(s) .and. valtype(MUCH_DOC) == "C"
    if empty(MUCH_DOC)
      MUCH_DOC := padr(s,10)
    elseif is_uchastok == 3 .and. !(MUCH_DOC == padr(s,10))
      MUCH_DOC := padr(s,10)
    endif
  endif
  close databases
endif
restscreen(buf)
return ret

***** 24.02.16
Function _f_fio_kart()
return padr(alltrim(mfio)+" "+iif(mpol=="М","(муж.)","(жен.)"),50)

***** проверка правильности ввода стоматологического статуса больного
Function f_valid_status_st(get)
Local i, s := "", fl := .t.
for i := 1 to len(mstatus_st)
  if !empty(c := substr(mstatus_st,i,1)) .and. !(c $ yes_d_plus)
    s += c
  endif
next
if !empty(s)
  fl := func_error(4,'Следующие символы не разрешены для ввода в данном поле: "'+s+'"')
endif
return fl

***** действия в ответ на выбор в меню "Новорожденный? (да/нет)"
Function f_valid_novor(get,old)
if m1novor != old .and. old != NIL
  if old == 0 // было "нет" - стало "да"
    mcount_reb := 1 ; mDATE_R2 := sys_date-5 ; mpol2 := "М"
  else
    mcount_reb := 0 ; mDATE_R2 := ctod("") ; mpol2 := " "
  endif
  update_get("mcount_reb")
  update_get("mDATE_R2")
  update_get("mpol2")
endif
fv_date_r(mn_data)
return .t.

***** действия в ответ на выбор в меню "Принадлежность счёта"
Function f_valid_komu(get,old)
Local tmp_select := select()
if m1komu != old .and. old != NIL
  m1company := 0 ; mcompany := space(30) ; mm_company := {}
  if m1komu == 0 // ОМС
    mm_company := aclone(glob_arr_smo)
  elseif m1komu == 1 // Прочие компании
    R_Use(dir_server+"str_komp")
    index on upper(name) to (cur_dir+"tmp_comp") for !between(tfoms,44,47)
    dbeval({|| aadd(mm_company,{alltrim(name),kod}) } )
    Use
  elseif m1komu == 3 // Комитеты/МО
    R_Use(dir_server+"komitet")
    index on upper(name) to (cur_dir+"tmp_comp")
    dbeval({|| aadd(mm_company,{alltrim(name),kod}) } )
    Use
  endif
  if eq_any(m1komu,1,3) .and. empty(mm_company)
    mm_company := {{"Пустой справочник",0}}
  endif
  update_get("mcompany")
endif
select (tmp_select)
return .t.

***** 20.02.20 действия в ответ на выбор в меню "Условия оказания медицинской помощи"
Function f_valid_usl_ok(get,old,is_input)
Local _y, _m, s
DEFAULT is_input TO .t.
if m1usl_ok != old .and. m1usl_ok > 0 .and. old != NIL
  mm_rslt := {}
  if m1usl_ok == 3 .and. is_input // поликлиника - убираем диспансеризацию
    aeval(tmp_V009,{|x| iif(x[5]==m1usl_ok.and.x[2]<316, aadd(mm_rslt,x), nil) })
  else
    aeval(tmp_V009,{|x| iif(x[5]==m1usl_ok, aadd(mm_rslt,x), nil) })
  endif
  mm_ishod := {}
  aeval(tmp_V012,{|x| iif(x[5]==m1usl_ok, aadd(mm_ishod,x), nil) })
  if get != NIL
    m1rslt := 0 ; mrslt := ""
    if ascan(mm_rslt, {|x| x[2] == rslt_umolch}) > 0
      m1rslt := rslt_umolch
      mrslt := inieditspr(A__MENUVERT, tmp_V009, m1rslt)
    endif
    m1ishod := 0 ; mishod := ""
    if ascan(mm_ishod, {|x| x[2] == ishod_umolch}) > 0
      m1ishod := ishod_umolch
      mishod := inieditspr(A__MENUVERT, tmp_V012, m1ishod)
    endif
    mrslt  := padr(mrslt ,60)
    mishod := padr(mishod,60)
    update_get("mrslt")
    update_get("mishod")
  endif
endif
if is_input .and. type("p_nstr_vnr") == "N"
  s := "" ; input_vnr := input_vnrm := .f.
  if m1usl_ok == 1 // стационар
    count_ymd(iif(M1NOVOR==1,mdate_r2,mdate_r),mn_data,@_y,@_m,)
    //if _y == 0 .and. _m < 7 // ребёнок не старше 6 месяцев
    if _y == 0 // ребёнок до года
      s := p_str_vnr ; input_vnr := .t.
    else
      MVNR := space(4)
    endif
    if mpol == "Ж" .and. _y > 10 // "мамаша" старше 10 лет
      s := p_str_vnrm ; input_vnrm := .t.
    else
      MVNR1 := MVNR2 := MVNR3 := space(4)
    endif
  else // другие условия оказания мед.помощи
    MVNR := MVNR1 := MVNR2 := MVNR3 := space(4)
  endif
  @ p_nstr_vnr,1 say padr(s,maxcol()) color cDataCGet
  if input_vnr
    update_get("MVNR")
  elseif input_vnrm
    update_get("MVNR1")
    update_get("MVNR2")
    update_get("MVNR3")
  endif
  if !((m1usl_ok==1 .and. (is_ksg_VMP .or. is_21_VMP .or. is_12_VMP .or. is_14_VMP)) .or. (m1usl_ok==2 .and. is_ds_VMP))
    mvmp := "нет"        ; m1vmp := 0
    MVIDVMP := space(70) ; M1VIDVMP := SPACE(12) // вид ВМП по справочнику V018
    MMETVMP := space(67) ; M1METVMP := 0        // метод ВМП по справочнику V019
    update_get("MVIDVMP")
    update_get("MMETVMP")
  endif
endif
return .t.

***** действия в ответ на выбор в меню "Результат"
Function f_valid_rslt(g,o)
if is_death(m1RSLT)
else
endif
return .t.

***** действия в ответ на выбор в меню "Госпитализация"
Function f_valid_f14_ekst(get,old)
// Static Function f_valid_f14_ekst(get,old)
if M1F14_EKST != old .and. old != NIL
endif
return .t.

***** 23.01.18 действия в ответ на выбор в меню "ВМП"
Function f_valid_vmp(get,old)
if m1vmp != old .and. old != NIL
  if m1vmp == 0
    mTAL_D := mTAL_P := ctod("")
    MVIDVMP := space(70) ; M1VIDVMP := SPACE(12) // вид ВМП по справочнику V018
    MMETVMP := space(67) ; M1METVMP := 0        // метод ВМП по справочнику V019
  else
    input_ad_cr := .f. ; mad_cr := space(66) ; m1ad_cr := space(10)
  endif
  update_get("mTAL_D")
  update_get("mTAL_P")
  update_get("MVIDVMP")
  update_get("MMETVMP")
endif
return .t.

***** 17.01.14 действия в ответ на выбор в меню "Вид ВМП"
Function f_valid_vidvmp(get,old)
if empty(m1vidvmp)
  MMETVMP := space(67) ; M1METVMP := 0
  update_get("MMETVMP")
elseif !(m1vidvmp == old) .and. old != NIL .and. get != NIL
  MMETVMP := space(67) ; M1METVMP := 0
  update_get("MMETVMP")
endif
return .t.

***** действия в ответ на выбор в меню "Больничный"
Function f_valid_bolnich(get,old)
if m1bolnich != old .and. old != NIL
  if m1bolnich == 0
    MDATE_B_1 := ctod("")
    MDATE_B_2 := ctod("")
  endif
  if m1bolnich != 2
    mrodit_dr  := ctod("")
    mrodit_pol := " "
  endif
  if m1bolnich > 0
    MDATE_B_1 := mn_data
    MDATE_B_2 := mk_data
    if m1bolnich == 2                         // по умолчанию больничный выдали
      mrodit_dr  := addmonth(sys_date,-25*12) // 25 летней
      mrodit_pol := "Ж"                       // матери
    endif
  endif
  update_get("MDATE_B_1")
  update_get("MDATE_B_2")
  update_get("mrodit_dr")
  update_get("mrodit_pol")
endif
return .t.

***** проверка введённого цифрами повода обращения
Function val_st_pov(get)
Local i, fl := .t.
if (i := ascan(stm_povod, {|x| x[2] == m1povod } )) > 0
  mpovod := padr(stm_povod[i,1],23) ; update_get("mpovod")
else
  fl := func_error(4,"Недопустимый шифр повода обращения")
  m1povod := get:original
endif
return fl

***** проверка введённого цифрами вида травмы
Function val_st_trav(get)
Local i, fl := .t.
if (i := ascan(stm_travma, {|x| x[2] == m1travma } )) > 0
  mtravma := padr(stm_travma[i,1],34) ; update_get("mtravma")
else
  fl := func_error(4,"Недопустимый шифр вида травмы")
  m1travma := get:original
endif
return fl

***** 11.08.20
Function inp_dop_diag()
Local arr, jt, mshifr, tmp_keys, tmp_gets, buf, tmp_color
Private mvar := upper(readvar())
if empty(mvar) .or. !(type(mvar) == "C")
  return .t.
endif
mshifr := &mvar
arr := {"MKOD_DIAG" ,;
        "MKOD_DIAG2",;
        "MKOD_DIAG3",;
        "MKOD_DIAG4",;
        "MSOPUT_B1" ,;
        "MSOPUT_B2" ,;
        "MSOPUT_B3" ,;
        "MSOPUT_B4"}
if !empty(mshifr) .and. (jt := ascan(arr,mvar)) > 0
  tmp_keys := my_savekey()
  save gets to tmp_gets
  buf := savescreen()
  change_attr()
  Private pr := 9, m1, m2
  m1 := adiag_talon[jt*2-1]
  m2 := adiag_talon[jt*2  ]
  box_shadow(pr,2,pr+4,77,color0,'Диагноз "'+alltrim(mshifr)+'"',"W+/BG")
  tmp_color := setcolor("N/BG,W+/N,,,B/BG")
  @ pr+1,5 say "Характер заболевания (1,2) " get m1 pict "9" valid {|g| v_i_d_diag(g,1) }
  @ pr+2,5 say "Диспансерный учет  (1,2,3) " get m2 pict "9" valid {|g| v_i_d_diag(g,2) }
  status_key("^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода")
  myread()
  if lastkey() != K_ESC
    adiag_talon[jt*2-1] := m1
    adiag_talon[jt*2  ] := m2
  endif
  keyboard chr(K_ENTER)
  restscreen(buf)
  restore gets from tmp_gets
  my_restkey(tmp_keys)
  setcolor(tmp_color)
  setcursor()
  put_dop_diag()
endif
return .t.

*****
Static Function v_i_d_diag(get,par)
Local fl := .t., mval, s := ""
Private mvar := upper(readvar())
mval := &mvar
if mval > 0
  do case
    case par == 1
      if (fl := between(m1,1,2))
        s := {"Выявлено впервые в жизни (или острое)",;
              "Ранее зарегистрированное заболевание"}[m1]
      endif
    case par == 2
      if (fl := between(m2,1,3))
        s := {"Состоит",;
              "Взят",;
              "Снят"}[m2]
      endif
  endcase
endif
@ pr+par,35 say padr(s,42) color "G+/BG"
if !fl
  &mvar := get:original
  mybell()
endif
return fl

*****
Function func_valid_ismo(get,lkomu,sh,name_var)
Local r1, r2, n := 4, buf, tmp_keys, tmp_list, tmp_color
DEFAULT name_var TO "company"
Private mvar := "m1"+name_var
if lkomu == 0 .and. &mvar == 34
  if get:row() > 18
    r2 := get:row()-1 ; r1 := r2-n
  else
    r1 := get:row()+1 ; r2 := r1+n
  endif
  buf := savescreen()
  change_attr()
  tmp_keys := my_savekey()
  save gets to tmp_list
  Private mm_ismo := {}
  box_shadow(r1,2,r2,77,"N+/W","Ввод иногородней СМО","GR/W")
  tmp_color := setcolor("N/W,W+/N,,,B/W")
  @ r1+1,4 say "Субъект РФ" get mokato ;
            reader {|x| menu_reader(x,;
                  {{|k,r,c| get_srf(k,r,c) },62},A__FUNCTION,,,.f.)} ;
            valid {|g,o| when_ismo(g,o) }
  @ r1+2,4 say "СМО" get mismo ;
           reader {|x|menu_reader(x,mm_ismo,A__MENUVERT,,,.f.)} ;
           when {|| len(mm_ismo) > 0 .and. empty(mnameismo) } ;
           valid {|| iif(empty(mismo),,mnameismo:=space(100)), .t. }
  @ r1+3,4 say "Наименование СМО" get mnameismo pict "@S56" ;
           when empty(m1ismo)
  myread()
  setcolor(tmp_color)
  restore gets from tmp_list
  my_restkey(tmp_keys)
  restscreen(buf)
  if !emptyall(mismo,mnameismo)
    mvar := "m"+name_var
    &mvar := padr(iif(emptyall(mismo),mnameismo,mismo),sh)
  endif
endif
return .t.

*****
Static Function get_srf(k,r,c)
Local ret, t_arr[BR_LEN], fl := .f.
Private muslovie := ".t.", str_find := ""
if r <= maxrow()/2
  t_arr[BR_TOP] := r
  t_arr[BR_BOTTOM] := maxrow()-2
else
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := r-1
endif
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "Выбор субъекта РФ (территории страхования)"
t_arr[BR_TITUL_COLOR] := "BG+/GR"
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.f.,72}
t_arr[BR_COLUMN] := {{"ОКАТО", {|| tmp->okato }},;
                     { center("Наименование",66),{|| left(tmp->name,66)} }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке") }
t_arr[BR_EDIT] := {|nk,ob| f2_srf(nk,ob) }
t_arr[BR_ENTER] := {|| ret := {tmp->okato,tmp->name} }
//
use (cur_dir+"tmp_srf") new alias TMP
set filter to !(okato=='18000')
if !empty(k)
  Locate for okato==k
  if !found()
    go top
  endif
endif
edit_browse(t_arr)
tmp->(dbCloseArea())
return ret

*****
Static Function f2_srf(nk,ob)
Static stmp1 := ""
Local rec1 := recno(), buf := savescreen(), tmp_color, ret := -1,;
      r1 := pr2-6, r2 := pr2-1, i, j, lf, s, rec
if nk == K_F2
  box_shadow(r1,pc1+1,r2,pc2-1,cDataPgDn,"Поиск по ключу",cDataCSay)
  tmp_color := setcolor(cDataCGet)
  @ r1+2,pc1+2 say center("Введите ключевое слово",pc2-pc1-3)
  setcolor(cDataCGet)
  tmp := padr(stmp1,pc2-pc1-3)
  status_key("^<Esc>^ - отказ от ввода")
  @ r1+3,pc1+2 get tmp picture "@K@!"
  myread()
  setcolor(color0)
  if lastkey() == K_ESC .or. empty(tmp)
    goto (rec1)
  else
    tmp := alltrim(tmp)
    stmp1 := tmp
    Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := pr1+3, k2 := pr2-1
    ob:goTop()
    do while !eof()
      if tmp $ upper(tmp->name)
        aadd(tmp_mas, tmp->name)
        aadd(tmp_kod, recno())
      endif
      skip
    enddo
    if (t_len := len(tmp_kod)) == 0
      func_error(3,"Неудачный поиск!")
      goto (rec1)
    else
      box_shadow(pr1,pc1,pr2,pc2)
      SETCOLOR("B/BG")
      @ pr1+1,pc1+2 say "Ключ: "+tmp
      SETCOLOR(color0)
      if t_len < pr2-pr1-5
        k2 := k1 + t_len + 2
      endif
      @ k1,pc1+1 say padc("Найденное количество - "+lstr(t_len),pc2-pc1-1)
      status_key("^<Esc>^ - отказ от выбора")
      if (i := popup(k1+1,pc1+1,k2,pc2-1,tmp_mas,1,0)) > 0
        ob:goTop()
        goto (tmp_kod[i])
        ret := 0
      endif
    endif
  endif
endif
return ret

*****
Static Function when_ismo(get,old)
Local s
if !(m1okato == old) .and. old != NIL
  m1ismo := "" ; mismo := space(len(mismo))
endif
mm_ismo := {}
if !empty(m1okato)
  R_Use(exe_dir+"_mo_smo",cur_dir+"_mo_smo","SMO")
  find (m1okato)
  do while smo->okato == m1okato .and. !eof()
    s := alltrim(smo->name)
    if !empty(smo->d_end)
      s += " (до "+full_date(smo->d_end)+")"
    endif
    aadd(mm_ismo, {s,smo->smo})
    skip
  enddo
  smo->(dbCloseArea())
endif
return len(mm_ismo) > 0

***** 20.12.18
Function f_oms_usl_sluch(oBrow)
Local oColumn, blk_color
oColumn := TBColumnNew(" NN; пп",{|| tmp->number })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
if mem_ordusl == 1
  oColumn := TBColumnNew("Дата; усл.",{|| left(dtoc(tmp->date_u1),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew(" Шифр услуги",{|| iif(tmp->dom==-1,padr(tmp->shifr_u,11)+"дом",;
                                           iif(tmp->dom==-2,padr(tmp->shifr_u,11)+"д-А",;
                                           padr(tmp->shifr_u,14))) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
if mem_ordusl == 2
  oColumn := TBColumnNew("Дата; усл.",{|| left(dtoc(tmp->date_u1),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("Отде-;ление",{|| otd->short_name })
oColumn:defColor := {6,6}
oColumn:colorBlock := {|| {6,6} }
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("МКБ10",{|| tmp->kod_diag })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Профиль услуги",{|| padr(inieditspr(A__MENUVERT,glob_V002,tmp->PROFIL),15) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Врач",{|| put_val(ret_tabn(tmp->kod_vr),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Асс.",{|| put_val(ret_tabn(tmp->kod_as),5) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол;усл",{|| str(tmp->kol_1,3) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Общая; ст-ть",{|| put_kop(tmp->stoim_1,8) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление; ^<F1>^ помощь")
return NIL

***** 20.12.18
Function f1oms_usl_sluch()
LOCAL nRow := ROW(), nCol := COL(), s := tmp->name_u, lcolor := cDataCSay
if is_zf_stomat == 1 .and. !empty(tmp->zf)
  s := alltrim(tmp->zf)+" / "+s
  lcolor := color8
endif
@ maxrow()-2,2 say padr(s,65) color lcolor
if empty(tmp->u_cena)
  s := iif(tmp->n_base==0, "", "ФФОМС")
else
  s := alltrim(dellastnul(tmp->u_cena,10,2))
endif
@ maxrow()-2,68 say padc(s,11) color cDataCSay
f3oms_usl_sluch()
@ nRow, nCol SAY ""
return NIL

*****
Function f3oms_usl_sluch()
@ maxrow()-4,59 say padl("Итого: "+lstr(human->cena_1,11,2),20) color "W+/N"
return NIL

***** 28.02.18
Function verify_OMS_sluch(mkod)
Local buf := save_maxrow(), fl := .t., name_file := "err_sl"+stxt
mywait()
f_create_diag_srok()
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("Список обнаруженных ошибок",80))
add_string(center("в листе учёта",80))
add_string("")
//
R_Use(dir_server+"mo_pers",,"PERS")
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
use_base("lusl")
use_base("luslc")
use_base("luslf")
R_Use(dir_server+"uslugi",,"USL")
G_Use(dir_server+"human_u_",,"HU_")
G_Use(dir_server+"human_u",{dir_server+"human_u",;
                            dir_server+"human_uk",;
                            dir_server+"human_ud",;
                            dir_server+"human_uv",;
                            dir_server+"human_ua"},"HU")
set relation to recno() into HU_, to u_kod into USL
R_Use(dir_server+"mo_su",,"MOSU")
G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
set relation to u_kod into MOSU
G_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_
G_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","ONKNA") // онконаправления
G_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","ONKSL") // Сведения о случае лечения онкологического заболевания
G_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","ONKDI") // Диагностический блок
G_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","ONKPR") // Сведения об имеющихся противопоказаниях
G_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","ONKUS")
G_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","ONKCO")
G_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","ONKLE")
G_Use(dir_server+"human_2",,"HUMAN_2")
G_Use(dir_server+"human_",,"HUMAN_")
G_Use(dir_server+"human",{dir_server+"humans",;
                          dir_server+"humankk",;
                          dir_server+"humand"},"HUMAN")
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
goto (mkod)
if empty(human->k_data)
  //
elseif year(human->k_data) > 2018
  fl := verify_1_sluch()
else
  fl := verify_1_sluch_18()
endif
if d_srok->(lastrec()) > 0
  am := {"78","80","88","89"}
  if fl
    uch->(dbGoto(human->LPU))
    otd->(dbGoto(human->OTD))
    add_string(alltrim(human->fio)+" "+alltrim(human->kod_diag)+" "+;
               date_8(human->n_data)+"-"+date_8(human->k_data)+;
               iif(d_srok->tip==0, "", " (2."+am[d_srok->tip]+".*)"))
    add_string(alltrim(uch->name)+'/'+alltrim(otd->name)+'/профиль по "'+;
               inieditspr(A__MENUVERT, glob_V002, human_->profil)+'"')
    pers->(dbGoto(human_->VRACH))
    add_string("лечащий врач ["+lstr(pers->tab_nom)+"] "+pers->fio)
  endif
  select HUMAN
  goto (d_srok->kod1)
  uch->(dbGoto(human->LPU))
  otd->(dbGoto(human->OTD))
  add_string("")
  add_string(center("Предупреждение!",80))
  add_string("")
  add_string("Обратите внимание, что "+lstr(d_srok->dni)+" дней назад обнаружен случай")
  add_string("с основным диагнозом "+alltrim(human->kod_diag)+" "+;
             date_8(human->n_data)+"-"+date_8(human->k_data)+;
             iif(d_srok->tip1==0, "", " (2."+am[d_srok->tip1]+".*)"))
  add_string(alltrim(uch->name)+'/'+alltrim(otd->name)+'/профиль по "'+;
             inieditspr(A__MENUVERT, glob_V002, human_->profil)+'"')
  pers->(dbGoto(human_->VRACH))
  add_string("лечащий врач ["+lstr(pers->tab_nom)+"] "+pers->fio)
  fl := .f.
endif
close databases
fclose(fp)
rest_box(buf)
if !fl
  viewtext(name_file,,,,.t.,,,5)
endif
return NIL

***** 06.01.22 Добавление листка учета лечения больного
Function oms_add()
  Local buf, str_sem

  change_sys_date() // перечитать системную дату (для травмпунктов, работающих ночами)
  if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. input_otd(T_ROW-1,T_COL+5,sys_date) != NIL
    buf := box_shadow(0,41,2,77,color13)
    @ 1,42 say padc(glob_otd[2],35) color color14
    Private fl_edit_oper, fl_edit_smp, fl_edit_DDS, fl_edit_DVN, fl_edit_DVN_COVID
    do while .t.
      fl_edit_oper := fl_edit_smp := fl_edit_DDS := fl_edit_DVN := fl_edit_DVN_COVID := .f.
      polikl_kart(1)
      if fl_edit_oper
        str_sem := "Редактирование человека "+lstr(glob_perso)
        if G_SLock(str_sem)
          oms_usl_sluch(glob_perso,glob_kartotek,.f.)

          if check_oms_sluch_lek_pr(glob_perso)
            oms_sluch_lek_pr(glob_perso, glob_kartotek, .f.)
          endif

          G_SUnLock(str_sem)
        else
          func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
        endif
      elseif fl_edit_smp .or. fl_edit_DDS .or. fl_edit_DVN .or. fl_edit_DVN_COVID
        // не выходим из цикла
      else
        exit
      endif
    enddo
    if buf != NIL
      rest_box(buf)
    endif
  endif
  return NIL

***** Редактирование листка учета лечения больного
Function oms_edit(k)
Static sk := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"Выбор по учреждению/отделению",;
                "Выбор по отчётному периоду",;
                "Выбор по ошибке из ТФОМС",;
                "Выбор по акту снятия из СМО"}
    mas_msg := {"Редактирование случая с выбором по учреждению/отделению",;
                "Редактирование случая с выбором по отчётному периоду",;
                "Редактирование случая с выбором по конкретной ошибке из ТФОМС",;
                "Редактирование повторно выставленных случаев (после ввода актов снятия из СМО)"}
    mas_fun := {"oms_edit(1)",;
                "oms_edit(2)",;
                "oms_edit(3)",;
                "oms_edit(4)"}
    //set key K_CTRL_F11 to my_extract_reestr()
    // set key K_CTRL_F12 to create_main_base_from_reestrs()
//test_definition_KSG()
    popup_prompt(T_ROW,T_COL+5,sk,mas_pmt,mas_msg,mas_fun)
    // set key K_CTRL_F12 to
    //set key K_CTRL_F11 to
  case k == 1
    f1oms_edit()
  case k == 2
    f2oms_edit()
  case k == 3
    if !find_unfinished_reestr_sp_tk()
      f3oms_edit()
    endif
  case k == 4
    f4oms_edit()
endcase
if k > 0
  sk := k
endif
return NIL

***** 05.02.19 Редактирование случая с выбором по учреждению/отделению
Function f1oms_edit()
Static si := 1, sk := 1
Local buf, mas_pmt, arr_m, str_sem, i, buf24, buf_scr, dostup, k := 1,;
      str_error, mtitul, str_find
if (arr_m := input_year()) != NIL .and. ;
      input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
          iif(yes_h_otd==1, input_otd(T_ROW-1,T_COL+5,sys_date)!=NIL, .t.)
  if yes_vypisan == B_END
    if (k := popup_prompt(T_ROW,T_COL+5,sk,;
              {"~Не закончившие лечение","~Закончившие лечение"})) > 0
      sk := k
    endif
    if k == 0
      return NIL
    endif
  endif
  dostup := yes_vypisan+k-1
  str_error := "В данный момент"
  mtitul := alltrim(glob_uch[2])
  str_find := str(dostup,1)
  if yes_h_otd == 1
    mtitul += " [ "+alltrim(glob_otd[2])+" ]"
    str_error += " в данном отделении"
    str_find += str(glob_otd[1],3)
  endif
  str_error += " нет пациентов"
  if dostup == B_STANDART
    str_error += ", закончивших лечение"
  else
    str_error += ", не закончивших лечение"
  endif
  if arr_m != NIL
    str_error += " "+arr_m[4]
    mtitul += " "+arr_m[4]
  endif
  buf24 := save_maxrow()
  mywait()
  dbcreate(cur_dir+"tmp_h",{{"kod","N",7,0}})
  use (cur_dir+"tmp_h") new
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humann","HUMAN")
  set relation to recno() into HUMAN_
  find (str_find)
  if yes_h_otd == 1
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup .and. otd == glob_otd[1] ;
            for between(k_data,arr_m[5],arr_m[6]) .and. human_->reestr == 0
    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup .and. otd == glob_otd[1] ;
            for between(k_data,arr_m[5],arr_m[6])
    endif
  else
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup ;
            for lpu == glob_uch[1] .and. between(k_data,arr_m[5],arr_m[6]) .and. human_->reestr == 0
    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h == dostup ;
            for lpu == glob_uch[1] .and. between(k_data,arr_m[5],arr_m[6])
    endif
  endif
  srec := 1
  go top
  do while !eof()
    select TMP_H
    append blank
    replace kod with human->kod
    if human->kod == glob_perso
      srec := tmp_h->(recno())
    endif
    select HUMAN
    skip
  enddo
  i := tmp_h->(lastrec())
  close databases
  rest_box(buf24)
  if i == 0
    func_error(4,str_error)
  else
    Private mr1 := T_ROW, regim_vyb := 2
    do while .t.
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, to otd into OTD
      use (cur_dir+"tmp_h") new
      set relation to kod into HUMAN
      index on upper(human->fio) to (cur_dir+"tmp_h")
      goto (srec)
      mkod := 0
      buf_scr := savescreen()
      if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,mtitul,'B/BG',,;
                      .t.,,,"f2ret_oms_human",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
        if (glob_perso := tmp_h->kod) == 0
          func_error(4,"Не найдено нужных записей!")
        elseif eq_any(human->ishod,88,89)
          func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
        else
          srec := tmp_h->(recno())
          mkod := glob_perso
          glob_kartotek := human->kod_k
          glob_k_fio := fio_plus_novor()
          glob_otd[1] := human->otd
          glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
          if len(glob_otd) == 2
            aadd(glob_otd,human_->usl_ok)
          else
            glob_otd[3] := human_->usl_ok
          endif
          k := ret_tip_lu()
          if len(glob_otd) == 3
            aadd(glob_otd,k)
          else
            glob_otd[4] := k
          endif
          glob_uch[1] := human->LPU
          glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
          fl_schet := (human->schet > 0)
        endif
      else
        restscreen(buf_scr)
        exit
      endif
      restscreen(buf_scr)
      close databases
      if mkod > 0
        if buf != NIL ; rest_box(buf) ; endif
        buf := box_shadow(0,41,3,77,color13)
        @ 1,42 say padc(glob_otd[2],35) color color14
        @ 2,42 say padc(glob_k_fio,35) color color8
        mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
        if glob_otd[3] == 4 .or. glob_otd[4] > 0
          si := 1
          asize(mas_pmt,1)
          keyboard chr(K_ENTER)
        endif
        do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
          si := i
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if G_SLock(str_sem)
            if i == 1
              oms_sluch(glob_perso,glob_kartotek)
            else
              oms_usl_sluch(glob_perso,glob_kartotek)
            endif
            G_SUnLock(str_sem)
          else
            func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
            exit
          endif
        enddo
      endif
    enddo
  endif
  if buf != NIL ; rest_box(buf) ; endif
  close databases
endif
return NIL

***** 06.01.22 Редактирование случая с выбором по отчётному периоду
Function f2oms_edit()
Static si := 1
Local buf, str_sem, i, arr_m, mas_pmt, buf24, buf_scr, srec, old_yes_h_otd := yes_h_otd
local lek_pr := .f.

if !myFileDeleted(cur_dir+"tmp_h"+sdbf)
  return NIL
endif
if (arr_m := year_month(T_ROW,T_COL+5,,3)) != NIL
  buf24 := save_maxrow()
  mywait()
  dbcreate(cur_dir+"tmp_h",{{"kod","N",7,0}})
  use (cur_dir+"tmp_h") new
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(arr_m[5]),.t.)
  index on upper(fio) to (cur_dir+"tmp_h2") ;
        while human->k_data <= arr_m[6] ;
        for schet < 1 .and. human_->reestr==0
  srec := 1
  go top
  do while !eof()
    select TMP_H
    append blank
    replace kod with human->kod
    if human->kod == glob_perso
      srec := tmp_h->(recno())
    endif
    select HUMAN
    skip
  enddo
  i := tmp_h->(lastrec())
  close databases
  rest_box(buf24)
  if i == 0
    func_error(4,"В данный момент нет пациентов с датой окончания "+arr_m[4])
  else
    Private mr1 := T_ROW, regim_vyb := 2
    do while .t.
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, to otd into OTD
      use (cur_dir+"tmp_h") new
      set relation to kod into HUMAN
      index on upper(human->fio) to (cur_dir+"tmp_h")
      goto (srec)
      mkod := 0
      yes_h_otd := 2
      buf_scr := savescreen()
      if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,'По дате окончания лечения "'+arr_m[4]+'"','B/BG',,;
                                     .t.,,,"f2ret_oms_human",,;
                                     {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
        if (glob_perso := tmp_h->kod) == 0
          func_error(4,"Не найдено нужных записей!")
        elseif eq_any(human->ishod,88,89)
          func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
        else
          srec := tmp_h->(recno())
          mkod := glob_perso
          glob_kartotek := human->kod_k
          glob_k_fio := fio_plus_novor()
          glob_otd[1] := human->otd
          glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
          if len(glob_otd) == 2
            aadd(glob_otd,human_->usl_ok)
          else
            glob_otd[3] := human_->usl_ok
          endif
          k := ret_tip_lu()
          if len(glob_otd) == 3
            aadd(glob_otd,k)
          else
            glob_otd[4] := k
          endif
          glob_uch[1] := human->LPU
          glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
          fl_schet := (human->schet > 0)
        endif
      else
        restscreen(buf_scr)
        exit
      endif
      restscreen(buf_scr)
      close databases
      if mkod > 0
        lek_pr := check_oms_sluch_lek_pr(glob_perso)
        yes_h_otd := old_yes_h_otd
        if buf != NIL ; rest_box(buf) ; endif
        buf := box_shadow(0,41,3,77,color13)
        @ 1,42 say padc(glob_otd[2],35) color color14
        @ 2,42 say padc(glob_k_fio,35) color color8
        if lek_pr
          mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг", "Использованные ~лекарства"}
        else
          mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
        endif
        if glob_otd[3] == 4 .or. glob_otd[4] > 0
          si := 1
          asize(mas_pmt,1)
          keyboard chr(K_ENTER)
        endif
        do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
          si := i
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if G_SLock(str_sem)
            if i == 1
              oms_sluch(glob_perso,glob_kartotek)
            elseif i == 2
              oms_usl_sluch(glob_perso,glob_kartotek)
            elseif i == 3
              oms_sluch_lek_pr(glob_perso,glob_kartotek)
            endif
            G_SUnLock(str_sem)
          else
            func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
            exit
          endif
        enddo
      endif
    enddo
  endif
  if buf != NIL ; rest_box(buf) ; endif
  yes_h_otd := old_yes_h_otd
  close databases
endif
return NIL

***** 05.05.19 Редактирование повторно выставленных случаев (после ввода актов снятия из СМО)
Function f4oms_edit()
Static si := 1
Local buf, str_sem, i, k, arr_m, arr, old_yes_h_otd := yes_h_otd,;
      iRefr, srec, buf24, buf_scr, mas_pmt
if !myFileDeleted(cur_dir+"tmp_h"+sdbf)
  return NIL
endif
if (arr_m := year_month(T_ROW,T_COL+5)) != NIL
  buf24 := save_maxrow()
  mywait()
  dbcreate(cur_dir+"tmp_h",{{"kod","N",7,0}})
  use (cur_dir+"tmp_h") new
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(arr_m[5]),.t.)
  index on upper(fio) to (cur_dir+"tmp_h2") ;
        while human->k_data <= arr_m[6] ;
        for emptyall(human_->reestr,human->schet) .and. human_->kod_up > 0
  go top
  do while !eof()
    select TMP_H
    append blank
    replace kod with human->kod
    select HUMAN
    skip
  enddo
  i := tmp_h->(lastrec())
  close databases
  rest_box(buf24)
  if i == 0
    func_error(4,"Нет повторно выставленных случаев "+arr_m[4])
  else
    Private mr1 := T_ROW, regim_vyb := 2
    srec := 1
    do while .t.
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, to otd into OTD
      use (cur_dir+"tmp_h") new
      set relation to kod into HUMAN
      index on upper(human->fio) to (cur_dir+"tmp_h")
      goto (srec)
      mkod := 0
      yes_h_otd := 2
      buf_scr := savescreen()
      if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,"Повторно выставленные случаи "+arr_m[4],'B/BG',,;
                                     .t.,,,"f2ret_oms_human",,;
                                     {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
        if (glob_perso := tmp_h->kod) == 0
          func_error(4,"Не найдено нужных записей!")
        elseif eq_any(human->ishod,88,89)
          func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
        else
          srec := tmp_h->(recno())
          mkod := glob_perso
          glob_kartotek := human->kod_k
          glob_k_fio := fio_plus_novor()
          glob_otd[1] := human->otd
          glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
          if len(glob_otd) == 2
            aadd(glob_otd,human_->usl_ok)
          else
            glob_otd[3] := human_->usl_ok
          endif
          k := ret_tip_lu()
          if len(glob_otd) == 3
            aadd(glob_otd,k)
          else
            glob_otd[4] := k
          endif
          glob_uch[1] := human->LPU
          glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
          fl_schet := (human->schet > 0)
        endif
      else
        restscreen(buf_scr)
        exit
      endif
      restscreen(buf_scr)
      close databases
      if mkod > 0
        yes_h_otd := old_yes_h_otd
        if buf != NIL ; rest_box(buf) ; endif
        buf := box_shadow(0,41,3,77,color13)
        @ 1,42 say padc(glob_otd[2],35) color color14
        @ 2,42 say padc(glob_k_fio,35) color color8
        mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
        if glob_otd[3] == 4 .or. glob_otd[4] > 0
          si := 1
          asize(mas_pmt,1)
          keyboard chr(K_ENTER)
        endif
        do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
          si := i
          str_sem := "Редактирование человека "+lstr(glob_perso)
          if G_SLock(str_sem)
            if i == 1
              oms_sluch(glob_perso,glob_kartotek)
            else
              oms_usl_sluch(glob_perso,glob_kartotek)
            endif
            G_SUnLock(str_sem)
          else
            func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
            exit
          endif
        enddo
      endif
    enddo
  endif
  if buf != NIL ; rest_box(buf) ; endif
  yes_h_otd := old_yes_h_otd
  close databases
endif
return NIL

***** 05.02.19 Редактирование листка учета лечения больного + смена отделения
Function oms_smena_otd()
Static si := 1, sk := 1
Local buf, buf1, buf2, str_sem, i, sou, old_otd, fl, fl1, mas_pmt, k := 1
if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
                            input_otd(T_ROW-1,T_COL+5,sys_date) != NIL
  if yes_vypisan == B_END
    if (k := popup_prompt(T_ROW,T_COL+5,sk,;
              {"~Не закончившие лечение","~Закончившие лечение"})) > 0
      sk := k
    endif
  endif
  buf := box_shadow(0,41,2,77,color13)
  @ 1,42 say padc(glob_otd[2],35) color color14
  if k > 0 .and. ret_oms_human(yes_vypisan+k-1)
    rest_box(buf)
    buf := box_shadow(0,41,3,77,color13)
    @ 1,42 say padc(glob_otd[2],35) color color14
    @ 2,42 say padc(glob_k_fio,35) color color8
    sou := glob_otd[2]+" ["+glob_uch[2]+"]" ; old_otd := glob_otd[1]
    buf1 := box_shadow(0,0,3,35,color5)
    @ 1,1 say padc("Теперь выберите",34) color color5
    @ 2,1 say padc("новое отделение",34) color color5
    if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
                          input_otd(T_ROW-1,T_COL+5,sys_date) != NIL
      rest_box(buf1)
      if old_otd == glob_otd[1]
        fl := func_error(4,"Выбрано то же самое отделение!")
      else
        buf2 := savescreen()
        f_message({"Старое отделение:",;
                   sou,;
                   "Новое отделение:",;
                   glob_otd[2]+" ["+glob_uch[2]+"]"},,"W+/W","N/W")
        if (fl := f_Esc_Enter("смены отделения",.t.))
          fl1 := .f.
          if input_value(maxrow()-4,10,maxrow()-2,69,color1,;
              "   Перезаписывать новое отделение в каждой услуге",0,mm_danet) == 1
            fl1 := .t.
          endif
        endif
        restscreen(buf2)
      endif
      if fl
        str_sem := "Редактирование человека "+lstr(glob_perso)
        if G_SLock(str_sem)
          use_base("human")
          set order to 0
          goto (glob_perso)
          k := human->ishod
          G_RLock(forever)
          human->LPU := glob_uch[1] // код учреждения
          human->OTD := glob_otd[1] // код отделения
          if fl1
            Use_base("mo_hu")
            find (str(glob_perso,7))
            do while mohu->kod == glob_perso .and. !eof()
              G_RLock(forever)
              mohu->otd := glob_otd[1] // код отделения
              skip
            enddo
            Use_base("human_u")
            find (str(glob_perso,7))
            do while hu->kod == glob_perso .and. !eof()
              G_RLock(forever)
              hu->otd := glob_otd[1] // код отделения
              skip
            enddo
          endif
          close databases
          func_error(2,"Смена отделения завершена!")
          if eq_any(k,88,89)
            func_error(4,"Данный случай - часть двойного случая. Редактирование запрещено!")
          else
            @ 1,42 say padc(glob_otd[2],35) color color14
            mas_pmt := {"Редактирование ~карточки","Редактирование ~услуг"}
            if glob_otd[3] == 4 .or. glob_otd[4] > 0
              si := 1
              asize(mas_pmt,1)
            endif
            do while (i := popup_prompt(T_ROW,T_COL+5,si,mas_pmt)) > 0
              if (si := i) == 1
                oms_sluch(glob_perso,glob_kartotek)
              else
                oms_usl_sluch(glob_perso,glob_kartotek)
              endif
            enddo
          endif
          G_SUnLock(str_sem)
        else
          func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
        endif
      endif
    endif
    if buf1 != NIL ; rest_box(buf1) ; endif
  endif
  if buf != NIL ; rest_box(buf) ; endif
endif
return NIL

***** 06.01.22 Удаление листка учета лечения больного
Function oms_del()
Static sk := 1
Local buf, str_sem, j, k := 1, arr_m, fl := .t., lkod_k, lyear

if ! hb_user_curUser:IsAdmin()
  return func_error(4,err_admin)
endif
if (arr_m := input_year()) != NIL .and. ;
     input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
          iif(yes_h_otd==1, input_otd(T_ROW-1,T_COL+5,sys_date)!=NIL, .t.)
  if yes_vypisan == B_END
    if (k := popup_prompt(T_ROW,T_COL+5,sk,;
              {"~Не закончившие лечение","~Закончившие лечение"})) > 0
      sk := k
    endif
  endif
  if yes_h_otd == 1
    buf := box_shadow(0,41,2,77,color13)
    @ 1,42 say padc(glob_otd[2],35) color color14
  endif
  if k > 0 .and. ret_oms_human(yes_vypisan+k-1,arr_m) .and. f_Esc_Enter(2,.t.)
    str_sem := "Редактирование человека "+lstr(glob_perso)
    if G_SLock(str_sem)
      G_Use(dir_server+"mo_pp",dir_server+"mo_pp_h","PP")
      use_base("mo_hdisp")
      Use_base("mo_hu")
      Use_base("human_u")
      Use_base("human")
      find (str(glob_perso,7))
      if fl .and. eq_any(human->ishod,88,89)
        fl := func_error(10,"Данный случай - часть двойного случая. Удаление запрещено!")
      endif
      if fl .and. human_->KOD_UP > 0
        fl := func_error(10,"Данный случай выставлен повторно (по акту снятия). Удаление запрещено!")
      endif
      if fl .and. human->ishod == 201 // диспансеризация I этап
        lkod_k := human->kod_k
        lyear := year(human->k_data)
        set order to 2
        find (str(lkod_k,7))
        do while human->kod_k == lkod_k .and. !eof()
          if human->ishod == 202 .and. year(human->k_data) == lyear
            fl := func_error(10,"Это I этап диспансеризации, но присутствует II этап. Удаление запрещено!")
            exit
          endif
          skip
        enddo
        set order to 1
        find (str(glob_perso,7))
      endif
      if fl
        flag_pp := .f.
        select PP // приемный покой
        find (str(glob_perso,7))
        if found() .and. human->kod_k == pp->kod_k // тот же пациент
          G_RLock(forever)
          pp->K_DATA := ctod("")  // дата окончания лечения
          pp->K_TIME := ""        // время выписки
          flag_pp := .t.
        endif
        j := 0
        do while .t.
          select HDISP
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        do while .t.
          select MOHU
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.,.f.)  // без пометки на удаление
          ++j
        enddo
        do while .t.
          select HU
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          //
          select HU_
          DeleteRec(.t.,.f.)
          select HU
          DeleteRec(.t.,.f.)  // без пометки на удаление
          ++j
        enddo
        select HUMAN_2
        DeleteRec(.t.,.f.)
        select HUMAN_
        DeleteRec(.t.,.f.)
        select HUMAN
        DeleteRec(.t.,.f.)  // без пометки на удаление
        G_RLock(forever)
        replace human->schet with -1  // (вместо нуля)
        // удаляем онкологию
        G_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","NAPR") // онконаправления
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","SL")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","DI")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","PR")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","US")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","CO")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","LE")
        do while .t.
          find (str(glob_perso,7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo

        // добавил новые файлы для листов учета
        G_Use(dir_server + "human_im", dir_server + "human_im", "IMP")
        do while .t.
          find (str(glob_perso, 7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        G_Use(dir_server + "human_lek_pr", dir_server + "human_lek_pr", "LEK")
        do while .t.
          find (str(glob_perso, 7))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo


        close databases
        write_work_oper(glob_task,OPER_USL,3,j)
        write_work_oper(glob_task,OPER_LIST,3)
        stat_msg("Лист учёта удалён.") ; mybell(2,OK)
        if flag_pp
          stat_msg("Не забудьте удалить историю болезни в подзадаче ПРИЁМНЫЙ ПОКОЙ") ; mybell(10,OK)
        endif
      else
        close databases
      endif
      G_SUnLock(str_sem)
    else
      func_error(4,"В данный момент с карточкой этого пациента работает другой пользователь.")
    endif
  endif
  if buf != NIL ; rest_box(buf) ; endif
endif
return NIL

***** Режимы работы с завершением лечения
Function oms_zav_lech(k)
Static sk := 1, str_sem := "Завершение лечения"
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"Завершение лечения для ~одного больного",;
                "Завершение лечения для ~всех",;
                "~Убрать у больного отметку о завершении лечения"}
    mas_msg := {"Завершение лечения для одного больного",;
                "Завершение лечения для всех",;
                "Убрать у больного отметку о завершении лечения"}
    mas_fun := {"oms_zav_lech(1)",;
                "oms_zav_lech(2)",;
                "oms_zav_lech(3)"}
    if G_SLock(str_sem)
      popup_prompt(T_ROW-len(mas_pmt)-3,T_COL+5,sk,mas_pmt,mas_msg,mas_fun)
      G_SUnLock(str_sem)
    else
      func_error(4,err_slock)
    endif
  case k == 1
    f1oms_zav_lech(1)
  case k == 2
    f1oms_zav_lech(2)
  case k == 3
    f1oms_zav_lech(3)
endcase
if k > 0
  sk := k
endif
return NIL

*****
Function f1oms_zav_lech(k)
Local buf, str_sem, k1, k2, tmp_color, dbf_tmp, r := 8, mtitul
if input_uch(T_ROW-1,T_COL+5,sys_date) != NIL .and. ;
          iif(yes_h_otd==1, input_otd(T_ROW-1,T_COL+5,sys_date)!=NIL, .t.)
  if k == 1 .or. k == 3  // один человек из отделения
    if ret_oms_human(iif(k==1,B_END,B_STANDART))
      str_sem := "Редактирование человека "+lstr(glob_perso)
      if !G_SLock(str_sem)
        return func_error(4,err_slock)
      endif
      tmp_color := setcolor(color1) ; buf := savescreen()
      box_shadow(r,10,r+7,69,color1,;
             if(k==1,"Завершение лечения",;
                     "Убираем отметку о завершении лечения"),"W/B")
      Use_base("human")
      goto (glob_perso)
      @ r+2,12 say "Ф.И.О. "
      @ row(),col() say human->fio color cDataCSay
      @ r+3,12 say "Дата начала лечения "
      @ row(),col() say full_date(human->n_data) color cDataCSay
      @ r+4,12 say "Дата окончания лечения "
      @ row(),col() say full_date(human->k_data) color cDataCSay
      @ r+5,12 say "Сумма лечения "
      @ row(),col() say lstr(human->cena_1,12,2) color cDataCSay
      if f_Esc_Enter(1) .and. G_RLock(forever)
        human->TIP_H := if(k == 3, B_END, B_STANDART)
        stat_msg(if(k == 1, "Лечение завершено", "Убрана отметка о завершении лечения")+"!")
        mybell(0.5,OK)
      endif
      close databases
      G_SUnLock(str_sem)
      restscreen(buf)
      setcolor(tmp_color)
    endif
  elseif k == 2  // целое отделение/учреждение
    dbf_tmp := {;
       {"KOD"      ,   "N",     7,     0},;
       {"N_DATA"   ,   "D",     8,     0},; // дата начала лечения
       {"K_DATA"   ,   "D",     8,     0},; // дата окончания лечения
       {"FIO"      ,   "C",    50,     0},; // Ф.И.О. больного
       {"CENA"     ,   "N",    12,     2},; // стоимость лечения
       {"PLUS"     ,   "L",     1,     0}}  // включается ли в счет
    buf := save_maxrow()
    mywait()
    dbcreate(cur_dir+"tmp",dbf_tmp)
    k1 := k2 := 0
    Use (cur_dir+"tmp") alias TMP
    R_Use(dir_server+"human",dir_server+"humann","HUMAN")
    find (str(B_END,1))
    do while human->tip_h == B_END .and. !eof()
      if iif(yes_h_otd==1, human->otd == glob_otd[1], .t.)
        k1++
        select TMP
        append blank
        replace tmp->KOD    with human->KOD ,;
                tmp->n_data with human->n_data,;
                tmp->k_data with human->k_data,;
                tmp->FIO    with human->FIO ,;
                tmp->CENA   with human->CENA_1,;
                tmp->PLUS   with .t.
        if k1 == 9999
          exit
        endif
      endif
      select HUMAN
      skip
    enddo
    close databases
    rest_box(buf)
    if k1 == 0
      func_error(4,"Нет больных, не закончивших лечение!")
    else
      buf := savescreen()
      Private old_summa := ob_summa := 0, old_kol := ob_kol := k1, regim_t := 3
      Private p_blk := {|mkol,msum| .t. }
      mtitul := alltrim(glob_uch[2])
      if yes_h_otd == 1
        mtitul += " [ "+alltrim(glob_otd[2])+" ]"
      endif
      Use (cur_dir+"tmp") alias TMP
      index on upper(fio) to (cur_dir+"tmp_hum")
      if Alpha_Browse(T_ROW,0,maxrow()-4,79,"f2oms_zav_lech",color1,;
                      mtitul,"G+/B",.t.,.t.,,,"f3oms_zav_lech",,;
                      {'═','░','═',"W+/B,BG+/R,GR+/B,GR+/R",,300} )
        if ob_kol > 0 .and. f_Esc_Enter("завершения лечения") .and. Use_base("human")
          mywait()
          select TMP
          go top
          do while !eof()
            if tmp->plus
              str_sem := "Редактирование человека "+lstr(tmp->kod)
              if G_SLock(str_sem) // если человек не заблокирован
                select HUMAN
                find (str(tmp->kod,7))
                if found() .and. G_RLock(forever)
                  human->TIP_H := B_STANDART
                  UnLock
                endif
                G_SUnLock(str_sem)
              else
                k2++
              endif
            endif
            select TMP
            skip
          enddo
          close databases
          stat_msg("Лечение завершено!" + if(k2 == 0, "", ;
                               " ("+lstr(k2)+" чел. были заблокированы)") )
          mybell(0.5,OK)
        endif
      endif
      restscreen(buf)
    endif
  endif
endif
close databases
return NIL

*****
Function f2oms_zav_lech(oBrow)
Local oColumn, tmp_color, blk_color := {|| if(tmp->plus, {3,4}, {1,2}) }, s1, s2, s3, n := 46
oColumn := TBColumnNew(" ", {|| if(tmp->plus," ","  ") })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Ф.И.О. больного",n), {|| padr(tmp->fio,n) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Окончан.;лечения", {|| tmp->k_data })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("    Сумма", {|| padl(expand_value(tmp->cena,2),14) })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" ", {|| if(tmp->plus," ","  ") })
oColumn:colorBlock := blk_color
oBrow:addColumn(oColumn)
tmp_color := setcolor("N/W")
s1 := "завершения лечения"
s2 := "все завершили лечение"
s3 := "все не завершили лечение"
@ maxrow()-3,0 say padr(" <Esc> - выход без изменений;    <Enter> - подтверждение "+s1,80)
@ maxrow()-2,0 say padr(" <Ins> - отметить одного больного или снять отметку с одного больного",80)
@ maxrow()-1,0 say padr(" <+> - отметить всех больных (все завершили лечение)    <F8> - удаление по дате",80)
@ maxrow()-0,0 say padr(" <-> - снять отметку со всех больных (все не завершили лечение)   <F9> - печать",80)
mark_keys({s1},"R/W")
mark_keys({"<Esc>","<Enter>","<Ins>","<+>","<->","<F8>","<F9>"},"B/W")
setcolor(tmp_color)
return NIL

*****
Function f3oms_zav_lech(nKey,oBrow)
Local buf, rec, k := -1, sh, HH, n_file, s, mdate, j
do case
  case nkey == K_F8
    mdate := input_value(21,1,23,78,"W+/N,N/W",;
          space(7)+"Введите дату, ранее которой не завершено лечение",;
           sys_date-30)
    if mdate != NIL .and. f_Esc_Enter("удаления") .and. ;
       f_alert({'После подтверждения данного режима будут удалены',;
                "все листки учета с незавершенным лечением, у которых",;
                "проставлена дата ранее "+date_month(mdate,.t.),;
                "Выберите действие"},;
               {" ~Отказ "," Подтвердить ~удаление "},;
               1,"N+/BG","R/BG",16,,col1menu ) == 2
      buf := save_maxrow()
      mywait()
      j := 0
      Use_base("mo_hu")
      Use_base("human_u")
      Use_base("human")
      select TMP
      go top
      do while !eof()
        if tmp->k_data <= mdate
          ++j
          do while .t.
            select HU
            find (str(tmp->kod,7))
            if !found() ; exit ; endif
            //
            select HU_
            DeleteRec(.t.,.f.)
            select HU
            DeleteRec(.t.,.f.)  // без пометки на удаление
          enddo
          do while .t.
            select MOHU
            find (str(tmp->kod,7))
            if !found() ; exit ; endif
            DeleteRec(.t.,.f.)  // без пометки на удаление
          enddo
          select HUMAN
          goto (tmp->kod)
          select HUMAN_
          DeleteRec(.t.,.f.)
          select HUMAN
          DeleteRec(.t.,.f.)  // без пометки на удаление
          G_RLock(forever)
          replace human->schet with -1  // (вместо нуля)
          UnLock
        endif
        select TMP
        skip
      enddo
      close databases
      stat_msg("Всего удалено листов учета - "+lstr(j)) ; mybell(2,OK)
      Use (cur_dir+"tmp") alias TMP
      rest_box(buf)
      k := 0
      keyboard chr(K_ESC)
    endif
  case nkey == K_F9
    mdate := input_value(21,1,23,78,color1,;
          space(7)+"Введите дату, ранее которой не завершено лечение",;
           sys_date-10)
    if mdate != NIL .and. f_Esc_Enter("печати")
      buf := save_maxrow()
      mywait()
      rec := recno()
      R_Use(dir_server+"human_u",dir_server+"human_u","HU")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"uslugi",,"USL")
      R_Use(dir_server+"mo_pers",,"PERSO")
      arr_title := {;
       "────────────────────────────────────────────────┬────────────────┬──────────────",;
       "               Ф.И.О.                           │ Сроки лечения  │    Сумма     ",;
       "────────────────────────────────────────────────┴────────────────┴──────────────"}
      n_file := "z_lech"+stxt ; sh := 80 ; HH := 57
      fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
      add_string("")
      add_string(center("Больные, не завершившие лечение",sh))
      add_string(center("до "+date_month(mdate,.t.),sh))
      add_string("")
      aeval(arr_title, {|x| add_string(x) } )
      select TMP
      go top
      do while !eof()
        if tmp->k_data <= mdate
          if verify_FF(HH, .t., sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(padr(tmp->fio,49)+;
                     left(dtoc(tmp->n_data),5)+'-'+dtoc(tmp->k_data)+;
                     put_kopE(tmp->cena,13))
          select HUMAN_
          goto (tmp->kod)
          if !eof() .and. human_->vrach > 0
            select PERSO
            goto (human_->vrach)
            if !eof()
              s := space(10)+"Леч.врач: ["+lstr(perso->tab_nom)
              add_string(s+"]  "+alltrim(perso->fio))
            endif
          endif
          arr_usl := {}
          select HU
          find (str(tmp->kod,7))
          do while hu->kod == tmp->kod
            usl->(dbGoto(hu->u_kod))
            if ascan(arr_usl,usl->shifr) == 0
              aadd(arr_usl,usl->shifr)
            endif
            select HU
            skip
          enddo
          if len(arr_usl) > 0
            asort(arr_usl,,,{|x,y| fsort_usl(x) < fsort_usl(y) } )
            s := "Услуги: "
            for j := 1 to len(arr_usl)
              s += alltrim(arr_usl[j])
              if j < len(arr_usl)
                s += ", "
              endif
            next
            for j := 1 to perenos(arr_usl,s,sh-10)
              add_string(space(10)+arr_usl[j])
            next
          endif
        endif
        select TMP
        skip
      enddo
      hu->(dbCloseArea())
      usl->(dbCloseArea())
      human_->(dbCloseArea())
      perso->(dbCloseArea())
      select TMP
      goto (rec)
      fclose(fp)
      rest_box(buf)
      viewtext(n_file,,,,,,,2)
    endif
  case nkey == K_INS
    replace tmp->plus with !tmp->plus
    if tmp->plus
      ob_summa += tmp->cena ; ob_kol++
    else
      ob_summa -= tmp->cena ; ob_kol--
    endif
    eval(p_blk,ob_kol,ob_summa)
    k := 0
    keyboard chr(K_TAB)
  case nkey == 43 .or. nkey == 45  // + или -
    fl := (nkey == 43)
    rec := recno()
    buf := save_maxrow()
    mywait()
    tmp->(dbeval({|| tmp->plus := fl}))
    goto (rec)
    rest_box(buf)
    if fl
      ob_summa := old_summa ; ob_kol := tmp->(lastrec())
    else
      ob_summa := ob_kol := 0
    endif
    eval(p_blk,ob_kol,ob_summa)
    k := 0
endcase
return k

***** поиск больного
Function ret_oms_human(dostup,arr_m)
//  dostup = B_END      = 2 - больные выписались из данного отделения
//  dostup = B_STANDART = 3 - проверен стандарт лечения и не включен в реестр
//  dostup = B_SCHET    = 4 - выписан счет
//  dostup = B_OPL      = 5 - оплачен счет
//  dostup = B_NE_OPL   = 6 - больной по какой-то причине не оплачивается
Local buf := savescreen(), mkod := 0, k, fl := .f., mtitul := ""
mywait()
Private mr1 := T_ROW, str_find, regim_vyb := 1
str_error := "В данный момент"
if dostup == NIL
  str_find := dtos(arr_m[5])
  mtitul := 'По дате окончания лечения "'+arr_m[4]+'"'
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_, to otd into OTD
  dbseek(str_find,.t.)
  index on upper(fio) to (cur_dir+"tmp_hum") ;
        while human->k_data <= arr_m[6] ;
        for schet < 1 .and. human_->reestr==0
  str_error += " нет пациентов с датой окончания "+arr_m[4]
else
  mtitul := alltrim(glob_uch[2])
  str_find := str(dostup,1)
  if yes_h_otd == 1
    mtitul += " [ "+alltrim(glob_otd[2])+" ]"
    str_error += " в данном отделении"
    str_find += str(glob_otd[1],3)
  endif
  str_error += " нет пациентов"
  if dostup == B_STANDART
    str_error += ", закончивших лечение"
  else
    str_error += ", не закончивших лечение"
  endif
  if arr_m != NIL
    str_error += " "+arr_m[4]
    mtitul += " "+arr_m[4]
  endif
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humann","HUMAN")
  set relation to recno() into HUMAN_, to otd into OTD
  find (str_find)
  if yes_h_otd == 1
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup .and. otd==glob_otd[1] ;
            for iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6])) .and. human_->reestr==0
    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup .and. otd==glob_otd[1] ;
            for iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6]))
    endif
  else
    if dostup == B_STANDART
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup ;
            for lpu==glob_uch[1] .and. iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6])) ;
                                 .and. human_->reestr==0

    else
      index on upper(fio) to (cur_dir+"tmp_hum") ;
            while tip_h==dostup ;
            for lpu==glob_uch[1] .and. iif(arr_m==NIL, .t., between(k_data,arr_m[5],arr_m[6]))
    endif
  endif
endif
go top
if eof()
  close databases
  restscreen(buf)
  str_error += "!"
  return func_error(4,str_error)
endif
if glob_perso > 0
  Locate for human->kod == glob_perso
  if !found()
    go top
  endif
endif
if Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1ret_oms_human",color0,mtitul,'B/BG',,;
                               .t.,,,"f2ret_oms_human",,;
                               {'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R"} )
  if (glob_perso := human->kod) == 0
    func_error(4,"Не найдено нужных записей!")
  else
    mkod := glob_perso
    glob_kartotek := human->kod_k
    glob_k_fio := fio_plus_novor()
    glob_otd[1] := human->otd
    glob_otd[2] := inieditspr(A__POPUPMENU, dir_server+"mo_otd", human->otd)
    if len(glob_otd) == 2
      aadd(glob_otd,human_->usl_ok)
    else
      glob_otd[3] := human_->usl_ok
    endif
    k := ret_tip_lu()
    if len(glob_otd) == 3
      aadd(glob_otd,k)
    else
      glob_otd[4] := k
    endif
    glob_uch[1] := human->LPU
    glob_uch[2] := inieditspr(A__POPUPMENU, dir_server+"mo_uch", human->LPU)
    fl_schet := (human->schet > 0)
  endif
  close databases
endif
close databases
restscreen(buf)
return (mkod > 0)

***** 28.12.21
Function f1ret_oms_human(oBrow)
Local oColumn, blk, r := 34
blk := {|| iif(human_->KOD_UP > 0, {3,4}, iif(human_->OPLATA == 2, {5,6},{1,2})) }
if yes_h_otd == 1
  r += 6
endif
oColumn := TBColumnNew(padc("ФИО пациента",r),{|| padr(fio_plus_novor(),r)})
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if yes_h_otd == 2
  oColumn := TBColumnNew("Отд-е", {|| otd->short_name })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
endif
oColumn := TBColumnNew("Осн.;диаг.", {|| human->kod_diag })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Нача-; ло", {|| left(dtoc(human->n_data),5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Оконч-ие;лечения", {|| date_8(human->k_data) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Стоимость;  лечения", {|| put_kopE(human->cena_1,10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if hb_user_curUser:IsAdmin()
  s := "^<Esc>^ выход  ^<Enter>^ выбор  ^<F2>^ поиск"
  if type("p_del_error") == "A" .and. p_del_error[2] > 0
    s += "  ^<Ctrl+F12>^ снятие флага об ошибке у всех"
  endif
  status_key(s)
else
  status_key("^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск")
endif
return NIL

***** 28.12.21
Function f2ret_oms_human(nkey)
Static tmp := " "
Local buf := savescreen(), buf1, rec1 := recno(), fl := -1, ss := 0, ;
      j, n_file := "omserror"+stxt, sh := 80, HH := 60
Private tmp1
if type("p_del_error") == "A" .and. p_del_error[2] > 0
  if nkey == K_F9
    mywait()
    fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
    add_string("")
    add_string(center("Список случаев, возвращённых ТФОМС с ошибкой",sh))
    add_string(center(p_del_error[1],sh))
    add_string(center(arr_m[4],sh))
    j := 0
    go top
    do while !eof()
      verify_FF(HH-3,.f.,sh)
      add_string("")
      ++j
      add_string(padr(lstr(j)+".",6)+alltrim(human->fio)+", д.р."+full_date(human->date_r)+",")
      if otd->IDUMP == 4
        add_string(space(6)+"карта вызова № "+alltrim(human->uch_doc)+;
                            ", дата выезда "+date_8(human->k_data))
      else
        add_string(space(6)+"лечение с "+date_8(human->n_data)+" по "+date_8(human->k_data)+;
                            ", стоимость "+lstr(human->cena_1,11,2)+"р.")
      endif
      ss += human->cena_1
      skip
    enddo
    goto rec1
    add_string("")
    add_string("Итого стоимость всех случаев "+lstr(ss,15,2)+"р.")
    fclose(fp)
    restscreen(buf)
    viewtext(n_file,,,,(sh>80),,,2)
    return -1
  // elseif eq_any(nkey,K_F12,K_CTRL_F12) .and. tip_polzovat == TIP_ADM .and. f_Esc_Enter("снятия флага об ошибке",.t.)
  elseif eq_any(nkey,K_F12,K_CTRL_F12) .and. hb_user_curUser:IsAdmin() .and. f_Esc_Enter("снятия флага об ошибке",.t.)
     /*involved_password(1,p_del_error[2],"снятия со всех пациентов флага об ошибке") ;
         .and. f_alert({padc("Выберите действие",60,".")},;
                       {" Отказ "," Снять флаг об ошибке со всех пациентов "},;
                       1,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" ) == 2*/
    go top
    do while !eof()
      human_->(G_RLock(forever))
      human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      skip
    enddo
    goto rec1
    stat_msg('Флаг об ошибке '+lstr(p_del_error[2])+' снят со всех пациентов. Войдите в режим "Реестры/Проверка"')
    mybell(4,OK)
    restscreen(buf)
    return 0
  elseif nkey == K_CTRL_F9
    mywait()
    fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
    add_string("")
    add_string(center("Сведения об отклоненных от оплаты случаях и стоимости медицинской помощи",sh))
    add_string(center(p_del_error[1],sh))
    add_string(center(arr_m[4],sh))
    tmp_1 := select()
    R_Use(dir_server+"uslugi",,"USL")
    //R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human_u_",,"HU_")
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    set relation to recno() into HU_, to u_kod into USL
    select (tmp_1)
    //
    Private mas_otch := {{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},;
                         {0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}}
    //mas_otch := array(16,2)
    //afill(mas_otch,0)
    //arr_iss := array(1,9) ; afillall(arr_iss,0)
    //
    go top
    do while !eof()
      verify_FF(HH-3,.f.,sh)
      //
      flag_covid := .F.
      if eq_any(human->kod_diag,"U07.1","U07.2")
        flag_covid := .T.
      endif
      if !flag_covid
        if eq_any(human->kod_diag2,"U07.1","U07.2")
          flag_covid := .T.
        endif
      endif
      if !flag_covid
        if eq_any(human->kod_diag3,"U07.1","U07.2")
          flag_covid := .T.
        endif
      endif
      if !flag_covid
        if eq_any(human->kod_diag4,"U07.1","U07.2")
          flag_covid := .T.
        endif
      endif
      //
      //select HUMAN_
      goto ((tmp_1)->(recno()))
      //goto (human->(recno()))
      //
      select HU
      find (str(human->kod,7))
      do while human->kod == hu->kod .and. !eof()
        // ныряем в услуги - если Диагностика - должно быть 60.*
        lshifr := ""
        svp := space(5)
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,,,,@svp)
          lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
        endif
        //
        if HUMAN_->Usl_ok == 1 //стационар
          if padr(lshifr,2) == "st" // KSG
            mas_otch[1,1] += 1
            mas_otch[2,1] += hu->stoim
            if eq_any(padr(alltrim(lshifr),8),"st12.015","st12.016",;
                      "st12.017","st12.018","st12.019")
              mas_otch[1,2] += 1
              mas_otch[2,2] += hu->stoim
            endif
          endif
        endif
        //
        if HUMAN_->Usl_ok == 2 // дневной стационар
          if padr(lshifr,2) == "ds" // KSG -дневной стационар
            mas_otch[3,1] += 1
            mas_otch[4,1] += human->cena_1
            if flag_covid
              mas_otch[3,2] += 1
              mas_otch[4,2] += human->cena_1
            endif
          endif
        endif
        //
        if HUMAN_->Usl_ok == 3 // амбулаторная
          if padr(lshifr,3) == "60." // Диагностика
            if padr(lshifr,4) == "60.4" //КТ
              mas_otch[13,1] += 1
              mas_otch[14,1] += hu->stoim
            endif
            mas_otch[11,1] += 1
            mas_otch[12,1] += hu->stoim
            if flag_covid
              mas_otch[11,2] += 1
              mas_otch[12,2] += hu->stoim
            endif
          endif
          //
          if padr(alltrim(lshifr),8) == "4.17.785" .or.;
             padr(alltrim(lshifr),8) == "4.17.786"       //COVID
            //
            mas_otch[15,1] += 1
            mas_otch[16,1] += hu->stoim
            //
            mas_otch[11,1] += 1
            mas_otch[12,1] += hu->stoim
            if flag_covid
              mas_otch[11,2] += 1
              mas_otch[12,2] += hu->stoim
            endif
          endif
          // профеля
          if padr(lshifr,5) == "2.80." .or. ; // Неотложка
             padr(lshifr,5) == "2.82."        //  ПРиемный покой
            mas_otch[9,1]  += 1
            mas_otch[10,1] += hu->stoim
            if flag_covid
              mas_otch[9,2]  += 1
              mas_otch[10,2] += hu->stoim
            endif
          endif
          //
          if padr(lshifr,5) == "2.78." // Обращения
            // нужен фильтр по профилям
            // Акушерство и генология == 2,136,137
            // Дерматовенерология  == 16
            // Онкология == 60
            // Травматология и ортопедия == 100
            // Стоматологии 85,86,87,88,89,90,171,
            // Медреабилитация 158
            if eq_any(human_->profil,2,136,137,16,60,100,85,86,87,89,90,171,158)
              mas_otch[7,1] += 1
              mas_otch[8,1] += hu->stoim
              if flag_covid
                mas_otch[7,2] += 1
                mas_otch[8,2] += hu->stoim
              endif
            endif
          endif
          //
          if padr(lshifr,5) == "2.79." .or.; // Посещения профилактические
             padr(lshifr,5) == "2.88."       //Диспансерное наблюдение
            // нужен фильтр по профилям
            if eq_any(human_->profil,2,136,137,16,60,100,85,86,87,89,90,171,158)
              mas_otch[5,1] += 1
              mas_otch[6,1] += hu->stoim
              if flag_covid
                mas_otch[5,2] += 1
                mas_otch[6,2] += hu->stoim
              endif
            endif
          endif
        endif
        select HU
        skip
      enddo
      select (tmp_1)
      skip
    enddo
    add_string("    Круглосуточный стационар")
    //
    add_string("Круглосуточный стационар случай: "+lstr(mas_otch[1,1])+;
                          "  сумма:"+put_kop(mas_otch[2,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[1,2])+;
                          "  сумма:"+put_kop(mas_otch[2,2],10))
    add_string("    Дневной стационар")
    add_string("Дневной стационар случай       : "+lstr(mas_otch[3,1])+;
                          "  сумма:"+put_kop(mas_otch[4,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[3,2])+;
                          "  сумма:"+put_kop(mas_otch[4,2],10))
    add_string("    Амбулаторная помощь")
    add_string("Посещения профилактические     : "+lstr(mas_otch[5,1])+;
                          "  сумма:"+put_kop(mas_otch[6,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[5,2])+;
                          "  сумма:"+put_kop(mas_otch[6,2],10))
    add_string("Обращения (не вход. в подушевое: "+lstr(mas_otch[7,1])+;
                          "  сумма:"+put_kop(mas_otch[8,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[7,2])+;
                          "  сумма:"+put_kop(mas_otch[8,2],10))
    add_string("Неотложная МП                  : "+lstr(mas_otch[9,1])+;
                          "  сумма:"+put_kop(mas_otch[10,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[9,2])+;
                          "  сумма:"+put_kop(mas_otch[10,2],10))
    add_string("Диагностические услуги         : "+lstr(mas_otch[11,1])+;
                          "  сумма:"+put_kop(mas_otch[12,1],10))
    add_string("                   в т.ч. Covid: "+lstr(mas_otch[11,2])+;
                          "  сумма:"+put_kop(mas_otch[12,2],10))
    add_string("Их них, КТ                     : "+lstr(mas_otch[13,1])+;
                          "  сумма:"+put_kop(mas_otch[14,1],10))
    add_string("Исследования COVID             : "+lstr(mas_otch[15,1])+;
                          "  сумма:"+put_kop(mas_otch[16,1],10))
    //
    USL->(dbCloseArea())
    HU_->(dbCloseArea())
    HU->(dbCloseArea())
    select (tmp_1)
    goto rec1
    add_string("")
    fclose(fp)
    restscreen(buf)
    viewtext(n_file,,,,(sh>80),,,2)
    return -1
  // заплатка 
  // elseif eq_any(nkey,K_F10,K_CTRL_F10) .and. tip_polzovat == TIP_ADM .and. f_Esc_Enter("смена услуги",.t.)
  elseif eq_any(nkey,K_F10,K_CTRL_F10) .and. hb_user_curUser:IsAdmin() .and. f_Esc_Enter("смена услуги",.t.)
    tmp_1 := select()
    G_Use(dir_server+"human_u",dir_server+"human_u","HU")
    select (tmp_1)
    go top
    do while !eof()
      human_->(G_RLock(forever))
      human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      //
      select ("HU")
      find (str(human->kod,7))
      if(hu->u_kod == 217) //611
        hu->(G_RLock(forever))
        hu->u_kod := 220  //614
      endif
      //
      if(hu->u_kod == 219) 
        hu->(G_RLock(forever))
        hu->u_kod := 220  
      endif
      //
      select (tmp_1)
      skip
    enddo
    goto rec1
    stat_msg('Услуга заменена у всех пациентов. Войдите в режим "Реестры/Проверка"')
    mybell(4,OK)
    restscreen(buf)
    return 0

  endif
endif
if nkey != K_F2
  return -1
endif
buf1 := savescreen(13,4,19,77)
do while .t.
  tmp1 := padr(tmp,50)
  setcolor(color8)
  box_shadow(13,14,18,67)
  @ 15,15 say center(" Введите шаблон для поиска фамилий",52)
  status_key("^<Esc>^ - отказ от ввода;  ^<F1>^ - помощь")
  @ 16,16 get tmp1 picture "@K@!"
  myread()
  setcolor(color0)
  if lastkey() == K_ESC .or. empty(tmp1)
    exit
  endif
  mywait()
  tmp := alltrim(tmp1)
  Private tmp_mas := {}, tmp_kod := {}, i := 0, t_len, k1 := mr1+3, ;
          k2 := 21, tmp2 := upper(tmp), ch := left(tmp,1)
  if !("*" $ tmp2)
    tmp2 := "*"+tmp2+"*"
  endif
  ch := left(tmp2,1)
  if !(ch == "*" .or. ch == "?")
    tmp1 := tmp2
    if "*" $ tmp1 ; tmp1 := beforatnum("*",tmp1,1) ; endif
    if "?" $ tmp1 ; tmp1 := beforatnum("?",tmp1,1) ; endif
    ch := len(tmp1)
    find (tmp1)
    do while tmp1 == left(upper(human->fio),ch) .and. !eof()
      if like(tmp2,upper(human->fio))
        if ++i > 4000 ; exit ; endif
        aadd(tmp_mas,fio_plus_novor()) ; aadd(tmp_kod,human->kod)
      endif
      skip
    enddo
  else
    go top
    do while !eof()
      if like(tmp2,upper(human->fio))
        if ++i > 4000 ; exit ; endif
        aadd(tmp_mas,fio_plus_novor()) ; aadd(tmp_kod,human->kod)
      endif
      skip
    enddo
  endif
  if (t_len := len(tmp_kod)) = 0
    stat_msg("Не найдено ни одной записи, удовлетворяющей данному шаблону!")
    mybell(2,ERR)
    restscreen(13,4,19,77,buf1)
    loop
  else
    box_shadow(mr1,2,22,77)
    SETCOLOR(col_tit_popup)
    @ k1-2,15 say "Шаблон: "+tmp2
    SETCOLOR(color0)
    if k1+t_len+2 < 21
      k2 := k1 + t_len + 2
    endif
    @ k1,3 say center(" Количество найденных фамилий - "+lstr(t_len),74)
    i := ascan(tmp_kod, glob_perso)
    status_key("^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор")
    if (i := popup(k1+1,13,k2,66,tmp_mas,i,color0)) > 0
      if regim_vyb == 1
        goto (tmp_kod[i])
      else
        select TMP_H
        go top
        Locate for kod == tmp_kod[i]
      endif
      fl := 0
    endif
    exit
  endif
enddo
if fl == -1
  goto rec1
endif
restscreen(buf)
return fl

***** 05.03.13
Function f21ret_oms_human()
Local s, r := row(), c := col()
s := "Полис ОМС: "+;
     alltrim(rtrim(human_->SPOLIS)+" "+human_->NPOLIS)+" ("+;
     alltrim(inieditspr(A__MENUVERT, mm_vid_polis, human_->VPOLIS))+")"
@ maxrow()-2,3 say padc(s,74) color color0
setpos(r,c)
return NIL

***** 09.02.14 ФИО пациента + если есть, номер новорожденного ребёнка
Function fio_plus_novor()
return alltrim(human->fio)+;
       iif(human_->NOVOR==0,""," ("+lstr(human_->NOVOR)+"-й реб.)")
