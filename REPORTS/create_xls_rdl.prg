#include 'inkey.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'hbxlsxwriter.ch'

// 16.09.23
function create_xls_rdl(name, arr_m, st_a_uch, lcount_uch, st_a_otd, lcount_otd)
  local workbook, worksheet, format_top1, format_top2
  local worksheetError
  local format_header_main
  local format_header, format_header2
  local format_text, format_text2, format_text3, format_text_center
  local error
  local name_file := name + '.xlsx'
  local iRow := 1
  local tmpAlias

  tmpAlias := select()

  /* Создадим новую книгу. */
  workbook   = WORKBOOK_NEW(name_file)

  /* Конфигурируем формат для шапки. */
  format_header_main    = WORKBOOK_ADD_FORMAT(workbook)
  FORMAT_SET_ALIGN(format_header_main, LXW_ALIGN_CENTER)
  FORMAT_SET_ALIGN(format_header_main, LXW_ALIGN_VERTICAL_CENTER)
  FORMAT_SET_FONT_SIZE(format_header_main, 14)

  format_header    = WORKBOOK_ADD_FORMAT(workbook)
  FORMAT_SET_ALIGN(format_header, LXW_ALIGN_CENTER)
  FORMAT_SET_ALIGN(format_header, LXW_ALIGN_VERTICAL_CENTER)
  FORMAT_SET_FONT_SIZE(format_header, 12)
  FORMAT_SET_TEXT_WRAP(format_header)
  FORMAT_SET_BORDER(format_header, LXW_BORDER_THIN)

  /* Конфигурируем формат для ntrcnf. */
  format_text    = WORKBOOK_ADD_FORMAT(workbook)
  FORMAT_SET_ALIGN(format_text, LXW_ALIGN_LEFT)
  FORMAT_SET_ALIGN(format_text, LXW_ALIGN_VERTICAL_CENTER)
  FORMAT_SET_FONT_SIZE(format_text, 11)
  FORMAT_SET_TEXT_WRAP(format_text)
  FORMAT_SET_BORDER(format_text, LXW_BORDER_THIN)

  format_text3    = WORKBOOK_ADD_FORMAT(workbook)
  FORMAT_SET_ALIGN(format_text3, LXW_ALIGN_VERTICAL_CENTER)
  FORMAT_SET_FONT_SIZE(format_text3, 11)
  FORMAT_SET_BORDER(format_text3, LXW_BORDER_THIN)

  format_text_center    = WORKBOOK_ADD_FORMAT(workbook)
  FORMAT_SET_ALIGN(format_text_center, LXW_ALIGN_CENTER)
  FORMAT_SET_ALIGN(format_text_center, LXW_ALIGN_VERTICAL_CENTER)
  FORMAT_SET_FONT_SIZE(format_text_center, 11)
  FORMAT_SET_TEXT_WRAP(format_text_center)
  FORMAT_SET_BORDER(format_text_center, LXW_BORDER_THIN)

  if hb_FileExists(cur_dir + 'tmp_xls' + sdbf)
    /* Добавим лист в книгу. */
    worksheet = WORKBOOK_ADD_WORKSHEET(workbook, 'План-заказ')

    /* Установить ширину колонок */
    WORKSHEET_SET_COLUMN(worksheet, 0, 0, 3.0)
  
    WORKSHEET_SET_COLUMN(worksheet, 1, 1, 8.0)
    WORKSHEET_SET_COLUMN(worksheet, 2, 2, 8.0)
    WORKSHEET_SET_COLUMN(worksheet, 3, 3, 9.86)
    WORKSHEET_SET_COLUMN(worksheet, 4, 4, 3.0)
    WORKSHEET_SET_COLUMN(worksheet, 5, 5, 5.43)
    WORKSHEET_SET_COLUMN(worksheet, 6, 6, 3.0)
    WORKSHEET_SET_COLUMN(worksheet, 7, 7, 7.14)

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

      WORKSHEET_SET_ROW(worksheet, iRow, 30.0)

      WORKSHEET_WRITE_STRING(worksheet, iRow, 0, hb_StrToUtf8( alltrim(FRD->SHIFR) ), format_text)
      WORKSHEET_WRITE_STRING(worksheet, iRow, 1, hb_StrToUtf8( alltrim(FRD->U_NAME) ), format_text)
      WORKSHEET_WRITE_NUMBER(worksheet, iRow, 2, FRD->KOL, format_text3)
      WORKSHEET_WRITE_NUMBER(worksheet, iRow, 3, FRD->SUM, format_text3)

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
    worksheetError = WORKBOOK_ADD_WORKSHEET(workbook, 'Снятия')

    iRow := 0
    // шапка таблицы
    WORKSHEET_MERGE_RANGE(worksheetError, iRow, 0, iRow++, 9, 'Список снятий по актам контроля', format_header_main)
    WORKSHEET_MERGE_RANGE(worksheetError, iRow, 0, iRow++, 9, hb_StrToUtf8( alltrim(arr_m[4]) ), format_header_main)  // вывод временного периода
    WORKSHEET_MERGE_RANGE(worksheetError, iRow, 0, iRow++, 9, '( по дате отчётного периода / все случаи снятия )', format_header_main)
    WORKSHEET_MERGE_RANGE(worksheetError, iRow, 0, iRow++, 9, '(ТФОМС (иногородние)', format_header_main)
    WORKSHEET_MERGE_RANGE(worksheetError, iRow, 0, iRow++, 9, hb_StrToUtf8(string_selected_uch(st_a_uch, lcount_uch)), format_header_main)
    if len(st_a_uch) == 1
      WORKSHEET_MERGE_RANGE(worksheetError, iRow, 0, iRow++, 9, hb_StrToUtf8(string_selected_otd(st_a_otd, lcount_otd)), format_header_main)
    endif
      
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 0, '№ п/п', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 1, 'ОШИБКА', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 2, 'КОД', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 3, 'Наименование', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 4, 'Номер заявки', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 5, 'ФИО', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 6, 'Дата рождения', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 7, 'Кол-во услуг', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 8, 'Стоимость услуг', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 9, 'Отделение', format_header)

    /* Установить ширину колонок */
    WORKSHEET_SET_COLUMN(worksheetError, 0, 0, 8.0)
    WORKSHEET_SET_COLUMN(worksheetError, 1, 1, 10.0)
    WORKSHEET_SET_COLUMN(worksheetError, 2, 2, 8.0)
    WORKSHEET_SET_COLUMN(worksheetError, 3, 3, 50.0)
    WORKSHEET_SET_COLUMN(worksheetError, 4, 4, 8.0)
    WORKSHEET_SET_COLUMN(worksheetError, 5, 5, 25.0)
    WORKSHEET_SET_COLUMN(worksheetError, 6, 6, 12.0)
    WORKSHEET_SET_COLUMN(worksheetError, 7, 7, 7.14)
    WORKSHEET_SET_COLUMN(worksheetError, 8, 8, 12.0)
    WORKSHEET_SET_COLUMN(worksheetError, 9, 9, 12.0)
    WORKSHEET_SET_COLUMN(worksheetError, 10, 10, 7.14)

    iRow++
    do while ! FRD->(eof())
      WORKSHEET_WRITE_STRING(worksheetError, iRow, 0, hb_StrToUtf8( alltrim(FRD->NUM_USL) ), format_text)
      WORKSHEET_WRITE_STRING(worksheetError, iRow, 1, hb_StrToUtf8( alltrim(FRD->REFREASON) ), format_text)
      WORKSHEET_WRITE_STRING(worksheetError, iRow, 2, hb_StrToUtf8( alltrim(FRD->SHIFR_USL) ), format_text)
      WORKSHEET_WRITE_STRING(worksheetError, iRow, 3, hb_StrToUtf8( alltrim(FRD->NAME_USL) ), format_text)
      if FRD->NUMORDER != 0
        WORKSHEET_WRITE_NUMBER(worksheetError, iRow, 4, FRD->NUMORDER, format_text3)
      endif
      WORKSHEET_WRITE_STRING(worksheetError, iRow, 5, hb_StrToUtf8( alltrim(FRD->FIO) ), format_text)
      WORKSHEET_WRITE_STRING(worksheetError, iRow, 6, hb_StrToUtf8( alltrim(FRD->DATE_R) ), format_text)
      WORKSHEET_WRITE_NUMBER(worksheetError, iRow, 7, FRD->KOL_USL, format_text3)
      WORKSHEET_WRITE_NUMBER(worksheetError, iRow, 8, FRD->SUM_SN, format_text3)
      WORKSHEET_WRITE_STRING(worksheetError, iRow, 9, hb_StrToUtf8( alltrim(FRD->OTD) ), format_text)

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
    worksheetError = WORKBOOK_ADD_WORKSHEET(workbook, 'Ошибки из ТФОМС')

    iRow := 0
      
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 0, '№ п/п', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 1, 'Шифр', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 2, 'Наименование услуги', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 3, 'Номер заявки', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 4, 'ФИО', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 5, 'Кол-во услуг', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 6, 'Стоимость услуг', format_header)
    WORKSHEET_WRITE_STRING(worksheetError, iRow, 7, 'Направившая МО', format_header)

    /* Установить ширину колонок */
    WORKSHEET_SET_COLUMN(worksheetError, 0, 0, 8.0)
    WORKSHEET_SET_COLUMN(worksheetError, 1, 1, 8.0)
    WORKSHEET_SET_COLUMN(worksheetError, 2, 2, 50.0)
    WORKSHEET_SET_COLUMN(worksheetError, 3, 3, 10.0)
    WORKSHEET_SET_COLUMN(worksheetError, 4, 4, 50.0)
    WORKSHEET_SET_COLUMN(worksheetError, 5, 5, 8.0)
    WORKSHEET_SET_COLUMN(worksheetError, 6, 6, 25.0)
    WORKSHEET_SET_COLUMN(worksheetError, 7, 7, 20.0)

    iRow++
    do while ! FRD->(eof())
      if (FRD->NUMORDER != 0) .or. (FRD->KOL_USL != 0)
        WORKSHEET_WRITE_STRING(worksheetError, iRow, 0, hb_StrToUtf8(alltrim(FRD->NUM_USL)), format_text)
        WORKSHEET_WRITE_STRING(worksheetError, iRow, 1, hb_StrToUtf8(alltrim(FRD->SHIFR_USL)), format_text)
        WORKSHEET_WRITE_STRING(worksheetError, iRow, 2, hb_StrToUtf8(alltrim(FRD->NAME_USL)), format_text)

        if (FRD->NUMORDER != 0)
          WORKSHEET_WRITE_NUMBER(worksheetError, iRow, 3, FRD->NUMORDER, format_text3)
        else
          WORKSHEET_WRITE_STRING(worksheetError, iRow, 3, '', format_text)
        endif
      endif
      WORKSHEET_WRITE_STRING(worksheetError, iRow, 4, hb_StrToUtf8( alltrim(FRD->FIO) ), format_text)
      if FRD->KOL_USL != 0
        WORKSHEET_WRITE_NUMBER(worksheetError, iRow, 5, FRD->KOL_USL, format_text3)
      endif
      if FRD->cena_1 != 0
        WORKSHEET_WRITE_NUMBER(worksheetError, iRow, 6, FRD->CENA_1, format_text3)
      endif
      if !empty(FRD->napr_uch)
        WORKSHEET_WRITE_STRING(worksheetError, iRow, 7, FRD->napr_uch, format_text_center)
      endif
      
      ++iRow
      FRD->(dbSkip())
    end
    frd->(dbCloseArea())
    hb_vfErase(cur_dir + 'tmp_err' + sdbf)
  endif

  /* Закрыть книгу, записать файл и освободить память. */
  error = WORKBOOK_CLOSE(workbook)
  /* Проверить наличие ошибки при создании xlsx файла. */
  if !EMPTY(error)
    alertx(hb_Utf8ToStr(sprintf('Ошибка в workbook_close().\n' + ;
               'Ошибка %d = %s\n', error, HB_NTOS(error)), 'RU866'), 'error')
  endif
  select(tmpAlias)

  return nil