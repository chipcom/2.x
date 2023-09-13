#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'common.ch'
#include 'property.ch'

// Префиксы имен
// c - строка
// n - число
// l - логическое
// b - блок кода
// a - массив
// h - хэш-массив
// o - объект
//***
 
// Хранится в файле 'Base1.dbf'
CREATE CLASS TUser	INHERIT	TBaseObjectBLL
	VISIBLE:
		PROPERTY FIO WRITE setFIO INIT space( 20 )					//	{"P1", "C", 20, 0},; // Ф.И.О.
		PROPERTY Access WRITE setAccess INIT 0						//	{"P2", "N",  1, 0},; // тип доступа
		PROPERTY Password WRITE setPassword INIT space( 10 )			//	{"P3", "C", 10, 0},; // пароль
		PROPERTY Position WRITE setPosition INIT space( 20 )			//	{"P5", "C", 20, 0},; // должность
		PROPERTY KEK WRITE setKEK INIT 0							//	{"P6", "N",  1, 0},; // Группа КЭК (1-3)
		PROPERTY PasswordFR WRITE setPasswordFR INIT 0				//	{"P7", "C", 10, 0},; // пароль1 для фискального регистратора
		PROPERTY PasswordFRSuper WRITE setPasswordFRSuper INIT 0	//	{"P8", "C", 10, 0};  // пароль2 для фискального регистратора
		PROPERTY INN AS STRING READ getINN WRITE setINN
		PROPERTY IDRole WRITE setIDRole INIT 0						//	{"IDROLE", "N",  4, 0},; // ID группы пользователей

		PROPERTY Dov_Date READ getDov_Date WRITE setDov_Date
		PROPERTY Dov_Nom READ getDov_Nom WRITE setDov_Nom
		
		PROPERTY Name READ getName WRITE setFIO
		PROPERTY Name1251 READ getName1251
		PROPERTY FIO1251 READ getName1251
		PROPERTY Department READ getDepartment
		PROPERTY Position1251 READ getPosition1251
		
		PROPERTY DepShortName READ getDepShortName
		PROPERTY Type_F READ getTypeFormat

		PROPERTY IsSuperUser READ getSuperUser WRITE setSuperUser

		CLASSDATA	aMenuType	AS ARRAY	INIT { { 'АДМИНИСТРАТОР',  0 }, ;
													{ 'ОПЕРАТОР     ', 1 }, ;
													{ 'КОНТРОЛЕР    ', 3 } }
										
		METHOD IsAdmin()					INLINE iif(( ::FAccess + 1 ) == 1, .t., .f. )
		METHOD IsOperator()				INLINE iif(( ::FAccess + 1 ) == 2, .t., .f. )
		METHOD IsKontroler()			INLINE iif(( ::FAccess + 1 ) == 3, .t., .f. )
					
		METHOD IsAllowedDepartment( nSub )
		METHOD IsAllowedTask( nTask )
		METHOD IDDepartment( Param )
		
		METHOD New( nID, cFIO, nAccess, cPassword, cDepartment, cPosition, nKEK, ;
					cPasswordFR, cPasswordFRSuper, nIdRole, lNew, lDeleted )
	HIDDEN:
		CLASSDATA	aType	AS ARRAY	INIT { 'АДМИНИСТРАТОР', ;
										   'ОПЕРАТОР     ', ;
										   '             ', ;
										   'КОНТРОЛЕР    ' }
		DATA FDepartment		INIT nil
		DATA FRole				INIT nil
		DATA FACLDep 			INIT space( 255 )	//	доступ к учреждениям, по умолчанию '*' все
		DATA FACLTask			INIT space( 255 )	//	доступ к задачам, по умолчанию '*' все
		DATA FINN					INIT space( 12 )
		DATA FSuper				INIT .f.					// установить(получить), что это суперпользователь
		DATA FDov_Nom			INIT space(20)
		DATA FDov_Date		INIT ctod('')
		
		VAR _department	 		AS CHARACTER	INIT chr( 0 )		//	{"P4", "C",  1, 0},; // код отделения [ chr(kod) ]
		
		METHOD setFIO( cText )
		METHOD setAccess( nAccess )
		METHOD setPassword( cText )
		METHOD setPosition( cText )
		METHOD setKEK( nKEK )
		METHOD setPasswordFR( nPassword )
		METHOD setPasswordFRSuper( nPassword )
		METHOD setIDRole( nID )
		METHOD getName
		METHOD getName1251
		METHOD getPosition1251
		METHOD getDepartment
		METHOD getINN
		METHOD setINN( param )
		METHOD getDov_Date
		METHOD setDov_Date( param )
		METHOD getDov_Nom
		METHOD setDov_Nom( param )
		METHOD getSuperUser
		METHOD setSuperUser( param )
		
		METHOD getDepShortName
		METHOD getTypeFormat
END CLASS

METHOD function getSuperUser()			CLASS TUser
return ::FSuper

METHOD procedure setSuperUser( param )	CLASS TUser

	if islogical( param )
		::FSuper := param
	endif
	return

METHOD function getINN()			CLASS TUser
	return ::FINN

METHOD procedure setINN( param )	CLASS TUser

	if ischaracter( param )
		::FINN := param
	endif
	return

METHOD function getDov_Date()			CLASS TUser
	return ::FDov_Date

METHOD procedure setDov_Date( param )	CLASS TUser

	if isdate( param )
		::FDov_Date := param
	endif
	return

METHOD function getDov_Nom()			CLASS TUser
	return ::FDov_Nom

