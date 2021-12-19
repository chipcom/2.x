#include 'hbclass.ch'
#include 'function.ch'

CREATE CLASS TDescriptorDBF

	HIDDEN:

		VAR _cFileName		AS STRING	INIT ''
		VAR _aStructFile	AS ARRAY	INIT {}
		VAR _aIndexFile		AS ARRAY	INIT {}
		VAR _cAlias			AS STRING	INIT ''
		VAR _cDescription	AS STRING	INIT ''
	
		VAR _bBeforeReconstruct    INIT ''
		VAR _bAfterReconstruct     INIT ''
	
	VISIBLE:
		METHOD FileName( Param )	INLINE	iif( param == nil, ::_cFileName, ::_cFileName := param )
		METHOD StructFile( Param )	INLINE	iif( param == nil, ::_aStructFile, ::_aStructFile := param )
		METHOD IndexFile( Param )	INLINE	iif( param == nil, ::_aIndexFile, ::_aIndexFile := param )
		METHOD AliasFile( Param )	INLINE	iif( param == nil, ::_cAlias, ::_cAlias := param )
		METHOD Description()		INLINE	::cDescription
		
		METHOD New( cFileName, aIndexFile, cAlias, cDescription )

ENDCLASS

METHOD New( cClassName, lCreate )		CLASS TDescriptorDBF

	Local oStruct
	
	HB_Default( @cClassName, '' ) 
	HB_Default( @lCreate, .f. ) 

	oStruct := TStructFiles():New():GetDescr( cClassName , lCreate )
	
	::_cFileName	:=		oStruct:FileName()
	::_aStructFile	:=		oStruct:StructFile()
	::_aIndexFile	:=		oStruct:IndexFile()
	::_cAlias		:=		oStruct:AliasFile()
	::_cDescription	:=		oStruct:Description()
	
	if lCreate .AND. ( !hb_FileExists( ::_cFileName ) )
		dbcreate( ::_cFileName, ::_aStructFile )
	endif
	Return Self
