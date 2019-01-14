external errorsys

Function Main
f_first()
xml2arrays()
f_end()
return NIL

*****
Function xml2arrays()
Local oXmlDoc, oXmlNode, i, j, af := {}
aadd(af, {"F005.xml","Классификатор статусов оплаты медицинской помощи",;
 {{"STNAME",  "C"},;
  {"IDIDST",  "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"F006.xml","Классификатор видов контроля",;
 {{"VIDNAME", "C"},;
  {"IDVID",   "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"F007.xml","Классификатор ведомственной принадлежности медицинской организации",;
 {{"VEDNAME", "C"},;
  {"IDVED",   "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"F008.xml","Классификатор типов документов, подтверждающих факт страхования по ОМС",;
 {{"DOCNAME", "C"},;
  {"IDDOC",   "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"F009.xml","Классификатор статуса застрахованного лица",;
 {{"StatusName", "C"},;
  {"IDStatus",   "N"},;
  {"DATEBEG",    "D"},;
  {"DATEEND",    "D"}}})
aadd(af, {"F010.xml","Классификатор субъектов Российской Федерации",;
 {{"SUBNAME",   "C"},;
  {"KOD_OKATO", "C"},;
  {"DATEBEG",   "D"},;
  {"DATEEND",   "D"},;
  {"KOD_TF",    "C"},;
  {"OKRUG",     "N"}}})
aadd(af, {"F011.xml","Классификатор типов документов, удостоверяющих личность",;
 {{"DocName", "C"},;
  {"IDDoc",   "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"},;
  {"DocSer",  "C"},;
  {"DocNum",  "C"}}})
aadd(af, {"F012.xml","Справочник ошибок форматно-логического контроля",;
 {{"Opis",    "C"},;
  {"Kod",     "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"},;
  {"DopInfo", "C"}}})
aadd(af, {"F014.xml","Классификатор причин отказа в оплате медицинской помощи",;
 {{"Komment", "C"},;
  {"Kod",     "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"},;
  {"IDVID",   "N"},;
  {"Naim",    "C"},;
  {"Osn",     "C"},;
  {"KodPG",   "C"}}})
aadd(af, {"F015.xml","Классификатор федеральных округов",;
 {{"OKRNAME", "C"},;
  {"KOD_OK",  "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"O001.dbf","Общероссийский классификатор стран мира (ОКСМ)",;
 {{"NAME11",  "C"},;
  {"KOD",     "C"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"},;
  {"ALFA2",   "C"},;
  {"ALFA3",   "C"}}})
aadd(af, {"V002.xml","Классификатор профилей оказанной медицинской помощи",;
 {{"PRNAME",  "C"},;
  {"IDPR",    "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"V004.xml","Классификатор медицинских специальностей",;
 {{"MSPNAME", "C"},;
  {"IDMSP",   "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"V005.xml","Классификатор пола застрахованного",;
 {{"POLNAME", "C"},;
  {"IDPOL",   "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"V006.xml","Классификатор условий оказания медицинской помощи",;
 {{"UMPNAME", "C"},;
  {"IDUMP",   "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"V008.xml","Классификатор видов медицинской помощи",;
 {{"VMPNAME", "C"},;
  {"IDVMP",   "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"V009.xml","Классификатор результатов обращения за медицинской помощью",;
 {{"RMPNAME",  "C"},;
  {"IDRMP",    "N"},;
  {"DATEBEG",  "D"},;
  {"DATEEND",  "D"},;
  {"DL_USLOV", "N"}}})
aadd(af, {"V010.xml","Классификатор способов оплаты медицинской помощи",;
 {{"SPNAME",  "C"},;
  {"IDSP",    "N"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"V012.xml","Классификатор исходов заболевания",;
 {{"IZNAME",   "C"},;
  {"IDIZ",     "N"},;
  {"DATEBEG",  "D"},;
  {"DATEEND",  "D"},;
  {"DL_USLOV", "N"}}})
aadd(af, {"V014.xml","Классификатор форм медицинской помощи",;
 {{"FRMMPNAME","C"},;
  {"IDFRMMP",  "N"},;
  {"DATEBEG",  "D"},;
  {"DATEEND",  "D"}}})
aadd(af, {"V015.xml","Классификатор медицинских специальностей",;
 {{"NAME",    "C"},;
  {"CODE",    "N"},;   
  {"HIGH",    "C"},;  
  {"OKSO",    "C"},;
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"V018.xml","Классификатор видов ВМП",;
 {{"IDHVID",   "C"},;
  {"HVIDNAME", "C"},;
  {"DATEBEG",  "D"},;
  {"DATEEND",  "D"}}})
aadd(af, {"V019.xml","Классификатор методов ВМП",;
 {{"IDHM",     "N"},;
  {"HMNAME",   "C"},;
  {"DIAG",     "C"},;  // диагнозы для данного метода через ";"
  {"HVID",     "C"},;  // код ВМП для данного метода  //  {"HGR",      "N"},;  {"HMODP",    "C"},;
  {"DATEBEG",  "D"},;
  {"DATEEND",  "D"}}})
aadd(af, {"V020.xml","Классификатор профиля койки",;
 {{"K_PRNAME", "C"},;
  {"IDK_PR",   "N"},;
  {"DATEBEG",  "D"},;
  {"DATEEND",  "D"}}})
aadd(af, {"V021.xml","Классификатор медицинских специальностей (последний)",;
 {{"SPECNAME","C"},;
  {"IDSPEC",  "N"},;   
  {"DATEBEG", "D"},;
  {"DATEEND", "D"}}})
aadd(af, {"T012.xml","Классификатор ошибок ИСОМП",;
 {{"NAME",     "C"},;
  {"CODE",     "N"},;
  {"STAGE_TK", "C"},;
  {"DATE_B",   "D"},;
  {"DATE_E",   "D"}}})
fp := fcreate("__tmp__.prg") ; n_list := 1 ; tek_stroke := 0
add_string("***** определение справочников ФФОМС")
add_string("Function InitSpravFFOMS()")
add_string("/////////////////////////////////////////////////")
for i := 1 to len(af)
  add_string("// "+af[i,1]+" - "+af[i,2])
next
add_string("/////////////////////////////////////////////////")
for i := 1 to len(af)
  add_string("// "+af[i,1]+" - "+af[i,2])
  s := ""
  for k := 1 to len(af[i,3])
    arr := af[i,3,k]
    s += "  "+ltrim(str(k))+" - "+arr[1]+"("+arr[2]+")"
  next k
  add_string("//"+s)
  s := iif(eq_any(left(af[i,1],4),"V018","V019"), "_", "")+"glob_"+left(af[i,1],4)
  iik := iif(eq_any(left(af[i,1],4),"V018","V019"), 1, 2)
  arr_UQ := {}
  if right(upper(af[i,1]),4) == ".XML" // XML-файл
    oXmlDoc := HXMLDoc():Read(af[i,1])
    IF Empty( oXmlDoc:aItems )
      ? "Ошибка в чтении файла",af[i,1]
      wait
    else
      ? "Обработка файла",af[i,1]
      FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
        oXmlNode := oXmlDoc:aItems[1]:aItems[j]
        fl := .f. // проверка на пустоту строки
        for k := 1 to len(af[i,3])
          arr := af[i,3,k]
          if (n := ascan(oXmlNode:aAttr, {|x| upper(x[1])==upper(arr[1]) })) > 0
            fl := !empty(oXmlNode:aAttr[n,2])
            if fl ; exit ; endif
          endif
        next k
        if fl // tag в одну строку
          s1 := "{"
          for k := 1 to len(af[i,3])
            arr := af[i,3,k]
            sval := ""
            if (n := ascan(oXmlNode:aAttr, {|x| upper(x[1])==upper(arr[1]) }))==0
              if eq_any(upper(arr[1]),"DATEBEG","DATEEND","DATE_B","DATE_E")
                sval := 'stod("")'
              else
                ? "Ошибка в обработке атрибута",arr[1]
                wait
              endif
            else
              do case
                case arr[2] == "N"
                  sval := oXmlNode:aAttr[n,2]
                case arr[2] == "C"
                  c := '"'
                  if c $ oXmlNode:aAttr[n,2]
                    c := "'"
                  endif
                  sval := c+charone(" ",hb_AnsiToOem(oXmlNode:aAttr[n,2]))+c
                case arr[2] == "D"
                  sval := oXmlNode:aAttr[n,2]
                  if "-" $ sval
                    sval := 'stod("'+alltrim(charrem("-",sval))+'")'
                  else
                    sval := 'stod("'+alltrim(dtos(ctod(sval)))+'")'
                  endif
                otherwise
                  if eq_any(upper(arr[1]),"DATEBEG","DATEEND","DATE_B","DATE_E")
                    sval := 'stod("")'
                  else
                    ? "Ошибка в обработке атрибута",arr[1],arr[2]
                    wait
                  endif
              endcase
            endif
            s1 += sval + ","
            if k == iik
              if ascan(arr_UQ, sval) == 0
                aadd(arr_UQ, sval)
              else
                fl := .f.
              endif
            endif
          next k
          if fl
            add_string("aadd("+s+", "+left(s1,len(s1)-1)+"})")
          endif
        else // развёрнутый tag
          for k := 1 to len(af[i,3])
            arr := af[i,3,k]
            if !empty(mo_read_xml_stroke(oXmlNode,upper(arr[1])))
              fl := .t. ; exit
            endif
          next k
          if fl
            s1 := "{"
            for k := 1 to len(af[i,3])
              arr := af[i,3,k]
              sval := mo_read_xml_stroke(oXmlNode,upper(arr[1]))
              if empty(sval)
                if eq_any(upper(arr[1]),"DATEBEG","DATEEND","DATE_B","DATE_E")
                  sval := 'stod("")'
                else
                  ? "Ошибка в обработке атрибута",arr[1]
                  ? af[i,1]
                  ? s,s1
                  wait
                endif
              else
                do case
                  case arr[2] == "N"
                    //
                  case arr[2] == "C"
                    c := '"'
                    if c $ sval
                      c := "'"
                    endif
                    sval := c+charone(" ",sval)+c
                  case arr[2] == "D"
                    if "-" $ sval
                      sval := 'stod("'+alltrim(charrem("-",sval))+'")'
                    else
                      sval := 'stod("'+alltrim(dtos(ctod(sval)))+'")'
                    endif
                  otherwise
                    if eq_any(upper(arr[1]),"DATEBEG","DATEEND","DATE_B","DATE_E")
                      sval := 'stod("")'
                    else
                      ? "Ошибка в обработке атрибута",arr[1],arr[2]
                      ? af[i,1]
                      ? s,s1
                      wait
                    endif
                endcase
              endif
              s1 += sval + ","
              if k == iik
                if ascan(arr_UQ, sval) == 0
                  aadd(arr_UQ, sval)
                elseif eq_any(upper(af[i,1]),"V018.XML","V019.XML")
                  // могут быть и есть дубликаты, т.к. хранится несколько лет
                else
                  fl := .f.
                endif
              endif
            next k
            if fl
              add_string("aadd("+s+", "+left(s1,len(s1)-1)+"})")
            endif
          endif
        endif
      NEXT j
    ENDIF
  else  // DBF-файл
    if !file(af[i,1])
      ? "Не найден файл",af[i,1]
      wait
    else
      ? "Обработка файла",af[i,1]
      use (af[i,1]) new alias TMP
      go top
      do while !eof()
        fl := .f. // проверка на пустоту строки
        for k := 1 to len(af[i,3])
          arr := af[i,3,k]
          if (n := fieldnum(arr[1])) > 0
            fl := !empty(fieldget(n))
            if fl ; exit ; endif
          endif
        next k
        if fl
          s1 := "{"
          for k := 1 to len(af[i,3])
            arr := af[i,3,k]
            sval := ""
            if (n := fieldnum(arr[1])) == 0
              if eq_any(upper(arr[1]),"DATEBEG","DATEEND")
                sval := 'stod("")'
              else
                ? "Ошибка в обработке атрибута",arr[1]
                ? af[i,1]
                ? s,s1
                wait
              endif
            else
              do case
                case arr[2] == "N"
                  sval := ltrim(str(fieldget(n)))
                case arr[2] == "C"
                  c := '"'
                  if c $ fieldget(n)
                    c := "'"
                  endif
                  s2 := alltrim(fieldget(n))
                  if "^" $ s2  // для справочника ОКСМ
                    s2 := beforatnum("^",s2)
                  endif
                  sval := c+charone(" ",s2)+c
                case arr[2] == "D"
                  if fieldtype(arr[1]) == "D"
                    sval := 'stod("'+alltrim(dtos(fieldget(n)))+'")'
                  else // == "C"
                    sval := 'stod("'+alltrim(dtos(ctod(fieldget(n))))+'")'
                  endif
                otherwise
                  if eq_any(upper(arr[1]),"DATEBEG","DATEEND")
                    sval := 'stod("")'
                  else
                    ? "Ошибка в обработке атрибута",arr[1],arr[2]
                    ? af[i,1]
                    ? s,s1
                    wait
                  endif
              endcase
            endif
            s1 += sval + ","
            if k == iik
              if ascan(arr_UQ, sval) == 0
                aadd(arr_UQ, sval)
              else
                fl := .f.
              endif
            endif
          next k
          if fl
            add_string("aadd("+s+", "+left(s1,len(s1)-1)+"})")
          endif
        endif
        skip
      enddo
      use
    ENDIF
  endif
next i
//
add_string("// T008.xml - Коды ошибок в протоколах обработки инф.пакетов")
add_string("// 1 - NAME (C), 2 - CODE (N), 3 - NAME_F (C), 4 - DATE_B (D), 5 - DATE_E (D)")
add_string("Public glob_T008 := {}")
// читаем файл в память
oXmlDoc := HXMLDoc():Read("T008.xml")
FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
  if Empty( oXmlDoc:aItems )
    fl := func_error(4,"Ошибка в чтении файла "+nfile)
    exit
  endif
  mNAME := ""
  oXmlNode := oXmlDoc:aItems[1]:aItems[j]
  if "ZGLV" == oXmlNode:title
  elseif "ZAP" == oXmlNode:title
    mNAME   := mo_read_xml_stroke(oXmlNode,"NAME")
    mCODE   := mo_read_xml_stroke(oXmlNode,"CODE")
    mNAME_F := mo_read_xml_stroke(oXmlNode,"NAME_F")
    mDATE_B := charrem("-",(mo_read_xml_stroke(oXmlNode,"DATE_B")))
    mDATE_E := charrem("-",(mo_read_xml_stroke(oXmlNode,"DATE_E")))
  endif
  if !empty(mNAME)
    add_string('aadd(glob_T008,{"'+mNAME+'",'+mCODE+',"'+mNAME_F+'",'+;
               'stod("'+alltrim(mDATE_B)+'"),stod("'+alltrim(mDATE_E)+'")})')
  endif
next j
add_string("return NIL")
fclose(fp)
return NIL

*

***** проверить наличие в XML-файле тэга и вернуть его значение
Function mo_read_xml_stroke(_node,_title)
// _node - указатель на узел
// _title - наименование тэга
Local ret := "", oNode
// ищем необходимый "_title" тэг в узле "_node"
oNode := _node:Find(_title)
if oNode != NIL
  ret := mo_read_xml_tag(oNode)
endif
return ret

***** вернуть значение тэга
Function mo_read_xml_tag(oNode)
// oNode - указатель на узел
Local ret := "", c
if empty(oNode:aItems)
  //
elseif (c := valtype(oNode:aItems[1])) == "C"
  ret := hb_AnsiToOem(alltrim(oNode:aItems[1]))
endif
return ret

***** пребразовать дату из "2002-02-01" в тип "DATE"
Function xml2date(s)
return stod(charrem("-",s))
