* 31.01.23 вернуть массив по справочнику Минздрава РФ OID 1.2.643.5.1.13.13.11.1468_2.1.xml
function getMethodINJ()
  // OID 1.2.643.5.1.13.13.11.1468_2.1.xml - Пути введения лекарственных препаратов
  //  1 - ID(N) 2 - NAME_RUS(C) 3 - NAME_ENG(C) 4 - PARENT(N) 5 - TYPE(C)
  static _arr := {}
  local dBegin := 0d20220101, dEnd := 0d20241231  // для совместимости
  local cmdText
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    cmdText := 'SELECT id, ' + ;
        iif(mem_methodinj == 0, 'name_rus, ', 'name_eng, ') + ;
        'parent, type FROM MethIntro WHERE type = "L"'
    aTable := sqlite3_get_table(db, cmdText)
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ;
            dBegin, dEnd, alltrim(aTable[nI, 3])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    asort(_arr,,,{|x, y| x[1] < y[1] })
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
