/* Download a file from an FTP server */
#require 'hbtip'

#include 'fileio.ch'
#include 'versionFTP.ch'

function checkVersionInternet( row, oldVersion )

	local cServer   := 'ftp.chipplus.nichost.ru'
	local cUser     := VERSION_US
	local cPassword := VERSION_PASS
	local cUrl      := 'ftp://' + cUser + ':' + cPassword + '@' + cServer
  local fileVersion  := 'version.txt'

  local oFTP, oURL
  local aVersion, arr := {}

  oURL := TUrl():New( cURL )

  oFTP := TIPClientFTP():New( oURL, .f. )
  oFTP:nConnTimeout := 20000
  oFTP:bUsePasv := .T.

  if oFTP:Open( cURL )
    if ! oFtp:DownloadFile( fileVersion )
      return nil
    endif
      oFTP:Close()
  else
    return nil
  endif

  if (aVersion := readVersion( fileVersion )) != nil
    if ControlVersion( aVersion, oldVersion )
      AAdd(arr, 'Доступна новая версия программы:')
      AAdd(arr, 'текущая версия: ' + fs_version( oldVersion ) )// + charVersion)
      AAdd(arr, 'новая версия: ' + fs_version( aVersion ) )// + aVersion[4])
      n_message( arr, , 'W/W', 'N/W', row + 3, , 'N+/W' )
    endif
  endif
  FErase( fileVersion )

  return nil

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


***** контроль версии базы данных
Function ControlVersion(aVersion, oldVersion)
  // aVersion - проверяемая версия
  local nfile := "ver_base"
  local ver__base
  local snversion := int(aVersion[1]*10000 + aVersion[2]*100 + aVersion[3])

  if hb_FileExists(dir_server+nfile+sdbf)
    R_Use(dir_server+nfile)
    ver__base := FIELD->version
    Use
    if snversion > ver__base
      return .t.
    elseif snversion == ver__base
      if asc(substr( oldVersion[4], 1, 1) ) < asc( aVersion[4] )
        // if asc(substr( charVersion, 1, 1) ) < asc( aVersion[4] )
        return .t.
      endif
    endif
  endif
  return .f.
  