#include 'inkey.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'hblibxlsxwriter.ch'

** 15.08.22
function create_xls_rdl(name, arr_m, st_a_uch, lcount_uch, st_a_otd, lcount_otd)
  local workbook, worksheet, format_top1, format_top2
  local worksheetError
  local format_header_main
  local format_header, format_header2
  local format_text, format_text2, format_text3
  local error
  local name_file := name + '.xlsx'
  local iRow := 1

  lxw_init()

  /* Создадим новую книгу. */
  workbook   = lxw_workbook_new(name_file)

  /* Конфигурируем формат для шапки. */
  format_header_main    = lxw_workbook_add_format(workbook)
  lxw_format_set_align(format_header_main, LXW_ALIGN_CENTER)
  lxw_format_set_align(format_header_main, LXW_ALIGN_VERTICAL_CENTER)
  // lxw_format_set_bold(format_header_main)
  lxw_format_set_font_size(format_header_main, 14)

  format_header    = lxw_workbook_add_format(workbook)
  lxw_format_set_align(format_header, LXW_ALIGN_CENTER)
  lxw_format_set_align(format_header, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(format_header, 12)
  lxw_format_set_text_wrap(format_header)
  lxw_format_set_border(format_header, LXW_BORDER_THIN)

  // format_header2    = lxw_workbook_add_format(workbook)
  // lxw_format_set_align(format_header2, LXW_ALIGN_CENTER)
  // lxw_format_set_align(format_header2, LXW_ALIGN_VERTICAL_CENTER)
  // lxw_format_set_font_size(format_header2, 11)
  // lxw_format_set_text_wrap(format_header2)
  // lxw_format_set_border(format_header2, LXW_BORDER_THIN)

  /* Конфигурируем формат для ntrcnf. */
  format_text    = lxw_workbook_add_format(workbook)
  lxw_format_set_align(format_text, LXW_ALIGN_LEFT)
  lxw_format_set_align(format_text, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(format_text, 11)
  lxw_format_set_text_wrap(format_text)
  lxw_format_set_border(format_text, LXW_BORDER_THIN)

  format_text3    = lxw_workbook_add_format(workbook)
  // lxw_format_set_align(format_text3, LXW_ALIGN_CENTER)
  lxw_format_set_align(format_text3, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(format_text3, 11)
  // lxw_format_set_text_wrap(format_text3)
  lxw_format_set_border(format_text3, LXW_BORDER_THIN)

  if hb_FileExists(cur_dir + 'tmp_xls' + sdbf)
    /* Добавим лист в книгу. */
    worksheet = lxw_workbook_add_worksheet(workbook, 'План-заказ')

    /* Установить ширину колонок */
    lxw_worksheet_set_column(worksheet, 0, 0, 3.0)
  
    lxw_worksheet_set_column(worksheet, 1, 1, 8.0)
    lxw_worksheet_set_column(worksheet, 2, 2, 8.0)
    lxw_worksheet_set_column(worksheet, 3, 3, 9.86)
    lxw_worksheet_set_column(worksheet, 4, 4, 3.0)
    lxw_worksheet_set_column(worksheet, 5, 5, 5.43)
    lxw_worksheet_set_column(worksheet, 6, 6, 3.0)
    lxw_worksheet_set_column(worksheet, 7, 7, 7.14)

    //   adbf := {{'kod','N',4,0},;
    //     {'kod1','N',4,0},;
    //     {'shifr','C',10,0},;
    //     {'u_name','C',255,0},;
    //     {'kol','N',7,0},;
    //     {'kol1','N',7,0},;
    //     {'uet','N',11,4},;
    //     {'sum','N',13,2}}

    use (cur_dir + 'tmp_xls') new  alias FRD
    FRD->(dbGoTop())
    do while ! FRD->(eof())

      lxw_worksheet_set_row(worksheet, iRow, 30.0)
      // lxw_worksheet_write_number(worksheet, iRow, 0, FRD->KOD, format_text3)
      // lxw_worksheet_write_number(worksheet, iRow, 1, FRD->KOD1, format_text3)

      lxw_worksheet_write_string(worksheet, iRow, 0, hb_StrToUtf8( alltrim(FRD->SHIFR) ), format_text)
      lxw_worksheet_write_string(worksheet, iRow, 1, hb_StrToUtf8( alltrim(FRD->U_NAME) ), format_text)
      lxw_worksheet_write_number(worksheet, iRow, 2, FRD->KOL, format_text3)
      // lxw_worksheet_write_number(worksheet, iRow, 5, FRD->KOL1, format_text3)
      // lxw_worksheet_write_number(worksheet, iRow, 6, FRD->UET, format_text3)
      lxw_worksheet_write_number(worksheet, iRow, 3, FRD->SUM, format_text3)

      ++iRow
      FRD->(dbSkip())
    end
    frd->(dbCloseArea())
    hb_vfErase(cur_dir + 'tmp_xls' + sdbf)
  endif

  if hb_FileExists(cur_dir + '_data3' + sdbf)
    // вторая таблица
    //   adbf := {{'num_usl','C',10,0},;
    //     {'refreason','C',15,0},;
    //     {'shifr_usl','C',10,0},;
    //     {'name_usl','C',250,0},;
    //     {'numorder','N',10,0},;
    //     {'fio','C',60,0},;
    //     {'date_r','C',10,0},;
    //     {'kol_usl','N',10,0},;
    //     {'cena_1','N',11,2},;
    //     {'sum_sn','N',11,2},;
    //     {'date_rep','C',10,0},;
    //     {'otd','C',42,0}}
    use (cur_dir + '_data3') new  alias FRD
    FRD->(dbGoTop())
    /* Добавим лист "Снятия" в книгу. */
    worksheetError = lxw_workbook_add_worksheet(workbook, 'Снятия')

    iRow := 0
    // шапка таблицы
    lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, 'Список снятий по актам контроля', format_header_main)
    lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, hb_StrToUtf8( alltrim(arr_m[4]) ), format_header_main)  // вывод временного периода
    lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, '( по дате отчётного периода / все случаи снятия )', format_header_main)
    lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, '(ТФОМС (иногородние)', format_header_main)
    lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, hb_StrToUtf8(string_selected_uch(st_a_uch, lcount_uch)), format_header_main)
    if len(st_a_uch) == 1
      lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, hb_StrToUtf8(string_selected_otd(st_a_otd, lcount_otd)), format_header_main)
    endif
      
    lxw_worksheet_write_string(worksheetError, iRow, 0, '№ п/п', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 1, 'ОШИБКА', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 2, 'КОД', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 3, 'Наименование', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 4, 'Номер заявки', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 5, 'ФИО', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 6, 'Дата рождения', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 7, 'Кол-во услуг', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 8, 'Стоимость услуг', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 9, 'Отделение', format_header)

    /* Установить ширину колонок */
    lxw_worksheet_set_column(worksheetError, 0, 0, 8.0)
    lxw_worksheet_set_column(worksheetError, 1, 1, 10.0)
    lxw_worksheet_set_column(worksheetError, 2, 2, 8.0)
    lxw_worksheet_set_column(worksheetError, 3, 3, 50.0)
    lxw_worksheet_set_column(worksheetError, 4, 4, 8.0)
    lxw_worksheet_set_column(worksheetError, 5, 5, 25.0)
    lxw_worksheet_set_column(worksheetError, 6, 6, 12.0)
    lxw_worksheet_set_column(worksheetError, 7, 7, 7.14)
    lxw_worksheet_set_column(worksheetError, 8, 8, 12.0)
    lxw_worksheet_set_column(worksheetError, 9, 9, 12.0)
    lxw_worksheet_set_column(worksheetError, 10, 10, 7.14)

    iRow++
    do while ! FRD->(eof())
      lxw_worksheet_write_string(worksheetError, iRow, 0, hb_StrToUtf8( alltrim(FRD->NUM_USL) ), format_text)
      lxw_worksheet_write_string(worksheetError, iRow, 1, hb_StrToUtf8( alltrim(FRD->REFREASON) ), format_text)
      lxw_worksheet_write_string(worksheetError, iRow, 2, hb_StrToUtf8( alltrim(FRD->SHIFR_USL) ), format_text)
      lxw_worksheet_write_string(worksheetError, iRow, 3, hb_StrToUtf8( alltrim(FRD->NAME_USL) ), format_text)
      if FRD->NUMORDER != 0
        lxw_worksheet_write_number(worksheetError, iRow, 4, FRD->NUMORDER, format_text3)
      endif
      lxw_worksheet_write_string(worksheetError, iRow, 5, hb_StrToUtf8( alltrim(FRD->FIO) ), format_text)
      lxw_worksheet_write_string(worksheetError, iRow, 6, hb_StrToUtf8( alltrim(FRD->DATE_R) ), format_text)
      lxw_worksheet_write_number(worksheetError, iRow, 7, FRD->KOL_USL, format_text3)
      lxw_worksheet_write_number(worksheetError, iRow, 8, FRD->SUM_SN, format_text3)
      lxw_worksheet_write_string(worksheetError, iRow, 9, hb_StrToUtf8( alltrim(FRD->OTD) ), format_text)

      ++iRow
      FRD->(dbSkip())
    end
    frd->(dbCloseArea())
    hb_vfErase(cur_dir + '_data3' + sdbf)
  endif

  if hb_FileExists(cur_dir + 'tmp_err' + sdbf)

    // adbf1 :=  {{'num_usl', 'C', 10, 0}, ;    // номер услуги по порядку
    // {'shifr_usl', 'C', 10, 0}, ;  // шифр услуги 
    // {'name_usl', 'C', 250, 0}, ; // наименование услуги 
    // {'NUMORDER', 'N', 10, 0}, ;   // Номер заявки(ORDER Number)
    // {'fio', 'C', 70, 0}, ;
    // {'kol_usl', 'N', 10, 0}, ;    // кол-во услуг
    // {'cena_1', 'N', 11, 2}, ;
    // {'otd', 'C', 42, 0}, ;
    // {'otd_kod', 'N', 3, 0}}     

    use (cur_dir + 'tmp_err') new  alias FRD
    FRD->(dbGoTop())
    /* Добавим лист "Ошибки из ТФОМС" книгу. */
    worksheetError = lxw_workbook_add_worksheet(workbook, 'Ошибки из ТФОМС')

    iRow := 0
    // шапка таблицы
    // lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, 'Список снятий по актам контроля', format_header_main)
    // lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, hb_StrToUtf8( alltrim(arr_m[4]) ), format_header_main)  // вывод временного периода
    // lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, '( по дате отчётного периода / все случаи снятия )', format_header_main)
    // lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, '(ТФОМС (иногородние)', format_header_main)
    // lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, hb_StrToUtf8(string_selected_uch(st_a_uch, lcount_uch)), format_header_main)
    // if len(st_a_uch) == 1
    //   lxw_worksheet_merge_range(worksheetError, iRow, 0, iRow++, 9, hb_StrToUtf8(string_selected_otd(st_a_otd, lcount_otd)), format_header_main)
    // endif
      
    lxw_worksheet_write_string(worksheetError, iRow, 0, '№ п/п', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 1, 'Шифр', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 2, 'Наименование услуги', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 3, 'Номер заявки', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 4, 'ФИО', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 5, 'Кол-во услуг', format_header)
    lxw_worksheet_write_string(worksheetError, iRow, 6, 'Стоимость услуг', format_header)

    /* Установить ширину колонок */
    lxw_worksheet_set_column(worksheetError, 0, 0, 8.0)
    lxw_worksheet_set_column(worksheetError, 1, 1, 8.0)
    lxw_worksheet_set_column(worksheetError, 2, 2, 50.0)
    lxw_worksheet_set_column(worksheetError, 3, 3, 10.0)
    lxw_worksheet_set_column(worksheetError, 4, 4, 50.0)
    lxw_worksheet_set_column(worksheetError, 5, 5, 8.0)
    lxw_worksheet_set_column(worksheetError, 6, 6, 25.0)

    iRow++
    do while ! FRD->(eof())
      lxw_worksheet_write_string(worksheetError, iRow, 0, hb_StrToUtf8( alltrim(FRD->NUM_USL) ), format_text)
      lxw_worksheet_write_string(worksheetError, iRow, 1, hb_StrToUtf8( alltrim(FRD->SHIFR_USL) ), format_text)
      lxw_worksheet_write_string(worksheetError, iRow, 2, hb_StrToUtf8( alltrim(FRD->NAME_USL) ), format_text)
      if FRD->NUMORDER != 0
        lxw_worksheet_write_number(worksheetError, iRow, 3, FRD->NUMORDER, format_text3)
      endif
      lxw_worksheet_write_string(worksheetError, iRow, 4, hb_StrToUtf8( alltrim(FRD->FIO) ), format_text)
      lxw_worksheet_write_number(worksheetError, iRow, 5, FRD->KOL_USL, format_text3)
      lxw_worksheet_write_number(worksheetError, iRow, 6, FRD->SUM_SN, format_text3)

      // lxw_worksheet_write_string(worksheetError, iRow, 1, hb_StrToUtf8( alltrim(FRD->REFREASON) ), format_text)
      // lxw_worksheet_write_string(worksheetError, iRow, 6, hb_StrToUtf8( alltrim(FRD->DATE_R) ), format_text)
      // lxw_worksheet_write_string(worksheetError, iRow, 9, hb_StrToUtf8( alltrim(FRD->OTD) ), format_text)

      ++iRow
      FRD->(dbSkip())
    end
    frd->(dbCloseArea())
    hb_vfErase(cur_dir + 'tmp_err' + sdbf)
  endif

  /* Закрыть книгу, записать файл и освободить память. */
  error = lxw_workbook_close(workbook)
  /* Проверить наличие ошибки при создании xlsx файла. */
  if !EMPTY(error)
    alertx(hb_Utf8ToStr(sprintf('Ошибка в workbook_close().\n' + ;
               'Ошибка %d = %s\n', error, HB_NTOS(error)), 'RU866'), 'error')
  endif
  return nil