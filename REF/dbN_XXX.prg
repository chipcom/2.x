#include 'hbhash.ch'
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// =========== N001 ===================
//
// 05.09.23 ������ ���ᨢ ����� N001.xml
Function getn001()

  // �����頥� ���ᨢ N001 ��⨢���������� � �⪠��� (OnkPrOt)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N001 - ���祭� ��⨢���������� � �⪠��� (OnkPrOt)
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

// =========== N002 ===================
//
// 09.09.23 ������ ���ᨢ ����� N002.xml
Function getn002()

  // �����頥� ���ᨢ N002 �����䨪��� �⠤�� (OnkStad)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N002 - �����䨪��� �⠤�� (OnkStad)
  // ID_St,      'N',  4 // �����䨪��� �⠤��
  // DS_St,      'C',  5 // ������� �� ���
  // KOD_St,     'C',  5 // �⠤��
  // DATEBEG,    'C',  10 // ��� ��砫� ����⢨� �����
  // DATEEND,    'C',  10 // ��� ����砭�� ����⢨� �����
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

// 09.09.23
Function getds_n002()

  Static aStadii
  Static time_load
  Local row, it, i := 0

  If timeout_load( @time_load )
    aStadii := {}
    For Each row in getn002()
      If ! Empty( row[ 5 ] )
        Loop
      Endif
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
  Endif

  Return aStadii

// =========== N003 ===================
//
// 09.09.23 ������ ���ᨢ ����� N003.xml
Function getn003()

  // �����頥� ���ᨢ N003 �����䨪��� Tumor (OnkT)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N003 - �����䨪��� Tumor (OnkT)
  // ID_T,       'N',  4  // �����䨪��� T
  // DS_T,       'C',  5  // ������� �� ���
  // KOD_T,      'C',  5  // ������祭�� T ��� ��������
  // T_NAME,     'C', 250 // �����஢�� T ��� ��������
  // DATEBEG,    'C',  10 // ��� ��砫� ����⢨� �����
  // DATEEND,    'C',  10 // ��� ����砭�� ����⢨� �����
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

// 09.09.23
Function getds_n003()

  Static aTumor
  Static time_load
  Local row, it, i := 0

  If timeout_load( @time_load )
    aTumor := {}
    For Each row in getn003()
      If ! Empty( row[ 6 ] )
        Loop
      Endif
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
  Endif

  Return aTumor

// =========== N004 ===================
//
// 09.09.23 ������ ���ᨢ ����� N004.xml
Function getn004()

  // �����頥� ���ᨢ N004 �����䨪��� Nodus (OnkN)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N004 - �����䨪��� Nodus (OnkN)
  // ID_N,       'N',  4 // �����䨪��� N
  // DS_N,       'C',  5 // ������� �� ���
  // KOD_N,      'C',  5 // ������祭�� N ��� ��������
  // N_NAME,     'C',500 // �����஢�� N ��� ��������
  // DATEBEG,    'C',  10 // ��� ��砫� ����⢨� �����
  // DATEEND,    'C',  10 // ��� ����砭�� ����⢨� �����
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

// 09.09.23
Function getds_n004()

  Static aNodus
  Static time_load
  Local row, it, i := 0

  If timeout_load( @time_load )
    aNodus := {}
    For Each row in getn004()
      If ! Empty( row[ 6 ] )
        Loop
      Endif
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
  Endif

  Return aNodus

// =========== N005 ===================
//
// 09.09.23 ������ ���ᨢ ����� N005.xml
Function getn005()

  // �����頥� ���ᨢ N005 �����䨪��� Metastasis (OnkM)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N005 - �����䨪��� Metastasis (OnkM)
  // ID_M,       'N',  4 // �����䨪��� M
  // DS_M,       'C',  5 // ������� �� ���
  // KOD_M,      'C',  5 // ������祭�� M ��� ��������
  // M_NAME,     'C',250 // �����஢�� M ��� ��������
  // DATEBEG,    'C',  10 // ��� ��砫� ����⢨� �����
  // DATEEND,    'C',  10 // ��� ����砭�� ����⢨� �����
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

// 09.09.23
Function getds_n005()

  Static aMetastasis
  Static time_load
  Local row, it, i := 0

  If timeout_load( @time_load )
    aMetastasis := {}
    For Each row in getn005()
      If ! Empty( row[ 6 ] )
        Loop
      Endif
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
  Endif

  Return aMetastasis

// =========== N006 ===================
//
// 27.08.23 ������ ���ᨢ ����� N006.xml ��ࠢ�筨� ᮮ⢥��⢨� �⠤�� TNM (OnkTNM)
Function loadn006()

  // �����頥� ���ᨢ N006 ᮮ⢥��⢨� �⠤�� TNM (OnkTNM)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N006 - ���祭� ᮮ⢥��⢨� �⠤�� TNM (OnkTNM)
  // ID_gr,      'N',  4 // �����䨪��� ��ப�
  // DS_gr,      'C',  5 // ������� �� ���
  // ID_St,      'N',  4 // �����䨪��� �⠤��
  // ID_T,       'N',  4 // �����䨪��� T
  // ID_N,       'N',  4 // �����䨪��� N
  // ID_M,       'N',  4 // �����䨪��� M
  // DATEBEG,    'C',  10 // ��� ��砫� ����⢨� �����
  // DATEEND,    'C',  10 // ��� ����砭�� ����⢨� �����
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
// 27.08.23 ������ ���ᨢ ����� N007.xml �����䨪��� ���⮫����᪨� �ਧ����� (OnkMrf)
Function getn007()

  // �����頥� ���ᨢ N007 ���⮫����᪨� �ਧ����� (OnkMrf)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N007 - ���祭� ���⮫����᪨� �ਧ����� (OnkMrf)
  // ID_Mrf,    'N',  2 // �����䨪��� ���⮫����᪮�� �ਧ����
  // Mrf_NAME,  'C',250 // ������������ ���⮫����᪮�� �ਧ����
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
// 12.09.23 ������ ���ᨢ ����� N008.xml �����䨪��� १���⮢ ���⮫����᪨� ��᫥������� (OnkMrfRt)
Function loadn008()

  // �����頥� ���ᨢ N008 १���⮢ ���⮫����᪨� ��᫥������� (OnkMrfRt)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N008 - ���祭� १���⮢ ���⮫����᪨� ��᫥������� (OnkMrfRt)
  // ID_R_M,    'N',  3 // �����䨪��� �����
  // ID_Mrf,    'N',  2 // �����䨪��� ���⮫����᪮�� �ਧ���� � ᮮ⢥��⢨� � N007
  // R_M_NAME,  'C',250 // ������������ १���� ���⮫����᪮�� ��᫥�������
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
// 27.08.23 ������ ���ᨢ ����� N009.xml �����䨪��� ᮮ⢥��⢨� ���⮫����᪨� �ਧ����� ��������� (OnkMrtDS)
Function getn009()

  // �����頥� ���ᨢ N009 ᮮ⢥��⢨� ���⮫����᪨� �ਧ����� ��������� (OnkMrtDS)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N009 - ���祭� ᮮ⢥��⢨� ���⮫����᪨� �ਧ����� ��������� (OnkMrtDS)
  // ID_M_D,     N,  2 // �����䨪��� ��ப�
  // DS_Mrf,     C,  3 // ������� �� ���
  // ID_Mrf,     N,  2 // �����䨪��� ���⮫����᪮�� �ਧ���� � ᮮ⢥��⢨� � N007
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
// 28.08.23 ������ ���ᨢ ����� N010.xml �����䨪��� ����஢ (OnkIgh)
Function loadn010()

  // �����頥� ���ᨢ N010 �����䨪��� ����஢ (OnkIgh)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N010 - ���祭� ����஢ (OnkIgh)
  // ID_Igh,     N,   2 // �����䨪��� ��થ�
  // KOD_Igh,    C, 250 // ������祭�� ��થ�
  // Igh_NAME,   C, 250 // ������������ ��થ�
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
// 28.08.23 ������ ���ᨢ ����� N011.xml �����䨪��� ���祭�� ����஢ (OnkIghRt)
Function loadn011()

  // �����頥� ���ᨢ N011 ���祭�� ����஢ (OnkIghRt)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N011 - ���祭� ���祭�� ����஢ (OnkIghRt)
  // ID_R_I,     N,   3 // �����䨪��� �����
  // ID_Igh,     N,   2 // �����䨪��� ��થ� � ᮮ⢥��⢨� � N010
  // KOD_R_I,    C, 250 // ������祭�� १����
  // R_I_NAME,   C, 250 // ������������ १����
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
// 28.08.23 ������ ���ᨢ ����� N012.xml �����䨪��� ᮮ⢥��⢨� ����஢ ��������� (OnkIghDS)
Function loadn012()

  // �����頥� ���ᨢ N012 ᮮ⢥��⢨� ����஢ ��������� (OnkIghDS)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N012 - ���祭� ᮮ⢥��⢨� ����஢ ��������� (OnkIghDS)
  // ID_I_D,     N,  2 // �����䨪��� ��ப�
  // DS_Igh,     C,  3 // ������� �� ���
  // ID_Igh,     N,  2 // �����䨪��� ��થ� � ᮮ⢥��⢨� � N010
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
// 19.09.23 ������ ���ᨢ ����� N013.xml �����䨪��� ⨯�� ��祭�� (OnkLech)
Function getn013()

  // �����頥� ���ᨢ N013 ⨯�� ��祭�� (OnkLech)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N013 - ���祭� ⨯�� ��祭�� (OnkLech)
  // ID_TLech,   N,   1 // �����䨪��� ⨯� ��祭��
  // TLech_NAME, C, 250 // ������������ ⨯� ��祭��
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
// 19.09.23 ������ ���ᨢ ����� N014.xml �����䨪��� ⨯�� ���ࣨ�᪮�� ��祭�� (OnkHir)
Function getn014()

  // �����頥� ���ᨢ N014 ⨯�� ���ࣨ�᪮�� ��祭�� (OnkHir)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N014 - ���祭� ⨯�� ���ࣨ�᪮�� ��祭�� (OnkHir)
  // ID_THir,    N,   1 // �����䨪��� ⨯� ���ࣨ�᪮�� ��祭��
  // THir_NAME,  C, 250 // ������������ ⨯� ���ࣨ�᪮�� ��祭��
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
// 19.09.23 ������ ���ᨢ ����� N015.xml �����䨪��� ����� ������⢥���� �࠯�� (OnkLek_L)
Function getn015()

  // �����頥� ���ᨢ N015 ����� ������⢥���� �࠯�� (OnkLek_L)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N015 - ���祭� ����� ������⢥���� �࠯�� (OnkLek_L)
  // ID_TLek_L,  N,   1 // �����䨪��� ����� ������⢥���� �࠯��
  // TLek_NAME_L,C, 250 // ������������ ����� ������⢥���� �࠯��
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
// 19.09.23 ������ ���ᨢ ����� N016.xml �����䨪��� 横��� ������⢥���� �࠯�� (OnkLek_V)
Function getn016()

  // �����頥� ���ᨢ N016 横��� ������⢥���� �࠯�� (OnkLek_V)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N016 - ���祭� 横��� ������⢥���� �࠯�� (OnkLek_V)
  // ID_TLek_V,  N,   1 // �����䨪��� 横�� ������⢥���� �࠯��
  // TLek_NAME_V,C, 250 // ������������ 横�� ������⢥���� �࠯��
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
// 19.09.23 ������ ���ᨢ ����� N017.xml �����䨪��� ⨯�� ��祢�� �࠯�� (OnkLuch)
Function getn017()

  // �����頥� ���ᨢ N017 ⨯�� ��祢�� �࠯�� (OnkLuch)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N017 - ���祭� ⨯�� ��祢�� �࠯�� (OnkLuch)
  // ID_TLuch,   N,   1 // �����䨪��� ⨯� ��祢�� �࠯��
  // TLuch_NAME, C, 250 // ������������ ⨯� ��祢�� �࠯��
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
// 19.09.23 ������ ���ᨢ ����� N018.xml �����䨪��� ������� ���饭�� (OnkReas)
Function getn018()

  // �����頥� ���ᨢ N018 ������� ���饭�� (OnkReas)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N018 - ���祭� ������� ���饭�� (OnkReas)
  // ID_REAS,    N,   2 // �����䨪��� ������ ���饭��
  // REAS_NAME,  C, 300 // ������������ ������ ���饭��
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
// 19.09.23 ������ ���ᨢ ����� N019.xml �����䨪��� 楫�� ���ᨫ�㬠 (OnkCons)
Function getn019()

  // �����頥� ���ᨢ N019 楫�� ���ᨫ�㬠 (OnkCons)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // N019 - ���祭� 楫�� ���ᨫ�㬠 (OnkCons)
  // ID_CONS,    N,   1 // �����䨪��� 楫� ���ᨫ�㬠
  // CONS_NAME,  C, 300 // ������������ 楫� ���ᨫ�㬠
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
// 28.09.22 ������ ���ᨢ �� �ࠢ�筨�� ����� N020.xml
// �����䨪��� ������⢥���� �९��⮢, �ਬ��塞�� �� �஢������ ������⢥���� �࠯�� (OnkLekp)
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

