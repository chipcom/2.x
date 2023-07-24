// Licence: GPL >= 2
// Author: Mark Clements, 2023-07-18
// Adapted from src/rdd/dbtotal.prg

// https://groups.google.com/g/harbour-users/c/SDAdDlhZ-Q4

#include "dbstruct.ch"
#include "error.ch"

// Use ft_AMedian() in an example of a user-defined aggregate
// For compilation, add: hbnf.hbc
#require "hbnf"

#command SUMMARIZE [<func1>(<field1>) [AS <name1>]][, <funcN>(<fieldN>) [AS <nameN>]] ;
               [TO <(f)>] [ON <key>] ;
               [FOR <for>] [WHILE <while>] [NEXT <next>] ;
               [RECORD <rec>] [<rest:REST>] [ALL] [VIA <rdd>] ;
               [CODEPAGE <cp>] => ;
__dbSummarize( <(f)>, <"key">, {<"field1">[, <"fieldN">]}, { <(name1)>[, <(nameN)>] }, ;
               { <(func1)>[, <(funcN)>] },,, ;
               <{for}>, <{while}>, <next>, <rec>, <.rest.>, <rdd>,, <cp> )

// Example: https://rosettacode.org/wiki/Merge_and_aggregate_datasets
// hbmk2 rosetta2 hbnf.hbc 
local pStruct, vStruct

   set date format "yyyy-mm-dd"

   REQUEST DBFNTX
   RDDSETDEFAULT('DBFNTX')
 
   ? "rosettacode example:"
   pStruct := {{"patient_id", "n", 8, 0}, {"lastname", "c", 10, 0 }}
   dbCreate( "patient", pStruct, "DBFNTX", .t., "patient" )
   (dbAppend(), patient->patient_id := 1001, patient->lastname := "Hopper")
   (dbAppend(), patient->patient_id := 2002, patient->lastname := "Wirth")
   (dbAppend(), patient->patient_id := 3003, patient->lastname := "Kemeny")
   (dbAppend(), patient->patient_id := 4004, patient->lastname := "Gosling")
   (dbAppend(), patient->patient_id := 5005, patient->lastname := "Kurtz")
   ? "patient table: "
   AEval(dbStruct(), {|item| QQout(item[1], " ")})
   LIST patient_id, lastname
   
   vStruct := {{"patient_id", "n", 8, 0}, {"visit_date", "d", 10, 0}, {"score", "n", 8, 1}}
   dbCreate( "visit", vStruct, "DBFNTX", .t., "visit" )
   (dbAppend(), visit->patient_id := 2002, visit->visit_date := ctod("2020-09-10"), visit->score := 6.8)
   (dbAppend(), visit->patient_id := 1001, visit->visit_date := ctod("2020-09-17"), visit->score := 5.5)
   (dbAppend(), visit->patient_id := 4004, visit->visit_date := ctod("2020-09-24"), visit->score := 8.4)
   (dbAppend(), visit->patient_id := 2002, visit->visit_date := ctod("2020-10-08"))
   (dbAppend(), visit->patient_id := 1001, visit->score := 6.6)
   (dbAppend(), visit->patient_id := 3003, visit->visit_date := ctod("2020-11-12"))
   (dbAppend(), visit->patient_id := 4004, visit->visit_date := ctod("2020-10-05"), visit->score := 7.0)
   (dbAppend(), visit->patient_id := 1001, visit->visit_date := ctod("2020-11-19"), visit->score := 5.3)
   ? "visit table: "
   AEval(dbStruct(), {|item| QQout(item[1], " ")})
   LIST patient_id, score, visit_date

   USE visit
   INDEX ON visit->patient_id TO visit_id
   SUMMARIZE COUNT(score) AS n, SUM(score) AS sum_score, AVG(score) AS avg_score, ;
      MAX(visit_date) AS max_date TO summ1 ON patient_id
   USE patient
   USE summ1
   JOIN WITH patient to summ2 FOR patient_id == patient->patient_id FIELDS patient_id, ;
      patient->lastname, n, sum_score, avg_score, max_date
   USE summ2
   ? "summ2 table: "
   AEval(dbStruct(), {|item| QQout(item[1], " ")})
   LIST patient_id, lastname, n, sum_score, avg_score, max_date

   ? "User-defined aggregate:"
   USE visit
   INDEX ON visit->patient_id TO visit_id
   __dbSummarize("summ3", "patient_id", {"score"}, {"median"}, {{|x,agg| AAdd(agg,x), agg}}, {{}}, ;
      {{|x| ft_AMedian(x)}})
   USE summ3
   ? "summ3 table: "
   AEval(dbStruct(), {|item| QQout(item[1], " ")})
   LIST patient_id, median
   
FUNCTION __dbSummarize( cFile, xKey, aFields, aNames, xUpdate, ;
	 aInit, xFinalize, ;
	 xFor, xWhile, nNext, nRec, lRest, ;
	 cRDD, nConnection, cCodePage )

LOCAL nOldArea
LOCAL nNewArea

LOCAL aOldDbStruct
LOCAL aNewDbStruct
LOCAL aGetField
LOCAL aPutField
LOCAL aFieldsAgg
LOCAL lDbTransRecord
LOCAL xCurKey

LOCAL bWhileBlock
LOCAL bForBlock
LOCAL bKeyBlock

LOCAL oError
LOCAL lError := .F.

   IF EMPTY( aNames )
      aNames := AClone( aFields )
   ENDIF	 
   IF aHasDups(aNames)
      RETURN .F.
   ENDIF
   IF EMPTY( xUpdate )
      xUpdate := Array(Len(aFields))
      AFill(xUpdate, {|x,agg| x+agg})
   ENDIF	 
   IF EMPTY( xFinalize )
      xFinalize := Array(Len(aFields))
      AFill(xFinalize, {|x| x})
   ENDIF	 
   IF EMPTY( aInit )
      aInit := Array(Len(aFields))
      AFill(aInit, 0)
   ENDIF	 
      
   DO CASE
   CASE HB_ISEVALITEM( xWhile )
      bWhileBlock := xWhile
      lRest := .T.
   CASE HB_ISSTRING( xWhile ) .AND. ! Empty( xWhile )
      bWhileBlock := hb_macroBlock( xWhile )
      lRest := .T.
   OTHERWISE
      bWhileBlock := {|| .T. }
   ENDCASE

   DO CASE
   CASE HB_ISEVALITEM( xFor )
      bForBlock := xFor
   CASE HB_ISSTRING( xFor ) .AND. ! Empty( xFor )
      bForBlock := hb_macroBlock( xFor )
   OTHERWISE
      bForBlock := {|| .T. }
   ENDCASE

   __defaultNIL( @lRest, .F. )

   IF nRec != NIL
      dbGoto( nRec )
      nNext := 1
   ELSEIF nNext == NIL
      nNext := -1
      IF ! lRest
         dbGoTop()
      ENDIF
   ELSE
      lRest := .T.
   ENDIF

   nOldArea := Select()
   
   hOldDbStruct := hb_Hash()
   AEval(dbStruct(), {|aField| iif(aField[DBS_TYPE] == "M", NIL, ;
      hb_HSet(hOldDbStruct, aField[DBS_NAME], aField))})
   
   aNewDbStruct := {}
   IF ! Empty( xKey )
      AAdd(aNewDbStruct, hb_HGet(hOldDbStruct, upper(xKey)))
   ENDIF
   AEval(aNames, {|cName, i| aNames[i] := iif(empty(aNames[i]) .and. HB_ISSTRING(xUpdate[i]), ;
      aFields[i], aNames[i])})
   AEval(aFields, {| cField, i | aField := hb_HGet(hOldDbStruct, upper(cField)), ;
      AAdd(aNewDbStruct, {aNames[i], AField[2], aField[3], aField[4]})}) 
   IF Empty( aNewDbStruct )
	 RETURN .F.
   ENDIF

   FOR i := 1 TO Len(xUpdate)
      IF HB_ISSTRING(xUpdate[i])
	 DO CASE
	    CASE upper(xUpdate[i]) == "MAX"
	       xUpdate[i] := {|x,agg| max(x,agg)}
	       xFinalize[i] := {|x| x}
	       aInit[i] := iif(hb_HGet(hOldDbStruct,upper(aFields[i]))[DBS_TYPE]=="D", ;
	       ctod("19000101"),-9999999999999999999999999999999999999999999999999)
	    CASE upper(xUpdate[i]) == "MIN"
	       xUpdate[i] := {|x,agg| min(x,agg)}
	       xFinalize[i] := {|x| x}
	       aInit[i] := iif(hb_HGet(hOldDbStruct,upper(aFields[i]))[DBS_TYPE]=="D", ;
	       ctod("99991231"), 9999999999999999999999999999999999999999999999999)
	    CASE upper(xUpdate[i]) == "SUM"
	       xUpdate[i] := {|x,agg| x+agg}
	       xFinalize[i] := {|x| x}
	       aInit[i] := 0
	    CASE upper(xUpdate[i]) == "COUNT"
	       // aNewDbStruct[iif(empty(xKey),i,i+1)][2] := "I"
	       xUpdate[i] := {|x,agg| agg+1}
	       xFinalize[i] := {|x| x}
	       aInit[i] := 0
	    CASE upper(xUpdate[i]) == "AVG"
	       xUpdate[i] := {|x,agg| {1+agg[1], x+agg[2]}}
	       xFinalize[i] := {|x| x[2]/x[1]}
	       aInit[i] := {0,0}
	 ENDCASE
      ENDIF
   NEXT
   
   BEGIN SEQUENCE

      IF HB_ISSTRING( xKey ) .AND. ! Empty( xKey )
	 bKeyBlock := hb_macroBlock( xKey )
      ELSE
	 bKeyBlock := {|| NIL }
      ENDIF

      aGetField := {}
      AEval( aFields, {| cField | AAdd( aGetField, __GetField( cField ) ) } )

      /* Keep it open after creating it. */
      dbCreate( cFile, aNewDbStruct, cRDD, .T., "", , cCodePage, nConnection )
      nNewArea := Select()
      aNewField := {}
      AEval( aNames, {| cField | AAdd( aNewField, __GetField( cField ) ) } )

      dbSelectArea( nOldArea )
      DO WHILE ! Eof() .AND. nNext != 0 .AND. Eval( bWhileBlock )

         lDbTransRecord := .F.

         aFieldsAgg := AClone(aInit)

         xCurKey := Eval( bKeyBlock )

         DO WHILE ! Eof() .AND. nNext-- != 0 .AND. Eval( bWhileBlock ) .AND. ;
               xCurKey == Eval( bKeyBlock )

            IF Eval( bForBlock )
               IF ! lDbTransRecord
                  __dbTransRec( nNewArea, aNewDbStruct )
                  dbSelectArea( nOldArea )
                  lDbTransRecord := .T.
               ENDIF
               AEval( aGetField, {| bFieldBlock, nFieldPos | ;
	          aFieldsAgg[ nFieldPos ] := Eval(xUpdate[nFieldPos], Eval( bFieldBlock ), aFieldsAgg[ nFieldPos ]) } )
            ENDIF

            dbSkip()
         ENDDO

         IF lDbTransRecord
            dbSelectArea( nNewArea )
            AEval( aNewField, {| bFieldBlock, nFieldPos | ;
	       Eval( bFieldBlock, Eval(xFinalize[nFieldPos], aFieldsAgg[ nFieldPos ]) ) } )
            dbSelectArea( nOldArea )
         ENDIF

      ENDDO

   RECOVER USING oError
      lError := .T.
   END SEQUENCE

   IF nNewArea != NIL
      dbSelectArea( nNewArea )
      dbCloseArea()
   ENDIF

   dbSelectArea( nOldArea )

   IF lError
      Break( oError )
   ENDIF

   RETURN .T.

