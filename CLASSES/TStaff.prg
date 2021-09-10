#include 'hbclass.ch'
#include 'hbhash.ch'

CLASS TStaff
  CLASSDATA cAlias As character INIT '__employees'
  CLASSDATA cFile As character INIT dir_server + 'mo_pers'
  CLASSDATA cIndex As character INIT dir_server + 'mo_pers'

  DATA hData

	VISIBLE:
  METHOD New() INLINE Self
  METHOD getByCode( nCode )
	METHOD GetByTabNom( nTabNom )
	ERROR HANDLER OnError( xParam )
  
ENDCLASS

// ------------------------------------------------------------------------------
// METHOD new() CLASS TStaff

//   return( Self )

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
			::hData := hb_Hash()
			hb_HAutoAdd( ::hData, HB_HAUTOADD_ALWAYS )
      FOR i := 1 TO ( ::cAlias ) ->( FCount() )
         hb_hSet(::hData, (::cAlias)->(FieldName(i)), (::cAlias)->(FieldGet(i)))
      NEXT
		else
			return nil
		endif
		(::cAlias)->(dbCloseArea())
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
			::hData := hb_Hash()
			hb_HAutoAdd( ::hData, HB_HAUTOADD_ALWAYS )
      FOR i := 1 TO ( ::cAlias ) ->( FCount() )
         hb_hSet(::hData, (::cAlias)->(FieldName(i)), (::cAlias)->(FieldGet(i)))
      NEXT
		else
			return nil
		endif
		(::cAlias)->(dbCloseArea())
		dbSelectArea( cOldArea )
	else
		return nil
	endif
	return Self

METHOD OnError( xParam ) CLASS TStaff
	local cMsg := __GetMessage(), cFieldName, nPos
	local xValue

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