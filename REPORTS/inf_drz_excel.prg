#include 'inkey.ch'
#include 'common.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'hbxlsxwriter.ch'

// 17.04.24 Итоги за период времени по диспансеризации репродуктивного здоровья МИАЦ
Function inf_drz_excel( file_name, arr_m, arr )
  local workbook, worksheet
  local merge_format, form_text_header, form_text_header_1, form_text_X, cell_format_plan
  local cell_format, cell_format_itog, cell_format_man, cell_format_woman, cell_format_full
  local merge_format_head, form_text_date_text, form_text_footer, form_text_footer_1
  local form_text_date, form_plan_gorod, form_plan_selo
//  Local buf := save_maxrow()
  local strMO := hb_StrToUtf8( glob_mo[ _MO_SHORT_NAME ] )
  local arr_plan := get_array_plan_drz( year( arr_m[ 6 ] ), glob_mo[ _MO_KOD_FFOMS ] )

  if ! isnil( arr_m )
    workbook  := WORKBOOK_NEW( file_name )
    worksheet := WORKBOOK_ADD_WORKSHEET(workbook, 'Табл_1' )

    /* Установить высоту строки */
    WORKSHEET_SET_ROW( worksheet, 0, 39.8 )
    WORKSHEET_SET_ROW( worksheet, 1, 13.5 )
    WORKSHEET_SET_ROW( worksheet, 2, 21.0 )
    WORKSHEET_SET_ROW( worksheet, 3, 15.8 )
    WORKSHEET_SET_ROW( worksheet, 4, 20.3 )
    WORKSHEET_SET_ROW( worksheet, 5, 20.3 )
    WORKSHEET_SET_ROW( worksheet, 6, 20.3 )
    WORKSHEET_SET_ROW( worksheet, 7, 42.8 )
    WORKSHEET_SET_ROW( worksheet, 8, 182.3 )
    WORKSHEET_SET_ROW( worksheet, 9, 18.8 )

    /* Установить ширину колонок */
    WORKSHEET_SET_COLUMN( worksheet, 0, 0, 6.22 )
    WORKSHEET_SET_COLUMN( worksheet, 1, 1, 32.78 )
    WORKSHEET_SET_COLUMN( worksheet, 2, 2, 16.11 )
    WORKSHEET_SET_COLUMN( worksheet, 3, 3, 13.89 )
    WORKSHEET_SET_COLUMN( worksheet, 4, 4, 13.56 )
    WORKSHEET_SET_COLUMN( worksheet, 5, 5, 13.56 )
    WORKSHEET_SET_COLUMN( worksheet, 6, 6, 13.56 )
    WORKSHEET_SET_COLUMN( worksheet, 7, 7, 18.11 )
    WORKSHEET_SET_COLUMN( worksheet, 8, 8, 19.89 )
    WORKSHEET_SET_COLUMN( worksheet, 9, 9, 15.33 )
    WORKSHEET_SET_COLUMN( worksheet, 10, 10, 14.56 )
    WORKSHEET_SET_COLUMN( worksheet, 11, 11, 22.11 )
    WORKSHEET_SET_COLUMN( worksheet, 12, 12, 19.78 )
    WORKSHEET_SET_COLUMN( worksheet, 13, 13, 19.78 )
    WORKSHEET_SET_COLUMN( worksheet, 14, 14, 18.56 )

    merge_format_head := fmt_excel_hC_vC_wrap( workbook ) // WORKBOOK_ADD_FORMAT( workbook )
    /* Конфигурируем формат для объединенных ячеек. */
    FORMAT_SET_BOLD( merge_format_head )
    FORMAT_SET_FONT_SIZE( merge_format_head, 14 )
