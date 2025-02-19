#include "hbwin.ch"

procedure main()

  Request HB_CODEPAGE_RU866
  hb_cdpSelect( 'RU866' )
  Request HB_LANG_RU866
  hb_langSelect( 'RU866' )
  
  readcountry()  
  return

FUNCTION MSGINFO( cText, cTitle )
  RETURN WAPI_MESSAGEBOX( 0, cText, cTitle, WIN_MB_ICONQUESTION )

FUNCTION MSGSTOP( cText, cTitle )
  RETURN WAPI_MESSAGEBOX( 0, cText, cTitle, WIN_MB_ICONSTOP )
  
*--------------------*
function readcountry()
  *---------------------*
  doc =   CreateObject( "MSXML2.DOMDocument" )
  ohttp = CreateObject( "MSXML2.XMLHTTP" )
  If (Empty( ohttp))
     MsgStop( 'No se Pudo Crear el Objeto ohttp; se Cancela el Programa' )
     Return( .f. )
  Endif
  If (Empty( ohttp))
     MsgStop( 'No se Pudo Crear el Objeto ohttp; se Cancela el Programa' )
     Return( .f. )
  Endif
  oHttp:Open ("GET", "https://covid19.mathdro.id/api/countries", .f.)
  ohttp:Send()
  mstatus=ohttp:STATUS
  if ohttp:STATUS = 200 .or. mstatus=520
      response:=ohttp:responseText
     if mstatus=520
        msginfo(response)
        return
     endif
  else
     MsgStop( "Error: Status "+str(mstatus,10) )
  endif
  if (Empty( response ) )
     MsgStop( "Error:  Respuesta esta VACIA.  Status "+str(mstatus,10) )
     return
  End
  nLen:=0
  res:={}
  o=0
  msginfo(response)
  nLen := hb_jsondecode( response, @res )
  paises:=res["countries"]
  alert("Hay "+tran(len(paises),"999,999")+" paises")
  aCountry:={}
  FOR EACH o IN paises
      cname:=""
      ciso2:=""
      ciso3:=""
      if "name"$o
         cname :=o["name"]
      endif
      if "iso2"$o
          ciso2 :=o["iso2"]
      endif
      if "iso3"$o
          ciso3 :=o["iso3"]
      endif
      AADD(aCountry,{cname,ciso2,ciso3})
  NEXT
  *** REVISAR LOS PRIMEROS 10 valores del array
  CLEAR
  FOR i=1 to 10
      @i,0 say "name "+aCountry[i,1]+" iso2 "+aCountry[i,2]+" iso3 "+aCountry[i,3]
  NEXT
  ohttp  := NIL
  Release ohttp
  WAIT ""
  return