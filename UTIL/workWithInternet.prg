/* Download and upload a file from an FTP server */
#require 'hbtip'

#include 'inkey.ch'
#include 'fileio.ch'
#include 'function.ch'
#include 'versionFTP.ch'
#include 'tbox.ch'

// 24.06.25
function parseAnswer()

  local xmlDOC
  local rootNode, childElement, currentNode
  local res, i, j, txt, name, xml, child1, txt1, name1, xml1


  xmlDOC := win_oleCreateObject( 'Microsoft.XMLDOM' ) // Поднимем КОМ
  xmlDOC:loadXML( ans_GetMedInsState() )
  rootNode := xmlDOC:DocumentElement()
  childElement := rootNode:childNodes:length()

  for i := 1 to childElement
    currentNode := rootNode:childNodes:item( i - 1 )
    name := currentNode:childNodes:item( 0 ):nodename
    xml := currentNode:childNodes:item( 0 ):xml
    txt := currentNode:childNodes:item( 0 ):text
    res := currentNode:hasChildNodes()
    for j := 1 to currentNode:childNodes:length()
      child1 := currentNode:childNodes:item( j - 1 )
      name1 := child1:childNodes:item( 0 ):nodename
      xml1 := child1:childNodes:item( 0 ):xml
      txt1 := child1:childNodes:item( 0 ):text
altd()
    next
  next
  return nil

// 24.06.25
function GetMedInsState()

  local cxml
  local fam, im, ot, doctype, docident, dob, birthPlace

  fam := 'Иванов'
  im := 'Иван'
  ot := 'Иванович'
  doctype := '14'
  docident := '18 04 574020'
  dob := '1999-11-28T00:00:00'
  birthPlace := 'гор. Волгоград'

  cxml := '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
	cxml += '<s:Body>'
	cxml += '<GetMedInsState xmlns="http://tempuri.org/">'
	cxml += '<p xmlns:a="http://schemas.datacontract.org/2004/07/InsuranceAffilation" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
	cxml += '<a:FullName>'
	cxml += '<a:FamilyName>' + fam + '</a:FamilyName>'
	cxml += '<a:FirstName>' + im + '</a:FirstName>'
	cxml += '<a:MiddleName>' + ot + '</a:MiddleName>'
	cxml += '</a:FullName>'
	cxml += '<a:Document>'
	cxml += '<a:DocType>' + doctype + '</a:DocType>'
	cxml += '<a:DocIdent>' + docident + '</a:DocIdent>'
	cxml += '</a:Document>'
	cxml += '<a:Birth>'
	cxml += '<a:BirthDate>' + dob + '</a:BirthDate>'
  cxml += '<a:BirthPlace>' + birthPlace + '</a:BirthPlace>'
	cxml += '</a:Birth>'
	cxml += '</p>'
	cxml += '</GetMedInsState>'
	cxml += '</s:Body>'
  cxml += '</s:Envelope>'

  return nil

// 24.06.25
function GetMedInsState2()

  local cxml
  local fam, im, ot, policytype, policynumber, insRegion, dob, birthPlace, insDate

  fam := 'Петров'
  im := 'Пётр'
  ot := 'Петрович'
  policytype := '3'
  policynumber := '0201005123'
  insRegion := '18000'
  dob := '1999-11-28T00:00:00'
  birthPlace := 'гор. Волгоград'
  insDate := '2025-05-16T00:00:00'

  cxml := '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
	cxml += '<s:Body>'
	cxml += '<GetMedInsState2 xmlns="http://tempuri.org/">'
	cxml += '<p xmlns:a="http://schemas.datacontract.org/2004/07/InsuranceAffilation" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
	cxml += '<a:FullName>'
	cxml += '<a:FamilyName>' + fam + '</a:FamilyName>'
	cxml += '<a:FirstName>' + im + '</a:FirstName>'
	cxml += '<a:MiddleName>' + ot + '</a:MiddleName>'
	cxml += '<a:PolicyType>' + policytype + '</a:PolicyType>'
	cxml += '<a:PolicyNumber>' + policynumber + '</a:PolicyNumber>'
	cxml += '<a:InsRegion>' + insRegion + '</a:InsRegion>'
	cxml += '</a:FullName>'
	cxml += '<a:Birth>'
	cxml += '<a:BirthDate>' + dob + '</a:BirthDate>'
	cxml += '<a:BirthPlace>' + birthPlace + '</a:BirthPlace>'
	cxml += '<a:InsDate>' + insDate + '</a:InsDate>'
	cxml += '</a:Birth>'
	cxml += '</p>'
	cxml += '</GetMedInsState2>'
	cxml += '</s:Body>'
  cxml += '</s:Envelope>'

  return nil

