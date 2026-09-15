#include 'hbhash.ch'
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// =========== V002 ===================
//
#define V002_IDPR     1
#define V002_PRNAME   2
#define V002_DATEBEG  3
#define V002_DATEEND  4
#define V002_IS_IDENT 5
#define V002_PARENT_ID 6

// 17.04.26 вернуть массив по справочнику регионов ТФОМС V002.xml
Function getv002( work_date )

  // V002.dbf - Классификатор профилей оказанной медицинской помощи
  // 1 - PRNAME(C)  2 - IDPR(N) 3 - IS_IDENT(C) 4 - PARENT_ID(N) 5 - DATEBEG(D)  6 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI
  Local ret_array

  if ValType( work_date ) == 'C'
    work_date := CToD( work_date )
  endif
  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idpr, ' + ;
      'prname, ' + ;
      'datebeg, ' + ;
      'dateend, ' + ;
      'is_ident, ' + ;
      'parent_id ' + ;
      'FROM v002' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, V002_PRNAME ] ), Val( aTable[ nI, V002_IDPR ] ), CToD( aTable[ nI, V002_DATEBEG ] ), CToD( aTable[ nI, V002_DATEEND ] ), AllTrim( aTable[ nI, V002_IS_IDENT ] ), Val( aTable[ nI, V002_PARENT_ID ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif
  Return ret_array

// =========== V004 ===================
//
// 20.12.24 вернуть массив по справочнику регионов ТФОМС V004.xml
Function getv004()

  // V004.xml - Классификатор медицинских специальностей
  // MSPNAME(C), IDMSP(N), DATEBEG(D), DATEEND(D)
  Static _arr := {}
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'mspname, ' + ;
      'idmsp, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v004' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), Val( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  return _arr

// =========== V005 ===================
//
// 22.10.22 вернуть Классификатор пола застрахованного V005.xml
Function getv005()

  // V005.xml - Классификатор пола застрахованного
  // 1 - POLNAME(C)  2 - IDPOL(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )

  If Len( _arr ) == 0
    AAdd( _arr, { 'Мужской', 1, empty_date, empty_date } )
    AAdd( _arr, { 'Женский', 2, empty_date, empty_date } )
  Endif
  Return _arr

// =========== V006 ===================
//
// 18.05.22 вернуть условиt оказания медицинской помощи по коду
Function getuslovie_v006( kod )

  Local ret := NIL
  Local i

  If ( i := AScan( getv006(), {| x| x[ 2 ] == kod } ) ) > 0
    ret := getv006()[ i, 1 ]
  Endif
  Return ret

// 28.02.21 вернуть Классификатор условий оказания медицинской помощи V006.xml
Function getv006()

  // V006.xml - Классификатор условий оказания медицинской помощи
  // 1 - UMPNAME(C)  2 - IDUMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )
  Local date_20110101 := SToD( '20110101' )

  If Len( _arr ) == 0
    AAdd( _arr, { 'Стационар', 1, date_20110101, empty_date } )
    AAdd( _arr, { 'Дневной стационар', 2, date_20110101, empty_date } )
    AAdd( _arr, { 'Поликлиника', 3, date_20110101, empty_date } )
    AAdd( _arr, { 'Скорая помощь', 4, SToD( '20130101' ), empty_date } )
  Endif
  Return _arr

// =========== V008 ===================
//
// 22.10.22 вернуть Классификатор видов медицинской помощи V008.xml
Function getv008()

  // V008.xml - Классификатор видов медицинской помощи
  // 1 - VMPNAME(C)  2 - IDVMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )
  Local date_20110101 := SToD( '20110101' )

  Local db
  Local aTable
  Local nI

  If Len( _arr ) == 0
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idvmp, ' + ;
      'vmpname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v008' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil

  Endif
  Return _arr

// =========== V009 ===================
//
#define V009_IDRMP    1
#define V009_RMPNAME  2
#define V009_DL_USLOV 3
#define V009_DATEBEG  4
#define V009_DATEEND  5

// 23.01.23 вернуть массив по справочнику ТФОМС V009.xml
Function getv009( work_date )

  // V009.xml - Классификатор результатов обращения за медицинской помощью
  Static _arr
  Local stroke := '', vid := ''
  Static time_load
  Local db
  Local aTable, row
  Local nI
  Local ret_array

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idrmp, ' + ;
      'rmpname, ' + ;
      'dl_uslov, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v009' )  // WHERE dateend == "    -  -  "')
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        If Val( aTable[ nI, V009_DL_USLOV ] ) == 1
          vid := '/ст-р/'
        Elseif Val( aTable[ nI, V009_DL_USLOV ] ) == 2
          vid := '/дн.с/'
        Elseif Val( aTable[ nI, V009_DL_USLOV ] ) == 3
          vid := '/п-ка/'
        Else
          vid := '/'
        Endif
        stroke := Str( Val( aTable[ nI, V009_IDRMP ] ), 3 ) + vid + AllTrim( aTable[ nI, V009_RMPNAME ] )
        AAdd( _arr, { stroke, Val( aTable[ nI, V009_IDRMP ] ), CToD( aTable[ nI, V009_DATEBEG ] ), CToD( aTable[ nI, V009_DATEEND ] ), Val( aTable[ nI, V009_DL_USLOV ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif
  Return ret_array

// 04.11.22 вернуть результат обращения за медицинской помощью по коду
Function getrslt_v009( result )

  Local ret := NIL
  Local i

  If ( i := AScan( getv009(), {| x| x[ 2 ] == result } ) ) > 0
    ret := getv009()[ i, 1 ]
  Endif
  Return ret

// 23.01.23 вернуть результат обращения по условию оказания и дате
Function getrslt_usl_date( uslovie, date )

  Local ret := {}
  Local row

  For Each row in getv009( date )
    If uslovie == row[ 5 ]
      AAdd( ret, row )
    Endif
  Next
  Return ret

// =========== V010 ===================
//
#define V010_IDSP     1
#define V010_SPNAME   2
#define V010_DATEBEG  3
#define V010_DATEEND  4

// 26.01.23 вернуть массив по справочнику ФФОМС V010.xml
Function getv010( work_date )

  // V010.xml - Классификатор способов оплаты медицинской помощи
  Static _arr
  Static time_load
  Local stroke := ''
  Local db
  Local aTable
  Local nI
  Local ret_array, row

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idsp, ' + ;
      'spname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v010' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        stroke := StrZero( Val( aTable[ nI, V010_IDSP ] ), 2, 0 ) + '/' + AllTrim( aTable[ nI, V010_SPNAME ] )
        AAdd( _arr, { stroke, Val( aTable[ nI, V010_IDSP ] ), AllTrim( aTable[ nI, V010_SPNAME ] ), CToD( aTable[ nI, V010_DATEBEG ] ), CToD( aTable[ nI, V010_DATEEND ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif
  Return ret_array

// =========== V012 ===================
//
#define V012_IDIZ     1
#define V012_IZNAME   2
#define V012_DL_USLOV 3
#define V012_DATEBEG  4
#define V012_DATEEND  5

// 23.01.23 вернуть массив по справочнику ФФОМС V012.xml
Function getv012( work_date )

  // V012.xml - Классификатор исходов заболевания
  Static _arr
  Static time_load
  Local stroke := '', vid := ''
  Local db
  Local aTable, row
  Local nI
  Local ret_array

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idiz, ' + ;
      'izname, ' + ;
      'dl_uslov, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v012' )   // WHERE dateend == "    -  -  "')
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        // if empty(ctod(aTable[nI, 5]))  // только если поле окончания действия пусто
        If Val( aTable[ nI, V012_DL_USLOV ] ) == 1
          vid := '/ст-р/'
        Elseif Val( aTable[ nI, V012_DL_USLOV ] ) == 2
          vid := '/дн.с/'
        Elseif Val( aTable[ nI, V012_DL_USLOV ] ) == 3
          vid := '/п-ка/'
        Else
          vid := '/'
        Endif
        stroke := Str( Val( aTable[ nI, V012_IDIZ ] ), 3 ) + vid + AllTrim( aTable[ nI, V012_IZNAME ] )
        AAdd( _arr, { stroke, Val( aTable[ nI, V012_IDIZ ] ), CToD( aTable[ nI, V012_DATEBEG ] ), CToD( aTable[ nI, V012_DATEEND ] ), Val( aTable[ nI, V012_DL_USLOV ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif
  Return ret_array

// 06.11.22 вернуть исход заболевания по коду
Function getishod_v012( ishod )

  Local ret := NIL
  Local i

  If ( i := AScan( getv012(), {| x| x[ 2 ] == ishod } ) ) > 0
    ret := getv012()[ i, 1 ]
  Endif
  Return ret

// 23.01.23 вернуть исход заболевания по условию оказания и дате
Function getishod_usl_date( uslovie, date )

  Local ret := {}
  Local row

  For Each row in getv012( date )
    If uslovie == row[ 5 ]
      AAdd( ret, row )
    Endif
  Next
  Return ret

// =========== V014 ===================
//
// 21.10.22 вернуть Классификатор форм медицинской помощи V014.xml
Function getv014()

  // V014.xml - Классификатор форм медицинской помощи
  // 1 - FRMMPNAME(C)  2 - IDFRMMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )

  If Len( _arr ) == 0
    AAdd( _arr, { 'Экстренная', 1, SToD( '20130101' ), empty_date } )
    AAdd( _arr, { 'Неотложная', 2, SToD( '20130101' ), empty_date } )
    AAdd( _arr, { 'Плановая', 3, SToD( '20130101' ), empty_date } )
  Endif
  Return _arr

// =========== V015 ===================
//
// 26.01.23 вернуть массив по справочнику V015.xml
// возвращает массив V015
Function getv015()

  // V015.xml - Классификатор медицинских специальностей
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
      'recid, ' + ;
      'code, ' + ;
      'name, ' + ;
      'high, ' + ;
      'okso, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v015' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 3 ] ), Val( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 4 ] ), AllTrim( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ), CToD( aTable[ nI, 7 ] ), Val( aTable[ nI, 1 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil

    ASort( _arr, , , {| x, y| x[ 2 ] < y[ 2 ] } )
  Endif
  Return _arr

// =========== V016 ===================
//
// 26.01.23 вернуть Классификатор видов диспансеризации/профосмотров V016.xml
Function getv016()

  // V016.xml - Классификатор видов диспансеризации/профосмотров
  Static _arr
  Static time_load
  Local ar := {}
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT iddt, dtname, rule, datebeg, dateend FROM v016' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        ar := list2arr( aTable[ nI, 3 ] )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), ar, CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  Return _arr

// 13.12.21 вернуть описатель типа диспнсеризации по коду
Function get_type_dispt( mdate, codeDispT )

  Local dispT := Upper( AllTrim( codeDispT ) )
  Local _arr := {}, i
  Local tmpArr := getv016()
  Local lengthArr := Len( tmpArr )

  For i := 1 To lengthArr
    If dispT == tmpArr[ i, 1 ] .and. between_date( tmpArr[ i, 4 ], tmpArr[ i, 5 ], mdate )
      AAdd( _arr, tmpArr[ i, 1 ] )
      AAdd( _arr, tmpArr[ i, 2 ] )
      AAdd( _arr, tmpArr[ i, 3 ] )
    Endif
  Next
  Return _arr

// =========== V017 ===================
//
// 26.01.23 вернуть Классификатор результатов диспансеризации (DispR) V017.xml
Function getv017()

  // V017.xml - Классификатор результатов диспансеризации (DispR)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT iddr, drname, datebeg, dateend FROM v017' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  Return _arr

// 13.12.21 вернуть список результатов диспансеризации на дату в соответствии со списком кодов
Function get_list_dispr( mdate, arrDR )

  Local _arr := {}, code, i
  Local tmpArr := getv017()
  Local lenArr := Len( tmpArr )

  For Each code in arrDR
    For i := 1 To lenArr
      If code == tmpArr[ i, 1 ] .and. between_date( tmpArr[ i, 3 ], tmpArr[ i, 4 ], mdate )
        AAdd( _arr, tmpArr[ i, 2 ] )
      Endif
    Next
  Next
  Return _arr

// =========== V018 ===================
//
// 25.01.23 возвращает массив V018 на указанную дату
Function getv018( dateSl )

  Local yearSl := Year( dateSl )
  Local _arr
  Local db
  Local aTable
  Local nI

  Static hV018, lHashV018 := .f.

  // при отсутствии ХЭШ-массива создадим его
  If !lHashV018
    hV018 := hb_Hash()
    lHashV018 := .t.
  Endif

  // получим массив V018 из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  If hb_HHasKey( hV018, yearSl )
    _arr := hb_HGet( hV018, yearSl )
  Else
    _arr := {}

    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idhvid, ' + ;
      'hvidname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v018' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        If ( Year( CToD( aTable[ nI, 3 ] ) ) <= yearSl ) .and. ( Empty( CToD( aTable[ nI, 4 ] ) ) .or. Year( CToD( aTable[ nI, 4 ] ) ) >= yearSl )   // только если поле окончания действия пусто
          AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
        Endif
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
    ASort( _arr,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    // поместим в ХЭШ-массив
    hV018[ yearSl ] := _arr
  Endif
  If Empty( _arr )
    alertx( 'На дату ' + DToC( dateSl ) + ' V018 отсутствуют!' )
  Endif
  Return _arr

// =========== V019 ===================
//
// 25.01.23 возвращает массив V019
Function getv019( dateSl )

  Local yearSl := Year( dateSl )
  Local _arr
  Local db
  Local aTable
  Local nI

  Static hV019, lHashV019 := .f.

  // при отсутствии ХЭШ-массива создадим его
  If !lHashV019
    hV019 := hb_Hash()
    lHashV019 := .t.
  Endif

  // получим массив V019 из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  If hb_HHasKey( hV019, yearSl )
    _arr := hb_HGet( hV019, yearSl )
  Else
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idhm, ' + ;
      'hmname, ' + ;
      'diag, ' + ;
      'hvid, ' + ;
      'hgr, ' + ;
      'hmodp, ' + ;
      'idmodp, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v019' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        If ( Year( CToD( aTable[ nI, 8 ] ) ) <= yearSl ) .and. ( Empty( CToD( aTable[ nI, 9 ] ) ) .or. Year( CToD( aTable[ nI, 9 ] ) ) >= yearSl )   // только если поле окончания действия пусто
          AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), ;
            AClone( split( AllTrim( aTable[ nI, 3 ] ), ', ' ) ), ;
            AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 8 ] ), CToD( aTable[ nI, 9 ] ), ;
            Val( aTable[ nI, 5 ] ), Val( aTable[ nI, 7 ] ) ;
            } )
        Endif
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
    ASort( _arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
    hV019[ yearSl ] := _arr
  Endif
  Return _arr

// =========== V020 ===================
//
// 26.01.26 вернуть массив по справочнику ФФОМС V020.xml - Классификатор профилей койки
Function getv020()

  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idk_pr, ' + ;
      'k_prname, ' + ;
      'datebeg, ' + ;
      'dateend, ' + ;
      'id_pr, ' + ;
      'prname ' + ;
      'FROM v020' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ), ;
          CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), Val( aTable[ nI, 5 ] ), ;
          AllTrim( aTable[ nI, 6 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  Return _arr

// =========== V021 ===================
//
// 15.09.26 вернуть массив по справочнику ФФОМС V021.xml
Function getv021() 

  // V021.xml - Классификатор медицинских специальностей (должностей) (MedSpec)
  // 1 - SPECNAME(C)  2 - IDSPEC(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - POSTNAME(C)  6 - IDPOST_MZ(C)

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
      'idspec, ' + ;
      'idspec || "." || trim(specname), ' + ;
      'postname, ' + ;
      'idpost_mz, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v021 WHERE dateend == "    -  -  "' + ;
      'group by idspec' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ), AllTrim( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  Return _arr

// 27.02.23 вернуть массив описывающий специальность
Function doljbyspec_v021( idspec )

  Local i, retArray := ''
  Local aV021 := getv021()

  If !Empty( idspec ) .and. ( ( i := AScan( aV021, {| x| x[ 2 ] == idspec } ) ) > 0 )
    retArray := aV021[ i, 5 ]
  Endif
  Return retArray

// 25.06.24
Function ret_str_spec( kod )

  Local i, s := '', aV021 := getv021()

  If ! Empty( kod ) .and. ( ( i := AScan( aV021, {| x | x[ 2 ] == kod } ) ) > 0 )
    s := aV021[ i, 1 ]
  Endif
  Return s

// =========== V022 ===================
//
// 26.01.23 возвращает массив V022
Function getv022()

  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idmpac, ' + ;
      'mpacname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v022' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), ;
          CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) ;
          } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
    ASort( _arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
  Endif
  Return _arr

// 11.02.21 вернуть строку модели пациента ВМП
Function ret_v022( idmpac, lk_data )

  Local i, s := Space( 10 )
  Local aV022 := getv022()
  Local dk := lk_data

  If !Empty( idmpac ) .and. ( ( i := AScan( aV022, {| x| x[ 1 ] == idmpac } ) ) > 0 )
    s := aV022[ i, 2 ]
  Endif

  Return s

// =========== V025 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V025 Классификатор целей посещения (KPC)
Function getv025()

  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idpc, ' + ;
      'n_pc, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v025' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ) + '-' + AllTrim( aTable[ nI, 2 ] ), nI -1, AllTrim( aTable[ nI, 1 ] ), ;
          CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) ;
          } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  Return _arr

Function get_idpc_from_v025_by_number( num )

  Local tableV025 := getv025()
  Local row
  Local retIDPC := ''

  For Each row in tableV025
    If row[ 2 ] == num
      retIDPC := row[ 3 ]
      Exit
    Endif
  Next
  Return retIDPC

// 16.07.26
Function get_npc_from_v025_by_idpc( idpc )

  Local tableV025 := getv025()
  Local row
  Local retIDPC := ''

  idpc := AllTrim( idpc )

  For Each row in tableV025
    If AllTrim( row[ 3 ] ) == idpc
      retIDPC := row[ 1 ]
      Exit
    Endif
  Next
  Return retIDPC

// =========== V029 ===================
//
// 10.04.26 вернуть массив по справочнику ФФОМС V029.xml
Function getv029()

  // V029.xml - Классификатор методов диагностического исследования (MET_ISSL)
  // 1 - IDMET(N) 2 - N_MET(C)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr
  Local db
  Local aTable
  Local nI
  local tmpStr

  If HB_ISNIL( _arr )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idmet, ' + ;
      'n_met, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v029' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        tmpStr := StrTran( AllTrim( aTable[ nI, 2 ] ), 'Дорогостоящие методы лучевой диагностики (', '' )
        tmpStr := StrTran( tmpStr, ')', '' )
        tmpStr := StrTran( tmpStr, ', за исключением дорогостоящих', '' )
        AAdd( _arr, { tmpStr, Val( aTable[ nI, 1 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// =========== V030 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V030.xml
Function getv030()

  // V030.xml - Схемы лечения заболевания COVID-19 (TreatReg)
  // 1 - SCHEMCOD(C) 2 - SCHEME(C) 3 - DEGREE(N) 4 - COMMENT(M)  5 - DATEBEG(D)  6 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'schemcode, ' + ;
      'scheme, ' + ;
      'degree, ' + ;
      'comment, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v030' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 1 ] ), ;
          Val( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ), ;
          CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) ;
          } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  Return _arr

// 11.01.22 вернуть схемы лечения согласно тяжести пациента
Function get_schemas_lech( _degree, ldate )

  Local _arr := {}, row

  If ValType( _degree ) == 'C' .and. Empty( _degree )
    Return _arr
  Endif
  If ValType( _degree ) == 'N' .and. _degree == 0
    Return _arr
  Endif

  For Each row in getv030()
    If ( row[ 3 ] == _degree ) .and. between_date( row[ 5 ], row[ 6 ], ldate )
      AAdd( _arr, { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ], row[ 6 ] } )
    Endif
  Next
  Return _arr

// 07.01.22 вернуть наименование схемы
Function ret_schema_v030( s_code )

  // s_code - код схемы
  Local i, ret := ''
  Local code := AllTrim( s_code )

  If !Empty( code ) .and. ( ( i := AScan( getv030(), {| x| x[ 2 ] == code } ) ) > 0 )
    ret := getv030()[ i, 1 ]
  Endif
  Return ret

// =========== V031 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V031.xml
Function getv031()

  // V031.xml - Группы препаратов для лечения заболевания COVID-19 (GroupDrugs)
  // 1 - DRUGCODE(N) 2 - DRUGGRUP(C) 3 - INDMNN(N)  4 - DATEBEG(D)  5 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT drugcode, druggrup, indmnn, datebeg, dateend FROM v031' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  Return _arr

// 29.08.22 вернуть группу препаратов
Function get_group_prep_by_kod( _code, ldate )

  Local _arr, row, code

  If ValType( _code ) == 'C'
    code := Val( SubStr( _code, Len( _code ) ) )
  Elseif ValType( _code ) == 'N'
    code := _code
  Else
    Return _arr
  Endif

  For Each row in getv031()
    If ( row[ 1 ] == code ) .and. between_date( row[ 4 ], row[ 5 ], ldate )
      _arr := { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ] }
    Endif
  Next
  Return _arr

// =========== V032 ===================
//
// 26.01.22 вернуть массив по справочнику ФФОМС V032.xml
Function getv032()

  // V032.xml - Сочетание схемы лечения и группы препаратов (CombTreat)
  // 1 - SCHEDRUG(C) 2 - NAME(C) 3 - SCHEMCOD(C)  4 - DATEBEG(D)  5 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT schedrug, name, schemcode, datebeg, dateend FROM v032' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  Return _arr

// 04.01.22 вернуть сочетание схемы и группы препаратов
Function get_group_by_schema_lech( _scheme, ldate )

  Local _arr := {}, row

  For Each row in getv032()
    If ( row[ 3 ] == AllTrim( _scheme ) ) .and. between_date( row[ 4 ], row[ 5 ], ldate )
      AAdd( _arr, { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ] } )
    Endif
  Next
  Return _arr

