// http://clipper.borda.ru/?1-4-0-00001372-000-0-0-1644181127

Proc Main 
  local objWMI 
  local intInterval:= "2" 
  local strDrive:= "C:"  
  local strFolder:= "\\POCKET\\skans\\" 
  local elem 
  objWMI:=WmiService()   
   
  colEvents:= objWMI:ExecNotificationQuery("Select * from __InstanceOperationEvent WITHIN "+intInterval+ ; 
                "Where Targetinstance ISA 'CIM_DataFile' And TargetInstance.Drive="+"'"+strdrive+"'"+;  
                "And TargetInstance.Path="+"'"+strFolder+"'" )  
   do while .t. 
  if inkey(2)==27 
  exit 
  endif  
   
  BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }    
  objEvent:= colEvents:NextEvent(2000) 
  Recover USING oErr 
  *      ? oErr:subCode , oErr:operation ,oErr:osCode 
         if "TIMED OUT" $ upper(oErr:description) .or. "0X80043001" $ upper(oErr:description) 
  loop 
         else 
  Return 
         endif 
  End SEQUENCE 
   
   
  objTargetInst:= objEvent:TargetInstance 
   
    For Each elem In objEvent:TargetInstance:Properties_ 
  ? elem:name,elem:value 
    Next  
   
   enddo 
  return  
   
  FUNC WMIService( cComp ) 
           Local oWmi, oItem 
           LOCAL oErrSave := ERRORBLOCK( { | objErr | BREAK( objErr ) } ) 
           LOCAL oErr 
           Local oLocator 
           LOCAL cName := '' 
           LOCAl lLocahost := .f. 
           LOCAL cStr := '' 
           hb_default(@cComp,".") 
   
           oLocator   := CreateObject( "wbemScripting.SwbemLocator" ) 
     oWMI       := oLocator:ConnectServer(cComp,'root\CIMV2') 
  errorblock(oErrSave) 
  RETURN oWmi 
  