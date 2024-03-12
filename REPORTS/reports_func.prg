#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'
#include 'hbxlsxwriter.ch'

// 09.03.24
function work_with_Excel_file( filename )

  local choice, lOpen := .f.

  filename := saveto( filename )
  if ! isnil( filename ) .and. check_install_Excel()
    if open_Excel_automatic()
      lOpen := .t.
    else
      if ( choice := hb_Alert( '������ 䠩�?', { '���', '��' } ) ) == 2
        lOpen := .t.
      endif
    endif
    if lOpen
      view_file_in_Viewer( filename )
    endif
  endif
  return nil

// 07.03.24
function check_install_Excel()

  local obj

  obj := win_oleCreateObject( 'Excel.Application' )
  return iif( isnil( obj ), .f., .t. )

// 07.03.24
function open_Excel_automatic()

  local opn
  
  opn := val( getinivar( tmp_ini, { { 'RAB_MESTO', 'open_Excel', '0' } } )[ 1 ] )
  return iif( opn == 1, .t., .f. )

// 06.03.24
// 業��஢���� �� ��ਧ��⠫� � ���⨪���
function fmt_excel_hC_vC( wb )

  local fmt

  fmt := workbook_add_format( wb )
  format_set_align( fmt, LXW_ALIGN_CENTER )
  format_set_align( fmt, LXW_ALIGN_VERTICAL_CENTER )
  return fmt

// 07.03.24
// 業��஢���� �� ��ਧ��⠫� � ���⨪��� � ��७�ᮬ
function fmt_excel_hC_vC_wrap( wb )

  local fmt

  fmt := fmt_excel_hC_vC( wb )
  format_set_text_wrap( fmt )
  return fmt

// 06.03.24
// ����� ��ࠢ������� �� ��ਧ��⠫� � 業��஢���� � ���⨪���
function fmt_excel_hL_vC( wb )

  local fmt

  fmt := workbook_add_format( wb )
  format_set_align( fmt, LXW_ALIGN_LEFT )
  format_set_align( fmt, LXW_ALIGN_VERTICAL_CENTER )
  return fmt

// 07.03.24
// ����� ��ࠢ������� �� ��ਧ��⠫� � 業��஢���� � ���⨪��� � ��७�ᮬ
function fmt_excel_hL_vC_wrap( wb )

  local fmt

  fmt := fmt_excel_hL_vC( wb )
  format_set_text_wrap( fmt )
  return fmt

// 06.03.24
// �ࠢ�� ��ࠢ������� �� ��ਧ��⠫� � 業��஢���� � ���⨪���
function fmt_excel_hR_vC( wb )

  local fmt

  fmt := workbook_add_format( wb )
  format_set_align( fmt, LXW_ALIGN_RIGHT )
  format_set_align( fmt, LXW_ALIGN_VERTICAL_CENTER )
  return fmt

// 07.03.24
// �ࠢ�� ��ࠢ������� �� ��ਧ��⠫� � 業��஢���� � ���⨪��� � ��७�ᮬ
function fmt_excel_hR_vC_wrap( wb )

  local fmt

  fmt := fmt_excel_hR_vC( wb )
  format_set_text_wrap( fmt )
  return fmt

// 06.03.24
// �롮� ���ࠢ����� �뢮�� ����
function type_output( row, col, sel_item )
  // row - ��ப�
  // col - �������
  // sel_item - ��ࢮ��砫�� �롮�
  // iOutput - ��࠭��� �襭�� ( 0 - �⪠� �� �롮� )

  local iOutput := 0
  local mm_output := { ;
    '�� �࠭', ;
    '� 䠩� Excel (�ଠ� xlsx)' ;
    }
  iOutput := popup_prompt( row, col, sel_item, mm_output )
  return iOutput

// 02.02.24
Function title_schet_akt( schet_akt )

  local retStr := ''

  If schet_akt == 2
    retStr := '[ �� ���⮬ ����� �� ��⠬ ]'
  Elseif schet_akt == 3
    retStr := '[ ��� ���� ����୮ ���⠢������ ��砥� ]'
  Endif
  Return retStr

