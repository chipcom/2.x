#include 'hblibxlsxwriter.ch'

procedure main()
  local workbook
  local shTitul, sh1000, sh2000, sh3000, sh3001, sh4000, sh5000DVN, sh5000PO
  local sh6000, sh5000
  local fName := 'f131.xlsx'
  local error

  lxw_init() 

  // if hb_FileExists(fName)  
  //   filedelete(fName)
  // endif


  workbook  := lxw_workbook_new( 'f131.xlsx' )
  shTitul := lxw_workbook_add_worksheet(workbook, 'Титульный лист' )
  sh1000 := lxw_workbook_add_worksheet(workbook, '1000, 1001' )
  sh2000 := lxw_workbook_add_worksheet(workbook, '2000' )
  sh3000 := lxw_workbook_add_worksheet(workbook, '2001, 3000' )
  sh3001 := lxw_workbook_add_worksheet(workbook, '3001, 3002, 3003' )
  sh4000 := lxw_workbook_add_worksheet(workbook, '4000, 4001' )
  sh5000DVN := lxw_workbook_add_worksheet(workbook, '5000 и 5001 ДВН' )
  sh5000PO := lxw_workbook_add_worksheet(workbook, '5000 и 5001 ПО' )
  sh6000 := lxw_workbook_add_worksheet(workbook, '6000-6010' )
  sh5000 := lxw_workbook_add_worksheet(workbook, '5000, 5001' )

  /* Установим цвета закладок. */
  lxw_worksheet_set_tab_color(sh1000, LXW_COLOR_YELLOW)
  lxw_worksheet_set_tab_color(sh3000, LXW_COLOR_YELLOW)
  lxw_worksheet_set_tab_color(sh3001, LXW_COLOR_YELLOW)
  lxw_worksheet_set_tab_color(sh2000, LXW_COLOR_LIME)
  lxw_worksheet_set_tab_color(sh4000, LXW_COLOR_BLUE)
  lxw_worksheet_set_tab_color(sh5000DVN, LXW_COLOR_PINK)
  lxw_worksheet_set_tab_color(sh5000PO, LXW_COLOR_GRAY)
  lxw_worksheet_set_tab_color(sh6000, LXW_COLOR_GRAY)

  /* Конфигурируем формат для шапки. */
  shTitulFmt1 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(shTitulFmt1, LXW_ALIGN_CENTER)
  lxw_format_set_align(shTitulFmt1, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(shTitulFmt1, 12)
  lxw_format_set_text_wrap(shTitulFmt1)
  lxw_format_set_border(shTitulFmt1, LXW_BORDER_THIN)

  shTitulFmt2 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(shTitulFmt2, LXW_ALIGN_CENTER)
  lxw_format_set_align(shTitulFmt2, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(shTitulFmt2, 12)

  shTitulFmt3 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(shTitulFmt3, LXW_ALIGN_CENTER)
  lxw_format_set_align(shTitulFmt3, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(shTitulFmt3, 12)
  lxw_format_set_bold(shTitulFmt3)
  lxw_format_set_border(shTitulFmt3, LXW_BORDER_THICK)

  shTitulFmt4 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(shTitulFmt4, LXW_ALIGN_LEFT)
  lxw_format_set_align(shTitulFmt4, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(shTitulFmt4, 12)
  lxw_format_set_text_wrap(shTitulFmt4)
  lxw_format_set_border(shTitulFmt4, LXW_BORDER_THIN)

  lxw_worksheet_set_column(shTitul, 0, 0, 11.86)
  lxw_worksheet_set_column(shTitul, 1, 1, 90.0)
  lxw_worksheet_set_column(shTitul, 2, 2, 18.0)
  lxw_worksheet_set_column(shTitul, 3, 3, 18.0)
  lxw_worksheet_set_column(shTitul, 4, 4, 18.0)
  lxw_worksheet_set_column(shTitul, 5, 5, 15.0)
  lxw_worksheet_set_column(shTitul, 6, 6, 15.0)

  lxw_worksheet_write_string(shTitul, 1, 6, 'Приложение № 3', nil)
  lxw_worksheet_write_string(shTitul, 2, 6, 'К приказу министерства здравоохранения', nil)
  lxw_worksheet_write_string(shTitul, 3, 6, 'Российской Федерации', nil)
  lxw_worksheet_write_string(shTitul, 4, 6, 'от 10 ноября 2020 г. № 1207н', nil)
  lxw_worksheet_merge_range(shTitul, 6, 1, 6, 2, 'ОТРАСЛЕВАЯ СТАТИСТИЧЕСКАЯ ОТЧЕТНОСТЬ', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 8, 1, 8, 2, 'КОНФИДЕНЦИАЛЬНОСТЬ ГАРАНТИРУЕТСЯ ПОЛУЧАТЕЛЕМ ИНФОРМАЦИИ', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 10, 1, 10, 3, 'ВОЗМОЖНО ПРЕДСТАВЛЕНИЕ В ЭЛЕКТРОННОМ ВИДЕ', shTitulFmt2)
  lxw_worksheet_merge_range(shTitul, 12, 1, 12, 3, '"СВЕДЕНИЯ О ПРОВЕДЕНИИ ПРОФИЛАКТИЧЕСКОГО МЕДИЦИНСКОГО ОСМОТРА И ДИСПАНСЕРИЗАЦИИ ОПРЕДЕЛЕННЫХ ГРУПП ВЗРОСЛОГО НАСЕЛЕНИЯ"', shTitulFmt3)
  lxw_worksheet_write_string(shTitul,13, 1, '2021 года                          за период', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,13, 2, 'январь', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,13, 3, 'февраль', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,15, 1, 'Представляют:', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 15, 2, 15, 4, 'Сроки представления', shTitulFmt1)
  lxw_worksheet_set_row(shTitul, 16, 10.5)
  lxw_worksheet_merge_range(shTitul, 16, 1, 18, 1, 'Медицинские организации, оказывающие первичную медико-санитарную помощь (далее - медицинская организация), органу исполнительной власти субъектов Российской Федерации в сфере охраны здоровья', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 16, 2, 18, 4, '5 числа месяца, следующего за отчетным периодом', shTitulFmt1)
  lxw_worksheet_set_row(shTitul, 19, 45.5)
  lxw_worksheet_write_string(shTitul, 19, 1, 'Органы исполнительной власти субъектов Российской Федерации в сфере охраны здоровья - Министерству здравоохранения Российской Федерации', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 19, 2, 19, 4, '10 числа месяца, следующего за отчетным периодом', shTitulFmt1)
  
  lxw_worksheet_write_string(shTitul,21, 1, 'Наименовние медицинской организации:', shTitulFmt4)
  lxw_worksheet_merge_range(shTitul, 22, 1, 22, 6, 'Почтовый адрес:', shTitulFmt4)

  lxw_worksheet_set_row(shTitul, 23, 60.0)
  lxw_worksheet_write_string(shTitul,23, 1, 'Код медицинской организации по ОКПО', shTitulFmt4)
  lxw_worksheet_write_string(shTitul,24, 1, '1', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,25, 1, '00088390', shTitulFmt1)

  lxw_worksheet_set_row(shTitul, 27, 25.0)
  lxw_worksheet_write_string(shTitul,27, 1, 'Должностное лицо (уполномоченный представитель), ответственное за предоставление статистической информации ', shTitulFmt4)

  /* Закрыть книгу, записать файл и освободить память. */
  error = lxw_workbook_close(workbook)

  /* Проверить наличие ошибки при создании xlsx файла. */
  if !EMPTY(error)
    sprintf("Error in workbook_close().\n"+;
           "Error %d = %s\n", error, HB_NTOS(error))
  endif

  return