#include 'function.ch'
#include 'chip_mo.ch'

#include 'hbclass.ch'
#include 'hbhash.ch' 
#include 'common.ch'
#include 'property.ch'

// Файл 'organiz.dbf'
CREATE CLASS TOrganizationDB	INHERIT	TBaseObjectDB
	VISIBLE:
		METHOD New()
		METHOD Save( oOrganization )
		METHOD geTOrganization()
	HIDDEN:
		METHOD FillFromHash( hbArray )
ENDCLASS

METHOD New()		CLASS TOrganizationDB
	return self

METHOD geTOrganization()     CLASS TOrganizationDB
	
	local hArray := nil
	local ret := nil
	
	// берем 1 запись
	if !empty( hArray := ::super:getById( 1 ) )
		ret := ::FillFromHash( hArray )
		self := ret
	endif
	return ret

METHOD Save( oOrganization ) CLASS TOrganizationDB
	
	local ret := .F.
	local aHash := Nil
	
	if upper( oRoleUser:classname() ) == upper( 'TOrganization' )
		aHash := hb_Hash()
		hb_HAutoAdd( aHash, HB_HAUTOADD_ALWAYS )
		hb_hSet(aHash, 'KOD_TFOMS',		oOrganization:Kod_Tfoms )
		hb_hSet(aHash, 'NAME_TFOMS',	oOrganization:Name_Tfoms )
		hb_hSet(aHash, 'UROVEN',		oOrganization:Uroven )
		hb_hSet(aHash, 'NAME',			oOrganization:Name )
		hb_hSet(aHash, 'NAME_SCHET',	oOrganization:Name_schet )
		if len( oOrganization:INN ) == 0
			hb_hSet(aHash, 'INN',			oOrganization:INN )
		else
			hb_hSet(aHash, 'INN',			alltrim( oOrganization:INN ) + '/' + alltrim( oOrganization:KPP ) )
		endif
		hb_hSet(aHash, 'ADRES',			oOrganization:Address )
		hb_hSet(aHash, 'TELEFON',		oOrganization:Phone )
		
		hb_hSet(aHash, 'OKONH',			oOrganization:Okonh )
		hb_hSet(aHash, 'OKPO',			oOrganization:Okpo )
		hb_hSet(aHash, 'E_1',			oOrganization:E_1 )
		
		hb_hSet(aHash, 'BANK',			oOrganization:Bank:Bank() )
		hb_hSet(aHash, 'R_SCHET',		oOrganization:Bank:RShet() )
		hb_hSet(aHash, 'K_SCHET',		oOrganization:Bank:KSchet() )
		hb_hSet(aHash, 'SMFO',			oOrganization:Bank:BIK() )
		hb_hSet(aHash, 'BANK2',			oOrganization:BankSecond:Bank() )
		hb_hSet(aHash, 'R_SCHET2',		oOrganization:BankSecond:RShet() )
		hb_hSet(aHash, 'K_SCHET2',		oOrganization:BankSecond:KSchet() )
		hb_hSet(aHash, 'SMFO2',			oOrganization:BankSecond:BIK() )
		
		hb_hSet(aHash, 'OGRN',			oOrganization:Ogrn )
		hb_hSet(aHash, 'RUK_FIO',		oOrganization:Ruk_fio )
		hb_hSet(aHash, 'RUK',			oOrganization:Ruk )
		hb_hSet(aHash, 'RUK_R',			oOrganization:Ruk_r )
		hb_hSet(aHash, 'BUX',			oOrganization:Bux )
		hb_hSet(aHash, 'ISPOLNIT',		oOrganization:Ispolnit )
		hb_hSet(aHash, 'NAME_D',		oOrganization:Name_d )
		hb_hSet(aHash, 'FILIAL_H',		oOrganization:Filial_h )
		
		hb_hSet(aHash, 'ID',			oOrganization:ID )
		hb_hSet(aHash, 'REC_NEW',		oOrganization:IsNew )
		hb_hSet(aHash, 'DELETED',		oOrganization:IsDeleted )
		ret := ::Super:Save( aHash )
		if ( ret := ::super:Save( aHash ) ) != -1
			oOrganization:ID := ret
			oOrganization:IsNew := .f.
		endif
	endif
	return ret
	
METHOD FillFromHash( hbArray )     CLASS TOrganizationDB
	
	local obj
	local pos

	
	obj := TOrganization():New( hbArray[ 'ID' ], ;
		hbArray[ 'REC_NEW' ], ;
		hbArray[ 'DELETED' ], ;
	)
	obj:Kod_Tfoms := left(hbArray[ 'KOD_TFOMS' ], 6)
	obj:Name_Tfoms := hbArray[ 'NAME_TFOMS' ]
	obj:Uroven := hbArray[ 'UROVEN' ]
	obj:Name := hbArray[ 'NAME' ]
	obj:Name_schet := hbArray[ 'NAME_SCHET' ]

	pos := hb_At( '/', hbArray[ 'INN' ] )
	if pos == 0
		obj:INN := hbArray[ 'INN' ]
		obj:KPP := ''
	else
		obj:INN := substr( hbArray[ 'INN' ], 1, pos - 1)
		obj:KPP := substr( hbArray[ 'INN' ], pos + 1 )
	endif

	obj:Address := hbArray[ 'ADRES' ]
	obj:Phone := hbArray[ 'TELEFON' ]

	obj:OKONH := hbArray[ 'OKONH' ]
	obj:OKPO := hbArray[ 'OKPO' ]
	obj:E_1 := hbArray[ 'E_1' ]
	obj:Name2 := hbArray[ 'NAME2' ]
	obj:OGRN := hbArray[ 'OGRN' ]
	obj:Ruk_fio := hbArray[ 'RUK_FIO' ]
	obj:Ruk := hbArray[ 'RUK' ]
	obj:Ruk_r := hbArray[ 'RUK_R' ]
	obj:Bux := hbArray[ 'BUX' ]
	obj:Ispolnit := hbArray[ 'ISPOLNIT' ]
	obj:Name_d := hbArray[ 'NAME_D' ]
	obj:Filial_h := hbArray[ 'FILIAL_H' ]
	obj:Bank := TBank():New( hbArray[ 'BANK' ], hbArray[ 'R_SCHET' ], hbArray[ 'K_SCHET' ], hbArray[ 'SMFO' ] )
	obj:BankSecond := TBank():New( hbArray[ 'BANK2' ], hbArray[ 'R_SCHET2' ], hbArray[ 'K_SCHET2' ], hbArray[ 'SMFO2' ] )
	return obj