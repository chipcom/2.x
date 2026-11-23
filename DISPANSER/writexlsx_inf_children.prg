#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'
#include 'hbxlsxwriter.ch'

// 22.11.26
function writexlsx_inf_children( file_name, arr_m, arr_PO, arr_15_17, arr_NP, ;
  arr_2510_DDS, arr_2510_DDSOP, hYoung13_14, hYoung15_17, hGirl13_14, hGirl15_17 )

  Local buf := save_maxrow()
  Local workbook
  Local ws1, ws2, ws3, ws4, ws5, ws6
  Local cColorTab1, cColorTab2, cColorTab3, cColorTab4, cColorTab5, cColorTab6
  local error, i
  Local strMO, arr_plan
  Local titul_table_thin, titul_table_bold, titul_table_bold_green, text_thin, header_bold, header_data_bold
  Local titul_bold, block_FIO, block_gray, block_empty, block_Total, note_titul, note_text
  local t25_10, t25_10_yelow, titul_table_yelow, titul_bold_center, header_bold_sost, titul_center
  local diseases_gray_bold, diseases_center_gray_bold, diseases_normal_gray_bold, diseases_norm_cent_gray_bold
  local diseases_norm_cent_gray, diseases_norm_left_gray, diseases_block_empty

  strMO := hb_StrToUTF8( glob_mo()[ _MO_SHORT_NAME ] )
  arr_plan := get_plans_KZVO( Year( arr_m[ 6 ] ), glob_mo()[ _MO_KOD_FFOMS ] )
  // цвета таблятора листов
  cColorTab1 := 0xd9ead3
  cColorTab2 := 0xe9ead3
  cColorTab3 := 0xa9ead3
  cColorTab4 := 0xb9ead3
  cColorTab5 := 0xc9ead3
  cColorTab6 := 0x99ead3

  workbook  := workbook_new( file_name )

  header_bold := fmt_excel_hc_vc_wrap( workbook )
  format_set_bold( header_bold )
  format_set_font_size( header_bold, 15 )

  header_data_bold := fmt_excel_hc_vc_wrap( workbook )
  format_set_bold( header_data_bold )
  format_set_bg_color( header_data_bold, 0xff3db9 )
  format_set_font_size( header_data_bold, 14 )

  header_bold_sost := fmt_excel_hc_vc_wrap( workbook )
  format_set_bold( header_bold_sost )
//  format_set_bg_color( header_bold_sost, 0xff3db9 )
  format_set_font_size( header_bold_sost, 12 )

  titul_bold := fmt_excel_hl_vc_wrap( workbook )
  format_set_bold( titul_bold )
  format_set_font_size( titul_bold, 14 )

  titul_center := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( titul_center, 14 )

  titul_bold_center := fmt_excel_hc_vc_wrap( workbook )
  format_set_bold( titul_bold_center )
  format_set_font_size( titul_bold_center, 14 )

  titul_table_bold := fmt_excel_hc_vc_wrap( workbook )
  format_set_bold( titul_table_bold )
  format_set_font_size( titul_table_bold, 11 )
//  format_set_bg_color( titul_table_thin, 0xffff00 )
  format_set_border( titul_table_bold, LXW_BORDER_THIN )

  titul_table_yelow := fmt_excel_hc_vc_wrap( workbook )
  format_set_bold( titul_table_yelow )
  format_set_font_size( titul_table_yelow, 11 )
  format_set_bg_color( titul_table_yelow, 0xffff00 )
  format_set_border( titul_table_yelow, LXW_BORDER_THIN )

  titul_table_bold_green := fmt_excel_hc_vc_wrap( workbook )
  format_set_bold( titul_table_bold_green )
  format_set_font_size( titul_table_bold_green, 11 )
  format_set_bg_color( titul_table_bold_green, 0x89ead3 ) //0x547346 )
  format_set_border( titul_table_bold_green, LXW_BORDER_THIN )

  note_titul := fmt_excel_hc_vc_wrap( workbook )
  format_set_bold( note_titul )
  format_set_font_size( note_titul, 9 )
  format_set_bg_color( note_titul, 0x89ead3 ) //0x547346 )
  format_set_border( note_titul, LXW_BORDER_THIN )

  note_text := fmt_excel_hc_vc_wrap( workbook )
  format_set_italic( note_text )
  format_set_font_size( note_text, 11 )
//  format_set_bg_color( note_text, 0x89ead3 ) //0x547346 )
  format_set_border( note_text, LXW_BORDER_THIN )

  t25_10 := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( t25_10, 12 )
  format_set_bg_color( t25_10, 0xd9ead3 )
  format_set_border( t25_10, LXW_BORDER_THIN )

  t25_10_yelow := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( t25_10_yelow, 12 )
  format_set_bg_color( t25_10_yelow, 0xffff00 )
  format_set_border( t25_10_yelow, LXW_BORDER_THIN )

  titul_table_thin := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( titul_table_thin, 9 )
//  format_set_bg_color( titul_table_thin, 0xffff00 )
  format_set_border( titul_table_thin, LXW_BORDER_THIN )

  block_FIO := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( block_FIO, 12 )
  format_set_bold( block_FIO )
  format_set_bg_color( block_FIO, 0xffff00 )  // желтый
  format_set_border( block_FIO, LXW_BORDER_THIN )

  block_Total := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( block_Total, 12 )
  format_set_bold( block_Total )
  format_set_bg_color( block_Total, 0xb5aff1 )  // 0xcdcdcd - серый 0xdae6f1 0xf1dddd
  format_set_border( block_Total, LXW_BORDER_THIN )

  block_gray := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( block_gray, 12 )
  format_set_bg_color( block_gray, 0xcdcdcd )
  format_set_border( block_gray, LXW_BORDER_THIN )

  diseases_gray_bold := fmt_excel_hl_vc_wrap( workbook )
  format_set_font_size( diseases_gray_bold, 14 )
  format_set_bold( diseases_gray_bold )
  format_set_bg_color( diseases_gray_bold, 0xcdcdcd )
  format_set_border( diseases_gray_bold, LXW_BORDER_THIN )

  diseases_center_gray_bold := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( diseases_center_gray_bold, 14 )
  format_set_bold( diseases_center_gray_bold )
  format_set_bg_color( diseases_center_gray_bold, 0xcdcdcd )
  format_set_border( diseases_center_gray_bold, LXW_BORDER_THIN )

  diseases_normal_gray_bold := fmt_excel_hl_vc_wrap( workbook )
  format_set_font_size( diseases_normal_gray_bold, 12 )
  format_set_bold( diseases_normal_gray_bold )
  format_set_bg_color( diseases_normal_gray_bold, 0xcdcdcd )
  format_set_border( diseases_normal_gray_bold, LXW_BORDER_THIN )

  diseases_norm_cent_gray_bold := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( diseases_norm_cent_gray_bold, 12 )
  format_set_bold( diseases_norm_cent_gray_bold )
  format_set_bg_color( diseases_norm_cent_gray_bold, 0xcdcdcd )
  format_set_border( diseases_norm_cent_gray_bold, LXW_BORDER_THIN )

  diseases_norm_cent_gray := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( diseases_norm_cent_gray, 12 )
  format_set_bg_color( diseases_norm_cent_gray, 0xcdcdcd )
  format_set_border( diseases_norm_cent_gray, LXW_BORDER_THIN )

  diseases_norm_left_gray := fmt_excel_hl_vc_wrap( workbook )
  format_set_font_size( diseases_norm_left_gray, 12 )
  format_set_bg_color( diseases_norm_left_gray, 0xcdcdcd )
  format_set_border( diseases_norm_left_gray, LXW_BORDER_THIN )

  diseases_block_empty := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( diseases_block_empty, 14 )
  format_set_bg_color( diseases_block_empty, 0xffffc3 )
  format_set_border( diseases_block_empty, LXW_BORDER_THIN )

  block_empty := fmt_excel_hc_vc_wrap( workbook )
  format_set_font_size( block_empty, 12 )
  format_set_bg_color( block_empty, 0xffffc3 )
  format_set_border( block_empty, LXW_BORDER_THIN )

  text_thin := fmt_excel_hl_vc_wrap( workbook )
  format_set_font_size( text_thin, 11 )
//  format_set_bg_color( titul_table_thin, 0xffff00 )
  format_set_border( text_thin, LXW_BORDER_THIN )


//
// лист 1 - профосмотры
//
  ws1 := workbook_add_worksheet( workbook, 'профосмотры' )
  worksheet_set_tab_color( ws1, cColorTab1 )
  /* Установить высоту строки */
  worksheet_set_row( ws1, 1, 35.0 )
  worksheet_set_row( ws1, 6, 42.6 )
  worksheet_set_row( ws1, 7, 28.2 )
  worksheet_set_row( ws1, 8, 80.4 )
  /* Установить ширину колонок */
  worksheet_set_column( ws1, 0, 0, 5 )
  worksheet_set_column( ws1, 1, 1, 33.89 )
  worksheet_set_column( ws1, 2, 2, 16.22 )
  worksheet_set_column( ws1, 3, 3, 11.33 )
  worksheet_set_column( ws1, 4, 4, 11.33 )
  worksheet_set_column( ws1, 5, 5, 10.56 )
  worksheet_set_column( ws1, 6, 6, 16.33 )
  worksheet_set_column( ws1, 7, 7, 11.33 )
  worksheet_set_column( ws1, 8, 8, 12.67 )
  worksheet_set_column( ws1, 9, 9, 13.89 )
  worksheet_set_column( ws1, 10, 10, 9.44 )
  worksheet_set_column( ws1, 11, 11, 11.67 )
  worksheet_set_column( ws1, 12, 12, 12.44 )
  worksheet_set_column( ws1, 13, 13, 10.44 )
  worksheet_set_column( ws1, 14, 14, 11.22 )
  worksheet_set_column( ws1, 15, 15, 11.22 )
  worksheet_set_column( ws1, 16, 16, 9.89 )
  worksheet_set_column( ws1, 17, 17, 8.78 )
  worksheet_set_column( ws1, 18, 18, 12.67 )
  worksheet_set_column( ws1, 19, 19, 8.22 )
  worksheet_set_column( ws1, 20, 20, 8.44 )
  worksheet_set_column( ws1, 21, 21, 11.22 )
  worksheet_set_column( ws1, 22, 22, 11.33 )
  worksheet_set_column( ws1, 23, 23, 12.22 )
  worksheet_set_column( ws1, 24, 24, 11.89 )
  worksheet_set_column( ws1, 25, 25, 15.44 )
  worksheet_set_column( ws1, 26, 26, 19.67 )
  worksheet_set_column( ws1, 27, 27, 6.22 )

  worksheet_merge_range( ws1, 1, 4, 1, 11, 'Сведения о профилактических осмотрах несовершеннолетних', header_bold )
  worksheet_merge_range( ws1, 2, 4, 2, 5, 'по состоянию на', header_bold )
  worksheet_write_number( ws1, 2, 6, Day( arr_m[ 6 ] ), header_data_bold )
  worksheet_write_string( ws1, 2, 7, hb_StrToUTF8( Lower( CMonth( arr_m[ 6 ] ) ) ), header_data_bold )
  worksheet_write_number( ws1, 2, 8, Year( arr_m[ 6 ] ), header_data_bold )

  worksheet_merge_range( ws1, 4, 2, 4, 13, strMO, titul_bold_center )

  worksheet_merge_range( ws1, 6, 0, 8, 0, '№ стр.', titul_table_bold )
  worksheet_merge_range( ws1, 6, 1, 8, 1, 'Категория детей', titul_table_bold )
  worksheet_merge_range( ws1, 6, 2, 6, 6, 'Плановые показатели', titul_table_bold )
  worksheet_merge_range( ws1, 7, 2, 8, 2, 'Прикреплено к учреждению детей до 17 лет включительно', titul_table_bold )
  worksheet_merge_range( ws1, 7, 3, 8, 3, 'в том числе детей-инвалидов', titul_table_bold )
  worksheet_merge_range( ws1, 7, 4, 8, 4, 'подлежит по плану всего', titul_table_bold )
  worksheet_merge_range( ws1, 7, 5, 8, 5, 'из них сельских жителей из гр.3', titul_table_bold )
  worksheet_merge_range( ws1, 7, 6, 8, 6, 'в том числе детей-инвалидов из гр.2', titul_table_bold )

  worksheet_merge_range( ws1, 6, 7, 6, 9, 'Число детей прошедших 1 этап профилактических осмотров', titul_table_bold )
  worksheet_merge_range( ws1, 7, 7, 8, 7, 'всего', titul_table_bold )
  worksheet_merge_range( ws1, 7, 8, 8, 8, 'из них (из гр.5) сельских жителей', titul_table_bold )
  worksheet_merge_range( ws1, 7, 9, 8, 9, 'из них (из гр.5) с применением мобильных медицинских комплексов', titul_table_bold )

  worksheet_merge_range( ws1, 6, 10, 6, 18, 'Распределение детей, прошедших 1 этап профилактических осмотров, по группам здоровья', titul_table_bold )
  worksheet_merge_range( ws1, 7, 10, 8, 10, '1', titul_table_bold )
  worksheet_merge_range( ws1, 7, 11, 8, 11, '2', titul_table_bold )
  worksheet_merge_range( ws1, 7, 12, 8, 12, '3', titul_table_bold )
  worksheet_merge_range( ws1, 7, 13, 7, 14, 'из гр.9', titul_table_bold )
  worksheet_write_string( ws1, 8, 13, 'из них: III А', titul_table_bold )
  worksheet_write_string( ws1, 8, 14, 'из них: III Б', titul_table_bold )
  worksheet_merge_range( ws1, 7, 15, 8, 15, '4', titul_table_bold )
  worksheet_merge_range( ws1, 7, 16, 8, 16, 'в т.ч. детей-инвалидов из гр.10', titul_table_bold )
  worksheet_merge_range( ws1, 7, 17, 8, 17, '5', titul_table_bold )
  worksheet_merge_range( ws1, 7, 18, 8, 18, 'в т.ч. детей-инвалидов из гр.11', titul_table_bold )

  worksheet_merge_range( ws1, 6, 19, 6, 22, 'Распределение детей по медицинским группам для занятий физкультуры', titul_table_bold )
  worksheet_merge_range( ws1, 7, 19, 8, 19, 'основная', titul_table_bold )
  worksheet_merge_range( ws1, 7, 20, 8, 20, 'подготовительная', titul_table_bold )
  worksheet_merge_range( ws1, 7, 21, 7, 22, 'специальная', titul_table_bold )
  worksheet_write_string( ws1, 8, 21, 'А', titul_table_bold )
  worksheet_write_string( ws1, 8, 22, 'Б', titul_table_bold )

  worksheet_merge_range( ws1, 6, 23, 6, 24, 'Число законченных случаев 1 этапа профилактического осмотра', titul_table_bold )
  worksheet_merge_range( ws1, 7, 23, 8, 23, 'Представлено счетов к оплате', titul_table_bold )
  worksheet_merge_range( ws1, 7, 24, 8, 24, 'Из них оплачено', titul_table_bold )

  worksheet_merge_range( ws1, 6, 25, 8, 25, 'Число детей направленных на 2 этап профосмотра', titul_table_bold )
  worksheet_merge_range( ws1, 6, 26, 8, 26, 'Из них завершили 2 этап профосмотра', titul_table_bold )

  worksheet_write_string( ws1, 9, 0, '', titul_table_thin )
  worksheet_write_string( ws1, 9, 1, '', titul_table_thin )
  worksheet_write_string( ws1, 9, 2, '1', titul_table_thin )
  worksheet_write_string( ws1, 9, 3, '2', titul_table_thin )
  worksheet_write_string( ws1, 9, 4, '3', titul_table_thin )
  worksheet_write_string( ws1, 9, 5, '3.1', titul_table_thin )
  worksheet_write_string( ws1, 9, 6, '4', titul_table_thin )
  worksheet_write_string( ws1, 9, 7, '5', titul_table_thin )
  worksheet_write_string( ws1, 9, 8, '5.1', titul_table_thin )
  worksheet_write_string( ws1, 9, 9, '6', titul_table_thin )
  worksheet_write_string( ws1, 9, 10, '7', titul_table_thin )
  worksheet_write_string( ws1, 9, 11, '8', titul_table_thin )
  worksheet_write_string( ws1, 9, 12, '9', titul_table_thin )
  worksheet_write_string( ws1, 9, 13, '9.1', titul_table_thin )
  worksheet_write_string( ws1, 9, 14, '9.2', titul_table_thin )
  worksheet_write_string( ws1, 9, 15, '10', titul_table_thin )
  worksheet_write_string( ws1, 9, 16, '10.1', titul_table_thin )
  worksheet_write_string( ws1, 9, 17, '11', titul_table_thin )
  worksheet_write_string( ws1, 9, 18, '11.1', titul_table_thin )
  worksheet_write_string( ws1, 9, 19, '12', titul_table_thin )
  worksheet_write_string( ws1, 9, 20, '13', titul_table_thin )
  worksheet_write_string( ws1, 9, 21, '14', titul_table_thin )
  worksheet_write_string( ws1, 9, 22, '15', titul_table_thin )
  worksheet_write_string( ws1, 9, 23, '16', titul_table_thin )
  worksheet_write_string( ws1, 9, 24, '17', titul_table_thin )
  worksheet_write_string( ws1, 9, 25, '18', titul_table_thin )
  worksheet_write_string( ws1, 9, 26, '19', titul_table_thin )

  worksheet_write_string( ws1, 10, 1, 'Всего', text_thin )
  worksheet_write_formula( ws1, 10, 2, '=C12+C14', block_Total )
  worksheet_write_formula( ws1, 10, 3, '=D12+D14', block_Total )
  worksheet_write_formula( ws1, 10, 4, '=E12+E14', block_Total )
  worksheet_write_formula( ws1, 10, 5, '=F12+F13+F14', block_Total )   // '=SUM(F12;F14)', nil )
  worksheet_write_formula( ws1, 10, 6, '=G12+G14', block_Total )
  worksheet_write_formula( ws1, 10, 7, '=K11+L11+M11+P11+R11', block_Total )
  worksheet_write_formula( ws1, 10, 8, '=I12+I14', block_Total )
  worksheet_write_formula( ws1, 10, 9, '=J12+J14', block_Total )
  worksheet_write_formula( ws1, 10, 10, '=K12+K14', block_Total )
  worksheet_write_formula( ws1, 10, 11, '=L12+L14', block_Total )
  worksheet_write_formula( ws1, 10, 12, '=M12+M14', block_Total )
  worksheet_write_string( ws1, 10, 13, 'Х', block_gray )
  worksheet_write_string( ws1, 10, 14, 'Х', block_gray )
  worksheet_write_formula( ws1, 10, 15, '=P12+P14', block_Total )
  worksheet_write_formula( ws1, 10, 16, '=Q12+Q14', block_Total )
  worksheet_write_formula( ws1, 10, 17, '=R12+R14', block_Total )
  worksheet_write_formula( ws1, 10, 18, '=S12+S14', block_Total )
  worksheet_write_formula( ws1, 10, 19, '=T12+T14', block_Total )
  worksheet_write_formula( ws1, 10, 20, '=U12+U14', block_Total )
  worksheet_write_formula( ws1, 10, 21, '=V12+V14', block_Total )
  worksheet_write_formula( ws1, 10, 22, '=W12+W14', block_Total )
  worksheet_write_formula( ws1, 10, 23, '=X12+X14', block_Total )
  worksheet_write_formula( ws1, 10, 24, '=Y12+Y14', block_Total )
  worksheet_write_formula( ws1, 10, 25, '=Z12+Z14', block_Total )
  worksheet_write_formula( ws1, 10, 26, '=AA12+AA14', block_Total )
  
  // занесем собранные данные
  for i := 11 to 15
    worksheet_write_number( ws1, i, 8, arr_PO[ i - 9, 2 ], block_empty )
    worksheet_write_number( ws1, i, 9, arr_PO[ i - 9, 3 ], block_empty )
    worksheet_write_number( ws1, i, 10, arr_PO[ i - 9, 4 ], block_empty )
    worksheet_write_number( ws1, i, 11, arr_PO[ i - 9, 5 ], block_empty )
    worksheet_write_number( ws1, i, 12, arr_PO[ i - 9, 6 ], block_empty )
    worksheet_write_string( ws1, i, 13, 'Х', block_gray )
    worksheet_write_string( ws1, i, 14, 'Х', block_gray )
    worksheet_write_number( ws1, i, 15, arr_PO[ i - 9, 7 ], block_empty )
    worksheet_write_number( ws1, i, 16, arr_PO[ i - 9, 8 ], block_empty )
    worksheet_write_number( ws1, i, 17, arr_PO[ i - 9, 9 ], block_empty )
    worksheet_write_number( ws1, i, 18, arr_PO[ i - 9, 10 ], block_empty )
    if i != 12
      worksheet_write_number( ws1, i, 19, arr_PO[ i - 9, 11 ], block_empty )
      worksheet_write_number( ws1, i, 20, arr_PO[ i - 9, 12 ], block_empty )
      worksheet_write_number( ws1, i, 21, arr_PO[ i - 9, 13 ], block_empty )
      worksheet_write_number( ws1, i, 22, arr_PO[ i - 9, 14 ], block_empty )
    else
      worksheet_write_string( ws1, i, 19, 'Х', block_gray )
      worksheet_write_string( ws1, i, 20, 'Х', block_gray )
      worksheet_write_string( ws1, i, 21, 'Х', block_gray )
      worksheet_write_string( ws1, i, 22, 'Х', block_gray )
    endif
    worksheet_write_number( ws1, i, 23, arr_PO[ i - 9, 15 ], block_empty )
    worksheet_write_number( ws1, i, 24, arr_PO[ i - 9, 16 ], block_empty )
    worksheet_write_number( ws1, i, 25, arr_PO[ i - 9, 17 ], block_empty )
    worksheet_write_number( ws1, i, 26, arr_PO[ i - 9, 18 ], block_empty )
  next

  worksheet_write_string( ws1, 11, 0, '1', text_thin )
  worksheet_write_string( ws1, 11, 1, 'дети в возрасте 0-14 лет вкл', text_thin )
  worksheet_write_string( ws1, 11, 2, '', block_empty )
  worksheet_write_string( ws1, 11, 3, '', block_empty )
  worksheet_write_number( ws1, 11, 4, arr_plan[ 3 ], block_empty )
  worksheet_write_string( ws1, 11, 5, '', block_empty )
  worksheet_write_string( ws1, 11, 6, '', block_empty )
  worksheet_write_formula( ws1, 11, 7, '=K12+L12+M12+P12+R12', block_Total )

  worksheet_write_string( ws1, 12, 0, '2', text_thin )
  worksheet_write_string( ws1, 12, 1, 'из них дети до 1 года', text_thin )
  worksheet_write_string( ws1, 12, 2, '', block_empty )
  worksheet_write_string( ws1, 12, 3, '', block_empty )
  worksheet_write_string( ws1, 12, 4, '', block_empty )
  worksheet_write_string( ws1, 12, 5, '', block_empty )
  worksheet_write_string( ws1, 12, 6, '', block_empty )
  worksheet_write_formula( ws1, 12, 7, '=K13+L13+M13+P13+R13', block_Total )

  worksheet_write_string( ws1, 13, 0, '3', text_thin )
  worksheet_write_string( ws1, 13, 1, 'дети 15-17 лет вкл', text_thin )
  worksheet_write_string( ws1, 13, 2, '', block_empty )
  worksheet_write_string( ws1, 13, 3, '', block_empty )
  worksheet_write_number( ws1, 13, 4, arr_plan[ 4 ], block_empty )
  worksheet_write_string( ws1, 13, 5, '', block_empty )
  worksheet_write_string( ws1, 13, 6, '', block_empty )
  worksheet_write_formula( ws1, 13, 7, '=K14+L14+M14+P14+R14', block_Total )

  worksheet_write_string( ws1, 14, 0, '4', text_thin )
  worksheet_write_string( ws1, 14, 1, 'из общего числа детей 15-17 лет(ст.03)-юношей', text_thin )
  worksheet_write_string( ws1, 14, 2, '', block_empty )
  worksheet_write_string( ws1, 14, 3, '', block_empty )
  worksheet_write_number( ws1, 14, 4, arr_plan[ 5 ], block_empty )
  worksheet_write_string( ws1, 14, 5, '', block_empty )
  worksheet_write_string( ws1, 14, 6, '', block_empty )
  worksheet_write_formula( ws1, 14, 7, '=K15+L15+M15+P15+R15', block_Total )

  worksheet_write_string( ws1, 15, 0, '5', text_thin )
  worksheet_write_string( ws1, 15, 1, 'школьники (из суммы стр.1+3)', text_thin )
  worksheet_write_string( ws1, 15, 2, '', block_empty )
  worksheet_write_string( ws1, 15, 3, '', block_empty )
  worksheet_write_string( ws1, 15, 4, '', block_empty )
  worksheet_write_string( ws1, 15, 5, '', block_empty )
  worksheet_write_string( ws1, 15, 6, '', block_empty )
  worksheet_write_formula( ws1, 15, 7, '=K16+L16+M16+P16+R16', block_Total )

  worksheet_write_number( ws1, 16, 6, arr_plan[ 6 ], block_empty )
  worksheet_write_formula( ws1, 16, 7, '=H12+H14', block_Total )
  worksheet_write_formula( ws1, 16, 22, '=T11+U11+V11+W11', block_Total )

  worksheet_merge_range( ws1, 20, 2, 20, 3, 'Ф.И.О. главного врача', block_FIO )
  worksheet_merge_range( ws1, 20, 4, 20, 6, '', block_FIO )
  worksheet_merge_range( ws1, 21, 2, 21, 3, 'Ф.И.О. исполнителя', block_FIO )
  worksheet_merge_range( ws1, 21, 4, 21, 6, '', block_FIO )
  worksheet_merge_range( ws1, 22, 2, 22, 3, 'телефон исполнителя', block_FIO )
  worksheet_merge_range( ws1, 22, 4, 22, 6, '', block_FIO )

  worksheet_write_string( ws1, 24, 0, '№ стр.', titul_table_thin )
  worksheet_write_string( ws1, 24, 1, 'таб. 2510', titul_table_thin )
  worksheet_write_string( ws1, 24, 2, 'подлежало осмотрам', titul_table_thin )
  worksheet_write_string( ws1, 24, 3, 'из них: сельских жителей', titul_table_thin )
  worksheet_write_string( ws1, 24, 4, 'осмотрено', titul_table_thin )
  worksheet_write_string( ws1, 24, 5, 'из них: сельских жителей', titul_table_thin )
  worksheet_write_string( ws1, 24, 6, 'из числа осмотренных (гр.5) определены группы здоровья - I', titul_table_thin )
  worksheet_write_string( ws1, 24, 7, 'из числа осмотренных (гр.5) определены группы здоровья - II', titul_table_thin )
  worksheet_write_string( ws1, 24, 8, 'из числа осмотренных (гр.5) определены группы здоровья - III', titul_table_thin )
  worksheet_write_string( ws1, 24, 9, 'из них: III А', titul_table_thin )
  worksheet_write_string( ws1, 24, 10, 'из них: III Б', titul_table_thin )
  worksheet_write_string( ws1, 24, 11, 'из числа осмотренных (гр. 5) определены группы здоровья - IV', titul_table_thin )
  worksheet_write_string( ws1, 24, 12, 'из числа осмотренных (гр. 5) определены группы здоровья - V', titul_table_thin )

  worksheet_write_string( ws1, 25, 0, '', titul_table_thin )
  worksheet_write_string( ws1, 25, 1, 'Профосмотры', titul_table_thin )
  worksheet_write_string( ws1, 25, 2, '3', titul_table_thin )
  worksheet_write_string( ws1, 25, 3, '4', titul_table_thin )
  worksheet_write_string( ws1, 25, 4, '5', titul_table_thin )
  worksheet_write_string( ws1, 25, 5, '6', titul_table_thin )
  worksheet_write_string( ws1, 25, 6, '7', titul_table_thin )
  worksheet_write_string( ws1, 25, 7, '8', titul_table_thin )
  worksheet_write_string( ws1, 25, 8, '9', titul_table_thin )
  worksheet_write_string( ws1, 25, 9, '10', titul_table_thin )
  worksheet_write_string( ws1, 25, 10, '11', titul_table_thin )
  worksheet_write_string( ws1, 25, 11, '12', titul_table_thin )
  worksheet_write_string( ws1, 25, 12, '13', titul_table_thin )

  worksheet_write_string( ws1, 26, 0, '1', text_thin )
  worksheet_write_string( ws1, 26, 1, 'дети в возрасте 0-14 лет вкл', text_thin )
  worksheet_write_formula( ws1, 26, 2, '=E12', block_Total )
  worksheet_write_formula( ws1, 26, 3, '=F12', block_Total )
  worksheet_write_formula( ws1, 26, 4, '=H12', block_Total )
  worksheet_write_formula( ws1, 26, 5, '=I12', block_Total )
  worksheet_write_formula( ws1, 26, 6, '=K12', block_Total )
  worksheet_write_formula( ws1, 26, 7, '=L12', block_Total )
  worksheet_write_formula( ws1, 26, 8, '=M12', block_Total )
  worksheet_write_string( ws1, 26, 9, 'Х', titul_table_thin )
  worksheet_write_string( ws1, 26, 10, 'Х', titul_table_thin )
  worksheet_write_formula( ws1, 26, 11, '=P12', block_Total )
  worksheet_write_formula( ws1, 26, 12, '=R12', block_Total )

  worksheet_write_string( ws1, 27, 0, '2', text_thin )
  worksheet_write_string( ws1, 27, 1, 'из них дети до 1 года', text_thin )
  worksheet_write_formula( ws1, 27, 2, '=E13', block_Total )
  worksheet_write_formula( ws1, 27, 3, '=F13', block_Total )
  worksheet_write_formula( ws1, 27, 4, '=H13', block_Total )
  worksheet_write_formula( ws1, 27, 5, '=I13', block_Total )
  worksheet_write_formula( ws1, 27, 6, '=K13', block_Total )
  worksheet_write_formula( ws1, 27, 7, '=L13', block_Total )
  worksheet_write_formula( ws1, 27, 8, '=M13', block_Total )
  worksheet_write_string( ws1, 27, 9, 'Х', titul_table_thin )
  worksheet_write_string( ws1, 27, 10, 'Х', titul_table_thin )
  worksheet_write_formula( ws1, 27, 11, '=P13', block_Total )
  worksheet_write_formula( ws1, 27, 12, '=R13', block_Total )

  worksheet_write_string( ws1, 28, 0, '3', text_thin )
  worksheet_write_string( ws1, 28, 1, 'дети 15-17 лет вкл', text_thin )
  worksheet_write_formula( ws1, 28, 2, '=E14', block_Total )
  worksheet_write_formula( ws1, 28, 3, '=F14', block_Total )
  worksheet_write_formula( ws1, 28, 4, '=H14', block_Total )
  worksheet_write_formula( ws1, 28, 5, '=I14', block_Total )
  worksheet_write_formula( ws1, 28, 6, '=K14', block_Total )
  worksheet_write_formula( ws1, 28, 7, '=L14', block_Total )
  worksheet_write_formula( ws1, 28, 8, '=M14', block_Total )
  worksheet_write_string( ws1, 28, 9, 'Х', titul_table_thin )
  worksheet_write_string( ws1, 28, 10, 'Х', titul_table_thin )
  worksheet_write_formula( ws1, 28, 11, '=P14', block_Total )
  worksheet_write_formula( ws1, 28, 12, '=R14', block_Total )

  worksheet_write_string( ws1, 29, 0, '4', text_thin )
  worksheet_write_string( ws1, 29, 1, 'из общего числа детей 15-17 лет(ст.03)-юношей', text_thin )
  worksheet_write_formula( ws1, 29, 2, '=E15', block_Total )
  worksheet_write_formula( ws1, 29, 3, '=F15', block_Total )
  worksheet_write_formula( ws1, 29, 4, '=H15', block_Total )
  worksheet_write_formula( ws1, 29, 5, '=I15', block_Total )
  worksheet_write_formula( ws1, 29, 6, '=K15', block_Total )
  worksheet_write_formula( ws1, 29, 7, '=L15', block_Total )
  worksheet_write_formula( ws1, 29, 8, '=M15', block_Total )
  worksheet_write_string( ws1, 29, 9, 'Х', titul_table_thin )
  worksheet_write_string( ws1, 29, 10, 'Х', titul_table_thin )
  worksheet_write_formula( ws1, 29, 11, '=P15', block_Total )
  worksheet_write_formula( ws1, 29, 12, '=R15', block_Total )

  worksheet_write_string( ws1, 30, 0, '5', text_thin )
  worksheet_write_string( ws1, 30, 1, 'школьники (из суммы стр.1+3)', text_thin )
  worksheet_write_formula( ws1, 30, 2, '=E16', block_Total )
  worksheet_write_formula( ws1, 30, 3, '=F16', block_Total )
  worksheet_write_formula( ws1, 30, 4, '=H16', block_Total )
  worksheet_write_formula( ws1, 30, 5, '=I16', block_Total )
  worksheet_write_formula( ws1, 30, 6, '=K16', block_Total )
  worksheet_write_formula( ws1, 30, 7, '=L16', block_Total )
  worksheet_write_formula( ws1, 30, 8, '=M16', block_Total )
  worksheet_write_string( ws1, 30, 9, 'Х', titul_table_thin )
  worksheet_write_string( ws1, 30, 10, 'Х', titul_table_thin )
  worksheet_write_formula( ws1, 30, 11, '=P16', block_Total )
  worksheet_write_formula( ws1, 30, 12, '=R16', block_Total )

