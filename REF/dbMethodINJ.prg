* 13.01.22 вернуть массив по справочнику Минздрава РФ OID 1.2.643.5.1.13.13.11.1468_2.1.xml
function getMethodINJ()
  // OID 1.2.643.5.1.13.13.11.1468_2.1.xml - Пути введения лекарственных препаратов
  //  1 - ID(N) 2 - NAME_RUS(C) 3 - NAME_ENG(C) 4 - PARENT(N) 5 - TYPE(C)
  local dbName := '_mo_method_inj'
  Local dbAlias := 'INJ'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if (dbAlias)->TYPE == 'L'
        //aadd(_arr, { alltrim((dbAlias)->NAME_RUS), (dbAlias)->ID,  (dbAlias)->PARENT, (dbAlias)->TYPE })
        if mem_methodinj == 0
          aadd(_arr, { alltrim((dbAlias)->NAME_RUS), (dbAlias)->ID, ctod(""),ctod("") , (dbAlias)->PARENT})
        else
          aadd(_arr, { alltrim((dbAlias)->NAME_ENG), (dbAlias)->ID, ctod(""), ctod(""),  (dbAlias)->PARENT})  
        endif  
      endif
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    asort(_arr, , , {|x, y| x[1] < y[1] })  // отсортируем для удобства использования
  endif
  return _arr

***** 13.01.22 вернуть наименование метода введения препарата
Function ret_meth_method_inj(s_code)
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

  if !empty(code) .and. ((i := ascan(getMethodINJ(), {|x| x[2] == code })) > 0)
    ret := getMethodINJ()[i, 1]
  endif
  return ret
