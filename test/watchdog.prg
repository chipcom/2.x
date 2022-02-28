// http://clipper.borda.ru/?1-4-0-00001144-000-0-0-1471346473
#include "hbwin+.ch" 
  
 PROCEDURE main( cDir ) 
  
    LOCAL cDirectory 
  
    if hb_dirExists( cDir ) 
       cDirectory := cDir 
    else 
       hb_fnameSplit( hb_dirBase(), @cDirectory ) 
    endif 
  
    if hb_dirExists( cDirectory ) 
       if hb_fileExists( cDirectory + "quit" ) 
          hb_FileDelete( cDirectory + "quit" ) 
       endif 
  
       ErrorLevel( WatchDirectory( cDirectory ) != 0, 1, 0 ) 
    else 
       ErrorLevel( -1 ) 
    endif 
  
    RETURN 
  
  
  
 FUNCTION WatchDirectory( cDir ) 
  
    LOCAL pChangeHandle 
    LOCAL nWaitStatus  
    LOCAL lRunAnyway := .t. 
  
    // watch file name changes ( file was CREATED, RENAMED or DELETED)  
    pChangeHandle := wapi_FindFirstChangeNotification( cDir, .F., FILE_NOTIFY_CHANGE_FILE_NAME ) 
  
    if INVALID_HANDLE_VALUE( pChangeHandle ) 
       ? "ERROR: FindFirstChangeNotification function failed." 
       return wapi_GetLastError()  
    endif  
  
    // Change notification is set. Now we can wait on notification handle. 
    do while lRunAnyway 
       ? "Waiting for notification..." 
       // If the function succeeds, the return value indicates 
       // the event that caused the function to return.  
       nWaitStatus = wapi_WaitForSingleObject( pChangeHandle, INFINITE )  
  
       switch nWaitStatus  
       case WAIT_OBJECT_0  
          // A file was CREATED, RENAMED or DELETED in the directory. 
          // _Refresh_ this directory and _restart_ the notification. 
          RefreshDirectory( cDir, @lRunAnyway )  
  
          if lRunAnyway 
             if ! wapi_FindNextChangeNotification( pChangeHandle ) 
                ? "ERROR: FindNextChangeNotification function failed." 
                return wapi_GetLastError()  
             endif 
          else 
             wapi_FindCloseChangeNotification( pChangeHandle ) 
          endif 
  
          exit 
  
       case WAIT_TIMEOUT 
          // A timeout occurred, this would happen if some value other  
          // than INFINITE is used in the Wait call and no changes occur. 
          // In a single-threaded environment you might not want an 
          // INFINITE wait. 
          ? "No changes in the timeout period." 
          exit 
  
       otherwise 
          ? "ERROR: Unhandled nWaitStatus." 
          return wapi_GetLastError()  
       endswitch 
    end while 
  
    RETURN 0 
  
 /*--- 
 */ 
 PROCEDURE RefreshDirectory( cDir,lRunAnyway ) 
    // This is where you might place code to refresh your 
    // directory listing, but not the subtree because it 
    // would not be necessary. 
    ? hb_strFormat( "Directory (%1$s) changed.", cDir ) 
  
    if hb_fileExists( cDir + "quit" ) 
       lRunAnyway := .f. 
    endif 
  
    RETURN
