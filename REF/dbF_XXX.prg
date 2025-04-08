#include 'inkey.ch'
#include 'function.ch'
#include 'common.ch'
#include 'edit_spr.ch'
#include "chip_mo.ch"

#include 'tbox.ch'

#require 'hbsqlit3'

// =========== F003 ===================
//
// 14.10.24 {_MO_KOD_TFOMS,_MO_SHORT_NAME}
Function viewf003()

  Local nTop, nLeft, nBottom, nRight
  Local tmp_select := Select()
  Local l := 0, fl
  Local ar, aStruct, dbName := '_mo_f003', indexName := cur_dir + dbName
  Local color_say := 'N/W', color_get := 'W/N*'
  Local oBox, oBoxRegion
  Local strRegion := '�롮� ॣ����'
  Local lFileCreated := .f.
  Local retMCOD := { '', Space( 10 ) }
  Local ar_f010 := getf010()
  Local selectedRegion := '34'
  Local sbase := 'mo_add'
  Local prev_codem := 0, cur_codem := 0

  Private nRegion := 34
  Private tmpName := cur_dir + 'tmp_F003', tmpAlias := 'tF003'
  Private oBoxCompany
  Private fl_space := .f., fl_other_region := .f.

  ar := {}
  For i := 1 To Len( ar_f010 )
    AAdd( ar, ar_f010[ i, 1 ] )
    l := Max( l, Len( ar[ i ] ) )
  Next

  dbUseArea( .t., 'DBFNTX', dir_exe() + dbName, dbName, .t., .f. )
  aStruct := ( dbName )->( dbStruct() )
  ( dbName )->( dbCreateIndex( indexName, 'substr(MCOD,1,2)', , NIL ) )

  nTop := 4
  nLeft := 3
  nBottom := 23
  nRight := 77

  // ���� �롮� ॣ����
  oBoxRegion := tbox():new( nTop, nLeft, nBottom, nRight )
  oBoxRegion:Caption := '�롥�� ॣ���'
  oBoxRegion:Frame := BORDER_SINGLE

  // ���� ������� ������������ �࣠����樨
  oBoxCompany := tbox():new( 19, 11, 21, 68 )
  oBoxCompany:Frame := BORDER_NONE
  oBoxCompany:Color := color5

  // ������� ����
  oBox := Nil // 㭨�⮦�� ����
  oBox := tbox():new( 2, 10, 22, 70 )
  oBox:Color := color_say + ',' + color_get
  oBox:Frame := BORDER_DOUBLE
  oBox:MessageLine := '^^ ��� ���.�㪢� - ��ᬮ��;  ^<Esc>^ - ��室;  ^<Enter>^ - �롮�'
  oBox:Save := .t.

  oBoxRegion:MessageLine := '^^ ��� ���.�㪢� - ��ᬮ��;  ^<Esc>^ - ��室;  ^<Enter>^ - �롮�'
  oBoxRegion:Save := .t.
  oBoxRegion:view()
  nRegion := AChoice( oBoxRegion:Top + 1, oBoxRegion:Left + 1, oBoxRegion:Bottom -1, oBoxRegion:Right - 1, ar, , , 34 )
  If nRegion == 0
    ( dbName )->( dbCloseArea() )
    ( tmpAlias )->( dbCloseArea() )
    Select ( tmp_select )
    Return retMCOD
  Else
    selectedRegion  := ar_f010[ nRegion, 2 ]
  Endif
  fl_other_region := .f.

  // ᮧ����� �६���� 䠩� ��� �⡮� �࣠����権 ��࠭���� ॣ����
  dbCreate( tmpName, aStruct )
  dbUseArea( .t.,, tmpName, tmpAlias, .t., .f. )

  ( dbName )->( dbGoTop() )
  ( dbName )->( dbSeek( selectedRegion ) )
  Do While SubStr( ( dbName )->MCOD, 1, 2 ) == selectedRegion
    ( tmpAlias )->( dbAppend() )
    ( tmpAlias )->MCOD := ( dbName )->MCOD
    ( tmpAlias )->NAMEMOK := ( dbName )->NAMEMOK
    ( tmpAlias )->NAMEMOP := ( dbName )->NAMEMOP
    ( tmpAlias )->ADDRESS := ( dbName )->ADDRESS
    ( tmpAlias )->YEAR := ( dbName )->YEAR

    ( dbName )->( dbSkip() )
  Enddo

  oBox:Caption := '�롮� ���ࠢ��襩 �࣠����樨'
  oBox:view()
  dbCreateIndex( tmpName, 'NAMEMOK', , NIL )

  ( tmpAlias )->( dbGoTop() )
  If fl := alpha_browse( oBox:Top + 1, oBox:Left + 1, oBox:Bottom -5, oBox:Right - 1, 'ColumnF003', color0, , , , , , 'ViewRecordF003', 'controlF003', , { '�', '�', '�', 'N/BG, W+/N, B/BG, BG+/B' } )
    // �஢��塞 �롮�
    If ( ifi := hb_AScan( glob_arr_mo, {| x| x[ _MO_KOD_FFOMS ] == ( tmpAlias )->MCOD }, , , .t. ) ) > 0
      // ��諨 � 䠩��
      Alert( '����樭᪮� ��०����� 㦥 ��������� � �ࠢ�筨�!' )
    Else
      If g_use( dir_server + sbase, dir_server + sbase, sbase, , .t., )
        ( sbase )->( dbGoTop() )
        Do While ! ( sbase )->( Eof() )
          prev_codem := ( sbase )->CODEM
          ( sbase )->( dbSkip() )
          cur_codem := ( sbase )->CODEM
          If ( Val( cur_codem ) - Val( prev_codem ) ) != 1
            ( sbase )->( dbAppend() )
            ( sbase )->MCOD := ( tmpAlias )->MCOD
            ( sbase )->CODEM := Str( Val( prev_codem ) + 1, 6 )
            ( sbase )->NAMEF := ( tmpAlias )->NAMEMOK
            ( sbase )->NAMES := ( tmpAlias )->NAMEMOP
            ( sbase )->ADRES := ( tmpAlias )->ADDRESS
            ( sbase )->DEND := hb_SToD( '20251231' )
            Exit
          Endif
        Enddo
        ( sbase )->( dbCloseArea() )
        retMCOD := { Str( Val( prev_codem ) + 1, 6 ), AllTrim( ( tmpAlias )->NAMEMOK ) }
      Endif
    Endif

  Endif
  selectedRegion := ''

  oBoxRegion := NIL
  oBoxCompany := nil
  oBox := nil
  ( tmpAlias )->( dbCloseArea() )
  ( dbName )->( dbCloseArea() )
  Select ( tmp_select )

  Return retMCOD

// 15.10.21
Function controlf003( nkey, oBrow )

  Local ret := -1, cCode, rec

  Return ret

// 15.10.21
Function columnf003( oBrow )

  Local oColumn

  oColumn := TBColumnNew( Center( '������������', 50 ), {|| Left( ( tmpAlias )->NAMEMOK, 50 ) } )
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ - ��室; ^<Enter>^ - �롮�' )

  Return Nil

// 21.01.21
Function viewrecordf003()

  Local i, arr := {}, count

  If ! oBoxCompany:Visible
    oBoxCompany:view()
  Else
    oBoxCompany:clear()
  Endif
  // ࠧ��쥬 ������ ����������� �� �����ப�
  // perenos(arr,(tmpAlias)->NAMEMOP,50)
  perenos( arr, ( tmpAlias )->NAMEMOP, oBoxCompany:Width )
  count := iif( Len( arr ) > oBoxCompany:Height, oBoxCompany:Height, Len( arr ) )

  For i := 1 To count
    @ oBoxCompany:Top + i - 1, oBoxCompany:Left + 1 Say arr[ i ]
  Next

  Return Nil

// 14.10.24
Function getf003mo( mCode )

  // mCode - ��� �� �� F003
  Local arr, dbName := '_mo_f003', indexName := cur_dir + dbName + 'cod'
  Local tmp_select := Select()
  Local i // ����� ��ࢮ� �� ���浪� ��

  If SubStr( mCode, 1, 2 ) != '34'

    arr := AClone( glob_arr_mo[ 1 ] )
    If Empty( mCode ) .or. ( Len( mCode ) != 6 )
      For i := 1 To Len( arr )
        If ValType( arr[ i ] ) == 'C'
          arr[ i ] := Space( 6 ) // � ���⨬ ��ப��� ������
        Endif
      Next
      Select( tmp_select )
      Return arr
    Endif

    arr := Array( _MO_LEN_ARR )

    dbUseArea( .t., 'DBFNTX', dir_exe() + dbName, dbName, .t., .f. )
    ( dbName )->( dbCreateIndex( indexName, 'MCOD', , NIL ) )

    ( dbName )->( dbGoTop() )
    If ( dbName )->( dbSeek( mCode ) )
      arr[ _MO_KOD_FFOMS ]  := ( dbName )->MCOD
      arr[ _MO_KOD_TFOMS ]  := ''
      arr[ _MO_FULL_NAME ]  := AllTrim( ( dbName )->NAMEMOP )
      arr[ _MO_SHORT_NAME ] := AllTrim( ( dbName )->NAMEMOK )
      arr[ _MO_ADRES ]      := AllTrim( ( dbName )->ADDRESS )
      arr[ _MO_PROD ]       := ''
      arr[ _MO_DEND ]       := CToD( '01-01-2021' )
      arr[ _MO_STANDART ]   := 1
      arr[ _MO_UROVEN ]     := 1
      arr[ _MO_IS_MAIN ]    := .t.
      arr[ _MO_IS_UCH ]     := .t.
      arr[ _MO_IS_SMP ]     := .t.
    Endif
    ( dbName )->( dbCloseArea() )
  Else
    arr := AClone( glob_arr_mo[ 1 ] )
    For i := 1 To Len( arr )
      If ValType( arr[ i ] ) == 'C'
        arr[ i ] := Space( 6 ) // � ���⨬ ��ப��� ������
      Endif
    Next
    If !Empty( mCode )
      If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == mCode } ) ) > 0
        arr := glob_arr_mo[ i ]
      Elseif ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_FFOMS ] == mCode } ) ) > 0
        arr := glob_arr_mo[ i ]
      Endif
    Endif
  Endif
  Select( tmp_select )

  Return arr

// =========== F005 ===================
//
// 27.02.21 ������ ���ᨢ �����䨪��� ����ᮢ ������ ����樭᪮� ����� F005.xml
Function getf005()

  // F005.xml - �����䨪��� ����ᮢ ������ ����樭᪮� �����
  // 1 - STNAME(C)  2 - IDIDST(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { '�� �ਭ�� �襭�� �� �����', 0, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '����祭�', 1, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '�� ����祭�', 2, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '����筮 ����祭�', 3, SToD( '20110101' ), SToD( '' ) } )
  Endif

  Return _arr

// =========== F006 ===================
//
// 19.12.22 ������ ���ᨢ �����䨪��� ����� ����஫� F006.xml
Function getf006()

  // F006.xml - �����䨪��� ����� ����஫�
  // IDVID,     "N",   2, 0  // ��� ���� ����஫�
  // VIDNAME,   "C", 350, 0  // ������������ ���� ����஫�
  // DATEBEG,   "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND,   "D",   8, 0  // ��� ����砭�� ����⢨� �����

  Static _arr := {}
  Local db
  Local aTable
  Local nI

  If Len( _arr ) == 0
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT idvid, vidname, datebeg, dateend FROM f006' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    db := nil
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  Endif

  Return _arr

// =========== F007 ===================
//
// 27.02.21 ������ ���ᨢ �����䨪��� ������⢥���� �ਭ��������� ����樭᪮� �࣠����樨 F007.xml
Function getf007()

  // F007.xml - �����䨪��� ������⢥���� �ਭ��������� ����樭᪮� �࣠����樨
  // 1 - VEDNAME(C)  2 - IDVED(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { '�㭨樯��쭮�� ��ࠧ������', 1, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '��ꥪ� ���ᨩ᪮� �����樨', 2, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '�����ࠢ��ࠧ���� ���ᨨ', 3, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '�����ୠ㪨 ���ᨨ', 4, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '������஭� ���ᨨ', 5, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '��� ���ᨨ', 6, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '������ ���ᨨ ����', 7, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '��� ���ᨨ', 8, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '����', 9, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '���� ���ᨨ', 10, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '���� 䥤�ࠫ��� ��������� � �������', 11, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '��� ��� "���"', 12, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '��⮭���� ��', 13, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '����⢥����, ५�������� �࣠����権', 14, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '���', 15, SToD( '20110101' ), SToD( '' ) } )
  Endif

  Return _arr

// =========== F008 ===================
//
// 27.02.21 ������ �����䨪��� ⨯�� ���㬥�⮢, ���⢥ত���� 䠪� ���客���� �� ��� F008.xml
Function getf008()

  // F008.xml - �����䨪��� ⨯�� ���㬥�⮢, ���⢥ত���� 䠪� ���客���� �� ���
  // 1 - DOCNAME(C)  2 - IDDOC(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { '����� ��� ��ண� ��ࠧ�', 1, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '�६����� ᢨ��⥫��⢮, ���⢥ত��饥 ��ଫ���� ����� ��易⥫쭮�� ����樭᪮�� ���客����', 2, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '����� ��� ������� ��ࠧ�', 3, SToD( '20110101' ), SToD( '' ) } )
  Endif

  Return _arr

// =========== F009 ===================
//
// 27.02.21 ������ �����䨪��� ����� �����客������ ��� F009.xml
Function getf009()

  // F009.xml - �����䨪��� ����� �����客������ ���
  // 1 - StatusName(C)  2 - IDStatus(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { '������騩', 1, SToD( '20110101' ), SToD( '' ) } )
    AAdd( _arr, { '��ࠡ���騩', 2, SToD( '20110101' ), SToD( '' ) } )
  Endif

  Return _arr

// =========== F010 ===================
//
// 14.10.24 ������ ���ᨢ ॣ����� �� �ࠢ�筨�� ॣ����� ����� F010.xml
Function getf010()

  // F010.xml - �����䨪��� ��ꥪ⮢ ���ᨩ᪮� �����樨
  // KOD_TF,       "C",      2,      0  // ��� �����
  // KOD_OKATO,     "C",    5,      0  // ��� �� ����� (�ਫ������ � O002).
  // SUBNAME,     "C",    254,      0  // ������������ ��ꥪ� ��
  // OKRUG,     "N",        1,      0  // ��� 䥤�ࠫ쭮�� ���㣠
  // DATEBEG,   "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND,   "D",   8, 0   // ��� ����砭�� ����⢨� �����

  Static _arr := {}
  Local db
  Local aTable
  Local nI

  If Len( _arr ) == 0
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT subname, kod_tf, okrug, kod_okato, datebeg, dateend FROM f010' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) } )
      Next
    Endif
    db := nil
    AAdd( _arr, { '����ࠫ쭮�� ���稭����', '99', 0 } )
    If hb_FileExists( dir_exe() + 'f010' + sdbf )
      FErase( dir_exe() + 'f010' + sdbf )
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  Endif

  Return _arr

// =========== F011 ===================
//
// 19.12.22 ������ �����䨪��� ⨯�� ���㬥�⮢, 㤮�⮢������ ��筮��� F011.xml
Function getf011()

  // F011.xml - �����䨪��� ⨯�� ���㬥�⮢, 㤮�⮢������ ��筮���
  // IDDoc,     "C",   2, 0  // ��� ⨯� ���㬥��
  // DocName,   "C", 254, 0  // ������������ ⨯� ���㬥��
  // DocSer,    "C",  10, 0  // ��᪠ �ਨ ���㬥��
  // DocNum,    "C",  20, 0  // ��᪠ ����� ���㬥��
  // DATEBEG,   "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND,   "D",   8, 0  // ��� ����砭�� ����⢨� �����

  Static _arr := {}
  Local db
  Local aTable
  Local nI

  If Len( _arr ) == 0
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT docname, iddoc, datebeg, dateend, docser, docnum FROM f011' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), Val( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), AllTrim( aTable[ nI, 5 ] ), AllTrim( aTable[ nI, 6 ] ) } )
      Next
    Endif
    db := nil
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  Endif

  Return _arr

// =========== F012 ===================
//
// 27.02.21 ������ ��ࠢ�筨� �訡�� �ଠ⭮-�����᪮�� ����஫� F012.xml
Function getf012()

  // F012.xml - ��ࠢ�筨� �訡�� �ଠ⭮-�����᪮�� ����஫�
  // 1 - Opis(C)  2 - Kod(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DopInfo(C)
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { "�訡��� ���冷� ⥣��", 901, SToD( "20110101" ), SToD( "" ), "����襭 ���冷� ᫥������� ⥣��, ���� ��������� ��易⥫�� ⥣." } )
    AAdd( _arr, { "��������� ��易⥫쭮� ����", 902, SToD( "20110101" ), SToD( "" ), "��������� ���祭�� � ��易⥫쭮� ⥣�." } )
    AAdd( _arr, { "������ ⨯ ������", 903, SToD( "20110101" ), SToD( "" ), "����������� ���� ᮤ�ন� �����, �� ᮮ⢥�����騥 ��� ⨯�." } )
    AAdd( _arr, { "������ ���", 904, SToD( "20110101" ), SToD( "" ), "���祭�� �� ᮮ⢥����� �����⨬���." } )
    AAdd( _arr, { "�㡫� ���祢��� �����䨪���", 905, SToD( "20110101" ), SToD( "" ), "�������� ��� 㦥 �ᯮ�짮����� � ������ 䠩��." } )
    AAdd( _arr, { "������ �ଠ� �����", 801, SToD( "20110101" ), SToD( "" ), "����� �� 㯠����� � ��娢 �ଠ� zip." } )
    AAdd( _arr, { "����୮� ��� �����", 802, SToD( "20110101" ), SToD( "" ), "��� ����� �� ᮮ⢥����� ���㬥��樨" } )
    AAdd( _arr, { "� ����� ᮤ�ঠ��� �� �� 䠩��", 803, SToD( "20110101" ), SToD( "" ), "���� ��� ��� 䠩�� �� ������� � zip ��娢�" } )
    AAdd( _arr, { "����୮� ���祭�� �����", 804, SToD( "20110101" ), SToD( "" ), "����୮� ���祭�� �����" } )
    AAdd( _arr, { "����� � ⠪�� ������ �� ��ॣ����஢�� ࠭��", 805, SToD( "20110101" ), SToD( "" ), "����� � ⠪�� ������ �� ��ॣ����஢�� ࠭��" } )
  Endif

  Return _arr

// =========== F014 ===================
//
// 19.05.23 ������ ���ᨢ �ࠢ�筨�� ����� F014.xml
Function getf014()

  // F014.xml - �����䨪��� ��稭 �⪠�� � ����� ����樭᪮� �����
  // Kod,     "N",   3, 0  // ��� �訡��
  // IDVID,   "N",   1, 0  // ��� ���� ����஫�, १�ࢭ�� ����
  // Naim,    "C",1000, 0  // ������������ ��稭� �⪠��
  // Osn,     "C",  20, 0  // �᭮����� �⪠��
  // Komment, "C", 100, 0  // ��㦥��� �������਩
  // KodPG,   "C",  20, 0  // ��� �� �ଥ N ��
  // DATEBEG, "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND, "D",   8, 0   // ��� ����砭�� ����⢨� �����

  // �����頥� ���ᨢ
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'kod, ' + ;
      'osn, ' + ;
      'naim, ' + ;
      'komment, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM f014' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), ;
          AllTrim( aTable[ nI, 1 ] ) + ' (' + AllTrim( aTable[ nI, 2 ] ) + ') ' + AllTrim( aTable[ nI, 3 ] ), ;
          AllTrim( aTable[ nI, 4 ] ), ;
          AllTrim( aTable[ nI, 2 ] ) } )
      Next
    Endif
    db := nil
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  Endif

  Return _arr

// 08.04.25 ������ ��ப� ��� ���� ��䥪� � ���ᠭ��� �訡�� ����� �� �ࠢ�筨�� F014
Function ret_f014( lkod )

  Local arrErrors := getf014()
  Local row := {}

  For Each row in arrErrors
    If row[ 1 ] == lkod
      Return '(' + lstr( row[ 1 ] ) + ') ' + row[ 2 ] + ', [' + row[ 3 ] + ']'
    Endif
  Next

  Return '�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + Str( lkod )

// 31.01.25 ������ ��ப� ��� ���� ��䥪� � ���ᠭ��� �訡�� ����� �� �ࠢ�筨�� F014
Function retarr_f014( lkod, isEmpty )

  Local arrErrors := getf014()
  Local row := {}

  For Each row in arrErrors
    If row[ 1 ] == lkod
      Return row
    Endif
  Next

Return iif( isEmpty, {}, { '�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + Str( lkod ), '', '' } )

// =========== F015 ===================
//
// 17.02.21 ������ ���ᨢ �ࠢ�筨�� ����� F015.xml
Function getf015()

  // F015.xml - �����䨪��� 䥤�ࠫ��� ���㣮�
  // 1 - OKRNAME(C)  2 - KOD_OK(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Local dbName := "f015"
  Static _arr := {}

  If Len( _arr ) == 0
    AAdd( _arr, { "����ࠫ�� 䥤�ࠫ�� ����", 1, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "���� 䥤�ࠫ�� ����", 2, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "�����-������� 䥤�ࠫ�� ����", 3, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "���쭥������ 䥤�ࠫ�� ����", 4, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "�����᪨� 䥤�ࠫ�� ����", 5, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "�ࠫ�᪨� 䥤�ࠫ�� ����", 6, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "�ਢ���᪨� 䥤�ࠫ�� ����", 7, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "�����-������᪨� 䥤�ࠫ�� ����", 8, SToD( "20110101" ), SToD( "" ) } )
    AAdd( _arr, { "-", 0, SToD( "20110101" ), SToD( "" ) } )
  Endif

  Return _arr
