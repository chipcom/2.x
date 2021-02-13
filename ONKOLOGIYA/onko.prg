
***** 13.02.21
Function ret_arr_shema(k) 
  // возвращает схемы лекарственных терапий для онкологии на текущий рабочий год
  Static ashema := {{},{},{}}
  Local i
  if empty(ashema[1])
    Private _data := 0d20210101 // 2021 год
    R_Use(exe_dir+"_mo1shema",,"IT")
    aadd(ashema[1],{"-----     без схемы лекарственной терапии",padr("нет",10)})
    index on kod to (cur_dir+"tmp_schema") for left(kod,2) == "sh" .and. between_date(it->datebeg,it->dateend,_data)
    dbeval({|| aadd(ashema[1],{it->kod+left(it->name,68),it->kod}) })
    index on kod to (cur_dir+"tmp_schema") for left(kod,2) == "mt" .and. between_date(it->datebeg,it->dateend,_data)
    dbeval({|| aadd(ashema[2],{it->kod+left(it->name,68),it->kod}) })
    index on kod to (cur_dir+"tmp_schema") for left(kod,2) == "fr" .and. between_date(it->datebeg,it->dateend,_data)
    dbeval({|| aadd(ashema[3],{it->kod+left(it->name,68),it->kod,0,0}) })
    use
    for i := 1 to len(ashema[3])
      ashema[3,i,3] := int(val(substr(ashema[3,i,1],3,2)))
      ashema[3,i,4] := int(val(substr(ashema[3,i,1],6,2)))
    next
  endif
  return ashema[k]

