FUNCTION xpp_dbUseArea( lNewArea, cDriver, cName, xcAlias, lShared, lReadonly )

  LOCAL nOldArea
  LOCAL nArea

  IF hb_defaultValue( lNewArea, .F. )

     hb_default( @xcAlias, "" )

     IF Empty( xcAlias )
        xcAlias := cName
     ENDIF

     IF HB_ISSTRING( xcAlias )
        nOldArea := Select()
        IF ( nArea := Select( xcAlias ) ) > 0
           xcAlias += "_" + hb_ntos( nArea )
        ENDIF
        dbSelectArea( nOldArea )
     ENDIF
  ENDIF

  RETURN dbUseArea( lNewArea, cDriver, cName, xcAlias, lShared, lReadonly )
