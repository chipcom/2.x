#include 'function.ch'
#include 'chip_mo.ch'

function test_init()

//  local a
//  local b, c

  // local HTTPQuery, result, timeout := 5
  // local status, statusText, bodyJSON
  // local token := "d34ab9d4-a6fc-47fe-aafb-bc914dac665f"
  // local cURL := "https://cdn.crpt.ru//api/v4/true-api/cdn/info"

  // HTTPQuery := CreateObject("WinHttp.WinHttpRequest.5.1")
  // HTTPQuery:Option(2, "utf-8")
  // HTTPQuery:SetTimeouts(15000, 15000, 15000, 15000)
  // HTTPQuery:Open( "GET", cURL, 1 )
  // HTTPQuery:SetRequestHeader("X-API-KEY", AllTrim(token))
  // HTTPQuery:SetRequestHeader("Accept-Charset", "utf-8")
  // HTTPQuery:SetRequestHeader("Content-Type", "application/json; charset=utf-8")
  // HTTPQuery:Send()
  // result := HTTPQuery:WaitForResponse(timeout)

  // //  if result == -1
		// status := HTTPQuery:status()
    // statusText := HTTPQuery:statusText()
    // bodyJSON := AllTrim(HTTPQuery:ResponseText())
// //  endif

// //   a := ksgInList( 'st19.089', 'st19.084-st19.089, st19.094-st19.102, st19.163-st19.181, ds19.058-ds19.062, ds19.067-ds19.078, ds19.135-ds19.156' ) 
// //   b := get_array_PZ_new( 2018 ) 
// //   c := get_array_PZ_new( 2017 ) 

  // altd()
  // HTTPQuery := nil
  return nil

// 12.07.24
function convert_P_CEL()

  static hPCEL

  if HB_ISNIL( hPCEL )
    hPCEL := hb_Hash( ;
      1 , '1.0', ;
      2 , '1.1', ;
      3 , '1.2', ;
      4 , '1.3', ;
      5 , '2.1', ;
      6 , '2.2', ;
      7 , '2.3', ;
      8 , '2.5', ;
      9 , '2.6', ;
      10 , '3.0', ;
      11 , '3.1', ;
      12 , '3.2', ;
      13 , '1.4', ;
      14 , '1.5', ;
      15 , '1.6', ;
      16 , '1.7', ;
      17 , '1.2' ;  // до 23 года
    )
  endif

  return hPCEL