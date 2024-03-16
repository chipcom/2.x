#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'hbxlsxwriter.ch'

// 16.03.24
function string_output( sText, lExcel, ws, row, column, fmt )

  default fmt to nil
  If lExcel
    worksheet_write_string( ws, row, column, hb_StrToUTF8( sText ), fmt )
  else
    add_string( sText )
  Endif
  return nil

// 15.03.24 �������ਠ��� ����
Function s_mnog_poisk()

  Static lcount_uch  := 1
  Static mm_rak := { ;
    { '�� ��砨', 0 }, ;
    { '�� �᪫�祭��� ��������� ������稢�����', 1 }, ;
    { '��������� ������稢���� � ��ॢ��⠢�����', 2 }, ;
    { '��������� ������稢���� � ����ॢ��⠢�����', 3 }, ;
    { '��������� ������稢����', 4 }, ;
    { '���筮 ������稢����', 5 }, ;
    { '��������� ��� ���筮 ������稢����', 6 } ;
    }
  Static mm_d_p_m := { ;  // '��ᯠ��ਧ���/��䨫��⨪�/����ᬮ��?'
    { '��ᯠ��ਧ��� ��⥩-��� �� ��樮��� I �⠯', 1 }, ;
    { '��ᯠ��ਧ��� ��⥩-��� �� ��樮��� II �⠯', 2 }, ;
    { '��ᯠ��ਧ��� ��⥩-��� ��� ������ I �⠯', 3 }, ;
    { '��ᯠ��ਧ��� ��⥩-��� ��� ������ II �⠯', 4 }, ;
    { '��ᯠ��ਧ��� ���᫮�� ��ᥫ���� I �⠯ (1 ࠧ � 3 ����)', 5 }, ;
    { '��ᯠ��ਧ��� ���᫮�� ��ᥫ���� II �⠯ (1 ࠧ � 3 ����)', 6 }, ;
    { '��䨫��⨪� ���᫮�� ��ᥫ����', 7 }, ;
    { '��ᯠ��ਧ��� ���᫮�� ��ᥫ���� I �⠯ (1 ࠧ � 2 ����)', 8 }, ;
    { '��ᯠ��ਧ��� ���᫮�� ��ᥫ���� II �⠯ (1 ࠧ � 2 ����)', 9 }, ;
    { '���ᬮ�� ��ᮢ��襭����⭨� I �⠯', 10 }, ;
    { '���ᬮ�� ��ᮢ��襭����⭨� II �⠯', 11 }, ;
    { '�।���⥫�� �ᬮ�� ��ᮢ��襭����⭨� I �⠯', 12 }, ;
    { '�।���⥫�� �ᬮ�� ��ᮢ��襭����⭨� II �⠯', 13 }, ;
    { '��ਮ���᪨� �ᬮ�� ��ᮢ��襭����⭨�', 14 }, ;
    { '㣫㡫����� ��ᯠ��ਧ��� I �⠯ (COVID-19)', 15 }, ;
    { '㣫㡫����� ��ᯠ��ਧ��� II �⠯ (COVID-19)', 16 } ;
    }
  Static mm_perevyst := { ;
    { '�� ��砨', 1 }, ;
    { '��� ���� ��砥� � �⪠��� (��ॢ��⠢������)', 0 }, ;
    { '⮫쪮 ��砨 � �⪠��� (����� �뫨 ��ॢ��⠢����)', 2 } ;
    }
  Static mm_g_selo :=  { { '��த', 1 }, { 'ᥫ�', 2 } }
  Static mm_regschet := { { '�� ��ॣ����஢���� ���', 1 }, { '��ॣ����஢���� ���', 2 } }
  Static mm_schet := { { '�� �����訥 � ���', 1 }, { '�����訥 � ���', 2 } }
  Static mm_reestr := { { '�� �����訥 � ॥����', 1 }, { '�����訥 � ॥����', 2 } }
  Static mm_zav_lech := { { '�������祭�� ��砩', 1 }, { '�����祭�� ��砩', 2 } }
  Static mm_dvojn := { { '�� ��砨', 1 }, { '⮫쪮 ������ ��砨', 2 }, { '��, �஬� ������� ��砥�', 3 } }
  Local mm_tmp := {}, k, adiag_talon[ 16 ]
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    tmp_help := help_code, hGauge, name_file := cur_dir + 'report' + stxt, ;
    sh := 80, HH := 77, i, a_diagnoz[ 10 ], ;
    mm_da_net := { { '���', 1 }, { '�� ', 2 } }, lvid_doc := 0, ;
    menu_bolnich := { { '���', 1 }, { '��', 2 }, { 'த�⥫�', 3 } }, ;
    mm_mest := { { '������ࠤ ��� �������', 1 }, { '�����த���', 2 } }, ;
    mm_dom := { { '-----', 0 }, { '� �����������', 1 }, { '�� ����', 2 } }, ;
    mm_invalid := { { '�������', 0 }, { '�� ��㯯�', 9 }, { '1 ��㯯�', 1 }, { '2 ��㯯�', 2 }, { '3 ��㯯�', 3 }, { '���-��������', 4 } }, ;
    mm_prik := { { '�������', 0 }, ;
    { '�ਪ९�� � ��襩 ��', 1 }, ;
    { '�� �ਪ९�� � ��襩 ��', 2 } }, ;
    tmp_file := cur_dir + 'tmp_mn_p' + sdbf, ;
    k_diagnoz, k_usl, tt_diagnoz[ 10 ], tt_usl[ 10 ]
  Local s := '', s1, s2, s3, sOutput := '', sZag1 := ''
  Local name_fileXLS := 'Report_' + suffixfiletimestamp()
  Local name_fileXLS_full := hb_DirTemp() + name_fileXLS + '.xlsx'
  Local lExcel := .f., used_column := 0
  Local workbook
  Local header, header_wrap
  Local worksheet, wsCommon
  Local formatDate
  Local fmtCellNumber, fmtCellString, fmtCellStringCenter, fmtCellNumberRub
  Local row, column, rowWS, columnWS
  Local wsCommon_format, wsCommon_format_header, wsCommon_format_wrap, wsCommon_Number, wsCommon_Number_Rub

  local mm_output := { ;
    { '�� �࠭                  ', 1 }, ;
    { '� 䠩� Excel (�ଠ� xlsx)', 2 } ;
    }
  local arr_title

  If mem_dom_aktiv == 1
    AAdd( mm_dom, { '�� ����-�����', 3 } )
    AAdd( mm_dom, { '�� ���� + �� ����-�����', 4 } )
  Endif
  Private ssumma := 0, srak_s := 0, suet := 0, p_regim := 1, mm_company := {}, is_kategor2 := .f., ;
    mm_rslt := {}, mm_ishod := {}, rslt_umolch := -1, ishod_umolch := -1
  Private tmp_V006 := create_classif_ffoms( 0, 'V006' ) // USL_OK
  Private tmp_V002 := create_classif_ffoms( 0, 'V002' ) // PROFIL
  Private tmp_V009 := getv009( sys_date ) // rslt
  Private tmp_V012 := getv012( sys_date ) // ishod
  Private arr_doc := { '��� ஦�.', ;
    '����', ;
    '����� �����', ;
    '�ப� ���.', ;
    '�������', ;
    '���', ;
    '���', ;
    '���.���', ;
    '��㣨', ;
    '���.���਩' }
  If yes_parol
    AAdd( arr_doc, '��� �����' )
  Endif
  AAdd( arr_doc, '����� ���.' )
  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5, , , @lcount_uch ) ) == NIL
    Return Nil
  Endif
  If yes_bukva
    Private md_plus := Array( Len( yes_d_plus ) )
    k_plus := Len( md_plus )
    AFill( md_plus, ' ' )
    AEval( md_plus, {| x, i| md_plus[ i ] := SubStr( yes_d_plus, i, 1 ) } )
    sd_plus := Array( k_plus )
    AFill( sd_plus, 0 )
  Endif
  Private pr_arr := {}, pr_arr_otd := {}, is_talon := ret_is_talon(), arr_tal_diag[ 2, 3 ], mm_pz := {}
  afillall( arr_tal_diag, 0 )

  If is_talon
    is_kategor2 := !Empty( stm_kategor2 )
  Endif
  //
  r_use( dir_server + 'mo_otd', , 'OTD' )
  dbEval( {|| AAdd( pr_arr, { otd->( RecNo() ), otd->name, otd->kod_lpu, '' } ) }, ;
    {|| f_is_uch( st_a_uch, otd->kod_lpu ) .and. between_date( otd->dbegin, otd->dend, sys_date ) } )
  r_use( dir_server + 'mo_uch', , 'UCH' )
  AEval( pr_arr, {| x, i| dbGoto( x[ 3 ] ), pr_arr[ i, 4 ] := uch->name } )
  //
  ASort( pr_arr, , , {| x, y| iif( x[ 3 ] == y[ 3 ], Upper( x[ 2 ] ) < Upper( y[ 2 ] ), Upper( x[ 4 ] ) < Upper( y[ 4 ] ) ) } )
  AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 2 ] + ' ' + x[ 4 ] ) } )
  Close databases
  //
  lvid_doc := SetBit( lvid_doc, 3 )
  lvid_doc := SetBit( lvid_doc, 5 )
  //
  Private pdate_lech, pdate_schet, pdate_usl, pdate_vvod, mstr_crb := 0, mstr_crbM := {}, mslugba
  //
  dbCreate( cur_dir + 'tmp', { ;
    { 'U_KOD',    'N',      4,      0 }, ;  // ��� ��㣨
    { 'U_SHIFR',  'C',     10,      0 }, ;  // ��� ��㣨
    { 'U_NAME',   'C',     65,      0 } ;   // ������������ ��㣨
  } )
  Use ( cur_dir + 'tmp' )
  Index On Str( u_kod, 4 ) to ( cur_dir + 'tmpk' )
  Index On fsort_usl( u_shifr ) to ( cur_dir + 'tmpn' )
  tmp->( dbCloseArea() )
  //
  dbCreate( cur_dir + 'tmpF', { ;
    { 'U_KOD',    'N',      6,      0 }, ;  // ��� ��㣨
    { 'U_SHIFR',  'C',     20,      0 }, ;  // ��� ��㣨
    { 'U_NAME',   'C',    255,      0 } ;   // ������������ ��㣨
  } )
  Use ( cur_dir + 'tmpF' )
  Index On Str( u_kod, 6 ) to ( cur_dir + 'tmpFk' )
  Index On fsort_usl( u_shifr ) to ( cur_dir + 'tmpFn' )
  tmpF->( dbCloseArea() )
  //
  AAdd( mm_tmp, { 'date_lech', 'N', 4, 0, NIL, ;
    {| x | menu_reader( x, ;
    { {| k, r, c | k := year_month( r + 1, c ), ;
    if( k == nil, NIL, ( pdate_lech := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    '��� ����砭�� ��祭��', ;
    {| g | st_pz_poisk( g ) } } )
  AAdd( mm_tmp, { 'date_schet', 'N', 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, NIL, ( pdate_schet := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    '��� �믨᪨ ���' } )
  AAdd( mm_tmp, { 'date_usl', 'N', 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, NIL, ( pdate_usl := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    '��� �������� ���' } )
  AAdd( mm_tmp, { 'date_vvod', 'N', 4, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c ), ;
    if( k == nil, NIL, ( pdate_vvod := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    '  ��� ����� ���ଠ樨' } )
  If yes_vypisan == B_END
    AAdd( mm_tmp, { 'zav_lech', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, mm_zav_lech, A__MENUVERT ) }, ;
      0, {|| Space( 10 ) }, ;
      '���� �����襭�� ��祭��?' } )
  Endif
  AAdd( mm_tmp, { 'reestr', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_reestr, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '� ॥���?' } )
  AAdd( mm_tmp, { 'schet', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_schet, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '� ����?' } )
  AAdd( mm_tmp, { 'regschet', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_regschet, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '���� ��ॣ����஢�� � �����?', , ;
    {|| m1schet == 2 } } )
  AAdd( mm_tmp, { 'perevyst', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_perevyst, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_perevyst, x ) }, ;
    '����� ��砨 ���뢠��?' } )
  AAdd( mm_tmp, { 'rak', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_rak, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_rak, x ) }, ;
    '����� � ���� ����஫� (���)' } )
  AAdd( mm_tmp, { 'd_p_m', 'N', 10, 0, NIL, ;
    {| x| menu_reader( x, mm_d_p_m, A__MENUBIT ) }, ;
    0, {| x| inieditspr( A__MENUBIT, mm_d_p_m, x ) }, ;
    '��ᯠ��ਧ���/��䨫��⨪�/����ᬮ��?' } )
  AAdd( mm_tmp, { 'pz', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_pz, A__MENUVERT_SPACE ) }, ;
    0, {|| Space( 10 ) }, ;
    '��� ����-������' } )
  AAdd( mm_tmp, { 'dvojn', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_dvojn, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_dvojn, x ) }, ;
    '���뢠�� ������ ��砨?' } )
  AAdd( mm_tmp, { 'zno', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '�ਧ��� �����७�� �� ���?' } )
  AAdd( mm_tmp, { 'kol_lu', 'N', 2, 0, , ;
    nil, ;
    0, NIL, ;
    '������⢮ ���⮢ ��� �� ������ ���쭮�� �����' } )
  AAdd( mm_tmp, { 'kol_pos', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '������뢠�� ������⢮ ���㫠���� � �⮬�⮫����᪨� ���饭��?' } )
  AAdd( mm_tmp, { 'uch_doc', 'C', 10, 0, '@!', ;
    nil, ;
    Space( 10 ), NIL, ;
    '� ���.�����/���ਨ ������� (蠡���)' } )
  Private arr_uchast := {}
  If is_uchastok > 0
    AAdd( mm_tmp, { 'bukva', 'C', 1, 0, '@!', ;
      nil, ;
      ' ', NIL, ;
      '�㪢� (��। ���⪮�)' } )
    AAdd( mm_tmp, { 'uchast', 'N', 1, 0, , ;
      {| x| menu_reader( x, { {|k, r, c| get_uchast( r + 1, c ) } }, A__FUNCTION ) }, ;
      0, {|| init_uchast( arr_uchast ) }, ;
      '���⮪ (���⪨)' } )
  Endif
  If glob_mo[ _MO_IS_UCH ]
    AAdd( mm_tmp, { 'o_prik', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, mm_prik, A__MENUVERT ) }, ;
      0, {| x| inieditspr( A__MENUVERT, mm_prik, x ) }, ;
      '�⭮襭�� � �ਪ९����� �� ��砫� ��祭��' } )
  Endif
  AAdd( mm_tmp, { 'fio', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), NIL, ;
    '��� (��砫�� �㪢� ��� 蠡���)' } )
  AAdd( mm_tmp, { 'inostran', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '���㬥��� �����࠭��� �ࠦ���:' } )
  AAdd( mm_tmp, { 'gorod_selo', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_g_selo, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    '��⥫�:' } )
  AAdd( mm_tmp, { 'mi_git', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_mest, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    '���� ��⥫��⢠:' } )
  AAdd( mm_tmp, { '_okato', 'C', 11, 0, NIL, ;
    {| x| menu_reader( x, { {|k, r, c| get_okato_ulica( k, r, c, { k, m_okato, } ) } }, A__FUNCTION ) }, ;
    Space( 11 ), {| x| Space( 11 ) }, ;
    '���� ॣ����樨 (�����)' } )
  AAdd( mm_tmp, { 'adres', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), NIL, ;
    '���� (�����ப� ��� 蠡���)' } )
  AAdd( mm_tmp, { 'mr_dol', 'C', 20, 0, '@!', ;
    nil, ;
    Space( 20 ), NIL, ;
    '���� ࠡ��� (�����ப� ��� 蠡���)' } )
  AAdd( mm_tmp, { 'invalid', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_invalid, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_invalid, x ) }, ;
    '����稥 �����������' } )
  AAdd( mm_tmp, { 'kategor', 'N', 4, 0, NIL, ;
    {| x| menu_reader( x, mo_cut_menu( stm_kategor ), A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '��� ��⥣�ਨ �죮��' } )
  If is_talon
    If is_kategor2
      AAdd( mm_tmp, { 'kategor2', 'N', 4, 0, NIL, ;
        {| x| menu_reader( x, stm_kategor2, A__MENUVERT ) }, ;
        0, {|| Space( 10 ) }, ;
        '��⥣��� ��' } )
    Endif
  Endif
  AAdd( mm_tmp, { 'pol', 'C', 1, 0, '!', ;
    nil, ;
    ' ', NIL, ;
    '���', {|| mpol $ ' ��' } } )
  AAdd( mm_tmp, { 'vzros_reb', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, menu_vzros, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    '�����⭠� �ਭ����������' } )
  AAdd( mm_tmp, { 'god_r_min', 'D', 8, 0, , ;
    nil, ;
    CToD( '' ), NIL, ;
    '��� ஦����� (�������쭠�)' } )
  AAdd( mm_tmp, { 'god_r_max', 'D', 8, 0, , ;
    nil, ;
    CToD( '' ), NIL, ;
    '��� ஦����� (���ᨬ��쭠�)' } )
  AAdd( mm_tmp, { 'rab_nerab', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, menu_rab, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    '������騩/��ࠡ���騩' } )
  AAdd( mm_tmp, { 'USL_OK', 'N', 3, 0, NIL, ;
    {| x| menu_reader( x, tmp_V006, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    '����樭᪠� ������: �᫮��� ��������', ;
    {| g, o| f_valid_usl_ok( g, o, .f. ) } } )
  /*aadd(mm_tmp, {'VIDPOM', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, tmp_V008, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              '  ���'})*/
  AAdd( mm_tmp, { 'PROFIL', 'N', 3, 0, NIL, ;
    {| x| menu_reader( x, tmp_V002, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    '  ��䨫� (� ��砥)' } )
  AAdd( mm_tmp, { 'PROFIL_U', 'N', 3, 0, NIL, ;
    {| x| menu_reader( x, tmp_V002, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    '  ��䨫� (� ��㣥)' } )
  /*aadd(mm_tmp, {'IDSP', 'N', 3, 0, NIL, ;
              {|x| menu_reader(x, tmp_V010, A__MENUVERT)}, ;
              -1, {|| space(10) }, ;
              '  ᯮᮡ ������'})*/
  AAdd( mm_tmp, { 'rslt', 'N', 3, 0, NIL, ;
    {| x| menu_reader( x, mm_rslt, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    '������� ���饭��', , ;
    {|| m1usl_ok > 0 } } )
  AAdd( mm_tmp, { 'ishod', 'N', 3, 0, NIL, ;
    {| x| menu_reader( x, mm_ishod, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    '��室 �����������', , ;
    {|| m1usl_ok > 0 } } )
  /*if is_talon
    aadd(mm_tmp, {'povod', 'N', 2, 0, NIL, ;
                {|x| menu_reader(x, stm_povod, A__MENUVERT)}, ;
                0, {|| space(10) }, ;
                '����� ���饭��'})
    aadd(mm_tmp, {'travma', 'N', 2, 0, NIL, ;
                {|x| menu_reader(x, stm_travma, A__MENUVERT)}, ;
                -1, {|| space(10) }, ;
                '��� �ࠢ��'})
  endif*/
  AAdd( mm_tmp, { 'bolnich1', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, menu_bolnich, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '���쭨��?' } )
  AAdd( mm_tmp, { 'bolnich', 'N', 3, 0, , ;
    nil, ;
    0, NIL, ;
    '���-�� ���� �� ���쭨筮� �����' } )
  AAdd( mm_tmp, { 'vrach1', 'N', 5, 0, NIL, ;
    nil, ;
    0, NIL, ;
    '���騩 ���', ;
    {| g| st_v_vrach( g, 'mvrach' ) } } )
  AAdd( mm_tmp, { 'vrach', 'C', 50, 0, NIL, ;
    nil, ;
    Space( 50 ), NIL, ;
    '            ', , ;
    {|| .f. } } )
  If yes_bukva
    AAdd( mm_tmp, { 'status_st', 'C', 5, 0, '@!', ;
      nil, ;
      Space( 5 ), NIL, ;
      '����� �⮬�⮫����᪮�� ���쭮��' } )
  Endif
  AAdd( mm_tmp, { 'diag', 'C', 5, 0, '@!', ;
    nil, ;
    Space( 5 ), NIL, ;
    '���� �������� (��.+ᮯ��.): [ � ]', ;
    {|| val2_10diag() } } )
  AAdd( mm_tmp, { 'diag1', 'C', 5, 0, '@!', ;
    nil, ;
    Space( 5 ), NIL, ;
    '                            [ �� ]', ;
    {|| val2_10diag() } } )
  AAdd( mm_tmp, { 'kod_diag', 'C', 5, 0, '@!', ;
    nil, ;
    Space( 5 ), NIL, ;
    '���� ��������� ��������: [ � ]', ;
    {|| val2_10diag() } } )
  AAdd( mm_tmp, { 'kod_diag1', 'C', 5, 0, '@!', ;
    nil, ;
    Space( 5 ), NIL, ;
    '                        [ �� ]', ;
    {|| val2_10diag() } } )
  AAdd( mm_tmp, { 'soput_d', 'C', 5, 0, '@!', ;
    nil, ;
    Space( 5 ), NIL, ;
    '���� �������������� ��������: [ � ]', ;
    {|| val2_10diag() } } )
  AAdd( mm_tmp, { 'soput_d1', 'C', 5, 0, '@!', ;
    nil, ;
    Space( 5 ), NIL, ;
    '                             [ �� ]', ;
    {|| val2_10diag() } } )
  AAdd( mm_tmp, { 'osl_d', 'C', 5, 0, '@!', ;
    nil, ;
    Space( 5 ), NIL, ;
    '���� �������� ����������: [ � ]', ;
    {|| val2_10diag() } } )
  AAdd( mm_tmp, { 'osl_d1', 'C', 5, 0, '@!', ;
    nil, ;
    Space( 5 ), NIL, ;
    '                         [ �� ]', ;
    {|| val2_10diag() } } )
  AAdd( mm_tmp, { 'pred_d', 'C', 5, 0, '@!', ;
    nil, ;
    Space( 5 ), NIL, ;
    '���� ���������������� ��������: [ � ]', ;
    {|| val2_10diag() } } )
  AAdd( mm_tmp, { 'pred_d1', 'C', 5, 0, '@!', ;
    nil, ;
    Space( 5 ), NIL, ;
    '                               [ �� ]', ;
    {|| val2_10diag() } } )
  If is_talon
    AAdd( mm_tmp, { 'talon_diag', 'N', 1, 0, NIL, ;
      {| x| menu_reader( x, { {| k, r, c| f_mn_tal_diag( k, r, c ) } }, A__FUNCTION ) }, ;
      0, {|| Space( 10 ) }, ;
      '��������� ⠫�� ���㫠�୮�� ��樥��?', , ;
      {|| !emptyall( mdiag, mkod_diag, msoput_d ) } } )
  Endif
  AAdd( mm_tmp, { 'otd', 'N', 3, 0, NIL, ;
    {| x| menu_reader( x, { {|k, r, c| get_otd( k, r + 1, c ) } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    '�⤥�����, � ���஬ �믨ᠭ ���' } )
  AAdd( mm_tmp, { 'ist_fin', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_ist_fin, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    '���筨� 䨭���஢����' } )
  AAdd( mm_tmp, { 'komu', 'N', 2, 0, NIL, ;
    {| x| menu_reader( x, mm_komu, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    '�ਭ���������� ����', ;
    {| g, o| f_valid_komu( g, o ) } } )
  AAdd( mm_tmp, { 'company', 'N', 5, 0, NIL, ;
    {| x| menu_reader( x, mm_company, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '  ==>', , {|| eq_any( m1komu, 0, 1, 3 ) } } )
  AAdd( mm_tmp, { 'uslugi', 'N', 4, 0, NIL, ;
    {| x| menu_reader( x, { {|k, r, c| ob2_v_usl( .t., r + 1, '��㣨 (�����)' ) } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    '�������� ��㣨 (�����)' } )
  AAdd( mm_tmp, { 'uslugiF', 'N', 4, 0, NIL, ;
    {| x| menu_reader( x, { {|k, r, c| obf2_v_usl( .t., r + 1, '��㣨 (�����)', 'tmpF' ) } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    '�������� ��㣨 (�����)' } )
  AAdd( mm_tmp, { 'dom', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_dom, A__MENUVERT ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_dom, x ) }, ;
    '��� ������� ��㣠', , ;
    {|| m1usl_ok == USL_OK_POLYCLINIC } } )
  AAdd( mm_tmp, { 'otd_usl', 'N', 3, 0, NIL, ;
    {| x| menu_reader( x, { {|k, r, c| get_otd( k, r + 1, c ) } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    '�⤥�����, � ���஬ ������� ��㣠' } )
  AAdd( mm_tmp, { 'vr1', 'N', 5, 0, NIL, ;
    nil, ;
    0, NIL, ;
    '���, ������訩 ����(�)', ;
    {| g| st_v_vrach( g, 'mvr' ) } } )
  AAdd( mm_tmp, { 'vr', 'C', 50, 0, NIL, ;
    nil, ;
    Space( 50 ), NIL, ;
    '                         ', , ;
    {|| .f. } } )
  AAdd( mm_tmp, { 'isvr', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '��� ��� ���⠢���?', , ;
    {|| mvr1 == 0 } } )
  AAdd( mm_tmp, { 'as1', 'N', 5, 0, NIL, ;
    nil, ;
    0, NIL, ;
    '����⥭�, ������訩 ����(�)', ;
    {| g| st_v_vrach( g, 'mas' ) } } )
  AAdd( mm_tmp, { 'as', 'C', 50, 0, NIL, ;
    nil, ;
    Space( 50 ), NIL, ;
    '                              ', , ;
    {|| .f. } } )
  AAdd( mm_tmp, { 'isas', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
    0, {|| Space( 10 ) }, ;
    '��� ����⥭� ���⠢���?', , ;
    {|| mas1 == 0 } } )
  AAdd( mm_tmp, { 'vras1', 'N', 5, 0, NIL, ;
    nil, ;
    0, NIL, ;
    '�������, ������訩 ����(�)', ;
    {| g| st_v_vrach( g, 'mvras' ) } } )
  AAdd( mm_tmp, { 'vras', 'C', 50, 0, NIL, ;
    nil, ;
    Space( 50 ), NIL, ;
    '                            ', , ;
    {|| .f. } } )
  AAdd( mm_tmp, { 'slug_usl', 'N', 3, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {|k, r, c| get_slugba( k, r, c ) } }, A__FUNCTION ) }, ;
    0, {|| Space( 10 ) }, ;
    '��㦡�, � ���ன ������� ��㣠' } )
  AAdd( mm_tmp, { 'srok_min', 'N', 3, 0, , ;
    nil, ;
    0, NIL, ;
    '�ப ��祭�� (���������)' } )
  AAdd( mm_tmp, { 'srok_max', 'N', 3, 0, , ;
    nil, ;
    0, NIL, ;
    '�ப ��祭�� (���ᨬ����)' } )
  AAdd( mm_tmp, { 'summa_min', 'N', 10, 2, , ;
    nil, ;
    0, NIL, ;
    '�㬬� ��祭�� (�������쭠�)' } )
  AAdd( mm_tmp, { 'summa_max', 'N', 10, 2, , ;
    nil, ;
    0, NIL, ;
    '�㬬� ��祭�� (���ᨬ��쭠�)' } )
  AAdd( mm_tmp, { 'vid_doc', 'N', 5, 0, NIL, ;
    {| x| menu_reader( x, arr_doc, A__MENUBIT ) }, ;
    lvid_doc, {| x| inieditspr( A__MENUBIT, arr_doc, x ) }, ;
    '������� ��� �뢮��', NIL } )
//  '��� ���㬥��', NIL } )
  AAdd( mm_tmp, { 'output', 'N', 1, 0, NIL, ;
    {| x| menu_reader( x, mm_output, A__MENUVERT ) }, ;
    1, {| x | inieditspr( A__MENUVERT, mm_output, x ) }, ;
    '�뢮� ����', , ;
     } )

  Delete File ( tmp_file )
  init_base( tmp_file, , mm_tmp, 0 )
  //
  r_use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO' )
  k := f_edit_spr( A__APPEND, mm_tmp, '������⢥����� ������', ;
    'e_use(cur_dir + "tmp_mn_p")', 0, 1, , , , , 'write_mn_p' )
  If k > 0
    mywait()
    Use ( tmp_file ) New Alias MN

    lExcel := iif(mn->output == 2, .t., .f. )

    If mn->ist_fin >= 0
      Private _arr_if := { mn->ist_fin }, _what_if := _init_if(), _arr_komit := {}
    Endif
    If is_talon .and. mn->kategor == 0 .and. mn->talon_diag == 0
      is_talon := ( is_kategor2 .and. mn->kategor2 > 0 )
    Endif
    If yes_vypisan == B_END .and. mn->zav_lech > 0
      Private p_zak_sl := ( mn->zav_lech == 2 )  // ? �����祭�� ��砩
      mn->zav_lech := yes_vypisan + mn->zav_lech -1
    Endif
    // �������� ⠡.����� �� ���
    r_use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO' )
    If mn->vrach1 > 0
      find ( Str( mn->vrach1, 5 ) )
      If Found()
        mn->vrach1 := perso->kod
      Endif
    Endif
    If mn->vr1 > 0
      find ( Str( mn->vr1, 5 ) )
      If Found()
        mn->vr1 := perso->kod
      Endif
    Endif
    If mn->as1 > 0
      find ( Str( mn->as1, 5 ) )
      If Found()
        mn->as1 := perso->kod
      Endif
    Endif
    If mn->vras1 > 0
      find ( Str( mn->vras1, 5 ) )
      If Found()
        mn->vras1 := perso->kod
      Endif
    Endif
    perso->( dbCloseArea() )
    If mn->date_schet > 0
      p_regim := 2
    Elseif mn->date_lech > 0
      p_regim := 1
    Elseif mn->date_usl > 0
      p_regim := 3
    Endif
    Private much_doc := '', mfio := '', madres := '', mmr_dol := ''
    If !Empty( mn->uch_doc )
      much_doc := AllTrim( mn->uch_doc )
      If !( Right( much_doc, 1 ) == '*' )
        much_doc += '*'
      Endif
    Endif
    If !Empty( mn->fio )
      mfio := AllTrim( mn->fio )
      If !( Right( mfio, 1 ) == '*' )
        mfio += '*'
      Endif
    Endif
    If !Empty( mn->adres )
      madres := AllTrim( mn->adres )
      If !( Left( madres, 1 ) == '*' )
        madres := '*' + madres
      Endif
      If !( Right( madres, 1 ) == '*' )
        madres += '*'
      Endif
    Endif
    If !Empty( mn->mr_dol )
      mmr_dol := AllTrim( mn->mr_dol )
      If !( Left( mmr_dol, 1 ) == '*' )
        mmr_dol := '*' + mmr_dol
      Endif
      If !( Right( mmr_dol, 1 ) == '*' )
        mmr_dol += '*'
      Endif
    Endif
    Private arr_usl := {}, arr_uslF := {}, fl_summa := .t., NUMdiag, NUMdiag1
    // ��࠭�� ��������� ��������� ��ॢ��� � �᫮�� ���祭��
    If !emptyall( mn->diag, mn->diag1 )
      NUMdiag := diag2num( mn->diag )
      NUMdiag1 := diag2num( mn->diag1 )
    Endif
    Private NUMkod_diag, NUMkod_diag1
    If !emptyall( mn->kod_diag, mn->kod_diag1 )
      NUMkod_diag := diag2num( mn->kod_diag )
      NUMkod_diag1 := diag2num( mn->kod_diag1 )
    Endif
    Private NUMsoput_d, NUMsoput_d1
    If !emptyall( mn->soput_d, mn->soput_d1 )
      NUMsoput_d := diag2num( mn->soput_d )
      NUMsoput_d1 := diag2num( mn->soput_d1 )
    Endif
    Private NUMpred_d, NUMpred_d1
    If !emptyall( mn->pred_d, mn->pred_d1 )
      NUMpred_d := diag2num( mn->pred_d )
      NUMpred_d1 := diag2num( mn->pred_d1 )
    Endif
    Private NUMosl_d, NUMosl_d1
    If !emptyall( mn->osl_d, mn->osl_d1 )
      NUMosl_d := diag2num( mn->osl_d )
      NUMosl_d1 := diag2num( mn->osl_d1 )
    Endif
    If mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. ;
        mn->vras1 > 0 .or. mn->slug_usl > 0 .or. mn->uslugi > 0 .or. mn->uslugiF > 0 .or. mn->dom > 0
      fl_summa := .f.
    Endif
    If mn->uslugi > 0
      fl_rak_usl := .f.
      Use ( cur_dir + 'tmp' ) index ( cur_dir + 'tmpn' ) new
      Go Top
      dbEval( {|| AAdd( arr_usl, { tmp->u_kod, tmp->u_shifr, tmp->u_name, 0, 0, 0 } ), ;
        iif( Left( tmp->u_shifr, 3 ) == '71.', fl_rak_usl := .t., ) ;
        } )
      tmp->( dbCloseArea() )
      If !IsBit( mn->vid_doc, 6 )
        fl_rak_usl := .f.
      Endif
    Endif
    If mn->uslugiF > 0
      Use ( cur_dir + 'tmpF' ) index ( cur_dir + 'tmpFn' ) new
      Go Top
      dbEval( {|| AAdd( arr_uslF, { tmpf->u_kod, tmpf->u_shifr, tmpf->u_name, 0, 0, 0 } ) } )
      tmpf->( dbCloseArea() )
    Endif
    flag_hu := ( mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. mn->vras1 > 0 .or. ;
      mn->slug_usl > 0 .or. mn->uslugi > 0 .or. mn->dom > 0 .or. ;
      mn->kol_pos == 2 .or. mn->date_usl > 0 .or. mn->profil_u > 0 )
    flag_huF := ( mn->otd_usl > 0 .or. mn->vr1 > 0 .or. mn->as1 > 0 .or. mn->vras1 > 0 .or. ;
      mn->uslugiF > 0 .or. mn->dom > 0 .or. ;
      mn->kol_pos == 2 .or. mn->date_usl > 0 .or. mn->profil_u > 0 )
    dbCreate( cur_dir + 'tmp', { { 'kod',      'N', 7, 0 }, ;
      { 'kod_k',    'N', 7, 0 }, ;
      { 'stoim',    'N', 10, 2 }, ;
      { 'rak_p',    'N', 3, 0 }, ;
      { 'rak_s',    'N', 10, 2 } } )
    Use ( cur_dir + 'tmp' ) new
    dbCreate( cur_dir + 'tmp_k', { { 'kod_k', 'N', 7, 0 }, ;
      { 'kol',  'N', 6, 0 } } )
    Use ( cur_dir + 'tmp_k' ) new
    Index On Str( kod_k, 7 ) to ( cur_dir + 'tmp_k' )
    If mn->kol_pos == 2
      Private kol_pos_amb := 0, pol_pos_stom1 := 0, pol_pos_stom2 := 0, pol_pos_stom3 := 0
      dbCreate( cur_dir + 'tmp_kp', { { 'kod_k', 'N', 7, 0 }, ;
        { 'data', 'C', 4, 0 } } )
      Use ( cur_dir + 'tmp_kp' ) new
      Index On Str( kod_k, 7 ) + Data to ( cur_dir + 'tmp_kp' )
    Endif
    f1_diag_statist_bukva()
    fl_exit := .f.
    If p_regim == 3  // �� ��� �������� ��㣨
      dbCreate( cur_dir + 'tmp_hum', { { 'kod', 'N', 7, 0 } } )
      Use ( cur_dir + 'tmp_hum' ) new
      r_use( dir_server + 'human_u', dir_server + 'human_ud', 'HU' )
      find ( pdate_usl[ 7 ] )
      Index On kod to ( cur_dir + 'tmp_hu' ) While date_u <= pdate_usl[ 8 ] UNIQUE
      Go Top
      Do While !Eof()
        Select TMP_HUM
        Append Blank
        Replace kod With hu->kod
        Select HU
        Skip
      Enddo
      hu->( dbCloseArea() )
      tmp_hum->( dbCloseArea() )
    Endif
    If mem_trudoem == 2
      useuch_usl()
    Endif
    status_key( '^<Esc>^ - ��ࢠ�� ����' )
    If IsBit( mn->vid_doc, 6 ) .or. mn->rak > 0
      r_use( dir_server + 'mo_raksh', , 'RAKSH' )
      Index On Str( kod_h, 7 ) to ( cur_dir + 'tmp_raksh' )
    Endif
    use_base( 'lusl' )
    use_base( 'luslc' )
    use_base( 'luslf' )
    r_use( dir_server + 'mo_su', , 'MOSU' )
    r_use( dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU' )
    r_use( dir_server + 'uslugi', , 'USL' )
    r_use( dir_server + 'human_u_', , 'HU_' )
    r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
    Set Relation To RecNo() into HU_, To u_kod into USL
    //
    r_use( dir_server + 'schet_', , 'SCHET_' )
    r_use( dir_server + 'schet', , 'SCHET' )
    Set Relation To RecNo() into SCHET_
    //
    r_use( dir_server + 'kartote2', , 'KART2' )
    r_use( dir_server + 'kartote_', , 'KART_' )
    r_use( dir_server + 'kartotek', , 'KART' )
    Set Relation To RecNo() into KART_, RecNo() into KART2
    //
    r_use( dir_server + 'human_3', { dir_server + 'human_3', dir_server + 'human_32' }, 'HUMAN_3' )
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human_2', , 'HUMAN_2' )
    r_use( dir_server + 'human', , 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
    //
    Private c_view := 0, c_found := 0
    Do Case
    Case p_regim == 1  // �� ��� ����砭�� ��祭��
      Select HUMAN
      Set Index to ( dir_server + 'humand' )
      dbSeek( DToS( pdate_lech[ 5 ] ), .t. )
      Do While human->k_data <= pdate_lech[ 6 ] .and. !Eof()
        If Inkey() == K_ESC
          fl_exit := .t.
          Exit
        Endif
        If f_is_uch( st_a_uch, human->lpu )
          date_24( human->k_data )
          s1_mnog_poisk( @c_view, @c_found )
        Endif
        Select HUMAN
        Skip
      Enddo
    Case p_regim == 2  // �� ��� �믨᪨ ���
      Select HUMAN
      Set Index to ( dir_server + 'humans' )
      Select SCHET
      Set Index to ( dir_server + 'schetd' )
      Set Filter To Empty( schet_->IS_DOPLATA )
      dbSeek( pdate_schet[ 7 ], .t. )
      Do While schet->pdate <= pdate_schet[ 8 ] .and. !Eof()
        date_24( c4tod( schet->pdate ) )
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod
          If Inkey() == K_ESC
            fl_exit := .t.
            Exit
          Endif
          If f_is_uch( st_a_uch, human->lpu )
            s1_mnog_poisk( @c_view, @c_found )
          Endif
          Select HUMAN
          Skip
        Enddo
        If fl_exit
          Exit
        Endif
        Select SCHET
        Skip
      Enddo
    Case p_regim == 3  // �� ��� �������� ��㣨
      Use ( cur_dir + 'tmp_hum' ) new
      Set Relation To kod into HUMAN
      Go Top
      Do While !Eof()
        If Inkey() == K_ESC
          fl_exit := .t.
          Exit
        Endif
        If f_is_uch( st_a_uch, human->lpu )
          date_24( human->k_data )
          s1_mnog_poisk( @c_view, @c_found )
        Endif
        Select TMP_HUM
        Skip
      Enddo
    Endcase
    j := tmp->( LastRec() )
    Close databases
    If j == 0
      If ! fl_exit
        func_error( 4, '��� ᢥ�����!' )
      Endif
    Else
      mywait()
      If lExcel
        workbook  := workbook_new( name_fileXLS_full )
        wsCommon := workbook_add_worksheet( workbook, hb_StrToUTF8( '���ᠭ��' ) )
        worksheet_set_column( wsCommon, 7, 7, 15, nil )
        wsCommon_format := fmt_excel_hC_vC( workbook )
        format_set_bold( wsCommon_format )

        wsCommon_format_wrap := fmt_excel_hL_vC( workbook )
        format_set_text_wrap( wsCommon_format_wrap )

        wsCommon_format_header := fmt_excel_hC_vC( workbook )
        format_set_bold( wsCommon_format_header )
        format_set_font_size( wsCommon_format_header, 20 )

        wsCommon_Number := fmt_excel_hC_vC( workbook )

        wsCommon_Number_Rub := fmt_excel_hR_vC( workbook )
        format_set_num_format( wsCommon_Number_Rub, '#,##0.00' )

        worksheet := workbook_add_worksheet( workbook, hb_StrToUTF8( '���᮪ ��樥�⮢' ) )
        formatDate := fmt_excel_hC_vC( workbook )
        format_set_num_format( formatDate, 'dd/mm/yyyy' )
        format_set_border( formatDate, LXW_BORDER_THIN )

        header = fmt_excel_hC_vC( workbook )
        format_set_fg_color( header, 0xD7E4BC )
        format_set_bold( header )
        format_set_border( header, LXW_BORDER_THIN )

        header_wrap = fmt_excel_hC_vC( workbook )
        format_set_fg_color( header_wrap, 0xD7E4BC )
        format_set_bold( header_wrap )
        format_set_border( header_wrap, LXW_BORDER_THIN )
        format_set_text_wrap( header_wrap )

        fmtCellNumber := fmt_excel_hC_vC( workbook )
        format_set_border( fmtCellNumber, LXW_BORDER_THIN )

        fmtCellNumberRub := fmt_excel_hR_vC( workbook )
        format_set_border( fmtCellNumberRub, LXW_BORDER_THIN )
        format_set_num_format( fmtCellNumberRub, '#,##0.00' )

        fmtCellString := fmt_excel_hL_vC( workbook )
        format_set_text_wrap( fmtCellString )
        format_set_border( fmtCellString, LXW_BORDER_THIN )

        fmtCellStringCenter := fmt_excel_hC_vC( workbook )
        format_set_text_wrap( fmtCellStringCenter )
        format_set_border( fmtCellStringCenter, LXW_BORDER_THIN )

        /* ����஧�� ������ ��ப� �� ��������. */
        // WORKSHEET_FREEZE_PANES(worksheet, row, 0)
      Endif
      row := 0
      column := 0
      rowWS := 1
      columnWS := 0
      Use ( tmp_file ) New Alias MN
      s1 := if( fl_summa, '  �㬬�  ', '�⮨�����' )
      s2 := if( fl_summa, ' ��祭�� ', '  ���  ' )
      If lExcel
        // WORKSHEET_SET_COLUMN(worksheet, row, column, 100, nil)
        worksheet_set_column( worksheet, column, column, 35, nil )
        worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '�.�.�. ���쭮��' ), header )
        worksheet_set_column( worksheet, column, column, 22, nil )
        worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '���' ), header )
        worksheet_set_column( worksheet, column, column, 15, nil )
        worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '�����' ), header )
        worksheet_set_column( worksheet, column, column, 11, nil )
        worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( iif( fl_summa, '�㬬� ��祭��', '�⮨����� ���' ) ), header_wrap )
      else
        arr_title := { ;
          '��������������������������������������������������', ;
          '             �.�.�. ���쭮��            �' + s1, ;
          '                                        �' + s2, ;
          '��������������������������������������������������' }
      Endif
      If IsBit( mn->vid_doc, 1 )
        If lExcel
          worksheet_set_column( worksheet, column, column, 10.0, nil )
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '��� ஦�����' ), header_wrap )
        else
          arr_title[ 1 ] += '���������'
          arr_title[ 2 ] += '�  ���  '
          arr_title[ 3 ] += '�஦�����'
          arr_title[ 4 ] += '���������'
        Endif
      Endif
      If IsBit( mn->vid_doc, 2 )
        If lExcel
          worksheet_set_column( worksheet, column, column, 22.0, nil )
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '����' ), header )
        else
          arr_title[ 1 ] += '�������������������������'
          arr_title[ 2 ] += '�         ����          '
          arr_title[ 3 ] += '�                        '
          arr_title[ 4 ] += '�������������������������'
        Endif
      Endif
      If IsBit( mn->vid_doc, 12 )
        If lExcel
          worksheet_set_column( worksheet, column, column, 11.0, nil )
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '����� ⥫�䮭��' ), header_wrap )
        else
          arr_title[ 1 ] += '�����������'
          arr_title[ 2 ] += '�   ����� '
          arr_title[ 3 ] += '� ⥫�䮭��'
          arr_title[ 4 ] += '�����������'
        Endif
      Endif
      If IsBit( mn->vid_doc, 3 )
        If lExcel
          worksheet_set_column( worksheet, column, column, 10.0, nil )
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( 'N �����' ), header )
        else
          arr_title[ 1 ] += '�����������'
          arr_title[ 2 ] += '�  N ����� '
          arr_title[ 3 ] += '�          '
          arr_title[ 4 ] += '�����������'
        Endif
      Endif
      If IsBit( mn->vid_doc, 4 )
        If lExcel
          worksheet_set_column( worksheet, column, column, 10.0, nil )
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '�ப� ��祭��' ), header_wrap )
        else
          arr_title[ 1 ] += '���������'
          arr_title[ 2 ] += '� �ப�  '
          arr_title[ 3 ] += '���祭�� '
          arr_title[ 4 ] += '���������'
        Endif
      Endif
      If IsBit( mn->vid_doc, 5 )
        If lExcel
          worksheet_set_column( worksheet, column, column, 11, nil )
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '�������' ), header )
        else
          arr_title[ 1 ] += '��������������'
          arr_title[ 2 ] += '�   �������   '
          arr_title[ 3 ] += '�             '
          arr_title[ 4 ] += '��������������'
        Endif
      Endif
      If IsBit( mn->vid_doc, 6 )
        If lExcel
          worksheet_set_column( worksheet, column, column, 19.0, nil )
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '����� � ��� ���' ), header_wrap )
        else
          arr_title[ 1 ] += '����������������'
          arr_title[ 2 ] += '� ����� � ���  '
          arr_title[ 3 ] += '�    ���      '
          arr_title[ 4 ] += '����������������'
        Endif
      Endif
      If IsBit( mn->vid_doc, 7 )
        r_use( dir_server + 'mo_raksh', cur_dir + 'tmp_raksh', 'RAKSH' )
        If lExcel
          worksheet_set_column( worksheet, column, column, 13.0, nil )
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '���' ), header_wrap )
        else
          arr_title[ 1 ] += '����������'
          arr_title[ 2 ] += '�   ���   '
          arr_title[ 3 ] += '�         '
          arr_title[ 4 ] += '����������'
        Endif
      Endif
      If IsBit( mn->vid_doc, 8 )
        If lExcel
          worksheet_set_column( worksheet, column, column, 10.0, nil )
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '���. ���' ), header_wrap )
        else
          arr_title[ 1 ] += '������'
          arr_title[ 2 ] += '� ���.'
          arr_title[ 3 ] += '� ���'
          arr_title[ 4 ] += '������'
        Endif
      Endif
      If IsBit( mn->vid_doc, 9 )
        If lExcel
          worksheet_set_column( worksheet, column, column, 10.0, nil )
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '���᮪ ���' ), header_wrap )
        else
          arr_title[ 1 ] += '������������������������'
          arr_title[ 2 ] += '�                       '
          arr_title[ 3 ] += '�     ���᮪ ���      '
          arr_title[ 4 ] += '������������������������'
        Endif
      Endif
      If IsBit( mn->vid_doc, 10 )
        If lExcel
          worksheet_set_column( worksheet, column, column, 10.0, nil )
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '��������. ���਩' ), header_wrap )
        else
          arr_title[ 1 ] += '���������'
          arr_title[ 2 ] += '���������'
          arr_title[ 3 ] += '����਩'
          arr_title[ 4 ] += '���������'
        Endif
      Endif
      If yes_parol
        If IsBit( mn->vid_doc, 11 )
          If lExcel
            worksheet_set_column( worksheet, column, column, 10.0, nil )
            worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '��� ����� � ������' ), header_wrap )
          else
            arr_title[ 1 ] += '�����������'
            arr_title[ 2 ] += '���� �����'
            arr_title[ 3 ] += '�� ������'
            arr_title[ 4 ] += '�����������'
          Endif
        Endif
      Endif
      if ! lExcel
        reg_print := f_reg_print( arr_title, @sh, 2 )
      endif
      If sh < 65
        sh := 65
      Endif
      r_use( dir_server + 'human_u_', , 'HU_' )
      r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
      Set Relation To RecNo() into HU_
      r_use( dir_server + 'uslugi', , 'USL' )
      r_use( dir_server + 'mo_su', , 'MOSU' )
      r_use( dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU' )
      r_use( dir_server + 'schet_', , 'SCHET_' )
      r_use( dir_server + 'schet', , 'SCHET' )
      Set Relation To RecNo() into SCHET_
      If yes_parol
        r_use( dir_server + 'base1', , 'BASE1' )
      Endif
      r_use( dir_server + 'mo_pers', , 'PERSO' )
      r_use( dir_server + 'kartote2', , 'KART2' )
      r_use( dir_server + 'kartote_', , 'KART_' )
      r_use( dir_server + 'kartotek', , 'KART' )
      Set Relation To RecNo() into KART_, To RecNo() into KART2
      r_use( dir_server + 'mo_onksl', dir_server + 'mo_onksl', 'ONKSL' ) // �������� � ��砥 ��祭�� ���������᪮�� �����������
      r_use( dir_server + 'human_3', { dir_server + 'human_3', dir_server + 'human_32' }, 'HUMAN_3' )
      r_use( dir_server + 'human_2', , 'HUMAN_2' )
      r_use( dir_server + 'human_', , 'HUMAN_' )
      r_use( dir_server + 'human', dir_server + 'humank', 'HUMAN' )
      Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2

      sOutput := '��������� ���������������� ������'
      sZag1 := '== ��������� ������ =='
      If lExcel
        worksheet_merge_range( wsCommon, rowWS, columnWS, rowWS, 12, '', wsCommon_format_header )
        worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( Expand( sOutput ) ), wsCommon_format_header )
        titlen_uchexcel( wsCommon, rowWS++, columnWS, st_a_uch, sh, lcount_uch )
        rowWS++
        worksheet_merge_range( wsCommon, rowWS, columnWS, rowWS, 12, '', wsCommon_format )
        worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sZag1 ), wsCommon_format )
      else
        fp := FCreate( name_file )
        n_list := 1
        tek_stroke := 0
        add_string( '' )
        add_string( Center( Expand( sOutput ), sh ) )
        titlen_uch( st_a_uch, sh, lcount_uch )
        add_string( '' )
        add_string( sZag1 )
      Endif

      If mn->date_lech > 0
        sOutput := '��� ����砭�� ��祭��: ' + pdate_lech[ 4 ]
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->date_schet > 0
        sOutput := '��� �믨᪨ ���: ' + pdate_schet[ 4 ]
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->date_usl > 0
        sOutput := '��� �������� ���: ' + pdate_usl[ 4 ]
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->perevyst != 1
        sOutput := Upper( inieditspr( A__MENUVERT, mm_perevyst, mn->perevyst ) )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->rak > 0
        sOutput := Upper( inieditspr( A__MENUVERT, mm_rak, mn->rak ) )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If yes_vypisan == B_END .and. mn->zav_lech > 0
        sOutput := '��祭�� �����襭�?: ' + iif( mn->zav_lech == B_STANDART, '��', '���' )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->reestr > 0
        sOutput := inieditspr( A__MENUVERT, mm_reestr, mn->reestr )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->schet > 0
        sOutput := inieditspr( A__MENUVERT, mm_schet, mn->schet )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
        If mn->schet == 2 .and. mn->regschet > 0
          sOutput :=  inieditspr( A__MENUVERT, mm_regschet, mn->regschet )
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Endif
      Endif
      If mn->d_p_m > 0
        s := '��ᯠ��ਧ���/��䨫��⨪�/����ᬮ��?: ' + ;
          inieditspr( A__MENUBIT, mm_d_p_m, mn->d_p_m )
        If lExcel
          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( s ), nil )
        else
          k := perenos( a_diagnoz, s, sh )
          add_string( a_diagnoz[ 1 ] )
          For i := 2 To k
            add_string( PadL( AllTrim( a_diagnoz[ i ] ), sh ) )
          Next
        Endif
      Endif
      If mn->pz > 0
        sOutput := '��� ����-������: ' + inieditspr( A__MENUVERT, mm_pz, mn->pz )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->dvojn > 1
        sOutput := '������ ��砨: ' + inieditspr( A__MENUVERT, mm_dvojn, mn->dvojn )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->zno == 2
        sOutput := '�ਧ��� ����७�� �� �������⢥���� ������ࠧ������: ��'
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->kol_lu > 0
        sOutput := '������⢮ ���⮢ ��� �� ������ ���쭮�� ����� ' + lstr( mn->kol_lu )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !Empty( much_doc )
        sOutput := '� ���.�����/���ਨ �������: ' + much_doc
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If is_uchastok > 0
        If !Empty( mn->bukva )
          sOutput := '�㪢�: ' + mn->bukva
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Endif
        If !Empty( mn->uchast )
          sOutput := '���⮪: ' + init_uchast( arr_uchast )
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Endif
      Endif
      If glob_mo[ _MO_IS_UCH ] .and. !Empty( mn->o_prik )
        sOutput := '�⭮襭�� � �ਪ९�����: ' + inieditspr( A__MENUVERT, mm_prik, mn->o_prik )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !Empty( mfio )
        sOutput := '���: ' + mfio
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->inostran > 0
        sOutput := '���㬥��� �����࠭��� �ࠦ���: ' + inieditspr( A__MENUVERT, mm_da_net, mn->inostran )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->gorod_selo > 0
        sOutput := '��⥫�: ' + inieditspr( A__MENUVERT, mm_g_selo, mn->gorod_selo )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->mi_git > 0
        sOutput := '���� ��⥫��⢠: ' + inieditspr( A__MENUVERT, mm_mest, mn->mi_git )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !Empty( mn->_okato )
        sOutput := '���� ॣ����樨 (�����): ' + ret_okato_ulica( '', mn->_okato )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !Empty( madres )
        sOutput := '����: ' + madres
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !Empty( mmr_dol )
        sOutput := '���� ࠡ���: ' + mmr_dol
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->invalid > 0
        sOutput := '����稥 �����������: ' + inieditspr( A__MENUVERT, mm_invalid, mn->invalid )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->kategor > 0
        sOutput := '��� ��⥣�ਨ �죮��: ' + inieditspr( A__MENUVERT, stm_kategor, mn->kategor )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If is_talon .and. is_kategor2 .and. mn->kategor2 > 0
        sOutput := '��⥣��� ��: ' + inieditspr( A__MENUVERT, stm_kategor2, mn->kategor2 )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !Empty( mn->pol )
        sOutput := '���: '
        If lExcel
          worksheet_write_string( wsCommon, rowWS, columnWS, hb_StrToUTF8( sOutput ), nil )
          worksheet_write_string( wsCommon, rowWS++, 1, hb_StrToUTF8( iif( Upper( mn->pol ) == '�', '��᪮�', '���᪨�' ) ), nil )
        else
          add_string( sOutput + iif( Upper( mn->pol ) == '�', '��᪮�', '���᪨�' ) )
        Endif
      Endif
      If mn->vzros_reb >= 0
        sOutput := '�����⭠� �ਭ����������: ' + inieditspr( A__MENUVERT, menu_vzros, mn->vzros_reb )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !Empty( mn->god_r_min ) .or. !Empty( mn->god_r_max )
        If Empty( mn->god_r_min )
          sOutput := '���, த��訥�� �� ' + full_date( mn->god_r_max )
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Elseif Empty( mn->god_r_max )
          sOutput := '���, த��訥�� ��᫥ ' + full_date( mn->god_r_min )
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Else
          sOutput := '���, த��訥�� � ' + full_date( mn->god_r_min ) + ' �� ' + full_date( mn->god_r_max )
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Endif
      Endif
      If mn->rab_nerab >= 0
        sOutput := Upper( inieditspr( A__MENUVERT, menu_rab, mn->rab_nerab ) )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->USL_OK > 0
        sOutput := '�᫮��� ��������: ' + inieditspr( A__MENUVERT, tmp_V006, mn->USL_OK )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      /*if mn->VIDPOM > 0
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('��� �����: ' + inieditspr(A__MENUVERT, tmp_V008, mn->VIDPOM)), nil)
        else
          add_string('��� �����: ' + inieditspr(A__MENUVERT, tmp_V008, mn->VIDPOM))
        endif
      endif*/
      If mn->PROFIL > 0
        sOutput := '��䨫� (� ��砥): ' + inieditspr( A__MENUVERT, tmp_V002, mn->PROFIL )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->PROFIL_U > 0
        sOutput := '��䨫� (� ��㣥): ' + inieditspr( A__MENUVERT, tmp_V002, mn->PROFIL_U )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      /*if mn->IDSP > 0
        if lExcel
          WORKSHEET_WRITE_STRING(wsCommon, rowWS++, columnWS, hb_StrToUtf8('���ᮡ ������: ' + inieditspr(A__MENUVERT, tmp_V010, mn->IDSP)), nil)
        else
          add_string('���ᮡ ������: ' + inieditspr(A__MENUVERT, tmp_V010, mn->IDSP))
        endif
      endif*/
      If mn->rslt > 0
        sOutput := '������� ���饭��: ' + inieditspr( A__MENUVERT, mm_rslt, mn->rslt )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->ishod > 0
        sOutput := '��室 �����������: ' + inieditspr( A__MENUVERT, mm_ishod, mn->ishod )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      /*if is_talon .and. mn->povod > 0
        add_string('����� ���饭��: '+;
                 inieditspr(A__MENUVERT, stm_povod, mn->povod))
      endif
      if is_talon .and. mn->travma > 0
        add_string('��� �ࠢ��: '+;
                 inieditspr(A__MENUVERT, stm_travma, mn->travma))
      endif*/
      If mn->bolnich1 > 0
        sOutput := '���쭨��: ' + inieditspr( A__MENUVERT, menu_bolnich, mn->bolnich1 )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->bolnich > 0
        sOutput := '���-�� ���� �� ���쭨筮� ����� ' + lstr( mn->bolnich )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->vrach1 > 0
        sOutput := '���騩 ���: ' + AllTrim( mn->vrach )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If yes_bukva .and. ! Empty( mn->status_st )
        sOutput := '����� �⮬�⮫����᪮�� ���쭮��: ' + AllTrim( mn->status_st )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !emptyany( mn->diag, mn->diag1 )
        sOutput := '���� �������� (��.+ᮯ��.): � ' + AllTrim( mn->diag ) + ' �� ' + AllTrim( mn->diag1 )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Elseif !Empty( mn->diag )
        sOutput := '���� �������� (��.+ᮯ��.): ' + mn->diag
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !emptyany( mn->kod_diag, mn->kod_diag1 )
        sOutput := '���� �᭮����� ��������: � ' + AllTrim( mn->kod_diag ) + ' �� ' + AllTrim( mn->kod_diag1 )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Elseif !Empty( mn->kod_diag )
        sOutput := '���� �᭮����� ��������: ' + mn->kod_diag
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !emptyany( mn->soput_d, mn->soput_d1 )
        sOutput := '���� ᮯ������饣� ��������: � ' + AllTrim( mn->soput_d ) + ' �� ' + AllTrim( mn->soput_d1 )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Elseif !Empty( mn->soput_d )
        sOutput := '���� ᮯ������饣� ��������: ' + mn->soput_d
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !emptyany( mn->osl_d, mn->osl_d1 )
        sOutput := '���� �������� �᫮������: � ' + AllTrim( mn->osl_d ) + ' �� ' + AllTrim( mn->osl_d1 )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Elseif !Empty( mn->osl_d )
        sOutput := '���� �������� �᫮������: ' + mn->osl_d
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If !emptyany( mn->pred_d, mn->pred_d1 )
        sOutput := '���� �।���⥫쭮�� ��������: � ' + AllTrim( mn->pred_d ) + ' �� ' + AllTrim( mn->pred_d1 )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Elseif !Empty( mn->pred_d )
        sOutput := '���� �।���⥫쭮�� ��������: ' + mn->pred_d
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If lExcel
        // �뢮� ���ଠ樨 � �ࠪ��, ��ᯠ��ਧ�樨...
        f_put_tal_diagexcel( wsCommon, rowWS++, columnWS )
      else
        f_put_tal_diag()
      Endif
      If yes_h_otd == 1 .and. mn->otd > 0
        sOutput := '�⤥�����, � ���஬ �믨ᠭ ���: ' + inieditspr( A__POPUPMENU, dir_server + 'mo_otd', mn->otd )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->ist_fin >= 0
        sOutput := '���筨� 䨭���஢���� ' + inieditspr( A__MENUVERT, mm_ist_fin, mn->ist_fin )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->komu >= 0
        sOutput := '�ਭ���������� ����: ' + inieditspr( A__MENUVERT, mm_komu, mn->komu )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif

        If mn->company > 0
          sOutput := '  ==> ' + inieditspr( A__MENUVERT, mm_company, mn->company )
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Endif
      Endif
      If mn->srok_min > 0 .or. mn->srok_max > 0
        sOutput := '�ப ��祭�� (���ᨬ����) ' + lstr( mn->srok_max ) + ' ��.'
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
        If Empty( mn->srok_min )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Elseif Empty( mn->srok_max )
          sOutput := '�ப ��祭�� (���������) ' + lstr( mn->srok_min ) + ' ��.'
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Else
          sOutput := '�ப ��祭�� �� ' + lstr( mn->srok_min ) + ' �� ' + lstr( mn->srok_max ) + ' ��.'
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Endif
      Endif
      If mn->summa_min > 0 .or. mn->summa_max > 0
        If Empty( mn->summa_min )
          sOutput := '�⮨����� ��祭�� ����� ' + lstr( mn->summa_max, 10, 2 )
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Elseif Empty( mn->summa_max )
          sOutput := '�⮨����� ��祭�� ����� ' + lstr( mn->summa_min, 10, 2 )
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Else
          sOutput := '�⮨����� ��祭�� � ��������� �� ' + lstr( mn->summa_min, 10, 2 ) + ' �� ' + lstr( mn->summa_max, 10, 2 )
          string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//          If lExcel
