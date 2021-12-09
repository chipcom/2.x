* 08.12.21 ������ ���ᨢ �� �ࠢ�筨�� ����� V020.xml - �����䨪��� ��䨫�� �����
function getV020()
  Local dbName, dbAlias := 'V020'
  local tmp_select := select()
  static _arr := {}


  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_v020'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - K_PRNAME(C)  2 - IDK_PR(N)  3 - DATEBEG(D)  4 - DATEEND(D)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(_arr, { alltrim((dbAlias)->K_PRNAME), (dbAlias)->IDK_PR, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr