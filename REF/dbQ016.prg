#include 'hbhash.ch' 

#require 'hbsqlit3'

* 21.12.22 ������ ���ᨢ � ���ᠭ��� �孮�����᪮�� �ࠢ��� ॠ����樨 ��� �� �ࠢ�筨�� ����� Q016.xml
function getRuleCheckErrorByID_Q016(idRule)
  // idRule - �����䨪��� �ࠢ��� �஢�ન
  // arr[1] - ������������ ��⥣�ਨ �஢�ન
  // arr[2] - ��� ��ꥪ� ���, �� ᮮ⢥��⢨� � ����� �����⢫���� �஢�ઠ ���祭�� �����
  // arr[3] - ��� ����� ��ꥪ� ���, �� ᮮ⢥��⢨� � ����� �����⢫���� �஢�ઠ ���祭�� �����
  // arr[4] - �᫮��� �஢������ �஢�ન �����
  // arr[5] - ������⢮ �����⨬�� ���祭�� �����
  // arr[6] - �������਩
  // arr[7] - ��� ��砫� ����⢨� ��⥣�ਨ �஢�ન
  // arr[8] - ��� ����砭�� ����⢨� ��⥣�ਨ �஢�ન
  
  // local arrRules := loadQ016()
  local db
  local stmt 
  local rule := alltrim(upper(idRule))
  local aRet := {}

  db := openSQL_DB()

  stmt := sqlite3_prepare(db, 'SELECT id_test, id_el, nsi_obj, nsi_el, usl_test, val_el, comment, datebeg, dateend FROM q016 WHERE id_test == :id_test')
  sqlite3_bind_text(stmt, 1, rule)
  Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
  do while sqlite3_step(stmt) == SQLITE_ROW
    // AAdd(aRet, sqlite3_column_text(stmt, 1))
    AAdd(aRet, sqlite3_column_text(stmt, 2))
    AAdd(aRet, sqlite3_column_text(stmt, 3))
    AAdd(aRet, sqlite3_column_text(stmt, 4))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 5), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 6), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 7), 'RU866'))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 8)))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 9)))
  enddo
  Set(_SET_DATEFORMAT, 'dd.mm.yyyy')

  sqlite3_clear_bindings(stmt)
  sqlite3_finalize(stmt)

  db := nil
  if len(aRet) == 0
      AAdd(aRet, '�������⭮� �ࠢ��� �஢�ન � �����䨪��஬: ' + rule)
      AAdd(aRet, '')
      AAdd(aRet, '')
      AAdd(aRet, '')
      AAdd(aRet, '')
      AAdd(aRet, '')
      AAdd(aRet, ctod('  /  /    '))
      AAdd(aRet, ctod('  /  /    '))
  endif

  // if hb_hHaskey(arrRules, rule)
  //   aRet := arrRules[rule]
  // else
  //   AAdd(aRet, '�������⭮� �ࠢ��� �஢�ન � �����䨪��஬: ' + rule)
  //   AAdd(aRet, '')
  //   AAdd(aRet, '')
  //   AAdd(aRet, '')
  //   AAdd(aRet, '')
  //   AAdd(aRet, '')
  //   AAdd(aRet, ctod('  /  /    '))
  //   AAdd(aRet, ctod('  /  /    '))
  // endif

  return aRet

