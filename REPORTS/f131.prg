#include 'hblibxlsxwriter.ch'

static strOKEI := 'Код по ОКЕИ: человек - 792'
static strOKEIed := 'Код по ОКЕИ: единица - 642'

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
  shTitul := createF131Titul( workbook )
  sh1000 := createF131SH1000( workbook )
  sh2000 := createF131SH2000( workbook )
  sh3000 := createF131SH3000( workbook )
  sh3001 := createF131SH3001( workbook )
  sh4000 := createF131SH4000( workbook )
  sh5000DVN := createF131SH5000DVN( workbook )
  sh5000PO := createF131SH5000PO( workbook )
  sh6000 := createF131SH6000( workbook )
  sh5000 := createF131SH5000( workbook )


  /* Закрыть книгу, записать файл и освободить память. */
  error = lxw_workbook_close(workbook)

  /* Проверить наличие ошибки при создании xlsx файла. */
  if !EMPTY(error)
    sprintf("Error in workbook_close().\n"+;
           "Error %d = %s\n", error, HB_NTOS(error))
  endif

  return

function format_HorCenter_VertCenter(workbook)
  local fmt := lxw_workbook_add_format(workbook)
  
  lxw_format_set_align(fmt, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmt, LXW_ALIGN_VERTICAL_CENTER)

return fmt

function format_HorLeft_VertCenter(workbook)
  local fmt := lxw_workbook_add_format(workbook)
  
  lxw_format_set_align(fmt, LXW_ALIGN_LEFT)
  lxw_format_set_align(fmt, LXW_ALIGN_VERTICAL_CENTER)

return fmt

function format_HorRight_VertCenter(workbook)
  local fmt := lxw_workbook_add_format(workbook)
  
  lxw_format_set_align(fmt, LXW_ALIGN_RIGHT)
  lxw_format_set_align(fmt, LXW_ALIGN_VERTICAL_CENTER)

return fmt

function createF131SH5000DVN( workbook )
  local sh5000DVN, col, row , i
  local fmt, fmt1, fmt2, fmt3, fmt4, fmt5, fmt6
          
  sh5000DVN := lxw_workbook_add_worksheet(workbook, '5000 и 5001 ДВН' )
  lxw_worksheet_set_tab_color(sh5000DVN, LXW_COLOR_PINK)

  fmt := format_HorCenter_VertCenter(workbook)
  lxw_format_set_text_wrap(fmt)
  lxw_format_set_font_name(fmt, 'Times New Roman')
  lxw_format_set_bold(fmt)
  lxw_format_set_font_size(fmt, 14)

  fmt1 := format_HorCenter_VertCenter(workbook)
  lxw_format_set_text_wrap(fmt1)
  lxw_format_set_font_name(fmt1, 'Times New Roman')
  lxw_format_set_font_size(fmt1, 12)
  lxw_format_set_border(fmt1, LXW_BORDER_THIN)

  fmt2 := format_HorLeft_VertCenter(workbook)
  lxw_format_set_text_wrap(fmt2)
  lxw_format_set_font_name(fmt2, 'Times New Roman')
  lxw_format_set_font_size(fmt2, 12)
  lxw_format_set_bold(fmt2)
  lxw_format_set_border(fmt2, LXW_BORDER_THIN)

  fmt3 := format_HorRight_VertCenter(workbook)
  lxw_format_set_font_name(fmt3, 'Times New Roman')
  lxw_format_set_bold(fmt3)
  lxw_format_set_font_size(fmt3, 12)

  fmt4 := format_HorRight_VertCenter(workbook)
  lxw_format_set_bg_color(fmt4, 0xFFFFCC)
  lxw_format_set_font_name(fmt4, 'Calibri')
  lxw_format_set_font_size(fmt4, 11)
  lxw_format_set_border(fmt4, LXW_BORDER_THIN)

  fmt5 := format_HorCenter_VertCenter(workbook)
  lxw_format_set_bg_color(fmt5, LXW_COLOR_GRAY)
  lxw_format_set_font_name(fmt5, 'Calibri')
  lxw_format_set_font_size(fmt5, 11)
  lxw_format_set_border(fmt5, LXW_BORDER_THIN)

  fmt6 := format_HorLeft_VertCenter(workbook)
  lxw_format_set_text_wrap(fmt6)
  lxw_format_set_font_name(fmt6, 'Times New Roman')
  lxw_format_set_font_size(fmt6, 12)

  url_format   = format_HorCenter_VertCenter(workbook)
  lxw_format_set_font_size(url_format, 12)
  lxw_format_set_underline (url_format, LXW_UNDERLINE_SINGLE)
  lxw_format_set_font_color(url_format, LXW_COLOR_BLUE)
  lxw_format_set_text_wrap(url_format)
  lxw_format_set_border(url_format, LXW_BORDER_THIN)

  lxw_worksheet_set_column(sh5000DVN, 0, 0, 8.0)
  lxw_worksheet_set_column(sh5000DVN, 1, 1, 40.0)
  lxw_worksheet_set_column(sh5000DVN, 2, 2, 8)
  lxw_worksheet_set_column(sh5000DVN, 3, 3, 9.0)
  lxw_worksheet_set_column(sh5000DVN, 4, 12, 8.0)

  lxw_worksheet_merge_range(sh5000DVN, 0, 1, 0, 13, 'Заболевания, выявленные при проведении профилактического медицинского осмотра (диспансеризации), установление диспансерного наблюдения', fmt)
  lxw_worksheet_write_string(sh5000DVN, 1, 1, '(5000)', fmt3)
  lxw_worksheet_write_string(sh5000DVN, 1, 10, strOKEI, nil)

  lxw_worksheet_merge_range(sh5000DVN, 2, 1, 4, 1, 'Наименование классов и отдельных заболеваний', fmt1)
  lxw_worksheet_merge_range(sh5000DVN, 2, 2, 4, 2, 'N строки', fmt1)
  lxw_worksheet_write_url(sh5000DVN, 2, 3, 'http://ivo.garant.ru/#/document/4100000/paragraph/41209:0', url_format)
  lxw_worksheet_merge_range(sh5000DVN, 2, 3, 4, 3, 'Код МКБ-10', url_format)
  lxw_worksheet_merge_range(sh5000DVN, 2, 4, 2, 7, 'Выявлено заболеваний', fmt1)
  lxw_worksheet_merge_range(sh5000DVN, 2, 8, 2, 13, 'из них: впервые в жизни с установленным диагнозом', fmt1)
  lxw_worksheet_merge_range(sh5000DVN, 3, 4, 3, 5, 'всего', fmt1)
  lxw_worksheet_merge_range(sh5000DVN, 3, 6, 3, 7, 'в том числе', fmt1)
  lxw_worksheet_merge_range(sh5000DVN, 3, 8, 3, 9, 'всего', fmt1)
  lxw_worksheet_merge_range(sh5000DVN, 3, 10, 3, 11, 'в трудоспособном возрасте', fmt1)
  lxw_worksheet_merge_range(sh5000DVN, 3, 12, 3, 13, 'в возрасте старше трудоспособного', fmt1)
  lxw_worksheet_write_string(sh5000DVN, 4, 4, 'всего', fmt1)
  lxw_worksheet_write_string(sh5000DVN, 4, 5, 'из них: установлено диспансерное наблюдение', fmt1)
  lxw_worksheet_write_string(sh5000DVN, 4, 6, 'в трудоспособном возрасте', fmt1)
  lxw_worksheet_write_string(sh5000DVN, 4, 7, 'в возрасте старше трудоспособного', fmt1)
  lxw_worksheet_write_string(sh5000DVN, 4, 8, 'всего', fmt1)
  lxw_worksheet_write_string(sh5000DVN, 4, 9, 'из них: установлено диспансерное наблюдение', fmt1)
  lxw_worksheet_write_string(sh5000DVN, 4, 10, 'всего', fmt1)
  lxw_worksheet_write_string(sh5000DVN, 4, 11, 'из них: установлено диспансерное наблюдение', fmt1)
  lxw_worksheet_write_string(sh5000DVN, 4, 12, 'всего', fmt1)
  lxw_worksheet_write_string(sh5000DVN, 4, 13, 'из них: установлено диспансерное наблюдение', fmt1)
  for col := 1 to 13
    lxw_worksheet_write_string(sh5000DVN, 5, col, alltrim(str(col)), fmt1)
  next
  // временно
  for row := 6 to 76
    for col := 5 to 7
      lxw_worksheet_write_string(sh5000DVN, row, col, '', fmt4)
    next
    for col := 10 to 13
      lxw_worksheet_write_string(sh5000DVN, row, col, '', fmt4)
    next
  next

  for row := 6 to 76
    arg := 'G' + alltrim(str(row+1)) + '+H' + alltrim(str(row+1))
    lxw_worksheet_write_formula(sh5000DVN, row, 4, arg, fmt5)
    arg := 'K' + alltrim(str(row+1)) + '+M' + alltrim(str(row+1))
    lxw_worksheet_write_formula(sh5000DVN, row, 8, arg, fmt5)
    arg := 'L' + alltrim(str(row+1)) + '+N' + alltrim(str(row+1))
    lxw_worksheet_write_formula(sh5000DVN, row, 9, arg, fmt5)
  next
  // Итговые данные
  lxw_worksheet_write_string(sh5000DVN, 68, 1, 'Прочие заболевания', fmt2)
  lxw_worksheet_write_string(sh5000DVN, 68, 2, '11', fmt1)
  lxw_worksheet_write_formula(sh5000DVN, 68, 4, 'E70+E74+E76+E77', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 68, 5, 'F70+F74+F76+F77', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 68, 6, 'G70+G74+G76+G77', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 68, 7, 'H70+H74+H76+H77', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 68, 8, 'K69+M69', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 68, 9, 'L69+N69', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 68, 10, 'K70+K74+K76+K77', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 68, 11, 'L70+L74+L76+L77', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 68, 12, 'M70+M74+M76+M77', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 68, 13, 'N70+N74+N76+N77', fmt5)

  lxw_worksheet_write_string(sh5000DVN, 77, 1, 'ИТОГО заболеваний', fmt2)
  lxw_worksheet_write_string(sh5000DVN, 77, 2, '12', fmt1)
  lxw_worksheet_write_string(sh5000DVN, 77, 3, 'A00-T98', fmt1)
  lxw_worksheet_write_formula(sh5000DVN, 77, 4, 'E7+E9+E35+E37+E42+E44+E48+E60+E64+E70+E69', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 77, 5, 'F7+F9+F35+F37+F42+F44+F48+F60+F64+F70+F69', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 77, 6, 'G7+G9+G35+G37+G42+G44+G48+G60+G64+G70+G69', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 77, 7, 'H7+H9+H35+H37+H42+H44+H48+H60+H64+H70+H69', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 77, 8, 'I7+I9+I35+I37+I42+I44+I48+I60+I64+I70+I69', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 77, 9, 'J7+J9+J35+J37+J42+J44+J48+J60+J64+J70+J69', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 77, 10, 'K7+K9+K35+K37+K42+K44+K48+K60+K64+K70+K69', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 77, 11, 'L7+L9+L35+L37+L42+L44+L48+L60+L64+L70+L69', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 77, 12, 'M7+M9+M35+M37+M42+M44+M48+M60+M64+M70+M69', fmt5)
  lxw_worksheet_write_formula(sh5000DVN, 77, 13, 'N7+N9+N35+N37+N42+N44+N48+N60+N64+N70+N69', fmt5)

  lxw_worksheet_write_string(sh5000DVN, 79, 1, '(5001)', fmt3)
  lxw_worksheet_write_string(sh5000DVN, 79, 10, strOKEI, nil)
  lxw_worksheet_merge_range(sh5000DVN, 80, 1, 80, 11, 'Число лиц с артериальным давлением ниже 140/90 мм рт. ст. на фоне приема гипотензивных лекарственных препаратов, при наличии болезней, характеризующихся повышенным кровяным давлением (I10-I15 по МКБ-10)', fmt6)

  // временно
  lxw_worksheet_write_string(sh5000DVN, 80, 12, '', fmt4)
  
  return sh5000DVN
  
