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
    METHOD editPolicyOMS()
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

** 25.08.22 ввод данных полиса ОМС
METHOD FUNCTION editPolicyOMS() CLASS TPolicyOMS
	// local tmp_keys, tmp_gets, buf
	// local iRow
	// local oBox
	// local series := space(10)
	// local number := space(20)
	// local arrError, flagError := .f.
	// local sPicture
	// local sPictureSeries
	// local picture_number := "@R 9999 9999 9999 9999"
	
	// private ;
	// 	mvidpolis := '', ; // вид полиса
	// 	m1vidpolis := 1, ;	// по умолчанию старый полис
	// 	mnamesmo, m1namesmo, msmo := space(5), ;
	// 	mismo, m1ismo := '', mnameismo := space(100)

	// if empty(oPolicyOMS:PolicyNumber)
	// 	mvidpolis := inieditspr(A__MENUVERT, TPolicyOMS():aMenuType, m1vidpolis)		// вид полиса
	// else
	// 	m1vidpolis := oPolicyOMS:PolicyType
	// 	mvidpolis := inieditspr(A__MENUVERT, TPolicyOMS():aMenuType, m1vidpolis)		// вид полиса
	// 	series := oPolicyOMS:PolicySeries
	// 	&& if m1vidpolis == 3
	// 		&& number := transform(oPolicyOMS:PolicyNumber, picture_number)
	// 	&& else
	// 		number := oPolicyOMS:PolicyNumber
	// 	&& endif

	// 	msmo        := oPolicyOMS:SMO    // реестровый номер СМО
	// 	if alltrim(msmo) == '34'
	// 		mnameismo := ret_inogSMO_name_bay(oPatient, oPolicyOMS)
	// 	elseif left(msmo, 2) == '34'
	// 		// Волгоградская область
	// 	elseif !empty(msmo)
	// 		m1ismo := msmo
	// 		msmo := '34'
	// 	endif
		
    // mismo     := init_ismo(m1ismo)

	// 	if empty( m1namesmo := int(val(msmo)))
	// 		m1namesmo := glob_arr_smo[1, 2] // по умолчанию = КапиталЪ Медстрах
	// 	endif
	// 	mnamesmo := inieditspr(A__MENUVERT, glob_arr_smo, m1namesmo)
	// 	if m1namesmo == 34
	// 		if !empty(mismo)
	// 			mnamesmo := padr(mismo, 41)
	// 		elseif !empty(mnameismo)
	// 			mnamesmo := padr(mnameismo, 41)
	// 		endif
	// 	endif

	// endif

	// buf := savescreen()
	// change_attr()
	// iRow := 10
	// tmp_keys := my_savekey()
	// save gets to tmp_gets
	
	// oBox := TBox():New( iRow, 10, iRow + 5, 70, .t. )
	// oBox:CaptionColor := 'B/B*'
	// oBox:Color := cDataCGet
	// oBox:MessageLine := '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода'
	// oBox:Caption := 'Редактирование данных полиса ОМС'
	// oBox:View()
	
	// sPicture :=  if(eq_any(m1vidpolis, 3), picture_number, if(eq_any(m1vidpolis, 3), ;
	// 			'@R 9999999999999999999', '@R 999999999'))
	// do while .t.
	// 	iRow := 10
	// 	@ ++iRow, 12 say 'Вид полиса:' get mvidpolis ;
	// 				reader {| x | menu_reader(x, TPolicyOMS():aMenuType, A__MENUVERT, , , .f.)} ;
	// 				valid {| oGet | ( ;
	// 				setPolicyOMS(oGet, oPolicyOMS, m1vidpolis), ;
	// 				sPicture :=  if(eq_any(m1vidpolis, 3), picture_number, if(eq_any(m1vidpolis, 3), ;
	// 						'@R 9999999999999999999', '@R 999999999')), ;
	// 				update_gets())}
	// 				&& sPicture :=  if(eq_any(m1vidpolis, 3), picture_number, '@S20'), ;
	// 				&& number := transform(oPolicyOMS:PolicyNumber, if(eq_any(m1vidpolis, 3), picture_number, '@S20')), ;

	// 	@ ++iRow, 12 say 'Серия:' get series when if(m1vidpolis != 1, .f., .t.)
	// 	@ iRow, col() + 1 say 'Номер:' get number ;
	// 				valid {| oGet | roCheckPolicyOMS(oGet, m1vidpolis, oPatient, oPolicyOMS)} ;
	// 				picture sPicture
	// 				&& picture if(eq_any(m1vidpolis, 3), picture_number, '@S20')
	
	// 	@ ++iRow, 12 say 'СМО' get mnamesmo ;
	// 				reader {| x | menu_reader(x, glob_arr_smo, A__MENUVERT, , , .f.)} ;
	// 				valid {| oGet | func_valid_ismo_bay(oGet, 0, 41, 'namesmo')}
					
	// 	myread()
	// 	if lastkey() != K_ESC
		
	// 		validNumberPolicyOMS(oPolicyOMS, between(m1namesmo, 34001, 34007))
				
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
	// update_gets()
	
	// oBox := nil
	// restscreen(buf)
	// restore gets from tmp_gets
	// my_restkey(tmp_keys)
	return nil
