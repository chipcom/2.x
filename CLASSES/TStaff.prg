#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'property.ch'
#include 'dbstruct.ch'

CLASS TStaff
  CLASSDATA cAlias As character INIT '__employees'
  CLASSDATA cFile As character INIT dir_server + 'mo_pers'
  CLASSDATA cIndex As character INIT dir_server + 'mo_pers'
	CLASSDATA aFields INIT nil

	CLASSDATA	aShortCat		AS ARRAY INIT { '   ', 'вр.', 'ср.', 'мл.', 'пр.' }
	CLASSDATA	aShortCatDoctor	AS ARRAY INIT { ' без', '2-ая', '1-ая', 'высш' }
	CLASSDATA	aMenuCategory	AS ARRAY	INIT { { 'врач', 1 }, ;
													{ 'средний мед.персонал', 2 }, ;
													{ 'младший мед.персонал', 3 }, ;
													{ 'прочие', 4 } }

	CLASSDATA	aMenuDoctorCat	AS ARRAY	INIT { {'без категории   ', 0 }, ;
														{ '2-ая категория  ', 1 }, ;
														{ '1-ая категория  ', 2 }, ;
														{ 'высшая категория', 3 } }
											
	CLASSDATA	aMenuTypeJob	AS ARRAY	INIT { { 'основная работа', 0 }, ;
														{ 'совмещение     ', 1 } }

  DATA hData INIT nil

	VISIBLE:
  METHOD New()
  METHOD getByCode( nCode )
	METHOD GetByTabNom( nTabNom )
	ERROR HANDLER OnError( xParam )

	// Категории сотрудников
	METHOD IsDoctor			INLINE ( iif(hb_isnil(::hData), nil, ::hData['KATEG']==1) )	// сотрудник доктор
	METHOD IsNurse		INLINE ( iif(hb_isnil(::hData), nil, ::hData['KATEG']==2) )	// сотрудник медсестра
	METHOD IsAidman	INLINE ( iif(hb_isnil(::hData), nil, ::hData['KATEG']==3) )	// сотрудник санитар
	METHOD IsOther		INLINE ( iif(hb_isnil(::hData), nil, ::hData['KATEG']==4) )	// сотрудник прочие
	METHOD CategoryFormat		INLINE ( iif(hb_isnil(::hData), nil, ::aShortCat[ ::hData['KATEG'] + 1 ]) )
	
	HIDDEN:
	METHOD fillAFields()

ENDCLASS

// ------------------------------------------------------------------------------
METHOD new() CLASS TStaff
	local cOldArea

	if empty(::aFields)
		cOldArea := Select( )
		if R_Use( ::cFile, ::cIndex, ::cAlias, .t., .f. )
			::fillAFields()
			(::cAlias)->(dbCloseArea())
		endif
		dbSelectArea( cOldArea )
	endif
	::hData := hb_Hash()
	hb_HAutoAdd( ::hData, HB_HAUTOADD_ALWAYS )
	for i := 1 to len(::aFields)
		if ::aFields[i, DBS_TYPE] == 'C'
			hb_hSet(::hData, ::aFields[i, DBS_NAME], space(::aFields[i, DBS_LEN]))
		elseif ::aFields[i, DBS_TYPE] == 'N'
			hb_hSet(::hData, ::aFields[i, DBS_NAME], 0)
		elseif ::aFields[i, DBS_TYPE] == 'D'
			hb_hSet(::hData, ::aFields[i, DBS_NAME], stod('  /  /    '))
		elseif ::aFields[i, DBS_TYPE] == 'L'
			hb_hSet(::hData, ::aFields[i, DBS_NAME], .f.)
		elseif ::aFields[i, DBS_TYPE] == 'M'
			hb_hSet(::hData, ::aFields[i, DBS_NAME], '')
		endif
	next

  return( Self )

*****************************
METHOD GetByCode( nCode ) CLASS TStaff
	local cOldArea
  local i
           
	// предварительно проверить что пришло число и что не ноль
	if valType( nCode ) != 'N' .or. ( nCode == 0 )
		return nil
	endif
	cOldArea := Select( )

	if R_Use( ::cFile, ::cIndex, ::cAlias, .t., .f. )
		(::cAlias)->(dbGoto(nCode))
		if !( (::cAlias)->(eof()) )
			::fillAFields()
			::hData := hb_Hash()
			hb_HAutoAdd( ::hData, HB_HAUTOADD_ALWAYS )
      FOR i := 1 TO ( ::cAlias ) ->( FCount() )
         hb_hSet(::hData, (::cAlias)->(FieldName(i)), (::cAlias)->(FieldGet(i)))
      NEXT
			(::cAlias)->(dbCloseArea())
		else
			return nil
		endif
		dbSelectArea( cOldArea )
	else
		return nil
	endif
	return Self

*****************************
METHOD GetByTabNom( nTabNom ) CLASS TStaff
	local cOldArea
  local i
           
	// предварительно проверить что пришло число и что не ноль
	if valType( nTabNom ) != 'N' .or. ( nTabNom == 0 )
		return nil
	endif
	cOldArea := Select( )

	if R_Use( ::cFile, ::cIndex, ::cAlias, .t., .f. )
		if (::cAlias)->(dbSeek(str(nTabNom,5)))
			::fillAFields()
			::hData := hb_Hash()
			hb_HAutoAdd( ::hData, HB_HAUTOADD_ALWAYS )
      FOR i := 1 TO ( ::cAlias ) ->( FCount() )
         hb_hSet(::hData, (::cAlias)->(FieldName(i)), (::cAlias)->(FieldGet(i)))
      NEXT
			(::cAlias)->(dbCloseArea())
		else
			return nil
		endif
		dbSelectArea( cOldArea )
	else
		return nil
	endif
	return Self

METHOD OnError( xParam ) CLASS TStaff
	local cMsg := __GetMessage(), cFieldName
	local xValue

	// пустой объект
	if ::hData == nil
		return nil
	endif

	if Left(cMsg, 1) == '_'
		cFieldName := Substr(cMsg,2)
	else
		cFieldName := cMsg
	endif
	if !hb_hHasKey(::hData, cFieldName)
		Alertx(cFieldName + ' wrong field name!')
	elseif cFieldName == cMsg
		return ::hData[cFieldName]
	else
		::hData[cFieldName] := xParam
	endif
	return nil

METHOD fillAFields() CLASS TStaff
	if ::aFields == nil
		::aFields := (::cAlias)->(dbStruct())
	endif
	return nil
