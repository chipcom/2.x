#include 'common.ch'
#include 'hbhash.ch'
#include 'tbox.ch'
#include 'chip_mo.ch'

//
FUNCTION Plugins()

  LOCAL aMenu := {}, i
  LOCAL aPlugins := ReadIni( edi_FindPath( 'chip_plugin.ini' ) )
  LOCAL aMenu1 := {}
	local color_say := 'N/W', color_get := 'W/N*'
  local oBox

  FOR i := 1 TO Len( aPlugins )
     IF Empty( aPlugins[i, 3] )
        AAdd( aMenu, { aPlugins[i, 2], Nil, i } )
        AAdd( aMenu1, aPlugins[i, 2] )
     ENDIF
  NEXT

  IF !Empty( aMenu1 )
    do while .t.
      oBox := NIL // уничтожим окно
      oBox := TBox():New( 2, 10, 22, 70 )
      oBox:Color := color_say + ',' + color_get
      oBox:Frame := BORDER_DOUBLE
      oBox:MessageLine := '^<Esc>^ - выход;  ^<Enter>^ - выбор'
      oBox:Save := .t.
  
      oBox:Caption := 'Выбор внешней обработки'
      oBox:View()

      if (i := AChoice( oBox:Top + 1, oBox:Left + 1, oBox:Bottom - 1, oBox:Right - 1, aMenu1 )) > 0
        oBox := nil
        i := aMenu[i, 3]
        edi_RunPlugin( aPlugins, i )
      else
        exit
      ENDIF
    enddo
  ENDIF

  oBox := nil
  RETURN Nil

FUNCTION edi_RunPlugin( aPlugins, xPlugin, aParams )

  LOCAL i, cPlugin, cFullPath
 
  IF Valtype( xPlugin ) == 'N'
      i := xPlugin
  ELSEIF Valtype( xPlugin ) == 'C'
      i := Ascan( aPlugins, {|a| a[1] == xPlugin} )
  ENDIF
  IF i > 0
    IF Empty( aPlugins[i, 4] )
      cPlugin := aPlugins[i, 1]
      IF !Empty( cFullPath := edi_FindPath( 'plugins' + hb_ps() + cPlugin ) )
        aPlugins[i, 4] := hb_hrbLoad( cFullPath )
        aPlugins[i, 5] := cFullPath
      ENDIF
    ENDIF
    IF !Empty( aPlugins[i, 4] )
      // RETURN hb_hrbDo( aPlugins[i, 4], oEdit, hb_fnameDir( aPlugins[i, 5] ), aParams )
      RETURN hb_hrbDo( aPlugins[i, 4], , hb_fnameDir( aPlugins[i, 5] ), aParams )
    ENDIF
  ENDIF
 
  RETURN .F.
 
FUNCTION edi_FindPath( cFile )

  LOCAL cFullPath

  //  hb_DirBase() - Drive and directory name of running executable ( application ) 
#ifdef __PLATFORM__UNIX
  IF File( cFullPath := ( cur_dir + cFile ) ) .OR. ;
    File( cFullPath := ( hb_DirBase() + cFile ) )
    // File( cFullPath := ( getenv("HOME") + "/hbedit/" + cFile ) ) .OR. ;
#else
  IF File( cFullPath := ( cur_dir + cFile ) ) .OR. ;
    File( cFullPath := ( hb_DirBase() + cFile ) )
#endif
    RETURN cFullPath
  ENDIF
 
  RETURN Nil
   
// 23.11.23
STATIC FUNCTION ReadIni( cIniName )

  LOCAL hIni := edi_iniRead( cIniName ), aSect, arr, i, cTmp, s, nPos, n
  LOCAL aPanes := { Nil, Nil }, cp, lPalette := .F.
  LOCAL aPlugins := {}
  local cPodrazdel

  Do Case
  Case glob_task == X_REGIST //
    cPodrazdel := 'PLUGINS_REGIST'
  Case glob_task == X_OMS  //
    cPodrazdel := 'PLUGINS_OMS'
  otherwise
    cPodrazdel := 'PLUGINS'
  Endcase

  IF !Empty( hIni )
    hb_hCaseMatch( hIni, .F. )
 
    IF hb_hHaskey( hIni, cTmp := cPodrazdel ) .AND. !Empty( aSect := hIni[ cTmp ] )
      hb_hCaseMatch( aSect, .F. )
      arr := hb_hKeys( aSect )
      FOR i := 1 TO Len( arr )
        s := aSect[ arr[i] ]
        IF ( n := At( ',', s ) ) > 0
          cTmp := AllTrim( Left( s, n - 1 ) )
          IF !Empty( edi_FindPath( 'plugins' + hb_ps() + cTmp ) )
            s := Substr( s, n + 1 )
            IF ( n := At( ',', s ) ) > 0
              Aadd( aPlugins, { cTmp, Substr( s, n + 1 ), AllTrim(Left( s, n - 1 )), Nil, Nil } )
            ENDIF
          ENDIF
        ENDIF
      NEXT
    ENDIF
  endif

  RETURN aPlugins
 
FUNCTION edi_IniRead( cFileName )

  LOCAL cText := Memoread( cFileName ), aText, i, s, nPos
  LOCAL hIni, hSect
   
  IF Empty( cText )
    RETURN Nil
  ENDIF
   
  aText := hb_aTokens( cText, Chr(10) )
  hIni := hb_Hash()
   
  FOR i := 1 TO Len( aText )
    s := Iif( Left( aText[i], 1 ) == ' ', Ltrim( aText[i] ), aText[i] )
    IF Left( s, 1 ) $ ";#"
      LOOP
    ENDIF
    s := Trim( Iif( Right(s, 1) == Chr(13), Left( s, Len(s) - 1 ), s ) )
    IF Empty( s )
      LOOP
    ENDIF
   
    IF Left( s, 1 ) == '[' .AND. Right( s, 1 ) == ']'
      hSect := hIni[Substr( s, 2, Len(s) - 2 )] := hb_Hash()
    ELSEIF !( hSect == Nil )
      IF ( nPos := At( '=', s ) ) > 0
        hSect[Trim(Left(s, nPos - 1))] := Ltrim( Substr( s, nPos + 1 ) )
      ENDIF
    ENDIF
  NEXT
   
  RETURN hIni