// 07.01.22 ������ ��� ������⢥����� �९���
Function get_lek_pr_by_id( id_lekp )

  Local arr := loadn020()
  Local ret

  If hb_HHasKey( arr, id_lekp )
    ret := arr[ id_lekp ][ 2 ]
  Endif

  Return ret

// 29.09.23
Function getn020( dk )

  Static stYear
  Static _arr
  Local db
  Local aTable, row
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
  Else
    Return {}
  Endif

  If ISNIL( stYear ) .or. Empty( _arr ) .or. year_dk != stYear
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, "SELECT " + ;
      'id_lekp, ' + ;
      'mnn, ' + ;
      "datebeg, " + ;
      "dateend " + ;
      "FROM n020 " + ;
      "WHERE datebeg <= " + dBeg + ;
      "AND dateend >= " + dEnd )
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
// 18.12.24 ������ ���ᨢ ����� N021.xml
// �����䨪��� ᮮ⢥��⢨� ������⢥����� �९��� �奬� ������⢥���� �࠯�� (OnkLpsh)
Function loadn021()

  // �����頥� ���ᨢ N021 ᮮ⢥��⢨� ������⢥����� �९��� �奬� ������⢥���� �࠯�� (OnkLpsh)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI, dBeg, dEnd

  // N021 - ���祭� ᮮ⢥��⢨� ������⢥����� �९��� �奬� ������⢥���� �࠯�� (OnkLpsh)
  // ID_ZAP,     N,   4 // �����䨪��� ����� (� ���ᠭ�� Char 15)
  // CODE_SH,    C,  10 // ��� �奬� ������⢥���� �࠯��
  // ID_LEKP,    C,   6 // �����䨪��� ������⢥����� �९���, �ਬ��塞��� �� �஢������ ������⢥���� ��⨢����宫���� �࠯��. ���������� � ᮮ⢥��⢨� � N020
  // DATEBEG,    C,  10
  // DATEEND,    C,  10
  // ��������� 16.12.24
  // LEKP_EXT,    C, 150, 0 // ����७�� �����䨪��� ��� ���. �९��� � 㪠������ ��� ��������
  // ID_LEKP_EXT, C,  25,0  // ��� ���७���� �����䨪��� ��� ���. �९��� � 㪠������ ��� ��������
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

