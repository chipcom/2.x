#include 'inkey.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'hblibxlsxwriter.ch'

function create_xls_rdl(name)
  local workbook, worksheet, format_top1, format_top2
  local format_header, format_header2
  local format_text, format_text2, format_text3
  local error
  local name_file := name + '.xlsx'
  local iRow := 1

  lxw_init() 
    
  /* Создадим новую книгу. */
  workbook   = lxw_workbook_new(name_file)

  /* Добавим лист в книгу. */
  worksheet = lxw_workbook_add_worksheet(workbook, 'План-заказ')

  /* Конфигурируем формат для ntrcnf. */
  format_text    = lxw_workbook_add_format(workbook)
  lxw_format_set_align(format_text, LXW_ALIGN_LEFT)
  lxw_format_set_align(format_text, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(format_text, 7)
  lxw_format_set_text_wrap(format_text)
  lxw_format_set_border(format_text, LXW_BORDER_THIN)

  format_text3    = lxw_workbook_add_format(workbook)
  // lxw_format_set_align(format_text3, LXW_ALIGN_CENTER)
  lxw_format_set_align(format_text3, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(format_text3, 7)
  // lxw_format_set_text_wrap(format_text3)
  lxw_format_set_border(format_text3, LXW_BORDER_THIN)

  /* Установить ширину колонок */
  lxw_worksheet_set_column(worksheet, 0, 0, 3.0)
  
  lxw_worksheet_set_column(worksheet, 1, 1, 8.0)
  lxw_worksheet_set_column(worksheet, 2, 2, 8.0)
  lxw_worksheet_set_column(worksheet, 3, 3, 9.86)
  lxw_worksheet_set_column(worksheet, 4, 4, 3.0)
  lxw_worksheet_set_column(worksheet, 5, 5, 5.43)
  lxw_worksheet_set_column(worksheet, 6, 6, 3.0)
  lxw_worksheet_set_column(worksheet, 7, 7, 7.14)

//   adbf := {{"kod","N",4,0},;
//     {"kod1","N",4,0},;
//     {"shifr","C",10,0},;
//     {"u_name","C",255,0},;
//     {"kol","N",7,0},;
//     {"kol1","N",7,0},;
//     {"uet","N",11,4},;
//     {"sum","N",13,2}}
  use (cur_dir + "tmp_xls") new  alias FRD
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

  /* Закрыть книгу, записать файл и освободить память. */
  error = lxw_workbook_close(workbook)
  /* Проверить наличие ошибки при создании xlsx файла. */
  if !EMPTY(error)
    alertx(hb_Utf8ToStr(sprintf('Ошибка в workbook_close().\n' + ;
               'Ошибка %d = %s\n', error, HB_NTOS(error)),'RU866'),'error')
  endif

  return nil
