#include 'hbclass.ch'

function Main
  local oCal := tCal():New()
  local aTest := { {date(), '07:00','07:15'} ,;
    {date(), '07:16','07:30'} }
  local aData := { {'MEL' , date(), '07:00','07:15'} ,;
    {'SUSAN' , date(), '07:31','07:59'} ,;
    {'DANIEL' , date(), '08:00','08:30'} }
  local i

  oCal:CreateDbf()
  oCal:FillData( aData )

  for i:= 1 to len( aTest )
    ?i, oCal:SeekData( aTest[ i, 1], aTest[ i, 2], aTest[ i, 3] ), ;
    oCal:cName
  next
  oCal:Close()
  Return Nil

Class tCal
  data cName init ''
  data cDbf init 'agenda.dbf'
  data cNtx init 'agenda.ntx'
  data aDbf init {{'Name' , 'C',40, 00} ,;
    {'date' , 'D',08,00 } ,;
    {'time_Start', 'C',05,00 } ,;
    {'time_End' , 'C',05,00 } }

  method new() constructor
  method CreateDbf()
  method SeekData( dDate, cTime1, cTime2 )
  Method FillData( aData )
  Method Close()
endclass

Method new() Class tCal
  return Self

Method CreateDbf() Class tCal
  field date
  if !file( ::cDbf )
    dbcreate( ::cDbf, ::aDbf )
    use ( ::cDbf ) new alias cal exclusive
    index on dtos( date ) to ( ::cNtx )
  else
    use ( ::cDbf ) index ( ::cNtx ) new alias cal exclusive
  end
  Return Nil

Method SeekData( dDate, cTime1, cTime2 ) Class tCal
  local lSeek := .f.

  ::cName := ''
  dbseek( dtos( dDate ) )
  while cal->date == dDate .and. !eof()
    //here write conditions you need
    if cTime1 >= cal->time_Start .and. cTime1 <=cal->time_End
      lSeek := .t.
      ::cName := cal->Name
    end
    if cTime2 >= cal->time_Start .and. cTime2 <=cal->time_End
      lSeek := .t.
      ::cName := cal->Name
    end
    if cTime1 >= cal->time_Start .and. cTime2 <=cal->time_End
      lSeek := .t.
      ::cName := cal->Name
    end
    dbskip()
  end
  return lSeek

Method FillData( aData ) Class tCal
  local i

  for i:= 1 to len( aData )
    dbappend()
    cal->Name := aData[ i, 1]
    cal->date := aData[ i, 2]
    cal->time_Start := aData[ i, 3]
    cal->time_End := aData[ i, 4]
  next
  Return Nil

Method Close( ) Class tCal
  select cal
  dbclosearea()
  Return Nil