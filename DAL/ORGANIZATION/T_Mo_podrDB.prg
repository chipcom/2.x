#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'property.ch'
#include 'common.ch'
#include 'chip_mo.ch'

// класс для справочник подразделений из паспорта ЛПУ _mo_podr.dbf
CREATE CLASS T_Mo_podrDB	INHERIT	TBaseObjectDB
	VISIBLE:
		METHOD New()
		METHOD getByID( nCode )
		METHOD getByCodePodr( param )
		METHOD getListByCodeTFOMS( param )
	HIDDEN:                                      
		METHOD FillFromHash( hbArray )
ENDCLASS

METHOD New()		CLASS T_Mo_podrDB
	return self

METHOD function GetListByCodeTFOMS( param )    	CLASS T_Mo_podrDB
	
	local hArray := nil, aReturn := {}
	local cOldArea
	local cAlias
	local cFind
	local obj
		
	// получим строку поиска
	cFind := param
	cOldArea := Select( )
	if ::super:RUse()
		cAlias := Select( )
		(cAlias)->(dbSetOrder( 1 ))
		if (cAlias)->( dbSeek( cFind ) )
			do while (cAlias)->codemo == glob_mo[ _MO_KOD_TFOMS ] .and. !(cAlias)->(eof())
				if !empty( hArray := ::super:currentRecord() )
					obj := ::FillFromHash( hArray )
					aadd( aReturn, obj )
				endif
				(cAlias)->(dbSkip())
			enddo
		endif
		(cAlias)->( dbCloseArea() )
		dbSelectArea( cOldArea )
	endif
	return aReturn

METHOD function GetByCodePodr( param )    		CLASS T_Mo_podrDB
	
	local hArray := nil, ret := nil
	local cOldArea
	local cAlias
	local cFind
		
	// получим строку поиска
	cFind := glob_mo[ _MO_KOD_TFOMS ] + padr( upper( param ), 25 )
	cOldArea := Select( )
	if ::super:RUse()
		cAlias := Select( )
		(cAlias)->(dbSetOrder( 1 ))
		if (cAlias)->( dbSeek( cFind ) )
			if ! empty( hArray := ::super:currentRecord() )
				ret := ::FillFromHash( hArray )
			endif
		endif
		(cAlias)->( dbCloseArea() )
		dbSelectArea( cOldArea )
	endif
	return ret

METHOD GetByID( nID )					CLASS T_Mo_podrDB
	
	local hArray := nil
	local ret := nil
	
	HB_Default( @nID, 0 )
	if ( nID != 0 ) .AND. ! empty( hArray := ::super:GetById( nId ) )
		ret := ::FillFromHash( hArray )
	endif
	return ret

METHOD FillFromHash( hbArray )			CLASS T_Mo_podrDB
	
	local obj
	
	obj := T_Mo_podr():New( hbArray[ 'ID' ], ;
			hbArray[ 'REC_NEW' ], ;
			hbArray[ 'DELETED' ] ;
			)
	obj:CodeMO := hbArray[ 'CODEMO' ]
	obj:Name := hbArray[ 'NAMEOTD' ]
	obj:OGRN := hbArray[ 'OGRN' ]
	obj:OIDMO := hbArray[ 'OIDMO' ]
	obj:KodOtd := hbArray[ 'KODOTD' ]
	return obj