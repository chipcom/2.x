#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'common.ch'
#include 'property.ch'
#include 'function.ch'

// класс для 'Roles.dbf'
CREATE CLASS TRoleUserDB	INHERIT	TBaseObjectDB
	VISIBLE:
		METHOD New()
		METHOD Save( oRoleUser )
		METHOD Delete( oRoleUser )
		METHOD getByID( nID )
		METHOD getList()
		METHOD MenuRoles()
	HIDDEN:
		METHOD FillFromHash( hbArray )
END CLASS

// ╤ючфрЄ№ эют√щ юс·хъЄ TRoleUserDB
METHOD New() CLASS TRoleUserDB
	return self

// получить роль по ID
METHOD GetByID ( nID )		 CLASS TRoleUserDB
	
	local oRoleUser := nil, hArray := nil
	
	if !Empty( hArray := ::super:GetById( nID ) )
		oRoleUser := ::FillFromHash( hArray )
	endif
	return oRoleUser

//
METHOD GetList()		 CLASS TRoleUserDB
	
	local aRoleUsers := {}
	local xValue := nil
	
	for each xValue in ::Super:GetList( )
		if !xValue[ 'DELETED' ]
			aadd( aRoleUsers, ::FillFromHash( xValue ) )
		endif
	next
	return aRoleUsers

METHOD MenuRoles()		 CLASS TRoleUserDB
	
	local aRoleUsers := {}
	local xValue := nil
	local oRole := nil
	
	for each xValue in ::super:GetList( )
		if !xValue[ 'DELETED' ]
			oRole := ::FillFromHash( xValue )
			aadd( aRoleUsers, { oRole:Name, oRole:ID() } )
		endif
	next
	return aRoleUsers

METHOD Delete( oRoleUser ) CLASS TRoleUserDB
	
	local ret := .f.
	local aHash := nil
	
	if upper( oRoleUser:classname() ) == upper( 'TRoleUser' ) .and. ( ! oRoleUser:IsNew )
		ret := ::super:Delete( oRoleUser )
	endif
	return ret

//
METHOD Save( oRoleUser ) CLASS TRoleUserDB
	
	local ret := .f.
	local aHash := nil
	
	if upper( oRoleUser:classname() ) == upper( 'TRoleUser' )
		aHash := hb_Hash()
		hb_HAutoAdd( aHash, HB_HAUTOADD_ALWAYS )
		hb_hSet(aHash, 'NAME',		oRoleUser:Name )
		hb_hSet(aHash, 'ACL_TASK',	oRoleUser:ACLTask )
		hb_hSet(aHash, 'ACL_DEP',	oRoleUser:ACLDep )
		hb_hSet(aHash, 'ID',		oRoleUser:ID )
		hb_hSet(aHash, 'REC_NEW',	oRoleUser:IsNew )
		hb_hSet(aHash, 'DELETED',	oRoleUser:IsDeleted )
		if ( ret := ::super:Save( aHash ) ) != -1
			oRoleUser:ID := ret
			oRoleUser:IsNew := .f.
		endif
	endif
	return ret

METHOD FillFromHash( hbArray )     CLASS TRoleUserDB
	
	local obj
	
	obj := TRoleUser():New( hbArray[ 'ID' ], ;
		hbArray[ 'NAME' ], ;
		hbArray[ 'ACL_DEP' ], ;
		hbArray[ 'ACL_TASK' ], ;
		hbArray[ 'REC_NEW' ], ;
		hbArray[ 'DELETED' ] ;
	)
	return obj