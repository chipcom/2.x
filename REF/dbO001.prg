#require 'hbsqlit3'

** 12.05.22 ������ ���ᨢ ����� O001.xml
function getO001()
  // O001 - �����ᨩ᪨� �����䨪��� ��࠭ ��� (����)
  // KOD,     "C",    3,      0 // ���஢�� ���
  // NAME11,  "C",  250,      0 // ������������
  // NAME12", "C",  250,      0 // �த������� ������������
  // ALFA2,   "C",    2,      0 // �㪢���� ��� ����-2
  // ALFA3,   "C",    3,      0 // �㪢���� ��� ����-3

  static _O001 := {}
  local db
  local aTable
  local nI

  if len(_O001) == 0
    db := openSQL_DB()
    // aTable := sqlite3_get_table( db, "SELECT name11, kod, datebeg, dateend, alfa2, alfa3, name12 FROM o001" )
    aTable := sqlite3_get_table(db, 'SELECT name11, kod, alfa2, alfa3, name12 FROM o001')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        // aadd(_O001, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4]), alltrim(aTable[nI, 5]), alltrim(aTable[nI, 6]), alltrim(aTable[nI, 7])})
        aadd(_O001, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), aTable[nI, 3], aTable[nI, 4], alltrim(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _O001

** 04.10.22 ������ ���ᨢ ����� O001.xml
function getO001_1()
  static _O001 := {}
  Local dbName, dbAlias := 'O001'
  local tmp_select := select()

  // O001.dbf - �����ᨩ᪨� �����䨪��� ��࠭ ��� (����)
  //  1 - NAME11(C)  2 - KOD(C)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - ALFA2(C)  6 - ALFA3(C)  7 - NAME11(C)
  if len(_O001) == 0
    dbName := '_mo_O001'
    tmp_select := select()
    dbUseArea( .t., 'DBFNTX', exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
        aadd(_O001, { alltrim((dbAlias)->NAME11), (dbAlias)->KOD, (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->ALFA2, (dbAlias)->ALFA3, alltrim((dbAlias)->NAME12) })
        (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _O001

** 01.11.22 ������ ��࠭�
Function getCountry(lstrana)
  Static kod_RF := '643'

  Local s := space(10), i

  if !empty(lstrana) .and. lstrana != kod_RF ;
         .and. (i := ascan(getO001(), {|x| x[2] == lstrana })) > 0
    s := getO001()[i, 1]
  endif
  return s
  
