#require 'hbhpdf'

#include 'harupdf.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 21.04.25
function pdf_header_reestr( page, nX, nY, nHeight )

  // Вывод шапки таблицы с левого нижнего угла nX nY по указанной высоте nHeght.
  
  local sText, textLeading, err

  textLeading := HPDF_Page_GetTextLeading( page )
  HPDF_Page_SetTextLeading( page, 9.0 ) // по умолчанию 15.74

  sText := '№ позиц ии реест ра'
  err := out_text_in_rectangle( page, sText, nX, nY, 8, nHeight, HPDF_TALIGN_CENTER )
  nX += 8

  sText := 'Фамилия, имя, отчество (при наличии)'
  err := out_text_in_rectangle( page, sText, nX, nY, 24, nHeight, HPDF_TALIGN_CENTER )
  nX += 24

  sText := 'Пол'
  err := out_text_in_rectangle( page, sText, nX, nY, 6, nHeight, HPDF_TALIGN_CENTER )
  nX += 6
  
  sText := 'Дата рождения'
  err := out_text_in_rectangle( page, sText, nX, nY, 13, nHeight, HPDF_TALIGN_CENTER )
  nX += 13

  sText := 'Место рождения'
  err := out_text_in_rectangle( page, sText, nX, nY, 21, nHeight, HPDF_TALIGN_CENTER )
  nX += 21

  sText := 'Данные документа удостоверяющ его личность'
  err := out_text_in_rectangle( page, sText, nX, nY, 18, nHeight, HPDF_TALIGN_CENTER )
  nX += 18
  
  sText := 'Место жительства'
  err := out_text_in_rectangle( page, sText, nX, nY, 23, nHeight, HPDF_TALIGN_CENTER )
  nX += 23

  sText := 'Место регистрации'
  err := out_text_in_rectangle( page, sText, nX, nY, 23, nHeight, HPDF_TALIGN_CENTER )
  nX += 23

  sText := 'СНИЛС (при наличии)'
  err := out_text_in_rectangle( page, sText, nX, nY, 12, nHeight, HPDF_TALIGN_CENTER )
  nX += 12

  sText := '№ полиса обязательно го медицинског о страхования'
  err := out_text_in_rectangle( page, sText, nX, nY, 16, nHeight, HPDF_TALIGN_CENTER )
  nX += 16

  sText := 'Вид оказан ной медиц инской помощ и (код)'
  err := out_text_in_rectangle( page, sText, nX, nY, 9, nHeight, HPDF_TALIGN_CENTER )
  nX += 9

  sText := 'Диагноз в соответ ствии с МКБ-10'
  err := out_text_in_rectangle( page, sText, nX, nY, 10, nHeight, HPDF_TALIGN_CENTER )
  nX += 10

  sText := 'Дата начала и дата окончания лечения'
  err := out_text_in_rectangle( page, sText, nX, nY, 13, nHeight, HPDF_TALIGN_CENTER )
  nX += 13

  sText := 'Объемы оказанн ой медици нской помощи'
  err := out_text_in_rectangle( page, sText, nX, nY, 10, nHeight, HPDF_TALIGN_CENTER )
  nX += 10

  sText := 'Профиль оказанной медицинск ой помощи (код)'
  err := out_text_in_rectangle( page, sText, nX, nY, 14, nHeight, HPDF_TALIGN_CENTER )
  nX += 14

  sText := 'Специальн ость медицинско го работника, оказавшего медицинску ю помощь (код)'
  err := out_text_in_rectangle( page, sText, nX, nY, 15, nHeight, HPDF_TALIGN_CENTER )
  nX += 15

  sText := 'Тариф на оплату медицинск ой помощи, оказанной застрахов анному лицу'
  err := out_text_in_rectangle( page, sText, nX, nY, 14, nHeight, HPDF_TALIGN_CENTER )
  nX += 14

  sText := 'Стоимость оказанной медицинской помощи'
  err := out_text_in_rectangle( page, sText, nX, nY, 17, nHeight, HPDF_TALIGN_CENTER )
  nX += 17

  sText := 'Результ ат обраще ния за медици нской помощь ю (код)'
  err := out_text_in_rectangle( page, sText, nX, nY, 10, nHeight, HPDF_TALIGN_CENTER )
  nX += 10
  HPDF_Page_SetTextLeading( page, textLeading )
  return nil

