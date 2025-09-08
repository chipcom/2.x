#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'function.ch'
#include 'dbstruct.ch'
#include 'dbinfo.ch'
#include 'common.ch'
#include 'property.ch'

static sforever := 'FOREVER'

// Описываем класс TDataAccessDB
CREATE CLASS TDataAccessDB
	VISIBLE:
		METHOD GetByID( nID )
		METHOD currentRecord()
		METHOD previousRecord()
		METHOD nextRecord()
		METHOD GetList( )
		METHOD GetByAttribute( cAttribute, cValue )
		METHOD Reconstruct()
		METHOD Index( lNecessarily )

		METHOD New( )
		METHOD Delete( object, is_cycle, is_delete, is_lock )
		METHOD Save( hbArray )

		METHOD GUse( lRegim )
		METHOD RUse()
		METHOD EUse()
	PROTECTED:
	HIDDEN:
		VAR oDescr			AS OBJECT	INIT nil
		METHOD G_UseDB( lTryForever, lExcluUse, lREADONLY )
		METHOD G_IndexDB( cIndex )
		METHOD G_RLock( ... )
		METHOD AddRecN( is_forever )
		METHOD AddRec( k, is_forever, is_only_0 )
ENDCLASS
// конец описания класса

METHOD New()	CLASS TDataAccessDB

	return self

// 23.11.18 - процедура переиндексирования файла БД объекта
METHOD procedure Index( lNecessarily )	CLASS TDataAccessDB

	local item
	local key, cName

	HB_Default( @lNecessarily, .f. ) 
	if isnil( ::oDescr )
		::oDescr := TDescriptorDBF():New( Self:ClassName )
	endif

	if ! empty( ::oDescr:IndexFile() )
		dbUseArea( .t., ;          // new
				, ;            // rdd
				::oDescr:FileName, ;       // db
				::oDescr:AliasFile(), ;      // alias
				.f., ;  // if(<.sh.> .or. <.ex.>, !<.ex.>, nil)
				.t., ;   // readonly
				'RU866' ;
		)
		for each item in ::oDescr:IndexFile()
			cName := item[ 1 ] + '.ntx'
			key := item[ 2 ]
			if lNecessarily
				index on &key to &cName progress
			else
				if files_time( ::oDescr:FileName, cName ) .or. ;
						files_time( ::oDescr:FileName, cName )
					index on &key to &cName progress
				endif
			endif
		next
		( ::oDescr:AliasFile())->( dbCloseArea() )
	endif
	return
	
// возвращает id - записи (номер записи в файле БД), в случае ошибки возвращает -1
METHOD Save( hbArray )	 CLASS TDataAccessDB

	local cOldArea, cAlias
	local lExist := .f., xValue := nil, nId := 0, lNew := .f.
	local retCode := -1
	local fl := .t.
	
	lExist := hb_hHaskey( hbArray, 'ID' )
	if lExist
		nId := hbArray[ 'ID' ]
		lNew := hbArray[ 'REC_NEW' ]
		cOldArea := Select()
		if ::GUse( .t. )
			cAlias := Select()
			if lNew
				if upper( ::oDescr:AliasFile() ) == upper( 'TPatientExtDB' ) ;
						.or. upper( ::oDescr:AliasFile() ) == upper( 'TPatientAddDB' ) ;
						.or. upper( ::oDescr:AliasFile() ) == upper( 'THumanExtDB' ) ;
						.or. upper( ::oDescr:AliasFile() ) == upper( 'THumanAddDB' )
					if (cAlias)->(lastrec()) >= nId
						(cAlias)->(dbGoto(nID))
						if !::G_RLock( sforever )
							return retCode
						endif
					 else
						do while (cAlias)->(lastrec()) < nId
							(cAlias)->( dbAppend() )
						enddo
					endif
				elseif upper( ::oDescr:AliasFile() ) == upper( 'TPatientDB' ) ;
						.or. upper( ::oDescr:AliasFile() ) == upper( 'THumanDB' ) ;
						.or. upper( ::oDescr:AliasFile() ) == upper( 'TContractDB' ) ;
						.or. upper( ::oDescr:AliasFile() ) == upper( 'TContractPayerDB' ) ;
						.or. upper( ::oDescr:AliasFile() ) == upper( 'TContractServiceDB' )
					(cAlias)->(dbSetOrder( 1 ))
					if upper( ::oDescr:AliasFile() ) == upper( 'TContractDB' )	// для шапки платных услуг
