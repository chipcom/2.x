
PROCEDURE xhb_ErrorSys()

   ErrorBlock( {| oError | xhb_DefError( oError ) } )

   RETURN

//and you will get the following error.log file

STATIC FUNCTION LogError( oErr )

   LOCAL cScreen
   LOCAL cLogFile    := s_cErrorLog       // error log file name
   LOCAL lAppendLog  := s_lErrorLogAppend // .F. = create a new error log (default) .T. = append to a existing one.
   LOCAL nCols
   LOCAL nRows

   LOCAL nCount

   LOCAL nForLoop
   LOCAL cOutString

   LOCAL nHandle
   LOCAL nBytes

   LOCAL nHandle2   := F_ERROR
   LOCAL cLogFile2  := "_error.log"
   LOCAL cBuff      := ""
   LOCAL nRead

   nCols := MaxCol()
   IF nCols > 0
      nRows := MaxRow()
      cScreen := SaveScreen()
   ENDIF

   // Alert( "An error occured, Information will be ;written to error.log" )

   IF ! lAppendLog
      nHandle := FCreate( cLogFile, FC_NORMAL )
   ELSE
      IF ! hb_FileExists( cLogFile )
         nHandle := FCreate( cLogFile, FC_NORMAL )
      ELSE
         nHandle  := FCreate( cLogFile2, FC_NORMAL )
         nHandle2 := FOpen( cLogFile, FO_READ )
      ENDIF
   ENDIF


   IF nHandle < 3 .AND. !( Lower( cLogFile ) == "error.log" )
      // Force creating error.log in case supplied log file cannot
      // be created for any reason
      cLogFile := "error.log"
      nHandle := FCreate( cLogFile, FC_NORMAL )
   ENDIF

   IF nHandle < 3
   ELSE

      FWriteLine( nHandle, PadC( " xHarbour Error Log ", 79, "-" ) )
      FWriteLine( nHandle, "" )

      FWriteLine( nHandle, "Date...............: " + DToC( Date() )  )
      FWriteLine( nHandle, "Time...............: " + Time()          )

      FWriteLine( nHandle, "" )
      FWriteLine( nHandle, "Application name...: " + hb_CmdArgArgV() )
      FWriteLine( nHandle, "Workstation name...: " + NetName() )
      FWriteLine( nHandle, "Available memory...: " + strvalue( Memory( 0 ) )  )
      FWriteLine( nHandle, "Current disk.......: " + DiskName() )
      FWriteLine( nHandle, "Current directory..: " + CurDir() )
      FWriteLine( nHandle, "Free disk space....: " + strvalue( DiskSpace() ) )
      FWriteLine( nHandle, "" )
      FWriteLine( nHandle, "Operating system...: " + OS() )
      FWriteLine( nHandle, "xHarbour version...: " + Version() )
      FWriteLine( nHandle, "xHarbour built on..: " + hb_BuildDate() )
      FWriteLine( nHandle, "C/C++ compiler.....: " + hb_Compiler() )

      FWriteLine( nHandle, "Multi Threading....: " + iif( hb_mtvm(), "YES", "NO" ) )
      FWriteLine( nHandle, "VM Optimization....: " + strvalue( hb_VMMode() ) )

      IF hb_IsFunction( "Select" )
         FWriteLine( nHandle, "" )
         FWriteLine( nHandle, "Current Area ......:" + strvalue( Eval( hb_macroBlock( "Select()" ) ) ) )
      ENDIF

      FWriteLine( nHandle, "" )
      FWriteLine( nHandle, PadC( " Environmental Information ", 79, "-" ) )
      FWriteLine( nHandle, "" )

      FWriteLine( nHandle, "SET ALTERNATE......: " + strvalue( Set( _SET_ALTERNATE ), .T. ) )
      FWriteLine( nHandle, "SET ALTFILE........: " + strvalue( Set( _SET_ALTFILE ) ) )
      FWriteLine( nHandle, "SET AUTOPEN........: " + strvalue( Set( _SET_AUTOPEN ), .T. ) )
      FWriteLine( nHandle, "SET AUTORDER.......: " + strvalue( Set( _SET_AUTORDER ) ) )
      FWriteLine( nHandle, "SET AUTOSHARE......: " + strvalue( Set( _SET_AUTOSHARE ) ) )

#ifdef __XHARBOUR__
      FWriteLine( nHandle, "SET BACKGROUNDTASKS: " + strvalue( Set( _SET_BACKGROUNDTASKS ), .T. ) )
      FWriteLine( nHandle, "SET BACKGROUNDTICK.: " + strvalue( Set( _SET_BACKGROUNDTICK ), .T. ) )
#endif
      FWriteLine( nHandle, "SET BELL...........: " + strvalue( Set( _SET_BELL ), .T. ) )
      FWriteLine( nHandle, "SET BLINK..........: " + strvalue( SetBlink() ) )

      FWriteLine( nHandle, "SET CANCEL.........: " + strvalue( Set( _SET_CANCEL ), .T. ) )
      FWriteLine( nHandle, "SET CENTURY........: " + strvalue( __SetCentury(), .T. ) )
      FWriteLine( nHandle, "SET COLOR..........: " + strvalue( Set( _SET_COLOR ) ) )
      FWriteLine( nHandle, "SET CONFIRM........: " + strvalue( Set( _SET_CONFIRM ), .T. ) )
      FWriteLine( nHandle, "SET CONSOLE........: " + strvalue( Set( _SET_CONSOLE ), .T. ) )
      FWriteLine( nHandle, "SET COUNT..........: " + strvalue( Set( _SET_COUNT ) ) )
      FWriteLine( nHandle, "SET CURSOR.........: " + strvalue( Set( _SET_CURSOR ) ) )

      FWriteLine( nHandle, "SET DATE FORMAT....: " + strvalue( Set( _SET_DATEFORMAT ) ) )
      FWriteLine( nHandle, "SET DBFLOCKSCHEME..: " + strvalue( Set( _SET_DBFLOCKSCHEME ) ) )
      FWriteLine( nHandle, "SET DEBUG..........: " + strvalue( Set( _SET_DEBUG ), .T. ) )
      FWriteLine( nHandle, "SET DECIMALS.......: " + strvalue( Set( _SET_DECIMALS ) ) )
      FWriteLine( nHandle, "SET DEFAULT........: " + strvalue( Set( _SET_DEFAULT ) ) )
      FWriteLine( nHandle, "SET DEFEXTENSIONS..: " + strvalue( Set( _SET_DEFEXTENSIONS ), .T. ) )
      FWriteLine( nHandle, "SET DELETED........: " + strvalue( Set( _SET_DELETED ), .T. ) )
      FWriteLine( nHandle, "SET DELIMCHARS.....: " + strvalue( Set( _SET_DELIMCHARS ) ) )
      FWriteLine( nHandle, "SET DELIMETERS.....: " + strvalue( Set( _SET_DELIMITERS ), .T. ) )
      FWriteLine( nHandle, "SET DEVICE.........: " + strvalue( Set( _SET_DEVICE ) ) )
      FWriteLine( nHandle, "SET DIRCASE........: " + strvalue( Set( _SET_DIRCASE ) ) )
      FWriteLine( nHandle, "SET DIRSEPARATOR...: " + strvalue( Set( _SET_DIRSEPARATOR ) ) )

      FWriteLine( nHandle, "SET EOL............: " + strvalue( Asc( Set( _SET_EOL ) ) ) )
      FWriteLine( nHandle, "SET EPOCH..........: " + strvalue( Set( _SET_EPOCH ) ) )
      FWriteLine( nHandle, "SET ERRORLOG.......: " + strvalue( cLogFile ) + "," + strvalue( lAppendLog ) )
