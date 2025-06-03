//
//
// 05.11.18 editSubdivisions() - редактирование списка отделений
// 21.10.18 editSubdivision( oBrowse, aObjects, oSubdivision, nKey ) - редактирование объекта отделение
// 27.09.18 inputN_otd( r, c, fl_all_uch, fl_all_otd, a_inp_uch, /*@*/c_otd )
// 23.09.18 static function ini_kod_podr( lkod )
// 23.09.18 static function get_kod_podr( k, r, c )
// 07.05.17 SelectSubdivision( r, c, department, dBegin, dEnd, nTask ) - выбор отделения
// 05.05.17 MultipleSelectedSubdivision( r, c, nTask, dBegin, dEnd, oUser ) - возвращает массив выбранных объектов Подразделений 
// 14.02.17 choiceDivision( r, c, kk, aVar, cName ) -
// get_kod_podr( k, r, c ) -
// titleN_otd( arr_o, lsh, c_otd )
//

#include 'set.ch'
#include 'inkey.ch'
#include 'hbthread.ch'
#include 'common.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

static strSubdivision := 'РЕДАКТИРОВАНИЕ ОТДЕЛЕНИЯ'

// 27.03.24 редактирование списка отделений
function editSubdivisions()
	local blkEditObject
	local aEdit
	local oBox
	local aProperties
	local blk := { | | iif( between_date( parr[ nInd ]:Dbegin, parr[ nInd ]:Dend ), { 1, 2 }, { 5, 6 } ) }
	
	private oDepartment := nil	// для передачи в ф-цию editSubdivision
	
	private tmp_V002 := create_classif_FFOMS( 1, 'V002' ) // PROFIL
	private tmp_V020 := create_classif_FFOMS( 1, 'V020' ) // PROFIL_K
	private tmp_V006 := create_classif_FFOMS( 1, 'V006' ) // USL_OK
	//private tmp_V008 := create_classif_FFOMS(1,'V008') // VIDPOM
	//private tmp_V010 := create_classif_FFOMS(1,'V010') // IDSP
	private mm_tiplu := {;
		{ 'стандартный'                          ,0            }, ;  // 1
		{ 'скорая помощь'                        ,TIP_LU_SMP   }, ;  // 2
		{ 'дисп-ия детей-сирот в стационаре'     ,TIP_LU_DDS   }, ;  // 3
		{ 'дисп-ия детей-сирот под опекой'       ,TIP_LU_DDSOP }, ;  // 4
		{ 'профилактика несовешеннолетних'       ,TIP_LU_PN    }, ;  // 5
		{ 'предварит.осмотры несовешеннолетних'  ,TIP_LU_PREDN }, ;  // 6
		{ 'периодич.осмотры несовешеннолетних'   ,TIP_LU_PERN  }, ;  // 7
		{ 'дисп-ия/профосмотр взрослых'          ,TIP_LU_DVN   }, ;  // 8
		{ 'пренатальная диагностика'             ,TIP_LU_PREND }, ;  // 9
		{ 'гемодиализ'                           ,TIP_LU_H_DIA }, ;  // 10
		{ 'перитонеальный диализ'                ,TIP_LU_P_DIA }, ;   // 11
		{ 'жидкостная цитология'                ,TIP_LU_G_CIT }, ;  // 12
		{ 'неотложная медицинская помощь'       ,TIP_LU_NMP }, ;  // 13
		{ 'COVID углубленная диспансеризация взрослого населения',TIP_LU_DVN_COVID }, ;  // 15
		{ 'амбулаторная медицинская реабилитация',TIP_LU_MED_REAB }, ;  // 16
		{ 'постановка на диспансерный учет онкопациетов в поликлинике',TIP_LU_ONKO_DISP }, ;  // 17
		{ 'диспансеризация репродуктивного здоровья',TIP_LU_DRZ } }  // 18

	private mm1tiplu := aclone( mm_tiplu )
	
	if ascan( glob_klin_diagn, 1 ) > 0
		aadd( mm_tiplu, { 'жидкостная цитология рака шейки матки', TIP_LU_G_CIT } )
	elseif ascan(glob_klin_diagn,2) > 0
		aadd( mm_tiplu, { 'пренатальный скрининг наруш.внутр.разв.', TIP_LU_G_CIT } )
	endif
	
	if ( oDepartment := SelectDepartment( T_ROW - 1, T_COL + 5, sys_date ) ) == nil
		return nil
	endif
	hb_ADel( mm1tiplu, 7 , .t. )
	hb_ADel( mm1tiplu, 6 , .t. )
	
	blkEditObject := { | oBrowse, aObjects, object, nKey, oDep | editSubdivision( oBrowse, aObjects, object, nKey ) }
	aProperties := { { 'Name', 'Наименование отделения', 30, blk }, { 'ShortName', 'Сокр.;наим.', 5, blk }, { 'TypeLU_F', 'Лист учета', 10, blk }, ;
						{ 'Profil_F', 'Профиль', 15, blk } }
	
	aEdit := if( hb_user_curUser:IsAdmin(), { .t., .t., .t., .t. }, { .f., .f., .f., .f. } )

	// просмотр и редактирование списка отделений
	oBox := TBox():New( T_ROW, 2, maxrow() - 1, 78, .t. )
	oBox:Caption := 'Список отделений подразделения'
	oBox:Color := color5
	ListObjectsBrowse( 'TSubdivision', oBox, TSubdivisionDB():GetList( oDepartment:ID() ), 1, aProperties, ;
										blkEditObject, aEdit, , , )

	return nil

