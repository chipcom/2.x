
#include 'function.ch'

#require 'hbsqlit3'

* 17.12.22 ������ ���ᨢ �ࠢ�筨�� ����� F014.xml
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
  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT kod, osn, naim, komment, datebeg, dateend FROM f014')
    if len(aTable) > 1
      for nI := 2 to Len(aTable)
        // if between(sys_date, ctod(aTable[nI, 5]), ctod(aTable[nI, 6]))
          aadd(_arr, {val(aTable[nI, 1]), alltrim(aTable[nI, 1]) + ' (' + alltrim(aTable[nI, 2]) + ') ' + alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), alltrim(aTable[nI, 2])})
          // AAdd(_F014, {(dbAlias)->KOD, lstr((dbAlias)->KOD)+" ("+ alltrim((dbAlias)->OSN)+") "+alltrim((dbAlias)->NAME), alltrim((dbAlias)->OPIS), alltrim((dbAlias)->OSN)} )
          // endif
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr

** 17.12.22 ������ ���ᨢ �ࠢ�筨�� ����� F014.xml
function getF014_1()
  // F014.xml - �����䨪��� ��稭 �⪠�� � ����� ����樭᪮� �����
  //  1 - Komment(C)  2 - Kod(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - IDVID(N)  6 - Naim(C)  7 - Osn(C)  8 - KodPG(C)

  // �����頥� ���ᨢ
  static _F014 := {}
  Local dbName, dbAlias := 'F014'
  local tmp_select := select()

  // _mo_f014.dbf - �����䨪��� ��稭 �⪠�� � ����� ����樭᪮� �����
  //  1 - KOD(3)  2 - NAME(C) 3 - OPIS(M) 4 - OSN(C) 5 - DATEBEG(D) 6 - DATEEND(D)
  if len(_F014) == 0
    dbName := '_mo_f014'
    tmp_select := select()
    dbUseArea(.t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f.)

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      // if between(sys_date, (dbAlias)->DATEBEG, (dbAlias)->DATEEND)
        AAdd(_F014, {(dbAlias)->KOD, lstr((dbAlias)->KOD)+" ("+ alltrim((dbAlias)->OSN)+") "+alltrim((dbAlias)->NAME), alltrim((dbAlias)->OPIS), alltrim((dbAlias)->OSN)})
      // endif

      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _F014
