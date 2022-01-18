* 18.01.22 вернуть массив по справочнику ФФОМС V037.xml
function getV037()
  // V037.xml - Перечень методов ВМП, требующих имплантацию медицинских изделий
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

***** 18.01.22 вернуть массив метода ВМП, требующих имплантации
Function ret_impl_V037(s_code, lk_data)
  // s_code - код ВМП метода
  // lk_data - дата оказания услуги
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
