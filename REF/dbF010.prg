#require 'hbsqlit3'

// 17.12.22 ������ ���ᨢ ॣ����� �� �ࠢ�筨�� ॣ����� ����� F010.xml
function getf010()
  // F010.xml - �����䨪��� ��ꥪ⮢ ���ᨩ᪮� �����樨
  // KOD_TF,       "C",      2,      0  // ��� �����
  // KOD_OKATO,     "C",    5,      0  // ��� �� ����� (�ਫ������ � O002).
  // SUBNAME,     "C",    254,      0  // ������������ ��ꥪ� ��
  // OKRUG,     "N",        1,      0  // ��� 䥤�ࠫ쭮�� ���㣠
  // DATEBEG,   "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND,   "D",   8, 0   // ��� ����砭�� ����⢨� �����

  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT subname, kod_tf, okrug, kod_okato, datebeg, dateend FROM f010')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), val(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
    aadd(_arr, {'����ࠫ쭮�� ���稭����', '99', 0})
    if hb_FileExists(exe_dir + 'f010' + sdbf)
      FErase(exe_dir + 'f010' + sdbf)
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr