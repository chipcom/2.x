#include 'hbhash.ch'
#include 'function.ch'
#include 'chip_mo.ch'
#include 'edit_spr.ch'

#require 'hbsqlit3'

// =========== T005 ===================
//
// 19.05.23 вернуть массив ошибок ТФОМС T005.dbf
Function loadt005()

  // возвращает массив ошибок T005
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // T005 - Перечень ошибок ТФОМС
  // 1 - code(3)  2 - error(C) 3 - opis(M)
  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'code, ' + ;
      'error, ' + ;
      'opis ' + ;
      'FROM t005' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 3 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil

    // добавим из справочника _mo_f014.dbf
    For Each row in getf014()
      If ( j := AScan( _arr, {| x| x[ 1 ] == row[ 1 ] } ) ) == 0
        AAdd( _arr, { row[ 1 ], AllTrim( row[ 2 ] ), AllTrim( row[ 3 ] ) } )
      Endif
    Next
  Endif

  Return _arr

// 04.08.21 вернуть строку для кода дефекта с описанием ошибки ТФОМС из справочника T005.dbf
Function ret_t005( lkod )

  Local arrErrors := loadt005()
  Local row := {}

  For Each row in arrErrors
    If row[ 1 ] == lkod
      Return '(' + lstr( row[ 1 ] ) + ') ' + row[ 2 ] + ', [' + row[ 3 ] + ']'
    Endif
  Next

  Return 'Неизвестная категория проверки с идентификатором: ' + Str( lkod )

// 28.06.22 вернуть строку для кода дефекта с описанием ошибки ТФОМС из справочника T005.dbf
Function ret_t005_smol( lkod )

  Local arrErrors := loadt005()
  Local row := {}

  For Each row in arrErrors
    If row[ 1 ] == lkod
      Return '(' + lstr( row[ 1 ] ) + ') ' + row[ 2 ]
    Endif
  Next

  Return 'Неизвестная категория проверки с идентификатором: ' + Str( lkod )

// 05.08.21 вернуть массив описателя ошибки для кода дефекта с описанием ошибки ТФОМС из справочника T005.dbf
Function retarr_t005( lkod, isEmpty )

  Local arrErrors := loadt005()
  Local row := {}

  Default isEmpty To .f.
  For Each row in arrErrors
    If row[ 1 ] == lkod
      Return row
    Endif
  Next

  Return iif( isEmpty, {}, { 'Неизвестная категория проверки с идентификатором: ' + Str( lkod ), '', '' } )

// =========== T007 ===================
//
// 02.06.23 вернуть массив ТФОМС T007.dbf
Function loadt007()

  // возвращает массив T007
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // T007 - Перечень
  // PROFIL_K,  N,  2
  // PK_V020,   N,  2
  // PROFIL,    N,  2
  // NAME,      C,  255
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'profil_k, ' + ;
      'pk_v020, ' + ;
      'profil, ' + ;
      'name ' + ;
      'FROM t007' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), Val( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ) } )
      Next
    Endif
    db := nil
  Endif

  Return _arr

// 04.06.23 массив T007 для выбора
Function arr_t007()

  Static arr
  Static time_load
  Local arrT007 := loadt007()
  Local row

  If timeout_load( @time_load )
    arr := {}
    For Each row in arrT007
      If AScan( arr, {| x| x[ 2 ] == row[ 1 ] } ) == 0
        AAdd( arr, { AllTrim( row[ 4 ] ), row[ 1 ], row[ 2 ] } )
      Endif
    Next
  Endif

  Return arr

// 02.06.23 вернуть массив профилей мед. помощи
Function ret_arr_v002_profil_k_t007( lprofil_k )

  Local arrT007 := loadt007()
  Local arr := {}, row := {}

  For Each row in arrT007
    If row[ 1 ] == lprofil_k
      AAdd( arr, { inieditspr( A__MENUVERT, getv002(), row[ 3 ] ), row[ 3 ] } )
    Endif
  Next

  Return arr

// =========== T008 ===================
//
// 23.10.22 вернуть Коды ошибок в протоколах обработки инф.пакетов T008.xml
Function gett008()

  // T008.xml - Коды ошибок в протоколах обработки инф.пакетов
  // 1 - NAME (C), 2 - CODE (N), 3 - NAME_F (C), 4 - DATE_B (D), 5 - DATE_E (D)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { 'Файл уже был загружен', 0, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Файл не соответствует xsd-схеме', 1, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректное сочетание кодов МО (codeM и Mcod)', 2, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректный код профиля', 3, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректный код профиля койки', 4, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректный код диагноза', 5, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректная форма оказания МП (V014)', 6, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректный тип документа (F008)', 7, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректный пол (V005)', 8, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректный реестровый код МО юридического лица', 9, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректный регистрационный код МО по ТФОМС', 10, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Данного направления нет в выписанных', 11, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректный код причины аннулирования', 12, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректный реестровый код СМО', 13, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Профиль койки не соответствует профилю МП', 14, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Некорректная дата госпитализации', 15, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Запись по данному направлению уже была загружена', 16, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Отсутствуют сведения о выполненных объемах для СМО', 17, '', SToD( '20160915' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Отчетная дата отлична от текущей', 18, '', SToD( '20170220' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Нарушена уникальность ID_D', 19, '', SToD( '20180829' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Дата в имени файла не соответствует DATE_R', 20, '', SToD( '20180907' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Дата в записи не соответствует DATE_R', 21, '', SToD( '20180907' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Превышен срок действия направления (30 дней)', 22, '', SToD( '20180907' ), SToD( '22220101' ) } )
    AAdd( _arr, { 'Ошибка в других записях файла', 999, '', SToD( '20140701' ), SToD( '22220101' ) } )
  Endif

  Return _arr

// =========== T012 ===================
//
// 26.12.22 вернуть описание ошибки из Классификатора ошибок ИСОМП ISDErr.xml
Function geterror_t012( code )

  Static arr
  Local db
  Local aTable
  Local nI
  Local s := 'ошибка ' + lstr( code ) + ': '

  If arr == nil
    arr := hb_Hash()

    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT code, name FROM isderr' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        hb_HSet( arr, Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ) )
      Next
    Endif
    db := nil
  Endif

  If hb_HHasKey( arr, code )
    s += AllTrim( arr[ code ] )
  Else
    s += '(неизвестная ошибка)'
  Endif

  Return s