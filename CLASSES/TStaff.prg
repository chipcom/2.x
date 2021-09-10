#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'property.ch'
#include 'dbstruct.ch'

CLASS TStaff
  CLASSDATA cAlias As character INIT '__employees'
  CLASSDATA cFile As character INIT dir_server + 'mo_pers'
  CLASSDATA cIndex As character INIT dir_server + 'mo_pers'
	CLASSDATA aFields INIT nil

	CLASSDATA	aShortCat		AS ARRAY INIT { '   ', '��.', '��.', '��.', '��.' }
	CLASSDATA	aShortCatDoctor	AS ARRAY INIT { ' ���', '2-��', '1-��', '����' }
	CLASSDATA	aMenuCategory	AS ARRAY	INIT { { '���', 1 }, ;
													{ '�।��� ���.���ᮭ��', 2 }, ;
													{ '����訩 ���.���ᮭ��', 3 }, ;
													{ '��稥', 4 } }

	CLASSDATA	aMenuDoctorCat	AS ARRAY	INIT { {'��� ��⥣�ਨ   ', 0 }, ;
														{ '2-�� ��⥣���  ', 1 }, ;
														{ '1-�� ��⥣���  ', 2 }, ;
														{ '����� ��⥣���', 3 } }
											
	CLASSDATA	aMenuTypeJob	AS ARRAY	INIT { { '�᭮���� ࠡ��', 0 }, ;
														{ 'ᮢ��饭��     ', 1 } }

  DATA hData INIT nil

	VISIBLE:
  METHOD New()
  METHOD getByCode( nCode )
	METHOD GetByTabNom( nTabNom )
	ERROR HANDLER OnError( xParam )

	// ��⥣�ਨ ���㤭����
	METHOD IsDoctor			INLINE ( iif(hb_isnil(::hData), nil, ::hData['KATEG']==1) )	// ���㤭�� �����
	METHOD IsNurse		INLINE ( iif(hb_isnil(::hData), nil, ::hData['KATEG']==2) )	// ���㤭�� �������
	METHOD IsAidman	INLINE ( iif(hb_isnil(::hData), nil, ::hData['KATEG']==3) )	// ���㤭�� ᠭ���
	METHOD IsOther		INLINE ( iif(hb_isnil(::hData), nil, ::hData['KATEG']==4) )	// ���㤭�� ��稥
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
           
	// �।���⥫쭮 �஢���� �� ��諮 �᫮ � �� �� ����
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
           
	// �।���⥫쭮 �஢���� �� ��諮 �᫮ � �� �� ����
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

	// ���⮩ ��ꥪ�
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
