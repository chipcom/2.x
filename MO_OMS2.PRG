***** режимы ввода данных для задачи ОМС (продолжение) - mo_oms2.prg
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 15.04.19 ввод направлений при подозрении на ЗНО - профосмотры несовершеннолетних
Function fget_napr_PN(k,r,c)
Local r1, r2, n := 4, buf, tmp_keys, tmp_list, tmp_color
  buf := savescreen()
  change_attr()
  tmp_keys := my_savekey()
  save gets to tmp_list
  //
  use_base("luslf")
  Use_base("mo_su")
  use (cur_dir+"tmp_onkna") new alias TNAPR
  count_napr := lastrec()
  mNAPR_MO := space(6)
  if cur_napr > 0 .and. cur_napr <= count_napr
    goto (cur_napr) // номер текущего направления
    mNAPR_DATE := tnapr->NAPR_DATE
    m1NAPR_MO := tnapr->NAPR_MO
    if empty(m1NAPR_MO)
      mNAPR_MO := space(60)
    else
      mNAPR_MO := ret_mo(m1NAPR_MO)[_MO_SHORT_NAME]
    endif
    m1NAPR_V := tnapr->NAPR_V
    m1MET_ISSL := tnapr->MET_ISSL
    mu_kod := iif(m1napr_v == 3, tnapr->U_KOD, 0)
    mshifr := iif(m1napr_v == 3, tnapr->shifr_u, space(20))
    mshifr1 := iif(m1napr_v == 3, tnapr->shifr1, space(20))
    mname_u := iif(m1napr_v == 3, tnapr->name_u, space(65))
  else
    cur_napr := 1
    mNAPR_DATE := ctod("")
    m1NAPR_MO := space(6)
    mNAPR_MO := space(60)
    m1NAPR_V := 0
    m1MET_ISSL := 0
    mu_kod := 0
    mshifr := space(20)
    mshifr1 := space(20)
    mname_u := space(65)
  endif
  mNAPR_V := inieditspr(A__MENUVERT, mm_napr_v, m1napr_v)
  mMET_ISSL := inieditspr(A__MENUVERT, mm_MET_ISSL, m1MET_ISSL)
  tip_onko_napr := 0
  j := r-9
  box_shadow(j,0,j+8,maxcol()-2,color1,"Ввод направлений при подозрении на ЗНО",color8)
  ++j; @ j,1 say "НАПРАВЛЕНИЕ №" get cur_napr pict "99" when .f.
       @ j,col() say "(из" get count_napr pict "99" when .f.
       @ j,col() say ")"
       @j,29 say "(<F5> - добавление/редактирование направления №...)" color "G/B"
  ++j; @ j,3 say "Дата направления" get mNAPR_DATE ;
             valid {|| iif(empty(mNAPR_DATE) .or. between(mNAPR_DATE,mn_data,mk_data), .t., ;
                           func_error(4,"Дата направления должна быть внутри сроков лечения")) }
  ++j; @ j,3 say "В какую МО направлен" get mnapr_mo ;
             reader {|x|menu_reader(x,{{|k,r,c|f_get_mo(k,r,c)}},A__FUNCTION,,,.f.)}
  ++j; @ j,3 say "Вид направления" get mnapr_v ;
             reader {|x|menu_reader(x,mm_napr_v,A__MENUVERT,,,.f.)} //; color colget_menu
  ++j; @ j,5 say "Метод диагностического исследования" get mmet_issl ;
             reader {|x|menu_reader(x,mm_met_issl,A__MENUVERT,,,.f.)} ;
             when m1napr_v == 3 //; color colget_menu
  ++j; @ j,5 say "Медицинская услуга" get mshifr pict "@!" ;
             when {|g| m1napr_v == 3 .and. m1MET_ISSL > 0 } ;
             valid {|g|
                        Local fl := f5editkusl(g,2,2)
                        if empty(mshifr)
                          mu_kod  := 0
                          mname_u := space(65)
                          mshifr1 := mshifr
                        elseif fl .and. tip_onko_napr > 0 .and. tip_onko_napr != m1MET_ISSL
                          func_error(4,"Тип медуслуги не соответствует методу диагностического исследования")
                        endif
                        return fl
                   }
  ++j; @ j,7 say "Услуга" get mname_u when .f. color color14
  //
  set key K_F5 TO change_num_napr
  myread()
  set key K_F5
  close databases
  if !(emptyany(mNAPR_DATE,m1NAPR_V) .and. count_napr == 0)
    if cur_napr == 0
      cur_napr := 1
    endif
    use (cur_dir+"tmp_onkna") new alias TNAPR
    count_napr := lastrec()
    if cur_napr <= count_napr
      goto (cur_napr) // номер текущего направления
    else
      append blank
    endif
    tnapr->NAPR_DATE := mNAPR_DATE
    tnapr->NAPR_MO := m1NAPR_MO
    tnapr->NAPR_V := m1NAPR_V
    tnapr->MET_ISSL := iif(m1NAPR_V == 3, m1MET_ISSL, 0)
    tnapr->U_KOD := iif(m1NAPR_V == 3, mu_kod, 0)
    tnapr->shifr_u := iif(m1NAPR_V == 3, mshifr, "")
    tnapr->shifr1 := iif(m1NAPR_V == 3, mshifr1, "")
    tnapr->name_u := iif(m1NAPR_V == 3, mname_u, "")
    cur_napr := recno()
    count_napr := lastrec()
    use
  endif
  setcolor(tmp_color)
  restore gets from tmp_list
  my_restkey(tmp_keys)
  restscreen(buf)
return {0,"Количество направлений - "+lstr(count_napr)}

***** 06.11.19 ДВН - добавление или редактирование случая (листа учета)
Function oms_sluch_DVN(Loc_kod,kod_kartotek,f_print)
// Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
// f_print - наименование функции для печати
Static sadiag1 := {}
Static st_N_DATA, st_K_DATA, s1dispans := 1
Local bg := {|o,k| get_MKB10(o,k,.t.) }, arr_del := {}, mrec_hu := 0,;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
      p_uch_doc := "@!", pic_diag := "@K@!", arr_usl := {}, ah,;
      i, j, k, s, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0, ar, larr, lu_kod,;
      fl, tmp_help := chm_help_code, fl_write_sluch := .f., mu_cena, lrslt_1_etap := 0
//
Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
Default Loc_kod TO 0, kod_kartotek TO 0
//
Private oms_sluch_DVN := .t., ps1dispans := s1dispans
if kod_kartotek == 0 // добавление в картотеку
  if (kod_kartotek := edit_kartotek(0,,,.t.)) == 0
    return NIL
  endif
elseif Loc_kod > 0
  R_Use(dir_server+"human",,"HUMAN")
  goto (Loc_kod)
  fl := (year(human->k_data) < 2018)
  Use
  if fl
    return func_error(4,"Это случай диспансеризации прошлого года")
    //return oms_sluch_DVN13(Loc_kod,kod_kartotek,f_print)
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
Private mfio := space(50), mpol, mdate_r, madres, mvozrast, mdvozrast,;
  M1VZROS_REB, MVZROS_REB, m1novor := 0,;
  m1company := 0, mcompany, mm_company,;
  mkomu, M1KOMU := 0, M1STR_CRB := 0,; // 0-ОМС,1-компании,3-комитеты/ЛПУ,5-личный счет
  msmo := "34007", rec_inogSMO := 0,;
  mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100),;
  mvidpolis, m1vidpolis := 1, mspolis := space(10), mnpolis := space(20)
Private mkod := Loc_kod, mtip_h, is_talon := .f., mshifr_zs := "",;
        mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
  M1LPU := glob_uch[1], MLPU,;
  M1OTD := glob_otd[1], MOTD,;
  M1FIO_KART := 1, MFIO_KART,;
  MRAB_NERAB, M1RAB_NERAB := 0,; // 0-работающий, 1 -неработающий
  mveteran, m1veteran := 0,;
  mmobilbr, m1mobilbr := 0,;
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
  mcena_1 := 0
//
Private arr_usl_dop := {}, arr_usl_otkaz := {}, arr_otklon := {}, m1p_otk := 0
Private metap := 0,;  // 1-первый этап, 2-второй этап, 3-профилактика
        m1ndisp := 3, mndisp, is_dostup_2_year := .f., mnapr_onk := space(10), m1napr_onk := 0,;
        mWEIGHT := 0,;   // вес в кг
        mHEIGHT := 0,;   // рост в см
        mOKR_TALII := 0,; // окружность талии в см
        mtip_mas, m1tip_mas := 0,;
        mkurenie, m1kurenie := 0,; //
        mriskalk, m1riskalk := 0,; //
        mpod_alk, m1pod_alk := 0,; //
        mpsih_na, m1psih_na := 0,; //
        mfiz_akt, m1fiz_akt := 0,; //
        mner_pit, m1ner_pit := 0,; //
        maddn, m1addn := 0, mad1 := 120, mad2 := 80,; // давление
        mholestdn, m1holestdn := 0, mholest := 0,; //"99.99"
        mglukozadn, m1glukozadn := 0, mglukoza := 0,; //"99.99"
        mssr := 0,; // "99"
        mgruppa, m1gruppa := 9      // группа здоровья
Private mot_nasl1, m1ot_nasl1 := 0, mot_nasl2, m1ot_nasl2 := 0,;
        mot_nasl3, m1ot_nasl3 := 0, mot_nasl4, m1ot_nasl4 := 0
Private mdispans, m1dispans := 0, mnazn_l , m1nazn_l  := 0,;
        mdopo_na, m1dopo_na := 0, mssh_na , m1ssh_na  := 0,;
        mspec_na, m1spec_na := 0, msank_na, m1sank_na := 0
Private mvar, m1var
Private mm_ndisp := {{"Диспансеризация I  этап",1},;
                     {"Диспансеризация II этап",2},;
                     {"Профилактический осмотр",3},;
                     {"Дисп.1этап(раз в 2года)",4},;
                     {"Дисп.2этап(раз в 2года)",5}}
Private mm_gruppa, mm_ndisp1, is_disp_19 := .t., is_disp_nabl := .f.
mm_ndisp1 := aclone(mm_ndisp)
// оставляем 3-ий и 4-ый этапы
asize(mm_ndisp1,4) ; hb_ADel(mm_ndisp1, 1, .t.) ; hb_ADel(mm_ndisp1, 1, .t.)
Private mm_gruppaP := {{"Присвоена I группа здоровья"   ,1,343},;
                       {"Присвоена II группа здоровья"  ,2,344},;
                       {"Присвоена III группа здоровья" ,3,345},;
                       {"Присвоена IIIа группа здоровья",3,373},;
                       {"Присвоена IIIб группа здоровья",4,374}}
Private mm_gruppaP_old := aclone(mm_gruppaP)
asize(mm_gruppaP_old,3)
Private mm_gruppaP_new := aclone(mm_gruppaP)
hb_ADel(mm_gruppaP_new,3,.t.)
Private mm_gruppaD1 := {;
  {"Проведена диспансеризация - присвоена I группа здоровья"   ,1,317},;
  {"Проведена диспансеризация - присвоена II группа здоровья"  ,2,318},;
  {"Проведена диспансеризация - присвоена IIIа группа здоровья",3,355},;
  {"Проведена диспансеризация - присвоена IIIб группа здоровья",4,356},;
  {"Направлен на 2 этап, предварительно присвоена I группа здоровья"   ,11,352},;
  {"Направлен на 2 этап, предварительно присвоена II группа здоровья"  ,12,353},;
  {"Направлен на 2 этап, предварительно присвоена IIIа группа здоровья",13,357},;
  {"Направлен на 2 этап, предварительно присвоена IIIб группа здоровья",14,358},;
  {"Направлен на 2 этап и ОТКАЗАЛСЯ, присвоена I группа здоровья"   ,21,352},;
  {"Направлен на 2 этап и ОТКАЗАЛСЯ, присвоена II группа здоровья"  ,22,353},;
  {"Направлен на 2 этап и ОТКАЗАЛСЯ, присвоена IIIа группа здоровья",23,357},;
  {"Направлен на 2 этап и ОТКАЗАЛСЯ, присвоена IIIб группа здоровья",24,358}}
Private mm_gruppaD2 := aclone(mm_gruppaD1)
asize(mm_gruppaD2,4)
Private mm_gruppaD4 := aclone(mm_gruppaD1)
asize(mm_gruppaD4,8)
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
Private mDS_ONK, m1DS_ONK := 0 // Признак подозрения на злокачественное новообразование
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
//
dbcreate(cur_dir+"tmp_onkna", {; // онконаправления
   {"KOD"      ,   "N",     7,     0},; // код больного
   {"NAPR_DATE",   "D",     8,     0},; // Дата направления
   {"NAPR_MO",     "C",     6,     0},; // код другого МО, куда выписано направление
   {"NAPR_V"  ,    "N",     1,     0},; // Вид направления:1-к онкологу,2-на биопсию,3-на дообследование,4-для опр.тактики лечения
   {"MET_ISSL" ,   "N",     1,     0},; // Метод диагностического исследования(при NAPR_V=3):1-лаб.диагностика;2-инстр.диагностика;3-луч.диагностика;4-КТ, МРТ, ангиография
   {"shifr"  ,     "C",    20,     0},;
   {"shifr_u"  ,   "C",    20,     0},;
   {"shifr1"   ,   "C",    20,     0},;
   {"name_u"   ,   "C",    65,     0},;
   {"U_KOD"    ,   "N",     6,     0};  // код услуги
  })
Private m1NAPR_MO, mNAPR_MO, mNAPR_DATE, mNAPR_V, m1NAPR_V, mMET_ISSL, m1MET_ISSL, ;
        mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0
Private mm_napr_v := {{"нет",0},;
                      {"к онкологу",1},;
                      {"на дообследование",3}}
/*Private mm_napr_v := {{"нет",0},;
                      {"к онкологу",1},;
                      {"на биопсию",2},;
                      {"на дообследование",3},;
                      {"для опредения тактики лечения",4}}*/
Private mm_met_issl := {{"нет",0},;
                        {"лабораторная диагностика",1},;
                        {"инструментальная диагностика",2},;
                        {"методы лучевой диагностики (недорогостоящие)",3},;
                        {"дорогостоящие методы лучевой диагностики",4}}
//
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
Private mg_cit := "", m1g_cit := 0, m1lis := 0, mm_g_cit := {;
  {"в МО-обычное иссл-е цитологичес.материала",1},;
  {"в ВОКОД-жидкостное иссл-ие цит.материала",2}}
for i := 1 to 31//count_dvn_arr_usl
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
  m1var := "M1LIS"+lstr(i)
  Private &m1var := 0
  mvar := "MLIS"+lstr(i)
  Private &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
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
      if between(human->ishod,201,205)
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
    letap := human->ishod - 200
    if eq_any(letap,1,4)
      lrslt_1_etap := human_->RSLT_NEW
    endif
    read_arr_DVN(human->kod,.f.)
  endif
endif
if empty(mWEIGHT)
  mWEIGHT := iif(mpol == "М", 70, 55)   // вес в кг
endif
if empty(mHEIGHT)
  mHEIGHT := iif(mpol == "М", 170, 160)  // рост в см
