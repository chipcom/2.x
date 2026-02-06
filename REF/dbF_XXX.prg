#include 'inkey.ch'
#include 'function.ch'
#include 'common.ch'
#include 'edit_spr.ch'
#include "chip_mo.ch"

#include 'tbox.ch'

#require 'hbsqlit3'

// =========== F003 ===================
//
// 09.09.25 {_MO_KOD_TFOMS,_MO_SHORT_NAME}
Function viewf003()

  Local nTop, nLeft, nBottom, nRight
  Local tmp_select := Select()
  Local l := 0, fl
  Local ar, aStruct, dbName := '_mo_f003', indexName := cur_dir() + dbName
  Local color_say := 'N/W', color_get := 'W/N*'
  Local oBox, oBoxRegion
  Local strRegion := 'Выбор региона'
  Local lFileCreated := .f.
  Local retMCOD := { '', Space( 10 ) }
  Local ar_f010 := getf010()
  Local selectedRegion := '34'
  Local sbase := 'mo_add'
  Local prev_codem := 0, cur_codem := 0
  Local i

  Private nRegion := 34
  Private tmpName := cur_dir() + 'tmp_F003', tmpAlias := 'tF003'
  Private oBoxCompany
  Private fl_space := .f., fl_other_region := .f.

  ar := {}
  For i := 1 To Len( ar_f010 )
    AAdd( ar, ar_f010[ i, 1 ] )
    l := Max( l, Len( ar[ i ] ) )
  Next

  dbUseArea( .t., 'DBFNTX', dir_exe() + dbName, dbName, .t., .f. )
  aStruct := ( dbName )->( dbStruct() )
  ( dbName )->( dbCreateIndex( indexName, 'substr(MCOD,1,2)', , NIL ) )

  nTop := 4
  nLeft := 3
  nBottom := 23
  nRight := 77

  // окно выбора региона
  oBoxRegion := tbox():new( nTop, nLeft, nBottom, nRight )
  oBoxRegion:Caption := 'Выберите регион'
  oBoxRegion:Frame := BORDER_SINGLE

  // окно полного наименования организации
  oBoxCompany := tbox():new( 19, 11, 21, 68 )
  oBoxCompany:Frame := BORDER_NONE
  oBoxCompany:Color := color5

  // главное окно
  oBox := Nil // уничтожим окно
  oBox := tbox():new( 2, 10, 22, 70 )
  oBox:Color := color_say + ',' + color_get
  oBox:Frame := BORDER_DOUBLE
  oBox:MessageLine := '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор'
  oBox:Save := .t.

  oBoxRegion:MessageLine := '^^ или нач.буква - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор'
  oBoxRegion:Save := .t.
  oBoxRegion:view()
  nRegion := AChoice( oBoxRegion:Top + 1, oBoxRegion:Left + 1, oBoxRegion:Bottom -1, oBoxRegion:Right - 1, ar, , , 34 )
  If nRegion == 0
    ( dbName )->( dbCloseArea() )
    ( tmpAlias )->( dbCloseArea() )
    Select ( tmp_select )
    Return retMCOD
  Else
    selectedRegion  := ar_f010[ nRegion, 2 ]
  Endif
  fl_other_region := .f.

  // создадим временный файл для отбора организаций выбранного региона
  dbCreate( tmpName, aStruct )
  dbUseArea( .t.,, tmpName, tmpAlias, .t., .f. )

  ( dbName )->( dbGoTop() )
  ( dbName )->( dbSeek( selectedRegion ) )
  Do While SubStr( ( dbName )->MCOD, 1, 2 ) == selectedRegion
    ( tmpAlias )->( dbAppend() )
    ( tmpAlias )->MCOD := ( dbName )->MCOD
    ( tmpAlias )->NAMEMOK := ( dbName )->NAMEMOK
    ( tmpAlias )->NAMEMOP := ( dbName )->NAMEMOP
    ( tmpAlias )->ADDRESS := ( dbName )->ADDRESS
    ( tmpAlias )->YEAR := ( dbName )->YEAR

    ( dbName )->( dbSkip() )
  Enddo

  oBox:Caption := 'Выбор направившей организации'
  oBox:view()
  dbCreateIndex( tmpName, 'NAMEMOK', , NIL )

  ( tmpAlias )->( dbGoTop() )
  If fl := alpha_browse( oBox:Top + 1, oBox:Left + 1, oBox:Bottom -5, oBox:Right - 1, 'ColumnF003', color0, , , , , , 'ViewRecordF003', 'controlF003', , { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B' } )
    // проверяем выбор
    If ( ifi := hb_AScan( glob_arr_mo(), {| x| x[ _MO_KOD_FFOMS ] == ( tmpAlias )->MCOD }, , , .t. ) ) > 0
      // нашли в файле
      Alert( 'Медицинское учреждение уже добавлено в справочник!' )
    Else
      If g_use( dir_server() + sbase, dir_server() + sbase, sbase, , .t., )
        ( sbase )->( dbGoTop() )
        Do While ! ( sbase )->( Eof() )
          prev_codem := ( sbase )->CODEM
          ( sbase )->( dbSkip() )
          cur_codem := ( sbase )->CODEM
          If ( Val( cur_codem ) - Val( prev_codem ) ) != 1
            ( sbase )->( dbAppend() )
            ( sbase )->MCOD := ( tmpAlias )->MCOD
            ( sbase )->CODEM := Str( Val( prev_codem ) + 1, 6 )
            ( sbase )->NAMEF := ( tmpAlias )->NAMEMOK
            ( sbase )->NAMES := ( tmpAlias )->NAMEMOP
            ( sbase )->ADRES := ( tmpAlias )->ADDRESS
            ( sbase )->DEND := hb_SToD( '20251231' )
            Exit
          Endif
        Enddo
        ( sbase )->( dbCloseArea() )
        retMCOD := { Str( Val( prev_codem ) + 1, 6 ), AllTrim( ( tmpAlias )->NAMEMOK ) }
      Endif
    Endif

  Endif
  selectedRegion := ''

  oBoxRegion := NIL
  oBoxCompany := nil
  oBox := nil
  ( tmpAlias )->( dbCloseArea() )
  ( dbName )->( dbCloseArea() )
  Select ( tmp_select )

  Return retMCOD

// 15.10.21
Function controlf003( nkey, oBrow )

  Local ret := -1
  Return ret

// 15.10.21
Function columnf003( oBrow )

  Local oColumn

  oColumn := TBColumnNew( Center( 'Наименование', 50 ), {|| Left( ( tmpAlias )->NAMEMOK, 50 ) } )
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ - выход; ^<Enter>^ - выбор' )

  Return Nil

// 21.01.21
Function viewrecordf003()

  Local i, arr := {}, count

  If ! oBoxCompany:Visible
    oBoxCompany:view()
  Else
    oBoxCompany:clear()
  Endif
  // разобьем полное наменование на подстроки
  // perenos(arr,(tmpAlias)->NAMEMOP,50)
  perenos( arr, ( tmpAlias )->NAMEMOP, oBoxCompany:Width )
  count := iif( Len( arr ) > oBoxCompany:Height, oBoxCompany:Height, Len( arr ) )

  For i := 1 To count
    @ oBoxCompany:Top + i - 1, oBoxCompany:Left + 1 Say arr[ i ]
  Next

  Return Nil

// 09.09.25
Function getf003mo( mCode )

  // mCode - код МО по F003
  Local arr, dbName := '_mo_f003', indexName := cur_dir() + dbName + 'cod'
  Local tmp_select := Select()
  Local i // возьмём первое по порядку МО

  If SubStr( mCode, 1, 2 ) != '34'

    arr := AClone( glob_arr_mo()[ 1 ] )
    If Empty( mCode ) .or. ( Len( mCode ) != 6 )
      For i := 1 To Len( arr )
        If ValType( arr[ i ] ) == 'C'
          arr[ i ] := Space( 6 ) // и очистим строковые элементы
        Endif
      Next
      Select( tmp_select )
      Return arr
    Endif

    arr := Array( _MO_LEN_ARR )

    dbUseArea( .t., 'DBFNTX', dir_exe() + dbName, dbName, .t., .f. )
    ( dbName )->( dbCreateIndex( indexName, 'MCOD', , NIL ) )

    ( dbName )->( dbGoTop() )
    If ( dbName )->( dbSeek( mCode ) )
      arr[ _MO_KOD_FFOMS ]  := ( dbName )->MCOD
      arr[ _MO_KOD_TFOMS ]  := ''
      arr[ _MO_FULL_NAME ]  := AllTrim( ( dbName )->NAMEMOP )
      arr[ _MO_SHORT_NAME ] := AllTrim( ( dbName )->NAMEMOK )
      arr[ _MO_ADRES ]      := AllTrim( ( dbName )->ADDRESS )
      arr[ _MO_PROD ]       := ''
      arr[ _MO_DEND ]       := CToD( '01-01-2021' )
      arr[ _MO_STANDART ]   := 1
      arr[ _MO_UROVEN ]     := 1
      arr[ _MO_IS_MAIN ]    := .t.
      arr[ _MO_IS_UCH ]     := .t.
      arr[ _MO_IS_SMP ]     := .t.
    Endif
    ( dbName )->( dbCloseArea() )
  Else
    arr := AClone( glob_arr_mo()[ 1 ] )
    For i := 1 To Len( arr )
      If ValType( arr[ i ] ) == 'C'
        arr[ i ] := Space( 6 ) // и очистим строковые элементы
      Endif
    Next
    If !Empty( mCode )
      If ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == mCode } ) ) > 0
        arr := glob_arr_mo()[ i ]
      Elseif ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_FFOMS ] == mCode } ) ) > 0
        arr := glob_arr_mo()[ i ]
      Endif
    Endif
  Endif
  Select( tmp_select )
  Return arr

