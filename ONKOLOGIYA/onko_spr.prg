#include 'hbhash.ch'
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// 30.07.25
function getN00X_new_rules( diag, stage, versionTNM, type_TNM, mdate )

  local arr
  Local db
  Local aTable
  Local cmdText
  Local where
  Local group := ''
  Local i

  default type_TNM to 'stage'

  type_TNM := lower( type_TNM )
  diag := AllTrim( diag )
  if mdate >= 0d20250701  // ???? ???????? ?? ????? ?????? ?????? TNM ?? ???-?
    diag := getds_sootv_onko( AllTrim( Upper( diag ) ), versionTNM )
  endif
  stage := AllTrim( stage )

  if type_TNM == 'stage'
//    cmdText := 'SELECT n.id_st, n.ds_st, n.kod_st, n.datebeg, n.dateend, o.versionTNM ' + ;
//      'FROM n002 AS n ' + ;
//      'JOIN onko_stad AS o ' + ;
//      'ON n.ds_st=o.icdtop'
//    group := ' GROUP BY n.kod_st'
    cmdText := 'SELECT n.id_st, n.ds_st, n.kod_st, n.datebeg, n.dateend ' + ;
      'FROM n002 AS n'
//    where := ' WHERE o.versionTNM=' + AllTrim( Str( versionTNM ) ) + ' and n.ds_st=="' + diag  + '"'
    cmdText += ' WHERE n.ds_st=="' + diag  + '"'  // ??????? WHERE
    cmdText += ''   // ??????? GROUP BY
  elseif type_TNM == 'tumor'
//    cmdText := 'SELECT id_t, ds_t, kod_t, t_name, datebeg, dateend ' + ;
//      'FROM n003 ' + ;
//      'JOIN onko_stad ON n003.id_t=onko_stad.id_tumor'
//    group := ' GROUP BY id_tumor'
    cmdText := 'SELECT n.id_t, n.ds_t, n.kod_t, n.t_name, n.datebeg, n.dateend, o.versionTNM ' + ;
      'FROM n003 AS n ' + ;
      'JOIN onko_stad AS o ' + ;
      'ON n.id_t=o.id_tumor'
    cmdText += ' WHERE o.stage="' + stage + '" and o.versionTNM=' + AllTrim( Str( versionTNM ) ) + ' and n.ds_t=="' + diag  + '"'
    cmdText += ' GROUP BY n.id_t'
  elseif type_TNM == 'nodus'
//    cmdText := 'SELECT id_n, ds_n, kod_n, n_name, datebeg, dateend ' + ;
//      'FROM n004 ' + ;
//      'JOIN onko_stad ON n004.id_n=onko_stad.id_nodus'
//    group := ' GROUP BY id_nodus'
    cmdText := 'SELECT n.id_n, n.ds_n, n.kod_n, n.n_name, n.datebeg, n.dateend, o.versionTNM ' + ;
      'FROM n004 AS n ' + ;
      'JOIN onko_stad AS o ' + ;
      'ON n.id_n=o.id_nodus'
    cmdText += ' WHERE o.stage="' + stage + '" and o.versionTNM=' + AllTrim( Str( versionTNM ) ) + ' and n.ds_n=="' + diag  + '"'
    cmdText += ' GROUP BY n.id_n'
  elseif type_TNM == 'metastasis'
//    cmdText := 'SELECT id_m, ds_m, kod_m, m_name, datebeg, dateend ' + ;
//      'FROM n005 ' + ;
//      'JOIN onko_stad ON n005.id_m=onko_stad.id_metastas'
//    group := ' GROUP BY id_metastas'
    cmdText := 'SELECT n.id_m, n.ds_m, n.kod_m, n.m_name, n.datebeg, n.dateend, o.versionTNM ' + ;
      'FROM n005 AS n ' + ;
      'JOIN onko_stad AS o ' + ;
      'ON n.id_m=o.id_metastas'
    cmdText += ' WHERE o.stage="' + stage + '" and o.versionTNM=' + AllTrim( Str( versionTNM ) ) + ' and n.ds_m="' + diag  + '"'
    cmdText += ' GROUP BY n.id_m'
  endif

  arr := {}
  db := opensql_db()
  aTable := sqlite3_get_table( db, cmdText )
  If Len( aTable ) > 1
    For i := 2 To Len( aTable )
      if type_TNM == 'stage'
        if correct_date_dictionary( mdate, CToD( aTable[ i, 4 ] ), CToD( aTable[ i, 5 ] ) )
          AAdd( arr, { AllTrim( aTable[ i, 3 ] ), val( aTable[ i, 1 ] ) } )
        endif
      else
        if correct_date_dictionary( mdate, CToD( aTable[ i, 5 ] ), CToD( aTable[ i, 6 ] ) )
          AAdd( arr, { AllTrim( aTable[ i, 3 ] ), val( aTable[ i, 1 ] ), AllTrim( aTable[ i, 4 ] ) } )
        endif
      endif
    Next
  Endif
  db := nil
  return arr

