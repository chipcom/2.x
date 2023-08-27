#include 'hbhash.ch' 
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// =========== N001 ===================
//
// 27.08.23 ������ ���ᨢ ����� N001.xml
function loadN001()
  // �����頥� ���ᨢ N001
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N001 - ���祭�
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
// 27.08.23 ������ ���ᨢ ����� N002.xml
function loadN002()
  // �����頥� ���ᨢ N002
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N002 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N003 ===================
//
// 27.08.23 ������ ���ᨢ ����� N003.xml
function loadN003()
  // �����頥� ���ᨢ N003
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N003 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N004 ===================
//
// 27.08.23 ������ ���ᨢ ����� N004.xml
function loadN004()
  // �����頥� ���ᨢ N004
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N004 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N005 ===================
//
// 27.08.23 ������ ���ᨢ ����� N005.xml
function loadN005()
  // �����頥� ���ᨢ N005
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N005 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N006 ===================
//
// 27.08.23 ������ ���ᨢ ����� N006.xml
function loadN006()
  // �����頥� ���ᨢ N006
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N006 - ���祭�
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
// 27.08.23 ������ ���ᨢ ����� N007.xml
function loadN007()
  // �����頥� ���ᨢ N007
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N007 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2])}) //, val(aTable[nI, 3]), alltrim(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N008 ===================
//
// 27.08.23 ������ ���ᨢ ����� N008.xml
function loadN008()
  // �����頥� ���ᨢ N008
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N008 - ���祭�
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

// =========== N009 ===================
//
// 27.08.23 ������ ���ᨢ ����� N009.xml
function loadN009()
  // �����頥� ���ᨢ N009
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N009 - ���祭�
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

// =========== N020 ===================
//
// 07.01.22 ������ ���ᨢ �� �ࠢ�筨�� ����� N020.xml - 
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