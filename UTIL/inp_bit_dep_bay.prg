#include "set.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"


*****
Function inp_bit_dep_bay( k, r, c )
	Local mlen, t_mas := {}, buf := savescreen(), ret, ;
		i, tmp_color := setcolor(), m1var := "", s := "",;
		r1, a_uch := {}
	Local oDepartment := Nil
	
	mywait()
	
	FOR EACH oDepartment IN TDepartmentDB():GetList( sys_date )
		s := if( chr( oDepartment:ID() ) $ k, " * ", "   " ) + ;
                padr( oDepartment:Name(), 30 ) + str( oDepartment:ID(), 10 )
		aadd( t_mas, s )
		s := ""
	NEXT
	mlen := len( t_mas )
	asort( t_mas, , , { | x, y | substr( x, 4, 30 ) < substr( y, 4, 30 ) } )
	i := 1
	status_key( "^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - установить/снять отметку" )
	if ( r1 := r - 1 - mlen - 1) < 2
		r1 := 2
	endif
	if ( ret := popup( r1, 19, r - 1, 57, t_mas, i, color0, .t., "fmenu_reader", , ;
						"Учреждения для работы", col_tit_popup ) ) > 0
		for i := 1 to mlen
			if "*" == substr( t_mas[i], 2, 1 )
				k := chr( int( val( right( t_mas[i], 10 ) ) ) )
				m1var += k
			endif
		next
		s := "= " + lstr( len( m1var ) ) + "учр. ="
	endif
	restscreen( buf )
	setcolor( tmp_color )
	Return iif( ret==0, NIL, { m1var, s } )