// 20.04.25
function print_pdf_header_page_reestr( page, top_text, bottom )
  
  local sText

  sText := '1'
  out_text_rectangle( page, 12, top_text, 20, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 12 ), mm_to_pt( bottom ), mm_to_pt( 8 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '2'
  out_text_rectangle( page, 20, top_text, 44, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 20 ), mm_to_pt( bottom ), mm_to_pt( 24 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '3'
  out_text_rectangle( page, 44, top_text, 50, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 44 ), mm_to_pt( bottom ), mm_to_pt( 6 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '4'
  out_text_rectangle( page, 50, top_text, 63, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 50 ), mm_to_pt( bottom ), mm_to_pt( 13 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '5'
  out_text_rectangle( page, 63, top_text, 84, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 63 ), mm_to_pt( bottom ), mm_to_pt( 21 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '6'
  out_text_rectangle( page, 84, top_text, 102, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 84 ), mm_to_pt( bottom ), mm_to_pt( 18 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '7'
  out_text_rectangle( page, 102, top_text, 125, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 102 ), mm_to_pt( bottom ), mm_to_pt( 23 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '8'
  out_text_rectangle( page, 125, top_text, 148, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 125 ), mm_to_pt( bottom ), mm_to_pt( 23 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '9'
  out_text_rectangle( page, 148, top_text, 160, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 148 ), mm_to_pt( bottom ), mm_to_pt( 12 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '10'
  out_text_rectangle( page, 160, top_text, 176, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 160 ), mm_to_pt( bottom ), mm_to_pt( 16 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '11'
  out_text_rectangle( page, 176, top_text, 185, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 176 ), mm_to_pt( bottom ), mm_to_pt( 9 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '12'
  out_text_rectangle( page, 185, top_text, 195, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 185 ), mm_to_pt( bottom ), mm_to_pt( 10 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '13'
  out_text_rectangle( page, 195, top_text, 208, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 195 ), mm_to_pt( bottom ), mm_to_pt( 13 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '14'
  out_text_rectangle( page, 208, top_text, 218, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 208 ), mm_to_pt( bottom ), mm_to_pt( 10 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '15'
  out_text_rectangle( page, 218, top_text, 232, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 218 ), mm_to_pt( bottom ), mm_to_pt( 14 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '16'
  out_text_rectangle( page, 232, top_text, 247, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 232 ), mm_to_pt( bottom ), mm_to_pt( 15 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '17'
  out_text_rectangle( page, 247, top_text, 261, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 247 ), mm_to_pt( bottom ), mm_to_pt( 14 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '18'
  out_text_rectangle( page, 261, top_text, 278, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 261 ), mm_to_pt( bottom ), mm_to_pt( 17 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  sText := '19'
  out_text_rectangle( page, 278, top_text, 288, bottom, sText, HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 278 ), mm_to_pt( bottom ), mm_to_pt( 10 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  return nil

// 21.04.25
function print_pdf_reestr( cFileToSave )

  LOCAL pdf
  local fError, pdfReturn
  local page, c1 := 'CP1251', sText, sTextReestr
  local fnt_arial, fnt_arial_bold, fnt_arial_italic, r_t, r_tb, r_ti
  local dbName := '_titl.dbf', dbAlias := 'FRT'
  local iPage, q1

  fError := tfiletext():new( cur_dir() + 'error_pdf.txt', , .t., , .t. ) 
  fError:width := 100

  IF ( pdf := HPDF_New() ) == NIL   // создание pdf - объекта файла
    fError:add_string( 'HPDF_New() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    fError := nil
    func_error( 4, 'Реестр счета не может быть создан!' )
    RETURN nil
  ENDIF

  /* установим режим сжатия */
  if ( pdfReturn := HPDF_SetCompressionMode( pdf, HPDF_COMP_ALL ) ) != HPDF_OK
    fError:add_string( 'HPDF_SetCompressionMode() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  if ( pdfReturn := HPDF_SetPageMode( pdf, HPDF_PAGE_MODE_USE_NONE ) ) != HPDF_OK
    fError:add_string( 'HPDF_SetPageMode() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  // регистрация шрифтов с вложением в pdf
  fnt_arial = HPDF_LoadTTFontFromFile( pdf, GetEnv( 'SystemRoot' ) + '\Fonts\arial.ttf', .t. ) // текст Arial
  fnt_arial_bold = HPDF_LoadTTFontFromFile( pdf, GetEnv( 'SystemRoot' ) + '\Fonts\arialbd.ttf', .t. ) // текст Arial Bold
  fnt_arial_italic = HPDF_LoadTTFontFromFile( pdf, GetEnv( 'SystemRoot' ) + '\Fonts\ariali.ttf', .t. ) // текст Arial Italic
  r_t = HPDF_GetFont( pdf, fnt_arial, c1 ) // указатели для шрифтов текст
  r_tb = HPDF_GetFont( pdf, fnt_arial_bold, c1 ) // текст BOLD
  r_ti = HPDF_GetFont( pdf, fnt_arial_italic, c1 ) // текст ITALIC
  If Empty( r_t ) .or. Empty( r_tb )
    fError:add_string( 'HPDF_GetFont() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    HPDF_Free( pdf ) // аннулирование pdf
    Return nil
  Endif

  // тело печати
  iPage := 2 // временно
  For q1 = 1 To iPage // цикл создания страниц (к примеру)
    /* добавим новый объект СТРАНИЦА. */
    if ( page := HPDF_AddPage( pdf ) ) == nil
      fError:add_string( 'HPDF_AddPage() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    endif
    if ( pdfReturn := HPDF_Page_SetSize( page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_LANDSCAPE ) ) != HPDF_OK
      fError:add_string( 'HPDF_Page_SetSize() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    endif
    sTextReestr := 'РЕЕСТР СЧЕТА'
    if q1 == 1
      HPDF_Page_SetFontAndSize( page, r_t, 10 ) // выбор шрифта из подключенных и его размер
      out_text_rectangle( page, 12, 200, 282, 195, sTextReestr, HPDF_TALIGN_CENTER )
      sText := 'Акционерное общество ""Многопрофильный медицинский центр", ' + 'ОГРН'
      out_text_rectangle( page, 12, 195, 282, 190, sText, HPDF_TALIGN_CENTER )
      sText := 'за период с 1 марта 2025 г. по 31 марта 2025 г.'
      out_text_rectangle( page, 12, 190, 282, 185, sText, HPDF_TALIGN_CENTER )
    
      sText := 'на оплату медицинской помощи, оказанной застрахованным лицам, в Административное структурное подразделение ООО "Капитал МС" - Филиал в Волгоградской области'
      out_text_rectangle( page, 12, 185, 282, 175, sText, HPDF_TALIGN_CENTER )

      HPDF_Page_SetFontAndSize( page, r_t, 7 ) // выбор шрифта из подключенных и его размер
      pdf_header_reestr( page, 12, 135, 30 )
//      print_pdf_header_page_reestr( page, 165, 135 )
    else
      HPDF_Page_SetFontAndSize( page, r_ti, 7 ) // выбор шрифта из подключенных и его размер
      out_text_rectangle( page, 12, 205, 290, 200, sTextReestr + ' стр.' + AllTrim( str( q1, 4 ) ), HPDF_TALIGN_RIGHT )
      HPDF_Page_SetFontAndSize( page, r_t, 7 ) // выбор шрифта из подключенных и его размер
      print_pdf_header_page_reestr( page, 199, 195 )      
    endif
  next

  IF HPDF_SaveToFile( pdf, cFileToSave ) != 0
    fError:add_string( 'HPDF_SaveToFile() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    func_error( 4, 'Ошибка создания печатной формы реестра счета!' )
  ENDIF 
    
  HPDF_Free( pdf )
  fError := nil
  return nil

// 20.04.25
function print_pdf_order( cFileToSave )

  LOCAL pdf
  local fError, pdfReturn
  local page, c1 := 'CP1251'
  local fnt_arial, fnt_arial_bold, r_t, r_tb
  local dbName := '_titl.dbf', dbAlias := 'FRT'

  fError := tfiletext():new( cur_dir() + 'error_pdf.txt', , .t., , .t. ) 
  fError:width := 100
  
  IF ( pdf := HPDF_New() ) == NIL   // создание pdf - объекта файла
    fError:add_string( 'HPDF_New() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    fError := nil
    func_error( 4, 'Счет на оплату медицинской помощи не может быть создан!' )
    RETURN nil
  ENDIF

  /* установим режим сжатия */
  if ( pdfReturn := HPDF_SetCompressionMode( pdf, HPDF_COMP_ALL ) ) != HPDF_OK
    fError:add_string( 'HPDF_SetCompressionMode() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  if ( pdfReturn := HPDF_SetPageMode( pdf, HPDF_PAGE_MODE_USE_NONE ) ) != HPDF_OK
    fError:add_string( 'HPDF_SetPageMode() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  // регистрация шрифтов с вложением в pdf
  fnt_arial = HPDF_LoadTTFontFromFile( pdf, GetEnv( 'SystemRoot' ) + '\Fonts\arial.ttf', .t. ) // текст Arial
  fnt_arial_bold = HPDF_LoadTTFontFromFile( pdf, GetEnv( 'SystemRoot' ) + '\Fonts\arialbd.ttf', .t. ) // текст Arial Bold
  r_t = HPDF_GetFont( pdf, fnt_arial, c1 ) // указатели для шрифтов текст
  r_tb = HPDF_GetFont( pdf, fnt_arial_bold, c1 ) // текст BOLD
  If Empty( r_t ) .or. Empty( r_tb )
    fError:add_string( 'HPDF_GetFont() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    HPDF_Free( pdf ) // аннулирование pdf
    Return nil
  Endif

  /* добавим новый объект СТРАНИЦА. */
  if ( page := HPDF_AddPage( pdf ) ) == nil
    fError:add_string( 'HPDF_AddPage() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  if ( pdfReturn := HPDF_Page_SetSize( page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT ) ) != HPDF_OK
    fError:add_string( 'HPDF_Page_SetSize() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  dbUseArea( .t., , cur_dir() + dbName, dbAlias, .t., .f. )
  ( dbAlias )->( dbGoto( 1 ) )

  // шапка счета
  HPDF_Page_SetLineWidth( page, 0.5 )

  HPDF_Page_SetFontAndSize( page, r_tb, 11 ) // выбор шрифта из подключенных и его размер
  out_text_rectangle( page, 10, 290, 200, 284, AllTrim( ( dbAlias )->name ), HPDF_TALIGN_LEFT )

  HPDF_Page_SetFontAndSize( page, r_t, 10 ) // выбор шрифта из подключенных и его размер
  out_text_rectangle( page, 10, 282, 200, 275, AllTrim( ( dbAlias )->adres ), HPDF_TALIGN_LEFT )

  HPDF_Page_Rectangle( page, mm_to_pt( 10 ), mm_to_pt( 210 ), mm_to_pt( 190 ), mm_to_pt( 40 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_MoveTo( page, mm_to_pt( 10 ), mm_to_pt( 230 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 200 ), mm_to_pt( 230 ) )
  HPDF_Page_Stroke( page )

  out_text_rectangle( page, 11, 249, 60, 244, 'ИНН: ' + AllTrim( ( dbAlias )->inn ), HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 61, 249, 110, 244, 'КПП: ' + AllTrim( ( dbAlias )->kpp ), HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 11, 243, 110, 230, 'Поставщик: ' + AllTrim( ( dbAlias )->name_schet ), HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 126, 235, 200, 230, AllTrim( ( dbAlias )->r_schet ), HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 126, 229, 200, 224, AllTrim( ( dbAlias )->bik ), HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 126, 223, 200, 218, AllTrim( ( dbAlias )->k_schet ), HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 11, 223, 110, 207, AllTrim( ( dbAlias )->bank ), HPDF_TALIGN_LEFT )

  HPDF_Page_MoveTo( page, mm_to_pt( 10 ), mm_to_pt( 244 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 110 ), mm_to_pt( 244 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_MoveTo( page, mm_to_pt( 110 ), mm_to_pt( 210 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 110 ), mm_to_pt( 250 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_MoveTo( page, mm_to_pt( 60 ), mm_to_pt( 244 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 60 ), mm_to_pt( 250 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_MoveTo( page, mm_to_pt( 125 ), mm_to_pt( 210 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 125 ), mm_to_pt( 250 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_MoveTo( page, mm_to_pt( 110 ), mm_to_pt( 217 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 125 ), mm_to_pt( 217 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_MoveTo( page, mm_to_pt( 110 ), mm_to_pt( 223 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 125 ), mm_to_pt( 223 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_SetFontAndSize( page, r_t, 10 ) // выбор шрифта из подключенных и его размер
  out_text( page, 113, 232, 'Сч. №' )
  out_text( page, 11, 226, 'Банк получателя:' )
  out_text( page, 113, 225, 'БИК' )
  HPDF_Page_SetFontAndSize( page, r_t, 9 ) // выбор шрифта из подключенных и его размер
  out_text( page, 110, 219, 'Кор.сч. №' )

  //Тело счета

  HPDF_Page_SetFontAndSize( page, r_tb, 11 ) // выбор шрифта из подключенных и его размер
  out_text( page, 65, 182, 'СЧЕТ № ' + AllTrim( ( dbAlias )->nschet ) + ' от ' + AllTrim( ( dbAlias )->dschet ) )

  HPDF_Page_SetFontAndSize( page, r_t, 10 ) // выбор шрифта из подключенных и его размер
  out_text( page, 10, 165, 'Плательщик:' )
  HPDF_Page_SetTextLeading( page, 10.0 ) // по умолчанию 15.74
  out_text_rectangle( page, 35, 170, 200, 155, AllTrim( ( dbAlias )->plat ), HPDF_TALIGN_LEFT )
  
  HPDF_Page_Rectangle( page, mm_to_pt( 10 ), mm_to_pt( 155 ), mm_to_pt( 7 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  out_text( page, 12, 156, '№' )
  HPDF_Page_Rectangle( page, mm_to_pt( 17 ), mm_to_pt( 155 ), mm_to_pt( 143 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  out_text_rectangle( page, 18, 160, 158, 155, 'Наименование услуг', HPDF_TALIGN_CENTER )
  HPDF_Page_Rectangle( page, mm_to_pt( 160 ), mm_to_pt( 155 ), mm_to_pt( 40 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  out_text_rectangle( page, 158, 160, 200, 155, 'Сумма', HPDF_TALIGN_CENTER )

  HPDF_Page_Rectangle( page, mm_to_pt( 10 ), mm_to_pt( 150 ), mm_to_pt( 7 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  out_text( page, 12, 151, '1' )
  HPDF_Page_Rectangle( page, mm_to_pt( 17 ), mm_to_pt( 150 ), mm_to_pt( 143 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  out_text_rectangle( page, 18, 155, 158, 150, AllTrim( ( dbAlias )->susluga ), HPDF_TALIGN_LEFT )
  HPDF_Page_Rectangle( page, mm_to_pt( 160 ), mm_to_pt( 150 ), mm_to_pt( 40 ), mm_to_pt( 5 ) )
  HPDF_Page_Stroke( page )
  out_text_rectangle( page, 158, 155, 198, 150, AllTrim( str( ( dbAlias )->summa, 16, 2 ) ), HPDF_TALIGN_RIGHT )

  HPDF_Page_SetFontAndSize( page, r_t, 10 ) // выбор шрифта из подключенных и его размер

  HPDF_Page_Rectangle( page, mm_to_pt( 160 ), mm_to_pt( 143 ), mm_to_pt( 40 ), mm_to_pt( 7 ) )
  HPDF_Page_Stroke( page )
  out_text( page, 132, 144, 'Итого без НДС:' )
  out_text_rectangle( page, 158, 149, 198, 144, AllTrim( str( ( dbAlias )->summa, 16, 2 ) ), HPDF_TALIGN_RIGHT )

  HPDF_Page_Rectangle( page, mm_to_pt( 160 ), mm_to_pt( 136 ), mm_to_pt( 40 ), mm_to_pt( 7 ) )
  HPDF_Page_Stroke( page )
  HPDF_Page_SetFontAndSize( page, r_tb, 10 ) // выбор шрифта из подключенных и его размер
  out_text( page, 132, 137, 'Всего к оплате:' )
  out_text_rectangle( page, 158, 141, 198, 137, AllTrim( str( ( dbAlias )->summa, 16, 2 ) ), HPDF_TALIGN_RIGHT )

  out_text_rectangle( page, 12, 130, 200, 140, 'Всего к оплате: ' + srub_kop( ( dbAlias )->Summa, .f. ), HPDF_TALIGN_LEFT )

  HPDF_Page_SetFontAndSize( page, r_t, 10 ) // выбор шрифта из подключенных и его размер
  out_text( page, 12, 108, 'Руководитель предприятия' )
  HPDF_Page_MoveTo( page, mm_to_pt( 60 ), mm_to_pt( 108 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 132 ), mm_to_pt( 108 ) )
  HPDF_Page_Stroke( page )
  out_text( page, 135, 108, '( ' + AllTrim( ( dbAlias )->ruk ) + ' )' )
  out_text( page, 12, 96, 'Главный бухгалтер' )
  HPDF_Page_MoveTo( page, mm_to_pt( 46 ), mm_to_pt( 96 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 132 ), mm_to_pt( 96 ) )
  HPDF_Page_Stroke( page )
  out_text( page, 135, 96, '( ' + AllTrim( ( dbAlias )->bux ) + ' )' )

  ( dbAlias )->( dbCloseArea() )

  IF HPDF_SaveToFile( pdf, cFileToSave ) != 0
    fError:add_string( 'HPDF_SaveToFile() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    func_error( 4, 'Ошибка создания печатной формы счета!' )
  ENDIF 
    
  HPDF_Free( pdf )
  fError := nil
    
  return nil