//            worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//          else
//            add_string( sOutput )
//          Endif
        Endif
      Endif
      If mn->dom > 0
        sOutput := '��� ������� ��㣠: ' + inieditspr( A__MENUVERT, mm_dom, mn->dom )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->otd_usl > 0
        sOutput := '�⤥�����, � ���஬ ������� ��㣠: ' + inieditspr( A__POPUPMENU, dir_server + 'mo_otd', mn->otd_usl )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->vr1 > 0
        sOutput := '���, ������訩 ����(�): ' + AllTrim( mn->vr )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->isvr > 0
        sOutput := '��� ��� ' + if( mn->isvr == 1, '�� ', '' ) + '���⠢���'
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->as1 > 0
        sOutput := '����⥭�, ������訩 ����(�): ' + AllTrim( mn->as )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->isas > 0
        sOutput := '��� ����⥭� ' + if( mn->isas == 1, '�� ', '' ) + '���⠢���'
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->vras1 > 0
        sOutput := '�������, ������訩 ����(�): ' + AllTrim( mn->vras )
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->date_vvod > 0
        sOutput := '��� �����: ' + pdate_vvod[ 4 ]
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->slug_usl > 0
        sOutput := '��㦡�, � ���ன ������� ��㣨: ' + mslugba[ 2 ]
        string_output( sOutput, lExcel, wsCommon, rowWS++, columnWS, nil )
