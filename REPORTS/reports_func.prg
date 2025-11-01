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
      if ( choice := hb_Alert( 'Открыть файл?', { 'Нет', 'Да' } ) ) == 2
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
  
  opn := val( getinivar( tmp_ini(), { { 'RAB_MESTO', 'open_Excel', '0' } } )[ 1 ] )
  return iif( opn == 1, .t., .f. )

// 06.03.24
// центрирование по горизонтали и вертикали
function fmt_excel_hC_vC( wb )

  local fmt

  fmt := workbook_add_format( wb )
  format_set_align( fmt, LXW_ALIGN_CENTER )
  format_set_align( fmt, LXW_ALIGN_VERTICAL_CENTER )
  return fmt

// 07.03.24
// центрирование по горизонтали и вертикали с переносом
function fmt_excel_hC_vC_wrap( wb )

  local fmt

  fmt := fmt_excel_hC_vC( wb )
  format_set_text_wrap( fmt )
  return fmt

// 06.03.24
// левое выравнивание по горизонтали и центрирование и вертикали
function fmt_excel_hL_vC( wb )

  local fmt

  fmt := workbook_add_format( wb )
  format_set_align( fmt, LXW_ALIGN_LEFT )
  format_set_align( fmt, LXW_ALIGN_VERTICAL_CENTER )
  return fmt

// 07.03.24
// левое выравнивание по горизонтали и центрирование и вертикали и переносом
function fmt_excel_hL_vC_wrap( wb )

  local fmt

  fmt := fmt_excel_hL_vC( wb )
  format_set_text_wrap( fmt )
  return fmt

// 06.03.24
// правое выравнивание по горизонтали и центрирование и вертикали
function fmt_excel_hR_vC( wb )

  local fmt

  fmt := workbook_add_format( wb )
  format_set_align( fmt, LXW_ALIGN_RIGHT )
  format_set_align( fmt, LXW_ALIGN_VERTICAL_CENTER )
  return fmt

// 07.03.24
// правое выравнивание по горизонтали и центрирование и вертикали и переносом
function fmt_excel_hR_vC_wrap( wb )

  local fmt

  fmt := fmt_excel_hR_vC( wb )
  format_set_text_wrap( fmt )
  return fmt

// 06.03.24
// выбор направления вывода отчета
function type_output( row, col, sel_item )
  // row - строка
  // col - колонка
  // sel_item - первоначальный выбор
  // iOutput - выбранное решение ( 0 - отказ от выбора )

  local iOutput := 0
  local mm_output := { ;
    'на экран', ;
    'в файл Excel (формат xlsx)' ;
    }
  iOutput := popup_prompt( row, col, sel_item, mm_output )
  return iOutput

// 02.02.24
Function title_schet_akt( schet_akt )

  local retStr := ''

  If schet_akt == 2
    retStr := '[ за вычетом снятых по актам ]'
  Elseif schet_akt == 3
    retStr := '[ без учёта повторно выставленных случаев ]'
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
      add_string( center( '[ по всем учреждениям ]', lsh ) )
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
      AAdd( ret, '[ по всем учреждениям ]' )
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
      add_string( center( '[ по всем отделениям ]', lsh ) )
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
      AAdd( ret, '[ по всем отделениям ]' )
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
  Local name_fileXLS_full := cur_dir() + name_fileXLS + '.xlsx'
  
  wb  := workbook_new( name_fileXLS_full )
  zakladka_excel_report( wb, 'Титульный лист' )
  workbook_close( wb )
  
  return nil
  
