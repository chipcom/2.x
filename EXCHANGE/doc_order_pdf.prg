#require 'hbhpdf'

#include 'harupdf.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 26.07.24
function out_text_rectangle( pg, rLEFT, rTOP, rRIGHT, rBOTTOM, sText, align )
  
  HPDF_Page_BeginText( pg )
  HPDF_Page_TextRect( pg, mm_to_pt( rLEFT ), mm_to_pt( rTOP ), mm_to_pt( rRIGHT ), mm_to_pt( rBOTTOM ), ;
    win_OEMToANSI( sText ), align, nil )
  HPDF_Page_EndText( pg )

  return nil

// 17.04.25
function print_pdf_order( cFileToSave )

  LOCAL pdf
  local fError, pdfReturn
  local page, c1 := 'CP1251'
  local fnt_arial, fnt_arial_bold, r_t, r_tb

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
//    Alert( 'шрифт не найден' )
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

  // шапка счета
  HPDF_Page_SetLineWidth( page, 0.5 )

  HPDF_Page_SetFontAndSize( page, r_tb, 11 ) // выбор шрифта из подключенных и его размер
  out_text_rectangle( page, 10, 290, 200, 284, 'Наименование организации', HPDF_TALIGN_LEFT )

  HPDF_Page_SetFontAndSize( page, r_t, 10 ) // выбор шрифта из подключенных и его размер
  out_text_rectangle( page, 10, 282, 200, 275, 'Адрес организации', HPDF_TALIGN_LEFT )

  HPDF_Page_Rectangle( page, mm_to_pt( 10 ), mm_to_pt( 210 ), mm_to_pt( 190 ), mm_to_pt( 40 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_MoveTo( page, mm_to_pt( 10 ), mm_to_pt( 230 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 200 ), mm_to_pt( 230 ) )
  HPDF_Page_Stroke( page )

  out_text_rectangle( page, 11, 249, 60, 244, 'ИНН:', HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 61, 249, 110, 244, 'КПП:', HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 11, 243, 110, 230, 'Поставщик:', HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 126, 235, 200, 230, '40700000000000000000', HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 126, 229, 200, 224, '046046046', HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 126, 223, 200, 218, '30100000000000000000', HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 11, 223, 110, 207, 'в Операционный офис "Волгоградский" АО "Альфа-банк" филиал Ростовский', HPDF_TALIGN_LEFT )

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
  out_text( page, 65, 182, 'СЧЕТ' )

  HPDF_Page_SetFontAndSize( page, r_t, 10 ) // выбор шрифта из подключенных и его размер
  out_text( page, 10, 165, 'Плательщик:' )
  out_text_rectangle( page, 35, 165, 150, 218, 'Административное структурное Капитал-МС', HPDF_TALIGN_LEFT )
  
  HPDF_Page_Rectangle( page, mm_to_pt( 10 ), mm_to_pt( 140 ), mm_to_pt( 190 ), mm_to_pt( 20 ) )
  HPDF_Page_Stroke( page )

  out_text( page, 12, 156, '№' )
  out_text_rectangle( page, 18, 160, 158, 155, 'Наименование услуг', HPDF_TALIGN_CENTER )
  out_text_rectangle( page, 158, 160, 200, 155, 'Сумма', HPDF_TALIGN_CENTER )
  out_text( page, 12, 151, '1' )
  out_text( page, 12, 143, '2' )

  out_text_rectangle( page, 18, 155, 158, 150, 'За медицинскую помощь оказанную.....', HPDF_TALIGN_LEFT )
  out_text_rectangle( page, 158, 155, 198, 150, '77 731.00', HPDF_TALIGN_RIGHT )

  HPDF_Page_MoveTo( page, mm_to_pt( 10 ), mm_to_pt( 155 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 200 ), mm_to_pt( 155 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_MoveTo( page, mm_to_pt( 10 ), mm_to_pt( 149 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 200 ), mm_to_pt( 149 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_Rectangle( page, mm_to_pt( 160 ), mm_to_pt( 132.5 ), mm_to_pt( 40 ), mm_to_pt( 7.5 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_MoveTo( page, mm_to_pt( 160 ), mm_to_pt( 140 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 160 ), mm_to_pt( 160 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_Rectangle( page, mm_to_pt( 160 ), mm_to_pt( 125 ), mm_to_pt( 40 ), mm_to_pt( 7.5 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_SetFontAndSize( page, r_t, 10 ) // выбор шрифта из подключенных и его размер
  out_text( page, 132, 135, 'Итого без НДС:' )
  out_text_rectangle( page, 158, 139, 198, 135, '77 731.00', HPDF_TALIGN_RIGHT )
  out_text( page, 132, 127, 'Всего к оплате:' )
  out_text_rectangle( page, 158, 131, 198, 127, '77 731.00', HPDF_TALIGN_RIGHT )

  out_text( page, 12, 108, 'Руководитель предприятия' )
  HPDF_Page_MoveTo( page, mm_to_pt( 60 ), mm_to_pt( 108 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 132 ), mm_to_pt( 108 ) )
  HPDF_Page_Stroke( page )
  out_text( page, 135, 108, '( Руководитель )' )
  out_text( page, 12, 96, 'Главный бухгалтер' )
  HPDF_Page_MoveTo( page, mm_to_pt( 46 ), mm_to_pt( 96 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 132 ), mm_to_pt( 96 ) )
  HPDF_Page_Stroke( page )
  out_text( page, 135, 96, '( Гл. бухгалтер )' )

  IF HPDF_SaveToFile( pdf, cFileToSave ) != 0
    fError:add_string( 'HPDF_SaveToFile() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    func_error( 4, 'Ошибка создания печатной формы счета!' )
  ENDIF 
    
  HPDF_Free( pdf )
  fError := nil
    
  return nil