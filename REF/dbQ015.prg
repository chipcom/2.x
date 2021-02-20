#include "hbhash.ch" 

// �� ������ ������쭮� ��६����� glob_Q015
// �஢��� � �������� �����
//

* 20.02.21 ������ ���ᨢ ����� Q015.xml
function loadQ015()
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
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      hb_hSet( _Q015, alltrim(upper((dbAlias)->KOD)), {alltrim((dbAlias)->NAME), alltrim((dbAlias)->NSI_OBJ), alltrim((dbAlias)->NSI_EL), alltrim((dbAlias)->USL_TEST), alltrim((dbAlias)->VAL_EL), alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND} )
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

  if hb_hHaskey( arrRules, rule )
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