// 01.03.24
Function titleN_uch( arr_u, lsh, c_uch )

  Local i, t_arr[ 2 ], s := ''

  if ! ( type( 'count_uch' ) == 'N' )
    count_uch := iif( c_uch == NIL, 1, c_uch )
  endif
  if count_uch > 1
    if count_uch == len( arr_u )
      add_string( center( '[ �� �ᥬ ��०����� ]', lsh ) )
    else
      aeval(arr_u, { | x | s += '"' + alltrim( x[ 2 ] ) + '", ' } )
      s := substr( s, 1, len( s ) - 2 )
      for i := 1 to perenos( t_arr, s, lsh )
        add_string( center( alltrim( t_arr[ i ] ), lsh ) )
      next
    endif
  endif
  return NIL

// 01.03.24
Function arr_titleN_uch( arr_u, c_uch )

  Local i, t_arr[ 2 ], s := ''
  local ret := {}

  if ! ( type( 'count_uch' ) == 'N' )
    count_uch := iif( c_uch == NIL, 1, c_uch )
  endif
  if count_uch > 1
    if count_uch == len( arr_u )
      AAdd( ret, '[ �� �ᥬ ��०����� ]' )
    else
      aeval(arr_u, { | x | s += '"' + alltrim( x[ 2 ] ) + '", ' } )
      s := substr( s, 1, len( s ) - 2 )
      AAdd( ret, s )
    endif
  endif
  return ret

// 01.03.24
Function titleN_otd( arr_o, lsh, c_otd )

  Local i, t_arr[ 2 ], s := ''

  if ! ( type( 'count_otd' ) == 'N' )
    count_otd := iif( c_otd == NIL, 1, c_otd )
  endif
  if count_otd > 1 .and. valtype( arr_o ) == 'A'
    if count_otd == len( arr_o )
      add_string( center( '[ �� �ᥬ �⤥����� ]', lsh ) )
    else
      aeval( arr_o, { | x | s += '"' + alltrim( x[ 2 ] ) + '", ' } )
      s := substr( s, 1, len( s ) - 2 )
      for i := 1 to perenos( t_arr, s, lsh )
        add_string( center( alltrim( t_arr[ i ] ), lsh ) )
      next
    endif
  endif
  return NIL

// 01.03.24
Function arr_titleN_otd( arr_o, c_otd )

  Local i, t_arr[ 2 ], s := ''
  local ret := {}

  if ! ( type( 'count_otd' ) == 'N' )
    count_otd := iif( c_otd == NIL, 1, c_otd )
  endif
  if count_otd > 1 .and. valtype( arr_o ) == 'A'
    if count_otd == len( arr_o )
      AAdd( ret, '[ �� �ᥬ �⤥����� ]' )
    else
      aeval( arr_o, { | x | s += '"' + alltrim( x[ 2 ] ) + '", ' } )
      s := substr( s, 1, len( s ) - 2 )
      AAdd( ret, s )
    endif
  endif
  return ret

function test_excel()
  local wb
  Local name_fileXLS := 'test'
  Local name_fileXLS_full := cur_dir + name_fileXLS + '.xlsx'
  
  wb  := workbook_new( name_fileXLS_full )
  zakladka_excel_report( wb, '������ ����' )
  workbook_close( wb )
  
  return nil
  
// 12.03.24
function zakladka_excel_report( wb, descr )
  
  local ws
  
  ws := workbook_add_worksheet( wb, hb_StrToUTF8( descr ) )
  worksheet_set_column( ws, 0, 300, 0.5, nil )
  worksheet_set_row( ws, 0, 18,  NIL)
  worksheet_set_row( ws, 1, 9,  NIL)
  worksheet_set_row( ws, 2, 14.3,  NIL)
  worksheet_set_row( ws, 3, 12,  NIL)
  worksheet_set_row( ws, 4, 54.8,  NIL)
  worksheet_set_row( ws, 5, 12,  NIL)
  worksheet_set_row( ws, 6, 29.3,  NIL)
  worksheet_set_row( ws, 7, 12.8,  NIL)
  worksheet_set_row( ws, 8, 14.3,  NIL)
  worksheet_set_row( ws, 9, 12.8,  NIL)
  worksheet_set_row( ws, 10, 17.3,  NIL)
  worksheet_set_row( ws, 11, 12,  NIL)
  worksheet_set_row( ws, 12, 13.5,  NIL)
  worksheet_set_row( ws, 13, 21,  NIL)
  worksheet_set_row( ws, 14, 2.3,  NIL)
  worksheet_set_row( ws, 15, 14.3,  NIL)
  worksheet_set_row( ws, 16, 12.8,  NIL)  // 17 ��ப�
  
  return ws
  