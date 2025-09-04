#include 'inkey.ch'
#include 'common.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'hbxlsxwriter.ch'

Static lcount_uch  := 1

// 04.09.25 Итоги за период времени по диспансеризации репродуктивного здоровья МИАЦ
Function inf_drz_excel( file_name, arr_m, arr, arr_1, tcount_uch  )

  Local workbook, worksheet, ws2511, ws2517, wsFemale, wsMan   // , analiz
  Local merge_format, form_text_header, form_text_header_1, form_text_X, cell_format_plan
  Local cell_format, cell_format_itog, cell_format_man, cell_format_woman, cell_format_full
  Local merge_format_head, form_text_date_text, form_text_footer, form_text_footer_1
  Local form_text_date, form_plan_gorod, form_plan_selo, form_text_header_yellow
  Local merge_format2511, form_text2511, cell_format2511, cell_format2517, cell_format_bold2517
  Local cell_formula_2517
  Local tmpFormat, form_text_add, form_text_add1, form_text_add2

  Local currentOrg := hb_main_curOrg

  // local strMO := hb_StrToUtf8( glob_mo[ _MO_SHORT_NAME ] )
  Local strMO   // := hb_StrToUTF8( hb_main_curOrg:name_tfoms() )
  Local arr_plan // := get_plan_drz( Year( arr_m[ 6 ] ), glob_mo[ _MO_KOD_FFOMS ] )
  Local i

  strMO := hb_StrToUTF8( currentOrg:name_tfoms() )
  arr_plan := get_plan_drz( Year( arr_m[ 6 ] ), glob_mo[ _MO_KOD_FFOMS ] )
  //
  For i := 1 To 8
    arr_1[ 3, i ] := arr_1[ 2, i ] + arr_1[ 1, i ]
  Next
  lcount_uch :=  tcount_uch

  If ! ISNIL( arr_m )
    workbook  := workbook_new( file_name )
    worksheet := workbook_add_worksheet( workbook, 'Табл_1' )
    worksheet_set_tab_color( worksheet, 0x56ff21 )

    /* Установить высоту строки */
    worksheet_set_row( worksheet, 0, 39.8 )
    worksheet_set_row( worksheet, 1, 13.5 )
    worksheet_set_row( worksheet, 2, 21.0 )
    worksheet_set_row( worksheet, 3, 15.8 )
    worksheet_set_row( worksheet, 4, 20.3 )
    worksheet_set_row( worksheet, 5, 20.3 )
    worksheet_set_row( worksheet, 6, 20.3 )
    worksheet_set_row( worksheet, 7, 115.8 )
    worksheet_set_row( worksheet, 8, 240 )
    worksheet_set_row( worksheet, 9, 18.8 )

    /* Установить ширину колонок */
    worksheet_set_column( worksheet, 0, 0, 6.22 )
    worksheet_set_column( worksheet, 1, 1, 32.78 )
    worksheet_set_column( worksheet, 2, 2, 16.11 )
    worksheet_set_column( worksheet, 3, 3, 13.89 )
    worksheet_set_column( worksheet, 4, 4, 13.56 )
    worksheet_set_column( worksheet, 5, 5, 13.56 )
    worksheet_set_column( worksheet, 6, 6, 13.56 )

    For i := 7 To 24
      worksheet_set_column( worksheet, i, i, 18.56 )
    Next

    merge_format_head := fmt_excel_hc_vc_wrap( workbook ) // WORKBOOK_ADD_FORMAT( workbook )
    /* Конфигурируем формат для объединенных ячеек. */
    format_set_bold( merge_format_head )
    format_set_font_size( merge_format_head, 14 )
    format_set_border( merge_format_head, LXW_BORDER_THIN )

    merge_format := fmt_excel_hc_vc_wrap( workbook ) // WORKBOOK_ADD_FORMAT( workbook )
    /* Конфигурируем формат для объединенных ячеек. */
    format_set_bold( merge_format )
    format_set_font_size( merge_format, 14 )
    format_set_bg_color( merge_format, 0xffffea )
    format_set_border( merge_format, LXW_BORDER_THIN )

    form_text_header := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( form_text_header, 12 )
    format_set_bg_color( form_text_header, 0xcdcdcd )
    format_set_border( form_text_header, LXW_BORDER_THIN )

    form_text_header_yellow := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( form_text_header_yellow, 12 )
    format_set_bg_color( form_text_header_yellow, 0xffff00 )
    format_set_border( form_text_header_yellow, LXW_BORDER_THIN )

    form_text_header_1 := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( form_text_header_1, 12 )
    format_set_bold( form_text_header_1 )
    format_set_border( form_text_header_1, LXW_BORDER_THIN )

    form_text_footer := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( form_text_footer, 11 )
    format_set_bg_color( form_text_footer, 0xffffea )
    format_set_border( form_text_footer, LXW_BORDER_THIN )

    form_text_footer_1 := workbook_add_format( workbook )
    format_set_font_size( form_text_footer_1, 14 )
    format_set_bold( form_text_footer_1 )

    form_text_X := fmt_excel_hc_vc( workbook )
    format_set_font_size( form_text_X, 12 )
    format_set_bg_color( form_text_x, 0xcdcdcd )
    format_set_border( form_text_X, LXW_BORDER_THIN )

    cell_format := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( cell_format, 14 )
    format_set_bg_color( cell_format, 0xffffea )
    format_set_border( cell_format, LXW_BORDER_THIN )

    cell_format_itog := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( cell_format_itog, 14 )
    format_set_bold( cell_format_itog )
    format_set_bg_color( cell_format_itog, 0xcdcdcd )
    format_set_border( cell_format_itog, LXW_BORDER_THIN )

    cell_format_plan := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( cell_format_plan, 14 )
    format_set_bg_color( cell_format_plan, 0xcdcdcd )
    format_set_border( cell_format_plan, LXW_BORDER_THIN )

    cell_format_man := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( cell_format_man, 12 )
    format_set_bg_color( cell_format_man, 0xdae6f1 )
    format_set_border( cell_format_man, LXW_BORDER_THIN )

    cell_format_woman := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( cell_format_woman, 12 )
    format_set_bg_color( cell_format_woman, 0xf1dddd )
    format_set_border( cell_format_woman, LXW_BORDER_THIN )

    cell_format_full := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( cell_format_full, 12 )
    format_set_bold( cell_format_full )
    format_set_bg_color( cell_format_full, 0xeeeee2 )
    format_set_border( cell_format_full, LXW_BORDER_THIN )

    form_text_date := fmt_excel_hc_vc( workbook )
    format_set_font_size( form_text_date, 14 )
    format_set_bg_color( form_text_date, 0xffffea )
    format_set_border( form_text_date, LXW_BORDER_THIN )

    form_text_date_text := fmt_excel_hc_vc( workbook )
    format_set_font_size( form_text_date_text, 12 )

    form_plan_gorod := fmt_excel_hc_vc( workbook )
    format_set_font_size( form_plan_gorod, 14 )
    format_set_bold( form_plan_gorod )
    format_set_bg_color( form_plan_gorod, 0xcdcdcd )
    format_set_border( form_plan_gorod, LXW_BORDER_THIN )

    form_plan_selo := fmt_excel_hc_vc( workbook )
    format_set_font_size( form_plan_selo, 14 )
    format_set_bg_color( form_plan_selo, 0xffffea )
    format_set_border( form_plan_selo, LXW_BORDER_THIN )

    /* Объединить 15 колонок одной строки. */
    worksheet_merge_range( worksheet, 0, 0, 0, 24, 'Диспансеризация определенных групп взрослого населения, подлежащих проведению диспансеризации, направленной на оценку репродуктивного здоровья (приказ Комитета здравоохранения Волгоградской области № 649 от 15.03.2024г.)', merge_format_head )
    worksheet_merge_range( worksheet, 2, 1, 2, 2, 'Наименование медицинской организации', merge_format )
    worksheet_merge_range( worksheet, 2, 3, 2, 11, strMO, merge_format )

    worksheet_write_string( worksheet, 4, 3, Str( Day( arr_m[ 6 ] ), 2 ), form_text_date )
    worksheet_write_string( worksheet, 4, 4, hb_StrToUTF8( Lower( CMonth( arr_m[ 6 ] ) ) ), form_text_date )
    worksheet_write_string( worksheet, 4, 5, Str( Year( arr_m[ 6 ] ), 4 ), form_text_date )

    worksheet_write_string( worksheet, 5, 3, 'число', form_text_date_text )
    worksheet_write_string( worksheet, 5, 4, 'месяц', form_text_date_text )
    worksheet_write_string( worksheet, 5, 5, 'год', form_text_date_text )

    worksheet_merge_range( worksheet, 7, 0, 8, 0, '№ строки', form_text_header )
    worksheet_merge_range( worksheet, 7, 1, 8, 1, 'Категории лиц, подлежащих осмотру', form_text_header )
    worksheet_merge_range( worksheet, 7, 2, 8, 2, 'Подлежит осмотрам, чел.', form_text_header )
    worksheet_merge_range( worksheet, 7, 3, 8, 3, 'Прошли 1 этап, чел.', form_text_header )


    worksheet_merge_range( worksheet, 7, 4, 7, 7, 'Из прошедших 1 этап (гр.4)', form_text_header )
    worksheet_write_string( worksheet, 8, 4, 'прошли обследование в вечернее время', form_text_header )
    worksheet_write_string( worksheet, 8, 5, 'в субботу', form_text_header )
    worksheet_write_string( worksheet, 8, 6, 'с использованием мобильных бригад', form_text_header )
    worksheet_write_string( worksheet, 8, 7, 'с использованием мобильных комплексов', form_text_header )

    worksheet_merge_range( worksheet, 7, 8, 7, 10, 'По результатам обследования определены группы здоровья', form_text_header )
    worksheet_write_string( worksheet, 8, 8, '1 группа РЗ (код классификаторов 375)', form_text_header )
    worksheet_write_string( worksheet, 8, 9, '2 группа РЗ (код классификаторов 376 предварительный 378)', form_text_header )
    worksheet_write_string( worksheet, 8, 10, '3 группа РЗ (код классификаторов 377 предварительный 379)', form_text_header )

    worksheet_merge_range( worksheet, 7, 11, 8, 11, 'Выявлена патология - направлено на 2 этап (код классификаторов 378 и 379), чел.', form_text_header )

    worksheet_merge_range( worksheet, 7, 12, 7, 16, 'из них (гр.12) патологические состояния выявлены при оказании медицинских услуг (следует указать все патологические состояния, выявленные у пациента и относящиеся к одной из граф)', form_text_header )
    worksheet_write_string( worksheet, 8, 12, 'прием (осмотр) врачом акушером-гинекологом первичный, включая  пальпацию молочных желез и осмотр шейки матки в зеркалах с забором материала на исследование', form_text_header )
    worksheet_write_string( worksheet, 8, 13, 'микроскопическое исследование влагалищных мазков', form_text_header )
    worksheet_write_string( worksheet, 8, 14, 'цитологическое исследование мазка (соскоба) с шейки матки с окрашиванием по Папаниколау', form_text_header )
    worksheet_write_string( worksheet, 8, 15, 'у женщин в возрасте 18 - 29 лет проведение лабораторных исследований мазков в целях выявления возбудителей инфекционных заболеваний органов малого таза методом полимеразной цепной реакции', form_text_header )
    worksheet_write_string( worksheet, 8, 16, 'прием (осмотр) врачом-урологом (при его отсутствии врачом-хирургом, прошедшим подготовку по вопросам репродуктивного здоровья у мужчин)', form_text_header )

    worksheet_merge_range( worksheet, 7, 17, 8, 17, 'Прошли 2 этап', form_text_header )

    worksheet_merge_range( worksheet, 7, 18, 7, 20, 'Определены группы здоровья по результатам 2 этапа диспансеризации (тип диспансеризации - ДР2, результат обращения в соответсвии с кодом)', form_text_header )
    worksheet_write_string( worksheet, 8, 18, '1 группа РЗ (код классификаторов 375)', form_text_header )
    worksheet_write_string( worksheet, 8, 19, '2 группа РЗ (код классификаторов 376 предварительный 378)', form_text_header )
    worksheet_write_string( worksheet, 8, 20, '3 группа РЗ (код классификаторов 377 предварительный 379)', form_text_header )

    worksheet_merge_range( worksheet, 7, 21, 7, 22, 'Из числа прошедших диспансеризацию под диспансерным наблюдением (из графы 4)', form_text_header_yellow )
    worksheet_write_string( worksheet, 8, 21, 'Всего, чел.', form_text_header_yellow )
    worksheet_write_string( worksheet, 8, 22, 'из них: диспансерное наблюдение установлено впервые по результатам проведения диспансеризации', form_text_header_yellow )

    worksheet_merge_range( worksheet, 7, 23, 8, 23, 'Направлено на лечение после проведения дополнительных обследований и уточнения диагноза, чел. (из гр.18)', form_text_header )
    worksheet_merge_range( worksheet, 7, 24, 8, 24, 'Пролечено из числа направленных, чел. (из гр.22)', form_text_header )

    For i := 1 To 25
      tmpFormat := iif( i == 22 .or. i == 23, form_text_header_yellow, form_text_header )
      worksheet_write_string( worksheet, 9, i - 1, AllTrim( Str( i ) ), tmpFormat )
    Next

    worksheet_set_row( worksheet, 10, 39.8 )
    worksheet_write_string( worksheet, 10, 0, '1', form_text_X )
    worksheet_write_string( worksheet, 10, 1, 'число мужчин в возрасте 18-49 лет  - всего', cell_format_man )
    worksheet_write_string( worksheet, 10, 2, iif( Len( arr_plan ) > 0, AllTrim( Str( arr_plan[ 1 ] ) ), '' ), form_plan_gorod )

    worksheet_write_formula( worksheet, 10, 3, '=I11+J11+K11', cell_format_plan )
    worksheet_write_number( worksheet, 10, 4, arr[ 1, 11 ], cell_format )
    worksheet_write_number( worksheet, 10, 5, arr[ 1, 12 ], cell_format )
    worksheet_write_number( worksheet, 10, 6, arr[ 1, 13 ], cell_format )
    worksheet_write_number( worksheet, 10, 7, arr[ 1, 14 ], cell_format )

    worksheet_write_number( worksheet, 10, 8, arr[ 1, 1 ], cell_format )
    worksheet_write_number( worksheet, 10, 9, arr[ 1, 2 ], cell_format )
    worksheet_write_number( worksheet, 10, 10, arr[ 1, 3 ], cell_format )
    worksheet_write_number( worksheet, 10, 11, arr[ 1, 4 ], cell_format )
    worksheet_write_string( worksheet, 10, 12, 'X', form_text_X )
    worksheet_write_string( worksheet, 10, 13, 'X', form_text_X )
    worksheet_write_string( worksheet, 10, 14, 'X', form_text_X )
    worksheet_write_string( worksheet, 10, 15, 'X', form_text_X )
    worksheet_write_formula( worksheet, 10, 16, '=L11', cell_format_plan )

    worksheet_write_formula( worksheet, 10, 17, '=S11+T11+U11', cell_format_plan )
    worksheet_write_number( worksheet, 10, 18, arr[ 1, 15 ], cell_format )
    worksheet_write_number( worksheet, 10, 19, arr[ 1, 16 ], cell_format )
    worksheet_write_number( worksheet, 10, 20, arr[ 1, 17 ], cell_format )
    // worksheet_write_number( worksheet, 10, 21, arr[ 1, 18 ], cell_format )
    // worksheet_write_number( worksheet, 10, 22, arr[ 1, 19 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 10, 18, arr_1[ 1, 3 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 10, 19, arr_1[ 1, 5 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 10, 20, arr_1[ 1, 7 ], cell_format )
    worksheet_write_number( worksheet, 10, 21, arr_1[ 1, 9 ], cell_format )
    worksheet_write_number( worksheet, 10, 22, arr_1[ 1, 11 ], cell_format )

    worksheet_write_number( worksheet, 10, 23, arr[ 1, 9 ], cell_format )
    worksheet_write_number( worksheet, 10, 24, arr[ 1, 10 ], cell_format )

    worksheet_set_row( worksheet, 11, 39.8 )
    worksheet_write_string( worksheet, 11, 0, '1.1', form_text_X )
    worksheet_write_string( worksheet, 11, 1, 'в том числе сельских жителей', cell_format_man )
    worksheet_write_string( worksheet, 11, 2, '', form_plan_selo )

    worksheet_write_formula( worksheet, 11, 3, '=I12+J12+K12', cell_format_plan )
    worksheet_write_number( worksheet, 11, 4, arr[ 2, 11 ], cell_format )
    worksheet_write_number( worksheet, 11, 5, arr[ 2, 12 ], cell_format )
    worksheet_write_number( worksheet, 11, 6, arr[ 2, 13 ], cell_format )
    worksheet_write_number( worksheet, 11, 7, arr[ 2, 14 ], cell_format )

    worksheet_write_number( worksheet, 11, 8, arr[ 2, 1 ], cell_format )
    worksheet_write_number( worksheet, 11, 9, arr[ 2, 2 ], cell_format )
    worksheet_write_number( worksheet, 11, 10, arr[ 2, 3 ], cell_format )
    worksheet_write_number( worksheet, 11, 11, arr[ 2, 4 ], cell_format )
    worksheet_write_string( worksheet, 11, 12, 'X', form_text_X )
    worksheet_write_string( worksheet, 11, 13, 'X', form_text_X )
    worksheet_write_string( worksheet, 11, 14, 'X', form_text_X )
    worksheet_write_string( worksheet, 11, 15, 'X', form_text_X )
    worksheet_write_formula( worksheet, 11, 16, '=L12', cell_format_plan )

    worksheet_write_formula( worksheet, 11, 17, '=S12+T12+U12', cell_format_plan )
    worksheet_write_number( worksheet, 11, 18, arr[ 2, 15 ], cell_format )
    worksheet_write_number( worksheet, 11, 19, arr[ 2, 16 ], cell_format )
    worksheet_write_number( worksheet, 11, 20, arr[ 2, 17 ], cell_format )
    // worksheet_write_number( worksheet, 11, 21, arr[ 2, 18 ], cell_format )
    // worksheet_write_number( worksheet, 11, 22, arr[ 2, 19 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 11, 18, arr_1[ 1, 4 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 11, 19, arr_1[ 1, 6 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 11, 20, arr_1[ 1, 8 ], cell_format )
    worksheet_write_number( worksheet, 11, 21, arr_1[ 1, 10 ], cell_format )
    worksheet_write_number( worksheet, 11, 22, arr_1[ 1, 12 ], cell_format )

    worksheet_write_number( worksheet, 11, 23, arr[ 2, 9 ], cell_format )
    worksheet_write_number( worksheet, 11, 24, arr[ 2, 10 ], cell_format )

    worksheet_set_row( worksheet, 12, 39.8 )
    worksheet_write_string( worksheet, 12, 0, '2', form_text_X )
    worksheet_write_string( worksheet, 12, 1, 'число женщин в возрасте 18-49 лет  - всего', cell_format_woman )
    worksheet_write_string( worksheet, 12, 2, iif( Len( arr_plan ) > 0, AllTrim( Str( arr_plan[ 2 ] ) ), '' ), form_plan_gorod )

    worksheet_write_formula( worksheet, 12, 3, '=I13+J13+K13', cell_format_plan )
    worksheet_write_number( worksheet, 12, 4, arr[ 3, 11 ], cell_format )
    worksheet_write_number( worksheet, 12, 5, arr[ 3, 12 ], cell_format )
    worksheet_write_number( worksheet, 12, 6, arr[ 3, 13 ], cell_format )
    worksheet_write_number( worksheet, 12, 7, arr[ 3, 14 ], cell_format )

    worksheet_write_number( worksheet, 12, 8, arr[ 3, 1 ], cell_format )
    worksheet_write_number( worksheet, 12, 9, arr[ 3, 2 ], cell_format )
    worksheet_write_number( worksheet, 12, 10, arr[ 3, 3 ], cell_format )
    worksheet_write_number( worksheet, 12, 11, arr[ 3, 4 ], cell_format )
    worksheet_write_number( worksheet, 12, 12, arr[ 3, 5 ], cell_format )
    worksheet_write_number( worksheet, 12, 13, arr[ 3, 6 ], cell_format )
    worksheet_write_number( worksheet, 12, 14, arr[ 3, 7 ], cell_format )
    worksheet_write_number( worksheet, 12, 15, arr[ 3, 8 ], cell_format )
    worksheet_write_string( worksheet, 12, 16, 'X', form_text_X )

    worksheet_write_formula( worksheet, 12, 17, '=S13+T13+U13', cell_format_plan )
    worksheet_write_number( worksheet, 12, 18, arr[ 3, 15 ], cell_format )
    worksheet_write_number( worksheet, 12, 19, arr[ 3, 16 ], cell_format )
    worksheet_write_number( worksheet, 12, 20, arr[ 3, 17 ], cell_format )
    // worksheet_write_number( worksheet, 12, 21, arr[ 3, 18 ], cell_format )
    // worksheet_write_number( worksheet, 12, 22, arr[ 3, 19 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 12, 18, arr_1[ 2, 3 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 12, 19, arr_1[ 2, 5 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 12, 20, arr_1[ 2, 7 ], cell_format )
    worksheet_write_number( worksheet, 12, 21, arr_1[ 2, 9 ], cell_format )
    worksheet_write_number( worksheet, 12, 22, arr_1[ 2, 11 ], cell_format )

    worksheet_write_number( worksheet, 12, 23, arr[ 3, 9 ], cell_format )
    worksheet_write_number( worksheet, 12, 24, arr[ 3, 10 ], cell_format )

    worksheet_set_row( worksheet, 13, 39.8 )
    worksheet_write_string( worksheet, 13, 0, '2.1', form_text_X )
    worksheet_write_string( worksheet, 13, 1, 'в том числе сельских жителей', cell_format_woman )
    worksheet_write_string( worksheet, 13, 2, '', form_plan_selo )

    worksheet_write_formula( worksheet, 13, 3, '=I14+J14+K14', cell_format_plan )
    worksheet_write_number( worksheet, 13, 4, arr[ 4, 11 ], cell_format )
    worksheet_write_number( worksheet, 13, 5, arr[ 4, 12 ], cell_format )
    worksheet_write_number( worksheet, 13, 6, arr[ 4, 13 ], cell_format )
    worksheet_write_number( worksheet, 13, 7, arr[ 4, 14 ], cell_format )

    worksheet_write_number( worksheet, 13, 8, arr[ 4, 1 ], cell_format )
    worksheet_write_number( worksheet, 13, 9, arr[ 4, 2 ], cell_format )
    worksheet_write_number( worksheet, 13, 10, arr[ 4, 3 ], cell_format )
    worksheet_write_number( worksheet, 13, 11, arr[ 4, 4 ], cell_format )
    worksheet_write_number( worksheet, 13, 12, arr[ 4, 5 ], cell_format )
    worksheet_write_number( worksheet, 13, 13, arr[ 4, 6 ], cell_format )
    worksheet_write_number( worksheet, 13, 14, arr[ 4, 7 ], cell_format )
    worksheet_write_number( worksheet, 13, 15, arr[ 4, 8 ], cell_format )
    worksheet_write_string( worksheet, 13, 16, 'X', form_text_X )

    worksheet_write_formula( worksheet, 13, 17, '=S14+T14+U14', cell_format_plan )
    worksheet_write_number( worksheet, 13, 18, arr[ 4, 15 ], cell_format )
    worksheet_write_number( worksheet, 13, 19, arr[ 4, 16 ], cell_format )
    worksheet_write_number( worksheet, 13, 20, arr[ 4, 17 ], cell_format )
    // worksheet_write_number( worksheet, 13, 21, arr[ 4, 18 ], cell_format )
    // worksheet_write_number( worksheet, 13, 22, arr[ 4, 19 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 13, 18, arr_1[ 2, 4 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 13, 19, arr_1[ 2, 6 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( worksheet, 13, 20, arr_1[ 2, 8 ], cell_format )
    worksheet_write_number( worksheet, 13, 21, arr_1[ 2, 10 ], cell_format )
    worksheet_write_number( worksheet, 13, 22, arr_1[ 2, 12 ], cell_format )

    worksheet_write_number( worksheet, 13, 23, arr[ 4, 9 ], cell_format )
    worksheet_write_number( worksheet, 13, 24, arr[ 4, 10 ], cell_format )

    worksheet_set_row( worksheet, 14, 39.8 )
    worksheet_write_string( worksheet, 14, 0, '3', form_text_X )
    worksheet_write_string( worksheet, 14, 1, 'Общее число лиц в возрасте 18-49 лет', cell_format_full )

    worksheet_write_formula( worksheet, 14, 2, '=C11+C13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 3, '=D11+D13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 4, '=E11+E13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 5, '=F11+F13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 6, '=G11+G13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 7, '=H11+H13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 8, '=I11+I13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 9, '=J11+J13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 10, '=K11+K13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 11, '=L11+L13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 12, '=M13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 13, '=N13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 14, '=O13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 15, '=P13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 16, '=Q11', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 17, '=R11+R13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 18, '=S11+S13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 19, '=T11+T13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 20, '=U11+U13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 21, '=V11+V13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 22, '=W11+W13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 23, '=X11+X13', cell_format_itog )
    worksheet_write_formula( worksheet, 14, 24, '=Y11+Y13', cell_format_itog )

    worksheet_set_row( worksheet, 15, 39.8 )
    worksheet_write_string( worksheet, 15, 0, '3.1', form_text_X )
    worksheet_write_string( worksheet, 15, 1, 'в том числе сельских жителей', cell_format_full )

    worksheet_write_formula( worksheet, 15, 2, '=C12+C14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 3, '=D12+D14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 4, '=E12+E14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 5, '=F12+F14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 6, '=G12+G14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 7, '=H12+H14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 8, '=I12+I14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 9, '=J12+J14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 10, '=K12+K14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 11, '=L12+L14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 12, '=M14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 13, '=N14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 14, '=O14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 15, '=P14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 16, '=Q12', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 17, '=R12+R14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 18, '=S12+S14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 19, '=T12+T14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 20, '=U12+U14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 21, '=V12+V14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 22, '=W12+W14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 23, '=X12+X14', cell_format_itog )
    worksheet_write_formula( worksheet, 15, 24, '=Y12+Y14', cell_format_itog )

    // подвал
    worksheet_set_row( worksheet, 19, 21 )
    worksheet_write_string( worksheet, 19, 1, 'ФИО главного врача', form_text_footer_1 )
    worksheet_merge_range( worksheet, 19, 2, 19, 6, '', form_text_footer )
    worksheet_set_row( worksheet, 20, 21 )
    worksheet_write_string( worksheet, 20, 1, 'ФИО исполнителя', form_text_footer_1 )
    worksheet_merge_range( worksheet, 20, 2, 20, 6, '', form_text_footer )
    worksheet_set_row( worksheet, 21, 21 )
    worksheet_write_string( worksheet, 21, 1, 'Номер телефона исполнителя', form_text_footer_1 )
    worksheet_merge_range( worksheet, 21, 2, 21, 6, '', form_text_footer )
    // добавка для РЖД

    /* Установить высоту строки */
    // WORKSHEET_SET_ROW( analiz, 0, 39.8 )
    // WORKSHEET_SET_ROW( analiz, 4, 70 )
    // WORKSHEET_SET_ROW( analiz, 5, 130 )

    /* Установить ширину колонок */
    // WORKSHEET_SET_COLUMN( analiz, 0, 0, 6.22 )
    // WORKSHEET_SET_COLUMN( analiz, 1, 1, 32.78 )
    // WORKSHEET_SET_COLUMN( analiz, 2, 2, 14.0 )
    // WORKSHEET_SET_COLUMN( analiz, 3, 3, 14.0 )
    // WORKSHEET_SET_COLUMN( analiz, 4, 4, 14.0 )
    // WORKSHEET_SET_COLUMN( analiz, 5, 5, 14.0 )
    // WORKSHEET_SET_COLUMN( analiz, 6, 6, 14.0 )
    // WORKSHEET_SET_COLUMN( analiz, 7, 7, 14.0 )
    // WORKSHEET_SET_COLUMN( analiz, 8, 8, 14.0 )
    // WORKSHEET_SET_COLUMN( analiz, 9, 9, 14.0 )

    // for iii := 1 to 8
    // arr_1[ 3, iii ] := arr_1[ 2, iii ] + arr_1[ 1, iii ]
    // next
    // titlen_uchexcel( analiz, 1, 1, st_a_uch, 90, lcount_uch, fmt_excel_hC_vC_wrap( workbook ) )

    // WORKSHEET_WRITE_STRING( analiz, 4, 3,  'Определены группы здоровья по результатам 2 этапа диспансеризации (тип диспансеризации - ДР2, результат обращения в соответствии с кодом)', form_text_header )
    // WORKSHEET_WRITE_STRING( analiz, 4, 4,  'Определены группы здоровья по результатам 2 этапа диспансеризации (тип диспансеризации - ДР2, результат обращения в соответствии с кодом)', form_text_header )
    // WORKSHEET_WRITE_STRING( analiz, 4, 5,  'Определены группы здоровья по результатам 2 этапа диспансеризации (тип диспансеризации - ДР2, результат обращения в соответствии с кодом)', form_text_header )
    // worksheet_merge_range(  analiz, 4, 3, 4, 5, 'Определены группы здоровья по результатам 2 этапа диспансеризации (тип диспансеризации - ДР2, результат обращения в соответствии с кодом)' ,form_text_header  )
    // WORKSHEET_WRITE_STRING( analiz, 5, 3,  '1 группа РЗ (код классификатора 375 )', form_text_header )
    // WORKSHEET_WRITE_STRING( analiz, 5, 4,  '2 группа РЗ (код классификатора 376 )', form_text_header )
    // WORKSHEET_WRITE_STRING( analiz, 5, 5,  '3 группа РЗ (код классификатора 377 )', form_text_header )
    // WORKSHEET_WRITE_STRING( analiz, 4, 6,  'Из числа прошедших диспансеризацию состояли под диспансерным наблюдением (из  графы 4)', form_text_header )
    // WORKSHEET_WRITE_STRING( analiz, 4, 7,  'Из числа прошедших диспансеризацию состояли под диспансерным наблюдением (из  графы 4)', form_text_header )
    // worksheet_merge_range(  analiz, 4, 6, 4, 7, 'Из числа прошедших диспансеризацию состояли под диспансерным наблюдением (из  графы 4)' ,form_text_header  )
    // WORKSHEET_WRITE_STRING( analiz, 5, 6,  'всего, чел.', form_text_header )
    // WORKSHEET_WRITE_STRING( analiz, 5, 7,  'из них: диспансерное наблюдение установлено впервые по результатам проведения диспансеризации ', form_text_header )
    //

    // WORKSHEET_WRITE_STRING( analiz, 6, 1,  'Число мужчин прошли 2-й этап', form_text_header )
    // WORKSHEET_WRITE_NUMBER( analiz, 6, 2, arr_1[ 1, 1 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 6, 3, arr_1[ 1, 3 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 6, 4, arr_1[ 1, 5 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 6, 5, arr_1[ 1, 7 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 6, 6, arr_1[ 1, 9 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 6, 7, arr_1[ 1, 11 ], cell_format )
    // WORKSHEET_WRITE_STRING( analiz, 7, 1,  'в том числе сельских жителей', form_text_header )
    // WORKSHEET_WRITE_NUMBER( analiz, 7, 2, arr_1[ 1, 2 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 7, 3, arr_1[ 1, 4 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 7, 4, arr_1[ 1, 6 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 7, 5, arr_1[ 1, 8 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 7, 6, arr_1[ 1, 10 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 7, 7, arr_1[ 1, 12 ], cell_format )

    // WORKSHEET_WRITE_STRING( analiz, 8, 1,  'Число женщин прошли 2-й этап', form_text_header )
    // WORKSHEET_WRITE_NUMBER( analiz, 8, 2, arr_1[ 2, 1 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 8, 3, arr_1[ 2, 3 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 8, 4, arr_1[ 2, 5 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 8, 5, arr_1[ 2, 7 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 8, 6, arr_1[ 2, 9 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 8, 7, arr_1[ 2, 11 ], cell_format )
    // WORKSHEET_WRITE_STRING( analiz, 9, 1,  'в том числе сельских жителей', form_text_header )
    // WORKSHEET_WRITE_NUMBER( analiz, 9, 2, arr_1[ 2, 2 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 9, 3, arr_1[ 2, 4 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 9, 4, arr_1[ 2, 6 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 9, 5, arr_1[ 2, 8 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 9, 6, arr_1[ 2, 10 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 9, 7, arr_1[ 2, 12 ], cell_format )

    // WORKSHEET_WRITE_STRING( analiz, 10, 1,  'Итого прошли 2-й этап', form_text_header )
    // WORKSHEET_WRITE_NUMBER( analiz, 10, 2, arr_1[ 3, 1 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 10, 3, arr_1[ 3, 3 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 10, 4, arr_1[ 3, 5 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 10, 5, arr_1[ 3, 7 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 10, 6, arr_1[ 3, 9 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 10, 7, arr_1[ 3, 11 ], cell_format )
    // WORKSHEET_WRITE_STRING( analiz, 11, 1,  'в том числе сельских жителей', form_text_header )
    // WORKSHEET_WRITE_NUMBER( analiz, 11, 2, arr_1[ 3, 2 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 11, 3, arr_1[ 3, 4 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 11, 4, arr_1[ 3, 6 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 11, 5, arr_1[ 3, 8 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 11, 6, arr_1[ 3, 10 ], cell_format )
    // WORKSHEET_WRITE_NUMBER( analiz, 11, 7, arr_1[ 3, 12 ], cell_format )


    // WORKSHEET_WRITE_NUMBER( analiz, 31, 7, arr_1[ 3, 12 ], nil )

    merge_format2511 := fmt_excel_hc_vc_wrap( workbook ) // WORKBOOK_ADD_FORMAT( workbook )
    /* Конфигурируем формат для объединенных ячеек. */
    format_set_font_size( merge_format2511, 10 )
    format_set_border( merge_format2511, LXW_BORDER_THIN )

    form_text2511 := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( form_text2511, 10 )
    format_set_border( form_text2511, LXW_BORDER_THIN )

    cell_format2511 := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( cell_format2511, 10 )
    format_set_border( cell_format2511, LXW_BORDER_THIN )

    ws2511 := workbook_add_worksheet( workbook,  'табл.2511' )

    worksheet_write_string( ws2511, 0, 0, 'табл. 2511 формы № 30', form_text_date )
    worksheet_merge_range( ws2511, 1, 0, 2, 0, '', merge_format2511 )
    worksheet_merge_range( ws2511, 1, 1, 2, 1, 'Подлежало осмотрам', merge_format2511 )
    worksheet_merge_range( ws2511, 1, 2, 2, 2, 'из них сельских жителей', merge_format2511 )
    worksheet_merge_range( ws2511, 1, 3, 2, 3, 'Осмотрено', merge_format2511 )
    worksheet_merge_range( ws2511, 1, 4, 2, 4, 'из них сельских жителей', merge_format2511 )
    worksheet_merge_range( ws2511, 1, 5, 1, 6, 'Выявлена патология', merge_format2511 )
    worksheet_write_string( ws2511, 2, 5, 'Всего', form_text2511 )
    worksheet_write_string( ws2511, 2, 6, 'из них сельских жителей', form_text2511 )

    worksheet_merge_range( ws2511, 1, 7, 1, 8, 'Направлено на лечение', merge_format2511 )
    worksheet_write_string( ws2511, 2, 7, 'Всего', form_text2511 )
    worksheet_write_string( ws2511, 2, 8, 'из них сельских жителей', form_text2511 )

    worksheet_merge_range( ws2511, 1, 9, 1, 10, 'Пролечено', merge_format2511 )
    worksheet_write_string( ws2511, 2, 9, 'Всего', form_text2511 )
    worksheet_write_string( ws2511, 2, 10, 'из них сельских жителей', form_text2511 )

    For i := 1 To 11
      worksheet_write_string( ws2511, 3, i - 1, AllTrim( Str( i ) ), form_text2511 )
    Next

    worksheet_set_column( ws2511, 0, 0, 26 )
    For i := 1 To 11
      worksheet_set_column( ws2511, i, i, 12 )
      worksheet_write_string( ws2511, 4, i - 1, 'X', form_text2511 )
      worksheet_write_string( ws2511, 5, i - 1, 'X', form_text2511 )
      worksheet_write_string( ws2511, 6, i - 1, 'X', form_text2511 )
    Next

    worksheet_write_string( ws2511, 4, 0, 'Осмотрено пациентов в возрасте 15-17 лет, всего', form_text2511 )
    worksheet_write_string( ws2511, 5, 0, 'из них: мальчиков (урологом-андрологом)', form_text2511 )
    worksheet_write_string( ws2511, 6, 0, 'девочек (акушером-гинекологом)', form_text2511 )
    worksheet_write_string( ws2511, 7, 0, 'Осмотрено пациентов в возрасте 18-49 лет, всего', form_text2511 )
    worksheet_write_string( ws2511, 8, 0, 'из них мужчин (врачом-урологом, при его отсутствии врачом-хирургом, прошедшим подготовку по вопросам репродуктивного здоровья у мужчин)', form_text2511 )
    worksheet_write_string( ws2511, 9, 0, 'женщин (врачом акушером-гинекологом)', form_text2511 )

    worksheet_write_formula( ws2511, 7, 1, '=табл_1!C15', cell_format2511 )
    worksheet_write_formula( ws2511, 8, 1, '=табл_1!C11', cell_format2511 )
    worksheet_write_formula( ws2511, 9, 1, '=табл_1!C13', cell_format2511 )

    worksheet_write_formula( ws2511, 7, 2, '=табл_1!C16', cell_format2511 )
    worksheet_write_formula( ws2511, 8, 2, '=табл_1!C12', cell_format2511 )
    worksheet_write_formula( ws2511, 9, 2, '=табл_1!C14', cell_format2511 )

    worksheet_write_formula( ws2511, 7, 3, '=табл_1!D15', cell_format2511 )
    worksheet_write_formula( ws2511, 8, 3, '=табл_1!D11', cell_format2511 )
    worksheet_write_formula( ws2511, 9, 3, '=табл_1!D13', cell_format2511 )

    worksheet_write_formula( ws2511, 7, 4, '=табл_1!D16', cell_format2511 )
    worksheet_write_formula( ws2511, 8, 4, '=табл_1!D12', cell_format2511 )
    worksheet_write_formula( ws2511, 9, 4, '=табл_1!D14', cell_format2511 )

    worksheet_write_formula( ws2511, 7, 5, '=табл_1!L15', cell_format2511 )
    worksheet_write_formula( ws2511, 8, 5, '=табл_1!L11', cell_format2511 )
    worksheet_write_formula( ws2511, 9, 5, '=табл_1!L13', cell_format2511 )

    worksheet_write_formula( ws2511, 7, 6, '=табл_1!L16', cell_format2511 )
    worksheet_write_formula( ws2511, 8, 6, '=табл_1!L12', cell_format2511 )
    worksheet_write_formula( ws2511, 9, 6, '=табл_1!L14', cell_format2511 )

    worksheet_write_formula( ws2511, 7, 7, '=табл_1!X15', cell_format2511 )
    worksheet_write_formula( ws2511, 8, 7, '=табл_1!X11', cell_format2511 )
    worksheet_write_formula( ws2511, 9, 7, '=табл_1!X13', cell_format2511 )

    worksheet_write_formula( ws2511, 7, 8, '=табл_1!X16', cell_format2511 )
    worksheet_write_formula( ws2511, 8, 8, '=табл_1!X12', cell_format2511 )
    worksheet_write_formula( ws2511, 9, 8, '=табл_1!X14', cell_format2511 )

    worksheet_write_formula( ws2511, 7, 9, '=табл_1!Y15', cell_format2511 )
    worksheet_write_formula( ws2511, 8, 9, '=табл_1!Y11', cell_format2511 )
    worksheet_write_formula( ws2511, 9, 9, '=табл_1!Y13', cell_format2511 )

    worksheet_write_formula( ws2511, 7, 10, '=табл_1!Y16', cell_format2511 )
    worksheet_write_formula( ws2511, 8, 10, '=табл_1!Y12', cell_format2511 )
    worksheet_write_formula( ws2511, 9, 10, '=табл_1!Y14', cell_format2511 )

    ws2517 := workbook_add_worksheet( workbook,  'табл.2517' )

    cell_format2517 := fmt_excel_hl_vc_wrap( workbook )
    format_set_font_size( cell_format2517, 10 )
    // FORMAT_SET_BOLD( cell_format2517 )
    format_set_bg_color( cell_format2517, 0xcdcdcd )
    format_set_border( cell_format2517, LXW_BORDER_THIN )

    cell_format_bold2517 := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( cell_format_bold2517, 10 )
    format_set_bold( cell_format_bold2517 )
    format_set_bg_color( cell_format_bold2517, 0xcdcdcd )
    format_set_border( cell_format_bold2517, LXW_BORDER_THIN )

    cell_formula_2517 := fmt_excel_hc_vc_wrap( workbook )
    format_set_font_size( cell_formula_2517, 10 )
    format_set_bold( cell_formula_2517 )
    format_set_bg_color( cell_formula_2517, 0xdae6f1 )
    format_set_border( cell_formula_2517, LXW_BORDER_THIN )

    format_set_font_size( cell_format, 10 )

    worksheet_set_column( ws2517, 0, 0, 50 )
    worksheet_set_column( ws2517, 1, 2, 11 )

    For i := 1 To 14
      worksheet_set_row( ws2517, i, 42 )
    Next

    worksheet_write_string( ws2517, 0, 0, 'табл. 2517 формы № 30', form_text_date )
    worksheet_write_string( ws2517, 1, 0, 'Диспансеризация граждан репродуктивного возраста 18–49 лет включительно, с целью оценки репродуктивного здоровья, чел.', cell_format_bold2517 )
    worksheet_write_string( ws2517, 1, 1, 'Всего', cell_format_bold2517 )
    worksheet_write_string( ws2517, 1, 2, 'из них сельских жителей', cell_format_bold2517 )
    worksheet_write_string( ws2517, 2, 0, '1', cell_format_bold2517 )
    worksheet_write_string( ws2517, 2, 1, '2', cell_format_bold2517 )
    worksheet_write_string( ws2517, 2, 2, '3', cell_format_bold2517 )

    worksheet_write_string( ws2517, 3, 0, 'Общее число пациентов, состоявших в отчетном году под диспансерным наблюдением с патологией репродуктивного здоровья', cell_format2517 )
    worksheet_write_formula( ws2517, 3, 1, '=табл_1!V15', cell_formula_2517 )
    worksheet_write_formula( ws2517, 3, 2, '=табл_1!V16', cell_formula_2517 )

    worksheet_write_string( ws2517, 4, 0, Space( 10 ) + 'из них женщин', cell_format2517 )
    worksheet_write_formula( ws2517, 4, 1, '=табл_1!V13', cell_formula_2517 )
    worksheet_write_formula( ws2517, 4, 2, '=табл_1!V14', cell_formula_2517 )

    worksheet_write_string( ws2517, 5, 0, 'из общего число пациентов, состоявших в отчетном году под диспансерным наблюдением с патологией репродуктивного здоровья, было: госпитализировано', cell_format2517 )
    worksheet_write_number( ws2517, 5, 1, 0, cell_format )
    worksheet_write_number( ws2517, 5, 2, 0, cell_format )

    worksheet_write_string( ws2517, 6, 0, Space( 10 ) + 'из них женщин', cell_format2517 )
    worksheet_write_number( ws2517, 6, 1, 0, cell_format )
    worksheet_write_number( ws2517, 6, 2, 0, cell_format )

    worksheet_write_string( ws2517, 7, 0, Space( 5 ) + 'направлено на санаторно-курортное лечение', cell_format2517 )
    //worksheet_write_number( ws2517, 7, 1, arr[ 1, 22 ] + arr[ 2, 22 ] + arr[ 3, 22 ] + arr[ 4, 22 ], cell_format )
    worksheet_write_number( ws2517, 7, 1, arr[ 1, 22 ] + arr[ 3, 22 ] , cell_format )
    worksheet_write_number( ws2517, 7, 2, arr[ 2, 22 ] + arr[ 4, 22 ], cell_format )

    worksheet_write_string( ws2517, 8, 0, Space( 10 ) + 'из них женщин', cell_format2517 )
    //worksheet_write_number( ws2517, 8, 1, arr[ 3, 22 ] + arr[ 4, 22 ], cell_format )
    worksheet_write_number( ws2517, 8, 1, arr[ 3, 22 ] , cell_format )
    worksheet_write_number( ws2517, 8, 2, arr[ 4, 22 ], cell_format )

    worksheet_write_string( ws2517, 9, 0, Space( 5 ) + 'нуждалось в оперативном лечении', cell_format2517 )
    //worksheet_write_number( ws2517, 9, 1, arr[ 1, 20 ] + arr[ 2, 20 ] + arr[ 3, 20 ] + arr[ 4, 20 ], cell_format )
    worksheet_write_number( ws2517, 9, 1, arr[ 1, 20 ] + arr[ 3, 20 ] , cell_format )
    worksheet_write_number( ws2517, 9, 2, arr[ 2, 20 ] + arr[ 4, 20 ], cell_format )

    worksheet_write_string( ws2517, 10, 0, Space( 10 ) + 'из них женщин', cell_format2517 )
    //worksheet_write_number( ws2517, 10, 1, arr[ 3, 20 ] + arr[ 4, 20 ], cell_format )
    worksheet_write_number( ws2517, 10, 1, arr[ 3, 20 ] , cell_format )
    worksheet_write_number( ws2517, 10, 2, arr[ 4, 20 ], cell_format )

    worksheet_write_string( ws2517, 11, 0, Space( 5 ) + 'оперировано', cell_format2517 )
    worksheet_write_number( ws2517, 11, 1, 0, cell_format )
    worksheet_write_number( ws2517, 11, 2, 0, cell_format )

    worksheet_write_string( ws2517, 12, 0, Space( 10 ) + 'из них женщин', cell_format2517 )
    worksheet_write_number( ws2517, 12, 1, 0, cell_format )
    worksheet_write_number( ws2517, 12, 2, 0, cell_format )

    worksheet_write_string( ws2517, 13, 0, Space( 5 ) + 'направлено на медицинскую реабилитацию', cell_format2517 )
    //worksheet_write_number( ws2517, 13, 1, arr[ 1, 21 ] + arr[ 2, 21 ] + arr[ 3, 21 ] + arr[ 4, 21 ], cell_format )
    worksheet_write_number( ws2517, 13, 1, arr[ 1, 21 ]  + arr[ 3, 21 ] , cell_format )
    worksheet_write_number( ws2517, 13, 2, arr[ 2, 21 ] + arr[ 4, 21 ], cell_format )

    worksheet_write_string( ws2517, 14, 0, Space( 10 ) + 'из них женщин', cell_format2517 )
    //worksheet_write_number( ws2517, 14, 1, arr[ 3, 21 ] + arr[ 4, 21 ], cell_format )
    worksheet_write_number( ws2517, 14, 1, arr[ 3, 21 ], cell_format )
    worksheet_write_number( ws2517, 14, 2, arr[ 4, 21 ], cell_format )

    form_text_add := fmt_excel_hL_vC_wrap( workbook )
    format_set_font_size( form_text_add, 9 )
    format_set_bg_color( form_text_add, 0xcd66cd )
    format_set_border( form_text_add, LXW_BORDER_NONE )

    form_text_add1 := fmt_excel_hR_vC_wrap( workbook )
    format_set_font_size( form_text_add1, 9 )
    format_set_border( form_text_add1, LXW_BORDER_NONE )

    form_text_add2 := fmt_excel_hR_vC_wrap( workbook )
    format_set_font_size( form_text_add2, 9 )
    format_set_bg_color( form_text_add2, 0xcdcdcd )
    format_set_border( form_text_add2, LXW_BORDER_NONE )

    wsFemale := workbook_add_worksheet( workbook,  'Женщины' )
    worksheet_set_column( wsFemale, 0, 0, 61.2 )
    worksheet_set_column( wsFemale, 1, 1, 61.2 )
    worksheet_set_column( wsFemale, 2, 2, 11 )

    worksheet_merge_range( wsFemale, 0, 0, 0, 1, 'Календарный год:', form_text_add1 )
    worksheet_write_string( wsFemale, 0, 2, Str( Year( arr_m[ 6 ] ), 4 ), form_text_add1 )
    worksheet_merge_range( wsFemale, 1, 0, 1, 1, 'Период:', form_text_add1 )
    worksheet_merge_range( wsFemale, 2, 0, 2, 1, 'Субъект РФ:', form_text_add1 )

    worksheet_write_string( wsFemale, 7, 0, 'Число женщин, которые были обследованы в рамках 1-го этапа диспансеризации', form_text_add )
    worksheet_write_formula( wsFemale, 7, 2, '=табл_1!D13', form_text_add2 )

    worksheet_write_string( wsFemale, 8, 0, 'Число женщин, которые были направлены на 2-й этапа диспансеризации', form_text_add )
    worksheet_write_formula( wsFemale, 8, 2, '=табл_1!L13', form_text_add2 )
    worksheet_write_string( wsFemale, 9, 0, 'Число женщин, которые были обследованы в рамках 2-го этапа диспансеризации', form_text_add )
    worksheet_write_formula( wsFemale, 9, 2, '=табл_1!R13', form_text_add2 )
    for i := 7 to 9
      worksheet_write_string( wsFemale, i, 1, '', form_text_add )
    next

    worksheet_write_string( wsFemale, 10, 0, 'Число женщин 18-29 лет с выявленными заболеваниями репродуктивной системы по кодам МКБ-10 по результатам 1-го и 2-го этапа диспансеризациия', form_text_add )
    for i := 11 to 30
      worksheet_write_string( wsFemale, i, 0, '', form_text_add )
    next
    worksheet_write_string( wsFemale, 10, 1, 'D25 лейомиома матки', form_text_add )
    worksheet_write_string( wsFemale, 11, 1, 'Е28 дисфункция яичников', form_text_add )
    worksheet_write_string( wsFemale, 12, 1, 'N70-N73 воспалительные болезни женских тазовых органов', form_text_add )
    worksheet_write_string( wsFemale, 13, 1, 'N76 воспалительные болезни влагалища и вульвы', form_text_add )
    worksheet_write_string( wsFemale, 14, 1, 'N80 эндометриоз', form_text_add )
    worksheet_write_string( wsFemale, 15, 1, 'N81 выпадение женских половых органов', form_text_add )
    worksheet_write_string( wsFemale, 16, 1, 'N84.0 полип эндометрия', form_text_add )
    worksheet_write_string( wsFemale, 17, 1, 'N85.0-N85.1 гиперплазия эндометрия', form_text_add )
    worksheet_write_string( wsFemale, 18, 1, 'N86 эрозия и эктропион шейки матки', form_text_add )
    worksheet_write_string( wsFemale, 19, 1, 'N87 дисплазия шейки матки', form_text_add )
    worksheet_write_string( wsFemale, 20, 1, 'С53 злокачественное новообразование шейки матки', form_text_add )
    worksheet_write_string( wsFemale, 21, 1, 'N91-N94 расстройства менструаций', form_text_add )
    worksheet_write_string( wsFemale, 22, 1, 'N96 привычный выкидыш', form_text_add )
    worksheet_write_string( wsFemale, 23, 1, 'N97 женское бесплодие', form_text_add )
    worksheet_write_string( wsFemale, 24, 1, 'Q50-Q52 врожденные аномалии женских половых органов', form_text_add )
    worksheet_write_string( wsFemale, 25, 1, 'N60 доброкачественая дисплазия молочной железы', form_text_add )
    worksheet_write_string( wsFemale, 26, 1, 'С50 злокачественное новообразование молочной железы', form_text_add )
    worksheet_write_string( wsFemale, 27, 1, 'А55-А56 Другие хламидийные болезни, передающиеся половым путем', form_text_add )
    worksheet_write_string( wsFemale, 28, 1, 'А54 Гонококковая нфекция', form_text_add )
    worksheet_write_string( wsFemale, 29, 1, 'А63.8. Урогенитальные заболевания, вызванные Mycoplasma genitalium', form_text_add )
    worksheet_write_string( wsFemale, 30, 1, 'А59 Трихомониаз', form_text_add )

    worksheet_write_string( wsFemale, 10, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 11, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 12, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 13, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 14, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 15, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 16, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 17, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 18, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 19, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 20, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 21, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 22, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 23, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 24, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 25, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 26, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 27, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 28, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 29, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 30, 2, '', form_text_add2 )

    worksheet_write_string( wsFemale, 31, 0, 'Число женщин 18-29 лет с выявленными факторами риска нарушения репродуктивной системы по кодам МКБ-10 по результатам 1-го диспансеризациия и общей диспансеризации', form_text_add )
    for i := 31 to 43
      worksheet_write_string( wsFemale, i, 0, '', form_text_add )
    next
    worksheet_write_string( wsFemale, 31, 1, 'Е43-Е44 недостаточная масса тела (индекс массы тела <=18,5 кг/м2)', form_text_add )
    worksheet_write_string( wsFemale, 32, 1, 'R63.5 избыточная масса тела (индекс массы тела 25 - 29,9 кг/м2)', form_text_add )
    worksheet_write_string( wsFemale, 33, 1, 'Е66 ожирение (индекс массы тела >=30 кг/м2)', form_text_add )
    worksheet_write_string( wsFemale, 34, 1, 'Z72.0 курение табака (ежедневное выкуривание одной сигареты и более)', form_text_add )
    worksheet_write_string( wsFemale, 35, 1, 'Z57 воздействие производственных факторов риска', form_text_add )
    worksheet_write_string( wsFemale, 36, 1, 'Z72.1 употребление алкоголя', form_text_add )
    worksheet_write_string( wsFemale, 37, 1, 'Z72.2 использование наркотиков', form_text_add )
    worksheet_write_string( wsFemale, 38, 1, 'Е00-Е07 болезни щитовидной железы', form_text_add )
    worksheet_write_string( wsFemale, 39, 1, 'Е10-Е14 сахарный диабет', form_text_add )
    worksheet_write_string( wsFemale, 40, 1, 'Е22.1 гиперппролактинемия', form_text_add )
    worksheet_write_string( wsFemale, 41, 1, 'Е25 адреногенитальные расстройства', form_text_add )
    worksheet_write_string( wsFemale, 42, 1, 'L68.0 гирсутизм', form_text_add )
    worksheet_write_string( wsFemale, 43, 1, 'I10-I15 болезни, характеризующиеся повышенным кровяным давлением', form_text_add )

    worksheet_write_string( wsFemale, 31, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 32, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 33, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 34, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 35, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 36, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 37, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 38, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 39, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 40, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 41, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 42, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 43, 2, '', form_text_add2 )

    worksheet_write_string( wsFemale, 44, 0, 'Число женщин 30-49 лет с выявленными заболеваниями репродуктивной системы по кодам МКБ-10 по результатам 1-го и 2-го этапа диспансеризациия', form_text_add )
    for i := 44 to 64
      worksheet_write_string( wsFemale, i, 0, '', form_text_add )
    next
    worksheet_write_string( wsFemale, 44, 1, 'D25 лейомиома матки', form_text_add )
    worksheet_write_string( wsFemale, 45, 1, 'Е28 дисфункция яичников', form_text_add )
    worksheet_write_string( wsFemale, 46, 1, 'N70-N73 воспалительные болезни женских тазовых органов', form_text_add )
    worksheet_write_string( wsFemale, 47, 1, 'N76 воспалительные болезни влагалища и вульвы', form_text_add )
    worksheet_write_string( wsFemale, 48, 1, 'N80 эндометриоз', form_text_add )
    worksheet_write_string( wsFemale, 49, 1, 'N81 выпадение женских половых органов', form_text_add )
    worksheet_write_string( wsFemale, 50, 1, 'N84.0 полип эндометрия', form_text_add )
    worksheet_write_string( wsFemale, 51, 1, 'N85.0-N85.1 гиперплазия эндометрия', form_text_add )
    worksheet_write_string( wsFemale, 52, 1, 'N86 эрозия и эктропион шейки матки', form_text_add )
    worksheet_write_string( wsFemale, 53, 1, 'N87 дисплазия шейки матки', form_text_add )
    worksheet_write_string( wsFemale, 54, 1, 'С53 злокачественное новообразование шейки матки', form_text_add )
    worksheet_write_string( wsFemale, 55, 1, 'N91-N94 расстройства менструаций', form_text_add )
    worksheet_write_string( wsFemale, 56, 1, 'N96 привычный выкидыш', form_text_add )
    worksheet_write_string( wsFemale, 57, 1, 'N97 женское бесплодие', form_text_add )
    worksheet_write_string( wsFemale, 58, 1, 'Q50-Q52 врожденные аномалии женских половых органов', form_text_add )
    worksheet_write_string( wsFemale, 59, 1, 'N60 доброкачественая дисплазия молочной железы', form_text_add )
    worksheet_write_string( wsFemale, 60, 1, 'С50 злокачественное новообразование молочной железы', form_text_add )
    worksheet_write_string( wsFemale, 61, 1, 'А55-А56 Другие хламидийные болезни, передающиеся половым путем', form_text_add )
    worksheet_write_string( wsFemale, 62, 1, 'А54 Гонококковая нфекция', form_text_add )
    worksheet_write_string( wsFemale, 63, 1, 'А63.8. Урогенитальные заболевания, вызванные Mycoplasma genitalium', form_text_add )
    worksheet_write_string( wsFemale, 64, 1, 'А59 Трихомониаз', form_text_add )

    worksheet_write_string( wsFemale, 44, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 45, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 46, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 47, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 48, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 49, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 50, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 51, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 52, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 53, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 54, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 55, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 56, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 57, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 58, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 59, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 60, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 61, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 62, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 63, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 64, 2, '', form_text_add2 )


    worksheet_write_string( wsFemale, 65, 0, 'Число женщин 30-49 лет с выявленными факторами риска нарушения репродуктивной системы по кодам МКБ-10 по результатам 1-го диспансеризациия и общей диспансеризации', form_text_add )
    for i := 65 to 77
      worksheet_write_string( wsFemale, i, 0, '', form_text_add )
    next
    worksheet_write_string( wsFemale, 65, 1, 'Е43-Е44 недостаточная масса тела (индекс массы тела <=18,5 кг/м2)', form_text_add )
    worksheet_write_string( wsFemale, 66, 1, 'R63.5 избыточная масса тела (индекс массы тела 25 - 29,9 кг/м2)', form_text_add )
    worksheet_write_string( wsFemale, 67, 1, 'Е66 ожирение (индекс массы тела >=30 кг/м2)', form_text_add )
    worksheet_write_string( wsFemale, 68, 1, 'Z72.0 курение табака (ежедневное выкуривание одной сигареты и более)', form_text_add )
    worksheet_write_string( wsFemale, 69, 1, 'Z57 воздействие производственных факторов риска', form_text_add )
    worksheet_write_string( wsFemale, 70, 1, 'Z72.1 употребление алкоголя', form_text_add )
    worksheet_write_string( wsFemale, 71, 1, 'Z72.2 использование наркотиков', form_text_add )
    worksheet_write_string( wsFemale, 72, 1, 'Е00-Е07 болезни щитовидной железы', form_text_add )
    worksheet_write_string( wsFemale, 73, 1, 'Е10-Е14 сахарный диабет', form_text_add )
    worksheet_write_string( wsFemale, 74, 1, 'Е22.1 гиперппролактинемия', form_text_add )
    worksheet_write_string( wsFemale, 75, 1, 'Е25 адреногенитальные расстройства', form_text_add )
    worksheet_write_string( wsFemale, 76, 1, 'L68.0 гирсутизм', form_text_add )
    worksheet_write_string( wsFemale, 77, 1, 'I10-I15 болезни, характеризующиеся повышенным кровяным давлением', form_text_add )

    worksheet_write_string( wsFemale, 65, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 66, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 67, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 68, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 69, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 70, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 71, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 72, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 73, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 74, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 75, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 76, 2, '', form_text_add2 )
    worksheet_write_string( wsFemale, 77, 2, '', form_text_add2 )

    wsMan := workbook_add_worksheet( workbook,  'Мужчины' )
    worksheet_set_column( wsMan, 0, 0, 61.2 )
    worksheet_set_column( wsMan, 1, 1, 61.2 )
    worksheet_set_column( wsMan, 2, 2, 11 )

    worksheet_merge_range( wsMan, 0, 0, 0, 1, 'Календарный год:', form_text_add1 )
    worksheet_write_string( wsMan, 0, 2, Str( Year( arr_m[ 6 ] ), 4 ), form_text_add1 )
    worksheet_merge_range( wsMan, 1, 0, 1, 1, 'Период:', form_text_add1 )
    worksheet_merge_range( wsMan, 2, 0, 2, 1, 'Субъект РФ:', form_text_add1 )
    worksheet_merge_range( wsMan, 3, 0, 3, 1, 'Отчет:', form_text_add1 )

    worksheet_write_string( wsMan, 7, 0, 'Число мужчин, которые были обследованы в рамках 1-го этапа диспансеризации', form_text_add )
    worksheet_write_formula( wsMan, 7, 2, '=табл_1!D11', form_text_add2 )

    worksheet_write_string( wsMan, 8, 0, 'Число мужчин, которые были направлены на 2-й этап диспансеризации', form_text_add )
    worksheet_write_formula( wsMan, 8, 2, '=табл_1!L11', form_text_add2 )
    for i := 7 to 8
      worksheet_write_string( wsMan, i, 1, '', form_text_add )
    next

    worksheet_write_string( wsMan, 9, 0, 'Число мужчин 18-29 лет с выявленными заболеваниями репродуктивной системы по кодам МКБ-10 по результатам 1-го и 2-го этапов диспансеризации, всего', form_text_add )
    for i := 10 to 12
      worksheet_write_string( wsMan, i, 0, '', form_text_add )
    next
    worksheet_write_string( wsMan, 9, 1, 'N46 Мужское бесплодие', form_text_add )
    worksheet_write_string( wsMan, 10, 1, 'E29.1 Гипофункция яичек', form_text_add )
    worksheet_write_string( wsMan, 11, 1, 'I86.1 Варикоцеле', form_text_add )
    worksheet_write_string( wsMan, 12, 1, 'N44 Перекрут яичка', form_text_add )

    worksheet_write_string( wsMan, 9, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 10, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 11, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 12, 2, '', form_text_add2 )

    worksheet_write_string( wsMan, 13, 0, 'Число мужячин 18-29 лет с выявленными факторами риска нарушения репродуктивной системы по кодам МКБ-10 по результатам 1-го этапа диспансеризации и общей диспансеризации, всего', form_text_add )
    for i := 14 to 22
      worksheet_write_string( wsMan, i, 0, '', form_text_add )
    next
    worksheet_write_string( wsMan, 13, 1, 'Е66 Ожирение', form_text_add )
    worksheet_write_string( wsMan, 14, 1, 'A56.1 Хламидиоз органов малого таза', form_text_add )
    worksheet_write_string( wsMan, 15, 1, 'А59 Трихомониаз', form_text_add )
    worksheet_write_string( wsMan, 16, 1, 'А54 Гонококковая инфекция', form_text_add )
    worksheet_write_string( wsMan, 17, 1, 'A63.8 Уреаплазменная, микоплазменная инфекция (U. urealyticum, M. genitalium)', form_text_add )
    worksheet_write_string( wsMan, 18, 1, 'A63.0 Папилломавирусная инфекция', form_text_add )
    worksheet_write_string( wsMan, 19, 1, 'N41.1 Простатит', form_text_add )
    worksheet_write_string( wsMan, 20, 1, 'N45 Эпидидимит, эпидидимоорхит', form_text_add )
    worksheet_write_string( wsMan, 21, 1, 'B26 Эпидемический паротит', form_text_add )
    worksheet_write_string( wsMan, 22, 1, 'E10 Сахарный диабет 1 типа', form_text_add )

    worksheet_write_string( wsMan, 13, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 14, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 15, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 16, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 17, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 18, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 19, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 20, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 21, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 22, 2, '', form_text_add2 )



    worksheet_write_string( wsMan, 23, 0, 'Число мужячин 18-29 лет с выявленными факторами риска нарушения репродуктивной системы по кодам МКБ-10 по результатам 1-го этапа диспансеризации и общей диспансеризации, всего', form_text_add )
    for i := 24 to 26
      worksheet_write_string( wsMan, i, 0, '', form_text_add )
    next
    worksheet_write_string( wsMan, 23, 1, 'N46 Мужское бесплодие', form_text_add )
    worksheet_write_string( wsMan, 24, 1, 'E29.1 Гипофункция яичек', form_text_add )
    worksheet_write_string( wsMan, 25, 1, 'I86.1 Варикоцеле', form_text_add )
    worksheet_write_string( wsMan, 26, 1, 'N44 Перекрут яичка', form_text_add )

    worksheet_write_string( wsMan, 23, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 24, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 25, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 26, 2, '', form_text_add2 )

    worksheet_write_string( wsMan, 27, 0, 'Число мужчин 30-49 лет с выявленными факторами риска нарушения репродуктивной системы по кодам МКБ-10 по результатам 1-го этапа диспансеризации и общей диспансеризации, всего', form_text_add )
    for i := 28 to 36
      worksheet_write_string( wsMan, i, 0, '', form_text_add )
    next
    worksheet_write_string( wsMan, 27, 1, 'Е66 Ожирение', form_text_add )
    worksheet_write_string( wsMan, 28, 1, 'A56.1 Хламидиоз органов малого таза', form_text_add )
    worksheet_write_string( wsMan, 29, 1, 'А59 Трихомониаз', form_text_add )
    worksheet_write_string( wsMan, 30, 1, 'А54 Гонококковая инфекция', form_text_add )
    worksheet_write_string( wsMan, 31, 1, 'A63.8 Уреаплазменная, микоплазменная инфекция (U. urealyticum, M. genitalium)', form_text_add )
    worksheet_write_string( wsMan, 32, 1, 'A63.0 Папилломавирусная инфекция', form_text_add )
    worksheet_write_string( wsMan, 33, 1, 'N41.1 Простатит', form_text_add )
    worksheet_write_string( wsMan, 34, 1, 'N45 Эпидидимит, эпидидимоорхит', form_text_add )
    worksheet_write_string( wsMan, 35, 1, 'B26 Эпидемический паротит', form_text_add )
    worksheet_write_string( wsMan, 36, 1, 'E10 Сахарный диабет 1 типа', form_text_add )

    worksheet_write_string( wsMan, 27, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 28, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 29, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 30, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 31, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 32, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 33, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 34, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 35, 2, '', form_text_add2 )
    worksheet_write_string( wsMan, 36, 2, '', form_text_add2 )

    workbook_close( workbook )

  Endif
  Return Nil
