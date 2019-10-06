***** mo_omsid.prg - информация по диспансеризации в ОМС
#include "inkey.ch"
#include "..\_mylib_hbt\fastreph.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1
Static mas1pmt := {"~все оказанные случаи",;
                   "случаи в выставленных ~счетах",;
                   "случаи в за~регистрированных счетах"}

***** 28.10.18 Диспансеризация, профилактика и медосмотры
Function dispanserizacia(k)
Static si1 := 1, si2 := 1, sj := 1, sj1 := 1
Local mas_pmt, mas_msg, mas_fun, j, j1
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~Дети-сироты",;
                "~Взрослое население",;
                "~Несовершеннолетние",;
                "~Сводная информация"}
    mas_msg := {"Информация по диспансеризации детей-сирот",;
                "Информация по диспансеризации и профилактике взрослого населения",;
                "Информация по медицинским осмотрам несовершеннолетних",;
                "Сводные документы по всем видам диспансеризации и профилактики"}
    mas_fun := {"dispanserizacia(11)",;
                "dispanserizacia(12)",;
                "dispanserizacia(13)",;
                "dispanserizacia(14)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    inf_DDS()
  case k == 12
    inf_DVN()
  case k == 13
    inf_DNL()
  case k == 14
    inf_DISP()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

***** 22.11.13 Информация по диспансеризации детей-сирот
Function inf_DDS(k)
Static si1 := 1, si2 := 1, sj := 1, sj1 := 1
Local mas_pmt, mas_msg, mas_fun, j, j1
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~Карта диспансеризации",;
                "~Список пациентов",;
                "Свод для Обл~здрава",;
                "Форма № 030-Д/с/~о-13",;
                "XML-файл для ~портала МЗРФ"}
    mas_msg := {"Распечатка карты диспансеризации (учётная форма № 030-Д/с/у-13)",;
                "Распечатка списка пациентов, которым проведена диспансеризация детей-сирот",;
                "Распечатка свода для Облздрава Волг.обл. (приказ № 10-03/1-3113 от 12.04.13г.)",;
                "Сведения о диспансеризации несовершеннолетних (отчётная форма № 030-Д/с/о-13)",;
                "Создание XML-файла для загрузки на портал Минздрава РФ"}
    mas_fun := {"inf_DDS(11)",;
                "inf_DDS(12)",;
                "inf_DDS(13)",;
                "inf_DDS(14)",;
                "inf_DDS(15)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case between(k,11,19)
    if (j := popup_prompt(T_ROW,T_COL-5,sj,;
        {"Находящиеся в стационаре","Находящиеся под опекой"})) == 0
      return NIL
    endif
    sj := j
    Private p_tip_lu := iif(j==1, TIP_LU_DDS, TIP_LU_DDSOP)
    do case
      case k == 11
        inf_DDS_karta()
      case k == 12
        if (j1 := popup_prompt(T_ROW,T_COL-5,3,mas1pmt)) > 0
          inf_DDS_svod(1,,j1)
        endif
      case k == 13
        if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
          if (j := popup_prompt(T_ROW,T_COL-5,1,;
              {"Вывод таблицы со списком детей-сирот",;
               "Вывод итоговой строки в Excel для ОДКБ"})) > 0
            inf_DDS_svod(2,j,j1)
          endif
        endif
      case k == 14
        if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
          inf_DDS_030dso(j1)
        endif
      case k == 15
        if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
          inf_DDS_XMLfile(j1)
        endif
    endcase
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  endif
endif
return NIL

***** 12.07.13 Распечатка карты диспансеризации (учётная форма № 030-Д/с/у-13)
Function inf_DDS_karta()
Local arr_m, buf := save_maxrow(), blk, t_arr[BR_LEN]
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  if f0_inf_DDS(arr_m,.f.)
    R_Use(dir_server+"human",,"HUMAN")
    use (cur_dir+"tmp") new
    set relation to kod into HUMAN
    index on upper(human->fio) to (cur_dir+"tmp")
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            R_Use(cur_dir+"tmp",cur_dir+"tmp"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    eval(blk_open)
    go top
    t_arr[BR_TOP] := T_ROW
    t_arr[BR_BOTTOM] := 23
    t_arr[BR_LEFT] := 0
    t_arr[BR_RIGHT] := 79
    t_arr[BR_TITUL] := "Диспансеризация детей-сирот "+arr_m[4]
    t_arr[BR_TITUL_COLOR] := "B/BG"
    t_arr[BR_COLOR] := color0
    t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
    blk := {|| iif(human->schet > 0, {1,2}, {3,4}) }
    t_arr[BR_COLUMN] := {{" Ф.И.О.", {|| padr(human->fio,39) }, blk },;
                         {"Дата рожд.", {|| full_date(human->date_r) }, blk },;
                         {"№ ам.карты", {|| human->uch_doc }, blk },;
                         {"Сроки леч-я", {|| left(date_8(human->n_data),5)+"-"+left(date_8(human->k_data),5) }, blk },;
                         {"Этап", {|| iif(human->ishod==101," I  ","I-II") }, blk }}
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - распечатать карту диспансеризации") }
    t_arr[BR_EDIT] := {|nk,ob| f1_inf_DDS_karta(nk,ob,"edit") }
    edit_browse(t_arr)
  endif
endif
close databases
rest_box(buf)
return NIL

*

***** 11.03.19
Function f0_inf_DDS(arr_m,is_schet,is_reg,is_snils)
Local fl := .t.
DEFAULT is_schet TO .t., is_reg TO .f., is_snils TO .f.
if !del_dbf_file("tmp"+sdbf)
  return .f.
endif
dbcreate(cur_dir+"tmp",{{"kod","N",7,0},;
                        {"is", "N",1,0}})
use (cur_dir+"tmp") new
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_, to kod_k into KART
dbseek(dtos(arr_m[5]),.t.)
index on kod to (cur_dir+"tmp_h") ;
      for iif(p_tip_lu==TIP_LU_DDS,!empty(za_smo),empty(za_smo)) .and. ;
          eq_any(ishod,101,102) .and. iif(is_schet, schet > 0, .t.) ;
      while human->k_data <= arr_m[6] ;
      PROGRESS
go top
do while !eof()
  fl := .t.
  if is_reg
    fl := .f.
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // только зарегистрированные
      fl := .t.
    endif
  endif
  if fl .and. ret_koef_from_RAK(human->kod) > 0
    select TMP
    append blank
    tmp->kod := human->kod
    tmp->is := iif(is_snils .and. empty(kart->snils), 0, 1)
  endif
  select HUMAN
  skip
enddo
fl := .t.
if tmp->(lastrec()) == 0
  fl := func_error(4,"Не найдено л/у по диспансеризации детей-сирот "+arr_m[4])
endif
close databases
return fl

***** 05.07.13
Function f1_inf_DDS_karta(nKey,oBrow,regim)
Local ret := -1, lkod_h, lkod_k, rec := tmp->(recno()), buf := save_maxrow()
if regim == "edit" .and. nKey == K_ENTER
  mywait()
  lkod_h := human->kod
  lkod_k := human->kod_k
  close databases
  oms_sluch_DDS(p_tip_lu,lkod_h,lkod_k,"f2_inf_DDS_karta")
  eval(blk_open)
  goto (rec)
  rest_box(buf)
endif
return ret

***** 22.04.18
Function f2_inf_DDS_karta(Loc_kod,kod_kartotek,lvozrast)
Static st := "     ", ub := "<u><b>", ue := "</b></u>", sh := 88
Local adbf, s, i, j, k, y, m, d, fl, mm_danet, blk := {|s| __dbAppend(), field->stroke := s }
delFRfiles()
R_Use(dir_server+"mo_stdds")
if type("m1stacionar") == "N" .and. m1stacionar > 0
  goto (m1stacionar)
endif
R_Use(dir_server+"kartote_",,"KART_")
goto (kod_kartotek)
R_Use(dir_server+"kartotek",,"KART")
goto (kod_kartotek)
R_Use(dir_server+"mo_pers",,"P2")
goto (m1vrach)
R_Use(dir_server+"organiz",,"ORG")
adbf := {{"name","C",130,0},;
         {"prikaz","C",50,0},;
         {"forma","C",50,0},;
         {"titul","C",100,0},;
         {"fio","C",50,0},;
         {"k_data","C",40,0},;
         {"vrach","C",40,0},;
         {"glavn","C",40,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_SHORT_NAME]
frt->fio := mfio
frt->k_data := date_month(mk_data)
frt->vrach := fam_i_o(p2->fio)
frt->glavn := fam_i_o(org->ruk)
adbf := {{"stroke","C",2000,0}}
dbcreate(fr_data,adbf)
use (fr_data) new alias FRD
if p_tip_lu == TIP_LU_PN // профилактика несовершеннолетних
  frt->prikaz := "от 21.12.2012г. № 1346н"
  frt->forma  := "030-ПО/у-12"
  frt->titul  := "Карта профилактического медицинского осмотра несовершеннолетнего"
  s := st+"1. Фамилия, имя, отчество несовершеннолетнего: "+ub+alltrim(mfio)+ue+"."
  frd->(eval(blk,s))
  s := st+"Пол: "+f3_inf_DDS_karta({{"муж.","М"},{"жен.","Ж"}},mpol,"/",ub,ue)
  frd->(eval(blk,s))
  s := st+"Дата рождения: "+ub+date_month(mdate_r,.t.)+ue+"."
  frd->(eval(blk,s))
  s := st+"2. Полис обязательного медицинского страхования: "
  s += "серия "+iif(empty(mspolis), replicate("_",15), ub+alltrim(mspolis)+ue)
  s += " № "+ub+alltrim(mnpolis)+ue+"."
  frd->(eval(blk,s))
  s := st+"Страховая медицинская организация: "+ub+alltrim(mcompany)+ue+"."
  frd->(eval(blk,s))
  s := st+"3. Страховой номер индивидуального лицевого счета: "
  s += iif(empty(kart->snils), replicate("_",25), ub+transform(kart->SNILS,picture_pf)+ue)+"."
  frd->(eval(blk,s))
  s := st+"4. Адрес места жительства: "
  if emptyall(kart_->okatog,kart->adres)
    s += replicate("_",50)+" "+replicate("_",sh)+"."
  else
    s += ub+ret_okato_ulica(kart->adres,kart_->okatog,1,2)+ue+"."
  endif
  frd->(eval(blk,s))
  s := st+"5. Категория: "+f3_inf_DDS_karta(mm_kateg_uch,m1kateg_uch,"; ",ub,ue)
  frd->(eval(blk,s))
  s := st+"6. Полное наименование медицинской организации, в которой "+;
          "несовершеннолетний получает первичную медико-санитарную помощь: "
  s += ub+ret_mo(m1MO_PR)[_MO_FULL_NAME]+ue+"."
  frd->(eval(blk,s))
  s := st+"7. Юридический адрес медицинской организации, в которой " +;
           "несовершеннолетний получает первичную медико-санитарную помощь: "
  s += ub+ret_mo(m1MO_PR)[_MO_ADRES]+ue+"."
  frd->(eval(blk,s))
  madresschool := ""
  if type("m1school") == "N" .and. m1school > 0
    R_Use(dir_server+"mo_schoo",,"SCH")
    goto (m1school)
    if !empty(sch->fname)
      mschool := alltrim(sch->fname)
      madresschool := alltrim(sch->adres)
    endif
  endif
  s := st+"8. Полное наименование образовательного учреждения, в котором "+;
          "обучается несовершеннолетний: "+ub+mschool+ue+"."
  frd->(eval(blk,s))
  s := st+"9. Юридический адрес образовательного учреждения, в котором "+;
          "обучается несовершеннолетний: "
  if empty(madresschool)
    frd->(eval(blk,s))
    s := replicate("_",sh)+"."
  else
    s += ub+madresschool+ue+"."
  endif
  frd->(eval(blk,s))
  s := st+"10. Дата начала медицинского осмотра: "+ub+full_date(mn_data)+ue+"."
  frd->(eval(blk,s))
else // диспансеризация детей-сирот
  frt->prikaz := "от 15.02.2013г. № 72н"
  frt->forma  := "030-Д/с/у-13"
  frt->titul  := "Карта диспансеризации несовершеннолетнего"
  s := st+"1. Полное наименование стационарного учреждения: "
  if p_tip_lu == TIP_LU_DDS
    s += ub+alltrim(mstacionar)+ue+"."
    frd->(eval(blk,s))
  else
    frd->(eval(blk,s))
    s := replicate("_",sh)+"."
    frd->(eval(blk,s))
  endif
  s := st+"1.1. Прежнее наименование (в случае его изменения):"
  frd->(eval(blk,s))
  s := replicate("_",sh)+"."
  frd->(eval(blk,s))
  s := st+"1.2. Ведомственная принадлежность: "
  if p_tip_lu == TIP_LU_DDS
    i := mo_stdds->vedom
    if !between(i,0,3)
      i := 3
    endif
  else
    i := -1
  endif
  mm_vedom := {{"органы здравоохранения",0},;
               {"образования",1},;
               {"социальной защиты",2},;
               {"другое",3}}
  s += f3_inf_DDS_karta(mm_vedom,i,,ub,ue)
  frd->(eval(blk,s))
  s := st+"1.3. Юридический адрес стационарного учреждения: "
  if p_tip_lu == TIP_LU_DDS .and. !empty(mo_stdds->adres)
    s += ub+alltrim(mo_stdds->adres)+ue+"."
  endif
  frd->(eval(blk,s))
  if p_tip_lu == TIP_LU_DDSOP .or. empty(mo_stdds->adres)
    s := replicate("_",sh)+"."
    frd->(eval(blk,s))
  endif
  s := st+"2. Фамилия, имя, отчество несовершеннолетнего: "+ub+alltrim(mfio)+ue+"."
  frd->(eval(blk,s))
  s := st+"2.1. Пол: "
  s += f3_inf_DDS_karta({{"муж.","М"},{"жен.","Ж"}},mpol,"/",ub,ue)
  frd->(eval(blk,s))
  s := st+"2.2. Дата рождения: "+ub+date_month(mdate_r,.t.)+ue+"."
  frd->(eval(blk,s))
  s := st+"2.3. Категория учета ребенка, находящегося в тяжелой жизненной ситуации: "
  s += f3_inf_DDS_karta(mm_kateg_uch,m1kateg_uch,"; ",ub,ue)
  frd->(eval(blk,s))
  s := st+"2.4. На момент проведения диспансеризации находится "
  mm_gde_nahod1[3,1] := "попечительством"
  s += f3_inf_DDS_karta(mm_gde_nahod1,m1gde_nahod,,ub,ue)
  frd->(eval(blk,s))
  s := st+"3. Полис обязательного медицинского страхования:"
  frd->(eval(blk,s))
  s := st+"серия "+iif(empty(mspolis), replicate("_",15), ub+alltrim(mspolis)+ue)
  s += " № "+ub+alltrim(mnpolis)+ue+"."
  frd->(eval(blk,s))
  s := st+"Страховая медицинская организация: "+ub+alltrim(mcompany)+ue+"."
  frd->(eval(blk,s))
  s := st+"Страховой номер индивидуального лицевого счета: "
  s += iif(empty(kart->snils), replicate("_",25), ub+transform(kart->SNILS,picture_pf)+ue)+"."
  frd->(eval(blk,s))
  s := st+"4. Дата поступления в стационарное учреждение: "
  s += iif(p_tip_lu==TIP_LU_DDSOP.or.empty(mdate_post), replicate("_",15), ub+full_date(mdate_post)+ue)+"."
  frd->(eval(blk,s))
  s := st+"5. Причина выбытия из стационарного учреждения: "
  Del_Array(mm_prich_vyb,1) // удалить 1-ый элемент "{"не выбыл",0}"
  s += f3_inf_DDS_karta(mm_prich_vyb,m1prich_vyb,,ub,ue)
  frd->(eval(blk,s))
  s := st+"5.1. Дата выбытия: "+iif(empty(mDATE_VYB), replicate("_",15), ub+full_date(mDATE_VYB)+ue)+"."
  frd->(eval(blk,s))
  s := st+"6. Отсутствует на момент проведения диспансеризации:"
  frd->(eval(blk,s))
  s := replicate("_",73)+" (указать причину)."
  frd->(eval(blk,s))
  s := st+"7. Адрес места жительства: "
  if emptyall(kart_->okatog,kart->adres)
    s += replicate("_",50)+" "+replicate("_",sh)+"."
  else
    s += ub+ret_okato_ulica(kart->adres,kart_->okatog,1,2)+ue+"."
  endif
  frd->(eval(blk,s))
  s := st+"8. Полное наименование медицинской организации, выбранной "+;
          "несовершеннолетним (его родителем или иным законным представителем) "+;
          "для получения первичной медико-санитарной помощи: "
  s += ub+ret_mo(m1MO_PR)[_MO_FULL_NAME]+ue+"."
  frd->(eval(blk,s))
  s := st+"9. Юридический адрес медицинской организации, выбранной "+;
           "несовершеннолетним (его родителем или иным законным представителем) "+;
           "для получения первичной медико-санитарной помощи: "
  s += ub+ret_mo(m1MO_PR)[_MO_ADRES]+ue+"."
  frd->(eval(blk,s))
  s := st+"10. Дата начала диспансеризации: "+ub+full_date(mn_data)+ue+"."
  frd->(eval(blk,s))
endif
s := st+"11. Полное наименование и юридический адрес медицинской организации, "+;
        "проводившей "+iif(p_tip_lu==TIP_LU_PN,"профилактический медицинский осмотр: ","диспансеризацию: ")+;
        ub+glob_mo[_MO_FULL_NAME]+", "+glob_mo[_MO_ADRES]+ue+"."
frd->(eval(blk,s))
s := st+"12. Оценка физического развития с учетом возраста на момент "+;
        iif(p_tip_lu==TIP_LU_PN,"медицинского осмотра:","диспансеризации:")
frd->(eval(blk,s))
count_ymd(mdate_r,mn_data,@y,@m,@d)
s := ub+st+lstr(d)+st+ue+" (число дней) "+;
     ub+st+lstr(m)+st+ue+" (месяцев) "+;
     ub+st+lstr(y)+st+ue+" лет."
frd->(eval(blk,s))
mm_fiz_razv1 := {{"дефицит массы тела",1},{"избыток массы тела",2}}
mm_fiz_razv2 := {{"низкий рост",1},{"высокий рост",2}}
for i := 1 to 2
  s := st+"12."+lstr(i)+". Для детей в возрасте "+;
          {"0 - 4 лет: ","5 - 17 лет включительно: "}[i]
  if i == 1
    fl := (lvozrast < 5)
  else
    fl := (lvozrast > 4)
  endif
  s += "масса (кг) "+iif(!fl,"________",ub+st+lstr(mWEIGHT)+st+ue)+"; "
  s += "рост (см) "+iif(!fl,"________",ub+st+lstr(mHEIGHT)+st+ue)+"; "
  s += "окружность головы (см) "+iif(!fl.or.mPER_HEAD==0,"________",ub+st+lstr(mPER_HEAD)+st+ue)+"; "
  s += "физическое развитие "+f3_inf_DDS_karta(mm_fiz_razv,iif(fl,m1FIZ_RAZV,-1),,ub,ue,.f.)
  s += " ("+f3_inf_DDS_karta(mm_fiz_razv1,iif(fl,m1FIZ_RAZV1,-1),,ub,ue,.f.)
  s += ", "+f3_inf_DDS_karta(mm_fiz_razv2,iif(fl,m1FIZ_RAZV2,-1),,ub,ue,.f.)
  s += " - нужное подчеркнуть)."
  frd->(eval(blk,s))
next
fl := (lvozrast < 5)
s := st+"13. Оценка психического развития (состояния):"
frd->(eval(blk,s))
s := st+"13.1. Для детей в возрасте 0 - 4 лет:"
frd->(eval(blk,s))
s := st+"познавательная функция (возраст развития) "+iif(!fl,"________",ub+st+lstr(m1psih11)+st+ue)+";"
frd->(eval(blk,s))
s := st+"моторная функция (возраст развития) "+iif(!fl,"________",ub+st+lstr(m1psih12)+st+ue)+";"
frd->(eval(blk,s))
s := st+"эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития) "+iif(!fl,"________",ub+st+lstr(m1psih13)+st+ue)+";"
frd->(eval(blk,s))
s := st+"предречевое и речевое развитие (возраст развития) "+iif(!fl,"________",ub+st+lstr(m1psih14)+st+ue)+"."
frd->(eval(blk,s))
fl := (lvozrast > 4)
s := st+"13.2. Для детей в возрасте 5 - 17 лет:"
frd->(eval(blk,s))
s := st+"13.2.1. Психомоторная сфера: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih21,-1),,ub,ue)
frd->(eval(blk,s))
s := st+"13.2.2. Интеллект: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih22,-1),,ub,ue)
frd->(eval(blk,s))
s := st+"13.2.3. Эмоционально-вегетативная сфера: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih23,-1),,ub,ue)
frd->(eval(blk,s))
fl := (mpol == "М" .and. lvozrast > 9)
s := st+"14. Оценка полового развития (с 10 лет):"
frd->(eval(blk,s))
s := st+"14.1. Половая формула мальчика: Р "+iif(!fl.or.m141p==0,"________",ub+st+lstr(m141p)+st+ue)
s += " Ах "+iif(!fl.or.m141ax==0,"________",ub+st+lstr(m141ax)+st+ue)
s += " Fa "+iif(!fl.or.m141fa==0,"________",ub+st+lstr(m141fa)+st+ue)+"."
frd->(eval(blk,s))
fl := (mpol == "Ж" .and. lvozrast > 9)
s := st+"14.2. Половая формула девочки: Р "+iif(!fl.or.m142p==0,"________",ub+st+lstr(m142p)+st+ue)
s += " Ах "+iif(!fl.or.m142ax==0,"________",ub+st+lstr(m142ax)+st+ue)
s += " Ma "+iif(!fl.or.m142ma==0,"________",ub+st+lstr(m142ma)+st+ue)
s += " Me "+iif(!fl.or.m142me==0,"________",ub+st+lstr(m142me)+st+ue)+";"
frd->(eval(blk,s))
s := st+"характеристика менструальной функции: menarhe ("
s += iif(!fl.or.m142me1==0,"________",ub+st+lstr(m142me1)+st+ue)+" лет, "
s += iif(!fl.or.m142me2==0,"________",ub+st+lstr(m142me2)+st+ue)+" месяцев); "
if fl .and. emptyall(m142p,m142ax,m142ma,m142me,m142me1,m142me2)
  m1142me3 := m1142me4 := m1142me5 := -1
endif
s += "menses (характеристика): "+f3_inf_DDS_karta(mm_142me3,iif(fl,m1142me3,-1),,ub,ue,.f.)
s += ", "+f3_inf_DDS_karta(mm_142me4,iif(fl,m1142me4,-1),,ub,ue,.f.)
s += ", "+f3_inf_DDS_karta(mm_142me5,iif(fl,m1142me5,-1)," и ",ub,ue)
frd->(eval(blk,s))
s := st+"15. Состояние здоровья до проведения "+;
     iif(p_tip_lu==TIP_LU_PN,"настоящего профилактического медицинского осмотра:","диспансеризации:")
frd->(eval(blk,s))
if lvozrast < 14
  mdef_diagnoz := "Z00.1"
else
  mdef_diagnoz := "Z00.3"
endif
s := st+"15.1. Практически здоров "+iif(m1diag_15_1==0,replicate("_",30),ub+st+rtrim(mdef_diagnoz)+st+ue)+" (код по МКБ)."
frd->(eval(blk,s))
//
mm_dispans := {{"установлено ранее",1},{"установлено впервые",2},{"не установлено",0}}
mm_danet := {{"да",1},{"нет",0}}
mm_usl := {{"в амбулаторных условиях",0},;
           {"в условиях дневного стационара",1},;
           {"в стационарных условиях",2}}
mm_uch := {{"в муниципальных медицинских организациях",1},;
           {"в государственных медицинских организациях субъекта Российской Федерации ",0},;
           {"в федеральных медицинских организациях",2},;
           {"частных медицинских организациях",3}}
mm_uch1 := aclone(mm_uch)
aadd(mm_uch1, {"санаторно-курортных организациях",4})
mm_danet1 := {{"оказана",1},{"не оказана",0}}
for i := 1 to 5
  fl := .f.
  for k := 1 to 14
    mvar := "mdiag_15_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_15_1 == 0
    else
      m1var := "m1diag_15_"+lstr(i)+"_"+lstr(k)
      if fl
        do case
          case eq_any(k,4,5,6,7)
            mvar := "m1diag_15_"+lstr(i)+"_3"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
          case eq_any(k,9,10,11,12)
            mvar := "m1diag_15_"+lstr(i)+"_8"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
          case k == 14
            mvar := "m1diag_15_"+lstr(i)+"_13"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
        endcase
      else
        &m1var := -1
      endif
    endif
  next
next
for i := 1 to 5
  fl := .f.
  s := s1 := s2 := s3 := s4 := s5 := s6 := ""
  for k := 1 to 14
    mvar := "mdiag_15_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_15_1 == 0
    else
      m1var := "m1diag_15_"+lstr(i)+"_"+lstr(k)
    endif
    do case
      case k == 1
        s := st+"15."+lstr(i+1)+". Диагноз "+iif(!fl,replicate("_",30),ub+st+rtrim(&mvar)+st+ue)+" (код по МКБ)."
      case k == 2
        s1 := st+"15."+lstr(i+1)+".1. Диспансерное наблюдение: "+f3_inf_DDS_karta(mm_dispans,&m1var,,ub,ue)
      case k == 3
        s2 := st+"15."+lstr(i+1)+".2. Лечение было назначено: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 4
        s2 := left(s2,len(s2)-1)+'; если "да": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 5
        s2 := left(s2,len(s2)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 6
        s3 := st+"15."+lstr(i+1)+".3. Лечение было выполнено: "+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 7
        s3 := left(s3,len(s3)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 8
        s4 := st+"15."+lstr(i+1)+".4. Медицинская реабилитация и (или) санаторно-курортное лечение были назначены: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 9
        s4 := left(s4,len(s4)-1)+'; если "да": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 10
        s4 := left(s4,len(s4)-1)+'; '+f3_inf_DDS_karta(mm_uch1,&m1var,,ub,ue)
      case k == 11
        s5 := st+"15."+lstr(i+1)+".5. Медицинская реабилитация и (или) санаторно-курортное лечение были выполнены: "+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 12
        s5 := left(s5,len(s5)-1)+'; '+f3_inf_DDS_karta(mm_uch1,&m1var,,ub,ue)
      case k == 13
        s6 := st+"15."+lstr(i+1)+".6. Высокотехнологичная медицинская помощь была рекомендована: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 14
        s6 := left(s6,len(s6)-1)+'; если "да": '+f3_inf_DDS_karta(mm_danet1,&m1var,,ub,ue)
    endcase
  next
  frd->(eval(blk,s))
  frd->(eval(blk,s1))
  frd->(eval(blk,s2))
  frd->(eval(blk,s3))
  frd->(eval(blk,s4))
  frd->(eval(blk,s5))
  frd->(eval(blk,s6))
next
mm_gruppa := {{"I",1},{"II",2},{"III",3},{"IV",4},{"V",5}}
s := st+"15.9. Группа состояния здоровья: "+f3_inf_DDS_karta(mm_gruppa,mGRUPPA_DO,,ub,ue)
frd->(eval(blk,s))
if p_tip_lu == TIP_LU_PN
  s := st+"15.10. Медицинская группа для занятий физической культурой: "
  s += f3_inf_DDS_karta(mm_gr_fiz_do,m1GR_FIZ_DO,,ub,ue)
  frd->(eval(blk,s))
endif
s := st+"16. Состояние здоровья по результатам проведения "+;
     iif(p_tip_lu==TIP_LU_PN,"настоящего профилактического медицинского осмотра:","диспансеризации:")
frd->(eval(blk,s))
s := st+"16.1. Практически здоров "+iif(m1diag_16_1==0,replicate("_",30),ub+st+rtrim(mkod_diag)+st+ue)+" (код по МКБ)."
frd->(eval(blk,s))
for i := 1 to 5
  fl := .f.
  for k := 1 to 16
    mvar := "mdiag_16_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_16_1 == 0
    else
      m1var := "m1diag_16_"+lstr(i)+"_"+lstr(k)
      if fl
        do case
          case eq_any(k,5,6)
            mvar := "m1diag_16_"+lstr(i)+"_4"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
          case eq_any(k,8,9)
            mvar := "m1diag_16_"+lstr(i)+"_7"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
          case eq_any(k,11,12)
            mvar := "m1diag_16_"+lstr(i)+"_10"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
          case eq_any(k,14,15)
            mvar := "m1diag_16_"+lstr(i)+"_13"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
        endcase
      else
        &m1var := -1
      endif
    endif
  next
next
for i := 1 to 5
  fl := .f.
  s := s1 := s2 := s3 := s4 := s5 := s6 := s7 := ""
  for k := 1 to 16
    mvar := "mdiag_16_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_16_1 == 0
    else
      m1var := "m1diag_16_"+lstr(i)+"_"+lstr(k)
    endif
    do case
      case k == 1
        s := st+"16."+lstr(i+1)+". Диагноз "+iif(!fl,replicate("_",30),ub+st+rtrim(&mvar)+st+ue)+" (код по МКБ)."
      case k == 2
        s1 := st+"16."+lstr(i+1)+".1. Диагноз установлен впервые: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 3
        s2 := st+"16."+lstr(i+1)+".2. Диспансерное наблюдение: "+f3_inf_DDS_karta(mm_dispans,&m1var,,ub,ue)
      case k == 4
        s3 := st+"16."+lstr(i+1)+".3. Дополнительные консультации и исследования назначены: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 5
        s3 := left(s3,len(s3)-1)+'; если "да": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 6
        s3 := left(s3,len(s3)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 7
        s4 := st+"16."+lstr(i+1)+".4. Дополнительные консультации и исследования выполнены: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 8
        s4 := left(s4,len(s4)-1)+'; если "да": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 9
        s4 := left(s4,len(s4)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 10
        s5 := st+"16."+lstr(i+1)+".5. Лечение назначено: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 11
        s5 := left(s5,len(s5)-1)+'; если "да": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 12
        s5 := left(s5,len(s5)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 13
        s6 := st+"16."+lstr(i+1)+".6. Медицинская реабилитация и (или) санаторно-курортное лечение назначены: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 14
        s6 := left(s6,len(s6)-1)+'; если "да": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 15
        s6 := left(s6,len(s6)-1)+'; '+f3_inf_DDS_karta(mm_uch1,&m1var,,ub,ue)
      case k == 16
        s7 := st+"16."+lstr(i+1)+".7. Высокотехнологичная медицинская помощь была рекомендована: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
    endcase
  next
  frd->(eval(blk,s))
  frd->(eval(blk,s1))
  frd->(eval(blk,s2))
  frd->(eval(blk,s3))
  frd->(eval(blk,s4))
  frd->(eval(blk,s5))
  frd->(eval(blk,s6))
  frd->(eval(blk,s7))
next
if m1invalid1 == 0
  m1invalid2 := m1invalid5 := m1invalid6 := m1invalid8 := -1
  minvalid3 := minvalid4 := minvalid7 := ctod("")
endif
if empty(minvalid7)
  m1invalid8 := -1
endif
s := st+'16.7. Инвалидность: '+f3_inf_DDS_karta(mm_danet,m1invalid1,,ub,ue)
s := left(s,len(s)-1)+'; если "да": '+f3_inf_DDS_karta(mm_invalid2,m1invalid2,,ub,ue)
s := left(s,len(s)-1)+'; установлена впервые (дата) '+iif(empty(minvalid3), replicate("_",15), ub+full_date(minvalid3)+ue)
s += '; дата последнего освидетельствования '+iif(empty(minvalid4), replicate("_",15), ub+full_date(minvalid4)+ue)+'.'
frd->(eval(blk,s))
s := st+'16.7.1. Заболевания, обусловившие возникновение инвалидности:'
frd->(eval(blk,s))
mm_invalid5[6,1] := "болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм;"
mm_invalid5[7,1] := "болезни эндокринной системы, расстройства питания и нарушения обмена веществ,"
atail(mm_invalid5)[1] := "последствия травм, отравлений и других воздействий внешних причин)"
s := st+'('+f3_inf_DDS_karta(mm_invalid5,m1invalid5,' ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.2.Виды нарушений в состоянии здоровья:'
frd->(eval(blk,s))
s := st+f3_inf_DDS_karta(mm_invalid6,m1invalid6,'; ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.3. Индивидуальная программа реабилитации ребенка-инвалида:'
frd->(eval(blk,s))
s := st+'дата назначения: '+iif(empty(minvalid7), replicate("_",15), ub+full_date(minvalid7)+ue)+';'
frd->(eval(blk,s))
s := st+'выполнение на момент диспансеризации: '+f3_inf_DDS_karta(mm_invalid8,m1invalid8,,ub,ue)
frd->(eval(blk,s))
s := st+"16.8. Группа состояния здоровья: "+f3_inf_DDS_karta(mm_gruppa,mGRUPPA,,ub,ue)
frd->(eval(blk,s))
if p_tip_lu == TIP_LU_PN
  s := st+"16.9. Медицинская группа для занятий физической культурой: "
  s += f3_inf_DDS_karta(mm_gr_fiz,m1GR_FIZ,,ub,ue)
  frd->(eval(blk,s))
endif
s := st+iif(p_tip_lu==TIP_LU_PN,'16.10','16.9')+;
     '. Проведение профилактических прививок:'
frd->(eval(blk,s))
s := st
for j := 1 to len(mm_privivki1)
  if m1privivki1 == mm_privivki1[j,2]
    s += ub
  endif
  s += mm_privivki1[j,1]
  if m1privivki1 == mm_privivki1[j,2]
    s += ue
  endif
  if mm_privivki1[j,2] == 0
    s += "; "
  else
    s += ": "+f3_inf_DDS_karta(mm_privivki2,iif(m1privivki1==mm_privivki1[j,2],m1privivki2,-1),,ub,ue,.f.)+"; "
  endif
next
s += 'нуждается в проведении вакцинации (ревакцинации) с указанием наименования прививки (нужное подчеркнуть): '
if m1privivki1 > 0 .and. !empty(mprivivki3)
  s += ub+alltrim(mprivivki3)+ue
endif
frd->(eval(blk,s))
s := replicate("_",sh)+"."
frd->(eval(blk,s))
s := st+iif(p_tip_lu==TIP_LU_PN,'16.11','16.10')+;
     '. Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой: '
k := 3
if !empty(mrek_form)
  k := 1
  s += ub+alltrim(mrek_form)+ue
endif
frd->(eval(blk,s))
for i := 1 to k
  s := replicate("_",sh)+iif(i==k, ".", "")
  frd->(eval(blk,s))
next
if p_tip_lu == TIP_LU_PN
  s := st+'16.12. Рекомендации о необходимости установления или продолжения '+;
          'диспансерного наблюдения, включая диагноз заболевания (состояния) '+;
          'и код МКБ, по лечению, медицинской реабилитации и '+;
          'санаторно-курортному лечению с указанием вида медицинской '+;
          'организации (санаторно-курортной организации) и специальности '+;
          '(должности) врача: '
else
  s := st+'16.11. Рекомендации по диспансерному наблюдению, лечению, '+;
          'медицинской реабилитации и санаторно-курортному лечению с указанием '+;
          'диагноза (код МКБ), вида медицинской организации и специальности '+;
          '(должности) врача: '
endif
k := 5
if !empty(mrek_disp)
  k := 2
  s += ub+alltrim(mrek_disp)+ue
endif
frd->(eval(blk,s))
for i := 1 to k
  s := replicate("_",sh)+iif(i==k, ".", "")
  frd->(eval(blk,s))
next
//
adbf := {{"name","C",60,0},;
         {"data","C",10,0},;
         {"rezu","C",17,0}}
dbcreate(fr_data+"1",adbf)
use (fr_data+"1") new alias FRD1
dbcreate(fr_data+"2",adbf)
use (fr_data+"2") new alias FRD2
arr := iif(p_tip_lu==TIP_LU_PN,f4_inf_DNL_karta(1),f4_inf_DDS_karta(1))
for i := 1 to len(arr)
  select FRD1
  append blank
  frd1->name := arr[i,1]
  frd1->data := full_date(arr[i,2])
next
arr := iif(p_tip_lu==TIP_LU_PN,f4_inf_DNL_karta(2),f4_inf_DDS_karta(2))
for i := 1 to len(arr)
  select FRD2
  append blank
  frd2->name := arr[i,1]
  frd2->data := full_date(arr[i,2])
  frd2->rezu := arr[i,3]
next
//
close databases
call_fr("mo_030dcu13")
return NIL

*

***** 05.07.13
Function f3_inf_DDS_karta(_menu,_i,_r,ub,ue,fl)
Local j, s := ""
DEFAULT _r TO ", ", fl TO .t.
for j := 1 to len(_menu)
  if _i == _menu[j,2]
    s += ub
  endif
  s += ltrim(_menu[j,1])
  if _i == _menu[j,2]
    s += ue
  endif
  if j < len(_menu)
    s += _r
  endif
next
if fl
  s += " (нужное подчеркнуть)."
endif
return s

*

***** 04.05.16
Function f4_inf_DDS_karta(par,_etap,et2)
Local i, k, arr := {}
if par == 1
  if iif(_etap==nil, .t., _etap==1)
    for i := 1 to count_dds_arr_osm1
      k := 0
      do case
        case i ==  1 // {"офтальмолог","",0,17,{65},{1112},{"2.83.21"}},;
          k := 3
        case i ==  2 // {"оториноларинголог","",0,17,{64},{1111,111101},{"2.83.22"}},;
          k := 5
        case i ==  3 // {"детский хирург","",0,17,{20},{1135},{"2.83.18"}},;
          k := 4
        case i ==  4 // {"травматолог-ортопед","",0,17,{100},{1123},{"2.83.19"}},;
          k := 6
        case i ==  5 // {"акушер-гинеколог (девочки)","Ж",0,17,{2},{1101},{"2.83.16"}},;
          k := 11
        case i ==  6 // {"детский уролог-андролог (мальчики)","М",0,17,{19},{112603,113502},{"2.83.17"}},;
          k := 10
        case i ==  7 // {"детский стоматолог (с 3 лет)","",3,17,{86},{140102},{"2.83.23"}},;
          k := 8
        case i ==  8 // {"детский эндокринолог (с 5 лет)","",5,17,{21},{1127,112702,113402},{"2.83.24"}},;
          k := 9
        case i ==  9 // {"невролог","",0,17,{53},{1109},{"2.83.20"}},;
          k := 2
        case i == 10 // {"психиатр","",0,17,{72},{1115},{"2.4.1"}},;
          k := 7
        case i == 11 // {"педиатр","",0,17,{68,57},{1134,1110},{"2.83.14","2.83.15"}};
          k := 1
      endcase
      mvart := "MTAB_NOMov"+lstr(i)
      mvard := "MDATEo"+lstr(i)
      if between(mvozrast,dds_arr_osm1[i,3],dds_arr_osm1[i,4]) .and. ;
              iif(empty(dds_arr_osm1[i,2]), .t., dds_arr_osm1[i,2]==mpol)
        if !emptyany(&mvard,&mvart)
          aadd(arr, {dds_arr_osm1[i,1], &mvard, "", i, k})
        endif
      endif
    next
  endif
  if metap == 2 .and. iif(_etap==nil, .t., _etap==2)
    DEFAULT et2 TO 0
    if eq_any(et2,0,1)
      for i := 7 to 8 // стоматолог и эндокринолог на 2 этапе
        k := 0
        mvart := "MTAB_NOMov"+lstr(i)
        mvard := "MDATEo"+lstr(i)
        if !between(mvozrast,dds_arr_osm1[i,3],dds_arr_osm1[i,4])
          if !emptyany(&mvard,&mvart)
            aadd(arr, {dds_arr_osm1[i,1], &mvard, "", i, k})
          endif
        endif
      next
    endif
    if eq_any(et2,0,2)
      for i := 1 to count_dds_arr_osm2
        k := 0
        mvart := "MTAB_NOM2ov"+lstr(i)
        mvard := "MDATE2o"+lstr(i)
        if !emptyany(&mvard,&mvart)
          aadd(arr, {dds_arr_osm2[i,1], &mvard, "", i, k})
        endif
      next
    endif
  endif
else
  for i := 1 to count_dds_arr_iss
    k := 0
    do case
      case i ==  1 // {"Клинический анализ мочи","",0,17,{34},{1107,1301,1402,1702},{"4.2.153"}},;
        k := 2
      case i ==  2 // {"Клинический анализ крови","",0,17,{34},{1107,1301,1402,1702},{"4.11.136"}},;
        k := 1
      case i ==  3 // {"Исследование уровня глюкозы в крови","",0,17,{34},{1107,1301,1402,1702},{"4.12.169"}},;
        k := 4
      case i ==  4 // {"Электрокардиография","",0,17,{111},{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},{"13.1.1"}},;
        k := 13
      case i ==  5 // {"Флюорография легких (с 15 лет)","",15,17,{78},{1118,1802},{"7.61.3"}},;
        k := 12
      case i ==  6 // {"УЗИ головного мозга (нейросонография) (до 1 года)","",0,0,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.1.1"}},;
        k := 11
      case i ==  7 // {"УЗИ щитовидной железы (с 7 лет)","",7,17,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.1.2"}},;
        k := 8
      case i ==  8 // {"УЗИ сердца","",0,17,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.1.3"}},;
        k := 7
      case i ==  9 // {"УЗИ тазобедренных суставов (до 1 года)","",0,0,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.1.4"}},;
        k := 10
      case i == 10 // {"УЗИ органов брюшной полости комплексное профилактическое","",0,17,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.2.1"}},;
        k := 6
      case i == 11 // {"УЗИ органов репродуктивной системы","",7,17,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.2.2","8.2.3"}};
        k := 9
    endcase
    mvart := "MTAB_NOMiv"+lstr(i)
    mvard := "MDATEi"+lstr(i)
    mvarr := "MREZi"+lstr(i)
    if between(mvozrast,dds_arr_iss[i,3],dds_arr_iss[i,4])
      if !emptyany(&mvard,&mvart)
        aadd(arr, {dds_arr_iss[i,1], &mvard, &mvarr, i, k})
      endif
    endif
  next
endif
return arr

*

***** 28.01.15
Function inf_DDS_svod(par,par2,is_schet)
Local arr_m, i, buf := save_maxrow(), lkod_h, lkod_k, rec
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  if f0_inf_DDS(arr_m,is_schet > 1,is_schet == 3)
    adbf := {;
     {"nomer"    ,   "N",     6,     0},;
     {"KOD"      ,   "N",     7,     0},; // код (номер записи)
     {"KOD_K"    ,   "N",     7,     0},; // код по картотеке
     {"FIO"      ,   "C",    50,     0},; // Ф.И.О. больного
     {"DATE_R"   ,   "D",     8,     0},; // дата рождения больного
     {"N_DATA"   ,   "D",     8,     0},; // дата начала лечения
     {"K_DATA"   ,   "D",     8,     0},; // дата окончания лечения
     {"sroki"    ,   "C",    11,     0},; // сроки лечения
     {"noplata"  ,   "N",     1,     0},; //
     {"oplata"   ,   "C",    30,     0},; // оплата
     {"CENA_1"   ,   "N",    10,     2},; // оплачиваемая сумма лечения
     {"KOD_DIAG" ,   "C",     5,     0},; // шифр 1-ой осн.болезни
     {"etap"     ,   "N",     1,     0},; //
     {"gruppa_do",   "N",     1,     0},; //
     {"gruppa"   ,   "N",     1,     0},; //
     {"gd1"      ,   "C",     1,     0},; //
     {"gd2"      ,   "C",     1,     0},; //
     {"gd3"      ,   "C",     1,     0},; //
     {"gd4"      ,   "C",     1,     0},; //
     {"gd5"      ,   "C",     1,     0},; //
     {"g1"       ,   "C",     1,     0},; //
     {"g2"       ,   "C",     1,     0},; //
     {"g3"       ,   "C",     1,     0},; //
     {"g4"       ,   "C",     1,     0},; //
     {"g5"       ,   "C",     1,     0},; //
     {"vperv"    ,   "C",     1,     0},; //
     {"dispans"  ,   "C",     1,     0},; //
     {"n1"       ,   "C",     1,     0},; //
     {"n2"       ,   "C",     1,     0},; //
     {"n3"       ,   "C",     1,     0},; //
     {"p1"       ,   "C",     1,     0},; //
     {"p2"       ,   "C",     1,     0},; //
     {"p3"       ,   "C",     1,     0},; //
     {"f1"       ,   "C",     1,     0},; //
     {"f2"       ,   "C",     1,     0},; //
     {"f3"       ,   "C",     1,     0},; //
     {"f4"       ,   "C",     1,     0},; //
     {"f5"       ,   "C",     1,     0}; //
    }
    for i := 1 to count_dds_arr_iss
      aadd(adbf,{"di_"+lstr(i),"C",8,0})
    next
    for i := 1 to count_dds_arr_osm1
      aadd(adbf,{"d1_"+lstr(i),"C",8,0})
    next
    aadd(adbf,{"d1_zs","C",8,0})
    for i := 1 to count_dds_arr_osm2
      aadd(adbf,{"d2_"+lstr(i),"C",8,0})
    next
    dbcreate(cur_dir+"tmpfio",adbf)
    R_Use(dir_server+"mo_rak",,"RAK")
    R_Use(dir_server+"mo_raks",,"RAKS")
    set relation to akt into RAK
    R_Use(dir_server+"mo_raksh",,"RAKSH")
    set relation to kod_raks into RAKS
    index on str(kod_h,7)+dtos(rak->DAKT) to (cur_dir+"tmp_raksh")
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            R_Use(cur_dir+"tmp"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    do while .t.
      eval(blk_open)
      if rec == NIL
        go top
      else
        goto (rec)
        skip
        if eof()
          exit
        endif
      endif
      rec := tmp->(recno())
      @ maxrow(),0 say str(rec/tmp->(lastrec())*100,6,2)+"%" color cColorWait
      lkod_h := human->kod
      lkod_k := human->kod_k
      close databases
      oms_sluch_DDS(p_tip_lu,lkod_h,lkod_k,"f2_inf_DDS_svod")
    enddo
    close databases
    delFRfiles()
    R_Use(dir_server+"organiz",,"ORG")
    adbf := {{"name","C",130,0},;
             {"nomer","N",6,0},;
             {"kol_opl","N",6,0},;
             {"CENA_1","N",15,2},;
             {"period","C",250,0},;
             {"period2","C",50,0},;
             {"kol2","C",60,0},;
             {"kol3","C",60,0},;
             {"kol4","C",60,0},;
             {"gd1"      ,   "N",     8,     0},; //
             {"gd2"      ,   "N",     8,     0},; //
             {"gd3"      ,   "N",     8,     0},; //
             {"gd4"      ,   "N",     8,     0},; //
             {"gd5"      ,   "N",     8,     0},; //
             {"g1"       ,   "N",     8,     0},; //
             {"g2"       ,   "N",     8,     0},; //
             {"g3"       ,   "N",     8,     0},; //
             {"g4"       ,   "N",     8,     0},; //
             {"g5"       ,   "N",     8,     0},; //
             {"vperv"    ,   "N",     8,     0},; //
             {"dispans"  ,   "N",     8,     0},; //
             {"n1"       ,   "N",     8,     0},; //
             {"n2"       ,   "N",     8,     0},; //
             {"n3"       ,   "N",     8,     0},; //
             {"p1"       ,   "N",     8,     0},; //
             {"p2"       ,   "N",     8,     0},; //
             {"p3"       ,   "N",     8,     0},; //
             {"f1"       ,   "N",     8,     0},; //
             {"f2"       ,   "N",     8,     0},; //
             {"f3"       ,   "N",     8,     0},; //
             {"f4"       ,   "N",     8,     0},; //
             {"f5"       ,   "N",     8,     0}}
    for i := 1 to count_dds_arr_iss
      aadd(adbf,{"di_"+lstr(i),"N",8,0})
    next
    for i := 1 to count_dds_arr_osm1
      aadd(adbf,{"d1_"+lstr(i),"N",8,0})
    next
    aadd(adbf,{"d1_zs","N",8,0})
    for i := 1 to count_dds_arr_osm2
      aadd(adbf,{"d2_"+lstr(i),"N",8,0})
    next
    dbcreate(fr_titl, adbf)
    use (fr_titl) new alias FRT
    append blank
    frt->name := glob_mo[_MO_SHORT_NAME]
    frt->period := iif(p_tip_lu==TIP_LU_DDS,;
      "пребывающих в стационарных условиях детей-сирот и детей, находящихся в трудной жизненной ситуации",;
      "детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновлённых (удочерённых), принятых под опеку (попечительство), в приёмную или патронатную семью")
    frt->period2 := arr_m[4]
    if par2 == 1
      frt->kol2 := "Ф.И.О"
      frt->kol3 := "Дата рождения"
      frt->kol4 := "Дата начала диспансеризации"
    else
      frt->kol2 := "Наименование медицинской организации"
      frt->kol3 := "Плановые показатели"
      frt->kol4 := "Фактические показатели выполнения: осмотрено/обработано карт"
    endif
    copy file ("tmpfio"+sdbf) to (fr_data+sdbf)
    do case
      case par == 1
        use (fr_data) new alias FRD
        index on dtos(n_data)+upper(fio) to (fr_data)
        go top
        j := 0
        do while !eof()
          frd->nomer := ++j
          select FRT
          frt->nomer := frd->nomer
          frt->kol_opl += frd->noplata
          frt->cena_1 += frd->cena_1
          for i := 1 to count_dds_arr_iss
            poled := "frd->di_"+lstr(i)
            polet := "frt->di_"+lstr(i)
            if !empty(&poled)
              &polet := &polet + 1
            endif
          next
          for i := 1 to count_dds_arr_osm1
            poled := "frd->d1_"+lstr(i)
            polet := "frt->d1_"+lstr(i)
            if !empty(&poled)
              &polet := &polet + 1
            endif
          next
          if !empty(frd->d1_zs)
            frt->d1_zs ++
          endif
          for i := 1 to count_dds_arr_osm2
            poled := "frd->d2_"+lstr(i)
            polet := "frt->d2_"+lstr(i)
            if !empty(&poled)
              &polet := &polet + 1
            endif
          next
          select FRD
          skip
        enddo
        close databases
        call_fr("mo_ddsTF")
      case par == 2
        use (fr_data) new alias FRD
        index on dtos(n_data)+upper(fio) to (fr_data)
        go top
        j := 0
        do while !eof()
          frd->nomer := ++j
          select FRT
          frt->nomer := frd->nomer
          for i := 1 to 5
            poled := "frd->gd"+lstr(i)
            polet := "frt->gd"+lstr(i)
            if !empty(&poled)
              &polet := &polet + 1
            endif
          next
          for i := 1 to 5
            poled := "frd->g"+lstr(i)
            polet := "frt->g"+lstr(i)
            if !empty(&poled)
              &polet := &polet + 1
            endif
          next
          if !empty(frd->vperv)
            frt->vperv ++
          endif
          if !empty(frd->dispans)
            frt->dispans ++
          endif
          if !empty(frd->n1)
            frt->n1 ++
          endif
          if !empty(frd->n2)
            frt->n2 ++
          endif
          if !empty(frd->n3)
            frt->n3 ++
          endif
          if !empty(frd->f1)
            frt->f1 ++
          endif
          if !empty(frd->f3)
            frt->f3 ++
          endif
          if !empty(frd->f4)
            frt->f4 ++
          endif
          if !empty(frd->f5)
            frt->f5 ++
          endif
          select FRD
          skip
        enddo
        if par2 == 2
          select FRD
          zap
        endif
        close databases
        call_fr("mo_ddsMZ",iif(par2==2,3,))
    endcase
  endif
endif
close databases
rest_box(buf)
return NIL

*

***** 04.05.16
Function f2_inf_DDS_svod(Loc_kod,kod_kartotek) // сводная информация
Local i := 0, c, s := "НЕТ акта", pole, arr, ddo := {}, dposle := {}
R_Use(dir_server+"mo_rak",,"RAK")
R_Use(dir_server+"mo_raks",,"RAKS")
set relation to akt into RAK
R_Use(dir_server+"mo_raksh",,"RAKSH")
set relation to kod_raks into RAKS
set index to (cur_dir+"tmp_raksh")
select RAKSH
find (str(Loc_kod,7))
do while Loc_kod == raksh->kod_h .and. !eof()
  if round(raksh->sump,2) == round(mCENA_1,2)
    i := 1
    s := "оплачен"
  else
    i := 0
    s := "НЕ опл.: акт "+alltrim(rak->NAKT)+" от "+date_8(rak->DAKT)
  endif
  skip
enddo
use (cur_dir+"tmpfio") new alias TF
append blank
tf->KOD := Loc_kod
tf->KOD_K := kod_kartotek
tf->FIO := mfio
tf->DATE_R := mdate_r
tf->N_DATA := mN_DATA
tf->K_DATA := mK_DATA
tf->sroki := left(date_8(mN_DATA),5)+"-"+left(date_8(mK_DATA),5)
tf->noplata := i
tf->oplata := s
tf->CENA_1 := mCENA_1
tf->KOD_DIAG := mkod_diag
tf->etap := metap
tf->gruppa_do := mgruppa_do
if between(mgruppa_do,1,5)
  pole := "tf->gd"+lstr(mgruppa_do)
  &pole := "X"
endif
tf->gruppa := mgruppa
if between(mgruppa,1,5)
  pole := "tf->g"+lstr(mgruppa)
  &pole := "X"
endif
for i := 1 to 5
  pole := "mdiag_16_"+lstr(i)+"_1"
  if !empty(&pole)
    aadd(ddo,alltrim(&pole))
  endif
next
for i := 1 to 5
  pole := "mdiag_16_"+lstr(i)+"_1"
  if !empty(&pole)
    aadd(dposle,alltrim(&pole))
    pole := "m1diag_16_"+lstr(i)+"_2"
    if &pole == 1
      tf->vperv := "X"
    endif
    pole := "m1diag_16_"+lstr(i)+"_3"
    if &pole == 2
      tf->dispans := "X"
    endif
    pole := "m1diag_16_"+lstr(i)+"_13"
    if &pole == 1
      tf->n2 := "X"
      pole := "m1diag_16_"+lstr(i)+"_15"
      if &pole == 4
        tf->n1 := "X"
      endif
    endif
    pole := "m1diag_16_"+lstr(i)+"_16"
    if &pole == 1
      tf->n3 := "X"
    endif
  endif
next
for i := 1 to len(ddo)
  c := left(ddo[i],3)
  if between(c,"F00","F69") .or. between(c,"F80","F99")
    tf->f3 := "X"
  endif
next
for i := 1 to len(dposle)
  if ascan(ddo,dposle[i]) == 0
    tf->f1 := "X"
  endif
  c := left(dposle[i],3)
  if between(c,"F00","F69") .or. between(c,"F80","F99")
    tf->f4 := "X"
  endif
next
if !empty(tf->f3) .and. empty(tf->f4)
  tf->f5 := "X"
endif
arr := f4_inf_DDS_karta(1,1)
for i := 1 to len(arr)
  pole := "tf->d1_"+lstr(arr[i,4])
  &pole := date_8(arr[i,2])
next
tf->d1_zs := mshifr_zs
arr := f4_inf_DDS_karta(1,2,1) // стоматолог и эндокринолог на 2 этапе
for i := 1 to len(arr)
  pole := "tf->d1_"+lstr(arr[i,4])
  &pole := date_8(arr[i,2])
next
arr := f4_inf_DDS_karta(1,2,2) // остальные приёмы на 2 этапе
for i := 1 to len(arr)
  pole := "tf->d2_"+lstr(arr[i,4])
  &pole := date_8(arr[i,2])
next
arr := f4_inf_DDS_karta(2)
for i := 1 to len(arr)
  pole := "tf->di_"+lstr(arr[i,4])
  &pole := date_8(arr[i,2])
next
return NIL

*

***** 08.11.13
Function inf_DDS_030dso(is_schet)
Local arr_m, i, n, buf := save_maxrow(), lkod_h, lkod_k, rec,;
      sh := 80, HH := 80, n_file := "f_030dso"+stxt, d1, d2
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  if f0_inf_DDS(arr_m,is_schet > 1,is_schet == 3)
    Private arr_deti[5] ; afill(arr_deti,0)
    Private s12_1 := 0, s12_1m := 0, s12_2 := 0, s12_2m := 0
    Private arr_vozrast := {;
      {4, 0, 4},;
      {5, 5, 9},;
      {6,10,14},;
      {7,15,17},;
      {8, 0,14},;
      {9, 0,17};
     }
    Private arr1vozrast := {;
      { 0,17},;
      { 0,14},;
      { 0, 4},;
      { 5, 9},;
      {10,14},;
      {15,17};
     }
    Private arr_4 := {;
      {"1","Некоторые инфекционные и паразит...","A00-B99",,},;
      {"1.1","туберкулез","A15-A19",,},;
      {"1.2","ВИЧ-инфекция, СПИД","B20-B24",,},;
      {"2","Новообразования","C00-D48",,},;
      {"3","Болезни крови и кроветворных органов ...","D50-D89",,},;
      {"3.1","анемии","D50-D53",,},;
      {"4","Болезни эндокринной системы, расстройства...","E00-E90",,},;
      {"4.1","сахарный диабет","E10-E14",,},;
      {"4.2","недостаточность питания","E40-E46",,},;
      {"4.3","ожирение","E66",,},;
      {"4.4","задержка полового развития","E30.0",,},;
      {"4.5","преждевременное половое развитие","E30.1",,},;
      {"5","Психические расстройства и расстро...","F00-F99",,},;
      {"5.1","умственная отсталость","F70-F79",,},;
      {"6","Болезни нервной системы, из них:","G00-G98",,},;
      {"6.1","церебральный паралич и другие ...","G80-G83",,},;
      {"7","Болезни глаза и его придаточного аппарата","H00-H59",,},;
      {"8","Болезни уха и сосцевидного отростка","H60-H95",,},;
      {"9","Болезни системы кровообращения","I00-I99",,},;
      {"10","Болезни органов дыхания, из них:","J00-J99",,},;
      {"10.1","астма, астматический статус","J45-J46",,},;
      {"11","Болезни органов пищеварения","K00-K93",,},;
      {"12","Болезни кожи и подкожной клетчатки","L00-L99",,},;
      {"13","Болезни костно-мышечной ...","M00-M99",,},;
      {"13.1","кифоз, лордоз, сколиоз","M40-M41",,},;
      {"14","Болезни мочеполовой системы, из них:","N00-N99",,},;
      {"14.1","болезни мужских половых органов","N40-N51",,},;
      {"14.2","нарушения ритма и характера менструаций","N91-N94.5",,},;
      {"14.3","воспалительные заболевания ...","N70-N77",,},;
      {"14.4","невоспалительные болезни ...","N83-N83.9",,},;
      {"14.5","болезни молочной железы","N60-N64",,},;
      {"15","Отдельные состояния, возника...","P00-P96",,},;
      {"16","Врожденные аномалии (пороки ...","Q00-Q99",,},;
      {"16.1","развития нервной системы","Q00-Q07",,},;
      {"16.2","системы кровообращения","Q20-Q28",,},;
      {"16.3","костно-мышечной системы","Q65-Q79",,},;
      {"16.4","женских половых органов","Q50-Q52",,},;
      {"16.5","мужских половых органов","Q53-Q55",,},;
      {"17","Травмы, отравления и некоторые...","S00-T98",,},;
      {"18","Прочие","",,},;
      {"19","ВСЕГО ЗАБОЛЕВАНИЙ","A00-T98",,};
     }
    for n := 1 to len(arr_4)
      if "-" $ arr_4[n,3]
        d1 := token(arr_4[n,3],"-",1)
        d2 := token(arr_4[n,3],"-",2)
      else
        d1 := d2 := arr_4[n,3]
      endif
      arr_4[n,4] := diag_to_num(d1,1)
      arr_4[n,5] := diag_to_num(d2,2)
    next
    dbcreate(cur_dir+"tmp4",{{"name","C",100,0},;
                     {"diagnoz","C",20,0},;
                     {"stroke","C",4,0},;
                     {"ns","N",2,0},;
                     {"diapazon1","N",10,0},;
                     {"diapazon2","N",10,0},;
                     {"tbl","N",1,0},;
                     {"k04","N",8,0},;
                     {"k05","N",8,0},;
                     {"k06","N",8,0},;
                     {"k07","N",8,0},;
                     {"k08","N",8,0},;
                     {"k09","N",8,0},;
                     {"k10","N",8,0},;
                     {"k11","N",8,0}})
    use (cur_dir+"tmp4") new alias TMP
    for i := 1 to len(arr_vozrast)
      for n := 1 to len(arr_4)
        append blank
        tmp->tbl := arr_vozrast[i,1]
        tmp->stroke := arr_4[n,1]
        tmp->name := arr_4[n,2]
        tmp->ns := n
        tmp->diagnoz := arr_4[n,3]
        tmp->diapazon1 := arr_4[n,4]
        tmp->diapazon2 := arr_4[n,5]
      next
    next
    index on str(tbl,1)+str(ns,2) to (cur_dir+"tmp4")
    use
    dbcreate(cur_dir+"tmp10",{{"voz","N",1,0},;
                      {"tbl","N",2,0},;
                      {"tip","N",1,0},;
                      {"kol","N",6,0}})
    use (cur_dir+"tmp10") new alias TMP10
    index on str(voz,1)+str(tbl,1)+str(tip,1) to (cur_dir+"tmp10")
    use
    copy file tmp10.dbf to tmp11.dbf
    use (cur_dir+"tmp11") new alias TMP11
    index on str(voz,1)+str(tbl,2)+str(tip,1) to (cur_dir+"tmp11")
    use
    dbcreate(cur_dir+"tmp13",{{"voz","N",1,0},;
                      {"tip","N",2,0},;
                      {"kol","N",6,0}})
    use (cur_dir+"tmp13") new alias TMP13
    index on str(voz,1)+str(tip,2) to (cur_dir+"tmp13")
    use
    dbcreate(cur_dir+"tmp16",{{"voz","N",1,0},;
                      {"man","N",1,0},;
                      {"tip","N",2,0},;
                      {"kol","N",6,0}})
    use (cur_dir+"tmp16") new alias TMP16
    index on str(voz,1)+str(man,1)+str(tip,2) to (cur_dir+"tmp16")
    use
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            R_Use(cur_dir+"tmp"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    do while .t.
      eval(blk_open)
      if rec == NIL
        go top
      else
        goto (rec)
        skip
        if eof()
          exit
        endif
      endif
      rec := tmp->(recno())
      @ maxrow(),0 say str(rec/tmp->(lastrec())*100,6,2)+"%" color cColorWait
      lkod_h := human->kod
      lkod_k := human->kod_k
      close databases
      oms_sluch_DDS(p_tip_lu,lkod_h,lkod_k,"f2_inf_DDS_030dso")
    enddo
    close databases
    fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
    add_string(glob_mo[_MO_SHORT_NAME])
    add_string(padl("Приложение 3",sh))
    add_string(padl("к Приказу МЗРФ",sh))
    add_string(padl("№72н от 15.02.2013г.",sh))
    add_string("")
    add_string(padl("Отчетная форма № 030-Д/с/о-13",sh))
    add_string("")
    add_string(center("Сведения о диспансеризации несовершеннолетних,",sh))
    if p_tip_lu == TIP_LU_DDS
      add_string(center("пребывающих в стационарных условиях детей-сирот и детей,",sh))
      add_string(center("находящихся в трудной жизненной ситуации",sh))
    else
      add_string(center("детей-сирот и детей, оставшихся без попечения родителей, в том числе",sh))
      add_string(center("усыновлённых (удочерённых), принятых под опеку (попечительство),",sh))
      add_string(center("в приёмную или патронатную семью",sh))
    endif
    add_string(center("[ "+charrem("~",mas1pmt[is_schet])+" ]",sh))
    add_string(center(arr_m[4],sh))
    add_string("")
    add_string("2. Число детей, прошедших диспансеризацию в отчетном периоде:")
    add_string("  2.1. всего в возрасте от 0 до 17 лет включительно:"+str(arr_deti[1],6)+" (человек), из них:")
    add_string("  2.1.1. в возрасте от 0 до 4 лет включительно      "+str(arr_deti[2],6)+" (человек),")
    add_string("  2.1.2. в возрасте от 5 до 9 лет включительно      "+str(arr_deti[3],6)+" (человек),")
    add_string("  2.1.3. в возрасте от 10 до 14 лет включительно    "+str(arr_deti[4],6)+" (человек),")
    add_string("  2.1.4. в возрасте от 15 до 17 лет включительно    "+str(arr_deti[5],6)+" (человек).")
    for i := 1 to len(arr_vozrast)
      verify_FF(HH-50, .t., sh)
      add_string("")
      add_string(center(lstr(arr_vozrast[i,1])+;
                 ". Структура выявленных заболеваниях (сосотояний) у детей в возрасте от "+;
                 lstr(arr_vozrast[i,2])+" до "+lstr(arr_vozrast[i,3])+" лет включительно",sh))
      add_string("────┬───────────────────┬───────┬─────┬─────┬─────┬─────┬───────────────────────")
      add_string(" №№ │    Наименование   │ Код по│Всего│в т.ч│выяв-│в т.ч│Состоит под дисп.наблюд")
      add_string(" пп │    заболеваний    │ МКБ-10│зарег│маль-│лено │маль-├─────┬─────┬─────┬─────")
      add_string("    │                   │       │забол│чики │вперв│чики │всего│мальч│взято│мальч")
      add_string("────┼───────────────────┼───────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────")
      add_string(" 1  │          2        │   3   │  4  │  5  │  6  │  7  │  8  │  9  │ 10  │ 11  ")
      add_string("────┴───────────────────┴───────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────")
      use (cur_dir+"tmp4") index (cur_dir+"tmp4") new alias TMP
      find (str(arr_vozrast[i,1],1))
      do while tmp->tbl == arr_vozrast[i,1] .and. !eof()
        s := tmp->stroke+" "+padr(tmp->name,19)+" "+padc(alltrim(tmp->diagnoz),7)
        for n := 4 to 11
          s += put_val(tmp->&("k"+strzero(n,2)),6)
        next
        add_string(s)
        skip
      enddo
      use
      add_string(replicate("─",sh))
    next
    arr1title := {;
      "────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────",;
      "                    │   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных ",;
      "  Возраст детей     │           │           │субъекта РФ│  ных ГУЗ  │    МО     ",;
      "                    │           │           │           │           │           ",;
      "────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────",;
      "          1         │     2     │     3     │     4     │     5     │     6     ",;
      "────────────────────┴───────────┴───────────┴───────────┴───────────┴───────────"}
    arr2title := {;
      "────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────",;
      "                    │   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных ",;
      "  Возраст детей     ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────",;
      "                    │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ",;
      "────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────",;
      "          1         │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 ",;
      "────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"}
    arr3title := {;
      "────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────",;
      " Возраст│   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных │в санаторно",;
      " детей  │           │           │субъекта РФ│  ных ГУЗ  │    МО     │-курортных ",;
      "        │           │           │           │           │           │организ-ях ",;
      "────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────",;
      "    1   │     2     │     3     │     4     │     5     │     6     │     7     ",;
      "────────┴───────────┴───────────┴───────────┴───────────┴───────────┴───────────"}
    arr4title := {;
      "────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────",;
      " Возраст│   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных │в сан.-кур.",;
      " детей  ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────┼──орг-иях──",;
      "        │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ",;
      "────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────",;
      "    1   │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 ",;
      "────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"}
    verify_FF(HH-50, .t., sh)
    add_string("10. Результаты дополнительных консультаций, исследований, лечения и медицинской")
    add_string("    реабилитации детей по результатам проведения настоящей диспансеризации:")
    use (cur_dir+"tmp10") index (cur_dir+"tmp10") new alias TMP10
    for i := 1 to 8
      verify_FF(HH-16, .t., sh)
      add_string("")
      s := space(5)
      if i == 1
        add_string(s+"10.1. Нуждались в дополнительных консультациях и исследованиях")
        add_string(s+"      в амбулаторных условиях и в условиях дневного стационара")
      elseif i == 2
        add_string(s+"10.2. Прошли дополнительные консультации и исследования")
        add_string(s+"      в амбулаторных условиях и в условиях дневного стационара")
      elseif i == 3
        add_string(s+"10.3. Нуждались в дополнительных консультациях и исследованиях")
        add_string(s+"      в стационарных условиях")
      elseif i == 4
        add_string(s+"10.4. Прошли дополнительные консультации и исследования")
        add_string(s+"      в стационарных условиях")
      elseif i == 5
        add_string(s+"10.5. Рекомендовано лечение в амбулаторных условиях и в условиях")
        add_string(s+"      дневного стационара")
      elseif i == 6
        add_string(s+"10.6. Рекомендовано лечение в стационарных условиях")
      elseif i == 7
        add_string(s+"10.7. Рекомендована медицинская реабилитация")
        add_string(s+"      в амбулаторных условиях и в условиях дневного стационара")
      else
        add_string(s+"10.8. Рекомендованы медицинская реабилитация и (или)")
        add_string(s+"      санаторно-курортное лечение в стационарных условиях")
      endif
      n := 20
      if eq_any(i,1,3,5,6,7)
        aeval(arr1title, {|x| add_string(x) } )
      elseif eq_any(i,2,4)
        aeval(arr2title, {|x| add_string(x) } )
      else
        aeval(arr3title, {|x| add_string(x) } )
        n := 8
      endif
      for j := 1 to len(arr1vozrast)
        s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
        skol := oldkol := 0
        s1 := ""
        for k := 1 to iif(i==8,5,4)
          find (str(j,1)+str(i,1)+str(k,1))
          if found() .and. (v := tmp10->kol) > 0
            skol += v
            if eq_any(i,2,4)
              s1 += str(v,6)
              find (str(j,1)+str(i-1,1)+str(k,1))
              if found() .and. tmp10->kol > 0
                s1 += " "+umest_val(v/tmp10->kol*100,5,2)
                oldkol += tmp10->kol
              else
                s1 += space(6)
              endif
            else
              s1 += " "+padc(lstr(v),11)
            endif
          else
            s1 += space(12)
          endif
        next
        if skol > 0
          if eq_any(i,2,4)
            s += str(skol,6)+" "+umest_val(skol/oldkol*100,5,2)
          else
            s += " "+padc(lstr(skol),11)
          endif
          add_string(s+s1)
        else
          add_string(s)
        endif
      next
      add_string(replicate("─",sh))
    next
    use
    //
    verify_FF(HH-50, .t., sh)
    add_string("11. Результаты лечения, медицинской реабилитации и (или) санаторно-курортного")
    add_string("    лечения детей до проведения настоящей диспансеризации:")
    vkol := 0
    use (cur_dir+"tmp11") index (cur_dir+"tmp11") new alias TMP11
    for i := 1 to 12
      if i % 3 > 0
        verify_FF(HH-16, .t., sh)
        add_string("")
      endif
      s := space(5)
      if i == 1
        add_string(s+"11.1. Рекомендовано лечение в амбулаторных условиях и в условиях")
        add_string(s+"      дневного стационара")
      elseif i == 2
        add_string(s+"11.2. Проведено лечение в амбулаторных условиях и в условиях")
        add_string(s+"      дневного стационара")
      elseif i == 3
        add_string(s+"11.3. Причины невыполнения рекомендаций по лечению в амбулаторных условиях")
        add_string(s+"      и в условиях дневного стационара:")
        add_string(s+"        11.3.1. не прошли всего "+lstr(vkol)+" (человек)")
      elseif i == 4
        add_string(s+"11.4. Рекомендовано лечение в стационарных условиях")
      elseif i == 5
        add_string(s+"11.5. Проведено лечение в стационарных условиях")
      elseif i == 6
        add_string(s+"11.6. Причины невыполнения рекомендаций по лечению в стационарных условиях:")
        add_string(s+"        11.6.1. не прошли всего "+lstr(vkol)+" (человек)")
      elseif i == 7
        add_string(s+"11.7. Рекомендована медицинская реабилитация")
        add_string(s+"      в амбулаторных условиях и в условиях дневного стационара")
      elseif i == 8
        add_string(s+"11.8. Проведена медицинская реабилитация")
        add_string(s+"      в амбулаторных условиях и в условиях дневного стационара")
      elseif i == 9
        add_string(s+"11.9. Причины невыполнения рекомендаций по медицинской реабилитации")
        add_string(s+"      в амбулаторных условиях и в условиях дневного стационара:")
        add_string(s+"        11.9.1. не прошли всего "+lstr(vkol)+" (человек)")
      elseif i == 10
        add_string(s+"11.10. Рекомендованы медицинская реабилитация и (или)")
        add_string(s+"       санаторно-курортное лечение в стационарных условиях")
      elseif i == 11
        add_string(s+"11.11. Проведена медицинская реабилитация и (или)")
        add_string(s+"       санаторно-курортное лечение в стационарных условиях")
      else
        add_string(s+"11.12. Причины невыполнения рекомендаций по медицинской реабилитации")
        add_string(s+"       и (или) санаторно-курортному лечению в стационарных условиях:")
        add_string(s+"         11.12.1. не прошли всего "+lstr(vkol)+" (человек)")
      endif
      if i % 3 > 0
        n := 20
        if eq_any(i,1,4,7)
          aeval(arr1title, {|x| add_string(x) } )
        elseif eq_any(i,2,5,8)
          aeval(arr2title, {|x| add_string(x) } )
        elseif i == 10
          aeval(arr3title, {|x| add_string(x) } )
          n := 8
        elseif i == 11
          aeval(arr4title, {|x| add_string(x) } )
          n := 8
        endif
        for j := 1 to len(arr1vozrast)
          s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
          skol := oldkol := 0
          s1 := ""
          for k := 1 to iif(i>10,5,4)
            find (str(j,1)+str(i,2)+str(k,1))
            if found() .and. (v := tmp11->kol) > 0
              skol += v
              if eq_any(i,2,5,8,11)
                s1 += str(v,6)
                find (str(j,1)+str(i-1,2)+str(k,1))
                if found() .and. tmp11->kol > 0
                  s1 += " "+umest_val(v/tmp11->kol*100,5,2)
                  oldkol += tmp11->kol
                else
                  s1 += space(6)
                endif
              else
                s1 += " "+padc(lstr(v),11)
              endif
            else
              s1 += space(12)
            endif
          next
          if eq_any(i,2,5,8,11)
            vkol := oldkol - skol
          endif
          if skol > 0
            if eq_any(i,2,5,8,11)
              s += str(skol,6)+" "+umest_val(skol/oldkol*100,5,2)
            else
              s += " "+padc(lstr(skol),11)
            endif
            add_string(s+s1)
          else
            add_string(s)
          endif
        next
        add_string(replicate("─",sh))
      endif
    next
    use
    verify_FF(HH-3, .t., sh)
    add_string("")
    add_string("12. Оказание высокотехнологичной медицинской помощи:")
    add_string("  12.1. рекомендована (по итогам настоящей диспанc-ции): "+lstr(s12_1)+" чел., в т.ч. "+lstr(s12_1m)+" мальчикам")
    add_string("  12.2. оказана (по итогам диспансеризации в пред.году): "+lstr(s12_2)+" чел., в т.ч. "+lstr(s12_2m)+" мальчикам")
    use (cur_dir+"tmp13") index (cur_dir+"tmp13") new alias TMP13
    verify_FF(HH-16, .t., sh)
    n := 32
    add_string("")
    add_string("13. Число детей-инвалидов из числа детей, прошедших диспансеризацию")
    add_string("    в отчетном периоде")
    add_string("────────────────────────────────┬───────────┬───────────┬───────────┬─────┬─────")
    add_string("                                │ с рождения│приобретённ│уст.впервые│ чел.│  %  ")
    add_string("         Возраст детей          ├─────┬─────┼─────┬─────┼─────┬─────┤детей│детей")
    add_string("                                │ чел.│  %  │ чел.│  %  │ чел.│  %  │инвал│инвал")
    add_string("────────────────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────")
    add_string("               1                │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  ")
    add_string("────────────────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────")
    for j := 1 to len(arr1vozrast)
      s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
      find (str(j,1)+str(0,2))
      oldkol := iif(found(), tmp13->kol, 0)
      for i := 1 to 4
        find (str(j,1)+str(i,2))
        if found()
          s += str(tmp13->kol,6)+" "+umest_val(tmp13->kol/oldkol*100,5,2)
        else
          s += space(12)
        endif
      next
      add_string(s)
    next
    add_string(replicate("─",sh))
    verify_FF(HH-16, .t., sh)
    n := 26
    add_string("")
    add_string("14. Выполнение индивидуальных программ реабилитации (ИПР) детей-инвалидов")
    add_string("    в отчетном периоде")
    add_string("──────────────────────────┬─────┬───────────┬───────────┬───────────┬───────────")
    add_string("                          │назна│вып.полност│вып.частичн│ ИПР начата│не выполнен")
    add_string("       Возраст детей      │чено ├─────┬─────┼─────┬─────┼─────┬─────┼─────┬─────")
    add_string("                          │ чел.│ чел.│  %  │ чел.│  %  │ чел.│  %  │ чел.│  %  ")
    add_string("──────────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────")
    add_string("             1            │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 ")
    add_string("──────────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────")
    for j := 1 to len(arr1vozrast)
      s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
      find (str(j,1)+str(10,2))
      oldkol := 0
      if found()
        oldkol := tmp13->kol
      endif
      s += put_val(oldkol,6)
      for i := 11 to 14
        find (str(j,1)+str(i,2))
        if found()
          s += str(tmp13->kol,6)+" "+umest_val(tmp13->kol/oldkol*100,5,2)
        else
          s += space(12)
        endif
      next
      add_string(s)
    next
    add_string(replicate("─",sh))
    verify_FF(HH-15, .t., sh)
    n := 20
    add_string("")
    add_string("15. Охват профилактическими прививками в отчетном периоде")
    add_string("────────────────────┬───────────┬───────────────────────┬───────────────────────")
    add_string("                    │  Привито  │Не привиты по мед.показ│Не привиты по друг.прич")
    add_string("    Возраст детей   │    чел.   ├───────────┬───────────┼───────────┬───────────")
    add_string("                    │           │ полностью │ частично  │ полностью │ частично  ")
    add_string("────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────")
    add_string("          1         │     2     │     3     │     4     │     5     │     6     ")
    add_string("────────────────────┴───────────┴───────────┴───────────┴───────────┴───────────")
    for j := 1 to len(arr1vozrast)
      s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
      find (str(j,1)+str(20,2))
      if found()
        s += " "+padc(lstr(tmp13->kol),11)
      else
        s += space(12)
      endif
      for i := 21 to 24
        find (str(j,1)+str(i,2))
        if found()
          s += " "+padc(lstr(tmp13->kol),11)
        else
          s += space(12)
        endif
      next
      add_string(s)
    next
    add_string(replicate("─",sh))
    use (cur_dir+"tmp16") index (cur_dir+"tmp16") new alias TMP16
    verify_FF(HH-21, .t., sh)
    n := 20
    add_string("")
    add_string("16. Распределение детей по уровню физического развития")
    add_string("────────────────────┬─────────┬─────────┬───────────────────────────────────────")
    add_string("                    │Число про│Норм.физ.│ Отклонения физического развития (чел.)")
    add_string("    Возраст детей   │шедших ди│развитие ├─────────┬─────────┬─────────┬─────────")
    add_string("                    │спансериз│   чел.  │дефиц.мас│избыт.мас│низк.рост│высо.рост")
    add_string("────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────")
    add_string("          1         │    2    │    3    │    4    │    5    │    6    │    7    ")
    add_string("────────────────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────")
    for j := 1 to len(arr1vozrast)
      for k := 0 to 1
        s := padr(" "+lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2])+;
                  iif(k==0,""," (мальчики)"),n)
        find (str(j,1)+str(k,1)+str(0,2))
        if found()
          s += " "+padc(lstr(tmp16->kol),9)
        else
          s += space(10)
        endif
        for i := 1 to 5
          find (str(j,1)+str(k,1)+str(i,2))
          if found()
            s += " "+padc(lstr(tmp16->kol),9)
          else
            s += space(10)
          endif
        next
        add_string(s)
      next
    next
    add_string(replicate("─",sh))
    verify_FF(HH-21, .t., sh)
    n := 20
    add_string("")
    add_string("17. Распределение детей по группам состояния здоровья")
    add_string("────────────────────┬─────────┬────────────────────────┬────────────────────────")
    add_string("                    │Число про│ до диспансеризации     │ по результатам дисп-ии ")
    add_string("    Возраст детей   │шедших ди├────┬────┬────┬────┬────┼────┬────┬────┬────┬────")
    add_string("                    │спансериз│ I  │ II │ III│ IV │ V  │ I  │ II │ III│ IV │ V  ")
    add_string("────────────────────┼─────────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────")
    add_string("          1         │    2    │ 3  │ 4  │ 5  │ 6  │ 7  │ 8  │ 9  │ 10 │ 11 │ 12 ")
    add_string("────────────────────┴─────────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────")
    for j := 1 to len(arr1vozrast)
      for k := 0 to 1
        s := padr(" "+lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2])+;
                  iif(k==0,""," (мальчики)"),n)
        find (str(j,1)+str(k,1)+str(0,2))
        if found()
          s += " "+padc(lstr(tmp16->kol),9)
        else
          s += space(10)
        endif
        for i := 11 to 15
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        for i := 21 to 25
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        add_string(s)
      next
    next
    add_string(replicate("─",sh))
    fclose(fp)
    viewtext(n_file,,,,.f.,,,5)
  endif
endif
close databases
rest_box(buf)
return NIL

*

***** 08.11.13
Function f2_inf_DDS_030dso(Loc_kod,kod_kartotek) // сводная информация
Local i, j, k, av := {}, av1 := {}, ad := {}, arr, s, fl, ;
      is_man := (mpol == "М"), blk_tbl, blk_tip, blk_put_tip, ;
      a10[9], a11[13]
blk_tbl := {|_k| iif(_k < 2, 1, 2) }
blk_tip := {|_k| iif(_k == 0, 2, iif(_k > 1, _k+1, _k)) }
blk_put_tip := {|_e,_k| iif(_k > _e, _k, _e) }
arr_deti[1] ++
if mvozrast < 5
  arr_deti[2] ++
elseif mvozrast < 10
  arr_deti[3] ++
elseif mvozrast < 15
  arr_deti[4] ++
else
  arr_deti[5] ++
endif
for i := 1 to len(arr_vozrast)
  if between(mvozrast,arr_vozrast[i,2],arr_vozrast[i,3])
    aadd(av,arr_vozrast[i,1]) // список таблиц с 4 по 9
  endif
next
for i := 1 to len(arr1vozrast)
  if between(mvozrast,arr1vozrast[i,1],arr1vozrast[i,2])
    aadd(av1,i)
  endif
next
for i := 1 to 5
  j := 0
  for k := 1 to 16
    s := "diag_16_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      if !empty(&mvar)
        arr := array(16) ; afill(arr,0) ; arr[1] := alltrim(&mvar)
        if len(arr[1]) > 5
          arr[1] := left(arr[1],5)
        endif
        aadd(ad,arr) ; j := len(ad)
      endif
    elseif j > 0
      m1var := "m1"+s
      ad[j,k] := &m1var
    endif
  next
next
use (cur_dir+"tmp4") index (cur_dir+"tmp4") new alias TMP
use (cur_dir+"tmp10") index (cur_dir+"tmp10") new alias TMP10
afill(a10,0)
for i := 1 to len(ad) // цикл по диагнозам
  au := {}
  d := diag_to_num(ad[i,1],1)
  for n := 1 to len(arr_4)
    if !empty(arr_4[n,3]) .and. between(d,arr_4[n,4],arr_4[n,5])
      aadd(au,n)
    endif
  next
  if len(au) == 1
    aadd(au,len(arr_4)-1)  // {"18","Прочие","",,},;
  endif
  select TMP
  for n := 1 to len(av) // цикл по списку таблиц с 4 по 9
    for j := 1 to len(au)
      find (str(av[n],1)+str(au[j],2))
      if found()
        tmp->k04 ++
        if is_man
          tmp->k05 ++
        endif
        if ad[i,2] > 0 // уст.впервые
          tmp->k06 ++
          if is_man
            tmp->k07 ++
          endif
        endif
        if ad[i,3] > 0 // дисп.набл.установлено
          tmp->k08 ++
          if is_man
            tmp->k09 ++
          endif
          if ad[i,3] == 2 // дисп.набл.установлено впервые
            tmp->k10 ++
            if is_man
              tmp->k11 ++
            endif
          endif
        endif
      endif
    next
  next
  if ad[i,4] == 1 // 1-доп.конс.назначены
    ntbl := eval(blk_tbl,ad[i,5])
    ntip := eval(blk_tip,ad[i,6])
    if ntbl == 1 .and. a10[3] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a10[1] := 0
      a10[3] := eval(blk_put_tip,a10[3],ntip)
    else
      a10[1] := eval(blk_put_tip,a10[1],ntip)
      a10[3] := 0
    endif
  endif
  if ad[i,7] == 1 // 1-доп.конс.выполнены
    ntbl := eval(blk_tbl,ad[i,8])
    ntip := eval(blk_tip,ad[i,9])
    if ntbl == 1 .and. a10[4] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a10[2] := 0
      a10[4] := eval(blk_put_tip,a10[4],ntip)
    else
      a10[2] := eval(blk_put_tip,a10[2],ntip)
      a10[4] := 0
    endif
  endif
  if ad[i,10] == 1 // 1-лечение назначено
    ntbl := eval(blk_tbl,ad[i,11])
    ntip := eval(blk_tip,ad[i,12])
    if ntbl == 1 .and. a10[6] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a10[5] := 0
      a10[6] := eval(blk_put_tip,a10[6],ntip)
    else
      a10[5] := eval(blk_put_tip,a10[5],ntip)
      a10[6] := 0
    endif
  endif
  if ad[i,13] == 1 // 1-реабил.назначена
    ntbl := eval(blk_tbl,ad[i,14])
    ntip := eval(blk_tip,ad[i,15])
    if ntbl == 1 .and. a10[8] > 0 // уже есть стационар
      //
    elseif ntbl == 2 .or. ntip == 5 // или санаторий
      a10[7] := 0
      a10[8] := eval(blk_put_tip,a10[8],ntip)
    else
      a10[7] := eval(blk_put_tip,a10[7],ntip)
      a10[8] := 0
    endif
  endif
  if ad[i,16] == 1 // 1-ВМП назначена
    a10[9] := 1
  endif
next
select TMP10
for n := 1 to len(av1) // цикл по возрастам таблиц 10
  for j := 1 to len(a10)-1
    if a10[j] > 0
      find (str(av1[n],1)+str(j,1)+str(a10[j],1))
      if !found()
        append blank
        tmp10->voz := av1[n]
        tmp10->tbl := j
        tmp10->tip := a10[j]
      endif
      tmp10->kol ++
    endif
  next
next
ad := {}
for i := 1 to 5
  j := 0
  for k := 1 to 14
    s := "diag_15_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      if !empty(&mvar)
        arr := array(14) ; afill(arr,0) ; arr[1] := alltrim(&mvar)
        if len(arr[1]) > 5
          arr[1] := left(arr[1],5)
        endif
        aadd(ad,arr) ; j := len(ad)
      endif
    elseif j > 0
      m1var := "m1"+s
      ad[j,k] := &m1var
    endif
  next
next
use (cur_dir+"tmp11") index (cur_dir+"tmp11") new alias TMP11
afill(a11,0)
for i := 1 to len(ad) // цикл по диагнозам
  if ad[i,3] == 1 // 1-лечение назначено
    ntbl := eval(blk_tbl,ad[i,4])
    ntip := eval(blk_tip,ad[i,5])
    if ntbl == 1 .and. a11[4] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a11[1] := 0
      a11[4] := eval(blk_put_tip,a11[4],ntip)
    else
      a11[1] := eval(blk_put_tip,a11[1],ntip)
      a11[4] := 0
    endif
    // лечение выполнено
    ntbl := eval(blk_tbl,ad[i,6])
    ntip := eval(blk_tip,ad[i,7])
    if ntbl == 1 .and. a11[5] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a11[2] := 0
      a11[5] := eval(blk_put_tip,a11[5],ntip)
    else
      a11[2] := eval(blk_put_tip,a11[2],ntip)
      a11[5] := 0
    endif
  endif
  if ad[i,8] == 1 // 1-реабил.назначена
    ntbl := eval(blk_tbl,ad[i,9])
    ntip := eval(blk_tip,ad[i,10])
    if ntbl == 1 .and. a11[10] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a11[ 7] := 0
      a11[10] := eval(blk_put_tip,a11[10],ntip)
    else
      a11[ 7] := eval(blk_put_tip,a11[7],ntip)
      a11[10] := 0
    endif
    // 1-реабил.выполнена
    ntbl := eval(blk_tbl,ad[i,11])
    ntip := eval(blk_tip,ad[i,12])
    if ntbl == 1 .and. a11[11] > 0 // уже есть стационар
      //
    elseif ntbl == 2 .or. ntip == 5 // или санаторий
      a11[ 8] := 0
      a11[11] := eval(blk_put_tip,a11[11],ntip)
    else
      a11[ 8] := eval(blk_put_tip,a11[8],ntip)
      a11[11] := 0
    endif
  endif
  if ad[i,14] == 1 // 1-ВМП проведена
    a11[13] := 1
  endif
next
select TMP11
for n := 1 to len(av1) // цикл по возрастам таблиц 10
  for j := 1 to len(a11)-1
    if a11[j] > 0
      find (str(av1[n],1)+str(j,2)+str(a11[j],1))
      if !found()
        append blank
        tmp11->voz := av1[n]
        tmp11->tbl := j
        tmp11->tip := a11[j]
      endif
      tmp11->kol ++
    endif
  next
next
if a10[9] > 0
  s12_1++
  if is_man
    s12_1m++
  endif
endif
if a11[13] > 0
  s12_2++
  if is_man
    s12_2m++
  endif
endif
ad := {0}
if m1invalid1 == 1 // инвалидность-да
  aadd(ad,4)
  if m1invalid2 == 0 // с рождения
    aadd(ad,1)
  else               // приобретенная
    aadd(ad,2)
    if !empty(minvalid3) .and. minvalid3 >= mn_data
      aadd(ad,3)
    endif
  endif
  if !empty(minvalid7) // Дата назначения инд.программы реабилитации
    aadd(ad,10)
    do case // выполнение
      case m1invalid8 == 1 // полностью,1
        aadd(ad,11)
      case m1invalid8 == 2 // частично,2
        aadd(ad,12)
      case m1invalid8 == 3 // начата,3
        aadd(ad,13)
      otherwise            // не выполнена,0
        aadd(ad,14)
    endcase
  endif
endif
if m1privivki1 == 1     // не привит по медицинским показаниям",1},;
  if m1privivki2 == 1
    aadd(ad,21)
  else
    aadd(ad,22)
  endif
elseif m1privivki1 == 2 // не привит по другим причинам",2}}
  if m1privivki2 == 1
    aadd(ad,23)
  else
    aadd(ad,24)
  endif
else                    // привит по возрасту",0},;
  aadd(ad,20)
endif
use (cur_dir+"tmp13") index (cur_dir+"tmp13") new alias TMP13
for n := 1 to len(av1) // цикл по возрастам таблицы
  for j := 1 to len(ad)
    find (str(av1[n],1)+str(ad[j],2))
    if !found()
      append blank
      tmp13->voz := av1[n]
      tmp13->tip := ad[j]
    endif
    tmp13->kol ++
  next
next
ad := {0}
if m1fiz_razv == 0
  aadd(ad,1)
else
  if m1fiz_razv1 == 1
    aadd(ad,2)
  elseif m1fiz_razv1 == 2
    aadd(ad,3)
  endif
  if m1fiz_razv2 == 1
    aadd(ad,4)
  elseif m1fiz_razv2 == 2
    aadd(ad,5)
  endif
endif
aadd(ad,mGRUPPA_DO+10)
aadd(ad,mGRUPPA+20)
    //index on str(voz,1)+str(man,1)+str(tip,2) to tmp16
use (cur_dir+"tmp16") index (cur_dir+"tmp16") new alias TMP16
for n := 1 to len(av1) // цикл по возрастам таблицы
  for j := 1 to len(ad)
    find (str(av1[n],1)+"0"+str(ad[j],2))
    if !found()
      append blank
      tmp16->voz := av1[n]
      tmp16->tip := ad[j]
    endif
    tmp16->kol ++
    if is_man
      find (str(av1[n],1)+"1"+str(ad[j],2))
      if !found()
        append blank
        tmp16->voz := av1[n]
        tmp16->man := 1
        tmp16->tip := ad[j]
      endif
      tmp16->kol ++
    endif
  next
next
return NIL

*

***** 11.03.19
Function inf_DDS_XMLfile(is_schet)
Static stitle := "Диспансеризация детей-сирот "
Local arr_m, n, buf := save_maxrow(), lkod_h, lkod_k, rec, blk, t_arr[BR_LEN]
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  if f0_inf_DDS(arr_m,is_schet > 1,is_schet == 3,.t.)
    R_Use(dir_server+"human",,"HUMAN")
    use (cur_dir+"tmp") new
    set relation to kod into HUMAN
    index on upper(human->fio) to (cur_dir+"tmp")
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            E_Use(cur_dir+"tmp",cur_dir+"tmp"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    eval(blk_open)
    go top
    t_arr[BR_TOP] := T_ROW
    t_arr[BR_BOTTOM] := 23
    t_arr[BR_LEFT] := 0
    t_arr[BR_RIGHT] := 79
    t_arr[BR_TITUL] := stitle+arr_m[4]
    t_arr[BR_TITUL_COLOR] := "B/BG"
    t_arr[BR_COLOR] := color0
    t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
    blk := {|| iif(tmp->is==1, {1,2}, {3,4}) }
    t_arr[BR_COLUMN] := {{" ", {|| iif(tmp->is==1,""," ") }, blk },;
                         {" Ф.И.О.", {|| padr(human->fio,37) }, blk },;
                         {"Дата рожд.", {|| full_date(human->date_r) }, blk },;
                         {"№ ам.карты", {|| human->uch_doc }, blk },;
                         {"Сроки леч-я", {|| left(date_8(human->n_data),5)+"-"+left(date_8(human->k_data),5) }, blk },;
                         {"Этап", {|| iif(human->ishod==101," I  ","I-II") }, blk }}
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход для создания файла;  ^<+,-,Ins>^ - отметить/снять отметку с пациента") }
    t_arr[BR_EDIT] := {|nk,ob| f1_inf_N_XMLfile(nk,ob,"edit") }
    edit_browse(t_arr)
    select TMP
    delete for is == 0
    pack
    n := lastrec()
    close databases
    rest_box(buf)
    if n == 0 .or. !f_Esc_Enter("составления XML-файла")
      return NIL
    endif
    mywait()
    R_Use(dir_server+"mo_rpdsh",,"RPDSH")
    index on str(KOD_H,7) to (cur_dir+"tmprpdsh")
    Use
    R_Use(dir_server+"mo_raksh",,"RAKSH")
    index on str(KOD_H,7) to (cur_dir+"tmpraksh")
    Use
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            R_Use(cur_dir+"tmp",cur_dir+"tmp"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    mo_mzxml_N(1)
    n := 0
    do while .t.
      ++n
      eval(blk_open)
      if rec == NIL
        go top
      else
        goto (rec)
        skip
        if eof()
          exit
        endif
      endif
      rec := tmp->(recno())
      @ maxrow(),0 say padr(str(n/tmp->(lastrec())*100,6,2)+"%"+" "+;
                            rtrim(human->fio)+" "+date_8(human->n_data)+"-"+;
                            date_8(human->k_data),80) color cColorWait
      lkod_h := human->kod
      lkod_k := human->kod_k
      close databases
      oms_sluch_DDS(p_tip_lu,lkod_h,lkod_k,"f2_inf_N_XMLfile")
    enddo
    close databases
    rest_box(buf)
    mo_mzxml_N(3,"tmp",stitle)
  endif
endif
close databases
rest_box(buf)
return NIL

*

***** 03.12.17 Информация по диспансеризации и профилактике взрослого населения
Function inf_DVN(k)
Static si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 2, si6 := 2, sj := 1, sj1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"Карта учёта №131/~у",;
                "~Список пациентов",;
                "Многовариантный ~запрос",;
                "Своды для ~Облздрава",;
                "Отчётная форма №~131",;
                "Обмен ~файлами R0... с ТФ"}
    mas_msg := {"Распечатка карты учёта диспансеризации (профилактических мед.осмотров) №131/у",;
                "Распечатка списка пациентов, прошедших диспансеризацию/профилактику",;
                "Многовариантный запрос по диспансеризации/профилактике взрослого населения",;
                "Распечатка сводов для Волгоградского областного Комитета здравоохранения",;
                "Сведения о диспансеризации определённых групп взрослого населения",;
                "Информационное сопровождение при орг-ции прохождения профилактических мероприятий"}
    mas_fun := {"inf_DVN(11)",;
                "inf_DVN(12)",;
                "inf_DVN(13)",;
                "inf_DVN(14)",;
                "inf_DVN(15)",;
                "inf_DVN(16)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    f_131_u()
  case k == 12
    mas_pmt := aclone(mas1pmt)
    aadd(mas_pmt, "случаи, ещё ~не попавшие в счета")
    if (j := popup_prompt(T_ROW,T_COL-5,sj,mas_pmt)) > 0
      sj := j
      if (j := popup_prompt(T_ROW,T_COL-5,sj1,;
                            {"Диспансеризация ~1 этап",;
                             "Направлены на 2 этап - ещё ~не прошли",;
                             "Диспансеризация ~2 этап",;
                             "~Профилактика"})) > 0
        sj1 := j
        f2_inf_DVN(sj,sj1)
      endif
    endif
  case k == 13
    /*mas_pmt := {"~Лица, подлежащие диспансеризации"}
    mas_msg := {"Запрос лиц, подлежащих диспасеризации, методом многовариантного поиска"}
    mas_fun := {"inf_DVN(31)"}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)*/
    inf_DVN(31)
  case k == 14
    mas_pmt := {"~Сведения о диспансеризации по состоянию на ...",;
                "~Индикаторы мониторинга диспансеризации взрослых"}
    mas_msg := {"Приложение к Приказу МЗВО №2066 от 01.08.2013г.",;
                "Индикаторы мониторинга диспансеризации взрослых"}
    mas_fun := {"inf_DVN(21)",;
                "inf_DVN(22)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 15
    if (j := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
      forma_131(j)
    endif
  case k == 16
    mas_pmt := {"~План-график (R05)",;
                "~Файлы обмена (R01)"}
    mas_msg := {"Создание и просмотр файлов обмена R05...",;
                "Создание и просмотр файлов обмена R01..."}
    mas_fun := {"inf_DVN(41)",;
                "inf_DVN(42)"}
    str_sem := "ИСОМП"
    if G_SLock(str_sem)
//ffffff()
      popup_prompt(T_ROW-len(mas_pmt)-3,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
      G_SUnLock(str_sem)
    else
      func_error(4,"В данный момент с этим режимом работает другой пользователь.")
    endif
  case k == 41
    mas_pmt := {"~Создание плана-графика",;
                "~Просмотр файлов обмена"}
    mas_msg := {"Создание файла обмена R05... с планом-графиком по месяцам",;
                "Просмотр файлов обмена R05... и результатов работы с ними"}
    mas_fun := {"inf_DVN(51)",;
                "inf_DVN(52)"}
    popup_prompt(T_ROW,T_COL-5,si5,mas_pmt,mas_msg,mas_fun)
  case k == 42
    mas_pmt := {"~Создание файлов обмена",;
                "~Просмотр файлов обмена"}
    mas_msg := {"Создание файлов обмена R01... по всем кварталам",;
                "Просмотр файлов обмена R01... и результатов работы с ними"}
    mas_fun := {"inf_DVN(61)",;
                "inf_DVN(62)"}
    if need_delete_reestr_R01()
      aadd(mas_pmt, "~Аннулирование пакета")
      aadd(mas_msg, "Аннулирование недописанного пакета файлов R01")
      aadd(mas_fun, "delete_reestr_R01()")
    endif
    popup_prompt(T_ROW,T_COL-5,si6,mas_pmt,mas_msg,mas_fun)
  case k == 21
    if (j := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
      f21_inf_DVN(j)
    endif
  case k == 22
    f22_inf_DVN(j)
  case k == 31
    mnog_poisk_DVN1()
  case k == 51
    f_create_R05()
  case k == 52
    f_view_R05()
  case k == 61
    f_create_R01()
  case k == 62
    f_view_R01()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  elseif between(k,31,39)
    si3 := j
  elseif between(k,41,49)
    si4 := j
  elseif between(k,51,59)
    si5 := j
  elseif between(k,61,69)
    si6 := j
  endif
endif
return NIL

Function ffffff()
Local aq[4,3], am[12,3], at[12,3]
R_Use(dir_server+"mo_dr05p",,"R05p")
goto (1)
R_Use(dir_server+"mo_dr01k",,"R01k")
index on str(reestr,6)+str(tip,1) to (cur_dir+"tmp_dr01k")
R_Use(dir_server+"mo_dr01",,"REES")
index on str(nn,3)+str(NQUARTER,1) to (cur_dir+"tmp_dr01") for NYEAR == 2018
for it := 1 to 2
  afillall(at,0)
  my_debug(,"-it="+lstr(it)+"-")
  ip := 0
  do while .t.
    ++ip
    select REES
    find (str(ip,3))
    if !found()
      exit
    endif
    afillall(aq,0)
    afillall(am,0)
    select REES
    find (str(ip,3))
    do while rees->nn == ip .and. !eof()
      iq := rees->NQUARTER
      select R01k
      find (str(rees->kod,6)+str(it,1))
      do while rees->kod == r01k->reestr .and. it == r01k->tip .and. !eof()
        im := r01k->n_m
        aq[iq,1] ++
        am[im,1] ++
        if r01k->oplata < 2
          aq[iq,2] ++
          am[im,2] ++
        else
          aq[iq,3] ++
          am[im,3] ++
        endif
        skip
      enddo
      select REES
      skip
    enddo
    my_debug(,"=== "+lstr(ip))
    for i := 1 to 4
      my_debug(,print_array(aq[i]))
    next
    my_debug(,"----")
    for i := 1 to 12
      my_debug(,print_array(am[i]))
      at[i,2] += am[i,2]
    next
  enddo
  my_debug(,"итого-it="+lstr(it)+"-")
  for i := 1 to 12
    at[i,1] := &("r05p->kol"+lstr(it)+"_"+strzero(i,2))
    at[i,3] := at[i,1] - at[i,2]
    my_debug(,print_array(at[i]))
  next
next it
close databases
return NIL

***** 15.08.19
Function f0_inf_DVN(arr_m,is_schet,is_reg,is_1_2)
Local fl := .t., j := 0, n, buf := save_maxrow()
DEFAULT is_schet TO .t., is_reg TO .f., is_1_2 TO .f.
if !del_dbf_file("tmp"+sdbf)
  return .f.
endif
mywait()
dbcreate(cur_dir+"tmp",{{"kod_k","N",7,0},;
                        {"kod1h","N",7,0},;
                        {"date1","D",8,0},;
                        {"kod2h","N",7,0},;
                        {"date2","D",8,0},;
                        {"kod3h","N",7,0},;
                        {"date3","D",8,0},;
                        {"kod4h","N",7,0},;
                        {"date4","D",8,0}})
use (cur_dir+"tmp") new
index on str(kod_k,7) to (cur_dir+"tmp")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_
n := iif(is_1_2, 204, 203)
dbseek(dtos(arr_m[5]),.t.)
index on kod to (cur_dir+"tmp_h") ;
      for between(ishod,201,n) .and. human->cena_1 > 0 .and. iif(is_schet, schet > 0, .t.) ;
      while human->k_data <= arr_m[6] ;
      PROGRESS
go top
do while !eof()
  fl := f_is_uch(st_a_uch,human->lpu)
  if fl .and. is_reg
    fl := .f.
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // только зарегистрированные
      fl := .t.
    endif
  endif
  if fl .and. ret_koef_from_RAK(human->kod) > 0
    select TMP
    find (str(human->kod_k,7))
    if !found()
      append blank
      tmp->kod_k := human->kod_k
    endif
    do case
      case human->ishod == 201
        if (empty(tmp->date1) .or. human->k_data > tmp->date1)
          tmp->kod1h := human->kod
          tmp->date1 := human->k_data
        endif
      case human->ishod == 202
        if (empty(tmp->date2) .or. human->k_data > tmp->date2)
          tmp->kod2h := human->kod
          tmp->date2 := human->k_data
        endif
      case human->ishod == 203
        if (empty(tmp->date3) .or. human->k_data > tmp->date3)
          tmp->kod3h := human->kod
          tmp->date3 := human->k_data
        endif
      case human->ishod == 204
        tmp->kod4h := human->kod
        tmp->date4 := human->k_data
    endcase
    if ++j % 1000 == 0
      commit
    endif
  endif
  select HUMAN
  skip
enddo
rest_box(buf)
fl := .t.
if tmp->(lastrec()) == 0
  fl := func_error(4,"Не найдено л/у по диспансеризации взрослого населения "+arr_m[4])
endif
close databases
return fl

*

***** 20.10.16 карта учёта диспансеризации по форме №131/у
Function f_131_u()
Local arr_m, buf := save_maxrow(), k, blk, t_arr[BR_LEN], rec := 0
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) != NIL ;
              .and. (arr_m := year_month(,,,5)) != NIL .and. f0_inf_DVN(arr_m,.f.)
  mywait()
  R_Use(dir_server+"kartotek",,"KART")
  use (cur_dir+"tmp") index (cur_dir+"tmp") new
  if glob_kartotek > 0
    find (str(glob_kartotek,7))
    if found()
      rec := tmp->(recno())
    endif
  endif
  set relation to kod_k into KART
  index on upper(kart->fio) to (cur_dir+"tmp")
  Private ;
    blk_open := {|| dbCloseAll(),;
                    R_Use(dir_server+"uslugi",,"USL"),;
                    R_Use(dir_server+"human_u_",,"HU_"),;
                    R_Use(dir_server+"human_u",dir_server+"human_u","HU"),;
                    dbSetRelation( "HU_", {|| recno() }, "recno()" ),;
                    R_Use(dir_server+"human_",,"HUMAN_"),;
                    R_Use(dir_server+"human",,"HUMAN"),;
                    dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                    R_Use(dir_server+"kartote_",,"KART_"),;
                    R_Use(dir_server+"kartotek",,"KART"),;
                    dbSetRelation( "KART_", {|| recno() }, "recno()" ),;
                    R_Use(cur_dir+"tmp",cur_dir+"tmp"),;
                    dbSetRelation( "KART", {|| kod_k }, "kod_k" );
                }
  eval(blk_open)
  go top
  if rec > 0
    goto (rec)
  endif
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := 23
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_TITUL] := "Взрослое население "+arr_m[4]
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B,RB/BG,W+/RB",.t.}
  blk := {|| iif(emptyall(tmp->kod1h,tmp->kod2h), {5,6}, iif(empty(tmp->kod2h), {1,2}, {3,4})) }
  t_arr[BR_COLUMN] := {{" Ф.И.О.",     {|| padr(kart->fio,39) }, blk },;
                       {"Дата рожд.",  {|| full_date(kart->date_r) }, blk },;
                       {"№ ам.карты",  {|| padr(__f_131_u(1),10) }, blk },;
                       {"Сроки леч-я", {|| padr(__f_131_u(2),11) }, blk },;
                       {"Этап",        {|| padr(__f_131_u(3), 4) }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - распечатать карту учёта дисп-ии (проф.осмотра)") }
  t_arr[BR_EDIT] := {|nk,ob| f1_131_u(nk,ob,"edit") }
  edit_browse(t_arr)
endif
close databases
rest_box(buf)
return NIL

***** 20.09.15
Static Function __f_131_u(k)
Local s := "", ie := 1
if emptyall(tmp->kod1h,tmp->kod2h) // значит профилактика
  human->(dbGoto(tmp->kod3h))
  ie := 3
else // диспансеризация
  if empty(tmp->kod1h) // почему-то нет первого этапа
    human->(dbGoto(tmp->kod2h))
  else
    human->(dbGoto(tmp->kod1h))
  endif
  if !empty(tmp->kod2h) // есть второй этап
    ie := 2
  endif
endif
if k == 1
  s := human->uch_doc
elseif k == 2
  s := left(date_8(human->n_data),5)+"-"
  if ie == 2
    human->(dbGoto(tmp->kod2h))
  endif
  s += left(date_8(human->k_data),5)
else
  s := {"I эт","I-II","проф"}[ie]
endif
return s

*

***** 21.07.19
Function f1_131_u(nKey,oBrow,regim)
Static lV := "V", sb1 := "<b><u>", sb2 := "</u></b>"
Static s_smg := "Не удалось определить группу здоровья"
Local ret := -1, rec := tmp->(recno()), buf := save_maxrow(),;
      i, j, k, fl, lshifr, au := {}, ar, metap, m1gruppa, is_disp := .t.,;
      mpol := kart->pol, fl_dispans := .f., adbf, s, y, m, d, arr,;
      blk := {|s| __dbAppend(), field->stroke := s }
if regim == "edit" .and. nKey == K_ENTER
  glob_kartotek := tmp->kod_k
  delFRfiles()
  mywait()
  Private arr_otklon := {}, arr_usl_otkaz := {}, mvozrast, mdvozrast,;
          M1RAB_NERAB, m1veteran := 0, m1mobilbr := 0,;
          m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, mssr := 0,;
          m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
          mholest := 0, mglukoza := 0, ;
          m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, ;
          m1ot_nasl1 := 0, m1ot_nasl2 := 0, m1ot_nasl3 := 0, m1ot_nasl4 := 0,;
          m1dispans := 0, m1nazn_l  := 0, m1dopo_na := 0, m1ssh_na  := 0,;
          m1spec_na := 0, m1sank_na := 0,;
          pole_diag, pole_1pervich, pole_1stadia, pole_1dispans,;
          mWEIGHT := 0, mHEIGHT := 0, mn_data, mk_data, mk_data1
  for i := 1 to 5
    pole_diag := "mdiag"+lstr(i)
    pole_d_diag := "mddiag"+lstr(i)
    pole_1pervich := "m1pervich"+lstr(i)
    pole_1stadia := "m1stadia"+lstr(i)
    pole_1dispans := "m1dispans"+lstr(i)
    pole_d_dispans := "mddispans"+lstr(i)
    Private &pole_diag := space(6)
    Private &pole_d_diag := ctod("")
    Private &pole_1pervich := 0
    Private &pole_1stadia := 0
    Private &pole_1dispans := 0
    Private &pole_d_dispans := ctod("")
  next
  if emptyall(tmp->kod1h,tmp->kod2h) // значит профилактика
    is_disp := .f.
    human->(dbGoto(tmp->kod3h))
    m1GRUPPA := human_->RSLT_NEW - 342
    if !between(m1gruppa,1,3)
      m1GRUPPA := 0 ; func_error(4,s_smg)
    endif
  else // I этап
    if empty(tmp->kod1h)
      func_error(4,"Присутствует II этап, но отсутствует I этап")
      rest_box(buf)
      return ret
    endif
    human->(dbGoto(tmp->kod1h))
    m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW)
    if !between(m1gruppa,0,4)
      m1GRUPPA := 0 ; func_error(4,s_smg)
    endif
  endif
  M1RAB_NERAB := human->RAB_NERAB
  mn_data := human->n_data
  mk_data := mk_data1 := human->k_data
  Private is_disp_19 := !(mk_data < d_01_05_2019)
  mdate_r := full_date(human->date_r)
  read_arr_DVN(human->kod)
  ret_arr_vozrast_DVN(mk_data)
  ret_arrays_disp(is_disp_19)
  ret_tip_mas(mWEIGHT,mHEIGHT,@m1tip_mas)
  mvozrast := count_years(human->date_r,human->n_data)
  mdvozrast := year(human->n_data) - year(human->date_r)
  if m1veteran == 1
    mdvozrast := ret_vozr_DVN_veteran(mdvozrast,human->k_data)
  endif
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
      lshifr := usl->shifr
    endif
    if !eq_any(left(lshifr,5),"70.3.","70.7.","72.1.","72.5.","72.6.","72.7.")
      aadd(au,{alltrim(lshifr),;
               hu_->PROFIL,;
               iif(left(hu_->kod_diag,1)=="Z","",hu_->kod_diag),;
               c4tod(hu->date_u);
              })
    endif
    select HU
    skip
  enddo
  k_nev_4_1_12 := 0
  for k := 1 to len(au)
    lshifr := au[k,1]
    if is_disp_19
        //
    elseif ((lshifr == "2.3.3" .and. au[k,2] == 3) .or.  ; // акушерскому делу
            (lshifr == "2.3.1" .and. au[k,2] == 136))    // акушерству и гинекологии
      k_nev_4_1_12 := k
    endif
    if ascan(arr_otklon,au[k,1]) > 0
      au[k,3] := "+" // отклонения в исследовании
      if eq_any(lshifr,"4.20.1","4.20.2") // если отклонения в исследовании цитологич.материала
        if (i := ascan(au, {|x| x[1] == "4.1.12"})) > 0
          au[i,3] := "+" // занесём отклонения в осмотр фельдшера "4.1.12"
        endif
      endif
    endif
  next
  if is_disp_19
    arr_10 := {;
      { 1,"56.1.16","Опрос (анкетирование) на выявление хронических неинфекционных заболеваний, факторов риска их развития, потребления наркотических средств и психотропных веществ без назначения врача"},;
      { 2,"3.1.19","Антропометрия (измерение роста стоя, массы тела, окружности талии), расчет индекса массы тела"},;
      { 3,"3.1.5","Измерение артериального давления"},;
      { 4,"3.4.9","Измерение внутриглазного давления"},;
      { 5,"4.12.174","Исследование крови на общий холестерин"},;
      { 6,"4.12.169","Исследование уровня глюкозы в крови"},;
      { 7,"4.11.137","Клинический анализ крови (3 показателя)"},;
      { 8,"4.8.4","Исследование кала на скрытую кровь"},;
      { 9,"4.14.66","Исследование крови на простат-специфический антиген"},;
      {10,{{"2.3.1",136},{"2.3.3",3},{"2.3.3",42}},"Осмотр акушеркой или акушером-гинекологом"},;
      {11,{"4.1.12","4.20.1","4.20.2"},"Взятие мазка (соскоба) с поверхности шейки матки (наружного маточного зева) и цервикального канала на цитологическое исследование"},;
      {12,"7.57.3","Маммография обеих молочных желез"},;
      {13,"7.61.3","Флюорография лёгких профилактическая"},;
      {14,"13.1.1","Электрокардиография (в покое)"},;
      {15,"10.3.13","Фиброэзофагогастродуоденоскопия"},;
      {16,"56.1.18","Определение относительного суммарного сердечно-сосудистого риска","mdvozrast < 40"},;
      {17,"56.1.19","Определение абсолютного суммарного сердечно-сосудистого риска","39 < mdvozrast .and. mdvozrast < 65"},;
      {18,"56.1.14","Краткое индивидуальное профилактическое консультирование"},;
      {19,{{"2.3.7",57},{"2.3.7",97},{"2.3.2",57},{"2.3.2",97},{"2.3.4",42}},"Прием (осмотр) врача-терапевта"};
     }
  else
    arr_10 := {;
      { 1,"56.1.16","Опрос (анкетирование) на выявление хронических неинфекционных заболеваний, факторов риска их развития, потребления наркотических средств и психотропных веществ без назначения врача"},;
      { 2,"3.1.19","Антропометрия (измерение роста стоя, массы тела, окружности талии), расчет индекса массы тела"},;
      { 3,"3.1.5","Измерение артериального давления"},;
      { 4,"4.12.174","Определение уровня общего холестерина в крови"},;
      { 5,"4.12.169","Определение уровня глюкозы в крови экспресс-методом"},;
      { 6,{"56.1.17","56.1.18"},"Определение относительного суммарного сердечно-сосудистого риска","mdvozrast < 40"},;
      { 7,{"56.1.17","56.1.19"},"Определение абсолютного суммарного сердечно-сосудистого риска","39 < mdvozrast .and. mdvozrast < 66"},;
      { 8,"13.1.1","Электрокардиография (в покое)"},;
      { 9,{"4.1.12","4.20.1","4.20.2"},"Осмотр фельдшером (акушеркой), включая взятие мазка (соскоба) с поверхности шейки матки (наружного маточного зева) и цервикального канала на цитологическое исследование"},;
      {10,"7.61.3","Флюорография легких"},;
      {11,"7.57.3","Маммография обеих молочных желез"},;
      {12,"4.11.137","Клинический анализ крови"},;
      {13,"4.11.136","Клинический анализ крови развернутый"},;
      {14,"4.12.172","Анализ крови биохимический общетерапевтический"},;
      {15,"4.2.153","Общий анализ мочи"},;
      {16,"4.8.4","Исследование кала на скрытую кровь иммунохимическим методом"},;
      {17,{"8.2.1","8.2.4","8.2.5"},"Ультразвуковое исследование (УЗИ) на предмет исключения новообразований органов брюшной полости, малого таза"},;
      {18,"8.1.5","Ультразвуковое исследование (УЗИ) в целях исключения аневризмы брюшной аорты"},;
      {19,"3.4.9","Измерение внутриглазного давления"},;
      {20,{{"2.3.1",97},{"2.3.1",57},{"2.3.2",97},{"2.3.2",57},{"2.3.3",42},{"2.3.5",57},{"2.3.5",97},{"2.3.6",57},{"2.3.6",97}},"Прием (осмотр) врача-терапевта"};
     }
    if is_disp .and. year(mk_data) > 2017 // с 2018 года
      arr_10[13] := {13,"4.14.66","Исследование крови на простат-специфический антиген"}
      Del_Array(arr_10,18)
      Del_Array(arr_10,17)
      Del_Array(arr_10,15)
      Del_Array(arr_10,14)
    endif
  endif
  dbcreate(fr_data,{{"name","C",200,0},;
                    {"ns","N",2,0},;
                    {"vv","C",10,0},;
                    {"vo","C",10,0},;
                    {"vd","C",20,0}})
  use (fr_data) new alias FRD
  for n := 1 to len(arr_10)
    append blank
    frd->name := arr_10[n,3]
    frd->ns := arr_10[n,1]
  next
  index on str(ns,2) to tmp_frd
  for i := 1 to len(arr_10)
    fl := fl_nev := .f. ;  date_o := ctod("")
    if valtype(arr_usl_otkaz) == "A"
      for k1 := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[k1]
        if valtype(ar) == "A" .and. len(ar) >= 10 .and. valtype(ar[5]) == "C" ;
                              .and. valtype(ar[10]) == "N" .and. between(ar[10],1,2)
          lshifr := alltrim(ar[5])
          if valtype(arr_10[i,2]) == "C"
            if lshifr == arr_10[i,2]
              fl := .t.
              if ar[10] == 1 // отказ
                date_o := ar[9]
              else // невозможность
                fl_nev := .t.
              endif
            endif
          elseif valtype(arr_10[i,2,1]) == "C" // шифры в массиве
            for j := 1 to len(arr_10[i,2])
              if lshifr == arr_10[i,2,j]
                fl := .t.
                if ar[10] == 1 // отказ
                  date_o := ar[9]
                else // невозможность
                  fl_nev := .t.
                endif
                exit
              endif
            next
          else
            for j := 1 to len(arr_10[i,2])
              if lshifr == arr_10[i,2,j,1] .and. ar[4] == arr_10[i,2,j,2]
                fl := .t.
                if ar[10] == 1 // отказ
                  date_o := ar[9]
                else // невозможность
                  fl_nev := .t.
                endif
                exit
              endif
            next
          endif
        endif
        if fl ; exit ; endif
      next
    endif
    if !fl
      if valtype(arr_10[i,2]) == "C" // один шифр
        if (k := ascan(au, {|x| x[1] == arr_10[i,2]})) > 0
          fl := .t.
        endif
      elseif valtype(arr_10[i,2,1]) == "C" // шифры в массиве
        for j := 1 to len(arr_10[i,2])
          if (k := ascan(au, {|x| x[1]==arr_10[i,2,j]})) > 0
            fl := .t. ; exit
          endif
        next
      else // в массиве пары: шифр и профиль
        for j := 1 to len(arr_10[i,2])
          if (k := ascan(au, {|x| x[1]==arr_10[i,2,j,1] .and. x[2]==arr_10[i,2,j,2]})) > 0
            fl := .t. ; exit
          endif
        next
      endif
    endif
    if fl .and. len(arr_10[i]) > 3
      fl := &(arr_10[i,4])
    endif
    if fl
      find (str(arr_10[i,1],2))
      if valtype(arr_10[i,2]) == "A" .and. valtype(arr_10[i,2,1]) == "C" ;
                                     .and. arr_10[i,2,1] == "4.1.12" .and. k_nev_4_1_12 > 0
        frd->vv := full_date(au[k_nev_4_1_12,4])
        frd->vd := "невозможно"
      elseif fl_nev
        frd->vv := "невозможно"
      elseif !empty(date_o)
        frd->vv := "отказ"
        frd->vo := full_date(date_o)
      else
        frd->vv := full_date(au[k,4])
        if au[k,4] < human->n_data
          frd->vo := full_date(au[k,4])
        endif
        frd->vd := iif(empty(au[k,3]), "-", "<b>"+au[k,3]+"</b>")
      endif
    endif
  next
  select FRD
  set index to
  go top
  do while !eof()
    if emptyall(frd->vv,frd->vd,frd->vo)
      delete
    endif
    skip
  enddo
  pack
  n := 0
  go top
  do while !eof()
    frd->ns := ++n
    skip
  enddo
  //
  adbf := {{"titul","C",50,0},;
           {"titul2","C",50,0},;
           {"fio","C",100,0},;
           {"fio2","C",60,0},;
           {"pol","C",50,0},;
           {"date_r","C",10,0},;
           {"d_dr","C",2,0},;
           {"m_dr","C",2,0},;
           {"y_dr","C",4,0},;
           {"vozrast","N",4,0},;
           {"subekt","C",50,0},;
           {"rajon","C",50,0},;
           {"gorod","C",50,0},;
           {"nas_p","C",50,0},;
           {"adres","C",200,0},;
           {"gorod_selo","C",50,0},;
           {"kod_lgot","C",2,0},;
           {"sever","C",30,0},;
           {"zanyat","C",200,0},;
           {"mobil","C",30,0},;
           {"n_data","C",10,0},;
           {"k_data","C",10,0},;
           {"v13_1","C",10,0},;
           {"v13_2","C",10,0},;
           {"v13_3","C",10,0},;
           {"v13_4","C",10,0},;
           {"v13_5","C",10,0},;
           {"v13_6","C",10,0},;
           {"v13_7","C",10,0},;
           {"v13_8","C",10,0},;
           {"v13_9","C",10,0},;
           {"v14","C",2,0},;
           {"v14_1","C",1,0},;
           {"v14_2","C",1,0},;
           {"v15","C",2,0},;
           {"v15_1","C",1,0},;
           {"v15_2","C",1,0},;
           {"v16_1","C",1,0},;
           {"v16_2","C",1,0},;
           {"v16_3","C",1,0},;
           {"v16_4","C",1,0},;
           {"v17","C",30,0},;
           {"v18","C",30,0},;
           {"v18_1","C",30,0},;
           {"v18_2","C",30,0},;
           {"v19","C",30,0},;
           {"v20","C",30,0},;
           {"vrach","C",100,0}}
  dbcreate(fr_titl, adbf)
  use (fr_titl) new alias FRT
  append blank
  frt->titul := iif(!emptyall(tmp->kod1h,tmp->kod2h), "диспансеризации", "профилактического медицинского осмотра")
  frt->titul2 := iif(!emptyall(tmp->kod1h,tmp->kod2h), "Диспансеризация", "Профилактический медицинский осмотр")
  arr := retFamImOt(1,.f.)
  frt->fio2 := arr[1]+" "+arr[2]+" "+arr[3]
  frt->fio := expand(upper(rtrim(frt->fio2)))
  frt->pol := iif(kart->pol=="М",sb1+"муж. - 1"+sb2+", жен. - 2","муж. - 1, "+sb1+"жен. - 2"+sb2)
  frt->date_r := mdate_r
  frt->d_dr := substr(mdate_r,1,2)
  frt->m_dr := substr(mdate_r,4,2)
  frt->y_dr := substr(mdate_r,7,4)
  frt->vozrast := mvozrast
  if f_is_selo()
    frt->gorod_selo := "городская - 1, "+sb1+"сельская - 2"+sb2
  else
    frt->gorod_selo := sb1+"городская - 1"+sb2+", сельская - 2"
  endif
  arr := ret_okato_Array(kart_->okatog)
  frt->subekt := arr[1]
  frt->rajon  := arr[2]
  frt->gorod  := arr[3]
  frt->nas_p  := arr[4]
  if empty(kart->adres)
    frt->adres := "улица"+sb1+space(30)+sb2+" дом"+sb1+space(5)+sb2+" квартира"+sb1+space(5)+sb2
  else
    frt->adres := sb1+padr(kart->adres,60)+sb2
  endif
  if (i := ascan(stm_kategor, {|x| x[2] == kart_->kategor })) > 0 .and. between(stm_kategor[i,3],1,8)
    frt->kod_lgot := lstr(stm_kategor[i,3])
  endif
  frt->mobil := f_131_u_da_net(m1mobilbr,sb1,sb2)
  frt->n_data := full_date(mn_data)
  frt->v13_1 := iif(mad1>140.and.mad2>90, frt->n_data, "-")
  frt->v13_2 := iif(m1glukozadn==1.or.mglukoza>6.1, frt->n_data, "-")
  frt->v13_3 := iif(m1tip_mas>=3, frt->n_data, "-")
  frt->v13_4 := iif(m1kurenie==1, frt->n_data, "-")
  frt->v13_5 := iif(m1riskalk==1, frt->n_data, "-")
  frt->v13_6 := iif(m1pod_alk==1, frt->n_data, "-")
  frt->v13_7 := iif(m1fiz_akt==1, frt->n_data, "-")
  frt->v13_8 := iif(m1ner_pit==1, frt->n_data, "-")
  frt->v13_9 := iif(m1ot_nasl1==1.or.m1ot_nasl2==1.or.m1ot_nasl3==1.or.m1ot_nasl4==1, frt->n_data, "-")
  if mdvozrast < 66
    if mdvozrast > 39
      frt->v15 := lstr(mssr)
      if 5 <= mssr .and. mssr < 10 // Высокий абс.суммарный сердечно-сосудистый риск
        frt->v15_1 := lV
      elseif mssr >= 10 // Очень высокий абс.суммарный сердечно-сосудистый риск
        frt->v16_2 := lV
      endif
    else
      frt->v14 := lstr(mssr)
      if mssr < 1 // низкий отн.суммарный сердечно-сосудистый риск
        frt->v14_1 := lV
      elseif 5 <= mssr .and. mssr < 10 // низкий отн.суммарный сердечно-сосудистый риск
        frt->v14_2 := lV
      endif
    endif
  endif
  dbcreate(fr_data+"1",{{"name","C",200,0},;
                        {"ns","N",2,0},;
                        {"vn","C",10,0},;
                        {"vv","C",10,0},;
                        {"vd","C",20,0}})
  if !empty(tmp->kod2h) // II этап
    human->(dbGoto(tmp->kod2h))
    M1RAB_NERAB := human->RAB_NERAB
    mk_data := human->k_data
    is_disp_19 := !(mk_data < d_01_05_2019)
    m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW)
    if !between(m1gruppa,1,4)
      m1GRUPPA := 0 ; func_error(4,s_smg)
    endif
    read_arr_DVN(human->kod)
    //
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
        lshifr := usl->shifr
      endif
      aadd(au,{alltrim(lshifr),;
               hu_->PROFIL,;
               iif(left(hu_->kod_diag,1)=="Z","",hu_->kod_diag),;
               c4tod(hu->date_u);
              })
      select HU
      skip
    enddo
    for k := 1 to len(au)
      if ascan(arr_otklon,au[k,1]) > 0
        au[k,3] := "+" // отклонения в исследовании
      endif
    next
    if is_disp_19
      arr_11 := {;
        { 1,"Дуплексное сканирование брахиоцефальных артерий","8.23.706"},;
        { 2,"Рентгенография органов грудной клетки","7.2.702"},;
        { 3,"КТ органов грудной полости","7.2.701"},;
        { 4,"Спиральная КТ легких","7.2.703"},;
        { 5,"КТ органов грудной полости (с контрастир-ием)","7.2.704"},;
        { 6,"Однофотонная эмиссионная КТ легких","7.2.705"},;
        { 7,"Ректосигмоколоноскопия диагностическая","10.6.710"},;
        { 8,"Ректороманоскопия","10.4.701"},;
        { 9,"Фиброэзофагогастродуоденоскопия","10.3.713"},;
        {10,"Спирометрия","16.1.717"},;
        {11,"Осмотр (консультация) врачом-неврологом","2.84.1"},;
        {12,"Осмотр (консультация) врачом-хирургом или врачом-урологом","2.84.10"},;
        {13,"Осмотр (консультация) врачом-хирургом или врачом-колопроктологом","2.84.6"},;
        {14,"Осмотр (консультация) врачом-акушером-гинекологом","2.84.5"},;
        {15,"Осмотр (консультация) врачом-оториноларингологом","2.84.8"},;
        {16,"Осмотр (консультация) врачом-офтальмологом","2.84.3"},;
        {17,"Углубленное профилактическое консультирование","56.1.723"},;
        {18,"Прием (осмотр) врача-терапевта","2.84.11"};
       }
    else
      arr_11 := {;
        { 1,"Дуплексное сканирование брахиоцефальных артерий",{"8.23.6","8.23.706"}},;
        { 2,"Осмотр (консультация) врачом-неврологом","2.84.1"},;
        { 3,"Эзофагогастродуоденоскопия","10.3.13"},;
        { 4,"Осмотр (консультация) врачом-хирургом или врачом-урологом","2.84.10"},;
        { 5,"Осмотр (консультация) врачом-хирургом или врачом-колопроктологом","2.84.6"},;
        { 6,"Колоноскопия или ректороманоскопия",{"10.4.1","10.6.10"}},;
        { 7,"Определение липидного спектра крови","4.12.173"},;
        { 8,"Спирометрия",{"16.1.17","16.1.717"}},;
        { 9,"Осмотр (консультация) врачом-акушером-гинекологом","2.84.5"},;
        {10,"Определение концентрации гликированного гемоглобина в крови или тест на толерантность к глюкозе",{"4.12.170","4.12.171"}},;
        {11,"Осмотр (консультация) врачом-оториноларингологом","2.84.8"},;
        {12,"Анализ крови на уровень содержания простатспецифического антигена","4.14.66"},;
        {13,"Осмотр (консультация) врачом-офтальмологом","2.84.3"},;
        {14,"Индивидуальное углубленное профилактическое консультирование",{"56.1.15","56.1.20"}},;
        {15,"Групповое профилактическое консультирование (школа пациента)","0"},;
        {16,"Прием (осмотр) врача-терапевта",{"2.84.2","2.84.7","2.84.9","2.84.11"}};
       }
      if is_disp .and. year(mk_data) > 2017 // с 2018 года
        arr_11[ 6] := { 6,"Ректосигмоколоноскопия диагностическая","10.6.710"}
        arr_11[14] := {14,"Индивидуальное или групповое (школа для пациента) углубленное профилактическое консультирование","56.1.723"}
        Del_Array(arr_11,15)
        Del_Array(arr_11,12)
        Del_Array(arr_11,10)
        Del_Array(arr_11, 7)
        Del_Array(arr_11, 3)
      endif
    endif
    use (fr_data+"1") new alias FRD1
    for n := 1 to len(arr_11)
      append blank
      frd1->name := arr_11[n,2]
      frd1->ns := arr_11[n,1]
    next
    index on str(ns,2) to tmp_frd1
    for k := 1 to len(au)
      fl := .f.
      for i := 1 to len(arr_11)
        if valtype(arr_11[i,3]) == "A"
          fl := (ascan(arr_11[i,3],au[k,1]) > 0)
        else
          fl := (au[k,1]==arr_11[i,3])
        endif
        if fl ; exit ; endif
      next
      if fl
        find (str(arr_11[i,1],2))
        frd1->vn := full_date(mk_data1)
        frd1->vv := full_date(au[k,4])
        frd1->vd := iif(empty(au[k,3]), "-", "<b>"+au[k,3]+"</b>")
      endif
    next
    select FRD1
    set index to
    go top
    do while !eof()
      if emptyall(frd1->vv,frd1->vd,frd1->vn)
        delete
       endif
      skip
    enddo
    pack
    n := 0
    go top
    do while !eof()
      frd1->ns := ++n
      skip
    enddo
  endif
  frt->k_data := full_date(mk_data)
  frt->zanyat := iif(M1RAB_NERAB==0,sb1,"")+"1 - работает"+iif(M1RAB_NERAB==0,sb2,"")+";  "+;
     iif(M1RAB_NERAB==1,sb1,"")+"2 - не работает"+iif(M1RAB_NERAB==1,sb2,"")+";  "+;
     iif(M1RAB_NERAB==2,"<u>","")+"3 - обучающийся в образовательной организации по очной форме"+iif(M1RAB_NERAB==2,"</u>","")+"."
  frt->sever := f_131_u_da_net(0,sb1,sb2)
  do case
    case m1gruppa == 1
      frt->v16_1 := lV
    case m1gruppa == 2
      frt->v16_2 := lV
    case m1gruppa == 3
      frt->v16_3 := lV
    case m1gruppa == 4
      frt->v16_4 := lV
  endcase
  frt->v17   := f_131_u_da_net(m1nazn_l,sb1,sb2)
  frt->v18   := f_131_u_da_net(m1dopo_na,sb1,sb2)
  frt->v18_1 := f_131_u_da_net(m1ssh_na,sb1,sb2)
  frt->v18_2 := f_131_u_da_net(m1psih_na,sb1,sb2)
  frt->v19   := f_131_u_da_net(m1spec_na,sb1,sb2)
  frt->v20   := f_131_u_da_net(m1sank_na,sb1,sb2)
  R_Use(dir_server+"mo_pers",,"P2")
  goto (human_->vrach)
  frt->vrach := p2->fio
  //
  arr_12 := {;
    { 7,"1","Некоторые инфекционные и паразитарные болезни","A00-B99"},;
    { 8,"1.1","  в том числе: туберкулез","A15-A19"},;
    { 9,"2","Новообразования","C00-D48"},;
    {10,"2.1","в том числе: злокачественные новообразования и новообразования in situ","C00-D09"},;
    {11,"2.2","в том числе: пищевода","C15,D00.1"},;
    {12,"2.2.1"," из них в 1-2 стадии","C15,D00.1","1"},;
    {13,"2.3","желудка","C16,D00.2"},;
    {14,"2.3.1"," из них в 1-2 стадии","C16,D00.2","1"},;
    {15,"2.4","ободочной кишки","C18,D01.0"},;
    {16,"2.4.1"," из них в 1-2 стадии","C18,D01.0","1"},;
    {17,"2.5","ректосигмоидного соединения, прямой кишки, заднего прохода (ануса) и анального канала","C19-C21,D01.1-D01.3"},;
    {18,"2.5.1"," из них в 1-2 стадии","C19-C21,D01.1-D01.3","1"},;
    {19,"2.6","поджелудочной железы","C25"},;
    {20,"2.6.1"," из них в 1-2 стадии","C25","1"},;
    {21,"2.7","трахеи, бронхов и легкого","C33,C34,D02.1-D02.2"},;
    {22,"2.7.1"," из них в 1-2 стадии","C33,C34,D02.1-D02.2","1"},;
    {23,"2.8","молочной железы","C50,D05"},;
    {24,"2.8.1"," из них в 1-2 стадии","C50,D05","1"},;
    {25,"2.9","шейки матки","C53,D06"},;
    {26,"2.9.1"," из них в 1-2 стадии","C53,D06","1"},;
    {27,"2.10","тела матки","C54"},;
    {28,"2.10.1"," из них в 1-2 стадии","C54","1"},;
    {29,"2.11","яичника","C56"},;
    {30,"2.11.1"," из них в 1-2 стадии","C56","1"},;
    {31,"2.12","предстательной железы","C61,D07.5"},;
    {32,"2.12.1"," из них в 1-2 стадии","C61,D07.5","1"},;
    {33,"2.13","почки, кроме почечной лоханки","C64"},;
    {34,"2.13.1"," из них в 1-2 стадии","C64","1"},;
    {35,"3","Болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм","D50-D89"},;
    {36,"3.1","в том числе: анемии, связанные с питанием, гемолитические анемии, апластические и другие анемии","D50-D64"},;
    {37,"4","Болезни эндокринной системы, расстройства питания и нарушения обмена веществ","E00-E90"},;
    {38,"4.1","в том числе: сахарный диабет","E10-E14"},;
    {39,"4.2","ожирение","E66"},;
    {40,"4.3","нарушения обмена липопротеинов и другие липидемии","E78"},;
    {41,"5","Болезни нервной системы","G00-G99"},;
    {42,"5.1","в том числе: преходящие церебральные ишемические приступы [атаки] и родственные синдромы","G45"},;
    {43,"6","Болезни глаза и его придаточного аппарата","H00-H59"},;
    {44,"6.1","в том числе: старческая катаракта и другие катаракты","H25,H26"},;
    {45,"6.2","глаукома","H40"},;
    {46,"6.3","слепота и пониженное зрение","H54"},;
    {47,"7","Болезни системы кровообращения","I00-I99"},;
    {48,"7.1","в том числе: болезни, характеризующиеся повышенным кровяным давлением","I10-I15"},;
    {49,"7.2","ишемическая болезнь сердца","I20-I25"},;
    {50,"7.2.1","в том числе: стенокардия (грудная жаба)","I20"},;
    {51,"7.2.2","в том числе нестабильная стенокардия","I20.0"},;
    {52,"7.2.3","хроническая ишемическая болезнь сердца","I25"},;
    {53,"7.2.4","в том числе: перенесенный в прошлом инфаркт миокарда","I25.2"},;
    {54,"7.3","другие болезни сердца","I30-I52"},;
    {55,"7.4","цереброваскулярные болезни","I60-I69"},;
    {56,"7.4.1","в том числе: закупорка и стеноз прецеребральных артерий, не приводящие к инфаркту мозга, и закупорка и стеноз церебральных артерий, не приводящие к инфаркту мозга","I65,I66"},;
    {57,"7.4.2","другие цереброваскулярные болезни","I67"},;
    {58,"7.4.3","последствия субарахноидального кровоизлияния, последствия внутричерепного кровоизлияния, последствия другого нетравматического внутричерепного кровоизлияния, последствия инфаркта мозга, последствия инсульта, не уточненные как кровоизлияние или инфаркт мозга","I69.0-I69.4"},;
    {59,"7.4.4","аневризма брюшной аорты","I71.3-I71.4"},;
    {60,"8","Болезни органов дыхания","J00-J98"},;
    {61,"8.1","в том числе: вирусная пневмония, пневмония, вызванная Streptococcus pneumonia, пневмония, вызванная Haemophilus influenza, бактериальная пневмония, пневмония, вызванная другими инфекционными возбудителями, пневмония при болезнях, классифицированных в других рубриках, пневмония без уточнения возбудителя","J12-J18"},;
    {62,"8.2","бронхит, не уточненный как острый и хронический, простой и слизисто-гнойный хронический бронхит, хронический бронхит неуточненный, эмфизема","J40-J43"},;
    {63,"8.3","другая хроническая обструктивная легочная болезнь, астма, астматический статус, бронхоэктатическая болезнь","J44-J47"},;
    {64,"9","Болезни органов пищеварения","K00-K93"},;
    {65,"9.1","в том числе: язва желудка, язва двенадцатиперстной кишки","K25,K26"},;
    {66,"9.2","гастрит и дуоденит","K29"},;
    {67,"9.3","неинфекционный энтерит и колит","K50-K52"},;
    {68,"9.4","другие болезни кишечника","K55-K63"},;
    {69,"10","Болезни мочеполовой системы","N00-N99"},;
    {70,"10.1","в том числе: гиперплазия предстательной железы, воспалительные болезни предстательной железы, другие болезни предстательной железы","N40-N42"},;
    {71,"10.2","доброкачественная дисплазия молочной железы","N60"},;
    {72,"10.3","воспалительные болезни женских тазовых органов","N70-N77"},;
    {73,"11","Прочие заболевания",""};
   }
  len12 := len(arr_12)
  diag12 := array(len12)
  dbcreate(fr_data+"2",{{"name","C",350,0},;
                        {"diagnoz","C",50,0},;
                        {"ns","N",2,0},;
                        {"stroke","C",8,0},;
                        {"vz","C",10,0},;
                        {"v1","C",10,0},;
                        {"vd","C",10,0},;
                        {"vp","C",10,0}})
  use (fr_data+"2") new alias FRD2
  for n := 1 to len12
    append blank
    frd2->name := iif("."$arr_12[n,2],"","<b>")+arr_12[n,3]+iif("."$arr_12[n,2],"","</b>")
    frd2->ns := n
    frd2->stroke := arr_12[n,2]
    if len(arr_12[n]) < 5
      frd2->diagnoz := arr_12[n,4]
    endif
    s2 := arr_12[n,4]
    if len(arr_12[n]) > 4
      frd2->vp := "-"
    endif
    diag12[n] := {}
    for i := 1 to numtoken(s2,",")
      s3 := token(s2,",",i)
      if "-" $ s3
        d1 := token(s3,"-",1)
        d2 := token(s3,"-",2)
      else
        d1 := d2 := s3
      endif
      aadd(diag12[n], {diag_to_num(d1,1),diag_to_num(d2,2)} )
    next
  next
  for i := 1 to 5
    pole_diag := "mdiag"+lstr(i)
    pole_d_diag := "mddiag"+lstr(i)
    pole_1pervich := "m1pervich"+lstr(i)
    pole_1stadia := "m1stadia"+lstr(i)
    pole_1dispans := "m1dispans"+lstr(i)
    pole_d_dispans := "mddispans"+lstr(i)
    if !empty(&pole_diag) .and. !(left(&pole_diag,1) == "Z")
      au := {}
      d := diag_to_num(&pole_diag,1)
      for n := 1 to len12
        r := diag12[n]
        for j := 1 to len(r)
          fl := between(d,r[j,1],r[j,2])
          if fl .and. len(arr_12[n]) > 4 // надо проверить стадию
            if human->k_data < d_01_04_2015
              fl := (&pole_1stadia == 0) // ранняя
            else
              fl := (&pole_1stadia < 3) // 1 и 2 стадия
            endif
          endif
          if fl
            aadd(au,n)
          endif
        next
      next
      if empty(au) // заносим в прочие заболевания
        aadd(au,len12)
      endif
      for j := 1 to len(au)
        goto (au[j])
        if &pole_1pervich == 1 // впервые
          frd2->vz := frd2->v1 := frt->k_data // дата приёма терапевта
          if &pole_1dispans == 1
            frd2->vd := frt->k_data
          endif
        elseif &pole_1pervich == 0 // ранее выявленный
          frd2->vz := full_date(&pole_d_diag)
          if &pole_1dispans == 1
            frd2->vd := iif(empty(&pole_d_dispans), frd2->vz, full_date(&pole_d_dispans))
          endif
        else // предварительный диагноз
          if empty(frd2->vp)
            frd2->vp := frt->k_data
          endif
        endif
      next
    endif
  next
  close databases
  call_fr("mo_131_u") // печать
  close databases
  eval(blk_open)
  goto (rec)
  rest_box(buf)
endif
return ret

***** 01.07.17
Static Function f_131_u_da_net(k,sb1,sb2)
if k > 1 ; k := 1 ; endif // если вместо "да" битовый ответ
return f3_inf_DDS_karta({{"да - 1",1},{"нет - 2",0}},k,";  ",sb1,sb2,.f.)

***** 06.10.19 Приложение к Приказу ГБУЗ "ВОМИАЦ" от 12.05.2017г. №1615
Function f21_inf_DVN(par) // свод
Local arr_m, buf := save_maxrow(), s, as := {}, as1[14],;
      i, j, k, n, ar, at, ii, g1, sh := 65, fl, mdvozrast
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) != NIL ;
              .and. (arr_m := year_month(,,,5)) != NIL .and. f0_inf_DVN(arr_m,par > 1,par == 3,.t.)
  Private arr_21[40], arr_316 := {}, arr_ne := {}
  afill(arr_21,0)
  mywait("Сбор статистики")
  dbcreate(cur_dir+"tmp1",{{"name","C",49,0},;
                   {"NN","N",2,0},;
                   {"g1","N",6,0},;
                   {"g2","N",6,0},;
                   {"g3","N",6,0},;
                   {"g4","N",6,0}})
  use (cur_dir+"tmp1") new
  index on str(nn,2) to (cur_dir+"tmp1")
  append blank
  tmp1->nn := 2 ;  tmp1->name := "Осмотрено всего (завершили I этап)"
  append blank
  tmp1->nn := 3 ;  tmp1->name := "из гр.2 после 18:00"
  append blank
  tmp1->nn := 4 ;  tmp1->name := "из гр.2 в субботу"
  append blank
  tmp1->nn := 5 ;  tmp1->name := "из гр.2 всего сельских жителей"
  append blank
  tmp1->nn := 6 ;  tmp1->name := "из гр.5 сельских жителей после 18:00"
  append blank
  tmp1->nn := 7 ;  tmp1->name := "из гр.5 сельских жителей в субботу"
  append blank
  tmp1->nn := 8 ;  tmp1->name := "ГРАЖДАН с впервые выявлен.неинф.заболеваниями"
  append blank
  tmp1->nn := 9 ;  tmp1->name := "всего впервые выявлено неинф.заболеваний"
  append blank
  tmp1->nn := 10 ; tmp1->name := "из гр.8 ГРАЖДАН болезни сист.кровообращения"
  append blank
  tmp1->nn := 11 ; tmp1->name := "из гр.8 ГРАЖДАН ЗНО"
  append blank
  tmp1->nn := 12 ; tmp1->name := "        из гр.11 в т.ч. в I и II стадиях"
  append blank
  tmp1->nn := 13 ; tmp1->name := "из гр.8 ГРАЖДАН сахарный диабет"
  append blank
  tmp1->nn := 14 ; tmp1->name := "        в т.ч. сахарный диабет I типа"
  append blank
  tmp1->nn := 15 ; tmp1->name := "из гр.8 ГРАЖДАН взяты на дисп.наблюдение"
  append blank
  tmp1->nn := 16 ; tmp1->name := "из гр.8 ГРАЖДАН было начато лечение"
  append blank
  tmp1->nn := 17 ; tmp1->name := "        из гр.16 из них сельских жителей"
  dbcreate(cur_dir+"tmp2",{{"kod_k","N",7,0},;
                           {"rslt1","N",3,0},;
                           {"rslt2","N",3,0}})
  use (cur_dir+"tmp2") new
  index on str(kod_k,7) to (cur_dir+"tmp2")
  R_Use(dir_server+"mo_rpdsh",,"RPDSH")
  index on str(KOD_H,7) to (cur_dir+"tmprpdsh")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_, to kod_k into KART_
  R_Use(dir_server+"schet_",,"SCHET_")
  use (cur_dir+"tmp") index (cur_dir+"tmp") new
  f_error_DVN(1)
  ii := 0
  go top
  do while !eof()
    @ maxrow(),0 say str(++ii/tmp->(lastrec())*100,6,2)+"%" color cColorWait
    if !empty(tmp->kod4h) // Диспансеризация 1 раз в 2 года
      human->(dbGoto(tmp->kod4h))
      mdvozrast := year(human->n_data) - year(human->date_r)
      g1 := ret_gruppa_DVN(human_->RSLT_NEW)
      if between(g1,1,4)
        arr_21[31] ++
        if human->pol == "М"
          arr_21[32] ++
        else
          arr_21[33] ++
        endif
        if human->pol == "Ж" .and. human->k_data < d_01_05_2019 .and. ascan(arr2g_vozrast_DVN,mdvozrast) > 0
          arr_21[34] ++
        else
          arr_21[35] ++
        endif
      endif
    elseif emptyall(tmp->kod1h,tmp->kod2h) // профилактика
      human->(dbGoto(tmp->kod3h))
      mdvozrast := year(human->n_data) - year(human->date_r)
      g1 := human_->RSLT_NEW - 342
      if between(g1,1,3)
        arr_21[14] ++
        if f_is_selo(kart_->gorod_selo,kart_->okatog)
          arr_21[15] ++
        endif
        arr_21[15+g1] ++ // профосмотры по группам здоровья
        if f_starshe_trudosp(human->POL,human->DATE_R,human->n_data)
          arr_21[40] ++
        endif
        f2_f21_inf_DVN(2)
      endif
    else
      f1_f21_inf_DVN()
    endif
    f_error_DVN(2)
    select TMP
    skip
  enddo
  close databases
  dbcreate(cur_dir+"tmp3",{{"et2","N",1,0},;
                   {"gr1","N",1,0},;
                   {"gr2","N",1,0},;
                   {"kol1","N",6,0},;
                   {"kol2","N",6,0}})
  use (cur_dir+"tmp3") new
  index on str(et2,1)+str(gr1,1)+str(gr2,1) to (cur_dir+"tmp3")
  R_Use(dir_server+"kartotek",,"KART")
  use (cur_dir+"tmp2") new
  go top
  do while !eof()
    fl := .f.
    g1 := ret_gruppa_DVN(tmp2->rslt1,@fl)
    if between(g1,0,4)
      k := iif(fl,1,0)
      g2 := ret_gruppa_DVN(tmp2->rslt2)
      if !between(g2,1,4)
        g2 := 0
      endif
      select TMP3
      find (str(k,1)+str(g1,1)+str(g2,1))
      if !found()
        append blank
        tmp3->et2 := k
        tmp3->gr1 := g1
        tmp3->gr2 := g2
      endif
      tmp3->kol1 ++
      if g2 > 0
        tmp3->kol2 ++
      endif
    endif
    if tmp2->rslt1 == 316 .and. empty(tmp2->rslt2)
      kart->(dbGoto(tmp2->kod_k))
      aadd(arr_316, alltrim(kart->fio)+" д.р."+full_date(kart->date_r))
    endif
    if tmp2->rslt1 == 0 .and. !empty(tmp2->rslt2)
      kart->(dbGoto(tmp2->kod_k))
      aadd(arr_ne, alltrim(kart->fio)+" д.р."+full_date(kart->date_r))
    endif
    select TMP2
    skip
  enddo
  close databases
  //
  at := {glob_mo[_MO_SHORT_NAME],"[ "+charrem("~",mas1pmt[par])+" за вычетом отказов в оплате ]",arr_m[4]}
  print_shablon("svod_dvn",{arr_21,at,ar},"tmp1.txt",.f.)
  fp := fcreate("tmp2.txt") ; n_list := 1 ; tek_stroke := 0
  fl := f_error_DVN(3,60,80)
  fclose(fp)
  if fl
    strfile("FF","tmp1.txt",.t.)
    feval("tmp2.txt",{|s| strfile(s+eos,"tmp1.txt",.t.) })
  endif
  viewtext("tmp1.txt",,,,,,,2)
endif
close databases
rest_box(buf)
return NIL

***** 06.10.19
Function f1_f21_inf_DVN()
Local sumr := 0, m1GRUPPA, fl2 := .f.
select TMP2
append blank
tmp2->kod_k := tmp->kod_k
// диспансеризация I этап
if empty(tmp->kod1h)
  // нет 1 этапа, но есть второй
else
  human->(dbGoto(tmp->kod1h))
  mdvozrast := year(human->n_data) - year(human->date_r)
  m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW,@fl2)
  if between(m1gruppa,0,4)
    tmp2->rslt1 := human_->RSLT_NEW
    if m1gruppa == 0
      fl2 := .t. // направлен на 2 этап
    endif
    Private m1veteran := 0, m1mobilbr := 0
    read_arr_DVN(human->kod,.f.)
    arr_21[3] ++
    if m1veteran == 1
      arr_21[4] ++
    endif
    if m1mobilbr == 1
      arr_21[5] ++
    endif
    if f_starshe_trudosp(human->POL,human->DATE_R,human->n_data)
      arr_21[19] ++
      if f_is_selo(kart_->gorod_selo,kart_->okatog)
        arr_21[20] ++
      endif
    endif
    if between(m1gruppa,1,4)
      arr_21[5+m1gruppa] ++
    endif
    f2_f21_inf_DVN(1)
    if human->schet > 0
      select SCHET_
      goto (human->schet)
      if !schet_->(eof()) .and. schet_->NREGISTR == 0 // только зарегистрированные
        arr_21[10] ++
        select RPDSH
        find (str(human->kod,7))
        do while rpdsh->KOD_H == human->kod .and. !eof()
          sumr += rpdsh->S_SL
          skip
        enddo
        if round(human->cena_1,2) == round(sumr,2) // полностью оплачен
          arr_21[11] ++
        endif
      endif
    endif
  else
    // почему-то неправильная группа
  endif
endif
if fl2 // направлен на 2 этап
  arr_21[12] ++ // направлен на 2 этап
endif
if !empty(tmp->kod2h) // диспансеризация II этап
  human->(dbGoto(tmp->kod2h))
  m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW)
  if between(m1gruppa,1,4)
    tmp2->rslt2 := human_->RSLT_NEW
    if empty(tmp2->rslt1)
      //my_debug(,"II этап - нет первого "+lstr(human->kod)+" "+lstr(tmp->kod_k)+" "+human->fio)
    else
      arr_21[13] ++
      if !fl2  // не был направлен, но всё равно прошёл
        arr_21[12] ++ // направлен на 2 этап
      endif
    endif
  else
    // почему-то неправильная группа
  endif
endif
return NIL

***** 06.10.19
Function f2_f21_inf_DVN(par)
Local is_selo, i, j, k := 4, ar[17]
afill(ar,0) ; ar[2] := 1
if kart_->invalid > 0
  arr_21[21] ++
endif
if par == 1
  if mdvozrast < 40
    k := 1
  elseif mdvozrast < 65
    k := 2
  else
    k := 3
  endif
endif
if (is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog))
  ar[5] := 1
endif
if dow(human->k_data) == 7 // суббота
  ar[4] := 1
  if is_selo
    ar[7] := 1
  endif
endif
for i := 1 to 5
  pole_diag := "mdiag"+lstr(i)
  pole_1pervich := "m1pervich"+lstr(i)
  pole_1stadia := "m1stadia"+lstr(i)
  pole_1dispans := "m1dispans"+lstr(i)
  Private &pole_diag := space(6)
  Private &pole_1pervich := 0
  Private &pole_1stadia := 0
  Private &pole_1dispans := 0
next
read_arr_DVN(human->kod)
// диспансеризация II этап
if !empty(tmp->kod2h)
  human->(dbGoto(tmp->kod2h))
  m1GRUPPA2 := ret_gruppa_DVN(human_->RSLT_NEW)
  if between(m1gruppa2,1,4) // точно прошёл 2 этап
    read_arr_DVN(human->kod) // перечитать диагнозы и т.п.
  endif
endif
for i := 1 to 5
  pole_diag := "mdiag"+lstr(i)
  pole_1pervich := "m1pervich"+lstr(i)
  pole_1stadia := "m1stadia"+lstr(i)
  pole_1dispans := "m1dispans"+lstr(i)
  if !(left(&pole_diag,1) == "A" .or. left(&pole_diag,1) == "B") .and. &pole_1pervich == 1 // неинфекционные заболевания уст.впервые
    ar[8] := 1
    ar[9] ++
    if left(&pole_diag,1) == "I" // болезни системы кровообращения
      ar[10] := 1
    endif
    if left(&pole_diag,1) == "C" .or. between(left(&pole_diag,3),"D00","D09") // ЗНО
      ar[11] := 1
      if &pole_1stadia < 3 // 1 и 2 стадия
        ar[12] := 1
      endif
    endif
    if between(left(&pole_diag,3),"E10","E14") // сахарный диабет
      ar[13] := 1
      if left(&pole_diag,3) == "E10" // I стадия
        ar[14] := 1
      endif
    endif
    if &pole_1dispans == 1
      ar[15] := 1
    endif
    if .f. // 1-лечение назначено
      ar[16] := 1 // ?? было начато лечение
      if is_selo
        ar[17] := 1
      endif
    endif
  endif
next
pole := "tmp1->g"+lstr(k)
select TMP1
for i := 1 to len(ar)
  if ar[i] > 0
    find (str(i,2))
    &pole := &pole + ar[i]
  endif
next
return NIL

***** 20.10.16 Индикаторы мониторинга диспансеризации взрослых
Function f22_inf_DVN()
Static group_ini := "f22_inf_DVN"
Static as := {;
  {1, 0,0,"Общее число граждан, подлежащих диспансеризации в текущем году"},;
  {2, 0,0,"Количество граждан от числа подлежащих диспансеризации в текущем году, прошедших 1-й этап диспансеризации за отчетный период"},;
  {3, 0,0,"Количество граждан от числа подлежащих диспансеризации в текущем году, прошедших 2-й этап диспансеризации за отчетный период"},;
  {4, 0,0,"Количество граждан от числа подлежащих диспансеризации в текущем году, полностью завершивших диспансеризацию за отчетный период, из них:"},;
  {4, 1,0,"имеют I группу здоровья"},;
  {4, 2,0,"имеют II группу здоровья"},;
  {4, 3,0,"имеют IIIа группу здоровья"},;
  {4, 4,0,"имеют IIIб группу здоровья"},;
  {5, 0,0,"Количество граждан с впервые выявленными хроническими неинфекционными заболеваниями, из них:"},;
  {5, 1,0,"со стенокардией"},;
  {5, 2,0,"с хронической ишемической болезнью сердца"},;
  {5, 3,0,"с артериальной гипертонией"},;
  {5, 4,0,"со стенозом сонных артерий >50%"},;
  {5, 5,0,"с острым нарушением мозгового кровообращения в анамнезе"},;
  {5, 6,0,"с подозрением на злокачественное новообразование желудка по результатам фиброгастроскопии"},;
  {5, 6,1,"на ранней стадии"},;
  {5, 7,0,"с подозрением на злокачественным новообразованием матки и ее придатков"},;
  {5, 7,1,"на ранней стадии"},;
  {5, 8,0,"с подозрением на злокачественное новообразование простаты по данным осмотра врача-хирурга (уролога) и теста на простатспецифический антиген"},;
  {5, 8,1,"на ранней стадии"},;
  {5, 9,0,"с подозрением на злокачественное новообразование грудной железы по данным маммографии"},;
  {5, 9,1,"на ранней стадии"},;
  {5,10,0,"с подозрением на колоректальный рак по данным ректоромано- и колоноскопии"},;
  {5,10,1,"на ранней стадии"},;
  {5,11,0,"с подозрением на злокачественные заболевания других локализаций"},;
  {5,11,1,"на ранней стадии"},;
  {5,12,0,"с сахарным диабетом"},;
  {6, 0,0,"Количество граждан с впервые выявленным туберкулезом легких"},;
  {7, 0,0,"Количество граждан с впервые выявленной глаукомой, из них:"},;
  {7, 0,1,"на ранней стадии"},;
  {8, 0,0,"Количество граждан с впервые выявленными заболеваниями других органов и систем за отчетный период"},;
  {9, 0,0,"Количество граждан, имеющих факторы риска хронических неинфекционных заболеваний за отчетный период, из них:"},;
  {9, 1,0,"потребляют табак (курение)"},;
  {9, 2,0,"повышенное АД"},;
  {9, 3,0,"избыточная масса тела"},;
  {9, 4,0,"ожирение"},;
  {9, 5,0,"гиперхолестеринемия, дислипидемия"},;
  {9, 6,0,"гипергликемия"},;
  {9, 7,0,"недостаточная физическая активность"},;
  {9, 8,0,"нерациональное питание"},;
  {9, 9,0,"подозрением на пагубное потребление алкоголя"},;
  {9,10,0,"имеющие 2 фактора риска и более"},;
  {10,0,0,"Количество граждан с подозрением на зависимость от алкоголя, наркотиков и психотропных средств, из них:"},;
  {11,0,1,"число граждан, направленных к психиатру-наркологу"},;
  {12,0,0,"Количество граждан 2-й группы здоровья, прошедших углубленное профилактическое консультирование"},;
  {13,0,0,"Количество граждан 2-й группы здоровья, прошедших групповое профилактическое консультирование"},;
  {14,0,0,"Количество граждан 3-й группы здоровья, прошедших углубленное профилактическое консультирование"},;
  {15,0,0,"Количество граждан 3-й группы здоровья, прошедших групповое профилактическое консультирование"};
 }
Local i, ii, s, arr_m, buf := save_maxrow(), ar, arr_excel := {}
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) != NIL ;
                                   .and. (arr_m := year_month(,,,5)) != NIL
  Private mk1, mispoln, mtel_isp
  ar := GetIniSect(tmp_ini,group_ini)
  mk1 := int(val(a2default(ar,"mk1","0")))
  mispoln := padr(a2default(ar,"mispoln",""),20)
  mtel_isp := padr(a2default(ar,"mtel_isp",""),20)
  s := " \"+;
    "      Общее число граждан, подлежащих диспансеризации @          \"+;
    "      Фамилия и инициалы исполнителя @                           \"+;
    "      Телефон исполнителя            @                           \"+;
    " \"
  DisplBox(s,;
    , ;                   // цвет окна (умолч. - cDataCGet)
    {"mk1","mispoln","mtel_isp"},; // массив Private-переменных для редактирования
    {"999999",,},; // массив Picture для редактирования
    17)
  if lastkey() != K_ESC
    SetIniSect(tmp_ini,group_ini,{{"mk1",mk1},;
                                  {"mispoln",mispoln},;
                                  {"mtel_isp",mtel_isp};
                                 })
    mywait()
    if f0_inf_DVN(arr_m,.f.)
      mywait("Сбор статистики")
      delFRfiles()
      dbcreate(fr_data,{;
        {"nomer","C",5,0},;
        {"nn1","N",2,0},;
        {"nn2","N",2,0},;
        {"nn3","N",2,0},;
        {"name","C",250,0},;
        {"v1","N",6,0},;
        {"v2","N",6,0}})
      use (fr_data) new alias FRD
      for i := 1 to len(as)
        append blank
        if !empty(as[i,1]) .and. empty(as[i,2])
          frd->nomer := lstr(as[i,1])+"."
        endif
        frd->nn1 := as[i,1]
        frd->nn2 := as[i,2]
        frd->nn3 := as[i,3]
        frd->name := iif(!empty(as[i,1]), "", space(10))+;
                     iif( empty(as[i,2]), "", space(10))+;
                     iif( empty(as[i,3]), "", space(10))+;
                     as[i,4]
        if i == 1
          frd->v1 := frd->v2 := mk1
        endif
      next
      index on str(nn1,2)+str(nn2,2)+str(nn3,2) to (cur_dir+"tmp_frd")
      //
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_
      R_Use(dir_server+"schet_",,"SCHET_")
      ii := 0
      use (cur_dir+"tmp") index (cur_dir+"tmp") new
      go top
      do while !eof()
        @ maxrow(),0 say str(++ii/tmp->(lastrec())*100,6,2)+"%" color cColorWait
        if !emptyall(tmp->kod1h,tmp->kod2h) // только диспансеризация
          f1_f22_inf_DVN()
        endif
        select TMP
        skip
      enddo
      close databases
      R_Use(dir_server+"organiz",,"ORG")
      dbcreate(fr_titl, {{"name","C",130,0},;
                         {"period","C",100,0},;
                         {"ispoln","C",100,0},;
                         {"glavn","C",100,0}})
      use (fr_titl) new alias FRT
      append blank
      frt->name := glob_mo[_MO_SHORT_NAME]
      frt->period := arr_m[4]
      frt->glavn :=  "Главный врач __________________ "+fam_i_o(org->ruk)
      frt->ispoln := "исполнитель: "+alltrim(mispoln)+" __________________ тел."+alltrim(mtel_isp)
      //
      ar := {}
      aadd(ar, {2,3,month(arr_m[6]+1) })
      aadd(ar, {2,4,"."+lstr(year(arr_m[6]+1)) })
      use (fr_data) new alias FRD
      for i := 1 to len(as)
        goto (i)
        if i != 4
          aadd(ar, {8+i,3,frd->v1})
        endif
        if !eq_any(i,1,4)
          aadd(ar, {8+i,5,frd->v2})
        endif
      next
      aadd(ar, {59,1,frt->glavn })
      aadd(ar, {61,1,frt->ispoln})
      aadd(arr_excel, {"форма отчета",aclone(ar)})
      close databases
      call_fr("mo_dvnMZ")
    endif
  endif
endif
return NIL

*

***** 23.09.15
Function f1_f22_inf_DVN() // сводная информация
Local i, ar := {}, fl_reg1 := .f., fl_reg2 := .f., is_d := .f., is_pr := .f.,;
      k5 := 0, k9 := 0, m1gruppa, fl
// диспансеризация I этап
if empty(tmp->kod1h)
  // нет 1 этапа, но есть второй
else
  human->(dbGoto(tmp->kod1h))
  m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW)
  if !between(m1gruppa,0,4)
    return NIL
  endif
  Private m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, ;
          mholest := 0, mglukoza := 0,;
          m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
          m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, m1prof_ko := 0, ;
          pole_diag, pole_1stadia, pole_1pervich, mWEIGHT := 0, mHEIGHT := 0
  for i := 1 to 5
    pole_diag := "mdiag"+lstr(i)
    pole_1stadia := "m1stadia"+lstr(i)
    pole_1pervich := "m1pervich"+lstr(i)
    Private &pole_diag := space(6)
    Private &pole_1stadia := 0
    Private &pole_1pervich := 0
  next
  read_arr_DVN(human->kod)
  ret_tip_mas(mWEIGHT,mHEIGHT,@m1tip_mas)
  if human->schet > 0
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // только зарегистрированные
      fl_reg1 := .t.
    endif
  endif
  //
  aadd(ar,{2,0,0,fl_reg1})
  if m1kurenie == 1
    aadd(ar,{9,1,0,fl_reg1}) ; ++k9
  endif
  if mad1 > 140 .and. mad2 > 90
    aadd(ar,{9,2,0,fl_reg1}) ; ++k9
  endif
  if m1tip_mas == 3
    aadd(ar,{9,3,0,fl_reg1}) ; ++k9
  elseif m1tip_mas > 3
    aadd(ar,{9,4,0,fl_reg1}) ; ++k9
  endif
  if m1holestdn == 1 .or. mholest > 5
    aadd(ar,{9,5,0,fl_reg1}) ; ++k9
  endif
  if m1glukozadn == 1 .or. mglukoza > 6.1
    aadd(ar,{9,6,0,fl_reg1}) ; ++k9
  endif
  if m1fiz_akt == 1
    aadd(ar,{9,7,0,fl_reg1}) ; ++k9
  endif
  if m1ner_pit == 1
    aadd(ar,{9,8,0,fl_reg1}) ; ++k9
  endif
  if m1riskalk == 1
    aadd(ar,{9,9,0,fl_reg1}) ; ++k9
  endif
  if k9 > 1
    aadd(ar,{9,10,0,fl_reg1})
  endif
  if k9 > 0
    aadd(ar,{9,0,0,fl_reg1})
  endif
  if m1pod_alk == 1
    aadd(ar,{10,0,0,fl_reg1})
    if m1psih_na == 1
      aadd(ar,{11,0,1,fl_reg1})
    endif
  endif
  if !empty(tmp->kod2h) // диспансеризация II этап
    human->(dbGoto(tmp->kod2h))
    i := ret_gruppa_DVN(human_->RSLT_NEW)
    if between(i,1,4)
      m1gruppa := i
      if human->schet > 0
        select SCHET_
        goto (human->schet)
        if !schet_->(eof()) .and. schet_->NREGISTR == 0 // только зарегистрированные
          fl_reg2 := .t.
        endif
      endif
      aadd(ar,{3,0,0,fl_reg2})
      if i == 2
        if m1prof_ko == 0
          aadd(ar,{12,0,0,fl_reg2})
        elseif m1prof_ko == 1
          aadd(ar,{13,0,0,fl_reg2})
        endif
      elseif eq_any(i,3,4)
        if m1prof_ko == 0
          aadd(ar,{14,0,0,fl_reg2})
        elseif m1prof_ko == 1
          aadd(ar,{15,0,0,fl_reg2})
        endif
      endif
    else // если что-то не так со вторым этапом
      human->(dbGoto(tmp->kod1h)) // вернуться на 1 этап
    endif
  endif
  if between(m1gruppa,1,4)
    fl := fl_reg1 .or. fl_reg2
    aadd(ar,{4,0,0,fl})
    aadd(ar,{4,m1gruppa,0,fl})
    for i := 1 to 5
      pole_diag := "mdiag"+lstr(i)
      pole_1stadia := "m1stadia"+lstr(i)
      pole_1pervich := "m1pervich"+lstr(i)
      if !empty(&pole_diag) .and. &pole_1pervich==1
        is_d := .t.
        if left(&pole_diag,3) == "I20"
          aadd(ar,{5,1,0,fl}) ; ++k5
        elseif left(&pole_diag,3) == "I25"
          aadd(ar,{5,2,0,fl}) ; ++k5
        elseif eq_any(left(&pole_diag,3),"I10","I11","I12","I13","I15")
          aadd(ar,{5,3,0,fl}) ; ++k5
        elseif left(&pole_diag,5) == "I65.2"
          aadd(ar,{5,4,0,fl}) ; ++k5
        elseif left(&pole_diag,3) == "I66"
          aadd(ar,{5,5,0,fl}) ; ++k5
        elseif left(&pole_diag,1) == "C"
          if left(&pole_diag,3) == "C16"
            aadd(ar,{5,6,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,6,1,fl})
            endif
          elseif eq_any(left(&pole_diag,3),"C53","C54","C55")
            aadd(ar,{5,7,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,7,1,fl})
            endif
          elseif left(&pole_diag,3) == "C61"
            aadd(ar,{5,8,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,8,1,fl})
            endif
          elseif left(&pole_diag,3) == "C50"
            aadd(ar,{5,9,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,9,1,fl})
            endif
          elseif eq_any(left(&pole_diag,3),"C17","C18","C19","C20","C21")
            aadd(ar,{5,10,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,10,1,fl})
            endif
          else
            aadd(ar,{5,11,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,11,1,fl})
            endif
          endif
        elseif eq_any(left(&pole_diag,3),"E10","E11","E12","E13","E14")
          aadd(ar,{5,12,0,fl}) ; ++k5
        elseif eq_any(left(&pole_diag,3),"A15","A16")
          aadd(ar,{6,0,0,fl}) ; is_pr := .t.
        elseif left(&pole_diag,3) == "H40"
          aadd(ar,{7,0,0,fl}) ; is_pr := .t.
          if &pole_1stadia == 1
            aadd(ar,{7,1,1,fl})
          endif
        endif
      endif
    next
    if k5 > 0
      aadd(ar,{5,0,0,fl})
    endif
    if is_d .and. empty(k5) .and. !is_pr
      aadd(ar,{8,0,0,fl})
    endif
  endif
endif
if !empty(ar)
  select FRD
  for i := 1 to len(ar)
    find (str(ar[i,1],2)+str(ar[i,2],2)+str(ar[i,3],2))
    if found()
      frd->v1 ++
      if ar[i,4]
        frd->v2 ++
      endif
    endif
  next
endif
return NIL

***** 01.07.18 список пациентов
Function f2_inf_DVN(is_schet,par)
Local arr_m, buf := save_maxrow(), lkod_h, lkod_k, rec, s, as := {},;
      a, sh, HH := 53, n, n_file := "spis_dvn"+stxt, reg_print
Private ppar := par, p_is_schet := is_schet
if par > 1
  ppar--
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) != NIL .and. (arr_m := year_month(,,,5)) != NIL
  mywait()
  if f0_inf_DVN(arr_m,eq_any(is_schet,2,3),is_schet==3)
    adbf := {;
     {"nomer"    ,   "N",     6,     0},;
     {"KOD"      ,   "N",     7,     0},; // код (номер записи)
     {"KOD_K"    ,   "N",     7,     0},; // код по картотеке
     {"FIO"      ,   "C",    50,     0},; // Ф.И.О. больного
     {"DATE_R"   ,   "D",     8,     0},; // дата рождения больного
     {"N_DATA"   ,   "D",     8,     0},; // дата начала лечения
     {"K_DATA"   ,   "D",     8,     0},; // дата окончания лечения
     {"sroki"    ,   "C",    35,     0},; // сроки лечения
     {"CENA_1"   ,   "N",    10,     2},; // оплачиваемая сумма лечения
     {"KOD_DIAG" ,   "C",     5,     0},; // шифр 1-ой осн.болезни
     {"etap"     ,   "N",     1,     0},; //
     {"gruppa"   ,   "N",     1,     0},; //
     {"vrach"    ,   "C",    15,     0},; // врач
     {"DATA_O"   ,   "C",    35,     0} ; // сроки другого этапа
    }
    for i := 1 to max(count_dvn_arr_usl13,count_dvn_arr_usl)
      aadd(adbf,{"d_"+lstr(i),"C",24,0})
    next
    for i := 1 to max(count_dvn_arr_umolch13,count_dvn_arr_umolch)
      aadd(adbf,{"du_"+lstr(i),"C",8,0})
    next
    aadd(adbf,{"fl_2013","L",1,0})
    aadd(adbf,{"d_zs","C",8,0})
    dbcreate(cur_dir+"tmpfio",adbf)
    use (cur_dir+"tmpfio") new alias TF
    R_Use(dir_server+"uslugi",,"USL")
    use_base("human_u")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",,"HUMAN")
    set relation to recno() into HUMAN_
    R_Use(dir_server+"mo_pers",,"PERS")
    R_Use(dir_server+"schet_",,"SCHET_")
    use (cur_dir+"tmp") new
    go top
    do while !eof()
      @ maxrow(),0 say str(tmp->(recno())/tmp->(lastrec())*100,6,2)+"%" color cColorWait
      do case
        case par == 1
          if tmp->kod1h > 0
            f2_inf_DVN_svod(1,tmp->kod1h)
          endif
        case par == 2
          if tmp->kod1h > 0 .and. tmp->kod2h == 0
            f2_inf_DVN_svod(0,tmp->kod1h)
          endif
        case par == 3
          if tmp->kod1h > 0 .and. tmp->kod2h > 0
            f2_inf_DVN_svod(2,tmp->kod2h)
          endif
        case par == 4
          if tmp->kod3h > 0
            f2_inf_DVN_svod(3,tmp->kod3h)
          endif
      endcase
      select TMP
      skip
    enddo
    close databases
    mywait()
    at := {;
      {"Внутриглазное давление",{{1,.t.,1},{1,.f.,1}},0},;
      {"Кровь на общий холестерин",{{1,.t.,2},{1,.f.,2},{3,.t.,2},{3,.f.,2}},0},;
      {"Уровень глюкозы в крови",{{1,.t.,3},{1,.f.,3},{3,.t.,3},{3,.f.,3}},0},;
      {"Клинический анализ мочи",{{1,.t.,4},{1,.f.,4}},0},;
      {"Анализ крови (3 показателя)",{{1,.t.,5},{1,.f.,5},{3,.t.,5},{3,.f.,5}},0},;
      {"Анализ крови (развёрнутый)",{{1,.t.,6},{1,.f.,6}},0},;
      {"Биохимический анализ крови",{{1,.t.,7},{1,.f.,7}},0},;
      {"Кровь на простат-специфический антиген",{{1,.t.,8},{2,.f.,21}},0},;
      {"Исследование кала на скрытую кровь",{{1,.t.,9},{1,.f.,8},{3,.t.,9},{3,.f.,8}},0},;
      {"Осмотр акушеркой, взятие мазка (соскоба)",{{1,.t.,10},{1,.f.,9}},0},;
      {"Маммография молочных желез",{{1,.t.,11},{1,.f.,11},{3,.t.,11},{3,.f.,11}},0},;
      {"Флюорография лёгких",{{1,.t.,12},{1,.f.,12},{3,.t.,12},{3,.f.,12}},0},;
      {"УЗИ брюшной полости",{{1,.t.,13},{1,.f.,13},{1,.f.,15}},0},;
      {"Электрокардиография (в покое)",{{1,.t.,14},{1,.f.,16}},0},;
      {"Спирометрия",{{2,.f.,17}},0},;
      {"Гликированный гемоглобин крови",{{2,.t.,15},{2,.f.,18}},0},;
      {"Толерантность к глюкозе",{{2,.t.,16},{2,.f.,19}},0},;
      {"Липидный спектр крови",{{2,.t.,17},{2,.f.,20}},0},;
      {"Сканир-ие брахиоцефальных артерий",{{2,.t.,18},{2,.f.,22}},0},;
      {"Фиброэзофагогастродуоденоскопия",{{2,.t.,19},{2,.f.,23}},0},;
      {"Ректоскопия диагностическая",{{2,.t.,20},{2,.f.,24}},0},;
      {"Ректосигмоколоноскопия диагностическая",{{2,.t.,21},{2,.f.,25}},0},;
      {"Приём врача невролога",{{1,.t.,22},{2,.t.,22},{2,.f.,26}},0},;
      {"Приём врача офтальмолога",{{2,.t.,23},{2,.f.,27}},0},;
      {"Приём врача оториноларинголога",{{2,.f.,28}},0},;
      {"Приём врача уролога (хирурга)",{{2,.t.,24},{2,.f.,29}},0},;
      {"Приём врача акушера-гинеколога",{{2,.t.,25},{2,.f.,30}},0},;
      {"Приём врача колопроктолога (хирурга)",{{2,.t.,26},{2,.f.,31}},0},;
      {"Приём врача терапевта",{{1,.t.,27},{1,.f.,32},{2,.t.,27},{2,.f.,32},{3,.t.,27},{3,.f.,32}},0};
    }
    lat := len(at)
    aitog := array(lat) ; afill(aitog,0) ; is_zs := 0
    use (cur_dir+"tmpfio") new alias TF
    index on upper(fio) to (cur_dir+"tmpfio")
    go top
    do while !eof()
      for i := 1 to iif(tf->fl_2013,count_dvn_arr_usl13,count_dvn_arr_usl)
        pole := "tf->d_"+lstr(i)
        if !empty(&pole)
          for j := 1 to lat
            if at[j,3] == 0 .and. ascan(at[j,2],{|x| x[1]==ppar .and. x[2]==tf->fl_2013 .and. x[3]==i }) > 0
              at[j,3] := 1 ; exit
            endif
          next
        endif
      next
      if empty(is_zs) .and. !empty(tf->d_zs)
        is_zs := 1
      endif
      skip
    enddo
    arr_title := {;
      "────────────┬────┬──────────┬─────",;
      "            │Дата│  Сроки   │ Осн.",;
      "    Ф.И.О   │рожд│ лечения  │диаг-",;
      "            │ения│          │ ноз ",;
      "────────────┴────┴──────────┴─────"}
    if ppar == 2
      arr_title[1] += "┬──────────"
      arr_title[2] += "│Информация"
      arr_title[3] += "│о I этапе "
      arr_title[4] += "│диспан-ции"
      arr_title[5] += "┴──────────"
    endif
    for i := 1 to lat
      if at[i,3] > 0
        arr_title[1] += "┬────────"
        arr_title[2] += "│"+padr(substr(at[i,1], 1,8),8)
        arr_title[3] += "│"+padr(substr(at[i,1], 9,8),8)
        arr_title[4] += "│"+padr(substr(at[i,1],17,8),8)
        arr_title[5] += "┴────────"
      endif
    next
    if is_zs > 0
      arr_title[1] += "┬────────"
      arr_title[2] += "│  шифр  "
      arr_title[3] += "│закончен"
      arr_title[4] += "│ случая "
      arr_title[5] += "┴────────"
    endif
    if ppar == 1
      arr_title[1] += "┬──────────"
      arr_title[2] += "│Информация"
      arr_title[3] += "│о II этапе"
      arr_title[4] += "│диспан-ции"
      arr_title[5] += "┴──────────"
    endif
    arr_title[1] += "┬─┬───────"
    arr_title[2] += "│Г│ Сумма "
    arr_title[3] += "│р│ случая"
    arr_title[4] += "│у│ Врач"
    arr_title[5] += "┴─┴───────"
    reg_print := f_reg_print(arr_title,@sh,2)
    fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
    add_string("")
    if ppar == 1
      add_string(center("Диспансеризация взрослого населения 1 этап",sh))
      if par == 2
        add_string(center("направлены на 2 этап, но ещё не прошли",sh))
      endif
    elseif ppar == 2
      add_string(center("Диспансеризация взрослого населения 2 этап",sh))
    else
      add_string(center("Профилактика взрослого населения",sh))
    endif
    if is_schet == 4
      add_string(center("[ случаи, ещё не попавшие в счета ]",sh))
    else
      add_string(center("[ "+charrem("~",mas1pmt[is_schet])+" ]",sh))
    endif
    add_string(center(arr_m[4],sh))
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    j1 := ss := 0
    go top
    do while !eof()
      s := lstr(++j1)+". "+tf->fio
      s1 := substr(s, 1,12)+" "
      s2 := substr(s,13,12)+" "
      s3 := substr(s,25,12)+" "
      s := full_date(tf->date_r)
      s1 += padr(substr(s,1,3),5)
      s2 += padr(substr(s,4,3),5)
      s3 += padr(substr(s,7)  ,5)
      //
      s1 += padr(substr(tf->sroki, 1,9),11)
      s2 += padr(substr(tf->sroki,10,9),11)
      s3 += padr(substr(tf->sroki,19)  ,11)
      //
      s1 += padr(tf->KOD_DIAG,6)
      s2 += space(6)
      s3 += space(6)
      if ppar == 2
        s1 += padr(substr(tf->data_o, 1,9),11)
        s2 += padr(substr(tf->data_o,10,9),11)
        s3 += padr(substr(tf->data_o,19)  ,11)
      endif
      for i := 1 to lat
        if at[i,3] > 0
          fl := .t.
          for j := 1 to len(at[i,2])
            if at[i,2,j,1] == ppar .and. at[i,2,j,2] == tf->fl_2013
              pole := "tf->d_"+lstr(at[i,2,j,3]) // номер элемента из массива ф-ии mo_init
              if !empty(&pole)
                s1 += padr(substr(&pole, 1,8),9)
                s2 += padr(substr(&pole, 9,8),9)
                s3 += padr(substr(&pole,17)  ,9)
                if between(left(&pole,1),'0','9')
                  aitog[i] ++
                endif
                fl := .f.
                exit
              endif
            endif
          next
          if fl
            s1 += space(9)
            s2 += space(9)
            s3 += space(9)
          endif
        endif
      next
      if is_zs > 0
        s1 += padr(tf->d_zs,9)
        s2 += space(9)
        s3 += space(9)
      endif
      if ppar == 1
        s1 += padr(substr(tf->data_o, 1,9),11)
        s2 += padr(substr(tf->data_o,10,9),11)
        s3 += padr(substr(tf->data_o,19)  ,11)
      endif
      s1 += iif(tf->gruppa == 4, "3", put_val(tf->gruppa,1))+str(tf->CENA_1,8,2)
      if ppar < 3 .and. tf->gruppa > 2
        s2 += iif(tf->gruppa == 3, "а", "б")
      endif
      s3 += alltrim(tf->vrach)
      ss += tf->CENA_1
      if verify_FF(HH-3,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s1)
      add_string(s2)
      add_string(s3)
      add_string(replicate("─",sh))
      skip
    enddo
    s1 := padr("Итого:",13+5+11+6)
    if ppar == 2
      s1 += space(11)
    endif
    for i := 1 to lat
      if at[i,3] > 0
        if empty(aitog[i])
          space(9)
        else
          s1 += padc(lstr(aitog[i]),8)+" "
        endif
      endif
    next
    i := 0
    if is_zs > 0
      i += 9
    endif
    if ppar == 1
      i += 11
    endif
    i += 2
    s1 += str(ss,7+i,2)
    add_string(s1)
    close databases
    fclose(fp)
    Private yes_albom := .t.
    viewtext(n_file,,,,(sh>80),,,reg_print)
  endif
endif
close databases
rest_box(buf)
return NIL

***** 01.07.18
Function f2_inf_DVN_svod(par,kod_h) // сводная информация
Static P_BEGIN_RSLT := 342
Local i, j, c, s, pole, ar, arr := {}, fl, lshifr, arr_usl := {}
Private metap := ppar, m1gruppa, mvozrast, mdvozrast, mpol, mn_data, mk_data,;
        arr_usl_dop := {}, arr_usl_otkaz := {}, arr_otklon := {}, m1veteran := 0, mvar,;
        fl2 := .f., mshifr_zs := "", is_2013
select HUMAN
goto (kod_h)
mpol    := human->pol
mn_data := human->n_data
mk_data := human->k_data
is_2013 := year(mk_data) < 2018
if ppar == 1 // диспансеризация 1 этап
  m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW,@fl2)
  if between(m1gruppa,0,4)
    if m1gruppa == 0
      fl2 := .t. // направлен на 2 этап
    endif
  else
    return NIL
  endif
  if par == 0 .and. !fl2
    return NIL
  endif
elseif ppar == 2 // диспансеризация 2 этап
  m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW)
  if between(m1gruppa,1,4)
    //
  else
    return NIL
  endif
elseif ppar == 3 // профилактика
  m1GRUPPA := human_->RSLT_NEW-P_BEGIN_RSLT
  if !between(m1gruppa,1,3)
    return NIL
  endif
else
  return NIL
endif
read_arr_DVN(kod_h)
mvozrast := count_years(human->date_r,human->n_data)
mdvozrast := year(human->n_data) - year(human->date_r)
if m1veteran == 1
  mdvozrast := ret_vozr_DVN_veteran(mdvozrast,human->k_data)
endif
for i := 1 to iif(is_2013,count_dvn_arr_usl13,count_dvn_arr_usl)
  mvar := "MTAB_NOMv"+lstr(i)
  Private &mvar := 0
  mvar := "MDATE"+lstr(i)
  Private &mvar := ctod("")
  mvar := "M1OTKAZ"+lstr(i)
  Private &mvar := 0
next
fl := .f.
if ppar == 1 .and. tmp->kod2h > 0
  select HUMAN
  goto (tmp->kod2h)
  fl := (human_->oplata != 9)
elseif ppar == 2 .and. tmp->kod1h > 0
  select HUMAN
  goto (tmp->kod1h)
  fl := (human_->oplata != 9)
endif
if fl
  s := "не в счёте"
  if human->schet > 0
    s := "незарег.сч"
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // зарегистрированные
      s := "счёт зарег"
    endif
  endif
  aadd(arr,{human->n_data,human->k_data,s})
endif
select HUMAN
goto (kod_h)
if p_is_schet == 4 .and. human->schet > 0
  return NIL
endif
s := "не в счёте"
if human->schet > 0
  s := "незарег.сч"
  select SCHET_
  goto (human->schet)
  if !schet_->(eof()) .and. schet_->NREGISTR == 0 // зарегистрированные
    s := "счёт зарег"
  endif
endif
select TF
append blank
tf->KOD    := human->kod
tf->KOD_K  := tmp->kod_k
tf->FIO    := human->fio
tf->DATE_R := human->date_r
tf->N_DATA := mN_DATA
tf->K_DATA := mK_DATA
tf->sroki  := date_8(mN_DATA)+"-"+date_8(mK_DATA)+" "+s
tf->CENA_1 := human->CENA_1
tf->etap   := metap
tf->gruppa := m1gruppa
tf->KOD_DIAG := human->kod_diag
if len(arr) > 0
  tf->data_o := date_8(arr[1,1])+"-"+date_8(arr[1,2])+" "+arr[1,3]
endif
pers->(dbGoto(human_->vrach))
tf->vrach := fam_i_o(pers->fio)
lcount := iif(is_2013,count_dvn_arr_usl13,count_dvn_arr_usl)
larr_dvn := iif(is_2013,dvn_arr_usl13,dvn_arr_usl)
lcount_u := iif(is_2013,count_dvn_arr_umolch13,count_dvn_arr_umolch)
larr_dvn_u := iif(is_2013,dvn_arr_umolch13,dvn_arr_umolch)
larr := array(2,lcount) ; afillall(larr,0)
select HU
find (str(kod_h,7))
do while hu->kod == kod_h .and. !eof()
  usl->(dbGoto(hu->u_kod))
  if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
    lshifr := usl->shifr
  endif
  lshifr := alltrim(lshifr)
  if !eq_any(left(lshifr,5),"70.3.","70.7.","72.1.","72.5.","72.6.","72.7.","2.90.")
    mshifr_zs := lshifr
  else
    fl := .t.
    if metap != 2
      if is_2013
        if lshifr == "2.3.3" .and. hu_->PROFIL == 3 ; // акушерскому делу
            .and. (i := ascan(dvn_arr_usl13, {|x| valtype(x[2])=="C" .and. x[2]=="4.20.1"})) > 0
          fl := .f. ; larr[1,i] := hu->(recno())
        endif
      else
        /*if ((lshifr == "2.3.3" .and. hu_->PROFIL == 3) .or.  ; // акушерскому делу
              (lshifr == "2.3.1" .and. hu_->PROFIL == 136))  ; // акушерству и гинекологии
            .and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"})) > 0
          fl := .f. ; larr[1,i] := hu->(recno())
        endif*/
      endif
    endif
    if fl
      for i := 1 to lcount_u
        if empty(larr[2,i]) .and. larr_dvn_u[i,2] == lshifr
          fl := .f. ; larr[2,i] := hu->(recno()) ; exit
        endif
      next
    endif
    if fl
      for i := 1 to lcount
        if empty(larr[1,i])
          if valtype(larr_dvn[i,2]) == "C"
            if larr_dvn[i,2] == lshifr
              fl := .f.
            elseif larr_dvn[i,2] == "4.20.1" .and. lshifr == "4.20.2"
              fl := .f.
            endif
          elseif len(larr_dvn[i]) > 11
            if ascan(larr_dvn[i,12],{|x| x[1]==lshifr .and. x[2]==hu_->PROFIL}) > 0
              fl := .f.
            endif
          endif
          if !fl
            larr[1,i] := hu->(recno()) ; exit
          endif
        endif
      next
    endif
  endif
  aadd(arr_usl,hu->(recno()))
  select HU
  skip
enddo
for i := 1 to lcount
  if !empty(larr[1,i])
    hu->(dbGoto(larr[1,i]))
    if hu->kod_vr > 0
      mvar := "MTAB_NOMv"+lstr(i)
      &mvar := hu->kod_vr
    endif
    mvar := "MDATE"+lstr(i)
    &mvar := c4tod(hu->date_u)
    mvar := "M1OTKAZ"+lstr(i)
    if metap != 2
      if is_2013
        if hu_->PROFIL == 3 .and. ;
            ascan(dvn_arr_usl13, {|x| valtype(x[2])=="C" .and. x[2]=="4.20.1"}) > 0
          &mvar := 2 // невозможность выполнения
        endif
      else
        /*if (hu_->PROFIL == 3 .or. hu_->PROFIL == 136)  ;
            .and. ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"}) > 0
          &mvar := 2 // невозможность выполнения
        endif*/
      endif
    endif
  endif
next
if metap != 2 .and. valtype(arr_usl_otkaz) == "A"
  for j := 1 to len(arr_usl_otkaz)
    ar := arr_usl_otkaz[j]
    if valtype(ar) == "A" .and. len(ar) >= 5 .and. valtype(ar[5]) == "C"
      lshifr := alltrim(ar[5])
      if (i := ascan(larr_dvn, {|x| valtype(x[2])=="C" .and. x[2]==lshifr})) > 0
        if valtype(ar[1]) == "N" .and. ar[1] > 0
          mvar := "MTAB_NOMv"+lstr(i)
          &mvar := ar[1]
        endif
        mvar := "MDATE"+lstr(i)
        &mvar := mn_data
        if len(ar) >= 9 .and. valtype(ar[9]) == "D"
          &mvar := ar[9]
        endif
        mvar := "M1OTKAZ"+lstr(i)
        &mvar := 1
        if len(ar) >= 10 .and. valtype(ar[10]) == "N" .and. between(ar[10],1,2)
          &mvar := ar[10]
        endif
      endif
    endif
  next
endif
//
if is_2013
  arr := f21_inf_DVN_svod13(1)
else
  arr := f21_inf_DVN_svod(1)
endif
for i := 1 to len(arr)
  pole := "tf->d_"+lstr(arr[i,4])
  if arr[i,5] == 1
    &pole := "отказ   пациента"
  elseif arr[i,5] == 2
    &pole := "невозможность выполнения"
  else
    &pole := date_8(arr[i,2])
  endif
next
tf->d_zs := mshifr_zs
tf->fl_2013 := is_2013
if is_2013
  arr := f21_inf_DVN_svod13(2)
else
  arr := f21_inf_DVN_svod(2)
endif
for i := 1 to len(arr)
  pole := "tf->du_"+lstr(arr[i,4])
  &pole := date_8(arr[i,2])
next
return NIL

***** 08.11.13
Function f21_inf_DVN_svod13(par)
Local i, arr := {}
if par == 1
  for i := 1 to count_dvn_arr_usl13
    mvart := "MTAB_NOMv"+lstr(i)
    mvard := "MDATE"+lstr(i)
    mvaro := "M1OTKAZ"+lstr(i)
    if f_is_usl_oms_sluch_DVN13(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol)
      if !emptyany(&mvard,&mvart)
        aadd(arr, {dvn_arr_usl13[i,1], &mvard, "", i, &mvaro})
      endif
    endif
  next
else
  for i := 1 to count_dvn_arr_umolch13
    if f_is_umolch_sluch_DVN13(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol)
      aadd(arr, {dvn_arr_umolch13[i,1], iif(dvn_arr_umolch13[i,8]==0, mn_data, mk_data), "", i, 0})
    endif
  next
endif
return arr

***** 08.12.15
Function f21_inf_DVN_svod(par)
Local i, arr := {}
if par == 1
  for i := 1 to count_dvn_arr_usl
    mvart := "MTAB_NOMv"+lstr(i)
    mvard := "MDATE"+lstr(i)
    mvaro := "M1OTKAZ"+lstr(i)
    if f_is_usl_oms_sluch_DVN(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol)
      if !emptyany(&mvard,&mvart)
        aadd(arr, {dvn_arr_usl[i,1], &mvard, "", i, &mvaro})
      endif
    endif
  next
else
  for i := 1 to count_dvn_arr_umolch
    if f_is_umolch_sluch_DVN(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol)
      aadd(arr, {dvn_arr_umolch[i,1], iif(dvn_arr_umolch[i,8]==0, mn_data, mk_data), "", i, 0})
    endif
  next
endif
return arr

***** 11.02.19 вернуть план диспансеризации на год из R01 для фрмы 131
Function ret_plan_disp_131(d)
Local arr[2,3], ar, s, s1, fl, sgod := year(d), v, i, j, group_ini := "DISP_PLAN_131"
ar := GetIniSect(tools_ini,group_ini)
fl := .f.
if len(ar) > 0
  for v := 1 to len(ar)
    s := ar[v,1]
    s1 := beforatnum("-",s,1) ; s := afteratnum("-",s,1)
    if int(val(s1)) == sgod
      i := int(val(s))
      j := int(val(afteratnum("-",s,1)))
      if between(i,1,2) .and. between(j,1,3)
        arr[i,j] := int(val(ar[v,2]))
      endif
    endif
  next
  fl := .t.
  for i := 1 to 2
    for j := 1 to 3
      if !(valtype(arr[i,j]) == "N")
        fl := .f.
      endif
    next
  next
endif
if !fl
  afillall(arr,0)
endif
if sgod >= 2019 .and. !fl
  R_Use(dir_server+"kartotek",,"KART")
  G_Use(dir_server+"mo_dr01k",,"R01")
  index on str(kod_k,7) to (cur_dir+"tmp_r01") ;
        for kod_k > 0 .and. oplata == 1 .and. tip == 1 .and. TYPEOFREC == 0
  go top
  do while !eof()
    select KART
    goto (r01->kod_k)
    v := sgod - year(kart->date_r)
    i := iif(kart->pol == "М", 1, 2)
    if v < 39
      j := 1
    elseif v < 61
      j := 2
    else
      j := 3
    endif
    arr[i,j] ++
    select R01
    skip
  enddo
  ar := {}
  for i := 1 to 2
    for j := 1 to 3
      aadd(ar, {lstr(sgod)+"-"+lstr(i)+"-"+lstr(j),arr[i,j]})
    next
  next
  SetIniSect(tools_ini, group_ini, ar) // запись секции в ini.файл
  close databases
endif
return arr

***** 15.09.19 форма 131
Function forma_131(par)
Static arr_v := {"21-36 лет","39-60 лет","старше 60 лет"}
Local arr_m, buf := save_maxrow(), s, as := {}, ar, sh := 80, HH := 80, n, ;
      ii, n_file := "f_131"+stxt, d1, d2, fl, arr_excel := {}, arr_plan_god
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) != NIL .and. (arr_m := year_month(,,,5)) != NIL
  mywait()
  if f0_inf_DVN(arr_m,par > 1,par == 3,.t.)
    mywait("Сбор статистики")
    arr_plan_god := ret_plan_disp_131(arr_m[5])
    dbcreate(cur_dir+"tmp1000",{{"vozrast","N",1,0},;
                                {"vm1","N",8,0},;
                                {"vm2","N",8,0},;
                                {"vg1","N",8,0},;
                                {"vg2","N",8,0}})
    use (cur_dir+"tmp1000") new alias TMP
    for n := 1 to 3
      append blank
      tmp->vozrast := n
    next
    index on str(vozrast,1) to (cur_dir+"tmp1000")
    use
    //
    Private arr_2000 := {;
      { 1,"Опрос (анкетирование), на выявление ... заболеваний","56.1.16"},;
      { 2,"Антропометрия (измерение роста стоя, массы тела...","3.1.19"},;
      { 3,"Измерение артериального давления","3.1.5"},;
      { 4,"Определение уровня общего холестерина в крови","4.12.174"},;
      { 5,"Определение уровня глюкозы в крови","4.12.169"},;
      { 6,"Определение относительного суммарного сердечно-сосудистого риска",{"56.1.17","56.1.18"},"mdvozrast < 40"},;
      { 7,"Определение абсолютного суммарного сердечно-сосудистого риска",{"56.1.17","56.1.19"},"39 < mdvozrast .and. mdvozrast < 66"},;
      { 8,"Электрокардиография в покое","13.1.1"},;
      { 9,"Осмотр фельдшером (акушеркой), включая взятие мазка",{"4.1.12","4.20.1","4.20.2"}},;
      {10,"Флюорография легких","7.61.3"},;
      {11,"Маммография обеих молочных желез","7.57.3"},;
      {12,"Клинический анализ крови","4.11.137"},;
      {13,"Клинический анализ крови развернутый","4.11.136"},;
      {14,"Анализ крови биохимический общетерапевтический","4.12.172"},;
      {15,"Общий анализ мочи","4.2.153"},;
      {16,"Исследование кала на скрытую кровь","4.8.4"},;
      {17,"УЗИ органов брюшной полости",{"8.2.1","8.2.4","8.2.5"}},;
      {18,"УЗИ в целях исключения аневризмы брюшной аорты","8.1.5"},;
      {19,"Измерение внутриглазного давления","3.4.9"},;
      {20,"Прием (осмотр) врача-терапевта",{{"2.3.1",97},{"2.3.1",57},{"2.3.2",97},{"2.3.2",57},{"2.3.3",42},{"2.3.5",57},{"2.3.5",97},{"2.3.6",57},{"2.3.6",97}}};
     }
    dbcreate(cur_dir+"tmp2000",{{"name","C",100,0},;
                                {"ns","N",2,0},;
                                {"vv","N",8,0},;
                                {"vr","N",8,0},;
                                {"vo","N",8,0},;
                                {"vd","N",8,0}})
    use (cur_dir+"tmp2000") new alias TMP
    for n := 1 to len(arr_2000)
      append blank
      tmp->name := arr_2000[n,2]
      tmp->ns := arr_2000[n,1]
    next
    index on str(ns,2) to (cur_dir+"tmp2000")
    use
    //
    Private v3001 := 0, arr_3000 := {;
      { 1,"Дуплексное сканирование брахицефальных артерий",{"8.23.6","8.23.706"}},;
      { 2,"Осмотр врача-невролога","2.84.1"},;
      { 3,"Эзофагогастродуоденоскопия","10.3.13"},;
      { 4,"Осмотр врача-уролога","2.84.10"},;
      { 5,"Осмотр врача-колопроктолога","2.84.6"},;
      { 6,"Колоноскопия (ректороманоскопия)",{"10.4.1","10.6.10","10.6.710"}},;
      { 7,"Определение липидного спектра крови","4.12.173"},;
      { 8,"Спирометрия",{"16.1.17","16.1.717"}},;
      { 9,"Осмотр врача-акушера-гинеколога","2.84.5"},;
      {10,"Глик.гемоглобин/тест на толерантность к глюкозе",{"4.12.170","4.12.171"}},;
      {11,"Осмотр врача-оториноларинголога","2.84.8"},;
      {12,"Анализ крови на ПСА","4.14.66"},;
      {13,"Осмотр врача-офтальмолога","2.84.3"},;
      {14,"Индивидуальное профилактическое консультирование",{"56.1.15","56.1.20","56.1.723"}},;
      {15,"Групповое профилактическое консультирование","0"},;
      {16,"Прием (осмотр) врача-терапевта",{"2.84.2","2.84.7","2.84.9","2.84.11"}};
     }
    dbcreate(cur_dir+"tmp3000",{{"name","C",100,0},;
                                {"ns","N",2,0},;
                                {"vv","N",8,0},;
                                {"vd","N",8,0}})
    use (cur_dir+"tmp3000") new alias TMP
    for n := 1 to len(arr_3000)
      append blank
      tmp->name := arr_3000[n,2]
      tmp->ns := arr_3000[n,1]
    next
    index on str(ns,2) to (cur_dir+"tmp3000")
    use
    //
    Private v4001_1 := 0, v4001_2 := 0, v4002_1 := 0, v4002_2 := 0, arr_4000 := {;
      { 1,"Повышенный уровень артериального давления","mad1>140.and.mad2>90"},;
      { 2,"Гипергликемия неуточненная","m1glukozadn==1.or.mglukoza>6.1"},;
      { 3,"Избыточная масса тела","m1tip_mas>=3"},;
      { 4,"Курение табака","m1kurenie==1"},;
      { 5,"Риск пагубного потребления алкоголя","m1riskalk==1"},;
      { 6,"Риск потребления наркотических средств","m1pod_alk==1"},;
      { 7,"Низкая физическая активность","m1fiz_akt==1"},;
      { 8,"Нерациональное питание","m1ner_pit==1"},;
      { 9,"Отягощенная наследственность","m1ot_nasl1==1.or.m1ot_nasl2==1.or.m1ot_nasl3==1.or.m1ot_nasl4==1"},;
      {10,"Высокий абс.суммарный сердечно-сосудистый риск","39<mdvozrast.and.mdvozrast<66.and.5<=mssr.and.mssr<10"},;
      {11,"Очень высокий абс.суммарный сердечно-сосудистый риск","39<mdvozrast.and.mdvozrast<66.and.10<=mssr"};
     }
    dbcreate(cur_dir+"tmp4000",{{"name","C",100,0},;
                                {"ns","N",2,0},;
                                {"m36","N",8,0},;
                                {"m39","N",8,0},;
                                {"mvv","N",8,0},;
                                {"g36","N",8,0},;
                                {"g39","N",8,0},;
                                {"gvv","N",8,0},;
                                {"v36","N",8,0},;
                                {"v39","N",8,0},;
                                {"vvv","N",8,0}})
    use (cur_dir+"tmp4000") new alias TMP
    for n := 1 to len(arr_4000)
      append blank
      tmp->name := arr_4000[n,2]
      tmp->ns := arr_4000[n,1]
    next
    index on str(ns,2) to (cur_dir+"tmp4000")
    use
    //
    Private arr_5000 := {;
      { 7,"1","Некоторые инфекционные и паразитарные болезни","A00-B99"},;
      { 8,"1.1","в т.ч. туберкулез","A15-A19"},;
      { 9,"2","Новообразования","C00-D48"},;
      {10,"2.1","в т.ч. злокачественные новообразования","C00-D09"},;
      {11,"2.2","в т.ч. пищевода","C15,D00.1"},;
      {12,"2.2.1"," из них в 1-2 стадии","C15,D00.1","1"},;
      {13,"2.3","желудка","C16,D00.2"},;
      {14,"2.3.1"," из них в 1-2 стадии","C16,D00.2","1"},;
      {15,"2.4","ободочной кишки","C18,D01.0"},;
      {16,"2.4.1"," из них в 1-2 стадии","C18,D01.0","1"},;
      {17,"2.5","прямой кишки...","C19-C21,D01.1-D01.3"},;
      {18,"2.5.1"," из них в 1-2 стадии","C19-C21,D01.1-D01.3","1"},;
      {19,"2.6","поджелудочной железы","C25"},;
      {20,"2.6.1"," из них в 1-2 стадии","C25","1"},;
      {21,"2.7","трахеи, бронхов и легкого","C33,C34,D02.1-D02.2"},;
      {22,"2.7.1"," из них в 1-2 стадии","C33,C34,D02.1-D02.2","1"},;
      {23,"2.8","молочной железы","C50,D05"},;
      {24,"2.8.1"," из них в 1-2 стадии","C50,D05","1"},;
      {25,"2.9","шейки матки","C53,D06"},;
      {26,"2.9.1"," из них в 1-2 стадии","C53,D06","1"},;
      {27,"2.10","тела матки","C54"},;
      {28,"2.10.1"," из них в 1-2 стадии","C54","1"},;
      {29,"2.11","яичника","C56"},;
      {30,"2.11.1"," из них в 1-2 стадии","C56","1"},;
      {31,"2.12","предстательной железы","C61,D07.5"},;
      {32,"2.12.1"," из них в 1-2 стадии","C61,D07.5","1"},;
      {33,"2.13","почки (кроме почечной лоханки)","C64"},;
      {34,"2.13.1"," из них в 1-2 стадии","C64","1"},;
      {35,"3","Болезни крови, кроветворных...","D50-D89"},;
      {36,"3.1","в т.ч. анемии","D50-D64"},;
      {37,"4","Болезни эндокринной системы...","E00-E90"},;
      {38,"4.1","в т.ч. сахарный диабет","E10-E14"},;
      {39,"4.2","ожирение","E66"},;
      {40,"4.3","липидемии","E78"},;
      {41,"5","Болезни нервной системы","G00-G99"},;
      {42,"5.1","в т.ч. преходящие транзиторные","G45"},;
      {43,"6","Болезни глаза и его придаточного аппарата","H00-H59"},;
      {44,"6.1","в т.ч. катаракта","H25,H26"},;
      {45,"6.2","глаукома","H40"},;
      {46,"6.3","слепота и пониженное зрение","H54"},;
      {47,"7","Болезни системы кровообращения","I00-I99"},;
      {48,"7.1","в т.ч. болезни, характ","I10-I15"},;
      {49,"7.2","ишемическая болезнь сердца","I20-I25"},;
      {50,"7.2.1","в т.ч. стенокардия","I20"},;
      {51,"7.2.2","в т.ч. нестабильная стенокардия","I20.0"},;
      {52,"7.2.3","хроническая ишемическая болезнь сердца","I25"},;
      {53,"7.2.4","в т.ч. инфаркт миокарда","I25.2"},;
      {54,"7.3","другие болезни сердца","I30-I52"},;
      {55,"7.4","цереброваскулярные болезни","I60-I69"},;
      {56,"7.4.1","в т.ч. закупорка и стеноз","I65,I66"},;
      {57,"7.4.2","другие цереброваскулярные болезни","I67"},;
      {58,"7.4.3","Последсвия инсульта","I69.0-I69.4"},;
      {59,"7.4.4","аневризма брюшной аорты","I71.3-I71.4"},;
      {60,"8","Болезни органов дыхания","J00-J98"},;
      {61,"8.1","в т.ч. пневмония","J12-J18"},;
      {62,"8.2","бронхит хронический и неуточненный, эмфизема","J40-J43"},;
      {63,"8.3","другая хроническая обструктивная легочная болезнь","J44-J47"},;
      {64,"9","Болезни органов пищеварения","K00-K93"},;
      {65,"9.1","в т.ч. язва желудка, двен","K25,K26"},;
      {66,"9.2","гастрит и дуоденит","K29"},;
      {67,"9.3","неинфекционный энтерит и колит","K50-K52"},;
      {68,"9.4","другие болезни кишечника","K55-K63"},;
      {69,"10","Болезни мочеполовой системы","N00-N99"},;
      {70,"10.1","в т.ч. болезни предстательной железы","N40-N42"},;
      {71,"10.2","доброкачественная дисплазия молочной железы","N60"},;
      {72,"10.3","воспалительные болезни женских тазовых органов","N70-N77"},;
      {73,"11","Прочие заболевания",""},;
      { 0,"12","ИТОГО",""};
     }
    Private len5000 := len(arr_5000)
    Private diag5000 := array(len5000)
    //
    Private arr_5001 := {;
      {74,"11.1","Болезни уха и сосцевидного отростка","H60-H95"},;
      {75,"11.2","Болезни кожи и подкожной клетчатки","L00-L98"},;
      {76,"11.3","Болезни костно-мышечной системы","M00-M99"};
     }
    Private len5001 := len(arr_5001)
    Private diag5001 := array(len5001)
    //
    adbf := {{"name","C",100,0},;
             {"diagnoz","C",20,0},;
             {"ns","N",2,0},;
             {"stroke","C",8,0},;
             {"dispans","N",8,0},;
             {"m36","N",8,0},;
             {"m39","N",8,0},;
             {"mvv","N",8,0},;
             {"g36","N",8,0},;
             {"g39","N",8,0},;
             {"gvv","N",8,0},;
             {"dispans1","N",8,0},;
             {"m361","N",8,0},;
             {"m391","N",8,0},;
             {"mvv1","N",8,0},;
             {"g361","N",8,0},;
             {"g391","N",8,0},;
             {"gvv1","N",8,0},;
             {"nap_dop","N",8,0},;
             {"m36p","N",8,0},;
             {"m39p","N",8,0},;
             {"mvvp","N",8,0},;
             {"g36p","N",8,0},;
             {"g39p","N",8,0},;
             {"gvvp","N",8,0}}
    dbcreate(cur_dir+"tmp5000",adbf)
    use (cur_dir+"tmp5000") new alias TMP
    for n := 1 to len5000
      append blank
      tmp->name := arr_5000[n,3]
      tmp->ns := n
      tmp->stroke := arr_5000[n,2]
      if len(arr_5000[n]) < 5
        tmp->diagnoz := arr_5000[n,4]
      endif
      s2 := arr_5000[n,4]
      diag5000[n] := {}
      for i := 1 to numtoken(s2,",")
        s3 := token(s2,",",i)
        if "-" $ s3
          d1 := token(s3,"-",1)
          d2 := token(s3,"-",2)
        else
          d1 := d2 := s3
        endif
        aadd(diag5000[n], {diag_to_num(d1,1),diag_to_num(d2,2)} )
      next
    next
    index on str(ns,2) to (cur_dir+"tmp5000")
    use
    //
    dbcreate(cur_dir+"tmp5001",adbf)
    use (cur_dir+"tmp5001") new alias TMP
    for n := 1 to len5001
      append blank
      tmp->name := arr_5001[n,3]
      tmp->ns := n
      tmp->stroke := arr_5001[n,2]
      if len(arr_5001[n]) < 5
        tmp->diagnoz := arr_5001[n,4]
      endif
      s2 := arr_5001[n,4]
      diag5001[n] := {}
      for i := 1 to numtoken(s2,",")
        s3 := token(s2,",",i)
        if "-" $ s3
          d1 := token(s3,"-",1)
          d2 := token(s3,"-",2)
        else
          d1 := d2 := s3
        endif
        aadd(diag5001[n], {diag_to_num(d1,1),diag_to_num(d2,2)} )
      next
    next
    index on str(ns,2) to (cur_dir+"tmp5001")
    use
    //
    Private arr_7000 := {;
      {1,"Определена I группа здоровья"},;
      {2,"Определена II группа здоровья"},;
      {3,"Определена IIIа группа здоровья"},;
      {4,"Определена IIIб группа здоровья"},;
      {5,"Назначено лечение"},;
      {6,"Направлено на дополнительное обследование"},;
      {7,"Направлено для получения спец., в т.ч.ВМП"},;
      {8,"Направлено на санаторно-курортное лечение"};
     }
    dbcreate(cur_dir+"tmp7000",{{"name","C",100,0},;
                                {"ns","N",2,0},;
                                {"m36","N",8,0},;
                                {"m39","N",8,0},;
                                {"mvv","N",8,0},;
                                {"g36","N",8,0},;
                                {"g39","N",8,0},;
                                {"gvv","N",8,0}})
    use (cur_dir+"tmp7000") new alias TMP
    for n := 1 to len(arr_7000)
      append blank
      tmp->name := arr_7000[n,2]
      tmp->ns := arr_7000[n,1]
    next
    index on str(ns,2) to (cur_dir+"tmp7000")
    use
    //
    Private arr_vrach := {}, arr_7001 := {;
      {"7001 Общее число работающих граждан, прошедших диспансеризацию",0,15},;           //  1
      {"7002 Общее число неработающих граждан, прошедших диспансеризацию",0,16},;         //  2
      {"7003 Общее число прошедших диспансеризацию обучающихся по очной форме",0,17},;    //  3
      {"7004 Общее число граждан, имеющих право на государст.социальную помощь",0,0},;    //  4
      {"     из них: - инвалиды войны",0,19},;                                            //  5
      {"             - участники Великой Отечественной войны",0,20},;                     //  6
      {"             - ветераны боевых действий (закон №5-ФЗ от 12.01.95г.)",0,21},;      //  7
      {"             - военнослужащие не из действующей армии (41-45 годы)",0,22},;       //  8
      {"             - лица, награждённые знаком ЖИТЕЛЮ БЛОКАДНОГО ЛЕНИНГРАДА",0,23},;    //  9
      {"             - лица, работавшие в период ВОВ на объектах ПВО и т.п.",0,24},;      // 10
      {"             - члены семей погибших (умерших) инвалидов, участников ВОВ",0,25},;  // 11
      {"             - инвалиды",0,26},;                                                  // 12
      {"7005 Общее число прошедших диспансеризацию коренных жителей Севера...",0,27},;    // 13
      {"7006 Общее число МО, принимавших участие в проведении диспансеризации",1,28},;    // 14
      {"     из них: имеют кабинеты или отделения медицинской профилактики",1,29},;       // 15
      {"7007 Общее число мобильных бригад, принимавших участие в диспансеризации",0,30},; // 16
      {"     7007.1 число выездов мобильных бригад",0,31},;                               // 17
      {"7008 Общее число граждан, дисп-ия которых проведена мобильными бригадами",0,32},; // 18
      {"     из них проживающих в сельской местности",0,33},;                             // 19
      {"7009 Число письменных отказов от прохождения отдельных осмотров",0,0},;           // 20
      {"7010 Число письменных отказов от прохождения диспансеризации в целом",0,35},;     // 21
      {"7011 Число прошедших I этап диспансеризации и не завершивших II этап",0,0},;      // 22
      {"     Направлено на второй этап",0,37},;                                           // 23
      {"     Завершили второй этап",0,38},;                                               // 24
      {"7012 Число сельских жителей, прошедших диспансеризацию",0,39};                    // 25
     }
    use (cur_dir+"tmp1000") index (cur_dir+"tmp1000") new
    use (cur_dir+"tmp2000") index (cur_dir+"tmp2000") new
    use (cur_dir+"tmp3000") index (cur_dir+"tmp3000") new
    use (cur_dir+"tmp4000") index (cur_dir+"tmp4000") new
    use (cur_dir+"tmp5000") index (cur_dir+"tmp5000") new
    use (cur_dir+"tmp5001") index (cur_dir+"tmp5001") new
    use (cur_dir+"tmp7000") index (cur_dir+"tmp7000") new
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"uslugi",,"USL")
    R_Use(dir_server+"human_u_",,"HU_")
    R_Use(dir_server+"human_u",dir_server+"human_u","HU")
    set relation to recno() into HU_
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"kartotek",,"KART")
    set relation to recno() into KART_
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",,"HUMAN")
    set relation to recno() into HUMAN_
    use (cur_dir+"tmp") index (cur_dir+"tmp") new
    set relation to kod_k into KART
    ii := 0
    f_error_DVN(1)
    mywait(" ")
    go top
    do while !eof()
      @ maxrow(),0 say padr(str(++ii/tmp->(lastrec())*100,6,2)+"%  "+alltrim(kart->fio)+"  "+full_date(kart->date_r),80) color cColorWait
      if empty(tmp->kod4h) .and. !empty(tmp->kod1h) // есть диспансеризация первый этап
        human->(dbGoto(tmp->kod1h))
        f1_forma_131()
      endif
      f_error_DVN(2)
      select TMP
      skip
    enddo
    close databases
    //
    fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
    add_string(glob_mo[_MO_SHORT_NAME])
    add_string(padl("Приложение №3",sh))
    add_string(padl("к Приказу МЗРФ",sh))
    add_string(padl("№87н от 06.03.2015г.",sh))
    add_string("")
    add_string(padl("Отчетная форма № 131",sh))
    add_string("")
    add_string(center("Сведения о диспансеризации определённых групп взрослого населения",sh))
    titleN_uch(st_a_uch,sh,lcount_uch)
    add_string(center("[ "+charrem("~",mas1pmt[par])+" ]",sh))
    add_string(center(arr_m[4],sh))
    add_string("")
    add_string(center("Сведения о проведении диспансеризации определённых групп взрослого населения",sh))
    add_string("Таблица 1000")
    add_string("─────────────────┬───────────────────┬───────────────────┬───────────────────")
    add_string("                 │       Всего       │     Мужчины       │      Женщины      ")
    add_string("Возрастная группа├─────────┬─────────┼─────────┬─────────┼─────────┬─────────")
    add_string("                 │  I этап │ II этап │  I этап │ II этап │  I этап │ II этап ")
    add_string("─────────────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────")
    R_Use(dir_server+"organiz",,"ORG")
    ar := {}
    //aadd(ar, {15,1,glob_mo[_MO_FULL_NAME]})
    aadd(ar, {16,2,glob_mo[_MO_ADRES]})
    aadd(ar, {19,1,alltrim(org->okpo)})
    aadd(arr_excel, {"Сведения",aclone(ar)})
    ar := {}
    sm1 := sg1 := sm2 := sg2 := 0
    use (cur_dir+"tmp1000") new alias TMP
    go top
    do while !eof()
      i := recno()
      //aadd(ar, {6+i, 5,tmp->vm1+tmp->vg1})
      //aadd(ar, {6+i, 6,tmp->vm2+tmp->vg2})
      aadd(ar, {6+i,8,arr_plan_god[1,i]})
      //aadd(ar, {6+i, 9,tmp->vm1})
      aadd(ar, {6+i,10,tmp->vm2})
      aadd(ar, {6+i,12,arr_plan_god[2,i]})
      //aadd(ar, {6+i,13,tmp->vg1})
      aadd(ar, {6+i,14,tmp->vg2})
      s := arr_v[i]
      add_string(padr(s,17)+put_val(tmp->vm1+tmp->vg1,10)+put_val(tmp->vm2+tmp->vg2,10)+;
                            put_val(tmp->vm1,10)+put_val(tmp->vm2,10)+;
                            put_val(tmp->vg1,10)+put_val(tmp->vg2,10))
      sm1 += tmp->vm1
      sg1 += tmp->vg1
      sm2 += tmp->vm2
      sg2 += tmp->vg2
      skip
    enddo
    use
    add_string(replicate("─",77))
    add_string(padl("ИТОГО:",17)+put_val(sm1+sg1,10)+put_val(sm2+sg2,10)+;
                                 put_val(sm1,10)+put_val(sm2,10)+;
                                 put_val(sg1,10)+put_val(sg2,10))
    aadd(arr_excel, {"1000",aclone(ar)})
    add_string("")
    add_string("")
    add_string(center("Сведения о первом этапе диспансеризации ...",sh))
    add_string("")
    add_string("Таблица 2000")
    add_string("───────────────────────────────────────────────────┬──┬──────┬──────┬──────┬──────")
    add_string("Осмотр (консультация), исследование                │№с│провед│ ранее│отказы│отклон")
    add_string("───────────────────────────────────────────────────┴──┴──────┴──────┴──────┴──────")
    ar := {} ; i := 0
    use (cur_dir+"tmp2000") new alias TMP
    go top
    do while !eof()
      ++i
      aadd(ar, {6+i,3,tmp->vv})
      if !empty(tmp->vr)
        aadd(ar, {6+i,4,tmp->vr})
      endif
      if !empty(tmp->vo)
        aadd(ar, {6+i,5,tmp->vo})
      endif
      if !empty(tmp->vd)
        aadd(ar, {6+i,6,tmp->vd})
      endif
      add_string(padr(tmp->name,51)+str(tmp->ns,3)+put_val(tmp->vv,7)+;
                 put_val(tmp->vr,7)+put_val(tmp->vo,7)+put_val(tmp->vd,7))
      skip
    enddo
    use
    aadd(ar, {30,2,arr_7001[20,2]}) // число лиц, оформивших письменные отказы
    aadd(arr_excel, {"2000",aclone(ar)})
    verify_FF(HH-40, .t., sh)
    add_string(center("Сведения о втором этапе диспансеризации ...",sh))
    add_string("")
    add_string("Таблица 3000")
    add_string("──────────────────────────────────────────────┬──┬──────┬──────┬──────┬──────┬──────")
    add_string("  Медицинское мероприятие                     │№№│выявл.│выпол-│      │      │выявле")
    add_string("  второго этапа диспансеризаци                │ст│показ.│нено  │ ранее│отказы│заболе")
    add_string("──────────────────────────────────────────────┴──┴──────┴──────┴──────┴──────┴──────")
    ar := {} ; i := 0
    use (cur_dir+"tmp3000") new alias TMP
    sv := sd := 0
    go top
    do while !eof()
      ++i
      if !empty(tmp->vv)
        aadd(ar, {5+i,3,tmp->vv})
        aadd(ar, {5+i,4,tmp->vv})
      endif
      if (5+i) != 19 .and. (5+i) != 20
        if !empty(tmp->vd)
          aadd(ar, {5+i,7,tmp->vd})
        endif
        add_string(padr(tmp->name,46)+str(tmp->ns,3)+put_val(tmp->vv,7)+;
                   put_val(tmp->vv,7)+put_val(tmp->vd,21))
        sd += tmp->vd
      else
        add_string(padr(tmp->name,46)+str(tmp->ns,3)+put_val(tmp->vv,7)+;
                   put_val(tmp->vv,7))
      endif
      sv += tmp->vv
      skip
    enddo
    use
    aadd(ar, {25,6,v3001}) // направлено к сердечно-сосудистому хирургу
    aadd(ar, {27,2,0}) // число лиц, оформивших письменные отказы
    add_string(replicate("─",84))
    add_string(padr("ИТОГО:",46)+str(17,3)+put_val(sv,7)+put_val(sv,7)+put_val(sd,21))
    aadd(arr_excel, {"3000",aclone(ar)})
    add_string("")
    add_string("")
    add_string(center("Сведения о распространенности факторов риска ...",sh))
    add_string("")
    add_string("Таблица 4000")
    add_string("───────────────────────────┬──┬─────────────────┬─────────────────┬─────────────────")
    add_string("                           │№ │     Мужчины     │     Женщины     │      Всего      ")
    add_string("  Фактор риска развития    │ст├─────┬─────┬─────┼─────┬─────┬─────┼─────┬─────┬─────")
    add_string("  заболеваний              │ро│до 36│39-60│> 60л│до 36│39-60│> 60л│до 36│39-60│> 60л")
    add_string("───────────────────────────┴──┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────")
    ar := {} ; i := 0
    use (cur_dir+"tmp4000") new alias TMP
    go top
    do while !eof()
      ++i
      if !empty(tmp->m36)
        aadd(ar, {5+i, 4,tmp->m36})
      endif
      if !empty(tmp->m39)
        aadd(ar, {5+i, 5,tmp->m39})
      endif
      if !empty(tmp->mvv)
        aadd(ar, {5+i, 6,tmp->mvv})
      endif
      if !empty(tmp->g36)
        aadd(ar, {5+i, 8,tmp->g36})
      endif
      if !empty(tmp->g39)
        aadd(ar, {5+i, 9,tmp->g39})
      endif
      if !empty(tmp->gvv)
        aadd(ar, {5+i,10,tmp->gvv})
      endif
      add_string(padr(tmp->name,27)+str(tmp->ns,3)+;
                 put_val(tmp->m36,6)+put_val(tmp->m39,6)+put_val(tmp->mvv,6)+;
                 put_val(tmp->g36,6)+put_val(tmp->g39,6)+put_val(tmp->gvv,6)+;
                 put_val(tmp->v36,6)+put_val(tmp->v39,6)+put_val(tmp->vvv,6))
      skip
    enddo
    use
    aadd(ar, {20, 9,v4001_1}) // уст.дисп.набл.врачом кабинета мед.профилактики
    aadd(ar, {21, 9,v4001_2}) // уст.дисп.набл.врачом центра здоровья
    aadd(ar, {22,14,v4002_1}) // направлено к писихиатру (алкоголь)
    aadd(ar, {23,14,v4002_2}) // направлено к писихиатру (наркотики)
    aadd(arr_excel, {"4000",aclone(ar)})
    verify_FF(HH-40, .t., sh)
    add_string(center("Сведения о выявленных заболеваниях (случаев)",sh))
    add_string("")
    add_string("Таблица 5000")
    add_string("───────────────────────┬──────┬───────┬─────────────────┬─────────────────┬─────")
    add_string("                       │  №№  │ Код по│     Мужчины     │     Женщины     │Устан")
    add_string("     Заболевание       │строки│ МКБ-10├─────┬─────┬─────┼─────┬─────┬─────┤дисп.")
    add_string("                       │      │       │до 36│39-60│> 60л│до 36│39-60│> 60л│набл.")
    add_string("───────────────────────┴──────┴───────┴─────┴─────┴─────┴─────┴─────┴─────┴─────")
    ar := {}
    use (cur_dir+"tmp5000") new alias TMP
    go top
    do while !eof()
      if (i := arr_5000[tmp->ns,1]) > 0
        if !empty(tmp->m36)
          aadd(ar, {i, 4,tmp->m36})
        endif
        if !empty(tmp->m39)
          aadd(ar, {i, 5,tmp->m39})
        endif
        if !empty(tmp->mvv)
          aadd(ar, {i, 6,tmp->mvv})
        endif
        if !empty(tmp->g36)
          aadd(ar, {i, 8,tmp->g36})
        endif
        if !empty(tmp->g39)
          aadd(ar, {i, 9,tmp->g39})
        endif
        if !empty(tmp->gvv)
          aadd(ar, {i,10,tmp->gvv})
        endif
        if !empty(tmp->dispans)
          aadd(ar, {i,16,tmp->dispans})
        endif
      else
        add_string(replicate("─",80))
      endif
      add_string(padr(tmp->name,23)+padc(tmp->stroke,8)+padc(alltrim(tmp->diagnoz),7)+;
                 put_val(tmp->m36,6)+put_val(tmp->m39,6)+put_val(tmp->mvv,6)+;
                 put_val(tmp->g36,6)+put_val(tmp->g39,6)+put_val(tmp->gvv,6)+;
                 put_val(tmp->dispans,6))
      skip
    enddo
    use
    aadd(arr_excel, {"5000",f2_forma_131(ar)})
    verify_FF(HH-40, .t., sh)
    add_string(center("Сведения о впервые выявленных заболеваниях (случаев)",sh))
    add_string("")
    add_string("Таблица 5001")
    add_string("───────────────────────┬──────┬───────┬─────────────────┬─────────────────┬─────")
    add_string("                       │  №№  │ Код по│     Мужчины     │     Женщины     │Устан")
    add_string("     Заболевание       │строки│ МКБ-10├─────┬─────┬─────┼─────┬─────┬─────┤дисп.")
    add_string("                       │      │       │до 36│39-60│> 60л│до 36│39-60│> 60л│набл.")
    add_string("───────────────────────┴──────┴───────┴─────┴─────┴─────┴─────┴─────┴─────┴─────")
    ar := {}
    use (cur_dir+"tmp5000") new alias TMP
    go top
    do while !eof()
      if (i := arr_5000[tmp->ns,1]) > 0
        if tmp->ns < len5000-1
          if !empty(tmp->m361)
            aadd(ar, {i, 4,tmp->m361})
          endif
          if !empty(tmp->m391)
            aadd(ar, {i, 5,tmp->m391})
          endif
          if !empty(tmp->mvv1)
            aadd(ar, {i, 6,tmp->mvv1})
          endif
          if !empty(tmp->g361)
            aadd(ar, {i, 8,tmp->g361})
          endif
          if !empty(tmp->g391)
            aadd(ar, {i, 9,tmp->g391})
          endif
          if !empty(tmp->gvv1)
            aadd(ar, {i,10,tmp->gvv1})
          endif
          if !empty(tmp->dispans1)
            aadd(ar, {i,16,tmp->dispans1})
          endif
        endif
      else
        add_string(replicate("─",80))
      endif
      add_string(padr(tmp->name,23)+padc(tmp->stroke,8)+padc(alltrim(tmp->diagnoz),7)+;
                 put_val(tmp->m361,6)+put_val(tmp->m391,6)+put_val(tmp->mvv1,6)+;
                 put_val(tmp->g361,6)+put_val(tmp->g391,6)+put_val(tmp->gvv1,6)+;
                 put_val(tmp->dispans1,6))
      skip
    enddo
    use
    add_string(replicate("─",80))
    use (cur_dir+"tmp5001") new alias TMP
    go top
    do while !eof()
      if (i := arr_5001[tmp->ns,1]) > 0
        if !empty(tmp->m361)
          aadd(ar, {i, 4,tmp->m361})
        endif
        if !empty(tmp->m391)
          aadd(ar, {i, 5,tmp->m391})
        endif
        if !empty(tmp->mvv1)
          aadd(ar, {i, 6,tmp->mvv1})
        endif
        if !empty(tmp->g361)
          aadd(ar, {i, 8,tmp->g361})
        endif
        if !empty(tmp->g391)
          aadd(ar, {i, 9,tmp->g391})
        endif
        if !empty(tmp->gvv1)
          aadd(ar, {i,10,tmp->gvv1})
        endif
        if !empty(tmp->dispans1)
          aadd(ar, {i,16,tmp->dispans1})
        endif
      else
        add_string(replicate("─",80))
      endif
      add_string(padr(tmp->name,23)+padc(tmp->stroke,8)+padc(alltrim(tmp->diagnoz),7)+;
                 put_val(tmp->m361,6)+put_val(tmp->m391,6)+put_val(tmp->mvv1,6)+;
                 put_val(tmp->g361,6)+put_val(tmp->g391,6)+put_val(tmp->gvv1,6)+;
                 put_val(tmp->dispans1,6))
      skip
    enddo
    use
    aadd(arr_excel, {"5001",f2_forma_131(ar)})
    verify_FF(HH-40, .t., sh)
    add_string(center("Сведения об установленных предварительных диагнозах (случаев)",sh))
    add_string("")
    add_string("Таблица 6000")
    add_string("───────────────────────┬──────┬───────┬─────────────────┬─────────────────┬─────")
    add_string("                       │  №№  │ Код по│     Мужчины     │     Женщины     │На   ")
    add_string("     Заболевание       │строки│ МКБ-10├─────┬─────┬─────┼─────┬─────┬─────┤допол")
    add_string("                       │      │       │до 36│39-60│> 60л│до 36│39-60│> 60л│обсле")
    add_string("───────────────────────┴──────┴───────┴─────┴─────┴─────┴─────┴─────┴─────┴─────")
    ar := {}
    use (cur_dir+"tmp5000") new alias TMP
    go top
    do while !eof()
      if (i := arr_5000[tmp->ns,1]) > 0
        if !empty(tmp->m36p)
          aadd(ar, {i, 4,tmp->m36p})
        endif
        if !empty(tmp->m39p)
          aadd(ar, {i, 5,tmp->m39p})
        endif
        if !empty(tmp->mvvp)
          aadd(ar, {i, 6,tmp->mvvp})
        endif
        if !empty(tmp->g36p)
          aadd(ar, {i, 8,tmp->g36p})
        endif
        if !empty(tmp->g39p)
          aadd(ar, {i, 9,tmp->g39p})
        endif
        if !empty(tmp->gvvp)
          aadd(ar, {i,10,tmp->gvvp})
        endif
        if !empty(tmp->nap_dop)
          aadd(ar, {i,16,tmp->nap_dop})
        endif
      else
        add_string(replicate("─",80))
      endif
      add_string(padr(tmp->name,23)+padc(tmp->stroke,8)+padc(alltrim(tmp->diagnoz),7)+;
                 put_val(tmp->m36p,6)+put_val(tmp->m39p,6)+put_val(tmp->mvvp,6)+;
                 put_val(tmp->g36p,6)+put_val(tmp->g39p,6)+put_val(tmp->gvvp,6)+;
                 put_val(tmp->nap_dop,6))
      skip
    enddo
    use
    aadd(arr_excel, {"6000",f2_forma_131(ar)})
    verify_FF(HH-40, .t., sh)
    add_string(center("Общие результаты диспансеризации ...",sh))
    add_string("")
    add_string("Таблица 7000")
    add_string("─────────────────────────────────────────┬──┬─────────────────┬─────────────────")
    add_string("Результат диспансеризации определенных   │№ │     Мужчины     │     Женщины     ")
    add_string("групп взрослого населения                │ст├─────┬─────┬─────┼─────┬─────┬─────")
    add_string("                                         │ро│до 36│39-60│> 60л│до 36│39-60│> 60л")
    add_string("─────────────────────────────────────────┴──┴─────┴─────┴─────┴─────┴─────┴─────")
    ar := {} ; i := 0
    use (cur_dir+"tmp7000") new alias TMP
    go top
    do while !eof()
      ++i
      if !empty(tmp->m36)
        aadd(ar, {5+i,3,tmp->m36})
      endif
      if !empty(tmp->m39)
        aadd(ar, {5+i,4,tmp->m39})
      endif
      if !empty(tmp->mvv)
        aadd(ar, {5+i,5,tmp->mvv})
      endif
      if !empty(tmp->g36)
        aadd(ar, {5+i,6,tmp->g36})
      endif
      if !empty(tmp->g39)
        aadd(ar, {5+i,7,tmp->g39})
      endif
      if !empty(tmp->gvv)
        aadd(ar, {5+i,8,tmp->gvv})
      endif
      add_string(padr(tmp->name,41)+str(tmp->ns,3)+;
                 put_val(tmp->m36,6)+put_val(tmp->m39,6)+put_val(tmp->mvv,6)+;
                 put_val(tmp->g36,6)+put_val(tmp->g39,6)+put_val(tmp->gvv,6))
      skip
    enddo
    use
    add_string(replicate("─",sh))
    add_string("")
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    arr_7001[2,2] += arr_7001[3,2] // прибавим студентов к неработающим
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    for n := 1 to len(arr_7001)
      if arr_7001[n,3] > 0
        aadd(ar, {arr_7001[n,3],7,arr_7001[n,2]})
      endif
      add_string(padr(arr_7001[n,1],sh-6)+put_val(arr_7001[n,2],6))
    next
    aadd(arr_excel, {"7000",aclone(ar)})
    //
    verify_FF(HH-8-len(arr_vrach), .t., sh)
    add_string("")
    add_string(center("Отчёт о работе врачей-терапевтов по диспансеризации",sh))
    add_string("")
    add_string("──────────────────────────────────────────────┬──────┬──────┬──────┬──────")
    add_string("                                              │прошло│прошло│прошло│прошло")
    add_string("     Врач                                     │1 этап│2 этап│проф- │дисп-ю")
    add_string("                                              │(чел.)│(чел.)│осмотр│1р.в2г")
    add_string("──────────────────────────────────────────────┴──────┴──────┴──────┴──────")
    R_Use(dir_server+"mo_pers",,"PERS")
    for i := 1 to len(arr_vrach)
      goto (arr_vrach[i,1])
      arr_vrach[i,2] := pers->tab_nom
      arr_vrach[i,3] := pers->fio
    next
    asort(arr_vrach,,,{|x,y| upper(x[3]) < upper(y[3])})
    for i := 1 to len(arr_vrach)
      add_string(padr(str(i,3)+". ["+lstr(arr_vrach[i,2])+"] ",13)+padr(arr_vrach[i,3],33)+;
                 put_val(arr_vrach[i,4],7)+put_val(arr_vrach[i,5],7)+;
                 put_val(arr_vrach[i,6],7)+put_val(arr_vrach[i,7],7))
    next
    f_error_DVN(3,HH,sh)
    fclose(fp)
    rest_box(buf)
    close databases
    viewtext(n_file,,,,.t.,,,5)
    fill_in_Excel_Book(dir_exe+"mo_131"+sxls,;
                       cur_dir+"__131__"+sxls,;
                       arr_excel,;
                       "присланный из ВОМИАЦ")
  endif
endif
close databases
rest_box(buf)
return NIL

***** 15.09.19 Поиск ошибок сочетаний разных видов осмотров
Function f_error_DVN(k,HH,sh)
Static arr := {}, arr_title := {;
  "────────────────────────────────────────────┬────────┬────────┬────────┬────────",;
  "                                            │дисп-ия │дисп-ия │ проф-  │дисп-ия ",;
  "     ФИО пациента                           │ 1 этап │ 2 этап │ осмотр │раз в 2г",;
  "────────────────────────────────────────────┴────────┴────────┴────────┴────────"}
Local i
if k == 1
  arr := {}
elseif k == 2
  if !empty(tmp->kod4h) // есть диспансеризация 1 раз в 2 года
    human->(dbGoto(tmp->kod4h))
    if type("arr_vrach") == "A"
      if (i := ascan(arr_vrach, {|x| x[1] == human_->VRACH })) == 0
        aadd(arr_vrach, {human_->VRACH,0,"",0,0,0,0}) ; i := len(arr_vrach)
      endif
      arr_vrach[i,7] ++
    endif
    if !emptyall(tmp->kod1h,tmp->kod2h,tmp->kod3h)
      aadd(arr,{" "," "," ","+",tmp->kod_k})
    endif
  elseif !empty(tmp->kod1h) // есть диспансеризация первый этап
    if !emptyall(tmp->kod3h)
      aadd(arr,{"+"," "," "," ",tmp->kod_k})
    endif
  elseif !empty(tmp->kod2h) // есть диспансеризация второй этап
    aadd(arr,{" "," "," "," ",tmp->kod_k})
  elseif !empty(tmp->kod3h) // есть профосмотр
    human->(dbGoto(tmp->kod3h))
    if type("arr_vrach") == "A"
      if (i := ascan(arr_vrach, {|x| x[1] == human_->VRACH })) == 0
        aadd(arr_vrach, {human_->VRACH,0,"",0,0,0,0}) ; i := len(arr_vrach)
      endif
      arr_vrach[i,6] ++
    endif
  endif
elseif len(arr) > 1
  R_Use(dir_server+"kartotek",,"KART")
  use (cur_dir+"tmp") new
  index on str(kod_k,7) to (cur_dir+"tmp")
  verify_FF(HH-8, .f., sh)
  add_string("")
  add_string(center("Несовместимые медосмотры",sh))
  add_string(center('(знаком "+" отмечены осмотры, учитываемые в статистике)',sh))
  aeval(arr_title,{|x| add_string(x) })
  for i := 1 to len(arr)
    select TMP
    find (str(arr[i,5],7))
    kart->(dbGoto(arr[i,5]))
    s := padr(lstr(i)+". "+kart->fio,44)
    s += iif(empty(tmp->kod1h), space(9), arr[i,1]+date_8(tmp->date1))
    s += iif(empty(tmp->kod2h), space(9), arr[i,2]+date_8(tmp->date2))
    s += iif(empty(tmp->kod3h), space(9), arr[i,3]+date_8(tmp->date3))
    s += iif(empty(tmp->kod4h), space(9), arr[i,4]+date_8(tmp->date4))
    if verify_FF(HH, .f., sh)
      aeval(arr_title,{|x| add_string(x) })
    endif
    add_string(s)
  next
endif
return (len(arr) > 0)

***** 15.08.19
Function f1_forma_131(Loc_kod,kod_kartotek) // 131
Local i, j, k, fl, lshifr, au := {}, a7[8], ar, metap, m1gruppa, m1gruppa2 := 0,;
      mpol, fl2 := .f., fl_dispans := .f., ivozrast
// диспансеризация I этап
human->(dbGoto(tmp->kod1h))
mpol := human->pol
m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW,@fl2)
if !between(m1gruppa,0,4)
  return NIL
endif
if (i := ascan(arr_vrach, {|x| x[1] == human_->VRACH })) == 0
  aadd(arr_vrach, {human_->VRACH,0,"",0,0,0,0}) ; i := len(arr_vrach)
endif
arr_vrach[i,4] ++
Private arr_otklon := {}, arr_usl_otkaz := {}, mvozrast, mdvozrast,;
        M1RAB_NERAB := human->RAB_NERAB, m1veteran := 0, m1mobilbr := 0,;
        m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, mssr := 0,;
        m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
        mholest := 0, mglukoza := 0, ;
        m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, ;
        m1ot_nasl1 := 0, m1ot_nasl2 := 0, m1ot_nasl3 := 0, m1ot_nasl4 := 0,;
        m1dispans := 0, m1nazn_l  := 0, m1dopo_na := 0, m1ssh_na  := 0,;
        m1spec_na := 0, m1sank_na := 0,;
        pole_diag, pole_1pervich, pole_1stadia, pole_1dispans,;
        mWEIGHT := 0, mHEIGHT := 0
for i := 1 to 5
  pole_diag := "mdiag"+lstr(i)
  pole_1pervich := "m1pervich"+lstr(i)
  pole_1stadia := "m1stadia"+lstr(i)
  pole_1dispans := "m1dispans"+lstr(i)
  Private &pole_diag := space(6)
  Private &pole_1pervich := 0
  Private &pole_1stadia := 0
  Private &pole_1dispans := 0
next
read_arr_DVN(human->kod)
ret_tip_mas(mWEIGHT,mHEIGHT,@m1tip_mas)
mvozrast := count_years(human->date_r,human->n_data)
mdvozrast := year(human->n_data) - year(human->date_r)
if m1veteran == 1
  mdvozrast := ret_vozr_DVN_veteran(mdvozrast,human->k_data)
endif
if mdvozrast < 39
  ivozrast := 1
elseif mdvozrast <= 60
  ivozrast := 2
else
  ivozrast := 3
endif
select TMP1000
goto (ivozrast)
if mpol == "М"
  tmp1000->vm1 ++
else
  tmp1000->vg1 ++
endif
if fl2 // направлен на 2 этап
  arr_7001[22,2] ++
  arr_7001[23,2] ++
elseif !empty(tmp->kod2h)
  human->(dbGoto(tmp->kod2h))
  m1GRUPPA2 := ret_gruppa_DVN(human_->RSLT_NEW)
  if between(m1gruppa2,1,4) // точно прошёл 2 этап
    arr_7001[22,2] ++
    arr_7001[23,2] ++
  endif
  human->(dbGoto(tmp->kod1h)) // вернуться на л/у первого этапа
endif
select HU
find (str(tmp->kod1h,7))
do while hu->kod == tmp->kod1h .and. !eof()
  usl->(dbGoto(hu->u_kod))
  if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
    lshifr := usl->shifr
  endif
  if !eq_any(left(lshifr,5),"70.3.","70.7.","72.1.","72.5.","72.6.","72.7.")
    aadd(au,{alltrim(lshifr),;
             hu_->PROFIL,;
             iif(left(hu_->kod_diag,1)=="Z","",hu_->kod_diag),;
             c4tod(hu->date_u);
            })
  endif
  select HU
  skip
enddo
for k := 1 to len(au)
  if ascan(arr_otklon,au[k,1]) > 0
    au[k,3] := "1" // отклонения в исследовании
    if eq_any(au[k,1],"4.20.1","4.20.2") // если отклонения в исследовании цитологич.материала
      if (i := ascan(au, {|x| x[1] == "4.1.12"})) > 0
        au[i,3] := "1" // занесём отклонения в осмотр фельдшера "4.1.12"
      endif
    endif
  endif
next
select TMP2000
for i := 1 to len(arr_2000)
  fl := fl_otkaz := .f.
  if valtype(arr_usl_otkaz) == "A"
    for k1 := 1 to len(arr_usl_otkaz)
      ar := arr_usl_otkaz[k1]
      if valtype(ar) == "A" .and. len(ar) >= 10 .and. valtype(ar[5]) == "C" ;
                               .and. valtype(ar[10]) == "N" .and. ar[10] == 1
        lshifr := alltrim(ar[5])
        if valtype(arr_2000[i,3]) == "C"
          if lshifr == arr_2000[i,3]
            fl := fl_otkaz := .t.
          endif
        elseif valtype(arr_2000[i,3,1]) == "C"
          for j := 1 to len(arr_2000[i,3])
            if lshifr == arr_2000[i,3,j]
              fl := fl_otkaz := .t.
              exit
            endif
          next
        else
          for j := 1 to len(arr_2000[i,3])
            if lshifr == arr_2000[i,3,j,1] .and. ar[4] == arr_2000[i,3,j,2]
              fl := fl_otkaz := .t.
              exit
            endif
          next
        endif
      endif
      if fl ; exit ; endif
    next
  endif
  if !fl_otkaz
    if valtype(arr_2000[i,3]) == "C"
      if (k := ascan(au, {|x| x[1] == arr_2000[i,3]})) > 0
        fl := .t.
      endif
    elseif valtype(arr_2000[i,3,1]) == "C"
      for j := 1 to len(arr_2000[i,3])
        if (k := ascan(au, {|x| x[1] == arr_2000[i,3,j]})) > 0
          fl := .t. ; exit
        endif
      next
    else
      for j := 1 to len(arr_2000[i,3])
        if (k := ascan(au, {|x| x[1]==arr_2000[i,3,j,1] .and. x[2]==arr_2000[i,3,j,2]})) > 0
          fl := .t. ; exit
        endif
      next
    endif
  endif
  if fl .and. len(arr_2000[i]) > 3
    fl := &(arr_2000[i,4])
  endif
  if fl
    find (str(arr_2000[i,1],2))
    if found()
      if fl_otkaz
        tmp2000->vo ++
        arr_7001[20,2] ++
      else
        tmp2000->vv ++
        if au[k,4] < human->n_data
          tmp2000->vr ++
        endif
        if !empty(au[k,3]) // отклонения (или диагноз)
          tmp2000->vd ++
        endif
      endif
    endif
  endif
next
select TMP4000
for i := 1 to len(arr_4000)
  if &(arr_4000[i,3])
    find (str(arr_4000[i,1],2))
    if found()
      if mpol == "М"
        if ivozrast == 1
          tmp4000->m36 ++
        elseif ivozrast == 2
          tmp4000->m39 ++
        else
          tmp4000->mvv ++
        endif
      else
        if ivozrast == 1
          tmp4000->g36 ++
        elseif ivozrast == 2
          tmp4000->g39 ++
        else
          tmp4000->gvv ++
        endif
      endif
      if ivozrast == 1
        tmp4000->v36 ++
      elseif ivozrast == 2
        tmp4000->v39 ++
      else
        tmp4000->vvv ++
      endif
    endif
  endif
next
if m1ssh_na == 1
  v3001 ++ // направлен к сердечно-сосудистому хирургу
endif
if m1psih_na == 1 // Направлен к врачу-психиатру (врачу-психиатру-наркологу)
  if m1pod_alk == 1 // Риск потребления наркотических/психотропных веществ без назначения врача
    v4002_2 ++
  else // Риск пагубного потребления алкоголя (употребление алкоголя)
    v4002_1 ++
  endif
endif
afill(a7,.f.)
if f_is_selo()
  if m1mobilbr == 1
    arr_7001[19,2] ++
  endif
  arr_7001[25,2] ++
endif
if M1RAB_NERAB == 0
  arr_7001[1,2] ++
elseif M1RAB_NERAB == 1
  arr_7001[2,2] ++
else
  arr_7001[3,2] ++
endif
if (i := ascan(stm_kategor, {|x| x[2] == kart_->kategor })) > 0 .and. between(stm_kategor[i,3],1,8)
  arr_7001[4,2] ++  // всего льготников
  arr_7001[4+stm_kategor[i,3],2] ++  // по каждой льготе расшифровка
endif
if m1mobilbr == 1
  arr_7001[18,2] ++
endif
// диспансеризация II этап
if !empty(tmp->kod2h)
  human->(dbGoto(tmp->kod2h))
  m1GRUPPA2 := ret_gruppa_DVN(human_->RSLT_NEW)
  if between(m1gruppa2,1,4) // точно прошёл 2 этап
    if (i := ascan(arr_vrach, {|x| x[1] == human_->VRACH })) == 0
      aadd(arr_vrach, {human_->VRACH,0,"",0,0,0,0}) ; i := len(arr_vrach)
    endif
    arr_vrach[i,5] ++
    m1GRUPPA := m1GRUPPA2 // переприсвоить группу
    read_arr_DVN(human->kod) // перечитать диагнозы и т.п.
    if mpol == "М"
      tmp1000->vm2 ++
    else
      tmp1000->vg2 ++
    endif
    arr_7001[22,2] --
    arr_7001[24,2] ++
    select HU
    find (str(tmp->kod2h,7))
    do while hu->kod == tmp->kod2h .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
        lshifr := usl->shifr
      endif
      aadd(au,{alltrim(lshifr),;
               hu_->PROFIL,;
               iif(left(hu_->kod_diag,1)=="Z","",hu_->kod_diag);
              })
      select HU
      skip
    enddo
    for k := 1 to len(au)
      if ascan(arr_otklon,au[k,1]) > 0
        au[k,3] := "1" // отклонения в исследовании
      endif
    next
    select TMP3000
    for k := 1 to len(au)
      fl := .f.
      for i := 1 to len(arr_3000)
        if valtype(arr_3000[i,3]) == "A"
          fl := (ascan(arr_3000[i,3],au[k,1]) > 0)
        else
          fl := (au[k,1]==arr_3000[i,3])
        endif
        if fl ; exit ; endif
      next
      if fl
        find (str(arr_3000[i,1],2))
        if found()
          tmp3000->vv ++
          if !empty(au[k,3]) // добавить отклонения для исследований
            tmp3000->vd ++
          endif
        endif
      endif
    next
  endif
endif
if between(m1gruppa,1,4)
  a7[m1gruppa] := .t.
endif
a7[5] := (m1nazn_l  == 1) // {5,"Назначено лечение"},;
a7[6] := (m1dopo_na > 0)  // {6,"Направлено на дополнительное диагностическое"},;
a7[7] := (m1spec_na == 1) // {7,"Направлено для получения спец., в т.ч.ВМП"},;
a7[8] := (m1sank_na == 1) // {8,"Направлено на санаторно-курортное лечение"};
for i := 1 to 5
  pole_diag := "mdiag"+lstr(i)
  pole_1pervich := "m1pervich"+lstr(i)
  pole_1stadia := "m1stadia"+lstr(i)
  pole_1dispans := "m1dispans"+lstr(i)
  if !empty(&pole_diag) .and. !(left(&pole_diag,1) == "Z")
    au := {} ; au1 := {}
    d := diag_to_num(&pole_diag,1)
    for n := 1 to len5000
      r := diag5000[n]
      for j := 1 to len(r)
        fl := between(d,r[j,1],r[j,2])
        if fl .and. len(arr_5000[n]) > 4 // надо проверить стадию
          if human->k_data < d_01_04_2015
            fl := (&pole_1stadia == 0) // ранняя
          else
            fl := (&pole_1stadia < 3) // 1 и 2 стадия
          endif
        endif
        if fl
          aadd(au,n)
        endif
      next
    next
    if empty(au) // заносим в прочие заболевания
      aadd(au,len5000-1)
      if &pole_1pervich == 1 // впервые
        for n := 1 to len5001
          r := diag5001[n]
          for j := 1 to len(r)
            if between(d,r[j,1],r[j,2])
              aadd(au1,n)
            endif
          next
        next
      endif
    endif
    aadd(au,len5000) // всегда заносим в ИТОГО
    select TMP5000
    for j := 1 to len(au)
      find (str(au[j],2))
      if found()
        if &pole_1pervich < 2 // впервые и ранее выявленный
          if mpol == "М"
            if ivozrast == 1
              tmp5000->m36 ++
            elseif ivozrast == 2
              tmp5000->m39 ++
            else
              tmp5000->mvv ++
            endif
          else
            if ivozrast == 1
              tmp5000->g36 ++
            elseif ivozrast == 2
              tmp5000->g39 ++
            else
              tmp5000->gvv ++
            endif
          endif
          if &pole_1dispans == 1
            fl_dispans := .t.
            tmp5000->dispans ++
          endif
          if &pole_1pervich == 1 // впервые
            if mpol == "М"
              if ivozrast == 1
                tmp5000->m361 ++
              elseif ivozrast == 2
                tmp5000->m391 ++
              else
                tmp5000->mvv1 ++
              endif
            else
              if ivozrast == 1
                tmp5000->g361 ++
              elseif ivozrast == 2
                tmp5000->g391 ++
              else
                tmp5000->gvv1 ++
              endif
            endif
            if &pole_1dispans == 1
              tmp5000->dispans1 ++
            endif
          endif
        else // предварительный диагноз
          if mpol == "М"
            if ivozrast == 1
              tmp5000->m36p ++
            elseif ivozrast == 2
              tmp5000->m39p ++
            else
              tmp5000->mvvp ++
            endif
          else
            if ivozrast == 1
              tmp5000->g36p ++
            elseif ivozrast == 2
              tmp5000->g39p ++
            else
              tmp5000->gvvp ++
            endif
          endif
          if m1dopo_na > 0 // Направлено на дополнительное диагностическое
            tmp5000->nap_dop ++
          endif
        endif
      endif
    next
    // добавка к таблице 5001
    select TMP5001
    for j := 1 to len(au1)
      find (str(au1[j],2))
      if found()
        if mpol == "М"
          if ivozrast == 1
            tmp5001->m361 ++
          elseif ivozrast == 2
            tmp5001->m391 ++
          else
            tmp5001->mvv1 ++
          endif
        else
          if ivozrast == 1
            tmp5001->g361 ++
          elseif ivozrast == 2
            tmp5001->g391 ++
          else
            tmp5001->gvv1 ++
          endif
        endif
        if &pole_1dispans == 1
          tmp5001->dispans1 ++
        endif
      endif
    next
  endif
next
if fl_dispans
  if m1dispans == 1 // Диспансерное наблюдение установлено врачом отд.мед.профилактики
    v4001_1 ++
  elseif m1dispans == 2 // Диспансерное наблюдение установлено врачом центра здоровья
    v4001_2 ++
  endif
endif
select TMP7000
for i := 1 to 8
  if a7[i]
    find (str(i,2))
    if found()
      if mpol == "М"
        if ivozrast == 1
          tmp7000->m36 ++
        elseif ivozrast == 2
          tmp7000->m39 ++
        else
          tmp7000->mvv ++
        endif
      else
        if ivozrast == 1
          tmp7000->g36 ++
        elseif ivozrast == 2
          tmp7000->g39 ++
        else
          tmp7000->gvv ++
        endif
      endif
    endif
  endif
next
return NIL

***** 15.03.16 клетки, исключаемые из таблиц 5000,5001,6000
Function f2_forma_131(ar1)
Static s_ar := {{23,30,4,6},{31,32,8,10},{58,58,4,17},{70,70,8,10}}
Local i, j, fl, arr := {}
for i := 1 to len(ar1)
  fl := .t.
  for j := 1 to len(s_ar)
    if between(ar1[i,1],s_ar[j,1],s_ar[j,2]) .and. between(ar1[i,2],s_ar[j,3],s_ar[j,4])
      fl := .f. ; exit
    endif
  next
  if fl
    aadd(arr, aclone(ar1[i]))
  endif
next
return arr

*

***** 17.05.15 вернуть группу здоровья для ДВН
Function ret_gruppa_DVN(_rslt,/*@*/_to_2_etap)
Local _gruppa := -1
_to_2_etap := .f.
do case
  case _rslt == 316 // т.е. направлен на II этап
    _to_2_etap := .t. // направлен на II этап
    _gruppa := 0
  case _rslt == 317 // I
    _gruppa := 1
  case _rslt == 318 // II
    _gruppa := 2
  case _rslt == 319 // III
    _gruppa := 3
  case _rslt == 355 // IIIа
    _gruppa := 3
  case _rslt == 356 // IIIб
    _gruppa := 4
  case _rslt == 352 // I
    _to_2_etap := .t. // направлен на II этап
    _gruppa := 1
  case _rslt == 353 // II
    _to_2_etap := .t. // направлен на II этап
    _gruppa := 2
  case _rslt == 354 // III
    _to_2_etap := .t. // направлен на II этап
    _gruppa := 3
  case _rslt == 357 // IIIа
    _to_2_etap := .t. // направлен на II этап
    _gruppa := 3
  case _rslt == 358 // IIIб
    _to_2_etap := .t. // направлен на II этап
    _gruppa := 4
endcase
return _gruppa

*

***** 19.02.18 Информация по профилактике и медосмотрам несовершеннолетних
Function inf_DNL(k)
Static si1 := 1, si2 := 1, sj1 := 1, sj2 := 1
Local mas_pmt, mas_msg, mas_fun, j, j1, j2
Local mas2pmt := {"Про~филактические осмотры",;
                  "Пре~дварительные осмотры",;
                  "Пе~риодические осмотры"}
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~Карта проф.медосмотра",;
                "~Список пациентов",;
                "~Многовариантный запрос",;
                "Своды для Обл~здрава",;
                "Форма № 030-ПО/~о-17",;
                "XML-файл для ~портала МЗРФ"}
    mas_msg := {"Карта профилактического медосмотра несовершеннолетнего (форма № 030-ПО/у-17)",;
                "Просмотр спика пациентов, прошедших медосмотры",;
                "Многовариантный запрос по диспансеризации/медосмотрам несовершеннолетних",;
                "Распечатка сводов для Волгоградского областного Комитета здравоохранения",;
                "Сведения о профилактических осмотрах несовершеннолетних (форма № 030-ПО/о-17)",;
                "Создание XML-файла для загрузки на портал Минздрава РФ"}
    mas_fun := {"inf_DNL(11)",;
                "inf_DNL(12)",;
                "inf_DNL(13)",;
                "inf_DNL(14)",;
                "inf_DNL(15)",;
                "inf_DNL(16)"}
    Private p_tip_lu := TIP_LU_PN
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    inf_DNL_karta()
  case k == 12
    ne_real()
  case k == 13
    mnog_poisk_DNL()
  case k == 14
    mas_pmt := {"~Сведения о профосмотрах детей по состоянию на ..."}
    mas_msg := {"Приложение к Приказу ВОМИАЦ №1185 от 12.08.2013г."}
    mas_fun := {"inf_DNL(21)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 15
    if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
      inf_DNL_030poo(j1)
    endif
  case k == 16
    //if (j2 := popup_prompt(T_ROW,T_COL-5,sj2,mas2pmt,,,"N/W,GR+/R,B/W,W+/R")) > 0
      //sj2 := j2
      //p_tip_lu := {TIP_LU_PN,TIP_LU_PREDN,TIP_LU_PERN}[j2]
      p_tip_lu := TIP_LU_PN
      if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
        //inf_DNL_XMLfile(j1,charrem("~",mas2pmt[j2]))
        inf_DNL_XMLfile(j1,"Профилактические осмотры")
      endif
    //endif
  case k == 21
    if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
      f21_inf_DNL(j1)
    endif
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  endif
endif
return NIL

*

***** 25.03.18 Распечатка карты проф.мед.осмотра (учётная форма № 030-ПО/у...)
Function inf_DNL_karta()
Local arr_m, buf := save_maxrow(), blk, t_arr[BR_LEN]
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  if f0_inf_DNL(arr_m,.f.)
    copy file (cur_dir+"tmp"+sdbf) to (cur_dir+"tmpDNL"+sdbf) // т.к. внутри тоже есть TMP-файл
    R_Use(dir_server+"human",,"HUMAN")
    use (cur_dir+"tmpDNL") new
    set relation to kod into HUMAN
    index on upper(human->fio) to (cur_dir+"tmpDNL")
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            R_Use(cur_dir+"tmpDNL",cur_dir+"tmpDNL","TMP"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    eval(blk_open)
    go top
    t_arr[BR_TOP] := T_ROW
    t_arr[BR_BOTTOM] := 23
    t_arr[BR_LEFT] := 0
    t_arr[BR_RIGHT] := 79
    t_arr[BR_TITUL] := "Профосмотры несовершеннолетних "+arr_m[4]
    t_arr[BR_TITUL_COLOR] := "B/BG"
    t_arr[BR_COLOR] := color0
    t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
    blk := {|| iif(human->schet > 0, {1,2}, {3,4}) }
    t_arr[BR_COLUMN] := {{" Ф.И.О.", {|| padr(human->fio,39) }, blk },;
                         {"Дата рожд.", {|| full_date(human->date_r) }, blk },;
                         {"№ ам.карты", {|| human->uch_doc }, blk },;
                         {"Сроки леч-я", {|| left(date_8(human->n_data),5)+"-"+left(date_8(human->k_data),5) }, blk },;
                         {"Этап", {|| iif(human->ishod==301," I  ","I-II") }, blk }}
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - распечатать карту профилактического мед.осмотра") }
    t_arr[BR_EDIT] := {|nk,ob| f1_inf_DNL_karta(nk,ob,"edit") }
    edit_browse(t_arr)
  endif
endif
close databases
rest_box(buf)
return NIL

*

***** 11.03.19
Function f0_inf_DNL(arr_m,is_schet,is_reg,arr_ishod,is_snils)
Local fl := .t.
DEFAULT is_schet TO .t., is_reg TO .f., is_snils TO .f., arr_ishod TO {301,302} // профилактика 1 и 2 этап
if !del_dbf_file("tmp"+sdbf)
  return .f.
endif
dbcreate(cur_dir+"tmp",{{"kod","N",7,0},;
                        {"kod_k","N",7,0},;
                        {"is", "N",1,0},;
                        {"ishod","N",6,0}})
use (cur_dir+"tmp") new
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_, to kod_k into KART
dbseek(dtos(arr_m[5]),.t.)
index on kod to (cur_dir+"tmp_h") ;
      for ascan(arr_ishod,ishod) > 0 .and. iif(is_schet, schet > 0, .t.) ;
      while human->k_data <= arr_m[6] ;
      PROGRESS
go top
do while !eof()
  fl := .t.
  if is_reg
    fl := .f.
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // только зарегистрированные
      fl := .t.
    endif
  endif
  if fl .and. ret_koef_from_RAK(human->kod) > 0
    select TMP
    append blank
    tmp->kod := human->kod
    tmp->kod_k := human->kod_k
    tmp->ishod := human->ishod
    tmp->is := iif(is_snils .and. empty(kart->snils), 0, 1)
  endif
  select HUMAN
  skip
enddo
fl := .t.
if tmp->(lastrec()) == 0
  fl := func_error(4,"Не найдено л/у по медосмотрам несовершеннолетних "+arr_m[4])
endif
close databases
return fl

*

***** 07.08.13
Function f1_inf_DNL_karta(nKey,oBrow,regim)
Local ret := -1, lkod_h, lkod_k, rec := tmp->(recno()), buf := save_maxrow()
if regim == "edit" .and. nKey == K_ENTER
  mywait()
  lkod_h := human->kod
  lkod_k := human->kod_k
  close databases
  oms_sluch_PN(lkod_h,lkod_k,"f2_inf_DNL_karta")
  eval(blk_open)
  goto (rec)
  rest_box(buf)
endif
return ret

***** 22.04.18
Function f2_inf_DNL_karta(Loc_kod,kod_kartotek,lvozrast)
Static st := "     ", ub := "<u><b>", ue := "</b></u>", sh := 88
Local adbf, s, i, j, k, y, m, d, fl, mm_danet, blk := {|s| __dbAppend(), field->stroke := s }
delFRfiles()
R_Use(dir_server+"mo_stdds")
if type("m1stacionar") == "N" .and. m1stacionar > 0
  goto (m1stacionar)
endif
R_Use(dir_server+"kartote_",,"KART_")
goto (kod_kartotek)
R_Use(dir_server+"kartotek",,"KART")
goto (kod_kartotek)
R_Use(dir_server+"mo_pers",,"P2")
goto (m1vrach)
R_Use(dir_server+"organiz",,"ORG")
adbf := {{"name","C",130,0},;
         {"prikaz","C",50,0},;
         {"forma","C",50,0},;
         {"titul","C",100,0},;
         {"fio","C",50,0},;
         {"k_data","C",40,0},;
         {"vrach","C",40,0},;
         {"glavn","C",40,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_SHORT_NAME]
frt->fio := mfio
frt->k_data := date_month(mk_data)
frt->vrach := fam_i_o(p2->fio)
frt->glavn := fam_i_o(org->ruk)
adbf := {{"stroke","C",2000,0}}
dbcreate(fr_data,adbf)
use (fr_data) new alias FRD
frt->prikaz := "от 10 августа 2017 г. № 514н"
frt->forma  := "030-ПО/у-17"
frt->titul  := "Карта профилактического осмотра несовершеннолетнего"
s := st+"1. Фамилия, имя, отчество (при наличии) несовершеннолетнего: "+ub+alltrim(mfio)+ue+"."
frd->(eval(blk,s))
s := st+"Пол: "+f3_inf_DDS_karta({{"муж.","М"},{"жен.","Ж"}},mpol,"/",ub,ue)
frd->(eval(blk,s))
s := st+"Дата рождения: "+ub+date_month(mdate_r,.t.)+ue+"."
frd->(eval(blk,s))
s := st+"2. Полис обязательного медицинского страхования: "
s += "серия "+iif(empty(mspolis), replicate("_",15), ub+alltrim(mspolis)+ue)
s += " № "+ub+alltrim(mnpolis)+ue+"."
frd->(eval(blk,s))
s := st+"Страховая медицинская организация: "+ub+alltrim(mcompany)+ue+"."
frd->(eval(blk,s))
s := st+"3. Страховой номер индивидуального лицевого счета: "
s += iif(empty(kart->snils), replicate("_",25), ub+transform(kart->SNILS,picture_pf)+ue)+"."
frd->(eval(blk,s))
s := st+"4. Адрес места жительства (пребывания): "
if emptyall(kart_->okatog,kart->adres)
  s += replicate("_",37)+" "+replicate("_",sh)+"."
else
  s += ub+ret_okato_ulica(kart->adres,kart_->okatog,1,2)+ue+"."
endif
frd->(eval(blk,s))
s := st+"5. Категория: "+f3_inf_DDS_karta(mm_kateg_uch,m1kateg_uch,"; ",ub,ue)
frd->(eval(blk,s))
s := st+"6. Полное наименование медицинской организации, в которой "+;
        "несовершеннолетний получает первичную медико-санитарную помощь: "
s += ub+ret_mo(m1MO_PR)[_MO_FULL_NAME]+ue+"."
frd->(eval(blk,s))
s := st+"7. Адрес места нахождения медицинской организации, в которой " +;
         "несовершеннолетний получает первичную медико-санитарную помощь: "
s += ub+ret_mo(m1MO_PR)[_MO_ADRES]+ue+"."
frd->(eval(blk,s))
madresschool := ""
if type("m1school") == "N" .and. m1school > 0
  R_Use(dir_server+"mo_schoo",,"SCH")
  goto (m1school)
  if !empty(sch->fname)
    mschool := alltrim(sch->fname)
    madresschool := alltrim(sch->adres)
  endif
endif
s := st+"8. Полное наименование образовательной организации, в которой "+;
        "обучается несовершеннолетний: "+ub+mschool+ue+"."
frd->(eval(blk,s))
s := st+"9. Адрес места нахождения образовательной организации, в которой "+;
        "обучается несовершеннолетний: "
if empty(madresschool)
  frd->(eval(blk,s))
  s := replicate("_",sh)+"."
else
  s += ub+madresschool+ue+"."
endif
frd->(eval(blk,s))
s := st+"10. Дата начала профилактического медицинского осмотра несовершеннолетнего (далее - профилактический осмотр): "+ub+full_date(mn_data)+ue+"."
frd->(eval(blk,s))
s := st+"11. Полное наименование и адрес места нахождения медицинской организации, "+;
        "проводившей профилактический осмотр: "+;
        ub+glob_mo[_MO_FULL_NAME]+", "+glob_mo[_MO_ADRES]+ue+"."
frd->(eval(blk,s))
s := st+"12. Оценка физического развития с учетом возраста на момент профилактического осмотра:"
frd->(eval(blk,s))
count_ymd(mdate_r,mn_data,@y,@m,@d)
s := ub+st+lstr(d)+st+ue+" (число дней) "+;
     ub+st+lstr(m)+st+ue+" (месяцев) "+;
     ub+st+lstr(y)+st+ue+" лет."
frd->(eval(blk,s))
mm_fiz_razv1 := {{"дефицит массы тела",1},{"избыток массы тела",2}}
mm_fiz_razv2 := {{"низкий рост",1},{"высокий рост",2}}
for i := 1 to 2
  s := st+"12."+lstr(i)+". Для детей в возрасте "+;
          {"0 - 4 лет: ","5 - 17 лет включительно: "}[i]
  if i == 1
    fl := (lvozrast < 5)
  else
    fl := (lvozrast > 4)
  endif
  s += "масса (кг) "+iif(!fl,"________",ub+st+lstr(mWEIGHT)+st+ue)+"; "
  s += "рост (см) "+iif(!fl,"________",ub+st+lstr(mHEIGHT)+st+ue)+"; "
  if i == 1
    s += "окружность головы (см) "+iif(!fl.or.mPER_HEAD==0,"________",ub+st+lstr(mPER_HEAD)+st+ue)+"; "
  endif
  s += "физическое развитие "+f3_inf_DDS_karta(mm_fiz_razv,iif(fl,m1FIZ_RAZV,-1),,ub,ue,.f.)
  s += " ("+f3_inf_DDS_karta(mm_fiz_razv1,iif(fl,m1FIZ_RAZV1,-1),,ub,ue,.f.)
  s += ", "+f3_inf_DDS_karta(mm_fiz_razv2,iif(fl,m1FIZ_RAZV2,-1),,ub,ue,.f.)
  s += " - нужное подчеркнуть)."
  frd->(eval(blk,s))
next
fl := (lvozrast < 5)
s := st+"13. Оценка психического развития (состояния):"
frd->(eval(blk,s))
s := st+"13.1. Для детей в возрасте 0 - 4 лет:"
frd->(eval(blk,s))
s := st+"познавательная функция (возраст развития) "+iif(!fl,"________",ub+st+lstr(m1psih11)+st+ue)+";"
frd->(eval(blk,s))
s := st+"моторная функция (возраст развития) "+iif(!fl,"________",ub+st+lstr(m1psih12)+st+ue)+";"
frd->(eval(blk,s))
s := st+"эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития) "+iif(!fl,"________",ub+st+lstr(m1psih13)+st+ue)+";"
frd->(eval(blk,s))
s := st+"предречевое и речевое развитие (возраст развития) "+iif(!fl,"________",ub+st+lstr(m1psih14)+st+ue)+"."
frd->(eval(blk,s))
fl := (lvozrast > 4)
s := st+"13.2. Для детей в возрасте 5 - 17 лет:"
frd->(eval(blk,s))
s := st+"13.2.1. Психомоторная сфера: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih21,-1),,ub,ue)
frd->(eval(blk,s))
s := st+"13.2.2. Интеллект: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih22,-1),,ub,ue)
frd->(eval(blk,s))
s := st+"13.2.3. Эмоционально-вегетативная сфера: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih23,-1),,ub,ue)
frd->(eval(blk,s))
fl := (mpol == "М" .and. lvozrast > 9)
s := st+"14. Оценка полового развития (с 10 лет):"
frd->(eval(blk,s))
s := st+"14.1. Половая формула мальчика: Р "+iif(!fl.or.m141p==0,"________",ub+st+lstr(m141p)+st+ue)
s += " Ах "+iif(!fl.or.m141ax==0,"________",ub+st+lstr(m141ax)+st+ue)
s += " Fa "+iif(!fl.or.m141fa==0,"________",ub+st+lstr(m141fa)+st+ue)+"."
frd->(eval(blk,s))
fl := (mpol == "Ж" .and. lvozrast > 9)
s := st+"14.2. Половая формула девочки: Р "+iif(!fl.or.m142p==0,"________",ub+st+lstr(m142p)+st+ue)
s += " Ах "+iif(!fl.or.m142ax==0,"________",ub+st+lstr(m142ax)+st+ue)
s += " Ma "+iif(!fl.or.m142ma==0,"________",ub+st+lstr(m142ma)+st+ue)
s += " Me "+iif(!fl.or.m142me==0,"________",ub+st+lstr(m142me)+st+ue)+";"
frd->(eval(blk,s))
s := st+"характеристика менструальной функции: menarhe ("
s += iif(!fl.or.m142me1==0,"________",ub+st+lstr(m142me1)+st+ue)+" лет, "
s += iif(!fl.or.m142me2==0,"________",ub+st+lstr(m142me2)+st+ue)+" месяцев); "
if fl .and. emptyall(m142p,m142ax,m142ma,m142me,m142me1,m142me2)
  m1142me3 := m1142me4 := m1142me5 := -1
endif
s += "menses (характеристика): "+f3_inf_DDS_karta(mm_142me3,iif(fl,m1142me3,-1),,ub,ue,.f.)
s += ", "+f3_inf_DDS_karta(mm_142me4,iif(fl,m1142me4,-1),,ub,ue,.f.)
s += ", "+f3_inf_DDS_karta(mm_142me5,iif(fl,m1142me5,-1)," и ",ub,ue)
frd->(eval(blk,s))
s := st+"15. Состояние здоровья до проведения настоящего профилактического осмотра:"
frd->(eval(blk,s))
if lvozrast < 14
  mdef_diagnoz := "Z00.1"
else
  mdef_diagnoz := "Z00.3"
endif
s := st+"15.1. Практически здоров "+iif(m1diag_15_1==0,replicate("_",30),ub+st+rtrim(mdef_diagnoz)+st+ue)+" (код по МКБ)."
frd->(eval(blk,s))
//
mm_dispans := {{"установлено ранее",1},{"установлено впервые",2},{"не установлено",0}}
mm_danet := {{"да",1},{"нет",0}}
mm_usl := {{"в амбулаторных условиях",0},;
           {"в условиях дневного стационара",1},;
           {"в стационарных условиях",2}}
mm_uch := {{"в муниципальных медицинских организациях",1},;
           {"в государственных медицинских организациях субъекта Российской Федерации ",0},;
           {"в федеральных медицинских организациях",2},;
           {"частных медицинских организациях",3}}
mm_uch1 := aclone(mm_uch)
aadd(mm_uch1, {"санаторно-курортных организациях",4})
mm_danet1 := {{"оказана",1},{"не оказана",0}}
for i := 1 to 5
  fl := .f.
  for k := 1 to 14
    mvar := "mdiag_15_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_15_1 == 0
    else
      m1var := "m1diag_15_"+lstr(i)+"_"+lstr(k)
      if fl
        do case
          case eq_any(k,4,5,6,7)
            mvar := "m1diag_15_"+lstr(i)+"_3"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
          case eq_any(k,9,10,11,12)
            mvar := "m1diag_15_"+lstr(i)+"_8"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
          case k == 14
            mvar := "m1diag_15_"+lstr(i)+"_13"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
        endcase
      else
        &m1var := -1
      endif
    endif
  next
next
for i := 1 to 5
  fl := .f.
  s := s1 := s2 := s3 := s4 := s5 := s6 := ""
  for k := 1 to 2
    mvar := "mdiag_15_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_15_1 == 0
    else
      m1var := "m1diag_15_"+lstr(i)+"_"+lstr(k)
      if (j := &m1var) > 0
        j := 1
      endif
    endif
    do case
      case k == 1
        s := st+"15."+lstr(i+1)+". Диагноз "+iif(!fl,replicate("_",30),ub+st+rtrim(&mvar)+st+ue)+" (код по МКБ)."
      case k == 2
        s1 := st+"15."+lstr(i+1)+".1. Диспансерное наблюдение установлено: "+f3_inf_DDS_karta(mm_danet,j,,ub,ue)
    endcase
  next
  frd->(eval(blk,s))
  frd->(eval(blk,s1))
next
mm_gruppa := {{"I",1},{"II",2},{"III",3},{"IV",4},{"V",5}}
s := st+"15.7. Группа состояния здоровья: "+f3_inf_DDS_karta(mm_gruppa,mGRUPPA_DO,,ub,ue)
frd->(eval(blk,s))
s := st+"15.8. Медицинская группа для занятий физической культурой: "+f3_inf_DDS_karta(mm_gr_fiz_do,m1GR_FIZ_DO,,ub,ue)
frd->(eval(blk,s))
s := st+"16. Состояние здоровья по результатам проведения настоящего профилактического осмотра:"
frd->(eval(blk,s))
s := st+"16.1. Практически здоров "+iif(m1diag_16_1==0,replicate("_",30),ub+st+rtrim(mkod_diag)+st+ue)+" (код по МКБ)."
frd->(eval(blk,s))
for i := 1 to 5
  fl := .f.
  for k := 1 to 16
    mvar := "mdiag_16_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_16_1 == 0
    else
      m1var := "m1diag_16_"+lstr(i)+"_"+lstr(k)
      if fl
        do case
          case eq_any(k,5,6)
            mvar := "m1diag_16_"+lstr(i)+"_4"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
          case eq_any(k,8,9)
            mvar := "m1diag_16_"+lstr(i)+"_7"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
          case eq_any(k,11,12)
            mvar := "m1diag_16_"+lstr(i)+"_10"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
          case eq_any(k,14,15)
            mvar := "m1diag_16_"+lstr(i)+"_13"
            if &mvar != 1 // если не "да"
              &m1var := -1
            endif
        endcase
      else
        &m1var := -1
      endif
    endif
  next
next
for i := 1 to 5
  fl := .f.
  s := s1 := s2 := s3 := s4 := s5 := s6 := s7 := ""
  for k := 1 to 15
    mvar := "mdiag_16_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_16_1 == 0
    else
      m1var := "m1diag_16_"+lstr(i)+"_"+lstr(k)
    endif
    do case
      case k == 1
        s := st+"16."+lstr(i+1)+". Диагноз "+iif(!fl,replicate("_",30),ub+st+rtrim(&mvar)+st+ue)+" (код по МКБ)."
      case k == 2
        s1 := st+"16."+lstr(i+1)+".1. Диагноз установлен впервые: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 3
        s2 := st+"16."+lstr(i+1)+".2. Диспансерное наблюдение: "+f3_inf_DDS_karta(mm_dispans,&m1var,,ub,ue)
      case k == 4
        s3 := st+"16."+lstr(i+1)+".3. Дополнительные консультации и исследования назначены: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 5
        s3 := left(s3,len(s3)-1)+'; если "да": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 6
        s3 := left(s3,len(s3)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 7
        s4 := st+"16."+lstr(i+1)+".4. Дополнительные консультации и исследования выполнены: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 8
        s4 := left(s4,len(s4)-1)+'; если "да": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 9
        s4 := left(s4,len(s4)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 10
        s5 := st+"16."+lstr(i+1)+".5. Лечение назначено: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 11
        s5 := left(s5,len(s5)-1)+'; если "да": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 12
        s5 := left(s5,len(s5)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 13
        s6 := st+"16."+lstr(i+1)+".6. Медицинская реабилитация и (или) санаторно-курортное лечение назначены: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 14
        s6 := left(s6,len(s6)-1)+'; если "да": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 15
        s6 := left(s6,len(s6)-1)+'; '+f3_inf_DDS_karta(mm_uch1,&m1var,,ub,ue)
    endcase
  next
  frd->(eval(blk,s))
  frd->(eval(blk,s1))
  frd->(eval(blk,s2))
  frd->(eval(blk,s3))
  frd->(eval(blk,s4))
  frd->(eval(blk,s5))
  frd->(eval(blk,s6))
next
if m1invalid1 == 0
  m1invalid2 := m1invalid5 := m1invalid6 := m1invalid8 := -1
  minvalid3 := minvalid4 := minvalid7 := ctod("")
endif
if empty(minvalid7)
  m1invalid8 := -1
endif
s := st+'16.7. Инвалидность: '+f3_inf_DDS_karta(mm_danet,m1invalid1,,ub,ue)
s := left(s,len(s)-1)+'; если "да": '+f3_inf_DDS_karta(mm_invalid2,m1invalid2,,ub,ue)
s := left(s,len(s)-1)+'; установлена впервые (дата) '+iif(empty(minvalid3), replicate("_",15), ub+full_date(minvalid3)+ue)
s += '; дата последнего освидетельствования '+iif(empty(minvalid4), replicate("_",15), ub+full_date(minvalid4)+ue)+'.'
frd->(eval(blk,s))
/*s := st+'16.7.1. Заболевания, обусловившие возникновение инвалидности:'
frd->(eval(blk,s))
mm_invalid5[6,1] := "болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм;"
mm_invalid5[7,1] := "болезни эндокринной системы, расстройства питания и нарушения обмена веществ,"
atail(mm_invalid5)[1] := "последствия травм, отравлений и других воздействий внешних причин)"
s := st+'('+f3_inf_DDS_karta(mm_invalid5,m1invalid5,' ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.2.Виды нарушений в состоянии здоровья:'
frd->(eval(blk,s))
s := st+f3_inf_DDS_karta(mm_invalid6,m1invalid6,'; ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.3. Индивидуальная программа реабилитации ребенка-инвалида:'
frd->(eval(blk,s))
s := st+'дата назначения: '+iif(empty(minvalid7), replicate("_",15), ub+full_date(minvalid7)+ue)+';'
frd->(eval(blk,s))
s := st+'выполнение на момент диспансеризации: '+f3_inf_DDS_karta(mm_invalid8,m1invalid8,,ub,ue)
frd->(eval(blk,s))*/
s := st+"16.8. Группа состояния здоровья: "+f3_inf_DDS_karta(mm_gruppa,mGRUPPA,,ub,ue)
frd->(eval(blk,s))
s := st+"16.9. Медицинская группа для занятий физической культурой: "
s += f3_inf_DDS_karta(mm_gr_fiz,m1GR_FIZ,,ub,ue)
frd->(eval(blk,s))
/*s := st+'16.10'+'. Проведение профилактических прививок:'
frd->(eval(blk,s))
s := st
for j := 1 to len(mm_privivki1)
  if m1privivki1 == mm_privivki1[j,2]
    s += ub
  endif
  s += mm_privivki1[j,1]
  if m1privivki1 == mm_privivki1[j,2]
    s += ue
  endif
  if mm_privivki1[j,2] == 0
    s += "; "
  else
    s += ": "+f3_inf_DDS_karta(mm_privivki2,iif(m1privivki1==mm_privivki1[j,2],m1privivki2,-1),,ub,ue,.f.)+"; "
  endif
next
s += 'нуждается в проведении вакцинации (ревакцинации) с указанием наименования прививки (нужное подчеркнуть): '
if m1privivki1 > 0 .and. !empty(mprivivki3)
  s += ub+alltrim(mprivivki3)+ue
endif
frd->(eval(blk,s))
s := replicate("_",sh)+"."
frd->(eval(blk,s))*/
s := st+'17. Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой: '
k := 3
if !empty(mrek_form)
  k := 1
  s += ub+alltrim(mrek_form)+ue
endif
frd->(eval(blk,s))
for i := 1 to k
  s := replicate("_",sh)+iif(i==k, ".", "")
  frd->(eval(blk,s))
next
s := st+'18. Рекомендации по проведению диспансерного наблюдения, '+;
        'лечению, медицинской реабилитации и санаторно-курортному лечению: '
k := 5
if !empty(mrek_disp)
  k := 2
  s += ub+alltrim(mrek_disp)+ue
endif
frd->(eval(blk,s))
for i := 1 to k
  s := replicate("_",sh)+iif(i==k, ".", "")
  frd->(eval(blk,s))
next
//
adbf := {{"name","C",60,0},;
         {"data","C",10,0},;
         {"rezu","C",17,0}}
dbcreate(fr_data+"1",adbf)
use (fr_data+"1") new alias FRD1
dbcreate(fr_data+"2",adbf)
use (fr_data+"2") new alias FRD2
/*arr := f4_inf_DNL_karta(1)
for i := 1 to len(arr)
  select FRD1
  append blank
  frd1->name := arr[i,1]
  frd1->data := full_date(arr[i,2])
next
arr := f4_inf_DNL_karta(2)
for i := 1 to len(arr)
  select FRD2
  append blank
  frd2->name := arr[i,1]
  frd2->data := full_date(arr[i,2])
  frd2->rezu := arr[i,3]
next*/
//
close databases
call_fr("mo_030pou17")
return NIL

***** 27.09.18
Function f4_inf_DNL_karta(par,_etap)
Local i, k := 0, fl, arr := {}, ar
if type("mperiod") == "N" .and. between(mperiod,1,31)
  //
else
  mperiod := ret_period_PN(mdate_r,mn_data,mk_data,,@k)
endif
if !between(mperiod,1,31)
  mperiod := k
endif
if !between(mperiod,1,31)
  mperiod := 31
endif
np_oftal_2_85_21(mperiod,mk_data)
ar := np_arr_1_etap[mperiod]
if par == 1
  if iif(_etap==nil, .t., _etap==1)
    for i := 1 to count_pn_arr_osm
      mvart := "MTAB_NOMov"+lstr(i)
      mvard := "MDATEo"+lstr(i)
      fl := .t.
      if fl .and. !empty(np_arr_osmotr[i,2])
        fl := (mpol == np_arr_osmotr[i,2])
      endif
      if fl
        fl := (!empty(ar[4]) .and. ascan(ar[4],np_arr_osmotr[i,1]) > 0)
      endif
      if fl .and. !emptyany(&mvard,&mvart)
        aadd(arr, {np_arr_osmotr[i,3], &mvard, "", i, f5_inf_DNL_karta(i)})
      endif
    next
  endif
  aadd(arr, {"педиатр (врач общей практики)", MDATEp1, "", -1, 1})
  if metap == 2 .and. iif(_etap==nil, .t., _etap==2)
    for i := 1 to count_pn_arr_osm
      mvart := "MTAB_NOMov"+lstr(i)
      mvard := "MDATEo"+lstr(i)
      fl := .t.
      if fl .and. !empty(np_arr_osmotr[i,2])
        fl := (mpol == np_arr_osmotr[i,2])
      endif
      if fl
        fl := (ascan(ar[4],np_arr_osmotr[i,1]) == 0)
      endif
      if fl .and. !emptyany(&mvard,&mvart)
        aadd(arr, {np_arr_osmotr[i,3], &mvard, "", i, f5_inf_DNL_karta(i)})
      endif
    next
    aadd(arr, {"педиатр (врач общей практики)", MDATEp2, "", -2, 1})
  endif
else
  for i := 1 to count_pn_arr_iss // исследования
    mvart := "MTAB_NOMiv"+lstr(i)
    mvard := "MDATEi"+lstr(i)
    mvarr := "MREZi"+lstr(i)
    fl := .t.
    if fl .and. !empty(np_arr_issled[i,2])
      fl := (mpol == np_arr_issled[i,2])
    endif
    if fl
      fl := (ascan(ar[5],np_arr_issled[i,1]) > 0)
    endif
    if fl .and. !emptyany(&mvard,&mvart)
      k := 0
      do case
        case i == 1 // {"3.5.4"   ,   , "Аудиологический скрининг",0,64,{1111,111101} },;
          k := 15
        case i == 2 // {"4.2.153" ,   , "Общий анализ мочи",0,34,{1107,1301,1402,1702} },;
          k := 2
        //case i == 3 // {"4.8.1"   ,   , "Общий анализ кала",0,34,{1107,1301,1402,1702} },;
          //k := 3
        //case i == 4 // {"4.11.136",   , "Клинический анализ крови",0,34,{1107,1301,1402,1702} },;
        case i == 3 // {"4.11.136",   , "Клинический анализ крови",0,34,{1107,1301,1402,1702} },;
          k := 1
        //case i == 5 // {"4.12.169",   , "Исследование уровня глюкозы в крови",0,34,{1107,1301,1402,1702} },;
          //k := 4
        //case between(i,6,16) // {"4.14.67" ,   , "пролактин (гормон)",1,34,{1107,1301,1402,1702} },;
          //k := 5
        //case between(i,17,21) // {"4.26.1"  ,   , "Неонатальный скрининг на гипотиреоз",0,34,{1107,1301,1402,1702} },;
        case between(i,4,8) // {"4.26.1"  ,   , "Неонатальный скрининг на гипотиреоз",0,34,{1107,1301,1402,1702} },;
          k := 14
        //case i == 22 // {"7.61.3"  ,   , "Флюорография легких в 1-й проекции",0,78,{1118,1802} },;
          //k := 12
        //case i == 23 // {"8.1.1"   ,   , "УЗИ головного мозга (нейросонография)",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
        case i == 9 // {"8.1.1"   ,   , "УЗИ головного мозга (нейросонография)",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 11
        //case i == 24 // {"8.1.2"   ,   , "УЗИ щитовидной железы",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          //k := 8
        case i == 12 // {"8.1.6"   , 12, "УЗИ почек",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 18
        //case i == 25 // {"8.1.3"   ,   , "УЗИ сердца",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
        case i == 10 // {"8.1.3"   ,   , "УЗИ сердца",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 7
        //case i == 26 // {"8.1.4"   ,   , "УЗИ тазобедренных суставов",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
        case i == 11 // {"8.1.4"   ,   , "УЗИ тазобедренных суставов",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 10
        //case i == 27 // {"8.2.1"   ,   , "УЗИ органов брюшной полости",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
        case i == 13 // {"8.2.1"   ,   , "УЗИ органов брюшной полости",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 6
        //case between(i,28,29) // {"8.2.2"   ,"М", "УЗИ органов репродуктивной системы",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          //k := 9
        //case i == 30 // {"13.1.1"  ,   , "Электрокардиография",0,111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202} },;
        case i == 14 // {"13.1.1"  ,   , "Электрокардиография",0,111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202} },;
          k := 13
      endcase
      aadd(arr, {np_arr_issled[i,3], &mvard, &mvarr, i, k})
    endif
  next
endif
return arr

***** 25.11.13
Function f5_inf_DNL_karta(i)
Local k := 0
do case
  case i == 14 // {"2.85.16","Ж", "акушер-гинеколог", 2, {1101} },;
    k := 11
  case i == 15 // {"2.85.17","М", "детский уролог-андролог", 19, {112603,113502} },;
    k := 10
  case i == 16 // {"2.85.18",   , "детский хирург", 20, {1135} },;
    k := 4
  case i == 17 // {"2.85.19",   , "травматолог-ортопед", 100, {1123} },;
    k := 6
  case i == 18 // {"2.85.20",   , "невролог", 53, {1109} },;
    k := 2
  case i == 19 // {"2.85.21",   , "офтальмолог", 65, {1112} },;
    k := 3
  case i == 20 // {"2.85.22",   , "отоларинголог", 64, {1111,111101} },;
    k := 5
  case i == 21 // {"2.85.23",   , "детский стоматолог", 86, {140102} },;
    k := 8
  case i == 22 // {"2.85.24",   , "детский эндокринолог", 21, {1127,112702,113402} },;
    k := 9
  case i == 23 // {"2.4.1"  ,   , "психиатр", 72, {1115} };
    k := 7
endcase
return k

***** 15.07.19 Приложение к письму ГБУЗ "ВОМИАЦ" №1025 от 08.07.2019г.
Function f21_inf_DNL(par)
Local arr_m, buf := save_maxrow(), lkod_h, lkod_k, rec, s, adbf, as, i, j, k, ;
      sh, HH := 60, n, n_file := "svod_dnl"+stxt
if (arr_m := year_month(,,,5)) != NIL
  mywait()
  if f0_inf_DNL(arr_m,par > 1,par == 3,{301,302,303,304,305})
    R_Use(dir_server+"mo_rpdsh",,"RPDSH")
    index on str(KOD_H,7) to (cur_dir+"tmprpdsh")
    adbf := {{"ti","N",1,0},;
             {"mm","N",2,0},;
             {"mm1","N",1,0},;
             {"vsego","N",6,0},;
             {"vsego1","N",6,0},;
             {"vsegoM","N",6,0},;
             {"g1","N",6,0},;
             {"g2","N",6,0},;
             {"g3","N",6,0},;
             {"g4","N",6,0},;
             {"g4inv","N",6,0},;
             {"g5","N",6,0},;
             {"g5inv","N",6,0},;
             {"mg1","N",6,0},;
             {"mg2","N",6,0},;
             {"mg3","N",6,0},;
             {"mg4","N",6,0},;
             {"sv","N",6,0},;
             {"so","N",6,0},;
             {"v2","N",6,0},;
             {"m15","N",6,0},;
             {"m15a","N",6,0},;
             {"m15p","N",6,0},;
             {"m15e","N",6,0},;
             {"g15","N",6,0},;
             {"g15g","N",6,0},;
             {"g15p","N",6,0},;
             {"g15e","N",6,0}}
    dbcreate(cur_dir+"tmp1",adbf)
    use (cur_dir+"tmp1") new
    index on str(ti,1)+str(mm,2)+str(mm1,1) to (cur_dir+"tmp1")
    adbf := {{"ti","N",1,0},;
             {"g1","N",6,0},;
             {"g2","N",6,0},;
             {"g3","N",6,0},;
             {"g4","N",6,0},;
             {"g5","N",6,0},;
             {"g6","N",6,0},;
             {"g7","N",6,0},;
             {"g8","N",6,0},;
             {"g9","N",6,0},;
             {"g10","N",6,0},;
             {"g11","N",6,0},;
             {"g12","N",6,0},;
             {"g13","N",6,0}}
    dbcreate(cur_dir+"tmp2",adbf)
    use (cur_dir+"tmp2") new
    index on str(ti,1) to (cur_dir+"tmp2")
    R_Use(dir_server+"mo_schoo",,"SCH")
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use_base("human_u")
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",,"HUMAN")
    set relation to recno() into HUMAN_, to kod_k into KART_
    use (cur_dir+"tmp") new
    set relation to kod into HUMAN
    go top
    do while !eof()
      @ maxrow(),0 say str(recno()/lastrec()*100,6,2)+"%" color cColorWait
      f1_f21_inf_DNL(tmp->kod,tmp->kod_k)
      select TMP
      skip
    enddo
    close databases
    arr_title := {;
"────────┬─────────────────┬─────────────────────────────────────────┬───────────────────────┬───────────┬─────┬─────",;
"        │Число детей Iэтап│распределение по группам здоровья I этап │распр-ие по мед.группам│Случаев Iэт│напр.│завер",;
"отчетный├─────┬─────┬─────┼─────┬─────┬─────┬─────┬─────┬─────┬─────┼─────┬─────┬─────┬─────┼─────┬─────┤на   │шило ",;
"период  │всего│до 1г│моб/к│  1  │  2  │  3  │  4  │4инв.│  5  │5инв.│основ│подго│спецА│спецБ│зарег│оплач│2 эт.│2 эт.",;
"────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────",;
"        │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 │  14 │  15 │  16 │  17 │  18 │  19 │  20 │  21 │  22 │  23 ",;
"────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"}
    sh := len(arr_title[1])
    fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
    add_string(glob_mo[_MO_SHORT_NAME])
    add_string(padl('Приложение к письму ГБУЗ "ВОМИАЦ"',sh))
    add_string(padl("№1025 от 08.07.2019г.",sh))
    add_string("")
    add_string(center("[ "+charrem("~",mas1pmt[par])+" ]",sh))
    add_string(center("("+arr_m[4]+")",sh))
    use (cur_dir+"tmp1") index (cur_dir+"tmp1") new
    as := array(18,2)
    for i := 1 to 1//iif(arr_m[1] < 18, 3, 1)
      afillall(as,0)
      if i == 3
        arr_title := {;
"────────┬───────────┬─────────────────────────────┬───────────",;
"        │Число детей│распределение по группам здор│Случаев 1эт",;
"отчетный├─────┬─────┼─────┬─────┬─────┬─────┬─────┼─────┬─────",;
"период  │всего│моб/к│  1  │  2  │  3  │  4  │  5  │зарег│оплач",;
"────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────",;
"        │  1  │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  ",;
"────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"}
        sh := len(arr_title[1])
      endif
      verify_FF(HH-12,.t.,sh)
      add_string("")
      add_string(center("Сведения о "+{"профилактических",;
                                       "предварительных",;
                                       "периодических"}[i]+" осмотрах несовершеннолетних",sh))
      add_string("")
      aeval(arr_title, {|x| add_string(x) } )
      find (str(i,1))
      do while tmp1->ti == i .and. !eof()
        j := 1
        if i == 3
          s := padr(mm_month[tmp1->mm],8)+;
               put_val(tmp1->vsego,6)+;
               put_val(tmp1->vsegoM,6)+;
               put_val(tmp1->g1,6)+;
               put_val(tmp1->g2,6)+;
               put_val(tmp1->g3,6)+;
               put_val(tmp1->g4,6)+;
               put_val(tmp1->g5,6)+;
               put_val(tmp1->sv,6)+;
               put_val(tmp1->so,6)
        else
          if tmp1->mm1 == 0
            s := padr(mm_month[tmp1->mm],8)
          else
            j := 2
            s := padl("до 1г.",8)
          endif
          s += put_val(tmp1->vsego,6)+;
               put_val(tmp1->vsego1,6)+;
               put_val(tmp1->vsegoM,6)+;
               put_val(tmp1->g1,6)+;
               put_val(tmp1->g2,6)+;
               put_val(tmp1->g3,6)+;
               put_val(tmp1->g4,6)+;
               put_val(tmp1->g4inv,6)+;
               put_val(tmp1->g5,6)+;
               put_val(tmp1->g5inv,6)+;
               put_val(tmp1->mg1,6)+;
               put_val(tmp1->mg2,6)+;
               put_val(tmp1->mg3,6)+;
               put_val(tmp1->mg4,6)+;
               put_val(tmp1->sv,6)+;
               put_val(tmp1->so,6)+;
               put_val(tmp1->v2,6)+;
               put_val(tmp1->v2,6)
        endif
        if verify_FF(HH-1,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        add_string(s)
        add_string(replicate("─",sh))
        as[ 1,j] += tmp1->vsego
        as[ 2,j] += tmp1->vsego1
        as[ 3,j] += tmp1->vsegoM
        as[ 4,j] += tmp1->g1
        as[ 5,j] += tmp1->g2
        as[ 6,j] += tmp1->g3
        as[ 7,j] += tmp1->g4
        as[ 8,j] += tmp1->g4inv
        as[ 9,j] += tmp1->g5
        as[10,j] += tmp1->g5inv
        as[11,j] += tmp1->mg1
        as[12,j] += tmp1->mg2
        as[13,j] += tmp1->mg3
        as[14,j] += tmp1->mg4
        as[15,j] += tmp1->sv
        as[16,j] += tmp1->so
        as[17,j] += tmp1->v2
        as[18,j] += tmp1->v2
        skip
      enddo
      j := 1
      s := padr(lstr(year(arr_m[6]))+" год",8)
      if i == 3
        s += put_val(as[ 1,j],6)+;
             put_val(as[ 3,j],6)+;
             put_val(as[ 4,j],6)+;
             put_val(as[ 5,j],6)+;
             put_val(as[ 6,j],6)+;
             put_val(as[ 7,j],6)+;
             put_val(as[ 8,j],6)+;
             put_val(as[13,j],6)+;
             put_val(as[14,j],6)
      else
        for k := 1 to len(as)
          s += put_val(as[k,j],6)
        next
      endif
      add_string(s)
      if i == 1
        s := padl("до 1г.",8)
        for k := 1 to len(as)
          s += put_val(as[k,2],6)
        next
        add_string(s)
      endif
      add_string(replicate("─",sh))
    next
    //
    afillall(as,0)
    verify_FF(HH-10,.t.,sh)
    arr_title := {;
"────────┬───────────────────────┬───────────────────────",;
"        │    Юноши (15-17 лет)  │  Девушки (15-17 лет)  ",;
"отчетный├───────────┬─────┬─────┼───────────┬─────┬─────",;
"период  │факт (чел.)│патол│напр.│факт (чел.)│патол│напр.",;
"        ├─────┬─────┤репр.│на II├─────┬─────┤репр.│на II",;
"        │всего│андро│сист.│этап │всего│гинек│сист.│этап ",;
"────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────",;
"        │  2  │  3  │  4  │  5  │  2  │  3  │  4  │  5  ",;
"────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"}
    sh := len(arr_title[1])
    i := 1
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    find (str(i,1))
    do while tmp1->ti == i .and. !eof()
      j := 1
      s := padr(mm_month[tmp1->mm],8)+;
           put_val(tmp1->m15,6)+;
           put_val(tmp1->m15a,6)+;
           put_val(tmp1->m15p,6)+;
           put_val(tmp1->m15e,6)+;
           put_val(tmp1->g15,6)+;
           put_val(tmp1->g15g,6)+;
           put_val(tmp1->g15p,6)+;
           put_val(tmp1->g15e,6)
      if verify_FF(HH-1,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s)
      add_string(replicate("─",sh))
      as[ 1,j] += tmp1->m15
      as[ 2,j] += tmp1->m15a
      as[ 3,j] += tmp1->m15p
      as[ 4,j] += tmp1->m15e
      as[ 5,j] += tmp1->g15
      as[ 6,j] += tmp1->g15g
      as[ 7,j] += tmp1->g15p
      as[ 8,j] += tmp1->g15e
      skip
    enddo
    j := 1
    s := padr(lstr(year(arr_m[6]))+" год",8)
    for k := 1 to 8
      s += put_val(as[k,j],6)
    next
    add_string(s)
    add_string(replicate("─",sh))
    //
    verify_FF(HH-11,.t.,sh)
    arr_title := {;
"─────────┬─────────────────┬─────────────────┬─────┬─────────────────┬─────┬─────┬─────",;
"         │    Осмотрено    │из них сельских ж│впер-│     из них      │из г7│из г7│из   ",;
"Контин-  ├─────┬─────┬─────┼─────┬─────┬─────┤вые  ├─────┬─────┬─────┤взяты│нача-│гр.12",;
"гент     │     │после│в суб│     │после│в суб│неинф│болез│     │из г9│на   │то   │сель-",;
"         │всего│18:00│боту │всего│18:00│боту │екцио│крово│ ЗНО │I иII│дисп.│лече-│ских ",;
"         │     │     │     │     │     │     │нные │обращ│     │стад.│набл.│ние  │жител",;
"─────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────",;
"         │  1  │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 ",;
"─────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"}
    sh := len(arr_title[1])
    add_string('в рамках национального проекта "Здравоохранение"')
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    use (cur_dir+"tmp2") index (cur_dir+"tmp2") new
    go top
    do while !eof()
      s := padr({"0-14 лет","15-17 лет","Всего"}[tmp2->ti],9)+;
           put_val(tmp2->g1,6)+;
           put_val(tmp2->g2,6)+;
           put_val(tmp2->g3,6)+;
           put_val(tmp2->g4,6)+;
           put_val(tmp2->g5,6)+;
           put_val(tmp2->g6,6)+;
           put_val(tmp2->g7,6)+;
           put_val(tmp2->g8,6)+;
           put_val(tmp2->g9,6)+;
           put_val(tmp2->g10,6)+;
           put_val(tmp2->g11,6)+;
           put_val(tmp2->g12,6)+;
           put_val(tmp2->g13,6)
      if verify_FF(HH-1,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s)
      add_string(replicate("─",sh))
      skip
    enddo
    //
    fclose(fp)
    close databases
    viewtext(n_file,,,,(.t.),,,3)
  endif
endif
close databases
rest_box(buf)
return NIL

***** 15.07.19
Function f1_f21_inf_DNL(Loc_kod,kod_kartotek) // сводная информация
Local ii, im, i, j, k, s, sumr := 0, is_do1g := 0, ltip_school := -1, ar15[8], is_2 := .f., ad := {}, arr, a3 := {}
Private m1tip_school := -1, m1school := 0, mvozrast, mdvozrast, mgruppa := 0, m1GR_FIZ := 1, m1invalid1 := 0
Private mvar, m1var
afill(ar15,0)
mvozrast := count_years(human->date_r,human->n_data)
mdvozrast := year(human->n_data) - year(human->date_r)
for i := 1 to 5
  for k := 1 to 16
    s := "diag_16_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      Private &mvar := space(6)
    else
      m1var := "m1"+s
      Private &m1var := 0
      Private &mvar := space(3)
    endif
  next
next
if human->ishod == 305
  ii := 3
  read_arr_PerN(Loc_kod)
  mGRUPPA := human_->RSLT_NEW - 342//L_BEGIN_RSLT
elseif eq_any(human->ishod,303,304)
  ii := 2
  is_2 := (human->ishod == 304) // это второй этап
  read_arr_PredN(Loc_kod)
  mGRUPPA := human_->RSLT_NEW - 336//L_BEGIN_RSLT
  ltip_school := m1tip_school
else
  ii := 1
  is_2 := (human->ishod == 302) // это второй этап
  read_arr_PN(Loc_kod)
  mGRUPPA := human_->RSLT_NEW - 331//L_BEGIN_RSLT
  is_do1g := iif(mvozrast == 0, 1, 0)
  if m1school > 0
    select SCH
    goto (m1school)
    ltip_school := sch->tip
  endif
  for i := 1 to 5
    j := 0
    for k := 1 to 16
      s := "diag_16_"+lstr(i)+"_"+lstr(k)
      mvar := "m"+s
      if k == 1
        if !empty(&mvar)
          arr := array(16) ; afill(arr,0) ; arr[1] := alltrim(&mvar)
          if len(arr[1]) > 5
            arr[1] := left(arr[1],5)
          endif
          aadd(ad,arr) ; j := len(ad)
        endif
      elseif j > 0
        m1var := "m1"+s
        ad[j,k] := &m1var
      endif
    next
  next
  //
  arr := array(14) ; afill(arr,0) ; arr[14] := 3
  arr[1] := 1
  if (is_selo := f_is_selo())
    arr[4] := 1
  endif
  if dow(human->k_data) == 7 // суббота
    arr[3] := 1
    if is_selo
      arr[6] := 1
    endif
  endif
  for i := 1 to len(ad)
    if !(left(ad[i,1],1) == "A" .or. left(ad[i,1],1) == "B") .and. ad[i,2] > 0 // неинфекционные заболевания уст.впервые
      arr[7] ++
      if left(ad[i,1],1) == "I" // болезни системы кровообращения
        arr[8] ++
      endif
      if left(ad[i,1],1) == "C" .or. between(left(ad[i,1],3),"D00","D09") // ЗНО
        arr[9] ++
      endif
      if ad[i,3] == 2 // дисп.набл.установлено впервые
        arr[11] ++
      endif
      if ad[i,10] == 1 // 1-лечение назначено
        arr[12] ++ // ?? было начато лечение
        if is_selo
          arr[13] ++
        endif
      endif
    endif
  next
  aadd(a3,aclone(arr))
  if between(mdvozrast,15,17)
    arr[14] := 2
    j := iif(human->pol == "М", 1, 5)
    ar15[j] ++
    if ascan(ad,{|x| left(x[1],1) == "N" }) > 0 // патология органов репродуктивной системы
      ar15[j+2] ++
    endif
    if is_2
      ar15[j+3] ++
    endif
    select HU
    find (str(Loc_kod,7))
    do while hu->kod == Loc_kod .and. !eof()
      if eq_any(hu_->PROFIL,19,136)
        ar15[j+1] ++
        exit
      endif
      skip
    enddo
  else
    arr[14] := 1
  endif
  aadd(a3,aclone(arr))
endif
for j := 1 to len(a3)
  select TMP2
  find (str(a3[j,14],1))
  if !found()
    append blank
    tmp2->ti := a3[j,14]
  endif
  for i := 1 to 13
    pole := "tmp2->g"+lstr(i)
    &pole := &pole + a3[j,i]
  next
next
im := month(human->k_data)
if !between(im,1,12)
  im := 1
endif
for j := 0 to is_do1g
  select TMP1
  find (str(ii,1)+str(im,2)+str(j,1))
  if !found()
    append blank
    tmp1->ti := ii
    tmp1->mm := im
    tmp1->mm1 := j
  endif
  tmp1->vsego ++
  if mvozrast == 0
    tmp1->vsego1 ++
  endif
  tmp1->m15  += ar15[1]
  tmp1->m15a += ar15[2]
  tmp1->m15p += ar15[3]
  tmp1->m15e += ar15[4]
  tmp1->g15  += ar15[5]
  tmp1->g15g += ar15[6]
  tmp1->g15p += ar15[7]
  tmp1->g15e += ar15[8]
  if between(mgruppa,1,5)
    pole := "tmp1->g"+lstr(mgruppa)
    &pole := &pole + 1
    if between(mgruppa,4,5) .and. m1invalid1 == 1 // инвалидность-да
      pole += "inv"
      &pole := &pole + 1
    endif
    if /*ltip_school == 0 .and.*/ between(m1GR_FIZ,1,4)
      pole := "tmp1->mg"+lstr(m1GR_FIZ)
      &pole := &pole + 1
    endif
    if is_2 // I и II этап
      tmp1->v2 ++
    endif
  endif
  if human->schet > 0
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // только зарегистрированные
      tmp1->sv ++
      sumr := 0
      select RPDSH
      find (str(Loc_kod,7))
      do while rpdsh->KOD_H == Loc_kod .and. !eof()
        sumr += rpdsh->S_SL
        skip
      enddo
      if round(human->cena_1,2) == round(sumr,2) // полностью оплачен
        tmp1->so ++
      endif
    endif
  endif
next
return NIL

***** 25.03.18
Function inf_DNL_030poo(is_schet)
Local arr_m, i, n, buf := save_maxrow(), lkod_h, lkod_k, rec,;
      sh := 80, HH := 80, n_file := "f_030poo"+stxt, d1, d2
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  if arr_m[1] < 2018
    return func_error(4,"Данная форма утверждена с 2018 года")
  endif
  mywait()
  if f0_inf_DNL(arr_m,is_schet > 1,is_schet == 3)
    Private arr_deti[6] ; afill(arr_deti,0)
    Private s12_1 := 0, s12_1m := 0, s12_2 := 0, s12_2m := 0
    Private arr_vozrast := {;
      {3,0,17};
     }
    Private arr1vozrast := {;
      { 0,17},;
      { 0, 4},;
      { 0,14},;
      { 5, 9},;
      {10,14},;
      {15,17};
     }
    Private arr_4 := {;
      {"1","Некоторые инфекционные и паразит...","A00-B99",,},;
      {"1.1","туберкулез","A15-A19",,},;
      {"1.2","ВИЧ-инфекция, СПИД","B20-B24",,},;
      {"2","Новообразования","C00-D48",,},;
      {"3","Болезни крови и кроветворных органов ...","D50-D89",,},;
      {"3.1","анемии","D50-D53",,},;
      {"4","Болезни эндокринной системы, расстройства...","E00-E90",,},;
      {"4.1","сахарный диабет","E10-E14",,},;
      {"4.2","недостаточность питания","E40-E46",,},;
      {"4.3","ожирение","E66",,},;
      {"4.4","задержка полового развития","E30.0",,},;
      {"4.5","преждевременное половое развитие","E30.1",,},;
      {"5","Психические расстройства и расстро...","F00-F99",,},;
      {"5.1","умственная отсталость","F70-F79",,},;
      {"6","Болезни нервной системы, из них:","G00-G98",,},;
      {"6.1","церебральный паралич и другие ...","G80-G83",,},;
      {"7","Болезни глаза и его придаточного аппарата","H00-H59",,},;
      {"8","Болезни уха и сосцевидного отростка","H60-H95",,},;
      {"9","Болезни системы кровообращения","I00-I99",,},;
      {"10","Болезни органов дыхания, из них:","J00-J99",,},;
      {"10.1","астма, астматический статус","J45-J46",,},;
      {"11","Болезни органов пищеварения","K00-K93",,},;
      {"12","Болезни кожи и подкожной клетчатки","L00-L99",,},;
      {"13","Болезни костно-мышечной ...","M00-M99",,},;
      {"13.1","кифоз, лордоз, сколиоз","M40-M41",,},;
      {"14","Болезни мочеполовой системы, из них:","N00-N99",,},;
      {"14.1","болезни мужских половых органов","N40-N51",,},;
      {"14.2","нарушения ритма и характера менструаций","N91-N94.5",,},;
      {"14.3","воспалительные заболевания ...","N70-N77",,},;
      {"14.4","невоспалительные болезни ...","N83",,},;
      {"14.5","болезни молочной железы","N60-N64",,},;
      {"15","Отдельные состояния, возника...","P00-P96",,},;
      {"16","Врожденные аномалии (пороки ...","Q00-Q99",,},;
      {"16.1","развития нервной системы","Q00-Q07",,},;
      {"16.2","системы кровообращения","Q20-Q28",,},;
      {"16.3","женских половых органов","Q50-Q52",,},;
      {"16.4","мужских половых органов","Q53-Q55",,},;
      {"16.5","костно-мышечной системы","Q65-Q79",,},;
      {"17","Травмы, отравления и некоторые...","S00-T98",,},;
      {"18","Прочие","",,},;
      {"19","ВСЕГО ЗАБОЛЕВАНИЙ","A00-T98",,};
     }
    for n := 1 to len(arr_4)
      if "-" $ arr_4[n,3]
        d1 := token(arr_4[n,3],"-",1)
        d2 := token(arr_4[n,3],"-",2)
      else
        d1 := d2 := arr_4[n,3]
      endif
      arr_4[n,4] := diag_to_num(d1,1)
      arr_4[n,5] := diag_to_num(d2,2)
    next
    dbcreate(cur_dir+"tmp4",{{"name","C",100,0},;
                             {"diagnoz","C",20,0},;
                             {"stroke","C",4,0},;
                             {"ns","N",2,0},;
                             {"diapazon1","N",10,0},;
                             {"diapazon2","N",10,0},;
                             {"tbl","N",1,0},;
                             {"k04","N",8,0},;
                             {"k05","N",8,0},;
                             {"k06","N",8,0},;
                             {"k07","N",8,0},;
                             {"k08","N",8,0},;
                             {"k09","N",8,0},;
                             {"k10","N",8,0},;
                             {"k11","N",8,0}})
    use (cur_dir+"tmp4") new alias TMP
    for i := 1 to len(arr_vozrast)
      for n := 1 to len(arr_4)
        append blank
        tmp->tbl := arr_vozrast[i,1]
        tmp->stroke := arr_4[n,1]
        tmp->name := arr_4[n,2]
        tmp->ns := n
        tmp->diagnoz := arr_4[n,3]
        tmp->diapazon1 := arr_4[n,4]
        tmp->diapazon2 := arr_4[n,5]
      next
    next
    index on str(tbl,1)+str(ns,2) to (cur_dir+"tmp4")
    use
    dbcreate(cur_dir+"tmp10",{{"voz","N",1,0},;
                              {"tbl","N",2,0},;
                              {"tip","N",2,0},;
                              {"kol","N",6,0}})
    use (cur_dir+"tmp10") new alias TMP10
    index on str(voz,1)+str(tbl,1)+str(tip,2) to (cur_dir+"tmp10")
    use
    copy file (cur_dir+"tmp10"+sdbf) to (cur_dir+"tmp11"+sdbf)
    use (cur_dir+"tmp11") new alias TMP11
    index on str(voz,1)+str(tbl,2)+str(tip,2) to (cur_dir+"tmp11")
    use
    dbcreate(cur_dir+"tmp13",{{"voz","N",1,0},;
                              {"tip","N",2,0},;
                              {"kol","N",6,0}})
    use (cur_dir+"tmp13") new alias TMP13
    index on str(voz,1)+str(tip,2) to (cur_dir+"tmp13")
    use
    dbcreate(cur_dir+"tmp16",{{"voz","N",1,0},;
                              {"man","N",1,0},;
                              {"tip","N",2,0},;
                              {"kol","N",6,0}})
    use (cur_dir+"tmp16") new alias TMP16
    index on str(voz,1)+str(man,1)+str(tip,2) to (cur_dir+"tmp16")
    use
    dbCloseAll()
    use (cur_dir+"tmp4")  index (cur_dir+"tmp4")  new
    use (cur_dir+"tmp10") index (cur_dir+"tmp10") new
    use (cur_dir+"tmp11") index (cur_dir+"tmp11") new
    use (cur_dir+"tmp13") index (cur_dir+"tmp13") new
    use (cur_dir+"tmp16") index (cur_dir+"tmp16") new
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",,"HUMAN")
    Set Relation to recno() into HUMAN_
    R_Use(cur_dir+"tmp")
    Set Relation to kod into HUMAN
    ii := 0
    mywait(" ")
    go top
    do while !eof()
      @ maxrow(),0 say padr(str(++ii/tmp->(lastrec())*100,6,2)+"%  "+alltrim(human->fio)+"  "+full_date(human->date_r),80) color cColorWait
      f2_inf_DNL_030poo(human->kod,human->kod_k)
      select TMP
      skip
    enddo
    close databases
    //
    fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
    add_string(glob_mo[_MO_SHORT_NAME])
    add_string(padl("Приложение 3",sh))
    add_string(padl("к Приказу МЗРФ",sh))
    add_string(padl("№514н от 10.08.2017г.",sh))
    add_string("")
    add_string(padl("Форма статистической отчетности № 030-ПО/о-17",sh))
    add_string("")
    add_string(center("Сведения о профилактических медицинских осмотрах несовершеннолетних",sh))
    add_string(center("[ "+charrem("~",mas1pmt[is_schet])+" ]",sh))
    add_string(center(arr_m[4],sh))
    add_string("")
    add_string("2. Число детей, прошедших профосмотры в отчетном периоде:")
    add_string("  2.1. всего в возрасте от 0 до 17 лет включительно:"+str(arr_deti[1],6)+" (человек), из них:")
    add_string("  2.1.1. в возрасте от 0 до 4 лет включительно      "+str(arr_deti[2],6)+" (человек),")
    add_string("  2.1.2. в возрасте от 0 до 14 лет включительно     "+str(arr_deti[2]+arr_deti[3]+arr_deti[4],6)+" (человек),")
    add_string("  2.1.3. в возрасте от 5 до 9 лет включительно      "+str(arr_deti[3],6)+" (человек),")
    add_string("  2.1.4. в возрасте от 10 до 14 лет включительно    "+str(arr_deti[4],6)+" (человек),")
    add_string("  2.1.5. в возрасте от 15 до 17 лет включительно    "+str(arr_deti[5],6)+" (человек),")
    add_string("  2.1.6. детей-инвалидов от 0 до 17 лет включительно"+str(arr_deti[6],6)+" (человек).")
    for i := 1 to len(arr_vozrast)
      verify_FF(HH-50, .t., sh)
      add_string("")
      add_string(center(lstr(arr_vozrast[i,1])+;
                 ". Структура выявленных заболеваниях (состояний) у детей в возрасте от "+;
                 lstr(arr_vozrast[i,2])+" до "+lstr(arr_vozrast[i,3])+" лет включительно",sh))
      add_string("────┬───────────────────┬───────┬─────┬─────┬─────┬─────┬───────────────────────")
      add_string(" №№ │    Наименование   │ Код по│Всего│в т.ч│выяв-│в т.ч│Состоит под дисп.наблюд")
      add_string(" пп │    заболеваний    │ МКБ-10│зарег│маль-│лено │маль-├─────┬─────┬─────┬─────")
      add_string("    │                   │       │забол│чики │вперв│чики │всего│мальч│взято│мальч")
      add_string("────┼───────────────────┼───────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────")
      add_string(" 1  │          2        │   3   │  4  │  5  │  6  │  7  │  8  │  9  │ 10  │ 11  ")
      add_string("────┴───────────────────┴───────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────")
      use (cur_dir+"tmp4") index (cur_dir+"tmp4") new alias TMP
      find (str(arr_vozrast[i,1],1))
      do while tmp->tbl == arr_vozrast[i,1] .and. !eof()
        s := tmp->stroke+" "+padr(tmp->name,19)+" "+padc(alltrim(tmp->diagnoz),7)
        for n := 4 to 11
          s += put_val(tmp->&("k"+strzero(n,2)),6)
        next
        add_string(s)
        skip
      enddo
      use
      add_string(replicate("─",sh))
    next
    arr1title := {;
      "────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────",;
      "                    │   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных ",;
      "  Возраст детей     │           │           │субъекта РФ│  ных ГУЗ  │    МО     ",;
      "                    │           │           │           │           │           ",;
      "────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────",;
      "          1         │     2     │     3     │     4     │     5     │     6     ",;
      "────────────────────┴───────────┴───────────┴───────────┴───────────┴───────────"}
    arr2title := {;
      "────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────",;
      "                    │   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных ",;
      "  Возраст детей     ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────",;
      "                    │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ",;
      "────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────",;
      "          1         │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 ",;
      "────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"}
    arr3title := {;
      "────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────",;
      " Возраст│   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных │в санаторно",;
      " детей  │           │           │субъекта РФ│  ных ГУЗ  │    МО     │-курортных ",;
      "        │           │           │           │           │           │организ-ях ",;
      "────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────",;
      "    1   │     2     │     3     │     4     │     5     │     6     │     7     ",;
      "────────┴───────────┴───────────┴───────────┴───────────┴───────────┴───────────"}
    arr4title := {;
      "────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────",;
      " Возраст│   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных │в сан.-кур.",;
      " детей  ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────┼──орг-иях──",;
      "        │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ",;
      "────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────",;
      "    1   │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 ",;
      "────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"}
    verify_FF(HH-50, .t., sh)
    add_string("4. Результаты дополнительных консультаций, исследований, лечения, медицинской")
    add_string("   реабилитации детей по результатам проведения профилактических осмотров:")
    use (cur_dir+"tmp10") index (cur_dir+"tmp10") new alias TMP10
    for i := 1 to 2
      verify_FF(HH-16, .t., sh)
      add_string("")
      s := space(5)
      if i == 1
        add_string(s+"4.1. Дополнительные консультации и (или) исследования")
      else
        add_string(s+"4.2. Лечение, медицинская реабилитация и санаторно-курортное лечение")
      endif
      n := 20
      if eq_any(i,1,3,5,6,7)
        aeval(arr1title, {|x| add_string(x) } )
      elseif eq_any(i,2,4)
        aeval(arr2title, {|x| add_string(x) } )
      else
        aeval(arr3title, {|x| add_string(x) } )
        n := 8
      endif
      for j := 1 to len(arr1vozrast)
        s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
        skol := oldkol := 0
        s1 := ""
        for k := 1 to iif(i==8,5,4)
          find (str(j,1)+str(i,1)+str(k,1))
          if found() .and. (v := tmp10->kol) > 0
            skol += v
            if eq_any(i,2,4)
              s1 += str(v,6)
              find (str(j,1)+str(i-1,1)+str(k,1))
              if found() .and. tmp10->kol > 0
                s1 += " "+umest_val(v/tmp10->kol*100,5,2)
                oldkol += tmp10->kol
              else
                s1 += space(6)
              endif
            else
              s1 += " "+padc(lstr(v),11)
            endif
          else
            s1 += space(12)
          endif
        next
        if skol > 0
          if eq_any(i,2,4)
            s += str(skol,6)+" "+umest_val(skol/oldkol*100,5,2)
          else
            s += " "+padc(lstr(skol),11)
          endif
          add_string(s+s1)
        else
          add_string(s)
        endif
      next
      add_string(replicate("─",sh))
    next
    use
    //
    //verify_FF(HH-50, .t., sh)
    //add_string("11. Результаты лечения, медицинской реабилитации и (или) санаторно-курортного")
    //add_string("    лечения детей до проведения настоящего профилактического осмотра:")
    vkol := 0
    use (cur_dir+"tmp11") index (cur_dir+"tmp11") new alias TMP11
    for i := 1 to 0//12
      if i % 3 > 0
        verify_FF(HH-16, .t., sh)
        add_string("")
      endif
      s := space(5)
      if i == 1
        add_string(s+"11.1. Рекомендовано лечение в амбулаторных условиях и в условиях")
        add_string(s+"      дневного стационара")
      elseif i == 2
        add_string(s+"11.2. Проведено лечение в амбулаторных условиях и в условиях")
        add_string(s+"      дневного стационара")
      elseif i == 3
        add_string(s+"11.3. Причины невыполнения рекомендаций по лечению в амбулаторных условиях")
        add_string(s+"      и в условиях дневного стационара:")
        add_string(s+"        11.3.1. не прошли всего "+lstr(vkol)+" (человек)")
      elseif i == 4
        add_string(s+"11.4. Рекомендовано лечение в стационарных условиях")
      elseif i == 5
        add_string(s+"11.5. Проведено лечение в стационарных условиях")
      elseif i == 6
        add_string(s+"11.6. Причины невыполнения рекомендаций по лечению в стационарных условиях:")
        add_string(s+"        11.6.1. не прошли всего "+lstr(vkol)+" (человек)")
      elseif i == 7
        add_string(s+"11.7. Рекомендована медицинская реабилитация")
        add_string(s+"      в амбулаторных условиях и в условиях дневного стационара")
      elseif i == 8
        add_string(s+"11.8. Проведена медицинская реабилитация")
        add_string(s+"      в амбулаторных условиях и в условиях дневного стационара")
      elseif i == 9
        add_string(s+"11.9. Причины невыполнения рекомендаций по медицинской реабилитации")
        add_string(s+"      в амбулаторных условиях и в условиях дневного стационара:")
        add_string(s+"        11.9.1. не прошли всего "+lstr(vkol)+" (человек)")
      elseif i == 10
        add_string(s+"11.10. Рекомендованы медицинская реабилитация и (или)")
        add_string(s+"       санаторно-курортное лечение в стационарных условиях")
      elseif i == 11
        add_string(s+"11.11. Проведена медицинская реабилитация и (или)")
        add_string(s+"       санаторно-курортное лечение в стационарных условиях")
      else
        add_string(s+"11.12. Причины невыполнения рекомендаций по медицинской реабилитации")
        add_string(s+"       и (или) санаторно-курортному лечению в стационарных условиях:")
        add_string(s+"         11.12.1. не прошли всего "+lstr(vkol)+" (человек)")
      endif
      if i % 3 > 0
        n := 20
        if eq_any(i,1,4,7)
          aeval(arr1title, {|x| add_string(x) } )
        elseif eq_any(i,2,5,8)
          aeval(arr2title, {|x| add_string(x) } )
        elseif i == 10
          aeval(arr3title, {|x| add_string(x) } )
          n := 8
        elseif i == 11
          aeval(arr4title, {|x| add_string(x) } )
          n := 8
        endif
        for j := 1 to len(arr1vozrast)
          s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
          skol := oldkol := 0
          s1 := ""
          for k := 1 to iif(i>10,5,4)
            find (str(j,1)+str(i,2)+str(k,1))
            if found() .and. (v := tmp11->kol) > 0
              skol += v
              if eq_any(i,2,5,8,11)
                s1 += str(v,6)
                find (str(j,1)+str(i-1,2)+str(k,1))
                if found() .and. tmp11->kol > 0
                  s1 += " "+umest_val(v/tmp11->kol*100,5,2)
                  oldkol += tmp11->kol
                else
                  s1 += space(6)
                endif
              else
                s1 += " "+padc(lstr(v),11)
              endif
            else
              s1 += space(12)
            endif
          next
          if eq_any(i,2,5,8,11)
            vkol := oldkol - skol
          endif
          if skol > 0
            if eq_any(i,2,5,8,11)
              s += str(skol,6)+" "+umest_val(skol/oldkol*100,5,2)
            else
              s += " "+padc(lstr(skol),11)
            endif
            add_string(s+s1)
          else
            add_string(s)
          endif
        next
        add_string(replicate("─",sh))
      endif
    next
    use
    use (cur_dir+"tmp16") index (cur_dir+"tmp16") new alias TMP16
    verify_FF(HH-21, .t., sh)
    n := 20
    add_string("")
    add_string("5. Число детей по уровню физического развития")
    add_string("────────────────────┬─────────┬─────────┬───────────────────────────────────────")
    add_string("                    │Число про│Норм.физ.│ Нарушения физического развития (чел.) ")
    add_string("    Возраст детей   │шедших   │развитие ├─────────┬─────────┬─────────┬─────────")
    add_string("                    │проф.осм.│   чел.  │дефиц.мас│избыт.мас│низк.рост│высо.рост")
    add_string("────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────")
    add_string("          1         │    2    │    3    │    4    │    5    │    6    │    7    ")
    add_string("────────────────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────")
    for j := 1 to len(arr1vozrast)
      for k := 0 to 1
        s := padr(" "+lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2])+;
                  iif(k==0,""," (мальчики)"),n)
        find (str(j,1)+str(k,1)+str(0,2))
        if found()
          s += " "+padc(lstr(tmp16->kol),9)
        else
          s += space(10)
        endif
        for i := 1 to 5
          find (str(j,1)+str(k,1)+str(i,2))
          if found()
            s += " "+padc(lstr(tmp16->kol),9)
          else
            s += space(10)
          endif
        next
        add_string(s)
      next
    next
    add_string(replicate("─",sh))
    verify_FF(HH-21, .t., sh)
    n := 20
    add_string("")
    add_string("6. Число детей по медицинским группам для занятий физической культурой")
    add_string("────────────────────┬─────────┬────────────────────────┬────────────────────────")
    add_string("                    │Число про│    до проф.осмотра     │ по результатам проф.осм")
    add_string("    Возраст детей   │шедших   ├────┬────┬────┬────┬────┼────┬────┬────┬────┬────")
    add_string("                    │проф.осм.│ I  │ II │ III│ IV │не д│ I  │ II │ III│ IV │не д")
    add_string("────────────────────┼─────────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────")
    add_string("          1         │    2    │ 3  │ 4  │ 5  │ 6  │ 7  │ 8  │ 9  │ 10 │ 11 │ 12 ")
    add_string("────────────────────┴─────────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────")
    for j := 1 to len(arr1vozrast)
      for k := 0 to 1
        s := padr(" "+lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2])+;
                  iif(k==0,""," (мальчики)"),n)
        find (str(j,1)+str(k,1)+str(0,2))
        if found()
          s += " "+padc(lstr(tmp16->kol),9)
        else
          s += space(10)
        endif
        for i := 31 to 35
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        for i := 41 to 45
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        add_string(s)
      next
    next
    verify_FF(HH-21, .t., sh)
    n := 20
    add_string("")
    add_string("7. Число детей по группам здоровья")
    add_string("────────────────────┬─────────┬────────────────────────┬────────────────────────")
    add_string("                    │Число про│    до проф.осмотра     │ по результатам проф.осм")
    add_string("    Возраст детей   │шедших   ├────┬────┬────┬────┬────┼────┬────┬────┬────┬────")
    add_string("                    │проф.осм.│ I  │ II │ III│ IV │ V  │ I  │ II │ III│ IV │ V  ")
    add_string("────────────────────┼─────────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────")
    add_string("          1         │    2    │ 3  │ 4  │ 5  │ 6  │ 7  │ 8  │ 9  │ 10 │ 11 │ 12 ")
    add_string("────────────────────┴─────────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────")
    for j := 1 to len(arr1vozrast)
      for k := 0 to 1
        s := padr(" "+lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2])+;
                  iif(k==0,""," (мальчики)"),n)
        find (str(j,1)+str(k,1)+str(0,2))
        if found()
          s += " "+padc(lstr(tmp16->kol),9)
        else
          s += space(10)
        endif
        for i := 11 to 15
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        for i := 21 to 25
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        add_string(s)
      next
    next
    add_string(replicate("─",sh))
    fclose(fp)
    viewtext(n_file,,,,.t.,,,5)
  endif
endif
close databases
rest_box(buf)
return NIL

***** 14.07.19
Function f2_inf_DNL_030poo(Loc_kod,kod_kartotek) // сводная информация
Local i, j, k, av := {}, av1 := {}, ad := {}, arr, s, fl, ;
      is_man := (human->pol == "М"), blk_tbl, blk_tip, blk_put_tip, a10[9], a11[13]
blk_tbl := {|_k| iif(_k < 2, 1, 2) }
blk_tip := {|_k| iif(_k == 0, 2, iif(_k > 1, _k+1, _k)) }
blk_put_tip := {|_e,_k| iif(_k > _e, _k, _e) }
Private metap := 1, mperiod := 0, mshifr_zs := "", m1lis := 0,;
        mkateg_uch, m1kateg_uch := 3,; // Категория учета ребенка:
        mMO_PR := space(10), m1MO_PR := space(6),; // код МО прикрепления
        mschool := space(10), m1school := 0,; // код обр.учреждения
        mWEIGHT := 0,;   // вес в кг
        mHEIGHT := 0,;   // рост в см
        mPER_HEAD := 0,; // окружность головы в см
        mfiz_razv, m1FIZ_RAZV := 0,; // физическое развитие
        mfiz_razv1, m1FIZ_RAZV1 := 0,; // отклонение массы тела
        mfiz_razv2, m1FIZ_RAZV2 := 0,; // отклонение роста
        m1psih11 := 0,;  // познавательная функция (возраст развития)
        m1psih12 := 0,;  // моторная функция (возраст развития)
        m1psih13 := 0,;  // эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития)
        m1psih14 := 0,;  // предречевое и речевое развитие (возраст развития)
        mpsih21, m1psih21 := 0,;  // Психомоторная сфера: (норма, отклонение)
        mpsih22, m1psih22 := 0,;  // Интеллект: (норма, отклонение)
        mpsih23, m1psih23 := 0,;  // Эмоционально-вегетативная сфера: (норма, отклонение)
        m141p   := 0,; // Половая формула мальчика P
        m141ax  := 0,; // Половая формула мальчика Ax
        m141fa  := 0,; // Половая формула мальчика Fa
        m142p   := 0,; // Половая формула девочки P
        m142ax  := 0,; // Половая формула девочки Ax
        m142ma  := 0,; // Половая формула девочки Ma
        m142me  := 0,; // Половая формула девочки Me
        m142me1 := 0,; // Половая формула девочки - menarhe (лет)
        m142me2 := 0,; // Половая формула девочки - menarhe (месяцев)
        m142me3, m1142me3 := 0,; // Половая формула девочки - menses (характеристика):
        m142me4, m1142me4 := 1,; // Половая формула девочки - menses (характеристика):
        m142me5, m1142me5 := 1,; // Половая формула девочки - menses (характеристика):
        mdiag_15_1, m1diag_15_1 := 1,; // Состояние здоровья до проведения профосмотра-Практически здоров
        mdiag_15[5,14],; //
        mGRUPPA_DO := 0,; // группа здоровья до дисп-ии
        mGR_FIZ_DO, m1GR_FIZ_DO := 1,;
        mdiag_16_1, m1diag_16_1 := 1,; // Состояние здоровья по результатам проведения профосмотра (Практически здоров)
        mdiag_16[5,16],; //
        minvalid[8],;  // раздел 16.7
        mGRUPPA := 0,;    // группа здоровья после дисп-ии
        mGR_FIZ, m1GR_FIZ := 1,;
        mPRIVIVKI[3],; // Проведение профилактических прививок
        mrek_form := space(255),; // "C100",Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой
        mrek_disp := space(255),; // "C100",Рекомендации по диспансерному наблюдению, лечению, медицинской реабилитации и санаторно-курортному лечению с указанием диагноза (код МКБ), вида медицинской организации и специальности (должности) врача
        mhormon := "0 шт.", m1hormon := 1, not_hormon,;
        mstep2, m1step2 := 0
Private minvalid1, m1invalid1 := 0,;
        minvalid2, m1invalid2 := 0,;
        minvalid3 := ctod(""), minvalid4 := ctod(""),;
        minvalid5, m1invalid5 := 0,;
        minvalid6, m1invalid6 := 0,;
        minvalid7 := ctod(""),;
        minvalid8, m1invalid8 := 0
Private mprivivki1, m1privivki1 := 0,;
        mprivivki2, m1privivki2 := 0,;
        mprivivki3 := space(100)
Private mvar, m1var, m1lis := 0
//
for i := 1 to 5
  for k := 1 to 14
    s := "diag_15_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      Private &mvar := space(6)
    else
      m1var := "m1"+s
      Private &m1var := 0
      Private &mvar := space(4)
    endif
  next
next
//
for i := 1 to 5
  for k := 1 to 16
    s := "diag_16_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      Private &mvar := space(6)
    else
      m1var := "m1"+s
      Private &m1var := 0
      Private &mvar := space(3)
    endif
  next
next
mvozrast := count_years(human->date_r,human->n_data)
if !between(mvozrast,0,17)
  mvozrast := 17
endif
mdvozrast := year(human->n_data) - year(human->date_r)
if !between(mdvozrast,0,17)
  mdvozrast := 17
endif
read_arr_PN(Loc_kod)
arr_deti[1] ++
if mdvozrast < 5
  arr_deti[2] ++
elseif mdvozrast < 10
  arr_deti[3] ++
elseif mdvozrast < 15
  arr_deti[4] ++
else
  arr_deti[5] ++
endif
for i := 1 to len(arr_vozrast)
  if between(mdvozrast,arr_vozrast[i,2],arr_vozrast[i,3])
    aadd(av,arr_vozrast[i,1]) // список таблиц с 4 по 9
  endif
next
for i := 1 to len(arr1vozrast)
  if between(mdvozrast,arr1vozrast[i,1],arr1vozrast[i,2])
    aadd(av1,i)
  endif
next
for i := 1 to 5
  j := 0
  for k := 1 to 16
    s := "diag_16_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      if !empty(&mvar)
        arr := array(16) ; afill(arr,0) ; arr[1] := alltrim(&mvar)
        if len(arr[1]) > 5
          arr[1] := left(arr[1],5)
        endif
        aadd(ad,arr) ; j := len(ad)
      endif
    elseif j > 0
      m1var := "m1"+s
      ad[j,k] := &m1var
    endif
  next
next
afill(a10,0)
for i := 1 to len(ad) // цикл по диагнозам
  au := {}
  d := diag_to_num(ad[i,1],1)
  for n := 1 to len(arr_4)
    if !empty(arr_4[n,3]) .and. between(d,arr_4[n,4],arr_4[n,5])
      aadd(au,n)
    endif
  next
  if len(au) == 1
    aadd(au,len(arr_4)-1)  // {"18","Прочие","",,},;
  endif
  select TMP4
  for n := 1 to len(av) // цикл по списку таблиц с 4 по 9
    for j := 1 to len(au)
      find (str(av[n],1)+str(au[j],2))
      if found()
        tmp4->k04 ++
        if is_man
          tmp4->k05 ++
        endif
        if ad[i,2] > 0 // уст.впервые
          tmp4->k06 ++
          if is_man
            tmp4->k07 ++
          endif
        endif
        if ad[i,3] > 0 // дисп.набл.установлено
          tmp4->k08 ++
          if is_man
            tmp4->k09 ++
          endif
          if ad[i,3] == 2 // дисп.набл.установлено впервые
            tmp4->k10 ++
            if is_man
              tmp4->k11 ++
            endif
          endif
        endif
      endif
    next
  next
  if ad[i,4] == 1 // 1-доп.конс.назначены
    ntbl := eval(blk_tbl,ad[i,5])
    ntip := eval(blk_tip,ad[i,6])
    if ntbl == 1 .and. a10[3] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a10[1] := 0
      a10[3] := eval(blk_put_tip,a10[3],ntip)
    else
      a10[1] := eval(blk_put_tip,a10[1],ntip)
      a10[3] := 0
    endif
  endif
  if ad[i,7] == 1 // 1-доп.конс.выполнены
    ntbl := eval(blk_tbl,ad[i,8])
    ntip := eval(blk_tip,ad[i,9])
    if ntbl == 1 .and. a10[4] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a10[2] := 0
      a10[4] := eval(blk_put_tip,a10[4],ntip)
    else
      a10[2] := eval(blk_put_tip,a10[2],ntip)
      a10[4] := 0
    endif
  endif
  if ad[i,10] == 1 // 1-лечение назначено
    ntbl := eval(blk_tbl,ad[i,11])
    ntip := eval(blk_tip,ad[i,12])
    if ntbl == 1 .and. a10[6] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a10[5] := 0
      a10[6] := eval(blk_put_tip,a10[6],ntip)
    else
      a10[5] := eval(blk_put_tip,a10[5],ntip)
      a10[6] := 0
    endif
  endif
  if ad[i,13] == 1 // 1-реабил.назначена
    ntbl := eval(blk_tbl,ad[i,14])
    ntip := eval(blk_tip,ad[i,15])
    if ntbl == 1 .and. a10[8] > 0 // уже есть стационар
      //
    elseif ntbl == 2 .or. ntip == 5 // или санаторий
      a10[7] := 0
      a10[8] := eval(blk_put_tip,a10[8],ntip)
    else
      a10[7] := eval(blk_put_tip,a10[7],ntip)
      a10[8] := 0
    endif
  endif
  if ad[i,16] == 1 // 1-ВМП назначена
    a10[9] := 1
  endif
next
select TMP10
for n := 1 to len(av1) // цикл по возрастам таблиц 10
  for j := 1 to len(a10)-1
    if a10[j] > 0
      find (str(av1[n],1)+str(j,1)+str(a10[j],2))
      if !found()
        append blank
        tmp10->voz := av1[n]
        tmp10->tbl := j
        tmp10->tip := a10[j]
      endif
      tmp10->kol ++
    endif
  next
next
ad := {}
for i := 1 to 5
  j := 0
  for k := 1 to 14
    s := "diag_15_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      if !empty(&mvar)
        arr := array(14) ; afill(arr,0) ; arr[1] := alltrim(&mvar)
        if len(arr[1]) > 5
          arr[1] := left(arr[1],5)
        endif
        aadd(ad,arr) ; j := len(ad)
      endif
    elseif j > 0
      m1var := "m1"+s
      ad[j,k] := &m1var
    endif
  next
next
afill(a11,0)
for i := 1 to len(ad) // цикл по диагнозам
  if ad[i,3] == 1 // 1-лечение назначено
    ntbl := eval(blk_tbl,ad[i,4])
    ntip := eval(blk_tip,ad[i,5])
    if ntbl == 1 .and. a11[4] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a11[1] := 0
      a11[4] := eval(blk_put_tip,a11[4],ntip)
    else
      a11[1] := eval(blk_put_tip,a11[1],ntip)
      a11[4] := 0
    endif
    // лечение выполнено
    ntbl := eval(blk_tbl,ad[i,6])
    ntip := eval(blk_tip,ad[i,7])
    if ntbl == 1 .and. a11[5] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a11[2] := 0
      a11[5] := eval(blk_put_tip,a11[5],ntip)
    else
      a11[2] := eval(blk_put_tip,a11[2],ntip)
      a11[5] := 0
    endif
  endif
  if ad[i,8] == 1 // 1-реабил.назначена
    ntbl := eval(blk_tbl,ad[i,9])
    ntip := eval(blk_tip,ad[i,10])
    if ntbl == 1 .and. a11[10] > 0 // уже есть стационар
      //
    elseif ntbl == 2
      a11[ 7] := 0
      a11[10] := eval(blk_put_tip,a11[10],ntip)
    else
      a11[ 7] := eval(blk_put_tip,a11[7],ntip)
      a11[10] := 0
    endif
    // 1-реабил.выполнена
    ntbl := eval(blk_tbl,ad[i,11])
    ntip := eval(blk_tip,ad[i,12])
    if ntbl == 1 .and. a11[11] > 0 // уже есть стационар
      //
    elseif ntbl == 2 .or. ntip == 5 // или санаторий
      a11[ 8] := 0
      a11[11] := eval(blk_put_tip,a11[11],ntip)
    else
      a11[ 8] := eval(blk_put_tip,a11[8],ntip)
      a11[11] := 0
    endif
  endif
  if ad[i,14] == 1 // 1-ВМП проведена
    a11[13] := 1
  endif
next
select TMP11
for n := 1 to len(av1) // цикл по возрастам таблиц 10
  for j := 1 to len(a11)-1
    if a11[j] > 0
      find (str(av1[n],1)+str(j,2)+str(a11[j],2))
      if !found()
        append blank
        tmp11->voz := av1[n]
        tmp11->tbl := j
        tmp11->tip := a11[j]
      endif
      tmp11->kol ++
    endif
  next
next
if a10[9] > 0
  s12_1++
  if is_man
    s12_1m++
  endif
endif
if a11[13] > 0
  s12_2++
  if is_man
    s12_2m++
  endif
endif
ad := {0}
if m1invalid1 == 1 // инвалидность-да
  arr_deti[6] ++
  aadd(ad,4)
  if m1invalid2 == 0 // с рождения
    aadd(ad,1)
  else               // приобретенная
    aadd(ad,2)
    if !empty(minvalid3) .and. minvalid3 >= human->n_data
      aadd(ad,3)
    endif
  endif
  if !empty(minvalid7) // Дата назначения инд.программы реабилитации
    aadd(ad,10)
    do case // выполнение
      case m1invalid8 == 1 // полностью,1
        aadd(ad,11)
      case m1invalid8 == 2 // частично,2
        aadd(ad,12)
      case m1invalid8 == 3 // начата,3
        aadd(ad,13)
      otherwise            // не выполнена,0
        aadd(ad,14)
    endcase
  endif
endif
if m1privivki1 == 1     // не привит по медицинским показаниям",1},;
  if m1privivki2 == 1
    aadd(ad,21)
  else
    aadd(ad,22)
  endif
elseif m1privivki1 == 2 // не привит по другим причинам",2}}
  if m1privivki2 == 1
    aadd(ad,23)
  else
    aadd(ad,24)
  endif
else                    // привит по возрасту",0},;
  aadd(ad,20)
endif
select TMP13
for n := 1 to len(av1) // цикл по возрастам таблицы
  for j := 1 to len(ad)
    find (str(av1[n],1)+str(ad[j],2))
    if !found()
      append blank
      tmp13->voz := av1[n]
      tmp13->tip := ad[j]
    endif
    tmp13->kol ++
  next
next
ad := {0}
if m1fiz_razv == 0
  aadd(ad,1)
else
  if m1fiz_razv1 == 1
    aadd(ad,2)
  elseif m1fiz_razv1 == 2
    aadd(ad,3)
  endif
  if m1fiz_razv2 == 1
    aadd(ad,4)
  elseif m1fiz_razv2 == 2
    aadd(ad,5)
  endif
endif
mGRUPPA := human_->RSLT_NEW - 331 //L_BEGIN_RSLT
if !between(mgruppa,1,5)
  mgruppa := 1
endif
if !between(mgruppa_do,1,5)
  mgruppa_do := 1
endif
if !between(m1GR_FIZ,0,4)
  m1GR_FIZ := 1
endif
if !between(m1GR_FIZ_DO,0,4)
  m1GR_FIZ_DO := 1
endif
aadd(ad,mGRUPPA_DO+10)
aadd(ad,mGRUPPA+20)
aadd(ad,iif(m1GR_FIZ_DO==0, 35, m1GR_FIZ_DO+30))
aadd(ad,iif(m1GR_FIZ==0, 45, m1GR_FIZ+40))
select TMP16
for n := 1 to len(av1) // цикл по возрастам таблицы
  for j := 1 to len(ad)
    find (str(av1[n],1)+"0"+str(ad[j],2))
    if !found()
      append blank
      tmp16->voz := av1[n]
      tmp16->tip := ad[j]
    endif
    tmp16->kol ++
    if is_man
      find (str(av1[n],1)+"1"+str(ad[j],2))
      if !found()
        append blank
        tmp16->voz := av1[n]
        tmp16->man := 1
        tmp16->tip := ad[j]
      endif
      tmp16->kol ++
    endif
  next
next
return NIL

*

***** 11.03.19
Function inf_DNL_XMLfile(is_schet,stitle)
Local arr_m, n, buf := save_maxrow(), lkod_h, lkod_k, rec, blk, t_arr[BR_LEN], arr, n_func
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  do case
    case p_tip_lu == TIP_LU_PN
      arr := {301,302} // профилактика 1 и 2 этап
    case p_tip_lu == TIP_LU_PREDN
      arr := {303,304} // пред.осмотры 1 и 2 этап
    case p_tip_lu == TIP_LU_PERN
      arr := {305} // период.осмотры
  endcase
  if f0_inf_DNL(arr_m,is_schet > 1,is_schet == 3,arr,.t.)
    copy file (cur_dir+"tmp"+sdbf) to (cur_dir+"tmpDNL"+sdbf) // т.к. внутри тоже есть TMP-файл
    R_Use(dir_server+"human",,"HUMAN")
    use (cur_dir+"tmpDNL") new
    set relation to kod into HUMAN
    index on upper(human->fio) to (cur_dir+"tmpDNL")
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            E_Use(cur_dir+"tmpDNL",cur_dir+"tmpDNL","TMP"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    eval(blk_open)
    go top
    t_arr[BR_TOP] := T_ROW
    t_arr[BR_BOTTOM] := 23
    t_arr[BR_LEFT] := 0
    t_arr[BR_RIGHT] := 79
    stitle += " несовершеннолетних "
    t_arr[BR_TITUL] := stitle+arr_m[4]
    t_arr[BR_TITUL_COLOR] := "B/BG"
    t_arr[BR_COLOR] := color0
    t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
    blk := {|| iif(tmp->is==1, {1,2}, {3,4}) }
    t_arr[BR_COLUMN] := {{" ", {|| iif(tmp->is==1,""," ") }, blk },;
                         {" Ф.И.О.", {|| padr(human->fio,37) }, blk },;
                         {"Дата рожд.", {|| full_date(human->date_r) }, blk },;
                         {"№ ам.карты", {|| human->uch_doc }, blk },;
                         {"Сроки леч-я", {|| left(date_8(human->n_data),5)+"-"+left(date_8(human->k_data),5) }, blk },;
                         {"Этап", {|| iif(eq_any(human->ishod,301,303,305)," I  ","I-II") }, blk }}
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход для создания файла;  ^<+,-,Ins>^ - отметить/снять отметку с пациента") }
    t_arr[BR_EDIT] := {|nk,ob| f1_inf_N_XMLfile(nk,ob,"edit") }
    edit_browse(t_arr)
    select TMP
    delete for is == 0
    pack
    n := lastrec()
    close databases
    rest_box(buf)
    if n == 0 .or. !f_Esc_Enter("составления XML-файла")
      return NIL
    endif
    mywait()
    R_Use(dir_server+"mo_rpdsh",,"RPDSH")
    index on str(KOD_H,7) to (cur_dir+"tmprpdsh")
    Use
    R_Use(dir_server+"mo_raksh",,"RAKSH")
    index on str(KOD_H,7) to (cur_dir+"tmpraksh")
    Use
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            E_Use(cur_dir+"tmpDNL",cur_dir+"tmpDNL","TMP"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    mo_mzxml_N(1)
    n := 0
    do while .t.
      ++n
      eval(blk_open)
      if rec == NIL
        go top
      else
        goto (rec)
        skip
        if eof()
          exit
        endif
      endif
      rec := tmp->(recno())
      @ maxrow(),0 say padr(str(n/tmp->(lastrec())*100,6,2)+"%"+" "+;
                            rtrim(human->fio)+" "+date_8(human->n_data)+"-"+;
                            date_8(human->k_data),80) color cColorWait
      lkod_h := human->kod
      lkod_k := human->kod_k
      close databases
      n_func := "f2_inf_N_XMLfile"
      do case
        case p_tip_lu == TIP_LU_PN
          oms_sluch_PN(lkod_h,lkod_k,n_func) // профилактика 1 и 2 этап
        case p_tip_lu == TIP_LU_PREDN
          oms_sluch_PREDN(lkod_h,lkod_k,n_func) // пред.осмотры 1 и 2 этап
        case p_tip_lu == TIP_LU_PERN
          oms_sluch_PerN(lkod_h,lkod_k,n_func) // период.осмотры
      endcase
    enddo
    close databases
    rest_box(buf)
    mo_mzxml_N(3,"tmp",stitle)
  endif
endif
close databases
rest_box(buf)
return NIL

*

***** 22.11.13
Function f1_inf_N_XMLfile(nKey,oBrow,regim)
Local ret := -1, rec := tmp->(recno())
if regim == "edit"
  do case
    case nkey == K_INS
      tmp->is := iif(tmp->is==1, 0, 1)
      ret := 0
      keyboard chr(K_TAB)
    case nkey == 43  // +
      tmp->(dbeval({|| tmp->is := 1 }))
      goto (rec)
      ret := 0
    case nkey == 45  //  -
      tmp->(dbeval({|| tmp->is := 0 }))
      goto (rec)
      ret := 0
  endcase
endif
return ret

*

***** 22.11.13 по листу учёта несовершеннолетнего создать часть XML-файла
Function f2_inf_N_XMLfile(Loc_kod,kod_kartotek,lvozrast)
Local adbf, s, i, j, k, y, m, d, fl
R_Use(dir_server+"kartote_",,"KART_")
goto (kod_kartotek)
R_Use(dir_server+"kartotek",,"KART")
goto (kod_kartotek)
R_Use(dir_server+"human_",,"HUMAN_")
goto (Loc_kod)
R_Use(dir_server+"human",,"HUMAN")
goto (Loc_kod)
R_Use(dir_server+"mo_pers",,"P2")
goto (m1vrach)
R_Use(dir_server+"organiz",,"ORG")
R_Use(dir_server+"mo_rpdsh",cur_dir+"tmprpdsh","RPDSH")
R_Use(dir_server+"mo_raksh",cur_dir+"tmpraksh","RAKSH")
mo_mzxml_N(2,,,lvozrast)
return NIL

*

***** 25.11.13
Function f4_inf_PREDN_karta(par,_etap)
Local i, k, fl, arr := {}, ar := npred_arr_1_etap[mperiod]
if par == 1
  if iif(_etap==nil, .t., _etap==1)
    for i := 1 to count_predn_arr_osm
      mvart := "MTAB_NOMov"+lstr(i)
      mvard := "MDATEo"+lstr(i)
      fl := .t.
      if fl .and. !empty(npred_arr_osmotr[i,2])
        fl := (mpol == npred_arr_osmotr[i,2])
      endif
      if fl
        fl := (!empty(ar[4]) .and. ascan(ar[4],npred_arr_osmotr[i,1]) > 0)
      endif
      if fl .and. !emptyany(&mvard,&mvart)
        aadd(arr, {npred_arr_osmotr[i,3], &mvard, "", i, f5_inf_DNL_karta(i)})
      endif
    next
  endif
  aadd(arr, {"педиатр (врач общей практики)", MDATEp1, "", -1, 1})
  if metap == 2 .and. iif(_etap==nil, .t., _etap==2)
    for i := 1 to count_predn_arr_osm
      mvart := "MTAB_NOMov"+lstr(i)
      mvard := "MDATEo"+lstr(i)
      fl := .t.
      if fl .and. !empty(npred_arr_osmotr[i,2])
        fl := (mpol == npred_arr_osmotr[i,2])
      endif
      if fl
        fl := (ascan(ar[4],npred_arr_osmotr[i,1]) == 0)
      endif
      if fl .and. !emptyany(&mvard,&mvart)
        aadd(arr, {npred_arr_osmotr[i,3], &mvard, "", i, f5_inf_DNL_karta(i)})
      endif
    next
    aadd(arr, {"педиатр (врач общей практики)", MDATEp2, "", -2, 1})
  endif
else
  for i := 1 to count_predn_arr_iss // исследования
    mvart := "MTAB_NOMiv"+lstr(i)
    mvard := "MDATEi"+lstr(i)
    mvarr := "MREZi"+lstr(i)
    fl := .t.
    if fl .and. !empty(npred_arr_issled[i,2])
      fl := (mpol == npred_arr_issled[i,2])
    endif
    if fl
      fl := (ascan(ar[5],npred_arr_issled[i,1]) > 0)
    endif
    if fl .and. !emptyany(&mvard,&mvart)
      k := 0
      do case
        case i ==  1 // {"4.2.153" ,   , "Общий анализ мочи",0,34,{1107,1301,1402,1702} },;
          k := 2
        case i ==  2 // {"4.11.136",   , "Клинический анализ крови",0,34,{1107,1301,1402,1702} },;
          k := 1
        case i ==  3 // {"4.12.169",   , "Исследование уровня глюкозы в крови",0,34,{1107,1301,1402,1702} },;
          k := 4
        case i ==  4 // {"4.8.12"  ,   , "Анализ кала на яйца глистов",0,34,{1107,1301,1402,1702} },;
          k := 16
        case i ==  5 // {"7.61.3"  ,   , "Флюорография легких в 1-й проекции",0,78,{1118,1802} },;
          k := 12
        case i ==  6 // {"8.1.2"   ,   , "УЗИ щитовидной железы",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 8
        case i ==  7 // {"8.1.3"   ,   , "УЗИ сердца",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 7
        case i ==  8 // {"8.2.1"   ,   , "УЗИ органов брюшной полости",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 6
        case i ==  9 // {"8.2.2"   ,"М", "УЗИ органов репродуктивной системы",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 9
        case i == 10 // {"8.2.3"   ,"Ж", "УЗИ органов репродуктивной системы",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 9
        case i == 11 // {"13.1.1"  ,   , "Электрокардиография",0,111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202} },;
          k := 13
      endcase
      aadd(arr, {npred_arr_issled[i,3], &mvard, &mvarr, i, k})
    endif
  next
endif
return arr

*

***** 25.11.13
Function f4_inf_PerN_karta(par)
Local i, k, fl, arr := {}, ar := nper_arr_1_etap[mperiod]
if par == 1
  aadd(arr, {"педиатр (врач общей практики)", MDATEp1, "", -1, 1})
else
  for i := 1 to count_Pern_arr_iss // исследования
    mvart := "MTAB_NOMiv"+lstr(i)
    mvard := "MDATEi"+lstr(i)
    mvarr := "MREZi"+lstr(i)
    fl := (ascan(ar[5],nPer_arr_issled[i,1]) > 0)
    if fl .and. !emptyany(&mvard,&mvart)
      k := 0
      do case
        case i ==  1 // {"4.2.153" ,   , "Общий анализ мочи",0,34,{1107,1301,1402,1702} },;
          k := 2
        case i ==  1 // {"4.11.136",   , "Клинический анализ крови",0,34,{1107,1301,1402,1702} },;
          k := 1
        case i ==  1 // {"16.1.16" ,   , "Анализ окиси углерода выдыхаем.воздуха",0,34,{1107,1301,1402,1702} };
          k := 17
      endcase
      aadd(arr, {nPer_arr_issled[i,3], &mvard, &mvarr, i, k})
    endif
  next
endif
return arr

*

***** 31.10.16 Запрос несовершеннолетних, подлежащих медосмотрам, методом многовариантного поиска
Function mnog_poisk_DNL()
Local mm_tmp := {}, mm_sort
Local buf := savescreen(), tmp_color := setcolor(cDataCGet),;
      tmp_help := help_code, hGauge, name_file := "_kartDNL"+stxt,;
      sh := 80, HH := 77, i, a_diagnoz[10], ta, name_dbf := cur_dir+"_kartDNL"+sdbf,;
      mm_da_net := {{"нет",1},{"да ",2}}, ;
      mm_mest := {{"Волгоград или область",1},{"иногородние",2}},;
      mm_disp := {{"неважно",0},{"не проходили",1},{"прошли",2}},;
      mm_death := {{"выводить всех",0},{"не выводить умерших",1},{"выводить только умерших",2}},;
      mm_prik := {{"неважно",0},;
                  {"прикреплён к нашей МО",1},;
                  {"прикреплён к другим МО",2},;
                  {"прикрепление неизвестно",3}},;
      tmp_file := cur_dir+"tmp_mn_p"+sdbf,;
      k_fio, k_adr, tt_fio[10], tt_adr[10], fl_exit := .f.
Local adbf := {;
   {"UCHAST" ,   "N",  2,0},; // номер участка
   {"KOD_VU" ,   "N",  6,0},; // код в участке
   {"FIO"    ,   "C", 50,0},; // Ф.И.О. больного
   {"PHONE"  ,   "C", 40,0},; // телефон больного
   {"POL"    ,   "C",  1,0},; // пол
   {"DATE_R"   , "C", 10,0},; // дата рождения больного
   {"LET"    ,   "N",  2,0},; // сколько лет в этом году
   {"ADRESR"  ,  "C", 50,0},; // адрес больного
   {"ADRESP"  ,  "C", 50,0},; // адрес больного
   {"POLIS",     "C", 17,0},; // полис
   {"KOD_SMO",   "C",  5,0},; //
   {"SMO",       "C", 80,0},; // реестровый номер СМО;;преобразовать из старых кодов в новые, иногродние = 34
   {"SNILS"  ,   "C", 14,0},;
   {"MO_PR",     "C",  6,0},; // код МО приписки
   {"MONAME_PR", "C", 60,0},; // наименование МО приписки
   {"DATE_PR"  , "C", 10,0},; // дата приписки
   {"LAST_L_U" , "C", 10,0};  // дата последнего листа учёта
  }
if !myFileDeleted(name_dbf)
  return NIL
endif
Private mm_smo := {}, pyear, mstr_crb := 0, is_kategor2 := .f., is_talon := ret_is_talon()
if is_talon
  is_kategor2 := !empty(stm_kategor2)
endif
for i := 1 to len(glob_arr_smo)
  if glob_arr_smo[i,3] == 1
    aadd(mm_smo,{glob_arr_smo[i,1],padr(lstr(glob_arr_smo[i,2]),5)})
  endif
next
ta := f2_mnog_poisk_DNL(,,,1)
aadd(mm_tmp, {"god","N",4,0,"9999",;
              nil,;
              year(sys_date),nil,;
              "В каком году не было медомотра/диспансеризации"})
aadd(mm_tmp, {"v_period","C",100,0,NIL,;
              {|x|menu_reader(x,{{ |k,r,c| f2_mnog_poisk_DNL(k,r,c) }},A__FUNCTION)},;
              ta[1],{|x| ta[2] },;
              'Возрастные периоды медомотра/диспансеризации'})
aadd(mm_tmp, {"o_prik","N",1,0,NIL,;
              {|x|menu_reader(x,mm_prik,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_prik,x)},;
              "Отношение к прикреплению"})
aadd(mm_tmp, {"o_death","N",1,0,NIL,;
              {|x|menu_reader(x,mm_death,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_death,x)},;
              "Сведения о смерти по сведениям ТФОМС"})
Private arr_uchast := {}
if is_uchastok > 0
  aadd(mm_tmp, {"bukva","C",1,0,"@!",;
                nil,;
                " ",nil,;
                "Буква (перед участком)"})
  aadd(mm_tmp, {"uchast","N",1,0,,;
                {|x|menu_reader(x,{{|k,r,c| get_uchast(r+1,c) }},A__FUNCTION)},;
                0,{|| init_uchast(arr_uchast) },;
                "Участок (участки)"})
  mm_sort := {;
   {"№ участка + Лет + ФИО",1},;
   {"№ участка + Лет + Адрес",2},;
   {"№ участка + Адрес + Лет",4};
  }
  if is_uchastok == 1
    aadd(mm_sort, {'№ участка + № в участке',3})
  elseif is_uchastok == 2
    aadd(mm_sort, {'№ участка + Код по картотеке',3})
  elseif is_uchastok == 3
    aadd(mm_sort, {'№ участка + номер АК МИС',3})
  endif
else
  mm_sort := {;
   {"Лет + ФИО",1},;
   {"Лет + Адрес",2},;
   {"Код по картотеке",3};
  }
  Del_Array(adbf,1) // убираем участок
  Del_Array(adbf,1) // убираем участок
endif
aadd(mm_tmp, {"fio","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "ФИО (начальные буквы или шаблон)"})
aadd(mm_tmp, {"mi_git","N",2,0,NIL,;
              {|x|menu_reader(x,mm_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "Место жительства:"})
aadd(mm_tmp, {"_okato","C",11,0,NIL,;
              {|x|menu_reader(x,;
                {{ |k,r,c| get_okato_ulica(k,r,c,{k,m_okato,}) }},A__FUNCTION)},;
              space(11),{|x| space(11)},;
              'Адрес регистрации (ОКАТО)'})
aadd(mm_tmp, {"adres","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "Улица (подстрока или шаблон)"})
if is_talon
  aadd(mm_tmp, {"kategor","N",2,0,NIL,;
                {|x|menu_reader(x,mo_cut_menu(stm_kategor),A__MENUVERT)},;
                0,{|| space(10) },;
                "Код категории льготы"})
  if is_kategor2
    aadd(mm_tmp, {"kategor2","N",4,0,NIL,;
                  {|x|menu_reader(x,stm_kategor2,A__MENUVERT)},;
                  0,{|| space(10) },;
                  "Категория МО"})
  endif
endif
aadd(mm_tmp, {"pol","C",1,0,"!",;
              nil,;
              " ",nil,;
              "Пол", {|| mpol $ " МЖ" } })
aadd(mm_tmp, {"god_r_min","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "Дата рождения (минимальная)"})
aadd(mm_tmp, {"god_r_max","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "Дата рождения (максимальная)"})
aadd(mm_tmp, {"smo","C",5,0,NIL,;
              {|x|menu_reader(x,mm_smo,A__MENUVERT)},;
              space(5),{|| space(10) },;
              "Страховая компания"})
aadd(mm_tmp, {"i_sort","N",1,0,NIL,;
              {|x|menu_reader(x,mm_sort,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_sort,x)},;
              "Сортировка выходного документа"})
delete file (tmp_file)
init_base(tmp_file,,mm_tmp,0)
//
k := f_edit_spr(A__APPEND,mm_tmp,"множественному запросу",;
                "e_use(cur_dir+'tmp_mn_p')",0,1,,,,,"write_mn_p_DNL")
if k > 0
  mywait()
  use (tmp_file) new alias MN
  if is_talon .and. mn->kategor == 0
    is_talon := (is_kategor2 .and. mn->kategor2 > 0)
  endif
  Private mfio := "", madres := "", arr_vozr := List2Arr(mn->v_period)
  if !empty(mn->fio)
    mfio := alltrim(mn->fio)
    if !(right(mfio,1) == "*")
      mfio += "*"
    endif
  endif
  if !empty(mn->adres)
    madres := alltrim(mn->adres)
    if !(left(madres,1) == "*")
      madres := "*"+madres
    endif
    if !(right(madres,1) == "*")
      madres += "*"
    endif
  endif
  Private c_view := 0, c_found := 0
  Status_Key("^<Esc>^ - прервать поиск")
  hGauge := GaugeNew(,,,"Поиск в картотеке",.t.)
  GaugeDisplay( hGauge )
  //
  dbcreate(cur_dir+"tmp",{{"kod","N",7,0}},,.t.,"TMP")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_, recno() into KART2
  go top
  do while !eof()
    GaugeUpdate( hGauge, recno()/lastrec() )
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    f1_mnog_poisk_DNL(@c_view,@c_found)
    select KART
    skip
  enddo
  CloseGauge(hGauge)
  j := tmp->(lastrec())
  close databases
  if j == 0
    if !fl_exit
      func_error(4,"Нет сведений!")
    endif
  else
    stat_msg("Составление текстового и DBF-файлов")
    use (tmp_file) new alias MN
    arr_title := {;
     "─────┬",;
     " №№  │",;
     " пп  │",;
     "─────┴"}
    if is_uchastok > 0 .or. mn->i_sort == 3 // Код по картотеке
      arr_title[1] += "─────────┬"
      arr_title[2] += " Участок │"
      arr_title[3] += "   код   │"
      arr_title[4] += "─────────┴"
    endif
    arr_title[1] += "───────────────────────────────────────────┬──┬──────────┬───────────────────────────────────┬─────┬──────────"
    arr_title[2] += "             Ф.И.О. пациента               │Ле│   дата   │              Адрес                │при- │последний "
    arr_title[3] += "                (телефон)                  │т │ рождения │                                   │креп.│л/у по ОМС"
    arr_title[4] += "───────────────────────────────────────────┴──┴──────────┴───────────────────────────────────┴─────┴──────────"
    reg_print := f_reg_print(arr_title,@sh,2)
    dbcreate(name_dbf,adbf,,.t.,"DVN")
    R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
    R_Use(dir_server+"kartote2",,"KART2")
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"kartotek",,"KART")
    set relation to recno() into KART_, to recno() into KART2
    use (cur_dir+"tmp") new
    set relation to kod into KART
    if is_uchastok > 0
      if mn->i_sort == 1 // № участка + Год рождения + ФИО
        index on str(kart->uchast,2)+str(mn->god-year(kart->date_r),4)+upper(kart->fio) to (cur_dir+"tmp")
      elseif mn->i_sort == 2 // № участка + Год рождения + Адрес
        index on str(kart->uchast,2)+str(mn->god-year(kart->date_r),4)+upper(kart->adres) to (cur_dir+"tmp")
      elseif mn->i_sort == 4 // № участка + Адрес + Год рождения
        index on str(kart->uchast,2)+upper(kart->adres)+str(mn->god-year(kart->date_r),4) to (cur_dir+"tmp")
      elseif mn->i_sort == 3 // № участка + Код
        if is_uchastok == 1 // № участка + № в участке
          index on str(kart->uchast,2)+str(kart->kod_vu,5)+upper(kart->fio) to (cur_dir+"tmp")
        elseif is_uchastok == 2 // № участка + Код по картотеке
          index on str(kart->uchast,2)+str(kart->kod,7) to (cur_dir+"tmp")
        elseif is_uchastok == 3 // № участка + номер АК МИС
          index on str(kart->uchast,2)+kart2->kod_AK+upper(kart->fio) to (cur_dir+"tmp")
        endif
      endif
    else
      if mn->i_sort == 1 // Год рождения + ФИО
        index on str(mn->god-year(kart->date_r),4)+upper(kart->fio) to (cur_dir+"tmp")
      elseif mn->i_sort == 2 // Год рождения + Адрес
        index on str(mn->god-year(kart->date_r),4)+upper(kart->adres) to (cur_dir+"tmp")
      elseif mn->i_sort == 3 // Код по картотеке
        index on str(kod,7) to (cur_dir+"tmp")
      endif
    endif
    fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center(expand("РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА"),sh))
    add_string("")
    add_string(" == ПАРАМЕТРЫ ПОИСКА ==")
    add_string("В каком году не было медосмотра/диспансеризации несовершеннолетних: "+lstr(mn->god))
    if !empty(mn->v_period)
      add_string("Возрастные периоды медосмотра/диспансеризации: "+alltrim(mn->v_period))
    endif
    if mn->o_death == 1
      add_string("За исключением умерших (по сведению ТФОМС)")
    elseif mn->o_death == 2
      add_string("Список умерших (по сведению ТФОМС)")
    endif
    if !empty(mn->o_prik)
      add_string("Отношение к прикреплению: "+inieditspr(A__MENUVERT, mm_prik, mn->o_prik))
    endif
    if is_uchastok > 0
      if !empty(mn->bukva)
        add_string("Буква: "+mn->bukva)
      endif
      if !empty(mn->uchast)
        add_string("Участок: "+init_uchast(arr_uchast))
      endif
    endif
    if !empty(mfio)
      add_string("ФИО: "+mfio)
    endif
    if mn->mi_git > 0
      add_string("Место жительства: "+inieditspr(A__MENUVERT, mm_mest, mn->mi_git))
    endif
    if !empty(mn->_okato)
      add_string("Адрес регистрации (ОКАТО): "+ret_okato_ulica('',mn->_okato))
    endif
    if !empty(madres)
      add_string("Улица: "+madres)
    endif
    if is_talon .and. mn->kategor > 0
      add_string("Код категории льготы: "+inieditspr(A__MENUVERT, stm_kategor, mn->kategor))
    endif
    if is_talon .and. is_kategor2 .and. mn->kategor2 > 0
      add_string("Категория МО: "+inieditspr(A__MENUVERT, stm_kategor2, mn->kategor2))
    endif
    if !empty(mn->pol)
      add_string("Пол: "+mn->pol)
    endif
    if !empty(mn->god_r_min) .or. !empty(mn->god_r_max)
      if empty(mn->god_r_min)
        add_string("Лица, родившиеся до "+full_date(mn->god_r_max))
      elseif empty(mn->god_r_max)
        add_string("Лица, родившиеся после "+full_date(mn->god_r_min))
      else
        add_string("Лица, родившиеся с "+full_date(mn->god_r_min)+" по "+full_date(mn->god_r_max))
      endif
    endif
    if !empty(mn->smo)
      add_string("СМО: "+inieditspr(A__MENUVERT, mm_smo, mn->smo))
    endif
    add_string("")
    add_string("Найдено пациентов: "+lstr(tmp->(lastrec()))+" чел.")
    aeval(arr_title, {|x| add_string(x) } )
    ii := 0
    select TMP
    go top
    do while !eof()
      ++ii
      @ 24,1 say str(ii/tmp->(lastrec())*100,6,2)+"%" color cColorSt2Msg
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      mdate := ctod("")
      select HUMAN
      find (str(tmp->kod,7))
      do while human->kod_k == tmp->kod .and. !eof()
        if empty(mdate)
          mdate := human->k_data
        else
          mdate := max(mdate,human->k_data)
        endif
        skip
      enddo
      select DVN
      append blank
      s1 := padr(lstr(ii),6)
      if is_uchastok > 0 .or. mn->i_sort == 3
        if is_uchastok > 0
          s := ""
          if !empty(kart->uchast)
            dvn->UCHAST := kart->uchast
            s += lstr(kart->uchast)
          endif
          if is_uchastok == 1 .and. !empty(kart->kod_vu) // № участка + № в участке
            s += "/"+lstr(kart->kod_vu)
            dvn->KOD_VU := kart->kod_vu
          elseif is_uchastok == 2 // № участка + Код по картотеке
            s += "/"+lstr(kart->kod)
            dvn->KOD_VU := kart->kod
          elseif is_uchastok == 3 .and. !empty(kart2->kod_AK) // № участка + номер АК МИС
            s += "/"+ltrim(kart2->kod_AK)
            dvn->KOD_VU := val(kart2->kod_AK)
          endif
        else
          s := padl(lstr(tmp->kod),9)
        endif
        s1 += padr(s,10)
      endif
      s := ""
      if !empty(kart_->PHONE_H)
        s += "д."+alltrim(kart_->PHONE_H)+" "
      endif
      if !empty(kart_->PHONE_M)
        s += "м."+alltrim(kart_->PHONE_M)+" "
      endif
      if !empty(kart_->PHONE_W)
        s += "р."+alltrim(kart_->PHONE_W)
      endif
      dvn->FIO := kart->fio
      dvn->PHONE := s
      s := alltrim(kart->fio)+" "+s
      k_fio := perenos(tt_fio,s,43)
      s1 += padr(tt_fio[1],44)
      s1 += str(mn->god-year(kart->date_r),2)+" "
      s1 += full_date(kart->date_r)+" "
      dvn->POL := kart->pol
      dvn->DATE_R := full_date(kart->date_r)
      dvn->LET := mn->god-year(kart->date_r)
      k_adr := perenos(tt_adr,kart->adres,35)
      s1 += padr(tt_adr[1],36)
      dvn->ADRESR := kart->adres
      dvn->ADRESP := kart_->adresp
      dvn->POLIS := ltrim(kart_->NPOLIS)
      dvn->KOD_SMO := kart_->smo
      dvn->SMO := smo_to_screen(1)
      dvn->SNILS := iif(empty(kart->SNILS),"",transform(kart->SNILS,picture_pf))
      if !empty(dvn->mo_pr := kart2->mo_pr)
        dvn->MONAME_PR := ret_mo(kart2->mo_pr)[_MO_SHORT_NAME]
        if !empty(kart2->pc4)
          dvn->DATE_PR := left(kart2->pc4,6)+"20"+substr(kart2->pc4,7)
        else
          dvn->DATE_PR := full_date(kart2->DATE_PR)
        endif
      endif
      if empty(kart2->MO_PR)
        s := ""
      elseif kart2->MO_PR == glob_mo[_MO_KOD_TFOMS]
        s := "наш"
      else
        s := "чужой"
      endif
      s1 += padr(s,6)
      s1 += full_date(mdate)
      dvn->last_l_u := full_date(mdate)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s1)
      for i := 2 to max(k_fio,k_adr)
        s1 := space(6)
        if is_uchastok > 0 .or. mn->i_sort == 3
          s1 += space(10)
        endif
        s1 += padr(tt_fio[i],44)
        s1 += space(14)
        s1 += tt_adr[i]
        add_string(s1)
      next
      add_string(replicate("-",sh))
      select TMP
      skip
    enddo
    if fl_exit
      add_string("*** "+expand("ОПЕРАЦИЯ ПРЕРВАНА"))
    else
      add_string("Итого количество пациентов: "+lstr(tmp->(lastrec()))+" чел.")
    endif
    fclose(fp)
    close databases
    restscreen(buf)
    viewtext(name_file,,,,.t.,,,reg_print)
    n_message({"Создан файл для загрузки в Excel: "+name_dbf},,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
  endif
endif
close databases
restscreen(buf) ; setcolor(tmp_color)
return NIL

***** 31.10.16
Function write_mn_p_DNL(k)
Local fl := .t.
if k == 1
  if empty(mgod)
    fl := func_error(4,'Должно быть заполнено поле "Год проведения медосмотра/диспансеризации"')
  elseif empty(mv_period)
    fl := func_error(4,'Должен быть введён хотя бы один возрастной период медосмотра/диспансеризации')
  endif
endif
return fl

*

***** 31.10.16
Static Function f1_mnog_poisk_DNL(cv,cf)
Local i, j, k, n, s, arr, fl := .t., god_r, arr1
++cv
if fl
  fl := (ascan(arr_vozr,mn->god-year(kart->date_r)) > 0)
endif
if fl
  select HUMAN
  find (str(kart->kod,7))
  do while human->kod_k == kart->kod .and. !eof()
    if year(human->k_data) == mn->god .and. eq_any(human->ishod,101,102,301,302,303,304,305)
      fl := .f. ; exit
    endif
    skip
  enddo
endif
if fl .and. !empty(mn->o_prik)
  if mn->o_prik == 1 // к нашей МО
    fl := (kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
  elseif mn->o_prik == 2 // к другим МО
    fl := !(kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
  else // прикрепление неизвестно
    fl := empty(kart2->MO_PR)
  endif
endif
if fl .and. mn->o_death > 0
  if mn->o_death == 1 // За исключением умерших (по сведению ТФОМС)
    fl := !(left(kart2->PC2,1) == "1")
  elseif mn->o_death == 2 // Список умерших (по сведению ТФОМС)
    fl := (left(kart2->PC2,1) == "1")
  endif
endif
if fl .and. is_uchastok > 0 .and. !empty(mn->bukva)
  fl := (mn->bukva == kart->bukva)
endif
if fl .and. is_uchastok > 0 .and. !empty(mn->uchast)
  fl := f_is_uchast(arr_uchast,kart->uchast)
endif
if fl .and. !empty(mfio)
  fl := like(mfio,upper(kart->fio))
endif
if fl .and. !empty(madres)
  fl := like(madres,upper(kart->adres))
endif
if fl .and. is_talon .and. mn->kategor > 0
  fl := (mn->kategor == kart_->kategor)
endif
if fl .and. is_kategor2 .and. mn->kategor2 > 0
  fl := (mn->kategor2 == kart_->kategor2)
endif
if fl .and. !empty(mn->pol)
  fl := (kart->pol == mn->pol)
endif
if fl .and. !empty(mn->god_r_min)
  fl := (mn->god_r_min <= kart->date_r)
endif
if fl .and. !empty(mn->god_r_max)
  fl := (human->date_r <= mn->god_r_max)
endif
if fl .and. mn->mi_git > 0
  if mn->mi_git == 1
    fl := (left(kart_->okatog,2)=='18')
  else
    fl := !(left(kart_->okatog,2)=='18')
  endif
endif
if fl .and. !empty(mn->_okato)
  s := mn->_okato
  for i := 1 to 3
    if right(s,3)=='000'
      s := left(s,len(s)-3)
    else
      exit
    endif
  next
  fl := (left(kart_->okatog,len(s))==s)
endif
if fl .and. !empty(mn->smo)
  fl := (kart_->smo == mn->smo)
endif
if fl
  select TMP
  append blank
  tmp->kod := kart->kod
  if ++cf % 5000 == 0
    tmp->(dbCommit())
  endif
endif
@ 24,1 say lstr(cv) color cColorSt2Msg
@ row(),col() say "/" color "W/R"
@ row(),col() say lstr(cf) color cColorStMsg
return NIL

***** 31.10.16 запрос в GET-е возрастных периодов медомотров несовершеннолетних
Function f2_mnog_poisk_DNL(k,r,c,par)
Static sast, sarr
Local buf := save_maxrow(), a, i, j, s, s1
DEFAULT par TO 2
if sast == NIL
  sast := {} ; sarr := {}
  for j := 0 to 17
    aadd(sast,.t.)
    s := lstr(j)
    if j == 1
      s += " год"
    elseif between(j,2,4)
      s += " года"
    else
      s += " лет"
    endif
    aadd(sarr,{s,j})
  next
endif
s := s1 := ""
if par == 1
  sast := {}
  for i := 1 to len(sarr)
    aadd(sast,.t.)
    s += lstr(sarr[i,2])+iif(i<len(sarr),",","")
  next
  s1 := "все"
elseif (a := bit_popup(r,c,sarr,sast)) != NIL
  afill(sast,.f.)
  for i := 1 to len(a)
    if (j := ascan(sarr,{|x| x[2]==a[i,2] })) > 0
      sast[j] := .t.
      s += lstr(a[i,2])+iif(i<len(a),",","")
    endif
  next
  if len(a) == len(sast)
    s1 := "все"
  endif
endif
if empty(s)
  s := space(10)
endif
if empty(s1)
  s1 := s
endif
return {s,s1}

*

***** 18.12.13 Сводные документы по всем видам диспансеризации и профилактики
Function inf_DISP(k)
Static si1 := 1, si2 := 1
Local mas_pmt, mas_msg, mas_fun
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~Итоги для ТФОМС"}
    mas_msg := {"Итоги за период времени для ТФОМС"}
    mas_fun := {"inf_DISP(11)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
   itog_svod_DISP_TF()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  endif
endif
return NIL

*

***** 18.12.13 Итоги за период времени для ТФОМС
Function itog_svod_DISP_TF()
Local i, k, arr_m, buf := save_maxrow(), ;
      sh := 80, hh := 60, n_file := "svod_dis"+stxt
if (arr_m := year_month(,,,5)) != NIL
  mywait()
  dbcreate(cur_dir+"tmpk",{{"kod","N",7,0},;
                           {"tip","N",1,0}})
  use (cur_dir+"tmpk") new
  index on str(tip,1)+str(kod,7) to (cur_dir+"tmpk")
  dbcreate(cur_dir+"tmp",{{"tip",  "N",1,0},;
                          {"kol_s","N",6,0},;
                          {"kol_o","N",6,0},;
                          {"kol_p","N",6,0}})
  use (cur_dir+"tmp") new
  index on str(tip,1) to (cur_dir+"tmp")
  R_Use(dir_server+"mo_rak",,"RAK")
  R_Use(dir_server+"mo_raks",,"RAKS")
  set relation to akt into RAK
  R_Use(dir_server+"mo_raksh",,"RAKSH")
  set relation to kod_raks into RAKS
  index on str(kod_h,7)+dtos(rak->dakt) to (cur_dir+"tmpraksh")
  R_Use(dir_server+"mo_rpd",,"RPD")
  R_Use(dir_server+"mo_rpds",,"RPDS")
  set relation to pd into RPD
  R_Use(dir_server+"mo_rpdsh",,"RPDSH")
  set relation to kod_rpds into RPDS
  index on str(kod_h,7)+dtos(rpd->d_pd) to (cur_dir+"tmprpdsh")
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(arr_m[5]),.t.)
  index on kod to (cur_dir+"tmp_h") ;
        for ishod > 100 .and. human_->oplata != 9 .and. schet > 0 ;
        while human->k_data <= arr_m[6] ;
        PROGRESS
  i := 0
  go top
  do while !eof()
    ++i
    @ maxrow(),1 say lstr(i) color cColorWait
    ltip := 0
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // только зарегистрированные
      if eq_any(human->ishod,101,102)
        ltip := iif(empty(human->za_smo), 2, 1)
      elseif eq_any(human->ishod,301,302)
        ltip := 3
      elseif eq_any(human->ishod,303,304)
        m1gruppa := human_->RSLT_NEW - 316
        if between(m1gruppa,1,3)
          ltip := 4
        endif
      elseif human->ishod == 305
        ltip := 5
      elseif eq_any(human->ishod,201,202)
        ltip := 6
      elseif human->ishod == 203
        ltip := 7
      endif
    endif
    if ltip > 0
      select TMPK
      find (str(ltip,1)+str(human->kod_k,7))
      if !found()
        append blank
        tmpk->tip := ltip
        tmpk->kod := human->kod_k
        if lastrec() % 2000 == 0
          commit
        endif
      endif
      select TMP
      find (str(ltip,1))
      if !found()
        append blank
        tmp->tip := ltip
      endif
      tmp->kol_s ++
      //
      k := 0
      select RAKSH
      find (str(human->kod,7))
      do while raksh->kod_h == human->kod .and. !eof()
        if raksh->IS_REPEAT < 1
          k := iif(raksh->SUMP > 0, 1, 0)
        endif
        skip
      enddo
      if k == 1
        tmp->kol_o ++
      endif
      //
      k := 0
      select RPDSH
      find (str(human->kod,7))
      do while rpdsh->kod_h == human->kod .and. !eof()
        k += rpdsh->S_SL
        skip
      enddo
      if k > 0
        tmp->kol_p ++
      endif
    endif
    select HUMAN
    skip
  enddo
  //
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string(glob_mo[_MO_SHORT_NAME])
  add_string("")
  add_string(center("Итоги по диспансеризации, профилактике и медосмотрам",sh))
  add_string(center("[ "+charrem("~",mas1pmt[3])+" ]",sh))
  add_string(center(arr_m[4],sh))
  add_string("")
  add_string("────────────────────────────────────────┬─────────┬─────────┬─────────┬─────────")
  add_string("                                        │ Кол-во  │ Кол-во  │ Кол-во  │ Кол-во  ")
  add_string("                                        │ случаев │ человек │ случаев,│ случаев,")
  add_string("                                        │         │         │ принятых│оплаченн.")
  add_string("                                        │         │         │ к оплате│полностью")
  add_string("                                        │         │         │         │или част.")
  add_string("────────────────────────────────────────┴─────────┴─────────┴─────────┴─────────")
  for i := 1 to 7
    s :=    {"диспансеризация детей-сирот в стационаре",;
             "диспансеризация детей-сирот под опекой",;
             "профилактич.осмотры несовершеннолетних",;
             "предварительн.осмотры несовершеннолетних",;
             "периодические осмотры несовершеннолетних",;
             "диспансеризация взрослого населения",;
             "профилактика взрослого населения"}[i]
    select TMP
    find (str(i,1))
    if found()
      k := 0
      select TMPK
      find (str(i,1))
      do while tmpk->tip == i .and. !eof()
        ++k
        skip
      enddo
      s := padr(s,40)+put_val(tmp->kol_s, 9)+;
                      put_val(k         ,10)+;
                      put_val(tmp->kol_o,10)+;
                      put_val(tmp->kol_p,10)
    endif
    add_string(s)
    add_string(replicate("─",sh))
  next
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(n_file,,,,.f.,,,2)
endif
return NIL
