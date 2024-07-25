#require "hbhpdf"

//
// 25.07.24
PROCEDURE Main( cFileToSave )

   CLS

   IF Empty( cFileToSave )
      cFileToSave := 'spravka.pdf'
   ENDIF

   IF DesignSpravkaPDF( cFileToSave )
      Alert( 'PDF файл <' + cFileToSave + '> создан!' )
   ELSE
      Alert( 'Возникли проблемы апи создании PDF!' )
   ENDIF

   RETURN

// 25.07.24
FUNCTION DesignSpravkaPDF( cFileToSave )

  local page, height, width
  LOCAL pdf := HPDF_New()

  IF pdf == NIL
     Alert( 'PDF не может быть создан!' )
     RETURN NIL
  ENDIF

  /* установим режим сжатия */
  HPDF_SetCompressionMode( pdf, HPDF_COMP_ALL )


  /* добавим новый объект СТРАНИЦА. */
  page := HPDF_AddPage( pdf )

  HPDF_Page_SetSize( page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT )

  height := HPDF_Page_GetHeight( page )
  width  := HPDF_Page_GetWidth( page )
  ?height
  ?
  ?width

  IF HPDF_SaveToFile( pdf, cFileToSave ) != 0
    ? "0x" + hb_NumToHex( HPDF_GetError( pdf ), 4 ), hb_HPDF_GetErrorString( HPDF_GetError( pdf ) ), HPDF_GetErrorDetail( pdf )
  ENDIF

  HPDF_Free( pdf )

  RETURN hb_FileExists( cFileToSave )
