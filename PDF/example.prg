/*
example.prg
*/

#require "hbhpdf"

#include 'harupdf.ch'

#define PAGE_WIDTH   420
#define PAGE_HEIGHT  400
#define CELL_WIDTH   20
#define CELL_HEIGHT  20
#define CELL_HEADER  10

Procedure Main()

  Local TTName := "lucon.ttf"
  Local embed := HPDF_TRUE
  Local detail_font_name, def_font3 //, def_font1, def_font2
  // Local w, h
  Local atxt := {}, page, i, a, b
  Local pdf := HPDF_New()
  Local s1 := "012345679 123456789 123456789 123456789 123456789 123456789 123456789 123456789 "

  atxt := { ;
    Replicate( "- ", 40 ) ;
    }

  For i = 1 To 60
    AAdd( atxt, s1 )
  Next i

  detail_font_name := HPDF_LoadTTFontFromFile ( pdf, TTName, embed )

  HPDF_SetCompressionMode( pdf, HPDF_COMP_ALL )


  HPDF_Page_SetSize( pdf, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT )


  HPDF_SetPageMode( pdf, HPDF_PAGE_MODE_USE_OUTLINE )
  page := HPDF_AddPage( pdf )

  HPDF_Page_SetWidth( page, PAGE_WIDTH )
  HPDF_Page_SetHeight( page, 297 )

  // w := HPDF_Page_GetWidth( page )
  // h := HPDF_Page_GetHeight( page )



  HPDF_Page_SetLineWidth( page, 0.5 )
  // 595x841


  def_font3 := HPDF_GetFont ( pdf, detail_font_name, "CP1251" )
  // def_font1 := HPDF_GetFont( pdf, "Courier", "CP1251" )
  // def_font2 := HPDF_GetFont( pdf, "Times-Bold", "WinAnsiEncoding" )
  HPDF_Page_BeginText( page )
  // 595x841

  // HPDF_Page_SetFontAndSize( page, def_font2, 10 )
  HPDF_Page_SetFontAndSize( page, def_font3, 12 )
  a = 20
  b = 800
  For i = 1 To Len( atxt )
    texto( page, a, b - 12 * i, atxt )
  Next i


  HPDF_Page_EndText( page )

  HPDF_SaveToFile( pdf, 'test.pdf' )
  HPDF_Free( pdf )

  Return


// //////////////////////////////////////////////////////////////////////////
Static Function texto( page, col, lin, texto, fim, direita )

  Local tw

  direita := if( direita = NIL, .f., direita )
  If fim = NIL
    col += 2
  Elseif ! direita
    tw := HPDF_Page_TextWidth( page, texto )
    col += ( ( fim - col ) / 2 ) - ( tw / 2 )
  Endif
  If direita
    tw := HPDF_Page_TextWidth( page, texto )
    col -= tw + 4
  Endif
  HPDF_Page_TextOut( page, col, lin, texto )

  Return Nil
