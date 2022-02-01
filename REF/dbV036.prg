* 29.12.21 вернуть массив по справочнику ФФОМС V036.xml
function getV036()
  // V036.xml - Перечень услуг, требующих имплантацию медицинских изделий (ServImplDv)
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

***** 01.02.22 вернуть массив услуга для имплантации
Function ret_impl_V036(s_code, lk_data)
  // s_code - код федеральной услуги
  // lk_data - дата оказания услуги
  Local i, retArr := nil
  local code := alltrim(s_code)

  if !empty(code) .and. ((i := ascan(getV036(), {|x| x[1] == code })) > 0)
  // if !empty(code) .and. ((i := ascan(getV036(), {|x| x[1] == code .and. x[3] == 2 })) > 0)
    retArr := getV036()[i]
  endif
  return retArr