//
// лист 2 - 15-17 лет
//
  ws2 := workbook_add_worksheet( workbook, '15-17 лет' )
  /* Установить ширину колонок */
  for i := 0 to 15
    worksheet_set_column( ws2, i, i, 15.89 )
  next

  worksheet_set_tab_color( ws2, cColorTab2 )
  worksheet_write_string( ws2, 0, 8, 'ПРИЛОЖЕНИЕ 6', nil )
  worksheet_write_string( ws2, 1, 8, 'к приказу комитета здравоохранения', nil )
  worksheet_write_string( ws2, 2, 8, 'Волгоградской области', nil )
  worksheet_write_string( ws2, 3, 8, 'от _____ № ______', nil )

  worksheet_merge_range( ws2, 5, 0, 5, 8, 'Информация об охваченных профилактическими осмотрами несовершеннолетних в возрасте 15-17 лет', header_bold )
  worksheet_merge_range( ws2, 6, 4, 6, 5, 'по состоянию на', header_bold_sost )
  worksheet_write_number( ws2, 6, 6, Day( arr_m[ 6 ] ), header_bold_sost )
  worksheet_write_string( ws2, 6, 7, hb_StrToUTF8( Lower( CMonth( arr_m[ 6 ] ) ) ), header_bold_sost )
  worksheet_write_number( ws2, 6, 8, Year( arr_m[ 6 ] ), header_bold_sost )
  worksheet_merge_range( ws2, 8, 0, 8, 8, strMO, titul_bold_center )

  worksheet_merge_range( ws2, 10, 0, 10, 10, 'ЮНОШИ (15-17 лет)', nil )
  worksheet_merge_range( ws2, 11, 0, 12, 0, 'План (чел.)', titul_table_bold )
  worksheet_merge_range( ws2, 11, 1, 12, 1, 'Из них сельских жителей (чел.)', titul_table_bold )
  worksheet_merge_range( ws2, 11, 2, 11, 6, 'Факт осмотренных', titul_table_bold )
  worksheet_write_string( ws2, 12, 2, 'всего (чел.)', titul_table_bold )
  worksheet_write_string( ws2, 12, 3, 'из них сельских жителей (чел.)', titul_table_bold )
  worksheet_write_string( ws2, 12, 4, 'Число посещений (из графы 3*)', titul_table_bold )
  worksheet_write_string( ws2, 12, 5, 'из них сельских жителей (чел.) из гр.5', titul_table_bold )
  worksheet_write_string( ws2, 12, 6, 'осмотрено врачом андрологом-урологом (чел. из гр.3)', titul_table_bold )
  worksheet_merge_range( ws2, 11, 7, 12, 7, 'Кол-во детей с выявленной паталогией органов репродуктивной системы (чел.) из гр.6', titul_table_bold )
  worksheet_merge_range( ws2, 11, 8, 12, 8, 'из них сельских жителей (чел.) из гр.7', titul_table_bold )
  worksheet_merge_range( ws2, 11, 9, 12, 9, 'Из них впервые (чел.) из гр.7', titul_table_bold )
  worksheet_merge_range( ws2, 11, 10, 12, 10, 'из них сельских жителей (чел.) из гр.7.2', titul_table_bold )
  worksheet_merge_range( ws2, 11, 11, 12, 11, 'Кол-во детей направленных на 2 этап для дообследования (чел.) из гр.7.2', titul_table_bold )
  worksheet_merge_range( ws2, 11, 12, 11, 13, 'Направлено на лечение из гр.7', titul_table_bold )

  worksheet_write_string( ws2, 12, 12, 'всего (чел.)', titul_table_bold )
  worksheet_write_string( ws2, 12, 13, 'из них сельских жителей (чел.)', titul_table_bold )

  worksheet_merge_range( ws2, 11, 14, 11, 15, 'Пролечено гр.7', titul_table_bold )
  worksheet_write_string( ws2, 12, 14, 'всего (чел.)', titul_table_bold )
  worksheet_write_string( ws2, 12, 15, 'из них сельских жителей (чел.)', titul_table_bold )

  worksheet_write_string( ws2, 13, 0, '1', titul_table_thin )
  worksheet_write_string( ws2, 13, 1, '2', titul_table_thin )
  worksheet_write_string( ws2, 13, 2, '3', titul_table_thin )
  worksheet_write_string( ws2, 13, 3, '4', titul_table_thin )
  worksheet_write_string( ws2, 13, 4, '5', titul_table_thin )
  worksheet_write_string( ws2, 13, 5, '5.1', titul_table_thin )
  worksheet_write_string( ws2, 13, 6, '6', titul_table_thin )
  worksheet_write_string( ws2, 13, 7, '7', titul_table_thin )
  worksheet_write_string( ws2, 13, 8, '7.1', titul_table_thin )
  worksheet_write_string( ws2, 13, 9, '7.2', titul_table_thin )
  worksheet_write_string( ws2, 13, 10, '7.3', titul_table_thin )
  worksheet_write_string( ws2, 13, 11, '8', titul_table_thin )
  worksheet_write_string( ws2, 13, 12, '9', titul_table_thin )
  worksheet_write_string( ws2, 13, 13, '9.1', titul_table_thin )
  worksheet_write_string( ws2, 13, 14, '10', titul_table_thin )
  worksheet_write_string( ws2, 13, 15, '10.1', titul_table_thin )

  worksheet_write_formula( ws2, 14, 0, '=профосмотры!E15', block_Total )
  worksheet_write_formula( ws2, 14, 1, '=профосмотры!F15', block_Total )
  worksheet_write_formula( ws2, 14, 2, '=профосмотры!H15', block_Total )
  worksheet_write_formula( ws2, 14, 3, '=профосмотры!I15', block_Total )
  worksheet_write_number( ws2, 14, 4, arr_15_17[ 1, 3 ], block_empty )
  worksheet_write_number( ws2, 14, 5, arr_15_17[ 1, 4 ], block_empty )
  worksheet_write_formula( ws2, 14, 6, '=C15', block_Total )
  worksheet_write_number( ws2, 14, 7, arr_15_17[ 1, 6 ], block_empty )
  worksheet_write_number( ws2, 14, 8, arr_15_17[ 1, 7 ], block_empty )
  worksheet_write_number( ws2, 14, 9, arr_15_17[ 1, 8 ], block_empty )
  worksheet_write_number( ws2, 14, 10, arr_15_17[ 1, 9 ], block_empty )
  worksheet_write_number( ws2, 14, 11, arr_15_17[ 1, 10 ], block_empty )
  worksheet_write_number( ws2, 14, 12, arr_15_17[ 1, 11 ], block_empty )
  worksheet_write_number( ws2, 14, 13, arr_15_17[ 1, 12 ], block_empty )
  worksheet_write_string( ws2, 14, 14, '', block_empty )
  worksheet_write_string( ws2, 14, 15, '', block_empty )

  worksheet_merge_range( ws2, 16, 0, 16, 10, 'ДЕВУШКИ (15-17 лет', nil )

  worksheet_merge_range( ws2, 17, 0, 18, 0, 'План (чел.)', titul_table_bold )
  worksheet_merge_range( ws2, 17, 1, 18, 1, 'Из них сельских жителей (чел.)', titul_table_bold )
  worksheet_merge_range( ws2, 17, 2, 17, 6, 'Факт осмотренных', titul_table_bold )
  worksheet_write_string( ws2, 18, 2, 'всего (чел.)', titul_table_bold )
  worksheet_write_string( ws2, 18, 3, 'из них сельских жителей (чел.)', titul_table_bold )
  worksheet_write_string( ws2, 18, 4, 'Число посещений (из графы 3*)', titul_table_bold )
  worksheet_write_string( ws2, 18, 5, 'из них сельских жителей (чел.) из гр.11', titul_table_bold )
  worksheet_write_string( ws2, 18, 6, 'осмотрено врачом акушером-гинекологом (чел. из гр.11)', titul_table_bold )
  worksheet_merge_range( ws2, 17, 7, 18, 7, 'Кол-во детей с выявленной паталогией органов репродуктивной системы (чел.) из гр.11', titul_table_bold )
  worksheet_merge_range( ws2, 17, 8, 18, 8, 'из них сельских жителей (чел.) из гр.14', titul_table_bold )
  worksheet_merge_range( ws2, 17, 9, 18, 9, 'Из них впервые (чел.) из гр.14', titul_table_bold )
  worksheet_merge_range( ws2, 17, 10, 18, 10, 'из них сельских жителей (чел.) из гр.14.2', titul_table_bold )
  worksheet_merge_range( ws2, 17, 11, 18, 11, 'Кол-во детей направленных на 2 этап для дообследования (чел.) из гр.14.2', titul_table_bold )
  worksheet_merge_range( ws2, 17, 12, 17, 13, 'Направлено на лечение из гр.16.2', titul_table_bold )
  worksheet_write_string( ws2, 18, 12, 'всего (чел.)', titul_table_bold )
  worksheet_write_string( ws2, 18, 13, 'из них сельских жителей (чел.)', titul_table_bold )
  worksheet_merge_range( ws2, 17, 14, 17, 15, 'Пролечено гр.7', titul_table_bold )
  worksheet_write_string( ws2, 18, 14, 'всего (чел.)', titul_table_bold )
  worksheet_write_string( ws2, 18, 15, 'из них сельских жителей (чел.)', titul_table_bold )

  worksheet_write_string( ws2, 19, 0, '11', titul_table_thin )
  worksheet_write_string( ws2, 19, 1, '12', titul_table_thin )
  worksheet_write_string( ws2, 19, 2, '13', titul_table_thin )
  worksheet_write_string( ws2, 19, 3, '13.1', titul_table_thin )
  worksheet_write_string( ws2, 19, 4, '14', titul_table_thin )
  worksheet_write_string( ws2, 19, 5, '14.1', titul_table_thin )
  worksheet_write_string( ws2, 19, 6, '15', titul_table_thin )
  worksheet_write_string( ws2, 19, 7, '16', titul_table_thin )
  worksheet_write_string( ws2, 19, 8, '16.1', titul_table_thin )
  worksheet_write_string( ws2, 19, 9, '16.2', titul_table_thin )
  worksheet_write_string( ws2, 19, 10, '16.3', titul_table_thin )
  worksheet_write_string( ws2, 19, 11, '17', titul_table_thin )
  worksheet_write_string( ws2, 19, 12, '18', titul_table_thin )
  worksheet_write_string( ws2, 19, 13, '18.1', titul_table_thin )
  worksheet_write_string( ws2, 19, 14, '19', titul_table_thin )
  worksheet_write_string( ws2, 19, 15, '19.1', titul_table_thin )

  worksheet_write_formula( ws2, 20, 0, '=профосмотры!E14-профосмотры!E15', block_Total )
  worksheet_write_formula( ws2, 20, 1, '=профосмотры!F14-профосмотры!F15', block_Total )
  worksheet_write_formula( ws2, 20, 2, '=профосмотры!H14-профосмотры!H15', block_Total )
  worksheet_write_formula( ws2, 20, 3, '=профосмотры!I14-профосмотры!I15', block_Total )
  worksheet_write_number( ws2, 20, 4, arr_15_17[ 2, 3 ], block_empty )
  worksheet_write_number( ws2, 20, 5, arr_15_17[ 2, 4 ], block_empty )
  worksheet_write_formula( ws2, 20, 6, '=C21', block_Total )
  worksheet_write_number( ws2, 20, 7, arr_15_17[ 2, 6 ], block_empty )
  worksheet_write_number( ws2, 20, 8, arr_15_17[ 2, 7 ], block_empty )
  worksheet_write_number( ws2, 20, 9, arr_15_17[ 2, 8 ], block_empty )
  worksheet_write_number( ws2, 20, 10, arr_15_17[ 2, 9 ], block_empty )
  worksheet_write_number( ws2, 20, 11, arr_15_17[ 2, 10 ], block_empty )
  worksheet_write_number( ws2, 20, 12, arr_15_17[ 2, 11 ], block_empty )
  worksheet_write_number( ws2, 20, 13, arr_15_17[ 2, 12 ], block_empty )
  worksheet_write_string( ws2, 20, 14, '', block_empty )
  worksheet_write_string( ws2, 20, 15, '', block_empty )

  worksheet_merge_range( ws2, 21, 0, 21, 3, '*число посещений это число осмотов специалистами', titul_table_bold )


  worksheet_write_string( ws2, 27, 0, '', titul_table_bold )
  worksheet_write_string( ws2, 28, 0, 'таб. 2511 ПО', titul_table_bold )
  worksheet_merge_range( ws2, 27, 1, 27, 2, 'подлежало осмотрам', titul_table_bold )
  worksheet_write_string( ws2, 28, 1, 'всего', titul_table_bold )
  worksheet_write_string( ws2, 28, 2, 'из них: сельских жителей', titul_table_bold )
  worksheet_merge_range( ws2, 27, 3, 27, 4, 'осмотрено', titul_table_bold )
  worksheet_write_string( ws2, 28, 3, 'всего', titul_table_bold )
  worksheet_write_string( ws2, 28, 4, 'из них: сельских жителей', titul_table_bold )
  worksheet_merge_range( ws2, 27, 5, 27, 6, 'выявлена патология', titul_table_bold )
  worksheet_write_string( ws2, 28, 5, 'всего', titul_table_bold )
  worksheet_write_string( ws2, 28, 6, 'из них: сельских жителей', titul_table_bold )
  worksheet_merge_range( ws2, 27, 7, 27, 8, 'Направлено на лечение', titul_table_bold )
  worksheet_write_string( ws2, 28, 7, 'всего', titul_table_bold )
  worksheet_write_string( ws2, 28, 8, 'из них: сельских жителей', titul_table_bold )
  worksheet_merge_range( ws2, 27, 9, 27, 10, 'Пролечено', titul_table_bold )
  worksheet_write_string( ws2, 28, 9, 'всего', titul_table_bold )
  worksheet_write_string( ws2, 28, 10, 'из них: сельских жителей', titul_table_bold )

  worksheet_write_string( ws2, 29, 0, '', titul_table_thin )
  worksheet_write_string( ws2, 29, 1, '3', titul_table_thin )
  worksheet_write_string( ws2, 29, 2, '4', titul_table_thin )
  worksheet_write_string( ws2, 29, 3, '5', titul_table_thin )
  worksheet_write_string( ws2, 29, 4, '6', titul_table_thin )
  worksheet_write_string( ws2, 29, 5, '7', titul_table_thin )
  worksheet_write_string( ws2, 29, 6, '8', titul_table_thin )
  worksheet_write_string( ws2, 29, 7, '9', titul_table_thin )
  worksheet_write_string( ws2, 29, 8, '10', titul_table_thin )
  worksheet_write_string( ws2, 29, 9, '11', titul_table_thin )
  worksheet_write_string( ws2, 29, 10, '12', titul_table_thin )

  worksheet_write_string( ws2, 30, 0, 'осмотрено пациентов всего', titul_table_bold )
  worksheet_write_formula( ws2, 30, 1, '=B32+B33', block_Total )
  worksheet_write_formula( ws2, 30, 2, '=C32+C33', block_Total )
  worksheet_write_formula( ws2, 30, 3, '=D32+D33', block_Total )
  worksheet_write_formula( ws2, 30, 4, '=E32+E33', block_Total )
  worksheet_write_formula( ws2, 30, 5, '=F32+F33', block_Total )
  worksheet_write_formula( ws2, 30, 6, '=G32+G33', block_Total )
  worksheet_write_formula( ws2, 30, 7, '=H32+H33', block_Total )
  worksheet_write_formula( ws2, 30, 8, '=I32+I33', block_Total )
  worksheet_write_formula( ws2, 30, 9, '=J32+J33', block_Total )
  worksheet_write_formula( ws2, 30, 10, '=K32+K33', block_Total )

  worksheet_write_string( ws2, 31, 0, 'из них мальчиков(урологом-андрологом)', text_thin )
  worksheet_write_formula( ws2, 31, 1, '=A15', block_Total )
  worksheet_write_formula( ws2, 31, 2, '=B15', block_Total )
  worksheet_write_formula( ws2, 31, 3, '=C15', block_Total )
  worksheet_write_formula( ws2, 31, 4, '=D15', block_Total )
  worksheet_write_formula( ws2, 31, 5, '=H15', block_Total )
  worksheet_write_formula( ws2, 31, 6, '=I15', block_Total )
  worksheet_write_formula( ws2, 31, 7, '=M15', block_Total )
  worksheet_write_formula( ws2, 31, 8, '=N15', block_Total )
  worksheet_write_formula( ws2, 31, 9, '=O15', block_Total )
  worksheet_write_formula( ws2, 31, 10, '=P15', block_Total )

  worksheet_write_string( ws2, 32, 0, 'девочек(акушером-гинекологом)', text_thin )
  worksheet_write_formula( ws2, 32, 1, '=A21', block_Total )
  worksheet_write_formula( ws2, 32, 2, '=B21', block_Total )
  worksheet_write_formula( ws2, 32, 3, '=C21', block_Total )
  worksheet_write_formula( ws2, 32, 4, '=D21', block_Total )
  worksheet_write_formula( ws2, 32, 5, '=H21', block_Total )
  worksheet_write_formula( ws2, 32, 6, '=I21', block_Total )
  worksheet_write_formula( ws2, 32, 7, '=M21', block_Total )
  worksheet_write_formula( ws2, 32, 8, '=N21', block_Total )
  worksheet_write_formula( ws2, 32, 9, '=O21', block_Total )
  worksheet_write_formula( ws2, 32, 10, '=P21', block_Total )

