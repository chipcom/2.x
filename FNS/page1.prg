#require 'hbhpdf'

#include 'harupdf.ch'
#include 'chip_mo.ch'

// 30.01.25
function designPage1( pdf, hArr, aFonts, fError )

  local page, i, j, t_arr := {}
  local pdfError
  local old_set := __SetCentury( 'on' )

  /* добавим новый объект СТРАНИЦА. */
  if ( page := HPDF_AddPage( pdf ) ) == nil
    fError:add_string( 'HPDF_AddPage() (Page 1) - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  if ( pdfError := HPDF_Page_SetSize( page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT ) ) != HPDF_OK
    fError:add_string( 'HPDF_Page_SetSize() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  if ( pdfError := HPDF_Page_SetLineWidth( page, 0.5 ) ) != HPDF_OK
    fError:add_string( 'HPDF_Page_SetLineWidth() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  if ( pdfError := HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL ], 8 ) ) != HPDF_OK
    fError:add_string( 'HPDF_Page_SetFontAndSize() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  out_text( page, 168, 291, 'Приложение № 1' )
  out_text( page, 168, 287, 'к приказу ФНС России' )
  out_text( page, 168, 283, 'от "08" ноября 2023 г.' )
  out_text( page, 168, 279, '№ ЕА-7-11/824@' )
  //

//  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_EANGNIVC ], 10 )
//  out_text( page, 25.5, 270, create_string_EanGnivc( '26901015' ) )

  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL ], 11 )

  out_text( page, 58.5, 288, 'ИНН' )
  out_text( page, 58.5, 280, 'КПП' )
  out_text( page, 114.5, 280, 'Стр.' )
  //
  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL_BOLD ], 9 )
  out_text( page, 13, 269, 'Форма по КНД 1151156' )
  //
  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL_BOLD ], 11 )
  out_text_center( page, 266, 'Справка' )

  out_text_center( page, 261, 'об оплате медицинских услуг для представления' )

  out_text_center( page, 256, 'в налоговый орган' )
  //
  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL ], 9 )
  out_text( page, 5, 249, 'Номер справки' )
  out_text( page, 98, 249, 'Номер корректировки' )
  out_text( page, 157, 249, 'Отчетный год' )

  out_text( page, 5, 239, 'Данные медицинской организации / индивидуального предпринимателя, осуществляющего медицинскую деятельность:' )
// -----
  out_text( page, 5, 195, 'Данные физического лица (его супруга/супруги), оплатившего медицинские услуги (далее - налогоплательщик):' )
  out_text( page, 5, 189, 'Фамилия' )
  out_text( page, 5, 180, 'Имя' )
  out_text( page, 5, 171, 'Отчество' )

  out_text( page, 5, 162, 'ИНН' ) // добавить апостроф
  out_text( page, 98, 162, 'Дата рождения' )

  out_text( page, 5, 153, 'Сведения о документе, удостоверяющем личность:' )
  out_text( page, 5, 147, 'Код вида документа' )
  out_text( page, 77, 147, 'Серия и номер' )
  out_text( page, 5, 138, 'Дата выдачи' )

  out_text( page, 5, 129, 'Налогоплательщик и пациент являются одним лицом' )
  out_text( page, 122, 131, '0 - нет' )
  out_text( page, 122, 127.5, '1 - да' )

  out_text( page, 5, 118, 'Сумма расходов на оказанные медицинские услуги по коду услуги "1"' )
  out_text( page, 5, 109, 'Сумма расходов на оказанные медицинские услуги по коду услуги "2"' )

  /* Рисуем линии. */
  HPDF_Page_SetLineWidth( page, 0 )
  HPDF_Page_MoveTo( page, mm_to_pt( 5 ), mm_to_pt( 103 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 201 ), mm_to_pt( 103 ) )
  HPDF_Page_Stroke( page )

  HPDF_Page_MoveTo( page, mm_to_pt( 108 ), mm_to_pt( 103 ) )
  HPDF_Page_LineTo( page, mm_to_pt( 108 ), mm_to_pt( 22 ) )
  HPDF_Page_Stroke( page )

  out_text( page, 5, 55, 'Подпись' )
  out_text( page, 46, 55, 'Дата' )
  out_text( page, 5, 47, 'Справка составлена на' )
  out_text( page, 60, 47, 'страницах' )

  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL_BOLD ], 9 )
  out_text( page, 20, 99, 'Достоверность и полноту сведений, указанных' )
  out_text( page, 140, 99, 'Зона QR-кода' )
  out_text( page, 30, 95, 'в настоящей справке, подтверждаю:' )

  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL ], 7 )
  out_text( page, 40, 65, '(Фамилия, имя, отчество  )' )

  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL ], 6 )
  out_text( page, 6, 17, '1' )
  out_text( page, 6, 12, '2' )

  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL ], 7 )
  out_text( page, 126, 203, '1' )
  out_text( page, 68.5, 66, '1' )
  out_text( page, 12, 164, '2' )
  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL ], 8 )
  out_text_center( page, 202, '(наименование медицинской оргаганизации / фамилия, имя, отчество  индивидуального предпринимателя)' )
  out_text( page, 8, 15, 'Отчество указывается при наличии (относится ко всем листам документа).' )
  out_text( page, 8, 10, 'ИНН указывается при наличии.' )

  out_kvadr( page, 0, 290 )
  out_kvadr( page, 40, 290 )
  out_kvadr( page, 0, 7 )
  out_kvadr( page, 195, 7 )

  HPDF_Page_SetFontAndSize( page, aFonts[ 4 ], 43 )
  out_text( page, 7, 284, create_string_EanGnivc( '26901015' ) )

  // заполняем поля
  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_COURIER ], 16 )

  fill_INN( page, hArr[ 'inn' ], hArr[ 'kpp' ], 1 )

  out_format( page, 29, 249, transform_int( hArr[ 'num_spr' ], 12 ) )
 
