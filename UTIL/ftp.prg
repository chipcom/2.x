#require 'hbtip'

#include 'fileio.ch'

PROCEDURE Main()
	DownloadFromFTP()
return

FUNCTION DownloadFromFTP()
	local cServer   := "ftp.chipplus.ru"
	local cUser     := 'chipplus_mo' 
	local cPassword := 'p-qpkGfzOV'
	// local nHandle := FCreate( hb_cwd() + 'temp.txt', FC_NORMAL )
	local cResult := ''
	local cUrl      := "ftp://" + cUser + ":" + cPassword + "@" + cServer
	local oUrl              := TUrl():New( cUrl )
	local oFTP              := TIPClientFTP():New( oUrl, .T. )

	oFTP:bUsePasv     := .T.
	oFTP:nConnTimeout := 20000

// pass p-qpkGfzOV
//Here is your problem:
	IF oFTP:Open( cUrl )
//When you pass cUrl to the Open() method, a new oUrl is created, but the
//oUrl object you talk to when you set oUrl:cFile a few lines later is the
//original one, which the oFtp object has already thrown out. Just remove
//cUrl from the Open() call and everything will be fine.

		// oFtp:Cwd( '/www/' )
		// oUrl:cFile := 'version.txt'
		oFtp:bEof := .F.
		oFtp:DownloadFile('version.txt') /* This works correctly */
		// cResult := oFtp:Read()
		// ?cResult
		// FWRITE (nHandle, cResult, len(cResult))
		// FCLOSE (nHandle)
		oFTP:Close()
	ENDIF
	RETURN cResult