// 15.02.20 редактирование объекта отделение
function editSubdivision( oBrowse, aObjects, oSubdivision, nKey )
	local fl := .f., _fl := .f.
	local k, i, ii := 1
	local oBox

	private mmtiplu, m1mtiplu
	private mtyppodr, m1typpodr
	private mmprofil, m1mprofil
	private mmprofilK, m1mprofilK
	private mmIDUMP, m1mIDUMP
	private mmkodpodr, m1mkodpodr
	//private mmIDSP, m1mIDSP
	//private mmIDVMP, m1mIDVMP
	&& private mmAdress, m1mAddress
	&& private mm_adres_podr := {}
	private mmCodeSubTFOMS, m1mCodeSubTFOMS

	if nKey == K_F9
	elseif nKey == K_F2
	elseif nKey == K_INS .or. nKey == K_ENTER .or. nKey == K_F4
		if ( isnil( oSubdivision ) )
			return fl
		endif
		// вид листа учета
		m1mtiplu 	:= oSubdivision:TypeLU
		mmtiplu		:= inieditspr( A__MENUVERT, mm_tiplu, m1mtiplu )
		
		// тип подразделения
		m1typpodr	:= oSubdivision:TypePodr
		mtyppodr	:= inieditspr_bay( A__MENUVERT, mm_danet, m1typpodr )
		
		// профиль
		m1mprofil 	:= oSubdivision:Profil
		mmprofil	:= inieditspr( A__MENUVERT, getV002(), m1mprofil )
		m1mprofilK 	:= oSubdivision:ProfilK
		// mmprofilK	:= inieditspr( A__MENUVERT, glob_V020, m1mprofilK )
		mmprofilK	:= inieditspr( A__MENUVERT, getV020(), m1mprofilK )
		// условия оказания медицинской помощи
		m1mIDUMP	:= oSubdivision:IDUMP
		// mmIDUMP	:= inieditspr( A__MENUVERT, glob_V006, m1mIDUMP )
		mmIDUMP	:= inieditspr( A__MENUVERT, getV006(), m1mIDUMP )
		// код подразделения
		mmkodpodr := ini_kod_podr( oSubdivision:KodPodr )

		m1mCodeSubTFOMS := oSubdivision:CodeSubTFOMS
		mmCodeSubTFOMS := inieditspr( A__MENUVERT, mm_otd_dep, m1mCodeSubTFOMS )
		
		if oSubdivision:IDDepartment() == 0
			oSubdivision:IDDepartment := oDepartment:ID()
		endif

		k := maxrow() - 15 - iif( is_task( X_PLATN ), 2, 0 ) - iif( is_task( X_ORTO ), 2, 0 ) - 1
		