//
// лист 3 - Нац.проект "Здравоохранение"
//
  ws3 := workbook_add_worksheet( workbook, 'Нац.проект "Здравоохранение"' )
  worksheet_set_tab_color( ws3, cColorTab3 )
  /* Установить высоту строки */
  worksheet_set_row( ws3, 1, 42.6 )
  worksheet_set_row( ws3, 7, 160.2 )
  /* Установить ширину колонок */
  worksheet_set_column( ws3, 0, 0, 41 )
  for i := 1 to 21
    worksheet_set_column( ws3, i, i, 13.0 )
  next

  worksheet_merge_range( ws3, 1, 0, 1, 6, 'Сведения о профилактических осмотрах несовершеннолетних в рамках национального проекта "Здравоохранение"', header_bold )
  worksheet_merge_range( ws3, 2, 3, 2, 4, 'по состоянию на', header_bold_sost )
  worksheet_write_number( ws3, 2, 5, Day( arr_m[ 6 ] ), header_bold_sost )
  worksheet_write_string( ws3, 2, 6, hb_StrToUTF8( Lower( CMonth( arr_m[ 6 ] ) ) ), header_bold_sost )
  worksheet_write_number( ws3, 2, 7, Year( arr_m[ 6 ] ), header_bold_sost )
  worksheet_merge_range( ws3, 4, 0, 4, 4, strMO, titul_bold_center )

  worksheet_merge_range( ws3, 6, 0, 7, 0, '', titul_table_bold )
  worksheet_merge_range( ws3, 6, 1, 6, 3, 'Осмотрено (завершено)', titul_table_bold )
  worksheet_write_string( ws3, 7, 1, 'всего', titul_table_bold )
  worksheet_write_string( ws3, 7, 2, 'в вечернее время (после 18:00)', titul_table_bold )
  worksheet_write_string( ws3, 7, 3, 'в субботу', titul_table_bold )
  worksheet_merge_range( ws3, 6, 4, 6, 6, 'из них сельских жителей', titul_table_bold )
  worksheet_write_string( ws3, 7, 4, 'всего', titul_table_bold )
  worksheet_write_string( ws3, 7, 5, 'в вечернее время (после 18:00)', titul_table_bold )
  worksheet_write_string( ws3, 7, 6, 'в субботу', titul_table_bold )
  worksheet_merge_range( ws3, 6, 7, 7, 7, 'Осмотрено урологом-андрологом', titul_table_bold )
  worksheet_merge_range( ws3, 6, 8, 7, 8, 'Осмотрено акушером-гинекологом', titul_table_bold )
  worksheet_merge_range( ws3, 6, 9, 7, 9, 'Число несовершеннолетних, у которых в ходе осмотров и диспансеризации впервые выявлены неинфекционные заболевания', titul_table_bold )
  worksheet_merge_range( ws3, 6, 10, 6, 17, 'В том числе', titul_table_bold )
  worksheet_write_string( ws3, 7, 10, 'болезни системы кровообращения', titul_table_bold )
  worksheet_write_string( ws3, 7, 11, 'злокачественные новообразования', titul_table_bold )
  worksheet_write_string( ws3, 7, 12, 'в том числе в I и II стадиях (из гр. 11)', titul_table_bold )
  worksheet_write_string( ws3, 7, 13, 'болезни костно-мыщечной системы, расстройств питания и соединительной ткани', titul_table_bold )
  worksheet_write_string( ws3, 7, 14, 'болезни глаза и его придаточного аппарата', titul_table_bold )
  worksheet_write_string( ws3, 7, 15, 'болезни эндокринной системы, расстройств питания и нарушения обмена веществ', titul_table_bold )
  worksheet_write_string( ws3, 7, 16, 'хронические заболевания органов дыхания', titul_table_bold )
  worksheet_write_string( ws3, 7, 17, 'болезни органов пищеварения', titul_table_bold )
  worksheet_merge_range( ws3, 6, 18, 7, 18, 'Число граждан, у которых в ходе осмотров и диспансеризации впервые выявлены факторы риска', titul_table_bold_green )
  worksheet_merge_range( ws3, 6, 19, 7, 19, 'Из числа граждан, у которых выявлены неинфексционные заболевания (из гр.9), взятые на диспансерное наблюдение', titul_table_bold )
  worksheet_merge_range( ws3, 6, 20, 7, 20, 'Из числа граждан, у которых выявлены неинфексционные заболевания (из гр.9), было начато лечение', titul_table_bold )
  worksheet_merge_range( ws3, 6, 21, 7, 21, 'из них сельских жителей (из гр.20)', titul_table_bold )

  for i := 0 to 21
    worksheet_write_string( ws3, 8, i, iif( i == 0, '', str( i, 2 ) ), titul_table_thin )
  next
  worksheet_write_string( ws3, 9, 0, 'Дети в возрасте 0 - 14 лет включительно', titul_table_bold )
  worksheet_write_formula( ws3, 9, 1, '=профосмотры!H12', block_Total )
  worksheet_write_number( ws3, 9, 2, arr_NP[ 1, 1 ], block_empty )
  worksheet_write_number( ws3, 9, 3, arr_NP[ 1, 2 ], block_empty )
  worksheet_write_formula( ws3, 9, 4, '=профосмотры!I12', block_Total )
  worksheet_write_number( ws3, 9, 5, arr_NP[ 1, 3 ], block_empty )
  worksheet_write_number( ws3, 9, 6, arr_NP[ 1, 4 ], block_empty )
  worksheet_write_number( ws3, 9, 7, arr_NP[ 1, 5 ], block_empty )
  worksheet_write_number( ws3, 9, 8, arr_NP[ 1, 6 ], block_empty )
  for i := 9 to 21
    if i == 11 .or. i == 12
      worksheet_write_number( ws3, 9, i, 0, block_empty )
    else
      worksheet_write_number( ws3, 9, i, arr_NP[ 1, i - 2 ], block_empty )
    endif
  next

  worksheet_write_string( ws3, 10, 0, 'Дети в возрасте 15 - 17 лет включительно', titul_table_bold )
  worksheet_write_formula( ws3, 10, 1, '=профосмотры!H14', block_Total )
  worksheet_write_number( ws3, 10, 2, arr_NP[ 2, 1 ], block_empty )
  worksheet_write_number( ws3, 10, 3, arr_NP[ 2, 2 ], block_empty )
  worksheet_write_formula( ws3, 10, 4, '=профосмотры!I14', block_Total )
  worksheet_write_number( ws3, 10, 5, arr_NP[ 2, 3 ], block_empty )
  worksheet_write_number( ws3, 10, 6, arr_NP[ 2, 4 ], block_empty )
  worksheet_write_formula( ws3, 10, 7, "='15-17 лет'!G15", block_Total )
  worksheet_write_formula( ws3, 10, 8, "='15-17 лет'!G21", block_Total )
  for i := 9 to 21
    if i == 11 .or. i == 12
      worksheet_write_number( ws3, 10, i, 0, block_empty )
    else
      worksheet_write_number( ws3, 10, i, arr_NP[ 2, i - 2 ], block_empty )
    endif
  next

  worksheet_merge_range( ws3, 15, 0, 15, 1, 'Ф.И.О. главного врача', block_FIO )
  worksheet_merge_range( ws3, 15, 2, 15, 5, '', block_FIO )
  worksheet_merge_range( ws3, 16, 0, 16, 1, 'Ф.И.О. исполнителя', block_FIO )
  worksheet_merge_range( ws3, 16, 2, 16, 5, '', block_FIO )
  worksheet_merge_range( ws3, 17, 0, 17, 1, 'телефон исполнителя', block_FIO )
  worksheet_merge_range( ws3, 17, 2, 17, 5, '', block_FIO )

  worksheet_set_row( ws3, 12, 27.0 )
  worksheet_set_row( ws3, 19, 29.0 )
  worksheet_set_row( ws3, 20, 29.0 )
  worksheet_set_row( ws3, 21, 43.2 )
  /* Установить ширину колонок */
  worksheet_set_column( ws3, 18, 18, 15.44 )
  worksheet_set_column( ws3, 19, 19, 15.44 )
  worksheet_merge_range( ws3, 12, 18, 12, 19, 'факторы риска по методическим рекомендациям Минздрава', note_titul )
  worksheet_merge_range( ws3, 13, 18, 13, 19, 'Гиперхолестеринемия (E78);', note_text )
  worksheet_merge_range( ws3, 14, 18, 14, 19, 'Гипергликемия (R73.9)', note_text )
  worksheet_merge_range( ws3, 15, 18, 15, 19, 'Курение табака (Z72.0)', note_text )
  worksheet_merge_range( ws3, 16, 18, 16, 19, 'Нерациональное питание (Z72.4)', note_text )
  worksheet_merge_range( ws3, 17, 18, 17, 19, 'Избыточная масса тела (R63.5)', note_text )
  worksheet_merge_range( ws3, 18, 18, 18, 19, 'Дефицит массы тела', note_text )
  worksheet_merge_range( ws3, 19, 18, 19, 19, 'Низкая физическая активность (Z72.3)', note_text )
  worksheet_merge_range( ws3, 20, 18, 20, 19, 'Риск пагубного потребления алкоголя (Z72.1)', note_text )
  worksheet_merge_range( ws3, 21, 18, 21, 19, 'Риск потребления наркотических средств и психотропных веществ без назначения врача (Z72.2)', note_text )