// =========== F005 ===================
//
// 27.02.21 вернуть массив Классификатор статусов оплаты медицинской помощи F005.xml
Function getf005()

  // F005.xml - Классификатор статусов оплаты медицинской помощи
  // 1 - STNAME(C)  2 - IDIDST(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { 'Не принято решение об оплате', 0, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Оплачена', 1, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Не оплачена', 2, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Частично оплачена', 3, SToD( '20110101' ), SToD( '' ) } )
  Endif

  Return _arr

// =========== F006 ===================
//
// 19.12.22 вернуть массив Классификатор видов контроля F006.xml
Function getf006()

  // F006.xml - Классификатор видов контроля
  // IDVID,     "N",   2, 0  // Код вида контроля
  // VIDNAME,   "C", 350, 0  // Наименование вида контроля
  // DATEBEG,   "D",   8, 0  // Дата начала действия записи
  // DATEEND,   "D",   8, 0  // Дата окончания действия записи

  Static _arr := {}
  Local db
  Local aTable
  Local nI

  If Len( _arr ) == 0
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT idvid, vidname, datebeg, dateend FROM f006' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    db := nil
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  Endif

  Return _arr

// =========== F007 ===================
//
// 27.02.21 вернуть массив Классификатор ведомственной принадлежности медицинской организации F007.xml
Function getf007()

  // F007.xml - Классификатор ведомственной принадлежности медицинской организации
  // 1 - VEDNAME(C)  2 - IDVED(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { 'Муниципального образования', 1, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Субъекта Российской Федерации', 2, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Минздравсоцразвития России', 3, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Минобрнауки России', 4, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Минобороны России', 5, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'МВД России', 6, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Минюста России ГУИН', 7, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'ФСБ России', 8, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'РАМН', 9, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'ФМБА России', 10, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Прочих федеральных министерств и ведомств', 11, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'НУЗ ОАО "РЖД"', 12, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Автономные МО', 13, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Общественных, религиозных организаций', 14, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Иные', 15, SToD( '20110101' ), SToD( '' ) } )
  Endif

  Return _arr