// 24.06.25
function GetMedInsState3()

  local cxml
  local insDate
  local numberENP

  numberENP := '3448040821000123'
  insDate := '2025-05-16T00:00:00'

  cxml := '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
	cxml += '<s:Body>'
	cxml += '<GetMedInsState3 xmlns="http://tempuri.org/">'
	cxml += '<p xmlns:a="http://schemas.datacontract.org/2004/07/InsuranceAffilation" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
	cxml += '<a:NumberENP>' + numberENP + '</a:NumberENP>'
	cxml += '<a:InsDate>' + insDate + '</a:InsDate>'
	cxml += '</p>'
	cxml += '</GetMedInsState3>'
	cxml += '</s:Body>'
  cxml += '</s:Envelope>'

  return nil

// 24.06.25
function testSOAP()

  // https://infostart.ru/1c/articles/249741/
  // https://www.dataaccess.com/products/dataflex/features/web-services/web-services-examples-1105
  local query, xmlHttp, answer, cUrl, xmlDOC
  local cxml, status, statusText, responseCode
  local rootNode, childElement, currentNode, i, txt, name, xml

  cUrl := 'https://webservices.daehosting.com//services/TemperatureConversions.wso'
  query := win_oleCreateObject( 'MSXML2.DOMDocument' )

  cxml := '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' + chr( 13 ) + chr( 10 )
  cxml += '<soap:Body>' + chr( 13 ) + chr( 10 )
  cxml += '<CelsiusToFahrenheit xmlns="http://webservices.daehosting.com/temperature">' + chr( 13 ) + chr( 10 )
  cxml += '<nCelsius>30</nCelsius>' + chr( 13 ) + chr( 10 )
  cxml += '</CelsiusToFahrenheit>' + chr( 13 ) + chr( 10 )
  cxml += '</soap:Body>' + chr( 13 ) + chr( 10 )
  cxml += '</soap:Envelope>' + chr( 13 ) + chr( 10 )

//  oSoapClient := win_oleCreateObject( 'MSSOAP.SoapClient30' )
  query:loadXML( cxml )

	xmlHttp := win_oleCreateObject( 'MSXML2.xmlHttp' )
	xmlHttp:OPEN ( 'POST', cUrl, 0 )
  xmlHttp:SetRequestHeader( 'Accept-Charset', 'utf-8' )
  xmlHttp:SetRequestHeader( 'Content-Type', 'application/soap+xml; charset=utf-8' )
  
	xmlHttp:SEND ( query )
//	answer := xmlHttp:responseXML()
	answer := xmlHttp:responseText()
  status := xmlHttp:Status()
  statusText := xmlHttp:StatusText()

  xmlDOC := win_oleCreateObject( 'Microsoft.XMLDOM' ) // Поднимем КОМ
  xmlDOC:loadXML( answer )
  rootNode := xmlDOC:DocumentElement()
  childElement := rootNode:childNodes:length()

  for i := 1 to childElement
    currentNode := rootNode:childNodes:item( i - 1 )
    name := currentNode:childNodes:item( 0 ):nodename
    xml := currentNode:childNodes:item( 0 ):xml
    txt := currentNode:childNodes:item( 0 ):text

altd()
  next
//  responseCode = xmlDOC:selectSingleNode('//CelsiusToFahrenheitResponse/CelsiusToFahrenheitResult') //Нашли представление узла по абсолютному пути
//  responseCode = xmlDOC:selectSingleNode('//soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"/soap:Body/CelsiusToFahrenheitResponse/CelsiusToFahrenheitResult')
//  responseCode := xmlDOC:getElementsByTagName( 'CelsiusToFahrenheitResult' )
//altd()

  return nil

//
function checkVersionInternet( row, oldVersion )

  local fileVersion  := 'version.txt'
  local readMe := 'readme.rtf'
  local aVersion, arr := {}
  local oBox := nil, max := 0
  local nLeft, nRight, key, i
  local buf := save_maxrow()

  mywait('Подождите, идет проверка наличия новой версии программы...')

  fileFromFTP( fileVersion )
  rest_box(buf)

  if (aVersion := readVersion( fileVersion )) != nil
    if ControlVersion( aVersion, oldVersion )
      AAdd(arr, 'Доступна новая версия программы:')
      AAdd(arr, 'текущая версия: ' + fs_version( oldVersion ) )
      AAdd(arr, 'новая версия:   ' + fs_version( aVersion ) )

      max := maxLenStringInArray(arr)
      nLeft := 40 - (max / 2) - 2
      nRight := 40 + (max / 2) + 2
      oBox := TBox():New( row, nLeft, row + len(arr) + 3, nRight )
      oBox:Color := 'N/W' + ',' + 'N+/W'
      oBox:Frame := BORDER_DOUBLE
      oBox:MessageLine := '^<любая клавиша>^ - продолжить работу; ^F2^ - новое в програме'
      oBox:Save := .t.
  
      oBox:View()
      for i := 1 to len(arr)
        @ row + i + 1, nLeft + 2 say arr[i]
      next
      key := inkey(0)
      if key == K_F2
        fileFromFTP( readMe )
        view_file_in_Viewer( readMe )
      endif
    endif
  endif
  FErase( fileVersion )
  return nil

//
function fileFromFTP( fileName )
  local cServer   := CUSTOM_FTP
  local cUser     := VERSION_US
  local cPassword := VERSION_PASS
  local cUrl      := 'ftp://' + cUser + ':' + cPassword + '@' + cServer
  local oFTP, oURL
  
  oURL := TUrl():New( cURL )
  
  oFTP := TIPClientFTP():New( oURL, .f. )
  oFTP:nConnTimeout := 2000
  oFTP:bUsePasv := .T.
  
  if oFTP:Open( cURL )
    if ! oFtp:DownloadFile( fileName )
      return nil
    endif
    oFTP:Close()
  endif
  return nil
  
// 25.03.24
function fileToFTP( fileName, strPath )
  local cServer   := CUSTOM_FTP
  local cUser     := UPLOAD_USER
  local cPassword := UPLOAD_PASS
  local cUrl      := 'ftp://' + cUser + ':' + cPassword + '@' + cServer
  local oFTP, oURL

  local fl := .f.

  Default strPath To ''
  
  oURL := TUrl():New( cURL )
    
  oFTP := TIPClientFTP():New( oURL, .f. )
  oFTP:nConnTimeout := 20000
  oFTP:bUsePasv := .T.
    
  if oFTP:Open( cURL )
    if ! empty( strPath )
      oFTP:CWD( alltrim( strPath ) )
      oFTP:DELE( hb_FNameNameExt( fileName ) )
    endif
    if oFtp:UploadFile( fileName )
      fl := .t.
    endif
    oFTP:Close()
  else
    fl := .f.
  endif
  return fl
    
//
function readVersion( fileVersion )
  local nHandle, i, j, tStr, cNum := '', cAlpha := ''
  local aStr, aVer := {}

  if ( nHandle := FOpen( fileVersion, FO_READ ) ) == F_ERROR
    return nil
  endif
  aStr := hb_ATokens( FReadStr( nHandle, 100 ), '.' )
  if len(aStr) == 3
    for i := 1 to 3
      if i < 3
        AAdd(aVer, val(aStr[i]))
      else
        tStr := aStr[i]
        for j := 1 to len(tStr)
          if IsDigit( SubStr(tStr, j, 1) )
            cNum += SubStr(tStr, j, 1)
          else
            cAlpha += SubStr(tStr, j, 1)
          endif
        next
        AAdd(aVer, val(cNum))
      endif
    next
  endif
  AAdd(aVer, cAlpha)
  FClose( nHandle )  
  return aVer
