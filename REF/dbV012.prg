** 22.10.22 ������ ��室 ����������� �� ����
function getISHOD_V012( ishod )
  local ret := NIL
  local i

  // if (i := ascan(glob_V012, {|x| x[2] == ishod })) > 0
    // ret := glob_V012[i,1]
  if (i := ascan(getV012(), {|x| x[2] == ishod })) > 0
    ret := getV012()[i,1]
  endif
  return ret

** 18.05.22 ������ ��室 ����������� �� �᫮��� �������� � ���
function getISHOD_usl_date(uslovie, date)
  local ret := {}
  local row

  for each row in getV012()
    if (empty(row[4]) .and. date >= row[3]) .or. between_date(row[3], row[4], date)
      if uslovie == row[5]
        aadd(ret, {row[1], row[2], row[3], row[4], row[5]})
      endif
    endif
  next
  return ret

* 11.12.21 ������ ���ᨢ �� �ࠢ�筨�� ����� V012.xml
function getV012()
  // V012.xml - �����䨪��� ��室�� �����������
  Local dbName, dbAlias := 'V012'
  local tmp_select := select()
  local stroke := '', vid := ''
  static _arr := {}

  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_v012'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - IZNAME(C)  2 - IDIZ(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DL_USLOV(N)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if empty((dbAlias)->DATEEND)  // ⮫쪮 �᫨ ���� ����砭�� ����⢨� ����
        if (dbAlias)->DL_USLOV == 1
          vid := '/��-�/'
        elseif (dbAlias)->DL_USLOV == 2
          vid := '/��.�/'
        elseif (dbAlias)->DL_USLOV == 3
          vid := '/�-��/'
        else
          vid := '/'
        endif
        stroke := str((dbAlias)->IDIZ, 3) + vid + alltrim((dbAlias)->IZNAME)
        aadd(_arr, { stroke, (dbAlias)->IDIZ, (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->DL_USLOV })
      endif
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _arr 