endif
if empty(mOKR_TALII)
  mOKR_TALII := iif(mpol == "М", 94, 80) // окружность талии в см
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
  M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий, 2-обучающ.ОЧНО
  mUCH_DOC    := human->uch_doc
  m1VRACH     := human_->vrach
  /*MKOD_DIAG0  := human_->KOD_DIAG0
  MKOD_DIAG   := human->KOD_DIAG
  MKOD_DIAG2  := human->KOD_DIAG2
  MKOD_DIAG3  := human->KOD_DIAG3
  MKOD_DIAG4  := human->KOD_DIAG4
  MSOPUT_B1   := human->SOPUT_B1
  MSOPUT_B2   := human->SOPUT_B2
  MSOPUT_B3   := human->SOPUT_B3
  MSOPUT_B4   := human->SOPUT_B4
  MDIAG_PLUS  := human->DIAG_PLUS
  for i := 1 to 16
    adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
  next*/
  MPOLIS      := human->POLIS         // серия и номер страхового полиса
  m1VIDPOLIS  := human_->VPOLIS
  mSPOLIS     := human_->SPOLIS
  mNPOLIS     := human_->NPOLIS
  if human->OBRASHEN == '1'
    m1DS_ONK := 1
  endif
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
  is_disp_19 := !(mk_data < d_01_05_2019)
  ret_arr_vozrast_DVN(mk_data)
  ret_arrays_disp(is_disp_19)
  metap := human->ishod-200
  if is_disp_19
    mdvozrast := year(mn_data) - year(mdate_r)
    // если это профосмотр
    if metap == 3 .and. ascan(ret_arr_vozrast_DVN(mk_data),mdvozrast) > 0 // а возраст диспансеризации
      metap := 1 // превращаем в диспансеризацию
      if mk_data < d_01_11_2019 .and. m1rslt == 345
        m1rslt := 355
      elseif mk_data >= d_01_11_2019 .and. m1rslt == 373
        m1rslt := 355
      elseif mk_data >= d_01_11_2019 .and. m1rslt == 374
        m1rslt := 356
      elseif m1rslt == 344
        m1rslt := 318
      else
        m1rslt := 317
      endif
    endif
    if metap == 4
      func_error(4,"Это диспансеризация раз в 2 года - преобразуем в обычную диспансеризацию")
      metap := 1
    elseif metap == 5
      func_error(4,"Это второй этап диспансеризации раз в 2 года - удалите этот случай!")
      close databases
      return NIL
    endif
  endif
  if between(metap,1,5)
    mm_gruppa := {mm_gruppaD1,mm_gruppaD2,mm_gruppaP,mm_gruppaD4,mm_gruppaD2}[metap]
    if (i := ascan(mm_gruppa, {|x| x[3] == m1rslt })) > 0
      m1GRUPPA := mm_gruppa[i,2]
    endif
  endif
  //
  fl_4_1_12 := .f.
  larr := array(2,count_dvn_arr_usl) ; afillall(larr,0)
  R_Use(dir_server+"uslugi",,"USL")
  use_base("human_u")
  find (str(Loc_kod,7))
  do while hu->kod == Loc_kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
      lshifr := usl->shifr
    endif
    lshifr := alltrim(lshifr)
    if eq_any(left(lshifr,5),"70.3.","70.7.","72.1.","72.5.","72.6.","72.7.")
      mshifr_zs := lshifr
    else
      fl := .t.
      if is_disp_19
        //
      else
        if lshifr == "2.3.3" .and. hu_->PROFIL == 3  ; // акушерскому делу
                             .and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"})) > 0
          fl_4_1_12 := .t.
          fl := .f. ; larr[1,i] := hu->(recno())
        endif
      endif
      if fl
        for i := 1 to count_dvn_arr_umolch
          if empty(larr[2,i]) .and. dvn_arr_umolch[i,2] == lshifr
            fl := .f. ; larr[2,i] := hu->(recno()) ; exit
          endif
        next
      endif
      if fl
        for i := 1 to count_dvn_arr_usl
          if empty(larr[1,i])
            if valtype(dvn_arr_usl[i,2]) == "C"
              if dvn_arr_usl[i,2] == "4.20.1"
                if lshifr == "4.20.1"
                  m1g_cit := 1
                elseif lshifr == "4.20.2"
                  m1g_cit := 2 ; fl := .f.
                endif
              endif
              if dvn_arr_usl[i,2] == lshifr
                fl := .f.
                m1var := "m1lis"+lstr(i)
                if is_disp_19
                  &m1var := 0
                elseif glob_yes_kdp2[TIP_LU_DVN] .and. ascan(glob_arr_usl_LIS,dvn_arr_usl[i,2]) > 0 .and. hu->is_edit > 0
                  &m1var := hu->is_edit
                endif
                mvar := "mlis"+lstr(i)
                &mvar := inieditspr(A__MENUVERT, mm_kdp2, &m1var)
              endif
            endif
            if fl .and. len(dvn_arr_usl[i]) > 11 .and. valtype(dvn_arr_usl[i,12]) == "A"
              if ascan(dvn_arr_usl[i,12],{|x| x[1] == lshifr .and. x[2] == hu_->PROFIL}) > 0
                fl := .f.
              endif
            endif
            if !fl
              larr[1,i] := hu->(recno()) ; exit
            endif
          endif
        next
      endif
      if fl .and. ascan(dvn_700,{|x| x[2] == lshifr}) > 0
        fl := .f. // к нулевой услуге добавлена услуга с ценой на "700"
      endif
      if fl
        n_message({"Некорректная настройка в справочнике услуг:",;
                   alltrim(usl->name),;
                   "шифр услуги в справочнике "+usl->shifr,;
                   "шифр ТФОМС - "+opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data)},,;
                  "GR+/R","W+/R",,,"G+/R")
      endif
    endif
    aadd(arr_usl,hu->(recno()))
    select HU
    skip
  enddo
  read_arr_DVN(Loc_kod)
  if metap == 1 .and. between(m1GRUPPA,11,14) .and. m1p_otk == 1
    m1GRUPPA += 10
  endif
  R_Use(dir_server+"mo_pers",,"P2")
  for i := 1 to count_dvn_arr_usl
    if !empty(larr[1,i])
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
      if !empty(hu_->kod_diag) .and. !(left(hu_->kod_diag,1)=="Z")
        mvar := "MKOD_DIAG"+lstr(i)
        &mvar := hu_->kod_diag
      endif
      m1var := "M1OTKAZ"+lstr(i)
      &m1var := 0 // выполнено
      if valtype(dvn_arr_usl[i,2]) == "C"
        if ascan(arr_otklon,dvn_arr_usl[i,2]) > 0
          &m1var := 3 // выполнено, обнаружены отклонения
        elseif dvn_arr_usl[i,2] == "2.3.1" .and. ascan(arr_otklon,"2.3.3") > 0
          &m1var := 3 // выполнено, обнаружены отклонения
        elseif dvn_arr_usl[i,2] == "4.20.1" .and. m1g_cit == 2 .and. ascan(arr_otklon,"4.20.2") > 0
          &m1var := 3 // выполнено, обнаружены отклонения
        elseif fl_4_1_12 .and. dvn_arr_usl[i,2] == "4.1.12"
          &m1var := 2 // НЕВОЗМОЖНОсть
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
        for i := 1 to count_dvn_arr_usl
          if valtype(dvn_arr_usl[i,2]) == "C" .and. ;
                (dvn_arr_usl[i,2] == lshifr .or. (len(dvn_arr_usl[i]) > 11 .and. valtype(dvn_arr_usl[i,12]) == "A" ;
                                                               .and. ascan(dvn_arr_usl[i,12],{|x| x[1] == lshifr}) > 0))
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
  if .t.
    use (cur_dir+"tmp_onkna") new alias TNAPR
    R_Use(dir_server+"mo_su",,"MOSU")
    R_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","NAPR") // онконаправления
    set relation to u_kod into MOSU
    find (str(Loc_kod,7))
    do while napr->kod == Loc_kod .and. !eof()
      cur_napr := 1 // при ред-ии - сначала первое направление текущее
      ++count_napr
      select TNAPR
      append blank
      tnapr->NAPR_DATE := napr->NAPR_DATE
      tnapr->NAPR_MO   := napr->NAPR_MO
      tnapr->NAPR_V    := napr->NAPR_V
      tnapr->MET_ISSL  := napr->MET_ISSL
      tnapr->U_KOD     := napr->U_KOD
      tnapr->shifr_u   := iif(empty(mosu->shifr),mosu->shifr1,mosu->shifr)
      tnapr->shifr1    := mosu->shifr1
      tnapr->name_u    := mosu->name
      select NAPR
      skip
    enddo
    if count_napr > 0
      mnapr_onk := "Количество направлений - "+lstr(count_napr)
    endif
  endif
  for i := 1 to 5
    f_valid_diag_oms_sluch_DVN(,i)
  next i
endif
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
mveteran := inieditspr(A__MENUVERT, mm_danet, m1veteran)
mmobilbr := inieditspr(A__MENUVERT, mm_danet, m1mobilbr)
mkurenie := inieditspr(A__MENUVERT, mm_danet, m1kurenie)
mriskalk := inieditspr(A__MENUVERT, mm_danet, m1riskalk)
mpod_alk := inieditspr(A__MENUVERT, mm_danet, m1pod_alk)
if emptyall(m1riskalk,m1pod_alk) ; m1psih_na := 0 ; endif
mpsih_na := inieditspr(A__MENUVERT, mm_danet, m1psih_na)
mfiz_akt := inieditspr(A__MENUVERT, mm_danet, m1fiz_akt)
mner_pit := inieditspr(A__MENUVERT, mm_danet, m1ner_pit)
maddn    := inieditspr(A__MENUVERT, mm_danet, m1addn)
mholestdn := inieditspr(A__MENUVERT, mm_danet, m1holestdn)
mglukozadn := inieditspr(A__MENUVERT, mm_danet, m1glukozadn)
mot_nasl1 := inieditspr(A__MENUVERT, mm_danet, m1ot_nasl1)
mot_nasl2 := inieditspr(A__MENUVERT, mm_danet, m1ot_nasl2)
mot_nasl3 := inieditspr(A__MENUVERT, mm_danet, m1ot_nasl3)
mot_nasl4 := inieditspr(A__MENUVERT, mm_danet, m1ot_nasl4)
mdispans  := inieditspr(A__MENUVERT, mm_dispans, m1dispans)
mDS_ONK   := inieditspr(A__MENUVERT, mm_danet, M1DS_ONK)
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
mtip_mas := ret_tip_mas(mWEIGHT,mHEIGHT,@m1tip_mas)
ret_ndisp(Loc_kod,kod_kartotek)
//
if !empty(f_print)
  return &(f_print+"("+lstr(Loc_kod)+","+lstr(kod_kartotek)+")")
endif
//
str_1 := " случая диспансеризации/профосмотра взрослого населения"
if Loc_kod == 0
  str_1 := "Добавление"+str_1
  mtip_h := yes_vypisan
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
  if metap == 2 .and. num_screen == 2
    hS := 30 ; wS := 80
  elseif num_screen == 3
    hS := 26 ; wS := 85
  else
    hS := 25 ; wS := 80
  endif
  SetMode(hS,wS)
  @ 0,0 say padc(str_1,wS) color "B/BG*"
  gl_area := {1,0,maxrow()-1,maxcol(),0}
  j := 1
  myclear(j)
  if yes_num_lu == 1 .and. Loc_kod > 0
    @ j,(wS-30) say padl("Лист учета № "+lstr(Loc_kod),29) color color14
  endif
  @ j,0 say "Экран "+lstr(num_screen) color color8
  if num_screen > 1
    s := alltrim(mfio)+" ("+lstr(mvozrast)+" "+s_let(mvozrast)+")"
    @ j,wS-len(s) say s color color14
  endif
  if num_screen == 1 //
    ++j; @ j,1 say "ФИО" get mfio_kart ;
         reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
         valid {|g,o| update_get("mdate_r"),;
                      update_get("mkomu"),update_get("mcompany") }
         @ row(),col()+5 say "Д.р." get mdate_r when .f. color color14
    ++j; @ j,1 say " Работающий?" get mrab_nerab ;
         reader {|x|menu_reader(x,menu_rab,A__MENUVERT,,,.f.)}
         @ j,40 say "Ветеран ВОВ (блокадник)?" get mveteran ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say " Принадлежность счёта" get mkomu ;
               reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
               valid {|g,o| f_valid_komu(g,o) } ;
               color colget_menu
         @ row(),col()+1 say "==>" get mcompany ;
             reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
             when m1komu < 5 ;
             valid {|g| func_valid_ismo(g,m1komu,38) }
    ++j; @ j,1 say " Полис ОМС: серия" get mspolis when m1komu == 0
         @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0
         @ row(),col()+3 say "вид"    get mvidpolis ;
                      reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
                      when m1komu == 0 ;
                      valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
    //
    ++j; @ j,1 say "Сроки" get mn_data ;
               valid {|g| f_k_data(g,1),;
                          iif(mvozrast < 18, func_error(4,"Это не взрослый пациент!"), nil),;
                          ret_ndisp(Loc_kod,kod_kartotek) ;
                     }
         @ row(),col()+1 say "-" get mk_data ;
               valid {|g| f_k_data(g,2),;
                          ret_ndisp(Loc_kod,kod_kartotek) ;
                     }
    if eq_any(metap,3,4) .and. is_dostup_2_year
         @ row(),col()+7 get mndisp /*color color14*/ reader {|x|menu_reader(x,mm_ndisp1,A__MENUVERT,,,.f.)} ;
                         valid {|| metap := m1ndisp, .t. }
    else
         @ row(),col()+7 get mndisp when .f. color color14
    endif
    ++j; @ j,1 say "№ амбулаторной карты" get much_doc picture "@!" ;
               when !(is_uchastok == 1 .and. is_task(X_REGIST)) .or. mem_edit_ist==2
         @ j,col()+5 say "Мобильная бригада?" get mmobilbr ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j
    ++j; @ j,1 say "Курение/употребление табака" get mkurenie ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "Риск пагубного потребления алкоголя (употребление алкоголя)" get mriskalk ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "Риск потребления наркотических/психотропных веществ без назначения врача" get mpod_alk ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "Низкая физическая активность (недостаток физической активности)" get mfiz_akt ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "Нерациональное питание (неприемлемая диета/вредные привычки питания)" get mner_pit ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "Отягощённая наследственность: по злокачественным новообразованиям" get mot_nasl1 ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "                            - по сердечно-сосудистым заболеваниям" get mot_nasl2 ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "               - по хроническим болезням нижних дыхательных путей" get mot_nasl3 ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "                                           - по сахарному диабету" get mot_nasl4 ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j
    ++j; @ j,1 say "Вес" get mWEIGHT pict "999" ;
               valid {|| iif(between(mWEIGHT,30,200),,func_error(4,"Неразумный вес")),;
                         mtip_mas := ret_tip_mas(mWEIGHT,mHEIGHT),;
                         update_get("mtip_mas") }
         @ row(),col()+1 say "кг, рост" get mHEIGHT pict "999" ;
               valid {|| iif(between(mHEIGHT,40,250),,func_error(4,"Неразумный рост")),;
                         mtip_mas := ret_tip_mas(mWEIGHT,mHEIGHT),;
                         update_get("mtip_mas") }
         @ row(),col()+1 say "см, окружность талии" get mOKR_TALII  pict "999" ;
               valid {|| iif(between(mOKR_TALII,40,200),,func_error(4,"Неразумное значение окружности талии")), .t.}
         @ row(),col()+1 say "см"
         @ row(),col()+5 get mtip_mas color color14 when .f.
    ++j; @ j,1 say " Артериальное давление" get mad1 pict "999" ;
               valid {|| iif(between(mad1,60,220),,func_error(4,"Неразумное давление")), .t.}
         @ row(),col() say "/" get mad2 pict "999";
               valid {|| iif(between(mad1,40,180),,func_error(4,"Неразумное давление")),;
                         iif(mad1 > mad2,,func_error(4,"Неразумное давление")),;
                         .t.}
         @ row(),col()+1 say "мм рт.ст.    Гипотензивная терапия" get maddn ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say " Общий холестерин" get mholest pict "99.99" ;
               valid {|| iif(empty(mholest) .or. between(mholest,3,8),,func_error(4,"Неразумное значение холестерина")), .t.}
         @ row(),col()+1 say "ммоль/л     Гиполипидемическая терапия" get mholestdn ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say " Глюкоза" get mglukoza pict "99.99" ;
               valid {|| iif(empty(mglukoza) .or. between(mglukoza,2.2,25),,func_error(4,"Критическое значение глюкозы")), .t.}
         @ row(),col()+1 say "ммоль/л     Гипогликемическая терапия" get mglukozadn ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    status_key("^<Esc>^ выход без записи ^<PgDn>^ на 2-ю страницу")
    if !empty(a_smert)
      n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
    endif
  elseif num_screen == 2 //
    ret_ndisp(Loc_kod,kod_kartotek)
    ++j; @ j,8 get mndisp when .f. color color14
    if mvozrast != mdvozrast
      if m1veteran == 1
        s := "(для ветерана проводится по возрасту "+lstr(mdvozrast)+" "+s_let(mdvozrast)+")"
      else
        s := "(в "+lstr(year(mn_data))+" году исполняется "+lstr(mdvozrast)+" "+s_let(mdvozrast)+")"
      endif
      @ j,80-len(s) say s color color14
    endif
    ++j; @ j,1 say "────────────────────────────────────────────┬─────┬─────┬──────────┬──────────" color color8
    ++j; @ j,1 say "Наименования исследований                   │врач │ассис│дата услуг│выполнение " color color8
    ++j; @ j,1 say "────────────────────────────────────────────┴─────┴─────┴──────────┴──────────" color color8
    //++j; @ j,0 say replicate("─",80) color color8
    //++j; @ j,0 say "_Наименования исследований____________________врач__ассис_дата услуг_выполнение_" color color8
    if mem_por_ass == 0
      @ j-1,52 say space(5)
    endif
    fl_vrach := .t.
    for i := 1 to count_dvn_arr_usl
      fl_diag := .f.
      i_otkaz := 0
      if f_is_usl_oms_sluch_DVN(i,metap,iif(metap==3.and.!is_disp_19,mvozrast,mdvozrast),mpol,@fl_diag,@i_otkaz)
        if fl_diag .and. fl_vrach
          ++j; @ j,1 say "────────────────────────────────────────────┬─────┬─────┬───────────" color color8
          ++j; @ j,1 say "Наименования осмотров                       │врач │ассис│дата услуги" color color8
          ++j; @ j,1 say "────────────────────────────────────────────┴─────┴─────┴───────────" color color8
          //++j; @ j,0 say replicate("─",80) color color8
          //++j; @ j,0 say "_Наименования осмотров________________________врач__ассис_дата услуг_диагноз____" color color8
          if mem_por_ass == 0
            @ j-1,52 say space(5)
          endif
          fl_vrach := .f.
        endif
        fl_g_cit := fl_kdp2 := .f.
        if valtype(dvn_arr_usl[i,2]) == "C"
          if (fl_g_cit := (dvn_arr_usl[i,2] == "4.20.1"))
            if m1g_cit == 0
              m1g_cit := 1 // начальное присвоение
            endif
            mg_cit := inieditspr(A__MENUVERT, mm_g_cit, m1g_cit)
            if mk_data > 0d20190831
              fl_g_cit := .f.
              m1g_cit := 1 // в МО
            endif
          elseif !is_disp_19 .and. glob_yes_kdp2[TIP_LU_DVN] .and. ascan(glob_arr_usl_LIS,dvn_arr_usl[i,2]) > 0
            fl_kdp2 := .t.
          endif
        endif
        mvarv := "MTAB_NOMv"+lstr(i)
        mvara := "MTAB_NOMa"+lstr(i)
        mvard := "MDATE"+lstr(i)
        if empty(&mvard)
          &mvard := mn_data
        endif
        mvarz := "MKOD_DIAG"+lstr(i)
        mvaro := "MOTKAZ"+lstr(i)
        mvarlis := "MLIS"+lstr(i)
        ++j
        if fl_g_cit
          @ j,1 get mg_cit reader {|x|menu_reader(x,mm_g_cit,A__MENUVERT,,,.f.)}
        else
          @ j,1 say dvn_arr_usl[i,1]
        endif
        if fl_kdp2
          @ j,41 get &mvarlis reader {|x|menu_reader(x,mm_kdp2,A__MENUVERT,,,.f.)}
        endif
        @ j,46 get &mvarv pict "99999" valid {|g| v_kart_vrach(g) }
      if mem_por_ass > 0
        @ j,52 get &mvara pict "99999" valid {|g| v_kart_vrach(g) }
      endif
        @ j,58 get &mvard
        if fl_diag
          //@ j,69 get &mvarz picture pic_diag ;
          //       reader {|o|MyGetReader(o,bg)} valid val1_10diag(.t.,.f.,.f.,mn_data,mpol)
        elseif i_otkaz == 0
          @ j,69 get &mvaro ;
                 reader {|x|menu_reader(x,mm_otkaz0,A__MENUVERT,,,.f.)}
        elseif i_otkaz == 1
          @ j,69 get &mvaro ;
                 reader {|x|menu_reader(x,mm_otkaz1,A__MENUVERT,,,.f.)}
        elseif eq_any(i_otkaz,2,3)
          @ j,69 get &mvaro ;
                 reader {|x|menu_reader(x,mm_otkaz,A__MENUVERT,,,.f.)}
        endif
      endif
    next
    ++j; @ j,1 say replicate("─",68) color color8
    status_key("^<Esc>^ выход без записи ^<PgUp>^ на 1-ю страницу ^<PgDn>^ на 3-ю страницу")
  elseif num_screen == 3 //
    mm_gruppa := {mm_gruppaD1,mm_gruppaD2,mm_gruppaP,mm_gruppaD4,mm_gruppaD2}[metap]
    if metap == 3
      if mk_data < d_01_11_2019
        mm_gruppa := mm_gruppaP_old
      else
        mm_gruppa := mm_gruppaP_new
      endif
    endif
    mgruppa := inieditspr(A__MENUVERT, mm_gruppa, m1gruppa)
    ret_ndisp(Loc_kod,kod_kartotek)
    ++j; @ j,8 get mndisp when .f. color color14
    if mvozrast != mdvozrast
      if m1veteran == 1
        s := "(для ветерана проводится по возрасту "+lstr(mdvozrast)+" "+s_let(mdvozrast)+")"
      else
        s := "(в "+lstr(year(mn_data))+" году исполняется "+lstr(mdvozrast)+" "+s_let(mdvozrast)+")"
      endif
      @ j,80-len(s) say s color color14
    endif
    ++j; @ j,1  say "───────┬────────────┬──────────┬──────┬───────────────────────────────────────"
    ++j; @ j,1  say "       │  выявлено  │   дата   │стадия│установлено диспансерное Дата следующего"
    ++j; @ j,1  say "диагноз│заболевание │выявления │забол.│наблюдение     (когда)     визита"
    ++j; @ j,1  say "───────┴────────────┴──────────┴──────┴───────────────────────────────────────"
    //                2      9            22           35       44        54
    ++j; @ j,2  get mdiag1 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN(g,1),;
                                .f.) }
         @ j,9  get mpervich1 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag1)
         @ j,22 get mddiag1 when !empty(mdiag1)
         @ j,35 get m1stadia1 pict "9" range 1,4 ;
                when !empty(mdiag1)
         @ j,44 get mdispans1 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag1)
         @ j,54 get mddispans1 when m1dispans1==1
         @ j,67 get mdndispans1 when m1dispans1==1
    //
    ++j; @ j,2  get mdiag2 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN(g,2),;
                                .f.) }
         @ j,9  get mpervich2 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag2)
         @ j,22 get mddiag2 when !empty(mdiag2)
         @ j,35 get m1stadia2 pict "9" range 1,4 ;
                when !empty(mdiag2)
         @ j,44 get mdispans2 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag2)
         @ j,54 get mddispans2 when m1dispans2==1
         @ j,67 get mdndispans2 when m1dispans2==1
    //
    ++j; @ j,2  get mdiag3 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN(g,3),;
                                .f.) }
         @ j,9  get mpervich3 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag3)
         @ j,22 get mddiag3 when !empty(mdiag3)
         @ j,35 get m1stadia3 pict "9" range 1,4 ;
                when !empty(mdiag3)
         @ j,44 get mdispans3 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag3)
         @ j,54 get mddispans3 when m1dispans3==1
         @ j,67 get mdndispans3 when m1dispans3==1
    //
    ++j; @ j,2  get mdiag4 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN(g,4),;
                                .f.) }
         @ j,9  get mpervich4 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag4)
         @ j,22 get mddiag4 when !empty(mdiag4)
         @ j,35 get m1stadia4 pict "9" range 1,4 ;
                when !empty(mdiag4)
         @ j,44 get mdispans4 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag4)
         @ j,54 get mddispans4 when m1dispans4==1
         @ j,67 get mdndispans4 when m1dispans4==1
    //
    ++j; @ j,2  get mdiag5 picture pic_diag ;
                reader {|o| MyGetReader(o,bg)} ;
                valid  {|g| iif(val1_10diag(.t.,.f.,.f.,mn_data,mpol),;
                                f_valid_diag_oms_sluch_DVN(g,5),;
                                .f.) }
         @ j,9  get mpervich5 ;
                reader {|x|menu_reader(x,mm_pervich,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag5)
         @ j,22 get mddiag5 when !empty(mdiag5)
         @ j,35 get m1stadia5 pict "9" range 1,4 ;
                when !empty(mdiag5)
         @ j,44 get mdispans5 ;
                reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
                when !empty(mdiag5)
         @ j,54 get mddispans5 when m1dispans5==1
         @ j,67 get mdndispans5 when m1dispans5==1
    //
    ++j; @ j,1 say replicate("─",78) color color1
    ++j; @ j,1 say "Диспансерное наблюдение установлено" get mdispans ;
               reader {|x|menu_reader(x,mm_dispans,A__MENUVERT,,,.f.)} ;
               when !emptyall(mdispans1,mdispans2,mdispans3,mdispans4,mdispans5)
  if is_disp_19
    if eq_any(metap,1,3) .and. mdvozrast < 65
      ++j; @ j,1 say iif(mdvozrast<40,"Относительный","Абсолютный")+" суммарный сердечно-сосудистый риск" get mssr pict "99" ;
                 valid {|| iif(between(mssr,0,47),,func_error(4,"Неразумное значение суммарного сердечно-сосудистого риска")), .t.}
           @ row(),col() say "%"
    else
      ++j
    endif
  else
    if metap == 1 .and. mdvozrast < 66
      ++j; @ j,1 say iif(mdvozrast<40,"Относительный","Абсолютный")+" суммарный сердечно-сосудистый риск" get mssr pict "99" ;
                 valid {|| iif(between(mssr,0,47),,func_error(4,"Неразумное значение суммарного сердечно-сосудистого риска")), .t.}
           @ row(),col() say "%"
    elseif metap == 3 .and. mvozrast < 66
      ++j; @ j,1 say "Суммарный сердечно-сосудистый риск" get mssr pict "99" ;
                 valid {|| iif(between(mssr,0,47),,func_error(4,"Неразумное значение суммарного сердечно-сосудистого риска")), .t.}
           @ row(),col() say "%"
    else
      ++j
    endif
  endif
    ++j; @ j,1 say "Признак подозрения на злокачественное новообразование" get mDS_ONK ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "Направления при подозрении на ЗНО" get mnapr_onk ;
               reader {|x|menu_reader(x,{{|k,r,c| fget_napr_PN(k,r,c)}},A__FUNCTION,,,.f.)} ;
               when m1ds_onk == 1
    ++j; @ j,1 say "Назначено лечение" get mnazn_l ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "Направлен на дополнительное обследование" get mdopo_na ;
               reader {|x|menu_reader(x,mm_dopo_na,A__MENUBIT,,,.f.)}
    ++j; @ j,1 say "Направлен" get mnapr_v_mo ;
               reader {|x|menu_reader(x,mm_napr_v_mo,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1napr_v_mo==0, (arr_mo_spec:={},ma_mo_spec:=padr("---",42)), ), update_get("ma_mo_spec")}
         @ j,col()+1 say "к специалистам" get ma_mo_spec ;
               reader {|x|menu_reader(x,{{|k,r,c| fget_spec_DVN(k,r,c,arr_mo_spec)}},A__FUNCTION,,,.f.)} ;
               when m1napr_v_mo > 0
    ++j; @ j,1 say "Направлен на лечение" get mnapr_stac ;
               reader {|x|menu_reader(x,mm_napr_stac,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1napr_stac==0, (m1profil_stac:=0,mprofil_stac:=space(32)), ), update_get("mprofil_stac")}
         @ j,col()+1 say "по профилю" get mprofil_stac ;
               reader {|x|menu_reader(x,glob_V002,A__MENUVERT,,,.f.)} ;
               when m1napr_stac > 0
    ++j; @ j,1 say "Направлен на реабилитацию" get mnapr_reab ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)} ;
               valid {|| iif(m1napr_reab==0, (m1profil_kojki:=0,mprofil_kojki:=space(30)), ), update_get("mprofil_kojki")}
         @ j,col()+1 say ", профиль койки" get mprofil_kojki ;
               reader {|x|menu_reader(x,glob_V020,A__MENUVERT,,,.f.)} ;
               when m1napr_reab > 0
    ++j; @ j,1 say "Направлен на саноторно-курортное лечение" get msank_na ;
               reader {|x|menu_reader(x,mm_danet,A__MENUVERT,,,.f.)}
    ++j; @ j,1 say "ГРУППА состояния ЗДОРОВЬЯ"
         @ j,col()+1 get mGRUPPA ;
                reader {|x|menu_reader(x,mm_gruppa,A__MENUVERT,,,.f.)}
    status_key("^<Esc>^ выход без записи ^<PgUp>^ на 2-ю страницу ^<PgDn>^ ЗАПИСЬ")
  endif
  DispEnd()
  count_edit += myread()
  if num_screen == 3
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
        func_error(4,"Проверьте сроки лечения!")
      endif
    endif
  endif
  SetMode(25,80)
  if k == 3
    loop
  elseif k == 2
    num_screen := 1
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
    if empty(mn_data)
      func_error(4,"Не введена дата начала лечения.")
      loop
    endif
    if mvozrast < 18
      func_error(4,"Профилактика оказана НЕ взрослому пациенту!")
      loop
    endif
    if empty(mk_data)
      func_error(4,"Не введена дата окончания лечения.")
      loop
    endif
    if empty(CHARREPL("0",much_doc,space(10)))
      func_error(4,'Не заполнен номер амбулаторной карты')
      loop
    endif
    if empty(mWEIGHT)
      func_error(4,"Не введён вес.")
      loop
    endif
    if empty(mHEIGHT)
      func_error(4,"Не введён рост.")
      loop
    endif
    if empty(mOKR_TALII)
      func_error(4,"Не введена окружность талии.")
      loop
    endif
    if m1veteran == 1
      if metap == 3
        func_error(4,"Профилактику взрослых не проводят ветеранам ВОВ (блокадникам)")
        loop
      endif
    endif
    //
    mdef_diagnoz := iif(metap==2, "Z01.8 ", "Z00.8 ")
    R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2")
    num_screen := 2
    max_date1 := mn_data
    fl := .t.
    not_4_20_1 := .f.
    date_4_1_12 := ctod("")
    k := ku := kol_d_usl := 0
    arr_osm1 := array(count_dvn_arr_usl,11) ; afillall(arr_osm1,0)
    for i := 1 to count_dvn_arr_usl
      fl_diag := fl_ekg := .f.
      i_otkaz := 0
      if f_is_usl_oms_sluch_DVN(i,metap,iif(metap==3.and.!is_disp_19,mvozrast,mdvozrast),mpol,@fl_diag,@i_otkaz,@fl_ekg)
        mvart := "MTAB_NOMv"+lstr(i)
        if empty(&mvart) .and. (eq_any(metap,2,5) .or. fl_ekg) // ЭКГ, не введён врач
          loop                                                 // и необязательный возраст
        endif
        ar := dvn_arr_usl[i]
        mvara := "MTAB_NOMa"+lstr(i)
        mvard := "MDATE"+lstr(i)
        mvarz := "MKOD_DIAG"+lstr(i)
        mvaro := "M1OTKAZ"+lstr(i)
        if &mvard == mn_data
          k := i
        endif
        if valtype(ar[2]) == "C" .and. ar[2] == "4.20.1"
          if not_4_20_1 // не включать услугу
            loop
          endif
          if m1g_cit == 2
            if empty(&mvard)
              fl := func_error(4,'Не введена дата услуги "'+mg_cit+'"')
            endif
            arr_osm1[i,1]  := 0        // врач
            arr_osm1[i,2]  := -13 //1107     // специальность
            arr_osm1[i,3]  := 0        // ассистент
            arr_osm1[i,4]  := 34       // профиль
            arr_osm1[i,5]  := "4.20.2" // шифр услуги
            arr_osm1[i,6]  := mdef_diagnoz
            arr_osm1[i,9]  := &mvard
            arr_osm1[i,10] := &mvaro
            //if date_4_1_12 < mn_data ; // если 4.1.12 оказано раньше дисп-ии
            //      .or. arr_osm1[i,9] < date_4_1_12 // или 4.20.1 раньше 4.1.12
            //  arr_osm1[i,9] := date_4_1_12 // приравняем даты
            //endif
            max_date1 := max(max_date1,arr_osm1[i,9])
            ++ku
            loop
          endif
        else
          ++kol_d_usl