//						if (cAlias)->(dbSeek( str( 0, 7 ) + dtos( ctod( '' ) ) + str( 0, 6 )))//, .t.))
						if (cAlias)->(dbSeek( str( 0, 7 ) ) )
							do while (cAlias)->kod_k == 0 .and. !(cAlias)->(eof())
								if ::G_RLock( sforever )
									fl := .f.
									exit
								endif
								(cAlias)->(dbSkip())
							enddo
						endif
					else
						if (cAlias)->(dbSeek( str( 0, 7 ), .t.))
							do while (cAlias)->KOD == 0 .and. !(cAlias)->(eof())
								if ::G_RLock( sforever )
									fl := .f.
									exit
								endif
								(cAlias)->(dbSkip())
							enddo
						endif
					endif
					if fl  // добавление записи
						&& if !::AddRecN()
						if ! ( if( .t., ::G_RLock( .t., sforever ), ::G_RLock( .t. ) ) )
							return retCode
						endif
					endif
				else
					if !::AddRecN()
						return retCode
					endif
				endif
				nID := (cAlias)->( recno() )
			else
				(cAlias)->(dbGoto(nID))
				if !::G_RLock( sforever )
					return retCode
				endif
			endif
			
			for each xValue in ::oDescr:StructFile()
				(cAlias)->&(xValue[ 1 ]) := hbArray[ xValue[ 1 ] ]
			next
			retCode := nID
			// для некоторых классов поле KOD есть номер записи в файле
			if ( hb_hHaskey( hbArray, 'KOD' ) ) ;
					.and. upper( ::oDescr:AliasFile() ) != upper( 'TIncompatibleServiceDB' ) ;
					.and. upper( ::oDescr:AliasFile() ) != upper( 'TPlannedMonthlyStaffDB' ) ;
					.and. upper( ::oDescr:AliasFile() ) != upper( 'TContractServiceDB' ) ;
					.and. upper( ::oDescr:AliasFile() ) != upper( 'Tk_prim1DB' ) ;
					.and. upper( ::oDescr:AliasFile() ) != upper( 'TContractPayerDB' ) ;
					.and. upper( ::oDescr:AliasFile() ) != upper( 'TDisabilityDB' ) ;
					.and. upper( ::oDescr:AliasFile() ) != upper( 'TForeignCitizenDB' ) ;
					.and. upper( ::oDescr:AliasFile() ) != upper( 'TDubleFIODB' ) ;
					.and. upper( ::oDescr:AliasFile() ) != upper( 'TMOKISMODB' ) ;
					.and. upper( ::oDescr:AliasFile() ) != upper( 'TMOHISMODB' ) ;
					.and. upper( ::oDescr:AliasFile() ) != upper( 'TNapravlenie263' )
				(cAlias)->KOD := nID
					&& .and. upper( ::oDescr:AliasFile() ) != upper( 'TPatientDB' ) ;
					&& .and. upper( ::oDescr:AliasFile() ) != upper( 'THumanDB' ) ;
			endif
			(cAlias)->( dbCommit() )
			(cAlias)->( dbCloseArea() )
			dbSelectArea( cOldArea )
		endif
	endif
	return retCode
	