//    FORMAT_SET_BG_COLOR( merge_format_head, 0xffffea )
    FORMAT_SET_BORDER( merge_format_head, LXW_BORDER_THIN )

    merge_format := fmt_excel_hC_vC_wrap( workbook ) // WORKBOOK_ADD_FORMAT( workbook )
    /* Конфигурируем формат для объединенных ячеек. */
    FORMAT_SET_BOLD( merge_format )
    FORMAT_SET_FONT_SIZE( merge_format, 14 )
    FORMAT_SET_BG_COLOR( merge_format, 0xffffea )
    FORMAT_SET_BORDER( merge_format, LXW_BORDER_THIN )

    form_text_header := fmt_excel_hC_vC_wrap( workbook )
    FORMAT_SET_FONT_SIZE( form_text_header, 12 )
    FORMAT_SET_BG_COLOR( form_text_header, 0xcdcdcd )
    FORMAT_SET_BORDER( form_text_header, LXW_BORDER_THIN )

    form_text_header_1 := fmt_excel_hC_vC_wrap( workbook )
    FORMAT_SET_FONT_SIZE( form_text_header_1, 12 )
    FORMAT_SET_BOLD( form_text_header_1 )
    FORMAT_SET_BORDER( form_text_header_1, LXW_BORDER_THIN )

    form_text_footer := fmt_excel_hC_vC_wrap( workbook )
    FORMAT_SET_FONT_SIZE( form_text_footer, 11 )
    FORMAT_SET_BG_COLOR( form_text_footer, 0xffffea )
    FORMAT_SET_BORDER( form_text_footer, LXW_BORDER_THIN )

    form_text_footer_1 := workbook_add_format( workbook )
    FORMAT_SET_FONT_SIZE( form_text_footer_1, 14 )
    FORMAT_SET_BOLD( form_text_footer_1 )

    form_text_X := fmt_excel_hC_vC( workbook )
    FORMAT_SET_FONT_SIZE( form_text_X, 12 )
    FORMAT_SET_BG_COLOR( form_text_x, 0xcdcdcd )
    FORMAT_SET_BORDER( form_text_X, LXW_BORDER_THIN )

    cell_format := fmt_excel_hC_vC_wrap( workbook )
    FORMAT_SET_FONT_SIZE( cell_format, 14 )
    FORMAT_SET_BG_COLOR( cell_format, 0xffffea )
    FORMAT_SET_BORDER( cell_format, LXW_BORDER_THIN )

    cell_format_itog := fmt_excel_hC_vC_wrap( workbook )
    FORMAT_SET_FONT_SIZE( cell_format_itog, 14 )
    FORMAT_SET_BOLD( cell_format_itog )
    FORMAT_SET_BG_COLOR( cell_format_itog, 0xcdcdcd )
    FORMAT_SET_BORDER( cell_format_itog, LXW_BORDER_THIN )

    cell_format_plan := fmt_excel_hC_vC_wrap( workbook )
    FORMAT_SET_FONT_SIZE( cell_format_plan, 14 )
    FORMAT_SET_BG_COLOR( cell_format_plan, 0xcdcdcd )
    FORMAT_SET_BORDER( cell_format_plan, LXW_BORDER_THIN )

    cell_format_man := fmt_excel_hC_vC_wrap( workbook )
    FORMAT_SET_FONT_SIZE( cell_format_man, 12 )
//    FORMAT_SET_BOLD( cell_format_man )
    FORMAT_SET_BG_COLOR( cell_format_man, 0xdae6f1 )
    FORMAT_SET_BORDER( cell_format_man, LXW_BORDER_THIN )

    cell_format_woman := fmt_excel_hC_vC_wrap( workbook )
    FORMAT_SET_FONT_SIZE( cell_format_woman, 12 )
