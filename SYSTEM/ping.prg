#include 'versionFTP.ch'

function hb_ping( URL ) 

  local wRet := .t.
  local hSocket
  local errString := ''
   
   
  HB_InetInit()
  if empty( URL )
     URL := CUSTOM_FTP
  endif

  hSocket := hb_inetCreate( 2000 )
  hb_inetConnect( URL, CONTROL_PORT, hSocket )
    if hb_inetErrorCode( hSocket ) # 0 
        wret:=.f. 
    endif 
  errString := hb_inetErrorDesc( hSocket ) 
  HB_InetCleanup() 
   
  Return wRet