// =========== F008 ===================
//
// 27.02.21 вернуть Классификатор типов документов, подтверждающих факт страхования по ОМС F008.xml
Function getf008()

  // F008.xml - Классификатор типов документов, подтверждающих факт страхования по ОМС
  // 1 - DOCNAME(C)  2 - IDDOC(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { 'Полис ОМС старого образца', 1, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Временное свидетельство, подтверждающее оформление полиса обязательного медицинского страхования', 2, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Полис ОМС единого образца', 3, SToD( '20110101' ), SToD( '' ) } )
  Endif

  Return _arr

// =========== F009 ===================
//
// 27.02.21 вернуть Классификатор статуса застрахованного лица F009.xml
Function getf009()

  // F009.xml - Классификатор статуса застрахованного лица
  // 1 - StatusName(C)  2 - IDStatus(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { 'Работающий', 1, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { 'Неработающий', 2, SToD( '20110101' ), SToD( '' ) } )
  Endif

  Return _arr

// =========== F010 ===================
//
// 14.10.24 вернуть массив регионов по справочнику регионов ТФОМС F010.xml
Function getf010()

  // F010.xml - Классификатор субъектов Российской Федерации
  // KOD_TF,       "C",      2,      0  // Код ТФОМС
  // KOD_OKATO,     "C",    5,      0  // Код по ОКАТО (Приложение А O002).
  // SUBNAME,     "C",    254,      0  // Наименование субъекта РФ
  // OKRUG,     "N",        1,      0  // Код федерального округа
  // DATEBEG,   "D",   8, 0  // Дата начала действия записи
  // DATEEND,   "D",   8, 0   // Дата окончания действия записи

  Static _arr := {}
  Local db
  Local aTable
  Local nI

  If Len( _arr ) == 0
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT subname, kod_tf, okrug, kod_okato, datebeg, dateend FROM f010' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) } )
      Next
    Endif
    db := nil
    AAdd( _arr, { 'Федерального подчинения', '99', 0 } )
    If hb_FileExists( dir_exe() + 'f010' + sdbf() )
      FErase( dir_exe() + 'f010' + sdbf() )
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  Endif

  Return _arr

// =========== F011 ===================
//
// 19.12.22 вернуть Классификатор типов документов, удостоверяющих личность F011.xml
Function getf011()

  // F011.xml - Классификатор типов документов, удостоверяющих личность
  // IDDoc,     "C",   2, 0  // Код типа документа
  // DocName,   "C", 254, 0  // Наименование типа документа
  // DocSer,    "C",  10, 0  // Маска серии документа
  // DocNum,    "C",  20, 0  // Маска номера документа
  // DATEBEG,   "D",   8, 0  // Дата начала действия записи
  // DATEEND,   "D",   8, 0  // Дата окончания действия записи

  Static _arr := {}
  Local db
  Local aTable
  Local nI

  If Len( _arr ) == 0
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT docname, iddoc, datebeg, dateend, docser, docnum FROM f011' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), Val( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), AllTrim( aTable[ nI, 5 ] ), AllTrim( aTable[ nI, 6 ] ) } )
      Next
    Endif
    db := nil
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  Endif

  Return _arr

// =========== F012 ===================
//
// 27.02.21 вернуть Справочник ошибок форматно-логического контроля F012.xml
Function getf012()

  // F012.xml - Справочник ошибок форматно-логического контроля
  // 1 - Opis(C)  2 - Kod(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DopInfo(C)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { "Ошибочный порядок тегов", 901, SToD( "20110101" ), SToD( "" ), "Нарушен порядок следования тегов, либо отсутствует обязательный тег." } )
    AAdd( _arr, { "Отсутствует обязательное поле", 902, SToD( "20110101" ), SToD( "" ), "Отсутствует значение в обязательном теге." } )
    AAdd( _arr, { "Неверный тип данных", 903, SToD( "20110101" ), SToD( "" ), "Заполненное поле содержит данные, не соответствующие его типу." } )
    AAdd( _arr, { "Неверный код", 904, SToD( "20110101" ), SToD( "" ), "Значение не соответствует допустимому." } )
    AAdd( _arr, { "Дубль ключевого идентификатора", 905, SToD( "20110101" ), SToD( "" ), "Уникальный код уже использовался в данном файле." } )
    AAdd( _arr, { "Неверный формат пакета", 801, SToD( "20110101" ), SToD( "" ), "Пакет не упакован в архив формата zip." } )
    AAdd( _arr, { "Неверное имя пакета", 802, SToD( "20110101" ), SToD( "" ), "Имя пакета не соответствует документации" } )
    AAdd( _arr, { "В пакете содержатся не все файлы", 803, SToD( "20110101" ), SToD( "" ), "Один или два файлы не найдены в zip архиве" } )
    AAdd( _arr, { "Неверное значение элемента", 804, SToD( "20110101" ), SToD( "" ), "Неверное значение элемента" } )
    AAdd( _arr, { "Пакет с таким именем был зарегистрирован ранее", 805, SToD( "20110101" ), SToD( "" ), "Пакет с таким именем был зарегистрирован ранее" } )
  Endif

  Return _arr

// =========== F014 ===================
//
// 19.05.23 вернуть массив справочнику ФФОМС F014.xml
Function getf014()

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
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'kod, ' + ;
      'osn, ' + ;
      'naim, ' + ;
      'komment, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM f014' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), ;
          AllTrim( aTable[ nI, 1 ] ) + ' (' + AllTrim( aTable[ nI, 2 ] ) + ') ' + AllTrim( aTable[ nI, 3 ] ), ;
          AllTrim( aTable[ nI, 4 ] ), ;
          AllTrim( aTable[ nI, 2 ] ) } )
      Next
    Endif
    db := nil
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  Endif

  Return _arr