//        If lExcel
//          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
//        else
//          add_string( sOutput )
//        Endif
      Endif
      If mn->uslugi > 0
        l := s := k := 0
        AEval( arr_usl, {| x| l := Max( l, Len( RTrim( x[ 3 ] ) ) ) } )
        If fl_rak_usl
          l -= 11
        Endif
        sOutput := '�������� ��㣨 (�����)'
        If lExcel
          worksheet_merge_range( wsCommon, rowWS, 0, rowWS, 5, hb_StrToUTF8( sOutput ), wsCommon_format )
          worksheet_write_string( wsCommon, rowWS, 6, hb_StrToUTF8( '���-��' ), wsCommon_format )
          worksheet_write_string( wsCommon, rowWS, 7, hb_StrToUTF8( '�⮨�����' ), wsCommon_format )
          If fl_rak_usl
            worksheet_write_string( wsCommon, rowWS, 8, hb_StrToUTF8( '���� ���' ), wsCommon_format )
          Endif
          rowWS++
        else
          verify_ff( HH -1, .t., sh )
          add_string( PadR( sOutput, l + 13 ) + '|���-��|  ��-��   ' + iif( fl_rak_usl, '| ���� ���', '' ) )
        Endif
        For i := 1 To Len( arr_usl )
          If lExcel
            worksheet_merge_range( wsCommon, rowWS, 0, rowWS, 5, hb_StrToUTF8( '  ' + arr_usl[ i, 2 ] + ' ' + PadR( arr_usl[ i, 3 ], l ) ), wsCommon_format_wrap )
            worksheet_write_number( wsCommon, rowWS, 6, arr_usl[ i, 4 ], wsCommon_Number )
            worksheet_write_number( wsCommon, rowWS, 7, arr_usl[ i, 5 ], wsCommon_Number_Rub )
            If fl_rak_usl .and. Left( arr_usl[ i, 2 ], 3 ) == '71.'
              worksheet_write_number( wsCommon, rowWS, 8, arr_usl[ i, 6 ], wsCommon_Number_Rub )
            Endif
            rowWS++
          else
            verify_ff( HH, .t., sh )
            add_string( '  ' + arr_usl[ i, 2 ] + ' ' + ;
              PadR( arr_usl[ i, 3 ], l ) + '|' + put_val( arr_usl[ i, 4 ], 5 ) + ' |' + put_kope( arr_usl[ i, 5 ], 10 ) + ;
              iif( fl_rak_usl .and. Left( arr_usl[ i, 2 ], 3 ) == '71.', '|' + put_kope( arr_usl[ i, 6 ], 10 ), '' ) )
            k += arr_usl[ i, 4 ]
            s += arr_usl[ i, 5 ]
          Endif
        Next
        If lExcel
          worksheet_write_string( wsCommon, rowWS, 1, hb_StrToUTF8( '�����:' ), nil )
          worksheet_write_number( wsCommon, rowWS, 6, k, wsCommon_Number )
          worksheet_write_number( wsCommon, rowWS++, 7, s, wsCommon_Number_Rub )
        else
          add_string( '  �����:     ������� ��� ' + lstr( k ) + ' �� �㬬� ' + lstr( s, 12, 2 ) + '�.' )
        Endif
      Endif
      If mn->uslugiF > 0
        l := s := k := 0
        AEval( arr_uslF, {| x| l := Max( l, Len( RTrim( x[ 3 ] ) ) ) } )
        sOutput := '�������� ��㣨 (�����)'
        sZag1 := '|���-��'
        If lExcel
          rowWS++
          worksheet_merge_range( wsCommon, rowWS, 0, rowWS, 5, hb_StrToUTF8( sOutput ), wsCommon_format )
          worksheet_write_string( wsCommon, rowWS++, 6, hb_StrToUTF8( sZag1 ), wsCommon_Number )
        else
          verify_ff( HH - 1, .t., sh )
          add_string( PadR( sOutput, l + 23 ) + sZag1 )
        Endif
        For i := 1 To Len( arr_uslF )
          If lExcel
            worksheet_merge_range( wsCommon, rowWS, 0, rowWS, 5, hb_StrToUTF8( arr_uslF[ i, 2 ] + ' ' + PadR( arr_uslF[ i, 3 ], l ) ), wsCommon_format_wrap )
            worksheet_write_number( wsCommon, rowWS++, 6, arr_uslF[ i, 4 ], wsCommon_Number )
          else
            verify_ff( HH, .t., sh )
            add_string( '  ' + arr_uslF[ i, 2 ] + ' ' + ;
              PadR( arr_uslF[ i, 3 ], l ) + '|' + put_val( arr_uslF[ i, 4 ], 5 ) )
          Endif
          k += arr_uslF[ i, 4 ]
        Next
        If lExcel
          worksheet_write_string( wsCommon, rowWS, 1, hb_StrToUTF8( '�����:' ), nil )
          worksheet_write_number( wsCommon, rowWS++, 6, k, nil )
        else
          add_string( '  �����:     ������� ��� ' + lstr( k ) )
        Endif
      Endif
      Use ( cur_dir + 'tmp_bbuk' ) index ( cur_dir + 'tmp_bbuk' ) new
      Use ( cur_dir + 'tmp_buk' ) index ( cur_dir + 'tmp_buk' ) new
      If LastRec() > 0
        sOutput := '�⮬�⮫����᪨� �����|����.|���砥�'
        If lExcel
          worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), nil )
        else
          verify_ff( HH -3, .t., sh )
          add_string( sOutput )
        Endif
        w1 := 17
        if ! lExcel
          f3_diag_statist_bukva( HH, sh )
        endif
      Endif
      sOutput := ' == ���������� ������ =='
      If lExcel
        rowWS++
        worksheet_merge_range( wsCommon, rowWS, columnWS, rowWS, 12, '', wsCommon_format )
        worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( sOutput ), wsCommon_format )
        worksheet_merge_range( wsCommon, rowWS, columnWS, rowWS, 12, '', wsCommon_format )
        worksheet_write_string( wsCommon, rowWS++, columnWS, hb_StrToUTF8( '(�. �� ���� "���᮪ ��樥�⮢")' ), nil )
        rowWS++
      else
        add_string( '' )
        add_string( sOutput )
      Endif

      If mn->kol_lu > 0
        Use ( cur_dir + 'tmp_k' ) index ( cur_dir + 'tmp_k' ) new
        Count To skol For tmp_k->kol > mn->kol_lu
        Use ( cur_dir + 'tmp' ) new
        Set Relation To Str( kod, 7 ) into HUMAN, To Str( kod_k, 7 ) into TMP_K
        Index On Upper( human->fio ) + DToS( human->k_data ) to ( cur_dir + 'tmp' ) ;
          For tmp_k->kol > mn->kol_lu
      Else
        Use ( cur_dir + 'tmp_k' ) new
        Use ( cur_dir + 'tmp' ) new
        Set Relation To Str( kod, 7 ) into HUMAN
        Index On Upper( human->fio ) + DToS( human->k_data ) to ( cur_dir + 'tmp' )
        add_string( '�⮣� ������⢮ ������: ' + lstr( tmp_k->( LastRec() ) ) + ' 祫.' )
        s := '�⮣� ���⮢ ���: ' + lstr( tmp->( LastRec() ) ) + ' �� �㬬� ' + lput_kop( ssumma, .t. ) + ' ��.'
        If suet > 0
          s += ' (' + AllTrim( str_0( suet, 15, 4 ) ) + ' ���)'
        Endif
        If lExcel
          worksheet_write_string( wsCommon, rowWS, columnWS, hb_StrToUTF8( '�⮣� ������⢮ ������ (祫.):' ), nil )
          worksheet_write_number( wsCommon, rowWS++, 7, tmp_k->( LastRec() ), nil )
          worksheet_write_string( wsCommon, rowWS, columnWS, hb_StrToUTF8( '�⮣� ���⮢ ���:' ), nil )
          worksheet_write_number( wsCommon, rowWS++, 7, tmp_k->( LastRec() ), nil )
          worksheet_write_string( wsCommon, rowWS, 1, hb_StrToUTF8( '�� �㬬� (��.):' ), nil )
          worksheet_write_number( wsCommon, rowWS, 7, ssumma, wsCommon_Number_Rub )
          If suet > 0
            worksheet_write_string( wsCommon, rowWS, 8, hb_StrToUTF8( '(' + AllTrim( str_0( suet, 15, 4 ) ) + ' ���)' ), nil )
          Endif
          rowWS++
        else
          add_string( s )
        Endif
      Endif
      If ! Empty( srak_s )
        sOutput := '�㬬�, ���� ��⠬� ����஫� '
        If lExcel
          worksheet_write_string( wsCommon, rowWS, columnWS, hb_StrToUTF8( sOutput + ' (��.)' ), nil )
          worksheet_write_number( wsCommon, rowWS++, 7, srak_s, nil )
        else
          add_string( sOutput + lput_kop( srak_s, .t. ) + ' ��.' )
        Endif
      Endif
      If mn->kol_pos == 2
        If lExcel
          worksheet_write_string( wsCommon, rowWS, 1, hb_StrToUTF8( '������⢮ ���㫠���� ���饭��:' ), nil )
          worksheet_write_number( wsCommon, rowWS++, 7, kol_pos_amb, nil )
          worksheet_write_string( wsCommon, rowWS, 1, hb_StrToUTF8( '������⢮ �⮬�⮫����᪨� ���饭�� �ᥣ�:' ), nil )
          worksheet_write_number( wsCommon, rowWS++, 7, pol_pos_stom1 + pol_pos_stom2 + pol_pos_stom3, nil )
          worksheet_write_string( wsCommon, rowWS, 1, hb_StrToUTF8( '� ⮬ �᫥' ), nil )
          worksheet_write_string( wsCommon, rowWS, 3, hb_StrToUTF8( '� ��祡��� 楫��:' ), nil )
          worksheet_write_number( wsCommon, rowWS++, 7, pol_pos_stom1, nil )
          worksheet_write_string( wsCommon, rowWS, 3, hb_StrToUTF8( '� ��䨫����᪮� 楫��:' ), nil )
          worksheet_write_number( wsCommon, rowWS++, 7, pol_pos_stom2, nil )
          worksheet_write_string( wsCommon, rowWS, 3, hb_StrToUTF8( '�� �������� ���⫮���� �����:' ), nil )
          worksheet_write_number( wsCommon, rowWS++, 7, pol_pos_stom3, nil )
        else
          verify_ff( HH -5, .t., sh )
          add_string( '������⢮ ���㫠���� ���饭��: ' + lstr( kol_pos_amb ) )
          add_string( '������⢮ �⮬�⮫����᪨� ���饭�� �ᥣ�: ' + lstr( pol_pos_stom1 + pol_pos_stom2 + pol_pos_stom3 ) )
          add_string( PadL(  '� ⮬ �᫥ � ��祡��� 楫��: ', 47 ) + lstr( pol_pos_stom1 ) )
          add_string( PadL(      '� ��䨫����᪮� 楫��: ', 47 ) + lstr( pol_pos_stom2 ) )
          add_string( PadL( '�� �������� ���⫮���� �����: ', 47 ) + lstr( pol_pos_stom3 ) )
        Endif
      Endif
      if ! lExcel
        add_string( '' )
        AEval( arr_title, {| x| add_string( x ) } )
      endif
      ssumma := skol_lu := 0
      Keyboard ''
      Select TMP
      Go Top
      Do While !Eof()
        If Inkey() == K_ESC
          fl_exit := .t.
          Exit
        Endif
        row++
        used_column := column + 1
        column := 0
        if ! lExcel
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
        endif
        //
        Select ONKSL
        find ( Str( human->kod, 7 ) )
        is_oncology := f_is_oncology( 1 )
        k_diagnoz := k_usl := 0
        AFill( tt_diagnoz, '' )
        AFill( tt_usl, '' )
        //
        is_2 := .f.
        rec_1 := 0
        mn_data := human->n_data
        If human->ishod == 89
          Select HUMAN_3
          Set Order To 2 // ����� �� ������ �� 2-�� ����
          find ( Str( human->kod, 7 ) )
          If Found()
            mn_data := human_3->N_DATA
            is_2 := .t.
            rec_1 := human_3->KOD
          Endif
        Endif
        //
        s1 := Left( human->fio, 40 )
        If lExcel
          worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( human->fio ), fmtCellString )
        Endif
        kart->( dbGoto( human->kod_k ) )
        If mem_kodkrt == 2
          s2 := ' ['
          If is_uchastok > 0
            s2 += AllTrim( kart->bukva )
            s2 += lstr( kart->uchast, 2 ) + '/'
          Endif
          If is_uchastok == 1
            s2 += lstr( kart->kod_vu )
          Elseif is_uchastok == 3
            s2 += AllTrim( kart2->kod_AK )
          Else
            s2 += lstr( kart->kod )
          Endif
          s2 += '] '
        Else
          s2 := Space( 7 )
        Endif
        If mn->komu < 0
          s2 += f4_view_list_schet( human->komu, cut_code_smo( human_->smo ), human->str_crb )
          If lExcel
            worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( f4_view_list_schet( human->komu, cut_code_smo( human_->smo ), human->str_crb ) ), fmtCellString )
          Endif
        Else
          column++
        Endif
        If yes_bukva .and. !Empty( human_->status_st )
          tmp1 := ' ' + AllTrim( human_->status_st )
          s2 := PadR( s2, 50 - Len( tmp1 ) ) + tmp1
        Else
          s2 := PadR( s2, 50 )
        Endif
        s3 := iif( mem_kodkrt == 2, Space( 1 ), Space( 7 ) )
        If !Empty( kart->SNILS )
          s3 += Transform( kart->SNILS, picture_pf ) + ' '
          If lExcel
            worksheet_write_string( worksheet, row, column++, Transform( kart->SNILS, picture_pf ), fmtCellString )
          Endif
        Else
          column++
        Endif
        If mn->invalid == 9
          If kart_->INVALID == 1
            s3 += '���.1��㯯� '
          Elseif kart_->INVALID == 2
            s3 += '���.2��㯯� '
          Elseif kart_->INVALID == 3
            s3 += '���.3��㯯� '
          Else
            s3 += '���-�������� '
          Endif
        Endif
        If mn->bolnich1 > 1 .or. mn->bolnich > 0
          s3 += '���쭨�. ' + Left( date_8( c4tod( human->date_b_1 ) ), 5 ) + '-' + date_8( c4tod( human->date_b_2 ) )
        Elseif !Empty( mmr_dol )
          s3 += AllTrim( kart->mr_dol )
        Endif
        s3 := PadR( s3, 50 )
        //
        s1 += Str( tmp->stoim, 10, 2 )
        If lExcel
          worksheet_write_number( worksheet, row, column++, tmp->stoim, fmtCellNumberRub )
        Endif
        ssumma += tmp->stoim
        ++skol_lu
        //
        //
        If IsBit( mn->vid_doc, 1 )
          s1 += ' ' + date_8( human->date_r )
          s2 += Space( 9 )
          s3 += Space( 9 )
          If lExcel
            worksheet_write_string( worksheet, row, column++, date_8( human->date_r ), fmtCellStringCenter )
          Endif
        Endif
        //
        If IsBit( mn->vid_doc, 2 ) // ����
          perenos( a_diagnoz, ret_okato_ulica( kart->adres, kart_->okatog, 0, 2 ), 24 )
          s1 += ' ' + PadR( AllTrim( a_diagnoz[ 1 ] ), 24 )
          s2 += ' ' + PadR( AllTrim( a_diagnoz[ 2 ] ), 24 )
          s3 += ' ' + PadR( AllTrim( a_diagnoz[ 3 ] ), 24 )
          If lExcel
            worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( ret_okato_ulica( kart->adres, kart_->okatog, 0, 2 ) ), fmtCellString )
          Endif
        Endif
        //
        If IsBit( mn->vid_doc, 12 ) // ⥫�䮭�
          KART->( dbSelectArea( human->kod_k ) )
          s1 += ' ' + PadR( AllTrim( kart_->Phone_h ), 10 )
          s2 += ' ' + PadR( AllTrim( kart_->Phone_m ), 10 )
          s3 += ' ' + PadR( AllTrim( kart_->Phone_w ), 10 )
          If lExcel
            worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( AllTrim( kart_->Phone_h ) + ' ' + AllTrim( kart_->Phone_m ) + ' ' + AllTrim( kart_->Phone_w ) ), fmtCellString )
          Endif
        Endif
        //
        If IsBit( mn->vid_doc, 3 ) // ����� �����
          s1 += Space( 11 )
          s2 += ' ' + human->uch_doc
          s3 += Space( 11 )
          If lExcel
            worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( human->uch_doc ), fmtCellString )
          Endif
        Endif
        //
        If IsBit( mn->vid_doc, 4 )
          If mn_data == human->k_data
            s1 += ' ' + date_8( human->k_data )
            s2 += Space( 9 )
          Else
            s1 += ' �' + Left( date_8( mn_data ), 5 ) + '��'
            s2 += ' ' + date_8( human->k_data )
          Endif
          s3 += Space( 9 )
          If lExcel
            worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( iif( mn_data == human->k_data, date_8( human->k_data ), '� ' + Left( date_8( mn_data ), 5 ) + ' �� ' + date_8( human->k_data ) ) ), fmtCellString )
          Endif
        Endif
        //
        If IsBit( mn->vid_doc, 5 )
          AFill( adiag_talon, 0 )
          For i := 1 To 16
            adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
          Next
          arr := diag_to_array(, .t., .t., .t., .t., adiag_talon )
          tmp1 := ''
          For i := 1 To Len( arr )
            tmp1 += arr[ i ] + ' '
          Next
          For i := 1 To 8
            If !Empty( s := SubStr( human->diag_plus, i, 1 ) )
              If yes_bukva .and. ( j := AScan( md_plus, s ) ) > 0
                sd_plus[ j ] ++
              Endif
            Endif
          Next
          k_diagnoz := perenos( a_diagnoz, tmp1, 13 )
          s1 += ' ' + PadC( AllTrim( a_diagnoz[ 1 ] ), 13 )
          s2 += ' ' + PadC( AllTrim( a_diagnoz[ 2 ] ), 13 )
          s3 += ' ' + PadC( AllTrim( a_diagnoz[ 3 ] ), 13 )
          If k_diagnoz > 3
            tt_diagnoz := AClone( a_diagnoz )
          Endif
          If lExcel
            worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( tmp1 ), fmtCellString )
          Endif
        Endif
        //
        If IsBit( mn->vid_doc, 6 )
          If human->tip_h >= B_SCHET .and. human->schet > 0
            Select SCHET
            Goto ( human->schet )
            s1 += ' ' + PadC( AllTrim( schet_->nschet ), 15 )
            s2 += ' ' + PadC( date_8( schet_->dschet ) + '�.', 15 )
          Else
            s1 += ' ' + PadC( '-', 15 )
            s2 += Space( 16 )
          Endif
          s3 += Space( 16 )
          If lExcel
            worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( iif( human->tip_h >= B_SCHET .and. human->schet > 0, AllTrim( schet_->nschet ) + ' ' + date_8( schet_->dschet ) + '�.', PadC( '-', 8 ) ) ), fmtCellString )
          Endif
        Endif
        //
        If IsBit( mn->vid_doc, 7 )
          If tmp->rak_p == 0
            s1 += ' ' + PadC( '�����-', 9 )
            s2 += ' ' + PadC( '������', 9 )
            s3 += Space( 10 )
          Else
            s1 += ' ' + PadR( '��� ' + lstr( tmp->rak_p ) + '%', 9 )
            If human_->oplata == 9
              s2 += ' ' + PadC( '��ॢ��-', 9 )
              s3 += ' ' + PadC( '⠢���', 9 )
            Else
              s2 += ' ' + PadC( lstr( tmp->rak_s, 9, 2 ), 9 )
              s3 += Space( 10 )
            Endif
          Endif
          If lExcel
            If tmp->rak_p == 0
              worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '����稢�����' ), fmtCellString )
            Else
              If human_->oplata == 9
                worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '��� ' + lstr( tmp->rak_p ) + '% ' + '��ॢ��⠢���' ), fmtCellString )
              Else
                worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( '��� ' + lstr( tmp->rak_p ) + '% ' + lstr( tmp->rak_s, 9, 2 ) ), fmtCellString )
              Endif
            Endif
          Endif
        Endif
        //
        If IsBit( mn->vid_doc, 8 )
          If human_->vrach > 0
            Select PERSO
            Goto ( human_->vrach )
            s1 += put_val( perso->tab_nom, 6 )
          Else
            s1 += Space( 6 )
          Endif
          s2 += Space( 6 )
          s3 += Space( 6 )
          If lExcel
            worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( put_val( perso->tab_nom, 6 ) ), fmtCellString )
          Endif
        Endif
        //
        If IsBit( mn->vid_doc, 9 )
          tmp1 := ''
          aup := {}
          ar := { human->kod }
          If is_2
            ins_array( ar, 1, rec_1 )
          Endif
          For j := 1 To Len( ar )
            Select HU
            find ( Str( ar[ j ], 7 ) )
            Do While hu->kod == ar[ j ] .and. !Eof()
              If hu->kol_1 > 0
                Select USL
                Goto ( hu->u_kod )
                // if empty(l1 := opr_shifr_TFOMS(usl->shifr1,usl->kod, human->k_data))
                l1 := usl->shifr
                // endif
                l3 := ''// iif(hu->is_edit > 1, '[-' + lstr(hu->is_edit) + '%]', '')
                If ( i := AScan( aup, {| x| x[ 1 ] == l1 .and. x[ 3 ] == l3 } ) ) == 0
                  AAdd( aup, { l1, 0, l3 } )
                  i := Len( aup )
                Endif
                aup[ i, 2 ] += hu->kol_1
              Endif
              Select HU
              Skip
            Enddo
          Next j
          ASort( aup, , , {| x, y| fsort_usl( x[ 1 ] ) < fsort_usl( y[ 1 ] ) } )
          For j := 1 To Len( ar )
            Select MOHU
            find ( Str( ar[ j ], 7 ) )
            Do While mohu->kod == ar[ j ] .and. !Eof()
              If !Empty( mohu->kol_1 )
                Select MOSU
                Goto ( mohu->u_kod )
                l1 := iif( Empty( mosu->shifr ), mosu->shifr1, mosu->shifr )
                l3 := ''
                If ( i := AScan( aup, {| x| x[ 1 ] == l1 .and. x[ 3 ] == l3 } ) ) == 0
                  AAdd( aup, { l1, 0, l3 } )
                  i := Len( aup )
                Endif
                aup[ i, 2 ] += mohu->kol_1
              Endif
              Select MOHU
              Skip
            Enddo
          Next j
          If mn->uslugi > 0
            bup := {}
            For i := 1 To Len( arr_usl )
              If ( l := AScan( aup, {| x| x[ 1 ] == arr_usl[ i, 2 ] } ) ) > 0
                AAdd( bup, AClone( aup[ l ] ) )
                ADel( aup, l )
                ASize( aup, Len( aup ) -1 )
              Endif
            Next
            For i := Len( bup ) To 1 Step -1
              AAdd( aup, nil )
              AIns( aup, 1 )
              aup[ 1 ] := bup[ i ]
            Next
          Endif
          If mn->uslugiF > 0
            bup := {}
            For i := 1 To Len( arr_uslF )
              If ( l := AScan( aup, {| x| x[ 1 ] == arr_uslF[ i, 2 ] } ) ) > 0
                AAdd( bup, AClone( aup[ l ] ) )
                ADel( aup, l )
                ASize( aup, Len( aup ) -1 )
              Endif
            Next
            For i := Len( bup ) To 1 Step -1
              AAdd( aup, nil )
              AIns( aup, 1 )
              aup[ 1 ] := bup[ i ]
            Next
          Endif
          For i := 1 To Len( aup )
            tmp1 += AllTrim( aup[ i, 1 ] ) + iif( aup[ i, 2 ] > 1, '(' + lstr( aup[ i, 2 ] ) + ')', '' ) + aup[ i, 3 ] + ','
          Next
          tmp1 := Left( tmp1, Len( tmp1 ) -1 )
          k_usl := perenos( a_diagnoz, tmp1, 23, ',' )
          s1 += ' ' + PadC( AllTrim( a_diagnoz[ 1 ] ), 23 )
          s2 += ' ' + PadC( AllTrim( a_diagnoz[ 2 ] ), 23 )
          s3 += ' ' + PadC( AllTrim( a_diagnoz[ 3 ] ), 23 )
          If k_usl > 3
            tt_usl := AClone( a_diagnoz )
          Endif
          If lExcel
            worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( tmp1 ), fmtCellString )
          Endif
        Endif
        //
        If IsBit( mn->vid_doc, 10 )
          AFill( a_diagnoz, '' )
          i := 0
          If !Empty( human_2->pc3 ) .and. !Left( human_2->pc3, 1 ) == '6' // �஬� '�����'
            a_diagnoz[ ++i ] := human_2->pc3
          Elseif is_oncology  == 2
            If !Empty( onksl->crit )
              a_diagnoz[ ++i ] := onksl->crit
            Endif
            If !Empty( onksl->crit2 )
              a_diagnoz[ ++i ] := onksl->crit2  // ��ன ���਩
            Endif
          Endif
          s1 += ' ' + PadC( a_diagnoz[ 1 ], 8 )
          s2 += ' ' + PadC( a_diagnoz[ 2 ], 8 )
          s3 += ' ' + PadC( a_diagnoz[ 3 ], 8 )
          If lExcel
            worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( a_diagnoz[ 1 ] + ' ' + a_diagnoz[ 2 ] + ' ' + a_diagnoz[ 3 ] ), fmtCellString )
          Endif
        Endif
        If yes_parol
          If IsBit( mn->vid_doc, 11 )
            s1 += ' ' + date_8( c4tod( human->date_e ) ) + '�.'
            If Asc( human->kod_p ) > 0
              Select BASE1
              Goto ( Asc( human->kod_p ) )
              If !Eof() .and. !Empty( base1->p1 )
                s2 += ' ' + Left( Crypt( base1->p1, gpasskod ), 10 )
              Endif
            Elseif human_2->PN3 > 0
              s2 += ' ������'
            Endif
            If lExcel
              If Asc( human->kod_p ) > 0
                worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( date_8( c4tod( human->date_e ) ) + '�. ' + Crypt( base1->p1, gpasskod ) ), fmtCellString )
              Elseif human_2->PN3 > 0
                worksheet_write_string( worksheet, row, column++, hb_StrToUTF8( date_8( c4tod( human->date_e ) ) + '�. ' + ' ������' ), fmtCellString )
              Endif
            Endif
          Endif
        Endif
        if ! lExcel
          add_string( s1 )
          add_string( s2 )
          add_string( s3 )
        endif
        If k_diagnoz > 3 .or. k_usl > 3
          For i := 4 To Min( 10, Max( k_diagnoz, k_usl ) )
            s3 := Space( 50 )
            If IsBit( mn->vid_doc, 1 )
              s3 += Space( 9 )
            Endif
            If IsBit( mn->vid_doc, 2 )
              s3 += ' ' + Space( 24 )
            Endif
            If IsBit( mn->vid_doc, 3 )
              s3 += Space( 9 )
            Endif
            If IsBit( mn->vid_doc, 4 )
              s3 += ' ' + PadC( AllTrim( tt_diagnoz[ i ] ), 13 )
            Endif
            If IsBit( mn->vid_doc, 5 )
              s3 += Space( 16 )
            Endif
            If IsBit( mn->vid_doc, 6 )
              s3 += Space( 10 )
            Endif
            If IsBit( mn->vid_doc, 7 )
              s3 += Space( 6 )
            Endif
            If IsBit( mn->vid_doc, 8 )
              s3 += ' ' + PadC( AllTrim( tt_usl[ i ] ), 23 )
            Endif
            if ! lExcel
              add_string( s3 )
            endif
          Next
        Endif
        If is_2
          if ! lExcel
            add_string( Space( 5 ) + '! �� ������� ��砩 !' )
          endif
        Endif
        Select TMP
        Skip
      Enddo
      if ! lExcel
        add_string( Replicate( '�', sh ) )
      endif
      If fl_exit
        if ! lExcel
          add_string( '*** ' + Expand( '�������� ��������' ) )
        endif
      Else
        If mn->kol_lu > 0
          if ! lExcel
            add_string( '�⮣� ������⢮ ������: ' + lstr( skol ) + ' 祫.' )
            add_string( '�⮣� ���⮢ ���: ' + lstr( skol_lu ) + ;
              ' �� �㬬�  ' + lput_kop( ssumma, .t. ) + ' ��.' )
          endif
        Else
          if ! lExcel
            add_string( '  �⮣� ���⮢ ���: ' + lstr( tmp->( LastRec() ) ) + ;
              ' �� �㬬�  ' + lput_kop( ssumma, .t. ) + ' ��.' )
          endif
          If yes_bukva
            For i := 1 To k_plus
              If !Empty( sd_plus[ i ] )
                if ! lExcel
                  add_string( PadL( '"' + md_plus[ i ] + '"  : ', 29 ) + lstr( sd_plus[ i ] ) )
                endif
              Endif
            Next
          Endif
        Endif
      Endif
      Close databases
      If lExcel
        workbook_close( workbook )
        work_with_Excel_file( name_fileXLS_full )
      else
        FClose( fp )
        viewtext( name_file, , , , .t., , , reg_print )
      Endif
    Endif
  Endif
  Close databases
  RestScreen( buf )
  SetColor( tmp_color )

  Return Nil

