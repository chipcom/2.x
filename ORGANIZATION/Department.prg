//
//
// 03.11.18 editDepartments() - редактирование списка подразделений
// 21.10.18 editDepartment( oBrowse, aObjects, oDepartment, nKey ) - редактирование объекта подразделение
// 27.09.18 inputN_uch( r, c, date1, date2, /*@*/c_uch ) - множественный выбор подразделений ( для совместимости )
// 13.02.17 SelectDepartment( r, c, date1, date2 ) - выбор подразделения
// 09.02.17 layoutDepartment( oBrow, aList ) - формирование колонок для отображения списка подразделений
// 05.05.17 MultipleSelectedDepartment( r, c, dBegin, dEnd, oUser ) - возвращает массив выбранных объектов Подразделений 
// 16.16.17 f_is_uch( arr_u, pole_u )
// 16.16.17 titleN_uch( arr_u, lsh, c_uch )
//

#include 'set.ch'
#include 'inkey.ch'
#include 'hbthread.ch'
#include 'common.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

static strDepartment := 'РЕДАКТИРОВАНИЕ ПОДРАЗДЕЛЕНИЯ'

// 28.01.24 редактирование списка подразделений
function editDepartments()
	local blkEditObject
	local aEdit
	local oBox
	local aProperties

	blkEditObject := { | oBrowse, aObjects, object, nKey, oDep | editDepartment( oBrowse, aObjects, object, nKey ) }
	aEdit := if( hb_user_curUser:IsAdmin(), { .t., .t., .t., .t. }, { .f., .f., .f., .f. } )
	
	aProperties := { { 'Name', 'Наименование', 30 }, { 'ShortName', 'Сокр.;наим.', 5 }, { 'IsUseTalon_F', 'Работа с;талоном ', 8 } }
	// просмотр и редактирование списка подразделений
	oBox := TBox():New( T_ROW, T_COL + 5, maxrow() - 1, T_COL + 58, .t. )
	oBox:Caption := 'Учреждения'
	oBox:Color := color5
	ListObjectsBrowse( 'TDepartment', oBox, TDepartmentDB():GetList(), 1, aProperties, ;
										blkEditObject, aEdit, , , )

	return nil