// 07.07.25
function get_sootv_mkb_mkbo()
  // возвращает массив Соответствие кодов МКЭ-10 и кодов МКЭ-О Топография для классификации TNM
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // Соответствие кодов МКЭ-10 и кодов МКЭ-О Топография для классификации TNM
  // icd10 TEXT(10)
  // icd10top TEXT(10)
  // tnm_7 INTEGER
  // tnm_8 INTEGER

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'icd10, ' + ;
      'icd10top, ' + ;
      'tnm_7, ' + ;
      'tnm_8 ' + ;
      'FROM mkb_mkbo' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), iif( Val( aTable[ nI, 3 ] ) == 1, .t., .f. ), iif( Val( aTable[ nI, 4 ] ) == 1, .t., .f. ) } )
      Next
    Endif
    db := nil
  endif
  Return _arr

// 17.07.25
function getds_sootv_onko( codeMKB, versionTNM )

  local ret := '', fl := .f.
  local aSootv, i, shortCodeMKB

  codeMKB := Upper( AllTrim( codeMKB ) )
  shortCodeMKB := SubStr( codeMKB, 1, 3 )
  aSootv := get_sootv_mkb_mkbo()

  for i := 1 to len( aSootv )
    if aSootv[ i, 1 ] == codeMKB .or. aSootv[ i, 1 ] == shortCodeMKB
      if versionTNM == 7 .and. aSootv[ i, 3 ]
        ret := aSootv[ i, 2 ]
        fl := .t.
        exit
      elseif versionTNM == 8 .and. aSootv[ i, 4 ]
        ret := aSootv[ i, 2 ]
        fl := .t.
        exit
      endif
    endif
  next
  if ! fl
    ret := codeMKB
  endif
  return ret

// =========== N002 ===================
//
// 09.09.23 вернуть массив ФФОМС N002.xml
Function getn002()

  // возвращает массив N002 Классификатор стадий (OnkStad)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N002 - Классификатор стадий (OnkStad)
  // ID_St,      'N',  4 // Идентификатор стадии
  // DS_St,      'C',  5 // Диагноз по МКЭ
  // KOD_St,     'C',  5 // Стадия
  // DATEBEG,    'C',  10 // Дата начала действия записи
  // DATEEND,    'C',  10 // Дата окончания действия записи
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_st, ' + ;
      'ds_st, ' + ;
      'kod_st, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n002' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 3 ] ), Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// 29.05.25
Function getds_n002( mdate )
 
  local aStadii
  Local row, it, i := 0

  default mdate to sys_date
  if ValType( mdate ) == 'C'
    mdate := CToD( mdate )
  endif
  aStadii := {}
  For Each row in getn002() 
    // if ! Empty( row[ 5 ] )
    //   if ( row[ 4 ] <= mdate .and. row[ 5 ] >= mdate )
    //     loop
    //   endif
    // endif
    if ! correct_date_dictionary( mdate, row[ 4 ], row[ 5 ] )
      loop
    endif
    If ( it := AScan( aStadii, {| x| x[ 1 ] == row[ 3 ] } ) ) > 0
      AAdd( aStadii[ it, 2 ], { row[ 1 ], row[ 2 ] } )
    Else
      AAdd( aStadii, { row[ 3 ], {} } )
      i++
      AAdd( aStadii[ i, 2 ], { row[ 1 ], row[ 2 ] } )
    Endif
  Next
  For i := 1 To Len( aStadii )
    ASort( aStadii[ i, 2 ], , , {| x, y| x[ 1 ] < y[ 1 ] } )
  Next
  Return aStadii

// =========== N003 ===================
//
// 09.09.23 вернуть массив ФФОМС N003.xml
Function getn003()

  // возвращает массив N003 Классификатор Tumor (OnkT)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N003 - Классификатор Tumor (OnkT)
  // ID_T,       'N',  4  // Идентификатор T
  // DS_T,       'C',  5  // Диагноз по МКЭ
  // KOD_T,      'C',  5  // Обозначение T для диагноза
  // T_NAME,     'C', 250 // Эасшифровка T для диагноза
  // DATEBEG,    'C',  10 // Дата начала действия записи
  // DATEEND,    'C',  10 // Дата окончания действия записи
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_t, ' + ;
      'ds_t, ' + ;
      'kod_t, ' + ;
      't_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n003' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 3 ] ), Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// 29.05.25