//my_debug(,"1:"+print_array(ar))
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
          arr_osm1[i,9] := iif(empty(&mvard), mn_data, &mvard)
          arr_osm1[i,10] := &mvaro
          --kol_d_usl
        elseif empty(&mvard)
          fl := func_error(4,'Не введена дата услуги "'+ltrim(ar[1])+'"')
        elseif empty(&mvart)
          fl := func_error(4,'Не введен врач в услуге "'+ltrim(ar[1])+'"')
        else
          select P2
          find (str(&mvart,5))
          if found()
            arr_osm1[i,1] := p2->kod
            arr_osm1[i,2] := -ret_new_spec(p2->prvs,p2->prvs_new)
          endif
          if !empty(&mvara)
            select P2
            find (str(&mvara,5))
            if found()
              arr_osm1[i,3] := p2->kod
            endif
          endif
          if valtype(ar[10]) == "N" // профиль
            arr_osm1[i,4] := ret_profil_dispans(ar[10],arr_osm1[i,2])
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
          ++ku
          if valtype(ar[2]) == "C"
            arr_osm1[i,5] := ar[2] // шифр услуги
            m1var := "m1lis"+lstr(i)
            if !is_disp_19 .and. glob_yes_kdp2[TIP_LU_DVN] .and. &m1var > 0
              arr_osm1[i,11] := &m1var // кровь проверяют в КДП2
            endif
            if ar[2] == "2.3.1"
              if eq_any(arr_osm1[i,2],2002,-206) // специальность-фельдшер
                arr_osm1[i,5] := "2.3.3" // шифр услуги
                arr_osm1[i,4] := 42 // профиль - лечебному делу
              elseif eq_any(arr_osm1[i,2],2003,-207) // Акушерское дело
                arr_osm1[i,5] := "2.3.3" // шифр услуги
                arr_osm1[i,4] := 3 // профиль - акушерскому делу
              endif
            endif
          else
            if len(ar[2]) >= metap
              j := metap
            else
              j := 1
            endif
            arr_osm1[i,5] := ar[2,j] // шифр услуги
            if i == count_dvn_arr_usl // последняя услуга из массива - терапевт
              if eq_any(metap,2,5)
                if eq_any(arr_osm1[i,2],2002,-206) // специальность-фельдшер
                  fl := func_error(4,"Фельдшер не может заменить терапевта на II этапе диспансеризации")
                endif
              else // 1 и 3 этап
                if eq_any(arr_osm1[i,2],2002,-206) // специальность-фельдшер
                  arr_osm1[i,5] := iif(is_disp_19,"2.3.4","2.3.3") // шифр услуги
                  arr_osm1[i,4] := 42 // профиль - лечебному делу
                endif
              endif
            endif
          endif
          if !fl_diag .or. empty(&mvarz) .or. left(&mvarz,1) == "Z"
            arr_osm1[i,6] := mdef_diagnoz
          else
            arr_osm1[i,6] := &mvarz
            select MKB_10
            find (padr(arr_osm1[i,6],6))
            if found() .and. !empty(mkb_10->pol) .and. !(mkb_10->pol == mpol)
              fl := func_error(4,"Несовместимость диагноза по полу "+arr_osm1[i,6])
            endif
          endif
          if (arr_osm1[i,10] := &mvaro) == 1 // отказ
            if arr_osm1[i,5] == "4.1.12" // Осмотр акушеркой, взятие мазка (соскоба)
              not_4_20_1 := .t. // не включать услугу
            endif
          endif
          if i_otkaz == 3 .and. &mvaro == 2 // НЕВОЗМОЖНОСТЬ для услуги 4.1.12
            if is_disp_19
              not_4_20_1 := .t. // не включать услугу
            else
              if arr_osm1[i,2] == 1101 // если указана спец-ть врача
                arr_osm1[i,5] := "2.3.1" // приём врача акушера-гинеколога
                arr_osm1[i,4] := 136 // профиль - акушерству и гинекологии (за исключением использования вспомогательных репродуктивных технологий)
              else
                arr_osm1[i,5] := "2.3.3" // приём фельдшера-акушера
                arr_osm1[i,4] := 3 // профиль - акушерскому делу
              endif
              arr_osm1[i,10] := 0 // нет отказа (? может поставить 3-отклонение?)
              not_4_20_1 := .t. // не включать услугу
            endif
          endif
          arr_osm1[i,9] := &mvard
          // перепишем дату по "связанным" услугам
          do case
            case arr_osm1[i,5] == "4.1.12" // взятие мазка (соскоба)
              date_4_1_12 := arr_osm1[i,9]
            case arr_osm1[i,5] == "4.20.1" // Иссл-е взятого цитологического материала
              //if date_4_1_12 < mn_data ; // если 4.1.12 оказано раньше дисп-ии
              //      .or. arr_osm1[i,9] < date_4_1_12 // или 4.20.1 раньше 4.1.12
              //  arr_osm1[i,9] := date_4_1_12 // приравняем даты
              //endif
          endcase
          max_date1 := max(max_date1,arr_osm1[i,9])
        endif
      endif
      if !fl ; exit ; endif
    next
    if !fl
      loop
    endif
    i_56_1_723 := 0
    if eq_any(metap,2,5)
      if ku < 2
        if !is_disp_19 .and. (i_56_1_723 := ascan(arr_osm1,{|x| valtype(x[5]) == "C" .and. x[5] == "56.1.723"})) > 0
          // одно индивидуальное или групповое углубленное профилактическое консультирование - "56.1.723"
        else
          func_error(4,"На II этапе обязателен осмотр терапевта и ещё какие-либо услуги.")
          loop
        endif
      endif
      if k == 0
        func_error(4,"Дата первого осмотра (исследования) должна равняться дате начала лечения.")
        loop
      endif
    endif
    fl := .t.
    if emptyany(arr_osm1[count_dvn_arr_usl,1],arr_osm1[count_dvn_arr_usl,9])
      if metap == 2 .and. i_56_1_723 > 0
        if !(arr_osm1[i_56_1_723,9] == mn_data .and. arr_osm1[i_56_1_723,9] == mk_data)
          fl := func_error(4,'Начало и окончание должно равняться дате углубленного профилактич.консультирования')
        elseif lrslt_1_etap == 353 // Направлен на 2 этап, предварительно присвоена II группа здоровья
          if m1gruppa != 2
            fl := func_error(4,'Результатом 2-го этапа должна быть II группа здоровья (как и на 1-ом этапе)')
            num_screen := 3
          endif
        else // другой результат
          fl := func_error(4,'Результатом 1-го этапа должна быть II группа (и направлен на 2-ой этап)')
          num_screen := 3
        endif
      else
        fl := func_error(4,'Не введён приём терапевта (врача общей практики)')
      endif
    elseif arr_osm1[count_dvn_arr_usl,9] < mk_data
      fl := func_error(4,'Терапевт (врач общей практики) должен проводить осмотр последним!')
    endif
    if !fl
      loop
    endif
    num_screen := 3
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
        if left(&pole_diag,1) == "Z"
          fl := func_error(4,'Диагноз '+rtrim(&pole_diag)+'(первый символ "Z") не вводится. Это не заболевание!')
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
      if !fl ; exit ; endif
    next
    if !fl
      loop
    endif
    is_disp_nabl := .f.
    afill(adiag_talon,0)
    if empty(arr_diag) // диагнозы не вводили
      aadd(arr_diag, {mdef_diagnoz,0,0,ctod("")}) // диагноз по умолчанию
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
        if ascan(sadiag1,alltrim(arr_diag[i,1])) > 0 .and. ;
                                  arr_diag[i,3] == 1 .and. !empty(arr_diag[i,4]) .and. arr_diag[i,4] > mk_data
          is_disp_nabl := .t.
        endif
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
        if !fl ; exit ; endif
      next
      if !fl
        loop
      endif
    endif
    mm_gruppa := {mm_gruppaD1,mm_gruppaD2,mm_gruppaP,mm_gruppaD4,mm_gruppaD2}[metap]
    if metap == 3
      if mk_data < d_01_11_2019
        mm_gruppa := mm_gruppaP_old
      else
        mm_gruppa := mm_gruppaP_new
      endif
    endif
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
    err_date_diap(mn_data,"Дата начала лечения")
    err_date_diap(mk_data,"Дата окончания лечения")
    //
    if mem_op_out == 2 .and. yes_parol
      box_shadow(19,10,22,69,cColorStMsg)
      str_center(20,'Оператор "'+fio_polzovat+'".',cColorSt2Msg)
      str_center(21,'Ввод данных за '+date_month(sys_date),cColorStMsg)
    endif
    mywait()
    //
    m1lis := 0
    for i := 1 to count_dvn_arr_usl
      if valtype(arr_osm1[i,9]) == "D"
        if arr_osm1[i,5] == "4.20.2" .and. arr_osm1[i,9] < mn_data // не в рамках диспансеризации
          m1g_cit := 1 // если и было =2, убираем
        elseif !is_disp_19 .and. glob_yes_kdp2[TIP_LU_DVN] .and. arr_osm1[i,9] >= mn_data .and. len(arr_osm1[i]) > 10 ;
                                                           .and. valtype(arr_osm1[i,11]) == "N" .and. arr_osm1[i,11] > 0
          m1lis := arr_osm1[i,11] // в рамках диспансеризации
        endif
      endif
    next
    if eq_any(metap,2,5)
      i := count_dvn_arr_usl
      m1vrach  := arr_osm1[i,1]
      m1prvs   := arr_osm1[i,2]
      m1assis  := arr_osm1[i,3]
      m1PROFIL := arr_osm1[i,4]
      //MKOD_DIAG := padr(arr_osm1[i,6],6)
    else  // metap := 1,3,4
      i := len(arr_osm1)
      m1vrach  := arr_osm1[i,1]
      m1prvs   := arr_osm1[i,2]
      m1assis  := arr_osm1[i,3]
      m1PROFIL := arr_osm1[i,4]
      //MKOD_DIAG := padr(arr_osm1[i,6],6)
      aadd(arr_osm1,array(11)) ; i := i_zs := len(arr_osm1)
      arr_osm1[i,1] := arr_osm1[i-1,1]
      arr_osm1[i,2] := arr_osm1[i-1,2]
      arr_osm1[i,3] := arr_osm1[i-1,3]
      arr_osm1[i,4] := 151 // для кода ЗС - мед.осмотрам профилактическим
      arr_osm1[i,5] := ret_shifr_zs_DVN(metap,iif(metap==3.and.!is_disp_19,mvozrast,mdvozrast),mpol,mk_data)
      arr_osm1[i,6] := arr_osm1[i-1,6]
      arr_osm1[i,9] := mn_data
      arr_osm1[i,10] := 0
    endif
    for i := 1 to count_dvn_arr_umolch
      if f_is_umolch_sluch_DVN(i,metap,iif(metap==3.and.!is_disp_19,mvozrast,mdvozrast),mpol)
        ++kol_d_usl
