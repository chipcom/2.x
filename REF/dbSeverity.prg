* 04.01.22 вернуть массив по справочнику Минздрава по Степень тяжести состояния пациента OID 1.2.643.5.1.13.13.11.1006.xml
function get_severity()
  Local dbName, dbAlias := 'sev'
  local tmp_select := select()
  static _arr := {}


  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_severity'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    //  1 - ID(N) 2 - NAME(C) 3 - SYN(C) 4 - SCTID(N) 5 - SORT(N)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if (dbAlias)->ID <= 4  // пока только до 4 степени тяжести
        aadd(_arr, { alltrim((dbAlias)->NAME), (dbAlias)->ID, alltrim((dbAlias)->SYN), (dbAlias)->SCTID, (dbAlias)->SORT })
      endif
      (dbAlias)->(dbSkip())
    enddo

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

***** 08.01.22 вернуть описание тяжести состояния пациента
Function ret_severity_name(s_code)
  // s_code - код тяжести
  Local i, ret := ''
  local code
  
  if ValType(s_code) == 'C'
    code := val(s_code)
  elseif ValType(s_code) == 'N'
    code := s_code
  else
    return ret
  endif

  if !empty(code) .and. ((i := ascan(get_severity(), {|x| x[2] == code })) > 0)
    ret := get_severity()[i, 1]
  endif
  return ret
