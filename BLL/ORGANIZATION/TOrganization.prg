#include 'hbclass.ch'
#include 'hbhash.ch' 
#include 'property.ch'

// Файл 'organiz.dbf'
CREATE CLASS TOrganization	INHERIT	TBaseObjectBLL
	VISIBLE:
		PROPERTY Kod_Tfoms READ getKod_Tfoms WRITE setKod_Tfoms		// Регистрационный код МО в ТФОМС
		PROPERTY Name_Tfoms READ getName_Tfoms WRITE setName_Tfoms   // Наименование (в ТФОМС)
		PROPERTY Name_Tfoms1251 READ getName_Tfoms1251
		PROPERTY Uroven READ getUroven WRITE setUroven               // Уровень цен МО
		PROPERTY Name READ getName WRITE setName                     // Название
		PROPERTY Name1251 READ getName1251
		PROPERTY Name_schet READ getName_schet WRITE setName_schet   // Название для счёта
		PROPERTY Name_schet1251 READ getName_schet1251
		PROPERTY INN READ getINN WRITE setINN						// ИНН/КПП
		PROPERTY Address READ getAddress WRITE setAddress			// Адрес
		PROPERTY Address1251 READ getAddress1251
		PROPERTY Phone READ getPhone WRITE setPhone					// Телефон

		PROPERTY OKONH READ getOKONH WRITE setOKOPNH					// Код по ОКОНХ
		PROPERTY OKPO READ getOKPO WRITE setOKPO						// Код по ОКПО
		PROPERTY E_1 READ getE_1 WRITE setE_1						// Банковские реквизиты для перечисления доплат из средств субсидий ФФОМС:
		PROPERTY Name2 READ getName2 WRITE setName2					// - название
		PROPERTY Name2_1251 READ getName2_1251
		PROPERTY OGRN READ getOGRN WRITE setOGRN						// ОГРН ЛПУ
		PROPERTY Ruk_fio READ getRuk_fio WRITE setRuk_fio			// Ф.И.О. главного врача
		PROPERTY Ruk_fio1251 READ getRuk_fio1251
		PROPERTY Ruk READ getRuk WRITE setRuk						// Фамилия и инициалы главного врача (им.падеж)
		PROPERTY Ruk1251 READ getRuk1251
		PROPERTY Ruk_r READ getRuk_r WRITE setRuk_r					// Фамилия и инициалы главного врача (род.падеж)
		PROPERTY Ruk_r1251 READ getRuk_r1251
		PROPERTY Bux READ getBux WRITE setBux						// Фамилия и инициалы главного бухгалтера
		PROPERTY Bux1251 READ getBux1251
		PROPERTY Ispolnit READ getIspolnit WRITE setIspolnit			// Ф.И.О. исполнителя для счетов ОМС
		PROPERTY Ispolnit1251 READ getIspolnit1251
		PROPERTY Name_d READ getName_d WRITE setName_d				// Наименование орг-ии (для договора)
		PROPERTY Name_d1251 READ getName_d1251
		PROPERTY Filial_h READ getFilial_h WRITE setFilial_h			// Филиал ТФОМС, в который отправляется файл с ходатайствами
		PROPERTY Bank READ getBank WRITE setBank						// банк
		PROPERTY BankSecond READ getBankSecond WRITE setBankSecond	// банк 2
		
		METHOD New( nId, lNew, lDeleted )

	HIDDEN:
		DATA FKod_Tfoms			INIT space( 8 )
		DATA FName_Tfoms		INIT space( 60 )
		DATA FUroven			INIT 0
		DATA FName				INIT space( 130 )
		DATA FName_schet		INIT space( 130 )
		DATA FINN				INIT space( 20 )
		DATA FAddress			INIT space( 70 )
		DATA FPhone				INIT space( 20 )
		DATA FOkonh				INIT space( 15 )
		DATA FOkpo				INIT space( 15 )
		DATA FE_1				INIT space( 1 )
		DATA FName2				INIT space( 130 )
		DATA FOgrn				INIT space( 15 )
		DATA FRuk_fio			INIT space( 60 )
		DATA FRuk				INIT space( 20 )
		DATA FRuk_r				INIT space( 20 )
		DATA FBux				INIT space( 20 )
		DATA FIspolnit			INIT space( 20 )
		DATA FName_d			INIT space( 32 )
		DATA FFilial_h			INIT 0
		DATA FBank				INIT nil				
		DATA FBankSecond		INIT nil             
		
		&& METHOD FillFromHash( hbArray )
		METHOD getKod_Tfoms
		METHOD setKod_Tfoms( cVal )
		METHOD getName_Tfoms
		METHOD getName_Tfoms1251
		METHOD setName_Tfoms( cVal )
		METHOD getUroven
		METHOD setUroven( nVal )
		METHOD getName
		METHOD getName1251
		METHOD setName( cVal )
		METHOD getName_schet
		METHOD getName_schet1251
		METHOD setName_schet( cVal )
		METHOD getINN
		METHOD setINN( cVal )
		METHOD getAddress
		METHOD getAddress1251
		METHOD setAddress( cVal )
		METHOD getPhone
		METHOD setPhone( cVal )
		METHOD getOKONH
		METHOD setOKOPNH( cVal )
		METHOD getOKPO
		METHOD setOKPO( cVal )
		METHOD getE_1
		METHOD setE_1( cVal )
		METHOD getName2
		METHOD setName2( cVal )
		METHOD getName2_1251
		METHOD getOGRN
		METHOD setOGRN( cVal )
		METHOD getRuk_fio
		METHOD setRuk_fio( cVal )
		METHOD getRuk_fio1251
		METHOD getRuk
		METHOD setRuk( cVal )
		METHOD getRuk1251
		METHOD getRuk_r
		METHOD setRuk_r( cVal )
		METHOD getRuk_r1251
		METHOD getBux
		METHOD setBux( cVal )
		METHOD getBux1251
		METHOD getIspolnit
		METHOD setIspolnit( cVal )
		METHOD getIspolnit1251
		METHOD getName_d
		METHOD setName_d( cVal )
		METHOD getName_d1251
		METHOD getFilial_h
		METHOD setFilial_h( nVal )
		METHOD getBank
		METHOD setBank( obj )
		METHOD getBankSecond
		METHOD setBankSecond( obj )
		
