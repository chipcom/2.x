/* Download and upload a file from an FTP server */
#require 'hbtip'

#include 'inkey.ch'
#include 'fileio.ch'
#include 'function.ch'
#include 'versionFTP.ch'
#include 'tbox.ch'

// 19.06.25
function testSOAP()

//  local hArr, aRet
  local cUrl, HTTPQuery, result, status //, bodyJSON, nLengthDecoded
  local timeout := 5
  local cxml, ccityZIP

  cUrl := 'http://wsf.cdyne.com/WeatherWS/Weather.asmx'

  ccityZIP := "12345"

  cxml := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:weat="http://ws.cdyne.com/WeatherWS/">'+chr(13)+chr(10)
  cxml += "<soap:Header/>"+chr(13)+chr(10)
  cxml += "<soap:Body>"+chr(13)+chr(10)
  cxml += "<weat:GetCityForecastByZIP>"+chr(13)+chr(10)
  cxml += "<weat:ZIP>"+ccityZIP+"</weat:ZIP>"+chr(13)+chr(10)
  cxml += "</weat:GetCityForecastByZIP>"+chr(13)+chr(10)
  cxml += "</soap:Body>"+chr(13)+chr(10)
  cxml += "</soap:Envelope>"+chr(13)+chr(10)


  HTTPQuery := CreateObject( 'WinHttp.WinHttpRequest.5.1' )
  HTTPQuery:Option( 2, 'utf-8' )

  HTTPQuery:SetTimeouts( 15000, 15000, 15000, 15000 )
  HTTPQuery:Open( 'GET', cURL, 0 )
  HTTPQuery:SetRequestHeader( 'Accept-Charset', 'utf-8' )
  HTTPQuery:SetRequestHeader( 'Content-Type', 'application/soap+xml; charset=utf-8' )
  HTTPQuery:Send( cxml )
  result := HTTPQuery:WaitForResponse( timeout )

altd()
  if result
    status := HTTPQuery:status()
    // if status == 200
    //   bodyJSON := AllTrim( HTTPQuery:ResponseText() )
    //   nLengthDecoded := hb_jsonDecode( bodyJSON, @hArr )
    //   aRet := hArr[ 'list' ]
    // endif
  endif
  HTTPQuery := nil
  return nil

//
function checkVersionInternet( row, oldVersion )

  local fileVersion  := 'version.txt'
  local readMe := 'readme.rtf'
  local aVersion, arr := {}
  local oBox := nil, max := 0
  local nLeft, nRight, key, i
  local buf := save_maxrow()

  mywait('��������, ���� �஢�ઠ ������ ����� ���ᨨ �ணࠬ��...')

  fileFromFTP( fileVersion )
  rest_box(buf)

  if (aVersion := readVersion( fileVersion )) != nil
    if ControlVersion( aVersion, oldVersion )
      AAdd(arr, '����㯭� ����� ����� �ணࠬ��:')
      AAdd(arr, '⥪��� �����: ' + fs_version( oldVersion ) )
      AAdd(arr, '����� �����:   ' + fs_version( aVersion ) )

      max := maxLenStringInArray(arr)
      nLeft := 40 - (max / 2) - 2
      nRight := 40 + (max / 2) + 2
      oBox := TBox():New( row, nLeft, row + len(arr) + 3, nRight )
      oBox:Color := 'N/W' + ',' + 'N+/W'
      oBox:Frame := BORDER_DOUBLE
      oBox:MessageLine := '^<�� ������>^ - �த������ ࠡ���; ^F2^ - ����� � �ணࠬ�'
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
