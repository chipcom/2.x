
***** 13.02.22
Function make_V018_V019(lk_data)
  // lk_data - дата на которую необходимо создать массивы ВМП
  Static sy := 0, sd2018 := 0d20180101, sd2019 := 0d20190101, sd2020 := 0d20200101
  static sd2021 := 0d20210101, sd2022 := 0d20220101
  Local i, y := year(lk_data)
  local aaaa
  
  if sy != y
    sy := y
    glob_V018 := getV018table(lk_data)
    glob_V019 := getV019table(lk_data)
  endif
  return NIL
  