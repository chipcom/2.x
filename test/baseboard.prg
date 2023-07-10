// https://fivetechsupport.com/forums/viewtopic.php?p=136822&sid=812f49ff1feaf67891c0611fbf143264#p136822

// procedure main()
//   local oLoc := CreateObject ( "wbemScripting.SwbemLocator" )
//   local objWMI := oLoc:ConnectServer()
//   local oTipo_Board := objWMI:ExecQuery ( "Select Product, SerialNumber FROM Win32_BaseBoard" )
//   local oDatos

//   FOR EACH oDatos IN oTipo_Board
//     ? "Tipo : " + ALLTRIM ( oDatos:Product ) + ;
//     ", Serie: " + ALLTRIM ( oDatos:SerialNumber ) + hb_eol()
//   NEXT
//   return

  procedure main()
    Local oDatos, oSrv, oJob, i, sMensaje := ""
  Local nFree := ""
  Local oLoc := CreateObject ( "wbemScripting.SwbemLocator" )
  Local objWMI
  Local oSerial_Board
  Local oDisco
  Local oParticiones
  Local oDiskettes
  Local oHard_Unidades
  Local oDVD_CD
  Local oResolucion
  Local oSistema
  Local oUsuarios
  Local oThemas
  Local oFecha_Hora
  Local oProcesador
  Local oTipo_Board
  Local oIP_Mac
  Local oDominio_Grupo
  Local aDrives
  
  // sMensaje += "NetName () := " + NetName () + hb_eol()
  // sMensaje += "GetNetCard := " + GetNetCardID () + hb_eol()
  
  // TRY
  
  objWMI := oLoc:ConnectServer () && Aqu? esta la configuraci?n del Sistema
  
  // CATCH
  
  // TRY
  // objWMI := oLoc:ConnectServer ( "192.168.2.20" ) && 0.0.0.0
  // MsgInfo ( "IP OK" )
  // CATCH
  // MsgInfo ( "Error. Validando el servidor" )
  // CLOSE ALL
  // Return ( NIL )
  // END
  
  // END
  
  oSerial_Board := objWMI:ExecQuery ( "Select * from Win32_PhysicalMedia" )
  oDisco := objWMI:ExecQuery ( "Select * from Win32_LogicalDisk" )
  oParticiones := objWMI:ExecQuery ( "Select * from CIM_DiskPartition" )
  oDiskettes := objWMI:ExecQuery ( "Select * From Win32_LogicalDisk Where DeviceID = 'A:'" )
  oHard_Unidades := objWMI:ExecQuery ( "Select * from Win32_MappedLogicalDisk" )
  oDVD_CD := objWMI:ExecQuery ( "Select * from Win32_CDROMDrive" )
  oResolucion := objWMI:ExecQuery ( "Select * from Win32_DesktopMonitor" )
  oSistema := objWMI:ExecQuery ( "Select * from Win32_OperatingSystem" )
  oUsuarios := objWMI:ExecQuery ( "Select * from Win32_Account" )
  oThemas := objWMI:ExecQuery ( "Select * from Win32_Service Where Name = 'Themes'" )
  oFecha_Hora := objWMI:ExecQuery ( "Select * from Win32_LocalTime" )
  oProcesador := objWMI:ExecQuery ( "Select * from Win32_Processor" )
  oTipo_Board := objWMI:ExecQuery ( "Select Product, SerialNumber FROM Win32_BaseBoard" )
  oIP_Mac := objWMI:ExecQuery ( "Select IPAddress FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=TRUE" )
  oDominio_Grupo := objWMI:ExecQuery ( "Select * from Win32_ComputerSystem" )
  aDrives := objWMI:ExecQuery ( "Select * from Win32_ComputerSystemProduct" )
  
  /*
  objWMI := oLoc:ConnectServer ()
  oTipo_Board := objWMI:ExecQuery ( "select * from Win32_BaseBoard" )
  * oSrv:ExecQuery ( "SELECT * FROM Win32_BaseBoard" )
  
  DeviceID
  */
  
  * --------------------------- // -------------------------- *
  // sMensaje += "Unidad y serial l?gico de las unidades del disco:" + hb_eol()
  // FOR Each oDatos In oDisco
  // sMensaje += "Unidad: " + ALLTRIM ( cValToChar ( oDatos:Name ) ) + ;
  // ", SN : " + ALLTRIM ( ( oDatos:SystemName ) ) + ;
  // " \ Serial: " + ALLTRIM ( cValToChar ( oDatos:VolumeSerialNumber ) ) + hb_eol()
  // NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  // sMensaje += hb_eol() + "Particiones Discos Duros disponibles:" + hb_eol()
  // FOR Each oDatos in oParticiones
  // sMensaje += ALLTRIM ( cValToChar ( oDatos:Name ) ) + ;
  // " - Tama?o: " + ALLTRIM ( cValToChar ( oDatos:Size ) ) + ;
  // " En: " + ALLTRIM ( cValToChar ( oDatos:SystemName ) ) + ;
  // " - Tipo: " + ALLTRIM ( cValToChar ( oDatos:TYPE ) ) + hb_eol()
  // NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  sMensaje += hb_eol() + 'Drive Diskette de 3?":' + hb_eol()
  FOR Each oDatos in oDiskettes
  nFree := oDatos:FreeSpace
  
  IF VALTYPE ( nFree ) = "U"; sMensaje += " No hay diskete en la unidad A:\" + hb_eol()
  ELSE ; sMensaje += " Hay un diskete en la unidad A:\" + hb_eol()
  ENDIF
  
  NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  // sMensaje += hb_eol() + "Lista de unidades Mapeadas por el PC:" + hb_eol()
  // FOR Each oDatos in oHard_Unidades
  // sMensaje += "Device ID: " + oDatos:DeviceID + ;
  // "Nombre: " + oDatos:Name + ;
  // "Espacio Libre: " + cValtoChar ( oDatos:FreeSpace ) + ;
  // "Tama?o: " + cValtoChar ( oDatos:Size ) + hb_eol()
  // NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  sMensaje += hb_eol() + "Unidades de CD instaladas en el equipo:" + hb_eol()
  FOR Each oDatos in oDVD_CD
  sMensaje += "Unidad: " + oDatos:Drive + " " + ;
  "Nombre: " + oDatos:Caption + hb_eol()
  NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  // sMensaje += hb_eol() + "Resoluci?n de Pantalla:" + hb_eol()
  // FOR Each oDatos in oResolucion
  // sMensaje += "Alto: " + cValToChar ( oDatos:ScreenHeight ) + " * " + ;
  // "Ancho: " + cValToChar ( oDatos:ScreenWidth ) + hb_eol()
  // NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  sMensaje += hb_eol() + "Fecha de Instalaci?n de Windows XP:" + hb_eol()
  FOR Each oDatos In oSistema
  sMensaje += oDatos:InstallDate + hb_eol()
  NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  sMensaje += hb_eol() + "Directorios:" + hb_eol()
  FOR Each oDatos in oSistema
  sMensaje += "Windows en: " + oDatos:WindowsDirectory + ;
  ", Sistema en: " + oDatos:SystemDirectory + hb_eol()
  NEXT
  * --------------------------- // -------------------------- *
  * &&
  
  * --------------------------- // -------------------------- *
  // sMensaje += hb_eol() + "Lista de Usuarios de Windows:" + hb_eol()
  // FOR Each oDatos in oUsuarios
  // sMensaje += cValToChar ( oDatos:Name ) + " - " + cValToChar ( oDatos:Caption ) + hb_eol()
  // NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  // sMensaje += hb_eol() + "Deshabilitando los Themes en Windows XP" + hb_eol()
  // FOR Each oDatos in oThemas
  // oDatos:StopService ()
  // SysRefresh ()
  // NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  // sMensaje += hb_eol() + "Habilitando los Themes en Windows XP" + hb_eol()
  // FOR Each oDatos in oThemas
  // oDatos:StartService ()
  // SysRefresh ()
  // NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  sMensaje += hb_eol() + "Sistemas operativos instalados en el PC:" + hb_eol()
  FOR Each oDatos in oSistema
  sMensaje += oDatos:Caption + " " + oDatos:VERSION + hb_eol()
  NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  // sMensaje += hb_eol() + "Fecha y Hora actual del PC:" + hb_eol()
  // FOR Each oDatos in oFecha_Hora
  // sMensaje += "Fecha_A?o: " + cValToChar ( oDatos:YEAR ) + hb_eol() + ;
  // "Fecha_Mes: " + cValToChar ( oDatos:MONTH ) + hb_eol() + ;
  // "Fecha_D?a: " + cValToChar ( oDatos:DAY ) + hb_eol() + ;
  // "D?a de la semana: " + cValToChar ( oDatos:DayOfWeek ) + hb_eol() + ;
  // "Semana en el mes: " + cValToChar ( oDatos:WeekInMonth ) + hb_eol() + hb_eol() + ;
  // "Hora: " + cValToChar ( oDatos:Hour ) + hb_eol() + ;
  // "Minutos: " + cValToChar ( oDatos:Minute ) + hb_eol() + ;
  // "Segundos: " + cValToChar ( oDatos:Second ) + hb_eol()
  // NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  // sMensaje += hb_eol() + "Procesadores en la CPU:" + hb_eol()
  // FOR EACH oDatos IN oProcesador
  // sMensaje += " El Nombre del Procesador es: " + ALLTRIM ( cValtoChar ( oDatos:Name ) ) + hb_eol()
  // sMensaje += " la Velocidad Actual del Procesador es de: " + ALLTRIM ( cValtoChar ( oDatos:CurrentClockSpeed ) ) + " Mghz" + hb_eol()
  // sMensaje += " la Velocidad M?xima del Procesador es de: " + ALLTRIM ( cValtoChar ( oDatos:MaxClockSpeed ) ) + " Mghz" + hb_eol()
  
  // NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  sMensaje += hb_eol() + "Dominio / Grupo:" + hb_eol()
  FOR EACH oDatos IN oDominio_Grupo
  If oDatos:PartOfDomain; sMensaje += "Dominio: " + oDatos:Domain + hb_eol()
  Else ; sMensaje += "Grupo de Trabajo: " + oDatos:Domain + hb_eol()
  EndIf
  Next
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  // sMensaje += hb_eol() + "IP Mac:" + hb_eol()
  // FOR EACH oDatos IN oIP_Mac
  // sMensaje += "La IPAddress es: " + ALLTRIM ( oDatos:IPAddress ( 0 ) ) + ;
  // ", la MacAddress es: " + ALLTRIM ( oDatos:IPAddress ( 1 ) ) + hb_eol()
  // NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  sMensaje += hb_eol() + "Tipo de MainBoard:" + hb_eol()
  FOR EACH oDatos IN oTipo_Board
  sMensaje += "Tipo : " + ALLTRIM ( oDatos:Product ) + ;
  ", Serie: " + ALLTRIM ( oDatos:SerialNumber ) + hb_eol()
  NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  nAt := 0
  sMensaje += hb_eol() + "Seriales del MainBoard de F?brica:" + hb_eol()
  FOR Each oDatos In oSerial_Board
  sMensaje += "Serial " + TRANSFORM ( nAt++, "99" ) + ": " + ALLTRIM ( oDatos:SerialNumber ) + hb_eol()
  * exit
  NEXT
  * --------------------------- // -------------------------- *
  
  * --------------------------- // -------------------------- *
  sMensaje += hb_eol() + "Lista de Drivers UUID" + hb_eol()
  FOR Each oDatos IN aDrives
  sMensaje += " nombre x : " + ALLTRIM ( oDatos:Name ) + ;
  " UUID x : " + ( oDatos:UUID ) + hb_eol()
  NEXT
  * --------------------------- // -------------------------- *
  
  * &&
  sMensaje += hb_eol() + "Seriales:" + hb_eol()
  FOR nAt := 1 TO LEN ( aDrives ) && 1 = Diskette A:, 2 = Diskette B:, W_MAIN_INFO( 242 )
  sMensaje += "Serial " + TRANSFORM ( nAt, "99" ) + ":" + hb_eol() && ALLTRIM ( STR ( aDrives [ nAt ] ), 20 ) + hb_eol() && Error description: (DOS Error -2147352567) WINOLE/1016 array access: SWbemObjectSet
  NEXT nAt
  * --------------------------- // -------------------------- *
  * &&
  
  NDOSNUME := FCREATE ( 'info_system.txt', 1 ) && FO_READ := 0, FO_WRITE := 1, READWRITE := 2
  FWRITE ( NDOSNUME, sMensaje )
  FCLOSE ( NDOSNUME )
  
  // MsgInfo ( sMensaje, "Informaci?n Hard" )
  
  Return ( NIL )