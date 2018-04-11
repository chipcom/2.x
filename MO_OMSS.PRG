***** mo_omss.prg - работа со счетами в задаче ОМС
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 06.12.17 читать файлы из ТФОМС (или СМО)
Function read_from_tf()
Local name_zip, _date, _time, s, arr_f := {}, buf, blk_sp_tk, fl := .f., n, hUnzip,;
      nErr, cFile, cName, arr_XML_info[7], tip_csv_file := 0, kod_csv_reestr := 0
if tip_polzovat != 0
  return func_error(4,err_admin)
endif
if find_unfinished_reestr_sp_tk()
  return NIL
endif
Private p_var_manager := "Read_From_TFOMS", p_ctrl_enter_sp_tk := .f.
blk_sp_tk := {|| p_ctrl_enter_sp_tk := .t., __keyboard(CHR(K_ENTER)) }
SETKEY(K_CTRL_ENTER, blk_sp_tk)
Private full_zip := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,1,,,,"*.zip")
SETKEY(K_CTRL_ENTER, nil)
if !empty(full_zip)
  full_zip := upper(full_zip)
  name_zip := StripPath(full_zip)
  cName := Name_Without_Ext(name_zip)
  /*if right(full_zip,4) == scsv
    if Is_Our_CSV(cName,@tip_csv_file,@kod_csv_reestr)
      fl := read_CSV_from_TF(full_zip,tip_csv_file,kod_csv_reestr)
    endif
    return fl
  endif*/
  // если это укрупнённый архив, распаковать и прочитать
  if !Is_Our_ZIP(cName,@tip_csv_file,@kod_csv_reestr)
    return fl
  endif
  if tip_csv_file > 0 // если это CSV-файлы прикрепления/открепления
    if (arr_f := Extract_Zip_XML(KeepPath(full_zip),name_zip)) != NIL
      if (n := ascan(arr_f,{|x| upper(Name_Without_Ext(x)) == upper(cName)})) > 0
        fl := read_CSV_from_TF(arr_f[n],tip_csv_file,kod_csv_reestr)
      else
        fl := func_error(4,"В архиве "+name_zip+" нет файла "+cName+scsv)
      endif
    endif
    return NIL
  endif
  // ещё раз, т.к. может быть переопределена переменная full_zip
  name_zip := StripPath(full_zip)
  cName := Name_Without_Ext(name_zip)
  // проверим, а нам ли предназначен данный файл
  if !Is_Our_XML(cName,arr_XML_info)
    return fl
  endif
  // проверим, читали ли уже данный файл
  if Verify_Is_Already_XML(cName,@_date,@_time)
    // спросить надо ли ещё раз читать, т.к. уже читали
    func_error(4,"Данный файл уже был прочитан и обработан в "+_time+" "+date_8(_date)+"г.")
    viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+cName+stxt,60,80),,,,.t.,,,2)
    return fl
  else
    s := "чтения "
    do case
      case arr_XML_info[1] == _XML_FILE_FLK
        s += "протокола ФЛК"
      case arr_XML_info[1] == _XML_FILE_SP
        s += "реестра СП и ТК"
      case arr_XML_info[1] == _XML_FILE_RAK
        s += "р-ра актов контроля"
      case arr_XML_info[1] == _XML_FILE_RPD
        s += "р-ра плат.док-тов"
      case arr_XML_info[1] == _XML_FILE_R02
        s += "файла ответа на R01"
      case arr_XML_info[1] == _XML_FILE_R06
        s += "файла ответа на R05"
    endcase
    buf := savescreen()
    f_message({"Системная дата: "+date_month(sys_date,.t.),;
               "Обращаем Ваше внимание, что после",;
               s,;
               "все документы будут созданы с этой датой.",;
               "",;
               "Изменить их будет НЕВОЗМОЖНО!"},,"R/R*","N/R*")
    fl := .t.
    if arr_XML_info[1] == _XML_FILE_SP .and. p_ctrl_enter_sp_tk
      fl := involved_password(2,"HT34M111111_"+right(cName,7),"чтения С ОШИБКАМИ реестра СП и ТК")
    endif
    if year(sys_date) < 2016
      fl := func_error(4,"Данная операция возможна начиная с 2016 года!")
    elseif fl
      fl := f_Esc_Enter(s,.t.)
    endif
    restscreen(buf)
    if !fl
      return fl
    endif
  endif
  if (arr_f := Extract_Zip_XML(KeepPath(full_zip),name_zip)) != NIL
    if (n := ascan(arr_f,{|x| upper(Name_Without_Ext(x)) == upper(cName)})) > 0
      fl := read_XML_from_TF(arr_f[n],arr_XML_info,arr_f)
    else
      fl := func_error(4,"В архиве "+name_zip+" нет файла "+cName+sxml)
    endif
  endif
endif
return fl

***** 07.12.17 чтение в память и анализ XML-файла
Function read_XML_from_TF(cFile,arr_XML_info,arr_f)
Local nTypeFile := 0, aerr := {}, j, oXmlDoc, oXmlNode, oNode1, oNode2, ;
      nCountWithErr := 0, adbf, go_to_schet := .f., go_to_akt := .f.,;
      go_to_rpd := .f., buf := save_maxrow()
