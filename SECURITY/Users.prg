// Users.prg - работа с пользователями системы
//////////////////////////////
// 04.11.18 edit_Users_bay() - редактирование списка пользователей
// 20.10.18 editUser( oBrowse, aObjects, object, nKey ) - редактирование объекта 'пользователь'
// 28.12.21 inp_password_bay( is_local_version, is_create ) - запрос и проверка пароля
// 20.10.18 get_parol_bay( r1, c1, r2, c2, ltip, color_say, color_get ) - функция окна ввода пароля
// 11.07.17 layoutUser( oBrow, aList ) - формирование колонок для отображения списка пользователей
// 01.09.16 PassExist( obj, aObjects, pass ) - проверка существования пользователя с указанным паролем
//////////////////////////////
#include 'hbthread.ch'
#include 'common.ch'
#include 'set.ch'
#include 'inkey.ch'

#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 13.09.23 ввод пароля
function inp_password_bay( is_local_version, is_create )
	local strPassword := space( 10 )
	local i_p := 0, ta := {}
	local oUser := nil
	local aMessageRepeat := { 'Не верный пароль!', 'Попробуйте еще раз...' }
	local aMessageEnd := { 'Нет прав доступа к системе!', 'Вы превысили число возможных попыток получить доступ!' }
	
	public TIP_ADM := 0
	public grup_polzovat := 1, dolj_polzovat := '', ;
		kod_polzovat := chr( 0 ), tip_polzovat := TIP_ADM, fio_polzovat := '', ;
		yes_parol := .t.
		
	if ( is_local_version .and. ! TStructFiles():New():ExistFileClass( 'TUserDB' ) ) .or. is_create
		hb_user_curUser := TUser():New(, 'Локальная версия', 0)
		yes_parol := .f.
		return ta
	endif
	do while i_p < 3  // до 3х попыток
		strPassword := get_parol_bay()
		if lastkey() == K_ESC
			f_end()
		else
			++i_p
			if ! TStructFiles():New():ExistFileClass( 'TUserDB' )
				hb_Alert( { 'Отсутствует таблица пользователей системы.', 'Продолжение работы невозможно!' }, , , 4 )
				f_end()
			elseif ( oUser := TUserDB():New():GetByPassword( strPassword ) ) != nil
				// присвоим текущего пользователя
				hb_user_curUser	:= oUser
				mfio			:= oUser:FIO
				fio_polzovat	:= alltrim( mfio )
				kod_polzovat	:= chr( oUser:ID() )
				tip_polzovat	:= oUser:Access
				dolj_polzovat	:= alltrim( oUser:Position )
				grup_polzovat	:= oUser:KEK

				oper_parol := oUser:PasswordFR	// int(val(s))
				oper_frparol := oUser:PasswordFRSuper	// oper_parol
				oper_fr_inn := oUser:INN
				oper_dov_date   := oUser:Dov_Date // stod(crypt(base1->dov_date,gpasskod))
				oper_dov_nomer  := oUser:Dov_nom	//alltrim(crypt(base->dov_nomer,gpasskod))
			else
				if i_p < 3  // до 3х попыток
					hb_Alert( aMessageRepeat, , , 4 )
					loop
				else
					hb_Alert( aMessageEnd, , , 4 )
					f_end()
				endif
			endif
		endif
		exit
	enddo
	aadd( ta, alltrim( fio_polzovat ) )
	aadd( ta, 'Тип доступа: "' + { 'Администратор', 'Оператор', '', 'Контролёр' }[ tip_polzovat + 1 ] + '"' )
	if !empty( alltrim( oUser:Position ) )
		aadd( ta, 'Должность: ' + alltrim( oUser:Position ) )
	endif
	if between( hb_user_curUser:KEK, 1, 3 )
		aadd( ta, 'Группа экспертизы (КЭК): ' + lstr( hb_user_curUser:KEK ) )
	endif
	return ta

