* 29.12.21 ������ ���ᨢ �� �ࠢ�筨�� ����� V036.xml
function getV036()
  // V036.xml - ���祭� ���, �ॡ���� ��������� ����樭᪨� ������� (ServImplDv)
  //  1 - S_CODE(C) 2 - NAME(C) 3 - PARAM(N) 4 - COMMENT(C) 5 - DATEBEG(D) 6 - DATEEND(D)
  local dbName := '_mo_v036'
  Local dbAlias := 'V036'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(_arr, { alltrim((dbAlias)->S_CODE), alltrim((dbAlias)->NAME), (dbAlias)->PARAM, alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

***** 01.02.22 ������ ���ᨢ ��㣠 ��� �������樨
Function ret_impl_V036(s_code, lk_data)
  // s_code - ��� 䥤�ࠫ쭮� ��㣨
  // lk_data - ��� �������� ��㣨
  Local i, retArr := nil
  local code := alltrim(s_code)

  if !empty(code) .and. ((i := ascan(getV036(), {|x| x[1] == code .and. (x[3] == 1 .or. x[3] == 3) })) > 0) // ᮣ��᭮ ���� 04-18-03 �� 31.01.2022
    retArr := getV036()[i]
  endif
  return retArr

***** 12.03.22 ��㣠 �ॡ�� ������⠭��
Function service_requires_implants(s_code, lk_data)
  // s_code - ��� 䥤�ࠫ쭮� ��㣨
  // lk_data - ��� �������� ��㣨
  Local i, fl := .f.
  local code := alltrim(s_code)

  if !empty(code) .and. ((i := ascan(getV036(), {|x| x[1] == code .and. (x[3] == 1 .or. x[3] == 3) })) > 0) // ᮣ��᭮ ���� 04-18-03 �� 31.01.2022
    fl := .t.
  endif
  return fl
