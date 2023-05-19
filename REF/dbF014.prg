
#include 'function.ch'

#require 'hbsqlit3'

// 19.05.23 ������ ���ᨢ �ࠢ�筨�� ����� F014.xml
function getF014()
  // F014.xml - �����䨪��� ��稭 �⪠�� � ����� ����樭᪮� �����
  // Kod,     "N",   3, 0  // ��� �訡��
  // IDVID,   "N",   1, 0  // ��� ���� ����஫�, १�ࢭ�� ����
  // Naim,    "C",1000, 0  // ������������ ��稭� �⪠��
  // Osn,     "C",  20, 0  // �᭮����� �⪠��
  // Komment, "C", 100, 0  // ��㦥��� �������਩
  // KodPG,   "C",  20, 0  // ��� �� �ଥ N ��
  // DATEBEG, "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND, "D",   8, 0   // ��� ����砭�� ����⢨� �����

  // �����頥� ���ᨢ
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'kod, ' + ;
      'osn, ' + ;
      'naim, ' + ;
      'komment, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM f014')
    if len(aTable) > 1
      for nI := 2 to Len(aTable)
        aadd(_arr, {val(aTable[nI, 1]), ;
          alltrim(aTable[nI, 1]) + ' (' + alltrim(aTable[nI, 2]) + ') ' + alltrim(aTable[nI, 3]), ;
          alltrim(aTable[nI, 4]), ;
          alltrim(aTable[nI, 2])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr