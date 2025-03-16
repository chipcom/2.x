#include 'hbclass.ch'
#include 'property.ch'
#include 'common.ch'

// класс описывающий удостоверение личности физического лица, не привязан к конкретному файлу БД
CREATE CLASS TPassport
	VISIBLE:
		PROPERTY DocumentType WRITE setDocumentType INIT 0				// тип документа удостоверяющего личность
		PROPERTY DocumentSeries WRITE setDocumentSeries INIT space( 10 )	// серия документа
		PROPERTY DocumentNumber WRITE setDocumentNumber INIT space( 20 )	// номер документа
		PROPERTY IDIssue WRITE setDocumentIDIssue INIT 0					// идентификатор организации выдавшей документ
		PROPERTY DateIssue WRITE setDateIssue INIT ctod( '' )			// дата выдачи
		PROPERTY AsString READ GetAsString( ... )						// представление документа по установленной форматной строке
		PROPERTY Format READ FFormat WRITE SetFormat						// форматная строка вывода представления документа
		PROPERTY Exists READ getExists
		
		CLASSDATA	aMenuType	AS ARRAY	INIT { ;
			{ 'Паспорт гражд.СССР        ', 1,  1,	'ПАСПОРТ',			'R-ББ',	'999999' }, ;
			{ 'Загранпасп.гражд.СССР     ', 2,  0,	'ЗГПАСПОРТ',		'99',	'0999999' }, ;
			{ 'Свид-во о рождении (РФ)   ', 3,  1,	'СВ-ВО О РОЖ.РФ',	'R-ББ',	'999999' }, ;
			{ 'Уд-ние личности офицера   ', 4,  0,	'УДОСТ ОФИЦЕРА',	'ББ',	'999999' }, ;
			{ 'Справка об освобождении   ', 5,  1,	'СПРАВКА ОБ ОСВ',	'',		'SSSSSSSSSSSSSSSSSSSSSSSSS' }, ;
			{ 'Паспорт Минморфлота       ', 6,  0,	'ПАСПОРТ МОРФЛТ',	'ББ',	'999999' }, ;
			{ 'Военный билет             ', 7,  0,	'ВОЕННЫЙ БИЛЕТ',	'ББ',	'0999999' }, ;
			{ 'Дипл.паспорт гражд.РФ     ', 8,  0,	'ДИППАСПОРТ РФ',	'99',	'9999999' }, ;
			{ 'Иностранный паспорт       ', 9,  1,	'ИНОСТР ПАСПОРТ',	'',		'SSSSSSSSSSSSSSSSSSSSSSSSS' }, ;
			{ 'Свидетельство...беженца   ', 10, 0,	'СВИД БЕЖЕНЦА',		'',		'SSSSSSSSSSSSSSSSSSSSSSSSS' }, ;
			{ 'Вид на жительство         ', 11, 1,	'ВИД НА ЖИТЕЛЬ',	'',		'SSSSSSSSSSSSSSSSSSSSSSSSS' }, ;
			{ 'Удост-ие беженца в РФ     ', 12, 1,	'УДОСТ БЕЖЕНЦА',	'',		'SSSSSSSSSSSSSSSSSSSSSSSSS' }, ;
			{ 'Врем.уд.личн.гражд.РФ     ', 13, 1,	'ВРЕМ УДОСТ',		'',		'SSSSSSSSSSSSSSSSSSSSSSSSS' }, ;
			{ 'Паспорт гражд.России      ', 14, 1,	'паспорт России',	'99 99','999999' }, ;
			{ 'Загранпасп.гражд.РФ       ', 15, 1,	'ЗПАСПОРТ РФ',		'99',	'9999999' }, ;
			{ 'Паспорт моряка            ', 16, 0,	'ПАСПОРТ МОРЯКА',	'ББ',	'0999999' }, ;
			{ 'Военный билет оф.запаса   ', 17, 0,	'ВОЕН БИЛЕТ ОЗ',	'ББ',	'0999999' }, ;
			{ 'Иные документы            ', 18, 1,	'ПРОЧЕЕ',			'',		'SSSSSSSSSSSSSSSSSSSSSSSSS' }, ;
			{ 'Док-т инос.гражданина     ', 21, 0,	'ИНОСТР ГРАЖДАН',	'',		'' }, ;
			{ 'Док-т лица без гражданства', 22, 0,	'ЛИЦО БЕЗ ГРАЖД',	'',		'' }, ;
			{ 'Разр-ие на врем.проживание', 23, 0,	'РАЗР НА ВР.ПР.',	'',		'' }, ;
			{ 'Свид-во о рожд.(не в РФ)  ', 24, 0,	'СВ.О РОЖ.НЕ РФ',	'',		'' } }

// В графе "Шаблон серии, номера" приведены данные для контроля значения серии, номера документа.
// Шаблон состоит из символов "R", "Б", "9", "0", "S", "-" (тире) и " " (пробел).
// Используются следующие обозначения:
// R - на месте одного символа R располагается целиком римское число, заданное символами "I", "V", "X", "L", "C", 
//		набранными на верхнем регистре латинской клавиатуры; возможно представление римских чисел с помощью 
//		символов "1", "У", "Х", "Л", "С" соответственно, набранных на верхнем регистре русской клавиатуры;
// 9 - любая десятичная цифра (обязательная);
// 0 - любая десятичная цифра (необязательная, может отсутствовать);
// Б - любая русская заглавная буква;
// S - символ не контролируется (может содержать любую букву, цифру или вообще отсутствовать);
// "-" (тире) - указывает на обязательное присутствие данного символа в контролируемом значении.
// Пробелы используются для разделения групп символов, а также вместо знаков "No" или "N" для разделения 
//		серии и номера документа.
// Число пробелов между значащими символами в контролируемом значении не должно превышать пяти.
													
		METHOD New( nType, cSeries, cNumber, nIDIssue, dIssue )
	HIDDEN:
		// форматная строка: TYPE - тип документа, SSS - серия, NNN - номер, ISSUE - кто выдал, DATE - дата выдачи
		DATA FFormat INIT 'TYPE #SSS #NNN'
		METHOD setDocumentType( nType )
		METHOD setDocumentSeries( cText )
		METHOD setDocumentNumber( cText )
		METHOD setDocumentIDIssue( nId )
		METHOD setDateIssue( dIssue )
		METHOD GetAsString( format )
		METHOD SetFormat( format )	INLINE ::FFormat := format
		METHOD getExists				INLINE ! empty( ::FDocumentNumber )
ENDCLASS

METHOD New( nType, cSeries, cNumber, nIDIssue, dIssue ) CLASS TPassport
	::FDocumentType := hb_defaultvalue( nType, 0 )
	::FDocumentSeries := left( hb_defaultvalue( cSeries, space( 10 ) ), 10 )
	::FDocumentNumber := left( hb_defaultvalue( cNumber, space( 20 ) ), 20 )
	::FIDIssue := hb_defaultvalue( nIDIssue, 0 )
	::FDateIssue := hb_defaultvalue( dIssue, ctod( '' ) )
	return self

METHOD PROCEDURE setDocumentType ( nType )	CLASS TPassport
	::FDocumentType := nType
	return

METHOD PROCEDURE setDocumentSeries( cText )	CLASS TPassport
	::FDocumentSeries := cText
	return

METHOD PROCEDURE setDocumentNumber( cText )	CLASS TPassport
	::FDocumentNumber := cText
	return

METHOD PROCEDURE setDocumentIDIssue( nId )	CLASS TPassport
	::FIDIssue := nId
	return

METHOD PROCEDURE setDateIssue( dIssue )	CLASS TPassport
	::FDateIssue := dIssue
	return
	
METHOD FUNCTION GetAsString( format ) CLASS TPassport
	local asString := ''
	local numToken
	local i := 0
	local j := 0
	local s := ''
	local tk := ''
	local tkSep
	local itm := ''
	local len := 0
	local oPublisher := nil
	local ch := ''
	local lExist := .f.
	
	&& if empty( format )
	if isnil( format )
		format := ::FFormat
	endif
	numToken := NumToken( format, ' ' )	// разделитель подстрок только 'пробел'
	&& numToken := NumToken( format )
	for i := 1 to numToken
		tk := Token( format, ' ', i )	// разделитель подстрок только 'пробел'
		&& tk := Token( format, , i )
		ch := alltrim( TokenSep( .t. ) )
		tkSep := ' '
		itm := upper( tk )
		len := len( itm )
		do case
		case alltrim( itm ) == 'TYPE'
			if ( j := ascan( ::aMenuType, { | x | x[ 2 ] == ::FDocumentType } ) ) > 0
				s := alltrim( ::aMenuType[ j, 4 ] )
			endif
		case alltrim( itm ) == 'SSS'
			if ! empty( ::FDocumentSeries )
				s := alltrim( ::FDocumentSeries )
				lExist := .t.
			endif
		case alltrim( itm ) == '#SSS'
			if ! empty( ::FDocumentSeries )
				s := 'серия ' + alltrim( ::FDocumentSeries )
				lExist := .t.
			endif
		case alltrim( itm ) == 'NNN'
			if ! empty( ::FDocumentNumber )
				s := alltrim( ::FDocumentNumber )
				lExist := .t.
			endif
		case alltrim( itm ) == '#NNN'
			if ! empty( ::FDocumentNumber )
				s := '№ ' + alltrim( ::FDocumentNumber )
				lExist := .t.
			endif
//		case alltrim( itm ) == 'ISSUE'
//			if ( oPublisher := TPublisherDB():getByID( ::FIDIssue ) ) != nil
//				s := alltrim( oPublisher:Name() )
//				lExist := .t.
//			endif
		case alltrim( itm ) == 'DATE'
			if ! empty( ::FDateIssue )
				s := dtoc( ::FDateIssue )
				lExist := .t.
			endif
		case alltrim( itm ) == '#DATE'
			if ! empty( ::FDateIssue )
				s := 'выдан: ' + dtoc( ::FDateIssue )
				lExist := .t.
			endif
		otherwise
			s := alltrim( tk )	// просто переносим текст
		endcase
		s += ch
		if s != nil
			asString += iif( i = 1, '', tkSep ) + s
        endif
	next
	if ! lExist
		asString := ''
	endif
	return asString