* 07.01.22 ������ ���ᨢ �� �ࠢ�筨�� ����� V034.xml
function getV034()
  // V034.xml - ������� ����७�� (UnitMeas)
  //  1 - UNITCODE(N) 2 - UNITMEAS(C) 3 - SHORTTIT(C)  4 - DATEBEG(D)  5 - DATEEND(D)
  local dbName := '_mo_v034'
  Local dbAlias := 'V034'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { alltrim((dbName)->SHORTTIT), (dbName)->UNITCODE, (dbName)->DATEBEG, (dbName)->DATEEND, alltrim((dbName)->UNITMEAS) })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

***** 12.01.22 ������ ������������ ������� ����७��
Function ret_ed_izm_V034(s_code)
  // s_code - ��� �奬�
  Local i, ret := ''
  local code

  if ValType(s_code) == 'C'
    code:= val(alltrim(s_code))
  elseif ValType(s_code) == 'N'
    code := s_code
  else
    return ret
  endif
  
  if !empty(code) .and. ((i := ascan(getV034(), {|x| x[2] == code })) > 0)
    ret := getV034()[i, 1]
  endif
  return ret
