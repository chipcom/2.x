#require 'hbsqlit3'

// 19.12.22 ������ ���ᨢ �����䨪��� ����� ����஫� F006.xml
function getF006()
  // F006.xml - �����䨪��� ����� ����஫�
  // IDVID,     "N",   2, 0  // ��� ���� ����஫�
  // VIDNAME,   "C", 350, 0  // ������������ ���� ����஫�
  // DATEBEG,   "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND,   "D",   8, 0  // ��� ����砭�� ����⢨� �����

  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT idvid, vidname, datebeg, dateend FROM f006')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr