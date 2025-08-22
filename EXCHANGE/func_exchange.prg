// ࠧ���� �㭪樨 ��� ������ 䠩���� � ���譨�� ��⥬��� - func_exchange.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 27.06.24 ��ନ஢��� ���ᨢ ���� 䠩��� ॥��� ᢥ����� � ��樥�⮢
function name_reestr_XML( type, nyear, nmonth, mnn, nsh )
  // type - ⨯ ॥��� (�����, ��� ��ᯠ��ਧ�樨)
  // nyear - ����� ����
  // nmonth - ����� �����
  // mnn - 
  // nsh - 
  // ������ - ���ᨢ { ��� 䠩�� ॥��� ᢥ�����, ��� 䠩�� ॥��� ��樥�⮢ }

  local sName := ''
  local aFiles

  sName := 'RM' + CODE_LPU + 'T34' + '_' ;
    + Right( StrZero( NYEAR, 4 ), 2 ) + StrZero( NMONTH, 2 ) + StrZero( mnn, nsh )
  aFiles := { { 'H', 'F' }[ type ] + sName, ;
    'L' + sName }
  return aFiles

// 22.08.25 ��ନ஢��� ���ᨢ ���� 䠩��� ॥��� ᢥ����� � ��樥�⮢ � 2025
function name_reestr_XML_2025( type, nyear, nmonth, mnn, nsh, kod_smo )
  // type - ⨯ ॥��� (�����, ��� ��ᯠ��ਧ�樨)
  // nyear - ����� ����
  // nmonth - ����� �����
  // mnn - 
  // nsh - 
  // ������ - ���ᨢ { ��� 䠩�� ॥��� ᢥ�����, ��� 䠩�� ॥��� ��樥�⮢ }

  local sName := ''
  local aFiles

  sName := 'M' + CODE_LPU + iif( kod_smo == '34   ', 'T34', 'S' + kod_smo ) + '_' ;
    + Right( StrZero( NYEAR, 4 ), 2 ) + StrZero( NMONTH, 2 ) + StrZero( mnn, nsh )
  aFiles := { { 'H', 'F' }[ type ] + sName, ;
    'L' + sName }
  return aFiles

