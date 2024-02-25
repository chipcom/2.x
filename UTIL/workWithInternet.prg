/* Download and upload a file from an FTP server */
#require 'hbtip'

#include 'inkey.ch'
#include 'fileio.ch'
#include 'function.ch'
#include 'versionFTP.ch'
#include 'tbox.ch'

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
  
// 20.01.24
function fileToFTP( fileName, flError )
  local cServer   := CUSTOM_FTP
  local cUser     := UPLOAD_USER
  local cPassword := UPLOAD_PASS
  local cUrl      := 'ftp://' + cUser + ':' + cPassword + '@' + cServer
  local oFTP, oURL, ftpPathError := 'Error'

  local fl := .f.

  Default flError To .f.
  
  oURL := TUrl():New( cURL )
    
  oFTP := TIPClientFTP():New( oURL, .f. )
  oFTP:nConnTimeout := 20000
  oFTP:bUsePasv := .T.
    
  if oFTP:Open( cURL )
    if flError
      oFTP:CWD( ftpPathError )
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
