#include 'chip_mo.ch'
#include 'hbxlsxwriter.ch'

function writexlsx_inf_pn( fName, dCreate )

  Local workbook, header, header_wrap
  Local worksheet1, worksheet2, worksheet3, worksheet4, worksheet5, worksheet6, worksheet7
  Local merge_format, formatDate, cell_format_num, cell_format_string
  local hGauge, row, curr, arr_fio
  local error
  Local strMO := hb_StrToUTF8( glob_mo[ _MO_SHORT_NAME ] )

  workbook  := workbook_new( fName )
  worksheet1 := workbook_add_worksheet( workbook, 'профосмотры' )
  worksheet_set_tab_color( worksheet1, 0xd9ead3 )
  worksheet2 := workbook_add_worksheet( workbook, '15-17 лет' )
  worksheet_set_tab_color( worksheet2, 0xe9ead3 )
  worksheet3 := workbook_add_worksheet( workbook, 'Нац.проект "Здравоохранение"' )
  worksheet_set_tab_color( worksheet3, 0xa9ead3 )
  worksheet4 := workbook_add_worksheet( workbook, '2510-2511-Дети сироты' )
  worksheet_set_tab_color( worksheet4, 0xb9ead3 )
  worksheet5 := workbook_add_worksheet( workbook, '2510-дети-СВОД' )
  worksheet_set_tab_color( worksheet5, 0xc9ead3 )
  worksheet6 := workbook_add_worksheet( workbook, 'таб. 2511 ф. 30' )
  worksheet_set_tab_color( worksheet6, 0x99ead3 )
  worksheet7 := workbook_add_worksheet( workbook, 'Заболевание 15-17' )
  worksheet_set_tab_color( worksheet7, 0x89ead3 )

  /* Закрыть книгу, записать файл и освободить память. */
  error = workbook_close( workbook )
  /* Проверить наличие ошибки при создании xlsx файла. */
  If !Empty( error )
    alertx( hb_UTF8ToStr( sprintf( 'Ошибка в workbook_close().\n' + ;
    'Ошибка %d = %s\n', error, hb_ntos( error ) ), 'RU866' ), 'error' )
  Endif

  return nil
