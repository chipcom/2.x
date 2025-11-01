#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'common.ch'
#include 'property.ch'

// класс для 'mo_opern.dbf'
CREATE CLASS TAuditDB	INHERIT	TBaseObjectDB
	VISIBLE:
		METHOD New()
		METHOD getByParam( date, idOperator, typeTask, typeCard, action )
		METHOD Save( oAudit )
	HIDDEN:
		METHOD FillFromHash( hbArray )
END CLASS

METHOD New() CLASS TAuditDB
	return self

METHOD getByParam( date, idUser, typeTask, typeCard, action ) CLASS TAuditDB

	local cFind := '', hArray
	local cOldArea, cAudit, obj := nil

	hb_Default( @typeTask, 1 )
	cFind := dtoc4( date ) + chr( idUser ) + chr( typeTask ) + chr( typeCard ) + chr( action )
	// найдем запись для работы оператора
	cOldArea := Select()
	if ::super:RUse()
		cAudit := Select()
		(cAudit)->(dbSetOrder( 1 ))
		if (cAudit)->(dbSeek( cFind ))
			if ! empty( hArray := ::super:currentRecord() )
				obj := ::FillFromHash( hArray )
			endif
		endif
		(cAudit)->( dbCloseArea() )
		dbSelectArea( cOldArea )
	endif
	return obj

//
METHOD Save( oAudit ) CLASS TAuditDB
	
	local ret := .f.
	local aHash := nil
	local llen := 6

	if upper( oAudit:classname() ) == upper( 'TAudit' )
		aHash := hb_Hash()
		hb_HAutoAdd( aHash, HB_HAUTOADD_ALWAYS )
		hb_hSet(aHash, 'PD',		dtoc4( oAudit:Date ) )					// дата ввода c4tod(pd)
		hb_hSet(aHash, 'PO',		chr( if( isnil( oAudit:Operator ), 0, oAudit:Operator:ID ) ) )	// код оператора asc(po)
		hb_hSet(aHash, 'PT',		chr( oAudit:Task ) )						// код задачи
		hb_hSet(aHash, 'TP',		chr( oAudit:Type ) )						// тип (1-карточка, 2-л/у, 3-услуги)
		hb_hSet(aHash, 'AE',		chr( oAudit:Work ) )						// 1-добавление, 2-редактирование, 3-удаление
		hb_hSet(aHash, 'KK',		ft_sqzn( oAudit:Quantity, llen ) )		// кол-во (карточек, л/у или услуг)
		hb_hSet(aHash, 'KP',		ft_sqzn( oAudit:Field, llen ) )			// количество введённых полей
		hb_hSet(aHash, 'ID',		oAudit:ID )
		hb_hSet(aHash, 'REC_NEW',	oAudit:IsNew )
		hb_hSet(aHash, 'DELETED',	oAudit:IsDeleted )
		if ( ret := ::super:Save( aHash ) ) != -1
			oAudit:ID := ret
			oAudit:IsNew := .f.
		endif
	endif
	return ret
	
METHOD FillFromHash( hbArray )     CLASS TAuditDB
	
	local obj
	local llen := 6
	
	obj := TAudit():New( hbArray[ 'ID' ], ;
			hbArray[ 'REC_NEW' ], ;
			hbArray[ 'DELETED' ] ;
			)
	obj:Date := c4tod( hbArray[ 'PD' ] )
	obj:Operator := asc( hbArray[ 'PO' ] )
	obj:Task := asc( hbArray[ 'PT' ] )
	obj:Type := asc( hbArray[ 'TP' ] )
	obj:Work := asc( hbArray[ 'AE' ] )
	obj:Quantity := ft_unsqzn( hbArray[ 'KK' ], llen )
	obj:Field := ft_unsqzn( hbArray[ 'KP' ], llen )
	return obj	

// класс для 'mo_oper.dbf'
CREATE CLASS TAudit_mainDB	INHERIT	TBaseObjectDB
	VISIBLE:
	
		METHOD New()
		METHOD Save( object )
	HIDDEN:
		METHOD FillFromHash( hbArray )
END CLASS

METHOD New() CLASS TAudit_mainDB
	return self

METHOD Save() CLASS TAudit_mainDB

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

METHOD FillFromHash( hbArray )     CLASS TAudit_mainDB

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
	&& obj := TAudit_main():New( hbArray[ 'ID' ], ;
			&& hbArray[ 'REC_NEW' ], ;
			&& hbArray[ 'DELETED' ] ;
			&& )
	&& obj:Date := c4tod( hbArray[ 'PD' ] ), ;
	&& obj:Operator := asc( hbArray[ 'PO' ] ), ;
	&& obj:Task := asc( hbArray[ 'PT' ] ), ;
	&& obj: := asc( hbArray[ 'TP' ] ), ;
	&& obj: := asc( hbArray[ 'AE' ] ), ;
	&& obj: := ft_unsqzn( hbArray[ 'KK' ], llen ), ;
	&& obj: := ft_unsqzn( hbArray[ 'KP' ], llen ), ;
	return obj