// 17.12.19 �஢����, ��� �� �।�����祭 ����� XML-䠩�
Function is_our_xml( cName, ret_arr )

  Local c, arr_err := {}, i, s, nSMO, nTypeFile, cFrom, cTo, _nYear, _nMonth, nNN, nReestr := 0

  s := cName
  If eq_any( Left( s, 3 ), 'VHR', 'VFR', 'PHR', 'PFR' ) // 䠩� ��⮪��� ���
    nTypeFile := _XML_FILE_FLK
    r_use( dir_server() + 'mo_rees', , 'REES' )
    r_use( dir_server() + 'mo_xml', , 'MO_XML' )
    Index On Upper( fname ) to ( cur_dir() + 'tmpmoxml' )
    find ( PadR( SubStr( s, 2 ), 26 ) ) // ��� � �� ᠬ��, ��稭�� � ��ண� �����
    If Found() .and. ( nReestr := mo_xml->REESTR ) > 0
      Select REES
      Goto ( nReestr )
      cFrom   := glob_MO[ _MO_KOD_TFOMS ]
      cTo     := '34'
      _nYear  := rees->NYEAR
      _nMonth := rees->NMONTH
      nNN     := rees->NN
    Else
      AAdd( arr_err, '�� 䠩� ���, �� �� �� ��ࠢ�﫨 ᮮ⢥�����騩 ॥��� ��砥� � �����!' )
    Endif
    rees->( dbCloseArea() )
    mo_xml->( dbCloseArea() )
  Elseif eq_any( Left( s, 3 ), 'D02', 'R02', 'R12', 'R06' ) // �⢥�� 䠩� �� ��᫠��� 䠩� D01 R01 (R05)
    s := SubStr( s, 4 )
    If Left( s, 1 ) == 'M'
      s := SubStr( s, 2 )
    Else
      AAdd( arr_err, '����ୠ� �㪢� � ������祭�� �����⥫�: ' + s )
    Endif
    If Len( arr_err ) == 0
      cTo := Left( s, 6 )
      If !( cTo == glob_MO[ _MO_KOD_TFOMS ] )
        AAdd( arr_err, '��� ��� �� ' + glob_MO[ _MO_KOD_TFOMS ] + ' �� ᮮ⢥����� ���� �����⥫�: ' + cTo )
        If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == cTo } ) ) > 0
          AAdd( arr_err, '�� 䠩� ���: ' + glob_arr_mo[ i, _MO_SHORT_NAME ] )
        Endif
      Endif
      s := SubStr( s, 7 )
      If Left( s, 3 ) == 'T34'
        s := AfterAtNum( '_', s )
      Else
        AAdd( arr_err, '������ ��ࠢ�⥫�: ' + s )
      Endif
    Endif
    If Len( arr_err ) == 0
      If Left( cName, 3 ) == 'D02'
        nTypeFile := _XML_FILE_D02
        r_use( dir_server() + 'mo_d01', , 'REES' )
        r_use( dir_server() + 'mo_xml', , 'MO_XML' )
        Index On Upper( fname ) to ( cur_dir() + 'tmpmoxml' )
        find ( PadR( 'D01T34M' + glob_MO[ _MO_KOD_TFOMS ] + '_' + s, 26 ) ) // ᪮�����஢��� ��� 䠩�� D01
        If Found() .and. ( nReestr := mo_xml->REESTR ) > 0
          Select REES
          Goto ( nReestr )
          cFrom   := '34'
          cTo     := glob_MO[ _MO_KOD_TFOMS ]
          _nYear  := rees->NYEAR
          _nMonth := rees->MM
          nNN     := rees->NN
        Else
          AAdd( arr_err, '�� 䠩� �⢥� �� D01, �� �� �� ��ࠢ�﫨 ᮮ⢥�����騩 ����� � �����!' )
        Endif
        rees->( dbCloseArea() )
        mo_xml->( dbCloseArea() )
      Elseif Left( cName, 3 ) == 'R02'
        nTypeFile := _XML_FILE_R02
        r_use( dir_server() + 'mo_dr01', , 'REES' )
        r_use( dir_server() + 'MO_XML', , 'MO_XML' )
        Index On Upper( fname ) to ( cur_dir() + 'tmpmoxml' )
        find ( PadR( 'R01T34M' + glob_MO[ _MO_KOD_TFOMS ] + '_' + s, 26 ) ) // ᪮�����஢��� ��� 䠩�� R01
        If Found() .and. ( nReestr := mo_xml->REESTR ) > 0
          Select REES
          Goto ( nReestr )
          cFrom   := '34'
          cTo     := glob_MO[ _MO_KOD_TFOMS ]
          _nYear  := rees->NYEAR
          _nMonth := rees->NQUARTER
          nNN     := rees->NN
        Else
          AAdd( arr_err, '�� 䠩� �⢥� �� R01, �� �� �� ��ࠢ�﫨 ᮮ⢥�����騩 ����� � �����!' )
        Endif
        rees->( dbCloseArea() )
        mo_xml->( dbCloseArea() )
      Elseif Left( cName, 3 ) == 'R12'
        nTypeFile := _XML_FILE_R12
        r_use( dir_server() + 'mo_dr01', , 'REES' )
        r_use( dir_server() + 'MO_XML', , 'MO_XML' )
        Index On Upper( fname ) to ( cur_dir() + 'tmpmoxml' )
        find ( PadR( 'R11T34M' + glob_MO[ _MO_KOD_TFOMS ] + '_' + s, 26 ) ) // ᪮�����஢��� ��� 䠩�� R11
        If Found() .and. ( nReestr := mo_xml->REESTR ) > 0
          Select REES
          Goto ( nReestr )
          cFrom   := '34'
          cTo     := glob_MO[ _MO_KOD_TFOMS ]
          _nYear  := rees->NYEAR
          _nMonth := rees->NQUARTER
          nNN     := rees->NN
        Else
          AAdd( arr_err, '�� 䠩� �⢥� �� R11, �� �� �� ��ࠢ�﫨 ᮮ⢥�����騩 ����� � �����!' )
        Endif
        rees->( dbCloseArea() )
        mo_xml->( dbCloseArea() )
      Else // "R06"
        nTypeFile := _XML_FILE_R06
        r_use( dir_server() + 'mo_dr05', , 'REES' )
        r_use( dir_server() + 'MO_XML', , 'MO_XML' )
        Index On Upper( fname ) to ( cur_dir() + 'tmpmoxml' )
        find ( PadR( 'R05T34M' + glob_MO[ _MO_KOD_TFOMS ] + '_' + s, 26 ) ) // ᪮�����஢��� ��� 䠩�� R05
        If Found() .and. ( nReestr := mo_xml->REESTR ) > 0
          Select REES
          Goto ( nReestr )
          cFrom   := '34'
          cTo     := glob_MO[ _MO_KOD_TFOMS ]
          _nYear  := rees->NYEAR
          _nMonth := 0
          nNN     := rees->NN
        Else
          AAdd( arr_err, '�� 䠩� �⢥� �� R05, �� �� �� ��ࠢ�﫨 ᮮ⢥�����騩 ����� � �����!' )
        Endif
        rees->( dbCloseArea() )
        mo_xml->( dbCloseArea() )
      Endif
    Endif
  Elseif eq_any( Left( s, 4 ), 'PR01', 'PR11', 'PR05' ) // �⢥�� 䠩� �� ��᫠��� 䠩� R01 (R11) (R05)
    s := SubStr( s, 8 )
    If Left( s, 1 ) == 'M'
      s := SubStr( s, 2 )
    Else
      AAdd( arr_err, '����ୠ� �㪢� � ������祭�� �����⥫�: ' + s )
    Endif
    If Len( arr_err ) == 0
      cTo := Left( s, 6 )
      If !( cTo == glob_MO[ _MO_KOD_TFOMS ] )
        AAdd( arr_err, '��� ��� �� ' + glob_MO[ _MO_KOD_TFOMS ] + ' �� ᮮ⢥����� ���� �����⥫�: ' + cTo )
        If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == cTo } ) ) > 0
          AAdd( arr_err, '�� 䠩� ���: ' + glob_arr_mo[ i, _MO_SHORT_NAME ] )
        Endif
      Endif
      s := SubStr( cName, 5, 3 )
      If !( Left( s, 3 ) == 'T34' )
        AAdd( arr_err, '������ ��ࠢ�⥫�: ' + s )
      Endif
    Endif
    If Len( arr_err ) == 0
      If Left( cName, 4 ) == 'PR01'
        nTypeFile := _XML_FILE_R02
        r_use( dir_server() + 'mo_dr01', , 'REES' )
        r_use( dir_server() + 'MO_XML', , 'MO_XML' )
        Index On Upper( fname ) to ( cur_dir() + 'tmpmoxml' )
        find ( PadR( SubStr( cName, 2 ), 26 ) ) // ᪮�����஢��� ��� 䠩�� R01
        If Found() .and. ( nReestr := mo_xml->REESTR ) > 0
          Select REES
          Goto ( nReestr )
          cFrom   := '34'
          cTo     := glob_MO[ _MO_KOD_TFOMS ]
          _nYear  := rees->NYEAR
          _nMonth := rees->NMONTH
          nNN     := rees->NN
        Else
          AAdd( arr_err, '�� 䠩� �⢥� �� R01, �� �� �� ��ࠢ�﫨 ᮮ⢥�����騩 ����� � �����!' )
        Endif
        rees->( dbCloseArea() )
        mo_xml->( dbCloseArea() )
      Elseif Left( cName, 4 ) == 'PR11'
        nTypeFile := _XML_FILE_R12
        r_use( dir_server() + 'mo_dr01', , 'REES' )
        r_use( dir_server() + 'MO_XML', , 'MO_XML' )
        Index On Upper( fname ) to ( cur_dir() + 'tmpmoxml' )
        find ( PadR( SubStr( cName, 2 ), 26 ) ) // ᪮�����஢��� ��� 䠩�� R01
        If Found() .and. ( nReestr := mo_xml->REESTR ) > 0
          Select REES
          Goto ( nReestr )
          cFrom   := '34'
          cTo     := glob_MO[ _MO_KOD_TFOMS ]
          _nYear  := rees->NYEAR
          _nMonth := rees->NMONTH
          nNN     := rees->NN
        Else
          AAdd( arr_err, '�� 䠩� �⢥� �� R11, �� �� �� ��ࠢ�﫨 ᮮ⢥�����騩 ����� � �����!' )
        Endif
        rees->( dbCloseArea() )
        mo_xml->( dbCloseArea() )
      Else // "R06"
        nTypeFile := _XML_FILE_R06
        r_use( dir_server() + 'mo_dr05', , 'REES' )
        r_use( dir_server() + 'MO_XML', , 'MO_XML' )
        Index On Upper( fname ) to ( cur_dir() + 'tmpmoxml' )
        find ( PadR( SubStr( cName, 2 ), 26 ) ) // ᪮�����஢��� ��� 䠩�� R05
        If Found() .and. ( nReestr := mo_xml->REESTR ) > 0
          Select REES
          Goto ( nReestr )
          cFrom   := '34'
          cTo     := glob_MO[ _MO_KOD_TFOMS ]
          _nYear  := rees->NYEAR
          _nMonth := 0
          nNN     := rees->NN
        Else
          AAdd( arr_err, '�� 䠩� �⢥� �� R05, �� �� �� ��ࠢ�﫨 ᮮ⢥�����騩 ����� � �����!' )
        Endif
        rees->( dbCloseArea() )
        mo_xml->( dbCloseArea() )
      Endif
    Endif
  Elseif eq_any( Left( s, 4 ), 'PR01', 'PR11', 'PR05' ) // �⢥�� 䠩� �� ��᫠��� 䠩� R01 (R11) (R05)
    s := SubStr( s, 8 )
    If Left( s, 1 ) == 'M'
      s := SubStr( s, 2 )
    Else
      AAdd( arr_err, '����ୠ� �㪢� � ������祭�� �����⥫�: ' + s )
    Endif
    If Len( arr_err ) == 0
      cTo := Left( s, 6 )
      If !( cTo == glob_MO[ _MO_KOD_TFOMS ] )
        AAdd( arr_err, '��� ��� �� ' + glob_MO[ _MO_KOD_TFOMS ] + ' �� ᮮ⢥����� ���� �����⥫�: ' + cTo )
        If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == cTo } ) ) > 0
          AAdd( arr_err, '�� 䠩� ���: ' + glob_arr_mo[ i, _MO_SHORT_NAME ] )
        Endif
      Endif
      s := SubStr( cName, 5, 3 )
      If !( Left( s, 3 ) == 'T34' )
        AAdd( arr_err, '������ ��ࠢ�⥫�: ' + s )
      Endif
    Endif
    If Len( arr_err ) == 0
      If eq_any( Left( cName, 4 ), 'PR01', 'PR11' )
        nTypeFile := _XML_FILE_R02
        r_use( dir_server() + 'mo_dr01', , 'REES' )
        r_use( dir_server() + 'MO_XML', , 'MO_XML' )
        Index On Upper( fname ) to ( cur_dir() + 'tmpmoxml' )
        find ( PadR( SubStr( cName, 2 ), 26 ) ) // ᪮�����஢��� ��� 䠩�� R01
        If Found() .and. ( nReestr := mo_xml->REESTR ) > 0
          Select REES
          Goto ( nReestr )
          cFrom   := '34'
          cTo     := glob_MO[ _MO_KOD_TFOMS ]
          _nYear  := rees->NYEAR
          _nMonth := rees->NMONTH
          nNN     := rees->NN
        Else
          AAdd( arr_err, '�� 䠩� �⢥� �� R01(R11), �� �� �� ��ࠢ�﫨 ⠪�� ����� � �����!' )
        Endif
        rees->( dbCloseArea() )
        mo_xml->( dbCloseArea() )
      Else // "R06"
        nTypeFile := _XML_FILE_R06
        r_use( dir_server() + 'mo_dr05', , 'REES' )
        r_use( dir_server() + 'MO_XML', , 'MO_XML' )
        Index On Upper( fname ) to ( cur_dir() + 'tmpmoxml' )
        find ( PadR( SubStr( cName, 2 ), 26 ) ) // ᪮�����஢��� ��� 䠩�� R05
        If Found() .and. ( nReestr := mo_xml->REESTR ) > 0
          Select REES
          Goto ( nReestr )
          cFrom   := '34'
          cTo     := glob_MO[ _MO_KOD_TFOMS ]
          _nYear  := rees->NYEAR
          _nMonth := 0
          nNN     := rees->NN
        Else
          AAdd( arr_err, '�� 䠩� �⢥� �� R05, �� �� �� ��ࠢ�﫨 ᮮ⢥�����騩 ����� � �����!' )
        Endif
        rees->( dbCloseArea() )
        mo_xml->( dbCloseArea() )
      Endif
    Endif
  Else
    If eq_any( Left( s, 2 ), 'HR', 'FR' ) // 䠩� ॥��� ��
      s := SubStr( s, 3 )
      nTypeFile := _XML_FILE_SP
    Elseif Left( s, 1 ) == 'A' // 䠩� ���
      s := SubStr( s, 2 )
      nTypeFile := _XML_FILE_RAK
    Elseif Left( s, 1 ) == 'D' // 䠩� ���
      s := SubStr( s, 2 )
      nTypeFile := _XML_FILE_RPD
    Else
      AAdd( arr_err, '����⪠ ������ ��������� 䠩�' )
    Endif
    If Left( s, 1 ) == 'T'
      // �� �����
    Elseif Left( s, 1 ) == 'S'
      // �� ���
    Else
      AAdd( arr_err, '����ୠ� �㪢� � ������祭�� ��ࠢ�⥫�: ' + s )
    Endif
    If Len( arr_err ) == 0
      If nTypeFile == _XML_FILE_SP
        s := SubStr( s, 2 )
        cFrom := BeforAtNum( '_', s )
        nSMO := Int( Val( cFrom ) )
        If AScan( glob_arr_smo, {| x| x[ 2 ] == nSMO } ) == 0
          AAdd( arr_err, '������ ��� ��ࠢ�⥫�: ' + cFrom )
        Endif
        If Len( arr_err ) == 0
          s := AfterAtNum( '_', s )
          If Left( s, 1 ) == 'M'
            s := SubStr( s, 2 )
          Else
            AAdd( arr_err, '����ୠ� �㪢� � ������祭�� �����⥫�: ' + s )
          Endif
          If Len( arr_err ) == 0
            cTo := Left( s, 6 )
            If !( cTo == glob_MO[ _MO_KOD_TFOMS ] )
              AAdd( arr_err, '��� ��� �� ' + glob_MO[ _MO_KOD_TFOMS ] + ' �� ᮮ⢥����� ���� �����⥫�: ' + cTo )
              If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == cTo } ) ) > 0
                AAdd( arr_err, '�� 䠩� ���: ' + glob_arr_mo[ i, _MO_SHORT_NAME ] )
              Endif
            Endif
          Endif
          If Len( arr_err ) == 0
            s := SubStr( s, 7 )
            _nYear := Int( Val( '20' + Left( s, 2 ) ) )
            _nMonth := Int( Val( SubStr( s, 3, 2 ) ) )
            nNN := Int( Val( SubStr( s, 5 ) ) ) // ���� ��ப� �� ����
          Endif
        Endif
      Elseif eq_any( nTypeFile, _XML_FILE_RAK, _XML_FILE_RPD )
        s := SubStr( s, 2 )
        cFrom := BeforAtNum( 'M', s )
        nSMO := Int( Val( cFrom ) )
        If AScan( glob_arr_smo, {| x| x[ 2 ] == nSMO } ) == 0
          AAdd( arr_err, '������ ��� ��ࠢ�⥫�: ' + cFrom )
        Endif
        If Len( arr_err ) == 0
          s := AfterAtNum( 'M', s )
          cTo := BeforAtNum( '_', s )
          If !( cTo == glob_MO[ _MO_KOD_TFOMS ] )
            AAdd( arr_err, '��� ��� �� ' + glob_MO[ _MO_KOD_TFOMS ] + ' �� ᮮ⢥����� ���� �����⥫�: ' + cTo )
            If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == cTo } ) ) > 0
              AAdd( arr_err, '�� 䠩� ���: ' + glob_arr_mo[ i, _MO_SHORT_NAME ] )
            Endif
          Endif
          If Len( arr_err ) == 0
            s := AfterAtNum( '_', s )
            _nYear := Int( Val( '20' + Left( s, 2 ) ) )
            _nMonth := Int( Val( SubStr( s, 3, 2 ) ) )
            nNN := Int( Val( SubStr( s, 5 ) ) ) // ���� ��ப� �� ����
          Endif
        Endif
      Endif
    Endif
  Endif
  If Len( arr_err ) == 0
    ret_arr[ 1 ] := nTypeFile
    ret_arr[ 2 ] := cFrom
    ret_arr[ 3 ] := cTo
    ret_arr[ 4 ] := _nYear
    ret_arr[ 5 ] := _nMonth
    ret_arr[ 6 ] := nNN
    ret_arr[ 7 ] := nReestr
  Else
    ins_array( arr_err, 1, '' )
    ins_array( arr_err, 1, '�ਭ������ 䠩�: ' + cName )
    n_message( arr_err, , 'GR+/R', 'W+/R', , , 'G+/R' )
  Endif

  Return ( Len( arr_err ) == 0 )

