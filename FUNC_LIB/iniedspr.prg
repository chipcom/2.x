#include 'function.ch'
#include 'edit_spr.ch'
#include 'inkey.ch'
#include 'getexit.ch'

// функция инициализации переменной
Function inieditspr( type, arr_name, j )

  // type     - тип инициализации
  // arr_name - двумерный или одномерный массив (для битовой комбинации)
  // или наименование базы данных в случае A__POPUP...
  // j        - число для инициализации
  Local s := '', k := 0

  Do Case
  Case equalany( type, A__MENUHORIZ, A__MENUVERT )
    If ( k := AScan( arr_name, {| x| x[ 2 ] == j } ) ) > 0
      s := arr_name[ k, 1 ]
    Else
      s := Space( 10 )
    Endif
  Case type == A__MENUBIT
    If ValType( arr_name[ 1 ] ) == 'A'
      AEval( arr_name, {| x| s += if( IsBit( j, x[ 2 ] ), AllTrim( x[ 1 ] ) + ', ', '' ) } )
    Else
      AEval( arr_name, {| x, i| s += if( IsBit( j, i ), AllTrim( x ) + ', ', '' ) } )
    Endif
    s := if( Empty( s ), Space( 10 ), SubStr( s, 1, Len( s ) -2 ) )
  Case equalany( type, A__POPUPBASE, A__POPUPBASE1, A__POPUPEDIT, A__POPUPMENU )
    s := retpopupedit( arr_name, j )
  Endcase

  Return s
