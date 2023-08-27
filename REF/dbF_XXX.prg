#include 'inkey.ch'
#include 'function.ch'
#include 'common.ch'
#include 'edit_spr.ch'
#include "chip_mo.ch"

#include 'tbox.ch'

#require 'hbsqlit3'

// =========== F003 ===================
//
// 20.01.21 {_MO_KOD_TFOMS,_MO_SHORT_NAME}
Function viewF003()

  local nTop, nLeft, nBottom, nRight
  local tmp_select := select()
  local l := 0, fl
  Local ar, aStruct, dbName := '_mo_f003', indexName := cur_dir + dbName
	local color_say := 'N/W', color_get := 'W/N*'
  local oBox, oBoxRegion
  local strRegion := 'Выбор региона' 
  local lFileCreated := .f.
  local retMCOD := { '', space(10) }
  local ar_f010 := getf010()
  local selectedRegion := '34'
  local sbase := 'mo_add'
  local prev_codem := 0, cur_codem := 0

  private nRegion := 34
  private tmpName := cur_dir + 'tmp_F003', tmpAlias := 'tF003'
  private oBoxCompany
  private fl_space := .f., fl_other_region := .f.

  ar := {}
  for i := 1 to len(ar_f010)
    aadd(ar, ar_f010[i, 1])
    l := max(l,len(ar[i]))
  next

  dbUseArea( .t., 'DBFNTX', exe_dir + dbName, dbName, .t., .f. )
  aStruct := (dbName)->(dbStruct())
  (dbName)->(dbCreateIndex( indexName, 'substr(MCOD,1,2)', , NIL ))

  nTop := 4
  nLeft := 3
  nBottom := 23
  nRight := 77

  // окно выбора региона
  oBoxRegion := TBox():New( nTop, nLeft, nBottom, nRight )
  oBoxRegion:Caption := 'Выберите регион'
  oBoxRegion:Frame := BORDER_SINGLE
    
  // окно полного наименования организации
  oBoxCompany := TBox():New( 19, 11, 21, 68 )
  oBoxCompany:Frame := BORDER_NONE
  oBoxCompany:Color := color5

  // главное окно
  oBox := NIL // уничтожим окно
  oBox := TBox():New( 2, 10, 22, 70 )
	oBox:Color := color_say + ',' + color_get
	oBox:Frame := BORDER_DOUBLE
  oBox:MessageLine := '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор'
  oBox:Save := .t.

  oBoxRegion:MessageLine := '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор'
  oBoxRegion:Save := .t.
  oBoxRegion:View()
  nRegion := AChoice( oBoxRegion:Top + 1, oBoxRegion:Left + 1, oBoxRegion:Bottom - 1, oBoxRegion:Right - 1, ar, , , 34 )
  if nRegion == 0
    (dbName)->(dbCloseArea())
    (tmpAlias)->(dbCloseArea())
    select (tmp_select)
    return retMCOD
  else
    selectedRegion  := ar_f010[nRegion, 2]
  endif
  fl_other_region := .f.

  // создадим временный файл для отбора организаций выбранного региона
  dbCreate(tmpName, aStruct)
  dbUseArea( .t.,, tmpName, tmpAlias, .t., .f. )
        
  (dbName)->(dbGoTop())
  (dbName)->(dbSeek(selectedRegion))
  do while substr((dbName)->MCOD, 1, 2) == selectedRegion
    (tmpAlias)->(dbAppend())
    (tmpAlias)->MCOD := (dbName)->MCOD
    (tmpAlias)->NAMEMOK := (dbName)->NAMEMOK
    (tmpAlias)->NAMEMOP := (dbName)->NAMEMOP
    (tmpAlias)->ADDRESS := (dbName)->ADDRESS
    (tmpAlias)->YEAR := (dbName)->YEAR
        
    (dbName)->(dbSkip())
  enddo
                
  oBox:Caption := 'Выбор направившей организации'
  oBox:View()
  dbCreateIndex( tmpName, 'NAMEMOK', , NIL )

  (tmpAlias)->(dbGoTop())
  if fl := Alpha_Browse(oBox:Top + 1, oBox:Left + 1, oBox:Bottom - 5, oBox:Right - 1, 'ColumnF003', color0, , , , , , 'ViewRecordF003', 'controlF003', , {'═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B'} )
    // проверяем выбор
    if (ifi := hb_ascan(glob_arr_mo, {|x| x[_MO_KOD_FFOMS] == (tmpAlias)->MCOD }, , , .t.) ) > 0
      // нашли в файле
      alert('Медицинское учреждение уже добавлено в справочник!')
    else
      if G_Use(dir_server + sbase, dir_server + sbase, sbase, , .t.,)
        (sbase)->(dbGoTop())
        do while ! (sbase)->(Eof())
          prev_codem := (sbase)->CODEM
          (sbase)->(dbSkip())
          cur_codem := (sbase)->CODEM
          if (val(cur_codem) - val(prev_codem)) != 1
            (sbase)->(dbappend())
            (sbase)->MCOD := (tmpAlias)->MCOD
            (sbase)->CODEM := str(val(prev_codem) + 1, 6)
            (sbase)->NAMEF := (tmpAlias)->NAMEMOK
            (sbase)->NAMES := (tmpAlias)->NAMEMOP
            (sbase)->ADRES := (tmpAlias)->ADDRESS
            (sbase)->DEND := hb_SToD('20251231')
            exit
          endif
        enddo
        (sbase)->(dbCloseArea())
        retMCOD := { str(val(prev_codem) + 1, 6), AllTrim((tmpAlias)->NAMEMOK) }
      endif
    endif
        
  endif
  selectedRegion := ''

  oBoxRegion := NIL
  oBoxCompany := nil
  oBox := nil
  (tmpAlias)->(dbCloseArea())
  (dbName)->(dbCloseArea())
  select (tmp_select)
  return retMCOD

// 15.10.21
Function controlF003(nkey, oBrow)
  Local ret := -1, cCode, rec

  return ret
    
// 15.10.21
Function ColumnF003(oBrow)
  Local oColumn
  
  oColumn := TBColumnNew(center('Наименование', 50), {|| left((tmpAlias)->NAMEMOK, 50)})
  oBrow:addColumn(oColumn)
  status_key('^<Esc>^ - выход; ^<Enter>^ - выбор')
  return nil

// 21.01.21
Function ViewRecordF003()
  Local i, arr := {}, count

  if ! oBoxCompany:Visible
    oBoxCompany:View()
  else
    oBoxCompany:Clear()
  endif
  // разобьем полное наменование на подстроки
  // perenos(arr,(tmpAlias)->NAMEMOP,50)
  perenos(arr, (tmpAlias)->NAMEMOP, oBoxCompany:Width)
  count := iif(len(arr) > oBoxCompany:Height, oBoxCompany:Height, len(arr))

  for i := 1 to count
    @ oBoxCompany:Top + i - 1, oBoxCompany:Left + 1 say arr[i]
  next
  
  return nil

// 15.10.21
Function getF003mo(mCode)
  // mCode - код МО по F003
  Local arr, dbName := '_mo_f003', indexName := cur_dir + dbName + 'cod'
  local tmp_select := Select()
  Local i // возьмём первое по порядку МО

  if SubStr(mCode,1,2) != '34'

    arr := aclone(glob_arr_mo[1])
    if empty(mCode) .or. (Len(mCode) != 6)
      for i := 1 to len(arr)
        if valtype(arr[i]) == 'C'
          arr[i] := space(6) // и очистим строковые элементы
        endif
      next
      Select(tmp_select)
      return arr
    endif

    arr := array(_MO_LEN_ARR)

    dbUseArea( .t., 'DBFNTX', exe_dir + dbName, dbName, .t., .f. )
    (dbName)->(dbCreateIndex( indexName, 'MCOD', , NIL ))

    (dbName)->(dbGoTop())
    if (dbName)->(dbSeek(mCode))
      arr[_MO_KOD_FFOMS]  := (dbName)->MCOD
      arr[_MO_KOD_TFOMS]  := ''
      arr[_MO_FULL_NAME]  := AllTrim((dbName)->NAMEMOP)
      arr[_MO_SHORT_NAME] := AllTrim((dbName)->NAMEMOK)
      arr[_MO_ADRES]      := AllTrim((dbName)->ADDRESS)
      arr[_MO_PROD]       := ''
      arr[_MO_DEND]       := ctod('01-01-2021')
      arr[_MO_STANDART]   := 1
      arr[_MO_UROVEN]     := 1
      arr[_MO_IS_MAIN]    := .t.
      arr[_MO_IS_UCH]     := .t.
      arr[_MO_IS_SMP]     := .t.
    endif
    (dbName)->(dbCloseArea())
  else
    arr := aclone(glob_arr_mo[1])
    for i := 1 to len(arr)
      if valtype(arr[i]) == 'C'
        arr[i] := space(6) // и очистим строковые элементы
      endif
    next
    if !empty(mCode)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == mCode })) > 0
        arr := glob_arr_mo[i]
      elseif (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_FFOMS] == mCode })) > 0
        arr := glob_arr_mo[i]
      endif
    endif
  endif
  Select(tmp_select)
  return arr

// =========== F005 ===================
//
// 27.02.21 вернуть массив Классификатор статусов оплаты медицинской помощи F005.xml
function getF005()
  // F005.xml - Классификатор статусов оплаты медицинской помощи
  //  1 - STNAME(C)  2 - IDIDST(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'Не принято решение об оплате', 0, stod('20110101'), stod('')})
    aadd(_arr, {'Оплачена', 1, stod('20110101'), stod('')})
    aadd(_arr, {'Не оплачена', 2, stod('20110101'), stod('')})
    aadd(_arr, {'Частично оплачена', 3, stod('20110101'), stod('')})
  endif

  return _arr

// =========== F006 ===================
//
// 19.12.22 вернуть массив Классификатор видов контроля F006.xml
function getF006()
  // F006.xml - Классификатор видов контроля
  // IDVID,     "N",   2, 0  // Код вида контроля
  // VIDNAME,   "C", 350, 0  // Наименование вида контроля
  // DATEBEG,   "D",   8, 0  // Дата начала действия записи
  // DATEEND,   "D",   8, 0  // Дата окончания действия записи

  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT idvid, vidname, datebeg, dateend FROM f006')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr

// =========== F007 ===================
//
// 27.02.21 вернуть массив Классификатор ведомственной принадлежности медицинской организации F007.xml
function getF007()
  // F007.xml - Классификатор ведомственной принадлежности медицинской организации
  //  1 - VEDNAME(C)  2 - IDVED(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'Муниципального образования', 1, stod('20110101'), stod('')})
    aadd(_arr, {'Субъекта Российской Федерации', 2, stod('20110101'), stod('')})
    aadd(_arr, {'Минздравсоцразвития России', 3, stod('20110101'), stod('')})
    aadd(_arr, {'Минобрнауки России', 4, stod('20110101'), stod('')})
    aadd(_arr, {'Минобороны России', 5, stod('20110101'), stod('')})
    aadd(_arr, {'МВД России', 6, stod('20110101'), stod('')})
    aadd(_arr, {'Минюста России ГУИН', 7, stod('20110101'), stod('')})
    aadd(_arr, {'ФСБ России', 8, stod('20110101'), stod('')})
    aadd(_arr, {'РАМН', 9, stod('20110101'), stod('')})
    aadd(_arr, {'ФМБА России', 10, stod('20110101'), stod('')})
    aadd(_arr, {'Прочих федеральных министерств и ведомств', 11, stod('20110101'), stod('')})
    aadd(_arr, {'НУЗ ОАО "РЖД"', 12, stod('20110101'), stod('')})
    aadd(_arr, {'Автономные МО', 13, stod('20110101'), stod('')})
    aadd(_arr, {'Общественных, религиозных организаций', 14, stod('20110101'), stod('')})
    aadd(_arr, {'Иные', 15, stod('20110101'), stod('')})
  endif

  return _arr

// =========== F008 ===================
//
// 27.02.21 вернуть Классификатор типов документов, подтверждающих факт страхования по ОМС F008.xml
function getF008()
  // F008.xml - Классификатор типов документов, подтверждающих факт страхования по ОМС
  //  1 - DOCNAME(C)  2 - IDDOC(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'Полис ОМС старого образца', 1, stod('20110101'), stod('')})
    aadd(_arr, {'Временное свидетельство, подтверждающее оформление полиса обязательного медицинского страхования', 2, stod('20110101'), stod('')})
    aadd(_arr, {'Полис ОМС единого образца', 3, stod('20110101'), stod('')})
  endif

  return _arr

// =========== F009 ===================
//
// 27.02.21 вернуть Классификатор статуса застрахованного лица F009.xml
function getF009()
  // F009.xml - Классификатор статуса застрахованного лица
  //  1 - StatusName(C)  2 - IDStatus(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'Работающий', 1, stod('20110101'), stod('')})
    aadd(_arr, {'Неработающий', 2, stod('20110101'), stod('')})
  endif

  return _arr

// =========== F010 ===================
//
// 17.12.22 вернуть массив регионов по справочнику регионов ТФОМС F010.xml
function getf010()
  // F010.xml - Классификатор субъектов Российской Федерации
  // KOD_TF,       "C",      2,      0  // Код ТФОМС
  // KOD_OKATO,     "C",    5,      0  // Код по ОКАТО (Приложение А O002).
  // SUBNAME,     "C",    254,      0  // Наименование субъекта РФ
  // OKRUG,     "N",        1,      0  // Код федерального округа
  // DATEBEG,   "D",   8, 0  // Дата начала действия записи
  // DATEEND,   "D",   8, 0   // Дата окончания действия записи

  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT subname, kod_tf, okrug, kod_okato, datebeg, dateend FROM f010')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), val(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
    aadd(_arr, {'Федерального подчинения', '99', 0})
    if hb_FileExists(exe_dir + 'f010' + sdbf)
      FErase(exe_dir + 'f010' + sdbf)
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr

// =========== F011 ===================
//
// 19.12.22 вернуть Классификатор типов документов, удостоверяющих личность F011.xml
function getF011()
  // F011.xml - Классификатор типов документов, удостоверяющих личность
  // IDDoc,     "C",   2, 0  // Код типа документа
  // DocName,   "C", 254, 0  // Наименование типа документа
  // DocSer,    "C",  10, 0  // Маска серии документа
  // DocNum,    "C",  20, 0  // Маска номера документа
  // DATEBEG,   "D",   8, 0  // Дата начала действия записи
  // DATEEND,   "D",   8, 0  // Дата окончания действия записи

  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table( db, 'SELECT docname, iddoc, datebeg, dateend, docser, docnum FROM f011')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]), val(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4]), alltrim(aTable[nI, 5]), alltrim(aTable[nI, 6])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr

// =========== F012 ===================
//
// 27.02.21 вернуть Справочник ошибок форматно-логического контроля F012.xml
function getF012()
  // F012.xml - Справочник ошибок форматно-логического контроля
  //  1 - Opis(C)  2 - Kod(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DopInfo(C)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"Ошибочный порядок тегов",901,stod("20110101"),stod(""),"Нарушен порядок следования тегов, либо отсутствует обязательный тег."})
    aadd(_arr, {"Отсутствует обязательное поле",902,stod("20110101"),stod(""),"Отсутствует значение в обязательном теге."})
    aadd(_arr, {"Неверный тип данных",903,stod("20110101"),stod(""),"Заполненное поле содержит данные, не соответствующие его типу."})
    aadd(_arr, {"Неверный код",904,stod("20110101"),stod(""),"Значение не соответствует допустимому."})
    aadd(_arr, {"Дубль ключевого идентификатора",905,stod("20110101"),stod(""),"Уникальный код уже использовался в данном файле."})
    aadd(_arr, {"Неверный формат пакета",801,stod("20110101"),stod(""),"Пакет не упакован в архив формата zip."})
    aadd(_arr, {"Неверное имя пакета",802,stod("20110101"),stod(""),"Имя пакета не соответствует документации"})
    aadd(_arr, {"В пакете содержатся не все файлы",803,stod("20110101"),stod(""),"Один или два файлы не найдены в zip архиве"})
    aadd(_arr, {"Неверное значение элемента",804,stod("20110101"),stod(""),"Неверное значение элемента"})
    aadd(_arr, {"Пакет с таким именем был зарегистрирован ранее",805,stod("20110101"),stod(""),"Пакет с таким именем был зарегистрирован ранее"})
  endif

  return _arr

// =========== F014 ===================
//
// 19.05.23 вернуть массив справочнику ФФОМС F014.xml
function getF014()
  // F014.xml - Классификатор причин отказа в оплате медицинской помощи
  // Kod,     "N",   3, 0  // Код ошибки
  // IDVID,   "N",   1, 0  // Код вида контроля, резервное поле
  // Naim,    "C",1000, 0  // Наименование причины отказа
  // Osn,     "C",  20, 0  // Основание отказа
  // Komment, "C", 100, 0  // Служебный комментарий
  // KodPG,   "C",  20, 0  // Код по форме N ПГ
  // DATEBEG, "D",   8, 0  // Дата начала действия записи
  // DATEEND, "D",   8, 0   // Дата окончания действия записи

  // возвращает массив
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'kod, ' + ;
      'osn, ' + ;
      'naim, ' + ;
      'komment, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM f014')
    if len(aTable) > 1
      for nI := 2 to Len(aTable)
        aadd(_arr, {val(aTable[nI, 1]), ;
          alltrim(aTable[nI, 1]) + ' (' + alltrim(aTable[nI, 2]) + ') ' + alltrim(aTable[nI, 3]), ;
          alltrim(aTable[nI, 4]), ;
          alltrim(aTable[nI, 2])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr

// =========== F015 ===================
//
// 17.02.21 вернуть массив справочнику ТФОМС F015.xml
function getF015()
  // F015.xml - Классификатор федеральных округов
  //  1 - OKRNAME(C)  2 - KOD_OK(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  local dbName := "f015"
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"Центральный федеральный округ",1,stod("20110101"),stod("")})
    aadd(_arr, {"Южный федеральный округ",2,stod("20110101"),stod("")})
    aadd(_arr, {"Северо-Западный федеральный округ",3,stod("20110101"),stod("")})
    aadd(_arr, {"Дальневосточный федеральный округ",4,stod("20110101"),stod("")})
    aadd(_arr, {"Сибирский федеральный округ",5,stod("20110101"),stod("")})
    aadd(_arr, {"Уральский федеральный округ",6,stod("20110101"),stod("")})
    aadd(_arr, {"Приволжский федеральный округ",7,stod("20110101"),stod("")})
    aadd(_arr, {"Северо-Кавказский федеральный округ",8,stod("20110101"),stod("")})
    aadd(_arr, {"-",0,stod("20110101"),stod("")})
  endif

  return _arr