// 08.01.22 вернуть наименование кода схемы
Function ret_schema_v032( s_code )

  // s_code - код схемы
  Local i, ret := ''
  Local code := AllTrim( s_code )

  If !Empty( code ) .and. ( ( i := AScan( getv032(), {| x| x[ 2 ] == code } ) ) > 0 )
    ret := getv032()[ i, 1 ]
  Endif
  Return ret

// =========== V033 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V033.xml
Function getv033()

  // V033.xml - Соответствие кода препарата схеме лечения (DgTreatReg)
  // 1 - SCHEDRUG(C) 2 - DRUGCODE(C)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT schedrug, drugcode, datebeg, dateend FROM v033' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  Return _arr

// =========== V036 ===================
//
// 26.01.23 вернуть массив по справочнику ФФОМС V036.xml
Function getv036()

  // V036.xml - Перечень услуг, требующих имплантацию медицинских изделий (ServImplDv)
  // 1 - S_CODE(C) 2 - NAME(C) 3 - PARAM(N) 4 - COMMENT(C) 5 - DATEBEG(D) 6 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT s_code, name, param, comment, datebeg, dateend FROM v036' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  Return _arr

// =========== V024 ===================
//
// 24.12.24 вернуть массив по справочнику ФФОМС V024.xml
Function getv024( dk )

  // V024.xml - Классификатор классификационных критериев (DopKr)
  // 1 - IDDKK(C) 2 - DKKNAME(C) 3 - DATEBEG(D) 4 - DATEEND(D)
  Local arr
  Local db
  Local aTable
  Local nI
  Local dBeg, dEnd

  arr := {}
  db := opensql_db()
  aTable := sqlite3_get_table( db, "SELECT " + ;
    "iddkk, " + ;
    "dkkname, " + ;
    "datebeg, " + ;
    "dateend " + ;
    "FROM v024 " )

  If Len( aTable ) > 1
    For nI := 2 To Len( aTable )
      Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
      dBeg := CToD( aTable[ nI, 3 ] )
      dEnd := CToD( aTable[ nI, 4 ] )
      Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
      if ValType( dk ) == 'D'
        if dBeg <= dk .and. ( dk <= dEnd .or. Empty( dEnd ) )
          AAdd( arr, { aTable[ nI, 1 ], aTable[ nI, 2 ], dBeg, dEnd } )
        endif
      else
        if Year( dBeg ) <= dk .and. ( dk <= Year( dEnd ) .or. Empty( dEnd ) )
          AAdd( arr, { aTable[ nI, 1 ], aTable[ nI, 2 ], dBeg, dEnd } )
        endif
      endif
    Next
  Endif
  db := nil
  Return arr