function createF131SH4000( workbook )
  local sh4000, col, row , i
  local fmt, fmt1, fmt2, fmt3, fmt4, fmt5
  
  sh4000 := lxw_workbook_add_worksheet(workbook, '4000, 4001' )
  lxw_worksheet_set_tab_color(sh4000, LXW_COLOR_BLUE)

  fmt := format_HorCenter_VertCenter(workbook)
  lxw_format_set_text_wrap(fmt)
  lxw_format_set_font_name(fmt, 'Times New Roman')
  lxw_format_set_bold(fmt)
  lxw_format_set_font_size(fmt, 12)

  fmt1 := format_HorCenter_VertCenter(workbook)
  lxw_format_set_text_wrap(fmt1)
  lxw_format_set_font_name(fmt1, 'Times New Roman')
  lxw_format_set_font_size(fmt1, 12)
  lxw_format_set_border(fmt1, LXW_BORDER_THIN)

  fmt2 := format_HorLeft_VertCenter(workbook)
  lxw_format_set_text_wrap(fmt2)
  lxw_format_set_font_name(fmt2, 'Times New Roman')
  lxw_format_set_font_size(fmt2, 12)
  lxw_format_set_border(fmt2, LXW_BORDER_THIN)

  fmt3 := format_HorRight_VertCenter(workbook)
  lxw_format_set_font_name(fmt3, 'Times New Roman')
  lxw_format_set_bold(fmt3)
  lxw_format_set_font_size(fmt3, 14)

  fmt4 := format_HorRight_VertCenter(workbook)
  lxw_format_set_bg_color(fmt4, 0xFFFFCC)
  lxw_format_set_font_name(fmt4, 'Times New Roman')
  lxw_format_set_font_size(fmt4, 12)
  lxw_format_set_border(fmt4, LXW_BORDER_THIN)

  fmt5 := format_HorCenter_VertCenter(workbook)
  lxw_format_set_bg_color(fmt5, LXW_COLOR_GRAY)
  lxw_format_set_font_name(fmt5, 'Times New Roman')
  lxw_format_set_font_size(fmt5, 12)
  lxw_format_set_border(fmt5, LXW_BORDER_THIN)

  lxw_worksheet_set_column(sh4000, 0, 0, 8.0)
  lxw_worksheet_set_column(sh4000, 1, 1, 60.0)
  lxw_worksheet_set_column(sh4000, 2, 2, 8)
  lxw_worksheet_set_column(sh4000, 3, 3, 8.0)
  lxw_worksheet_set_column(sh4000, 4, 12, 12.0)

  lxw_worksheet_merge_range(sh4000, 3, 0, 23, 0, '', fmt1)
  lxw_worksheet_merge_range(sh4000, 1, 1, 1, 12, 'Сведения о выявленных при проведении профилактического медицинского осмотра (диспансеризации) факторах риска и других патологических состояниях и заболеваниях, повышающих вероятность развития хронических неинфекционных заболеваний (далее - факторы риска)', fmt)
  lxw_worksheet_write_string(sh4000, 2, 1, '(4000)', fmt3)
  lxw_worksheet_write_string(sh4000, 2, 9, strOKEI, nil)

  lxw_worksheet_merge_range(sh4000, 3, 1, 4, 1, 'Наименование факторов риска и других патологических состояний и заболеваний', fmt1)
  lxw_worksheet_merge_range(sh4000, 3, 2, 4, 2, 'Код МКБ-10', fmt1)
  lxw_worksheet_merge_range(sh4000, 3, 3, 4, 3, 'N строки', fmt1)
  lxw_worksheet_merge_range(sh4000, 3, 4, 3, 6, 'Все взрослое население  в том числе:', fmt1)
  lxw_worksheet_merge_range(sh4000, 3, 7, 3, 9, 'Мужчины в том числе:', fmt1)
  lxw_worksheet_merge_range(sh4000, 3, 10, 3, 12, 'Женщины в том числе:', fmt1)
  lxw_worksheet_write_string(sh4000, 4, 4, 'Всего', fmt1)
  lxw_worksheet_write_string(sh4000, 4, 5, 'в трудоспособном возрасте', fmt1)
  lxw_worksheet_write_string(sh4000, 4, 6, 'в возрасте старше трудоспособного', fmt1)
  lxw_worksheet_write_string(sh4000, 4, 7, 'Всего', fmt1)
  lxw_worksheet_write_string(sh4000, 4, 8, 'в трудоспособном возрасте', fmt1)
  lxw_worksheet_write_string(sh4000, 4, 9, 'в возрасте старше трудоспособного', fmt1)
  lxw_worksheet_write_string(sh4000, 4, 10, 'Всего', fmt1)
  lxw_worksheet_write_string(sh4000, 4, 11, 'в трудоспособном возрасте', fmt1)
  lxw_worksheet_write_string(sh4000, 4, 12, 'в возрасте старше трудоспособного', fmt1)

  for col := 1 to 12
    lxw_worksheet_write_string(sh4000, 5, col, alltrim(str(col)), fmt1)
  next

  lxw_worksheet_write_string(sh4000, 6, 1, 'Гиперхолестеринемия', fmt2)
  lxw_worksheet_write_string(sh4000, 7, 1, 'Гипергликемия', fmt2)
  lxw_worksheet_write_string(sh4000, 8, 1, 'Курение табака', fmt2)
  lxw_worksheet_write_string(sh4000, 9, 1, 'Нерациональное питание', fmt2)
  lxw_worksheet_write_string(sh4000, 10, 1, 'Избыточная масса тела', fmt2)
  lxw_worksheet_write_string(sh4000, 11, 1, 'Ожирение', fmt2)
  lxw_worksheet_write_string(sh4000, 12, 1, 'Низкая физическая активность', fmt2)
  lxw_worksheet_write_string(sh4000, 13, 1, 'Риск пагубного потребления алкоголя', fmt2)
  lxw_worksheet_write_string(sh4000, 14, 1, 'Риск потребления наркотических средств и психотропных веществ без назначения врача', fmt2)
  lxw_worksheet_write_string(sh4000, 15, 1, 'Отягощенная наследственность по инфаркту  миокарда', fmt2)
  lxw_worksheet_write_string(sh4000, 16, 1, 'Отягощенная наследственность по мозговому  инсульту', fmt2)
  lxw_worksheet_write_string(sh4000, 17, 1, 'Отягощенная наследственность по ЗНО колоректальной области', fmt2)
  lxw_worksheet_write_string(sh4000, 18, 1, 'Отягощенная наследственность по ЗНО по другим локализациям', fmt2)
  lxw_worksheet_write_string(sh4000, 19, 1, 'Отягощенная наследственность по хроническим болезням нижних дыхательных путей', fmt2)
  lxw_worksheet_write_string(sh4000, 20, 1, 'Отягощенная наследственность по сахарному диабету', fmt2)
  lxw_worksheet_write_string(sh4000, 21, 1, 'Высокий (5% и более) или очень высокий (10% и более) абсолютный сердечно-сосудистый риск', fmt2)
  lxw_worksheet_write_string(sh4000, 22, 1, 'Высокий (более 1 ед.) относительный сердечно-сосудистый риск', fmt2)
  lxw_worksheet_write_string(sh4000, 23, 1, 'Старческая астения', fmt2)

  lxw_worksheet_write_string(sh4000, 6, 2, 'Е78', fmt1)
  lxw_worksheet_write_string(sh4000, 7, 2, 'R73.9', fmt1)
  lxw_worksheet_write_string(sh4000, 8, 2, 'Z72.0', fmt1)
  lxw_worksheet_write_string(sh4000, 9, 2, 'Z72.4', fmt1)
  lxw_worksheet_write_string(sh4000, 10, 2, 'R63.5', fmt1)
  lxw_worksheet_write_string(sh4000, 11, 2, 'Е66', fmt1)
  lxw_worksheet_write_string(sh4000, 12, 2, 'Z72.3', fmt1)
  lxw_worksheet_write_string(sh4000, 13, 2, 'Z72.1', fmt1)
  lxw_worksheet_write_string(sh4000, 14, 2, 'Z72.2', fmt1)
  lxw_worksheet_write_string(sh4000, 15, 2, 'Z82.4', fmt1)
  lxw_worksheet_write_string(sh4000, 16, 2, 'Z82.3', fmt1)
  lxw_worksheet_write_string(sh4000, 17, 2, 'Z80.0', fmt1)
  lxw_worksheet_write_string(sh4000, 18, 2, 'Z80.9', fmt1)
  lxw_worksheet_write_string(sh4000, 19, 2, 'Z82.5', fmt1)
  lxw_worksheet_write_string(sh4000, 20, 2, 'Z83.3', fmt1)
  lxw_worksheet_write_string(sh4000, 21, 2, '-', fmt1)
  lxw_worksheet_write_string(sh4000, 22, 2, '-', fmt1)
  lxw_worksheet_write_string(sh4000, 23, 2, 'R54', fmt1)

  for row := 6 to 23
    lxw_worksheet_write_string(sh4000, row, 3, alltrim(str(row)), fmt1)
  next
  
  lxw_worksheet_set_row(sh4000, 1, 40)
  lxw_worksheet_set_row(sh4000, 3, 40)
  lxw_worksheet_set_row(sh4000, 4, 60)
  for i := 6 to 23
    if i == 14 .or. i == 17 .or. i == 18 .or. i == 19 .or. i == 21 .or. i == 22
      lxw_worksheet_set_row(sh4000, i, 40)
    else
      lxw_worksheet_set_row(sh4000, i, 20)
    end
  next

  // временно
  for row := 6 to 23
    for col := 7 to 12
      lxw_worksheet_write_string(sh4000, row, col, '', fmt4)
    next
  next
  for i := 1 to 18
    arg := 'SUM(H' + alltrim(str(i+6)) + '+K' + alltrim(str(i+6)) + ')'
    lxw_worksheet_write_formula(sh4000, i+5, 4, arg, fmt5)
    arg := 'SUM(I' + alltrim(str(i+6)) + '+L' + alltrim(str(i+6)) + ')'
    lxw_worksheet_write_formula(sh4000, i+5, 5, arg, fmt5)
    arg := 'SUM(J' + alltrim(str(i+6)) + '+M' + alltrim(str(i+6)) + ')'
    lxw_worksheet_write_formula(sh4000, i+5, 6, arg, fmt5)
  next

  lxw_worksheet_write_string(sh4000, 25, 1, '(4001)', fmt3)
  lxw_worksheet_write_string(sh4000, 26, 1, 'Число лиц, у которых по строкам 03, 04, 07, 08, 09 отсутствуют факторы риска ', nil)
  lxw_worksheet_write_string(sh4000, 26, 8, '', fmt4)
  
  return sh4000
  