** 21.12.22 ������ ���ᨢ ����� Q016.xml
function loadQ016()
  // �����頥� ���-���ᨢ ����� ��⥣�਩ �஢�ப ��� � ���
  // <key> - �����䨪��� �ࠢ��� �஢�ન
  // <value> - ���ᨢ

  // Q016 - ���祭� �孮�����᪨� �ࠢ�� ॠ����樨 ��� � �� ������� ���ᮭ���஢������ ��� ᢥ����� �� ��������� ����樭᪮� ����� (FLK_MPF)
  // ID_TEST, �����(12),	�����䨪��� �஢�ન. 
  //      ��ନ����� �� 蠡���� KKKK.RR.TTTT, ���
  //      KKKK - �����䨪��� ��⥣�ਨ �஢�ન 
  //        � ᮮ⢥��⢨� � �����䨪��஬ Q017,
  //      RR ��� ����� � ᮮ⢥��⢨� � �����䨪��஬ F010.
  //        ��� �஢�ப 䥤�ࠫ쭮�� �஢�� RR �ਭ����� ���祭�� 00.
  //      TTTT - 㭨����� ����� �஢�ન � ��⥣�ਨ
  // ID_EL, �����(100),	�����䨪��� �����, 
  //      �������饣� �஢�થ (�ਫ������ �, �����䨪��� Q018)
  
  // DESC_TEST, �����(500),	���ᠭ�� �஢�ન
  // TYPE_MD	��	�����⨬� ⨯� ��।������� ������, ᮤ�ঠ�� 
  //      �����, �������騩 �஢�થ
  // TYPE_D, �����(2),	��� ��।������� ������, ᮤ�ঠ�� �����,
  //      �������騩 �஢�થ (�ਫ������ �, �����䨪��� Q019)
  // NSI_OBJ, �����(4), ��� ��ꥪ� ���, �� ᮮ⢥��⢨� � ����� 
  //      �����⢫���� �஢�ઠ ���祭�� �����
  // NSI_EL, �����(20), ��� ����� ��ꥪ� ���, �� ᮮ⢥��⢨� � 
  //      ����� �����⢫���� �஢�ઠ ���祭�� �����
  // USL_TEST, �����(254),	�᫮��� �஢������ �஢�ન �����
  // VAL_EL, �����(254),	������⢮ �����⨬�� ���祭�� �����
  // COMMENT, �����(500), �������਩
  // DATEBEG, �����(10),	��� ��砫� ����⢨� �����
  // DATEEND, �����(10),	��� ����砭�� ����⢨� �����

  static _Q016
  local db
  local aTable
  local nI

  if _Q016 == nil
    _Q016 := hb_hash()

    db := openSQL_DB()
    aTable := sqlite3_get_table( db, 'SELECT id_test, id_el, nsi_obj, nsi_el, usl_test, val_el, comment, datebeg, dateend FROM q016' )
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        hb_hSet(_Q016, alltrim(upper(aTable[nI, 1])), {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), alltrim(aTable[nI, 5]), alltrim(aTable[nI, 6]), alltrim(aTable[nI, 7]), ctod(aTable[nI, 8]), ctod(aTable[nI, 9])})
      next
    endif
    db := nil
  endif
  return _Q016

** 21.12.21 ������ ���ᨢ ����� Q016.xml
function loadQ016_1()
  // �����頥� ���-���ᨢ ����� ��⥣�਩ �஢�ப ��� � ���
  // <key> - �����䨪��� �ࠢ��� �஢�ન
  // <value> - ���ᨢ
  static _Q016
  Local dbName, dbAlias := 'Q016'
  local tmp_select := select()

  // Q016.dbf - ���祭� �孮�����᪨� �ࠢ�� ॠ����樨 ��� � �� ������� ���ᮭ���஢������ ��� ᢥ����� �� ��������� ����樭᪮� ����� (FLK_MPF)
  //  1 - KOD(C)  2 - NAME(C) 3 - NSI_OBJ(C)  4 - NSI_EL(C) 5 - USL_TEST(M) 6 - VAL_EL(M) 7 - COMMENT(M)  8 - DATEBEG(D)  9 - DATEEND(D)

  if _Q016 == nil
    _Q016 := hb_hash()
    dbName := '_mo_Q016'
    tmp_select := select()
    dbUseArea(.t., 'DBFNTX', exe_dir + dbName, dbAlias , .t., .f.)

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      hb_hSet(_Q016, alltrim(upper((dbAlias)->KOD)), {alltrim((dbAlias)->NAME), alltrim((dbAlias)->NSI_OBJ), alltrim((dbAlias)->NSI_EL), alltrim((dbAlias)->USL_TEST), alltrim((dbAlias)->VAL_EL), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND})
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _Q016

* 21.05.21 ������ ���ᨢ � ���ᠭ��� �孮�����᪮�� �ࠢ��� ॠ����樨 ��� �� �ࠢ�筨�� ����� Q016.xml
function getRuleCheckErrorByID_Q016_1(idRule)
  // idRule - �����䨪��� �ࠢ��� �஢�ન
  // arr[1] - ������������ ��⥣�ਨ �஢�ન
  // arr[2] - ��� ��ꥪ� ���, �� ᮮ⢥��⢨� � ����� �����⢫���� �஢�ઠ ���祭�� �����
  // arr[3] - ��� ����� ��ꥪ� ���, �� ᮮ⢥��⢨� � ����� �����⢫���� �஢�ઠ ���祭�� �����
  // arr[4] - �᫮��� �஢������ �஢�ન �����
  // arr[5] - ������⢮ �����⨬�� ���祭�� �����
  // arr[6] - �������਩
  // arr[7] - ��� ��砫� ����⢨� ��⥣�ਨ �஢�ન
  // arr[8] - ��� ����砭�� ����⢨� ��⥣�ਨ �஢�ન
  local arrRules := loadQ016()
  local rule := alltrim(upper(idRule))
  local aRet := {}

  if hb_hHaskey(arrRules, rule)
    aRet := arrRules[rule]
  else
    AAdd(aRet, '�������⭮� �ࠢ��� �஢�ન � �����䨪��஬: ' + rule)
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, '')
    AAdd(aRet, ctod('  /  /    '))
    AAdd(aRet, ctod('  /  /    '))
  endif

  return aRet

