* 07.01.22 вернуть массив по справочнику ФФОМС V035.xml
function getV035()
  // V035.xml - Способы введения (MethIntro)
  //  1 - METHCODE(N) 2 - METHNAME(C) 3 - DATEBEG(D) 4 - DATEEND(D)
  local dbName := '_mo_v035'
  Local dbAlias := 'V035'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbName, .f., .f. )
    (dbName)->(dbGoTop())
    do while !(dbName)->(EOF())
      aadd(_arr, { alltrim((dbName)->METHNAME), (dbName)->METHCODE, (dbName)->DATEBEG, (dbName)->DATEEND })
      (dbName)->(dbSkip())
    enddo
    (dbName)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _arr

***** 07.01.22 вернуть наименование метода введения препарата
Function ret_meth_V035(s_code)
  // s_code - код метода
  Local i, ret := ''
  local code
  
  if ValType(s_code) == 'C'
    code := val(s_code)
  elseif ValType(s_code) == 'N'
    code := s_code
  else
    return ret
  endif

  if !empty(code) .and. ((i := ascan(getV035(), {|x| x[2] == code })) > 0)
    ret := getV035()[i, 1]
  endif
  return ret
