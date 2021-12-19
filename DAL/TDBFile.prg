#include "hbclass.ch"
#include "function.ch"

CREATE CLASS TDBFile

	HIDDEN:

		VAR _cFileName		AS STRING	INIT ""
		VAR _aStructFile		AS ARRAY	INIT {}
		VAR _aIndexFile		AS ARRAY	INIT {}
		VAR _cAlias			AS STRING	INIT ""
		VAR _cDescription	AS STRING	INIT ""
	
		VAR _bBeforeReconstruct    INIT ''	// для дальнейшего
		VAR _bAfterReconstruct     INIT ''	// для дальнейшего
	
	
	VISIBLE:
		METHOD FileName( Param )	INLINE	iif( param == nil, ::_cFileName, ::_cFileName := param )
		METHOD IndexFile( Param )	INLINE	iif( param == nil, ::_aIndexFile, ::_aIndexFile := param )
		METHOD AliasFile( Param )	INLINE	iif( param == nil, ::_cAlias, ::_cAlias := param )
		METHOD StructFile( Param )	INLINE	iif( param == nil, ::_aStructFile, ::_aStructFile := param )
		METHOD Description()		INLINE	::_cDescription
		
		METHOD New( cFileName, aIndexFile, cAlias, cDescription )

ENDCLASS

// Конструктор
METHOD New( cFileName, aIndexFile, cAlias, aStructFile, cDescription )		CLASS TDBFile

	HB_Default( @cFileName, "" ) 
	HB_Default( @cAlias, "" ) 
	HB_Default( @cDescription, "" ) 
	HB_Default( @aStructFile, {} ) 
	HB_Default( @aIndexFile, {} ) 

	If Empty( cFileName)
		Return Nil
	EndIf
	::_cFileName	:=	cFileName
	::_aStructFile	:=	aStructFile
	::_aIndexFile	:=	aIndexFile
	::_cAlias		:=	cAlias
	::_cDescription	:=	cDescription
	
	Return Self
