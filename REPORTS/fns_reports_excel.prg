#include 'common.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'hbxlsxwriter.ch'

// 14.11.24
function fns_jornal_excel( file_name, arr_m )

  local workbook, worksheet
  local merge_format, form_text_header, form_text_header_1, form_text_X, cell_format_plan
  local cell_format, cell_format_itog, cell_format_man, cell_format_woman, cell_format_full
  local merge_format_head, form_text_date_text, form_text_footer, form_text_footer_1
  local form_text_date, form_plan_gorod, form_plan_selo
  local strMO := hb_StrToUtf8( glob_mo[ _MO_SHORT_NAME ] )

  workbook  := WORKBOOK_NEW( file_name )
  worksheet := WORKBOOK_ADD_WORKSHEET(workbook, 'Табл_1' )

  WORKBOOK_CLOSE( workbook )

  return nil