METHOD procedure setDov_Nom( param )	CLASS TUser

	if ischaracter( param )
		::FDov_Nom := param
	endif
	return

METHOD FUNCTION getTypeFormat()	CLASS TUser
	return ::aType[ ::FAccess + 1 ]

METHOD FUNCTION getDepShortName()	CLASS TUser
	local ret := ''
	
	if ! isnil( ::FDepartment )
		ret := ::FDepartment:ShortName
	endif
	return ret

METHOD FUNCTION getDepartment()	CLASS TUser
	&& return TDepartmentDB():getById( asc( ::_department ) )
	return ::FDepartment

METHOD FUNCTION getName()	CLASS TUser
	return ::FFIO

METHOD FUNCTION getName1251()	CLASS TUser
	return win_OEMToANSI( ::FFIO )

METHOD FUNCTION getPosition1251()	CLASS TUser
	return win_OEMToANSI( ::FPosition )

METHOD PROCEDURE setIDRole( nID )	CLASS TUser
	::FIDRole := nID
	return

METHOD PROCEDURE setFIO( cText )	CLASS TUser
	::FFIO := left( cText, 20 )
	return

METHOD PROCEDURE setAccess( nAccess )	CLASS TUser
	::FAccess := nAccess
	return

METHOD PROCEDURE setPassword( cText )	CLASS TUser
	::FPassword := left( cText, 10 )
	return

METHOD PROCEDURE setKEK( nKEK )	CLASS TUser
	::FKEK := nKEK
	return

METHOD PROCEDURE setPasswordFR( nPassword )	CLASS TUser
	::FPasswordFR := nPassword
	return

METHOD PROCEDURE setPasswordFRSuper( nPassword )	CLASS TUser
	::FPasswordFRSuper := nPassword
	return

METHOD PROCEDURE setPosition( cText )	CLASS TUser
	::FPosition := left( cText, 20 )
	return
	
***********************************
* Создать новый объект TUser
METHOD New( nID, cFIO, nAccess, cPassword, cDepartment, cPosition, nKEK, ;
			cPasswordFR, cPasswordFRSuper, nIdRole, lNew, lDeleted ) CLASS TUser
	local cRegEx := '[-+]?[0-9]*[.,]?[0-9]+'			// допустимы только цифровые символы
	local tmpPassFR, tmpPassFRSuper
	
	::super:new( nID, lNew, lDeleted )

	::FFIO			:= HB_DefaultValue( cFIO, space( 20 ) )		// ФИО
	::FAccess		:= hb_DefaultValue( nAccess, 0 )			// тип доступа
	::FPassword		:= HB_DefaultValue( cPassword, space( 10 ) )	// пароль
	::_department	:= HB_DefaultValue( cDepartment, ' ' )		// код отделения [ chr(kod) ]
	::FPosition		:= HB_DefaultValue( cPosition, space( 20 ) ) // должность
	::FKEK			:= hb_DefaultValue( nKek, 0 )				// Группа КЭК (1-3)
	
	tmpPassFR		:= alltrim( HB_DefaultValue( cPasswordFR, space( 10 ) ) )
	tmpPassFRSuper	:= alltrim( HB_DefaultValue( cPasswordFRSuper, space( 10 ) ) )
	
	::FDepartment := TDepartmentDB():getById( asc( ::_department ) )
	::FIDRole		:= hb_DefaultValue( nIdRole, 0 )
	::FRole := TRoleUserDB():GetByID( ::FIDRole )
	
	if !empty( cPasswordFR ) .and. hb_RegexLike( cRegEx, tmpPassFR )
		::FPasswordFR		:= iif( ::FNew, cPasswordFR, int( val( tmpPassFR ) ) )			// пароль1 для фискального регистратора
	endif
	if !empty( cPasswordFRSuper ) .and. hb_RegexLike( cRegEx, tmpPassFRSuper )
		::FPasswordFRSuper	:= iif( ::FNew, cPasswordFRSuper, int( val( tmpPassFRSuper ) ) )	// пароль2 для фискального регистратора
	endif
	
	if ! isnil( ::FRole )
		::FACLTask	:= ::FRole:ACLTask
		::FACLDep	:= ::FRole:ACLDep
	endif
	if ! ( ::FNew ) .and. ( ::FID == 0 )		// служебный пользователь со спец паролем
		return ret
	endif
	return self                  

METHOD IDDepartment( Param )		 CLASS TUser
	local ret := 0
	
	if pcount() > 0
		::_department := chr( param )
		::FDepartment := TDepartmentDB():getById( param )
	else
		ret := asc( ::_department )
	endif
	return ret

***********************************
* Проверка допустимости работы с отделением
* Параметры:
* 	nSub - код отделения ( Subdivision )
* Возврат:
*	.t. - работа допустима, .f. - работа не допустима
METHOD IsAllowedDepartment( nSub ) CLASS TUser
	local ret := .f., k
	local ch

	if !::IsAdmin()
		if empty( ::FACLDep )
			return .t.
		endif
		ret := HasNumberInString( nSub, ::FACLDep )
	else
		ret := .t.
	endif
	return ret

***********************************
* Проверка допустимости работы с задачей
* Параметры:
* 	nTask - код задачи ( Subdivision )
* Возврат:
*	.t. - работа в задаче допустима, .f. - работа в задаче не допустима
METHOD IsAllowedTask( nTask ) CLASS TUser
	local ret := .F., k

	if !::IsAdmin()
		if empty( ::FACLTask )
			return .t.
		endif
		ret := HasNumberInString( nTask, ::FACLTask )
	else
		ret := .t.
	endif
	return ret