#include 'hbhash.ch'
#include 'function.ch'
#include 'chip_mo.ch'
#include 'edit_spr.ch'

#require 'hbsqlit3'

// =========== T005 ===================
//
// 19.05.23 ������ ���ᨢ �訡�� ����� T005.dbf
Function loadt005()

  // �����頥� ���ᨢ �訡�� T005
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // T005 - ���祭� �訡�� �����
  // 1 - code(3)  2 - error(C) 3 - opis(M)
  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'code, ' + ;
      'error, ' + ;
      'opis ' + ;
      'FROM t005' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 3 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil

    // ������� �� �ࠢ�筨�� _mo_f014.dbf
    For Each row in getf014()
      If ( j := AScan( _arr, {| x| x[ 1 ] == row[ 1 ] } ) ) == 0
        AAdd( _arr, { row[ 1 ], AllTrim( row[ 2 ] ), AllTrim( row[ 3 ] ) } )
      Endif
    Next
  Endif

  Return _arr

// 04.08.21 ������ ��ப� ��� ���� ��䥪� � ���ᠭ��� �訡�� ����� �� �ࠢ�筨�� T005.dbf
Function ret_t005( lkod )

  Local arrErrors := loadt005()
  Local row := {}

  For Each row in arrErrors
    If row[ 1 ] == lkod
      Return '(' + lstr( row[ 1 ] ) + ') ' + row[ 2 ] + ', [' + row[ 3 ] + ']'
    Endif
  Next

  Return '�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + Str( lkod )

// 28.06.22 ������ ��ப� ��� ���� ��䥪� � ���ᠭ��� �訡�� ����� �� �ࠢ�筨�� T005.dbf
Function ret_t005_smol( lkod )

  Local arrErrors := loadt005()
  Local row := {}

  For Each row in arrErrors
    If row[ 1 ] == lkod
      Return '(' + lstr( row[ 1 ] ) + ') ' + row[ 2 ]
    Endif
  Next

  Return '�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + Str( lkod )

// 05.08.21 ������ ���ᨢ ����⥫� �訡�� ��� ���� ��䥪� � ���ᠭ��� �訡�� ����� �� �ࠢ�筨�� T005.dbf
Function retarr_t005( lkod, isEmpty )

  Local arrErrors := loadt005()
  Local row := {}

  Default isEmpty To .f.
  For Each row in arrErrors
    If row[ 1 ] == lkod
      Return row
    Endif
  Next

  Return iif( isEmpty, {}, { '�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + Str( lkod ), '', '' } )

// =========== T007 ===================
//
// 02.06.23 ������ ���ᨢ ����� T007.dbf
Function loadt007()

  // �����頥� ���ᨢ T007
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI

  // T007 - ���祭�
  // PROFIL_K,  N,  2
  // PK_V020,   N,  2
  // PROFIL,    N,  2
  // NAME,      C,  255
  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'profil_k, ' + ;
      'pk_v020, ' + ;
      'profil, ' + ;
      'name ' + ;
      'FROM t007' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), Val( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ) } )
      Next
    Endif
    db := nil
  Endif

  Return _arr

// 04.06.23 ���ᨢ T007 ��� �롮�
Function arr_t007()

  Static arr
  Static time_load
  Local arrT007 := loadt007()
  Local row

  If timeout_load( @time_load )
    arr := {}
    For Each row in arrT007
      If AScan( arr, {| x| x[ 2 ] == row[ 1 ] } ) == 0
        AAdd( arr, { AllTrim( row[ 4 ] ), row[ 1 ], row[ 2 ] } )
      Endif
    Next
  Endif

  Return arr

// 02.06.23 ������ ���ᨢ ��䨫�� ���. �����
Function ret_arr_v002_profil_k_t007( lprofil_k )

  Local arrT007 := loadt007()
  Local arr := {}, row := {}

  For Each row in arrT007
    If row[ 1 ] == lprofil_k
      AAdd( arr, { inieditspr( A__MENUVERT, getv002(), row[ 3 ] ), row[ 3 ] } )
    Endif
  Next

  Return arr

// =========== T008 ===================
//
// 23.10.22 ������ ���� �訡�� � ��⮪���� ��ࠡ�⪨ ���.����⮢ T008.xml
Function gett008()

  // T008.xml - ���� �訡�� � ��⮪���� ��ࠡ�⪨ ���.����⮢
  // 1 - NAME (C), 2 - CODE (N), 3 - NAME_F (C), 4 - DATE_B (D), 5 - DATE_E (D)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { '���� 㦥 �� ����㦥�', 0, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '���� �� ᮮ⢥����� xsd-�奬�', 1, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४⭮� ��⠭�� ����� �� (codeM � Mcod)', 2, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४�� ��� ��䨫�', 3, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४�� ��� ��䨫� �����', 4, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४�� ��� ��������', 5, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४⭠� �ଠ �������� �� (V014)', 6, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४�� ⨯ ���㬥�� (F008)', 7, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४�� ��� (V005)', 8, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४�� ॥��஢� ��� �� �ਤ��᪮�� ���', 9, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४�� ॣ����樮��� ��� �� �� �����', 10, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '������� ���ࠢ����� ��� � �믨ᠭ���', 11, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४�� ��� ��稭� ���㫨஢����', 12, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४�� ॥��஢� ��� ���', 13, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '��䨫� ����� �� ᮮ⢥����� ��䨫� ��', 14, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�����४⭠� ��� ��ᯨ⠫���樨', 15, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '������ �� ������� ���ࠢ����� 㦥 �뫠 ����㦥��', 16, '', SToD( '20140701' ), SToD( '22220101' ) } )
    AAdd( _arr, { '���������� ᢥ����� � �믮������� ��ꥬ�� ��� ���', 17, '', SToD( '20160915' ), SToD( '22220101' ) } )
    AAdd( _arr, { '���⭠� ��� �⫨筠 �� ⥪�饩', 18, '', SToD( '20170220' ), SToD( '22220101' ) } )
    AAdd( _arr, { '����襭� 㭨���쭮��� ID_D', 19, '', SToD( '20180829' ), SToD( '22220101' ) } )
    AAdd( _arr, { '��� � ����� 䠩�� �� ᮮ⢥����� DATE_R', 20, '', SToD( '20180907' ), SToD( '22220101' ) } )
    AAdd( _arr, { '��� � ����� �� ᮮ⢥����� DATE_R', 21, '', SToD( '20180907' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�ॢ�襭 �ப ����⢨� ���ࠢ����� (30 ����)', 22, '', SToD( '20180907' ), SToD( '22220101' ) } )
    AAdd( _arr, { '�訡�� � ��㣨� ������� 䠩��', 999, '', SToD( '20140701' ), SToD( '22220101' ) } )
  Endif

  Return _arr

// =========== T012 ===================
//
// 26.12.22 ������ ���ᠭ�� �訡�� �� �����䨪��� �訡�� ����� ISDErr.xml
Function geterror_t012( code )

  Static arr
  Local db
  Local aTable
  Local nI
  Local s := '�訡�� ' + lstr( code ) + ': '

  If arr == nil
    arr := hb_Hash()

    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT code, name FROM isderr' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        hb_HSet( arr, Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ) )
      Next
    Endif
    db := nil
  Endif

  If hb_HHasKey( arr, code )
    s += AllTrim( arr[ code ] )
  Else
    s += '(�������⭠� �訡��)'
  Endif

  Return s