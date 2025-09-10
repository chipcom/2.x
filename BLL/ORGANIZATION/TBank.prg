#include 'hbclass.ch'
#include 'property.ch'

// класс описывающий банковский счет, не привязан к конкретному файлу БД
CREATE CLASS TBank
	VISIBLE:
		PROPERTY Name READ GetName WRITE SetName VISIBLE			// Наименование банка
		PROPERTY Name1251 READ GetName1251						// Наименование банка в кодировке Win1251
		PROPERTY BIK READ GetBIK WRITE SetBIK VISIBLE			// БИК банка
		PROPERTY RSchet READ GetRSchet WRITE SetRSchet VISIBLE	// Расчетный счет в банке
		PROPERTY KSchet READ GetKSchet WRITE SetKSchet VISIBLE	// Коореспондентский счет банка
	
		METHOD New( cName, cBIK, cR_schet, cK_schet )
		METHOD forJSON
	HIDDEN:
		DATA FName
		DATA FAccount
		DATA FAccountCor
		DATA FBIK
		
		METHOD	GetName
		METHOD	SetName( cText )
		METHOD	GetName1251
		METHOD	GetBIK
		METHOD	SetBIK( cText )
		METHOD	GetRSchet
		METHOD	SetRSchet( cText )
		METHOD	GetKSchet
		METHOD	SetKSchet( cText )
		
		METHOD	transformText( cText, nChar )
ENDCLASS
					
METHOD function forJSON()							CLASS TBank
	
	local hItem

	hItem := { => }
	hb_HSet( hItem, 'Name', alltrim( ::Name ) )
	hb_HSet( hItem, 'BIK', alltrim( ::BIK ) )
	hb_HSet( hItem, 'Account', alltrim( ::RSchet ) )
	hb_HSet( hItem, 'KorAccount', alltrim( ::KSchet ) )
	return hItem
					
METHOD New( cName, cR_schet, cK_schet, cBIK )	CLASS TBank
	
	::FName := ::transformText( cName, 100 )
	::FBIK := ::transformText( cBIK, 10 )
	::FAccount := ::transformText( cR_schet, 20 )
	::FAccountCor := ::transformText( cK_schet, 20 )
	return self
	
METHOD Function GetName()							CLASS TBank
	return ::FName

METHOD PROCEDURE SetName( cText )				CLASS TBank
	
	::FName := ::transformText( cText, 100 )
	return
	
METHOD Function GetName1251()						CLASS TBank
	return win_OEMToANSI( ::FName )

METHOD Function GetBIK()							CLASS TBank
	return ::FBIK

METHOD PROCEDURE SetBIK( cText )					CLASS TBank
	
	::FBIK := ::transformText( cText, 10 )
	return

METHOD Function GetRSchet()						CLASS TBank
	return ::FAccount

METHOD PROCEDURE SetRSchet( cText )				CLASS TBank
	
	::FAccount := ::transformText( cText, 20 )
	return

METHOD Function GetKSchet()						CLASS TBank
	return ::FAccountCor

METHOD PROCEDURE SetKSchet( cText )				CLASS TBank
	
	::FAccountCor := ::transformText( cText, 20 )
	return
	
METHOD function transformText( cText, nChar )		CLASS TBank
	return left( hb_defaultvalue( cText, space( nChar ) ), nChar )