#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'property.ch'
#include 'common.ch'
&& #include 'function.ch'
#include 'chip_mo.ch'

// класс для отделений учреждения файл mo_otd.dbf
CREATE CLASS TSubdivisionDB	INHERIT	TBaseObjectDB
	VISIBLE:
		METHOD New()
		METHOD Save( oSubdivision )
		METHOD GetByID( nCode )
		METHOD GetByCode( nCode )
		METHOD GetList( nDepartment, oUser, nTask, dBegin, dEnd )
		METHOD MenuSubdivisions( department, oUser, nTask )
	HIDDEN:                                      
		METHOD FillFromHash( hbArray )
ENDCLASS

METHOD New() CLASS TSubdivisionDB
	return self

METHOD GetByID( nID )    CLASS TSubdivisionDB
	local hArray := nil
	local ret := nil
	
	HB_Default( @nID, 0 )
	if ( nID != 0 ) .AND. !Empty( hArray := ::super:GetById( nId ) )
		ret := ::FillFromHash( hArray )
	EndIf
	return ret

METHOD GetByCode( nCode )    CLASS TSubdivisionDB
	return ::GetByID( nCode )		//ret

METHOD GetList( nDepartment, oUser, nTask, dBegin, dEnd )   CLASS TSubdivisionDB
 	local lFlag := .t.
	local aReturn := {}
	local oRow := nil
	
	HB_Default( @dBegin, ctod( '' ) )
	HB_Default( @dEnd, ctod( '' ) )
	HB_Default( @nDepartment, 0 )
	HB_Default( @oUser, nil )
	for each oRow in ::super:GetList( )
		if oUser != nil
			if !oUser:IsAllowedDepartment( oRow[ 'KOD_LPU' ] )
				loop
			endif
		endif
		if nDepartment != 0
			if nDepartment != oRow[ 'KOD_LPU' ]
				loop
			endif
		endif
		if nTask != nil
			switch nTask
				case X_ORTO
					if between_date( oRow[ 'DBEGINO' ], oRow[ 'DENDO' ], dBegin, dEnd )
						lFlag := .t.
					endif
				case X_PLATN
					if between_date( oRow[ 'DBEGINP' ], oRow[ 'DENDP' ], dBegin, dEnd )
						lFlag := .t.
					endif
				case X_OMS
						if between_date( oRow[ 'DBEGIN' ], oRow[ 'DEND' ], dBegin, dEnd )
							lFlag := .t.
					endif
			endswitch
		endif
		if lFlag
			AADD( aReturn, ::FillFromHash( oRow ) )
		EndIf
	next
	return aReturn
	
METHOD MenuSubdivisions( department, oUser, nTask )		 CLASS TSubdivisionDB
	local aSubdivision := {}
	local oRow := nil
	local idDepartment := 0
	
	if valtype( department ) == 'N'
		idDepartment := department
	elseif valtype( department ) == 'O' .and. department:ClassName() == upper( 'TDepartment' )
		idDepartment := department:ID()
	endif
	
	for each oRow in ::GetList( idDepartment, hb_defaultValue( oUser, hb_user_curUser ), ;
				hb_defaultValue( nTask, X_PLATN ), sys_date  )
		AADD( aSubdivision, { oRow:Name(), oRow:ID() } )
	next
	return aSubdivision
	
METHOD Save( oSubdivision ) CLASS TSubdivisionDB
	local ret := .f.
	local aHash := nil
	
	if upper( oSubdivision:classname() ) == upper( 'TSubdivision' )
		aHash := hb_Hash()
		hb_HAutoAdd( aHash, HB_HAUTOADD_ALWAYS )
	
		hb_hSet(aHash, 'KOD',			oSubdivision:Code )
		hb_hSet(aHash, 'NAME',			oSubdivision:Name )
		hb_hSet(aHash, 'KOD_LPU',		oSubdivision:IDDepartment )
		hb_hSet(aHash, 'SHORT_NAME',	oSubdivision:ShortName )
		hb_hSet(aHash, 'DBEGIN',		oSubdivision:DBegin )
		hb_hSet(aHash, 'DEND',			oSubdivision:DEnd )
		hb_hSet(aHash, 'DBEGINP',		oSubdivision:DBeginP )
		hb_hSet(aHash, 'DENDP',			oSubdivision:DEndP )
		hb_hSet(aHash, 'DBEGINO',		oSubdivision:DBeginO )
		hb_hSet(aHash, 'DENDO',			oSubdivision:DEndO )
		hb_hSet(aHash, 'PLAN_VP',		oSubdivision:Plan_VP )
		hb_hSet(aHash, 'PLAN_PF',		oSubdivision:Plan_PF )
		hb_hSet(aHash, 'PLAN_PD',		oSubdivision:Plan_PD )
		hb_hSet(aHash, 'PROFIL',		oSubdivision:Profil )
		hb_hSet(aHash, 'PROFIL_K',		oSubdivision:ProfilK )
		hb_hSet(aHash, 'IDSP',			oSubdivision:IDSP )
		hb_hSet(aHash, 'IDUMP',			oSubdivision:IDUMP )
		hb_hSet(aHash, 'IDVMP',			oSubdivision:IDVMP )
		hb_hSet(aHash, 'TIP_OTD',		oSubdivision:TypePodr )
		hb_hSet(aHash, 'KOD_PODR',		oSubdivision:KodPodr )
		hb_hSet(aHash, 'TIPLU',			oSubdivision:TypeLU )
		hb_hSet(aHash, 'CODE_DEP',		oSubdivision:CodeSubTFOMS )
		hb_hSet(aHash, 'KOD_SOGL',		oSubdivision:KodSogl )
	
		hb_hSet(aHash, 'ADDRESS',		oSubdivision:Address )
		hb_hSet(aHash, 'ADRES_PODR',	oSubdivision:AddressSubdivision )
		hb_hSet(aHash, 'CODE_TFOMS',	oSubdivision:CodeTFOMS )
		hb_hSet(aHash, 'SOME_SOGL',		oSubdivision:SomeSogl )
		
		hb_hSet(aHash, 'ID',			oSubdivision:ID )
		hb_hSet(aHash, 'REC_NEW',		oSubdivision:IsNew )
		hb_hSet(aHash, 'DELETED',		oSubdivision:IsDeleted )
		if ( ret := ::super:Save( aHash ) ) != -1
			oSubdivision:ID := ret
			oSubdivision:IsNew := .f.
		endif
	endif
	return ret

METHOD FillFromHash( hbArray )     CLASS TSubdivisionDB
	local obj
	
	obj := TSubdivision():New( hbArray[ 'ID' ], ;
			hbArray[ 'REC_NEW' ], ;
			hbArray[ 'DELETED' ] ;
			)
	obj:Code := hbArray[ 'KOD' ]
	obj:Name := hbArray[ 'NAME' ]
	obj:IDDepartment := hbArray[ 'KOD_LPU' ]
	obj:ShortName := hbArray[ 'SHORT_NAME' ]
	obj:DBegin := hbArray[ 'DBEGIN' ]
	obj:DEnd := hbArray[ 'DEND' ]
	obj:DBeginP := hbArray[ 'DBEGINP' ]
	obj:DEndP := hbArray[ 'DENDP' ]
	obj:DBeginO := hbArray[ 'DBEGINO' ]
	obj:DEndO := hbArray[ 'DENDO' ]
	obj:Plan_VP := hbArray[ 'PLAN_VP' ]
	obj:Plan_PF := hbArray[ 'PLAN_PF' ]
	obj:Plan_PD := hbArray[ 'PLAN_PD' ]
	obj:Profil := hbArray[ 'PROFIL' ]
	obj:ProfilK := hbArray[ 'PROFIL_K' ]
	obj:IDSP := hbArray[ 'IDSP' ]
	obj:IDUMP := hbArray[ 'IDUMP' ]
	obj:IDVMP := hbArray[ 'IDVMP' ]
	obj:TypePodr := hbArray[ 'TIP_OTD' ]
	obj:KodPodr := hbArray[ 'KOD_PODR' ]
	obj:TypeLU := hbArray[ 'TIPLU' ]
	obj:KodSogl := hbArray[ 'KOD_SOGL' ]
	obj:AddressSubdivision := hbArray[ 'ADRES_PODR' ]
	obj:Address := hbArray[ 'ADDRESS' ]
	obj:CodeTFOMS := hbArray[ 'CODE_TFOMS' ]
	obj:SomeSogl := hbArray[ 'SOME_SOGL' ]
	obj:CodeSubTFOMS  := hbArray[ 'CODE_DEP' ]
	return obj