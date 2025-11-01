#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 20.10.25
Function loadcriteria21( val_year )

  Local fl, ar, ar1, ar2, i
  Local retCriteria := {}, lSchema := .f.
  Local tmp_select := Select()
  Local sbaseIt1 := prefixfilerefname( val_year ) + 'it1'
  Local aV024, it, sIt1code

  // исходный файл T006 21 года и выше
  If hb_FileExists( dir_exe() + sbaseIt1 + sdbf() )
    aV024 := getv024( val_year )
    tmp_select := Select()
    r_use( dir_exe() + sbaseIt1, , 'IT1' )
    ( 'IT1' )->( dbGoTop() )
    Do While !( 'IT1' )->( Eof() )
      lSchema := .f.
      ar := {}
      ar1 := {}
      ar2 := {}
      If !Empty( it1->ds )
        ar := slist2arr( it1->ds )
        For i := 1 To Len( ar )
          ar[ i ] := PadR( ar[ i ], 5 )
        Next
      Endif
      If !Empty( it1->ds1 )
        ar1 := slist2arr( it1->ds1 )
        For i := 1 To Len( ar1 )
          ar1[ i ] := PadR( ar1[ i ], 5 )
        Next
      Endif
      If !Empty( it1->ds2 )
        ar2 := slist2arr( it1->ds2 )
        For i := 1 To Len( ar2 )
          ar2[ i ] := PadR( ar2[ i ], 5 )
        Next
      Endif
      sIt1code := AllTrim( it1->CODE )
      If ( it := AScan( aV024, {| x| AllTrim( x[ 1 ] ) == sIt1code } ) ) > 0
        lSchema := .t.
      Endif
      If lSchema
        AAdd( retCriteria, { it1->USL_OK, PadR( it1->CODE, 7 ), ar, ar1, ar2, AllTrim( aV024[ it, 2 ] ) } )
      Else
        AAdd( retCriteria, { it1->USL_OK, PadR( it1->CODE, 7 ), ar, ar1, ar2, '' } )
      Endif
      ( 'IT1' )->( dbSkip() )
    Enddo
    ( 'IT1' )->( dbCloseArea() )
    ASort( retCriteria, , , {| x, y| x[ 2 ] < y[ 2 ] } )
  Else
    fl := notexistsfilensi( dir_exe() + sbaseIt1 + sdbf() )
  Endif
  Select( tmp_select )

  Return retCriteria

// 30.10.22
// возвращает массив параметров дополнительного критерия
Function getarraycriteria( dateSl, codeCriteria )

  Local tmpArrCriteria, row := {}
  Local arr

  tmpArrCriteria := getadditionalcriteria( dateSl )
  For Each row in tmpArrCriteria
    If AllTrim( row[ 2 ] ) == AllTrim( codeCriteria )
      arr := row
      Exit
    Endif
  Next

  Return arr

// 07.02.22
// возвращает массив дополнительных критериев на указанную дату
Function getadditionalcriteria( dateSl )

  Local dbAlias := '_ADCRIT'
  Local tmp_select := Select()
  Local retCriteria := {}
  Local aCriteria
  Local yearSl := Year( dateSl )

  Static hCriteria, lHashCriteria := .f.

  // при отсутствии ХЭШ-массива создадим его
  If !lHashCriteria
    hCriteria := hb_Hash()
    lHashCriteria := .t.
  Endif

  // получим массив критериев из хэша по ключу ГОД ОКОНЧАНИЯ СЛУЧАЯ, или загрузим его из справочника
  If hb_HHasKey( hCriteria, yearSl )
    retCriteria := hb_HGet( hCriteria, yearSl )
  Else
    If yearSl >= 2021
      // поместим в ХЭШ-массив
      aCriteria := loadcriteria21( yearSl )
      hCriteria[ yearSl ] := aCriteria
      retCriteria := aCriteria
    Elseif yearSl == 2020
      // поместим в ХЭШ-массив
      aCriteria := loadcriteria20( yearSl )
      hCriteria[ yearSl ] := aCriteria
      retCriteria := aCriteria
    Elseif yearSl == 2019
      // поместим в ХЭШ-массив
      aCriteria := loadcriteria19( yearSl )
      hCriteria[ yearSl ] := aCriteria
      retCriteria := aCriteria
    Elseif yearSl == 2018
      // поместим в ХЭШ-массив
      aCriteria := loadcriteria18( yearSl )
      hCriteria[ yearSl ] := aCriteria
      retCriteria := aCriteria
    Endif
  Endif

  If Empty( retCriteria )
    alertx( 'На дату ' + DToC( dateSl ) + ' дополнительные критерии отсутствуют!' )
  Endif

  Return retCriteria

