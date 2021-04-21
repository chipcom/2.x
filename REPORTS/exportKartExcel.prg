#include 'chip_mo.ch'
#include 'hblibxlsxwriter.ch'

function exportKartExcel(fName)
  local workbook
  local header
  local worksheet
  local formatDate
  // local merge_format, merge_cell_name_format
  local fmtCellNumber, fmtCellString, fmtCellStringCenter
  // local cell_code_format
  // local strMO := hb_StrToUtf8( glob_mo[_MO_SHORT_NAME] )
  local arr_fio, row, curr

  lxw_init() 

  if hb_FileExists(fName)  
    filedelete(fName)
  endif

  workbook  := lxw_workbook_new(fName)
  worksheet := lxw_workbook_add_worksheet(workbook, 'Пациенты' )

  formatDate := lxw_workbook_add_format(workbook)
  lxw_format_set_num_format(formatDate, 'dd/mm/yyyy')
  lxw_format_set_align(formatDate, LXW_ALIGN_LEFT)
  lxw_format_set_border(formatDate, LXW_BORDER_THIN)

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

  // merge_format := lxw_workbook_add_format(workbook)
  // /* Конфигурируем формат для объединенных ячеек. */
  // lxw_format_set_align(merge_format, LXW_ALIGN_CENTER)
  // lxw_format_set_align(merge_format, LXW_ALIGN_VERTICAL_CENTER)
  // lxw_format_set_bold(merge_format)
  // lxw_format_set_font_size(merge_format, 14)
  // lxw_format_set_bg_color(merge_format, LXW_COLOR_YELLOW)
  // lxw_format_set_border(merge_format, LXW_BORDER_THIN)

  fmtCellNumber := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmtCellNumber, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmtCellNumber, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_border(fmtCellNumber, LXW_BORDER_THIN)

  fmtCellString := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmtCellString, LXW_ALIGN_LEFT)
  lxw_format_set_align(fmtCellString, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_border(fmtCellString, LXW_BORDER_THIN)

  fmtCellStringCenter := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmtCellStringCenter, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmtCellStringCenter, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_border(fmtCellStringCenter, LXW_BORDER_THIN)

  // шапка
  lxw_worksheet_write_string(worksheet, 2, 0, 'п/н', header)
  lxw_worksheet_write_string(worksheet, 2, 1, 'ФИО', header)
  lxw_worksheet_write_string(worksheet, 2, 2, 'Дата рождения', header_wrap)
  lxw_worksheet_write_string(worksheet, 2, 3, 'Возраст', header)
  lxw_worksheet_write_string(worksheet, 2, 4, 'Пол', header_wrap)

  /* Установить высоту строки */
  lxw_worksheet_set_row(worksheet, 0, 35.0)
  lxw_worksheet_set_row(worksheet, 2, 35.0)

  /* Установить ширину колонок */
  lxw_worksheet_set_column(worksheet, 0, 0, 8.0)
  lxw_worksheet_set_column(worksheet, 1, 1, 50.0)
  lxw_worksheet_set_column(worksheet, 2, 2, 10.0)
  lxw_worksheet_set_column(worksheet, 3, 3, 10.0)
  lxw_worksheet_set_column(worksheet, 4, 4, 12.0)
  // lxw_worksheet_set_column(worksheet, 5, 5, 50.0)

  /* Заморозим 3-е верхние строки на закладке. */
  lxw_worksheet_freeze_panes(worksheet, 3, 0)

  hGauge := GaugeNew(,,,hb_Utf8ToStr('Экспорт картотеки в Excel','RU866'),.t.)
  GaugeDisplay( hGauge )
  row := 3
  curr := 0

  R_Use(dir_server + 'kartote2', , 'KART2')
  R_Use(dir_server + 'kartote_', , 'KART_')
  R_Use(dir_server + 'kartotek', , 'KART')
  set relation to recno() into KART_, to recno() into KART2


  // R_Use_base("kartotek")
  // set order to 0
  KART->(dbGoTop()) // go top
  do while  ! KART->(eof())   // eof()
    GaugeUpdate( hGauge, ++curr / KART->(lastrec()) )

    if ! (left(kart2->PC2,1) == '1')  // выбираем только живых
      lxw_worksheet_write_number(worksheet, row, 0, row - 2, fmtCellNumber)
      arr_fio := retFamImOt( 1, .f., .f. )
      lxw_worksheet_write_string(worksheet, row, 1, hb_StrToUtf8( arr_fio[1] + ' ' + arr_fio[2] + ' ' + arr_fio[3] ), fmtCellString)
      lxw_worksheet_write_datetime(worksheet, row, 2, HB_STOT(DToS(KART->DATE_R)), formatDate)
      lxw_worksheet_write_number(worksheet, row, 3, count_years(KART->DATE_R, date()), fmtCellNumber)
      lxw_worksheet_write_string(worksheet, row, 4, hb_StrToUtf8( KART->POL ), fmtCellStringCenter)
      // lxw_worksheet_write_number(worksheet, row, 4, kart->uchast, fmtCellNumber)
      // lxw_worksheet_write_string(worksheet, row, 5, strMO, fmtCellString)
      ++row
    endif
    
    KART->(dbSkip())
  enddo
  KART->(dbCloseAll())

  lxw_worksheet_autofilter(worksheet, 2, 0, row - 1, 4)

  lxw_workbook_close(workbook)

  CloseGauge(hGauge)

  return nil