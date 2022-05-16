* 18.01.22 ������ ���ᨢ �� �ࠢ�筨�� ����� V037.xml
function getV037()
  // V037.xml - ���祭� ��⮤�� ���, �ॡ���� ��������� ����樭᪨� �������
  //  1 - CODE(N) 2 - NAME(C) 3 - PARAM(N) 4 - COMMENT(C) 5 - DATEBEG(D) 6 - DATEEND(D)
  local dbName := '_mo_v037'
  Local dbAlias := 'V037'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(_arr, { (dbAlias)->CODE, alltrim((dbAlias)->NAME), (dbAlias)->PARAM, alltrim((dbAlias)->COMMENT), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    asort(_arr,,,{|x, y| x[1] < y[1] })
    Select(tmp_select)
  endif

  return _arr

***** 18.01.22 ������ ���ᨢ ��⮤� ���, �ॡ���� �������樨
Function ret_impl_V037(s_code, lk_data)
  // s_code - ��� ��� ��⮤�
  // lk_data - ��� �������� ��㣨
  Local i, retArr := ''
  local code

  if ValType(s_code) == 'C'
    code:= val(alltrim(s_code))
  elseif ValType(s_code) == 'N'
    code := s_code
  else
    return retArr
  endif

  if !empty(code) .and. ((i := ascan(getV037(), {|x| x[1] == code .and. x[3] == 2 })) > 0)
    retArr := getV037()[i]
  endif
  return retArr
