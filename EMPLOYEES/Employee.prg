// Employee.prg - работа с сотрудниками организации
//
// 06.11.18 editLevelPayment( oBrowse, aObjects, oEmployee, nKey ) - редактирование объекта сотрудник для определения уровня оплаты
// 06.11.18 editEmployee( oBrowse, ar, obj, nElem, nKey ) редактирование объекта сотрудник
// 05.11.18 SelectEmployee( r, c ) - выбор сотрудника из списка
// 05.11.18 editDistrictDoctors() - редактирование участковых врачей
// 05.11.18 editDistrictDoctor( oBrowse, ar, obj, nElem, nKey ) - редактирование объекта привязки врача
// 05.11.18 editPlannedMonthlyStaff() - плановая месячная трудоемкость персонала
// 29.10.18 editEmployees() - отображение списка персонала организации
// 17.09.18 inputEmployee( oBrowse, ar, nDim, nElem, nKey ) - ввод сотрудника в массив
// 29.11.16 CheckTabNom( obj, get, nKey ) проверка на допустимость табельного номера
// 23.05.17 FillBrowseEmployee( oBrow, aList ) -  прорисовка списка сотрудников
// 24.04.17 CheckDoctorAndAssistant( get, k ) - функция для valid проверки ввода врача и ассистента
// 17.04.17 InputTabNumberDoctor( get, k ) - определить врача по табельному номеру
// 24.04.16 editPlanned( oBrowse, ar, obj, nElem, nKey ) - редактирование объекта плановой трудоемкости
// 17.06.17 validEmployer( get, cEmploeer, obj ) - проверка допустимости сотрудников	в GET-ах
// 17.06.17 put_tab_nom( ltab_nom, lsvod_nom )- формирование строки с табельными номерами сотрудников
// 17.06.17 FillArrayEmployees() - заполнение массива сотрудниками
// 17.06.17 input_kperso() - заполнение массива сотрудниками (для совместимости)
// 17.06.17 st_v_vrach( get, pole_vr, regim ) - ( для совместимости )
// 17.06.17 checkEmployee( get, k ) - проверка ввода в Get сотрудников организации
// 30.11.16 SelectDepartmentAndSubdivision( k, r, c, date1, date2, nTask ) вернуть учреждение и отделение в GET'е
// 26.06.17 s_pl_meds( num ) - ф-ция пустышка для совместимости
//

#include 'hbthread.ch'
#include 'set.ch'
#include 'inkey.ch'
#include 'common.ch'

#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

static strEmployee := 'РЕДАКТИРОВАНИЕ СОТРУДНИКА'

// 01.11.18 редактирование списка сотрудников
function editEmployees( nType )
	local blkEditObject
	local blcCodeColor
	local oBox, aEdit := {}
	local aProperties
	
	if hb_user_curUser:IsAdmin()
		aEdit := { .t., .t., .t., .t. }
	else
		aEdit := { .f., .f., .f., .f. }
	endif
	if hb_user_curUser:IsAdmin()
		if G_SLock( 'edit_Employees' )
			
			oBox := TBox():New( T_ROW, 0, maxrow() - 1, 79, .t. )
			oBox:CaptionColor := 'B/BG'
			oBox:Color := color5

			if nType == 1		// редактирование персонала
				oBox:Caption := 'Список сотрудников организации'
				blcCodeColor := { | | iif(between_date( parr[ nInd ]:Dbegin, parr[ nInd ]:Dend ), { 1, 2 }, { 5, 6 } ) }
				aProperties := { { 'FIO', 'Ф.И.О.', 20, blcCodeColor }, ;
								{ 'TabNom', 'Таб.№', 5, blcCodeColor }, ;
								{ 'SNILS_F', 'СНИЛС', 14, blcCodeColor }, ;
								{ 'Category_F', 'Кат', 3, blcCodeColor }, ;
								{ 'PRVS_F', 'Специальность', 15, blcCodeColor }, ;
								{ 'SvodNom', 'Свод.;таб.№', 5, blcCodeColor } ;
								}
				blkEditObject := { | oBrowse, aObjects, object, nKey | editEmployee( oBrowse, aObjects, object, nKey ) }
			elseif nType == 2	// Корректировка уровней оплаты персонала
//				oBox:Caption := 'Корректировка уровней оплаты персонала'
//				blcCodeColor := { | | if( empty( parr[ nInd ]:Uroven ), { 5, 6 }, { 1, 2 } ) }
//				aProperties := { { 'FIO', 'Ф.И.О.', 36, blcCodeColor }, ;
//								{ 'TabNom', 'Таб.№', 5, blcCodeColor }, ;
//								{ 'DoctorCategory_F', 'Кате;гор.', 4, blcCodeColor }, ;
//								{ 'Uroven_F', 'Класс;оплаты', 14, blcCodeColor }, ;
//								{ 'Otdal_F', 'Отдален-;  ность', 8, blcCodeColor } ;
//								}
//				blkEditObject := { | oBrowse, aObjects, object, nKey | editLevelPayment( oBrowse, aObjects, object, nKey ) }
				
			endif
			// просмотр и редактирование списка сотрудников
			ListObjectsBrowse( 'TEmployee', oBox, asort( TEmployeeDB():GetList(), , , { | x, y | x:FIO < y:FIO } ), 1, aProperties, ;
										blkEditObject, aEdit, , '^<F9>^-печать' )
			G_SUnlock( 'edit_Employees' )
		else
			hb_Alert( 'В данный момент сотрудников редактирует другой администратор. Ждите.', , , 4 )
		endif
	else
		hb_Alert( err_admin, , , 4 )
	endif
	return nil

// 12.09.25 редактирование объекта сотрудник
function editEmployee( oBrowse, aObjects, oEmployee, nKey )	
	local fl := .F.
	local nRow := ROW(), nCol := COL(), tmp_color, i, buf := save_maxrow(), buf1
	local k, r
	local tmp := ' ', tmp1, fl1
	local item, counter
	local mr := 10
	local tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr + 3, k2 := 21

	private tmp_V002 := create_classif_FFOMS( 0, 'V002' ) // PROFIL
    private mfio := space( 50 ), m1uch := 0, m1otd := 0, m1kateg := 1, ;
            much, motd, mname_dolj := space( 30 ), mkateg, mstavka := 1,;
            mvid, m1vid := 0, mtab_nom := 0, msvod_nom := 0, mkod_dlo := 0,;
            mvr_kateg, m1vr_kateg := 0, msnils := space( 11 ), mprofil, m1profil := 0, fl_profil := .f., ;
            mDOLJKAT := space( 15 ), mD_KATEG := ctod( '' ),;
            mSERTIF, m1sertif := 0, mD_SERTIF := ctod( '' ),;
            mPRVS, m1prvs := 0, muroven := 0, motdal := 0,;
            mDBEGIN := boy(sys_date), mDEND := ctod( '' ),;
            gl_area := { 1, 0, maxrow() - 1, 79, 0 }

	if nKey == K_F9
