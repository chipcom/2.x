*
*******************************************************************************
* 24.04.18 ChoiceObjectFromArray( r, c, sourceArray, lMulti ) -
*******************************************************************************
*
#include "set.ch"
#include "inkey.ch"
#include "hbthread.ch"

#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

function ChoiceObjectFromArray( r, c, sourceArray, lMulti, cTitle, /*@*/c_uch )
	local aRet := {}, aName := {}, aID := {}, aObject := {}
	local i, k, t_mas, c2, buf := savescreen(), obj
	local item, arrSaved := {}, iRet := 0

	hb_Default( @c_uch, 0 )
	if lMulti		// выбор многих объектов
		for each obj in sourceArray
			aadd( aName, obj:Name() )
			aadd( aID, obj:ID() )
			aadd( aObject, obj )
		next
	
		count_uch := c_uch := len( aID )
		if count_uch == 0
			hb_Alert( 'Список выбора пустой!', , , 4 )
		elseif count_uch == 1
			aRet := aObject
		else
			arrSaved := list2arr( getWorkAreaVar( 'WorkArea', 'Saved', substr( sourceArray[ 1 ]:ClassName, 2 ) ) )
			if r < 0 // т.е. GET находится внизу экрана
				k := abs( r ) - 2
				if ( r := k - count_uch - 1 ) < 2
					r := 2
				endif
			else
				if ( k := r + count_uch + 1 ) > maxrow() - 2
					k := maxrow() - 2
				endif
			endif
			c2 := c + 35 + 1
			if c2 > 77
				c2 := 77 ; c := 76 - 35
			endif
			t_mas := aclone( aName )		// массив имен подразделений
			
			&& aeval( t_mas, { | x, i | ;
					&& t_mas[ i ] := if( ascan( t_mas, aID[ i ] ) > 0, " * ", "   " ) + t_mas[ i ] } )
			aeval( t_mas, { | x, i | t_mas[ i ] := "   " + t_mas[ i ] } )
			for each item in arrSaved
				if ( i := ascan( aID, item ) ) > 0
					t_mas[ i ] := " * " + alltrim( t_mas[ i ] )
				endif
			next
  
			status_key( '^<Esc>^ отмена;  ^<Enter>^ выбор;  ^<Ins>^ установить/снять отметку' )
			do while .t.
				if ( iRet := popup( r, c, k, c2, t_mas, i, color_uch, .t., 'fmenu_reader', , ;
						cTitle, col_tit_uch ) ) > 0
					
					for i := 1 TO len( t_mas )
						if "*" == substr( t_mas[i], 2, 1 )
							aadd( aRet, aObject[ i ] )
						endif
					next
					if empty( aRet )
						hb_Alert( 'Необходимо отметить хотя бы один элемент списка!', , , 4 )
						loop
					else
						exit
					endif
				else
					exit
				endif
			enddo
		endif
	endif
	restscreen( buf )
	if iRet > 0
		aID := {}
		&& for each item in aRet
			&& aadd( aID, item:ID )
		&& next
		aeval( aRet, { | x, i | aadd( aID, x:ID ) } )
		arrSaved := setWorkAreaVar( 'WorkArea', 'Saved', substr( sourceArray[ 1 ]:ClassName, 2 ), arr2list( aID ) )
	endif
	return aRet