//		oBox := TBox():New( k - 1, 2, maxrow() - 1, 77, .t. )

		oBox := TBox():New( k, 2, maxrow() - 1, 77, .t. )
		oBox:Caption := if( nKey == K_INS .or. nKey == K_F4, 'Добавление', 'Редактирование' ) + ' информации об отделении'
		oBox:CaptionColor := color8
		oBox:MessageLine := '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода'
		oBox:View()

		@ k + ii++, 4 say 'Наименование отделения' get oSubdivision:Name	//mname
		@ k + ii++, 4 say 'Сокращенное наименование отделения' get oSubdivision:ShortName	//mshortname
		@ k + ii++, 4 say 'Адрес отделения' get oSubdivision:Address picture '@S57'
		
		@ k + ii++, 4 say 'Вид листа учета при вводе данных' get mmtiplu ;
						reader { | x | menu_reader( x, mm_tiplu, A__MENUVERT, , , .f. ) }
						
		@ k + ii++, 4 say 'Является данное отделение приёмным покоем стационара' get mtyppodr ;
						reader { | x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
						
		@ k + ii++, 4 say 'Профиль мед.помощи' get mmprofil ;
						reader { | x | menu_reader( x, tmp_V002, A__MENUVERT_SPACE, , , .f. ) }
		@ k + ii++, 4 say 'Профиль койки' get mmprofilK ;
						reader { | x | menu_reader( x, tmp_V020, A__MENUVERT_SPACE, , , .f. ) }
		@ k + ii++, 4 say 'Условия оказания медицинской помощи' get mmIDUMP ;
						reader { | x | menu_reader( x, tmp_V006, A__MENUVERT, , , .f. ) }
		@ k + ii++, 4 say 'Код подразделения из паспорта ЛПУ' get mmkodpodr ;
						reader { | x | menu_reader( x, { { | k, r, c | get_kod_podr( k, r, c ) } }, A__FUNCTION, , , .f. ) }

/*		@ k + ii++, 4 say 'Способ оплаты' get mmIDSP ;
						// reader { | x | menu_reader( x, tmp_V010, A__MENUVERT, , , .f. ) }
		@ k + ii++, 4 say 'Вид мед.помощи' get mmIDVMP ;
						// reader { | x | menu_reader( x, tmp_V008, A__MENUVERT, , , .f. ) }
*/
						
		@ k + ii++, 4 say 'Дата начала работы в задаче ОМС' get oSubdivision:DBegin
		@ k + ii++, 9 say 'Дата окончания работы в задаче ОМС' get oSubdivision:DEnd
		
		if is_otd_dep
			@ k + ii++, 4 say 'По справочнику ТФОМС' get mmCodeSubTFOMS ;
						reader { | x | menu_reader( x, mm_otd_dep, A__MENUVERT_SPACE, , , .f. ) } picture '@S50'
		endif                       
		
		if is_task( X_PLATN )
			@ k + ii++, 4 say 'Дата начала работы в задаче "Платные услуги"' get oSubdivision:DBeginP
			@ k + ii++, 9 say 'Дата окончания работы в задаче "Платные услуги"' get oSubdivision:DEndP
		endif
		if is_task( X_ORTO )
			@ k + ii++, 4 say 'Дата начала работы в задаче "Ортопедия"' get oSubdivision:DBeginO
			@ k + ii++, 9 say 'Дата окончания работы в задаче "Ортопедия"' get oSubdivision:DEndO
		endif
		@ k + ii++, 4 say 'План врачебных приемов на месяц' get oSubdivision:Plan_VP picture '999999'
		@ k + ii++, 4 say 'План профилактик на месяц' get oSubdivision:Plan_PF picture '999999'
		@ k + ii++, 4 say 'План приемов на дому на месяц' get oSubdivision:Plan_PD picture '999999'
		
		myread()
		if lastkey() != K_ESC .and. ! empty( oSubdivision:Name ) .and. f_Esc_Enter( 1 )
			// вид листа учета
			oSubdivision:TypeLU := m1mtiplu
			oSubdivision:TypePodr := m1typpodr
			// профиль
			oSubdivision:Profil := m1mprofil
			oSubdivision:ProfilK := m1mprofilK
			// условия оказания медицинской помощи
			oSubdivision:IDUMP := m1mIDUMP
			// код подразделения
			oSubdivision:KodPodr := mmkodpodr
			oSubdivision:CodeSubTFOMS := m1mCodeSubTFOMS
			//oSubdivision:IDSP := m1mIDSP
			//oSubdivision:IDVMP := m1mIDVMP
			
/*if is_adres_podr
  if ( i := ascan( glob_adres_podr, { | x | x[ 1 ] == glob_mo[ _MO_KOD_TFOMS ] } ) ) > 0
    for j := 1 to len( glob_adres_podr[ i, 2 ] )
	 aadd( mm_adres_podr, { glob_adres_podr[ i, 2, j, 3 ], glob_adres_podr[ i, 2, j, 2 ] } )
	next
  endif
  Ins_Array(arr[US_EDIT_SPR],7,{"ADRES_PODR","N",2,0,,;
                                {|x|menu_reader(x,mm_adres_podr,A__MENUVERT,,,.f.)},;
                                0,{|x|inieditspr(A__MENUVERT,mm_adres_podr,x)},;
                                "Адрес удалённого подразделения для стационара"})
endif                       
if is_adres_podr .and. (i := ascan(glob_adres_podr, {|x| x[1] == glob_mo[_MO_KOD_TFOMS] })) > 0
 G_Use(dir_server()+"mo_otd",,"OTD")
 go top
 do while !eof()
    if otd->ADRES_PODR > 0 .and. (j := ascan(glob_adres_podr[i,2], {|x| x[2] == otd->ADRES_PODR })) > 0 ;
                          .and. !(otd->CODE_TFOMS == glob_adres_podr[i,2,j,1])
     G_RLock(forever)
     otd->CODE_TFOMS := glob_adres_podr[i,2,j,1]
     UnLock
   endif
   skip
 enddo
 close databases                      
endif*/
			TSubdivisionDB():Save( oSubdivision )
			fl := .t.
		endif
		oBox := nil	// очистим объект TBox
	elseif nKey == K_DEL
		&& stat_msg( 'Ждите! Производится проверка на допустимость удаления отделения' )
//		_fl := ! empty( TEmployeeDB():GetListBySubdivision( oSubdivision:ID() ))
//		if !_fl
//			_fl := ! THumanDB():HasSubdivision( oSubdivision )
//		endif
//		if _fl
//			_fl := ! TContractDB():HasSubdivision( oSubdivision )
//		endif
//		if _fl
//			TSubdivisionDB():Delete( oSubdivision )
//			fl := .t.
//		else
//			hb_Alert( { 'Данное отделение используется.', 'Удаление запрещено!' }, , , 4 )
//		endif
	endif
	return fl
	
static function ini_kod_podr( lkod )
	local s := space( 10 )
	local obj := nil
	
	obj := T_Mo_podrDB():GetByCodePodr( lkod )
	if ! isnil( obj )
		s := '(' + alltrim( obj:KodOtd ) + ') ' + alltrim( obj:Name )
	endif
	return s

static function get_kod_podr( k, r, c )
	static arr
	local ret, ret_arr, tmp_select
	local aObject, item
	
	if isnil( arr ) // только при первом вызове
		arr := {}
		aObject := T_Mo_podrDB():GetListByCodeTFOMS( glob_mo[ _MO_KOD_TFOMS ] )
		for each item in aObject
			aadd( arr, { '(' + alltrim( item:KodOtd ) + ') ' + alltrim( item:Name ), item:KodOtd } )
		next
	endif
	popup_2array( arr, -r, c, k, 1, @ret_arr, 'Выбор из паспорта ЛПУ', 'GR+/RB', 'BG+/RB,N/BG' )
	if valtype( ret_arr ) == 'A'
		ret := array( 2 )
		ret[ 1 ] := ret_arr[ 2 ]
		ret[ 2 ] := ret_arr[ 1 ]
	endif
	return ret

// 07.05.17 - выбор отделения
function SelectSubdivision( r, c, department, dBegin, dEnd, nTask )
	local kk, idDepartment := 0
	local aSubdivisions
	local ret := nil
	
	if valtype( department ) == 'N'
		idDepartment := department
	elseif valtype( department ) == 'O' .and. department:ClassName() == upper( 'TDepartment' )
		idDepartment := department:ID()
	endif
	aSubdivisions := TSubdivisionDB():GetList( idDepartment, hb_user_curUser, hb_defaultValue( nTask, X_OMS ), dBegin, dEnd )
	if ( kk := Len( aSubdivisions ) ) == 0						// справочник пустой
		hb_Alert( 'Пустой справочник отделений', , , 4 )
	elseif kk == 1												// только одна строка в справочнике
		ret := aSubdivisions[ 1 ]
	elseif kk > 1												// выбираем из нескольких возможных элементов
		ret := choiceDivision( r, c, kk, aSubdivisions, 'Отделения' )
	endif
	if ret != nil
		glob_otd := { ret:ID(), ret:Name() }
		SetIniVar( tmp_ini, { { 'uch_otd', 'otd', glob_otd[ 1 ] } } )
	endif
	return ret
	
// 14.02.17
function choiceDivision( r, c, kk, aVar, cName )
	local item, i, nInd, k, c2
	local aTemp := {}
	local buf := savescreen()
	local ret := nil

	for each item in aVar					// заполним массив выбора
		aadd( aTemp, item:Name() )
	next
	if r < 0 // т.е. GET находится внизу экрана
		k := abs( r ) - 2
		if ( r := k - kk - 1 ) < 2
			r := 2
		endif
	else
		if ( k := r + kk + 1 ) > maxrow() - 2
			k := maxrow() - 2
		endif
	endif
	c2 := c + 35 + 1
	if c2 > 77
		c2 := 77 ; c := 76 - 35
	endif
	
	i := 1
	status_key( '^<Esc>^ отказ;  ^<Enter>^ выбор' )
	if ( nInd := popup( r, c, k, c2, aTemp, i, color_uch, .t., 'fmenu_reader', , ;
			cName, col_tit_uch ) ) > 0
		ret := aVar[ nInd ]
	endif
	restscreen( buf )
	return ret
	
// 05.05.17 - возвращает массив выбранных объектов Подразделений 
function MultipleSelectedSubdivision( r, c, nTask, dBegin, dEnd, oUser )
	local aRet := {}, oDep
	local aSubdivisions := {}
	
	if ( oDep := SelectDepartment( r, c, dBegin, dEnd ) ) != nil
		aSubdivisions := TSubdivisionDB():GetList( oDep:ID(), hb_user_curUser, ;
				hb_defaultValue( nTask, X_OMS ), dBegin, dEnd )
		aRet := ChoiceObjectFromArray( r, c, aSubdivisions, .t., 'Отделения' )
	endif
	return aRet

// 27.09.18
//function inputN_otd( r, c, fl_all_uch, fl_all_otd, a_inp_uch, /*@*/c_otd )
//	static st_otd := {}
//	local i, k
//	local mas_o := {}, mas := {}, t_mas, c2
//	local buf := savescreen(), l_a_otd
//	local aSubdivisions := {}, item
//	local selectedDepartmentArray, nDepartment

//	if isnil ( a_inp_uch ) // запросить учреждение
//		selectedDepartmentArray := input_uch( r, c, iif( fl_all_uch, , sys_date ) )
//	else  // учреждение уже было ранее выбрано
//		selectedDepartmentArray := glob_uch
//	endif
//	if ! isnil( selectedDepartmentArray )
//		mywait()
//		nDepartment := selectedDepartmentArray[ 1 ]
//		aSubdivisions := TSubdivisionDB():GetList( nDepartment, hb_user_curUser, , sys_date, sys_date )
//		for each item in aSubdivisions
//			aadd( mas_o, item:Name )
//			aadd( mas, item:ID )
//		next
//		count_otd := c_otd := len( mas )
//		if count_otd == 1
//			glob_otd := { mas[ 1 ], mas_o[ 1 ] }
//			restscreen( buf )
//			return { glob_otd }
//		endif
//		if r < 0 // т.е. GET находится внизу экрана
//			k := abs( r ) - 2
//			if ( r := k - count_otd - 1 ) < 2
//				r := 2
//			endif
//		else
//			if ( k := r + count_otd + 1 ) > maxrow() - 2
//				k := maxrow() - 2
//			endif
//		endif
//		c2 := c + 35 + 1
//		if c2 > 77
//			c2 := 77 ; c := 76 - 35
//		endif
//		t_mas := aclone( mas_o )
//		if len( st_otd ) == 0
//			if glob_otd[ 1 ] > 0
//				aadd( st_otd, glob_otd[ 1 ] )
//			else
//				aeval( mas, { | x | aadd( st_otd, x ) } )
//			endif
//		endif
//		aeval( t_mas, { | x, i | t_mas[ i ] := if( ascan( st_otd, mas[ i ] ) > 0, ' * ', '   ' ) + t_mas[ i ] } )
//		status_key( '^<Esc>^ отказ;  ^<Enter>^ подтверждение;  ^<Ins>^ смена признака выбора отделения' )
//		do while .t.
//			l_a_otd := nil
//			if popup( r, c, k, c2, t_mas, i, color_uch, .t., 'fmenu_reader', , alltrim( glob_uch[ 2 ] ), col_tit_uch ) > 0
//				l_a_otd := {} ; st_otd := {}
//				for i := 1 TO len( t_mas )
//					if '*' == substr( t_mas[ i ], 2, 1 )
//						aadd( l_a_otd, { mas[ i ], mas_o[ i ] } )
//						aadd( st_otd, mas[ i ] )
//					endif
//				next
//				if empty( l_a_otd )
//					func_error( 4, 'Необходимо отметить хотя бы одно отделение!' )
//					loop
//				else
//					if ( k := len( l_a_otd ) ) == 1
//						glob_otd := l_a_otd[ 1 ]
//					endif
//					exit
//				endif
//			else
//				exit
//			endif
//		enddo
//	endif
//	restscreen( buf )
//	return l_a_otd

//
//function titleN_otd( arr_o, lsh, c_otd )
//	local i, t_arr[ 2 ], s := ''

//	if !( type( 'count_otd' ) == 'N' )
//		count_otd := iif( c_otd == nil, 1, c_otd )
//	endif
//	if count_otd > 1 .and. valtype( arr_o ) == 'A'
//		if count_otd == len( arr_o )
//			add_string( center( '[ по всем отделениям ]', lsh ) )
//		else
//			aeval( arr_o, { | x | s += '"' + alltrim( x[ 2 ] ) + '", ' } )
//			s := substr( s, 1, len( s ) - 2 )
//			for i := 1 to perenos( t_arr, s, lsh )
//				add_string( center( alltrim( t_arr[ i ] ), lsh ) )
//			next
//		endif
//	endif
//	return nil