//    FORMAT_SET_BOLD( cell_format_woman )
    FORMAT_SET_BG_COLOR( cell_format_woman, 0xf1dddd )
    FORMAT_SET_BORDER( cell_format_woman, LXW_BORDER_THIN )

    cell_format_full := fmt_excel_hC_vC_wrap( workbook )
    FORMAT_SET_FONT_SIZE( cell_format_full, 12 )
    FORMAT_SET_BOLD( cell_format_full )
    FORMAT_SET_BG_COLOR( cell_format_full, 0xeeeee2 )
    FORMAT_SET_BORDER( cell_format_full, LXW_BORDER_THIN )

    form_text_date := fmt_excel_hC_vC( workbook )
    FORMAT_SET_FONT_SIZE( form_text_date, 14 )
    FORMAT_SET_BG_COLOR( form_text_date, 0xffffea )
    FORMAT_SET_BORDER( form_text_date, LXW_BORDER_THIN )

    form_text_date_text := fmt_excel_hC_vC( workbook )
    FORMAT_SET_FONT_SIZE( form_text_date_text, 12 )

    form_plan_gorod := fmt_excel_hC_vC( workbook )
    FORMAT_SET_FONT_SIZE( form_plan_gorod, 14 )
    FORMAT_SET_BOLD( form_plan_gorod )
    FORMAT_SET_BG_COLOR( form_plan_gorod, 0xcdcdcd )
    FORMAT_SET_BORDER( form_plan_gorod, LXW_BORDER_THIN )

    form_plan_selo := fmt_excel_hC_vC( workbook )
    FORMAT_SET_FONT_SIZE( form_plan_selo, 14 )
    FORMAT_SET_BG_COLOR( form_plan_selo, 0xffffea )
    FORMAT_SET_BORDER( form_plan_selo, LXW_BORDER_THIN )

    /* Объединить 15 колонок одной строки. */
    WORKSHEET_MERGE_RANGE( worksheet, 0, 0, 0, 14, 'Диспансеризация определенных групп взрослого населения, подлежащих проведению диспансеризации, направленной на оценку репродуктивного здоровья (приказ Комитета здравоохранения Волгоградской области № 649 от 15.03.2024г.)', merge_format_head )
    WORKSHEET_MERGE_RANGE( worksheet, 2, 1, 2, 2, 'Наименование медицинской организации', merge_format )
    WORKSHEET_MERGE_RANGE( worksheet, 2, 3, 2, 7, strMO, merge_format )

    WORKSHEET_WRITE_STRING( worksheet, 4, 3, str( day( arr_m[ 6 ] ), 2 ), form_text_date )
    WORKSHEET_WRITE_STRING( worksheet, 4, 4, hb_StrToUtf8( CMonth( arr_m[ 6 ] ) ), form_text_date )
    WORKSHEET_WRITE_STRING( worksheet, 4, 5, str( year( arr_m[ 6 ] ), 4 ), form_text_date )

    WORKSHEET_WRITE_STRING( worksheet, 5, 3, 'число', form_text_date_text )
    WORKSHEET_WRITE_STRING( worksheet, 5, 4, 'месяц', form_text_date_text )
    WORKSHEET_WRITE_STRING( worksheet, 5, 5, 'год', form_text_date_text )

    WORKSHEET_MERGE_RANGE( worksheet, 7, 0, 8, 0, '№ строки', form_text_header )
    WORKSHEET_MERGE_RANGE( worksheet, 7, 1, 8, 1, 'Категории лиц, подлежащих осмотру', form_text_header )
    WORKSHEET_MERGE_RANGE( worksheet, 7, 2, 8, 2, 'Подлежит осмотрам, чел.', form_text_header )
    WORKSHEET_MERGE_RANGE( worksheet, 7, 3, 8, 3, 'Прошли 1 этап, чел.', form_text_header )
    WORKSHEET_MERGE_RANGE( worksheet, 7, 4, 7, 6, 'По результатам обследования определены группы здоровья', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 8, 4, '1 группа', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 8, 5, '2 группа', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 8, 6, '3 группа', form_text_header )
    WORKSHEET_MERGE_RANGE( worksheet, 7, 7, 8, 7, 'Направлено на 2 этап для проведения дополнительных обследований и уточнения диагноза  (число лиц с выявленными патологическими состояниями), чел.', form_text_header )
    WORKSHEET_MERGE_RANGE( worksheet, 7, 8, 7, 12, 'из них (гр.5)  патологические состояния выявлены  при оказании медицинских услуг (следует указать все патологические состояния, выявленные у пациента)', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 8, 8, 'прием (осмотр) врачом акушером-гинекологом первичный, включая  пальпацию молочных желез и осмотр шейки матки в зеркалах с забором материала на исследование', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 8, 9, 'микроскопическое исследование влагалищных мазков', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 8, 10, 'цитологическое исследование мазка (соскоба) с шейки матки с окрашиванием по Папаниколау', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 8, 11, 'у женщин в возрасте 18 - 29 лет проведение лабораторных исследований мазков в целях выявления возбудителей инфекционных заболеваний органов малого таза методом полимеразной цепной реакции', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 8, 12, 'прием (осмотр) врачом-урологом (при его отсутствии врачом-хирургом, прошедшим подготовку по вопросам репродуктивного здоровья у мужчин)', form_text_header )
    WORKSHEET_MERGE_RANGE( worksheet, 7, 13, 8, 13, 'Направлено на лечение после проведения дополнительных обследований и уточнения диагноза, чел.', form_text_header )
    WORKSHEET_MERGE_RANGE( worksheet, 7, 14, 8, 14, 'Пролечено из числа направленных, чел.', form_text_header )

    WORKSHEET_WRITE_STRING( worksheet, 9, 0, '1', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 1, '2', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 2, '3', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 3, '4', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 4, '4.1', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 5, '4.2', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 6, '4.3', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 7, '5', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 8, '5.1', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 9, '5.2', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 10, '5.3', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 11, '5.4', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 12, '5.5', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 13, '6', form_text_header )
    WORKSHEET_WRITE_STRING( worksheet, 9, 14, '7', form_text_header )

    WORKSHEET_SET_ROW( worksheet, 10, 39.8 )
    WORKSHEET_WRITE_STRING( worksheet, 10, 0, '1', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 10, 1, 'число мужчин в возрасте 18-49 лет  - всего', cell_format_man )
    WORKSHEET_WRITE_STRING( worksheet, 10, 2, iif( len( arr_plan ) > 0, alltrim( str( arr_plan[ 1 ] ) ), '' ), form_plan_gorod )
    
    worksheet_write_formula( worksheet, 10, 3, '=SUM(E11:G11)', cell_format_plan )

    WORKSHEET_WRITE_NUMBER( worksheet, 10, 4, arr[ 1, 1 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 10, 5, arr[ 1, 2 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 10, 6, arr[ 1, 3 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 10, 7, arr[ 1, 4 ], cell_format )

    WORKSHEET_WRITE_STRING( worksheet, 10, 8, 'X', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 10, 9, 'X', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 10, 10, 'X', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 10, 11, 'X', form_text_X )

    worksheet_write_formula( worksheet, 10, 12, '=H11', cell_format_plan )

    WORKSHEET_WRITE_NUMBER( worksheet, 10, 13, arr[ 1, 9 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 10, 14, arr[ 1, 10 ], cell_format )

    WORKSHEET_SET_ROW( worksheet, 11, 39.8 )
    WORKSHEET_WRITE_STRING( worksheet, 11, 0, '2', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 11, 1, 'в том числе сельских жителей', cell_format_man )
    WORKSHEET_WRITE_STRING( worksheet, 11, 2, '', form_plan_selo )

    worksheet_write_formula( worksheet, 11, 3, '=SUM(E12:G12)', cell_format_plan )
    WORKSHEET_WRITE_NUMBER( worksheet, 11, 4, arr[ 2, 1 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 11, 5, arr[ 2, 2 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 11, 6, arr[ 2, 3 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 11, 7, arr[ 2, 4 ], cell_format )

    WORKSHEET_WRITE_STRING( worksheet, 11, 8, 'X', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 11, 9, 'X', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 11, 10, 'X', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 11, 11, 'X', form_text_X )

    worksheet_write_formula( worksheet, 11, 12, '=H12', cell_format_plan )

    WORKSHEET_WRITE_NUMBER( worksheet, 11, 13, arr[ 2, 9 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 11, 14, arr[ 2, 10 ], cell_format )

    WORKSHEET_SET_ROW( worksheet, 12, 39.8 )
    WORKSHEET_WRITE_STRING( worksheet, 12, 0, '3', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 12, 1, 'число женщин в возрасте 18-49 лет  - всего', cell_format_woman )
    WORKSHEET_WRITE_STRING( worksheet, 12, 2, iif( len( arr_plan ) > 0, alltrim( str( arr_plan[ 2 ] ) ), '' ), form_plan_gorod )

    worksheet_write_formula( worksheet, 12, 3, '=SUM(E13:G13)', cell_format_plan )
    WORKSHEET_WRITE_NUMBER( worksheet, 12, 4, arr[ 3, 1 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 12, 5, arr[ 3, 2 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 12, 6, arr[ 3, 3 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 12, 7, arr[ 3, 4 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 12, 8, arr[ 3, 5 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 12, 9, arr[ 3, 6 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 12, 10, arr[ 3, 7 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 12, 11, arr[ 3, 8 ], cell_format )

    WORKSHEET_WRITE_STRING( worksheet, 12, 12, 'X', form_text_X )

    WORKSHEET_WRITE_NUMBER( worksheet, 12, 13, arr[ 3, 9 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 12, 14, arr[ 3, 10 ], cell_format )

    WORKSHEET_SET_ROW( worksheet, 13, 39.8 )
    WORKSHEET_WRITE_STRING( worksheet, 13, 0, '4', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 13, 1, 'в том числе сельских жителей', cell_format_woman )
    WORKSHEET_WRITE_STRING( worksheet, 13, 2, '', form_plan_selo )

    worksheet_write_formula( worksheet, 13, 3, '=SUM(E14:G14)', cell_format_plan )
    WORKSHEET_WRITE_NUMBER( worksheet, 13, 4, arr[ 4, 1 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 13, 5, arr[ 4, 2 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 13, 6, arr[ 4, 3 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 13, 7, arr[ 4, 4 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 13, 8, arr[ 4, 5 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 13, 9, arr[ 4, 6 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 13, 10, arr[ 4, 7 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 13, 11, arr[ 4, 8 ], cell_format )

    WORKSHEET_WRITE_STRING( worksheet, 13, 12, 'X', form_text_X )

    WORKSHEET_WRITE_NUMBER( worksheet, 13, 13, arr[ 4, 9 ], cell_format )
    WORKSHEET_WRITE_NUMBER( worksheet, 13, 14, arr[ 4, 10 ], cell_format )

    WORKSHEET_SET_ROW( worksheet, 14, 39.8 )
    WORKSHEET_WRITE_STRING( worksheet, 14, 0, '5', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 14, 1, 'Общее число лиц в возрасте 18-49 лет', cell_format_full )

    worksheet_write_number( worksheet, 14, 2, 0, cell_format_itog )
    worksheet_write_formula( worksheet, 14, 3, '=D11+D13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 4, '=E11+E13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 5, '=F11+F13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 6, '=G11+G13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 7, '=H11+H13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 8, '=I13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 9, '=J13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 10, '=K13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 11, '=L13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 12, '=M11', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 13, '=N11+N13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 14, '=O11+O13', cell_format_itog )

    WORKSHEET_SET_ROW( worksheet, 15, 39.8 )
    WORKSHEET_WRITE_STRING( worksheet, 15, 0, '6', form_text_X )
    WORKSHEET_WRITE_STRING( worksheet, 15, 1, 'в том числе сельских жителей', cell_format_full )

    worksheet_write_formula( worksheet, 15, 2, '=C12+C14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 3, '=D12+D14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 4, '=E12+E14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 5, '=F12+F14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 6, '=G12+G14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 7, '=H12+H14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 8, '=I14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 9, '=J14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 10, '=K14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 11, '=L14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 12, '=M12', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 13, '=N12+N14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 14, '=O12+O14', cell_format_itog )
    
//  подвал    
    WORKSHEET_SET_ROW( worksheet, 19, 21 )
    WORKSHEET_WRITE_STRING( worksheet, 19, 1, 'ФИО главного врача', form_text_footer_1 )
    WORKSHEET_MERGE_RANGE( worksheet, 19, 2, 19, 6, '', form_text_footer )
    WORKSHEET_SET_ROW( worksheet, 20, 21 )
    WORKSHEET_WRITE_STRING( worksheet, 20, 1, 'ФИО исполнителя', form_text_footer_1 )
    WORKSHEET_MERGE_RANGE( worksheet, 20, 2, 20, 6, '', form_text_footer )
    WORKSHEET_SET_ROW( worksheet, 21, 21 )
    WORKSHEET_WRITE_STRING( worksheet, 21, 1, 'Номер телефона исполнителя', form_text_footer_1 )
    WORKSHEET_MERGE_RANGE( worksheet, 21, 2, 21, 6, '', form_text_footer )
    WORKBOOK_CLOSE( workbook )

  endif

  return nil

