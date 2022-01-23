******* 23.01.22 вернуть массив по справочнику Минздрава OID 1.2.643.5.1.13.13.11.1358_*.*.xml (единицы измерений)
function get_ed_izm()
  // OID 1.2.643.5.1.13.13.11.1358_*.*.xml - Единицы измерения
  //  2 - ID(N)       // Уникальный идентификатор единицы измерения лабораторного теста, целое число
  //  3 - FULLNAME(C) // Полное наименование, Строчный
  //  4 - SHOTNAME(C) // Краткое наименование, Строчный;
  //  5 - PRNNAME(C)  // Наименование для печати, Строчный;
  //  6 - MEASUR(C)   // Размерность, Строчный;
  //  7 - UCUM(C)     // Код UCUM, Строчный;
  //  8 - COEF(C)     // Коэффициент пересчета, Строчный, Коэффициент пересчета в рамках одной размерности.;
  //  9 - CONV_ID(N)  // Код единицы измерения для пересчета, Целочисленный, Код единицы измерения, в которую осуществляется пересчет.;
  // 10 - CONV_NAM(C) // Единица измерения для пересчета, Строчный, Краткое наименование единицы измерения, в которую осуществляется пересчет.;
  // 11 - OKEI_COD(N) // Код ОКЕИ, Строчный, Соответствующий код Общероссийского классификатора единиц измерений.;

  local dbName := '_mo_ed_izm'
  Local dbAlias := '_ED_IZM'
  local tmp_select := select()
  static _arr := {}

  if len(_arr) == 0
    dbUseArea( .t.,, exe_dir + dbName, dbAlias, .f., .f. )
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if mem_n_V034 == 0
         aadd(_arr, { alltrim((dbAlias)->SHOTNAME), (dbAlias)->ID })
      else
        aadd(_arr, { alltrim((dbAlias)->FULLNAME), (dbAlias)->ID })
      endif  
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return _arr

***** 23.01.22 вернуть наименование единицы измерения
Function ret_ed_izm(id)
  // id - код единицы измерения
  Local i, ret := ''
  // local code

  if ValType(id) == 'C'
    id:= val(alltrim(id))
  elseif ValType(id) == 'N'
    // id := id
  else
    return ret
  endif
  
  if !empty(id) .and. ((i := ascan(get_ed_izm(), {|x| x[2] == id })) > 0)
    ret := get_ed_izm()[i, 1]
  endif
  return ret