//		PrintEmployees( aObjects )
	elseif nKey == K_F2
		buf1 := savescreen( 13, 4, 19, 77 )
		do while .t.
			tmp_mas := {}
			tmp_kod := {}
			tmp1 := padr( tmp, 50 )
			setcolor( color8 )
			box_shadow( 13, 14, 18, 67 )
			@ 15, 15 say center( 'Введите подстроку (или табельный номер) для поиска', 52 )
			status_key( '^<Esc>^ - отказ от ввода' )
			@ 16, 16 get tmp1 picture '@K@!'
			myread()
			setcolor( color0 )
			if lastkey() == K_ESC .or. empty( tmp1 )
				exit
			endif
			mywait()
			tmp := alltrim( tmp1 )
			// проверка на поиск по таб.номеру
			fl1 := .t.
			for i := 1 to len( tmp )
				if !( substr( tmp, i, 1 ) $ '0123456789' )
					fl1 := .f.
					exit
				endif
			next
			i := 0
			for each item in aObjects
				if fl1
					tmp1 := tmp
					if  tmp1 $ alltrim( str( item:TabNom ) )
						aadd( tmp_mas, item:FIO )
						aadd( tmp_kod, item:ID )
					endif
				else
					if tmp $ Upper( item:FIO() )
						aadd( tmp_mas, item:FIO )
						aadd( tmp_kod, item:ID )
					endif
				endif
			next
			if ( t_len := len( tmp_kod ) ) = 0
				stat_msg( 'Не найдено ни одной записи, удовлетворяющей данному запросу!' )
				mybell( 2 )
				restscreen( 13, 4, 19, 77, buf1 )
				loop
			elseif t_len == 1  // по табельному номру найдена одна строка
				counter := 0
				for each item in aObjects
					counter++
					if item:ID() == tmp_kod[ 1 ]
						nInd := counter
						exit
					endif
				next
				oBrowse:refreshAll()
				fl := .t.
				exit
			else
				box_shadow( mr, 2, 22, 77 )
				SETCOLOR( 'B/BG' )
				@ k1 - 2, 15 say 'Подстрока: ' + tmp
				SETCOLOR( color0 )
				if k1 + t_len + 2 < 21
					k2 := k1 + t_len + 2
				endif
				@ k1, 3 say center( ' Количество найденных фамилий - ' + lstr( t_len ), 74 )
				status_key( '^<Esc>^ - отказ от выбора' )
				if ( i := popup( k1 + 1, 13, k2, 66, tmp_mas, , color0 ) ) > 0
					counter := 0
					for each item in aObjects
						counter++
						if item:ID() == tmp_kod[ i ]
							nInd := counter
							exit
						endif
					next
					oBrowse:refreshAll()
					fl := .t.
				endif
				exit
			endif
		enddo
	elseif nKey == K_INS .OR. nKey == K_ENTER .or. nKey == K_F4
		if ( oEmployee != nil )
			mkod		:= oEmployee:Code
			mfio		:= oEmployee:FIO
			mtab_nom	:= oEmployee:TabNom
			msvod_nom	:= oEmployee:SvodNom
			m1uch		:= oEmployee:Department
			m1otd		:= oEmployee:Subdivision
			m1kateg		:= oEmployee:Category
			mname_dolj	:= oEmployee:Position
			mstavka		:= oEmployee:Stavka
			m1vid		:= oEmployee:Vid
			mkod_dlo	:= oEmployee:KodDLO
			m1vr_kateg	:= oEmployee:DoctorCategory
			mDOLJKAT	:= oEmployee:DoljCategory
			mD_KATEG	:= oEmployee:Dcategory
			m1sertif	:= Iif( oEmployee:IsSertif, 1, 0 )
			mD_SERTIF	:= oEmployee:Dsertif
			m1prvs		:= ret_new_spec( oEmployee:PRVS, oEmployee:PRVSNEW )
			&& if fieldpos( 'profil' ) > 0
			if oEmployee:Profil > 0
				fl_profil := .t.
				&& m1profil := p2->profil 
				m1profil := oEmployee:Profil
			endif
			msnils		:= oEmployee:SNILS
			mDBEGIN		:= oEmployee:Dbegin
			mDEND		:= oEmployee:Dend
		EndIf
		if mstavka <= 0
			mstavka := 1
		endif
	
		much      := inieditspr_bay( A__POPUPBASE, TDepartmentDB():GetList(), m1uch )
		motd      := inieditspr_bay( A__POPUPBASE, TSubdivisionDB():GetList(), m1otd )
		mkateg    := inieditspr_bay( A__MENUVERT, TEmployee():aMenuCategory, m1kateg )
		mvid      := inieditspr_bay( A__MENUVERT, TEmployee():aMenuTypeJob, m1vid )
		mvr_kateg := inieditspr_bay( A__MENUVERT, TEmployee():aMenuDoctorCat, m1vr_kateg )
		msertif   := inieditspr_bay( A__MENUVERT, mm_danet, m1sertif )
		m1prvs    := iif( empty( m1prvs ), space( 4 ), padr( lstr( m1prvs ), 4 ) )
		mprvs     := ret_tmp_prvs( 0, m1prvs )
		
		tmp_color := setcolor( cDataCGet )
		k := maxrow() - 19
		if fl_profil
			--k
			mprofil := inieditspr( A__MENUVERT, getV002(), m1profil )
		endif
		
		buf1 := box_shadow( k - 1, 0, maxrow() - 1, 79, , ;
			if( nKey == K_INS, 'Добавление', 'Редактирование' ) + ' информации о сотруднике', color8 )
			
		setcolor(cDataCGet)
		r := k
		
		@ ++r, 2 say 'Табельный номер' get mtab_nom picture '99999' valid { | g | CheckTabNom( oEmployee, g, nKey ) }
		@ r, 36 say 'Сводный табельный номер' get msvod_nom picture '99999'
		@ ++r, 2 say 'Ф.И.О.' get mfio
		@ ++r, 2 say 'СНИЛС' get msnils picture picture_pf() valid val_snils( msnils, 1 )
		@ ++r, 2 say 'Учр-е' get much ;
					reader { | x | menu_reader( x, { { | k, r, c | SelectDepartmentAndSubdivision( k, r, c ) } }, A__FUNCTION, , , .f. ) }
		@ r, 39 say 'Отделение' get motd when .f.
		@ ++r, 2 say 'Категория' get mkateg ;
				reader { | x | menu_reader( x, TEmployee():aMenuCategory, A__MENUVERT, , , .f. ) }
		@ ++r, 2 say 'Мед.специальность' get mPRVS ;
				reader { | x | menu_reader( x, { { | k, r, c | fget_tmp_V015( k, r, c ) } }, A__FUNCTION, , , .f. ) }
		if fl_profil
			@ ++r,2 say "Профиль" get mprofil ;
				reader { | x | menu_reader( x, tmp_V002, A__MENUVERT_SPACE, , , .f. ) }
		endif
		@ ++r, 2 say 'Наименование должности' get mname_dolj
		@ ++r, 2 say 'Вид работы' get mvid ;
				reader { | x | menu_reader( x, TEmployee():aMenuTypeJob, A__MENUVERT, , , .f. ) }
		@ r, 36 say 'Ставка' color color8 get mstavka picture '9.99'
		@ ++r, 2 say 'Медицинская категория' get mvr_kateg ;
				reader { | x | menu_reader( x, TEmployee():aMenuDoctorCat, A__MENUVERT, , , .f. ) }
		@ ++r, 2 say 'Наименование должности по мед.категории' get mDOLJKAT
		@ ++r, 2 say 'Дата подтверждения мед.категории' get mD_KATEG
		@ ++r, 2 say 'Наличие сертификата' get mSERTIF ;
				reader { | x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
		@ ++r, 2 say 'Дата подтверждения сертификата' get mD_SERTIF
		@ ++r, 2 say 'Код врача для выписки рецептов по ДЛО' get mKOD_DLO pict '99999'
		@ ++r, 2 say 'Дата начала работы в должности' get mDBEGIN
		@ ++r, 2 say 'Дата окончания работы' get mDEND
	
		status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода' )
		myread()
		
		rest_box( buf )
		setcolor( tmp_color )
		
		if lastkey() != K_ESC .and. !empty( mfio ) .and. f_Esc_Enter(1)
			oEmployee:Code := mkod
			oEmployee:FIO := mfio
			oEmployee:TabNom := mtab_nom
			oEmployee:SvodNom := msvod_nom
			oEmployee:Department := m1uch
			oEmployee:Subdivision := m1otd
			oEmployee:Category := m1kateg
			oEmployee:Position := mname_dolj
			oEmployee:Stavka := mstavka
			oEmployee:Vid := m1vid
			oEmployee:KodDLO := mkod_dlo
			oEmployee:DoctorCategory:= m1vr_kateg
			oEmployee:DoljCategory := mDOLJKAT
			oEmployee:Dcategory := mD_KATEG
			oEmployee:IsSertif := if( m1sertif == 0, .f., .t. )
			oEmployee:Dsertif := mD_SERTIF
			oEmployee:PRVSNEW := VAL( m1prvs )
			if fl_profil
				oEmployee:Profil := m1profil
			endif
			oEmployee:SNILS := msnils
			oEmployee:Dbegin := mDBEGIN
			oEmployee:Dend := mDEND
			TEmployeeDB():Save( oEmployee )
			oBrowse:refreshAll()
			fl := .t.
		endif
		rest_box( buf1 )
	endif
	return fl
	
// 29.11.16 проверка на допустимость табельного номера
function CheckTabNom( obj, get, nKey )

	local ret := .F.
	local fl := .t., id := 0, oFind

	if mtab_nom > 0 .and. !( mtab_nom == get:original )
		id := obj:ID()
		if ( oFind := TEmployeeDB():getByTabNom( mtab_nom ) ) != nil
			if nKey == K_ENTER
				if id != oFind:ID()
					fl := .F.
				EndIf
			ElseIf ( nKey == K_INS ) .or. ( nKey == K_F4 )
				fl := .F.
			EndIf
		EndIf
		if !fl
			hb_Alert( 'Указанный табельный номер уже используется в справочнике сотрудников!', , , 4 )
			mtab_nom := get:original
		endif
	EndIf
	return fl

// 06.11.18 редактирование объекта сотрудник для определения уровня оплаты
//static function editLevelPayment( oBrowse, aObjects, oEmployee, nKey )
//	local fl := .F.
//	local nRow := ROW(), nCol := COL(), tmp_color, r1, r2, i, ;
//		buf := save_maxrow(), buf1
//	local old_m1otd, k
//	local tmp := ' ', tmp1, fl1
//	local item, counter
//	local mr := 10
//	local tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr + 3, k2 := 21

//    private muroven := 0, motdal,;
//			bg := { | o, k | get_c_symb( o, k, '√' ) }

//	if nKey == K_F9
//		PrintLevelPayment( aObjects )
//	elseif nKey == K_F8
//		if ( j := f_alert( { padc( 'Выберите порядок сортировки', 60, '.' ) }, ;
//				{ ' По ФИО ', ' По таб.номеру ' }, ;
//				1, 'W+/N', 'N+/N', maxrow() - 2, , 'W+/N,N/BG' ) ) != 0
//			if j == 1
//				asort( aObjects, , , { | x, y | x:FIO < y:FIO } )
//			elseif j == 2
//				asort( aObjects, , , { | x, y | x:TabNom < y:TabNom } )
//			endif
//			oBrowse:refreshAll()
//		endif
//	elseif nKey == K_ENTER
//		&& if ( oEmployee != nil )
//			muroven		:= oEmployee:Uroven
//			motdal		:= iif( oEmployee:Otdal, '√', ' ')
//		&& else
//			&& return fl
//		&& EndIf
	
//		tmp_color := setcolor( cDataCGet )
//		k := maxrow() - 19
//		buf1 := box_shadow( k - 1, 20, 9, 51, , 'Редактирование уровня оплаты', color8 )
//		setcolor(cDataCGet)
		
//        @ k + 1, 22 say 'Класс оплаты (от 0 до 99)' get muroven picture '99' range 0, 99
//        @ k + 2, 22 say 'Отдаленность ' get motdal reader { | o | MyGetReader( o, bg ) }
		
//		status_key('^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода')
//		myread()
		
//		rest_box( buf )
//		setcolor( tmp_color )
		
//		if lastkey() != K_ESC .and. f_Esc_Enter(1)
		
//			oEmployee:Uroven := muroven
//			oEmployee:Otdal := iif( motdal == '√', .t., .f. )
//			TEmployeeDB():Save( oEmployee )
			
//			oBrowse:refreshAll()
//			fl := .t.
//		endif
//		rest_box( buf1 )
//	endif
	
//	return fl
	
// 30.11.16 вернуть учреждение и отделение в GET'е
function SelectDepartmentAndSubdivision( k, r, c, date1, date2, nTask )
	local ret, n := 1
	local aDep, aSub
	local oDep := nil
	local oSub := nil
	
	if empty( glob_uch[1] )
		ar := GetIniVar( tmp_ini, { { 'uch_otd', 'uch', '0' }, ;
									{ 'uch_otd', 'otd', '0' } } )
		glob_uch[1] := int( val( ar[1] ) )
		glob_otd[1] := int( val( ar[2] ) )
	endif

	if k != nil .and. k > 0
		glob_uch[ 1 ] := k
	endif
	if ( oDep := SelectDepartment( r, c, date1, date2 ) ) != nil
		glob_uch := { oDep:ID(), alltrim( oDep:Name() ) }
		SetIniVar( tmp_ini, { { 'uch_otd', 'uch', glob_uch[1] } } )
		
		if type( 'm1otd' ) == 'N' .and. m1otd > 0
			glob_otd[1] := m1otd
		endif
		if ( oSub := SelectSubdivision( r, c, oDep:ID(), date1, date2 ) ) != nil
			glob_otd := { oSub:Code(), alltrim( oSub:Name() ) }
			SetIniVar( tmp_ini, { { 'uch_otd', 'otd', glob_otd[ 1 ] } } )
			
			if valtype( motd ) == 'C'
				n := len( motd )
			endif
			m1otd := glob_otd[ 1 ]
			motd := alltrim( glob_otd[ 2 ] )
			if len( motd ) < n
				motd := padr( motd, n )
			endif
			ret := glob_uch
		endif
	endif
	return ret

&& function input_perso( r, c, is_null, is_rab )
	&& local fl := .f., oEmployee := nil
	
	&& hb_Default( @is_rab, .f. )
	&& if ( oEmployee := SelectEmployee( r, c ) ) != nil
		&& glob_human := { oEmployee:ID, ;
			&& alltrim( oEmployee:FIO ), ;
			&& oEmployee:Department, ;
			&& oEmployee:Subdivision, ;
			&& oEmployee:TabNom, ;
			&& alltrim( oEmployee:Position ) }
		&& fl := .t.
	&& else
		&& if hb_DefaultValue( is_null, .t. )
			&& glob_human := { 0,'', 0, 0, 0 }
			&& fl := .t.
		&& else
			&& fl := .f.
		&& endif
	&& endif
	&& return fl
	
// 05.11.18 выбор сотрудника из списка
function SelectEmployee( r, c )
	static si := 1
	local fl := .f., fl1 := .f., mas_pmt, s_input, s_glob, i
	local idHuman := 0
	local oEmployee := nil
	local aProperties
	local oBox
		
	mas_pmt := { 'Поиск по ~таб.номеру', 'Поиск по ~фамилии' }
	s_input := space( 10 ) + 'Введите табельный номер сотрудника'
	s_glob := glob_human[5]
	if ( i := popup_prompt( r, c, si, mas_pmt ) ) == 0
		return oEmployee
	elseif i == 1
		si := 1
		if ( i := input_value( 18, 6, 20, 73, color1, s_input, s_glob, '99999' ) ) == nil
			return oEmployee
		elseif i == 0
				return oEmployee
		elseif i < 0
			hb_Alert( 'Отрицательный табельный номер не допустим!', , , 4 )
			return oEmployee
		endif
		oEmployee := TEmployeeDB():getByTabNom( i )
		if oEmployee == nil
			hb_Alert( 'Сотрудник с табельным номером ' + lstr( i ) + ' отсутстует в списке персонала!', , , 4 )
		endif
		return oEmployee
	endif
	si := 2
	nPos := 1
	
	aProperties := { { 'FIO', 'Ф.И.О.', 49 } }//, { 'TabNom', 'Таб.N', 5 } }

	oBox := TBox():New( r, 10, maxrow() - 2, 69, .t. )
	oBox:Color := color0
	
	oEmployee := ListObjectsBrowse( 'TEmployee', oBox, TEmployeeDB():GetList(), 1, aProperties, , , , , , .t. )
	return oEmployee
	
// 05.11.18 редактирование участковых врачей
//function editDistrictDoctors()
//	local blkEditObject
//	local oBox, aEdit := {}
//	local i, j, aPatients := {}
//	local aDoctors := TDistrictDoctorDB():GetList()
//	local oDistrictDoctor := nil, item := nil
//	local aProperties

//	aPatients := TPatientDB():getAllDistrict()
//	if len( aPatients ) == 0
//		hb_Alert( 'В картотеке не настроены участки!', , , 4 )
//		return .f.
//	endif

//	for i := 1 to len( aPatients )
//		if ( j := ascan( aDoctors, { | x | x:District == aPatients[ i ] } ) ) == 0
//			oDistrictDoctor := TDistrictDoctor():New()
//			oDistrictDoctor:District := aPatients[ i ]
//		else
//			oDistrictDoctor := aDoctors[ j ]
//		endif
//		oDistrictDoctor:IS := 1
//		TDistrictDoctorDB():Save( oDistrictDoctor )
//		if j == 0
//			aadd( aDoctors, oDistrictDoctor )
//		endif
//	next
//	for each item in aDoctors
//		if ascan( aPatients, item:District ) == 0
//			item:IS := 0
//			TDistrictDoctorDB():Save( item )
//		endif
//	next
//	aDoctors := TDistrictDoctorDB():GetListIS()
//	blkEditObject := { | oBrowse, aObjects, object, nKey | editDistrictDoctor( oBrowse, aObjects, object, nKey ) }
//	aProperties := { { 'District', 'Уч-к', 4 }, { 'View', 'Участковый врач', 67 } }
	
//	aEdit := { .f., .f., .t., .f. }
				
//	oBox := TBox():New( T_ROW, 2, maxrow() - 2, 77, .t. )
//	oBox:Caption := '"Привязка" участковых врачей к участкам'
//	oBox:CaptionColor := 'W+/GR'
//	oBox:Color := color5
//	// просмотр и редактирование списка привязки участковых врачей
//	ListObjectsBrowse( 'TDistrictDoctor', oBox, aDoctors, 1, aProperties, ;
//										blkEditObject, aEdit, , , )
//	return nil

// 05.11.18 редактирование объекта привязки врача
//static function editDistrictDoctor( oBrowse, aObjects, oDistrictDoc, nKey )
//	local fl := .f.
//	local k
//	local oEmployee := nil
//	local oBox

//	private mrazryad, motdal, musl_1, musl_2, mprocent, mprocent2
//	private bg := { | o, k | get_c_symb( o, k, '√' ) }

//	private m1vrach, ; //  := uv->vrach ,;
//			m1vrachv, ; // := uv->vrachv,;
//			m1vrachd, ; // := uv->vrachd,;
//			mvrach  := space(36),;
//			mvrachv := space(36),;
//			mvrachd := space(36),;
//			mtab_nom  := 0,;
//			mtab_nomv := 0,;
//			mtab_nomd := 0
	
//	if nKey == K_F9
////		PrintPaymentTable()
//	elseif nKey == K_ENTER 		// .or. nKey == K_INS .or. nKey == K_F4
//		oEmployee := nil
//		if oDistrictDoc != nil
//			m1vrach	:= oDistrictDoc:IDDoctor
//			m1vrachv	:= oDistrictDoc:IDDoctorAdult
//			m1vrachd	:= oDistrictDoc:IDDoctorChild
//			if ( oEmployee := TEmployeeDB():getByID( m1vrach ) ) != nil
//				mtab_nom := oEmployee:TabNom
//				mvrach := EmployeeDescription( oEmployee )
//			endif
//			if ( oEmployee := TEmployeeDB():getByID( m1vrachv ) ) != nil
//				mtab_nomv := oEmployee:TabNom
//				mvrachv := EmployeeDescription( oEmployee )
//			endif
//			if ( oEmployee := TEmployeeDB():getByID( m1vrachd ) ) != nil
//				mtab_nomd := oEmployee:TabNom
//				mvrachd := EmployeeDescription( oEmployee )
//			endif
//		EndIf
	
//		k := maxrow() - 7		
		
//		oBox := TBox():New( k, 2, maxrow() - 3, 77, .t. )
//		oBox:Caption := 'Редактирование участкового врача'
//		oBox:CaptionColor := color8
//		oBox:Color := cDataCGet
//		oBox:MessageLine := '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода'
//		oBox:View()
	
//		// @ k + 1, 12 say 'Класс оплаты' get mrazryad picture '99' range 0, 99
//		@ k + 1, 4 say 'Участ.врач (все возраста)' get mtab_nom pict '99999' ;
//            valid { | g | InputTabNumberDoctor( g, 1 ) } ;
//           when emptyall( m1vrachv, m1vrachd )
//		@ row(), col() + 1 get mvrach when .f. color color14
//		@ k + 2, 4 say 'Участ.врач (взрослые)' get mtab_nomv pict '99999' ;
//            valid { | g | InputTabNumberDoctor( g, 2 ) } ;
//            when emptyall( m1vrach )
//		@ row(), col() + 1 get mvrachv when .f. color color14
//		@ k + 3, 4 say 'Участ.врач (дети)' get mtab_nomd pict '99999' ;
//            valid { | g | InputTabNumberDoctor( g, 3 ) } ;
//            when emptyall( m1vrach )
//		@ row(), col() + 1 get mvrachd when .f. color color14
	
//		myread()
//		if lastkey() != K_ESC .and. f_Esc_Enter(1)
//			oDistrictDoc:IDDoctor := m1vrach
//			oDistrictDoc:IDDoctorAdult := m1vrachv
//			oDistrictDoc:IDDoctorChild := m1vrachd
//			TDistrictDoctorDB():Save( oDistrictDoc )
//			oBrowse:refreshAll()
//			fl := .t.
//		endif
//	endif
//	return fl
	
// 17.04.17 
function EmployeeDescription( obj )

	return padr( alltrim( obj:ShortFIO() ) + ' (' + Left( TEmployee():aMenuCategory[ obj:Category(), 1], 2 ) + '.)' ;
							+ ' ' + ret_tmp_prvs( obj:PRVS(), obj:PRVSNew() ), 36 )

							
// 17.04.17 определить врача по табельному номеру
function InputTabNumberDoctor( get, k )
	local fl := .t.
	local oEmployee := nil
	
	private tmp := readvar()
	if &tmp != get:original
		if &tmp == 0
			do case
				case k == 1
					m1vrach := 0 ; mvrach := space(36)
				case k == 2
					m1vrachv := 0 ; mvrachv := space(36)
				case k == 3
					m1vrachd := 0 ; mvrachd := space(36)
			endcase
		elseif &tmp != 0
			if ( oEmployee := TEmployeeDB():getByTabNom( &tmp ) ) != nil
				do case
					case k == 1
						m1vrach := oEmployee:ID()
						mvrach := EmployeeDescription( oEmployee )
					case k == 2
						m1vrachv := oEmployee:ID()
						mvrachv := EmployeeDescription( oEmployee )
					case k == 3
						m1vrachd := oEmployee:ID()
						mvrachd := EmployeeDescription( oEmployee )
				endcase
			else
				hb_Alert( 'Сотрудник с табельным номером ' + lstr( &tmp ) + ' не найден в справочнике персонала!', , , 4 )
				fl := .f.
			endif
		endif
		if !fl
			&tmp := get:original
			return .f.
		endif
		do case
			case k == 1
				update_get( 'mvrach' )
			case k == 2
				update_get( 'mvrachv' )
			case k == 3
				update_get( 'mvrachd' )
		endcase
	endif
	return .t.
	
// 05.11.2018 плановая месячная трудоемкость персонала
//function editPlannedMonthlyStaff()
//	static si := 1
//	local blkEditObject
//	local oBox, aEdit := {}
//	local aPlanned := {}
//	local aProperties
//	local i, arr_m, mtitle, k1, k2

//	if ( i := popup_prompt( T_ROW, T_COL + 5, si, { 'Среднемесячные УЕТ', ;
//                                        'УЕТ за конкретный месяц' } ) ) == 0
//		return nil
//	endif

//	si := i
//	private lgod := 0, lmes := 0
//	if i == 1
//		mtitle := 'Плановые среднемесячные УЕТ персонала'
//	else
//		if ( arr_m := year_month( T_ROW, T_COL + 5, , 3 ) ) == nil
//			return nil
//		endif
//		lgod := arr_m[ 1 ]
//		lmes := arr_m[ 2 ]
//		mtitle := 'Плановые УЕТ персонала ' + arr_m[ 4 ]
//	endif

//	stat_msg( 'Пождите, идет заполнение справочника!' )
//	TPlannedMonthlyStaffDB():Clear()				// очистим
//	TPlannedMonthlyStaffDB():Fill( lgod, lmes )	// заполним
//	aPlanned := TPlannedMonthlyStaffDB():getByYearMonth( lgod, lmes )
//	aPlanned := asort( aPlanned, , , { | x, y | x:FIO < y:FIO } )
	
//	blkEditObject := { | oBrowse, aObjects, object, nKey | editPlanned( oBrowse, aObjects, object, nKey ) }
//	aProperties := { { 'TabNom', 'Таб.№', 5 }, { 'FIO', 'Ф.И.О.', 50 }, { 'PlannedMonthly', 'У.Е.Т.', 6 } }
	
//	aEdit := { .f., .f., .t., .f. }
				
//	oBox := TBox():New( 2, 2, maxrow() - 2, 77, .t. )
//	oBox:Caption :=mtitle
//	oBox:CaptionColor := 'W+/GR'
//	oBox:Color := color5
//	// просмотр и редактирование списка трудоемкости
//	ListObjectsBrowse( 'TPlannedMonthlyStaff', oBox, aPlanned, 1, aProperties, ;
//										blkEditObject, aEdit, , , )
//	return nil

// 29.10.18 редактирование объекта плановой трудоемкости
//function editPlanned( oBrowse, aObjects, oPlannedMonthlyStaff, nKey )
//	local fl := .f., tmp_color, buf := save_maxrow(), buf1, k

//	private mm_trud
	
//	if nKey == K_ENTER
//		mm_trud	:= oPlannedMonthlyStaff:PlannedMonthly()
	
//		tmp_color := setcolor( cDataCGet )
//		k := maxrow() - 7		
//		buf1 := box_shadow( k, 16, maxrow() - 5, 61, , 'Редактирование плановой трудоемкости', color8 )
//		setcolor(cDataCGet)
		
//		@ k + 1, 25 say 'Плановая трудоемкость' get mm_trud pict '9999.9'
	
//		status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение смены УЕТ' )
//		myread()
//		rest_box( buf )
//		setcolor( tmp_color )
//		if lastkey() != K_ESC .and. f_Esc_Enter(1)
//			oPlannedMonthlyStaff:PlannedMonthly := mm_trud
//			TPlannedMonthlyStaffDB():Save( oPlannedMonthlyStaff )
//			oBrowse:refreshAll()
//			fl := .t.
//		endif
//		rest_box( buf1 )
//	endif
//	return fl

// 28.01.24 функция для valid проверки ввода врача и ассистента
function CheckDoctorAndAssistant( get, k )
	local fl := .t.
	local old_kod
	local msg1_err := 'Код врача равен коду ассистента! Это недопустимо.'
	local msg2_err := 'Сотрудника с таким кодом нет в базе данных персонала!'
	local oEmpl := nil
	
	if k == 1 // Код врача
		old_kod := mkod_vr
		if empty( mtabn_vr )
			mkod_vr := 0
			mvrach := space( 35 )
		else
			oEmpl := TEmployeeDB():GetByTabNom( mtabn_vr )
			if oEmpl != nil
				if type( 'mkod_as' ) == 'N' .and. oEmpl:ID() == mkod_as
					hb_Alert( msg1_err, , , 4 )
					fl := .f.
				elseif mem_kat_va == 2 .and. !oEmpl:IsDoctor() .and. ;
						!UslugaFeldsher( iif( empty( mshifr1 ), mshifr, mshifr1 ) )
					hb_Alert( 'Данный сотрудник не является ВРАЧОМ по штатному расписанию', , , 4 )
					fl := .f.
				else
					mkod_vr := oEmpl:ID() //perso->kod
					m1prvs := -ret_new_spec( oEmpl:PRVS(), oEmpl:PRVSNEW() )
					mvrach := padr( oEmpl:ShortFIO() + ' ' + ret_tmp_prvs( m1prvs ), 50 )
				endif
			else
				hb_Alert( msg2_err, , , 4 )
				fl := .f.
			endif
		endif
		if old_kod != mkod_vr
			update_get( 'mvrach' )
		endif
	elseif k == 2 // Код ассистента
		old_kod := mkod_as
		if empty( mtabn_as )
			mkod_as := 0
			massist := space( 35 )
		else
			oEmpl := TEmployeeDB():GetByTabNom( mtabn_as )
			if oEmpl != nil
				if oEmpl:ID() == mkod_vr
					hb_Alert( msg1_err, , , 4 )
					fl := .f.
				elseif mem_kat_va == 2 .and. !oEmpl:IsNurse()
					hb_Alert( 'Данный сотрудник не является СРЕДНИМ МЕД.ПЕРСОНАЛОМ по штатному расписанию', , , 4 )
					fl := .f.
				else
					mkod_as := oEmpl:ID()
					massist := alltrim( oEmpl:ShortFIO() )
				endif
			else
				hb_Alert( msg2_err, , , 4 )
				fl := .f.
			endif
		endif
		if old_kod != mkod_as
			update_get( 'massist' )
		endif
	endif
	return fl	
	
// 17.06.17 - проверка допустимости сотрудников	
function validEmployer( get, cEmploeer, obj )
	local fl := .t.
	local oEmpl := nil, cNamevar, mvar
	local msg1 := 'Табельный номер совпадает с номером врача!', ;
		msg2 := 'Табельный номер совпадает с номером ассистента!', ;
		msg3 := 'Введен одинаковый табельный номер медсестры!', ;
		msg4 := 'Введен одинаковый табельный номер санитарки!', ;
		msg5 := 'Код врача равен коду ассистента! Это недопустимо.', ;
		msg6 := 'Сотрудник не найден в справочнике персонала!', ;
		part1msg := 'Данный сотрудник не является '
		part2msg := ' по штатному расписанию.'
	
	cNamevar := readvar()
	mvar := &( readvar() )
	if upper( cEmploeer ) == 'ВРАЧ'
		if empty( mtabn_vr )
			mvrach := space( 35 )
			obj := nil
		else
			if ( ( oEmpl := TEmployeeDB():getByTabNom( mtabn_vr ) ) != nil )
				if type( 'mtabn_as' ) == 'N' .and. oEmpl:TabNom == mtabn_as
					hb_Alert( msg5, , , 4 )
					fl := .f.
				elseif mem_kat_va == 2 .and. !oEmpl:IsDoctor()
					hb_Alert( part1msg + 'ВРАЧОМ' + part2msg, , , 4 )
					fl := .f.
				else
					mvrach := padr( oEmpl:ShortFIO(), 35 )
					obj := oEmpl
				endif
			else
				hb_Alert( msg6, , , 4 )
				fl := .f.
			endif
		endif
		if !fl
			mtabn_vr := 0
			obj := nil
			&& mtabn_vr := 0
			&& mvrach := space( 35 )
			&& obj := nil
		endif
		&& if !empty( mtabn_vr )
			&& obj := oEmpl
		&& endif
		update_get( 'mvrach' )
	elseif  upper( cEmploeer ) == 'АССИСТЕНТ'
		if empty( mtabn_as )
			massist := space( 35 )
			obj := nil
		else
			if ( ( oEmpl := TEmployeeDB():getByTabNom( mtabn_as )) != nil )
				if oEmpl:TabNom == mtabn_vr
					hb_Alert( msg5, , , 4 )
					fl := .f.
				elseif mem_kat_va == 2 .and. !oEmpl:IsNurse()
					hb_Alert( part1msg + 'СРЕДНИМ МЕД.ПЕРСОНАЛОМ' + part2msg, , , 4 )
					fl := .f.
				else
					massist := padr( oEmpl:ShortFIO(), 35 )
					obj := oEmpl
				endif
			else
				hb_Alert( msg6, , , 4 )
				fl := .f.
			endif
		endif
		if !fl
			mtabn_as := 0
			obj := nil
			&& mtabn_as := 0
			&& massist := space( 35 )
			&& obj := nil
		endif
		&& if !empty( mtabn_as )
			&& obj := oEmpl
		&& endif
		update_get( 'massist' )
	elseif  upper( cEmploeer ) == 'МЕДСЕСТРА'
		if mvar == mtabn_vr .and. &cNamevar != 0
			&cNamevar := 0
			hb_Alert( msg1, , , 4 )
			fl := .f.
			return fl
		endif
		if mvar == mtabn_as .and. &cNamevar != 0
			&cNamevar := 0
			hb_Alert( msg2, , , 4 )
			fl := .f.
			return fl
		endif
		if cNamevar == 'MNURSE_1'
			if ( mNurse_1 != 0 ) .and. ( mvar == mNurse_2 .OR. mvar == mNurse_3 )
				mNurse_1 := 0
				hb_Alert( msg3, , , 4 )
				fl := .f.
				return fl
			endif
		elseif cNamevar == 'MNURSE_2'
			if ( mNurse_2 != 0 ) .and. ( mvar == mNurse_1 .OR. mvar == mNurse_3 )
				mNurse_2 := 0
				hb_Alert( msg3, , , 4 )
				fl := .f.
				return fl
			endif
		elseif cNamevar == 'MNURSE_3'
			if ( mNurse_3 != 0 ) .and. ( mvar == mNurse_1 .OR. mvar == mNurse_2 )
				mNurse_3 := 0
				hb_Alert( msg3, , , 4 )
				fl := .f.
				return fl
			endif
		endif
		if fl .and. &cNamevar != 0
			if ( ( oEmpl := TEmployeeDB():getByTabNom( mvar )) != nil )
				if mem_kat_va == 2 .and. !oEmpl:IsNurse()
					hb_Alert( part1msg + 'СРЕДНИМ МЕД.ПЕРСОНАЛОМ' + part2msg, , , 4 )
					fl := .f.
					&cNamevar := 0
				else
					obj := oEmpl
					update_get( &cNamevar )
				endif
			else
				hb_Alert( msg6, , , 4 )
				fl := .f.
				&cNamevar := 0
			endif
		else
			obj := nil
		endif
	elseif  upper( cEmploeer ) == 'САНИТАРКА'
		if mvar == mtabn_vr .and. &cNamevar != 0
			&cNamevar := 0
			hb_Alert( msg1, , , 4 )
			return fl := .f.
		endif
		if mvar == mtabn_as .and. &cNamevar != 0
			&cNamevar := 0
			hb_Alert( msg2, , , 4 )
			return fl := .f.
		endif
		if cNamevar == 'MAIDMAN_1'
			if ( mAidMan_1 != 0 ) .and. ( mvar == mAidMan_2 .OR. mvar == mAidMan_3 )
				mAidMan_1 := 0
				hb_Alert( msg4, , , 4 )
				return fl := .f.
			endif
		elseif cNamevar == 'MAIDMAN_2'
			if ( mAidMan_2 != 0 ) .and. ( mvar == mAidMan_1 .OR. mvar == mAidMan_3 )
				mAidMan_2 := 0
				hb_Alert( msg4, , , 4 )
				return fl := .f.
			endif
		elseif cNamevar == 'MAIDMAN_3'
			if ( mAidMan_3 != 0 ) .and. ( mvar == mAidMan_1 .OR. mvar == mAidMan_2 )
				mAidMan_3 := 0
				hb_Alert( msg4, , , 4 )
				return fl := .f.
			endif
		endif
		if fl .and. &cNamevar != 0
			if ( ( oEmpl := TEmployeeDB():getByTabNom( mvar ) ) != nil )
				if mem_kat_va == 2 .and. !oEmpl:IsAidman()
					hb_Alert( part1msg + 'МЛАДШИМ МЕД.ПЕРСОНАЛОМ' + part2msg, , , 4 )
					fl := .f.
					&cNamevar := 0
				else
					obj := oEmpl
					update_get( &cNamevar )
				endif
			else
				hb_Alert( msg6, , , 4 )
				fl := .f.
				&cNamevar := 0
			endif
		else
			obj := nil
		endif
	endif
	return fl
	
// 17.06.17 - заполнение массива сотрудниками (для совместимости)
//function input_kperso()
//	local aRet := FillArrayEmployees()

//	if empty( aRet )
//		aRet := nil
//	endif
//	return aRet
		
// 17.06.17 - заполнение массива сотрудниками
function FillArrayEmployees()
	local mas1 := {}, buf := savescreen(), i, arr := {},;
		mas3 := { { 5, 0 }, }, ;
		mas2 := { { 1, 'Таб.N' }, ;
				{ 2, '  Ф.И.О.' } }, ;
		blk := { | oBrowse, ar, nDim, nElem, nKey | inputEmployee( oBrowse, ar, nDim, nElem, nKey ) }

	if len( mas1 ) == 0
		aadd( mas1, { 0, space( 50 ), 0 } )
	endif
	change_attr()
	Arrn_Browse( 2, 9, maxrow() - 2, 70, mas1, mas2, 1, , color1, 'Ввод списка персонала', 'G+/B', ;
				.t., , mas3, blk, { .t., .t., .t. } )
	for i := 1 to len( mas1 )
		if mas1[ i, 1 ] > 0 .and. ascan( arr, { | x | x[ 1 ] == mas1[ i, 3 ] } ) == 0
			aadd( arr, { mas1[ i, 3 ], '', mas1[ i, 1 ] } )
		endif
	next
	if len( arr ) == 0
		arr := nil
	endif
	restscreen( buf )
	return arr
	
// 17.09.18 - ввод сотрудника в массив
function inputEmployee( oBrowse, parr, nDim, nElem, nKey )
	local nRow := ROW(), nCol := COL(), flag := .f., mpic := { '99999' }
	local nTabNom
	local oEmployee
	local s_input, s_glob
		
	s_input := space( 10 ) + 'Введите табельный номер сотрудника'
	s_glob := glob_human[5]
	do case
		case nKey == K_DOWN
			oBrowse:panHome()
		case nKey == K_INS
			if ( nTabNom := input_value( 18, 6, 20, 73, color1, s_input, s_glob, '99999' ) ) == nil
				flag := .f.
			elseif nTabNom == 0
				flag := .f.
			elseif nTabNom < 0
				hb_Alert( 'Отрицательный табельный номер не допустим!', , , 4 )
				flag := .f.
			else
				oEmployee := TEmployeeDB():getByTabNom( nTabNom )
				if isnil( oEmployee )
					hb_Alert( 'Сотрудник с табельным номером ' + lstr( nTabNom ) + ' отсутстует в списке персонала!', , , 4 )
					flag := .f.
				else
					parr[ nElem, 1 ] := nTabNom
					parr[ nElem, 2 ] := oEmployee:FIO
					parr[ nElem, 3 ] := oEmployee:ID
					flag := .t.
				endif
			endif
		otherwise
	endcase
	@ nRow, nCol say ''
	return flag
	
// 17.06.17 - формирование строки с табельными номерами сотрудников
//function put_tab_nom( ltab_nom, lsvod_nom )
//	local s := lstr( ltab_nom )

//	if !empty( lsvod_nom ) .and. ltab_nom != lsvod_nom
//		s := '(' + lstr( lsvod_nom ) + ')' + s
//	endif
//	return s

// 17.06.17 ( для совместимости )
//function st_v_vrach( get, pole_vr, regim )
// regim = 0  - по БД mo_pers
// regim = 1  - медсестры по БД plat_ms
// regim = 2  - санитарки по БД plat_ms
// regim = 3  - по БД mo_pers через VGET
//	local lval, lpole, fl := .t.
	
//	hb_Default( @regim, 0 )
//	if regim == 3
//		lval := get:varget()
//		lpole := readvar()
//	else
//		lval := &(readvar())
//		lpole := readvar()
//	endif
//	if lval == 0
//		&pole_vr := space( 30 )
//	elseif lval > 0
//		if equalany( regim, 0, 3 )
//			select PERSO
//			find ( str( lval, 5 ) )
//			if found()
//				&pole_vr := padr( fam_i_o( perso->fio ), 30 )
//			else
//				fl := .f.
//			endif
//		else   // regim == 1 или 2
//			select MS
//			find ( str( regim, 1 ) + str( lval, 5 ) )
//			if found()
//				&pole_vr := padr( ms->fio, 30 )
//			else
//				fl := .f.
//			endif
//		endif
//		if !fl
//			//&lpole := get:original
//			get:varput( get:original )
//			hb_Alert( 'Сотрудника с таким кодом нет в справочнике персонала!', , , 4 )
//			return .f.
//		endif
//	else
//		//&lpole := get:original
//		get:varput( get:original )
//		hb_Alert( 'Недопустимо вводить отрицательное число!', , , 4 )
//		return .f.
//	endif
//	if regim < 3
//		update_get( pole_vr )
//	endif
//	return .t.

// 26.06.17 - ф-ция пустышка для совместимости
//function s_pl_meds( num )

//	return nil
	
* 17.06.17 проверка ввода в Get сотрудников организации
&& function checkEmployee( get, k )
	&& local fl := .t., old_kod, old_tabn
	&& local s, i, j, mvar, amsg, arr_zf,;
		&& msg1_err := 'Код врача равен коду ассистента! Это недопустимо.', ;
		&& msg2_err := 'Сотрудник с указанным табельным номером отсутствует в справочнике персонала!'
	&& local oEmpl := nil, oldObjEmpl := nil

	&& if k == 1 // Код врача
		&& old_kod := mkod_vr
		&& old_tabn := if( ( oldObjEmpl := TEmployeeDB():getByCode( mkod_vr ) ) != nil, oldObjEmpl:TabNom, 0 )
		&& if empty( mtabn_vr )
			&& mkod_vr := 0
			&& mvrach := space( 35 )
		&& else
			&& if ( ( oEmpl := TEmployeeDB():getByTabNom( mtabn_vr ) ) != nil )
				&& if type( 'mkod_as' ) == 'N' .and. oEmpl:Code() == mkod_as
					&& mtabn_vr := old_tabn
					&& hb_Alert( msg1_err, , , 4 )
					&& fl := .f.
				&& elseif mem_kat_va == 2 .and. !oEmpl:IsDoctor()
					&& mtabn_vr := old_tabn
					&& hb_Alert( 'Сотрудник не является ВРАЧОМ согласно справочника персонала!', , , 4 )
					&& fl := .f.
				&& else
					&& mkod_vr := oEmpl:Code()
					&& mvrach := padr( oEmpl:FIO, 35 )
				&& endif
			&& else
				&& mtabn_vr := old_tabn
				&& hb_Alert( msg2_err, , , 4 )
				&& fl := .f.
			&& endif
		&& endif
		&& if old_kod != mkod_vr
			&& update_get( 'mvrach' )
			&& update_get( 'mtabn_vr' )
		&& endif
	&& elseif k == 2 // Код ассистента
		&& old_kod := mkod_as
		&& if empty( mtabn_as )
			&& mkod_as := 0
			&& massist := space( 35 )
		&& else
			&& if ( ( oEmpl := TEmployeeDB():getByTabNom( mtabn_as ) ) != nil )
				&& if oEmpl:Code() == mkod_vr
					&& hb_Alert( msg1_err, , , 4 )
					&& fl := .f.
				&& elseif mem_kat_va == 2 .and. !oEmpl:IsNurse()
					&& hb_Alert( 'Данный сотрудник не является СРЕДНИМ МЕД.ПЕРСОНАЛОМ по штатному расписанию', , , 4 )
					&& fl := .f.
				&& else
					&& mkod_as := oEmpl:Code()
					&& massist := padr( oEmpl:FIO, 35 )
				&& endif
			&& else
				&& hb_Alert( msg2_err, , , 4 )
				&& fl := .f.
			&& endif
		&& endif
		&& if old_kod != mkod_as
			&& update_get( 'massist' )
		&& endif
	&& elseif k == 3  // код медсестры
		&& mvar := &(readvar())
		&& if mvar == 0
			&& mvar := 'P' + readvar()
			&& &mvar := 0
		&& elseif mvar != get:original
			&& select MS
			&& find ( '1' + str( mvar, 5 ) )
			&& if found()
				&& mvar := 'P' + readvar()
				&& &mvar := ms->(recno())
			&& else
				&& hb_Alert( 'Медсестра с данным кодом не найдена!', , , 4 )
				&& fl := .f.
			&& endif
		&& endif
	&& elseif k == 4  // код санитарки
		&& mvar := &(readvar())
		&& if mvar == 0
			&& mvar := 'P' + readvar()
			&& &mvar := 0
		&& elseif mvar != get:original
			&& select MS
			&& find ( '2' + str( mvar, 5 ) )
			&& if found()
				&& mvar := 'P' + readvar()
				&& &mvar := ms->(recno())
			&& else
				&& hb_Alert( 'Санитарка с данным кодом не найдена!', , , 4 )
				&& fl := .f.
			&& endif
		&& endif
	&& endif
	&& return fl