//
// лист 4 - 2510-2511-Дети сироты
//
  ws4 := workbook_add_worksheet( workbook, '2510-2511-Дети сироты' )
  worksheet_set_tab_color( ws4, cColorTab4 )

  /* Установить высоту строки */
  worksheet_set_row( ws4, 5, 84.6 )
  worksheet_set_row( ws4, 13, 84.6 )
  worksheet_set_row( ws4, 22, 84.6 )
  /* Установить ширину колонок */
  worksheet_set_column( ws4, 0, 0, 8.11 )
  worksheet_set_column( ws4, 1, 1, 24.44 )
  for i := 2 to 12
    worksheet_set_column( ws4, i, i, 16.33 )
  next

  worksheet_merge_range( ws4, 0, 3, 0, 10, 'Сведения о диспансеризации детей-сирот', header_bold )
  worksheet_merge_range( ws4, 1, 4, 1, 5, 'по состоянию на', header_bold_sost )
  worksheet_write_number( ws4, 1, 6, Day( arr_m[ 6 ] ), header_bold_sost )
  worksheet_write_string( ws4, 1, 7, hb_StrToUTF8( Lower( CMonth( arr_m[ 6 ] ) ) ), header_bold_sost )
  worksheet_write_number( ws4, 1, 8, Year( arr_m[ 6 ] ), header_bold_sost )
  worksheet_merge_range( ws4, 3, 1, 3, 12, strMO, titul_bold_center )

  worksheet_write_string( ws4, 5, 0, '№ п/п', titul_table_thin )
  worksheet_write_string( ws4, 5, 1, 'таб.2510', titul_table_thin )
  worksheet_write_string( ws4, 5, 2, 'подлежало осмотрам', titul_table_thin )
  worksheet_write_string( ws4, 5, 3, 'из них сельских жителей', titul_table_thin )
  worksheet_write_string( ws4, 5, 4, 'осмотрено', titul_table_thin )
  worksheet_write_string( ws4, 5, 5, 'из них сельских жителей', titul_table_thin )
  worksheet_write_string( ws4, 5, 6, 'из числа осмотренных(гр.5): определены группы здоровья - I', titul_table_thin )
  worksheet_write_string( ws4, 5, 7, 'из числа осмотренных(гр.5): определены группы здоровья - II', titul_table_thin )
  worksheet_write_string( ws4, 5, 8, 'из числа осмотренных(гр.5): определены группы здоровья - III', titul_table_thin )
  worksheet_write_string( ws4, 5, 9, 'из них: III А', titul_table_thin )
  worksheet_write_string( ws4, 5, 10, 'из них: III Б', titul_table_thin )
  worksheet_write_string( ws4, 5, 11, 'из числа осмотренных(гр.5): определены группы здоровья - IV', titul_table_thin )
  worksheet_write_string( ws4, 5, 12, 'из числа осмотренных(гр.5): определены группы здоровья - V', titul_table_thin )
  for i := 0 to 12
    worksheet_write_string( ws4, 6, i, iif( i == 1, 'дети-сироты в стационарных', str( i + 1, 2 ) ), titul_table_thin )
  next
  worksheet_write_string( ws4, 7, 0, '001', text_thin )
  worksheet_write_string( ws4, 7, 1, 'дети в возрасте 0-14 лет включительно', text_thin )
  worksheet_write_number( ws4, 7, 2, 0, block_empty )
  worksheet_write_number( ws4, 7, 3, 0, block_empty )

  worksheet_write_formula( ws4, 7, 4, '=G8+H8+I8+L8+M8', block_Total )
  worksheet_write_number( ws4, 7, 5, 0, block_empty )
  worksheet_write_number( ws4, 7, 6, arr_2510_DDS[ 1, 4 ], block_empty )
  worksheet_write_number( ws4, 7, 7, arr_2510_DDS[ 1, 5 ], block_empty )
  worksheet_write_number( ws4, 7, 8, arr_2510_DDS[ 1, 6 ], block_empty )

  worksheet_write_string( ws4, 7, 9, 'X', block_gray )
  worksheet_write_string( ws4, 7, 10, 'X', block_gray )
  worksheet_write_number( ws4, 7, 11, arr_2510_DDS[ 1, 7 ], block_empty )
  worksheet_write_number( ws4, 7, 12, arr_2510_DDS[ 1, 8 ], block_empty )

  worksheet_write_string( ws4, 8, 0, '002', text_thin )
  worksheet_write_string( ws4, 8, 1, 'из них дети до 1 года', text_thin )
  worksheet_write_number( ws4, 8, 2, 0, block_empty )
  worksheet_write_number( ws4, 8, 3, 0, block_empty )
  worksheet_write_formula( ws4, 8, 4, '=G9+H9+I9+L9+M9', block_Total )
  worksheet_write_number( ws4, 8, 5, 0, block_empty )
  worksheet_write_number( ws4, 8, 6, arr_2510_DDS[ 2, 4 ], block_empty )
  worksheet_write_number( ws4, 8, 7, arr_2510_DDS[ 2, 5 ], block_empty )
  worksheet_write_number( ws4, 8, 8, arr_2510_DDS[ 2, 6 ], block_empty )
  worksheet_write_string( ws4, 8, 9, 'X', block_gray )
  worksheet_write_string( ws4, 8, 10, 'X', block_gray )
  worksheet_write_number( ws4, 8, 11, arr_2510_DDS[ 2, 7 ], block_empty )
  worksheet_write_number( ws4, 8, 12, arr_2510_DDS[ 2, 8 ], block_empty )

  worksheet_write_string( ws4, 9, 0, '003', text_thin )
  worksheet_write_string( ws4, 9, 1, 'дети в возрасте 15-17 лет включительно', text_thin )
  worksheet_write_number( ws4, 9, 2, 0, block_empty )
  worksheet_write_number( ws4, 9, 3, 0, block_empty )
  worksheet_write_formula( ws4, 9, 4, '=G10+H10+I10+L10+M10', block_Total )
  worksheet_write_number( ws4, 9, 5, 0, block_empty )
  worksheet_write_number( ws4, 9, 6, arr_2510_DDS[ 3, 4 ], block_empty )
  worksheet_write_number( ws4, 9, 7, arr_2510_DDS[ 3, 5 ], block_empty )
  worksheet_write_number( ws4, 9, 8, arr_2510_DDS[ 3, 6 ], block_empty )
  worksheet_write_string( ws4, 9, 9, 'X', block_gray )
  worksheet_write_string( ws4, 9, 10, 'X', block_gray )
  worksheet_write_number( ws4, 9, 11, arr_2510_DDS[ 3, 7 ], block_empty )
  worksheet_write_number( ws4, 9, 12, arr_2510_DDS[ 3, 8 ], block_empty )

  worksheet_write_string( ws4, 10, 0, '004', text_thin )
  worksheet_write_string( ws4, 10, 1, 'из общего числа детей 15-17 лет(стр.03)-юношей', text_thin )
  worksheet_write_number( ws4, 10, 2, 0, block_empty )
  worksheet_write_number( ws4, 10, 3, 0, block_empty )
  worksheet_write_formula( ws4, 10, 4, '=G11+H11+I11+L11+M11', block_Total )
  worksheet_write_number( ws4, 10, 5, 0, block_empty )
  worksheet_write_number( ws4, 10, 6, arr_2510_DDS[ 4, 4 ], block_empty )
  worksheet_write_number( ws4, 10, 7, arr_2510_DDS[ 4, 5 ], block_empty )
  worksheet_write_number( ws4, 10, 8, arr_2510_DDS[ 4, 6 ], block_empty )
  worksheet_write_string( ws4, 10, 9, 'X', block_gray )
  worksheet_write_string( ws4, 10, 10, 'X', block_gray )
  worksheet_write_number( ws4, 10, 11, arr_2510_DDS[ 4, 7 ], block_empty )
  worksheet_write_number( ws4, 10, 12, arr_2510_DDS[ 4, 8 ], block_empty )

  worksheet_write_string( ws4, 11, 0, '005', text_thin )
  worksheet_write_string( ws4, 11, 1, 'школьники(из суммы стр.1+3)', text_thin )
  worksheet_write_number( ws4, 11, 2, 0, block_empty )
  worksheet_write_number( ws4, 11, 3, 0, block_empty )
  worksheet_write_formula( ws4, 11, 4, '=G12+H12+I12+L12+M12', block_Total )
  worksheet_write_number( ws4, 11, 5, 0, block_empty )
  worksheet_write_number( ws4, 11, 6, arr_2510_DDS[ 5, 4 ], block_empty )
  worksheet_write_number( ws4, 11, 7, arr_2510_DDS[ 5, 5 ], block_empty )
  worksheet_write_number( ws4, 11, 8, arr_2510_DDS[ 5, 6 ], block_empty )
  worksheet_write_string( ws4, 11, 9, 'X', block_gray )
  worksheet_write_string( ws4, 11, 10, 'X', block_gray )
  worksheet_write_number( ws4, 11, 11, arr_2510_DDS[ 5, 7 ], block_empty )
  worksheet_write_number( ws4, 11, 12, arr_2510_DDS[ 5, 8 ], block_empty )

  worksheet_write_string( ws4, 13, 0, '№ п/п', titul_table_thin )
  worksheet_write_string( ws4, 13, 1, 'таб.2510', titul_table_thin )
  worksheet_write_string( ws4, 13, 2, 'подлежало осмотрам', titul_table_thin )
  worksheet_write_string( ws4, 13, 3, 'из них сельских жителей', titul_table_thin )
  worksheet_write_string( ws4, 13, 4, 'осмотрено', titul_table_thin )
  worksheet_write_string( ws4, 13, 5, 'из них сельских жителей', titul_table_thin )
  worksheet_write_string( ws4, 13, 6, 'из числа осмотренных(гр.5): определены группы здоровья - I', titul_table_thin )
  worksheet_write_string( ws4, 13, 7, 'из числа осмотренных(гр.5): определены группы здоровья - II', titul_table_thin )
  worksheet_write_string( ws4, 13, 8, 'из числа осмотренных(гр.5): определены группы здоровья - III', titul_table_thin )
  worksheet_write_string( ws4, 13, 9, 'из них: III А', titul_table_thin )
  worksheet_write_string( ws4, 13, 10, 'из них: III Б', titul_table_thin )
  worksheet_write_string( ws4, 13, 11, 'из числа осмотренных(гр.5): определены группы здоровья - IV', titul_table_thin )
  worksheet_write_string( ws4, 13, 12, 'из числа осмотренных(гр.5): определены группы здоровья - V', titul_table_thin )
  for i := 0 to 12
    worksheet_write_string( ws4, 14, i, iif( i == 1, 'дети-сироты опекаемые', str( i + 1, 2 ) ), titul_table_thin )
  next
  worksheet_write_string( ws4, 15, 0, '001', text_thin )
  worksheet_write_string( ws4, 15, 1, 'дети в возрасте 0-14 лет включительно',text_thin )
  worksheet_write_number( ws4, 15, 2, 0, block_empty )
  worksheet_write_number( ws4, 15, 3, 0, block_empty )
  worksheet_write_formula( ws4, 15, 4, '=G16+H16+I16+L16+M16', block_Total )
  worksheet_write_number( ws4, 15, 5, 0, block_empty )
  worksheet_write_number( ws4, 15, 6, arr_2510_DDSOP[ 1, 4 ], block_empty )
  worksheet_write_number( ws4, 15, 7, arr_2510_DDSOP[ 1, 5 ], block_empty )
  worksheet_write_number( ws4, 15, 8, arr_2510_DDSOP[ 1, 6 ], block_empty )
  worksheet_write_string( ws4, 15, 9, 'X', block_gray )
  worksheet_write_string( ws4, 15, 10, 'X', block_gray )
  worksheet_write_number( ws4, 15, 11, arr_2510_DDSOP[ 1, 7 ], block_empty )
  worksheet_write_number( ws4, 15, 12, arr_2510_DDSOP[ 1, 8 ], block_empty )
  worksheet_write_string( ws4, 16, 0, '002', text_thin )
  worksheet_write_string( ws4, 16, 1, 'из них дети до 1 года', text_thin )
  worksheet_write_number( ws4, 16, 2, 0, block_empty )
  worksheet_write_number( ws4, 16, 3, 0, block_empty )
  worksheet_write_formula( ws4, 16, 4, '=G17+H17+I17+L17+M17', block_Total )
  worksheet_write_number( ws4, 16, 5, 0, block_empty )
  worksheet_write_number( ws4, 16, 6, arr_2510_DDSOP[ 2, 4 ], block_empty )
  worksheet_write_number( ws4, 16, 7, arr_2510_DDSOP[ 2, 5 ], block_empty )
  worksheet_write_number( ws4, 16, 8, arr_2510_DDSOP[ 2, 6 ], block_empty )
  worksheet_write_string( ws4, 16, 9, 'X', block_gray )
  worksheet_write_string( ws4, 16, 10, 'X', block_gray )
  worksheet_write_number( ws4, 16, 11, arr_2510_DDSOP[ 2, 7 ], block_empty )
  worksheet_write_number( ws4, 16, 12, arr_2510_DDSOP[ 2, 8 ], block_empty )
  worksheet_write_string( ws4, 17, 0, '003', text_thin )
  worksheet_write_string( ws4, 17, 1, 'дети в возрасте 15-17 лет включительно', text_thin )
  worksheet_write_number( ws4, 17, 2, 0, block_empty )
  worksheet_write_number( ws4, 17, 3, 0, block_empty )
  worksheet_write_formula( ws4, 17, 4, '=G18+H18+I18+L18+M18', block_Total )
  worksheet_write_number( ws4, 17, 5, 0, block_empty )
  worksheet_write_number( ws4, 17, 6, arr_2510_DDSOP[ 3, 4 ], block_empty )
  worksheet_write_number( ws4, 17, 7, arr_2510_DDSOP[ 3, 5 ], block_empty )
  worksheet_write_number( ws4, 17, 8, arr_2510_DDSOP[ 3, 6 ], block_empty )
  worksheet_write_string( ws4, 17, 9, 'X', block_gray )
  worksheet_write_string( ws4, 17, 10, 'X', block_gray )
  worksheet_write_number( ws4, 17, 11, arr_2510_DDSOP[ 3, 7 ], block_empty )
  worksheet_write_number( ws4, 17, 12, arr_2510_DDSOP[ 3, 8 ], block_empty )
  worksheet_write_string( ws4, 18, 0, '004', text_thin )
  worksheet_write_string( ws4, 18, 1, 'из общего числа детей 15-17 лет(стр.03)-юношей', text_thin )
  worksheet_write_number( ws4, 18, 2, 0, block_empty )
  worksheet_write_number( ws4, 18, 3, 0, block_empty )
  worksheet_write_formula( ws4, 18, 4, '=G19+H19+I19+L19+M19', block_Total )
  worksheet_write_number( ws4, 18, 5, 0, block_empty )
  worksheet_write_number( ws4, 18, 6, arr_2510_DDSOP[ 4, 4 ], block_empty )
  worksheet_write_number( ws4, 18, 7, arr_2510_DDSOP[ 4, 5 ], block_empty )
  worksheet_write_number( ws4, 18, 8, arr_2510_DDSOP[ 4, 6 ], block_empty )
  worksheet_write_string( ws4, 18, 9, 'X', block_gray )
  worksheet_write_string( ws4, 18, 10, 'X', block_gray )
  worksheet_write_number( ws4, 18, 11, arr_2510_DDSOP[ 4, 7 ], block_empty )
  worksheet_write_number( ws4, 18, 12, arr_2510_DDSOP[ 4, 8 ], block_empty )
  worksheet_write_string( ws4, 19, 0, '005', text_thin )
  worksheet_write_string( ws4, 19, 1, 'школьники(из суммы стр.1+3)', text_thin )
  worksheet_write_number( ws4, 19, 2, 0, block_empty )
  worksheet_write_number( ws4, 19, 3, 0, block_empty )
  worksheet_write_formula( ws4, 19, 4, '=G20+H20+I20+L20+M20', block_Total )
  worksheet_write_number( ws4, 19, 5, 0, block_empty )
  worksheet_write_number( ws4, 19, 6, arr_2510_DDSOP[ 5, 4 ], block_empty )
  worksheet_write_number( ws4, 19, 7, arr_2510_DDSOP[ 5, 5 ], block_empty )
  worksheet_write_number( ws4, 19, 8, arr_2510_DDSOP[ 5, 6 ], block_empty )
  worksheet_write_string( ws4, 19, 9, 'X', block_gray )
  worksheet_write_string( ws4, 19, 10, 'X', block_gray )
  worksheet_write_number( ws4, 19, 11, arr_2510_DDSOP[ 5, 7 ], block_empty )
  worksheet_write_number( ws4, 19, 12, arr_2510_DDSOP[ 5, 8 ], block_empty )

  worksheet_write_string( ws4, 22, 0, '№ п/п', titul_table_thin )
  worksheet_write_string( ws4, 22, 1, 'таб.2510', titul_table_thin )
  worksheet_write_string( ws4, 22, 2, 'подлежало осмотрам', titul_table_thin )
  worksheet_write_string( ws4, 22, 3, 'из них сельских жителей', titul_table_thin )
  worksheet_write_string( ws4, 22, 4, 'осмотрено', titul_table_thin )
  worksheet_write_string( ws4, 22, 5, 'из них сельских жителей', titul_table_thin )
  worksheet_write_string( ws4, 22, 6, 'из числа осмотренных(гр.5): определены группы здоровья - I', titul_table_thin )
  worksheet_write_string( ws4, 22, 7, 'из числа осмотренных(гр.5): определены группы здоровья - II', titul_table_thin )
  worksheet_write_string( ws4, 22, 8, 'из числа осмотренных(гр.5): определены группы здоровья - III', titul_table_thin )
  worksheet_write_string( ws4, 22, 9, 'из них: III А', titul_table_thin )
  worksheet_write_string( ws4, 22, 10, 'из них: III Б', titul_table_thin )
  worksheet_write_string( ws4, 22, 11, 'из числа осмотренных(гр.5): определены группы здоровья - IV', titul_table_thin )
  worksheet_write_string( ws4, 22, 12, 'из числа осмотренных(гр.5): определены группы здоровья - V', titul_table_thin )
  for i := 0 to 12
    worksheet_write_string( ws4, 23, i, iif( i == 1, 'дети-сироты ВСЕГО', str( i + 1, 2 ) ), titul_table_thin )
  next
  worksheet_write_string( ws4, 24, 0, '001', text_thin )
  worksheet_write_string( ws4, 24, 1, 'дети в возрасте 0-14 лет включительно', text_thin )
  worksheet_write_formula( ws4, 24, 2, '=C8+C16', t25_10 )
  worksheet_write_formula( ws4, 24, 3, '=D8+D16', t25_10 )
  worksheet_write_formula( ws4, 24, 4, '=E8+E16', t25_10 )
  worksheet_write_formula( ws4, 24, 5, '=F8+F16', t25_10 )
  worksheet_write_formula( ws4, 24, 6, '=G8+G16', t25_10 )
  worksheet_write_formula( ws4, 24, 7, '=H8+H16', t25_10 )
  worksheet_write_formula( ws4, 24, 8, '=I8+I16', t25_10 )
  worksheet_write_string( ws4, 24, 9, 'X', block_gray )
  worksheet_write_string( ws4, 24, 10, 'X', block_gray )
  worksheet_write_formula( ws4, 24, 11, '=L8+L16', t25_10 )
  worksheet_write_formula( ws4, 24, 12, '=M8+M16', t25_10 )
  worksheet_write_string( ws4, 25, 0, '002', text_thin )
  worksheet_write_string( ws4, 25, 1, 'из них дети до 1 года', text_thin )
  worksheet_write_formula( ws4, 25, 2, '=C9+C17', t25_10 )
  worksheet_write_formula( ws4, 25, 3, '=D9+D17', t25_10 )
  worksheet_write_formula( ws4, 25, 4, '=E9+E17', t25_10 )
  worksheet_write_formula( ws4, 25, 5, '=F9+F17', t25_10 )
  worksheet_write_formula( ws4, 25, 6, '=G9+G17', t25_10 )
  worksheet_write_formula( ws4, 25, 7, '=H9+H17', t25_10 )
  worksheet_write_formula( ws4, 25, 8, '=I9+I17', t25_10 )
  worksheet_write_string( ws4, 25, 9, 'X', block_gray )
  worksheet_write_string( ws4, 25, 10, 'X', block_gray )
  worksheet_write_formula( ws4, 25, 11, '=L9+L17', t25_10 )
  worksheet_write_formula( ws4, 25, 12, '=M9+M17', t25_10 )
  worksheet_write_string( ws4, 26, 0, '003', text_thin )
  worksheet_write_string( ws4, 26, 1, 'дети в возрасте 15-17 лет включительно', text_thin )
  worksheet_write_formula( ws4, 26, 2, '=C10+C18', t25_10 )
  worksheet_write_formula( ws4, 26, 3, '=D10+D18', t25_10 )
  worksheet_write_formula( ws4, 26, 4, '=E10+E18', t25_10 )
  worksheet_write_formula( ws4, 26, 5, '=F10+F18', t25_10 )
  worksheet_write_formula( ws4, 26, 6, '=G10+G18', t25_10 )
  worksheet_write_formula( ws4, 26, 7, '=H10+H18', t25_10 )
  worksheet_write_formula( ws4, 26, 8, '=I10+I18', t25_10 )
  worksheet_write_string( ws4, 26, 9, 'X', block_gray )
  worksheet_write_string( ws4, 26, 10, 'X', block_gray )
  worksheet_write_formula( ws4, 26, 11, '=L10+L18', t25_10 )
  worksheet_write_formula( ws4, 26, 12, '=M10+M18', t25_10 )
  worksheet_write_string( ws4, 27, 0, '004', text_thin )
  worksheet_write_string( ws4, 27, 1, 'из общего числа детей 15-17 лет(стр.03)-юношей', text_thin )
  worksheet_write_formula( ws4, 27, 2, '=C11+C19', t25_10 )
  worksheet_write_formula( ws4, 27, 3, '=D11+D19', t25_10 )
  worksheet_write_formula( ws4, 27, 4, '=E11+E19', t25_10 )
  worksheet_write_formula( ws4, 27, 5, '=F11+F19', t25_10 )
  worksheet_write_formula( ws4, 27, 6, '=G11+G19', t25_10 )
  worksheet_write_formula( ws4, 27, 7, '=H11+H19', t25_10 )
  worksheet_write_formula( ws4, 27, 8, '=I11+I19', t25_10 )
  worksheet_write_string( ws4, 27, 9, 'X', block_gray )
  worksheet_write_string( ws4, 27, 10, 'X', block_gray )
  worksheet_write_formula( ws4, 27, 11, '=L11+L19', t25_10 )
  worksheet_write_formula( ws4, 27, 12, '=M11+M19', t25_10 )
  worksheet_write_string( ws4, 28, 0, '005', text_thin )
  worksheet_write_string( ws4, 28, 1, 'школьники(из суммы стр.1+3)', text_thin )
  worksheet_write_formula( ws4, 28, 2, '=C12+C20', t25_10 )
  worksheet_write_formula( ws4, 28, 3, '=D12+D20', t25_10 )
  worksheet_write_formula( ws4, 28, 4, '=E12+E20', t25_10 )
  worksheet_write_formula( ws4, 28, 5, '=F12+F20', t25_10 )
  worksheet_write_formula( ws4, 28, 6, '=G12+G20', t25_10 )
  worksheet_write_formula( ws4, 28, 7, '=H12+H20', t25_10 )
  worksheet_write_formula( ws4, 28, 8, '=I12+I20', t25_10 )
  worksheet_write_string( ws4, 28, 9, 'X', block_gray )
  worksheet_write_string( ws4, 28, 10, 'X', block_gray )
  worksheet_write_formula( ws4, 28, 11, '=L12+L20', t25_10 )
  worksheet_write_formula( ws4, 28, 12, '=M12+M20', t25_10 )

  worksheet_merge_range( ws4, 31, 1, 31, 2, 'Ф.И.О. главного врача', block_FIO )
  worksheet_merge_range( ws4, 31, 3, 31, 6, '', block_FIO )
  worksheet_merge_range( ws4, 32, 1, 32, 2, 'Ф.И.О. исполнителя', block_FIO )
  worksheet_merge_range( ws4, 32, 3, 32, 6, '', block_FIO )
  worksheet_merge_range( ws4, 33, 1, 33, 2, 'телефон исполнителя', block_FIO )
  worksheet_merge_range( ws4, 33, 3, 33, 6, '', block_FIO )

  worksheet_merge_range( ws4, 35, 0, 36, 0, '', titul_table_bold )
  worksheet_merge_range( ws4, 35, 1, 36, 1, 'таб.2511', titul_table_bold )
  worksheet_merge_range( ws4, 35, 2, 35, 3, 'подлежало осмотрам', titul_table_bold )
  worksheet_write_string( ws4, 36, 2, 'всего', titul_table_bold )
  worksheet_write_string( ws4, 36, 3, 'из них сельских жителей', titul_table_bold )
  worksheet_merge_range( ws4, 35, 4, 35, 5, 'осмотрено', titul_table_bold )
  worksheet_write_string( ws4, 36, 4, 'всего', titul_table_bold )
  worksheet_write_string( ws4, 36, 5, 'из них сельских жителей', titul_table_bold )
  worksheet_merge_range( ws4, 35, 6, 35, 7, 'выявлена патология', titul_table_bold )
  worksheet_write_string( ws4, 36, 6, 'всего', titul_table_bold )
  worksheet_write_string( ws4, 36, 7, 'из них сельских жителей', titul_table_bold )
  worksheet_merge_range( ws4, 35, 8, 35, 9, 'Направлено на лечение', titul_table_yelow )
  worksheet_write_string( ws4, 36, 8, 'всего', titul_table_yelow )
  worksheet_write_string( ws4, 36, 9, 'из них сельских жителей', titul_table_yelow )
  worksheet_merge_range( ws4, 35, 10, 35, 11, 'Пролечено', titul_table_yelow )
  worksheet_write_string( ws4, 36, 10, 'всего', titul_table_yelow )
  worksheet_write_string( ws4, 36, 11, 'из них сельских жителей', titul_table_yelow )
  for i := 0 to 11
    worksheet_write_string( ws4, 37, i, iif( i == 0, '', iif( i == 1,  'дети-сироты', str( i + 1, 2 ) ) ), titul_table_thin )
  next
  worksheet_write_string( ws4, 38, 0, '001', text_thin )
  worksheet_write_string( ws4, 38, 1, 'осмотрено пациентов всего', text_thin )
  worksheet_write_formula( ws4, 38, 2, '=C27', block_Total )
  worksheet_write_formula( ws4, 38, 3, '=D27', block_Total )
  worksheet_write_formula( ws4, 38, 4, '=E27', block_Total )
  worksheet_write_formula( ws4, 38, 5, '=F27', block_Total )
  worksheet_write_formula( ws4, 38, 6, '=G40+G41', block_Total )
  worksheet_write_formula( ws4, 38, 7, '=H40+H41', block_Total )
  worksheet_write_formula( ws4, 38, 8, '=I40+I41', block_Total )
  worksheet_write_formula( ws4, 38, 9, '=J40+J41', block_Total )
  worksheet_write_formula( ws4, 38, 10, '=K40+K41', block_Total )
  worksheet_write_formula( ws4, 38, 11, '=L40+L41', block_Total )
  worksheet_write_string( ws4, 39, 0, '011', text_thin )
  worksheet_write_string( ws4, 39, 1, 'из них мальчиков(урологом-андрологом)', text_thin )
  worksheet_write_formula( ws4, 39, 2, '=C28', block_Total )
  worksheet_write_formula( ws4, 39, 3, '=D28', block_Total )
  worksheet_write_formula( ws4, 39, 4, '=E28', block_Total )
  worksheet_write_formula( ws4, 39, 5, '=F28', block_Total )
  worksheet_write_number( ws4, 39, 6, 0, block_empty )
  worksheet_write_number( ws4, 39, 7, 0, block_empty )
  worksheet_write_number( ws4, 39, 8, 0, block_empty )
  worksheet_write_number( ws4, 39, 9, 0, block_empty )
  worksheet_write_number( ws4, 39, 10, 0, block_empty )
  worksheet_write_number( ws4, 39, 11, 0, block_empty )

  worksheet_write_string( ws4, 40, 0, '012', text_thin )
  worksheet_write_string( ws4, 40, 1, 'девочек (акушером-гинекологом', text_thin )
  worksheet_write_formula( ws4, 40, 2, '=C39-C40', block_Total )
  worksheet_write_formula( ws4, 40, 3, '=D39-D40', block_Total )
  worksheet_write_formula( ws4, 40, 4, '=E39-E40', block_Total )
  worksheet_write_formula( ws4, 40, 5, '=F39-F40', block_Total )
  worksheet_write_number( ws4, 40, 6, 0, block_empty )
  worksheet_write_number( ws4, 40, 7, 0, block_empty )
  worksheet_write_number( ws4, 40, 8, 0, block_empty )
  worksheet_write_number( ws4, 40, 9, 0, block_empty )
  worksheet_write_number( ws4, 40, 10, 0, block_empty )
  worksheet_write_number( ws4, 40, 11, 0, block_empty )

  worksheet_write_string( ws4, 43, 0, '№ п/п', titul_table_thin )
  worksheet_write_string( ws4, 43, 1, 'таб.2510', titul_table_thin )
  worksheet_write_string( ws4, 43, 2, 'подлежало осмотрам', titul_table_thin )
  worksheet_write_string( ws4, 43, 3, 'из них сельских жителей', titul_table_thin )
  worksheet_write_string( ws4, 43, 4, 'осмотрено', titul_table_thin )
  worksheet_write_string( ws4, 43, 5, 'из них сельских жителей', titul_table_thin )
  worksheet_write_string( ws4, 43, 6, 'из числа осмотренных(гр.5): определены группы здоровья - I', titul_table_thin )
  worksheet_write_string( ws4, 43, 7, 'из числа осмотренных(гр.5): определены группы здоровья - II', titul_table_thin )
  worksheet_write_string( ws4, 43, 8, 'из числа осмотренных(гр.5): определены группы здоровья - III', titul_table_thin )
  worksheet_write_string( ws4, 43, 9, 'из них: III А', titul_table_thin )
  worksheet_write_string( ws4, 43, 10, 'из них: III Б', titul_table_thin )
  worksheet_write_string( ws4, 43, 11, 'из числа осмотренных(гр.5): определены группы здоровья - IV', titul_table_thin )
  worksheet_write_string( ws4, 43, 12, 'из числа осмотренных(гр.5): определены группы здоровья - V', titul_table_thin )
  for i := 0 to 12
    worksheet_write_string( ws4, 44, i, iif( i == 1, 'дети-сироты', str( i + 1, 2 ) ), titul_table_thin )
  next
  worksheet_write_string( ws4, 45, 0, '1', text_thin )
  worksheet_write_string( ws4, 45, 1, 'Всего', text_thin )
  worksheet_write_formula( ws4, 45, 2, '=C47+C48', block_Total )
  worksheet_write_formula( ws4, 45, 3, '=D47+D48', block_Total )
  worksheet_write_formula( ws4, 45, 4, '=E47+E48', block_Total )
  worksheet_write_formula( ws4, 45, 5, '=F47+F48', block_Total )
  worksheet_write_formula( ws4, 45, 6, '=G47+G48', block_Total )
  worksheet_write_formula( ws4, 45, 7, '=H47+H48', block_Total )
  worksheet_write_formula( ws4, 45, 8, '=I47+I48', block_Total )
  worksheet_write_string( ws4, 45, 9, 'X', block_gray )
  worksheet_write_string( ws4, 45, 10, 'X', block_gray )
  worksheet_write_formula( ws4, 45, 11, '=L47+L48', block_Total )
  worksheet_write_formula( ws4, 45, 12, '=M47+M48', block_Total )

  worksheet_write_string( ws4, 46, 0, '2', text_thin )
  worksheet_write_string( ws4, 46, 1, 'дети-сироты в стационарных учреждениях', text_thin )
  worksheet_write_number( ws4, 46, 2, arr_plan[ 7 ], t25_10_yelow )

  worksheet_write_formula( ws4, 46, 3, '=D8+D10', block_Total )
  worksheet_write_formula( ws4, 46, 4, '=E8+E10', block_Total )
  worksheet_write_formula( ws4, 46, 5, '=F8+F10', block_Total )
  worksheet_write_formula( ws4, 46, 6, '=G8+G10', block_Total )
  worksheet_write_formula( ws4, 46, 7, '=H8+H10', block_Total )
  worksheet_write_formula( ws4, 46, 8, '=I8+I10', block_Total )
  worksheet_write_string( ws4, 46, 9, 'X', block_gray )
  worksheet_write_string( ws4, 46, 10, 'X', block_gray )
  worksheet_write_formula( ws4, 46, 11, '=L8+L10', block_Total )
  worksheet_write_formula( ws4, 46, 12, '=M8+M10', block_Total )

  worksheet_write_string( ws4, 47, 0, '3', text_thin )
  worksheet_write_string( ws4, 47, 1, 'дети, находящиеся под опекой в семьях', text_thin )
  worksheet_write_number( ws4, 47, 2, arr_plan[ 8 ], t25_10_yelow )

  worksheet_write_formula( ws4, 47, 3, '=D16+D18', block_Total )
  worksheet_write_formula( ws4, 47, 4, '=E16+E18', block_Total )
  worksheet_write_formula( ws4, 47, 5, '=F16+F18', block_Total )
  worksheet_write_formula( ws4, 47, 6, '=G16+G18', block_Total )
  worksheet_write_formula( ws4, 47, 7, '=H16+H18', block_Total )
  worksheet_write_formula( ws4, 47, 8, '=I16+I18', block_Total )
  worksheet_write_string( ws4, 47, 9, 'X', block_gray )
  worksheet_write_string( ws4, 47, 10, 'X', block_gray )
  worksheet_write_formula( ws4, 47, 11, '=L16+L18', block_Total )
  worksheet_write_formula( ws4, 47, 12, '=M16+M18', block_Total )

//
// лист 5 - 2510-дети-СВОД
//
  ws5 := workbook_add_worksheet( workbook, '2510-дети-СВОД' )
  worksheet_set_tab_color( ws5, cColorTab5 )

  worksheet_set_row( ws5, 0, 44.4 )
  worksheet_set_column( ws5, 1, 1, 26 )
  worksheet_merge_range( ws5, 0, 3, 0, 10, 'Сведения о профилактических осмотрах и диспансеризации несовершеннолетних ВСЕГО', header_bold )
  worksheet_merge_range( ws5, 1, 4, 1, 5, 'по состоянию на', header_bold_sost )
  worksheet_write_number( ws5, 1, 6, Day( arr_m[ 6 ] ), header_bold_sost )
  worksheet_write_string( ws5, 1, 7, hb_StrToUTF8( Lower( CMonth( arr_m[ 6 ] ) ) ), header_bold_sost )
  worksheet_write_number( ws5, 1, 8, Year( arr_m[ 6 ] ), header_bold_sost )
  worksheet_merge_range( ws5, 3, 2, 3, 12, strMO, titul_bold_center )

  worksheet_write_string( ws5, 6, 0, '№ п/п', titul_table_thin )
  worksheet_write_string( ws5, 6, 1, 'таб.2510', titul_table_thin )
  worksheet_write_string( ws5, 6, 2, 'подлежало осмотрам', titul_table_thin )
  worksheet_write_string( ws5, 6, 3, 'из них сельских жителей', titul_table_thin )
  worksheet_write_string( ws5, 6, 4, 'осмотрено', titul_table_thin )
  worksheet_write_string( ws5, 6, 5, 'из них сельских жителей', titul_table_thin )
  worksheet_write_string( ws5, 6, 6, 'из числа осмотренных(гр.5): определены группы здоровья - I', titul_table_thin )
  worksheet_write_string( ws5, 6, 7, 'из числа осмотренных(гр.5): определены группы здоровья - II', titul_table_thin )
  worksheet_write_string( ws5, 6, 8, 'из числа осмотренных(гр.5): определены группы здоровья - III', titul_table_thin )
  worksheet_write_string( ws5, 6, 9, 'из них: III А', titul_table_thin )
  worksheet_write_string( ws5, 6, 10, 'из них: III Б', titul_table_thin )
  worksheet_write_string( ws5, 6, 11, 'из числа осмотренных(гр.5): определены группы здоровья - IV', titul_table_thin )
  worksheet_write_string( ws5, 6, 12, 'из числа осмотренных(гр.5): определены группы здоровья - V', titul_table_thin )
  for i := 0 to 12
    worksheet_write_string( ws5, 7, i, iif( i == 1, 'свод', str( i + 1, 2 ) ), titul_table_thin )
  next

  worksheet_write_string( ws5, 8, 0, '001', text_thin )
  worksheet_write_string( ws5, 8, 1, 'дети в возрасте 0-14 лет включительно', text_thin )
  worksheet_write_formula( ws5, 8, 2, "=профосмотры!C27+'2510-2511-Дети сироты'!C25", block_Total )
  worksheet_write_formula( ws5, 8, 3, "=профосмотры!D27+'2510-2511-Дети сироты'!D25", block_Total )
  worksheet_write_formula( ws5, 8, 4, "=профосмотры!E27+'2510-2511-Дети сироты'!E25", block_Total )
  worksheet_write_formula( ws5, 8, 5, "=профосмотры!F27+'2510-2511-Дети сироты'!F25", block_Total )
  worksheet_write_formula( ws5, 8, 6, "=профосмотры!G27+'2510-2511-Дети сироты'!G25", block_Total )
  worksheet_write_formula( ws5, 8, 7, "=профосмотры!H27+'2510-2511-Дети сироты'!H25", block_Total )
  worksheet_write_formula( ws5, 8, 8, "=профосмотры!I27+'2510-2511-Дети сироты'!I25", block_Total )
  worksheet_write_string( ws5, 8, 9, 'X', block_empty )
  worksheet_write_string( ws5, 8, 10, 'X', block_empty )
  worksheet_write_formula( ws5, 8, 11, "=профосмотры!L27+'2510-2511-Дети сироты'!L25", block_Total )
  worksheet_write_formula( ws5, 8, 12, "=профосмотры!M27+'2510-2511-Дети сироты'!M25", block_Total )
  worksheet_write_string( ws5, 9, 0, '002', text_thin )
  worksheet_write_string( ws5, 9, 1, 'из них дети до 1 года', text_thin )
  worksheet_write_formula( ws5, 9, 2, "=профосмотры!C28+'2510-2511-Дети сироты'!C26", block_Total )
  worksheet_write_formula( ws5, 9, 3, "=профосмотры!D28+'2510-2511-Дети сироты'!D26", block_Total )
  worksheet_write_formula( ws5, 9, 4, "=профосмотры!E28+'2510-2511-Дети сироты'!E26", block_Total )
  worksheet_write_formula( ws5, 9, 5, "=профосмотры!F28+'2510-2511-Дети сироты'!F26", block_Total )
  worksheet_write_formula( ws5, 9, 6, "=профосмотры!G28+'2510-2511-Дети сироты'!G26", block_Total )
  worksheet_write_formula( ws5, 9, 7, "=профосмотры!H28+'2510-2511-Дети сироты'!H26", block_Total )
  worksheet_write_formula( ws5, 9, 8, "=профосмотры!I28+'2510-2511-Дети сироты'!I26", block_Total )
  worksheet_write_string( ws5, 9, 9, 'X', block_empty )
  worksheet_write_string( ws5, 9, 10, 'X', block_empty )
  worksheet_write_formula( ws5, 9, 11, "=профосмотры!L28+'2510-2511-Дети сироты'!L26", block_Total )
  worksheet_write_formula( ws5, 9, 12, "=профосмотры!M28+'2510-2511-Дети сироты'!M26", block_Total )
  worksheet_write_string( ws5, 10, 0, '003', text_thin )
  worksheet_write_string( ws5, 10, 1, 'дети в возрасте 15-17 лет включительно', text_thin )
  worksheet_write_formula( ws5, 10, 2, "=профосмотры!C29+'2510-2511-Дети сироты'!C27", block_Total )
  worksheet_write_formula( ws5, 10, 3, "=профосмотры!D29+'2510-2511-Дети сироты'!D27", block_Total )
  worksheet_write_formula( ws5, 10, 4, "=профосмотры!E29+'2510-2511-Дети сироты'!E27", block_Total )
  worksheet_write_formula( ws5, 10, 5, "=профосмотры!F29+'2510-2511-Дети сироты'!F27", block_Total )
  worksheet_write_formula( ws5, 10, 6, "=профосмотры!G29+'2510-2511-Дети сироты'!G27", block_Total )
  worksheet_write_formula( ws5, 10, 7, "=профосмотры!H29+'2510-2511-Дети сироты'!H27", block_Total )
  worksheet_write_formula( ws5, 10, 8, "=профосмотры!I29+'2510-2511-Дети сироты'!I27", block_Total )
  worksheet_write_string( ws5, 10, 9, 'X', block_empty )
  worksheet_write_string( ws5, 10, 10, 'X', block_empty )
  worksheet_write_formula( ws5, 10, 11, "=профосмотры!L29+'2510-2511-Дети сироты'!L27", block_Total )
  worksheet_write_formula( ws5, 10, 12, "=профосмотры!M29+'2510-2511-Дети сироты'!M27", block_Total )
  worksheet_write_string( ws5, 11, 0, '004', text_thin )
  worksheet_write_string( ws5, 11, 1, 'из общего числа детей 15-17 лет(стр.03)-юношей', text_thin )
  worksheet_write_formula( ws5, 11, 2, "=профосмотры!C30+'2510-2511-Дети сироты'!C28", block_Total )
  worksheet_write_formula( ws5, 11, 3, "=профосмотры!D30+'2510-2511-Дети сироты'!D28", block_Total )
  worksheet_write_formula( ws5, 11, 4, "=профосмотры!E30+'2510-2511-Дети сироты'!E28", block_Total )
  worksheet_write_formula( ws5, 11, 5, "=профосмотры!F30+'2510-2511-Дети сироты'!F28", block_Total )
  worksheet_write_formula( ws5, 11, 6, "=профосмотры!G30+'2510-2511-Дети сироты'!G28", block_Total )
  worksheet_write_formula( ws5, 11, 7, "=профосмотры!H30+'2510-2511-Дети сироты'!H28", block_Total )
  worksheet_write_formula( ws5, 11, 8, "=профосмотры!I30+'2510-2511-Дети сироты'!I28", block_Total )
  worksheet_write_string( ws5, 11, 9, 'X', block_empty )
  worksheet_write_string( ws5, 11, 10, 'X', block_empty )
  worksheet_write_formula( ws5, 11, 11, "=профосмотры!L30+'2510-2511-Дети сироты'!L28", block_Total )
  worksheet_write_formula( ws5, 11, 12, "=профосмотры!M30+'2510-2511-Дети сироты'!M28", block_Total )
  worksheet_write_string( ws5, 12, 0, '005', text_thin )
  worksheet_write_string( ws5, 12, 1, 'школьники(из суммы стр.1+3)', text_thin )
  worksheet_write_formula( ws5, 12, 2, "=профосмотры!C31+'2510-2511-Дети сироты'!C29", block_Total )
  worksheet_write_formula( ws5, 12, 3, "=профосмотры!D31+'2510-2511-Дети сироты'!D29", block_Total )
  worksheet_write_formula( ws5, 12, 4, "=профосмотры!E31+'2510-2511-Дети сироты'!E29", block_Total )
  worksheet_write_formula( ws5, 12, 5, "=профосмотры!F31+'2510-2511-Дети сироты'!F29", block_Total )
  worksheet_write_formula( ws5, 12, 6, "=профосмотры!G31+'2510-2511-Дети сироты'!G29", block_Total )
  worksheet_write_formula( ws5, 12, 7, "=профосмотры!H31+'2510-2511-Дети сироты'!H29", block_Total )
  worksheet_write_formula( ws5, 12, 8, "=профосмотры!I31+'2510-2511-Дети сироты'!I29", block_Total )
  worksheet_write_string( ws5, 12, 9, 'X', block_empty )
  worksheet_write_string( ws5, 12, 10, 'X', block_empty )
  worksheet_write_formula( ws5, 12, 11, "=профосмотры!L31+'2510-2511-Дети сироты'!L29", block_Total )
  worksheet_write_formula( ws5, 12, 12, "=профосмотры!M31+'2510-2511-Дети сироты'!M29", block_Total )

  worksheet_write_string( ws5, 13, 0, '006', text_thin )
  worksheet_write_string( ws5, 13, 1, 'дети-сироты в стационарных учреждениях', text_thin )

  worksheet_write_formula( ws5, 13, 2, "='2510-2511-Дети сироты'!C47", block_Total )
  worksheet_write_formula( ws5, 13, 3, "='2510-2511-Дети сироты'!D47", block_Total )
  worksheet_write_formula( ws5, 13, 4, "='2510-2511-Дети сироты'!E47", block_Total )
  worksheet_write_formula( ws5, 13, 5, "='2510-2511-Дети сироты'!F47", block_Total )
  worksheet_write_formula( ws5, 13, 6, "='2510-2511-Дети сироты'!G47", block_Total )
  worksheet_write_formula( ws5, 13, 7, "='2510-2511-Дети сироты'!H47", block_Total )
  worksheet_write_formula( ws5, 13, 8, "='2510-2511-Дети сироты'!I47", block_Total )
  worksheet_write_string( ws5, 13, 9, 'X', block_empty )
  worksheet_write_string( ws5, 13, 10, 'X', block_empty )
  worksheet_write_formula( ws5, 13, 11, "='2510-2511-Дети сироты'!L47", block_Total )
  worksheet_write_formula( ws5, 13, 12, "='2510-2511-Дети сироты'!M47", block_Total )

  worksheet_write_string( ws5, 14, 0, '007', text_thin )
  worksheet_write_string( ws5, 14, 1, 'дети, находящиеся под опекой в семьях', text_thin )

  worksheet_write_formula( ws5, 14, 2, "='2510-2511-Дети сироты'!C48", block_Total )
  worksheet_write_formula( ws5, 14, 3, "='2510-2511-Дети сироты'!D48", block_Total )
  worksheet_write_formula( ws5, 14, 4, "='2510-2511-Дети сироты'!E48", block_Total )
  worksheet_write_formula( ws5, 14, 5, "='2510-2511-Дети сироты'!F48", block_Total )
  worksheet_write_formula( ws5, 14, 6, "='2510-2511-Дети сироты'!G48", block_Total )
  worksheet_write_formula( ws5, 14, 7, "='2510-2511-Дети сироты'!H48", block_Total )
  worksheet_write_formula( ws5, 14, 8, "='2510-2511-Дети сироты'!I48", block_Total )
  worksheet_write_string( ws5, 14, 9, 'X', block_empty )
  worksheet_write_string( ws5, 14, 10, 'X', block_empty )
  worksheet_write_formula( ws5, 14, 11, "='2510-2511-Дети сироты'!L48", block_Total )
  worksheet_write_formula( ws5, 14, 12, "='2510-2511-Дети сироты'!M48", block_Total )

  worksheet_merge_range( ws5, 17, 1, 17, 2, 'Ф.И.О. главного врача', block_FIO )
  worksheet_merge_range( ws5, 17, 3, 17, 6, '', block_FIO )
  worksheet_merge_range( ws5, 18, 1, 18, 2, 'Ф.И.О. исполнителя', block_FIO )
  worksheet_merge_range( ws5, 18, 3, 18, 6, '', block_FIO )
  worksheet_merge_range( ws5, 19, 1, 19, 2, 'телефон исполнителя', block_FIO )
  worksheet_merge_range( ws5, 19, 3, 19, 6, '', block_FIO )

//
// лист 6 - таб. 2511 ф. 30
//
  ws6 := workbook_add_worksheet( workbook, 'таб. 2511 ф. 30' )
  worksheet_set_tab_color( ws6, cColorTab6 )

  worksheet_set_row( ws6, 0, 43.8 )
  worksheet_set_row( ws6, 5, 28.2 )
  worksheet_set_row( ws6, 9, 31.8 )
  worksheet_set_column( ws6, 1, 1, 32.44 )

  worksheet_merge_range( ws6, 0, 3, 0, 10, 'Сведения о профилактических осмотрах детей в возрасте 15-17 лет', header_bold )
  worksheet_merge_range( ws6, 1, 4, 1, 5, 'по состоянию на', header_bold_sost )
  worksheet_write_number( ws6, 1, 6, Day( arr_m[ 6 ] ), header_bold_sost )
  worksheet_write_string( ws6, 1, 7, hb_StrToUTF8( Lower( CMonth( arr_m[ 6 ] ) ) ), header_bold_sost )
  worksheet_write_number( ws6, 1, 8, Year( arr_m[ 6 ] ), header_bold_sost )
  worksheet_merge_range( ws6, 3, 1, 3, 11, strMO, titul_bold_center )


  worksheet_merge_range( ws6, 5, 0, 6, 0, '', titul_table_bold )
  worksheet_merge_range( ws6, 5, 1, 6, 1, 'таб.2511 профосмотры 15-17 лет', titul_table_bold )
  worksheet_merge_range( ws6, 5, 2, 5, 3, 'подлежало осмотрам', titul_table_bold )
  worksheet_write_string( ws6, 6, 2, 'всего', titul_table_bold )
  worksheet_write_string( ws6, 6, 3, 'из них сельских жителей', titul_table_bold )

  worksheet_merge_range( ws6, 5, 4, 5, 5, 'осмотрено', titul_table_bold )
  worksheet_write_string( ws6, 6, 4, 'всего', titul_table_bold )
  worksheet_write_string( ws6, 6, 5, 'из них сельских жителей', titul_table_bold )

  worksheet_merge_range( ws6, 5, 6, 5, 7, 'выявлена патология', titul_table_bold )
  worksheet_write_string( ws6, 6, 6, 'всего', titul_table_bold )
  worksheet_write_string( ws6, 6, 7, 'из них сельских жителей', titul_table_bold )

  worksheet_merge_range( ws6, 5, 8, 5, 9, 'напроавлено на лечение', titul_table_yelow )
  worksheet_write_string( ws6, 6, 8, 'всего', titul_table_yelow )
  worksheet_write_string( ws6, 6, 9, 'из них сельских жителей', titul_table_yelow )
  worksheet_merge_range( ws6, 5, 10, 5, 11, 'пролечено', titul_table_yelow )
  worksheet_write_string( ws6, 6, 10, 'всего', titul_table_yelow )
  worksheet_write_string( ws6, 6, 11, 'из них сельских жителей', titul_table_yelow )

  for i := 0 to 11
    worksheet_write_string( ws6, 7, i, iif( i == 0, '', iif( i == 1, 'свод', str( i + 1, 2 ) ) ), titul_table_thin )
  next

  worksheet_write_string( ws6, 8, 0, '001', text_thin )
  worksheet_write_string( ws6, 8, 1, 'осмотрено пациентов всего', text_thin )
  worksheet_write_formula( ws6, 8, 2, "='15-17 лет'!B31+'2510-2511-Дети сироты'!C39", block_Total )
  worksheet_write_formula( ws6, 8, 3, "='15-17 лет'!C31+'2510-2511-Дети сироты'!D39", block_Total )
  worksheet_write_formula( ws6, 8, 4, "='15-17 лет'!D31+'2510-2511-Дети сироты'!E39", block_Total )
  worksheet_write_formula( ws6, 8, 5, "='15-17 лет'!E31+'2510-2511-Дети сироты'!F39", block_Total )
  worksheet_write_formula( ws6, 8, 6, "='15-17 лет'!F31+'2510-2511-Дети сироты'!G39", block_Total )
  worksheet_write_formula( ws6, 8, 7, "='15-17 лет'!G31+'2510-2511-Дети сироты'!H39", block_Total )
  worksheet_write_formula( ws6, 8, 8, "='15-17 лет'!H31+'2510-2511-Дети сироты'!I39", block_Total )
  worksheet_write_formula( ws6, 8, 9, "='15-17 лет'!I31+'2510-2511-Дети сироты'!J39", block_Total )
  worksheet_write_formula( ws6, 8, 10, "='15-17 лет'!J31+'2510-2511-Дети сироты'!K39", block_Total )
  worksheet_write_formula( ws6, 8, 11, "='15-17 лет'!K31+'2510-2511-Дети сироты'!L39", block_Total )
  worksheet_write_string( ws6, 9, 0, '011', text_thin )
  worksheet_write_string( ws6, 9, 1, 'из них мальчиков(урологом-андрологом)', text_thin )
  worksheet_write_formula( ws6, 9, 2, "='15-17 лет'!B32+'2510-2511-Дети сироты'!C40", block_Total )
  worksheet_write_formula( ws6, 9, 3, "='15-17 лет'!C32+'2510-2511-Дети сироты'!D40", block_Total )
  worksheet_write_formula( ws6, 9, 4, "='15-17 лет'!D32+'2510-2511-Дети сироты'!E40", block_Total )
  worksheet_write_formula( ws6, 9, 5, "='15-17 лет'!E32+'2510-2511-Дети сироты'!F40", block_Total )
  worksheet_write_formula( ws6, 9, 6, "='15-17 лет'!F32+'2510-2511-Дети сироты'!G40", block_Total )
  worksheet_write_formula( ws6, 9, 7, "='15-17 лет'!G32+'2510-2511-Дети сироты'!H40", block_Total )
  worksheet_write_formula( ws6, 9, 8, "='15-17 лет'!H32+'2510-2511-Дети сироты'!I40", block_Total )
  worksheet_write_formula( ws6, 9, 9, "='15-17 лет'!I32+'2510-2511-Дети сироты'!J40", block_Total )
  worksheet_write_formula( ws6, 9, 10, "='15-17 лет'!J32+'2510-2511-Дети сироты'!K40", block_Total )
  worksheet_write_formula( ws6, 9, 11, "='15-17 лет'!K32+'2510-2511-Дети сироты'!L40", block_Total )
  worksheet_write_string( ws6, 10, 0, '012', text_thin )
  worksheet_write_string( ws6, 10, 1, 'девочек (акушером-гинекологом', text_thin )
  worksheet_write_formula( ws6, 10, 2, "='15-17 лет'!B33+'2510-2511-Дети сироты'!C41", block_Total )
  worksheet_write_formula( ws6, 10, 3, "='15-17 лет'!C33+'2510-2511-Дети сироты'!D41", block_Total )
  worksheet_write_formula( ws6, 10, 4, "='15-17 лет'!D33+'2510-2511-Дети сироты'!E41", block_Total )
  worksheet_write_formula( ws6, 10, 5, "='15-17 лет'!E33+'2510-2511-Дети сироты'!F41", block_Total )
  worksheet_write_formula( ws6, 10, 6, "='15-17 лет'!F33+'2510-2511-Дети сироты'!G41", block_Total )
  worksheet_write_formula( ws6, 10, 7, "='15-17 лет'!G33+'2510-2511-Дети сироты'!H41", block_Total )
  worksheet_write_formula( ws6, 10, 8, "='15-17 лет'!H33+'2510-2511-Дети сироты'!I41", block_Total )
  worksheet_write_formula( ws6, 10, 9, "='15-17 лет'!I33+'2510-2511-Дети сироты'!J41", block_Total )
  worksheet_write_formula( ws6, 10, 10, "='15-17 лет'!J33+'2510-2511-Дети сироты'!K41", block_Total )
  worksheet_write_formula( ws6, 10, 11, "='15-17 лет'!K33+'2510-2511-Дети сироты'!L41", block_Total )

  worksheet_merge_range( ws6, 13, 1, 13, 2, 'Ф.И.О. главного врача', block_FIO )
  worksheet_merge_range( ws6, 13, 3, 13, 6, '', block_FIO )
  worksheet_merge_range( ws6, 14, 1, 14, 2, 'Ф.И.О. исполнителя', block_FIO )
  worksheet_merge_range( ws6, 14, 3, 14, 6, '', block_FIO )
  worksheet_merge_range( ws6, 15, 1, 15, 2, 'телефон исполнителя', block_FIO )
  worksheet_merge_range( ws6, 15, 3, 15, 6, '', block_FIO )

  svod_new( workbook, hYoung15_17, hYoung13_14, hGirl15_17, hGirl13_14 )

  /* Закрыть книгу, записать файл и освободить память. */
  error = workbook_close( workbook )
  /* Проверить наличие ошибки при создании xlsx файла. */
  If !Empty( error )
    alertx( hb_UTF8ToStr( sprintf( 'Ошибка в workbook_close().\n' + ;
    'Ошибка %d = %s\n', error, hb_ntos( error ) ), 'RU866' ), 'error' )
  Endif
  rest_box( buf )

  return nil

// 23.11.26
function svod_new( wb, hYoung15_17, hYoung13_14, hGirl15_17, hGirl13_14 )

    Local ws7, cColorTab7, text_thin_svod,text_thin_svod_center, header_bold
    local hTemp, total
    local total_I, total_II, total_III, total_IV, total_V, sum_total, sum_total_young, sum_total_girl
    local total_fiz1, total_fiz2, total_fiz3, total_fiz4

//
// лист 7 - Заболевания 13-17 ВСЕ
//
  cColorTab7 := 0x99ead3

  header_bold := fmt_excel_hc_vc_wrap( wb )
  format_set_font_name( header_bold, 'Arial' )
  format_set_bold( header_bold )
  format_set_font_size( header_bold, 14 )

  text_thin_svod := fmt_excel_hl_vc_wrap( wb )

  format_set_font_name( text_thin_svod, 'Arial' )
  format_set_font_size( text_thin_svod, 10 )
//  format_set_bg_color( titul_table_thin, 0xffff00 )
  format_set_border( text_thin_svod, LXW_BORDER_THIN )

  text_thin_svod_center := fmt_excel_hc_vc_wrap( wb )
  format_set_font_name( text_thin_svod_center, 'Arial' )
  format_set_font_size( text_thin_svod_center, 10 )
//  format_set_bg_color( titul_table_thin, 0xffff00 )
  format_set_border( text_thin_svod_center, LXW_BORDER_THIN )


  ws7 := workbook_add_worksheet( wb, 'Заболевания 13-17 ВСЕ' )
  worksheet_set_tab_color( ws7, cColorTab7 )

  worksheet_set_row( ws7, 0, 7.8 )
  worksheet_set_row( ws7, 2, 7.8 )
  worksheet_set_row( ws7, 3, 7.8 )
  worksheet_set_row( ws7, 4, 16.8 )

  worksheet_set_column( ws7, 0, 0, 8.89   )
  worksheet_set_column( ws7, 1, 1, 61.11   )
  worksheet_set_column( ws7, 2, 8, 12.56 )
  worksheet_set_column( ws7, 9, 9, 1.33 )
  worksheet_set_column( ws7, 10, 10, 6.11 )

  total_I   := hYoung13_14[ 'GR1' ] + hYoung15_17[ 'GR1' ] + hGirl13_14[ 'GR1' ] + hGirl15_17[ 'GR1' ]
  total_II  := hYoung13_14[ 'GR2' ] + hYoung15_17[ 'GR2' ] + hGirl13_14[ 'GR2' ] + hGirl15_17[ 'GR2' ]
  total_III := hYoung13_14[ 'GR3' ] + hYoung15_17[ 'GR3' ] + hGirl13_14[ 'GR3' ] + hGirl15_17[ 'GR3' ]
  total_IV  := hYoung13_14[ 'GR4' ] + hYoung15_17[ 'GR4' ] + hGirl13_14[ 'GR4' ] + hGirl15_17[ 'GR4' ]
  total_V   := hYoung13_14[ 'GR5' ] + hYoung15_17[ 'GR5' ] + hGirl13_14[ 'GR5' ] + hGirl15_17[ 'GR5' ]
  sum_total := total_I + total_II + total_III + total_IV + total_V

  worksheet_merge_range( ws7, 1, 1, 1, 7, 'Профосмотры несовершеннолетних', header_bold )

  worksheet_write_string( ws7, 1, 0, '№ строки', text_thin_svod_center )
  worksheet_merge_range( ws7, 4, 1, 4, 7, 'Наименование показателя', text_thin_svod_center )
  worksheet_write_string( ws7, 4, 8, 'человек / %', text_thin_svod_center )

  row_single_number( wb, ws7, 5, 1, 13, 'Общее число несовершеннолетних в возрасте 13-17 лет включительно, подлежащих профилактическому осмотру (прикрепленного населения соответствующего возраста)', 0, .t. )
  row_single_number( wb, ws7, 6, 2, 13, 'Общее число несовершеннолетних в возрасте 13-17 лет включительно, прошедших 1 этап профилактического осмотра в соответствующем возрасте', '=H14+H15+H16+H17+H18', .f. )
  row_single_number( wb, ws7, 7, 3, 27.6, 'Общее число несовершеннолетних в возрасте 13-17 лет включительно, прошедших 1 этап профилактического осмотра в соответствующем возрасте с применением мобильных медицинских комплексов', 0, .t. )
  row_single_number( wb, ws7, 8, 4, 13, 'Процент несовершеннолетних в возрасте 13-17 лет включительно, прошедших профилактический осмотр в соответствующем возрасте', '=IFERROR(ROUND(I7/I6*100,1),0)', .f. )
  row_single_number( wb, ws7, 9, 5, 27.6, 'Общее число несовершеннолетних в возрасте 13-17 лет включительно с оформленным отказом от профилактического осмотра в соответствующем возрасте', 0, .t. )

  empty_rows( ws7, 10, 2, 3.0 )  

  worksheet_write_number( ws7, 12, 0, 8, text_thin_svod )
  worksheet_merge_range( ws7, 12, 1, 12, 6, 'Общее число и доля несовершеннолетних в возрасте 13-17 лет включительно из прошедших профилактический осмотр, которые были отнесены к:', text_thin_svod )
  worksheet_write_string( ws7, 12, 7, 'человек', text_thin_svod_center )
  worksheet_write_string( ws7, 12, 8, '%', text_thin_svod_center )

  row_two_numbers( wb, ws7, 13, 9, 13, '1 группе здоровья', total_I, number_percent_100( total_I, sum_total ) )
  row_two_numbers( wb, ws7, 14, 10, 13, '2 группе здоровья', total_II, number_percent_100( total_II, sum_total ) )
  row_two_numbers( wb, ws7, 15, 11, 13, '3 группе здоровья', total_III, number_percent_100( total_III, sum_total ) )
  row_two_numbers( wb, ws7, 16, 12, 13, '4 группе здоровья', total_IV, number_percent_100( total_IV, sum_total ) )
  row_two_numbers( wb, ws7, 17, 13, 13, '5 группе здоровья', total_V, number_percent_100( total_V, sum_total ) )

  empty_rows( ws7, 18, 2, 3.0 )  

  row_single_number( wb, ws7, 20, 16, 27.6, 'Общее число несовершеннолетних в возрасте 13-17 лет включительно с выявленными заболеваниями органов репродуктивной системы из прошедших профилактический осмотр в соответствующем возрасте', 0, .t. )
  row_single_number( wb, ws7, 21, 17, 27.6, 'Общее число несовершеннолетних в возрасте 13-17 лет включительно, прошедших профилактический осмотр и взятых на учет после профилактического осмотра, в том числе:', '=I23+I24+I25', .f. )
  row_single_number( wb, ws7, 22, 18, 13, 'для диспансерного наблюдения в амбулаторных условиях', '=I66+I137+I208+I263', .t. )
  row_single_number( wb, ws7, 23, 19, 13, 'для обследования и лечения в стационарных условиях за счет средств ОМС', '=I67+I138+I209+I264', .t. )
  row_single_number( wb, ws7, 24, 20, 13, 'для обследования и лечения в стационарных условиях с использованием ВМП', '=I68+I139+I210+I265', .t. )
//  row_single_number( wb, ws7, 25, 21, 13, 'Распределение несовершеннолетних в возрасте 13 - 17 лет включительно по медицинским группам для занятия физкультурой', '=I27+I28+I29+I30+I31', .f. )
  row_single_number( wb, ws7, 25, 21, 13, 'Распределение несовершеннолетних в возрасте 13 - 17 лет включительно по медицинским группам для занятия физкультурой', '=I27+I28+I29+I30', .f. )

  total_fiz1 := hYoung13_14[ 'F1' ] + hYoung15_17[ 'F1' ] + hGirl13_14[ 'F1' ] + hGirl15_17[ 'F1' ]
  total_fiz2 := hYoung13_14[ 'F2' ] + hYoung15_17[ 'F2' ] + hGirl13_14[ 'F2' ] + hGirl15_17[ 'F2' ]
  total_fiz3 := hYoung13_14[ 'F3' ] + hYoung15_17[ 'F3' ] + hGirl13_14[ 'F3' ] + hGirl15_17[ 'F3' ]
  total_fiz4 := hYoung13_14[ 'F4' ] + hYoung15_17[ 'F4' ] + hGirl13_14[ 'F4' ] + hGirl15_17[ 'F4' ]

  row_single_number( wb, ws7, 26, 22, 13, 'основная', total_fiz1, .t. )
  row_single_number( wb, ws7, 27, 23, 13, 'подготовительная', total_fiz2, .t. )
  row_single_number( wb, ws7, 28, 24, 13, 'Специальная А', total_fiz3, .t. )
  row_single_number( wb, ws7, 29, 25, 13, 'Специальная Б', total_fiz4, .t. )
  row_single_number( wb, ws7, 30, 26, 13, 'Число законченных случаев 1 этапа профилактических осмотров', '=I7', .f. )
  row_single_number( wb, ws7, 31, 27, 13, 'Представлено счетов к оплате', 0, .t. )
  row_single_number( wb, ws7, 32, 28, 13, 'из них оплачено', 0, .t. )
  row_single_number( wb, ws7, 33, 29, 13, 'Число детей, направленных на 2 этап профилактических осмотров', '=I40+I41', .f. )
  row_single_number( wb, ws7, 34, 30, 13, 'Из них: завершили 2 этап профилактических осмотров', 0, .t. )

  empty_rows( ws7, 35, 1, 3.0 )  

  worksheet_set_row( ws7, 36, 13 )
  worksheet_write_number( ws7, 36, 0, 32, text_thin_svod )
  worksheet_merge_range( ws7, 36, 1, 36, 8, 'Сведения о профилактических осмотрах подростков 13-17 лет включительно (мальчиков детскими урологами-андрологами, девочек акушерами-гинекологами) по субъекту', text_thin_svod )

  worksheet_set_row( ws7, 37, 3.0 )

  total_I   := hYoung13_14[ 'GR1' ] + hYoung15_17[ 'GR1' ]
  total_II  := hYoung13_14[ 'GR2' ] + hYoung15_17[ 'GR2' ]
  total_III := hYoung13_14[ 'GR3' ] + hYoung15_17[ 'GR3' ]
  total_IV  := hYoung13_14[ 'GR4' ] + hYoung15_17[ 'GR4' ]
  total_V   := hYoung13_14[ 'GR5' ] + hYoung15_17[ 'GR5' ]
  sum_total_young := total_I + total_II + total_III + total_IV + total_V

  total_I   := hGirl13_14[ 'GR1' ] + hGirl15_17[ 'GR1' ]
  total_II  := hGirl13_14[ 'GR2' ] + hGirl15_17[ 'GR2' ]
  total_III := hGirl13_14[ 'GR3' ] + hGirl15_17[ 'GR3' ]
  total_IV  := hGirl13_14[ 'GR4' ] + hGirl15_17[ 'GR4' ]
  total_V   := hGirl13_14[ 'GR5' ] + hGirl15_17[ 'GR5' ]
  sum_total_girl := total_I + total_II + total_III + total_IV + total_V

  worksheet_set_row( ws7, 38, 234 )
  worksheet_write_number( ws7, 38, 0, 34, text_thin_svod )
  worksheet_merge_range( ws7, 38, 1, 38, 1, 'Наименование показателя', text_thin_svod )
  worksheet_write_string( ws7, 38, 1, 'Наименование показателя', text_thin_svod_center )
  worksheet_write_string( ws7, 38, 2, 'План (подлежало осмотрам несовершеннолетних в возрасте 13-17 лет включительно, согласно статформе №30 на начало мониторируемого года) (чел)', text_thin_svod_center )
  worksheet_write_string( ws7, 38, 3, 'Факт (чел)', text_thin_svod_center )
  worksheet_write_string( ws7, 38, 4, 'Отказы (численность несовершеннолетних в возрасте 13-17 лет включительно с оформленными отказами от профилактического осмотра урологом/андрологом акушером/гинекологом) (чел)', text_thin_svod_center )
  worksheet_write_string( ws7, 38, 5, 'Процент осмотренных от численности подростков 13-17 лет, %', text_thin_svod_center )
  worksheet_write_string( ws7, 38, 6, 'Количество подростков с патологией из фактически осмотренных урологами/андрологами акушерами/гинекологами (чел)', text_thin_svod_center )
  worksheet_write_string( ws7, 38, 7, 'Количество подростков с впервые выявленной патологией (чел)', text_thin_svod_center )
  worksheet_write_string( ws7, 38, 8, 'Направлено на 2 этап для дообследования и лечения из количества подростков с патологией по результатам осмотров (чел)', text_thin_svod_center )

  row_seven_numbers( wb, ws7, 39, 34, 27.6, 'Профилактические осмотры мальчиков в возрасте 13-17 лет включительно', 0, sum_total_young, 0, '=IFERROR(ROUND(D40/C40*100,1),0)', '=I62+I133', 0, 0, .t. )
  row_seven_numbers( wb, ws7, 40, 35, 27.6, 'Профилактические осмотры девочек в возрасте 13-17 лет включительно', 0, sum_total_girl, 0, '=IFERROR(ROUND(D41/C41*100,1),0)', '=I204+I259', 0, 0, .t. )
  row_seven_numbers( wb, ws7, 41, 36, 13, 'ВСЕГО', '=C40+C41', '=D40+D41', '=E40+E41', '=IFERROR(ROUND(D42/C42*100,1),0)', '=G40+G41', '=H40+H41', '=I40+I41', .f. )

  worksheet_set_row( ws7, 42, 3.0 )
  worksheet_set_row( ws7, 43, 3.0 )
  worksheet_set_row( ws7, 44, 13 )
  worksheet_write_number( ws7, 44, 0, 40, text_thin_svod )
  worksheet_set_row( ws7, 45, 13 )
  worksheet_write_number( ws7, 45, 0, 41, text_thin_svod )
  worksheet_set_row( ws7, 46, 13 )
  worksheet_write_number( ws7, 46, 0, 42, text_thin_svod )
  worksheet_merge_range( ws7, 46, 1, 46, 7, '2', text_thin_svod_center )
  worksheet_write_string( ws7, 46, 8, '', text_thin_svod_center )

  hTemp := hGirl13_14
  total := hTemp[ 'GR1' ] + hTemp[ 'GR2' ] + hTemp[ 'GR3' ] + hTemp[ 'GR4' ] + hTemp[ 'GR5' ]

  row_single_number( wb, ws7, 47, 43, 27.6, 'Общее число девочек в возрасте 13-14 лет, подлежащих профилактическому осмотру (прикрепленного населения соответствующего возраста), согласно статформе №30-по/у на начало', 0, .t. )
  row_single_number( wb, ws7, 48, 44, 13, 'Общее число девочек в возрасте 13-14 лет, прошедших профилактический осмотр, из общего числа подлежащих профилактическому осмотру (чел)', '=H55+H56+H57+H58+H59', .f. )
  row_single_number( wb, ws7, 49, 45, 13, 'Доля девочек, прошедших профилактический осмотр в возрасте 13-14 лет, из общего числа подлежащих профилактическому осмотру (%)', 0, .t. )
  row_single_number( wb, ws7, 50, 46, 13, 'Общее число девочек в возрасте 13-14 лет с оформленным отказом от профилактического осмотра (чел)', 0, .t. )

  empty_rows( ws7, 51, 2, 3.0 )  

  worksheet_set_row( ws7, 53, 13 )
  worksheet_write_number( ws7, 53, 0, 49, text_thin_svod )
  worksheet_merge_range( ws7, 53, 1, 53, 6, 'Общее число и доля девочек в возрасте 13-14 лет из прошедших профилактический осмотр, которые были отнесены к:', text_thin_svod )
  worksheet_write_string( ws7, 53, 7, 'человек', text_thin_svod_center )
  worksheet_write_string( ws7, 53, 8, '%', text_thin_svod_center )

  row_two_numbers( wb, ws7, 54, 50, 13, '1 группе здоровья', hTemp[ 'GR1' ], '=IFERROR(H55/I49*100,0)' )
  row_two_numbers( wb, ws7, 55, 51, 13, '2 группе здоровья', hTemp[ 'GR2' ], '=IFERROR(H56/I49*100,0)' )
  row_two_numbers( wb, ws7, 56, 52, 13, '3 группе здоровья', hTemp[ 'GR3' ], '=IFERROR(H57/I49*100,0)' )
  row_two_numbers( wb, ws7, 57, 53, 13, '4 группе здоровья', hTemp[ 'GR4' ], '=IFERROR(H58/I49*100,0)' )
  row_two_numbers( wb, ws7, 58, 54, 13, '5 группе здоровья', hTemp[ 'GR5' ], '=IFERROR(H59/I49*100,0)' )

  empty_rows( ws7, 59, 2, 3.0 )  

  row_single_number( wb, ws7, 61, 57, 27.6, 'Общее число девочек в возрасте 13-14 лет с выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (чел.)', '=SUM(G71:G100)', .t. )
  row_single_number( wb, ws7, 62, 58, 27.6, 'Общее число девочек в возрасте 13-14 лет с впервые выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (чел.)', '=SUM(I71:I100)', .t. )
  row_single_number( wb, ws7, 63, 59, 13, 'Доля девочек в возрасте 13-14 лет с впервые выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (%)', '=IFERROR(ROUND(I63/I49*100,1),0)', .f. )
  row_single_number( wb, ws7, 64, 60, 13, 'Общее число девочек в возрасте 13-14 лет прошедших профилактический осмотр и взятых на учет после профилактического осмотра, в том числе:', '=I66+I67+I68', .t. )
  row_single_number( wb, ws7, 65, 61, 13, 'для диспансерного наблюдения в амбулаторных условиях (чел.)', hTemp[ 'DISPAN' ], .t. )
  row_single_number( wb, ws7, 66, 62, 13, 'для обследования и лечения в стационарных условиях за счет средств ОМС или ДМС (чел.)', hTemp[ 'STAC' ], .t. )
  row_single_number( wb, ws7, 67, 63, 13, 'для обследования и лечения в стационарных условиях с использованием ВМП (чел.)', hTemp[ 'VMP' ], .t. )

  empty_rows( ws7, 68, 1, 3.0 )  

