***** различные функции общего пользования - mo_func.prg
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"
 
***** 21.08.17
Function run_my_hrb(name_hrb,name_func)
Local x, handle, n_file := dir_exe+name_hrb+".hrb"
if hb_FileExists(n_file)
  handle := hb_hrbLoad(n_file)
  x := &(name_func)   // функция из name_hrb.hrb
  hb_hrbUnload( handle )
else
  func_error(4,"Не обнаружен файл "+n_file)
endif
Return Nil

***** записать объём работы операторов
Function write_work_oper(_pt,_tp,_ae,_kk,_kp,_open)
// {"PD",      "C",   4,   0},; // дата ввода c4tod(pd)
// {"PO",      "C",   1,   0},; // код оператора asc(po)
// {"PT",      "C",   1,   0},; // код задачи
// {"TP",      "C",   1,   0},; // тип (1-карточка, 2-л/у, 3-услуги)
// {"AE",      "C",   1,   0},; // 1-добавление, 2-редактирование, 3-удаление
// {"KK",      "C",   3,   0},; // кол-во (карточек, л/у или услуг)
// {"KP",      "C",   3,   0};  // количество введённых полей
Static llen := 6
DEFAULT _kk TO 1, _kp TO 0, _open TO .t.
if yes_parol .and. hb_FileExists(dir_server+"mo_opern"+sdbf) .and.;
    iif(_open, G_Use(dir_server+"mo_opern",dir_server+"mo_opern","OP"), .t.)
  _pt := chr(_pt)
  _tp := chr(_tp)
  _ae := chr(_ae)
  find (c4sys_date+kod_polzovat+_pt+_tp+_ae)
  if found()
    G_RLock(forever)
    op->kk := ft_sqzn(_kk + ft_unsqzn(op->kk,llen), llen)
    op->kp := ft_sqzn(_kp + ft_unsqzn(op->kp,llen), llen)
  else
    G_RLock(.t.,forever)
    op->PD := c4sys_date
    op->PO := kod_polzovat
    op->pt := _pt
    op->tp := _tp
    op->ae := _ae
    op->kk := ft_sqzn(_kk, llen)
    op->kp := ft_sqzn(_kp, llen)
  endif
  if _open
    op->(dbCloseArea())
  endif
endif
return NIL

***** проверить, более одного ли слова отдельно в фамилии, имени и отчестве
Function TwoWordFamImOt(s)
Static arr_char := {" ","-",".","'",'"'}
Local i, fl := .f.
s := alltrim(s)
for i := 1 to len(arr_char)
  if arr_char[i] $ s
    fl := .t. ; exit
  endif
next
return fl

***** проверить отдельно фамилию, имя и отчество в GET'ах
Function valFamImOt(ltip,s,par,/*@*/msg)
Static arr_pole := {"Фамилия","Имя","Отчество"}
Static arr_char := {" ","-",".","'",'"'}
Local fl := .t., i, c, s1 := "", nword := 0, get, r := row()
DEFAULT par TO 1
s := alltrim(s)
for i := 1 to len(arr_char)
  s := charone(arr_char[i],s)
next
if len(s) > 0
  s := upper(left(s,1))+substr(s,2)
endif
for i := 1 to len(s)
  c := substr(s,i,1)
  if isralpha(c)
    //
  elseif ascan(arr_char,c) > 0
    ++nword
  else
    s1 += c
  endif
next
msg := ""
if !empty(s1)
  msg := 'В поле "'+arr_pole[ltip]+'" обнаружены недопустимые символы "'+s1+'"'
elseif empty(s) .and. ltip < 3
  msg := 'Пустое значение поля "'+arr_pole[ltip]+'" недопустимо'
endif
if par == 1  // для GET-системы
  Private tmp := readvar()
  &tmp := padr(s,40)
  if empty(msg) .and. nword > 0
    if (get := get_pointer(tmp)) != NIL
      r := get:Row
    endif
    fl := .f.
    MyBell()
    if f_alert({padc('В поле "'+arr_pole[ltip]+'" занесено '+lstr(nword+1)+' слова',60,'.')},;
               {' Возврат в редактирование ',' Правильное поле '},;
               1,"W+/N","N+/N",r+1,,"W+/N,N/BG") == 2
      fl := .t.
    endif
  endif
endif
if !empty(msg)
  if par == 1  // для GET-системы
    fl := func_error(4,msg)
  else  // для проверки ТФОМС
    fl := .f.
  endif
endif
return fl

***** 02.09.15 вернуть отдельно фамилию, имя и отчество в массиве
Function retFamImOt(ltip,fl_no,is_open_kfio)
Static cDelimiter := " ."
Local i, k := 0, s := "", s1, mfio, tmp_select, ret_arr := {"","",""}
DEFAULT fl_no TO .t., is_open_kfio TO .f.
if ltip == 1 // вызвали из картотеки
  mfio := kart->fio
else  // вызвали из листа учёта
  mfio := human->fio
  if human->kod_k != kart->kod // если не связаны по relation
    kart->(dbGoto(human->kod_k))
  endif
endif
if kart->MEST_INOG == 9 // т.е. отдельно занесены Ф.И.О.
  tmp_select := select()
  if is_open_kfio
    select KFIO
  else
    R_Use(dir_server+"mo_kfio",,"KFIO")
    index on str(kod,7) to (cur_dir+"tmp_kfio")
  endif
  find (str(kart->kod,7))
  if found()
    ret_arr[1] := alltrim(kfio->FAM)
    ret_arr[2] := alltrim(kfio->IM)
    ret_arr[3] := alltrim(kfio->OT)
  endif
  if !is_open_kfio
    kfio->(dbCloseArea())
  endif
  select (tmp_select)
endif
if empty(ret_arr[1]) // на всякий случай - вдруг не нашли в "mo_kfio"
  mfio := alltrim(mfio)
  for i := 1 to numtoken(mfio,cDelimiter)
    s1 := alltrim(token(mfio,cDelimiter,i))
    if !empty(s1)
      ++k
      if k < 3
        ret_arr[k] := s1
      else
        s += s1+" "
      endif
    endif
  next
  ret_arr[3] := alltrim(s)
endif
if fl_no .and. empty(ret_arr[3])
  ret_arr[3] := "НЕТ"
endif
return ret_arr

***** 26.10.14 проверка на правильность введённого ФИО
Function val_fio(afio,aerr)
Local i, k := 0, msg
DEFAULT aerr TO {}
for i := 1 to 3
  valFamImOt(i,afio[i],2,@msg)
  if !empty(msg)
    ++k ; aadd(aerr,msg)
  endif
next
return (k == 0)

***** 26.08.14 вернуть иногороднюю СМО
Function ret_inogSMO_name(ltip,/*@*/rec,fl_close)
Local s := space(100), fl := .f., tmp_select := select()
DEFAULT fl_close TO .f.
if select("SN") == 0
  R_Use(dir_server+iif(ltip==1,"mo_kismo","mo_hismo"),,"SN")
  index on str(kod,7) to (cur_dir+"tmp_ismo")
  fl := .t.
endif
select SN
find (str(iif(ltip==1,kart->kod,human->kod),7))
if found()
  s := sn->SMO_NAME
  rec := sn->(recno())
endif
if fl .and. fl_close
  sn->(dbCloseArea())
endif
select (tmp_select)
return s

***** 22.05.15 СМО на экран (печать)
Function smo_to_screen(ltip)
Local s := "", s1 := "", lsmo, nsmo, lokato
lsmo := iif(ltip==1,kart_->smo,human_->smo) ; nsmo := int(val(lsmo))
s := inieditspr(A__MENUVERT,glob_arr_smo,nsmo)
if empty(s) .or. nsmo == 34
  if nsmo == 34
    s1 := ret_inogSMO_name(ltip,,.t.)
  else
    s1 := init_ismo(lsmo)
  endif
  if !empty(s1)
    s := alltrim(s1)
  endif
  lokato := iif(ltip==1,kart_->KVARTAL_D,human_->okato)
  if !empty(lokato)
    s += "/"+inieditspr(A__MENUVERT, glob_array_srf, lokato)
  endif
endif
return s

***** 15.10.14 проверка корректности GUID
Function valid_GUID(s,par)
// par = 1 - GUID из моей программы
// par = 2 - GUID из чужой программы
Local fl := .t.
DEFAULT par TO 1
if par == 1
  if len(charrem(" ",s)) < 36
    fl := .f.
  else
    fl := empty(CHARREPL("0123456789ABCDEF-", upper(s), SPACE(17)))
  endif
else // par = 2 - GUID из чужой программы
  fl := !empty(s) // просто проверим на пустоту
endif
return fl

***** составить GUID
Function mo_guid(par1,par2)
// par1 - от 1 до 3
//        .XXXXX...... для par1 = 1
//        ....XXXXX... для par1 = 2
//        .......XXXXX для par1 = 3
//        .....XXXXXX. для par1 = 4
// par2 - номер записи
Local s, s1, s2, k, l
s := f1CreateGUID(8) + "-" + ;
     f1CreateGUID(4) + "-" + ;
     f1CreateGUID(4) + "-" + ;
     f1CreateGUID(4) + "-"
s1 := f1CreateGUID(12)
s2 := ntoc(par2,16) // номер записи -> в 16-ричное число (строку)
l := len(s2) // длина 16-ричной строки
k := {6,9,12,11}[par1] - l + 1 // номер позиции, с которой будем замещать
return s+stuff(s1,k,l,s2)

*****
Static Function f1CreateGUID(tmpLength)
Static strValid := "0123456789ABCDEF"
Local tmpCounter, tmpGUID := ""
For tmpCounter := 1 To tmpLength
  tmpGUID += substr(strValid, random()%16 + 1, 1)
Next
return tmpGUID

***** 21.01.17 определить диапазоны номеров пакетов
Function f_mb_me_nsh(_nyear,/*@*/mb,/*@*/me)
if mem_bnn13rees <= 0 .or. mem_enn13rees <= 0
  if mem_bnn_rees == 1
    mem_bnn13rees := mem_bnn_rees
  else
    mem_bnn13rees := int(val(lstr(mem_bnn_rees)+"0"))
  endif
  mem_enn13rees := int(val(lstr(mem_enn_rees)+"9"))
endif
mb := mem_bnn13rees
me := mem_enn13rees
/*if _nyear < 2013 .and. mem_bnn_rees == 1
  mb := 100
endif*/
return iif(_nyear < 2017, 3, 5) // начиная с 2017 года - 5 символов

***** 09.03.22 если это укрупнённый архив, распаковать и прочитать
Function Is_Our_ZIP(cName,/*@*/tip_csv_file,/*@*/kod_csv_reestr)
Static cStFile, si
Local fl := .f., arr := {}, arr_f, i, s := cName, s1, name_ext, _date, _time, c
DEFAULT cStFile TO cName
if left(s,3) == "RI0" .or. left(s,2) == "I0"
  fl := func_error(4,'Данный файл необходимо читать в подзадаче "Учёт направлений на госпитализацию"')
