
* 05.04.21 ������ ���ᨢ �訡�� ����� T005.dbf
function loadT005()
  // �����頥� ���-���ᨢ
  // <key> - �����䨪���
  // <value> - ���ᨢ {'������������ �訡��'}
  static _T005 := {}
  Local dbName, dbAlias := 'T005'
  local tmp_select := select()

  // T005.dbf - ���祭� �訡�� �����
  //  1 - KOD(3)  2 - NAME(C)
  if len(_T005) == 0
    // _T005 := hb_hash()
    dbName := '_mo_T005'
    tmp_select := select()
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      AAdd(_T005, {(dbAlias)->KOD, alltrim((dbAlias)->NAME)} )

      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _T005

* 05.04.21 ������ ��ப� ��� ���� ��䥪� � ���ᠭ��� �訡�� ����� �� �ࠢ�筨�� T005.dbf
Function ret_t005(lkod)
  local arrErrors := loadT005()
  local aRet := {}, i


  if (i := hb_ascan(arrErrors, {|x| x[1] == lkod})) > 0
    return arrErrors[i,2]
  endif

  return '�������⭠� ��⥣��� �஢�ન � �����䨪��஬: ' + str(lkod)
