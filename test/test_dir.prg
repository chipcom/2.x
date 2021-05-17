#include "Directry.ch"
//
procedure main()
  local aDirectory, nPos, tsDateTime

  aDirectory := hb_vfDirectory( 'd:\_MO\chip\Work\*.ntx' )
  AEval( aDirectory, {|aFile| QOut(aFile[F_NAME] + ' : ' + dtoc(aFile[F_DATE]))} )

  ? len(aDirectory)

  ? AScan( aDirectory,,, ;
     {| aFile, nPos | HB_SYMBOL_UNUSED( nPos ), aFile[ F_NAME ] == "okato.ntx" } )

  ? nPos := AScan( aDirectory, ;
     {| aFile, nPos | HB_SYMBOL_UNUSED( nPos ), aFile[ F_NAME ] == "_okato.ntx" } )

  ? VALTYPE(aDirectory[nPos, F_NAME])
  ? VALTYPE(aDirectory[nPos, F_DATE])
  ? aDirectory[nPos, F_DATE]
  ? VALTYPE(aDirectory[nPos, F_TIME])

  HB_VFTIMEGET( 'd:\_MO\chip\Work\_okato.ntx', @tsDateTime )
  ?tsDateTime

return