#include "inkey.ch"

PROC Main()
  
   LOCAL i, tba
   
   LOCAL aDir:= Directory( "*.*" )
   
   PRIVATE nCurRow := 1,;            // Like RECN() in .dbf source 
           nMaxRow := LEN( aDir )    // Like RECC() in .dbf source  
      
   // Create TBrowse configured for an array
   
   tba := TBrowseArray( 10, 19, 15, 32, aDir )


   c := TBColumnNew( "File Name", { || aDir[ nCurRow, 1 ] } )
   
   c:width := 12 // Force width to 12
   
   tba:addColumn( c )
   
   @ 09,18 CLEAR TO 16,33
   @ 09,18 TO 16,33 DOUBLE


   TBKeyProcess( tba )
  
RETURN // TBrArray.Main()  

// Process user keystrokes
FUNCTION TBKeyProcess( b )


   LOCAL nKey
   
   WHILE .T.
   
      b:ForceStable()
   
      nKey:= InKey( 0 )
   
      DO CASE
         CASE nKey == K_UP;   b:up()
         CASE nKey == K_DOWN; b:down()
         CASE nKey == K_PGUP; b:pageUp()
         CASE nKey == K_PGDN; b:pageDown()
         CASE nKey == K_ESC;  EXIT
      ENDCASE
      
   END
   
RETURN nKey  
  
FUNCTION TBrowseArray( ; // Create a generic TBrowse
                       nTr,; // Top Row
                       nLc,; // Left Column
                       nBr,; // Bottom Row
                       nRc,; // Right Column
                       aArray ) // Array to browse
                       
   LOCAL tb := TBrowseNew( nTr, nLc, nBr, nRc ) // Return Value : Builded TBrowse Object
  
   tb:HeadSep := "---"      // Header Seperator
  
   tb:goTopBlock:= { || TBrArGoTop( tb ) }
   
   // Bottom of array: Element == array length
   tb:goBottomBlock:= { || TBrArGoBottom( tb ) } 
   
   // Movement in array: based on amount to move and current element
   tb:skipBlock:= { | nMove | SkipElement( nMove, aArray ) } 
   
RETURN tb // Return, ready to browse array

// Static function only visible in same
// source file as TBrowseArray()
STATIC FUNCTION SkipElement( nMove, aArray ) // , bIndex )


   IF nMove > 0 // Move down requested amount or
      // as much as possible
      IF (  nCurRow + nMove ) > nMaxRow
                        nMove := nMaxRow - nCurRow // nDSASize - nDSCRowNo
                ENDIF
        ELSE
                IF ( nMove + nCurRow  ) < 1
                        nMove := 1 - nCurRow
                ENDIF
        ENDIF
   
   // Set current element to new position
   nCurRow := nCurRow + nMove // Eval( bIndex, Eval( bIndex ) + nMove )
   
RETURN nMove // Return amount moved

PROC TBrArGoTop( oBrowse )


   LOCAL nSkipUp
   
   FOR nSkipUp := nCurRow TO 1 STEP -1
      oBrowse:Up()
   NEXT 
   
   nCurRow := 1
   
RETU // TBrArGoTop()

PROC TBrArGoBottom( oBrowse ) 


   LOCAL nSkipDown


   FOR nSkipDown := nCurRow TO nMaxRow
      oBrowse:Down()            
   NEXT
   
   nCurRow := nMaxRow


RETURN // TBrArGoBottom()
