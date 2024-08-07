#include "set.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 11.07.24
Function inp_bit_task_bay( k, r, c )
	Local mlen, t_mas := {}, buf := savescreen(), ret, ;
		i, tmp_color := setcolor(), m1var := "", s := "",;
		r1, a_uch := {}
	local arr := {}, kk, lens := 0
	
	Local oTask := Nil
	local tempStr := '', numTask := 0
	
	local arr1 := { ;
		{ "���������� �����������"            , X_REGIST, , .t., "������������"}, ;
		{ "���� ����� ��樮���"           , X_PPOKOJ, , .t., "�������� �����"}, ;
		{ "��易⥫쭮� ����樭᪮� ���客����", X_OMS   , , .t., "���"}, ;
		{ "���� ���ࠢ����� �� ��ᯨ⠫�����"  , X_263   , , .F., "��������������"}, ;
		{ "����� ��㣨"                      , X_PLATN , , .t., "������� ������"}, ;
		{ "��⮯����᪨� ��㣨 � �⮬�⮫����", X_ORTO  , , .t., "���������"}, ;
		{ "���� ����樭᪮� �࣠����樨"       , X_KASSA , , .t., "�����"}, ;
		{ "������஢���� �ࠢ�筨���"         , X_SPRAV , , .t., '' }, ;
		{ "��ࢨ�� � ����ன��"                 , X_SERVIS, , .t., '' }, ;
		{ "����ࢭ�� ����஢���� ���� ������"   , X_COPY  , , .t., '' }, ;
		{ "��२�����஢���� ���� ������"      , X_INDEX , , .t., '' } ;
	}
//	{ "��� ����樭᪮� �࣠����樨"         , X_KEK   , , .F., "���"}, ;
	
	for i := 1 to len( arr1 )
		if ( kk := arr1[ i, 2 ] ) < 10  // ��� �����
			arr1[ i, 4 ] := ( substr( glob_mo[ _MO_PROD ], kk, 1 ) == '1' )
			if arr1[ i, 4 ]
				fl_exit := .f.
			endif
		endif
		// ���� ���ࠢ����� �� ��ᯨ⠫�����
		if kk == X_263 .and. ( is_napr_pol .or. is_napr_stac ) //	.and. ( substr( glob_mo[ _MO_PROD ], X_263, 1 ) == '1' )
			arr1[ i, 4 ] := .t.
			fl_exit := .f.
		endif
		if arr1[ i, 4 ]
			aadd( arr, arr1[ i ] )
			lens := max( lens, len( arr1[ i, 1 ] ) )
		endif
	next
	
	mywait()
	
	FOR i := 1 TO Len( arr1 )
		if arr1[ i, 4 ]
			s := if( chr( i ) $ k, " * ", "   " ) + ;
					padr( arr1[ i, 1 ], 40 ) + str( i, 10 )
		else
			s := " - " + ;
					padr( arr1[ i, 1 ], 40 ) + str( i, 10 )
		endif
		aadd( t_mas, s )
		s := ""
	NEXT
	mlen := len( t_mas )
//	asort( t_mas, , , { | x, y | substr( x, 4, 40 ) < substr( y, 4, 40 ) } )
	i := 1
	status_key( "^<Esc>^ - �⪠�; ^<Enter>^ - ���⢥ত����; ^<Ins>^ - ��⠭�����/���� �⬥��" )
	if ( r1 := r - 1 - mlen - 1) < 2
		r1 := 2
	endif
	if ( ret := popup( r1, 19, r - 1, 62, t_mas, i, color0, .t., "fmenu_reader_task", , ;
						"����� ��� ࠡ���", col_tit_popup ) ) > 0
		for i := 1 to mlen
			if "*" == substr( t_mas[ i ], 2, 1 )
				k := chr( int( val( right( t_mas[ i ], 10 ) ) ) )
				m1var += k
			endif
		next
		numTask := len( m1var )
		tempStr := ' �����'
		if numTask == 1
			tempStr := tempStr +'�'
		elseif  numTask > 1.and. numTask < 5
			tempStr := tempStr +'�'
		endif
		s := "= " + lstr( numTask ) + tempStr + " ="
	endif
	restscreen( buf )
	setcolor( tmp_color )
	Return iif( ret == 0, NIL, { m1var, s } )

Function fmenu_reader_task( nKey, i )

	do case
		case nKey == K_INS
			if substr( parr[ i ], 2, 1 ) != "-"
				parr[ i ] := stuff( parr[ i ], 2, 1, if( "*" == substr( parr[ i ], 2, 1 ), " ", "*" ) )
				keyboard chr( K_TAB )
			endif
		case nKey == 43  // "+"
			for i := 1 to len( parr )
				if substr( parr[ i ], 2, 1 ) != "-"
					parr[ i ] := stuff( parr[ i ], 2, 1, "*" )
				endif
			next
		case nKey == 45  // "-"
			for i := 1 to len( parr )
				if substr( parr[ i ], 2, 1 ) != "-"
					parr[ i ] := stuff( parr[ i ], 2, 1, " " )
				endif
			next
	endcase
	return 0	