STATIC FUNCTION __GetField( cField )

LOCAL nCurrArea := Select()
LOCAL nPos
LOCAL oError

   /* Is the field aliased? */
   IF ( nPos := At( "->", cField ) ) > 0

      IF Select( Left( cField, nPos - 1 ) ) != nCurrArea

         oError := ErrorNew()
         oError:severity   := ES_ERROR
         oError:genCode    := EG_SYNTAX
         oError:subSystem  := "DBCMD"
         oError:canDefault := .T.
         oError:operation  := cField
         oError:subCode    := 1101

         IF hb_defaultValue( Eval( ErrorBlock(), oError ), .T. )
            __errInHandler()
         ENDIF

         Break( oError )
      ENDIF

      cField := SubStr( cField, nPos + 2 )
   ENDIF

   RETURN FieldBlock( cField )

FUNCTION __dbTransRec( nDstArea, aFieldsStru )
   RETURN __dbTrans( nDstArea, aFieldsStru, , , 1 )

FUNCTION AHasDups(anArray)
LOCAL x, i, j
   IF Len(anArray)==1
      RETURN .F.
   ENDIF
   FOR i := 1 to Len(anArray)-1
      x := anArray[i]
      FOR j := i+1 to Len(anArray)
	 IF x==anArray[j]
	    RETURN .T.
	 ENDIF
      NEXT
   NEXT
   RETURN .F.
   // Tests
   // ? AHasDups({1})
   // ? AHasDups({1,2})
   // ? AHasDups({2,1,1})
   // ? AHasDups({1,1,2})
   // ? AHasDups({1,2,1})
   
