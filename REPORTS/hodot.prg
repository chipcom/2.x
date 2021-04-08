 #include "function.ch"
 #include "chip_mo.ch"
 
#include "hblibxlsxwriter.ch"

function hodotajstvoXLS(name) 
  local workbook, worksheet, format_top1, format_top2
  local format_header, format_header2
  local format_text, format_text2, format_text3
  local error
  local name_file := name + '.xlsx'
  local iRow := 6

  lxw_init() 
    
  /* Создадим новую книгу. */
  workbook   = lxw_workbook_new(name_file)

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
  lxw_format_set_text_wrap(format_text2)
  lxw_format_set_border(format_text2, LXW_BORDER_THIN)

  format_text3    = lxw_workbook_add_format(workbook)
  lxw_format_set_align(format_text3, LXW_ALIGN_CENTER)
  lxw_format_set_align(format_text3, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(format_text3, 7)
  lxw_format_set_border(format_text3, LXW_BORDER_THIN)

  /* Объединить ячейки строк. */
  lxw_worksheet_merge_range(worksheet, 0, 0, 0, 2, 'Наименование файла:', format_top1)
  lxw_worksheet_merge_range(worksheet, 1, 0, 1, 2, 'Код МО:', format_top1)
  lxw_worksheet_merge_range(worksheet, 2, 0, 2, 2, 'Наименование МО:', format_top1)
  lxw_worksheet_merge_range(worksheet, 3, 0, 3, 2, 'Дата создания файла:', format_top1)

  lxw_worksheet_merge_range(worksheet, 0, 3, 0, 19, name_file, format_top2)
  lxw_worksheet_merge_range(worksheet, 1, 3, 1, 19, glob_mo[_MO_KOD_TFOMS], format_top2)
  lxw_worksheet_merge_range(worksheet, 2, 3, 2, 19, hb_StrToUtf8( glob_mo[_MO_SHORT_NAME] ), format_top2)
  lxw_worksheet_merge_range(worksheet, 3, 3, 3, 19, HB_STOT(DToS(sys_date)), format_top2)

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

  /* Установить ширину колонок */
  lxw_worksheet_set_column(worksheet, 0, 0, 3.0)
  lxw_worksheet_set_column(worksheet, 1, 3, 8.0)
  lxw_worksheet_set_column(worksheet, 4, 4, 3.0)
  lxw_worksheet_set_column(worksheet, 6, 6, 3.0)

  /* Установить высоту строк. */
  lxw_worksheet_set_row(worksheet, 4, 10.5)
  lxw_worksheet_set_row(worksheet, 5, 20.0)

  use (fr_data) new alias FRD
  FRD->(dbGoTop())
  do while ! FRD->(eof())

    lxw_worksheet_set_row(worksheet, iRow, 30.0)
    lxw_worksheet_write_number(worksheet, iRow, 0, FRD->NOMER, format_text3)
    lxw_worksheet_write_string(worksheet, iRow, 1, hb_StrToUtf8( alltrim(FRD->FAM) ), format_text)
    lxw_worksheet_write_string(worksheet, iRow, 2, hb_StrToUtf8( alltrim(FRD->IM) ), format_text)
    lxw_worksheet_write_string(worksheet, iRow, 3, hb_StrToUtf8( alltrim(FRD->OT) ), format_text)
    lxw_worksheet_write_string(worksheet, iRow, 4, hb_StrToUtf8( alltrim(FRD->POL) ), format_text)
    lxw_worksheet_write_string(worksheet, iRow, 5, hb_StrToUtf8( alltrim(FRD->DATE_R) ), format_text2)
    lxw_worksheet_write_number(worksheet, iRow, 6, FRD->VID_UD, format_text3)
    lxw_worksheet_write_string(worksheet, iRow, 7, hb_StrToUtf8( alltrim(FRD->NAME_UD) ), format_text)
    lxw_worksheet_write_string(worksheet, iRow, 8, hb_StrToUtf8( alltrim(FRD->SER_UD) ), format_text)
    lxw_worksheet_write_string(worksheet, iRow, 9, hb_StrToUtf8( alltrim(FRD->NOM_UD) ), format_text)
    lxw_worksheet_write_string(worksheet, iRow, 10, hb_StrToUtf8( alltrim(FRD->SNILS) ), format_text2)
    lxw_worksheet_write_string(worksheet, iRow, 11, hb_StrToUtf8( alltrim(FRD->OKATOG) ), format_text2)
    lxw_worksheet_write_string(worksheet, iRow, 12, hb_StrToUtf8( alltrim(FRD->ADRESG) ), format_text2)
    lxw_worksheet_write_string(worksheet, iRow, 13, hb_StrToUtf8( alltrim(FRD->VIDPOLIS) ), format_text2)
    lxw_worksheet_write_string(worksheet, iRow, 14, hb_StrToUtf8( alltrim(FRD->POLIS) ), format_text2)
    lxw_worksheet_write_string(worksheet, iRow, 15, hb_StrToUtf8( alltrim(FRD->SMO) ), format_text2)
    lxw_worksheet_write_string(worksheet, iRow, 16, hb_StrToUtf8( alltrim(FRD->NAME_SMO) ), format_text2)
    lxw_worksheet_write_string(worksheet, iRow, 17, hb_StrToUtf8( alltrim(FRD->OKATO) ), format_text2)
    lxw_worksheet_write_string(worksheet, iRow, 18, hb_StrToUtf8( alltrim(FRD->REGION) ), format_text2)
    lxw_worksheet_write_string(worksheet, iRow, 19, hb_StrToUtf8( alltrim(FRD->PROCH) ), format_text2)

    ++iRow
    FRD->(dbSkip())
  end
  frd->(dbCloseArea())

    /* Закрыть книгу, записать файл и освободить память. */
    error = lxw_workbook_close(workbook)

    /* Проверить наличие ошибки при создании xlsx файла. */
    if !EMPTY(error)
        alertx(hb_Utf8ToStr(sprintf('Ошибка в workbook_close().\n' + ;
               'Ошибка %d = %s\n', error, HB_NTOS(error)),'RU866'),'error')
    endif

    return error