// 27.05.23
Static Function s1_mnog_poisk( cv, cf )

  Static a_stom_vp := { {}, {}, {} }
  Local i, j, k, n, s, arr, fl := .t., flu := .f., mkol, mstoim := 0, fl1, fl2, vid_vp := 1, ;
    au := {}, au_lu := {}, au_flu := {}, msumma, mn_data, rec_1 := 0, is_2 := .f., ;
    mrak_p := 0, mrak_s := 0, d, lshifr, muet := 0, god_r, arr1, adiag_talon[ 16 ]  // �� ���⠫��� � ���������

  If Empty( a_stom_vp[ 1 ] )
    f_vid_p_stom( {}, {}, a_stom_vp[ 1 ], { 1 } )
    f_vid_p_stom( {}, {}, a_stom_vp[ 2 ], { 2 } )
    f_vid_p_stom( {}, {}, a_stom_vp[ 3 ], { 3 } )
  Endif
  ++cv
  mn_data := human->n_data
  msumma := human->cena_1
  kart->( dbGoto( human->kod_k ) )
  If fl
    If mn->dvojn == 1
      fl := ( human->ishod != 88 )
    Elseif mn->dvojn == 2
      fl := ( human->ishod == 89 )
    Elseif mn->dvojn == 3
      fl := !eq_any( human->ishod, 88, 89 )
    Endif
    If fl
      If human->ishod == 89
        Select HUMAN_3
        Set Order To 2 // ����� �� ������ �� 2-�� ����
        find ( Str( human->kod, 7 ) )
        If Found()
          mn_data := human_3->N_DATA
          msumma := human_3->CENA_1
          rec_1 := human_3->KOD
          is_2 := .t.
        Endif
      Endif
    Endif
  Endif
  If fl .and. mn->date_lech > 0 .and. p_regim != 1
    fl := Between( human->k_data, pdate_lech[ 5 ], pdate_lech[ 6 ] )
  Endif
  If fl .and. mn->date_schet > 0 .and. p_regim != 2
    fl := !Empty( human->DATE_CLOSE ) .and. Between( human->DATE_CLOSE, pdate_lech[ 5 ], pdate_lech[ 6 ] )
    If ( fl := ( human->schet > 0 ) )
      If schet->kod != human->schet
        schet->( dbGoto( human->schet ) )
      Endif
      fl := Between( schet->pdate, pdate_schet[ 7 ], pdate_schet[ 8 ] )
    Endif
  Endif
  If fl .and. mn->perevyst != 1
    If mn->perevyst == 0
      fl := ( human_->oplata != 9 )
    Elseif mn->perevyst == 2
      fl := ( human_->oplata == 9 )
    Endif
  Endif
  If fl .and. mn->rak > 0
    k := 0 // �� 㬮�砭�� ����祭, �᫨ ���� ��� ����
    Select RAKSH
    find ( Str( human->kod, 7 ) )
    Do While human->kod == raksh->kod_h .and. !Eof()
      k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
      Skip
    Enddo
    If !Empty( Round( k, 2 ) )
      mrak_s := k
      If Empty( human->cena_1 ) // ᪮�� ������ � �㫥��� 業��
        If ( y := Year( human->k_data ) ) == 2018
          n := 2224.60
        Elseif y == 2017
          n := 1819.50
        Else  // 16 ���
          n := 1747.70
        Endif
        mrak_p := k := Round( mrak_s / n * 100, 0 )
      Else
        mrak_p := k := Round( mrak_s / human->cena_1 * 100, 0 )
      Endif
    Endif
    Do Case
    Case mn->rak == 1 // {'�� �᪫�祭��� ��������� ������稢�����', 1}, ;
      fl := ( k < 100 )
    Case mn->rak == 2 // {'��������� ������稢���� � ��ॢ��⠢�����', 2}, ;
      fl := ( k == 100 .and. human_->oplata == 9 )
    Case mn->rak == 3 // {'��������� ������稢���� � ����ॢ��⠢�����', 3}, ;
      fl := ( k == 100 .and. human_->oplata != 9 )
    Case mn->rak == 4 // {'��������� ������稢����', 4}, ;
      fl := ( k == 100 )
    Case mn->rak == 5 // {'���筮 ������稢����', 5}, ;
      fl := ( k > 0 .and. k < 100 )
    Case mn->rak == 6 // {'��������� ��� ���筮 ������稢����', 6};
      fl := ( k > 0 )
    Endcase
  Endif
  If fl .and. mn->date_vvod > 0
    fl := Between( human->date_e, pdate_vvod[ 7 ], pdate_vvod[ 8 ] )
  Endif
  If fl .and. yes_vypisan == B_END .and. mn->zav_lech > 0
    If p_zak_sl  // �᫨ �����祭�� ��砩
      fl := ( human->tip_h >= mn->zav_lech )  // �஢���� �� ������ �� ��⮢
    Else
      fl := ( human->tip_h <= mn->zav_lech )
    Endif
  Endif
  If fl
    If mn->reestr == 1
      fl := ( human_->reestr == 0 )
    Elseif mn->reestr == 2
      fl := ( human_->reestr > 0 )
    Endif
  Endif
  If fl
    If mn->schet == 1
      fl := ( human->schet <= 0 )
    Elseif mn->schet == 2
      If ( fl := ( human->schet > 0 ) ) .and. mn->regschet > 0
        If schet->kod != human->schet
          schet->( dbGoto( human->schet ) )
        Endif
        If mn->regschet == 1
          fl := ( schet_->NREGISTR != 0 ) // �� ��ॣ����஢����
        Elseif mn->regschet == 2
          fl := ( schet_->NREGISTR == 0 ) // ��ॣ����஢����
        Endif
      Endif
    Endif
  Endif
  If fl .and. mn->d_p_m > 0
    fl := .f.
    If !fl .and. IsBit( mn->d_p_m, 1 ) // ��ᯠ��ਧ��� ��⥩-��� �� ��樮��� I �⠯', 1}
      fl := ( human->ishod == 101 .and. !Empty( human->za_smo ) )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 2 ) // ��ᯠ��ਧ��� ��⥩-��� �� ��樮��� II �⠯', 2}, ;
      fl := ( human->ishod == 102 .and. !Empty( human->za_smo ) )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 3 ) // ��ᯠ��ਧ��� ��⥩-��� ��� ������ I �⠯', 3}, ;
      fl := ( human->ishod == 101 .and. Empty( human->za_smo ) )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 4 ) // ��ᯠ��ਧ��� ��⥩-��� ��� ������ II �⠯', 4}, ;
      fl := ( human->ishod == 102 .and. Empty( human->za_smo ) )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 5 ) // ��ᯠ��ਧ��� ���᫮�� ��ᥫ���� I �⠯', 5}, ;
      fl := ( human->ishod == 201 )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 6 ) // ��ᯠ��ਧ��� ���᫮�� ��ᥫ���� II �⠯', 6}, ;
      fl := ( human->ishod == 202 )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 7 ) // ��䨫��⨪� ���᫮�� ��ᥫ����', 7}, ;
      fl := ( human->ishod == 203 )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 8 ) // ��ᯠ��ਧ��� ���᫮�� ��ᥫ���� I �⠯ 1 ࠧ � ��� ����
      fl := ( human->ishod == 204 )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 9 ) // ��ᯠ��ਧ��� ���᫮�� ��ᥫ���� II �⠯ 1 ࠧ � ��� ����
      fl := ( human->ishod == 205 )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 10 ) // ���ᬮ�� ��ᮢ��襭����⭨� I �⠯', 8}, ;
      fl := ( human->ishod == 301 )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 11 ) // ���ᬮ�� ��ᮢ��襭����⭨� II �⠯', 9}, ;
      fl := ( human->ishod == 302 )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 12 ) // �।���⥫�� �ᬮ�� ��ᮢ��襭����⭨� I �⠯', 10}, ;
      fl := ( human->ishod == 303 )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 13 ) // �।���⥫�� �ᬮ�� ��ᮢ��襭����⭨� II �⠯', 11}, ;
      fl := ( human->ishod == 304 )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 14 ) // ��ਮ���᪨� �ᬮ�� ��ᮢ��襭����⭨�', 12};
      fl := ( human->ishod == 305 )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 15 ) // 㣫㡫����� ��ᯠ��ਧ��� I -� �⠯};
      fl := ( human->ishod == 401 )
    Endif
    If !fl .and. IsBit( mn->d_p_m, 16 ) // 㣫㡫����� ��ᯠ��ਧ��� II -� �⠯};
      fl := ( human->ishod == 402 )
    Endif
  Endif
  If fl .and. mn->pz > 0
    fl := ( human_->PZTIP == mn->pz )
  Endif
  If fl .and. mn->zno == 2
    fl := ( human->OBRASHEN == '1' )
  Endif
  If fl .and. !Empty( much_doc )
    fl := Like( much_doc, human->uch_doc )
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->bukva )
    kart->( dbGoto( human->kod_k ) )
    fl := ( mn->bukva == kart->bukva )
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->uchast )
    kart->( dbGoto( human->kod_k ) )
    fl := f_is_uchast( arr_uchast, kart->uchast )
  Endif
  If fl .and. glob_mo[ _MO_IS_UCH ] .and. !Empty( mn->o_prik )
    kart->( dbGoto( human->kod_k ) )
    If mn->o_prik == 1 // �ਪ९��� � ��襩 ��
      fl := ( kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ] )
    Elseif mn->o_prik == 2 // �� �ਪ९��� � ��襩 ��
      fl := !( kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ] )
    Endif
  Endif
  If fl .and. !Empty( mfio )
    fl := Like( mfio, Upper( human->fio ) )
  Endif
  If fl .and. mn->inostran > 0
    If mn->inostran == 1 // ���
      // 9, 21, 22, 23, 24
      fl := !equalany( kart_->vid_ud, 9, 21, 22, 23, 24 )
    Else
      fl := equalany( kart_->vid_ud, 9, 21, 22, 23, 24 )
    Endif
  Endif
  If fl .and. mn->gorod_selo > 0
    If mn->gorod_selo == 1
      fl := !f_is_selo( kart_->gorod_selo, kart_->okatog )
    Else
      fl := f_is_selo( kart_->gorod_selo, kart_->okatog )
    Endif
  Endif
  If fl .and. !Empty( madres )
    fl := Like( madres, Upper( kart->adres ) )
  Endif
  If fl .and. !Empty( mmr_dol )
    fl := Like( mmr_dol, Upper( kart->mr_dol ) )
  Endif
  If fl .and. mn->invalid > 0
    If mn->invalid == 9
      fl := ( kart_->INVALID > 0 )
    Else
      fl := ( kart_->INVALID == mn->invalid )
    Endif
  Endif
  If fl .and. mn->kategor > 0
    fl := ( mn->kategor == kart_->kategor )
  Endif
  If fl .and. is_kategor2 .and. mn->kategor2 > 0
    fl := ( mn->kategor2 == kart_->kategor2 )
  Endif
  /*if fl .and. is_talon .and. (mn->povod > 0 .or. mn->travma > 0)
    fl1 := fl2 := .t.
    if mn->povod > 0
      fl1 := .f.
    endif
    if mn->travma > 0
      fl2 := .f.
    endif
    if mn->povod > 0 .and. mn->povod == human_->povod
      fl1:= .t.
    endif
    if mn->travma > 0 .and. mn->travma == human_->travma
      fl2 := .t.
    endif
    fl := (fl1 .and. fl2)
  endif*/
  If fl .and. !Empty( mn->pol )
    fl := ( human->pol == mn->pol )
  Endif
  If fl .and. mn->vzros_reb >= 0
    fl := ( human->vzros_reb == mn->vzros_reb )
  Endif
  If fl .and. !Empty( mn->god_r_min )
    fl := ( mn->god_r_min <= human->date_r )
  Endif
  If fl .and. !Empty( mn->god_r_max )
    fl := ( human->date_r <= mn->god_r_max )
  Endif
  If fl .and. mn->rab_nerab >= 0
    fl := ( kart->rab_nerab == mn->rab_nerab )
  Endif
  If fl .and. mn->mi_git > 0
    If mn->mi_git == 1
      fl := ( Left( kart_->okatog, 2 ) == '18' )
    Else
      fl := !( Left( kart_->okatog, 2 ) == '18' )
    Endif
  Endif
  If fl .and. !Empty( mn->_okato )
    s := mn->_okato
    For i := 1 To 3
      If Right( s, 3 ) == '000'
        s := Left( s, Len( s ) -3 )
      Else
        Exit
      Endif
    Next
    fl := ( Left( kart_->okatog, Len( s ) ) == s )
  Endif
  If fl .and. mn->USL_OK > 0
    fl := ( human_->USL_OK == mn->USL_OK )
  Endif
  /*if fl .and. mn->VIDPOM > 0
    fl := (human_->VIDPOM == mn->VIDPOM)
  endif*/
  If fl .and. mn->PROFIL > 0
    fl := ( human_->PROFIL == mn->PROFIL )
  Endif
  /*if fl .and. mn->IDSP > 0
    fl := (human_->IDSP == mn->IDSP)
  endif*/
  If fl .and. mn->rslt > 0
    fl := ( human_->RSLT_NEW == mn->rslt )
  Endif
  If fl .and. mn->ishod > 0
    fl := ( human_->ISHOD_NEW == mn->ishod )
  Endif
  If fl .and. mn->bolnich1 > 0
    fl := ( human->bolnich + 1 == mn->bolnich1 )
  Endif
  If fl .and. mn->bolnich > 0 .and. mn->bolnich1 != 1  // �� '���'
    fl := .f.
    If human->bolnich > 0 .and. ( c4tod( human->date_b_2 ) - c4tod( human->date_b_1 ) + 1 ) >= mn->bolnich
      fl := .t.
    Endif
  Endif
  If fl .and. mn->vrach1 > 0
    fl := ( human_->vrach == mn->vrach1 )
  Endif
  If fl .and. yes_bukva .and. !Empty( mn->status_st )
    If ( fl := !Empty( human_->status_st ) )
      fl := .f.
      s := AllTrim( mn->status_st )
      For i := 1 To Len( s )
        fl := ( SubStr( s, i, 1 ) $ human_->status_st )
        If fl
          Exit
        Endif
      Next
    Endif
  Endif
  If fl .and. !Empty( mn->osl_d )
    arr := { human_2->OSL1, human_2->OSL2, human_2->OSL3 }
    fl := .f.
    For j := 1 To Len( arr )
      If !Empty( arr[ j ] )
        arr[ j ] := PadR( arr[ j ], 5 )
        If Empty( mn->osl_d1 )
          fl := ( arr[ j ] == mn->osl_d )
        Else
          fl := Between( diag2num( arr[ j ] ), NUMosl_d, NUMosl_d1 )
        Endif
        If fl
          Exit
        Endif  // �.�. ���� ������� 㤮���⢮��� �᫮���
      Endif
    Next
  Endif
  If fl .and. !Empty( mn->pred_d )
    If Between( human->ishod, 201, 203 )  // ���-�� (���ᬮ��) ���᫮�� ��ᥫ����
      Private pole_diag, pole_1pervich
      For i := 1 To 5
        pole_diag := 'mdiag' + lstr( i )
        pole_1pervich := 'm1pervich' + lstr( i )
        Private &pole_diag := Space( 6 )
        Private &pole_1pervich := 0
      Next
      read_arr_dvn( human->kod )
      arr := {}
      For i := 1 To 5
        pole_diag := 'mdiag' + lstr( i )
        pole_1pervich := 'm1pervich' + lstr( i )
        If !Empty( &pole_diag ) .and. &pole_1pervich == 2  // �।���⥫�� �������
          AAdd( arr, &pole_diag )
        Endif
      Next
    Else
      arr := { human_->KOD_DIAG0 }
    Endif
    fl := .f.
    For j := 1 To Len( arr )
      If !Empty( arr[ j ] )
        arr[ j ] := PadR( arr[ j ], 5 )
        If Empty( mn->pred_d1 )
          fl := ( arr[ j ] == mn->pred_d )
        Else
          fl := Between( diag2num( arr[ j ] ), NUMpred_d, NUMpred_d1 )
        Endif
        If fl
          Exit
        Endif  // �.�. ���� ������� 㤮���⢮��� �᫮���
      Endif
    Next
  Endif
  If fl .and. !emptyall( mn->diag, mn->kod_diag, mn->soput_d )
    arr := { { human->KOD_DIAG, 1, 0, 0 }, ;
      { human->KOD_DIAG2, 2, 0, 0 }, ;
      { human->KOD_DIAG3, 3, 0, 0 }, ;
      { human->KOD_DIAG4, 4, 0, 0 }, ;
      { human->SOPUT_B1, 5, 0, 0 }, ;
      { human->SOPUT_B2, 6, 0, 0 }, ;
      { human->SOPUT_B3, 7, 0, 0 }, ;
      { human->SOPUT_B4, 8, 0, 0 } }
    If is_talon .and. mn->talon_diag > 0
      AFill( adiag_talon, 0 )
      For i := 1 To 16
        adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
      Next
      For j := 1 To Len( arr )
        For i := 1 To 2
          If adiag_talon[ j * 2 - ( 2 - i ) ] > 0
            arr[ j, 2 + i ] := 1
          Endif
        Next
      Next
    Endif
    If fl .and. !emptyall( mn->diag, mn->diag1 ) // �஢�ਬ �� �����������
      fl := .f.
      For j := 1 To Len( arr )
        If Empty( mn->diag1 )
          fl := ( arr[ j, 1 ] == mn->diag )
        Else
          fl := Between( diag2num( arr[ j, 1 ] ), NUMdiag, NUMdiag1 )
        Endif
        If fl
          If is_talon .and. mn->talon_diag > 0
            fl := .f.
            If arr[ j, 3 ] > 0 .or. arr[ j, 4 ] > 0 .or. arr_tal_diag[ 1, 3 ] == 2 .or. arr_tal_diag[ 2, 3 ] == 2
              For i := 1 To 2
                If arr[ j, 2 + i ] > 0 .or. arr_tal_diag[ i, 3 ] == 2
                  k := adiag_talon[ j * 2 - ( 2 - i ) ]
                  If arr_tal_diag[ i, 3 ] == 2
                    If Empty( k )
                      fl := .t.
                    Endif
                  Elseif arr_tal_diag[ i, 1 ] > 0 .and. Between( k, arr_tal_diag[ i, 1 ], arr_tal_diag[ i, 2 ] )
                    fl := .t.
                  Endif
                  If fl
                    Exit
                  Endif
                Endif
              Next
            Endif
          Endif
          If fl
            Exit
          Endif  // �.�. ���� ������� 㤮���⢮��� �᫮���
        Endif
      Next
    Endif
    If fl .and. !emptyall( mn->kod_diag, mn->kod_diag1 ) // �஢�ਬ �᭮���� �����������
      fl := .f.
      j := 1 // ��ࢮ� = �᭮���� �����������
      If Empty( mn->kod_diag1 )
        fl := ( arr[ j, 1 ] == mn->kod_diag )
      Else
        fl := Between( diag2num( arr[ j, 1 ] ), NUMkod_diag, NUMkod_diag1 )
      Endif
      If fl
        If is_talon .and. mn->talon_diag > 0
          fl := .f.
          If arr[ j, 3 ] > 0 .or. arr[ j, 4 ] > 0 .or. arr_tal_diag[ 1, 3 ] == 2 .or. arr_tal_diag[ 2, 3 ] == 2
            For i := 1 To 2
              If arr[ j, 2 + i ] > 0 .or. arr_tal_diag[ i, 3 ] == 2
                k := adiag_talon[ j * 2 - ( 2 - i ) ]
                If arr_tal_diag[ i, 3 ] == 2
                  If Empty( k )
                    fl := .t.
                  Endif
                Elseif arr_tal_diag[ i, 1 ] > 0 .and. Between( k, arr_tal_diag[ i, 1 ], arr_tal_diag[ i, 2 ] )
                  fl := .t.
                Endif
                If fl
                  Exit
                Endif
              Endif
            Next
          Endif
        Endif
      Endif
    Endif
    If fl .and. !emptyall( mn->soput_d, mn->soput_d1 ) // �஢�ਬ ᮯ������騥 �����������
      fl := .f.
      For j := 2 To Len( arr )  // ��稭�� � ��ண�
        If Empty( mn->soput_d1 )
          fl := ( arr[ j, 1 ] == mn->soput_d )
        Else
          fl := Between( diag2num( arr[ j, 1 ] ), NUMsoput_d, NUMsoput_d1 )
        Endif
        If fl
          If is_talon .and. mn->talon_diag > 0
            fl := .f.
            If arr[ j, 3 ] > 0 .or. arr[ j, 4 ] > 0 .or. arr_tal_diag[ 1, 3 ] == 2 .or. arr_tal_diag[ 2, 3 ] == 2
              For i := 1 To 2
                If arr[ j, 2 + i ] > 0 .or. arr_tal_diag[ i, 3 ] == 2
                  k := adiag_talon[ j * 2 - ( 2 - i ) ]
                  If arr_tal_diag[ i, 3 ] == 2
                    If Empty( k )
                      fl := .t.
                    Endif
                  Elseif arr_tal_diag[ i, 1 ] > 0 .and. Between( k, arr_tal_diag[ i, 1 ], arr_tal_diag[ i, 2 ] )
                    fl := .t.
                  Endif
                  If fl
                    Exit
                  Endif
                Endif
              Next
            Endif
          Endif
          If fl
            Exit
          Endif  // �.�. ���� ������� 㤮���⢮��� �᫮���
        Endif
      Next
    Endif
  Endif
  If fl .and. yes_h_otd == 1 .and. mn->otd > 0
    fl := ( human->otd == mn->otd )
  Endif
  If fl .and. mn->ist_fin >= 0
    fl := _f_ist_fin()
  Endif
  If fl .and. mn->komu >= 0
    If mn->company == 0
      If mn->komu == 0
        fl := !Empty( human_->smo )
      Else
        fl := ( mn->komu == human->komu )
      Endif
    Elseif mn->komu == 0
      If human->schet > 0
        If schet->kod != human->schet
          schet->( dbGoto( human->schet ) )
        Endif
        fl := ( Int( Val( schet_->smo ) ) == mn->company )
      Else
        fl := ( Int( Val( cut_code_smo( human_->smo ) ) ) == mn->company )
      Endif
    Else
      fl := ( mn->komu == human->komu .and. mn->company == human->str_crb )
    Endif
  Endif
  k := human->k_data - mn_data + 1
  If fl .and. mn->srok_min > 0
    fl := ( mn->srok_min <= k )
  Endif
  If fl .and. mn->srok_max > 0
    fl := ( k <= mn->srok_max )
  Endif
  If fl .and. mn->summa_min > 0
    fl := ( mn->summa_min <= msumma )
  Endif
  If fl .and. mn->summa_max > 0
    fl := ( msumma <= mn->summa_max )
  Endif
  fl1 := fl2 := .t.
  If fl
    If flag_hu .or. flag_huF
      ar := { human->kod }
      If is_2
        ins_array( ar, 1, rec_1 )
      Endif
    Endif
    If flag_hu
      For i := 1 To Len( ar )
        Select HU
        find ( Str( ar[ i ], 7 ) )
        Do While hu->kod == ar[ i ] .and. !Eof()
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If f_paraklinika( usl->shifr, lshifr1, human->k_data )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            AAdd( au_lu, { lshifr, ;              // 1
              c4tod( hu->date_u ), ;               // 2
            hu_->profil, ;         // 3
            hu_->PRVS, ;           // 4
            AllTrim( usl->shifr ), ; // 5
            hu->kol_1, ;           // 6
            c4tod( hu_->date_u2 ), ;     // 7
            hu_->kod_diag, ;       // 8
            hu->( RecNo() ), ;       // 9 - ����� �����
            hu->is_edit } )         // 10
            If flag_hu
              AAdd( au, { 1, hu->( RecNo() ), Len( au_lu ) } )
            Endif
          Endif
          Select HU
          Skip
        Enddo
      Next i
    Endif
    If flag_huF
      For i := 1 To Len( ar )
        Select MOHU
        find ( Str( ar[ i ], 7 ) )
        Do While mohu->kod == ar[ i ] .and. !Eof()
          Select MOSU
          Goto ( mohu->u_kod )
          AAdd( au_flu, { mosu->shifr1, ;         // 1
          c4tod( mohu->date_u ), ;  // 2
          mohu->profil, ;         // 3
          mohu->PRVS, ;           // 4
            mosu->shifr, ;          // 5
          mohu->kol_1, ;          // 6
            c4tod( mohu->date_u2 ), ; // 7
          mohu->kod_diag, ;       // 8
          mohu->( RecNo() ) } )      // 9 - ����� �����
          AAdd( au, { 2, mohu->( RecNo() ), Len( au_flu ) } )
          Select MOHU
          Skip
        Enddo
      Next i
      If mn->kol_pos == 2
        k := 0
        f_vid_p_stom( au_lu, {}, , , human->k_data, @vid_vp, @k, , au_flu )
        If vid_vp == 1 // � ��祡��� 楫��
          pol_pos_stom1 += k  // �� ������ �����������
        Elseif vid_vp == 2 // // � ��䨫����᪮� 楫��
          pol_pos_stom2 += k  // ��䨫��⨪�
        Elseif vid_vp == 3 // // �� �������� ���⫮���� �����
          pol_pos_stom3 += k  // � ���⫮���� �ଥ
        Endif
      Endif
    Endif
    If flag_hu .or. flag_huF
      If mn->kol_pos == 2 .and. eq_any( human_->USL_OK, 1, 4 ) // ��樮��� � ���
        Select TMP_KP
        For d := human->n_data To human->k_data
          s := dtoc4( d )
          find ( Str( human->kod_k, 7 ) + s )
          If !Found()
            Append Blank
            tmp_kp->kod_k := human->kod_k
            tmp_kp->data  := s
          Endif
        Next
      Endif
      mkol := 0
      For iau := 1 To Len( au )
        lal := { 'hu', 'mohu' }[ au[ iau, 1 ] ]
        lal_ := { 'hu_', 'mohu' }[ au[ iau, 1 ] ]
        dbSelectArea( lal )
        dbGoto( au[ iau, 2 ] )
        flu := .t.
        If flu .and. mn->date_usl > 0
          flu := Between( &lal.->date_u, pdate_usl[ 7 ], pdate_usl[ 8 ] )
        Endif
        If flu .and. mn->dom > 0
          If au[ iau, 1 ] == 1 // ⮫쪮 ��� HU
            Do Case
            Case mn->dom == 1 // � �����������
              flu := ( hu->KOL_RCP >= 0 )
            Case mn->dom == 2 // �� ����
              flu := ( hu->KOL_RCP == -1 )
            Case mn->dom == 3 // �� ����-�����
              flu := ( hu->KOL_RCP == -2 )
            Case mn->dom == 4 // �� ���� + �� ����-�����
              flu := ( hu->KOL_RCP < 0 )
            Endcase
          Elseif mn->dom > 1 // 䥤.��㣨 ⮫쪮 � �����������
            flu := .f.
          Endif
        Endif
        If flu .and. mn->otd_usl > 0
          flu := ( &lal.->otd == mn->otd_usl )
        Endif
        If flu .and. mn->PROFIL_U > 0
          flu := ( &lal_.->PROFIL == mn->PROFIL_U )
        Endif
        If flu .and. mn->vras1 > 0
          flu := ( &lal.->kod_vr == mn->vras1 .or. &lal.->kod_as == mn->vras1 )
        Endif
        If flu .and. mn->vr1 > 0
          flu := ( &lal.->kod_vr == mn->vr1 )
        Endif
        If flu .and. mn->isvr > 0
          If mn->isvr == 1  // ���
            flu := ( &lal.->kod_vr == 0 )
          Else
            flu := ( &lal.->kod_vr > 0 )
          Endif
        Endif
        If flu .and. mn->as1 > 0
          flu := ( &lal.->kod_as == mn->as1 )
        Endif
        If flu .and. mn->isas > 0
          If mn->isas == 1  // ���
            flu := ( &lal.->kod_as == 0 )
          Else
            flu := ( &lal.->kod_as > 0 )
          Endif
        Endif
        If flu .and. mn->slug_usl > 0 .and. au[ iau, 1 ] == 1 // ⮫쪮 ��� HU
          flu := ( usl->slugba == mn->slug_usl )
        Endif
        If flu
          If au[ iau, 1 ] == 1 .and. mn->uslugi > 0
            i := AScan( arr_usl, {| x| x[ 1 ] == hu->u_kod } )
            If ( flu := ( i > 0 ) )
              fl1 := .f.
              arr_usl[ i, 4 ] += hu->kol_1
              arr_usl[ i, 5 ] += hu->stoim_1
              arr_usl[ i, 6 ] += mrak_s
            Endif
          Elseif au[ iau, 1 ] == 2 .and. mn->uslugiF > 0
            i := AScan( arr_uslF, {| x| x[ 1 ] == mohu->u_kod } )
            If ( flu := ( i > 0 ) )
              fl2 := .f.
              arr_uslF[ i, 4 ] += mohu->kol_1
            Endif
          Endif
        Endif
        If flu
          mkol += &lal.->kol_1
          mstoim += &lal.->stoim_1
          If mem_trudoem == 2 // ������뢠�� ��㤮񬪮���
            If au[ iau, 1 ] == 1
              muet += round_5( hu->kol_1 * opr_uet( human->vzros_reb ), 4 )
            Elseif human_->usl_ok == 3 // ⮫쪮 ��� �⮬�⮫����
              If Year( human->k_data ) > 2018
                Select LUSLF
                find ( mosu->shifr1 )
                muet += round_5( mohu->kol_1 * iif( human->vzros_reb == 0, luslf->uetv, luslf->uetd ), 4 )
              Elseif LUSLF18->( Used() )
                Select LUSLF18
                find ( mosu->shifr1 )
                muet += round_5( mohu->kol_1 * iif( human->vzros_reb == 0, luslf18->uetv, luslf18->uetd ), 4 )
              Endif
            Endif
          Endif
          If mn->kol_pos == 2 .and. eq_any( human_->USL_OK, 2, 3 ) .and. au[ iau, 1 ] == 1
            i := au[ iau, 3 ]
            lshifr := au_lu[ i, 1 ]
            If human_->USL_OK == 2 // ������� ��樮���
              If Left( lshifr, 5 ) == '55.1.' // ���-�� ��樥��-����
                For i := 1 To hu->kol_1
                  If i == 1
                    s := hu->date_u
                  Else
                    s := dtoc4( c4tod( hu->date_u ) + i -1 )
                  Endif
                  Select TMP_KP
                  find ( Str( human->kod_k, 7 ) + s )
                  If !Found()
                    Append Blank
                    tmp_kp->kod_k := human->kod_k
                    tmp_kp->data  := s
                  Endif
                Next
              Endif
            Elseif !f_is_zak_sl_vr( lshifr )  // �����������
              If Left( lshifr, 2 ) == '2.' // ��祡�� ���� ���㫠���
                If between_shifr( lshifr, '2.79.52', '2.79.64' )
                  vid_vp := 2 // � ��䨫����᪮� 楫��
                Elseif between_shifr( lshifr, '2.88.40', '2.88.51' )
                  vid_vp := 2 // � ��䨫����᪮� 楫��
                Elseif between_shifr( lshifr, '2.80.29', '2.80.38' )
                  vid_vp := 3 // �� �������� ���⫮���� �����
                Else
                  kol_pos_amb += hu->kol_1
                Endif
              Else // �஢��塞 ����� �⮬�⮫����
                For i := 1 To 3
                  If AScan( a_stom_vp[ i ], lshifr ) > 0
                    Do Case
                    Case i == 1 // � ��祡��� 楫��
                      pol_pos_stom1 += hu->kol_1  // �� ������ �����������
                    Case i == 2 // // � ��䨫����᪮� 楫��
                      pol_pos_stom2 += hu->kol_1  // ��䨫��⨪�
                    Case i == 3 // // �� �������� ���⫮���� �����
                      pol_pos_stom3 += hu->kol_1  // � ���⫮���� �ଥ
                    Endcase
                    Exit
                  Endif
                Next
              Endif
            Endif
          Endif
          If flu .and. mn->kol_pos == 2
            Select TMP_KP
            find ( Str( human->kod_k, 7 ) + &lal.->date_u )
            If !Found()
              Append Blank
              tmp_kp->kod_k := human->kod_k
              tmp_kp->data  := &lal.->date_u
            Endif
          Endif
        Endif
      Next
      If emptyall( mkol, mstoim )
        fl := .f.
      Elseif mn->uslugi > 0 .and. fl1 // �� ������ �� ����� ��㣨 �� ᯨ᪠ �⡮�
        fl := .f.
      Elseif mn->uslugiF > 0 .and. fl2 // �� ������ �� ����� ��㣨 �� ᯨ᪠ �⡮�
        fl := .f.
      Endif
    Else
      mstoim := msumma
    Endif
  Endif
  If fl
    Select TMP_K
    find ( Str( human->kod_k, 7 ) )
    If !Found()
      Append Blank
      tmp_k->kod_k := human->kod_k
    Endif
    tmp_k->kol++
    Select TMP
    Append Blank
    tmp->kod := human->kod
    tmp->kod_k := human->kod_k
    tmp->stoim := mstoim
    tmp->rak_p := mrak_p
    tmp->rak_s := mrak_s
    ssumma += mstoim
    srak_s += mrak_s
    If muet > 0
      suet += muet
    Endif
    f2_diag_statist_bukva()
    If ++cf % 5000 == 0
      tmp->( dbCommit() )
      tmp_k->( dbCommit() )
    Endif
  Endif
  @ MaxRow(), 1 Say lstr( cv ) Color cColorSt2Msg
  @ Row(), Col() Say '/' Color 'W/R'
  @ Row(), Col() Say lstr( cf ) Color cColorStMsg

  Return Nil

