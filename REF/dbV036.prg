* 29.12.21 ������ ���ᨢ �� �ࠢ�筨�� ����� V036.xml
function getV036()
  // V036.xml - ���祭� ���, �ॡ���� ��������� ����樭᪨� ������� (ServImplDv)
  //  1 - S_CODE(C) 2 - NAME(C) 3 - PARAM(N) 4 - COMMENT(C) 5 - DATEBEG(D) 6 - DATEEND(D)
  local dbName := '_mo_v036'
  Local dbAlias := 'V036'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { alltrim((dbName)->S_CODE), alltrim((dbName)->NAME), (dbName)->PARAM, alltrim((dbName)->COMMENT), (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

***** 01.01.22 ������ ���ᨢ ��㣠 ��� �������樨
Function ret_impl_V036(s_code, lk_data)
  // s_code - ��� 䥤�ࠫ쭮� ��㣨
  // lk_data - ��� �������� ��㣨
  Local i, retArr := nil
  local code := alltrim(s_code)

  if !empty(code) .and. ((i := ascan(getV036(), {|x| x[1] == code .and. x[3] == 2 })) > 0)
    retArr := getV036()[i]
  endif
  return retArr