//my_debug(,"1:"+print_array(dvn_arr_umolch[i]))
        aadd(arr_osm1,array(11)) ; j := len(arr_osm1)
        arr_osm1[j,1] := m1vrach
        arr_osm1[j,2] := m1prvs
        arr_osm1[j,3] := m1assis
        arr_osm1[j,4] := m1PROFIL
        arr_osm1[j,5] := dvn_arr_umolch[i,2]
        arr_osm1[j,6] := mdef_diagnoz
        arr_osm1[j,9] := iif(dvn_arr_umolch[i,8]==0, mn_data, mk_data)
        arr_osm1[j,10] := 0
      endif
    next
    if eq_any(metap,1,3,4) // если первый этап, проверим на 85%
      not_zs := .f.
      kol := kol_otkaz := kol_n_date := kol_ob_otkaz := 0
      for i := 1 to len(arr_osm1)
        if i == i_zs
          loop // пропустим код законченного случая
        endif
        if valtype(arr_osm1[i,5]) == "C" .and. !eq_any(arr_osm1[i,5],"4.20.1","4.20.2")
          ++kol // кол-во реально введённых услуг
//my_debug(,"2:"+print_array(arr_osm1[i]))
          if eq_any(arr_osm1[i,10],0,3)
            if is_disp_19
              if arr_osm1[i,9] < mn_data .and. year(arr_osm1[i,9]) < year(mn_data) // кол-во услуг без отказа выполнены ранее
                ++kol_n_date                 // начала проведения диспансеризации и не принадлежат текущему календарному году
              endif
            else
              if arr_osm1[i,9] < mn_data
                ++kol_n_date // кол-во услуг без отказа до периода диспансеризации
              endif
            endif
          elseif arr_osm1[i,10] == 1
            ++kol_otkaz // кол-во отказов
/* При проведении диспансеризации обязательным для всех граждан является:
- "7.57.3" проведение маммографии,
- "4.8.4" исследование кала на скрытую кровь иммунохимическим качественным или количественным методом,
- "2.3.1","2.3.3" осмотр фельдшером (акушеркой) или врачом акушером-гинекологом,
- "4.1.12" взятие мазка с шейки матки,
- "4.20.1","4.20.2" цитологическое исследование мазка с шейки матки,
- "4.14.66" определение простат-специфического антигена в крови */
            if is_disp_19 .and. eq_any(arr_osm1[i,5],"4.8.4","4.14.66","7.57.3","2.3.1","2.3.3","4.1.12","4.20.1","4.20.2")
              ++kol_ob_otkaz // кол-во отказов от обязательных услуг
            endif
          else//if arr_osm1[i,10] == 2 если невозможность проведения - просто вычитаем общее кол-во
            --kol
//my_debug(,"2-:"+print_array(arr_osm1[i]))
          endif
        endif
      next
//my_debug(,"kol_d_usl ="+lstr(kol_d_usl))
//my_debug(,"kol       ="+lstr(kol))
//my_debug(,"kol_otkaz ="+lstr(kol_otkaz))
//my_debug(,"kol_n_date="+lstr(kol_n_date))
      // kol_d_usl = 100% (должно равняться "kol")
      if kol_d_usl != kol
        //func_error(4,"kol_d_usl ("+lstr(kol_d_usl)+") != kol "+lstr(kol))
      endif
      if metap == 4
        if kol_n_date == 1
          not_zs := .t. // выставляем по отдельным тарифам
        endif
      elseif (i := ascan(dvn_85, {|x| x[1] == kol })) > 0 // определить 85%
        k := dvn_85[i,1] - dvn_85[i,2] // 15%
        if is_disp_19
          if kol_n_date+kol_otkaz <= k // отказы + ранее оказано менее 15%
            // выставляем по законченному случаю
            if kol_ob_otkaz > 0 .and. metap == 1 // надо переделать в профосмотр !!!!!
              if (i := ascan(arr_osm1, {|x| valtype(x[5]) == "C" .and. x[5] == "2.3.7" })) > 0
                arr_osm1[i,5] := "2.3.2" // шифр услуги приёма терапевта для профосмотра
              endif
              metap := 3
              if eq_any(m1rslt,355,356,357,358) .and. mk_data < d_01_11_2019 // III группа
                m1rslt := 345
                m1gruppa := 3
              elseif eq_any(m1rslt,355,357) // IIIа группа
                m1rslt := 373
                m1gruppa := 3
              elseif eq_any(m1rslt,356,358) // IIIб группа
                m1rslt := 374
                m1gruppa := 4
              elseif eq_any(m1rslt,318,353)
                m1rslt := 344
                m1gruppa := 2
              else
                m1rslt := 343
                m1gruppa := 1
              endif
              arr_osm1[i_zs,5] := ret_shifr_zs_DVN(metap,mdvozrast,mpol,mk_data)
              func_error(4,"Отказ от обязательного исследования - оформляем профилактический осмотр "+arr_osm1[i_zs,5])
            endif
          else
            // если < 85%, отсечём в проверке
          endif
        else
          if kol_otkaz <= k // оказано 85% и более
            if kol_n_date+kol_otkaz <= k // отказы + ранее оказано менее 15%
              // выставляем по законченному случаю
            else
              not_zs := .t. // выставляем по отдельным тарифам
            endif
          else
            // если "kol - kol_otkaz" < 85%, отсечём в проверке
          endif
        endif
      else
        // если такого кол-ва услуг нет в массиве "dvn_85", отсечём в проверке
      endif
      if not_zs // выставляем по отдельным тарифам
        Del_Array(arr_osm1,i_zs) // удаляем законченный случай
        larr := {}
        for i := 1 to len(arr_osm1)
          if valtype(arr_osm1[i,5]) == "C" ;
                 .and. !(len(arr_osm1[i]) > 10 .and. valtype(arr_osm1[i,11]) == "N" .and. arr_osm1[i,11] > 0) ; // не в КДП2
                 .and. eq_any(arr_osm1[i,10],0,3) ; // не отказ
                 .and. arr_osm1[i,9] >= mn_data ; // оказано во время дисп-ии
                 .and. (k := ascan(dvn_700, {|x| x[1] == arr_osm1[i,5] })) > 0
            aadd(larr,aclone(arr_osm1[i])) ; j := len(larr)
            larr[j,5] := dvn_700[k,2]
          endif
        next
        for i := 1 to len(larr)
          aadd(arr_osm1,aclone(larr[i])) // добавим в массив услуги на "700"
        next
      endif
    endif
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
    glob_podr := "" ; glob_otd_dep := 0
    for i := 1 to len(arr_osm1)
      if valtype(arr_osm1[i,5]) == "C"
        arr_osm1[i,7] := foundOurUsluga(arr_osm1[i,5],mk_data,arr_osm1[i,4],M1VZROS_REB,@mu_cena)
        arr_osm1[i,8] := mu_cena
        mcena_1 += mu_cena
        if eq_any(arr_osm1[i,10],0,3) // выполнено
          aadd(arr_usl_dop,arr_osm1[i])
          if arr_osm1[i,10] == 3 // обнаружены отклонения
            aadd(arr_otklon,arr_osm1[i,5])
          endif
        else // отказ и невозможность
          aadd(arr_usl_otkaz,arr_osm1[i])
        endif
      endif
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
    human->ishod      := 200+metap
    human->OBRASHEN   := iif(m1DS_ONK == 1, '1', " ")
    human->bolnich    := 0
    human->date_b_1   := ""
    human->date_b_2   := ""
    human_->RODIT_DR  := ctod("")
    human_->RODIT_POL := ""
    s := "" ; aeval(adiag_talon, {|x| s += str(x,1) })
    human_->DISPANS   := s
    human_->STATUS_ST := ""
    human_->POVOD     := iif(metap == 3, 5, 6)
    //human_->TRAVMA    := m1travma
    human_->VPOLIS    := m1vidpolis
    human_->SPOLIS    := ltrim(mspolis)
    human_->NPOLIS    := ltrim(mnpolis)
    human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
    human_->NOVOR     := 0
    human_->DATE_R2   := ctod("")
    human_->POL2      := ""
    human_->USL_OK    := m1USL_OK
    human_->VIDPOM    := m1VIDPOM
    human_->PROFIL    := m1PROFIL
    human_->IDSP      := iif(metap == 3, 17, 11)
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
    i2 := len(arr_usl_dop)
    Use_base("human_u")
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
    next
    if i2 < i1
      for i := i2+1 to i1
        select HU
        goto (arr_usl[i])
        DeleteRec(.t.,.f.)  // очистка записи без пометки на удаление
      next
    endif
    save_arr_DVN(mkod)
    // направления при подозрении на ЗНО
    cur_napr := 0
    arr := {}
    G_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","NAPR") // онконаправления
    find (str(mkod,7))
    do while napr->kod == mkod .and. !eof()
      aadd(arr,recno())
      skip
    enddo
    if m1ds_onk == 1 // подозрение на злокачественное новообразование
      Use_base("mo_su")
      use (cur_dir+"tmp_onkna") new alias TNAPR
      select TNAPR
      go top
      do while !eof()
        if !emptyany(tnapr->NAPR_DATE,tnapr->NAPR_V)
          if tnapr->U_KOD == 0 // добавляем в свой справочник федеральную услугу
            select MOSU
            set order to 3
            find (tnapr->shifr1)
            if found()  // наверное, добавили только что
              tnapr->U_KOD := mosu->kod
            else
              set order to 1
              FIND (STR(-1,6))
              if found()
                G_RLock(forever)
              else
                AddRec(6)
              endif
              tnapr->U_KOD := mosu->kod := recno()
              mosu->name   := tnapr->name_u
              mosu->shifr1 := tnapr->shifr1
            endif
          endif
          select NAPR
          if ++cur_napr > len(arr)
            AddRec(7)
            napr->kod := mkod
          else
            goto (arr[cur_napr])
            G_RLock(forever)
          endif
          napr->NAPR_DATE := tnapr->NAPR_DATE
          napr->NAPR_MO := tnapr->NAPR_MO
          napr->NAPR_V := tnapr->NAPR_V
          napr->MET_ISSL := iif(tnapr->NAPR_V == 3, tnapr->MET_ISSL, 0)
          napr->U_KOD := iif(tnapr->NAPR_V == 3, tnapr->U_KOD, 0)
        endif
        select TNAPR
        skip
      enddo
    endif
    select NAPR
    do while ++cur_napr <= len(arr)
      goto (arr[cur_napr])
      DeleteRec(.t.)
    enddo
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
  if type("fl_edit_DVN") == "L"
    fl_edit_DVN := .t.
  endif
  if !empty(val(msmo))
    verify_OMS_sluch(glob_perso)
  endif
endif
return NIL

*

***** 23.01.17
Function f_valid_diag_oms_sluch_DVN(get,k)
Local sk := lstr(k)
Private pole_diag := "mdiag"+sk,;
        pole_d_diag := "mddiag"+sk,;
        pole_pervich := "mpervich"+sk,;
        pole_1pervich := "m1pervich"+sk,;
        pole_stadia := "m1stadia"+sk,;
        pole_dispans := "mdispans"+sk,;
        pole_1dispans := "m1dispans"+sk,;
        pole_d_dispans := "mddispans"+sk
if get == NIL .or. !(&pole_diag == get:original)
  if empty(&pole_diag)
    &pole_pervich := space(12)
    &pole_1pervich := 0
    &pole_d_diag := ctod("")
    &pole_stadia := 1
    &pole_dispans := space(3)
    &pole_1dispans := 0
    &pole_d_dispans := ctod("")
  else
    &pole_pervich := inieditspr(A__MENUVERT, mm_pervich, &pole_1pervich)
    &pole_dispans := inieditspr(A__MENUVERT, mm_danet, &pole_1dispans)
  endif
endif
if emptyall(m1dispans1,m1dispans2,m1dispans3,m1dispans4,m1dispans5)
  m1dispans := 0
elseif m1dispans == 0
  m1dispans := ps1dispans
endif
mdispans := inieditspr(A__MENUVERT, mm_dispans, m1dispans)
update_get(pole_pervich)
update_get(pole_d_diag)
update_get(pole_stadia)
update_get(pole_dispans)
update_get(pole_d_dispans)
update_get("mdispans")
return .t.

***** 19.06.19 рабочая ли услуга ДВН в зависимости от этапа, возраста и пола
Function f_is_usl_oms_sluch_DVN(i,_etap,_vozrast,_pol,/*@*/_diag,/*@*/_otkaz,/*@*/_ekg)
Local fl := .f., ars := {}, ar := dvn_arr_usl[i]
if valtype(ar[3]) == "N"
  fl := (ar[3] == _etap)
else
  fl := ascan(ar[3],_etap) > 0
endif
_diag := (ar[4] == 1)
_otkaz := 0
_ekg := .f.
if valtype(ar[2]) == "C"
  aadd(ars,ar[2])
else
  ars := aclone(ar[2])
endif
if eq_any(_etap,1,3) .and. ar[5] == 1 .and. ascan(ars,"4.20.1") == 0
  _otkaz := 1 // можно ввести отказ
  if valtype(ar[2]) == "C" .and. eq_ascan(ars,"7.57.3","7.61.3","4.1.12")
    _otkaz := 2 // можно ввести невозможность
    if ascan(ars,"4.1.12") > 0 // взятие мазка
      _otkaz := 3 // заменить на приём фельдшера-акушера
    endif
  endif
endif
if fl .and. eq_any(_etap,1,4,5)
  if _etap == 1
    i := iif(_pol == "М", 6, 7)
  elseif len(ar) < 14
    return .f.
  else
    i := iif(_pol == "М", 13, 14)
  endif
  if valtype(ar[i]) == "N" // специально для услуги "Электрокардиография","13.1.1" ранее 2018 года
    fl := (ar[i] != 0)
    if ar[i] < 0  // ЭКГ
      _ekg := (_vozrast < abs(ar[i])) // необязательный возраст
    endif
  else // для 1,4,5 этапа возраст указан массивом
    fl := ascan(ar[i],_vozrast) > 0
  endif
endif
if fl .and. eq_any(_etap,2,3)
  i := iif(_pol=="М", 8, 9)
  if valtype(ar[i]) == "N"
    fl := (ar[i] != 0)
  elseif type("is_disp_19") == "L" .and. is_disp_19
    fl := ascan(ar[i],_vozrast) > 0
  else // для 2 этапа и профилактики возраст указан диапазоном
    fl := between(_vozrast,ar[i,1],ar[i,2])
  endif
endif
return fl

***** 16.06.19 рабочая ли услуга (умолчание) ДВН в зависимости от этапа, возраста и пола
Function f_is_umolch_sluch_DVN(i,_etap,_vozrast,_pol)
Local fl := .f., j, ta, ar := dvn_arr_umolch[i]
if _etap > 3
  return fl
endif
if valtype(ar[3]) == "N"
  fl := (ar[3] == _etap)
else
  fl := ascan(ar[3],_etap) > 0
endif
if fl
  if _etap == 1
    i := iif(_pol=="М", 4, 5)
  else//if _etap == 3
    i := iif(_pol=="М", 6, 7)
  endif
  if valtype(ar[i]) == "N"
    fl := (ar[i] != 0)
  elseif valtype(ar[i]) == "C"
    // "18,65" - для краткого инд.проф.консультирования
    ta := list2arr(ar[i])
    for i := len(ta) to 1 step -1
      if _vozrast >= ta[i]
        for j := 0 to 99
          if _vozrast == int(ta[i]+j*3)
            fl := .t. ; exit
          endif
        next
        if fl ; exit ; endif
      endif
    next
  else
    fl := between(_vozrast,ar[i,1],ar[i,2])
  endif
endif
return fl

*

