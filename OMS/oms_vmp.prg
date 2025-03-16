#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 25.01.23 в GET-е вернуть строку из справочника V018
Function f_get_vidvmp( k, r, c, diagnoze )

  // Static sy := 0,
  Local arr, svidvmp := ''
  Local ret, ret_arr
  Local sTmp := ''
  Local y := Year( mk_data )
  Local row, arr_vid := {}, kk

  Local arrV019 := getv019( mk_data )
  Local arrV018 := getv018( mk_data )

  diagnoze := AllTrim( diagnoze )
  If y < 2018
    y := 2018
  Endif

  For Each row in arrV019   // только с нужным диагнозом
    If ( kk := AScan( row[ 3 ], {| x| x == AllTrim( diagnoze ) } ) ) > 0
      AAdd( arr_vid, row[ 4 ] )
    Endif
  Next

  arr := {}
  For i := 1 To Len( arrV018 )
    If ( kk := AScan( arr_vid, {| x| x == AllTrim( arrV018[ i, 1 ] ) } ) ) > 0
      sTmp := PadL( arrV018[ i, 1 ], 5 ) + '.'
      AAdd( arr, { PadR( sTmp + arrV018[ i, 2 ], 76 ), arrV018[ i, 1 ] } )
    Endif
  Next
  If Empty( k )
    k := svidvmp
  Endif
  popup_2array( arr, -r, c, k, 1, @ret_arr, 'Выбор вида ВМП', 'GR+/RB', 'BG+/RB,N/BG' )
  If ValType( ret_arr ) == 'A'
    ret := Array( 2 )
    svidvmp := ret_arr[ 2 ]
    ret[ 1 ] := ret_arr[ 2 ]
    ret[ 2 ] := ret_arr[ 1 ]
  Endif

  Return ret

// 25.01.23 в GET-е вернуть строку из справочника V019
Function f_get_metvmp( k, r, c, lvidvmp, modpac )

  Local arr := {}, i, ret, ret_arr

  Local arrV019 := getv019( mk_data )

  If Empty( lvidvmp ) .or. Empty( modpac )
    Return Nil
  Endif

  For i := 1 To Len( arrV019 )
    If arrV019[ i, 4 ] == AllTrim( lvidvmp ) .and. arrV019[ i, 8 ] == modpac
      AAdd( arr, { PadR( Str( arrV019[ i, 1 ], 4 ) + '.' + arrV019[ i, 2 ], 76 ), arrV019[ i, 1 ] } )
    Endif
  Next
  If Empty( arr )
    func_error( 4, 'В справочнике V019 не найдено методов для вида ВМП ' + lvidvmp )
    Return Nil
  Endif
  popup_2array( arr, -r, c, k, 1, @ret_arr, 'Выбор метода ВМП для ' + lvidvmp, 'GR+/RB*', 'N/RB*,W+/N' )
  If ValType( ret_arr ) == 'A'
    ret := Array( 2 )
    ret[ 1 ] := ret_arr[ 2 ]
    ret[ 2 ] := ret_arr[ 1 ]
  Endif

  Return ret

// 25.01.23 в GET-е вернуть строку из getV022()
Function f_get_mmodpac( k, r, c, lvidvmp, sDiag )

  Local arr := {}, i, ret, ret_arr
  Local diag := AllTrim( sDiag )
  Local model := getv022()
  Local row

  Local arrV019 := getv019( mk_data )

  If Empty( lvidvmp ) .or. Empty( diag )
    Return Nil
  Endif

  For i := 1 To Len( arrV019 )
    If arrV019[ i, 4 ] == AllTrim( lvidvmp ) .and. ( AScan( arrV019[ i, 3 ], diag ) > 0 )
      For Each row in model
        If row[ 1 ] == arrV019[ i, 8 ]
          If AScan( arr, {| x| x[ 2 ] == row[ 1 ] } ) == 0
            AAdd( arr, { PadR( AllTrim( row[ 2 ] ), 76 ), row[ 1 ] } )
            Exit
          Endif
        Endif
      Next
    Endif
  Next
  If Empty( arr )
    func_error( 4, 'В справочнике V022 не найдено моделей пациентов для вида ВМП ' + lvidvmp )
    Return Nil
  Endif
  popup_2array( arr, -r, c, k, 1, @ret_arr, 'Выбор модели пациента для ' + lvidvmp, 'GR+/RB*', 'N/RB*,W+/N' )
  If ValType( ret_arr ) == 'A'
    ret := Array( 2 )
    ret[ 1 ] := ret_arr[ 2 ]
    ret[ 2 ] := ret_arr[ 1 ]
  Endif

  Return ret

// 17.01.14 действия в ответ на выбор в меню 'Вид ВМП'
Function f_valid_vidvmp( get, old )

  If Empty( m1vidvmp )
    MMETVMP := Space( 67 ) ; M1METVMP := 0
    update_get( 'MMETVMP' )
  Elseif !( m1vidvmp == old ) .and. old != Nil .and. get != NIL
    MMETVMP := Space( 67 ) ; M1METVMP := 0
    update_get( 'MMETVMP' )
  Endif

  Return .t.

// 25.01.23 вернуть строку вида ВМП
Function ret_v018( lVIDVMP, lk_data )

  Local i, s := Space( 10 )
  Local arrV018 := getv018( lk_data )

  If !Empty( lVIDVMP ) .and. ( i := AScan( arrV018, {| x| x[ 1 ] == AllTrim( lVIDVMP ) } ) ) > 0
    s := arrV018[ i, 1 ] + '.' + arrV018[ i, 2 ]
  Endif

  Return s

// 19.06.24 вернуть строку метода ВМП
Function ret_v019( lMETVMP, lVIDVMP, lk_data )

  Local i, s := Space( 10 )
  Local arrV019 := getv019( lk_data )
  
  lVIDVMP := AllTrim( lVIDVMP )
  If !emptyany( lMETVMP, lVIDVMP )
    for i := 1 to len( arrV019 )
      if arrV019[ i, 1 ] == lMETVMP .and. arrV019[ i, 4 ] == lVIDVMP
        s := PadR( Str( arrV019[ i, 1 ], 4 ) + '.' + arrV019[ i, 2 ], 76 )
      endif
    next
  endif

  Return s