// 20.10.18 функция окна ввода пароля
function get_parol_bay()
	local s := space( 10 )
	local color_say := 'N/W', color_get := 'W/N*'
	local r1 := maxrow() - 5, c1 := int( ( maxcol() - 36 ) / 2 )
	local oBox
	
	oBox := TBox():New( r1, c1, maxrow() - 3, maxrow() + 31, .t. )
	oBox:MessageLine := '^<Esc>^ - выход из задачи;  ^<Enter>^ - подтверждение ввода пароля'
	oBox:Color := color_say + ',' + color_get
	oBox:Frame := 0
	oBox:View()
	set confirm on
	setcursor()
	@ r1 + 1, c1 + 18 say s color color_get  // т.к. не работает get в выделенном цвете
	s := upper( getsecret( s, r1 + 1, c1 + 10, , 'Пароль:' ) )
	setcursor( 0 )
	set confirm off
	return s
	
// 04.11.18 редактирование списка пользователей
function edit_Users_bay()
	local blkEditObject
	local oBox, aEdit := {}
	local c_1 := T_COL + 5, c_2 := c_1 + 67
	local lWork
	local aProperties
	
	if is_task( X_KEK )
		c_1 := 2
		c_2 := 77
	endif
	blkEditObject := { | oBrowse, aObjects, object, nKey | editUser( oBrowse, aObjects, object, nKey ) }
										
	if hb_user_curUser:IsAdmin()
		aEdit := { .t., .t., .t., .t. }
		lWork := G_SLock( 'edit_pass' )
	else
		aEdit := { .f., .f., .f., .f. }
		lWork := .t.
	endif
	if lWork
		aProperties := { { 'FIO', 'Ф.И.О.', 20 }, { 'DepShortName', 'Под-ние', 7 }, { 'Position', 'Должность', 20 }, { 'Type_F', 'Тип', 3 } }
		if is_task( X_KEK )
			aadd( aProperties, { 'KEK', 'КЭК', 3 } )
		endif
		
		oBox := TBox():New( T_ROW, c_1, maxrow() - 2, c_2, .t. )
		oBox:Caption := 'Список пользователей'
		oBox:Color := color5
		// просмотр и редактирование списка пользователей, возврат функции не интересует
		ListObjectsBrowse( 'TUser', oBox, TUserDB():GetList(), 1, aProperties, ;
										blkEditObject, aEdit, , ' ^<F9>^-печать', )

	else
		return func_error( 4, 'В данный момент пароли редактирует другой администратор. Ждите.' )
	endif
	if lWork .and. hb_user_curUser:IsAdmin()
		G_SUnlock( 'edit_pass' )
	endif
	return nil

