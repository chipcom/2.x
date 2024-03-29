#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 29.03.24
Function ret_ndisp_drz( lkod_h, lkod_k )

  Local fl := .t., msg

  msg := ' '

  ar := ret_etap_drz( lkod_h, lkod_k )
  If ( Len( ar[ 1 ] ) == 0 ) .and. ( lkod_h == 0 )
    metap := 1
  Elseif  ( Len( ar[ 1 ] ) == 1 ) .and. ( lkod_h == 0 )
    If ! eq_any( ar[ 1, 1, 3 ], 352, 353, 357, 358 )
      msg := '� ' + lstr( Year( mn_data ) ) + ' ���� �஢���� I �⠯ ��ᯠ��ਧ�樨 ९த�⨢���� ���஢�� ��� ���ࠢ����� �� II �⠯!'
      hb_Alert( msg )
      fl := .f.
    Endif
    metap := 2
  Endif

  mndisp := inieditspr( A__MENUVERT, mm_ndisp, metap )

  Return fl

// 29.03.24
Function ret_etap_drz( lkod_h, lkod_k )

  Local ae := { {}, {} }, fl, i, k, d1 := Year( mn_data )

  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', dir_server + 'humankk', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  find ( Str( lkod_k, 7 ) )
  Do While human->kod_k == lkod_k .and. !Eof()
    fl := ( lkod_h != human->( RecNo() ) )
    If fl .and. human->schet > 0 .and. human_->oplata == 9
      fl := .f. // ���� ���� ��� �� ���� � ���⠢��� ����୮
    Endif
    If fl .and. Between( human->ishod, 401, 402 ) // ???
      i := human->ishod - 400
      If Year( human->n_data ) == d1 // ⥪�騩 ���
        AAdd( ae[ 1 ], { i, human->k_data, human_->RSLT_NEW } )
      Endif
    Endif
    Skip
  Enddo
  Close databases

  Return ae

// 28.08.24 ������� ������ ��㣨 �� �⠯� ��ᯠ��ਧ�樨 COVID
Function index_usluga_etap_drz( _etap, lshifr, age, gender )

  // _etap - �⠯ ��ᯠ��ਧ�樨
  // lshifr - ��� ��㣨
  // age - ������
  // gender - ��� (� ��� �)
  Local index := 0
  Local i := 0
  Local usl := uslugietap_drz( _etap, age, gender )

  For i := 1 To Len( usl )
    If AllTrim( usl[ i, 2 ] ) == AllTrim( lshifr )
      index := i
      Exit
    Endif
  Next

  Return Index

// 28.03.24
Function valid_date_uslugi_drz( get, metap, beginDate, endDate, lenArr, i )

  If CToD( get:buffer ) > endDate
    get:varput( get:original )
    func_error( 4, '��� �஢������ ��᫥������� ����� ���� ����砭�� ��ᯠ��ਧ�樨' )
    Return .f.
  Endif

  If CToD( get:buffer ) < beginDate
    get:varput( get:original )
    func_error( 4, '��� �஢������ ��᫥������� ����� ���� ��砫� ��ᯠ��ਧ�樨' )
    Return .f.
  Endif

  If ( metap == 1 .and. Upper( get:name ) == 'MDATE8' ) .or. ( metap == 2 .and. Upper( get:name ) == 'MDATE4' ) // ��� �ਥ��
    If CToD( get:buffer ) != endDate
      get:varput( get:original )
      func_error( 4, '��� �஢������ �ᬮ�� ��� �� ࠢ�� ��� ����砭�� 㣫㡫����� ��ᯠ��ਧ�樨' )
      Return .f.
    Endif
  Endif

  Return .t.

// 28.03.24
Function f_valid_begdata_drz( get, loc_kod )

  Local i

  If CToD( get:buffer ) < 0d20240101
    get:varput( get:original )
    func_error( 4, '��ᯠ��ਧ��� ९த�⨢���� ���஢�� ��砫��� � 01 ﭢ��� 2024 ����' )
    Keyboard Chr( K_UP )
    Return .f.
  Endif

//  If loc_kod == 0
//    For i := 1 To Len( uslugietap_drz( metap ) ) - iif( metap == 1, 2, 1 )
//      // �� 1-�⠯� ���� ��㣠 �� �⮡ࠦ����� � ᯨ᪥ (70.9.1 ��� 70.9.2 ��� 70.9.3)
//      mvar := 'MDATE' + lstr( i )
//      &mvar := CToD( get:buffer )
//      update_get( mvar )
//    Next
//  Endif

  Return .t. 

// 28.03.24 ࠡ��� �� ��㣠 �� ��ᯠ��ਧ�樨 ९த�⨢���� ���஢�� � ����ᨬ��� �� �⠯�
Function f_is_usl_oms_sluch_drz( i, _etap, age, gender, allUsl, /*@*/_diag, /*@*/_otkaz )
 
  Local fl := .f.
  Local ars := {}
  local uName

  Local ar := uslugietap_drz( _etap, age, gender )[ i ]

  uName := alltrim( ar[ 2 ] )
  If ValType( ar[ 2 ] ) == 'C' .and. _etap == 1 .and. ( uName == '70.9.1' .or. uName == '70.9.2' .or. uName == '70.9.3' ) .and. ( ! allUsl )
    Return fl
  Endif
  If ValType( ar[ 3 ] ) == 'N'
    fl := ( ar[ 3 ] == _etap )
  Else
    fl := AScan( ar[ 3 ], _etap ) > 0
  Endif
  _diag := ( ar[ 4 ] == 1 )
  _otkaz := 0
  If ValType( ar[ 2 ] ) == 'C'
    AAdd( ars, ar[ 2 ] )
  Else
    ars := AClone( ar[ 2 ] )
  Endif
  If eq_any( _etap, 1, 2 ) .and. ar[ 5 ] == 1
    _otkaz := 1 // ����� ����� �⪠�
  Endif

  Return fl

// 28.03.241 ������� ��㣨 �⠯� ��ᯠ��ਧ�樨 COVID
Function uslugietap_drz( _etap, age, gender )

  // _etap - �⠯ ��ᯠ��ਧ�樨
  Local retArray := {}
  Local i, fl
  Local usl := ret_arrays_drz()

  default age to 18
  default gender to 0

  For i := 1 To Len( usl )
    fl := .f.
    If ValType( usl[ i, 3 ] ) == 'N'
      fl := ( usl[ i, 3 ] == _etap )
    Else
      fl := AScan( usl[ i, 3 ], _etap ) > 0
    Endif
    If fl
      if gender == '�'
        if ValType( usl[ i, 6 ] ) == 'N'
          fl := ( usl[ i, 6 ] == 1 )
        else
          fl := AScan( usl[ i, 6 ], age ) > 0
        Endif
      else
        if ValType( usl[ i, 7 ] ) == 'N'
          fl := ( usl[ i, 7 ] == 1 )
        else
          fl := AScan( usl[ i, 7 ], age ) > 0
        Endif
      endif
    endif

    if fl
      AAdd( retArray, usl[ i ] )
    Endif
  Next

  Return retArray

// 28.03.24 ᪮�४�஢��� ���ᨢ� �� 㣫㡫����� ��ᯠ��ਧ�樨 COVID
Function ret_arrays_drz()

  Local dvn_drz_arr_usl

  // 1- ������������ ����
  // 2- ��� ��㣨
  // 3- �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1,2}
  // 4 - ������� (0 ��� 1) ����� ����?
  // 5- �������� �⪠� ��樥�� (0 - ���, 1 - ��)
  // 6 - ������ ��� ��稭 (�᫮ ���), �᫨ 1 - �� ������, �᫨ ᯨ᮪ {} � ������� ���祭�� ������
  // 7 - ������ ��� ���騭 (�᫮ ���), �᫨ 1 - �� ������, �᫨ ᯨ᮪ {} � ������� ���祭�� ������

  // 10- V002 - �����䨪��� ��䨫�� ��������� ����樭᪮� �����
  // 11- V004 - �����䨪��� ����樭᪨� ᯥ樠�쭮�⥩
  // 12 - �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
  // 13 - ᮮ⢥������� ��㣠 ����� ��㣥 �����
  dvn_drz_arr_usl := { ; // ��㣨 �� ��࠭ ��� �����
    { ;
      '��� ���-�����-���������� ��ࢨ��', ; // ������������ ����
      'B01.001.001', ; // ��� ��㣨
      1, ;  // �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1, 2}
      1, ;  // ������� (0 ��� 1) ����� ����?
      0, ;  // �������� �⪠� ��樥�� (0 - ��, 1 - ���)
      0, ;  // ������ ��� ��稭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      { 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, ;
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, ;
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49 }, ; // ������ ��� ���騭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      1, ;  // ?
      1, ;  // ?
      { 136, 151 }, ; // V002 - �����䨪��� ��䨫�� ��������� ���. �����
      { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ; // V004 �����䨪��� ���. ᯥ樠�쭮�⥩
      1, ;  // �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
      '';   // ᮮ⢥������� ��㣠 ����� ��㣥 �����
    }, ;
    { ;
      '���쯠�� ������� �����', ; // ������������ ����
      'A01.20.006', ; // ��� ��㣨
      1, ;  // �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1, 2}
      1, ;  // ������� (0 ��� 1) ����� ����?
      0, ;  // �������� �⪠� ��樥�� (0 - ��, 1 - ���)
      0, ;  // ������ ��� ��稭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      { 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, ;
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, ;
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49 }, ; // ������ ��� ���騭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      1, ;  // ?
      1, ;  // ?
      { 136, 151 }, ; // V002 - �����䨪��� ��䨫�� ��������� ���. �����
      { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ; // V004 �����䨪��� ���. ᯥ樠�쭮�⥩
      1, ;  // �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
      '';   // ᮮ⢥������� ��㣠 ����� ��㣥 �����
    }, ;
    { ;
      '�ᬮ�� 襩�� ��⪨ � ��ઠ���', ; // ������������ ����
      'A02.20.001', ; // ��� ��㣨
      1, ;  // �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1, 2}
      1, ;  // ������� (0 ��� 1) ����� ����?
      0, ;  // �������� �⪠� ��樥�� (0 - ��, 1 - ���)
      0, ;  // ������ ��� ��稭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      { 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, ;
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, ;
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49 }, ; // ������ ��� ���騭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      1, ;  // ?
      1, ;  // ?
      { 136, 151 }, ; // V002 - �����䨪��� ��䨫�� ��������� ���. �����
      { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ; // V004 �����䨪��� ���. ᯥ樠�쭮�⥩
      1, ;  // �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
      '';   // ᮮ⢥������� ��㣠 ����� ��㣥 �����
    }, ;
    { ;
      '����᪮���᪮� ���-��� ���������� ������', ; // ������������ ����
      'A12.20.001', ; // ��� ��㣨
      1, ;  // �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1, 2}
      1, ;  // ������� (0 ��� 1) ����� ����?
      0, ;  // �������� �⪠� ��樥�� (0 - ��, 1 - ���)
      0, ;  // ������ ��� ��稭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      { 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, ;
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, ;
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49 }, ; // ������ ��� ���騭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      1, ;  // ?
      1, ;  // ?
      { 136, 151 }, ; // V002 - �����䨪��� ��䨫�� ��������� ���. �����
      { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ; // V004 �����䨪��� ���. ᯥ樠�쭮�⥩
      1, ;  // �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
      '';   // ᮮ⢥������� ��㣠 ����� ��㣥 �����
    }, ;
    { ;
      '���. ��᫥������� ���ய९��� 襩�� ��⪨', ; // ������������ ����
      'A08.20.017', ; // ��� ��㣨
      1, ;  // �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1, 2}
      1, ;  // ������� (0 ��� 1) ����� ����?
      0, ;  // �������� �⪠� ��樥�� (0 - ��, 1 - ���)
      0, ;  // ������ ��� ��稭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      { 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, ;
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, ;
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49 }, ; // ������ ��� ���騭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      1, ;  // ?
      1, ;  // ?
      { 136, 151 }, ; // V002 - �����䨪��� ��䨫�� ��������� ���. �����
      { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ; // V004 �����䨪��� ���. ᯥ樠�쭮�⥩
      1, ;  // �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
      '';   // ᮮ⢥������� ��㣠 ����� ��㣥 �����
    }, ;
    { ;
      '��।-��� ��䥪権, ��।������ ������ ��⥬', ; // ������������ ����
      'A26.20.034.001', ; // ��� ��㣨
      1, ;  // �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1, 2}
      1, ;  // ������� (0 ��� 1) ����� ����?
      0, ;  // �������� �⪠� ��樥�� (0 - ��, 1 - ���)
      0, ;  // ������ ��� ��稭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      { 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29 }, ; // ������ ��� ���騭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      1, ;  // ?
      1, ;  // ?
      { 136, 151 }, ; // V002 - �����䨪��� ��䨫�� ��������� ���. �����
      { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ; // V004 �����䨪��� ���. ᯥ樠�쭮�⥩
      1, ;  // �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
      '';   // ᮮ⢥������� ��㣠 ����� ��㣥 �����
    }, ;
    { ;
      '�������᭮� ���饭�� ���騭 �� �業�� ९த�⨢���� ���஢�� I �⠯ 18-29 ���', ; // ������������ ����
      '70.9.1', ; // ��� ��㣨
      1, ;  // �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1, 2}
      1, ;  // ������� (0 ��� 1) ����� ����?
      0, ;  // �������� �⪠� ��樥�� (0 - ��, 1 - ���)
      0, ;  // ������ ��� ��稭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      { 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29 }, ; // ������ ��� ���騭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      1, ;  // ?
      1, ;  // ?
      { 136, 151 }, ; // V002 - �����䨪��� ��䨫�� ��������� ���. �����
      { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ; // V004 �����䨪��� ���. ᯥ樠�쭮�⥩
      0, ;  // �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
      '';   // ᮮ⢥������� ��㣠 ����� ��㣥 �����
    }, ;
    { ;
      '�������᭮� ���饭�� ���騭 �� �業�� ९த�⨢���� ���஢�� I �⠯ 30-49 ���', ; // ������������ ����
      '70.9.2', ; // ��� ��㣨
      1, ;  // �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1, 2}
      1, ;  // ������� (0 ��� 1) ����� ����?
      0, ;  // �������� �⪠� ��樥�� (0 - ��, 1 - ���)
      0, ;  // ������ ��� ��稭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      { 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, ;
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49 }, ; // ������ ��� ���騭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      1, ;  // ?
      1, ;  // ?
      { 136, 151 }, ; // V002 - �����䨪��� ��䨫�� ��������� ���. �����
      { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ; // V004 �����䨪��� ���. ᯥ樠�쭮�⥩
      0, ;  // �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
      '';   // ᮮ⢥������� ��㣠 ����� ��㣥 �����
    }, ;
    { ;
      '��� ���-�஫��� ��ࢨ��', ; // ������������ ����
      'B01.053.001', ; // ��� ��㣨
      1, ;  // �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1, 2}
      1, ;  // ������� (0 ��� 1) ����� ����?
      0, ;  // �������� �⪠� ��樥�� (0 - ��, 1 - ���)
      { 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, ;
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, ;
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49 }, ;  // ������ ��� ��稭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      0, ; // ������ ��� ���騭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      1, ;  // ?
      1, ;  // ?
      { 108, 151 }, ; // V002 - �����䨪��� ��䨫�� ��������� ���. �����
      { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ; // V004 �����䨪��� ���. ᯥ樠�쭮�⥩
      1, ;  // �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
      '';   // ᮮ⢥������� ��㣠 ����� ��㣥 �����
    }, ;
    { ;
      '��� ���-���࣠ ��ࢨ�� *', ; // ������������ ����
      'B01.057.001', ; // ��� ��㣨
      1, ;  // �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1, 2}
      1, ;  // ������� (0 ��� 1) ����� ����?
      0, ;  // �������� �⪠� ��樥�� (0 - ��, 1 - ���)
      { 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, ;
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, ;
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49 }, ;  // ������ ��� ��稭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      0, ; // ������ ��� ���騭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      1, ;  // ?
      1, ;  // ?
      { 112, 151 }, ; // V002 - �����䨪��� ��䨫�� ��������� ���. �����
      { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ; // V004 �����䨪��� ���. ᯥ樠�쭮�⥩
      1, ;  // �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
      '';   // ᮮ⢥������� ��㣠 ����� ��㣥 �����
    }, ;
    { ;
      '�������᭮� ���饭�� ��稭 �� �業�� ९த�⨢���� ���஢�� I �⠯ 18-49 ���', ; // ������������ ����
      '70.9.3', ; // ��� ��㣨
      1, ;  // �⠯ ��� ᯨ᮪ �����⨬�� �⠯��, �ਬ��: {1, 2}
      1, ;  // ������� (0 ��� 1) ����� ����?
      0, ;  // �������� �⪠� ��樥�� (0 - ��, 1 - ���)
      { 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, ;
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, ;
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49 }, ;  // ������ ��� ��稭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      0, ; // ������ ��� ���騭 (�᫮ ���), 1 - �� ������, �᫨ ��᮪ {} � ������� ���祭�� ������
      1, ;  // ?
      1, ;  // ?
      { 108, 112, 151 }, ; // V002 - �����䨪��� ��䨫�� ��������� ���. �����
      { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ; // V004 �����䨪��� ���. ᯥ樠�쭮�⥩
      0, ;  // �ਧ��� ��㣨 �����/����� 0 - �����, 1 - �����
      '';   // ᮮ⢥������� ��㣠 ����� ��㣥 �����
    } ;
  }

  Return dvn_drz_arr_usl

// 29.03.24
Function save_arr_drz( lkod, mk_data )

  Local arr := {}, i, sk, ta
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'TPERS' )
  Endif

  If Type( 'mfio' ) == 'C'
    AAdd( arr, { 'mfio', AllTrim( mfio ) } )
  Endif
  If Type( 'mdate_r' ) == 'D'
    AAdd( arr, { 'mdate_r', mdate_r } )
  Endif
  For i := 1 To 5
    sk := lstr( i )
    pole_diag := 'mdiag' + sk
    pole_1pervich := 'm1pervich' + sk
    pole_1stadia := 'm1stadia' + sk
    pole_1dispans := 'm1dispans' + sk
    pole_1dop := 'm1dop' + sk
    pole_1usl := 'm1usl' + sk
    pole_1san := 'm1san' + sk
    pole_d_diag := 'mddiag' + sk
    pole_d_dispans := 'mddispans' + sk
    pole_dn_dispans := 'mdndispans' + sk
    If !Empty( &pole_diag )
      ta := { &pole_diag, ;
        &pole_1pervich, ;
        &pole_1stadia, ;
        &pole_1dispans }
      If Type( pole_1dop ) == 'N' .and. Type( pole_1usl ) == 'N' .and. Type( pole_1san ) == 'N'
        AAdd( ta, &pole_1dop )
        AAdd( ta, &pole_1usl )
        AAdd( ta, &pole_1san )
      Else
        AAdd( ta, 0 )
        AAdd( ta, 0 )
        AAdd( ta, 0 )
      Endif
      If Type( pole_d_diag ) == 'D' .and. Type( pole_d_dispans ) == 'D'
        AAdd( ta, &pole_d_diag )
        AAdd( ta, &pole_d_dispans )
      Else
        AAdd( ta, CToD( '' ) )
        AAdd( ta, CToD( '' ) )
      Endif
      If Type( pole_dn_dispans ) == 'D'
        AAdd( ta, &pole_dn_dispans )
      Else
        AAdd( ta, CToD( '' ) )
      Endif
      AAdd( arr, { lstr( 10 + i ), ta } )
    Endif
  Next i
  // �⪠�� ��樥��
  If !Empty( arr_usl_otkaz )
    AAdd( arr, { '19', arr_usl_otkaz } ) // ���ᨢ
  Endif
  AAdd( arr, { '30', m1GRUPPA } )    // 'N1',��㯯� ���஢�� ��᫥ ���-��
  If Type( 'm1prof_ko' ) == 'N'
    AAdd( arr, { '31', m1prof_ko } )    // 'N1',��� ���.�������஢����
  Endif
  // if type('m1ot_nasl1') == 'N'
  AAdd( arr, { '40', arr_otklon } ) // ���ᨢ
  AAdd( arr, { '45', m1dispans } )
  AAdd( arr, { '46', m1nazn_l } )
  If mk_data >= 0d20210801
    If mtab_v_dopo_na != 0
      If TPERS->( dbSeek( Str( mtab_v_dopo_na, 5 ) ) )
        AAdd( arr, { '47', { m1dopo_na, TPERS->kod } } )
      Else
        AAdd( arr, { '47', { m1dopo_na, 0 } } )
      Endif
    Else
      AAdd( arr, { '47', { m1dopo_na, 0 } } )
    Endif
  Else
    AAdd( arr, { '47', m1dopo_na } )
  Endif
  AAdd( arr, { '48', m1ssh_na } )
  AAdd( arr, { '49', m1spec_na } )
  If mk_data >= 0d20210801
    If mtab_v_sanat != 0
      If TPERS->( dbSeek( Str( mtab_v_sanat, 5 ) ) )
        AAdd( arr, { '50', { m1sank_na, TPERS->kod } } )
      Else
        AAdd( arr, { '50', { m1sank_na, 0 } } )
      Endif
    Else
      AAdd( arr, { '50', { m1sank_na, 0 } } )
    Endif
  Else
    AAdd( arr, { '50', m1sank_na } )
  Endif
  // endif
  If Type( 'm1p_otk' ) == 'N'
    AAdd( arr, { '51', m1p_otk } )
  Endif
  If mk_data >= 0d20210801
    If Type( 'm1napr_v_mo' ) == 'N'
      If mtab_v_mo != 0
        If TPERS->( dbSeek( Str( mtab_v_mo, 5 ) ) )
          AAdd( arr, { '52', { m1napr_v_mo, TPERS->kod } } )
        Else
          AAdd( arr, { '52', { m1napr_v_mo, 0 } } )
        Endif
      Else
        AAdd( arr, { '52', { m1napr_v_mo, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_v_mo' ) == 'N'
      AAdd( arr, { '52', m1napr_v_mo } )
    Endif
  Endif
  If Type( 'arr_mo_spec' ) == 'A'
    AAdd( arr, { '53', arr_mo_spec } ) // ���ᨢ
  Endif
  If mk_data >= 0d20210801
    If Type( 'm1napr_stac' ) == 'N'
      If mtab_v_stac != 0
        If TPERS->( dbSeek( Str( mtab_v_stac, 5 ) ) )
          AAdd( arr, { '54', { m1napr_stac, TPERS->kod } } )
        Else
          AAdd( arr, { '54', { m1napr_stac, 0 } } )
        Endif
      Else
        AAdd( arr, { '54', { m1napr_stac, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_stac' ) == 'N'
      AAdd( arr, { '54', m1napr_stac } )
    Endif
  Endif
  If Type( 'm1profil_stac' ) == 'N'
    AAdd( arr, { '55', m1profil_stac } )
  Endif
  If mk_data >= 0d20210801
    If Type( 'm1napr_reab' ) == 'N'
      If mtab_v_reab != 0
        If TPERS->( dbSeek( Str( mtab_v_reab, 5 ) ) )
          AAdd( arr, { '56', { m1napr_reab, TPERS->kod } } )
        Else
          AAdd( arr, { '56', { m1napr_reab, 0 } } )
        Endif
      Else
        AAdd( arr, { '56', { m1napr_reab, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_reab' ) == 'N'
      AAdd( arr, { '56', m1napr_reab } )
    Endif
  Endif
  If Type( 'm1profil_kojki' ) == 'N'
    AAdd( arr, { '57', m1profil_kojki } )
  Endif

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif

  save_arr_dispans( lkod, arr )

  Return Nil

// 29.03.24
Function read_arr_drz( lkod, is_all )

  Local arr, i, sk
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server + 'mo_pers', , 'TPERS' )
  Endif

  Private mvar
  arr := read_arr_dispans( lkod )
  Default is_all To .t.
  For i := 1 To Len( arr )
    If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C'
      Do Case
      Case is_all .and. eq_any( arr[ i, 1 ], '11', '12', '13', '14', '15' ) .and. ;
          ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 7
        sk := Right( arr[ i, 1 ], 1 )
        pole_diag := 'mdiag' + sk
        pole_1pervich := 'm1pervich' + sk
        pole_1stadia := 'm1stadia' + sk
        pole_1dispans := 'm1dispans' + sk
        pole_1dop := 'm1dop' + sk
        pole_1usl := 'm1usl' + sk
        pole_1san := 'm1san' + sk
        pole_d_diag := 'mddiag' + sk
        pole_d_dispans := 'mddispans' + sk
        pole_dn_dispans := 'mdndispans' + sk
        If ValType( arr[ i, 2, 1 ] ) == 'C'
          &pole_diag := arr[ i, 2, 1 ]
        Endif
        If ValType( arr[ i, 2, 2 ] ) == 'N'
          &pole_1pervich := arr[ i, 2, 2 ]
        Endif
        If ValType( arr[ i, 2, 3 ] ) == 'N'
          &pole_1stadia := arr[ i, 2, 3 ]
        Endif
        If ValType( arr[ i, 2, 4 ] ) == 'N'
          &pole_1dispans := arr[ i, 2, 4 ]
        Endif
        If ValType( arr[ i, 2, 5 ] ) == 'N' .and. Type( pole_1dop ) == 'N'
          &pole_1dop := arr[ i, 2, 5 ]
        Endif
        If ValType( arr[ i, 2, 6 ] ) == 'N' .and. Type( pole_1usl ) == 'N'
          &pole_1usl := arr[ i, 2, 6 ]
        Endif
        If ValType( arr[ i, 2, 7 ] ) == 'N' .and. Type( pole_1san ) == 'N'
          &pole_1san := arr[ i, 2, 7 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 8 .and. ValType( arr[ i, 2, 8 ] ) == 'D' .and. Type( pole_d_diag ) == 'D'
          &pole_d_diag := arr[ i, 2, 8 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 9 .and. ValType( arr[ i, 2, 9 ] ) == 'D' .and. Type( pole_d_dispans ) == 'D'
          &pole_d_dispans := arr[ i, 2, 9 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 10 .and. ValType( arr[ i, 2, 10 ] ) == 'D' .and. Type( pole_dn_dispans ) == 'D'
          &pole_dn_dispans := arr[ i, 2, 10 ]
        Endif
      Case is_all .and. arr[ i, 1 ] == '19' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_usl_otkaz := arr[ i, 2 ]
      Case arr[ i, 1 ] == '30' .and. ValType( arr[ i, 2 ] ) == 'N'
        // m1GRUPPA := arr[i,2]
      Case arr[ i, 1 ] == '31' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1prof_ko := arr[ i, 2 ]
      Case is_all .and. arr[ i, 1 ] == '40' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_otklon := arr[ i, 2 ]
      Case arr[ i, 1 ] == '45' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1dispans  := arr[ i, 2 ]
      Case arr[ i, 1 ] == '46' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1nazn_l   := arr[ i, 2 ]
      Case arr[ i, 1 ] == '47'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1dopo_na  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1dopo_na  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_dopo_na := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '48' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ssh_na   := arr[ i, 2 ]
      Case arr[ i, 1 ] == '49' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1spec_na  := arr[ i, 2 ]
      Case arr[ i, 1 ] == '50'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1sank_na  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1sank_na  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_sanat := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '51' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1p_otk  := arr[ i, 2 ]
      Case arr[ i, 1 ] == '52'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_v_mo  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_v_mo  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_mo := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '53' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_mo_spec := arr[ i, 2 ]
      Case arr[ i, 1 ] == '54'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_stac := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_stac := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_stac := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '55' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1profil_stac := arr[ i, 2 ]
      Case arr[ i, 1 ] == '56'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_reab := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_reab := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_reab := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '57' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1profil_kojki := arr[ i, 2 ]
      Endcase
    Endif
  Next

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif

  Return Nil

// 23.01.17
Function f_valid_diag_oms_sluch_drz( get, k )

  Local sk := lstr( k )

  Private pole_diag := 'mdiag' + sk, ;
    pole_d_diag := 'mddiag' + sk, ;
    pole_pervich := 'mpervich' + sk, ;
    pole_1pervich := 'm1pervich' + sk, ;
    pole_stadia := 'm1stadia' + sk, ;
    pole_dispans := 'mdispans' + sk, ;
    pole_1dispans := 'm1dispans' + sk, ;
    pole_d_dispans := 'mddispans' + sk

  If get == Nil .or. !( &pole_diag == get:original )
    If Empty( &pole_diag )
      &pole_pervich := Space( 12 )
      &pole_1pervich := 0
      &pole_d_diag := CToD( '' )
      &pole_stadia := 1
      &pole_dispans := Space( 3 )
      &pole_1dispans := 0
      &pole_d_dispans := CToD( '' )
    Else
      &pole_pervich := inieditspr( A__MENUVERT, mm_pervich, &pole_1pervich )
      &pole_dispans := inieditspr( A__MENUVERT, mm_danet, &pole_1dispans )
    Endif
  Endif
  If emptyall( m1dispans1, m1dispans2, m1dispans3, m1dispans4, m1dispans5 )
    m1dispans := 0
  Elseif m1dispans == 0
    m1dispans := ps1dispans
  Endif
  mdispans := inieditspr( A__MENUVERT, mm_dispans, m1dispans )
  update_get( pole_pervich )
  update_get( pole_d_diag )
  update_get( pole_stadia )
  update_get( pole_dispans )
  update_get( pole_d_dispans )
  update_get( 'mdispans' )

  Return .t.

