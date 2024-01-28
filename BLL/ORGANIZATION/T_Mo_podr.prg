#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'property.ch'
#include 'common.ch'
#include 'chip_mo.ch'

********************************
// класс для справочник подразделений из паспорта ЛПУ _mo_podr.dbf
CREATE CLASS T_Mo_podr	INHERIT	TBaseObjectBLL
	VISIBLE:
		
		PROPERTY CodeMO READ getCodeMO WRITE setCodeMO								// код
		PROPERTY Name READ getName WRITE setName								// наименование
		PROPERTY OGRN READ getOGRN WRITE setOGRN
		PROPERTY OIDMO READ getOIDMO WRITE setOIDMO				// 
		PROPERTY KodOtd READ getKodOtd WRITE setKodOtd
  
		METHOD New( nId, lNew, lDeleted )
  
	HIDDEN:                                      
		DATA FCodeMO			INIT space( 6 )
		DATA FOGRN			INIT space( 13 )
		DATA FOIDMO			INIT space( 27 )
		DATA FKodOtd		INIT space( 25 )
		DATA FName			INIT space( 76 )
		
		METHOD getCodeMO
		METHOD setCodeMO( cVal )
		METHOD getName
		METHOD setName( cVar )
		METHOD getOGRN
		METHOD setOGRN( cVal )
		METHOD getOIDMO
		METHOD setOIDMO( cVar )
		METHOD getKodOtd
		METHOD setKodOtd( cVal )
ENDCLASS

METHOD FUNCTION getCodeMO()				CLASS T_Mo_podr
	return ::FCodeMO

METHOD PROCEDURE setCodeMO( cVar )		CLASS T_Mo_podr

	::FCodeMO := cVar
	return

METHOD FUNCTION getName()					CLASS T_Mo_podr
	return ::FName

METHOD PROCEDURE setName( cVar )			CLASS T_Mo_podr

	::FName := cVar
	return

METHOD FUNCTION getOGRN()					CLASS T_Mo_podr
	return ::FOGRN

METHOD PROCEDURE setOGRN( cVar )			CLASS T_Mo_podr

	::FOGRN := cVar
	return

METHOD FUNCTION getOIDMO()				CLASS T_Mo_podr
	return ::FOIDMO

METHOD PROCEDURE setOIDMO( cVar )		CLASS T_Mo_podr

	::FOIDMO := cVar
	return

METHOD FUNCTION getKodOtd()				CLASS T_Mo_podr
	return ::FKodOtd

METHOD PROCEDURE setKodOtd( cVar )		CLASS T_Mo_podr

	::FKodOtd := cVar
	return

METHOD New( nId, lNew, lDeleted )		CLASS T_Mo_podr
			
	::FNew 						:= hb_defaultValue( lNew, .t. )
	::FDeleted					:= hb_defaultValue( lDeleted, .f. )
	::FID						:= hb_defaultValue( nID, 0 )
	return self