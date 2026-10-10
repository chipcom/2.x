#include 'common.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'hbxlsxwriter.ch'

// 14.11.24
function fns_jornal_excel( file_name, arr_m )

  local workbook, worksheet
  local strMO := hb_StrToUtf8( glob_mo()[ _MO_SHORT_NAME ] )

  workbook  := WORKBOOK_NEW( file_name )
  worksheet := WORKBOOK_ADD_WORKSHEET(workbook, 'Табл_1' )

  WORKBOOK_CLOSE( workbook )

  return nil