#include 'hbgtinfo.ch'
#include 'hbgtwvg.ch'
#include 'function.ch'

Static runApp := .t.
//
Function put_icon( cTitle, xIcon )

  If runApp
    Announce HB_GTSYS
    Request HB_GT_WVT
    Request HB_GT_WVT_DEFAULT
    // запретить закрытие окна (крестиком и по Alt+F4)
    hb_gtInfo( HB_GTI_CLOSABLE, .f. ) // для GT_WVT
    // hb_gtInfo(HB_GTI_CLOSEMODE, 2 ) // для GT_WVG
    // Определить сразу окно 25*80 символов, иначе нужна дополнительная настройка
    SetMode( 25, 80 )
    runApp := .f.
  Endif
  If ValType( cTitle ) == 'C'
    hb_gtInfo( HB_GTI_WINTITLE, cTitle ) // заголовок окна
  Endif
  If xIcon != NIL
    // иконка в левом верхнем углу окна
    If HB_ISNUMERIC( xIcon )
      hb_gtInfo( HB_GTI_ICONRES, xIcon )
    Elseif ( '.ico' $ Lower( xIcon ) )
      hb_gtInfo( HB_GTI_ICONFILE, xIcon )
    Else
      hb_gtInfo( HB_GTI_ICONRES, xIcon )
    Endif
  Endif

  Return Nil

#ifdef __PLATFORM__UNIX
#else
  #pragma BEGINDUMP

  #define HB_OS_WIN_32_USED
  #include <windows.h>
  #include <hbapi.h>
  #include <hbapiitm.h>
  #include <shlobj.h>

  HB_FUNC ( ISEXERUNNING ) // ( cExeNameCaseSensitive ) --> lResult
  {
    HANDLE hMutex = CreateMutex( NULL, TRUE, ( LPTSTR ) hb_parc( 1 ) );
    hb_retl( GetLastError() == 183 /*ERROR_ALREADY_EXISTS*/ );
    ReleaseMutex( hMutex );
  }

  HB_FUNC( GETDESKTOPWINDOW )
  {
    hb_retnl( (LONG)GetDesktopWindow() );
  }

  HB_FUNC( SHELLEXECUTE )
  {
    hb_retnl( (LONG) ShellExecute(
      (HWND) hb_parnl( 1 ) ,
      (LPCSTR) hb_parcx( 2 ) ,
      (LPCSTR) hb_parcx( 3 ) ,
      (LPCSTR) hb_parcx( 4 ) ,  ////////ISNIL(4) ? NULL : (LPCSTR) hb_parcx( 4 ) ,
      (LPCSTR) hb_parcx( 5 ) ,
           hb_parni( 6 )
    ) ) ;
  }
  /*
  Parameters
  hwnd [in] Handle to the owner window used for displaying a user interface (UI)
          or error messages. This value can be NULL if the operation is not
          associated with a window.
  lpOperation [in] Pointer to a null-terminated string, referred to in this case
          as a verb, that specifies the action to be performed. The set of
          available verbs depends on the particular file or folder. Generally,
          the actions available from an object's shortcut menu are available
          verbs. For more information about verbs and their availability,
          see Object Verbs. See Extending Shortcut Menus for further discussion
          of shortcut menus. The following verbs are commonly used.
          "edit" - Launches an editor and opens the document for editing.
                   If lpFile is not a document file, the function will fail.
          "explore" - Explores the folder specified by lpFile.
          "find" - Initiates a search starting from the specified directory.
          "open" - Opens the file specified by the lpFile parameter. The file
                   can be an executable file, a document file, or a folder.
          "print" - Prints the document file specified by lpFile. If lpFile
                    is not a document file, the function will fail.
          NULL - For systems prior to Microsoft Windows 2000, the default verb
                 is used if it is valid and available in the registry. If not,
                 the "open" verb is used.
                 For Windows 2000 and later systems, the default verb is used
                 if available. If not, the "open" verb is used. If neither verb
                 is available, the system uses the first verb listed in the
                 registry.
  lpFile [in] Pointer to a null-terminated string that specifies the file or
            object on which to execute the specified verb. To specify a Shell
            namespace object, pass the fully qualified parse name. Note that
            not all verbs are supported on all objects. For example, not all
            document types support the "print" verb.
  lpParameters [in] If the lpFile parameter specifies an executable file,
            lpParameters is a pointer to a null-terminated string that
            specifies the parameters to be passed to the application.
            The format of this string is determined by the verb that is to be
            invoked. If lpFile specifies a document file, lpParameters should
            be NULL.
  lpDirectory [in] Pointer to a null-terminated string that specifies the default
            directory.
  nShowCmd [in] Flags that specify how an application is to be displayed when
            it is opened. If lpFile specifies a document file, the flag is
            simply passed to the associated application. It is up to the
            application to decide how to handle it.
            SW_HIDE - Hides the window and activates another window.
            SW_MAXIMIZE - Maximizes the specified window.
            SW_MINIMIZE - Minimizes the specified window and activates the next
                          top-level window in the z-order.
            SW_RESTORE - Activates and displays the window. If the window is
                         minimized or maximized, Windows restores it to its
                         original size and position. An application should
                         specify this flag when restoring a minimized window.
            SW_SHOW - Activates the window and displays it in its current size
                      and position.
            SW_SHOWDEFAULT - Sets the show state based on the SW_ flag specified
                             in the STARTUPINFO structure passed to the
                             CreateProcess function by the program that started
                             the application. An application should call
                             ShowWindow with this flag to set the initial show
                             state of its main window.
            SW_SHOWMAXIMIZED - Activates the window and displays it as a
                               maximized window.
            SW_SHOWMINIMIZED - Activates the window and displays it as a
                               minimized window.
            SW_SHOWMINNOACTIVE - Displays the window as a minimized window.
                                 The active window remains active.
            SW_SHOWNA - Displays the window in its current state. The active
                        window remains active.
            SW_SHOWNOACTIVATE - Displays a window in its most recent size and
                                position. The active window remains active.
            SW_SHOWNORMAL - Activates and displays a window. If the window
                            is minimized or maximized, Windows restores it to
                            its original size and position. An application
                            should specify this flag when displaying the window
                            for the first time.
  Return Value
  Returns a value greater than 32 if successful, or an error value that is less
  than or equal to 32 otherwise. The following table lists the error values.
  The return value is cast as an HINSTANCE for backward compatibility with
  16-bit Windows applications. It is not a true HINSTANCE, however. The only
  thing that can be done with the returned HINSTANCE is to cast it to an int
  and compare it with the value 32 or one of the error codes below.
  */
#pragma ENDDUMP
#endif