ENDCLASS

METHOD function  getINN						CLASS TOrganization
	return ::FINN
	
METHOD procedure setINN( cVal )				CLASS TOrganization
	::FINN := cVal
	return

METHOD FUNCTION getKod_Tfoms					CLASS TOrganization
	return ::FKod_Tfoms

METHOD PROCEDURE setKod_Tfoms( cVal )		CLASS TOrganization
	::FKod_Tfoms := cVal
	return

METHOD FUNCTION getName_Tfoms					CLASS TOrganization
	return ::FName_Tfoms

METHOD FUNCTION getName_Tfoms1251				CLASS TOrganization
	return win_OEMToANSI( ::FName_Tfoms )

METHOD PROCEDURE setName_Tfoms( cVal )		CLASS TOrganization
	::FName_Tfoms := cVal
	return

METHOD FUNCTION getUroven						CLASS TOrganization
	return ::FUroven

METHOD PROCEDURE setUroven( nVal )			CLASS TOrganization
	::FUroven := nVal
	return

METHOD FUNCTION getName						CLASS TOrganization
	return ::FName

METHOD FUNCTION getName1251					CLASS TOrganization
	return win_OEMToANSI( ::FName )

METHOD PROCEDURE setName( cVal )				CLASS TOrganization
	::FName := cVal
	return

METHOD FUNCTION getName_schet					CLASS TOrganization
	return ::FName_schet

METHOD FUNCTION getName_schet1251				CLASS TOrganization
	return win_OEMToANSI( ::FName_schet )

METHOD PROCEDURE setName_schet( cVal )		CLASS TOrganization
	::FName_schet := cVal
	return

METHOD FUNCTION getAddress					CLASS TOrganization
	return ::FAddress

METHOD FUNCTION getAddress1251				CLASS TOrganization
	return win_OEMToANSI( ::FAddress )

METHOD PROCEDURE setAddress( cVal )			CLASS TOrganization
	::FAddress := cVal
	return

METHOD FUNCTION getPhone						CLASS TOrganization
	return ::FPhone