#ifdef __XHARBOUR__
      FWriteLine( nHandle, "SET ERRORLOOP......: " + strvalue( Set( _SET_ERRORLOOP ) ) )
#endif
      FWriteLine( nHandle, "SET ESCAPE.........: " + strvalue( Set( _SET_ESCAPE ), .T. ) )
      FWriteLine( nHandle, "SET EVENTMASK......: " + strvalue( Set( _SET_EVENTMASK ) ) )
      FWriteLine( nHandle, "SET EXACT..........: " + strvalue( Set( _SET_EXACT ), .T. ) )
      FWriteLine( nHandle, "SET EXCLUSIVE......: " + strvalue( Set( _SET_EXCLUSIVE ), .T. ) )
      FWriteLine( nHandle, "SET EXIT...........: " + strvalue( Set( _SET_EXIT ), .T. ) )
      FWriteLine( nHandle, "SET EXTRA..........: " + strvalue( Set( _SET_EXTRA ), .T. ) )
      FWriteLine( nHandle, "SET EXTRAFILE......: " + strvalue( Set( _SET_EXTRAFILE ) ) )

      FWriteLine( nHandle, "SET FILECASE.......: " + strvalue( Set( _SET_FILECASE ) ) )
      FWriteLine( nHandle, "SET FIXED..........: " + strvalue( Set( _SET_FIXED ), .T. ) )
      FWriteLine( nHandle, "SET FORCEOPT.......: " + strvalue( Set( _SET_FORCEOPT ), .T. ) )

      FWriteLine( nHandle, "SET HARDCOMMIT.....: " + strvalue( Set( _SET_HARDCOMMIT ), .T. ) )

      FWriteLine( nHandle, "SET IDLEREPEAT.....: " + strvalue( Set( _SET_IDLEREPEAT ), .T. ) )
      FWriteLine( nHandle, "SET INSERT.........: " + strvalue( Set( _SET_INSERT ), .T. ) )
      FWriteLine( nHandle, "SET INTENSITY......: " + strvalue( Set( _SET_INTENSITY ), .T. ) )

      FWriteLine( nHandle, "SET LANGUAGE.......: " + strvalue( Set( _SET_LANGUAGE ) ) )

      FWriteLine( nHandle, "SET MARGIN.........: " + strvalue( Set( _SET_MARGIN ) ) )
      FWriteLine( nHandle, "SET MBLOCKSIZE.....: " + strvalue( Set( _SET_MBLOCKSIZE ) ) )
      FWriteLine( nHandle, "SET MCENTER........: " + strvalue( Set( _SET_MCENTER ), .T. ) )
      FWriteLine( nHandle, "SET MESSAGE........: " + strvalue( Set( _SET_MESSAGE ) ) )
      FWriteLine( nHandle, "SET MFILEEXT.......: " + strvalue( Set( _SET_MFILEEXT ) ) )

      FWriteLine( nHandle, "SET OPTIMIZE.......: " + strvalue( Set( _SET_OPTIMIZE ), .T. ) )
#ifdef __XHARBOUR__
      FWriteLine( nHandle, "SET OUTPUTSAFETY...: " + strvalue( Set( _SET_OUTPUTSAFETY ), .T. ) )
#endif

      FWriteLine( nHandle, "SET PATH...........: " + strvalue( Set( _SET_PATH ) ) )
      FWriteLine( nHandle, "SET PRINTER........: " + strvalue( Set( _SET_PRINTER ), .T. ) )
#ifdef __XHARBOUR__
      FWriteLine( nHandle, "SET PRINTERJOB.....: " + strvalue( Set( _SET_PRINTERJOB ) ) )
#endif
      FWriteLine( nHandle, "SET PRINTFILE......: " + strvalue( Set( _SET_PRINTFILE ) ) )

      FWriteLine( nHandle, "SET SCOREBOARD.....: " + strvalue( Set( _SET_SCOREBOARD ), .T. ) )
      FWriteLine( nHandle, "SET SCROLLBREAK....: " + strvalue( Set( _SET_SCROLLBREAK ), .T. ) )
      FWriteLine( nHandle, "SET SOFTSEEK.......: " + strvalue( Set( _SET_SOFTSEEK ), .T. ) )
      FWriteLine( nHandle, "SET STRICTREAD.....: " + strvalue( Set( _SET_STRICTREAD ), .T. ) )

#ifdef __XHARBOUR__
      FWriteLine( nHandle, "SET TRACE..........: " + strvalue( Set( _SET_TRACE ), .T. ) )
      FWriteLine( nHandle, "SET TRACEFILE......: " + strvalue( Set( _SET_TRACEFILE ) ) )
      FWriteLine( nHandle, "SET TRACESTACK.....: " + strvalue( Set( _SET_TRACESTACK ) ) )
#endif
      FWriteLine( nHandle, "SET TRIMFILENAME...: " + strvalue( Set( _SET_TRIMFILENAME ) ) )

      FWriteLine( nHandle, "SET TYPEAHEAD......: " + strvalue( Set( _SET_TYPEAHEAD ) ) )

      FWriteLine( nHandle, "SET UNIQUE.........: " + strvalue( Set( _SET_UNIQUE ), .T. ) )

      FWriteLine( nHandle, "SET VIDEOMODE......: " + strvalue( Set( _SET_VIDEOMODE ) ) )

      FWriteLine( nHandle, "SET WRAP...........: " + strvalue( Set( _SET_WRAP ), .T. ) )


      FWriteLine( nHandle, "" )

      IF nCols > 0
         FWriteLine( nHandle, PadC( "Detailed Work Area Items", nCols, "-" ) )
      ELSE
         FWriteLine( nHandle, "Detailed Work Area Items " )
      ENDIF
      FWriteLine( nHandle, "" )

      hb_WAEval( {||
         IF hb_IsFunction( "Select" )
            FWriteLine( nHandle, "Work Area No ......: " + strvalue( Do( "Select" ) ) )
         ENDIF
         IF hb_IsFunction( "Alias" )
            FWriteLine( nHandle, "Alias .............: " + Do( "Alias" ) )
         ENDIF
         IF hb_IsFunction( "RecNo" )
            FWriteLine( nHandle, "Current Recno .....: " + strvalue( Do( "RecNo" ) ) )
         ENDIF
         IF hb_IsFunction( "dbFilter" )
            FWriteLine( nHandle, "Current Filter ....: " + Do( "dbFilter" ) )
         ENDIF
         IF hb_IsFunction( "dbRelation" )
            FWriteLine( nHandle, "Relation Exp. .....: " + Do( "dbRelation" ) )
         ENDIF
         IF hb_IsFunction( "IndexOrd" )
            FWriteLine( nHandle, "Index Order .......: " + strvalue( Do( "IndexOrd" ) ) )
         ENDIF
         IF hb_IsFunction( "IndexKey" )
            FWriteLine( nHandle, "Active Key ........: " + strvalue( Eval( hb_macroBlock( "IndexKey( 0 )" ) ) ) )
         ENDIF
         FWriteLine( nHandle, "" )
         RETURN .T.
         } )

      FWriteLine( nHandle, "" )
      IF nCols > 0
         FWriteLine( nHandle, PadC( " Internal Error Handling Information  ", nCols, "-" ) )
      ELSE
         FWriteLine( nHandle, " Internal Error Handling Information  " )
      ENDIF
      FWriteLine( nHandle, "" )
      FWriteLine( nHandle, "Subsystem Call ....: " + oErr:subsystem() )
      FWriteLine( nHandle, "System Code .......: " + strvalue( oErr:suBcode() ) )
      FWriteLine( nHandle, "Default Status ....: " + strvalue( oErr:candefault() ) )
      FWriteLine( nHandle, "Description .......: " + oErr:description() )
      FWriteLine( nHandle, "Operation .........: " + oErr:operation() )
      FWriteLine( nHandle, "Arguments .........: " + Arguments( oErr ) )
      FWriteLine( nHandle, "Involved File .....: " + oErr:filename() )
      FWriteLine( nHandle, "Dos Error Code ....: " + strvalue( oErr:oscode() ) )