//  if hArr[ 'annul' ] == 1 // проверка на аанулированность справки
//    out_format( page, 134, 249, transform_int( 999, 3 ) )
//  else
    out_format( page, 134, 249, transform_int( hArr[ 'cor' ], 3 ) )
//  endif

  out_format( page, 184, 249, str( hArr[ 'nYear' ], 4 ) )

  if empty( hArr[ 'name' ] )
    perenos( t_arr, hArr[ 'full_name' ], 40, '' )
  else
    perenos( t_arr, hArr[ 'name' ], 40, '' )
  endif
  for j := 1 to len( t_arr )
    out_format( page, 5, 231 - ( j - 1) * 8, t_arr[ j ] )
  next

  out_format( page, 24.5, 188, hArr[ 'fam' ] )
  out_format( page, 24.5, 179.5, hArr[ 'im' ] )
  out_format( page, 24.5, 171, hArr[ 'ot' ] )

  if ! empty( hArr[ 'inn_plat' ] )
    out_format( page, 24.5, 161.5, hArr[ 'inn_plat' ] )
  endif

  out_format( page, 128, 161.5, DToC( hArr[ 'dob' ] ) )

  if empty( hArr[ 'inn_plat' ] )
    out_format( page, 38, 146.5, str( hArr[ 'vid_d' ], 2 ) )
    out_format( page, 104, 146, alltrim( hArr[ 'ser' ] ) ) // + ' ' + alltrim( hArr[ 'nomer' ] ) )
    out_format( page, 38, 137.5, DToC( hArr[ 'dVydach' ] ) )
  endif

  out_format( page, 113.5, 128, str( hArr[ 'attribut' ], 1 ) )

  out_format( page, 113.5, 117, transform_sum( hArr[ 'sum1' ] ) )
  out_format( page, 113.5, 108, transform_sum( hArr[ 'sum2' ] ) )

  perenos( t_arr, hArr[ 'fioSost' ], 20 )
  for j := 1 to len( t_arr )
    out_format( page, 5, 88 - ( j - 1) * 8, t_arr[ j ] )
  next

  out_format( page, 55, 55, DToC( hArr[ 'dSost' ] ) )

//  out_format( page, 44, 47, str( hArr[ 'kolStr' ], 3 ) )
  out_format( page, 44, 47, str( iif( hArr[ 'attribut' ] == 1, 1, 2), 3 ) )

  __SetCentury( old_set )

  return nil