#include 'function.ch'

#require 'hbsqlit3'

** 26.01.23 ������ ���ᨢ �� �ࠢ�筨�� �����ࠢ� �� �⥯��� �殮�� ���ﭨ� ��樥�� OID 1.2.643.5.1.13.13.11.1006.xml
function get_severity()
  // Local dbName, dbAlias := 'sev'
  // local tmp_select := select()
  static _arr   // := {}
  static time_load
  local db
  local aTable, row
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'id, ' + ;
        'name, ' + ;
        'syn, ' + ;
        'sctid, ' + ;
        'sort ' + ;
        'FROM Severity')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        if val(aTable[nI, 1]) <= 4  // ���� ⮫쪮 �� 4 �⥯��� �殮��
          aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), alltrim(aTable[nI, 3]), val(aTable[nI, 4]), val(aTable[nI, 5])})
        endif
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif

  return _arr

***** 08.01.22 ������ ���ᠭ�� �殮�� ���ﭨ� ��樥��
Function ret_severity_name(s_code)
  // s_code - ��� �殮��
  Local i, ret := ''
  local code
  
  if ValType(s_code) == 'C'
    code := val(s_code)
  elseif ValType(s_code) == 'N'
    code := s_code
  else
    return ret
  endif

  if !empty(code) .and. ((i := ascan(get_severity(), {|x| x[2] == code })) > 0)
    ret := get_severity()[i, 1]
  endif
  return ret
