#include 'hbclass.ch'
#include 'property.ch'
#include 'common.ch'

// класс TProgressBar
CREATE CLASS TProgressBar
	VISIBLE:

		METHOD new( nRow, nColumnMin, nColumnMax, nValueMin, nValueMax )
    METHOD Update( nStep )
    METHOD Display()
    METHOD Destroy()

	PROTECTED:
		DATA FDisplay 		INIT .f.
		DATA FRow  		    INIT 0
		DATA FColumnMin	  INIT 0
		DATA FColumnMax 	INIT 0
		DATA FValueMin	  INIT 0
		DATA FValueMax   	INIT 0
    DATA FStep        INIT 0
    DATA FCurrent     INIT 0
    DATA FScreen
//		DATA FDeleted	INIT .f.
		
ENDCLASS

METHOD New( nRow, nColumnMin, nColumnMax, nValueMin, nValueMax )	CLASS TProgressBar

	::FRow      			:= hb_DefaultValue( nRow, 0 )
	::FColumnMin			:= hb_DefaultValue( nColumnMin, 0 )
	::FColumnMax			:= hb_DefaultValue( nColumnMax, 80 ) - 1 
	::FValueMin			  := hb_DefaultValue( nValueMin, 0 )
	::FValueMax			  := hb_DefaultValue( nValueMax, 0 )
  ::FStep           := int( ( nValueMax - nValueMin ) / ( nColumnMax - nColumnMin - 2 ) )
  ::FCurrent        := nColumnMin + 1
	return self

METHOD PROCEDURE Display( )	CLASS TProgressBar

  ::FScreen := save_box( ::FRow, ::FColumnMin, ::FRow, ::FColumnMax )
  ::FScreen := .t.
  @ ::FRow, ::FColumnMin SAY '['
  @ ::FRow, ::FColumnMax SAY ']'
  return

METHOD PROCEDURE TProgressBar:Update( nStep )

  If nStep % ::FStep == 0
    @ ::FRow, ::FCurrent++ SAY '='
  endif
  return

METHOD PROCEDURE TProgressBar:Destroy()

  rest_box( ::FScreen )
  return
