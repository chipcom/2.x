#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'common.ch'
#include 'property.ch'

********************************
// класс для учреждений организации файл mo_uch.dbf
CREATE CLASS TDepartment	INHERIT	TBaseObjectBLL
  
	VISIBLE:
		PROPERTY Code AS NUMERIC READ getCode WRITE setCode
		PROPERTY Name AS STRING READ getName WRITE setName		// наименование подразделения
		PROPERTY Name1251 READ getName1251
		PROPERTY ShortName AS STRING READ getShort WRITE setShort		// краткое наименование подразделения
		PROPERTY ShortName1251 READ getShort1251
		PROPERTY IsUseTalon AS BOOLEAN READ getTalon WRITE setTalon		// 
		PROPERTY DBegin AS DATE READ getDBegin WRITE setDBegin		// 
		PROPERTY DEnd AS DATE READ getDEnd WRITE setDEnd		// 
		PROPERTY Address AS STRING READ getAddress WRITE setAddress		// адрес подразделения
		PROPERTY Address1251 READ getAddress1251
		PROPERTY Chief AS OBJECT READ getChief WRITE setChief			// руководитель подразделения
		PROPERTY Competence AS STRING READ getCompetence WRITE setCompetence
		PROPERTY Competence1251 READ getCompetence1251
		
		PROPERTY IsUseTalon_F READ getTalonFormat
	
		METHOD New( nId, lNew, lDeleted )
		METHOD Clone()
		
		METHOD listForJSON()
		METHOD forJSON()
		
	HIDDEN:
		DATA FCode		INIT 0
		DATA FName		INIT space( 30 )
		DATA FShortName	INIT space( 5 )
		DATA FTalon		INIT .f.
		DATA FDBEGIN	INIT ctod( '' )
		DATA FDEND		INIT ctod( '' )
		DATA FAddress	INIT space( 70 )
		DATA FCompetence INIT space( 40 )
		DATA FChief		INIT nil
		
		METHOD getCode
		METHOD setCode( nValue )
		METHOD getName
		METHOD getName1251
		METHOD setName( cValue )
		METHOD getShort
		METHOD getShort1251
		METHOD setShort( cValue )
		METHOD getTalon
		METHOD setTalon( bValue )
		METHOD getDBegin
		METHOD setDBegin( dValue )
		METHOD getDEnd
		METHOD setDEnd( dValue )
		METHOD getAddress
		METHOD getAddress1251
		METHOD setAddress( cValue )
		METHOD getCompetence
		METHOD getCompetence1251
		METHOD setCompetence( cValue )
		METHOD getChief
		METHOD setChief( oValue )
		METHOD getTalonFormat
	PROTECTED:
ENDCLASS

METHOD function getTalonFormat()		 	CLASS TDepartment

	return if( ::FTalon, 'Да', 'Нет' )

METHOD function getCode()		 			CLASS TDepartment
	return ::FCode

METHOD procedure setCode( nValue )		CLASS TDepartment
	::FCode := nValue
	return

METHOD function getName()		 			CLASS TDepartment
	return ::FName
	
METHOD function getName1251()		 		CLASS TDepartment
	return win_OEMToANSI( ::FName )
	
METHOD procedure setName( cValue )		CLASS TDepartment
	::FName := cValue
	return

METHOD function getShort()	 			CLASS TDepartment
	return ::FShortName
	
METHOD function getShort1251()	 		CLASS TDepartment
	return win_OEMToANSI( ::FShortName )
	
METHOD procedure setShort( cValue )		CLASS TDepartment
	::FShortName := cValue
	return

METHOD function getTalon()	 			CLASS TDepartment
	return ::FTalon
	
METHOD procedure setTalon( bValue )		CLASS TDepartment
	::FTalon := bValue
	return

METHOD function getDBegin()				CLASS TDepartment
	return ::FDBEGIN
	
METHOD procedure setDBegin( dValue )		CLASS TDepartment
	::FDBEGIN := dValue
	return

METHOD function getDEnd()					CLASS TDepartment
	return ::FDEND
	
METHOD procedure setDEnd( dValue )		CLASS TDepartment
	::FDEND := dValue
	return

METHOD function getAddress()		 		CLASS TDepartment
	return ::FAddress
	
METHOD function getAddress1251()		 	CLASS TDepartment
	return win_OEMToANSI( ::FAddress )
	
METHOD procedure setAddress( cValue )	CLASS TDepartment
	::FAddress := cValue
	return

METHOD function getCompetence()		 	CLASS TDepartment
	return ::FCompetence
	
METHOD function getCompetence1251()		CLASS TDepartment
	return win_OEMToANSI( ::FCompetence )
	
METHOD procedure setCompetence( cValue )	CLASS TDepartment
	::FCompetence := cValue
	return

METHOD function getChief()			 	CLASS TDepartment
	return ::FChief
	
METHOD procedure setChief( param )		CLASS TDepartment
	if valtype( param ) == 'N'
		::FChief := TEmployeeDB():GetByID( param )
	elseif valtype( param ) == 'O' .and. param:ClassName() == upper( 'TEmployee' )
		::FChief := param
	elseif isnil( param )
		::FChief := nil
	endif
	return

METHOD Clone()							CLASS TDepartment
	local oTarget := nil
	
	oTarget := ::super:Clone()
	oTarget:Code( 0 )
	return oTarget

METHOD New( nId, lNew, lDeleted )		CLASS TDepartment
			
	::FNew 						:= hb_defaultValue( lNew, .t. )
	::FDeleted					:= hb_defaultValue( lDeleted, .f. )
	::FID						:= hb_defaultValue( nID, 0 )
	return self
	
METHOD function forJSON()					CLASS TDepartment
	local oRow := nil, obj := nil
	local hItems, hItem, h

	h := { => }
	hItems := { => }
	hItem := { => }
	hb_HSet( hItem, 'ID', ltrim( str( ::ID ) ) )
	hb_HSet( hItem, 'ShortName', alltrim( ::ShortName ) )
	hb_HSet( hItem, 'Name', alltrim( ::Name ) )
	hb_HSet( hItem, 'Address', alltrim( ::Address ) )
	if ! isnil( ::Chief )
		hb_HSet( hItem, 'Chief', ::Chief:forJSON() )
	endif
	hb_HSet( hItem, 'Competence', alltrim( ::Competence ) )
	return hItem

METHOD function listForJSON()				CLASS TDepartment
	local oRow := nil, obj := nil
	local hItems, hItem, h

	h := { => }
	hItems := { => }
	for each oRow in ::super:GetList( )
		hItem := { => }
		obj := ::FillFromHash( oRow )
		hb_HSet( hItem, 'ID', ltrim( str( obj:ID ) ) )
		hb_HSet( hItem, 'ShortName', alltrim( obj:ShortName ) )
		hb_HSet( hItem, 'Name', alltrim( obj:Name ) )
		hb_HSet( hItem, 'Address', alltrim( obj:Address ) )
		if ! isnil( obj:Chief )
			hb_HSet( hItem, 'Chief', obj:Chief:forJSON() )
		endif
		hb_HSet( hItem, 'Competence', alltrim( obj:Competence ) )
		hb_HSet( hItems, 'Подразделение-' + ltrim( str( obj:ID ) ), hItem )
	next
	h[ 'СправочникПодразделений' ] := hItems
	return h