// 17.06.15 �᫨ �� 䠩� � ���७���� CSV - ������
Function is_our_csv( cName, /*@*/tip_csv_file, /*@*/kod_csv_reestr)

  Local fl := .f., i, s := cName, s1

  If eq_any( Left( s, 3 ), 'EO2', 'LO2' ) // 䠩�� ��⮪��� �ਪ९����� � ��९�����
    fl := .t.
    tip_csv_file := iif( Left( s, 1 ) == 'E', _CSV_FILE_PRIKANS, _CSV_FILE_PRIKFLK )
    kod_csv_reestr := 0
    If ( s1 := SubStr( s, 4, 6 ) ) == glob_MO[ _MO_KOD_TFOMS ]
      r_use( dir_server() + 'mo_krtf', , 'KRTF' )
      Index On Upper( fname ) to ( cur_dir() + 'tmp_krtf' )
      find ( PadR( s, 26 ) ) // �� �ਭ����� �� 㦥 ����� 䠩�
      If Found()
        fl := func_error( 4, '��� 䠩� 㦥 �� ���⠭ � ' + krtf->TFILE + ' ' + date_8( krtf->DFILE ) + '�.' )
        viewtext( devide_into_pages( dir_server() + dir_XML_TF() + hb_ps() + cName + stxt(), 60, 80 ), , , , .t., , , 2 )
      Else
        find ( PadR( 'M' + SubStr( s, 2 ), 26 ) ) // ��� � �� ᠬ��, ��稭�� � ��ண� �����
        If Found()
          kod_csv_reestr := krtf->REESTR
          r_use( dir_server() + 'mo_krtr', , 'KRTR' )
          Goto ( kod_csv_reestr )
          If krtr->ANSWER == 0 .and. tip_csv_file == _CSV_FILE_PRIKANS
            fl := func_error( 4, '���砫� ����室��� ������ 䠩� L' + SubStr( s, 2 ) + scsv() )
          Endif
          krtr->( dbCloseArea() )
        Else
          fl := func_error( 4, '���� �ਪ९����� ��� ������� ��⮪��� ��ࠡ�⪨ �� �� ��ࠢ�﫨 � �����!' )
        Endif
      Endif
      krtf->( dbCloseArea() )
    Else
      fl := func_error( 4, '��� ��� �� ' + glob_MO[ _MO_KOD_TFOMS ] + ' �� ᮮ⢥����� ���� �����⥫�: ' + s1 )
      If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == s1 } ) ) > 0
        func_error( 4, '�� 䠩� ���: ' + glob_arr_mo[ i, _MO_SHORT_NAME ] )
      Endif
    Endif
  Else
    fl := func_error( 4, '��������� 䠩�' )
  Endif

  Return fl

