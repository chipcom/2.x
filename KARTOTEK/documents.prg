// documents.prg - работа с документами пацтентов
#include 'inkey.ch'
#include 'common.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

//// ПОЛИС ОМС

// 04.06.22
Function func_valid_polis(_vpolis, _SPOLIS, _NPOLIS, is_volgograd)
  Local a_err := {}

  Valid_SN_Polis(_vpolis, _SPOLIS, _NPOLIS, a_err, is_volgograd)
  if !empty(a_err)
    n_message(a_err, , 'GR+/R', 'W+/R', , , 'G+/R')
  endif
  return .t.
  
// 04.06.22
Function Valid_SN_Polis(_vpolis, _SPOLIS, _NPOLIS, a_err, is_volgograd)
  Local i, c, CountDigit := 0, s := ''

  if empty(_vpolis)
    aadd(a_err, 'не заполнено поле "Вид полиса"')
  endif
  if empty(_npolis)
    aadd(a_err, 'не заполнен номер полиса')
  endif
  if _vpolis == 1
    DEFAULT is_volgograd TO .f.
    if is_volgograd // ТОЛЬКО ДЛЯ ВОЛГОГРАДСКОЙ ОБЛАСТИ
      s := alltrim(_SPOLIS) + alltrim(_NPOLIS)
      CountDigit := len(s)
      s := charrem(' ', CHARREPL('0123456789', s, SPACE(10)))
      if !empty(s)
        aadd(a_err, 'недопустимые символы в (старом) Волгоградском полисе "' + s + '"')
      elseif CountDigit != 16
        aadd(a_err, 'в (старом) Волгоградском полисе должно быть 16 цифр')
      endif
    endif
  else
    if !empty(_SPOLIS)
      aadd(a_err, 'для данного вида СЕРИЯ ПОЛИСА не заполняется')
    endif
    _NPOLIS := alltrim(_NPOLIS)
    s := charrem(' ', CHARREPL('0123456789', _NPOLIS, SPACE(10)))
    CountDigit := len(_NPOLIS)
    if !empty(s)
      aadd(a_err, '"' + s + '" недопустимые символы в НОМЕРЕ ПОЛИСА')
    elseif _vpolis == 2
      if CountDigit != 9
        aadd(a_err, _NPOLIS + ' - в НОМЕРЕ временного ПОЛИСА должно быть 9 цифр')
      endif
    elseif _vpolis == 3
      if CountDigit == 16
        if !f_checksum_polis(_NPOLIS)
          aadd(a_err, _NPOLIS + ' - неверная контрольная сумма в ПОЛИСЕ единого образца')
        endif
      else
        aadd(a_err, _NPOLIS + ' - в НОМЕРЕ ПОЛИСА должно быть 16 цифр')
      endif
    endif
  endif
  return NIL
  
// 04.06.22 проверить контрольную сумму в ПОЛИСЕ единого образца
Function f_checksum_polis(_NPOLIS)
  Local i, n, s := ''
  // а) Выбираются цифры, стоящие в нечётных позициях, по порядку,
  //    начиная справа, записываются в виде числа.

  for i := 15 to 1 step -2
    s += substr(_NPOLIS, i, 1)
  next
  // Полученное число умножается на 2.
  n := int(val(s) * 2)
  // б) Выбираются цифры, стоящие в чётных позициях, по порядку,
  //    начиная справа, записываются в виде числа.
  s := ''
  for i := 14 to 1 step -2
    s += substr(_NPOLIS, i, 1)
  next
  // Полученное число приписывается слева от числа, полученного в пункте а).
  s += lstr(n)
  // в) Складываются все цифры полученного в пункте б) числа.
  n := 0
  for i := 1 to len(s)
    n += int(val(substr(s, i, 1)))
  next
  // г) Полученное в пункте в) число вычитается из ближайшего большего
  //    или равного числа, кратного 10.
  n := int(val(right(lstr(n), 1)))
  i := 0
  if n > 0
    i := 10-n
  endif
  // В результате получается искомая контрольная цифра.
  return lstr(i) == right(_NPOLIS, 1)