#ifdef __XHARBOUR__
#ifdef HB_THREAD_SUPPORT
      FWriteLine( nHandle, "Running threads ...: " + strvalue( oErr:RunningThreads() ) )
      FWriteLine( nHandle, "VM thread ID ......: " + strvalue( oErr:VmThreadId() ) )
      FWriteLine( nHandle, "OS thread ID ......: " + strvalue( oErr:OsThreadId() ) )
#endif
#endif

      FWriteLine( nHandle, "" )
      FWriteLine( nHandle, " Trace Through:" )
      FWriteLine( nHandle, "----------------" )

      FWriteLine( nHandle, PadR( err_ProcName( oErr, 3 ), 21 ) + " : " + Transform( err_ProcLine( oErr, 3 ), "999,999" ) + " in Module: " + err_ModuleName( oErr, 3 ) )

      nCount := 3
      WHILE ! Empty( ProcName( ++nCount ) )
         FWriteLine( nHandle, PadR( ProcName( nCount ), 21 ) + " : " + Transform( ProcLine( nCount ), "999,999" ) + " in Module: " + ProcFile( nCount ) )
      ENDDO

      FWriteLine( nHandle, "" )
      FWriteLine( nHandle, "" )

      IF HB_ISSTRING( cScreen )
         FWriteLine( nHandle, PadC( " Video Screen Dump ", nCols, "#" ) )
         FWriteLine( nHandle, "" )
         FWriteLine( nHandle, "+" + Replicate( "-", nCols + 1 ) + "+" )
         FOR nCount := 0 TO nRows
            cOutString := ""
            FOR nForLoop := 0 TO nCols
               cOutString += __XSaveGetChar( cScreen, nCount * ( nCols + 1 ) + nForLoop )
            NEXT
            FWriteLine( nHandle, "|" + cOutString + "|" )
         NEXT
         FWriteLine( nHandle, "+" + Replicate( "-", nCols + 1 ) + "+" )
         FWriteLine( nHandle, "" )
         FWriteLine( nHandle, "" )
      ELSE
         FWriteLine( nHandle, " Video Screen Dump not available" )
      ENDIF

#if 0
      /* NOTE: Adapted from hb_mvSave() source in Harbour RTL. [vszakats] */
      LOCAL nScope, nCount, tmp, cName, xValue

      FWriteLine( nHandle, PadC( " Available Memory Variables ", nCols, "+" ) )
      FWriteLine( nHandle, "" )

      FOR EACH nScope IN { HB_MV_PUBLIC, HB_MV_PRIVATE }
         nCount := __mvDbgInfo( nScope )
         FOR tmp := 1 TO nCount
            xValue := __mvDbgInfo( nScope, tmp, @cName )
            IF ValType( xValue ) $ "CNDTL"
               FWriteLine( nHandle, "      " + cName + " TYPE " + ValType( xValue ) + " " + hb_CStr( xValue ) )
            ENDIF
         NEXT
      NEXT
#endif

      IF lAppendLog .AND. nHandle2 != F_ERROR

         nBytes := FSeek( nHandle2, 0, FS_END )

         cBuff := Space( 10 )
         FSeek( nHandle2, 0, FS_SET )

         WHILE nBytes > 0
            nRead := FRead( nHandle2, @cBuff, hb_BLen( cBuff ) )
            FWrite( nHandle, cBuff, nRead )
            nBytes -= nRead
            cBuff := Space( 10 )
         ENDDO

         FClose( nHandle2 )
         FClose( nHandle )

         FErase( cLogFile )
         FRename( cLogFile2, cLogFile )
      ELSE
         FClose( nHandle )
      ENDIF

   ENDIF

   RETURN .F.
