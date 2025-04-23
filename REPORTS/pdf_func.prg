#require 'hbhpdf'

#include 'harupdf.ch'

// 23.04.25
function new_page( pdf, fError )

  local page, pdfReturn

  /* добавим новый объект СТРАНИЦА. */
  if ( page := HPDF_AddPage( pdf ) ) == nil
    fError:add_string( 'HPDF_AddPage() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif
  if ( pdfReturn := HPDF_Page_SetSize( page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_LANDSCAPE ) ) != HPDF_OK
    fError:add_string( 'HPDF_Page_SetSize() - 0x' + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf ) )
  endif
  return page

// 27.07.24
function mm_to_pt( x_y )

  local t := x_y / 25.4

  t := t * 72
  return t

// 21.04.25
function out_text_in_rectangle( pg, sText, nX, nY, nWidth, nHeight, align )

  // Рисование прямоугольника с левого нижнего угла nX nY по указанной ширине/высоте nW nH.
  // После указатель устанавливается на nX nY. И вывод текста

  local err

  if ( err := HPDF_Page_Rectangle( pg, mm_to_pt( nX ), mm_to_pt( nY ), mm_to_pt( nWidth ), mm_to_pt( nHeight ) ) ) != HPDF_OK
    return err
  endif
    
  if ( err := HPDF_Page_Stroke( pg ) ) != HPDF_OK
    return err
  endif

  err := HPDF_Page_BeginText( pg )
  err := HPDF_Page_TextRect( pg, mm_to_pt( nX ), mm_to_pt( nY + nHeight ), mm_to_pt( nX + nWidth ), mm_to_pt( nY - nHeight ), ;
    win_OEMToANSI( sText ), align )
  err := HPDF_Page_EndText( pg )

  return err

// 20.04.25
function out_text_rectangle( pg, rLEFT, rTOP, rRIGHT, rBOTTOM, sText, align )

  local err

  err := HPDF_Page_BeginText( pg )
  err := HPDF_Page_TextRect( pg, mm_to_pt( rLEFT ), mm_to_pt( rTOP ), mm_to_pt( rRIGHT ), mm_to_pt( rBOTTOM ), ;
    win_OEMToANSI( sText ), align, nil )
  err := HPDF_Page_EndText( pg )
  return err

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