// Очистить запись и пометить для удаления
// object - удаляемый объект
// is_cycle  - (.f.) .f. - делать COMMIT, .t. - не делать
// is_delete - (.t.) .t. - помечать на удаление, .f. - не помечать
// is_lock   - (.t.) .t. - блокировать запись, .f. - нет (уже заблокирована)
METHOD Delete( object, is_cycle, is_delete, is_lock )	CLASS TDataAccessDB

	local cOldArea, temp
	local ret := .f.
	local nNumberofFields, nCurField, mtype, fl := .t.

	HB_Default( @is_cycle, .f. ) 
	HB_Default( @is_delete, .t. ) 
	HB_Default( @is_lock, .t. ) 
	if object:ID == 0
		return ret
	endif
	cOldArea := Select( )
	if ::GUse( .t. )
		temp := Select( )
		(temp)->(dbGoto( object:ID ))
		if !(temp)->(Eof())
			nNumberofFields := FCOUNT()
			if ( ret := iif( is_lock, ::G_RLock( sforever ), .t. ) )
				for nCurField := 1 to nNumberofFields
					mtype := type( field( nCurField ) )
					do case
						case mtype == 'C'
							fieldput( nCurField, ' ' )
						case mtype == 'N'
							fieldput( nCurField, 0 )
						case mtype == 'L'
							fieldput( nCurField, .f. )
						case mtype == 'D'
							fieldput( nCurField, CTOD( '' ) )
						case mtype == 'M'
							if !empty( FIELDGET( nCurField  ) )
								fieldput( nCurField, ' ' )
							endif
					endcase
				next
			endif
			if is_delete
				(temp)->(dbDelete())
			endif
			if !is_cycle
				(temp)->(dbCommit())
			endif
			if is_lock
				(temp)->(dbUnlock())
			endif
		endif
		(temp)->(dbCloseArea())
	endif
	dbSelectArea( cOldArea )
	return ret
	
// открытие файла базы данных в сети
METHOD GUse( lRegim )	CLASS TDataAccessDB

	HB_Default( @lRegim, .t. ) 
	return ::G_UseDB( lRegim )

// открытие файла базы данных в сети ТОЛЬКО ДЛЯ ЧТЕНИЯ
METHOD RUse()	CLASS TDataAccessDB

	return ::G_UseDB()

// монопольное открытие файла базы данных
METHOD EUse()	CLASS TDataAccessDB

	return ::G_UseDB( , .t.)
	
  
// открытие файла базы данных в сети
// lTryForever - логическая величина (.t. - пытаться бесконечно)
// lExcluUse - логическая величина (.t. - монопольное открытие БД)
// lREADONLY - логическая величина (.t. - открытие БД только для чтения)
METHOD G_UseDB( lTryForever, lExcluUse, lREADONLY )	CLASS TDataAccessDB

	local cMessage, lRetValue, c1Array := { 'Попытаться снова' }, cArray
	local cFile, curUser

	::oDescr := TDescriptorDBF():New( Self:ClassName() )
	
	HB_Default( @lTryForever, .f. ) 
	HB_Default( @lExcluUse, .f. ) 
	HB_Default( @lREADONLY, .f. ) 

	cFile		:= ::oDescr:FileName()
	curUser := hb_user_curUser
	
	if !File( cFile )
		dbCreate( cFile, ::oDescr:StructFile() )
	endif
	
	// получим ID работающего пользователя
//	if hb_user_curUser != nil
//		::FIDUser := hb_user_curUser:ID()
//	endif
	if curUser != nil
		::FIDUser := curUser:ID()
	endif
	
	if '.DBF' == Upper( right( cFile, 4 ) )
		cFile := substr( cFile, 1, len( cFile ) - 4 )
	endif
	// чтобы все файлы в данном модуле открывались только для чтения,
	// определите PRIVATE-перемменную 'PRIVATE use_readonly := .t.'
