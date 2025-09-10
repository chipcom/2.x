#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'common.ch'
#include 'property.ch'

********************************
// класс для учреждений организации файл mo_uch.dbf
CREATE CLASS TDepartmentDB	INHERIT	TBaseObjectDB
  
	VISIBLE:
		METHOD New()
		METHOD Save( oDepartment )
		
		METHOD GetByID( nID )
		METHOD GetByCode( nCode )
		METHOD GetList( dBegin, dEnd, oUser )
		METHOD NumberOfDepartments( dBegin, dEnd )
		METHOD MenuDepartments()
	HIDDEN:
		
		METHOD FillFromHash( hbArray )

	PROTECTED:
ENDCLASS

METHOD New()		CLASS TDepartmentDB
	return self
	
METHOD GetByID( nID )					CLASS TDepartmentDB
	
	local hArray := nil
	local ret := nil
	
	if ( nID != 0 ) .and. !Empty( hArray := ::super:GetById( nId ) )
		ret := ::FillFromHash( hArray )
	endif
	return ret
	
METHOD GetByCode( nCode )				CLASS TDepartmentDB
  
	return ::GetByID( nCode )
  
METHOD NumberOfDepartments( dBegin, dEnd )	CLASS TDepartmentDB
	
	local oRow := nil
	local ret := 0
	
	HB_Default( @dBegin, ctod( '' ) )
	HB_Default( @dEnd, ctod( '' ) ) 
	for each oRow in ::super:GetList( )
		if between_date( oRow[ 'DBEGIN' ], oRow[ 'DEND' ], dBegin, dEnd )
			ret++
		endif
	next
	return ret

METHOD GetList( dBegin, dEnd, oUser )	CLASS TDepartmentDB
	
	local lFlag := .t.
	local aReturn := {}
	local oRow := nil
	
	HB_Default( @oUser, hb_user_curUser ) 
	HB_Default( @dBegin, ctod( '' ) )
	HB_Default( @dEnd, ctod( '' ) ) 
	for each oRow in ::super:GetList( )
		if empty( dBegin )
				if ! isnil( oUser )
					lFlag := oUser:IsAllowedDepartment( oRow[ 'KOD' ] )
				endif
				if lFlag
					aadd( aReturn, ::FillFromHash( oRow ) )
				endif
		else
			if between_date( oRow[ 'DBEGIN' ], oRow[ 'DEND' ], dBegin, dEnd ) .and. !oRow[ 'DELETED' ]
				if ! isnil( oUser )
					lFlag := oUser:IsAllowedDepartment( oRow[ 'KOD' ] )
				endif
				if lFlag
					aadd( aReturn, ::FillFromHash( oRow ) )
				endif
			endif
		endif
	next
	return aReturn
      
METHOD MenuDepartments( oUser )			CLASS TDepartmentDB
	
	local aDepartment := {}
	local oRow := nil
	
	for each oRow in ::GetList( Date(), , , hb_defaultValue( oUser, hb_user_curUser ) )
		aadd( aDepartment, { oRow:Name(), oRow:ID() } )
	next
	return aDepartment
	  
METHOD Save( oDepartment )							CLASS TDepartmentDB
	
	local ret := .f.
	local aHash := nil
	
	if upper( oDepartment:classname() ) == upper( 'TDepartment' )
		aHash := hb_Hash()
		hb_HAutoAdd( aHash, HB_HAUTOADD_ALWAYS )
		hb_hSet(aHash, 'KOD',			oDepartment:Code )
		hb_hSet(aHash, 'NAME',			oDepartment:Name )
		hb_hSet(aHash, 'SHORT_NAME',	oDepartment:ShortName )
		hb_hSet(aHash, 'IDCHIEF',		if( ! isnil( oDepartment:Chief ), oDepartment:Chief:ID, 0 ) )
		hb_hSet(aHash, 'COMPET',		oDepartment:Competence )
		hb_hSet(aHash, 'ADDRESS',		oDepartment:Address )
		hb_hSet(aHash, 'IS_TALON',		iif( oDepartment:IsUseTalon, 1, 0 ) )
		hb_hSet(aHash, 'DBEGIN',		oDepartment:DBEGIN )
		hb_hSet(aHash, 'DEND',			oDepartment:DEND )
		
		hb_hSet(aHash, 'ID',			oDepartment:ID )
		hb_hSet(aHash, 'REC_NEW',		oDepartment:IsNew )
		hb_hSet(aHash, 'DELETED',		oDepartment:IsDeleted )
		if ( ret := ::super:Save( aHash ) ) != -1
			oDepartment:ID := ret
			oDepartment:IsNew := .f.
		endif
	endif
	return ret
	  
METHOD FillFromHash( hbArray )			CLASS TDepartmentDB
	
	local obj
	
	obj := TDepartment():New( hbArray[ 'ID' ], ;
		hbArray[ 'REC_NEW' ], ;
		hbArray[ 'DELETED' ] ;
	)
	obj:Code := hbArray[ 'KOD' ]
	obj:Name := hbArray[ 'NAME' ]
	obj:ShortName := hbArray[ 'SHORT_NAME' ]
	obj:Chief := hbArray[ 'IDCHIEF' ]
	obj:Competence := hbArray[ 'COMPET' ]
	obj:Address := hbArray[ 'ADDRESS' ]
	obj:IsUseTalon := ! empty( hbArray[ 'IS_TALON' ] )			//если IS_TALON == 0 то .f. иначе .t.
	obj:DBegin := hbArray[ 'DBEGIN' ]
	obj:DEnd := hbArray[ 'DEND' ]
	return obj