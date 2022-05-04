* 07.01.22 вернуть массив по справочнику ФФОМС V034.xml
function getV034()
  // V034.xml - Единицы измерения (UnitMeas)
  //  1 - UNITCODE(N) 2 - UNITMEAS(C) 3 - SHORTTIT(C)  4 - DATEBEG(D)  5 - DATEEND(D)
  local dbName := '_mo_v034'
  Local dbAlias := 'V034'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      //aadd(_arr, { alltrim((dbAlias)->SHORTTIT), (dbAlias)->UNITCODE, (dbAlias)->DATEBEG, (dbAlias)->DATEEND, alltrim((dbAlias)->UNITMEAS) })
      if mem_n_V034 == 0
         aadd(_arr, { alltrim((dbAlias)->SHORTTIT), (dbAlias)->UNITCODE, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      else
        aadd(_arr, { alltrim((dbAlias)->UNITMEAS), (dbAlias)->UNITCODE, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      endif  
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

***** 12.01.22 вернуть наименование единицы измерения
Function ret_ed_izm_V034(s_code)
  // s_code - код схемы
  Local i, ret := ''
  local code

  if ValType(s_code) == 'C'
    code:= val(alltrim(s_code))
  elseif ValType(s_code) == 'N'
    code := s_code
  else
    return ret
  endif
  
  if !empty(code) .and. ((i := ascan(getV034(), {|x| x[2] == code })) > 0)
    ret := getV034()[i, 1]
  endif
  return ret
