#include "chip_mo.ch"
#include "hblibxlsxwriter.ch"

function WriteXLSXGreater60(fName, dCreate)
  local workbook, header
  local worksheet
  local worksheetRemoved
  local nfile := 'Great60.xlsx'
  // local sCode := 'МКБ-10', sName := 'Наименование диагноза'
  local merge_format, merge_cell_name_format
  local cell_code_format
  local strMO := hb_StrToUtf8( glob_mo[_MO_SHORT_NAME] )

  lxw_init() 

  if hb_FileExists(nfile)  
    filedelete(nfile)
  endif

  // workbook  := lxw_workbook_new(nfile)
  workbook  := lxw_workbook_new(fName)
  worksheet := lxw_workbook_add_worksheet(workbook, 'Sheet1' )

  /* Create a format for the date or time.*/
  formatDate := lxw_workbook_add_format(workbook)
  lxw_format_set_num_format(formatDate, 'dd/mm/yyyy')
  lxw_format_set_align(formatDate, LXW_ALIGN_LEFT)
  lxw_format_set_border(formatDate, LXW_BORDER_THIN)

  /* Set up some formatting and text to highlight the panes. */
  header = lxw_workbook_add_format(workbook)
  lxw_format_set_align(header, LXW_ALIGN_CENTER)
  lxw_format_set_align(header, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_fg_color(header, 0xD7E4BC)
  lxw_format_set_bold(header)
  lxw_format_set_border(header, LXW_BORDER_THIN)

  header_wrap = lxw_workbook_add_format(workbook)
  lxw_format_set_align(header_wrap, LXW_ALIGN_CENTER)
  lxw_format_set_align(header_wrap, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_fg_color(header_wrap, 0xD7E4BC)
  lxw_format_set_bold(header_wrap)
  lxw_format_set_border(header_wrap, LXW_BORDER_THIN)
  lxw_format_set_text_wrap(header_wrap)

  merge_format := lxw_workbook_add_format(workbook)
  /* Конфигурируем формат для объединенных ячеек. */
  lxw_format_set_align(merge_format, LXW_ALIGN_CENTER)
  lxw_format_set_align(merge_format, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_bold(merge_format)
  lxw_format_set_font_size(merge_format, 14)
  lxw_format_set_bg_color(merge_format, LXW_COLOR_YELLOW)
  lxw_format_set_border(merge_format, LXW_BORDER_THIN)


  cell_format_num := lxw_workbook_add_format(workbook)
  /* Конфигурируем формат для вывода чисел. */
  lxw_format_set_align(cell_format_num, LXW_ALIGN_CENTER)
  lxw_format_set_align(cell_format_num, LXW_ALIGN_VERTICAL_CENTER)
  // lxw_format_set_bg_color(merge_cell_code_format, LXW_COLOR_YELLOW)
  lxw_format_set_border(cell_format_num, LXW_BORDER_THIN)

  cell_format_string := lxw_workbook_add_format(workbook)
  /* Конфигурируем формат для вывода чисел. */
  lxw_format_set_align(cell_format_string, LXW_ALIGN_LEFT)
  lxw_format_set_align(cell_format_string, LXW_ALIGN_VERTICAL_CENTER)
  // lxw_format_set_bg_color(merge_cell_code_format, LXW_COLOR_YELLOW)
  lxw_format_set_border(cell_format_string, LXW_BORDER_THIN)

  /* Объединить 5 колонок одной строки. */
  lxw_worksheet_merge_range(worksheet, 0, 0, 0, 5, 'Список граждан старше 60 лет, прикрепленных к медицинской организации, по терапевтическим участкам', merge_format)

  /* Нарисуем шапку */
  lxw_worksheet_write_string(worksheet, 2, 0, 'п/н', header)
  lxw_worksheet_write_string(worksheet, 2, 1, 'ФИО', header)
  lxw_worksheet_write_string(worksheet, 2, 2, 'Дата рождения', header_wrap)
  lxw_worksheet_write_string(worksheet, 2, 3, 'Возраст', header)
  lxw_worksheet_write_string(worksheet, 2, 4, 'Терапевтический участок', header_wrap)
  lxw_worksheet_write_string(worksheet, 2, 5, 'Наименование медицинской организации', header)

  /* Установить высоту строки */
  lxw_worksheet_set_row(worksheet, 0, 35.0)
  lxw_worksheet_set_row(worksheet, 2, 35.0)

  /* Установить ширину колонок */
  lxw_worksheet_set_column(worksheet, 0, 0, 8.0)
  lxw_worksheet_set_column(worksheet, 1, 1, 50.0)
  lxw_worksheet_set_column(worksheet, 2, 2, 10.0)
  lxw_worksheet_set_column(worksheet, 3, 3, 10.0)
  lxw_worksheet_set_column(worksheet, 4, 4, 12.0)
  lxw_worksheet_set_column(worksheet, 5, 5, 50.0)
  
  /* Заморозим 3-е верхние строки на закладке. */
  lxw_worksheet_freeze_panes(worksheet, 3, 0)

  hGauge := GaugeNew(,,,hb_Utf8ToStr('Составление файла для ВОМИАЦ','RU866'),.t.)
  GaugeDisplay( hGauge )
  row := 3
  curr := 0
  R_Use_base("kartotek")
  set order to 0
  go top
  do while  !eof()
    GaugeUpdate( hGauge, ++curr/lastrec() )
    if kart->kod > 0 .and. kart2->mo_pr == glob_MO[_MO_KOD_TFOMS]
      if f_starshe_60(kart->DATE_R,dCreate)
        lxw_worksheet_write_number(worksheet, row, 0, row - 2, cell_format_num)
        arr_fio := retFamImOt(1,.f.,.F.)
        lxw_worksheet_write_string(worksheet, row, 1, hb_StrToUtf8( arr_fio[1]+" "+arr_fio[2]+" "+arr_fio[3] ), cell_format_string)
        lxw_worksheet_write_datetime(worksheet, row, 2, HB_STOT(DToS(kart->DATE_R) + '000000000'), formatDate)
        lxw_worksheet_write_number(worksheet, row, 3, count_years(kart->DATE_R,date()), cell_format_num)
        lxw_worksheet_write_number(worksheet, row, 4, kart->uchast, cell_format_num)
        lxw_worksheet_write_string(worksheet, row, 5, strMO, cell_format_string)
        ++row
      endif
    endif
    KART->(dbSkip())
  enddo
  KART->(dbCloseAll())
  CloseGauge(hGauge)

  return lxw_workbook_close(workbook)