// 14.03.24
function zakladka_excel_report( wb, descr )
  
  local ws, fmt_
  local sOutput

  ws := workbook_add_worksheet( wb, hb_StrToUTF8( descr ) )
  worksheet_set_column( ws, 0, 300, 0.5, nil )
  worksheet_set_row( ws, 0, 18,  NIL )
  fmt_ := fmt_excel_hC_vC( wb )
  format_set_border( fmt_, LXW_BORDER_THICK )
  format_set_bold( fmt_ )
  worksheet_merge_range( ws, 0, 22, 0, 138, hb_StrToUTF8( 'ФЕДЕРАЛЬНОЕ СТАТИСТИЧЕСКОЕ НАБЛЮДЕНИЕ' ), fmt_ )
  worksheet_set_row( ws, 1, 9,  NIL )
  worksheet_set_row( ws, 2, 14.3,  NIL )

  fmt_ := fmt_excel_hC_vC( wb )
  format_set_border( fmt_, LXW_BORDER_THICK )
  worksheet_merge_range( ws, 2, 22, 2, 138, hb_StrToUTF8( 'КОНФИДЕНЦИАЛЬНОСТЬ ГАРАНТИРУЕТСЯ ПОЛУЧАТЕЛЕМ ИНФОРМАЦИИ' ), fmt_ )
  worksheet_set_row( ws, 3, 12,  NIL )

  fmt_ := fmt_excel_hC_vC_wrap( wb )
  format_set_border( fmt_, LXW_BORDER_THICK )
  format_set_fg_color( fmt_, 0xD7E4BC )
  worksheet_set_row( ws, 4, 54.8, fmt_excel_hC_vC_wrap( wb ) )
  sOutput := 'Нарушение порядка представления статистической информации, а равно представление недостоверной статистической информации влечет ответственность, установленную статьей 13.19 Кодекса ' + ;
    'Российской Федерации об административных правонарушениях от 30.12.2001 № 195-ФЗ, а также статьей 3 Закона Российской Федерации от 13.05.92 № 2761-1 "Об ответственности за нарушение ' + ;
    'порядка представления государственной статистической отчетности"'
  worksheet_merge_range( ws, 4, 13, 4, 147, ;
    hb_StrToUTF8( sOutput ), fmt_ )

  worksheet_set_row( ws, 5, 12,  NIL )
  worksheet_set_row( ws, 6, 29.3, fmt_excel_hC_vC_wrap( wb ) )
  sOutput := 'В соответствии со статьей 6 Федерального закона от 27.07.2006 № 152-ФЗ "О персональных данных" обработка персональных данных осуществляется для статистических целей при условии ' + ;
    'обязательного обезличивания персональных данных'
  worksheet_merge_range( ws, 6, 14, 6, 146, ;
    hb_StrToUTF8( sOutput ), fmt_ )
  worksheet_set_row( ws, 7, 12.8,  NIL )

  fmt_ := fmt_excel_hC_vC( wb )
  format_set_border( fmt_, LXW_BORDER_THICK )
  worksheet_set_row( ws, 8, 14.3,  NIL )
  worksheet_merge_range( ws, 8, 22, 8, 138, ;
    hb_StrToUTF8( 'ВОЗМОЖНО ПРЕДОСТАВЛЕНИЕ В ЭЛЕКТРОННОМ ВИДЕ' ), fmt_ )
  worksheet_set_row( ws, 9, 12.8,  NIL )

  fmt_ := fmt_excel_hC_vC( wb )
  worksheet_set_row( ws, 10, 17.3,  NIL )
  worksheet_merge_range( ws, 10, 29, 10, 131, ;
    hb_StrToUTF8( 'СВЕДЕНИЯ О РАБОТЕ МЕДИЦИНСКИХ ОРГАНИЗАЦИЙ В СФЕРЕ ОМС' ), fmt_ )
  worksheet_set_row( ws, 11, 12,  NIL )
  worksheet_merge_range( ws, 11, 29, 11, 131, ;
    hb_StrToUTF8( 'за январь - _____________________ 20__ г.' ), fmt_ )
  worksheet_set_row( ws, 12, 13.5,  NIL )
  worksheet_merge_range( ws, 12, 29, 12, 131, ;
    hb_StrToUTF8( '(нарастающим итогом)' ), fmt_ )

//  fmt_ := fmt_excel_hC_vC_wrap( wb )
//  format_set_border( fmt_, LXW_BORDER_THICK )
//  format_set_fg_color( fmt_, 0xD7E4BC )
//  worksheet_merge_range( ws, 10, 29, 12, 131, ;
//    nil, fmt_ )

  worksheet_set_row( ws, 13, 21,  NIL )
  worksheet_set_row( ws, 14, 2.3,  NIL )
  worksheet_set_row( ws, 15, 14.3,  NIL )
  worksheet_set_row( ws, 16, 12.8,  NIL )  // 17 строка
  worksheet_set_row( ws, 17, 12.8,  NIL )
  worksheet_set_row( ws, 18, 10.5,  NIL )
  worksheet_set_row( ws, 19, 10.5,  NIL )
  worksheet_set_row( ws, 20, 10.5,  NIL )
  worksheet_set_row( ws, 21, 9,  NIL )
  worksheet_set_row( ws, 22, 4.5,  NIL )
  worksheet_set_row( ws, 23, 10.5,  NIL )
  worksheet_set_row( ws, 24, 10.5,  NIL )
  worksheet_set_row( ws, 25, 3.8,  NIL )
  worksheet_set_row( ws, 26, 6.8,  NIL )
  worksheet_set_row( ws, 27, 5.3,  NIL )
  worksheet_set_row( ws, 28, 6.8,  NIL )
  worksheet_set_row( ws, 29, 10.5,  NIL )
  worksheet_set_row( ws, 30, 3,  NIL ) // 31 строка
  worksheet_set_row( ws, 31, 7.5,  NIL )
  worksheet_set_row( ws, 32, 10.5,  NIL )
  worksheet_set_row( ws, 33, 21.8,  NIL )
  worksheet_set_row( ws, 34, 14.3,  NIL )
  worksheet_set_row( ws, 35, 4.5,  NIL )
  worksheet_set_row( ws, 36, 14.3,  NIL )
  worksheet_set_row( ws, 37, 4.5,  NIL )
  worksheet_set_row( ws, 38, 18,  NIL )
  worksheet_set_row( ws, 39, 27,  NIL )
  worksheet_set_row( ws, 40, 13.8,  NIL )
  worksheet_set_row( ws, 41, 13.8,  NIL )
  
  return ws
  