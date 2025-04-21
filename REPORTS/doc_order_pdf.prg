#require 'hbhpdf'

#include 'harupdf.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 21.04.25
function text_header( reg )

  local arr := {}

  if reg != 1 .and. reg != 2
    return arr
  endif
  // { техт, щирина столбца}
  AAdd( arr, { iif( reg == 1, '№ позиц ии реест ра', '1' ), 8 } )
  AAdd( arr, { iif( reg == 1, 'Фамилия, имя, отчество (при наличии)', '2' ), 24 } )
  AAdd( arr, { iif( reg == 1, 'Пол', '3' ), 6 } )
  AAdd( arr, { iif( reg == 1, 'Дата рождения', '4' ), 13 } )
  AAdd( arr, { iif( reg == 1, 'Место рождения', '5' ), 21 } )
  AAdd( arr, { iif( reg == 1, 'Данные документа удостоверяющ его личность', '6' ), 18 } )
  AAdd( arr, { iif( reg == 1, 'Место жительства', '7' ), 23 } )
  AAdd( arr, { iif( reg == 1, 'Место регистрации', '8' ), 23 } )
  AAdd( arr, { iif( reg == 1, 'СНИЛС (при наличии)', '9' ), 12 } )
  AAdd( arr, { iif( reg == 1, '№ полиса обязательно го медицинског о страхования', '10' ), 16 } )
  AAdd( arr, { iif( reg == 1, 'Вид оказан ной медиц инской помощ и (код)', '11' ), 9 } )
  AAdd( arr, { iif( reg == 1, 'Диагноз в соответ ствии с МКБ-10', '12' ), 10 } )
  AAdd( arr, { iif( reg == 1, 'Дата начала и дата окончания лечения', '13' ), 13 } )
  AAdd( arr, { iif( reg == 1, 'Объемы оказанн ой медици нской помощи', '14' ), 10 } )
  AAdd( arr, { iif( reg == 1, 'Профиль оказанной медицинск ой помощи (код)', '15' ), 15 } )
  AAdd( arr, { iif( reg == 1, 'Специальн ость медицинско го работника, оказавшего медицинску ю помощь (код)', '16' ), 15 } )
  AAdd( arr, { iif( reg == 1, 'Тариф на оплату медицинск ой помощи, оказанной застрахов анному лицу', '17' ), 14 } )
  AAdd( arr, { iif( reg == 1, 'Стоимость оказанной медицинской помощи', '18' ), 17 } )
  AAdd( arr, { iif( reg == 1, 'Результ ат обраще ния за медици нской помощь ю (код)', '19' ), 10 } )
  return arr

// 21.04.25
function pdf_header_reestr( page, nX, nY, nHeight, aText )

  // Вывод шапки таблицы с левого нижнего угла nX, nY по указанной высоте nHeght.
  
  local textLeading, err
  local row

  textLeading := HPDF_Page_GetTextLeading( page )
  HPDF_Page_SetTextLeading( page, 9.0 ) // по умолчанию 15.74
  for each row in aText
    err := out_text_in_rectangle( page, row[ 1 ], nX, nY, row[ 2 ], nHeight, HPDF_TALIGN_CENTER )
    nX += row[ 2 ]
  next
  HPDF_Page_SetTextLeading( page, textLeading )
  return nil

// 21.04.25
function print_pdf_reestr( cFileToSave )

  LOCAL pdf
  local fError, pdfReturn
  local page, c1 := 'CP1251', sText, sTextReestr
  local fnt_arial, fnt_arial_bold, fnt_arial_italic, r_t, r_tb, r_ti
  local dbName := '_titl.dbf', dbAlias := 'FRT', dbNameDT := '_data.dbf', dbAliasDT := 'DT'
  local nPatients, nCurrent
  local iPage, q1
  local curX

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

  dbUseArea( .t., , cur_dir() + dbName, dbAlias, .t., .f. )
  ( dbAlias )->( dbGoto( 1 ) )
  dbUseArea( .t., , cur_dir() + dbNameDT, dbAliasDT, .t., .f. )
  nPatient := ( dbAliasDT )->( LastRec() )
  nCurrent := 0

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
    sTextReestr := 'РЕЕСТР СЧЕТА № ' + AllTrim( ( dbAlias )->nschet ) + ' от ' + ( dbAlias )->dschet
    if q1 == 1
      HPDF_Page_SetFontAndSize( page, r_t, 10 ) // выбор шрифта из подключенных и его размер
      out_text_rectangle( page, 12, 200, 282, 195, sTextReestr, HPDF_TALIGN_CENTER )
      sText := AllTrim( ( dbAlias )->name ) + ', ОГРН ' + AllTrim( ( dbAlias )->ogrn )
      out_text_rectangle( page, 12, 195, 282, 190, sText, HPDF_TALIGN_CENTER )
      sText := 'за период с ' + AllTrim( ( dbAlias )->date_begin ) + ' по ' + AllTrim( ( dbAlias )->date_end )
      out_text_rectangle( page, 12, 190, 282, 185, sText, HPDF_TALIGN_CENTER )
    
      sText := 'на оплату медицинской помощи, оказанной застрахованным лицам, в ' + AllTrim( ( dbAlias )->plat )
      out_text_rectangle( page, 12, 185, 282, 175, sText, HPDF_TALIGN_CENTER )

      HPDF_Page_SetFontAndSize( page, r_t, 7 ) // выбор шрифта из подключенных и его размер
      pdf_header_reestr( page, 12, 135, 30, text_header( 1 ) )
      pdf_header_reestr( page, 12, 130, 5, text_header( 2 ) )
    else
      HPDF_Page_SetFontAndSize( page, r_ti, 7 ) // выбор шрифта из подключенных и его размер
      out_text_rectangle( page, 12, 205, 290, 200, sTextReestr + ' стр.' + AllTrim( str( q1, 4 ) ), HPDF_TALIGN_RIGHT )
      HPDF_Page_SetFontAndSize( page, r_t, 7 ) // выбор шрифта из подключенных и его размер
      pdf_header_reestr( page, 12, 195, 5, text_header( 2 ) )
    endif

    curX := HPDF_Page_GetCurrentTextPos( page )
altd()
  next

  ( dbAlias )->( dbCloseArea() )
  ( dbAliasDT )->( dbCloseArea() )

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