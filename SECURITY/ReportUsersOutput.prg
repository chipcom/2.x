// ReportUsersOutput.prg - работа с пользователями системы
//
// 11.07.24 printUserList( aList ) - печать списка пользователей системы
//
#include "chip_mo.ch"

#require "hbtip" 

// 11.07.24 - печать списка пользователей системы
function printUserList( aList )
	Local oDoc, oNode, oTable, oRow, oCell, oHTable, oBTable, oTH
	Local item
	
	oDoc := CreateReportHTML( 'Список пользователей' )
	/* Operator ":" returns first "h1" from body (creates if not existent) */
	oNode         := oDoc:body:h1
	oNode         := oNode   + 'center'
	oNode:text    := "Пользователи зарегистрированные в системе"
	oNode         := oNode   - 'center'
	HB_SYMBOL_UNUSED( oNode )
	
	/* Operator ":" returns first "table" from body (creates if not existent) */
	oTable        := oDoc:body + 'table'
	oTable:attr   := 'border="0" cellspacing="0" cellpadding="0"'

	oTH		:= oTable  + 'tr'
	oTH:attr		:= 'class="head"'
	// первая колонка
	oCell		:= oTH + 'th'
	oCell:attr	:= 'class="thleft"'
	oParag			:= oCell + 'p'
	oParag:attr		:= 'align="center" class="bodyp"'
	oParag:text		:= 'Пользователь'
	oParag			:= oParag - 'p'
	oCell		:= oCell - 'th'
	HB_SYMBOL_UNUSED( oCell )
	// вторая колонка
	oCell		:= oTH + 'th'
	oCell:attr	:= 'class="thleft"'
	oParag			:= oCell + 'p'
	oParag:attr		:= 'align="center" class="bodyp"'
	oParag:text		:= 'ИНН'
	oParag			:= oParag - 'p'
	oCell		:= oCell - 'th'
	HB_SYMBOL_UNUSED( oCell )
	// третья колонка
	oCell		:= oTH + 'th'
	oCell:attr	:= 'class="thleft"'
	oParag			:= oCell + 'p'
	oParag:attr		:= 'align="center" class="bodyp"'
	oParag:text		:= 'Касса'
	oParag			:= oParag - 'p'
	oCell		:= oCell - 'th'
	HB_SYMBOL_UNUSED( oCell )
	// четвертая колонка
	oCell		:= oTH + 'th'
	oCell:attr	:= 'class="thleft"'
	oParag			:= oCell + 'p'
	oParag:attr		:= 'align="center" class="bodyp"'
	oParag:text		:= 'Тип доступа'
	oParag			:= oParag - 'p'
	oCell		:= oCell - 'th'
	HB_SYMBOL_UNUSED( oCell )
	// пятая колонка
	oCell		:= oTH + 'th'
	oCell:attr	:= 'class="thleft"'
	oParag			:= oCell + 'p'
	oParag:attr		:= 'align="center" class="bodyp"'
	oParag:text		:= 'Подразделение'
	oParag			:= oParag - 'p'
	oCell		:= oCell - 'th'
	HB_SYMBOL_UNUSED( oCell )
	// шестая колонка
	oCell		:= oTH + 'th'
//	if is_task( X_KEK )
//		oCell:attr	:= 'class="thleft"'
//	else
	oCell:attr	:= 'class="thleft thright"'
//	endif
	oParag			:= oCell + 'p'
	oParag:attr		:= 'align="center" class="bodyp"'
	oParag:text		:= 'Должность'
	oParag			:= oParag - 'p'
	oCell		:= oCell - 'th'
	HB_SYMBOL_UNUSED( oCell )
	
//	if is_task( X_KEK )
//		// седьмая колонка
//		oCell		:= oTH + 'th'
//		oCell:attr	:= 'class="thleft thright"'
//		oParag			:= oCell + 'p'
//		oParag:attr		:= 'align="center" class="bodyp"'
//		oParag:text		:= 'Группа КЭК'
//		oParag			:= oParag - 'p'
//		oCell		:= oCell - 'th'
//		HB_SYMBOL_UNUSED( oCell )
//	endif
	
	for EACH item IN aList
		oRow         := oTable + 'tr'
		oRow:bgColor := iif( item:IsAdmin(), "yellow", "" )
						
		// 1-я колонка
		oCell		:= oRow + 'td'
		oCell:attr	:= 'class="td1" valign="center" align="left"'
		oCell:text	:= item:FIO1251
		oCell		:= oCell - 'td'
		HB_SYMBOL_UNUSED( oCell )

		// 2-я колонка
		oCell		:= oRow + 'td'
		oCell:attr	:= 'class="td1" valign="center" align="left"'
		oCell:text	:= item:INN
		oCell		:= oCell - 'td'
		HB_SYMBOL_UNUSED( oCell )

		// 3-я колонка
		oCell		:= oRow + 'td'
		oCell:attr	:= 'class="td1" valign="center" align="center"'
		oCell:text	:= iif( empty( item:PasswordFR ), '', '+' )
		oCell		:= oCell - 'td'
		HB_SYMBOL_UNUSED( oCell )

		// 4-я колонка
		oCell		:= oRow + 'td'
		oCell:attr	:= 'class="td1" valign="center" align="center"'
		oCell:text	:= if( item:IsAdmin(), "Администратор", if( item:IsOperator(), "Оператор", "Контролер" ) )
		oCell		:= oCell - 'td'
		HB_SYMBOL_UNUSED( oCell )

		// 5-я колонка
		oCell		:= oRow + 'td'
		oCell:attr	:= 'class="td1" valign="center" align="left"'
		oCell:text	:= if( TDepartmentDB():GetByID( item:IDDepartment() ) != nil, ;
							TDepartmentDB():GetByID( item:IDDepartment() ):Name1251, '' )
		oCell		:= oCell - 'td'
		HB_SYMBOL_UNUSED( oCell )
		
		// 6-я колонка
		oCell		:= oRow + 'td'
//		if is_task( X_KEK )
//			oCell:attr	:= 'class="td1" valign="center" align="center"'
//		else
			oCell:attr	:= 'class="td3" valign="center" align="center"'
//		endif
		oCell:text	:= item:Position1251
		oCell		:= oCell - 'td'
		HB_SYMBOL_UNUSED( oCell )

//		if is_task( X_KEK )
//			// 7-я колонка
//			oCell		:= oRow + 'td'
//			oCell:attr	:= 'class="td3" valign="center" align="center"'
//			oCell:text	:= item:KEK
//			oCell		:= oCell - 'td'
//			HB_SYMBOL_UNUSED( oCell )
//		endIf
		oRow := oRow - "tr"
		HB_SYMBOL_UNUSED( oRow )
	next
	oTable        := oTable - 'table'
	HB_SYMBOL_UNUSED( oTable )
	ViewHTML( oDoc )
	return nil