#include 'hbhash.ch' 
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// =========== N001 ===================
//
// 05.09.23 вернуть массив ФФОМС N001.xml
function getN001()
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
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1])}) //, val(aTable[nI, 3]), alltrim(aTable[nI, 4])})
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

// =========== N010 ===================
//
// 28.08.23 вернуть массив ФФОМС N010.xml
function loadN010()
  // возвращает массив N010
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N010 - Перечень
  // ID_Igh,     N,   2 // Идентификатор маркера
  // KOD_Igh,    C, 250 // Обозначение маркера
  // Igh_NAME,   C, 250 // Наименование маркера
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_igh, ' + ;
        'kod_igh, ' + ;
        'igh_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n010')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N011 ===================
//
// 28.08.23 вернуть массив ФФОМС N011.xml
function loadN011()
  // возвращает массив N011
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N011 - Перечень
  // ID_R_I,     N,   3 // Идентификатор записи
  // ID_Igh,     N,   2 // Идентификатор маркера в соответствии с N010
  // KOD_R_I,    C, 250 // Обозначение результата
  // R_I_NAME,   C, 250 // Наименование результата
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_r_i, ' + ;
        'id_igh, ' + ;
        'kod_r_i, ' + ;
        'r_i_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n011')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), val(aTable[nI, 2]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N012 ===================
//
// 28.08.23 вернуть массив ФФОМС N012.xml
function loadN012()
  // возвращает массив N012
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N012 - Перечень
  // ID_I_D,     N,  2 // Идентификатор строки
  // DS_Igh,     C,  3 // Диагноз по МКБ
  // ID_Igh,     N,  2 // Идентификатор маркера в соответствии с N010
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_i_d, ' + ;
        'ds_igh, ' + ;
        'id_igh, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n012')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), val(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N013 ===================
//
// 28.08.23 вернуть массив ФФОМС N013.xml
function loadN013()
  // возвращает массив N013
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N013 - Перечень
  // ID_TLech,   N,   1 // Идентификатор типа лечения
  // TLech_NAME, C, 250 // Наименование типа лечения
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_tlech, ' + ;
        'tlech_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n013')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N014 ===================
//
// 28.08.23 вернуть массив ФФОМС N014.xml
function loadN014()
  // возвращает массив N014
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N014 - Перечень
  // ID_THir,    N,   1 // Идентификатор типа хирургического лечения
  // THir_NAME,  C, 250 // Наименование типа хирургического лечения
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_thir, ' + ;
        'thir_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n014')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N015 ===================
//
// 28.08.23 вернуть массив ФФОМС N015.xml
function loadN015()
  // возвращает массив N015
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N015 - Перечень
  // ID_TLek_L,  N,   1 // Идентификатор линии лекарственной терапии
  // TLek_NAME_L,C, 250 // Наименование линии лекарственной терапии
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_tlek_l, ' + ;
        'tlek_name_l, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n015')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N016 ===================
//
// 28.08.23 вернуть массив ФФОМС N016.xml
function loadN016()
  // возвращает массив N016
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N016 - Перечень
  // ID_TLek_V,  N,   1 // Идентификатор цикла лекарственной терапии
  // TLek_NAME_V,C, 250 // Наименование цикла лекарственной терапии
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_tlek_v, ' + ;
        'tlek_name_v, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n016')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N017 ===================
//
// 28.08.23 вернуть массив ФФОМС N017.xml
function loadN017()
  // возвращает массив N017
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N017 - Перечень
  // ID_TLuch,   N,   1 // Идентификатор типа лучевой терапии
  // TLuch_NAME, C, 250 // Наименование типа лучевой терапии
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_tluch, ' + ;
        'tluch_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n017')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N018 ===================
//
// 28.08.23 вернуть массив ФФОМС N018.xml
function loadN018()
  // возвращает массив N018
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N018 - Перечень
  // ID_REAS,    N,   2 // Идентификатор повода обращения
  // REAS_NAME,  C, 300 // Наименование повода обращения
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_reas, ' + ;
        'reas_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n018')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N019 ===================
//
// 28.08.23 вернуть массив ФФОМС N019.xml
function loadN019()
  // возвращает массив N019
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N019 - Перечень
  // ID_CONS,    N,   1 // Идентификатор цели консилиума
  // CONS_NAME,  C, 300 // Наименование цели консилиума
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_cons, ' + ;
        'cons_name, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n019')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
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

// =========== N021 ===================
//
// 28.08.23 вернуть массив ФФОМС N021.xml
function loadN021()
  // возвращает массив N021
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N021 - Перечень
  // ID_ZAP,     N,   4 // Идентификатор записи (в описании Char 15)
  // CODE_SH,    C,  10 // Код схемы лекарственной терапии
  // ID_LEKP,    C,   6 // Идентификатор лекарственного препарата, применяемого при проведении лекарственной противоопухолевой терапии. Заполняется в соответствии с N020
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id_zap, ' + ;
        'code_sh, ' + ;
        'id_lekp, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM n021')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _arr