// 18.12.24
Function getn021( dk )

  Static stYear
  Static _arr
  Local db
  Local aTable
  Local nI, dBeg, dEnd
  Local year_dk

  If ValType( dk ) == 'N'
    dBeg := "'" + Str( dk, 4 ) + "-01-01'"// 00:00:00'"
    dEnd := "'" + Str( dk, 4 ) + "-12-31'"// 00:00:00'"
    year_dk := dk
  Elseif ValType( dk ) == 'D'
    year_dk := Year( dk )
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    dBeg := "'" + DToS( dk ) + "'"  // "-01-01 00:00:00'"
    dEnd := "'" + DToS( dk ) + "'"  // "-12-31 00:00:00'"
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
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
      "FROM n021 " + ;
      "WHERE DATE(datebeg) <= " + dBeg + ;
      "AND DATE(dateend) >= " + dEnd )
    // "WHERE datebeg <= " + dBeg + ;
    // "AND dateend >= " + dEnd)
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
        dBeg := CToD( aTable[ nI, 4 ] )
        dEnd := CToD( aTable[ nI, 5 ] )
        Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), PadR( aTable[ nI, 2 ], 10 ), PadR( aTable[ nI, 3 ], 6 ), dBeg, dEnd, AllTrim( aTable[ nI, 6 ] ), AllTrim( aTable[ nI, 7 ] ) } )
      Next
    Endif
    db := nil
    stYear := year_dk
  Endif
  Return _arr