//	if lREADONLY == nil .and. islogical( 'use_readonly' ) .and. use_readonly
//		lREADONLY := .t.
//	endif
	// Попытки открытия базы данных до успеха или отказа
	do while lRetValue == nil
		dbUseArea( .t.,;          // new
					, ;            // rdd
					cFile, ;       // db
					::oDescr:AliasFile(), ;      // alias
					!lExcluUse, ;  // if(<.sh.> .or. <.ex.>, !<.ex.>, nil)
					lREADONLY, ;   // readonly
					'RU866' ;
				)
		if !NETERR()
			if empty( ::oDescr:IndexFile() )  // нет индексов при вызове ф-ии
				lRetValue := .t.
				DbClearIndex()  // все равно закрыть - для FOXPRO
			elseif !( lRetValue := ::G_IndexDB( ::oDescr:IndexFile() ) )
				Use  // закрыть БД при отсутствии индекса(ов)
			endif
		else
			if !lTryForever
				cMessage := ::oDescr + ' - невозможно открыть'
				cMessage += ';Он занят другим пользователем'
				cArray := aclone( c1Array )
				aadd( cArray, 'Завершить' )
				if ALERT( cMessage, cArray, 'N/BG, W+/N' ) != 1
					lRetValue := .f.
				endif
			endif
		endif
	enddo
	return ( lRetValue )
  
// Открытие списка индексных файлов для работы в сети
METHOD G_IndexDB( cIndex )	CLASS TDataAccessDB
	local nIndexNum, cMessage, lRetValue
	
	HB_Default( @cIndex, {} ) 

	if valtype( cIndex ) == 'C'
		cIndex := { cIndex }
	endif
	if len( cIndex ) == 0
		// Если индекс не указан, то закрытие всех индексных файлов
		dbClearIndex()
		lRetValue := .t.
	else
		for nIndexNum := 1 to len( cIndex )
			// Проверка наличия индексного файла
			if !FILE( cIndex[ nIndexNum, 1 ] + if( '.' $ cIndex[ nIndexNum, 1 ], '', '.??x' ) )
				cMessage := 'ОШИБКА: Индексный файл ' + StripPath( cIndex[ nIndexNum, 1 ] ) + ;
							' не существует'
				ALERT( cMessage, { 'Завершить' }, 'N/BG, W+/N' )
				lRetValue := .f.
				EXIT
			endif
		next
		if lRetValue == nil
			// Сохранение указателя записи
			dbClearIndex()
			for nIndexNum := 1 to min( len( cIndex ), 15 )
				dbSetIndex( cIndex[ nIndexNum, 1 ] )
			next
			// Восстановление указателя записи
			lRetValue := .t.
		endif
	endif
	return ( lRetValue )  

// 
METHOD GetByAttribute( cAttribute, cValue ) CLASS TDataAccessDB
	local block
	local aReturn := {}
	local xValue
	local aRow
	local cAlias
	local cOldArea
                    
	cAttribute := Upper( Alltrim( cAttribute ) )
	cOldArea := Select( )
	if ::RUse()
		cAlias := Select( )
		if AScan( ::oDescr:StructFile( ), {| aFields | aFields[ 1 ] == cAttribute } ) > 0  // проверяем наличия атрибута в структуре файла
			if VALTYPE( cValue ) == 'N'
				block := &( '{||' + cAttribute + ' = ' + AllTrim( STR( cValue ) ) + '}' )      // составляем строку поиска по атрибуту
			ElseIf VALTYPE( cValue ) == 'D'
				block := &( '{||' + cAttribute + ' = "' + DTOS( cValue ) + '"}' )      // составляем строку поиска по атрибуту
			ElseIf VALTYPE( cValue ) == 'L'
				block := &( '{||' + cAttribute + ' = ' + IIF( cValue, '.t.', '.f.' ) + '}' )      // составляем строку поиска по атрибуту
			else
				block := &( '{||' + cAttribute + '="' + cValue + '"}' )      // составляем строку поиска по атрибуту
			endif
			( cAlias )->( __dbLocate( block, , , , .f. ) )
			do while ( cAlias )->( found( ) )
				aRow := hb_Hash()
				hb_HAutoAdd( aRow, HB_HAUTOADD_ALWAYS )
				for Each xValue IN  ::oDescr:StructFile() 
					hb_hSet(aRow, Upper( xValue[ 1 ] ),  ( cAlias )->(&( xValue[ 1 ] ) ) )
				next
				hb_hSet(aRow, 'ID', ( cAlias )->( recno() )  )
				hb_hSet(aRow, 'REC_NEW', .f. )
				hb_hSet(aRow, 'DELETED', ( cAlias )->( Deleted() )  )
				Aadd( aReturn, aRow )
        
				( cAlias )->( __dbContinue() )
			enddo
			( cAlias )->( dbCloseArea() )
			dbSelectArea( cOldArea )
		endif
	endif
  return aReturn
  
