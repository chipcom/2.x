#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'function.ch'
#include 'property.ch'

// класс для сотрудников учреждения файл MO_PERS.DBF
CREATE CLASS TEmployeeDB	INHERIT	TBaseObjectDB
	VISIBLE:
		METHOD New()
	
		METHOD Save( oEmployee )
		METHOD getByID ( nCode )
		METHOD getByCode ( nCode )
		METHOD getByTabNom ( cCode )
		METHOD GetList( nType )
		METHOD GetListOnDate( nType, dDate )	// список на дату
		METHOD GetListByDepartment( nDepartment )
		METHOD GetListBySubdivision( nSubdivision )
		METHOD GetListDoctor( )
		METHOD GetListNurse( )
		METHOD GetListAidman( )
		METHOD GetListEmployees( )
	HIDDEN:
		METHOD FillFromHash( hbArray )
ENDCLASS

METHOD New() CLASS TEmployeeDB
	return self
  

METHOD getByID ( nID )		 CLASS TEmployeeDB
	local hArray := Nil
	local ret := Nil
	
	if ( nID != 0 ) .and. !Empty( hArray := ::super:GetById( nID ) )
		ret := ::FillFromHash( hArray )
	endif
	return ret
  
METHOD getByCode ( nCode )		 CLASS TEmployeeDB
	return ::GetByID( nCode )
  
METHOD getByTabNom ( cCode )		 CLASS TEmployeeDB
	local cOldArea, employee, cFind
	local ret := nil
	
	// предварительно проверить что пришло число или строка из 5-ти цифр,
	// если число преобразовать STR( nCode, 5 )
	if ValType( cCode ) == 'N'
		cFind := STR( cCode, 5 )
	elseif ValType( cCode ) == 'C'
		cFind := cCode
	else
		return nil
	endif
	cOldArea := Select( )
	if ::super:RUse()
		employee := Select( )
		if (employee)->(dbSeek( cFind ))
			ret := TEmployee():New( (employee)->( recno() ), .f., (employee)->(Deleted()) )
			ret:Code := (employee)->KOD
			ret:Department := (employee)->UCH
			ret:Subdivision := (employee)->OTD
			ret:Position := (employee)->NAME_DOLJ
			ret:Category := (employee)->KATEG
			ret:Name := (employee)->FIO
			ret:Stavka := (employee)->STAVKA
			ret:Vid := (employee)->VID
			ret:DoctorCategory := (employee)->VR_KATEG
			ret:DoljCategory := (employee)->DOLJKAT
			ret:Profil := (employee)->PROFIL
			ret:Dcategory := (employee)->D_KATEG
			ret:IsSertif := iif( (employee)->SERTIF == 1, .t., .f. )
			ret:Dsertif := (employee)->D_SERTIF
			ret:PRVS := (employee)->PRVS
			ret:PRVSNEW := (employee)->PRVS_NEW
			ret:PRVS021 := (employee)->PRVS_021
			ret:SNILS := (employee)->SNILS
			ret:DBegin := (employee)->DBEGIN
			ret:DEnd := (employee)->DEND
			ret:TabNom := (employee)->TAB_NOM
			ret:SvodNom := (employee)->SVOD_NOM
			ret:KodDLO := (employee)->KOD_DLO
			ret:Uroven := (employee)->UROVEN
			ret:Otdal := iif( (employee)->OTDAL == 1, .t., .f. )
		endif
		(employee)->( dbCloseArea() )
		dbSelectArea( cOldArea )
	endif
	return ret

METHOD getListByDepartment( nDepartment )   CLASS TEmployeeDB
	local aReturn := {}
	local oRow := Nil
	
	HB_Default( @nDepartment, 0 ) 
	for each oRow in ::super:GetList( )
		if ( oRow[ 'UCH' ] == nDepartment .and. !oRow[ 'DELETED' ] )
			aadd( aReturn, ::FillFromHash( oRow ) )
		endif
	next
	return aReturn
	
METHOD getListBySubdivision( nSubdivision )   CLASS TEmployeeDB
	local aReturn := {}
	local oRow := Nil
	
	HB_Default( @nSubdivision, 0 ) 
	for each oRow in ::super:GetList( )
		if ( oRow[ 'OTD' ] == nSubdivision .and. !oRow[ 'DELETED' ] )
			aadd( aReturn, ::FillFromHash( oRow ) )
		endif
	next
	return aReturn
	
METHOD getList( nType )   CLASS TEmployeeDB
	local aReturn := {}
	local oRow := Nil
	
	HB_Default( @nType, 0 ) 
	for each oRow in ::super:GetList( )
		if ( oRow[ 'KOD' ] > 0 .and. !oRow[ 'DELETED' ] )
				do case
					case ( nType == 0 )
						aadd( aReturn, ::FillFromHash( oRow ) )		// все
					case ( nType == 1 )
						if ( oRow[ 'KATEG' ] == 1 )				// врачи
							aadd( aReturn, ::FillFromHash( oRow ) )
						endif
					case ( nType == 2 )
						if ( oRow[ 'KATEG' ] == 2 )				// медсестры
							aadd( aReturn, ::FillFromHash( oRow ) )
						endif
					case ( nType == 3 )
						if ( oRow[ 'KATEG' ] == 3 )				// санитары
							aadd( aReturn, ::FillFromHash( oRow ) )
						endif
					case ( nType == 4 )
						if ( oRow[ 'KATEG' ] == 4 )				// прочие
							aadd( aReturn, ::FillFromHash( oRow ) )
						endif
				endcase
		endif
	next
	return aReturn

METHOD getListOnDate( nType, dDate )   CLASS TEmployeeDB
	local aReturn := {}
	local oRow := nil
	
	HB_Default( @nType, 0 ) 
	HB_Default( @dDate, date() ) 

	for each oRow in ::super:GetList( )
		if ( oRow[ 'KOD' ] > 0 .and. !oRow[ 'DELETED' ] ) //.and. between( dDate, oRow[ 'DBEGIN' ], oRow[ 'DEND' ] )//;
			if ( oRow[ 'DBEGIN' ] <= dDate .and. empty( oRow[ 'DEND' ] ) ) .or. ;
							between( dDate, oRow[ 'DBEGIN' ], oRow[ 'DEND' ] )
//							( oRow[ 'DBEGIN' ] <= dDate .and. oRow[ 'DEND' ] >= dDate )
				do case
					case ( nType == 0 )
						aadd( aReturn, ::FillFromHash( oRow ) )		// все
					case ( nType == 1 )
						if ( oRow[ 'KATEG' ] == 1 )				// врачи
							aadd( aReturn, ::FillFromHash( oRow ) )
						endif
					case ( nType == 2 )
						if ( oRow[ 'KATEG' ] == 2 )				// медсестры
							aadd( aReturn, ::FillFromHash( oRow ) )
						endif
					case ( nType == 3 )
						if ( oRow[ 'KATEG' ] == 3 )				// санитары
							aadd( aReturn, ::FillFromHash( oRow ) )
						endif
					case ( nType == 4 )
						if ( oRow[ 'KATEG' ] == 4 )				// прочие
							aadd( aReturn, ::FillFromHash( oRow ) )
						endif
				endcase
			endif
		endif
	next
	return aReturn
	
METHOD getListDoctor( )   CLASS TEmployeeDB
	return ::GetList( 1 )
  
METHOD getListNurse( )   CLASS TEmployeeDB
	return ::GetList( 2 )

METHOD getListAidman( )   CLASS TEmployeeDB
	return ::GetList( 3 )

METHOD getListEmployees( )   CLASS TEmployeeDB
	return ::GetList( 4 )
  
METHOD getShortFIO( )   CLASS TEmployeeDB
	local cStr, ret := '', k := 0
	local cFIO := ::FName, i, s := '', s1 := '', ret_arr := { '', '', '' }

	cFIO := alltrim( cFIO )
	for i := 1 to numtoken(	cFIO,	' '	)
		s1 := alltrim( token( cFIO, ' ', i ) )
		if !empty( s1 )
			++k
			if k < 3
				ret_arr[ k ] := s1
			else
				s += s1 + ' '
			endif
		endif
	next
	ret_arr[3] := alltrim( s )
	ret := ret_arr[1] + ' ' + Left( ret_arr[2], 1 ) + '.' + if( Empty( ret_arr[3] ), '', Left( ret_arr[3], 1 ) + '.' )
	return ret

* Сохранить объект TEmployeeDB
*
METHOD Save( oEmployee ) CLASS TEmployeeDB
	local ret := .f.
	local aHash := nil
	
	if upper( oEmployee:classname() ) == upper( 'TEmployee' )
		aHash := hb_Hash()
		hb_HAutoAdd( aHash, HB_HAUTOADD_ALWAYS )
		hb_hSet(aHash, 'KOD',		oEmployee:Code )
		hb_hSet(aHash, 'UCH',		oEmployee:Department )
		hb_hSet(aHash, 'OTD',		oEmployee:Subdivision )
		hb_hSet(aHash, 'NAME_DOLJ',	oEmployee:Position )
		hb_hSet(aHash, 'KATEG',		oEmployee:Category )
		hb_hSet(aHash, 'FIO',		oEmployee:Name )
		hb_hSet(aHash, 'STAVKA',	oEmployee:Stavka )
		hb_hSet(aHash, 'VID',		oEmployee:Vid )
		hb_hSet(aHash, 'VR_KATEG',	oEmployee:DoctorCategory )
		hb_hSet(aHash, 'DOLJKAT',	oEmployee:DoljCategory )
		
		hb_hSet(aHash, 'D_KATEG',	oEmployee:Dcategory )
		hb_hSet(aHash, 'SERTIF',	iif( oEmployee:IsSertif, 1, 0 ) )
		hb_hSet(aHash, 'D_SERTIF',	oEmployee:Dsertif )
		hb_hSet(aHash, 'PRVS',		oEmployee:PRVS )
		hb_hSet(aHash, 'PRVS_NEW',	oEmployee:PRVSNEW )
		hb_hSet(aHash, 'PRVS_021',	oEmployee:PRVS021 )
		hb_hSet(aHash, 'PROFIL',	oEmployee:Profil )
		
		hb_hSet(aHash, 'TAB_NOM',	oEmployee:TabNom )
		hb_hSet(aHash, 'SVOD_NOM',	oEmployee:SvodNom )
		hb_hSet(aHash, 'KOD_DLO',	oEmployee:KodDLO )
		hb_hSet(aHash, 'UROVEN',	oEmployee:Uroven )
		hb_hSet(aHash, 'OTDAL',		iif( oEmployee:Otdal, 1, 0 ) )
		hb_hSet(aHash, 'SNILS',		oEmployee:SNILS )
		hb_hSet(aHash, 'DBEGIN',	oEmployee:DBegin )
		hb_hSet(aHash, 'DEND',		oEmployee:DEnd )
			
		hb_hSet(aHash, 'ID',		oEmployee:ID )
		hb_hSet(aHash, 'REC_NEW',	oEmployee:IsNew )
		hb_hSet(aHash, 'DELETED',	oEmployee:IsDeleted )
		if ( ret := ::super:Save( aHash ) ) != -1
			oEmployee:ID := ret
			oEmployee:IsNew := .f.
		endif
	endif
	return ret
	
METHOD FillFromHash( hbArray )     CLASS TEmployeeDB
	local obj
	
	obj := TEmployee():New( hbArray[ 'ID' ], hbArray[ 'REC_NEW' ], hbArray[ 'DELETED' ] )
	obj:Code := hbArray[ 'KOD' ]
	obj:Department := hbArray[ 'UCH' ]
	obj:Subdivision := hbArray[ 'OTD' ]
	obj:Position := hbArray[ 'NAME_DOLJ' ]
	obj:Category := hbArray[ 'KATEG' ]
	obj:Name := hbArray[ 'FIO' ]
	obj:Stavka := hbArray[ 'STAVKA' ]
	obj:Vid := hbArray[ 'VID' ]
	obj:DoctorCategory := hbArray[ 'VR_KATEG' ]
	obj:DoljCategory := hbArray[ 'DOLJKAT' ]
	obj:Profil := hbArray[ 'PROFIL' ]
	obj:Dcategory := hbArray[ 'D_KATEG' ]
	obj:IsSertif := iif( hbArray[ 'SERTIF' ] == 1, .t., .f. )
	obj:Dsertif := hbArray[ 'D_SERTIF' ]
	obj:PRVS := hbArray[ 'PRVS' ]
	obj:PRVSNEW := hbArray[ 'PRVS_NEW' ]
	obj:PRVS021 := hbArray[ 'PRVS_021' ]
	obj:SNILS := hbArray[ 'SNILS' ]
	obj:DBegin := hbArray[ 'DBEGIN' ]
	obj:DEnd := hbArray[ 'DEND' ]
	obj:TabNom := hbArray[ 'TAB_NOM' ]
	obj:SvodNom := hbArray[ 'SVOD_NOM' ]
	obj:KodDLO := hbArray[ 'KOD_DLO' ]
	obj:Uroven := hbArray[ 'UROVEN' ]
	obj:Otdal := iif( hbArray[ 'OTDAL' ] == 1, .t., .f. )
	return obj