#include 'inkey.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'hbxlsxwriter.ch'

// 06.10.23
Function create_xls_rdl( name, arr_m, st_a_uch, lcount_uch, st_a_otd, lcount_otd )

  Local workbook, worksheet
  Local worksheetError
  Local format_header_main
  Local format_header
  Local format_text, format_text3
  Local error
  Local name_file := name + '.xlsx'
  Local iRow := 1
  Local tmpAlias

  tmpAlias := Select()

  /* Создадим новую книгу. */
  workbook   = workbook_new( name_file )

  /* Конфигурируем формат для шапки. */
  format_header_main    = workbook_add_format( workbook )
  format_set_align( format_header_main, LXW_ALIGN_CENTER )
  format_set_align( format_header_main, LXW_ALIGN_VERTICAL_CENTER )
  format_set_font_size( format_header_main, 14 )

  format_header    = workbook_add_format( workbook )
  format_set_align( format_header, LXW_ALIGN_CENTER )
  format_set_align( format_header, LXW_ALIGN_VERTICAL_CENTER )
  format_set_font_size( format_header, 12 )
  format_set_text_wrap( format_header )
  format_set_border( format_header, LXW_BORDER_THIN )

  /* Конфигурируем формат для ntrcnf. */
  format_text    = workbook_add_format( workbook )
  format_set_align( format_text, LXW_ALIGN_LEFT )
  format_set_align( format_text, LXW_ALIGN_VERTICAL_CENTER )
  format_set_font_size( format_text, 11 )
  format_set_text_wrap( format_text )
  format_set_border( format_text, LXW_BORDER_THIN )

  format_text3    = workbook_add_format( workbook )
  format_set_align( format_text3, LXW_ALIGN_VERTICAL_CENTER )
  format_set_font_size( format_text3, 11 )
  format_set_border( format_text3, LXW_BORDER_THIN )

  If hb_FileExists( cur_dir() + 'tmp_xls' + sdbf() )
    /* Добавим лист в книгу. */
    worksheet = workbook_add_worksheet( workbook, 'План-заказ' )

    /* Установить ширину колонок */
    worksheet_set_column( worksheet, 0, 0, 3.0 )

    worksheet_set_column( worksheet, 1, 1, 8.0 )
    worksheet_set_column( worksheet, 2, 2, 8.0 )
    worksheet_set_column( worksheet, 3, 3, 9.86 )
    worksheet_set_column( worksheet, 4, 4, 3.0 )
    worksheet_set_column( worksheet, 5, 5, 5.43 )
    worksheet_set_column( worksheet, 6, 6, 3.0 )
    worksheet_set_column( worksheet, 7, 7, 7.14 )

    Use ( cur_dir() + 'tmp_xls' ) New  Alias FRD
    FRD->( dbGoTop() )
    Do While ! FRD->( Eof() )
      worksheet_set_row( worksheet, iRow, 30.0 )
      worksheet_write_string( worksheet, iRow, 0, hb_StrToUTF8( AllTrim( FRD->SHIFR ) ), format_text )
      worksheet_write_string( worksheet, iRow, 1, hb_StrToUTF8( AllTrim( FRD->U_NAME ) ), format_text )
      worksheet_write_number( worksheet, iRow, 2, FRD->KOL, format_text3 )
      worksheet_write_number( worksheet, iRow, 3, FRD->SUM, format_text3 )
      ++iRow
      FRD->( dbSkip() )
    End
    frd->( dbCloseArea() )
    hb_vfErase( cur_dir() + 'tmp_xls' + sdbf() )
  Endif

  If hb_FileExists( cur_dir() + '_data3' + sdbf() )
    Use ( cur_dir() + '_data3' ) New  Alias FRD
    FRD->( dbGoTop() )
    /* Добавим лист "Снятия" в книгу. */
    worksheetError = workbook_add_worksheet( workbook, 'Снятия' )
    iRow := 0
    // шапка таблицы
    worksheet_merge_range( worksheetError, iRow, 0, iRow++, 10, 'Список снятий по актам контроля', format_header_main )
    worksheet_merge_range( worksheetError, iRow, 0, iRow++, 10, hb_StrToUTF8( AllTrim( arr_m[ 4 ] ) ), format_header_main )  // вывод временного периода
    worksheet_merge_range( worksheetError, iRow, 0, iRow++, 10, '( по дате отчётного периода / все случаи снятия )', format_header_main )
    worksheet_merge_range( worksheetError, iRow, 0, iRow++, 10, '(ТФОМС (иногородние)', format_header_main )
    worksheet_merge_range( worksheetError, iRow, 0, iRow++, 10, hb_StrToUTF8( string_selected_uch( st_a_uch, lcount_uch ) ), format_header_main )
    If Len( st_a_uch ) == 1
      worksheet_merge_range( worksheetError, iRow, 0, iRow++, 10, hb_StrToUTF8( string_selected_otd( st_a_otd, lcount_otd ) ), format_header_main )
    Endif
    worksheet_write_string( worksheetError, iRow, 0, '№ п/п', format_header )
    worksheet_write_string( worksheetError, iRow, 1, 'ОШИБКА', format_header )
    worksheet_write_string( worksheetError, iRow, 2, 'КОД', format_header )
    worksheet_write_string( worksheetError, iRow, 3, 'Наименование', format_header )
    worksheet_write_string( worksheetError, iRow, 4, 'Номер заявки', format_header )
    worksheet_write_string( worksheetError, iRow, 5, 'ФИО', format_header )
    worksheet_write_string( worksheetError, iRow, 6, 'Дата рождения', format_header )
    worksheet_write_string( worksheetError, iRow, 7, 'Кол-во услуг', format_header )
    worksheet_write_string( worksheetError, iRow, 8, 'Стоимость услуг', format_header )
    worksheet_write_string( worksheetError, iRow, 9, 'Отделение', format_header )
    worksheet_write_string( worksheetError, iRow, 10, 'МО напр.', format_header )
    /* Установить ширину колонок */
    worksheet_set_column( worksheetError, 0, 0, 8.0 )
    worksheet_set_column( worksheetError, 1, 1, 10.0 )
    worksheet_set_column( worksheetError, 2, 2, 8.0 )
    worksheet_set_column( worksheetError, 3, 3, 50.0 )
    worksheet_set_column( worksheetError, 4, 4, 8.0 )
    worksheet_set_column( worksheetError, 5, 5, 25.0 )
    worksheet_set_column( worksheetError, 6, 6, 12.0 )
    worksheet_set_column( worksheetError, 7, 7, 7.14 )
    worksheet_set_column( worksheetError, 8, 8, 12.0 )
    worksheet_set_column( worksheetError, 9, 9, 12.0 )
	worksheet_set_column( worksheetError, 10, 10, 8.0 )
  //  worksheet_set_column( worksheetError, 10, 10, 7.14 )
    iRow++
    Do While ! FRD->( Eof() )
      worksheet_write_string( worksheetError, iRow, 0, hb_StrToUTF8( AllTrim( FRD->NUM_USL ) ), format_text )
      worksheet_write_string( worksheetError, iRow, 1, hb_StrToUTF8( AllTrim( FRD->REFREASON ) ), format_text )
      worksheet_write_string( worksheetError, iRow, 2, hb_StrToUTF8( AllTrim( FRD->SHIFR_USL ) ), format_text )
      worksheet_write_string( worksheetError, iRow, 3, hb_StrToUTF8( AllTrim( FRD->NAME_USL ) ), format_text )
      If FRD->NUMORDER != 0
        worksheet_write_number( worksheetError, iRow, 4, FRD->NUMORDER, format_text3 )
      Endif
      worksheet_write_string( worksheetError, iRow, 5, hb_StrToUTF8( AllTrim( FRD->FIO ) ), format_text )
      worksheet_write_string( worksheetError, iRow, 6, hb_StrToUTF8( AllTrim( FRD->DATE_R ) ), format_text )
      worksheet_write_number( worksheetError, iRow, 7, FRD->KOL_USL, format_text3 )
      worksheet_write_number( worksheetError, iRow, 8, FRD->SUM_SN, format_text3 )
      worksheet_write_string( worksheetError, iRow, 9, hb_StrToUTF8( AllTrim( FRD->OTD ) ), format_text )
      worksheet_write_string( worksheetError, iRow, 10, hb_StrToUTF8( AllTrim( FRD->NAPR_UCH ) ), format_text )
      ++iRow
      FRD->( dbSkip() )
    End
	// новый лист
	  /* Добавим лист "Свод. */
    worksheetError = workbook_add_worksheet( workbook, 'Свод' )
	 // шапка таблицы
    worksheet_merge_range( worksheetError, iRow, 0, iRow++, 9, 'Список снятий по актам контроля', format_header_main )
    worksheet_merge_range( worksheetError, iRow, 0, iRow++, 9, hb_StrToUTF8( AllTrim( arr_m[ 4 ] ) ), format_header_main )  // вывод временного периода
    worksheet_merge_range( worksheetError, iRow, 0, iRow++, 9, '( по дате отчётного периода / все случаи снятия )', format_header_main )
    worksheet_merge_range( worksheetError, iRow, 0, iRow++, 9, '(ТФОМС (иногородние)', format_header_main )
    worksheet_merge_range( worksheetError, iRow, 0, iRow++, 9, hb_StrToUTF8( string_selected_uch( st_a_uch, lcount_uch ) ), format_header_main )
    If Len( st_a_uch ) == 1
      worksheet_merge_range( worksheetError, iRow, 0, iRow++, 9, hb_StrToUTF8( string_selected_otd( st_a_otd, lcount_otd ) ), format_header_main )
    Endif
    iRow := 0
	FRD->( dbGoTop() )
	// 
    worksheet_write_string( worksheetError, iRow, 0, '№ п/п', format_header )
    worksheet_write_string( worksheetError, iRow, 1, 'Шифр', format_header )
	worksheet_write_string( worksheetError, iRow, 2, 'КОД', format_header )
    worksheet_write_string( worksheetError, iRow, 3, 'Наименование услуги', format_header )
    worksheet_write_string( worksheetError, iRow, 4, 'Кол-во услуг', format_header )
    worksheet_write_string( worksheetError, iRow, 5, 'Стоимость услуг', format_header )
