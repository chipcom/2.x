#include 'hbclass.ch'
#include 'property.ch'
#include 'common.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// класс описывающий полис ОМС
CREATE CLASS TPolicyOMS
  VISIBLE:
    PROPERTY PolicyType AS NUMERIC READ getPolicyType WRITE setPolicyType		// вид полиса (от 1 до 3) 1-старый,2-врем.,3-новый;по умолчанию 3 - старый
		PROPERTY PolicySeries AS STRING READ getPolicySeries WRITE setPolicySeries	// серия полиса, для наших - разделить по пробелу
		PROPERTY PolicyNumber AS STRING READ getPolicyNumber WRITE setPolicyNumber	// номер полиса, 'для иногородних - вынуть из ""k_inog"" и разделить'
		PROPERTY SMO AS STRING READ getSMO WRITE setSMO								// реестровый номер СМО, преобразовать из старых кодов в новые, иногродние = 34
    PROPERTY AsString READ GetAsString(...)       // представление документа по установленной форматной строке
    PROPERTY Format READ FFormat WRITE SetFormat  // форматная строка вывода представления документа

    CLASSDATA	aMenuType	AS ARRAY	INIT {{'старый', 1}, ;
      {'врем. ', 2}, ;
      {'новый ', 3} }

    METHOD New(nType, cSeries, cNumber, cSMO)
    METHOD Edit()
    METHOD checksumPolisOMS(cNumber)
  HIDDEN:
    // формат по умолчанию : TYPE - тип полиса, SSS - серия, NNN - номер, ISSUE - издатель, DATE - дата выдачи
    DATA FFormat        INIT 'TYPE #SSS #NNN'
    DATA FPolicyType    INIT 3
    DATA FPolicySeries  INIT space(10)
    DATA FPolicyNumber	INIT space(20)
    DATA FSMO           INIT space(5)

		METHOD getPolicyType		INLINE ::FPolicyType
    METHOD setPolicyType(param)
    METHOD getPolicySeries	INLINE ::FPolicySeries
    METHOD setPolicySeries(param)
    METHOD getPolicyNumber	INLINE ::FPolicyNumber
    METHOD setPolicyNumber(param)
    METHOD getSMO	INLINE ::FSMO
    METHOD setSMO(param)
    METHOD SetFormat(format)    INLINE ::FFormat := format
    METHOD GetAsString(format)
    METHOD setPolicyOMS(oGet, vidpolis)
    METHOD validNumberPolicyOMS(is_volgograd)
ENDCLASS

METHOD New(nType, cSeries, cNumber, cSMO) CLASS TPolicyOMS
  // Local kartotek_ := {;
  //   {"VPOLIS",    "N",  1,0},; // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый;по умолчанию 1 - старый
  //   {"SPOLIS",    "C", 10,0},; // серия полиса;;для наших - разделить по пробелу
  //   {"NPOLIS",    "C", 20,0},; // номер полиса;;"для иногородних - вынуть из ""k_inog"" и разделить"
  //   {"SMO",       "C",  5,0},; // реестровый номер СМО;;преобразовать из старых кодов в новые, иногродние = 34

  ::FPolicyType := hb_defaultvalue(nType, 1)
  ::FPolicySeries := padr(hb_defaultvalue(cSeries, space(10)), 10)
  ::FPolicyNumber := padr(hb_defaultvalue(cNumber, space(20)), 20)
  ::FSMO := padr(hb_defaultvalue(cSMO, space(5)), 5)
  return self

METHOD PROCEDURE setPolicyType (param)	CLASS TPolicyOMS

  if isnumber(param)
    ::FPolicyType := param
  endif
  return
  
METHOD PROCEDURE setPolicySeries(param)	CLASS TPolicyOMS

  if ischaracter(param)
    ::FPolicySeries := padr(param, 10)
  endif
  return
  
METHOD PROCEDURE setPolicyNumber(param)	CLASS TPolicyOMS
  
  if ischaracter(param)
    ::FPolicyNumber := padr(param, 20)
  endif
  return
  
METHOD PROCEDURE setSMO(param)	CLASS TPolicyOMS

  if ischaracter(param)
    ::FSMO := padr(param, 5)
  endif
  return
  