elseif eq_any(left(s,8),"RHRT34_M","RFRT34_M") .and. substr(s,9,6) == glob_MO[_MO_KOD_TFOMS]
  c := substr(s,2,1)
  if (arr_f := Extract_Zip_XML(KeepPath(full_zip),StripPath(full_zip),2)) != NIL
    for i := 1 to len(arr_f)
      s := upper(arr_f[i]) ; name_ext := Name_Extention(s)
      do case
        case left(s,8) == "P"+c+"RT34_M" .and. name_ext == spdf
          aadd(arr,{1,"протокол обработки поступивших сведений "+s,s,name_ext})
        case eq_any(left(s,4),"V"+c+"RM","P"+c+"RM") .and. name_ext == szip
          s1 := "протокол ФЛК "+s
          // проверим, читали ли уже данный файл
          if Verify_Is_Already_XML(Name_Without_Ext(s),@_date,@_time)
            s1 += " [прочитан в "+_time+" "+date_8(_date)+"г.]"
          endif
          aadd(arr,{2,s1,s,name_ext})
        case left(s,8) == "M"+c+"RT34_M" .and. name_ext == spdf
          aadd(arr,{3,"сведения о выполнении плана-задания "+s,s,name_ext})
        case left(s,8) == "F"+c+"RT34_M" .and. name_ext == spdf
          aadd(arr,{4,"сведения о выполнении обьемов ФО "+s,s,name_ext})
        case left(s,7) == c+"RT34_M" .and. name_ext == szip
          s1 := "реестр СП и ТК "+s
          // проверим, читали ли уже данный файл
          if Verify_Is_Already_XML(Name_Without_Ext(s),@_date,@_time)
            s1 += " [прочитан в "+_time+" "+date_8(_date)+"г.]"
          endif
          aadd(arr,{5,s1,s,name_ext})
      endcase
    next
    asort(arr,,,{|x,y| x[1] < y[1] })
    arr_f := {} ; aeval(arr,{|x| aadd(arr_f,x[2])})
    i := iif(cStFile == cName, si, 1)
    if (i := popup_prompt(T_ROW,T_COL-5,i,arr_f)) > 0
      cStFile := cName ; si := i
      if arr[i,4] == spdf
        // file_AdobeReader(_tmp2dir1+arr[i,3])
        view_file_in_Viewer(_tmp2dir1 + arr[i, 3])
      elseif arr[i,4] == szip
        fl := .t.
        full_zip := _tmp2dir1+arr[i,3] // переопределяем Private-переменную
      endif
    endif
  endif
elseif left(s,6) == glob_MO[_MO_KOD_TFOMS]
  if (arr_f := Extract_Zip_XML(KeepPath(full_zip),StripPath(full_zip),2)) != NIL
    for i := 1 to len(arr_f)
      s := upper(arr_f[i]) ; name_ext := Name_Extention(s)
      do case
        case left(s,1) == "R" .and. name_ext == spdf
          aadd(arr,{1,"протокол приёма поступивших счетов ОМС "+s,s,name_ext})
        case left(s,2) == "NR" .and. name_ext == spdf
          aadd(arr,{2,"протокол отклонения поступивших счетов ОМС "+s,s,name_ext})
      endcase
    next
    asort(arr,,,{|x,y| x[1] < y[1] })
    arr_f := {} ; aeval(arr,{|x| aadd(arr_f,x[2])})
    if (i := popup_prompt(T_ROW,T_COL-5,1,arr_f)) > 0
      if arr[i,4] == spdf
        // file_AdobeReader(_tmp2dir1+arr[i,3])
        view_file_in_Viewer(_tmp2dir1 + arr[i, 3])
      endif
    endif
  endif
elseif eq_any(left(s,1),"A","D") // файлы РАК и РПД
  fl := .t.
  s := substr(s,2)
  if eq_any(left(s,1),"T","S")
    s := substr(s,2)
    cFrom := beforatnum("M",s) ; nSMO := int(val(cFrom))
    if ascan(glob_arr_smo,{|x| x[2] == nSMO }) > 0
      s := afteratnum("M",s)
      if beforatnum("_",s) == glob_MO[_MO_KOD_TFOMS] .and. ;
         (arr_f := Extract_Zip_XML(KeepPath(full_zip),StripPath(full_zip),2,"tmp"+szip)) != NIL
        for i := 1 to len(arr_f)
          if upper(cName+szip) == upper(arr_f[i])
            full_zip := _tmp2dir1+arr_f[i] // переопределяем Private-переменную
            exit
          endif
        next
      endif
    endif
  endif
