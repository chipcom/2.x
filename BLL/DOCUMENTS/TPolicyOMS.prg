#include 'hbclass.ch'
#include 'property.ch'
#include 'common.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// класс описывающий полис ОМС
CREATE CLASS TPolicyOMS
  VISIBLE:
    PROPERTY AsString READ GetAsString(...)       // представление документа по установленной форматной строке
    PROPERTY Format READ FFormat WRITE SetFormat  // форматная строка вывода представления документа

    CLASSDATA	aMenuType	AS ARRAY	INIT {{'старый', 1}, ;
      {'врем. ', 2}, ;
      {'новый ', 3} }

    METHOD New( nType, cSeries, cNumber, cSMO, dBeginPolicy, dPolicyPeriod )
  HIDDEN:
    // формат по умолчанию : TYPE - тип полиса, SSS - серия, NNN - номер, ISSUE - издатель, DATE - дата выдачи
    DATA FFormat        INIT 'TYPE #SSS #NNN'
    DATA FPolicyType    INIT 1
    DATA FPolicySeries  INIT space(10)
    DATA FPolicyNumber	INIT space(20)
    DATA FSMO           INIT space(5)
    DATA FBeginPolicy   INIT ctod('')
    DATA FPolicyPeriod  INIT ctod('')
    DATA FOKATOInogSMO  INIT space(5)
    DATA FNameInogSMO   INIT space(100)
    DATA FIsInogSMO     INIT .f.
    DATA FOwner         INIT nil

		METHOD SetFormat(format)    INLINE ::FFormat := format
    METHOD GetAsString(format)
ENDCLASS

METHOD New(nType, cSeries, cNumber, cSMO, dBeginPolicy, dPolicyPeriod) CLASS TPolicyOMS

  ::FPolicyType := hb_defaultvalue(nType, 1)
  ::FPolicySeries := left(hb_defaultvalue(cSeries, space( 10 ) ), 10)
  ::FPolicyNumber := left(hb_defaultvalue(cNumber, space( 20 ) ), 20)
  ::FSMO := left(hb_defaultvalue(cSMO, space(5)), 5)
  ::FBeginPolicy := hb_defaultvalue(dBeginPolicy, ctod(''))
  ::FPolicyPeriod := hb_defaultvalue(dPolicyPeriod, ctod(''))
  return self
    
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
        && if ::FPolicyType == 3
          && s := transform( ::FPolicyNumber, picture_number )
        && else
          && s := ::FPolicyNumber
        && endif
        && s := '№ ' + alltrim( s )
        s := '№ ' + alltrim(if(::FPolicyType == 3, transform(::FPolicyNumber, picture_number ), ::FPolicyNumber))
      endif
    case itm == 'ISSUE'
      if alltrim(::FSMO) == '34' .and. len(alltrim(::FSMO)) == 2
        mnameismo := ret_inogSMO_name_bay(::FOwner, self)
      elseif left(::FSMO, 2) == '34'
        // Волгоград
      elseif ! empty(::FSMO)
        m1ismo := ::FSMO
        ::FSMO := '34'
      endif
      
      mismo := T_mo_smoDB():getBySMO(m1ismo)
    
      if empty(m1namesmo := int(val(::FSMO)))
        m1namesmo := smo_volgograd()[1, 2] // по умолчанию = КапиталЪ Медстрах
      endif
      mnamesmo := inieditspr(A__MENUVERT, smo_volgograd(), m1namesmo)
      if m1namesmo == 34
        if !empty(mismo)
          mnamesmo := mismo
        elseif !empty(mnameismo)
          mnamesmo := mnameismo
        endif
      endif
      s := alltrim(mnamesmo)
    case itm == 'DATE'
      s := dtoc(::FBeginPolicy)
    otherwise
      s := alltrim(tk)	// просто переносим текст
    endcase
    s += ch
    if s != nil
      asString += iif(i == 1, '', tkSep) + s
    endif
  next
  return asString