#include 'hbhash.ch' 

#require 'hbsqlit3'

** 21.12.22 ������ ���ᨢ ����� Q017.xml
function loadQ017()
  // �����頥� ���-���ᨢ ����� ��⥣�਩ �஢�ப ��� � ���
  // <key> - �����䨪��� ��⥣�ਨ �஢�ન
  // <value> - ���ᨢ {'������������ �஢�ન', '�������਩', '��� ��砫� �ਬ������', '��� ����砭�� �ਬ������'}

  // Q017 - ���祭� ��⥣�਩ �஢�ப ��� � ��� (TEST_K)
  // ID_KTEST, �����(4),	�����䨪��� ��⥣�ਨ �஢�ન
  // NAM_KTEST, �����(400),	������������ ��⥣�ਨ �஢�ન
  // COMMENT, �����(500), �������਩
  // DATEBEG, �����(10),	��� ��砫� ����⢨� �����
  // DATEEND, �����(10),	��� ����砭�� ����⢨� �����

  static _Q017
  local db
  local aTable
  local nI

  if _Q017 == nil
    _Q017 := hb_hash()
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT id_ktest, nam_ktest, comment, datebeg, dateend FROM q017')
    if len(aTable) > 1
      for nI := 2 to Len(aTable)
        hb_hSet(_Q017, alltrim(upper(aTable[nI, 1])), {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5])})
      next
    endif
    db := nil
  endif
  return _Q017

** 21.12.22 ������ ���ᨢ ����� Q017.xml
function loadQ017_1()
  // �����頥� ���-���ᨢ ����� ��⥣�਩ �஢�ப ��� � ���
  // <key> - �����䨪��� ��⥣�ਨ �஢�ન
  // <value> - ���ᨢ {'������������ �஢�ન', '�������਩', '��� ��砫� �ਬ������', '��� ����砭�� �ਬ������'}
  static _Q017
  Local dbName, dbAlias := 'Q017'
  local tmp_select := select()

  // Q017.dbf - ���祭� ��⥣�਩ �஢�ப ��� � ��� (TEST_K)
  //  1 - ID_KTEST(4)  2 - NAM_KTEST(C) 3 - COMMENT(M)  4 - DATEBEG(D)  5 - DATEEND(D)
  if _Q017 == nil
    _Q017 := hb_hash()
    dbName := '_mo_Q017'
    tmp_select := select()
    dbUseArea(.t., 'DBFNTX', exe_dir + dbName, dbAlias , .t., .f.)

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      hb_hSet(_Q017, alltrim(upper((dbAlias)->ID_KTEST)), {alltrim((dbAlias)->NAM_KTEST), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND})
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _Q017

* 19.02.21 ������ ���ᨢ � ���ᠭ��� ��⥣�ਨ �஢�ન �� �����䨪���� ��⥣�ਨ �஢�ન �� �ࠢ�筨�� ����� Q017.xml
function getCategoryCheckErrorByID_Q017(idCategory)
  // idError - �����䨪��� ��⥣�ਨ �஢�ન
  // arr[1] - �����䨪��� ��⥣�ਨ �஢�ન
  // arr[2] - ������������ ��⥣�ਨ �஢�ન
  // arr[3] - �������਩
  // arr[4] - ��� ��砫� ����⢨� ��⥣�ਨ �஢�ન
  // arr[5] - ��� ����砭�� ����⢨� ��⥣�ਨ �஢�ન
  local arrCategories := loadQ017()
  local category := alltrim(upper(idCategory))
  local aRet := {}

  if hb_hHaskey(arrCategories, category)
    aRet := arrCategories[category]
  else
    AAdd(aRet, '�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + category)
    AAdd(aRet, '')
    AAdd(aRet, ctod('  /  /    '))
    AAdd(aRet, ctod('  /  /    '))
  endif

  return aRet