METHOD Reconstruct() CLASS TDataAccessDB
					 
	static sdbf := '.dbf'
	static err_2_task := 'Вероятность повторного запуска задачи!'
	local adbf, fl := .f., lOldDeleted, lrec
	local item, vrec
	
	::oDescr := TDescriptorDBF():New( Self:ClassName() )
	if !file( ::oDescr:FileName() )
		dbCreate( ::oDescr:FileName(), ::oDescr:StructFile() )
		fl := .t.
	elseif control_base( 2 )
		if !::G_UseDB( .t. )
			err_msg( 'Вероятность повторного запуска задачи!' )
		endif
		adbf := dbstruct()
		lrec := lastrec()
		( ::oDescr:AliasFile() )->( dbCloseArea() )
		if !compare_arrays( adbf, ::oDescr:StructFile() )
			dbcreate( 'tmp', ::oDescr:StructFile() )
			if !G_Use( 'tmp', , , .t., .t. )
				err_msg( err_2_task )
			endif
			vrec := ( recsize() * lrec + header() + 1 ) * 1.3
			if diskspace() < vrec
				func_error( 'На диске не хватает ' + lstr( vrec - diskspace(), 15, 0 ) + ;
							' байт для перестроения базы данных' )
				f_end()
			endif
			tmp->( dbCloseArea() )
			//
			lOldDeleted := SET( _SET_DELETED, .f. )
			use tmp new
			__dbApp( ::oDescr:FileName(), , , , , , , , , 'RU866' )
			close databases
			//
			do while FErase( ::oDescr:FileName() ) != 0
			enddo
//			if fl_NET
//				__CopyFile( 'tmp.dbf', ::oDescr:FileName() )
//				FErase( 'tmp.dbf' )
//			else
				FRename( 'tmp.dbf', ::oDescr:FileName() )
//			endif
			SET( _SET_DELETED, lOldDeleted )
			fl := .t.
		endif
	endif
	if !empty( ::oDescr:IndexFile() )
		for each item IN ::oDescr:IndexFile()
			INDEX ON ( item[ 2 ] ) to ( item[ 1 ] )
		next
	endif
	return nil

// добавление с повторным использованием удаленных записей (нет индекса)
METHOD AddRecN( is_forever ) CLASS TDataAccessDB
	local lOldDeleted := SET( _SET_DELETED, .f. ), fl := .f.
	
	HB_Default( @is_forever, .t. )		// если .t. - пытаться бесконечно блокировать запись

	dbGoTop()
	do while !eof()
		if DELETED() .and. iif( is_forever, ::G_RLock( sforever ), ::G_RLock() )
			dbRecall()
			fl := .t.
			exit
		endif
		dbSkip()
	enddo
	if !fl
		fl := if( is_forever, ::G_RLock( .t., sforever ), ::G_RLock( .t. ) )
	endif
	SET( _SET_DELETED, lOldDeleted )  // Восстановление среды
	return fl
	
// добавление с повторным использованием удаленных записей (есть индекс)
//	Parameters k, is_forever, is_only_0
	// k    - длина цифрового ключа
	//        или наименование поля для поиска кода (для locate)
	// is_forever - если .t. - пытаться бесконечно блокировать запись
	// is_only_0  - .t. искать просто нулевой код, .f. - нулевой код + deleted()