// 15.10.24 �᫨ �� ��㯭�� ��娢, �ᯠ������ � ������
Function is_our_zip( cName, /*@*/tip_csv_file, /*@*/kod_csv_reestr) 

  Static cStFile, si
  Local fl := .f., arr := {}, arr_f, i, s := cName, s1, name_ext, _date, _time, c

  Default cStFile To cName
  If Left( s, 3 ) == 'RI0' .or. Left( s, 2 ) == 'I0'
    fl := func_error( 4, '����� 䠩� ����室��� ���� � �������� "���� ���ࠢ����� �� ��ᯨ⠫�����"' )
  Elseif eq_any( Left( s, 8 ), 'RHRT34_M', 'RFRT34_M' ) .and. SubStr( s, 9, 6 ) == glob_MO[ _MO_KOD_TFOMS ]
    c := SubStr( s, 2, 1 )
    If ( arr_f := extract_zip_xml( keeppath( full_zip ), strippath( full_zip ), 2 ) ) != NIL
      For i := 1 To Len( arr_f )
        s := Upper( arr_f[ i ] )
        name_ext := name_extention( s )
        Do Case
        Case Left( s, 8 ) == 'P' + c + 'RT34_M' .and. name_ext == spdf()
          AAdd( arr, { 1, '��⮪�� ��ࠡ�⪨ ����㯨��� ᢥ����� ' + s, s, name_ext } )
        Case eq_any( Left( s, 4 ), 'V' + c + 'RM', 'P' + c + 'RM' ) .and. name_ext == szip()
          s1 := '��⮪�� ��� ' + s
          // �஢�ਬ, �⠫� �� 㦥 ����� 䠩�
          If verify_is_already_xml( name_without_ext( s ), @_date, @_time )
            s1 += ' [���⠭ � ' + _time + ' ' + date_8( _date ) + '�.]'
          Endif
          AAdd( arr, { 2, s1, s, name_ext } )
        Case Left( s, 8 ) == 'M' + c + 'RT34_M' .and. name_ext == spdf()
          AAdd( arr, { 3, 'ᢥ����� � �믮������ �����-������� ' + s, s, name_ext } )
        Case Left( s, 8 ) == 'F' + c + 'RT34_M' .and. name_ext == spdf()
          AAdd( arr, { 4, 'ᢥ����� � �믮������ ��쥬�� �� ' + s, s, name_ext } )
        Case Left( s, 7 ) == c + 'RT34_M' .and. name_ext == szip()
          s1 := '॥��� �� � �� ' + s
          // �஢�ਬ, �⠫� �� 㦥 ����� 䠩�
          If verify_is_already_xml( name_without_ext( s ), @_date, @_time )
            s1 += ' [���⠭ � ' + _time + ' ' + date_8( _date ) + '�.]'
          Endif
          AAdd( arr, { 5, s1, s, name_ext } )
        Endcase
      Next
      ASort( arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
      arr_f := {}
      AEval( arr, {| x| AAdd( arr_f, x[ 2 ] ) } )
      i := iif( cStFile == cName, si, 1 )
      If ( i := popup_prompt( T_ROW, T_COL -5, i, arr_f ) ) > 0
        cStFile := cName
        si := i
        If arr[ i, 4 ] == spdf()
          // file_AdobeReader(_tmp2dir1()+arr[i,3])
          view_file_in_viewer( _tmp2dir1() + arr[ i, 3 ] )
        Elseif arr[ i, 4 ] == szip()
          fl := .t.
          full_zip := _tmp2dir1() + arr[ i, 3 ] // ��८�।��塞 Private-��६�����
        Endif
      Endif
    Endif
  Elseif Left( s, 6 ) == glob_MO[ _MO_KOD_TFOMS ]
    If ( arr_f := extract_zip_xml( keeppath( full_zip ), strippath( full_zip ), 2 ) ) != NIL
      For i := 1 To Len( arr_f )
        s := Upper( arr_f[ i ] )
        name_ext := name_extention( s )
        Do Case
        Case Left( s, 1 ) == 'R' .and. name_ext == spdf()
          AAdd( arr, { 1, '��⮪�� ��� ����㯨��� ��⮢ ��� ' + s, s, name_ext } )
        Case Left( s, 2 ) == 'NR' .and. name_ext == spdf()
          AAdd( arr, { 2, '��⮪�� �⪫������ ����㯨��� ��⮢ ��� ' + s, s, name_ext } )
        Endcase
      Next
      ASort( arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
      arr_f := {}
      AEval( arr, {| x| AAdd( arr_f, x[ 2 ] ) } )
      If ( i := popup_prompt( T_ROW, T_COL -5, 1, arr_f ) ) > 0
        If arr[ i, 4 ] == spdf()
          // file_AdobeReader(_tmp2dir1()+arr[i,3])
          view_file_in_viewer( _tmp2dir1() + arr[ i, 3 ] )
        Endif
      Endif
    Endif
  Elseif eq_any( Left( s, 1 ), 'A', 'D' ) // 䠩�� ��� � ���
    fl := .t.
    s := SubStr( s, 2 )
    If eq_any( Left( s, 1 ), 'T', 'S' )
      s := SubStr( s, 2 )
      cFrom := BeforAtNum( 'M', s )
      nSMO := Int( Val( cFrom ) )
      If AScan( glob_arr_smo, {| x| x[ 2 ] == nSMO } ) > 0
        s := AfterAtNum( 'M', s )
        If BeforAtNum( '_', s ) == glob_MO[ _MO_KOD_TFOMS ] .and. ;
            ( arr_f := extract_zip_xml( keeppath( full_zip ), strippath( full_zip ), 2, 'tmp' + szip() ) ) != NIL
          For i := 1 To Len( arr_f )
            If Upper( cName + szip() ) == Upper( arr_f[ i ] )
              full_zip := _tmp2dir1() + arr_f[ i ] // ��८�।��塞 Private-��६�����
              Exit
            Endif
          Next
        Endif
      Endif
    Endif
  Elseif eq_any( Left( s, 2 ), 'E2', 'O2' ) // 䠩�� ��⮪��� �ਪ९����� � ��९�����
    fl := .t.
    tip_csv_file := iif( Left( s, 1 ) == 'E', _CSV_FILE_ANSWER, _CSV_FILE_OTKREP )
    kod_csv_reestr := 0
    If ( s1 := SubStr( s, 3, 6 ) ) == glob_MO[ _MO_KOD_TFOMS ]
      r_use( dir_server() + 'mo_krtf', , 'KRTF' )
      Index On Upper( fname ) to ( cur_dir() + 'tmp_krtf' )
      find ( PadR( s, 26 ) ) // �� �ਭ����� �� 㦥 ����� 䠩�
      If Found()
        fl := func_error( 4, '��� 䠩� 㦥 �� ���⠭ � ' + krtf->TFILE + ' ' + date_8( krtf->DFILE ) + '�.' )
        viewtext( devide_into_pages( dir_server() + dir_XML_TF() + hb_ps() + cName + stxt(), 60, 80 ), , , , .t., , , 2 )
      Elseif tip_csv_file == _CSV_FILE_ANSWER
        find ( PadR( 'MO' + SubStr( s, 2 ), 26 ) ) // ��� � �� ᠬ��, ��稭�� � ���쥣� �����
        If Found()
          kod_csv_reestr := krtf->REESTR
        Else
          fl := func_error( 4, '���� �ਪ९����� ��� ������� ��⮪��� ��ࠡ�⪨ �� �� ��ࠢ�﫨 � �����!' )
        Endif
      Endif
      krtf->( dbCloseArea() )
    Else
      fl := func_error( 4, '��� ��� �� ' + glob_MO[ _MO_KOD_TFOMS ] + ' �� ᮮ⢥����� ���� �����⥫�: ' + s1 )
      If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == s1 } ) ) > 0
        func_error( 4, '�� 䠩� ���: ' + glob_arr_mo[ i, _MO_SHORT_NAME ] )
      Endif
    Endif
  Elseif Left( s, 3 ) == 'SO2' // �⢥� �� ����� ᢥન
    fl := .t.
    tip_csv_file := _CSV_FILE_SVERKAO
    kod_csv_reestr := 0
    If ( s1 := SubStr( s, 4, 6 ) ) == glob_MO[ _MO_KOD_TFOMS ]
      r_use( dir_server() + 'mo_krtf', , 'KRTF' )
      Index On Upper( fname ) to ( cur_dir() + 'tmp_krtf' )
      find ( PadR( s, 26 ) ) // �� �ਭ����� �� 㦥 ����� 䠩�
      If Found()
        fl := func_error( 4, '��� 䠩� 㦥 �� ���⠭ � ' + krtf->TFILE + ' ' + date_8( krtf->DFILE ) + '�.' )
        viewtext( devide_into_pages( dir_server() + dir_XML_TF() + hb_ps() + cName + stxt(), 60, 80 ), , , , .t., , , 2 )
      Else
        find ( PadR( 'SZ' + SubStr( s, 3 ), 26 ) ) // ��� � �� ᠬ��, ��稭�� � ���쥣� �����
        If Found()
          kod_csv_reestr := krtf->REESTR
        Else
          fl := func_error( 4, '���� ����� �� ᢥથ ��� ������� ��⮪��� ��ࠡ�⪨ �� �� ��ࠢ�﫨 � �����' )
        Endif
      Endif
      krtf->( dbCloseArea() )
    Else
      fl := func_error( 4, '��� ��� �� ' + glob_MO[ _MO_KOD_TFOMS ] + ;
        ' �� ᮮ⢥����� ���� �����⥫�: ' + s1 )
      If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == s1 } ) ) > 0
        func_error( 4, '�� 䠩� ���: ' + glob_arr_mo[ i, _MO_SHORT_NAME ] )
      Endif
    Endif
  Else
    fl := .t.
  Endif

  Return fl

// �஢����, ����ᥭ �� ����� 䠩� � 'MO_XML'
Function verify_is_already_xml( cName, /*@*/_date, /*@*/_time)

  Local l, fl, tmp_select := Select()

  r_use( dir_server() + 'MO_XML', , 'MX' )
  Index On Upper( FNAME ) to ( cur_dir() + 'tmp_mxml' )
  l := FieldLen( FieldNum( 'FNAME' ) )
  find ( PadR( cName, l ) )
  If ( fl := Found() )
    If mx->tip_in > 0  // �᫨ �ਭ������ 䠩�
      _date := mx->DREAD  // � ���� ���� ��᫥����� �⥭�� (��ࠡ�⪨)
      _time := mx->TREAD
    Else               // �᫨ ���뫠��� 䠩�
      _date := mx->DFILE  // � ���� ���� ᮧ����� 䠩��
      _time := mx->TFILE
    Endif
  Endif
  mx->( dbCloseArea() )
  Select ( tmp_select )

  Return fl

// 20.10.14 ������ CSV-䠩� � ��㬥�� ���ᨢ
Function read_csv_to_array( cFile_csv )

  Local arr := {}, _ar, i, s, s1, lfp

  lfp := FOpen( cFile_csv )
  Do While !feof( lfp )
    If !Empty( s := freadln( lfp ) )
      _ar := {}
      For i := 1 To NumToken( s, ';', 1 )
        s1 := AllTrim( CharRem( '"', Token( s, ';', i, 1 ) ) )
        AAdd( _ar, hb_ANSIToOEM( s1 ) )
      Next
      For i := 1 To 25
        AAdd( _ar, ' ' ) // ������� 25 ����� (���� ��-� �� ⠪ � ��ப��)
      Next
      AAdd( arr, AClone( _ar ) )
    Endif
  Enddo
  FClose( lfp )

  Return arr

// ��ப� ���� ��� XML-䠩��
Function date2xml( mdate )
  Return StrZero( Year( mdate ), 4 ) + '-' + ;
    StrZero( Month( mdate ), 2 ) + '-' + ;
    StrZero( Day( mdate ), 2 )

// �ॡࠧ����� ���� �� "2002-02-01" � ⨯ "DATE"
Function xml2date( s )
  Return SToD( CharRem( '-', s ) )

// 06.03.23 �஢���� ����稥 ��(��) � ������ ���(��) ���祭��(�) � ���ᨢ�
Function mo_read_xml_array( _node, _title )

  Local j1, oNode2, arr := {}

  For j1 := 1 To Len( _node:aitems )
    oNode2 := _node:aItems[ j1 ]
    If Upper( _title ) == Upper( oNode2:title ) .and. !Empty( oNode2:aItems ) ;
        .and. ValType( oNode2:aItems[ 1 ] ) == 'C'
      // aadd(arr, oNode2:aItems[1])
      If Type( 'p_xml_code_page' ) == 'C' .and. Upper( p_xml_code_page ) == 'UTF-8'
        AAdd( arr, hb_UTF8ToStr( AllTrim( oNode2:aItems[ 1 ] ), 'RU866' ) )
      Else
        AAdd( arr, hb_ANSIToOEM( AllTrim( oNode2:aItems[ 1 ] ) ) )
      Endif

    Endif
  Next

  Return arr

// �஢���� ����稥 � 㧫� _node XML-䠩�� �� _title � ������ ��� ���祭��
Function mo_read_xml_stroke( _node, _title, _aerr, _binding )

  // _node - 㪠��⥫� �� 㧥�
  // _title - ������������ ��
  // _aerr - ���ᨢ ᮮ�饭�� �� �訡���
  // _binding - ��易⥫�� �� ��ਡ�� (��-㬮�砭�� .T.)
  Local ret := '', oNode, yes_err := ( ValType( _aerr ) == 'A' ), ;
    s_msg := '��������� ���祭�� ��易⥫쭮�� �� "' + _title + '"'

  Default _binding To .t.
  // �饬 ����室��� "_title" �� � 㧫� "_node"
  oNode := _node:find( _title )
  If oNode == Nil .and. _binding .and. yes_err
    AAdd( _aerr, s_msg )
  Endif
  If oNode != NIL
    ret := mo_read_xml_tag( oNode, _aerr, _binding )
  Endif

  Return ret

// 11.12.17 ������ ���祭�� ��
Function mo_read_xml_tag( oNode, _aerr, _binding )

  // oNode - 㪠��⥫� �� 㧥�
  // _aerr - ���ᨢ ᮮ�饭�� �� �訡���
  // _binding - ��易⥫�� �� ��ਡ�� (��-㬮�砭�� .T.)
  Local ret := '', c, yes_err := ( ValType( _aerr ) == 'A' ), ;
    s_msg := '��������� ���祭�� ��易⥫쭮�� �� "' + oNode:title + '"'

  Default _binding To .t.
  If Empty( oNode:aItems )
    If _binding .and. yes_err
      AAdd( _aerr, s_msg )
    Endif
  Elseif ( c := ValType( oNode:aItems[ 1 ] ) ) == 'C'
    If Type( 'p_xml_code_page' ) == 'C' .and. Upper( p_xml_code_page ) == 'UTF-8'
      ret := hb_UTF8ToStr( AllTrim( oNode:aItems[ 1 ] ), 'RU866' )
    Else
      ret := hb_ANSIToOEM( AllTrim( oNode:aItems[ 1 ] ) )
    Endif
  Elseif yes_err
    AAdd( _aerr, '������ ⨯ ������ � �� "' + oNode:title + '": "' + c + '"' )
  Endif

  Return ret

// 22.11.13 ������� � XML-䠩� ��ப� (������ ��, ������� ���祭��, ������� ��)
Function mo_add_xml_stroke( oNode, sTag, sValue )

  Local oXmlNode := oNode:add( hxmlnode():new( sTag ) )

  sValue := AllTrim( sValue )
  If Type( 'p_xml_code_page' ) == 'C' .and. Upper( p_xml_code_page ) == 'UTF-8'
    sValue := hb_StrToUTF8( sValue, 'RU866' )
  Else
    sValue := hb_OEMToANSI( sValue )
  Endif
  oXmlNode:add( sValue )

  Return Nil
