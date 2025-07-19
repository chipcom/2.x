#include 'hbhash.ch'
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// 19.07.25
function getN00X_new_rules( diag, stage, versionTNM, TNM, dk )

  local arr
  Local db
  Local aTable
  Local cmdText
  Local where
  Local group := ''
  Local i

  default TNM to 'stage'

  tnm := lower( tnm )
  diag := getds_sootv_onko( AllTrim( Upper( diag ) ), versionTNM )
  stage := AllTrim( stage )

  if tnm == 'stage'
//    cmdText := 'SELECT id_st, ds_st, kod_st, datebeg, dateend ' + ;
//      'FROM n002 ' + ;
//      'JOIN onko_stad ON n002.ds_st=onko_stad.icdtop'
//    group := ' GROUP BY kod_st'
    cmdText := 'SELECT n.id_st, n.ds_st, n.kod_st, n.datebeg, n.dateend, o.versionTNM ' + ;
      'FROM n002 AS n ' + ;
      'JOIN onko_stad AS o ' + ;
      'ON n.ds_st=o.icdtop'
    group := ' GROUP BY kod_st'
  elseif tnm == 'tumor'
//    cmdText := 'SELECT id_t, ds_t, kod_t, t_name, datebeg, dateend ' + ;
//      'FROM n003 ' + ;
//      'JOIN onko_stad ON n003.id_t=onko_stad.id_tumor'
//    group := ' GROUP BY id_tumor'
    cmdText := 'SELECT n.id_t, n.ds_t, n.kod_t, n.t_name, n.datebeg, n.dateend, o.versionTNM ' + ;
      'FROM n003 AS n ' + ;
      'JOIN onko_stad AS o ' + ;
      'ON n.id_t=o.id_tumor'
    group := ' GROUP BY n.id_t'
  elseif tnm == 'nodus'
//    cmdText := 'SELECT id_n, ds_n, kod_n, n_name, datebeg, dateend ' + ;
//      'FROM n004 ' + ;
//      'JOIN onko_stad ON n004.id_n=onko_stad.id_nodus'
//    group := ' GROUP BY id_nodus'
    cmdText := 'SELECT n.id_n, n.ds_n, n.kod_n, n.n_name, n.datebeg, n.dateend, o.versionTNM ' + ;
      'FROM n004 AS n ' + ;
      'JOIN onko_stad AS o ' + ;
      'ON n.id_n=o.id_nodus'
    group := ' GROUP BY n.id_n'
  elseif tnm == 'metastasis'
//    cmdText := 'SELECT id_m, ds_m, kod_m, m_name, datebeg, dateend ' + ;
//      'FROM n005 ' + ;
//      'JOIN onko_stad ON n005.id_m=onko_stad.id_metastas'
//    group := ' GROUP BY id_metastas'
    cmdText := 'SELECT n.id_m, n.ds_m, n.kod_m, n.m_name, n.datebeg, n.dateend, o.versionTNM ' + ;
      'FROM n005 AS n ' + ;
      'JOIN onko_stad AS o ' + ;
      'ON n.id_m=o.id_metastas'
    group := ' GROUP BY n.id_m'
  endif

  if tnm == 'stage'
    where := ' WHERE o.versionTNM=' + AllTrim( Str( versionTNM ) ) + ' and n.ds_st=="' + diag  + '"'
  elseif tnm == 'tumor'
    where := ' WHERE o.stage="' + stage + '" and o.versionTNM=' + AllTrim( Str( versionTNM ) ) + ' and n.ds_t=="' + diag  + '"'
  elseif tnm == 'nodus'
    where := ' WHERE o.stage="' + stage + '" and o.versionTNM=' + AllTrim( Str( versionTNM ) ) + ' and n.ds_n=="' + diag  + '"'
  elseif tnm == 'metastasis'
    where := ' WHERE o.stage="' + stage + '" and o.versionTNM=' + AllTrim( Str( versionTNM ) ) + ' and n.ds_m="' + diag  + '"'
  endif

  cmdText += where + group

  arr := {}
  db := opensql_db()
  aTable := sqlite3_get_table( db, cmdText )
  If Len( aTable ) > 1
    For i := 2 To Len( aTable )
//        AAdd( arr, { val( aTable[ i, 1 ] ), AllTrim( aTable[ i, 2 ] ), val( aTable[ i, 3 ] ), AllTrim( aTable[ i, 4 ] ), CToD( aTable[ i, 5 ] ), CToD( aTable[ i, 6 ] ) } )
      if tnm == 'stage'
        if between_date_new( CToD( aTable[ i, 4 ] ), CToD( aTable[ i, 5 ] ), dk )
          AAdd( arr, { AllTrim( aTable[ i, 3 ] ), val( aTable[ i, 1 ] ) } )
        endif
      else
        if between_date_new( CToD( aTable[ i, 5 ] ), CToD( aTable[ i, 6 ] ), dk )
          AAdd( arr, { AllTrim( aTable[ i, 3 ] ), val( aTable[ i, 1 ] ), AllTrim( aTable[ i, 4 ] ) } )
        endif
      endif
    Next
  Endif
  db := nil
  return arr

// 07.07.25
function get_sootv_mkb_mkbo()
  // возвращает массив Соответствие кодов МКБ-10 и кодов МКБ-О Топография для классификации TNM
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  // Соответствие кодов МКБ-10 и кодов МКБ-О Топография для классификации TNM
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