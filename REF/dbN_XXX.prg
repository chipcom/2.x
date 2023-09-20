#include 'hbhash.ch' 
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// =========== N001 ===================
//
// 05.09.23 вернуть массив ФФОМС N001.xml
function getN001()
  // возвращает массив N001 противопоказаний и отказов (OnkPrOt)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N001 - Перечень противопоказаний и отказов (OnkPrOt)
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
// 09.09.23 вернуть массив ФФОМС N002.xml
function getN002()
  // возвращает массив N002 Классификатор стадий (OnkStad)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N002 - Классификатор стадий (OnkStad)
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
        aadd(_arr, {alltrim(aTable[nI, 3]), val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _arr

// 09.09.23
function getDS_N002()
  static aStadii
  static time_load
  local row, it, i := 0

  if timeout_load(@time_load)
    aStadii := {}
    for each row in getN002()
      if ! empty(row[5])
        loop
      endif
      if (it := ascan(aStadii, {|x| x[1] == row[3]})) > 0
        // aadd(aStadii[it], {row[1], row[2]})
        aadd(aStadii[it, 2], {row[1], row[2]})
      else
        // aadd(aStadii, {row[3], {row[1], row[2]}})
        aadd(aStadii, {row[3], {}})
        i++
        aadd(aStadii[i, 2], {row[1], row[2]})
      endif
    next
    for i := 1 to len(aStadii)
      asort(aStadii[i, 2], , , {|x, y| x[1] < y[1]})
    next
    // asort(aStadii, , , {|x, y| x[1] < y[1]})
  endif
  return aStadii

// =========== N003 ===================
//
// 09.09.23 вернуть массив ФФОМС N003.xml
function getN003()
  // возвращает массив N003 Классификатор Tumor (OnkT)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N003 - Классификатор Tumor (OnkT)
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
        aadd(_arr, {alltrim(aTable[nI, 3]), val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
  endif
  return _arr

// 09.09.23
function getDS_N003()
  static aTumor
  static time_load
  local row, it, i := 0

  if timeout_load(@time_load)
    aTumor := {}
    for each row in getN003()
      if ! empty(row[6])
        loop
      endif
      // if (it := ascan(aTumor, {|x| x[1] == row[2]})) > 0
      if (it := ascan(aTumor, {|x| x[1] == row[3]})) > 0
        // aadd(aTumor[it], {row[1], row[3], row[4]})
        aadd(aTumor[it, 2], {row[1], row[2], row[4]})
      else
        // aadd(aTumor, {row[2], {row[1], row[3], row[4]}})
        aadd(aTumor, {row[3], {}})
        i++
        aadd(aTumor[i, 2], {row[1], row[2], row[4]})
      endif
    next
    for i := 1 to len(aTumor)
      asort(aTumor[i, 2], , , {|x, y| x[1] < y[1]})
    next
    // asort(aTumor, , , {|x, y| x[1] < y[1]})
  endif
  return aTumor

// =========== N004 ===================
//
// 09.09.23 вернуть массив ФФОМС N004.xml
function getN004()
  // возвращает массив N004 Классификатор Nodus (OnkN)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N004 - Классификатор Nodus (OnkN)
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
        aadd(_arr, {alltrim(aTable[nI, 3]), val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
  endif
  return _arr

// 09.09.23
function getDS_N004()
  static aNodus
  static time_load
  local row, it, i := 0

  if timeout_load(@time_load)
    aNodus := {}
    for each row in getN004()
      if ! empty(row[6])
        loop
      endif
      // if (it := ascan(aNodus, {|x| x[1] == row[2]})) > 0
      if (it := ascan(aNodus, {|x| x[1] == row[3]})) > 0
        // aadd(aNodus[it], {row[1], row[3], row[4]})
        aadd(aNodus[it, 2], {row[1], row[2], row[4]})
      else
        // aadd(aNodus, {row[2], {row[1], row[3], row[4]}})
        aadd(aNodus, {row[3], {}})
        i++
        aadd(aNodus[i, 2], {row[1], row[2], row[4]})
      endif
    next
    for i := 1 to len(aNodus)
      asort(aNodus[i, 2], , , {|x, y| x[1] < y[1]})
    next
    // asort(aNodus, , , {|x, y| x[1] < y[1]})
  endif
  return aNodus

// =========== N005 ===================
//
// 09.09.23 вернуть массив ФФОМС N005.xml
function getN005()
  // возвращает массив N005 Классификатор Metastasis (OnkM)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N005 - Классификатор Metastasis (OnkM)
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
        aadd(_arr, {alltrim(aTable[nI, 3]), val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
  endif
  return _arr

// 09.09.23
function getDS_N005()
  static aMetastasis
  static time_load
  local row, it, i := 0

  if timeout_load(@time_load)
    aMetastasis := {}
    for each row in getN005()
      if ! empty(row[6])
        loop
      endif
      // if (it := ascan(aMetastasis, {|x| x[1] == row[2]})) > 0
      if (it := ascan(aMetastasis, {|x| x[1] == row[3]})) > 0
        // aadd(aMetastasis[it], {row[1], row[3], row[4]})
        aadd(aMetastasis[it, 2], {row[1], row[2], row[4]})
      else
        // aadd(aMetastasis, {row[2], {row[1], row[3], row[4]}})
        aadd(aMetastasis, {row[3], {}})
        i++
        aadd(aMetastasis[i, 2], {row[1], row[2], row[4]})
      endif
    next
    for i := 1 to len(aMetastasis)
      asort(aMetastasis[i, 2], , , {|x, y| x[1] < y[1]})
    next
    // asort(aMetastasis, , , {|x, y| x[1] < y[1]})
  endif
  return aMetastasis

// =========== N006 ===================
//
// 27.08.23 вернуть массив ФФОМС N006.xml Справочник соответствия стадий TNM (OnkTNM)
function loadN006()
  // возвращает массив N006 соответствия стадий TNM (OnkTNM)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N006 - Перечень соответствия стадий TNM (OnkTNM)
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
// 27.08.23 вернуть массив ФФОМС N007.xml Классификатор гистологических признаков (OnkMrf)
function getN007()
  // возвращает массив N007 гистологических признаков (OnkMrf)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N007 - Перечень гистологических признаков (OnkMrf)
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
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N008 ===================
//
// 12.09.23 вернуть массив ФФОМС N008.xml Классификатор результатов гистологических исследований (OnkMrfRt)
function loadN008()
  // возвращает массив N008 результатов гистологических исследований (OnkMrfRt)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N008 - Перечень результатов гистологических исследований (OnkMrfRt)
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

// 12.09.23
function getN008()
  local arr := {}
  local row

  for each row in loadN008()
    aadd(arr, {row[3], row[2]})
  next
  return arr

// =========== N009 ===================
//
// 27.08.23 вернуть массив ФФОМС N009.xml Классификатор соответствия гистологических признаков диагнозам (OnkMrtDS)
function getN009()
  // возвращает массив N009 соответствия гистологических признаков диагнозам (OnkMrtDS)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N009 - Перечень соответствия гистологических признаков диагнозам (OnkMrtDS)
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
// 28.08.23 вернуть массив ФФОМС N010.xml Классификатор маркёров (OnkIgh)
function loadN010()
  // возвращает массив N010 Классификатор маркёров (OnkIgh)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N010 - Перечень маркёров (OnkIgh)
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
// 28.08.23 вернуть массив ФФОМС N011.xml Классификатор значений маркёров (OnkIghRt)
function loadN011()
  // возвращает массив N011 значений маркёров (OnkIghRt)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N011 - Перечень значений маркёров (OnkIghRt)
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

// 13.09.23
function getN011()
  local arr := {}
  local row

  for each row in loadN011()
    aadd(arr, {row[4], row[2]})
  next
  return arr

// =========== N012 ===================
//
// 28.08.23 вернуть массив ФФОМС N012.xml Классификатор соответствия маркёров диагнозам (OnkIghDS)
function loadN012()
  // возвращает массив N012 соответствия маркёров диагнозам (OnkIghDS)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N012 - Перечень соответствия маркёров диагнозам (OnkIghDS)
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

// 12.09.23
function getDS_N012()
  static OnkIghDS
  static time_load
  local row, it, i := 0

  if timeout_load(@time_load)
    OnkIghDS := {}
    for each row in loadN012()
      if ! empty(row[5])
        loop
      endif
      if (it := ascan(OnkIghDS, {|x| x[1] == row[2]})) > 0
        aadd(OnkIghDS[it, 2], {row[3]}) // {row[1], row[3]}
      else
        aadd(OnkIghDS, {row[2], {}})
        i++
        aadd(OnkIghDS[i, 2], {row[3]})  // {row[1], row[3]}
      endif
    next
    // for i := 1 to len(OnkIghDS)
    //   asort(OnkIghDS[i, 2], , , {|x, y| x[1] < y[1]})
    // next
  endif
  return OnkIghDS

// =========== N013 ===================
//
// 19.09.23 вернуть массив ФФОМС N013.xml Классификатор типов лечения (OnkLech)
function getN013()
  // возвращает массив N013 типов лечения (OnkLech)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N013 - Перечень типов лечения (OnkLech)
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
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1])}) //, ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N014 ===================
//
// 19.09.23 вернуть массив ФФОМС N014.xml Классификатор типов хирургического лечения (OnkHir)
function getN014()
  // возвращает массив N014 типов хирургического лечения (OnkHir)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N014 - Перечень типов хирургического лечения (OnkHir)
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
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N015 ===================
//
// 19.09.23 вернуть массив ФФОМС N015.xml Классификатор линий лекарственной терапии (OnkLek_L)
function getN015()
  // возвращает массив N015 линий лекарственной терапии (OnkLek_L)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N015 - Перечень линий лекарственной терапии (OnkLek_L)
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
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1])})  //, ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N016 ===================
//
// 19.09.23 вернуть массив ФФОМС N016.xml Классификатор циклов лекарственной терапии (OnkLek_V)
function getN016()
  // возвращает массив N016 циклов лекарственной терапии (OnkLek_V)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N016 - Перечень циклов лекарственной терапии (OnkLek_V)
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
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1])})  //, ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N017 ===================
//
// 19.09.23 вернуть массив ФФОМС N017.xml Классификатор типов лучевой терапии (OnkLuch)
function getN017()
  // возвращает массив N017 типов лучевой терапии (OnkLuch)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N017 - Перечень типов лучевой терапии (OnkLuch)
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
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1])})  //, ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N018 ===================
//
// 19.09.23 вернуть массив ФФОМС N018.xml Классификатор поводов обращения (OnkReas)
function getN018()
  // возвращает массив N018 поводов обращения (OnkReas)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N018 - Перечень поводов обращения (OnkReas)
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
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1])})  //, ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N019 ===================
//
// 19.09.23 вернуть массив ФФОМС N019.xml Классификатор целей консилиума (OnkCons)
function getN019()
  // возвращает массив N019 целей консилиума (OnkCons)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N019 - Перечень целей консилиума (OnkCons)
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
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1])})  //, ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N020 ===================
//
// 07.01.22 вернуть массив по справочнику ФФОМС N020.xml
// Классификатор лекарственных препаратов, применяемых при проведении лекарственной терапии (OnkLekp)
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
// Классификатор соответствия лекарственного препарата схеме лекарственной терапии (OnkLpsh)
function loadN021()
  // возвращает массив N021 соответствия лекарственного препарата схеме лекарственной терапии (OnkLpsh)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N021 - Перечень соответствия лекарственного препарата схеме лекарственной терапии (OnkLpsh)
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

// 20.09.23
function getN021_by_date(dk)
  local arr := {}, row

  for each row in loadN021()
    if between_date(row[4], row[5], dk)
      aadd(arr, row)
    endif
  next

  return arr