//  worksheet_set_row( ws7, 68, 23 )
  worksheet_write_number( ws7, 69, 0, 65, text_thin_svod )
  worksheet_merge_range( ws7, 69, 1, 69, 5, 'наименование заболеваний по кодам МКБ-10, выявленных на профилактическом осмотре девочек в возрасте 13-14 лет', text_thin_svod )
  worksheet_write_string( ws7, 69, 6, 'Всего зарегистрировано заболеваний (абсолютное число)', text_thin_svod_center )
  worksheet_write_string( ws7, 69, 7, 'В пересчете на 1000 девочек соответствующег возраста (%)', text_thin_svod_center )
  worksheet_write_string( ws7, 69, 8, 'Выявлено впервые (абсолютное число)', text_thin_svod_center )

  row_SVOD_MKB10( wb, ws7, 70, 66, 13, 'E30.0 Задержка полового созревания (остутствие роста молочных желез и оволосения лобка)', hTemp[ 'E30.0' ], total )
  row_SVOD_MKB10( wb, ws7, 71, 67, 13, 'N76.1 Подострый и хронический вагинит', hTemp[ 'N76.1' ], total )
  row_SVOD_MKB10( wb, ws7, 72, 68, 13, 'N76.3 Подострый и хронический вульвит', hTemp[ 'N76.3' ], total )
  row_SVOD_MKB10( wb, ws7, 73, 69, 13, 'N76.6 Изъязвление вульвы', hTemp[ 'N76.6' ], total )
  row_SVOD_MKB10( wb, ws7, 74, 70, 13, 'N90.4 Лейкоплакия вульвы (на фоне склерозирующего лихена)', hTemp[ 'N90.4' ], total )
  row_SVOD_MKB10( wb, ws7, 75, 71, 13, 'N90.6 Гипертрофия вульвы (гипертрофия половых губ и клитора)', hTemp[ 'N90.6' ], total )
  row_SVOD_MKB10( wb, ws7, 76, 72, 13, 'N90.8 Другие уточненные невоспалительные болезни вульвы и промежности (спайки или синехии вульвы)', hTemp[ 'N90.8' ], total )
  row_SVOD_MKB10( wb, ws7, 77, 73, 13, 'D28.0 Доброкачественное образование вульвы бартолиниевой железы, фиброма, липома, гидроаденома', hTemp[ 'D28.0' ], total )
  row_SVOD_MKB10( wb, ws7, 78, 74, 13, 'A63.0 Аногенитальные (венерические) бородавки', hTemp[ 'A63.0' ], total )
  row_SVOD_MKB10( wb, ws7, 79, 75, 13, 'Q52.0 Врожденное отсутствие влагалища', hTemp[ 'Q52.0' ], total )
  row_SVOD_MKB10( wb, ws7, 80, 76, 13, 'Q52.3 Девственная плева, полностью закрывающая вход во влагалище (килевидный, решетчатый, мембранный гимен)', hTemp[ 'Q52.3' ], total )
  row_SVOD_MKB10( wb, ws7, 81, 77, 13, 'Q52.5 Сращение губ (врожденный урегинетальный синус II-V степени вирилизации по Прадеру)', hTemp[ 'Q52.5' ], total )
  row_SVOD_MKB10( wb, ws7, 82, 78, 13, 'Q56.4 Неопределенность пола неуточненная (неопределенность половых органов)', hTemp[ 'Q56.4' ], total )
  row_SVOD_MKB10( wb, ws7, 83, 79, 13, 'Q64.8 Другие уточненные врожденные аномалии мочевыделительной системы (уретра, открывающая на передней стенке влагалища)', hTemp[ 'Q64.8' ], total )
  row_SVOD_MKB10( wb, ws7, 84, 80, 13, 'N91.1 Вторичная аменорея (отсутствие менструаций в течении 3 месяцев при регулярных и 6 месяцев при нерегулярных до этого менструациях)', hTemp[ 'N91.1' ], total )
  row_SVOD_MKB10( wb, ws7, 85, 81, 13, 'N91.3 Первичная олигоминорея (менструация с промежутком более 48 дней и менее 6 месяцев)', hTemp[ 'N91.3' ], total )
  row_SVOD_MKB10( wb, ws7, 86, 82, 13, 'N91.4 Вторичная олигоминорея (менструация с промежутком более 48 дней и менее 3 месяцев при ранее регулярном ритме)', hTemp[ 'N91.4' ], total )
  row_SVOD_MKB10( wb, ws7, 87, 83, 13, 'N91.5 Олигоменорея неуточненная (скудные регулярные менструальные выделения)', hTemp[ 'N91.5' ], total )
  row_SVOD_MKB10( wb, ws7, 88, 84, 13, 'N92.2 Обильные кровотечения вначале менструального периода (обильные регулярные менструации, межменструальные маточные кровотечения)', hTemp[ 'N92.2' ], total )
  row_SVOD_MKB10( wb, ws7, 89, 85, 13, 'N94.6 Дисменорея неуточненная', hTemp[ 'N94.6' ], total )
  row_SVOD_MKB10( wb, ws7, 90, 86, 13, 'N94.3 Синдром предменструального напряжения', hTemp[ 'N94.3' ], total )
  row_SVOD_MKB10( wb, ws7, 91, 87, 13, 'N60.9 Доброкачественная дисплазия молочной железы неуточненная', hTemp[ 'N60.9' ], total )
  row_SVOD_MKB10( wb, ws7, 92, 88, 13, 'N61 Воспалительные болезни молочной железы (мастит, карбункул, абсцесс)', hTemp[ 'N61' ], total )
  row_SVOD_MKB10( wb, ws7, 93, 89, 13, 'N62 Гипертрофия молочной железы (массивная пубертатная)', hTemp[ 'N62' ], total )
  row_SVOD_MKB10( wb, ws7, 94, 90, 13, 'N63 Образование в молочной железе неуточненное (узелок/узелки в молочной железе без диагностического уточнения)', hTemp[ 'N63' ], total )
  row_SVOD_MKB10( wb, ws7, 95, 91, 13, 'Q83 Врожденные аномалии [пороки развития] молочной железы', hTemp[ 'Q83' ], total )
  row_SVOD_MKB10( wb, ws7, 96, 92, 13, 'N64.4 Мастодиния', hTemp[ 'N64.4' ], total )
  row_SVOD_MKB10( wb, ws7, 97, 93, 13, 'L70.0 Угри обыкновенные', hTemp[ 'L70.0' ], total )
  row_SVOD_MKB10( wb, ws7, 98, 94, 13, 'L68.0 Гирсутизм', hTemp[ 'L68.0' ], total )
  row_SVOD_MKB10( wb, ws7, 99, 95, 13, 'Z33 Состояние свойственное беременности (состояние беременности)', hTemp[ 'Z33' ], total )

  worksheet_set_row( ws7, 100, 3.0 )
  worksheet_set_row( ws7, 101, 3.0 )

  worksheet_set_row( ws7, 102, 75 )
  worksheet_write_number( ws7, 102, 0, 98, text_thin_svod )
  worksheet_merge_range( ws7, 102, 1, 102, 5, 'Общее число девочек в возрасте 13-14 лет с выявленными факторами риска нарушений репродуктивной системы по кодам МКБ-10 по результатам профилактических осмотров', text_thin_svod )
  worksheet_write_string( ws7, 102, 6, 'абсолютное число)', text_thin_svod_center )
  worksheet_write_string( ws7, 102, 7, 'на 1000 девочек соответствующег возраста', text_thin_svod_center )
  worksheet_write_string( ws7, 102, 8, 'Выявлено впервые (абсолютное число)', text_thin_svod_center )

  row_SVOD_MKB10( wb, ws7, 103, 99, 13, 'E40 - E46 Недостаточность питания', hTemp[ 'E40_E46' ], total )
  row_SVOD_MKB10( wb, ws7, 104, 100, 13, 'E66 Ожирение', hTemp[ 'E66' ], total )
  row_SVOD_MKB10( wb, ws7, 105, 101, 13, 'E10 Сахарный диабет I типа', hTemp[ 'E10' ], total )
  row_SVOD_MKB10( wb, ws7, 106, 102, 13, 'Z72.1 Употребление алкоголя', hTemp[ 'Z72.1' ], total )
  row_SVOD_MKB10( wb, ws7, 107, 103, 13, 'Z72.2 Использование наркотиков', hTemp[ 'Z72.2' ], total )
  row_SVOD_MKB10( wb, ws7, 108, 104, 13, 'Z72.0 Курение табака (ежедневное выкуривание одной сигареты и более)', hTemp[ 'Z72.0' ], total )
  row_SVOD_MKB10( wb, ws7, 109, 105, 13, 'E89.4 Нарушение функции яичников, возникшее после медицинских процедур', hTemp[ 'E89.4' ], total )
  row_SVOD_MKB10( wb, ws7, 110, 106, 13, 'Y83.2-4 Хирургические операции и другие хирургические процедуры как причина аномальной реакции или позднего осложнения у пациента без упоминания о случайном нанесении ему вреда во', hTemp[ 'Y83.2_4' ], total )
  row_SVOD_MKB10( wb, ws7, 111, 107, 13, 'Z91.2 В личном анамнезе о неудовлетворительное соблюдение личной гигиены', hTemp[ 'Z91.2' ], total )
  row_SVOD_MKB10( wb, ws7, 112, 108, 13, 'Z91.3 В личном анамнезе нарушение режима сна/бодрствования (исключены нарушения сна - G47. -)', hTemp[ 'Z91.3' ], total )

  worksheet_set_row( ws7, 113, 3.0 )
  worksheet_set_row( ws7, 114, 3.0 )

  hTemp := hGirl15_17
  total := hTemp[ 'GR1' ] + hTemp[ 'GR2' ] + hTemp[ 'GR3' ] + hTemp[ 'GR4' ] + hTemp[ 'GR5' ]

  worksheet_set_row( ws7, 115, 13 )
  worksheet_write_number( ws7, 115, 0, 111, text_thin_svod )
  worksheet_merge_range( ws7, 115, 1, 115, 8, '15-17 лет девочки', text_thin_svod )
  worksheet_set_row( ws7, 116, 3.0 )

  worksheet_set_row( ws7, 117, 13 )
  worksheet_write_number( ws7, 117, 0, 113, text_thin_svod )
  worksheet_merge_range( ws7, 117, 1, 117, 7, '2', text_thin_svod_center )
  worksheet_write_string( ws7, 117, 8, 'x', text_thin_svod_center )

  row_single_number( wb, ws7, 118, 114, 13, 'Общее число девочек в возрасте 15-17 лет, подлежащих профилактическому осмотру (прикрепленного населения соответствующего возраста), согласно статформе №30-по/у на начало', "'15-17 лет'!A21", .f. )
  row_single_number( wb, ws7, 119, 115, 13, 'Общее число девочек в возрасте 15-17 лет, прошедших профилактический осмотр, из общего числа подлежащих профилактическому осмотру (чел)', "'15-17 лет'!C21", .f. )
  row_single_number( wb, ws7, 120, 116, 13, 'Доля девочек, прошедших профилактический осмотр в возрасте 15-17 лет, из общего числа подлежащих профилактическому осмотру (%)', 0, .f. )
  row_single_number( wb, ws7, 121, 117, 13, 'Общее число девочек в возрасте 15-17 лет с оформленным отказом от профилактического осмотра (чел)', 0, .t. )

  empty_rows( ws7, 122, 2, 3.0 )  

  worksheet_set_row( ws7, 124, 13 )
  worksheet_write_number( ws7, 124, 0, 120, text_thin_svod )
  worksheet_merge_range( ws7, 124, 1, 124, 6, 'Общее число и доля девочек в возрасте 15-17 лет из прошедших профилактический осмотр, которые были отнесены к:', text_thin_svod )
  worksheet_write_string( ws7, 124, 7, 'человек', text_thin_svod_center )
  worksheet_write_string( ws7, 124, 8, '%', text_thin_svod_center )

  row_two_numbers( wb, ws7, 125, 121, 13, '1 группе здоровья', hTemp[ 'GR1' ], '=IFERROR(H126/I120*100,0)' )
  row_two_numbers( wb, ws7, 126, 122, 13, '2 группе здоровья', hTemp[ 'GR2' ], '=IFERROR(H127/I120*100,0)' )
  row_two_numbers( wb, ws7, 127, 123, 13, '3 группе здоровья', hTemp[ 'GR3' ], '=IFERROR(H128/I120*100,0)' )
  row_two_numbers( wb, ws7, 128, 124, 13, '4 группе здоровья', hTemp[ 'GR4' ], '=IFERROR(H129/I120*100,0)' )
  row_two_numbers( wb, ws7, 129, 125, 13, '5 группе здоровья', hTemp[ 'GR5' ], '=IFERROR(H130/I120*100,0)' )

  empty_rows( ws7, 130, 2, 3.0 )  

  row_single_number( wb, ws7, 132, 128, 13, 'Общее число девочек в возрасте 15-17 лет с выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (чел.)', '=SUM(G142:G171)', .t. )
  row_single_number( wb, ws7, 133, 129, 13, 'Общее число девочек в возрасте 15-17 лет с впервые выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (чел.)', '=SUM(I142:I171)', .t. )
  row_single_number( wb, ws7, 134, 130, 13, 'Доля девочек в возрасте 15-17 лет с впервые выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (%)', '=IFERROR(ROUND(I134/I120*100,1),0)', .f. )
  row_single_number( wb, ws7, 135, 131, 13, 'Общее число девочек в возрасте 15-17 лет прошедших профилактический осмотр и взятых на учет после профилактического осмотра, в том числе:', '=I137+I138+I139', .t. )
  row_single_number( wb, ws7, 136, 132, 13, 'для диспансерного наблюдения в амбулаторных условиях (чел.)', hTemp[ 'DISPAN' ], .t. )
  row_single_number( wb, ws7, 137, 133, 13, 'для обследования и лечения в стационарных условиях за счет средств ОМС или ДМС (чел.)', hTemp[ 'STAC' ], .t. )
  row_single_number( wb, ws7, 138, 134, 13, 'для обследования и лечения в стационарных условиях с использованием ВМП (чел.)', hTemp[ 'VMP' ], .t. )

  empty_rows( ws7, 139, 1, 3.0 )  

  worksheet_set_row( ws7, 140, 79.2 )
  worksheet_write_number( ws7, 140, 0, 136, text_thin_svod )
  worksheet_merge_range( ws7, 140, 1, 140, 5, 'наименование заболеваний по кодам МКБ-10, выявленных на профилактическом осмотре девочек в возрасте 15-17 лет', text_thin_svod )
  worksheet_write_string( ws7, 140, 6, 'Всего зарегистрировано заболеваний (абсолютное число)', text_thin_svod_center )
  worksheet_write_string( ws7, 140, 7, 'В пересчете на 1000 девочек соответствующег возраста (%)', text_thin_svod_center )
  worksheet_write_string( ws7, 140, 8, 'Выявлено впервые (абсолютное число)', text_thin_svod_center )

  row_SVOD_MKB10( wb, ws7, 141, 137, 13, 'E30.0 Задержка полового созревания (остутствие роста молочных желез и оволосения лобка)', hTemp[ 'E30.0' ], total )
  row_SVOD_MKB10( wb, ws7, 142, 138, 13, 'N76.1 Подострый и хронический вагинит', hTemp[ 'N76.1' ], total )
  row_SVOD_MKB10( wb, ws7, 143, 139, 13, 'N76.3 Подострый и хронический вульвит', hTemp[ 'N76.3' ], total )
  row_SVOD_MKB10( wb, ws7, 144, 140, 13, 'N76.6 Изъязвление вульвы', hTemp[ 'N76.6' ], total )
  row_SVOD_MKB10( wb, ws7, 145, 141, 13, 'N90.4 Лейкоплакия вульвы (на фоне склерозирующего лихена)', hTemp[ 'N90.4' ], total )
  row_SVOD_MKB10( wb, ws7, 146, 142, 13, 'N90.6 Гипертрофия вульвы (гипертрофия половых губ и клитора)', hTemp[ 'N90.6' ], total )
  row_SVOD_MKB10( wb, ws7, 147, 143, 13, 'N90.8 Другие уточненные невоспалительные болезни вульвы и промежности (спайки или синехии вульвы)', hTemp[ 'N90.8' ], total )
  row_SVOD_MKB10( wb, ws7, 148, 144, 13, 'D28.0 Доброкачественное образование вульвы бартолиниевой железы, фиброма, липома, гидроаденома', hTemp[ 'D28.0' ], total )
  row_SVOD_MKB10( wb, ws7, 149, 145, 13, 'A63.0 Аногенитальные (венерические) бородавки', hTemp[ 'A63.0' ], total )
  row_SVOD_MKB10( wb, ws7, 150, 146, 13, 'Q52.0 Врожденное отсутствие влагалища', hTemp[ 'Q52.0' ], total )
  row_SVOD_MKB10( wb, ws7, 151, 147, 13, 'Q52.3 Девственная плева, полностью закрывающая вход во влагалище (килевидный, решетчатый, мембранный гимен)', hTemp[ 'Q52.3' ], total )
  row_SVOD_MKB10( wb, ws7, 152, 148, 13, 'Q52.5 Сращение губ (врожденный урегинетальный синус II-V степени вирилизации по Прадеру)', hTemp[ 'Q52.5' ], total )
  row_SVOD_MKB10( wb, ws7, 153, 149, 13, 'Q56.4 Неопределенность пола неуточненная (неопределенность половых органов)', hTemp[ 'Q56.4' ], total )
  row_SVOD_MKB10( wb, ws7, 154, 150, 13, 'Q64.8 Другие уточненные врожденные аномалии мочевыделительной системы (уретра, открывающая на передней стенке влагалища)', hTemp[ 'Q64.8' ], total )
  row_SVOD_MKB10( wb, ws7, 155, 151, 13, 'N91.1 Вторичная аменорея (отсутствие менструаций в течении 3 месяцев при регулярных и 6 месяцев при нерегулярных до этого менструациях)', hTemp[ 'N91.1' ], total )
  row_SVOD_MKB10( wb, ws7, 156, 152, 13, 'N91.3 Первичная олигоминорея (менструация с промежутком более 48 дней и менее 6 месяцев)', hTemp[ 'N91.3' ], total )
  row_SVOD_MKB10( wb, ws7, 157, 153, 13, 'N91.4 Вторичная олигоминорея (менструация с промежутком более 48 дней и менее 3 месяцев при ранее регулярном ритме)', hTemp[ 'N91.4' ], total )
  row_SVOD_MKB10( wb, ws7, 158, 154, 13, 'N91.5 Олигоменорея неуточненная (скудные регулярные менструальные выделения)', hTemp[ 'N91.5' ], total )
  row_SVOD_MKB10( wb, ws7, 159, 155, 13, 'N92.2 Обильные кровотечения вначале менструального периода (обильные регулярные менструации, межменструальные маточные кровотечения)', hTemp[ 'N92.2' ], total )
  row_SVOD_MKB10( wb, ws7, 160, 156, 13, 'N94.6 Дисменорея неуточненная', hTemp[ 'N94.6' ], total )
  row_SVOD_MKB10( wb, ws7, 161, 157, 13, 'N94.3 Синдром предменструального напряжения', hTemp[ 'N94.3' ], total )
  row_SVOD_MKB10( wb, ws7, 162, 158, 13, 'N60.9 Доброкачественная дисплазия молочной железы неуточненная', hTemp[ 'N60.9' ], total )
  row_SVOD_MKB10( wb, ws7, 163, 159, 13, 'N61 Воспалительные болезни молочной железы (мастит, карбункул, абсцесс)', hTemp[ 'N61' ], total )
  row_SVOD_MKB10( wb, ws7, 164, 160, 13, 'N62 Гипертрофия молочной железы (массивная пубертатная)', hTemp[ 'N62' ], total )
  row_SVOD_MKB10( wb, ws7, 165, 161, 13, 'N63 Образование в молочной железе неуточненное (узелок/узелки в молочной железе без диагностического уточнения)', hTemp[ 'N63' ], total )
  row_SVOD_MKB10( wb, ws7, 166, 162, 13, 'Q83 Врожденные аномалии [пороки развития] молочной железы', hTemp[ 'Q83' ], total )
  row_SVOD_MKB10( wb, ws7, 167, 163, 13, 'N64.4 Мастодиния', hTemp[ 'N64.4' ], total )
  row_SVOD_MKB10( wb, ws7, 168, 164, 13, 'L70.0 Угри обыкновенные', hTemp[ 'L70.0' ], total )
  row_SVOD_MKB10( wb, ws7, 169, 165, 13, 'L68.0 Гирсутизм', hTemp[ 'L68.0' ], total )
  row_SVOD_MKB10( wb, ws7, 170, 166, 13, 'Z33 Состояние свойственное беременности (состояние беременности)', hTemp[ 'Z33' ], total )

  empty_rows( ws7, 171, 2, 3.0 )  

  worksheet_set_row( ws7, 172, 75 )
  worksheet_write_number( ws7, 172, 0, 167, text_thin_svod )
  worksheet_merge_range( ws7, 172, 1, 172, 5, 'Общее число девочек в возрасте 15-17 лет с выявленными факторами риска нарушений репродуктивной системы по кодам МКБ-10 по результатам профилактических осмотров', text_thin_svod )
  worksheet_write_string( ws7, 172, 6, 'абсолютное число)', text_thin_svod_center )
  worksheet_write_string( ws7, 172, 7, 'на 1000 девочек соответствующег возраста', text_thin_svod_center )
  worksheet_write_string( ws7, 172, 8, 'Выявлено впервые (абсолютное число)', text_thin_svod_center )

  row_SVOD_MKB10( wb, ws7, 173, 168, 13, 'E40 - E46 Недостаточность питания', hTemp[ 'E40_E46' ], total )
  row_SVOD_MKB10( wb, ws7, 174, 169, 13, 'E66 Ожирение', hTemp[ 'E66' ], total )
  row_SVOD_MKB10( wb, ws7, 175, 170, 13, 'E10 Сахарный диабет I типа', hTemp[ 'E10' ], total )
  row_SVOD_MKB10( wb, ws7, 176, 171, 13, 'Z72.1 Употребление алкоголя', hTemp[ 'Z72.1' ], total )
  row_SVOD_MKB10( wb, ws7, 177, 172, 13, 'Z72.2 Использование наркотиков', hTemp[ 'Z72.2' ], total )
  row_SVOD_MKB10( wb, ws7, 178, 173, 13, 'Z72.0 Курение табака (ежедневное выкуривание одной сигареты и более)', hTemp[ 'Z72.0' ], total )
  row_SVOD_MKB10( wb, ws7, 179, 174, 13, 'E89.4 Нарушение функции яичников, возникшее после медицинских процедур', hTemp[ 'E89.4' ], total )
  row_SVOD_MKB10( wb, ws7, 180, 175, 13, 'Y83.2-4 Хирургические операции и другие хирургические процедуры как причина аномальной реакции или позднего осложнения у пациента без упоминания о случайном нанесении ему вреда во', hTemp[ 'Y83.2_4' ], total )
  row_SVOD_MKB10( wb, ws7, 181, 176, 13, 'Z91.2 В личном анамнезе о неудовлетворительное соблюдение личной гигиены', hTemp[ 'Z91.2' ], total )
  row_SVOD_MKB10( wb, ws7, 182, 177, 13, 'Z91.3 В личном анамнезе нарушение режима сна/бодрствования (исключены нарушения сна - G47. -)', hTemp[ 'Z91.3' ], total )

  empty_rows( ws7, 183, 2, 3.0 )  

  hTemp := hYoung13_14
  total := hTemp[ 'GR1' ] + hTemp[ 'GR2' ] + hTemp[ 'GR3' ] + hTemp[ 'GR4' ] + hTemp[ 'GR5' ]

  worksheet_write_number( ws7, 185, 0, 182, text_thin_svod )
  worksheet_merge_range( ws7, 185, 1, 185, 8, '13-14 лет мальчики', text_thin_svod_center )

  empty_rows( ws7, 186, 2, 3.0 )  

  worksheet_set_row( ws7, 188, 13 )
  worksheet_write_number( ws7, 188, 0, 184, text_thin_svod )
  worksheet_merge_range( ws7, 188, 1, 188, 7, '2', text_thin_svod_center )
  worksheet_write_string( ws7, 188, 8, 'x', text_thin_svod_center )
  row_single_number( wb, ws7, 189, 185, 27.6, 'Общее число мальчиков в возрасте 13-14 лет, подлежащих профилактическому осмотру (прикрепленного населения соответствующего возраста), согласно статформе №30-по/у на начало', 0, .t. )
  row_single_number( wb, ws7, 190, 186, 13, 'Общее число мальчиков в возрасте 13-14 лет, прошедших профилактический осмотр, из общего числа подлежащих профилактическому осмотру (чел)', '=H197+H198+H199+H200+H201', .f. )
  row_single_number( wb, ws7, 191, 187, 13, 'Доля мальчиков, прошедших профилактический осмотр в возрасте 13-14 лет, из общего числа подлежащих профилактическому осмотру (%)', 0, .f. )
  row_single_number( wb, ws7, 192, 188, 13, 'Общее число мальчиков в возрасте 13-14 лет с оформленным отказом от профилактического осмотра (чел)', 0, .t. )

  empty_rows( ws7, 193, 2, 3.0 )  

  worksheet_set_row( ws7, 195, 13 )
  worksheet_write_number( ws7, 195, 0, 191, text_thin_svod )
  worksheet_merge_range( ws7, 195, 1, 195, 6, 'Общее число и доля мальчиков в возрасте 13-14 лет из прошедших профилактический осмотр, которые были отнесены к:', text_thin_svod )
  worksheet_write_string( ws7, 195, 7, 'человек', text_thin_svod_center )
  worksheet_write_string( ws7, 195, 8, '%', text_thin_svod_center )

  row_two_numbers( wb, ws7, 196, 192, 13, '1 группе здоровья', hTemp[ 'GR1' ], '=IFERROR(H197/I191*100,0)' )
  row_two_numbers( wb, ws7, 197, 193, 13, '2 группе здоровья', hTemp[ 'GR2' ], '=IFERROR(H198/I191*100,0)' )
  row_two_numbers( wb, ws7, 198, 194, 13, '3 группе здоровья', hTemp[ 'GR3' ], '=IFERROR(H199/I191*100,0)' )
  row_two_numbers( wb, ws7, 199, 195, 13, '4 группе здоровья', hTemp[ 'GR4' ], '=IFERROR(H200/I191*100,0)' )
  row_two_numbers( wb, ws7, 200, 196, 13, '5 группе здоровья', hTemp[ 'GR5' ], '=IFERROR(H200/I191*100,0)' )

  empty_rows( ws7, 201, 2, 3.0 )  

  row_single_number( wb, ws7, 203, 199, 13, 'Общее число мальчиков в возрасте 13-14 лет с выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (чел.)', '=SUM(G213:G227)', .t. )
  row_single_number( wb, ws7, 204, 200, 13, 'Общее число мальчиков в возрасте 13-14 лет с впервые выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (чел.)', '=SUM(I213:I227)', .t. )
  row_single_number( wb, ws7, 205, 201, 13, 'Доля мальчиков в возрасте 13-14 лет с впервые выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (%)', '=IFERROR(ROUND(I205/I191*100,1),0)', .f. )
  row_single_number( wb, ws7, 206, 202, 13, 'Общее число мальчиков в возрасте 13-14 лет прошедших профилактический осмотр и взятых на учет после профилактического осмотра, в том числе:', '=I208+I209+I210', .t. )
  row_single_number( wb, ws7, 207, 203, 13, 'для диспансерного наблюдения в амбулаторных условиях (чел.)', hTemp[ 'DISPAN' ], .t. )
  row_single_number( wb, ws7, 208, 204, 13, 'для обследования и лечения в стационарных условиях за счет средств ОМС или ДМС (чел.)', hTemp[ 'STAC' ], .t. )
  row_single_number( wb, ws7, 209, 205, 13, 'для обследования и лечения в стационарных условиях с использованием ВМП (чел.)', hTemp[ 'VMP' ], .t. )

  empty_rows( ws7, 210, 1, 3.0 )

  worksheet_set_row( ws7, 211, 79.2 )
  worksheet_write_number( ws7, 211, 0, 207, text_thin_svod )
  worksheet_merge_range( ws7, 211, 1, 211, 5, 'наименование заболеваний по кодам МКБ-10, выявленных на профилактическом осмотре мальчиков в возрасте 13-14 лет', text_thin_svod )
  worksheet_write_string( ws7, 211, 6, 'Всего зарегистрировано заболеваний (абсолютное число)', text_thin_svod_center )
  worksheet_write_string( ws7, 211, 7, 'В пересчете на 1000 мальчиков соответствующег возраста (%)', text_thin_svod_center )
  worksheet_write_string( ws7, 211, 8, 'Выявлено впервые (абсолютное число)', text_thin_svod_center )

  row_SVOD_MKB10( wb, ws7, 212, 208, 13, 'E30.0 Задержка полового созревания (отсутствие или слабое развитие оволосения лобка, яички объемом менее 4 куб. см, непигментированная мошонка, "детский" половой член)', hTemp[ 'E30.0' ], total )
  row_SVOD_MKB10( wb, ws7, 213, 209, 13, 'N43 Гидроцеле или сперматоцеле (водянка семенного канатика, яичка или влагалищной оболочки яичка)', hTemp[ 'N43' ], total )
  row_SVOD_MKB10( wb, ws7, 214, 210, 13, 'N45 Орхит, эпидидимит, эпидимоорхит', hTemp[ 'N45' ], total )
  row_SVOD_MKB10( wb, ws7, 215, 211, 13, 'N47 Избыточная крайняя плоть, фимоз и парафимоз', hTemp[ 'N47' ], total )
  row_SVOD_MKB10( wb, ws7, 216, 212, 13, 'N48.0 Лейкоплакия полового члена (облитерирущий ксеротический балонопостит, склеротический лихен или крауроз)', hTemp[ 'N48.0' ], total )
  row_SVOD_MKB10( wb, ws7, 217, 213, 13, 'N48.1 Баланопостит (баланит)', hTemp[ 'N48.1' ], total )
  row_SVOD_MKB10( wb, ws7, 218, 214, 13, 'N50.0 Атрофия яичка', hTemp[ 'N50.0' ], total )
  row_SVOD_MKB10( wb, ws7, 219, 215, 13, 'A63.0 Аногенитальные (венерические) бородавки', hTemp[ 'A63.0' ], total )
  row_SVOD_MKB10( wb, ws7, 220, 216, 13, 'I86.1 Варикозное расширение вен мошонки', hTemp[ 'I86.1' ], total )
  row_SVOD_MKB10( wb, ws7, 221, 217, 13, 'Q53 Неопущение яичка', hTemp[ 'Q53' ], total )
  row_SVOD_MKB10( wb, ws7, 222, 218, 13, 'Q54 Гипоспадия', hTemp[ 'Q54' ], total )
  row_SVOD_MKB10( wb, ws7, 223, 219, 13, 'Q55 Другие врожденные аномалии (пороки развития) мужских половых органов', hTemp[ 'Q55' ], total )
  row_SVOD_MKB10( wb, ws7, 224, 220, 13, 'Q64.0 Эписпадия', hTemp[ 'Q64.0' ], total )
  row_SVOD_MKB10( wb, ws7, 225, 221, 13, 'N62 Гипертрофия молочной железы (гинекомастия)', hTemp[ 'N62' ], total )
  row_SVOD_MKB10( wb, ws7, 226, 222, 13, 'L70.0 Угри обыкновенные', hTemp[ 'L70.0' ], total )

  empty_rows( ws7, 227, 2, 3.0 )  

  worksheet_set_row( ws7, 229, 75 )
  worksheet_write_number( ws7, 229, 0, 225, text_thin_svod )
  worksheet_merge_range( ws7, 229, 1, 229, 5, 'Число мальчиков в возрасте 13-14 лет с выявленными факторами риска нарушений репродуктивной системы по кодам МКБ-10 по результатам профилактических осмотров', text_thin_svod )
  worksheet_write_string( ws7, 229, 6, 'абсолютное число', text_thin_svod_center )
  worksheet_write_string( ws7, 229, 7, 'на 1000 мальчиков соответствующег возраста', text_thin_svod_center )
  worksheet_write_string( ws7, 229, 8, 'Выявлено впервые (абсолютное число)', text_thin_svod_center )

  row_SVOD_MKB10( wb, ws7, 230, 226, 13, 'E40 - E46 Недостаточность питания', hTemp[ 'E40_E46' ], total )
  row_SVOD_MKB10( wb, ws7, 231, 227, 13, 'E66 Ожирение', hTemp[ 'E66' ], total )
  row_SVOD_MKB10( wb, ws7, 232, 228, 13, 'E10 Сахарный диабет I типа', hTemp[ 'E10' ], total )
  row_SVOD_MKB10( wb, ws7, 233, 229, 13, 'Z72.1 Употребление алкоголя', hTemp[ 'Z72.1' ], total )
  row_SVOD_MKB10( wb, ws7, 234, 230, 13, 'Z72.2 Использование наркотиков', hTemp[ 'Z72.2' ], total )
  row_SVOD_MKB10( wb, ws7, 235, 231, 13, 'Z72.0 Курение табака (ежедневное выкуривание одной сигареты и более)', hTemp[ 'Z72.0' ], total )
  row_SVOD_MKB10( wb, ws7, 236, 232, 13, 'Y83.2-4 Хирургические операции и другие хирургические процедуры как причина аномальной реакции или позднего осложнения у пациента без упоминания о случайном нанесении ему вреда во', hTemp[ 'Y83.2_4' ], total )
  row_SVOD_MKB10( wb, ws7, 237, 233, 13, 'Z91.2 В личном анамнезе о неудовлетворительное соблюдение личной гигиены', hTemp[ 'Z91.2' ], total )
  row_SVOD_MKB10( wb, ws7, 238, 234, 13, 'Z91.3 В личном анамнезе нарушение режима сна/бодрствования (исключены нарушения сна - G47. -)', hTemp[ 'Z91.3' ], total )

  empty_rows( ws7, 239, 2, 3.0 )

  hTemp := hYoung15_17
  total := hTemp[ 'GR1' ] + hTemp[ 'GR2' ] + hTemp[ 'GR3' ] + hTemp[ 'GR4' ] + hTemp[ 'GR5' ]

  worksheet_write_number( ws7, 241, 0, 237, text_thin_svod )
  worksheet_merge_range( ws7, 241, 1, 241, 8, '15-17 лет мальчики', text_thin_svod_center )

  empty_rows( ws7, 242, 1, 3.0 )  

  worksheet_set_row( ws7, 243, 13 )
  worksheet_write_number( ws7, 243, 0, 239, text_thin_svod )
  worksheet_merge_range( ws7, 243, 1, 243, 7, '2', text_thin_svod_center )
  worksheet_write_string( ws7, 243, 8, 'x', text_thin_svod_center )
  row_single_number( wb, ws7, 244, 240, 27.6, 'Общее число мальчиков в возрасте 15-17 лет, подлежащих профилактическому осмотру (прикрепленного населения соответствующего возраста), согласно статформе №30-по/у на начало', "'15-17 лет'!A15", .f. )
  row_single_number( wb, ws7, 245, 241, 13, 'Общее число мальчиков в возрасте 15-17 лет, прошедших профилактический осмотр, из общего числа подлежащих профилактическому осмотру (чел)', "'15-17 лет'!C15", .f. )
  row_single_number( wb, ws7, 246, 242, 13, 'Доля мальчиков, прошедших профилактический осмотр в возрасте 15-17 лет, из общего числа подлежащих профилактическому осмотру (%)', 0, .f. )
  row_single_number( wb, ws7, 247, 243, 13, 'Общее число мальчиков в возрасте 15-17 лет с оформленным отказом от профилактического осмотра (чел)', 0, .t. )

  empty_rows( ws7, 248, 2, 3.0 )  

  worksheet_set_row( ws7, 250, 13 )
  worksheet_write_number( ws7, 250, 0, 246, text_thin_svod )
  worksheet_merge_range( ws7, 250, 1, 250, 6, 'Общее число и доля мальчиков в возрасте 15-17 лет из прошедших профилактический осмотр, которые были отнесены к:', text_thin_svod )
  worksheet_write_string( ws7, 250, 7, 'человек', text_thin_svod_center )
  worksheet_write_string( ws7, 250, 8, '%', text_thin_svod_center )

  row_two_numbers( wb, ws7, 251, 247, 13, '1 группе здоровья', hTemp[ 'GR1' ], '=IFERROR(H252/I246*100,0)' )
  row_two_numbers( wb, ws7, 252, 248, 13, '2 группе здоровья', hTemp[ 'GR2' ], '=IFERROR(H252/I247*100,0)' )
  row_two_numbers( wb, ws7, 253, 249, 13, '3 группе здоровья', hTemp[ 'GR3' ], '=IFERROR(H252/I248*100,0)' )
  row_two_numbers( wb, ws7, 254, 250, 13, '4 группе здоровья', hTemp[ 'GR4' ], '=IFERROR(H252/I249*100,0)' )
  row_two_numbers( wb, ws7, 255, 251, 13, '5 группе здоровья', hTemp[ 'GR5' ], '=IFERROR(H252/I250*100,0)' )

  empty_rows( ws7, 256, 2, 3.0 )  

  row_single_number( wb, ws7, 258, 254, 13, 'Общее число мальчиков в возрасте 15-17 лет с выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (чел.)', '=SUM(G268:G282)', .t. )
  row_single_number( wb, ws7, 259, 255, 13, 'Общее число мальчиков в возрасте 15-17 лет с впервые выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (чел.)', '=SUM(I268:I282)', .t. )
  row_single_number( wb, ws7, 260, 256, 13, 'Доля мальчиков в возрасте 15-17 лет с впервые выявленными заболеваниями половых органов и молочных желез из прошедших профилактический осмотр (%)', '=IFERROR(ROUND(I260/I246*100,1),0)', .f. )
  row_single_number( wb, ws7, 261, 257, 13, 'Общее число мальчиков в возрасте 15-17 лет прошедших профилактический осмотр и взятых на учет после профилактического осмотра, в том числе:', '=I263+I264+I265', .t. )
  row_single_number( wb, ws7, 262, 258, 13, 'для диспансерного наблюдения в амбулаторных условиях (чел.)', hTemp[ 'DISPAN' ], .t. )
  row_single_number( wb, ws7, 263, 259, 13, 'для обследования и лечения в стационарных условиях за счет средств ОМС или ДМС (чел.)', hTemp[ 'STAC' ], .t. )
  row_single_number( wb, ws7, 264, 260, 13, 'для обследования и лечения в стационарных условиях с использованием ВМП (чел.)', hTemp[ 'VMP' ], .t. )

  empty_rows( ws7, 265, 1, 3.0 )

  worksheet_set_row( ws7, 266, 79.2 )
  worksheet_write_number( ws7, 265, 0, 262, text_thin_svod )
  worksheet_merge_range( ws7, 266, 1, 266, 5, 'наименование заболеваний по кодам МКБ-10, выявленных на профилактическом осмотре мальчиков в возрасте 15-17 лет', text_thin_svod )
  worksheet_write_string( ws7, 266, 6, 'Всего зарегистрировано заболеваний (абсолютное число)', text_thin_svod_center )
  worksheet_write_string( ws7, 266, 7, 'В пересчете на 1000 мальчиков соответствующег возраста (%)', text_thin_svod_center )
  worksheet_write_string( ws7, 266, 8, 'Выявлено впервые (абсолютное число)', text_thin_svod_center )

  row_SVOD_MKB10( wb, ws7, 267, 263, 13, 'E30.0 Задержка полового созревания (отсутствие или слабое развитие оволосения лобка, яички объемом менее 4 куб. см, непигментированная мошонка, "детский" половой член)', hTemp[ 'E30.0' ], total )
  row_SVOD_MKB10( wb, ws7, 268, 264, 13, 'N43 Гидроцеле или сперматоцеле (водянка семенного канатика, яичка или влагалищной оболочки яичка)', hTemp[ 'N43' ], total )
  row_SVOD_MKB10( wb, ws7, 269, 265, 13, 'N45 Орхит, эпидидимит, эпидимоорхит', hTemp[ 'N45' ], total )
  row_SVOD_MKB10( wb, ws7, 270, 266, 13, 'N47 Избыточная крайняя плоть, фимоз и парафимоз', hTemp[ 'N47' ], total )
  row_SVOD_MKB10( wb, ws7, 271, 267, 13, 'N48.0 Лейкоплакия полового члена (облитерирущий ксеротический балонопостит, склеротический лихен или крауроз)', hTemp[ 'N48.0' ], total )
  row_SVOD_MKB10( wb, ws7, 272, 268, 13, 'N48.1 Баланопостит (баланит)', hTemp[ 'N48.1' ], total )
  row_SVOD_MKB10( wb, ws7, 273, 269, 13, 'N50.0 Атрофия яичка', hTemp[ 'N50.0' ], total )
  row_SVOD_MKB10( wb, ws7, 274, 270, 13, 'A63.0 Аногенитальные (венерические) бородавки', hTemp[ 'A63.0' ], total )
  row_SVOD_MKB10( wb, ws7, 275, 271, 13, 'I86.1 Варикозное расширение вен мошонки', hTemp[ 'I86.1' ], total )
  row_SVOD_MKB10( wb, ws7, 276, 272, 13, 'Q53 Неопущение яичка', hTemp[ 'Q53' ], total )
  row_SVOD_MKB10( wb, ws7, 277, 273, 13, 'Q54 Гипоспадия', hTemp[ 'Q54' ], total )
  row_SVOD_MKB10( wb, ws7, 278, 274, 13, 'Q55 Другие врожденные аномалии (пороки развития) мужских половых органов', hTemp[ 'Q55' ], total )
  row_SVOD_MKB10( wb, ws7, 279, 275, 13, 'Q64.0 Эписпадия', hTemp[ 'Q64.0' ], total )
  row_SVOD_MKB10( wb, ws7, 280, 276, 13, 'N62 Гипертрофия молочной железы (гинекомастия)', hTemp[ 'N62' ], total )
  row_SVOD_MKB10( wb, ws7, 281, 277, 13, 'L70.0 Угри обыкновенные', hTemp[ 'L70.0' ], total )

  empty_rows( ws7, 282, 2, 3.0 )  

  worksheet_set_row( ws7, 284, 75 )
  worksheet_write_number( ws7, 284, 0, 280, text_thin_svod )
  worksheet_merge_range( ws7, 284, 1, 284, 5, 'Число мальчиков в возрасте 15-17 лет с выявленными факторами риска нарушений репродуктивной системы по кодам МКБ-10 по результатам профилактических осмотров', text_thin_svod )
  worksheet_write_string( ws7, 284, 6, 'абсолютное число', text_thin_svod_center )
  worksheet_write_string( ws7, 284, 7, 'на 1000 мальчиков соответствующег возраста', text_thin_svod_center )
  worksheet_write_string( ws7, 284, 8, 'Выявлено впервые (абсолютное число)', text_thin_svod_center )

  row_SVOD_MKB10( wb, ws7, 285, 281, 13, 'E40 - E46 Недостаточность питания', hTemp[ 'E40_E46' ], total )
  row_SVOD_MKB10( wb, ws7, 286, 282, 13, 'E66 Ожирение', hTemp[ 'E66' ], total )
  row_SVOD_MKB10( wb, ws7, 287, 283, 13, 'E10 Сахарный диабет I типа', hTemp[ 'E10' ], total )
  row_SVOD_MKB10( wb, ws7, 288, 284, 13, 'Z72.1 Употребление алкоголя', hTemp[ 'Z72.1' ], total )
  row_SVOD_MKB10( wb, ws7, 289, 285, 13, 'Z72.2 Использование наркотиков', hTemp[ 'Z72.2' ], total )
  row_SVOD_MKB10( wb, ws7, 290, 286, 13, 'Z72.0 Курение табака (ежедневное выкуривание одной сигареты и более)', hTemp[ 'Z72.0' ], total )
  row_SVOD_MKB10( wb, ws7, 291, 287, 13, 'Y83.2-4 Хирургические операции и другие хирургические процедуры как причина аномальной реакции или позднего осложнения у пациента без упоминания о случайном нанесении ему вреда во', hTemp[ 'Y83.2_4' ], total )
  row_SVOD_MKB10( wb, ws7, 292, 288, 13, 'Z91.2 В личном анамнезе о неудовлетворительное соблюдение личной гигиены', hTemp[ 'Z91.2' ], total )
  row_SVOD_MKB10( wb, ws7, 293, 289, 13, 'Z91.3 В личном анамнезе нарушение режима сна/бодрствования (исключены нарушения сна - G47. -)', hTemp[ 'Z91.3' ], total )

  empty_rows( ws7, 294, 2, 3.0 )

  return nil

