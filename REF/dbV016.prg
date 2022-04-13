* 12.12.21 ������ �����䨪��� ����� ��ᯠ��ਧ�樨/���ᬮ�஢ V016.xml
function getV016()
  // V016.xml - �����䨪��� ����� ��ᯠ��ਧ�樨/���ᬮ�஢
  Local dbName, dbAlias := 'V016'
  local tmp_select := select()
  local ar := {}
  static _arr := {}

  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_v016'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - IDDT(C)  2 - DTNAME(C)  3 - RULE(C)  4 - DATEBEG(D)  5 - DATEEND(D)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      ar := list2Arr((dbAlias)->RULE)
      aadd(_arr, { (dbAlias)->IDDT, (dbAlias)->DTNAME, ar, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

**** 13.12.21 ������ ����⥫� ⨯� ��ᯭ�ਧ�樨 �� ����
function get_type_DispT(mdate, codeDispT)
  local dispT := Upper(alltrim(codeDispT))
  local _arr := {}, i
  local tmpArr := getV016()
  local lengthArr := len(tmpArr)

  for i := 1 to lengthArr
    if dispT == tmpArr[i, 1] .and. between_date(tmpArr[i, 4], tmpArr[i, 5], mdate)
      aadd(_arr, tmpArr[i, 1])
      aadd(_arr, tmpArr[i, 2])
      aadd(_arr, tmpArr[i, 3])
    endif
  next
  return _arr