METHOD AddRec( k, is_forever, is_only_0 ) CLASS TDataAccessDB
	local lOldDeleted := SET( _SET_DELETED, .f. ), fl := .t., fl_f := .f.
	
	HB_Default( @is_forever, .f. )
	HB_Default( @is_only_0, .f. )
	
	if valtype( k ) == 'N'
		FIND ( STR( 0, k ) )
		if FOUND()  // если найдено значение 'нуль' - проверить на DELETED()
			fl_f := .t.
			if DELETED()
				if ( fl := iif( is_forever, ::G_RLock( sforever ), ::G_RLock() ) )
					dbRecall()
				endif
			elseif is_only_0
				fl := iif( is_forever, ::G_RLock( sforever ), ::G_RLock() )
			else
				fl_f := .f.
			endif
		endif
	else
		dbGoTop()
		do while !eof()
			if DELETED() .and. iif( is_forever, ::G_RLock( sforever ), ::G_RLock() )
				dbRecall()
				fl := fl_f := .t.
				exit
			endif
			dbSkip()
		enddo
	endif
	if !fl_f
		fl := if( is_forever, ::G_RLock( .t., sforever ), ::G_RLock( .t. ) )
	endif
	SET( _SET_DELETED, lOldDeleted )  // Восстановление среды
	return fl

// Блокирование записи (или добавление с блокированием)
// G_RLock() - одноразовая попытка блокировать запись
// G_RLock('forever') - бесконечная попытка блокировать запись
// G_RLock(.t.) - одноразовая попытка добавить запись
// G_RLock('forever',.t.) - бесконечная попытка добавить запись
// G_RLock(.t.,'forever') - бесконечная попытка добавить запись
// 09.01.17
METHOD G_RLock( ... ) CLASS TDataAccessDB

	local lAppend := .f., cMessage, cTitle, i, lRetValue, nSec, lTryForever := .f., cArray := hb_AParams()
	
	// Обработка переданных параметров
	for i := 1 to len( cArray )
		&& if VALTYPE( cArray[ i ] ) == 'L'
		if islogical( cArray[ i ] )
			lAppend := cArray[ i ]
		else
			lTryForever := ( UPPER( cArray[ i ] ) == sforever )
		endif
	next // i
	do while lRetValue == nil
		nSec := SECONDS() + 3
		// Зацикливание на не более 3 секунд
		do while ( SECONDS() < nSec ) .and. ( isnil( lRetValue ) )
			if lAppend
				// Выполнение APPEND BLANK если указано
				APPEND BLANK
				if !NETERR()
					lRetValue := .t.
				endif
			else
				// Блокировка текущей записи
				if RLOCK()
					lRetValue := .t.
				endif
			endif
		enddo
		if lRetValue == nil
			// 3 секунды истекли
			cTitle := 'Ошибка блокировки'
			cMessage := 'Невозможно блокировать запись в БД ' + ALIAS()			// + ';' + hb_oel()
			cMessage += ';Вероятнее всего, она занята другим пользователем.'
			if lTryForever
				cArray := { '<Enter> - попытаться снова' }
			else
				cArray := { 'Попытаться снова', 'Завершить' }
			endif
			if ( ALERT( cMessage, cArray, 'N/BG, W+/N' ) != 1 ) .AND. !lTryForever
				lRetValue := .f.
			endif
		endif
	enddo
	return ( lRetValue )
	
// получить хэш-массив для текущей записи (можно использовать в циклах)	
METHOD currentRecord() CLASS TDataAccessDB

	local aRow := nil
	local xValue
	local cAlias

	cAlias := Select()
	if !( (cAlias)->(eof()) )
		aRow := hb_Hash()
		hb_HAutoAdd( aRow, HB_HAUTOADD_ALWAYS )
		for each xValue in ::oDescr:StructFile() 
			hb_hSet( aRow, upper( xValue[ 1 ] ),  ( cAlias )->(&( xValue[ 1 ]) ) )
		next
		hb_hSet(aRow, 'ID', (cAlias)->(recno()) )
		hb_hSet(aRow, 'REC_NEW', .f. )
		hb_hSet(aRow, 'DELETED', (cAlias)->(Deleted()) )
	endif
	return aRow

// перейти на следующую запись и получить хэш-массив для следующей записи (можно использовать в циклах)	
METHOD nextRecord() CLASS TDataAccessDB

	local aRow := nil
	local xValue
	local cAlias

	cAlias := Select()
	if !( (cAlias)->( eof()) )
		(cAlias)->( dbSkip() )
		if !( (cAlias)->( eof()) )
			aRow := hb_Hash()
			hb_HAutoAdd( aRow, HB_HAUTOADD_ALWAYS )
			for each xValue in ::oDescr:StructFile() 
				hb_hSet( aRow, upper( xValue[ 1 ] ),  ( cAlias )->(&( xValue[ 1 ]) ) )
			next
			hb_hSet(aRow, 'ID', (cAlias)->(recno()) )
			hb_hSet(aRow, 'REC_NEW', .f. )
			hb_hSet(aRow, 'DELETED', (cAlias)->(Deleted()) )
		endif
	endif
	return aRow

// перейти на предыдущую запись и получить хэш-массив для следующей записи (можно использовать в циклах)	
METHOD previousRecord() CLASS TDataAccessDB

	local aRow := nil
	local xValue
	local cAlias

	cAlias := Select()
	if !( (cAlias)->( eof()) )
		(cAlias)->( dbSkip() )
		if !( (cAlias)->( eof()) )
			aRow := hb_Hash()
			hb_HAutoAdd( aRow, HB_HAUTOADD_ALWAYS )
			for each xValue in ::oDescr:StructFile() 
				hb_hSet( aRow, upper( xValue[ 1 ] ),  ( cAlias )->(&( xValue[ 1 ]) ) )
			next
			hb_hSet(aRow, 'ID', (cAlias)->(recno()) )
			hb_hSet(aRow, 'REC_NEW', .f. )
			hb_hSet(aRow, 'DELETED', (cAlias)->(Deleted()) )
		endif
	endif
	return aRow
	
//
METHOD GetByID( nID ) CLASS TDataAccessDB

	local aRow := nil
	local xValue
	local cAlias
	local cOldArea
           
	// предварительно проверить что пришло число и что не ноль
	if valType( nID ) != 'N' .or. ( nID == 0 )
		return aRow
	endif
	cOldArea := Select( )
	if ::RUse()
		cAlias := Select( )
		(cAlias)->(dbGoto(nID))
		if !( (cAlias)->(eof()) )
			aRow := hb_Hash()
			hb_HAutoAdd( aRow, HB_HAUTOADD_ALWAYS )
			for each xValue in ::oDescr:StructFile() 
				hb_hSet(aRow, upper( xValue[ 1 ] ),  ( cAlias )->(&( xValue[ 1 ]) ) )
			next
			hb_hSet(aRow, 'ID', (cAlias)->(recno()) )
			hb_hSet(aRow, 'REC_NEW', .f. )
			hb_hSet(aRow, 'DELETED', (cAlias)->(Deleted()) )
		endif
		(cAlias)->(dbCloseArea())
		dbSelectArea( cOldArea )
	endif
	return aRow
	
//
METHOD GetList( ) CLASS TDataAccessDB

	local xValue, aRow, aReturn := {}
	local cAlias
	local cOldArea
                    
	cOldArea := Select( )
	if ::RUse()
		cAlias := Select( )
		(cAlias)->(dbGoTop())
		do while !(cAlias)->(eof())
			aRow := hb_Hash()
			hb_HAutoAdd( aRow, HB_HAUTOADD_ALWAYS )
			for each xValue in  ::oDescr:StructFile() 
				hb_hSet(aRow, upper( xValue[ 1 ] ),  (cAlias)->(&( xValue[ 1 ] ) ) )
			next
			hb_hSet(aRow, 'ID', (cAlias)->( recno() )  )
			hb_hSet(aRow, 'REC_NEW', .f. )
			hb_hSet(aRow, 'DELETED', (cAlias)->(Deleted()) )
			Aadd( aReturn, aRow )
			(cAlias)->(DBSkip())
		enddo
		(cAlias)->(dbCloseArea())
		dbSelectArea( cOldArea )
	endif
	return aReturn