// =========== V039 ===================
//
// 16.01.26 вернуть массив по справочнику ФФОМС V039.xml
Function getv039( dk )

  // V039.xml - Классификатор видов занятости (KVZ)
  // 1 - ID_VZ(N) 2 - N_VZ(C) 3 - DATEBEG(D) 4 - DATEEND(D)
  Local arr
  Local db
  Local aTable
  Local nI
  Local loc_date := dk

  arr := {}

  db := opensql_db()
  aTable := sqlite3_get_table( db, "SELECT " + ;
    "id_vz, " + ;
    "n_vz, " + ;
    "datebeg, " + ;
    "dateend " + ;
    "FROM v039" )

  If Len( aTable ) > 1
    For nI := 2 To Len( aTable )
/*
      Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
      dBeg := CToD( aTable[ nI, 3 ] )
      dEnd := CToD( aTable[ nI, 4 ] )
      Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
*/
      AAdd( arr, { aTable[ nI, 2 ], Val( aTable[ nI, 1 ] ) } )
    Next
  Endif
  db := nil
  Return arr

// =========== V040 ===================
//
// 18.01.26 вернуть массив по справочнику ФФОМС V040.xml
Function getv040( dk )

  // V040.xml - Классификатор мест обращений (посещений) (KMOP)
  // 1 - ID_MOP(N) 2 - N_MOP(C) 3 - DATEBEG(D) 4 - DATEEND(D)
  Local arr
  Local db
  Local aTable
  Local nI
  Local dBeg, dEnd
  Local loc_date := dk

  arr := {}

  db := opensql_db()
  aTable := sqlite3_get_table( db, "SELECT " + ;
    "id_mop, " + ;
    "n_mop, " + ;
    "datebeg, " + ;
    "dateend " + ;
    "FROM v040" )

  If Len( aTable ) > 1
    For nI := 2 To Len( aTable )
      Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
      dBeg := CToD( aTable[ nI, 3 ] )
      dEnd := CToD( aTable[ nI, 4 ] )
      Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
      AAdd( arr, { aTable[ nI, 2 ], Val( aTable[ nI, 1 ] ), dBeg, dEnd } )
    Next
  Endif
  db := nil
  Return arr