nTypeFile := arr_XML_info[1]
if !myFileDeleted(cur_dir+"tmp1file"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp2file"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp3file"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp4file"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp_r_t1"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp_r_t2"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp_r_t3"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp_r_t4"+sdbf)
  return NIL
endif
if !myFileDeleted(cur_dir+"tmp_r_t5"+sdbf)
  return NIL
endif
if eq_any(nTypeFile,_XML_FILE_FLK,_XML_FILE_R02,_XML_FILE_R06)
  //
elseif !mo_Lock_Task(X_OMS)
  return .f.
endif
mywait("Производится анализ файла "+cFile)
Private cReadFile := Name_Without_Ext(cFile), ;
        cTimeBegin := hour_min(seconds()),;
        mkod_reestr := 0, mXML_REESTR := 0, mdate_schet, is_err_FLK := .f.
Private cFileProtokol := cReadFile+stxt
strfile(space(10)+"Протокол обработки файла: "+cFile+hb_eol(),cFileProtokol)
strfile(space(10)+full_date(sys_date)+"г. "+cTimeBegin+hb_eol(),cFileProtokol,.t.)
// читаем файл в память
oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
if empty( oXmlDoc:aItems )
  aadd(aerr,"Ошибка в чтении файла "+cFile)
elseif nTypeFile == _XML_FILE_FLK
  is_err_FLK := protokol_flk_tmpfile(arr_f,aerr)
elseif nTypeFile == _XML_FILE_SP
  reestr_sp_tk_tmpfile(oXmlDoc,aerr,cReadFile)
elseif nTypeFile == _XML_FILE_RAK
  reestr_rak_tmpfile(oXmlDoc,aerr,cReadFile)
elseif nTypeFile == _XML_FILE_RPD
  reestr_rpd_tmpfile(oXmlDoc,aerr,cReadFile)
elseif nTypeFile == _XML_FILE_R02
  reestr_R02_tmpfile(oXmlDoc,aerr,cReadFile)
elseif nTypeFile == _XML_FILE_R06
  reestr_R06_tmpfile(oXmlDoc,aerr,cReadFile)
endif
close databases
if empty(aerr)
  do case
    case nTypeFile == _XML_FILE_FLK
      strfile(hb_eol()+"Тип файла: протокол ФЛК (форматно-логического контроля)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      if read_XML_FILE_FLK(arr_XML_info,aerr)
        // запишем принимаемый файл (протокол ФЛК)
        //chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
        chip_copy_zipXML(full_zip,dir_server+dir_XML_TF)
        use (cur_dir+"tmp1file") new alias TMP1
        G_Use(dir_server+"mo_xml",,"MO_XML")
        AddRecN()
        mo_xml->KOD := recno()
        mo_xml->FNAME := cReadFile
        mo_xml->DREAD := sys_date
        mo_xml->TREAD := hour_min(seconds())
        mo_xml->TIP_IN := _XML_FILE_FLK // тип принимаемого файла;3-ФЛК
        mo_xml->DWORK  := sys_date
        mo_xml->TWORK1 := cTimeBegin
        mo_xml->TWORK2 := hour_min(seconds())
        mo_xml->REESTR := mkod_reestr
        mo_xml->KOL2   := tmp1->KOL2
      endif
    case nTypeFile == _XML_FILE_SP
      strfile(hb_eol()+"Тип файла: реестр СП и ТК (страховой принадлежности и технологического контроля)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      nCountWithErr := 0
      if read_XML_FILE_SP(arr_XML_info,aerr,@nCountWithErr) > 0
        go_to_schet := create_schet_from_XML(arr_XML_info,aerr,,,cReadFile)
      elseif nCountWithErr > 0 // все пришли с ошибкой
        G_Use(dir_server+"mo_xml",,"MO_XML")
        goto (mXML_REESTR)
        G_RLock(forever)
        mo_xml->TWORK2 := hour_min(seconds())
      endif
    case nTypeFile == _XML_FILE_RAK
      strfile(hb_eol()+"Тип файла: РАК (реестр актов контроля)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      read_XML_FILE_RAK(arr_XML_info,aerr)
      go_to_akt := empty(aerr)
    case nTypeFile == _XML_FILE_RPD
      strfile(hb_eol()+"Тип файла: РПД (реестр платёжных документов)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      read_XML_FILE_RPD(arr_XML_info,aerr)
      go_to_rpd := empty(aerr)
    case nTypeFile == _XML_FILE_R02
      strfile(hb_eol()+"Тип файла: R02 (ответ на файл R01)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      nCountWithErr := 0
      read_XML_FILE_R02(arr_XML_info,aerr,@nCountWithErr)
      G_Use(dir_server+"mo_xml",,"MO_XML")
      goto (mXML_REESTR)
      G_RLock(forever)
      mo_xml->TWORK2 := hour_min(seconds())
    case nTypeFile == _XML_FILE_R06
      strfile(hb_eol()+"Тип файла: R06 (ответ на файл R05)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      nCountWithErr := 0
      read_XML_FILE_R06(arr_XML_info,aerr,@nCountWithErr)
      G_Use(dir_server+"mo_xml",,"MO_XML")
      goto (mXML_REESTR)
      G_RLock(forever)
      mo_xml->TWORK2 := hour_min(seconds())
  endcase
endif
close databases
rest_box(buf)
if eq_any(nTypeFile,_XML_FILE_FLK,_XML_FILE_R02,_XML_FILE_R06)
  //
else
  mo_UnLock_Task(X_OMS)
endif
if empty(aerr) .or. nCountWithErr > 0 // запишем файл протокола обработки
  chip_copy_zipXML(cFileProtokol,dir_server+dir_XML_TF)
endif
if !empty(aerr)
  aeval(aerr,{|x| strfile(x+hb_eol(),cFileProtokol,.t.) })
endif
viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
delete file (cFileProtokol)
if go_to_schet // если выписаны счета
  keyboard chr(K_TAB)+chr(K_ENTER)
elseif go_to_akt // если приняты акты
  keyboard replicate(chr(K_TAB),3)+replicate(chr(K_ENTER),2)
elseif go_to_rpd // если приняты платёжки
  keyboard replicate(chr(K_TAB),4)+chr(K_ENTER)
endif
return NIL

*

***** прочитать реестр ФЛК
Function read_XML_FILE_FLK(arr_XML_info,aerr)
Local ii, pole, i, k, t_arr[2], adbf, ar
mkod_reestr := arr_XML_info[7]
use (cur_dir+"tmp1file") new alias TMP1
R_Use(dir_server+"mo_rees",,"REES")
goto (arr_XML_info[7])
strfile("Обрабатывается ответ ТФОМС на реестр № "+;
        lstr(rees->NSCHET)+" от "+full_date(rees->DSCHET)+"г. ("+;
        lstr(rees->KOL)+" чел.)"+;
        hb_eol(),cFileProtokol,.t.)
if !emptyany(rees->nyear,rees->nmonth)
  strfile("выставленный за "+;
          mm_month[rees->nmonth]+str(rees->nyear,5)+" года"+;
          hb_eol(),cFileProtokol,.t.)
endif
use (cur_dir+"tmp2file") new alias TMP2
index on str(tip,1)+str(oshib,3) to (cur_dir+"tmp2")
if is_err_FLK
  if !extract_reestr(rees->(recno()),rees->name_xml)
    aadd(aerr,center("Не найден ZIP-архив с РЕЕСТРом № "+lstr(rees->nschet)+" от "+date_8(rees->DSCHET),80))
    aadd(aerr,"")
    aadd(aerr,center(dir_server+dir_XML_MO+cslash+alltrim(rees->name_xml)+szip,80))
    aadd(aerr,"")
    aadd(aerr,center("Без данного архива дальнейшая работа НЕВОЗМОЖНА!",80))
    close databases
    return .f.
  endif
  use (cur_dir+"tmp_r_t1") new alias T1
  index on upper(ID_PAC) to (cur_dir+"tmp_r_t1")
  use (cur_dir+"tmp_r_t2") new alias T2
  use (cur_dir+"tmp_r_t3") new alias T3
  use (cur_dir+"tmp_r_t4") new alias T4
  use (cur_dir+"tmp_r_t5") new alias T5
  // заполнить поле "N_ZAP" в файле "tmp2"
  fill_tmp2_file_flk()
  R_Use(dir_server+"mo_otd",,"OTD")
  G_Use(dir_server+"human_",,"HUMAN_")
  G_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_, to otd into OTD
  G_Use(dir_server+"mo_rhum",,"RHUM")
  index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
  select TMP2 // сначала проверка
  go top
  do while !eof()
    select RHUM
    find (str(tmp2->N_ZAP,6))
    if found()
      human->(dbGoto(rhum->KOD_HUM))
      if rhum->OPLATA > 0
        aadd(aerr,"Пациент с REES_ZAP="+lstr(rhum->REES_ZAP)+" был прочитан в реестре СП и ТК")
        if !empty(human->fio)
          aadd(aerr,"└─>(ФИО пациента = "+alltrim(human->fio)+")")
        endif
      endif
      if !(rhum->REES_ZAP == human_->REES_ZAP)
        aadd(aerr,"Не равен параметр REES_ZAP: "+lstr(rhum->REES_ZAP)+" != "+lstr(human_->REES_ZAP))
      endif
    else
      aadd(aerr,"Не найден случай с N_ZAP="+lstr(tmp2->N_ZAP))
    endif
    select TMP2
    skip
  enddo
  if !empty(aerr)
    close databases
    return .f.
  endif
endif
for ii := 1 to 2
  pole := "tmp1->fname"+lstr(ii)
  strfile(hb_eol()+"Обработан файл "+&pole+hb_eol(),cFileProtokol,.t.)
  select TMP2
  find (str(ii,1))
  if found()
    strfile("  Список ошибок:"+hb_eol(),cFileProtokol,.t.)
    do while tmp2->tip == ii .and. !eof()
      s := "код ошибки = "+lstr(tmp2->OSHIB)
      if (i := ascan(glob_F012,{|x| x[2] == tmp2->OSHIB})) > 0
        s += ' "'+glob_F012[i,5]+'"'
      endif
      if !empty(tmp2->IM_POL)
        s += ", имя поля = "+alltrim(tmp2->IM_POL)
      endif
      if !empty(tmp2->BAS_EL)
        s += ", имя базового элемента = "+alltrim(tmp2->BAS_EL)
      endif
      if !empty(tmp2->ID_BAS)
        s += ", GUID базового элемента = "+alltrim(tmp2->ID_BAS)
      endif
      if !empty(tmp2->COMMENT)
        s += ", описание ошибки = "+alltrim(tmp2->COMMENT)
      endif
      if !empty(tmp2->BAS_EL) .and. !empty(tmp2->ID_BAS)
        if empty(tmp2->N_ZAP)
          s += ", СЛУЧАЙ НЕ НАЙДЕН!"
        else
          select RHUM
          find (str(tmp2->N_ZAP,6))
          G_RLock(forever)
          rhum->OPLATA := 2
          tmp2->kod_human := rhum->KOD_HUM
          select HUMAN
          goto (rhum->KOD_HUM)
          if human_->REESTR == mkod_reestr
            G_RLock(forever)
            human_->(G_RLock(forever))
            human_->OPLATA := 2
            human_->REESTR := 0 // направляется на дальнейшее редактирование
            human_->ST_VERIFY := 0 // снова ещё не проверен
            if human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM-1
            endif
            UnLock
            s += ", "+alltrim(human->fio)+", "+full_date(human->date_r)+;
                 iif(empty(otd->SHORT_NAME), "", " ["+alltrim(otd->SHORT_NAME)+"]")+;
                 " "+date_8(human->n_data)+"-"+date_8(human->k_data)
          endif
        endif
      endif
      k := perenos(t_arr,s,75)
      strfile(hb_eol(),cFileProtokol,.t.)
      for i := 1 to k
        strfile(space(5)+t_arr[i]+hb_eol(),cFileProtokol,.t.)
      next
      select TMP2
      skip
    enddo
  else
    strfile("-- Ошибок не обнаружено -- "+hb_eol(),cFileProtokol,.t.)
  endif
next
close databases
return .t.

***** заполнить поле "N_ZAP" в файле "tmp2"
Function fill_tmp2_file_flk()
Local i, s, s1, adbf, ar
use (cur_dir+"tmp22fil") new alias TMP22
select TMP2
adbf := array(fcount())
go top
do while !eof()
  if !empty(tmp2->BAS_EL) .and. !empty(tmp2->ID_BAS)
    s := alltrim(tmp2->BAS_EL) ; s1 := alltrim(tmp2->ID_BAS)
    do case
      case s == "ZAP"
        select T1
        Locate for t1->N_ZAP==padr(s1,6)
        if found()
          tmp2->N_ZAP := val(t1->N_ZAP)
        endif
      case s == "PACIENT"
        ar := {}
        select T1
        find (padr(upper(s1),36))
        do while upper(t1->ID_PAC)==padr(upper(s1),36)
          aadd(ar,int(val(t1->N_ZAP)))
          skip
        enddo
        if len(ar) > 0
          select TMP2
          tmp2->N_ZAP := ar[1]
          if len(ar) > 1
            aeval(adbf, {|x,i| adbf[i] := fieldget(i) }  )
            select TMP22
            for i := 2 to len(ar)
              append blank
              aeval(adbf, {|x,i| fieldput(i,x) } )
              tmp22->N_ZAP := ar[i]
            next
          endif
        endif
      case s == "SLUCH"
        select T1
        Locate for upper(t1->ID_C)==padr(upper(s1),36)
        if found()
          tmp2->N_ZAP := val(t1->N_ZAP)
        endif
      case s == "USL"
        select T2
        Locate for upper(t2->ID_U)==padr(upper(s1),36)
        if found()
          select T1
          Locate for t1->N_ZAP==t2->IDCASE
          if found()
            tmp2->N_ZAP := val(t1->N_ZAP)
          endif
        endif
      case s == "PERS"
        select T3
        Locate for upper(t3->ID_PAC)==padr(upper(s1),36)
        if found()
          ar := {}
          select T1
          find (padr(upper(s1),36))
          do while upper(t1->ID_PAC)==padr(upper(s1),36)
            aadd(ar,int(val(t1->N_ZAP)))
            skip
          enddo
          if len(ar) > 0
            select TMP2
            tmp2->N_ZAP := ar[1]
            if len(ar) > 1
              aeval(adbf, {|x,i| adbf[i] := fieldget(i) }  )
              select TMP22
              for i := 2 to len(ar)
                append blank
                aeval(adbf, {|x,i| fieldput(i,x) } )
                tmp22->N_ZAP := ar[i]
              next
            endif
          endif
        endif
    endcase
  endif
  select TMP2
  skip
enddo
i := tmp22->(lastrec())
tmp22->(dbCloseArea())
if i > 0
  select TMP2
  append from tmp22fil codepage "RU866"
  index on str(tip,1)+str(oshib,3) to (cur_dir+"tmp2")
endif
return NIL

*

***** 07.02.17 прочитать и "разнести" по базам данных реестр СП
Function read_XML_FILE_SP(arr_XML_info,aerr,/*@*/current_i2)
Local count_in_schet := 0, mnschet, bSaveHandler, ii1, ii2, i, k, t_arr[2],;
      ldate_sptk, s, fl_589, mANSREESTR
if !(type("p_ctrl_enter_sp_tk") == "L")
  Private p_ctrl_enter_sp_tk := .f.
endif
use (cur_dir+"tmp1file") new alias TMP1
ldate_sptk := tmp1->_DATA
mnschet := int(val(tmp1->_NSCHET))  // в число (отрезать всё, что после "-")
mANSREESTR := afteratnum("-",tmp1->_NSCHET)
R_Use(dir_server+"mo_rees",,"REES")
index on str(NSCHET,6) to (cur_dir+"tmp_rees") for NYEAR == tmp1->_YEAR
find (str(mnschet,6))
if found()
  mkod_reestr := arr_XML_info[7] := rees->kod
  strfile("Обрабатывается ответ ТФОМС ("+alltrim(tmp1->_NSCHET)+") на реестр № "+;
          lstr(rees->NSCHET)+" от "+full_date(rees->DSCHET)+"г. ("+;
          lstr(rees->KOL)+" чел.)"+;
          hb_eol(),cFileProtokol,.t.)
  if !emptyany(rees->nyear,rees->nmonth)
    strfile("выставленный за "+;
            mm_month[rees->nmonth]+str(rees->nyear,5)+" года"+;
            hb_eol(),cFileProtokol,.t.)
  endif
  strfile(hb_eol(),cFileProtokol,.t.)
  //
  R_Use(dir_server+"mo_xml",,"MO_XML")
  index on ANSREESTR to (cur_dir+"tmp_xml") for reestr == mkod_reestr
  find (mANSREESTR)
  if found()
    aadd(aerr,'По реестру № '+lstr(mnschet)+' от '+date_8(tmp1->_DSCHET)+' уже прочитан ответ номер "'+alltrim(tmp1->_NSCHET)+'"')
  endif
else
  aadd(aerr,"Не найден РЕЕСТР № "+lstr(mnschet)+" от "+date_8(tmp1->_DSCHET))
endif
if empty(aerr) .and. !extract_reestr(rees->(recno()),rees->name_xml)
  aadd(aerr,center("Не найден ZIP-архив с РЕЕСТРом № "+lstr(mnschet)+" от "+date_8(tmp1->_DSCHET),80))
  aadd(aerr,"")
  aadd(aerr,center(dir_server+dir_XML_MO+cslash+alltrim(rees->name_xml)+szip,80))
  aadd(aerr,"")
  aadd(aerr,center("Без данного архива дальнейшая работа НЕВОЗМОЖНА!",80))
endif
if empty(aerr)
  R_Use(dir_server+"human",,"HUMAN")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"mo_rhum",,"RHUM")
  index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
  use (cur_dir+"tmp2file") new alias TMP2
  // сначала проверка
  ii1 := ii2 := 0
  go top
  do while !eof()
    if tmp2->_OPLATA == 1
      ++ii1
      if ascan(glob_arr_smo,{|x| x[2] == int(val(tmp2->_SMO)) }) == 0
        aadd(aerr,"Некорректное значение атрибута SMO: "+tmp2->_SMO)
      endif
    elseif tmp2->_OPLATA == 2
      ++ii2
    else
      aadd(aerr,"Некорректное значение атрибута OPLATA: "+lstr(tmp2->_OPLATA))
    endif
    select RHUM
    find (str(tmp2->_N_ZAP,6))
    if found()
      human_->(dbGoto(rhum->KOD_HUM))
      if rhum->OPLATA > 0
        aadd(aerr,"Пациент с REES_ZAP="+lstr(rhum->REES_ZAP)+" был прочитан в предыдущем реестре СП и ТК")
        human->(dbGoto(rhum->KOD_HUM))
        if !empty(human->fio)
          aadd(aerr,"└─>(ФИО пациента = "+alltrim(human->fio)+")")
        endif
      endif
      if iif(p_ctrl_enter_sp_tk, (tmp2->_OPLATA == 1), .t.)
        if !(rhum->REES_ZAP == human_->REES_ZAP)
          aadd(aerr,"Не равен параметр REES_ZAP: "+lstr(rhum->REES_ZAP)+" != "+lstr(human_->REES_ZAP))
        endif
        if !(upper(tmp2->_ID_PAC) == upper(human_->ID_PAC))
          aadd(aerr,"Не равен параметр ID_PAC: "+tmp2->_ID_PAC+" != "+human_->ID_PAC)
        endif
        if !(upper(tmp2->_ID_C) == upper(human_->ID_C))
          aadd(aerr,"Не равен параметр ID_C: "+tmp2->_ID_C+" != "+human_->ID_C)
        endif
      endif
    else
      aadd(aerr,"Не найден случай с N_ZAP="+lstr(tmp2->_N_ZAP)+", _ID_PAC="+tmp2->_ID_PAC)
    endif
    select TMP2
    skip
  enddo
  tmp1->kol1 := ii1
  tmp1->kol2 := ii2
  close databases
  if empty(aerr) // если проверка прошла успешно
    Private fl_open := .t.
    bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
    BEGIN SEQUENCE
      if ii1 > 0 // были пациенты без ошибок
        index_base("schet") // для составления счетов
        index_base("human") // для разноски счетов
        use (dir_server+"human_u") new READONLY
        index on str(kod,7)+date_u to (dir_server+"human_u") progress
        use
        Use (dir_server+"mo_hu") new READONLY
        index on str(kod,7)+date_u to (dir_server+"mo_hu") progress
        Use
      endif
      if ii2 > 0 // были пациенты с ошибками
        if !p_ctrl_enter_sp_tk
          index_base("mo_refr")  // для записи причин отказов
        endif
        if ii1 == 0 // в ответном файле не было пациентов без ошибок
          index_base("human") // для разноски ФИО
        endif
      endif
    RECOVER USING error
      aadd(aerr,"Возникла непредвиденная ошибка при переиндексировании!")
    END
    ERRORBLOCK(bSaveHandler)
    close databases
  endif
  if empty(aerr) // если проверка прошла успешно
    // запишем принимаемый файл (реестр СП)
    //chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
    chip_copy_zipXML(full_zip,dir_server+dir_XML_TF)
    G_Use(dir_server+"mo_xml",,"MO_XML")
    AddRecN()
    mo_xml->KOD := recno()
    mo_xml->FNAME := cReadFile
    mo_xml->DFILE := ldate_sptk
    mo_xml->TFILE := ""
    mo_xml->DREAD := sys_date
    mo_xml->TREAD := hour_min(seconds())
    mo_xml->TIP_IN := _XML_FILE_SP // тип принимаемого файла;3-ФЛК,4-СП,5-РАК,6-РПД пишем в каталог XML_TF
    mo_xml->DWORK  := sys_date
    mo_xml->TWORK1 := cTimeBegin
    mo_xml->REESTR := mkod_reestr
    mo_xml->ANSREESTR := mANSREESTR
    mo_xml->KOL1 := ii1
    mo_xml->KOL2 := ii2
    //
    mXML_REESTR := mo_xml->KOD
    use
    if ii2 > 0
      if !p_ctrl_enter_sp_tk
        G_Use(dir_server+"mo_refr",dir_server+"mo_refr","REFR")
      endif
      //G_Use(dir_server+"mo_kfio",,"KFIO")
      //index on str(kod,7) to (cur_dir+"tmp_kfio")
    endif
    // открыть распакованный реестр
    use (cur_dir+"tmp_r_t1") new alias T1
    index on str(val(n_zap),6) to (cur_dir+"tmpt1")
    use (cur_dir+"tmp_r_t2") new alias T2
    index on IDCASE to (cur_dir+"tmpt2")
    use (cur_dir+"tmp_r_t3") new alias T3
    index on upper(ID_PAC) to (cur_dir+"tmpt3")
    use (cur_dir+"tmp_r_t4") new alias T4
    index on IDCASE to (cur_dir+"tmpt4")
    use (cur_dir+"tmp_r_t5") new alias T5
    index on IDCASE to (cur_dir+"tmpt5")
    //
    G_Use(dir_server+"mo_kfio",,"KFIO")
    index on str(kod,7) to (cur_dir+"tmp_kfio")
    G_Use(dir_server+"kartote2",,"KART2")
    G_Use(dir_server+"kartote_",,"KART_")
    G_Use(dir_server+"kartotek",dir_server+"kartoten","KART")
    set order to 0 // индекс открыт для реконструкции при перезаписи ФИО и даты рождения
    R_Use(dir_server+"mo_otd",,"OTD")
    G_Use(dir_server+"human_",,"HUMAN_")
    G_Use(dir_server+"human",{dir_server+"humann",dir_server+"humans"},"HUMAN")
    set order to 0 // индексы открыты для реконструкции при перезаписи ФИО
    set relation to recno() into HUMAN_, to otd into OTD
    G_Use(dir_server+"mo_rhum",,"RHUM")
    index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
    use (cur_dir+"tmp3file") new alias TMP3
    index on str(_n_zap,8) to (cur_dir+"tmp3")
    use (cur_dir+"tmp2file") new alias TMP2
    count_in_schet := lastrec() ; current_i2 := 0
    go top
    do while !eof()
      if tmp2->_OPLATA == 1
        select T1
        find (str(tmp2->_N_ZAP,6))
        if found()
          t1->VPOLIS := lstr(tmp2->_VPOLIS)
          t1->SPOLIS := tmp2->_SPOLIS
          t1->NPOLIS := tmp2->_NPOLIS
          t1->ENP    := tmp2->_ENP
          t1->SMO    := tmp2->_SMO
          t1->SMO_OK := tmp2->_SMO_OK
          t1->MO_PR  := tmp2->_MO_PR
        endif
      endif
      select RHUM
      find (str(tmp2->_N_ZAP,6))
      G_RLock(forever)
      rhum->OPLATA := tmp2->_OPLATA
      tmp2->kod_human := rhum->KOD_HUM
      select HUMAN
      goto (rhum->KOD_HUM)
      G_RLock(forever)
      human_->(G_RLock(forever))
      human_->OPLATA := tmp2->_OPLATA
      kart->(dbGoto(human->kod_k))
      fl_589 := .f.
      if tmp2->_OPLATA == 1
        human->POLIS   := make_polis(tmp2->_spolis,tmp2->_npolis)
        human_->VPOLIS := tmp2->_VPOLIS
        human_->SPOLIS := tmp2->_SPOLIS
        human_->NPOLIS := tmp2->_NPOLIS
        human_->OKATO  := tmp2->_SMO_OK
        if int(val(tmp2->_SMO)) != 34 // не иногородние
          human_->SMO := tmp2->_SMO
        endif
        if kart->za_smo == -9
          select KART
          G_RLock(forever)
          kart->za_smo := 0  // снять признак "Проблемы с полисом"
          dbUnLock()
        endif
        if !eq_any(tmp2->_MO_PR,space(6),replicate('0',6)) .or. !empty(tmp2->_enp) 
          select KART2
          do while kart2->(lastrec()) < human->kod_k
            APPEND BLANK
          enddo
          goto (human->kod_k)
          if empty(kart2->MO_PR)
            G_RLock(forever)
            if !eq_any(tmp2->_MO_PR,space(6),replicate('0',6)) 
              kart2->MO_PR := tmp2->_MO_PR
              kart2->TIP_PR := 2 // тип/статус прикрепления 2-из реестра СП и ТК
              kart2->DATE_PR := ldate_sptk
              if empty(kart2->pc4)
                kart2->pc4 := date_8(kart2->pc4)
              endif
            endif
            if !empty(tmp2->_enp)
              kart2->kod_mis := tmp2->_enp
            endif 
            dbUnLock()
          endif
        endif
      else // tmp2->_OPLATA == 2
        --count_in_schet    // не включается в счет,
        if !p_ctrl_enter_sp_tk
          human_->REESTR := 0 // а направляется на дальнейшее редактирование
          human_->ST_VERIFY := 0 // снова ещё не проверен
          if current_i2 == 0
            strfile(space(10)+"Список случаев с ошибками"+hb_eol()+hb_eol(),cFileProtokol,.t.)
          endif
          ++current_i2
          strfile(lstr(current_i2)+". "+alltrim(human->fio)+", "+;
                       full_date(human->date_r)+;
                       iif(empty(otd->SHORT_NAME), "", " ["+alltrim(otd->SHORT_NAME)+"]")+;
                       " "+date_8(human->n_data)+"-"+;
                       date_8(human->k_data)+hb_eol(),cFileProtokol,.t.)
          // изменение ФИО
          if !emptyall(tmp2->CORRECT,tmp2->_FAM,tmp2->_IM,tmp2->_OT,tmp2->_DR)
            arr_fio := retFamImOt(2,.f.,.t.)
            mdate_r := human->date_r
            s := ""
            //s := space(5)+"!Ошибки в персональных данных!"+eos
            if !empty(tmp2->_FAM)
              //s += space(5)+'старая фамилия "'+alltrim(arr_fio[1])+'", изменена на "'+alltrim(tmp2->_FAM)+'"'+eos 
              s += space(5)+'фамилия в нашей БД "'+alltrim(arr_fio[1])+'", в регистре ТФОМС "'+alltrim(tmp2->_FAM)+'"'+eos 
              arr_fio[1] := alltrim(tmp2->_FAM) 
            endif 
            if !empty(tmp2->_IM)
              //s += space(5)+'старое имя "'+alltrim(arr_fio[2])+'", изменено на "'+alltrim(tmp2->_IM)+'"'+eos 
              s += space(5)+'имя в нашей БД "'+alltrim(arr_fio[2])+'", в регистре ТФОМС "'+alltrim(tmp2->_IM)+'"'+eos 
              arr_fio[2] := alltrim(tmp2->_IM) 
            endif 
            if !emptyall(tmp2->CORRECT,tmp2->_OT)
              //s += space(5)+'старое отчество "'+alltrim(arr_fio[3])+'", изменено на "'+alltrim(tmp2->_OT)+'"'+eos 
              s += space(5)+'отчество в нашей БД "'+alltrim(arr_fio[3])+'", в регистре ТФОМС "'+alltrim(tmp2->_OT)+'"'+eos 
              arr_fio[3] := alltrim(tmp2->_OT) 
            endif 
            if !empty(tmp2->_DR)
              mdate_r := xml2date(tmp2->_DR)
              //s += space(5)+"старая дата рождения "+full_date(human->date_r)+", изменена на "+full_date(mdate_r)+eos 
              s += space(5)+"дата рождения в нашей БД "+full_date(human->date_r)+", в регистре ТФОМС "+full_date(mdate_r)+eos 
            endif
            //s += space(5)+"(исправлено - войти в редактирование л/у и подтвердить запись)"+eos
            //s += space(5)+"(исправляйте самостоятельно; в случае несогласия обращайтесь в отдел ТФОМС"+eos
            //s += space(5)+" по ведению регистра застрахованных лиц, тел.94-71-59, 95-87-88, 94-67-41)"+eos
            strfile(s,cFileProtokol,.t.)
            /*
            newMEST_INOG := 0
            if TwoWordFamImOt(arr_fio[1]) .or. TwoWordFamImOt(arr_fio[2]) .or. TwoWordFamImOt(arr_fio[3])
              newMEST_INOG := 9
            endif
            mfio := arr_fio[1]+" "+arr_fio[2]+" "+arr_fio[3]
            if kart->MEST_INOG == 9 .or. newMEST_INOG == 9
              select KFIO
              find (str(kart->kod,7))
              if found()
                if newMEST_INOG == 9
                  G_RLock(forever)
                  kfio->FAM := arr_fio[1]
                  kfio->IM  := arr_fio[2]
                  kfio->OT  := arr_fio[3]
                  dbUnLock()
                else
                  DeleteRec(.t.)
                endif
              else
                if newMEST_INOG == 9
                  AddRec(7)
                  kfio->kod := kart->kod
                  kfio->FAM := arr_fio[1]
                  kfio->IM  := arr_fio[2]
                  kfio->OT  := arr_fio[3]
                  dbUnLock()
                endif
              endif
            endif
            select KART
            G_RLock(forever)
            kart->fio := mfio
            kart->date_r := mdate_r
            kart->MEST_INOG := newMEST_INOG
            dbUnLock()
            select HUMAN
            G_RLock(forever)
            human->fio := mfio
            human->date_r := mdate_r
            dbUnLock()
            */
          endif
          select REFR
          do while .t.
            find (str(1,1)+str(mkod_reestr,6)+str(1,1)+str(rhum->KOD_HUM,8))
            if !found() ; exit ; endif
            DeleteRec(.t.)
          enddo
          select TMP3
          find (str(tmp2->_N_ZAP,8))
          do while tmp2->_N_ZAP == tmp3->_N_ZAP .and. !eof()
            select REFR
            AddRec(1)
            refr->TIPD := 1
            refr->KODD := mkod_reestr
            refr->TIPZ := 1
            refr->KODZ := rhum->KOD_HUM
            refr->IDENTITY := tmp2->_IDENTITY
            refr->REFREASON := tmp3->_REFREASON
            if empty(s := ret_t005(refr->REFREASON))
              strfile(space(5)+lstr(refr->REFREASON)+" неизвестная причина отказа"+;
                      hb_eol(),cFileProtokol,.t.)
            else
              if tmp3->_REFREASON == 562
                s += " (спец-ть врача "+ret_tmp_prvs(human_->PRVS)+")"
              elseif tmp3->_REFREASON == 589 .and. int(val(tmp2->_SMO)) > 0
                fl_589 := .t.
                s += " (в л/у и в карточке пациента исправлены полис и СМО - войти в редактирование л/у и подтвердить запись)"
              endif
              k := perenos(t_arr,s,75)
              for i := 1 to k
                strfile(space(5)+t_arr[i]+hb_eol(),cFileProtokol,.t.)
              next
            endif
            if eq_any(refr->REFREASON,57,59) .and. kart->za_smo != -9
              select KART
              G_RLock(forever)
              kart->za_smo := -9  // установить признак "Проблемы с полисом"
              dbUnLock()
            endif
            if refr->REFREASON == 513 .or. !eq_any(tmp2->_MO_PR,space(6),replicate('0',6))
              select KART2
              do while kart2->(lastrec()) < human->kod_k
                APPEND BLANK
              enddo
              goto (human->kod_k)
              if empty(kart2->MO_PR)
                G_RLock(forever)
                kart2->MO_PR := tmp2->_MO_PR
                kart2->TIP_PR := 2
                kart2->DATE_PR := ldate_sptk
                if empty(kart2->pc4)
                  kart2->pc4 := date_8(kart2->pc4)
                endif
                dbUnLock()
              endif
            endif
            select TMP3
            skip
          enddo
        endif
      endif
      UnLock ALL
      if fl_589
        select HUMAN
        G_RLock(forever)
        human->POLIS := make_polis(tmp2->_spolis,tmp2->_npolis)
        //
        human_->(G_RLock(forever))
        human_->VPOLIS := tmp2->_VPOLIS
        human_->SPOLIS := tmp2->_SPOLIS
        human_->NPOLIS := tmp2->_NPOLIS
        human_->SMO    := tmp2->_SMO
        human_->OKATO  := tmp2->_SMO_OK
        //
        select KART_
        goto (human->kod_k)
        G_RLock(forever)
        kart_->VPOLIS    := tmp2->_VPOLIS
        kart_->SPOLIS    := tmp2->_SPOLIS
        kart_->NPOLIS    := tmp2->_NPOLIS
        kart_->SMO       := tmp2->_SMO
        kart_->KVARTAL_D := tmp2->_SMO_OK
        //
        UnLock ALL
      endif
      select TMP2
      if recno() % 1000 == 0
        Commit
      endif
      skip
    enddo
  endif
endif
close databases
return count_in_schet

*

***** 09.05.16 создать счета по результатам прочитанного реестра СП
Function create_schet_from_XML(arr_XML_info,aerr,fl_msg,arr_s,name_sp_tk)
Static sa_usl
Local arr_schet := {}, c, len_stand, _arr_stand, lshifr, i, j, k, lbukva,;
      doplataF, doplataR, mnn, fl, name_zip, arr_zip := {}, lshifr1,;
      CODE_LPU := glob_mo[_MO_KOD_TFOMS], code_schet, mb, me, nsh,;
      CODE_MO  := glob_mo[_MO_KOD_FFOMS], s1
DEFAULT fl_msg TO .t., arr_s TO {},;
        sa_usl TO Uslugi_MKB_Standart() // закачаем массив ноз.форм (услуг по ним)
Private pole
//
use (cur_dir+"tmp1file") new alias TMP1
mdate_schet := tmp1->_DSCHET
nsh := f_mb_me_nsh(tmp1->_year,@mb,@me)
if tmp1->_year > 2016
  close databases
  return create_schet17_from_XML(arr_XML_info,aerr,fl_msg,arr_s,name_sp_tk)
endif
// составляем массив будущих счетов
// открыть распакованный реестр
use (cur_dir+"tmp_r_t1") new index (cur_dir+"tmpt1") alias T1
use (cur_dir+"tmp_r_t2") new index (cur_dir+"tmpt2") alias T2
use (cur_dir+"tmp_r_t3") new index (cur_dir+"tmpt3") alias T3
use (cur_dir+"tmp_r_t4") new index (cur_dir+"tmpt4") alias T4
use_base("lusld")
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
G_Use(dir_server+"schetd",,"SD")
use_base("human")
set order to 0
set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
use (cur_dir+"tmp2file") new alias TMP2
set relation to kod_human into HUMAN
index on upper(human->fio) to (cur_dir+"tmp2") for _OPLATA == 1
go top
do while !eof()
  c := " " ; doplataF := doplataR := 0
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
    lbukva := " "
    if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,@lbukva)
      if !empty(lbukva)
        c := lbukva
      endif
      lshifr := iif(empty(lshifr1), usl->shifr, lshifr1)
      if c == "M" // в листе учета д.б. одна услуга по ОМС = законченный случай
        susl := alltrim(lshifr)
        select LUSLD
        find (lshifr)
        do while lshifr == lusld->shifr .and. !eof()
          // поиск цены по дате окончания лечения
          if between_date(lusld->datebeg,lusld->dateend,human->k_data)
            doplataF := lusld->dopl_F // по ссылке вернём сумму фед.доплаты
            doplataR := lusld->dopl_R // по ссылке вернём сумму рег.доплаты
            exit
          endif
          skip
        enddo
      endif
    endif
    if !empty(c) ; exit ; endif
    select HU
    skip
  enddo
  if type("pr_array_schet") == "A" .and. empty(c)
    c := "A"   // искусственно для экспорта из БД Маслака
  endif        // случаев с отсутствующими услугами
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
  arr_schet[i,5] += doplataF
  if doplataR > 0
    arr_schet[i,6] ++
    arr_schet[i,7] += doplataR
  endif
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
    mn_schet := alltrim(arr_schet[ii,1])+"-"+alltrim(tmp1->_NSCHET)
    if (i := ascan(pr_array_schet, {|x| alltrim(x[3])==mn_schet .and. x[6]==tmp1->_year})) > 0
      arr_schet[ii,9] := pr_array_schet[i,2] // сюда запишем номер пакета
      arr_schet[ii,2] := " " // уберём букву
      arr_schet[ii,10] := i
    else
      if !empty(arr_schet[ii,2])
        mn_schet += arr_schet[ii,2]
      endif
      if (i := ascan(pr_array_schet, {|x| alltrim(x[3])==mn_schet .and. x[6]==tmp1->_year})) > 0
        arr_schet[ii,9] := pr_array_schet[i,2] // сюда запишем номер пакета
        arr_schet[ii,10] := i
      endif
    endif
    if arr_schet[ii,10] == 0
      my_debug(,lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" не найден счёт "+mn_schet)
    else
      i := arr_schet[ii,10]
      s := lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" "+padr(mn_schet,13)
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
        s := lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" "+padr(mn_schet,13)
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
index on smo+str(nn,3) to (cur_dir+"tmp_sch") ;
      for nyear==tmp1->_YEAR .and. nmonth==tmp1->_MONTH
fl := .f.
for i := 1 to len(arr_schet)
  fl := .f. ; sKodSMO := arr_schet[i,1]
  if arr_schet[i,9] > 0
    find (sKodSMO+str(arr_schet[i,9],3))
    if found() // номер уже занят
      arr_schet[i,9] := 0
    endif
  endif
  fl := (arr_schet[i,9] > 0)
  if !fl
    for mnn := mb to me
      if ascan(arr_schet, {|x| x[1]==sKodSMO .and. x[9]==mnn}) == 0
        find (sKodSMO+str(mnn,3))
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
  schet_->IS_MODERN  := iif(tmp1->_YEAR < 2013 .and. eq_any(arr_schet[ii,2],"M","D"), 1, 0) // является модернизацией, 1-да
  schet_->IS_DOPLATA := 0 // является доплатой;0-нет
  schet_->BUKVA      := arr_schet[ii,2]
  schet_->NSCHET     := mn_schet
  schet_->DSCHET     := mdate_schet
  schet_->SMO        := sKodSMO
  schet_->NYEAR      := tmp1->_YEAR
  schet_->NMONTH     := tmp1->_MONTH
  schet_->NN         := mnn
  schet_->NAME_XML   := "H"+s
  schet_->XML_REESTR := mXML_REESTR
  schet_->NREGISTR   := 1 // ещё не зарегистрирован
  schet_->CODE := ret_unique_code(mkod)
  code_schet := schet_->code
  //
  select MO_XML
  AddRecN()
  mo_xml->KOD    := recno()
  mo_xml->FNAME  := "H"+s
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
   if schet_->NYEAR < 2014
    mo_add_xml_stroke(oXmlNode,"VERSION" ,'1.2')
   else
    mo_add_xml_stroke(oXmlNode,"VERSION" ,'2.11')
   endif
    mo_add_xml_stroke(oXmlNode,"DATA"    ,date2xml(schet_->DSCHET))
    mo_add_xml_stroke(oXmlNode,"FILENAME",mo_xml->FNAME)
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
       mo_add_xml_stroke(oZAP,"PR_NOV",'0')
       oPAC := oZAP:Add( HXMLNode():New( "PACIENT" ) )
        mo_add_xml_stroke(oPAC,"ID_PAC",t1->ID_PAC)
        mo_add_xml_stroke(oPAC,"VPOLIS",t1->VPOLIS)
        if !empty(t1->SPOLIS)
          mo_add_xml_stroke(oPAC,"SPOLIS",t1->SPOLIS)
        endif
        mo_add_xml_stroke(oPAC,"NPOLIS",t1->NPOLIS)
        mo_add_xml_stroke(oPAC,"SMO"   ,t1->smo)
        mo_add_xml_stroke(oPAC,"SMO_OK",t1->SMO_OK)
        mo_add_xml_stroke(oPAC,"NOVOR",t1->NOVOR)
        mo_add_xml_stroke(oPAC,"MO_PR",t1->MO_PR)
        if !empty(t1->VNOV_D)
          mo_add_xml_stroke(oPAC,"VNOV_D",t1->VNOV_D)
        endif
       oSLUCH := oZAP:Add( HXMLNode():New( "SLUCH" ) )
        mo_add_xml_stroke(oSLUCH,"IDCASE",lstr(human_->schet_zap))
        mo_add_xml_stroke(oSLUCH,"ID_C"  ,t1->ID_C)
        mo_add_xml_stroke(oSLUCH,"USL_OK",t1->USL_OK)
        mo_add_xml_stroke(oSLUCH,"VIDPOM",t1->VIDPOM)
        if !empty(t1->FOR_POM)
          mo_add_xml_stroke(oSLUCH,"FOR_POM",t1->FOR_POM)
        endif
        if !empty(t1->VID_HMP)               
          if (s := alltrim(t1->VID_HMP)) == "14.00.26.003"
            s := "14.00.26.001"
          endif
          mo_add_xml_stroke(oSLUCH,"VID_HMP",s)
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
        if !empty(t1->EXTR)
          mo_add_xml_stroke(oSLUCH,"EXTR",t1->EXTR)
        endif
        mo_add_xml_stroke(oSLUCH,"LPU"     ,t1->LPU)
        mo_add_xml_stroke(oSLUCH,"PROFIL"  ,t1->PROFIL)
        mo_add_xml_stroke(oSLUCH,"DET"     ,t1->DET)
        mo_add_xml_stroke(oSLUCH,"NHISTORY",t1->NHISTORY)
        mo_add_xml_stroke(oSLUCH,"DATE_1"  ,t1->DATE_1)
        mo_add_xml_stroke(oSLUCH,"DATE_2"  ,t1->DATE_2)
        if !empty(t1->DS0)
          mo_add_xml_stroke(oSLUCH,"DS0"   ,t1->DS0)
        endif
        mo_add_xml_stroke(oSLUCH,"DS1"     ,t1->DS1)
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
        for j := 1 to 3
          pole := "t1->VNOV_M"+iif(j==1, "", "_"+lstr(j))
          if !empty(&pole)
            mo_add_xml_stroke(oSLUCH,"VNOV_M",&pole)
          endif
        next
        if !empty(t1->CODE_MES1)
          mo_add_xml_stroke(oSLUCH,"CODE_MES1",t1->CODE_MES1)
        endif
        mo_add_xml_stroke(oSLUCH,"RSLT"    ,t1->RSLT)
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
        if !empty(t1->IT_SL)
          mo_add_xml_stroke(oSLUCH,"IT_SL" ,t1->IT_SL)
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
          if !empty(t2->PODR)
            mo_add_xml_stroke(oUSL,"PODR"  ,t2->PODR)
          endif
          mo_add_xml_stroke(oUSL,"PROFIL"  ,t2->PROFIL)
          if !empty(t2->VID_VME)
            mo_add_xml_stroke(oUSL,"VID_VME",t2->VID_VME)
          endif
          mo_add_xml_stroke(oUSL,"DET"     ,t2->DET)
          mo_add_xml_stroke(oUSL,"DATE_IN" ,t2->DATE_IN)
          mo_add_xml_stroke(oUSL,"DATE_OUT",t2->DATE_OUT)
          mo_add_xml_stroke(oUSL,"DS"      ,t2->DS)
          mo_add_xml_stroke(oUSL,"CODE_USL",t2->CODE_USL)
          mo_add_xml_stroke(oUSL,"KOL_USL" ,t2->KOL_USL)
          mo_add_xml_stroke(oUSL,"TARIF"   ,t2->TARIF)
          mo_add_xml_stroke(oUSL,"SUMV_USL",t2->SUMV_USL)
          mo_add_xml_stroke(oUSL,"PRVS"    ,t2->PRVS)
          if !empty(t2->CODE_MD)
            mo_add_xml_stroke(oUSL,"CODE_MD",t2->CODE_MD)
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
      /*is_zak_sl := .f. ; is_zak_sl_vr := .f. ; lshifr_zak_sl := ""
      a_usl := {} ; a_fusl := {} ; kol_dn_stac := 0 ; lvidpom := 1
      lst := 0
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,,@lst)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if (i := ret_vid_pom(1,lshifr,human->k_data)) > 0
            lvidpom := i
          endif
          if eq_any(left(lshifr,4),"55.2","55.3","55.4") // старый дневной стационар
            kol_dn_stac += hu->KOL_1
          endif
          if lst == 1
            lshifr_zak_sl := lshifr
            if f_is_zak_sl_vr(lshifr) // зак.случай в п-ке
              is_zak_sl_vr := .t.
            elseif f_dn_stac_01_04(lshifr) .and. human->k_data >= d_01_04_2013 // дневной стационар с 1 апреля
              is_zak_sl_vr := .t.
            else
              is_zak_sl := .t. ; exit // в остальных случаях выйти из услуг
            endif
          else
            aadd(a_usl,hu->(recno()))
          endif
        endif
        select HU
        skip
      enddo
      select MOHU
      find (str(human->kod,7))
      do while mohu->kod == human->kod .and. !eof()
        aadd(a_fusl,mohu->(recno()))
        skip
      enddo
      mdiagnoz := diag_for_xml(,.t.,,,.t.)
      oZAP := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZAP" ) )
       mo_add_xml_stroke(oZAP,"N_ZAP" ,lstr(human_->schet_zap))
       mo_add_xml_stroke(oZAP,"PR_NOV",'0')
       oPAC := oZAP:Add( HXMLNode():New( "PACIENT" ) )
        mo_add_xml_stroke(oPAC,"ID_PAC",human_->ID_PAC)
        mo_add_xml_stroke(oPAC,"VPOLIS",lstr(human_->VPOLIS))
        if !empty(human_->SPOLIS)
          mo_add_xml_stroke(oPAC,"SPOLIS",human_->SPOLIS)
        endif
        mo_add_xml_stroke(oPAC,"NPOLIS",human_->NPOLIS)
        mo_add_xml_stroke(oPAC,"SMO"   ,tmp2->_SMO)  // !!!
        mo_add_xml_stroke(oPAC,"SMO_OK",human_->OKATO)
        if human_->NOVOR == 0
          mo_add_xml_stroke(oPAC,"NOVOR",lstr(human_->NOVOR))
        else
          mnovor := iif(human_->pol2=="М",'1','2')+;
                    strzero(day(human_->DATE_R2),2)+;
                    strzero(month(human_->DATE_R2),2)+;
                    right(lstr(year(human_->DATE_R2)),2)+;
                    strzero(human_->NOVOR,2)
          mo_add_xml_stroke(oPAC,"NOVOR",mnovor)
        endif
        mo_add_xml_stroke(oPAC,"MO_PR",replicate("0",6))
       oSLUCH := oZAP:Add( HXMLNode():New( "SLUCH" ) )
        mo_add_xml_stroke(oSLUCH,"IDCASE"  ,lstr(human_->schet_zap))
        mo_add_xml_stroke(oSLUCH,"ID_C"    ,human_->ID_C)
        mo_add_xml_stroke(oSLUCH,"USL_OK"  ,lstr(human_->USL_OK))
        mo_add_xml_stroke(oSLUCH,"VIDPOM"  ,lstr(lvidpom))
        if schet_->NYEAR < 2014 .and. human_->USL_OK == 4 // скорая помощь
          i := int(val(left(human_->FORMA14,1)))
          mo_add_xml_stroke(oSLUCH,"F_SP",lstr(i+1))
        endif
        if !empty(human_->NPR_MO) .and. ;
               !empty(mNPR_MO := ret_mo(human_->NPR_MO)[_MO_KOD_FFOMS])
          mo_add_xml_stroke(oSLUCH,"NPR_MO",mNPR_MO)
        endif
        if human_->USL_OK == 1 // стационар
          i := int(val(left(human_->FORMA14,1)))
          mo_add_xml_stroke(oSLUCH,"EXTR",lstr(i+1))
        endif
        mo_add_xml_stroke(oSLUCH,"LPU"     ,CODE_LPU)
        mo_add_xml_stroke(oSLUCH,"PROFIL"  ,lstr(human_->PROFIL))
        mo_add_xml_stroke(oSLUCH,"DET"     ,iif(human->VZROS_REB==0,'0','1'))
        mo_add_xml_stroke(oSLUCH,"NHISTORY",iif(empty(human->UCH_DOC),lstr(human->kod),human->UCH_DOC))
        mo_add_xml_stroke(oSLUCH,"DATE_1"  ,date2xml(human->N_DATA))
        mo_add_xml_stroke(oSLUCH,"DATE_2"  ,date2xml(human->K_DATA))
        if !empty(human_->kod_diag0)
          mo_add_xml_stroke(oSLUCH,"DS0"   ,human_->kod_diag0)
        endif
        mo_add_xml_stroke(oSLUCH,"DS1"     ,rtrim(mdiagnoz[1]))
        j := 0
        for i := 2 to len(mdiagnoz)
          if !empty(mdiagnoz[i])
            ++j
            mo_add_xml_stroke(oSLUCH,"DS2" ,rtrim(mdiagnoz[i]))
          endif
          if schet_->NYEAR < 2014 .and. j > 0 // в 2013 году только один сопут.диагноз
            exit
          endif
        next
        if schet_->NYEAR >= 2014   // ЕЩЁ ДИАГНОЗы ОСЛОЖНЕНИЯ ЗАБОЛЕВАНИЯ
          //mo_add_xml_stroke(oSLUCH,"DS3"   ,rtrim(mdiagnoz[2]))
        endif
        if is_zak_sl .or. is_zak_sl_vr
          mo_add_xml_stroke(oSLUCH,"CODE_MES1",lshifr_zak_sl)
        endif
        mo_add_xml_stroke(oSLUCH,"RSLT"    ,lstr(human_->RSLT_NEW))
        mo_add_xml_stroke(oSLUCH,"ISHOD"   ,lstr(human_->ISHOD_NEW))
        mo_add_xml_stroke(oSLUCH,"PRVS"    ,lstr(human_->PRVS))
        s := ""
        if retFamImOt(2)[3] == "НЕТ"
          s += '2'
        endif
        if eq_any(human->ishod,101,102) // ДДС
          s += lstr(human->ishod-101+3)
        elseif eq_any(human->ishod,201,202) // ДВН
          s += lstr(human->ishod-201+3)
        elseif eq_any(human->ishod,301,302) // ПН
          s += lstr(human->ishod-301+3)
        elseif eq_any(human->ishod,303,304) // ПредН
          s += lstr(human->ishod-303+3)
        endif
        if !empty(s)
          mo_add_xml_stroke(oSLUCH,"OS_SLUCH",s)
        endif
        mo_add_xml_stroke(oSLUCH,"IDSP"    ,lstr(human_->IDSP))
        if is_zak_sl .or. is_zak_sl_vr
          mo_add_xml_stroke(oSLUCH,"ED_COL",'1')
          mo_add_xml_stroke(oSLUCH,"TARIF" ,lstr(human->cena_1,10,2))
        endif
        mo_add_xml_stroke(oSLUCH,"SUMV"    ,lstr(human->cena_1,10,2))
        if !is_zak_sl
          if kol_dn_stac > 0 // для дневного стационара
            asize(a_usl,1)   // сводим всё в одну строку
          endif
          for j := 1 to len(a_usl)
            select HU
            goto (a_usl[j])
            hu_->(G_RLock(forever))
            hu_->SCHET_ZAP := ++iidserv
            lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
            lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
            oUSL := oSLUCH:Add( HXMLNode():New( "USL" ) )
            mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(hu_->SCHET_ZAP))
            mo_add_xml_stroke(oUSL,"ID_U"    ,hu_->ID_U)
            mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
            if hu->KOL_RCP < 0 .and. DomUslugaTFOMS(lshifr)
              mo_add_xml_stroke(oUSL,"PODR"  ,'0')
            endif
            mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(hu_->PROFIL))
            mo_add_xml_stroke(oUSL,"DET"     ,iif(human->VZROS_REB==0,'0','1'))
            mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(c4tod(hu->DATE_U)))
            mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(c4tod(hu_->DATE_U2)))
            mo_add_xml_stroke(oUSL,"DS"      ,hu_->kod_diag)
            mo_add_xml_stroke(oUSL,"CODE_USL",lshifr)
            if kol_dn_stac > 0 // дневной стационар, суммированный в одну строку
              mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(kol_dn_stac,6,2))
              mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(hu->U_CENA,10,2))
              mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(human->cena_1,10,2))
            else
              mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(hu->KOL_1,6,2))
              mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(hu->U_CENA,10,2))
              mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(hu->STOIM_1,10,2))
            endif
            mo_add_xml_stroke(oUSL,"PRVS"    ,lstr(hu_->PRVS))
          next
          UnLock
        endif
        if len(a_fusl) > 0
          for j := 1 to len(a_fusl)
            select MOHU
            goto (a_fusl[j])
            mohu->(G_RLock(forever))
            mohu->SCHET_ZAP := ++iidserv
            lshifr := alltrim(mosu->shifr1)
            oUSL := oSLUCH:Add( HXMLNode():New( "USL" ) )
            mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(mohu->SCHET_ZAP))
            mo_add_xml_stroke(oUSL,"ID_U"    ,mohu->ID_U)
            mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
            mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(mohu->PROFIL))
            mo_add_xml_stroke(oUSL,"DET"     ,iif(human->VZROS_REB==0,'0','1'))
            mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(c4tod(mohu->DATE_U)))
            mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(c4tod(mohu->DATE_U2)))
            mo_add_xml_stroke(oUSL,"DS"      ,mohu->kod_diag)
            mo_add_xml_stroke(oUSL,"CODE_USL",lshifr)
            mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(mohu->KOL_1,6,2))
            mo_add_xml_stroke(oUSL,"TARIF"   ,'0')//lstr(mohu->U_CENA,10,2))
            mo_add_xml_stroke(oUSL,"SUMV_USL",'0')//lstr(mohu->STOIM_1,10,2))
            mo_add_xml_stroke(oUSL,"PRVS"    ,lstr(mohu->PRVS))
          next
          UnLock
        endif*/
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
   if schet_->NYEAR < 2014
    mo_add_xml_stroke(oXmlNode,"VERSION" ,'1.2')
   else
    mo_add_xml_stroke(oXmlNode,"VERSION" ,'2.11')
   endif
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
      mo_add_xml_stroke(oPAC,"OT"    ,t3->OT)
      mo_add_xml_stroke(oPAC,"W"     ,t3->W)
      mo_add_xml_stroke(oPAC,"DR"    ,t3->DR)
      if !empty(t3->FAM_P)
        mo_add_xml_stroke(oPAC,"FAM_P",t3->FAM_P)
        mo_add_xml_stroke(oPAC,"IM_P" ,t3->IM_P)
        mo_add_xml_stroke(oPAC,"OT_P" ,t3->OT_P)
        mo_add_xml_stroke(oPAC,"W_P"  ,t3->W_P)
        mo_add_xml_stroke(oPAC,"DR_P" ,t3->DR_P)
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
      /*arr_fio := retFamImOt(2)
      otd->(dbGoto(human->otd))
      oPAC := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERS" ) )
      mo_add_xml_stroke(oPAC,"ID_PAC" ,human_->ID_PAC)
      if human_->NOVOR == 0
        mo_add_xml_stroke(oPAC,"FAM"  ,arr_fio[1])
        mo_add_xml_stroke(oPAC,"IM"   ,arr_fio[2])
        mo_add_xml_stroke(oPAC,"OT"   ,arr_fio[3])
        mo_add_xml_stroke(oPAC,"W"    ,iif(human->pol=="М",'1','2'))
        mo_add_xml_stroke(oPAC,"DR"   ,date2xml(human->date_r))
      else
        mo_add_xml_stroke(oPAC,"FAM"  ,"НЕТ")
        mo_add_xml_stroke(oPAC,"IM"   ,"НЕТ")
        mo_add_xml_stroke(oPAC,"OT"   ,"НЕТ")
        mo_add_xml_stroke(oPAC,"W"    ,iif(human_->pol2=="М",'1','2'))
        mo_add_xml_stroke(oPAC,"DR"   ,date2xml(human_->date_r2))
        mo_add_xml_stroke(oPAC,"FAM_P",arr_fio[1])
        mo_add_xml_stroke(oPAC,"IM_P" ,arr_fio[2])
        mo_add_xml_stroke(oPAC,"OT_P" ,arr_fio[3])
        mo_add_xml_stroke(oPAC,"W_P"  ,iif(human->pol=="М",'1','2'))
        mo_add_xml_stroke(oPAC,"DR_P" ,date2xml(human->date_r))
      endif
      if !empty(smr := del_spec_symbol(kart_->mesto_r))
        mo_add_xml_stroke(oPAC,"MR",smr)
      endif
      if human_->vpolis == 3 .and. empty(kart_->nom_ud)
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
      endif*/
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
// а теперь запишем счета по доплате
for ii := 1 to len(arr_schet)
  if arr_schet[ii,2] == "M"
    sKodSMO := alltrim(arr_schet[ii,1])
    for j := 1 to 2
      if j == 2 .and. empty(arr_schet[ii,6])
        exit  // если нет региональной доплаты - выход из цикла
      endif
      lbukva := iif(j==1,"F","B")
      mn_schet := sKodSMO+"-"+alltrim(tmp1->_NSCHET)+lbukva
      //
      lkol := iif(j==1,arr_schet[ii,3],arr_schet[ii,6])
      lsumma := iif(j==1,arr_schet[ii,5],arr_schet[ii,7])
      select SCHET
      AddRec(6)
      mkod := recno()
      schet->KOD := mkod
      schet->NOMER_S := mn_schet
      aadd(arr_s,mn_schet)
      schet->PDATE := dtoc4(mdate_schet)
      schet->KOL   := lkol
      schet->SUMMA := lsumma
      schet->KOL_OST   := lkol
      schet->SUMMA_OST := lsumma
      //
      select SCHET_
      do while schet_->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      schet_->IFIN       := iif(j==1,2,1) // источник финансирования;1-ТФОМС,2-ФФОМС
      schet_->IS_MODERN  := 0
      schet_->IS_DOPLATA := 1 // является доплатой;1-да
      schet_->BUKVA      := lbukva
      schet_->NSCHET     := mn_schet
      schet_->DSCHET     := mdate_schet
      schet_->SMO        := sKodSMO
      schet_->NYEAR      := tmp1->_YEAR
      schet_->NMONTH     := tmp1->_MONTH
      schet_->XML_REESTR := mXML_REESTR
      schet_->NREGISTR   := 1 // ещё не зарегистрирован
      schet_->CODE       := ret_unique_code(mkod)
      //
      strfile("Счёт на доплату "+mn_schet+" от "+date_8(mdate_schet)+" ("+;
              lstr(lkol)+" чел.) "+;
              inieditspr(A__MENUVERT,glob_arr_smo,int(val(sKodSMO)))+;
              hb_eol(),cFileProtokol,.t.)
      // записываем связь счёта на доплату с основным счётом
      select SD
      AddRecN()
      sd->kod := schet->KOD
      sd->kod2 := arr_schet[ii,8]
      UnLock
    next
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

*

***** 02.04.13 Просмотр списка счетов, запись для ТФОМС, печать счетов
Function view_list_schet()
Local i, k, buf := savescreen(), tmp_help := chm_help_code, mdate := stod("20130101")
mywait()
close databases
R_Use(dir_server+"mo_rees",,"REES")
G_Use(dir_server+"mo_xml",,"MO_XML")
G_Use(dir_server+"schet_",,"SCHET_")
G_Use(dir_server+"schet",dir_server+"schetd","SCHET")
set relation to recno() into SCHET_
dbseek(dtoc4(mdate),.t.)
index on dtos(schet_->dschet)+fsort_schet(schet_->nschet,nomer_s) to (cur_dir+"tmp_sch") ;
      for schet_->dschet >= mdate .and. !empty(pdate) .and.;
          (schet_->IS_DOPLATA==1 .or. !empty(val(schet_->smo))) ;
      DESCENDING
go top
if eof()
  restscreen(buf)
  close databases
  return func_error(4,"Нет выписанных счетов c "+date_month(mdate))
endif
chm_help_code := 122
box_shadow(maxrow()-3,0,maxrow()-1,79,color0)
Alpha_Browse(T_ROW,0,maxrow()-4,79,"f1_view_list_schet",color0,,,,,,"f21_view_list_schet",;
             "f2_view_list_schet",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,RB/BG,GR/BG",.t.,60} )
close databases
chm_help_code := tmp_help
restscreen(buf)
return NIL

*****
Function f1_view_list_schet(oBrow)
Local s, oColumn, ;
   blk := {|| iif(!empty(schet_->NAME_XML).and.empty(schet_->date_out), {3,4}, {1,2}) }
oColumn := TBColumnNew("Номер счета",{|| schet_->nschet })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Дата",{|| date_8(schet_->dschet) })
oColumn:colorBlock := {|| f23_view_list_schet() }
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Пе-;риод",;
          {|| iif(emptyany(schet_->nyear,schet_->nmonth), ;
                  space(5), ;
                  right(str(schet_->nyear,4),2)+"/"+strzero(schet_->nmonth,2)) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Сумма счета",{|| put_kop(schet->summa,13) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Кол.;бол.", {|| str(schet->kol,4) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Критерий", {|| padr(f3_view_list_schet(),10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Принадлежность;счета",{|| padr(f4_view_list_schet(),14) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  ",{|| f22_view_list_schet() })
oColumn:colorBlock := {|| f23_view_list_schet() }
oBrow:addColumn(oColumn)
status_key("^<Esc>^ - выход;  ^<F5>^ - запись счетов за день;  ^<F9>^ - печать счёта/реестра")
return NIL

*****
Function f21_view_list_schet()
Local s := "", fl := .t., r := row(), c := col()
if !emptyany(schet_->name_xml,schet_->kod_xml)
  fl := hb_FileExists(dir_server+dir_XML_MO+cslash+alltrim(schet_->name_xml)+szip)
  s := iif(fl,"XML-файл: ","Нет XML-файла: ")+alltrim(schet_->name_xml)
  mo_xml->(dbGoto(schet_->XML_REESTR))
  if mo_xml->REESTR > 0
    rees->(dbGoto(mo_xml->REESTR))
    s += ", по реестру № "+lstr(rees->NSCHET)+" от "+;
         date_8(rees->DSCHET)+"г. ("+lstr(rees->KOL)+" чел.)"
  endif
endif
@ maxrow()-2,1 say padc(s,78) color iif(fl,color0,"R/BG")
setpos(r,c)
return NIL

*****
Function f22_view_list_schet()
Local s := "  "
if schet_->NREGISTR == 1 // ещё не зарегистрирован
  s := ""
elseif schet_->NREGISTR == 2 // не будет зарегистрирован
  s := "▄▀"
elseif schet_->NREGISTR == 3 // удалён
  s := "--"
endif
return s

*****
Function f23_view_list_schet()
Local arr := iif(!empty(schet_->NAME_XML).and.empty(schet_->date_out), {3,4}, {1,2})
if schet_->NREGISTR == 1 // ещё не зарегистрирован
  arr[1] := 5
elseif schet_->NREGISTR == 2 // не будет зарегистрирован
  arr[1] := 6
elseif schet_->NREGISTR == 3 // удалён
  arr[1] := 7
endif
return arr

*

***** 02.04.13
Function f2_view_list_schet(nKey,oBrow)
Local ret := -1, rec := schet->(recno()), tmp_color := setcolor(), r, r1, r2,;
      s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
do case
  case nKey == K_F5
    r := row()
    arr := {} ; k := 0 ; mdate := schet_->dschet
    find (dtos(mdate))
    do while schet_->dschet == mdate .and. !eof()
      if !emptyany(schet_->name_xml,schet_->kod_xml)
        aadd(arr, {schet_->nschet,schet_->name_xml,schet_->kod_xml,schet->(recno())})
        if empty(schet_->date_out)
          ++k
        endif
      endif
      skip
    enddo
    if len(arr) == 0
      func_error(4,"Нечего записывать!")
    else
      if len(arr) > 1
        asort(arr,,,{|x,y| x[1] < y[1]})
        for i := 1 to len(arr)
          schet->(dbGoto(arr[i,4]))
          aadd(arr_pmt, {"Счёт № "+alltrim(schet_->nschet)+" ("+;
                         lstr(schet_->nyear)+"/"+strzero(schet_->nmonth,2)+;
                         ") файл "+alltrim(schet_->name_xml),aclone(arr[i])})
        next
        if r+2+len(arr) > maxrow()-2
          r2 := r-1
          r1 := r2-len(arr)-1
          if r1 < 0 ; r1 := 0 ; endif
        else
          r1 := r+1
        endif
        arr := {}
        if (t_arr := bit_popup(r1,10,arr_pmt,,color5,1,"Записываемые файлы счетов ("+date_8(mdate)+")","B/W")) != NIL
          aeval(t_arr, {|x| aadd(arr,aclone(x[2])) })
        endif
        t_arr := array(2)
      endif
      if len(arr) > 0
        s := "Количество счетов - "+lstr(len(arr))+;
             ", записываются в первый раз - "+lstr(k)+":"
        for i := 1 to len(arr)
          if i > 1
            s += ","
          endif
          s += " "+alltrim(arr[i,1])+" ("+alltrim(arr[i,2])+szip+")"
        next
        perenos(t_arr,s,74)
        f_message(t_arr,,color1,color8)
        if f_Esc_Enter("записи счетов за "+date_8(mdate)+"г.")
          Private p_var_manager := "copy_schet"
          s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" для выбора каталога
          if !empty(s)
            goal_dir := dir_server+dir_XML_MO+cslash
            if upper(s) == upper(goal_dir)
              func_error(4,"Вы выбрали каталог, в котором уже записаны целевые файлы! Это недопустимо.")
            else
              cFileProtokol := "prot_sch"+stxt
              strfile(hb_eol()+center(glob_mo[_MO_SHORT_NAME],80)+hb_eol()+hb_eol(),cFileProtokol)
              smsg := "Счета записаны на: "+s+;
                      " ("+full_date(sys_date)+"г. "+hour_min(seconds())+")"
              strfile(center(smsg,80)+hb_eol(),cFileProtokol,.t.)
              k := 0
              for i := 1 to len(arr)
                zip_file := alltrim(arr[i,2])+szip
                if hb_fileExists(goal_dir+zip_file)
                  mywait('Копирование "'+zip_file+'" в каталог "'+s+'"')
                  //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
                  copy file (goal_dir+zip_file) to (s+zip_file)
                  //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
                  if hb_fileExists(s+zip_file)
                    ++k
                    schet->(dbGoto(arr[i,4]))
                    smsg := lstr(i)+". Счёт № "+alltrim(schet_->nschet)+;
                            " от "+date_8(mdate)+"г. (отч.период "+;
                             lstr(schet_->nyear)+"/"+strzero(schet_->nmonth,2)+;
                             ") "+alltrim(schet_->name_xml)+szip
                    strfile(hb_eol()+smsg+hb_eol(),cFileProtokol,.t.)
                    smsg := "   количество пациентов - "+lstr(schet->kol)+;
                            ", сумма счёта - "+expand_value(schet->summa,2)
                    strfile(smsg+hb_eol(),cFileProtokol,.t.)
                    schet_->(G_RLock(forever))
                    schet_->DATE_OUT := sys_date
                    if schet_->NUMB_OUT < 99
                      schet_->NUMB_OUT ++
                    endif
                    //
                    mo_xml->(dbGoto(arr[i,3]))
                    mo_xml->(G_RLock(forever))
                    mo_xml->DREAD := sys_date
                    mo_xml->TREAD := hour_min(seconds())
                  else
                    smsg := "! Ошибка записи файла "+s+zip_file
                    func_error(4,smsg)
                    strfile(smsg+hb_eol(),cFileProtokol,.t.)
                  endif
                else
                  smsg := "! Не обнаружен файл "+goal_dir+zip_file
                  func_error(4,smsg)
                  strfile(smsg+hb_eol(),cFileProtokol,.t.)
                endif
              next
              UnLock
              Commit
              viewtext(cFileProtokol,,,,.t.,,,2)
              /*asize(t_arr,1)
              perenos(t_arr,"Записано счетов - "+lstr(k)+" в каталог "+s+;
                     iif(k == len(arr), "", ", не записано счетов - "+lstr(len(arr)-k)),60)
              stat_msg("Запись завершена!")
              n_message(t_arr,,"GR+/B","W+/B",18,,"G+/B")*/
            endif
          endif
        endif
      endif
    endif
    select SCHET
    goto (rec)
    ret := 0
  case nKey == K_F9
    print_schet(oBrow)
    select SCHET
    ret := 0
  case nKey == K_CTRL_F11 .and. !empty(schet_->NAME_XML) .and. schet_->XML_REESTR > 0
    k := schet_->XML_REESTR // ссылка на реестр СП и ТК
    arr := {}
    go top
    do while !eof()
      if !emptyany(schet_->name_xml,schet_->kod_xml) .and. k == schet_->XML_REESTR
        aadd(arr,schet->(recno()))
      endif
      skip
    enddo
    if len(arr) == 0
      func_error(4,"Нечего записывать!")
    else
      if len(arr) > 1
        for i := 1 to len(arr)
          schet->(dbGoto(arr[i]))
          aadd(arr_pmt, {"Счёт № "+alltrim(schet_->nschet)+" ("+;
                         lstr(schet_->nyear)+"/"+strzero(schet_->nmonth,2)+;
                         ") файл "+alltrim(schet_->name_xml),arr[i]})
        next
        r := row()
        if r+2+len(arr) > maxrow()-2
          r2 := r-1
          r1 := r2-len(arr)-1
          if r1 < 0 ; r1 := 0 ; endif
        else
          r1 := r+1
        endif
        arr := {}
        if (t_arr := bit_popup(r1,10,arr_pmt,,"N/W*,GR+/R",1,"Пересоздаваемые файлы счетов","B/W*")) != NIL
          aeval(t_arr, {|x| aadd(arr,x[2]) })
        endif
      endif
      if len(arr) > 0
        ReCreate_some_Schet_From_FILE_SP(arr)
        close databases
        R_Use(dir_server+"mo_rees",,"REES")
        G_Use(dir_server+"mo_xml",,"MO_XML")
        G_Use(dir_server+"schet_",,"SCHET_")
        G_Use(dir_server+"schet",dir_server+"schetd","SCHET")
        set relation to recno() into SCHET_
        go top
        ret := 1
      endif
    endif
  case nKey == K_CTRL_F12 .and. !empty(schet_->NAME_XML) ;
                          .and. schet_->XML_REESTR > 0
    ReCreate_some_Schet_From_FILE_SP({schet->(recno())})
    close databases
    R_Use(dir_server+"mo_rees",,"REES")
    G_Use(dir_server+"mo_xml",,"MO_XML")
    G_Use(dir_server+"schet_",,"SCHET_")
    G_Use(dir_server+"schet",dir_server+"schetd","SCHET")
    set relation to recno() into SCHET_
    go top
    ret := 1
endcase
setcolor(tmp_color)
restscreen(buf)
return ret

*

***** 26.04.15
Function f3_view_list_schet()
Local s := ""
if schet_->nyear < 2013 .and. schet_->IS_MODERN == 1 // является модернизацией?;0-нет, 1-да для IFIN=1
  s := "модернизация"
endif
if schet_->IS_DOPLATA == 1 // является доплатой?;0-нет, 1-да для IFIN=1 или 2
  s := "допл."
  if schet_->IFIN == 1
    s += "ТФОМС"
  elseif schet_->IFIN == 2
    s += "ФФОМС"
  endif
endif
if empty(s) .and. schet_->IFIN > 0
  s := "ОМС "
  if schet_->bukva     == "A"
    s += "п-ка"
  elseif schet_->bukva == "D"
    s += "ДДС"
  elseif schet_->bukva == "E"
    s += "СМП"
  elseif schet_->bukva == "F"
    s += "Нпроф."
  elseif schet_->bukva == "G"
    s += "дермат"
  elseif schet_->bukva == "H"
    s += "ВМП"
  elseif schet_->bukva == "I"
    s += "Нперио"
  elseif schet_->bukva == "J"
    s += "п-ка"
  elseif schet_->bukva == "K"
    s += "о/м/у"
  elseif schet_->bukva == "M"
    s += "зак/с"
  elseif schet_->bukva == "O"
    s += "ВНдисп"
  elseif schet_->bukva == "R"
    s += "ВНпроф"
  elseif schet_->bukva == "S"
    s += "стац."
  elseif schet_->bukva == "T"
    s += "стомат"
  elseif schet_->bukva == "U"
    s += "ДДСоп"
  elseif schet_->bukva == "V"
    s += "Нпред."
  elseif schet_->bukva == "Z"
    s += "дн/ст."
  elseif schet_->IFIN == 1
    s += "ТФОМС"
  elseif schet_->IFIN == 2
    s += "ФФОМС"
  endif
endif
return s

*****
Function f4_view_list_schet(lkomu,lsmo,lstr_crb)
Local s := ""
DEFAULT lkomu TO schet->komu, lsmo TO schet_->smo, lstr_crb TO schet->str_crb
if lkomu == 5
  s := "Личный счёт"
elseif !empty(lsmo)
  s := inieditspr(A__MENUVERT, glob_arr_smo, int(val(lsmo)))
  if empty(s)
    s := inieditspr(A__POPUPMENU, dir_server+"str_komp", lstr_crb)
    if empty(s)
      s := lsmo
    endif
  endif
elseif lkomu == 1
  s := inieditspr(A__POPUPMENU, dir_server+"str_komp", lstr_crb)
elseif lkomu == 3
  s := inieditspr(A__POPUPMENU, dir_server+"komitet", lstr_crb)
endif
return s

***** для совместимости со старой версией программы
Function func1_komu(lkomu,lstr_crb)
return f4_view_list_schet(lkomu,"",lstr_crb)

*

*****
Function print_schet(oBrow)
Static si := 1
Local i, r := row(), r1, r2, mm_menu := {}
if schet_->IS_DOPLATA == 1 // является доплатой?;0-нет, 1-да для IFIN=1 или 2
  if schet_->IFIN == 1  // "ТФОМС"
    print_schet_doplata(1)
  elseif schet_->IFIN == 2 // "ФФОМС"
    print_schet_doplata(2)
  endif
elseif !empty(val(schet_->smo))
  for i := 1 to 2
    aadd(mm_menu, "Печать "+iif(i==1,"","реестра ")+"счёта на оплату медицинской помощи")
  next
  if r <= maxrow()/2
    r1 := r+1 ; r2 := r1+3
  else
    r2 := r-1 ; r1 := r2 - 3
  endif
  if (i := popup_prompt(r1,10,si,mm_menu,,,color5)) > 0
    si := i
    print_schet_S(i)
  endif
else
  print_other_schet(1)
endif
return NIL

*

***** 07.08.16 печать счета
Function print_schet_S(reg)
Local adbf, j, s, ii := 0, fl_numeration := .f., buf := save_maxrow(),;
      lshifr1, ldate1, ldate2, hGauge
mywait()
delFRfiles()
adbf := {{"name","C",130,0},;
         {"name_schet","C",130,0},;
         {"adres","C",110,0},;
         {"ogrn","C",15,0},;
         {"inn","C",12,0},;
         {"kpp","C",9,0},;
         {"bank","C",130,0},;
         {"r_schet","C",45,0},;
         {"bik","C",10,0},;
         {"ruk","C",20,0},;
         {"bux","C",20,0},;
         {"ispolnit","C",20,0},;
         {"plat","C",250,0},;
         {"nschet","C",20,0},;
         {"dschet","C",30,0},;
         {"date_begin","C",30,0},;
         {"date_end","C",30,0},;
         {"date_podp","C",13,0},;
         {"susluga","C",250,0},;
         {"summa","N",15,2}}
dbcreate(fr_titl, adbf)
R_Use(dir_server+"organiz",,"ORG")
use (fr_titl) new alias FRT
append blank
frt->name := frt->name_schet := org->name
if !empty(org->name_schet)
  frt->name_schet := org->name_schet
endif
s := alltrim(org->adres)
if !empty(charrem("-",org->telefon))
  s += " тел."+alltrim(org->telefon)
endif
frt->adres := s
frt->ogrn := org->ogrn
sinn := org->inn ; skpp := ""
if "/" $ sinn
  skpp := afteratnum("/",sinn)
  sinn := beforatnum("/",sinn)
endif
frt->inn := sinn
frt->kpp := skpp
frt->bank := org->bank
frt->r_schet := org->r_schet
frt->bik := org->smfo
frt->ruk := org->ruk
frt->bux := org->bux
frt->ispolnit := org->ispolnit
frt->date_podp := full_date(sys_date)+" г."
s := ""
if (j := ascan(arr_rekv_smo,{|x| x[1]==schet_->SMO})) > 0
  s := arr_rekv_smo[j,2]
  if reg == 2 .and. int(val(schet_->SMO)) == 34 // иногородние !
    reg := 3
  endif
elseif schet->str_crb > 0
  if schet->komu == 3
    s := inieditspr(A__POPUPMENU, dir_server+"komitet", schet->str_crb)
  else
    s := inieditspr(A__POPUPMENU, dir_server+"str_komp", schet->str_crb)
  endif
endif
frt->plat := s
frt->nschet := schet_->nschet
frt->dschet := date_month(schet_->dschet)
s := "За медицинскую помощь, оказанную "
if !empty(schet_->SMO)
  s += "застрахованным лицам "
endif
if !emptyany(schet_->nyear,schet_->nmonth)
  s += "за "+mm_month[schet_->nmonth]+str(schet_->nyear,5)+" года"
  ldate := stod(strzero(schet_->nyear,4)+strzero(schet_->nmonth,2)+"01")
  frt->date_begin := date_month(ldate)
  frt->date_end   := date_month(eom(ldate))
else
  s := "За оказанную медицинскую помощь"
  fl_numeration := .t.
endif
frt->susluga := s
frt->summa := schet->summa
org->(dbCloseArea())
rest_box(buf)
//
if reg > 1
  hGauge := GaugeNew(,,{"GR+/RB","BG+/RB","G+/RB"},"Составление счёта",.t.)
  GaugeDisplay( hGauge )
  adbf := {{"nomer","N",4,0},;
           {"fio","C",50,0},;
           {"pol","C",10,0},;
           {"date_r","C",10,0},;
           {"mesto_r","C",100,0},;
           {"pasport","C",50,0},;
           {"adresp","C",250,0},;
           {"adresg","C",250,0},;
           {"snils","C",50,0},;
           {"polis","C",50,0},;
           {"vid_pom","C",10,0},;
           {"diagnoz","C",10,0},;
           {"n_data","C",10,0},;
           {"k_data","C",10,0},;
           {"ob_em","N",5,0},;
           {"profil","C",10,0},;
           {"vrach","C",10,0},;
           {"cena","N",12,2},;
           {"stoim","N",12,2},;
           {"rezultat","C",10,0}}
  dbcreate(fr_data,adbf)
  use (fr_data) new alias FRD
  index on str(nomer,4) to (fr_data)
  use_base("lusl")
  R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                              dir_server+"uslugi1s"},"USL1")
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  set relation to u_kod into USL
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humans","HUMAN")
  set relation to recno() into HUMAN_, to kod_k into KART
  Select HUMAN
  find (str(schet->kod,6))
  do while human->schet == schet->kod .and. !eof()
    GaugeUpdate( hGauge, ++ii/schet->kol )
    ldate1 := iif(ldate1==nil, human->k_data, min(ldate1,human->k_data))
    ldate2 := iif(ldate2==nil, human->k_data, max(ldate2,human->k_data))
    a_diag := diag_for_xml(,.t.,,,.t.)
    is_zak_sl := is_zak_sl_d := is_zak_sl_v := .f.
    lst := kol_dn := mcena := 0 ; lvidpom := 1 ; au := {}
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
      if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,,@lst)
        lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
        if (i := ret_vid_pom(1,lshifr,human->k_data)) > 0
          lvidpom := i
        endif
        if left(lshifr,5) == "55.1." // дневной стационар с 1 апреля 2013 года
          kol_dn += hu->KOL_1
        elseif eq_any(left(lshifr,4),"55.2","55.3","55.4") // старый дневной стационар
          kol_dn += hu->KOL_1 ; mcena := hu->u_cena
        elseif left(lshifr,2) == "1."
          kol_dn += hu->KOL_1 ; mcena := hu->u_cena
        endif
        if lst == 1
          if left(lshifr,2) == "1."
            is_zak_sl := .t. ; mcena := hu->u_cena
          elseif left(lshifr,3) == "55."
            if human->k_data < d_01_04_2013 // дневной стационар до 1 апреля
              is_zak_sl_d := .t.
            endif
            mcena := hu->u_cena
          elseif f_is_zak_sl_vr(lshifr) // зак.случай в п-ке
            is_zak_sl_v := .t. ; mcena := hu->u_cena
          endif
        else
          j := ascan(au,{|x| x[1]==lshifr .and. x[2]==hu->date_u })
          if j == 0
            aadd(au,{lshifr,hu->date_u,0,hu->u_cena})
            j := len(au)
          endif
          au[j,3] += hu->kol_1
        endif
      endif
      select HU
      skip
    enddo
    if is_zak_sl
      kol_dn := human->k_data - human->n_data
    elseif is_zak_sl_d
      kol_dn := human->k_data - human->n_data + 1
    elseif is_zak_sl_v
      for j := 1 to len(au)
        if left(au[j,1],2) == "2."
          kol_dn += au[j,3]
        endif
      next
    elseif empty(kol_dn)
      for j := 1 to len(au)
        kol_dn += au[j,3]
      next
      if kol_dn > 0
        mcena := round_5(human->cena_1/kol_dn,2)
        if !(round(mcena,2) == round(au[1,4],2))
          kol_dn := mcena := 0
        endif
      endif
    endif
    select FRD
    append blank
    frd->nomer := iif(fl_numeration, ii, human_->SCHET_ZAP)
    frd->fio := human->fio
    frd->pol := iif(human->pol=="М","муж","жен")
    frd->date_r := full_date(human->date_r)
    frd->mesto_r := kart_->mesto_r
    s := ""
    if (j := ascan(menu_vidud, {|x| x[2] == kart_->vid_ud})) > 0
      s := menu_vidud[j,4]+" "
    endif
    if !empty(kart_->ser_ud)
      s += alltrim(kart_->ser_ud)+" "
    endif
    if !empty(kart_->nom_ud)
      s += alltrim(kart_->nom_ud)
    endif
    frd->pasport := s
    frd->adresg := ret_okato_ulica(kart->adres,kart_->okatog,0,2)
    if empty(kart_->okatop)
      frd->adresp := frd->adresg
    else
      frd->adresp := ret_okato_ulica(kart_->adresp,kart_->okatop,0,2)
    endif
    if !empty(kart->snils)
      frd->snils := transform(kart->SNILS,picture_pf)
    endif
    frd->polis := alltrim(alltrim(human_->SPOLIS)+" "+human_->NPOLIS)
    frd->vid_pom := lstr(lvidpom)
    frd->diagnoz := a_diag[1]
    frd->n_data := full_date(human->n_data)
    frd->k_data := full_date(human->k_data)
    frd->ob_em := kol_dn
    if human_->PROFIL > 0
      frd->profil := lstr(human_->PROFIL)
    endif
    if !empty(human_->PRVS)
      frd->vrach := lstr(abs(human_->PRVS))
    endif
    frd->cena := mcena
    frd->stoim := human->cena_1
    frd->rezultat := lstr(human_->RSLT_NEW)
    //
    Select HUMAN
    skip
  enddo
  lusl->(dbCloseArea())
  lusl17->(dbCloseArea())
  usl1->(dbCloseArea())
  usl->(dbCloseArea())
  hu->(dbCloseArea())
  kart_->(dbCloseArea())
  kart->(dbCloseArea())
  human_->(dbCloseArea())
  human->(dbCloseArea())
  frd->(dbCloseArea())
  if fl_numeration .and. !emptyany(ldate1,ldate2)
    frt->date_begin := date_month(ldate1)
    frt->date_end   := date_month(ldate2)
  endif
  CloseGauge(hGauge)
endif
frt->(dbCloseArea())
do case
  case reg == 1
    call_fr("mo_schet")
  case reg == 2
    call_fr("mo_reesv")
  case reg == 3
    call_fr("mo_reesi")
endcase
select SCHET
return NIL

*

***** Просмотр и печать выписанных счетов/реестров на доплату
Function print_schet_doplata(reg)
// reg = 1 - доплата ТФОМС
// reg = 2 - доплата ФФОМС
Local arr_title, arr1title, sh, HH := 57, n_file := "schetd"+stxt,;
      s, i, j, j1, a_shifr[10], k1, k2, k3, lshifr, v_doplata, rec,;
      buf := save_maxrow(), t_arr[2], llpu, lbank, ssumma := 0,;
      fl_numeration, is_20_11, sdate := stod("20121120") // 20.11.2012г.
if schet_->NREGISTR == 0 // зарегистрированные счета
  is_20_11 := (date_reg_schet() >= sdate)
else
  is_20_11 := (schet_->DSCHET > stod("20121210")) // 10.12.2012г.
endif
s1 := iif(reg==2,space(11),"и сопутст. ")
s2 := iif(reg==2,space(11),"диагноза   ")
arr_title := {;
"────┬───────────────┬────────────┬────────┬──────────┬───────────┬──────────────",;
"№   │№ счета по ОМС │№ страхового│Дата    │Код       │Код        │Доплата по    ",;
"пози│               │случая в    │счета по│закончен- │основного  │данной услуге ",;
"ции │               │счете по ОМС│ОМС     │ного      │диагноза   │из средств    ",;
"реес│               │            │        │случая    │"+s1+     "│бюджета "+iif(reg==2,"ФФОМС ","ТФОМС "),;
"тра │               │            │        │          │"+s2+     "│(рублей)      ",;
"────┼───────────────┼────────────┼────────┼──────────┼───────────┼──────────────",;
" 1  │       2       │      3     │   4    │    5     │     6     │       7      ",;
"────┴───────────────┴────────────┴────────┴──────────┴───────────┴──────────────"}
  arr1title := {;
"────┬───────────────┬────────────┬────────┬──────────┬───────────┬──────────────",;
" 1  │       2       │      3     │   4    │    5     │     6     │       7      ",;
"────┴───────────────┴────────────┴────────┴──────────┴───────────┴──────────────"}
//
use_base("lusl")
use_base("lusld")
use_base("luslf")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to u_kod into USL
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to recno() into HUMAN_
R_Use(dir_server+"organiz",,"ORG")
R_Use(dir_server+"schetd",,"SD")
index on str(kod,6) to (cur_dir+"tmp_sd")
//
sh := len(arr_title[1])
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(center("Счет № "+alltrim(schet_->nschet)+" от "+full_date(schet_->dschet)+" г.",sh))
s := "на оплату медицинской помощи за счет средств бюджета "+iif(reg==2,"Федерального","Территориального")+" фонда "
s += "обязательного медицинского страхования "+iif(reg==2,"","Волгоградской области ")+"по Программе модернизации здравоохранения "
s += "Волгоградской области на 2011-2012 годы в части реализации мероприятий по "
s += "поэтапному внедрению стандартов медицинской помощи"
for k := 1 to perenos(t_arr,s,sh)
  add_string(center(alltrim(t_arr[k]),sh))
next
add_string("")
sinn := org->inn ; skpp := ""
if "/" $ sinn
  skpp := afteratnum("/",sinn)
  sinn := beforatnum("/",sinn)
endif
sname    := org->name
sbank    := org->bank
sr_schet := org->r_schet
sbik     := org->smfo
if reg==2
  if !empty(org->r_schet2)
    sbank    := org->bank2
    sr_schet := org->r_schet2
    sbik     := org->smfo2
  endif
  if !empty(org->name2)
    sname := org->name2
  endif
endif
k := perenos(t_arr,sname,sh-11)
add_string("Поставщик: "+t_arr[1])
for i := 2 to k
  add_string(space(11)+t_arr[2])
next
add_string("ИНН: "+padr(sinn,12)+", КПП: "+skpp)
add_string("Адрес: "+rtrim(org->adres))
k := perenos(t_arr,sbank,sh-17)
add_string("Банк поставщика: "+t_arr[1])
for i := 2 to k
  add_string(space(17)+t_arr[2])
next
add_string("Расчетный счет: "+alltrim(sr_schet)+", БИК: "+alltrim(sbik))
add_string("")
add_string("")
if (j := ascan(arr_rekv_smo,{|x| x[1]==schet_->SMO})) == 0
  j := len(arr_rekv_smo) // если не нашли - печатаем реквизиты ТФОМС
endif
k := perenos(t_arr,arr_rekv_smo[j,2],sh-12)
add_string("Плательщик: "+t_arr[1])
for i := 2 to k
  add_string(space(12)+t_arr[2])
next
add_string("ИНН: "+arr_rekv_smo[j,3]+", КПП: "+arr_rekv_smo[j,4])
k := perenos(t_arr,arr_rekv_smo[j,6],sh-7)
add_string("Адрес: "+t_arr[1])
for i := 2 to k
  add_string(space(7)+t_arr[2])
next
k := perenos(t_arr,arr_rekv_smo[j,7],sh-18)
add_string("Банк плательщика: "+t_arr[1])
for i := 2 to k
  add_string(space(18)+t_arr[2])
next
add_string("Расчетный счет: "+alltrim(arr_rekv_smo[j,8])+", БИК: "+alltrim(arr_rekv_smo[j,9]))
add_string("")
add_string("")
add_string(center("Реестр счета № "+alltrim(schet_->nschet)+" от "+full_date(schet_->dschet)+" г.",sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
select SCHET
fl_numeration := emptyany(schet_->nyear,schet_->nmonth)
rec := recno()
set index to
j := 0
select SD
find (str(rec,6))
do while sd->kod == rec .and. !eof()
  schet->(dbGoto(sd->kod2))
  j1 := 0
  Select HUMAN
  find (str(sd->kod2,6))
  do while human->schet == sd->kod2 .and. !eof()
    lshifr := "" ; v_doplata := r_doplata := 0
    ret_zak_sl(@lshifr,@v_doplata,@r_doplata,,,iif(is_20_11, sdate, nil))
    if iif(reg==1, !empty(r_doplata), .t.)
      a_diag := diag_for_xml(,.t.,,,.t.)
      s_diag := a_diag[1]
      if reg==1 .and. len(a_diag)>1 .and. !empty(a_diag[2])
        s_diag += " "+a_diag[2]
      endif
      s := padr(lstr(++j),5)+;
           padc(alltrim(schet_->nschet),15)+" "+;
           padr(str(iif(fl_numeration, ++j1, human_->SCHET_ZAP),7),13)+;
           date_8(schet_->dschet)+" "+;
           padc(lshifr,10)+;
           padc(alltrim(s_diag),13)+;
           str(iif(reg==2,v_doplata,r_doplata),11,2)
      ssumma += iif(reg==2,v_doplata,r_doplata)
      if verify_FF(HH,.t.,sh)
        aeval(arr1title, {|x| add_string(x) } )
      endif
      add_string(s)
    endif
    //
    Select HUMAN
    skip
  enddo
  select SD
  skip
enddo
if verify_FF(HH-8,.t.,sh)
  aeval(arr1title, {|x| add_string(x) } )
endif
add_string(replicate("─",sh))
add_string(padl("Всего: "+lstr(ssumma,14,2),sh-3))
add_string("")
k := perenos(t_arr,"К оплате: "+srub_kop(ssumma,.t.),sh)
add_string(t_arr[1])
for j := 2 to k
  add_string(padl(alltrim(t_arr[j]),sh))
next
add_string("")
add_string("  Главный врач медицинской организации      _____________ / "+alltrim(org->ruk)+" /")
add_string("  Главный бухгалтер медицинской организации _____________ / "+alltrim(org->bux)+" /")
add_string("                                        М.П.")
fclose(fp)
rest_box(buf)
lusl->(dbCloseArea())
lusld->(dbCloseArea())
luslf->(dbCloseArea())
usl->(dbCloseArea())
hu->(dbCloseArea())
human_->(dbCloseArea())
human->(dbCloseArea())
org->(dbCloseArea())
sd->(dbCloseArea())
if select("USL1") > 0
  usl1->(dbCloseArea())
endif
select SCHET
if !(round(ssumma,2) == round(schet->summa,2))
  // если ТФОМС поменял ценник - перезапишем сумму счёта
  goto (rec)
  G_RLock(forever)
  schet->summa := schet->summa_ost := ssumma
  UnLock
  Commit
endif
set index to (cur_dir+"tmp_sch")
goto (rec)
viewtext(n_file,,,,.t.,,,2)
return NIL

*

***** 23.04.13 вынуть ЛЮБОЙ реестр из XML-файлов и записать во временные DBF-файлы
Function my_extract_reestr()
Local cName, full_zip
full_zip := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,1,,,,"*"+szip)
if !empty(full_zip)
  cName := Name_Without_Ext(StripPath(full_zip))
  if left(cName,3) == "HRM" // файл реестра
    extract_reestr(1,cName,,,KeepPath(full_zip)+cslash)
  else
    func_error(4,"Это не файл реестра")
  endif
endif
return NIL

***** 10.04.18 вынуть реестр из XML-файлов и записать во временные DBF-файлы
Function extract_reestr(mkod,mname_xml,flag_tmp1,is_all,goal_dir)
Local _table1 := {;
   {"KOD",      "N", 6,0},; // код
   {"N_ZAP",    "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
   {"PR_NOV",   "C", 1,0},;
   {"ID_PAC",   "C",36,0},; //
   {"VPOLIS",   "C", 1,0},; //
   {"SPOLIS",   "C",10,0},; //
   {"NPOLIS",   "C",20,0},; //
   {"ENP",      "C",16,0},; //
   {"SMO",      "C", 5,0},; //
   {"SMO_OK",   "C", 5,0},; //
   {"SMO_NAM", "C",100,0},; //
   {"MO_PR",    "C", 6,0},; //
   {"NOVOR",    "C", 9,0},; //
   {"VNOV_D",   "C", 4,0},; // вес новорожденного в граммах
   {"INV",      "C", 1,0},; //
   {"DATA_INV", "C",10,0},; //
   {"REASON_INV","C",2,0},; //
   {"DS_INV",   "C",10,0},; //
   {"MSE",      "C", 1,0},; //
   {"IDCASE",   "C",12,0},; //
   {"ID_C",     "C",36,0},; //
   {"DISP",     "C", 3,0},; //
   {"USL_OK",   "C", 2,0},; //
   {"VIDPOM",   "C", 4,0},; //
   {"F_SP",     "C", 1,0},; // удалено поле
   {"FOR_POM",  "C", 1,0},; // N1
   {"VID_HMP",  "C",12,0},; // C9
   {"METOD_HMP","C", 3,0},; // N3
   {"NPR_MO",   "C", 6,0},; //
   {"EXTR",     "C", 1,0},; //
   {"LPU"     , "C", 6,0},; //
   {"LPU_1"   , "C", 8,0},; //
   {"PODR"    , "C", 8,0},; //
   {"PROFIL"  , "C", 3,0},; //
   {"DET"     , "C", 1,0},; //
   {"TAL_D",    "C",10,0},; //
   {"TAL_P",    "C",10,0},; //
   {"VBR",      "C", 1,0},; //
   {"NHISTORY", "C",10,0},; //
   {"P_OTK",    "C", 1,0},; //
   {"P_PER",    "C", 1,0},; //
   {"DATE_1"  , "C",10,0},; //
   {"DATE_2"  , "C",10,0},; //
   {"DS0"   ,   "C", 6,0},; //
   {"DS1"   ,   "C", 6,0},; //
   {"DS1_PR",   "C", 1,0},; //
   {"PR_D_N",   "C", 1,0},; //
   {"DS2"   ,   "C", 6,0},; //
   {"DS2N"   ,  "C", 6,0},; //
   {"DS2N_PR",  "C", 1,0},; //
   {"DS2N_D",   "C", 1,0},; //
   {"DS2_2" ,   "C", 6,0},; //
   {"DS2N_2" ,  "C", 6,0},; //
   {"DS2N_2_PR","C", 1,0},; //
   {"DS2N_2_D", "C", 1,0},; //
   {"DS2_3" ,   "C", 6,0},; //
   {"DS2N_3" ,  "C", 6,0},; //
   {"DS2N_3_PR","C", 1,0},; //
   {"DS2N_3_D", "C", 1,0},; //
   {"DS2_4" ,   "C", 6,0},; //
   {"DS2N_4" ,  "C", 6,0},; //
   {"DS2N_4_PR","C", 1,0},; //
   {"DS2N_4_D", "C", 1,0},; //
   {"DS2_5" ,   "C", 6,0},; //
   {"DS2_6" ,   "C", 6,0},; //
   {"DS2_7" ,   "C", 6,0},; //
   {"DS3"   ,   "C", 6,0},; //
   {"DS3_2" ,   "C", 6,0},; //
   {"DS3_3" ,   "C", 6,0},; //
   {"VNOV_M",   "C", 4,0},; // вес новорожденного в граммах
   {"VNOV_M_2", "C", 4,0},; // вес новорожденного в граммах
   {"VNOV_M_3", "C", 4,0},; // вес новорожденного в граммах
   {"CODE_MES1","C",20,0},; //
   {"RSLT"    , "C", 3,0},; //
   {"ISHOD"   , "C", 3,0},; //
   {"PRVS"    , "C", 9,0},; //
   {"IDDOKT",   "C",16,0},; //
   {"OS_SLUCH", "C", 2,0},; //
   {"COMENTSL", "C",99,0},; //
   {"IDSP"    , "C", 2,0},; //
   {"ED_COL",   "C", 1,0},; //
   {"IT_SL"   , "C", 9,0},; //
   {"AD_CR"   , "C",10,0},; //
   {"CODE_KIRO","C", 1,0},; //
   {"VAL_K"   , "C", 5,0},; //
   {"NEXT_VISIT","C",10,0},; //
   {"TARIF" ,   "C",10,0},; //
   {"SUMV"    , "C",10,0}; //
  }
Local _table2 := {;
   {"KOD",      "N", 6,0},; // код
   {"IDCASE",   "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
   {"IDSERV"  , "C",36,0},; //
   {"ID_U"    , "C",36,0},; //
   {"LPU"     , "C", 6,0},; //
   {"LPU_1"   , "C", 8,0},; //
   {"PODR"    , "C", 8,0},; //
   {"PROFIL"  , "C", 3,0},; //
   {"VID_VME" , "C",20,0},; //
   {"DET"     , "C", 1,0},; //
   {"P_OTK"   , "C", 1,0},; //
   {"DATE_IN" , "C",10,0},; //
   {"DATE_OUT", "C",10,0},; //
   {"DS"      , "C", 6,0},; //
   {"CODE_USL", "C",20,0},; //
   {"KOL_USL" , "C", 6,0},; //
   {"TARIF"   , "C",10,0},; //
   {"SUMV_USL", "C",10,0},; //
   {"PRVS"    , "C", 9,0},; //
   {"CODE_MD",  "C",16,0},; //
   {"COMENTU" , "C",99,0};  //
  }
Local _table3 := {;
   {"KOD",      "N", 6,0},; // код
   {"ID_PAC",   "C",36,0},; // код записи о пациенте ;GUID пациента в листе учета;создается при добавлении записи
   {"FAM"  ,    "C",40,0},; //
   {"IM"   ,    "C",40,0},; //
   {"OT"   ,    "C",40,0},; //
   {"W"    ,    "C", 1,0},; //
   {"DR"   ,    "C",10,0},; //
   {"DOST" ,    "C", 1,0},; //
   {"TEL"  ,    "C",10,0},; //
   {"FAM_P",    "C",40,0},; //
   {"IM_P" ,    "C",40,0},; //
   {"OT_P" ,    "C",40,0},; //
   {"W_P"  ,    "C", 1,0},; //
   {"DR_P" ,    "C",10,0},; //
   {"DOST_P",   "C", 1,0},; //
   {"MR"   ,    "C",100,0},; //
   {"DOCTYPE",  "C", 2,0},; //
   {"DOCSER" ,  "C",10,0},; //
   {"DOCNUM" ,  "C",20,0},; //
   {"SNILS",    "C",14,0},; //
   {"OKATOG" ,  "C",11,0},; //
   {"OKATOP",   "C",11,0}; //
  }
Local _table4 := {;
   {"KOD",      "N", 6,0},; // код
   {"IDCASE",   "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
   {"CODE_SL",  "C", 5,0},; //
   {"VAL_C",    "C", 6,0};  //
  }
Local _table5 := {;
   {"KOD",      "N", 6,0},; // код
   {"IDCASE",   "C",12,0},; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
   {"NAZR"    , "C", 2,0},; // PRESCRIPTIONS - Код назначения
   {"NAZ_SP1" , "C", 5,0},; //
   {"NAZ_SP2" , "C", 5,0},; //
   {"NAZ_SP3" , "C", 5,0},; //
   {"NAZ_V1"  , "C", 1,0},; //
   {"NAZ_V2"  , "C", 1,0},; //
   {"NAZ_V3"  , "C", 1,0},; //
   {"NAZ_PMP" , "C", 3,0},; //
   {"NAZ_PK"  , "C", 3,0}; //
  }
Local arr_f, ii, oXmlDoc, j, j1, _ar, buf := save_maxrow(),;
      name_zip := alltrim(mname_xml)+szip, fl := .f.
//
DEFAULT flag_tmp1 TO .f., is_all TO .t.,;
        goal_dir TO dir_server+dir_XML_MO+cslash
Private pole
stat_msg("Распаковка/чтение/анализ "+;
         iif(eq_any(left(mname_xml,3),"HRM","FRM"),"реестра ","счёта ")+mname_xml)
if (arr_f := Extract_Zip_XML(goal_dir,name_zip)) != NIL
  fl := .t.
  dbcreate(cur_dir+"tmp_r_t1",_table1)
  dbcreate(cur_dir+"tmp_r_t2",_table2)
  dbcreate(cur_dir+"tmp_r_t3",_table3)
  dbcreate(cur_dir+"tmp_r_t4",_table4)
  dbcreate(cur_dir+"tmp_r_t5",_table5)
  use (cur_dir+"tmp_r_t1") new alias T1
  use (cur_dir+"tmp_r_t2") new alias T2
  use (cur_dir+"tmp_r_t3") new alias T3
  use (cur_dir+"tmp_r_t4") new alias T4
  use (cur_dir+"tmp_r_t5") new alias T5
  if flag_tmp1
    dbcreate(cur_dir+"tmp1file", {;
     {"_VERSION",   "C",  5,0},;
     {"_DATA",      "D",  8,0},;
     {"_FILENAME",  "C", 26,0},;
     {"_SD_Z",      "N",  9,0},;
     {"_CODE",      "N", 12,0},;
     {"_CODE_MO",   "C",  6,0},;
     {"_YEAR",      "N",  4,0},;
     {"_MONTH",     "N",  2,0},;
     {"_NSCHET",    "C", 15,0},;
     {"_DSCHET",    "D",  8,0},;
     {"_SUMMAV",    "N", 15,2},;
     {"_KOL",       "N",  6,0},;
     {"_MAX",       "N",  8,0};
    })
    use (cur_dir+"tmp1file") new alias TMP1
    append blank
  endif
  for ii := 1 to len(arr_f)
    // читаем файл в память
    oXmlDoc := HXMLDoc():Read(_tmp_dir1+arr_f[ii])
    if Empty( oXmlDoc:aItems )
      fl := func_error(4,"Ошибка в чтении файла "+arr_f[ii])
      exit
    endif
    FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
      @ maxrow(),1 say padr(lstr(ii)+"/"+lstr(j),8) color cColorSt2Msg
      oXmlNode := oXmlDoc:aItems[1]:aItems[j]
      do case
        case flag_tmp1 .and. "ZGLV" == oXmlNode:title 
          tmp1->_VERSION :=          mo_read_xml_stroke(oXmlNode,"VERSION")
          tmp1->_DATA    := xml2date(mo_read_xml_stroke(oXmlNode,"DATA"))
          tmp1->_FILENAME:=          mo_read_xml_stroke(oXmlNode,"FILENAME")
          tmp1->_SD_Z    :=      val(mo_read_xml_stroke(oXmlNode,"SD_Z",,.f.))
        case flag_tmp1 .and. "SCHET" == oXmlNode:title
          tmp1->_CODE    :=      val(mo_read_xml_stroke(oXmlNode,"CODE"))
          tmp1->_CODE_MO :=          mo_read_xml_stroke(oXmlNode,"CODE_MO")
          tmp1->_YEAR    :=      val(mo_read_xml_stroke(oXmlNode,"YEAR"))
          tmp1->_MONTH   :=      val(mo_read_xml_stroke(oXmlNode,"MONTH"))
          tmp1->_NSCHET  :=          mo_read_xml_stroke(oXmlNode,"NSCHET")
          tmp1->_DSCHET  := xml2date(mo_read_xml_stroke(oXmlNode,"DSCHET"))
          tmp1->_SUMMAV  :=      val(mo_read_xml_stroke(oXmlNode,"SUMMAV"))
        case "ZAP" == oXmlNode:title
          if is_all
            select T1
            append blank
            t1->kod := mkod
            t1->N_ZAP := mo_read_xml_stroke(oXmlNode,"N_ZAP")
            t1->PR_NOV := mo_read_xml_stroke(oXmlNode,"PR_NOV")
            if (oNode1 := oXmlNode:Find("PACIENT")) != NIL
              t1->ID_PAC  := mo_read_xml_stroke(oNode1,"ID_PAC")
              t1->VPOLIS  := mo_read_xml_stroke(oNode1,"VPOLIS")
              t1->SPOLIS  := mo_read_xml_stroke(oNode1,"SPOLIS",,.f.)
              t1->NPOLIS  := mo_read_xml_stroke(oNode1,"NPOLIS")
              t1->ENP     := mo_read_xml_stroke(oNode1,"ENP",,.f.)
              t1->SMO     := mo_read_xml_stroke(oNode1,"SMO")
              t1->SMO_OK  := mo_read_xml_stroke(oNode1,"SMO_OK",,.f.)
              t1->SMO_NAM := mo_read_xml_stroke(oNode1,"SMO_NAM",,.f.)
              t1->MO_PR   := mo_read_xml_stroke(oNode1,"MO_PR",,.f.)
              t1->NOVOR   := mo_read_xml_stroke(oNode1,"NOVOR",,.f.)
              t1->VNOV_D  := mo_read_xml_stroke(oNode1,"VNOV_D",,.f.)
              if (oNode2 := oNode1:Find("DISABILITY")) != NIL
                t1->INV        := mo_read_xml_stroke(oNode2,"INV")
                t1->DATA_INV   := mo_read_xml_stroke(oNode2,"DATA_INV")
                t1->REASON_INV := mo_read_xml_stroke(oNode2,"REASON_INV")
                t1->DS_INV     := mo_read_xml_stroke(oNode2,"DS_INV",,.f.)
              endif
              t1->MSE     := mo_read_xml_stroke(oNode1,"MSE",,.f.)
            endif
            if (oNode1 := oXmlNode:Find("SLUCH")) != NIL
              t1->IDCASE   := mo_read_xml_stroke(oNode1,"IDCASE")
              t1->ID_C     := mo_read_xml_stroke(oNode1,"ID_C")
              t1->DISP     := mo_read_xml_stroke(oNode1,"DISP",,.f.)
              t1->USL_OK   := mo_read_xml_stroke(oNode1,"USL_OK")
              t1->VIDPOM   := mo_read_xml_stroke(oNode1,"VIDPOM")
              t1->FOR_POM  := mo_read_xml_stroke(oNode1,"FOR_POM",,.f.)
              t1->VID_HMP  := mo_read_xml_stroke(oNode1,"VID_HMP",,.f.)
              t1->METOD_HMP:= mo_read_xml_stroke(oNode1,"METOD_HMP",,.f.)
              t1->F_SP     := mo_read_xml_stroke(oNode1,"F_SP",,.f.)
              t1->NPR_MO   := mo_read_xml_stroke(oNode1,"NPR_MO",,.f.)
              t1->EXTR     := mo_read_xml_stroke(oNode1,"EXTR",,.f.)
              t1->LPU      := mo_read_xml_stroke(oNode1,"LPU")
              t1->LPU_1    := mo_read_xml_stroke(oNode1,"LPU_1",,.f.)
              t1->PODR     := mo_read_xml_stroke(oNode1,"PODR",,.f.)
              t1->PROFIL   := mo_read_xml_stroke(oNode1,"PROFIL")
              t1->DET      := mo_read_xml_stroke(oNode1,"DET",,.f.)
              t1->TAL_D    := mo_read_xml_stroke(oNode1,"TAL_D",,.f.)
              t1->TAL_P    := mo_read_xml_stroke(oNode1,"TAL_P",,.f.)
              t1->VBR      := mo_read_xml_stroke(oNode1,"VBR",,.f.)
              t1->NHISTORY := mo_read_xml_stroke(oNode1,"NHISTORY")
              t1->P_OTK    := mo_read_xml_stroke(oNode1,"P_OTK",,.f.)
              t1->P_PER    := mo_read_xml_stroke(oNode1,"P_PER",,.f.)
              t1->DATE_1   := mo_read_xml_stroke(oNode1,"DATE_1"  )
              t1->DATE_2   := mo_read_xml_stroke(oNode1,"DATE_2"  )
              t1->DS0      := mo_read_xml_stroke(oNode1,"DS0",,.f.)
              t1->DS1      := mo_read_xml_stroke(oNode1,"DS1")
              t1->DS1_PR   := mo_read_xml_stroke(oNode1,"DS1_PR",,.f.) // для диспансеризации
              t1->PR_D_N   := mo_read_xml_stroke(oNode1,"PR_D_N",,.f.) // для диспансеризации
              // DS2 для диспансеризации
              j1 := 0
              for i := 1 to len(oNode1:aitems) // последовательный просмотр
                oNode2 := oNode1:aItems[i]     // т.к. услуг м.б. несколько
                if valtype(oNode2) != "C" .AND. oNode2:title == "DS2_N"
                  if ++j1 > 4 ; exit ; endif
                  pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))
                  &pole := mo_read_xml_stroke(oNode2,"DS2")
                  pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_PR"
                  &pole := mo_read_xml_stroke(oNode2,"DS2_PR",,.f.)
                  pole := "t1->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_D"
                  &pole := mo_read_xml_stroke(oNode2,"PR_D",,.f.)
                endif
              next
              // DS2 для обычного листа учёта
              _ar := mo_read_xml_array(oNode1,"DS2") // М.Б.НЕСКОЛЬКО DS2
              for j1 := 1 to min(7,len(_ar))
                pole := "t1->DS2"+iif(j1==1, "", "_"+lstr(j1))
                &pole := _ar[j1]
              next
              _ar := mo_read_xml_array(oNode1,"DS3") // М.Б.НЕСКОЛЬКО DS3
              for j1 := 1 to min(3,len(_ar))
                pole := "t1->DS3"+iif(j1==1, "", "_"+lstr(j1))
                &pole := _ar[j1]
              next
              _ar := mo_read_xml_array(oNode1,"VNOV_M") // М.Б.НЕСКОЛЬКО VNOV_M
              for j1 := 1 to min(3,len(_ar))
                pole := "t1->VNOV_M"+iif(j1==1, "", "_"+lstr(j1))
                &pole := _ar[j1]
              next
              t1->CODE_MES1:= mo_read_xml_stroke(oNode1,"CODE_MES1",,.f.)
              t1->RSLT     := mo_read_xml_stroke(oNode1,"RSLT")
              if (oNode3 := oNode1:Find("PRESCRIPTION")) != NIL
                for i := 1 to len(oNode3:aitems) // последовательный просмотр
                  oNode2 := oNode3:aItems[i]     // т.к. назначений м.б. несколько
                  if valtype(oNode2) != "C" .AND. oNode2:title == "PRESCRIPTIONS"
                    select T5
                    append blank
                    t5->KOD      := mkod
                    t5->IDCASE   := t1->IDCASE // для связи со случаем
                    t5->NAZR     := mo_read_xml_stroke(oNode2,"NAZR")
                    _ar := mo_read_xml_array(oNode2,"NAZ_SP") // М.Б.НЕСКОЛЬКО NAZ_SP
                    for j1 := 1 to min(3,len(_ar))
                      pole := "t5->NAZ_SP"+lstr(j1)
                      &pole := _ar[j1]
                    next
                    _ar := mo_read_xml_array(oNode2,"NAZ_V") // М.Б.НЕСКОЛЬКО NAZ_V
                    for j1 := 1 to min(3,len(_ar))
                      pole := "t5->NAZ_V"+lstr(j1)
                      &pole := _ar[j1]
                    next
                    t5->NAZ_PMP := mo_read_xml_stroke(oNode2,"NAZ_PMP",,.f.)
                    t5->NAZ_PK  := mo_read_xml_stroke(oNode2,"NAZ_PK",,.f.)
                  endif
                next
              endif
              t1->ISHOD    := mo_read_xml_stroke(oNode1,"ISHOD")
              t1->PRVS     := mo_read_xml_stroke(oNode1,"PRVS")
              t1->IDDOKT   := mo_read_xml_stroke(oNode1,"IDDOKT",,.f.)
              t1->OS_SLUCH := mo_read_xml_stroke(oNode1,"OS_SLUCH",,.f.)
              t1->IDSP     := mo_read_xml_stroke(oNode1,"IDSP")
              t1->ED_COL   := mo_read_xml_stroke(oNode1,"ED_COL",,.f.)
              t1->TARIF    := mo_read_xml_stroke(oNode1,"TARIF",,.f.)
              t1->SUMV     := mo_read_xml_stroke(oNode1,"SUMV")
              t1->AD_CR    := mo_read_xml_stroke(oNode1,"AD_CRITERION",,.f.)
              t1->NEXT_VISIT := mo_read_xml_stroke(oNode1,"NEXT_VISIT",,.f.)
              t1->IT_SL    := mo_read_xml_stroke(oNode1,"IT_SL",,.f.)
              t1->COMENTSL := mo_read_xml_stroke(oNode1,"COMENTSL",,.f.)
              if (oNode3 := oNode1:Find("S_KIRO")) != NIL
                t1->CODE_KIRO := mo_read_xml_stroke(oNode3,"CODE_KIRO")
                t1->VAL_K     := mo_read_xml_stroke(oNode3,"VAL_K")
              endif
              for j1 := 1 to len(oNode1:aitems) // последовательный просмотр
                oNode2 := oNode1:aItems[j1]     // т.к. услуг м.б. несколько
                if valtype(oNode2) != "C" .AND. oNode2:title == "USL"
                  select T2
                  append blank
                  t2->KOD      := mkod
                  t2->IDCASE   := t1->IDCASE // для связи со случаем
                  t2->IDSERV   := mo_read_xml_stroke(oNode2,"IDSERV")
                  t2->ID_U     := mo_read_xml_stroke(oNode2,"ID_U")
                  t2->LPU      := mo_read_xml_stroke(oNode2,"LPU")
                  t2->LPU_1    := mo_read_xml_stroke(oNode2,"LPU_1",,.f.)
                  t2->PODR     := mo_read_xml_stroke(oNode2,"PODR",,.f.)
                  t2->PROFIL   := mo_read_xml_stroke(oNode2,"PROFIL")
                  t2->VID_VME  := mo_read_xml_stroke(oNode2,"VID_VME",,.f.)
                  t2->DET      := mo_read_xml_stroke(oNode2,"DET",,.f.)
                  t2->DATE_IN  := mo_read_xml_stroke(oNode2,"DATE_IN")
                  t2->DATE_OUT := mo_read_xml_stroke(oNode2,"DATE_OUT")
                  t2->P_OTK    := mo_read_xml_stroke(oNode2,"P_OTK",,.f.)
                  t2->DS       := mo_read_xml_stroke(oNode2,"DS",,.f.)
                  t2->CODE_USL := mo_read_xml_stroke(oNode2,"CODE_USL")
                  t2->KOL_USL  := mo_read_xml_stroke(oNode2,"KOL_USL")
                  t2->TARIF    := mo_read_xml_stroke(oNode2,"TARIF")
                  t2->SUMV_USL := mo_read_xml_stroke(oNode2,"SUMV_USL")
                  t2->PRVS     := mo_read_xml_stroke(oNode2,"PRVS")
                  t2->CODE_MD  := mo_read_xml_stroke(oNode2,"CODE_MD",,.f.)
                  t2->COMENTU  := mo_read_xml_stroke(oNode2,"COMENTU",,.f.)
                endif
              next
              if (oNode3 := oNode1:Find("SL_KOEFF")) != NIL
                for j1 := 1 to len(oNode3:aitems) // последовательный просмотр
                  oNode2 := oNode3:aItems[j1]     // т.к. услуг м.б. несколько
                  if valtype(oNode2) != "C" .AND. oNode2:title == "COEFF"
                    select T4
                    append blank
                    t4->KOD      := mkod
                    t4->IDCASE   := t1->IDCASE // для связи со случаем
                    t4->CODE_SL  := mo_read_xml_stroke(oNode2,"CODE_SL")
                    t4->VAL_C    := mo_read_xml_stroke(oNode2,"VAL_C")
                  endif
                next
              endif
            endif
          endif
          if flag_tmp1
            tmp1->_KOL ++
            tmp1->_MAX := max(tmp1->_MAX,int(val(mo_read_xml_stroke(oXmlNode,"N_ZAP"))))
          endif
        case is_all .and. "PERS" == oXmlNode:title
          select T3
          append blank
          t3->KOD     := mkod
          t3->ID_PAC  := mo_read_xml_stroke(oXmlNode,"ID_PAC")
          t3->FAM     := mo_read_xml_stroke(oXmlNode,"FAM")
          t3->IM      := mo_read_xml_stroke(oXmlNode,"IM")
          t3->OT      := mo_read_xml_stroke(oXmlNode,"OT",,.f.)
          t3->W       := mo_read_xml_stroke(oXmlNode,"W")
          t3->DR      := mo_read_xml_stroke(oXmlNode,"DR")
          t3->DOST    := mo_read_xml_stroke(oXmlNode,"DOST",,.f.)
          t3->TEL     := mo_read_xml_stroke(oXmlNode,"TEL",,.f.)
          t3->FAM_P   := mo_read_xml_stroke(oXmlNode,"FAM_P",,.f.)
          t3->IM_P    := mo_read_xml_stroke(oXmlNode,"IM_P",,.f.)
          t3->OT_P    := mo_read_xml_stroke(oXmlNode,"OT_P",,.f.)
          t3->W_P     := mo_read_xml_stroke(oXmlNode,"W_P",,.f.)
          t3->DR_P    := mo_read_xml_stroke(oXmlNode,"DR_P",,.f.)
          t3->DOST_P  := mo_read_xml_stroke(oXmlNode,"DOST_P",,.f.)
          t3->MR      := mo_read_xml_stroke(oXmlNode,"MR",,.f.)
          t3->DOCTYPE := mo_read_xml_stroke(oXmlNode,"DOCTYPE",,.f.)
          t3->DOCSER  := mo_read_xml_stroke(oXmlNode,"DOCSER",,.f.)
          t3->DOCNUM  := mo_read_xml_stroke(oXmlNode,"DOCNUM",,.f.)
          t3->SNILS   := mo_read_xml_stroke(oXmlNode,"SNILS",,.f.)
          t3->OKATOG  := mo_read_xml_stroke(oXmlNode,"OKATOG",,.f.)
          t3->OKATOP  := mo_read_xml_stroke(oXmlNode,"OKATOP",,.f.)
      endcase
      if j % 2000 == 0
        commit
      endif
    next j
  next ii
  t1->(dbCloseArea())
  t2->(dbCloseArea())
  t3->(dbCloseArea())
  t4->(dbCloseArea())
  t5->(dbCloseArea())
  if flag_tmp1
    tmp1->(dbCloseArea())
  endif
endif
rest_box(buf)
return fl

*

***** 03.03.13 переписать архив во временный каталог и распаковать
Function Extract_Zip_XML(goal_dir,name_zip,regim,new_name)
Local arr_f := {}, fl := .f., n, hUnzip, nErr, cFile, cName, _dir, _dir1
DEFAULT regim TO 1, new_name TO name_zip
_dir  := iif(regim==1, _tmp_dir,  _tmp2dir)
_dir1 := iif(regim==1, _tmp_dir1, _tmp2dir1)
if right(goal_dir,1) != cslash
  goal_dir += cslash
endif
//if !hb_FileExists(hb_OemToAnsi(goal_dir)+name_zip)
if !hb_FileExists(goal_dir+name_zip)
  func_error(4,"Не найден архив "+goal_dir+name_zip)
  return NIL
endif
dirmake(_dir)
filedelete(_dir1+"*.*")
//copy file (hb_OemToAnsi(goal_dir)+name_zip) to (_dir1+new_name)
copy file (goal_dir+name_zip) to (_dir1+new_name)
if !hb_FileExists(_dir1+new_name)
  func_error(4,"Ошибка при копировании архива "+name_zip+" во временный каталог")
else
  n := 0
  if !empty(hUnzip := HB_UNZIPOPEN(_dir1+new_name))
    fl := .t.
    hb_UnzipGlobalInfo( hUnzip, @n, NIL )
    if n > 0
      nErr := HB_UNZIPFILEFIRST(hUnzip)
      DO WHILE nErr == 0
        HB_UnzipFileInfo( hUnzip, @cFile)//, @dDate, @cTime,,,, @nSize, @nCompSize, @lCrypted, @cComment )
        HB_UnzipExtractCurrentFile(hUnzip,_dir1+cFile)//, cPassword)
        aadd(arr_f,cFile)
        nErr := HB_UNZIPFILENEXT(hUnzip)
      ENDDO
    endif
    HB_UNZIPCLOSE(hUnzip)
  else
    func_error(4,"Возникла ошибка при разархивировании "+_dir1+name_zip)
  endif
endif
return iif(fl, arr_f, nil)

*

***** 21.06.15 переписать архив во временный каталог и распаковать
Function Extract_RAR(goal_dir,name_zip,regim,new_name)
Local fl := .f., buf, _dir, _dir1
DEFAULT regim TO 1, new_name TO name_zip
_dir  := iif(regim==1, _tmp_dir,  _tmp2dir)
_dir1 := iif(regim==1, _tmp_dir1, _tmp2dir1)
if right(goal_dir,1) != cslash
  goal_dir += cslash
endif
//if !hb_FileExists(hb_OemToAnsi(goal_dir)+name_zip)
if !hb_FileExists(goal_dir+name_zip)
  func_error(4,"Не найден архив "+goal_dir+name_zip)
  return NIL
endif
dirmake(_dir)
filedelete(_dir1+"*.*")
//copy file (hb_OemToAnsi(goal_dir)+name_zip) to (_dir1+new_name)
copy file (goal_dir+name_zip) to (_dir1+new_name)
if !hb_FileExists(_dir1+new_name)
  func_error(4,"Ошибка при копировании архива "+name_zip+" во временный каталог")
else
  buf := savescreen()
  RUN (dir_exe+"unrar.exe e "+_dir1+new_name+" "+_dir1)
  restscreen(buf)
  fl := .t.
endif
return fl

*

***** 05.01.13 зачитать протокол ФЛК во временные файлы
Function protokol_flk_tmpfile(arr_f,aerr)
Local adbf, ii, j, oXmlDoc, oXmlNode, is_err_FLK := .f.
adbf := {;
 {"FNAME",  "C", 26,0},;
 {"FNAME1", "C", 26,0},;
 {"FNAME2", "C", 26,0},;
 {"KOL2",   "N",  6,0};   // кол-во ошибок
}
dbcreate(cur_dir+"tmp1file",adbf)
adbf := {; // элементы PR
 {"TIP",        "N",  1,0},;  // тип(номер) обрабатываемого файла
 {"OSHIB",      "N",  3,0},;  // код ошибки  F012
 {"IM_POL",     "C", 20,0},;  // имя поля, в котором ошибка
 {"BAS_EL",     "C", 20,0},;  // имя базового элемента
 {"ID_BAS",     "C", 36,0},;  // GUID базового элемента
 {"COMMENT",    "C",250,0},;  // описание ошибки
 {"N_ZAP",      "N",  6,0},;  // поле из первичного реестра
 {"KOD_HUMAN",  "N",  7,0};   // код по БД листов учёта
}
dbcreate(cur_dir+"tmp2file",adbf) // элементы PR
dbcreate(cur_dir+"tmp22fil",adbf) // доп.файл, если по одному пациенту > 1 листа учёта
use (cur_dir+"tmp1file") new alias TMP1
append blank
use (cur_dir+"tmp2file") new alias TMP2
for ii := 1 to len(arr_f)
  // т.к. в ZIP'е два XML-файла, второй файл также прочитать
  if upper(right(arr_f[ii],4)) == sxml
    // читаем файл в память
    oXmlDoc := HXMLDoc():Read(_tmp_dir1+arr_f[ii])
    FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
      oXmlNode := oXmlDoc:aItems[1]:aItems[j]
      do case
        case "FNAME" == oXmlNode:title
          tmp1->FNAME := mo_read_xml_tag(oXmlNode,aerr,.t.)
        case "FNAME_I" == oXmlNode:title
          if ii == 1
            tmp1->FNAME1 := mo_read_xml_tag(oXmlNode,aerr,.t.)
          else
            tmp1->FNAME2 := mo_read_xml_tag(oXmlNode,aerr,.t.)
          endif
        case "PR" == oXmlNode:title
          select TMP2
          append blank
          tmp2->tip := ii
          tmp2->OSHIB := val(mo_read_xml_stroke(oXmlNode,"OSHIB",aerr))
          tmp2->IM_POL  := mo_read_xml_stroke(oXmlNode,"IM_POL",aerr,.f.)
          tmp2->BAS_EL  := mo_read_xml_stroke(oXmlNode,"BAS_EL",aerr,.f.)
          tmp2->ID_BAS  := mo_read_xml_stroke(oXmlNode,"ID_BAS",aerr,.f.)
          tmp2->COMMENT := mo_read_xml_stroke(oXmlNode,"COMMENT",aerr,.f.)
          if !empty(tmp2->BAS_EL) .and. !empty(tmp2->ID_BAS)
            is_err_FLK := .t.
            tmp1->KOL2 ++
          endif
      endcase
    NEXT j
  endif
next ii
commit
return is_err_FLK

*

***** 31.01.17 зачитать реестр СП и ТК во временные файлы
Function reestr_sp_tk_tmpfile(oXmlDoc,aerr,mname_xml)
Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()
DEFAULT aerr TO {}, mname_xml TO ""
stat_msg("Распаковка/чтение/анализ реестра СП и ТК "+beforatnum(".",mname_xml))
dbcreate(cur_dir+"tmp1file", {;
 {"_VERSION",   "C",  5,0},;
 {"_DATA",      "D",  8,0},;
 {"_FILENAME",  "C", 26,0},;
 {"_CODE",      "N",  8,0},;
 {"_CODE_MO",   "C",  6,0},;
 {"_YEAR",      "N",  4,0},;
 {"_MONTH",     "N",  2,0},;
 {"_NSCHET",    "C", 15,0},;
 {"_DSCHET",    "D",  8,0},;
 {"KOL1",       "N",  6,0},;
 {"KOL2",       "N",  6,0};
})
dbcreate(cur_dir+"tmp2file", {;
 {"_N_ZAP",     "N",  8,0},;
 {"_ID_PAC",    "C", 36,0},;
 {"_VPOLIS",    "N",  1,0},;
 {"_SPOLIS",    "C", 10,0},;
 {"_NPOLIS",    "C", 20,0},;
 {"_ENP",       "C", 16,0},;
 {"_SMO",       "C",  5,0},;
 {"_SMO_OK",    "C",  5,0},;
 {"_MO_PR",     "C",  6,0},;
 {"KOD_HUMAN",  "N",  7,0},; // код по БД листов учёта
 {"SCHET_CHAR", "C",  1,0},; // пусто, буква "M", или буква "D"
 {"SCHET"    ,  "N",  6,0},; // код счета
 {"SCHET_ZAP",  "N",  6,0},; // номер позиции записи в счете
 {"_IDCASE",    "N",  8,0},;
 {"_ID_C",      "C", 36,0},;
 {"_IDENTITY",  "N",  1,0},;
 {"CORRECT",    "C",  2,0},;
 {"_FAM"  ,     "C", 40,0},; //
 {"_IM"   ,     "C", 40,0},; //
 {"_OT"   ,     "C", 40,0},; //
 {"_DR"   ,     "C", 10,0},; //
 {"_OPLATA",    "N",  1,0};
})
dbcreate(cur_dir+"tmp3file", {;
 {"_N_ZAP",     "N",  8,0},;
 {"_REFREASON", "N",  3,0};
})
use (cur_dir+"tmp1file") new alias TMP1
append blank
use (cur_dir+"tmp2file") new alias TMP2
use (cur_dir+"tmp3file") new alias TMP3
FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
  @ maxrow(),1 say padr(lstr(j),6) color cColorSt2Msg
  oXmlNode := oXmlDoc:aItems[1]:aItems[j]
  do case
    case "ZGLV" == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke(oXmlNode,"VERSION", aerr)
      tmp1->_DATA    := xml2date(mo_read_xml_stroke(oXmlNode,"DATA",    aerr))
      tmp1->_FILENAME:=          mo_read_xml_stroke(oXmlNode,"FILENAME",aerr)
    case "SCHET" == oXmlNode:title
      tmp1->_CODE    :=      val(mo_read_xml_stroke(oXmlNode,"CODE",   aerr))
      tmp1->_CODE_MO :=          mo_read_xml_stroke(oXmlNode,"CODE_MO",aerr)
      tmp1->_YEAR    :=      val(mo_read_xml_stroke(oXmlNode,"YEAR",   aerr))
      tmp1->_MONTH   :=      val(mo_read_xml_stroke(oXmlNode,"MONTH",  aerr))
      tmp1->_NSCHET  :=          mo_read_xml_stroke(oXmlNode,"NSCHET", aerr)
      tmp1->_DSCHET  := xml2date(mo_read_xml_stroke(oXmlNode,"DSCHET", aerr))
    case "ZAP" == oXmlNode:title
      select TMP2
      append blank
      tmp2->_N_ZAP := val(mo_read_xml_stroke(oXmlNode,"N_ZAP",aerr))
      if (oNode1 := oXmlNode:Find("PACIENT")) == NIL
        aadd(aerr,'Отсутствует значение обязательного тэга "PACIENT"')
      else
        tmp2->_ID_PAC := upper(mo_read_xml_stroke(oNode1,"ID_PAC",aerr))
        tmp2->_VPOLIS :=   val(mo_read_xml_stroke(oNode1,"VPOLIS",aerr))
        tmp2->_SPOLIS :=       mo_read_xml_stroke(oNode1,"SPOLIS",aerr,.f.)
        tmp2->_NPOLIS :=       mo_read_xml_stroke(oNode1,"NPOLIS",aerr)
        tmp2->_ENP    :=       mo_read_xml_stroke(oNode1,"ENP"   ,aerr,.f.)
        tmp2->_SMO    :=       mo_read_xml_stroke(oNode1,"SMO"   ,aerr)
        tmp2->_SMO_OK :=       mo_read_xml_stroke(oNode1,"SMO_OK",aerr)
        tmp2->_MO_PR  :=       mo_read_xml_stroke(oNode1,"MO_PR" ,aerr,.f.)
        tmp2->_IDENTITY := val(mo_read_xml_stroke(oNode1,"IDENTITY",aerr,.f.))
        if empty(tmp2->_MO_PR)
          tmp2->_MO_PR := replicate("0",6)
        endif
        if (oNode2 := oNode1:Find("CORRECTION")) != NIL
          tmp2->_FAM := mo_read_xml_stroke(oNode2,"FAM",aerr,.f.)
          tmp2->_IM  := mo_read_xml_stroke(oNode2,"IM",aerr,.f.)
          tmp2->_OT  := mo_read_xml_stroke(oNode2,"OT",aerr,.f.)
          tmp2->_DR  := mo_read_xml_stroke(oNode2,"DR",aerr,.f.)
          if oNode2:Find("OT") != NIL .and. empty(tmp2->_OT)
            tmp2->CORRECT := "OT" // т.е. пустое отчество
          endif 
        endif
      endif
      if (oNode1 := oXmlNode:Find("SLUCH")) == NIL
        aadd(aerr,'Отсутствует значение обязательного тэга "SLUCH"')
      else
        tmp2->_IDCASE :=   val(mo_read_xml_stroke(oNode1,"IDCASE",aerr))
        tmp2->_ID_C   := upper(mo_read_xml_stroke(oNode1,"ID_C"  ,aerr))
        tmp2->_OPLATA :=   val(mo_read_xml_stroke(oNode1,"OPLATA",aerr))
        if tmp2->_OPLATA > 1
          _ar := mo_read_xml_array(oNode1,"REFREASON")
          for j1 := 1 to len(_ar)
            select TMP3
            append blank
            tmp3->_N_ZAP := tmp2->_N_ZAP
            tmp3->_REFREASON := val(_ar[j1])
          next
        endif
      endif
  endcase
NEXT j
commit
rest_box(buf)
return NIL
