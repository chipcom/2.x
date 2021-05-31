/* Download a file from an FTP server */
#require 'hbtip'

#include 'inkey.ch'
#include 'fileio.ch'
#include 'versionFTP.ch'
#include 'tbox.ch'

function checkVersionInternet( row, oldVersion )

  local fileVersion  := 'version.txt'
  local readMe := 'readme.rtf'
  local aVersion, arr := {}
  local oBox := nil, max := 0
  local nLeft, nRight, key

  fileFromFTP( fileVersion )

  if (aVersion := readVersion( fileVersion )) != nil
    if ControlVersion( aVersion, oldVersion )
      AAdd(arr, 'Доступна новая версия программы:')
      AAdd(arr, 'текущая версия: ' + fs_version( oldVersion ) )
      AAdd(arr, 'новая версия: ' + fs_version( aVersion ) )
      // n_message( arr, , 'W/W', 'N/W', row + 3, , 'N+/W' )

      max := maxLenStringInArray(arr)
      nLeft := 40 - (max / 2) - 2
      nRight := 40 + (max / 2) + 2
      oBox := TBox():New( row, nLeft, row + len(arr) + 3, nRight )
      oBox:Color := 'N/W' + ',' + 'N+/W'
      oBox:Frame := BORDER_DOUBLE
      oBox:MessageLine := '^<любая клавиша>^ - выход; ^F2^ - новое в програме'
      oBox:Save := .t.
  
      oBox:View()
      for i := 1 to len(arr)
        @ row + i + 1, nLeft + 2 say arr[i]
      next
      key := inkey(0)
      if key == K_F2
        fileFromFTP( readMe )
        file_Wordpad( readMe )
      endif
    endif
  endif
  FErase( fileVersion )

  return nil

function fileFromFTP( fileName )
  local cServer   := CUSTOM_FTP
  local cUser     := VERSION_US
  local cPassword := VERSION_PASS
  local cUrl      := 'ftp://' + cUser + ':' + cPassword + '@' + cServer
  local oFTP, oURL
  
  oURL := TUrl():New( cURL )
  
  oFTP := TIPClientFTP():New( oURL, .f. )
  oFTP:nConnTimeout := 20000
  oFTP:bUsePasv := .T.
  
  if oFTP:Open( cURL )
    if ! oFtp:DownloadFile( fileName )
      return nil
    endif
    oFTP:Close()
  endif
  return nil
  
  function fileToFTP( fileName )
    local cServer   := CUSTOM_FTP
    local cUser     := UPLOAD_USER
    local cPassword := UPLOAD_PASS
    local cUrl      := 'ftp://' + cUser + ':' + cPassword + '@' + cServer
    local oFTP, oURL
    
    oURL := TUrl():New( cURL )
    
    oFTP := TIPClientFTP():New( oURL, .f. )
    oFTP:nConnTimeout := 20000
    oFTP:bUsePasv := .T.
    
    if oFTP:Open( cURL )
      if ! oFtp:UploadFile( fileName )
        return .f.
      endif
      oFTP:Close()
    else
      return .f.
    endif
    return .t.
    
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
        return .t.
      endif
    endif
  endif
  return .f.
