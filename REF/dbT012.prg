#include 'function.ch'
#include 'hbhash.ch' 
 
#require 'hbsqlit3'

** 26.12.22 ������ ���ᠭ�� �訡�� �� �����䨪��� �訡�� ����� ISDErr.xml
function getError_T012(code)
  static arr
  local db
  local aTable
  local nI
  local s := '�訡�� ' + lstr(code) + ': '

  if arr == nil
    arr := hb_hash()
  
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT code, name FROM isderr')
    if len(aTable) > 1
      for nI := 2 to Len(aTable)
        hb_hSet(arr, val(aTable[nI, 1]), alltrim(aTable[nI, 2]))
      next
    endif
    db := nil
  endif

  if hb_hHaskey(arr, code) 
    s += alltrim(arr[code])
  else
    s += '(�������⭠� �訡��)'
  endif

  return s