// 21.10.18 редактирование объекта подразделение
function editDepartment( oBrowse, aObjects, oDepartment, nKey )
	local fl := .f.
	local k
	local oBox
	local oChief := nil

	private m1talon := 0, mtalon
	private mtabn_vr := 0, mvrach := space( 35 )
	
	if nKey == K_F9
	elseif nKey == K_F2
	elseif nKey == K_INS .OR. nKey == K_ENTER .or. nKey == K_F4
		m1talon		:= iif( oDepartment:IsUseTalon, 1, 0 )
		mtalon			:= inieditspr_bay( A__MENUVERT, mm_danet, m1talon )
		oChief		:= oDepartment:Chief
		if ! isnil( oChief )
			mvrach := padr( oChief:ShortFIO(), 20 )
			mtabn_vr := oChief:TabNom()
		endif
		k := maxrow() - 19
		
		oBox := TBox():New( k - 1, 10, k + 10, 70, .t. )
		oBox:Caption := if( nKey == K_INS .or. nKey == K_F4, 'Добавление', 'Редактирование' ) + ' информации о подразделении'
		oBox:CaptionColor := color8
		oBox:MessageLine := '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода'
		oBox:View()

		@ k + 1, 12 say 'Наименование подразделения' get oDepartment:Name
		@ k + 2, 12 say 'Сокращенное наименование' get oDepartment:ShortName
		@ k + 3, 12 say 'Работаем со стат. талоном?' get mtalon ;
				reader { | x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
		@ k + 4, 12 say 'Таб.№ руководителя' get mtabn_vr pict '99999' ;
				valid { | g | validEmployer( g, 'врач', @oChief ) }
		@ row(), col() + 1 get mvrach  when .f. color color14 picture '@S20'
		@ k + 5, 12 say 'Действует на основании'  get oDepartment:Competence picture '@S34'  // '@!@S34'
		@ k + 6, 12 say 'Адрес нахождения' get oDepartment:Address picture '@S40' // '@!@S40'
		@ k + 7, 12 say 'Дата начала работы с подразделением' get oDepartment:Dbegin
		@ k + 8, 12 say 'Дата окончания работы' get oDepartment:Dend
	
		myread()
		if lastkey() != K_ESC .and. !empty( oDepartment:Name ) .and. f_Esc_Enter(1)
			oDepartment:IsUseTalon := if( m1talon == 0, .f., .t. )
			oDepartment:Chief := oChief
			TDepartmentDB():Save( oDepartment )
			oBrowse:refreshAll()
			fl := .t.
		endif
		oBox := nil
	elseif nKey == K_DEL
		&& stat_msg( 'Ждите! Производится проверка на допустимость удаления подразделения' )
				
		if len( TSubdivisionDB():GetList( oDepartment:ID() ) ) > 0
			ret := .f.
			hb_Alert( 'Данное подразделение используется справочнике отделений. Удаление запрещено!', , , 4 )
		else
			TDepartmentDB():Delete( oDepartment )
			ret := .t.
		endif
	endif
	return fl

// 07.06.17 - выбор подразделения
function SelectDepartment( r, c, dBegin, dEnd )
	local kk
	local aDepartment, ar
	local ret := nil
	
	if empty( glob_uch[ 1 ] )
		// tmp_ini - глобальная переменная, хранит имя файла конфигурации ('tmp.ini')
		// glob_uch := { 0, '' } // глобальное учреждение массив
		// glob_otd := { 0, '' } // глобальное отделение массив
		ar := GetIniVar( tmp_ini, { { 'uch_otd', 'uch', '0' }, ;
                           { 'uch_otd', 'otd', '0' } } )
		glob_uch[ 1 ] := int( val( ar[ 1 ] ) )
		glob_otd[ 1 ] := int( val( ar[ 2 ] ) )
	endif
	
	aDepartment := TDepartmentDB():GetList( hb_defaultValue( dBegin, ctod( '' ) ), hb_defaultValue( dEnd, ctod( '' ) ), hb_user_curUser )
	if ( kk := Len( aDepartment ) ) == 0
		hb_Alert( 'Пустой справочник подразделений', , , 4)
	elseif kk == 1
		ret := aDepartment[ 1 ]
	elseif kk > 1
		ret := choiceDivision( r, c, kk, aDepartment, 'Подразделения' )
	endif
	if ret != nil
		glob_uch := { ret:ID, ret:Name }
		st_a_uch := { glob_uch }
		SetIniVar( tmp_ini, { { 'uch_otd', 'uch', glob_uch[ 1 ] } } )
	endif
	return ret
	
// 05.05.17 - возвращает массив выбранных объектов Подразделений 
function MultipleSelectedDepartment( r, c, dBegin, dEnd, oUser )
	local aRet := {}
	local aDepartment := TDepartmentDB():GetList( dBegin, dEnd, hb_defaultValue( oUser, hb_user_curUser ) )
	
	return ChoiceObjectFromArray( r, c, aDepartment, .t., 'Подразделения' )

// 27.09.18 - возвращает массив выбранных объектов Подразделений 
//function inputN_uch( r, c, date1, date2, /*@*/c_uch )
//	static st_uch := {}
//	local i, k, mas_u := {}, mas := {}, t_mas, c2, buf := savescreen()
//	local l_a_uch
//	local aDepartment := {}, item
		
//	aDepartment := TDepartmentDB():getList( date1, date2 )
//	for each item in aDepartment
//		aadd( mas_u, item:Name )
//		aadd( mas, item:ID )
//	next
	
//	count_uch := c_uch := len( mas )
//	if count_uch == 0
//		hb_Alert( 'Справочник учреждений пуст!', , , 4 )
//		return nil
//	elseif count_uch == 1
//		is_all_uch := .f.
//		glob_uch := { mas[ 1 ], mas_u[ 1 ] }
//		restscreen( buf )
//		return { glob_uch }
//	else
//		if r < 0 // т.е. GET находится внизу экрана
//			k := abs( r ) - 2
//			if ( r := k - count_uch - 1 ) < 2
//				r := 2
//			endif
//		else
//			if ( k := r + count_uch + 1 ) > maxrow() - 2
//				k := maxrow() - 2
//			endif
//		endif
//		c2 := c + 35 + 1
//		if c2 > 77
//			c2 := 77 ; c := 76 - 35
//		endif
//		t_mas := aclone( mas_u )
//		if len( st_uch ) == 0
//			aeval( mas, { | x | aadd( st_uch, x ) } )
//		endif
//		aeval( t_mas, { | x, i | ;
//				t_mas[ i ] := if( ascan( st_uch, mas[ i ] ) > 0, ' * ', '   ') + t_mas[ i ] } )
  
//		status_key( '^<Esc>^ отказ;  ^<Enter>^ подтверждение;  ^<Ins>^ смена признака выбора учреждения' )
//		do while .t.
//			l_a_uch := nil
//			if popup( r, c, k, c2, t_mas, i, color_uch, .t., 'fmenu_reader', , ;
//					'Учреждения', col_tit_uch ) > 0
					
//				l_a_uch := {} ; st_uch := {}
//				for i := 1 TO len( t_mas )
//					if '*' == substr( t_mas[ i ], 2, 1 )
//						aadd( l_a_uch, { mas[ i ], mas_u[ i ] } )
//						aadd( st_uch, mas[ i ] )
//					endif
//				next
//				if empty( l_a_uch )
//					hb_Alert( 'Необходимо отметить хотя бы одно учреждение!', , , 4 )
//					loop
//				else
//					if ( k := len( l_a_uch ) ) == 1
//						glob_uch := l_a_uch[ 1 ]
//					endif
//					is_all_uch := ( k == count_uch )
//					exit
//				endif
//			else
//				exit
//			endif
//		enddo
//	endif
//	restscreen( buf )
//	return l_a_uch

//
//function f_is_uch( arr_u, pole_u )

//	return ascan( arr_u, { | x | pole_u == x[ 1 ] } ) > 0

//
//function titleN_uch( arr_u, lsh, c_uch )
//	local i, t_arr[ 2 ], s := ''
	
//	if !(type( 'count_uch' )== 'N' )
//		count_uch := iif( c_uch == nil, 1, c_uch )
//	endif
//	if count_uch > 1
//		if count_uch == len( arr_u )
//			add_string( center( '[ по всем учреждениям ]', lsh ) )
//		else
//			aeval( arr_u, { | x | s += '"' + alltrim( x[ 2 ] ) + '", ' } )
//			s := substr( s, 1, len( s ) - 2 )
//			for i := 1 to perenos( t_arr, s, lsh )
//				add_string( center( alltrim( t_arr[ i ] ), lsh ) )
//			next
//		endif
//	endif
//	return nil
