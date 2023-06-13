#require 'hbsqlit3'

// 19.12.22 ������ �����䨪��� ⨯�� ���㬥�⮢, 㤮�⮢������ ��筮��� F011.xml
function getF011()
  // F011.xml - �����䨪��� ⨯�� ���㬥�⮢, 㤮�⮢������ ��筮���
  // IDDoc,     "C",   2, 0  // ��� ⨯� ���㬥��
  // DocName,   "C", 254, 0  // ������������ ⨯� ���㬥��
  // DocSer,    "C",  10, 0  // ��᪠ �ਨ ���㬥��
  // DocNum,    "C",  20, 0  // ��᪠ ����� ���㬥��
  // DATEBEG,   "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND,   "D",   8, 0  // ��� ����砭�� ����⢨� �����

  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table( db, 'SELECT docname, iddoc, datebeg, dateend, docser, docnum FROM f011')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]), val(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4]), alltrim(aTable[nI, 5]), alltrim(aTable[nI, 6])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr