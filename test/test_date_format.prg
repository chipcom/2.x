

procedure main( ... )
  local i, dt := date()
  local t1, t2, t3

  REQUEST HB_CODEPAGE_RU866
  HB_CDPSELECT("RU866")
  REQUEST HB_LANG_RU866
  HB_LANGSELECT("RU866")

  //SET(_SET_EVENTMASK,INKEY_KEYBOARD)
  SET SCOREBOARD OFF
  SET EXACT ON
  SET DATE GERMAN
  SET WRAP ON
  SET CENTURY ON
  SET EXCLUSIVE ON
  SET DELETED ON

  t1 := int(Seconds())
  OutStd( "Количество секунд после полуночи 1 - " + str(t1) + hb_eol() )
  for i := 1 to 100000000
  next
  t2 := int(Seconds())
  OutStd( "Количество секунд после полуночи 2 - " + str(t2) + hb_eol() )
  t3 := t2 - t1
  if t3 > 0
    OutStd( "Разница во времени - " + sectotime(t3) + hb_eol() )
  endif
  // for i := 1 to 100000000
  //   d_str(dt)
  // next
  // t2 := Seconds() - t1
  // if t2 > 0
  //   OutStd( "Время конвертации - " + sectotime(t2) + hb_eol() )
  // endif


  // t1 := Seconds()
  // for i := 1 to 100000000
  //   date2xml(dt)
  // next
  // t2 := Seconds() - t1
  // if t2 > 0
  //   OutStd( "Время конвертации - " + sectotime(t2) + hb_eol() )
  // endif

  return

function d_str(mdate)
  local dc

  Set(_SET_DATEFORMAT, 'yyyy-mm-dd')

  dc := hb_ValToStr(mdate)

  Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  return dc

** строка даты для XML-файла
Function date2xml(mdate)
return strzero(year(mdate), 4) + '-' + ;
     strzero(month(mdate), 2) + '-' + ;
     strzero(day(mdate), 2)