METHOD PROCEDURE setPhone( cVal )			CLASS TOrganization
	::FPhone := cVal
	return

METHOD FUNCTION getOKONH						CLASS TOrganization
	return ::FOkonh

METHOD PROCEDURE setOKOPNH( cVal )			CLASS TOrganization
	::FOkonh := cVal
	return

METHOD FUNCTION getOKPO						CLASS TOrganization
	return ::FOkpo

METHOD PROCEDURE setOKPO( cVal )				CLASS TOrganization
	::FOkpo := cVal
	return

METHOD FUNCTION getE_1							CLASS TOrganization
	return ::FE_1

METHOD PROCEDURE setE_1( cVal )				CLASS TOrganization
	::FE_1 := cVal
	return

METHOD FUNCTION getName2						CLASS TOrganization
	return ::FName2

METHOD PROCEDURE setName2( cVal )			CLASS TOrganization
	::FName2 := cVal
	return

METHOD FUNCTION getName2_1251					CLASS TOrganization
	return win_OEMToANSI( ::FName2 )

METHOD FUNCTION getOGRN						CLASS TOrganization
	return ::FOgrn

METHOD PROCEDURE setOGRN( cVal )				CLASS TOrganization
	::FOgrn := cVal
	return

METHOD FUNCTION getRuk_fio					CLASS TOrganization
	return ::FRuk_fio

METHOD PROCEDURE setRuk_fio( cVal )			CLASS TOrganization
	::FRuk_fio := cVal
	return

METHOD FUNCTION getRuk_fio1251				CLASS TOrganization
	return win_OEMToANSI( ::FRuk_fio )

METHOD FUNCTION getRuk						CLASS TOrganization
	return ::FRuk

METHOD PROCEDURE setRuk( cVal )				CLASS TOrganization
	::FRuk := cVal
	return

METHOD FUNCTION getRuk1251					CLASS TOrganization
	return win_OEMToANSI( ::FRuk )

METHOD FUNCTION getRuk_r						CLASS TOrganization
	return ::FRuk_r

METHOD PROCEDURE setRuk_r( cVal )			CLASS TOrganization
	::FRuk_r := cVal
	return

METHOD FUNCTION getRuk_r1251					CLASS TOrganization
	return win_OEMToANSI( ::FRuk_r )

METHOD FUNCTION getBux						CLASS TOrganization
	return ::FBux

METHOD PROCEDURE setBux( cVal )				CLASS TOrganization
	::FBux := cVal
	return

METHOD FUNCTION getBux1251					CLASS TOrganization
	return win_OEMToANSI( ::FBux )

METHOD FUNCTION getIspolnit					CLASS TOrganization
	return ::FIspolnit

METHOD PROCEDURE setIspolnit( cVal )			CLASS TOrganization
	::FIspolnit := cVal
	return

METHOD FUNCTION getIspolnit1251				CLASS TOrganization
	return win_OEMToANSI( ::FIspolnit )

METHOD FUNCTION getName_d						CLASS TOrganization
	return ::FName_d

METHOD PROCEDURE setName_d( cVal )			CLASS TOrganization
	::FName_d := cVal
	return

METHOD FUNCTION getName_d1251					CLASS TOrganization
	return win_OEMToANSI( ::FName_d )

METHOD FUNCTION getFilial_h					CLASS TOrganization
	return ::FFilial_h
	
METHOD PROCEDURE setFilial_h( nVal )			CLASS TOrganization
	::FFilial_h := nVal
	return

METHOD FUNCTION getBank						CLASS TOrganization
	return ::FBank

METHOD PROCEDURE setBank( obj )				CLASS TOrganization
	::FBank := obj
	return

METHOD FUNCTION getBankSecond					CLASS TOrganization
	return ::FBankSecond

METHOD PROCEDURE setBankSecond( obj )		CLASS TOrganization
	::FBankSecond := obj
	return
					
METHOD New( nId, lNew, lDeleted )		CLASS TOrganization
			
	::FNew						:= hb_defaultValue( lNew, .t. )
	::FDeleted					:= hb_defaultValue( lDeleted, .f. )
	::FID						:= hb_defaultValue( nID, 0 )
	return self