// 12.10.23
Function titlen_uchexcel( worksheet, row, column, arr_u, lsh, c_uch )

  Local s := ''

  If !( Type( 'count_uch' ) == 'N' )
    count_uch := iif( c_uch == NIL, 1, c_uch )
  Endif
  If count_uch > 1
    If count_uch == Len( arr_u )
      worksheet_write_string( worksheet, row, column, hb_StrToUTF8( Center( '[ �� �ᥬ ��०����� ]' ) ), nil )
    Else
      AEval( arr_u, {| x| s += '"' + AllTrim( x[ 2 ] ) + '", ' } )
      s := SubStr( s, 1, Len( s ) -2 )
      worksheet_write_string( worksheet, row, column, hb_StrToUTF8( Center( s ) ), nil )
    Endif
  Endif

  Return Nil

//
Function f_put_tal_diag()

  Static mm_s := { '��ࠪ�� �����������', ;
    '��ᯠ���� ���' }
  Local i, s

  For i := 1 To 2
    If arr_tal_diag[ i, 3 ] == 2
      add_string( mm_s[ i ] + ': �� �����' )
    Elseif arr_tal_diag[ i, 1 ] > 0
      s := mm_s[ i ] + ': ' + lstr( arr_tal_diag[ i, 1 ] )
      If arr_tal_diag[ i, 1 ] != arr_tal_diag[ i, 2 ]
        s += ' - ' + lstr( arr_tal_diag[ i, 2 ] )
      Endif
      add_string( s )
    Endif
  Next

  Return Nil