// 14.10.24
Function loadcriteria20( val_year )

  Local fl, ar, ar1, ar2, i
  Local retCriteria := {}
  Local tmp_select := Select()
  Local sbaseIt1 := prefixfilerefname( val_year ) + 'it1'

  // исходный файл T006 20 года
  If hb_FileExists( dir_exe() + sbaseIt1 + sdbf() )
    tmp_select := Select()
    r_use( dir_exe() + sbaseIt1, , 'IT1' )
    ( 'IT1' )->( dbGoTop() )
    Do While !( 'IT1' )->( Eof() )
      ar := {}
      ar1 := {}
      ar2 := {}
      If !Empty( it1->ds )
        ar := slist2arr( it1->ds )
        For i := 1 To Len( ar )
          ar[ i ] := PadR( ar[ i ], 5 )
        Next
      Endif
      If !Empty( it1->ds1 )
        ar1 := slist2arr( it1->ds1 )
        For i := 1 To Len( ar1 )
          ar1[ i ] := PadR( ar1[ i ], 5 )
        Next
      Endif
      If !Empty( it1->ds2 )
        ar2 := slist2arr( it1->ds2 )
        For i := 1 To Len( ar2 )
          ar2[ i ] := PadR( ar2[ i ], 5 )
        Next
      Endif
      AAdd( retCriteria, { it1->USL_OK, PadR( it1->CODE, 3 ), ar, ar1, ar2 } )
      ( 'IT1' )->( dbSkip() )
    Enddo
    ( 'IT1' )->( dbCloseArea() )
  Else
    fl := notexistsfilensi( dir_exe() + sbaseIt1 + sdbf() )
  Endif
  Select( tmp_select )

  Return retCriteria

// 14.10.24
Function loadcriteria19( val_year )

  Local retCriteria := {}
  Local tmp_select := Select()
  Local sbaseIt := prefixfilerefname( val_year ) + 'it'
  local fl

  // исходный файл T006 19 года
  If hb_FileExists( dir_exe() + sbaseIt + sdbf() )
    tmp_select := Select()
    r_use( dir_exe() + sbaseIt, , 'IT' )
    Index On FIELD->ds To tmpit memory
    dbEval( {|| AAdd( retCriteria, { it->ds, it->it } ) } )
    ( 'IT' )->( dbCloseArea() )
  Else
    fl := notexistsfilensi( dir_exe() + sbaseIt + sdbf() )
  Endif
  Select( tmp_select )

  Return retCriteria

// 14.10.24
Function loadcriteria18( val_year )

  Local retCriteria := {}
  Local tmp_select := Select()
  Local sbaseIt := prefixfilerefname( val_year ) + 'it'
  local fl

  // исходный файл T006 18 года
  If hb_FileExists( dir_exe() + sbaseIt + sdbf() )
    tmp_select := Select()
    r_use( dir_exe() + sbaseIt, , 'IT' )
    Index On FIELD->ds To tmpit memory
    dbEval( {|| AAdd( retCriteria, { it->ds, it->it } ) } )
    ( 'IT' )->( dbCloseArea() )
  Else
    fl := notexistsfilensi( dir_exe() + sbaseIt + sdbf() )
  Endif
  Select( tmp_select )
  Return retCriteria
