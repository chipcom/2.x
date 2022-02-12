
***** 10.02.22
Function make_V018_V019(lk_data)
  // lk_data - дата на которую необходимо создать массивы ВМП
  Static sy := 0, sd2018 := 0d20180101, sd2019 := 0d20190101, sd2020 := 0d20200101
  static sd2021 := 0d20210101, sd2022 := 0d20220101
  Local i, y := year(lk_data)
  local aaaa
  
  if sy != y
    sy := y
    glob_V018 := {}
    for i := 1 to len(_glob_V018)
      if y > 2021
        if between_date(_glob_V018[i, 3], _glob_V018[i, 4], sd2022)
          aadd(glob_V018, aclone(_glob_V018[i]))
        endif
      elseif y == 2021
        if between_date(_glob_V018[i, 3], _glob_V018[i, 4], sd2021)
          aadd(glob_V018, aclone(_glob_V018[i]))
        endif
      elseif y == 2020
        if between_date(_glob_V018[i,3],_glob_V018[i,4],sd2020)
          aadd(glob_V018, aclone(_glob_V018[i]))
        endif
      elseif y == 2019
        if between_date(_glob_V018[i,3],_glob_V018[i,4],sd2019)
          aadd(glob_V018, aclone(_glob_V018[i]))
        endif
      else
        if between_date(_glob_V018[i,3],_glob_V018[i,4],sd2018)
          aadd(glob_V018, aclone(_glob_V018[i]))
        endif
      endif
    next

    glob_V019 := {}
    for i := 1 to len(_glob_V019)
      if y > 2021
        if between_date(_glob_V019[i, 5], _glob_V019[i, 6], sd2022)
          // aadd(glob_V019, aclone(_glob_V019[i]))
          aaaa := _glob_V019[i]
          aaaa[3] := split(_glob_V019[i, 3][1],', ')
          aadd(glob_V019, aaaa)
        endif
      elseif y == 2021
        if between_date(_glob_V019[i,5],_glob_V019[i,6],sd2021)
          // aadd(glob_V019, aclone(_glob_V019[i]))
          aaaa := _glob_V019[i]
          aaaa[3] := split(_glob_V019[i, 3][1],', ')
          aadd(glob_V019, aaaa)
        endif
      elseif y == 2020
        if between_date(_glob_V019[i,5],_glob_V019[i,6],sd2020)
          // aadd(glob_V019, aclone(_glob_V019[i]))
          aaaa := _glob_V019[i]
          aaaa[3] := split(_glob_V019[i, 3][1],', ')
          aadd(glob_V019, aaaa)
        endif
      elseif y == 2019
        if between_date(_glob_V019[i,5],_glob_V019[i,6],sd2019) .or. ;
             between_date(_glob_V019[i,5],_glob_V019[i,6],0d20190301) // для методов, добавленных с 1 марта
          // aadd(glob_V019, aclone(_glob_V019[i]))
          aaaa := _glob_V019[i]
          aaaa[3] := split(_glob_V019[i, 3][1],', ')
          aadd(glob_V019, aaaa)
        endif
      else
        if between_date(_glob_V019[i,5],_glob_V019[i,6],sd2018)
          // aadd(glob_V019, aclone(_glob_V019[i]))
          aaaa := _glob_V019[i]
          aaaa[3] := split(_glob_V019[i, 3][1],', ')
          aadd(glob_V019, aaaa)
        endif
      endif
    next
  endif
  return NIL
  