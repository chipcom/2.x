// https://groups.google.com/g/harbour-users/c/Jag2rPxWK_U/m/0pwkE4WNcYYJ


#include "inkey.ch"
// #include "function.ch"
// #include "edit_spr.ch"
// #include "chip_mo.ch"
// #include "f_fr.ch"

#require "hbwin"

procedure main()
  ? HB_PING( "88.87.94.143") 
  ? HB_PING() 
  wait 

return
  
function HB_PING( URL ) 
  local wRet := .T. 
  local hSocket 
   
   
  HB_InetInit() 
  if empty(URL) 
     URL := "www.google.com" 
  endif 
   
  hSocket := hb_inetCreate(2000) 
  hb_inetConnect( URL,80,hSocket )   
    if hb_inetErrorCode( hSocket )#0 
  wret:=.f. 
    endif 
  *? hb_inetErrorDesc( hSocket ) 
  HB_InetCleanup() 
   
  Return wRet  