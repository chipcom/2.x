/* Upload a file or files to FTP server */

#require "hbtip"

#include "fileio.ch"

PROCEDURE Main()

  local lRetVal := .T.

	local cServer   := 'ftp.chipplus.nichost.ru'
	local cUser     := 'chipplus_mo' 
	local cPassword := 'p-qpkGfzOV'
	local cURL      := 'ftp://' + cUser + ':' + cPassword + '@' + cServer
  local fileName  := 'version.txt'

  LOCAL oFTP, oURL

  /* fetch files to transfer */
  oURL := TUrl():New( cURL )

  oFTP := TIPClientFTP():New( oURL, .T. )
  oFTP:nConnTimeout := 20000
  oFTP:bUsePasv := .T.

  IF oFTP:Open( cURL )
    if crFile( fileName )
      IF ! oFtp:UploadFile( fileName )
        lRetVal := .F.
      ENDIF
    endif
    oFTP:Close()
  ELSE
    ? "Could not connect to FTP server", oURL:cServer
    IF oFTP:SocketCon == NIL
      ? "Connection not initialized"
    ELSEIF hb_inetErrorCode( oFTP:SocketCon ) == 0
      ? "Server response:", oFTP:cReply
    ELSE
      ? "Error in connection:", hb_inetErrorDesc( oFTP:SocketCon )
    ENDIF
    lRetVal := .F.
  ENDIF

  ErrorLevel( iif( lRetVal, 0, 1 ) )

  RETURN

function crFile( cFile )
  local nHandle

  IF ( nHandle := FCreate( cFile, FC_NORMAL ) ) == F_ERROR
    return .f.
  ENDIF  

  FWrite( nHandle, '2.11.20d' )
  FClose( nHandle )  

  return .t.