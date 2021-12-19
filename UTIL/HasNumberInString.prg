function HasNumberInString( number, string )
	local ret := .f., k
	local ch

	if  number >= 0 .and. number <= 255
		k := 1
		do while !( ( ch := substr( string, k, 1 ) ) == chr( 0 ) )
			if asc( ch ) == number
				ret := .t.
				exit
			endif
			if ++k > 255
				ret := .f.
				exit
			endif
		enddo
	&& else
		&& return ret
	endif
	return ret
