#include 'hbhash.ch' 

#require 'hbsqlit3'

** 22.12.22 ������ ���ᨢ � ���ᠭ��� ��⥣�ਨ �஢�ન �� �����䨪���� ��⥣�ਨ �஢�ન �� �ࠢ�筨�� ����� Q017.xml
function getCategoryCheckErrorByID_Q017(idCategory)
  // idError - �����䨪��� ��⥣�ਨ �஢�ન
  // arr[1] - ������������ ��⥣�ਨ �஢�ન
  // arr[2] - �������਩
  // arr[3] - ��� ��砫� ����⢨� ��⥣�ਨ �஢�ન
  // arr[4] - ��� ����砭�� ����⢨� ��⥣�ਨ �஢�ન
  // arr[5] - �����䨪��� ��⥣�ਨ �஢�ન

  // Q017 - ���祭� ��⥣�਩ �஢�ப ��� � ��� (TEST_K)
  // ID_KTEST, �����(4),	�����䨪��� ��⥣�ਨ �஢�ન
  // NAM_KTEST, �����(400),	������������ ��⥣�ਨ �஢�ન
  // COMMENT, �����(500), �������਩
  // DATEBEG, �����(10),	��� ��砫� ����⢨� �����
  // DATEEND, �����(10),	��� ����砭�� ����⢨� �����

  local db
  local stmt 
  local category := alltrim(upper(idCategory))
  local aRet := {}

  db := openSQL_DB()

  stmt := sqlite3_prepare(db, 'SELECT id_ktest, nam_ktest, comment, datebeg, dateend FROM q017 WHERE id_ktest == :id_ktest')
  sqlite3_bind_text(stmt, 1, category)
  Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
  do while sqlite3_step(stmt) == SQLITE_ROW
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 2), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 3), 'RU866'))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 4)))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 5)))
    AAdd(aRet, sqlite3_column_text(stmt, 1))
  enddo
  Set(_SET_DATEFORMAT, 'dd.mm.yyyy')

  sqlite3_clear_bindings(stmt)
  sqlite3_finalize(stmt)

  db := nil

  if len(aRet) == 0
    AAdd(aRet, '�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + category)
    AAdd(aRet, '')
    AAdd(aRet, ctod('  /  /    '))
    AAdd(aRet, ctod('  /  /    '))
    AAdd(aRet, '')
  endif

  return aRet

* 22.12.22 ������ ���ᨢ � ���ᠭ��� �孮�����᪮�� �ࠢ��� ॠ����樨 ��� �� �ࠢ�筨�� ����� Q015.xml
function getRuleCheckErrorByID_Q015(idRule)
  // idRule - �����䨪��� �ࠢ��� �஢�ન
  // arr[1] - ������������ ��⥣�ਨ �஢�ન
  // arr[2] - ��� ��ꥪ� ���, �� ᮮ⢥��⢨� � ����� �����⢫���� �஢�ઠ ���祭�� �����
  // arr[3] - ��� ����� ��ꥪ� ���, �� ᮮ⢥��⢨� � ����� �����⢫���� �஢�ઠ ���祭�� �����
  // arr[4] - �᫮��� �஢������ �஢�ન �����
  // arr[5] - ������⢮ �����⨬�� ���祭�� �����
  // arr[6] - �������਩
  // arr[7] - ��� ��砫� ����⢨� ��⥣�ਨ �஢�ન
  // arr[8] - ��� ����砭�� ����⢨� ��⥣�ਨ �஢�ન
  // arr[8] - �����䨪��� �ࠢ��� �஢�ન

  // Q015 - ���祭� �孮�����᪨� �ࠢ�� ॠ����樨 ��� � �� ������� ���ᮭ���஢������ ��� ᢥ����� �� ��������� ����樭᪮� ����� (FLK_MPF)
  // ID_TEST, �����(12), �����䨪��� �஢�ન.
  //      ��ନ����� �� 蠡���� KKKK.00.TTTT, ���
  //      KKKK - �����䨪��� ��⥣�ਨ �஢�ન 
  //        � ᮮ⢥��⢨� � �����䨪��஬ Q017,
  //      TTTT - 㭨����� ����� �஢�ન � ��⥣�ਨ
  // ID_EL, �����(100),	�����䨪��� �����, 
  //      �������饣� �஢�થ (�ਫ������ �, �����䨪��� Q018)
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
  // MIN_LEN, �����᫥���(4),	�������쭠� ����� ���祭�� �����
  // MAX_LEN, �����᫥���(4),	���ᨬ��쭠� ����� ���祭�� �����
  // MASK_VAL, �����(254),	��᪠ ���祭�� �����
  // COMMENT, �����(500), �������਩
  // DATEBEG, �����(10),	��� ��砫� ����⢨� �����
  // DATEEND, �����(10),	��� ����砭�� ����⢨� �����

  local db
  local stmt 
  local rule := alltrim(upper(idRule))
  local aRet := {}

  db := openSQL_DB()

  stmt := sqlite3_prepare(db, 'SELECT id_test, id_el, nsi_obj, nsi_el, usl_test, val_el, comment, datebeg, dateend FROM q015 WHERE id_test == :id_test')
  sqlite3_bind_text(stmt, 1, rule)
  Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
  do while sqlite3_step(stmt) == SQLITE_ROW
    AAdd(aRet, sqlite3_column_text(stmt, 2))
    AAdd(aRet, sqlite3_column_text(stmt, 3))
    AAdd(aRet, sqlite3_column_text(stmt, 4))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 5), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 6), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 7), 'RU866'))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 8)))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 9)))
    AAdd(aRet, sqlite3_column_text(stmt, 1))
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
    AAdd(aRet, '')
  endif

  return aRet

** 22.12.22 ������ ���ᨢ � ���ᠭ��� �孮�����᪮�� �ࠢ��� ॠ����樨 ��� �� �ࠢ�筨�� ����� Q016.xml
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
  // arr[8] - �����䨪��� �ࠢ��� �஢�ન

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
  
  local db
  local stmt 
  local rule := alltrim(upper(idRule))
  local aRet := {}

  db := openSQL_DB()

  stmt := sqlite3_prepare(db, 'SELECT id_test, id_el, nsi_obj, nsi_el, usl_test, val_el, comment, datebeg, dateend FROM q016 WHERE id_test == :id_test')
  sqlite3_bind_text(stmt, 1, rule)
  Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
  do while sqlite3_step(stmt) == SQLITE_ROW
    AAdd(aRet, sqlite3_column_text(stmt, 2))
    AAdd(aRet, sqlite3_column_text(stmt, 3))
    AAdd(aRet, sqlite3_column_text(stmt, 4))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 5), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 6), 'RU866'))
    AAdd(aRet, hb_Utf8ToStr(sqlite3_column_blob(stmt, 7), 'RU866'))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 8)))
    AAdd(aRet, ctod(sqlite3_column_text(stmt, 9)))
    AAdd(aRet, sqlite3_column_text(stmt, 1))
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
      AAdd(aRet, '')
  endif

  return aRet