//// СНИЛС

// проверка СНИЛС
Function val_snils(s, par, /*@*/msg)
  Local fl := .t., v1, v2, i, k := len(charrem(' ',s))

  DEFAULT msg TO ''
  if k == 0
    //
  elseif k == 11
    if s == replicate('0', 11)
      msg := 'В поле "СНИЛС" одни нули'
    else
      v1 := int(val(left(s, 9)))
      if v1 > 1001998
        v1 := 0
        for i := 1 to 9
          v1 += int(val(substr(s, 10 -i, 1)) * i)
        next
        v1 := int(v1 % 101)
        if v1 == 100
          v1 := 0
        endif
        v2 := int(val(right(s, 2)))
        if v1 != v2
          msg := 'Неверная контрольная сумма в коде "СНИЛС"'
        endif
      else
        msg := 'Значение поля "СНИЛС" меньше "001-001-998"'
      endif
    endif
  else
    msg := 'Заполнены не все знаки поля "СНИЛС"'
  endif
  if !empty(msg)
    if par == 1  // для GET-системы
      func_error(4, msg)
    else  // для проверки ТФОМС
      fl := .f.
    endif
  endif
  return fl
  
//// УДОСТОВЕРЕНИЕ ЛИЧНОСТИ

// проверка на правильность серии удостоверения личности
Function val_ud_ser(par, k, s, /*@*/msg)
  Local fl := .t., i, c, _sl, _sr, _n

  DEFAULT msg TO ''
  s := alltrim(s)
  if k == 14
    _sl := ALLTRIM(TOKEN(s, ' ', 1))
    _sr := ALLTRIM(TOKEN(s, ' ', 2))
    IF (EMPTY(_sl) .OR. LEN(_sl) != 2 .OR. !yes_number(_sl)) .or. ;
       (EMPTY(_sr) .OR. LEN(_sr) != 2 .OR. !yes_number(_sr))
      msg := 'серия паспорта РФ должна состоять из двух двузначных чисел'
    ENDIF
  elseif eq_any(k, 1, 3) // "Паспорт гражд.СССР" или "Свид-во о рождении"
    _n := NUMTOKEN(s, '-') - 1
    _sl := ALLTRIM(TOKEN(s, '-', 1))
    _sl := gniRIMTORUS(_sl)
    _sr := ALLTRIM(TOKEN(s, '-', 2))
    IF _n == 0
      msg := 'отсутствует разделитель "-" частей серии'
    ELSEIF _n > 1
      msg := 'лишний разделитель "-"'
    ELSEIF EMPTY(_sl)
      msg := 'отсутствует числовая часть серии'
    ELSEIF !EMPTY(CHARREPL('1УХЛС', _sl, SPACE(10)))
      msg := 'числовая часть серии состоит из символов: 1 У Х Л С (I V X L C)'
    ELSEIF !(_sl == gniRIMTORUS(gniNOMTORIM(gniRIMTONOM(gniRUSTORIM(_sl)))))
      msg := 'некорректно введена числовая часть серии'
    ELSEIF EMPTY(_sr) .OR. LEN(_sr) != 2 .OR. !yes_rus_str(_sr)
      msg := 'после разделителя "-" должны быть ДВЕ pусcкие заглавные буквы'
    ENDIF
  endif
  if !empty(msg)
    msg := '"' + s + '" - ' + msg
    if par == 1  // для GET-системы
      func_error(4, msg)
    else  // для проверки ТФОМС
      fl := .f.
    endif
  endif
  return fl
  