METHOD FUNCTION GetAsString(format) CLASS TPolicyOMS
  local asString := ''
  local numToken
  local i
  local j := 0
  local s
  local tk
  local tkSep
  local itm
  local oPublisher := nil
  local ch
  local mismo, m1ismo := '', mnameismo := space(100)
  local mnamesmo, m1namesmo
  local picture_number := '@R 9999 9999 9999 9999'
  local rec_inogSMO := 0
    
  if empty(format)
    format := ::FFormat
  endif
  numToken := NumToken(format, ' ')	// разделитель подстрок только 'пробел'
  for i := 1 to numToken
    s := ''
    tk := Token(format, ' ', i)	// разделитель подстрок только 'пробел'
    ch := alltrim(TokenSep(.t.))
    tkSep := ' '
    itm := upper(alltrim(tk))
    do case
      case itm == 'TYPE'
        if (j := ascan(::aMenuType, {| x | x[2] == ::FPolicyType})) > 0
        s := alltrim(::aMenuType[j, 1])
      endif
    case itm == 'SSS'
      if ! empty(::FPolicySeries)
        s := alltrim(::FPolicySeries)
      endif
    case itm == '#SSS'
      if ! empty(::FPolicySeries)
        s := 'серия:' + alltrim(::FPolicySeries)
      endif
    case itm == '#NNN'
      if ! empty(::FPolicyNumber)
        s := '№ ' + alltrim(if(::FPolicyType == 3, transform(::FPolicyNumber, picture_number ), ::FPolicyNumber))
      endif
    case itm == 'ISSUE'
      if alltrim(::FSMO) == '34' .and. len(alltrim(::FSMO)) == 2
        mnameismo := ret_inogSMO_name(2, @rec_inogSMO, .t.)
      elseif left(::FSMO, 2) == '34'
        // Волгоград
      elseif ! empty(::FSMO)
        m1ismo := ::FSMO
        ::FSMO := '34'
      endif

      mismo     := init_ismo(m1ismo)
    
      if empty(m1namesmo := int(val(::FSMO)))
        m1namesmo := glob_arr_smo[1, 2] // по умолчанию = КапиталЪ Медстрах
      endif
      mnamesmo := inieditspr(A__MENUVERT, glob_arr_smo, m1namesmo)
      if m1namesmo == 34
        if !empty(mismo)
          mnamesmo := mismo
        elseif !empty(mnameismo)
          mnamesmo := mnameismo
        endif
      endif
      s := alltrim(mnamesmo)
    otherwise
      s := alltrim(tk)	// просто переносим текст
    endcase
    // s += ch
    if (s != nil) .and. (! empty(s))
      asString += iif(i == 1, '', tkSep) + s
    endif
  next
  return asString

** 26.08.22 ввод данных полиса ОМС
METHOD FUNCTION Edit() CLASS TPolicyOMS
	local tmp_keys, tmp_gets, buf
	local iRow
	local oBox
	local series := space(10)
	local number := space(20)
	local arrError, flagError := .f.
	local sPicture
	local sPictureSeries
	local picture_number := "@R 9999 9999 9999 9999"
  local rec_inogSMO := 0

	
	private mvidpolis := '', ; // вид полиса
		m1vidpolis := 3, ;	// по умолчанию новый полис
		mnamesmo, m1namesmo, msmo := space(5), ;
		mismo, m1ismo := '', mnameismo := space(100)

	if empty(::FPolicyNumber)
		mvidpolis := inieditspr(A__MENUVERT, TPolicyOMS():aMenuType, m1vidpolis)		// вид полиса
	else
		m1vidpolis := ::FPolicyType
		mvidpolis := inieditspr(A__MENUVERT, TPolicyOMS():aMenuType, m1vidpolis)		// вид полиса
		series := ::FPolicySeries
	// 	&& if m1vidpolis == 3
	// 		&& number := transform(oPolicyOMS:PolicyNumber, picture_number)
	// 	&& else
	// 		number := oPolicyOMS:PolicyNumber
	// 	&& endif

		msmo        := ::FSMO    // реестровый номер СМО
		if alltrim(msmo) == '34'
      mnameismo := ret_inogSMO_name(2, @rec_inogSMO, .t.)
      // 		mnameismo := ret_inogSMO_name_bay(oPatient, oPolicyOMS)
		elseif left(msmo, 2) == '34'
			// Волгоградская область
		elseif !empty(msmo)
			m1ismo := msmo
			msmo := '34'
		endif
		
    mismo     := init_ismo(m1ismo)

		if empty(m1namesmo := int(val(msmo)))
			m1namesmo := glob_arr_smo[1, 2] // по умолчанию = КапиталЪ Медстрах
		endif
		mnamesmo := inieditspr(A__MENUVERT, glob_arr_smo, m1namesmo)
		if m1namesmo == 34
			if !empty(mismo)
				mnamesmo := padr(mismo, 41)
			elseif !empty(mnameismo)
				mnamesmo := padr(mnameismo, 41)
			endif
		endif

	endif

	buf := savescreen()
	change_attr()
	iRow := 10
	tmp_keys := my_savekey()
	save gets to tmp_gets
	
	oBox := TBox():New( iRow, 10, iRow + 5, 70, .t. )
	oBox:CaptionColor := 'B/B*'
	oBox:Color := cDataCGet
	oBox:MessageLine := '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода'
	oBox:Caption := 'Редактирование данных полиса ОМС'
	oBox:View()
	
	sPicture :=  if(eq_any(m1vidpolis, 3), picture_number, if(eq_any(m1vidpolis, 3), ;
				'@R 9999999999999999999', '@R 999999999'))
	// do while .t.
		iRow := 10
		@ ++iRow, 12 say 'Вид полиса:' get mvidpolis ;
					reader {| x | menu_reader(x, TPolicyOMS():aMenuType, A__MENUVERT, , , .f.)} ;
					valid {| oGet | ( ;
					::setPolicyOMS(oGet, m1vidpolis), ;
					sPicture :=  if(eq_any(m1vidpolis, 3), picture_number, if(eq_any(m1vidpolis, 3), ;
							'@R 9999999999999999999', '@R 999999999')), ;
					update_gets())}
	// 				&& sPicture :=  if(eq_any(m1vidpolis, 3), picture_number, '@S20'), ;
	// 				&& number := transform(oPolicyOMS:PolicyNumber, if(eq_any(m1vidpolis, 3), picture_number, '@S20')), ;

		@ ++iRow, 12 say 'Серия:' get series when if(m1vidpolis != 1, .f., .t.)
		@ iRow, col() + 1 say 'Номер:' get number ;
					valid {| oGet | roCheckPolicyOMS(oGet, m1vidpolis, oPatient, oPolicyOMS)} ;
					picture sPicture
	// 				&& picture if(eq_any(m1vidpolis, 3), picture_number, '@S20')
	
		@ ++iRow, 12 say 'СМО' get mnamesmo ;
					reader {| x | menu_reader(x, glob_arr_smo, A__MENUVERT, , , .f.)} ;
					valid {| oGet | func_valid_ismo_bay(oGet, 0, 41, 'namesmo')}
					
		myread()
	// 	if lastkey() != K_ESC
		
	// 		::validNumberPolicyOMS(between(m1namesmo, 34001, 34007))
				
	// 		oPolicyOMS:PolicyType := m1vidpolis
	// 		oPolicyOMS:PolicySeries := series
	// 		oPolicyOMS:PolicyNumber := alltrim( charrem(' ', number))
	// 		oPolicyOMS:SMO := lstr(m1namesmo)
	// 		if m1namesmo == 34
	// 			if ! empty(m1ismo)
	// 				if ! empty(mismo)
	// 					oPolicyOMS:IsInogSMO := .t.
	// 					oPolicyOMS:NameInogSMO := mismo
	// 				endif
	// 			else
	// 				oPolicyOMS:SMO := m1ismo  // заменяем "34" на код иногородней СМО
	// 			endif
	// 		endif
	// 		exit
	// 	else
	// 		exit
	// 	endif
	// enddo
	// if ! isnil(mPolicyOMS) .and. ! empty(oPolicyOMS:PolicyNumber)
	// 	mPolicyOMS := padr(oPolicyOMS:AsString, 65)
	// endif
	update_gets()
	
	oBox := nil
	restscreen(buf)
	restore gets from tmp_gets
	my_restkey(tmp_keys)
	return nil

** 26.08.22
METHOD FUNCTION setPolicyOMS(oGet, vidpolis) CLASS TPolicyOMS

	if vidpolis != 1
		::FPolicySeries := space(10)
	endif
	return .t.

* 26.12.18 проверка номера полиса ОМС
function roCheckPolicyOMS( oGet, m1vidpolis, oPatient, oPolicyOMS )
	local ret := .t., mkod

	::FPolicyType := m1vidpolis
	::FPolicyNumber := alltrim(charrem(' ', oGet:Buffer))
	::validNumberPolicyOMS()

	if ( findKartoteka_bay( oPatient, 2, @mkod, oPolicyOMS ) )
		update_gets()
	endif
	return ret

* 26.12.18
METHOD FUNCTION validNumberPolicyOMS(is_volgograd) CLASS TPolicyOMS
	local a_err := {}
	local CountDigit := 0, s := ''

	if empty(::FPolicyType)
		aadd(a_err, 'не заполнено поле "Вид полиса"')
	endif
	if empty(::FPolicyNumber)
		aadd(a_err, 'не заполнен номер полиса')
	endif
	if ::FPolicyType == 1
		DEFAULT is_volgograd TO .f.
		if is_volgograd // ТОЛЬКО ДЛЯ ВОЛГОГРАДСКОЙ ОБЛАСТИ
			s := alltrim(::FPolicySeries) + alltrim(::FPolicyNumber)
			CountDigit := len(s)
			s := charrem(' ', CHARREPL('0123456789', s, space(10)))
			if !empty(s)
				aadd(a_err, 'недопустимые символы в (старом) Волгоградском полисе "' + s + '"')
			elseif CountDigit != 16
				aadd(a_err, 'в (старом) Волгоградском полисе должно быть 16 цифр')
			endif
		endif
	else
		if ! empty(::FPolicySeries)
			aadd(a_err, 'для данного вида СЕРИЯ ПОЛИСА не заполняется')
		endif
		::FPolicyNumber := alltrim(::FPolicyNumber)
		s := charrem(' ', CHARREPL('0123456789', ::FPolicyNumber, space(10)))
		CountDigit := len( alltrim(::FPolicyNumber))
		if !empty(s)
			aadd(a_err, '"' + s + '" недопустимые символы в НОМЕРЕ ПОЛИСА' )
		elseif ::FPolicyType == 2
			if CountDigit != 9
				aadd(a_err, ::FPolicyNumber + ' - в НОМЕРЕ временного ПОЛИСА должно быть 9 цифр')
			endif
		elseif ::FPolicyType == 3
			if CountDigit == 16
				if ! ::checksumPolisOMS(::FPolicyNumber)
					aadd(a_err, ::FPolicyNumber + ' - неверная контрольная сумма в ПОЛИСЕ единого образца')
				endif
			else
				aadd(a_err, ::FPolicyNumber + ' - в НОМЕРЕ ПОЛИСА должно быть 16 цифр')
			endif
		endif
	endif
	if !empty(a_err)
		n_message(a_err, , 'GR+/R', 'W+/R', , , 'G+/R')
	endif
	return .t.

** 26.08.22 проверить контрольную сумму в ПОЛИСЕ единого образца
METHOD FUNCTION checksumPolisOMS(cNumber) CLASS TPolicyOMS
	local i, n, s := ''
	// а) Выбираются цифры, стоящие в нечётных позициях, по порядку,
	//    начиная справа, записываются в виде числа.

	cNumber := alltrim(cNumber)
	for i := 15 to 1 step -2
		s += substr(cNumber, i, 1)
	next
	// Полученное число умножается на 2.
	n := int(val(s) * 2)
	// б) Выбираются цифры, стоящие в чётных позициях, по порядку,
	//    начиная справа, записываются в виде числа.
	s := ''
	for i := 14 to 1 step -2
		s += substr(cNumber, i, 1)
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
		i := 10 - n
	endif
	// В результате получается искомая контрольная цифра.
	return lstr(i) == right(cNumber, 1)

** 26.08.22
function func_valid_ismo_bay( oGet, lkomu, sh, name_var )
	local r1, r2, n := 4, buf, tmp_keys, tmp_list, tmp_color
	local oBox

	DEFAULT name_var TO 'company'
	private mvar := 'm1' + name_var
	if lkomu == 0 .and. &mvar == 34
		if oGet:row() > 18
			r2 := oGet:row() - 1
			r1 := r2 - n
		else
			r1 := oGet:row() + 1
			r2 := r1 + n
		endif
		tmp_keys := my_savekey()
		save gets to tmp_list
		private mm_ismo := {}
		
		oBox := TBox():New(r1, 2, r2, 77, .t.)
		oBox:Caption := 'Ввод иногородней СМО'
		oBox:CaptionColor := 'GR/W'
		oBox:Color := 'N/W,W+/N,,,B/W'
		oBox:View()
		
		@ r1 + 1, 4 say 'Субъект РФ' get mokato ;
					reader {| x | menu_reader(x, ;
					{{| k, r, c | get_srf(k, r, c)}, 62}, A__FUNCTION, , , .f.)} ;
					valid {| g, o | when_ismo(g, o)}
		@ r1 + 2, 4 say 'СМО' get mismo ;
					reader {| x | menu_reader(x, mm_ismo, A__MENUVERT, , , .f.)} ;
					when {| | len(mm_ismo) > 0 .and. empty(mnameismo)} ;
					valid {| | iif(empty(mismo), , mnameismo := space(100)), .t.}
		@ r1 + 3, 4 say 'Наименование СМО' get mnameismo pict '@S56' ;
					when empty(m1ismo)
		myread()
		restore gets from tmp_list
		my_restkey( tmp_keys )
		if ! emptyall(mismo, mnameismo)
			mvar := 'm' + name_var
			&mvar := padr(iif(emptyall(mismo), mnameismo, mismo), sh)
		endif
	endif
	return .t.

