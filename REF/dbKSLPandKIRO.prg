#include 'function.ch'
#include 'chip_mo.ch'

// 01.11.22
Function getinfokslp( dateSl, code )

  Local row := {}
  Local tmpArray := getkslptable( dateSl )

  For Each row in tmpArray
    If row[ 1 ] == code
      Return row
    Endif
  Next

  Return row

// 01.11.22
Function getinfokiro( dateSl, code )

  Local row := {}
  Local tmpArray := getkirotable( dateSl )

  For Each row in tmpArray
    If row[ 1 ] == code
      Return row
    Endif
  Next

  Return row

// 27.02.26 возвращает массив КСЛП на указанную дату
Function getkslptable( dateSl )

  Local dbName, dbAlias := 'KSLP_'
  Local tmp_select := Select()
  Local retKSLP := {}
  Local aKSLP, row
  Local yearSl := Year( dateSl )

  Static hKSLP, lHashKSLP := .f.

  // при отсутствии ХЭШ-массива создадим его
  If !lHashKSLP
    hKSLP := hb_Hash()
    lHashKSLP := .t.
  Endif

  // получим массив КСЛЭ из хэша по ключу ГОД ОКОЭЧАЭИЯ СЛУЧАЯ, или загрузим его из справочника
  If hb_HHasKey( hKSLP, yearSl )
    aKSLP := hb_HGet( hKSLP, yearSl )
  Else
    aKSLP := {}
    tmp_select := Select()
    dbName := prefixfilerefname( dateSl ) + 'kslp'

    dbUseArea( .t., 'DBFNTX', dir_exe() + dbName, dbAlias, .t., .f. )
    ( dbAlias )->( dbGoTop() )
    Do While !( dbAlias )->( Eof() )
      if dateSl >= 0d20260101
        AAdd( aKSLP, { ( dbAlias )->CODE, AllTrim( ( dbAlias )->NAME ), AllTrim( ( dbAlias )->NAME_F ), ( dbAlias )->COEFF, ( dbAlias )->DATEBEG, ( dbAlias )->DATEEND, ( dbAlias )->ID_SL, ( dbAlias )->PG_SL } )
      else
        AAdd( aKSLP, { ( dbAlias )->CODE, AllTrim( ( dbAlias )->NAME ), AllTrim( ( dbAlias )->NAME_F ), ( dbAlias )->COEFF, ( dbAlias )->DATEBEG, ( dbAlias )->DATEEND } )
      endif
      ( dbAlias )->( dbSkip() )
    Enddo
    ( dbAlias )->( dbCloseArea() )
    ASort( aKSLP,,, {| x, y| x[ 1 ] < y[ 1 ] } )

    Select( tmp_select )
    // поместим в ХЭШ-массив
    hKSLP[ yearSl ] := aKSLP
  Endif

  // выберем возможные КСЛП по дате
  For Each row in aKSLP
    If ( row[ 5 ] <= dateSl ) .and. ( ( dateSl <= row[ 6 ] ) .or. Empty( row[ 6 ] ) ) //, row[ 5 ], row[ 6 ] )
      if dateSl >= 0d20260101
        AAdd( retKSLP, { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ], row[ 6 ], row[ 7 ], row[ 8 ] } )
      else
        AAdd( retKSLP, { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ], row[ 6 ] } )
      endif
    Endif
  Next

  If Empty( retKSLP )
    alertx( 'На дату ' + DToC( dateSl ) + ' КСЛП отсутствуют!' )
  Endif

  Return retKSLP

// 27.02.26 возвращает массив КИРО на указанную дату
Function getkirotable( dateSl )

  Local dbName, dbAlias := 'KIRO_'
  Local tmp_select := Select()
  Local retKIRO := {}
  Local aKIRO, row
  Local yearSl := Year( dateSl )

  Static hKIRO, lHashKIRO := .f.

  // при отсутствии ХЭШ-массива создадим его
  If !lHashKIRO
    hKIRO := hb_Hash()
    lHashKIRO := .t.
  Endif

  // получим массив КИРО из хэша по ключу ГОД ОКОЗАНИЯ СЛУЧАЯ, или загрузим его из справочника
  If hb_HHasKey( hKIRO, yearSl )
    aKIRO := hb_HGet( hKIRO, yearSl )
  Else
    aKIRO := {}
    tmp_select := Select()
    dbName := prefixfilerefname( dateSl ) + 'kiro'

    dbUseArea( .t., 'DBFNTX', dir_exe() + dbName, dbAlias, .t., .f. )
    ( dbAlias )->( dbGoTop() )
    Do While !( dbAlias )->( Eof() )
      if dateSl >= 0d20260101
        AAdd( aKIRO, { ( dbAlias )->CODE, AllTrim( ( dbAlias )->NAME ), AllTrim( ( dbAlias )->NAME_F ), 0, ( dbAlias )->DATEBEG, ( dbAlias )->DATEEND } )
      else
        AAdd( aKIRO, { ( dbAlias )->CODE, AllTrim( ( dbAlias )->NAME ), AllTrim( ( dbAlias )->NAME_F ), ( dbAlias )->COEFF, ( dbAlias )->DATEBEG, ( dbAlias )->DATEEND } )
      endif
      ( dbAlias )->( dbSkip() )
    Enddo
    ( dbAlias )->( dbCloseArea() )
    ASort( aKIRO,,, {| x, y| x[ 1 ] < y[ 1 ] } )

    Select( tmp_select )
    // поместим в ХЭШ-массив
    hKIRO[ yearSl ] := aKIRO
  Endif

  // выберем возможные КИРО по дате
  For Each row in aKIRO
    If ( row[ 5 ] <= dateSl ) .and. ( ( dateSl <= row[ 6 ] ) .or. Empty( row[ 6 ] ) )
      AAdd( retKIRO, { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ], row[ 6 ] } )
    Endif
  Next

  If Empty( retKIRO )
    alertx( 'На дату ' + DToC( dateSl ) + ' КИРО отсутствуют!' )
  Endif

  Return retKIRO