// 17.11.26
function number_percent_100( value, total )

  return iif( value == 0, 0, ( value / total ) * 100 )

// 16.11.26
function number_percent_1000( value, total )

  return iif( value == 0, 0, ( value / total ) * 1000 )

// 14.11.26
function empty_rows( ws, value, count, height )

  local i

  for i := 1 to count
    worksheet_set_row( ws, value + ( i - 1 ), height )
  next

  return nil

// 19.11.26
function row_single_number( wb, ws, row, num_str, heigh, text, value, lColor )

  static text_thin_svod
  local block_value

  if HB_ISNIL( text_thin_svod )
    text_thin_svod := fmt_excel_hl_vc_wrap( wb )
    format_set_font_name( text_thin_svod, 'Arial' )
    format_set_font_size( text_thin_svod, 10 )
//    format_set_bg_color( titul_table_thin, 0xffff00 )
    format_set_border( text_thin_svod, LXW_BORDER_THIN )
  endif

  block_value := fmt_excel_hc_vc_wrap( wb )
  format_set_font_name( block_value, 'Arial' )
  format_set_font_size( block_value, 10 )
  if lColor
    format_set_bg_color( block_value, 0xffffc3 )
  else
    format_set_bg_color( block_value, 0xcdcdcd )
  endif
  format_set_border( block_value, LXW_BORDER_THIN )
//  format_set_num_format( block_value, '#,###0.000' )

  worksheet_set_row( ws, row, heigh )

  worksheet_write_number( ws, row, 0, num_str, text_thin_svod )
  worksheet_merge_range( ws, row, 1, row, 7, text, text_thin_svod )
  if ValType( value ) == 'N'
    worksheet_write_number( ws, row, 8, value, block_value )
  else
    worksheet_write_formula( ws, row, 8, value, block_value )
  endif

  return nil

// 14.11.26
function row_two_numbers( wb, ws, row, num_str, heigh, text, value, next_value )

  static text_thin_svod
  static block_value, block_next_value

  if HB_ISNIL( text_thin_svod )
    text_thin_svod := fmt_excel_hl_vc_wrap( wb )
    format_set_font_name( text_thin_svod, 'Arial' )
    format_set_font_size( text_thin_svod, 10 )
//    format_set_bg_color( titul_table_thin, 0xffff00 )
    format_set_border( text_thin_svod, LXW_BORDER_THIN )
  endif

  if HB_ISNIL( block_value )
    block_value := fmt_excel_hc_vc_wrap( wb )
    format_set_font_name( block_value, 'Arial' )
    format_set_font_size( block_value, 10 )
    format_set_bg_color( block_value, 0xffffc3 )
    format_set_border( block_value, LXW_BORDER_THIN )
//    format_set_num_format( block_value, '#,###0.000' )
  endif

  if HB_ISNIL( block_next_value )
    block_next_value := fmt_excel_hc_vc_wrap( wb )
    format_set_font_name( block_next_value, 'Arial' )
    format_set_font_size( block_next_value, 10 )
    format_set_bg_color( block_next_value, 0xcdcdcd )
    format_set_num_format( block_next_value, '#,#0.0' )
    format_set_border( block_next_value, LXW_BORDER_THIN )
  endif

  worksheet_set_row( ws, row, heigh )

  worksheet_write_number( ws, row, 0, num_str, text_thin_svod )
  worksheet_merge_range( ws, row, 1, row, 6, text, text_thin_svod )
  worksheet_write_number( ws, row, 7, value, block_value )
  if ValType( next_value ) == 'N'
    worksheet_write_number( ws, row, 8, next_value, block_next_value )
  else
    worksheet_write_formula( ws, row, 8, next_value, block_next_value )
  endif

  return nil

// 13.11.26
function row_three_numbers( wb, ws, row, num_str, heigh, text, vsego, percent, first )

  static text_thin_svod, block_empty, block_gray

  if HB_ISNIL( text_thin_svod )
    text_thin_svod := fmt_excel_hl_vc_wrap( wb )
    format_set_font_name( text_thin_svod, 'Arial' )
    format_set_font_size( text_thin_svod, 10 )
//    format_set_bg_color( titul_table_thin, 0xffff00 )
    format_set_border( text_thin_svod, LXW_BORDER_THIN )
  endif

  if HB_ISNIL( block_empty )
    block_empty := fmt_excel_hc_vc_wrap( wb )
    format_set_font_name( block_empty, 'Arial' )
    format_set_font_size( block_empty, 10 )
    format_set_bg_color( block_empty, 0xffffc3 )
    format_set_border( block_empty, LXW_BORDER_THIN )
  endif

  if HB_ISNIL( block_gray )
    block_gray := fmt_excel_hc_vc_wrap( wb )
    format_set_font_name( block_gray, 'Arial' )
    format_set_font_size( block_gray, 10 )
    format_set_bg_color( block_gray, 0xcdcdcd )
    format_set_border( block_gray, LXW_BORDER_THIN )
    format_set_num_format( block_gray, '#,###0.000' )
  endif

  worksheet_set_row( ws, row, heigh )
  worksheet_write_number( ws, row, 0, num_str, text_thin_svod )
  worksheet_merge_range( ws, row, 1, row, 5, text, text_thin_svod )

  worksheet_write_number( ws, row, 6, vsego, block_empty )
  worksheet_write_number( ws, row, 7, percent, block_gray )
  worksheet_write_number( ws, row, 8, first, block_empty )

  return nil

// 13.11.26
function row_SVOD_MKB10( wb, ws, row, num_str, heigh, text, arr, total )

  static text_thin_svod, block_empty, block_gray

  if HB_ISNIL( text_thin_svod )
    text_thin_svod := fmt_excel_hl_vc_wrap( wb )
    format_set_font_name( text_thin_svod, 'Arial' )
    format_set_font_size( text_thin_svod, 10 )
//    format_set_bg_color( titul_table_thin, 0xffff00 )
    format_set_border( text_thin_svod, LXW_BORDER_THIN )
  endif

  if HB_ISNIL( block_empty )
    block_empty := fmt_excel_hc_vc_wrap( wb )
    format_set_font_name( block_empty, 'Arial' )
    format_set_font_size( block_empty, 10 )
    format_set_bg_color( block_empty, 0xffffc3 )
    format_set_border( block_empty, LXW_BORDER_THIN )
  endif

  if HB_ISNIL( block_gray )
    block_gray := fmt_excel_hc_vc_wrap( wb )
    format_set_font_name( block_gray, 'Arial' )
    format_set_font_size( block_gray, 10 )
    format_set_bg_color( block_gray, 0xcdcdcd )
    format_set_border( block_gray, LXW_BORDER_THIN )
    format_set_num_format( block_gray, '#,###0.000' )
  endif

  worksheet_set_row( ws, row, heigh )
  worksheet_write_number( ws, row, 0, num_str, text_thin_svod )
  worksheet_merge_range( ws, row, 1, row, 5, text, text_thin_svod )

  worksheet_write_number( ws, row, 6, arr[ 1 ], block_empty )

  worksheet_write_number( ws, row, 7, iif( arr[ 1 ] == 0, 0, ( arr[ 1 ] / total ) * 1000 ), block_gray )
  worksheet_write_number( ws, row, 8, arr[ 2 ], block_empty )

  return nil

// 18.11.26
function row_seven_numbers( wb, ws, row, num_str, heigh, text, val1, val2, val3, val4, val5, val6, val7, lColor )

  local text_thin_svod, block_value, block_value_gray

  block_value := fmt_excel_hc_vc_wrap( wb )
  format_set_font_name( block_value, 'Arial' )
  format_set_font_size( block_value, 10 )
  if lColor
    format_set_bg_color( block_value, 0xffffc3 )
  else
    format_set_bg_color( block_value, 0xcdcdcd )
  endif
  format_set_border( block_value, LXW_BORDER_THIN )
//  format_set_num_format( block_value, '#,###0.000' )

  block_value_gray := fmt_excel_hc_vc_wrap( wb )
  format_set_font_name( block_value_gray, 'Arial' )
  format_set_font_size( block_value_gray, 10 )
  format_set_bg_color( block_value_gray, 0xcdcdcd )
  format_set_border( block_value_gray, LXW_BORDER_THIN )
//  format_set_num_format( block_value_gray, '#,###0.000' )

  text_thin_svod := fmt_excel_hl_vc_wrap( wb )
  format_set_font_name( text_thin_svod, 'Arial' )
  format_set_font_size( text_thin_svod, 10 )
//  format_set_bg_color( titul_table_thin, 0xffff00 )
  format_set_border( text_thin_svod, LXW_BORDER_THIN )

  worksheet_set_row( ws, row, heigh )
  worksheet_write_number( ws, row, 0, num_str, text_thin_svod )
//  worksheet_merge_range( ws, row, 1, row, 5, text, text_thin_svod )
  worksheet_write_string( ws, row, 1, text, text_thin_svod)

  if ValType( val1 ) == 'N'
    worksheet_write_number( ws, row, 2, val1, block_value )
  else
    worksheet_write_formula( ws, row, 2, val1, block_value )
  endif
  if ValType( val2 ) == 'N'
    worksheet_write_number( ws, row, 3, val2, block_value )
  else
    worksheet_write_formula( ws, row, 3, val2, block_value )
  endif
  if ValType( val3 ) == 'N'
    worksheet_write_number( ws, row, 4, val3, block_value )
  else
    worksheet_write_formula( ws, row, 4, val3, block_value )
  endif
  if ValType( val4 ) == 'N'
    worksheet_write_number( ws, row, 5, val4, block_value_gray )
  else
    worksheet_write_formula( ws, row, 5, val4, block_value_gray )
  endif
  if ValType( val5 ) == 'N'
    worksheet_write_number( ws, row, 6, val5, block_value )
  else
    worksheet_write_formula( ws, row, 6, val5, block_value )
  endif
  if ValType( val6 ) == 'N'
    worksheet_write_number( ws, row, 7, val6, block_value )
  else
    worksheet_write_formula( ws, row, 7, val6, block_value )
  endif
  if ValType( val7 ) == 'N'
    worksheet_write_number( ws, row, 8, val7, block_value )
  else
    worksheet_write_formula( ws, row, 8, val7, block_value )
  endif

  return nil
