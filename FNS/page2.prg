#require 'hbhpdf'

#include 'harupdf.ch'
#include 'chip_mo.ch'

// 07.05.25
function designPage2( pdf, hArr, aFonts, fError )

  local page
  local pdfError
  local old_set := __SetCentury( 'on' )

  Set Date GERMAN

  /* ������� ���� ��ꥪ� ��������. */
  if ( page := HPDF_AddPage( pdf ) ) == nil
    fError:add_string( strErrorPdf( pdf, 'HPDF_AddPage() (Page 2)' ) )
  endif

  if ( pdfError := HPDF_Page_SetSize( page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT ) ) != HPDF_OK
    fError:add_string( strErrorPdf( pdf, 'HPDF_Page_SetSize()' ) )
  endif

  if ( pdfError := HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL ], 11 ) ) != HPDF_OK
    fError:add_string( strErrorPdf( pdf, 'HPDF_Page_SetFontAndSize() (page 2)' ) )
  endif

  out_text( page, 58.5, 288, '���' )
  out_text( page, 58.5, 280, '���' )
  out_text( page, 114.5, 280, '���.' )
  //
  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL ], 9 )
// -----
  out_text( page, 5, 260, '����� 䨧��᪮�� ���, ���஬� ������� ����樭᪨� ��㣨 :' )
  out_text( page, 5, 254, '�������' )
  out_text( page, 5, 246, '���' )
  out_text( page, 5, 238, '����⢮' )

  out_text( page, 5, 229, '���' ) // �������� �������
  out_text( page, 98, 229, '��� ஦�����' )

  out_text( page, 5, 220, '�������� � ���㬥��, 㤮�⮢����饬 ��筮���:' )
  out_text( page, 5, 214, '��� ���� ���㬥��' )
  out_text( page, 77, 214, '���� � �����' )
  out_text( page, 5, 205, '��� �뤠�' )

  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL ], 6 )

  out_text( page, 12, 22, '1' )
  out_text( page, 12, 19, '2' )
  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_ARIAL ], 8 )
  out_text( page, 14, 20, '����� �����������, �᫨ ���������⥫�騪 � ��樥�� �� ����� ����� ��殬.' )
  out_text( page, 14, 17, '��� 㪠�뢠���� �� ����稨.' )
  out_text_center( page, 10, '���⮢�୮��� � ������� ᢥ�����, 㪠������ �� ������ ��࠭��, ���⢥ত��:' )
  out_text( page, 93, 5, '(�������)' )
  out_text( page, 162, 5, '(���)' )

  out_kvadr( page, 0, 290 )
  out_kvadr( page, 40, 290 )
  out_kvadr( page, 0, 7 )
  out_kvadr( page, 195, 7 )

  HPDF_Page_SetFontAndSize( page, aFonts[ 4 ], 43 )
  out_text( page, 7, 284, create_string_EanGnivc( '26901022' ) )

  // ������塞 ����
  HPDF_Page_SetFontAndSize( page, aFonts[ FONT_COURIER ], 16 )

  fill_INN( page, hArr[ 'inn' ], hArr[ 'kpp' ], 2 )

  out_format( page, 24.5, 254, hArr[ 'famPacient' ] )
  out_format( page, 24.5, 246, hArr[ 'imPacient' ] )
  out_format( page, 24.5, 238, hArr[ 'otPacient' ] )

  if ! empty( hArr[ 'innPacient' ] )
    out_format( page, 24.5, 229, hArr[ 'innPacient' ] )
  endif

  out_format( page, 128, 229, DToC( hArr[ 'dobPacient' ] ) )

  if empty( hArr[ 'innPacient' ] )
    out_format( page, 38, 214, str( hArr[ 'vid_d_pacient' ], 2 ) )
    out_format( page, 104, 214, alltrim( hArr[ 'ser_pacient' ] ) )
    out_format( page, 38, 205, DToC( hArr[ 'dVydachPacient' ] ) )
  endif

  __SetCentury( old_set )
  return nil