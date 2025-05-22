#include 'chip_mo.ch'
#include 'hbxlsxwriter.ch'

Function writexlsxgreater60( fName, dCreate )

  Local workbook, header, header_wrap
  Local worksheet
  Local merge_format, formatDate, cell_format_num, cell_format_string
  local hGauge, row, curr, arr_fio
  Local strMO := hb_StrToUTF8( glob_mo[ _MO_SHORT_NAME ] )

  workbook  := workbook_new( fName )
  worksheet := workbook_add_worksheet( workbook, 'Sheet1' )

  /* Create a format for the date or time.*/
  formatDate := workbook_add_format( workbook )
  format_set_num_format( formatDate, 'dd/mm/yyyy' )
  format_set_align( formatDate, LXW_ALIGN_LEFT )
  format_set_border( formatDate, LXW_BORDER_THIN )

  /* Set up some formatting and text to highlight the panes. */
  header = workbook_add_format( workbook )
  format_set_align( header, LXW_ALIGN_CENTER )
  format_set_align( header, LXW_ALIGN_VERTICAL_CENTER )
  format_set_fg_color( header, 0xD7E4BC )
  format_set_bold( header )
  format_set_border( header, LXW_BORDER_THIN )

  header_wrap = workbook_add_format( workbook )
  format_set_align( header_wrap, LXW_ALIGN_CENTER )
  format_set_align( header_wrap, LXW_ALIGN_VERTICAL_CENTER )
  format_set_fg_color( header_wrap, 0xD7E4BC )
  format_set_bold( header_wrap )
  format_set_border( header_wrap, LXW_BORDER_THIN )
  format_set_text_wrap( header_wrap )

  merge_format := workbook_add_format( workbook )
  /* Конфигурируем формат для объединенных ячеек. */
  format_set_align( merge_format, LXW_ALIGN_CENTER )
  format_set_align( merge_format, LXW_ALIGN_VERTICAL_CENTER )
  format_set_bold( merge_format )
  format_set_font_size( merge_format, 14 )
  format_set_bg_color( merge_format, LXW_COLOR_YELLOW )
  format_set_border( merge_format, LXW_BORDER_THIN )

  cell_format_num := workbook_add_format( workbook )
  /* Конфигурируем формат для вывода чисел. */
  format_set_align( cell_format_num, LXW_ALIGN_CENTER )
  format_set_align( cell_format_num, LXW_ALIGN_VERTICAL_CENTER )
  format_set_border( cell_format_num, LXW_BORDER_THIN )

  cell_format_string := workbook_add_format( workbook )
  /* Конфигурируем формат для вывода чисел. */
  format_set_align( cell_format_string, LXW_ALIGN_LEFT )
  format_set_align( cell_format_string, LXW_ALIGN_VERTICAL_CENTER )
  format_set_border( cell_format_string, LXW_BORDER_THIN )

  /* Объединить 5 колонок одной строки. */
  worksheet_merge_range( worksheet, 0, 0, 0, 5, 'Список граждан старше 60 лет, прикрепленных к медицинской организации, по терапевтическим участкам', merge_format )

  /* Нарисуем шапку */
  worksheet_write_string( worksheet, 2, 0, 'п/н', header )
  worksheet_write_string( worksheet, 2, 1, 'ФИО', header )
  worksheet_write_string( worksheet, 2, 2, 'Дата рождения', header_wrap )
  worksheet_write_string( worksheet, 2, 3, 'Возраст', header )
  worksheet_write_string( worksheet, 2, 4, 'Терапевтический участок', header_wrap )
  worksheet_write_string( worksheet, 2, 5, 'Наименование медицинской организации', header )

  /* Установить высоту строки */
  worksheet_set_row( worksheet, 0, 35.0 )
  worksheet_set_row( worksheet, 2, 35.0 )

  /* Установить ширину колонок */
  worksheet_set_column( worksheet, 0, 0, 8.0 )
  worksheet_set_column( worksheet, 1, 1, 50.0 )
  worksheet_set_column( worksheet, 2, 2, 10.0 )
  worksheet_set_column( worksheet, 3, 3, 10.0 )
  worksheet_set_column( worksheet, 4, 4, 12.0 )
  worksheet_set_column( worksheet, 5, 5, 50.0 )

  /* Заморозим 3-е верхние строки на закладке. */
  worksheet_freeze_panes( worksheet, 3, 0 )

  hGauge := gaugenew(,,, hb_UTF8ToStr( 'Составление файла для ВОМИАЦ', 'RU866' ), .t. )
  gaugedisplay( hGauge )
  row := 3
  curr := 0
  r_use_base( 'kartotek' )
  Set Order To 0
  Go Top
  Do While  !Eof()
    gaugeupdate( hGauge, ++curr / LastRec() )
    If kart->kod > 0 .and. kart2->mo_pr == glob_MO[ _MO_KOD_TFOMS ]
      If ageismorethan( 60, kart->DATE_R, dCreate )
        worksheet_write_number( worksheet, row, 0, row -2, cell_format_num )
        arr_fio := retfamimot( 1, .f., .f. )
        worksheet_write_string( worksheet, row, 1, hb_StrToUTF8( arr_fio[ 1 ] + ' ' + arr_fio[ 2 ] + ' ' + arr_fio[ 3 ] ), cell_format_string )
        worksheet_write_datetime( worksheet, row, 2, hb_SToT( DToS( kart->DATE_R ) ), formatDate )
        worksheet_write_number( worksheet, row, 3, count_years( kart->DATE_R, Date() ), cell_format_num )
        worksheet_write_number( worksheet, row, 4, kart->uchast, cell_format_num )
        worksheet_write_string( worksheet, row, 5, strMO, cell_format_string )
        ++row
      Endif
    Endif
    KART->( dbSkip() )
  Enddo
  KART->( dbCloseAll() )
  closegauge( hGauge )
  Return workbook_close( workbook )
