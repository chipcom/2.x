#include 'function.ch'
#include 'chip_mo.ch'
#include 'fileio.ch'

function test_init()

  //  GetDictionaryListFFOMS()
  //  FindDictionary( 'F001' )
  //  GetFile( FindDictionary( 'F032' ) )
    return nil
  
//GetFile загружает указанную версию справочника в формате XML
//func (d *Dictionary) GetFile() ([]byte, error) {
function GetFile( hValues )

  local lReturn := .f., s, id, version
  local cUrl, HTTPQuery, result, status, statusText, body
  local timeout := 5, headers
  local hUnzip, zipFile, n, nErr, cFile

  s := Split( hValues[ 'providerParam' ], 'v' )
  id := AllTrim( s[ 1 ] )
  version := AllTrim( s[ 2 ] )

//	url := fmt.Sprintf("http://nsi.ffoms.ru/refbook?type=XML&id=%s&version=%s", id, version)
	cUrl := 'http://nsi.ffoms.ru/refbook?type=XML&' + 'id=' + id + '&' + 'version=' + version

  HTTPQuery := CreateObject( 'WinHttp.WinHttpRequest.5.1' )
  HTTPQuery:Option( 2, 'utf-8' )

  HTTPQuery:SetTimeouts( 15000, 15000, 15000, 15000 )
  HTTPQuery:Open( 'GET', cURL, 0 )
//  HTTPQuery:SetRequestHeader( 'Accept-Charset', 'utf-8' )
  HTTPQuery:SetRequestHeader( 'Content-Type', 'application/zip' )
  HTTPQuery:Send()
  result := HTTPQuery:WaitForResponse( timeout )

  if result
    headers := HTTPQuery:getAllResponseHeaders()
		status := HTTPQuery:status()
    statusText := HTTPQuery:statusText()
//    body := HTTPQuery:ResponseText()
    body := HTTPQuery:ResponseBody()
    zipFile := cur_dir() + hValues[ 'd' ][ 'code' ] + '_' + hValues[ 'user_version' ] + '_XML.zip'
    hb_MemoWrit( zipFile, body )
    If ! Empty( hUnzip := hb_unzipOpen( zipFile ) )
      hb_unzipGlobalInfo( hUnzip, @n, NIL )
      If n > 0
        nErr := hb_unzipFileFirst( hUnzip )
        hb_unzipFileInfo( hUnzip, @cFile )// , @dDate, @cTime,,,, @nSize, @nCompSize, @lCrypted, @cComment )
        hb_unzipExtractCurrentFile( hUnzip, cur_dir() + cFile )// , cPassword)
        lReturn := .t.
      endif
      hb_unzipClose( hUnzip )
    endif
  endif
  hb_vfErase( zipFile )

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