elseif eq_any(left(s,2),"E2","O2") // файлы протокола прикрепления и открепления
  fl := .t.
  tip_csv_file := iif(left(s,1)=="E",_CSV_FILE_ANSWER,_CSV_FILE_OTKREP)
  kod_csv_reestr := 0
  if (s1 := substr(s,3,6)) == glob_MO[_MO_KOD_TFOMS]
    R_Use(dir_server+"mo_krtf",,"KRTF")
    index on upper(fname) to (cur_dir+"tmp_krtf")
    find (padr(s,26)) // не принимали ли уже данный файл
    if found()
      fl := func_error(4,"Этот файл уже был прочитан в "+krtf->TFILE+" "+date_8(krtf->DFILE)+"г.")
      viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+cName+stxt,60,80),,,,.t.,,,2)
    elseif tip_csv_file == _CSV_FILE_ANSWER
      find (padr("MO"+substr(s,2),26)) // имя то же самое, начиная с третьего знака
      if found()
        kod_csv_reestr := krtf->REESTR
      else
        fl := func_error(4,"Файл прикрепления для данного протокола обработки мы не отправляли в ТФОМС!")
      endif
    endif
    krtf->(dbCloseArea())
  else
    fl := func_error(4,"Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+s1)
    if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == s1})) > 0
      func_error(4,"Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
    endif
  endif
elseif left(s,3) == "SO2" // ответ на запрос сверки
  fl := .t.
  tip_csv_file := _CSV_FILE_SVERKAO
  kod_csv_reestr := 0
  if (s1 := substr(s,4,6)) == glob_MO[_MO_KOD_TFOMS]
    R_Use(dir_server+"mo_krtf",,"KRTF")
    index on upper(fname) to (cur_dir+"tmp_krtf")
    find (padr(s,26)) // не принимали ли уже данный файл
    if found()
      fl := func_error(4,"Этот файл уже был прочитан в "+krtf->TFILE+" "+date_8(krtf->DFILE)+"г.")
      viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+cName+stxt,60,80),,,,.t.,,,2)
    else
      find (padr("SZ"+substr(s,3),26)) // имя то же самое, начиная с третьего знака
      if found()
        kod_csv_reestr := krtf->REESTR
      else
        fl := func_error(4,"Файл запроса по сверке для данного протокола обработки мы не отправляли в ТФОМС")
      endif
    endif
    krtf->(dbCloseArea())
  else
    fl := func_error(4,"Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+;
                       " не соответствует коду получателя: "+s1)
    if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == s1})) > 0
      func_error(4,"Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
    endif
  endif
else
  fl := .t.
endif
return fl

***** 17.06.15 если это файл с расширениием CSV - прочитать
Function Is_Our_CSV(cName,/*@*/tip_csv_file,/*@*/kod_csv_reestr)
Local fl := .f., i, s := cName, s1
if eq_any(left(s,3),"EO2","LO2") // файлы протокола прикрепления и открепления
  fl := .t.
  tip_csv_file := iif(left(s,1)=="E",_CSV_FILE_PRIKANS,_CSV_FILE_PRIKFLK)
  kod_csv_reestr := 0
  if (s1 := substr(s,4,6)) == glob_MO[_MO_KOD_TFOMS]
    R_Use(dir_server+"mo_krtf",,"KRTF")
    index on upper(fname) to (cur_dir+"tmp_krtf")
    find (padr(s,26)) // не принимали ли уже данный файл
    if found()
      fl := func_error(4,"Этот файл уже был прочитан в "+krtf->TFILE+" "+date_8(krtf->DFILE)+"г.")
      viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+cName+stxt,60,80),,,,.t.,,,2)
    else
      find (padr("M"+substr(s,2),26)) // имя то же самое, начиная со второго знака
      if found()
        kod_csv_reestr := krtf->REESTR
        R_Use(dir_server+"mo_krtr",,"KRTR")
        goto (kod_csv_reestr)
        if krtr->ANSWER == 0 .and. tip_csv_file == _CSV_FILE_PRIKANS
          fl := func_error(4,"Сначала необходимо прочитать файл L"+substr(s,2)+scsv)
        endif
        krtr->(dbCloseArea())
      else
        fl := func_error(4,"Файл прикрепления для данного протокола обработки мы не отправляли в ТФОМС!")
      endif
    endif
    krtf->(dbCloseArea())
  else
    fl := func_error(4,"Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+s1)
    if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == s1})) > 0
      func_error(4,"Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
    endif
  endif
else
  fl := func_error(4,"Неизвестный файл")
endif
return fl

***** 17.12.19 проверить, нам ли предназначен данный XML-файл
Function Is_Our_XML(cName,ret_arr)
Local c, arr_err := {}, i, s, nSMO, nTypeFile, cFrom, cTo, _nYear, _nMonth, nNN, nReestr := 0
s := cName
if eq_any(left(s,3),"VHR","VFR","PHR","PFR") // файл протокола ФЛК
  nTypeFile := _XML_FILE_FLK
  R_Use(dir_server+"mo_rees",,"REES")
  R_Use(dir_server+"mo_xml",,"MO_XML")
  index on upper(fname) to (cur_dir+"tmpmoxml")
  find (padr(substr(s,2),26)) // имя то же самое, начиная со второго знака
  if found() .and. (nReestr := mo_xml->REESTR) > 0
    select REES
    goto (nReestr)
    cFrom   := glob_MO[_MO_KOD_TFOMS]
    cTo     := '34'
    _nYear  := rees->NYEAR
    _nMonth := rees->NMONTH
    nNN     := rees->NN
  else
    aadd(arr_err, "Это файл ФЛК, но мы не отправляли соответствующий реестр случаев в ТФОМС!")
  endif
  rees->(dbCloseArea())
  mo_xml->(dbCloseArea())
elseif eq_any(left(s,3),"D02","R02","R12","R06") // ответный файл на отосланный файл D01 R01 (R05)
  s := substr(s,4)
  if left(s,1) == "M"
    s := substr(s,2)
  else
    aadd(arr_err, "Неверная буква в обозначении получателя: "+s)
  endif
  if len(arr_err) == 0
    cTo := left(s,6)
    if !(cTo == glob_MO[_MO_KOD_TFOMS])
      aadd(arr_err, "Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+cTo)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
        aadd(arr_err, "Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
      endif
    endif
    s := substr(s,7)
    if left(s,3) == "T34"
      s := afteratnum("_",s)
    else
      aadd(arr_err, "Неверный отправитель: "+s)
    endif
  endif
  if len(arr_err) == 0
    if left(cName,3) == "D02"
      nTypeFile := _XML_FILE_D02
      R_Use(dir_server+"mo_d01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr("D01T34M"+glob_MO[_MO_KOD_TFOMS]+"_"+s,26)) // сконструировали имя файла D01
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->MM
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на D01, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    elseif left(cName,3) == "R02"
      nTypeFile := _XML_FILE_R02
      R_Use(dir_server+"mo_dr01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr("R01T34M"+glob_MO[_MO_KOD_TFOMS]+"_"+s,26)) // сконструировали имя файла R01
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->NQUARTER
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R01, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    elseif left(cName,3) == "R12"
      nTypeFile := _XML_FILE_R12
      R_Use(dir_server+"mo_dr01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr("R11T34M"+glob_MO[_MO_KOD_TFOMS]+"_"+s,26)) // сконструировали имя файла R11
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->NQUARTER
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R11, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    else // "R06"
      nTypeFile := _XML_FILE_R06
      R_Use(dir_server+"mo_dr05",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr("R05T34M"+glob_MO[_MO_KOD_TFOMS]+"_"+s,26)) // сконструировали имя файла R05
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := 0
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R05, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    endif
  endif
elseif eq_any(left(s,4),"PR01","PR11","PR05") // ответный файл на отосланный файл R01 (R11) (R05)
  s := substr(s,8)
  if left(s,1) == "M"
    s := substr(s,2)
  else
    aadd(arr_err, "Неверная буква в обозначении получателя: "+s)
  endif
  if len(arr_err) == 0
    cTo := left(s,6)
    if !(cTo == glob_MO[_MO_KOD_TFOMS])
      aadd(arr_err, "Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+cTo)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
        aadd(arr_err, "Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
      endif
    endif
    s := substr(cName,5,3)
    if !(left(s,3) == "T34")
      aadd(arr_err, "Неверный отправитель: "+s)
    endif
  endif
  if len(arr_err) == 0
    if left(cName,4) == "PR01"
      nTypeFile := _XML_FILE_R02
      R_Use(dir_server+"mo_dr01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr(substr(cName,2),26)) // сконструировали имя файла R01
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->NMONTH
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R01, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    elseif left(cName,4) == "PR11"
      nTypeFile := _XML_FILE_R12
      R_Use(dir_server+"mo_dr01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr(substr(cName,2),26)) // сконструировали имя файла R01
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->NMONTH
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R11, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    else // "R06"
      nTypeFile := _XML_FILE_R06
      R_Use(dir_server+"mo_dr05",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr(substr(cName,2),26)) // сконструировали имя файла R05
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := 0
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R05, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    endif
  endif
elseif eq_any(left(s,4),"PR01","PR11","PR05") // ответный файл на отосланный файл R01 (R11) (R05)
  s := substr(s,8)
  if left(s,1) == "M"
    s := substr(s,2)
  else
    aadd(arr_err, "Неверная буква в обозначении получателя: "+s)
  endif
  if len(arr_err) == 0
    cTo := left(s,6)
    if !(cTo == glob_MO[_MO_KOD_TFOMS])
      aadd(arr_err, "Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+cTo)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
        aadd(arr_err, "Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
      endif
    endif
    s := substr(cName,5,3)
    if !(left(s,3) == "T34")
      aadd(arr_err, "Неверный отправитель: "+s)
    endif
  endif
  if len(arr_err) == 0
    if eq_any(left(cName,4),"PR01","PR11")
      nTypeFile := _XML_FILE_R02
      R_Use(dir_server+"mo_dr01",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr(substr(cName,2),26)) // сконструировали имя файла R01
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := rees->NMONTH
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R01(R11), но мы не отправляли такой пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    else // "R06"
      nTypeFile := _XML_FILE_R06
      R_Use(dir_server+"mo_dr05",,"REES")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      index on upper(fname) to (cur_dir+"tmpmoxml")
      find (padr(substr(cName,2),26)) // сконструировали имя файла R05
      if found() .and. (nReestr := mo_xml->REESTR) > 0
        select REES
        goto (nReestr)
        cFrom   := '34'
        cTo     := glob_MO[_MO_KOD_TFOMS]
        _nYear  := rees->NYEAR
        _nMonth := 0
        nNN     := rees->NN
      else
        aadd(arr_err, "Это файл ответа на R05, но мы не отправляли соответствующий пакет в ТФОМС!")
      endif
      rees->(dbCloseArea())
      mo_xml->(dbCloseArea())
    endif
  endif
else
  if eq_any(left(s,2),"HR","FR") // файл реестра СП
    s := substr(s,3)
    nTypeFile := _XML_FILE_SP
  elseif left(s,1) == "A" // файл РАК
    s := substr(s,2)
    nTypeFile := _XML_FILE_RAK
  elseif left(s,1) == "D" // файл РПД
    s := substr(s,2)
    nTypeFile := _XML_FILE_RPD
  else
    aadd(arr_err, "Попытка прочитать незнакомый файл")
  endif
  if left(s,1) == "T"
    // из ТФОМС
  elseif left(s,1) == "S"
    // от СМО
  else
    aadd(arr_err, "Неверная буква в обозначении отправителя: "+s)
  endif
  if len(arr_err) == 0
    if nTypeFile == _XML_FILE_SP
      s := substr(s,2)
      cFrom := beforatnum("_",s) ; nSMO := int(val(cFrom))
      if ascan(glob_arr_smo,{|x| x[2] == nSMO }) == 0
        aadd(arr_err, "Неверный код отправителя: "+cFrom)
      endif
      if len(arr_err) == 0
        s := afteratnum("_",s)
        if left(s,1) == "M"
          s := substr(s,2)
        else
          aadd(arr_err, "Неверная буква в обозначении получателя: "+s)
        endif
        if len(arr_err) == 0
          cTo := left(s,6)
          if !(cTo == glob_MO[_MO_KOD_TFOMS])
            aadd(arr_err, "Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+;
                          " не соответствует коду получателя: "+cTo)
            if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
              aadd(arr_err, "Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
            endif
          endif
        endif
        if len(arr_err) == 0
          s := substr(s,7)
          _nYear := int(val("20"+left(s,2)))
          _nMonth := int(val(substr(s,3,2)))
          nNN := int(val(substr(s,5))) // берём строку до конца
        endif
      endif
    elseif eq_any(nTypeFile,_XML_FILE_RAK,_XML_FILE_RPD)
      s := substr(s,2)
      cFrom := beforatnum("M",s) ; nSMO := int(val(cFrom))
      if ascan(glob_arr_smo,{|x| x[2] == nSMO }) == 0
        aadd(arr_err, "Неверный код отправителя: "+cFrom)
      endif
      if len(arr_err) == 0
        s := afteratnum("M",s)
        cTo := beforatnum("_",s)
        if !(cTo == glob_MO[_MO_KOD_TFOMS])
          aadd(arr_err, "Ваш код МО "+glob_MO[_MO_KOD_TFOMS]+" не соответствует коду получателя: "+cTo)
          if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cTo})) > 0
            aadd(arr_err, "Это файл для: "+glob_arr_mo[i,_MO_SHORT_NAME])
          endif
        endif
        if len(arr_err) == 0
          s := afteratnum("_",s)
          _nYear := int(val("20"+left(s,2)))
          _nMonth := int(val(substr(s,3,2)))
          nNN := int(val(substr(s,5))) // берём строку до конца
        endif
      endif
    endif
  endif
endif
if len(arr_err) == 0
  ret_arr[1] := nTypeFile
  ret_arr[2] := cFrom
  ret_arr[3] := cTo
  ret_arr[4] := _nYear
  ret_arr[5] := _nMonth
  ret_arr[6] := nNN
  ret_arr[7] := nReestr
else
  Ins_Array(arr_err,1,"")
  Ins_Array(arr_err,1,"Принимаемый файл: "+cName)
  n_message(arr_err,,"GR+/R","W+/R",,,"G+/R")
endif
return (len(arr_err) == 0)

***** проверить, занесен ли данный файл в "mo_xml"
Function Verify_Is_Already_XML(cName,/*@*/_date,/*@*/_time)
Local l, fl, tmp_select := select()
R_Use(dir_server+"mo_xml",,"MX")
index on upper(FNAME) to (cur_dir+"tmp_mxml")
l := fieldlen(fieldnum("FNAME"))
find (padr(cName,l))
if (fl := found())
  if mx->tip_in > 0  // если принимаемый файл
    _date := mx->DREAD  // то вернём дату последнего чтения (обработки)
    _time := mx->TREAD
  else               // если отсылаемый файл
    _date := mx->DFILE  // то вернём дату создания файла
    _time := mx->TFILE
  endif
endif
mx->(dbCloseArea())
select (tmp_select)
return fl

***** 20.10.14 зачитать CSV-файл в двумерный массив
Function read_CSV_to_array(cFile_csv)
Local arr := {}, _ar, i, s, s1, lfp
lfp := fopen(cFile_csv)
do while !feof(lfp)
  if !empty(s := fReadLn(lfp))
    _ar := {}
    for i := 1 to numtoken(s,";",1)
      s1 := alltrim(charrem('"',token(s,";",i,1)))
      aadd(_ar, hb_AnsiToOem(s1))
    next
    for i := 1 to 25
      aadd(_ar, " ") // добавим 25 полей (вдруг что-то не так со строкой)
    next
    aadd(arr,aclone(_ar))
  endif
enddo
fclose(lfp)
return arr

***** проверить, существует файл nfile, и попытаться удалить его
Function myFileDeleted(nfile)
Static sn := 100 // делаем 100 попыток
Local i := 0, fl := .f.
do while i < sn
  if hb_FileExists(nfile)
    delete file (nfile)
  else
    fl := .t. ; exit
  endif
  ++i
enddo
if !fl
  func_error(4,"Неудачная попытка удаления файла "+nfile+". Попытайтесь снова")
endif
return fl

***** строка даты для XML-файла
Function date2xml(mdate)
return strzero(year(mdate),4)+'-'+;
       strzero(month(mdate),2)+'-'+;
       strzero(day(mdate),2)

***** пребразовать дату из "2002-02-01" в тип "DATE"
Function xml2date(s)
return stod(charrem("-",s))

***** 30.01.14 проверить наличие тэга(ов) и вернуть его(их) значение(я) в массиве
Function mo_read_xml_array(_node,_title)
Local j1, oNode2, arr := {}
for j1 := 1 to len(_node:aitems)
  oNode2 := _node:aItems[j1]
  if upper(_title) == upper(oNode2:title) .and. !empty(oNode2:aItems) ;
                                          .and. valtype(oNode2:aItems[1]) == "C"
    aadd(arr, oNode2:aItems[1])
  endif
next
return arr

***** проверить наличие в узле _node XML-файла тэга _title и вернуть его значение
Function mo_read_xml_stroke(_node,_title,_aerr,_binding)
// _node - указатель на узел
// _title - наименование тэга
// _aerr - массив сообщений об ошибках
// _binding - обязателен ли атрибут (по-умолчанию .T.)
Local ret := "", oNode, yes_err := (valtype(_aerr) == "A"),;
      s_msg := 'Отсутствует значение обязательного тэга "'+_title+'"'
DEFAULT _binding TO .t.
// ищем необходимый "_title" тэг в узле "_node"
oNode := _node:Find(_title)
if oNode == NIL .and. _binding .and. yes_err
  aadd(_aerr,s_msg)
endif
if oNode != NIL
  ret := mo_read_xml_tag(oNode,_aerr,_binding)
endif
return ret

***** 11.12.17 вернуть значение тэга
Function mo_read_xml_tag(oNode,_aerr,_binding)
// oNode - указатель на узел
// _aerr - массив сообщений об ошибках
// _binding - обязателен ли атрибут (по-умолчанию .T.)
Local ret := "", c, yes_err := (valtype(_aerr) == "A"),;
      s_msg := 'Отсутствует значение обязательного тэга "'+oNode:title+'"'
DEFAULT _binding TO .t.
if empty(oNode:aItems)
  if _binding .and. yes_err
    aadd(_aerr,s_msg)
  endif
elseif (c := valtype(oNode:aItems[1])) == "C"
  if type("p_xml_code_page") == "C" .and. upper(p_xml_code_page) == "UTF-8"
    ret := hb_Utf8ToStr(alltrim(oNode:aItems[1]),"RU866")
  else
    ret := hb_AnsiToOem(alltrim(oNode:aItems[1]))
  endif
elseif yes_err
  aadd(_aerr,'Неверный тип данных у тэга "'+oNode:title+'": "'+c+'"')
endif
return ret

***** 22.11.13 записать в XML-файл строку (открыть тэг, записать значение, закрыть тэг)
Function mo_add_xml_stroke(oNode,sTag,sValue)
Local oXmlNode := oNode:Add( HXMLNode():New(sTag))
sValue := alltrim(sValue)
if type("p_xml_code_page") == "C" .and. upper(p_xml_code_page) == "UTF-8"
  sValue := hb_StrToUtf8(sValue,"RU866")
else
  sValue := hb_OemToAnsi(sValue)
endif
oXmlNode:Add(sValue)
return NIL

***** 15.12.13 корректен ли период для информации "по отчётному периоду"
Function is_otch_period(arr_m)
Local fl := .t.
if !(arr_m[5]==bom(arr_m[5]) .and. arr_m[6]==eom(arr_m[6]))
  fl := func_error(4,"Для отчётного периода необходимо выбирать кратный месяцу период!")
endif
return fl

***** попадает ли отч.период (_YEAR,_MONTH) в диапазон с _begin_date по _end_date
Function between_otch_period(_date,_YEAR,_MONTH,_begin_date,_end_date)
Local mdate
if emptyany(_YEAR,_MONTH)
  mdate := _date // по-старому, т.е. по дате счёта
else
  mdate := stod(strzero(_YEAR,4)+strzero(_MONTH,2)+'15')
endif
return between(mdate,_begin_date,_end_date)


***** 21.10.13 проверить перекрытие диапазонов p1-p2 с d1-d2 для стационара
Function overlap_diapazon(p1,p2,d1,d2)
Local fl := .f.
if p1 == d1 .and. p2 == d2 // абсолютно одинаковые диапазоны лечения
  fl := .t.
elseif p1 == p2 // первое лечение в один день
  if d1 < d2    // а второе лечение более одного дня
    fl := (d1 < p1 .and. p2 < d2) // первое лечение внутри второго
  endif
elseif d1 == d2 // второе лечение в один день
  if p1 < p2    // а первое лечение более одного дня
    fl := (p1 < d1 .and. d2 < p2) // второе лечение внутри первого
  endif
elseif p1 == d1 .or. p2 == d2 // начало ИЛИ окончание лечения в один день
  fl := .t.
else
  if !(fl := ((p1 < d1 .and. d1 < p2) .or. (p1 < d2 .and. d2 < p2)))
    fl := ((d1 < p1 .and. p1 < d2) .or. (d1 < p2 .and. p2 < d2))
  endif
endif
return fl

***** сделать из глобального массива укороченный (отсечь по дате действия)
Function cut_glob_array(_glob_array,_date)
Local i, tmp_array := {}
for i := 1 to len(_glob_array)
  if between_date(_glob_array[i,3],_glob_array[i,4],_date)
    aadd(tmp_array,_glob_array[i])
  endif
next
return tmp_array

***** создать (name_base).DBF из глобального массива (укороченную) (отсечь по дате действия)
FUNCTION init_tmp_glob_array(name_base,_glob_array,_date,is_all)
Local i, len1, len2, f2type, fl_is, tmp_select
DEFAULT name_base TO "tmp_ga", is_all TO .f.
if !myFileDeleted(cur_dir+name_base+sdbf)
  return .f.
endif
tmp_select := select()
len1 := len2 := 0
f2type := valtype(_glob_array[1,2])
for i := 1 to len(_glob_array)
  if iif(is_all, .t., between_date(_glob_array[i,3],_glob_array[i,4],_date))
    len1 := max(len1,len(alltrim(_glob_array[i,1])))
    if f2type == "N"
      len2 := max(len2,len(lstr(_glob_array[i,2])))
    else
      len2 := max(len2,len(alltrim(_glob_array[i,2])))
    endif
  endif
next
dbcreate(name_base,{{"name","C",len1,0},;
                    {"kod",f2type,len2,0},;
                    {"is","L",1,0}})
use (name_base) new alias tmp_ga
for i := 1 to len(_glob_array)
  fl_is := between_date(_glob_array[i,3],_glob_array[i,4],_date)
  if iif(is_all, .t., fl_is)
    append blank
    replace name with _glob_array[i,1], ;
            kod with _glob_array[i,2], ;
            is with fl_is
  endif
next
index on upper(name) to (name_base)
tmp_ga->(dbCloseArea())
select (tmp_select)
return .t.

***** 04.05.13 в GET'е выбрать значение из TMP_GA.DBF (глобального массива) с поиском по подстроке
Function fget_tmp_ga(k,r,c,name_base,browTitle,is_F2,sTitle)
Local ret, fl, cRec, kolRec, nRec, len1, len2, f2type, tmp_select, blk, t_arr[BR_LEN]
DEFAULT name_base TO "tmp_ga", browTitle TO "Наименование", is_F2 TO .t.
tmp_select := select()
use (name_base) index (name_base) new alias tmp_ga
kolRec := lastrec()
len1 := fieldlen(1)
len2 := fieldlen(2)
if r <= maxrow()/2
  t_arr[BR_TOP] := r+1
  if (t_arr[BR_BOTTOM] := t_arr[BR_TOP]+kolRec+3) > maxrow()-2
    t_arr[BR_BOTTOM] := maxrow()-2
  endif
else
  t_arr[BR_BOTTOM] := r-1
  if (t_arr[BR_TOP] := t_arr[BR_BOTTOM]-kolRec-3) < 1
    t_arr[BR_TOP] := 1
  endif
endif
t_arr[BR_LEFT] := c
if (t_arr[BR_RIGHT] := c+len1+3) > 77
  t_arr[BR_RIGHT] := 77
  t_arr[BR_LEFT] := t_arr[BR_RIGHT]-len1-3
  if t_arr[BR_LEFT] < 2
    t_arr[BR_LEFT] := 2
  endif
endif
len1 := t_arr[BR_RIGHT]-t_arr[BR_LEFT]-3
blk := {|| iif(tmp_ga->is, {1,2}, {3,4}) }
t_arr[BR_COLOR] := color0
if sTitle != NIL
  t_arr[BR_TITUL] := sTitle
  t_arr[BR_TITUL_COLOR] := "B/BG"
endif
t_arr[BR_ARR_BROWSE] := {,,,"N/BG,W+/N,B/BG,W+/B",.f.}
t_arr[BR_COLUMN] := {{ center(browTitle,len1), {|| left(tmp_ga->name,len1) },blk }}
if is_F2
  t_arr[BR_EDIT] := {|nk,ob| f1get_tmp_ga(nk,ob,"edit") }
endif
if fieldnum("IDUMP") > 0 //специально для отделений
  t_arr[BR_ENTER] := {|| ret := {tmp_ga->kod,alltrim(tmp_ga->name),tmp_ga->idump,tmp_ga->tiplu} }
else
  t_arr[BR_ENTER] := {|| ret := {tmp_ga->kod,alltrim(tmp_ga->name)} }
endif
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор"+iif(is_F2,";  ^<F2>^ - поиск по подстроке","")) }
f2type := fieldtype(2)
fl := .f. ; nRec := 0
if k != NIL
  go top
  do while !eof()
    if f2type == "N"
      fl := (tmp_ga->kod == k)
    else
      fl := (alltrim(tmp_ga->kod) == alltrim(k))
    endif
    if fl
      cRec := recno()
      exit
    endif
    ++nRec
    skip
  enddo
endif
if !fl
  nRec := 0
endif
go top
if nRec > 0
  if kolRec-nRec < t_arr[BR_BOTTOM]-t_arr[BR_TOP]-3 // последняя страница?
    keyboard chr(K_END)+replicate(chr(K_UP),kolRec-nRec-1)
  else
    goto (cRec)
  endif
endif
edit_browse(t_arr)
tmp_ga->(dbCloseArea())
select (tmp_select)
return ret

***** 23.01.17
Function f1get_tmp_ga(nKey,oBrow,regim,arr)
Static tmp := ""
Local ret := -1, buf, buf1, tmp1, rec1 := recno()
if regim == "edit" .and. nkey == K_INS .and. valtype(arr) == "A" .and. fieldnum("ISN") > 0
  //специально для множественного выбора из справочника новых специальностей V015
  tmp_ga->isn := iif(tmp_ga->isn==1, 0, 1)
  keyboard chr(K_TAB)
  return 0
endif
if !(regim == "edit" .and. nKey == K_F2)
  return ret
endif
buf := savescreen()
do while .t.
  buf1 := save_box(pr2-3,pc1+1,pr2-1,pc2-1)
  box_shadow(pr2-3,pc1+1,pr2-1,pc2-1,color1,"Введите подстроку поиска",color8)
  tmp1 := padr(tmp,15)
  status_key("^<Esc>^ - отказ от ввода")
  @ pr2-2,pc1+(pc2-pc1-15)/2 get tmp1 picture "@K@!" color color8
  myread()
  if lastkey() == K_ESC .or. empty(tmp1)
    exit
  endif
  mywait()
  tmp := alltrim(tmp1)
  Private tmp_mas := {}, tmp_kod := {}, t_len, k1, k2
  i := 0
  go top
  do while !eof()
    if tmp $ upper(tmp_ga->name)
      aadd(tmp_mas,tmp_ga->name) ; aadd(tmp_kod,tmp_ga->(recno()))
    endif
    skip
  enddo
  rest_box(buf1)
  if (t_len := len(tmp_kod)) = 0
    stat_msg("Не найдено ни одной записи, удовлетворяющей данной подстроке!")
    mybell(2)
    loop
  elseif t_len == 1  // найдена одна строка
    goto (tmp_kod[1])
    ret := 0
    exit
  else
    status_key("^<Esc>^ - отказ от выбора")
    if (i := popup(pr1+3,pc1+1,pr2-1,pc2-1,tmp_mas,1,color1,.f.,,,;
                   'Кол-во записей с "'+tmp+'" - '+lstr(t_len),color8)) > 0
      goto (tmp_kod[i])
      ret := 0
    endif
    exit
  endif
enddo
restscreen(buf)
if ret == -1
  goto rec1
endif
return ret

***** 23.01.17 в GET'е выбрать значение из TMP_V015.DBF (глобального массива) с поиском по подстроке
Function fget_tmp_V015(k,r,c,a_spec)
Local ret, fl, kolRec, nRec, tmp_select := select(), s, blk, t_arr[BR_LEN]
use (cur_dir+"tmp_v015") index (cur_dir+"tmpsV015"),(cur_dir+"tmpkV015") new alias tmp_ga
kolRec := lastrec()
if r <= maxrow()/2
  t_arr[BR_TOP] := r+1
  if (t_arr[BR_BOTTOM] := t_arr[BR_TOP]+kolRec+3) > maxrow()-2
    t_arr[BR_BOTTOM] := maxrow()-2
  endif
else
  t_arr[BR_BOTTOM] := r-1
  if (t_arr[BR_TOP] := t_arr[BR_BOTTOM]-kolRec-3) < 1
    t_arr[BR_TOP] := 1
  endif
endif
if valtype(a_spec) == "A"
  blk := {|| iif(tmp_ga->isn==1, {1,2}, {3,4}) }
  if !empty(a_spec)
    go top
    do while !eof()
      if ascan(a_spec,int(val(tmp_ga->kod))) > 0
        tmp_ga->isn := 1
      endif
      skip
    enddo
  endif
else
  blk := {|| iif(tmp_ga->vs=="врач", {1,2}, {3,4}) }
endif
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {"═","░","═","N/BG,W+/N,B/BG,W+/B",.f.}
t_arr[BR_COLUMN] := {;
  { "Код", {|| tmp_ga->kod },blk },;
  { center("Медицинская специальность",40), {|| padr(f1get_tmp_V015(),40) },blk },;
  { " ", {|| tmp_ga->vs },blk },;
  { center("подчинение",21), {|| left(tmp_ga->name_up,21) },blk };
}
t_arr[BR_EDIT] := {|nk,ob| f1get_tmp_ga(nk,ob,"edit",a_spec) }
if valtype(a_spec) == "A"
  Ins_Array(t_arr[BR_COLUMN], 1, {" ", {|| iif(tmp_ga->isn==1,""," ") }, blk })
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Ins>^ - отметить специальность;  ^<F2>^ - поиск по подстроке") }
else
  t_arr[BR_ENTER] := {|| iif(tmp_ga->uroven==0, (func_error(4,"Запрещается выбирать данную специальность"),ret:=nil),;
                                                (ret := {tmp_ga->kod,alltrim(tmp_ga->name)})) }
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке") }
endif
fl := .f. ; nRec := 0
if !(valtype(a_spec) == "A") .and. k != NIL
  set order to 2
  find (k)
  if (fl := found())
    nRec := recno()
  endif
  set order to 1
endif
if !fl
  nRec := 0
endif
go top
if nRec > 0
  if kolRec-nRec < t_arr[BR_BOTTOM]-t_arr[BR_TOP]-3 // последняя страница?
    keyboard chr(K_END)+replicate(chr(K_UP),kolRec-nRec-1)
  else
    goto (nRec)
  endif
endif
edit_browse(t_arr)
if valtype(a_spec) == "A"
  s := ""
  asize(a_spec,0)
  go top
  do while !eof()
    if tmp_ga->isn == 1
      s += alltrim(tmp_ga->kod)+","
      aadd(a_spec,int(val(tmp_ga->kod)))
      tmp_ga->isn := 0
    endif
    skip
  enddo
  if empty(s)
    s := "---"
  else
    s := left(s,len(s)-1)
  endif
  ret := {1,s}
endif
tmp_ga->(dbCloseArea())
select (tmp_select)
return ret

***** 07.08.16
Static Function f1get_tmp_V015()
Local s := afteratnum(".",tmp_ga->name,1)
s := space(2*tmp_ga->uroven)+s
return s

*****
Function is_up_usl(arr_usl,mkod)
Local i := 0, tmp_select := select()
select USL
do while .t.
  find (str(mkod,4))
  if !found() ; exit ; endif
  if usl->kod_up == 0 .or. i > 20
    exit
  endif
  mkod := usl->kod_up ; ++i
enddo
if tmp_select > 0
  select(tmp_select)
endif
return ( ascan(arr_usl,usl->kod) > 0 )

***** 03.01.19
Function input_usluga(arr_tfoms)
Local ar, musl, arr_usl, buf, fl_tfoms := (valtype(arr_tfoms)=="A")
ar := GetIniSect(tmp_ini,"uslugi")
musl := padr(a2default(ar,"shifr"),10)
if (musl := input_value(18,6,20,73,color1,;
          space(17)+"Введите шифр услуги",musl,"@K")) != NIL .and. !empty(musl)
  buf := save_maxrow()
  mywait()
  musl := transform_shifr(musl)
  SetIniSect(tmp_ini,"uslugi",{{"shifr",musl}})
  R_Use(dir_server+"uslugi",dir_server+"uslugish","USL")
  find (musl)
  if found()
    susl := musl
    arr_usl := {usl->kod,alltrim(usl->shifr)+". "+alltrim(usl->name),usl->shifr}
  else
    func_error(4,"Услуга с шифром "+alltrim(musl)+" не найдена в нашем справочнике!")
    if fl_tfoms
      arr_usl := {0,"",""}
    endif
  endif
  usl->(dbCloseArea())
  if fl_tfoms
    use_base("lusl")
    find (musl)
    if found()
      arr_tfoms[1] := lusl->(recno())
      arr_tfoms[2] := alltrim(lusl->shifr)+". "+alltrim(lusl->name)
      arr_tfoms[3] := lusl->shifr
    endif
    close_use_base('lusl')
    // lusl->(dbCloseArea())
    // lusl18->(dbCloseArea())
    // lusl19->(dbCloseArea())
    // lusl20->(dbCloseArea())
    // lusl21->(dbCloseArea())
  endif
  rest_box(buf)
endif
return arr_usl

*****
Function ret_1st_otd(lkod_uch)
Local k, tmp_select := select()
R_Use(dir_server+"mo_otd",,"OTD")
Locate for otd->kod_lpu == lkod_uch
if found()
  k := {otd->(recno()),alltrim(otd->name)}
else
  func_error(3,"Нет отделений для данного учреждения!")
endif
otd->(dbCloseArea())
if tmp_select > 0
  select(tmp_select)
endif
return k

***** вернуть процент выполнения плана
Function ret_trudoem(lkod_vr,ltrudoem,kol_mes,arr_m,/*@*/plan)
Local i := 0, trd := 0, ltrud, tmp_select := select()
plan := 0
do while i < kol_mes
  ltrud := 0
  // сначала поиск конкретного месяца
  select UCHP
  find (str(lkod_vr,4)+str(arr_m[1],4)+str(arr_m[2]+i,2))
  if found()
    ltrud := uchp->m_trud
  endif
  if empty(ltrud)  // если не нашли
    // то поиск среднемесячного плана
    select UCHP
    find (str(lkod_vr,4)+str(0,4)+str(0,2))
    if found()
      ltrud := uchp->m_trud
    endif
  endif
  plan += ltrud
  ++i
enddo
if plan > 0
  trd := ltrudoem / plan * 100
endif
select (tmp_select)
return trd

***** 13.02.14
FUNCTION input_uch(r,c,date1,date2)
Local ret, k, fl_is, tmp_select := select()
if !myFileDeleted(cur_dir+"tmp_ga"+sdbf)
  return ret
endif
if empty(glob_uch[1])
  ar := GetIniVar(tmp_ini,{{"uch_otd","uch","0"},;
                           {"uch_otd","otd","0"}} )
  glob_uch[1] := int(val(ar[1]))
  glob_otd[1] := int(val(ar[2]))
endif
dbcreate(cur_dir+"tmp_ga",{{"name","C",30,0},;
                           {"kod","N",3,0},;
                           {"is","L",1,0}})
use (cur_dir+"tmp_ga") new
R_Use(dir_server+"mo_uch",,"UCH")
go top
do while !eof()
  fl_is := between_date(uch->DBEGIN,uch->DEND,date1,date2)
  if iif(date1==NIL, .t., fl_is)
    select TMP_GA
    append blank
    replace name with uch->name, ;
            kod with uch->kod, ;
            is with fl_is
  endif
  select UCH
  skip
enddo
uch->(dbCloseArea())
select TMP_GA
if (k := tmp_ga->(lastrec())) == 1
  ret := {tmp_ga->kod,alltrim(tmp_ga->name)}
else
  index on upper(name) to (cur_dir+"tmp_ga")
endif
tmp_ga->(dbCloseArea())
select (tmp_select)
if k == 0
  func_error(4,"Пустой справочник учреждений")
elseif k > 1
  ret := fget_tmp_ga(glob_uch[1],r,c,,"Выбор учреждения",.f.)
endif
if ret != NIL
  glob_uch := ret
  st_a_uch := {glob_uch}
  SetIniVar(tmp_ini,{{"uch_otd","uch",glob_uch[1]}})
endif
return ret

*****
Function inputE_otd(r1,c1,r2)
return input_otd(r1,c1,sys_date)

***** 13.02.14
FUNCTION input_otd(r,c,date1,date2,nTask)
Local ret, k, fl_is, tmp_select := select()
DEFAULT nTask TO X_OMS
if !myFileDeleted(cur_dir+"tmp_ga"+sdbf)
  return ret
endif
dbcreate(cur_dir+"tmp_ga",{{"name","C",30,0},;
                           {"kod","N",3,0},;
                           {"idump","N",2,0},;
                           {"tiplu","N",2,0},;
                           {"is","L",1,0}})
use (cur_dir+"tmp_ga") new
R_Use(dir_server+"mo_otd",,"OTD")
go top
do while !eof()
  if otd->KOD_LPU == glob_uch[1]
    if nTask == X_ORTO
      fl_is := between_date(otd->DBEGINO,otd->DENDO,date1,date2)
    elseif nTask == X_PLATN
      fl_is := between_date(otd->DBEGINP,otd->DENDP,date1,date2)
    else
      fl_is := between_date(otd->DBEGIN,otd->DEND,date1,date2)
    endif
    if iif(date1==NIL, .t., fl_is)
      select TMP_GA
      append blank
      replace name with otd->name, ;
              kod with otd->kod, ;
              idump with otd->idump, ;
              tiplu with otd->tiplu, ;
              is with fl_is
    endif
  endif
  select OTD
  skip
enddo
otd->(dbCloseArea())
select TMP_GA
if (k := tmp_ga->(lastrec())) == 1
  ret := {tmp_ga->kod,alltrim(tmp_ga->name),tmp_ga->idump,tmp_ga->tiplu}
else
  index on upper(name) to (cur_dir+"tmp_ga")
endif
tmp_ga->(dbCloseArea())
select (tmp_select)
if k == 0
  func_error(4,"Не найдено отделений для данного учреждения")
elseif k > 1
  ret := fget_tmp_ga(glob_otd[1],r,c,,"Выбор отделения",.f.,alltrim(glob_uch[2]))
endif
if ret != NIL
  glob_otd := ret
  SetIniVar(tmp_ini,{{"uch_otd","otd",glob_otd[1]}})
endif
return ret

***** 29.10.18
Function input_perso(r,c,is_null,is_rab)
Static si := 1
Local fl := .f., fl1 := .f., mas_pmt, s_input, s_glob, s_pict, tmp_help := 0,;
      arr_dolj := {}, arr_kod := {}, lr, r1, r2, i, buf := save_row(maxrow())
DEFAULT is_null TO .t., is_rab TO .f.
mas_pmt := {"Поиск сотрудника по ~таб.номеру","Поиск сотрудника по ~фамилии"}
s_input := space(10)+"Введите табельный номер сотрудника"
s_glob := glob_human[5]
s_pict := "99999"
if (i := popup_prompt(r,c,si,mas_pmt)) == 0
  return .f.
elseif i == 1
  si := 1
  if (i := input_value(18,6,20,73,color1,s_input,s_glob,s_pict)) == NIL
    return .f.
  elseif i == 0
    if is_null
      glob_human := {0,"",0,0,0,"",0,0}
      return .t.
    else
      return .f.
    endif
  elseif i < 0
    return func_error(4,"Неверный ввод - отрицательный код!")
  endif
  R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
  find (str(i,5))
  if found()
    glob_human := {perso->kod,;
                   alltrim(perso->fio),;
                   perso->uch,;
                   perso->otd,;
                   i,;
                   alltrim(perso->name_dolj),;
                   perso->prvs,;
                   perso->prvs_new }
    fl1 := .t.
  else
    func_error(4,"Сотрудника с табельным номером "+lstr(i)+" нет в базе данных персонала!")
  endif
  close databases
  return fl1
endif
si := 2
Private mr := r
mywait()
//help_code := H_Input_fio
if R_Use(dir_server+"mo_pers",,"PERSO")
  index on upper(fio) to (cur_dir+"tmp_pers") for kod > 0
  if glob_human[1] > 0
    goto (glob_human[1])
    fl := !eof() .and. !deleted()
  endif
  if !fl ; go top ; endif
  if Alpha_Browse(r,9,maxrow()-2,70,"f1inp_perso",color0,,,,,,,,,{"═","░","═","N/BG,W+/N,B/BG,BG+/B"} )
    lr := row()
    if perso->kod == 0
      func_error(4,"База данных персонала пустая!")
    else
      glob_human := {perso->kod,;
                     alltrim(perso->fio),;
                     perso->uch,;
                     perso->otd,;
                     perso->tab_nom,;
                     alltrim(perso->name_dolj),;
                     perso->prvs,;
                     perso->prvs_new }
      fl1 := .t.
    endif
  endif
endif
close databases
//help_code := tmp_help
rest_box(buf)
return fl1

***** 29.10.18
Function f1inp_perso(oBrow)
Local oColumn
oColumn := TBColumnNew(center("Ф.И.О.",30), {|| left(perso->fio,30) })
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Таб.№", {|| perso->tab_nom })
oColumn:defColor := {3,3}
oColumn:colorBlock := {|| {3,3} }
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(center("Специальность",21), {|| padr(ret_tmp_prvs(perso->prvs,perso->prvs_new),21) })
oBrow:addColumn(oColumn)
return NIL

***** вернуть учреждение и отделение в GET'е
FUNCTION ret_uch_otd(k,r,c,date1,date2,nTask)
Local ret, n := 1
if k != NIL .and. k > 0
  glob_uch[1] := k
endif
if input_uch(r,c,date1,date2) != NIL
  if type("m1otd") == "N" .and. m1otd > 0
    glob_otd[1] := m1otd
  endif
  if input_otd(r,c,date1,date2,nTask) != NIL
    if valtype(motd) == "C"
      n := len(motd)
    endif
    m1otd := glob_otd[1] ; motd := alltrim(glob_otd[2])
    if len(motd) < n
      motd := padr(motd,n)
    endif
    ret := glob_uch
  endif
endif
return ret

***** удаление данных по зубной формуле в HUMANST (для платных услуг)
Function STdelHuman(ltip,lrec)
select HUMANST
do while .t.
  find (str(ltip,1)+str(lrec,8))
  if !found() ; exit ; endif
  DeleteRec(.t.)
enddo
return NIL

***** удаление данных по зубной формуле в картотеке
Function STdelKart(ltip,lrec)
select KART_ST
set order to 2
do while .t.
  find (str(ltip,1)+str(lrec,8))
  if !found() ; exit ; endif
  DeleteRec(.t.)
enddo
return NIL

***** добавление данных по зубной формуле
Function STappend(ltip,lrec,lkod_k,ldate_u,lu_kod,lkod_vr,_zf,_diag)
Local i, arr_zf := STretArrZF(_zf)
STdelKart(ltip,lrec)
if ltip == 2 // платные услуги
  STdelHuman(ltip,lrec)
endif
if len(arr_zf) > 0
  if ltip == 2 // платные услуги
    select HUMANST
    AddRec(1)
    humanst->TIP_BD    := ltip
    humanst->REC_BD    := lrec
    humanst->KOD_DIAG  := _diag
    humanst->ZF        := _zf
    humanst->(dbUnLock())
  endif
  select KART_ST
  set order to 2
  for i := 1 to len(arr_zf)
    AddRec(1)
    kart_st->KOD       := lkod_k
    kart_st->ZF        := arr_zf[i]
    kart_st->KOD_DIAG  := _diag
    kart_st->TIP_BD    := ltip
    kart_st->REC_BD    := lrec
    kart_st->DATE_U    := ldate_u
    kart_st->U_KOD     := lu_kod
    kart_st->KOD_VR    := lkod_vr
    kart_st->(dbUnLock())
  next
endif
return NIL

***** 17.12.18 добавление удалённого зуба
Function STappendDelZ(lkod_k,_zf,ldate_u,lu_kod)
Static arr_STdelzub
Local i, arr_zf := STretArrZF(_zf)
DEFAULT arr_STdelzub TO ret_arr_STdelzub()
if len(arr_zf) > 0 .and. ascan(arr_STdelzub,lu_kod) > 0 .and. select("KARTDELZ") > 0
  select KARTDELZ
  for i := 1 to len(arr_zf)
    find (str(lkod_k,7)+str(arr_zf[i],2))
    if found()
      if !(kartdelz->DATE_U == ldate_u)
        G_RLock(forever)
        kartdelz->DATE_U := ldate_u
        kartdelz->(dbUnLock())
      endif
    else
      AddRec(7)
      kartdelz->KOD    := lkod_k
      kartdelz->ZF     := arr_zf[i]
      kartdelz->DATE_U := ldate_u
      kartdelz->(dbUnLock())
    endif
  next
endif
return NIL

***** 17.12.18 удаление удалённого зуба
Function STDelDelZ(lkod_k,_zf,lu_kod)
Static arr_STdelzub
Local i, arr_zf := STretArrZF(_zf)
DEFAULT arr_STdelzub TO ret_arr_STdelzub()
if len(arr_zf) > 0 .and. ascan(arr_STdelzub,lu_kod) > 0 .and. select("KARTDELZ") > 0
  select KARTDELZ
  for i := 1 to len(arr_zf)
    find (str(lkod_k,7)+str(arr_zf[i],2))
    if found()
      DeleteRec(.t.)
    endif
  next
endif
return NIL

***** 11.12.18 вернуть массив с кодами услуг удаления зуба
Function ret_arr_STdelzub()
Static arr := {;
  {"A16.07.030.001", "Удаление временного зуба"},;
  {"A16.07.030.002", "Удаление постоянного зуба"},;
  {"A16.07.030.003", "Удаление зуба сложное с разъединением корней"},;
  {"A16.07.039"    , "Операция удаления ретинированного, дистопированного или сверхкомплектного зуба"};
}
Static akod := {}
Local i, s, lkod := 0
/*if len(akod) == 0
  use_base("mo_su","MOSU1")
  akod := {}
  for i := 1 to len(arr)
    s := arr[i,1]
    select MOSU1
    set order to 3
    find (padr(s,20))
    do while mosu1->shifr1 == padr(s,20) .and. !eof()
      if !("*" $ mosu1->shifr)
        lkod := mosu1->kod ; exit
      endif
      skip
    enddo
    if lkod == 0
      set order to 1
      FIND (STR(-1,6))
      if found()
        G_RLock(forever)
      else
        AddRec(6)
      endif
      lkod := mosu1->kod := recno()
      mosu1->name := arr[i,2]
      mosu1->shifr1 := s
    endif
    aadd(akod,lkod)
  next
  mosu1->(dbCloseArea())
endif*/
return akod

***** 17.12.18 проверка, не удалён ли зуб
Function STverDelZub(lkod_k,arr_zf,ldate_u,ltip,lrec,/*@*/amsg)
Static arr_STdelzub
Local i
DEFAULT arr_STdelzub TO ret_arr_STdelzub()
if len(arr_STdelzub) > 0 .and. select("KARTDELZ") > 0
  select KARTDELZ
  for i := 1 to len(arr_zf)
    find (str(lkod_k,7)+str(arr_zf[i],2))
    if found() .and. kartdelz->DATE_U < ldate_u
      aadd(amsg, lstr(arr_zf[i])+': данный зуб удален '+full_date(c4tod(kartdelz->DATE_U)))
    endif
  next
endif
/*if len(arr_STdelzub) > 0
  select KART_ST
  set order to 1
  for i := 1 to len(arr_zf)
    find (str(lkod_k,7)+str(arr_zf[i],2))
    do while kart_st->KOD == lkod_k .and. kart_st->ZF == arr_zf[i]
      if !(kart_st->TIP_BD == ltip .and. kart_st->REC_BD == lrec)
        if kart_st->DATE_U < ldate_u .and. ascan(arr_STdelzub,kart_st->U_KOD) > 0
          aadd(amsg, lstr(arr_zf[i])+': данный зуб удален '+full_date(c4tod(kart_st->DATE_U)))
        endif
      endif
      skip
    enddo
  next
endif*/
return NIL

***** 16.01.19 проверка правильности ввода зубной формулы
Function STVerifyKolZf(arr_zf,mkol,/*@*/amsg,lshifr)
if valtype(arr_zf) == "A" .and. valtype(mkol) == "N"
  DEFAULT lshifr TO ""
  if len(arr_zf) == 0 //
    aadd(amsg, 'не введена зубная формула '+lshifr)
  elseif len(arr_zf) != mkol
    aadd(amsg, 'количество зубов не соответствует количеству введённых зубных формул '+lshifr)
  endif
endif
return !empty(amsg)

***** 31.01.19 проверка правильности ввода зубной формулы
Function STverifyZF(_zf,_date_r,_sys_date,/*@*/amsg,lshifr)
Static fz := {{11,18},{21,28},{31,38},{41,48},{51,55},{61,65},{71,75},{81,85}}
//               возраст больного с 14 лет   |       возраст до 5 лет
Local i, j, k, v, arr_zf := STretArrZF(_zf,@amsg,lshifr)
if len(arr_zf) > 0
  DEFAULT lshifr TO ""
  v := count_years(_date_r,_sys_date)
  for i := 1 to len(arr_zf)
    k := 0
    for j := 1 to len(fz)
      if between(arr_zf[i],fz[j,1],fz[j,2])
        k := j ; exit
      endif
    next
    if k == 0
      aadd(amsg, lstr(arr_zf[i])+' - неверная зубная формула '+lshifr)
    //elseif v <= 5 .and. between(k,1,4)
      //aadd(amsg, lstr(arr_zf[i])+' - у ребенка зубная формула взрослого '+lshifr)
    //elseif v > 14 .and. between(k,5,8)
      //aadd(amsg, lstr(arr_zf[i])+' - у взрослого зубная формула ребенка '+lshifr)
    endif
  next
endif
return arr_zf

***** 16.01.19 синтаксический анализ зубной формулы, возврат массива зубов
Function STretArrZF(_zf,/*@*/amsg,lshifr)
//Static ssymb := "12345678,-МДВЖН", nsymb := 15  так было у Демиденко Татьяны
Static ssymb := "12345678,-", nsymb := 10
Local i, j, s, tmps, v1, v2, arr_zf := {}
DEFAULT amsg TO {}, lshifr TO ""
s := charrem(" ",_zf) // удалить все пробелы
// проверяем на допустимые символы
tmps := charrem(" ",CHARREPL(ssymb, s, SPACE(nsymb)))
if !empty(tmps)
  aadd(amsg, '"'+tmps+'" - зубная формула: некорректные символы '+lshifr)
endif
for i := 1 to numtoken(s,",")
  tmps := token(s,",",i)
  if "-" $ tmps // обработка диапазона
    v1 := token(tmps,"-",1)
    v2 := token(tmps,"-",2)
  else // одиночное значение
    v1 := v2 := tmps
  endif
  v1 := int(val(v1))
  v2 := int(val(v2))
  if v2 < v1
    aadd(amsg, '"'+tmps+'" - зубная формула: некорректный диапазон '+lshifr)
    v2 := v1
  endif
  for j := v1 to v2
    aadd(arr_zf,j) // массив зубов
  next
next
return arr_zf

***** 16.01.19 является ли случай стоматологическим для ввода зубной формулы
Function STisZF(_USL_OK,_PROFIL)
return (_USL_OK == 3 .and. eq_any(_PROFIL,85,86,87,88,89,90,140,171))

** ввод фразы для места работы из списка
Function v_vvod_mr()
Local k, nrow := row(), ncol := col(), fl := .f., tmp_keys, tmp_gets
tmp_keys := my_savekey()
if (get := get_pointer("MMR_DOL")) != NIL .and. get:hasFocus
  save gets to tmp_gets
  setcursor(0)
  if !empty(k := input_s_mr())
    fl := .t.
  else
    @ nrow,ncol say ""
  endif
  restore gets from tmp_gets
  if fl
    keyboard (alltrim(k))
  endif
  setcursor()
endif
my_restkey(tmp_keys)
return NIL

***** выбор фразы для места работы
Function input_s_mr()
Local t_arr[BR_LEN], tmp_select := select(), buf := savescreen(), ret := ""
t_arr[BR_TOP] := 2
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 26
t_arr[BR_RIGHT] := 79
t_arr[BR_OPEN] := {|| f1_s_mr(,,"open") }
t_arr[BR_CLOSE] := {|| sa->(dbCloseArea()) }
t_arr[BR_COLOR] := color0
//t_arr[BR_ARR_BROWSE] := {,,,,,reg,"*+"}
t_arr[BR_COLUMN] := {{ center("Список фраз для места работы",50),{|| sa->name} }}
s_msg := "^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<Ins>^ - добавление"
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<Ins>^ - добавление;  ^<F2>^ - поиск") }
t_arr[BR_EDIT] := {|nk,ob| f1_s_mr(nk,ob,"edit") }
t_arr[BR_ENTER] := {|| ret := alltrim(sa->name) }
edit_browse(t_arr)
if tmp_select > 0
  select(tmp_select)
endif
restscreen(buf)
return ret

*****
Function f1_s_mr(nKey,oBrow,regim)
Static tmp := " "
Local ret := -1, j := 0, flag := -1, buf := save_maxrow(), buf1, ;
      fl := .f., rec, mkod, tmp_color := setcolor()
do case
  case regim == "open"
    G_Use(dir_server+"s_mr",,"SA")
    index on upper(name) to (cur_dir+"tmp_mr")
    go top
    ret := !eof()
  case regim == "edit"
    if nKey == K_F2
      Private tmp1 := padr(tmp,30)
      if (tmp1 := input_value(pr2-2,pc1+1,pr2,pc2-1,color1,;
                              "Подстрока поиска",;
                              tmp1,"@K@!")) != NIL .and. !empty(tmp1)
        tmp := alltrim(tmp1)
        Private tmp_mas := {}, tmp_kod := {}
        rec := recno()
        go top
        locate for tmp $ upper(name)
        do while !eof()
          if ++j > 4000 ; exit ; endif
          aadd(tmp_mas,sa->name) ; aadd(tmp_kod,sa->(recno()))
          continue
        enddo
        goto (rec)
        if len(tmp_kod) == 0
          stat_msg("Неудачный поиск!") ; mybell(2)
        else
          status_key("^<Esc>^ - отказ от выбора")
          if (j := popup(pr1+1,pc1+1,pr2-1,pc2-1,tmp_mas,,color5,,,,;
                         'Результат поиска по подстроке "'+tmp+'"',"B/W")) > 0
            oBrow:gotop()
            goto (tmp_kod[j])
          endif
          ret := 0
        endif
      endif
    elseif nKey == K_INS
      rec := recno()
      Private mname := if(nKey == K_INS, space(50), sa->name),;
              gl_area := {1,0,23,79,0}
      buf1 := box_shadow(pr2-2,pc1+1,pr2,pc2-1,color8,;
                    iif(nKey==K_INS,"Добавление","Редактирование"),cDataPgDn)
      setcolor(cDataCGet)
      @ pr2-1,pc1+2 get mname
      status_key("^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение записи")
      myread()
      if lastkey() != K_ESC .and. !empty(mname)
        if nKey == K_INS
          AddRecN()
          rec := recno()
        else
          G_RLock(forever)
        endif
        replace name with mname
        COMMIT
        UNLOCK
        oBrow:goTop()
        goto (rec)
        ret := 0
      endif
      setcolor(tmp_color)
      rest_box(buf) ; rest_box(buf1)
    else
      keyboard ""
    endif
endcase
return ret

***** 07.02.13 ввод фразы для адреса из списка
Function v_vvod_adres()
Local k, nrow := row(), ncol := col(), fl := .f., tmp_keys, tmp_gets
tmp_keys := my_savekey()
if (get := get_pointer("MULICADOM")) != NIL .and. get:hasFocus
  save gets to tmp_gets
  setcursor(0)
  if !empty(k := input_s_adres())
    fl := .t.
  else
    @ nrow,ncol say ""
  endif
  restore gets from tmp_gets
  if fl
    keyboard (alltrim(k)+" ")
  endif
  setcursor()
endif
my_restkey(tmp_keys)
return NIL

***** выбор фразы для адреса
Function input_s_adres()
Local t_arr[BR_LEN], tmp_select := select(), buf := savescreen(), ret := ""
t_arr[BR_TOP] := 2
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 36
t_arr[BR_RIGHT] := 79
t_arr[BR_OPEN] := {|| f1_s_adres(,,"open") }
t_arr[BR_CLOSE] := {|| sa->(dbCloseArea()) }
t_arr[BR_COLOR] := color0
//t_arr[BR_ARR_BROWSE] := {,,,,,reg,"*+"}
t_arr[BR_COLUMN] := {{ center("Список фраз для адреса",40),{|| sa->name} }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<Ins>^ - добавление") }
t_arr[BR_EDIT] := {|nk,ob| f1_s_adres(nk,ob,"edit") }
t_arr[BR_ENTER] := {|| ret := alltrim(sa->name) }
edit_browse(t_arr)
if tmp_select > 0
  select(tmp_select)
endif
restscreen(buf)
return ret

***** форма настройки включаемых/исключаемых услуг
Function forma_nastr(s_titul,arr_strok,nfile,arr,fl)
Local i, j, r := 2, tmp_color := setcolor(cDataCGet)
Local buf := savescreen(), blk := {|| f9_f_nastr(s_titul,arr_strok) }
if nfile != NIL
  arr := rest_arr(nfile)
endif
if arr == NIL .or. empty(arr)
  arr := {{},{}}
endif
Private mda[15], mnet[15]
afill(mda,space(10))
aeval(arr[1], {|x,i| mda[i] := padr(x,10) } )
afill(mnet,space(10))
aeval(arr[2], {|x,i| mnet[i] := padr(x,10) } )
box_shadow(r,0,23,79,color1,s_titul,color8)
str_center(r+2,"Данный режим предназначен для настройки")
j := r + 2
aeval(arr_strok, {|x| str_center(++j,x,"G+/B") } )
++j
@ ++j,4 say "     Включаемые услуги (шаблон)          Исключаемые услуги (шаблон)"
for i := 1 to 15
  @ j+i,15 say str(i,2) get mda[i]
next
for i := 1 to 15
  @ j+i,52 say str(i,2) get mnet[i]
next
status_key("^<Esc>^ - выход;  ^<PgDn>^ - запомнить настройки;  ^<F9>^ - печать списка услуг")
SETKEY(K_F9, blk)
myread()
SETKEY(K_F9, NIL)
fl := .f.
if lastkey() != K_ESC .and. f_Esc_Enter(1)
  fl := .t.
  arr := {{},{}}
  for i := 1 to 15
    if !empty(mda[i])
      aadd(arr[1],mda[i])
    endif
    if !empty(mnet[i])
      aadd(arr[2],mnet[i])
    endif
  next
  if nfile != NIL
    save_arr(arr,nfile)
  endif
endif
setcolor(tmp_color)
restscreen(buf)
return arr

*****
Function f9_f_nastr(l_titul,a_strok)
Local sh := 80, HH := 77, buf := save_maxrow(), n_file := "frm_nast"+stxt
Local i, k, nrow := row(), ncol := col(), tmp_keys, tmp_gets, ta := {}
mywait()
tmp_keys := my_savekey()
save gets to tmp_gets
//
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center(l_titul,sh))
add_string("")
add_string(center("Данный список услуг представляет содержание",sh))
aeval(a_strok, {|x| add_string(center(x,sh)) } )
add_string("")
add_string("      Включаемые услуги (шаблон)          Исключаемые услуги (шаблон)")
k := 0
for i := 1 to 15
  aadd(ta,space(20)+mda[i]+space(20)+mnet[i])
  if !emptyall(mda[i],mnet[i])
    k := i
  endif
next
for i := 1 to k
  add_string(ta[i])
next
R_Use(dir_server+"uslugi",,"USL")
index on fsort_usl(shifr) to (cur_dir+"tmpu")
go top
do while !eof()
  if _f_usl_danet(mda,mnet)
    verify_FF(HH,.t.,sh)
    add_string(usl->shifr+" "+rtrim(usl->name))
  endif
  skip
enddo
usl->(dbCloseArea())
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.f.,,,5)
//
restore gets from tmp_gets
my_restkey(tmp_keys)
setcursor()
return NIL

*****
Function ret_f_nastr(a_usl,lshifr)
Local i, shb, fl := .f.
for i := 1 to len(a_usl[1])
  if !empty(shb := a_usl[1,i])
    if "*" $ shb .or. "?" $ shb
      fl := like(alltrim(shb),lshifr)
    else
      fl := (shb == lshifr)
    endif
    if fl ; exit ; endif
  endif
next
if fl
  for i := 1 to len(a_usl[2])
    if !empty(shb := a_usl[2,i])
      if "*" $ shb .or. "?" $ shb
        fl := !like(alltrim(shb),lshifr)
      else
        fl := !(shb == lshifr)
      endif
      if !fl ; exit ; endif
    endif
  next
endif
return fl

*****
Function _f_usl_danet(a_da,a_net)
Local fl, i, shb
fl := usl->is_nul .or. !emptyall(usl->cena,usl->cena_d)
if !fl .and. is_task(X_PLATN) // для платных услуг
  fl := usl->is_nulp .or. !emptyall(usl->pcena,usl->pcena_d,usl->dms_cena)
endif
if fl
  fl := .f.
  for i := 1 to len(a_da)
    if !empty(shb := a_da[i])
      if "*" $ shb .or. "?" $ shb
        fl := like(alltrim(shb),usl->shifr)
      else
        fl := (shb == usl->shifr)
      endif
      if fl ; exit ; endif
    endif
  next
  if fl
    for i := 1 to len(a_net)
      if !empty(shb := a_net[i])
        if "*" $ shb .or. "?" $ shb
          fl := !like(alltrim(shb),usl->shifr)
        else
          fl := !(shb == usl->shifr)
        endif
        if !fl ; exit ; endif
      endif
    next
  endif
endif
return fl

***** 28.01.20 вывести строку в отладочный массив о КСГ
Function f_put_debug_KSG(k,arr,ars)
// k = 1 - терапевтическая
// k = 2 - хирургическая
Local s := " ", i, s1, arr1 := {}
if k == 1
  s += "терап."
elseif k == 2
  s += "хирур."
endif
s += "КСГ"
if len(arr) == 0
  s += " не определена"
else
  s += ": "
  for i := 1 to len(arr)
    s1 := ""
    if k == 0 .and. !empty(arr[i,5])
      s1 += "осн.диаг.,"
    endif
    if eq_any(k,0,1) .and. !empty(arr[i,6])
      if alltrim(arr[i,10]) == "mgi"
        //
      else
        s1 += "усл.,"
      endif
    endif
    if !empty(arr[i,7])
      s1 += "возр.,"
    endif
    if !empty(arr[i,8])
      s1 += "пол,"
    endif
    if !empty(arr[i,9])
      s1 += "дл-ть,"
    endif
    if !empty(arr[i,10])
      s1 += "доп.критерий,"
    endif
    if len(arr[i]) >= 15 .and. !empty(arr[i,15])
      s1 += "иной критерий,"
    endif
    if !empty(arr[i,11])
      s1 += "соп.диаг.,"
    endif
    if !empty(arr[i,12])
      s1 += "диаг.осл.,"
    endif
    if !empty(s1)
      s1 := " ("+left(s1,len(s1)-1)+")"
    endif
    s1 := alltrim(arr[i,1])+s1+" [КЗ="+lstr(arr[i,3])+"]"
    if ascan(arr1,s1) == 0
      aadd(arr1,s1)
    endif
  next
  for i := 1 to len(arr1)
    s += arr1[i]+" "
  next
endif
aadd(ars,s)
return len(arr1)

***** 20.01.14 вернуть цену КСГ
Function ret_cena_KSG(lshifr,lvr,ldate,ta)
Local fl_del := .f., fl_uslc := .f., v := 0
DEFAULT ta TO {}
v := fcena_oms(lshifr,;
               (lvr==0),;
               ldate,;
               @fl_del,;
               @fl_uslc)
if fl_uslc  // если нашли в справочнике ТФОМС
  if fl_del
    aadd(ta,' цена на услугу '+rtrim(lshifr)+' отсутствует в справочнике ТФОМС')
  endif
else
  aadd(ta,' для Вашей МО в справочнике ТФОМС не найдена услуга: '+lshifr)
endif
return v

***** 28.01.14 вывести в центре экрана протокол определения КСГ
Function f_put_arr_ksg(cLine)
Local buf := savescreen(), i, nLLen := 0, mc := maxcol()-1,;
      nLCol, nRCol, nTRow, nBRow, nNumRows := len(cLine)
AEVAL(cLine, {|x,i| nLLen := Max(nLLen,Len(x)) })
if nLLen > mc
  nLLen := mc
endif
// вычисление координат углов
nLCol := Int((mc-nLLen)/2)
nRCol := nLCol+nLLen+1
nTRow := Int((maxrow()-nNumRows)/2)
nBRow := nTRow+nNumRows+1
PUT_SHADOW(nTRow,nLCol,nBRow,nRCol)
@ nTRow,nLCol Clear to nBRow,nRCol
DispBox(nTRow,nLCol,nBRow,nRCol,2,"GR/GR*")
AEVAL(cLine, { |cSayStr,i|;
               nSayRow := nTRow+i,;
               nSayCol := nLCol+1,;
               setpos(nSayRow,nSayCol), dispout(padr(cSayStr,nLLen),"N/GR*");
             })
inkey(0)
restscreen(buf)
return NIL

// ***** 26.01.18 тест определения КСГ
// Function test_definition_KSG()
// Local arr, buf := save_maxrow(), lshifr, lrec, lu_kod, lcena, lyear, mrec_hu, not_ksg := .t.
// stat_msg("Определение КСГ")
// R_Use(dir_server+"mo_uch",,"UCH")
// R_Use(dir_server+"mo_otd",,"OTD")
// Use_base("lusl")
// Use_base("luslc")
// Use_base("uslugi")
// R_Use(dir_server+"schet_",,"SCHET_")
// R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
//                             dir_server+"uslugi1s"},"USL1")
// use_base("human_u") // если понадобится, удалить старый КСГ и добавить новый
// R_Use(dir_server+"mo_su",,"MOSU")
// R_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
// set relation to u_kod into MOSU
// R_Use(dir_server+"human_2",,"HUMAN_2")
// R_Use(dir_server+"human_",,"HUMAN_")
// G_Use(dir_server+"human",,"HUMAN") // перезаписать сумму
// set relation to recno() into HUMAN_, to recno() into HUMAN_2
// n_file := "test_ksg"+stxt
// fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
// go top
// do while !eof()
//   @ maxrow(),0 say str(recno()/lastrec()*100,7,2)+"%" color cColorStMsg
//   if inkey() == K_ESC
//     exit
//   endif
//   if human->K_DATA > stod("20190930") .and. eq_any(human_->USL_OK,1,2)
//     arr := definition_KSG()
//     if len(arr) == 7 // диализ
//       add_string("== диализ == ")
//     else
//       aeval(arr[1],{|x| add_string(x) })
//       if !empty(arr[2])
//         add_string("ОШИБКА:")
//         aeval(arr[2],{|x| add_string(x) })
//       endif
//       select HU
//       find (str(human->kod,7))
//       do while hu->kod == human->kod .and. !eof()
//         usl->(dbGoto(hu->u_kod))
//         if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
//           lshifr := usl->shifr
//         endif
//         if alltrim(lshifr) == arr[3] // уже стоит тот же КСГ
//           if !(round(hu->u_cena,2) == round(arr[4],2)) // не та цена
//             add_string("в л/у для КСГ="+arr[3]+" стоит цена "+lstr(hu->u_cena,10,2)+", а должна быть "+lstr(arr[4],10,2))
//             if human->schet > 0
//               schet_->(dbGoto(human->schet))
//               add_string("..счёт № "+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)+"г.")
//             endif
//           endif
//           exit
//         endif
//         select LUSL
//         find (lshifr) // длина lshifr 10 знаков
//         if found() .and. (eq_any(left(lshifr,5),"1.12.") .or. is_ksg(lusl->shifr)) // стоит другой КСГ
//           add_string("в л/у стоит КСГ="+alltrim(lshifr)+"("+lstr(hu->u_cena,10,2)+;
//                      "), а должна быть "+arr[3]+"("+lstr(arr[4],10,2)+")")
//           if human->schet > 0
//             schet_->(dbGoto(human->schet))
//             add_string("..счёт № "+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet)+"г.")
//           endif
//           exit
//         endif
//         select HU
//         skip
//       enddo
//     endif
//     add_string(replicate("*",80))
//   endif
//   select HUMAN
//   skip
// enddo
// close databases
// rest_box(buf)
// fclose(fp)
// return NIL