// =========== V041 ===================
//
// 26.01.26 вернуть массив по справочнику ФФОМС V041.xml
Function getv041()

  // V041.xml - Классификатор коэффициентов сложности лечения пациента (KSLP)
  // 1 - ID_SL(C) 2 - N_SL(C) 3 - PG_SL(C) 4 - K_SL(N) 5 - DATEBEG(D) 6 - DATEEND(D)
  static arr
  Local db
  Local aTable
  Local nI
  Local dBeg, dEnd

  if HB_ISNIL( arr )
    arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_sl, ' + ;
      'n_sl, ' + ;
      'pg_sl, ' + ;
      'k_sl, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v041' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
        dBeg := CToD( aTable[ nI, 5 ] )
        dEnd := CToD( aTable[ nI, 6 ] )
        Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
        AAdd( arr, { AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 3 ] ), Val( aTable[ nI, 4 ] ), dBeg, dEnd } )
      Next
    Endif
  endif
  db := nil
  Return arr

// 26.01.26 вернуть массив по справочнику ФФОМС V041.xml
Function getv041_on_date( dk )

  // V041.xml - Классификатор коэффициентов сложности лечения пациента (KSLP)
  // 1 - ID_SL(C) 2 - N_SL(C) 3 - PG_SL(C) 4 - K_SL(N) 5 - DATEBEG(D) 6 - DATEEND(D)
  local arr
  Local row

  arr := {}
  for each row in getv041()
    if between_date_new( row[ 5 ], row[ 6 ], dk )
      AAdd( arr, row )
    endif
  next
  Return arr