//	worksheet_write_string( worksheetError, iRow, 6, 'Отделение', format_header )
   
    /* Установить ширину колонок */
	worksheet_set_column( worksheetError, 0, 0, 8.0 )
    worksheet_set_column( worksheetError, 1, 1, 10.0 )
    worksheet_set_column( worksheetError, 2, 2, 8.0 )
    worksheet_set_column( worksheetError, 3, 3, 50.0 )
    worksheet_set_column( worksheetError, 4, 4, 12.0 )
    worksheet_set_column( worksheetError, 5, 5, 12.0 )
    //worksheet_set_column( worksheetError, 6, 6, 7.14 )
  
    iRow++
	flag := .T.
    Do While ! FRD->( Eof() )
	  If FRD->NUMORDER != 0 .and. flag
	   flag := .F.
       worksheet_write_string( worksheetError, iRow, 0, hb_StrToUTF8( AllTrim( FRD->NUM_USL ) ), format_text )
       worksheet_write_string( worksheetError, iRow, 1, hb_StrToUTF8( AllTrim( FRD->REFREASON ) ), format_text )
       worksheet_write_string( worksheetError, iRow, 2, hb_StrToUTF8( AllTrim( FRD->SHIFR_USL ) ), format_text )
       worksheet_write_string( worksheetError, iRow, 3, hb_StrToUTF8( AllTrim( FRD->NAME_USL ) ), format_text )
      endif 
      If FRD->NUMORDER == 0
	    flag := .T.
        worksheet_write_number( worksheetError, iRow, 4, FRD->KOL_USL, format_text3 )
        worksheet_write_number( worksheetError, iRow, 5, FRD->SUM_SN, format_text3 )
      //  worksheet_write_string( worksheetError, iRow, 6, hb_StrToUTF8( AllTrim( FRD->OTD ) ), format_text )
        ++iRow
	  endif 
      FRD->( dbSkip() )
    End
	frd->( dbCloseArea() )
	hb_vfErase( cur_dir() + '_data3' + sdbf() )
	
  Endif

  If hb_FileExists( cur_dir() + 'tmp_err' + sdbf() )
    Use ( cur_dir() + 'tmp_err' ) New  Alias FRD
    FRD->( dbGoTop() )
    /* Добавим лист "Ошибки из ТФОМС" книгу. */
    worksheetError = workbook_add_worksheet( workbook, 'Ошибки из ТФОМС' )
    iRow := 0
    worksheet_write_string( worksheetError, iRow, 0, '№ п/п', format_header )
    worksheet_write_string( worksheetError, iRow, 1, 'Шифр', format_header )
    worksheet_write_string( worksheetError, iRow, 2, 'Наименование услуги', format_header )
    worksheet_write_string( worksheetError, iRow, 3, 'Номер заявки', format_header )
    worksheet_write_string( worksheetError, iRow, 4, 'ФИО', format_header )
    worksheet_write_string( worksheetError, iRow, 5, 'Кол-во услуг', format_header )
    worksheet_write_string( worksheetError, iRow, 6, 'Стоимость услуг', format_header )
    worksheet_write_string( worksheetError, iRow, 7, 'Направившая МО', format_header )
    /* Установить ширину колонок */
    worksheet_set_column( worksheetError, 0, 0, 8.0 )
    worksheet_set_column( worksheetError, 1, 1, 8.0 )
    worksheet_set_column( worksheetError, 2, 2, 50.0 )
    worksheet_set_column( worksheetError, 3, 3, 10.0 )
    worksheet_set_column( worksheetError, 4, 4, 50.0 )
    worksheet_set_column( worksheetError, 5, 5, 8.0 )
    worksheet_set_column( worksheetError, 6, 6, 25.0 )
    worksheet_set_column( worksheetError, 7, 7, 8.0 )
    iRow++
    Do While ! FRD->( Eof() )
      If ( FRD->NUMORDER != 0 ) .or. ( FRD->KOL_USL != 0 )
        worksheet_write_string( worksheetError, iRow, 0, hb_StrToUTF8( AllTrim( FRD->NUM_USL ) ), format_text )
        worksheet_write_string( worksheetError, iRow, 1, hb_StrToUTF8( AllTrim( FRD->SHIFR_USL ) ), format_text )
        worksheet_write_string( worksheetError, iRow, 2, hb_StrToUTF8( AllTrim( FRD->NAME_USL ) ), format_text )
        If ( FRD->NUMORDER != 0 )
          worksheet_write_number( worksheetError, iRow, 3, FRD->NUMORDER, format_text3 )
        Else
          worksheet_write_string( worksheetError, iRow, 3, '', format_text )
        Endif
      Endif
      worksheet_write_string( worksheetError, iRow, 4, hb_StrToUTF8( AllTrim( FRD->FIO ) ), format_text )
      If FRD->KOL_USL != 0
        worksheet_write_number( worksheetError, iRow, 5, FRD->KOL_USL, format_text3 )
      Endif
      If FRD->cena_1 != 0
        worksheet_write_number( worksheetError, iRow, 6, FRD->CENA_1, format_text3 )
      Endif
      If !Empty( FRD->napr_uch )
        worksheet_write_string( worksheetError, iRow, 7, FRD->napr_uch, format_text )
      Endif
      ++iRow
      FRD->( dbSkip() )
    End
    frd->( dbCloseArea() )
    hb_vfErase( cur_dir() + 'tmp_err' + sdbf() )
  Endif
  /* Закрыть книгу, записать файл и освободить память. */
  error = workbook_close( workbook )
  /* Проверить наличие ошибки при создании xlsx файла. */
  If !Empty( error )
    alertx( hb_UTF8ToStr( sprintf( 'Ошибка в workbook_close().\n' + ;
      'Ошибка %d = %s\n', error, hb_ntos( error ) ), 'RU866' ), 'error' )
  Endif
  Select( tmpAlias )

  Return Nil