#include 'hbhash.ch' 
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// =========== N001 ===================
//
// 27.08.23 вернуть массив ФФОМС N001.xml
function loadN001()
  // возвращает массив N001
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N001 - Перечень
  // ID_PROT,  N,  2
  // PROT_NAME,   C,  250
  // DATEBEG,    C,  10
  // DATEEND,      C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_prot, ' + ;
        'prot_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n001')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2])}) //, val(aTable[nI, 3]), alltrim(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N002 ===================
//
// 27.08.23 вернуть массив ФФОМС N002.xml
function loadN002()
  // возвращает массив N002
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N002 - Перечень
  // ID_St,      'N',  4 // Идентификатор стадии
  // DS_St,      'C',  5 // Диагноз по МКБ
  // KOD_St,     'C',  5 // Стадия
  // DATEBEG,    'C',  10 // Дата начала действия записи
  // DATEEND,    'C',  10 // Дата окончания действия записи
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_st, ' + ;
        'ds_st, ' + ;
        'kod_st, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n002')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N003 ===================
//
// 27.08.23 вернуть массив ФФОМС N003.xml
function loadN003()
  // возвращает массив N003
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N003 - Перечень
  // ID_T,       'N',  4  // Идентификатор T
  // DS_T,       'C',  5  // Диагноз по МКБ
  // KOD_T,      'C',  5  // Обозначение T для диагноза
  // T_NAME,     'C', 250 // Расшифровка T для диагноза
  // DATEBEG,    'C',  10 // Дата начала действия записи
  // DATEEND,    'C',  10 // Дата окончания действия записи
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_t, ' + ;
        'ds_t, ' + ;
        'kod_t, ' + ;
        't_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n003')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N004 ===================
//
// 27.08.23 вернуть массив ФФОМС N004.xml
function loadN004()
  // возвращает массив N004
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N004 - Перечень
  // ID_N,       'N',  4 // Идентификатор N
  // DS_N,       'C',  5 // Диагноз по МКБ
  // KOD_N,      'C',  5 // Обозначение N для диагноза
  // N_NAME,     'C',500 // Расшифровка N для диагноза
  // DATEBEG,    'C',  10 // Дата начала действия записи
  // DATEEND,    'C',  10 // Дата окончания действия записи
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_n, ' + ;
        'ds_n, ' + ;
        'kod_n, ' + ;
        'n_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n004')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N005 ===================
//
// 27.08.23 вернуть массив ФФОМС N005.xml
function loadN005()
  // возвращает массив N005
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N005 - Перечень
  // ID_M,       'N',  4 // Идентификатор M
  // DS_M,       'C',  5 // Диагноз по МКБ
  // KOD_M,      'C',  5 // Обозначение M для диагноза
  // M_NAME,     'C',250 // Расшифровка M для диагноза
  // DATEBEG,    'C',  10 // Дата начала действия записи
  // DATEEND,    'C',  10 // Дата окончания действия записи
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_m, ' + ;
        'ds_m, ' + ;
        'kod_m, ' + ;
        'm_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n005')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N006 ===================
//
// 27.08.23 вернуть массив ФФОМС N006.xml
function loadN006()
  // возвращает массив N006
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N006 - Перечень
  // ID_gr,      'N',  4 // Идентификатор строки
  // DS_gr,      'C',  5 // Диагноз по МКБ
  // ID_St,      'N',  4 // Идентификатор стадии
  // ID_T,       'N',  4 // Идентификатор T
  // ID_N,       'N',  4 // Идентификатор N
  // ID_M,       'N',  4 // Идентификатор M
  // DATEBEG,    'C',  10 // Дата начала действия записи
  // DATEEND,    'C',  10 // Дата окончания действия записи
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_gr, ' + ;
        'ds_gr, ' + ;
        'id_st, ' + ;
        'id_t, ' + ;
        'id_n, ' + ;
        'id_m, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n006')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), val(aTable[nI, 3]), val(aTable[nI, 4]), val(aTable[nI, 5]), val(aTable[nI, 6]), ctod(aTable[nI, 7]), ctod(aTable[nI, 8])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N007 ===================
//
// 27.08.23 вернуть массив ФФОМС N007.xml
function loadN007()
  // возвращает массив N007
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N007 - Перечень
  // ID_Mrf,    'N',  2 // Идентификатор гистологического признака
  // Mrf_NAME,  'C',250 // Наименование гистологического признака
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_mrf, ' + ;
        'mrf_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n007')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2])}) //, val(aTable[nI, 3]), alltrim(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N008 ===================
//
// 27.08.23 вернуть массив ФФОМС N008.xml
function loadN008()
  // возвращает массив N008
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N008 - Перечень
  // ID_R_M,    'N',  3 // Идентификатор записи
  // ID_Mrf,    'N',  2 // Идентификатор гистологического признака в соответствии с N007
  // R_M_NAME,  'C',250 // Наименование результата гистологического исследования
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_r_m, ' + ;
        'id_mrf, ' + ;
        'r_m_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n008')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), val(aTable[nI, 2]), alltrim(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N009 ===================
//
// 27.08.23 вернуть массив ФФОМС N009.xml
function loadN009()
  // возвращает массив N009
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N009 - Перечень
  // ID_M_D,     N,  2 // Идентификатор строки
  // DS_Mrf,     C,  3 // Диагноз по МКБ
  // ID_Mrf,     N,  2 // Идентификатор гистологического признака в соответствии с N007
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_m_d, ' + ;
        'ds_mrf, ' + ;
        'id_mrf, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n009')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), val(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N020 ===================
//
// 07.01.22 вернуть массив по справочнику ФФОМС N020.xml - 
function loadN020()
  Local dbName, dbAlias := 'N020'
  local tmp_select := select()
  static _N020

  if _N020 == nil
    _N020 := hb_hash()
    tmp_select := select()
    dbName := '_mo_n020'
    dbUseArea( .t., 'DBFNTX', exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - ID_LEKP(C)  2 - MNN(C)  3 - DATEBEG(D)  4 - DATEEND(D)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      hb_hSet( _N020, alltrim((dbAlias)->ID_LEKP), {(dbAlias)->ID_LEKP, alltrim((dbAlias)->MNN), (dbAlias)->DATEBEG, (dbAlias)->DATEEND} )
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _N020

// 07.01.22 вернуть МНН лекарственного препарата
function get_Lek_pr_By_ID(id_lekp)
  local arr := loadN020()
  local ret

  if hb_hHaskey( arr, id_lekp )
    ret := arr[id_lekp][2]
  endif
  return ret