#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'
#include 'hbxlsxwriter.ch'

// 06.03.24
function fmt_excel_hC_vC( wb )

  local fmt

  fmt := workbook_add_format( wb )
  format_set_align( fmt, LXW_ALIGN_CENTER )
  format_set_align( fmt, LXW_ALIGN_VERTICAL_CENTER )
  return fmt

// 06.03.24
function fmt_excel_hL_vC( wb )

  local fmt

  fmt := workbook_add_format( wb )
  format_set_align( fmt, LXW_ALIGN_LEFT )
  format_set_align( fmt, LXW_ALIGN_VERTICAL_CENTER )
  return fmt

// 06.03.24
function fmt_excel_hR_vC( wb )

  local fmt

  fmt := workbook_add_format( wb )
  format_set_align( fmt, LXW_ALIGN_RIGHT )
  format_set_align( fmt, LXW_ALIGN_VERTICAL_CENTER )
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