***** 18.06.18 скорректировать массивы по диспансеризации
Function ret_arrays_disp(is_disp_19)
Static sp := 0
Local p := iif(is_disp_19, 2, 1), blk
if p != sp
  if (sp := p) == 1
    dvn_arr_usl := aclone(dvn_arr_usl18)
    dvn_arr_umolch := aclone(dvn_arr_umolch18)
  else
    blk := {|d1,d2,d|
                      Local i, arr := {}
                      DEFAULT d TO 1
                      for i := d1 to d2 step d
                        aadd(arr,i)
                      next
                      return arr
           }
    dvn_arr_usl := {; // Услуги на экран для ввода
      {"Измерение внутриглазного давления","3.4.9",1,0,1,;
        eval(blk,40,99),;
        eval(blk,40,99),;
        1,1,65,{1112};
       },;
      {"Исследование крови на общий холестерин","4.12.174",{1,3},0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Исследование уровня глюкозы в крови","4.12.169",{1,3},0,1,;
        1,1,1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Клинический анализ крови (3 показателя)","4.11.137",1,0,1,;
        eval(blk,40,99),;
        eval(blk,40,99),;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Исследование кала на скрытую кровь","4.8.4",1,0,1,;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,65,66,67,68,69,70,71,72,73,74,75},;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,65,66,67,68,69,70,71,72,73,74,75},;
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Кровь на простат-специфический антиген","4.14.66",1,0,1,;
        {45,50,55,60,64},;
        0,;
        1,0,34,{1107,1301,1402,1702,1801,2011,2013};
       },;
      {"Осмотр акушеркой или акушером-гинекологом","2.3.1",{1,3},0,1,; // женщины
        0,1,0,1,{3,42,136},{2003,2002,1101},;
        {{"2.3.1",136},{"2.3.3",3},{"2.3.3",42}},1,1;
       },;
      {"Взятие мазка (соскоба) с пов-ти шейки матки","4.1.12",1,0,1,; // женщины
        0,;
        {18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63},;
        1,1,{3,42,136},{2003,2002,1101};
       },;
      {"Иссл-е взятого цитологического материала","4.20.1",1,0,1,; // если невозможна 4.1.12
        0,;
        {18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63},;     // то очистить
        1,1,34,{1107,1301,1402,1702,1801,2011,2013};               // эту услугу
       },;
      {"Маммография обеих молочных желез","7.57.3",1,0,1,; // женщины
        0,;
        {40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74},;
        0,1,78,{1118,1802,2020};
       },;
      {"Флюорография лёгких профилактическая","7.61.3",{1,3},0,1,;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        eval(blk,18,99,2),;
        78,{1118,1802,2020};
       },;
      {"Электрокардиография (в покое)","13.1.1",{1,3},0,1,;
        eval(blk,35,99),;
        eval(blk,35,99),;
        eval(blk,35,99),;
        eval(blk,35,99),;
        111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202,2021};
       },;
      {"Фиброэзофагогастродуоденоскопия","10.3.13",1,0,1,;
        {45},;
        {45},;
        1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Фиброэзофагогастродуоденоскопия","10.3.713",2,0,1,;
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Спирометрия","16.1.717",2,0,1,; // "2.84.11"
        1,1,1,1,111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202,2021};
       },;
      {"Дуплексное сканир-ие брахиоцефальных артерий","8.23.706",2,0,1,; // "2.84.1"
        1,1,1,1,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203};
       },;
      {"Рентгенография органов грудной клетки","7.2.702",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"КТ органов грудной полости","7.2.701",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"Спиральная КТ легких","7.2.703",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"КТ органов грудной полости (с контрастир-ием)","7.2.704",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"Однофотонная эмиссионная КТ легких","7.2.705",2,0,1,;
        1,1,1,1,78,{1118,1802};
       },;
      {"Ректосигмоколоноскопия диагностическая","10.6.710",2,0,1,; // "2.84.6"
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Ректороманоскопия","10.4.701",2,0,1,;                      // "2.84.6"
        1,1,1,1,123,{110104,111007,112221,112609,113419,113511};
       },;
      {"Углубленное профилактическое консультирование","56.1.723",2,0,1,;
        1,1,1,1,{97,57,42},{1122,1110,2002};
       },;
      {"Приём врача невролога","2.84.1",2,1,0,;
        1,1,1,1,53,{1109};
       },;
      {"Приём врача офтальмолога","2.84.3",2,1,0,;
        1,1,1,1,65,{1112};
       },;
      {"Приём врача оториноларинголога","2.84.8",2,1,0,;
        1,1,1,1,162,{1111};
       },;
      {"Приём врача уролога (хирурга)","2.84.10",2,1,0,;
        1,1,1,0,{108,112},{112603,1126};
       },;
      {"Приём врача акушера-гинеколога","2.84.5",2,1,0,;
        1,1,0,1,136,{1101};
       },;
      {"Приём врача колопроктолога (хирурга)","2.84.6",2,1,0,;
        1,1,1,1,{30,30,112},{112601,113503,1126};
       },;
      {"Приём врача терапевта",{"2.3.7","2.84.11","2.3.2"},{1,2,3},1,0,;
        1,1,1,1,{97,57,42},{1122,1110,2002},;
        {{"2.3.7",57},{"2.3.7",97},{"2.3.2",57},{"2.3.2",97},{"2.3.4",42},{"2.84.11",57},{"2.84.11",97}},1,1;
       };
     }
    //
    dvn_arr_umolch := {; // услуги, записываемые всегда по умолчанию
      {"Опрос (анкетирование)","56.1.16",{1,3},1,1,1,1,0},;
      {"Измерение артериального давления","3.1.5",{1,3},1,1,1,1,0},;
      {"Антропометрия, расчёт индекса массы тела","3.1.19",{1,3},1,1,1,1,0},;
      {"Определение относительного суммарного сердечно-сосудистого риска","56.1.18",{1,3},{18,39},{18,39},{18,39},{18,39},1},;
      {"Определение абсолютного суммарного сердечно-сосудистого риска","56.1.19",1,{40,64},{40,64},1,1,1},;
      {"Краткое индивидуальное профилактическое консультирование","56.1.14",1,"18,65","18,65",1,1,1};
    }
  endif
  count_dvn_arr_usl := len(dvn_arr_usl)
  count_dvn_arr_umolch := len(dvn_arr_umolch)
  //aeval(dvn_arr_usl,{|x| my_debug(,print_array(x)) })
  //my_debug(,lstr(count_dvn_arr_usl))
  //aeval(dvn_arr_umolch,{|x| my_debug(,print_array(x)) })
  //my_debug(,lstr(count_dvn_arr_umolch))
endif
return NIL

***** 15.06.18 скорректировать возраст диспансеризации для ветеранов
Function ret_vozr_DVN_veteran(_dvozrast,_data)
Local i, _arr_vozrast_DVN := ret_arr_vozrast_DVN(_data)
if ascan(_arr_vozrast_DVN,_dvozrast) == 0
  if _dvozrast < _arr_vozrast_DVN[1]
    _dvozrast := _arr_vozrast_DVN[1]
  elseif _dvozrast > atail(_arr_vozrast_DVN)
    _dvozrast := atail(_arr_vozrast_DVN)
  else
    for i := 2 to len(_arr_vozrast_DVN)
      if between(_dvozrast,_arr_vozrast_DVN[i-1],_arr_vozrast_DVN[i])
        if _dvozrast == _arr_vozrast_DVN[i-1] + 1
          _dvozrast := _arr_vozrast_DVN[i-1]
        else
          _dvozrast := _arr_vozrast_DVN[i]
        endif
        exit
      endif
    next
  endif
endif
return _dvozrast

***** 15.06.19 вернуть массив возрастов дисп-ии для старого или нового Приказов МЗ РФ
Function ret_arr_vozrast_DVN(_data)
Static sp := 0, arr := {}
Local i, p := iif(_data < d_01_05_2019, 1, 2)
if p != sp
  arr := aclone(arr_vozrast_DVN) // по старому Приказу МЗ РФ
  if (sp := p) == 2 // по новому Приказу МЗ РФ
    asize(arr,7) // уберём хвост после 39 лет {21,24,27,30,33,36,39,
    Ins_Array(arr,1,18) // вставим в начало =18 лет
    for i := 40 to 99
      aadd(arr,i) // добавим в конец подряд с 40 по 99 лет
    next
    //my_debug(,print_array(arr))
  endif
endif
return arr

***** 02.07.19
Function ret_ndisp(lkod_h,lkod_k,/*@*/new_etap,/*@*/msg)
Local i, i1, i2, i3, i4, i5, s, s1, is_disp, ar, fl := .t.
is_disp_19 := !(mk_data < d_01_05_2019)
ret_arrays_disp(is_disp_19)
msg := " "
new_etap := metap
is_dostup_2_year := .f.
if m1veteran == 1
  mdvozrast := ret_vozr_DVN_veteran(mdvozrast,mk_data)
endif
if !(is_disp := ascan(ret_arr_vozrast_DVN(mk_data),mdvozrast) > 0)
  if !is_disp_19 // по старому приказу МЗ РФ
    is_dostup_2_year := ascan(arr2m_vozrast_DVN,mdvozrast) > 0
    if !is_dostup_2_year .and. mpol == "Ж"
      is_dostup_2_year := ascan(arr2g_vozrast_DVN,mdvozrast) > 0
    endif
  endif
endif
if metap == 0
  if is_disp
    new_etap := 1
  else
    new_etap := 3
  endif
elseif metap == 3
  if is_disp
    new_etap := 1
  else
    // остаётся = 3
  endif
else
  if is_disp
    // остаётся = 1 или 2
  elseif new_etap < 4
    new_etap := 3
  endif
endif
ar := ret_etap_DVN(lkod_h,lkod_k)
if new_etap != 3
  if empty(ar[1]) // в этом году ещё ничего не делали
    // оставляем 1
  else
    i1 := i2 := i3 := i4 := i5 := 0
    for i := 1 to len(ar[1])
      do case
        case ar[1,i,1] == 1 // дисп-ия 1 этап
          i1 := i
        case ar[1,i,1] == 2 // дисп-ия 2 этап
          i2 := i
        case ar[1,i,1] == 3 // профилактика
          i3 := i
          msg := date_8(ar[1,i,2])+"г. уже проведён профилактический медосмотр!"
        case ar[1,i,1] == 4 // дисп-ия 1 этап 1 раз в 2 года
          i4 := i
          msg := "В "+lstr(year(mn_data))+" году уже проведена диспансеризации 1 раз в 2 года"
        case ar[1,i,1] == 5 // дисп-ия 2 этап 1 раз в 2 года
          i5 := i
          msg := "В "+lstr(year(mn_data))+" году уже проведена диспансеризации 1 раз в 2 года"
      endcase
    next
    if eq_any(new_etap,1,2) .and. new_etap != metap
      if i1 == 0
        new_etap := 1 // делаем 1 этап
      elseif i2 == 0
        new_etap := 2 // делаем 2 этап
      endif
    endif
    if i1 > 0 .and. i2 > 0
      msg := "В "+lstr(year(mn_data))+" году уже проведены оба этапа диспансеризации!"
    elseif i1 > 0 .and. !empty(ar[1,i1,2]) .and. ar[1,i1,2] > mn_data
      msg := "Диспансеризация I этапа закончилась "+date_8(ar[1,i1,2])+"г.!"
    endif
    if eq_any(new_etap,4,5) .and. new_etap != metap
      if i4 == 0
        new_etap := 4 // делаем 1 этап
      elseif i5 == 0
        new_etap := 5 // делаем 2 этап
      endif
    endif
    if i4 > 0 .and. i5 > 0
      msg := "В "+lstr(year(mn_data))+" году уже проведены оба этапа диспансеризации (раз в 2 года)!"
    elseif i4 > 0 .and. !empty(ar[1,i4,2]) .and. ar[1,i4,2] > mn_data
      msg := "Диспансеризация I этапа (раз в 2 года) закончилась "+date_8(ar[1,i4,2])+"г.!"
    endif
  endif
else //if new_etap == 3
  if empty(ar[1]) // в этом году ещё ничего не делали
    if empty(ar[2]) // посмотрим прошлый год
      // оставляем 3
    elseif ascan(ar[2],{|x| x[1] == 3 }) > 0 // профилактика была в прошлом году
      if is_dostup_2_year
        new_etap := 4 // сразу разрешаем дисп-ию 1 раз в 2 года, т.к. в прошлом
      else
        msg := "Профилактика проводится 1 раз в 2 года ("+date_8(ar[2,1,2])+"г. уже проведена)"
      endif
    endif
  else
    i1 := i2 := i3 := i4 := i5 := 0
    for i := 1 to len(ar[1])
      do case
        case ar[1,i,1] == 1 // дисп-ия 1 этап
          i1 := i
          msg := date_8(ar[1,i,2])+"г. уже проведена диспансеризация I этапа!"
        case ar[1,i,1] == 2 // дисп-ия 2 этап
          i2 := i
          msg := date_8(ar[1,i,2])+"г. уже проведена диспансеризация II этапа!"
        case ar[1,i,1] == 3 // профилактика
          i3 := i
          msg := date_8(ar[1,i,2])+"г. уже проведён профилактический медосмотр!"
        case ar[1,i,1] == 4 // дисп-ия 1 этап раз в 2 года
          i4 := i
        case ar[1,i,1] == 5 // дисп-ия 2 этап раз в 2 года
          i5 := i
      endcase
    next
    if i4 > 0
      if i5 > 0
        msg := "В "+lstr(year(mn_data))+" году уже проведены оба этапа диспансеризации (раз в 2 года)!"
      elseif !empty(ar[1,i4,2]) .and. ar[1,i4,2] > mn_data
        msg := "Диспансеризация I этапа (раз в 2 года) закончилась "+date_8(ar[1,i4,2])+"г.!"
      else
        new_etap := 5 // делаем 2 этап
      endif
    endif
  endif
endif
if empty(msg)
  metap := new_etap
  mndisp := inieditspr(A__MENUVERT, mm_ndisp, metap)
else
  metap := 0
  mndisp := space(23)
  func_error(4,fam_i_o(mfio)+" "+msg)
endif
return fl

***** 15.06.19
Function ret_etap_DVN(lkod_h,lkod_k)
Local ae := {{},{}}, fl, i, k, d1 := year(mn_data)
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
set relation to recno() into HUMAN_
find (str(lkod_k,7))
do while human->kod_k == lkod_k .and. !eof()
  fl := (lkod_h != human->(recno()))
  if fl .and. human->schet > 0 .and. human_->oplata == 9
    fl := .f. // лист учёта снят по акту и выставлен повторно
  endif
  if fl .and. between(human->ishod,201,205) // ???
    i := human->ishod-200
    if year(human->n_data) == d1 // текущий год
      aadd(ae[1],{i,human->k_data,human_->RSLT_NEW})
    //elseif i >= 3 .and. mk_data < d_01_05_2019 .and. year(human->n_data) == d1-1 // профилактика прошлый год ???
      //aadd(ae[2],{i,human->k_data,human_->RSLT_NEW})
    endif
  endif
  skip
enddo
close databases
return ae

***** 08.08.13 вернуть тип массы в строке
Function ret_tip_mas(_WEIGHT,_HEIGHT,/*@*/ret)
Static mm_tip_mas := {{"Дефицит массы тела",0,18.4},;
                      {"Нормальная масса тела",18.5,24.9},;
                      {"Избыточная масса тела",25.0,29.9},;
                      {"Ожирение I степени",30.0,34.9},;
                      {"Ожирение II степени",35.0,39.9},;
                      {"Ожирение III степени",40.0,9999}}
Local i, k, s := ""
ret := 2
if !emptyany(_WEIGHT,_HEIGHT)
  _HEIGHT /= 100  // рост из сантиметров в метры
  k := round(_WEIGHT/_HEIGHT/_HEIGHT,1) // индекс Кетле
  if (i := ascan(mm_tip_mas,{|x| between(k,x[2],x[3]) })) > 0
    ret := i
    s := mm_tip_mas[i,1]
  endif
endif
return padr(s,21)

/*
70.7.1	Законченный случай диспансеризации взрослых 1 этап (мужчины 18,24,30)
70.7.2	Законченный случай диспансеризации взрослых 1 этап (мужчины 21,27,33)
70.7.3	Законченный случай диспансеризации взрослых 1 этап (мужчины 40,44,46,52,56,58,62)
70.7.4	Законченный случай диспансеризации взрослых 1 этап (мужчины 42,48,54)
70.7.5	Законченный случай диспансеризации взрослых 1 этап (мужчины 41,43,47,49,53,59)
70.7.6	Законченный случай диспансеризации взрослых 1 этап (мужчины 50,64)
70.7.7	Законченный случай диспансеризации взрослых 1 этап (мужчины 51,57,63)
70.7.8	Законченный случай диспансеризации взрослых 1 этап (мужчины 55)
70.7.9	Законченный случай диспансеризации взрослых 1 этап (мужчины 60)
70.7.10	Законченный случай диспансеризации взрослых 1 этап (мужчины 61)
70.7.11	Законченный случай диспансеризации взрослых 1 этап (мужчины 36)
70.7.12	Законченный случай диспансеризации взрослых 1 этап (мужчины 39)
70.7.13	Законченный случай диспансеризации взрослых 1 этап (мужчины 45)
70.7.14	Законченный случай диспансеризации взрослых 1 этап (женщины 18,24,30)
70.7.15	Законченный случай диспансеризации взрослых 1 этап (женщины 21,27,33)
70.7.16	Законченный случай диспансеризации взрослых 1 этап (женщины 42,48,54,60)
70.7.17	Законченный случай диспансеризации взрослых 1 этап (женщины 40,44,46,50,52,56,58,62,64)
70.7.18	Законченный случай диспансеризации взрослых 1 этап (женщины 41,43,47,49)
70.7.19	Законченный случай диспансеризации взрослых 1 этап (женщины 51,57,63)
70.7.20	Законченный случай диспансеризации взрослых 1 этап (женщины 53,55,59,61)
70.7.21	Законченный случай диспансеризации взрослых 1 этап (женщины 36)
70.7.22	Законченный случай диспансеризации взрослых 1 этап (женщины 39)
70.7.23	Законченный случай диспансеризации взрослых 1 этап (женщины 45)
70.7.24	Законченный случай диспансеризации взрослых 1 этап (65,71)
70.7.25	Законченный случай диспансеризации взрослых 1 этап (66,70,72)
70.7.26	Законченный случай диспансеризации взрослых 1 этап (67,69,73,75)
70.7.27	Законченный случай диспансеризации взрослых 1 этап (68,74)
70.7.28	Законченный случай диспансеризации взрослых 1 этап (76,78,82,84,88,90,94,96)
70.7.29	Законченный случай диспансеризации взрослых 1 этап (80,86,92,98)
70.7.30	Законченный случай диспансеризации взрослых 1 этап (77,83,89,95)
70.7.31	Законченный случай диспансеризации взрослых 1 этап (79,81,85,87,91,93,97,99)
*/
***** 19.06.19 вернуть шифр услуги законченного случая для ДВН
Function ret_shifr_zs_DVN(_etap,_vozrast,_pol,_date)
Local lshifr := "", fl, is_disp, n := 1
if _date >= 0d20190501 // с 1 мая
  if _etap == 1
    if _pol == "М" // мужчины
      if eq_any(_vozrast,18,24,30)
        n := 1
      elseif eq_any(_vozrast,21,27,33)
        n := 2
      elseif eq_any(_vozrast,40,44,46,52,56,58,62)
        n := 3
      elseif eq_any(_vozrast,42,48,54)
        n := 4
      elseif eq_any(_vozrast,41,43,47,49,53,59)
        n := 5
      elseif eq_any(_vozrast,50,64)
        n := 6
      elseif eq_any(_vozrast,51,57,63)
        n := 7
      elseif _vozrast == 55
        n := 8
      elseif _vozrast == 60
        n := 9
      elseif _vozrast == 61
        n := 10
      elseif _vozrast == 36
        n := 11
      elseif _vozrast == 39
        n := 12
      elseif _vozrast == 45
        n := 13
      elseif eq_any(_vozrast,65,71)
        n := 24
      elseif eq_any(_vozrast,66,70,72)
        n := 25
      elseif eq_any(_vozrast,67,69,73,75)
        n := 26
      elseif eq_any(_vozrast,68,74)
        n := 27
      elseif eq_any(_vozrast,76,78,82,84,88,90,94,96)
        n := 28
      elseif eq_any(_vozrast,80,86,92,98)
        n := 29
      elseif eq_any(_vozrast,77,83,89,95)
        n := 30
      elseif eq_any(_vozrast,79,81,85,87,91,93,97,99)
        n := 31
      endif
    else // женщины
      if eq_any(_vozrast,18,24,30)
        n := 14
      elseif eq_any(_vozrast,21,27,33)
        n := 15
      elseif eq_any(_vozrast,42,48,54,60)
        n := 16
      elseif eq_any(_vozrast,40,44,46,50,52,56,58,62,64)
        n := 17
      elseif eq_any(_vozrast,41,43,47,49)
        n := 18
      elseif eq_any(_vozrast,51,57,63)
        n := 19
      elseif eq_any(_vozrast,53,55,59,61)
        n := 20
      elseif _vozrast == 36
        n := 21
      elseif _vozrast == 39
        n := 22
      elseif _vozrast == 45
        n := 23
      elseif eq_any(_vozrast,65,71)
        n := 32
      elseif eq_any(_vozrast,66,70,72)
        n := 33
      elseif eq_any(_vozrast,67,69,73,75)
        n := 34
      elseif eq_any(_vozrast,68,74)
        n := 35
      elseif eq_any(_vozrast,76,78,82,84,88,90,94,96)
        n := 36
      elseif eq_any(_vozrast,77,83,89,95)
        n := 37
      elseif eq_any(_vozrast,79,81,85,87,91,93,97,99)
        n := 38
      elseif eq_any(_vozrast,80,86,92,98)
        n := 39
      endif
    endif
    if m1g_cit == 2
      if m1mobilbr == 1
        n += 600
      else
        n += 500
      endif
    else
      if m1mobilbr == 1
        n += 300
      endif
    endif
    lshifr := "70.7."+lstr(n)
  elseif _etap == 3
    is_disp := (ascan(ret_arr_vozrast_DVN(_date),_vozrast) > 0)
