// https://harbour.wiki/index.asp?page=PublicArticles&mode=show&id=220304024106&sig=2327201296

function main()
  local l_tNow := hb_datetime()  // To get the current date time.
  local l_dDate
  local l_cTime24    // Will receive the current time of the day in 24 hours mode as text.
  local l_cTimeAmPm  // Will receive the current time of the day in 12 hours mode as text.
  local l_nSeconds   // will receive the current time of the day in seconds with fractions.
  
  local l_tMoonLoadingGMT := hb_CtoT("08/20/1969 4:17 pm GMT")
  local l_tMoonLoadingPST
  
  set century on  //To display the years with 4 digits instead of 2.
  
  l_dDate := hb_TtoD(l_tNow,@l_cTime24,"hh:mm:ss")
  hb_TtoD(l_tNow,@l_cTimeAmPm,"hh:mm:ss am")
  hb_TtoD(l_tNow,@l_nSeconds)
  l_tTime := hb_SecToT(l_nSeconds)   // To create a Datetime with only the time component.
  
  ?"l_tNow",l_tNow
  ?"Now with no milliseconds",hb_SecToT(round(hb_TToSec(l_tNow),0))
  ?"l_dDate",l_dDate
  ?"l_cTime24",l_cTime24
  ?"l_cTimeAmPm",l_cTimeAmPm
  ?"l_nSeconds",l_nSeconds
  ?"l_tTime",l_tTime
  // Two methods to recombine the date and time values.
  ?"Method 1)",l_dDate+l_tTime
  ?"Method 2)",hb_DtoT(l_dDate)+(l_nSeconds/(24*60*60))
  ?
  // to display the time as of UTC
  ?"hb_TSToUTC(l_tNow)",hb_TSToUTC(l_tNow)
  // To find out what the UTC shift is in seconds.
  // The parameter is used to determine as of when we want to know the UTC shift.
  // In the USA there is a concept of daylight savings time which will affect the result.
  ?"hb_UTCOffset(l_tNow)",hb_UTCOffset(l_tNow)
  ?"hb_UTCOffset(l_tNow) in hours",hb_UTCOffset(l_tNow)/3600
  ?
  ?"Moon Landing time in GMT",l_tMoonLoadingGMT
  l_tMoonLoadingPST := l_tMoonLoadingGMT+(hb_UTCOffset(l_tMoonLoadingGMT)/86400)
  ?"Moon Landing time in Seattle",l_tMoonLoadingPST
  ?"Moon Landing time in GMT knowing Seattle time",hb_TSToUTC(l_tMoonLoadingPST)
  ?
  ?"An empty date",ctod(""),empty(ctod(""))
  
  return nil
  