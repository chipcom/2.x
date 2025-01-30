#require 'hbhpdf'

#include 'common.ch'
#include 'hbhash.ch' 
#include 'harupdf.ch'
#include 'tfile.ch'
#include 'chip_mo.ch'

// 30.01.25
FUNCTION DesignSpravkaPDF( cFileToSave, hArr )

  Local detail_font_name, detail_font_nameBold
  Local detail_font_courier
  Local detail_font_eangnivc
  local aFonts := {}

  Local TTFArial := dir_fonts() + 'arial.ttf'
  Local TTFArialBold := dir_fonts() + 'arialbd.ttf'
  Local TTFCourier := dir_fonts() + 'cour.ttf'
  Local TTFEanGnivc := dir_fonts() + 'Eang000.ttf'

  LOCAL pdf
  local fl := .t.
  local fError, pdfReturn

  fError := tfiletext():new( cur_dir() + 'error_pdf.txt', , .t., , .t. ) 
  fError:width := 100
  
  IF ( pdf := HPDF_New() ) == NIL   // создание pdf - объекта файла
    fError:add_string( 'HPDF_New() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    fError := nil
    func_error( 4, 'Справка для ФНС не может быть создана!' )
    RETURN .f.
  ENDIF

  // загрузим шрифты
  detail_font_name := HPDF_LoadTTFontFromFile ( pdf, TTFArial, HPDF_TRUE )
  detail_font_nameBold := HPDF_LoadTTFontFromFile ( pdf, TTFArialBold, HPDF_TRUE )
  detail_font_courier := HPDF_LoadTTFontFromFile ( pdf, TTFCourier, HPDF_TRUE )
  detail_font_eangnivc := HPDF_LoadTTFontFromFile ( pdf, TTFEanGnivc, HPDF_TRUE )
  AAdd( aFonts, HPDF_GetFont ( pdf, detail_font_name, 'CP1251' ) )
  AAdd( aFonts, HPDF_GetFont ( pdf, detail_font_nameBold, 'CP1251' ) )
  AAdd( aFonts, HPDF_GetFont ( pdf, detail_font_courier, 'CP1251' ) )
  AAdd( aFonts, HPDF_GetFont ( pdf, detail_font_eangnivc, 'CP1251' ) )

  /* установим режим сжатия */
  if ( pdfReturn := HPDF_SetCompressionMode( pdf, HPDF_COMP_ALL ) ) != HPDF_OK
    fError:add_string( 'HPDF_SetCompressionMode() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  if ( pdfReturn := HPDF_SetPageMode( pdf, HPDF_PAGE_MODE_USE_OUTLINE ) ) != HPDF_OK
    fError:add_string( 'HPDF_SetPageMode() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif

  designPage1( pdf, hArr, aFonts, fError )

  if hArr[ 'attribut' ] == 0
    designPage2( pdf, hArr, aFonts, fError )
  endif

  IF HPDF_SaveToFile( pdf, cFileToSave ) != 0
//    func_error( 4, '0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    fError:add_string( 'HPDF_SaveToFile() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
    func_error( 4, 'Ошибка создания печатной формы справки для ФНС!' )
    fl := .f.
  ENDIF 

  HPDF_Free( pdf )
  fError := nil

  RETURN fl //  hb_FileExists( cFileToSave )

// 27.07.24
function mm_to_pt( x_y )

   local t := x_y / 25.4

   t := t * 72
   return t

// 26.07.24
function out_text( pg, x, y, sText )

   HPDF_Page_BeginText( pg )
   HPDF_Page_TextOut( pg, mm_to_pt( x ), mm_to_pt( y ), win_OEMToANSI( sText ) )
   HPDF_Page_EndText( pg )
 
   return nil

// 26.07.24
function out_text_center( pg, y, sText )

  local tw, width

  sText := win_OEMToANSI ( sText )
  width  := HPDF_Page_GetWidth( pg )
  tw := HPDF_Page_TextWidth( pg, sText )
  HPDF_Page_BeginText( pg )
  HPDF_Page_TextOut( pg, ( width - tw ) / 2, mm_to_pt( y ), sText )
  HPDF_Page_EndText( pg )
 
  return nil

// 27.07.24
function out_kvadr( pg, x, y )

   HPDF_Page_SetDash( pg, , 0, 0 )

   HPDF_Page_SetLineWidth( pg, 15 )

   /* Line Cap Style */
   HPDF_Page_SetLineCap( pg, HPDF_BUTT_END )

   HPDF_Page_MoveTo( pg, mm_to_pt( x ) + 15, mm_to_pt( y ) ) //- 25 )
   HPDF_Page_LineTo( pg, mm_to_pt( x ) + 30, mm_to_pt( y ) ) //- 25 )
   HPDF_Page_Stroke( pg )

   return nil

// 29.07.24
function fill_INN( pg, inn, kpp, num )

  local i, tStr

  inn := fill_string( inn, 12 )
  for i := 1 to len( inn )
   out_text( pg, 69 + ( i - 1 ) * 5, 288, substr( inn, i, 1 ) ) //58
  next
  for i := 1 to len( kpp )
   out_text( pg, 69 + ( i - 1 ) * 5, 280, substr( kpp, i, 1 ) ) //58
  next
  tStr := iif( num == 1 , '001', '002' )
  for i := 1 to len( tStr )
   out_text( pg, 124 + ( i - 1 ) * 5, 280, substr( tStr, i, 1 ) ) //58
  next

  return nil

// 29.07.24
function out_format( pg, x, y, sText )

  local i

  for i := 1 to len( sText )
    out_text( pg, x + ( i - 1 ) * 5, y, substr( sText, i, 1 ) )
  next

  return nil

// 30.07.24
function transform_sum( sum )

  local ret := ''
  local cel := int( sum )

  ret := alltrim( transform( cel, '@B' ) )
  if len( ret ) < 13
    ret := ret + replicate( '-', 13 - len( ret ) ) + '.'
  endif
  ret := ret + transform( ( sum - cel ) * 100, '@L 99' )

  return ret

// 30.07.24
function transform_int( num, width )

  return fill_string( alltrim( str( num ) ), width )

// 30.07.24
function fill_string( str, width )

  if len( str ) < width
    str += replicate( '-', width - len( str ) )
  endif
  return str

// 26.11.24
function create_string_EanGnivc( str )

  local i, rez := '', charCoding := "#$%&'()*+,"
  local leftProtectTemplate := '!'
  local middleProtectTemplate := '-'
  local rightProtectTemplate := '!'
  local codingLeftPart := {}
  local codingRightPart := 'RRRRRR'
  local kolSymbolGroup, symbolsTypeCoding
  local indexTypeCoding
  local leftPartCode := ''
  local rightPartCode := ''
  local symbolTypeCode := hb_hash()

  if HB_ISSTRING( str ) .and. IsDigit( str )
    rez := str
  endif

  hb_hSet( symbolTypeCode, 'L', '0123456789' )
  hb_hSet( symbolTypeCode, 'G', 'ABCDEFGHIJ' )
  hb_hSet( symbolTypeCode, 'R', 'abcdefghij' )

  AAdd( codingLeftPart, 'LLLLLL')
  AAdd( codingLeftPart, 'LLGLGG')
  AAdd( codingLeftPart, 'LLGGLG')
  AAdd( codingLeftPart, 'LLGGGL')
  AAdd( codingLeftPart, 'LGLLGG')
  AAdd( codingLeftPart, 'LGGLLG')
  AAdd( codingLeftPart, 'LGGGLL')
  AAdd( codingLeftPart, 'LGLGLG')
  AAdd( codingLeftPart, 'LGLGGL')
  AAdd( codingLeftPart, 'LGGLGL')


  if len( str ) == 13
    kolSymbolGroup := 6
  elseif len( str ) == 8
    kolSymbolGroup := 4
    symbolsTypeCoding := ''
    str := '0' + str
  else
    return ''
  endif

  indexTypeCoding = val( left( str, 1 ) )

  for i := 1 to kolSymbolGroup
    leftPartCode = leftPartCode ;
      + substr( symbolTypeCode[ substr( codingLeftPart[ indexTypeCoding + 1 ], i, 1 ) ] ;
              , val( substr( str, ( i + 1 ), 1 ) ) + 1 ,1 )
    rightPartCode = rightPartCode ;
      + substr( symbolTypeCode[ substr( codingRightPart, i, 1 ) ] ;
              , val( substr( str, ( i + kolSymbolGroup + 1 ), 1 ) ) + 1, 1 )
  next

  rez := ''  + substr( charCoding, indexTypeCoding + 1, 1 ) ;
      + leftProtectTemplate ;
      + leftPartCode ;
      + middleProtectTemplate ;
      + rightPartCode ;
      + rightProtectTemplate

  return rez