/*
72.5.1	Законченный случай профилактического медицинского осмотра взрослых (мужчины 19,23,25,29,31)
72.5.2	Законченный случай профилактического медицинского осмотра взрослых (мужчины 20,22,26,28,32,34)
72.5.3	Законченный случай профилактического медицинского осмотра взрослых (мужчины 35,37)
72.5.4	Законченный случай профилактического медицинского осмотра взрослых (мужчины 38)
72.5.5	Законченный случай профилактического медицинского осмотра взрослых (женщины 19,23,25,29,31)
72.5.6	Законченный случай профилактического медицинского осмотра взрослых (женщины 20,22,26,28,32,34)
72.5.7	Законченный случай профилактического медицинского осмотра взрослых (женщины 35,37)
72.5.8	Законченный случай профилактического медицинского осмотра взрослых (женщины 38)
*/
    if !is_disp // профосмотр оформлен как обычно
      if _pol == "М" // мужчины
        if eq_any(_vozrast,19,23,25,29,31)
          n := 1
        elseif eq_any(_vozrast,20,22,26,28,32,34)
          n := 2
        elseif eq_any(_vozrast,35,37)
          n := 3
        else // _vozrast == 38
          n := 4
        endif
      else // женщины
        if eq_any(_vozrast,19,23,25,29,31)
          n := 5
        elseif eq_any(_vozrast,20,22,26,28,32,34)
          n := 6
        elseif eq_any(_vozrast,35,37)
          n := 7
        else // _vozrast == 38
          n := 8
        endif
      endif
      if m1mobilbr == 1
        n += 300
      endif
      // "6" - в рамках диспансерного наблюдения
      fl := .t.
      if type("is_disp_nabl") == "L" .and. is_disp_nabl
        fl := .f.
      endif
      lshifr := "72."+iif(fl,"5","6")+"."+lstr(n)
    else // если вместо диспансеризации оформляется профосмотр