Function getds_n003( mdate )

  local aTumor
  Local row, it, i := 0

  default mdate to sys_date
  if ValType( mdate ) == 'C'
    mdate := CToD( mdate )
  endif
  aTumor := {}
  For Each row in getn003()
    // if ! Empty( row[ 6 ] )
    //   if ( row[ 5 ] <= mdate .and. row[ 6 ] >= mdate )
    //     loop
    //   endif
    // endif
    if ! correct_date_dictionary( mdate, row[ 5 ], row[ 6 ] )
      loop
    endif

    If ( it := AScan( aTumor, {| x| x[ 1 ] == row[ 3 ] } ) ) > 0
      AAdd( aTumor[ it, 2 ], { row[ 1 ], row[ 2 ], row[ 4 ] } )
    Else
      AAdd( aTumor, { row[ 3 ], {} } )
      i++
      AAdd( aTumor[ i, 2 ], { row[ 1 ], row[ 2 ], row[ 4 ] } )
    Endif
  Next
  For i := 1 To Len( aTumor )
    ASort( aTumor[ i, 2 ], , , {| x, y| x[ 1 ] < y[ 1 ] } )
  Next
  Return aTumor

// =========== N004 ===================
//
// 09.09.23 вернуть массив ФФОМС N004.xml
Function getn004()

  // возвращает массив N004 Классификатор Nodus (OnkN)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N004 - Классификатор Nodus (OnkN)
  // ID_N,       'N',  4 // Идентификатор N
  // DS_N,       'C',  5 // Диагноз по МКЭ
  // KOD_N,      'C',  5 // Обозначение N для диагноза
  // N_NAME,     'C',500 // Эасшифровка N для диагноза
  // DATEBEG,    'C',  10 // Дата начала действия записи
  // DATEEND,    'C',  10 // Дата окончания действия записи
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_n, ' + ;
      'ds_n, ' + ;
      'kod_n, ' + ;
      'n_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n004' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 3 ] ), Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// 29.05.25
Function getds_n004( mdate )

  Static aNodus
  Local row, it, i := 0

  default mdate to sys_date
  if ValType( mdate ) == 'C'
    mdate := CToD( mdate )
  endif
  aNodus := {}
  For Each row in getn004()
    // if ! Empty( row[ 6 ] )
    //   if ( row[ 5 ] <= mdate .and. row[ 6 ] >= mdate )
    //     loop
    //   endif
    // endif
    if ! correct_date_dictionary( mdate, row[ 5 ], row[ 6 ] )
      loop
    endif
    If ( it := AScan( aNodus, {| x| x[ 1 ] == row[ 3 ] } ) ) > 0
      AAdd( aNodus[ it, 2 ], { row[ 1 ], row[ 2 ], row[ 4 ] } )
    Else
      AAdd( aNodus, { row[ 3 ], {} } )
      i++
      AAdd( aNodus[ i, 2 ], { row[ 1 ], row[ 2 ], row[ 4 ] } )
    Endif
  Next
  For i := 1 To Len( aNodus )
    ASort( aNodus[ i, 2 ], , , {| x, y| x[ 1 ] < y[ 1 ] } )
  Next
  Return aNodus

// =========== N005 ===================
//
// 09.09.23 вернуть массив ФФОМС N005.xml
Function getn005()

  // возвращает массив N005 Классификатор Metastasis (OnkM)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // N005 - Классификатор Metastasis (OnkM)
  // ID_M,       'N',  4 // Идентификатор M
  // DS_M,       'C',  5 // Диагноз по МКЭ
  // KOD_M,      'C',  5 // Обозначение M для диагноза
  // M_NAME,     'C',250 // Эасшифровка M для диагноза
  // DATEBEG,    'C',  10 // Дата начала действия записи
  // DATEEND,    'C',  10 // Дата окончания действия записи
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'id_m, ' + ;
      'ds_m, ' + ;
      'kod_m, ' + ;
      'm_name, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM n005' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 3 ] ), Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) } )
      Next
    Endif
    db := nil
  Endif
  Return _arr

// 29.05.25
Function getds_n005( mdate )

  local aMetastasis
  Local row, it, i := 0

  default mdate to sys_date
  if ValType( mdate ) == 'C'
    mdate := CToD( mdate )
  endif
  aMetastasis := {}
  For Each row in getn005()
    // if ! Empty( row[ 6 ] )
    //   if ( row[ 5 ] <= mdate .and. row[ 6 ] >= mdate )
    //     loop
    //   endif
    // endif
    if ! correct_date_dictionary( mdate, row[ 5 ], row[ 6 ] )
      loop
    endif
    If ( it := AScan( aMetastasis, {| x| x[ 1 ] == row[ 3 ] } ) ) > 0
      AAdd( aMetastasis[ it, 2 ], { row[ 1 ], row[ 2 ], row[ 4 ] } )
    Else
      AAdd( aMetastasis, { row[ 3 ], {} } )
      i++
      AAdd( aMetastasis[ i, 2 ], { row[ 1 ], row[ 2 ], row[ 4 ] } )
    Endif
  Next
  For i := 1 To Len( aMetastasis )
    ASort( aMetastasis[ i, 2 ], , , {| x, y| x[ 1 ] < y[ 1 ] } )
  Next
  Return aMetastasis