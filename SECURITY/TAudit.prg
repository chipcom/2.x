#include 'hbclass.ch'
#include 'hbhash.ch'

// класс для 'mo_opern.dbf'
CREATE CLASS TAudit	INHERIT	TBaseObject
	
	HIDDEN:
		VAR _dDate				AS DATE		INIT ctod( '' )	// {"PD",      "C",   4,   0},; // дата ввода c4tod(pd)
		VAR _nIDOper			AS NUMERIC	INIT 0			// {"PO",      "C",   1,   0},; // код оператора asc(po)
		VAR _nTask				AS NUMERIC	INIT 0			// {"PT",      "C",   1,   0},; // код задачи
		VAR _nType				AS NUMERIC	INIT 0			// {"TP",      "C",   1,   0},; // тип (1-карточка, 2-л/у, 3-услуги)
		VAR _nWork				AS NUMERIC	INIT 0			// {"AE",      "C",   1,   0},; // 1-добавление, 2-редактирование, 3-удаление
		VAR _nQuantity			AS NUMERIC	INIT 0			// {"KK",      "C",   3,   0},; // кол-во (карточек, л/у или услуг)
		VAR _nField				AS NUMERIC	INIT 0			// {"KP",      "C",   3,   0};  // количество введённых полей
		                                                        
		METHOD FillFromHash( hbArray )
		
	VISIBLE:
		
		METHOD New( nID, dDate, nIDUser, nTask, nType, nWork, nQuantity, nField, lNew, lDeleted )
		METHOD Save()

		METHOD Quantity( param )			INLINE iif( param == nil, ::_nQuantity, ::_nQuantity )
		METHOD Field( param )			INLINE iif( param == nil, ::_nField, ::_nField )
		METHOD WriteToAudit( nTask, nType, nWork, nQuantity, nField, _open )
		
END CLASS

METHOD New( nID, dDate, nIDUser, nTask, nType, nWork, nQuantity, nField, lNew, lDeleted ) CLASS TAudit

	::nID				:= hb_DefaultValue( nID, 0 )
	::lNew				:= hb_DefaultValue( lNew, .t. )
	::lDeleted			:= hb_DefaultValue( lDeleted, .f. )
	
	::_dDate			:= hb_DefaultValue( dDate, sys_date )
	::_nIDOper			:= hb_DefaultValue( nIDUser, currentuser():ID() )
	::_nTask			:= hb_DefaultValue( nTask, 0 )
	::_nType			:= hb_DefaultValue( nType, 0 )
	::_nWork			:= hb_DefaultValue( nWork, 0 )
	::_nQuantity		:= hb_DefaultValue( nQuantity, 0 )
	::_nField			:= hb_DefaultValue( nField, 0 )
	return self

* 
*
METHOD Save() CLASS TAudit
	local ret := .f.
	local aHash := nil
	local llen := 6
	
	aHash := hb_Hash()
	hb_HAutoAdd( aHash, HB_HAUTOADD_ALWAYS )
	hb_hSet(aHash, 'PD',		dtoc4( ::_dDate ) )
	hb_hSet(aHash, 'PO',		chr( ::_nIDOper ) )
	hb_hSet(aHash, 'PT',		chr( ::_nTask ) )
	hb_hSet(aHash, 'TP',		chr( ::_nType ) )
	hb_hSet(aHash, 'AE',		chr( ::_nWork ) )
    hb_hSet(aHash, 'KK',		ft_sqzn( ::_nQuantity, llen ) )
    hb_hSet(aHash, 'KP',		ft_sqzn( ::_nField, llen ) )
	hb_hSet(aHash, 'ID',		::nID )
	hb_hSet(aHash, 'REC_NEW',	::lNew )
	hb_hSet(aHash, 'DELETED',	::lDeleted )
	ret := ::super:Save( aHash )
	return ret
	
METHOD FillFromHash( hbArray )     CLASS TAudit
	local obj
	local llen := 6
	
	obj := TAudit():New( hbArray[ 'ID' ], ;
			c4tod( hbArray[ 'PD' ] ), ;
			asc( hbArray[ 'PO' ] ), ;
			asc( hbArray[ 'PT' ] ), ;
			asc( hbArray[ 'TP' ] ), ;
			asc( hbArray[ 'AE' ] ), ;
			ft_unsqzn( hbArray[ 'KK' ], llen ), ;
			ft_unsqzn( hbArray[ 'KP' ], llen ), ;
			hbArray[ 'REC_NEW' ], ;
			hbArray[ 'DELETED' ] ;
			)
	return obj	

METHOD WriteToAudit( nTask, nType, nWork, nQuantity, nField, _open )     CLASS TAudit
	local cFind := '', hArray
	local cOldArea, cAudit, obj := nil
	local llen := 6

	hb_Default( @nTask, 1 )
	hb_Default( @nField, 0 )
	hb_Default( @_open, .t. )
	cFind := c4sys_date + chr( currentuser():ID() ) + chr( nTask ) + chr( nType ) + chr( nWork )
	// найдем запись для работы оператора
	cOldArea := Select()
	if ::super:RUse()
		cAudit := Select()
		(cAudit)->(dbSetOrder( 1 ))
		if (cAudit)->(dbSeek( cFind ))
			if !empty( hArray := ::super:currentRecord() )
				obj := ::FillFromHash( hArray )
				&& obj:Quantity( ft_sqzn( nQuantity + ft_unsqzn(obj:Quantity, llen ), llen ) )
				&& obj:Field( ft_sqzn( nField + ft_unsqzn( obj:Field(), llen ), llen ) )
				obj:Quantity( nQuantity + obj:Quantity() )
				obj:Field( nField + obj:Field() )
			endif
		else
			obj := ::New( , c4sys_date, currentuser():ID(), nTask, nType, nWork, nQuantity, nField )
		endif
		(cAudit)->( dbCloseArea() )
		dbSelectArea( cOldArea )
	endif
	return obj
	
