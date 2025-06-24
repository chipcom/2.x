#include 'common.ch'

function ans_GetMedInsState()

  local answer

  answer := '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
	answer += '<s:Body>'
	answer += '<GetMedInsStateResponse xmlns="http://tempuri.org/">'
	answer += '<GetMedInsStateResult xmlns:a="http://schemas.datacontract.org/2004/07/InsuranceAffilation" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
	answer += '<a:Ack>AA</a:Ack>'
	answer += '<a:Err i:nil="true"/>'
	answer += '<a:Person>'
	answer += '<a:MainENP>3448040821000346</a:MainENP>'
	answer += '<a:RegionalENP>3448040821000346</a:RegionalENP>'
	answer += '</a:Person>'
	answer += '<a:Insurance>'
	answer += '<a:MedInsCompanyId>1027739008440</a:MedInsCompanyId>'
	answer += '<a:InsRegion>18000</a:InsRegion>'
	answer += '<a:StartDate>2016-07-21T00:00:00</a:StartDate>'
	answer += '<a:InsType>3</a:InsType>'
	answer += '<a:InsId>02010053658</a:InsId>'
	answer += '</a:Insurance>'
	answer += '<a:MedicalCare>'
	answer += '<a:LPU>174601</a:LPU>'
	answer += '<a:LPUDT>2016-02-01T00:00:00</a:LPUDT>'
	answer += '<a:LPUDX i:nil="true"/>'
	answer += '<a:LPUDU>2016-04-21T00:00:00</a:LPUDU>'
	answer += '<a:SUBDIV>34202108600003006</a:SUBDIV>'
	answer += '<a:SS_DOCTOR>02188728363</a:SS_DOCTOR>'
	answer += '</a:MedicalCare>'
  answer += '</GetMedInsStateResult>'
	answer += '</GetMedInsStateResponse>'
	answer += '</s:Body>'
  answer += '</s:Envelope>'

  return answer

function ans_GetMedInsState2()

  local answer

  answer := '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
	answer += '<s:Body>'
	answer += '<GetMedInsState2Response xmlns="http://tempuri.org/">'
	answer += '<GetMedInsState2Result xmlns:a="http://schemas.datacontract.org/2004/07/InsuranceAffilation" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
	answer += '<a:Ack>AA</a:Ack>'
	answer += '<a:Err i:nil="true"/>'
	answer += '<a:Person>'
	answer += '<a:MainENP>3448040821000123</a:MainENP>'
	answer += '<a:RegionalENP>3448040821000123</a:RegionalENP>'
	answer += '</a:Person>'
	answer += '<a:Insurance>'
	answer += '<a:MedInsCompanyId>1027739008440</a:MedInsCompanyId>'
	answer += '<a:InsRegion>18000</a:InsRegion>'
	answer += '<a:StartDate>2016-07-21T00:00:00</a:StartDate>'
	answer += '<a:InsType>3</a:InsType>'
	answer += '<a:InsId>02010053123</a:InsId>'
	answer += '</a:Insurance>'
	answer += '<a:MedicalCare>'
	answer += '<a:LPU>174601</a:LPU>'
	answer += '<a:LPUDT>2016-02-01T00:00:00</a:LPUDT>'
	answer += '<a:LPUDX i:nil="true"/>'
	answer += '<a:LPUDU>2016-04-21T00:00:00</a:LPUDU>'
	answer += '<a:SUBDIV>34202108600003001</a:SUBDIV>'
	answer += '<a:SS_DOCTOR>02188728363</a:SS_DOCTOR>'
	answer += '</a:MedicalCare>'
	answer += '</GetMedInsState2Result>'
	answer += '</GetMedInsState2Response>'
	answer += '</s:Body>'
  answer += '</s:Envelope>'

  return answer

function ans_GetMedInsState3()

  local answer

  answer := '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
	answer += '<s:Body>'
	answer += '<GetMedInsState3Response xmlns="http://tempuri.org/">'
	answer += '<GetMedInsState3Result xmlns:a="http://schemas.datacontract.org/2004/07/InsuranceAffilation" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
	answer += '<a:Ack>AA</a:Ack>'
	answer += '<a:Err i:nil="true"/>'
	answer += '<a:Person>'
	answer += '<a:MainENP>3448040821000346</a:MainENP>'
	answer += '<a:RegionalENP>3448040821000346</a:RegionalENP>'
	answer += '</a:Person>'
	answer += '<a:Insurance>'
	answer += '<a:MedInsCompanyId>1027739008440</a:MedInsCompanyId>'
	answer += '<a:InsRegion>18000</a:InsRegion>'
	answer += '<a:StartDate>2016-07-21T00:00:00</a:StartDate>'
	answer += '<a:InsType>3</a:InsType>'
	answer += '<a:InsId>02010053658</a:InsId>'
	answer += '</a:Insurance>'
	answer += '<a:MedicalCare>'
	answer += '<a:LPU>174601</a:LPU>'
	answer += '<a:LPUDT>2016-02-01T00:00:00</a:LPUDT>'
	answer += '<a:LPUDX i:nil="true"/>'
	answer += '<a:LPUDU>2016-04-21T00:00:00</a:LPUDU>'
	answer += '<a:SUBDIV>34202108600003006</a:SUBDIV>'
	answer += '<a:SS_DOCTOR>02188728363</a:SS_DOCTOR>'
	answer += '</a:MedicalCare>'
	answer += '</GetMedInsState3Result>'
	answer += '</GetMedInsState3Response>'
	answer += '</s:Body>'
  answer += '</s:Envelope>'

  return answer

function ans_Error()

  local answer

  answer := '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
	answer += '<s:Body>'
	answer += '<GetMedInsState2Response xmlns="http://tempuri.org/">'
	answer += '<GetMedInsState2Result xmlns:a="http://schemas.datacontract.org/2004/07/InsuranceAffilation" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
	answer += '<a:Ack>AE</a:Ack>'
	answer += '<a:Err>'
	answer += '<a:ErrCode>20</a:ErrCode>'
	answer += '<a:ErrText>На указанную дату СП гражданина в СРЗ не определена</a:ErrText>'
	answer += '</a:Err>'
	answer += '<a:Person i:nil="true"/>'
	answer += '<a:Insurance i:nil="true"/>'
	answer += '<a:MedicalCare i:nil="true"/>'
	answer += '</GetMedInsState2Result>'
	answer += '</GetMedInsState2Response>'
	answer += '</s:Body>'
  answer += '</s:Envelope>'

  return answer