/*
72.7.1	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 18,24,30)
72.7.2	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 21,27,33)
72.7.3	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 40,42,44,46,48,50,52,54,56,58,60,62,64)
72.7.4	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 41,43,45,47,49,51,53,55,57,59,61,63)
72.7.5	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 36)
72.7.6	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 39)
72.7.7	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 18,24,30)
72.7.8	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 21,27,33)
72.7.9	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 40,42,44,46,48,50,52,54,56,58,60,62,64)
72.7.10	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 41,43,45,47,49,51,53,55,57,59,61,63)
72.7.11	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 36)
72.7.12	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 39)
72.7.13	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
72.7.14	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (мужчины 66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
72.7.15	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
72.7.16	Законченный случай профилактического медицинского осмотра взрослых в год диспансеризации (женщины 66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
*/
      if _pol == "М" // мужчины
        if eq_any(_vozrast,18,24,30)
          n := 1
        elseif eq_any(_vozrast,21,27,33)
          n := 2
        elseif eq_any(_vozrast,40,42,44,46,48,50,52,54,56,58,60,62,64)
          n := 3
        elseif eq_any(_vozrast,41,43,45,47,49,51,53,55,57,59,61,63)
          n := 4
        elseif _vozrast == 36
          n := 5
        elseif _vozrast == 39
          n := 6
        elseif eq_any(_vozrast,65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
          n := 13
        elseif eq_any(_vozrast,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
          n := 14
        endif
      else // женщины
        if eq_any(_vozrast,18,24,30)
          n := 7
        elseif eq_any(_vozrast,21,27,33)
          n := 8
        elseif eq_any(_vozrast,40,42,44,46,48,50,52,54,56,58,60,62,64)
          n := 9
        elseif eq_any(_vozrast,41,43,45,47,49,51,53,55,57,59,61,63)
          n := 10
        elseif _vozrast == 36
          n := 11
        elseif _vozrast == 39
          n := 12
        elseif eq_any(_vozrast,65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99)
          n := 15
        elseif eq_any(_vozrast,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98)
          n := 16
        endif
      endif
      if m1mobilbr == 1
        n += 300
      endif
      lshifr := "72.7."+lstr(n)
    endif
  endif
elseif _etap == 1 // до 1 мая
  if _pol == "М" // мужчины
    if eq_any(_vozrast,21,24,27,30,33)
      lshifr := iif(m1lis > 0, "70.3.98", "70.3.97")
//70.3.97 ЗС дисп-ии мужчин (21,24,27,30,33 лет), 1 этап
//70.3.98 ЗС дисп-ии мужчин (21,24,27,30,33 лет) без гематологических исследований, 1 этап
    elseif eq_any(_vozrast,36,39,42,48,54)
      lshifr := iif(m1lis > 0, "70.3.100", "70.3.99")
//70.3.99 ЗС дисп-ии мужчин (36,39,42,48,54 лет), 1 этап
//70.3.100 ЗС дисп-ии мужчин (36,39,42,48,54 лет) без гематологических исследований, 1 этап
    elseif _vozrast == 45
      lshifr := iif(m1lis > 0, "70.3.199", "70.3.198")
//70.3.198 ЗС дисп-ии мужчин (45 лет), 1 этап
//70.3.199 ЗС дисп-ии мужчин (45 лет) без гематологических исследований, 1 этап
    elseif _vozrast == 51
      lshifr := iif(m1lis > 0, "70.3.105", "70.3.104")
//70.3.104 ЗС дисп-ии мужчин (51 года), 1 этап
//70.3.105 ЗС дисп-ии мужчин (51 года) без гематологических исследований, 1 этап
    elseif _vozrast == 57
      lshifr := iif(m1lis > 0, "70.3.109", "70.3.108")
//70.3.108 ЗС дисп-ии мужчин (57 лет), 1 этап
//70.3.109 ЗС дисп-ии мужчин (57 лет) без гематологических исследований, 1 этап
    elseif _vozrast == 60
      lshifr := iif(m1lis > 0, "70.3.113", "70.3.112")
//70.3.112 ЗС дисп-ии мужчин (60 лет), 1 этап
//70.3.113 ЗС дисп-ии мужчин (60 лет) без гематологических исследований, 1 этап
    elseif _vozrast == 63
      lshifr := iif(m1lis > 0, "70.3.115", "70.3.114")
//70.3.114 ЗС дисп-ии мужчин (63 лет), 1 этап
//70.3.115 ЗС дисп-ии мужчин (63 лет) без гематологических исследований, 1 этап
    elseif eq_any(_vozrast,66,72)
      lshifr := iif(m1lis > 0, "70.3.103", "70.3.102")
//70.3.102 ЗС дисп-ии мужчин (66,72 лет), 1 этап
//70.3.103 ЗС дисп-ии мужчин (66,72 лет) без гематологических исследований, 1 этап
    elseif _vozrast == 69
      lshifr := iif(m1lis > 0, "70.3.119", "70.3.118")
//70.3.118 ЗС дисп-ии мужчин (69 лет), 1 этап
//70.3.119 ЗС дисп-ии мужчин (69 лет) без гематологических исследований, 1 этап
    elseif eq_any(_vozrast,75,78,81,84)
      lshifr := iif(m1lis > 0, "70.3.165", "70.3.164")
//70.3.164 ЗС дисп-ии мужчин (75,78,81,84 лет), 1 этап
//70.3.165 ЗС дисп-ии мужчин (75,78,81,84 лет) без гематологических исследований, 1 этап
    else//if eq_any(_vozrast,87,90,93,96,99)
      lshifr := iif(m1lis > 0, "70.3.167", "70.3.166")
//70.3.166 ЗС дисп-ии мужчин (87,90,93,96,99 лет), 1 этап
//70.3.167 ЗС дисп-ии мужчин (87,90,93,96,99 лет) без гематологических исследований, 1 этап
    endif
  else // женщины
    if m1lis > 0 // без гематологических иссл-ий
      if eq_any(_vozrast,21,24,27)
        lshifr := "70.3.123"
//70.3.123 ЗС дисп-ии женщин (21,24,27 лет) без гематологических исследований, 1 этап
      elseif eq_any(_vozrast,30,33,36)
        lshifr := iif(m1g_cit == 2, "70.3.173", "70.3.125")
//70.3.125 ЗС дисп-ии женщин (30,33,36 лет) без гематологических исследований, 1 этап
//70.3.173 ЗС дисп-ии женщин (30,33,36 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif _vozrast == 39
        lshifr := iif(m1g_cit == 2, "70.3.175", "70.3.127")
//70.3.127 ЗС дисп-ии женщин (39 лет) без гематологических исследований, 1 этап
//70.3.175 ЗС дисп-ии женщин (39 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif _vozrast == 42
        lshifr := iif(m1g_cit == 2, "70.3.179", "70.3.131")
//70.3.131 ЗС дисп-ии женщин (42 лет) без гематологических исследований, 1 этап
//70.3.179 ЗС дисп-ии женщин (42 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif eq_any(_vozrast,45,48)
        lshifr := iif(m1g_cit == 2, "70.3.183", "70.3.135")
//70.3.135 ЗС дисп-ии женщин (45,48 лет) без гематологических исследований, 1 этап
//70.3.183 ЗС дисп-ии женщин (45,48 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif eq_any(_vozrast,51,57)
        lshifr := iif(m1g_cit == 2, "70.3.187", "70.3.149")
//70.3.149 ЗС дисп-ии женщин (51,57 лет) без гематологических исследований, 1 этап
//70.3.187 ЗС дисп-ии женщин (51,57 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif _vozrast == 54
        lshifr := iif(m1g_cit == 2, "70.3.191", "70.3.153")
//70.3.153 ЗС дисп-ии женщин (54 лет) без гематологических исследований, 1 этап
//70.3.191 ЗС дисп-ии женщин (54 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif _vozrast == 60
        lshifr := iif(m1g_cit == 2, "70.3.195", "70.3.157")
//70.3.157 ЗС дисп-ии женщин (60 лет) без гематологических исследований, 1 этап
//70.3.195 ЗС дисп-ии женщин (60 лет) без гематологических исследований, без цитологического исследования, 1 этап
      elseif _vozrast == 63
        lshifr := "70.3.161"
//70.3.161 ЗС дисп-ии женщин (63 лет) без гематологических исследований, 1 этап
      elseif _vozrast == 66
        lshifr := "70.3.202"
//70.3.202 ЗС дисп-ии женщин (66 лет) без гематологических исследований, 1 этап
      elseif _vozrast == 69
        lshifr := "70.3.143"
//70.3.143 ЗС дисп-ии женщин (69 лет) без гематологических исследований, 1 этап
      elseif _vozrast == 72
        lshifr := "70.3.147"
//70.3.147 ЗС дисп-ии женщин (72 лет) без гематологических исследований, 1 этап
      elseif eq_any(_vozrast,75,78,81,84)
        lshifr := "70.3.169"
//70.3.169 ЗС дисп-ии женщин (75,78,81,84 лет) без гематологических исследований, 1 этап
      else//if eq_any(_vozrast,87,90,93,96,99)
        lshifr := "70.3.171"
//70.3.171 ЗС дисп-ии женщин (87,90,93,96,99 лет) без гематологических исследований, 1 этап
      endif
    else // гематологические иссл-ия проводятся в ЛПУ
      if eq_any(_vozrast,21,24,27)
        lshifr := "70.3.122"
//70.3.122 ЗС дисп-ии женщин (21,24,27 лет), 1 этап
      elseif eq_any(_vozrast,30,33,36)
        lshifr := iif(m1g_cit == 2, "70.3.172", "70.3.124")
//70.3.124 ЗС дисп-ии женщин (30,33,36 лет), 1 этап
//70.3.172 ЗС дисп-ии женщин (30,33,36 лет) без цитологического исследования, 1 этап
      elseif _vozrast == 39
        lshifr := iif(m1g_cit == 2, "70.3.174", "70.3.126")
//70.3.126 ЗС дисп-ии женщин (39 лет), 1 этап
//70.3.174 ЗС дисп-ии женщин (39 лет) без цитологического исследования, 1 этап
      elseif _vozrast == 42
        lshifr := iif(m1g_cit == 2, "70.3.178", "70.3.130")
//70.3.130 ЗС дисп-ии женщин (42 лет), 1 этап
//70.3.178 ЗС дисп-ии женщин (42 лет) без цитологического исследования, 1 этап
      elseif eq_any(_vozrast,45,48)
        lshifr := iif(m1g_cit == 2, "70.3.182", "70.3.134")
//70.3.134 ЗС дисп-ии женщин (45,48 лет), 1 этап
//70.3.182 ЗС дисп-ии женщин (45,48 лет) без цитологического исследования, 1 этап
      elseif eq_any(_vozrast,51,57)
        lshifr := iif(m1g_cit == 2, "70.3.186", "70.3.148")
//70.3.148 ЗС дисп-ии женщин (51,57 лет), 1 этап
//70.3.186 ЗС дисп-ии женщин (51,57 лет) без цитологического исследования, 1 этап
      elseif _vozrast == 54
        lshifr := iif(m1g_cit == 2, "70.3.190", "70.3.152")
//70.3.152 ЗС дисп-ии женщин (54 лет), 1 этап
//70.3.190 ЗС дисп-ии женщин (54 лет) без цитологического исследования, 1 этап
      elseif _vozrast == 60
        lshifr := iif(m1g_cit == 2, "70.3.194", "70.3.156")
//70.3.156 ЗС дисп-ии женщин (60 лет), 1 этап
//70.3.194 ЗС дисп-ии женщин (60 лет) без цитологического исследования, 1 этап
      elseif _vozrast == 63
        lshifr := "70.3.160"
//70.3.160 ЗС дисп-ии женщин (63 лет), 1 этап
      elseif _vozrast == 66
        lshifr := "70.3.140"
//70.3.140 ЗС дисп-ии женщин (66 лет), 1 этап
      elseif _vozrast == 69
        lshifr := "70.3.142"
//70.3.142 ЗС дисп-ии женщин (69 лет), 1 этап
      elseif _vozrast == 72
        lshifr := "70.3.146"
//70.3.146 ЗС дисп-ии женщин (72 лет), 1 этап
      elseif eq_any(_vozrast,75,78,81,84)
        lshifr := "70.3.168"
//70.3.168 ЗС дисп-ии женщин (75,78,81,84 лет), 1 этап
      else//if eq_any(_vozrast,87,90,93,96,99)
        lshifr := "70.3.170"
//70.3.170 ЗС дисп-ии женщин (87,90,93,96,99 лет), 1 этап
      endif
    endif
  endif
elseif _etap == 3
  if _pol == "М"
    if _vozrast < 45
      lshifr := iif(m1lis > 0, "72.1.14", "72.1.4")
    else
      lshifr := iif(m1lis > 0, "72.1.15", "72.1.5")
    endif
  else
    if _vozrast < 39
      lshifr := iif(m1lis > 0, "72.1.11", "72.1.1")
    elseif _vozrast < 45
      lshifr := iif(m1lis > 0, "72.1.12", "72.1.2")
    else
      lshifr := iif(m1lis > 0, "72.1.13", "72.1.3")
    endif
  endif
elseif _etap == 4
  if _pol == "М"
    lshifr := "70.3.101"
//70.3.101 ЗС дисп-ии мужчин (49,53,55,59,61,65,67,71,73), 1 этап (иссл.1 раз в 2 года)
  else
    if eq_any(_vozrast,49,53,55,59,61,65,67,71,73)
      lshifr := "70.3.138"
//70.3.138 ЗС дисп-ии женщин (49,53,55,59,61,65,67,71,73), 1 этап (иссл.1 раз в 2 года)
    else
      lshifr := "70.3.139"
//70.3.139 ЗС дисп-ии женщин (50,52,56,58,62,64,68,70), 1 этап (иссл.1 раз в 2 года)
    endif
  endif
endif
return lshifr

***** 06.05.15 вернуть "правильный" профиль для диспансеризации/профилактики
Function ret_profil_dispans(lprofil,lprvs)
if lprofil == 34 // если профиль по "клинической лабораторной диагностике"
  if ret_old_prvs(lprvs) == 2013 // и спец-ть "Лабораторное дело"
    lprofil := 37 // сменим на профиль по "лабораторному делу"
  elseif ret_old_prvs(lprvs) == 2011 // или "Лабораторная диагностика"
    lprofil := 38 // сменим на профиль по "лабораторной диагностике"
  endif
endif
return lprofil

***** 01.02.17
Function fget_spec_DVN(k,r,c,a_spec)
Static as := {;
  {8,2},;
  {255,1},;
  {112,1},;
  {58,1},;
  {65,1},;
  {113,1},;
  {133,1},;
  {257,1},;
  {114,1},;
  {258,1},;
  {115,1},;
  {66,1},;
  {116,1},;
  {10,1},;
  {32,1},;
  {260,1},;
  {118,1},;
  {139,2},;
  {59,1},;
  {67,1},;
  {120,1},;
  {134,1},;
  {14,2},;
  {140,1},;
  {261,1},;
  {123,1},;
  {17,1},;
  {19,2},;
  {20,2},;
  {23,1},;
  {262,1},;
  {125,1},;
  {138,1},;
  {263,1},;
  {126,1},;
  {141,1},;
  {75,1},;
  {28,1},;
  {145,2},;
  {29,1},;
  {30,2},;
  {31,1},;
  {97,1};
}
Local tmp_select := select(), s, blk, t_arr[BR_LEN], n_file := cur_dir+"tmpspecdvn"
if !hb_fileExists(n_file+sdbf)
  dbcreate(n_file,{{"name","C",30,0},;
                   {"kod","C",4,0},;
                   {"kod_up","C",4,0},;
                   {"name1","C",50,0},;
                   {"isn","N",1,0},;
                   {"is","L",1,0}})
  use (n_file) new alias SDVN
  use (cur_dir+"tmp_v015") index (cur_dir+"tmpkV015") new alias tmp_ga
  go top
  do while !eof()
    if (i := ascan(as,{|x| lstr(x[1]) == rtrim(tmp_ga->kod)})) > 0
      select SDVN
      append blank
      sdvn->name := afteratnum(".",tmp_ga->name,1)
      sdvn->kod := tmp_ga->kod
      sdvn->isn := as[i,2]
      s := ""
      select TMP_GA
      rec := recno()
      do while !empty(tmp_ga->kod_up)
        find (tmp_ga->kod_up)
        if found()
          s += alltrim(afteratnum(".",tmp_ga->name,1))+"/"
        else
          exit
        endif
      enddo
      goto (rec)
      sdvn->name1 := s
    endif
    skip
  enddo
  sdvn->(dbCloseArea())
  tmp_ga->(dbCloseArea())
endif
use (n_file) new alias tmp_ga
do while !eof()
  tmp_ga->is := (ascan(a_spec,int(val(tmp_ga->kod))) > 0)
  skip
enddo
if metap == 3
  index on upper(name)+kod to (n_file)
else
  index on upper(name)+kod to (n_file) for isn == 1
endif
if r <= maxrow()/2
  t_arr[BR_TOP] := r+1
  t_arr[BR_BOTTOM] := maxrow()-2
else
  t_arr[BR_BOTTOM] := r-1
  t_arr[BR_TOP] := 2
endif
blk := {|| iif(tmp_ga->is, {1,2}, {3,4}) }
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.f.}
t_arr[BR_COLUMN] := {;
  { " ", {|| iif(tmp_ga->is,""," ") }, blk },;
  { "Код", {|| left(tmp_ga->kod,3) },blk },;
  { center("Медицинская специальность",26), {|| padr(tmp_ga->name,26) },blk },;
  { center("подчинение",45), {|| left(tmp_ga->name1,45) },blk };
}
t_arr[BR_EDIT] := {|nk,ob| f1get_spec_DVN(nk,ob,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Ins>^ - отметить специальность/снять отметку со специальности") }
go top
edit_browse(t_arr)
s := ""
asize(a_spec,0)
go top
do while !eof()
  if iif(metap == 3, .t., tmp_ga->isn==1) .and. tmp_ga->is
    s += alltrim(tmp_ga->kod)+","
    aadd(a_spec,int(val(tmp_ga->kod)))
  endif
  skip
enddo
if empty(s)
  s := "---"
else
  s := left(s,len(s)-1)
endif
tmp_ga->(dbCloseArea())
select (tmp_select)
return {1,s}

***** 11.11.17
Function f1get_spec_DVN(nKey,oBrow,regim)
if regim == "edit" .and. nkey == K_INS
  tmp_ga->is := !tmp_ga->is
  keyboard chr(K_TAB)
endif
return 0

***** 20.01.19 гемодиализ (1) и перитонеальный диализ (2)
Function oms_sluch_dializ(par,Loc_kod,kod_kartotek)
// Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
// kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
Static SKOD_DIAG := 'N18.5', st_N_DATA, st_K_DATA, st_vrach := 0
Local top2 := {2,11}[par]
Local bg := {|o,k| get_MKB10(o,k,.t.) },;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {},;
      p_uch_doc := "@!", pic_diag := "@K@!",;
      i, d, colget_menu := "R/W", colgetImenu := "R/BG",;
      pos_read := 0, k_read := 0, count_edit := 0, arr_usl, fl, ss,;
      tmp_help := chm_help_code, fl_write_sluch := .f.
Static kod_ksg := "ds18.002", arr_lek := {;
  {"A25.28.001.001","препараты железа"},;
  {"A25.28.001.002","антианемические препараты (стимуляторы эритропоэза)"},;
  {"A25.28.001.003","антипаратиреоидные препараты"},;
  {"A25.28.001.004","препараты витамина D и его аналогов"},;
  {"A25.28.001.005","препараты аминокислот, включая комбинации с полипептидами"},;
  {"A25.28.001.006","препараты для лечения гиперкальциемии, гиперкалиемии и гиперфосфатемии"}}
//
Default st_N_DATA TO bom(sys_date), st_K_DATA TO eom(sys_date)
Private mkol_proc := 0, mkol_proc2 := 0,;
  MFIO        := space(50)         ,; // Ф.И.О. больного
  mfam := space(40), mim := space(40), mot := space(40),;
  mpol        := "М"            ,;
  mdate_r     := boy(addmonth(sys_date,-12*30)) ,;
  MVZROS_REB, M1VZROS_REB := 0,;
  MADRES      := space(50)         ,; // адрес больного
  m1MEST_INOG := 0, newMEST_INOG := 0,;
  MVID_UD                          ,; // вид удостоверения
  M1VID_UD    := 14                ,; // 1-18
  mser_ud := space(10), mnom_ud := space(20), ;
  mspolis := space(10), mnpolis := space(20), msmo := '34007',;
  mnamesmo, m1namesmo,;
  m1company := 0, mcompany, mm_company, ;
  m1KOMU := 0, MKOMU, M1STR_CRB := 0, ;
  mvidpolis, m1vidpolis := 1,;
  msnils := space(11),;
  mokatog := padr(alltrim(okato_umolch),11,"0"),;
  m1adres_reg := 1, madres_reg,;
  rec_inogSMO := 0, ;
  mkol[6], musl_lek[6],;
  mokato, m1okato := "", mismo, m1ismo := "", mnameismo := space(100)
afill(mkol,0)
afill(musl_lek,0)
//
Private mkod := Loc_kod, mtip_h, is_talon := .f.,;
        mkod_k := kod_kartotek, fl_kartotek := (kod_kartotek == 0),;
  M1LPU := glob_uch[1], MLPU,;
  M1OTD := glob_otd[1], MOTD,;
  M1FIO_KART := 1, MFIO_KART,;
  MUCH_DOC    := space(10)         ,; // вид и номер учетного документа
  MKOD_DIAG   := SKOD_DIAG         ,; // шифр 1-ой осн.болезни
  MKOD_DIAG2  := space(5)          ,; // шифр 2-ой осн.болезни
  MKOD_DIAG3  := space(5)          ,; // шифр 3-ой осн.болезни
  MKOD_DIAG4  := space(5)          ,; // шифр 4-ой осн.болезни
  MSOPUT_B1   := space(5)          ,; // шифр 1-ой сопутствующей болезни
  MSOPUT_B2   := space(5)          ,; // шифр 2-ой сопутствующей болезни
  MSOPUT_B3   := space(5)          ,; // шифр 3-ой сопутствующей болезни
  MSOPUT_B4   := space(5)          ,; // шифр 4-ой сопутствующей болезни
  MDIAG_PLUS  := space(8)          ,; // дополнения к диагнозам
  mrslt, m1rslt := 0         ,; // результат
  mishod, m1ishod := 0      ,; // исход
  MN_DATA     := st_N_DATA         ,; // дата начала лечения
  MK_DATA     := st_K_DATA         ,; // дата окончания лечения
  MVRACH      := space(10)         ,; // фамилия и инициалы лечащего врача
  M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0,; // код, таб.№ и спец-ть лечащего врача
  m1novor := 0, mnovor, mcount_reb := 0, ldnej := 0,;
  mDATE_R2 := ctod(""), mpol2 := " ",;
  m1USL_OK, m1PROFIL := 56, m1PROFIL_K := 41 // НЕФРОЛОГИЯ
//
Private mm_rslt := {}, mm_ishod := {}
if par == 1 // гемодиализ (1)
  m1USL_OK := 2
  aeval(glob_V009,{|x| iif(x[5]==m1usl_ok, aadd(mm_rslt,x), nil) })
  m1rslt := 201 ; m1ishod := 203
else // перитонеальный диализ (2)
  m1USL_OK := 3
  aeval(glob_V009,{|x| iif(x[5]==m1usl_ok.and.x[2]<316, aadd(mm_rslt,x), nil) })
  m1rslt := 314 ; m1ishod := 304
endif
aeval(glob_V012,{|x| iif(x[5]==m1usl_ok, aadd(mm_ishod,x), nil) })
//
R_Use(dir_server+"kartote_",,"KART_")
goto (kod_kartotek)
R_Use(dir_server+"kartotek",,"KART")
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
mokatog     := kart_->okatog       // код места жительства по ОКАТО
m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
//
arr := retFamImOt(1,.f.)
mfam := padr(arr[1],40)
mim  := padr(arr[2],40)
mot  := padr(arr[3],40)
if alltrim(msmo) == '34'
  mnameismo := ret_inogSMO_name(1,@rec_inogSMO)
elseif left(msmo,2) == '34'
  // Волгоградская область
elseif !empty(msmo)
  m1ismo := msmo ; msmo := '34'
endif
if eq_any(is_uchastok,1,3)
  MUCH_DOC := padr(amb_kartaN(),10)
elseif mem_kodkrt == 2
  MUCH_DOC := padr(lstr(mkod_k),10)
endif
close databases
chm_help_code := 3002
//
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
set relation to recno() into HUMAN_
// проверка исхода = СМЕРТЬ
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
mvzros_reb:= inieditspr(A__MENUVERT, menu_vzros, m1vzros_reb)
mrslt     := inieditspr(A__MENUVERT, mm_rslt, m1rslt)
mishod    := inieditspr(A__MENUVERT, mm_ishod, m1ishod)
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
str_1 := iif(par==1,"гемодиализа","перитонеального диализа")+" за месяц"
if Loc_kod == 0
  str_1 := "Добавление "+str_1
  mtip_h := yes_vypisan
else
  str_1 := "Редактирование "+str_1
endif
setcolor(color8)
myclear(top2)
@ top2-1,0 say padc(str_1,80) color "B/BG*"
Private gl_area := {1,0,maxrow()-1,maxcol(),0}
status_key("^<Esc>^ - выход  ^<PgDn>^ - запись листов учёта")
setcolor(cDataCGet)
make_diagP(1)  // сделать "шестизначные" диагнозы
Private row_diag_screen := 9
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
  ++j; @ j,1 say "ФИО" get mfio_kart ;
       reader {|x| menu_reader(x,{{|k,r,c| get_fio_kart(k,r,c)}},A__FUNCTION,,,.f.)} ;
       valid {|g,o| update_get("mkomu"),update_get("mcompany") }
  //
  ++j; @ j,1 say "Принадлежность счёта" get mkomu ;
             reader {|x|menu_reader(x,mm_komu,A__MENUVERT,,,.f.)} ;
             valid {|g,o| f_valid_komu(g,o) } ;
             color colget_menu
       @ row(),col()+1 say "==>" get mcompany ;
           reader {|x|menu_reader(x,mm_company,A__MENUVERT,,,.f.)} ;
           when diag_screen(2) .and. m1komu < 5 ;
           valid {|g| func_valid_ismo(g,m1komu,38) }
  //
  ++j; @ j,1 say "Полис ОМС: серия" get mspolis when m1komu == 0
       @ row(),col()+3 say "номер"  get mnpolis when m1komu == 0
       @ row(),col()+3 say "вид"    get mvidpolis ;
                    reader {|x|menu_reader(x,mm_vid_polis,A__MENUVERT,,,.f.)} ;
                    when diag_screen(2) .and. m1komu == 0 ;
                    valid func_valid_polis(m1vidpolis,mspolis,mnpolis)
  //
  ++j; @ j,1 say "Основной диагноз" get mkod_diag picture pic_diag when .f. //reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mn_data,iif(m1novor==0,mpol,mpol2))
       @ row(),col() say ", соп.диагноз" get mkod_diag2 picture pic_diag reader {|o|MyGetReader(o,bg)} when when_diag() valid val1_10diag(.t.,.t.,.t.,mn_data,iif(m1novor==0,mpol,mpol2))
  //
  ++j; @ j,1 say "№ амб.карты" get much_doc picture "@!" ;
             when !(is_uchastok == 1 .and. is_task(X_REGIST)) ;
                   .or. mem_edit_ist==2
             //   !(    У23/12356     и есть "Регистратура")
       @ row(),col()+1 say "Врач" get MTAB_NOM pict "99999" ;
             valid {|g| v_kart_vrach(g,.t.) } when diag_screen(2)
       @ row(),col()+1 get mvrach when .f. color color14
  //
  ++j; @ j,1 say "Диализ проводился с" get mn_data valid {|g| f_d_dializ()}
       @ row(),col()+1 say            "по" get mk_data valid {|g| f_d_dializ()}
  //
  if par == 1
    ++j; @ j,1 say "Количество процедур лекарственной терапии:"
   for i := 1 to 6
    ++j; @ j,2 say arr_lek[i,1] get mkol[i] pict "99"
         @ j,col()+1 say arr_lek[i,2]
   next
    ++j; @ j,1 say "Количество НИЗКОпоточных процедур" get mkol_proc pict "99"
    ++j; @ j,1 say "Количество ВЫСОКОпоточных процедур" get mkol_proc2 pict "99"
  endif
  ++j; @ j,1 say "Результат обращения" get mrslt ;
           reader {|x|menu_reader(x,mm_rslt,A__MENUVERT,,,.f.)} ;
           valid {|g,o| f_valid_rslt(g,o) }
  //
  ++j; @ j,1 say "Исход заболевания" get mishod ;
           reader {|x|menu_reader(x,mm_ishod,A__MENUVERT,,,.f.)}
  if !empty(a_smert)
    n_message(a_smert,,"GR+/R","W+/R",,,"G+/R")
  endif
  if pos_read > 0 .and. lower(GetList[pos_read]:name) == "mishod"
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
    if empty(mn_data)
      func_error(4,"Не введена дата начала процедур.")
      loop
    endif
    if empty(mk_data)
      func_error(4,"Не введена дата окончания процедур.")
      loop
    elseif year(mk_data) < 2018
      func_error(4,"Данный режим работает только с 2018 года.")
      loop
    endif
    if mk_data < mn_data
      func_error(4,"Дата окончания меньше даты начала процедур.")
      loop
    endif
    if !(left(dtos(mn_data),6) == left(dtos(mk_data),6))
      func_error(4,"Даты начала и окончания процедур не в одном отчётном месяце.")
      loop
    endif
    ldnej := mk_data - mn_data + 1
    vlek := vdial := 0
    if par == 1
      if empty(vdial := mkol_proc + mkol_proc2)
        func_error(4,"Количество процедур гемодиализа равно нулю")
        loop
      elseif mkol_proc + mkol_proc2 > ldnej
        func_error(4,"Количество процедур гемодиализа больше длительности лечения")
        loop
      endif
      vlek := 0
      for i := 1 to 6
        vlek += mkol[i]
      next
      if vlek > 0
        if year(mk_data) == 2018
          func_error(4,"Работа с лекарственными препаратами разрешена только с 2019 года.")
          loop
        elseif !(alltrim(mkod_diag) == "N18.5")
          func_error(4,"Для КСГ лекарственной терапии основной диагноз должен быть N18.5")
          loop
        endif
      endif
    endif
    if empty(CHARREPL("0",much_doc,space(10)))
      func_error(4,'Не заполнен номер амбулаторной карты')
      loop
    endif
    if m1vrach == 0
      func_error(4,'Не заполнен табельный номер лечащего врача')
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
    if empty(mkod_diag)
      func_error(4,"Не введен шифр основного заболевания.")
      loop
    endif
    err_date_diap(mn_data,"Дата начала процедур")
    err_date_diap(mk_data,"Дата окончания процедур")
    arr_usl := {}
    if par == 1
      if vlek > 0
        aadd(arr_usl,{"55.1.1",0,0,iif(vlek > vdial, vdial, vlek)})
      endif
      if mkol_proc > 0
        aadd(arr_usl,{"60.3.9",0,0,mkol_proc})
      endif
      if mkol_proc2 > 0
        aadd(arr_usl,{"60.3.10",0,0,mkol_proc2})
      endif
    else
      aadd(arr_usl,{"60.3.1",0,0,ldnej})
    endif
    fv_date_r(mn_data) // переопределение M1VZROS_REB
    Use_base("lusl")
    Use_base("luslc")
    Use_base("uslugi")
    R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                                dir_server+"uslugi1s"},"USL1")
    glob_podr := "" ; glob_otd_dep := 0 ; fl := .t.
    for i := 1 to len(arr_usl)
      arr_usl[i,2] := foundOurUsluga(arr_usl[i,1],mk_data,m1PROFIL,M1VZROS_REB,@arr_usl[i,3])
      if empty(arr_usl[i,2])
        fl := func_error(4,'Цена на услугу '+arr_usl[i,1]+' отсутствует в справочнике ТФОМС')
      endif
    next
    close databases
    if !fl
      loop
    endif
    k := f_alert({padc("Сейчас будет записан лист учёта. Выберите действие",60,".")},;
                 {" Выход без записи "," Запись "," Возврат в редактирование "},;
                 iif(lastkey()==K_ESC,1,2),"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )
    if k == 3
      loop
    elseif k == 1
      exit
    endif
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
    st_N_DATA := MN_DATA
    st_K_DATA := MK_DATA
    st_VRACH := m1vrach
    SKOD_DIAG := substr(MKOD_DIAG,1,5)
    Private mu_kod, mu_cena, fl_nameismo
    Use_base("lusl")
    Use_base("luslc")
    use_base("luslf")
    Use_base("mo_su")
    Use_base("uslugi")
    R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                                dir_server+"uslugi1s"},"USL1")
    G_Use(dir_server+"mo_hismo",,"SN")
    index on str(kod,7) to (cur_dir+"tmp_ismo")
    Use_base("mo_hu")
    use_base("human_u")
    Use_base("human")
    Add1Rec(7)
    mkod := recno()
    replace human->kod with mkod
    select HUMAN_
    do while human_->(lastrec()) < mkod
      APPEND BLANK
    enddo
    goto (mkod)
    G_RLock(forever)
    select HUMAN_2
    do while human_2->(lastrec()) < mkod
      APPEND BLANK
    enddo
    goto (mkod)
    G_RLock(forever)
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
    human->UCH_DOC    := MUCH_DOC // вид и номер учетного документа
    human->N_DATA     := MN_DATA // дата начала лечения
    human->K_DATA     := MK_DATA // дата окончания лечения
    human->CENA := human->CENA_1 := 0 // стоимость лечения
    human_->DISPANS   := replicate("0",16)
    human_->POVOD     := 1
    //human_->TRAVMA    := m1travma
    human_->VPOLIS    := m1vidpolis
    human_->SPOLIS    := ltrim(mspolis)
    human_->NPOLIS    := ltrim(mnpolis)
    human_->OKATO     := "" // это поле вернётся из ТФОМС в случае иногороднего
    human_->NOVOR     := iif(m1novor==0, 0       , mcount_reb)
    human_->DATE_R2   := iif(m1novor==0, ctod(""), mDATE_R2  )
    human_->POL2      := iif(m1novor==0, ""      , mpol2     )
    human_->USL_OK    := m1USL_OK //
    human_->PROFIL    := m1PROFIL // 56
    human_->FORMA14   := "0000"
    human_->RSLT_NEW  := m1rslt
    human_->ISHOD_NEW := m1ishod
    human_->VRACH     := m1vrach
    human_->PRVS      := m1prvs
    human_->OPLATA    := 0 // уберём "2", если отредактировали запись из реестра СП и ТК
    human_->ST_VERIFY := 0 // снова ещё не проверен
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
    put_0_human_2()
    human_2->PROFIL_K := m1PROFIL_K // 41
    fl_nameismo := .f.
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
      select SN
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
    ss := 0
    // записываем услуги
    for i := 1 to len(arr_usl)
      select HU
      Add1Rec(7)
      mrec_hu := hu->(recno())
      replace hu->kod     with mkod,;
              hu->kod_vr  with m1vrach,;
              hu->kod_as  with 0,;
              hu->u_koef  with 1,;
              hu->u_kod   with arr_usl[i,2],;
              hu->u_cena  with arr_usl[i,3],;
              hu->is_edit with 0,;
              hu->date_u  with dtoc4(MN_DATA),;
              hu->otd     with m1otd,;
              hu->kol     with arr_usl[i,4],;
              hu->stoim   with arr_usl[i,3]*arr_usl[i,4],;
              hu->kol_1   with arr_usl[i,4],;
              hu->stoim_1 with arr_usl[i,3]*arr_usl[i,4],;
              hu->KOL_RCP with 0
      ss += arr_usl[i,3]*arr_usl[i,4]
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
    next i
    if par == 1 .and. vlek > 0
      for i := 1 to len(arr_lek)
        if mkol[i] > 0
          mu_kod := append_shifr_mo_su(arr_lek[i,1])
          select MOHU
          Add1Rec(7)
          mohu->kod     := mkod
          mohu->kod_vr  := m1vrach
          mohu->kod_as  := 0
          mohu->u_kod   := mu_kod
          mohu->u_cena  := 0
          mohu->date_u  := dtoc4(MN_DATA)
          mohu->otd     := m1otd
          mohu->kol_1   := mkol[i]
          mohu->stoim_1 := 0
          mohu->ID_U    := mo_guid(4,mohu->(recno()))
          mohu->PROFIL  := m1PROFIL
          mohu->PRVS    := m1PRVS
          mohu->kod_diag := mkod_diag
        endif
      next
    endif
    human->CENA := human->CENA_1 := ss // стоимость лечения
    write_work_oper(glob_task,OPER_LIST,iif(Loc_kod==0,1,2),1,count_edit)
    fl_write_sluch := .t.
    close databases
    stat_msg("Запись завершена!",.f.)
    if par == 1 .and. vlek > 0
      f_1pac_definition_KSG(mkod)
    endif
  endif
  exit
