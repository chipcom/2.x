/* Upload a file or files to FTP server */

#require "hbtip"

#include "fileio.ch"
#include '../../INCLUDE/versionFTP.ch'

PROCEDURE Main()

  local lRetVal := .T.

	local cServer   := VERSION_FTP
	local cUser     := VERSION_US
	local cPassword := VERSION_PASS
	local cURL      := 'ftp://' + cUser + ':' + cPassword + '@' + cServer
  local fileVersion  := 'version.txt'

  LOCAL oFTP, oURL

  /* fetch files to transfer */
  oURL := TUrl():New( cURL )

  oFTP := TIPClientFTP():New( oURL, .f. )
  oFTP:nConnTimeout := 20000
  oFTP:bUsePasv := .T.

  IF oFTP:Open( cURL )
    if crFile( fileVersion )
      IF ! oFtp:UploadFile( fileVersion )
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

  FErase( fileVersion )

  ErrorLevel( iif( lRetVal, 0, 1 ) )

  RETURN

function crFile( cFile )
  local nHandle

  IF ( nHandle := FCreate( cFile, FC_NORMAL ) ) == F_ERROR
    return .f.
  ENDIF  

  FWrite( nHandle, '2.11.20g' )
  FClose( nHandle )  

  return .t.