/* Download a file from an FTP server */
#require "hbtip"

#include "fileio.ch"

function Main()  // cURL, ... )

  local lRetVal := .T.

	local cServer   := 'ftp.chipplus.nichost.ru'
	local cUser     := 'chipplus_mo' 
	local cPassword := 'p-qpkGfzOV'
	local cUrl      := 'ftp://' + cUser + ':' + cPassword + '@' + cServer
  local fileName  := 'version.txt'

  local oFTP, oURL
  local aVersion

  /* fetch files to transfer */
  oURL := TUrl():New( cURL )

  oFTP := TIPClientFTP():New( oURL, .f. )
  oFTP:nConnTimeout := 20000
  oFTP:bUsePasv := .T.

  if oFTP:Open( cURL )
    if ! oFtp:DownloadFile( fileName )
      lRetVal := .F.
    endif
      oFTP:Close()
  else
    ? "Could not connect to FTP server", oURL:cServer
    if oFTP:SocketCon == nil
      ? "Connection not initialized"
    elseif hb_inetErrorCode( oFTP:SocketCon ) == 0
      ? "Server response:", oFTP:cReply
    else
      ? "Error in connection:", hb_inetErrorDesc( oFTP:SocketCon )
    endif
    lRetVal := .F.
  endif

  if lRetVal
    if (aVersion := readVersion()) != nil
      ? hb_ValToExp( aVersion )
    endif
    if FErase( fileName ) != F_ERROR
      ? "File successfully erased"
    else
      ? "File cannot be deleted"
    endif    
  endif
  //  ErrorLevel( iif( lRetVal, 0, 1 ) )

  return lRetVal

function readVersion()
  local nHandle, i, j, tStr, cNum := '', cAlpha := ''
  local aStr, aVer := {}

  if ( nHandle := FOpen( 'version.txt', FO_READ ) ) == F_ERROR
    // ? "File cannot be opened"
    return nil
  endif
  aStr := hb_ATokens( FReadStr( nHandle, 100 ), '.' )
  // ? hb_ValToExp( aStr )
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
  // ? hb_ValToExp( aVer )
  // ? hb_ValToExp( cAlpha )

  FClose( nHandle )  
  return aVer