function createF131SH3000( workbook )
  local sh3000, row, col, i
  local fmt, fmt1, fmt2, fmt3, fmt4
        
  sh3000 := lxw_workbook_add_worksheet(workbook, '2001, 3000' )
  lxw_worksheet_set_tab_color(sh3000, 0xfcdeb6)

  lxw_worksheet_set_column(sh3000, 0, 0, 10.0)
  lxw_worksheet_set_column(sh3000, 1, 1, 60.0)
  lxw_worksheet_set_column(sh3000, 2, 2, 8)
  lxw_worksheet_set_column(sh3000, 3, 8, 20.0)

  fmt := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmt, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_text_wrap(fmt)
  lxw_format_set_font_name(fmt, 'Times New Roman')
  lxw_format_set_font_size(fmt, 12)
  lxw_format_set_border(fmt, LXW_BORDER_THIN)

  fmt1 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt1, LXW_ALIGN_RIGHT)
  lxw_format_set_align(fmt1, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_bg_color(fmt1, 0xFFFFCC)
  lxw_format_set_font_name(fmt1, 'Times New Roman')
  lxw_format_set_font_size(fmt1, 12)
  lxw_format_set_border(fmt1, LXW_BORDER_THIN)

  fmt2 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt2, LXW_ALIGN_LEFT)
  lxw_format_set_align(fmt2, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_text_wrap(fmt2)
  lxw_format_set_font_name(fmt2, 'Times New Roman')
  lxw_format_set_font_size(fmt2, 12)
  lxw_format_set_border(fmt2, LXW_BORDER_THIN)

  fmt3 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt3, LXW_ALIGN_RIGHT)
  lxw_format_set_align(fmt3, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_name(fmt3, 'Times New Roman')
  lxw_format_set_bold(fmt3)
  lxw_format_set_font_size(fmt3, 14)

  fmt4 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt4, LXW_ALIGN_LEFT)
  lxw_format_set_align(fmt4, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_name(fmt4, 'Times New Roman')
  lxw_format_set_bold(fmt4)
  lxw_format_set_font_size(fmt4, 14)

  fmt5 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt5, LXW_ALIGN_LEFT)
  lxw_format_set_align(fmt5, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_name(fmt5, 'Times New Roman')
  lxw_format_set_font_size(fmt5, 11)

  lxw_worksheet_write_string(sh3000, 1, 1, '(2001)', fmt3)
  lxw_worksheet_merge_range(sh3000, 2, 1, 2, 3, 'Число лиц, которые по результатам первого этапа диспансеризации направлены на второй этап', fmt5)
  lxw_worksheet_write_string(sh3000, 2, 4, '', fmt1)

  lxw_worksheet_write_string(sh3000, 4, 1, 'Сведения о приёмах (осмотрах), медицинских исследованиях и иных медицинских вмешательствах второго этапа диспансеризации', fmt4)

  lxw_worksheet_write_string(sh3000, 6, 1, '(3000)', fmt3)
  lxw_worksheet_write_string(sh3000, 6, 5, strOKEIed, nil)
  lxw_worksheet_merge_range(sh3000, 7, 1, 8, 1, 'Медицинское вмешательство, входящее в объем второго этапа диспансеризации', fmt)
  lxw_worksheet_merge_range(sh3000, 7, 2, 8, 2, '№ строки', fmt)
  lxw_worksheet_merge_range(sh3000, 7, 3, 8, 3, 'Число лиц с выявленными медицинскими показаниями в рамках первого этапа диспансеризации', fmt)
  lxw_worksheet_merge_range(sh3000, 7, 4, 7, 5, 'Число выполненных медицинских мероприятий', fmt)
  lxw_worksheet_write_string(sh3000, 8, 4, 'в рамках диспансеризации', fmt)
  lxw_worksheet_write_string(sh3000, 8, 5, 'проведено ранее ( в предшествующие 12 мес.)', fmt)
  lxw_worksheet_merge_range(sh3000, 7, 6, 8, 6, 'Число отказов', fmt)
  lxw_worksheet_merge_range(sh3000, 7, 7, 8, 7, 'Впервые выявлено заболевание или патологическое состояние', fmt)
  for col := 1 to 7
    lxw_worksheet_write_string(sh3000, 9, col, alltrim(str(col)), fmt)
  next
  for row := 10 to 22
    lxw_worksheet_write_string(sh3000, row, 2, alltrim(str(row-9)), fmt)
  next
  lxw_worksheet_write_string(sh3000, 23, 2, '13.1', fmt)
  lxw_worksheet_write_string(sh3000, 24, 2, '13.2', fmt)
  lxw_worksheet_write_string(sh3000, 25, 2, '13.3', fmt)
  lxw_worksheet_write_string(sh3000, 26, 2, '13.4', fmt)
  lxw_worksheet_write_string(sh3000, 27, 2, '14', fmt)
  lxw_worksheet_write_string(sh3000, 28, 2, '15', fmt)

  for i := 1 to 6
    lxw_worksheet_set_row(sh3000, i, 20)
  next
  lxw_worksheet_set_row(sh3000, 7, 50)
  lxw_worksheet_set_row(sh3000, 8, 50)
  for i := 10 to 28
    if i >= 22 .or. i == 12 .or. i == 13
      lxw_worksheet_set_row(sh3000, i, 70)
    else
      lxw_worksheet_set_row(sh3000, i, 20)
    end
  next
  lxw_worksheet_set_row(sh3000, 26, 110) // исключение

  lxw_worksheet_write_string(sh3000, 10, 1, 'Осмотр (консультация) врачом-неврологом', fmt2)
  lxw_worksheet_write_string(sh3000, 11, 1, 'Дуплексное сканирование брахиоцефальных артерий', fmt2)
  lxw_worksheet_write_string(sh3000, 12, 1, 'Осмотр (консультация) врачом-хирургом или врачом-урологом', fmt2)
  lxw_worksheet_write_string(sh3000, 13, 1, 'Осмотр (консультация) врачом-хирургом или врачом-колопроктологом, включая проведение ректороманоскопии', fmt2)
  lxw_worksheet_write_string(sh3000, 14, 1, 'Колоноскопия', fmt2)
  lxw_worksheet_write_string(sh3000, 15, 1, 'Эзофагогастродуоденоскопия', fmt2)
  lxw_worksheet_write_string(sh3000, 16, 1, 'Рентгенография легких', fmt2)
  lxw_worksheet_write_string(sh3000, 17, 1, 'Компьютерная томография легких', fmt2)
  lxw_worksheet_write_string(sh3000, 18, 1, 'Спирометрия', fmt2)
  lxw_worksheet_write_string(sh3000, 19, 1, 'Осмотр (консультация) врачом акушером-гинекологом', fmt2)
  lxw_worksheet_write_string(sh3000, 20, 1, 'Осмотр (консультация) врачом-оториноларингологом', fmt2)
  lxw_worksheet_write_string(sh3000, 21, 1, 'Осмотр (консультация) врачом-офтальмологом', fmt2)
  lxw_worksheet_write_string(sh3000, 22, 1, 'Индивидуальное или групповое (школа для пациентов) углубленное профилактическое консультирование для граждан:', fmt2)
  lxw_worksheet_write_string(sh3000, 23, 1, 'с выявленными ишемической болезнью сердца, цереброваскулярными заболеваниями, хронической ишемией нижних конечностей атеросклеротического генеза или болезнями, характеризующимися повышенным кровяным давлением', fmt2)
  lxw_worksheet_write_string(sh3000, 24, 1, 'с выявленным по результатам анкетирования риском пагубного потребления алкоголя и (или) потребления наркотических средств и психотропных веществ без назначения врача', fmt2)
  lxw_worksheet_write_string(sh3000, 25, 1, 'в возрасте 65 лет и старше в целях коррекции выявленных факторов риска и (или) профилактики старческой астении', fmt2)
  lxw_worksheet_write_string(sh3000, 26, 1, 'при выявлении высокого относительного, высокого и очень высокого абсолютного сердечно-сосудистого риска, и (или) ожирения, и (или) гиперхолестеринемии с уровнем общего холестерина 8 ммоль/л и более, а также установленном по результатам анкетирования курении более 20 сигарет в день, риске пагубного потребления алкоголя и (или) риске немедицинского потребления наркотических средств и психотропных веществ', fmt2)
  lxw_worksheet_write_string(sh3000, 27, 1, 'Прием (осмотр) врачом-терапевтом по результатам второго этапа диспансеризации', fmt2)
  lxw_worksheet_write_string(sh3000, 28, 1, 'Направление на осмотр (консультацию) врачом-онкологом при подозрении на онкологические заболевания', fmt2)

  // временно
  for row := 10 to 28
    for col := 3 to 7
      lxw_worksheet_write_string(sh3000, row, col, '', fmt1)
    next
  next

  for row := 22 to 26
    lxw_worksheet_write_string(sh3000, row, 7, 'X', fmt)
  next
  
  return sh3000
    
function createF131SH2000( workbook )
  local sh2000, col, row
  local fmt, fmt1, fmt2, fmt3, fmt4, fmt5
      
  sh2000 := lxw_workbook_add_worksheet(workbook, '2000' )
  lxw_worksheet_set_tab_color(sh2000, 0xB0E88B)

  lxw_worksheet_set_column(sh2000, 0, 0, 20.0)
  lxw_worksheet_set_column(sh2000, 1, 1, 90.0)
  lxw_worksheet_set_column(sh2000, 2, 2, 10.2)
  lxw_worksheet_set_column(sh2000, 3, 6, 13.0)

  lxw_worksheet_set_row(sh2000, 0, 16)
  lxw_worksheet_set_row(sh2000, 1, 50)
  lxw_worksheet_set_row(sh2000, 3, 90)
  lxw_worksheet_set_row(sh2000, 6, 30)
  lxw_worksheet_set_row(sh2000, 15, 32)
  lxw_worksheet_set_row(sh2000, 16, 60)
  lxw_worksheet_set_row(sh2000, 23, 75)
  lxw_worksheet_set_row(sh2000, 24, 40)
  lxw_worksheet_set_row(sh2000, 25, 40)
  lxw_worksheet_set_row(sh2000, 26, 60)

  fmt := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmt, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_text_wrap(fmt)
  lxw_format_set_font_name(fmt, 'Times New Roman')
  lxw_format_set_font_size(fmt, 14)

  fmt1 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt1, LXW_ALIGN_LEFT)
  lxw_format_set_align(fmt1, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_text_wrap(fmt1)
  lxw_format_set_font_name(fmt1, 'Times New Roman')
  lxw_format_set_font_size(fmt1, 12)
  lxw_format_set_border(fmt1, LXW_BORDER_THIN)

  fmt2 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt2, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmt2, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_text_wrap(fmt2)
  lxw_format_set_font_name(fmt2, 'Times New Roman')
  lxw_format_set_font_size(fmt2, 12)
  lxw_format_set_border(fmt2, LXW_BORDER_THIN)

  fmt3 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt3, LXW_ALIGN_RIGHT)
  lxw_format_set_align(fmt3, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_bg_color(fmt3, 0xFFFFCC)
  lxw_format_set_font_name(fmt3, 'Times New Roman')
  lxw_format_set_font_size(fmt3, 12)
  lxw_format_set_border(fmt3, LXW_BORDER_THIN)

  fmt4 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt4, LXW_ALIGN_RIGHT)
  lxw_format_set_align(fmt4, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_name(fmt4, 'Times New Roman')
  lxw_format_set_font_size(fmt4, 13)

  fmt5 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt5, LXW_ALIGN_LEFT)
  lxw_format_set_align(fmt5, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_name(fmt5, 'Times New Roman')
  lxw_format_set_font_size(fmt5, 13)

  lxw_worksheet_merge_range(sh2000, 1, 1, 1, 6, 'Сведения о приёмах (осмотрах), консультациях, исследованиях и иных медицинских вмешательствах, входящих в объем профилактического медицинского осмотра и первого этапа диспансеризации', fmt)
  lxw_worksheet_write_string(sh2000, 2, 0, '(2000)', fmt4)
  lxw_worksheet_write_string(sh2000, 2, 5, strOKEIed, fmt5)
  lxw_worksheet_write_string(sh2000, 3, 1, 'Приём (осмотр), консультация, исследование и иное медицинское вмешательство (далее - медицинское мероприятие), входящее в объем профилактического медицинского осмотра/первого этапа диспансеризации', fmt1)
  lxw_worksheet_write_string(sh2000, 3, 2, 'N  строки', fmt2)
  lxw_worksheet_write_string(sh2000, 3, 3, 'Проведено медицинских мероприятий', fmt2)
  lxw_worksheet_write_string(sh2000, 3, 4, 'Учтено из числа выполненных ранее (в предшествующие 12 мес.)', fmt2)
  lxw_worksheet_write_string(sh2000, 3, 5, 'Число отказов', fmt2)
  lxw_worksheet_write_string(sh2000, 3, 6, 'Выявлены патологические состояния', fmt2)
  lxw_worksheet_merge_range(sh2000, 5, 0, 26, 0, '', fmt2)

  for col := 1 to 6
    lxw_worksheet_write_string(sh2000, 4, col, alltrim(str(col)), fmt2)
  next
  lxw_worksheet_write_string(sh2000, 5, 1, 'Опрос (анкетирование)', fmt1)
  lxw_worksheet_write_string(sh2000, 6, 1, 'Расчет на основании антропометрии (измерение роста, массы тела, окружности талии) индекса массы тела', fmt1)
  lxw_worksheet_write_string(sh2000, 7, 1, 'Измерение артериального давления на периферических артериях', fmt1)
  lxw_worksheet_write_string(sh2000, 8, 1, 'Определение уровня общего холестерина в крови', fmt1)
  lxw_worksheet_write_string(sh2000, 9, 1, 'Определение уровня глюкозы в крови натощак', fmt1)
  lxw_worksheet_write_string(sh2000, 10, 1, 'Определение относительного сердечно-сосудистого риска', fmt1)
  lxw_worksheet_write_string(sh2000, 11, 1, 'Определение абсолютного сердечно-сосудистого риска', fmt1)
  lxw_worksheet_write_string(sh2000, 12, 1, 'Флюорография легких или рентгенография легких', fmt1)
  lxw_worksheet_write_string(sh2000, 13, 1, 'Электрокардиография в покое', fmt1)
  lxw_worksheet_write_string(sh2000, 14, 1, 'Измерение внутриглазного давления', fmt1)
  lxw_worksheet_write_string(sh2000, 15, 1, 'Осмотр фельдшером (акушеркой) или врачом акушером-гинекологом', fmt1)
  lxw_worksheet_write_string(sh2000, 16, 1, 'Взятие с использованием щетки цитологической цервикальной мазка (соскоба) с поверхности шейки матки (наружного маточного зева) и цервикального канала на цитологическое исследование, цитологическое исследование мазка с шейки матки', fmt1)
  lxw_worksheet_write_string(sh2000, 17, 1, 'Маммография обеих молочных желез в двух проекциях', fmt1)
  lxw_worksheet_write_string(sh2000, 18, 1, 'Исследование кала на скрытую кровь иммунохимическим методом', fmt1)
  lxw_worksheet_write_string(sh2000, 19, 1, 'Определение простат-специфического антигена в крови', fmt1)
  lxw_worksheet_write_string(sh2000, 20, 1, 'Эзофагогастродуоденоскопия', fmt1)
  lxw_worksheet_write_string(sh2000, 21, 1, 'Общий анализ крови', fmt1)
  lxw_worksheet_write_string(sh2000, 22, 1, 'Краткое индивидуальное профилактическое консультирование', fmt1)
  lxw_worksheet_write_string(sh2000, 23, 1, 'Прием (осмотр) по результатам профилактического медицинского осмотра фельдшером фельдшерского здравпункта или фельдшерско-акушерского пункта, врачом-терапевтом или врачом по медицинской профилактике отделения (кабинета) медицинской профилактики или центра здоровья граждан в возрасте 18 лет и старше, 1 раз в год', fmt1)
  lxw_worksheet_write_string(sh2000, 24, 1, 'Прием (осмотр) врачом-терапевтом по результатам первого этапа диспансеризации:                                                                                                                                           а) граждан в возрасте от 18 лет до 39 лет 1 раз в 3 года', fmt1)
  lxw_worksheet_write_string(sh2000, 25, 1, 'б) граждан в возрасте 40 лет и старше 1 раз в год', fmt1)
  lxw_worksheet_write_string(sh2000, 26, 1, 'Осмотр на выявление визуальных и иных локализаций онкологических заболеваний, включающий осмотр кожных покровов, слизистых губ и ротовой полости, пальпацию щитовидной железы, лимфатических узлов', fmt1)
  for row := 5 to 23
    lxw_worksheet_write_string(sh2000, row, 2, alltrim(str(row-4)), fmt2)
  next
  lxw_worksheet_write_string(sh2000, 24, 2, '19.1', fmt2)
  lxw_worksheet_write_string(sh2000, 25, 2, '19.2', fmt2)
  lxw_worksheet_write_string(sh2000, 26, 2, '20', fmt2)

  for row := 5 to 26
    for col := 3 to 6
      lxw_worksheet_write_string(sh2000, row, col, '', fmt3)
    next
  next

  lxw_worksheet_write_string(sh2000, 5, 4, 'X', fmt2)
  lxw_worksheet_write_string(sh2000, 23, 4, 'X', fmt2)
  lxw_worksheet_write_string(sh2000, 24, 4, 'X', fmt2)
  lxw_worksheet_write_string(sh2000, 25, 4, 'X', fmt2)
  lxw_worksheet_write_string(sh2000, 26, 4, 'X', fmt2)

  return sh2000

function createF131SH1000( workbook )
  local sh1000, col, row, i
  local fmt1

    
  sh1000 := lxw_workbook_add_worksheet(workbook, '1000, 1001' )
  lxw_worksheet_set_tab_color(sh1000, 0xFFFFCC)

  lxw_worksheet_set_column(sh1000, 0, 0, 8.4)
  lxw_worksheet_set_column(sh1000, 1, 1, 20.0)
  lxw_worksheet_set_column(sh1000, 2, 2, 7.2)
  lxw_worksheet_set_column(sh1000, 3, 12, 13.0)

  lxw_worksheet_set_row(sh1000, 0, 16)
  lxw_worksheet_set_row(sh1000, 1, 30)
  lxw_worksheet_set_row(sh1000, 2, 16)
  lxw_worksheet_set_row(sh1000, 3, 16)
  lxw_worksheet_set_row(sh1000, 4, 25)
  lxw_worksheet_set_row(sh1000, 5, 16)
  lxw_worksheet_set_row(sh1000, 6, 25)
  lxw_worksheet_set_row(sh1000, 7, 110)
  lxw_worksheet_set_row(sh1000, 8, 16)

  fmt := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmt, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_text_wrap(fmt)
  lxw_format_set_font_name(fmt, 'Times New Roman')
  lxw_format_set_font_size(fmt, 14)
  lxw_format_set_border(fmt, LXW_BORDER_MEDIUM)

  fmt1 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt1, LXW_ALIGN_RIGHT)
  lxw_format_set_font_name(fmt1, 'Times New Roman')
  lxw_format_set_bold(fmt1)
  lxw_format_set_font_size(fmt1, 12)

  fmt3 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt3, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmt3, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_text_wrap(fmt3)
  lxw_format_set_font_name(fmt3, 'Times New Roman')
  lxw_format_set_font_size(fmt3, 12)
  lxw_format_set_border(fmt3, LXW_BORDER_MEDIUM)

  fmt4 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt4, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmt4, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_text_wrap(fmt4)
  lxw_format_set_font_name(fmt4, 'Times New Roman')
  lxw_format_set_font_size(fmt4, 12)
  lxw_format_set_border(fmt4, LXW_BORDER_THIN)

  fmt5 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt5, LXW_ALIGN_CENTER)
  lxw_format_set_align(fmt5, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_bg_color(fmt5, LXW_COLOR_GRAY)
  lxw_format_set_font_name(fmt5, 'Times New Roman')
  lxw_format_set_font_size(fmt5, 12)
  lxw_format_set_border(fmt5, LXW_BORDER_THIN)

  fmt6 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt6, LXW_ALIGN_RIGHT)
  lxw_format_set_align(fmt6, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_bg_color(fmt6, LXW_COLOR_GRAY)
  lxw_format_set_font_name(fmt6, 'Times New Roman')
  lxw_format_set_font_size(fmt6, 12)
  lxw_format_set_border(fmt6, LXW_BORDER_MEDIUM)

  fmt7 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt7, LXW_ALIGN_RIGHT)
  lxw_format_set_align(fmt7, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_bg_color(fmt7, 0xFFFFCC)
  lxw_format_set_font_name(fmt7, 'Times New Roman')
  lxw_format_set_font_size(fmt7, 12)
  lxw_format_set_border(fmt7, LXW_BORDER_MEDIUM)

  fmt8 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt8, LXW_ALIGN_RIGHT)
  lxw_format_set_align(fmt8, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_bg_color(fmt8, 0xFFFFCC)
  lxw_format_set_font_name(fmt8, 'Times New Roman')
  lxw_format_set_font_size(fmt8, 12)
  lxw_format_set_border(fmt8, LXW_BORDER_THIN)

  fmt9 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt9, LXW_ALIGN_LEFT)
  lxw_format_set_align(fmt9, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_bold(fmt9)
  lxw_format_set_font_name(fmt9, 'Calibri')
  lxw_format_set_font_size(fmt9, 11)

  fmt10 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt10, LXW_ALIGN_LEFT)
  lxw_format_set_align(fmt10, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_name(fmt10, 'Calibri')
  lxw_format_set_font_size(fmt10, 11)

  lxw_worksheet_merge_range(sh1000, 1, 1, 1, 13, 'Сведения о проведении профилактического медицинского осмотра (ПМО) и диспансеризации определенных групп взрослого населения (ДОГВН)', fmt)
  lxw_worksheet_write_string(sh1000, 2, 12, strOKEI, nil)
  lxw_worksheet_write_string(sh1000, 3, 1, '(1000)', fmt1)
  lxw_worksheet_merge_range(sh1000, 4, 1, 7, 1, 'Возраст', fmt3)
  lxw_worksheet_merge_range(sh1000, 4, 2, 7, 2, '№ строки', fmt3)
  lxw_worksheet_merge_range(sh1000, 4, 3, 5, 6, 'Все взрослое население', fmt3)
  lxw_worksheet_merge_range(sh1000, 4, 7, 4, 14, 'в том числе', fmt3)
  lxw_worksheet_merge_range(sh1000, 5, 7, 5, 10, 'Мужчины', fmt3)
  lxw_worksheet_merge_range(sh1000, 5, 11, 5, 14, 'Женщины', fmt3)
  lxw_worksheet_merge_range(sh1000, 6, 3, 7, 3, 'Численность прикрепленного взрослого населения на 01.01 текущего года', fmt3)
  lxw_worksheet_merge_range(sh1000, 6, 4, 7, 4, 'Из них по плану подлежат: ПМО и ДОГВН (чел.)', fmt3)

  lxw_worksheet_merge_range(sh1000, 6, 5, 6, 6, 'Из них прошли:', fmt3)
  lxw_worksheet_write_string(sh1000, 7, 5, 'ПМО (чел.)', fmt3)
  lxw_worksheet_write_string(sh1000, 7, 6, 'ДОГВН (чел.)', fmt3)

  lxw_worksheet_merge_range(sh1000, 6, 7, 7, 7, 'Численность прикрепленного взрослого населения на 01.01 текущего года', fmt3)
  lxw_worksheet_merge_range(sh1000, 6, 8, 7, 8, 'Из них по плану подлежат: ПМО и ДОГВН (чел.)', fmt3)

  lxw_worksheet_merge_range(sh1000, 6, 9, 6, 10, 'Из них прошли:', fmt3)
  lxw_worksheet_write_string(sh1000, 7, 9, 'ПМО (чел.)', fmt3)
  lxw_worksheet_write_string(sh1000, 7, 10, 'ДОГВН (чел.)', fmt3)

  lxw_worksheet_merge_range(sh1000, 6, 11, 7, 11, 'Численность прикрепленного взрослого населения на 01.01 текущего года', fmt3)
  lxw_worksheet_merge_range(sh1000, 6, 12, 7, 12, 'Из них по плану подлежат: ПМО и ДОГВН (чел.)', fmt3)

  lxw_worksheet_merge_range(sh1000, 6, 13, 6, 14, 'Из них прошли:', fmt3)
  lxw_worksheet_write_string(sh1000, 7, 13, 'ПМО (чел.)', fmt3)
  lxw_worksheet_write_string(sh1000, 7, 14, 'ДОГВН (чел.)', fmt3)

  for col := 1 to 14
    lxw_worksheet_write_string(sh1000, 8, col, alltrim(str(col)), fmt4)
  next
  lxw_worksheet_write_string(sh1000, 9, 1, '18-34', fmt4)
  lxw_worksheet_write_string(sh1000, 10, 1, '35-39', fmt4)
  lxw_worksheet_write_string(sh1000, 11, 1, '40-54', fmt4)
  lxw_worksheet_write_string(sh1000, 12, 1, '55-59', fmt4)
  lxw_worksheet_write_string(sh1000, 13, 1, '60-64', fmt4)
  lxw_worksheet_write_string(sh1000, 14, 1, '65-74', fmt4)
  lxw_worksheet_write_string(sh1000, 15, 1, '75 и старше', fmt4)
  lxw_worksheet_write_string(sh1000, 16, 1, 'Всего', fmt5)
  for row := 1 to 7
    lxw_worksheet_write_string(sh1000, row + 8, 2, alltrim(str(row)), fmt4)
  next
  lxw_worksheet_write_string(sh1000, 16, 2, '8', fmt5)

  // временно
  for col := 7 to 14
    for row := 9 to 15
      lxw_worksheet_write_string(sh1000, row, col, '', fmt8)
    next
  next

  for i := 1 to 7
    lxw_worksheet_set_row(sh1000, i+8, 18.5)
    arg := 'H' + alltrim(str(i+9)) + '+L' + alltrim(str(i+9))
    lxw_worksheet_write_formula(sh1000, i+8, 3, arg, fmt5)
    arg := 'I' + alltrim(str(i+9)) + '+M' + alltrim(str(i+9))
    lxw_worksheet_write_formula(sh1000, i+8, 4, arg, fmt5)
    arg := 'J' + alltrim(str(i+9)) + '+N' + alltrim(str(i+9))
    lxw_worksheet_write_formula(sh1000, i+8, 5, arg, fmt5)
    arg := 'K' + alltrim(str(i+9)) + '+O' + alltrim(str(i+9))
    lxw_worksheet_write_formula(sh1000, i+8, 6, arg, fmt5)
  next
  lxw_worksheet_set_row(sh1000, 16, 18.5)
  lxw_worksheet_write_formula(sh1000, 16, 3, '=SUM(D10:D16)', fmt5)
  lxw_worksheet_write_formula(sh1000, 16, 4, '=SUM(E10:E16)', fmt5)
  lxw_worksheet_write_formula(sh1000, 16, 5, '=SUM(F10:F16)', fmt5)
  lxw_worksheet_write_formula(sh1000, 16, 6, '=SUM(G10:G16)', fmt5)

  lxw_worksheet_write_formula(sh1000, 16, 7, '=SUM(H10:H16)', fmt5)
  lxw_worksheet_write_formula(sh1000, 16, 8, '=SUM(I10:I16)', fmt5)
  lxw_worksheet_write_formula(sh1000, 16, 9, '=SUM(J10:J16)', fmt5)
  lxw_worksheet_write_formula(sh1000, 16, 10, '=SUM(K10:K16)', fmt5)
  lxw_worksheet_write_formula(sh1000, 16, 11, '=SUM(L10:L16)', fmt5)
  lxw_worksheet_write_formula(sh1000, 16, 12, '=SUM(M10:M16)', fmt5)
  lxw_worksheet_write_formula(sh1000, 16, 13, '=SUM(N10:N16)', fmt5)
  lxw_worksheet_write_formula(sh1000, 16, 14, '=SUM(O10:O16)', fmt5)

  lxw_worksheet_write_string(sh1000, 18, 1, '(1001)', fmt1)
  lxw_worksheet_write_string(sh1000, 18, 5, 'Код по ОКЕИ: человек - 792', nil)

  lxw_worksheet_merge_range(sh1000, 19, 1, 19, 7, 'Число лиц в трудоспособном возрасте прошло:', fmt9)
  lxw_worksheet_merge_range(sh1000, 20, 1, 20, 5, 'диспансеризацию определенных групп взрослого населения всего        1', fmt9)
  lxw_worksheet_write_formula(sh1000, 20, 6, '=SUM(D22:D23)', fmt6)

  lxw_worksheet_merge_range(sh1000, 21, 1, 21, 2, 'в том числе: женщин              2', fmt10)
  lxw_worksheet_write_string(sh1000, 21, 3, '',fmt7)
  lxw_worksheet_merge_range(sh1000, 22, 1, 22, 2, '  мужчин                         3', fmt10)
  lxw_worksheet_write_string(sh1000, 22, 3, '',fmt7)

  lxw_worksheet_merge_range(sh1000, 24, 1, 24, 5, 'профилактический медицинский осмотр всего                                             4 ', fmt9)
  lxw_worksheet_write_formula(sh1000, 24, 6, '=SUM(D26:D27)', fmt6)

  lxw_worksheet_merge_range(sh1000, 25, 1, 25, 2, 'в том числе: женщин              5', fmt10)
  lxw_worksheet_write_string(sh1000, 25, 3, '',fmt7)
  lxw_worksheet_merge_range(sh1000, 26, 1, 26, 2, '  мужчин                         6', fmt10)
  lxw_worksheet_write_string(sh1000, 26, 3, '',fmt7)
  
  return sh1000
    
function createF131SH5000( workbook )
  local sh5000
              
  sh5000 := lxw_workbook_add_worksheet(workbook, '5000, 5001' )
              
  return sh5000

function createF131SH6000( workbook )
    local sh6000
              
  sh6000 := lxw_workbook_add_worksheet(workbook, '6000-6010' )
  lxw_worksheet_set_tab_color(sh6000, LXW_COLOR_GRAY)
              
  return sh6000
  
function createF131SH5000PO( workbook )
  local sh5000PO
            
  sh5000PO := lxw_workbook_add_worksheet(workbook, '5000 и 5001 ПО' )
  lxw_worksheet_set_tab_color(sh5000PO, LXW_COLOR_GRAY)
            
  return sh5000PO
  


function createF131SH3001( workbook )
  local sh3001, fmt1, fmt2, fmt3, fmt4
            
  sh3001 := lxw_workbook_add_worksheet(workbook, '3001, 3002, 3003' )
  lxw_worksheet_set_tab_color(sh3001, 0xFFFFCC)
  lxw_worksheet_set_column(sh3001, 0, 15, 9.0)
  lxw_worksheet_set_column(sh3001, 16, 16, 16.0)
  
  fmt1 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt1, LXW_ALIGN_RIGHT)
  lxw_format_set_bold(fmt1)
  lxw_format_set_font_size(fmt1, 16)
  
  fmt2 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt2, LXW_ALIGN_LEFT)
  lxw_format_set_font_size(fmt2, 12)
  
  fmt3 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt3, LXW_ALIGN_LEFT)
  lxw_format_set_align(fmt3, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_text_wrap(fmt3)
  lxw_format_set_font_size(fmt3, 14)
  
  fmt4 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(fmt4, LXW_ALIGN_RIGHT)
  lxw_format_set_align(fmt4, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(fmt4, 12)
  lxw_format_set_border(fmt4, LXW_BORDER_MEDIUM)
  lxw_format_set_bg_color(fmt4, 0xFFFFCC)
  
  lxw_worksheet_set_row(sh3001, 1, 20.0)
  lxw_worksheet_write_string(sh3001, 1, 1, '(3001)', fmt1)
  lxw_worksheet_write_string(sh3001, 1, 12, strOKEI, fmt2)
    
  lxw_worksheet_set_row(sh3001, 3, 35.0)
  lxw_worksheet_merge_range(sh3001, 3, 1, 3, 15, 'Число лиц, прошедших полностью все мероприятия второго этапа диспансеризации, на которые они были направлены по результатам первого этапа', fmt3)
  lxw_worksheet_write_string(sh3001, 3, 16, '', fmt4)
  lxw_worksheet_write_string(sh3001, 3, 17, ';', fmt3)
  
  lxw_worksheet_set_row(sh3001, 5, 20.0)
  lxw_worksheet_write_string(sh3001, 5, 1, '(3002)', fmt1)
  lxw_worksheet_write_string(sh3001, 5, 12, strOKEI, fmt2)
  
  lxw_worksheet_set_row(sh3001, 7, 35.0)
  lxw_worksheet_merge_range(sh3001, 7, 1, 7, 15, 'Число лиц, прошедших частично (не все рекомендованные) мероприятия второго этапа диспансеризации, на которые они были направлены по результатам первого этапа', fmt3)
  lxw_worksheet_write_string(sh3001, 7, 16, '', fmt4)
  lxw_worksheet_write_string(sh3001, 7, 17, ';', fmt3)
  
  lxw_worksheet_set_row(sh3001, 9, 20.0)
  lxw_worksheet_write_string(sh3001, 9, 1, '(3003)', fmt1)
  lxw_worksheet_write_string(sh3001, 9, 12, strOKEI, fmt2)
  
  lxw_worksheet_set_row(sh3001, 11, 35.0)
  lxw_worksheet_merge_range(sh3001, 11, 1, 11, 15, 'Число лиц, не прошедших ни одного мероприятия второго этапа диспансеризации, на которые они были направлены по результатам первого этапа', fmt3)
  lxw_worksheet_write_string(sh3001, 11, 16, '', fmt4)
  lxw_worksheet_write_string(sh3001, 11, 17, ';', fmt3)
  
  return sh3001
    
function createF131Titul( workbook )
  local shTitul

  shTitul := lxw_workbook_add_worksheet(workbook, 'Титульный лист' )

  /* Конфигурируем формат для шапки. */

  shTitulHead1 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(shTitulHead1, LXW_ALIGN_RIGHT)
  lxw_format_set_align(shTitulHead1, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_bold(shTitulHead1)
  lxw_format_set_font_size(shTitulHead1, 12)
  // lxw_format_set_text_wrap(shTitulHead1)
  // lxw_format_set_border(shTitulHead1, LXW_BORDER_THIN)

  shTitulHead2 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(shTitulHead2, LXW_ALIGN_RIGHT)
  lxw_format_set_align(shTitulHead2, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_bold(shTitulHead2)
  lxw_format_set_font_size(shTitulHead2, 11)
  // lxw_format_set_text_wrap(shTitulHead1)
  // lxw_format_set_border(shTitulHead1, LXW_BORDER_THIN)

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
  lxw_format_set_text_wrap(shTitulFmt3)
  lxw_format_set_border(shTitulFmt3, LXW_BORDER_THICK)

  shTitulFmt4 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(shTitulFmt4, LXW_ALIGN_LEFT)
  lxw_format_set_align(shTitulFmt4, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(shTitulFmt4, 12)
  lxw_format_set_text_wrap(shTitulFmt4)
  lxw_format_set_border(shTitulFmt4, LXW_BORDER_THIN)

  shTitulSign1 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(shTitulSign1, LXW_ALIGN_LEFT)
  lxw_format_set_align(shTitulSign1, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(shTitulSign1, 14)
  lxw_format_set_bg_color(shTitulSign1, 0xFFFFCC)
  // lxw_format_set_text_wrap(shTitulSign1)
  lxw_format_set_border(shTitulSign1, LXW_BORDER_THIN)

  shTitulSign2 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(shTitulSign2, LXW_ALIGN_LEFT)
  lxw_format_set_align(shTitulSign2, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(shTitulSign2, 14)
  lxw_format_set_text_wrap(shTitulSign2)
  // lxw_format_set_border(shTitulSign2, LXW_BORDER_THIN)

  shTitulSign3 := lxw_workbook_add_format(workbook)
  lxw_format_set_align(shTitulSign3, LXW_ALIGN_LEFT)
  lxw_format_set_align(shTitulSign3, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(shTitulSign3, 14)
  // lxw_format_set_text_wrap(shTitulSign3)
  // lxw_format_set_border(shTitulFmt4, LXW_BORDER_THIN)

  url_format   = lxw_workbook_add_format(workbook)
  lxw_format_set_align(url_format, LXW_ALIGN_CENTER)
  lxw_format_set_align(url_format, LXW_ALIGN_VERTICAL_CENTER)
  lxw_format_set_font_size(url_format, 12)
  lxw_format_set_underline (url_format, LXW_UNDERLINE_SINGLE)
  lxw_format_set_font_color(url_format, LXW_COLOR_BLUE)
  lxw_format_set_text_wrap(url_format)
  lxw_format_set_border(url_format, LXW_BORDER_THIN)

  lxw_worksheet_set_column(shTitul, 0, 0, 8.2)
  lxw_worksheet_set_column(shTitul, 1, 1, 95.0)
  lxw_worksheet_set_column(shTitul, 2, 2, 18.0)
  lxw_worksheet_set_column(shTitul, 3, 3, 19.0)
  lxw_worksheet_set_column(shTitul, 4, 4, 14.0)
  lxw_worksheet_set_column(shTitul, 5, 5, 14.0)
  lxw_worksheet_set_column(shTitul, 6, 6, 14.0)

  lxw_worksheet_write_string(shTitul, 1, 6, 'Приложение № 3', shTitulHead1)
  lxw_worksheet_write_string(shTitul, 2, 6, 'К приказу министерства здравоохранения', shTitulHead2)
  lxw_worksheet_write_string(shTitul, 3, 6, 'Российской Федерации', shTitulHead1)
  lxw_worksheet_write_string(shTitul, 4, 6, 'от 10 ноября 2020 г. № 1207н', shTitulHead1)
  lxw_worksheet_merge_range(shTitul, 6, 1, 6, 2, 'ОТРАСЛЕВАЯ СТАТИСТИЧЕСКАЯ ОТЧЕТНОСТЬ', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 8, 1, 8, 2, 'КОНФИДЕНЦИАЛЬНОСТЬ ГАРАНТИРУЕТСЯ ПОЛУЧАТЕЛЕМ ИНФОРМАЦИИ', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 10, 1, 10, 3, 'ВОЗМОЖНО ПРЕДСТАВЛЕНИЕ В ЭЛЕКТРОННОМ ВИДЕ', shTitulFmt2)

  lxw_worksheet_set_row(shTitul, 12, 55.0)
  lxw_worksheet_merge_range(shTitul, 12, 1, 12, 3, '"СВЕДЕНИЯ О ПРОВЕДЕНИИ ПРОФИЛАКТИЧЕСКОГО МЕДИЦИНСКОГО ОСМОТРА И ДИСПАНСЕРИЗАЦИИ ОПРЕДЕЛЕННЫХ ГРУПП ВЗРОСЛОГО НАСЕЛЕНИЯ"', shTitulFmt3)

  lxw_worksheet_set_row(shTitul, 13, 25.0)
  lxw_worksheet_write_string(shTitul,13, 1, '2021 года                          за период', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,13, 2, 'январь', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,13, 3, 'февраль', shTitulFmt1)

  lxw_worksheet_set_row(shTitul, 15, 25.0)
  lxw_worksheet_write_string(shTitul,15, 1, 'Представляют:', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 15, 2, 14, 3, 'Сроки представления', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 15, 5, 14, 6, 'ФОРМА № 131/о', shTitulFmt1)

  lxw_worksheet_merge_range(shTitul, 16, 1, 18, 1, 'Медицинские организации, оказывающие первичную медико-санитарную помощь (далее - медицинская организация), органу исполнительной власти субъектов Российской Федерации в сфере охраны здоровья', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 16, 2, 18, 3, '5 числа месяца, следующего за отчетным периодом', shTitulFmt1)
  // lxw_worksheet_set_row(shTitul, 16, 10.5)
  // lxw_worksheet_set_row(shTitul, 17, 10.5)
  lxw_worksheet_merge_range(shTitul, 17, 4, 17, 6, 'Утверждена приказом Минздрава России', shTitulFmt2)
  lxw_worksheet_set_row(shTitul, 18, 25.0)
  lxw_worksheet_merge_range(shTitul, 18, 4, 18, 6, 'от ___________ № _____________', shTitulFmt2)

  lxw_worksheet_set_row(shTitul, 19, 45.5)
  lxw_worksheet_write_string(shTitul, 19, 1, 'Органы исполнительной власти субъектов Российской Федерации в сфере охраны здоровья - Министерству здравоохранения Российской Федерации', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 19, 2, 19, 3, '10 числа месяца, следующего за отчетным периодом', shTitulFmt1)
  
  lxw_worksheet_write_string(shTitul,21, 1, 'Наименование медицинской организации:', shTitulFmt4)
  lxw_worksheet_merge_range(shTitul, 22, 1, 22, 6, 'Почтовый адрес:', shTitulFmt4)

  lxw_worksheet_set_row(shTitul, 23, 60.0)
  lxw_worksheet_write_string(shTitul,23, 1, 'Код медицинской организации по ОКПО', shTitulFmt4)

  lxw_worksheet_write_url(shTitul, 23, 2, 'http://ivo.garant.ru/#/document/70650726/paragraph/11371:0', url_format)
  lxw_worksheet_write_string(shTitul,23, 2, 'Код вида деятельности по ОКВЭД', url_format)
  lxw_worksheet_write_string(shTitul,23, 3, 'Код отрасли по ОКОНХ', shTitulFmt1)
  lxw_worksheet_write_url(shTitul, 23, 4, 'http://ivo.garant.ru/#/document/179064/entry/0', url_format)
  lxw_worksheet_write_string(shTitul,23, 4, 'Код территории по ОКАТО', url_format)
  
  lxw_worksheet_merge_range(shTitul, 23, 5, 23, 6, 'Код органа исполнительной власти субъекта Российской федерации в сфере охраны здоровья по ОКУД', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,24, 1, '1', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,24, 2, '2', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,24, 3, '3', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,24, 4, '4', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 24, 5, 24, 6, '5', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,25, 1, '00088390', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,25, 2, '75.11.21', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,25, 3, '', shTitulFmt1)
  lxw_worksheet_write_string(shTitul,25, 4, '18401395000', shTitulFmt1)
  lxw_worksheet_merge_range(shTitul, 25, 5, 25, 6, '2300229', shTitulFmt1)

  lxw_worksheet_set_row(shTitul, 27, 35.0)
  lxw_worksheet_write_string(shTitul,27, 1, 'Должностное лицо (уполномоченный представитель), ответственное за предоставление статистической информации ', shTitulSign2)
  lxw_worksheet_write_string(shTitul,28, 1, ' ', shTitulSign1)
  lxw_worksheet_write_string(shTitul,28, 2, 'должность (руководитель медицинско организации', shTitulSign3)
  lxw_worksheet_write_string(shTitul,29, 1, ' ', shTitulSign1)
  lxw_worksheet_write_string(shTitul,29, 2, 'Ф.И.О.', shTitulSign3)
  lxw_worksheet_write_string(shTitul,30, 1, ' ', shTitulSign1)
  lxw_worksheet_write_string(shTitul,30, 2, 'Ф.И.О. исполнителя', shTitulSign3)
  lxw_worksheet_write_string(shTitul,31, 1, ' ', shTitulSign1)
  lxw_worksheet_write_string(shTitul,31, 2, 'номер контактного телефона', shTitulSign3)
  lxw_worksheet_write_string(shTitul,32, 1, ' ', shTitulSign1)
  lxw_worksheet_write_string(shTitul,32, 2, 'E-mail', shTitulSign3)
  lxw_worksheet_write_string(shTitul,32, 5, 'М.П.', shTitulSign3)

  return shTitul