// класс для 'mo_oper.dbf'
CREATE CLASS TAudit_main	INHERIT	TBaseObject
	
	HIDDEN:

		VAR _nIDOper			AS NUMERIC	INIT 0			// {"PO",      "C",   1,   0},; // код оператора asc(po)
		VAR _dDate				AS DATE		INIT ctod( '' )	// {"PD",      "C",   4,   0},; // дата ввода c4tod(pd)
		VAR _cV0				AS CHARACTER INIT '   '		// { 'V0',			'C',   3,   0},; // добавление в регистратуре
		VAR _cVR				AS CHARACTER INIT '   '		// { 'VR',			'C',   3,   0},; // добавление в регистратуре
		VAR _cVK				AS CHARACTER INIT '   '		// { 'VK',			'C',   3,   0},; // добавление в регистратуре
		VAR _cVU				AS CHARACTER INIT '   '		// { 'VU',			'C',   3,   0},; // добавление в регистратуре
		VAR _nTask				AS NUMERIC	INIT 0			// { 'TASK',      'N',   1,   0},; // код задачи
		VAR _nCharacter			AS NUMERIC	INIT 0			// { 'CS',			'C',   4,   0},; // количество введённых символов
		VAR _lEdit				AS LOGICAL	INIT .f.		// { 'APP_EDIT',	'N',   1,   0};  // 0 - добавление, 1 - редактирование
		                                                        
		METHOD FillFromHash( hbArray )
		
					&& { 'PO',			'C',   1,   0},; // код оператора asc(po)
					&& { 'PD',			'C',   4,   0},; // дата ввода c4tod(pd)
					&& { 'V0',			'C',   3,   0},; // добавление в регистратуре
					&& { 'VR',			'C',   3,   0},; // полные реквизиты      \
					&& { 'VK',			'C',   3,   0},; // реквизиты из картотеки => ft_unsqzn(V..., 6)
					&& { 'VU',			'C',   3,   0},; // ввод услуг            /
					&& { 'TASK',		'N',   1,   0},; // код задачи            /
					&& { 'CS',			'C',   4,   0},; // количество введённых символов
					&& { 'APP_EDIT',	'N',   1,   0};  // 0 - добавление, 1 - редактирование
		
	VISIBLE:
	
		METHOD New( nID, nIDUser, dDate, cV0, cVR, cVK, cVU, nTask, nCharacter, lEdit, lNew, lDeleted )
		METHOD Save()
					
END CLASS

METHOD New( nID, nIDUser, dDate, cV0, cVR, cVK, cVU, nTask, nCharacter, lEdit, lNew, lDeleted ) CLASS TAudit_main

	::nID				:= hb_DefaultValue( nID, 0 )
	::lNew				:= hb_DefaultValue( lNew, .t. )
	::lDeleted			:= hb_DefaultValue( lDeleted, .f. )
	
	::_dDate			:= hb_DefaultValue( dDate, sys_date )
	::_nIDOper			:= hb_DefaultValue( nIDUser, currentuser():ID() )
	::_nTask			:= hb_DefaultValue( nTask, 0 )
	::_nCharacter		:= hb_DefaultValue( nCharacter, 0 )
	::_cV0				:= hb_DefaultValue( cV0, '   ' )
	::_cVR				:= hb_DefaultValue( cVR, '   ' )
	::_cVK				:= hb_DefaultValue( cVK, '   ' )
	::_cVU				:= hb_DefaultValue( cVU, '   ' )
	return self

* 
*
METHOD Save() CLASS TAudit_main
	local ret := .f.
	local aHash := nil
	local llen := 6
	
	&& aHash := hb_Hash()
	&& hb_HAutoAdd( aHash, HB_HAUTOADD_ALWAYS )
	&& hb_hSet(aHash, 'PD',		dtoc4( ::_dDate ) )
	&& hb_hSet(aHash, 'PO',		chr( ::_nIDOper ) )
	&& hb_hSet(aHash, 'PT',		chr( ::_nTask ) )
	&& hb_hSet(aHash, 'TP',		chr( ::_nType ) )
	&& hb_hSet(aHash, 'AE',		chr( ::_nWork ) )
    && hb_hSet(aHash, 'KK',		ft_sqzn( ::_nQuantity, llen ) )		// ft_sqzn(_kk + ft_unsqzn(op->kk,llen), llen)
    && hb_hSet(aHash, 'KP',		ft_sqzn( ::_nField, llen ) )		// ft_sqzn(_kp + ft_unsqzn(op->kp,llen), llen)
	&& hb_hSet(aHash, 'ID',		::nID )
	&& hb_hSet(aHash, 'REC_NEW',	::lNew )
	&& hb_hSet(aHash, 'DELETED',	::lDeleted )
	&& ret := ::super:Save( aHash )
	return ret



METHOD FillFromHash( hbArray )     CLASS TAudit_main
	local obj
	local llen := 6
	
	&& obj := TAudit_main():New( hbArray[ 'ID' ], ;
			&& c4tod( hbArray[ 'PD' ] ), ;
			&& asc( hbArray[ 'PO' ] ), ;
			&& asc( hbArray[ 'PT' ] ), ;
			&& asc( hbArray[ 'TP' ] ), ;
			&& asc( hbArray[ 'AE' ] ), ;
			&& ft_unsqzn( hbArray[ 'KK' ], llen ), ;
			&& ft_unsqzn( hbArray[ 'KP' ], llen ), ;
			&& hbArray[ 'REC_NEW' ], ;
			&& hbArray[ 'DELETED' ] ;
			&& )
	return obj	

