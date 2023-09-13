#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'common.ch'
#include 'property.ch'
#include 'function.ch'

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
CREATE CLASS TUserDB	INHERIT	TBaseObjectDB
	VISIBLE:
					
		METHOD getByID ( nID )
		METHOD getByPassword ( cPass )
		METHOD getList ( )
		METHOD getListUsersByRole( nId )
		METHOD cryptoKey()
		
		METHOD New()
		METHOD Delete( oUser )
		METHOD Save( oUser )
	HIDDEN:
		METHOD InnerPassword( k )
		
		METHOD FillFromHash( hbArray )
END CLASS

//

METHOD New() CLASS TUserDB
	return self

// поиск объекта TUserDB по паролю
//
METHOD getByPassword ( cPass )		 CLASS TUserDB
	local cOldArea, user
	local ret := nil
	local hArray := nil
	local tUser := nil
	
	if empty( cPass )
		Return ret
	endif
	
	if ascan( ::InnerPassword(), crypt( cPass, ::cryptoKey() ) ) != 0
		tUser := TUser():New(, 'Администратор')
		tUser:IsSuperUser := .t.
		tUser:Access := 0
		return tUser
	endif
	cPass := padr( crypt( cPass, ::cryptoKey() ), 10 )
	cOldArea := Select( )
	if ::super:RUse()
		user := Select( )
		LOCATE FOR (user)->P3 == cPass .and. !empty( (user)->P1 )
		if (user)->( found() )
			if !empty( hArray := ::super:currentRecord() )
				ret := ::FillFromHash( hArray )
			endif
		endif
		(user)->( dbCloseArea() )
		dbSelectArea( cOldArea )
	endif
	return ret

// получить пользователя по ID
//
METHOD getByID ( nID )		 CLASS TUserDB
	local ret := nil, hArray := nil
	
	if ( nID != 0 ) .and. !empty( hArray := ::super:getById( nID ) )
		ret := ::FillFromHash( hArray )
	endif
	return ret

// получить список пользователей системы
//	
METHOD getList ( )		 CLASS TUserDB
	local aUser := {}
	local xValue := nil
	
	for each xValue in ::super:GetList( )
		if !xValue[ 'DELETED' ]
			aadd( aUser, ::FillFromHash( xValue ) )
		endif
	next
	return aUser

METHOD getListUsersByRole( nId )		 CLASS TUserDB
	local aUser := {}
	local xValue := nil

	for each xValue in ::super:GetList( )
		if !xValue[ 'DELETED' ] .and. xValue[ 'IDROLE' ] == nId
			aadd( aUser, ::FillFromHash( xValue ) )
		endif
	next
	return aUser
	
METHOD Delete( oUser ) CLASS TUserDB
	local ret := .f.
	local aHash := nil
	
	if upper( oUser:classname() ) == upper( 'TUser' ) .and. ( ! oUser:IsNew )
		ret := ::super:Delete( oUser )
	endif
	return ret

// Сохранить объект TUserDB
//
METHOD Save( oUser ) CLASS TUserDB
	local ret := .f.
	local aHash := nil
	
	if upper( oUser:classname() ) == upper( 'TUser' )
		aHash := hb_Hash()
		hb_HAutoAdd( aHash, HB_HAUTOADD_ALWAYS )
		hb_hSet(aHash, 'P1',		crypt( oUser:FIO, ::cryptoKey() ) )
		hb_hSet(aHash, 'P2',		oUser:Access )
		hb_hSet(aHash, 'P3',		crypt( oUser:Password, ::cryptoKey() ) )
		&& hb_hSet(aHash, 'P4',		oUser:Department )
		hb_hSet(aHash, 'P4',		chr( iif( isnil( oUser:Department ), 0, oUser:Department:ID ) ) )
		hb_hSet(aHash, 'P5',		crypt( oUser:Position, ::cryptoKey() ) )
		hb_hSet(aHash, 'P6',		oUser:KEK )
		hb_hSet(aHash, 'P7',		crypt( str( oUser:PasswordFR, 10 ), ::cryptoKey() ) )
		hb_hSet(aHash, 'P8',		crypt( str( oUser:PasswordFRSuper, 10 ), ::cryptoKey() ) )
		hb_hSet(aHash, 'INN',		crypt( oUser:INN, ::cryptoKey() ) )
		// hb_hSet(aHash, 'INN',		oUser:INN )
		hb_hSet(aHash, 'IDROLE',	oUser:IDRole )
		hb_hSet(aHash, 'DOV_DATA', dtos(crypt( oUser:Dov_Date, ::cryptoKey())))
		hb_hSet(aHash, 'DOV_NOM',	crypt( oUser:Dov_Nom, ::cryptoKey() ) )
		
		hb_hSet(aHash, 'ID',		oUser:ID )
		hb_hSet(aHash, 'REC_NEW',	oUser:IsNew )
		hb_hSet(aHash, 'DELETED',	oUser:IsDeleted )
		if ( ret := ::super:Save( aHash ) ) != -1
			oUser:ID := ret
			oUser:IsNew := .f.
		endif
	endif
	return ret

// составить ключ для шифрования (расшифровки)
//
METHOD cryptoKey()		 CLASS TUserDB
	local i, s := ""
	
	for i := 91 to 160 step 4
		s += chr( i )
	next
	for i := 120 to 91 step -2
		s += chr( i )
	next
	return s
	
// вернуть в массиве мой пароль в русской и английской раскладке
METHOD InnerPassword( k )		 CLASS TUserDB
	local ret := {"вЕ█╞Eg▒├","jS╟У╢╬i"}
	
	HB_Default( @k, 1 ) 
	if k == 2  // второй системный пароль
		//ret := {"└єажw)u╙╡"}
		ret := {"├·енu'├в"}
	endif
	
	return ret

METHOD FillFromHash( hbArray )     CLASS TUserDB
	local obj
	
	obj := TUser():New( hbArray[ 'ID' ], ;
			crypt( hbArray[ 'P1' ], ::cryptoKey() ), ;
			hbArray[ 'P2' ], ;
			crypt( hbArray[ 'P3' ], ::cryptoKey() ), ;
			hbArray[ 'P4' ], ;
			crypt( hbArray[ 'P5' ], ::cryptoKey() ), ;
			hbArray[ 'P6' ], ;
			crypt( hbArray[ 'P7' ], ::cryptoKey() ), ;
			crypt( hbArray[ 'P8' ], ::cryptoKey() ), ;
			hbArray[ 'IDROLE' ], ;
			hbArray[ 'REC_NEW' ], ;
			hbArray[ 'DELETED' ] ;
			)
	// obj:INN := hbArray[ 'INN' ]
	obj:INN := crypt( hbArray[ 'INN' ], ::cryptoKey() )
	obj:Dov_Date := stod(crypt( hbArray[ 'DOV_DATA' ], ::cryptoKey() ))
	obj:Dov_Nom := crypt( hbArray[ 'DOV_NOM' ], ::cryptoKey() )
	return obj