#include "function.ch"
#include "chip_mo.ch"
#include 'hbxlsxwriter.ch'

Function hodotajstvoxls( name )

  Local workbook, worksheet, format_top1, format_top2, format_top3
  Local format_header, format_header2
  Local format_text, format_text2, format_text3
  Local error
  Local name_file := name + '.xlsx'
  Local iRow := 6

  /* Создадим новую книгу. */
  workbook   = workbook_new( name_file )

  /* Добавим лист в книгу. */
  worksheet = workbook_add_worksheet( workbook, 'Лист1' )

  /* Добавим формат для строк и ячеек. */
  format_top1    = workbook_add_format( workbook )
  format_top2    = workbook_add_format( workbook )
  format_set_bold( format_top2 )
  format_set_font_size( format_top2, 11 )
  format_top3    = workbook_add_format( workbook )
  format_set_bold( format_top3 )
  format_set_font_size( format_top3, 11 )
  format_set_num_format( format_top3, 'dd/mm/yyyy' )

  /* Конфигурируем формат для шапки. */
  format_header    = workbook_add_format( workbook )
  format_set_align( format_header, LXW_ALIGN_CENTER )
  format_set_align( format_header, LXW_ALIGN_VERTICAL_CENTER )
  format_set_font_size( format_header, 7 )
  format_set_border( format_header, LXW_BORDER_THIN )

  format_header2    = workbook_add_format( workbook )
  format_set_align( format_header2, LXW_ALIGN_CENTER )
  format_set_align( format_header2, LXW_ALIGN_VERTICAL_CENTER )
  format_set_font_size( format_header2, 6 )
  format_set_border( format_header2, LXW_BORDER_THIN )

  /* Конфигурируем формат для ntrcnf. */
  format_text    = workbook_add_format( workbook )
  format_set_align( format_text, LXW_ALIGN_LEFT )
  format_set_align( format_text, LXW_ALIGN_VERTICAL_CENTER )
  format_set_font_size( format_text, 7 )
  format_set_text_wrap( format_text )
  format_set_border( format_text, LXW_BORDER_THIN )

  format_text2    = workbook_add_format( workbook )
  format_set_align( format_text2, LXW_ALIGN_LEFT )
  format_set_align( format_text2, LXW_ALIGN_VERTICAL_CENTER )
  format_set_font_size( format_text2, 6 )
  format_set_text_wrap( format_text2 )
  format_set_border( format_text2, LXW_BORDER_THIN )

  format_text3    = workbook_add_format( workbook )
  format_set_align( format_text3, LXW_ALIGN_CENTER )
  format_set_align( format_text3, LXW_ALIGN_VERTICAL_CENTER )
  format_set_font_size( format_text3, 7 )
  format_set_text_wrap( format_text3 )
  format_set_border( format_text3, LXW_BORDER_THIN )

  /* Объединить ячейки строк. */
  worksheet_merge_range( worksheet, 0, 0, 0, 2, 'Наименование файла:', format_top1 )
  worksheet_merge_range( worksheet, 1, 0, 1, 2, 'Код МО:', format_top1 )
  worksheet_merge_range( worksheet, 2, 0, 2, 2, 'Наименование МО:', format_top1 )
  worksheet_merge_range( worksheet, 3, 0, 3, 2, 'Дата создания файла:', format_top1 )

  worksheet_merge_range( worksheet, 0, 3, 0, 19, name_file, format_top2 )
  worksheet_merge_range( worksheet, 1, 3, 1, 19, glob_mo[ _MO_KOD_TFOMS ], format_top2 )
  worksheet_merge_range( worksheet, 2, 3, 2, 19, hb_StrToUTF8( glob_mo[ _MO_SHORT_NAME ] ), format_top2 )
  worksheet_merge_range( worksheet, 3, 3, 3, 19, full_date( sys_date ), format_top3 )

  worksheet_merge_range( worksheet, 4, 0, 5, 0, '№ п/п', format_header2 )
  worksheet_merge_range( worksheet, 4, 1, 5, 1, 'Фамилия', format_header )
  worksheet_merge_range( worksheet, 4, 2, 5, 2, 'Имя', format_header )
  worksheet_merge_range( worksheet, 4, 3, 5, 3, 'Отчество', format_header )
  worksheet_merge_range( worksheet, 4, 4, 5, 4, 'пол', format_header2 )
  worksheet_merge_range( worksheet, 4, 5, 5, 5, 'Дата рождения', format_header )

  worksheet_merge_range( worksheet, 4, 6, 4, 9, 'Документ, удостоверяющий личность', format_header2 )
  worksheet_write_string( worksheet, 5, 6, 'код', format_header )
  worksheet_write_string( worksheet, 5, 7, 'наименование', format_header )
  worksheet_write_string( worksheet, 5, 8, 'серия', format_header )
  worksheet_write_string( worksheet, 5, 9, 'номер', format_header )

  worksheet_merge_range( worksheet, 4, 10, 5, 10, 'СНИЛС', format_header )

  worksheet_merge_range( worksheet, 4, 11, 4, 12, 'Адрес регистрации', format_header2 )
  worksheet_write_string( worksheet, 5, 11, 'ОКАТО', format_header )
  worksheet_write_string( worksheet, 5, 12, 'адрес', format_header )

  worksheet_merge_range( worksheet, 4, 13, 4, 14, 'Полис ОМС', format_header2 )

  worksheet_write_string( worksheet, 5, 13, 'вид', format_header )
  worksheet_write_string( worksheet, 5, 14, 'серия и №', format_header )

  worksheet_merge_range( worksheet, 4, 15, 4, 16, 'СМО', format_header2 )
  worksheet_write_string( worksheet, 5, 15, 'код', format_header )
  worksheet_write_string( worksheet, 5, 16, 'наименование', format_header )

  worksheet_merge_range( worksheet, 4, 17, 4, 18, 'Регион страхования', format_header2 )
  worksheet_write_string( worksheet, 5, 17, 'ОКАГО', format_header )
  worksheet_write_string( worksheet, 5, 18, 'наименование', format_header )

  worksheet_merge_range( worksheet, 4, 19, 5, 19, 'Прочая контактная информация', format_header )

  /* Установить ширину колонок */
  worksheet_set_column( worksheet, 0, 0, 3.0 )
  worksheet_set_column( worksheet, 1, 2, 8.0 )
  worksheet_set_column( worksheet, 3, 3, 9.86 )
  worksheet_set_column( worksheet, 4, 4, 3.0 )
  worksheet_set_column( worksheet, 5, 5, 5.43 )
  worksheet_set_column( worksheet, 6, 6, 3.0 )
  worksheet_set_column( worksheet, 7, 7, 7.14 )
  worksheet_set_column( worksheet, 10, 10, 8.0 )
  worksheet_set_column( worksheet, 11, 11, 6.14 )
  worksheet_set_column( worksheet, 12, 12, 11.86 )
  worksheet_set_column( worksheet, 13, 13, 4.71 )
  worksheet_set_column( worksheet, 14, 14, 9.86 )
  worksheet_set_column( worksheet, 15, 15, 4.71 )
  worksheet_set_column( worksheet, 16, 16, 10.86 )
  worksheet_set_column( worksheet, 17, 17, 5.71 )
  worksheet_set_column( worksheet, 18, 18, 12.0 )
  worksheet_set_column( worksheet, 19, 19, 8.0 )

  /* Установить высоту строк. */
  worksheet_set_row( worksheet, 4, 10.5 )
  worksheet_set_row( worksheet, 5, 20.0 )

  Use ( fr_data ) New Alias FRD
  FRD->( dbGoTop() )
  Do While ! FRD->( Eof() )
    worksheet_set_row( worksheet, iRow, 30.0 )
    worksheet_write_number( worksheet, iRow, 0, FRD->NOMER, format_text3 )
    worksheet_write_string( worksheet, iRow, 1, hb_StrToUTF8( AllTrim( FRD->FAM ) ), format_text )
    worksheet_write_string( worksheet, iRow, 2, hb_StrToUTF8( AllTrim( FRD->IM ) ), format_text )
    worksheet_write_string( worksheet, iRow, 3, hb_StrToUTF8( AllTrim( FRD->OT ) ), format_text )
    worksheet_write_string( worksheet, iRow, 4, hb_StrToUTF8( AllTrim( FRD->POL ) ), format_text )
    worksheet_write_string( worksheet, iRow, 5, hb_StrToUTF8( AllTrim( FRD->DATE_R ) ), format_text2 )
    worksheet_write_number( worksheet, iRow, 6, FRD->VID_UD, format_text3 )
    worksheet_write_string( worksheet, iRow, 7, hb_StrToUTF8( AllTrim( FRD->NAME_UD ) ), format_text )
    worksheet_write_string( worksheet, iRow, 8, hb_StrToUTF8( AllTrim( FRD->SER_UD ) ), format_text )
    worksheet_write_string( worksheet, iRow, 9, hb_StrToUTF8( AllTrim( FRD->NOM_UD ) ), format_text )
    worksheet_write_string( worksheet, iRow, 10, hb_StrToUTF8( AllTrim( FRD->SNILS ) ), format_text2 )
    worksheet_write_string( worksheet, iRow, 11, hb_StrToUTF8( AllTrim( FRD->OKATOG ) ), format_text2 )
    worksheet_write_string( worksheet, iRow, 12, hb_StrToUTF8( AllTrim( FRD->ADRESG ) ), format_text2 )
    worksheet_write_string( worksheet, iRow, 13, hb_StrToUTF8( AllTrim( FRD->VIDPOLIS ) ), format_text2 )
    worksheet_write_string( worksheet, iRow, 14, hb_StrToUTF8( AllTrim( FRD->POLIS ) ), format_text2 )
    worksheet_write_string( worksheet, iRow, 15, hb_StrToUTF8( AllTrim( FRD->SMO ) ), format_text2 )
    worksheet_write_string( worksheet, iRow, 16, hb_StrToUTF8( AllTrim( FRD->NAME_SMO ) ), format_text2 )
    worksheet_write_string( worksheet, iRow, 17, hb_StrToUTF8( AllTrim( FRD->OKATO ) ), format_text2 )
    worksheet_write_string( worksheet, iRow, 18, hb_StrToUTF8( AllTrim( FRD->REGION ) ), format_text2 )
    worksheet_write_string( worksheet, iRow, 19, hb_StrToUTF8( AllTrim( FRD->PROCH ) ), format_text2 )
    ++iRow
    FRD->( dbSkip() )
  End
  frd->( dbCloseArea() )
  /* Закрыть книгу, записать файл и освободить память. */
  error = workbook_close( workbook )
  Return error
