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

***** 11.02.21 в GET-е вернуть строку из glob_V022
Function f_get_mmodpac(k, r, c, lvidvmp, sDiag)
  Local arr := {}, i, ret, ret_arr
  local diag := alltrim(sDiag)
  local model := getV022table()
  local row

  if empty(lvidvmp) .or. empty(diag)
    return NIL
  endif

  make_V018_V019(mk_data)
  for i := 1 to len(glob_V019)
    if glob_V019[i,4] == alltrim(lvidvmp) .and. ( ascan(glob_V019[i,3],diag) > 0 )
      for each row in model
        if row[1] == glob_V019[i,8]
          if ascan(arr, {|x| x[2] == row[1] }) == 0
            aadd(arr, {padr(alltrim(row[2]),76),row[1]})
            exit
          endif
        endif
      next
    endif
  next
  if empty(arr)
    func_error(4,"В справочнике V022 не найдено моделей пациентов для вида ВМП "+lvidvmp)
    return NIL
  endif
  popup_2array(arr,-r,c,k,1,@ret_arr,"Выбор модели пациента для "+lvidvmp,"GR+/RB*","N/RB*,W+/N")
  if valtype(ret_arr) == "A"
    ret := array(2)
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
return ret

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
  
***** 11.02.21 вернуть строку модели пациента ВМП
Function ret_V022(idmpac,lk_data)
  Local i, s := space(10)
  local aV022 := getV022table()

  // make_V018_V019(lk_data)
  if !empty(idmpac) .and. ((i := ascan(aV022, {|x| x[1] == idmpac })) > 0)
    s := aV022[i,2]
  endif
  return s
  
    