* 15.08.21 ������ ���ᨢ �� �ࠢ�筨�� ����� V021.xml
function getV021()
  // V021.xml - �����䨪��� ����樭᪨� ᯥ樠�쭮�⥩ (�������⥩) (MedSpec)
  //  1 - SPECNAME(C)  2 - IDSPEC(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - POSTNAME(C)  6 - IDPOST_MZ(C)
  local dbName := "_mo_v021"
  Local dbAlias := 'V021'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      if Empty((dbName)->DATEEND)
        aadd(_arr, { alltrim((dbName)->SPECNAME), (dbName)->IDSPEC, (dbName)->DATEBEG, (dbName)->DATEEND, alltrim((dbName)->POSTNAME), alltrim((dbName)->IDPOST_MZ) })
      endif
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

