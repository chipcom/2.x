#include 'function.ch'
#include 'chip_mo.ch'
#include 'fileio.ch'
#include 'common.ch'

function test_init()

//  local aaa
  
//  aaa := glob_array_srf( 'D:\_MO\chip\exe\', 'D:\_MO\chip\work\')
//  altd()
return nil
  
function GetVersions( code )

  local hArr, aRet
  local cUrl, HTTPQuery, result, status, bodyJSON, nLengthDecoded
  local timeout := 5

  cUrl := hb_StrFormat( 'http://nsi.ffoms.ru/nsi-int/api/versions?identifier=%s', code )

  HTTPQuery := CreateObject( 'WinHttp.WinHttpRequest.5.1' )
  HTTPQuery:Option( 2, 'utf-8' )

  HTTPQuery:SetTimeouts( 15000, 15000, 15000, 15000 )
  HTTPQuery:Open( 'GET', cURL, 0 )
  HTTPQuery:SetRequestHeader( 'Accept-Charset', 'utf-8' )
  HTTPQuery:SetRequestHeader( 'Content-Type', 'application/json; charset=utf-8' )
  HTTPQuery:Send()
  result := HTTPQuery:WaitForResponse( timeout )

  if result
    status := HTTPQuery:status()
    if status == 200
      bodyJSON := AllTrim( HTTPQuery:ResponseText() )
      nLengthDecoded := hb_jsonDecode( bodyJSON, @hArr )
      aRet := hArr[ 'list' ]
    endif
  endif
  HTTPQuery := nil
  return aRet

function GetStructure( code )

  local hArr
  local cUrl, HTTPQuery, result, status, bodyJSON, nLengthDecoded
  local timeout := 5

	cUrl := hb_StrFormat( 'http://nsi.ffoms.ru/nsi-int/api/structure?identifier=%s', code )

  HTTPQuery := CreateObject( 'WinHttp.WinHttpRequest.5.1' )
  HTTPQuery:Option( 2, 'utf-8' )

  HTTPQuery:SetTimeouts( 15000, 15000, 15000, 15000 )
  HTTPQuery:Open( 'GET', cURL, 0 )
  HTTPQuery:SetRequestHeader( 'Accept-Charset', 'utf-8' )
  HTTPQuery:SetRequestHeader( 'Content-Type', 'application/json; charset=utf-8' )
  HTTPQuery:Send()
  result := HTTPQuery:WaitForResponse( timeout )

  if result
		status := HTTPQuery:status()
    if status == 200
      bodyJSON := AllTrim( HTTPQuery:ResponseText() )
      nLengthDecoded := hb_jsonDecode( bodyJSON, @hArr )
//    aRet := aDict[ 'list' ]
    endif
  endif
  HTTPQuery := nil

  return hArr

//GetFile загружает zip-архив последней версии справочника в формате XML
function GetFile( hDict, destination )

  local lReturn := .f., s, id, version
  local cUrl, HTTPQuery, result, status, body
  local timeout := 5, headers
  local zipFile

  if isnil( destination ) .or. Empty( destination )
    destination := '.\'
  endif
  s := Split( hDict[ 'providerParam' ], 'v' )
  id := AllTrim( s[ 1 ] )
  version := AllTrim( s[ 2 ] )

//	cUrl := hb_StrFormat( 'http://nsi.ffoms.ru/refbook?type=XML&id=%s&version=%s', id, version)
	cUrl := 'http://nsi.ffoms.ru/refbook?type=XML&' + 'id=' + id + '&' + 'version=' + version

  HTTPQuery := CreateObject( 'WinHttp.WinHttpRequest.5.1' )
  HTTPQuery:Option( 2, 'utf-8' )

  HTTPQuery:SetTimeouts( 15000, 15000, 15000, 15000 )
  HTTPQuery:Open( 'GET', cURL, 0 )
  HTTPQuery:SetRequestHeader( 'Content-Type', 'application/zip' )
  HTTPQuery:Send()
  result := HTTPQuery:WaitForResponse( timeout )

  if result
    headers := HTTPQuery:getAllResponseHeaders()
		status := HTTPQuery:status()
    if status == 200
      body := HTTPQuery:ResponseBody()
      zipFile := destination + hDict[ 'd' ][ 'code' ] + '_' + hDict[ 'user_version' ] + '_XML.zip'
      hb_MemoWrit( zipFile, body )
        lReturn := .t.
    endif
  endif
  HTTPQuery := nil
  return lReturn

// FindDictionary получает последнюю версию справочника по его коду
function FindDictionary( code )

  local collection := GetDictionaryListFFOMS()
  local hValues, arr, v

  code := Upper( code )
	for each v in collection
    arr := hb_hValues( v )
    if arr[ 6 ][ 'code' ] == code
      hValues := v
    endif
  next
  return hValues

// GetDictionaryList получает список справочников с сайта ФФОМС
function GetDictionaryListFFOMS()

  local aDict, aRet
  local HTTPQuery, result, timeout := 5
  local status, statusText, bodyJSON, nLengthDecoded
  local cURL := 'http://nsi.ffoms.ru/data?pageId=refbookList&containerId=refbookList&size=110'

  HTTPQuery := CreateObject( 'WinHttp.WinHttpRequest.5.1' )
  HTTPQuery:Option( 2, 'utf-8' )

  HTTPQuery:SetTimeouts( 15000, 15000, 15000, 15000 )
  HTTPQuery:Open( 'GET', cURL, 0 )
  HTTPQuery:SetRequestHeader( 'Accept-Charset', 'utf-8' )
  HTTPQuery:SetRequestHeader( 'Content-Type', 'application/json; charset=utf-8' )
  HTTPQuery:Send()
  result := HTTPQuery:WaitForResponse( timeout )

  if result
		status := HTTPQuery:status()
    statusText := HTTPQuery:statusText()
    bodyJSON := AllTrim( HTTPQuery:ResponseText() )
    nLengthDecoded := hb_jsonDecode( bodyJSON, @aDict )
    aRet := aDict[ 'list' ]
  endif

  HTTPQuery := nil
  return aRet

// 12.07.24
function convert_P_CEL()

  static hPCEL

  if HB_ISNIL( hPCEL )
    hPCEL := hb_Hash( ;
      1 , '1.0', ;
      2 , '1.1', ;
      3 , '1.2', ;
      4 , '1.3', ;
      5 , '2.1', ;
      6 , '2.2', ;
      7 , '2.3', ;
      8 , '2.5', ;
      9 , '2.6', ;
      10 , '3.0', ;
      11 , '3.1', ;
      12 , '3.2', ;
      13 , '1.4', ;
      14 , '1.5', ;
      15 , '1.6', ;
      16 , '1.7', ;
      17 , '1.2' ;  // до 23 года
    )
  endif

  return hPCEL