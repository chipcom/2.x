#include 'common.ch'

procedure main()

  local testkontur := 1
  local addres, HTTPRequest, HTTPResponse
  local status, statusText, bodyAnswer
  local token := 'd34ab9d4-a6fc-47fe-aafb-bc914dac665f'
  local timeout

	addres = iif( testkontur == 1, 'markirovka.sandbox.crptech.ru', 'cdn.crpt.ru' ) // тут хост продуктивного контура
	addres = 'https://' + addres + '/api/v4/true-api/cdn/info'

  HTTPRequest := win_oleCreateObject( 'WinHttp.WinHttpRequest.5.1' )
//  HTTPRequest := CreateObject ( 'WinHttp.WinHttpRequest.5.1' )
	HTTPRequest:Option( 2, 'utf-8' )
  HTTPRequest:SetTimeouts( 15000, 15000, 15000, 15000 )
    
  HTTPRequest:Open( 'GET', addres, 1 )
    
  HTTPRequest:SetRequestHeader( 'X-API-KEY', alltrim( token ) )
  HTTPRequest:SetRequestHeader( 'Content-Type', 'application/json; charset=utf-8' )
  HTTPRequest:SetRequestHeader( 'Accept-Charset', 'utf-8' )
  HTTPRequest:Send()
  timeout := 5
  HTTPResponse := HTTPRequest:WaitForResponse( timeout )

  if HTTPResponse
    status := HTTPRequest:status()
	  statusText := HTTPRequest:statusText()
	  bodyAnswer := alltrim( HTTPRequest:ResponseText() )

    ?token
    ?status
    ?statusText
    ?bodyAnswer
  else
    ?'ГИС МТ не вернул ни одной доступной плащадки'
  endif
  return