// 12.10.23
Function f_put_tal_diagexcel( worksheet, row, column )

  Static mm_s := { '��ࠪ�� �����������', ;
    '��ᯠ���� ���' }
  Local i, s

  For i := 1 To 2
    If arr_tal_diag[ i, 3 ] == 2
      worksheet_write_string( worksheet, row, column, hb_StrToUTF8( mm_s[ i ] + ': �� �����' ), nil )
    Elseif arr_tal_diag[ i, 1 ] > 0
      s := mm_s[ i ] + ': ' + lstr( arr_tal_diag[ i, 1 ] )
      If arr_tal_diag[ i, 1 ] != arr_tal_diag[ i, 2 ]
        s += ' - ' + lstr( arr_tal_diag[ i, 2 ] )
      Endif
      worksheet_write_string( worksheet, row, column, hb_StrToUTF8( s ), nil )
    Endif
  Next

  Return Nil

// 12.10.23
Function f3_diag_statist_bukvaexcel( HH, sh, arr_title, lvu )

  Local j

  Default lvu To 0
  If Select( 'TMP_BUK' ) == 0
    Use ( cur_dir + 'tmp_bbuk' ) index ( cur_dir + 'tmp_bbuk' ) new
    Use ( cur_dir + 'tmp_buk' ) index ( cur_dir + 'tmp_buk' ) new
  Endif
  Select TMP_BUK
  find ( Str( lvu, 4 ) )
  Do While tmp_buk->vu == lvu .and. !Eof()
    j := 0
    Select TMP_BBUK
    find ( Str( lvu, 4 ) + tmp_buk->bukva )
    dbEval( {|| ++j }, , {|| tmp_bbuk->vu == lvu .and. tmp_bbuk->bukva == tmp_buk->bukva } )
    If verify_ff( HH, .t., sh ) .and. ValType( arr_title ) == 'A'
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( PadL( tmp_buk->bukva, w1 + 6 ) + Str( j, 7 ) + Str( tmp_buk->kol, 7 ) )
    Select TMP_BUK
    Skip
  Enddo

  Return Nil

Function st_pz_poisk( get )

  Local t_year
  Local nameArr

  If !Empty( pdate_lech )
    t_year := pdate_lech[ 1 ]
    mm_pz := {}
    nameArr := get_array_pz( t_year )
    For i := 1 To Len( nameArr )
      AAdd( mm_pz, { nameArr[ i, 3 ], nameArr[ i, 1 ] } )
    Next
  Endif

  Return .t.