// 21.09.23 редактирование объекта пользователя
static function editUser( oBrowse, aObjects, oUser, nKey )
	local fl := .f.
	local r1 := maxrow() - 12, r2 := maxrow() - 3, i
	local c_1 := T_COL + 5, c_2 := c_1 + 62
	local oBox
	
	local mm_gruppa := { ;
						{ '0 - не работает в задаче КЭК', 0 }, ;
						{ '1 - уровень зав.отделением', 1 }, ;
						{ '2 - уровень зам.гл.врача', 2 }, ;
						{ '3 - уровень комиссии КЭК', 3 } }
	
	private mtip, m1tip, mgruppa, m1gruppa := 0, mDepartment, m1Department, mrole, m1role
	
	keyboard ''
	if nKey == K_F8
		if ( j := f_alert( { padc( 'Выберите порядок сортировки', 60, '.' ) }, ;
				{ ' По ФИО ', ' По номеру ' }, ;
				1, 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N,N/BG' ) ) != 0
			if j == 1
				asort( aObjects, , , { | x, y | x:FIO < y:FIO } )
			elseif j == 2
				asort( aObjects, , , { | x, y | x:ID < y:ID } )
			endif
			oBrowse:refreshAll()
			return .t.
		endif
	elseif nKey == K_F9 .and. glob_mo[_MO_KOD_TFOMS] == '102604'	// Для ВОККВД
		// hb_threadStart( HB_THREAD_INHERIT_PUBLIC, @printUserList(), aObjects )
		// WaitingReport( 3 )
		// return .t.
	elseif nKey == K_INS .OR. nKey == K_ENTER
		m1tip := oUser:Access
		mtip := inieditspr( A__MENUVERT, TUser():aMenuType, m1tip )
		m1role := oUser:IDRole
		mrole := inieditspr( A__MENUVERT, TRoleUserDB():MenuRoles, m1role )
		m1Department := oUser:IDDepartment()
		mDepartment := inieditspr( A__MENUVERT, TDepartmentDB():MenuDepartments(), m1Department )

		if is_task( X_KEK )
			m1gruppa := oUser:KEK
			mgruppa := inieditspr( A__MENUVERT, mm_gruppa, m1gruppa )
			--r1
			c_1 := 2
			c_2 := 77
		endif
		if is_task( X_PLATN ) .or. is_task( X_ORTO ) .or. is_task( X_KASSA )
			--r1
		endif
		
		oBox := TBox():New( r1, c_1 + 1, r2, c_2 - 1, .t. )
		oBox:Caption := iif( nKey == K_INS .or. nKey == K_F4, 'Добавление', 'Редактирование' )
		oBox:MessageLine := '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода'
		oBox:Color := cDataCGet
		oBox:View()
		
    if is_task(X_PLATN) .or. is_task(X_ORTO) .or. is_task(X_KASSA)
			@ r1 + 2, c_1 + 3 say 'Ф.И.О. пользователя' get oUser:FIO valid func_empty( oUser:FIO )
			@ r1 + 2, c_1 + 44 say 'ИНН пользователя' get oUser:INN picture '999999999999'
    else
			@ r1 + 2, c_1 + 3 say 'Ф.И.О. пользователя' get oUser:FIO valid func_empty( oUser:FIO )
    endif

		@ r1 + 3, c_1 + 3 say 'Учреждение' get mDepartment ;
								READER { | x | menu_reader( x, TDepartmentDB():MenuDepartments(), A__MENUVERT, , , .f. ) }
		@ r1 + 4, c_1 + 3 say 'Должность' get oUser:Position
		@ r1 + 5, c_1 + 3 say 'Группа пользователей' get mrole ;
								READER { | x | menu_reader( x, TRoleUserDB():MenuRoles(), A__MENUVERT, , , .f. ) }
		@ r1 + 6, c_1 + 3 say 'Тип доступа' get mtip ;
								READER { | x | menu_reader( x, TUser():aMenuType, A__MENUVERT, , , .f. ) }
		@ r1 + 7, c_1 + 3 say 'Пароль' get oUser:Password picture '@!' valid func_empty( oUser:Password ) .and. !PassExist( oUser, aObjects, oUser:Password )
		i := 7
		if is_task( X_KEK )
			++i
			@ r1 + i, c_1 + 3 say 'Группа КЭК' get mgruppa READER { | x | menu_reader( x, mm_gruppa, A__MENUVERT, , , .f. ) }
		endif
		if is_task( X_PLATN ) .or. is_task( X_ORTO ) .or. is_task( X_KASSA )
			++i
			@ r1 + i, c_1 + 3 say 'Пароль для фискального регистратора' get oUser:PasswordFR picture '99999999'
			++i
      @ r1 + i, c_1 + 3 say 'N доверен-ти' get oUser:Dov_Nom
      @ r1 + i, c_1 + 36 say 'Дата доверен-ти' get oUser:Dov_Date
		endif
		myread()
		if lastkey() != K_ESC .and. f_Esc_Enter( 1 )
			oUser:IDDepartment( m1Department )
			oUser:KEK := m1gruppa
			oUser:Access := m1tip
			oUser:IDRole := m1role
			TUserDB():Save( oUser )
			fl := .t.
		endif
		oBox := nil
	elseif nKey == K_DEL
	// не реализовано
	endif
	return fl

// 01.09.16 проверка существования пользователя с указанным паролем
// obj	- объект пользователя не участвующего в проверке
// aObjects	- список пользователей
// pass	- строка пароля
function PassExist( obj, aObjects, pass )
	local ret := .f., oUser := nil

	pass := alltrim( pass )
	for each oUser in aObjects
		if ( alltrim( oUser:Password ) == pass ) .and. ( !obj:Equal( oUser ) )
			hb_Alert( 'Пользователь с указанным паролем существует!', , , 4 )
			ret := .t.
			exit
		endif
	next
	return ret