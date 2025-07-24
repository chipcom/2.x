#include 'hbhash.ch'
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// =========== N001 ===================
//
// 05.09.23 вернуть массив ФФОМС N001.xml
Function getn001()

  // возвращает массив N001 противопоказаний и отказов (OnkPrOt)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N001 - Перечень противопоказаний и отказов (OnkPrOt)
  // ID_PROT,  N,  2
  // PROT_NAME,   C,  250
  // DATEBEG,    C,  10
  // DATEEND,      C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_prot, ' + ;
      'prot_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n001' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ) } ) // , val(aTable[nI, 3]), alltrim(aTable[nI, 4])})
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N006 ===================
//
// 27.08.23 вернуть массив ФФОМС N006.xml Справочник соответствия стадий TNM (OnkTNM)
Function loadn006()

  // возвращает массив N006 соответствия стадий TNM (OnkTNM)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N006 - Перечень соответствия стадий TNM (OnkTNM)
  // ID_gr,      'N',  4 // Идентификатор строки
  // DS_gr,      'C',  5 // Диагноз по МКБ
  // ID_St,      'N',  4 // Идентификатор стадии
  // ID_T,       'N',  4 // Идентификатор T
  // ID_N,       'N',  4 // Идентификатор N
  // ID_M,       'N',  4 // Идентификатор M
  // DATEBEG,    'C',  10 // Дата начала действия записи
  // DATEEND,    'C',  10 // Дата окончания действия записи
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_gr, ' + ;
      'ds_gr, ' + ;
      'id_st, ' + ;
      'id_t, ' + ;
      'id_n, ' + ;
      'id_m, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n006' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), Val( aTable[ nI, 4 ] ), Val( aTable[ nI, 5 ] ), Val( aTable[ nI, 6 ] ), CToD( aTable[ nI, 7 ] ), CToD( aTable[ nI, 8 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N007 ===================
//
// 27.08.23 вернуть массив ФФОМС N007.xml Классификатор гистологических признаков (OnkMrf)
Function getn007()

  // возвращает массив N007 гистологических признаков (OnkMrf)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N007 - Перечень гистологических признаков (OnkMrf)
  // ID_Mrf,    'N',  2 // Идентификатор гистологического признака
  // Mrf_NAME,  'C',250 // Наименование гистологического признака
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_mrf, ' + ;
      'mrf_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n007' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N008 ===================
//
// 12.09.23 вернуть массив ФФОМС N008.xml Классификатор результатов гистологических исследований (OnkMrfRt)
Function loadn008()

  // возвращает массив N008 результатов гистологических исследований (OnkMrfRt)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N008 - Перечень результатов гистологических исследований (OnkMrfRt)
  // ID_R_M,    'N',  3 // Идентификатор записи
  // ID_Mrf,    'N',  2 // Идентификатор гистологического признака в соответствии с N007
  // R_M_NAME,  'C',250 // Наименование результата гистологического исследования
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_r_m, ' + ;
      'id_mrf, ' + ;
      'r_m_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n008' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), Val( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// 12.09.23
Function getn008()

  Local arr := {}
  Local row

  For Each row in loadn008()
    AAdd( arr, { row[ 3 ], row[ 2 ] } )
  Next
  Return arr

// =========== N009 ===================
//
// 27.08.23 вернуть массив ФФОМС N009.xml Классификатор соответствия гистологических признаков диагнозам (OnkMrtDS)
Function getn009()

  // возвращает массив N009 соответствия гистологических признаков диагнозам (OnkMrtDS)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N009 - Перечень соответствия гистологических признаков диагнозам (OnkMrtDS)
  // ID_M_D,     N,  2 // Идентификатор строки
  // DS_Mrf,     C,  3 // Диагноз по МКБ
  // ID_Mrf,     N,  2 // Идентификатор гистологического признака в соответствии с N007
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_m_d, ' + ;
      'ds_mrf, ' + ;
      'id_mrf, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n009' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N010 ===================
//
// 28.08.23 вернуть массив ФФОМС N010.xml Классификатор маркёров (OnkIgh)
Function loadn010()

  // возвращает массив N010 Классификатор маркёров (OnkIgh)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N010 - Перечень маркёров (OnkIgh)
  // ID_Igh,     N,   2 // Идентификатор маркера
  // KOD_Igh,    C, 250 // Обозначение маркера
  // Igh_NAME,   C, 250 // Наименование маркера
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_igh, ' + ;
      'kod_igh, ' + ;
      'igh_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n010' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N011 ===================
//
// 28.08.23 вернуть массив ФФОМС N011.xml Классификатор значений маркёров (OnkIghRt)
Function loadn011()

  // возвращает массив N011 значений маркёров (OnkIghRt)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N011 - Перечень значений маркёров (OnkIghRt)
  // ID_R_I,     N,   3 // Идентификатор записи
  // ID_Igh,     N,   2 // Идентификатор маркера в соответствии с N010
  // KOD_R_I,    C, 250 // Обозначение результата
  // R_I_NAME,   C, 250 // Наименование результата
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_r_i, ' + ;
      'id_igh, ' + ;
      'kod_r_i, ' + ;
      'r_i_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n011' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), Val( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// 13.09.23
Function getn011()

  Local arr := {}
  Local row

  For Each row in loadn011()
    AAdd( arr, { row[ 4 ], row[ 2 ] } )
  Next
  Return arr

// =========== N012 ===================
//
// 28.08.23 вернуть массив ФФОМС N012.xml Классификатор соответствия маркёров диагнозам (OnkIghDS)
Function loadn012()

  // возвращает массив N012 соответствия маркёров диагнозам (OnkIghDS)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N012 - Перечень соответствия маркёров диагнозам (OnkIghDS)
  // ID_I_D,     N,  2 // Идентификатор строки
  // DS_Igh,     C,  3 // Диагноз по МКБ
  // ID_Igh,     N,  2 // Идентификатор маркера в соответствии с N010
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_i_d, ' + ;
      'ds_igh, ' + ;
      'id_igh, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n012' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// 12.09.23
Function getds_n012()

  Static OnkIghDS
  Static time_load
  Local row, it, i := 0

  If timeout_load( @time_load )
    OnkIghDS := {}
    For Each row in loadn012()
      If ! Empty( row[ 5 ] )
        Loop
      Endif
      If ( it := AScan( OnkIghDS, {| x| x[ 1 ] == row[ 2 ] } ) ) > 0
        AAdd( OnkIghDS[ it, 2 ], { row[ 3 ] } )
      Else
        AAdd( OnkIghDS, { row[ 2 ], {} } )
        i++
        AAdd( OnkIghDS[ i, 2 ], { row[ 3 ] } )
      Endif
    Next
  Endif
  Return OnkIghDS

// =========== N013 ===================
//
// 19.09.23 вернуть массив ФФОМС N013.xml Классификатор типов лечения (OnkLech)
Function getn013()

  // возвращает массив N013 типов лечения (OnkLech)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N013 - Перечень типов лечения (OnkLech)
  // ID_TLech,   N,   1 // Идентификатор типа лечения
  // TLech_NAME, C, 250 // Наименование типа лечения
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_tlech, ' + ;
      'tlech_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n013' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N014 ===================
//
// 19.09.23 вернуть массив ФФОМС N014.xml Классификатор типов хирургического лечения (OnkHir)
Function getn014()

  // возвращает массив N014 типов хирургического лечения (OnkHir)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N014 - Перечень типов хирургического лечения (OnkHir)
  // ID_THir,    N,   1 // Идентификатор типа хирургического лечения
  // THir_NAME,  C, 250 // Наименование типа хирургического лечения
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_thir, ' + ;
      'thir_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n014' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N015 ===================
//
// 19.09.23 вернуть массив ФФОМС N015.xml Классификатор линий лекарственной терапии (OnkLek_L)
Function getn015()

  // возвращает массив N015 линий лекарственной терапии (OnkLek_L)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N015 - Перечень линий лекарственной терапии (OnkLek_L)
  // ID_TLek_L,  N,   1 // Идентификатор линии лекарственной терапии
  // TLek_NAME_L,C, 250 // Наименование линии лекарственной терапии
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_tlek_l, ' + ;
      'tlek_name_l, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n015' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N016 ===================
//
// 19.09.23 вернуть массив ФФОМС N016.xml Классификатор циклов лекарственной терапии (OnkLek_V)
Function getn016()

  // возвращает массив N016 циклов лекарственной терапии (OnkLek_V)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N016 - Перечень циклов лекарственной терапии (OnkLek_V)
  // ID_TLek_V,  N,   1 // Идентификатор цикла лекарственной терапии
  // TLek_NAME_V,C, 250 // Наименование цикла лекарственной терапии
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_tlek_v, ' + ;
      'tlek_name_v, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n016' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N017 ===================
//
// 19.09.23 вернуть массив ФФОМС N017.xml Классификатор типов лучевой терапии (OnkLuch)
Function getn017()

  // возвращает массив N017 типов лучевой терапии (OnkLuch)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N017 - Перечень типов лучевой терапии (OnkLuch)
  // ID_TLuch,   N,   1 // Идентификатор типа лучевой терапии
  // TLuch_NAME, C, 250 // Наименование типа лучевой терапии
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_tluch, ' + ;
      'tluch_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n017' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N018 ===================
//
// 19.09.23 вернуть массив ФФОМС N018.xml Классификатор поводов обращения (OnkReas)
Function getn018()

  // возвращает массив N018 поводов обращения (OnkReas)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N018 - Перечень поводов обращения (OnkReas)
  // ID_REAS,    N,   2 // Идентификатор повода обращения
  // REAS_NAME,  C, 300 // Наименование повода обращения
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_reas, ' + ;
      'reas_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n018' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N019 ===================
//
// 19.09.23 вернуть массив ФФОМС N019.xml Классификатор целей консилиума (OnkCons)
Function getn019()

  // возвращает массив N019 целей консилиума (OnkCons)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N019 - Перечень целей консилиума (OnkCons)
  // ID_CONS,    N,   1 // Идентификатор цели консилиума
  // CONS_NAME,  C, 300 // Наименование цели консилиума
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_cons, ' + ;
      'cons_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n019' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// =========== N020 ===================
//
// 28.09.22 вернуть массив по справочнику ФФОМС N020.xml
// Классификатор лекарственных препаратов, применяемых при проведении лекарственной терапии (OnkLekp)
Function loadn020()

  Static _N020
  Static time_load
  Local db
  Local aTable
  Local nI, dBeg, dEnd

  If timeout_load( @time_load )
    _N020 := hb_Hash()
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_lekp, ' + ;
      'mnn, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n020' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
        dBeg := CToD( aTable[ nI, 3 ] )
        dEnd := CToD( aTable[ nI, 4 ] )
        Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
        hb_HSet( _N020, AllTrim( aTable[ nI, 1 ] ), { aTable[ nI, 1 ], AllTrim( aTable[ nI, 2 ] ), dBeg, dEnd } )
      Next
    Endif
    db := nil
  Endif
  Return _N020

// 07.01.22 вернуть МНН лекарственного препарата
Function get_lek_pr_by_id( id_lekp )

  Local arr := loadn020()
  Local ret

  If hb_HHasKey( arr, id_lekp )
    ret := arr[ id_lekp ][ 2 ]
  Endif
  Return ret

// 06.01.25
Function getn020( dk )

  Static stYear
  Static _arr
  Local db
  Local aTable
  Local nI, dBeg, dEnd, year_dk

  If ValType( dk ) == 'N'
    dBeg := "'" + Str( dk, 4 ) + "-01-01 00:00:00'"
    dEnd := "'" + Str( dk, 4 ) + "-12-31 00:00:00'"
    year_dk := dk
  Elseif ValType( dk ) == 'D'
    year_dk := Year( dk )
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    dBeg := "'" + DToS( dk ) + "-01-01 00:00:00'"
    dEnd := "'" + DToS( dk ) + "-12-31 00:00:00'"
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  elseif ISNIL( dk )
  Else
    Return {}
  Endif

  If ISNIL( stYear ) .or. Empty( _arr ) .or. year_dk != stYear
    _arr := {}
    db := opensql_db()
    if isnil( dk )
      // получим все записи таблицы
      aTable := sqlite3_get_table( db, "SELECT " + ;
        'id_lekp, ' + ;
        'mnn, ' + ;
        "datebeg, " + ;
        "dateend " + ;
        "FROM n020 " )
    else
      // получим записи таблицы с ограничениями
      aTable := sqlite3_get_table( db, "SELECT " + ;
        'id_lekp, ' + ;
        'mnn, ' + ;
        "datebeg, " + ;
        "dateend " + ;
        "FROM n020 " + ;
        "WHERE datebeg <= " + dBeg + ;
        "AND dateend >= " + dEnd )
    endif
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
        dBeg := CToD( aTable[ nI, 3 ] )
        dEnd := CToD( aTable[ nI, 4 ] )
        Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )

        AAdd( _arr, { PadR( aTable[ nI, 1 ], 6 ), AllTrim( aTable[ nI, 2 ] ), dBeg, dEnd } )
      Next
    Endif
    stYear := year_dk
    db := nil
  Endif
  Return _arr

// =========== N021 ===================
//
// 18.12.24 вернуть массив ФФОМС N021.xml
// Классификатор соответствия лекарственного препарата схеме лекарственной терапии (OnkLpsh)
Function loadn021()

  // возвращает массив N021 соответствия лекарственного препарата схеме лекарственной терапии (OnkLpsh)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI, dBeg, dEnd

  // N021 - Перечень соответствия лекарственного препарата схеме лекарственной терапии (OnkLpsh)
  // ID_ZAP,     N,   4 // Идентификатор записи (в описании Char 15)
  // CODE_SH,    C,  10 // Код схемы лекарственной терапии
  // ID_LEKP,    C,   6 // Идентификатор лекарственного препарата, применяемого при проведении лекарственной противоопухолевой терапии. Заполняется в соответствии с N020
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  // добавлено 16.12.24
  // LEKP_EXT,    C, 150, 0 // Расширенный идентификатор МНН лек. препарата с указанием пути введения
  // ID_LEKP_EXT, C,  25,0  // Код расширенного идентификатора МНН лек. препарата с указанием пути введения
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_zap, ' + ;
      'code_sh, ' + ;
      'id_lekp, ' + ;
      'datebeg, ' + ;
      'dateend, ' + ;
      'lekp_ext,' + ;
      'id_lekp_ext ' + ;
      'FROM n021' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
        dBeg := CToD( aTable[ nI, 4 ] )
        dEnd := CToD( aTable[ nI, 5 ] )
        Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 3 ] ), dBeg, dEnd, AllTrim( aTable[ nI, 6 ] ), AllTrim( aTable[ nI, 7 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// 24.12.24
Function getn021( dk )

  Static stYear
  Static _arr
  Local db
  Local aTable
  Local nI, dBeg, dEnd
  Local year_dk

  If ValType( dk ) == 'N'
    year_dk := dk
  Elseif ValType( dk ) == 'D'
    year_dk := Year( dk )
  Else
    Return {}
  Endif
  If ISNIL( stYear ) .or. Empty( _arr ) .or. year_dk != stYear
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, "SELECT " + ;
      "id_zap, " + ;
      "code_sh, " + ;
      "id_lekp, " + ;
      "datebeg, " + ;
      "dateend, " + ;
      "lekp_ext, " + ;
      "id_lekp_ext " + ;
      "FROM n021 " )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
        dBeg := CToD( aTable[ nI, 4 ] )
        dEnd := CToD( aTable[ nI, 5 ] )
        Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
        If ValType( dk ) == 'D'
          if dBeg <= dk .and. ( dk <= dEnd .or. Empty( dEnd ) )
            AAdd( _arr, { Val( aTable[ nI, 1 ] ), alltrim( aTable[ nI, 2 ] ), PadR( aTable[ nI, 3 ], 6 ), dBeg, dEnd, AllTrim( aTable[ nI, 6 ] ), AllTrim( aTable[ nI, 7 ] ) } )
          endif
        else
          if dk >= Year( dBeg ) .and. ( dk <= Year( dEnd ) .or. Empty( dEnd ) )
            AAdd( _arr, { Val( aTable[ nI, 1 ] ), alltrim( aTable[ nI, 2 ] ), PadR( aTable[ nI, 3 ], 6 ), dBeg, dEnd, AllTrim( aTable[ nI, 6 ] ), AllTrim( aTable[ nI, 7 ] ) } )
          endif
        endif
      Next
    Endif
    db := nil
    stYear := year_dk
  Endif
  Return _arr

// 19.01.25
function get_sootv_n021( sh, reg, dk )
  // sh - схема
  // dk - дата применения схемы

  local aN021 := getn021( dk ), nI
  local arr := {}

  sh := alltrim( lower( sh ) )
  reg := alltrim( reg )

  For nI := 1 To Len( aN021 )
      if reg == alltrim( aN021[ nI, 3 ] ) .and.  sh == lower( aN021[ nI, 2 ] ) .and. aN021[ nI, 4 ] <= dk .and. ( dk <= aN021[ nI, 5 ] .or. Empty( aN021[ nI, 5 ] ) )
        AAdd( arr, aN021[ nI, 1 ] )
        AAdd( arr, aN021[ nI, 2 ] )
        AAdd( arr, aN021[ nI, 3 ] )
        AAdd( arr, aN021[ nI, 4 ] )
        AAdd( arr, aN021[ nI, 5 ] )
        AAdd( arr, aN021[ nI, 6 ] )
        AAdd( arr, aN021[ nI, 7 ] )
      endif
  next
  return arr
