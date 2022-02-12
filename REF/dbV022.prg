***** 11.02.21
// возвращает массив V022
function getV022table()
  Local dbName, dbAlias := 'V022'
  local tmp_select := select()
  static _arr := {}
  
  if len(_arr) == 0
    tmp_select := select()
    dbName := '_mo_V022'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    // 1 - IDMPAC(N)  2 - MPACNAME(C)  3 - DATEBEG(D)  4 - DATEEND(D)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(_arr, { (dbAlias)->IDMPAC, alltrim((dbAlias)->MPACNAME), (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    asort(_arr,,,{|x,y| x[1] < y[1] })

    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return _arr

***** 11.02.21 вернуть строку модели пациента ВМП
Function ret_V022(idmpac,lk_data)
  Local i, s := space(10)
  local aV022 := getV022table()

  // make_V018_V019(lk_data)
  if !empty(idmpac) .and. ((i := ascan(aV022, {|x| x[1] == idmpac })) > 0)
    s := aV022[i,2]
  endif
  return s

***** 11.02.21 действия в ответ на выбор в меню "Вид модели пациента ВМП"
// Function f_valid_mmodpac(get,old)
//   if empty(m1modpac)
//     mmodpac := space(67) ; m1modpac := 0
//     update_get("mmodpac")
//   elseif !(m1modpac == old) .and. old != NIL .and. get != NIL
//     mmodpac := space(67) ; m1modpac := 0
//     update_get("mmodpac")
//   endif
//   return .t.
