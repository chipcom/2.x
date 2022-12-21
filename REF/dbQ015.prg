#include 'hbhash.ch' 

#require 'hbsqlit3'

** 21.12.22 ������ ���ᨢ ����� Q015.xml
function loadQ015()
  // �����頥� ���-���ᨢ ����� ��⥣�਩ �஢�ப ��� � ���
  // <key> - �����䨪��� �ࠢ��� �஢�ન
  // <value> - ���ᨢ

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

  static _Q015
  local db
  local aTable
  local nI
  if _Q015 == nil
    _Q015 := hb_hash()

    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT id_test, id_el, nsi_obj, nsi_el, usl_test, val_el, comment, datebeg, dateend FROM q015')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        hb_hSet(_Q015, alltrim(upper(aTable[nI, 1])), {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4]), alltrim(aTable[nI, 5]), alltrim(aTable[nI, 6]), alltrim(aTable[nI, 7]), ctod(aTable[nI, 8]), ctod(aTable[nI, 9])})
      next
    endif
    db := nil

  endif
  return _Q015

** 21.12.22 ������ ���ᨢ ����� Q015.xml
function loadQ015_1()
  // �����頥� ���-���ᨢ ����� ��⥣�਩ �஢�ப ��� � ���
  // <key> - �����䨪��� �ࠢ��� �஢�ન
  // <value> - ���ᨢ
  static _Q015
  Local dbName, dbAlias := 'Q015'
  local tmp_select := select()

  // Q015.dbf - ���祭� �孮�����᪨� �ࠢ�� ॠ����樨 ��� � �� ������� ���ᮭ���஢������ ��� ᢥ����� �� ��������� ����樭᪮� ����� (FLK_MPF)
  //  1 - KOD(C)  2 - NAME(C) 3 - NSI_OBJ(C)  4 - NSI_EL(C) 5 - USL_TEST(M) 6 - VAL_EL(M) 7 - COMMENT(M)  8 - DATEBEG(D)  9 - DATEEND(D)

  if _Q015 == nil
    _Q015 := hb_hash()
    dbName := '_mo_Q015'
    tmp_select := select()
    dbUseArea(.t., 'DBFNTX', exe_dir + dbName, dbAlias , .t., .f.)

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      hb_hSet(_Q015, alltrim(upper((dbAlias)->KOD)), {alltrim((dbAlias)->NAME), alltrim((dbAlias)->NSI_OBJ), alltrim((dbAlias)->NSI_EL), alltrim((dbAlias)->USL_TEST), alltrim((dbAlias)->VAL_EL), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND})
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _Q015

* 20.02.21 ������ ���ᨢ � ���ᠭ��� �孮�����᪮�� �ࠢ��� ॠ����樨 ��� �� �ࠢ�筨�� ����� Q015.xml
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
  local arrRules := loadQ015()
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