/*
 * Anatomy of a simple libxlsxwriter program.
 *
 * Copyright 2014-2017, John McNamara, jmcnamara@cpan.org
 *
 */

#include "hblibxlsxwriter.ch"

function main() 
  local workbook, worksheet, format_top1, format_top2
  local format_header, format_header2
  local format_text, format_text2
  local error

  lxw_init() 
    
  /* Создадим новую книгу. */
  workbook   = lxw_workbook_new('HD_1_M.xlsx')

  /* Добавим лист в книгу. */
  worksheet = lxw_workbook_add_worksheet(workbook, 'Лист1')

  /* Добавим формат для строк и ячеек. */
  format_top1    = lxw_workbook_add_format(workbook)

  format_top2    = lxw_workbook_add_format(workbook)
  lxw_format_set_bold(format_top2)
  lxw_format_set_font_size(format_top2, 11)

  /* Конфигурируем формат для шапки. */
  format_header    = lxw_workbook_add_format(workbook)
  lxw_format_set_align(format_header, LXW_ALIGN_CENTER)
  lxw_format_set_align(format_header, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(format_header, 7)
  lxw_format_set_border(format_header, LXW_BORDER_THIN)

  format_header2    = lxw_workbook_add_format(workbook)
  lxw_format_set_align(format_header2, LXW_ALIGN_CENTER)
  lxw_format_set_align(format_header2, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(format_header2, 6)
  lxw_format_set_border(format_header2, LXW_BORDER_THIN)

  /* Конфигурируем формат для ntrcnf. */
  format_text    = lxw_workbook_add_format(workbook)
  lxw_format_set_align(format_text, LXW_ALIGN_LEFT)
  lxw_format_set_align(format_text, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(format_text, 7)
  lxw_format_set_border(format_text, LXW_BORDER_THIN)

  format_text2    = lxw_workbook_add_format(workbook)
  lxw_format_set_align(format_text2, LXW_ALIGN_LEFT)
  lxw_format_set_align(format_text2, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(format_text2, 6)
  lxw_format_set_border(format_text2, LXW_BORDER_THIN)

  /* Установить ширину колонок */
  lxw_worksheet_set_column(worksheet, 0, 0, 3.0)
  lxw_worksheet_set_column(worksheet, 1, 2, 8.0)

  /* Объединить ячейки строк. */
  lxw_worksheet_merge_range(worksheet, 0, 0, 0, 2, 'Наименование файла:', format_top1)
  lxw_worksheet_merge_range(worksheet, 1, 0, 1, 2, 'Код МО:', format_top1)
  lxw_worksheet_merge_range(worksheet, 2, 0, 2, 2, 'Наименование МО:', format_top1)
  lxw_worksheet_merge_range(worksheet, 3, 0, 3, 2, 'Дата создания файла:', format_top1)

  lxw_worksheet_merge_range(worksheet, 0, 3, 0, 19, 'Тест 1', format_top2)
  lxw_worksheet_merge_range(worksheet, 1, 3, 1, 19, 'Тест 2', format_top2)
  lxw_worksheet_merge_range(worksheet, 2, 3, 2, 19, 'Тест 3', format_top2)
  lxw_worksheet_merge_range(worksheet, 3, 3, 3, 19, 'Тест 4', format_top2)

  lxw_worksheet_merge_range(worksheet, 4, 0, 5, 0, '№ п/п', format_header2)
  lxw_worksheet_merge_range(worksheet, 4, 1, 5, 1, 'Фамилия', format_header)
  lxw_worksheet_merge_range(worksheet, 4, 2, 5, 2, 'Имя', format_header)
  lxw_worksheet_merge_range(worksheet, 4, 3, 5, 3, 'Отчество', format_header)
  lxw_worksheet_merge_range(worksheet, 4, 4, 5, 4, 'пол', format_header2)
  lxw_worksheet_merge_range(worksheet, 4, 5, 5, 5, 'Дата рождения', format_header)

  lxw_worksheet_merge_range(worksheet, 4, 6, 4, 9, 'Документ, удостоверяющий личность', format_header2)
  lxw_worksheet_write_string(worksheet, 5, 6, 'код', format_header)
  lxw_worksheet_write_string(worksheet, 5, 7, 'наименование', format_header)
  lxw_worksheet_write_string(worksheet, 5, 8, 'серия', format_header)
  lxw_worksheet_write_string(worksheet, 5, 9, 'номер', format_header)

  lxw_worksheet_merge_range(worksheet, 4, 10, 5, 10, 'СНИЛС', format_header)

  lxw_worksheet_merge_range(worksheet, 4, 11, 4, 12, 'Адрес регистрации', format_header2)
  lxw_worksheet_write_string(worksheet, 5, 11, 'ОКАТО', format_header)
  lxw_worksheet_write_string(worksheet, 5, 12, 'адрес', format_header)

  lxw_worksheet_merge_range(worksheet, 4, 13, 4, 14, 'Полис ОМС', format_header2)

  lxw_worksheet_write_string(worksheet, 5, 13, 'вид', format_header)
  lxw_worksheet_write_string(worksheet, 5, 14, 'серия и №', format_header)

  lxw_worksheet_merge_range(worksheet, 4, 15, 4, 16, 'СМО', format_header2)
  lxw_worksheet_write_string(worksheet, 5, 15, 'код', format_header)
  lxw_worksheet_write_string(worksheet, 5, 16, 'наименование', format_header)

  lxw_worksheet_merge_range(worksheet, 4, 17, 4, 18, 'Регион страхования', format_header2)
  lxw_worksheet_write_string(worksheet, 5, 17, 'ОКАГО', format_header)
  lxw_worksheet_write_string(worksheet, 5, 18, 'наименование', format_header)

  lxw_worksheet_merge_range(worksheet, 4, 19, 5, 19, 'Прочая контактная информация', format_header)

  /* Установить высоту строк. */
  lxw_worksheet_set_row(worksheet, 4, 10.5)
  lxw_worksheet_set_row(worksheet, 5, 20.0)
  lxw_worksheet_set_row(worksheet, 6, 30.0)

    // /* Set the bold property for the first format. */
    // lxw_format_set_bold(myformat1)

    // /* Set a number format for the second format. */
    // lxw_format_set_num_format(myformat2, "$#,##0.00")

    // /* Widen the first column to make the text clearer. */
    // lxw_worksheet_set_column(worksheet1, 0, 0, 20, NIL)

    // /* Write some unformatted data. */
    // lxw_worksheet_write_string(worksheet1, 0, 0, "Peach", NIL)
    // lxw_worksheet_write_string(worksheet1, 1, 0, "Plum",  NIL)

    // /* Write formatted data. */
    // lxw_worksheet_write_string(worksheet1, 2, 0, "Pear",  myformat1)

    // /* Formats can be reused. */
    // lxw_worksheet_write_string(worksheet1, 3, 0, "Persimmon",  myformat1)


    // /* Write some numbers. */
    // lxw_worksheet_write_number(worksheet1, 5, 0, 123,       NIL)
    // lxw_worksheet_write_number(worksheet1, 6, 0, 4567.555,  myformat2)

    /* Закрыть книгу, записать файл и освободить память. */
    error = lxw_workbook_close(workbook)

    /* Проверить наличие ошибки при создании xlsx файла. */
    if !EMPTY(error)
        sprintf('Ошибка в workbook_close().\n' + ;
               'Ошибка %d = %s\n', error, HB_NTOS(error))
    endif

    return error
