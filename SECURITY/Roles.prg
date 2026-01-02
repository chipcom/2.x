* Roles.prg - работа с ролями пользователей системы
*******************************************************************************
* 02.11.18 editRoles() - отображение списка ролей пользователей
* 19.10.18 editRole( oBrowse, listObjects, object, nElem, nKey ) - редактирование роли
*******************************************************************************
#include 'hbthread.ch'
#include 'set.ch'
#include 'inkey.ch'

#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

***** 02.11.18 редактирование списка ролей пользователей
function editRoles()
	local blkEditObject
	local colBeg, colEnd
	local oBox, aEdit := {}
	local lWork
	local aProperties

	colBeg := T_COL + 5
	colEnd := colBeg + 40
	blkEditObject := { | oBrowse, aObjects, object, nKey | editRole( oBrowse, aObjects, object, nKey ) }

	if currentuser():IsAdmin()
		aEdit := { .t., .t., .t., .t. }
		lWork := G_SLock( 'edit_roles' )
	else
		aEdit := { .f., .f., .f., .f. }
		lWork := .t.
	endif
	if lWork
		
		aProperties := { { 'Name', 'Наименование группы', 34 } }
		// просмотр и редактирование списка ролей пользователей
		oBox := TBox():New( T_ROW, colBeg, maxrow() - 2, colEnd, .t. )
		oBox:Caption := 'Список групп пользователей'
		oBox:Color := color5
		ListObjectsBrowse( 'TRoleUser', oBox, TRoleUserDB():GetList(), 1, aProperties, ;
										blkEditObject, aEdit, , , )
	else
		return func_error( 4, 'В данный момент группы пользователей редактирует другой администратор. Ждите.' )
	endif
	if lWork .and. currentuser():IsAdmin()
		G_SUnlock( 'edit_roles' )
	endif
	return nil

***** 19.10.18 редактирование объекта роли
function editRole( oBrowse, aObjects, oRole, nKey )
	local fl := .f.
	local old_m1otd, old_m1task, k
	local rowBeg, colBeg
	local strCaption := ''
	local oBox

	private	motdel := space( 10 ), m1otdel := ''
	private	mtask := space( 10 ), m1task := ''

	if ( nKey == K_INS .or. nKey == K_ENTER .or. nKey == K_F4 )
		if ( oRole != nil )
			mname := oRole:Name
			if !Empty( oRole:ACLDep )
				k := atnum( chr( 0 ), oRole:ACLDep, 1 )
				motdel := oRole:StrAcceptDepartment()
				m1otdel := left( oRole:ACLDep, k - 1 )
			endif
			if !Empty( oRole:ACLTask )
				k := atnum( chr( 0 ), oRole:ACLTask, 1 )
				mtask := oRole:StrAcceptTask()
				m1task := left( oRole:ACLTask, k - 1 )
			endif
		endif
		old_m1otd := m1otdel
		old_m1task := m1task
		rowBeg := maxrow() - 11
		colBeg := T_COL + 5
		
		oBox := TBox():New( rowBeg, colBeg + 1, rowBeg + 6, colBeg + 49, .t. )
		oBox:Caption := iif( nKey == K_INS .or. nKey == K_F4, 'Добавление', 'Редактирование' )
		oBox:MessageLine := '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода'
		oBox:View()
		
		rowBeg++
		@ ++rowBeg, colBeg + 3 say 'Название роли' get oRole:Name valid func_empty( oRole:Name )
		if glob_mo[_MO_KOD_TFOMS] == '102604'	// Для ВОККВД
//			aadd(array_tasks, {'ВОУНЦ - трансплантированные',X_MO,'TABLET_ICON', .t.})
			@ ++rowBeg, colBeg + 3 say 'Разрешенные отделения для работы' ;
					get motdel reader { | x | menu_reader( x, ;
					{ { | k, r, c | inp_bit_dep_bay( k, r, c ) } }, A__FUNCTION, , , .f. ) }
		endif
		
		@ ++rowBeg, colBeg + 3 say 'Разрешенные задачи для работы' ;
							get mtask reader { | x | menu_reader( x, ;
							{ { | k, r, c | inp_bit_task_bay( k, r, c ) } }, A__FUNCTION, , , .f. ) }
	
		myread()
		if lastkey() != K_ESC .and. f_Esc_Enter( 1 )
			if !( old_m1otd == m1otdel )
				oRole:ACLDep := padr( m1otdel, 255, chr( 0 ) )
			endif
			if !( old_m1task == m1task )
				oRole:ACLTask := padr( m1task, 255, chr( 0 ) )
			endif
			TRoleUserDB():Save( oRole )
			fl := .t.
		endif
		oBox := nil	// очистим объект TBox
	elseif nKey == K_DEL
		if glob_mo[_MO_KOD_TFOMS] == '102604'	// Для ВОККВД
			// Производится проверка на допустимость удаления данной группы
			if len( TUserDB():GetListUsersByRole( oRole:ID() ) ) > 0
				hb_alert( 'Данная группа используется справочнике пользователей. Удаление запрещено!', , , 4 )
				fl := .f.
			else
				TRoleUserDB():Delete( oRole )
				fl := .t.
			endif
		endif
	else
		return fl
	endif
	return fl