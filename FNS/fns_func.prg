#require 'hbhpdf'

#include 'common.ch'
#include 'hbhash.ch' 
#include 'harupdf.ch'
#include 'tfile.ch'
#include 'chip_mo.ch'

// 07.05.25
FUNCTION DesignSpravkaPDF( cFileToSave, hArr )

  Local detail_font_name, detail_font_nameBold
  Local detail_font_courier
  Local detail_font_eangnivc
  local aFonts := {}

  Local TTFArial := dir_fonts() + 'arial.ttf'
  Local TTFArialBold := dir_fonts() + 'arialbd.ttf'
  Local TTFCourier := dir_fonts() + 'cour.ttf'
  Local TTFEanGnivc := dir_fonts() + 'Eang000.ttf'

  LOCAL pdf, tFont
  local fl := .t.
  local fError, pdfReturn

  fError := tfiletext():new( cur_dir() + 'error_pdf.txt', , .t., , .t. ) 
  fError:width := 100
  
  IF ( pdf := HPDF_New() ) == NIL   // ᮧ����� pdf - ��ꥪ� 䠩��
    fError:add_string( strErrorPdf( pdf, 'HPDF_New()' ) )
    fError := nil
    func_error( 4, '��ࠢ�� ��� ��� �� ����� ���� ᮧ����!' )
    RETURN .f.
  ENDIF

  // ����㧨� �����
  if ( detail_font_name := HPDF_LoadTTFontFromFile ( pdf, TTFArial, HPDF_TRUE ) ) == NIL
    fError:add_string( strErrorPdf( pdf, 'HPDF_LoadTTFontFromFile() ARIAL' ) )
  endif
  fError:add_string( strErrorPdf( pdf, 'HPDF_LoadTTFontFromFile() ARIAL' ) )  // + detail_font_name )

  if ( detail_font_nameBold := HPDF_LoadTTFontFromFile ( pdf, TTFArialBold, HPDF_TRUE ) ) == NIL
    fError:add_string( strErrorPdf( pdf, 'HPDF_LoadTTFontFromFile() ARIAL Bold' ) )
  endif
  fError:add_string( strErrorPdf( pdf, 'HPDF_LoadTTFontFromFile() ARIAL Bold' ) ) // + detail_font_nameBold )

  if ( detail_font_courier := HPDF_LoadTTFontFromFile ( pdf, TTFCourier, HPDF_TRUE ) ) == NIL
    fError:add_string( strErrorPdf( pdf, 'HPDF_LoadTTFontFromFile() COURIER' ) )
  endif
  fError:add_string( strErrorPdf( pdf, 'HPDF_LoadTTFontFromFile() COURIER' ) ) // + detail_font_courier )

  if ( detail_font_eangnivc := HPDF_LoadTTFontFromFile ( pdf, TTFEanGnivc, HPDF_TRUE ) ) == NIL
    fError:add_string( strErrorPdf( pdf, 'HPDF_LoadTTFontFromFile() EANGNIVC' ) )
  endif
  fError:add_string( strErrorPdf( pdf, 'HPDF_LoadTTFontFromFile() EANGNIVC' ) ) // + detail_font_eangnivc )

  if ( tFont := HPDF_GetFont ( pdf, detail_font_name, 'CP1251' ) ) == NIL
    fError:add_string( strErrorPdf( pdf, 'HPDF_GetFont() ARIAL' ) )
  else
    AAdd( aFonts, tFont )
  endif
  if ( tFont := HPDF_GetFont ( pdf, detail_font_nameBold, 'CP1251' ) ) == NIL
    fError:add_string( strErrorPdf( pdf, 'HPDF_GetFont() ARIAL Bold' ) )
  else
    AAdd( aFonts, tFont )
  endif
  if ( tFont := HPDF_GetFont ( pdf, detail_font_courier, 'CP1251' ) ) == NIL
    fError:add_string( strErrorPdf( pdf, 'HPDF_GetFont() Courier' ) )
  else
    AAdd( aFonts, tFont )
  endif
  if ( tFont := HPDF_GetFont ( pdf, detail_font_eangnivc, 'CP1251' ) ) == NIL
    fError:add_string( strErrorPdf( pdf, 'HPDF_GetFont() EANGNIVC' ) )
  else
    AAdd( aFonts, tFont )
  endif

  /* ��⠭���� ०�� ᦠ�� */
  if ( pdfReturn := HPDF_SetCompressionMode( pdf, HPDF_COMP_ALL ) ) != HPDF_OK
    fError:add_string( strErrorPdf( pdf, 'HPDF_SetCompressionMode()' ) )
  endif

  if ( pdfReturn := HPDF_SetPageMode( pdf, HPDF_PAGE_MODE_USE_NONE ) ) != HPDF_OK
    fError:add_string( strErrorPdf( pdf, 'HPDF_SetPageMode()' ) )
  endif

  designPage1( pdf, hArr, aFonts, fError )

  if hArr[ 'attribut' ] == 0
    designPage2( pdf, hArr, aFonts, fError )
  endif

  IF HPDF_SaveToFile_Wrap( pdf, cFileToSave, '�ࠢ�� ��� ���', fError ) != 0
    fl := .f.
  ENDIF 

  HPDF_Free( pdf )
  fError := nil
  RETURN fl

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