// =========== V042 ===================
//
// 26.01.26 вернуть массив по справочнику ФФОМС V042.xml
Function getv042()

  // V042.xml - ККлассификатор причин оплаты за прерванный случай лечения (KPPSL)
  // 1 - ID_PR(C) 2 - N_PR(C) 3 - DATEBEG(D) 4 - DATEEND(D)
  static arr
  Local db
  Local aTable
  Local nI
  Local dBeg, dEnd

  if HB_ISNIL( arr )
    arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_pr, ' + ;
      'n_pr, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v042' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
        dBeg := CToD( aTable[ nI, 3 ] )
        dEnd := CToD( aTable[ nI, 4 ] )
        Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
        AAdd( arr, { AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 1 ] ), dBeg, dEnd } )
      Next
    Endif
  endif
  db := nil
  Return arr

// 26.01.26 вернуть массив по справочнику ФФОМС V042.xml
Function getv042_on_date( dk )

  // V042.xml - ККлассификатор причин оплаты за прерванный случай лечения (KPPSL)
  // 1 - ID_PR(C) 2 - N_PR(C) 3 - DATEBEG(D) 4 - DATEEND(D)
  local arr
  Local row

  arr := {}
  for each row in getv042()
    if between_date_new( row[ 3 ], row[ 4 ], dk )
      AAdd( arr, row )
    endif
  next
  Return arr
