
***** 07.02.21
Function make_V018_V019(lk_data)
  // lk_data - ��� �� ������ ����室��� ᮧ���� ���ᨢ� ���
  Static sy := 0, sd2018 := 0d20180101, sd2019 := 0d20190101, sd2020 := 0d20200101
  static sd2021 := 0d20210101
  Local i, y := year(lk_data)
  
  if sy != y
    sy := y
    glob_V018 := {}
    for i := 1 to len(_glob_V018)
      if y > 2020
        if between_date(_glob_V018[i,3],_glob_V018[i,4],sd2021)
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
      if y > 2020
        if between_date(_glob_V019[i,5],_glob_V019[i,6],sd2021)
          aadd(glob_V019, aclone(_glob_V019[i]))
        endif
      elseif y == 2020
        if between_date(_glob_V019[i,5],_glob_V019[i,6],sd2020)
          aadd(glob_V019, aclone(_glob_V019[i]))
        endif
      elseif y == 2019
        if between_date(_glob_V019[i,5],_glob_V019[i,6],sd2019) .or. ;
           between_date(_glob_V019[i,5],_glob_V019[i,6],0d20190301) // ��� ��⮤��, ����������� � 1 ����
          aadd(glob_V019, aclone(_glob_V019[i]))
        endif
      else
        if between_date(_glob_V019[i,5],_glob_V019[i,6],sd2018)
          aadd(glob_V019, aclone(_glob_V019[i]))
        endif
      endif
    next
  endif
  return NIL
  