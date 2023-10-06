#include 'chip_mo.ch'
// #include "hblibxlsxwriter.ch"
#include 'hbxlsxwriter.ch'

function WriteXLSXGreater60(fName, dCreate)
  local workbook, header
  local worksheet
  local worksheetRemoved
  local merge_format, merge_cell_name_format
  local cell_code_format
  local strMO := hb_StrToUtf8( glob_mo[_MO_SHORT_NAME] )

  workbook  := WORKBOOK_NEW(fName)
  worksheet := WORKBOOK_ADD_WORKSHEET(workbook, 'Sheet1' )

  /* Create a format for the date or time.*/
  formatDate := WORKBOOK_ADD_FORMAT(workbook)
  FORMAT_SET_NUM_FORMAT(formatDate, 'dd/mm/yyyy')
  FORMAT_SET_ALIGN(formatDate, LXW_ALIGN_LEFT)
  FORMAT_SET_BORDER(formatDate, LXW_BORDER_THIN)

  /* Set up some formatting and text to highlight the panes. */
  header = WORKBOOK_ADD_FORMAT(workbook)
  FORMAT_SET_ALIGN(header, LXW_ALIGN_CENTER)
  FORMAT_SET_ALIGN(header, LXW_ALIGN_VERTICAL_CENTER)
  FORMAT_SET_FG_COLOR(header, 0xD7E4BC)
  FORMAT_SET_BOLD(header)
  FORMAT_SET_BORDER(header, LXW_BORDER_THIN)

  header_wrap = WORKBOOK_ADD_FORMAT(workbook)
  FORMAT_SET_ALIGN(header_wrap, LXW_ALIGN_CENTER)
  FORMAT_SET_ALIGN(header_wrap, LXW_ALIGN_VERTICAL_CENTER)
  FORMAT_SET_FG_COLOR(header_wrap, 0xD7E4BC)
  FORMAT_SET_BOLD(header_wrap)
  FORMAT_SET_BORDER(header_wrap, LXW_BORDER_THIN)
  FORMAT_SET_TEXT_WRAP(header_wrap)

  merge_format := WORKBOOK_ADD_FORMAT(workbook)
  /* Конфигурируем формат для объединенных ячеек. */
  FORMAT_SET_ALIGN(merge_format, LXW_ALIGN_CENTER)
  FORMAT_SET_ALIGN(merge_format, LXW_ALIGN_VERTICAL_CENTER)
  FORMAT_SET_BOLD(merge_format)
  FORMAT_SET_FONT_SIZE(merge_format, 14)
  FORMAT_SET_BG_COLOR(merge_format, LXW_COLOR_YELLOW)
  FORMAT_SET_BORDER(merge_format, LXW_BORDER_THIN)


  cell_format_num := WORKBOOK_ADD_FORMAT(workbook)
  /* Конфигурируем формат для вывода чисел. */
  FORMAT_SET_ALIGN(cell_format_num, LXW_ALIGN_CENTER)
  FORMAT_SET_ALIGN(cell_format_num, LXW_ALIGN_VERTICAL_CENTER)
  // FORMAT_SET_BG_COLOR(merge_cell_code_format, LXW_COLOR_YELLOW)
  FORMAT_SET_BORDER(cell_format_num, LXW_BORDER_THIN)

  cell_format_string := WORKBOOK_ADD_FORMAT(workbook)
  /* Конфигурируем формат для вывода чисел. */
  FORMAT_SET_ALIGN(cell_format_string, LXW_ALIGN_LEFT)
  FORMAT_SET_ALIGN(cell_format_string, LXW_ALIGN_VERTICAL_CENTER)
  // FORMAT_SET_BG_COLOR(merge_cell_code_format, LXW_COLOR_YELLOW)
  FORMAT_SET_BORDER(cell_format_string, LXW_BORDER_THIN)

  /* Объединить 5 колонок одной строки. */
  WORKSHEET_MERGE_RANGE(worksheet, 0, 0, 0, 5, 'Список граждан старше 60 лет, прикрепленных к медицинской организации, по терапевтическим участкам', merge_format)

  /* Нарисуем шапку */
  WORKSHEET_WRITE_STRING(worksheet, 2, 0, 'п/н', header)
  WORKSHEET_WRITE_STRING(worksheet, 2, 1, 'ФИО', header)
  WORKSHEET_WRITE_STRING(worksheet, 2, 2, 'Дата рождения', header_wrap)
  WORKSHEET_WRITE_STRING(worksheet, 2, 3, 'Возраст', header)
  WORKSHEET_WRITE_STRING(worksheet, 2, 4, 'Терапевтический участок', header_wrap)
  WORKSHEET_WRITE_STRING(worksheet, 2, 5, 'Наименование медицинской организации', header)

  /* Установить высоту строки */
  WORKSHEET_SET_ROW(worksheet, 0, 35.0)
  WORKSHEET_SET_ROW(worksheet, 2, 35.0)

  /* Установить ширину колонок */
  WORKSHEET_SET_COLUMN(worksheet, 0, 0, 8.0)
  WORKSHEET_SET_COLUMN(worksheet, 1, 1, 50.0)
  WORKSHEET_SET_COLUMN(worksheet, 2, 2, 10.0)
  WORKSHEET_SET_COLUMN(worksheet, 3, 3, 10.0)
  WORKSHEET_SET_COLUMN(worksheet, 4, 4, 12.0)
  WORKSHEET_SET_COLUMN(worksheet, 5, 5, 50.0)
  
  /* Заморозим 3-е верхние строки на закладке. */
  WORKSHEET_FREEZE_PANES(worksheet, 3, 0)

  hGauge := GaugeNew(,,,hb_Utf8ToStr('Составление файла для ВОМИАЦ','RU866'),.t.)
  GaugeDisplay( hGauge )
  row := 3
  curr := 0
  R_Use_base("kartotek")
  set order to 0
  go top
  do while  !eof()
    GaugeUpdate( hGauge, ++curr / lastrec() )
    if kart->kod > 0 .and. kart2->mo_pr == glob_MO[_MO_KOD_TFOMS]
      if ageIsMoreThan(60, kart->DATE_R, dCreate)
        WORKSHEET_WRITE_NUMBER(worksheet, row, 0, row - 2, cell_format_num)
        arr_fio := retFamImOt(1,.f.,.F.)
        WORKSHEET_WRITE_STRING(worksheet, row, 1, hb_StrToUtf8( arr_fio[1]+" "+arr_fio[2]+" "+arr_fio[3] ), cell_format_string)
        WORKSHEET_WRITE_DATETIME(worksheet, row, 2, HB_STOT(DToS(kart->DATE_R)), formatDate)
        WORKSHEET_WRITE_NUMBER(worksheet, row, 3, count_years(kart->DATE_R,date()), cell_format_num)
        WORKSHEET_WRITE_NUMBER(worksheet, row, 4, kart->uchast, cell_format_num)
        WORKSHEET_WRITE_STRING(worksheet, row, 5, strMO, cell_format_string)
        ++row
      endif
    endif
    KART->(dbSkip())
  enddo
  KART->(dbCloseAll())
  CloseGauge(hGauge)

  return WORKBOOK_CLOSE(workbook)