// 08.04.25 вернуть строку для кода дефекта с описанием ошибки ФФОМС из справочника F014
Function ret_f014( lkod )

  Local arrErrors := getf014()
  Local row := {}

  For Each row in arrErrors
    If row[ 1 ] == lkod
      Return '(' + lstr( row[ 1 ] ) + ') ' + row[ 2 ] + ', [' + row[ 3 ] + ']'
    Endif
  Next

  Return 'Неизвестная категория проверки с идентификатором: ' + Str( lkod )

// 31.01.25 вернуть строку для кода дефекта с описанием ошибки ФФОМС из справочника F014
Function retarr_f014( lkod, isEmpty )

  Local arrErrors := getf014()
  Local row := {}

  For Each row in arrErrors
    If row[ 1 ] == lkod
      Return row
    Endif
  Next

Return iif( isEmpty, {}, { 'Неизвестная категория проверки с идентификатором: ' + Str( lkod ), '', '' } )

// =========== F015 ===================
//
// 17.02.21 вернуть массив справочнику ТФОМС F015.xml
Function getf015()

  // F015.xml - Классификатор федеральных округов
  // 1 - OKRNAME(C)  2 - KOD_OK(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Local dbName := "f015"
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { "Центральный федеральный округ", 1, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "Южный федеральный округ", 2, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "Северо-Западный федеральный округ", 3, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "Дальневосточный федеральный округ", 4, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "Сибирский федеральный округ", 5, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "Уральский федеральный округ", 6, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "Приволжский федеральный округ", 7, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "Северо-Кавказский федеральный округ", 8, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "-", 0, SToD( "20110101" ), SToD( "" ) } )
  Endif

  Return _arr

// 22.01.26
function get_f032()

  static arr
  Local tmp_select

  if HB_ISNIL( arr )
    arr := {}
    r_use( dir_exe() + '_mo_f032', cur_dir() + '_mo_f032', 'F032' )
    f032->( dbGoTop() )
    do while ! f032->( Eof() )
      AAdd( arr, { AllTrim( f032->NAMEMOK ), f032->MCOD } )
      f032->( dbSkip() )
    enddo
    dbCloseArea()
    Select ( tmp_select )
  endif
  return arr

// 24.01.26
function get_f032_prik()

  static arr

  local i, j, loc_m
  local arr_glob := glob_arr_mo()
  local arr_f032 := get_f032()

  if HB_ISNIL( arr )
    arr := {}
    for i := 1 to len( arr_f032 )
      loc_m := arr_f032[ i, 2 ]
      if ( j := ascan( arr_glob, { | x | ( x[ _MO_KOD_FFOMS ] == loc_m ) .and. x[ _MO_IS_UCH ] } ) ) > 0
        AAdd( arr, { arr_f032[ i, 1 ], arr_f032[ i, 2 ] } )
      endif
    next
  endif
  return arr

// 17.01.26 вернуть UIDMO из справочника F032
Function ret_uidmo_f032( mcod )

  Local tmp_select
  Local cUIDMO := ''

  tmp_select := Select()
  r_use( dir_exe() + '_mo_f032', cur_dir() + '_mo_f032', 'F032' )
  f032->( dbSeek( mcod ) )
  if f032->( Found() )
    cUIDMO := f032->UIDMO
  Endif
  dbCloseArea()
  Select ( tmp_select )

  return cUIDMO

// 06.02.26 вернуть массив из справочника F033
Function get_f033( mcod )

  Local tmp_select
  Local cUIDMO
  Local arr := {}

  cUIDMO := ret_uidmo_f032( mcod )

  if ! Empty( cUIDMO )
    tmp_select := Select()
    r_use( dir_exe() + '_mo_f033', cur_dir() + '_mo_f033', 'F033' )
    f033->( dbSeek( cUIDMO ) )
    Do While SubStr( f033->uidspmo, 1, 11 ) == cUIDMO .and. ! f033->( Eof() )
      AAdd( arr, { AllTrim( f033->NAM_SK ), f033->UIDSPMO } )
      f033->( dbSkip() )
    Enddo
    dbCloseArea()
    Select ( tmp_select )
  endif

  return arr
