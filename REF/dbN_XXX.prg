#include 'hbhash.ch' 
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// =========== N001 ===================
//
// 05.09.23 ������ ���ᨢ ����� N001.xml
function getN001()
  // �����頥� ���ᨢ N001 ��⨢���������� � �⪠��� (OnkPrOt)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N001 - ���祭� ��⨢���������� � �⪠��� (OnkPrOt)
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
// 09.09.23 ������ ���ᨢ ����� N002.xml
function getN002()
  // �����頥� ���ᨢ N002 �����䨪��� �⠤�� (OnkStad)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N002 - �����䨪��� �⠤�� (OnkStad)
  // ID_St,      'N',  4 // �����䨪��� �⠤��
  // DS_St,      'C',  5 // ������� �� ���
  // KOD_St,     'C',  5 // �⠤��
  // DATEBEG,    'C',  10 // ��� ��砫� ����⢨� �����
  // DATEEND,    'C',  10 // ��� ����砭�� ����⢨� �����
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
// 09.09.23 ������ ���ᨢ ����� N003.xml
function getN003()
  // �����頥� ���ᨢ N003 �����䨪��� Tumor (OnkT)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N003 - �����䨪��� Tumor (OnkT)
  // ID_T,       'N',  4  // �����䨪��� T
  // DS_T,       'C',  5  // ������� �� ���
  // KOD_T,      'C',  5  // ������祭�� T ��� ��������
  // T_NAME,     'C', 250 // �����஢�� T ��� ��������
  // DATEBEG,    'C',  10 // ��� ��砫� ����⢨� �����
  // DATEEND,    'C',  10 // ��� ����砭�� ����⢨� �����
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
// 09.09.23 ������ ���ᨢ ����� N004.xml
function getN004()
  // �����頥� ���ᨢ N004 �����䨪��� Nodus (OnkN)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N004 - �����䨪��� Nodus (OnkN)
  // ID_N,       'N',  4 // �����䨪��� N
  // DS_N,       'C',  5 // ������� �� ���
  // KOD_N,      'C',  5 // ������祭�� N ��� ��������
  // N_NAME,     'C',500 // �����஢�� N ��� ��������
  // DATEBEG,    'C',  10 // ��� ��砫� ����⢨� �����
  // DATEEND,    'C',  10 // ��� ����砭�� ����⢨� �����
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
// 09.09.23 ������ ���ᨢ ����� N005.xml
function getN005()
  // �����頥� ���ᨢ N005 �����䨪��� Metastasis (OnkM)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N005 - �����䨪��� Metastasis (OnkM)
  // ID_M,       'N',  4 // �����䨪��� M
  // DS_M,       'C',  5 // ������� �� ���
  // KOD_M,      'C',  5 // ������祭�� M ��� ��������
  // M_NAME,     'C',250 // �����஢�� M ��� ��������
  // DATEBEG,    'C',  10 // ��� ��砫� ����⢨� �����
  // DATEEND,    'C',  10 // ��� ����砭�� ����⢨� �����
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
// 27.08.23 ������ ���ᨢ ����� N006.xml ��ࠢ�筨� ᮮ⢥��⢨� �⠤�� TNM (OnkTNM)
function loadN006()
  // �����頥� ���ᨢ N006 ᮮ⢥��⢨� �⠤�� TNM (OnkTNM)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N006 - ���祭� ᮮ⢥��⢨� �⠤�� TNM (OnkTNM)
  // ID_gr,      'N',  4 // �����䨪��� ��ப�
  // DS_gr,      'C',  5 // ������� �� ���
  // ID_St,      'N',  4 // �����䨪��� �⠤��
  // ID_T,       'N',  4 // �����䨪��� T
  // ID_N,       'N',  4 // �����䨪��� N
  // ID_M,       'N',  4 // �����䨪��� M
  // DATEBEG,    'C',  10 // ��� ��砫� ����⢨� �����
  // DATEEND,    'C',  10 // ��� ����砭�� ����⢨� �����
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
// 27.08.23 ������ ���ᨢ ����� N007.xml �����䨪��� ���⮫����᪨� �ਧ����� (OnkMrf)
function getN007()
  // �����頥� ���ᨢ N007 ���⮫����᪨� �ਧ����� (OnkMrf)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N007 - ���祭� ���⮫����᪨� �ਧ����� (OnkMrf)
  // ID_Mrf,    'N',  2 // �����䨪��� ���⮫����᪮�� �ਧ����
  // Mrf_NAME,  'C',250 // ������������ ���⮫����᪮�� �ਧ����
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
// 12.09.23 ������ ���ᨢ ����� N008.xml �����䨪��� १���⮢ ���⮫����᪨� ��᫥������� (OnkMrfRt)
function loadN008()
  // �����頥� ���ᨢ N008 १���⮢ ���⮫����᪨� ��᫥������� (OnkMrfRt)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N008 - ���祭� १���⮢ ���⮫����᪨� ��᫥������� (OnkMrfRt)
  // ID_R_M,    'N',  3 // �����䨪��� �����
  // ID_Mrf,    'N',  2 // �����䨪��� ���⮫����᪮�� �ਧ���� � ᮮ⢥��⢨� � N007
  // R_M_NAME,  'C',250 // ������������ १���� ���⮫����᪮�� ��᫥�������
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
// 27.08.23 ������ ���ᨢ ����� N009.xml �����䨪��� ᮮ⢥��⢨� ���⮫����᪨� �ਧ����� ��������� (OnkMrtDS)
function getN009()
  // �����頥� ���ᨢ N009 ᮮ⢥��⢨� ���⮫����᪨� �ਧ����� ��������� (OnkMrtDS)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N009 - ���祭� ᮮ⢥��⢨� ���⮫����᪨� �ਧ����� ��������� (OnkMrtDS)
  // ID_M_D,     N,  2 // �����䨪��� ��ப�
  // DS_Mrf,     C,  3 // ������� �� ���
  // ID_Mrf,     N,  2 // �����䨪��� ���⮫����᪮�� �ਧ���� � ᮮ⢥��⢨� � N007
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
// 28.08.23 ������ ���ᨢ ����� N010.xml �����䨪��� ����஢ (OnkIgh)
function loadN010()
  // �����頥� ���ᨢ N010 �����䨪��� ����஢ (OnkIgh)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N010 - ���祭� ����஢ (OnkIgh)
  // ID_Igh,     N,   2 // �����䨪��� ��થ�
  // KOD_Igh,    C, 250 // ������祭�� ��થ�
  // Igh_NAME,   C, 250 // ������������ ��થ�
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
// 28.08.23 ������ ���ᨢ ����� N011.xml �����䨪��� ���祭�� ����஢ (OnkIghRt)
function loadN011()
  // �����頥� ���ᨢ N011 ���祭�� ����஢ (OnkIghRt)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N011 - ���祭� ���祭�� ����஢ (OnkIghRt)
  // ID_R_I,     N,   3 // �����䨪��� �����
  // ID_Igh,     N,   2 // �����䨪��� ��થ� � ᮮ⢥��⢨� � N010
  // KOD_R_I,    C, 250 // ������祭�� १����
  // R_I_NAME,   C, 250 // ������������ १����
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
// 28.08.23 ������ ���ᨢ ����� N012.xml �����䨪��� ᮮ⢥��⢨� ����஢ ��������� (OnkIghDS)
function loadN012()
  // �����頥� ���ᨢ N012 ᮮ⢥��⢨� ����஢ ��������� (OnkIghDS)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N012 - ���祭� ᮮ⢥��⢨� ����஢ ��������� (OnkIghDS)
  // ID_I_D,     N,  2 // �����䨪��� ��ப�
  // DS_Igh,     C,  3 // ������� �� ���
  // ID_Igh,     N,  2 // �����䨪��� ��થ� � ᮮ⢥��⢨� � N010
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
// 19.09.23 ������ ���ᨢ ����� N013.xml �����䨪��� ⨯�� ��祭�� (OnkLech)
function getN013()
  // �����頥� ���ᨢ N013 ⨯�� ��祭�� (OnkLech)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N013 - ���祭� ⨯�� ��祭�� (OnkLech)
  // ID_TLech,   N,   1 // �����䨪��� ⨯� ��祭��
  // TLech_NAME, C, 250 // ������������ ⨯� ��祭��
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
// 19.09.23 ������ ���ᨢ ����� N014.xml �����䨪��� ⨯�� ���ࣨ�᪮�� ��祭�� (OnkHir)
function getN014()
  // �����頥� ���ᨢ N014 ⨯�� ���ࣨ�᪮�� ��祭�� (OnkHir)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N014 - ���祭� ⨯�� ���ࣨ�᪮�� ��祭�� (OnkHir)
  // ID_THir,    N,   1 // �����䨪��� ⨯� ���ࣨ�᪮�� ��祭��
  // THir_NAME,  C, 250 // ������������ ⨯� ���ࣨ�᪮�� ��祭��
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
// 19.09.23 ������ ���ᨢ ����� N015.xml �����䨪��� ����� ������⢥���� �࠯�� (OnkLek_L)
function getN015()
  // �����頥� ���ᨢ N015 ����� ������⢥���� �࠯�� (OnkLek_L)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N015 - ���祭� ����� ������⢥���� �࠯�� (OnkLek_L)
  // ID_TLek_L,  N,   1 // �����䨪��� ����� ������⢥���� �࠯��
  // TLek_NAME_L,C, 250 // ������������ ����� ������⢥���� �࠯��
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
// 19.09.23 ������ ���ᨢ ����� N016.xml �����䨪��� 横��� ������⢥���� �࠯�� (OnkLek_V)
function getN016()
  // �����頥� ���ᨢ N016 横��� ������⢥���� �࠯�� (OnkLek_V)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N016 - ���祭� 横��� ������⢥���� �࠯�� (OnkLek_V)
  // ID_TLek_V,  N,   1 // �����䨪��� 横�� ������⢥���� �࠯��
  // TLek_NAME_V,C, 250 // ������������ 横�� ������⢥���� �࠯��
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
// 19.09.23 ������ ���ᨢ ����� N017.xml �����䨪��� ⨯�� ��祢�� �࠯�� (OnkLuch)
function getN017()
  // �����頥� ���ᨢ N017 ⨯�� ��祢�� �࠯�� (OnkLuch)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N017 - ���祭� ⨯�� ��祢�� �࠯�� (OnkLuch)
  // ID_TLuch,   N,   1 // �����䨪��� ⨯� ��祢�� �࠯��
  // TLuch_NAME, C, 250 // ������������ ⨯� ��祢�� �࠯��
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
// 19.09.23 ������ ���ᨢ ����� N018.xml �����䨪��� ������� ���饭�� (OnkReas)
function getN018()
  // �����頥� ���ᨢ N018 ������� ���饭�� (OnkReas)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N018 - ���祭� ������� ���饭�� (OnkReas)
  // ID_REAS,    N,   2 // �����䨪��� ������ ���饭��
  // REAS_NAME,  C, 300 // ������������ ������ ���饭��
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
// 19.09.23 ������ ���ᨢ ����� N019.xml �����䨪��� 楫�� ���ᨫ�㬠 (OnkCons)
function getN019()
  // �����頥� ���ᨢ N019 楫�� ���ᨫ�㬠 (OnkCons)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N019 - ���祭� 楫�� ���ᨫ�㬠 (OnkCons)
  // ID_CONS,    N,   1 // �����䨪��� 楫� ���ᨫ�㬠
  // CONS_NAME,  C, 300 // ������������ 楫� ���ᨫ�㬠
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
// 07.01.22 ������ ���ᨢ �� �ࠢ�筨�� ����� N020.xml
// �����䨪��� ������⢥���� �९��⮢, �ਬ��塞�� �� �஢������ ������⢥���� �࠯�� (OnkLekp)
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