// проверка на правильность номера удостоверения личности
Function val_ud_nom(par, k, s, /*@*/msg)
  Static arr_d := { ;
   { 1, 6  }, ;
   { 3, 6  }, ;
   { 4, 7  }, ;
   { 6, 6  }, ;
   { 7, 6, 7}, ;
   { 8, 7  }, ;
   {14, 6, 7}, ;
   {15, 7  }, ;
   {16, 6, 7}, ;
   {17, 6  }}
  Local fl := .t., d1, d2
  
  DEFAULT msg TO ''
  s := alltrim(s)
  if (j := ascan(arr_d, {|x| x[1] == k })) > 0
    if !yes_number(s)
      msg := 'недопустимый символ в номере уд.личности "' + inieditspr(A__MENUVERT, getVidUd(), k) + '"'
    else
      d1 := arr_d[j, 2]
      d2 := iif(len(arr_d[j]) == 2, d1, arr_d[j, 3])
      if !between(len(s), d1, d2)
        msg := 'неверное кол-во цифр в номере уд.личности "' + inieditspr(A__MENUVERT, getVidUd(), k) + '"'
      endif
    endif
  endif
  if !empty(msg)
    msg := '"' + s + '" - ' + msg
    if par == 1  // для GET-системы
      func_error(4, msg)
    else  // для проверки ТФОМС
      fl := .f.
    endif
  endif
  return fl

//// МАНИПУЛЯЦИИ С АРАБСКИМИ И РИМСКИМИ ЦИФРАМИ

// проверка: "в строке все символы цифры?"
Function yes_number(s)
  return EMPTY(CHARREPL('0123456789', s, SPACE(10)))

// проверка: "в строке все символы русские буквы?"
Function yes_rus_str(s)
  return EMPTY(CHARREPL('АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ', s, SPACE(33)))

// рисмкое число, записанное латинскими символами, записать русскими символами
FUNCTION gniRIMTORUS(_s)
  RETURN CHARREPL('IVXLC', _s, '1УХЛС')

// рисмкое число, записанное русскими символами, записать латинскими символами
FUNCTION gniRUSTORIM(_s)
  RETURN CHARREPL('1УХЛС', _s, 'IVXLC')

// перевести арабское число в римское
FUNCTION gniNOMTORIM(_s, _c1, _c2, _c3, _c4, _c5, _c6, _c7)
  LOCAL _s1 := REPLALL(STR(_s, 3), '0'), _s2, _s3, _n1, _n2, _n3, _ret := ''

  DEFAULT _c1 TO 'I', _c2 TO 'V', _c3 TO 'X', _c4 TO 'L', ;
          _c5 TO 'C', _c6 TO 'D', _c7 TO 'M'
  _n3 := VAL(SUBSTR(_s1, LEN(_s1), 1))
  _n2 := VAL(SUBSTR(_s1, LEN(_s1) - 1, 1))
  _n1 := VAL(SUBSTR(_s1, LEN(_s1) - 2, 1))
  _ret += gniDIGTORIM(_n1, _c5, _c6, _c7)
  _ret += gniDIGTORIM(_n2, _c3, _c4, _c5)
  _ret += gniDIGTORIM(_n3, _c1, _c2, _c3)
  RETURN _ret

// перевести римское число в арабское
FUNCTION gniRIMTONOM(_s, _c1, _c2, _c3, _c4, _c5, _c6, _c7)
  LOCAL _ret := 0, i, _nl, aArr := {}

  DEFAULT _c1 TO 'I', _c2 TO 'V', _c3 TO 'X', _c4 TO 'L', ;
          _c5 TO 'C', _c6 TO 'D', _c7 TO 'M'
  _s := ALLTRIM(_s)
  _nl := LEN(_s)
  FOR i := 1 TO _nl
    AADD(aArr, SUBSTR(_s, i, 1))
  NEXT
  FOR i := 1 TO _nl
    IF aArr[i] == _c7
      _ret += 1000
    ELSEIF aArr[i] == _c6
      _ret += 500
    ELSEIF aArr[i] == _c5
      IF i < _nl .AND. (aArr[i + 1] == _c6 .OR. aArr[i + 1] == _c7)
        _ret -= 100
      ELSE
        _ret += 100
      ENDIF
    ELSEIF aArr[i] == _c4
      _ret += 50
    ELSEIF aArr[i] == _c3
      IF i < _nl .AND. (aArr[i + 1] == _c4 .OR. aArr[i + 1] == _c5)
        _ret -= 10
      ELSE
        _ret += 10
      ENDIF
    ELSEIF aArr[i] == _c2
      _ret += 5
    ELSEIF aArr[i] == _c1
      IF i < _nl .AND. (aArr[i + 1] == _c2 .OR. aArr[i + 1] == _c3)
        _ret -= 1
      ELSE
        _ret += 1
      ENDIF
    ENDIF
  NEXT
  RETURN _ret

// перевести арабскую цифру в римскую
FUNCTION gniDIGTORIM(_s, _c1, _c2, _c3)
  LOCAL _c := ''

  DO CASE
    CASE _s == 1
      _c := _c1
    CASE _s == 2
      _c := _c1 + _c1
    CASE _s == 3
      _c := _c1 + _c1 + _c1
    CASE _s == 4
      _c := _c1 + _c2
    CASE _s == 5
      _c := _c2
    CASE _s == 6
      _c := _c2 + _c1
    CASE _s == 7
      _c := _c2 + _c1 + _c1
    CASE _s == 8
      _c := _c2 + _c1 + _c1 + _c1
    CASE _s == 9
      _c := _c1 + _c3
  ENDCASE
  RETURN _c

/////////////////////////////////////////
// проверка на правильность серии удостоверения личности
function checkDocumentSeries( oGet, vid_ud )
	local fl := .t., i, c, _sl, _sr, _n
	local msg, ser_ud
	
	if lastkey() == K_UP
		return fl
	endif
	msg := ''
	ser_ud := alltrim( oGet:buffer )
	if vid_ud == 14 
		if allCharIsDigit( ser_ud ) .and. ( len( ser_ud ) == 4 )	// "Паспорт гражд.РФ"
			oGet:pos := 3  // курсор в 3-ю позицию
			oGet:insert( ' ' )
			oGet:assign()
		else
			_sl := alltrim( token( ser_ud, ' ', 1 ) )
			_sr := alltrim( token( ser_ud, ' ', 2 ) )
			if ( empty( _sl ) .or. len( _sl ) != 2 .or. !allCharIsDigit( _sl ) ) .or. ;
					( empty( _sr ) .or. len( _sr ) != 2 .or. ! allCharIsDigit( _sr ) )
				msg := 'серия паспорта РФ должна состоять из двух двузначных чисел'
			else
				oGet:buffer := _sl + ' ' + left(_sr, 2)
				oGet:assign()
			endif
		endif
	elseif eq_any( vid_ud, 1, 3 )	// "Паспорт гражд.СССР" или "Свид-во о рождении"
		_n := numtoken( ser_ud, '-' ) - 1
		_sl := alltrim( token( ser_ud, '-', 1 ) )
		// _sl := convertNumberLatinCharInCyrillicChar( _sl )
		_sl := convertNumberCyrillicCharInLatinChar( _sl )
		_sr := alltrim( token( ser_ud, '-', 2 ) )
		if _n == 0
			msg := 'отсутствует разделитель "-" частей серии'
		elseif _n > 1
			msg := 'лишний разделитель "-"'
		elseif empty( _sl )
			msg := 'отсутствует числовая часть серии'
		// elseif !empty( charrepl( '1УХЛС', _sl, space( 10 ) ) )
		elseif !empty( charrepl( '1УХЛСIVXLC', _sl, space( 10 ) ) )
			msg := 'числовая часть серии состоит из символов: 1 У Х Л С (I V X L C)'
		// elseif !( _sl == convertNumberLatinCharInCyrillicChar( convertArabicNumberToRoman( convertRomanNumberToArabic( convertNumberCyrillicCharInLatinChar( _sl ) ) ) ) )
		// 	msg := 'некорректно введена числовая часть серии'
		elseif empty( _sr ) .or. len( _sr ) != 2 .or. !allCharIsCyrillic( _sr )
			msg := 'после разделителя "-" должны быть ДВЕ pусcкие заглавные буквы'
    else
      oGet:buffer := _sl + '-' + left(_sr, 2)
      oGet:assign()
    endif
	endif
	if !empty( msg )
		msg := '"' + ser_ud + '" - ' + msg
		hb_alert( msg, , , 4 )
		fl := .f.
	endif
	return fl

// проверка: "в строке все символы цифры?"
function allCharIsDigit( s )
  return empty( charrepl( '0123456789', s, SPACE( 10 ) ) )

// проверка: "в строке все символы русские буквы?"
function allCharIsCyrillic( s )
  return empty( charrepl( 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ', s, SPACE( 33 ) ) )

// рисмкое число, записанное латинскими символами, записать русскими символами
function convertNumberLatinCharInCyrillicChar( _s )
  return charrepl( 'IVXLC', _s, '1УХЛС' )

// рисмкое число, записанное русскими символами, записать латинскими символами
function convertNumberCyrillicCharInLatinChar( _s )
  return charrepl( '1УХЛС', _s, 'IVXLC' )

// перевести арабское число в римское

function convertArabicNumberToRoman( _s, _c1, _c2, _c3, _c4, _c5, _c6, _c7 )
  local _s1 := replall( str( _s, 3 ), '0' ), _s2, _s3, _n1, _n2, _n3, _ret := ''

  DEFAULT _c1 TO 'I', _c2 TO 'V', _c3 TO 'X', _c4 TO 'L', ;
    _c5 TO 'C', _c6 TO 'D', _c7 TO 'M'
  _n3 := val( substr( _s1, len( _s1 ), 1 ) )
  _n2 := val( substr( _s1, len( _s1 ) - 1, 1 ) )
  _n1 := val( substr( _s1, len( _s1 ) - 2, 1 ) )
  _ret += convertArabicNumeralsToRomanNumerals( _n1, _c5, _c6, _c7 )
  _ret += convertArabicNumeralsToRomanNumerals( _n2, _c3, _c4, _c5 )
  _ret += convertArabicNumeralsToRomanNumerals( _n3, _c1, _c2, _c3 )
  return _ret

// перевести римское число в арабское
function convertRomanNumberToArabic(_s, _c1, _c2, _c3, _c4, _c5, _c6, _c7)
  local _ret := 0, i, _nl, aArr := {}

  DEFAULT _c1 TO 'I', _c2 TO 'V', _c3 TO 'X', _c4 TO 'L', ;
    _c5 TO  'C', _c6 TO 'D', _c7 TO 'M'
  _s := alltrim( _s )
  _nl := len( _s )
  for i := 1 to _nl
    aadd( aArr, substr( _s, i, 1 ) )
  next
  for i := 1 to _nl
    if aArr[ i ] == _c7
      _ret += 1000
    elseif aArr[ i ] == _c6
      _ret += 500
    elseif aArr[ i ] == _c5
      if i < _nl .and. ( aArr[ i + 1 ] == _c6 .or. aArr[ i + 1 ] == _c7 )
        _ret -= 100
      else
        _ret += 100
      endif
    elseif aArr[ i ] == _c4
      _ret += 50
    elseif aArr[ i ] == _c3
      if i < _nl .and. ( aArr[ i + 1 ] == _c4 .or. aArr[ i + 1 ] == _c5 )
        _ret -= 10
      else
        _ret += 10
      endif
    elseif aArr[ i ] == _c2
      _ret += 5
    elseif aArr[ i ] == _c1
      if i < _nl .and. ( aArr[ i + 1 ] == _c2 .or. aArr[ i + 1 ] == _c3 )
        _ret -= 1
      else
        _ret += 1
      endif
    endif
  next
  return _ret

// перевести арабскую цифру в римскую
function convertArabicNumeralsToRomanNumerals( _s, _c1, _c2, _c3 )
  local _c := ''

  do case
    case _s == 1
      _c := _c1
    case _s == 2
      _c := _c1 + _c1
    case _s == 3
      _c := _c1 + _c1 + _c1
    case _s == 4
      _c := _c1 + _c2
    case _s == 5
      _c := _c2
    case _s == 6
      _c := _c2 + _c1
    case _s == 7
      _c := _c2 + _c1 + _c1
    case _s == 8
      _c := _c2 + _c1 + _c1 + _c1
    case _s == 9
      _c := _c1 + _c3
  endcase
  return _c
