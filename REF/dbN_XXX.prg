#include 'hbhash.ch' 
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// =========== N001 ===================
//
// 05.09.23 ������ ���ᨢ ����� N001.xml
function getN001()
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
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1])}) //, val(aTable[nI, 3]), alltrim(aTable[nI, 4])})
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

// =========== N010 ===================
//
// 28.08.23 ������ ���ᨢ ����� N010.xml
function loadN010()
  // �����頥� ���ᨢ N010
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N010 - ���祭�
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
// 28.08.23 ������ ���ᨢ ����� N011.xml
function loadN011()
  // �����頥� ���ᨢ N011
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N011 - ���祭�
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

// =========== N012 ===================
//
// 28.08.23 ������ ���ᨢ ����� N012.xml
function loadN012()
  // �����頥� ���ᨢ N012
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N012 - ���祭�
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

// =========== N013 ===================
//
// 28.08.23 ������ ���ᨢ ����� N013.xml
function loadN013()
  // �����頥� ���ᨢ N013
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N013 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N014 ===================
//
// 28.08.23 ������ ���ᨢ ����� N014.xml
function loadN014()
  // �����頥� ���ᨢ N014
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N014 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N015 ===================
//
// 28.08.23 ������ ���ᨢ ����� N015.xml
function loadN015()
  // �����頥� ���ᨢ N015
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N015 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N016 ===================
//
// 28.08.23 ������ ���ᨢ ����� N016.xml
function loadN016()
  // �����頥� ���ᨢ N016
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N016 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N017 ===================
//
// 28.08.23 ������ ���ᨢ ����� N017.xml
function loadN017()
  // �����頥� ���ᨢ N017
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N017 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N018 ===================
//
// 28.08.23 ������ ���ᨢ ����� N018.xml
function loadN018()
  // �����頥� ���ᨢ N018
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N018 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
  endif
  return _arr

// =========== N019 ===================
//
// 28.08.23 ������ ���ᨢ ����� N019.xml
function loadN019()
  // �����頥� ���ᨢ N019
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N019 - ���祭�
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
        aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
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

// =========== N021 ===================
//
// 28.08.23 ������ ���ᨢ ����� N021.xml
function loadN021()
  // �����頥� ���ᨢ N021
  static _arr
  static time_load
  local db
  local aTable, row
  local nI

  // N021 - ���祭�
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

