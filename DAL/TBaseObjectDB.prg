#include 'hbclass.ch'
#include 'common.ch'
#include 'property.ch'

// Описываем класс TBaseObjectDB
CREATE CLASS TBaseObjectDB	INHERIT	TDataAccessDB
	VISIBLE:
		
		PROPERTY ID AS NUMERIC READ getID WRITE setID
		PROPERTY IDUser AS NUMERIC READ getIDUser WRITE setIDUser
		PROPERTY IsDeleted AS LOGICAL READ getIsDeleted WRITE setIsDeleted
		PROPERTY IsNew AS LOGICAL READ getIsNew WRITE setIsNew
		
		METHOD Equal( obj )
	
	PROTECTED:
		DATA FID		INIT 0
		DATA FIDUser	INIT 0
		DATA FDeleted	INIT .f.
		DATA FNew		INIT .t.
		
		METHOD FillFromHash( hbArray )	VIRTUAL
		
		METHOD getID
		METHOD setID( value )
		METHOD getIDUser
		METHOD setIDUser( value )
		METHOD getIsDeleted
		METHOD setIsDeleted( value )
		METHOD getIsNew
		METHOD setIsNew( value )
	
ENDCLASS

METHOD New( )	CLASS TBaseObjectDB

	return self

METHOD function getID()	CLASS TBaseObjectDB
	return ::FID

METHOD procedure setID( value )	CLASS TBaseObjectDB
	::FID := value
	return

METHOD function getIDUser()	CLASS TBaseObjectDB
	return ::FIDUser

METHOD procedure setIDUser( value )	CLASS TBaseObjectDB
	::FIDUser := value
	return

METHOD function getIsDeleted()	CLASS TBaseObjectDB
	return ::FDeleted

METHOD procedure setIsDeleted( value )	CLASS TBaseObjectDB
	::FDeleted := value
	return

METHOD function getIsNew()	CLASS TBaseObjectDB
	return ::FNew

METHOD procedure setIsNew( value )	CLASS TBaseObjectDB
	::FNew := value
	return


&& METHOD Clone()		 CLASS TBaseObjectDB
	&& local oTarget := nil

	&& oTarget := __objClone( self )
	&& oTarget:ID( 0 )
	&& oTarget:IsNew( .t. )
	&& oTarget:IDUser( 0 )
	&& return oTarget
	
******** сравнить объект с переданным
* проверка происходит на основании совпадения идентификаторов записи
*
* Возврат 	.T. - объекты эквивалентены
*			.F. - объекты не эквивалентены
METHOD Equal( obj )		 CLASS TBaseObjectDB

	local ret := .f.
	
	if upper( alltrim( ::ClassName() ) ) == upper( alltrim( obj:ClassName() ) )	// определяем, это один и тот же класс
		ret := ( ::ID == obj:ID )
	endif
	return ret