// 07.01.22 ������ ��� ������⢥����� �९���
function get_Lek_pr_By_ID(id_lekp)
  local arr := loadN020()
  local ret

  if hb_hHaskey( arr, id_lekp )
    ret := arr[id_lekp][2]
  endif
  return ret

// =========== N021 ===================
//
// 28.08.23 ������ ���ᨢ ����� N021.xml
// �����䨪��� ᮮ⢥��⢨� ������⢥����� �९��� �奬� ������⢥���� �࠯�� (OnkLpsh)
function loadN021()
  // �����頥� ���ᨢ N021 ᮮ⢥��⢨� ������⢥����� �९��� �奬� ������⢥���� �࠯�� (OnkLpsh)
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N021 - ���祭� ᮮ⢥��⢨� ������⢥����� �९��� �奬� ������⢥���� �࠯�� (OnkLpsh)
  // ID_ZAP,     N,   4 // �����䨪��� ����� (� ���ᠭ�� Char 15)
  // CODE_SH,    C,  10 // ��� �奬� ������⢥���� �࠯��
  // ID_LEKP,    C,   6 // �����䨪��� ������⢥����� �९���, �ਬ��塞��� �� �஢������ ������⢥���� ��⨢����宫���� �࠯��. ���������� � ᮮ⢥��⢨� � N020
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