enddo
close databases
diag_screen(2)
setcolor(tmp_color)
restscreen(buf)
chm_help_code := tmp_help
if fl_write_sluch // если записали - запускаем проверку
  verify_OMS_sluch(mkod)
endif
return nil

***** 04.07.19 добавить шифр манипуляции в свой справочник MO_SU
Function append_shifr_mo_su(lshifr,fl_commit)
Local lu_kod := 0, arr := {}
DEFAULT fl_commit TO .t.
select MOSU
set order to 3 // по шифру ФФОМС
find (padr(lshifr,20))
do while mosu->shifr1 == padr(lshifr,20) .and. !eof()
  aadd(arr,{iif(left(mosu->shifr,1)=="*",1,0),mosu->kod})
  skip
enddo
if !empty(arr)
  asort(arr,,,{|x,y| x[1] < y[1] }) // все старые стомат.услуги со звёздочкой в конец массива
  lu_kod := arr[1,2]
else
  select LUSLF
  find (padr(lshifr,20))
  select MOSU
  set order to 1
  FIND (STR(-1,6))
  if found()
    G_RLock(forever)
  else
    AddRec(6)
  endif
  lu_kod := mosu->kod := recno()
  mosu->name := luslf->name
  mosu->shifr1 := lshifr
  mosu->PROFIL := m1PROFIL
  if fl_commit
    UnLock
    Commit
  endif
endif
return lu_kod

***** 03.02.15
Static Function f_d_dializ()
if !(left(dtos(mn_data),6) == left(dtos(mk_data),6))
  func_error(4,"Даты начала и окончания процедур не в одном отчётном месяце.")
endif
return .t.

*

***** 27.11.14
Function create_FR_file_for_spravkaOMS()
dbCloseAll()
delFRfiles()
dbcreate(fr_titl,{{"name","C",255,0},;
                  {"adres","C",255,0},;
                  {"data","D",8,0},;
                  {"data1","D",8,0},;
                  {"data2","D",8,0},;
                  {"fio","C",60,0}})
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_FULL_NAME]
frt->adres := glob_mo[_MO_ADRES]
dbcreate(fr_data,{{"name","C",255,0},;
                  {"name1","C",55,0},;
                  {"shifr","C",10,0},;
                  {"kol","N",4,0},;
                  {"cena","N",11,2},;
                  {"summa","N",11,2}})
use (fr_data) new alias FRD
index on shifr to (cur_dir+"tmp1")
return NIL

*

***** 12.12.14 печать справки ОМС по готовому листу учёта
Function print_spravka_OMS(mkod)
// mkod - код больного по БД human
Local r1, c1, r2, c2, mdate, buf := save_maxrow(), msumma := 0, lshifr
get_row_col_max(18,4,@r1,@c1,@r2,@c2)
if (mdate := input_value(r1,c1,r2,c2,color1,;
      "Введите дату выдачи справки о стоимости мед.помощи по ОМС",;
      sys_date)) == NIL
  return NIL
endif
mywait()
create_FR_file_for_spravkaOMS()
Use_base("lusl")
Use_base("luslf")
R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                            dir_server+"uslugi1s"},"USL1")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
R_Use(dir_server+"human_",,"HUMAN_")
goto (mkod)
R_Use(dir_server+"human",,"HUMAN")
goto (mkod)
if mdate < human->k_data
  rest_box(buf)
  close databases
  return func_error(4,"Дата выдачи справки меньше даты окончания лечения!")
endif
frt->data := mdate
frt->data1 := human->n_data
frt->data2 := human->k_data
frt->fio := human->fio
Select HU
find (str(mkod,7))
do while hu->kod == mkod .and. !eof()
  if !emptyany(hu->kol_1,hu->stoim_1)
    usl->(dbGoto(hu->u_kod))
    lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    if is_usluga_TFOMS(usl->shifr,lshifr,human->k_data)
      lshifr := iif(empty(lshifr), usl->shifr, lshifr)
      select LUSL
      find (padr(lshifr,10))
      Select FRD
      find (padr(lshifr,10))
      if !found()
        append blank
        frd->shifr := lshifr
        frd->name := lusl->name  // наименование услуги из справочника ТФОМС
        frd->cena := hu->stoim_1 / hu->kol_1
      endif
      frd->kol += hu->kol_1
      frd->summa += hu->stoim_1
      msumma += hu->stoim_1
    endif
  endif
  select HU
  Skip
enddo
Select FRD
go top
do while !eof()
  if frd->kol > 1
    frd->name1 := " (в количестве "+lstr(frd->kol)+")"
  endif
  Skip
enddo
index on str(summa,11,2) to (fr_data) descending
G_Use(dir_server+"mo_sprav",,"SPR_OMS")
Locate for kod_h == mkod
if found()
  G_RLock(forever)
else
  append blank
  spr_oms->KOD_H  := mkod
  spr_oms->KOD_K  := 0
endif
spr_oms->FIO    := human->FIO
spr_oms->DATE_R := human->DATE_R
spr_oms->DATA   := mdate
spr_oms->N_DATA := human->n_data
spr_oms->K_DATA := human->k_data
if human_->USL_OK == 1
  spr_oms->TIP := 2  // стационар
elseif human_->USL_OK == 2
  spr_oms->TIP := 3  // дневной стационар
else
  spr_oms->TIP := 1  // амбулаторно
endif
spr_oms->STOIM  := human->CENA_1
close databases
rest_box(buf)
call_fr("mo_spravkaOMS")
return NIL

*

***** 27.11.14 Ввод и распечатка справки о стоимости оказанной медицинской помощи в сфере ОМС")
Function f_spravka_OMS()
Local i, j, k, k1, buf := savescreen(), rec_spr_oms := 0
k1 := polikl1_kart()
close databases // если вдруг вышли по <Esc>
//
Private mfio := space(50), mdate_r := ctod(""),;
        mdate := sys_date, mn_data := sys_date, mk_data := sys_date,;
        mstoim := 0, m1usl := 1, musl := " ", parr_usl := {},;
        p_box_buf, gl_area := {1,0,23,79,0}
if k1 > 0
  R_Use(dir_server+"kartotek",,"KART")
  goto (glob_kartotek)
  mfio    := kart->fio
  mdate_r := kart->date_r
  close databases
endif
Private r1 := maxrow()-18
do while .t.
  setcolor(cDataCGet)
  ClrLines(r1,maxrow()-1)
  @ r1-1,0 say padc("Справка ОМС",80) color "B/B*"
  if p_box_buf != NIL
    rest_box(p_box_buf)
  endif
  i := r1+1
  if k1 == 0
        @ i,1 say "Пациент" get mfio pict "@!"
        @ row(),col()+2 say "Дата р." get mdate_r
  else
        @ i,1 say "Пациент" color "G+/B" get mfio when .f.
        @ row(),col()+2 say "Дата р." color "G+/B" get mdate_r when .f.
  endif
  ++i ; @ i,1 say "Сроки лечения: с" get mn_data
        @ row(),col()+1 say "по" get mk_data
        @ row(),col()+7 say "Дата выдачи справки" get mdate ;
                        valid {|| __keyboard(CHR(K_ENTER)), .t. }
  ++i ; @ i,1 say "Оказанные услуги:" color color8 get musl ;
              reader {|x|menu_reader(x,{{|k,r,c| fu_spravka_OMS(r,c)}},A__FUNCTION,,,.f.)}
  status_key("^<Esc>^ - выход для печати")
  myread()
  do while (k := f_alert({padc("Выберите действие",60,".")},;
             {" Выход "," Печать справки "," Возврат в редактирование "},;
             2,"W+/N","N+/N",maxrow()-2,,"W+/N,N/BG" )) == 0
  enddo
  if k == 1
    exit
  elseif k == 2
    if empty(mfio)
      func_error(4,"Не введены Ф.И.О.")
      loop
    endif
    if empty(mdate)
      func_error(4,"Не введена дата выдачи справки.")
      loop
    endif
    if empty(mn_data)
      func_error(4,"Не введена дата начала лечения.")
      loop
    endif
    if empty(mk_data)
      func_error(4,"Не введена дата окончания лечения.")
      loop
    endif
    if mdate < mk_data
      func_error(4,"Дата выдачи справки меньше даты окончания лечения.")
      loop
    endif
    if mk_data < mn_data
      func_error(4,"Дата окончания лечения меньше даты начала лечения.")
      loop
    endif
    mstoim := 0 ; mtip := 2 // стационар
    for i := 1 to len(parr_usl)
      mstoim += parr_usl[i,2] * parr_usl[i,3]
      if left(parr_usl[i,5],3) == "55."
        mtip := 3  // дневной стационар
        exit
      elseif left(parr_usl[i,5],2) == "2." .or. eq_any(left(parr_usl[i,5],3),"57.","60.","70.","72.")
        mtip := 1  // амбулаторно
        exit
      endif
    next
    if empty(mstoim)
      func_error(4,"Не введены услуги.")
      loop
    endif
    create_FR_file_for_spravkaOMS()
    Use_base("lusl")
    frt->data := mdate
    frt->data1 := mn_data
    frt->data2 := mk_data
    frt->fio := mfio
    for i := 1 to len(parr_usl)
      if !emptyany(parr_usl[i,2],parr_usl[i,3])
        select LUSL
        find (padr(parr_usl[i,5],10))
        Select FRD
        find (padr(parr_usl[i,5],10))
        if !found()
          append blank
          frd->shifr := parr_usl[i,5]
          frd->name := lusl->name  // наименование услуги из справочника ТФОМС
          frd->cena := parr_usl[i,3]
        endif
        frd->kol += parr_usl[i,2]
        frd->summa += parr_usl[i,2] * parr_usl[i,3]
      endif
    next
    Select FRD
    go top
    do while !eof()
      if frd->kol > 1
        frd->name1 := " (в количестве "+lstr(frd->kol)+")"
      endif
      Skip
    enddo
    index on str(summa,11,2) to (fr_data) descending
    G_Use(dir_server+"mo_sprav",,"SPR_OMS")
    if rec_spr_oms == 0
      append blank
      spr_oms->KOD_H  := 0
      spr_oms->KOD_K  := iif(k1 > 0, glob_kartotek, 0)
      rec_spr_oms := recno()
    else
      goto (rec_spr_oms)
      G_RLock(forever)
    endif
    spr_oms->FIO    := mFIO
    spr_oms->DATE_R := mDATE_R
    spr_oms->DATA   := mdate
    spr_oms->N_DATA := mn_data
    spr_oms->K_DATA := mk_data
    spr_oms->TIP    := mtip
    spr_oms->STOIM  := mstoim
    close databases
    call_fr("mo_spravkaOMS")
  endif
enddo
restscreen(buf)
return NIL

***** 27.11.14
Function fu_spravka_OMS(r,c)
Local arr_title := {{1," Шифр усл."},;
                    {2,"Кол"},;
                    {3,"   Цена   "},;
                    {4," Наименование услуги"}},;
      mpic := {,{3,0},{10,2}}, tmp_color := setcolor("W+/B,W+/RB"), i
local blk := {|b,ar,nDim,nElem,nKey| fu2spravka_OMS(b, ar, nDim, nElem, nKey)}
if emptyany(mdate_r,mn_data,mk_data)
  func_error(4,"Проверьте правильность ввода даты рождения и сроков лечения")
else
  @ r,c say space(10) color "B/B"
  Private mvzros_reb := iif(count_years(mdate_r,mn_data) < 18, 1, 0)
  if len(parr_usl) == 0
    aadd(parr_usl, {space(10),1,0,space(40),""})
  endif
  Use_base("lusl")
  Use_base("luslc")
  R_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
  Arrn_Browse(r+1,2,maxrow()-2,77,parr_usl,arr_title,1,,,,,.t.,,mpic,blk,{.t.,.t.,.t.})
  p_box_buf := save_box(r+1,0,maxrow()-1,79)
  close databases
endif
setcolor(tmp_color)
return {1," "}

***** 27.11.14
Function fu2spravka_OMS(b, ar, nDim, nElem, nKey)
LOCAL nRow := ROW(), nCol := COL(), i, j, flag := .f., fl, lshifr, lshifr1
DO CASE
  CASE nKey == K_DOWN .or. nKey == K_INS
    b:panHome()
  CASE nKey == K_LEFT
    b:left()
  CASE nKey == K_RIGHT
    if nDim == 1
      b:right()
    endif
  OTHERWISE
    if (nKey == K_ENTER .or. between(nKey,48,57)) .and. nDim < 3
      if nDim == 1 .and. empty(parr[nElem,nDim])
        if between(nKey,48,57)
          keyboard chr(nKey)
        endif
        Private mshifr := space(10)
        @ nRow, nCol GET mshifr picture "@!" valid valid_shifr()
        myread()
        if lastkey() != K_ESC
          lshifr := mname := ""
          select USL
          find (mshifr)
          if found()
            mname := usl->name
            lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data)
            if is_usluga_TFOMS(usl->shifr,lshifr1,mk_data)
              lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
            else
              func_error(4,'Это не услуга ТФОМС: '+lshifr1)
            endif
          else
            select LUSL
            find (mshifr)
            if found()
              lshifr := lusl->shifr
              mname := lusl->name
            else
              func_error(4,'Это не услуга ТФОМС: '+mshifr)
            endif
          endif
          if !empty(lshifr)
            fl_del := fl_uslc := .f.
            glob_podr := "" ; glob_otd_dep := 0
            v := fcena_oms(lshifr,;
                           (mvzros_reb==0),;
                           mk_data,;
                           @fl_del,;
                           @fl_uslc)
            if fl_uslc  // если нашли в справочнике ТФОМС
              if fl_del
                func_error(4,'Цена на услугу '+rtrim(lshifr)+' отсутствует в справочнике ТФОМС')
              else
                fl := .t.
                parr[nElem,1] := mshifr
                if empty(parr[nElem,2])
                  parr[nElem,2] := 1
                endif
                parr[nElem,3] := v
                parr[nElem,4] := left(mname,40)
                parr[nElem,5] := lshifr
                b:right()
                b:refreshAll() ; flag := .t.
              endif
            else
              func_error(4,'Не найдена услуга в справочнике ТФОМС: '+lshifr)
            endif
          endif
        endif
      elseif nDim == 2
        if between(nKey,48,57)
          keyboard chr(nKey)
        endif
        Private mkol := parr[nElem,nDim]
        @ nRow, nCol GET mkol picture "999"
        myread()
        if lastkey() != K_ESC .and. mkol >= 0
          parr[nElem,2] := mkol
          flag := .t.
        endif
      endif
    else
      keyboard ""
    endif
ENDCASE
@ nRow, nCol SAY ""
return flag

*

***** 27.11.14 Отчёт о количестве выданных справок ОМС
Function f_otchet_spravka_OMS()
Local arr_m, buf := save_maxrow(), as := {0,0,0}, sh := 80, HH := 80, ;
      i, n_file := "o_sprOMS"+stxt
if (arr_m := year_month()) != NIL
  mywait()
  R_Use(dir_server+"mo_sprav",,"SPR_OMS")
  index on data to (cur_dir+"tmp") for between(data,arr_m[5],arr_m[6])
  go top
  do while !eof()
    i := 1
    if between(spr_oms->TIP,1,3)
      i := spr_oms->TIP
    endif
    as[i] ++
    skip
  enddo
  Use
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string(glob_mo[_MO_SHORT_NAME])
  add_string(padl("Приложение 3",sh))
  add_string(padl("к Приказу МЗВО и ТФОМС",sh))
  add_string(padl("№2841/758 от 29.10.2014г.",sh))
  add_string("")
  add_string(center("Отчёт",sh))
  add_string(center("О количестве справок о стоимости оказанной медицинской помощи в",sh))
  add_string(center("сфере ОМС, выданных застрахованным лицам в медицинских организациях",sh))
  add_string(center(arr_m[4],sh))
  add_string("")
  add_string("────────────────────────────────────────────────────────────────────────────────")
  add_string("      Количество проинформированных пациентов с выдачей справок о стоимости     ")
  add_string("                      медицинской помощи в сфере ОМС                            ")
  add_string("──────────────────────────┬──────────────────────────┬──────────────────────────")
  add_string(" в амбулаторно-поликлини- │  в условиях стационара   │     в условиях дневного  ")
  add_string("     ческих условиях      │                          │         стационара       ")
  add_string("──────────────────────────┴──────────────────────────┴──────────────────────────")
  add_string("")
  add_string(padc(lstr(as[1]),26)+" "+padc(lstr(as[2]),26)+" "+padc(lstr(as[3]),26))
  add_string("")
  add_string("────────────────────────────────────────────────────────────────────────────────")
  fclose(fp)
  rest_box(buf)
  viewtext(n_file,,,,.f.,,,2)
endif
return NIL
